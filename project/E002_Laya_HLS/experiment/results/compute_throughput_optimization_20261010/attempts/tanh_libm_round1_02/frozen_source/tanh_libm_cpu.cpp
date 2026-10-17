#include "tanh_libm_bits.h"
#include <cmath>
#include <cfenv>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <vector>
static float fl(uint32_t x) { float y; std::memcpy(&y,&x,4); return y; }
static uint32_t bi(float x) { uint32_t y; std::memcpy(&y,&x,4); return y; }
static uint32_t randbits(uint32_t &s) { s ^= s<<13; s ^= s>>17; s ^= s<<5; return s; }
static void check(const char *op,uint32_t a,uint32_t b,uint32_t got,uint32_t expected) {
    if(got!=expected) { std::printf("FAIL %s a=%08x b=%08x got=%08x gold=%08x\n",op,a,b,got,expected); std::exit(1); }
}
static std::vector<uint32_t> read(const char *p) {
    std::ifstream f(p,std::ios::binary); if(!f) std::exit(2);
    std::vector<uint32_t> v; uint32_t x; while(f.read(reinterpret_cast<char*>(&x),4)) v.push_back(x); return v;
}
int main(int argc,char **argv) {
    if(argc!=3 && argc!=4) return 2;
    if(std::fegetround()!=FE_TONEAREST) { std::puts("FAIL_NATIVE_ROUNDING_MODE"); return 2; }
    std::ofstream directed_file;
    if(argc==4) { directed_file.open(argv[3]); if(!directed_file) return 2; }
    auto save_directed=[&](uint32_t a,uint32_t b,uint32_t gold) {
        if(argc==4) directed_file << std::hex << std::setfill('0')
            << std::setw(8) << a << '\n' << std::setw(8) << b << '\n'
            << std::setw(8) << gold << '\n';
    };
    unsigned directed=0;
    const uint32_t zeros[]={0,0x80000000};
    for(uint32_t a:zeros) for(uint32_t b:zeros) {
        volatile float fa=fl(a),fb=fl(b),sum=fa+fb;
        save_directed(a,b,bi(sum));
        check("signed_zero",a,b,fp_add_bits(a,b),bi(sum)); ++directed;
    }
    const uint32_t mags[]={1,2,0x007fffff,0x00800000,0x00800001,
                          0x24000000,0x3f000000,0x3f800000,0x3f800001,
                          0x40000000,0x41b00000,0x7f7ffffe};
    for(uint32_t m:mags) for(unsigned order=0;order<2;++order) {
        uint32_t a=order ? m|0x80000000 : m, b=a^0x80000000;
        volatile float fa=fl(a),fb=fl(b),sum=fa+fb;
        save_directed(a,b,bi(sum));
        check("exact_cancel",a,b,fp_add_bits(a,b),bi(sum)); ++directed;
        b=(m+1)|(order?0:0x80000000);
        volatile float fc=fl(b),near_sum=fa+fc;
        save_directed(a,b,bi(near_sum));
        check("adjacent_nonzero",a,b,fp_add_bits(a,b),bi(near_sum)); ++directed;
    }
    std::printf("RNE_ZERO_DIRECTED_PASS count=%u\n",directed); std::fflush(stdout);
    if(argc==4) directed_file.close();
    auto input=read(argv[1]),gold=read(argv[2]); if(input.size()!=gold.size()) return 2;
    for(size_t i=0;i<input.size();++i) {
        uint32_t out,st; tanh_libm_leaf(input[i],out,st);
        check("fixture",input[i],uint32_t(i),out,gold[i]);
        check("status",input[i],uint32_t(i),st,(input[i]&0x7fffffff)>=0x7f800000?1:0);
    }
    std::printf("FIXTURE_PASS count=%zu\n",input.size()); std::fflush(stdout);
    uint32_t s=0x3129beef;
    for(unsigned i=0;i<200000;++i) {
        uint32_t a=randbits(s), b=randbits(s);
        if((a&0x7f800000)==0x7f800000) a^=0x00800000;
        if((b&0x7f800000)==0x7f800000) b^=0x00800000;
        volatile float fa=fl(a),fb=fl(b);
        volatile float sum=fa+fb,prod=fa*fb,quot=fa/fb;
        check("add",a,b,fp_add_bits(a,b),bi(sum));
        check("mul",a,b,fp_mul_bits(a,b),bi(prod));
        check("div",a,b,fp_div_bits(a,b),bi(quot));
        check("tanh",a,i,tanh_libm_bits(a),bi(::tanhf(fa)));
    }
    std::puts("TANH_LIBM_CPU_PASS fixture_plus_200000_finite_tanh_and_600000_basic_ops");
}
