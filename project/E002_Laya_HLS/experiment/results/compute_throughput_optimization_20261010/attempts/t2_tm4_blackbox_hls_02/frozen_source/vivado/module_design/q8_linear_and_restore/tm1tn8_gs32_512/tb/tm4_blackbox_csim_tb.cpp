#include "laya_numeric.h"
#include <array>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

void laya_tm4_blackbox_smoke(const uint64_t input[112], uint64_t output[57]);
namespace {
void check(bool good, const std::string& why) {
  if (!good) { std::cerr << "TM4_BLACKBOX_FAIL " << why << '\n'; std::exit(1); }
}
std::vector<uint8_t> read(const std::string& name) {
  std::ifstream f(name, std::ios::binary);
  check(bool(f), "open=" + name);
  return {std::istreambuf_iterator<char>(f), std::istreambuf_iterator<char>()};
}
uint64_t word(const uint8_t* p, unsigned bytes) {
  uint64_t v = 0;
  for (unsigned i = 0; i < bytes; ++i) v |= uint64_t(p[i]) << (i * 8);
  return v;
}
void owner(uint64_t input[112], unsigned sequence) {
  for (unsigned i = 0; i < 16; ++i)
    input[i] = 0x916cc843390125a7ULL ^ (uint64_t(i + 1) << 41) ^ sequence;
  input[0] = 3;
  input[1] = 1;
  input[109] = 0;
  input[110] = 0;
  input[111] = sequence;
}
void echo(const uint64_t input[112], const uint64_t output[57]) {
  for (unsigned i = 0; i < 16; ++i)
    check(input[i] == output[i], "complete 1024-bit owner echo");
}
}

int main() {
  const char* root = std::getenv("LAYA_TM4_FIXTURE");
  check(root && *root, "fixture path required");
  unsigned calls = 0, lane_groups = 0;
  for (const std::string name : {"wi_rows4", "down_rows4"}) {
    const unsigned G = name == "wi_rows4" ? 32 : 82;
    const unsigned N = name == "wi_rows4" ? 5248 : 1024;
    const unsigned T = N / 8;
    const std::string prefix = std::string(root) + "/" + name + "_";
    const auto aq = read(prefix + "a8_q.bin"), as = read(prefix + "a8_scale.bin");
    const auto q0 = read(prefix + "w_q0.bin"), q1 = read(prefix + "w_q1.bin");
    const auto ws = read(prefix + "w_scale.bin"), steps = read(prefix + "steps_u32x6.bin");
    check(aq.size() == 4 * G * 32 && as.size() == 4 * G * 2 &&
          ws.size() == T * G * 8 * 2 && steps.size() == 4 * G * N * 24,
          "independent frozen fixture dimensions");
    for (unsigned tile = 0; tile < T; ++tile) {
      uint32_t partial[32] = {};
      for (unsigned g = 0; g < G; ++g) {
        uint64_t input[112] = {}, output[57] = {};
        owner(input, calls);
        for (unsigned r = 0; r < 4; ++r) {
          for (unsigned i = 0; i < 4; ++i)
            input[16 + r * 4 + i] = word(aq.data() + (r * G + g) * 32 + i * 8, 8);
          input[64 + r] = laya::numeric_f32_bits(laya::numeric_half_to_f32(
              uint16_t(word(as.data() + (r * G + g) * 2, 2))));
        }
        const auto& shard = tile & 1 ? q1 : q0;
        for (unsigned lane = 0; lane < 8; ++lane) {
          for (unsigned i = 0; i < 4; ++i)
            input[32 + lane * 4 + i] = word(shard.data() +
                (((tile / 2) * G + g) * 8 + lane) * 32 + i * 8, 8);
          input[68 + lane] = laya::numeric_f32_bits(laya::numeric_half_to_f32(
              uint16_t(word(ws.data() + ((tile * G + g) * 8 + lane) * 2, 2))));
        }
        for (unsigned i = 0; i < 32; ++i) input[76 + i] = partial[i];
        input[108] = 0xffffffffu;
        input[109] = g;
        input[110] = tile;
        laya_tm4_blackbox_smoke(input, output);
        echo(input, output);
        check(output[56] == 0, "real group status");
        for (unsigned r = 0; r < 4; ++r) {
          check(output[48 + r] == 0 && output[52 + r] == 0x924924,
                "all real lanes successful");
          for (unsigned lane = 0; lane < 8; ++lane) {
            const unsigned index = r * 8 + lane;
            const uint32_t expected = uint32_t(word(steps.data() +
                ((r * G + g) * N + tile * 8 + lane) * 24 + 20, 4));
            check(output[16 + index] == expected, "independent per-group PS");
            partial[index] = uint32_t(output[16 + index]);
            ++lane_groups;
          }
        }
        ++calls;
      }
    }
    std::cout << "ACT_TM4_FIXTURE_PASS name=" << name << " groups=" << G
              << " tiles=" << T << '\n';
  }
  uint64_t input[112] = {}, output[57] = {};
  owner(input, calls);
  for (unsigned i = 16; i < 64; ++i) input[i] = 0x0101010101010101ULL;
  for (unsigned i = 64; i < 76; ++i) input[i] = 0x3f800000;
  input[108] = 0xffffffffu; input[109] = 127; input[110] = 655;
  laya_tm4_blackbox_smoke(input, output); echo(input, output);
  for (unsigned i = 16; i < 48; ++i) check(output[i] == 0x42000000, "G127/T655 arithmetic");
  check(output[56] == 0, "maximum legal group/tile");
  input[67] = 0x7f800000;
  laya_tm4_blackbox_smoke(input, output); echo(input, output);
  check(output[56] == 1 && output[51] == 255 && output[55] == 0,
        "last active row bad scale phase0");
  input[67] = 0x3f800000; input[109] = 128;
  laya_tm4_blackbox_smoke(input, output);
  check(output[56] == 2, "out of range group rejection");
  input[109] = 0;
  laya_tm4_blackbox_smoke(input, output);
  check(output[56] == 0, "invocation recovery");
  std::cout << "TM4_BLACKBOX_CSIM_PASS real_calls=" << calls
            << " real_lane_groups=" << lane_groups
            << " full_owner_bits=1024 max_group=127 max_tile=655 error_recovery=1\n";
}
