#include "attention_and_fp_engine.h"
namespace laya::attention_and_fp_engine {
namespace {Check bad(Op op){return {Status::E_SHAPE,detail(7,uint8_t(op),5)};}}
Check validate(const QKTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::QK||(t.ctx.stage!=2&&t.ctx.stage!=4)||t.ctx.row_space!=RowSpace::TOKEN||t.head>=16||t.S!=S||t.mask_mode>1||t.scale_bits!=0x3e000000||t.kv.id!=Buffer::KV||t.score.id!=Buffer::SCORE_PROB)return bad(t.ctx.op);
  if((t.ctx.stage==4&&t.mask_mode!=0)||(t.ctx.stage==2&&t.mask_mode!=(t.ctx.layer%3==0?0:1)))return bad(t.ctx.op);
  for(unsigned i=0;i<2;i++)if(!check_ref(t.qkv_ref[i])||t.qkv_ref[i].id!=Buffer::QKV||t.qkv_ref[i].bank!=i)return {Status::E_BUFFER,detail(4,5,4)};
  if(!check_ref(t.kv)||!check_ref(t.score))return {Status::E_BUFFER,detail(4,0,9)};
  outputs=uint32_t(t.ctx.rows)*S;return ok();
}
Check validate(const SoftmaxTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(!check_ref(t.src,t.src_region)||!check_ref(t.dst,t.dst_region))return {Status::E_BUFFER,detail(4,0,9)};
  if(t.ctx.op==Op::SOFTMAX_ATT){
    if((t.ctx.stage!=2&&t.ctx.stage!=4)||t.ctx.row_space!=RowSpace::TOKEN||t.mode!=0||t.length!=S||t.src.id!=Buffer::SCORE_PROB||t.dst.id!=Buffer::SCORE_PROB||t.src.bank!=t.dst.bank||t.dst.epoch!=t.src.epoch+1)return bad(t.ctx.op);
  }else if(t.ctx.op==Op::SOFTMAX_CAND){
    if(t.ctx.stage!=6||t.ctx.row_space!=RowSpace::BATCH||t.mode!=1||t.length!=16||t.src.id!=Buffer::HEAD_WORK||t.dst.id!=Buffer::HEAD_WORK||t.src_region!=uint8_t(Region::CAND_MASKED)||t.dst_region!=uint8_t(Region::CAND_PROB))return bad(t.ctx.op);
  }else return bad(t.ctx.op);
  outputs=uint32_t(t.ctx.rows)*t.length;return ok();
}
Check validate(const AVTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::AV||(t.ctx.stage!=2&&t.ctx.stage!=4)||t.ctx.row_space!=RowSpace::TOKEN||t.S!=S||t.head>=16||t.prob.id!=Buffer::SCORE_PROB||t.kv.id!=Buffer::KV||t.partial.id!=Buffer::AV_PARTIAL||t.dst.id!=Buffer::ATT_OUT)return bad(t.ctx.op);
  if(!check_ref(t.prob)||!check_ref(t.kv)||!check_ref(t.partial)||!check_ref(t.dst))return {Status::E_BUFFER,detail(4,0,9)};
  outputs=uint32_t(t.ctx.rows)*64;return ok();
}
Check validate(const FPLinearTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(!check_ref(t.src,t.src_region)||!check_ref(t.dst,t.dst_region))return {Status::E_BUFFER,detail(4,0,9)};
  uint8_t family=0;
  if(t.ctx.op==Op::FP_SCORER_FC2&&t.ctx.stage==5&&t.ctx.row_space==RowSpace::MARKER)family=10;
  if(t.ctx.op==Op::FP_ACT_FC1&&t.ctx.stage==6&&t.ctx.row_space==RowSpace::BATCH)family=11;
  if(!family||t.weight.family!=family)return bad(t.ctx.op);
  if(family==10&&(t.src.id!=Buffer::HEAD_WORK||t.src_region!=uint8_t(Region::SCORER_ACT)||t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=uint8_t(Region::CAND_RAW)))return bad(t.ctx.op);
  if(family==11&&(t.src.id!=Buffer::HEAD_WORK||t.src_region!=uint8_t(Region::ACT_INPUT)||t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=uint8_t(Region::ACT_HIDDEN)))return bad(t.ctx.op);
  c=check_weight(t.weight,t.ctx.stage,t.ctx.layer,t.K,t.N,true);if(!c)return c;
  outputs=uint32_t(t.ctx.rows)*t.N;return ok();
}
}
