#include "full_kernel_wrapper.h"
#include "laya_model_layout_generated.h"

#include <algorithm>
#include <array>
#include <cfenv>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

namespace fs = std::filesystem;
using namespace laya;

namespace {
void require(bool condition, const std::string& reason) {
  if (!condition) {
    std::cerr << "FULL_SYNTHESIS_SHADOW_FAIL " << reason << '\n';
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const fs::path& path) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "open " + path.string());
  return {std::istreambuf_iterator<char>(stream),
          std::istreambuf_iterator<char>()};
}

void write_file(const fs::path& path, const uint8_t* bytes, size_t size) {
  std::ofstream stream(path, std::ios::binary | std::ios::trunc);
  require(bool(stream), "write " + path.string());
  stream.write(reinterpret_cast<const char*>(bytes), std::streamsize(size));
  require(bool(stream), "complete " + path.string());
}

uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint32_t le32(const uint8_t* p) {
  uint32_t value = 0;
  for (unsigned i = 0; i < 4; ++i) value |= uint32_t(p[i]) << (8 * i);
  return value;
}
uint64_t le64(const uint8_t* p) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i) value |= uint64_t(p[i]) << (8 * i);
  return value;
}
void put32(uint8_t* p, uint32_t value) {
  for (unsigned i = 0; i < 4; ++i) p[i] = uint8_t(value >> (8 * i));
}

struct Ports {
  std::vector<uint8_t> embedding, io, w_q0, w_q1, w_scale, aux;
  std::vector<uint8_t> state0, state1, qkv0, qkv1, ff0, ff1, att_out;

  explicit Ports(const fs::path& package)
      : embedding(read_file(package / "embedding.bin")),
        io(kResultOffset + kResultCapacity),
        w_q0(read_file(package / "w_q0.bin")),
        w_q1(read_file(package / "w_q1.bin")),
        w_scale(read_file(package / "w_scale.bin")),
        aux(read_file(package / "aux.bin")),
        state0(16920576u), state1(16919104u),
        qkv0(12u << 20), qkv1(12u << 20),
        ff0(41u << 20), ff1((21u << 20) - 512u * 1024u),
        att_out(8u << 20) {
    require(embedding.size() == full::kFullModelBoSizes[0] &&
                w_q0.size() == full::kFullModelBoSizes[1] &&
                w_q1.size() == full::kFullModelBoSizes[2] &&
                w_scale.size() == full::kFullModelBoSizes[3] &&
                aux.size() == full::kFullModelBoSizes[4],
            "all five complete production model BOs");
  }

  void execute() {
    laya_typed_q8_forward(
        embedding.data(), io.data(), w_q0.data(), w_q1.data(),
        w_scale.data(), aux.data(), state0.data(), state1.data(),
        qkv0.data(), qkv1.data(), ff0.data(), ff1.data(), att_out.data());
  }
};

struct Case {
  const char* name;
  unsigned B;
  uint64_t request_id;
  bool fault;
};

void compare_final(const fs::path& expected_path,
                   const uint8_t* actual, unsigned B,
                   const fs::path& output_path) {
  const auto expected = read_file(expected_path);
  std::vector<uint8_t> final(size_t(B) * 18 * 4);
  for (unsigned b = 0; b < B; ++b) {
    std::memcpy(final.data() + size_t(b) * 18 * 4,
                actual + 128 + size_t(b) * 16 * 4, 16 * 4);
    std::memcpy(final.data() + (size_t(b) * 18 + 16) * 4,
                actual + 256 + size_t(b) * 2 * 4, 2 * 4);
  }
  require(final.size() == expected.size(), "independent final18 byte count");
  for (size_t i = 0; i < final.size(); ++i)
    require(final[i] == expected[i],
            "independent final18 F32 mismatch at byte " +
                std::to_string(i));
  write_file(output_path, final.data(), final.size());
}

void verify_frame(const uint8_t* frame, const uint8_t* request,
                  const uint8_t* model_tags, const Case& one,
                  const fs::path& oracle, const fs::path& output) {
  require(std::memcmp(frame, "LYRS", 4) == 0 && le16(frame + 4) == 1 &&
              le16(frame + 8) == 128 && le32(frame + 12) == kResultBytes &&
              le64(frame + 16) == one.request_id &&
              le64(frame + 24) == le64(request + 32) &&
              std::memcmp(frame + 32, model_tags, 64) == 0 &&
              le16(frame + 96) == one.B && le16(frame + 98) == 128 &&
              le32(frame + 104) == 128 && le32(frame + 108) == 256,
          std::string(one.name) + " 384-byte result identity and shape");
  require(std::all_of(frame + 6, frame + 8,
                      [](uint8_t byte) { return byte == 0; }) &&
              std::all_of(frame + 124, frame + 128,
                          [](uint8_t byte) { return byte == 0; }) &&
              std::all_of(frame + 272, frame + 320,
                          [](uint8_t byte) { return byte == 0; }) &&
              std::all_of(frame + 368, frame + 384,
                          [](uint8_t byte) { return byte == 0; }),
          std::string(one.name) + " reserved bytes cleared from poison");
  if (one.fault) {
    require(le16(frame + 10) == 6 &&
                le16(frame + 100) == 0 && le16(frame + 102) == 0 &&
                le32(frame + 112) == 9 &&
                le16(frame + 116) == 1 && le16(frame + 118) == 0x82 &&
                le32(frame + 120) == 0x0782000f &&
                le64(frame + 328) > 0 && le64(frame + 336) == 578 &&
                le64(frame + 344) == 0 && le64(frame + 352) == UINT64_MAX &&
                le32(frame + 360) > 0 && le32(frame + 320) == 0 &&
                le32(frame + 324) == 0 && le32(frame + 364) == 0 &&
                std::all_of(frame + 128, frame + 320,
                            [](uint8_t byte) { return byte == 0; }),
            "accepted gamma fault first cause and cleared result data");
  } else {
    require(le16(frame + 10) == 0 &&
                le16(frame + 100) == 16 * one.B &&
                le16(frame + 102) == 2 * one.B &&
                le32(frame + 112) == 11 &&
                le16(frame + 116) == 0 && le16(frame + 118) == 0 &&
                le32(frame + 120) == 0 &&
                le64(frame + 328) > 0 &&
                le64(frame + 336) == 289 * one.B &&
                le64(frame + 344) == 18 * one.B &&
                le64(frame + 352) == UINT64_MAX &&
                le32(frame + 360) == 0 &&
                le32(frame + 320) == 0 && le32(frame + 324) == 0 &&
                le32(frame + 364) == 0,
            std::string(one.name) + " successful status, flags and lengths");
    if (one.B == 1)
      require(std::all_of(frame + 192, frame + 256,
                          [](uint8_t byte) { return byte == 0; }) &&
                  std::all_of(frame + 264, frame + 272,
                              [](uint8_t byte) { return byte == 0; }),
              std::string(one.name) + " unused F32 slots cleared");
    compare_final(oracle / one.name / "final18.f32.bin", frame, one.B,
                  output / "final18.f32.bin");
  }
}

}  // namespace

int main(int argc, char** argv) {
  require(argc == 5,
          "usage: full_synthesis_shadow_tb PACKAGE REQUEST_DIR ORACLE_DIR OUTPUT_DIR");
  require(std::fegetround() == FE_TONEAREST,
          "binary32 round-to-nearest-even");
  const fs::path package(argv[1]), requests(argv[2]), oracle(argv[3]),
      output(argv[4]);
  fs::create_directories(output);
  Ports ports(package);
  const auto original_aux = ports.aux;
  full::FullTensorDescriptor gamma;
  const Check lookup = full::full_lookup_tensor("emb_norm_w", gamma);
  require(bool(lookup) && gamma.bo == uint8_t(Bo::AUX) &&
              gamma.span == 4096 && uint64_t(gamma.base) + 4 <= ports.aux.size(),
          "production gamma descriptor for in-memory fault");
  const uint32_t original_gamma = le32(ports.aux.data() + gamma.base);
  require((original_gamma & 0x7f800000u) != 0x7f800000u,
          "frozen gamma is finite");

  const std::array<Case, 4> cases = {{
      {"B2_S128", 2, 1, false},
      {"accepted_gamma_failure", 2, 2, true},
      {"B1_from_b0_S128", 1, 3, false},
      {"B1_from_b1_S128", 1, 4, false},
  }};
  for (const Case& one : cases) {
    const auto request = read_file(requests /
                                   (std::string(one.name) + ".request.bin"));
    require(request.size() == (one.B == 2 ? 1856u : 1152u) &&
                std::memcmp(request.data(), "LYRQ", 4) == 0 &&
                le16(request.data() + 20) == one.B &&
                le16(request.data() + 22) == 128 &&
                le64(request.data() + 24) == one.request_id &&
                std::memcmp(request.data() + 40,
                            ports.aux.data() + 32, 64) == 0,
            std::string(one.name) + " rebound request identity");
    std::fill(ports.io.begin(), ports.io.end(), 0);
    std::memcpy(ports.io.data(), request.data(), request.size());
    std::fill(ports.io.begin() + kResultOffset,
              ports.io.begin() + kResultOffset + kResultBytes, 0xa5);
    if (one.fault) put32(ports.aux.data() + gamma.base, 0x7f800000u);
    ports.execute();  // The same static production runtime handles all four calls.
    if (one.fault) put32(ports.aux.data() + gamma.base, original_gamma);
    require(ports.aux == original_aux,
            std::string(one.name) + " complete model AUX restoration");
    const uint8_t* frame = ports.io.data() + kResultOffset;
    const fs::path directory = output / one.name;
    fs::create_directories(directory);
    verify_frame(frame, request.data(), ports.aux.data() + 32, one,
                 oracle, directory);
    write_file(directory / "result.bin", frame, kResultBytes);
    std::cout << "FULL_SYNTHESIS_SHADOW_CASE_PASS " << one.name
              << " status=" << le16(frame + 10)
              << " request_id=" << le64(frame + 16)
              << " tasks=" << le64(frame + 328) << '\n' << std::flush;
  }
  std::cout << "FULL_SYNTHESIS_SHADOW_PASS calls=4 successes=3 "
               "accepted_faults=1 oracle_f32_values=72\n";
}
