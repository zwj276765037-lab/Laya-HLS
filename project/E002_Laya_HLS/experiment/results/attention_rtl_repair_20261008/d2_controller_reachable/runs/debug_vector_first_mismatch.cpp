#include "laya_full_runtime.h"

#include <array>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

extern "C" void vector_controller_slice(const uint8_t*, const uint8_t*,
                                         uint8_t*, const uint8_t*,
                                         uint8_t*, uint8_t*, uint32_t,
                                         uint32_t*);

namespace {

void require(bool condition, const char* message) {
  if (!condition) {
    std::fprintf(stderr, "D2_I_VECTOR_FAIL %s\n", message);
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "open input or gold");
  return {std::istreambuf_iterator<char>(in),
          std::istreambuf_iterator<char>()};
}

void store64(uint8_t* p, uint64_t value) {
  for (unsigned byte = 0; byte < 8; ++byte)
    p[byte] = uint8_t(value >> (8 * byte));
}

void run_case(const std::string& fixture, const std::vector<uint8_t>& request,
              const std::vector<uint8_t>& aux,
              const char* lhs_name, const char* rhs_name,
              const char* gold_name, uint32_t mode, uint64_t request_id) {
  constexpr size_t kInputBytes = 64u * 1024u * 4u;
  auto lhs_raw = read_file(fixture + "/" + lhs_name);
  std::vector<uint8_t> rhs_raw;
  if (rhs_name) rhs_raw = read_file(fixture + "/" + rhs_name);
  const size_t lhs_expected = mode == 3 ? 16u * 4u : kInputBytes;
  const size_t rhs_expected = mode == 1 ? 3u * 1024u * 4u :
                              mode == 0 || mode == 4 ? kInputBytes : 0;
  require(lhs_raw.size() == lhs_expected &&
          rhs_raw.size() == rhs_expected, "exact source fixture spans");
  std::vector<uint8_t> lhs(kInputBytes, 0xa5), rhs(kInputBytes, 0xa5);
  std::memcpy(lhs.data(), lhs_raw.data(), lhs_raw.size());
  if (!rhs_raw.empty())
    std::memcpy(rhs.data(), rhs_raw.data(), rhs_raw.size());
  std::vector<uint8_t> io(32768, 0);
  std::memcpy(io.data(), request.data(), request.size());
  store64(io.data() + 24, request_id);
  std::vector<uint8_t> state0(16920576u, 0xa5),
                       state1(16919104u, 0xa5);
  std::array<uint32_t, 32> observed;
  observed.fill(0xdeadbeefu);
  vector_controller_slice(lhs.data(), rhs.data(), io.data(), aux.data(),
                          state0.data(), state1.data(), mode,
                          observed.data());
  require(observed[14] == request_id && observed[15] != 0,
          "real parsed request identity");
  if (mode == 2) {
    require(observed[0] == uint32_t(laya::Status::E_SHAPE) &&
            observed[1] == laya::detail(7, uint8_t(laya::Op::ADD_RESIDUAL), 5) &&
            observed[2] == 4 && observed[3] == 1 &&
            observed[9] == uint32_t(laya::Status::OK),
            "no-src1 binary op reaches original task shape guard and cleans up");
    require(state1[0] == 0xa5 && state1[4095] == 0xa5,
            "invalid binary op leaves destination untouched");
    return;
  }
  require(observed[0] == uint32_t(laya::Status::OK) &&
          observed[1] == 0 && observed[2] == 5 &&
          observed[16] == uint32_t(laya::Status::OK) &&
          observed[17] == uint32_t(laya::CacheState::READY) &&
          observed[18] == 1,
          "real Controller vector success and READY owner");
  const unsigned tasks = mode == 3 ? 1 : 4;
  require(observed[3] == tasks && observed[4] == tasks &&
          observed[5] == (mode == 3 ? 2u : 3u),
          "full row-tile task retirement and producer claims");
  if (mode == 1)
    require(observed[10] == 7 && observed[12] == 4,
            "all three real type rows published and four ADD_TYPE tasks");
  else if (mode == 3)
    require(observed[13] == 1,
            "unary missing-src1 path retires a real candidate-mask task");
  else
    require(observed[11] == 4,
            "binary residual retires four full-width tasks");
  const auto gold = read_file(fixture + "/" + gold_name);
  const size_t expected_bytes = mode == 3 ? 16u * 4u : kInputBytes;
  require(gold.size() == expected_bytes, "exact independent gold span");
  const uint8_t* output = mode == 4 ? state0.data() : state1.data();
  if (mode == 3) output += 16777216u + 141504u;
  if (std::memcmp(output, gold.data(), gold.size()) != 0) {
    for (size_t i = 0; i + 4 <= gold.size(); i += 4) {
      if (std::memcmp(output + i, gold.data() + i, 4) != 0) {
        uint32_t actual_bits, gold_bits, lhs_bits, rhs_bits;
        std::memcpy(&actual_bits, output + i, 4);
        std::memcpy(&gold_bits, gold.data() + i, 4);
        std::memcpy(&lhs_bits, lhs.data() + i, 4);
        std::memcpy(&rhs_bits, rhs.data() + i, 4);
        std::fprintf(stderr, "VECTOR_FIRST_MISMATCH mode=%u request=%llu byte=%zu row=%zu col=%zu actual=%08x gold=%08x lhs=%08x rhs=%08x\n", mode, (unsigned long long)request_id, i, i / 4096, (i / 4) % 1024, actual_bits, gold_bits, lhs_bits, rhs_bits);
        break;
      }
    }
    std::ofstream out("results/attention_rtl_repair_20261008/d2_controller_reachable/runs/vector_first_mismatch.actual.bin", std::ios::binary);
    out.write(reinterpret_cast<const char*>(output), gold.size());
  }
  require(std::memcmp(output, gold.data(), gold.size()) == 0,
          "bit-exact independent F32 vector gold");
  require(output[gold.size()] == 0xa5 &&
          output[gold.size() + 3] == 0xa5,
          "adjacent row/region sentinel unchanged");
}

}  // namespace

int main(int argc, char** argv) {
  const char* package = argc == 3 ? argv[1] :
                        std::getenv("LAYA_D2_I_PACKAGE");
  const char* fixture = argc == 3 ? argv[2] :
                        std::getenv("LAYA_D2_I_FIXTURE");
  require(package && fixture, "package and fixture paths");
  require(std::fegetround() == FE_TONEAREST,
          "round-to-nearest-even host mode");
  const auto request = read_file(std::string(fixture) + "/request.bin");
  const auto aux = read_file(std::string(package) + "/aux.bin");
  require(request.size() == 832 && aux.size() == 1671872,
          "official B1/S64 request and package header");
  run_case(fixture, request, aux, "residual_src0.f32.bin",
           "residual_src1.f32.bin", "residual_gold.f32.bin", 0, 301);
  run_case(fixture, request, aux, "residual_src0.f32.bin",
           "residual_src1_changed.f32.bin", "residual_changed_gold.f32.bin",
           4, 302);
  run_case(fixture, request, aux, "type_src0.f32.bin", "type_rows.f32.bin",
           "type_gold.f32.bin", 1, 303);
  run_case(fixture, request, aux, "residual_src0.f32.bin", nullptr,
           nullptr, 2, 304);
  run_case(fixture, request, aux, "candidate.f32.bin", nullptr,
           "candidate_gold.f32.bin", 3, 305);
  std::printf("D2_I_VECTOR_PASS residual=2 type=1 binary_reject=1 unary=1 values=%u\n",
              2u * 64u * 1024u + 64u * 1024u + 16u);
}
