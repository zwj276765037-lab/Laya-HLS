#include "laya_forward_full.h"
#include "laya_model_layout_generated.h"

namespace laya::full {

Check full_forward_ports(FullRuntime& rt,
                         const uint8_t* embedding, uint8_t* io,
                         const uint8_t* w_q0, const uint8_t* w_q1,
                         const uint8_t* w_scale, const uint8_t* aux,
                         uint8_t* state0, uint8_t* state1,
                         uint8_t* qkv0, uint8_t* qkv1,
                         uint8_t* ff0, uint8_t* ff1,
                         uint8_t* att_out) {
  // Model capacities come from the generated, compile-time descriptor table.
  // Workspace capacities are the fixed 04§7 physical BO extents, including
  // the final HEAD_WORK and TYPE_ROWS regions.
  rt.memory = FullMemory{};
  rt.memory.embedding = embedding;
  rt.memory.embedding_bytes = kFullModelBoSizes[0];
  rt.memory.io = io;
  rt.memory.io_bytes = kResultOffset + kResultCapacity;
  rt.memory.w_q0 = w_q0;
  rt.memory.w_q0_bytes = kFullModelBoSizes[1];
  rt.memory.w_q1 = w_q1;
  rt.memory.w_q1_bytes = kFullModelBoSizes[2];
  rt.memory.w_scale = w_scale;
  rt.memory.w_scale_bytes = kFullModelBoSizes[3];
  rt.memory.aux = aux;
  rt.memory.aux_bytes = kFullModelBoSizes[4];
  rt.memory.state0 = state0;
  rt.memory.state0_bytes = 16920576u;
  rt.memory.state1 = state1;
  rt.memory.state1_bytes = 16919104u;
  rt.memory.qkv0 = qkv0;
  rt.memory.qkv0_bytes = 12u * 1024u * 1024u;
  rt.memory.qkv1 = qkv1;
  rt.memory.qkv1_bytes = 12u * 1024u * 1024u;
  rt.memory.ff0 = ff0;
  rt.memory.ff0_bytes = 41u * 1024u * 1024u;
  rt.memory.ff1 = ff1;
  rt.memory.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  rt.memory.att_out = att_out;
  rt.memory.att_out_bytes = 8u * 1024u * 1024u;
  return full_execute_request(rt);
}

} // namespace laya::full
