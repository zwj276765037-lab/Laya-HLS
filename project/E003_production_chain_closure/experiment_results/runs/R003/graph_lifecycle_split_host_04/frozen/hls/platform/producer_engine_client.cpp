#include "laya_producer_engine_client.h"

namespace laya::producer {
namespace {

Check protocol(Op op, uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(op), reason)};
}
Check shape(Op op) {
  return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
}
Check buffer(Buffer id) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), 9)};
}
bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}
bool supported(const LayerNormTask& task) {
  return (task.ctx.op == Op::LN_ATTN || task.ctx.op == Op::LN_FFN) &&
         (task.ctx.stage == 2 || task.ctx.stage == 4) &&
         !(task.ctx.op == Op::LN_ATTN && task.ctx.stage == 2 &&
           task.ctx.layer == 0) &&
         task.ctx.row_space == RowSpace::TOKEN && task.gamma == 0 &&
         task.D == 1024 && task.eps_bits == 0x3727c5acu &&
         task.src.id == Buffer::HIDDEN && task.dst.id == Buffer::NORM &&
         task.src != task.dst;
}
full::FullOwnerSpec destination_spec(const full::FullRuntime& rt,
                                     const LayerNormTask& task) {
  return {task.dst, 0, task.ctx.stage, task.ctx.layer, 255,
          RowSpace::TOKEN, 0, rt.inputs.identity.S, 1024, Content::F32};
}
Check bound_source(const full::FullRuntime& rt, const LayerNormTask& task,
                   full::FullOwnerSpec& source) {
  for (unsigned i = 0; i < rt.expected_task_source_count; ++i) {
    const full::FullOwnerSpec& candidate = rt.expected_task_source[i];
    if (candidate.ref != task.src || candidate.region != 0) continue;
    if (candidate.content != Content::F32 || candidate.width != 1024 ||
        candidate.row_space != task.ctx.row_space)
      return buffer(task.src.id);
    source = candidate;
    return ok();
  }
  return buffer(task.src.id);
}

Check release_layernorm_source(full::FullRuntime& rt,
                               const full::FullOwnerSpec& source,
                               Op op) {
  auto& tracker = rt.generated_store;
  if (!tracker.active || !tracker.source_lease_active ||
      tracker.source_lease.ref != source.ref ||
      tracker.source_lease.region != source.region)
    return protocol(op);
  const Check released = full::full_release_read_owner(rt, source);
  if (!released) return released;
  tracker.source_lease_active = false;
  tracker.source_lease = full::FullOwnerSpec{};
  return ok();
}

} // namespace

Check prepare_layernorm(full::FullRuntime& rt, const full::FullMemory& memory,
                        const LayerNormTask& task,
                        full::FullOwnerSpec& source,
                        full::FullOwnerSpec& destination) {
  (void)memory;
  if (!rt.request_valid || !rt.model_header_valid ||
      task.ctx.task_id != rt.last_task_id + 1 ||
      task.ctx.task_id > kMaxEpoch ||
      !check_context(task.ctx, rt.inputs.identity.B, rt.inputs.identity.S))
    return protocol(task.ctx.op, 4);
  if (!supported(task) || !check_ref(task.src) || !check_ref(task.dst))
    return shape(task.ctx.op);
  Check result = bound_source(rt, task, source);
  if (!result) return result;
  result = full::full_require_owner(rt, source, task.ctx.batch,
                                    task.ctx.row0, task.ctx.rows);
  destination = destination_spec(rt, task);
  if (result)
    result = full::full_check_uncovered_owner(
        rt, destination, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  if (result)
    result = full::full_acquire_owner(rt, source, task.ctx.batch,
                                      task.ctx.row0, task.ctx.rows);
  return result;
}

Check build_layernorm_request(full::FullRuntime& rt,
                              const full::FullMemory& memory,
                              const portal::ModelBinding& model,
                              const LayerNormTask& task,
                              const provenance::Request& begin,
                              Request& request) {
  if (!supported(task) || begin.action != provenance::Action::BEGIN ||
      begin.descriptor_count != 1 ||
      !numeric_identity_equal(begin.identity, rt.inputs.identity) ||
      !same_context(begin.context, task.ctx) ||
      begin.descriptor[0].target_ref != task.dst ||
      begin.descriptor[0].target_region != 0 ||
      begin.geometry[0].component != provenance::Component::FULL_WIDTH ||
      begin.geometry[0].segment_bytes != 4096 ||
      begin.geometry[0].row_count != task.ctx.rows ||
      begin.geometry[0].repeat_count != 1 ||
      begin.geometry[0].total_write_bytes !=
          uint64_t(task.ctx.rows) * 4096u)
    return protocol(task.ctx.op);

  Address source_address, destination_address;
  Check result = full::full_f32_address(
      rt, memory, task.src, 0, task.ctx.batch, task.ctx.row0, 0,
      source_address);
  if (result)
    result = full::full_f32_address(
        rt, memory, task.dst, 0, task.ctx.batch, task.ctx.row0, 0,
        destination_address);
  if (!result) return result;
  if (destination_address.bo != begin.descriptor[0].role ||
      destination_address.offset != begin.geometry[0].first_offset ||
      begin.geometry[0].row_step != (task.ctx.rows == 1 ? 0 : 4096))
    return protocol(task.ctx.op);
  const uint64_t source_span = full::full_bo_capacity(memory,
                                                       source_address.bo);
  const uint64_t destination_span = full::full_bo_capacity(
      memory, destination_address.bo);
  const uint64_t bytes = uint64_t(task.ctx.rows) * 4096u;
  result = full::full_span(memory, source_address.bo,
                           source_address.offset, bytes);
  if (result)
    result = full::full_span(memory, destination_address.bo,
                             destination_address.offset, bytes);
  if (!result) return result;
  if (!source_span || !destination_span ||
      begin.descriptor[0].bo_span != destination_span ||
      rt.producer_request_high_water == UINT64_MAX)
    return protocol(task.ctx.op, 9);

  request = Request{};
  request.request_seq = ++rt.producer_request_high_water;
  request.provenance_origin_seq = begin.event_seq;
  request.identity = rt.inputs.identity;
  request.context = task.ctx;
  request.model_identity = model.identity;
  request.source = task.src;
  request.destination = task.dst;
  request.gamma = task.gamma;
  request.source_role = source_address.bo;
  request.destination_role = destination_address.bo;
  request.source_first_offset = source_address.offset;
  request.destination_first_offset = destination_address.offset;
  request.source_bo_span = source_span;
  request.destination_bo_span = destination_span;
  request.expected_elements = uint32_t(task.ctx.rows) * 1024u;
  return ok();
}

Check accept_layernorm_completion(full::FullRuntime& rt,
                                  const LayerNormTask& task,
                                  const full::FullOwnerSpec& source,
                                  const full::FullOwnerSpec& destination,
                                  const provenance::Request& begin,
                                  const Completion& completion,
                                  TaskDone& done) {
  auto& tracker = rt.generated_store;
  if (!tracker.active || !tracker.source_lease_active ||
      tracker.source_lease.ref != source.ref ||
      tracker.source_lease.region != source.region ||
      begin.descriptor_count != 1 || tracker.descriptor_count != 1 ||
      completion.provenance_origin_seq != begin.event_seq ||
      completion.issued_store_bytes > begin.geometry[0].total_write_bytes)
    return protocol(task.ctx.op);

  tracker.issued_bytes[0] = completion.issued_store_bytes;
  Check result{completion.status, completion.error_detail,
               completion.bad_element};
  const Check released = release_layernorm_source(rt, source, task.ctx.op);
  if (!released) return released;

  if (result)
    result = full::full_cover_owner(rt, destination, task.ctx.batch,
                                    task.ctx.row0, task.ctx.rows);
  if (!result)
    (void)full::full_invalidate_owner(rt, task.dst, 0);

  done = TaskDone{};
  done.task_id = task.ctx.task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = true;
  if (result) {
    done.output_unit = OutputUnit::F32;
    done.output_elements = uint32_t(task.ctx.rows) * 1024u;
  }
  return result;
}

Check accept_layernorm_local_reject(full::FullRuntime& rt,
                                    const LayerNormTask& task,
                                    const full::FullOwnerSpec& source,
                                    const full::FullOwnerSpec& destination,
                                    const provenance::Request& begin,
                                    Check rejection, TaskDone& done) {
  auto& tracker = rt.generated_store;
  if (rejection || !tracker.active || !tracker.source_lease_active ||
      begin.action != provenance::Action::BEGIN ||
      begin.descriptor_count != 1 || tracker.descriptor_count != 1 ||
      begin.descriptor[0].target_ref != destination.ref ||
      begin.descriptor[0].target_region != destination.region ||
      tracker.issued_bytes[0] || tracker.issued_bytes[1] ||
      !tracker.first_error)
    return protocol(task.ctx.op);

  Check settled = release_layernorm_source(rt, source, task.ctx.op);
  if (!settled) return settled;
  settled = full::full_invalidate_owner(rt, destination.ref,
                                        destination.region);
  if (!settled) return settled;

  done = TaskDone{};
  done.task_id = task.ctx.task_id;
  done.status = rejection.code;
  done.error_detail = rejection.detail;
  done.bad_element = rejection.bad_element;
  done.drained = true;
  return rejection;
}

} // namespace laya::producer
