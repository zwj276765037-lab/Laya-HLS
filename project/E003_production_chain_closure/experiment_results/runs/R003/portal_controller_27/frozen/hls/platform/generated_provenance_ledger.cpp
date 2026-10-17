#include "laya_generated_provenance_ledger.h"

namespace laya::provenance {
namespace {

Check protocol(uint16_t reason = 23) {
  return {Status::E_PROTOCOL, detail(4, 0, reason)};
}
Check buffer(Buffer id, uint16_t reason = 8) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), reason)};
}

bool same_identity(const NumericIdentity& a, const NumericIdentity& b) {
  return numeric_identity_equal(a, b);
}

bool same_physical(const OwnerDescriptor& a, const OwnerDescriptor& b) {
  return a.target_ref.id == b.target_ref.id &&
         a.target_ref.bank == b.target_ref.bank &&
         a.target_region == b.target_region && a.role == b.role &&
         a.owner_base_offset == b.owner_base_offset &&
         a.bo_span == b.bo_span;
}

bool same_owner_shape(const OwnerDescriptor& a, const OwnerDescriptor& b) {
  return a.target_region == b.target_region && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 &&
         a.rows == b.rows && a.width == b.width &&
         a.content == b.content && a.layout == b.layout &&
         a.bo_span == b.bo_span &&
         a.owner_base_offset == b.owner_base_offset &&
         a.row_stride == b.row_stride &&
         a.batch_stride == b.batch_stride &&
         a.owner_extent_span == b.owner_extent_span &&
         a.head_stride == b.head_stride &&
         a.plane_stride == b.plane_stride;
}

bool owner_event_descriptors_ok(const Request& request) {
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    const OwnerDescriptor& d = request.descriptor[i];
    if ((d.old_ref.id == Buffer::NONE && d.old_region) ||
        (d.target_ref.id != Buffer::QKV && d.target_ref.bank)) return false;
  }
  if (request.descriptor_count == 1)
    return request.descriptor[0].target_ref.id != Buffer::QKV;
  const OwnerDescriptor& first = request.descriptor[0];
  const OwnerDescriptor& second = request.descriptor[1];
  const bool no_old = first.old_ref.id == Buffer::NONE &&
                      second.old_ref.id == Buffer::NONE;
  const bool old_pair = first.old_ref.id == Buffer::QKV &&
                        second.old_ref.id == Buffer::QKV &&
                        first.old_ref.bank == 0 && second.old_ref.bank == 1 &&
                        first.old_ref.epoch == second.old_ref.epoch &&
                        first.old_region == 0 && second.old_region == 0;
  return first.target_ref.id == Buffer::QKV &&
         second.target_ref.id == Buffer::QKV &&
         first.target_ref.bank == 0 && second.target_ref.bank == 1 &&
         first.target_ref.epoch == second.target_ref.epoch &&
         first.target_region == 0 && second.target_region == 0 &&
         first.layout == 1 && second.layout == 1 &&
         first.role == Bo::QKV0 && second.role == Bo::QKV1 &&
         same_owner_shape(first, second) && (no_old || old_pair);
}

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

bool same_begin_binding(const Request& end, const Request& begin) {
  if (end.origin_seq != begin.event_seq ||
      !same_identity(end.identity, begin.identity) ||
      !same_context(end.context, begin.context) ||
      end.descriptor_count != begin.descriptor_count ||
      end.expected_unit != begin.expected_unit ||
      end.expected_elements != begin.expected_elements ||
      end.model_identity != begin.model_identity)
    return false;
  for (unsigned i = 0; i < begin.descriptor_count; ++i)
    if (!same_descriptor(end.descriptor[i], begin.descriptor[i]) ||
        !same_geometry(end.geometry[i], begin.geometry[i])) return false;
  return true;
}

bool range_end(uint64_t first, uint32_t bytes, uint64_t& end) {
  end = first + bytes;
  return bytes && end >= first;
}

bool geometry_within(const OwnerDescriptor& d, const WriteGeometry& g) {
  const uint64_t owner_end = d.owner_base_offset + d.owner_extent_span;
  if (owner_end < d.owner_base_offset || owner_end > d.bo_span) return false;
  for (uint16_t repeat = 0; repeat < g.repeat_count; ++repeat)
    for (uint16_t row = 0; row < g.row_count; ++row) {
      const uint64_t repeat_offset = uint64_t(repeat) * g.repeat_step;
      const uint64_t row_offset = uint64_t(row) * g.row_step;
      if ((repeat && repeat_offset / repeat != g.repeat_step) ||
          (row && row_offset / row != g.row_step)) return false;
      const uint64_t first = g.first_offset + repeat_offset + row_offset;
      if (first < g.first_offset) return false;
      uint64_t end = 0;
      if (!range_end(first, g.segment_bytes, end) ||
          first < d.owner_base_offset || end > owner_end) return false;
    }
  return true;
}

bool geometries_disjoint(const Request& request) {
  constexpr uint64_t kMaximumTaskWriteBytes = 16ull * 5248 * 4;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    const WriteGeometry& g = request.geometry[i];
    const uint64_t segments = uint64_t(g.row_count) * g.repeat_count;
    if (!segments || segments > 32 ||
        g.total_write_bytes > kMaximumTaskWriteBytes) return false;
  }
  for (unsigned a = 0; a < request.descriptor_count; ++a) {
    if (!geometry_within(request.descriptor[a], request.geometry[a]))
      return false;
    for (unsigned b = a; b < request.descriptor_count; ++b) {
      if (request.descriptor[a].role != request.descriptor[b].role) continue;
      const WriteGeometry& ga = request.geometry[a];
      const WriteGeometry& gb = request.geometry[b];
      for (uint16_t ar = 0; ar < ga.repeat_count; ++ar)
        for (uint16_t ai = 0; ai < ga.row_count; ++ai) {
          const uint64_t af = ga.first_offset + uint64_t(ar) * ga.repeat_step +
                              uint64_t(ai) * ga.row_step;
          uint64_t ae = 0;
          if (!range_end(af, ga.segment_bytes, ae)) return false;
          for (uint16_t br = 0; br < gb.repeat_count; ++br)
            for (uint16_t bi = 0; bi < gb.row_count; ++bi) {
              if (a == b && ar == br && ai == bi) continue;
              const uint64_t bf = gb.first_offset +
                  uint64_t(br) * gb.repeat_step + uint64_t(bi) * gb.row_step;
              uint64_t be = 0;
              if (!range_end(bf, gb.segment_bytes, be) ||
                  (af < be && bf < ae)) return false;
            }
        }
    }
  }
  return true;
}

int find_exact(const LedgerState& state, const NumericIdentity& identity,
               const OwnerDescriptor& descriptor) {
  for (unsigned i = 0; i < kLedgerOwners; ++i) {
    const LedgerOwner& owner = state.owner[i];
    if (owner.occupied && owner.active &&
        same_identity(owner.identity, identity) &&
        same_descriptor(owner.descriptor, descriptor)) return int(i);
  }
  return -1;
}

int find_physical(const LedgerState& state, const OwnerDescriptor& descriptor) {
  for (unsigned i = 0; i < kLedgerOwners; ++i)
    if (state.owner[i].occupied &&
        same_physical(state.owner[i].descriptor, descriptor)) return int(i);
  return -1;
}

int find_empty(const LedgerState& state, int excluded = -1) {
  for (unsigned i = 0; i < kLedgerOwners; ++i)
    if (int(i) != excluded && !state.owner[i].occupied) return int(i);
  return -1;
}

int find_typed(const LedgerState& state, const NumericIdentity& identity) {
  for (unsigned i = 0; i < kLedgerOwners; ++i)
    if (state.typed[i].occupied &&
        same_identity(state.typed[i].identity, identity)) return int(i);
  return -1;
}

int find_empty_typed(const LedgerState& state) {
  for (unsigned i = 0; i < kLedgerOwners; ++i)
    if (!state.typed[i].occupied) return int(i);
  return -1;
}

void response_base(const Request& request, Response& response) {
  response = Response{};
  response.action = request.action;
  response.event_seq = request.event_seq;
  response.origin_seq = request.origin_seq;
  response.drained = true;
  response.descriptor_count = request.descriptor_count;
  response.identity = request.identity;
  response.context = request.context;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    response.target_ref[i] = request.descriptor[i].target_ref;
    response.target_region[i] = request.descriptor[i].target_region;
    response.old_ref[i] = request.descriptor[i].old_ref;
    response.old_region[i] = request.descriptor[i].old_region;
  }
}

Check fail(const Request& request, Response& response, Check result,
           bool scope_active = false) {
  response_base(request, response);
  response.status = result.code;
  response.error_detail = result.detail;
  response.bad_element = result.bad_element;
  response.scope_active = scope_active;
  return result;
}

Check check_model(const Request& request) {
  portal::ModelBinding canonical;
  Check c = portal::build_l13m_model_binding(canonical);
  if (!c) return c;
  canonical.identity = request.model_identity;
  return portal::validate_l13m_model_binding(request.identity, canonical);
}

Check claim(LedgerState& state, const Request& request, Response& response) {
  if (!owner_event_descriptors_ok(request))
    return fail(request, response, protocol());
  int slots[2] = {-1, -1};
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    const OwnerDescriptor& d = request.descriptor[i];
    int slot = find_physical(state, d);
    if (d.old_ref.id != Buffer::NONE) {
      if (slot < 0) return fail(request, response, buffer(d.target_ref.id));
      const LedgerOwner& old = state.owner[slot];
      if (!old.active || !old.published || old.invalid ||
          !same_identity(old.identity, request.identity) ||
          old.descriptor.target_ref != d.old_ref ||
          old.descriptor.target_region != d.old_region ||
          d.target_ref.epoch != d.old_ref.epoch + 1)
        return fail(request, response, buffer(d.target_ref.id));
    } else if (slot >= 0) {
      const LedgerOwner& prior = state.owner[slot];
      if (prior.active || d.target_ref.epoch <= prior.max_epoch)
        return fail(request, response, buffer(d.target_ref.id));
    } else {
      slot = find_empty(state, i ? slots[0] : -1);
      if (slot < 0) return fail(request, response, buffer(d.target_ref.id));
    }
    if (i && slot == slots[0])
      return fail(request, response, buffer(d.target_ref.id));
    slots[i] = slot;
  }
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    LedgerOwner& owner = state.owner[slots[i]];
    const uint32_t previous = owner.max_epoch;
    owner.identity = request.identity;
    owner.descriptor = request.descriptor[i];
    owner.max_epoch = request.descriptor[i].target_ref.epoch > previous ?
                      request.descriptor[i].target_ref.epoch : previous;
    owner.occupied = true; owner.active = true;
    owner.published = false; owner.invalid = false;
  }
  response_base(request, response);
  response.status = Status::OK;
  return ok();
}

Check owner_transition(LedgerState& state, const Request& request,
                       const PhysicalObservation& physical,
                       Response& response) {
  if (!owner_event_descriptors_ok(request))
    return fail(request, response, protocol());
  int slots[2] = {-1, -1};
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    slots[i] = find_exact(state, request.identity, request.descriptor[i]);
    if (slots[i] < 0 || (i && slots[i] == slots[0]))
      return fail(request, response,
                  buffer(request.descriptor[i].target_ref.id));
  }
  if (!physical.drained)
    return fail(request, response, protocol(), state.scope_active);
  if (physical.status != Status::OK)
    return fail(request, response,
                {physical.status, physical.error_detail,
                 physical.bad_element}, state.scope_active);
  if (request.action == Action::PUBLISH && !physical.coverage_complete)
    return fail(request, response,
                buffer(request.descriptor[0].target_ref.id));
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    const LedgerOwner& owner = state.owner[slots[i]];
    if ((request.action == Action::PUBLISH &&
         (owner.published || owner.invalid)) ||
        (request.action == Action::RELEASE &&
         (!owner.published || owner.invalid)))
      return fail(request, response, buffer(owner.descriptor.target_ref.id));
  }
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    LedgerOwner& owner = state.owner[slots[i]];
    if (request.action == Action::PUBLISH) owner.published = true;
    else if (request.action == Action::RELEASE) {
      if (!owner.published || owner.invalid)
        return fail(request, response, buffer(owner.descriptor.target_ref.id));
      owner.active = false; owner.published = false;
    } else {
      owner.active = false; owner.published = false; owner.invalid = true;
    }
  }
  response_base(request, response);
  response.status = Status::OK;
  response.owner_published = request.action == Action::PUBLISH;
  return ok();
}

Check begin(LedgerState& state, const Request& request, Response& response) {
  int typed_slot = find_typed(state, request.identity);
  if (typed_slot < 0) typed_slot = find_empty_typed(state);
  if (state.scope_active || typed_slot < 0 ||
      (state.typed[typed_slot].occupied &&
       request.context.task_id <= state.typed[typed_slot].last_task) ||
      !geometries_disjoint(request))
    return fail(request, response, protocol(), state.scope_active);
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    const int slot = find_exact(state, request.identity, request.descriptor[i]);
    if (slot < 0 || state.owner[slot].invalid ||
        state.owner[slot].published)
      return fail(request, response,
                  buffer(request.descriptor[i].target_ref.id));
  }
  if (!state.typed[typed_slot].occupied) {
    state.typed[typed_slot].identity = request.identity;
    state.typed[typed_slot].last_task = 0;
    state.typed[typed_slot].occupied = true;
  }
  state.active_begin = request;
  state.active_typed_slot = uint8_t(typed_slot);
  state.scope_active = true;
  response_base(request, response);
  response.status = Status::OK;
  response.scope_active = true;
  return ok();
}

Check end(LedgerState& state, const Request& request,
          const PhysicalObservation& physical, Response& response) {
  if (!state.scope_active ||
      !same_begin_binding(request, state.active_begin))
    return fail(request, response, protocol(), state.scope_active);
  if (!physical.drained)
    return fail(request, response, protocol(), true);
  for (unsigned i = 0; i < request.descriptor_count; ++i)
    if (physical.observed_store_bytes[i] != request.issued_store_bytes[i])
      return fail(request, response, protocol(), true);
  for (unsigned i = request.descriptor_count; i < 2; ++i)
    if (physical.observed_store_bytes[i])
      return fail(request, response, protocol(), true);
  Check result{physical.status, physical.error_detail, physical.bad_element};
  if (result && request.reported_status != Status::OK)
    result = {request.reported_status, request.reported_error_detail,
              request.reported_bad_element};
  if (result && !physical.coverage_complete)
    result = buffer(request.descriptor[0].target_ref.id);
  for (unsigned i = 0; i < request.descriptor_count; ++i)
    if (result && request.issued_store_bytes[i] !=
                  request.geometry[i].total_write_bytes) result = protocol();
  response_base(request, response);
  response.status = result.code;
  response.error_detail = result.detail;
  response.bad_element = result.bad_element;
  for (unsigned i = 0; i < request.descriptor_count; ++i)
    response.observed_store_bytes[i] = physical.observed_store_bytes[i];
  if (result) {
    response.output_elements = request.expected_elements;
    response.unit = request.expected_unit;
  }
  if (!result)
    for (unsigned i = 0; i < request.descriptor_count; ++i) {
      const int slot = find_exact(state, request.identity,
                                  request.descriptor[i]);
      if (slot >= 0) {
        state.owner[slot].invalid = true;
        state.owner[slot].published = false;
      }
    }
  state.typed[state.active_typed_slot].last_task = request.context.task_id;
  state.active_begin = Request{};
  state.active_typed_slot = 0xff;
  state.scope_active = false;
  return result;
}

} // namespace

Check ledger_handle(LedgerState& state, const Request& request,
                    const PhysicalObservation& physical,
                    Response& response) {
  Request decoded;
  Check checked = decode(encode(request), decoded);
  if (!checked) return fail(request, response, checked, state.scope_active);
  if (request.event_seq <= state.last_event_seq)
    return fail(request, response, protocol(), state.scope_active);
  state.last_event_seq = request.event_seq;
  checked = check_model(request);
  if (!checked) return fail(request, response, checked, state.scope_active);
  switch (request.action) {
    case Action::CLAIM:
      if (state.scope_active)
        return fail(request, response, protocol(), true);
      return claim(state, request, response);
    case Action::BEGIN: return begin(state, request, response);
    case Action::END: return end(state, request, physical, response);
    case Action::PUBLISH:
    case Action::RELEASE:
    case Action::INVALIDATE:
      if (state.scope_active)
        return fail(request, response, protocol(), true);
      return owner_transition(state, request, physical, response);
  }
  return fail(request, response, protocol(), state.scope_active);
}

} // namespace laya::provenance
