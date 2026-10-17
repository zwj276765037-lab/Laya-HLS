#include "laya_full_cache_storage.h"

extern "C" void full_cache_packing_pilot(uint8_t target, uint32_t index,
                                           uint32_t value, bool write_enable,
                                           int32_t* result, uint32_t* status) {
#ifdef __SYNTHESIS__
  using laya::full::g_full_cache_weight_q;
  using laya::full::g_full_cache_weight_scale;
#pragma HLS INTERFACE s_axilite port=target bundle=control
#pragma HLS INTERFACE s_axilite port=index bundle=control
#pragma HLS INTERFACE s_axilite port=value bundle=control
#pragma HLS INTERFACE s_axilite port=write_enable bundle=control
#pragma HLS INTERFACE s_axilite port=result bundle=control
#pragma HLS INTERFACE s_axilite port=status bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_q type=ram_1p impl=uram
#pragma HLS BIND_STORAGE variable=g_full_cache_weight_scale type=ram_1p impl=uram
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_q cyclic factor=8 dim=1
#pragma HLS ARRAY_RESHAPE variable=g_full_cache_weight_scale cyclic factor=4 dim=1
#endif
  static laya::full::FullRuntime runtime;
  *result = 0;
  *status = 0;
  if (target == 0) {
    if (index >= 5373952u) { *status = 1; return; }
    if (write_enable)
      laya::full::full_cache_weight_q(runtime)[index] =
          static_cast<int8_t>(value);
    else
      *result = laya::full::full_cache_weight_q(runtime)[index];
  } else if (target == 1) {
    if (index >= 167936u) { *status = 1; return; }
    if (write_enable)
      laya::full::full_cache_weight_scale(runtime)[index] =
          static_cast<uint16_t>(value);
    else
      *result = laya::full::full_cache_weight_scale(runtime)[index];
  } else if (target == 2) {
    *result = (uint32_t(runtime.owners.record[0].layer) << 8) |
              uint32_t(runtime.owners.record[0].state);
  } else {
    *status = 1;
  }
}
