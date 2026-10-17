#include "laya_full_runtime.h"

#include <array>
#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>
#include <set>
#include <string>
#include <vector>

using namespace laya;
namespace fs = std::filesystem;

namespace {
void fail(const std::string& message) {
  std::cerr << "FULL_FORWARD_DUT_RUNNER_FAIL " << message << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& message) {
  if (!condition) fail(message);
}
std::vector<uint8_t> read_file(const fs::path& path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "open " + path.string());
  return {std::istreambuf_iterator<char>(input),
          std::istreambuf_iterator<char>()};
}
void write_file(const fs::path& path, const uint8_t* data, size_t bytes) {
  std::ofstream output(path, std::ios::binary | std::ios::trunc);
  require(bool(output), "write " + path.string());
  output.write(reinterpret_cast<const char*>(data),
               std::streamsize(bytes));
  require(bool(output), "complete " + path.string());
}
uint16_t le16(const uint8_t* data) {
  return uint16_t(data[0]) | uint16_t(data[1]) << 8;
}
uint32_t le32(const uint8_t* data) {
  return uint32_t(data[0]) | uint32_t(data[1]) << 8 |
         uint32_t(data[2]) << 16 | uint32_t(data[3]) << 24;
}
uint64_t le64(const uint8_t* data) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i) value |= uint64_t(data[i]) << (8 * i);
  return value;
}
struct Capture {
  fs::path directory;
  std::set<std::string> names;
  std::ofstream records;
};
void checkpoint(const char* name, const full::FullRuntime& rt,
                BufferRef ref, uint8_t region, RowSpace space,
                uint16_t width, void* user) {
  auto& capture = *static_cast<Capture*>(user);
  require(name && *name, "nonempty production checkpoint name");
  const std::string label(name);
  require(label != "final18" && capture.names.insert(label).second,
          "unique physical checkpoint " + label);
  const unsigned rows = space == RowSpace::TOKEN ? rt.inputs.identity.S :
                        space == RowSpace::MARKER ? 16 : 1;
  const unsigned B = rt.inputs.identity.B;
  require(B >= 1 && B <= 2 && width >= 1 && width <= 5248 &&
          rows >= 1 && rows <= 1024,
          "checkpoint scope " + label);
  std::vector<uint8_t> bytes(size_t(B) * rows * width * 4);
  for (unsigned batch = 0; batch < B; ++batch)
    for (unsigned row = 0; row < rows; ++row) {
      Address address;
      Check c = full::full_f32_address(rt, ref, region, uint8_t(batch),
                                       uint16_t(row), 0, address);
      require(bool(c), "physical checkpoint address " + label);
      c = full::full_read(rt.memory, address.bo, address.offset,
                          bytes.data() + (size_t(batch) * rows + row) *
                                             width * 4,
                          uint32_t(width * 4));
      require(bool(c), "physical checkpoint read " + label);
    }
  write_file(capture.directory / (label + ".f32.bin"),
             bytes.data(), bytes.size());
  capture.records << label << '\t' << B << '\t' << rows << '\t'
                  << width << '\t' << unsigned(space) << '\t'
                  << unsigned(ref.id) << '\t' << unsigned(ref.bank) << '\t'
                  << ref.epoch << '\t' << unsigned(region) << '\t'
                  << bytes.size() << '\n';
  require(bool(capture.records), "checkpoint record " + label);
  std::cout << "FULL_FORWARD_DUT_CHECKPOINT "
            << capture.directory.filename().string() << ' ' << label
            << " bytes=" << bytes.size() << '\n' << std::flush;
}
void capture_result(const full::FullRuntime& rt, Capture& capture) {
  std::array<uint8_t, kResultBytes> result{};
  Check c = full::full_read(rt.memory, Bo::IO, kResultOffset,
                            result.data(), result.size());
  require(bool(c), "read actual ABI result frame");
  write_file(capture.directory / "result.bin", result.data(), result.size());
  require(std::memcmp(result.data(), "LYRS", 4) == 0 &&
          le16(result.data() + 10) == 0 &&
          (result[112] & 11) == 11 &&
          le16(result.data() + 96) == rt.inputs.identity.B &&
          le16(result.data() + 98) == rt.inputs.identity.S &&
          le16(result.data() + 100) == 16 * rt.inputs.identity.B &&
          le16(result.data() + 102) == 2 * rt.inputs.identity.B &&
          le64(result.data() + 16) == rt.inputs.identity.request_id &&
          le64(result.data() + 24) == rt.inputs.identity.generation,
          "successful real ABI result identity and lengths");
  const unsigned B = rt.inputs.identity.B;
  std::vector<uint8_t> final(size_t(B) * 18 * 4);
  for (unsigned batch = 0; batch < B; ++batch) {
    std::memcpy(final.data() + size_t(batch) * 18 * 4,
                result.data() + 128 + size_t(batch) * 16 * 4, 16 * 4);
    std::memcpy(final.data() + (size_t(batch) * 18 + 16) * 4,
                result.data() + 256 + size_t(batch) * 2 * 4, 2 * 4);
  }
  require(capture.names.insert("final18").second,
          "final18 recorded exactly once from ABI result");
  write_file(capture.directory / "final18.f32.bin",
             final.data(), final.size());
  capture.records << "final18\t" << B << "\t1\t18\t"
                  << unsigned(RowSpace::BATCH)
                  << "\t0\t0\t0\t0\t" << final.size() << '\n';
  require(bool(capture.records), "final18 checkpoint record");
}
void runtime_state(std::ofstream& output, const char* phase,
                   const full::FullRuntime& rt) {
  unsigned valid_owners = 0, nonfree_owners = 0;
  uint32_t a8_max_epoch = 0, gamma_max_epoch = 0;
  for (const full::FullOwnerRecord& owner : rt.owners.record) {
    valid_owners += owner.valid;
    nonfree_owners += owner.ref.id != Buffer::NONE &&
                      owner.state != CacheState::FREE &&
                      owner.state != CacheState::INVALID;
    if (owner.ref.id == Buffer::A8 && owner.max_claimed_epoch > a8_max_epoch)
      a8_max_epoch = owner.max_claimed_epoch;
    if (owner.ref.id == Buffer::LN_GAMMA &&
        owner.max_claimed_epoch > gamma_max_epoch)
      gamma_max_epoch = owner.max_claimed_epoch;
  }
  output << phase << '\t' << rt.session_generation << '\t'
         << rt.last_accepted_request_id << '\t' << rt.last_task_id << '\t'
         << rt.tasks_retired << '\t' << unsigned(rt.request_valid) << '\t'
         << unsigned(rt.model_header_valid) << '\t' << valid_owners << '\t'
         << nonfree_owners << '\t' << a8_max_epoch << '\t'
         << gamma_max_epoch << '\t'
         << rt.cache.activation_meta.ref.epoch << '\t'
         << rt.owner_claims << '\t' << rt.owner_leases << '\t'
         << unsigned(rt.encoder_layers_completed) << '\t'
         << unsigned(rt.decision_layers_completed);
  for (const uint32_t calls : rt.op_calls) output << '\t' << calls;
  output << '\n';
  require(bool(output), "runtime state record");
}
void run_accepted_failure(full::FullRuntime& rt, std::vector<uint8_t>& aux,
                          const fs::path& request_path,
                          const fs::path& output_root,
                          const std::string& session) {
  const fs::path directory = output_root / "accepted_gamma_failure";
  fs::create_directories(directory);
  full::FullTensorDescriptor gamma;
  Check c = full::full_lookup_tensor("emb_norm_w", gamma);
  require(bool(c) && gamma.bo == uint8_t(Bo::AUX) &&
          gamma.span == 4096 && uint64_t(gamma.base) + 4 <= aux.size(),
          "compiled embedding gamma descriptor for fault mutation");
  const uint32_t original = le32(aux.data() + gamma.base);
  const std::vector<uint8_t> original_aux = aux;
  require((original & 0x7f800000u) != 0x7f800000u,
          "original gamma is finite");
  const auto request = read_file(request_path);
  require(request.size() == 1856, "real accepted B2 fault request frame");
  auto* io = rt.memory.io;
  require(io && rt.memory.io_bytes >= 32768, "fault IO capacity");
  std::memset(io, 0, size_t(rt.memory.io_bytes));
  std::memcpy(io, request.data(), request.size());
  std::ofstream state(directory / "runtime.tsv");
  require(bool(state), "open fault runtime snapshots");
  runtime_state(state, "pre", rt);
  constexpr uint32_t injected = 0x7f800000u;
  for (unsigned i = 0; i < 4; ++i)
    aux[gamma.base + i] = uint8_t(injected >> (8 * i));
  const Check failed = full::full_execute_request(rt);
  for (unsigned i = 0; i < 4; ++i)
    aux[gamma.base + i] = uint8_t(original >> (8 * i));
  require(aux == original_aux,
          "entire in-memory model AUX bit-identical after fault restoration");
  runtime_state(state, "post", rt);
  state.close();
  require(failed.code == Status::E_NUMERICAL &&
          failed.detail == detail(7, uint8_t(Op::LOAD_LN_PARAMS), 15) &&
          rt.last_execution_error.code == failed.code &&
          rt.last_execution_error.detail == failed.detail &&
          bool(rt.last_cleanup_error) &&
          rt.last_accepted_request_id == 2 &&
          rt.inputs.identity.request_id == 2 &&
          rt.tasks_retired > 0 && rt.last_task_id == rt.tasks_retired,
          "accepted in-graph numerical failure and first cause");
  std::array<uint8_t, kResultBytes> frame{};
  c = full::full_read(rt.memory, Bo::IO, kResultOffset,
                      frame.data(), frame.size());
  require(bool(c), "actual error ABI result frame read");
  write_file(directory / "result.bin", frame.data(), frame.size());
  require(std::memcmp(frame.data(), "LYRS", 4) == 0 &&
          le16(frame.data() + 10) == uint16_t(Status::E_NUMERICAL) &&
          le64(frame.data() + 16) == 2 &&
          le64(frame.data() + 24) == rt.inputs.identity.generation &&
          le16(frame.data() + 96) == 2 && le16(frame.data() + 98) == 128 &&
          le16(frame.data() + 100) == 0 && le16(frame.data() + 102) == 0 &&
          le32(frame.data() + 112) == 9 &&
          std::memcmp(frame.data() + 32, aux.data() + 32, 64) == 0 &&
          le16(frame.data() + 116) == 1 &&
          le16(frame.data() + 118) == uint16_t(Op::LOAD_LN_PARAMS) &&
          le32(frame.data() + 120) == failed.detail &&
          le64(frame.data() + 328) == rt.tasks_retired &&
          le64(frame.data() + 336) == 578 &&
          le64(frame.data() + 344) == 0 &&
          le64(frame.data() + 352) == UINT64_MAX &&
          le32(frame.data() + 360) == rt.last_task_id &&
          le32(frame.data() + 320) == 0 &&
          le32(frame.data() + 324) == 0 &&
          le32(frame.data() + 364) == 0 &&
          std::all_of(frame.begin() + 128, frame.begin() + 320,
                      [](uint8_t byte) { return byte == 0; }),
          "accepted failure ABI identity, first cause and zeroed logits");
  std::ofstream mutation(directory / "mutation.tsv");
  require(bool(mutation), "fault mutation record");
  mutation << gamma.base << '\t' << original << '\t' << injected << '\t'
           << unsigned(failed.code) << '\t' << failed.detail << '\t'
           << rt.tasks_retired << '\t' << session << '\n';
  require(bool(mutation), "complete fault mutation record");
  std::cout << "FULL_FORWARD_ACCEPTED_FAILURE_PASS request_id=2"
            << " status=" << unsigned(failed.code)
            << " task=" << rt.last_task_id
            << " restored_gamma=1 run_session_id=" << session << '\n'
            << std::flush;
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 8,
          "usage: full_forward_dut_runner PACKAGE B2_REQUEST FAULT_REQUEST "
          "B1_B0_REQUEST B1_B1_REQUEST OUTPUT_ROOT RUN_SESSION_ID");
  const fs::path package(argv[1]), output_root(argv[6]);
  const std::array<const char*, 3> scenarios = {
      "B2_S128", "B1_from_b0_S128", "B1_from_b1_S128"};
  const std::array<fs::path, 3> request_paths = {
      fs::path(argv[2]), fs::path(argv[4]), fs::path(argv[5])};
  const std::string session(argv[7]);
  require(!session.empty(), "nonempty run session identifier");
  fs::create_directories(output_root);
  const auto embedding = read_file(package / "embedding.bin");
  const auto w_q0 = read_file(package / "w_q0.bin");
  const auto w_q1 = read_file(package / "w_q1.bin");
  const auto w_scale = read_file(package / "w_scale.bin");
  auto aux = read_file(package / "aux.bin");
  require(embedding.size() == 54803648 &&
          w_q0.size() == 184682496 && w_q1.size() == 184680448 &&
          w_scale.size() == 23085184 && aux.size() == 1671872,
          "complete fixed P2 package byte spans");
  std::vector<uint8_t> io(32768), state0(17u << 20), state1(17u << 20),
      qkv0(12u << 20), qkv1(12u << 20), ff0(42u << 20),
      ff1(21u << 20), att(8u << 20);
  static full::FullRuntime rt;
  rt.memory.embedding = embedding.data();
  rt.memory.embedding_bytes = embedding.size();
  rt.memory.io = io.data(); rt.memory.io_bytes = io.size();
  rt.memory.w_q0 = w_q0.data(); rt.memory.w_q0_bytes = w_q0.size();
  rt.memory.w_q1 = w_q1.data(); rt.memory.w_q1_bytes = w_q1.size();
  rt.memory.w_scale = w_scale.data();
  rt.memory.w_scale_bytes = w_scale.size();
  rt.memory.aux = aux.data(); rt.memory.aux_bytes = aux.size();
  rt.memory.state0 = state0.data(); rt.memory.state0_bytes = state0.size();
  rt.memory.state1 = state1.data(); rt.memory.state1_bytes = state1.size();
  rt.memory.qkv0 = qkv0.data(); rt.memory.qkv0_bytes = qkv0.size();
  rt.memory.qkv1 = qkv1.data(); rt.memory.qkv1_bytes = qkv1.size();
  rt.memory.ff0 = ff0.data(); rt.memory.ff0_bytes = ff0.size();
  rt.memory.ff1 = ff1.data(); rt.memory.ff1_bytes = ff1.size();
  rt.memory.att_out = att.data(); rt.memory.att_out_bytes = att.size();

  for (unsigned run = 0; run < scenarios.size(); ++run) {
    const auto request = read_file(request_paths[run]);
    require(request.size() <= kRequestLimit && request.size() >= 320,
            "bounded request frame " + std::string(scenarios[run]));
    std::fill(io.begin(), io.end(), 0);
    std::memcpy(io.data(), request.data(), request.size());
    const fs::path directory = output_root / scenarios[run];
    fs::create_directories(directory);
    Capture capture{directory, {},
                    std::ofstream(directory / "checkpoints.tsv")};
    require(bool(capture.records), "open checkpoint manifest");
    std::ofstream state(directory / "runtime.tsv");
    require(bool(state), "open runtime state record");
    runtime_state(state, "pre", rt);
    rt.checkpoint = checkpoint;
    rt.checkpoint_user = &capture;
    const Check result = full::full_execute_request(rt);
    rt.checkpoint = nullptr;
    rt.checkpoint_user = nullptr;
    runtime_state(state, "post", rt);
    state.close();
    capture.records.flush();
    require(bool(result), std::string("production controller status ") +
                           scenarios[run] + "=" +
                           std::to_string(unsigned(result.code)) +
                           " detail=" + std::to_string(result.detail) +
                           " task=" + std::to_string(rt.last_task_id));
    capture_result(rt, capture);
    capture.records.close();
    require(capture.names.size() == 47,
            std::string(scenarios[run]) + " exact 47 checkpoints");
    std::cout << "FULL_FORWARD_DUT_RUN " << scenarios[run]
              << " checkpoints=" << capture.names.size()
              << " request_id=" << rt.inputs.identity.request_id
              << " generation=" << rt.inputs.identity.generation
              << " tasks=" << rt.tasks_retired
              << " run_session_id=" << session << '\n' << std::flush;
    if (run == 0)
      run_accepted_failure(rt, aux, fs::path(argv[3]), output_root,
                           session);
  }
  std::cout << "FULL_FORWARD_DUT_RUNNER_PASS persistent_requests=4 "
               "successful_requests=3 checkpoints=141"
               " accepted_failure_recovered=1 run_session_id="
            << session << '\n';
  return 0;
}
