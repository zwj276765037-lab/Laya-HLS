#include "full_kernel_wrapper.h"
#include "laya_full_cache_storage.h"
#include "laya_forward_full.h"

namespace {
static laya::full::FullRuntime runtime;
}

#ifndef __SYNTHESIS__
laya::full::FullRuntime& full_kernel_csim_runtime() { return runtime; }
#endif

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
extern "C" void laya_typed_q8_forward(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out) {
#ifdef __SYNTHESIS__
  using laya::full::g_full_cache_weight_q;
  using laya::full::g_full_cache_weight_scale;
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff0 offset=slave bundle=ff0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff1 offset=slave bundle=ff1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
// Bind the actual persistent Q8 matrix cache, rather than an interface copy.
// The synthesis report determines whether these map to URAM and at what cost.
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_q type=ram_1p impl=uram
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_scale type=ram_1p impl=uram
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_q cyclic factor=8 dim=1
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_scale cyclic factor=4 dim=1
#endif
  (void)laya::full::full_forward_ports(
      runtime, embedding, io, w_q0, w_q1, w_scale, aux,
      state0, state1, qkv0, qkv1, ff0, ff1, att_out);
}
#endif

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
extern "C" void laya_typed_q8_forward_controller(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out,
    hls::stream<ap_uint<512>>& compute_cmd,
    hls::stream<ap_uint<512>>& compute_rsp,
    hls::stream<ap_uint<512>>& provenance_cmd,
    hls::stream<ap_uint<512>>& provenance_rsp) {
#ifdef __SYNTHESIS__
  using laya::full::g_full_cache_weight_q;
  using laya::full::g_full_cache_weight_scale;
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff0 offset=slave bundle=ff0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff1 offset=slave bundle=ff1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE ap_fifo port=compute_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=compute_rsp depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_rsp depth=2
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_q type=ram_1p impl=uram
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_scale type=ram_1p impl=uram
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_q cyclic factor=8 dim=1
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_scale cyclic factor=4 dim=1
#endif
  (void)laya::full::full_forward_ports_portal(
      runtime, embedding, io, w_q0, w_q1, w_scale, aux,
      state0, state1, qkv0, qkv1, ff0, ff1, att_out,
      compute_cmd, compute_rsp, provenance_cmd, provenance_rsp);
}
#endif

#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
extern "C" void laya_typed_q8_forward_graph_sequencer(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out,
    hls::stream<ap_uint<512>>& transaction_request,
    hls::stream<ap_uint<512>>& transaction_completion) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff0 offset=slave bundle=ff0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff1 offset=slave bundle=ff1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE ap_fifo port=transaction_request depth=2
#pragma HLS INTERFACE ap_fifo port=transaction_completion depth=2
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  (void)laya::full::full_forward_ports_graph_sequencer(
      runtime, embedding, io, w_q0, w_q1, w_scale, aux,
      state0, state1, qkv0, qkv1, ff0, ff1, att_out,
      transaction_request, transaction_completion);
}
#else
extern "C" void laya_typed_q8_forward_controller_partitioned(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out,
    hls::stream<ap_uint<512>>& compute_cmd,
    hls::stream<ap_uint<512>>& compute_rsp,
    hls::stream<ap_uint<512>>& provenance_cmd,
    hls::stream<ap_uint<512>>& provenance_rsp,
    hls::stream<ap_uint<512>>& producer_request,
    hls::stream<ap_uint<512>>& producer_completion) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff0 offset=slave bundle=ff0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff1 offset=slave bundle=ff1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE ap_fifo port=compute_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=compute_rsp depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_rsp depth=2
#pragma HLS INTERFACE ap_fifo port=producer_request depth=2
#pragma HLS INTERFACE ap_fifo port=producer_completion depth=2
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  (void)laya::full::full_forward_ports_partitioned(
      runtime, embedding, io, w_q0, w_q1, w_scale, aux,
      state0, state1, qkv0, qkv1, ff0, ff1, att_out,
      compute_cmd, compute_rsp, provenance_cmd, provenance_rsp,
      producer_request, producer_completion);
}
#endif
#endif
