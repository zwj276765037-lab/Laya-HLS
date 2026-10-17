#pragma once
#include <stdint.h>
struct GeGluStreamTrace {
 uint32_t u,v,w,t,z,h,r,s,y,gate;
 uint32_t mask,failed_step;
};
void geglu_libm_stream_leaf(uint32_t x,uint32_t g,uint32_t &result,
                            uint32_t &status,GeGluStreamTrace &trace);
