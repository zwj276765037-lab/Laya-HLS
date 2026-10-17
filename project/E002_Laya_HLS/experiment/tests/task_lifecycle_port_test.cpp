#include "laya_task_lifecycle_port.h"
#include "laya_graph_program_hls.h"
#include "laya_graph_program_sequencer.h"
#include "lifecycle_fixture_helpers.h"

#include <iostream>

using namespace laya;
using namespace lifecycle_fixture;

namespace {
const full::FullOwnerSpec source{
    {Buffer::HIDDEN, 0, 1}, 0, 2, 0, 255, RowSpace::TOKEN,
    0, 64, 1024, Content::F32};

void seed(full::FullRuntime& rt) {
  rt.inputs.identity = identity();
  rt.request_valid = rt.model_header_valid = true;
  fill_owner(rt, source);
}

action::Request request(full::FullRuntime& rt) {
  program::State graph;
  assert(program::begin(graph, rt.inputs.identity));
  assert(program::seed_slot(graph, 0, source, source.ref.epoch));
  action::Request result;
  assert(program::prepare_norm(graph, 0, 1, Op::LN_ATTN, 2, 1,
                               Buffer::NORM, 0, 0, 0, result));
  return result;
}

struct Remote {
  unsigned producers = 0, events = 0;
  void step(Streams& streams) {
    laya_command_provenance_adapter(
        false, streams.transaction_request, streams.transaction_completion,
        streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request event;
      assert(provenance::decode(
          dequeue<provenance::kRequestBytes>(streams.provenance_command), event));
      ++events;
      enqueue(streams.provenance_response,
              provenance::encode(provenance_response(event)));
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request producer_request;
      assert(producer::decode(
          dequeue<producer::kRequestBytes>(streams.producer_request),
          producer_request));
      ++producers;
      enqueue(streams.producer_completion,
              producer::encode(producer_success(producer_request)));
    }
  }
};

void port_call(lifecycle::Port& port, full::FullRuntime& rt, Streams& streams,
               hls::stream<ap_uint<512>>& requests,
               hls::stream<ap_uint<512>>& completions, bool consumed = false) {
  lifecycle::port_step(port, rt, memory(), false, consumed, requests, completions,
                       streams.transaction_request, streams.transaction_completion);
}

void drain_check(Streams& s) {
  assert(s.transaction_request.empty() && s.transaction_completion.empty() &&
         s.compute_command.empty() && s.compute_response.empty() &&
         s.provenance_command.empty() && s.provenance_response.empty() &&
         s.producer_request.empty() && s.producer_completion.empty());
}

void transport_case(full::FullRuntime& rt) {
  seed(rt);
  lifecycle::Port port;
  Streams streams;
  Remote remote;
  hls::stream<ap_uint<512>> requests, completions;
  auto first = request(rt);
  enqueue(requests, action::encode(first));
  for (unsigned cycle = 0; cycle < 100000 &&
       port.phase != lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED; ++cycle) {
    // A notification received before completion production must not release
    // the active action.  This is the software signal contract, not RTL depth2.
    port_call(port, rt, streams, requests, completions,
              port.phase == lifecycle::PortPhase::EXECUTE);
    remote.step(streams);
  }
  assert(port.phase == lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED &&
         completions.size() == action::kCompletionBeats &&
         remote.producers == 4 && remote.events == 10 && rt.tasks_retired == 4);
  action::Completion decoded;
  assert(action::decode(port.completion_packet, decoded) && decoded.result);
  auto unsupported = first;
  unsupported.kind = action::Kind::LINEAR;
  unsupported.ordinal = 2;
  const auto packet = action::encode(unsupported);
  // A successor descriptor is already queued, including its first two beats.
  requests.write(pack(packet, 0)); requests.write(pack(packet, 1));
  assert(completions.read() == pack(port.completion_packet, 0));
  assert(completions.read() == pack(port.completion_packet, 1));
  for (unsigned cycle = 0; cycle < 12; ++cycle)
    port_call(port, rt, streams, requests, completions);
  assert(requests.size() == 2 && completions.size() == 2 &&
         port.machine.action_high_water == 1 && rt.tasks_retired == 4);
  assert(completions.read() == pack(port.completion_packet, 2));
  for (unsigned cycle = 0; cycle < 12; ++cycle)
    port_call(port, rt, streams, requests, completions);
  assert(requests.size() == 2 && completions.size() == 1 &&
         port.machine.action_high_water == 1 && remote.events == 10);
  assert(completions.read() == pack(port.completion_packet, 3));
  port_call(port, rt, streams, requests, completions, true);
  assert(port.phase == lifecycle::PortPhase::READ_ACTION && requests.size() == 2);
  for (unsigned beat = 2; beat < action::kRequestBeats; ++beat)
    requests.write(pack(packet, beat));
  for (unsigned cycle = 0; cycle < 100 &&
       port.phase != lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED; ++cycle)
    port_call(port, rt, streams, requests, completions);
  assert(action::decode(dequeue<action::kCompletionBytes>(completions), decoded));
  assert(!decoded.result && (decoded.flags & action::LOCAL_REJECT) &&
         !(decoded.flags & action::SLOT_UPDATE_VALID) && decoded.ordinal == 2 &&
         port.machine.action_high_water == 2 && rt.tasks_retired == 4 &&
         remote.events == 10 && streams.transaction_request.empty());
  port_call(port, rt, streams, requests, completions, true);
  assert(port.phase == lifecycle::PortPhase::READ_ACTION);
  // A repeated ordinal and a changed source handle each fail before a new
  // owner event.  Both are syntactically valid, fully keyed local rejections.
  for (unsigned which = 0; which < 2; ++which) {
    auto rejected = first;
    rejected.ordinal = which == 0 ? 2 : 3;
    if (which == 1) rejected.source.version = 2;
    enqueue(requests, action::encode(rejected));
    for (unsigned cycle = 0; cycle < 100 &&
         port.phase != lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED; ++cycle)
      port_call(port, rt, streams, requests, completions);
    assert(action::decode(dequeue<action::kCompletionBytes>(completions), decoded));
    assert(!decoded.result && (decoded.flags & action::LOCAL_REJECT) &&
           port.machine.action_high_water == 2 && rt.tasks_retired == 4 &&
           streams.transaction_request.empty());
    port_call(port, rt, streams, requests, completions, true);
  }
  drain_check(streams);
  assert(requests.empty() && completions.empty());
}

void malformed_case(full::FullRuntime& rt, unsigned which) {
  seed(rt);
  lifecycle::Port port;
  Streams streams;
  hls::stream<ap_uint<512>> requests, completions;
  auto packet = action::encode(request(rt));
  if (which == 0) packet[0] ^= 1;
  else packet[8] = 255; // Semantic kind rejection after a legal header.
  enqueue(requests, packet);
  for (unsigned cycle = 0; cycle < 32; ++cycle)
    port_call(port, rt, streams, requests, completions, true);
  assert(port.phase == lifecycle::PortPhase::ISOLATED && !port.transport_error &&
         port.machine.action_high_water == 0 && !rt.lifecycle_action.active &&
         !rt.generated_store.active && rt.tasks_retired == 0 &&
         rt.provenance_event_high_water == 0 && requests.empty() && completions.empty());
  drain_check(streams);
}

void program_combination(full::FullRuntime& rt) {
  seed(rt);
  lifecycle::Port port;
  Streams streams;
  Remote remote;
  hls::stream<ap_uint<512>> commands, results, requests, completions;
  program_wire::Command command;
  command.identity = rt.inputs.identity;
  command.flags = program_wire::SOURCE_READY_PROOF;
  command.source = {0, source.ref.epoch, source};
  enqueue(commands, program_wire::encode(command));
  unsigned completion_reads = 0;
  bool consumed = false;
  for (unsigned cycle = 0; cycle < 100000 &&
       results.size() != program_wire::kResultBeats; ++cycle) {
    port_call(port, rt, streams, requests, completions, consumed);
    remote.step(streams);
    const auto before = completions.size();
    laya_graph_program_sequencer(false, false, commands, results, requests, completions);
    if (completions.size() < before && ++completion_reads == action::kCompletionBeats)
      consumed = true;
  }
  assert(results.size() == program_wire::kResultBeats && completion_reads == 4);
  program_wire::Result result;
  assert(program_wire::decode(dequeue<program_wire::kResultBytes>(results), result));
  assert(result.result && result.pc == 1 && result.action_ordinal == 1 &&
         (result.flags & program_wire::SLOT_UPDATE_VALID) &&
         rt.tasks_retired == 4 && remote.producers == 4 && remote.events == 10);
  laya_graph_program_sequencer(false, true, commands, results, requests, completions);
  port_call(port, rt, streams, requests, completions, consumed);
  assert(port.phase == lifecycle::PortPhase::READ_ACTION &&
         commands.empty() && results.empty() && requests.empty() && completions.empty());
  drain_check(streams);
}
} // namespace

int main() {
  static full::FullRuntime runtimes[4];
  transport_case(runtimes[0]);
  malformed_case(runtimes[1], 0);
  malformed_case(runtimes[2], 1);
  program_combination(runtimes[3]);
  std::cout << "FULL_CURRENT_TASK_LIFECYCLE_PORT_PASS "
            << "program_executor_adapter_host=1 four_windows_retired=4 "
            << "queued_successor_tail2_tail1_wait=1 early_notification_ignored=1 "
            << "unsupported_dynamic=1 stale_ordinal=1 source_version=1 "
            << "malformed_header_semantic_isolated=2 software_stream_empty=1 "
            << "request_model_source_test_seeded=1 physical_bootstrap_pending=1\n";
}
