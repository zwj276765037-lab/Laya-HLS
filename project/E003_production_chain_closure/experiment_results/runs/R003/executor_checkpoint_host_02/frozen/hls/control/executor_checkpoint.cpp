#include "laya_executor_checkpoint.h"

namespace laya::checkpoint {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
bool idle(const lifecycle::Port& p, const full::FullRuntime& rt) {
  if (p.phase != lifecycle::PortPhase::READ_ACTION || p.beat ||
      p.machine.phase != lifecycle::Phase::IDLE || rt.lifecycle_action.active ||
      rt.generated_store.active || rt.generated_store.source_lease_active ||
      rt.lifecycle_action.source_release_pending || rt.defer_task_retirement ||
      !rt.last_execution_error || !rt.last_cleanup_error)
    return false;
  for (const auto& o : rt.owners.record)
    if (o.readers || (o.state != CacheState::INVALID && o.state != CacheState::READY))
      return false;
  return true;
}
bool safe(const Fence& f) {
  return f.physical_quiescent && f.predecessor_dispatch_held &&
      f.source_held && f.target_held && !f.cancel && f.handoff_epoch;
}
bool base_matches(const Fence& f, const Request& r) {
  return f.handoff_epoch == r.handoff_epoch && f.base.epoch == r.source.base_epoch &&
      f.base.address == r.source.base_address && f.base.capacity == r.source.base_capacity;
}
bool matches(const full::FullOwnerRecord& o, const Request& r) {
  const auto& d = r.source.source;
  if (!o.valid || o.state != CacheState::READY || o.readers ||
      !numeric_identity_equal(o.identity, r.source.identity) ||
      o.ref != d.target_ref || o.region != d.target_region ||
      o.stage != d.stage || o.layer != d.layer || o.batch != d.batch ||
      o.row_space != d.row_space || o.row0 != d.row0 || o.rows != d.rows ||
      o.width != d.width || o.content != d.content) return false;
  for (unsigned b = 0; b < r.source.identity.B; ++b)
    for (unsigned row = 0; row < d.rows; ++row) {
      const unsigned bit = b * 1024 + row;
      if (!((o.covered_rows[bit / 32] >> (bit % 32)) & 1u)) return false;
    }
  return true;
}
// Preflight source cache and every local owner mapping before any mutation.
Check owner_plan(const full::FullRuntime& rt, const Response& proof,
                 unsigned& source_slot, unsigned& target_slot, bool& existing,
                 uint32_t& source_floor, uint32_t& target_floor) {
  const auto& r = proof.binding;
  unsigned empty[2] = {32,32}; source_slot = target_slot = 32; existing = false;
  source_floor = proof.source_epoch_floor; target_floor = proof.target_epoch_floor;
  Span source_span, target_span;
  if (!span(r.source.source.target_ref, 0, source_span) ||
      !span({r.target.buffer, r.target.bank, 1}, r.target.region, target_span) ||
      source_span.bo != r.source.source.role || target_span.bo != r.target.role ||
      target_span.base != r.target.offset || r.target.extent > target_span.bytes)
    return protocol();
  for (unsigned i = 0; i < 32; ++i) {
    const auto& o = rt.owners.record[i];
    if (o.ref.id == Buffer::NONE) {
      if (empty[0] == 32) empty[0] = i;
      else if (empty[1] == 32) empty[1] = i;
      continue;
    }
    Span mapped;
    // The diagnostic refuses local domains whose physical mapping is unknown.
    if (!span({o.ref.id, o.ref.bank, 1}, o.region, mapped)) return protocol();
    const bool source = mapped.bo == source_span.bo &&
        uint64_t(mapped.base) < uint64_t(source_span.base) + source_span.bytes &&
        uint64_t(source_span.base) < uint64_t(mapped.base) + mapped.bytes;
    const bool target = mapped.bo == target_span.bo &&
        uint64_t(mapped.base) < uint64_t(target_span.base) + target_span.bytes &&
        uint64_t(target_span.base) < uint64_t(mapped.base) + mapped.bytes;
    if (source) {
      if (o.ref.id != r.source.source.target_ref.id ||
          o.ref.bank != r.source.source.target_ref.bank || o.region ||
          source_slot != 32) return protocol();
      source_slot = i;
      if (source_floor < o.max_claimed_epoch) source_floor = o.max_claimed_epoch;
      if (o.valid || o.state != CacheState::INVALID) {
        if (!matches(o, r)) return protocol();
        existing = true;
      } else if (o.max_claimed_epoch >= r.source.source.target_ref.epoch)
        return protocol(); // Do not resurrect a locally invalidated epoch.
    }
    if (target) {
      if (o.ref.id != r.target.buffer || o.ref.bank != r.target.bank ||
          o.region != r.target.region || o.valid || o.state != CacheState::INVALID ||
          o.readers || target_slot != 32) return protocol();
      target_slot = i;
      if (target_floor < o.max_claimed_epoch) target_floor = o.max_claimed_epoch;
    }
  }
  if (source_slot == 32) source_slot = empty[0];
  if (target_slot == 32)
    target_slot = source_slot == empty[0] ? empty[1] : empty[0];
  return source_slot == 32 || target_slot == 32 ? protocol() : ok();
}
void commit_source(full::FullRuntime& rt, const Request& r, unsigned slot,
                   uint32_t source_floor) {
  const auto& d = r.source.source;
  auto& o = rt.owners.record[slot];
  o = full::FullOwnerRecord{};
  o.identity = r.source.identity; o.ref = d.target_ref;
  o.max_claimed_epoch = source_floor; o.region = d.target_region;
  o.stage = d.stage; o.layer = d.layer; o.batch = d.batch;
  o.row_space = d.row_space; o.row0 = d.row0; o.rows = d.rows;
  o.width = d.width; o.content = d.content; o.valid = true; o.state = CacheState::READY;
  for (unsigned b = 0; b < r.source.identity.B; ++b)
    for (unsigned row = 0; row < d.rows; ++row) {
      const unsigned bit = b * 1024 + row;
      o.covered_rows[bit / 32] |= uint32_t(1) << (bit % 32);
    }
}
} // namespace

Check prepare(State& state, const lifecycle::Port& port,
              const full::FullRuntime& rt, const full::FullMemory& memory,
              BufferRef source, const Fence& fence, Request& out) {
  if (state.phase != bootstrap::Phase::IDLE || !idle(port, rt) || !safe(fence) ||
      !rt.request_valid || !rt.model_header_valid || rt.checkpoint_baseline.valid ||
      state.sequence_high_water == UINT64_MAX ||
      fence.handoff_epoch <= state.handoff_high_water ||
      full::full_bo_capacity(memory, Bo::STATE0) != fence.base.capacity)
    return protocol();
  // Reuse the v1 immutable source builder on a small temporary state only.
  bootstrap::State builder;
  builder.sequence_high_water = state.sequence_high_water;
  Request next;
  Check c = bootstrap::prepare_snapshot(builder, port, rt, memory, source,
                                        fence.base, next.source);
  if (!c) return c;
  next.handoff_epoch = fence.handoff_epoch;
  next.target = {Buffer::NORM, 0, 0, Bo::STATE0, fence.base.epoch,
      fence.base.address, fence.base.capacity, 8ull * 1024 * 1024,
      next.source.source.owner_extent_span, 4096, 4194304};
  if (!validate(next)) return protocol();
  state.pending = next;
  state.sequence_high_water = next.source.sequence;
  state.phase = bootstrap::Phase::WAIT_SNAPSHOT;
  out = next; return ok();
}

Check accept(State& state, const lifecycle::Port& port, full::FullRuntime& rt,
             const Response& proof, const Fence& fence, program_wire::Command& out) {
  if (state.phase != bootstrap::Phase::WAIT_SNAPSHOT || !idle(port, rt) ||
      !safe(fence) || !base_matches(fence, state.pending) ||
      !rt.request_valid || !rt.model_header_valid || rt.checkpoint_baseline.valid ||
      !proof.result || !validate(proof) || !same_binding(state.pending, proof.binding) ||
      !numeric_identity_equal(rt.inputs.identity, proof.binding.source.identity) ||
      proof.task_floor < rt.last_task_id ||
      rt.dispatch_reservations.task_high_water(rt.last_task_id) != rt.last_task_id)
    return protocol();
  const unsigned windows = unsigned(rt.inputs.identity.B) *
      ((unsigned(rt.inputs.identity.S) + 15) / 16);
  if (rt.producer_request_high_water > UINT64_MAX - windows ||
      rt.provenance_event_high_water > UINT64_MAX - (2 * windows + 3) ||
      proof.lpv_floor > UINT64_MAX - (2 * windows + 3) ||
      port.machine.action_high_water == UINT64_MAX ||
      !rt.portal_reservations.can(1) || rt.dispatch_command_generation == UINT64_MAX)
    return protocol();
  unsigned source_slot, target_slot; bool existing;
  uint32_t source_floor, target_floor;
  if (!owner_plan(rt, proof, source_slot, target_slot, existing, source_floor, target_floor))
    return protocol();
  // This small copy is only an allocator capacity/overflow probe, not a
  // second runtime or READY authority. No reservation is externally issued.
  full::TaskReservation allocator = rt.dispatch_reservations;
  target_floor = allocator.ref_high_water(Buffer::NORM, 0, 0, target_floor);
  if (!allocator.raise_task_floor(proof.task_floor) ||
      !allocator.raise_ref_floor(Buffer::HIDDEN, 0, 0, source_floor) ||
      !allocator.raise_ref_floor(Buffer::NORM, 0, 0, target_floor) ||
      !allocator.can_tasks(proof.task_floor, windows) ||
      !allocator.can_refs(Buffer::NORM, 0, 0, target_floor, 1))
    return protocol();
  program_wire::Command command;
  command.identity = rt.inputs.identity;
  command.flags = program_wire::SOURCE_READY_PROOF;
  const auto& d = proof.binding.source.source;
  command.source = {0, d.target_ref.epoch,
      {d.target_ref, d.target_region, d.stage, d.layer, d.batch, d.row_space,
       d.row0, d.rows, d.width, d.content}};
  if (!program_wire::validate(command)) return protocol();
  // All possible rejection points are above. This single commit neither
  // calls retirement nor creates a target owner/READY record.
  if (!existing) commit_source(rt, proof.binding, source_slot, source_floor);
  // CLAIM compares epochs against the local owner history as well as the
  // dispatch cursor. Cache the complete domain floor with no READY content.
  auto& target_history = rt.owners.record[target_slot];
  target_history = full::FullOwnerRecord{};
  target_history.ref = {Buffer::NORM, 0, target_floor};
  target_history.max_claimed_epoch = target_floor;
  target_history.state = CacheState::INVALID;
  rt.dispatch_reservations = allocator;
  rt.last_task_id = proof.task_floor;
  if (rt.provenance_event_high_water < proof.lpv_floor)
    rt.provenance_event_high_water = proof.lpv_floor;
  auto& baseline = rt.checkpoint_baseline;
  baseline.identity = rt.inputs.identity;
  baseline.snapshot_sequence = proof.binding.source.sequence;
  baseline.handoff_epoch = proof.binding.handoff_epoch;
  baseline.base_epoch = fence.base.epoch; baseline.base_address = fence.base.address;
  baseline.base_capacity = fence.base.capacity;
  baseline.task_base = proof.task_floor; baseline.local_retired_at_import = rt.tasks_retired;
  baseline.valid = true;
  state.handoff_high_water = proof.binding.handoff_epoch;
  state.phase = bootstrap::Phase::SOURCE_CONFIRMED;
  out = command;
  return ok();
}
} // namespace laya::checkpoint
