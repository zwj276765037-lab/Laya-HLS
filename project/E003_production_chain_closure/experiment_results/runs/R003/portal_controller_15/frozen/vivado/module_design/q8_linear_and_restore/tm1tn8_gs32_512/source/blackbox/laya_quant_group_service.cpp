#include "laya_quant_group_service.h"
#include "laya_numeric.h"
#include <cmath>

void laya_quant_group_service(
  uint64_t owner0,
  uint64_t owner1,
  uint64_t owner2,
  uint64_t owner3,
  uint64_t owner4,
  uint64_t owner5,
  uint64_t owner6,
  uint64_t owner7,
  uint64_t owner8,
  uint64_t owner9,
  uint64_t owner10,
  uint64_t owner11,
  uint64_t owner12,
  uint64_t owner13,
  uint64_t x0,
  uint64_t x1,
  uint64_t x2,
  uint64_t x3,
  uint64_t x4,
  uint64_t x5,
  uint64_t x6,
  uint64_t x7,
  uint64_t x8,
  uint64_t x9,
  uint64_t x10,
  uint64_t x11,
  uint64_t x12,
  uint64_t x13,
  uint64_t x14,
  uint64_t x15,
  uint32_t row,
  uint64_t &echo0,
  uint64_t &echo1,
  uint64_t &echo2,
  uint64_t &echo3,
  uint64_t &echo4,
  uint64_t &echo5,
  uint64_t &echo6,
  uint64_t &echo7,
  uint64_t &echo8,
  uint64_t &echo9,
  uint64_t &echo10,
  uint64_t &echo11,
  uint64_t &echo12,
  uint64_t &echo13,
  uint64_t &q0,
  uint64_t &q1,
  uint64_t &q2,
  uint64_t &q3,
  uint32_t &scale,
  uint32_t &d_full,
  uint32_t &reciprocal,
  uint32_t &status,
  uint32_t &bad_col) {
#pragma HLS inline off
  echo0=owner0;echo1=owner1;echo2=owner2;echo3=owner3;echo4=owner4;echo5=owner5;echo6=owner6;echo7=owner7;echo8=owner8;echo9=owner9;echo10=owner10;echo11=owner11;echo12=owner12;echo13=owner13;
  q0=q1=q2=q3=0; scale=d_full=reciprocal=status=0; bad_col=UINT32_MAX;
  const uint64_t packed[16] = {x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15};
  float values[32], amax=0;
  for (unsigned i=0;i<32;++i) {
    values[i]=laya::numeric_bits_f32(uint32_t(packed[i/2] >> (32*(i%2))));
    if ((laya::numeric_f32_bits(values[i]) & 0x7f800000u)==0x7f800000u) {
      status=1;bad_col=i;return;
    }
    if (::fabsf(values[i])>amax) amax=::fabsf(values[i]);
  }
  const float d=amax/127.0f;
  const float r=d==0.0f ? 0.0f : 1.0f/d;
  d_full=laya::numeric_f32_bits(d);reciprocal=laya::numeric_f32_bits(r);
  scale=laya::numeric_f32_to_half_rne(d);
  if ((d_full&0x7f800000u)==0x7f800000u ||
      (reciprocal&0x7f800000u)==0x7f800000u || (scale&0x7c00u)==0x7c00u) {
    status=1;bad_col=0;return;
  }
  uint64_t packed_q[4]={};
  for (unsigned i=0;i<32;++i) {
    const float product=d==0.0f ? 0.0f : values[i]*r;
    const float rounded=::roundf(product);
    if ((laya::numeric_f32_bits(product)&0x7f800000u)==0x7f800000u ||
        (laya::numeric_f32_bits(rounded)&0x7f800000u)==0x7f800000u ||
        rounded < -127.0f || rounded > 127.0f) {status=1;bad_col=i;return;}
    packed_q[i/8] |= uint64_t(uint8_t(int8_t(rounded))) << (8*(i%8));
  }
  q0=packed_q[0];q1=packed_q[1];q2=packed_q[2];q3=packed_q[3];
}
