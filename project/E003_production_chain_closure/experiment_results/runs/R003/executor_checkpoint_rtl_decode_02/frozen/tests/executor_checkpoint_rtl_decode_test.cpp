#include "laya_executor_checkpoint.h"
#include "lifecycle_fixture_helpers.h"
#include <algorithm>
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
  for(unsigned b=0;b<16;++b){assert(bool(f>>line) && line.size()==128);
    for(unsigned i=0;i<64;++i)p[b*64+i]=uint8_t(std::stoul(line.substr(126-2*i,2),nullptr,16));}
  assert(!(f>>line));return p;
}
int main(int argc,char** argv) {
  assert(argc==3);const std::string fixture=argv[1],host=argv[2];
  const auto actual=readhex(fixture+"/actual_checkpoint.hex");
  auto gold=bytes(fixture+"/checkpoint_good.bin");assert(gold.size()==1024);
  checkpoint::Packet expected{};std::copy(gold.begin(),gold.end(),expected.begin());
  portal::put(expected.data(),16,4,8);portal::put(expected.data(),680,4,8);
  assert(actual==expected);
  auto reqbytes=bytes(fixture+"/checkpoint.bin");checkpoint::Packet request{};
  std::copy(reqbytes.begin(),reqbytes.end(),request.begin());
  portal::put(request.data(),16,4,8);portal::put(request.data(),680,4,8);
  checkpoint::Request binding;assert(checkpoint::decode(request,binding));
  checkpoint::Response proof;assert(checkpoint::decode(actual,binding,proof));
  assert(checkpoint::encode(proof)==actual && proof.task_floor==7 &&
    proof.lpv_floor==179 && proof.target_epoch_floor==8 &&
    proof.target_state==checkpoint::TargetState::INACTIVE);
  // The observed RTL bytes are imported by the actual helper. Fence inputs
  // here are controlled host facts, not a generated executor handshake.
  auto io=bytes(host+"/request.bin"),aux=bytes(host+"/aux_header.bin");
  auto ports=lifecycle_fixture::memory();ports.io=io.data();ports.io_bytes=io.size();ports.aux=aux.data();
  static full::FullRuntime rt;bootstrap::State admission;lifecycle::Port port;
  assert(bootstrap::admit_new(admission,port,rt,ports,{true,true}));
  checkpoint::State state;state.sequence_high_water=3;
  checkpoint::Fence fence;fence.base={7,0x1200000000ull,16920576};fence.handoff_epoch=4;
  fence.physical_quiescent=fence.predecessor_dispatch_held=fence.source_held=fence.target_held=true;
  checkpoint::Request prepared;assert(checkpoint::prepare(state,port,rt,ports,{Buffer::HIDDEN,0,1},fence,prepared));
  assert(checkpoint::same_binding(prepared,binding));
  const auto claimed=rt.owner_claims,leased=rt.owner_leases,retired=rt.tasks_retired;
  program_wire::Command command;assert(checkpoint::accept(state,port,rt,proof,fence,command));
  assert(rt.last_task_id==7 && rt.tasks_retired==retired && rt.owner_claims==claimed &&
    rt.owner_leases==leased && rt.provenance_event_high_water==179 && rt.checkpoint_baseline.valid);
  const auto next=rt.dispatch_reservations.context(0,Op::LN_ATTN,2,1,0,RowSpace::TOKEN,0,16);
  const auto ref=rt.dispatch_reservations.ref(Buffer::NORM,0,0,0);
  assert(next.task_id==8 && ref.epoch==9 && rt.tasks_retired==0);
  const unsigned offsets[]={0,4,6,12,16,64,160,576,664,672,678,680,688,744,748,776,1023};
  for(auto off:offsets){auto p=actual;p[off]^=1;checkpoint::Response decoded=proof;
    assert(!checkpoint::decode(p,binding,decoded) && decoded.flags==0 && !decoded.task_floor);}
  std::cout<<"FULL_CURRENT_EXECUTOR_CHECKPOINT_RTL_DECODE_PASS actual_bytes=1024 task_base=7 lpv=179 target_epoch=8 import_retired=0 next_task=8 next_epoch=9 wire_rejects=17\n";
}
