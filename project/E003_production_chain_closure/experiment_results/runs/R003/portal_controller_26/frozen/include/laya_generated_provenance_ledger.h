#pragma once

#include "laya_generated_provenance_events.h"

namespace laya::provenance {

constexpr unsigned kLedgerOwners = 32;

struct PhysicalObservation {
  Status status = Status::OK;
  uint32_t error_detail = 0;
  uint64_t bad_element = UINT64_MAX;
  uint64_t observed_store_bytes[2] = {};
  bool drained = true;
  bool coverage_complete = true;
};

struct LedgerOwner {
  NumericIdentity identity;
  OwnerDescriptor descriptor;
  uint32_t max_epoch = 0;
  bool occupied = false;
  bool active = false;
  bool published = false;
  bool invalid = false;
};

struct LedgerTypedWatermark {
  NumericIdentity identity;
  uint32_t last_task = 0;
  bool occupied = false;
};

struct LedgerState {
  LedgerOwner owner[kLedgerOwners];
  LedgerTypedWatermark typed[kLedgerOwners];
  Request active_begin;
  uint64_t last_event_seq = 0;
  uint8_t active_typed_slot = 0xff;
  bool scope_active = false;
};

// Transactional reference for the persistent physical ledger.  The caller
// supplies the final bus/fence observation for the event; a real RTL hub may
// wait before invoking the same state transition.  Fully decoded fresh events
// consume their sequence even when the semantic transition is rejected.
Check ledger_handle(LedgerState&, const Request&,
                    const PhysicalObservation&, Response&);

} // namespace laya::provenance
