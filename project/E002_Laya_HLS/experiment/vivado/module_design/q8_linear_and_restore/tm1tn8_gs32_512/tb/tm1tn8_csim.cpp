#include "q8_tm1tn8_engine.h"
#include "q8_tm1tn8_abi.h"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace q8_tm1tn8;

namespace {
std::vector<uint8_t> read_bytes(const std::string& path) {
  std::ifstream file(path, std::ios::binary | std::ios::ate);
  if (!file) throw std::runtime_error("open " + path);
  const auto size = file.tellg();
  if (size < 0) throw std::runtime_error("size " + path);
  file.seekg(0);
  std::vector<uint8_t> data(size_t(size), uint8_t(0));
  if (!file.read(reinterpret_cast<char*>(data.data()), size))
    throw std::runtime_error("read " + path);
  return data;
}

void check(bool condition, const char* what) {
  if (!condition) throw std::runtime_error(what);
}

std::vector<uint32_t> little_words(const std::vector<uint8_t>& data) {
  check(data.size() % 4 == 0, "word alignment");
  std::vector<uint32_t> words(data.size() / 4);
  for (size_t i = 0; i < words.size(); ++i)
    words[i] = uint32_t(data[4*i]) | (uint32_t(data[4*i+1]) << 8) |
               (uint32_t(data[4*i+2]) << 16) | (uint32_t(data[4*i+3]) << 24);
  return words;
}

std::vector<ap_uint<512>> wide_bytes(const std::vector<uint8_t>& data) {
  check(data.size() % 64 == 0, "wide input alignment");
  std::vector<ap_uint<512>> words(data.size() / 64);
  for (size_t i = 0; i < words.size(); ++i) {
    ap_uint<512> word = 0;
    for (unsigned b = 0; b < 64; ++b)
      word.range(8*b+7, 8*b) = data[64*i+b];
    words[i] = word;
  }
  return words;
}

struct Inputs {
  std::vector<ap_uint<512>> q0, q1, scale;
  std::vector<uint32_t> aux;
};

Inputs load_model(const std::string& package) {
  Inputs m;
  m.q0 = wide_bytes(read_bytes(package + "/w_q0.bin"));
  m.q1 = wide_bytes(read_bytes(package + "/w_q1.bin"));
  m.scale = wide_bytes(read_bytes(package + "/w_scale.bin"));
  m.aux = little_words(read_bytes(package + "/aux.bin"));
  return m;
}

void check_trace(const std::vector<uint32_t>& observed,
                 const std::string& fixtures, const std::string& name,
                 unsigned rows, unsigned K, unsigned N) {
  const unsigned G = K / 32;
  const auto q = little_words(read_bytes(fixtures + "/" + name + "_a8_q.bin"));
  const auto scale = read_bytes(fixtures + "/" + name + "_a8_scale.bin");
  const auto steps = little_words(read_bytes(fixtures + "/" + name + "_steps_u32x6.bin"));
  check(q.size() == rows * G * 8 && scale.size() == rows * G * 2 &&
        steps.size() == rows * G * N * 6, "gold trace shape");
  for (unsigned i = 0; i < q.size(); ++i)
    if (observed[kTraceQWord + i] != q[i])
      throw std::runtime_error("quant q first mismatch at word " + std::to_string(i));
  for (unsigned i = 0; i < rows * G; ++i) {
    const uint16_t expected = uint16_t(scale[2*i]) | (uint16_t(scale[2*i+1]) << 8);
    const uint32_t actual = observed[kTraceScaleWord + i/2];
    if (uint16_t(actual >> (16 * (i % 2))) != expected)
      throw std::runtime_error("quant half first mismatch at group " + std::to_string(i));
  }
  for (unsigned g = 0; g < G; ++g) {
    const unsigned offset = (g * N) * 6;
    const unsigned at = kTraceGroupWord + g * kTraceGroupWords;
    for (unsigned field = 0; field < 6; ++field)
      if (observed[at + field] != steps[offset + field])
        throw std::runtime_error("group numeric first mismatch g=" +
                                 std::to_string(g) + " field=" +
                                 std::to_string(field));
    check(observed[at + T_GROUP] == g && observed[at + T_VALID] == 1,
          "group tag/valid");
  }
  check(observed[O_TRACE_GROUP_COUNT] == G, "selected group count");
}

void check_tiles(hls::stream<ap_uint<288>>& out0,
                 hls::stream<ap_uint<288>>& out1,
                 const std::vector<uint32_t>& descriptor,
                 const std::string& fixtures, const std::string& name) {
  const unsigned rows = descriptor[D_ROWS], N = descriptor[D_N];
  const bool qkv = N == 3072;
  const auto gold = little_words(read_bytes(fixtures + "/" + name + "_output_f32.bin"));
  check(gold.size() == rows * N, "gold output shape");
  std::vector<uint8_t> seen(rows * N, 0);
  unsigned tiles = 0;
  for (unsigned shard = 0; shard < 2; ++shard) {
    auto& stream = shard ? out1 : out0;
    while (!stream.empty()) {
      const ap_uint<288> packet = stream.read();
      const unsigned n0 = unsigned(packet.range(267, 256));
      const unsigned r = unsigned(packet.range(269, 268));
      const unsigned row0 = unsigned(packet.range(279, 270));
      const unsigned batch = unsigned(packet[280]);
      const unsigned lanes = unsigned(packet.range(284, 281));
      check(unsigned(packet[285]) == unsigned(qkv) &&
            row0 == descriptor[D_ROW0] && batch == descriptor[D_BATCH] &&
            n0 % 8 == 0 && r < rows && lanes == (N - n0 < 8 ? N - n0 : 8),
            "tile tag/shape");
      check(!qkv || (((n0 % 1024) / 64) & 1) == shard,
            "QKV shard routing");
      for (unsigned lane = 0; lane < lanes; ++lane) {
        const unsigned index = r * N + n0 + lane;
        check(index < gold.size() && !seen[index], "tile coverage uniqueness");
        seen[index] = 1;
        const uint32_t actual = uint32_t(packet.range(lane*32+31, lane*32));
        if (actual != gold[index])
          throw std::runtime_error("output first mismatch r=" +
                                   std::to_string(r) + " n=" +
                                   std::to_string(n0 + lane));
      }
      ++tiles;
    }
  }
  for (unsigned i = 0; i < seen.size(); ++i)
    if (!seen[i]) throw std::runtime_error("missing output element " + std::to_string(i));
  check(tiles == rows * ((N + 7) / 8), "tile count");
}

void invoke(const Inputs& model, const std::string& descriptors,
            const std::string& fixtures, const std::string& command_name,
            const std::string& fixture_name) {
  auto descriptor = little_words(read_bytes(descriptors + "/" + command_name + ".bin"));
  check(descriptor.size() == 128 && descriptor[D_MAGIC] == kDescriptorMagic,
        "Q8T1 descriptor identity");
  std::vector<ap_uint<512>> activation(1);
  const bool run = descriptor[D_COMMAND] == RUN_TILE;
  if (run) activation = wide_bytes(read_bytes(fixtures + "/" + fixture_name +
                                              "_source_f32.bin"));
  std::vector<uint32_t> observed(kObservedWords, 0xd15ea5ed);
  hls::stream<ap_uint<256>> config;
  hls::stream<ap_uint<288>> out0, out1;
  hls::stream<ap_uint<1>> finish;
  hls::stream<ap_uint<129>> completion;
  ap_uint<129> ack = 0;
  if (run) {
    const uint64_t physical = descriptor[D_N] == 2 ? 64 :
                              uint64_t(descriptor[D_ROWS]) * 6144;
    ack.range(64, 1) = physical;
    if (descriptor[D_N] == 3072) ack.range(128, 65) = physical;
  }
  completion.write(ack); // CSim models only successful physical retirement.
  q8_tm1tn8_engine(descriptor.data(), model.q0.data(), model.q1.data(),
                    model.scale.data(), model.aux.data(), activation.data(),
                    config, out0, out1, finish, completion, observed.data());
  check(!config.empty() && !finish.empty() && completion.empty(),
        "stream command framing");
  const ap_uint<256> cfg = config.read();
  check(uint64_t(cfg.range(63, 0)) == join_u64(descriptor[D_OUT0_BASE_LO],
                                               descriptor[D_OUT0_BASE_HI]) &&
        uint64_t(cfg.range(127, 64)) == join_u64(descriptor[D_OUT0_SPAN_LO],
                                                 descriptor[D_OUT0_SPAN_HI]),
        "writer config identity");
  check(unsigned(finish.read()) == 1, "writer end marker");
  check(observed[O_MAGIC] == kObservedMagic && observed[O_STATUS] == 0 &&
        observed[O_DONE_STATUS] == 0 && observed[O_DONE_DRAINED] == 1 &&
        observed[O_DONE_TASK] == descriptor[D_TASK_ID], "command status");
  if (run) {
    const unsigned rows = descriptor[D_ROWS], K = descriptor[D_K];
    const unsigned N = descriptor[D_N], G = K / 32;
    check(observed[O_QUANT_GROUPS] == rows * G &&
          observed[O_QUANT_INPUTS] == rows * K &&
          observed[O_ACCEPTED_ISSUES] == rows * G * ((N + 7) / 8) &&
          observed[O_RETIRED_GROUPS] == observed[O_ACCEPTED_ISSUES] &&
          observed[O_COMMITTED_WRITES] == rows * N &&
          join_u64(observed[O_DOT_MACS_LO], observed[O_DOT_MACS_HI]) ==
              uint64_t(rows) * K * N, "complete K/N work counts");
    if (descriptor[D_FLAGS]) check_trace(observed, fixtures, fixture_name, rows, K, N);
    check_tiles(out0, out1, descriptor, fixtures, fixture_name);
  } else check(out0.empty() && out1.empty(), "LOAD emitted output");
  std::printf("TM1TN8_CSIM_COMMAND_PASS name=%s rows=%u K=%u N=%u\n",
              command_name.c_str(), descriptor[D_ROWS], descriptor[D_K],
              descriptor[D_N]);
}
} // namespace

int main(int argc, char** argv) {
  try {
    check(argc == 5, "usage: tm1tn8_csim PACKAGE DESCRIPTORS FIXTURES act|qkv");
    const Inputs model = load_model(argv[1]);
    const std::string kind = argv[4];
    if (kind == "act") {
      invoke(model, argv[2], argv[3], "act_load", "act");
      invoke(model, argv[2], argv[3], "act_run_trace", "act");
    } else if (kind == "qkv") {
      invoke(model, argv[2], argv[3], "qkv_load", "qkv_row1");
      invoke(model, argv[2], argv[3], "qkv_run1_trace", "qkv_row1");
      invoke(model, argv[2], argv[3], "qkv_run4_trace", "qkv_rows4");
      invoke(model, argv[2], argv[3], "qkv_run4_off", "qkv_rows4");
    } else throw std::runtime_error("case must be act or qkv");
    std::printf("TM1TN8_CSIM_PASS case=%s\n", kind.c_str());
    return 0;
  } catch (const std::exception& e) {
    std::fprintf(stderr, "TM1TN8_CSIM_FAIL %s\n", e.what());
    return 1;
  }
}
