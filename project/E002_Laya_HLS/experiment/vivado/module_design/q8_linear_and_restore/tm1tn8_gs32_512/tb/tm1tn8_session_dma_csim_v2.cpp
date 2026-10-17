#include "q8_tm1tn8_session_dma_v2.h"
#include "q8_tm1tn8_session_abi_v2.h"
#include "laya_model_layout_generated.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
namespace v2 = q8_tm1tn8_v2;
using namespace q8_tm1tn8;

void check(bool okay, const char* why) {
  if (!okay) throw std::runtime_error(why);
}

std::vector<uint8_t> read_bytes(const std::string& path, size_t offset = 0,
                                size_t count = SIZE_MAX) {
  std::ifstream input(path, std::ios::binary | std::ios::ate);
  check(bool(input), "open model/fixture");
  const auto size = size_t(input.tellg());
  check(offset <= size, "model offset");
  if (count == SIZE_MAX) count = size - offset;
  check(count <= size - offset, "model length");
  std::vector<uint8_t> bytes(count);
  input.seekg(offset);
  if (count) check(bool(input.read(reinterpret_cast<char*>(bytes.data()), count)),
                   "model read");
  return bytes;
}

template <typename T>
std::vector<T> read_hex(const std::string& path) {
  std::ifstream input(path);
  check(bool(input), "open hex");
  std::vector<T> result;
  std::string token;
  while (input >> token) result.push_back(T(std::stoull(token, nullptr, 16)));
  check(input.eof(), "read hex");
  return result;
}

void fill_wide(std::vector<ap_uint<512>>& target, size_t offset_bytes,
               const std::vector<uint8_t>& bytes) {
  check(offset_bytes % 64 == 0 && bytes.size() % 64 == 0 &&
        offset_bytes + bytes.size() <= target.size() * 64,
        "wide model window");
  for (size_t i = 0; i < bytes.size(); ++i)
    target[(offset_bytes+i)/64].range(((offset_bytes+i)%64)*8+7,
                                     ((offset_bytes+i)%64)*8) = bytes[i];
}

struct Model {
  std::vector<ap_uint<512>> q0, q1, scale, activation;
  std::vector<uint32_t> aux;
};

Model prepare(const std::string& package, const std::string& fixture) {
  Model model;
  model.q0.resize(laya::full::kFullModelBoSizes[1] / 64);
  model.q1.resize(1);
  model.scale.resize(laya::full::kFullModelBoSizes[3] / 64);
  model.aux.resize(laya::full::kFullModelBoSizes[4] / 4);
  model.activation.resize(16);
  // ACT is the last packed Q8 matrix in the generated table. Cross-check
  // the exact package offsets independently of the command descriptor.
  const auto* act = static_cast<const laya::full::FullWeightDescriptor*>(nullptr);
  for (const auto& candidate : laya::full::kFullWeights)
    if (candidate.key.family == 12 && candidate.key.layer == 255)
      act = &candidate;
  check(act != nullptr && act->q_span[0] == 2048 &&
        act->q_span[1] == 0 && act->scale_span == 128 &&
        act->bias_span == 8, "ACT model record");
  fill_wide(model.q0, act->q_base[0],
            read_bytes(package + "/w_q0.bin", act->q_base[0], 2048));
  fill_wide(model.scale, act->scale_base,
            read_bytes(package + "/w_scale.bin", act->scale_base, 128));
  const auto header = read_bytes(package + "/aux.bin", 0, 128);
  const auto bias = read_bytes(package + "/aux.bin", act->bias_base, 8);
  for (unsigned i = 0; i < 32; ++i)
    for (unsigned j = 0; j < 4; ++j)
      model.aux[i] |= uint32_t(header[4*i+j]) << (8*j);
  for (unsigned i = 0; i < 2; ++i)
    for (unsigned j = 0; j < 4; ++j)
      model.aux[(act->bias_base/4)+i] |= uint32_t(bias[4*i+j]) << (8*j);
  const auto source = read_bytes(fixture + "/act_source_f32.bin");
  check(source.size() == 1024, "ACT source length");
  fill_wide(model.activation, 0, source);
  return model;
}

void run_one(const Model& model, const std::string& inputs,
             const char* name, unsigned expected_status,
             unsigned expected_state, bool trace_on) {
  const auto descriptor = read_hex<uint32_t>(inputs + "/" + name + ".hex");
  const auto binding = read_hex<uint64_t>(inputs + "/binding.hex");
  check(descriptor.size() == 256 && binding.size() == 18,
        "Q8S2 descriptor/binding length");
  hls::stream<ap_uint<64>> binding_context;
  hls::stream<ap_uint<256>> writer_config, compute_config;
  hls::stream<ap_uint<288>> bias_tiles;
  hls::stream<ap_uint<2816>> group_issues;
  hls::stream<ap_uint<1>> finish;
  hls::stream<ap_uint<512>> completion;
  for (uint64_t beat : binding) binding_context.write(beat);
  const bool run = descriptor[D_COMMAND] == v2::RUN_TILE;
  ap_uint<512> ack = 0;
  if (run) {
    ack.range(64, 1) = 64;
    ack.range(257, 226) = 8;
    ack.range(289, 258) = 2;
    ack.range(353, 290) = 512;
    ack.range(385, 354) = 8;
    ack.range(417, 386) = trace_on ? 64 : 0;
    ack.range(449, 418) = trace_on ? 8 : 0;
  }
  completion.write(ack);
  std::vector<uint32_t> observed(kObservedWords, 0xd15ea5ed);
  q8_tm1tn8_session_dma_v2(
      descriptor.data(), model.q0.data(), model.q1.data(),
      model.scale.data(), model.aux.data(), model.activation.data(),
      binding_context, writer_config, compute_config, bias_tiles,
      group_issues, finish, completion, observed.data());
  check(binding_context.empty() && completion.empty() &&
        !writer_config.empty() && !compute_config.empty() &&
        !finish.empty(), "Q8S2 stream framing");
  const auto wc = writer_config.read(), cc = compute_config.read();
  check(uint64_t(wc.range(63, 0)) ==
        join_u64(descriptor[D_OUT0_BASE_LO], descriptor[D_OUT0_BASE_HI]) &&
        unsigned(cc[225]) == unsigned(run && expected_status == 0) &&
        unsigned(finish.read()) == 1, "Q8S2 control framing");
  check(observed[O_MAGIC] == v2::kObservedMagic &&
        observed[O_STATUS] == expected_status &&
        observed[v2::O_MODEL_SESSION_STATE] == expected_state &&
        observed[v2::O_BINDING_WORDS] == 18 &&
        observed[v2::O_CANDIDATE_BUILD_SHA256_0] == descriptor[88],
        "Q8S2 status/identity");
  const bool load = descriptor[D_COMMAND] == v2::LOAD_W;
  check(observed[v2::O_SCALE_CHECKS_LO] ==
        (load && expected_status == 0 && trace_on ? 64u : 0u) &&
        observed[v2::O_SCALE_CHECKS_HI] == 0,
        "Q8S2 strict/fast scale check count");
  check(observed[port_useful_lo(P_W_Q0)] ==
        (load && expected_status == 0 ? 2048u : 0u) &&
        observed[port_useful_lo(P_W_SCALE)] ==
        (load && expected_status == 0 ? 128u : 0u) &&
        observed[port_useful_lo(P_ACTIVATION)] ==
        (run && expected_status == 0 ? 1024u : 0u),
        "Q8S2 model/source read scope");
  const unsigned expected_issues = run && expected_status == 0 ? 8 : 0;
  const auto qgold = read_hex<uint32_t>(inputs + "/a8q.hex");
  const auto halfgold = read_hex<uint32_t>(inputs + "/a8half.hex");
  check(qgold.size() == 64 && halfgold.size() == 4,
        "independent ACT quant gold shape");
  for (unsigned i = 0; i < expected_issues; ++i) {
    check(!group_issues.empty(), "Q8S2 missing issue");
    const auto issue = group_issues.read();
    check(unsigned(issue.range(2606, 2601)) == i, "Q8S2 issue order");
    for (unsigned j = 0; j < 8; ++j)
      check(uint32_t(issue.range(j*32+31, j*32)) == qgold[i*8+j],
            "Q8S2 ACT quant q bits");
  }
  check(group_issues.empty(), "Q8S2 extra issue");
  if (run && expected_status == 0)
    for (unsigned i = 0; i < 64; ++i)
      check(observed[kTraceQWord+i] ==
            (trace_on ? qgold[i] : 0xd15ea5edu),
            "Q8S2 observed quant q bits");
  if (run && expected_status == 0)
    for (unsigned i = 0; i < 4; ++i)
      check(observed[kTraceScaleWord+i] ==
            (trace_on ? halfgold[i] : 0xd15ea5edu),
            "Q8S2 observed quant half bits");
  if (run && expected_status == 0) {
    check(!bias_tiles.empty(), "Q8S2 missing bias");
    const auto bias = bias_tiles.read();
    check(unsigned(bias.range(264, 256)) == 0 &&
          unsigned(bias.range(272, 265)) == 3 &&
          unsigned(bias[273]) == 1 &&
          observed[O_DONE_TASK] == descriptor[D_TASK_ID] &&
          observed[O_ACCEPTED_ISSUES] == 8, "Q8S2 RUN result");
  }
  check(bias_tiles.empty(), "Q8S2 unexpected bias");
  std::printf("TM1TN8_SESSION_DMA_CSIM_COMMAND_PASS name=%s status=%u\n",
              name, expected_status);
}
}  // namespace

int main(int argc, char** argv) {
  try {
    check(argc == 5, "usage: csim PACKAGE FIXTURE INPUTS strict|fast");
    const std::string profile = argv[4];
    check(profile == "strict" || profile == "fast", "profile");
    const Model model = prepare(argv[1], argv[2]);
    const bool trace = profile == "strict";
    run_one(model, argv[3], "register", 0, 1, trace);
    run_one(model, argv[3], "load1", 0, 1, trace);
    run_one(model, argv[3], "run1", 0, 1, trace);
    run_one(model, argv[3], "load2", 0, 1, trace);
    run_one(model, argv[3], "run2", 0, 1, trace);
    run_one(model, argv[3], "revoke", 0, 0, trace);
    run_one(model, argv[3], "load1", 7, 0, trace);
    std::printf("TM1TN8_SESSION_DMA_CSIM_V2_PASS profile=%s\n",
                profile.c_str());
    return 0;
  } catch (const std::exception& error) {
    std::fprintf(stderr, "TM1TN8_SESSION_DMA_CSIM_V2_FAIL %s\n",
                 error.what());
    return 1;
  }
}
