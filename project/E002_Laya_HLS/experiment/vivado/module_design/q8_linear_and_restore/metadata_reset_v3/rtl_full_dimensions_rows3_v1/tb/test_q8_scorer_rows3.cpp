#include "q8_joint_tm4tn8.h"
#include "q8_joint_abi.h"

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

// Dormant source until the separate rows3 CPU execution gate.
namespace {
using namespace q8_joint;
constexpr size_t kPage = 4096;
constexpr size_t kRows = 3;
constexpr uint32_t kSentinel = 0xa5a5a5a5u;

void need(bool ok, const std::string& message) {
  if (!ok) throw std::runtime_error(message);
}

std::vector<uint8_t> read_file(const std::string& path, size_t size) {
  std::ifstream input(path, std::ios::binary | std::ios::ate);
  need(bool(input), "open " + path);
  need(size_t(input.tellg()) == size, "size " + path);
  std::vector<uint8_t> raw(size);
  input.seekg(0);
  input.read(reinterpret_cast<char*>(raw.data()), size);
  need(bool(input), "read " + path);
  return raw;
}

uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}

struct MappedBo {
  int fd = -1;
  size_t size = 0;
  const uint8_t* data = nullptr;
  explicit MappedBo(const std::string& path) {
    fd = ::open(path.c_str(), O_RDONLY);
    need(fd >= 0, "open BO " + path);
    struct stat st {};
    need(::fstat(fd, &st) == 0 && st.st_size > 0, "stat BO " + path);
    size = size_t(st.st_size);
    void* address = ::mmap(nullptr, size, PROT_READ, MAP_PRIVATE, fd, 0);
    need(address != MAP_FAILED, "mmap BO " + path);
    data = static_cast<const uint8_t*>(address);
  }
  ~MappedBo() {
    if (data) ::munmap(const_cast<uint8_t*>(data), size);
    if (fd >= 0) ::close(fd);
  }
  MappedBo(const MappedBo&) = delete;
  MappedBo& operator=(const MappedBo&) = delete;
};

void compare(const uint8_t* actual, const std::vector<uint8_t>& expected,
             const std::string& label) {
  for (size_t i = 0; i < expected.size(); ++i)
    if (actual[i] != expected[i])
      throw std::runtime_error(label + " first bad byte " + std::to_string(i) +
                               " actual=" + std::to_string(actual[i]) +
                               " expected=" + std::to_string(expected[i]));
}

void original_pages(const std::string& model, const std::string& fixture,
                    const MappedBo& q0, const MappedBo& q1,
                    const MappedBo& scale, const MappedBo& aux) {
  (void)model;
  const auto q0_page = read_file(fixture + "/pages/w_q0.bin", 524288);
  const auto q1_page = read_file(fixture + "/pages/w_q1.bin", 524288);
  const auto scale_page = read_file(fixture + "/pages/w_scale.bin", 65536);
  const auto aux_page = read_file(fixture + "/pages/aux.bin", 3 * kPage);
  need(q0.size >= 184156160 + q0_page.size() &&
       q1.size >= 184156160 + q1_page.size() &&
       scale.size >= 23019520 + scale_page.size() &&
       aux.size == 1671872, "original BO bounds");
  compare(q0.data + 184156160, q0_page, "original q0");
  compare(q1.data + 184156160, q1_page, "original q1");
  compare(scale.data + 23019520, scale_page, "original scales");
  compare(aux.data, std::vector<uint8_t>(aux_page.begin(), aux_page.begin() + kPage),
          "original AUX header page");
  compare(aux.data + 1667072,
          std::vector<uint8_t>(aux_page.begin() + kPage, aux_page.begin() + 2 * kPage),
          "original AUX bias first page");
  constexpr size_t kAuxFinalPrefix = 704;
  compare(aux.data + 1671168,
          std::vector<uint8_t>(aux_page.begin() + 2 * kPage,
                               aux_page.begin() + 2 * kPage + kAuxFinalPrefix),
          "original AUX bias second page prefix");
  for (size_t i = 2 * kPage + kAuxFinalPrefix; i < aux_page.size(); ++i)
    need(aux_page[i] == 0xa5, "AUX forbidden suffix sentinel");
}

std::vector<uint32_t> descriptor(const std::string& fixture,
                                 const std::string& name, uint32_t command,
                                 uint32_t task, uint32_t quant, bool trace) {
  const auto page = read_file(fixture + "/commands/" + name +
                              "/descriptor_page.bin", kPage);
  for (size_t i = 512; i < kPage; ++i)
    need(page[i] == 0xa5, "descriptor page sentinel " + name);
  std::vector<uint32_t> d(kDescriptorWords);
  for (unsigned i = 0; i < kDescriptorWords; ++i)
    d[i] = le32(page.data() + i * 4);
  need(d[D_MAGIC] == kDescriptorMagic && d[D_VERSION] == 1 &&
       d[D_COMMAND] == command && d[D_TASK_ID] == task &&
       d[D_QUANT_TASK_ID] == quant && d[D_FLAGS] == unsigned(trace) &&
       d[D_STAGE] == 5 && d[D_LAYER] == 255 && d[D_B] == 2 &&
       d[D_S] == 128 && d[D_K] == 1024 && d[D_N] == 1024 &&
       d[D_WEIGHT_FAMILY] == 9 && d[D_WEIGHT_LAYER] == 255 &&
       d[D_ROWS] == (command == LOAD_W ? 1u : kRows) &&
       d[D_OBSERVED_WORDS] == kObservedWords,
       "full scorer descriptor " + name);
  if (command == RUN_TILE)
    need(d[D_BATCH] == 1 && d[D_ROW0] == 13 &&
         d[D_TRACE_ROW_LOCAL] == (trace ? 2u : 0u) &&
         d[D_TRACE_COLUMN] == (trace ? 8u : 0u) &&
         d[D_SRC_ID] == 10 && d[D_SRC_REGION] == 0 &&
         d[D_DST_ID] == 10 && d[D_DST_REGION] == 0 &&
         join_u64(d[D_ACT_SPAN_LO], d[D_ACT_SPAN_HI]) == kRows * kPage &&
         join_u64(d[D_OUT0_SPAN_LO], d[D_OUT0_SPAN_HI]) == kRows * kPage,
         "full scorer RUN shape " + name);
  return d;
}

std::vector<ap_uint<512>> activation(const std::string& fixture) {
  const auto page = read_file(fixture + "/pages/activation.bin", 16 * kPage);
  const auto gold = read_file(fixture + "/gold/input_rows3_12288.bin",
                              kRows * kPage);
  compare(page.data(), gold, "full scorer input rows3");
  for (size_t i = kRows * kPage; i < page.size(); ++i)
    need(page[i] == 0xa5, "activation neighbor sentinel");
  std::vector<ap_uint<512>> words(kRows * 64);
  for (size_t beat = 0; beat < words.size(); ++beat) {
    words[beat] = 0;
    for (unsigned lane = 0; lane < 16; ++lane)
      words[beat].range(lane * 32 + 31, lane * 32) =
          le32(page.data() + beat * 64 + lane * 4);
  }
  return words;
}

void run_case(const std::string& fixture, const std::string& name,
              const std::vector<uint32_t>& d, const MappedBo& q0,
              const MappedBo& q1, const MappedBo& scale,
              const MappedBo& aux, const std::vector<ap_uint<512>>& act,
              uint32_t command, uint32_t task, uint32_t quant, bool trace,
              uint32_t reuse) {
  std::vector<uint32_t> out0(16 * 1024, kSentinel);
  std::vector<uint32_t> out1(1024, kSentinel);
  std::vector<uint32_t> observed(kObservedWords, kSentinel);
  static_assert(sizeof(ap_uint<512>) == 64, "host packed beat size");
  q8_joint_tm4tn8(d.data(),
      reinterpret_cast<const ap_uint<512>*>(q0.data),
      reinterpret_cast<const ap_uint<512>*>(q1.data),
      reinterpret_cast<const ap_uint<512>*>(scale.data),
      reinterpret_cast<const uint32_t*>(aux.data), act.data(),
      out0.data(), out1.data(), observed.data());
  need(observed[O_COMMAND] == command && observed[O_STATUS] == 0 &&
       observed[O_LAST_TASK] == task && observed[O_DONE_TASK] == task &&
       observed[O_W_LOADS] == 1 && observed[O_W_REUSES] == reuse,
       "status/task/reuse " + name);
  need(observed[O_PORT_BYTES_BEGIN] == 512 &&
       observed[port_useful_lo(P_OBSERVED)] ==
           (command == LOAD_W ? 1024u : trace ? 5312u : 1024u),
       "descriptor/observed bytes " + name);
  if (command == RUN_TILE)
    need(observed[O_QUANT_DONE_TASK] == quant &&
         observed[O_QUANT_GROUPS] == 96 &&
         observed[O_QUANT_INPUTS] == 3072 &&
         observed[O_ACCEPTED_ISSUES] == 4096 &&
         observed[O_RETIRED_GROUPS] == 4096 &&
         observed[O_COMMITTED_WRITES] == 3072 &&
         observed[O_DOT_MACS_LO] == 3145728 &&
         observed[O_TRACE_GROUP_COUNT] == (trace ? 32u : 0u),
         "full dimension work " + name);
  compare(reinterpret_cast<const uint8_t*>(out0.data()),
          read_file(fixture + "/commands/" + name +
                    "/expected_out0_65536.bin", 16 * kPage), "out0 " + name);
  compare(reinterpret_cast<const uint8_t*>(out1.data()),
          read_file(fixture + "/commands/" + name +
                    "/expected_out1_4096.bin", kPage), "out1 " + name);
  compare(reinterpret_cast<const uint8_t*>(observed.data()),
          read_file(fixture + "/commands/" + name +
                    "/expected_observed_131072.bin", kObservedWords * 4),
          "observed " + name);
  if (command == RUN_TILE)
    compare(reinterpret_cast<const uint8_t*>(out0.data()),
            read_file(fixture + "/gold/scorer_rows3_12288.bin", kRows * kPage),
            "frozen full scorer rows3 " + name);
}
}  // namespace

int main(int argc, char** argv) {
  try {
    need(argc == 3, "usage: test_q8_scorer_rows3 MODEL_BUILD_DIR FIXTURE_DIR");
    const std::string model = argv[1], fixture = argv[2];
    const uint32_t byte_probe = 0x01020304u;
    need(*reinterpret_cast<const uint8_t*>(&byte_probe) == 4,
         "little-endian host required");
    MappedBo q0(model + "/w_q0.bin"), q1(model + "/w_q1.bin");
    MappedBo scale(model + "/w_scale.bin"), aux(model + "/aux.bin");
    original_pages(model, fixture, q0, q1, scale, aux);
    const auto act = activation(fixture);
    struct CaseSpec {
      const char* name;
      unsigned command, task, quant;
      bool trace;
      unsigned reuse;
    };
    for (const CaseSpec& c : {CaseSpec{"load_w", 0, 1, 0, false, 0},
                              CaseSpec{"run_trace_on", 1, 3, 2, true, 0},
                              CaseSpec{"run_trace_off", 1, 5, 4, false, 1}}) {
      const std::string name = c.name;
      const auto d = descriptor(fixture, name, c.command, c.task,
                                c.quant, c.trace);
      run_case(fixture, name, d, q0, q1, scale, aux, act,
               c.command, c.task, c.quant, c.trace, c.reuse);
      std::cout << "Q8_SCORER_CPU_COMMAND_PASS name=" << name << '\n';
    }
    std::cout << "Q8_SCORER_ROWS3_CPU_PASS commands=3 rows=3 K=1024 N=1024\n";
    return 0;
  } catch (const std::exception& e) {
    std::cerr << "Q8_SCORER_ROWS3_CPU_FAIL " << e.what() << '\n';
    return 1;
  }
}
