#include "geglu_libm_stream_bits.h"
#include "tanh_libm_stream_bits.cpp"
static bool geglu_stream_finite(uint32_t x) {
#pragma HLS inline
 return (x&0x7f800000u)!=0x7f800000u;
}
void geglu_libm_stream_leaf(uint32_t x,uint32_t g,uint32_t &result,
                            uint32_t &status,GeGluStreamTrace &trace) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=x
#pragma HLS interface ap_none port=g
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS interface ap_vld port=trace
#pragma HLS aggregate variable=trace compact=bit
#pragma HLS pipeline II=1
 // External 7M/2A positions are charged to the public vector pool.
 // Earlier numerical failures predicate all later values with safe operands.
 bool vg=geglu_stream_finite(g),vx=geglu_stream_finite(x),p0=vg&&vx;
 uint32_t u=stream_mul_node<100>(0x3d372713,p0?x:0);
 bool p1=p0&&geglu_stream_finite(u);
 uint32_t v=stream_mul_node<101>(p1?u:0,p1?x:0);
 bool p2=p1&&geglu_stream_finite(v);
 uint32_t w=stream_add_node<100>(0x3f800000,p2?v:0);
 bool p3=p2&&geglu_stream_finite(w);
 uint32_t t=stream_mul_node<102>(0x3f4c422a,p3?x:0);
 bool p4=p3&&geglu_stream_finite(t);
 uint32_t z=stream_mul_node<103>(p4?t:0,p4?w:0);
 bool p5=p4&&geglu_stream_finite(z);
 uint32_t h=stream_graph(p5?z:0);
 bool p6=p5&&geglu_stream_finite(h);
 uint32_t r=stream_add_node<101>(0x3f800000,p6?h:0);
 bool p7=p6&&geglu_stream_finite(r);
 uint32_t s=stream_mul_node<104>(0x3f000000,p7?x:0);
 bool p8=p7&&geglu_stream_finite(s);
 uint32_t y=stream_mul_node<105>(p8?s:0,p8?r:0);
 bool p9=p8&&geglu_stream_finite(y);
 uint32_t gate=stream_mul_node<106>(p9?y:0,p9?g:0);
 bool success=p9&&geglu_stream_finite(gate);
 uint32_t failed=0xffffffffu;
 if(!vg) failed=10; else if(!vx) failed=11;
 else if(!p1) failed=0; else if(!p2) failed=1;
 else if(!p3) failed=2; else if(!p4) failed=3;
 else if(!p5) failed=4; else if(!p6) failed=5;
 else if(!p7) failed=6; else if(!p8) failed=7;
 else if(!p9) failed=8; else if(!success) failed=9;
 trace={u,v,w,t,z,h,r,s,y,gate,
   uint32_t(p0)|uint32_t(p1)<<1|uint32_t(p2)<<2|uint32_t(p3)<<3|
   uint32_t(p4)<<4|uint32_t(p5)<<5|uint32_t(p6)<<6|uint32_t(p7)<<7|
   uint32_t(p8)<<8|uint32_t(p9)<<9,failed};
 status=success?0:1;
 result=success?gate:0;
}
