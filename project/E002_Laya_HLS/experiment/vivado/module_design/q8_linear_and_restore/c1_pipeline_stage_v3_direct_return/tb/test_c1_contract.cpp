// Dormant source-only regression. Requires a separate CPU execution release.
#include "c1_operand_stages.h"
#include "c1_quant_bias.h"

#include <cmath>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <stdexcept>

namespace {
uint32_t raw(float value) {
  uint32_t out;
  std::memcpy(&out, &value, sizeof(out));
  return out;
}
void require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
uint32_t independent_half_reference(uint16_t half) {
  const uint32_t sign=uint32_t(half & 0x8000u)<<16;
  const unsigned exponent=(half>>10)&31u;
  const unsigned fraction=half&1023u;
  if (exponent==31u) return sign|0x7f800000u|(fraction<<13);
  const double magnitude=exponent ?
      std::ldexp(double(1024u+fraction),int(exponent)-25) :
      std::ldexp(double(fraction),-24);
  const float converted=sign ? -float(magnitude) : float(magnitude);
  return raw(converted);
}
void half_all_patterns() {
  for (unsigned word=0;word<65536u;++word)
    require(c1_stage::half_to_f32_bits(uint16_t(word))==
            independent_half_reference(uint16_t(word)),
            "live half decoder mismatch");
}
int32_t staged_dot(ap_uint<256> a, ap_uint<256> w) {
  c1_stage::DotBank input={};
  input.tag.valid=1;
  for (unsigned row=0;row<4;++row) input.a[row]=a;
  for (unsigned column=0;column<8;++column) input.w[column]=w;
  c1_stage::Products products;
  c1_stage::Tree1 tree1;
  c1_stage::Tree2 tree2;
  c1_stage::Tree3 tree3;
  c1_stage::Tree4 tree4;
  c1_stage::Tree5 tree5;
  c1_stage::make_products(input,products);
  c1_stage::reduce_tree1(products,tree1);
  c1_stage::reduce_tree<17,16>(tree1,tree2);
  c1_stage::reduce_tree<18,8>(tree2,tree3);
  c1_stage::reduce_tree<19,4>(tree3,tree4);
  c1_stage::reduce_tree<20,2>(tree4,tree5);
  for (unsigned lane=1;lane<32;++lane)
    require(tree5.value[lane][0]==tree5.value[0][0],
            "broadcast lane dot mismatch");
  return int32_t(tree5.value[0][0]);
}
void int8_extremes() {
  const int values[]={-128,-127,-1,0,1,127};
  for (int a:values) for (int w:values) {
    ap_uint<256> av=0,wv=0;
    int64_t expected=0;
    for (unsigned k=0;k<32;++k) {
      const int left=(k&1u) ? a : -128;
      const int right=(k&1u) ? w : -128;
      av.range(8*k+7,8*k)=uint8_t(int8_t(left));
      wv.range(8*k+7,8*k)=uint8_t(int8_t(right));
      expected+=int64_t(left)*right;
    }
    require(staged_dot(av,wv)==expected,"independent wide dot mismatch");
  }
  ap_uint<256> all=0;
  for (unsigned k=0;k<32;++k) all.range(8*k+7,8*k)=0x80;
  require(staged_dot(all,all)==524288,"all -128 dot mismatch");
}
void finite_r0_edges() {
  require(c1::div127_bits(0x037e0000u)==0x00400000u,"tiny div127 edge");
  require(c1::reciprocal_bits(0x00400000u)==0x7f000000u,
          "subnormal reciprocal edge");
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
void restore_and_tag_examples() {
  c1_stage::DotConverted dot={};
  c1_stage::ScaleProducts scale={};
  dot.context.tag.valid=1;
  dot.context.tag.seq=19;
  dot.context.tag.shape_mask=1;
  dot.context.tag.trace_reserved=1;
  dot.context.tag.trace_lane=0;
  scale.tag=dot.context.tag;
  dot.dot_f32[0]=raw(2.0f);
  dot.context.old_ps[0]=raw(3.0f);
  dot.trace_dot=2;
  scale.product[0]=raw(4.0f);
  scale.trace_sa=raw(2.0f);
  scale.trace_sw=raw(2.0f);
  c1_stage::TermInput term_input;
  require(c1_stage::join_dot_scale(dot,scale,term_input),
          "same tag join rejected");
  c1_stage::TermOutput term_output;
  c1_stage::AddOutput added;
  c1_stage::FinalReturn returned;
  c1_stage::multiply_term(term_input,term_output);
  c1_stage::add_ps(term_output,added);
  c1_stage::classify(added,returned);
  require(returned.valid && returned.result.success_mask[0] &&
          returned.result.next_ps[0]==raw(11.0f),
          "separate term and add regression");
  scale.tag.seq=20;
  require(!c1_stage::join_dot_scale(dot,scale,term_input) &&
          term_input.alignment_fault,"changing-tag mismatch was accepted");
}
void independent_ledger_examples() {
  c1::ResultRing ring;
  ring.reset_metadata();
  ring.start_edge();
  ap_uint<6> index=0;
  for (unsigned i=0;i<64;++i) {
    require(ring.reserve(index) && unsigned(index)==i,"result reservation order");
    c1::ResultPayload payload={};
    payload.result_slot=index; payload.seq=i;
    require(ring.return_result(index,payload),"reserved return");
  }
  require(!ring.can_reserve() && ring.conserved(),"result full credit");
  c1::ResultPayload oldest;
  require(ring.commit_oldest(oldest) && oldest.seq==0,"oldest ordered commit");
  require(!ring.can_reserve(),"same-step free credit reused");
  ring.start_edge();
  require(ring.reserve(index) && unsigned(index)==0,"ring wrap");
  require(ring.conserved(),"credit invariant after wrap");
  c1::TileHazards hazard;
  hazard.reset_metadata();
  require(hazard.issue_ready(0),"initial tile issue");
  hazard.on_issue(0);
  require(!hazard.issue_ready(0),"busy tile issue");
  hazard.on_physical_commit(0);
  require(!hazard.issue_ready(0),"same-step commit reuse");
  hazard.end_arbitration_step();
  require(!hazard.issue_ready(0),"next-step commit reuse");
  hazard.end_arbitration_step();
  require(hazard.issue_ready(0),"commit plus two guard");
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
    restore_and_tag_examples();
    independent_ledger_examples();
    std::cout<<"C1_SOURCE_TEST_PASS half=65536 int8_extremes=36\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr<<"C1_SOURCE_TEST_FAIL "<<error.what()<<'\n';
    return 1;
  }
}
