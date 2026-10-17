#include "laya_executor_cold_init.h"

namespace laya::full {
namespace {
void advance(ColdInitCursor& c, unsigned count, ColdInitPhase next) {
#pragma HLS inline
  ++c.steps;
  if (++c.index == count) { c.index = 0; c.phase = next; }
}
}
void cold_init_step(FullRuntime& rt, ColdInitCursor& c) {
#pragma HLS inline off
  if (c.done) return;
  const unsigned i = c.index;
  switch (c.phase) {
  case ColdInitPhase::OWNERS:
    rt.owners.record.initialize(i);
    advance(c, kColdInitOwnerSteps, ColdInitPhase::SOURCES);
    break;
  case ColdInitPhase::SOURCES:
    // Establish a source record's metadata without constructing 128 windows.
    rt.owners.source.initialize_cold(i);
    advance(c, kColdInitSourceSteps, ColdInitPhase::SOURCE_WINDOWS);
    break;
  case ColdInitPhase::SOURCE_WINDOWS:
    rt.owners.source[i / kSourceProvenanceWindows].window.initialize(
        i % kSourceProvenanceWindows);
    advance(c, kColdInitWindowSteps, ColdInitPhase::QKV_ROWS);
    break;
  case ColdInitPhase::QKV_ROWS:
    rt.owners.qkv_plane_head_rows[i / 3072][(i / 1024) % 3]
        [(i / 64) % 16][(i / 32) % 2][i % 32] = 0;
    advance(c, kColdInitQkvSteps, ColdInitPhase::ROPE_ROWS);
    break;
  case ColdInitPhase::ROPE_ROWS:
    rt.owners.qkv_rope_rows[i / 2048][(i / 1024) % 2]
        [(i / 64) % 16][(i / 32) % 2][i % 32] = 0;
    advance(c, kColdInitRopeSteps, ColdInitPhase::ATT_ROWS);
    break;
  case ColdInitPhase::ATT_ROWS:
    rt.owners.att_head_rows[i / 64][(i / 32) % 2][i % 32] = 0;
    advance(c, kColdInitAttSteps, ColdInitPhase::G_DOWN_WINDOWS);
    break;
  case ColdInitPhase::G_DOWN_WINDOWS:
    rt.g_down_plan.window.initialize(i);
    advance(c, kGDownWindows, ColdInitPhase::DONE);
    // All cells and all scalar row-map words now have their ordinary defaults.
    if (c.phase == ColdInitPhase::DONE) c.done = true;
    break;
  case ColdInitPhase::DONE:
    // The DONE phase can only be reached by the final real initialization.
    break;
  }
}
} // namespace laya::full
