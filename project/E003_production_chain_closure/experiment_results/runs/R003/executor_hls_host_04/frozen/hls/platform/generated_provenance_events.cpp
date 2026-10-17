#include "laya_generated_provenance_events.h"

namespace laya::provenance {
namespace {

Check protocol(uint8_t op = 0, uint16_t reason = 9) {
  return {Status::E_PROTOCOL, detail(7, op, reason)};
}
Check buffer(Buffer id, uint16_t reason = 8) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), reason)};
}

full::FullOwnerSpec owner_spec(const full::FullOwnerRecord& record) {
  return {record.ref, record.region, record.stage, record.layer, record.batch,
          record.row_space, record.row0, record.rows, record.width,
          record.content};
}

Check snapshot(const full::FullRuntime& rt, BufferRef ref, uint8_t region,
               full::FullOwnerSpec& owner, BufferRef& old_ref) {
  full::FullOwnerRecord record;
  Check c = full::full_owner_snapshot(rt, ref, region, record);
  if (!c || (record.state != CacheState::FILL &&
             record.state != CacheState::EXCLUSIVE_RW) ||
      !numeric_identity_equal(record.identity, rt.inputs.identity))
    return buffer(ref.id);
  owner = owner_spec(record);
  old_ref = record.state == CacheState::EXCLUSIVE_RW ?
            record.lease_old_ref : none();
  return ok();
}

uint64_t physical_batch_stride(BufferRef ref, uint8_t region) {
  switch (ref.id) {
    case Buffer::HIDDEN: case Buffer::NORM: case Buffer::TMP:
    case Buffer::ATT_OUT: return 1024ull * 1024 * 4;
    case Buffer::WI: return 1024ull * 5248 * 4;
    case Buffer::GATE: return 1024ull * 2624 * 4;
    case Buffer::DEC_FF: return 1024ull * 4096 * 4;
    case Buffer::MARKER: return 16ull * 1024 * 4;
    case Buffer::TYPE_ROWS: return 0;
    case Buffer::HEAD_WORK:
      switch (Region(region)) {
        case Region::SCORER_ACT: return 16ull * 1024 * 4;
        case Region::ACT_INPUT: return 1028ull * 4;
        case Region::ACT_HIDDEN: return 256ull * 4;
        case Region::CAND_RAW: case Region::CAND_MASKED:
        case Region::CAND_PROB: return 16ull * 4;
        case Region::ACT_LOGITS: return 2ull * 4;
        case Region::STATS: return 4ull * 4;
      }
      break;
    default: break;
  }
  return 0;
}

Check address(const full::FullRuntime& rt, const full::FullMemory& memory,
              const full::FullOwnerSpec& owner, uint8_t batch,
              uint16_t row, uint16_t col, Address& result) {
  return full::full_f32_address(rt, memory, owner.ref, owner.region,
                                batch, row, col, result);
}

Check descriptor(const full::FullRuntime& rt, const full::FullMemory& memory,
                 const full::FullOwnerSpec& owner, BufferRef old_ref,
                 OwnerDescriptor& result) {
  result = OwnerDescriptor{};
  Span mapped;
  Check c = span(owner.ref, owner.region, mapped);
  if (!c) return c;
  const uint64_t capacity = full::full_bo_capacity(memory, mapped.bo);
  if (!capacity || uint64_t(mapped.base) + mapped.bytes > capacity)
    return buffer(owner.ref.id);
  result.target_ref = owner.ref;
  result.target_region = owner.region;
  result.old_ref = old_ref;
  result.old_region = old_ref.id == Buffer::NONE ? 0 : owner.region;
  result.stage = owner.stage; result.layer = owner.layer;
  result.batch = owner.batch; result.row_space = owner.row_space;
  result.row0 = owner.row0; result.rows = owner.rows;
  result.width = owner.width; result.content = owner.content;
  result.role = mapped.bo; result.bo_span = capacity;
  if (owner.ref.id == Buffer::QKV) {
    result.layout = 1;
    result.owner_base_offset = mapped.base;
    result.row_stride = 64ull * 4;
    result.batch_stride = 8ull * 1024 * 64 * 4;
    result.head_stride = 1024ull * 64 * 4;
    result.plane_stride = 2ull * 8 * 1024 * 64 * 4;
    const uint8_t batches = owner.batch == 255 ? rt.inputs.identity.B : 1;
    const uint16_t last_row = uint16_t(owner.row0 + owner.rows - 1);
    result.owner_extent_span = 2 * result.plane_stride +
        uint64_t(batches - 1) * result.batch_stride +
        7 * result.head_stride + uint64_t(last_row) * result.row_stride +
        64ull * 4;
    return result.owner_extent_span <= mapped.bytes ? ok() : buffer(owner.ref.id);
  }
  const uint8_t first_batch = owner.batch == 255 ? 0 : owner.batch;
  const uint8_t last_batch = owner.batch == 255 ?
      uint8_t(rt.inputs.identity.B - 1) : owner.batch;
  Address first, last;
  c = address(rt, memory, owner, first_batch, owner.row0, 0, first);
  if (!c) return c;
  c = address(rt, memory, owner, last_batch,
              uint16_t(owner.row0 + owner.rows - 1),
              uint16_t(owner.width - 1), last);
  if (!c || first.bo != mapped.bo || last.bo != mapped.bo ||
      last.offset < first.offset) return buffer(owner.ref.id);
  result.owner_base_offset = first.offset;
  result.batch_stride = owner.batch == 255 ?
                        physical_batch_stride(owner.ref, owner.region) : 0;
  if (owner.rows == 1) result.row_stride = 0;
  else {
    Address next;
    c = address(rt, memory, owner, first_batch,
                uint16_t(owner.row0 + 1), 0, next);
    if (!c || next.bo != first.bo || next.offset <= first.offset)
      return buffer(owner.ref.id);
    result.row_stride = uint64_t(next.offset) - first.offset;
  }
  result.owner_extent_span = uint64_t(last.offset) - first.offset + 4;
  return result.owner_base_offset <= result.bo_span &&
         result.owner_extent_span <= result.bo_span - result.owner_base_offset ?
         ok() : buffer(owner.ref.id);
}

constexpr uint64_t kNormBase = 8ull * 1024 * 1024;
constexpr uint64_t kNormBytes = 8ull * 1024 * 1024;
constexpr uint64_t kNormRowStride = 1024ull * 4;
constexpr uint64_t kNormBatchStride = 1024ull * kNormRowStride;

// Equivalent to f32_address/byte_address for an already checked NORM Ref.
// Keep the original first-address error order, including the range rather
// than the stricter legal-shape test used by later wire validation.
Check norm_offset(const NumericIdentity& id, uint8_t batch, uint16_t row,
                  uint16_t col, uint64_t& offset) {
  if (batch >= id.B || id.B < 1 || id.B > 2 ||
      id.S < 64 || id.S > 1024 || row >= id.S)
    return buffer(Buffer::NORM, 5);
  if (col >= 1024) return buffer(Buffer::NORM, 4);
  const uint64_t relative = uint64_t(batch) * kNormBatchStride +
      uint64_t(row) * kNormRowStride + uint64_t(col) * 4;
  if (relative > UINT32_MAX || relative + 4 > kNormBytes ||
      kNormBase + relative + 4 > UINT32_MAX)
    return buffer(Buffer::NORM);
  offset = kNormBase + relative;
  return ok();
}

Check norm_descriptor(const full::FullRuntime& rt, const full::FullMemory& memory,
                      const full::FullOwnerSpec& owner, BufferRef old_ref,
                      OwnerDescriptor& result) {
  result = OwnerDescriptor{};
  Check c = check_ref(owner.ref, owner.region);
  if (!c) return c;
  if (owner.ref.id != Buffer::NORM) return buffer(owner.ref.id, 4);
  const uint64_t capacity = full::full_bo_capacity(memory, Bo::STATE0);
  if (!capacity || kNormBase + kNormBytes > capacity)
    return buffer(owner.ref.id);
  result.target_ref = owner.ref;
  result.target_region = owner.region;
  result.old_ref = old_ref;
  result.old_region = old_ref.id == Buffer::NONE ? 0 : owner.region;
  result.stage = owner.stage; result.layer = owner.layer;
  result.batch = owner.batch; result.row_space = owner.row_space;
  result.row0 = owner.row0; result.rows = owner.rows;
  result.width = owner.width; result.content = owner.content;
  result.role = Bo::STATE0; result.bo_span = capacity;

  const uint8_t first_batch = owner.batch == 255 ? 0 : owner.batch;
  const uint8_t last_batch = owner.batch == 255 ?
      uint8_t(rt.inputs.identity.B - 1) : owner.batch;
  uint64_t first, last;
  c = norm_offset(rt.inputs.identity, first_batch, owner.row0, 0, first);
  if (!c) return c;
  // This is the same physical-presence/capacity/32-bit check as the generic
  // first full_f32_address. Capacity alone must not authorize a missing BO.
  c = full::full_span(memory, Bo::STATE0, first, 4);
  if (!c) return c;
  c = norm_offset(rt.inputs.identity, last_batch,
                  uint16_t(owner.row0 + owner.rows - 1),
                  uint16_t(owner.width - 1), last);
  if (!c || last < first) return buffer(owner.ref.id);
  result.owner_base_offset = first;
  result.batch_stride = owner.batch == 255 ? kNormBatchStride : 0;
  if (owner.rows == 1) result.row_stride = 0;
  else {
    uint64_t next;
    c = norm_offset(rt.inputs.identity, first_batch,
                    uint16_t(owner.row0 + 1), 0, next);
    if (!c || next <= first) return buffer(owner.ref.id);
    result.row_stride = next - first;
  }
  // All later offsets lie inside the same checked 8MiB span. The complete
  // mapped capacity and presence above make repeated full_span redundant.
  result.owner_extent_span = last - first + 4;
  return result.owner_base_offset <= result.bo_span &&
         result.owner_extent_span <= result.bo_span - result.owner_base_offset ?
         ok() : buffer(owner.ref.id);
}

Check norm_geometry(const full::FullRuntime& rt, const full::FullMemory& memory,
                    const TaskContext& context, WriteGeometry& result) {
  uint64_t first;
  Check c = norm_offset(rt.inputs.identity, context.batch, context.row0, 0, first);
  if (!c) return c;
  c = full::full_span(memory, Bo::STATE0, first, 4);
  if (!c) return c;
  result = WriteGeometry{};
  result.first_offset = first;
  result.segment_bytes = uint32_t(kNormRowStride);
  result.row_count = context.rows;
  result.repeat_count = 1;
  if (context.rows > 1) {
    uint64_t next;
    c = norm_offset(rt.inputs.identity, context.batch,
                    uint16_t(context.row0 + 1), 0, next);
    if (!c || next <= first) return buffer(Buffer::NORM);
    result.row_step = next - first;
  }
  result.total_write_bytes = kNormRowStride * context.rows;
  result.component = Component::FULL_WIDTH;
  result.head = 255;
  result.plane_mask = 0;
  return ok();
}

Check next_sequence(full::FullRuntime& rt, uint64_t& sequence) {
  if (rt.provenance_event_high_water == UINT64_MAX) return protocol();
  sequence = ++rt.provenance_event_high_water;
  return ok();
}

void common(Request& request, const full::FullRuntime& rt,
            const portal::ModelBinding& model) {
  request.identity = rt.inputs.identity;
  request.model_identity = model.identity;
}

Check wire_check(const Request& request) {
#ifdef LAYA_TRANSACTION_SEQUENCER_CODEC
  (void)request;
  return ok();
#else
  Request decoded;
  return decode(encode(request), decoded);
#endif
}

Check geometry(const full::FullRuntime& rt, const full::FullMemory& memory,
               const full::FullOwnerSpec& owner, const TaskContext& context,
               uint16_t width, uint16_t first_row, uint16_t rows,
               Component component, uint8_t head, uint8_t plane_mask,
               WriteGeometry& result) {
  Address first;
  const uint16_t column = component == Component::ATT_HEAD ?
                          uint16_t(head * 64u) : 0;
  Check c = address(rt, memory, owner, context.batch, first_row, column, first);
  if (!c) return c;
  result = WriteGeometry{};
  result.first_offset = first.offset;
  result.segment_bytes = uint32_t(width) * 4;
  result.row_count = rows;
  result.repeat_count = 1;
  if (rows > 1) {
    Address next;
    c = address(rt, memory, owner, context.batch,
                uint16_t(first_row + 1), column, next);
    if (!c || next.bo != first.bo || next.offset <= first.offset)
      return buffer(owner.ref.id);
    result.row_step = uint64_t(next.offset) - first.offset;
  }
  result.total_write_bytes = uint64_t(result.segment_bytes) * rows;
  result.component = component;
  result.head = component == Component::FULL_WIDTH ? 255 : head;
  result.plane_mask = plane_mask;
  return ok();
}

Check ordinary_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                     const portal::ModelBinding& model,
                     const TaskContext& context, BufferRef target,
                     uint8_t region, uint16_t width, uint16_t first_row,
                     uint16_t rows, uint32_t elements, OutputUnit unit,
                     Component component, uint8_t head, Request& request,
                     bool& protected_task) {
  protected_task = true;
  if (unit != OutputUnit::F32 || !elements) return protocol(uint8_t(context.op));
  full::FullOwnerSpec owner;
  BufferRef old_ref;
  Check c = snapshot(rt, target, region, owner, old_ref);
  if (!c) return c;
  request = Request{};
  request.action = Action::BEGIN;
  c = next_sequence(rt, request.event_seq);
  if (!c) return c;
  request.origin_seq = request.event_seq;
  request.context = context;
  common(request, rt, model);
  request.descriptor_count = 1;
  request.expected_unit = unit;
  request.expected_elements = elements;
  c = descriptor(rt, memory, owner, old_ref, request.descriptor[0]);
  if (c) c = geometry(rt, memory, owner, context, width, first_row, rows,
                      component, head, 0, request.geometry[0]);
  return c ? wire_check(request) : c;
}

} // namespace

Check build_owner_event(full::FullRuntime& rt, const full::FullMemory& memory,
                        const portal::ModelBinding& model, Action action,
                        const full::FullOwnerSpec* owner,
                        const full::FullOwnerSpec* old_owner,
                        uint8_t count, Request& request) {
  if ((action != Action::CLAIM && action != Action::PUBLISH &&
       action != Action::RELEASE && action != Action::INVALIDATE) ||
      !owner || count < 1 || count > 2)
    return protocol();
  request = Request{};
  request.action = action;
  Check c = next_sequence(rt, request.event_seq);
  if (!c) return c;
  common(request, rt, model);
  request.descriptor_count = count;
  for (unsigned i = 0; i < count && c; ++i) {
    const BufferRef old = old_owner ? old_owner[i].ref : none();
    c = descriptor(rt, memory, owner[i], old, request.descriptor[i]);
  }
  return c ? wire_check(request) : c;
}

Check build_norm_owner_event(full::FullRuntime& rt, const full::FullMemory& memory,
                             const portal::ModelBinding& model, Action action,
                             const full::FullOwnerSpec& owner, Request& request) {
  if (action != Action::CLAIM && action != Action::PUBLISH &&
      action != Action::RELEASE && action != Action::INVALIDATE)
    return protocol();
  request = Request{};
  request.action = action;
  Check c = next_sequence(rt, request.event_seq);
  if (!c) return c;
  common(request, rt, model);
  request.descriptor_count = 1;
  c = norm_descriptor(rt, memory, owner, none(), request.descriptor[0]);
  return c ? wire_check(request) : c;
}

Check build_norm_generated_begin(full::FullRuntime& rt,
                                 const full::FullMemory& memory,
                                 const portal::ModelBinding& model,
                                 const LayerNormTask& task, uint32_t elements,
                                 OutputUnit unit, Request& request,
                                 bool& protected_task) {
  // Match ordinary_begin's order: invalid unit/elements and a failed complete
  // snapshot do not consume sequence; descriptor/geometry/wire failures do.
  protected_task = true;
  if (unit != OutputUnit::F32 || !elements) return protocol(uint8_t(task.ctx.op));
  full::FullOwnerSpec owner;
  BufferRef old_ref;
  Check c = snapshot(rt, task.dst, 0, owner, old_ref);
  if (!c) return c;
  request = Request{};
  request.action = Action::BEGIN;
  c = next_sequence(rt, request.event_seq);
  if (!c) return c;
  request.origin_seq = request.event_seq;
  request.context = task.ctx;
  common(request, rt, model);
  request.descriptor_count = 1;
  request.expected_unit = unit;
  request.expected_elements = elements;
  c = norm_descriptor(rt, memory, owner, old_ref, request.descriptor[0]);
  if (c) c = norm_geometry(rt, memory, task.ctx, request.geometry[0]);
  return c ? wire_check(request) : c;
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const EmbeddingTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  const uint16_t row = task.ctx.op == Op::EMB_TYPE ? task.type_id : task.ctx.row0;
  const uint16_t rows = task.ctx.op == Op::EMB_TYPE ? 1 : task.ctx.rows;
  return ordinary_begin(rt, memory, model, task.ctx, task.dst, 0, 1024,
                        row, rows, elements, unit, Component::FULL_WIDTH,
                        255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const LayerNormTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  const uint8_t region = task.ctx.op == Op::LN_MARKER ?
                         uint8_t(Region::SCORER_ACT) : 0;
  return ordinary_begin(rt, memory, model, task.ctx, task.dst, region, 1024,
                        task.ctx.row0, task.ctx.rows, elements, unit,
                        Component::FULL_WIDTH, 255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const RopeTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  protected_task = true;
  if (unit != OutputUnit::F32 || !elements || task.head >= 16)
    return protocol(uint8_t(task.ctx.op));
  const uint8_t shard = task.head % 2;
  full::FullOwnerSpec owner;
  BufferRef old_ref;
  Check c = snapshot(rt, task.dst_qkv_ref[shard], 0, owner, old_ref);
  if (!c || old_ref != task.src_qkv_ref[shard]) return buffer(Buffer::QKV);
  request = Request{};
  request.action = Action::BEGIN;
  c = next_sequence(rt, request.event_seq);
  if (!c) return c;
  request.origin_seq = request.event_seq;
  request.context = task.ctx;
  common(request, rt, model);
  request.descriptor_count = 2;
  request.expected_unit = unit;
  request.expected_elements = elements;
  for (unsigned plane = 0; plane < 2 && c; ++plane) {
    c = descriptor(rt, memory, owner, old_ref, request.descriptor[plane]);
    Address first;
    if (c) c = qkv_address(uint8_t(plane), task.ctx.batch, task.head,
                           task.ctx.row0, 0, rt.inputs.identity.B,
                           rt.inputs.identity.S, first);
    if (!c) break;
    WriteGeometry& g = request.geometry[plane];
    g.first_offset = first.offset; g.segment_bytes = 64u * 4;
    g.row_count = task.ctx.rows; g.repeat_count = 1;
    g.row_step = task.ctx.rows == 1 ? 0 : 64u * 4;
    g.total_write_bytes = uint64_t(g.segment_bytes) * g.row_count;
    g.component = Component::QKV_PLANES;
    g.head = task.head; g.plane_mask = uint8_t(1u << plane);
  }
  return c ? wire_check(request) : c;
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const AVTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.dst, 0, 64,
                        task.ctx.row0, task.ctx.rows, elements, unit,
                        Component::ATT_HEAD, task.head, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const FPLinearTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.dst,
                        task.dst_region, task.N, task.ctx.row0,
                        task.ctx.rows, elements, unit, Component::FULL_WIDTH,
                        255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const VectorTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.dst,
                        task.dst_region, task.length, task.ctx.row0,
                        task.ctx.rows, elements, unit, Component::FULL_WIDTH,
                        255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const GatherTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.markers, 0, 1024,
                        0, 16, elements, unit, Component::FULL_WIDTH, 255,
                        request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const SoftmaxTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  if (task.ctx.op != Op::SOFTMAX_CAND) {
    protected_task = false;
    return ok();
  }
  return ordinary_begin(rt, memory, model, task.ctx, task.dst,
                        task.dst_region, task.length, 0, 1, elements, unit,
                        Component::FULL_WIDTH, 255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const StatsTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.stats,
                        task.stats_region, 4, 0, 1, elements, unit,
                        Component::FULL_WIDTH, 255, request, protected_task);
}

Check build_generated_begin(full::FullRuntime& rt, const full::FullMemory& memory,
                            const portal::ModelBinding& model,
                            const ConcatActTask& task, uint32_t elements,
                            OutputUnit unit, Request& request,
                            bool& protected_task) {
  return ordinary_begin(rt, memory, model, task.ctx, task.dst,
                        task.dst_region, 1028, 0, 1, elements, unit,
                        Component::FULL_WIDTH, 255, request, protected_task);
}

Check arm_generated_store_tracker(full::FullRuntime& rt,
                                  const Request& begin) {
  if (begin.action != Action::BEGIN || begin.descriptor_count < 1 ||
      begin.descriptor_count > 2 || rt.generated_store.active)
    return protocol(uint8_t(begin.context.op));
  rt.generated_store = full::FullRuntime::GeneratedStoreTracker{};
  rt.generated_store.descriptor_count = begin.descriptor_count;
  rt.generated_store.active = true;
  for (unsigned i = 0; i < begin.descriptor_count; ++i) {
    auto& out = rt.generated_store.geometry[i];
    const WriteGeometry& in = begin.geometry[i];
    out.role = begin.descriptor[i].role;
    out.first_offset = in.first_offset;
    out.segment_bytes = in.segment_bytes;
    out.row_count = in.row_count; out.repeat_count = in.repeat_count;
    out.row_step = in.row_step; out.repeat_step = in.repeat_step;
  }
  return ok();
}

Check build_generated_end(full::FullRuntime& rt, const Request& begin,
                          const TaskDone& done, Request& end) {
  if (begin.action != Action::BEGIN || !rt.generated_store.active ||
      done.task_id != begin.context.task_id || !done.drained)
    return protocol(uint8_t(begin.context.op));
  end = begin;
  end.action = Action::END;
  Check c = next_sequence(rt, end.event_seq);
  if (!c) return c;
  end.origin_seq = begin.event_seq;
  end.reported_status = done.status;
  end.reported_unit = done.status == Status::OK ? done.output_unit :
                      OutputUnit::NONE;
  end.reported_elements = done.status == Status::OK ? done.output_elements : 0;
  end.reported_error_detail = done.error_detail;
  end.reported_bad_element = done.bad_element;
  for (unsigned i = 0; i < begin.descriptor_count; ++i)
    end.issued_store_bytes[i] = rt.generated_store.issued_bytes[i];
  if (!rt.generated_store.first_error && done.status == Status::OK)
    return rt.generated_store.first_error;
  return wire_check(end);
}

void clear_generated_store_tracker(full::FullRuntime& rt) {
  rt.generated_store = full::FullRuntime::GeneratedStoreTracker{};
}

} // namespace laya::provenance
