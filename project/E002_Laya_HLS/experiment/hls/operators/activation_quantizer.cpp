#include "activation_quantizer.h"
namespace laya::activation_quantizer {
Check validate(const QuantTask& t,uint16_t B,uint16_t S,uint32_t& groups){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  c=check_ref(t.src,t.src_region);if(!c)return c;c=check_ref(t.a_dst);if(!c)return c;
  if(t.ctx.op!=Op::QUANT||t.src.id==Buffer::NONE||t.a_dst.id!=Buffer::A8||t.input_lanes!=8)return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  bool valid=false;
  if(t.ctx.stage==2&&t.ctx.row_space==RowSpace::TOKEN){
    valid=(t.K==1024&&(t.src.id==Buffer::HIDDEN||t.src.id==Buffer::NORM||t.src.id==Buffer::ATT_OUT))||(t.K==2624&&t.src.id==Buffer::GATE);
  }else if(t.ctx.stage==4&&t.ctx.row_space==RowSpace::TOKEN){
    valid=(t.K==1024&&(t.src.id==Buffer::HIDDEN||t.src.id==Buffer::NORM||t.src.id==Buffer::ATT_OUT))||(t.K==4096&&t.src.id==Buffer::DEC_FF);
  }else if(t.ctx.stage==5&&t.ctx.row_space==RowSpace::MARKER){
    valid=t.K==1024&&t.src.id==Buffer::HEAD_WORK&&t.src_region==uint8_t(Region::SCORER_ACT);
  }else if(t.ctx.stage==6&&t.ctx.row_space==RowSpace::BATCH){
    valid=t.K==256&&t.src.id==Buffer::HEAD_WORK&&t.src_region==uint8_t(Region::ACT_HIDDEN);
  }
  if(!valid)return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  groups=uint32_t(t.ctx.rows)*(t.K/32);
  return ok();
}
}
