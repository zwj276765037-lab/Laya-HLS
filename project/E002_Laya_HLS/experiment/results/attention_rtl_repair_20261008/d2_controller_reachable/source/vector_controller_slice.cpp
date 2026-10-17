#include "laya_full_runtime.h"

// This is the production translation unit, not a copy of Controller or its
// load/bind/issue methods. The HLS source list must exclude this .cpp itself.
#include "control/full_forward_controller.cpp"

namespace laya::full {
namespace {

static FullRuntime vector_runtime;

Check produce_f32(FullRuntime& rt, FullMemory& memory,
                  const FullOwnerSpec& spec, const uint8_t* input) {
  Check c = full_claim_owner(rt, spec);
  if (!c) return c;
  for (uint16_t row = 0; row < spec.rows; ++row) {
    Address at;
    c = full_f32_address(rt, memory, spec.ref, spec.region, 0,
                         row, 0, at);
    if (c) c = full_write(memory, at.bo, at.offset,
                          input + uint32_t(row) * spec.width * 4u,
                          uint32_t(spec.width) * 4u);
    if (!c) return c;
  }
  c = full_cover_owner(rt, spec, 0, 0, spec.rows);
  return c ? full_publish_owner(rt, spec) : c;
}

void report(uint32_t* observed, const FullRuntime& rt, Check c,
            uint32_t phase, const FullOwnerSpec& output,
            Check cleanup = ok()) {
  observed[0] = uint32_t(c.code);
  observed[1] = c.detail;
  observed[2] = phase;
  observed[3] = rt.last_task_id;
  observed[4] = rt.tasks_retired;
  observed[5] = rt.owner_claims;
  observed[6] = uint32_t(output.ref.id);
  observed[7] = output.ref.bank;
  observed[8] = output.ref.epoch;
  observed[9] = uint32_t(cleanup.code);
  observed[10] = uint32_t(rt.owners.type_valid[0]) |
                 uint32_t(rt.owners.type_valid[1]) << 1 |
                 uint32_t(rt.owners.type_valid[2]) << 2;
  observed[11] = rt.op_calls[uint8_t(Op::ADD_RESIDUAL)];
  observed[12] = rt.op_calls[uint8_t(Op::ADD_TYPE)];
  observed[13] = rt.op_calls[uint8_t(Op::APPLY_CAND_MASK)];
  observed[14] = uint32_t(rt.inputs.identity.request_id);
  observed[15] = uint32_t(rt.inputs.identity.generation);
  FullOwnerRecord record;
  Check snapshot = output.ref.id == Buffer::NONE ?
      Check{Status::E_BUFFER, 0} :
      full_owner_snapshot(rt, output.ref, output.region, record);
  observed[16] = uint32_t(snapshot.code);
  observed[17] = snapshot ? uint32_t(record.state) : 0xffffffffu;
  observed[18] = snapshot ? uint32_t(record.valid) : 0;
}

}  // namespace
}  // namespace laya::full

// mode: 0 residual HIDDEN0, 1 ADD_TYPE, 2 residual without src1,
//       3 unary candidate mask, 4 residual HIDDEN1.
extern "C" void vector_controller_slice(const uint8_t* src0_input,
                                         const uint8_t* src1_input,
                                         uint8_t* io, const uint8_t* aux,
                                         uint8_t* state0, uint8_t* state1,
                                         uint32_t mode,
                                         uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=src0_input offset=slave bundle=src0_input depth=262144 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=src1_input offset=slave bundle=src1_input depth=262144 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io depth=32768 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux depth=1671872 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 depth=16920576 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 depth=16919104 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed depth=32 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=mode bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  using namespace laya;
  using namespace laya::full;
  FullRuntime& rt = vector_runtime;
  FullMemory memory;
  memory.io = io; memory.io_bytes = 32768;
  memory.aux = aux; memory.aux_bytes = 1671872;
  memory.state0 = state0; memory.state0_bytes = 16920576;
  memory.state1 = state1; memory.state1_bytes = 16919104;
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  for (unsigned i = 0; i < 32; ++i) observed[i] = 0xffffffffu;
  FullOwnerSpec output;
  Check c = full_parse_request(rt, memory);
  if (!c) { report(observed, rt, c, 1, output); return; }
  if (rt.inputs.identity.B != 1 || rt.inputs.identity.S != 64 || mode > 4) {
    report(observed, rt, {Status::E_SHAPE, detail(7, 0, 20)},
           1, output);
    return;
  }
  Controller controller{rt, memory};
  FullOwnerSpec src0, src1;
  if (mode == 3) {
    src0 = {controller.fresh(Buffer::HEAD_WORK, 0, uint8_t(Region::CAND_RAW)), uint8_t(Region::CAND_RAW),
            5, 255, 255, RowSpace::MARKER, 0, 16, 1, Content::F32};
  } else if (mode == 1) {
    src0 = {controller.fresh(Buffer::HIDDEN, 0), 0, 3, 255, 255,
            RowSpace::TOKEN, 0, 64, 1024, Content::F32};
    src1 = {controller.fresh(Buffer::TYPE_ROWS, 0), 0, 3, 255, 0,
            RowSpace::BATCH, 0, 3, 1024, Content::F32};
  } else {
    src0 = {controller.fresh(Buffer::TMP, 0), 0, 4, 0, 255,
            RowSpace::TOKEN, 0, 64, 1024, Content::F32};
    src1 = {controller.fresh(Buffer::HIDDEN, uint8_t(mode == 4)), 0, 4, 0, 255,
            RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  }
  c = produce_f32(rt, memory, src0, src0_input);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 2, output, cleanup);
    return;
  }
  if (mode != 2 && mode != 3) {
    c = produce_f32(rt, memory, src1, src1_input);
    if (!c) {
      Check cleanup = controller.invalidate_incomplete();
      report(observed, rt, c, 3, output, cleanup);
      return;
    }
  }
  if (mode == 3)
    c = controller.vector(Op::APPLY_CAND_MASK, src0, 5, 255,
                          controller.fresh(Buffer::HEAD_WORK, 0,
                                           uint8_t(Region::CAND_MASKED)),
                          uint8_t(Region::CAND_MASKED), 16, output);
  else if (mode == 1)
    c = controller.vector(Op::ADD_TYPE, src0, src1, 3, 255,
                          controller.fresh(Buffer::HIDDEN, 1),
                          0, 1024, output);
  else if (mode == 2)
    c = controller.vector(Op::ADD_RESIDUAL, src0, 4, 0,
                          controller.fresh(Buffer::HIDDEN, 1),
                          0, 1024, output);
  else
    c = controller.vector(Op::ADD_RESIDUAL, src0, src1, 4, 0,
                          controller.fresh(Buffer::HIDDEN,
                                           uint8_t(mode == 4 ? 0 : 1)),
                          0, 1024, output);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 4, output, cleanup);
    return;
  }
  report(observed, rt, c, 5, output);
}
