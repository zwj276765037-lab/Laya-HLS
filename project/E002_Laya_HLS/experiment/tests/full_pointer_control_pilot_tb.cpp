#include "laya_types.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

extern "C" void full_pointer_control_pilot(
    uint8_t mode, uint8_t batch, uint16_t S, uint8_t layer,
    uint16_t row0, uint8_t rows, uint8_t fault, uint32_t epoch,
    const uint8_t* qkv0, uint64_t qkv0_bytes, uint32_t out[14]);

namespace {
using laya::Status;
constexpr uint64_t kQkvBytes = 12ull << 20;
constexpr uint32_t kScoreSentinelBits = 0x40e00000u; // 7.0f
constexpr uint32_t kExpectedScoreBits = 0x3e000000u; // 1/8
constexpr uint32_t kMaskedScoreBits = 0xc61c4000u; // -10000.0f
unsigned checks = 0;

void require(bool condition, const char* what) {
  if (!condition) {
    std::fprintf(stderr, "FULL_POINTER_CONTROL_PILOT_FAIL %s\n", what);
    std::abort();
  }
  ++checks;
}

void write_query_one(std::vector<uint8_t>& qkv0,
                     uint8_t batch, uint16_t row) {
  const uint64_t offset = ((uint64_t(batch) * 8 * 1024 + row) * 64) * 4;
  const uint32_t one = 0x3f800000u;
  require(offset + 4 <= qkv0.size(), "query stimulus in real QKV0 range");
  std::memcpy(qkv0.data() + offset, &one, 4);
}

std::array<uint32_t, 14> run(std::vector<uint8_t>& qkv0,
                             uint8_t mode, uint8_t batch = 0,
                             uint16_t S = 64, uint8_t layer = 0,
                             uint16_t row0 = 0, uint8_t rows = 1,
                             uint8_t fault = 0, uint32_t epoch = 3,
                             uint64_t qkv_bytes = kQkvBytes) {
  std::array<uint32_t, 14> out{};
  full_pointer_control_pilot(mode, batch, S, layer, row0, rows,
                             fault, epoch, qkv0.data(), qkv_bytes,
                             out.data());
  return out;
}

void expect_qk_success(std::vector<uint8_t>& qkv0,
                       uint8_t batch, uint16_t S, uint8_t layer,
                       uint16_t row0, uint8_t rows) {
  write_query_one(qkv0, batch, row0);
  const auto out = run(qkv0, 2, batch, S, layer, row0, rows);
  require(out[0] == uint32_t(Status::OK), "QK task accepted");
  require(out[4] == kExpectedScoreBits, "QK first score exact F32 bits");
  require(out[10] == kMaskedScoreBits,
          "QK second key uses non-first mask byte");
  require(out[5] == uint32_t(rows) * S, "QK output element count");
  require(out[6] == 1, "QK score owner published");
  require(out[7] == 0 && out[8] == 0, "QK read leases released");
}
} // namespace

int main() {
  std::vector<uint8_t> qkv0(kQkvBytes, 0);
  auto out = run(qkv0, 0, 1, 64, 0, 0, 1, 0, 3);
  require(out[0] == uint32_t(Status::OK) && out[13] == 4,
          "first physical owner wins with epoch increment");
  require(out[11] == uint32_t(laya::CacheState::INVALID),
          "ascending cleanup reaches last incomplete owner");
  out = run(qkv0, 0, 0, 64, 0, 0, 1, 0, 3);
  require(out[0] == uint32_t(Status::OK) && out[13] == 10,
          "later physical owner found when first slot empty");
  out = run(qkv0, 0, 1, 64, 0, 0, 1, 0, laya::kMaxEpoch);
  require(out[0] == uint32_t(Status::OK) && out[13] == 0,
          "first owner max epoch returns zero boundary");
  out = run(qkv0, 0, 1, 64, 0, 0, 1, 1, 3);
  require(out[0] == uint32_t(Status::E_INTERNAL) &&
          out[11] == uint32_t(laya::CacheState::FILL),
          "busy owner rejects before later invalidation");

  out = run(qkv0, 1, 0);
  require(out[0] == uint32_t(Status::OK) && out[12] == 133 &&
          out[8] == 4096, "production scorer bias indexed lookup");
  out = run(qkv0, 1, 1);
  require(out[0] == uint32_t(Status::OK) && out[12] == 137 &&
          out[8] == 1024, "production act bias indexed lookup");

  expect_qk_success(qkv0, 0, 64, 0, 0, 1);
  expect_qk_success(qkv0, 1, 1024, 1, 7, 1);
  expect_qk_success(qkv0, 0, 128, 0, 12, 4);
  expect_qk_success(qkv0, 1, 256, 1, 15, 2);
  expect_qk_success(qkv0, 0, 512, 0, 9, 1);

  write_query_one(qkv0, 0, 0);
  out = run(qkv0, 2, 0, 64, 0, 0, 1, 1);
  require(out[0] == uint32_t(Status::E_SHAPE) &&
          out[4] == kScoreSentinelBits && out[6] == 0,
          "invalid mask remains a leaf shape failure without score write");
  out = run(qkv0, 2, 0, 64, 0, 0, 1, 2);
  require(out[0] == uint32_t(Status::E_BUFFER) &&
          out[4] == kScoreSentinelBits && out[6] == 0,
          "Q owner acquisition failure prevents mask path");
  out = run(qkv0, 2, 0, 64, 0, 0, 1, 3);
  require(out[0] == uint32_t(Status::E_BUFFER) &&
          out[4] == kScoreSentinelBits && out[6] == 0 && out[7] == 0,
          "KV owner acquisition failure releases Q read lease");
  out = run(qkv0, 2, 0, 64, 0, 0, 1, 0, 3, 0);
  require(out[0] == uint32_t(Status::E_BUFFER) &&
          out[4] == kScoreSentinelBits && out[6] == 0,
          "QKV0 read failure retains score sentinel");
  out = run(qkv0, 2, 0, 64, 0, 0, 0);
  require(out[0] == uint32_t(Status::E_PROTOCOL) &&
          out[4] == kScoreSentinelBits && out[6] == 0,
          "invalid QK context rejects before score write");
  out = run(qkv0, 2, 2, 64, 0, 0, 1);
  require(out[0] == UINT32_MAX, "pilot rejects out-of-range batch");
  std::printf("FULL_POINTER_CONTROL_PILOT_PASS checks=%u\n", checks);
  return 0;
}
