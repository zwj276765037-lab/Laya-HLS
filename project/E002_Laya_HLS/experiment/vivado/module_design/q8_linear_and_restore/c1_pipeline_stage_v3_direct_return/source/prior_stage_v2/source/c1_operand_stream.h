#pragma once

#include "c1_operand_stages.h"
#include "hls_stream.h"

// Dataflow intent is explicit. Each stream has depth one and carries only
// unfinished operands/tags. The caller must provide concurrent bank service
// and final reserved-slot return actors. No wrapper latency/II is assumed.
namespace c1_stage {

inline void split_actor(hls::stream<BankReturn>& input,
                        hls::stream<DotBank>& dots,
                        hls::stream<ScaleBank>& scales, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    BankReturn in=input.read();
    DotBank dot;
    ScaleBank scale;
    split_bank_return(in,dot,scale);
    dots.write(dot);
    scales.write(scale);
  }
}
inline void products_actor(hls::stream<DotBank>& input,
                           hls::stream<Products>& output, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    DotBank in=input.read();
    Products out;
    make_products(in,out);
    output.write(out);
  }
}
inline void tree1_actor(hls::stream<Products>& input,
                        hls::stream<Tree1>& output, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    Products in=input.read();
    Tree1 out;
    reduce_tree1(in,out);
    output.write(out);
  }
}
template <unsigned IN_W, unsigned IN_COUNT>
inline void tree_actor(hls::stream<Tree<IN_W,IN_COUNT>>& input,
                       hls::stream<Tree<IN_W+1,IN_COUNT/2>>& output,
                       unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    Tree<IN_W,IN_COUNT> in=input.read();
    Tree<IN_W+1,IN_COUNT/2> out;
    reduce_tree(in,out);
    output.write(out);
  }
}
inline void convert_actor(hls::stream<Tree5>& input,
                          hls::stream<DotConverted>& output,
                          unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    Tree5 in=input.read();
    DotConverted out;
    convert_dot(in,out);
    output.write(out);
  }
}
inline void decode_actor(hls::stream<ScaleBank>& input,
                         hls::stream<ScaleDecoded>& output,
                         unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    ScaleBank in=input.read();
    ScaleDecoded out;
    decode_scales(in,out);
    output.write(out);
  }
}
inline void scale_actor(hls::stream<ScaleDecoded>& input,
                        hls::stream<ScaleProducts>& output,
                        unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    ScaleDecoded in=input.read();
    ScaleProducts out;
    multiply_scales(in,out);
    output.write(out);
  }
}
inline void join_actor(hls::stream<DotConverted>& dots,
                       hls::stream<ScaleProducts>& scales,
                       hls::stream<TermInput>& output, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    DotConverted dot=dots.read();
    ScaleProducts scale=scales.read();
    TermInput out;
    join_dot_scale(dot,scale,out);
    output.write(out);
  }
}
inline void term_actor(hls::stream<TermInput>& input,
                       hls::stream<TermOutput>& output, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    TermInput in=input.read();
    TermOutput out;
    multiply_term(in,out);
    output.write(out);
  }
}
inline void add_actor(hls::stream<TermOutput>& input,
                      hls::stream<AddOutput>& output, unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    TermOutput in=input.read();
    AddOutput out;
    add_ps(in,out);
    output.write(out);
  }
}
inline void classify_actor(hls::stream<AddOutput>& input,
                           hls::stream<FinalReturn>& output,
                           unsigned count) {
#pragma HLS INLINE off
  for (unsigned i=0;i<count;++i) {
#pragma HLS PIPELINE II=1
    AddOutput in=input.read();
    FinalReturn out;
    classify(in,out);
    output.write(out);
  }
}

inline void run_operand_pipeline(hls::stream<BankReturn>& bank_returns,
                                 hls::stream<FinalReturn>& final_returns,
                                 unsigned count) {
#pragma HLS INLINE off
#pragma HLS DATAFLOW
  hls::stream<DotBank> dot_bank("dot_bank");
  hls::stream<ScaleBank> scale_bank("scale_bank");
  hls::stream<Products> product("product");
  hls::stream<Tree1> tree1("tree1");
  hls::stream<Tree2> tree2("tree2");
  hls::stream<Tree3> tree3("tree3");
  hls::stream<Tree4> tree4("tree4");
  hls::stream<Tree5> tree5("tree5");
  hls::stream<DotConverted> dot_converted("dot_converted");
  hls::stream<ScaleDecoded> decoded("decoded");
  hls::stream<ScaleProducts> scale_product("scale_product");
  hls::stream<TermInput> term_input("term_input");
  hls::stream<TermOutput> term_output("term_output");
  hls::stream<AddOutput> add_output("add_output");
#pragma HLS STREAM variable=dot_bank depth=1
#pragma HLS STREAM variable=scale_bank depth=1
#pragma HLS STREAM variable=product depth=1
#pragma HLS STREAM variable=tree1 depth=1
#pragma HLS STREAM variable=tree2 depth=1
#pragma HLS STREAM variable=tree3 depth=1
#pragma HLS STREAM variable=tree4 depth=1
#pragma HLS STREAM variable=tree5 depth=1
#pragma HLS STREAM variable=dot_converted depth=1
#pragma HLS STREAM variable=decoded depth=1
#pragma HLS STREAM variable=scale_product depth=1
#pragma HLS STREAM variable=term_input depth=1
#pragma HLS STREAM variable=term_output depth=1
#pragma HLS STREAM variable=add_output depth=1
  split_actor(bank_returns,dot_bank,scale_bank,count);
  products_actor(dot_bank,product,count);
  tree1_actor(product,tree1,count);
  tree_actor<17,16>(tree1,tree2,count);
  tree_actor<18,8>(tree2,tree3,count);
  tree_actor<19,4>(tree3,tree4,count);
  tree_actor<20,2>(tree4,tree5,count);
  convert_actor(tree5,dot_converted,count);
  decode_actor(scale_bank,decoded,count);
  scale_actor(decoded,scale_product,count);
  join_actor(dot_converted,scale_product,term_input,count);
  term_actor(term_input,term_output,count);
  add_actor(term_output,add_output,count);
  classify_actor(add_output,final_returns,count);
}

}  // namespace c1_stage
