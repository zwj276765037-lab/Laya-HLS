#pragma once
#include <stdint.h>
// Negative finite softmax inputs, binary32 result with gradual underflow.
uint32_t attention_exp_bits(uint32_t x);
uint64_t attention_f64_add(uint64_t a, uint64_t b);
uint64_t attention_f64_mul(uint64_t a, uint64_t b);
void attention_exp_leaf(uint32_t x, uint32_t &result, uint32_t &status);
