#pragma once

#include "ap_int.h"
#include "c1_flow.h"
#include "c1_stage_bits.h"
#include <cstdint>

#pragma STDC FP_CONTRACT OFF

// Isolated source candidate. Service latency/II and a hardware return edge are
// UNMEASURED; these operations are not a virtual 18-edge result delay.
namespace c1_stage {

struct Tag {
  ap_uint<1> valid;
  ap_uint<17> seq;
  ap_uint<4> m0;
  ap_uint<7> g;
  ap_uint<10> tile;
  ap_uint<1> last_g;
  ap_uint<6> result_slot;
  ap_uint<1> trace_reserved;
  ap_uint<2> trace_slot;
  ap_uint<5> trace_lane;
  ap_uint<32> shape_mask;
  ap_uint<32> bad_mask;
};
constexpr unsigned kTagBits = 118;
static_assert(kTagBits == 1+17+4+7+10+1+6+1+2+5+32+32,
              "stage tag width drift");

// A request is accepted only with pre-edge Q64/D4 credits and same-tile guard.
// The banks own the following return; a C++ array read is not its proof.
struct BankRequest {
  Tag tag;
  ap_uint<15> w_address;
  ap_uint<9> a_address;
  ap_uint<10> ps_address;
  ap_uint<1> ps_read_enable;
};
constexpr unsigned kBankRequestBits = kTagBits + 15 + 9 + 10 + 1;

struct BankReturn {
  Tag tag;
  ap_uint<256> a[4];
  ap_uint<256> w[8];
  ap_uint<16> sa_half[4];
  ap_uint<16> sw_half[8];
  ap_uint<32> old_ps[32];
};
constexpr unsigned kBankReturnBits = kTagBits + 4*256 + 8*256 +
                                      4*16 + 8*16 + 32*32;
static_assert(kBankReturnBits == 4406, "bank return source width drift");

struct DotBank {
  Tag tag;
  ap_uint<256> a[4];
  ap_uint<256> w[8];
  ap_uint<32> old_ps[32];
};
constexpr unsigned kDotBankBits = kTagBits + 4*256 + 8*256 + 32*32;
struct ScaleBank {
  Tag tag;
  ap_uint<16> sa_half[4];
  ap_uint<16> sw_half[8];
};
constexpr unsigned kScaleBankBits = kTagBits + 4*16 + 8*16;

struct DotContext {
  Tag tag;
  ap_uint<32> old_ps[32];
};
constexpr unsigned kDotContextBits = kTagBits + 32*32;

struct Products {
  DotContext context;
  ap_int<16> value[32][32];
};
constexpr unsigned kProductBits = kDotContextBits + 32*32*16;

template <unsigned W, unsigned COUNT>
struct Tree {
  DotContext context;
  ap_int<W> value[32][COUNT];
};
using Tree1 = Tree<17,16>;
using Tree2 = Tree<18,8>;
using Tree3 = Tree<19,4>;
using Tree4 = Tree<20,2>;
using Tree5 = Tree<21,1>;
constexpr unsigned kTreeRegisterBits =
    32*(16*17 + 8*18 + 4*19 + 2*20 + 1*21);
static_assert(kTreeRegisterBits == 17696, "tree arithmetic bits drift");

struct ScaleDecoded {
  Tag tag;
  ap_uint<32> sa[4];
  ap_uint<32> sw[8];
};
constexpr unsigned kScaleDecodedBits = kTagBits + (4+8)*32;

struct ScaleProducts {
  Tag tag;
  ap_uint<32> product[32];
  ap_uint<32> scale_bad, product_bad;
  ap_uint<32> trace_sa, trace_sw;
};
constexpr unsigned kScaleProductBits = kTagBits + 32*32 + 32+32+32+32;

struct DotConverted {
  DotContext context;
  ap_uint<32> dot_f32[32];
  ap_uint<32> trace_dot;
};
constexpr unsigned kDotConvertedBits = kDotContextBits + 32*32 + 32;

struct TermInput {
  ap_uint<1> alignment_fault;
  Tag tag;
  ap_uint<32> old_ps[32];
  ap_uint<32> dot_f32[32];
  ap_uint<32> scale_product[32];
  ap_uint<32> scale_bad, product_bad;
  ap_uint<32> trace_sa, trace_sw, trace_dot;
};
constexpr unsigned kTermInputBits = 1 + kTagBits + 3*32*32 + 2*32 + 3*32;

struct TermOutput {
  ap_uint<1> alignment_fault;
  Tag tag;
  ap_uint<32> old_ps[32];
  ap_uint<32> term[32];
  ap_uint<32> scale_bad, product_bad, term_bad;
  ap_uint<32> trace_sa, trace_sw, trace_dot, trace_product, trace_term;
};
constexpr unsigned kTermOutputBits = 1 + kTagBits + 2*32*32 + 3*32 + 5*32;

struct AddOutput {
  ap_uint<1> alignment_fault;
  Tag tag;
  ap_uint<32> next[32];
  ap_uint<32> scale_bad, product_bad, term_bad, next_bad;
  ap_uint<32> trace_sa, trace_sw, trace_dot, trace_product, trace_term,
              trace_next;
};
constexpr unsigned kAddOutputBits = 1 + kTagBits + 32*32 + 4*32 + 6*32;

// One final full-vector boundary is permitted only for the reservation-return
// interface. The consuming core must write its reserved Q64/D4 slots directly.
struct FinalReturn {
  ap_uint<1> valid;
  ap_uint<1> alignment_fault;
  c1::ResultPayload result;
  ap_uint<256> trace_payload;
};
constexpr unsigned kFinalReturnBits = 2 + c1::kResultPayloadBits + 256;
static_assert(kFinalReturnBits == 1557, "final boundary width drift");

inline bool same_tag(const Tag& a, const Tag& b) {
  return a.valid==b.valid && a.seq==b.seq && a.m0==b.m0 &&
         a.g==b.g && a.tile==b.tile && a.last_g==b.last_g &&
         a.result_slot==b.result_slot &&
         a.trace_reserved==b.trace_reserved && a.trace_slot==b.trace_slot &&
         a.trace_lane==b.trace_lane && a.shape_mask==b.shape_mask &&
         a.bad_mask==b.bad_mask;
}

inline void split_bank_return(const BankReturn& in, DotBank& dot,
                              ScaleBank& scale) {
#pragma HLS INLINE off
  dot.tag=in.tag; scale.tag=in.tag;
  for (unsigned row=0;row<4;++row) {
#pragma HLS UNROLL
    dot.a[row]=in.a[row]; scale.sa_half[row]=in.sa_half[row];
  }
  for (unsigned column=0;column<8;++column) {
#pragma HLS UNROLL
    dot.w[column]=in.w[column]; scale.sw_half[column]=in.sw_half[column];
  }
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    dot.old_ps[lane]=in.old_ps[lane];
  }
}

inline void make_products(const DotBank& in, Products& out) {
#pragma HLS INLINE off
  out.context.tag = in.tag;
  for (unsigned lane=0; lane<32; ++lane) {
#pragma HLS UNROLL
    out.context.old_ps[lane] = in.old_ps[lane];
    const unsigned row=lane/8, column=lane%8;
    for (unsigned k=0; k<32; ++k) {
#pragma HLS UNROLL
      const ap_int<8> av=in.a[row].range(8*k+7,8*k);
      const ap_int<8> wv=in.w[column].range(8*k+7,8*k);
      ap_int<16> product=av*wv;
#pragma HLS BIND_OP variable=product op=mul impl=dsp latency=1
      out.value[lane][k]=product;
    }
  }
}

inline void reduce_tree1(const Products& in, Tree1& out) {
#pragma HLS INLINE off
  out.context=in.context;
  for (unsigned lane=0; lane<32; ++lane) {
#pragma HLS UNROLL
    for (unsigned k=0;k<16;++k) {
#pragma HLS UNROLL
      out.value[lane][k]=ap_int<17>(in.value[lane][2*k])+
                         ap_int<17>(in.value[lane][2*k+1]);
    }
  }
}
template <unsigned IN_W, unsigned IN_COUNT>
inline void reduce_tree(const Tree<IN_W,IN_COUNT>& in,
                        Tree<IN_W+1,IN_COUNT/2>& out) {
#pragma HLS INLINE off
  static_assert(IN_COUNT>=2 && IN_COUNT%2==0, "binary tree only");
  out.context=in.context;
  for (unsigned lane=0; lane<32; ++lane) {
#pragma HLS UNROLL
    for (unsigned k=0;k<IN_COUNT/2;++k) {
#pragma HLS UNROLL
      out.value[lane][k]=ap_int<IN_W+1>(in.value[lane][2*k])+
                         ap_int<IN_W+1>(in.value[lane][2*k+1]);
    }
  }
}

inline void decode_scales(const ScaleBank& in, ScaleDecoded& out) {
#pragma HLS INLINE off
  out.tag=in.tag;
  for (unsigned row=0;row<4;++row) {
#pragma HLS UNROLL
    out.sa[row]=half_to_f32_bits(uint16_t(in.sa_half[row]));
  }
  for (unsigned column=0;column<8;++column) {
#pragma HLS UNROLL
    out.sw[column]=half_to_f32_bits(uint16_t(in.sw_half[column]));
  }
}
inline void multiply_scales(const ScaleDecoded& in, ScaleProducts& out) {
#pragma HLS INLINE off
  out.tag=in.tag;
  out.scale_bad=0; out.product_bad=0;
  out.trace_sa=0; out.trace_sw=0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    const uint32_t sa=uint32_t(in.sa[lane/8]);
    const uint32_t sw=uint32_t(in.sw[lane%8]);
    const float product=f32(sa)*f32(sw);
    const uint32_t raw=bits(product);
    out.product[lane]=raw;
    out.scale_bad[lane]=!nonnegative_finite(sa) ||
                        !nonnegative_finite(sw);
    out.product_bad[lane]=!finite(raw);
    if (in.tag.trace_reserved && lane==unsigned(in.tag.trace_lane)) {
      out.trace_sa=sa; out.trace_sw=sw;
    }
  }
}
inline void convert_dot(const Tree5& in, DotConverted& out) {
#pragma HLS INLINE off
  out.context=in.context;
  out.trace_dot=0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    const int32_t dot=int32_t(in.value[lane][0]);
    out.dot_f32[lane]=bits(float(dot));
    if (in.context.tag.trace_reserved &&
        lane==unsigned(in.context.tag.trace_lane))
      out.trace_dot=uint32_t(dot);
  }
}
inline bool join_dot_scale(const DotConverted& dot,
                           const ScaleProducts& scale, TermInput& out) {
#pragma HLS INLINE off
  out.alignment_fault=!same_tag(dot.context.tag,scale.tag);
  if (out.alignment_fault) {
    out.tag=dot.context.tag;
    out.tag.valid=0;
    return false;
  }
  out.tag=dot.context.tag;
  out.scale_bad=scale.scale_bad;
  out.product_bad=scale.product_bad;
  out.trace_sa=scale.trace_sa; out.trace_sw=scale.trace_sw;
  out.trace_dot=dot.trace_dot;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    out.old_ps[lane]=dot.context.old_ps[lane];
    out.dot_f32[lane]=dot.dot_f32[lane];
    out.scale_product[lane]=scale.product[lane];
  }
  return true;
}
inline void multiply_term(const TermInput& in, TermOutput& out) {
#pragma HLS INLINE off
  out.alignment_fault=in.alignment_fault;
  if (in.alignment_fault) { out.tag=in.tag; return; }
  out.tag=in.tag;
  out.scale_bad=in.scale_bad;
  out.product_bad=in.product_bad;
  out.term_bad=0;
  out.trace_sa=in.trace_sa; out.trace_sw=in.trace_sw;
  out.trace_dot=in.trace_dot;
  out.trace_product=0; out.trace_term=0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    const uint32_t product=uint32_t(in.scale_product[lane]);
    const uint32_t raw=bits(f32(uint32_t(in.dot_f32[lane]))*f32(product));
    out.term[lane]=raw;
    out.old_ps[lane]=in.old_ps[lane];
    out.term_bad[lane]=!finite(raw);
    if (in.tag.trace_reserved && lane==unsigned(in.tag.trace_lane)) {
      out.trace_product=product; out.trace_term=raw;
    }
  }
}
inline void add_ps(const TermOutput& in, AddOutput& out) {
#pragma HLS INLINE off
  out.alignment_fault=in.alignment_fault;
  if (in.alignment_fault) { out.tag=in.tag; return; }
  out.tag=in.tag;
  out.scale_bad=in.scale_bad; out.product_bad=in.product_bad;
  out.term_bad=in.term_bad; out.next_bad=0;
  out.trace_sa=in.trace_sa; out.trace_sw=in.trace_sw;
  out.trace_dot=in.trace_dot; out.trace_product=in.trace_product;
  out.trace_term=in.trace_term; out.trace_next=0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    const uint32_t old=in.tag.g==0 ? 0 : uint32_t(in.old_ps[lane]);
    const uint32_t raw=bits(f32(old)+f32(uint32_t(in.term[lane])));
    out.next[lane]=raw;
    out.next_bad[lane]=!finite(raw);
    if (in.tag.trace_reserved && lane==unsigned(in.tag.trace_lane))
      out.trace_next=raw;
  }
}
inline void classify(const AddOutput& in, FinalReturn& out) {
#pragma HLS INLINE off
  out.alignment_fault=in.alignment_fault;
  out.valid=in.tag.valid && !in.alignment_fault;
  if (in.alignment_fault) return;
  c1::ResultPayload& result=out.result;
  result.seq=in.tag.seq; result.m0=in.tag.m0; result.g=in.tag.g;
  result.tile=in.tag.tile; result.last_g=in.tag.last_g;
  result.result_slot=in.tag.result_slot;
  result.trace_reserved=in.tag.trace_reserved;
  result.trace_slot=in.tag.trace_slot;
  result.shape_mask=in.tag.shape_mask;
  result.active_mask=in.tag.shape_mask & ~in.tag.bad_mask;
  result.success_mask=0; result.failure_mask=0;
  result.error_valid=0; result.error_key=0;
  result.error_bad_element=0; result.active_dot_count=0;
  out.trace_payload=0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    result.next_ps[lane]=0;
    if (!result.active_mask[lane]) continue;
    result.active_dot_count=result.active_dot_count+1;
    const unsigned phase=in.scale_bad[lane] ? 0 :
                         in.product_bad[lane] ? 1 :
                         in.term_bad[lane] ? 2 :
                         in.next_bad[lane] ? 3 : 4;
    const unsigned row=unsigned(in.tag.m0)+lane/8;
    const unsigned column=lane%8;
    if (phase==4) {
      result.success_mask[lane]=1;
      result.next_ps[lane]=in.next[lane];
    } else {
      result.failure_mask[lane]=1;
      const ap_uint<28> key=c1::error_key(in.tag.tile,row,column,
                                          in.tag.g,phase);
      if (!result.error_valid || key<result.error_key) {
        result.error_valid=1;
        result.error_key=key;
        const uint64_t n=uint64_t(unsigned(in.tag.tile))*8+column;
        result.error_bad_element=uint64_t(row)*5248*128+n*128+
                                 unsigned(in.tag.g);
      }
    }
    if (in.tag.trace_reserved && lane==unsigned(in.tag.trace_lane)) {
      out.trace_payload.range(31,0)=in.trace_dot;
      out.trace_payload.range(63,32)=in.trace_sa;
      out.trace_payload.range(95,64)=in.trace_sw;
      out.trace_payload.range(127,96)=in.trace_product;
      out.trace_payload.range(159,128)=in.trace_term;
      out.trace_payload.range(191,160)=in.trace_next;
      out.trace_payload.range(223,192)=in.tag.g;
      out.trace_payload.range(255,224)=1;
    }
  }
}

}  // namespace c1_stage
