#include "laya_forward_full.h"
#include "laya_model_layout_generated.h"

namespace laya::full {

namespace {
FullMemory bind_full_memory(const uint8_t* embedding, uint8_t* io,
                            const uint8_t* w_q0, const uint8_t* w_q1,
                            const uint8_t* w_scale, const uint8_t* aux,
                            uint8_t* state0, uint8_t* state1,
                            uint8_t* qkv0, uint8_t* qkv1,
                            uint8_t* ff0, uint8_t* ff1,
                            uint8_t* att_out) {
  FullMemory memory{};
  memory.embedding = embedding;
  memory.embedding_bytes = kFullModelBoSizes[0];
  memory.io = io;
  memory.io_bytes = kResultOffset + kResultCapacity;
  memory.w_q0 = w_q0;
  memory.w_q0_bytes = kFullModelBoSizes[1];
  memory.w_q1 = w_q1;
  memory.w_q1_bytes = kFullModelBoSizes[2];
  memory.w_scale = w_scale;
  memory.w_scale_bytes = kFullModelBoSizes[3];
  memory.aux = aux;
  memory.aux_bytes = kFullModelBoSizes[4];
  memory.state0 = state0;
  memory.state0_bytes = 16920576u;
  memory.state1 = state1;
  memory.state1_bytes = 16919104u;
  memory.qkv0 = qkv0;
  memory.qkv0_bytes = 12u * 1024u * 1024u;
  memory.qkv1 = qkv1;
  memory.qkv1_bytes = 12u * 1024u * 1024u;
  memory.ff0 = ff0;
  memory.ff0_bytes = 41u * 1024u * 1024u;
  memory.ff1 = ff1;
  memory.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  memory.att_out = att_out;
  memory.att_out_bytes = 8u * 1024u * 1024u;
  return memory;
}
} // namespace

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_forward_ports(FullRuntime& rt,
                         const uint8_t* embedding, uint8_t* io,
                         const uint8_t* w_q0, const uint8_t* w_q1,
                         const uint8_t* w_scale, const uint8_t* aux,
                         uint8_t* state0, uint8_t* state1,
                         uint8_t* qkv0, uint8_t* qkv1,
                         uint8_t* ff0, uint8_t* ff1,
                         uint8_t* att_out) {
  // Model capacities come from the generated descriptor table. Workspace
  // capacities remain the fixed 04§7 physical BO extents.
  FullMemory memory = bind_full_memory(embedding, io, w_q0, w_q1, w_scale,
      aux, state0, state1, qkv0, qkv1, ff0, ff1, att_out);
#ifndef __SYNTHESIS__
  rt.memory = memory; // Host-only observer compatibility.
#endif
  return full_execute_request(rt, memory);
}
#endif

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_forward_ports_portal(FullRuntime& rt,
                         const uint8_t* embedding, uint8_t* io,
                         const uint8_t* w_q0, const uint8_t* w_q1,
                         const uint8_t* w_scale, const uint8_t* aux,
                         uint8_t* state0, uint8_t* state1,
                         uint8_t* qkv0, uint8_t* qkv1,
                         uint8_t* ff0, uint8_t* ff1,
                         uint8_t* att_out,
                         hls::stream<ap_uint<512>>& compute_cmd,
                         hls::stream<ap_uint<512>>& compute_rsp,
                         hls::stream<ap_uint<512>>& provenance_cmd,
                         hls::stream<ap_uint<512>>& provenance_rsp) {
  FullMemory memory = bind_full_memory(embedding, io, w_q0, w_q1, w_scale,
      aux, state0, state1, qkv0, qkv1, ff0, ff1, att_out);
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  return full_execute_request_portal(rt, memory, compute_cmd, compute_rsp,
                                     provenance_cmd, provenance_rsp);
}
#endif

Check full_forward_ports_partitioned(FullRuntime& rt,
                         const uint8_t* embedding, uint8_t* io,
                         const uint8_t* w_q0, const uint8_t* w_q1,
                         const uint8_t* w_scale, const uint8_t* aux,
                         uint8_t* state0, uint8_t* state1,
                         uint8_t* qkv0, uint8_t* qkv1,
                         uint8_t* ff0, uint8_t* ff1,
                         uint8_t* att_out,
                         hls::stream<ap_uint<512>>& compute_cmd,
                         hls::stream<ap_uint<512>>& compute_rsp,
                         hls::stream<ap_uint<512>>& provenance_cmd,
                         hls::stream<ap_uint<512>>& provenance_rsp,
                         hls::stream<ap_uint<512>>& producer_request,
                         hls::stream<ap_uint<512>>& producer_completion) {
  FullMemory memory = bind_full_memory(embedding, io, w_q0, w_q1, w_scale,
      aux, state0, state1, qkv0, qkv1, ff0, ff1, att_out);
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  return full_execute_request_partitioned(
      rt, memory, compute_cmd, compute_rsp, provenance_cmd, provenance_rsp,
      producer_request, producer_completion);
}
#endif

} // namespace laya::full
