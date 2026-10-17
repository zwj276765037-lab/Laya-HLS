#include "q8_linear_and_restore.h"
namespace laya::q8_linear_and_restore {
Check validate(const LinearTask& t,uint16_t B,uint16_t S,uint32_t& outputs,uint8_t& tail){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(!check_ref(t.a)||!check_ref(t.w)||!check_ref(t.ps)||!check_ref(t.dst,t.dst_region))return {Status::E_BUFFER,detail(4,0,9)};
  if(t.a.id!=Buffer::A8||t.w.id!=Buffer::WEIGHT||t.ps.id!=Buffer::PS||t.bias_kind>1)return {Status::E_BUFFER,detail(4,0,4)};
  uint8_t family=0;
  switch(t.ctx.op){
    case Op::LIN_QKV:family=t.ctx.stage==2?1:t.ctx.stage==4?5:0;break;
    case Op::LIN_WO:family=t.ctx.stage==2?2:t.ctx.stage==4?6:0;break;
    case Op::LIN_WI:family=t.ctx.stage==2?3:0;break;
    case Op::LIN_DOWN:family=t.ctx.stage==2?4:0;break;
    case Op::LIN_DEC_FC1:family=t.ctx.stage==4?7:0;break;
    case Op::LIN_DEC_FC2:family=t.ctx.stage==4?8:0;break;
    case Op::LIN_SCORER_FC1:family=t.ctx.stage==5?9:0;break;
    case Op::LIN_ACT_FC2:family=t.ctx.stage==6?12:0;break;
    default:break;
  }
  if(!family||t.weight.family!=family||t.dst.id==Buffer::NONE)return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  if((t.ctx.stage==5&&t.ctx.row_space!=RowSpace::MARKER)||(t.ctx.stage==6&&t.ctx.row_space!=RowSpace::BATCH)||((t.ctx.stage==2||t.ctx.stage==4)&&t.ctx.row_space!=RowSpace::TOKEN))return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  c=check_weight(t.weight,t.ctx.stage,t.ctx.layer,t.K,t.N);if(!c)return c;
  if(t.ctx.op==Op::LIN_QKV&&t.dst.id!=Buffer::QKV)return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  if((t.ctx.op==Op::LIN_WO||t.ctx.op==Op::LIN_DOWN||t.ctx.op==Op::LIN_DEC_FC2)&&t.dst.id!=Buffer::TMP)return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  if(t.ctx.op==Op::LIN_WI&&t.dst.id!=Buffer::WI)return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  if(t.ctx.op==Op::LIN_DEC_FC1&&t.dst.id!=Buffer::DEC_FF)return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  if(t.ctx.op==Op::LIN_SCORER_FC1&&(t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=uint8_t(Region::SCORER_ACT)))return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  if(t.ctx.op==Op::LIN_ACT_FC2&&(t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=uint8_t(Region::ACT_LOGITS)))return {Status::E_BUFFER,detail(4,uint8_t(t.dst.id),4)};
  outputs=uint32_t(t.ctx.rows)*t.N;tail=uint8_t(t.N%8?t.N%8:8);
  return ok();
}
}
