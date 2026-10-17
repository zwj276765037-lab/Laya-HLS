#pragma once

#include "laya_full_runtime.h"

extern "C" void laya_typed_q8_forward(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out);

#ifndef __SYNTHESIS__
// CSim-only observation of the static runtime; this is not a kernel port.
laya::full::FullRuntime& full_kernel_csim_runtime();
#endif
