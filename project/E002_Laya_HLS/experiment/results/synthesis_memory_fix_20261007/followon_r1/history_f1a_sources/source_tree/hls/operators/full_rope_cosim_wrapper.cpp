#include "laya_full_numeric.h"

// Tool-only unmangled top for Vitis RTL co-simulation. The arithmetic and
// validation remain in the production rope_head leaf.
extern "C" uint16_t full_rope_cosim_top(const float x[64],
                                         const float cosine[64],
                                         const float sine[64], float y[64]) {
  const laya::Check result = laya::full::rope_head(x, cosine, sine, y);
  return static_cast<uint16_t>(result.code);
}
