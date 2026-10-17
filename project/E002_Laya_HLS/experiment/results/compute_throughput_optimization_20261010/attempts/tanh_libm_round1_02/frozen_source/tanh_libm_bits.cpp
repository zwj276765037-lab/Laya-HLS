// tanhf/expm1f graph adapted from glibc 2.39 sysdeps/ieee754/flt-32.
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this software is freely
// granted, provided that this notice is preserved.
// Integer arithmetic implements each separate binary32 RNE operation.
#include "tanh_libm_bits.h"

static uint64_t jam(uint64_t x, int n) {
#pragma HLS inline
    if (n <= 0) return x;
    if (n >= 64) return x != 0;
    return (x >> n) | ((x << (64-n)) != 0);
}
static void unpack(uint32_t x, int &e, uint32_t &m) {
#pragma HLS inline
    int f = (x >> 23) & 255;
    m = x & 0x7fffff;
    e = f ? f-127 : -126;
    if (f) m |= 0x800000;
    for (int i=0; i<23; ++i) {
#pragma HLS unroll
        if (m && m < 0x800000) { m <<= 1; --e; }
    }
}
static uint32_t pack(uint32_t sign, int e, uint64_t m) {
#pragma HLS inline
    if (!m) return sign;
    if (m & (uint64_t(1)<<27)) { m=jam(m,1); ++e; }
    for (int i=0; i<27; ++i) {
#pragma HLS unroll
        if (m < (uint64_t(1)<<26)) { m <<= 1; --e; }
    }
    if (e < -126) { m=jam(m,-126-e); e=-126; }
    uint32_t frac = uint32_t(m >> 3);
    unsigned tail = unsigned(m & 7);
    if (tail > 4 || (tail == 4 && (frac & 1))) ++frac;
    if (frac >= 0x1000000) { frac >>= 1; ++e; }
    if (e > 127) return sign | 0x7f800000;
    if (frac < 0x800000) return sign | frac;
    return sign | (uint32_t(e+127)<<23) | (frac & 0x7fffff);
}
uint32_t fp_add_bits(uint32_t a, uint32_t b) {
#pragma HLS inline off
    uint32_t sa=a & 0x80000000, sb=b & 0x80000000;
    uint32_t aa=a & 0x7fffffff, ab=b & 0x7fffffff;
    if (aa >= 0x7f800000 || ab >= 0x7f800000) {
        if (aa>0x7f800000) return a|0x400000;
        if (ab>0x7f800000) return b|0x400000;
        if (aa==ab && sa!=sb) return 0x7fc00000;
        return aa==0x7f800000 ? a:b;
    }
    if (!aa && !ab) return sa & sb;
    if (!aa) return b;
    if (!ab) return a;
    int ea,eb; uint32_t ma,mb;
    unpack(a,ea,ma); unpack(b,eb,mb);
    if (ea<eb || (ea==eb && ma<mb)) {
        int et=ea; ea=eb; eb=et;
        uint32_t mt=ma; ma=mb; mb=mt;
        uint32_t st=sa; sa=sb; sb=st;
    }
    uint64_t lhs=uint64_t(ma)<<3, rhs=jam(uint64_t(mb)<<3,ea-eb);
    // Under RNE exact cancellation of nonzero opposite operands is +0.
    // The earlier zero-input branch separately preserves -0 + -0.
    if (sa!=sb && lhs==rhs) return 0;
    return pack(sa,ea,sa==sb ? lhs+rhs : lhs-rhs);
}
uint32_t fp_mul_bits(uint32_t a, uint32_t b) {
#pragma HLS inline off
    uint32_t s=(a^b)&0x80000000, aa=a&0x7fffffff, ab=b&0x7fffffff;
    if (aa>0x7f800000) return a|0x400000;
    if (ab>0x7f800000) return b|0x400000;
    if (aa==0x7f800000 || ab==0x7f800000)
        return (!aa || !ab) ? 0x7fc00000 : s|0x7f800000;
    if (!aa || !ab) return s;
    int ea,eb; uint32_t ma,mb; unpack(a,ea,ma); unpack(b,eb,mb);
    uint64_t p=uint64_t(ma)*mb;
    bool hi=(p & (uint64_t(1)<<47))!=0;
    return pack(s,ea+eb+(hi?1:0),jam(p,hi?21:20));
}
uint32_t fp_div_bits(uint32_t a, uint32_t b) {
#pragma HLS inline off
    uint32_t s=(a^b)&0x80000000, aa=a&0x7fffffff, ab=b&0x7fffffff;
    if (aa>0x7f800000) return a|0x400000;
    if (ab>0x7f800000) return b|0x400000;
    if ((!aa && !ab) || (aa==0x7f800000 && ab==0x7f800000)) return 0x7fc00000;
    if (aa==0x7f800000 || !ab) return s|0x7f800000;
    if (ab==0x7f800000 || !aa) return s;
    int ea,eb; uint32_t ma,mb; unpack(a,ea,ma); unpack(b,eb,mb);
    int e=ea-eb;
    uint32_t rem=ma;
    if (rem<mb) { rem <<= 1; --e; }
    rem-=mb;
    uint32_t q=1;
    for (int i=0; i<26; ++i) {
#pragma HLS pipeline off
        rem <<= 1; q <<= 1;
        if (rem>=mb) { rem-=mb; q |= 1; }
    }
    if (rem) q |= 1;
    return pack(s,e,q);
}
static uint32_t sub(uint32_t a,uint32_t b) {
#pragma HLS inline
    return fp_add_bits(a,b^0x80000000);
}
static uint32_t from_int(int k) {
#pragma HLS inline
    if (!k) return 0;
    uint32_t s=k<0?0x80000000:0, m=k<0?uint32_t(-k):uint32_t(k);
    return pack(s,23,uint64_t(m)<<3);
}
static int to_int(uint32_t x) {
#pragma HLS inline
    int e=int((x>>23)&255)-127;
    uint32_t m=(x&0x7fffff)|0x800000;
    int k=e<0?0:int(m>>(23-e));
    return x&0x80000000 ? -k:k;
}
static uint32_t expm1_bits(uint32_t x) {
#pragma HLS inline
    const uint32_t one=0x3f800000, half=0x3f000000;
    const uint32_t ln2hi=0x3f317180, ln2lo=0x3717f7d1;
    uint32_t hx=x&0x7fffffff; bool neg=(x>>31)!=0;
    // Caller domain is -2 < x < 44; no overflow/nonfinite case is reachable.
    if (hx>=0x4195b844 && neg) return 0xbf800000;
    int k=0; uint32_t c=0;
    if (hx>0x3eb17218) {
        uint32_t hi,lo;
        if (hx<0x3f851592) {
            hi=neg?fp_add_bits(x,ln2hi):sub(x,ln2hi);
            lo=neg?(ln2lo^0x80000000):ln2lo;
            k=neg?-1:1;
        } else {
            k=to_int(fp_add_bits(fp_mul_bits(0x3fb8aa3b,x),neg?0xbf000000:half));
            uint32_t t=from_int(k);
            hi=sub(x,fp_mul_bits(t,ln2hi));
            lo=fp_mul_bits(t,ln2lo);
        }
        x=sub(hi,lo);
        c=sub(sub(hi,x),lo);
    } else if (hx<0x33000000) return x;
    uint32_t hfx=fp_mul_bits(half,x), hxs=fp_mul_bits(x,hfx);
    uint32_t r=fp_add_bits(0x36867e54,fp_mul_bits(hxs,0xb457edbb));
    r=fp_add_bits(0xb8a670cd,fp_mul_bits(hxs,r));
    r=fp_add_bits(0x3ad00d01,fp_mul_bits(hxs,r));
    r=fp_add_bits(0xbd088889,fp_mul_bits(hxs,r));
    r=fp_add_bits(one,fp_mul_bits(hxs,r));
    uint32_t t=sub(0x40400000,fp_mul_bits(r,hfx));
    uint32_t e=fp_mul_bits(hxs,fp_div_bits(sub(r,t),sub(0x40c00000,fp_mul_bits(x,t))));
    if (k==0) return sub(x,sub(fp_mul_bits(x,e),hxs));
    e=sub(sub(fp_mul_bits(x,sub(e,c)),c),hxs);
    if (k==-1) return sub(fp_mul_bits(half,sub(x,e)),half);
    if (k==1) {
        if ((x>>31) && (x&0x7fffffff)>0x3e800000)
            return fp_mul_bits(0xc0000000,sub(e,fp_add_bits(x,half)));
        return fp_add_bits(one,fp_mul_bits(0x40000000,sub(x,e)));
    }
    uint32_t y;
    if (k<=-2 || k>56) {
        y=sub(one,sub(e,x));
        y += uint32_t(k)*0x800000u;
        return sub(y,one);
    }
    if (k<23) {
        t=one-(0x1000000u>>k);
        y=sub(t,sub(e,x));
    } else {
        t=uint32_t(127-k)<<23;
        y=fp_add_bits(sub(x,fp_add_bits(e,t)),one);
    }
    return y+uint32_t(k)*0x800000u;
}
uint32_t tanh_libm_bits(uint32_t x) {
#pragma HLS inline
    const uint32_t one=0x3f800000, two=0x40000000;
    uint32_t a=x&0x7fffffff, z;
    if (a>=0x7f800000) return 0; // numerical rejection handled by leaf status
    if (a==0) return x;
    if (a<0x24000000) return fp_mul_bits(x,fp_add_bits(one,x));
    if (a>=0x41b00000) z=sub(one,0x0da24260); // frozen tiny=1e-30f
    else if (a>=one) {
        uint32_t t=expm1_bits(fp_mul_bits(two,a));
        z=sub(one,fp_div_bits(two,fp_add_bits(t,two)));
    } else {
        uint32_t t=expm1_bits(fp_mul_bits(0xc0000000,a));
        z=fp_div_bits(t^0x80000000,fp_add_bits(t,two));
    }
    return z^(x&0x80000000);
}
void tanh_libm_leaf(uint32_t x, uint32_t &result, uint32_t &status) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=x
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS allocation function instances=fp_add_bits limit=1
#pragma HLS allocation function instances=fp_mul_bits limit=1
#pragma HLS allocation function instances=fp_div_bits limit=1
    status=(x&0x7fffffff)>=0x7f800000 ? 1:0;
    result=status?0:tanh_libm_bits(x);
}
