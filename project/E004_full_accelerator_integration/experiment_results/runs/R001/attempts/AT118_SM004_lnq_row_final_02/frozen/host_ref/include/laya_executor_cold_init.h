#pragma once

#include "laya_full_runtime.h"

namespace laya::full {

enum class ColdInitPhase : uint8_t {
  OWNERS, SOURCES, SOURCE_WINDOWS, QKV_ROWS, ROPE_ROWS, ATT_ROWS,
  G_DOWN_WINDOWS, DONE
};
struct ColdInitCursor {
  ColdInitPhase phase = ColdInitPhase::OWNERS;
  unsigned index = 0;
  unsigned steps = 0;
  bool done = false;
};
// One typed cell or one uint32_t row-map word is initialized per invocation.
// These are invocation bounds, not an HLS cycle count.
constexpr unsigned kColdInitOwnerSteps = 32;
constexpr unsigned kColdInitSourceSteps = kSourceProvenanceOwners;
constexpr unsigned kColdInitWindowSteps =
    kSourceProvenanceOwners * kSourceProvenanceWindows;
constexpr unsigned kColdInitQkvSteps = 2 * 3 * 16 * 2 * 32;
constexpr unsigned kColdInitRopeSteps = 2 * 2 * 16 * 2 * 32;
constexpr unsigned kColdInitAttSteps = 16 * 2 * 32;
constexpr unsigned kColdInitMaxSteps = kColdInitOwnerSteps + kColdInitSourceSteps +
    kColdInitWindowSteps + kColdInitQkvSteps + kColdInitRopeSteps +
    kColdInitAttSteps + kGDownWindows;

// Only the global cold-start owner calls this, before FIRST or any actor read.
// Ordinary request begin/cancel/close/reset APIs do not call or reset it.
void cold_init_step(FullRuntime&, ColdInitCursor&);

} // namespace laya::full
