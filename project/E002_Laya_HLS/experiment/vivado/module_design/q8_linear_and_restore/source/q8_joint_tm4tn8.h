#pragma once

#include <cstdint>
#include "ap_int.h"

extern "C" void q8_joint_tm4tn8(
    const uint32_t* descriptor,
    const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1,
    const ap_uint<512>* w_scale,
    const uint32_t* aux,
    const ap_uint<512>* activation,
    uint32_t* out0,
    uint32_t* out1,
    uint32_t* observed);
