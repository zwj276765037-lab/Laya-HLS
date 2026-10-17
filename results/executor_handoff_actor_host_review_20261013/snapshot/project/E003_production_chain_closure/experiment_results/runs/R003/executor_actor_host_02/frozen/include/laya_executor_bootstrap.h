#pragma once

#include "laya_bootstrap_snapshot.h"
#include "laya_task_lifecycle_port.h"
#include "laya_graph_program_protocol.h"

namespace laya::bootstrap {

struct BaseBinding {
  uint64_t epoch = 0, address = 0, capacity = 0;
};
// These acknowledgements come from the unique production shell's physical
// state, never from a Host field or LGP1 SOURCE_READY_PROOF bit.
struct AdmissionFence {
  bool physical_quiescent = false;
  bool request_result_consumed = false;
};
enum class Phase : uint8_t { IDLE, WAIT_SNAPSHOT, SOURCE_CONFIRMED };
struct State {
  Phase phase = Phase::IDLE;
  uint64_t sequence_high_water = 0;
  Request pending;
};

// New request only.  The old active action remains runnable when this rejects.
Check admit_new(State&, const lifecycle::Port&, full::FullRuntime&,
                const full::FullMemory&, const AdmissionFence&);
// Checkpoint within an already admitted request.  This does not begin/admit
// again or change any typed/protocol/Ref high water or retirement statistics.
Check prepare_snapshot(State&, const lifecycle::Port&, const full::FullRuntime&,
                       const full::FullMemory&, BufferRef source,
                       const BaseBinding&, Request&);
// Source protection must cover every physical mutation path and remain held
// until safe action completion consumption; a readonly snapshot alone cannot
// authorize reads.  The production shell owns this guard and its live base.
Check accept_snapshot(State&, const lifecycle::Port&, full::FullRuntime&,
                      const Response&, const BaseBinding& live_base,
                      bool source_protection_held, bool cancel,
                      program_wire::Command&);

} // namespace laya::bootstrap
