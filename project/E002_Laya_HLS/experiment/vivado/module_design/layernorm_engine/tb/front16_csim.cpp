#include "front16.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <vector>

namespace {
using Byte = std::vector<uint8_t>;
void require(bool yes, const char* what) {
  if (!yes) { std::fprintf(stderr, "FRONT16_CSIM_FAIL %s\n", what); std::exit(1); }
}
Byte read(const char* path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "input open");
  return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}
uint32_t get32(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
float f32(const uint8_t* p) {
  const uint32_t bits = get32(p);
  float f;
  std::memcpy(&f, &bits, 4);
  return f;
}
uint32_t crc32c(const uint8_t* p, size_t n) {
  uint32_t crc = 0xffffffffu;
  for (size_t i = 0; i < n; ++i) {
    crc ^= p[i];
    for (unsigned b = 0; b < 8; ++b)
      crc = (crc >> 1) ^ ((crc & 1u) ? 0x82f63b78u : 0);
  }
  return crc ^ 0xffffffffu;
}
void check_observed(const uint32_t* o, uint32_t status, uint32_t row,
                    uint32_t col, uint32_t crc, uint32_t raw,
                    uint32_t rd, uint32_t gamma, uint32_t out) {
  const uint32_t expected[16] = {0x31423146u, 1, status, row, col, crc,
                                 16, 1024, raw, 0, rd, 0, gamma, 0, out, 0};
  for (unsigned i = 0; i < 16; ++i)
    if (o[i] != expected[i]) {
      std::fprintf(stderr, "observed[%u] got=%08x expected=%08x\n", i, o[i], expected[i]);
      require(false, "observed field");
    }
  for (unsigned i = 16; i < 64; ++i) require(o[i] == 0, "observed reserved");
}
void compare_norm(const Byte& out, const Byte& gold) {
  float max_abs = 0, max_rel = 0;
  for (unsigned i = 0; i < 16384; ++i) {
    const float actual = f32(out.data() + i * 4);
    const float expected = f32(gold.data() + i * 4);
    require(std::isfinite(actual), "norm finite");
    const float err = std::fabs(actual - expected);
    max_abs = std::max(max_abs, err);
    max_rel = std::max(max_rel, err / std::max(std::fabs(expected), 1e-30f));
    if (err > 1e-4f + 1e-4f * std::fabs(expected)) {
      std::fprintf(stderr, "norm[%u] actual=%a gold=%a err=%g\n", i, actual, expected, err);
      require(false, "independent norm tolerance");
    }
  }
  std::printf("norm max_abs=%g max_rel=%g\n", max_abs, max_rel);
}
void run_byte(const Byte& raw, const Byte& aux, const Byte& norm) {
  Byte output(65536 + 64, 0xa5), input = raw, weights = aux;
  uint32_t obs[64];
  std::fill(obs, obs + 64, 0xa5a5a5a5u);
  laya_front16_byte(input.data(), weights.data(), output.data(), obs);
  require(input == raw && weights == aux, "byte input read only");
  compare_norm(output, norm);
  for (unsigned i = 65536; i < output.size(); ++i) require(output[i] == 0xa5, "byte sentinel");
  check_observed(obs, 0, UINT32_MAX, UINT32_MAX,
                 crc32c(raw.data(), 65536), 65536, 65536, 4096, 65536);
  input = raw; input[0] = 0; input[1] = 0; input[2] = 0x80; input[3] = 0x7f;
  std::fill(output.begin(), output.end(), 0xa5);
  laya_front16_byte(input.data(), weights.data(), output.data(), obs);
  check_observed(obs, 1, 0, 0, crc32c(input.data(), 4), 4, 0, 0, 0);
  require(std::all_of(output.begin(), output.end(), [](uint8_t x){return x == 0xa5;}), "raw error no norm");
  weights = aux; weights[128] = 0; weights[129] = 0; weights[130] = 0x80; weights[131] = 0x7f;
  laya_front16_byte(raw.data(), weights.data(), output.data(), obs);
  check_observed(obs, 2, UINT32_MAX, 0, crc32c(raw.data(), 65536), 65536, 0, 4, 0);
  require(std::all_of(output.begin(), output.end(), [](uint8_t x){return x == 0xa5;}), "gamma error no norm");
}
void run_wide(const Byte& raw, const Byte& aux, const Byte& norm) {
  require(raw.size() % 64 == 0 && aux.size() % 64 == 0, "wide alignment size");
  std::vector<ap_uint<512>> input(raw.size() / 64), weights(aux.size() / 64);
  std::vector<ap_uint<512>> output(1025);
  for (size_t i = 0; i < input.size(); ++i)
    for (unsigned b = 0; b < 64; ++b) input[i].range(b*8+7,b*8) = raw[i*64+b];
  for (size_t i = 0; i < weights.size(); ++i)
    for (unsigned b = 0; b < 64; ++b) weights[i].range(b*8+7,b*8) = aux[i*64+b];
  auto input_copy = input, weights_copy = weights;
  for (auto& word : output) word = ~ap_uint<512>(0);
  uint32_t obs[64];
  laya_front16_wide(input.data(), weights.data(), output.data(), obs);
  require(input == input_copy && weights == weights_copy, "wide input read only");
  Byte actual(65536);
  for (size_t i = 0; i < actual.size(); ++i)
    actual[i] = uint8_t(output[i/64].range((i%64)*8+7,(i%64)*8));
  compare_norm(actual, norm);
  require(output[1024] == ~ap_uint<512>(0), "wide sentinel");
  check_observed(obs, 0, UINT32_MAX, UINT32_MAX,
                 crc32c(raw.data(), 65536), 65536, 65536, 4096, 65536);
  input[0].range(31,0) = 0x7f800000u;
  for (auto& word : output) word = ~ap_uint<512>(0);
  laya_front16_wide(input.data(), weights.data(), output.data(), obs);
  Byte bad = raw; bad[0] = 0; bad[1] = 0; bad[2] = 0x80; bad[3] = 0x7f;
  check_observed(obs, 1, 0, 0, crc32c(bad.data(), 4), 4, 0, 0, 0);
  for (const auto& word : output) require(word == ~ap_uint<512>(0), "wide raw error no norm");
  input[0] = input_copy[0];
  weights[2].range(31,0) = 0x7f800000u;
  laya_front16_wide(input.data(), weights.data(), output.data(), obs);
  check_observed(obs, 2, UINT32_MAX, 0, crc32c(raw.data(), 65536), 65536, 0, 4, 0);
  for (const auto& word : output) require(word == ~ap_uint<512>(0), "wide gamma error no norm");
}
} // namespace

int main(int argc, char** argv) {
  require(argc == 5, "usage STATE0 AUX RAW_GOLD NORM_GOLD");
  const Byte raw = read(argv[1]), aux = read(argv[2]);
  const Byte raw_gold = read(argv[3]), norm = read(argv[4]);
  require(raw.size() >= 65536 && aux.size() >= 4224 &&
          raw_gold.size() >= 65536 && norm.size() >= 65536, "input sizes");
  require(std::memcmp(raw.data(), raw_gold.data(), 65536) == 0, "16384 raw F32 exact gold");
  run_byte(raw, aux, norm);
  run_wide(raw, aux, norm);
  std::puts("FRONT16_CSIM_PASS rows=16 elements=16384 modes=2 negatives=4");
}
