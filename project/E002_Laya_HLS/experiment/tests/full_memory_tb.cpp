#include "laya_full_runtime.h"

#include <cerrno>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

using namespace laya;

namespace {
void require(bool condition, const char* message) {
  if (!condition) {
    std::cerr << "FULL_MEMORY_FAIL " << message << '\n';
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "open input file");
  return {std::istreambuf_iterator<char>(stream),
          std::istreambuf_iterator<char>()};
}

struct MappedFile {
  int descriptor = -1;
  const uint8_t* data = nullptr;
  size_t size = 0;
  explicit MappedFile(const std::string& path) {
    descriptor = open(path.c_str(), O_RDONLY);
    require(descriptor >= 0, "open BO");
    struct stat metadata {};
    require(fstat(descriptor, &metadata) == 0 && metadata.st_size > 0,
            "BO metadata");
    size = size_t(metadata.st_size);
    void* view = mmap(nullptr, size, PROT_READ, MAP_PRIVATE, descriptor, 0);
    require(view != MAP_FAILED, "map BO");
    data = static_cast<const uint8_t*>(view);
  }
  MappedFile(const MappedFile&) = delete;
  MappedFile& operator=(const MappedFile&) = delete;
  ~MappedFile() {
    if (data) munmap(const_cast<uint8_t*>(data), size);
    if (descriptor >= 0) close(descriptor);
  }
};

uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
void store32(uint8_t* p, uint32_t value) {
  for (unsigned i = 0; i < 4; ++i) p[i] = uint8_t(value >> (8 * i));
}
void store64(uint8_t* p, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) p[i] = uint8_t(value >> (8 * i));
}
void expect_status(Check check, Status expected, const char* message) {
  require(check.code == expected, message);
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 3, "usage: full_memory_tb PACKAGE_DIR REQUEST_V1_BIN");
  const std::string package = argv[1];
  MappedFile embedding(package + "/embedding.bin");
  MappedFile q0(package + "/w_q0.bin");
  MappedFile q1(package + "/w_q1.bin");
  MappedFile scale(package + "/w_scale.bin");
  MappedFile aux(package + "/aux.bin");
  std::vector<uint8_t> request = read_file(argv[2]);
  require(request.size() == 1856 && aux.size >= 128,
          "frozen B2/S128 request/model header sizes");
  for (unsigned i = 0; i < 64; ++i) request[40 + i] = aux.data[32 + i];
  std::vector<uint8_t> io(32768, 0);
  std::memcpy(io.data(), request.data(), request.size());
  std::vector<uint8_t> state0(17 * 1024 * 1024, 0xA5);
  std::vector<uint8_t> state1(17 * 1024 * 1024, 0xA5);
  static full::FullRuntime runtime;
  auto& memory = runtime.memory;
  memory.embedding = embedding.data; memory.embedding_bytes = embedding.size;
  memory.io = io.data(); memory.io_bytes = io.size();
  memory.w_q0 = q0.data; memory.w_q0_bytes = q0.size;
  memory.w_q1 = q1.data; memory.w_q1_bytes = q1.size;
  memory.w_scale = scale.data; memory.w_scale_bytes = scale.size;
  memory.aux = aux.data; memory.aux_bytes = aux.size;
  memory.state0 = state0.data(); memory.state0_bytes = state0.size();
  memory.state1 = state1.data(); memory.state1_bytes = state1.size();

  expect_status(full::full_parse_request(runtime), Status::OK,
                "real B2 request with package tags");
  require(runtime.request_valid && runtime.model_header_valid &&
          runtime.inputs.identity.B == 2 && runtime.inputs.identity.S == 128 &&
          runtime.inputs.token_ids[0][0] == 50281 &&
          runtime.inputs.token_ids[1][0] == 50281 &&
          runtime.inputs.marker_positions[0][0] == 23 &&
          runtime.inputs.marker_positions[1][0] == 147 &&
          runtime.inputs.marker_positions[1][15] == 128 &&
          runtime.inputs.qtype[0] == 2 && runtime.inputs.qtype[1] == 0,
          "real B2 parsed payload");
  const full::FullInputs accepted = runtime.inputs;

  expect_status(full::full_parse_request(runtime), Status::E_PROTOCOL,
                "accepted request ID cannot be replayed before any task");
  require(!runtime.request_valid && runtime.tasks_retired == 0,
          "duplicate ID closes gate without retiring task");

  io[40] ^= 1;
  expect_status(full::full_parse_request(runtime), Status::E_MODEL,
                "wrong model tag");
  require(!runtime.request_valid && !runtime.model_header_valid,
          "wrong tag closes task entry");
  io[40] ^= 1;
  // Final active token, invalid marker and final qtype are all rejected
  // before any of the previously accepted input arrays are replaced.
  const uint32_t token_offset = le32(io.data() + 128 + 4);
  const uint32_t marker_offset = le32(io.data() + 128 + 2 * 32 + 4);
  const uint32_t qtype_offset = le32(io.data() + 128 + 4 * 32 + 4);
  const uint32_t last_token = token_offset + 4 * 255;
  const uint32_t last_marker = marker_offset + 4 * 31;
  const uint32_t last_qtype = qtype_offset + 4;
  const uint32_t old_token = le32(io.data() + last_token);
  const uint32_t old_marker = le32(io.data() + last_marker);
  const uint32_t old_qtype = le32(io.data() + last_qtype);
  store32(io.data() + last_token, UINT32_MAX);
  expect_status(full::full_parse_request(runtime), Status::E_INDEX,
                "negative final token");
  require(!runtime.request_valid && !runtime.model_header_valid,
          "invalid token closes task entry");
  store32(io.data() + last_token, old_token);
  store32(io.data() + last_marker, UINT32_MAX);
  expect_status(full::full_parse_request(runtime), Status::E_INDEX,
                "negative final invalid marker");
  require(!runtime.request_valid && !runtime.model_header_valid,
          "invalid marker closes task entry");
  store32(io.data() + last_marker, old_marker);
  store32(io.data() + last_qtype, UINT32_MAX);
  expect_status(full::full_parse_request(runtime), Status::E_INDEX,
                "negative final qtype");
  require(!runtime.request_valid && !runtime.model_header_valid,
          "invalid qtype closes task entry");
  store32(io.data() + last_qtype, old_qtype);
  require(runtime.inputs.token_ids[1][127] == accepted.token_ids[1][127] &&
          runtime.inputs.marker_positions[1][15] ==
              accepted.marker_positions[1][15] &&
          runtime.inputs.qtype[1] == accepted.qtype[1],
          "failed parse preserves accepted inputs");
  store64(io.data() + 24, accepted.identity.request_id + 1);
  expect_status(full::full_parse_request(runtime), Status::OK,
                "new request ID reopens task entry");

  expect_status(full::full_span(memory, Bo::W_Q0, q0.size - 1, 1),
                Status::OK, "last model byte");
  expect_status(full::full_span(memory, Bo::W_Q0, q0.size, 1),
                Status::E_BUFFER, "past model BO");
  expect_status(full::full_span(memory, Bo::W_Q0, UINT64_MAX, 1),
                Status::E_BUFFER, "u64 overflow offset");
  uint8_t last_model_byte = 0;
  expect_status(full::full_read(memory, Bo::W_Q0, q0.size - 1,
                                &last_model_byte, 1), Status::OK,
                "read last Q0 byte");
  require(last_model_byte == q0.data[q0.size - 1], "actual Q0 byte read");
  expect_status(full::full_write(memory, Bo::W_Q0, 0,
                                 &last_model_byte, 1), Status::E_BUFFER,
                "model BO read only");

  for (unsigned i = 0; i < 20; ++i) io[4090 + i] = uint8_t(0x30 + i);
  full::FullSegment segment;
  expect_status(full::full_next_segment(Bo::IO, 4090, Bo::STATE0, 4093,
                                        20, segment), Status::OK,
                "first page split");
  require(segment.bytes == 3 && segment.src_offset == 4090 &&
          segment.dst_offset == 4093, "first segment exact");
  expect_status(full::full_next_segment(Bo::IO, 4093, Bo::STATE0, 4096,
                                        17, segment), Status::OK,
                "second page split");
  require(segment.bytes == 3, "second segment exact");
  uint32_t count = 0;
  expect_status(full::full_copy(memory, Bo::IO, 4090, Bo::STATE0,
                                4093, 20, count), Status::OK,
                "cross-page actual copy");
  require(count == 3 && state0[4092] == 0xA5 && state0[4113] == 0xA5,
          "copy segment count/neighbors");
  for (unsigned i = 0; i < 20; ++i)
    require(state0[4093 + i] == uint8_t(0x30 + i), "copy byte identity");
  count = 99;
  expect_status(full::full_copy(memory, Bo::STATE0, 4093, Bo::STATE0,
                                4094, 20, count), Status::E_BUFFER,
                "overlap rejected");
  require(count == 0, "rejected copy has no segments");

  unsigned legal_weights = 0;
  for (unsigned family = 1; family <= 12; ++family) {
    const unsigned layers = family <= 4 ? 28 : family <= 8 ? 2 : 1;
    for (unsigned layer = 0; layer < layers; ++layer) {
      full::FullWeightDescriptor descriptor;
      const uint8_t key_layer = family <= 8 ? uint8_t(layer) : 255;
      expect_status(full::full_lookup_weight({uint8_t(family), key_layer},
                                             descriptor), Status::OK,
                    "all 124 legal WeightKeys");
      require(descriptor.key.family == family &&
              descriptor.key.layer == key_layer && descriptor.K > 0 &&
              descriptor.N > 0, "WeightKey descriptor identity");
      ++legal_weights;
    }
  }
  require(legal_weights == 124, "WeightKey count");
  full::FullWeightDescriptor descriptor;
  expect_status(full::full_lookup_weight({1, 0}, descriptor), Status::OK,
                "Encoder QKV descriptor");
  require(descriptor.K == 1024 && descriptor.N == 3072 &&
          descriptor.dtype == 8, "Encoder QKV full dimensions");
  Address q, s;
  const uint16_t n = 3071, k = 1023;
  expect_status(full::full_q8_address(runtime, descriptor, n, k, q, s),
                Status::OK, "last QKV q/scale address");
  const uint32_t groups = descriptor.K / 32, tile = n / 8;
  const uint32_t expected_q = descriptor.q_base[tile % 2] +
      ((((tile / 2) * groups + k / 32) * 8 + n % 8) * 32 + k % 32);
  const uint32_t expected_s = descriptor.scale_base +
      (((tile * groups + k / 32) * 8 + n % 8) * 2);
  require(q.bo == Bo::W_Q1 && q.offset == expected_q &&
          s.bo == Bo::W_SCALE && s.offset == expected_s,
          "independent Q8 physical formula");
  expect_status(full::full_q8_address(runtime, descriptor, 3072, 0, q, s),
                Status::E_BUFFER, "Q8 output column bound");
  auto tampered = descriptor;
  tampered.q_base[0] += 64;
  expect_status(full::full_q8_address(runtime, tampered, 0, 0, q, s),
                Status::E_MODEL, "host descriptor override rejected");

  Address hidden_address;
  expect_status(full::full_f32_address(runtime, {Buffer::HIDDEN, 0, 1},
                                       0, 1, 127, 1023, hidden_address),
                Status::OK, "last active B2 hidden feature address");
  require(hidden_address.bo == Bo::STATE0 &&
          hidden_address.offset == ((1024u + 127u) * 1024u + 1023u) * 4u,
          "hidden physical 1024 stride");
  expect_status(full::full_f32_address(runtime, {Buffer::HIDDEN, 0, 1},
                                       0, 1, 128, 0, hidden_address),
                Status::E_BUFFER, "inactive S tail rejected");

  Address address;
  const uint32_t state0_marker_base = 16u * 1024u * 1024u;
  const uint32_t state0_type_base = 16908288u;
  const uint32_t state1_head_base = 16777216u;
  expect_status(full::full_f32_address(runtime, {Buffer::MARKER, 0, 1},
                                       0, 1, 15, 1023, address),
                Status::OK, "last B2 marker feature");
  require(address.bo == Bo::STATE0 &&
          address.offset == state0_marker_base + 131068u,
          "MARKER physical row mapping");
  expect_status(full::full_f32_address(runtime, {Buffer::TYPE_ROWS, 0, 1},
                                       0, 0, 2, 1023, address),
                Status::OK, "last type feature");
  require(address.bo == Bo::STATE0 &&
          address.offset == state0_type_base + 12284u,
          "TYPE_ROWS keyed by type not batch");
  const BufferRef head{Buffer::HEAD_WORK, 0, 1};
  struct HeadCase { Region region; uint16_t row, col; uint32_t relative; };
  const HeadCase head_cases[] = {
      {Region::SCORER_ACT, 15, 1023, 131068u},
      {Region::ACT_INPUT, 0, 1027, 131072u + 8220u},
      {Region::ACT_HIDDEN, 0, 255, 139328u + 2044u},
      {Region::CAND_MASKED, 0, 15, 141376u + 124u},
      {Region::ACT_LOGITS, 0, 1, 141504u + 12u},
      {Region::STATS, 0, 3, 141568u + 28u},
      {Region::CAND_PROB, 0, 15, 141632u + 124u},
      {Region::CAND_RAW, 15, 0, 141760u + 124u},
  };
  for (const auto& item : head_cases) {
    expect_status(full::full_f32_address(runtime, head,
                                         uint8_t(item.region), 1,
                                         item.row, item.col, address),
                  Status::OK, "HEAD_WORK region address");
    require(address.bo == Bo::STATE1 &&
            address.offset == state1_head_base + item.relative,
            "HEAD_WORK canonical physical formula");
  }
  Address raw_vector;
  expect_status(full::full_f32_address(runtime, head,
                                       uint8_t(Region::CAND_RAW), 1,
                                       0, 15, raw_vector),
                Status::OK, "CAND_RAW batch-vector view");
  require(raw_vector.offset == address.offset,
          "CAND_RAW marker-row and batch-vector coincide");
  expect_status(full::full_f32_address(runtime, head,
                                       uint8_t(Region::ACT_INPUT), 1,
                                       1, 0, address),
                Status::E_BUFFER, "ACT_INPUT has only BATCH row0");

  // Supply finite, covered result owners so the success path reaches the
  // same physical IO write rather than failing at result validation.
  const full::FullOwnerSpec candidate{
      head, uint8_t(Region::CAND_MASKED), 5, 255, 255,
      RowSpace::BATCH, 0, 1, 16, Content::F32};
  const full::FullOwnerSpec act{
      head, uint8_t(Region::ACT_LOGITS), 6, 255, 255,
      RowSpace::BATCH, 0, 1, 2, Content::F32};
  memory.io_bytes = io.size();
  for (const auto& owner : {candidate, act}) {
    expect_status(full::full_claim_owner(runtime, owner), Status::OK,
                  "claim result owner");
    for (uint8_t batch = 0; batch < runtime.inputs.identity.B; ++batch) {
      Address output;
      expect_status(full::full_f32_address(runtime, owner.ref, owner.region,
                                           batch, 0, 0, output), Status::OK,
                    "result owner physical address");
      std::vector<uint8_t> values(size_t(owner.width) * 4);
      for (unsigned col = 0; col < owner.width; ++col)
        store32(values.data() + 4 * col, 0x3f800000u);
      expect_status(full::full_write(memory, output.bo, output.offset,
                                     values.data(), uint32_t(values.size())),
                    Status::OK, "finite result owner physical write");
      expect_status(full::full_cover_owner(runtime, owner, batch, 0, 1),
                    Status::OK, "cover result owner row");
    }
    expect_status(full::full_publish_owner(runtime, owner), Status::OK,
                  "publish result owner");
  }
  Check committed = full::full_write_result(runtime, memory, ok(), true,
                                            0, 0, 0, head, head);
  require(committed.code == Status::OK &&
          runtime.last_commit_error.code == Status::OK &&
          std::memcmp(io.data() + kResultOffset, "LYRS", 4) == 0 &&
          le32(io.data() + kResultOffset + 12) == kResultBytes,
          "full-capacity accepted result commit control");

  std::memset(io.data() + kResultOffset, 0, kResultBytes);
  memory.io_bytes = kResultOffset + kResultBytes - 1;
  committed = full::full_write_result(runtime, memory, ok(), true, 0, 0, 0,
                                      head, head);
  require(committed.code == Status::E_BUFFER &&
          committed.detail == detail(4, uint8_t(Bo::IO), 9) &&
          runtime.last_commit_error.code == committed.code &&
          runtime.last_commit_error.detail == committed.detail &&
          std::memcmp(io.data() + kResultOffset, "LYRS", 4) != 0,
          "short IO returns commit error after successful computation");
  memory.io_bytes = io.size();

  // Run an accepted request through the real controller. An injected
  // embedding gamma infinity fails at LOAD_LN_PARAMS before the result
  // commit; the one-byte-short result BO then fails its physical write too.
  std::vector<uint8_t> fault_aux(aux.data, aux.data + aux.size);
  full::FullTensorDescriptor gamma;
  expect_status(full::full_lookup_tensor("emb_norm_w", gamma), Status::OK,
                "embedding gamma descriptor for accepted graph fault");
  require(gamma.bo == uint8_t(Bo::AUX) &&
          uint64_t(gamma.base) + 4 <= fault_aux.size(),
          "gamma mutation stays in AUX BO");
  store32(fault_aux.data() + gamma.base, 0x7f800000u);
  std::vector<uint8_t> fault_io(io.size(), 0);
  std::memcpy(fault_io.data(), request.data(), request.size());
  full::FullMemory fault_memory = memory;
  fault_memory.io = fault_io.data();
  fault_memory.io_bytes = kResultOffset + kResultBytes - 1;
  fault_memory.aux = fault_aux.data();
  fault_memory.aux_bytes = fault_aux.size();
  static full::FullRuntime fault_runtime;
  fault_runtime.memory = fault_memory;
  const Check failed = full::full_execute_request(fault_runtime);
  require(failed.code == Status::E_NUMERICAL &&
          failed.detail == detail(7, uint8_t(Op::LOAD_LN_PARAMS), 15) &&
          failed.code == fault_runtime.last_execution_error.code &&
          failed.detail == fault_runtime.last_execution_error.detail &&
          failed.bad_element ==
              fault_runtime.last_execution_error.bad_element &&
          fault_runtime.tasks_retired == 17,
          "short IO preserves real accepted graph first cause");
  require(fault_runtime.last_commit_error.code == Status::E_BUFFER &&
          fault_runtime.last_commit_error.detail ==
              detail(4, uint8_t(Bo::IO), 9) &&
          std::memcmp(fault_io.data() + kResultOffset, "LYRS", 4) != 0,
          "short IO records secondary commit error without valid frame");

  std::cout << "FULL_MEMORY_PASS cases=31 weights=" << legal_weights
            << " result_commit_cases=3 short_io_failures=2\n";
}
