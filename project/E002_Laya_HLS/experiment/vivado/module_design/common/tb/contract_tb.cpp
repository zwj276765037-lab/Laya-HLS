#include "contract_test.h"
#include "laya_types.h"
int main(){using namespace laya;F32Beat b{};b.task_id=7;b.epoch=4;b.row=1;b.col=0;b.valid_count=8;b.data[0]=0x80000000;
  auto p=pack(b);F32Beat got;test::require(unpack(p,got),"F32 unpack");test::require(got.data[0]==0x80000000,"signed zero bits");
  p[44]|=0x80;test::require(!unpack(p,got),"padding bit rejected");
  WiPairBeat w{};w.task_id=7;w.epoch=4;w.pair_count=4;w.col=2620;w.row_last=w.task_last=true;test::require(check_beat(w,0),"WiPair last");w.pair_count=8;test::require(!check_beat(w,0),"pair count differs from F32 count");
  Q8Group q{};q.q[0]=-127;q.scale_bits=0xfc00;q.task_id=1;q.epoch=1;q.row_last=q.tile_last=true;auto qp=pack(q);Q8Group g;test::require(unpack(qp,g)&&g.q[0]==-127&&g.scale_bits==0xfc00,"Q8 original bits");test::require(check_group(g,1,1),"Q8 last");
  TaskContext io=test::ctx(Op::IO_VALIDATE,0,255,RowSpace::BATCH);test::require(check_context(io,2,128),"IO validation stage0");io.stage=7;test::require(!check_context(io,2,128),"IO validation cannot run at stage7");
  TaskContext commit=test::ctx(Op::RESULT_COMMIT,7,255,RowSpace::BATCH);test::require(check_context(commit,2,128),"result commit stage7");commit.stage=0;test::require(!check_context(commit,2,128),"result commit cannot run at stage0");
}
