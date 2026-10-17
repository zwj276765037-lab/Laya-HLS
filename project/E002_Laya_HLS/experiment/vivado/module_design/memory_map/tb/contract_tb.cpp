#include "contract_test.h"
#include "laya_memory_map.h"
int main(){using namespace laya;Address a;Span s;
  test::require(span(test::ref(Buffer::HEAD_WORK),uint8_t(Region::CAND_PROB),s)&&s.base==16777216+141632&&s.bytes==128,"CAND_PROB span");
  test::require(!byte_address(test::ref(Buffer::HEAD_WORK),uint8_t(Region::CAND_PROB),128,4,a),"region bound");
  test::require(qkv_address(2,1,15,1023,63,2,1024,a)&&a.bo==Bo::QKV1&&a.offset==12582908,"QKV final byte");
  test::require(!qkv_address(2,1,15,1024,0,2,1024,a),"QKV first overflow");
  test::require(f32_address(test::ref(Buffer::HIDDEN,1),0,1,1023,1023,2,1024,a)&&a.offset==8388604,"hidden final byte");
  uint16_t row;test::require(marker_token_row(135,1,128,row)&&row==1031,"marker 135");
  for(auto m:std::array<uint32_t,3>{147,163,174})test::require(marker_token_row(m,1,128,row)&&row==1024+(m-128),"real marker rebasing");
  Q8Descriptor d;d.K=1024;d.N=2;d.q_span={8192,8192};d.scale_span=1024;d.q_base={64,128};d.scale_base=192;Address q,sc;test::require(q8_weight_addresses(d,1,31,q,sc)&&q.offset==64+63&&sc.offset==194,"Q8 shard formula");}
