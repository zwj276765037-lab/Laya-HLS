#include "laya_controller_transaction_adapter.h"
#include "laya_graph_program_sequencer.h"
#include "laya_model_layout_generated.h"
#include "laya_task_lifecycle_executor.h"

#include <atomic>
#include <cassert>
#include <functional>
#include <iostream>
#include <thread>
#include <vector>

using namespace laya;

namespace {

struct Streams {
  hls::stream<ap_uint<512>> transaction_request{"transaction_request"};
  hls::stream<ap_uint<512>> transaction_completion{"transaction_completion"};
  hls::stream<ap_uint<512>> compute_command{"compute_command"};
  hls::stream<ap_uint<512>> compute_response{"compute_response"};
  hls::stream<ap_uint<512>> provenance_command{"provenance_command"};
  hls::stream<ap_uint<512>> provenance_response{"provenance_response"};
  hls::stream<ap_uint<512>> producer_request{"producer_request"};
  hls::stream<ap_uint<512>> producer_completion{"producer_completion"};
};

NumericIdentity identity(uint64_t request_id) {
  NumericIdentity id;
  id.request_id = request_id;
  id.generation = request_id + 100;
  id.B = 1;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = full::kFullModelTag[i];
    id.numeric_tag[i] = full::kFullNumericTag[i];
    id.layout_tag[i] = full::kFullLayoutTag[i];
    id.build_tag[i] = full::kFullBuildTag[i];
  }
  return id;
}

full::FullMemory memory() {
  static uint8_t byte = 0;
  full::FullMemory m;
  m.embedding = &byte; m.embedding_bytes = full::kFullModelBoSizes[0];
  m.io = &byte; m.io_bytes = 32768;
  m.w_q0 = &byte; m.w_q0_bytes = full::kFullModelBoSizes[1];
  m.w_q1 = &byte; m.w_q1_bytes = full::kFullModelBoSizes[2];
  m.w_scale = &byte; m.w_scale_bytes = full::kFullModelBoSizes[3];
  m.aux = &byte; m.aux_bytes = full::kFullModelBoSizes[4];
  m.state0 = &byte; m.state0_bytes = 16920576;
  m.state1 = &byte; m.state1_bytes = 16919104;
  m.qkv0 = &byte; m.qkv0_bytes = 12u * 1024u * 1024u;
  m.qkv1 = &byte; m.qkv1_bytes = 12u * 1024u * 1024u;
  m.ff0 = &byte; m.ff0_bytes = 41u * 1024u * 1024u;
  m.ff1 = &byte; m.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  m.att_out = &byte; m.att_out_bytes = 8u * 1024u * 1024u;
  return m;
}

full::FullOwnerSpec source_spec(uint32_t epoch = 1) {
  return {{Buffer::HIDDEN, 0, epoch}, 0, 2, 0, 255, RowSpace::TOKEN,
          0, 64, 1024, Content::F32};
}

void fill_owner(full::FullRuntime& rt, const full::FullOwnerSpec& owner) {
  assert(full::full_claim_owner(rt, owner));
  for (unsigned row = 0; row < owner.rows; row += 16)
    assert(full::full_cover_owner(rt, owner, 0, uint16_t(row), 16));
  assert(full::full_publish_owner(rt, owner));
}

void initialize(full::FullRuntime& rt, uint64_t request_id,
                const full::FullOwnerSpec& source) {
  rt.inputs.identity = identity(request_id);
  rt.request_valid = true;
  rt.model_header_valid = true;
  fill_owner(rt, source);
}

action::Request prepare(program::State& state, full::FullRuntime& rt,
                        const full::FullOwnerSpec& source) {
  assert(program::begin(state, rt.inputs.identity));
  assert(program::seed_slot(state, 0, source, source.ref.epoch));
  action::Request request;
  assert(program::prepare_norm(state, 0, 1, Op::LN_ATTN, 2, 1,
                               Buffer::NORM, 0, 0, 0, request));
  return request;
}

template<std::size_t Bytes>
ap_uint<512> pack(const std::array<uint8_t, Bytes>& packet, unsigned beat) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  return word;
}

template<std::size_t Bytes>
std::array<uint8_t, Bytes> dequeue(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

template<std::size_t Bytes>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat)
    stream.write(pack(packet, beat));
}

provenance::Response base_provenance_response(
    const provenance::Request& request) {
  provenance::Response response;
  response.action = request.action;
  response.event_seq = request.event_seq;
  response.origin_seq = request.origin_seq;
  response.identity = request.identity;
  response.context = request.context;
  response.descriptor_count = request.descriptor_count;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    response.target_ref[i] = request.descriptor[i].target_ref;
    response.target_region[i] = request.descriptor[i].target_region;
    response.old_ref[i] = request.descriptor[i].old_ref;
    response.old_region[i] = request.descriptor[i].old_region;
  }
  response.status = request.action == provenance::Action::END ?
                    request.reported_status : Status::OK;
  response.error_detail = request.action == provenance::Action::END ?
                          request.reported_error_detail : 0;
  response.bad_element = request.action == provenance::Action::END ?
                         request.reported_bad_element : UINT64_MAX;
  response.drained = true;
  response.scope_active = request.action == provenance::Action::BEGIN;
  response.owner_published = request.action == provenance::Action::PUBLISH;
  if (request.action == provenance::Action::END &&
      request.reported_status == Status::OK) {
    response.unit = request.expected_unit;
    response.output_elements = request.expected_elements;
    for (unsigned i = 0; i < request.descriptor_count; ++i)
      response.observed_store_bytes[i] = request.issued_store_bytes[i];
  }
  return response;
}

producer::Completion producer_success(const producer::Request& request) {
  producer::Completion response;
  response.family = request.family;
  response.request_seq = request.request_seq;
  response.provenance_origin_seq = request.provenance_origin_seq;
  response.status = Status::OK;
  response.unit = OutputUnit::F32;
  response.finished = true;
  response.bad_element = UINT64_MAX;
  response.output_elements = request.expected_elements;
  response.issued_store_bytes = uint64_t(request.expected_elements) * 4u;
  response.consumed_source_bytes = response.issued_store_bytes;
  response.identity = request.identity;
  response.context = request.context;
  response.source = request.source;
  response.destination = request.destination;
  response.source_region = request.source_region;
  response.destination_region = request.destination_region;
  response.source_role = request.source_role;
  response.destination_role = request.destination_role;
  response.D = request.D;
  response.gamma = request.gamma;
  response.eps_bits = request.eps_bits;
  response.row_bytes = request.row_bytes;
  response.source_first_offset = request.source_first_offset;
  response.destination_first_offset = request.destination_first_offset;
  response.source_row_step = request.source_row_step;
  response.destination_row_step = request.destination_row_step;
  return response;
}

using ProvenancePolicy = std::function<provenance::Response(
    const provenance::Request&, unsigned)>;

struct Execution {
  Check result = ok();
  action::Completion completion;
  std::vector<provenance::Request> provenance_requests;
  unsigned producer_requests = 0;
};

Execution execute_with_policy(full::FullRuntime& rt, full::FullMemory& ports,
                              const action::Request& request,
                              const ProvenancePolicy& policy) {
  Streams streams;
  Execution execution;
  std::atomic<bool> completed{false};
  std::thread executor([&] {
    execution.result = lifecycle::execute(
        rt, ports, request, execution.completion,
        streams.transaction_request, streams.transaction_completion);
    completed.store(true, std::memory_order_release);
  });

  bool cancel = false;
  for (unsigned cycle = 0; cycle < 4000000 &&
       !completed.load(std::memory_order_acquire); ++cycle) {
    laya_command_provenance_adapter(
        cancel, streams.transaction_request, streams.transaction_completion,
        streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request item;
      assert(provenance::decode(
          dequeue<provenance::kRequestBytes>(streams.provenance_command),
          item));
      const unsigned index = execution.provenance_requests.size();
      execution.provenance_requests.push_back(item);
      enqueue(streams.provenance_response,
              provenance::encode(policy(item, index)));
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request item;
      assert(producer::decode(
          dequeue<producer::kRequestBytes>(streams.producer_request), item));
      ++execution.producer_requests;
      enqueue(streams.producer_completion,
              producer::encode(producer_success(item)));
    }
    std::this_thread::yield();
  }
  assert(completed.load(std::memory_order_acquire));
  executor.join();
  return execution;
}

action::Completion successful_completion(const action::Request& request) {
  action::Completion completion;
  completion.kind = request.kind;
  completion.pc = request.pc;
  completion.op = request.op;
  completion.stage = request.stage;
  completion.layer = request.layer;
  completion.flags = action::FRAME_COMPLETE | action::BINDING_OK |
      action::SAFE_TERMINAL | action::REMOTE_DRAINED |
      action::SLOT_UPDATE_VALID | action::TYPED_RETIRED;
  completion.ordinal = request.ordinal;
  completion.identity = request.identity;
  completion.first_task_id = 1;
  completion.last_task_id = 4;
  completion.retired_tasks = 4;
  completion.slot_delta.slot = request.target_slot;
  completion.slot_delta.version = request.target_slot_version;
  completion.slot_delta.owner = {
      {request.target_buffer, request.target_bank, 1}, request.target_region,
      request.stage, request.layer, 255, request.source.owner.row_space,
      0, request.identity.S, 1024, Content::F32};
  return completion;
}

void test_completion_validation_and_program_geometry() {
  static full::FullRuntime rt;
  const full::FullOwnerSpec source = source_spec(1);
  initialize(rt, 801, source);
  program::State state;
  const action::Request request = prepare(state, rt, source);
  const action::Completion good = successful_completion(request);
  assert(action::validate(good));

  action::Completion preset = good;
  action::Completion bad = good;
  bad.flags |= action::LOCAL_REJECT;
  assert(!action::decode(action::encode(bad), preset));
  assert(preset.flags == 0 && preset.ordinal == 0);

  bad = good;
  bad.result.code = Status(uint16_t(Status::E_INTERNAL) + 1u);
  preset = good;
  assert(!action::decode(action::encode(bad), preset));
  assert(preset.flags == 0 && preset.ordinal == 0);

  bad = good;
  bad.slot_delta.slot = uint8_t(program::kGraphSlots);
  preset = good;
  assert(!action::decode(action::encode(bad), preset));
  assert(preset.flags == 0 && preset.ordinal == 0);

  bad = good;
  bad.slot_delta.owner.batch = 0;
  assert(!program::accept_completion(state, bad) && state.action_active);
  bad = good;
  bad.slot_delta.owner.row0 = 16;
  assert(!program::accept_completion(state, bad) && state.action_active);
  bad = good;
  bad.retired_tasks = 1;
  bad.last_task_id = bad.first_task_id;
  assert(!program::accept_completion(state, bad) && state.action_active);
  assert(program::accept_completion(state, good));
}

void test_publish_cleanup_and_request_failure_lock() {
  static full::FullRuntime rt;
  const full::FullOwnerSpec source = source_spec(1);
  initialize(rt, 802, source);
  full::FullMemory ports = memory();
  program::State state;
  const action::Request request = prepare(state, rt, source);
  const Check publish_failure{
      Status::E_BUFFER, laya::detail(4, uint8_t(Buffer::NORM), 9)};
  unsigned invalidate_count = 0;
  ProvenancePolicy first_policy = [&](const provenance::Request& item,
                                      unsigned) {
    provenance::Response response = base_provenance_response(item);
    if (item.action == provenance::Action::PUBLISH) {
      response.status = publish_failure.code;
      response.error_detail = publish_failure.detail;
      response.bad_element = publish_failure.bad_element;
      response.owner_published = false;
    } else if (item.action == provenance::Action::INVALIDATE) {
      ++invalidate_count;
      response.status = Status::E_PROTOCOL;
      response.error_detail = laya::detail(7, 0, 14);
      response.drained = false;
    }
    return response;
  };
  const Execution first = execute_with_policy(rt, ports, request, first_policy);
  assert(!first.result && first.result.code == publish_failure.code &&
         invalidate_count == 1 && rt.lifecycle_action.active &&
         rt.lifecycle_action.cleanup_pending &&
         !rt.lifecycle_action.cleanup_remote_terminal &&
         !(first.completion.flags & action::SAFE_TERMINAL) &&
         rt.tasks_retired == 4 && !rt.generated_store.active);
  assert(!program::accept_completion(state, first.completion) &&
         state.action_active);

  ProvenancePolicy terminal_cleanup = [&](const provenance::Request& item,
                                          unsigned) {
    assert(item.action == provenance::Action::INVALIDATE);
    return base_provenance_response(item);
  };
  const Execution second = execute_with_policy(
      rt, ports, request, terminal_cleanup);
  assert(!second.result && second.result.code == publish_failure.code &&
         second.provenance_requests.size() == 1 &&
         second.provenance_requests[0].action ==
             provenance::Action::INVALIDATE &&
         !rt.lifecycle_action.active &&
         rt.lifecycle_action.cleanup_remote_terminal &&
         rt.lifecycle_action.cleanup_local_complete &&
         (second.completion.flags & action::SAFE_TERMINAL) &&
         (second.completion.flags & action::REMOTE_DRAINED) &&
         rt.tasks_retired == 4);
  assert(!program::accept_completion(state, second.completion));
  assert(!state.action_active && !state.first_error && state.pc == 0);

  const uint64_t high_water = state.action_high_water;
  action::Request blocked;
  blocked.ordinal = UINT64_MAX;
  assert(!program::prepare_norm(state, 0, 1, Op::LN_ATTN, 2, 1,
                                Buffer::NORM, 0, 0, 0, blocked));
  assert(state.action_high_water == high_water &&
         blocked.ordinal == UINT64_MAX);

  NumericIdentity next = identity(803);
  assert(program::begin(state, next));
  assert(state.action_high_water == high_water && state.first_error);
  assert(program::seed_slot(state, 0, source, source.ref.epoch));
  action::Request recovered;
  assert(program::prepare_norm(state, 0, 1, Op::LN_ATTN, 2, 1,
                               Buffer::NORM, 0, 0, 0, recovered));
  assert(recovered.ordinal == high_water + 1);
}

void test_begin_nonterminal_and_release_failure_retention() {
  static full::FullRuntime nonterminal_rt;
  const full::FullOwnerSpec source_a = source_spec(1);
  initialize(nonterminal_rt, 804, source_a);
  full::FullMemory ports = memory();
  program::State state_a;
  const action::Request request_a = prepare(state_a, nonterminal_rt, source_a);
  ProvenancePolicy nonterminal_begin = [](const provenance::Request& item,
                                          unsigned) {
    provenance::Response response = base_provenance_response(item);
    if (item.action == provenance::Action::BEGIN) {
      response.status = Status::E_PROTOCOL;
      response.error_detail = laya::detail(7, uint8_t(Op::LN_ATTN), 14);
      response.drained = false;
      response.scope_active = false;
    }
    return response;
  };
  const Execution a = execute_with_policy(
      nonterminal_rt, ports, request_a, nonterminal_begin);
  assert(!a.result && nonterminal_rt.lifecycle_action.active &&
         nonterminal_rt.lifecycle_action.begin_response_bound &&
         nonterminal_rt.lifecycle_action.source_release_pending &&
         nonterminal_rt.generated_store.active &&
         nonterminal_rt.generated_store.source_lease_active &&
         !(a.completion.flags & action::SAFE_TERMINAL));
  full::FullOwnerRecord source_record;
  assert(full::full_owner_snapshot(nonterminal_rt, source_a.ref,
                                   source_a.region, source_record));
  assert(source_record.readers == 1 && source_record.state == CacheState::READ);

  static full::FullRuntime release_rt;
  const full::FullOwnerSpec source_b = source_spec(1);
  initialize(release_rt, 805, source_b);
  program::State state_b;
  const action::Request request_b = prepare(state_b, release_rt, source_b);
  ProvenancePolicy release_failure = [&](const provenance::Request& item,
                                         unsigned) {
    provenance::Response response = base_provenance_response(item);
    if (item.action == provenance::Action::BEGIN) {
      response.status = Status::E_PROTOCOL;
      response.error_detail = laya::detail(7, uint8_t(Op::LN_ATTN), 9);
      response.drained = true;
      response.scope_active = false;
      for (auto& record : release_rt.owners.record)
        if (record.ref == source_b.ref && record.region == source_b.region) {
          record.readers = 0;
          record.state = CacheState::READY;
        }
    }
    return response;
  };
  const Execution b = execute_with_policy(
      release_rt, ports, request_b, release_failure);
  assert(!b.result && release_rt.lifecycle_action.active &&
         release_rt.lifecycle_action.source_release_pending &&
         release_rt.generated_store.active &&
         release_rt.generated_store.source_lease_active &&
         !(b.completion.flags & action::SAFE_TERMINAL));
}

void test_all_unsupported_kinds_have_no_side_effect() {
  static full::FullRuntime rt;
  const full::FullOwnerSpec source = source_spec(1);
  initialize(rt, 806, source);
  full::FullMemory ports = memory();
  program::State state;
  const action::Request base = prepare(state, rt, source);
  Streams unused;
  const uint64_t event_high_water = rt.provenance_event_high_water;
  const uint64_t producer_high_water = rt.producer_request_high_water;
  unsigned checked = 0;
  for (unsigned raw = 0; raw <= uint8_t(action::Kind::ACT_CONCAT); ++raw) {
    if (raw == uint8_t(action::Kind::NORM)) continue;
    action::Request request = base;
    request.kind = action::Kind(raw);
    request.ordinal = raw + 100;
    action::Completion completion;
    const Check result = lifecycle::execute(
        rt, ports, request, completion, unused.transaction_request,
        unused.transaction_completion);
    assert(!result && (completion.flags & action::LOCAL_REJECT) &&
           (completion.flags & action::SAFE_TERMINAL));
    ++checked;
  }
  assert(checked == 16 &&
         rt.provenance_event_high_water == event_high_water &&
         rt.producer_request_high_water == producer_high_water &&
         rt.tasks_retired == 0 && !rt.lifecycle_action.active);
}

} // namespace

int main() {
  test_completion_validation_and_program_geometry();
  test_publish_cleanup_and_request_failure_lock();
  test_begin_nonterminal_and_release_failure_retention();
  test_all_unsupported_kinds_have_no_side_effect();
  std::cout << "FULL_CURRENT_GRAPH_LIFECYCLE_F11_F13_PASS "
            << "lac1_status_local_reject_reset=1 "
            << "norm_batch_row0_retirement_exact=1 "
            << "publish_failure_cleanup_nonterminal_then_terminal=1 "
            << "first_error_preserved=1 no_duplicate_retirement=1 "
            << "begin_nonterminal_retained=1 source_release_failure_retained=1 "
            << "failed_request_dispatch_lock=1 new_request_high_water=1 "
            << "unsupported_dynamic=16\n";
  return 0;
}
