#include "quant16.h"
#include "laya_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <limits>
#include <memory>
#include <vector>

namespace {
using namespace laya;
using namespace laya::quant16;

void require(bool okay, const char* message) {
  if (!okay) { std::fprintf(stderr,"QUANT16_FAIL %s\n",message); std::exit(1); }
}

std::vector<uint8_t> load(const char* path) {
  std::ifstream in(path,std::ios::binary);
  require(bool(in),"input file open");
  return {std::istreambuf_iterator<char>(in),std::istreambuf_iterator<char>()};
}

uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id=3; id.generation=1; id.B=1; id.S=128;
  for (unsigned i=0;i<16;++i) {
    id.model_tag[i]=1; id.numeric_tag[i]=2;
    id.layout_tag[i]=3; id.build_tag[i]=4;
  }
  return id;
}

Task task(unsigned K, Buffer source_buffer, uint8_t slot=0) {
  Task t;
  t.identity=identity();
  t.context={1,Op::QUANT,2,0,0,RowSpace::TOKEN,0,1};
  t.source={source_buffer,0,1};
  t.destination={Buffer::A8,slot,1};
  t.K=K; t.destination_slot=slot;
  return t;
}

F32TileMeta source(const Task& t) {
  F32TileMeta meta;
  meta.identity=t.identity; meta.ref=t.source;
  meta.region=t.source_region;
  meta.row_space=t.context.row_space;
  meta.batch=t.context.batch; meta.row0=t.context.row0;
  meta.rows=t.context.rows; meta.K=t.K;
  numeric_cover_all(meta.covered_groups,t.context.rows,t.K/32,16);
  meta.state=CacheState::READY; meta.content=Content::F32; meta.valid=true;
  return meta;
}

std::vector<Beat> beats(const Task& t, const uint8_t* raw) {
  std::vector<Beat> result(t.context.rows*t.K/16);
  unsigned next=0;
  for (unsigned r=0;r<t.context.rows;++r)
    for (unsigned g=0;g<t.K/32;++g)
      for (unsigned half=0;half<2;++half) {
        Beat& b=result[next++];
        b.task_id=t.context.task_id; b.source_epoch=t.source.epoch;
        b.row=t.context.row0+r; b.group=g; b.half=half;
        b.valid_mask=0xffff;
        for (unsigned lane=0;lane<16;++lane)
          b.bits[lane]=le32(raw+4*(r*t.K+g*32+half*16+lane));
      }
  return result;
}

void real_case(unsigned K, Buffer src, const char* source_file,
               const char* q_file, const char* scale_file) {
  const auto raw=load(source_file), expected_q=load(q_file),
             expected_scale=load(scale_file);
  require(raw.size()>=K*4 && expected_q.size()>=K &&
          expected_scale.size()>=(K/32)*2,"real fixture length");
  Task t=task(K,src);
  F32TileMeta src_meta=source(t);
  auto b=beats(t,raw.data());
  auto output=std::make_unique<AStore>();
  std::memset(output->q[1],0x5a,sizeof(output->q[1]));
  Check c=run(t,src_meta,b.data(),*output);
  require(bool(c),"real quant status");
  require(output->meta[0].valid && output->meta[0].state==CacheState::READY &&
          !output->meta[1].valid,"dual A publication");
  require(output->peak_reserved_slots[0]>1 &&
          output->scalar_issues[0]==K/32 &&
          output->scalar_returns[0]==K/32,"cross-group scalar reservation/return");
  for (unsigned i=0;i<K;++i)
    require(uint8_t(output->q[0][0][i/32][i%32])==expected_q[i],"real q byte");
  for (unsigned g=0;g<K/32;++g) {
    const uint16_t saved=uint16_t(expected_scale[2*g]) |
                         (uint16_t(expected_scale[2*g+1])<<8);
    require(output->scale[0][0][g]==saved,"real half scale");
    float maximum=0;
    for (unsigned i=0;i<32;++i) {
      const float x=numeric_bits_f32(le32(raw.data()+4*(g*32+i)));
      const float magnitude=std::fabs(x);
      if (magnitude>maximum) maximum=magnitude;
    }
    volatile float d=maximum/127.0f;
    volatile float reciprocal=d==0.0f?0.0f:1.0f/d;
    require(output->d_full_bits[0][0][g]==numeric_f32_bits(d),"real d_full");
    require(output->reciprocal_bits[0][0][g]==numeric_f32_bits(reciprocal),
            "real reciprocal");
  }
  for (auto q:output->q[1][0][0]) require(uint8_t(q)==0x5a,"other A slot untouched");
  Task next=t;
  next.context.task_id=2;
  next.destination={Buffer::A8,1,1};
  next.destination_slot=1;
  auto next_beats=beats(next,raw.data());
  c=run(next,src_meta,next_beats.data(),*output);
  require(bool(c) && output->meta[0].valid && output->meta[1].valid &&
          output->meta[0].producer_task_id==1 &&
          output->meta[1].producer_task_id==2,"two A slots published independently");
  require(output->peak_reserved_slots[1]>1 &&
          output->scalar_issues[1]==K/32 &&
          output->scalar_returns[1]==K/32,"second slot scalar reservation/return");
  for (unsigned i=0;i<K;++i)
    require(uint8_t(output->q[1][0][i/32][i%32])==expected_q[i],
            "second A slot q byte");
  std::printf("QUANT16_REAL_PASS K=%u groups=%u q_bytes=%u scale_bytes=%u peak_slots=%u scalar_issues=%u scalar_returns=%u\n",
              K,K/32,K,K/16,output->peak_reserved_slots[0],
              output->scalar_issues[0],output->scalar_returns[0]);
}

void boundary_case() {
  Task t=task(256,Buffer::HEAD_WORK);
  t.context.stage=6;
  t.context.layer=255;
  t.context.row_space=RowSpace::BATCH;
  t.source_region=uint8_t(Region::ACT_HIDDEN);
  auto out=std::make_unique<AStore>();
  float x[256]={};
  x[32]=-0.0f;
  x[64]=std::numeric_limits<float>::denorm_min();
  x[96]=127.0f; x[97]=0.5f; x[98]=-0.5f;
  uint8_t raw[256*4];
  for (unsigned i=0;i<256;++i) {
    uint32_t bits=numeric_f32_bits(x[i]);
    for (unsigned j=0;j<4;++j) raw[4*i+j]=uint8_t(bits>>(8*j));
  }
  auto b=beats(t,raw);
  Check c=run(t,source(t),b.data(),*out);
  require(bool(c) && out->meta[0].valid,"boundary accepted");
  for (unsigned g=0;g<3;++g) {
    require(out->scale[0][0][g]==0,"zero/tiny saved scale");
    require(out->q[0][0][g][0]==0,"zero/tiny quant");
  }
  require(out->q[0][0][3][0]==127 && out->q[0][0][3][1]==1 &&
          out->q[0][0][3][2]==-1,"roundf ties away");
  require(out->scale[0][0][3]==0x3c00,"unit scale half");
  // A first-group reciprocal overflow must invalidate only the target slot.
  out=std::make_unique<AStore>();
  x[0]=1.0e-38f;
  uint32_t bits=numeric_f32_bits(x[0]);
  for (unsigned j=0;j<4;++j) raw[j]=uint8_t(bits>>(8*j));
  b=beats(t,raw);
  c=run(t,source(t),b.data(),*out);
  require(c.code==Status::E_NUMERICAL && c.bad_element==0 &&
          out->meta[0].state==CacheState::INVALID && !out->meta[1].valid,
          "tiny reciprocal overflow invalidation");
  // Incomplete producer coverage must reject before accepting any beat.
  F32TileMeta incomplete=source(t);
  incomplete.covered_groups[0][0]&=~uint32_t(1);
  c=run(t,incomplete,b.data(),*out);
  require(c.code==Status::E_BUFFER,"unpublished source rejected");
  F32TileMeta wrong_identity=source(t);
  wrong_identity.identity.build_tag[0]^=1;
  c=run(t,wrong_identity,b.data(),*out);
  require(c.code==Status::E_BUFFER,"full source identity rejected");
  auto incomplete_beat=b;
  incomplete_beat[0].valid_mask=0x7fff;
  out=std::make_unique<AStore>();
  c=run(t,source(t),incomplete_beat.data(),*out);
  require(c.code==Status::E_PROTOCOL,"16-lane mask rejected");
  std::puts("QUANT16_BOUNDARY_PASS zero=1 tiny=1 round=1 reciprocal_overflow=1 source_coverage=1 identity=1 valid_mask=1");
}
} // namespace

int main(int argc,char** argv) {
  require(argc==7,"usage WI_SOURCE WI_Q WI_SCALE DOWN_SOURCE DOWN_Q DOWN_SCALE");
  real_case(1024,Buffer::NORM,argv[1],argv[2],argv[3]);
  real_case(2624,Buffer::GATE,argv[4],argv[5],argv[6]);
  boundary_case();
  std::puts("QUANT16_LIGHT_PASS real_rows=2 boundary=1");
}
