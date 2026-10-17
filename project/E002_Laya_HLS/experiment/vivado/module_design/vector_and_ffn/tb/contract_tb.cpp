#include "contract_test.h"
#include "vector_and_ffn.h"
int main(){using namespace laya;VectorTask t;t.ctx=test::ctx(Op::GEGLU,2,1);t.src0=test::ref(Buffer::WI);t.src1=none();t.dst=test::ref(Buffer::GATE);t.length=2624;uint32_t out=0;test::require(vector_and_ffn::validate(t,2,128,out)&&out==2624,"GEGLU pairs");t.length=5248;test::require(!vector_and_ffn::validate(t,2,128,out),"pairs not all Wi features");
  t.length=2624;t.bias_id=0;test::require(!vector_and_ffn::validate(t,2,128,out),"unused bias sentinel");
  VectorTask residual;residual.ctx=test::ctx(Op::ADD_RESIDUAL,2,1);residual.dst=test::ref(Buffer::HIDDEN,1);residual.length=1024;test::require(!vector_and_ffn::validate(residual,2,128,out),"residual both sources required");residual.src0=test::ref(Buffer::TMP);residual.src1=test::ref(Buffer::HIDDEN,0);test::require(vector_and_ffn::validate(residual,2,128,out),"TMP plus old H to other bank");residual.dst.bank=0;test::require(!vector_and_ffn::validate(residual,2,128,out),"old hidden cannot be overwritten");
  VectorTask mask;mask.ctx=test::ctx(Op::APPLY_CAND_MASK,5,255,RowSpace::BATCH);mask.src0=test::ref(Buffer::HEAD_WORK);mask.src0_region=uint8_t(Region::CAND_RAW);mask.src1=none();mask.dst=test::ref(Buffer::HEAD_WORK);mask.dst_region=uint8_t(Region::CAND_MASKED);mask.length=16;
  test::require(vector_and_ffn::validate(mask,2,128,out)&&out==16,"candidate mask one batch vector");
  mask.ctx.row_space=RowSpace::MARKER;test::require(!vector_and_ffn::validate(mask,2,128,out),"marker rows cannot mask candidates");
  mask.ctx.row_space=RowSpace::BATCH;mask.ctx.rows=2;test::require(!vector_and_ffn::validate(mask,2,128,out),"multiple candidate rows denied");
}
