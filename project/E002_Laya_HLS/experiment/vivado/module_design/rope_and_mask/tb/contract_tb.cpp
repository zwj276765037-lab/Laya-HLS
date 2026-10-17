#include "contract_test.h"
#include "rope_and_mask.h"
int main(){using namespace laya;RopeTask t;t.ctx=test::ctx(Op::ROPE,2,0);t.src_qkv_ref={test::ref(Buffer::QKV,0),test::ref(Buffer::QKV,1)};t.dst_qkv_ref={test::ref(Buffer::QKV,0,2),test::ref(Buffer::QKV,1,2)};uint32_t out=0;test::require(rope_and_mask::validate(t,2,128,out)&&out==128,"both QKV shards");t.dst_qkv_ref[1].bank=0;test::require(!rope_and_mask::validate(t,2,128,out),"shard not ping-pong");}
