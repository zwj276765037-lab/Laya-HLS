#include "full_kernel_wrapper.h"
#include "laya_model_layout_generated.h"

#include <array>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <set>
#include <string>
#include <vector>

namespace fs = std::filesystem;
using namespace laya;

namespace {
[[noreturn]] void fail(const std::string& reason) {
  std::cerr << "FULL_KERNEL_CSIM_FAIL " << reason << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& reason) {
  if (!condition) fail(reason);
}
std::string env_required(const char* name) {
  const char* value = std::getenv(name);
  require(value && *value, std::string("missing ") + name);
  return value;
}
std::vector<uint8_t> read_file(const fs::path& path) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "open " + path.string());
  return {std::istreambuf_iterator<char>(stream),
          std::istreambuf_iterator<char>()};
}
uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint64_t le64(const uint8_t* p) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i) value |= uint64_t(p[i]) << (8 * i);
  return value;
}
struct Observation {
  fs::path expected;
  std::set<std::string> names;
  uint64_t compared_values = 0;
};
void checkpoint(const char* name, const laya::full::FullRuntime& rt,
                BufferRef ref, uint8_t region, RowSpace space,
                uint16_t width, void* user) {
  Observation& obs = *static_cast<Observation*>(user);
  const std::string label(name ? name : "");
  require(!label.empty() && obs.names.insert(label).second,
          "unique checkpoint " + label);
  const unsigned rows = space == RowSpace::TOKEN ? rt.inputs.identity.S :
                        space == RowSpace::MARKER ? 16 : 1;
  const unsigned B = rt.inputs.identity.B;
  const auto expected = read_file(obs.expected / (label + ".f32.bin"));
  require(expected.size() == size_t(B) * rows * width * 4,
          "checkpoint shape " + label);
  std::vector<uint8_t> actual(expected.size());
  for (unsigned b = 0; b < B; ++b)
    for (unsigned row = 0; row < rows; ++row) {
      Address address;
      Check c = laya::full::full_f32_address(
          rt, ref, region, uint8_t(b), uint16_t(row), 0, address);
      require(bool(c), "checkpoint address " + label);
      c = laya::full::full_read(rt.memory, address.bo, address.offset,
              actual.data() + (size_t(b) * rows + row) * width * 4,
              uint32_t(width * 4));
      require(bool(c), "checkpoint read " + label);
    }
  for (size_t byte = 0; byte < expected.size(); ++byte)
    if (actual[byte] != expected[byte])
      fail("checkpoint mismatch " + label + " byte=" +
           std::to_string(byte));
  obs.compared_values += expected.size() / 4;
}
} // namespace

int main() {
  const fs::path package(env_required("LAYA_FULL_HLS_PACKAGE"));
  const fs::path request_path(env_required("LAYA_FULL_HLS_REQUEST"));
  Observation obs{fs::path(env_required("LAYA_FULL_HLS_ORACLE"))};
  const auto embedding = read_file(package / "embedding.bin");
  const auto w_q0 = read_file(package / "w_q0.bin");
  const auto w_q1 = read_file(package / "w_q1.bin");
  const auto w_scale = read_file(package / "w_scale.bin");
  const auto aux = read_file(package / "aux.bin");
  const auto request = read_file(request_path);
  require(embedding.size() == laya::full::kFullModelBoSizes[0] &&
          w_q0.size() == laya::full::kFullModelBoSizes[1] &&
          w_q1.size() == laya::full::kFullModelBoSizes[2] &&
          w_scale.size() == laya::full::kFullModelBoSizes[3] &&
          aux.size() == laya::full::kFullModelBoSizes[4],
          "complete generated model package");
  require(request.size() >= 320 && request.size() <= kRequestLimit &&
          request[0] == 'L' && request[1] == 'Y' &&
          le16(request.data() + 20) == 2 &&
          le16(request.data() + 22) == 128,
          "real B2/S128 ABI request");
  std::vector<uint8_t> io(kResultOffset + kResultCapacity),
      state0(16920576u), state1(16919104u),
      qkv0(12u << 20), qkv1(12u << 20),
      ff0(41u << 20), ff1((21u << 20) - 512u * 1024u),
      att_out(8u << 20);
  std::memcpy(io.data(), request.data(), request.size());
  auto& rt = full_kernel_csim_runtime();
  rt.checkpoint = checkpoint;
  rt.checkpoint_user = &obs;
  laya_typed_q8_forward(
      embedding.data(), io.data(), w_q0.data(), w_q1.data(),
      w_scale.data(), aux.data(), state0.data(), state1.data(),
      qkv0.data(), qkv1.data(), ff0.data(), ff1.data(), att_out.data());
  rt.checkpoint = nullptr;
  rt.checkpoint_user = nullptr;
  const uint8_t* result = io.data() + kResultOffset;
  require(std::memcmp(result, "LYRS", 4) == 0 &&
          le16(result + 10) == 0 && (result[112] & 11) == 11 &&
          le64(result + 16) == le64(request.data() + 24) &&
          le64(result + 24) == le64(request.data() + 32) &&
          le16(result + 96) == 2 && le16(result + 98) == 128 &&
          le16(result + 100) == 32 && le16(result + 102) == 4,
          "committed result frame");
  std::array<uint8_t, 2 * 18 * 4> final{};
  for (unsigned b = 0; b < 2; ++b) {
    std::memcpy(final.data() + b * 18 * 4,
                result + 128 + b * 16 * 4, 16 * 4);
    std::memcpy(final.data() + (b * 18 + 16) * 4,
                result + 256 + b * 2 * 4, 2 * 4);
  }
  const auto expected_final = read_file(obs.expected / "final18.f32.bin");
  require(expected_final.size() == final.size() &&
          std::memcmp(expected_final.data(), final.data(), final.size()) == 0,
          "final18 from actual result frame");
  obs.compared_values += final.size() / 4;
  require(obs.names.size() == 46 && rt.tasks_retired == 37158 &&
          rt.encoder_layers_completed == 28 &&
          rt.decision_layers_completed == 2,
          "complete production graph events");
  std::cout << "FULL_KERNEL_CSIM_PASS checkpoints=47 values="
            << obs.compared_values << " tasks=" << rt.tasks_retired << '\n';
  return 0;
}
