#include "laya_full_runtime.h"

#include <array>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

extern "C" void attention_slice(const uint8_t*, uint8_t*, const uint8_t*,
                                 uint8_t*, uint8_t*, uint8_t*, uint32_t*);

namespace {

void require(bool condition, const char* message) {
  if (!condition) {
    std::fprintf(stderr, "D2_ATTENTION_SLICE_FAIL %s\n", message);
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "open fixture or model file");
  return {std::istreambuf_iterator<char>(in),
          std::istreambuf_iterator<char>()};
}

uint32_t bits(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
float f32(uint32_t word) {
  float value;
  std::memcpy(&value, &word, 4);
  return value;
}
uint32_t bits(float value) {
  uint32_t word;
  std::memcpy(&word, &value, 4);
  return word;
}
bool near(float actual, float expected) {
  return std::isfinite(actual) && std::isfinite(expected) &&
         std::abs(actual - expected) <=
             1.0e-4f + 1.0e-4f * std::abs(expected);
}

}  // namespace

int main(int argc, char** argv) {
  const char* package_arg = argc == 3 ? argv[1] : std::getenv("LAYA_D2_PACKAGE");
  const char* fixture_arg = argc == 3 ? argv[2] : std::getenv("LAYA_D2_FIXTURE");
  require(package_arg && fixture_arg,
          "PACKAGE and FIXTURE_DIR args or LAYA_D2_PACKAGE/LAYA_D2_FIXTURE env");
  const std::string package = package_arg, fixture = fixture_arg;
  auto request = read_file(fixture + "/request.bin");
  const auto raw_qkv = read_file(fixture + "/qkv_final.f32.bin");
  const auto score = read_file(fixture + "/score.f32.bin");
  const auto probability = read_file(fixture + "/probability.f32.bin");
  const auto av = read_file(fixture + "/av.f32.bin");
  const auto aux = read_file(package + "/aux.bin");
  require(request.size() == 832 && raw_qkv.size() == 786432 &&
          score.size() == 256 && probability.size() == 256 &&
          av.size() == 256 && aux.size() == 1671872,
          "exact frozen fixture and package spans");
  request.resize(32768, 0);
  std::vector<uint8_t> qkv0(12u << 20, 0xa5),
                       qkv1(12u << 20, 0xa5),
                       att_out(8u << 20, 0xa5);
  std::array<uint32_t, 256> observed;
  observed.fill(0xdeadbeefu);
  attention_slice(raw_qkv.data(), request.data(), aux.data(),
                  qkv0.data(), qkv1.data(), att_out.data(), observed.data());
  require(observed[0] == 0 && observed[1] == 0 &&
          observed[2] == 13 && observed[3] == 4,
          "all four real tasks completed successfully");
  require(observed[4] == 1 && observed[5] == 1 &&
          observed[6] == 32768 && observed[9] == 4 &&
          observed[10] == 0,
          "QKV/KV owner and TaskDone completion");
  require(observed[7] == uint32_t(laya::Status::E_BUFFER),
          "partial ATT_OUT cannot publish full matrix");
  unsigned qkv_bytes_checked = 0;
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned row = 0; row < 64; ++row) {
        laya::Address address;
        require(bool(laya::qkv_address(uint8_t(plane), 0, uint8_t(head),
                                       uint16_t(row), 0, 1, 64, address)),
                "QKV physical address");
        const uint8_t* bank = address.bo == laya::Bo::QKV0 ?
                              qkv0.data() : qkv1.data();
        const unsigned offset =
            ((row * 3072u + plane * 1024u + head * 64u) * 4u);
        require(std::memcmp(bank + address.offset,
                            raw_qkv.data() + offset, 256) == 0,
                "all QKV AXI input bytes physically written");
        qkv_bytes_checked += 256;
      }
  require(qkv_bytes_checked == raw_qkv.size(), "entire fixture written");

  for (unsigned key = 0; key < 64; ++key) {
    require(observed[16 + key] == bits(score.data() + 4 * key),
            "QK score bit-exact independent oracle");
    require(near(f32(observed[80 + key]),
                 f32(bits(probability.data() + 4 * key))),
            "softmax independent nonlinear tolerance");
  }
  unsigned av_exact = 0;
  for (unsigned d = 0; d < 64; ++d) {
    float expected = 0.0f;
    for (unsigned key = 0; key < 64; ++key) {
      const uint32_t input_word = bits(raw_qkv.data() +
          ((key * 3072u + 2048u + d) * 4u));
      const float product = f32(observed[80 + key]) * f32(input_word);
      expected = expected + product;
    }
    require(observed[144 + d] == bits(expected),
            "AV bit-exact from actual probability inputs");
    require(near(f32(observed[144 + d]), f32(bits(av.data() + 4 * d))),
            "AV end-to-end independent oracle tolerance");
    require(bits(att_out.data() + d * 4u) == observed[144 + d],
            "AV AXI output equals observed numeric word");
    ++av_exact;
  }
  require(bits(att_out.data() + 64u * 4u) == 0xa5a5a5a5u &&
          bits(att_out.data() + 1024u * 4u) == 0xa5a5a5a5u &&
          observed[208] == 0xdeadbeefu,
          "neighbor head, row and output tail untouched");
  std::printf("D2_ATTENTION_SLICE_PASS qkv_bytes=%u score=64 prob=64 av_exact=%u tasks=4\n",
              qkv_bytes_checked, av_exact);
}
