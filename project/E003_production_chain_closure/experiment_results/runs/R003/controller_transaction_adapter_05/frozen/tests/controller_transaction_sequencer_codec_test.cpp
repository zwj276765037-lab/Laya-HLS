#include "laya_controller_transaction.h"

#include <cassert>
#include <iostream>

using namespace laya;

namespace {

NumericIdentity identity() {
  NumericIdentity value;
  value.request_id = 501;
  value.generation = 29;
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

portal::Response compute_completion(const portal::Command& request) {
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

provenance::Request provenance_request() {
  provenance::Request value;
  value.action = provenance::Action::END;
  value.event_seq = 81;
  value.origin_seq = 80;
  value.identity = identity();
  value.context = context(63, Op::LN_ATTN);
  value.descriptor_count = 1;
  value.descriptor[0].target_ref = {Buffer::NORM, 0, 21};
  value.descriptor[0].target_region = 0;
  value.expected_unit = OutputUnit::F32;
  value.expected_elements = 16384;
  value.issued_store_bytes[0] = 65536;
  return value;
}

provenance::Response provenance_completion(
    const provenance::Request& request) {
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
  value.target_region[0] = request.descriptor[0].target_region;
  value.output_elements = request.expected_elements;
  value.observed_store_bytes[0] = request.issued_store_bytes[0];
  value.drained = true;
  value.scope_active = false;
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

producer::Completion producer_completion(const producer::Request& request) {
  producer::Completion value;
  value.family = request.family;
  value.request_seq = request.request_seq;
  value.provenance_origin_seq = request.provenance_origin_seq;
  value.status = Status::OK;
  value.unit = OutputUnit::F32;
  value.finished = true;
  value.output_elements = request.expected_elements;
  value.issued_store_bytes = uint64_t(request.expected_elements) * 4u;
  value.consumed_source_bytes = value.issued_store_bytes;
  value.identity = request.identity;
  value.context = request.context;
  value.source = request.source;
  value.destination = request.destination;
  value.source_region = request.source_region;
  value.destination_region = request.destination_region;
  value.source_role = request.source_role;
  value.destination_role = request.destination_role;
  value.D = request.D;
  value.gamma = request.gamma;
  value.eps_bits = request.eps_bits;
  value.row_bytes = request.row_bytes;
  value.source_first_offset = request.source_first_offset;
  value.destination_first_offset = request.destination_first_offset;
  value.source_row_step = request.source_row_step;
  value.destination_row_step = request.destination_row_step;
  return value;
}

} // namespace

int main() {
  using namespace laya::transaction;
  const portal::Command compute = compute_request();
  const provenance::Request provenance = provenance_request();
  const producer::Request producer = producer_request();
  const Request request[3] = {
      make_request(compute), make_request(provenance, CANCEL_CLEANUP),
      make_request(producer)};
  const Completion response[3] = {
      make_completion(request[0], compute_completion(compute), true),
      make_completion(request[1], provenance_completion(provenance), true),
      make_completion(request[2], producer_completion(producer), true)};

  for (unsigned i = 0; i < 3; ++i) {
    const RequestPacket outgoing = encode(request[i]);
    assert(portal::get(outgoing.data(), 0, 4) == kRequestMagic);
    assert(portal::get(outgoing.data(), 8, 2) == i + 1);
    Completion decoded;
    Check result = decode(encode(response[i]), request[i], decoded);
    assert(result.code == Status::OK);
    assert(completion_frame_complete(decoded));
    assert(completion_binding_ok(decoded));
    assert(completion_safe_terminal(decoded));
  }

  Completion stale = response[2];
  ++stale.producer.request_seq;
  Completion decoded;
  assert(!decode(encode(stale), request[2], decoded));

  Completion undrained = response[1];
  undrained.provenance.drained = false;
  undrained.flags &= ~(REMOTE_DRAINED | REMOTE_TERMINAL);
  Check undrained_result = decode(encode(undrained), request[1], decoded);
  assert(undrained_result.code == Status::OK);
  assert(completion_binding_ok(decoded));
  assert(!completion_safe_terminal(decoded));

  Completion rejected = make_local_reject(
      request[0], {Status::E_PROTOCOL, detail(7, 0, 14)});
  Check rejected_result = decode(encode(rejected), request[0], decoded);
  assert(rejected_result.code == Status::E_PROTOCOL);
  assert(decoded.flags & LOCAL_REJECT);
  assert(!completion_binding_ok(decoded));

  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_SEQUENCER_CODEC_PASS "
            << "kinds=3 external_protocol_codecs=0 stale_rejected=1 "
            << "undrained_nonterminal=1 local_reject=1\n";
  return 0;
}
