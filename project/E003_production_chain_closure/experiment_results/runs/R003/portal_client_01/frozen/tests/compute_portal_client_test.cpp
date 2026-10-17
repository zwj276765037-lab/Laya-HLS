#include "laya_compute_portal_client.h"
#include <cassert>
#include <iostream>
#include <vector>

using namespace laya;
using namespace laya::full;
using namespace laya::portal;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 9; id.generation = 17; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x10 + i);
    id.numeric_tag[i] = uint8_t(0x30 + i);
    id.layout_tag[i] = uint8_t(0x50 + i);
    id.build_tag[i] = uint8_t(0x70 + i);
  }
  return id;
}

ModelBinding model(const NumericIdentity& id) {
  ModelBinding value;
  for (unsigned i = 0; i < 16; ++i) {
    value.identity[i] = id.model_tag[i];
    value.identity[16 + i] = id.numeric_tag[i];
    value.identity[32 + i] = id.layout_tag[i];
    value.identity[48 + i] = id.build_tag[i];
  }
  for (unsigned i = 64; i < value.identity.size(); ++i)
    value.identity[i] = uint8_t(i * 29u + 7u);
  for (unsigned i = 0; i < value.expected_aux_header.size(); ++i)
    value.expected_aux_header[i] = uint8_t(i * 11u + 3u);
  return value;
}

FullMemory memory() {
  static uint8_t byte = 0;
  FullMemory m;
  m.embedding = &byte; m.embedding_bytes = 54803648;
  m.io = &byte; m.io_bytes = 32768;
  m.w_q0 = &byte; m.w_q0_bytes = 184682496;
  m.w_q1 = &byte; m.w_q1_bytes = 184680448;
  m.w_scale = &byte; m.w_scale_bytes = 23085184;
  m.aux = &byte; m.aux_bytes = 1671872;
  m.state0 = &byte; m.state0_bytes = 16920576;
  m.state1 = &byte; m.state1_bytes = 16919104;
  m.qkv0 = &byte; m.qkv0_bytes = 12u * 1024u * 1024u;
  m.qkv1 = &byte; m.qkv1_bytes = 12u * 1024u * 1024u;
  m.ff0 = &byte; m.ff0_bytes = 41u * 1024u * 1024u;
  m.ff1 = &byte; m.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  m.att_out = &byte; m.att_out_bytes = 8u * 1024u * 1024u;
  return m;
}

Response success(const Command& command) {
  Response r;
  r.status = Status::OK; r.service = command.service;
  r.rows = command.rows; r.row_block = command.row_block;
  r.generation = command.generation; r.task_id = command.context.task_id;
  r.drained = true; r.published = true;
  r.identity = command.identity; r.context = command.context;
  r.source = command.source; r.source_region = command.source_region;
  r.a = command.a; r.w = command.w; r.ps = command.ps;
  r.dst = command.dst; r.dst_region = command.dst_region;
  r.a_epoch = command.a_epoch; r.w_epoch = command.w_epoch;
  r.producer_context = command.producer_context;
  r.quant_context = command.quant_context;
  r.linear_context = command.linear_context;
  r.future_dst = command.future_dst;
  r.future_dst_region = command.future_dst_region;
  if (command.service == Service::LOAD_W) {
    r.output_elements = ((uint32_t(command.N) + 7u) & ~7u) *
                        (command.K / 32u) * 34u;
    r.unit = OutputUnit::BYTES;
  } else if (command.service == Service::QUANT) {
    r.output_elements = uint32_t(command.rows) * command.K / 32u;
    r.unit = OutputUnit::Q8_GROUP;
  } else if (command.service == Service::MATRIX) {
    r.output_elements = uint32_t(command.rows) * command.N;
    r.unit = OutputUnit::F32;
  } else {
    r.output_elements = uint32_t(command.rows) * command.K;
    r.unit = OutputUnit::F32;
  }
  return r;
}

struct Sink {
  std::vector<Word512> words;
  void write(const Word512& word) { words.push_back(word); }
};
struct Source {
  ResponseWords words{};
  unsigned index = 0;
  Word512 read() { assert(index < words.size()); return words[index++]; }
};

void reject_response(const Command& expected, Response changed) {
  Response decoded;
  assert(!verify_response(response_words(encode(changed)), expected, decoded));
}

} // namespace

int main() {
  const NumericIdentity id = identity();
  const ModelBinding model_binding = model(id);
  const FullMemory mem = memory();
  TaskReservation reservation;
  PortalReservation portal;
  GDownPlan plan;
  assert(reserve_g_down(reservation, portal, 0, id, 0,
      {Buffer::WI, 0, 1}, {Buffer::GATE, 0, 1}, {Buffer::TMP, 0, 1},
      0, 0, 0, 0, plan));
  assert(plan.count == 4 && portal.high_water() == 25);
  FullWeightDescriptor descriptor;
  assert(full_lookup_weight(plan.load.weight, descriptor));
  const GDownWindow& window = plan.window[0];
  TaskBinding binding{window.producer.ctx, window.quant, window.linear};

  Command load;
  assert(build_load_command(id, mem, model_binding, descriptor, plan.load,
                            plan.load_generation, load));
  assert(load.service == Service::LOAD_W && load.context.task_id == 5);
  assert(load.w == plan.load.dst && load.w_epoch == plan.load.dst.epoch);
  assert(load.weight[0].offset == descriptor.q_base[0] &&
         load.weight[2].span == descriptor.scale_span);
  assert(load.producer_context.task_id == 0 && load.future_dst == none());

  Command geglu;
  assert(build_geglu_command(id, mem, model_binding, window.producer,
                             binding, window.producer_generation, geglu));
  assert(geglu.context.task_id == window.producer.ctx.task_id);
  assert(geglu.source == window.producer.src0 && geglu.dst == window.producer.dst);
  assert(geglu.source_role == Bo::FF0 && geglu.output_role[0] == Bo::FF1);
  assert(geglu.source_range.offset == 0 && geglu.source_range.span == 41u * 1024u * 1024u);
  assert(geglu.output[0].bo_span == mem.ff1_bytes && geglu.output[0].span == mem.ff1_bytes);
  assert(geglu.source_stride == 20992 && geglu.row_stride == 10496 &&
         geglu.batch_stride == 10747904);

  Command quant;
  assert(build_quant_command(id, mem, model_binding, binding,
                             window.quant_generation, quant));
  assert(quant.context.task_id == window.quant.ctx.task_id &&
         quant.source == window.quant.src && quant.dst == window.quant.a_dst);
  assert(quant.source_role == Bo::FF1 && quant.output[0].span == 0);
  assert(quant.source_stride == 10496 && quant.row_stride == 10496 &&
         quant.batch_stride == 10747904);

  Command matrix;
  assert(build_matrix_command(id, mem, model_binding, binding,
                              window.view[0], matrix));
  assert(matrix.context.task_id == window.linear.ctx.task_id &&
         matrix.source == window.quant.src && matrix.dst == window.linear.dst);
  assert(matrix.rows == 4 && matrix.row_block == 0 &&
         matrix.output_role[0] == Bo::STATE1);
  assert(matrix.output[0].bo_span == mem.state1_bytes &&
         matrix.output[0].offset == 8u * 1024u * 1024u &&
         matrix.output[0].span == 8u * 1024u * 1024u);
  assert(matrix.row_stride == 4096 && matrix.batch_stride == 4194304);

  // The portable 512-bit transport is exactly the codec byte sequence.
  const CommandPacket packet = encode(matrix);
  const CommandWords beats = command_words(packet);
  for (unsigned i = 0; i < packet.size(); ++i)
    assert(beats[i / 64].byte[i % 64] == packet[i]);
  Response expected = success(matrix), decoded;
  const ResponsePacket reply = encode(expected);
  const ResponseWords reply_words = response_words(reply);
  assert(response_packet(reply_words) == reply);
  assert(verify_response(reply_words, matrix, decoded));

  Sink sink;
  Source source{reply_words};
  assert(exchange(sink, source, matrix, decoded));
  assert(sink.words.size() == 16 && source.index == 8);
  for (unsigned i = 0; i < sink.words.size(); ++i)
    assert(sink.words[i].byte == beats[i].byte);

  // Exact outstanding binding rejects old generation/view, service, P/Q/L,
  // and Ref responses even when the rest of the frame is valid.
  Response bad = expected; bad.generation = window.view[1].generation;
  reject_response(matrix, bad);
  bad = expected; bad.service = Service::QUANT; reject_response(matrix, bad);
  bad = expected; bad.row_block = 4; reject_response(matrix, bad);
  bad = expected; ++bad.producer_context.task_id; reject_response(matrix, bad);
  bad = expected; ++bad.quant_context.task_id; reject_response(matrix, bad);
  bad = expected; ++bad.linear_context.task_id; reject_response(matrix, bad);
  bad = expected; ++bad.a.epoch; reject_response(matrix, bad);
  bad = expected; bad.output_elements--; reject_response(matrix, bad);
  bad = expected; bad.published = false; reject_response(matrix, bad);

  // A well-bound service failure is propagated and may not claim publication.
  bad = expected; bad.status = Status::E_NUMERICAL;
  bad.error_detail = detail(7, uint8_t(Op::LIN_DOWN), 15);
  bad.bad_element = 3; bad.output_elements = 0;
  bad.unit = OutputUnit::NONE; bad.published = false;
  Check failed = verify_response(response_words(encode(bad)), matrix, decoded);
  assert(failed.code == Status::E_NUMERICAL && failed.bad_element == 3);

  // Builders reject malformed view and false GEGLU source provenance.
  ViewTicket invalid_view{window.view[0].generation, 14, 4};
  assert(!build_matrix_command(id, mem, model_binding, binding,
                               invalid_view, matrix));
  VectorTask wrong = window.producer;
  wrong.dst.epoch++;
  assert(!build_geglu_command(id, mem, model_binding, wrong, binding,
                              window.producer_generation, geglu));

  std::cout << "FULL_CURRENT_PORTAL_CLIENT_PASS command_beats=16 response_beats=8 "
               "builders=4 exact_response_binding=1 failure_propagation=1 "
               "model_identity_explicit=1\n";
}
