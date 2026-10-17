#pragma once

#include "laya_full_runtime.h"

namespace laya::full {

using FullCacheWeightQ = int8_t[5373952];
using FullCacheWeightScale = uint16_t[167936];
using FullCacheWeightBias = float[5248];
using FullCacheActivationQ = int8_t[16][128][32];
using FullCacheActivationScale = uint16_t[16][128];
using FullCacheInputTile = float[16][4096];
using FullCachePsTile = float[16][5248];
using FullCacheGamma = float[2][1024];
using FullCacheRopeTable = float[2][1025][64];
using FullCacheKv = float[2][2][1024][64];
using FullCacheScore = float[2][16][1024];
using FullCacheAvPartial = float[16][64];
using FullCacheFpActWeight = uint16_t[256][1028];

#ifdef __SYNTHESIS__

extern FullCacheWeightQ g_full_cache_weight_q;
extern FullCacheWeightScale g_full_cache_weight_scale;
extern FullCacheWeightBias g_full_cache_weight_bias;
extern FullCacheActivationQ g_full_cache_activation_q;
extern FullCacheActivationScale g_full_cache_activation_scale;
extern FullCacheInputTile g_full_cache_input_tile;
extern FullCachePsTile g_full_cache_ps_tile;
extern FullCacheGamma g_full_cache_gamma;
extern FullCacheRopeTable g_full_cache_rope_table;
extern FullCacheKv g_full_cache_kv;
extern FullCacheScore g_full_cache_score;
extern FullCacheAvPartial g_full_cache_av_partial;
extern FullCacheFpActWeight g_full_cache_fp_act_weight;

#define LAYA_FULL_CACHE_ACCESSOR(name, type)                                  \
  inline type& full_cache_##name(FullRuntime&) {                              \
    _Pragma("HLS INLINE")                                                      \
    return g_full_cache_##name;                                               \
  }                                                                           \
  inline const type& full_cache_##name(const FullRuntime&) {                  \
    _Pragma("HLS INLINE")                                                      \
    return g_full_cache_##name;                                               \
  }

#else

#define LAYA_FULL_CACHE_ACCESSOR(name, type)                                  \
  inline type& full_cache_##name(FullRuntime& rt) { return rt.cache.name; }   \
  inline const type& full_cache_##name(const FullRuntime& rt) {               \
    return rt.cache.name;                                                      \
  }

#endif

LAYA_FULL_CACHE_ACCESSOR(weight_q, FullCacheWeightQ)
LAYA_FULL_CACHE_ACCESSOR(weight_scale, FullCacheWeightScale)
LAYA_FULL_CACHE_ACCESSOR(weight_bias, FullCacheWeightBias)
LAYA_FULL_CACHE_ACCESSOR(activation_q, FullCacheActivationQ)
LAYA_FULL_CACHE_ACCESSOR(activation_scale, FullCacheActivationScale)
LAYA_FULL_CACHE_ACCESSOR(input_tile, FullCacheInputTile)
LAYA_FULL_CACHE_ACCESSOR(ps_tile, FullCachePsTile)
LAYA_FULL_CACHE_ACCESSOR(gamma, FullCacheGamma)
LAYA_FULL_CACHE_ACCESSOR(rope_table, FullCacheRopeTable)
LAYA_FULL_CACHE_ACCESSOR(kv, FullCacheKv)
LAYA_FULL_CACHE_ACCESSOR(score, FullCacheScore)
LAYA_FULL_CACHE_ACCESSOR(av_partial, FullCacheAvPartial)
LAYA_FULL_CACHE_ACCESSOR(fp_act_weight, FullCacheFpActWeight)

#undef LAYA_FULL_CACHE_ACCESSOR

} // namespace laya::full
