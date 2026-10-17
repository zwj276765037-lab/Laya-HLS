#pragma once

#include "laya_full_runtime.h"

namespace laya::full {

// The CPU and hardware paths use the same ordered 13-port forward entry.
// The caller owns runtime state so successive CPU requests retain epochs and
// request IDs. The hardware wrapper owns one static instance of that state.
Check full_forward_ports(FullRuntime& rt,
                         const uint8_t* embedding, uint8_t* io,
                         const uint8_t* w_q0, const uint8_t* w_q1,
                         const uint8_t* w_scale, const uint8_t* aux,
                         uint8_t* state0, uint8_t* state1,
                         uint8_t* qkv0, uint8_t* qkv1,
                         uint8_t* ff0, uint8_t* ff1,
                         uint8_t* att_out);

} // namespace laya::full
