#include "full_kernel_wrapper.h"
#include "laya_model_layout_generated.h"

#include <algorithm>
#include <array>
#include <cfenv>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <set>
#include <sstream>
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
    if (actual[byte] != expected[byte]) {
      const size_t word = byte / 4;
      uint32_t wanted = 0, got = 0;
      std::memcpy(&wanted, expected.data() + 4 * word, 4);
      std::memcpy(&got, actual.data() + 4 * word, 4);
      std::ostringstream reason;
      reason << "checkpoint mismatch " << label << " byte=" << byte
             << " batch=" << word / (size_t(rows) * width)
             << " row=" << (word / width) % rows
             << " col=" << word % width << " expected_bits=0x"
             << std::hex << wanted << " actual_bits=0x" << got;
      fail(reason.str());
    }
  obs.compared_values += expected.size() / 4;
}
} // namespace

int main() {
  require(std::fegetround() == FE_TONEAREST, "binary32 round-to-nearest-even");
  const fs::path package(env_required("LAYA_FULL_HLS_PACKAGE"));
  const fs::path input_root(env_required("LAYA_FULL_HLS_INPUT_ROOT"));
  const fs::path oracle_root(env_required("LAYA_FULL_HLS_ORACLE_ROOT"));
  const auto embedding = read_file(package / "embedding.bin");
  const auto w_q0 = read_file(package / "w_q0.bin");
  const auto w_q1 = read_file(package / "w_q1.bin");
  const auto w_scale = read_file(package / "w_scale.bin");
  auto aux = read_file(package / "aux.bin");
  const auto aux_original = aux;
  require(embedding.size() == laya::full::kFullModelBoSizes[0] &&
          w_q0.size() == laya::full::kFullModelBoSizes[1] &&
          w_q1.size() == laya::full::kFullModelBoSizes[2] &&
          w_scale.size() == laya::full::kFullModelBoSizes[3] &&
          aux.size() == laya::full::kFullModelBoSizes[4],
          "complete generated model package");
  std::vector<uint8_t> io(kResultOffset + kResultCapacity),
      state0(16920576u), state1(16919104u),
      qkv0(12u << 20), qkv1(12u << 20),
      ff0(41u << 20), ff1((21u << 20) - 512u * 1024u),
      att_out(8u << 20);
  auto& rt = full_kernel_csim_runtime();
  const std::array<const char*, 4> scenarios = {
      "B2_S128", "accepted_gamma_failure", "B1_from_b0_S128",
      "B1_from_b1_S128"};
  uint64_t total_values = 0;
  for (unsigned invocation = 0; invocation < scenarios.size(); ++invocation) {
    const std::string scenario(scenarios[invocation]);
    const auto request = read_file(input_root / (scenario + ".request.bin"));
    const unsigned B = invocation < 2 ? 2 : 1;
    require(request.size() >= 320 && request.size() <= kRequestLimit &&
            std::memcmp(request.data(), "LYRQ", 4) == 0 &&
            le16(request.data() + 20) == B &&
            le16(request.data() + 22) == 128 &&
            le64(request.data() + 24) == invocation + 1 &&
            le64(request.data() + 32) == 1,
            "frozen S128 ABI request " + scenario);
    std::fill(io.begin(), io.end(), 0);
    std::memcpy(io.data(), request.data(), request.size());
    Observation obs{oracle_root / scenario};
    if (invocation == 1) {
      require(aux == aux_original && aux.size() > 132,
              "original AUX before injected failure");
      // Generated descriptor: emb_norm_w is AUX byte 128, first F32.
      const uint8_t positive_inf[4] = {0, 0, 0x80, 0x7f};
      std::memcpy(aux.data() + 128, positive_inf, 4);
      require(std::memcmp(aux.data() + 128, aux_original.data() + 128, 4) != 0,
              "gamma fault applied");
    } else {
      rt.checkpoint = checkpoint;
      rt.checkpoint_user = &obs;
    }
    laya_typed_q8_forward(
        embedding.data(), io.data(), w_q0.data(), w_q1.data(),
        w_scale.data(), aux.data(), state0.data(), state1.data(),
        qkv0.data(), qkv1.data(), ff0.data(), ff1.data(), att_out.data());
    rt.checkpoint = nullptr;
    rt.checkpoint_user = nullptr;
    if (invocation == 1) {
      std::copy(aux_original.begin(), aux_original.end(), aux.begin());
      require(aux == aux_original, "entire AUX image restored exactly");
    }
    const uint8_t* result = io.data() + kResultOffset;
    require(std::memcmp(result, "LYRS", 4) == 0 &&
            le64(result + 16) == le64(request.data() + 24) &&
            le64(result + 24) == le64(request.data() + 32) &&
            le16(result + 96) == B && le16(result + 98) == 128 &&
            rt.session_generation == 1 &&
            rt.last_accepted_request_id == invocation + 1 &&
            rt.last_commit_error.code == Status::OK,
            "persistent result identity and commit " + scenario);
    if (invocation == 1) {
      require(le16(result + 10) == uint16_t(Status::E_NUMERICAL) &&
              le32(result + 112) == 9 &&
              le16(result + 100) == 0 && le16(result + 102) == 0 &&
              le16(result + 116) == 1 &&
              le16(result + 118) == uint16_t(Op::LOAD_LN_PARAMS) &&
              le32(result + 120) == 125960207u &&
              le32(result + 360) == 17 &&
              le64(result + 328) == 17 &&
              rt.tasks_retired == 17 &&
              rt.op_calls[uint8_t(Op::EMB_TOKEN)] == 16 &&
              rt.op_calls[uint8_t(Op::LOAD_LN_PARAMS)] == 1 &&
              rt.encoder_layers_completed == 0 &&
              rt.decision_layers_completed == 0,
              "accepted gamma fault first cause and cleanup");
      require(std::all_of(result + 128, result + 272,
                          [](uint8_t value) { return value == 0; }),
              "zero failure logits");
      std::cout << "PERSISTENT_CSIM_FAILURE_PASS id=2 tasks=17 flags=9\n";
      continue;
    }
    require(le16(result + 10) == 0 && le32(result + 112) == 11 &&
            le16(result + 100) == 16 * B &&
            le16(result + 102) == 2 * B &&
            le64(result + 328) == (B == 2 ? 37158u : 18895u),
            "committed successful result " + scenario);
    std::vector<uint8_t> final(B * 18 * 4);
    for (unsigned b = 0; b < B; ++b) {
      std::memcpy(final.data() + b * 18 * 4,
                  result + 128 + b * 16 * 4, 16 * 4);
      std::memcpy(final.data() + (b * 18 + 16) * 4,
                  result + 256 + b * 2 * 4, 2 * 4);
    }
    const auto expected_final = read_file(obs.expected / "final18.f32.bin");
    require(expected_final.size() == final.size() &&
            std::memcmp(expected_final.data(), final.data(), final.size()) == 0,
            "independent final18 " + scenario);
    obs.compared_values += final.size() / 4;
    require(obs.names.size() == 46 &&
            rt.tasks_retired == (B == 2 ? 37158u : 18895u) &&
            rt.op_calls[uint8_t(Op::QUANT)] == (B == 2 ? 1924u : 962u) &&
            rt.encoder_layers_completed == 28 &&
            rt.decision_layers_completed == 2,
            "complete production graph " + scenario);
    total_values += obs.compared_values;
    std::cout << "PERSISTENT_CSIM_REQUEST_PASS scenario=" << scenario
              << " id=" << invocation + 1 << " checkpoints=47 values="
              << obs.compared_values << " tasks=" << rt.tasks_retired << '\n';
  }
  std::cout << "PERSISTENT_FULL_KERNEL_CSIM_PASS requests=4 normal=3 "
               "checkpoints=141 values=" << total_values
            << " recovered_fault=1\n";
  return 0;
}
