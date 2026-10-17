#include "laya_executor_checkpoint.h"
#include "laya_graph_program_sequencer.h"
#include "lifecycle_fixture_helpers.h"
#include <algorithm>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

using namespace laya;
using namespace lifecycle_fixture;
namespace {
std::vector<uint8_t> read(const std::string& path) {
  std::ifstream file(path, std::ios::binary); assert(file);
  return {std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>()};
}
template<std::size_t N> std::array<uint8_t, N> fixed(const std::vector<uint8_t>& data) {
  assert(data.size() == N); std::array<uint8_t,N> result{};
  std::copy(data.begin(), data.end(), result.begin()); return result;
}
checkpoint::Fence fence() {
  checkpoint::Fence f;
  f.base = {7, 0x1200000000ull, 16920576}; f.handoff_epoch = 19;
  f.physical_quiescent = f.predecessor_dispatch_held = f.source_held = f.target_held = true;
  return f;
}
void admitted(full::FullRuntime& rt, full::FullMemory& ports,
              std::vector<uint8_t>& io, std::vector<uint8_t>& aux) {
  ports = memory(); ports.io = io.data(); ports.io_bytes = io.size();
  ports.aux = aux.data();
  bootstrap::State admission; lifecycle::Port idle;
  assert(bootstrap::admit_new(admission, idle, rt, ports, {true,true}));
  assert(rt.request_valid && rt.model_header_valid && rt.tasks_retired == 0);
}
unsigned schema(const checkpoint::Packet& req_bytes, const checkpoint::Packet& resp_bytes) {
  checkpoint::Request req;
  assert(checkpoint::decode(req_bytes, req) && checkpoint::encode(req) == req_bytes);
  checkpoint::Response resp;
  assert(checkpoint::decode(resp_bytes, req, resp) && checkpoint::encode(resp) == resp_bytes);
  const unsigned offsets[] = {0,4,6,8,10,12,16,28,40,48,56,64,72,84,148,
      160,576,580,592,598,604,608,624,664,672,674,675,676,677,678,679,
      680,688,696,704,712,720,728,736,744,748,764,776,1023};
  for (unsigned off : offsets) {
    auto bad = resp_bytes; bad[off] ^= off == 10 ? 255 : 1;
    checkpoint::Response decoded = resp;
    assert(!checkpoint::decode(bad, req, decoded));
    assert(decoded.flags == 0 && decoded.binding.source.sequence == 0 &&
           decoded.known == 0 && decoded.task_floor == 0 &&
           decoded.binding.source.source.target_ref.id == Buffer::NONE);
  }
  auto bad = req_bytes; bad[752] = 1;
  checkpoint::Request clean = req;
  assert(!checkpoint::decode(bad, clean) && clean.source.sequence == 0);
  bad = req_bytes; bad[4] = 1;
  assert(!checkpoint::decode(bad, clean));
  checkpoint::Response negative;
  negative.binding = req; negative.result = {Status::E_BUFFER, laya::detail(4,1,9)};
  negative.flags = 3;
  checkpoint::Response bound;
  assert(!checkpoint::decode(checkpoint::encode(negative), req, bound));
  assert(bound.flags == 3 && bound.result.code == Status::E_BUFFER && !bound.known);
  return unsigned(sizeof(offsets)/sizeof(offsets[0])) + 2;
}

unsigned rejection_cases(const std::vector<uint8_t>& io_gold,
                         const std::vector<uint8_t>& aux_gold) {
  static full::FullRuntime runtimes[28];
  for (unsigned which = 0; which < 28; ++which) {
    auto io = io_gold, aux = aux_gold; full::FullMemory ports;
    auto& rt = runtimes[which]; admitted(rt, ports, io, aux);
    lifecycle::Port port; checkpoint::State state; checkpoint::Request req;
    auto live = fence();
    assert(checkpoint::prepare(state, port, rt, ports, {Buffer::HIDDEN,0,1}, live, req));
    checkpoint::Response proof;
    proof.binding = req; proof.result = ok(); proof.flags = checkpoint::kSuccessFlags;
    proof.known = proof.complete = checkpoint::kDomains;
    proof.task_floor = 4; proof.source_epoch_floor = 1;
    proof.target_state = checkpoint::TargetState::INACTIVE; proof.target_epoch_floor = 7;
    proof.lpv_floor = 23;
    switch (which) {
      case 0: ++proof.binding.source.identity.request_id; break;
      case 1: proof.binding.source.model_identity[0] ^= 1; break;
      case 2: ++proof.binding.source.source.target_ref.epoch; break;
      case 3: ++proof.binding.target.bank; break;
      case 4: ++proof.binding.target.offset; break;
      case 5: ++live.base.address; break;
      case 6: ++live.base.epoch; break;
      case 7: ++live.base.capacity; break;
      case 8: ++live.handoff_epoch; break;
      case 9: --proof.binding.source.sequence; break;
      case 10: proof.known &= ~checkpoint::TARGET; break;
      case 11: proof.complete &= ~checkpoint::LPV; break;
      case 12: proof.flags &= ~checkpoint::FRONTIER_COMPLETE; break;
      case 13: proof.target_state = checkpoint::TargetState::ACTIVE; break;
      case 14: (void)rt.dispatch_reservations.context(0,Op::LN_ATTN,2,1,0,RowSpace::TOKEN,0,16); break;
      case 15: proof.task_floor = kMaxEpoch - 3; break;
      case 16: proof.target_epoch_floor = kMaxEpoch; break;
      case 17: proof.lpv_floor = UINT64_MAX - 5; break;
      case 18: rt.producer_request_high_water = UINT64_MAX - 2; break;
      case 19: port.machine.action_high_water = UINT64_MAX; break;
      case 20: live.cancel = true; break;
      case 21: live.source_held = false; break;
      case 22: live.target_held = false; break;
      case 23: live.predecessor_dispatch_held = false; break;
      case 24: live.physical_quiescent = false; break;
      case 25:
        fill_owner(rt, {{Buffer::NORM,0,1},0,2,1,255,RowSpace::TOKEN,0,64,1024,Content::F32});
        break;
      case 26:
        rt.owners.record[0].ref = {Buffer::HIDDEN,0,1};
        rt.owners.record[0].max_claimed_epoch = 1;
        break;
      case 27: rt.last_execution_error = {Status::E_PROTOCOL,laya::detail(7,0,14)}; break;
    }
    // Whole-object byte comparison verifies that a late validation/capacity
    // refusal cannot leave a partially imported source, baseline or allocator.
    std::vector<uint8_t> before(sizeof(rt));
    std::memcpy(before.data(), &rt, sizeof(rt));
    program_wire::Command command; command.identity.request_id = 9999;
    const auto previous_command = program_wire::encode(command);
    const auto previous_state = state.phase;
    assert(!checkpoint::accept(state, port, rt, proof, live, command));
    assert(std::memcmp(before.data(), &rt, sizeof(rt)) == 0 &&
           program_wire::encode(command) == previous_command && state.phase == previous_state);
  }
  return 28;
}

void success_case(full::FullRuntime& rt, unsigned case_id,
                  const std::vector<uint8_t>& io_gold, const std::vector<uint8_t>& aux_gold,
                  const checkpoint::Packet& req_gold, const checkpoint::Packet& resp_gold) {
  auto io = io_gold, aux = aux_gold; full::FullMemory ports;
  admitted(rt, ports, io, aux);
  const uint32_t task_base = case_id == 0 ? 4 : case_id == 1 ? 7 : 3;
  const uint64_t remote_lpv = case_id == 0 ? 23 : case_id == 1 ? 97 : 41;
  const uint32_t target_epoch = case_id == 0 ? 7 : case_id == 1 ? 17 : 5;
  const uint64_t producer_base = case_id == 0 ? 0 : 11;
  const uint64_t action_base = case_id == 0 ? 0 : 17;
  // Existing locally retired work is retained. External baseline import
  // contributes zero; no fake prior completion is emitted by the helper.
  const uint32_t local_retired = case_id == 2 ? 2 : 0;
  for (unsigned i = 0; i < local_retired; ++i) {
    const auto ctx = rt.dispatch_reservations.context(rt.last_task_id,Op::ADD_RESIDUAL,2,0,0,RowSpace::TOKEN,0,16);
    TaskDone done; done.task_id = ctx.task_id; done.drained = true;
    assert(full::full_retire_prepared_task(rt,ctx,done));
  }
  rt.producer_request_high_water = producer_base;
  rt.provenance_event_high_water = case_id == 2 ? 119 : 0;
  // Preserve larger local Ref history without creating a target READY owner.
  const uint32_t local_target = case_id == 2 ? 31 : target_epoch;
  assert(rt.dispatch_reservations.raise_ref_floor(Buffer::NORM,0,0,local_target));
  lifecycle::Port port; port.machine.action_high_water = action_base;
  checkpoint::State state; checkpoint::Request req;
  const auto live = fence();
  assert(checkpoint::prepare(state,port,rt,ports,{Buffer::HIDDEN,0,1},live,req));
  if (case_id == 0) assert(checkpoint::encode(req) == req_gold);
  checkpoint::Response proof;
  assert(checkpoint::decode(resp_gold, req, proof));
  proof.task_floor = task_base; proof.lpv_floor = remote_lpv;
  proof.target_epoch_floor = target_epoch;
  const auto previous_claims = rt.owner_claims, previous_leases = rt.owner_leases;
  const uint32_t previous_op = rt.op_calls[uint8_t(Op::ADD_RESIDUAL)];
  program_wire::Command command;
  assert(checkpoint::accept(state,port,rt,proof,live,command));
  assert(rt.last_task_id == task_base && rt.tasks_retired == local_retired &&
         rt.owner_claims == previous_claims && rt.owner_leases == previous_leases &&
         rt.op_calls[uint8_t(Op::ADD_RESIDUAL)] == previous_op &&
         rt.op_calls[uint8_t(Op::LN_ATTN)] == 0 &&
         rt.checkpoint_baseline.valid && rt.checkpoint_baseline.task_base == task_base &&
         rt.checkpoint_baseline.local_retired_at_import == local_retired &&
         rt.producer_request_high_water == producer_base &&
         port.machine.action_high_water == action_base);
  for (const auto& o : rt.owners.record)
    if (o.ref.id == Buffer::NORM)
      assert(!o.valid && o.state == CacheState::INVALID && o.max_claimed_epoch == local_target);
  assert(!checkpoint::accept(state,port,rt,proof,live,command));
  // A fresh helper object cannot apply an already-consumed handoff twice.
  checkpoint::State fresh; checkpoint::Request unused;
  assert(!checkpoint::prepare(fresh,port,rt,ports,{Buffer::HIDDEN,0,1},live,unused));
  program::State graph; graph.action_high_water = action_base;
  assert(program::begin(graph,command.identity));
  assert(program::seed_slot(graph,command.source.slot,command.source.owner,command.source.version));
  action::Request action_request;
  assert(program::prepare_norm(graph,0,1,Op::LN_ATTN,2,1,Buffer::NORM,0,0,0,action_request));
  assert(action_request.ordinal == action_base + 1);
  // Host FIFO streams and remote responses are controlled; only the actual
  // program helper, lifecycle port/FSM and C++ adapter execute here.
  hls::stream<ap_uint<512>> actions, completions;
  enqueue(actions, action::encode(action_request));
  Streams streams; unsigned events=0, producers=0; uint32_t next_task=task_base+1;
  const uint64_t lpv_base = rt.provenance_event_high_water;
  for (unsigned cycle=0; cycle<100000 && completions.size()<action::kCompletionBeats; ++cycle) {
    lifecycle::port_step(port,rt,ports,false,false,actions,completions,
                         streams.transaction_request,streams.transaction_completion);
    laya_command_provenance_adapter(false,streams.transaction_request,streams.transaction_completion,
        streams.compute_command,streams.compute_response,streams.provenance_command,
        streams.provenance_response,streams.producer_request,streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request event;
      assert(provenance::decode(dequeue<provenance::kRequestBytes>(streams.provenance_command),event));
      assert(event.event_seq == lpv_base + ++events);
      if (event.action == provenance::Action::CLAIM)
        assert(event.descriptor[0].target_ref.epoch == local_target + 1);
      if (event.action == provenance::Action::BEGIN) assert(event.context.task_id == next_task++);
      enqueue(streams.provenance_response,provenance::encode(provenance_response(event)));
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request request;
      assert(producer::decode(dequeue<producer::kRequestBytes>(streams.producer_request),request));
      assert(request.request_seq == producer_base + ++producers);
      enqueue(streams.producer_completion,producer::encode(producer_success(request)));
    }
  }
  assert(completions.size() == action::kCompletionBeats && events == 10 && producers == 4);
  action::Completion done;
  assert(action::decode(dequeue<action::kCompletionBytes>(completions),done));
  assert(done.result && done.first_task_id == task_base+1 && done.last_task_id == task_base+4 &&
         done.retired_tasks == 4 && rt.tasks_retired == local_retired+4 &&
         rt.last_task_id == task_base+4 && rt.op_calls[uint8_t(Op::LN_ATTN)] == 4);
  assert(program::accept_completion(graph,done) && graph.pc == 1);
  lifecycle::port_step(port,rt,ports,false,true,actions,completions,
                       streams.transaction_request,streams.transaction_completion);
  assert(port.phase == lifecycle::PortPhase::READ_ACTION && actions.empty() && completions.empty() &&
         streams.transaction_request.empty() && streams.transaction_completion.empty() &&
         streams.provenance_command.empty() && streams.provenance_response.empty() &&
         streams.producer_request.empty() && streams.producer_completion.empty());
}
} // namespace
int main(int argc,char** argv) {
  assert(argc == 2); const std::string path=argv[1];
  const auto io=read(path+"/v1/request.bin"), aux=read(path+"/v1/aux_header.bin");
  const auto req=fixed<checkpoint::kBytes>(read(path+"/checkpoint_request.bin"));
  const auto resp=fixed<checkpoint::kBytes>(read(path+"/checkpoint_response.bin"));
  const unsigned wire_negatives=schema(req,resp), import_negatives=rejection_cases(io,aux);
  static full::FullRuntime success[3];
  for(unsigned i=0;i<3;++i) success_case(success[i],i,io,aux,req,resp);
  std::cout << "FULL_CURRENT_EXECUTOR_CHECKPOINT_HOST_PASS oracle_bytes=2048 wire_negatives="
            << wire_negatives << " import_negatives=" << import_negatives
            << " dynamic_task_bases=4,7,3 lpv_bases=23,97,119 target_epochs=8,18,32"
            << " imported_retirements=0 actual_retirements_per_action=4 persistent_numbers=1"
            << " actual_program_port_adapter=1 controlled_hub_snapshot_and_remote=1"
            << " rtl_handoff_pending=1\n";
}
