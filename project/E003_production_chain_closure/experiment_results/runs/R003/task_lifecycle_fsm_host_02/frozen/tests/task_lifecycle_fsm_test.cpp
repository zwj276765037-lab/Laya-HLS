#include "laya_task_lifecycle_fsm.h"
#include "laya_graph_program_sequencer.h"
#include "lifecycle_fixture_helpers.h"

#include <iostream>
#include <vector>

using namespace laya;
using namespace lifecycle_fixture;

enum class Case { SUCCESS, OWNER_WAIT, CANCEL_WAIT, BAD_END, WRONG_END, BAD_BEGIN };

void run_case(full::FullRuntime& rt, Case test_case) {
  rt.inputs.identity = identity();
  rt.request_valid = true;
  rt.model_header_valid = true;
  full::FullMemory ports = memory();
  const full::FullOwnerSpec source{
      {Buffer::HIDDEN, 0, 1}, 0, 2, 0, 255, RowSpace::TOKEN,
      0, 64, 1024, Content::F32};
  fill_owner(rt, source);
  program::State graph;
  assert(program::begin(graph, rt.inputs.identity));
  assert(program::seed_slot(graph, 0, source, source.ref.epoch));
  action::Request action_request;
  assert(program::prepare_norm(graph, 0, 1, Op::LN_ATTN, 2, 1,
                               Buffer::NORM, 0, 0, 0, action_request));
  lifecycle::Machine machine;
  assert(lifecycle::start(machine, rt, action_request));
  Streams streams;
  bool cancel = false;
  std::vector<provenance::Request> provenance_requests;
  unsigned producers = 0, ends = 0, invalidates = 0;
  for (unsigned cycle = 0; cycle < 100000 &&
       machine.phase != lifecycle::Phase::COMPLETE &&
       machine.phase != lifecycle::Phase::ISOLATED; ++cycle) {
    lifecycle::step(machine, rt, ports, cancel,
                     streams.transaction_request,
                     streams.transaction_completion);
    laya_command_provenance_adapter(
        cancel, streams.transaction_request, streams.transaction_completion,
        streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request request;
      assert(provenance::decode(
          dequeue<provenance::kRequestBytes>(streams.provenance_command), request));
      provenance_requests.push_back(request);
      auto response = provenance_response(request);
      if (test_case == Case::OWNER_WAIT &&
          request.action == provenance::Action::PUBLISH) {
        response.status = Status::E_BUFFER;
        response.error_detail = laya::detail(4, uint8_t(Buffer::NORM), 9);
        response.owner_published = false;
      }
      if (request.action == provenance::Action::INVALIDATE) {
        ++invalidates;
        if (test_case == Case::OWNER_WAIT && invalidates == 1) {
          response.status = Status::E_PROTOCOL;
          response.error_detail = laya::detail(7, 0, 14);
          response.drained = false;
        }
      }
      if (request.action == provenance::Action::BEGIN) {
        if (test_case == Case::CANCEL_WAIT || test_case == Case::BAD_END ||
            test_case == Case::WRONG_END) cancel = true;
        if (test_case == Case::BAD_BEGIN) {
          response.status = Status::E_PROTOCOL;
          response.error_detail = laya::detail(7, 0, 14);
          response.drained = false;
        }
      }
      if (request.action == provenance::Action::END) {
        ++ends;
        if (test_case == Case::CANCEL_WAIT || test_case == Case::BAD_END ||
            test_case == Case::WRONG_END) {
          assert(request.issued_store_bytes[0] == 0 && producers == 0);
          if (ends == 1) {
            response.status = Status::E_PROTOCOL;
            response.error_detail = laya::detail(7, 0, 14);
            response.drained = false;
            response.scope_active = true;
          }
          if (ends == 2) {
            assert(provenance_requests[provenance_requests.size()-2].event_seq ==
                   request.event_seq);
            assert(rt.generated_store.active && rt.tasks_retired == 0);
            full::FullOwnerRecord reader;
            assert(full::full_owner_snapshot(rt, source.ref, 0, reader));
            assert(reader.readers == 0);
          }
        }
      }
      auto packet = provenance::encode(response);
      if (test_case == Case::BAD_END && ends == 2 &&
          request.action == provenance::Action::END) packet[0] ^= 0x80;
      if (test_case == Case::WRONG_END && ends == 2 &&
          request.action == provenance::Action::END) {
        response.event_seq ^= 1;
        packet = provenance::encode(response);
      }
      enqueue(streams.provenance_response, packet);
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request request;
      assert(producer::decode(
          dequeue<producer::kRequestBytes>(streams.producer_request), request));
      ++producers;
      enqueue(streams.producer_completion,
              producer::encode(producer_success(request)));
    }
  }
  full::FullOwnerRecord reader;
  assert(full::full_owner_snapshot(rt, source.ref, 0, reader));
  const auto ordinal = machine.action_high_water;
  const auto task_high = rt.dispatch_reservations.task_high_water(rt.last_task_id);
  const auto event_high = rt.provenance_event_high_water;
  assert(!lifecycle::start(machine, rt, action_request));
  assert(machine.action_high_water == ordinal &&
         rt.dispatch_reservations.task_high_water(rt.last_task_id) == task_high &&
         rt.provenance_event_high_water == event_high);
  if (test_case == Case::BAD_END || test_case == Case::WRONG_END ||
      test_case == Case::BAD_BEGIN) {
    assert(machine.phase == lifecycle::Phase::ISOLATED &&
           rt.lifecycle_action.active && rt.generated_store.active &&
           rt.tasks_retired == 0 && !lifecycle::completion_consumed(machine, rt));
    if (test_case == Case::BAD_BEGIN) {
      assert(producers == 0 && ends == 0 && reader.readers == 1 &&
             rt.generated_store.source_lease_active);
    } else {
      assert(producers == 0 && ends == 2 && reader.readers == 0 &&
             !rt.generated_store.source_lease_active);
      const auto requests = provenance_requests.size();
      for (unsigned cycle = 0; cycle < 100; ++cycle)
        lifecycle::step(machine, rt, ports, true, streams.transaction_request,
                         streams.transaction_completion);
      assert(streams.transaction_request.empty() &&
             provenance_requests.size() == requests && rt.tasks_retired == 0);
    }
    assert(graph.action_active);
  } else {
    assert(machine.phase == lifecycle::Phase::COMPLETE && reader.readers == 0 &&
           !rt.lifecycle_action.active && !rt.generated_store.active);
    action::Completion completion;
    assert(action::decode(action::encode(machine.completion), completion));
    if (test_case == Case::SUCCESS) {
      assert(producers == 4 && ends == 4 && invalidates == 0 &&
             provenance_requests.size() == 10 && rt.tasks_retired == 4 &&
             completion.retired_tasks == 4 && completion.result);
      assert(program::accept_completion(graph, completion));
      assert(!graph.action_active && graph.pc == 1);
    } else {
      assert(!completion.result && !(completion.flags & action::SLOT_UPDATE_VALID));
      if (test_case == Case::OWNER_WAIT) {
        assert(producers == 4 && ends == 4 && invalidates == 2 &&
               rt.tasks_retired == 4 && completion.result.code == Status::E_BUFFER);
        const auto n = provenance_requests.size();
        assert(provenance_requests[n-1].event_seq == provenance_requests[n-2].event_seq);
      } else {
        assert(producers == 0 && ends == 2 && invalidates == 1 &&
               rt.tasks_retired == 1 && completion.retired_tasks == 1);
      }
      assert(!program::accept_completion(graph, completion) && !graph.action_active);
      action::Request untouched = action_request;
      assert(!program::prepare_norm(graph, 0, 1, Op::LN_ATTN, 2, 1,
                                    Buffer::NORM, 0, 0, 0, untouched));
    }
    // Completion production leaves this machine unavailable until explicitly
    // notified about consumption; a new action cannot reset its pending key.
    assert(lifecycle::completion_consumed(machine, rt));
    assert(machine.phase == lifecycle::Phase::IDLE);
  }
  assert(streams.transaction_request.empty() && streams.transaction_completion.empty() &&
         streams.compute_command.empty() && streams.compute_response.empty() &&
         streams.provenance_command.empty() && streams.provenance_response.empty() &&
         streams.producer_request.empty() && streams.producer_completion.empty());
}

int main() {
  static full::FullRuntime runtimes[6];
  const Case cases[] = {Case::SUCCESS, Case::OWNER_WAIT, Case::CANCEL_WAIT,
                        Case::BAD_END, Case::WRONG_END, Case::BAD_BEGIN};
  for (unsigned i = 0; i < 6; ++i) run_case(runtimes[i], cases[i]);
  std::cout << "FULL_CURRENT_TASK_LIFECYCLE_FSM_PASS "
            << "cases=6 explicit_step=1 b1_s64_windows=4 "
            << "owner_cleanup_same_action=1 actual_completion_end=1 "
            << "producer_cancel_zero_external=1 end_wait_same_key=1 "
            << "bad_end_isolated=1 wrong_end_isolated=1 "
            << "begin_nondrained_reader_retained=1 unique_retirement=1 "
            << "completion_consumer_wait=1 no_synchronous_execute_tree=1\n";
}
