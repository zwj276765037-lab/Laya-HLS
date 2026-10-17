#include "laya_full_cache_storage.h"
#include "laya_full_runtime.h"

// Include the production controller once so the pilot can exercise its
// otherwise translation-unit-local scans. Its .cpp is not a separate syn.file.
#include "full_forward_controller.cpp"

namespace {
using namespace laya;
using namespace laya::full;

FullRuntime runtime;

void ready_record(unsigned slot, BufferRef ref, Content content,
                  uint8_t layer, uint16_t S) {
  FullOwnerRecord& record = runtime.owners.record[slot];
  record = FullOwnerRecord{};
  record.identity = runtime.inputs.identity;
  record.ref = ref;
  record.max_claimed_epoch = ref.epoch;
  record.stage = 2;
  record.layer = layer;
  record.batch = 255;
  record.row_space = RowSpace::TOKEN;
  record.rows = S;
  record.width = 64;
  record.content = content;
  record.state = CacheState::READY;
  record.valid = true;
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned row = 0; row < S; ++row) {
      const unsigned bit = batch * 1024 + row;
      record.covered_rows[bit / 32] |= uint32_t(1) << (bit % 32);
    }
}

void run_controller(uint8_t first_match, uint8_t busy,
                    uint32_t epoch, uint32_t out[14]) {
  for (unsigned i = 0; i < 32; ++i)
    runtime.owners.record[i] = FullOwnerRecord{};
  FullOwnerRecord& first = runtime.owners.record[0];
  if (first_match) {
    first.ref = {Buffer::HIDDEN, 0, 1};
    first.max_claimed_epoch = epoch;
    first.state = CacheState::READY;
  }
  FullOwnerRecord& later = runtime.owners.record[30];
  later.ref = {Buffer::HIDDEN, 0, 2};
  later.max_claimed_epoch = 9;
  later.state = CacheState::READY;
  FullOwnerRecord& incomplete = runtime.owners.record[31];
  incomplete.ref = {Buffer::WI, 0, 1};
  incomplete.state = CacheState::FILL;
  if (busy) {
    FullOwnerRecord& reader = runtime.owners.record[1];
    reader.ref = {Buffer::GATE, 0, 1};
    reader.state = CacheState::READ;
    reader.readers = 1;
  }
  FullMemory memory{};
  Controller controller{runtime, memory};
  const BufferRef next = controller.fresh(Buffer::HIDDEN, 0, 0);
  const Check result = controller.invalidate_incomplete();
  out[0] = uint32_t(result.code);
  out[1] = result.detail;
  out[11] = uint32_t(incomplete.state);
  out[13] = next.epoch;
}

void run_lookup(uint8_t choice, uint32_t out[14]) {
  FullTensorDescriptor descriptor;
  uint16_t index = 65535;
  const Check result = choice ?
      full_lookup_tensor_indexed("act_fc1.bias", descriptor, index) :
      full_lookup_tensor_indexed("scorer_fc1.bias", descriptor, index);
  out[0] = uint32_t(result.code);
  out[1] = result.detail;
  out[8] = descriptor.span;
  out[12] = index;
}

void run_qk(uint8_t batch, uint16_t S, uint8_t layer,
            uint16_t row0, uint8_t rows, uint8_t fault,
            const uint8_t* qkv0, uint64_t qkv0_bytes, uint32_t out[14]) {
  NumericIdentity identity{};
  identity.request_id = 1;
  identity.generation = 1;
  identity.B = 2;
  identity.S = S;
  identity.model_tag[0] = 1;
  identity.numeric_tag[0] = 2;
  identity.layout_tag[0] = 3;
  identity.build_tag[0] = 4;
  runtime.inputs.identity = identity;
  runtime.request_valid = true;
  runtime.model_header_valid = true;
  runtime.last_task_id = 0;
  runtime.score_valid = false;
  if (S > 1024 || batch >= 2) { out[0] = UINT32_MAX; return; }
  for (unsigned b = 0; b < 2; ++b)
    for (unsigned key = 0; key < S; ++key)
      runtime.inputs.attention_mask[b][key] =
          (fault == 1 && key == 0) ? 2 : uint8_t((key & 1u) ? 0 : 1);
  ready_record(0, {Buffer::QKV, 0, 1}, Content::QKV_FINAL, layer, S);
  ready_record(1, {Buffer::QKV, 1, 1}, Content::QKV_FINAL, layer, S);
  ready_record(2, {Buffer::KV, 0, 1}, Content::F32, layer, S);
  runtime.owners.record[3] = FullOwnerRecord{};
  if (fault == 2) runtime.owners.record[0].readers = UINT8_MAX;
  if (fault == 3) runtime.owners.record[2].readers = UINT8_MAX;
  runtime.final_qkv_ref[0] = {Buffer::QKV, 0, 1};
  runtime.final_qkv_ref[1] = {Buffer::QKV, 1, 1};
  runtime.loaded_kv_ref = {Buffer::KV, 0, 1};
  runtime.loaded_kv_head = 0;
  for (unsigned d = 0; d < 64; ++d)
    full_cache_kv(runtime)[0][batch][0][d] = 0.0f;
  full_cache_kv(runtime)[0][batch][0][0] = 1.0f;
  full_cache_score(runtime)[batch][0][0] = 7.0f;

  FullMemory memory{};
  memory.qkv0 = const_cast<uint8_t*>(qkv0);
  memory.qkv0_bytes = qkv0_bytes;
  QKTask task{};
  task.ctx = {1, Op::QK, 2, layer, batch, RowSpace::TOKEN, row0, rows};
  task.qkv_ref = {runtime.final_qkv_ref[0], runtime.final_qkv_ref[1]};
  task.kv = runtime.loaded_kv_ref;
  task.score = {Buffer::SCORE_PROB, 0, 1};
  task.head = 0;
  task.mask_mode = layer % 3 == 0 ? 0 : 1;
  task.S = S;
  TaskDone done;
  const Check result = full_run_task(runtime, memory, task, done);
  out[0] = uint32_t(result.code);
  out[1] = result.detail;
  out[2] = uint32_t(result.bad_element);
  out[3] = uint32_t(result.bad_element >> 32);
  out[4] = numeric_f32_bits(full_cache_score(runtime)[batch][0][0]);
  out[5] = done.output_elements;
  out[6] = runtime.score_valid ? 1 : 0;
  out[7] = runtime.owners.record[0].readers;
  out[8] = runtime.owners.record[2].readers;
  out[9] = runtime.owner_claims;
  out[10] = numeric_f32_bits(full_cache_score(runtime)[batch][0][1]);
}
} // namespace

extern "C" void full_pointer_control_pilot(
    uint8_t mode, uint8_t batch, uint16_t S, uint8_t layer,
    uint16_t row0, uint8_t rows, uint8_t fault, uint32_t epoch,
    const uint8_t* qkv0, uint64_t qkv0_bytes, uint32_t out[14]) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE s_axilite port=mode bundle=control
#pragma HLS INTERFACE s_axilite port=batch bundle=control
#pragma HLS INTERFACE s_axilite port=S bundle=control
#pragma HLS INTERFACE s_axilite port=layer bundle=control
#pragma HLS INTERFACE s_axilite port=row0 bundle=control
#pragma HLS INTERFACE s_axilite port=rows bundle=control
#pragma HLS INTERFACE s_axilite port=fault bundle=control
#pragma HLS INTERFACE s_axilite port=epoch bundle=control
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 depth=12582912
#pragma HLS INTERFACE s_axilite port=qkv0_bytes bundle=control
#pragma HLS INTERFACE m_axi port=out offset=slave bundle=out depth=14
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  for (unsigned i = 0; i < 14; ++i) out[i] = 0;
  if (mode == 0) run_controller(batch, fault, epoch, out);
  else if (mode == 1) run_lookup(batch, out);
  else if (mode == 2) run_qk(batch, S, layer, row0, rows, fault,
                            qkv0, qkv0_bytes, out);
  else out[0] = UINT32_MAX;
}
