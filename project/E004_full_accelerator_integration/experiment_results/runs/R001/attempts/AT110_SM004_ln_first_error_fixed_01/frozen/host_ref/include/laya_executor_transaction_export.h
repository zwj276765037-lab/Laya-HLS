#pragma once

#include "laya_executor_stream.h"
#include "laya_executor_transaction_pending.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::transaction_pending {

// One transport snapshot of the actual executor's pending transaction. This
// owns no request, task, physical owner, permission, allocator or retirement.
// It references the actor's existing immutable A/K through their full key.
struct Exporter {
  Packet packet{};
  Key key;
  unsigned beat = 0;
  bool active = false, written = false, protocol_error = false;
};

// Call after the one actual actor/Port step, supplying that same Machine's
// phase/beat sampled immediately before it. A send changes a non-TX phase to
// TX_WRITE with beat zero; the actual sixteenth LTC pop changes TX_READ/15 to
// TX_VALIDATE/0. The helper never supplies a completion or a drained fact.
// It continues writing an already captured frame during persistent revoke.
// The source-side full LAP/LAX comparison uses the real complete LAP consumer
// retained in Transport; this FIRST executor source is physical route 1 only.
// No reference to an invocation-local object is retained.
void export_step(Exporter&, const executor::State&,
                 const executor_stream::Transport&,
                 lifecycle::Phase machine_phase_before,
                 unsigned machine_beat_before,
                 hls::stream<ap_uint<512>>& transaction_pending);

} // namespace laya::transaction_pending
#endif
