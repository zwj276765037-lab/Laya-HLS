#pragma once

#include <ap_int.h>
#include <cstdint>

// Fixed B1/S128 row 0..15 microbenchmark. All addresses are BO-relative.
extern "C" void laya_front16_byte(const uint8_t* state0,
                                   const uint8_t* aux, uint8_t* state1,
                                   uint32_t* observed);
extern "C" void laya_front16_wide(const ap_uint<512>* state0,
                                   const ap_uint<512>* aux,
                                   ap_uint<512>* state1, uint32_t* observed);
