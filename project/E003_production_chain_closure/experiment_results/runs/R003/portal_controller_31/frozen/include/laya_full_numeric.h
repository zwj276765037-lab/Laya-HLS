#pragma once

#include "laya_numeric_tasks.h"

namespace laya::full {

// P2 F0 blocking arithmetic leaves.  A successful Check does not publish a
// buffer, retire a task, or replace the complete task/owner boundary.
Check embedding_row(const uint8_t raw[1088], float y[1024]);
Check rope_head(const float x[64], const float cosine[64],
                const float sine[64], float y[64]);
Check qk_row(const float q[64], const float k[1024][64],
             const uint8_t mask[1024], uint16_t S, uint16_t query,
             bool sliding, float score[1024]);
Check softmax_row(const float x[1024], uint16_t length, float p[1024]);
Check av_row(const float p[1024], const float v[1024][64],
             uint16_t S, float y[64]);
Check fp_scorer_row(const float x[1024], const float w[1024],
                    float bias, float& y);
Check fp_act_row(const float x[1028], const uint16_t w[256][1028],
                 float y[256]);
Check gelu_scalar(float x, float& y);
Check geglu_row(const float wi[5248], float y[2624]);
Check relu_row(const float x[4096], float y[4096]);
Check add_row(const float a[1024], const float b[1024], float y[1024]);
Check bias_gelu_row(const float x[1024], const float bias[1024],
                    uint16_t length, float y[1024]);
Check candidate_mask(const float logits[16], const uint8_t mask[16],
                      float y[16]);
Check candidate_stats(const float p[16], uint8_t valid_options,
                       float stats[4]);
Check concat_act_row(const float cls[1024], const float stats[4],
                      float y[1028]);

} // namespace laya::full
