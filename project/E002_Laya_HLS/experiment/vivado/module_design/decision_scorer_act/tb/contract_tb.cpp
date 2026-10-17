#include "contract_test.h"
#include "decision_scorer_act.h"
int main(){using namespace laya;StatsTask t;t.ctx=test::ctx(Op::CAND_STATS,6,255,RowSpace::BATCH);t.probs=test::ref(Buffer::HEAD_WORK);t.stats=test::ref(Buffer::HEAD_WORK);t.valid_options=2;uint32_t out=0;test::require(decision_scorer_act::validate(t,2,128,out)&&out==4,"four stats");t.valid_options=0;test::require(!decision_scorer_act::validate(t,2,128,out),"at least one option");
  ConcatActTask c;c.ctx=test::ctx(Op::CONCAT_ACT,6,255,RowSpace::BATCH);c.hidden=test::ref(Buffer::HIDDEN);c.stats=test::ref(Buffer::HEAD_WORK);c.dst=test::ref(Buffer::HEAD_WORK);test::require(decision_scorer_act::validate(c,2,128,out)&&out==1028,"act 1028");}
