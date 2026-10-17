#pragma once
#include <stdint.h>
// Ordered binary32 GELU graph, with a trace of the nine arithmetic results.
uint32_t gelu_libm_bits(uint32_t x, uint32_t &status, uint32_t steps[9]);
// One U/G element from the full 5248 -> 2624 GEGLU row.
void geglu_libm_leaf(uint32_t x, uint32_t g, uint32_t &result,
                     uint32_t &status, uint32_t steps[10]);
