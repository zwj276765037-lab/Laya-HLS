#include "quant16_hls_top.h"
#include "laya_numeric.h"

#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <memory>
#include <vector>

namespace {
using namespace laya;
using namespace laya::quant16;

void require(bool good, const char* why) {
  if (!good) { std::fprintf(stderr, "QUANT16_HLS_FAIL %s\n", why); std::exit(1); }
}

std::vector<uint8_t> load(const char* path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "fixture open");
  return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}

uint32_t le32(const uint8_t* data) {
  return uint32_t(data[0]) | uint32_t(data[1]) << 8 |
         uint32_t(data[2]) << 16 | uint32_t(data[3]) << 24;
}

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id=3; id.generation=1; id.B=1; id.S=128;
  for (unsigned i=0; i<16; ++i) {
    id.model_tag[i]=1; id.numeric_tag[i]=2;
    id.layout_tag[i]=3; id.build_tag[i]=4;
  }
  return id;
}

Task make_task(unsigned k, Buffer source) {
  Task task;
  task.identity=identity();
  task.context={1,Op::QUANT,2,0,0,RowSpace::TOKEN,0,1};
  task.source={source,0,1};
  task.destination={Buffer::A8,0,1};
  task.K=k;
  return task;
}

F32TileMeta make_source(const Task& task) {
  F32TileMeta meta;
  meta.identity=task.identity;
  meta.ref=task.source;
  meta.region=task.source_region;
  meta.row_space=task.context.row_space;
  meta.batch=task.context.batch;
  meta.row0=task.context.row0;
  meta.rows=task.context.rows;
  meta.K=task.K;
  numeric_cover_all(meta.covered_groups,1,task.K/32,16);
  meta.state=CacheState::READY;
  meta.content=Content::F32;
  meta.valid=true;
  return meta;
}

std::vector<Beat> make_beats(const Task& task, const std::vector<uint8_t>& source) {
  const unsigned groups=task.K/32;
  // Cosimulation copies the declared top-level array depth, even though this
  // task consumes only the first two beats of each active group.
  std::vector<Beat> beats(4096);
  for (unsigned g=0; g<groups; ++g)
    for (unsigned half=0; half<2; ++half) {
      Beat& beat=beats[g*2+half];
      beat.task_id=task.context.task_id;
      beat.source_epoch=task.source.epoch;
      beat.row=task.context.row0;
      beat.group=g;
      beat.half=half;
      beat.valid_mask=0xffff;
      for (unsigned lane=0; lane<16; ++lane)
        beat.bits[lane]=le32(source.data()+4*(g*32+half*16+lane));
    }
  return beats;
}

void real_case(unsigned k, Buffer source_buffer, const char* source_path,
               const char* q_path, const char* scale_path, const char* scalar_path) {
  const auto source=load(source_path), q=load(q_path), scale=load(scale_path),
             scalar=load(scalar_path);
  require(source.size()==k*4 && q.size()==k && scale.size()==k/16 &&
          scalar.size()==(k/32)*12,"fixture sizes");
  Task task=make_task(k,source_buffer);
  auto metadata=make_source(task);
  auto beats=make_beats(task,source);
  auto output=std::make_unique<AStore>();
  Check result;
  laya_quant16_functional(&task,&metadata,beats.data(),output.get(),&result);
  require(bool(result) && output->meta[0].valid &&
          output->meta[0].state==CacheState::READY,"real status/READY");
  require(output->scalar_issues[0]==k/32 && output->scalar_returns[0]==k/32 &&
          output->peak_reserved_slots[0]>1,"scalar reservation/retirement");
  for (unsigned i=0; i<k; ++i)
    require(uint8_t(output->q[0][0][i/32][i%32])==q[i],"independent q byte");
  for (unsigned g=0; g<k/32; ++g) {
    const unsigned s=2*g;
    require(output->scale[0][0][g]==uint16_t(scale[s]|(uint16_t(scale[s+1])<<8)),
            "independent half scale");
    require(output->d_full_bits[0][0][g]==le32(scalar.data()+12*g+4),
            "independent d_full");
    require(output->reciprocal_bits[0][0][g]==le32(scalar.data()+12*g+8),
            "independent reciprocal");
  }
  require(!output->meta[1].valid,"other A slot remains unclaimed");
  std::printf("QUANT16_HLS_REAL_PASS K=%u groups=%u q_bytes=%u\n",k,k/32,k);
}

void reject_bad_mask() {
  Task task=make_task(1024,Buffer::NORM);
  auto metadata=make_source(task);
  std::vector<uint8_t> zero(1024*4);
  auto beats=make_beats(task,zero);
  beats[0].valid_mask=0x7fff;
  auto output=std::make_unique<AStore>();
  Check result;
  laya_quant16_functional(&task,&metadata,beats.data(),output.get(),&result);
  require(result.code==Status::E_PROTOCOL && !output->meta[0].valid,
          "bad valid mask rejected");
  metadata.covered_groups[0][0]=0;
  beats[0].valid_mask=0xffff;
  laya_quant16_functional(&task,&metadata,beats.data(),output.get(),&result);
  require(result.code==Status::E_BUFFER && !output->meta[0].valid,
          "unpublished source rejected");
  std::puts("QUANT16_HLS_REJECT_PASS mask=1 source_coverage=1");
}
} // namespace

int main(int argc,char** argv) {
  require(argc==9,"usage WI_SOURCE WI_Q WI_SCALE WI_SCALAR DOWN_SOURCE DOWN_Q DOWN_SCALE DOWN_SCALAR");
  real_case(1024,Buffer::NORM,argv[1],argv[2],argv[3],argv[4]);
  real_case(2624,Buffer::GATE,argv[5],argv[6],argv[7],argv[8]);
  reject_bad_mask();
  std::puts("QUANT16_HLS_TOP_TB_PASS real_rows=2 reject=2");
}
