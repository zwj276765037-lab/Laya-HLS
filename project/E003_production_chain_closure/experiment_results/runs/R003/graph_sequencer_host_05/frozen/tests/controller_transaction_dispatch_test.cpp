#include "laya_controller_transaction_dispatch.h"
#include "full_kernel_wrapper.h"

#include <cassert>
#include <iostream>

using namespace laya;

namespace {

NumericIdentity identity() {
  NumericIdentity value;
  value.request_id = 601;
  value.generation = 31;
  value.B = 1;
  value.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    value.model_tag[i] = uint8_t(0x10 + i);
    value.numeric_tag[i] = uint8_t(0x30 + i);
    value.layout_tag[i] = uint8_t(0x50 + i);
    value.build_tag[i] = uint8_t(0x70 + i);
  }
  return value;
}

TaskContext context(uint32_t task_id, Op op) {
  return {task_id, op, 2, 3, 0, RowSpace::TOKEN, 16, 16};
}

portal::Command compute_request() {
  portal::Command value;
  value.service = portal::Service::QUANT;
  value.generation = 71;
  value.identity = identity();
  value.context = context(61, Op::QUANT);
  value.producer_context = context(60, Op::LN_ATTN);
  value.quant_context = value.context;
  value.linear_context = context(62, Op::LIN_QKV);
  value.source = {Buffer::NORM, 0, 11};
  value.a = {Buffer::A8, 0, 12};
  value.future_dst = {Buffer::QKV, 0, 13};
  value.K = 1024;
  value.rows = 16;
  value.row_block = 16;
  return value;
}

portal::Response compute_response(const portal::Command& request) {
  portal::Response value;
  value.status = Status::OK;
  value.service = request.service;
  value.generation = request.generation;
  value.identity = request.identity;
  value.context = request.context;
  value.task_id = request.context.task_id;
  value.producer_context = request.producer_context;
  value.quant_context = request.quant_context;
  value.linear_context = request.linear_context;
  value.source = request.source;
  value.a = request.a;
  value.w = request.w;
  value.ps = request.ps;
  value.dst = request.dst;
  value.future_dst = request.future_dst;
  value.source_region = request.source_region;
  value.dst_region = request.dst_region;
  value.future_dst_region = request.future_dst_region;
  value.a_epoch = request.a_epoch;
  value.w_epoch = request.w_epoch;
  value.rows = request.rows;
  value.row_block = request.row_block;
  value.output_elements = 512;
  value.unit = OutputUnit::Q8_GROUP;
  value.drained = true;
  return value;
}

provenance::Request end_request() {
  provenance::Request value;
  value.action = provenance::Action::END;
  value.event_seq = 81;
  value.origin_seq = 80;
  value.identity = identity();
  value.context = context(63, Op::LN_ATTN);
  value.descriptor_count = 1;
  value.descriptor[0].target_ref = {Buffer::NORM, 0, 21};
  value.expected_unit = OutputUnit::F32;
  value.expected_elements = 16384;
  value.issued_store_bytes[0] = 65536;
  return value;
}

provenance::Response end_response(const provenance::Request& request) {
  provenance::Response value;
  value.action = request.action;
  value.event_seq = request.event_seq;
  value.origin_seq = request.origin_seq;
  value.status = Status::OK;
  value.unit = request.expected_unit;
  value.identity = request.identity;
  value.context = request.context;
  value.descriptor_count = request.descriptor_count;
  value.target_ref[0] = request.descriptor[0].target_ref;
  value.output_elements = request.expected_elements;
  value.observed_store_bytes[0] = request.issued_store_bytes[0];
  value.drained = true;
  return value;
}

producer::Request producer_request() {
  producer::Request value;
  value.request_seq = 91;
  value.provenance_origin_seq = 80;
  value.identity = identity();
  value.context = context(63, Op::LN_ATTN);
  value.source = {Buffer::HIDDEN, 0, 20};
  value.destination = {Buffer::NORM, 0, 21};
  value.source_role = Bo::STATE0;
  value.destination_role = Bo::STATE1;
  value.source_first_offset = 65536;
  value.destination_first_offset = 65536;
  value.source_bo_span = 16920576;
  value.destination_bo_span = 16919104;
  value.expected_elements = 16384;
  return value;
}

template<std::size_t Bytes>
void push_packet(hls::stream<ap_uint<512>>& stream,
                 const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    ap_uint<512> word = 0;
    for (unsigned byte = 0; byte < 64; ++byte)
      word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
    stream.write(word);
  }
}

template<std::size_t Bytes>
std::array<uint8_t, Bytes> pop_packet(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

} // namespace

int main() {
  using namespace laya::transaction;
  auto* graph_top = &laya_typed_q8_forward_graph_sequencer;
  assert(graph_top != nullptr);

  const portal::Command compute = compute_request();
  const Request compute_tx = make_request(compute);
  Completion compute_done = make_completion(
      compute_tx, compute_response(compute), true);
  hls::stream<ap_uint<512>> requests, completions;
  push_packet(completions, encode(compute_done));
  portal::Response decoded_compute;
  uint32_t flags = 0;
  Check result = exchange_compute(requests, completions, compute,
                                  decoded_compute, &flags);
  assert(result.code == Status::OK);
  assert(flags & BINDING_OK);
  assert(flags & REMOTE_TERMINAL);
  assert(pop_packet<kRequestBytes>(requests) == encode(compute_tx));

  Completion stale = compute_done;
  ++stale.compute.generation;
  push_packet(completions, encode(stale));
  flags = UINT32_MAX;
  result = exchange_compute(requests, completions, compute,
                            decoded_compute, &flags);
  assert(result.code == Status::E_PROTOCOL);
  assert(flags == 0);
  (void)pop_packet<kRequestBytes>(requests);

  const provenance::Request end = end_request();
  const Request end_tx = make_request(end, CANCEL_CLEANUP);
  Completion end_done = make_completion(end_tx, end_response(end), true);
  push_packet(completions, encode(end_done));
  provenance::Response decoded_end;
  flags = 0;
  result = exchange_provenance(requests, completions, end, decoded_end,
                               &flags);
  assert(result.code == Status::OK);
  assert(flags & REMOTE_TERMINAL);
  const RequestPacket emitted_end = pop_packet<kRequestBytes>(requests);
  assert(portal::get(emitted_end.data(), 32, 4) == CANCEL_CLEANUP);

  Completion waiting = end_done;
  waiting.provenance.status = Status::E_BUFFER;
  waiting.provenance.unit = OutputUnit::NONE;
  waiting.provenance.output_elements = 0;
  waiting.provenance.observed_store_bytes[0] = 0;
  waiting.provenance.drained = false;
  waiting.provenance.scope_active = true;
  waiting.flags &= ~(REMOTE_DRAINED | REMOTE_TERMINAL);
  waiting.flags |= REMOTE_SCOPE_ACTIVE;
  push_packet(completions, encode(waiting));
  result = exchange_provenance(requests, completions, end, decoded_end,
                               &flags);
  assert(result.code == Status::E_BUFFER);
  assert(flags & REMOTE_SCOPE_ACTIVE);
  assert(!(flags & REMOTE_TERMINAL));
  (void)pop_packet<kRequestBytes>(requests);

  const producer::Request producer = producer_request();
  const Request producer_tx = make_request(producer);
  Completion rejected = make_local_reject(
      producer_tx, {Status::E_PROTOCOL, laya::detail(7, 0, 14)});
  push_packet(completions, encode(rejected));
  producer::Completion decoded_producer;
  flags = 0;
  result = exchange_producer(requests, completions, producer,
                             decoded_producer, &flags);
  assert(result.code == Status::E_PROTOCOL);
  assert(flags & LOCAL_REJECT);
  assert(!(flags & REMOTE_TERMINAL));
  (void)pop_packet<kRequestBytes>(requests);

  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_DISPATCH_PASS "
            << "compute_ok=1 stale_flags_zero=1 cleanup_flag=1 "
            << "undrained_nonterminal=1 producer_local_reject=1 "
            << "graph_top=1 external_protocol_codecs=0 "
            << "transaction_fifos=2 transaction_signals=6\n";
  return 0;
}
