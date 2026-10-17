#include "laya_full_runtime.h"

// The production Controller is included once in this translation unit. Its
// EMB_TYPE, type_add and vector paths remain unchanged and are not separately
// listed as a synthesis source.
#include "control/full_forward_controller.cpp"

namespace laya::full {
namespace {

static FullRuntime type_runtime;

Check ingest_hidden(FullRuntime& rt, FullMemory& memory,
                    const FullOwnerSpec& owner, const uint8_t* input) {
  Check c = full_claim_owner(rt, owner);
  for (uint16_t row = 0; row < 64 && c; ++row) {
    Address address;
    c = full_f32_address(rt, memory, owner.ref, owner.region,
                         0, row, 0, address);
    if (c) c = full_write(memory, address.bo, address.offset,
                          input + uint32_t(row) * 4096u, 4096u);
  }
  if (c) c = full_cover_owner(rt, owner, 0, 0, 64);
  if (c) c = full_publish_owner(rt, owner);
  return c;
}

void report(uint32_t* words, const FullRuntime& rt, Check result,
            uint32_t phase, const FullOwnerSpec& old_hidden,
            BufferRef type_ref, const FullOwnerSpec& new_hidden,
            Check cleanup = ok()) {
  words[0] = uint32_t(result.code);
  words[1] = result.detail;
  words[2] = phase;
  words[3] = rt.last_task_id;
  words[4] = rt.tasks_retired;
  words[5] = rt.owner_claims;
  words[6] = uint32_t(new_hidden.ref.id);
  words[7] = new_hidden.ref.bank;
  words[8] = new_hidden.ref.epoch;
  words[9] = uint32_t(cleanup.code);
  words[10] = uint32_t(rt.owners.type_valid[0]) |
              uint32_t(rt.owners.type_valid[1]) << 1 |
              uint32_t(rt.owners.type_valid[2]) << 2;
  words[11] = rt.op_calls[uint8_t(Op::EMB_TYPE)];
  words[12] = rt.op_calls[uint8_t(Op::ADD_TYPE)];
  words[13] = rt.inputs.qtype[0];
  words[14] = uint32_t(rt.inputs.identity.request_id);
  words[15] = uint32_t(rt.inputs.identity.generation);

  FullOwnerRecord output{};
  Check snapshot = new_hidden.ref.id == Buffer::NONE ?
      Check{Status::E_BUFFER, 0} :
      full_owner_snapshot(rt, new_hidden.ref, new_hidden.region, output);
  words[16] = uint32_t(snapshot.code);
  words[17] = snapshot ? uint32_t(output.state) : 0xffffffffu;
  words[18] = snapshot ? uint32_t(output.valid) : 0xffffffffu;
  words[19] = snapshot ? output.covered_rows[0] : 0xffffffffu;
  words[20] = snapshot ? output.covered_rows[1] : 0xffffffffu;

  FullOwnerRecord type{};
  snapshot = type_ref.id == Buffer::NONE ? Check{Status::E_BUFFER, 0} :
             full_owner_snapshot(rt, type_ref, 0, type);
  words[21] = uint32_t(snapshot.code);
  words[22] = snapshot ? uint32_t(type.state) : 0xffffffffu;
  words[23] = snapshot ? uint32_t(type.valid) : 0xffffffffu;
  words[24] = snapshot ? type.covered_rows[0] : 0xffffffffu;

  FullOwnerRecord input{};
  snapshot = old_hidden.ref.id == Buffer::NONE ? Check{Status::E_BUFFER, 0} :
             full_owner_snapshot(rt, old_hidden.ref, old_hidden.region, input);
  words[25] = uint32_t(snapshot.code);
  words[26] = snapshot ? uint32_t(input.state) : 0xffffffffu;
  words[27] = snapshot ? uint32_t(input.valid) : 0xffffffffu;
  words[28] = snapshot ? input.covered_rows[0] : 0xffffffffu;
  words[29] = uint32_t(old_hidden.ref.id);
  words[30] = old_hidden.ref.bank;
  words[31] = old_hidden.ref.epoch;
}

} // namespace
} // namespace laya::full

extern "C" void type_producer_binary_slice(const uint8_t* hidden_input,
                                            const uint8_t* embedding,
                                            uint8_t* io,
                                            const uint8_t* aux,
                                            uint8_t* state0,
                                            uint8_t* state1,
                                            uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=hidden_input offset=slave bundle=hidden_input depth=262144 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding depth=54803648 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io depth=32768 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux depth=1671872 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 depth=16920576 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 depth=16919104 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed depth=32 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  using namespace laya;
  using namespace laya::full;
  FullRuntime& rt = type_runtime;
  FullMemory memory;
  memory.embedding = embedding; memory.embedding_bytes = 54803648u;
  memory.io = io; memory.io_bytes = 32768u;
  memory.aux = aux; memory.aux_bytes = 1671872u;
  memory.state0 = state0; memory.state0_bytes = 16920576u;
  memory.state1 = state1; memory.state1_bytes = 16919104u;
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  for (unsigned i = 0; i < 32; ++i) observed[i] = 0xffffffffu;
  FullOwnerSpec empty{}, ingress{};
  Check c = full_parse_request(rt, memory);
  if (!c) { report(observed, rt, c, 1, empty, none(), empty); return; }
  if (rt.inputs.identity.B != 1 || rt.inputs.identity.S != 64) {
    report(observed, rt, {Status::E_SHAPE, detail(7, 0, 20)},
           1, empty, none(), empty);
    return;
  }
  Controller controller{rt, memory};
  ingress = {controller.fresh(Buffer::HIDDEN, 0), 0, 3, 255, 255,
             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  c = ingest_hidden(rt, memory, ingress, hidden_input);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 2, ingress, none(), empty, cleanup);
    return;
  }
  const BufferRef type_ref = controller.fresh(Buffer::TYPE_ROWS);
  FullOwnerSpec hidden = ingress;
  c = controller.type_add(hidden);
  if (!c) {
    Check cleanup = controller.invalidate_incomplete();
    report(observed, rt, c, 3, ingress, type_ref, hidden, cleanup);
    return;
  }
  report(observed, rt, c, 5, ingress, type_ref, hidden);
}
