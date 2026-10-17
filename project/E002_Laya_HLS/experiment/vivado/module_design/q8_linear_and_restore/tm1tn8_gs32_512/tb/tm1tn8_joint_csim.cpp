#include "q8_tm1tn8_joint_dma.h"
#include "q8_tm1tn8_abi.h"
#include "laya_types.h"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace q8_tm1tn8;
using laya::Status;
namespace {
void check(bool ok, const std::string& why) {
  if (!ok) throw std::runtime_error(why);
}
std::vector<uint8_t> raw(const std::string& path) {
  std::ifstream f(path, std::ios::binary | std::ios::ate);
  check(bool(f), "open " + path);
  const auto n=f.tellg();
  check(n>=0, "size " + path);
  f.seekg(0);
  std::vector<uint8_t> bytes(size_t(n), uint8_t(0));
  check(bool(f.read(reinterpret_cast<char*>(bytes.data()),n)), "read " + path);
  return bytes;
}
uint32_t u32(const std::vector<uint8_t>& b, size_t i) {
  check(i*4+4<=b.size(), "u32 range");
  return uint32_t(b[i*4]) | uint32_t(b[i*4+1])<<8 |
         uint32_t(b[i*4+2])<<16 | uint32_t(b[i*4+3])<<24;
}
std::vector<uint32_t> words(const std::vector<uint8_t>& b) {
  check(b.size()%4==0, "word alignment");
  std::vector<uint32_t> result(b.size()/4);
  for (size_t i=0;i<result.size();++i) result[i]=u32(b,i);
  return result;
}
std::vector<ap_uint<512>> wide(const std::vector<uint8_t>& b) {
  check(b.size()%64==0, "wide alignment");
  std::vector<ap_uint<512>> result(b.size()/64);
  for (size_t i=0;i<result.size();++i)
    for (unsigned j=0;j<64;++j)
      result[i].range(j*8+7,j*8)=b[i*64+j];
  return result;
}
struct Model {
  std::vector<ap_uint<512>> q0,q1,scale;
  std::vector<uint32_t> aux;
};
Model model(const std::string& path) {
  return {wide(raw(path+"/w_q0.bin")), wide(raw(path+"/w_q1.bin")),
          wide(raw(path+"/w_scale.bin")), words(raw(path+"/aux.bin"))};
}
void reject_source_profiles(const Model& m, const std::string& descriptors,
                            const std::string& command, bool qkv) {
  const auto good=words(raw(descriptors+"/"+command+".bin"));
  struct Bad { const char* name; unsigned index; uint32_t value;
               Status status; };
  const Bad cases[] = {
      {"source epoch zero",D_SRC_EPOCH,0,Status::E_BUFFER},
      {"source epoch two",D_SRC_EPOCH,2,Status::E_BUFFER},
      {"source epoch later",D_SRC_EPOCH,7,Status::E_BUFFER},
      {"source bank",D_SRC_BANK,qkv ? 0u : 1u,Status::E_BUFFER},
      {"source id",D_SRC_ID,qkv ? 2u : 9u,Status::E_BUFFER},
      {"source region",D_SRC_REGION,qkv ? 1u : 0u,Status::E_BUFFER},
      {"source row",D_ROW0,1,Status::E_BUFFER},
      {"request",D_REQUEST_LO,4,Status::E_PROTOCOL},
      {"generation",D_GENERATION_LO,2,Status::E_PROTOCOL},
      {"B2",D_B,2,Status::E_SHAPE},
      {"model tag",D_MODEL_TAG_0,good[D_MODEL_TAG_0]^1u,Status::E_MODEL},
      {"numeric tag",D_NUMERIC_TAG_0,good[D_NUMERIC_TAG_0]^1u,Status::E_MODEL},
      {"layout tag",D_LAYOUT_TAG_0,good[D_LAYOUT_TAG_0]^1u,Status::E_MODEL},
      {"build tag",D_BUILD_TAG_0,good[D_BUILD_TAG_0]^1u,Status::E_MODEL},
  };
  for (const Bad& bad:cases) {
    auto d=good;
    d[bad.index]=bad.value;
    std::vector<uint32_t> observed(kObservedWords,0xd15ea5ed);
    hls::stream<ap_uint<256>> writer_config,compute_config;
    hls::stream<ap_uint<288>> bias_tiles;
    hls::stream<ap_uint<2816>> group_issues;
    hls::stream<ap_uint<1>> finish;
    hls::stream<ap_uint<512>> completion;
    completion.write(ap_uint<512>(0));
    // A preflight reject must not dereference activation at all.
    q8_tm1tn8_joint_dma(d.data(),m.q0.data(),m.q1.data(),m.scale.data(),
                         m.aux.data(),nullptr,writer_config,compute_config,
                         bias_tiles,group_issues,finish,completion,
                         observed.data());
    check(observed[O_STATUS]==uint32_t(bad.status) &&
          observed[O_BAD_ELEMENT_LO]==UINT32_MAX &&
          observed[O_BAD_ELEMENT_HI]==UINT32_MAX &&
          observed[O_DONE_TASK]==0 && observed[O_QUANT_DONE_TASK]==0 &&
          observed[O_LINEAR_STARTED]==0 &&
          observed[O_LAST_TASK]==1 && observed[O_W_MAX_CLAIMED]==1 &&
          observed[O_W_STATE]==uint32_t(laya::CacheState::READY) &&
          observed[O_A8_MAX_CLAIMED]==0 &&
          observed[O_PS_MAX_CLAIMED]==0 &&
          observed[O_DST_MAX_CLAIMED]==0 &&
          observed[O_ACCEPTED_ISSUES]==0 &&
          observed[port_useful_lo(P_ACTIVATION)]==0,
          std::string("preflight state/read changed: ")+bad.name);
    const uint32_t expected_detail =
        bad.status==Status::E_BUFFER ?
          ((4u<<24)|(d[D_SRC_ID]<<16)|4u) :
        bad.status==Status::E_SHAPE ?
          ((7u<<24)|(d[D_OP]<<16)|5u) :
        bad.status==Status::E_MODEL ? ((4u<<24)|4u) :
                                   ((7u<<24)|4u);
    check(observed[O_DETAIL]==expected_detail,
          std::string("preflight detail: ")+bad.name);
    check(!writer_config.empty() && !compute_config.empty() &&
          bias_tiles.empty() && group_issues.empty() &&
          !finish.empty() && completion.empty(),
          std::string("preflight stream debt: ")+bad.name);
    const auto cc=compute_config.read();
    check(unsigned(cc[225])==0, "preflight zero-work config");
    writer_config.read();
    check(unsigned(finish.read())==1, "preflight finish marker");
  }
  std::printf("TM1TN8_JOINT_SOURCE_REJECT_PASS case=%s count=%zu\n",
              qkv ? "qkv" : "act",sizeof(cases)/sizeof(cases[0]));
}
void invoke(const Model& m, const std::string& descriptors,
            const std::string& fixture, const std::string& command,
            const std::string& name) {
  auto d=words(raw(descriptors+"/"+command+".bin"));
  check(d.size()==128, "descriptor length");
  const bool run=d[D_COMMAND]==RUN_TILE;
  const unsigned rows=d[D_ROWS], K=d[D_K], N=d[D_N];
  const unsigned G=K/32, T=(N+7)/8;
  auto activation=wide(run ? raw(fixture+"/"+name+"_source_f32.bin") :
                             std::vector<uint8_t>(64));
  const auto aq=run ? raw(fixture+"/"+name+"_a8_q.bin") :
                      std::vector<uint8_t>();
  const auto as=run ? raw(fixture+"/"+name+"_a8_scale.bin") :
                      std::vector<uint8_t>();
  const auto q0=run ? raw(fixture+"/"+name+"_q0.bin") :
                      std::vector<uint8_t>();
  const auto q1=run ? raw(fixture+"/"+name+"_q1.bin") :
                      std::vector<uint8_t>();
  const auto steps=run ? raw(fixture+"/"+name+"_steps_u32x6.bin") :
                         std::vector<uint8_t>();
  const auto bias=run && N==2 ? raw(fixture+"/"+name+"_bias.bin") :
                                std::vector<uint8_t>();
  std::vector<uint32_t> observed(kObservedWords,0xd15ea5ed);
  hls::stream<ap_uint<256>> writer_config,compute_config;
  hls::stream<ap_uint<288>> bias_tiles;
  hls::stream<ap_uint<2816>> group_issues;
  hls::stream<ap_uint<1>> finish;
  hls::stream<ap_uint<512>> completion;
  ap_uint<512> ack=0;
  if (run) {
    ack.range(64,1)=N==2 ? 64 : uint64_t(rows)*6144;
    if (N==3072) ack.range(128,65)=uint64_t(rows)*6144;
    ack.range(257,226)=rows*G*T;
    ack.range(289,258)=rows*N;
    ack.range(353,290)=uint64_t(rows)*K*N;
    ack.range(385,354)=rows*G*T;
    ack.range(449,418)=d[D_FLAGS] ? G : 0;
    ack.range(417,386)=d[D_FLAGS] ? G*8 : 0;
  }
  completion.write(ack); // Front-only CSim; physical B is checked in RTL.
  q8_tm1tn8_joint_dma(d.data(),m.q0.data(),m.q1.data(),m.scale.data(),
                       m.aux.data(),activation.data(),writer_config,
                       compute_config,bias_tiles,group_issues,finish,
                       completion,observed.data());
  check(!writer_config.empty() && !compute_config.empty() &&
        !finish.empty() && completion.empty(), "command stream framing");
  const auto wc=writer_config.read(), cc=compute_config.read();
  check(uint64_t(wc.range(63,0))==join_u64(d[D_OUT0_BASE_LO],d[D_OUT0_BASE_HI]) &&
        unsigned(cc[225])==unsigned(run) &&
        unsigned(cc[224])==unsigned(run && d[D_FLAGS]),
        "front config identity");
  check(unsigned(finish.read())==1, "finish marker");
  check(observed[O_MAGIC]==kObservedMagic && observed[O_STATUS]==0 &&
        observed[O_DONE_DRAINED]==1, "front status");
  if (run) {
    check(aq.size()==size_t(rows)*G*32 && as.size()==size_t(rows)*G*2 &&
          steps.size()==size_t(rows)*G*N*24, "fixture shape");
    for (unsigned i=0;i<aq.size()/4;++i)
      check(observed[kTraceQWord+i]==
                (d[D_FLAGS] ? u32(aq,i) : 0xd15ea5edu),
            d[D_FLAGS] ? "quant q bit mismatch" : "trace-off q region changed");
    for (unsigned i=0;i<(rows*G+1)/2;++i) {
      uint32_t expected=0xd15ea5edu;
      if (d[D_FLAGS]) {
        expected=uint16_t(as[4*i]) | uint32_t(as[4*i+1])<<8;
        if (2*i+1<rows*G)
          expected|=uint32_t(as[4*i+2])<<16 | uint32_t(as[4*i+3])<<24;
      }
      check(observed[kTraceScaleWord+i]==expected,
            d[D_FLAGS] ? "quant half bit mismatch" :
                         "trace-off half region changed");
    }
    for (unsigned tile=0;tile<T;++tile) {
      const auto b=bias_tiles.read();
      check(unsigned(b.range(264,256))==tile &&
            unsigned(b.range(272,265))==(tile==T-1 ? (1u<<(N-tile*8))-1:255u) &&
            unsigned(b[273])==unsigned(N==2), "bias tile tag");
      if (N==2)
        for (unsigned lane=0;lane<N;++lane)
          check(uint32_t(b.range(lane*32+31,lane*32))==u32(bias,lane),
                "actual bias bits");
    }
    for (unsigned r=0;r<rows;++r)
      for (unsigned g=0;g<G;++g)
        for (unsigned tile=0;tile<T;++tile) {
          const auto p=group_issues.read();
          check(unsigned(p.range(2600,2592))==tile &&
                unsigned(p.range(2606,2601))==g &&
                unsigned(p.range(2608,2607))==r &&
                unsigned(p.range(2616,2609))==
                    (tile==T-1 ? (1u<<(N-tile*8))-1:255u) &&
                unsigned(p[2617])==unsigned(d[D_FLAGS] && r==d[D_TRACE_ROW_LOCAL] &&
                                          tile==d[D_TRACE_COLUMN]/8),
                "group issue order/tag/mask");
          for (unsigned k=0;k<32;++k)
            check(unsigned(p.range(k*8+7,k*8))==aq[(r*G+g)*32+k],
                  "group activation q bits");
          for (unsigned lane=0;lane<8;++lane) {
            const auto& shard=(tile&1) ? q1:q0;
            const size_t qoff=(((tile/2)*G+g)*8+lane)*32;
            for (unsigned k=0;k<32;++k)
              check(unsigned(p.range(256+lane*256+k*8+7,
                                     256+lane*256+k*8))==shard[qoff+k],
                    "group model q bits");
            const unsigned n=tile*8+lane;
            if (n<N) {
              const size_t at=((r*G+g)*N+n)*6;
              check(uint32_t(p.range(2335,2304))==u32(steps,at+1) &&
                    uint32_t(p.range(2336+lane*32+31,2336+lane*32))==
                        u32(steps,at+2), "group scale bits");
            }
          }
        }
    check(group_issues.empty() && bias_tiles.empty(), "stream residual");
    for (unsigned g=0;g<G;++g)
      for (unsigned j=0;j<8;++j)
        check(observed[kTraceGroupWord+g*8+j]==0xd15ea5ed,
              "HLS overlapped physical trace writer partition");
    check(observed[O_ACCEPTED_ISSUES]==rows*G*T &&
          observed[O_TRACE_GROUP_COUNT]==(d[D_FLAGS] ? G : 0),
          "front completion accounting");
  } else check(bias_tiles.empty() && group_issues.empty(), "LOAD issues");
  std::printf("TM1TN8_JOINT_FRONT_COMMAND_PASS name=%s rows=%u G=%u T=%u\n",
              command.c_str(),rows,G,T);
}
} // namespace

int main(int argc,char** argv) {
  try {
    check(argc==5,"usage: joint_csim PACKAGE DESCRIPTORS FIXTURES act|qkv");
    const auto m=model(argv[1]);
    const std::string kind=argv[4];
    if (kind=="act") {
      invoke(m,argv[2],argv[3],"act_load","act");
      reject_source_profiles(m,argv[2],"act_run_trace",false);
      invoke(m,argv[2],argv[3],"act_run_trace","act");
    } else if (kind=="qkv") {
      invoke(m,argv[2],argv[3],"qkv_load","qkv_row1");
      reject_source_profiles(m,argv[2],"qkv_run1_trace",true);
      invoke(m,argv[2],argv[3],"qkv_run1_trace","qkv_row1");
      invoke(m,argv[2],argv[3],"qkv_run4_trace","qkv_rows4");
      invoke(m,argv[2],argv[3],"qkv_run4_off","qkv_rows4");
    } else throw std::runtime_error("case must be act or qkv");
    std::printf("TM1TN8_JOINT_FRONT_CSIM_PASS case=%s\n",kind.c_str());
    return 0;
  } catch (const std::exception& e) {
    std::fprintf(stderr,"TM1TN8_JOINT_FRONT_CSIM_FAIL %s\n",e.what());
    return 1;
  }
}
