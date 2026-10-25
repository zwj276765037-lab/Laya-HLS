// expf graph/table adapted from glibc 2.39 e_expf.c/e_exp2f_data.c.
// Copyright (C) 2017-2024 Free Software Foundation, Inc.
// This adaptation is distributed under GNU LGPL 2.1 or later.
// https://github.com/bminor/glibc/tree/release/2.39/master/sysdeps/ieee754/flt-32
// Each operation below implements a separate binary64 RNE operation. The
// original independent oracle remains the host libm expf, not this source.
#include "attention_exp_bits.h"

static uint64_t jam64(uint64_t x, unsigned n) {
#pragma HLS inline
  if (!n) return x;
  if (n >= 64) return x != 0;
  return (x >> n) | ((x << (64-n)) != 0);
}
static unsigned clz64(uint64_t x) {
#pragma HLS inline
  unsigned n=0;
  if (!(x & 0xffffffff00000000ull)) { x <<= 32; n += 32; }
  if (!(x & 0xffff000000000000ull)) { x <<= 16; n += 16; }
  if (!(x & 0xff00000000000000ull)) { x <<= 8; n += 8; }
  if (!(x & 0xf000000000000000ull)) { x <<= 4; n += 4; }
  if (!(x & 0xc000000000000000ull)) { x <<= 2; n += 2; }
  if (!(x & 0x8000000000000000ull)) ++n;
  return n;
}
static void unpack64(uint64_t x, int &e, uint64_t &m) {
#pragma HLS inline
  unsigned f=unsigned((x>>52)&2047);
  m=x&0xfffffffffffffull;
  e=f ? int(f)-1023 : -1022;
  if (f) m |= 0x10000000000000ull;
  else if (m) { unsigned n=clz64(m)-11; m <<= n; e-=int(n); }
}
static uint64_t pack64(uint64_t s, int e, uint64_t m) {
#pragma HLS inline
  if (!m) return s;
  if (m & 0x100000000000000ull) { m=jam64(m,1); ++e; }
  else { unsigned n=clz64(m)-8; m <<= n; e-=int(n); }
  if (e < -1022) { m=jam64(m,unsigned(-1022-e)); e=-1022; }
  uint64_t f=m>>3;
  unsigned t=unsigned(m&7);
  if (t>4 || (t==4 && (f&1))) ++f;
  if (f >= 0x20000000000000ull) { f >>= 1; ++e; }
  if (e>1023) return s|0x7ff0000000000000ull;
  if (f<0x10000000000000ull) return s|f;
  return s|(uint64_t(e+1023)<<52)|(f&0xfffffffffffffull);
}
uint64_t attention_f64_add(uint64_t a, uint64_t b) {
#pragma HLS inline off
  uint64_t sa=a&0x8000000000000000ull, sb=b&0x8000000000000000ull;
  uint64_t aa=a&0x7fffffffffffffffull, ab=b&0x7fffffffffffffffull;
  if (aa>=0x7ff0000000000000ull || ab>=0x7ff0000000000000ull) {
    if (aa>0x7ff0000000000000ull) return a|0x8000000000000ull;
    if (ab>0x7ff0000000000000ull) return b|0x8000000000000ull;
    if (aa==ab && sa!=sb) return 0x7ff8000000000000ull;
    return aa==0x7ff0000000000000ull ? a:b;
  }
  if (!aa && !ab) return sa&sb;
  if (!aa) return b;
  if (!ab) return a;
  int ea,eb; uint64_t ma,mb;
  unpack64(a,ea,ma); unpack64(b,eb,mb);
  if (ea<eb || (ea==eb && ma<mb)) {
    int et=ea; ea=eb; eb=et;
    uint64_t mt=ma; ma=mb; mb=mt;
    uint64_t st=sa; sa=sb; sb=st;
  }
  uint64_t lhs=ma<<3, rhs=jam64(mb<<3,unsigned(ea-eb));
  if (sa!=sb && lhs==rhs) return 0;
  return pack64(sa,ea,sa==sb ? lhs+rhs:lhs-rhs);
}
uint64_t attention_f64_mul(uint64_t a, uint64_t b) {
#pragma HLS inline off
  uint64_t s=(a^b)&0x8000000000000000ull;
  uint64_t aa=a&0x7fffffffffffffffull, ab=b&0x7fffffffffffffffull;
  if (aa>0x7ff0000000000000ull) return a|0x8000000000000ull;
  if (ab>0x7ff0000000000000ull) return b|0x8000000000000ull;
  if (aa==0x7ff0000000000000ull || ab==0x7ff0000000000000ull)
    return (!aa||!ab) ? 0x7ff8000000000000ull:s|0x7ff0000000000000ull;
  if (!aa||!ab) return s;
  int ea,eb; uint64_t ma,mb;
  unpack64(a,ea,ma); unpack64(b,eb,mb);
  // 53x53 product, built with bounded native integer words (no host FP).
  uint64_t a0=uint32_t(ma), a1=ma>>32, b0=uint32_t(mb), b1=mb>>32;
  uint64_t p0=a0*b0, p1=a0*b1, p2=a1*b0, p3=a1*b1;
  uint64_t middle=(p0>>32)+uint32_t(p1)+uint32_t(p2);
  uint64_t lo=(middle<<32)|uint32_t(p0);
  uint64_t hi=p3+(p1>>32)+(p2>>32)+(middle>>32);
  bool carry=(hi&0x20000000000ull)!=0; // full product bit105
  unsigned shift=carry ? 50:49;
  uint64_t m=(hi<<(64-shift))|(lo>>shift);
  if ((lo<< (64-shift))!=0) m|=1;
  return pack64(s,ea+eb+(carry?1:0),m);
}
static uint64_t widen32(uint32_t x) {
#pragma HLS inline
  uint32_t m=x&0x7fffff; int e=int((x>>23)&255)-127;
  if (!(x&0x7fffffff)) return uint64_t(x&0x80000000u)<<32;
  if (((x>>23)&255)==0) {
    e=-126;
    for (unsigned i=0;i<23;++i) {
#pragma HLS unroll
      if (m<0x800000) { m<<=1; --e; }
    }
  }
  return (uint64_t(x&0x80000000u)<<32)|(uint64_t(e+1023)<<52)|
         (uint64_t(m&0x7fffff)<<29);
}
static uint32_t narrow32(uint64_t x) {
#pragma HLS inline
  uint32_t s=uint32_t(x>>32)&0x80000000u;
  if (!(x&0x7fffffffffffffffull)) return s;
  int e; uint64_t m; unpack64(x,e,m);
  m=jam64(m,26); // 24 significant bits + 3 RNE bits
  if (e < -126) { m=jam64(m,unsigned(-126-e)); e=-126; }
  uint32_t f=uint32_t(m>>3); unsigned t=unsigned(m&7);
  if (t>4 || (t==4&&(f&1))) ++f;
  if (f>=0x1000000) { f>>=1; ++e; }
  if (e>127) return s|0x7f800000;
  if (f<0x800000) return s|f;
  return s|(uint32_t(e+127)<<23)|(f&0x7fffff);
}
uint32_t attention_exp_bits(uint32_t x) {
#pragma HLS inline off
  static const uint64_t table[32]={
    0x3ff0000000000000ull,0x3fefd9b0d3158574ull,0x3fefb5586cf9890full,0x3fef9301d0125b51ull,
    0x3fef72b83c7d517bull,0x3fef54873168b9aaull,0x3fef387a6e756238ull,0x3fef1e9df51fdee1ull,
    0x3fef06fe0a31b715ull,0x3feef1a7373aa9cbull,0x3feedea64c123422ull,0x3feece086061892dull,
    0x3feebfdad5362a27ull,0x3feeb42b569d4f82ull,0x3feeab07dd485429ull,0x3feea47eb03a5585ull,
    0x3feea09e667f3bcdull,0x3fee9f75e8ec5f74ull,0x3feea11473eb0187ull,0x3feea589994cce13ull,
    0x3feeace5422aa0dbull,0x3feeb737b0cdc5e5ull,0x3feec49182a3f090ull,0x3feed503b23e255dull,
    0x3feee89f995ad3adull,0x3feeff76f2fb5e47ull,0x3fef199bdd85529cull,0x3fef3720dcef9069ull,
    0x3fef5818dcfba487ull,0x3fef7c97337b9b5full,0x3fefa4afa2a490daull,0x3fefd0765b6e4540ull};
  // This service's declared input domain is finite x<=0 from score-maximum.
  // Values below glibc's log(2^-150) threshold round to zero under RNE.
  if ((x&0x7fffffff)>0x42cff1b4u) return 0;
  uint64_t xd=widen32(x);
  uint64_t z=attention_f64_mul(0x40471547652b82feull,xd);
  uint64_t kd=attention_f64_add(z,0x4338000000000000ull);
  uint64_t ki=kd;
  kd=attention_f64_add(kd,0xc338000000000000ull);
  uint64_t r=attention_f64_add(z,kd^0x8000000000000000ull);
  uint64_t s=table[ki&31]+(ki<<47);
  z=attention_f64_add(attention_f64_mul(0x3ebc6af84b912394ull,r),0x3f2ebfce50fac4f3ull);
  uint64_t r2=attention_f64_mul(r,r);
  uint64_t y=attention_f64_add(attention_f64_mul(0x3f962e42ff0c52d6ull,r),0x3ff0000000000000ull);
  y=attention_f64_add(attention_f64_mul(z,r2),y);
  return narrow32(attention_f64_mul(y,s));
}
void attention_exp_leaf(uint32_t x, uint32_t &result, uint32_t &status) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=x
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS pipeline II=1
  status=((x&0x7f800000u)==0x7f800000u || (!(x>>31)&&(x&0x7fffffff))) ? 1:0;
  result=status ? 0:attention_exp_bits(x);
}
