#include "laya_executor_bootstrap.h"

namespace laya::bootstrap {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
bool locally_idle(const lifecycle::Port& p, const full::FullRuntime& rt) {
  if (p.phase != lifecycle::PortPhase::READ_ACTION || p.beat ||
      p.machine.phase != lifecycle::Phase::IDLE || rt.lifecycle_action.active ||
      rt.generated_store.active || rt.generated_store.source_lease_active ||
      rt.lifecycle_action.source_release_pending || rt.defer_task_retirement)
    return false;
  for (const auto& r : rt.owners.record)
    if (r.readers || r.state == CacheState::FILL || r.state == CacheState::READ ||
        r.state == CacheState::EXCLUSIVE_RW || r.state == CacheState::DRAIN)
      return false;
  return true;
}
bool same_base(const BaseBinding& base, const Request& r) {
  return base.epoch == r.base_epoch && base.address == r.base_address &&
         base.capacity == r.base_capacity;
}
Check mirror(full::FullRuntime& rt, const Request& r) {
  const auto& d = r.source;
  unsigned empty = 32, same = 32;
  for (unsigned i = 0; i < 32; ++i) {
    const auto& owner = rt.owners.record[i];
    if (owner.ref.id == Buffer::NONE && empty == 32) empty = i;
    if (owner.ref.id == d.target_ref.id && owner.ref.bank == d.target_ref.bank &&
        owner.region == d.target_region) {
      same = i;
      if (owner.valid || owner.state != CacheState::INVALID || owner.readers) {
        if (!owner.valid || owner.state != CacheState::READY || owner.readers ||
            !numeric_identity_equal(owner.identity, r.identity) ||
            owner.ref != d.target_ref || owner.stage != d.stage ||
            owner.layer != d.layer || owner.batch != d.batch ||
            owner.row_space != d.row_space || owner.row0 != d.row0 ||
            owner.rows != d.rows || owner.width != d.width || owner.content != d.content)
          return protocol();
        return ok();
      }
      // A snapshot cannot resurrect an epoch explicitly invalidated locally.
      if (d.target_ref.epoch <= owner.max_claimed_epoch) return protocol();
      break;
    }
  }
  const unsigned slot = same == 32 ? empty : same;
  if (slot == 32) return protocol();
  // Read-only logical cache of the one hub's fully bound published snapshot.
  // No physical CLAIM, cover or PUBLISH and no task/statistic increment occurs.
  auto& owner = rt.owners.record[slot];
  owner = full::FullOwnerRecord{};
  owner.identity = r.identity; owner.ref = d.target_ref;
  owner.max_claimed_epoch = d.target_ref.epoch; owner.region = d.target_region;
  owner.stage = d.stage; owner.layer = d.layer; owner.batch = d.batch;
  owner.row_space = d.row_space; owner.row0 = d.row0; owner.rows = d.rows;
  owner.width = d.width; owner.content = d.content;
  owner.valid = true; owner.state = CacheState::READY;
  for (unsigned batch = 0; batch < r.identity.B; ++batch)
    for (unsigned row = 0; row < d.rows; ++row) {
      const unsigned index = batch * 1024 + row;
      owner.covered_rows[index / 32] |= uint32_t(1) << (index % 32);
    }
  return ok();
}
} // namespace

Check admit_new(State& state, const lifecycle::Port& port, full::FullRuntime& rt,
                const full::FullMemory& memory, const AdmissionFence& fence) {
  if (state.phase == Phase::WAIT_SNAPSHOT || !locally_idle(port, rt) ||
      !fence.physical_quiescent || !fence.request_result_consumed)
    return protocol();
  // Do not clear old action bindings or task reservations until both the
  // logical domain and the shell's real physical/result fence permit this.
  full::full_begin_request(rt);
  full::FullInputs candidate;
  uint32_t frame_bytes = 0;
  Check result = full::full_decode_validate_request(rt, memory, candidate, frame_bytes);
  if (!result) return result;
  result = full::full_admit_request(rt, candidate);
  if (!result) return result;
  state.phase = Phase::IDLE;
  state.pending = Request{};
  return ok();
}

Check prepare_snapshot(State& state, const lifecycle::Port& port,
                       const full::FullRuntime& rt, const full::FullMemory& memory,
                       BufferRef source, const BaseBinding& base, Request& out) {
  if (state.phase != Phase::IDLE || !locally_idle(port, rt) || !rt.request_valid ||
      !rt.model_header_valid || state.sequence_high_water == UINT64_MAX)
    return protocol();
  Request next;
  next.sequence = state.sequence_high_water + 1;
  next.identity = rt.inputs.identity; next.base_epoch = base.epoch;
  next.base_address = base.address; next.base_capacity = base.capacity;
  portal::ModelBinding model;
  Check result = portal::build_l13m_model_binding(model);
  if (!result) return result;
  next.model_identity = model.identity;
  auto& d = next.source;
  d.target_ref = source; d.stage = 2; d.layer = 0; d.batch = 255;
  d.row_space = RowSpace::TOKEN; d.rows = next.identity.S;
  d.width = 1024; d.content = Content::F32; d.role = Bo::STATE0;
  d.bo_span = full::full_bo_capacity(memory, d.role);
  d.row_stride = 4096; d.batch_stride = 4194304;
  d.owner_extent_span = uint64_t(next.identity.B - 1) * d.batch_stride +
                        uint64_t(next.identity.S) * d.row_stride;
  result = validate(next);
  if (!result) return result;
  state.sequence_high_water = next.sequence;
  state.pending = next; state.phase = Phase::WAIT_SNAPSHOT;
  out = next;
  return ok();
}

Check accept_snapshot(State& state, const lifecycle::Port& port,
                      full::FullRuntime& rt, const Response& response,
                      const BaseBinding& live_base, bool guard, bool cancel,
                      program_wire::Command& out) {
  if (state.phase != Phase::WAIT_SNAPSHOT || !locally_idle(port, rt) ||
      !rt.request_valid || !rt.model_header_valid || cancel || !guard ||
      !same_base(live_base, state.pending) || !response.result ||
      response.flags != kSuccessFlags || !validate(response.binding) ||
      !same_binding(response.binding, state.pending) ||
      !numeric_identity_equal(rt.inputs.identity, response.binding.identity))
    return protocol();
  Check result = mirror(rt, response.binding);
  if (!result) return result;
  program_wire::Command command;
  command.identity = rt.inputs.identity;
  command.flags = program_wire::SOURCE_READY_PROOF;
  const auto& d = response.binding.source;
  command.source = {0, d.target_ref.epoch,
      {d.target_ref, d.target_region, d.stage, d.layer, d.batch, d.row_space,
       d.row0, d.rows, d.width, d.content}};
  state.phase = Phase::SOURCE_CONFIRMED;
  out = command;
  return ok();
}
} // namespace laya::bootstrap
