#include "laya_compute_portal_client.h"
#include "laya_model_layout_generated.h"
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
    id.model_tag[i] = kFullModelTag[i];
    id.numeric_tag[i] = kFullNumericTag[i];
    id.layout_tag[i] = kFullLayoutTag[i];
    id.build_tag[i] = kFullBuildTag[i];
  }
  return id;
}

void oracle_put(uint8_t* p, unsigned offset, uint64_t value, unsigned bytes) {
  for (unsigned i = 0; i < bytes; ++i)
    p[offset + i] = uint8_t(value >> (8 * i));
}

void oracle_copy(uint8_t* dst, const uint8_t* src, unsigned bytes) {
  for (unsigned i = 0; i < bytes; ++i) dst[i] = src[i];
}

ModelBinding oracle_model() {
  ModelBinding value;
  oracle_copy(value.identity.data(), kFullModelTag, 16);
  oracle_copy(value.identity.data() + 16, kFullNumericTag, 16);
  oracle_copy(value.identity.data() + 32, kFullLayoutTag, 16);
  oracle_copy(value.identity.data() + 48, kFullBuildTag, 16);
  oracle_put(value.identity.data(), 64, 0x4d33314cu, 4);
  oracle_put(value.identity.data(), 68, 1, 2);
  oracle_put(value.identity.data(), 70, 416, 2);
  oracle_put(value.identity.data(), 72, 0, 4);
  oracle_put(value.identity.data(), 76, 1, 4);
  oracle_copy(value.identity.data() + 80, kFullSourceSha256, 32);
  oracle_put(value.identity.data(), 112, 5, 4);
  oracle_put(value.identity.data(), 116, 16, 4);
  oracle_put(value.identity.data(), 120, 128, 4);
  const uint32_t roles[5] = {0, 2, 3, 4, 5};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned entry = 128 + 16 * i;
    oracle_put(value.identity.data(), entry, roles[i], 4);
    oracle_put(value.identity.data(), entry + 4, 1, 4);
    oracle_put(value.identity.data(), entry + 8, kFullModelBoSizes[i], 8);
  }

  uint8_t* aux = value.expected_aux_header.data();
  aux[0] = 'L'; aux[1] = 'Y'; aux[2] = 'M'; aux[3] = 'P';
  oracle_put(aux, 4, 1, 2); oracle_put(aux, 6, 0, 2);
  oracle_put(aux, 8, 128, 4); oracle_put(aux, 12, 13, 4);
  oracle_put(aux, 16, 1, 4);
  oracle_copy(aux + 32, kFullModelTag, 16);
  oracle_copy(aux + 48, kFullNumericTag, 16);
  oracle_copy(aux + 64, kFullLayoutTag, 16);
  oracle_copy(aux + 80, kFullBuildTag, 16);
  oracle_copy(aux + 96, kFullSourceSha256, 32);
  return value;
}

void reject_model(const NumericIdentity& id, const ModelBinding& model,
                  Status status) {
  const Check c = validate_l13m_model_binding(id, model);
  assert(!c && c.code == status);
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
  ModelBinding model_binding;
  assert(build_l13m_model_binding(model_binding));
  const ModelBinding independent = oracle_model();
  assert(model_binding.identity == independent.identity);
  assert(model_binding.expected_aux_header == independent.expected_aux_header);
  assert(validate_l13m_model_binding(id, model_binding));

  // The byte oracle is independent of the implementation builder.  Structural
  // violations are ABI errors; current-package identity mismatches are model
  // errors.  The old Q8S2 slice is never accepted by format auto-detection.
  ModelBinding changed = model_binding;
  changed.identity[64] ^= 1; reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[68] ^= 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[70] ^= 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[72] = 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[76] ^= 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[124] = 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[128] = 2;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding;
  for (unsigned i = 0; i < 16; ++i)
    std::swap(changed.identity[128 + i], changed.identity[144 + i]);
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[132] ^= 2;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.identity[208] = 1;
  reject_model(id, changed, Status::E_ABI);
  for (unsigned offset : {0u, 16u, 32u, 48u, 80u, 136u}) {
    changed = model_binding; changed.identity[offset] ^= 1;
    reject_model(id, changed, Status::E_MODEL);
  }
  changed = model_binding; changed.expected_aux_header[0] = 'Q';
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.expected_aux_header[20] = 1;
  reject_model(id, changed, Status::E_ABI);
  changed = model_binding; changed.expected_aux_header[32] ^= 1;
  reject_model(id, changed, Status::E_MODEL);
  changed = model_binding; changed.expected_aux_header[96] ^= 1;
  reject_model(id, changed, Status::E_MODEL);
  ModelBinding q8s2{};
  oracle_put(q8s2.identity.data(), 0, 0x32533851u, 4);
  oracle_put(q8s2.identity.data(), 64, 1, 4);
  reject_model(id, q8s2, Status::E_ABI);
  NumericIdentity wrong_identity = id; wrong_identity.build_tag[0] ^= 1;
  reject_model(wrong_identity, model_binding, Status::E_MODEL);

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
  assert(load.model_identity == model_binding.identity &&
         load.expected_aux_header == model_binding.expected_aux_header);

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
  assert(geglu.model_identity == model_binding.identity);

  Command quant;
  assert(build_quant_command(id, mem, model_binding, binding,
                             window.quant_generation, quant));
  assert(quant.context.task_id == window.quant.ctx.task_id &&
         quant.source == window.quant.src && quant.dst == window.quant.a_dst);
  assert(quant.source_role == Bo::FF1 && quant.output[0].span == 0);
  assert(quant.source_stride == 10496 && quant.row_stride == 10496 &&
         quant.batch_stride == 10747904);
  assert(quant.model_identity == model_binding.identity);

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
  assert(matrix.model_identity == model_binding.identity);

  // QKV keeps one typed parent and emits the two fixed physical shards.
  TaskBinding qkv;
  qkv.producer = {100, Op::LN_FFN, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  qkv.quant.ctx = {101, Op::QUANT, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  qkv.quant.src = {Buffer::NORM, 0, 2};
  qkv.quant.a_dst = {Buffer::A8, 0, 2};
  qkv.quant.K = 1024;
  qkv.linear.ctx = {102, Op::LIN_QKV, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  qkv.linear.a = qkv.quant.a_dst;
  qkv.linear.w = {Buffer::WEIGHT, 0, 2};
  qkv.linear.ps = {Buffer::PS, 0, 2};
  qkv.linear.dst = {Buffer::QKV, 0, 2};
  qkv.linear.weight = {1, 0}; qkv.linear.K = 1024; qkv.linear.N = 3072;
  Command qkv_matrix;
  assert(build_matrix_command(id, mem, model_binding, qkv,
                              {100, 0, 4}, qkv_matrix));
  assert(qkv_matrix.output_role[0] == Bo::QKV0 &&
         qkv_matrix.output_role[1] == Bo::QKV1);
  assert(qkv_matrix.output[0].bo_span == mem.qkv0_bytes &&
         qkv_matrix.output[0].span == mem.qkv0_bytes &&
         qkv_matrix.output[1].bo_span == mem.qkv1_bytes &&
         qkv_matrix.output[1].span == mem.qkv1_bytes);
  assert(qkv_matrix.row_stride == 12288 &&
         qkv_matrix.batch_stride == 12582912);

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

  changed = model_binding; changed.identity[80] ^= 1;
  assert(!build_load_command(id, mem, changed, descriptor, plan.load,
                             plan.load_generation, load));
  assert(!build_geglu_command(id, mem, changed, window.producer, binding,
                              window.producer_generation, geglu));
  assert(!build_quant_command(id, mem, changed, binding,
                              window.quant_generation, quant));
  assert(!build_matrix_command(id, mem, changed, binding,
                               window.view[0], matrix));

  std::cout << "FULL_CURRENT_PORTAL_CLIENT_PASS command_beats=16 response_beats=8 "
               "builders=4 qkv_two_ranges=1 exact_response_binding=1 failure_propagation=1 "
               "l13m_v1_oracle=1 lymp_v1_oracle=1 identity_mutation_reject=1 "
               "q8s2_reject=1 canonical_all_services=1\n";
}
