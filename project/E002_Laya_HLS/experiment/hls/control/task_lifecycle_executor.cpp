#include "laya_task_lifecycle_executor.h"

#include "laya_compute_portal_client.h"
#include "laya_generated_provenance_events.h"
#include "laya_producer_engine_client.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {
namespace {

Check protocol(Op op = Op::IO_VALIDATE, uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(op), reason)};
}

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

bool response_bound(Check result, const provenance::Response& response) {
  return result.code == response.status && result.detail == response.error_detail &&
         result.bad_element == response.bad_element;
}

bool same_owner(const full::FullOwnerSpec& a,
                const full::FullOwnerSpec& b) {
  return a.ref == b.ref && a.region == b.region && a.stage == b.stage &&
      a.layer == b.layer && a.batch == b.batch &&
      a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows &&
      a.width == b.width && a.content == b.content;
}

bool action_bound(const full::FullRuntime::LifecycleActionTracker& active,
                  const action::Request& request) {
  return active.active && active.kind == uint8_t(request.kind) &&
      active.pc == request.pc && active.op == uint8_t(request.op) &&
      active.stage == request.stage && active.layer == request.layer &&
      active.request_flags == request.flags &&
      active.ordinal == request.ordinal &&
      numeric_identity_equal(active.identity, request.identity) &&
      active.source_slot == request.source.slot &&
      active.source_version == request.source.version &&
      same_owner(active.source, request.source.owner) &&
      active.target_slot == request.target_slot &&
      active.target_slot_version == request.target_slot_version &&
      active.target_buffer == uint8_t(request.target_buffer) &&
      active.target_bank == request.target_bank &&
      active.target_region == request.target_region &&
      active.gamma == request.gamma;
}

void remember_failure(full::FullRuntime::LifecycleActionTracker& active,
                      Check failure) {
  if (!failure && active.first_error) active.first_error = failure;
}

bool retirement_count(const full::FullRuntime& rt) {
  const auto& a = rt.lifecycle_action;
  return rt.tasks_retired >= a.previous_tasks_retired &&
      rt.last_task_id >= a.previous_task_id &&
      rt.tasks_retired - a.previous_tasks_retired <= UINT16_MAX &&
      rt.tasks_retired - a.previous_tasks_retired == rt.last_task_id - a.previous_task_id;
}

void begin_action(full::FullRuntime& rt, const action::Request& request,
                  const full::FullOwnerSpec& output) {
  auto& active = rt.lifecycle_action;
  active = full::FullRuntime::LifecycleActionTracker{};
  active.active = true;
  active.kind = uint8_t(request.kind);
  active.pc = request.pc;
  active.op = uint8_t(request.op);
  active.stage = request.stage;
  active.layer = request.layer;
  active.request_flags = request.flags;
  active.ordinal = request.ordinal;
  active.identity = request.identity;
  active.source_slot = request.source.slot;
  active.source_version = request.source.version;
  active.source = request.source.owner;
  active.target_slot = request.target_slot;
  active.target_slot_version = request.target_slot_version;
  active.target_buffer = uint8_t(request.target_buffer);
  active.target_bank = request.target_bank;
  active.target_region = request.target_region;
  active.gamma = request.gamma;
  active.output = output;
  active.previous_task_id = rt.last_task_id;
  active.previous_tasks_retired = rt.tasks_retired;
}

bool producer_bound(Check result, const producer::Request& request,
                    const producer::Completion& completion) {
  return completion.family == request.family &&
      completion.request_seq == request.request_seq &&
      completion.provenance_origin_seq == request.provenance_origin_seq &&
      numeric_identity_equal(completion.identity, request.identity) &&
      same_context(completion.context, request.context) &&
      completion.source == request.source &&
      completion.destination == request.destination &&
      completion.source_region == request.source_region &&
      completion.destination_region == request.destination_region &&
      completion.source_role == request.source_role &&
      completion.destination_role == request.destination_role &&
      completion.D == request.D && completion.gamma == request.gamma &&
      completion.eps_bits == request.eps_bits &&
      completion.row_bytes == request.row_bytes &&
      completion.source_first_offset == request.source_first_offset &&
      completion.destination_first_offset == request.destination_first_offset &&
      completion.source_row_step == request.source_row_step &&
      completion.destination_row_step == request.destination_row_step &&
      completion.finished && result.code == completion.status &&
      result.detail == completion.error_detail &&
      result.bad_element == completion.bad_element;
}

bool physical(const full::FullOwnerRecord& record, Buffer id,
              uint8_t bank, uint8_t region) {
  if (record.ref.id == Buffer::NONE || record.region != region) return false;
  if (id == Buffer::ROPE_TABLE && record.ref.id == id) return true;
  if (record.ref.bank != bank) return false;
  return record.ref.id == id ||
      (id == Buffer::WI && record.ref.id == Buffer::DEC_FF) ||
      (id == Buffer::DEC_FF && record.ref.id == Buffer::WI);
}

uint32_t committed_epoch(const full::FullRuntime& rt, Buffer id,
                         uint8_t bank, uint8_t region) {
  for (const auto& record : rt.owners.record)
    if (physical(record, id, bank, region)) return record.max_claimed_epoch;
  return 0;
}

struct OwnerEventResult {
  Check result = protocol();
  provenance::Response response;
  uint32_t flags = 0;
  bool bound = false, terminal = false;
};

OwnerEventResult owner_event(full::FullRuntime& rt,
                             const full::FullMemory& memory,
                             const portal::ModelBinding& model,
                             provenance::Action action_value,
                             const full::FullOwnerSpec& owner,
                             hls::stream<ap_uint<512>>& request_stream,
                             hls::stream<ap_uint<512>>& completion_stream) {
  OwnerEventResult outcome;
  provenance::Request request;
  outcome.result = provenance::build_owner_event(
      rt, memory, model, action_value, &owner, nullptr, 1, request);
  if (!outcome.result) return outcome;
  outcome.result = transaction::exchange_provenance(
      request_stream, completion_stream, request, outcome.response,
      &outcome.flags);
  constexpr uint32_t required = transaction::FRAME_COMPLETE |
      transaction::BINDING_OK;
  outcome.bound = (outcome.flags & required) == required &&
      !(outcome.flags & transaction::LOCAL_REJECT) &&
      response_bound(outcome.result, outcome.response);
  outcome.terminal = outcome.bound &&
      (outcome.flags & transaction::REMOTE_DRAINED) &&
      (outcome.flags & transaction::REMOTE_TERMINAL) &&
      !(outcome.flags & transaction::REMOTE_SCOPE_ACTIVE);
  if (!outcome.bound) outcome.result = protocol();
  return outcome;
}

Check claim_output(full::FullRuntime& rt, const full::FullMemory& memory,
                   const portal::ModelBinding& model,
                   const full::FullOwnerSpec& output,
                   hls::stream<ap_uint<512>>& request_stream,
                   hls::stream<ap_uint<512>>& completion_stream) {
  auto& active = rt.lifecycle_action;
  Check result = full::full_claim_owner(rt, output);
  if (!result) {
    remember_failure(active, result);
    active.active = false;
    return result;
  }
  active.owner_local_claimed = true;
  active.claim_sent = true;
  const OwnerEventResult physical = owner_event(
      rt, memory, model, provenance::Action::CLAIM, output, request_stream,
      completion_stream);
  if (!physical.result || !physical.terminal) {
    result = physical.result ? protocol() : physical.result;
    remember_failure(active, result);
    active.cleanup_pending = true;
    return result;
  }
  active.claim_remote_terminal = true;
  return ok();
}

Check publish_output(full::FullRuntime& rt, const full::FullMemory& memory,
                     const portal::ModelBinding& model,
                     const full::FullOwnerSpec& output,
                     hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream) {
  auto& active = rt.lifecycle_action;
  active.publish_sent = true;
  const OwnerEventResult physical = owner_event(
      rt, memory, model, provenance::Action::PUBLISH, output, request_stream,
      completion_stream);
  Check result = physical.result;
  if (result && (!physical.terminal ||
                 !(physical.flags & transaction::REMOTE_PUBLISHED)))
    result = protocol();
  if (!result) {
    remember_failure(active, result);
    active.cleanup_pending = true;
    return result;
  }
  active.publish_remote_terminal = true;
  result = full::full_publish_owner(rt, output);
  if (!result) {
    remember_failure(active, result);
    active.cleanup_pending = true;
  }
  return result;
}

bool settle_owner_cleanup(full::FullRuntime& rt,
                          const full::FullMemory& memory,
                          const portal::ModelBinding& model,
                          hls::stream<ap_uint<512>>& request_stream,
                          hls::stream<ap_uint<512>>& completion_stream) {
  auto& active = rt.lifecycle_action;
  if (!active.active || rt.generated_store.active) return false;
  if (!active.owner_local_claimed) {
    active.cleanup_local_complete = true;
    active.active = false;
    return true;
  }
  active.cleanup_pending = true;
  const OwnerEventResult physical = owner_event(
      rt, memory, model, provenance::Action::INVALIDATE, active.output,
      request_stream, completion_stream);
  if (!physical.result || !physical.terminal) return false;
  active.cleanup_remote_terminal = true;
  const Check local = full::full_invalidate_owner(
      rt, active.output.ref, active.output.region);
  if (!local) return false;
  active.cleanup_local_complete = true;
  active.cleanup_pending = false;
  active.active = false;
  rt.expected_task_source_count = 0;
  return true;
}

Check execute_task(full::FullRuntime& rt, const full::FullMemory& memory,
                   const portal::ModelBinding& model,
                   const full::FullOwnerSpec& source,
                   const full::FullOwnerSpec& destination,
                   const LayerNormTask& task,
                   hls::stream<ap_uint<512>>& request_stream,
                   hls::stream<ap_uint<512>>& completion_stream) {
  Check result = full::full_bind_task_source(rt, source);
  if (!result) return result;
  provenance::Request begin;
  bool protected_task = false;
  const uint32_t elements = uint32_t(task.ctx.rows) * 1024u;
  result = provenance::build_generated_begin(
      rt, memory, model, task, elements, OutputUnit::F32, begin,
      protected_task);
  if (!result || !protected_task) return result ? protocol(task.ctx.op, 5) : result;

  full::FullOwnerSpec acquired_source, checked_destination;
  result = producer::prepare_layernorm(rt, memory, task, acquired_source,
                                       checked_destination);
  if (!result || acquired_source.ref != source.ref ||
      acquired_source.region != source.region ||
      checked_destination.ref != destination.ref ||
      checked_destination.region != destination.region)
    return result ? protocol(task.ctx.op) : result;

  producer::Request producer_request;
  result = producer::build_layernorm_request(
      rt, memory, model, task, begin, producer_request);
  if (!result) {
    (void)full::full_release_read_owner(rt, source);
    return result;
  }
  result = provenance::arm_generated_store_tracker(rt, begin);
  if (!result) {
    (void)full::full_release_read_owner(rt, source);
    return result;
  }
  rt.generated_store.source_lease = source;
  rt.generated_store.source_lease_active = true;
  rt.lifecycle_action.begin_event_seq = begin.event_seq;
  rt.lifecycle_action.begin_response_bound = false;
  rt.lifecycle_action.begin_scope_active = false;
  rt.lifecycle_action.source_release_pending = true;

  provenance::Response begin_response;
  uint32_t begin_flags = 0;
  result = transaction::exchange_provenance(
      request_stream, completion_stream, begin, begin_response, &begin_flags);
  constexpr uint32_t bound = transaction::FRAME_COMPLETE |
      transaction::BINDING_OK;
  if ((begin_flags & bound) != bound ||
      (begin_flags & transaction::LOCAL_REJECT) ||
      !response_bound(result, begin_response))
    return protocol(task.ctx.op);
  rt.lifecycle_action.begin_response_bound = true;
  rt.lifecycle_action.begin_scope_active =
      begin_flags & transaction::REMOTE_SCOPE_ACTIVE;
  if (!result) {
    const bool terminal = (begin_flags & transaction::REMOTE_DRAINED) &&
        (begin_flags & transaction::REMOTE_TERMINAL) &&
        !(begin_flags & transaction::REMOTE_SCOPE_ACTIVE);
    if (!terminal) return result;
    Check released = full::full_release_read_owner(rt, source);
    if (!released) return result;
    rt.generated_store.source_lease_active = false;
    rt.generated_store.source_lease = full::FullOwnerSpec{};
    rt.lifecycle_action.source_release_pending = false;
    rt.lifecycle_action.begin_scope_active = false;
    rt.lifecycle_action.begin_event_seq = 0;
    provenance::clear_generated_store_tracker(rt);
    return result;
  }
  if (!(begin_flags & transaction::REMOTE_DRAINED) ||
      !(begin_flags & transaction::REMOTE_SCOPE_ACTIVE) ||
      (begin_flags & transaction::REMOTE_TERMINAL))
    return protocol(task.ctx.op);

  producer::Completion producer_completion;
  uint32_t producer_flags = 0;
  result = transaction::exchange_producer(
      request_stream, completion_stream, producer_request,
      producer_completion, &producer_flags);
  const bool local_reject = producer_flags & transaction::LOCAL_REJECT;
  if (!(producer_flags & transaction::FRAME_COMPLETE) ||
      (!local_reject && (!(producer_flags & transaction::BINDING_OK) ||
       !producer_bound(result, producer_request, producer_completion))))
    return protocol(task.ctx.op);

  TaskDone logical_done;
  Check logical_result;
  if (local_reject) {
    if (result || producer_completion.finished ||
        producer_completion.issued_store_bytes ||
        producer_completion.consumed_source_bytes ||
        producer_completion.output_elements ||
        producer_completion.unit != OutputUnit::NONE)
      return protocol(task.ctx.op);
    logical_result = producer::accept_layernorm_local_reject(
        rt, task, source, destination, begin, result, logical_done);
  } else {
    logical_result = producer::accept_layernorm_completion(
        rt, task, source, destination, begin, producer_completion,
        logical_done);
  }
  if (logical_result.code != result.code ||
      logical_result.detail != result.detail ||
      logical_result.bad_element != result.bad_element)
    return protocol(task.ctx.op);
  rt.lifecycle_action.source_release_pending =
      rt.generated_store.source_lease_active;

  provenance::Request end;
  result = provenance::build_generated_end(rt, begin, logical_done, end);
  if (!result) return result;
  provenance::Response end_response;
  while (true) {
    uint32_t end_flags = 0;
    result = transaction::exchange_provenance(
        request_stream, completion_stream, end, end_response, &end_flags);
    if ((end_flags & bound) != bound ||
        (end_flags & transaction::LOCAL_REJECT) ||
        !response_bound(result, end_response))
      return protocol(task.ctx.op);
    rt.lifecycle_action.begin_scope_active = end_response.scope_active;
    if ((end_flags & transaction::REMOTE_DRAINED) &&
        (end_flags & transaction::REMOTE_TERMINAL) &&
        !(end_flags & transaction::REMOTE_SCOPE_ACTIVE))
      break;
  }

  provenance::clear_generated_store_tracker(rt);
  rt.lifecycle_action.begin_event_seq = 0;
  rt.lifecycle_action.begin_response_bound = false;
  rt.lifecycle_action.begin_scope_active = false;
  rt.lifecycle_action.source_release_pending = false;
  TaskDone final_done;
  final_done.task_id = task.ctx.task_id;
  final_done.status = end_response.status;
  final_done.error_detail = end_response.error_detail;
  final_done.bad_element = end_response.bad_element;
  final_done.output_elements = end_response.output_elements;
  final_done.output_unit = end_response.unit;
  final_done.drained = end_response.drained;
  Check retired = full::full_retire_prepared_task(rt, task.ctx, final_done);
  if (retired.code != final_done.status ||
      retired.detail != final_done.error_detail ||
      retired.bad_element != final_done.bad_element)
    return protocol(task.ctx.op);
  Check done_check = check_done(final_done, task.ctx.task_id, elements,
                                OutputUnit::F32);
  if (!done_check || !retired) return done_check ? retired : done_check;
  return full::full_source_accept_completion(
      rt, task.dst, 0, task.ctx, 0, 1, final_done, elements,
      OutputUnit::F32);
}

void base_completion(const action::Request& request,
                     action::Completion& completion) {
  completion = action::Completion{};
  completion.kind = request.kind;
  completion.pc = request.pc;
  completion.op = request.op;
  completion.stage = request.stage;
  completion.layer = request.layer;
  completion.ordinal = request.ordinal;
  completion.identity = request.identity;
  completion.flags = action::FRAME_COMPLETE | action::BINDING_OK;
}

} // namespace

Check execute(full::FullRuntime& rt, full::FullMemory& memory,
              const action::Request& request,
              action::Completion& completion,
              hls::stream<ap_uint<512>>& transaction_request,
              hls::stream<ap_uint<512>>& transaction_completion) {
  base_completion(request, completion);
  Check valid = action::validate(request);
  auto& active = rt.lifecycle_action;
  if (active.active) {
    if (!valid || !action_bound(active, request)) {
      completion.result = protocol(request.op);
      return completion.result;
    }
    portal::ModelBinding resume_model;
    Check resume = portal::build_l13m_model_binding(resume_model);
    if (!resume) remember_failure(active, resume);
    if (resume && !rt.generated_store.active)
      (void)settle_owner_cleanup(rt, memory, resume_model,
                                 transaction_request,
                                 transaction_completion);
    completion.result = active.first_error;
    if (!retirement_count(rt)) {
      completion.result = protocol(request.op);
      return completion.result;
    }
    completion.retired_tasks =
        uint16_t(rt.tasks_retired - active.previous_tasks_retired);
    if (completion.retired_tasks) {
      completion.first_task_id = active.previous_task_id + 1;
      completion.last_task_id = rt.last_task_id;
    }
    if (!active.active)
      completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED;
    return completion.result;
  }
  if (!valid || !numeric_identity_equal(request.identity, rt.inputs.identity) ||
      !rt.request_valid || !rt.model_header_valid ||
      request.source.version != request.source.owner.ref.epoch) {
    completion.result = valid ? protocol(request.op, 4) : valid;
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::LOCAL_REJECT;
    return completion.result;
  }
  if (request.kind != action::Kind::NORM) {
    completion.result = protocol(request.op, 5);
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::LOCAL_REJECT;
    return completion.result;
  }

  full::FullOwnerRecord source_record;
  valid = full::full_owner_snapshot(rt, request.source.owner.ref,
                                    request.source.owner.region,
                                    source_record);
  if (!valid || !source_record.valid ||
      source_record.state != CacheState::READY ||
      source_record.stage != request.source.owner.stage ||
      source_record.layer != request.source.owner.layer ||
      source_record.batch != request.source.owner.batch ||
      source_record.row_space != request.source.owner.row_space ||
      source_record.row0 != request.source.owner.row0 ||
      source_record.rows != request.source.owner.rows ||
      source_record.width != request.source.owner.width ||
      source_record.content != request.source.owner.content) {
    completion.result = valid ? protocol(request.op, 9) : valid;
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::LOCAL_REJECT;
    return completion.result;
  }

  const uint32_t committed = committed_epoch(
      rt, request.target_buffer, request.target_bank, request.target_region);
  BufferRef target_ref = rt.dispatch_reservations.ref(
      request.target_buffer, request.target_bank, request.target_region,
      committed);
  if (!target_ref.epoch) {
    completion.result = protocol(request.op, 9);
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::LOCAL_REJECT;
    return completion.result;
  }
  full::FullOwnerSpec output{
      target_ref, request.target_region, request.stage, request.layer, 255,
      request.source.owner.row_space, 0, request.identity.S, 1024,
      Content::F32};
  begin_action(rt, request, output);

  portal::ModelBinding model;
  Check result = portal::build_l13m_model_binding(model);
  if (result)
    result = claim_output(rt, memory, model, output,
                          transaction_request, transaction_completion);
  for (unsigned batch = 0; batch < request.identity.B && result; ++batch) {
    for (unsigned row = 0; row < request.identity.S && result; row += 16) {
      LayerNormTask task;
      task.ctx = rt.dispatch_reservations.context(
          rt.last_task_id, request.op, request.stage, request.layer,
          uint8_t(batch), request.source.owner.row_space, uint16_t(row),
          uint8_t(request.identity.S - row < 16 ?
                  request.identity.S - row : 16));
      task.src = request.source.owner.ref;
      task.dst = output.ref;
      task.gamma = request.gamma;
      result = execute_task(rt, memory, model, request.source.owner, output,
                            task, transaction_request,
                            transaction_completion);
    }
  }
  if (result)
    result = publish_output(rt, memory, model, output,
                            transaction_request, transaction_completion);
  if (!result) {
    remember_failure(active, result);
    if (!rt.generated_store.active)
      (void)settle_owner_cleanup(rt, memory, model, transaction_request,
                                 transaction_completion);
  }

  completion.result = result ? result : active.first_error;
  if (!retirement_count(rt)) {
    completion.result = protocol(request.op);
    return completion.result;
  }
  completion.retired_tasks =
      uint16_t(rt.tasks_retired - active.previous_tasks_retired);
  if (completion.retired_tasks) {
    completion.first_task_id = active.previous_task_id + 1;
    completion.last_task_id = rt.last_task_id;
  }
  if (result) {
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::SLOT_UPDATE_VALID | action::TYPED_RETIRED;
    completion.slot_delta.slot = request.target_slot;
    completion.slot_delta.version = request.target_slot_version;
    completion.slot_delta.owner = output;
    active.active = false;
  } else if (!active.active) {
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED;
  }
  return completion.result;
}

} // namespace laya::lifecycle
#endif
