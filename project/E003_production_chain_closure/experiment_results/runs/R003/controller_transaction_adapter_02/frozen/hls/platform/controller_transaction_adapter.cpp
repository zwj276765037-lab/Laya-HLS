#include "laya_controller_transaction_adapter.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace {

using namespace laya;

enum class State : uint8_t {
  READ_INTERNAL,
  PREPARE,
  SEND_EXTERNAL,
  RECEIVE_EXTERNAL,
  WRITE_INTERNAL,
};

template<std::size_t Bytes>
ap_uint<512> packet_word(const std::array<uint8_t, Bytes>& packet,
                         unsigned beat) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  return word;
}

template<std::size_t Bytes>
void store_word(std::array<uint8_t, Bytes>& packet, unsigned beat,
                const ap_uint<512>& word) {
  for (unsigned byte = 0; byte < 64; ++byte)
    packet[beat * 64 + byte] =
        uint8_t(word.range(byte * 8 + 7, byte * 8));
}

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
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
      request.provenance.action == provenance::Action::RELEASE ||
      request.provenance.action == provenance::Action::INVALIDATE;
}

} // namespace

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
#pragma HLS pipeline II=1
  using namespace laya;
  static State state = State::READ_INTERNAL;
  static unsigned beat = 0;
  static bool cancel_at_accept = false;
  static transaction::RequestPacket internal_request{};
  static transaction::CompletionPacket internal_completion{};
  static std::array<uint8_t, portal::kCommandBytes> external_request{};
  static std::array<uint8_t, portal::kResponseBytes> external_response{};
  static transaction::Request request{};

  if (state == State::READ_INTERNAL) {
    ap_uint<512> word;
    if (transaction_request.read_nb(word)) {
      if (beat == 0) cancel_at_accept = cancel;
      store_word(internal_request, beat, word);
      ++beat;
      if (beat == transaction::kRequestBeats) {
        beat = 0; state = State::PREPARE;
      }
    }
    return;
  }

  if (state == State::PREPARE) {
    Check parsed = transaction::decode(internal_request, request);
    if (!parsed || (cancel_at_accept && !cleanup_allowed(request))) {
      if (parsed)
        parsed = Check{Status::E_PROTOCOL, laya::detail(7, 0, 14)};
      internal_completion = transaction::encode(
          transaction::make_local_reject(request, parsed));
      state = State::WRITE_INTERNAL;
      return;
    }
    if (request.kind == transaction::Kind::COMPUTE_TRANSACTION) {
      const auto packet = portal::encode(request.compute);
      for (unsigned i = 0; i < packet.size(); ++i) external_request[i] = packet[i];
    } else if (request.kind == transaction::Kind::PROVENANCE_TRANSACTION) {
      const auto packet = provenance::encode(request.provenance);
      for (unsigned i = 0; i < packet.size(); ++i) external_request[i] = packet[i];
    } else {
      const auto packet = producer::encode(request.producer);
      for (unsigned i = 0; i < packet.size(); ++i) external_request[i] = packet[i];
    }
    state = State::SEND_EXTERNAL;
    return;
  }

  if (state == State::SEND_EXTERNAL) {
    const ap_uint<512> word = packet_word(external_request, beat);
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

    transaction::Completion completion;
    if (request.kind == transaction::Kind::COMPUTE_TRANSACTION) {
      portal::Response response;
      portal::ResponsePacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      (void)portal::decode(packet, request.compute, response);
      completion = transaction::make_completion(
          request, response, compute_binding_ok(request.compute, response));
    } else if (request.kind == transaction::Kind::PROVENANCE_TRANSACTION) {
      provenance::Response response;
      provenance::ResponsePacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      (void)provenance::decode(packet, request.provenance, response);
      completion = transaction::make_completion(
          request, response,
          provenance_binding_ok(request.provenance, response));
    } else {
      producer::Completion response;
      producer::CompletionPacket packet{};
      for (unsigned i = 0; i < packet.size(); ++i) packet[i] = external_response[i];
      (void)producer::decode(packet, request.producer, response);
      completion = transaction::make_completion(
          request, response, producer_binding_ok(request.producer, response));
    }
    internal_completion = transaction::encode(completion);
    state = State::WRITE_INTERNAL;
    return;
  }

  const ap_uint<512> word = packet_word(internal_completion, beat);
  if (transaction_completion.write_nb(word)) {
    ++beat;
    if (beat == transaction::kCompletionBeats) {
      beat = 0; cancel_at_accept = false; request = transaction::Request{};
      state = State::READ_INTERNAL;
    }
  }
}
#endif
