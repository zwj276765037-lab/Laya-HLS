// Dormant CPU source. Do not execute under the source-preparation gate.
#include "c1_arithmetic.h"
#include "c1_flow.h"

#include <cmath>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>

namespace {
uint32_t raw(float value) {
  uint32_t bits;
  std::memcpy(&bits,&value,sizeof(bits));
  return bits;
}
void require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
uint32_t independent_half_reference(uint16_t half) {
  const uint32_t sign=uint32_t(half & 0x8000u)<<16;
  const unsigned e=(half>>10)&31u;
  const unsigned m=half&1023u;
  if (e==31u) return sign|0x7f800000u|(m<<13);
  double magnitude=e ? std::ldexp(double(1024u+m),int(e)-25) :
                       std::ldexp(double(m),-24);
  float converted=float(magnitude);
  if (sign) converted=-converted;
  return raw(converted);
}
void half_all_patterns() {
  for (unsigned word=0;word<65536u;++word)
    require(c1::half_to_f32_bits(uint16_t(word))==
            independent_half_reference(uint16_t(word)),"half pattern mismatch");
}
void int8_extremes() {
  const int values[]={-128,-127,-1,0,1,127};
  for (int a:values) for (int w:values) {
    ap_uint<256> av=0,wv=0;
    int64_t reference=0;
    for (unsigned lane=0;lane<32;++lane) {
      const int left=(lane & 1u) ? a : -128;
      const int right=(lane & 1u) ? w : -128;
      av.range(8*lane+7,8*lane)=uint8_t(int8_t(left));
      wv.range(8*lane+7,8*lane)=uint8_t(int8_t(right));
      reference+=int64_t(left)*right;
    }
    require(reference>=INT32_MIN && reference<=INT32_MAX,"reference overflow");
    require(c1::dot32(av,wv)==reference,"independent wide dot mismatch");
  }
  ap_uint<256> all=0;
  for (unsigned lane=0;lane<32;++lane) all.range(8*lane+7,8*lane)=0x80;
  require(c1::dot32(all,all)==524288,"all -128 dot mismatch");
}
void finite_r0_edges() {
  require(c1::div127_bits(0x037e0000u)==0x00400000u,"tiny div127 edge");
  require(c1::reciprocal_bits(0x00400000u)==0x7f000000u,"subnormal reciprocal edge");
  require(c1::div127_bits(0x00000001u)==0,"smallest subnormal d-zero edge");
  uint32_t raw32[32]={};
  raw32[0]=0x00800000u;
  require(!c1::quant_group(raw32).valid,"overflow reciprocal must reject group");
  raw32[0]=0x00000001u;
  const c1::QuantGroup tiny=c1::quant_group(raw32);
  require(tiny.valid && tiny.d_raw==0 && tiny.reciprocal_raw==0 &&
          tiny.packed==0,"smallest subnormal zero route");
  const c1::BiasValue bias=c1::final_bias(0,0x00000001u,true);
  require(bias.finite && bias.invariant_ok && bias.raw==0x00000001u,
          "PS+0 tiny bias route");
  require(!c1::final_bias(0x80000000u,0,true).invariant_ok,
          "negative-zero PS invariant");
}
void independent_ledger_examples() {
  c1::ResultRing ring={};ring.reset_metadata();ring.start_edge();
  ap_uint<6> index=0;
  for (unsigned i=0;i<64;++i) {
    require(ring.reserve(index) && unsigned(index)==i,"result reservation order");
    c1::ResultPayload payload={};payload.result_slot=index;payload.seq=i;
    require(ring.return_result(index,payload),"fixed return reservation");
  }
  require(!ring.can_reserve() && ring.conserved(),"result full credit");
  c1::ResultPayload oldest={};
  require(ring.commit_oldest(oldest) && oldest.seq==0,"oldest ordered commit");
  require(!ring.can_reserve(),"same-edge free credit reused");
  ring.start_edge();require(ring.reserve(index) && unsigned(index)==0,"ring wrap");
  require(ring.conserved(),"credit invariant after wrap");
  c1::TileHazards hazard={};hazard.reset_metadata();
  require(hazard.issue_ready(0,2),"initial tile issue");
  hazard.on_issue(0);require(!hazard.issue_ready(0,3),"busy tile issue");
  hazard.on_physical_commit(0,10);
  require(!hazard.issue_ready(0,11) && hazard.issue_ready(0,12),
          "physical commit plus two edge guard");
  c1::RankedError best={};
  c1::take_minimum(best,true,c1::error_key(3,2,1,7,3),99);
  c1::take_minimum(best,true,c1::error_key(2,15,7,7,3),88);
  require(best.valid && best.bad_element==88,"minimum rank not arrival order");
}
}  // namespace

int main() {
  try {
    half_all_patterns();
    int8_extremes();
    finite_r0_edges();
    independent_ledger_examples();
    std::cout<<"C1_SOURCE_TEST_PASS half=65536 int8_extremes=36\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr<<"C1_SOURCE_TEST_FAIL "<<error.what()<<'\n';
    return 1;
  }
}
