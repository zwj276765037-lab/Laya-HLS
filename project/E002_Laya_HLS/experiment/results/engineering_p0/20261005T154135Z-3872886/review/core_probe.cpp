#include "forward_controller.h"
#include "layernorm_engine.h"
#include "activation_quantizer.h"
#include "q8_linear_and_restore.h"
#include "attention_and_fp_engine.h"
#include "vector_and_ffn.h"
#include "hbm_loader_and_cache.h"
#include <iostream>
#include <cstdlib>
using namespace laya;
BufferRef r(Buffer b,uint8_t bank=0){return {b,bank,1};}
TaskContext ctx(Op op,uint8_t stage,uint8_t layer=255,RowSpace rs=RowSpace::TOKEN,uint8_t rows=1){return {1,op,stage,layer,0,rs,0,rows};}
unsigned checks=0;
void need(bool good,const char* label){++checks;if(!good){std::cerr<<"REVIEW_FAIL "<<label<<'\n';std::exit(1);}}
int main(){
 ForwardController f;auto type=r(Buffer::TYPE_ROWS);
 need(bool(f.reserve(type,0,3,Content::F32)),"type reserve");
 need(bool(f.type_row(type,2)),"type2 fill");
 need(!f.acquire_read(type,0,Content::F32),"generic type denied");
 need(!f.acquire_type_read(type,1),"unloaded type denied");
 need(bool(f.type_row(type,1)),"type1 fill");
 need(bool(f.acquire_type_read(type,2)),"type2 lock");
 need(!f.release_type_read(type,1),"wrong type release denied");
 need(!f.release_read(type,0),"generic release denied");
 need(!f.type_row(type,0),"reader prevents fill");
 need(bool(f.release_type_read(type,2)),"correct release");
 f.reset();
 need(!f.type_valid(type,2),"reset type invalid");
 need(!f.reserve(type,0,3,Content::F32),"old epoch reuse denied");
 type.epoch=2;need(bool(f.reserve(type,0,3,Content::F32)),"next epoch accepted");
 LayerNormTask ln;ln.ctx=ctx(Op::LN_EMB,1);ln.src=none();ln.dst=r(Buffer::NORM);ln.gamma=1;
 need(!layernorm_engine::validate(ln,2,128),"LN NONE denied");
 ln.src=r(Buffer::WI);ln.dst=r(Buffer::DEC_FF);
 need(!layernorm_engine::validate(ln,2,128),"LN alias denied");
 ln.src=r(Buffer::HIDDEN);ln.dst=r(Buffer::HIDDEN,1);
 need(bool(layernorm_engine::validate(ln,2,128)),"LN different hidden bank");
 uint32_t n=0;uint8_t tail=0;
 QuantTask q;q.ctx=ctx(Op::QUANT,6,255,RowSpace::TOKEN,16);q.src=none();q.a_dst=r(Buffer::A8);q.K=4096;
 need(!activation_quantizer::validate(q,2,128,n),"act invalid quant denied");
 q.ctx=ctx(Op::QUANT,4,0);q.src=r(Buffer::ATT_OUT);q.K=1024;
 need(bool(activation_quantizer::validate(q,2,128,n))&&n==32,"decision AV quant accepted");
 LinearTask li;li.ctx=ctx(Op::LIN_WI,2,1);li.a=r(Buffer::A8);li.w=r(Buffer::WEIGHT);li.ps=r(Buffer::PS);li.dst=none();li.weight={3,1};li.K=1024;li.N=5248;
 need(!q8_linear_and_restore::validate(li,2,128,n,tail),"Linear NONE dest denied");
 VectorTask v;v.ctx=ctx(Op::ADD_RESIDUAL,2,1);v.src0=none();v.src1=none();v.dst=r(Buffer::HIDDEN);v.length=1024;
 need(!vector_and_ffn::validate(v,2,128,n),"residual NONE sources denied");
 v.ctx=ctx(Op::APPLY_CAND_MASK,5,255,RowSpace::BATCH);v.src0=r(Buffer::HEAD_WORK);v.src0_region=7;v.src1=none();v.dst=r(Buffer::HEAD_WORK);v.dst_region=3;v.length=16;
 need(bool(vector_and_ffn::validate(v,2,128,n))&&n==16,"mask BATCH 16 accepted");
 v.ctx=ctx(Op::APPLY_CAND_MASK,5,255,RowSpace::MARKER,16);
 need(!vector_and_ffn::validate(v,2,128,n),"mask marker 256 denied");
 SoftmaxTask sm;sm.ctx=ctx(Op::SOFTMAX_CAND,6,255,RowSpace::TOKEN,16);sm.src=r(Buffer::HEAD_WORK);sm.dst=r(Buffer::HEAD_WORK);sm.length=16;sm.mode=1;sm.src_region=3;sm.dst_region=6;
 need(!attention_and_fp_engine::validate(sm,2,128,n),"candidate 16 TOKEN rows denied");
 QKTask qk;qk.ctx=ctx(Op::QK,2,1);qk.qkv_ref={r(Buffer::QKV),r(Buffer::QKV,1)};qk.kv=r(Buffer::KV);qk.score=r(Buffer::SCORE_PROB);qk.S=128;qk.mask_mode=0;
 need(!attention_and_fp_engine::validate(qk,2,128,n),"encoder1 full mode denied");
 qk.mask_mode=1;need(bool(attention_and_fp_engine::validate(qk,2,128,n)),"encoder1 slide accepted");
 LoadTask ld;ld.ctx=ctx(Op::LOAD_KV,0,255,RowSpace::BATCH);ld.kind=1;ld.dst=r(Buffer::KV);ld.head=0;ld.planes=3;ld.byte_count=2*2*128*64*4;
 need(!hbm_loader_and_cache::validate(ld,2,128),"stage0 KV load denied");
 std::cout<<"ASTRA_REVIEW_PROBE_PASS checks="<<checks<<'\n';
}
