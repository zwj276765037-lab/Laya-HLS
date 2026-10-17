#include "contract_test.h"
#include "hbm_loader_and_cache.h"
int main(){using namespace laya;using namespace laya::hbm_loader_and_cache;MemTransfer m{};m.task_id=1;m.bo=Bo::EMBEDDING;m.offset=4000;m.byte_count=1088;m.cache=test::ref(Buffer::WEIGHT);std::vector<MemTransfer> parts;
  test::require(segment(m,8192,8192,parts)&&parts.size()==2,"4K crossing split");test::require(parts[0].byte_count==96&&parts[1].byte_count==992&&parts[1].last_segment,"length conservation");
  m.offset=UINT32_MAX-10;test::require(!segment(m,UINT32_MAX,8192,parts),"overflow rejected");
  LoadTask load;load.ctx=test::ctx(Op::LOAD_KV,0,255,RowSpace::BATCH);load.kind=1;load.dst=test::ref(Buffer::KV);load.head=0;load.planes=3;load.byte_count=2*2*128*64*4;test::require(!validate(load,2,128),"LOAD_KV cannot use stage0");
  load.ctx=test::ctx(Op::LOAD_KV,2,1,RowSpace::BATCH);test::require(validate(load,2,128),"LOAD_KV encoder stage");}
