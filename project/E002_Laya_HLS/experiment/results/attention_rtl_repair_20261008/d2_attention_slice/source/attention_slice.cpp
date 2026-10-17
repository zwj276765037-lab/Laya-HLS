#include "laya_full_runtime.h"
#include "laya_full_cache_storage.h"

namespace laya::full {
namespace {

// Diagnostic boundary: the AXI fixture is a complete, real-model QKV tensor.
// Every byte enters the production QKV BO before production owner coverage is
// recorded. This top does not claim to implement the upstream Q8 projection.
static FullRuntime runtime;

void fail(uint32_t* observed, Check c, uint32_t phase) {
  observed[0] = uint32_t(c.code);
  observed[1] = c.detail;
  observed[2] = phase;
  observed[3] = runtime.last_task_id;
}

Check run(FullRuntime& rt, FullMemory& memory, const LoadTask& t,
          uint32_t elements, TaskDone& done) {
  Check c = full_run_task(rt, memory, t, done);
  return c ? check_done(done, t.ctx.task_id, elements, OutputUnit::BYTES) : c;
}
Check run(FullRuntime& rt, FullMemory& memory, const QKTask& t,
          uint32_t elements, TaskDone& done) {
  Check c = full_run_task(rt, memory, t, done);
  return c ? check_done(done, t.ctx.task_id, elements, OutputUnit::F32) : c;
}
Check run(FullRuntime& rt, FullMemory& memory, const SoftmaxTask& t,
          uint32_t elements, TaskDone& done) {
  Check c = full_run_task(rt, memory, t, done);
  return c ? check_done(done, t.ctx.task_id, elements, OutputUnit::F32) : c;
}
Check run(FullRuntime& rt, FullMemory& memory, const AVTask& t,
          uint32_t elements, TaskDone& done) {
  Check c = full_run_task(rt, memory, t, done);
  return c ? check_done(done, t.ctx.task_id, elements, OutputUnit::F32) : c;
}

}  // namespace
}  // namespace laya::full

extern "C" void attention_slice(const uint8_t* fixture,
                                 uint8_t* io, const uint8_t* aux,
                                 uint8_t* qkv0, uint8_t* qkv1,
                                 uint8_t* att_out, uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=fixture offset=slave bundle=fixture depth=786432 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io depth=32768 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux depth=128 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 depth=10240064 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 depth=10240064 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out depth=4100 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed depth=256 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  using namespace laya;
  using namespace laya::full;
  FullRuntime& rt = runtime;
  FullMemory memory;
  memory.io = io; memory.io_bytes = 32768;
  memory.aux = aux; memory.aux_bytes = 1671872;
  memory.qkv0 = qkv0; memory.qkv0_bytes = 12u << 20;
  memory.qkv1 = qkv1; memory.qkv1_bytes = 12u << 20;
  memory.att_out = att_out; memory.att_out_bytes = 8u << 20;
  observed[0] = 0xffffffffu;
  observed[1] = 0;
  observed[2] = 0;
  observed[3] = 0;

  Check c = full_parse_request(rt, memory);
  if (!c) { fail(observed, c, 1); return; }
  if (rt.inputs.identity.B != 1 || rt.inputs.identity.S != 64) {
    fail(observed, {Status::E_SHAPE, detail(7, 0, 20)}, 1);
    return;
  }
  FullOwnerSpec pair[2] = {
      {{Buffer::QKV, 0, 1}, 0, 4, 0, 255,
       RowSpace::TOKEN, 0, 64, 64, Content::QKV_FINAL},
      {{Buffer::QKV, 1, 1}, 0, 4, 0, 255,
       RowSpace::TOKEN, 0, 64, 64, Content::QKV_FINAL}};
  c = full_claim_qkv_pair(rt, pair);
  if (!c) { fail(observed, c, 2); return; }
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned row = 0; row < 64; ++row) {
        Address address;
        c = qkv_address(uint8_t(plane), 0, uint8_t(head),
                        uint16_t(row), 0, 1, 64, address);
        if (!c) { fail(observed, c, 3); return; }
        const uint32_t input_offset =
            ((row * 3072u + plane * 1024u + head * 64u) * 4u);
        uint8_t raw[256];
        for (unsigned byte = 0; byte < 256; ++byte)
          raw[byte] = fixture[input_offset + byte];
        c = full_write(memory, address.bo, address.offset, raw, 256);
        if (c) c = full_cover_qkv(rt, pair, uint8_t(plane),
                                  uint8_t(head), 0, uint16_t(row), 1);
        if (!c) { fail(observed, c, 4); return; }
      }
  c = full_publish_qkv_pair(rt, pair);
  if (!c) { fail(observed, c, 5); return; }
  observed[4] = uint32_t(rt.final_qkv_ref[0].epoch);
  observed[5] = uint32_t(rt.final_qkv_ref[1].epoch);

  const FullOwnerSpec output{{Buffer::ATT_OUT, 0, 1}, 0, 4, 0, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  c = full_claim_owner(rt, output);
  if (!c) { fail(observed, c, 6); return; }
  TaskDone done;
  LoadTask kv{};
  kv.ctx = {1, Op::LOAD_KV, 4, 0, 0, RowSpace::BATCH, 0, 1};
  kv.kind = 1; kv.dst = {Buffer::KV, 0, 1};
  kv.head = 0; kv.planes = 3; kv.byte_count = 2u * 64u * 64u * 4u;
  c = run(rt, memory, kv, kv.byte_count, done);
  if (!c) { fail(observed, c, 7); return; }
  observed[6] = done.output_elements;

  QKTask qk{};
  qk.ctx = {2, Op::QK, 4, 0, 0, RowSpace::TOKEN, 0, 1};
  qk.qkv_ref = {pair[0].ref, pair[1].ref};
  qk.kv = kv.dst; qk.score = {Buffer::SCORE_PROB, 0, 1};
  qk.head = 0; qk.mask_mode = 0; qk.S = 64;
  c = run(rt, memory, qk, 64, done);
  if (!c) { fail(observed, c, 8); return; }
  for (unsigned key = 0; key < 64; ++key)
    observed[16 + key] = numeric_f32_bits(full_cache_score(rt)[0][0][key]);

  const FullOwnerSpec score{qk.score, 0, 4, 0, 0,
                            RowSpace::TOKEN, 0, 1, 64, Content::SCORE};
  FullOwnerSpec probability = score;
  probability.ref.epoch = 2;
  probability.content = Content::PROB;
  c = full_begin_inplace_owner(rt, score, probability);
  if (!c) { fail(observed, c, 9); return; }
  SoftmaxTask softmax{};
  softmax.ctx = {3, Op::SOFTMAX_ATT, 4, 0, 0,
                 RowSpace::TOKEN, 0, 1};
  softmax.src = score.ref;
  softmax.dst = probability.ref;
  softmax.length = 64;
  c = run(rt, memory, softmax, 64, done);
  if (!c) { fail(observed, c, 10); return; }
  for (unsigned key = 0; key < 64; ++key)
    observed[80 + key] = numeric_f32_bits(full_cache_score(rt)[0][0][key]);

  AVTask av{};
  av.ctx = {4, Op::AV, 4, 0, 0, RowSpace::TOKEN, 0, 1};
  av.prob = probability.ref;
  av.kv = kv.dst;
  av.partial = {Buffer::AV_PARTIAL, 0, 1};
  av.dst = output.ref;
  av.head = 0;
  av.S = 64;
  c = run(rt, memory, av, 64, done);
  if (!c) { fail(observed, c, 11); return; }
  for (unsigned d = 0; d < 64; ++d) {
    Address address;
    c = full_f32_address(rt, memory, output.ref, 0, 0, 0,
                         uint16_t(d), address);
    if (!c) { fail(observed, c, 12); return; }
    uint8_t raw[4];
    c = full_read(memory, address.bo, address.offset, raw, 4);
    if (!c) { fail(observed, c, 12); return; }
    observed[144 + d] = uint32_t(raw[0]) |
                        uint32_t(raw[1]) << 8 |
                        uint32_t(raw[2]) << 16 |
                        uint32_t(raw[3]) << 24;
  }
  Check partial_publish = full_publish_att(rt, output);
  observed[7] = uint32_t(partial_publish.code);
  observed[8] = partial_publish.detail;
  observed[9] = rt.tasks_retired;
  observed[10] = uint32_t(rt.score_valid);
  observed[0] = 0;
  observed[1] = 0;
  observed[2] = 13;
  observed[3] = rt.last_task_id;
}
