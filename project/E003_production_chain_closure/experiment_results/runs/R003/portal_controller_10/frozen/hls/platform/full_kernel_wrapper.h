#pragma once

#include "laya_full_runtime.h"
#include "laya_compute_portal_hls.h"

extern "C" void laya_typed_q8_forward(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out);

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
// Internal generated controller. An RTL shell retains the public
// laya_typed_q8_forward name and original 13-BO/control ABI, and connects
// these two private ap_fifo ports to the persistent compute portal.
extern "C" void laya_typed_q8_forward_controller(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out,
    hls::stream<ap_uint<512>>& compute_cmd,
    hls::stream<ap_uint<512>>& compute_rsp);
#endif

#ifndef __SYNTHESIS__
// CSim-only observation of the static runtime; this is not a kernel port.
laya::full::FullRuntime& full_kernel_csim_runtime();
#endif
