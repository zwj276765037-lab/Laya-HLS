#include "laya_graph_program_sequencer.h"

namespace laya::program {
namespace {

Check protocol(uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, 0, reason)};
}

} // namespace

Check begin(State& state, const NumericIdentity& identity) {
  if (!numeric_identity_valid(identity) || state.action_active)
    return protocol(4);
  const uint64_t high_water = state.action_high_water;
  state = State{};
  state.action_high_water = high_water;
  state.identity = identity;
  state.request_active = true;
  return ok();
}

Check seed_slot(State& state, uint8_t slot,
                const full::FullOwnerSpec& owner, uint64_t version) {
  if (!state.request_active || state.action_active || slot >= kGraphSlots ||
      !version || owner.ref.id == Buffer::NONE ||
      !check_ref(owner.ref, owner.region))
    return protocol(9);
  state.slot[slot].owner = owner;
  state.slot[slot].version = version;
  state.slot[slot].valid = true;
  return ok();
}

Check prepare_norm(State& state, uint8_t source_slot, uint8_t target_slot,
                   Op op, uint8_t stage, uint8_t layer,
                   Buffer target_buffer, uint8_t target_bank,
                   uint8_t target_region, uint8_t gamma,
                   action::Request& request) {
  if (!state.request_active || state.action_active || state.cancel_pending ||
      source_slot >= kGraphSlots || target_slot >= kGraphSlots ||
      !state.slot[source_slot].valid || state.action_high_water == UINT64_MAX)
    return protocol(9);
  request = action::Request{};
  request.kind = action::Kind::NORM;
  request.pc = state.pc;
  request.op = op;
  request.stage = stage;
  request.layer = layer;
  request.ordinal = ++state.action_high_water;
  request.identity = state.identity;
  request.source.slot = source_slot;
  request.source.version = state.slot[source_slot].version;
  request.source.owner = state.slot[source_slot].owner;
  request.target_slot = target_slot;
  request.target_slot_version = state.slot[target_slot].valid ?
      state.slot[target_slot].version + 1 : 1;
  request.target_buffer = target_buffer;
  request.target_bank = target_bank;
  request.target_region = target_region;
  request.weight.layer = 255;
  request.gamma = gamma;
  Check valid = action::validate(request);
  if (!valid) return valid;
  state.pending = request;
  state.action_active = true;
  return ok();
}

Check accept_completion(State& state,
                        const action::Completion& completion) {
  if (!state.request_active || !state.action_active)
    return protocol(14);
  Check valid = action::validate(completion);
  if (!valid || !action::same_key(state.pending, completion) ||
      !(completion.flags & action::FRAME_COMPLETE) ||
      !(completion.flags & action::BINDING_OK))
    return protocol(14);
  if (!(completion.flags & action::SAFE_TERMINAL) ||
      !(completion.flags & action::REMOTE_DRAINED))
    return protocol(9);

  Check result = completion.result;
  if (result) {
    if (!(completion.flags & action::SLOT_UPDATE_VALID) ||
        !(completion.flags & action::TYPED_RETIRED) ||
        completion.slot_delta.slot != state.pending.target_slot ||
        completion.slot_delta.version !=
            state.pending.target_slot_version ||
        completion.slot_delta.owner.ref.id != state.pending.target_buffer ||
        completion.slot_delta.owner.ref.bank != state.pending.target_bank ||
        completion.slot_delta.owner.region != state.pending.target_region ||
        completion.slot_delta.owner.stage != state.pending.stage ||
        completion.slot_delta.owner.layer != state.pending.layer ||
        completion.slot_delta.owner.row_space !=
            state.pending.source.owner.row_space ||
        completion.slot_delta.owner.rows != state.pending.identity.S ||
        completion.slot_delta.owner.width != 1024 ||
        completion.slot_delta.owner.content != Content::F32)
      return protocol(14);
    Slot& target = state.slot[completion.slot_delta.slot];
    if (target.valid && completion.slot_delta.version != target.version + 1)
      return protocol(14);
    target.owner = completion.slot_delta.owner;
    target.version = completion.slot_delta.version;
    target.valid = true;
    ++state.pc;
  } else if (state.first_error) {
    state.first_error = result;
  }
  state.action_active = false;
  state.pending = action::Request{};
  return result;
}

void request_cancel(State& state) {
  state.cancel_pending = true;
}

} // namespace laya::program
