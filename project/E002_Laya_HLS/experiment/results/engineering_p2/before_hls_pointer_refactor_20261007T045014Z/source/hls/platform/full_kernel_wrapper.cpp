#include "full_kernel_wrapper.h"
#include "laya_forward_full.h"

namespace {
static laya::full::FullRuntime runtime;
}

#ifndef __SYNTHESIS__
laya::full::FullRuntime& full_kernel_csim_runtime() { return runtime; }
#endif

extern "C" void laya_typed_q8_forward(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out) {
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
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  (void)laya::full::full_forward_ports(
      runtime, embedding, io, w_q0, w_q1, w_scale, aux,
      state0, state1, qkv0, qkv1, ff0, ff1, att_out);
}
