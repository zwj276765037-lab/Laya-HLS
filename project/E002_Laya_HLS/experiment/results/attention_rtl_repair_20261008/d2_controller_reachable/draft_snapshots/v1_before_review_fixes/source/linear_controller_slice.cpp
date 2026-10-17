#include "laya_full_runtime.h"

// Compile the current production Controller in this same translation unit.
// The source list excludes its standalone object to avoid duplicate symbols.
#include "control/full_forward_controller.cpp"

namespace laya::full {
namespace {

static FullRuntime linear_runtime;

void report(uint32_t* observed, const FullRuntime& rt, Check c,
            uint32_t phase, const FullOwnerSpec& output,
            const FullOwnerSpec (&pair)[2],
            Check cleanup = ok()) {
  observed[0] = uint32_t(c.code);
  observed[1] = c.detail;
  observed[2] = phase;
  observed[3] = rt.last_task_id;
  observed[4] = rt.tasks_retired;
  observed[5] = rt.op_calls[uint8_t(Op::LOAD_W)];
  observed[6] = rt.op_calls[uint8_t(Op::QUANT)];
  observed[7] = rt.op_calls[uint8_t(Op::LIN_QKV)];
  observed[8] = rt.owner_claims;
  observed[9] = uint32_t(cleanup.code);
  observed[10] = uint32_t(rt.final_qkv_ref[0].id);
  observed[11] = rt.final_qkv_ref[0].epoch;
  observed[12] = uint32_t(rt.final_qkv_ref[1].id);
  observed[13] = rt.final_qkv_ref[1].epoch;
  observed[14] = uint32_t(rt.inputs.identity.request_id);
  observed[15] = uint32_t(rt.inputs.identity.generation);
  for (unsigned shard = 0; shard < 2; ++shard) {
    FullOwnerRecord record;
    Check snapshot = pair[shard].ref.id == Buffer::NONE ?
        Check{Status::E_BUFFER, 0} :
        full_owner_snapshot(rt, pair[shard].ref, pair[shard].region,
                            record);
    observed[16 + shard * 5] = uint32_t(pair[shard].ref.id);
    observed[17 + shard * 5] = pair[shard].ref.bank;
    observed[18 + shard * 5] = pair[shard].ref.epoch;
    observed[19 + shard * 5] = uint32_t(snapshot.code);
    observed[20 + shard * 5] = snapshot ? uint32_t(record.state) :
                                 0xffffffffu;
  }
  observed[26] = output.width;
  observed[27] = uint32_t(output.content);
  observed[28] = uint32_t(pair[0].content);
  observed[29] = uint32_t(pair[1].content);
  observed[30] = pair[0].rows;
  observed[31] = pair[1].rows;
}

}  // namespace
}  // namespace laya::full

extern "C" void linear_controller_slice(const uint8_t* norm_input,
                                         uint8_t* io,
                                         const uint8_t* w_q0,
                                         const uint8_t* w_q1,
                                         const uint8_t* w_scale,
                                         const uint8_t* aux,
                                         uint8_t* state0,
                                         uint8_t* qkv0,
                                         uint8_t* qkv1,
                                         uint32_t pair_present,
                                         uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=norm_input offset=slave bundle=norm_input depth=262144 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io depth=32768 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 depth=184682496 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 depth=184680448 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale depth=23085184 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux depth=1671872 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 depth=16920576 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 depth=12582912 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 depth=12582912 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed depth=32 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=pair_present bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  using namespace laya;
  using namespace laya::full;
  FullRuntime& rt = linear_runtime;
  FullMemory memory;
  memory.io = io; memory.io_bytes = 32768;
  memory.w_q0 = w_q0; memory.w_q0_bytes = 184682496;
  memory.w_q1 = w_q1; memory.w_q1_bytes = 184680448;
  memory.w_scale = w_scale; memory.w_scale_bytes = 23085184;
  memory.aux = aux; memory.aux_bytes = 1671872;
  memory.state0 = state0; memory.state0_bytes = 16920576;
  memory.qkv0 = qkv0; memory.qkv0_bytes = 12u << 20;
  memory.qkv1 = qkv1; memory.qkv1_bytes = 12u << 20;
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  for (unsigned i = 0; i < 32; ++i) observed[i] = 0xffffffffu;
  FullOwnerSpec output, pair[2];
  Check c = full_parse_request(rt, memory);
  if (!c) { report(observed, rt, c, 1, output, pair); return; }
  if (rt.inputs.identity.B != 1 || rt.inputs.identity.S != 64 ||
      pair_present > 1) {
    report(observed, rt, {Status::E_SHAPE, detail(7, 0, 20)},
           1, output, pair);
    return;
  }
  Controller controller{rt, memory};
  const FullOwnerSpec source{{Buffer::NORM, 0, 1}, 0, 4, 0, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  c = full_claim_owner(rt, source);
  if (!c) { report(observed, rt, c, 2, output, pair); return; }
  for (uint16_t row = 0; row < 64; ++row) {
    Address at;
    c = full_f32_address(rt, memory, source.ref, 0, 0, row, 0, at);
    if (c) c = full_write(memory, at.bo, at.offset,
                          norm_input + uint32_t(row) * 4096u, 4096);
    if (!c) break;
  }
  if (c) c = full_cover_owner(rt, source, 0, 0, 64);
  if (c) c = full_publish_owner(rt, source);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 3, output, pair, cleanup);
    return;
  }
  if (pair_present)
    c = controller.linear(Op::LIN_QKV, {5, 0}, source, 4, 0,
                          controller.fresh(Buffer::QKV, 0), 0,
                          output, pair);
  else
    c = controller.linear(Op::LIN_QKV, {5, 0}, source, 4, 0,
                          controller.fresh(Buffer::QKV, 0), 0,
                          output);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 4, output, pair, cleanup);
    return;
  }
  report(observed, rt, c, 5, output, pair);
}
