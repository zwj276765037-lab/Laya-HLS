// tanhf/expm1f graph adapted from glibc 2.39 sysdeps/ieee754/flt-32.
// Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
// Developed at SunPro, a Sun Microsystems, Inc. business.
// Permission to use, copy, modify, and distribute this software is freely
// granted, provided that this notice is preserved.
// Integer arithmetic implements each separate binary32 RNE operation.
#include "tanh_libm_stream_bits.h"
namespace stream_detail {
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
// Add-only normalization has five bounded stages. The multiply/divide
// implementation keeps its separately verified generic normalization.
static unsigned add_clz32(uint32_t x) {
#pragma HLS inline
    unsigned n=0;
    if (!(x & 0xffff0000u)) { x <<= 16; n += 16; }
    if (!(x & 0xff000000u)) { x <<= 8; n += 8; }
    if (!(x & 0xf0000000u)) { x <<= 4; n += 4; }
    if (!(x & 0xc0000000u)) { x <<= 2; n += 2; }
    if (!(x & 0x80000000u)) ++n;
    return n;
}
static uint32_t add_jam(uint32_t x, int n) {
#pragma HLS inline
    if (n <= 0) return x;
    if (n >= 32) return x != 0;
    return (x >> n) | ((x << (32-n)) != 0);
}
static void add_unpack(uint32_t x, int &e, uint32_t &m) {
#pragma HLS inline
    unsigned f=(x >> 23) & 255;
    m=x & 0x7fffff;
    e=f ? int(f)-127 : -126;
    if (f) m |= 0x800000;
    else {
        unsigned shift=add_clz32(m)-8;
        m <<= shift; e -= shift;
    }
}
static uint32_t add_pack(uint32_t sign, int e, uint32_t m) {
#pragma HLS inline
    if (!m) return sign;
    if (m & 0x08000000u) { m=add_jam(m,1); ++e; }
    else {
        unsigned shift=add_clz32(m)-5;
        m <<= shift; e -= shift;
    }
    if (e < -126) { m=add_jam(m,-126-e); e=-126; }
    uint32_t frac=m >> 3;
    unsigned tail=m & 7;
    if (tail > 4 || (tail == 4 && (frac & 1))) ++frac;
    if (frac >= 0x1000000) { frac >>= 1; ++e; }
    if (e > 127) return sign | 0x7f800000;
    if (frac < 0x800000) return sign | frac;
    return sign | (uint32_t(e+127)<<23) | (frac & 0x7fffff);
}
uint32_t fp_add_bits(uint32_t a, uint32_t b) {
#pragma HLS inline
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
    add_unpack(a,ea,ma); add_unpack(b,eb,mb);
    if (ea<eb || (ea==eb && ma<mb)) {
        int et=ea; ea=eb; eb=et;
        uint32_t mt=ma; ma=mb; mb=mt;
        uint32_t st=sa; sa=sb; sb=st;
    }
    uint32_t lhs=ma<<3, rhs=add_jam(mb<<3,ea-eb);
    // Under RNE exact cancellation of nonzero opposite operands is +0.
    // The earlier zero-input branch separately preserves -0 + -0.
    if (sa!=sb && lhs==rhs) return 0;
    return add_pack(sa,ea,sa==sb ? lhs+rhs : lhs-rhs);
}
uint32_t fp_mul_bits(uint32_t a, uint32_t b) {
#pragma HLS inline
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
#pragma HLS inline
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
#pragma HLS unroll
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

}
uint32_t stream_fp_add_bits(uint32_t a,uint32_t b) {
#pragma HLS inline
    return stream_detail::fp_add_bits(a,b);
}
uint32_t stream_fp_mul_bits(uint32_t a,uint32_t b) {
#pragma HLS inline
    return stream_detail::fp_mul_bits(a,b);
}
uint32_t stream_fp_div_bits(uint32_t a,uint32_t b) {
#pragma HLS inline
    return stream_detail::fp_div_bits(a,b);
}
// Every A/M/D call below is one named graph position. Predicated operands
// share alternative reconstruction branches at that position; all operators
// perform independent RNE steps. Dormant branches receive finite safe data.
static uint32_t stream_graph(uint32_t input) {
#pragma HLS inline
    using namespace stream_detail;
    const uint32_t one=0x3f800000,two=0x40000000,half=0x3f000000;
    const uint32_t sign=input&0x80000000,abs=input&0x7fffffff;
    const bool core=abs>=0x24000000 && abs<0x41b00000;
    const bool low=abs<one;
    const uint32_t m0=fp_mul_bits(low?0xc0000000:two,core?abs:0);
    const uint32_t ya=m0&0x7fffffff;
    const bool yn=(m0>>31)!=0;
    const bool reduce=ya>0x3eb17218, simple=ya<0x3f851592;
    const uint32_t m1=fp_mul_bits(0x3fb8aa3b,m0);
    const uint32_t a0=fp_add_bits(m1,yn?0xbf000000:half);
    const int k=reduce?(simple?(yn?-1:1):to_int(a0)):0;
    const uint32_t fk=from_int(k);
    const uint32_t m2=fp_mul_bits(fk,0x3f317180);
    const uint32_t m3=fp_mul_bits(fk,0x3717f7d1);
    const uint32_t a1=fp_add_bits(m0,m2^0x80000000);
    const uint32_t a2=fp_add_bits(a1,m3^0x80000000);
    const uint32_t x=reduce?a2:m0;
    const uint32_t a3=fp_add_bits(a1,x^0x80000000);
    const uint32_t a4=fp_add_bits(a3,m3^0x80000000);
    const uint32_t c=reduce?a4:0;
    const uint32_t m4=fp_mul_bits(half,x);
    const uint32_t m5=fp_mul_bits(x,m4);
    const uint32_t m6=fp_mul_bits(m5,0xb457edbb);
    const uint32_t a5=fp_add_bits(0x36867e54,m6);
    const uint32_t m7=fp_mul_bits(m5,a5);
    const uint32_t a6=fp_add_bits(0xb8a670cd,m7);
    const uint32_t m8=fp_mul_bits(m5,a6);
    const uint32_t a7=fp_add_bits(0x3ad00d01,m8);
    const uint32_t m9=fp_mul_bits(m5,a7);
    const uint32_t a8=fp_add_bits(0xbd088889,m9);
    const uint32_t m10=fp_mul_bits(m5,a8);
    const uint32_t a9=fp_add_bits(one,m10);
    const uint32_t m11=fp_mul_bits(a9,m4);
    const uint32_t a10=fp_add_bits(0x40400000,m11^0x80000000);
    const uint32_t m12=fp_mul_bits(x,a10);
    const uint32_t a11=fp_add_bits(a9,a10^0x80000000);
    const uint32_t a12=fp_add_bits(0x40c00000,m12^0x80000000);
    const uint32_t dexp=fp_div_bits(a11,a12);
    const uint32_t m13=fp_mul_bits(m5,dexp);
    const uint32_t a13=fp_add_bits(m13,c^0x80000000);
    const uint32_t m14=fp_mul_bits(x,k==0?m13:a13);
    const uint32_t a14=fp_add_bits(m14,(k==0?m5:c)^0x80000000);
    const uint32_t a15=fp_add_bits(a14,m5^0x80000000);
    const uint32_t e=k==0?a14:a15;
    const bool k1neg=k==1 && (x>>31) && (x&0x7fffffff)>0x3e800000;
    const bool forward=k==0 || k==-1 || (k==1&&!k1neg);
    const uint32_t a16=fp_add_bits(forward?x:e,(forward?e:x)^0x80000000);
    const uint32_t power=k>=23 && k<=56 ? uint32_t(127-k)<<23 : 0;
    const uint32_t a17=fp_add_bits(k1neg?x:e,k1neg?half:power);
    const uint32_t rep_t=k>=2 && k<23 ? one-(0x1000000u>>k) : one;
    const uint32_t a18=fp_add_bits(k1neg?e:(k>=23?x:rep_t),
                                  (k1neg||k>=23?a17:a16)^0x80000000);
    const uint32_t factor=k==-1?half:(k==1?(k1neg?0xc0000000:two):one);
    const uint32_t m15=fp_mul_bits(factor,forward?a16:a18);
    const bool outside=k<=-2 || k>56;
    const uint32_t scale_input=outside?m15+uint32_t(k)*0x800000u:m15;
    const uint32_t final_bias=k==-1?0xbf000000:
        ((k==1&&!k1neg)||(k>=23&&k<=56)?one:0xbf800000);
    const uint32_t a19=fp_add_bits(scale_input,final_bias);
    uint32_t rebuilt=k==0?a16:(k==-1?a19:(k==1?(k1neg?m15:a19):
        (outside?a19:(k<23?m15:a19)+uint32_t(k)*0x800000u)));
    const uint32_t exp=ya<0x33000000?m0:rebuilt;
    const uint32_t a20=fp_add_bits(exp,two);
    const uint32_t dtanh=fp_div_bits(low?exp^0x80000000:two,a20);
    const uint32_t a21=fp_add_bits(one,dtanh^0x80000000);
    const uint32_t tiny_input=abs>0 && abs<0x24000000?input:0;
    const uint32_t a22=fp_add_bits(one,tiny_input);
    const uint32_t m16=fp_mul_bits(tiny_input,a22);
    const uint32_t a23=fp_add_bits(one,0x8da24260);
    if(abs>=0x7f800000) return 0;
    if(abs==0) return input;
    if(abs<0x24000000) return m16;
    return (core?(low?dtanh:a21):a23)^sign;
}
uint32_t tanh_libm_stream_bits(uint32_t x) {
#pragma HLS inline
    return stream_graph(x);
}
void tanh_libm_stream_leaf(uint32_t x,uint32_t &result,uint32_t &status) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=x
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS pipeline II=1
    uint32_t value=stream_graph(x);
    result=value;
    status=(x&0x7fffffff)>=0x7f800000?1:0;
}
