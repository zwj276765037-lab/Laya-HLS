#include "laya_io.h"
#include "laya_memory_map.h"
#include "forward_controller.h"
#include "hbm_loader_and_cache.h"
#include "laya_forward.h"
#include "contract_test.h"
#include <array>
#include <iostream>
#define CHECK(expr) test::require((expr), #expr)

int main(){
  using namespace laya;
  F32Beat b{};b.data[0]=0x7fc00001;b.task_id=1;b.epoch=1;b.row=0;b.col=1024;b.valid_count=4;b.row_last=true;b.task_last=true;
  auto packed=pack(b);F32Beat u{};CHECK(unpack(packed,u));CHECK(u.data[0]==b.data[0]);CHECK(check_beat(u,1028,0));packed[44]|=0x40;CHECK(!unpack(packed,u));
  Q8Group g{};g.q[0]=-128;g.scale_bits=0x3c00;g.task_id=1;g.epoch=1;g.row_last=g.tile_last=true;auto qp=pack(g);Q8Group gu{};CHECK(unpack(qp,gu));CHECK(gu.q[0]==-128&&gu.scale_bits==0x3c00);CHECK(check_group(gu,1,1));
  Address a{};CHECK(qkv_address(2,1,15,1023,63,2,1024,a));CHECK(a.offset==12582908);CHECK(!qkv_address(2,1,15,1024,0,2,1024,a));
  CHECK(f32_address({Buffer::HIDDEN,1,1},0,1,1023,1023,2,1024,a));CHECK(a.offset==8388604);
  uint16_t row=0;CHECK(marker_token_row(135,1,128,row)&&row==1031);CHECK(!marker_token_row(127,1,128,row));
  ForwardController fc;BufferRef old{Buffer::SCORE_PROB,0,1},next{Buffer::SCORE_PROB,0,2};
  CHECK(fc.reserve(old,0,2,Content::SCORE));CHECK(fc.cover(old,0,0,1));CHECK(!fc.publish(old,0,true));CHECK(fc.cover(old,0,1,1));CHECK(fc.publish(old,0,true));
  CHECK(fc.begin_inplace(old,next,0,2,Content::PROB));CHECK(!fc.ready(old,0));CHECK(fc.cover(next,0,0,2));CHECK(fc.publish_inplace(next,0,true));CHECK(fc.ready(next,0));
  CHECK(!fc.acquire_read(old,0,Content::PROB));CHECK(fc.release_storage(next,0));
  CHECK(!forward_available());for(const auto& m:kModules)CHECK(!m.numerical_implemented);
  hbm_loader_and_cache::MemTransfer mt{};mt.task_id=1;mt.bo=Bo::EMBEDDING;mt.offset=4000;mt.byte_count=1088;mt.cache={Buffer::WEIGHT,0,1};std::vector<hbm_loader_and_cache::MemTransfer> chunks;
  CHECK(hbm_loader_and_cache::segment(mt,1u<<20,1u<<20,chunks));CHECK(chunks.size()==2&&chunks[0].byte_count==96&&chunks[1].byte_count==992);
  std::cout<<"CONTRACT_CORE_PASS\n";
}
