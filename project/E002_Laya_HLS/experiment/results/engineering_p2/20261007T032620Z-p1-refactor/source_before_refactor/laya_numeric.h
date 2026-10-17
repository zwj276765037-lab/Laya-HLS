#pragma once

#include "laya_numeric_tasks.h"

namespace laya {

Check layernorm_compute(const LayerNormTask& task,
                        const NumericIdentity& request,
                        const F32TileMeta& source, const GammaMeta& gamma_meta,
                        const float x[16][1024], const float gamma[1024],
                        float y[16][1024], float mean[16],
                        float variance[16], float inverse[16],
                        F32TileMeta& result);

Check activation_quantizer_compute(const QuantTask& task,
                                   const NumericIdentity& request,
                                   const F32TileMeta& source,
                                   const float x[16][4096],
                                   int8_t q[16][128][32],
                                   uint16_t scale_bits[16][128],
                                   A8TileMeta& result);

Check q8_linear_compute(const LinearTask& task,
                        const NumericIdentity& request,
                        const F32TileMeta& expected_source,
                        const A8TileMeta& activation,
                        const WeightWindowMeta& weight,
                        const WeightBinding& expected_binding,
                        uint16_t n0, uint8_t cols,
                        const int8_t aq[16][128][32],
                        const uint16_t as[16][128],
                        const int8_t wq[8][128][32],
                        const uint16_t ws[8][128],
                        const float bias[8], float y[16][8],
                        NumericWindowResult& result,
                        NumericTraceRequest trace_request,
                        NumericGroupTrace trace[128]);

// Read-only diagnostic replay for any selected output.  It uses the same
// per-output arithmetic as q8_linear_compute and never publishes a window.
Check q8_linear_trace(const LinearTask& task,
                      const NumericIdentity& request,
                      const F32TileMeta& expected_source,
                      const A8TileMeta& activation,
                      const WeightWindowMeta& weight,
                      const WeightBinding& expected_binding,
                      uint16_t n0, uint8_t cols, uint8_t row_local,
                      uint8_t col_local,
                      const int8_t aq[16][128][32],
                      const uint16_t as[16][128],
                      const int8_t wq[8][128][32],
                      const uint16_t ws[8][128],
                      const float bias[8], NumericGroupTrace trace[128]);

} // namespace laya
