#pragma once

#include "laya_tasks.h"

namespace laya {

// P1's fixed-size, blocking compute boundary.  A valid READY record is a
// producer's publication of complete 32-element groups; callers may not
// substitute a pointer or a content label for this record.
struct NumericIdentity {
  uint64_t request_id = 0;
  uint64_t generation = 0;
  uint16_t B = 0, S = 0;
  uint8_t model_tag[16] = {};
  uint8_t numeric_tag[16] = {};
  uint8_t layout_tag[16] = {};
  uint8_t build_tag[16] = {};
};

struct F32TileMeta {
  NumericIdentity identity;
  BufferRef ref;
  uint8_t region = 0;
  RowSpace row_space = RowSpace::TOKEN;
  uint8_t batch = 0;
  uint16_t row0 = 0;
  uint8_t rows = 0;
  uint16_t K = 0;
  CacheState state = CacheState::INVALID;
  Content content = Content::UNDEFINED;
  uint8_t readers = 0;
  // Bit g means all 32 features of group g in that row were written.
  uint32_t covered_groups[16][4] = {};
  bool valid = false;
};

struct GammaMeta {
  uint8_t model_tag[16] = {};
  BufferRef ref;
  uint8_t gamma_kind = 0;
  uint16_t D = 0;
  uint32_t covered_groups = 0;
  CacheState state = CacheState::INVALID;
  bool valid = false;
};

struct A8TileMeta {
  NumericIdentity identity;
  BufferRef ref;
  F32TileMeta source;
  uint32_t producer_task_id = 0;
  uint8_t stage = 0, layer = 255;
  RowSpace row_space = RowSpace::TOKEN;
  uint8_t batch = 0;
  uint16_t row0 = 0;
  uint8_t rows = 0;
  uint16_t K = 0;
  uint32_t covered_groups[16][4] = {};
  CacheState state = CacheState::INVALID;
  Content content = Content::UNDEFINED;
  uint8_t readers = 0;
  bool valid = false;
};

// The expected binding is supplied independently of the loaded window.  The
// full tensor hash and byte range identify the exact immutable GGUF source.
struct WeightBinding {
  uint8_t weight_sha256[32] = {};
  uint64_t weight_offset = 0;
  uint32_t weight_bytes = 0;
  uint8_t bias_sha256[32] = {};
  uint64_t bias_offset = 0;
  uint32_t bias_bytes = 0;
};

struct WeightWindowMeta {
  NumericIdentity identity;
  BufferRef ref;
  WeightKey weight;
  WeightBinding binding;
  uint16_t K = 0, N = 0, n0 = 0;
  uint8_t cols = 0, bias_kind = 0;
  uint32_t covered_groups[8][4] = {};
  CacheState state = CacheState::INVALID;
  Content content = Content::UNDEFINED;
  uint8_t readers = 0;
  bool valid = false;
};

struct NumericWindowResult {
  NumericIdentity identity;
  BufferRef ps, dst;
  uint32_t task_id = 0;
  uint8_t dst_region = 0;
  RowSpace row_space = RowSpace::TOKEN;
  uint8_t batch = 0;
  uint16_t row0 = 0, N = 0, n0 = 0;
  uint8_t rows = 0, cols = 0;
  uint32_t output_elements = 0, output_beats = 0;
  Status status = Status::E_INTERNAL;
  CacheState state = CacheState::INVALID;
  uint8_t readers = 0;
  bool valid = false;
};

struct NumericTraceRequest {
  bool enabled = false;
  uint8_t row_local = 0, col_local = 0;
};
struct NumericGroupTrace {
  int32_t dot = 0;
  uint32_t term_bits = 0, partial_bits = 0;
};

bool numeric_identity_valid(const NumericIdentity&);
bool numeric_identity_equal(const NumericIdentity&, const NumericIdentity&);
bool numeric_source_equal(const F32TileMeta&, const F32TileMeta&);
bool numeric_binding_equal(const WeightBinding&, const WeightBinding&);
bool numeric_coverage_complete(const uint32_t mask[][4], unsigned rows,
                               unsigned groups, unsigned capacity_rows);
void numeric_cover_all(uint32_t mask[][4], unsigned rows, unsigned groups,
                       unsigned capacity_rows);
Check numeric_check_context(const TaskContext&, const NumericIdentity&);
Check numeric_check_ref(BufferRef, uint8_t region = 0);
Check numeric_check_weight(WeightKey, uint8_t stage, uint8_t layer,
                           uint16_t K, uint16_t N);
Check numeric_check_source(const F32TileMeta&, const NumericIdentity&,
                           BufferRef, uint8_t region, const TaskContext&,
                           uint16_t K);
Check numeric_check_gamma(const GammaMeta&, const NumericIdentity&,
                          uint8_t gamma_kind);
Check numeric_check_a8(const A8TileMeta&, const NumericIdentity&,
                       const LinearTask&, const F32TileMeta& expected_source);
Check numeric_check_window(const WeightWindowMeta&, const NumericIdentity&,
                           const LinearTask&, const WeightBinding&,
                           uint16_t n0, uint8_t cols);
Check numeric_claim_f32(F32TileMeta&, BufferRef next, uint8_t region);
Check numeric_claim_a8(A8TileMeta&, BufferRef next);
Check numeric_claim_window(NumericWindowResult&, BufferRef next_ps,
                           BufferRef next_dst, uint8_t dst_region);
Check numeric_release_f32(F32TileMeta&);
Check numeric_release_a8(A8TileMeta&);
Check numeric_release_window(NumericWindowResult&);
void numeric_reset_f32(F32TileMeta&);
void numeric_reset_a8(A8TileMeta&);
void numeric_reset_window(NumericWindowResult&);
uint32_t numeric_f32_bits(float);
float numeric_bits_f32(uint32_t);
float numeric_half_to_f32(uint16_t);
uint16_t numeric_f32_to_half_rne(float);

} // namespace laya
