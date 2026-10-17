#include "numeric_test_support.h"
#include <iostream>
using namespace laya;

int main() {
  const NumericIdentity id = test_identity();
  struct Shape { uint8_t family, stage; Op op; Buffer dst; uint16_t K, N; };
  const Shape shapes[] = {
    {12,6,Op::LIN_ACT_FC2,Buffer::HEAD_WORK,256,2},
    {1,2,Op::LIN_QKV,Buffer::QKV,1024,3072},
    {2,2,Op::LIN_WO,Buffer::TMP,1024,1024},
    {3,2,Op::LIN_WI,Buffer::WI,1024,5248},
    {4,2,Op::LIN_DOWN,Buffer::TMP,2624,1024},
    {7,4,Op::LIN_DEC_FC1,Buffer::DEC_FF,1024,4096},
    {8,4,Op::LIN_DEC_FC2,Buffer::TMP,4096,1024},
    {5,4,Op::LIN_QKV,Buffer::QKV,1024,3072},
    {6,4,Op::LIN_WO,Buffer::TMP,1024,1024},
    {9,5,Op::LIN_SCORER_FC1,Buffer::HEAD_WORK,1024,1024}
  };
  int8_t aq[16][128][32] = {}, wq[8][128][32] = {};
  uint16_t as[16][128] = {}, ws[8][128] = {};
  float bias[8] = {}, y[16][8] = {};
  for (unsigned r=0;r<16;++r) for(unsigned g=0;g<128;++g) {
    as[r][g]=0x3c00;
    for(unsigned k=0;k<32;++k) aq[r][g][k]=1;
  }
  for(unsigned c=0;c<8;++c) {
    bias[c]=1.25f;
    for(unsigned g=0;g<128;++g) {
      ws[c][g]=0x3c00;
      for(unsigned k=0;k<32;++k) wq[c][g][k]=1;
    }
  }
  unsigned cases=0;
  for(const auto& shape:shapes) {
    LinearTask t;
    const uint8_t layer=shape.stage>=5?255:0;
    const uint8_t rows=shape.stage==6?1:shape.family==3?16:4;
    t.ctx={5,shape.op,shape.stage,layer,0,
           shape.stage==6?RowSpace::BATCH:shape.stage==5?RowSpace::MARKER:RowSpace::TOKEN,0,rows};
    t.a={Buffer::A8,0,9};t.w={Buffer::WEIGHT,0,7};
    t.ps={Buffer::PS,0,11};t.dst={shape.dst,0,13};
    t.weight={shape.family,layer};t.K=shape.K;t.N=shape.N;t.bias_kind=shape.stage>=4;
    t.dst_region=shape.stage==6?uint8_t(Region::ACT_LOGITS):0;
    const uint16_t n0=shape.N<8?0:shape.N-8;
    const uint8_t cols=shape.N<8?shape.N:8;
    for(auto& row:y)for(auto& value:row)value=-999;
    Check c=q8_linear_owned_window_arithmetic(t,id,n0,cols,aq,as,wq,ws,bias,y);
    nrequire(bool(c),"owned seven-shape success");
    for(unsigned r=0;r<rows;++r)for(unsigned lane=0;lane<cols;++lane)
      nrequire(y[r][lane]==float(shape.K)+(t.bias_kind?1.25f:0.0f),"independent exact integer sum and final bias");
    if(rows<16)nrequire(y[rows][0]==-999,"inactive row guard");
    const unsigned late=shape.K/32-1;
    ws[cols-1][late]=0x7c00;
    c=q8_linear_owned_window_arithmetic(t,id,n0,cols,aq,as,wq,ws,bias,y);
    nrequire(c.code==Status::E_NUMERICAL &&
             c.bad_element==uint64_t(n0+cols-1)*128+late,
             "late group failure chooses original row/col rank");
    ws[cols-1][late]=0x3c00;
    c=q8_linear_owned_window_arithmetic(t,id,n0,cols,aq,as,wq,ws,bias,y);
    nrequire(bool(c),"subsequent owned call recovery");
    ++cases;
    std::cout<<"ACT_TM4_OWNED_SHAPE_PASS K="<<shape.K<<" N="<<shape.N
             <<" rows="<<unsigned(rows)<<" last_tile="<<n0/8<<'\n';
  }
  std::cout<<"TM4_OWNED_SHAPES_PASS unique_shapes=7 families="<<cases
           <<" full_owner_bits=1024 rows16=1 late_error_recovery=10\n";
}
