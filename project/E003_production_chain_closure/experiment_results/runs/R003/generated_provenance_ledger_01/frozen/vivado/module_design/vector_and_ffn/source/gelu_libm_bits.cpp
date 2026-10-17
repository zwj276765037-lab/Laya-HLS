#include "gelu_libm_bits.h"
#include "tanh_libm_bits.h"

static bool gelu_finite(uint32_t x) {
#pragma HLS inline
    return (x & 0x7f800000u) != 0x7f800000u;
}
uint32_t gelu_libm_bits(uint32_t x, uint32_t &status, uint32_t steps[9]) {
#pragma HLS inline
    status=1;
    if (!gelu_finite(x)) return 0;
    const uint32_t u=fp_mul_bits(0x3d372713,x); steps[0]=u;
    if (!gelu_finite(u)) return 0;
    const uint32_t v=fp_mul_bits(u,x); steps[1]=v;
    if (!gelu_finite(v)) return 0;
    const uint32_t w=fp_add_bits(0x3f800000,v); steps[2]=w;
    if (!gelu_finite(w)) return 0;
    const uint32_t t=fp_mul_bits(0x3f4c422a,x); steps[3]=t;
    if (!gelu_finite(t)) return 0;
    const uint32_t z=fp_mul_bits(t,w); steps[4]=z;
    if (!gelu_finite(z)) return 0;
    const uint32_t h=tanh_libm_bits(z); steps[5]=h;
    if (!gelu_finite(h)) return 0;
    const uint32_t r=fp_add_bits(0x3f800000,h); steps[6]=r;
    if (!gelu_finite(r)) return 0;
    const uint32_t s=fp_mul_bits(0x3f000000,x); steps[7]=s;
    if (!gelu_finite(s)) return 0;
    const uint32_t y=fp_mul_bits(s,r); steps[8]=y;
    if (!gelu_finite(y)) return 0;
    status=0;
    return y;
}
void geglu_libm_leaf(uint32_t x, uint32_t g, uint32_t &result,
                     uint32_t &status, uint32_t steps[10]) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=x
#pragma HLS interface ap_none port=g
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS interface ap_memory port=steps
#pragma HLS allocation function instances=fp_add_bits limit=1
#pragma HLS allocation function instances=fp_mul_bits limit=1
#pragma HLS allocation function instances=fp_div_bits limit=1
    result=0; status=1;
    if (!gelu_finite(g)) return;
    uint32_t y=gelu_libm_bits(x,status,steps);
    if (status) return;
    uint32_t gate=fp_mul_bits(y,g); steps[9]=gate;
    if (!gelu_finite(gate)) { status=1; return; }
    result=gate;
}
