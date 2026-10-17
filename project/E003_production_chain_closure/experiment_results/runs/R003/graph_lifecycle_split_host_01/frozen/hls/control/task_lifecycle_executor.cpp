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

Check owner_event(full::FullRuntime& rt, const full::FullMemory& memory,
                  const portal::ModelBinding& model,
                  provenance::Action action_value,
                  const full::FullOwnerSpec& owner,
                  hls::stream<ap_uint<512>>& request_stream,
                  hls::stream<ap_uint<512>>& completion_stream) {
  provenance::Request request;
  Check result = provenance::build_owner_event(
      rt, memory, model, action_value, &owner, nullptr, 1, request);
  if (!result) return result;
  provenance::Response response;
  uint32_t flags = 0;
  result = transaction::exchange_provenance(
      request_stream, completion_stream, request, response, &flags);
  constexpr uint32_t required = transaction::FRAME_COMPLETE |
      transaction::BINDING_OK;
  if ((flags & required) != required || (flags & transaction::LOCAL_REJECT) ||
      !response_bound(result, response))
    return protocol();
  return result;
}

Check claim_output(full::FullRuntime& rt, const full::FullMemory& memory,
                   const portal::ModelBinding& model,
                   const full::FullOwnerSpec& output,
                   hls::stream<ap_uint<512>>& request_stream,
                   hls::stream<ap_uint<512>>& completion_stream) {
  Check result = full::full_claim_owner(rt, output);
  if (!result) return result;
  Check physical_result = owner_event(rt, memory, model,
      provenance::Action::CLAIM, output, request_stream, completion_stream);
  if (!physical_result) {
    (void)full::full_invalidate_owner(rt, output.ref, output.region);
    return physical_result;
  }
  return result;
}

Check publish_output(full::FullRuntime& rt, const full::FullMemory& memory,
                     const portal::ModelBinding& model,
                     const full::FullOwnerSpec& output,
                     hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream) {
  Check result = owner_event(rt, memory, model, provenance::Action::PUBLISH,
                             output, request_stream, completion_stream);
  return result ? full::full_publish_owner(rt, output) : result;
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
  if (!result) {
    Check released = full::full_release_read_owner(rt, source);
    rt.generated_store.source_lease_active = false;
    rt.generated_store.source_lease = full::FullOwnerSpec{};
    provenance::clear_generated_store_tracker(rt);
    return released ? result : released;
  }

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

  provenance::Request end;
  result = provenance::build_generated_end(rt, begin, logical_done, end);
  if (!result) return result;
  provenance::Response end_response;
  do {
    uint32_t end_flags = 0;
    result = transaction::exchange_provenance(
        request_stream, completion_stream, end, end_response, &end_flags);
    if ((end_flags & bound) != bound ||
        (end_flags & transaction::LOCAL_REJECT) ||
        !response_bound(result, end_response))
      return protocol(task.ctx.op);
  } while (!end_response.drained || end_response.scope_active);

  provenance::clear_generated_store_tracker(rt);
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
      source_record.row_space != request.source.owner.row_space ||
      source_record.rows != request.source.owner.rows ||
      source_record.width != request.source.owner.width ||
      source_record.content != request.source.owner.content) {
    completion.result = valid ? protocol(request.op, 9) : valid;
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::LOCAL_REJECT;
    return completion.result;
  }

  const uint32_t previous_task = rt.last_task_id;
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

  completion.result = result;
  completion.first_task_id = previous_task + 1;
  completion.last_task_id = rt.last_task_id;
  completion.retired_tasks = uint16_t(rt.last_task_id - previous_task);
  if (result) {
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
                        action::SLOT_UPDATE_VALID | action::TYPED_RETIRED;
    completion.slot_delta.slot = request.target_slot;
    completion.slot_delta.version = request.target_slot_version;
    completion.slot_delta.owner = output;
  } else if (!rt.generated_store.active) {
    completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED;
  }
  return result;
}

} // namespace laya::lifecycle
#endif
