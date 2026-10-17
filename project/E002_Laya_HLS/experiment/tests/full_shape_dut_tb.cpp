#include "laya_full_runtime.h"

#include <algorithm>
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
constexpr uint8_t kGuard = 0xa5;
constexpr unsigned kD = 64;

void fail(const std::string& message) {
  std::cerr << "FULL_SHAPE_DUT_FAIL " << message << '\n';
  std::exit(1);
}
void require(bool ok, const std::string& message) {
  if (!ok) fail(message);
}
void expect(Check c, const std::string& message) {
  if (!c) fail(message + " status=" + std::to_string(unsigned(c.code)) +
               " detail=" + std::to_string(c.detail));
}
void done_ok(const TaskDone& d, unsigned id, unsigned elements,
             OutputUnit unit, const std::string& label) {
  require(d.task_id == id && d.status == Status::OK && d.drained &&
          d.output_elements == elements && d.output_unit == unit,
          label + " TaskDone");
}
std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "open " + path);
  return {std::istreambuf_iterator<char>(in),
          std::istreambuf_iterator<char>()};
}
struct MappedFile {
  int fd = -1;
  const uint8_t* data = nullptr;
  size_t size = 0;
  explicit MappedFile(const std::string& path) {
    fd = open(path.c_str(), O_RDONLY);
    require(fd >= 0, "open " + path);
    struct stat statbuf {};
    require(fstat(fd, &statbuf) == 0 && statbuf.st_size > 0,
            "stat " + path);
    size = size_t(statbuf.st_size);
    void* view = mmap(nullptr, size, PROT_READ, MAP_PRIVATE, fd, 0);
    require(view != MAP_FAILED, "mmap " + path);
    data = static_cast<const uint8_t*>(view);
  }
  ~MappedFile() {
    if (data) munmap(const_cast<uint8_t*>(data), size);
    if (fd >= 0) close(fd);
  }
  MappedFile(const MappedFile&) = delete;
  MappedFile& operator=(const MappedFile&) = delete;
};
struct Model {
  MappedFile embedding, q0, q1, scale, aux;
  explicit Model(const std::string& base)
      : embedding(base + "/embedding.bin"), q0(base + "/w_q0.bin"),
        q1(base + "/w_q1.bin"), scale(base + "/w_scale.bin"),
        aux(base + "/aux.bin") {}
};
struct Buffers {
  std::vector<uint8_t> io = std::vector<uint8_t>(32768, 0);
  std::vector<uint8_t> state0 = std::vector<uint8_t>((17u << 20) + 64, kGuard);
  std::vector<uint8_t> state1 = std::vector<uint8_t>((17u << 20) + 64, kGuard);
  std::vector<uint8_t> qkv0 = std::vector<uint8_t>((12u << 20) + 64, kGuard);
  std::vector<uint8_t> qkv1 = std::vector<uint8_t>((12u << 20) + 64, kGuard);
  std::vector<uint8_t> att = std::vector<uint8_t>((8u << 20) + 64, kGuard);
  void attach(full::FullRuntime& rt, const Model& model,
              const std::vector<uint8_t>& request) {
    require(request.size() <= io.size(), "bounded ABI request");
    std::copy(request.begin(), request.end(), io.begin());
    auto& m = rt.memory;
    m.embedding = model.embedding.data;
    m.embedding_bytes = model.embedding.size;
    m.io = io.data(); m.io_bytes = io.size();
    m.w_q0 = model.q0.data; m.w_q0_bytes = model.q0.size;
    m.w_q1 = model.q1.data; m.w_q1_bytes = model.q1.size;
    m.w_scale = model.scale.data; m.w_scale_bytes = model.scale.size;
    m.aux = model.aux.data; m.aux_bytes = model.aux.size;
    m.state0 = state0.data(); m.state0_bytes = 17u << 20;
    m.state1 = state1.data(); m.state1_bytes = 17u << 20;
    m.qkv0 = qkv0.data(); m.qkv0_bytes = 12u << 20;
    m.qkv1 = qkv1.data(); m.qkv1_bytes = 12u << 20;
    m.att_out = att.data(); m.att_out_bytes = 8u << 20;
  }
  void guards(const std::string& label) const {
    for (const auto* buffer : {&state0, &state1, &qkv0, &qkv1, &att})
      require(std::all_of(buffer->end() - 64, buffer->end(),
                          [](uint8_t byte) { return byte == kGuard; }),
              label + " BO capacity guard");
  }
};
void compare(const uint8_t* got, const uint8_t* wanted, size_t bytes,
             const std::string& label) {
  if (std::memcmp(got, wanted, bytes) == 0) return;
  size_t at = 0;
  while (at < bytes && got[at] == wanted[at]) ++at;
  fail(label + " first mismatched byte=" + std::to_string(at));
}
void compare_f32_rows(full::FullRuntime& rt, BufferRef ref,
                      unsigned batch, unsigned row0, unsigned rows,
                      unsigned width, const std::vector<uint8_t>& wanted,
                      const std::string& label, unsigned column = 0) {
  require(wanted.size() == size_t(rows) * width * 4,
          label + " oracle span");
  for (unsigned local = 0; local < rows; ++local) {
    Address address;
    expect(full::full_f32_address(rt, ref, 0, uint8_t(batch),
                                   uint16_t(row0 + local),
                                   uint16_t(column), address),
           label + " address");
    std::vector<uint8_t> got(width * 4);
    expect(full::full_read(rt.memory, address.bo, address.offset,
                            got.data(), uint32_t(got.size())),
           label + " read");
    compare(got.data(), wanted.data() + size_t(local) * width * 4,
            got.size(), label + " row=" + std::to_string(row0 + local));
  }
}
void check_tail_address(full::FullRuntime& rt, BufferRef ref,
                        Bo bo, uint32_t base, unsigned S,
                        const std::string& label) {
  Address a;
  expect(full::full_f32_address(rt, ref, 0, 1, uint16_t(S - 1), 1023, a),
         label + " last coordinate");
  const uint32_t expected = base +
      uint32_t((1024u + S - 1) * 1024u + 1023u) * 4u;
  require(a.bo == bo && a.offset == expected,
          label + " independent physical last-column formula");
  require(full::full_f32_address(rt, ref, 0, 1, uint16_t(S), 0, a).code ==
              Status::E_BUFFER &&
          full::full_f32_address(rt, ref, 0, 1, uint16_t(S - 1), 1024, a).code ==
              Status::E_BUFFER,
          label + " first invalid row/column");
}

void run_front(const Model& model, const std::vector<uint8_t>& request,
               const std::string& fixture, unsigned S) {
  static full::FullRuntime rt;
  Buffers buffers;
  buffers.attach(rt, model, request);
  expect(full::full_parse_request(rt), "front adapted B2 parse");
  require(rt.inputs.identity.B == 2 && rt.inputs.identity.S == S,
          "front active shape");
  const auto raw = read_file(fixture + "/front_raw.f32.bin");
  const auto norm_bytes = read_file(fixture + "/front_norm.f32.bin");
  const auto q8 = read_file(fixture + "/front_quant.q8.bin");
  const uint16_t row0 = uint16_t(S - 16);
  const full::FullOwnerSpec hidden{{Buffer::HIDDEN, 0, 1}, 0, 1, 255,
                                    255, RowSpace::TOKEN, 0, uint16_t(S), 1024,
                                    Content::F32};
  expect(full::full_claim_owner(rt, hidden), "claim complete embedding owner");
  TaskDone done;
  unsigned id = 0;
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned row = 0; row < S; row += 16) {
      EmbeddingTask emb{};
      emb.ctx = {++id, Op::EMB_TOKEN, 1, 255, uint8_t(batch),
                 RowSpace::TOKEN, uint16_t(row), 16};
      emb.table = 0; emb.dst = hidden.ref;
      expect(full::full_run_task(rt, emb, done), "typed Embedding tile");
      done_ok(done, id, 16 * 1024, OutputUnit::F32,
              "Embedding tile");
    }
  expect(full::full_publish_owner(rt, hidden),
         "publish complete Embedding");
  compare_f32_rows(rt, hidden.ref, 1, row0, 16, 1024, raw,
                   "tail Embedding");
  check_tail_address(rt, hidden.ref, Bo::STATE0, 0, S, "HIDDEN");

  LoadTask gamma{};
  gamma.ctx = {++id, Op::LOAD_LN_PARAMS, 1, 255, 0,
               RowSpace::BATCH, 0, 1};
  gamma.kind = 2; gamma.dst = {Buffer::LN_GAMMA, 0, 1};
  gamma.byte_count = 4096;
  expect(full::full_run_task(rt, gamma, done), "typed gamma load");
  done_ok(done, id, 4096, OutputUnit::BYTES, "gamma load");
  const full::FullOwnerSpec normalized{{Buffer::NORM, 0, 1}, 0, 1, 255,
                                        255, RowSpace::TOKEN, 0,
                                        uint16_t(S), 1024,
                                        Content::F32};
  expect(full::full_claim_owner(rt, normalized),
         "claim complete LN owner");
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned row = 0; row < S; row += 16) {
      LayerNormTask ln{};
      ln.ctx = {++id, Op::LN_EMB, 1, 255, uint8_t(batch),
                RowSpace::TOKEN, uint16_t(row), 16};
      ln.src = hidden.ref; ln.dst = normalized.ref; ln.gamma = 1;
      expect(full::full_bind_task_source(rt, hidden),
             "bind Embedding source");
      expect(full::full_run_task(rt, ln, done), "typed LN tile");
      done_ok(done, id, 16 * 1024, OutputUnit::F32, "LN tile");
    }
  expect(full::full_publish_owner(rt, normalized),
         "publish complete LN");
  compare_f32_rows(rt, normalized.ref, 1, row0, 16, 1024,
                   norm_bytes, "tail LN");
  check_tail_address(rt, normalized.ref, Bo::STATE0, 8u << 20, S, "NORM");

  std::memset(rt.cache.activation_q, kGuard,
              sizeof(rt.cache.activation_q));
  std::memset(rt.cache.activation_scale, kGuard,
              sizeof(rt.cache.activation_scale));
  QuantTask quant{};
  quant.ctx = {++id, Op::QUANT, 2, 0, 1,
               RowSpace::TOKEN, row0, 16};
  quant.src = normalized.ref; quant.a_dst = {Buffer::A8, 0, 1};
  quant.K = 1024;
  expect(full::full_bind_quant_source(rt, normalized), "bind tail LN source");
  expect(full::full_run_task(rt, quant, done), "typed tail Quant");
  done_ok(done, id, 16 * 32, OutputUnit::Q8_GROUP, "tail Quant");
  require(q8.size() == 16u * 32u * 34u, "tail Quant oracle bytes");
  for (unsigned row = 0; row < 16; ++row)
    for (unsigned group = 0; group < 32; ++group) {
      const size_t at = (size_t(row) * 32 + group) * 34;
      const uint16_t scale = rt.cache.activation_scale[row][group];
      require(q8[at] == uint8_t(scale) &&
              q8[at + 1] == uint8_t(scale >> 8),
              "tail Quant scale row/group");
      compare(reinterpret_cast<const uint8_t*>(
                  rt.cache.activation_q[row][group]),
              q8.data() + at + 2, 32, "tail Quant q row/group");
    }
  for (unsigned row = 0; row < 16; ++row)
    require(rt.cache.activation_scale[row][32] == 0xa5a5 &&
            std::all_of(std::begin(rt.cache.activation_q[row][32]),
                        std::end(rt.cache.activation_q[row][32]),
                        [](int8_t value) {
                          return uint8_t(value) == kGuard;
                        }),
            "Quant group after K bound untouched");
  if (S < 1024) {
    const uint32_t inactive = ((1024u + S) * 1024u) * 4u;
    require(buffers.state0[inactive] == kGuard &&
            buffers.state0[(8u << 20) + inactive] == kGuard,
            "first inactive physical row untouched by front tasks");
  }
  buffers.guards("front");
}

void run_qkv_linear(const Model& model,
                    const std::vector<uint8_t>& request,
                    const std::string& matrix_fixture, unsigned S) {
  static full::FullRuntime rt;
  Buffers buffers;
  buffers.attach(rt, model, request);
  expect(full::full_parse_request(rt), "QKV adapted B2 parse");
  const auto source = read_file(matrix_fixture +
                                "/qkv_full_b0.source_f32.bin");
  const auto activation = read_file(matrix_fixture +
                                    "/qkv_full_b0.activation_q8.bin");
  const auto wanted = read_file(matrix_fixture +
                                "/qkv_full_b0.expected_f32.bin");
  require(source.size() == 16u * 1024u * 4u &&
          activation.size() == 16u * 32u * 34u &&
          wanted.size() == 16u * 3072u * 4u,
          "independent full-N QKV fixture spans");
  const uint16_t row0 = uint16_t(S - 16);
  const full::FullOwnerSpec source_owner{{Buffer::NORM, 0, 1}, 0, 2, 0,
                                          1, RowSpace::TOKEN, row0, 16,
                                          1024, Content::F32};
  expect(full::full_claim_owner(rt, source_owner), "claim QKV source");
  for (unsigned local = 0; local < 16; ++local) {
    Address a;
    expect(full::full_f32_address(rt, source_owner.ref, 0, 1,
                                   uint16_t(row0 + local), 0, a),
           "QKV source address");
    expect(full::full_write(rt.memory, a.bo, a.offset,
                            source.data() + size_t(local) * 1024 * 4,
                            1024 * 4), "QKV source physical seed");
  }
  expect(full::full_cover_owner(rt, source_owner, 1, row0, 16),
         "cover QKV source fixture");
  expect(full::full_publish_owner(rt, source_owner),
         "publish QKV source fixture");
  TaskDone done;
  const BufferRef w{Buffer::WEIGHT, 0, 1};
  expect(full::full_load_weight(rt, {1, 0}, w, done),
         "typed full QKV W load");
  done_ok(done, 1, done.output_elements, OutputUnit::BYTES, "QKV W load");
  const full::FullOwnerSpec qkv[2] = {
      {{Buffer::QKV, 0, 1}, 0, 2, 0, 255,
       RowSpace::TOKEN, 0, uint16_t(S), 64, Content::QKV_RAW},
      {{Buffer::QKV, 1, 1}, 0, 2, 0, 255,
       RowSpace::TOKEN, 0, uint16_t(S), 64, Content::QKV_RAW}};
  expect(full::full_claim_qkv_pair(rt, qkv), "claim complete QKV pair");
  QuantTask quant{};
  quant.ctx = {2, Op::QUANT, 2, 0, 1, RowSpace::TOKEN, row0, 16};
  quant.src = source_owner.ref; quant.a_dst = {Buffer::A8, 0, 1};
  quant.K = 1024;
  expect(full::full_bind_quant_source(rt, source_owner),
         "bind QKV source fixture");
  expect(full::full_run_task(rt, quant, done), "typed QKV Quant");
  done_ok(done, 2, 16 * 32, OutputUnit::Q8_GROUP, "QKV Quant");
  for (unsigned row = 0; row < 16; ++row)
    for (unsigned group = 0; group < 32; ++group) {
      const size_t at = (size_t(row) * 32 + group) * 34;
      const uint16_t scale = rt.cache.activation_scale[row][group];
      require(activation[at] == uint8_t(scale) &&
              activation[at + 1] == uint8_t(scale >> 8),
              "QKV Quant scale");
      compare(reinterpret_cast<const uint8_t*>(
                  rt.cache.activation_q[row][group]),
              activation.data() + at + 2, 32, "QKV Quant q");
    }
  LinearTask linear{};
  linear.ctx = {3, Op::LIN_QKV, 2, 0, 1,
                RowSpace::TOKEN, row0, 16};
  linear.a = quant.a_dst; linear.w = w;
  linear.ps = {Buffer::PS, 0, 1}; linear.dst = qkv[0].ref;
  linear.weight = {1, 0}; linear.K = 1024; linear.N = 3072;
  expect(full::full_run_task(rt, linear, done), "typed tail QKV full-N");
  done_ok(done, 3, 16 * 3072, OutputUnit::F32, "tail QKV full-N");
  for (unsigned local = 0; local < 16; ++local)
    for (unsigned plane = 0; plane < 3; ++plane)
      for (unsigned head = 0; head < 16; ++head) {
        Address a;
        expect(qkv_address(uint8_t(plane), 1, uint8_t(head),
                           uint16_t(row0 + local), 0, 2, uint16_t(S), a),
               "tail QKV scatter address");
        std::array<uint8_t, 256> got{};
        expect(full::full_read(rt.memory, a.bo, a.offset,
                                got.data(), got.size()),
               "tail QKV scatter read");
        const size_t at = (size_t(local) * 3072 + plane * 1024 +
                           head * 64) * 4;
        compare(got.data(), wanted.data() + at, got.size(),
                "tail QKV full-N row/plane/head");
      }
  require(full::full_publish_qkv_pair(rt, qkv).code == Status::E_BUFFER,
          "tail-only QKV cannot masquerade as full published tensor");
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head) {
      Address a;
      expect(qkv_address(uint8_t(plane), 1, uint8_t(head),
                         uint16_t(S - 1), 63, 2, uint16_t(S), a),
             "QKV last row/column address");
      const uint32_t expected = uint32_t(
          (((((plane * 2u + 1u) * 8u + head / 2u) * 1024u +
              (S - 1u)) * 64u) + 63u) * 4u);
      require(a.bo == (head & 1 ? Bo::QKV1 : Bo::QKV0) &&
              a.offset == expected,
              "QKV independent two-shard address formula");
      require(qkv_address(uint8_t(plane), 1, uint8_t(head),
                          uint16_t(S), 0, 2, uint16_t(S), a).code ==
                  Status::E_BUFFER &&
              qkv_address(uint8_t(plane), 1, uint8_t(head),
                          uint16_t(S - 1), 64, 2, uint16_t(S), a).code ==
                  Status::E_BUFFER,
              "QKV first invalid row/column");
    }
  const uint32_t before = uint32_t(
      (((((2u * 2u + 1u) * 8u + 7u) * 1024u +
          (S - 17u)) * 64u) + 63u) * 4u);
  require(buffers.qkv1[before] == kGuard,
          "QKV previous row untouched by tail tile");
  buffers.guards("QKV linear");
}

void run_attention(const Model& model,
                   const std::vector<uint8_t>& request,
                   const std::string& fixture_root,
                   const std::string& fixture, unsigned S) {
  static full::FullRuntime rt;
  Buffers buffers;
  buffers.attach(rt, model, request);
  expect(full::full_parse_request(rt), "attention adapted B2 parse");
  const auto raw = read_file(fixture_root + "/raw_qkv_128.f32.bin");
  const auto scores = read_file(fixture + "/score.f32.bin");
  const auto probs = read_file(fixture + "/prob.f32.bin");
  const auto outputs = read_file(fixture + "/av.f32.bin");
  require(raw.size() == 2u * 128u * 3072u * 4u &&
          scores.size() == 2u * 16u * S * 4u &&
          probs.size() == scores.size() &&
          outputs.size() == 2u * 16u * 64u * 4u,
          "attention source and independent oracle spans");
  const full::FullOwnerSpec qkv[2] = {
      {{Buffer::QKV, 0, 1}, 0, 4, 0, 255,
       RowSpace::TOKEN, 0, uint16_t(S), 64, Content::QKV_FINAL},
      {{Buffer::QKV, 1, 1}, 0, 4, 0, 255,
       RowSpace::TOKEN, 0, uint16_t(S), 64, Content::QKV_FINAL}};
  expect(full::full_claim_qkv_pair(rt, qkv),
         "claim externally seeded complete QKV input");
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned batch = 0; batch < 2; ++batch) {
        for (unsigned row = 0; row < S; ++row) {
          Address a;
          expect(qkv_address(uint8_t(plane), uint8_t(batch),
                             uint8_t(head), uint16_t(row), 0, 2,
                             uint16_t(S), a), "QKV fixture address");
          const unsigned native_row = std::min(row, 127u);
          const size_t at = (((size_t(batch) * 128 + native_row) * 3072 +
                              plane * 1024 + head * 64) * 4);
          expect(full::full_write(rt.memory, a.bo, a.offset,
                                  raw.data() + at, 64 * 4),
                 "physical QKV fixture write");
        }
        expect(full::full_cover_qkv(rt, qkv, uint8_t(plane),
                                    uint8_t(head), uint8_t(batch),
                                    0, uint16_t(S)),
               "cover complete QKV source after physical write");
      }
  expect(full::full_publish_qkv_pair(rt, qkv),
         "publish complete seeded QKV input");
  TaskDone done;
  LoadTask kv{};
  kv.ctx = {1, Op::LOAD_KV, 4, 0, 0, RowSpace::BATCH, 0, 1};
  kv.kind = 1; kv.dst = {Buffer::KV, 0, 1};
  kv.head = 15; kv.planes = 3;
  kv.byte_count = 2u * 2u * S * 64u * 4u;
  expect(full::full_run_task(rt, kv, done), "typed head15 KV load");
  done_ok(done, 1, kv.byte_count, OutputUnit::BYTES, "head15 KV load");
  const full::FullOwnerSpec att{{Buffer::ATT_OUT, 0, 1}, 0, 4, 0, 255,
                                 RowSpace::TOKEN, 0, uint16_t(S),
                                 1024, Content::F32};
  expect(full::full_claim_owner(rt, att), "claim ATT_OUT");
  unsigned id = 1, score_epoch = 1, partial_epoch = 1;
  for (unsigned batch = 0; batch < 2; ++batch) {
    const uint16_t row0 = uint16_t(S - 16);
    QKTask qk{};
    qk.ctx = {++id, Op::QK, 4, 0, uint8_t(batch),
              RowSpace::TOKEN, row0, 16};
    qk.qkv_ref = {qkv[0].ref, qkv[1].ref};
    qk.kv = kv.dst;
    qk.score = {Buffer::SCORE_PROB, 0, score_epoch};
    qk.head = 15; qk.mask_mode = 0; qk.S = uint16_t(S);
    expect(full::full_run_task(rt, qk, done), "typed head15 tail QK");
    done_ok(done, id, 16 * S, OutputUnit::F32, "head15 tail QK");
    for (unsigned row = 0; row < 16; ++row)
      compare(reinterpret_cast<const uint8_t*>(rt.cache.score[batch][row]),
              scores.data() + (size_t(batch) * 16 + row) * S * 4,
              S * 4, "head15 tail QK full S");
    const full::FullOwnerSpec score_owner{
        qk.score, 0, 4, 0, uint8_t(batch), RowSpace::TOKEN,
        row0, 16, uint16_t(S), Content::SCORE};
    auto prob_owner = score_owner;
    prob_owner.ref.epoch = score_epoch + 1;
    prob_owner.content = Content::PROB;
    expect(full::full_begin_inplace_owner(rt, score_owner, prob_owner),
           "begin tail score/prob lease");
    SoftmaxTask softmax{};
    softmax.ctx = {++id, Op::SOFTMAX_ATT, 4, 0, uint8_t(batch),
                   RowSpace::TOKEN, row0, 16};
    softmax.src = qk.score;
    softmax.dst = prob_owner.ref;
    softmax.length = uint16_t(S);
    expect(full::full_run_task(rt, softmax, done),
           "typed head15 tail softmax");
    done_ok(done, id, 16 * S, OutputUnit::F32,
            "head15 tail softmax");
    for (unsigned row = 0; row < 16; ++row)
      compare(reinterpret_cast<const uint8_t*>(rt.cache.score[batch][row]),
              probs.data() + (size_t(batch) * 16 + row) * S * 4,
              S * 4, "head15 tail softmax full S");
    AVTask av{};
    av.ctx = {++id, Op::AV, 4, 0, uint8_t(batch),
              RowSpace::TOKEN, row0, 16};
    av.prob = prob_owner.ref; av.kv = kv.dst;
    av.partial = {Buffer::AV_PARTIAL, 0, partial_epoch++};
    av.dst = att.ref; av.head = 15; av.S = uint16_t(S);
    expect(full::full_run_task(rt, av, done), "typed head15 tail AV");
    done_ok(done, id, 16 * 64, OutputUnit::F32, "head15 tail AV");
    for (unsigned row = 0; row < 16; ++row) {
      const uint8_t* wanted = outputs.data() +
                              (size_t(batch) * 16 + row) * 64 * 4;
      compare(reinterpret_cast<const uint8_t*>(rt.cache.av_partial[row]),
              wanted, 64 * 4, "head15 AV cache");
      Address a;
      expect(full::full_f32_address(rt, att.ref, 0, uint8_t(batch),
                                     uint16_t(row0 + row), 15 * 64, a),
             "head15 ATT_OUT scatter address");
      std::array<uint8_t, 256> got{};
      expect(full::full_read(rt.memory, a.bo, a.offset,
                              got.data(), got.size()),
             "head15 ATT_OUT scatter read");
      compare(got.data(), wanted, got.size(),
              "head15 ATT_OUT physical bytes");
    }
    score_epoch += 2;
  }
  require(full::full_publish_att(rt, att).code == Status::E_BUFFER,
          "head15-only ATT_OUT cannot publish full tensor");
  check_tail_address(rt, att.ref, Bo::ATT_OUT, 0, S, "ATT_OUT");
  Address a;
  expect(full::full_f32_address(rt, att.ref, 0, 1,
                                 uint16_t(S - 1), 14 * 64 + 63, a),
         "ATT_OUT previous head final column address");
  require(buffers.att[a.offset] == kGuard,
          "neighbor head output not clobbered");
  buffers.guards("attention");
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 5,
          "usage: full_shape_dut_tb PACKAGE SHAPE_FIXTURE_ROOT "
          "MATRIX_FIXTURE S");
  const unsigned S = unsigned(std::strtoul(argv[4], nullptr, 10));
  require(S == 64 || S == 256 || S == 512 || S == 1024,
          "required focused shape");
  const std::string fixture = std::string(argv[2]) + "/S" +
                              std::to_string(S);
  const auto request = read_file(fixture + "/request.bin");
  Model model(argv[1]);
  run_front(model, request, fixture, S);
  run_qkv_linear(model, request, argv[3], S);
  run_attention(model, request, argv[2], fixture, S);
  std::cout << "FULL_SHAPE_DUT_PASS B=2 S=" << S
            << " scope=typed_tasks_and_addresses_not_full_network"
            << " front_rows=16 qkv_full_N=3072"
            << " attention_head=15 query_rows=16" << '\n';
}
