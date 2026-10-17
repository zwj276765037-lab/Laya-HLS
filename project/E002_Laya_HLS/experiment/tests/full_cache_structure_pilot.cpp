#include "laya_full_cache_storage.h"

extern "C" void full_cache_structure_pilot(
    uint8_t target, uint32_t i, uint32_t j, uint32_t k, uint32_t l,
    uint32_t value, bool write_enable, uint32_t* result, uint32_t* status) {
#ifdef __SYNTHESIS__
  using laya::full::g_full_cache_weight_q;
  using laya::full::g_full_cache_weight_scale;
#pragma HLS INTERFACE s_axilite port=target bundle=control
#pragma HLS INTERFACE s_axilite port=i bundle=control
#pragma HLS INTERFACE s_axilite port=j bundle=control
#pragma HLS INTERFACE s_axilite port=k bundle=control
#pragma HLS INTERFACE s_axilite port=l bundle=control
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

#define RW_CELL(cell, type)                              \
  do {                                                    \
    if (write_enable) (cell) = static_cast<type>(value);  \
    else *result = static_cast<uint32_t>(cell);           \
  } while (0)

  switch (target) {
  case 0:
    if (i >= 5373952u) break;
    RW_CELL(laya::full::full_cache_weight_q(runtime)[i], int8_t);
    return;
  case 1:
    if (i >= 167936u) break;
    RW_CELL(laya::full::full_cache_weight_scale(runtime)[i], uint16_t);
    return;
  case 2:
    if (i >= 5248u) break;
    RW_CELL(laya::full::full_cache_weight_bias(runtime)[i], float);
    return;
  case 3:
    if (i >= 16u || j >= 128u || k >= 32u) break;
    RW_CELL(laya::full::full_cache_activation_q(runtime)[i][j][k], int8_t);
    return;
  case 4:
    if (i >= 16u || j >= 128u) break;
    RW_CELL(laya::full::full_cache_activation_scale(runtime)[i][j], uint16_t);
    return;
  case 5:
    if (i >= 16u || j >= 4096u) break;
    RW_CELL(laya::full::full_cache_input_tile(runtime)[i][j], float);
    return;
  case 6:
    if (i >= 16u || j >= 5248u) break;
    RW_CELL(laya::full::full_cache_ps_tile(runtime)[i][j], float);
    return;
  case 7:
    if (i >= 2u || j >= 1024u) break;
    RW_CELL(laya::full::full_cache_gamma(runtime)[i][j], float);
    return;
  case 8:
    if (i >= 2u || j >= 1025u || k >= 64u) break;
    RW_CELL(laya::full::full_cache_rope_table(runtime)[i][j][k], float);
    return;
  case 9:
    if (i >= 2u || j >= 2u || k >= 1024u || l >= 64u) break;
    RW_CELL(laya::full::full_cache_kv(runtime)[i][j][k][l], float);
    return;
  case 10:
    if (i >= 2u || j >= 16u || k >= 1024u) break;
    RW_CELL(laya::full::full_cache_score(runtime)[i][j][k], float);
    return;
  case 11:
    if (i >= 16u || j >= 64u) break;
    RW_CELL(laya::full::full_cache_av_partial(runtime)[i][j], float);
    return;
  case 12:
    if (i >= 256u || j >= 1028u) break;
    RW_CELL(laya::full::full_cache_fp_act_weight(runtime)[i][j], uint16_t);
    return;
  case 13:
    if (i >= 32u) break;
    if (write_enable)
      runtime.owners.record[i].state =
          static_cast<laya::CacheState>(value & 7u);
    else
      *result = (uint32_t(runtime.owners.record[i].layer) << 8) |
                uint32_t(runtime.owners.record[i].state);
    return;
  default:
    break;
  }
  *status = 1;
#undef RW_CELL
}
