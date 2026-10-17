#include "laya_full_cache_storage.h"

#ifdef __SYNTHESIS__
namespace laya::full {

FullCacheWeightQ g_full_cache_weight_q = {};
FullCacheWeightScale g_full_cache_weight_scale = {};
FullCacheWeightBias g_full_cache_weight_bias = {};
FullCacheActivationQ g_full_cache_activation_q = {};
FullCacheActivationScale g_full_cache_activation_scale = {};
FullCacheInputTile g_full_cache_input_tile = {};
FullCachePsTile g_full_cache_ps_tile = {};
FullCacheGamma g_full_cache_gamma = {};
FullCacheRopeTable g_full_cache_rope_table = {};
FullCacheKv g_full_cache_kv = {};
FullCacheScore g_full_cache_score = {};
FullCacheAvPartial g_full_cache_av_partial = {};
FullCacheFpActWeight g_full_cache_fp_act_weight = {};

} // namespace laya::full
#endif
