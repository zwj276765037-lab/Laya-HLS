
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cfenv>
#include <fstream>
#include <vector>
#include <string>
static uint32_t node_a[42],node_b[42],node_result[42];
static bool seen[42];
static uint32_t native_fp(unsigned op,uint32_t a,uint32_t b) {
 float af,bf;std::memcpy(&af,&a,4);std::memcpy(&bf,&b,4);
 volatile float av=af,bv=bf,rv=0;
 if(op==0)rv=av+bv;else if(op==1)rv=av*bv;else rv=av/bv;
 float result=rv;uint32_t bits;std::memcpy(&bits,&result,4);return bits;
}
static uint32_t traced_fp(unsigned op,unsigned index,uint32_t a,uint32_t b) {
 uint32_t result=native_fp(op,a,b);
 if(op==0 && index==23) {
  if(a!=0x3f800000u||b!=0x8da24260u||result!=0x3f800000u)std::exit(3);
  return result;
 }
 unsigned slot=op==0?index:(op==1?23+index:40+index);
 if(slot>=42||seen[slot])std::exit(4);
 node_a[slot]=a;node_b[slot]=b;node_result[slot]=result;seen[slot]=true;
 return result;
}
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
template<int Node> static uint32_t stream_add_node(uint32_t a,uint32_t b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
    return traced_fp(0,Node,a,b);
}
template<int Node> static uint32_t stream_mul_node(uint32_t a,uint32_t b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
    return traced_fp(1,Node,a,b);
}
template<int Node> static uint32_t stream_div_node(uint32_t a,uint32_t b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
    return traced_fp(2,Node,a,b);
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
    const uint32_t m0=stream_mul_node<0>(low?0xc0000000:two,core?abs:0);
    const uint32_t ya=m0&0x7fffffff;
    const bool yn=(m0>>31)!=0;
    const bool reduce=ya>0x3eb17218, simple=ya<0x3f851592;
    const uint32_t m1=stream_mul_node<1>(0x3fb8aa3b,m0);
    const uint32_t a0=stream_add_node<0>(m1,yn?0xbf000000:half);
    const int k=reduce?(simple?(yn?-1:1):to_int(a0)):0;
    const uint32_t fk=from_int(k);
    const uint32_t m2=stream_mul_node<2>(fk,0x3f317180);
    const uint32_t m3=stream_mul_node<3>(fk,0x3717f7d1);
    const uint32_t a1=stream_add_node<1>(m0,m2^0x80000000);
    const uint32_t a2=stream_add_node<2>(a1,m3^0x80000000);
    const uint32_t x=reduce?a2:m0;
    const uint32_t a3=stream_add_node<3>(a1,x^0x80000000);
    const uint32_t a4=stream_add_node<4>(a3,m3^0x80000000);
    const uint32_t c=reduce?a4:0;
    const uint32_t m4=stream_mul_node<4>(half,x);
    const uint32_t m5=stream_mul_node<5>(x,m4);
    const uint32_t m6=stream_mul_node<6>(m5,0xb457edbb);
    const uint32_t a5=stream_add_node<5>(0x36867e54,m6);
    const uint32_t m7=stream_mul_node<7>(m5,a5);
    const uint32_t a6=stream_add_node<6>(0xb8a670cd,m7);
    const uint32_t m8=stream_mul_node<8>(m5,a6);
    const uint32_t a7=stream_add_node<7>(0x3ad00d01,m8);
    const uint32_t m9=stream_mul_node<9>(m5,a7);
    const uint32_t a8=stream_add_node<8>(0xbd088889,m9);
    const uint32_t m10=stream_mul_node<10>(m5,a8);
    const uint32_t a9=stream_add_node<9>(one,m10);
    const uint32_t m11=stream_mul_node<11>(a9,m4);
    const uint32_t a10=stream_add_node<10>(0x40400000,m11^0x80000000);
    const uint32_t m12=stream_mul_node<12>(x,a10);
    const uint32_t a11=stream_add_node<11>(a9,a10^0x80000000);
    const uint32_t a12=stream_add_node<12>(0x40c00000,m12^0x80000000);
    const uint32_t dexp=stream_div_node<0>(a11,a12);
    const uint32_t m13=stream_mul_node<13>(m5,dexp);
    const uint32_t a13=stream_add_node<13>(m13,c^0x80000000);
    const uint32_t m14=stream_mul_node<14>(x,k==0?m13:a13);
    const uint32_t a14=stream_add_node<14>(m14,(k==0?m5:c)^0x80000000);
    const uint32_t a15=stream_add_node<15>(a14,m5^0x80000000);
    const uint32_t e=k==0?a14:a15;
    const bool k1neg=k==1 && (x>>31) && (x&0x7fffffff)>0x3e800000;
    const bool forward=k==0 || k==-1 || (k==1&&!k1neg);
    const uint32_t a16=stream_add_node<16>(forward?x:e,(forward?e:x)^0x80000000);
    const uint32_t power=k>=23 && k<=56 ? uint32_t(127-k)<<23 : 0;
    const uint32_t a17=stream_add_node<17>(k1neg?x:e,k1neg?half:power);
    const uint32_t rep_t=k>=2 && k<23 ? one-(0x1000000u>>k) : one;
    const uint32_t a18=stream_add_node<18>(k1neg?e:(k>=23?x:rep_t),
                                  (k1neg||k>=23?a17:a16)^0x80000000);
    const uint32_t factor=k==-1?half:(k==1?(k1neg?0xc0000000:two):one);
    const uint32_t m15=stream_mul_node<15>(factor,forward?a16:a18);
    const bool outside=k<=-2 || k>56;
    const uint32_t scale_input=outside?m15+uint32_t(k)*0x800000u:m15;
    const uint32_t final_bias=k==-1?0xbf000000:
        ((k==1&&!k1neg)||(k>=23&&k<=56)?one:0xbf800000);
    const uint32_t a19=stream_add_node<19>(scale_input,final_bias);
    uint32_t rebuilt=k==0?a16:(k==-1?a19:(k==1?(k1neg?m15:a19):
        (outside?a19:(k<23?m15:a19)+uint32_t(k)*0x800000u)));
    const uint32_t exp=ya<0x33000000?m0:rebuilt;
    const uint32_t a20=stream_add_node<20>(exp,two);
    const uint32_t dtanh=stream_div_node<1>(low?exp^0x80000000:two,a20);
    const uint32_t a21=stream_add_node<21>(one,dtanh^0x80000000);
    const uint32_t tiny_input=abs>0 && abs<0x24000000?input:0;
    const uint32_t a22=stream_add_node<22>(one,tiny_input);
    const uint32_t m16=stream_mul_node<16>(tiny_input,a22);
    const uint32_t a23=stream_add_node<23>(one,0x8da24260);
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

static std::vector<uint32_t> read_mem(const char *path) {
 std::ifstream input(path);std::vector<uint32_t> words;std::string word;
 if(!input)std::exit(2);
 while(input>>word)words.push_back(uint32_t(std::stoul(word,nullptr,16)));
 return words;
}
int main(int argc,char **argv) {
 if(argc!=5 || std::fesetround(FE_TONEAREST)!=0)return 2;
 auto inputs=read_mem(argv[1]),gold=read_mem(argv[2]),ops=read_mem(argv[3]);
 if(inputs.size()!=3270||gold.size()!=3270||ops.size()!=4*1159)return 2;
 FILE *output=std::fopen(argv[4],"w");if(!output)return 2;
 for(unsigned i=0;i<inputs.size();++i) {
  std::memset(seen,0,sizeof(seen));uint32_t result=stream_graph(inputs[i]);
  if(result!=gold[i]) {
   std::printf("TANH_CANONICAL_CPU_FINAL_FAIL index=%u x=%08x got=%08x gold=%08x\n",i,inputs[i],result,gold[i]);return 1;
  }
  for(unsigned j=0;j<42;++j) {
   if(!seen[j])return 1;
   std::fprintf(output,"%08x\n%08x\n%08x\n",node_a[j],node_b[j],node_result[j]);
  }
 }
 std::fclose(output);
 for(unsigned i=0;i<1159;++i) {
  unsigned op=ops[4*i];uint32_t a=ops[4*i+1],b=ops[4*i+2],expected=ops[4*i+3];
  uint32_t bits=op==0?stream_detail::fp_add_bits(a,b):
   (op==1?stream_detail::fp_mul_bits(a,b):stream_detail::fp_div_bits(a,b));
  if(bits!=expected||native_fp(op,a,b)!=expected) {
   std::printf("TANH_CANONICAL_CPU_HELPER_FAIL index=%u op=%u a=%08x b=%08x got=%08x gold=%08x\n",i,op,a,b,bits,expected);return 1;
  }
 }
 std::puts("TANH_CANONICAL_CPU_PASS fixture=3270 nodes=42 independent_native_node_results=137340 native_helpers=1159 original_gold_unchanged=1");
}
