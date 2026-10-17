#include "laya_executor_bootstrap.h"
#include "laya_graph_program_hls.h"
#include "lifecycle_fixture_helpers.h"

#include <algorithm>
#include <fstream>
#include <iostream>
#include <vector>

using namespace laya;
using namespace lifecycle_fixture;

namespace {
std::vector<uint8_t> read(const std::string& path) {
  std::ifstream file(path, std::ios::binary);
  assert(file);
  return {std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>()};
}
template<std::size_t N>
std::array<uint8_t, N> fixed(const std::vector<uint8_t>& bytes) {
  assert(bytes.size() == N);
  std::array<uint8_t, N> result{};
  std::copy(bytes.begin(), bytes.end(), result.begin());
  return result;
}
void write64(std::vector<uint8_t>& bytes, unsigned off, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) bytes[off + i] = uint8_t(value >> (8 * i));
}
full::FullMemory ports(std::vector<uint8_t>& io, std::vector<uint8_t>& aux) {
  auto result = memory();
  result.io = io.data(); result.io_bytes = io.size(); result.aux = aux.data();
  return result;
}
const bootstrap::BaseBinding base{7, 0x1200000000ull, 16920576};
const bootstrap::AdmissionFence safe{true, true};

void admission_errors(const std::vector<uint8_t>& io_gold,
                       const std::vector<uint8_t>& aux_gold) {
  static full::FullRuntime runtimes[10];
  for (unsigned which = 0; which < 10; ++which) {
    auto io = io_gold, aux = aux_gold;
    switch (which) {
      case 0: io[0] ^= 1; break;
      case 1: io[4] = 2; break;
      case 2: io[20] = 3; break;
      case 3: io[40] ^= 1; break;
      case 4: io[132] ^= 1; break; // Directory offset.
      case 5: io[320] = 255; io[321] = io[322] = io[323] = 255; break;
      case 6: io[576] = 2; break; // Non-boolean attention mask.
      case 7: std::fill(io.begin() + 576, io.begin() + 640, 0); break;
      case 8: aux[0] ^= 1; break;
      case 9: aux[32] ^= 1; break;
    }
    auto memory_ports = ports(io, aux);
    bootstrap::State state;
    lifecycle::Port port;
    auto& rt = runtimes[which];
    assert(!bootstrap::admit_new(state, port, rt, memory_ports, safe));
    assert(!rt.request_valid && !rt.model_header_valid &&
           rt.last_accepted_request_id == 0 && rt.session_generation == 0 &&
           rt.last_task_id == 0 && rt.tasks_retired == 0);
  }
}

void schema(const bootstrap::Packet& request_gold,
             const bootstrap::Packet& response_gold) {
  bootstrap::Request request;
  assert(bootstrap::decode(request_gold, request));
  assert(bootstrap::encode(request) == request_gold);
  bootstrap::Response trusted;
  assert(bootstrap::decode(response_gold, request, trusted));
  assert(bootstrap::encode(trusted) == response_gold);
  const unsigned corruptions[] = {0, 4, 6, 8, 10, 12, 16, 28, 40,
                                  48, 56, 64, 72, 84, 160, 576, 580,
                                  592, 598, 604, 608, 624, 704};
  for (unsigned offset : corruptions) {
    auto packet = response_gold;
    packet[offset] ^= offset == 10 ? 255 : 1;
    bootstrap::Response rejected = trusted;
    assert(!bootstrap::decode(packet, request, rejected));
    assert(rejected.flags == 0 && rejected.binding.sequence == 0 &&
           rejected.binding.identity.request_id == 0 &&
           rejected.binding.source.target_ref.id == Buffer::NONE);
  }
  bootstrap::Response error = trusted;
  error.result = {Status::E_BUFFER, laya::detail(4, 1, 9)};
  error.flags = bootstrap::FRAME_COMPLETE | bootstrap::BINDING_OK;
  bootstrap::Response decoded;
  assert(!bootstrap::decode(bootstrap::encode(error), request, decoded));
  assert(decoded.flags == 3 && decoded.result.code == Status::E_BUFFER &&
         bootstrap::same_binding(decoded.binding, request));
}

void bootstrap_combination(const std::vector<uint8_t>& io_gold,
                            const std::vector<uint8_t>& aux_gold,
                            const bootstrap::Packet& request_gold,
                            const bootstrap::Packet& response_gold) {
  static full::FullRuntime rt;
  auto io = io_gold, aux = aux_gold;
  auto memory_ports = ports(io, aux);
  bootstrap::State state;
  lifecycle::Port port;
  // A missing real-shell acknowledgement rejects before full_begin_request.
  const bootstrap::AdmissionFence busy{false, true};
  assert(!bootstrap::admit_new(state, port, rt, memory_ports, busy));
  assert(!rt.request_valid && rt.session_generation == 0);
  assert(bootstrap::admit_new(state, port, rt, memory_ports, safe));
  assert(rt.request_valid && rt.model_header_valid &&
         rt.inputs.identity.request_id == 1101 && rt.inputs.identity.generation == 51 &&
         rt.inputs.token_ids[0][63] == 63 && rt.inputs.attention_mask[0][0] == 1 &&
         rt.inputs.marker_positions[0][15] == 15 && rt.inputs.qtype[0] == 1);

  // Controlled prior typed completions use the normal reservation/retirement
  // functions.  This is host bookkeeping evidence, not an encoder payload.
  for (unsigned row = 0; row < 64; row += 16) {
    const auto ctx = rt.dispatch_reservations.context(
        rt.last_task_id, Op::ADD_RESIDUAL, 2, 0, 0, RowSpace::TOKEN, uint16_t(row), 16);
    TaskDone done;
    done.task_id = ctx.task_id; done.drained = true;
    done.output_elements = 16384; done.output_unit = OutputUnit::F32;
    assert(full::full_retire_prepared_task(rt, ctx, done));
  }
  assert(rt.last_task_id == 4 && rt.tasks_retired == 4);
  bootstrap::Request snapshot;
  assert(bootstrap::prepare_snapshot(state, port, rt, memory_ports,
                                    {Buffer::HIDDEN, 0, 1}, base, snapshot));
  assert(bootstrap::encode(snapshot) == request_gold &&
         state.sequence_high_water == 1 && rt.last_task_id == 4 && rt.tasks_retired == 4);
  bootstrap::Response proof;
  assert(bootstrap::decode(response_gold, snapshot, proof));
  program_wire::Command command;
  command.identity.request_id = 9999;
  const auto original = program_wire::encode(command);
  auto changed = base; ++changed.epoch;
  assert(!bootstrap::accept_snapshot(state, port, rt, proof, changed, true, false, command));
  assert(!bootstrap::accept_snapshot(state, port, rt, proof, base, false, false, command));
  assert(!bootstrap::accept_snapshot(state, port, rt, proof, base, true, true, command));
  auto old = proof; --old.binding.sequence;
  assert(!bootstrap::accept_snapshot(state, port, rt, old, base, true, false, command));
  assert(program_wire::encode(command) == original &&
         state.phase == bootstrap::Phase::WAIT_SNAPSHOT && rt.owner_claims == 0);
  assert(bootstrap::accept_snapshot(state, port, rt, proof, base, true, false, command));
  assert(rt.owner_claims == 0 && rt.tasks_retired == 4 && rt.last_task_id == 4 &&
         rt.provenance_event_high_water == 0 && rt.producer_request_high_water == 0 &&
         command.identity.request_id == 1101 && command.source.owner.rows == 64);

  Streams streams;
  hls::stream<ap_uint<512>> commands, results, actions, completions;
  enqueue(commands, program_wire::encode(command));
  unsigned events = 0, producers = 0, completion_reads = 0;
  bool consumed = false, active_admission_blocked = false;
  for (unsigned cycle = 0; cycle < 100000 && results.size() != 4; ++cycle) {
    lifecycle::port_step(port, rt, memory_ports, false, consumed, actions, completions,
                         streams.transaction_request, streams.transaction_completion);
    if (!active_admission_blocked && rt.lifecycle_action.active && rt.generated_store.active) {
      const auto task_high = rt.dispatch_reservations.task_high_water(rt.last_task_id);
      const auto event_high = rt.provenance_event_high_water;
      assert(!bootstrap::admit_new(state, port, rt, memory_ports, safe));
      assert(rt.request_valid && rt.lifecycle_action.active && rt.generated_store.active &&
             rt.provenance_event_high_water == event_high &&
             rt.dispatch_reservations.task_high_water(rt.last_task_id) == task_high);
      active_admission_blocked = true;
    }
    laya_command_provenance_adapter(false, streams.transaction_request,
        streams.transaction_completion, streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request event;
      assert(provenance::decode(dequeue<provenance::kRequestBytes>(
          streams.provenance_command), event));
      ++events;
      if (event.action == provenance::Action::BEGIN) assert(event.context.task_id >= 5);
      enqueue(streams.provenance_response, provenance::encode(provenance_response(event)));
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request producer_request;
      assert(producer::decode(dequeue<producer::kRequestBytes>(
          streams.producer_request), producer_request));
      ++producers;
      enqueue(streams.producer_completion, producer::encode(producer_success(producer_request)));
    }
    const auto before = completions.size();
    laya_graph_program_sequencer(false, false, commands, results, actions, completions);
    if (completions.size() < before && ++completion_reads == 4) consumed = true;
  }
  assert(active_admission_blocked && results.size() == 4 && events == 10 && producers == 4 &&
         rt.last_task_id == 8 && rt.tasks_retired == 8 &&
         port.machine.completion.first_task_id == 5 &&
         port.machine.completion.last_task_id == 8 && port.machine.completion.retired_tasks == 4);
  program_wire::Result result;
  assert(program_wire::decode(dequeue<program_wire::kResultBytes>(results), result));
  assert(result.result && result.pc == 1);
  lifecycle::port_step(port, rt, memory_ports, false, consumed, actions, completions,
                       streams.transaction_request, streams.transaction_completion);
  laya_graph_program_sequencer(false, true, commands, results, actions, completions);
  assert(port.phase == lifecycle::PortPhase::READ_ACTION && commands.empty() &&
         results.empty() && actions.empty() && completions.empty() &&
         streams.transaction_request.empty() && streams.transaction_completion.empty() &&
         streams.provenance_command.empty() && streams.provenance_response.empty() &&
         streams.producer_request.empty() && streams.producer_completion.empty());

  const auto event_high = rt.provenance_event_high_water;
  // Restore no new state by parsing the same accepted request. It is rejected
  // by the original identity monotonicity check, without advancing acceptance.
  assert(!bootstrap::admit_new(state, port, rt, memory_ports, safe));
  assert(!rt.request_valid && !rt.model_header_valid &&
         rt.last_accepted_request_id == 1101 && rt.session_generation == 51);
  write64(io, 24, 1102);
  assert(bootstrap::admit_new(state, port, rt, memory_ports, safe));
  assert(rt.request_valid && rt.last_accepted_request_id == 1102 &&
         state.sequence_high_water == 1 && port.machine.action_high_water == 1 &&
         rt.provenance_event_high_water == event_high && rt.producer_request_high_water == 4);
  assert(bootstrap::prepare_snapshot(state, port, rt, memory_ports,
                                    {Buffer::HIDDEN, 0, 2}, base, snapshot));
  assert(snapshot.sequence == 2 && snapshot.identity.request_id == 1102);
}
} // namespace

int main(int argc, char** argv) {
  assert(argc == 2);
  const std::string root = argv[1];
  const auto io = read(root + "/request.bin"), aux = read(root + "/aux_header.bin");
  const auto request = fixed<bootstrap::kBytes>(read(root + "/snapshot_request.bin"));
  const auto response = fixed<bootstrap::kBytes>(read(root + "/snapshot_response.bin"));
  admission_errors(io, aux);
  schema(request, response);
  bootstrap_combination(io, aux, request, response);
  std::cout << "FULL_CURRENT_EXECUTOR_BOOTSTRAP_HOST_PASS real_lyrq_lymp=1 "
            << "admission_negatives=10 response_reset_negatives=23 "
            << "independent_snapshot_bytes=1536 old_action_not_cleared=1 "
            << "cancel_guard_base_stale_proof_rejected=4 checkpoint_tasks=4 "
            << "actual_program_port_adapter=1 norm_retirement_range=5..8 "
            << "new_request_highwater_preserved=1 controlled_snapshot_and_remote=1 "
            << "physical_snapshot_and_guard_pending=1\n";
}
