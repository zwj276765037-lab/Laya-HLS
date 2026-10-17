#include "laya_executor_actor.h"
#include "laya_graph_program_hls.h"
#include "lifecycle_fixture_helpers.h"
#include <algorithm>
#include <fstream>
#include <iostream>
#include <memory>
#include <vector>
using namespace laya;
using namespace lifecycle_fixture;
namespace {
std::vector<uint8_t> bytes(const std::string& path) {
  std::ifstream f(path,std::ios::binary); assert(f);
  return {std::istreambuf_iterator<char>(f),std::istreambuf_iterator<char>()};
}
template<std::size_t N> std::array<uint8_t,N> packet(const std::vector<uint8_t>& b) {
  assert(b.size()==N);std::array<uint8_t,N> p{};std::copy(b.begin(),b.end(),p.begin());return p;
}
struct Harness {
  executor::State& state;
  executor::Inputs in;
  full::FullMemory ports;
  std::vector<uint8_t> io,aux;
  Streams tx;
  hls::stream<ap_uint<512>> query,response,commands,program_results,results,actions,completions;
  unsigned completion_reads=0,producers=0,events=0;
  bool action_consumed=false;
  Harness(executor::State& s,const std::string& fixture):state(s) {
    io=bytes(fixture+"/v2/v1/request.bin");aux=bytes(fixture+"/v2/v1/aux_header.bin");
    ports=memory();ports.io=io.data();ports.io_bytes=io.size();ports.aux=aux.data();
    in.request_valid=true;in.session=29;in.accepted_request=101;
    in.admission={true,true};in.source={Buffer::HIDDEN,0,1};
    in.fence.base={7,0x1200000000ull,16920576};in.fence.handoff_epoch=19;
  }
  void call(bool program=false) {
    in.action_completion_consumed=action_consumed;
    executor::step(state,ports,in,query,response,commands,program_results,results,
      actions,completions,tx.transaction_request,tx.transaction_completion);
    in.control_request_consumed=false;in.control_response_valid=false;
    if (!program) return;
    laya_command_provenance_adapter(in.cancel || state.revoked,tx.transaction_request,
      tx.transaction_completion,tx.compute_command,tx.compute_response,
      tx.provenance_command,tx.provenance_response,tx.producer_request,tx.producer_completion);
    if(tx.provenance_command.size()>=provenance::kRequestBeats) {
      provenance::Request q;assert(provenance::decode(dequeue<provenance::kRequestBytes>(tx.provenance_command),q));
      ++events;enqueue(tx.provenance_response,provenance::encode(provenance_response(q)));
    }
    if(tx.producer_request.size()>=producer::kRequestBeats) {
      producer::Request q;assert(producer::decode(dequeue<producer::kRequestBytes>(tx.producer_request),q));
      ++producers;enqueue(tx.producer_completion,producer::encode(producer_success(q)));
    }
    const auto before=completions.size();
    laya_graph_program_sequencer(in.cancel || state.revoked,state.program_result_consumed,
      commands,program_results,actions,completions);
    if(completions.size()<before && ++completion_reads==4) action_consumed=true;
  }
  handoff::Message outgoing() {
    assert(state.control_pending && handoff::validate(state.control_request));
    handoff::Message m;assert(handoff::decode(handoff::encode(state.control_request),m));
    in.control_request_consumed=true;call();return m;
  }
  void incoming(const handoff::Message& m) {
    handoff::Message decoded;assert(handoff::decode(handoff::encode(m),decoded));
    in.control_response_valid=true;in.control_response=decoded;call();
  }
  void start_hold() {
    call();assert(state.phase==executor::Phase::WAIT_CHECKPOINT && state.runtime.request_valid);
    in.request_valid=false;in.checkpoint_valid=true;call();
    assert(state.phase==executor::Phase::WAIT_HELD && state.checkpoint.hold_reserved &&
      !state.runtime.checkpoint_baseline.valid && state.checkpoint.pending.handoff_epoch==0 && query.empty());
  }
  void held(uint64_t h) {
    auto m=outgoing();assert(m.kind==handoff::Kind::HOLD && m.binding.handoff_epoch==0);
    m.kind=handoff::Kind::HELD;m.binding.handoff_epoch=h;
    in.fence.handoff_epoch=h;
    in.fence.physical_quiescent=in.fence.predecessor_dispatch_held=in.fence.source_held=in.fence.target_held=true;
    incoming(m);assert(state.phase==executor::Phase::WRITE_CHECKPOINT);
    assert(state.checkpoint.sequence_high_water==m.binding.source.sequence && state.checkpoint.handoff_high_water==h);
    for(unsigned i=0;i<16;++i)call();
    assert(query.size()==16 && state.phase==executor::Phase::READ_CHECKPOINT);
  }
  void proof(checkpoint::Response p,bool stall=true) {
    p.binding=state.checkpoint.pending;
    const auto encoded=checkpoint::encode(p);
    for(unsigned i=0;i<14;++i)response.write(pack(encoded,i));
    for(unsigned i=0;i<14;++i)call();
    if(stall)for(unsigned i=0;i<12;++i) {call();assert(state.imports==0 && !state.runtime.checkpoint_baseline.valid && commands.empty());}
    response.write(pack(encoded,14));call();
    if(stall)for(unsigned i=0;i<12;++i) {call();assert(!state.runtime.checkpoint_baseline.valid && commands.empty());}
    response.write(pack(encoded,15));call();
    assert(state.phase==executor::Phase::VALIDATE_CHECKPOINT && !state.runtime.checkpoint_baseline.valid && commands.empty());
    call();assert(state.phase==executor::Phase::IMPORT_CHECKPOINT);call();
  }
};
void wire(const std::string& fixture) {
  for(unsigned kind=1;kind<=7;++kind) {
    const auto p=packet<1024>(bytes(fixture+"/control_"+std::to_string(kind)+".bin"));
    handoff::Message m;assert(handoff::decode(p,m) && unsigned(m.kind)==kind && handoff::encode(m)==p);
  }
  const auto good=packet<1024>(bytes(fixture+"/control_3.bin"));
  const unsigned bad[]={0,4,6,9,12,15,28,31,148,159,664,671,678,679,744,764,768,775,793,1023};
  for(unsigned i:bad) {auto p=good;p[i]^=1;handoff::Message out;
    out.local_committed=true;out.session=999;assert(!handoff::decode(p,out) && !out.session && !out.local_committed);}
  handoff::Message m;assert(handoff::decode(good,m));
  for(unsigned which=0;which<5;++which) {
    auto changed=m;
    if(which==0)++changed.session;
    if(which==1)++changed.accepted_request;
    if(which==2)++changed.binding.source.sequence;
    if(which==3)++changed.binding.handoff_epoch;
    if(which==4)++changed.binding.source.identity.request_id;
    assert(handoff::validate(changed) && !handoff::same_key(changed,m));
  }
}
void consecutive(const std::string& fixture,const checkpoint::Response& gold) {
  static executor::State state;Harness h(state,fixture);
  for(unsigned request=0;request<2;++request) {
    if(request) {
      portal::put(h.io.data(),24,1102,8);h.in.request_valid=true;++h.in.accepted_request;
      h.in.source.epoch=2;h.completion_reads=0;h.action_consumed=false;
      h.in.result_consumed=false;h.in.control_request_consumed=false;
    }
    h.start_hold();
    const auto s=state.checkpoint.sequence_high_water;
    assert(s==request+1 && state.admissions==request+1 && state.runtime.tasks_retired==0);
    // The independent HOLD binding is exact, with no HELD prerequisite.
    if(!request)assert(handoff::encode(state.control_request)==packet<1024>(bytes(fixture+"/control_1.bin")));
    for(unsigned i=0;i<12;++i){h.call();assert(h.query.empty() && h.commands.empty());}
    h.held(19+request);
    checkpoint::Request decoded;
    assert(checkpoint::decode(dequeue<1024>(h.query),decoded));
    auto p=gold;p.task_floor=request?7:4;p.source_epoch_floor=h.in.source.epoch;
    p.target_epoch_floor=request?8:7;p.lpv_floor=request?61:23;
    const auto before_import=state.imports;
    h.proof(p,!request);
    assert(state.imports==before_import+1 && state.runtime.tasks_retired==0 &&
      state.runtime.owner_claims==0 && state.runtime.owner_leases==0 &&
      state.runtime.last_task_id==p.task_floor && state.phase==executor::Phase::WAIT_IMPORT_CONFIRMATION);
    for(unsigned i=0;i<24;++i){h.call();assert(h.commands.empty() && h.actions.empty() && h.events==10*request);}
    auto early=state.control_request;early.kind=handoff::Kind::GRANTED;
    h.incoming(early);assert(h.commands.empty() && state.control_pending);
    auto confirmation=h.outgoing();assert(confirmation.kind==handoff::Kind::IMPORT_OK && confirmation.local_committed);
    for(unsigned which=0;which<4;++which) {
      auto wrong=confirmation;wrong.kind=handoff::Kind::GRANTED;
      if(which==0)++wrong.session;
      if(which==1)++wrong.binding.source.sequence;
      if(which==2)++wrong.binding.handoff_epoch;
      if(which==3)++wrong.binding.source.identity.request_id;
      h.incoming(wrong);assert(h.commands.empty() && state.imports==request+1);
    }
    auto stale=confirmation;stale.kind=handoff::Kind::GRANTED;--stale.accepted_request;
    h.incoming(stale);assert(h.commands.empty() && state.control_rejections==6*(request+1));
    auto grant=confirmation;grant.kind=handoff::Kind::GRANTED;
    h.incoming(grant);assert(state.phase==executor::Phase::WRITE_COMMAND);
    for(unsigned i=0;i<10000 && state.phase!=executor::Phase::WAIT_RESULT_CONSUMED;++i)h.call(true);
    assert(state.phase==executor::Phase::WAIT_RESULT_CONSUMED && h.results.size()==4 &&
      state.runtime.tasks_retired==4 && state.runtime.last_task_id==p.task_floor+4 &&
      state.runtime.producer_request_high_water==4*(request+1) &&
      state.port.machine.action_high_water==request+1 && h.producers==4*(request+1));
    assert(state.port.machine.completion.retired_tasks==4 &&
      state.port.machine.completion.first_task_id==p.task_floor+1 &&
      state.port.machine.completion.last_task_id==p.task_floor+4);
    program_wire::Result result;assert(program_wire::decode(dequeue<256>(h.results),result));
    assert(result.result && result.action_ordinal==request+1 && result.pc==1);
    for(unsigned i=0;i<24;++i){h.call(true);assert(state.admissions==request+1 && state.phase==executor::Phase::WAIT_RESULT_CONSUMED);}
    h.in.result_consumed=true;h.call(true);assert(state.phase==executor::Phase::IDLE);
    assert(h.commands.empty() && h.program_results.empty() && h.actions.empty() && h.completions.empty());
  }
  assert(state.admissions==2 && state.imports==2 && state.results==2 && state.checkpoint.sequence_high_water==2 && state.checkpoint.handoff_high_water==20);
}
void helper_reservation(const std::string& fixture,const checkpoint::Response& gold) {
  auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
  h.start_hold();
  auto& cp=state->checkpoint;
  const auto seq=cp.sequence_high_water;
  checkpoint::Request out;out.source.sequence=999;
  assert(!checkpoint::reserve_hold(cp,state->port,state->runtime,h.ports,h.in.source,h.in.fence.base,out));
  assert(seq==1 && cp.sequence_high_water==seq && out.source.sequence==999);
  auto held=cp.pending;held.handoff_epoch=19;
  auto fence=h.in.fence;fence.physical_quiescent=fence.predecessor_dispatch_held=fence.source_held=fence.target_held=true;
  fence.cancel=true;
  const auto retired=state->runtime.tasks_retired;
  assert(!checkpoint::prepare_held(cp,state->port,state->runtime,h.ports,held,fence,out));
  assert(cp.sequence_high_water==seq && cp.handoff_high_water==19 && cp.hold_reserved &&
    !state->runtime.checkpoint_baseline.valid && state->runtime.tasks_retired==retired);
  fence.cancel=false;auto proof=gold;proof.binding=cp.pending;program_wire::Command command;
  assert(!checkpoint::accept(cp,state->port,state->runtime,proof,fence,command));
  assert(!state->runtime.checkpoint_baseline.valid && cp.handoff_high_water==19);
}
void failures(const std::string& fixture,const checkpoint::Response& gold) {
  for(unsigned which=0;which<4;++which) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    h.start_hold();h.held(19);assert(checkpoint::decode(dequeue<1024>(h.query),state->checkpoint.pending));
    if(which==0)assert(state->runtime.dispatch_reservations.raise_task_floor(2)); // unknown reservation hole
    h.proof(gold,false);
    if(which==0) {
      assert(state->phase==executor::Phase::WAIT_ABORT && !state->runtime.checkpoint_baseline.valid && !state->imports);
      auto abort=h.outgoing();assert(abort.kind==handoff::Kind::ABORT && !abort.local_committed);
      abort.kind=handoff::Kind::ABORT_CLOSED;h.incoming(abort);
      assert(state->phase==executor::Phase::WAIT_CHECKPOINT && state->checkpoint.sequence_high_water==1 && state->checkpoint.handoff_high_water==19);
    } else {
      assert(state->runtime.checkpoint_baseline.valid && state->imports==1);
      const auto floor=state->runtime.provenance_event_high_water;
      if(which==1)h.in.cancel=true;
      if(which==2)++h.in.fence.base.epoch;
      if(which==3)++h.in.accepted_request;
      h.call();assert(state->revoked && state->phase==executor::Phase::WAIT_IMPORT_CONFIRMATION && state->control_pending);
      h.in.cancel=false;h.in.fence.base.epoch=7;h.in.accepted_request=101;
      auto original=h.outgoing();assert(original.kind==handoff::Kind::IMPORT_OK);
      assert(state->phase==executor::Phase::WAIT_ABORT && state->control_pending);
      auto abort=h.outgoing();assert(abort.kind==handoff::Kind::ABORT && abort.local_committed);
      auto old=original;old.kind=handoff::Kind::GRANTED;h.incoming(old);
      for(unsigned i=0;i<24;++i)h.call();
      assert(h.commands.empty() && h.actions.empty() && state->runtime.checkpoint_baseline.valid &&
        state->runtime.provenance_event_high_water==floor && state->runtime.tasks_retired==0 && state->imports==1);
    }
  }
}
} // namespace
int main(int argc,char** argv) {
  assert(argc==2);const std::string fixture=argv[1];wire(fixture);
  auto p=packet<1024>(bytes(fixture+"/v2/checkpoint_request.bin"));checkpoint::Request r;assert(checkpoint::decode(p,r));
  checkpoint::Response proof;assert(checkpoint::decode(packet<1024>(bytes(fixture+"/v2/checkpoint_response.bin")),r,proof));
  helper_reservation(fixture,proof);failures(fixture,proof);consecutive(fixture,proof);
  std::cout<<"FULL_CURRENT_EXECUTOR_ACTOR_PASS literal_control_bytes=7168 wire_reserved_rejects=20 full_key_mutants=5 early_wrong_grants=12 "
    <<"same_runtime_requests=2 host_windows_retired=8 import_stat_contribution=0 control_held_query_import_grant=1 "
    <<"real_helper_reject_abort=1 cancel_held_no_sequence_reuse=1 committed_cancel_base_request_revoke=3 source_shell_fences_controlled=1 "
    <<"real_hls_top_shell_rearm_NOT_RUN=1\n";
}
