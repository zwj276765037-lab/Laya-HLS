#pragma once

// Dormant CPU caller binding. The vendor simulation constructor takes the
// respective backing-memory pointer; it does not model physical B latency.
#include "q8_joint_tm4tn8.h"

inline void call_c1_candidate(const uint32_t* descriptor,
                              const ap_uint<512>* w_q0,
                              const ap_uint<512>* w_q1,
                              const ap_uint<512>* w_scale,
                              const uint32_t* aux,
                              const ap_uint<512>* activation,
                              uint32_t* out0, uint32_t* out1,
                              uint32_t* observed) {
  q8_joint_tm4tn8(descriptor, w_q0, w_q1, w_scale, aux, activation,
                  hls::burst_maxi<uint32_t>(out0),
                  hls::burst_maxi<uint32_t>(out1),
                  hls::burst_maxi<uint32_t>(observed));
}
