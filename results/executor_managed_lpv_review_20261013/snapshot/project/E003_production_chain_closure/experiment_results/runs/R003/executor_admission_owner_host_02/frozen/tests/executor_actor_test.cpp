#include "laya_executor_actor.h"
#include "laya_graph_program_hls.h"
#include "laya_graph_program_sequencer.h"
#include "laya_graph_program_state.h"
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
void admission_owner_wire(const std::string& fixture) {
  const auto literal=packet<1024>(bytes(fixture+"/admission_owner.bin"));
  admission_owner::Record r;assert(admission_owner::decode(literal,r) &&
    admission_owner::encode(r)==literal && r.physical.known_roles==(1u<<6));
  unsigned rejected=0;
  for(unsigned offset:{0u,4u,6u,8u,12u,15u,16u,24u,32u,63u,64u,72u,80u,148u,159u,160u,576u,727u,728u,736u,888u,1023u}) {
    auto bad=literal;bad[offset]^=1;
    // Nonzero session/request/id changes are legal wire values, so use zero
    // for those fields. They are bound by the owner comparison at the hub.
    if(offset==16 || offset==24 || offset==64 || offset==72)
      portal::put(bad.data(),offset,0,8);
    if(offset==12)portal::put(bad.data(),12,0,4);
    if(offset==80)portal::put(bad.data(),80,0,2);
    if(offset==727)portal::put(bad.data(),720,0,8);
    if(offset==736)portal::put(bad.data(),736,UINT64_MAX,8);
    admission_owner::Record out;out.session=999;
    assert(!admission_owner::decode(bad,out) && !out.session && !out.accepted_request);
    ++rejected;
  }
  auto state=std::make_unique<executor::State>();Harness h(*state,fixture);h.call();
  assert(state->phase==executor::Phase::WAIT_CHECKPOINT && state->admitted_owner_valid &&
    admission_owner::encode(state->admitted_owner)==literal && !state->checkpoint.hold_reserved &&
    state->checkpoint.sequence_high_water==0 && h.query.empty() && h.commands.empty());
  const auto before=std::vector<uint8_t>(reinterpret_cast<const uint8_t*>(&state->runtime),
    reinterpret_cast<const uint8_t*>(&state->runtime)+sizeof(state->runtime));
  const auto original=state->admitted_owner;
  for(unsigned which=0;which<7;++which) {
    auto physical=original.physical;auto session=original.session,instance=original.accepted_request;
    if(which==0)session=0;
    if(which==1)instance=0;
    if(which==2)physical.role[6].epoch=0;
    if(which==3)physical.role[6].address+=1;
    if(which==4)--physical.role[6].capacity;
    if(which==5)physical.role[5]={7,0x1300000000ull,64}; // unknown role cannot carry mapping
    if(which==6)physical.known_roles|=1u<<13;
    admission_owner::Record out;out.session=999;
    assert(!admission_owner::capture(state->runtime,h.ports,session,instance,physical,out) && !out.session);
  }
  assert(std::equal(before.begin(),before.end(),reinterpret_cast<const uint8_t*>(&state->runtime)));
  std::ofstream f(fixture+"/actual_admission_owner.bin",std::ios::binary);
  const auto actual=admission_owner::encode(state->admitted_owner);
  f.write(reinterpret_cast<const char*>(actual.data()),actual.size());assert(f);
  std::cout<<"FULL_CURRENT_ADMISSION_OWNER_HOST_PASS bytes=1024 wire_rejects="<<rejected
    <<" capture_rejects=7 actual_LYRQ_LYMP=1 before_HOLD=1 runtime_unchanged=1 physical_STATE0_controlled=1 all13BO_NOT_RUN=1\n";
}
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
void close_wire(const std::string& fixture) {
  unsigned cases=0;
  for(const std::string kind:{"close","closed"})
    for(const std::string status:{"ok","error"})for(unsigned commit=0;commit<2;++commit) {
      const auto p=packet<1024>(bytes(fixture+"/"+kind+"_"+status+"_c"+std::to_string(commit)+".bin"));
      handoff::Message m;assert(handoff::decode(p,m) && handoff::encode(m)==p &&
        m.local_committed==bool(commit) && bool(m.result)==(status=="ok"));++cases;
      for(unsigned offset:{0u,4u,6u,9u,12u,28u,664u,678u,744u,768u,793u,1023u}) {
        auto bad=p;bad[offset]^=1;handoff::Message out;out.session=99;
        assert(!handoff::decode(bad,out) && !out.session);
      }
      for(unsigned unknown:{0u,10u,11u,127u,255u}) {
        auto bad=p;bad[8]=unknown;handoff::Message out;out.session=99;
        assert(!handoff::decode(bad,out) && !out.session);
      }
      auto bad=p;bad[792]=2;handoff::Message out;assert(!handoff::decode(bad,out));
      bad=p;portal::put(bad.data(),680,0,8);assert(!handoff::decode(bad,out));
      if(status=="ok") {bad=p;bad[24]=1;assert(!handoff::decode(bad,out));}
    }
  assert(cases==8);
}
void actual_closed_capture(const std::string& fixture,const std::string& directory) {
  unsigned frames=0;
  for(const std::string status:{"ok","error"})for(unsigned commit=0;commit<2;++commit) {
    const std::string name="closed_"+status+"_c"+std::to_string(commit);
    std::ifstream file(directory+"/"+name+"_capture.hex");assert(file);
    handoff::Packet captured{};
    for(unsigned beat=0;beat<16;++beat) {
      std::string line;assert(bool(file>>line) && line.size()==128);
      for(unsigned byte=0;byte<64;++byte)
        captured[beat*64+byte]=uint8_t(std::stoul(line.substr(126-2*byte,2),nullptr,16));
    }
    std::string extra;assert(!(file>>extra));
    handoff::Message decoded;
    assert(handoff::decode(captured,decoded) && handoff::encode(decoded)==captured &&
      decoded.kind==handoff::Kind::CLOSED && decoded.local_committed==bool(commit) &&
      bool(decoded.result)==(status=="ok") && decoded.binding.handoff_epoch==1 &&
      captured==packet<1024>(bytes(fixture+"/shell_"+name+".bin")));
    ++frames;
  }
  assert(frames==4);
}
void finish_managed_close(Harness& h,const std::string& fixture,
                          const program_wire::ResultPacket& consumed,const std::string& name) {
  auto& s=h.state;
  assert(s.managed_close && s.phase==executor::Phase::WAIT_RESULT_CONSUMED);
  const auto before=std::vector<uint8_t>(reinterpret_cast<const uint8_t*>(&s.runtime),
    reinterpret_cast<const uint8_t*>(&s.runtime)+sizeof(s.runtime));
  const auto task=s.runtime.last_task_id;
  const auto lpv=s.runtime.provenance_event_high_water;
  const auto producer=s.runtime.producer_request_high_water;
  // An untagged last-read or a foreign syntactically valid result has no
  // managed close authority. The full result belongs to the old admitted A/K.
  h.in.result_consumed=true;h.call();h.in.result_consumed=false;
  assert(s.phase==executor::Phase::WAIT_RESULT_CONSUMED && !s.control_pending);
  auto wrong=s.result;++wrong.identity.request_id;
  h.in.host_result_valid=true;h.in.host_result=program_wire::encode(wrong);h.call();
  assert(s.phase==executor::Phase::WAIT_RESULT_CONSUMED && !s.managed_result_consumed && !s.result_consumed_pending);
  h.in.host_result=consumed;h.call();h.in.host_result_valid=false;
  assert(s.phase==executor::Phase::WAIT_CLOSE && s.control_pending && s.managed_result_consumed && !s.result_consumed_pending);
  auto expected=s.control_request;assert(expected.kind==handoff::Kind::CLOSE && expected.local_committed);
  const auto literal=packet<1024>(bytes(fixture+(expected.result?"/close_ok_c1.bin":"/close_error_c1.bin")));
  assert(handoff::encode(expected)==literal);
  auto closed=expected;closed.kind=handoff::Kind::CLOSED;
  h.incoming(closed);assert(!s.closed_consumed && s.phase==executor::Phase::WAIT_CLOSE);
  for(unsigned i=0;i<12;++i) {h.call();assert(s.control_pending && handoff::encode(s.control_request)==literal);}
  auto actual=h.outgoing();assert(handoff::encode(actual)==literal);
  for(unsigned which=0;which<9;++which) {
    auto foreign=closed;
    if(which==0)++foreign.session;
    if(which==1)++foreign.accepted_request;
    if(which==2)++foreign.binding.source.sequence;
    if(which==3)++foreign.binding.handoff_epoch;
    if(which==4)++foreign.binding.source.identity.request_id;
    if(which==5)foreign.local_committed=false;
    if(which==6)foreign.result={Status::E_BUFFER,laya::detail(7,0,14)};
    if(which==7) {foreign.result={Status::E_PROTOCOL,laya::detail(7,0,15)};}
    if(which==8)foreign.kind=handoff::Kind::GRANTED,foreign.result=ok();
    h.incoming(foreign);assert(s.phase==executor::Phase::WAIT_CLOSE && !s.closed_consumed);
  }
  // Persistently changed live inputs do not replace the old CLOSED owner.
  h.in.cancel=true;++h.in.fence.base.epoch;++h.in.session;++h.in.accepted_request;
  for(unsigned i=0;i<12;++i) {h.call();}
  h.incoming(closed);
  assert(s.closed_consumed && s.closed_requests==1 && s.phase==executor::Phase::WAIT_NEW_ADMISSION &&
    handoff::encode(s.closed_record)==packet<1024>(bytes(fixture+(closed.result?"/closed_ok_c1.bin":"/closed_error_c1.bin"))));
  std::ofstream capture(fixture+"/actual_close_"+name+".bin",std::ios::binary);
  capture.write(reinterpret_cast<const char*>(literal.data()),literal.size());assert(capture);
  h.in.cancel=false;h.in.request_valid=true;h.in.managed_close=false;
  for(unsigned i=0;i<24;++i) {h.call();}
  h.incoming(closed);
  assert(s.closed_requests==1 && s.admissions==1 && s.phase==executor::Phase::WAIT_NEW_ADMISSION &&
    h.commands.empty() && h.results.empty() && s.runtime.last_task_id==task &&
    s.runtime.provenance_event_high_water==lpv && s.runtime.producer_request_high_water==producer &&
    std::equal(before.begin(),before.end(),reinterpret_cast<const uint8_t*>(&s.runtime)));
}
void managed_success_host(const std::string& fixture,const checkpoint::Response& gold) {
  auto state=std::make_unique<executor::State>();Harness h(*state,fixture);h.in.managed_close=true;
  h.start_hold();h.held(19);checkpoint::Request q;assert(checkpoint::decode(dequeue<1024>(h.query),q));
  h.proof(gold,false);auto m=h.outgoing();m.kind=handoff::Kind::GRANTED;h.incoming(m);
  for(unsigned i=0;i<10000 && state->phase!=executor::Phase::WAIT_RESULT_CONSUMED;++i)h.call(true);
  assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED && state->runtime.tasks_retired==4 &&
    state->runtime.last_task_id==8 && h.producers==4 && h.results.size()==4);
  const auto r=dequeue<256>(h.results);program_wire::Result decoded;assert(program_wire::decode(r,decoded) && decoded.result);
  finish_managed_close(h,fixture,r,"success");
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

// These cases keep the actual actor/port/FSM and codecs.  The bounded peer
// supplies remote terminals without a reset of the static production adapter;
// the two normal requests above separately retain the real adapter path.
struct Peer {
  Harness& h;
  std::vector<transaction::Request> requests;
  unsigned producers=0,ends=0,invalidates=0;
  bool pending=false;
  transaction::Request held;
  explicit Peer(Harness& harness):h(harness) {}
  bool take() {
    if(pending || h.tx.transaction_request.size()<transaction::kRequestBeats)return false;
    assert(transaction::decode(dequeue<transaction::kRequestBytes>(h.tx.transaction_request),held));
    requests.push_back(held);pending=true;return true;
  }
  transaction::CompletionPacket complete(bool producer_external=false) {
    assert(pending);pending=false;
    if(held.kind==transaction::Kind::PRODUCER_TRANSACTION) {
      if(!producer_external && h.state.revoked)
        return transaction::encode(transaction::make_local_reject(held,
            {Status::E_PROTOCOL,laya::detail(7,0,14)}));
      ++producers;
      return transaction::encode(transaction::make_completion(held,producer_success(held.producer),true));
    }
    assert(held.kind==transaction::Kind::PROVENANCE_TRANSACTION);
    ends+=held.provenance.action==provenance::Action::END;
    invalidates+=held.provenance.action==provenance::Action::INVALIDATE;
    return transaction::encode(transaction::make_completion(held,provenance_response(held.provenance),true));
  }
  void call() {h.call();if(take())enqueue(h.tx.transaction_completion,complete());}
};

action::Request granted_action(Harness& h,const checkpoint::Response& gold) {
  h.start_hold();h.held(19);
  checkpoint::Request q;assert(checkpoint::decode(dequeue<1024>(h.query),q));
  h.proof(gold,false);auto m=h.outgoing();assert(m.kind==handoff::Kind::IMPORT_OK);
  m.kind=handoff::Kind::GRANTED;h.incoming(m);
  for(unsigned i=0;i<4;++i)h.call();
  assert(h.state.phase==executor::Phase::RUN_ACTION && h.state.port.beat==0);
  program_wire::Command command;assert(program_wire::decode(dequeue<256>(h.commands),command));
  program::State graph;assert(program::begin(graph,command.identity));
  assert(program::seed_slot(graph,command.source.slot,command.source.owner,command.source.version));
  action::Request a;assert(program::prepare_norm(graph,command.source.slot,1,Op::LN_ATTN,2,1,
      Buffer::NORM,0,0,0,a));return a;
}

void pulse(Harness& h,unsigned which) {
  const auto saved=h.in;
  if(which==0)++h.in.fence.base.epoch;
  if(which==1)h.in.fence.base.address+=4096;
  if(which==2)h.in.fence.base.capacity-=4096;
  if(which==3)++h.in.session;
  if(which==4)++h.in.accepted_request;
  if(which==5)h.in.cancel=true;
  if(which==6)h.in.fence.source_held=false;
  if(which==7)h.in.fence.target_held=false;
  if(which==8)h.in.fence.predecessor_dispatch_held=false;
  if(which==9)++h.in.fence.handoff_epoch;
  if(which==10)h.in.fence.physical_quiescent=false;
  h.call();h.in=saved;assert(h.state.revoked);
}

void run_action_revocation(const std::string& fixture,const checkpoint::Response& gold) {
  for(unsigned stage=0;stage<5;++stage)for(unsigned which=0;which<(stage<3?11u:6u);++which) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    auto a=granted_action(h,gold);enqueue(h.actions,action::encode(a));Peer peer(h);
    if(stage==1)for(unsigned i=0;i<3;++i)h.call();
    if(stage==2)for(unsigned i=0;i<8;++i)h.call();
    if(stage>=3) {
      for(unsigned i=0;i<2000;++i) {
        h.call();
        if(!peer.take())continue;
        const bool wanted=stage==3?
            peer.held.kind==transaction::Kind::PROVENANCE_TRANSACTION &&
              peer.held.provenance.action==provenance::Action::BEGIN:
            peer.held.kind==transaction::Kind::PRODUCER_TRANSACTION;
        if(wanted)break;
        enqueue(h.tx.transaction_completion,peer.complete());
      }
      assert(peer.pending && state->runtime.generated_store.active &&
          state->runtime.generated_store.source_lease_active && !state->runtime.tasks_retired);
      // Active work may own the fences and have real outstanding debt.  Its
      // old completion/END must keep moving; these inputs do not revoke it.
      h.in.fence.physical_quiescent=h.in.fence.source_held=h.in.fence.target_held=false;
      h.call();assert(!state->revoked);
    }
    const auto task_before=state->runtime.dispatch_reservations.task_high_water(state->runtime.last_task_id);
    const auto event_before=state->runtime.provenance_event_high_water;
    pulse(h,which);
    auto stale=state->control_request;stale.kind=handoff::Kind::GRANTED;
    h.incoming(stale);assert(state->revoked && state->imports==1);
    if(stage==0) {
      for(unsigned i=0;i<24;++i)h.call();
      assert(h.actions.size()==8 && state->port.beat==0 &&
          state->port.machine.action_high_water==0 && !state->runtime.lifecycle_action.active &&
          h.tx.transaction_request.empty() && state->runtime.provenance_event_high_water==event_before &&
          state->runtime.dispatch_reservations.task_high_water(state->runtime.last_task_id)==task_before &&
          !state->runtime.producer_request_high_water && !state->runtime.tasks_retired);
      continue;
    }
    if(stage>=3) {
      const auto packet=peer.complete(stage==4);
      for(unsigned i=0;i<14;++i)h.tx.transaction_completion.write(pack(packet,i));
      for(unsigned i=0;i<14;++i)h.call();
      for(unsigned i=0;i<12;++i) {h.call();assert(state->runtime.generated_store.active &&
          !state->runtime.tasks_retired && state->port.machine.phase==lifecycle::Phase::TX_READ);}
      h.tx.transaction_completion.write(pack(packet,14));h.call();
      for(unsigned i=0;i<12;++i) {h.call();assert(state->runtime.generated_store.active && !state->runtime.tasks_retired);}
      h.tx.transaction_completion.write(pack(packet,15));
    }
    for(unsigned i=0;i<3000 && state->port.phase!=lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED;++i)peer.call();
    assert(state->port.phase==lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED && h.completions.size()==4 &&
        !state->runtime.lifecycle_action.active && !state->runtime.generated_store.active &&
        !state->runtime.generated_store.source_lease_active && !peer.pending &&
        h.tx.transaction_request.empty() && h.tx.transaction_completion.empty());
    action::Completion done;assert(action::decode(dequeue<256>(h.completions),done));
    assert(!done.result && done.identity.request_id==1101 && done.ordinal==a.ordinal &&
        done.retired_tasks==(stage>=3?1u:0u) && state->runtime.tasks_retired==done.retired_tasks &&
        peer.producers==(stage==4?1u:0u) && peer.ends==(stage>=3?1u:0u) &&
        peer.invalidates==(stage>=3?1u:0u));
    for(const auto& q:peer.requests) {
      if(q.kind==transaction::Kind::PROVENANCE_TRANSACTION)assert(numeric_identity_equal(q.provenance.identity,a.identity));
      else assert(numeric_identity_equal(q.producer.identity,a.identity));
    }
    // Consume the old safe completion before testing a queued successor.
    auto next=a;++next.ordinal;enqueue(h.actions,action::encode(next));
    h.action_consumed=true;h.call();assert(state->port.phase==lifecycle::PortPhase::READ_ACTION);
    const auto old_task=state->runtime.last_task_id;
    const auto old_event=state->runtime.provenance_event_high_water;
    for(unsigned i=0;i<24;++i)h.call();
    assert(state->revoked && h.actions.size()==8 && state->port.beat==0 &&
        state->port.machine.action_high_water==a.ordinal && state->runtime.last_task_id==old_task &&
        state->runtime.provenance_event_high_water==old_event && h.tx.transaction_request.empty());
  }
}

void grant_only(Harness& h,const checkpoint::Response& gold) {
  h.start_hold();h.held(19);
  checkpoint::Request q;assert(checkpoint::decode(dequeue<1024>(h.query),q));
  h.proof(gold,false);auto m=h.outgoing();m.kind=handoff::Kind::GRANTED;h.incoming(m);
  for(unsigned i=0;i<4;++i)h.call();
  assert(h.state.phase==executor::Phase::RUN_ACTION && h.commands.size()==4);
}
program_pending::Key old_program_key(const Harness& h) {
  return {h.state.session,h.state.accepted_request_high_water,
    h.state.checkpoint.pending.source.sequence,h.state.checkpoint.pending.handoff_epoch};
}
void pending_wire(const std::string& fixture) {
  const auto literal=packet<1024>(bytes(fixture+"/pending.bin"));
  program_pending::Record r;
  assert(program_pending::decode(literal,r) && program_pending::encode(r)==literal);
  const unsigned reserved[]={0,4,6,8,9,15,48,255,256+10,512+511};
  for(unsigned i:reserved) {
    auto bad=literal;bad[i]^=1;program_pending::Record out;out.key.session=999;
    assert(!program_pending::decode(bad,out) && !out.key.session);
  }
  for(unsigned i=0;i<4;++i) {
    auto bad=literal;portal::put(bad.data(),16+8*i,0,8);
    program_pending::Record out;assert(!program_pending::decode(bad,out));
  }
}
void cancel_drain_host(const std::string& fixture,const checkpoint::Response& gold,bool managed=false) {
  pending_wire(fixture);
  unsigned successful=0,bad_frames=0,bad_keys=0;
  // Same actor/actual explicit program logic; no stream reset or removal is
  // used to finish a request. HLS software queues are unbounded; these waits
  // prove notification/state retention, not physical depth2 scheduling.
  for(unsigned mode=0;mode<3;++mode) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    program_hls::State graph;h.in.managed_close=managed;grant_only(h,gold);auto key=old_program_key(h);
    auto program_call=[&]() {
      program_hls::step(graph,state->revoked || h.in.cancel,state->program_result_consumed,
        &key,h.commands,h.program_results,h.actions,h.completions);
    };
    for(unsigned i=0;i<6;++i)program_call();
    assert(graph.phase==program_hls::Phase::WRITE_ACTION && graph.graph.action_active &&
      h.commands.empty() && h.actions.empty());
    program_pending::Packet owner;assert(program_hls::observe_pending(graph,owner));
    assert(owner==packet<1024>(bytes(fixture+"/pending.bin")));
    const auto before=std::vector<uint8_t>(reinterpret_cast<const uint8_t*>(&state->runtime),
      reinterpret_cast<const uint8_t*>(&state->runtime)+sizeof(state->runtime));
    if(mode==0)for(unsigned i=0;i<8;++i)program_call();
    if(mode==1)for(unsigned i=0;i<2;++i)program_call();
    // mode2 selects cancel reception on the same step that would otherwise
    // read the normal first beat. The normal port never acquires that frame.
    h.in.cancel_drain_valid=true;h.in.cancel_drain_record=owner;
    h.in.cancel=true;h.call();h.in.cancel=false;
    assert(state->revoked && state->port.beat==0 &&
      state->cancel_consumer.phase==executor::CancelPhase::READ_ACTION);
    if(mode!=0) {
      for(unsigned i=0;i<12;++i)h.call();
      assert(state->cancel_consumer.beat==(mode==1?2u:0u) &&
        !state->port.machine.action_high_water && h.completions.empty());
      while(graph.beat<6) {program_call();h.call();}
      for(unsigned i=0;i<12;++i) {h.call();assert(state->cancel_consumer.beat==6 &&
        !state->port.machine.action_high_water && h.completions.empty());}
      program_call();h.call();
      for(unsigned i=0;i<12;++i) {h.call();assert(state->cancel_consumer.beat==7 &&
        !state->port.machine.action_high_water && h.completions.empty());}
      program_call();h.call();
    }
    for(unsigned i=0;i<100 && state->cancel_consumer.phase!=executor::CancelPhase::WAIT_COMPLETION_CONSUMED;++i)h.call();
    assert(state->cancel_consumer.phase==executor::CancelPhase::WAIT_COMPLETION_CONSUMED &&
      h.actions.empty() && h.completions.size()==4 && state->port.machine.action_high_water==1);
    const auto done=state->cancel_consumer.completion;
    assert(action::validate(done) && !done.result && !done.retired_tasks &&
      !done.first_task_id && !done.last_task_id && done.flags==79 &&
      state->port.machine.phase==lifecycle::Phase::IDLE);
    assert(state->cancel_consumer.completion_packet==packet<256>(bytes(fixture+"/cancel_completion.bin")));
    for(unsigned i=0;i<2;++i)program_call();
    for(unsigned i=0;i<12;++i) {h.call();assert(h.completions.size()==2 &&
      graph.graph.action_active && state->cancel_consumer.phase==executor::CancelPhase::WAIT_COMPLETION_CONSUMED);}
    program_call();
    for(unsigned i=0;i<12;++i) {h.call();assert(h.completions.size()==1 && graph.graph.action_active &&
      state->cancel_consumer.phase==executor::CancelPhase::WAIT_COMPLETION_CONSUMED);}
    program_call();assert(h.completions.empty());h.action_consumed=true;h.call();
    assert(state->cancel_consumer.phase==executor::CancelPhase::DONE);
    for(unsigned i=0;i<100 && state->phase!=executor::Phase::WAIT_RESULT_CONSUMED;++i) {program_call();h.call();}
    assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED && h.results.size()==4 &&
      graph.graph.pc==0 && graph.graph.action_high_water==1 && !graph.graph.action_active &&
      !graph.graph.slot[1].valid && state->port.machine.action_high_water==1 && state->results==1);
    program_wire::ResultPacket result{};
    for(unsigned beat=0;beat<4;++beat) {
      if(beat>=2)for(unsigned i=0;i<12;++i) {
        program_call();h.call();assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED &&
          h.results.size()==4-beat && !state->result_consumed_pending);
      }
      const auto w=h.results.read();
      for(unsigned byte=0;byte<64;++byte)result[beat*64+byte]=uint8_t(w.range(byte*8+7,byte*8));
    }
    program_wire::Result decoded;
    assert(program_wire::decode(result,decoded) && !decoded.result && decoded.action_ordinal==1 &&
      !(decoded.flags&program_wire::LOCAL_REJECT) && result==packet<256>(bytes(fixture+"/cancel_result.bin")));
    // The actual Host-side last read is acknowledged. It is retained, but
    // cannot substitute for the still-missing bound CLOSE/safe-release path.
    if(managed) {
      assert(graph.phase==program_hls::Phase::READ_COMMAND && !graph.bound_command);
      finish_managed_close(h,fixture,result,"cancel"+std::to_string(mode));
    }
    else {h.in.result_consumed=true;h.call();h.in.result_consumed=false;}
    assert(managed?state->managed_result_consumed:state->result_consumed_pending);
    for(unsigned i=0;i<24;++i) {program_call();h.call();assert(state->phase==(managed?executor::Phase::WAIT_NEW_ADMISSION:executor::Phase::WAIT_RESULT_CONSUMED));}
    assert(std::equal(before.begin(),before.end(),reinterpret_cast<const uint8_t*>(&state->runtime)) &&
      h.tx.transaction_request.empty() && h.tx.transaction_completion.empty() &&
      !h.events && !h.producers && !state->runtime.tasks_retired &&
      !state->runtime.lifecycle_action.active && !state->runtime.generated_store.active);
    if(mode==0) {
      enqueue(h.actions,action::encode(state->cancel_consumer.owner.action));
      for(unsigned i=0;i<24;++i)h.call();
      assert(h.actions.size()==8 && h.completions.empty() && state->results==1);
    }
    ++successful;
  }
  for(unsigned which=0;which<8;++which) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    program_hls::State graph;grant_only(h,gold);auto key=old_program_key(h);
    for(unsigned i=0;i<6;++i)program_hls::step(graph,false,false,&key,h.commands,h.program_results,h.actions,h.completions);
    program_pending::Packet owner;assert(program_hls::observe_pending(graph,owner));
    auto a=graph.graph.pending;
    if(which==0)++a.ordinal;
    if(which==1)++a.source.version;
    if(which==2)++a.source.owner.ref.epoch;
    if(which==3)++a.target_slot_version;
    if(which==4)++a.pc;
    if(which==5)a.source.slot=2;
    if(which==6)a.layer=2;
    auto bad=action::encode(a);if(which==7)bad[511]=1;
    if(which!=7)assert(action::validate(a));
    enqueue(h.actions,bad);h.in.cancel=true;h.in.cancel_drain_valid=true;h.in.cancel_drain_record=owner;
    for(unsigned i=0;i<20 && state->phase!=executor::Phase::ISOLATED;++i)h.call();
    assert(state->phase==executor::Phase::ISOLATED && !state->port.machine.action_high_water &&
      h.completions.empty() && h.results.empty() && h.tx.transaction_request.empty() &&
      !state->runtime.tasks_retired && !state->runtime.producer_request_high_water);
    ++bad_frames;
  }
  for(unsigned which=0;which<4;++which) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    program_hls::State graph;grant_only(h,gold);auto key=old_program_key(h);
    for(unsigned i=0;i<14;++i)program_hls::step(graph,false,false,&key,h.commands,h.program_results,h.actions,h.completions);
    program_pending::Packet owner;assert(program_hls::observe_pending(graph,owner));
    portal::put(owner.data(),16+8*which,portal::get(owner.data(),16+8*which,8)+1,8);
    h.in.cancel=true;h.in.cancel_drain_valid=true;h.in.cancel_drain_record=owner;h.call();
    assert(state->phase==executor::Phase::ISOLATED && h.actions.size()==8 &&
      !state->port.machine.action_high_water && h.completions.empty() && h.tx.transaction_request.empty());
    ++bad_keys;
  }
  // Command cancellation before first consumption, and after two actual
  // reads: the bound program drains the issued frame and emits the real
  // ordinal-zero local result, with no pending action or fabricated LAC1.
  for(unsigned partial=0;partial<2;++partial) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    program_hls::State graph;h.in.managed_close=managed;grant_only(h,gold);auto key=old_program_key(h);
    if(partial)for(unsigned i=0;i<2;++i)program_hls::step(graph,false,false,&key,h.commands,h.program_results,h.actions,h.completions);
    h.in.cancel=true;h.call();h.in.cancel=false;
    for(unsigned i=0;i<100 && state->phase!=executor::Phase::WAIT_RESULT_CONSUMED;++i) {
      program_hls::step(graph,state->revoked,state->program_result_consumed,&key,h.commands,h.program_results,h.actions,h.completions);h.call();
    }
    assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED && h.commands.empty() &&
      h.actions.empty() && h.completions.empty() && h.results.size()==4 &&
      !graph.graph.action_high_water && !state->port.machine.action_high_water && !state->runtime.tasks_retired);
    const auto actual_result=dequeue<256>(h.results);
    program_wire::Result r;assert(program_wire::decode(actual_result,r) &&
      !r.result && !r.action_ordinal && (r.flags&program_wire::LOCAL_REJECT));
    if(managed) {
      assert(graph.phase==program_hls::Phase::READ_COMMAND && !graph.bound_command);
      finish_managed_close(h,fixture,actual_result,"no_action"+std::to_string(partial));
    }
  }
  std::cout<<(managed?"FULL_CURRENT_EXECUTOR_CANCEL_DRAIN_CLOSE_COMPAT_PASS":"FULL_CURRENT_EXECUTOR_CANCEL_DRAIN_PASS")<<" pending_literal_bytes=1024 pending_wire_rejects=14 "
    <<"actual_program_successful_cancel_cases="<<successful<<" bad_frame_cases="<<bad_frames
    <<" bad_key_cases="<<bad_keys<<" real_program_no_action_cases=2 shared_action_highwater=1 "
    <<"completion_literal=1 result_literal=1 first_read_owner_unique=1 runtime_byte_unchanged=1 "
    <<"action_tail2_tail1_wait=1 completion_tail2_tail1_wait=1 zero_tasks_retired=1 zero_transactions=1 "
    <<"replay_no_second_completion=1 result_tail2_tail1_wait=1 "
    <<(managed?"Host_tagged_close_cases=5 ":"host_result_consumed_retained_no_CLOSE_no_rearm=1 ")
    <<"depth2_RTL_NOT_RUN=1 hardware_rearm_NOT_RUN=1\n";
}
// F19: real bound program error results reach the final actor write.
// Software queues have no depth limit. Tail read delays test retained facts;
// the co-present complete record tests the abstract consumer interface at the
// WRITE_RESULT -> WAIT_RESULT_CONSUMED boundary, not RTL FIFO timing.
void managed_result_boundary(const std::string& fixture,const checkpoint::Response& gold) {
  for(unsigned mode=0;mode<6;++mode) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    program_hls::State graph;h.in.managed_close=true;grant_only(h,gold);
    auto key=old_program_key(h);h.in.cancel=true;h.call();h.in.cancel=false;
    auto advance=[&]() {
      program_hls::step(graph,state->revoked,state->program_result_consumed,&key,
        h.commands,h.program_results,h.actions,h.completions);h.call();
    };
    for(unsigned i=0;i<100 && !(state->phase==executor::Phase::WRITE_RESULT && state->beat==3);++i)advance();
    assert(state->phase==executor::Phase::WRITE_RESULT && state->beat==3 && h.results.size()==3);
    const auto before=std::vector<uint8_t>(reinterpret_cast<const uint8_t*>(&state->runtime),
      reinterpret_cast<const uint8_t*>(&state->runtime)+sizeof(state->runtime));
    const auto S=state->checkpoint.sequence_high_water,H=state->checkpoint.handoff_high_water;
    const auto ordinal=state->port.machine.action_high_water;
    const auto expected=state->result_packet;
    if(mode<2)h.in.result_consumed=true;
    if(mode==2 || mode==3) {
      auto wrong=state->result;
      if(mode==2)++wrong.identity.request_id;
      else ++wrong.pc;
      h.in.host_result_valid=true;h.in.host_result=program_wire::encode(wrong);
      program_wire::Result decoded;assert(program_wire::decode(h.in.host_result,decoded));
    }
    if(mode==4) {h.in.host_result_valid=true;h.in.host_result=expected;}
    advance();
    assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED && !state->control_pending &&
      !state->result_consumed_pending && state->managed_result_consumed==(mode==4) && h.results.size()==4);
    if(mode!=1)h.in.result_consumed=false;
    if(mode==4)h.in.host_result_valid=false;
    program_wire::ResultPacket consumed{};
    for(unsigned beat=0;beat<4;++beat) {
      if(beat>=2)for(unsigned i=0;i<12;++i) {
        advance();assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED &&
          !state->control_pending && h.results.size()==4-beat && !state->result_consumed_pending);
      }
      const auto w=h.results.read();
      for(unsigned byte=0;byte<64;++byte)consumed[beat*64+byte]=uint8_t(w.range(byte*8+7,byte*8));
    }
    program_wire::Result decoded;assert(program_wire::decode(consumed,decoded) && consumed==expected &&
      !decoded.result && (decoded.flags&program_wire::LOCAL_REJECT));
    if(mode!=4) {
      for(unsigned i=0;i<12;++i) {advance();assert(state->phase==executor::Phase::WAIT_RESULT_CONSUMED &&
        !state->control_pending && !state->managed_result_consumed && !state->result_consumed_pending);}
      h.in.host_result_valid=true;h.in.host_result=consumed;
    }
    advance();h.in.host_result_valid=false;h.in.result_consumed=false;
    assert(state->phase==executor::Phase::WAIT_CLOSE && state->managed_result_consumed &&
      !state->result_consumed_pending && state->control_request.kind==handoff::Kind::CLOSE);
    const auto close=h.outgoing();auto closed=close;closed.kind=handoff::Kind::CLOSED;
    h.incoming(closed);h.incoming(closed);
    assert(state->closed_requests==1 && state->phase==executor::Phase::WAIT_NEW_ADMISSION &&
      state->checkpoint.sequence_high_water==S && state->checkpoint.handoff_high_water==H &&
      state->port.machine.action_high_water==ordinal && !state->runtime.tasks_retired &&
      !state->runtime.producer_request_high_water && h.tx.transaction_request.empty() &&
      std::equal(before.begin(),before.end(),reinterpret_cast<const uint8_t*>(&state->runtime)));
    std::cout<<"F19_RESULT_BOUNDARY_PASS case="<<mode<<" final_write_legacy_ignored=1 tagged_fact="<<state->managed_result_consumed
      <<" close_once="<<state->closed_requests<<" tail2_tail1_read_wait=1 runtime_unchanged=1\n";
  }
}
void helper_shell_stimuli(const std::string& fixture,const checkpoint::Response& gold,
                          const std::string& rtl_capture) {
  auto write=[&](const std::string& name,const auto& p) {
    std::ofstream f(fixture+"/"+name,std::ios::binary);assert(f);
    f.write(reinterpret_cast<const char*>(p.data()),p.size());assert(f);
  };
  for(unsigned fail=0;fail<2;++fail) {
    auto state=std::make_unique<executor::State>();Harness h(*state,fixture);
    h.start_hold();write("actual_helper_hold.bin",handoff::encode(state->control_request));
    h.held(1);const auto request=dequeue<1024>(h.query);
    write("actual_helper_query.bin",request);
    if(fail)assert(state->runtime.dispatch_reservations.raise_task_floor(2));
    auto p=gold;p.binding=state->checkpoint.pending;
    if(!rtl_capture.empty()) {
      std::ifstream f(rtl_capture);assert(f);checkpoint::Packet captured{};
      for(unsigned beat=0;beat<16;++beat) {
        std::string line;assert(bool(f>>line) && line.size()==128);
        for(unsigned byte=0;byte<64;++byte)
          captured[beat*64+byte]=uint8_t(std::stoul(line.substr(126-2*byte,2),nullptr,16));
      }
      assert(checkpoint::decode(captured,state->checkpoint.pending,p));
      assert(checkpoint::encode(p)==captured && p.task_floor==7 && p.lpv_floor==179 && p.target_epoch_floor==8);
    }
    write("helper_proof_stimulus.bin",checkpoint::encode(p));h.proof(p,false);
    const auto output=handoff::encode(state->control_request);
    if(fail) {
      assert(state->phase==executor::Phase::WAIT_ABORT && !state->control_request.local_committed &&
          !state->runtime.checkpoint_baseline.valid && !state->imports);
      write("actual_helper_abort.bin",output);
    } else {
      assert(state->phase==executor::Phase::WAIT_IMPORT_CONFIRMATION && state->control_request.local_committed &&
          state->runtime.checkpoint_baseline.valid && state->imports==1);
      auto literal=packet<1024>(bytes(fixture+"/control_3.bin"));portal::put(literal.data(),680,1,8);
      assert(output==literal);write("actual_helper_import_ok.bin",output);
    }
    assert(!state->runtime.tasks_retired && !state->runtime.owner_claims && !state->runtime.owner_leases);
  }
}
} // namespace
int main(int argc,char** argv) {
  assert(argc==2 || argc==3 || argc==4);const std::string fixture=argv[1];wire(fixture);admission_owner_wire(fixture);
  auto p=packet<1024>(bytes(fixture+"/v2/checkpoint_request.bin"));checkpoint::Request r;assert(checkpoint::decode(p,r));
  checkpoint::Response proof;assert(checkpoint::decode(packet<1024>(bytes(fixture+"/v2/checkpoint_response.bin")),r,proof));
  if(argc>=3 && std::string(argv[2])=="--request-close") {
    close_wire(fixture);
    if(argc==4)actual_closed_capture(fixture,argv[3]);
    managed_success_host(fixture,proof);cancel_drain_host(fixture,proof,true);managed_result_boundary(fixture,proof);
    std::cout<<"FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS wire_literals=8 wire_mutants=156 real_success_cases=1 real_cancel_cases=3 real_no_action_cases=2 "
      <<"F19_boundary_cases=6 managed_legacy_fact_separate=1 tagged_final_transition_retained=1 host_full_result_required=1 real_program_action_completion_results=1 exact_closed_error_commit=1 old_live_changed_close=1 "
      <<"closed_once_wait_new_admission=1 runtime_unchanged_close=1 actual_closed_rtl_capture_frames="<<(argc==4?4:0)
      <<" no_LGP_error_NOT_RUN=1 same_hardware_consumer_NOT_RUN=1 hardware_rearm_NOT_RUN=1\n";return 0;
  }
  if(argc==3 && std::string(argv[2])=="--cancel-drain") {cancel_drain_host(fixture,proof);return 0;}
  if(argc>=3) {
    assert(std::string(argv[2])=="--shell-stimuli");helper_shell_stimuli(fixture,proof,argc==4?argv[3]:"");
    std::cout<<"FULL_CURRENT_EXECUTOR_SHELL_HELPER_PASS actual_success_import=1 actual_hole_reject_abort=1 "
      <<"import_stats_zero=1 matched_literal_import=1 H1_S1=1 shell_grant_controlled=1 "
      <<"actual_rtl_capture="<<(argc==4)<<"\n";return 0;
  }
  helper_reservation(fixture,proof);failures(fixture,proof);consecutive(fixture,proof);
  run_action_revocation(fixture,proof);
  std::cout<<"FULL_CURRENT_EXECUTOR_ACTOR_PASS literal_control_bytes=7168 wire_reserved_rejects=20 full_key_mutants=5 early_wrong_grants=12 "
    <<"same_runtime_requests=2 host_windows_retired=8 import_stat_contribution=0 control_held_query_import_grant=1 "
    <<"real_helper_reject_abort=1 cancel_held_no_sequence_reuse=1 committed_cancel_base_request_revoke=3 source_shell_fences_controlled=1 "
    <<"F17_unread_partial_validate_cases=33 F17_active_begin_producer_cases=12 F17_revocation_persistent=1 "
    <<"F17_old_frame_cleanup_preserved=1 F17_completion_tail_backpressure=1 F17_active_debt_not_revocation=1 "
    <<"real_hls_top_shell_rearm_NOT_RUN=1\n";
}
