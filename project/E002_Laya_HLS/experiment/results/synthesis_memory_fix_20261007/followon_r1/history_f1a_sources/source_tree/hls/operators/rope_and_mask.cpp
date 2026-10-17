#include "rope_and_mask.h"
namespace laya::rope_and_mask {
Check validate(const RopeTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::ROPE||t.ctx.stage!=2||t.head>=16||t.mode>1||t.table_set!=t.mode||t.mode!=(t.ctx.layer%3==0?0:1))return {Status::E_SHAPE,detail(7,0x40,5)};
  for(unsigned i=0;i<2;i++){
    BufferRef old=t.src_qkv_ref[i],next=t.dst_qkv_ref[i];
    if(!check_ref(old)||!check_ref(next)||old.id!=Buffer::QKV||next.id!=Buffer::QKV||old.bank!=i||next.bank!=i||next.epoch!=old.epoch+1||next.epoch>kMaxEpoch)return {Status::E_BUFFER,detail(4,5,9)};
  }
  outputs=uint32_t(t.ctx.rows)*2*64;return ok();
}
}
