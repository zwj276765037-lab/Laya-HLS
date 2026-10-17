#pragma once

#include "laya_full_numeric.h"
#include "laya_memory_map.h"

namespace laya::full {

// The 13 ordered byte ports of the single forward kernel. The first six
// model ports are read-only except IO; capacities are supplied by the CPU
// harness and replaced by generated constants at the hardware boundary.
struct FullMemory {
  const uint8_t* embedding = nullptr; uint64_t embedding_bytes = 0;
  uint8_t* io = nullptr; uint64_t io_bytes = 0;
  const uint8_t* w_q0 = nullptr; uint64_t w_q0_bytes = 0;
  const uint8_t* w_q1 = nullptr; uint64_t w_q1_bytes = 0;
  const uint8_t* w_scale = nullptr; uint64_t w_scale_bytes = 0;
  const uint8_t* aux = nullptr; uint64_t aux_bytes = 0;
  uint8_t* state0 = nullptr; uint64_t state0_bytes = 0;
  uint8_t* state1 = nullptr; uint64_t state1_bytes = 0;
  uint8_t* qkv0 = nullptr; uint64_t qkv0_bytes = 0;
  uint8_t* qkv1 = nullptr; uint64_t qkv1_bytes = 0;
  uint8_t* ff0 = nullptr; uint64_t ff0_bytes = 0;
  uint8_t* ff1 = nullptr; uint64_t ff1_bytes = 0;
  uint8_t* att_out = nullptr; uint64_t att_out_bytes = 0;
};

// B/S live in identity only. These arrays contain every ABI element, with
// unused physical positions preserved but never interpreted as active rows.
struct FullInputs {
  NumericIdentity identity;
  int32_t token_ids[2][1024] = {};
  int32_t marker_positions[2][16] = {};
  uint8_t attention_mask[2][1024] = {};
  uint8_t marker_mask[2][16] = {};
  uint8_t qtype[2] = {};
};

// Generated model-table record. A removed slide_bias retains its source
// record with omitted=1, bo=255 and no target span.
struct FullTensorDescriptor {
  char name[48] = {};
  uint8_t ggml_type_id = 0, bo = 255, omitted = 0, reserved = 0;
  uint32_t ne[4] = {};
  uint32_t source_offset = 0, source_bytes = 0;
  uint32_t base = 0, span = 0;
  uint8_t source_sha256[32] = {};
};

// 122 Q8 matrices plus scorer F32 FC2 and act F16 FC1. Unused bases/spans
// are zero; each valid matrix has one descriptor for its legal family/layer.
struct FullWeightDescriptor {
  char name[48] = {};
  WeightKey key;
  uint16_t K = 0, N = 0;
  uint8_t dtype = 0, bias_kind = 0;
  uint32_t q_base[2] = {}, q_span[2] = {};
  uint32_t scale_base = 0, scale_span = 0;
  uint32_t aux_base = 0, aux_span = 0;
  uint32_t bias_base = 0, bias_span = 0;
  uint8_t source_sha256[32] = {};
  uint8_t bias_sha256[32] = {};
};

struct FullOwnerRecord {
  NumericIdentity identity;
  BufferRef ref;
  BufferRef lease_old_ref;
  uint32_t max_claimed_epoch = 0;
  uint8_t region = 0, stage = 0, layer = 255, batch = 0;
  RowSpace row_space = RowSpace::TOKEN;
  uint16_t row0 = 0, rows = 0, width = 0;
  Content content = Content::UNDEFINED;
  CacheState state = CacheState::INVALID;
  uint8_t readers = 0;
  uint32_t covered_rows[64] = {};
  uint32_t old_consumed_rows[64] = {};
  bool valid = false;
};

struct FullOwnerSpec {
  BufferRef ref;
  uint8_t region = 0, stage = 0, layer = 255;
  uint8_t batch = 255; // 255 binds every active batch; otherwise one batch.
  RowSpace row_space = RowSpace::TOKEN;
  uint16_t row0 = 0, rows = 0;
  uint16_t width = 0;
  Content content = Content::UNDEFINED;
};

struct FullOwners {
  FullOwnerRecord record[32] = {};
  uint32_t qkv_plane_head_rows[2][3][16][2][32] = {};
  uint32_t qkv_rope_rows[2][2][16][2][32] = {};
  uint32_t att_head_rows[16][2][32] = {};
  uint16_t scorer_old_consumed[2] = {};
  uint16_t scorer_new_written[2] = {};
  bool type_valid[3] = {};
};

// One current matrix and one row tile.  The Q8 arrays are sized for the
// actual largest N*K/32 product (Wi), not max(N)*max(K).
struct FullCache {
  int8_t weight_q[5373952] = {};
  uint16_t weight_scale[167936] = {};
  float weight_bias[5248] = {};
  int8_t activation_q[16][128][32] = {};
  uint16_t activation_scale[16][128] = {};
  float input_tile[16][4096] = {};
  float ps_tile[16][5248] = {};
  float gamma[2][1024] = {};
  float rope_table[2][1025][64] = {};
  float kv[2][2][1024][64] = {};
  float score[2][16][1024] = {};
  float av_partial[16][64] = {};
  uint16_t fp_act_weight[256][1028] = {};
  F32TileMeta activation_source_ledger;
  A8TileMeta activation_meta;
};

struct FullRuntime {
  FullMemory memory;
  FullInputs inputs;
  FullOwners owners;
  FullCache cache;
  FullWeightDescriptor current_weight;
  BufferRef current_weight_ref;
  BufferRef loaded_gamma_ref[2];
  BufferRef final_qkv_ref[2];
  BufferRef loaded_kv_ref, loaded_rope_ref;
  BufferRef score_ref, score_kv_ref, score_qkv_ref[2];
  uint8_t score_head = 255, score_stage = 0, score_layer = 255;
  uint8_t score_batch = 255, score_rows = 0;
  uint16_t score_row0 = 0;
  bool score_valid = false;
  FullOwnerSpec expected_quant_source;
  FullOwnerSpec expected_task_source[4];
  uint8_t expected_task_source_count = 0;
  uint8_t loaded_rope_mode = 255, loaded_kv_head = 255;
  uint32_t last_task_id = 0, tasks_retired = 0;
  uint32_t op_calls[256] = {};
  uint32_t owner_claims = 0, owner_leases = 0;
  uint8_t encoder_layers_completed = 0, decision_layers_completed = 0;
  uint64_t session_generation = 0, last_accepted_request_id = 0;
  uint64_t diagnostic_request_id = 0, diagnostic_generation = 0;
  uint16_t diagnostic_B = 0, diagnostic_S = 0;
  bool diagnostic_identity_valid = false, diagnostic_shape_valid = false;
  Check last_execution_error = ok(), last_cleanup_error = ok();
  bool request_valid = false, model_header_valid = false;
  bool expected_quant_source_valid = false;
#ifndef __SYNTHESIS__
  void (*checkpoint)(const char* name, const FullRuntime&, BufferRef,
                     uint8_t region, RowSpace, uint16_t width,
                     void* user) = nullptr;
  void* checkpoint_user = nullptr;
#endif
};

struct FullSegment {
  Bo src_bo = Bo::IO, dst_bo = Bo::IO;
  uint32_t src_offset = 0, dst_offset = 0, bytes = 0;
};

Check full_check_model_header(const FullMemory&, const NumericIdentity&);
Check full_parse_request(FullRuntime&);
Check full_lookup_weight(WeightKey, FullWeightDescriptor&);
bool full_equal_weight(const FullWeightDescriptor&, const FullWeightDescriptor&);
Check full_tensor_descriptor(uint16_t tensor_index, FullTensorDescriptor&);
Check full_lookup_tensor(const char* name, FullTensorDescriptor&,
                         uint16_t* index = nullptr);
Check full_span(const FullMemory&, Bo, uint64_t offset, uint64_t bytes);
Check full_read(const FullMemory&, Bo, uint64_t offset, uint8_t* dst,
                uint32_t bytes);
Check full_write(FullMemory&, Bo, uint64_t offset, const uint8_t* src,
                 uint32_t bytes);
Check full_next_segment(Bo src_bo, uint64_t src_offset,
                        Bo dst_bo, uint64_t dst_offset, uint32_t remaining,
                        FullSegment&);
Check full_copy(FullMemory&, Bo src_bo, uint64_t src_offset,
                Bo dst_bo, uint64_t dst_offset, uint32_t bytes,
                uint32_t& segment_count);
Check full_f32_address(const FullRuntime&, BufferRef, uint8_t region,
                       uint8_t batch, uint16_t row, uint16_t col,
                       Address&);
Check full_q8_address(const FullRuntime&, const FullWeightDescriptor&,
                      uint16_t n, uint16_t k, Address& q, Address& scale);
Check full_claim_owner(FullRuntime&, const FullOwnerSpec&);
Check full_check_fill_owner(const FullRuntime&, const FullOwnerSpec&);
Check full_check_uncovered_owner(const FullRuntime&, const FullOwnerSpec&,
                                 uint8_t batch, uint16_t row0,
                                 uint16_t rows);
Check full_check_uncovered_qkv(const FullRuntime&,
                               const FullOwnerSpec (&)[2], uint8_t batch,
                               uint16_t row0, uint16_t rows);
Check full_claim_qkv_pair(FullRuntime&, const FullOwnerSpec (&)[2]);
Check full_cover_qkv(FullRuntime&, const FullOwnerSpec (&)[2],
                     uint8_t plane, uint8_t head, uint8_t batch,
                     uint16_t row0, uint16_t rows);
Check full_publish_qkv_pair(FullRuntime&, const FullOwnerSpec (&)[2]);
Check full_begin_qkv_rope_pair(FullRuntime&, const FullOwnerSpec (&old_object)[2],
                               const FullOwnerSpec (&next_object)[2]);
Check full_cover_qkv_rope(FullRuntime&, const FullOwnerSpec (&next_object)[2],
                          uint8_t head, uint8_t batch,
                          uint16_t row0, uint16_t rows);
Check full_commit_qkv_rope_pair(FullRuntime&,
                                const FullOwnerSpec (&next_object)[2]);
Check full_cover_att_head(FullRuntime&, const FullOwnerSpec&, uint8_t head,
                          uint8_t batch, uint16_t row0, uint16_t rows);
Check full_publish_att(FullRuntime&, const FullOwnerSpec&);
Check full_require_owner(const FullRuntime&, const FullOwnerSpec&,
                         uint8_t batch, uint16_t row0, uint16_t rows);
Check full_acquire_owner(FullRuntime&, const FullOwnerSpec&,
                         uint8_t batch, uint16_t row0, uint16_t rows);
Check full_release_read_owner(FullRuntime&, const FullOwnerSpec&);
Check full_cover_owner(FullRuntime&, const FullOwnerSpec&,
                       uint8_t batch, uint16_t row0, uint16_t rows);
Check full_publish_owner(FullRuntime&, const FullOwnerSpec&);
Check full_release_owner(FullRuntime&, const FullOwnerSpec&);
Check full_invalidate_owner(FullRuntime&, BufferRef, uint8_t region);
Check full_begin_inplace_owner(FullRuntime&, const FullOwnerSpec& old_object,
                               const FullOwnerSpec& next_object);
Check full_consume_inplace_rows(FullRuntime&, const FullOwnerSpec&,
                                uint8_t batch, uint16_t row0, uint16_t rows);
Check full_commit_inplace_owner(FullRuntime&, const FullOwnerSpec&);
Check full_owner_snapshot(const FullRuntime&, BufferRef, uint8_t region,
                          FullOwnerRecord&);
Check full_bind_quant_source(FullRuntime&, const FullOwnerSpec& expected);
Check full_bind_task_source(FullRuntime&, const FullOwnerSpec& expected);
Check full_load_weight(FullRuntime&, WeightKey, BufferRef next_ref,
                       TaskDone& done);
Check full_recycle_request(FullRuntime&);
Check full_soft_reset(FullRuntime&, uint64_t new_generation);
Check full_execute_request(FullRuntime&);
Check full_write_result(FullRuntime&, Check result, bool accepted,
                        uint8_t error_stage, uint8_t error_op,
                        uint32_t error_task_id, BufferRef candidate,
                        BufferRef act);

// These are distinct typed tasks; no generic host-supplied command/payload
// union is interpreted by the kernel. The returned Check and TaskDone agree.
Check full_run_task(FullRuntime&, const EmbeddingTask&, TaskDone&);
Check full_run_task(FullRuntime&, const LayerNormTask&, TaskDone&);
Check full_run_task(FullRuntime&, const QuantTask&, TaskDone&);
Check full_run_task(FullRuntime&, const LinearTask&, TaskDone&);
Check full_run_task(FullRuntime&, const RopeTask&, TaskDone&);
Check full_run_task(FullRuntime&, const QKTask&, TaskDone&);
Check full_run_task(FullRuntime&, const SoftmaxTask&, TaskDone&);
Check full_run_task(FullRuntime&, const AVTask&, TaskDone&);
Check full_run_task(FullRuntime&, const FPLinearTask&, TaskDone&);
Check full_run_task(FullRuntime&, const VectorTask&, TaskDone&);
Check full_run_task(FullRuntime&, const GatherTask&, TaskDone&);
Check full_run_task(FullRuntime&, const StatsTask&, TaskDone&);
Check full_run_task(FullRuntime&, const ConcatActTask&, TaskDone&);
Check full_run_task(FullRuntime&, const LoadTask&, TaskDone&);

} // namespace laya::full
