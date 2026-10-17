#include "decision_scorer_act.h"
namespace laya::decision_scorer_act {
namespace {Check bad(Op op){return {Status::E_SHAPE,detail(7,uint8_t(op),5)};}}
Check validate(const GatherTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::GATHER_MARKER||t.ctx.stage!=5||t.ctx.row_space!=RowSpace::MARKER||t.ctx.row0||t.ctx.rows!=16||t.columns!=16||t.hidden.id!=Buffer::HIDDEN||t.markers.id!=Buffer::MARKER||!check_ref(t.hidden)||!check_ref(t.markers))return bad(t.ctx.op);
  outputs=16*1024;return ok();
}
Check validate(const StatsTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::CAND_STATS||t.ctx.stage!=6||t.ctx.row_space!=RowSpace::BATCH||t.valid_options<1||t.valid_options>16||t.probs.id!=Buffer::HEAD_WORK||t.stats.id!=Buffer::HEAD_WORK||t.prob_region!=6||t.stats_region!=5||!check_ref(t.probs,t.prob_region)||!check_ref(t.stats,t.stats_region))return bad(t.ctx.op);
  outputs=4;return ok();
}
Check validate(const ConcatActTask& t,uint16_t B,uint16_t S,uint32_t& outputs){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  if(t.ctx.op!=Op::CONCAT_ACT||t.ctx.stage!=6||t.ctx.row_space!=RowSpace::BATCH||t.hidden.id!=Buffer::HIDDEN||t.stats.id!=Buffer::HEAD_WORK||t.dst.id!=Buffer::HEAD_WORK||t.stats_region!=5||t.dst_region!=1||!check_ref(t.hidden)||!check_ref(t.stats,t.stats_region)||!check_ref(t.dst,t.dst_region))return bad(t.ctx.op);
  outputs=1028;return ok();
}
}
