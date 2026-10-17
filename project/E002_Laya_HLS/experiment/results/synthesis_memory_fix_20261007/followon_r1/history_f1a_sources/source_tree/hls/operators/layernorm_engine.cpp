#include "layernorm_engine.h"
namespace laya::layernorm_engine {
Check validate(const LayerNormTask& t,uint16_t B,uint16_t S){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(!check_ref(t.src)||!check_ref(t.dst)||t.src.id==Buffer::NONE||t.dst.id==Buffer::NONE||t.D!=1024||t.eps_bits!=0x3727c5ac||(t.src.id==t.dst.id&&t.src.bank==t.dst.bank))return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  bool valid=false;
  switch(t.ctx.op){
    case Op::LN_EMB:
      valid=t.ctx.stage==1&&t.ctx.row_space==RowSpace::TOKEN&&t.gamma==1&&t.src.id==Buffer::HIDDEN&&
            (t.dst.id==Buffer::NORM||(t.dst.id==Buffer::HIDDEN&&t.dst.bank!=t.src.bank));
      break;
    case Op::LN_ATTN:
      valid=(t.ctx.stage==2||t.ctx.stage==4)&&t.ctx.row_space==RowSpace::TOKEN&&t.gamma==0&&
            !(t.ctx.stage==2&&t.ctx.layer==0)&&t.src.id==Buffer::HIDDEN&&t.dst.id==Buffer::NORM;
      break;
    case Op::LN_FFN:
      valid=(t.ctx.stage==2||t.ctx.stage==4)&&t.ctx.row_space==RowSpace::TOKEN&&t.gamma==0&&
            t.src.id==Buffer::HIDDEN&&t.dst.id==Buffer::NORM;
      break;
    case Op::LN_FINAL:
      valid=t.ctx.stage==3&&t.ctx.row_space==RowSpace::TOKEN&&t.gamma==2&&t.src.id==Buffer::HIDDEN&&
            (t.dst.id==Buffer::NORM||(t.dst.id==Buffer::HIDDEN&&t.dst.bank!=t.src.bank));
      break;
    case Op::LN_MARKER:
      valid=t.ctx.stage==5&&t.ctx.row_space==RowSpace::MARKER&&t.gamma==0&&
            t.src.id==Buffer::MARKER&&t.dst.id==Buffer::HEAD_WORK;
      break;
    default:break;
  }
  return valid?ok():Check{Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
}
}
