#include "q8_joint_tm4tn8.h"
#include "q8_joint_abi.h"

#include <algorithm>
#include <cerrno>
#include <cstdint>
#include <cstring>
#include <fcntl.h>
#include <iostream>
#include <stdexcept>
#include <string>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

namespace {
using namespace q8_joint;
constexpr uint32_t kSentinel = 0xa5a5a5a5u;

void require(bool pass, const std::string& what) {
  if (!pass) throw std::runtime_error(what);
}

std::vector<uint8_t> read_file(const std::string& path, size_t wanted = 0) {
  const int fd = ::open(path.c_str(), O_RDONLY);
  require(fd >= 0, "open " + path);
  struct stat st {};
  require(::fstat(fd, &st) == 0, "stat " + path);
  if (wanted) require(size_t(st.st_size) == wanted, "size " + path);
  std::vector<uint8_t> bytes(size_t(st.st_size));
  size_t off = 0;
  while (off < bytes.size()) {
    const ssize_t n = ::read(fd, bytes.data() + off, bytes.size() - off);
    require(n > 0, "read " + path);
    off += size_t(n);
  }
  ::close(fd);
  return bytes;
}

uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}

struct Map {
  int fd = -1;
  size_t size = 0;
  uint8_t* data = nullptr;
  explicit Map(const std::string& path) {
    fd = ::open(path.c_str(), O_RDONLY);
    require(fd >= 0, "map open " + path);
    struct stat st {};
    require(::fstat(fd, &st) == 0, "map stat " + path);
    size = size_t(st.st_size);
    data = static_cast<uint8_t*>(::mmap(nullptr, size, PROT_READ | PROT_WRITE,
                                         MAP_PRIVATE, fd, 0));
    require(data != MAP_FAILED, "mmap " + path);
  }
  ~Map() {
    if (data && data != MAP_FAILED) ::munmap(data, size);
    if (fd >= 0) ::close(fd);
  }
  Map(const Map&) = delete;
  Map& operator=(const Map&) = delete;
};

std::vector<uint32_t> descriptor(const std::string& dir, const char* name) {
  auto raw = read_file(dir + "/" + name + ".bin", 512);
  std::vector<uint32_t> out(128);
  for (unsigned i = 0; i < 128; ++i) out[i] = le32(raw.data() + 4 * i);
  return out;
}

void activation_from(const std::vector<uint8_t>& input, ap_uint<512> out[16]) {
  require(input.size() == 1024, "activation fixture bytes");
  for (unsigned b = 0; b < 16; ++b) {
    out[b] = 0;
    for (unsigned lane = 0; lane < 16; ++lane)
      out[b].range(32 * lane + 31, 32 * lane) =
          le32(input.data() + b * 64 + lane * 4);
  }
}

void reset_buffers(uint32_t out0[16], uint32_t out1[16],
                   std::vector<uint32_t>& observed) {
  for (unsigned i = 0; i < 16; ++i) out0[i] = out1[i] = kSentinel;
  std::fill(observed.begin(), observed.end(), kSentinel);
}

void expect_status(const std::vector<uint32_t>& o, uint32_t command,
                   uint32_t status, uint32_t last, uint32_t done) {
  require(o[O_MAGIC] == kObservedMagic && o[O_VERSION] == 1, "observed ABI");
  require(o[O_COMMAND] == command && o[O_STATUS] == status,
          "command/status expected=" + std::to_string(command) + "/" +
          std::to_string(status) + " got=" + std::to_string(o[O_COMMAND]) + "/" +
          std::to_string(o[O_STATUS]) + " detail=" + std::to_string(o[O_DETAIL]) +
          " phase=" + std::to_string(o[O_ERROR_PHASE]));
  require(o[O_LAST_TASK] == last && o[O_DONE_TASK] == done, "retired task IDs");
  require(o[O_PORT_BYTES_BEGIN] == 512 && o[O_PORT_BYTES_BEGIN + 2] == 512,
          "complete descriptor port read");
  for (unsigned i = O_HEADER_WORDS; i < kTraceQWord; ++i)
    require(o[i] == kSentinel, "unwritten observed gap");
}

void expect_out(const uint32_t out0[16], const uint32_t out1[16],
                const std::vector<uint8_t>& expected) {
  require(expected.size() == 8, "expected F32 bytes");
  for (unsigned n = 0; n < 2; ++n)
    require(out0[n] == le32(expected.data() + 4 * n), "complete ACT final F32");
  for (unsigned i = 2; i < 16; ++i)
    require(out0[i] == kSentinel, "out0 unwritten neighbor");
  for (unsigned i = 0; i < 16; ++i)
    require(out1[i] == kSentinel, "unused out1 shard");
}

void expect_no_out(const uint32_t out0[16], const uint32_t out1[16]) {
  for (unsigned i = 0; i < 16; ++i)
    require(out0[i] == kSentinel && out1[i] == kSentinel,
            "rejected command wrote output");
}

void expect_trace(const std::vector<uint32_t>& o,
                  const std::vector<uint8_t>& q,
                  const std::vector<uint8_t>& scale,
                  const std::vector<uint8_t>& selected,
                  unsigned column,
                  const std::vector<uint8_t>& bias,
                  const std::vector<uint8_t>& expected) {
  require(q.size() == 256 && scale.size() == 16 && selected.size() == 256,
          "trace fixture sizes");
  for (unsigned i = 0; i < 64; ++i)
    require(o[kTraceQWord + i] == le32(q.data() + i * 4),
            "all ACT A8 q words " + std::to_string(i));
  for (unsigned i = 0; i < 4; ++i)
    require(o[kTraceScaleWord + i] == le32(scale.data() + i * 4),
            "all ACT A8 half scales " + std::to_string(i));
  for (unsigned i = 0; i < 64; ++i)
    require(o[kTraceGroupWord + i] == le32(selected.data() + i * 4),
            "selected actual group trace " + std::to_string(i));
  require(o[O_TRACE_ROW] == 0 && o[O_TRACE_COLUMN] == column &&
          o[O_TRACE_GROUP_COUNT] == 8, "trace selection/count");
  require(o[O_TRACE_BIAS_ENABLE] == 1 &&
          o[O_TRACE_BIAS_BITS] == le32(bias.data() + 4 * column) &&
          o[O_TRACE_FINAL_BITS] == le32(expected.data() + 4 * column),
          "selected bias and final bits");
  for (unsigned i = 64; i < kTraceQCapacityWords; ++i)
    require(o[kTraceQWord + i] == kSentinel, "q trace tail sentinel");
  for (unsigned i = 4; i < kTraceScaleCapacityWords; ++i)
    require(o[kTraceScaleWord + i] == kSentinel, "scale trace tail sentinel");
  for (unsigned i = 64; i < kTraceGroupWords * kTraceGroupCapacity; ++i)
    require(o[kTraceGroupWord + i] == kSentinel, "group trace tail sentinel");
}

void expect_trace_off(const std::vector<uint32_t>& o) {
  require(o[O_TRACE_GROUP_COUNT] == 0 && o[O_TRACE_BIAS_ENABLE] == 0,
          "trace-off header");
  for (unsigned i = kTraceQWord;
       i < kTraceGroupWord + kTraceGroupWords * kTraceGroupCapacity; ++i)
    require(o[i] == kSentinel, "trace-off memory sentinel");
}

void expect_run_counts(const std::vector<uint32_t>& o, uint32_t w_reuses,
                       bool trace) {
  require(o[O_W_LOADS] == 1 && o[O_W_REUSES] == w_reuses, "W load/reuse counts");
  require(o[O_QUANT_GROUPS] == 8 && o[O_QUANT_INPUTS] == 256,
          "complete quant coverage");
  require(o[O_ACCEPTED_ISSUES] == 8 && o[O_INFLIGHT] == 0 &&
          o[O_RETIRED_GROUPS] == 8 && o[O_COMMITTED_WRITES] == 2,
          "actual issue/retirement/write counts");
  require(o[O_DOT_MACS_LO] == 512 && o[O_DOT_MACS_HI] == 0, "fullK/N dot work");
  require(o[port_useful_lo(P_ACTIVATION)] == 1024 &&
          o[port_total_lo(P_ACTIVATION)] == 1024 &&
          o[port_useful_lo(P_OUT0)] == 8 &&
          o[port_useful_lo(P_W_Q0)] == 0 &&
          o[port_useful_lo(P_W_SCALE)] == 0,
          "activation/output bytes and no W reread");
  require(o[port_useful_lo(P_OBSERVED)] == (trace ? 1552u : 1024u),
          "observed written-byte accounting");
  require(o[O_W_STATE] == 2 && o[O_A8_STATE] == 2 &&
          o[O_PS_STATE] == 2 && o[O_DST_STATE] == 2,
          "READY only after full completion");
  require(o[O_DONE_OUTPUT_ELEMENTS] == 2 && o[O_DONE_OUTPUT_UNIT] == 1 &&
          o[O_DONE_DRAINED] == 1, "complete F32 TaskDone");
}

void call(const std::vector<uint32_t>& d, Map& q0, Map& q1, Map& scales,
          Map& aux, const ap_uint<512> act[16], uint32_t out0[16],
          uint32_t out1[16], std::vector<uint32_t>& obs) {
  static_assert(sizeof(ap_uint<512>) == 64, "host packed beat size");
  q8_joint_tm4tn8(d.data(),
                   reinterpret_cast<const ap_uint<512>*>(q0.data),
                   reinterpret_cast<const ap_uint<512>*>(q1.data),
                   reinterpret_cast<const ap_uint<512>*>(scales.data),
                   reinterpret_cast<const uint32_t*>(aux.data), act,
                   out0, out1, obs.data());
}
}  // namespace

int main(int argc, char** argv) {
  try {
    require(argc == 4, "usage: test_q8_joint ROOT DESCRIPTOR_DIR legal|fault_load");
    const std::string root = argv[1], dir = argv[2], mode = argv[3];
    require(mode == "legal" || mode == "fault_load", "mode");
    const std::string model = root + "/build/model-attention-rtl-repair-20261008";
    const std::string fix = root + "/vivado/module_design/q8_linear_and_restore/runs/fixture_act_v1/fixture";
    Map q0(model + "/w_q0.bin"), q1(model + "/w_q1.bin");
    Map scale(model + "/w_scale.bin"), aux(model + "/aux.bin");
    auto weight_q = read_file(fix + "/act_w_q0_2048.bin", 2048);
    auto weight_s = read_file(fix + "/act_w_scale_128.bin", 128);
    auto weight_b = read_file(fix + "/act_bias_8.bin", 8);
    require(std::memcmp(q0.data + 184680448, weight_q.data(), 2048) == 0,
            "actual BO q payload identity");
    require(std::memcmp(scale.data + 23085056, weight_s.data(), 128) == 0,
            "actual BO scale payload identity");
    require(std::memcmp(aux.data + 617664, weight_b.data(), 8) == 0,
            "actual BO bias payload identity");
    ap_uint<512> act0[16], act1[16];
    activation_from(read_file(fix + "/act_b0_input_1024.bin", 1024), act0);
    activation_from(read_file(fix + "/act_b1_input_1024.bin", 1024), act1);
    auto q_b0 = read_file(fix + "/act_b0_a8_q_256.bin", 256);
    auto s_b0 = read_file(fix + "/act_b0_a8_scale_16.bin", 16);
    auto e_b0 = read_file(fix + "/act_b0_expected_8.bin", 8);
    auto q_b1 = read_file(fix + "/act_b1_a8_q_256.bin", 256);
    auto s_b1 = read_file(fix + "/act_b1_a8_scale_16.bin", 16);
    auto e_b1 = read_file(fix + "/act_b1_expected_8.bin", 8);
    auto t_b0 = read_file(dir + "/act_b0_selected_trace_256.bin", 256);
    auto t_b1 = read_file(dir + "/act_b1_selected_trace_256.bin", 256);
    auto load = descriptor(dir, "load_w");
    auto run0 = descriptor(dir, "run_b0_trace_n0");
    auto run1 = descriptor(dir, "run_b1_trace_n1");
    auto off = descriptor(dir, "run_b0_trace_off");
    uint32_t out0[16], out1[16];
    std::vector<uint32_t> obs(kObservedWords);

    if (mode == "fault_load") {
      // MAP_PRIVATE keeps the frozen model file untouched.
      const size_t s_off = 23085056;
      const size_t b_off = 617664;
      const uint8_t prior_s1[2] = {scale.data[s_off + 16], scale.data[s_off + 17]};
      const uint8_t prior_s2[2] = {scale.data[s_off + 2], scale.data[s_off + 3]};
      uint8_t prior_bias[4];
      std::memcpy(prior_bias, aux.data + b_off, 4);
      scale.data[s_off + 16] = 0x00; scale.data[s_off + 17] = 0x7c; // n0,g1
      scale.data[s_off + 2] = 0x00; scale.data[s_off + 3] = 0x7c; // n1,g0, earlier byte
      aux.data[b_off + 0] = 0; aux.data[b_off + 1] = 0;
      aux.data[b_off + 2] = 0xc0; aux.data[b_off + 3] = 0x7f; // bias n0 NaN
      reset_buffers(out0, out1, obs);
      call(load, q0, q1, scale, aux, act0, out0, out1, obs);
      expect_status(obs, LOAD_W, 6, 1, 1);
      require(obs[O_BAD_ELEMENT_LO] == 1 && obs[O_W_MAX_CLAIMED] == 1 &&
              obs[O_W_STATE] == 6 && obs[O_W_LOADS] == 0,
              "failed LOAD first-error n0/g1 before earlier-byte n1/g0 and bias");
      expect_no_out(out0, out1);
      scale.data[s_off + 16] = prior_s1[0]; scale.data[s_off + 17] = prior_s1[1];
      scale.data[s_off + 2] = prior_s2[0]; scale.data[s_off + 3] = prior_s2[1];
      std::memcpy(aux.data + b_off, prior_bias, 4);
      auto retry = load;
      retry[D_TASK_ID] = 2; retry[D_W_EPOCH] = 2; retry[D_DST_EPOCH] = 2;
      reset_buffers(out0, out1, obs);
      call(retry, q0, q1, scale, aux, act0, out0, out1, obs);
      expect_status(obs, LOAD_W, 0, 2, 2);
      require(obs[O_W_MAX_CLAIMED] == 2 && obs[O_W_LOADS] == 1,
              "recovered LOAD exact next epoch");
      auto recover = run0;
      recover[D_QUANT_TASK_ID] = 3; recover[D_TASK_ID] = 4;
      recover[D_W_EPOCH] = 2;
      reset_buffers(out0, out1, obs);
      call(recover, q0, q1, scale, aux, act0, out0, out1, obs);
      expect_status(obs, RUN_TILE, 0, 4, 4);
      expect_out(out0, out1, e_b0);
      expect_trace(obs, q_b0, s_b0, t_b0, 0, weight_b, e_b0);
      expect_run_counts(obs, 0, true);
      ::usleep(300000);  // Keep the mapped test process alive for the 0.2 s RSS sampler.
      std::cout << "Q8_JOINT_ACT_FAULT_LOAD_RECOVERY_PASS\n";
      return 0;
    }

    reset_buffers(out0, out1, obs);
    call(load, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, LOAD_W, 0, 1, 1);
    require(obs[O_W_STATE] == 2 && obs[O_W_LOADS] == 1 &&
            obs[port_useful_lo(P_W_Q0)] == 2048 &&
            obs[port_useful_lo(P_W_Q1)] == 0 &&
            obs[port_useful_lo(P_W_SCALE)] == 128 &&
            obs[port_useful_lo(P_AUX)] == 136 &&
            obs[O_DONE_OUTPUT_ELEMENTS] == 8 * 8 * 34 &&
            obs[O_DONE_OUTPUT_UNIT] == 3,
            "complete physical LOAD and byte accounting");
    expect_no_out(out0, out1);

    auto high_id = run0;
    high_id[D_SRC_ID] = 0x10a;
    reset_buffers(out0, out1, obs);
    call(high_id, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, RUN_TILE, 3, 1, 0);
    require(obs[O_A8_MAX_CLAIMED] == 0 && obs[O_PS_MAX_CLAIMED] == 0,
            "narrow-field rejection did not claim");
    expect_no_out(out0, out1);

    auto wrong_tag = run0;
    wrong_tag[D_MODEL_TAG_0] ^= 1;
    reset_buffers(out0, out1, obs);
    call(wrong_tag, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, RUN_TILE, 2, 1, 0);
    expect_no_out(out0, out1);

    reset_buffers(out0, out1, obs);
    call(run0, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, RUN_TILE, 0, 3, 3);
    require(obs[O_QUANT_DONE_TASK] == 2 && obs[O_QUANT_DONE_STATUS] == 0 &&
            obs[O_A8_EPOCH] == 1 && obs[O_PS_EPOCH] == 1 &&
            obs[O_DST_MAX_CLAIMED] == 1, "first quant/linear retirement");
    expect_out(out0, out1, e_b0);
    expect_trace(obs, q_b0, s_b0, t_b0, 0, weight_b, e_b0);
    expect_run_counts(obs, 0, true);

    reset_buffers(out0, out1, obs);
    call(run1, q0, q1, scale, aux, act1, out0, out1, obs);
    expect_status(obs, RUN_TILE, 0, 5, 5);
    require(obs[O_QUANT_DONE_TASK] == 4 && obs[O_A8_EPOCH] == 2 &&
            obs[O_PS_EPOCH] == 2 && obs[O_DST_MAX_CLAIMED] == 2,
            "second batch/task/epoch retirement");
    expect_out(out0, out1, e_b1);
    expect_trace(obs, q_b1, s_b1, t_b1, 1, weight_b, e_b1);
    expect_run_counts(obs, 1, true);

    reset_buffers(out0, out1, obs);
    call(run1, q0, q1, scale, aux, act1, out0, out1, obs);
    expect_status(obs, RUN_TILE, 7, 5, 0);
    require(obs[O_A8_MAX_CLAIMED] == 2 && obs[O_PS_MAX_CLAIMED] == 2,
            "replay did not consume task/epoch");
    expect_no_out(out0, out1);

    reset_buffers(out0, out1, obs);
    call(off, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, RUN_TILE, 0, 7, 7);
    expect_out(out0, out1, e_b0);
    expect_trace_off(obs);
    expect_run_counts(obs, 2, false);

    auto bad_quant = off;
    bad_quant[D_QUANT_TASK_ID] = 8; bad_quant[D_TASK_ID] = 9;
    bad_quant[D_PS_EPOCH] = 4; bad_quant[D_DST_EPOCH] = 4;
    ap_uint<512> nan_act[16];
    for (unsigned i = 0; i < 16; ++i) nan_act[i] = act0[i];
    nan_act[0].range(2 * 32 + 31, 2 * 32) = 0x7fc00000u;
    nan_act[0].range(7 * 32 + 31, 7 * 32) = 0x7fc00000u;
    reset_buffers(out0, out1, obs);
    call(bad_quant, q0, q1, scale, aux, nan_act, out0, out1, obs);
    expect_status(obs, RUN_TILE, 6, 8, 8);
    require(obs[O_QUANT_DONE_TASK] == 8 && obs[O_QUANT_DONE_STATUS] == 6 &&
            obs[O_LINEAR_STARTED] == 0 && obs[O_A8_MAX_CLAIMED] == 4 &&
            obs[O_PS_MAX_CLAIMED] == 3 && obs[O_DST_MAX_CLAIMED] == 3 &&
            obs[O_BAD_ELEMENT_LO] == 2 && obs[O_A8_STATE] == 6 &&
            obs[O_W_STATE] == 2, "quant failure only retires quant");
    expect_no_out(out0, out1);

    auto recover = bad_quant;
    recover[D_QUANT_TASK_ID] = 9; recover[D_TASK_ID] = 10;
    reset_buffers(out0, out1, obs);
    call(recover, q0, q1, scale, aux, act0, out0, out1, obs);
    expect_status(obs, RUN_TILE, 0, 10, 10);
    require(obs[O_QUANT_DONE_TASK] == 9 && obs[O_A8_MAX_CLAIMED] == 5 &&
            obs[O_PS_MAX_CLAIMED] == 4 && obs[O_DST_MAX_CLAIMED] == 4,
            "next legal recovery claims exactly next epochs");
    expect_out(out0, out1, e_b0);
    expect_trace_off(obs);
    expect_run_counts(obs, 3, false);
    ::usleep(300000);  // Keep the mapped test process alive for the 0.2 s RSS sampler.
    std::cout << "Q8_JOINT_ACT_STRICT_CPU_PASS legal=4 trace=2 rejects=3 quant_fault=1 recovery=1\n";
    return 0;
  } catch (const std::exception& e) {
    std::cerr << "Q8_JOINT_ACT_STRICT_CPU_FAIL " << e.what() << '\n';
    return 1;
  }
}
