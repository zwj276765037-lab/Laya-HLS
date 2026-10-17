#include "embedding_engine.h"
namespace laya::embedding_engine {
Check validate(const EmbeddingTask& t,uint16_t B,uint16_t S){
  Check c=check_context(t.ctx,B,S);if(!c)return c;
  c=check_ref(t.dst);if(!c)return c;
  bool token=t.ctx.op==Op::EMB_TOKEN&&t.ctx.stage==1&&t.ctx.row_space==RowSpace::TOKEN&&t.table==0&&t.type_id==255&&t.dst.id==Buffer::HIDDEN;
  bool type=t.ctx.op==Op::EMB_TYPE&&t.ctx.stage==3&&t.ctx.row_space==RowSpace::BATCH&&t.table==1&&t.type_id<3&&t.dst.id==Buffer::TYPE_ROWS;
  return token||type?ok():Check{Status::E_SHAPE,detail(7,uint8_t(t.ctx.op),5)};
}
}
