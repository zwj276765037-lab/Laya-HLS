#include "laya_full_runtime.h"

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;

namespace {
void fail(const std::string& message) {
  std::cerr << "FULL_FRONT_DUT_FAIL " << message << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& message) {
  if (!condition) fail(message);
}
void expect(Check check, const std::string& message) {
  if (!check)
    fail(message + " status=" + std::to_string(unsigned(check.code)) +
         " detail=" + std::to_string(check.detail));
}
std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "cannot open " + path);
  return {std::istreambuf_iterator<char>(input),
          std::istreambuf_iterator<char>()};
}
uint32_t le32(const uint8_t* bytes) {
  return uint32_t(bytes[0]) | uint32_t(bytes[1]) << 8 |
         uint32_t(bytes[2]) << 16 | uint32_t(bytes[3]) << 24;
}
void compare_rows(full::FullRuntime& rt, BufferRef ref, uint8_t region,
                  unsigned batches, unsigned rows, unsigned width,
                  const std::vector<uint8_t>& expected,
                  const char* label) {
  require(expected.size() == size_t(batches) * rows * width * 4,
          std::string(label) + " oracle byte count");
  std::vector<uint8_t> actual(width * 4);
  for (unsigned batch = 0; batch < batches; ++batch)
    for (unsigned row = 0; row < rows; ++row) {
      Address address;
      expect(full::full_f32_address(rt, ref, region, uint8_t(batch),
                                    uint16_t(row), 0, address),
             std::string(label) + " physical row address");
      expect(full::full_read(rt.memory, address.bo, address.offset,
                             actual.data(), uint32_t(actual.size())),
             std::string(label) + " physical row read");
      const uint8_t* wanted = expected.data() +
                              (size_t(batch) * rows + row) * width * 4;
      if (std::memcmp(actual.data(), wanted, actual.size()) == 0) continue;
      for (unsigned col = 0; col < width; ++col) {
        const uint32_t got = le32(actual.data() + col * 4);
        const uint32_t good = le32(wanted + col * 4);
        if (got != good)
          fail(std::string(label) + " bit mismatch batch=" +
               std::to_string(batch) + " row=" + std::to_string(row) +
               " col=" + std::to_string(col) + " expected_bits=" +
               std::to_string(good) + " actual_bits=" +
               std::to_string(got));
      }
    }
}
void done_ok(const TaskDone& done, uint32_t task_id,
             uint32_t elements, OutputUnit unit, const char* label) {
  require(done.task_id == task_id && done.status == Status::OK &&
          done.drained && done.output_elements == elements &&
          done.output_unit == unit, std::string(label) + " TaskDone");
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 7,
          "usage: full_front_dut_tb PACKAGE REQUEST RAW_EXPECT "
          "NORM_EXPECT TYPE_EXPECT OUTPUT_HINT");
  const std::string package = argv[1];
  const auto embedding = read_file(package + "/embedding.bin");
  const auto aux = read_file(package + "/aux.bin");
  auto request = read_file(argv[2]);
  const auto raw_expected = read_file(argv[3]);
  const auto norm_expected = read_file(argv[4]);
  const auto type_expected = read_file(argv[5]);
  require(request.size() == 1856 && aux.size() >= 128,
          "real B2/S128 request/model header sizes");
  std::memcpy(request.data() + 40, aux.data() + 32, 64);
  std::vector<uint8_t> io(32768, 0), state0(17u << 20, 0),
      state1(17u << 20, 0);
  std::memcpy(io.data(), request.data(), request.size());
  static full::FullRuntime rt;
  rt.memory.embedding = embedding.data();
  rt.memory.embedding_bytes = embedding.size();
  rt.memory.aux = aux.data(); rt.memory.aux_bytes = aux.size();
  rt.memory.io = io.data(); rt.memory.io_bytes = io.size();
  rt.memory.state0 = state0.data(); rt.memory.state0_bytes = state0.size();
  rt.memory.state1 = state1.data(); rt.memory.state1_bytes = state1.size();
  expect(full::full_parse_request(rt), "real request parse");
  require(rt.inputs.identity.B == 2 && rt.inputs.identity.S == 128,
          "real B2/S128 front scope");

  const full::FullOwnerSpec hidden{{Buffer::HIDDEN, 0, 1}, 0, 1, 255,
                                    255, RowSpace::TOKEN, 0, 128, 1024,
                                    Content::F32};
  expect(full::full_claim_owner(rt, hidden), "claim embedding destination");
  uint32_t task_id = 0;
  TaskDone done;
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned row0 = 0; row0 < 128; row0 += 16) {
      EmbeddingTask task{};
      task.ctx = {++task_id, Op::EMB_TOKEN, 1, 255, uint8_t(batch),
                  RowSpace::TOKEN, uint16_t(row0), 16};
      task.table = 0;
      task.dst = hidden.ref;
      expect(full::full_run_task(rt, task, done),
             "typed real token embedding tile");
      done_ok(done, task_id, 16 * 1024, OutputUnit::F32,
              "token embedding tile");
    }
  expect(full::full_publish_owner(rt, hidden),
         "publish complete B2 embedding_raw");
  compare_rows(rt, hidden.ref, 0, 2, 128, 1024, raw_expected,
               "embedding_raw");

  LoadTask gamma{};
  gamma.ctx = {++task_id, Op::LOAD_LN_PARAMS, 1, 255, 0,
               RowSpace::BATCH, 0, 1};
  gamma.kind = 2;
  gamma.dst = {Buffer::LN_GAMMA, 0, 1};
  gamma.byte_count = 4096;
  expect(full::full_run_task(rt, gamma, done),
         "typed real embedding gamma load");
  done_ok(done, task_id, 4096, OutputUnit::BYTES, "gamma load");

  const full::FullOwnerSpec norm{{Buffer::NORM, 0, 1}, 0, 1, 255,
                                  255, RowSpace::TOKEN, 0, 128, 1024,
                                  Content::F32};
  expect(full::full_claim_owner(rt, norm), "claim embedding_norm destination");
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned row0 = 0; row0 < 128; row0 += 16) {
      LayerNormTask task{};
      task.ctx = {++task_id, Op::LN_EMB, 1, 255, uint8_t(batch),
                  RowSpace::TOKEN, uint16_t(row0), 16};
      task.src = hidden.ref;
      task.dst = norm.ref;
      task.gamma = 1;
      task.D = 1024;
      expect(full::full_bind_task_source(rt, hidden),
             "bind independently published embedding source");
      expect(full::full_run_task(rt, task, done),
             "typed real embedding LayerNorm tile");
      done_ok(done, task_id, 16 * 1024, OutputUnit::F32,
              "embedding LayerNorm tile");
    }
  expect(full::full_publish_owner(rt, norm),
         "publish complete B2 embedding_norm");
  compare_rows(rt, norm.ref, 0, 2, 128, 1024, norm_expected,
               "embedding_norm");

  const full::FullOwnerSpec type_rows{{Buffer::TYPE_ROWS, 0, 1}, 0, 3, 255,
                                       0, RowSpace::BATCH, 0, 3, 1024,
                                       Content::F32};
  expect(full::full_claim_owner(rt, type_rows),
         "claim shared type embedding rows");
  for (unsigned type = 0; type < 3; ++type) {
    EmbeddingTask task{};
    task.ctx = {++task_id, Op::EMB_TYPE, 3, 255, 0,
                RowSpace::BATCH, 0, 1};
    task.table = 1;
    task.dst = type_rows.ref;
    task.type_id = uint8_t(type);
    expect(full::full_run_task(rt, task, done),
           "typed real type embedding row");
    done_ok(done, task_id, 1024, OutputUnit::F32,
            "type embedding row");
    require(rt.owners.type_valid[type],
            "type row published only after real model read and BO write");
  }
  compare_rows(rt, type_rows.ref, 0, 1, 3, 1024, type_expected,
               "type_embedding");

  // A legal-looking source label cannot substitute for the published
  // producer's stage/layer, and a consumer without a binding cannot read it.
  auto wrong_producer = hidden;
  wrong_producer.stage = 2;
  wrong_producer.layer = 0;
  expect(full::full_bind_task_source(rt, wrong_producer),
         "register wrong-stage producer counterexample");
  LayerNormTask stale{};
  stale.ctx = {++task_id, Op::LN_EMB, 1, 255, 0,
               RowSpace::TOKEN, 0, 1};
  stale.src = hidden.ref;
  stale.dst = norm.ref;
  stale.gamma = 1;
  require(full::full_run_task(rt, stale, done).code == Status::E_BUFFER &&
          done.task_id == task_id && done.drained,
          "wrong-stage producer rejected at typed task boundary");
  stale.ctx.task_id = ++task_id;
  require(full::full_run_task(rt, stale, done).code == Status::E_BUFFER &&
          done.task_id == task_id && done.drained,
          "missing source binding rejected at typed task boundary");
  EmbeddingTask duplicate{};
  duplicate.ctx = {++task_id, Op::EMB_TYPE, 3, 255, 0,
                   RowSpace::BATCH, 0, 1};
  duplicate.table = 1;
  duplicate.dst = type_rows.ref;
  duplicate.type_id = 0;
  require(full::full_run_task(rt, duplicate, done).code == Status::E_BUFFER &&
          done.task_id == task_id && done.drained,
          "duplicate type-row producer rejected before overwrite");
  compare_rows(rt, norm.ref, 0, 2, 128, 1024, norm_expected,
               "embedding_norm_after_rejected_tasks");
  compare_rows(rt, type_rows.ref, 0, 1, 3, 1024, type_expected,
               "type_embedding_after_rejected_tasks");

  std::cout << "FULL_FRONT_DUT_PASS B=2 S=128 raw_f32=262144 "
               "norm_f32=262144 type_f32=3072 tasks=" << task_id
            << " result_hint=" << argv[6] << '\n';
  return 0;
}
