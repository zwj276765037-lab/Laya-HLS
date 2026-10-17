#include "laya_executor_checkpoint.h"
#include "lifecycle_fixture_helpers.h"
#include <algorithm>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>
using namespace laya;
std::vector<uint8_t> bytes(const std::string& path) {
  std::ifstream f(path,std::ios::binary);assert(f);
  return {std::istreambuf_iterator<char>(f),std::istreambuf_iterator<char>()};
}
checkpoint::Packet readhex(const std::string& path) {
  std::ifstream f(path);assert(f);checkpoint::Packet p{};std::string line;
  for(unsigned b=0;b<16;++b){assert(bool(f>>line)&&line.size()==128);
    for(unsigned i=0;i<64;++i)p[b*64+i]=uint8_t(std::stoul(line.substr(126-2*i,2),nullptr,16));}
  assert(!(f>>line));return p;
}
int main(int argc,char**argv) {
  assert(argc==5);unsigned rejected=0;
  for(unsigned index=0;index<3;++index) {
    const std::string root=argv[index+1];
    const auto query=readhex(root+"/control_fixture/query.hex");
    const auto actual=readhex(root+"/fixture/actual_handoff_checkpoint.hex");
    const auto expected=index<2?readhex(root+"/control_fixture/revoked_proof_gold.hex"):
      readhex(root+"/control_fixture/proof.hex");
    assert(actual==expected);
    checkpoint::Request binding;assert(checkpoint::decode(query,binding));
    checkpoint::Response proof;const auto decoded=checkpoint::decode(actual,binding,proof);
    assert(checkpoint::same_binding(proof.binding,binding)&&checkpoint::encode(proof)==actual);
    if(index<2) {
      assert(decoded.code==Status::E_PROTOCOL&&decoded.detail==0x0700000e&&
        decoded.bad_element==UINT64_MAX&&proof.flags==3&&!proof.known&&!proof.complete&&
        !proof.task_floor&&!proof.source_epoch_floor&&!proof.target_epoch_floor&&!proof.lpv_floor&&
        proof.target_state==checkpoint::TargetState::UNKNOWN);
    } else assert(decoded&&proof.flags==255&&proof.task_floor==7&&proof.lpv_floor==179);
    auto io=bytes(std::string(argv[4])+"/request.bin"),aux=bytes(std::string(argv[4])+"/aux_header.bin");
    auto ports=lifecycle_fixture::memory();ports.io=io.data();ports.io_bytes=io.size();ports.aux=aux.data();
    static full::FullRuntime rt;rt=full::FullRuntime{};
    bootstrap::State admission;lifecycle::Port port;
    assert(bootstrap::admit_new(admission,port,rt,ports,{true,true}));
    checkpoint::State state;checkpoint::Fence fence;
    fence.base={7,0x1200000000ull,16920576};fence.handoff_epoch=1;
    fence.physical_quiescent=fence.predecessor_dispatch_held=fence.source_held=fence.target_held=true;
    checkpoint::Request prepared;assert(checkpoint::prepare(state,port,rt,ports,{Buffer::HIDDEN,0,1},fence,prepared));
    assert(checkpoint::same_binding(prepared,binding));
    std::vector<uint8_t> before(sizeof(rt));std::memcpy(before.data(),&rt,sizeof(rt));
    program_wire::Command command;
    if(index<2) {
      assert(!checkpoint::accept(state,port,rt,proof,fence,command));
      assert(std::memcmp(before.data(),&rt,sizeof(rt))==0&&!rt.checkpoint_baseline.valid);
    } else {
      // Valid stable success bytes cannot import after a real revocation.
      // The host fence here represents the observed hardware cancellation.
      fence.cancel=true;
      assert(!checkpoint::accept(state,port,rt,proof,fence,command));
      assert(std::memcmp(before.data(),&rt,sizeof(rt))==0&&!rt.checkpoint_baseline.valid);
    }
    const unsigned offsets[]={0,4,6,9,12,16,64,160,576,664,672,678,680,688,744,748,776,1023};
    for(auto off:offsets) {
      auto variant=actual;variant[off]^=1;checkpoint::Response out=proof;
      const auto c=checkpoint::decode(variant,binding,out);
      // Valid negative status is distinguished from a failed binding decode.
      assert(c.code==Status::E_PROTOCOL&&out.flags==0&&!out.task_floor);++rejected;
    }
  }
  std::cout<<"FULL_CURRENT_EXECUTOR_MANAGED_QUERY_DECODE_PASS actual_frames=3 negative_roundtrip=2 stable_success_revoked=1 atomic_no_import=3 wire_rejects="<<rejected<<"\n";
}
