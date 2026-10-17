#pragma once

#include "laya_graph_action_protocol.h"

namespace laya::program {

constexpr unsigned kGraphSlots = 22;

struct Slot {
  full::FullOwnerSpec owner;
  uint64_t version = 0;
  bool valid = false;
};

struct State {
  NumericIdentity identity;
  Slot slot[kGraphSlots] = {};
  action::Request pending;
  uint64_t action_high_water = 0;
  uint8_t pc = 0;
  bool request_active = false;
  bool action_active = false;
  bool cancel_pending = false;
  Check first_error = ok();
};

Check begin(State&, const NumericIdentity&);
Check seed_slot(State&, uint8_t slot, const full::FullOwnerSpec&,
                uint64_t version);
Check prepare_norm(State&, uint8_t source_slot, uint8_t target_slot,
                   Op op, uint8_t stage, uint8_t layer,
                   Buffer target_buffer, uint8_t target_bank,
                   uint8_t target_region, uint8_t gamma,
                   action::Request&);
Check accept_completion(State&, const action::Completion&);
void request_cancel(State&);

} // namespace laya::program
