#include "laya_full_runtime.h"

#include <array>
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
struct Case {
  const char* name;
  uint8_t family, layer, stage, batch;
  RowSpace space;
  uint16_t row0, rows, K, N;
  Buffer source, dest;
  uint8_t source_region, dest_region;
  Op op;
};

constexpr Case cases[] = {
    {"qkv_full_b0", 1, 0, 2, 0, RowSpace::TOKEN, 0, 16, 1024, 3072,
     Buffer::NORM, Buffer::QKV, 0, 0, Op::LIN_QKV},
    {"wo_full_b1", 2, 0, 2, 1, RowSpace::TOKEN, 112, 16, 1024, 1024,
     Buffer::ATT_OUT, Buffer::TMP, 0, 0, Op::LIN_WO},
    {"wi_full_b0", 3, 0, 2, 0, RowSpace::TOKEN, 0, 16, 1024, 5248,
     Buffer::NORM, Buffer::WI, 0, 0, Op::LIN_WI},
    {"down_full_b1", 4, 0, 2, 1, RowSpace::TOKEN, 112, 16, 2624, 1024,
     Buffer::GATE, Buffer::TMP, 0, 0, Op::LIN_DOWN},
    {"decision_qkv_full_b0", 5, 0, 4, 0, RowSpace::TOKEN, 0, 16, 1024, 3072,
     Buffer::NORM, Buffer::QKV, 0, 0, Op::LIN_QKV},
    {"decision_wo_full_b1", 6, 0, 4, 1, RowSpace::TOKEN, 112, 16, 1024, 1024,
     Buffer::ATT_OUT, Buffer::TMP, 0, 0, Op::LIN_WO},
    {"decision_fc1_full_b0", 7, 0, 4, 0, RowSpace::TOKEN, 0, 16, 1024, 4096,
     Buffer::NORM, Buffer::DEC_FF, 0, 0, Op::LIN_DEC_FC1},
    {"decision_fc2_full_b1", 8, 0, 4, 1, RowSpace::TOKEN, 112, 16, 4096, 1024,
     Buffer::DEC_FF, Buffer::TMP, 0, 0, Op::LIN_DEC_FC2},
    {"scorer_fc1_full_b1", 9, 255, 5, 1, RowSpace::MARKER, 0, 16, 1024, 1024,
     Buffer::HEAD_WORK, Buffer::HEAD_WORK,
     uint8_t(Region::SCORER_ACT), uint8_t(Region::SCORER_ACT),
     Op::LIN_SCORER_FC1},
    {"act_fc2_n2_b0", 12, 255, 6, 0, RowSpace::BATCH, 0, 1, 256, 2,
     Buffer::HEAD_WORK, Buffer::HEAD_WORK,
     uint8_t(Region::ACT_HIDDEN), uint8_t(Region::ACT_LOGITS),
     Op::LIN_ACT_FC2},
};

void fail(const std::string& message) {
  std::cerr << "FULL_MATRIX_DUT_FAIL " << message << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& message) {
  if (!condition) fail(message);
}
void expect(Check c, const std::string& operation) {
  if (!c) fail(operation + " status=" + std::to_string(unsigned(c.code)) +
               " detail=" + std::to_string(c.detail) +
               " bad_element=" + std::to_string(c.bad_element));
}
std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "cannot open " + path);
  return {std::istreambuf_iterator<char>(input),
          std::istreambuf_iterator<char>()};
}
struct MappedFile {
  int fd = -1;
  const uint8_t* data = nullptr;
  size_t size = 0;
  explicit MappedFile(const std::string& path) {
    fd = open(path.c_str(), O_RDONLY);
    require(fd >= 0, "cannot open " + path);
    struct stat info {};
    require(fstat(fd, &info) == 0 && info.st_size > 0,
            "cannot stat " + path);
    size = size_t(info.st_size);
    void* view = mmap(nullptr, size, PROT_READ, MAP_PRIVATE, fd, 0);
    require(view != MAP_FAILED, "cannot mmap " + path);
    data = static_cast<const uint8_t*>(view);
  }
  MappedFile(const MappedFile&) = delete;
  MappedFile& operator=(const MappedFile&) = delete;
  ~MappedFile() {
    if (data) munmap(const_cast<uint8_t*>(data), size);
    if (fd >= 0) close(fd);
  }
};
uint32_t le32(const uint8_t* bytes) {
  return uint32_t(bytes[0]) | uint32_t(bytes[1]) << 8 |
         uint32_t(bytes[2]) << 16 | uint32_t(bytes[3]) << 24;
}
full::FullOwnerSpec owner(BufferRef ref, uint8_t region, const Case& c,
                          uint8_t batch, uint16_t row0, uint16_t rows,
                          uint16_t width, Content content) {
  return {ref, region, c.stage, c.layer, batch, c.space,
          row0, rows, width, content};
}
void write_source_row(full::FullRuntime& rt, BufferRef ref, uint8_t region,
                      uint8_t batch, uint16_t row, const uint8_t* bytes,
                      uint16_t width) {
  Address address;
  expect(full::full_f32_address(rt, ref, region, batch, row, 0, address),
         "source physical address");
  expect(full::full_write(rt.memory, address.bo, address.offset,
                          bytes, uint32_t(width) * 4),
         "source physical write");
}
void prepare_source(full::FullRuntime& rt, const Case& c,
                    BufferRef source_ref, const std::vector<uint8_t>& input,
                    full::FullOwnerSpec& source_spec) {
  require(input.size() == size_t(c.rows) * c.K * 4,
          "independent source byte count");
  if (c.source == Buffer::ATT_OUT) {
    source_spec = owner(source_ref, c.source_region, c, 255, 0,
                        rt.inputs.identity.S, 1024, Content::F32);
    expect(full::full_claim_owner(rt, source_spec), "claim ATT_OUT source");
    std::array<uint8_t, 1024 * 4> zeros{};
    for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
      for (unsigned row = 0; row < rt.inputs.identity.S; ++row)
        write_source_row(rt, source_ref, 0, uint8_t(batch), uint16_t(row),
                         zeros.data(), 1024);
    for (unsigned local = 0; local < c.rows; ++local)
      write_source_row(rt, source_ref, 0, c.batch,
                       uint16_t(c.row0 + local),
                       input.data() + size_t(local) * c.K * 4, c.K);
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
        expect(full::full_cover_att_head(rt, source_spec, uint8_t(head),
                                         uint8_t(batch), 0,
                                         rt.inputs.identity.S),
               "ATT_OUT source coverage after complete physical writes");
    expect(full::full_publish_att(rt, source_spec),
           "publish complete ATT_OUT source");
  } else {
    const bool scorer = c.op == Op::LIN_SCORER_FC1;
    source_spec = owner(source_ref, c.source_region, c,
                        scorer ? 255 : c.batch,
                        c.row0, c.rows, c.K, Content::F32);
    expect(full::full_claim_owner(rt, source_spec), "claim fixture source");
    if (scorer) {
      std::array<uint8_t, 1024 * 4> zeros{};
      for (unsigned row = 0; row < c.rows; ++row)
        write_source_row(rt, source_ref, c.source_region, 0,
                         uint16_t(c.row0 + row), zeros.data(), c.K);
    }
    for (unsigned local = 0; local < c.rows; ++local)
      write_source_row(rt, source_ref, c.source_region, c.batch,
                       uint16_t(c.row0 + local),
                       input.data() + size_t(local) * c.K * 4, c.K);
    if (scorer)
      expect(full::full_cover_owner(rt, source_spec, 0, c.row0, c.rows),
             "scorer b0 physical source coverage");
    expect(full::full_cover_owner(rt, source_spec, c.batch, c.row0, c.rows),
           "fixture source coverage after physical writes");
    expect(full::full_publish_owner(rt, source_spec),
           "publish written fixture source");
  }
}
void check_quant(const full::FullRuntime& rt, const Case& c,
                 const std::vector<uint8_t>& expected) {
  const unsigned groups = c.K / 32;
  require(expected.size() == size_t(c.rows) * groups * 34,
          "independent Q8 byte count");
  size_t at = 0;
  for (unsigned row = 0; row < c.rows; ++row)
    for (unsigned group = 0; group < groups; ++group) {
      const uint16_t scale = rt.cache.activation_scale[row][group];
      require(expected[at++] == uint8_t(scale) &&
              expected[at++] == uint8_t(scale >> 8),
              std::string(c.name) + " Q8 scale mismatch row=" +
                  std::to_string(row) + " group=" + std::to_string(group));
      for (unsigned k = 0; k < 32; ++k)
        require(expected[at++] == uint8_t(rt.cache.activation_q[row][group][k]),
                std::string(c.name) + " Q8 value mismatch row=" +
                    std::to_string(row) + " group=" +
                    std::to_string(group) + " k=" + std::to_string(k));
    }
}
void check_output(full::FullRuntime& rt, const Case& c, BufferRef dst_ref,
                  const std::vector<uint8_t>& expected) {
  require(expected.size() == size_t(c.rows) * c.N * 4,
          "independent full-N expected byte count");
  for (unsigned local = 0; local < c.rows; ++local)
    for (unsigned n = 0; n < c.N; ++n) {
      const uint16_t row = uint16_t(c.row0 + local);
      Address address;
      if (c.op == Op::LIN_QKV) {
        expect(qkv_address(uint8_t(n / 1024), c.batch,
                           uint8_t((n % 1024) / 64), row,
                           uint8_t(n % 64), rt.inputs.identity.B,
                           rt.inputs.identity.S, address),
               "QKV output physical address");
      } else {
        expect(full::full_f32_address(rt, dst_ref, c.dest_region,
                                      c.batch, row, uint16_t(n), address),
               "linear output physical address");
      }
      uint8_t got[4] = {};
      expect(full::full_read(rt.memory, address.bo, address.offset, got, 4),
             "linear output physical read");
      const uint32_t observed = le32(got);
      const uint32_t wanted = le32(expected.data() +
                                   (size_t(local) * c.N + n) * 4);
      if (observed != wanted)
        fail(std::string(c.name) + " full-N mismatch row=" +
             std::to_string(row) + " n=" + std::to_string(n) +
             " expected_bits=" + std::to_string(wanted) +
             " actual_bits=" + std::to_string(observed));
    }
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 5,
          "usage: full_matrix_dut_tb PACKAGE REQUEST FIXTURE_DIR CASE_NAME");
  const Case* selected = nullptr;
  for (const Case& candidate : cases)
    if (candidate.name == std::string(argv[4])) selected = &candidate;
  require(selected != nullptr, "unknown matrix case");
  const Case& c = *selected;
  const std::string fixture = std::string(argv[3]) + "/" + c.name;
  const auto input = read_file(fixture + ".source_f32.bin");
  const auto activation = read_file(fixture + ".activation_q8.bin");
  const auto expected = read_file(fixture + ".expected_f32.bin");
  const std::string package = argv[1];
  MappedFile embedding(package + "/embedding.bin");
  MappedFile q0(package + "/w_q0.bin");
  MappedFile q1(package + "/w_q1.bin");
  MappedFile scale(package + "/w_scale.bin");
  MappedFile aux(package + "/aux.bin");
  std::vector<uint8_t> request = read_file(argv[2]);
  require(request.size() == 1856 && aux.size >= 128,
          "real B2/S128 request/package header sizes");
  std::memcpy(request.data() + 40, aux.data + 32, 64);
  std::vector<uint8_t> io(32768, 0), state0(17u << 20, 0),
      state1(17u << 20, 0), qkv0(12u << 20, 0), qkv1(12u << 20, 0),
      ff0(42u << 20, 0), ff1(21u << 20, 0), att(8u << 20, 0);
  std::memcpy(io.data(), request.data(), request.size());
  static full::FullRuntime rt;
  auto& m = rt.memory;
  m.embedding = embedding.data; m.embedding_bytes = embedding.size;
  m.io = io.data(); m.io_bytes = io.size();
  m.w_q0 = q0.data; m.w_q0_bytes = q0.size;
  m.w_q1 = q1.data; m.w_q1_bytes = q1.size;
  m.w_scale = scale.data; m.w_scale_bytes = scale.size;
  m.aux = aux.data; m.aux_bytes = aux.size;
  m.state0 = state0.data(); m.state0_bytes = state0.size();
  m.state1 = state1.data(); m.state1_bytes = state1.size();
  m.qkv0 = qkv0.data(); m.qkv0_bytes = qkv0.size();
  m.qkv1 = qkv1.data(); m.qkv1_bytes = qkv1.size();
  m.ff0 = ff0.data(); m.ff0_bytes = ff0.size();
  m.ff1 = ff1.data(); m.ff1_bytes = ff1.size();
  m.att_out = att.data(); m.att_out_bytes = att.size();
  expect(full::full_parse_request(rt), "real request parse");
  require(rt.inputs.identity.B == 2 && rt.inputs.identity.S == 128,
          "real B2/S128 fixture scope");

  const BufferRef source_ref{c.source, 0, 1};
  full::FullOwnerSpec source_spec;
  prepare_source(rt, c, source_ref, input, source_spec);
  const BufferRef weight_ref{Buffer::WEIGHT, 0, 1};
  const WeightKey key{c.family, c.layer};
  TaskDone done;
  expect(full::full_load_weight(rt, key, weight_ref, done),
         "real package weight load");
  require(done.status == Status::OK && done.task_id == 1 && done.drained,
          "weight TaskDone contract");
  full::FullWeightDescriptor descriptor;
  expect(full::full_lookup_weight(key, descriptor), "weight descriptor");
  require(descriptor.K == c.K && descriptor.N == c.N,
          "fixture matches model descriptor dimensions");

  BufferRef dst_ref{c.dest, 0,
                    uint32_t(c.source == c.dest &&
                             c.source_region == c.dest_region ? 2 : 1)};
  const uint16_t scope_rows = c.space == RowSpace::TOKEN ?
                              rt.inputs.identity.S :
                              c.space == RowSpace::MARKER ? 16 : 1;
  const auto dst = owner(dst_ref, c.dest_region, c, 255, 0, scope_rows,
                         c.dest == Buffer::QKV ? 64 : c.N,
                         c.dest == Buffer::QKV ?
                             (c.stage == 4 ? Content::QKV_FINAL :
                                             Content::QKV_RAW) :
                             Content::F32);
  full::FullOwnerSpec qkv_pair[2] = {dst, dst};
  qkv_pair[1].ref.bank = 1;
  const bool same_physical = c.source == c.dest &&
                             c.source_region == c.dest_region;
  const bool scorer_lease = c.op == Op::LIN_SCORER_FC1;
  if (scorer_lease)
    expect(full::full_begin_inplace_owner(rt, source_spec, dst),
           "begin scorer full-B old/new lease");
  else if (!same_physical) {
    if (c.dest == Buffer::QKV)
      expect(full::full_claim_qkv_pair(rt, qkv_pair), "claim QKV destination");
    else
      expect(full::full_claim_owner(rt, dst), "claim matrix destination");
  }

  expect(full::full_bind_quant_source(rt, source_spec),
         "bind published independent source");
  QuantTask quant{};
  quant.ctx = {2, Op::QUANT, c.stage, c.layer, c.batch,
               c.space, c.row0, uint8_t(c.rows)};
  quant.src = source_ref;
  quant.a_dst = {Buffer::A8, 0, 1};
  quant.K = c.K;
  quant.src_region = c.source_region;
  quant.input_lanes = 8;
  expect(full::full_run_task(rt, quant, done), "typed quant task");
  require(done.status == Status::OK && done.task_id == 2 && done.drained &&
          done.output_elements == uint32_t(c.rows) * (c.K / 32),
          "quant TaskDone contract");
  check_quant(rt, c, activation);
  if (same_physical && !scorer_lease) {
    expect(full::full_release_owner(rt, source_spec),
           "release quant source before same-region matrix destination");
    expect(full::full_claim_owner(rt, dst),
           "claim next-epoch same-region matrix destination");
  }

  LinearTask linear{};
  linear.ctx = {3, c.op, c.stage, c.layer, c.batch,
                c.space, c.row0, uint8_t(c.rows)};
  linear.a = quant.a_dst;
  linear.w = weight_ref;
  linear.ps = {Buffer::PS, 0, 1};
  linear.dst = dst_ref;
  linear.weight = key;
  linear.K = c.K;
  linear.N = c.N;
  linear.dst_region = c.dest_region;
  linear.bias_kind = descriptor.bias_kind;
  expect(full::full_run_task(rt, linear, done), "typed full-N linear task");
  require(done.status == Status::OK && done.task_id == 3 && done.drained &&
          done.output_elements == uint32_t(c.rows) * c.N,
          "linear TaskDone contract");
  check_output(rt, c, dst_ref, expected);
  if (scorer_lease) {
    const Check incomplete = full::full_commit_inplace_owner(rt, dst);
    require(!incomplete && incomplete.code == Status::E_BUFFER,
            "single-batch scorer tile must not commit full-B lease");
    full::FullOwnerRecord record;
    expect(full::full_owner_snapshot(rt, dst.ref, dst.region, record),
           "scorer lease snapshot");
    require(record.state == CacheState::EXCLUSIVE_RW &&
            record.old_consumed_rows[0] == 0xffff0000u &&
            record.covered_rows[0] == 0xffff0000u,
            "only b1 scorer rows consumed and written");
  }
  std::cout << "FULL_MATRIX_DUT_PASS case=" << c.name
            << " rows=" << c.rows << " K=" << c.K << " N=" << c.N
            << " elements=" << uint32_t(c.rows) * c.N << '\n';
  return 0;
}
