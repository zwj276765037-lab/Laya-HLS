#pragma once
#include <stdint.h>
uint32_t stream_fp_add_bits(uint32_t a,uint32_t b);
uint32_t stream_fp_mul_bits(uint32_t a,uint32_t b);
uint32_t stream_fp_div_bits(uint32_t a,uint32_t b);
uint32_t tanh_libm_stream_bits(uint32_t x);
void tanh_libm_stream_leaf(uint32_t x,uint32_t &result,uint32_t &status);
