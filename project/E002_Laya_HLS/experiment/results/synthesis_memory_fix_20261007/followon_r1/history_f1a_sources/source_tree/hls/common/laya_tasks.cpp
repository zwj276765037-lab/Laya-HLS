#include "laya_tasks.h"

namespace laya {
namespace {
Check bad(uint8_t reason=4){return {Status::E_PROTOCOL,detail(7,0,reason)};}
bool valid_op(Op op){
  switch(op){
    case Op::EMB_TOKEN:case Op::EMB_TYPE:case Op::LN_EMB:case Op::LN_ATTN:case Op::LN_FFN:case Op::LN_FINAL:case Op::LN_MARKER:
    case Op::QUANT:case Op::LIN_QKV:case Op::LIN_WO:case Op::LIN_WI:case Op::LIN_DOWN:case Op::LIN_DEC_FC1:case Op::LIN_DEC_FC2:
    case Op::LIN_SCORER_FC1:case Op::LIN_ACT_FC2:case Op::ROPE:case Op::QK:case Op::SOFTMAX_ATT:case Op::AV:
    case Op::FP_SCORER_FC2:case Op::FP_ACT_FC1:case Op::SOFTMAX_CAND:case Op::GEGLU:case Op::RELU:
    case Op::ADD_RESIDUAL:case Op::ADD_TYPE:case Op::BIAS_GELU_SCORER:case Op::BIAS_GELU_ACT:case Op::APPLY_CAND_MASK:
    case Op::GATHER_MARKER:case Op::CAND_STATS:case Op::CONCAT_ACT:case Op::LOAD_W:case Op::LOAD_KV:
    case Op::LOAD_LN_PARAMS:case Op::LOAD_ROPE:case Op::IO_VALIDATE:case Op::RESULT_COMMIT:return true;
  }
  return false;
}
}
Check check_context(const TaskContext& c,uint16_t B,uint16_t S){
  bool legal_s=S==64||S==128||S==256||S==512||S==1024;
  if(!valid_op(c.op)||!c.task_id||c.task_id>kMaxEpoch||B<1||B>2||!legal_s||c.stage>7||c.rows<1||c.rows>16||c.batch>=B)return bad();
  if(c.row_space==RowSpace::TOKEN){if(uint32_t(c.row0)+c.rows>S)return bad(5);}
  else if(c.row_space==RowSpace::MARKER){if(uint32_t(c.row0)+c.rows>16)return bad(5);}
  else if(c.row_space==RowSpace::BATCH){if(c.row0||c.rows!=1)return bad(5);}
  else return bad();
  const bool control = c.op==Op::LOAD_W || c.op==Op::LOAD_KV || c.op==Op::LOAD_LN_PARAMS || c.op==Op::LOAD_ROPE || c.op==Op::IO_VALIDATE || c.op==Op::RESULT_COMMIT;
  if(c.stage==2&&(c.layer>27||(!control&&c.row_space!=RowSpace::TOKEN)))return bad(5);
  if(c.stage==4&&(c.layer>1||(!control&&c.row_space!=RowSpace::TOKEN)))return bad(5);
  if(control&&(c.row_space!=RowSpace::BATCH||c.batch!=0||c.row0||c.rows!=1))return bad(5);
  if((c.op==Op::IO_VALIDATE&&c.stage!=0)||(c.op==Op::RESULT_COMMIT&&c.stage!=7))return bad(5);
  if(c.stage!=2&&c.stage!=4&&c.layer!=255)return bad(5);
  return ok();
}
Check check_ref(BufferRef r,uint8_t region){
  if(r.id==Buffer::NONE)return r.bank==0&&r.epoch==0&&region==0?ok():Check{Status::E_BUFFER,detail(4,0,9)};
  if(r.epoch==0||r.epoch>kMaxEpoch)return {Status::E_BUFFER,detail(4,uint8_t(r.id),9)};
  uint8_t id=uint8_t(r.id);bool valid=(id>=1&&id<=11)||(id>=0x20&&id<=0x2b);
  if(!valid)return {Status::E_BUFFER,detail(4,id,4)};
  bool dual=id==1||id==5||(id>=0x20&&id<=0x2b&&id!=0x2a&&id!=0x2b);
  if(id==0x2a||id==0x2b)dual=true;
  if(r.bank>(dual?1:0))return {Status::E_BUFFER,detail(4,id,4)};
  if(id==10){if(region>7)return {Status::E_BUFFER,detail(4,id,4)};}
  else if(region)return {Status::E_BUFFER,detail(4,id,4)};
  return ok();
}
Check check_weight(WeightKey w,uint8_t stage,uint8_t layer,uint16_t K,uint16_t N,bool fp){
  const uint8_t f=w.family;
  if(f<1||f>12)return {Status::E_BUFFER,detail(4,0,4)};
  uint16_t ek=0,en=0;
  switch(f){case 1:case 5:ek=1024;en=3072;break;case 2:case 6:ek=1024;en=1024;break;case 3:ek=1024;en=5248;break;case 4:ek=2624;en=1024;break;case 7:ek=1024;en=4096;break;case 8:ek=4096;en=1024;break;case 9:ek=1024;en=1024;break;case 10:ek=1024;en=1;break;case 11:ek=1028;en=256;break;case 12:ek=256;en=2;break;}
  if(K!=ek||N!=en||((f==10||f==11)!=fp))return {Status::E_SHAPE,detail(4,f,5)};
  if(f<=4){if(stage!=2||layer>27||w.layer!=layer)return {Status::E_BUFFER,detail(4,f,4)};}
  else if(f<=8){if(stage!=4||layer>1||w.layer!=layer)return {Status::E_BUFFER,detail(4,f,4)};}
  else{if(w.layer!=255||stage!=(f==9||f==10?5:6)||layer!=255)return {Status::E_BUFFER,detail(4,f,4)};}
  return ok();
}
Check check_done(const TaskDone& d,uint32_t id,uint32_t elems,OutputUnit unit){
  if(d.task_id!=id||!d.drained||uint8_t(d.output_unit)>3)return bad(14);
  if(d.status==Status::OK){if(d.error_detail||d.bad_element!=UINT64_MAX||d.output_elements!=elems||d.output_unit!=unit)return bad(12);}
  else if(uint16_t(d.status)>8)return bad(4);
  return ok();
}
}
