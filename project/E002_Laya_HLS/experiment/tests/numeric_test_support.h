#pragma once

#include "laya_numeric.h"

#include <cstdlib>
#include <iostream>

inline void nrequire(bool condition, const char* message) {
  if (!condition) { std::cerr << "NUMERIC_TEST_FAIL " << message << '\n'; std::exit(1); }
}

inline laya::NumericIdentity test_identity() {
  laya::NumericIdentity id;
  id.request_id = 37; id.generation = 5; id.B = 2; id.S = 128;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(i + 1);
    id.numeric_tag[i] = uint8_t(i + 21);
    id.layout_tag[i] = uint8_t(i + 41);
    id.build_tag[i] = uint8_t(i + 61);
  }
  return id;
}

inline laya::F32TileMeta test_source(const laya::NumericIdentity& id,
                                     laya::BufferRef ref, uint8_t region,
                                     const laya::TaskContext& ctx, uint16_t K) {
  laya::F32TileMeta m;
  m.identity = id; m.ref = ref; m.region = region;
  m.row_space = ctx.row_space; m.batch = ctx.batch;
  m.row0 = ctx.row0; m.rows = ctx.rows; m.K = K;
  laya::numeric_cover_all(m.covered_groups, ctx.rows, K / 32, 16);
  m.state = laya::CacheState::READY; m.content = laya::Content::F32;
  m.valid = true;
  return m;
}

inline laya::GammaMeta test_gamma(const laya::NumericIdentity& id,
                                  uint8_t kind) {
  laya::GammaMeta m;
  for (unsigned i = 0; i < 16; ++i) m.model_tag[i] = id.model_tag[i];
  m.ref = {laya::Buffer::LN_GAMMA, uint8_t(kind - 1), 1};
  m.gamma_kind = kind; m.D = 1024; m.covered_groups = UINT32_MAX;
  m.state = laya::CacheState::READY; m.valid = true;
  return m;
}

inline laya::WeightBinding test_binding(uint16_t K, uint16_t N,
                                        bool with_bias = false) {
  laya::WeightBinding b;
  b.weight_offset = 1000; b.weight_bytes = uint32_t(N) * (K / 32) * 34;
  for (unsigned i = 0; i < 32; ++i) b.weight_sha256[i] = uint8_t(i + 1);
  if (with_bias) {
    b.bias_offset = 2000; b.bias_bytes = uint32_t(N) * 4;
    for (unsigned i = 0; i < 32; ++i) b.bias_sha256[i] = uint8_t(i + 2);
  }
  return b;
}

inline laya::WeightWindowMeta test_window(const laya::NumericIdentity& id,
                                           const laya::LinearTask& task,
                                           uint16_t n0, uint8_t cols,
                                           const laya::WeightBinding& binding) {
  laya::WeightWindowMeta m;
  m.identity = id; m.ref = task.w; m.weight = task.weight;
  m.binding = binding; m.K = task.K; m.N = task.N;
  m.n0 = n0; m.cols = cols; m.bias_kind = task.bias_kind;
  laya::numeric_cover_all(m.covered_groups, cols, task.K / 32, 8);
  m.state = laya::CacheState::READY; m.content = laya::Content::Q8_WEIGHT;
  m.valid = true;
  return m;
}
