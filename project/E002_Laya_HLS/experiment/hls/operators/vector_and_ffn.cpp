#include "vector_and_ffn.h"
namespace laya::vector_and_ffn {
Check validate(const VectorTask& t,uint16_t B,uint16_t S,uint32_t& outputs,uint16_t expected_bias_id){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(!check_ref(t.src0,t.src0_region)||!check_ref(t.src1,t.src1_region)||!check_ref(t.dst,t.dst_region))return {Status::E_BUFFER,detail(4,0,9)};
  uint16_t length=0;
  switch(t.ctx.op){
    case Op::GEGLU:
      length=2624;
      if(t.ctx.stage!=2||t.ctx.row_space!=RowSpace::TOKEN||t.src0.id!=Buffer::WI||t.src1!=none()||t.dst.id!=Buffer::GATE)return {Status::E_SHAPE,detail(7,0x60,5)};
      break;
    case Op::RELU:
      length=4096;
      if(t.ctx.stage!=4||t.ctx.row_space!=RowSpace::TOKEN||t.src0.id!=Buffer::DEC_FF||t.src1!=none()||t.dst.id!=Buffer::DEC_FF||t.dst.epoch!=t.src0.epoch+1)return {Status::E_SHAPE,detail(7,0x61,5)};
      break;
    case Op::ADD_RESIDUAL:
      length=1024;
      if((t.ctx.stage!=2&&t.ctx.stage!=4)||t.ctx.row_space!=RowSpace::TOKEN||t.src0.id!=Buffer::TMP||t.src1.id!=Buffer::HIDDEN||t.dst.id!=Buffer::HIDDEN||t.dst.bank==t.src1.bank)return {Status::E_SHAPE,detail(7,0x62,5)};
      break;
    case Op::ADD_TYPE:
      length=1024;
      if(t.ctx.stage!=3||t.ctx.row_space!=RowSpace::TOKEN||t.src0.id!=Buffer::HIDDEN||t.src1.id!=Buffer::TYPE_ROWS||t.dst.id!=Buffer::HIDDEN||t.dst.bank==t.src0.bank)return {Status::E_SHAPE,detail(7,0x63,5)};
      break;
    case Op::BIAS_GELU_SCORER:
      length=1024;
      if(t.ctx.stage!=5||t.ctx.row_space!=RowSpace::MARKER||t.src0.id!=Buffer::HEAD_WORK||t.src0_region!=uint8_t(Region::SCORER_ACT)||t.src1!=none()||t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=t.src0_region||t.dst.epoch!=t.src0.epoch+1)return {Status::E_SHAPE,detail(7,0x64,5)};
      break;
    case Op::BIAS_GELU_ACT:
      length=256;
      if(t.ctx.stage!=6||t.ctx.row_space!=RowSpace::BATCH||t.src0.id!=Buffer::HEAD_WORK||t.src0_region!=uint8_t(Region::ACT_HIDDEN)||t.src1!=none()||t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=t.src0_region||t.dst.epoch!=t.src0.epoch+1)return {Status::E_SHAPE,detail(7,0x65,5)};
      break;
    case Op::APPLY_CAND_MASK:
      length=16;
      if(t.ctx.stage!=5||t.ctx.row_space!=RowSpace::BATCH||t.ctx.row0!=0||t.ctx.rows!=1||t.src0.id!=Buffer::HEAD_WORK||t.src0_region!=uint8_t(Region::CAND_RAW)||t.src1!=none()||t.dst.id!=Buffer::HEAD_WORK||t.dst_region!=uint8_t(Region::CAND_MASKED))return {Status::E_SHAPE,detail(7,0x66,5)};
      break;
    default:return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  }
  if(t.length!=length)return {Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
  bool needs_bias=t.ctx.op==Op::BIAS_GELU_SCORER||t.ctx.op==Op::BIAS_GELU_ACT;
  if(needs_bias){
    // A real expected index will come from the frozen model export. P0 callers may
    // pass a separately verified protocol-test binding; no index is invented here.
    if(expected_bias_id==65535||t.bias_id!=expected_bias_id)return {Status::E_BUFFER,detail(4,0,4)};
  }else if(t.bias_id!=65535)return {Status::E_BUFFER,detail(4,0,4)};
  outputs=uint32_t(t.ctx.rows)*length;return ok();
}
}
