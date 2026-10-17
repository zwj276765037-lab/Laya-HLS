#include "hbm_loader_and_cache.h"
#include <algorithm>

namespace laya::hbm_loader_and_cache {
namespace {Check bad(uint16_t reason=4){return {Status::E_BUFFER,detail(4,0,reason)};}}
Check validate(const LoadTask& t,uint16_t B,uint16_t S){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.row_space!=RowSpace::BATCH||t.ctx.row0||t.ctx.rows!=1||t.ctx.batch!=0)return bad(5);
  if(t.kind>3||uint8_t(t.ctx.op)!=uint8_t(Op::LOAD_W)+t.kind)return bad(4);
  c=check_ref(t.dst);if(!c)return c;
  if(t.kind==0){
    if(t.dst.id!=Buffer::WEIGHT||t.head!=255||t.planes||t.weight.family==0||t.weight.family==10||t.weight.family==11)return bad();
    uint16_t K=0,N=0;
    switch(t.weight.family){case 1:case 5:K=1024;N=3072;break;case 2:case 6:K=1024;N=1024;break;case 3:K=1024;N=5248;break;case 4:K=2624;N=1024;break;case 7:K=1024;N=4096;break;case 8:K=4096;N=1024;break;case 9:K=1024;N=1024;break;case 12:K=256;N=2;break;default:return bad();}
    c=check_weight(t.weight,t.ctx.stage,t.ctx.layer,K,N);if(!c)return c;
    uint32_t bytes=((N+7u)/8u)*8u*(K/32u)*34u;
    return t.byte_count==bytes?ok():bad(8);
  }
  if(t.weight.family||t.weight.layer!=255)return bad();
  if(t.kind==1)return (t.ctx.stage==2||t.ctx.stage==4)&&t.dst.id==Buffer::KV&&t.head<16&&t.planes==3&&t.byte_count==2u*B*S*64u*4u?ok():bad(5);
  if(t.kind==2)return t.dst.id==Buffer::LN_GAMMA&&t.head==255&&!t.planes&&t.byte_count==4096&&((t.ctx.stage==1&&t.dst.bank==0)||(t.ctx.stage==3&&t.dst.bank==1))?ok():bad(5);
  return t.dst.id==Buffer::ROPE_TABLE&&t.ctx.stage==2&&t.head==255&&!t.planes&&t.byte_count==2u*1025u*64u*4u&&t.dst.bank==(t.ctx.layer%3==0?0:1)?ok():bad(5);
}
Check segment(const MemTransfer& in,uint32_t bo_capacity,uint32_t cache_capacity,std::vector<MemTransfer>& out){
  if(!in.task_id||in.task_id>kMaxEpoch||uint8_t(in.bo)>=kBoCount||!in.byte_count||uint64_t(in.offset)+in.byte_count>bo_capacity||uint64_t(in.cache_offset)+in.byte_count>cache_capacity||!check_ref(in.cache))return bad(8);
  uint64_t first=std::min<uint64_t>(in.byte_count,4096u-(in.offset&4095u));
  uint64_t remaining=in.byte_count-first;
  uint64_t segment_count=1+(remaining+4095)/4096;
  if(segment_count>65536)return bad(8);
  out.clear();uint32_t done=0,seq=0;
  while(done<in.byte_count){
    uint32_t offset=in.offset+done,remain=in.byte_count-done;
    uint32_t chunk=std::min({remain,4096u,4096u-(offset&4095u)});
    MemTransfer s=in;s.segment=uint16_t(seq++);s.offset=offset;s.cache_offset=in.cache_offset+done;s.byte_count=chunk;done+=chunk;s.last_segment=done==in.byte_count;out.push_back(s);
  }
  return ok();
}
}
