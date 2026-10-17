#include "laya_full_cache_storage.h"

#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <vector>

// Compile this exact driver against the frozen f1a tree and the follow-on
// tree. The old tree has no indexed API, so its non-null optional API is the
// reference for that one call. All other calls use identical API forms.
namespace {
using namespace laya;
using namespace laya::full;

FILE* output;
unsigned lookup_cases = 0, qk_cases = 0;
constexpr uint64_t kQkvBytes = 12ull << 20;
std::vector<uint8_t> qkv0(kQkvBytes, 0);

void require(bool condition, const char* message) {
  if (!condition) {
    std::fprintf(stderr, "FULL_POINTER_CONTROL_DIFF_FAIL %s\n", message);
    std::exit(1);
  }
}
template<class T> void emit(const T& value) {
  require(std::fwrite(&value, sizeof(value), 1, output) == 1, "write scalar");
}
void emit_bytes(const void* bytes, size_t count) {
  require(std::fwrite(bytes, 1, count, output) == count, "write bytes");
}
void emit_check(Check c) {
  emit(uint16_t(c.code)); emit(c.detail); emit(c.bad_element);
}
void emit_ref(BufferRef r) {
  emit(uint8_t(r.id)); emit(r.bank); emit(r.epoch);
}
void emit_descriptor(const FullTensorDescriptor& d) {
  emit_bytes(d.name, sizeof(d.name));
  emit(d.ggml_type_id); emit(d.bo); emit(d.omitted); emit(d.reserved);
  emit_bytes(d.ne, sizeof(d.ne));
  emit(d.source_offset); emit(d.source_bytes); emit(d.base); emit(d.span);
  emit_bytes(d.source_sha256, sizeof(d.source_sha256));
}
void run_lookup(const char* name, bool known, uint16_t expected_index) {
  FullTensorDescriptor baseline{};
  if (known) {
    Check c = full_tensor_descriptor(expected_index, baseline);
    require(bool(c) && std::strcmp(baseline.name, name) == 0,
            "known tensor name and index");
  }
  for (unsigned form = 0; form < 4; ++form) {
    FullTensorDescriptor descriptor;
    std::memset(&descriptor, 0xa5, sizeof(descriptor));
    const FullTensorDescriptor sentinel = descriptor;
    uint16_t index = 0xa55a;
    Check c;
    if (form == 0) {
#ifdef FOLLOWON_REQUIRED_INDEX
      c = full_lookup_tensor_indexed(name, descriptor, index);
#else
      c = full_lookup_tensor(name, descriptor, &index);
#endif
    } else if (form == 1) {
      c = full_lookup_tensor(name, descriptor);
    } else if (form == 2) {
      c = full_lookup_tensor(name, descriptor, nullptr);
    } else {
      c = full_lookup_tensor(name, descriptor, &index);
    }
    if (known) {
      require(bool(c) && std::memcmp(&descriptor, &baseline,
                                    sizeof(descriptor)) == 0,
              "successful descriptor equals indexed table entry");
      require((form != 0 && form != 3) || index == expected_index,
              "successful non-null index equals table position");
    } else {
      require(c.code == Status::E_MODEL &&
              std::memcmp(&descriptor, &sentinel, sizeof(descriptor)) == 0 &&
              index == 0xa55a, "failed lookup preserves both sentinels");
    }
    emit(uint8_t(0x4c)); emit(uint8_t(form));
    emit(uint8_t(known)); emit(expected_index);
    emit_check(c); emit_descriptor(descriptor); emit(index);
    ++lookup_cases;
  }
}
void ready_record(FullRuntime& rt, unsigned slot, BufferRef ref,
                  Content content, uint8_t layer, uint16_t S) {
  FullOwnerRecord& record = rt.owners.record[slot];
  record = FullOwnerRecord{};
  record.identity = rt.inputs.identity;
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
void emit_owner(const FullOwnerRecord& r) {
  emit_ref(r.ref); emit_ref(r.lease_old_ref);
  emit(r.max_claimed_epoch); emit(r.region); emit(r.stage); emit(r.layer);
  emit(r.batch); emit(uint8_t(r.row_space)); emit(r.row0); emit(r.rows);
  emit(r.width); emit(uint8_t(r.content)); emit(uint8_t(r.state));
  emit(r.readers); emit(uint8_t(r.valid));
  emit_bytes(r.covered_rows, sizeof(r.covered_rows));
  emit_bytes(r.old_consumed_rows, sizeof(r.old_consumed_rows));
}
void emit_done(const TaskDone& done) {
  emit(done.task_id); emit(uint16_t(done.status));
  emit(done.error_detail); emit(done.bad_element);
  emit(done.output_elements); emit(done.output_beats);
  emit(uint8_t(done.output_unit)); emit(uint8_t(done.drained));
}
void write_query_one(uint8_t batch, uint16_t row) {
  const uint64_t offset = ((uint64_t(batch) * 8 * 1024 + row) * 64) * 4;
  require(offset + 8 <= qkv0.size(), "query address");
  const uint32_t one = 0x3f800000u, half = 0x3f000000u;
  std::memcpy(qkv0.data() + offset, &one, 4);
  std::memcpy(qkv0.data() + offset + 4, &half, 4);
}
void run_qk(unsigned case_id, uint8_t batch, uint16_t S,
            uint8_t layer, uint16_t row0, uint8_t rows, uint8_t fault) {
  auto rt = std::make_unique<FullRuntime>();
  NumericIdentity identity{};
  identity.request_id = 1; identity.generation = 1;
  identity.B = 2; identity.S = S;
  identity.model_tag[0] = 1; identity.numeric_tag[0] = 2;
  identity.layout_tag[0] = 3; identity.build_tag[0] = 4;
  rt->inputs.identity = identity;
  rt->request_valid = true; rt->model_header_valid = true;
  std::fill(qkv0.begin(), qkv0.end(), 0);
  for (unsigned b = 0; b < 2; ++b)
    for (unsigned key = 0; key < S; ++key)
      rt->inputs.attention_mask[b][key] =
          uint8_t((key + b) % 3 == 0 ? 0 : 1);
  if (fault == 1) rt->inputs.attention_mask[batch][7] = 2;
  ready_record(*rt, 0, {Buffer::QKV, 0, 1}, Content::QKV_FINAL, layer, S);
  ready_record(*rt, 1, {Buffer::QKV, 1, 1}, Content::QKV_FINAL, layer, S);
  ready_record(*rt, 2, {Buffer::KV, 0, 1}, Content::F32, layer, S);
  if (fault == 2) rt->owners.record[0].readers = UINT8_MAX;
  if (fault == 3) rt->owners.record[2].readers = UINT8_MAX;
  rt->final_qkv_ref[0] = {Buffer::QKV, 0, 1};
  rt->final_qkv_ref[1] = {Buffer::QKV, 1, 1};
  rt->loaded_kv_ref = {Buffer::KV, 0, 1};
  rt->loaded_kv_head = 0;
  for (unsigned b = 0; b < 2; ++b)
    for (unsigned key = 0; key < S; ++key) {
      full_cache_kv(*rt)[0][b][key][0] = float(int(key % 7) - 3);
      full_cache_kv(*rt)[0][b][key][1] = 0.25f;
    }
  for (unsigned b = 0; b < 2; ++b)
    for (unsigned r = 0; r < 16; ++r)
      for (unsigned key = 0; key < 1024; ++key)
        full_cache_score(*rt)[b][r][key] = 7.0f;
  for (unsigned r = 0; r < rows; ++r)
    write_query_one(batch, uint16_t(row0 + r));
  FullMemory memory{};
  memory.qkv0 = qkv0.data();
  memory.qkv0_bytes = fault == 4 ? 0 : kQkvBytes;
  QKTask task{};
  task.ctx = {1, Op::QK, 2, layer, batch, RowSpace::TOKEN, row0, rows};
  task.qkv_ref = {rt->final_qkv_ref[0], rt->final_qkv_ref[1]};
  task.kv = rt->loaded_kv_ref;
  task.score = {Buffer::SCORE_PROB, 0, 1};
  task.head = 0;
  task.mask_mode = layer % 3 == 0 ? 0 : 1;
  task.S = S;
  TaskDone done;
  Check c = full_run_task(*rt, memory, task, done);
  emit(uint8_t(0x51)); emit(uint8_t(case_id)); emit_check(c);
  emit_done(done);
  emit_bytes(full_cache_score(*rt), sizeof(FullCacheScore));
  emit(rt->last_task_id); emit(rt->tasks_retired);
  emit(rt->op_calls[uint8_t(Op::QK)]);
  emit(rt->owner_claims); emit(rt->owner_leases);
  emit(uint8_t(rt->score_valid)); emit_ref(rt->score_ref);
  emit_ref(rt->score_kv_ref);
  emit_ref(rt->score_qkv_ref[0]); emit_ref(rt->score_qkv_ref[1]);
  emit(rt->score_head); emit(rt->score_stage); emit(rt->score_layer);
  emit(rt->score_batch); emit(rt->score_row0); emit(rt->score_rows);
  for (const FullOwnerRecord& record : rt->owners.record) emit_owner(record);
  std::printf("QK case=%u code=%u detail=%u bad=%llu elements=%u\n",
              case_id, unsigned(c.code), c.detail,
              static_cast<unsigned long long>(c.bad_element),
              done.output_elements);
  ++qk_cases;
}
} // namespace

int main(int argc, char** argv) {
  require(argc == 2, "usage: full_pointer_control_diff OUTPUT");
  output = std::fopen(argv[1], "wb");
  require(output != nullptr, "open output");
  for (uint16_t i = 0; i < 153; ++i) {
    FullTensorDescriptor descriptor{};
    require(bool(full_tensor_descriptor(i, descriptor)), "tensor index");
    run_lookup(descriptor.name, true, i);
  }
  run_lookup("scorer_fc1.bias", true, 133);
  run_lookup("act_fc1.bias", true, 137);
  run_lookup("missing.tensor", false, UINT16_MAX);
  run_lookup("", false, UINT16_MAX);
  run_lookup(nullptr, false, UINT16_MAX);
  run_qk(0, 0, 64, 0, 0, 1, 0);
  run_qk(1, 1, 128, 1, 7, 2, 0);
  run_qk(2, 0, 256, 0, 18, 4, 0);
  run_qk(3, 1, 512, 1, 65, 3, 0);
  run_qk(4, 1, 1024, 1, 1008, 16, 0);
  run_qk(5, 0, 128, 0, 12, 2, 1);
  run_qk(6, 1, 64, 1, 15, 1, 1);
  run_qk(7, 0, 64, 0, 0, 1, 2);
  run_qk(8, 0, 64, 0, 0, 1, 3);
  run_qk(9, 0, 64, 0, 0, 1, 4);
  run_qk(10, 0, 64, 0, 0, 0, 5);
  require(std::fclose(output) == 0, "close output");
  std::printf("FULL_POINTER_CONTROL_DIFF_PASS lookup=%u qk=%u\n",
              lookup_cases, qk_cases);
}
