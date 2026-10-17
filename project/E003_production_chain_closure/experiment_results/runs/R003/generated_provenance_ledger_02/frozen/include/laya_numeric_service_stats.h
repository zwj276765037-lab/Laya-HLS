#pragma once
#include <cstdint>

// Software/CSim observations only. These counters do not enter synthesized RTL
// or replace actual generated-instance and physical handshake evidence.
#ifndef __SYNTHESIS__
namespace laya {
struct NumericServiceStats {
  uint64_t quant_tasks = 0;
  uint64_t quant_group_calls = 0;
  uint64_t quant_owner_echoes = 0;
  uint64_t tm4_owned_windows = 0;
  uint64_t tm4_group_calls = 0;
  uint64_t tm4_active_lane_groups = 0;
  uint64_t tm4_owner_echoes = 0;
  uint64_t legacy_windows = 0;
  uint64_t trace_enabled_windows = 0;
  uint64_t isolated_trace_replays = 0;
  uint64_t tm4_shape_windows[7] = {};
};
NumericServiceStats& numeric_service_stats();
void numeric_service_stats_reset();
void numeric_service_stats_window(uint16_t K, uint16_t N);
void numeric_service_stats_tm4_call(uint32_t active_mask);
} // namespace laya
#endif
