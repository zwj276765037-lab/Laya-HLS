#include "forward_controller.h"
#include <algorithm>

namespace laya {
namespace {Check bad(Buffer b,uint16_t reason=9){return {Status::E_BUFFER,detail(4,uint8_t(b),reason)};}}
BufferRecord* ForwardController::find(BufferRef r,uint8_t region){auto it=records_.find({r.id,r.bank,region});return it==records_.end()?nullptr:&it->second;}
const BufferRecord* ForwardController::find(BufferRef r,uint8_t region)const{auto it=records_.find({r.id,r.bank,region});return it==records_.end()?nullptr:&it->second;}
bool ForwardController::alias_busy(Buffer b)const{
  Buffer other=b==Buffer::WI?Buffer::DEC_FF:Buffer::WI;
  for(const auto& [key,record]:records_)if(key.id==other&&record.state!=CacheState::FREE&&record.state!=CacheState::INVALID)return true;
  return false;
}
Check ForwardController::accept_task(uint32_t id){if(active_||!id||id>kMaxEpoch||id<=last_task_)return {Status::E_PROTOCOL,detail(7,0,14)};active_=id;return ok();}
Check ForwardController::retire_task(const TaskDone& done,uint32_t elements,OutputUnit unit){
  if(!active_)return {Status::E_PROTOCOL,detail(7,0,14)};
  Check c=check_done(done,active_,elements,unit);if(!c)return c;
  last_task_=active_;active_=0;return ok();
}
Check ForwardController::reserve(BufferRef r,uint8_t region,uint16_t rows,Content content){
  Check c=check_ref(r,region);if(!c||r.id==Buffer::NONE||rows==0)return bad(r.id,4);
  if((r.id==Buffer::WI||r.id==Buffer::DEC_FF)&&alias_busy(r.id))return bad(r.id);
  BufferRecord& m=records_[{r.id,r.bank,region}];
  if(m.state!=CacheState::FREE&&m.state!=CacheState::INVALID)return bad(r.id);
  if(r.epoch!=m.epoch+1||r.epoch>kMaxEpoch)return bad(r.id);
  m.epoch=r.epoch;m.next_epoch=0;m.state=CacheState::FILL;m.content=content;m.covered.assign(rows,false);m.readers=0;m.type_readers.fill(0);m.drained=false;m.type_bits=0;return ok();
}
Check ForwardController::cover(BufferRef r,uint8_t region,uint16_t first,uint16_t count){
  if(r.id==Buffer::TYPE_ROWS)return bad(r.id);
  BufferRecord* m=find(r,region);
  bool filling=m&&m->state==CacheState::FILL&&r.epoch==m->epoch;
  bool inplace=m&&m->state==CacheState::EXCLUSIVE_RW&&r.epoch==m->next_epoch;
  if(!m||(!filling&&!inplace)||!count||uint32_t(first)+count>m->covered.size())return bad(r.id);
  for(uint32_t i=first;i<uint32_t(first)+count;i++)if(m->covered[i])return bad(r.id,12);
  for(uint32_t i=first;i<uint32_t(first)+count;i++)m->covered[i]=true;
  return ok();
}
Check ForwardController::publish(BufferRef r,uint8_t region,bool drained){
  if(r.id==Buffer::TYPE_ROWS)return bad(r.id);
  BufferRecord* m=find(r,region);if(!m||r.epoch!=m->epoch||m->state!=CacheState::FILL||!drained||!std::all_of(m->covered.begin(),m->covered.end(),[](bool x){return x;}))return bad(r.id);
  m->state=CacheState::READY;m->drained=true;return ok();
}
Check ForwardController::expect_ready(BufferRef r,uint8_t region,Content expected)const{
  if(r.id==Buffer::TYPE_ROWS)return bad(r.id);
  const BufferRecord* m=find(r,region);
  if(!m||r.epoch!=m->epoch||(m->state!=CacheState::READY&&m->state!=CacheState::READ)||m->content!=expected)return bad(r.id);
  return ok();
}
Check ForwardController::acquire_read(BufferRef r,uint8_t region,Content expected){
  Check c=expect_ready(r,region,expected);if(!c)return c;
  BufferRecord* m=find(r,region);if(m->readers==UINT8_MAX)return bad(r.id,12);m->state=CacheState::READ;m->readers++;return ok();
}
Check ForwardController::release_read(BufferRef r,uint8_t region){if(r.id==Buffer::TYPE_ROWS)return bad(r.id);BufferRecord* m=find(r,region);if(!m||r.epoch!=m->epoch||m->state!=CacheState::READ||!m->readers)return bad(r.id);if(--m->readers==0)m->state=CacheState::READY;return ok();}
Check ForwardController::acquire_type_read(BufferRef r,uint8_t type_id){
  BufferRecord* m=find(r,0);
  if(r.id!=Buffer::TYPE_ROWS||type_id>=3||!m||m->epoch!=r.epoch||(m->state!=CacheState::READY&&m->state!=CacheState::READ)||!(m->type_bits&(1u<<type_id))||m->readers==UINT8_MAX||m->type_readers[type_id]==UINT8_MAX)return bad(r.id);
  m->state=CacheState::READ;m->readers++;m->type_readers[type_id]++;return ok();
}
Check ForwardController::release_type_read(BufferRef r,uint8_t type_id){
  BufferRecord* m=find(r,0);
  if(r.id!=Buffer::TYPE_ROWS||type_id>=3||!m||m->epoch!=r.epoch||m->state!=CacheState::READ||!m->readers||!m->type_readers[type_id])return bad(r.id);
  --m->type_readers[type_id];if(--m->readers==0)m->state=CacheState::READY;
  return ok();
}
Check ForwardController::validate_inputs(const LinearTask& t)const{
  Check c=expect_ready(t.a,0,Content::Q8_TILE);if(!c)return c;
  return expect_ready(t.w,0,Content::Q8_WEIGHT);
}
Check ForwardController::validate_inputs(const QKTask& t)const{
  for(const BufferRef& r:t.qkv_ref){Check c=expect_ready(r,0,Content::QKV_FINAL);if(!c)return c;}
  return expect_ready(t.kv,0,Content::F32);
}
Check ForwardController::validate_inputs(const AVTask& t)const{
  Check c=expect_ready(t.prob,0,Content::PROB);if(!c)return c;
  return expect_ready(t.kv,0,Content::F32);
}
Check ForwardController::release_storage(BufferRef r,uint8_t region){
  BufferRecord* m=find(r,region);
  if(!m||r.epoch!=m->epoch||m->state!=CacheState::READY||m->readers)return bad(r.id);
  m->state=CacheState::FREE;
  m->covered.clear();
  m->content=Content::UNDEFINED;
  m->type_bits=0;
  m->type_readers.fill(0);
  m->drained=false;
  return ok();
}
Check ForwardController::begin_inplace(BufferRef old_ref,BufferRef new_ref,uint8_t region,uint16_t rows,Content new_content){
  if(old_ref.id==Buffer::TYPE_ROWS||!check_ref(old_ref,region)||!check_ref(new_ref,region)||old_ref.id!=new_ref.id||old_ref.bank!=new_ref.bank||new_ref.epoch!=old_ref.epoch+1||!rows)return bad(old_ref.id);
  BufferRecord* m=find(old_ref,region);if(!m||m->epoch!=old_ref.epoch||m->state!=CacheState::READY||m->readers)return bad(old_ref.id);
  if((new_content==Content::QKV_FINAL&&(old_ref.id!=Buffer::QKV||m->content!=Content::QKV_RAW))||
     (new_content==Content::PROB&&(old_ref.id!=Buffer::SCORE_PROB||m->content!=Content::SCORE)))return bad(old_ref.id);
  m->state=CacheState::EXCLUSIVE_RW;m->next_epoch=new_ref.epoch;m->content=new_content;m->covered.assign(rows,false);m->drained=false;return ok();
}
Check ForwardController::publish_inplace(BufferRef r,uint8_t region,bool drained){
  BufferRecord* m=find(r,region);if(!m||m->state!=CacheState::EXCLUSIVE_RW||m->next_epoch!=r.epoch||!drained||!std::all_of(m->covered.begin(),m->covered.end(),[](bool x){return x;}))return bad(r.id);
  m->epoch=r.epoch;m->next_epoch=0;m->state=CacheState::READY;m->drained=true;return ok();
}
Check ForwardController::type_row(BufferRef r,uint8_t type_id){
  BufferRecord* m=find(r,0);if(r.id!=Buffer::TYPE_ROWS||!m||m->epoch!=r.epoch||type_id>=3||(m->state!=CacheState::FILL&&m->state!=CacheState::READY)||m->type_bits&(1u<<type_id))return bad(r.id);
  m->type_bits|=uint8_t(1u<<type_id);m->state=CacheState::READY;return ok();
}
bool ForwardController::type_valid(BufferRef r,uint8_t type_id)const{const BufferRecord* m=find(r,0);return r.id==Buffer::TYPE_ROWS&&m&&m->epoch==r.epoch&&type_id<3&&(m->state==CacheState::READY||m->state==CacheState::READ)&&(m->type_bits&(1u<<type_id));}
bool ForwardController::ready(BufferRef r,uint8_t region)const{
  // TYPE_ROWS is only readable through type_valid() for the requested type id.
  if(r.id==Buffer::TYPE_ROWS)return false;
  const BufferRecord* m=find(r,region);
  return m&&m->epoch==r.epoch&&(m->state==CacheState::READY||m->state==CacheState::READ);
}
void ForwardController::reset(){active_=0;last_task_=0;for(auto& [key,m]:records_){m.state=CacheState::INVALID;m.epoch=std::max(m.epoch,m.next_epoch);m.next_epoch=0;m.readers=0;m.type_readers.fill(0);m.covered.clear();m.type_bits=0;m.drained=false;}}
}
