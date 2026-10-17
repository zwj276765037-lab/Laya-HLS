#include "laya_compute_portal_commit.h"

namespace laya::portal {
namespace {

Check protocol(Op op, uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(op), reason)};
}

Check finish(full::FullRuntime& rt, const TaskContext& context,
             uint32_t elements, OutputUnit unit, Check mutation,
             TaskDone& done) {
  Check contract = check_done(done, context.task_id, elements, unit);
  if (!contract) mutation = contract;
  if (context.task_id != rt.last_task_id + 1 ||
      context.task_id > kMaxEpoch) mutation = protocol(context.op);
  if (!mutation) {
    done.status = mutation.code;
    done.error_detail = mutation.detail;
    done.bad_element = mutation.bad_element;
    done.output_elements = 0;
    done.output_beats = 0;
    done.output_unit = OutputUnit::NONE;
    done.drained = true;
  }
  if (context.task_id == rt.last_task_id + 1 &&
      context.task_id <= kMaxEpoch) {
    rt.last_task_id = context.task_id;
    ++rt.tasks_retired;
    ++rt.op_calls[uint8_t(context.op)];
  }
  return mutation;
}

Check response_result(const TaskDone& done) {
  return {done.status, done.error_detail, done.bad_element};
}

full::FullOwnerSpec weight_spec(const full::FullWeightDescriptor& descriptor,
                                BufferRef ref, const TaskContext& context) {
  return {ref, 0, context.stage, context.layer, 0, RowSpace::BATCH,
          0, 1, descriptor.N, Content::Q8_WEIGHT};
}

TaskContext weight_context(const full::FullWeightDescriptor& descriptor,
                           const TaskContext& fallback) {
  TaskContext context = fallback;
  context.stage = descriptor.key.family <= 4 ? 2 :
                  descriptor.key.family <= 8 ? 4 :
                  descriptor.key.family == 9 ? 5 : 6;
  context.layer = descriptor.key.family <= 8 ? descriptor.key.layer : 255;
  return context;
}

full::FullOwnerSpec a_spec(const QuantTask& task) {
  return {task.a_dst, 0, task.ctx.stage, task.ctx.layer, task.ctx.batch,
          task.ctx.row_space, task.ctx.row0, task.ctx.rows, task.K,
          Content::Q8_TILE};
}

F32TileMeta source_meta(const full::FullRuntime& rt, const QuantTask& task) {
  F32TileMeta source;
  source.identity = rt.inputs.identity;
  source.ref = task.src;
  source.region = task.src_region;
  source.row_space = task.ctx.row_space;
  source.batch = task.ctx.batch;
  source.row0 = task.ctx.row0;
  source.rows = task.ctx.rows;
  source.K = task.K;
  source.state = CacheState::READY;
  source.content = Content::F32;
  source.valid = true;
  numeric_cover_all(source.covered_groups, task.ctx.rows, task.K / 32, 16);
  return source;
}

} // namespace

Check commit_load(full::FullRuntime& rt,
                  const full::FullWeightDescriptor& descriptor,
                  const LoadTask& task, TaskDone& done) {
  Check mutation = response_result(done);
  const uint32_t elements = ((uint32_t(descriptor.N) + 7u) & ~7u) *
                            (descriptor.K / 32u) * 34u;
  if (mutation) {
    if (task.ctx.op != Op::LOAD_W || task.dst.id != Buffer::WEIGHT ||
        task.dst.bank != 0 || descriptor.key.family != task.weight.family ||
        descriptor.key.layer != task.weight.layer || task.byte_count != elements)
      mutation = protocol(task.ctx.op, 9);
  }
  if (mutation && rt.current_weight_ref.id != Buffer::NONE) {
    const full::FullOwnerSpec old =
        weight_spec(rt.current_weight, rt.current_weight_ref,
                    weight_context(rt.current_weight, task.ctx));
    mutation = full::full_release_owner(rt, old);
  }
  const full::FullOwnerSpec next = weight_spec(descriptor, task.dst, task.ctx);
  if (mutation) mutation = full::full_claim_owner(rt, next);
  if (mutation) mutation = full::full_cover_owner(rt, next, 0, 0, 1);
  if (mutation) mutation = full::full_publish_owner(rt, next);
  if (mutation) {
    rt.current_weight = descriptor;
    rt.current_weight_ref = task.dst;
  }
  return finish(rt, task.ctx, elements, OutputUnit::BYTES, mutation, done);
}

Check commit_quant(full::FullRuntime& rt, const full::FullOwnerSpec& source,
                   const QuantTask& task, TaskDone& done) {
  Check mutation = response_result(done);
  const uint32_t elements = uint32_t(task.ctx.rows) * task.K / 32u;
  if (mutation && (source.ref != task.src || source.region != task.src_region ||
                   source.row_space != task.ctx.row_space ||
                   source.width != task.K || source.content != Content::F32))
    mutation = protocol(task.ctx.op, 9);
  if (mutation) mutation = full::full_require_owner(
      rt, source, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  const full::FullOwnerSpec activation = a_spec(task);
  if (mutation) mutation = full::full_claim_owner(rt, activation);
  if (mutation) mutation = numeric_claim_a8(rt.cache.activation_meta,
                                            task.a_dst);
  if (mutation) mutation = full::full_cover_owner(
      rt, activation, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  if (mutation) mutation = full::full_publish_owner(rt, activation);
  if (mutation) {
    const F32TileMeta ledger = source_meta(rt, task);
    A8TileMeta& a = rt.cache.activation_meta;
    a.identity = rt.inputs.identity;
    a.source = ledger;
    a.producer_task_id = task.ctx.task_id;
    a.stage = task.ctx.stage; a.layer = task.ctx.layer;
    a.row_space = task.ctx.row_space; a.batch = task.ctx.batch;
    a.row0 = task.ctx.row0; a.rows = task.ctx.rows; a.K = task.K;
    numeric_cover_all(a.covered_groups, task.ctx.rows, task.K / 32, 16);
    a.state = CacheState::READY; a.content = Content::Q8_TILE;
    a.valid = true;
    rt.cache.activation_source_ledger = ledger;
    if (task.ctx.stage == 5) {
      full::FullOwnerSpec next = source;
      next.ref.epoch = source.ref.epoch + 1;
      mutation = full::full_consume_inplace_rows(
          rt, next, task.ctx.batch, task.ctx.row0, task.ctx.rows);
    }
  }
  if (!mutation) {
    full::full_invalidate_owner(rt, task.a_dst, 0);
    numeric_reset_a8(rt.cache.activation_meta);
  }
  rt.expected_quant_source_valid = false;
  return finish(rt, task.ctx, elements, OutputUnit::Q8_GROUP,
                mutation, done);
}

Check commit_geglu(full::FullRuntime& rt,
                   const full::FullOwnerSpec& source,
                   const full::FullOwnerSpec& output,
                   const VectorTask& task, TaskDone& done) {
  Check mutation = response_result(done);
  const uint32_t elements = uint32_t(task.ctx.rows) * task.length;
  if (mutation && (task.ctx.op != Op::GEGLU || source.ref != task.src0 ||
                   source.region != task.src0_region ||
                   output.ref != task.dst || output.region != task.dst_region ||
                   output.width != task.length))
    mutation = protocol(task.ctx.op, 9);
  if (mutation) mutation = full::full_require_owner(
      rt, source, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  if (mutation) mutation = full::full_check_uncovered_owner(
      rt, output, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  if (mutation) mutation = full::full_cover_owner(
      rt, output, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  rt.expected_task_source_count = 0;
  return finish(rt, task.ctx, elements, OutputUnit::F32, mutation, done);
}

Check commit_matrix(full::FullRuntime& rt,
                    const full::FullOwnerSpec& output,
                    const full::FullOwnerSpec* qkv_pair,
                    const LinearTask& task, TaskDone& done) {
  Check mutation = response_result(done);
  const uint32_t elements = uint32_t(task.ctx.rows) * task.N;
  const full::FullOwnerSpec activation = {
      task.a, 0, task.ctx.stage, task.ctx.layer, task.ctx.batch,
      task.ctx.row_space, task.ctx.row0, task.ctx.rows, task.K,
      Content::Q8_TILE};
  const full::FullOwnerSpec weight =
      weight_spec(rt.current_weight, task.w, task.ctx);
  if (mutation && (output.ref != task.dst || output.region != task.dst_region ||
                   rt.current_weight_ref != task.w))
    mutation = protocol(task.ctx.op, 9);
  if (mutation) mutation = full::full_require_owner(
      rt, activation, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  if (mutation) mutation = full::full_require_owner(rt, weight, 0, 0, 1);
  if (mutation && task.ctx.op == Op::LIN_QKV) {
    if (!qkv_pair) mutation = protocol(task.ctx.op, 9);
    else {
      full::FullOwnerSpec pair[2] = {qkv_pair[0], qkv_pair[1]};
      mutation = full::full_check_uncovered_qkv(
          rt, pair, task.ctx.batch, task.ctx.row0, task.ctx.rows);
      for (uint8_t plane = 0; plane < 3 && mutation; ++plane)
        for (uint8_t head = 0; head < 16 && mutation; ++head)
          mutation = full::full_cover_qkv(
              rt, pair, plane, head, task.ctx.batch,
              task.ctx.row0, task.ctx.rows);
    }
  } else if (mutation) {
    mutation = full::full_check_uncovered_owner(
        rt, output, task.ctx.batch, task.ctx.row0, task.ctx.rows);
    if (mutation) mutation = full::full_cover_owner(
        rt, output, task.ctx.batch, task.ctx.row0, task.ctx.rows);
  }
  if (mutation) mutation = full::full_release_owner(rt, activation);
  if (mutation) mutation = numeric_release_a8(rt.cache.activation_meta);
  if (!mutation) {
    full::full_invalidate_owner(rt, task.a, 0);
    numeric_reset_a8(rt.cache.activation_meta);
  }
  rt.expected_task_source_count = 0;
  return finish(rt, task.ctx, elements, OutputUnit::F32, mutation, done);
}

} // namespace laya::portal

