#include "laya_controller_transaction_adapter.h"
#include "laya_controller_request_mapping.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace {

using namespace laya;

enum class State : uint8_t {
  READ_INTERNAL,
  PREPARE,
  SEND_EXTERNAL,
  RECEIVE_EXTERNAL,
  NORMALIZE_RESPONSE,
  WRITE_INTERNAL,
};

template<std::size_t Bytes>
ap_uint<512> packet_word(const std::array<uint8_t, Bytes>& packet,
                         unsigned beat) {
#pragma HLS inline off
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  }
  return word;
}

template<std::size_t Bytes>
void store_word(std::array<uint8_t, Bytes>& packet, unsigned beat,
                const ap_uint<512>& word) {
#pragma HLS inline off
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    packet[beat * 64 + byte] =
        uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
}

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

bool raw_zeros(const uint8_t* p, unsigned first, unsigned after) {
  for (unsigned i = first; i < after; ++i)
    if (p[i]) return false;
  return true;
}

// The protocol decoders deliberately reject malformed framing before exposing
// any fields.  The adapter still has to return the actual response key so the
// sequencer can isolate a stale/malformed peer without mistaking an expected
// key echo for evidence.  These readers only extract fixed-width fields from a
// complete 8-beat frame; the syntax predicates below decide whether the frame
// is eligible for BINDING_OK.
portal::Response raw_compute_response(const portal::ResponsePacket& p) {
  portal::Response r;
  const uint16_t status = uint16_t(portal::get(p.data(), portal::OP_STATUS, 2));
  const uint8_t unit = p[portal::UNIT];
  r.status = status <= uint16_t(Status::E_INTERNAL) ? Status(status) :
                                                     Status::E_ABI;
  r.unit = unit <= uint8_t(OutputUnit::BYTES) ? OutputUnit(unit) :
                                               OutputUnit::NONE;
  r.generation = portal::get(p.data(), portal::GENERATION, 8);
  r.task_id = uint32_t(portal::get(p.data(), portal::TASK, 4));
  r.error_detail = uint32_t(portal::get(p.data(), portal::FLAGS_DETAIL, 4));
  r.first_error_rank = portal::get(p.data(), portal::RANK, 8);
  r.bad_element = portal::get(p.data(), portal::BAD_ELEMENT, 8);
  r.output_elements = uint32_t(portal::get(p.data(), portal::ELEMENTS, 4));
  r.drained = p[portal::RETIRE_FLAGS] & 1;
  r.published = p[portal::RETIRE_FLAGS] & 2;
  r.cycles = portal::get(p.data(), portal::CYCLES, 8);
  for (unsigned i = 0; i < r.counters.size(); ++i)
    r.counters[i] = uint32_t(portal::get(p.data(), portal::COUNTERS + 4 * i, 4));
  r.identity = portal::get_identity(p.data(), portal::RESPONSE_IDENTITY);
  r.context = portal::get_context(p.data(), portal::RESPONSE_CONTEXT);
  r.source = portal::get_ref(p.data(), portal::RESPONSE_REFS);
  r.source_region = p[portal::RESPONSE_REFS + 6];
  r.a = portal::get_ref(p.data(), portal::RESPONSE_REFS + 8);
  r.w = portal::get_ref(p.data(), portal::RESPONSE_REFS + 16);
  r.ps = portal::get_ref(p.data(), portal::RESPONSE_REFS + 24);
  r.dst = portal::get_ref(p.data(), portal::RESPONSE_REFS + 32);
  r.dst_region = p[portal::RESPONSE_REFS + 38];
  r.a_epoch = uint32_t(portal::get(p.data(), portal::RESPONSE_A_EPOCH, 4));
  r.w_epoch = uint32_t(portal::get(p.data(), portal::RESPONSE_W_EPOCH, 4));
  r.producer_context = portal::get_context(
      p.data(), portal::RESPONSE_PRODUCER_CONTEXT);
  r.quant_context = portal::get_context(p.data(), portal::RESPONSE_QUANT_CONTEXT);
  r.linear_context = portal::get_context(
      p.data(), portal::RESPONSE_LINEAR_CONTEXT);
  r.future_dst = portal::get_ref(p.data(), portal::RESPONSE_FUTURE_DST_REF);
  r.future_dst_region = p[portal::RESPONSE_FUTURE_DST_REF + 6];
  r.rows = p[portal::RESPONSE_ROWS];
  r.row_block = p[portal::RESPONSE_ROW_BLOCK];
  r.service = portal::Service(portal::get(p.data(), portal::RESPONSE_SERVICE, 2));
  return r;
}

bool compute_response_syntax_ok(const portal::ResponsePacket& p) {
  if (portal::get(p.data(), portal::MAGIC, 4) != portal::kResponseMagic ||
      portal::get(p.data(), portal::VERSION, 2) != portal::kVersion ||
      portal::get(p.data(), portal::OP_STATUS, 2) >
          uint16_t(Status::E_INTERNAL) ||
      p[portal::UNIT] > uint8_t(OutputUnit::BYTES) ||
      (p[portal::RETIRE_FLAGS] & ~3u) ||
      !raw_zeros(p.data(), 46, 48) || !raw_zeros(p.data(), 56, 64) ||
      !raw_zeros(p.data(), 120, 128) ||
      !raw_zeros(p.data(), portal::RESPONSE_USED, portal::kResponseBytes) ||
      p[portal::RESPONSE_FUTURE_DST_REF + 7]) return false;
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned off = portal::RESPONSE_REFS + 8 * i;
    if (p[off + 7] ||
        ((i == 1 || i == 2 || i == 3) && p[off + 6])) return false;
  }
  return true;
}

provenance::Response raw_provenance_response(
    const provenance::ResponsePacket& p) {
  provenance::Response r;
  const uint16_t status = uint16_t(portal::get(p.data(), 24, 2));
  const uint8_t unit = p[44];
  r.action = provenance::Action(portal::get(p.data(), 6, 2));
  r.event_seq = portal::get(p.data(), 8, 8);
  r.origin_seq = portal::get(p.data(), 16, 8);
  r.status = status <= uint16_t(Status::E_INTERNAL) ? Status(status) :
                                                     Status::E_ABI;
  r.unit = unit <= uint8_t(OutputUnit::BYTES) ? OutputUnit(unit) :
                                               OutputUnit::NONE;
  r.drained = p[26] & 1;
  r.scope_active = p[26] & 2;
  r.owner_published = p[26] & 4;
  r.error_detail = uint32_t(portal::get(p.data(), 28, 4));
  r.bad_element = portal::get(p.data(), 32, 8);
  r.output_elements = uint32_t(portal::get(p.data(), 40, 4));
  r.descriptor_count = p[45];
  r.observed_store_bytes[0] = portal::get(p.data(), 48, 8);
  r.observed_store_bytes[1] = portal::get(p.data(), 56, 8);
  r.identity = portal::get_identity(p.data(), 64);
  r.context = portal::get_context(p.data(), 148);
  for (unsigned i = 0; i < 2; ++i) {
    r.target_ref[i] = portal::get_ref(p.data(), 160 + 16 * i);
    r.target_region[i] = p[166 + 16 * i];
    r.old_ref[i] = portal::get_ref(p.data(), 168 + 16 * i);
    r.old_region[i] = p[174 + 16 * i];
  }
  return r;
}

bool provenance_response_syntax_ok(const provenance::ResponsePacket& p) {
  const uint64_t action = portal::get(p.data(), 6, 2);
  if (portal::get(p.data(), 0, 4) != provenance::kResponseMagic ||
      portal::get(p.data(), 4, 2) != provenance::kVersion ||
      action < uint16_t(provenance::Action::CLAIM) ||
      action > uint16_t(provenance::Action::INVALIDATE) ||
      portal::get(p.data(), 24, 2) > uint16_t(Status::E_INTERNAL) ||
      (p[26] & ~7u) || p[27] || p[44] > uint8_t(OutputUnit::BYTES) ||
      !raw_zeros(p.data(), 46, 48) ||
      !raw_zeros(p.data(), 192, provenance::kResponseBytes)) return false;
  for (unsigned off = 160; off < 192; off += 8)
    if (p[off + 7]) return false;
  return true;
}

producer::Completion raw_producer_completion(
    const producer::CompletionPacket& p) {
  producer::Completion r;
  const uint16_t status = uint16_t(portal::get(p.data(), 10, 2));
  const uint8_t unit = p[12];
  r.family = producer::Family(portal::get(p.data(), 8, 2));
  r.status = status <= uint16_t(Status::E_INTERNAL) ? Status(status) :
                                                     Status::E_ABI;
  r.unit = unit <= uint8_t(OutputUnit::BYTES) ? OutputUnit(unit) :
                                               OutputUnit::NONE;
  r.finished = p[13] != 0;
  r.request_seq = portal::get(p.data(), 16, 8);
  r.provenance_origin_seq = portal::get(p.data(), 24, 8);
  r.error_detail = uint32_t(portal::get(p.data(), 32, 4));
  r.output_elements = uint32_t(portal::get(p.data(), 36, 4));
  r.bad_element = portal::get(p.data(), 40, 8);
  r.issued_store_bytes = portal::get(p.data(), 48, 8);
  r.consumed_source_bytes = portal::get(p.data(), 56, 8);
  r.identity = portal::get_identity(p.data(), 64);
  r.context = portal::get_context(p.data(), 148);
  r.source = portal::get_ref(p.data(), 160);
  r.destination = portal::get_ref(p.data(), 168);
  r.source_role = Bo(p[176]);
  r.destination_role = Bo(p[177]);
  r.source_region = p[178];
  r.destination_region = p[179];
  r.D = uint16_t(portal::get(p.data(), 180, 2));
  r.gamma = p[182];
  r.eps_bits = uint32_t(portal::get(p.data(), 184, 4));
  r.row_bytes = uint32_t(portal::get(p.data(), 188, 4));
  r.source_first_offset = portal::get(p.data(), 192, 8);
  r.destination_first_offset = portal::get(p.data(), 200, 8);
  r.source_row_step = portal::get(p.data(), 208, 8);
  r.destination_row_step = portal::get(p.data(), 216, 8);
  return r;
}

bool producer_completion_syntax_ok(const producer::CompletionPacket& p) {
  return portal::get(p.data(), 0, 4) == producer::kCompletionMagic &&
      portal::get(p.data(), 4, 2) == producer::kVersion &&
      portal::get(p.data(), 6, 2) == producer::kCompletionBeats &&
      portal::get(p.data(), 8, 2) ==
          uint16_t(producer::Family::LAYERNORM) &&
      portal::get(p.data(), 10, 2) <= uint16_t(Status::E_INTERNAL) &&
      p[12] <= uint8_t(OutputUnit::BYTES) && p[13] <= 1 &&
      raw_zeros(p.data(), 14, 16) && !p[167] && !p[175] && !p[183] &&
      p[166] == p[178] && p[174] == p[179] &&
      raw_zeros(p.data(), 224, producer::kCompletionBytes);
}

bool compute_binding_ok(const portal::Command& expected,
                        const portal::Response& r) {
  return r.generation == expected.generation &&
      r.task_id == expected.context.task_id &&
      numeric_identity_equal(r.identity, expected.identity) &&
      same_context(r.context, expected.context) &&
      r.source == expected.source && r.a == expected.a &&
      r.w == expected.w && r.ps == expected.ps && r.dst == expected.dst &&
      r.source_region == expected.source_region &&
      r.dst_region == expected.dst_region && r.a_epoch == expected.a_epoch &&
      r.w_epoch == expected.w_epoch &&
      same_context(r.producer_context, expected.producer_context) &&
      same_context(r.quant_context, expected.quant_context) &&
      same_context(r.linear_context, expected.linear_context) &&
      r.future_dst == expected.future_dst &&
      r.future_dst_region == expected.future_dst_region &&
      r.rows == expected.rows && r.row_block == expected.row_block &&
      r.service == expected.service && r.drained &&
      (!r.published || r.status == Status::OK) &&
      (r.status == Status::OK ||
       (!r.output_elements && r.unit == OutputUnit::NONE));
}

bool provenance_binding_ok(const provenance::Request& expected,
                           const provenance::Response& r) {
  const bool scope_valid = expected.action == provenance::Action::BEGIN ?
      r.scope_active == (r.status == Status::OK) :
      expected.action == provenance::Action::END ?
          (r.status != Status::OK || !r.scope_active) : !r.scope_active;
  if (r.action != expected.action || r.event_seq != expected.event_seq ||
      r.origin_seq != expected.origin_seq ||
      !numeric_identity_equal(r.identity, expected.identity) ||
      !same_context(r.context, expected.context) ||
      r.descriptor_count != expected.descriptor_count ||
      (r.status == Status::OK && !r.drained) || !scope_valid ||
      r.owner_published !=
          (expected.action == provenance::Action::PUBLISH &&
           r.status == Status::OK)) return false;
  for (unsigned i = 0; i < 2; ++i) {
    const bool used = i < expected.descriptor_count;
    if ((used &&
         (r.target_ref[i] != expected.descriptor[i].target_ref ||
          r.target_region[i] != expected.descriptor[i].target_region ||
          r.old_ref[i] != expected.descriptor[i].old_ref ||
          r.old_region[i] != expected.descriptor[i].old_region)) ||
        (!used &&
         (r.target_ref[i].id != Buffer::NONE ||
          r.old_ref[i].id != Buffer::NONE || r.target_region[i] ||
          r.old_region[i] || r.observed_store_bytes[i]))) return false;
  }
  if (expected.action == provenance::Action::END &&
      r.status == Status::OK) {
    if (expected.reported_status != Status::OK ||
        r.output_elements != expected.expected_elements ||
        r.unit != expected.expected_unit) return false;
    for (unsigned i = 0; i < expected.descriptor_count; ++i)
      if (r.observed_store_bytes[i] != expected.issued_store_bytes[i])
        return false;
  } else if (r.output_elements || r.unit != OutputUnit::NONE ||
             (expected.action != provenance::Action::END &&
              (r.observed_store_bytes[0] || r.observed_store_bytes[1])))
    return false;
  return true;
}

bool producer_binding_ok(const producer::Request& expected,
                         const producer::Completion& r) {
  if (!producer::same_request_binding(expected, r) || !r.finished ||
      r.issued_store_bytes > uint64_t(expected.expected_elements) * 4u ||
      r.consumed_source_bytes > uint64_t(expected.expected_elements) * 4u)
    return false;
  if (r.status == Status::OK)
    return r.unit == expected.expected_unit &&
        r.output_elements == expected.expected_elements && !r.error_detail &&
        r.bad_element == UINT64_MAX &&
        r.issued_store_bytes == uint64_t(expected.expected_elements) * 4u &&
        r.consumed_source_bytes == uint64_t(expected.expected_elements) * 4u;
  return r.unit == OutputUnit::NONE && !r.output_elements;
}

bool cleanup_allowed(const transaction::Request& request) {
  if (!(request.flags & transaction::CANCEL_CLEANUP) ||
      request.kind != transaction::Kind::PROVENANCE_TRANSACTION) return false;
  return request.provenance.action == provenance::Action::END ||
#if !defined(LAYA_MANAGED_TRANSACTION_ADAPTER) || !LAYA_MANAGED_TRANSACTION_ADAPTER
      request.provenance.action == provenance::Action::RELEASE ||
#endif
      request.provenance.action == provenance::Action::INVALIDATE;
}

Check parse_internal(const transaction::RequestPacket& packet,
                     transaction::Request& request) {
#pragma HLS inline off
  // Sequential semantic validation retains the original full parser.  It is
  // scheduled as its own finite phase instead of expanding into a pipelined
  // word-transport combinational block.
  request = transaction::Request{};
  return transaction::decode(packet, request);
}

transaction::CompletionPacket reject_internal(
    const transaction::Request& request, Check failure) {
#pragma HLS inline off
  return transaction::encode(transaction::make_local_reject(request, failure));
}

transaction::CompletionPacket normalize_response(
    const transaction::Request& request,
    const std::array<uint8_t, portal::kResponseBytes>& external_response) {
#pragma HLS inline off
    transaction::Completion completion;
    if (request.kind == transaction::Kind::COMPUTE_TRANSACTION) {
      portal::ResponsePacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      portal::Response response = raw_compute_response(packet);
      const bool syntax_ok = compute_response_syntax_ok(packet);
      if (!syntax_ok) {
        response.drained = false;
        response.published = false;
      }
      completion = transaction::make_completion(
          request, response, syntax_ok &&
              compute_binding_ok(request.compute, response));
    } else if (request.kind == transaction::Kind::PROVENANCE_TRANSACTION) {
      provenance::ResponsePacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      provenance::Response response = raw_provenance_response(packet);
      const bool syntax_ok = provenance_response_syntax_ok(packet);
      if (!syntax_ok) {
        response.drained = false;
        response.owner_published = false;
      }
      completion = transaction::make_completion(
          request, response,
          syntax_ok &&
              provenance_binding_ok(request.provenance, response));
    } else {
      producer::CompletionPacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      producer::Completion response = raw_producer_completion(packet);
      const bool syntax_ok = producer_completion_syntax_ok(packet);
      if (!syntax_ok) response.finished = false;
      completion = transaction::make_completion(
          request, response, syntax_ok &&
              producer_binding_ok(request.producer, response));
    }
    return transaction::encode(completion);
}

} // namespace

namespace laya::transaction {

ap_uint<512> external_request_word(const RequestPacket& packet,
                                  Kind kind, unsigned beat) {
#pragma HLS inline off
  ap_uint<512> word = 0;
  const uint16_t action = uint16_t(portal::get(packet.data(), 10, 2));
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    const unsigned offset = beat * 64 + byte;
    int16_t source = kind == Kind::COMPUTE_TRANSACTION ?
        mapping::kCompute[offset] : kind == Kind::PROVENANCE_TRANSACTION ?
        mapping::kProvenance[offset] : mapping::kProducer[offset];
    // The external codec omits unused owner and geometry slots.  LTX1 can
    // still carry semantic defaults there; never forward those as wire data.
    if (kind == Kind::PROVENANCE_TRANSACTION) {
      if (offset >= 608 && offset < 864 &&
          (offset - 608) / 128 >= packet[579]) source = -1;
      if (offset >= 864 && offset < 992 &&
          ((offset - 864) / 64 >= packet[579] ||
           (action != uint16_t(provenance::Action::BEGIN) &&
            action != uint16_t(provenance::Action::END)))) source = -1;
    }
    word.range(byte * 8 + 7, byte * 8) = source >= 0 ?
        packet[unsigned(source)] : uint8_t(-1 - source);
  }
  return word;
}

} // namespace laya::transaction

extern "C" void laya_command_provenance_adapter(
    bool cancel,
    hls::stream<ap_uint<512>>& transaction_request,
    hls::stream<ap_uint<512>>& transaction_completion,
    hls::stream<ap_uint<512>>& compute_command,
    hls::stream<ap_uint<512>>& compute_response,
    hls::stream<ap_uint<512>>& provenance_command,
    hls::stream<ap_uint<512>>& provenance_response,
    hls::stream<ap_uint<512>>& producer_request,
    hls::stream<ap_uint<512>>& producer_completion) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none port=cancel
#pragma HLS interface ap_fifo port=transaction_request
#pragma HLS interface ap_fifo port=transaction_completion
#pragma HLS interface ap_fifo port=compute_command
#pragma HLS interface ap_fifo port=compute_response
#pragma HLS interface ap_fifo port=provenance_command
#pragma HLS interface ap_fifo port=provenance_response
#pragma HLS interface ap_fifo port=producer_request
#pragma HLS interface ap_fifo port=producer_completion
#pragma HLS pipeline off
  using namespace laya;
  static State state = State::READ_INTERNAL;
  static unsigned beat = 0;
  static bool cancel_at_accept = false;
#if defined(LAYA_MANAGED_TRANSACTION_ADAPTER) && LAYA_MANAGED_TRANSACTION_ADAPTER
  // cancel must come from the wrapper's persistent revoke for this old A.
  // These are transaction-local transport facts, not an owner/cleanup proof.
  static bool transaction_cancelled = false;
  static bool external_presented = false;
  if ((state != State::READ_INTERNAL || beat != 0) && cancel)
    transaction_cancelled = true;
#endif
  static transaction::RequestPacket internal_request{};
  static transaction::CompletionPacket internal_completion{};
  static std::array<uint8_t, portal::kResponseBytes> external_response{};
  static transaction::Request request{};

  if (state == State::READ_INTERNAL) {
    ap_uint<512> word;
    if (transaction_request.read_nb(word)) {
      if (beat == 0) {
        cancel_at_accept = cancel;
#if defined(LAYA_MANAGED_TRANSACTION_ADAPTER) && LAYA_MANAGED_TRANSACTION_ADAPTER
        transaction_cancelled = cancel;
        external_presented = false;
#endif
      }
      store_word(internal_request, beat, word);
      ++beat;
      if (beat == transaction::kRequestBeats) {
        beat = 0; state = State::PREPARE;
      }
    }
    return;
  }

  if (state == State::PREPARE) {
    Check parsed = parse_internal(internal_request, request);
#if defined(LAYA_MANAGED_TRANSACTION_ADAPTER) && LAYA_MANAGED_TRANSACTION_ADAPTER
    transaction_cancelled = transaction_cancelled || cancel;
    const bool dispatch_cancelled = transaction_cancelled || cancel_at_accept;
#else
    const bool dispatch_cancelled = cancel_at_accept;
#endif
    if (!parsed || (dispatch_cancelled && !cleanup_allowed(request))) {
      if (parsed)
        parsed = Check{Status::E_PROTOCOL, laya::detail(7, 0, 14)};
      internal_completion = reject_internal(request, parsed);
      state = State::WRITE_INTERNAL;
      return;
    }
    state = State::SEND_EXTERNAL;
    return;
  }

  if (state == State::SEND_EXTERNAL) {
    const ap_uint<512> word = transaction::external_request_word(
        internal_request, request.kind, beat);
#if defined(LAYA_MANAGED_TRANSACTION_ADAPTER) && LAYA_MANAGED_TRANSACTION_ADAPTER
    // Check again after word preparation, before the first write attempt.
    // A failed write_nb does not prove that an old VALID was never presented.
    transaction_cancelled = transaction_cancelled || cancel;
    if (!external_presented && transaction_cancelled && !cleanup_allowed(request)) {
      internal_completion = reject_internal(
          request, Check{Status::E_PROTOCOL, laya::detail(7, 0, 14)});
      beat = 0;
      state = State::WRITE_INTERNAL;
      return;
    }
    external_presented = true;
#endif
    bool written = false;
    if (request.kind == transaction::Kind::COMPUTE_TRANSACTION)
      written = compute_command.write_nb(word);
    else if (request.kind == transaction::Kind::PROVENANCE_TRANSACTION)
      written = provenance_command.write_nb(word);
    else
      written = producer_request.write_nb(word);
    if (written) {
      ++beat;
      if (beat == portal::kCommandBeats) {
        beat = 0; state = State::RECEIVE_EXTERNAL;
      }
    }
    return;
  }

  if (state == State::RECEIVE_EXTERNAL) {
    ap_uint<512> word;
    bool read = false;
    if (request.kind == transaction::Kind::COMPUTE_TRANSACTION)
      read = compute_response.read_nb(word);
    else if (request.kind == transaction::Kind::PROVENANCE_TRANSACTION)
      read = provenance_response.read_nb(word);
    else
      read = producer_completion.read_nb(word);
    if (!read) return;
    store_word(external_response, beat, word);
    ++beat;
    if (beat != portal::kResponseBeats) return;
    beat = 0;

    state = State::NORMALIZE_RESPONSE;
    return;
  }

  if (state == State::NORMALIZE_RESPONSE) {
    internal_completion = normalize_response(request, external_response);
    state = State::WRITE_INTERNAL;
    return;
  }

  const ap_uint<512> word = packet_word(internal_completion, beat);
  if (transaction_completion.write_nb(word)) {
    ++beat;
    if (beat == transaction::kCompletionBeats) {
      beat = 0; cancel_at_accept = false;
#if defined(LAYA_MANAGED_TRANSACTION_ADAPTER) && LAYA_MANAGED_TRANSACTION_ADAPTER
      transaction_cancelled = false;
      external_presented = false;
#endif
      state = State::READ_INTERNAL;
    }
  }
}
#endif
