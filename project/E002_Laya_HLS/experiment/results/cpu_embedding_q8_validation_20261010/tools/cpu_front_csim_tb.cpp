#include "laya_full_runtime.h"
#include "laya_frontend_observed.h"
#include "laya_model_layout_generated.h"

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;
namespace fo = laya::full::front_observed;

extern "C" void laya_cpu_embedding_ln_chain(
    const uint8_t*, const uint8_t*, const uint8_t*, uint8_t*, uint32_t*);

namespace {
void require(bool test, const char* message) {
  if (!test) { std::cerr << "CPU_FRONT_CSIM_FAIL " << message << '\n'; std::exit(1); }
}
std::vector<uint8_t> read(const char* path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "open input");
  return {std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
}
uint32_t crc32c(const uint8_t* data, size_t size, size_t zero = SIZE_MAX) {
  uint32_t crc = 0xffffffffu;
  for (size_t i = 0; i < size; ++i) {
    crc ^= i >= zero && i < zero + 4 ? 0 : data[i];
    for (unsigned bit = 0; bit < 8; ++bit)
      crc = (crc >> 1) ^ (crc & 1 ? 0x82f63b78u : 0u);
  }
  return crc ^ 0xffffffffu;
}
void put16(uint8_t* p, uint16_t x) {
  p[0] = uint8_t(x); p[1] = uint8_t(x >> 8);
}
void put32(uint8_t* p, uint32_t x) {
  for (unsigned i = 0; i < 4; ++i) p[i] = uint8_t(x >> (8 * i));
}
void put64(uint8_t* p, uint64_t x) {
  for (unsigned i = 0; i < 8; ++i) p[i] = uint8_t(x >> (8 * i));
}
uint64_t get64(const uint8_t* p) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i) value |= uint64_t(p[i]) << (8 * i);
  return value;
}
uint32_t get32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
void descriptor(std::vector<uint8_t>& io, const std::vector<uint8_t>& raw,
                uint16_t B, uint16_t S, uint32_t frame_bytes) {
  uint8_t* p = io.data() + 20480;
  std::memset(p, 0, 256);
  std::memcpy(p, "LYER", 4);
  put16(p + 4, 1); put16(p + 6, 256); put32(p + 8, 1);
  put64(p + 16, get64(io.data() + 24));
  put64(p + 24, get64(io.data() + 32));
  std::memcpy(p + 32, io.data() + 40, 64);
  put16(p + 96, B); put16(p + 98, S);
  put16(p + 100, 1024); put16(p + 102, 1);
  put32(p + 120, 4096); put32(p + 124, 4194304);
  put64(p + 128, uint64_t(B) * S * 4096);
  put64(p + 136, uint64_t(B - 1) * 4194304 + uint64_t(S) * 4096);
  put32(p + 144, frame_bytes);
  put32(p + 148, crc32c(io.data(), frame_bytes));
  put32(p + 152, crc32c(raw.data(), raw.size()));
  put32(p + 156, crc32c(p, 256, 156));
}
} // namespace

int main(int argc, char** argv) {
  require(argc == 5 || argc == 6,
          "usage PACKAGE REQUEST STATE0 NORM_GOLD [HOST_IO]");
  const std::string package = argv[1];
  auto aux = read((package + "/aux.bin").c_str());
  const auto request = read(argv[2]);
  auto state0 = read(argv[3]);
  const auto norm_gold = read(argv[4]);
  require(request.size() == 1152 && state0.size() == 16920576 &&
          norm_gold.size() == 524288, "B1/S128 input lengths");
  std::vector<uint8_t> io(32768, 0xa5);
  std::memcpy(io.data(), request.data(), request.size());
  if (argc == 6)
    require(std::memcmp(request.data() + 40, aux.data() + 32, 64) == 0,
            "new request identity matches model package");
  std::memcpy(io.data() + 40, aux.data() + 32, 64);
  const auto raw = std::vector<uint8_t>(state0.begin(), state0.begin() + 524288);
  descriptor(io, raw, 1, 128, uint32_t(request.size()));
  if (argc == 6) {
    const auto host_io = read(argv[5]);
    require(host_io == io,
            "Host-produced LYER/CRC/full IO image matches independent builder");
    io = host_io;
  }
  const auto protected_io = io;
  const auto protected_aux = aux;
  const auto protected_state0 = state0;
  std::vector<uint8_t> state1(16919104u, 0xa5);
  static full::FullRuntime rt;
  auto& memory = rt.memory;
  memory.io = io.data(); memory.io_bytes = io.size();
  memory.aux = aux.data(); memory.aux_bytes = aux.size();
  memory.state0 = state0.data(); memory.state0_bytes = state0.size();
  memory.state1 = state1.data(); memory.state1_bytes = state1.size();
  full::FullOwnerSpec output;
  const Check result = full::full_execute_cpu_frontend(rt, memory, output);
  if (!result) {
    std::cerr << "status=" << uint16_t(result.code) << " detail=" << result.detail
              << " phase=" << unsigned(rt.cpu_import.reached_phase) << '\n';
  }
  require(bool(result) && result.bad_element == UINT64_MAX,
          "CPU frontend success");
  require(io == protected_io && aux == protected_aux &&
          state0 == protected_state0, "read-only inputs unchanged");
  require(rt.tasks_retired == 9 && rt.last_task_id == 9 &&
          rt.op_calls[uint8_t(Op::EMB_TOKEN)] == 0 &&
          rt.op_calls[uint8_t(Op::LOAD_LN_PARAMS)] == 1 &&
          rt.op_calls[uint8_t(Op::LN_EMB)] == 8 &&
          rt.owner_claims == 3 && rt.owner_leases == 0,
          "fixed task and owner counts");
  const auto& d = rt.cpu_import;
  require(d.descriptor_valid && d.admitted && d.imports_started &&
          d.imports_committed && d.raw_verified && d.scan_complete &&
          d.reached_phase == 8 && d.raw_elements_scanned == 131072 &&
          d.raw_bytes_scanned == 524288 && d.import_rows_covered == 128 &&
          d.expected_raw_crc == d.actual_raw_crc && d.request_crc_valid &&
          d.descriptor_crc_valid, "CPU import diagnostics");
  require(output.ref.id == Buffer::HIDDEN && output.ref.bank == 1 &&
          output.ref.epoch == 1 && output.rows == 128,
          "published HIDDEN1 output spec");
  require(std::equal(norm_gold.begin(), norm_gold.end(), state1.begin()),
          "embedding_norm independent gold bits");
  require(std::all_of(state1.begin() + norm_gold.size(), state1.end(),
                      [](uint8_t byte) { return byte == 0xa5; }),
          "STATE1 outside output unchanged");

  // Every descriptor rejection uses a prospective ID 4. The earlier
  // accepted session and owner identities must survive all of them.
  struct RejectCase {
    uint16_t reason; Status status; uint32_t offset; uint8_t value;
  };
  const RejectCase cases[] = {
      {2, Status::E_ABI, 0, 'X'},
      {3, Status::E_ABI, 4, 2},
      {4, Status::E_ABI, 12, 1},
      {5, Status::E_ABI, 156, 1},
      {6, Status::E_PROTOCOL, 16, 5},
      {7, Status::E_MODEL, 32, uint8_t(io[20480 + 32] ^ 1)},
      {8, Status::E_ABI, 48, uint8_t(io[20480 + 48] ^ 1)},
      {9, Status::E_SHAPE, 96, 2},
      {10, Status::E_ABI, 102, 2},
      {11, Status::E_BUFFER, 112, 1},
      {12, Status::E_BUFFER, 128, 1},
      {13, Status::E_BUFFER, 144, 1},
      {14, Status::E_ABI, 148, 1},
  };
  auto prospective = [&](uint64_t id) {
    io = protected_io;
    put64(io.data() + 24, id);
    descriptor(io, raw, 1, 128, uint32_t(request.size()));
  };
  auto expect_reject = [&](Status status, uint16_t reason, uint32_t offset) {
    full::FullOwnerSpec rejected;
    const Check failed = full::full_execute_cpu_frontend(rt, memory, rejected);
    require(failed.code == status &&
            failed.detail == detail(0x0a, 0x01, reason) &&
            failed.bad_element == UINT64_MAX &&
            rt.cpu_import.descriptor_error_offset == offset &&
            rt.cpu_import.first_error_stage == 1 &&
            rt.cpu_import.first_error_operator == uint8_t(Op::IO_VALIDATE) &&
            rt.cpu_import.first_error_task_id == 0 &&
            !rt.cpu_import.admitted && !rt.cpu_import.imports_started &&
            rt.tasks_retired == 0 && rt.owner_claims == 0 &&
            !rt.cpu_import.cleanup_attempted &&
            rt.session_generation == 1 && rt.last_accepted_request_id == 3 &&
            rt.inputs.identity.request_id == 3 &&
            rejected.ref.id == Buffer::NONE,
            "descriptor reject preserves prior session and owners");
  };
  prospective(4);
  memory.io_bytes = 20480 + 255;
  expect_reject(Status::E_BUFFER, 1, 0);
  memory.io_bytes = io.size();
  for (const auto& test : cases) {
    prospective(4);
    uint8_t* p = io.data() + 20480;
    p[test.offset] = test.reason == 5 ? uint8_t(p[test.offset] ^ 1) :
                     test.value;
    if (test.reason != 5) put32(p + 156, crc32c(p, 256, 156));
    expect_reject(test.status, test.reason, test.offset);
  }
  prospective(4);
  memory.state0_bytes = 524287;
  expect_reject(Status::E_BUFFER, 12, 136);
  memory.state0_bytes = state0.size();
  full::FullOwnerSpec failed_output;
  prospective(4);
  io[0] = 'X';
  io[20480] = 'X';
  failed_output = full::FullOwnerSpec{};
  Check parse_failed = full::full_execute_cpu_frontend(rt, memory,
                                                        failed_output);
  require(parse_failed.code == Status::E_ABI &&
          parse_failed.detail == detail(1, 0, 1) &&
          rt.cpu_import.first_error_stage == 0 &&
          rt.cpu_import.first_error_operator == 0 &&
          rt.cpu_import.reached_phase == 0 &&
          rt.last_accepted_request_id == 3,
          "LYRQ parse error wins over descriptor error");
  prospective(3);
  io[20480] = 'X';
  parse_failed = full::full_execute_cpu_frontend(rt, memory, failed_output);
  require(parse_failed.code == Status::E_PROTOCOL &&
          parse_failed.detail == detail(1, 24, 4) &&
          rt.cpu_import.first_error_stage == 0 &&
          rt.last_accepted_request_id == 3,
          "session monotonicity wins over descriptor error");

  // A valid descriptor admits ID 4. A nonfinite element must consume the
  // ID, stop at the first bad F32, and clean its uncommitted owner.
  prospective(4);
  const uint8_t saved[4] = {state0[4092], state0[4093],
                            state0[4094], state0[4095]};
  put32(state0.data() + 4092, 0x7f800000u);
  Check failed = full::full_execute_cpu_frontend(rt, memory, failed_output);
  std::memcpy(state0.data() + 4092, saved, 4);
  require(failed.code == Status::E_NUMERICAL &&
          failed.detail == detail(0x0a, 0x01, 15) &&
          failed.bad_element == 1023 &&
          rt.last_accepted_request_id == 4 && rt.cpu_import.admitted &&
          rt.cpu_import.imports_started && !rt.cpu_import.imports_committed &&
          rt.cpu_import.raw_elements_scanned == 1024 &&
          rt.cpu_import.raw_bytes_scanned == 4096 &&
          !rt.cpu_import.scan_complete && !rt.cpu_import.raw_verified &&
          rt.cpu_import.import_bad_element == 1023 &&
          rt.cpu_import.cleanup_attempted &&
          rt.cpu_import.cleanup_completed && rt.owner_claims == 1 &&
          rt.tasks_retired == 0 && failed_output.ref.id == Buffer::NONE,
          "nonfinite raw first cause and cleanup");

  prospective(5);
  uint8_t* p = io.data() + 20480;
  p[152] ^= 1;
  put32(p + 156, crc32c(p, 256, 156));
  failed = full::full_execute_cpu_frontend(rt, memory, failed_output);
  require(failed.code == Status::E_ABI &&
          failed.detail == detail(0x0a, 0x01, 16) &&
          failed.bad_element == UINT64_MAX &&
          rt.last_accepted_request_id == 5 &&
          rt.cpu_import.scan_complete && !rt.cpu_import.raw_verified &&
          rt.cpu_import.raw_elements_scanned == 131072 &&
          rt.cpu_import.import_rows_covered == 0 &&
          rt.cpu_import.cleanup_completed && rt.owner_claims == 1 &&
          rt.tasks_retired == 0,
          "complete finite raw CRC failure consumes ID");

  prospective(6);
  const uint8_t saved_gamma[4] = {aux[128], aux[129], aux[130], aux[131]};
  put32(aux.data() + 128, 0x7f800000u);
  failed = full::full_execute_cpu_frontend(rt, memory, failed_output);
  std::memcpy(aux.data() + 128, saved_gamma, 4);
  require(failed.code == Status::E_NUMERICAL &&
          failed.detail == detail(7, uint8_t(Op::LOAD_LN_PARAMS), 15) &&
          rt.last_accepted_request_id == 6 &&
          rt.cpu_import.imports_committed && rt.cpu_import.raw_verified &&
          rt.cpu_import.reached_phase == 6 &&
          rt.cpu_import.first_error_task_id == 1 &&
          rt.cpu_import.first_error_operator == uint8_t(Op::LOAD_LN_PARAMS) &&
          rt.cpu_import.cleanup_completed && rt.owner_claims == 2 &&
          rt.tasks_retired == 1 && rt.last_task_id == 1 &&
          rt.op_calls[uint8_t(Op::EMB_TOKEN)] == 0 &&
          rt.op_calls[uint8_t(Op::LN_EMB)] == 0,
          "gamma numerical first cause after committed import");

  prospective(7);
  full::FullOwnerSpec recovery;
  const Check recovered = full::full_execute_cpu_frontend(rt, memory, recovery);
  full::FullOwnerRecord hidden0;
  const Check hidden0_check = full::full_owner_snapshot(
      rt, {Buffer::HIDDEN, 0, 5}, 0, hidden0);
  if (!recovered || rt.last_accepted_request_id != 7 ||
      rt.tasks_retired != 9 || rt.owner_claims != 3 ||
      rt.cpu_import.reached_phase != 8 || recovery.ref.epoch != 2) {
    std::cerr << "recovery status=" << uint16_t(recovered.code)
              << " detail=" << recovered.detail
              << " accepted=" << rt.last_accepted_request_id
              << " tasks=" << rt.tasks_retired
              << " claims=" << rt.owner_claims
              << " phase=" << unsigned(rt.cpu_import.reached_phase)
              << " epoch=" << recovery.ref.epoch << '\n';
  }
  require(bool(recovered) && rt.last_accepted_request_id == 7 &&
          rt.tasks_retired == 9 && rt.owner_claims == 3 &&
          rt.cpu_import.reached_phase == 8 &&
          recovery.ref.epoch == 2 &&
          bool(hidden0_check) && hidden0.ref.epoch == 5 &&
          hidden0.state == CacheState::FREE &&
          std::equal(norm_gold.begin(), norm_gold.end(), state1.begin()),
          "larger ID recovers after raw and gamma failures");

  // The production five-port top has its own cold runtime. Observe its
  // complete CFO1 ABI and guard without reaching through a CSim-only hook.
  auto top_io = protected_io;
  auto top_state1 = std::vector<uint8_t>(16919104u, 0xa5);
  auto top_state0 = protected_state0;
  const auto top_io_original = top_io;
  std::vector<uint32_t> obs(fo::kCpuWords + 1, 0xa5a5a5a5u);
  laya_cpu_embedding_ln_chain(top_io.data(), aux.data(), top_state0.data(),
                              top_state1.data(), obs.data());
  require(obs[fo::MAGIC] == fo::kCpuMagic &&
          obs[fo::VERSION] == fo::kVersion &&
          obs[fo::WORDS] == fo::kCpuWords &&
          obs[fo::STATUS] == 0 && obs[fo::DETAIL] == 0 &&
          obs[fo::BAD_ELEMENT_LO] == UINT32_MAX &&
          obs[fo::BAD_ELEMENT_HI] == UINT32_MAX &&
          obs[fo::TASKS_RETIRED] == 9 && obs[fo::LAST_TASK_ID] == 9 &&
          obs[fo::OWNER_CLAIMS] == 3 && obs[fo::OWNER_LEASES] == 0 &&
          obs[fo::EMB_TOKEN_CALLS] == 0 &&
          obs[fo::LOAD_LN_PARAMS_CALLS] == 1 &&
          obs[fo::LN_EMB_CALLS] == 8 &&
          obs[fo::PROFILE] == 1 && obs[fo::DESCRIPTOR_VALID] == 1 &&
          obs[fo::ADMITTED] == 1 && obs[fo::IMPORTS_STARTED] == 1 &&
          obs[fo::IMPORTS_COMMITTED] == 1 && obs[fo::RAW_VERIFIED] == 1 &&
          obs[fo::SCAN_COMPLETE] == 1 &&
          obs[fo::RAW_ELEMENTS_LO] == 131072 &&
          obs[fo::RAW_BYTES_LO] == 524288 &&
          obs[fo::IMPORT_ROWS_COVERED] == 128 &&
          obs[fo::REACHED_PHASE] == 8 &&
          obs[fo::DESCRIPTOR_ERROR_OFFSET] == UINT32_MAX &&
          obs[fo::IMPORT_BAD_ELEMENT_LO] == UINT32_MAX &&
          obs[fo::IMPORT_BAD_ELEMENT_HI] == UINT32_MAX &&
          obs[fo::OUTPUT_ID] == uint8_t(Buffer::HIDDEN) &&
          obs[fo::OUTPUT_BANK] == 1 && obs[fo::OUTPUT_EPOCH] == 1 &&
          obs[fo::LIVE_READERS] == 0 && obs[fo::INCOMPLETE_OWNERS] == 0 &&
          obs[fo::kCpuWords] == 0xa5a5a5a5u,
          "five-port CFO1 diagnostics and guard");
  auto owner_field = [&](unsigned ordinal, unsigned field) {
    return obs[fo::kGlobalWords + ordinal * fo::kOwnerWords + field];
  };
  for (unsigned ordinal = 0; ordinal < 3; ++ordinal) {
    const Buffer id = ordinal == 1 ? Buffer::LN_GAMMA : Buffer::HIDDEN;
    const unsigned bank = ordinal == 2 ? 1 : 0;
    require(owner_field(ordinal, fo::FOUND) == 1 &&
            owner_field(ordinal, fo::REF_ID) == uint8_t(id) &&
            owner_field(ordinal, fo::REF_BANK) == bank &&
            owner_field(ordinal, fo::REF_EPOCH) == 1 &&
            owner_field(ordinal, fo::MAX_CLAIMED_EPOCH) == 1 &&
            owner_field(ordinal, fo::REGION) == 0 &&
            owner_field(ordinal, fo::STAGE) == 1 &&
            owner_field(ordinal, fo::LAYER) == 255 &&
            owner_field(ordinal, fo::BATCH) == (ordinal == 1 ? 0 : 255) &&
            owner_field(ordinal, fo::ROW_SPACE) ==
                uint8_t(ordinal == 1 ? RowSpace::BATCH : RowSpace::TOKEN) &&
            owner_field(ordinal, fo::ROW0) == 0 &&
            owner_field(ordinal, fo::ROWS) == (ordinal == 1 ? 1 : 128) &&
            owner_field(ordinal, fo::WIDTH) == 1024 &&
            owner_field(ordinal, fo::CONTENT) == uint8_t(Content::F32) &&
            owner_field(ordinal, fo::READERS) == 0 &&
            owner_field(ordinal, fo::VALID) == (ordinal != 0) &&
            owner_field(ordinal, fo::STATE) == uint8_t(
                ordinal == 0 ? CacheState::FREE : CacheState::READY) &&
            owner_field(ordinal, fo::IDENTITY_B) == 1 &&
            owner_field(ordinal, fo::IDENTITY_S) == 128 &&
            owner_field(ordinal, fo::IDENTITY_REQUEST_LO) == 3 &&
            owner_field(ordinal, fo::IDENTITY_REQUEST_HI) == 0 &&
            owner_field(ordinal, fo::IDENTITY_GENERATION_LO) == 1 &&
            owner_field(ordinal, fo::IDENTITY_GENERATION_HI) == 0,
            "CFO1 owner spec, state and identity");
    for (unsigned word = 0; word < 4; ++word) {
      require(owner_field(ordinal, fo::MODEL_TAG0 + word) ==
                  get32(top_io.data() + 40 + 4 * word) &&
              owner_field(ordinal, fo::NUMERIC_TAG0 + word) ==
                  get32(top_io.data() + 56 + 4 * word) &&
              owner_field(ordinal, fo::LAYOUT_TAG0 + word) ==
                  get32(top_io.data() + 72 + 4 * word) &&
              owner_field(ordinal, fo::BUILD_TAG0 + word) ==
                  get32(top_io.data() + 88 + 4 * word),
              "CFO1 complete four-tag owner identity");
    }
    for (unsigned word = 0; word < 64; ++word) {
      const uint32_t expected = ordinal == 2 && word < 4 ? UINT32_MAX :
                                ordinal == 1 && word == 0 ? 1u : 0u;
      require(owner_field(ordinal, fo::COVERAGE0 + word) == expected,
              "CFO1 owner coverage");
    }
  }
  require(owner_field(0, fo::SLOT) != owner_field(1, fo::SLOT) &&
          owner_field(0, fo::SLOT) != owner_field(2, fo::SLOT) &&
          owner_field(1, fo::SLOT) != owner_field(2, fo::SLOT),
          "three owner slots discovered independently");
  require(top_io == top_io_original && aux == protected_aux &&
          top_state0 == protected_state0 &&
          std::equal(norm_gold.begin(), norm_gold.end(), top_state1.begin()) &&
          std::all_of(top_state1.begin() + norm_gold.size(), top_state1.end(),
                      [](uint8_t byte) { return byte == 0xa5; }),
          "five-port input protection and output mapping");
  std::cout << "CPU_FRONT_CSIM_PASS tasks=9 raw_f32=131072 norm_f32=131072 "
               "claims=3 descriptor_reasons=1..14 raw_reasons=15..16 "
               "persistent_recovery_id=7\n";
}
