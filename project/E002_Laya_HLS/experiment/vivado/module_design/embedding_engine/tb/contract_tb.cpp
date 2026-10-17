#include "contract_test.h"
#include "embedding_engine.h"
int main(){using namespace laya;EmbeddingTask t;t.ctx=test::ctx(Op::EMB_TOKEN,1);t.dst=test::ref(Buffer::HIDDEN);test::require(embedding_engine::validate(t,2,128),"token embedding contract");t.type_id=2;test::require(!embedding_engine::validate(t,2,128),"token type sentinel");t.ctx=test::ctx(Op::EMB_TYPE,3,255,RowSpace::BATCH);t.dst=test::ref(Buffer::TYPE_ROWS);t.table=1;test::require(embedding_engine::validate(t,2,128),"type embedding contract");}
