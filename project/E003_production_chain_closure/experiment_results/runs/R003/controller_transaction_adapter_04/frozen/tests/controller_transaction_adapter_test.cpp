#include "laya_controller_transaction_adapter.h"
#include "laya_model_layout_generated.h"

#include <cassert>
#include <iostream>

using namespace laya;

namespace {

struct Streams {
  hls::stream<ap_uint<512>> transaction_request{"transaction_request"};
  hls::stream<ap_uint<512>> transaction_completion{"transaction_completion"};
  hls::stream<ap_uint<512>> compute_command{"compute_command"};
  hls::stream<ap_uint<512>> compute_response{"compute_response"};
  hls::stream<ap_uint<512>> provenance_command{"provenance_command"};
  hls::stream<ap_uint<512>> provenance_response{"provenance_response"};
  hls::stream<ap_uint<512>> producer_request{"producer_request"};
  hls::stream<ap_uint<512>> producer_completion{"producer_completion"};
};

void step(Streams& s, bool cancel = false) {
  laya_command_provenance_adapter(
      cancel, s.transaction_request, s.transaction_completion,
      s.compute_command, s.compute_response, s.provenance_command,
      s.provenance_response, s.producer_request, s.producer_completion);
}

template<std::size_t Bytes>
ap_uint<512> pack(const std::array<uint8_t, Bytes>& p, unsigned beat) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = p[beat * 64 + byte];
  return word;
}

template<std::size_t Bytes>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat)
    stream.write(pack(packet, beat));
}

template<std::size_t Bytes>
std::array<uint8_t, Bytes> dequeue(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

template<std::size_t Bytes>
void assert_packet(hls::stream<ap_uint<512>>& stream,
                   const std::array<uint8_t, Bytes>& expected) {
  assert(stream.size() == Bytes / 64);
  assert(dequeue<Bytes>(stream) == expected);
}

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 61; id.generation = 73; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = full::kFullModelTag[i];
    id.numeric_tag[i] = full::kFullNumericTag[i];
    id.layout_tag[i] = full::kFullLayoutTag[i];
    id.build_tag[i] = full::kFullBuildTag[i];
  }
  return id;
}

std::array<uint8_t, 416> model_identity() {
  std::array<uint8_t, 416> value{};
  const uint8_t* tags[4] = {full::kFullModelTag, full::kFullNumericTag,
      full::kFullLayoutTag, full::kFullBuildTag};
  for (unsigned tag = 0; tag < 4; ++tag)
    for (unsigned byte = 0; byte < 16; ++byte)
      value[16 * tag + byte] = tags[tag][byte];
  portal::put(value.data(), 64, 0x4d33314cu, 4);
  portal::put(value.data(), 68, 1, 2); portal::put(value.data(), 70, 416, 2);
  portal::put(value.data(), 76, 1, 4);
  for (unsigned byte = 0; byte < 32; ++byte)
    value[80 + byte] = full::kFullSourceSha256[byte];
  portal::put(value.data(), 112, 5, 4);
  portal::put(value.data(), 116, 16, 4);
  portal::put(value.data(), 120, 128, 4);
  constexpr uint32_t roles[5] = {0, 2, 3, 4, 5};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned off = 128 + 16 * i;
    portal::put(value.data(), off, roles[i], 4);
    portal::put(value.data(), off + 4, 1, 4);
    portal::put(value.data(), off + 8, full::kFullModelBoSizes[i], 8);
  }
  return value;
}

portal::Command compute_request() {
  portal::Command c;
  c.service = portal::Service::MATRIX; c.generation = 101;
  c.identity = identity();
  c.context = {19, Op::LIN_QKV, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  c.producer_context = {17, Op::LN_ATTN, 2, 1, 0,
                        RowSpace::TOKEN, 16, 16};
  c.quant_context = {18, Op::QUANT, 2, 1, 0,
                     RowSpace::TOKEN, 16, 16};
  c.linear_context = c.context;
  c.source = {Buffer::NORM, 0, 2}; c.a = {Buffer::A8, 0, 3};
  c.w = {Buffer::WEIGHT, 0, 4}; c.ps = {Buffer::PS, 0, 5};
  c.dst = {Buffer::QKV, 0, 6}; c.future_dst = c.dst;
  c.model_identity = model_identity();
  c.K = 1024; c.N = 1024; c.rows = 4; c.row_block = 4;
  c.a_epoch = 3; c.w_epoch = 4; c.weight_key = 0x0101;
  c.output_role[0] = Bo::QKV0;
  c.output[0] = {12u * 1024u * 1024u, 16u * 4096u, 16u * 4096u};
  c.row_stride = 4096; c.batch_stride = 4u * 1024u * 1024u;
  return c;
}

portal::Response compute_response(const portal::Command& c) {
  portal::Response r;
  r.status = Status::OK; r.service = c.service; r.rows = c.rows;
  r.row_block = c.row_block; r.generation = c.generation;
  r.task_id = c.context.task_id; r.output_elements = 4096;
  r.unit = OutputUnit::F32; r.drained = true; r.published = true;
  r.identity = c.identity; r.context = c.context;
  r.source = c.source; r.a = c.a; r.w = c.w; r.ps = c.ps; r.dst = c.dst;
  r.a_epoch = c.a_epoch; r.w_epoch = c.w_epoch;
  r.producer_context = c.producer_context;
  r.quant_context = c.quant_context; r.linear_context = c.linear_context;
  r.future_dst = c.future_dst;
  return r;
}

provenance::Request provenance_begin() {
  provenance::Request r;
  r.action = provenance::Action::BEGIN; r.event_seq = 102;
  r.origin_seq = 102; r.identity = identity();
  r.context = {20, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  r.model_identity = model_identity(); r.descriptor_count = 1;
  r.expected_unit = OutputUnit::F32; r.expected_elements = 16384;
  auto& d = r.descriptor[0];
  d.target_ref = {Buffer::NORM, 0, 2}; d.stage = 2; d.layer = 1;
  d.batch = 255; d.row_space = RowSpace::TOKEN; d.rows = 64;
  d.width = 1024; d.content = Content::F32; d.role = Bo::STATE1;
  d.bo_span = 16919104; d.row_stride = 4096;
  d.batch_stride = 4194304; d.owner_extent_span = 262144;
  auto& g = r.geometry[0];
  g.first_offset = 16u * 4096u; g.segment_bytes = 4096;
  g.row_count = 16; g.repeat_count = 1; g.row_step = 4096;
  g.total_write_bytes = 65536;
  g.component = provenance::Component::FULL_WIDTH; g.head = 255;
  return r;
}

provenance::Request provenance_end(const provenance::Request& begin) {
  provenance::Request r = begin;
  r.action = provenance::Action::END; r.event_seq = 104;
  r.origin_seq = begin.event_seq; r.reported_status = Status::OK;
  r.reported_unit = OutputUnit::F32;
  r.reported_elements = r.expected_elements;
  r.reported_bad_element = UINT64_MAX;
  r.issued_store_bytes[0] = r.geometry[0].total_write_bytes;
  return r;
}

provenance::Response provenance_end_response(
    const provenance::Request& q) {
  provenance::Response r;
  r.action = q.action; r.event_seq = q.event_seq; r.origin_seq = q.origin_seq;
  r.status = Status::OK; r.drained = true; r.scope_active = false;
  r.descriptor_count = 1; r.identity = q.identity; r.context = q.context;
  r.target_ref[0] = q.descriptor[0].target_ref;
  r.observed_store_bytes[0] = q.issued_store_bytes[0];
  r.output_elements = q.expected_elements; r.unit = q.expected_unit;
  return r;
}

producer::Request producer_request_value() {
  producer::Request r;
  r.request_seq = 103; r.provenance_origin_seq = 102;
  r.identity = identity();
  r.context = {20, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  r.model_identity = model_identity();
  r.source = {Buffer::HIDDEN, 0, 1};
  r.destination = {Buffer::NORM, 0, 2};
  r.source_role = Bo::STATE0; r.destination_role = Bo::STATE1;
  r.source_first_offset = 16u * 4096u;
  r.destination_first_offset = 16u * 4096u;
  r.source_bo_span = 16920576; r.destination_bo_span = 16919104;
  r.expected_elements = 16384;
  return r;
}

producer::Completion producer_response(const producer::Request& q) {
  producer::Completion r;
  r.family = q.family; r.request_seq = q.request_seq;
  r.provenance_origin_seq = q.provenance_origin_seq;
  r.status = Status::OK; r.unit = OutputUnit::F32; r.finished = true;
  r.bad_element = UINT64_MAX; r.output_elements = q.expected_elements;
  r.issued_store_bytes = uint64_t(q.expected_elements) * 4u;
  r.consumed_source_bytes = r.issued_store_bytes;
  r.identity = q.identity; r.context = q.context;
  r.source = q.source; r.destination = q.destination;
  r.D = q.D; r.gamma = q.gamma; r.source_region = q.source_region;
  r.destination_region = q.destination_region;
  r.source_role = q.source_role; r.destination_role = q.destination_role;
  r.eps_bits = q.eps_bits; r.row_bytes = q.row_bytes;
  r.source_first_offset = q.source_first_offset;
  r.destination_first_offset = q.destination_first_offset;
  r.source_row_step = q.source_row_step;
  r.destination_row_step = q.destination_row_step;
  return r;
}

void run_until(Streams& s, std::size_t expected,
               hls::stream<ap_uint<512>>& stream, bool cancel = false) {
  for (unsigned cycle = 0; cycle < 400 && stream.size() < expected; ++cycle)
    step(s, cancel);
  assert(stream.size() == expected);
}

} // namespace

int main() {
  using namespace laya::transaction;
  Streams s;

  // COMPUTE: no response is available while the full command is emitted.
  const portal::Command compute = compute_request();
  const Request compute_tx = make_request(compute);
  enqueue(s.transaction_request, encode(compute_tx));
  run_until(s, portal::kCommandBeats, s.compute_command);
  assert(s.transaction_completion.empty() && s.provenance_command.empty() &&
         s.producer_request.empty());
  assert_packet(s.compute_command, portal::encode(compute));
  const portal::Response compute_rsp = compute_response(compute);
  const auto compute_rsp_packet = portal::encode(compute_rsp);
  s.compute_response.write(pack(compute_rsp_packet, 0));
  for (unsigned i = 0; i < 4; ++i) step(s, true);
  assert(s.transaction_completion.empty());
  for (unsigned beat = 1; beat < portal::kResponseBeats; ++beat)
    s.compute_response.write(pack(compute_rsp_packet, beat));
  run_until(s, kCompletionBeats, s.transaction_completion, true);
  Completion completion;
  assert(decode(dequeue<kCompletionBytes>(s.transaction_completion),
                compute_tx, completion));
  assert(completion_binding_ok(completion) &&
         completion_safe_terminal(completion));

  enqueue(s.transaction_request, encode(compute_tx));
  run_until(s, portal::kCommandBeats, s.compute_command);
  assert_packet(s.compute_command, portal::encode(compute));
  portal::Response malformed_compute = compute_response(compute);
  malformed_compute.generation += 3;
  auto malformed_compute_packet = portal::encode(malformed_compute);
  malformed_compute_packet[portal::RESPONSE_USED] = 1;
  enqueue(s.compute_response, malformed_compute_packet);
  run_until(s, kCompletionBeats, s.transaction_completion);
  const Check malformed_compute_check = decode(
      dequeue<kCompletionBytes>(s.transaction_completion), compute_tx,
      completion);
  assert(malformed_compute_check.code == Status::E_PROTOCOL &&
         completion_frame_complete(completion) &&
         !completion_binding_ok(completion) &&
         !completion_safe_terminal(completion) &&
         completion.compute.generation == malformed_compute.generation);

  // A task first accepted while cancel is already asserted is consumed as one
  // internal descriptor and rejected without putting any external beat.
  const producer::Request producer = producer_request_value();
  const Request producer_tx = make_request(producer);
  enqueue(s.transaction_request, encode(producer_tx));
  step(s, true);
  run_until(s, kCompletionBeats, s.transaction_completion);
  assert(s.producer_request.empty());
  Check rejected = decode(dequeue<kCompletionBytes>(s.transaction_completion),
                          producer_tx, completion);
  assert(rejected.code == Status::E_PROTOCOL &&
         (completion.flags & LOCAL_REJECT) &&
         !completion_safe_terminal(completion));

  // A cancel cleanup END remains admissible and closes the existing physical
  // scope; cancel stays asserted throughout command and response transfer.
  const provenance::Request end = provenance_end(provenance_begin());
  const Request end_tx = make_request(end, CANCEL_CLEANUP);
  enqueue(s.transaction_request, encode(end_tx));
  run_until(s, provenance::kRequestBeats, s.provenance_command, true);
  assert_packet(s.provenance_command, provenance::encode(end));
  enqueue(s.provenance_response, provenance::encode(provenance_end_response(end)));
  run_until(s, kCompletionBeats, s.transaction_completion, true);
  assert(decode(dequeue<kCompletionBytes>(s.transaction_completion),
                end_tx, completion));
  assert(completion_binding_ok(completion) &&
         completion_safe_terminal(completion));

  enqueue(s.transaction_request, encode(end_tx));
  run_until(s, provenance::kRequestBeats, s.provenance_command);
  assert_packet(s.provenance_command, provenance::encode(end));
  provenance::Response malformed_provenance = provenance_end_response(end);
  malformed_provenance.event_seq += 5;
  auto malformed_provenance_packet = provenance::encode(malformed_provenance);
  malformed_provenance_packet[192] = 1;
  enqueue(s.provenance_response, malformed_provenance_packet);
  run_until(s, kCompletionBeats, s.transaction_completion);
  const Check malformed_provenance_check = decode(
      dequeue<kCompletionBytes>(s.transaction_completion), end_tx,
      completion);
  assert(malformed_provenance_check.code == Status::E_PROTOCOL &&
         completion_frame_complete(completion) &&
         !completion_binding_ok(completion) &&
         !completion_safe_terminal(completion) &&
         completion.provenance.event_seq == malformed_provenance.event_seq);

  // A syntactically valid but stale producer completion is returned with its
  // actual key and BINDING_OK clear.  The caller must retain its old tracker.
  enqueue(s.transaction_request, encode(producer_tx));
  run_until(s, producer::kRequestBeats, s.producer_request);
  assert_packet(s.producer_request, producer::encode(producer));
  producer::Completion stale = producer_response(producer);
  ++stale.request_seq;
  enqueue(s.producer_completion, producer::encode(stale));
  run_until(s, kCompletionBeats, s.transaction_completion);
  const Check stale_check = decode(
      dequeue<kCompletionBytes>(s.transaction_completion), producer_tx,
      completion);
  assert(stale_check.code == Status::E_PROTOCOL &&
         !completion_binding_ok(completion) &&
         completion.producer.request_seq == stale.request_seq);

  // A complete response with malformed reserved bytes is also nonterminal,
  // but its fixed-width actual key remains visible so the sequencer can
  // identify and isolate the responding peer instead of receiving a default
  // key that looks like an adapter-generated echo.
  enqueue(s.transaction_request, encode(producer_tx));
  run_until(s, producer::kRequestBeats, s.producer_request);
  assert_packet(s.producer_request, producer::encode(producer));
  producer::Completion malformed = producer_response(producer);
  malformed.request_seq += 2;
  auto malformed_packet = producer::encode(malformed);
  malformed_packet[224] = 1;
  enqueue(s.producer_completion, malformed_packet);
  run_until(s, kCompletionBeats, s.transaction_completion);
  const Check malformed_check = decode(
      dequeue<kCompletionBytes>(s.transaction_completion), producer_tx,
      completion);
  assert(malformed_check.code == Status::E_PROTOCOL &&
         completion_frame_complete(completion) &&
         !completion_binding_ok(completion) &&
         !completion_safe_terminal(completion) &&
         completion.producer.request_seq == malformed.request_seq);

  assert(s.compute_command.empty() && s.compute_response.empty() &&
         s.provenance_command.empty() && s.provenance_response.empty() &&
         s.producer_request.empty() && s.producer_completion.empty() &&
         s.transaction_request.empty() && s.transaction_completion.empty());
  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_PASS kinds=3 "
            << "external_signals=18 request_beats=24 completion_beats=16 "
            << "partial_response_cancel=1 cancel_local_reject=1 "
            << "cancel_cleanup_end=1 stale_binding=1 malformed_raw_keys=3\n";
  return 0;
}
