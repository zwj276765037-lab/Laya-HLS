#include "laya_full_runtime.h"

#include <array>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;

namespace {
unsigned checks = 0;

void require(bool condition, const char* message) {
  ++checks;
  if (!condition) {
    std::cerr << "FULL_OWNER_FAIL " << message << '\n';
    std::exit(1);
  }
}

void expect(Check actual, Status expected, const char* message) {
  require(actual.code == expected, message);
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "open input file");
  return {std::istreambuf_iterator<char>(input),
          std::istreambuf_iterator<char>()};
}

full::FullOwnerSpec spec(BufferRef ref, uint8_t region, uint8_t stage,
                         uint8_t layer, uint8_t batch, RowSpace space,
                         uint16_t row0, uint16_t rows, uint16_t width,
                         Content content) {
  return {ref, region, stage, layer, batch, space, row0, rows, width, content};
}

void write_row(full::FullRuntime& rt, const full::FullOwnerSpec& s,
               uint8_t batch, uint16_t row, uint32_t marker) {
  Address address;
  expect(full::full_f32_address(rt, s.ref, s.region, batch, row, 0, address),
         Status::OK, "physical owner row address");
  std::vector<uint8_t> bytes(size_t(s.width) * 4, 0);
  for (unsigned i = 0; i < 4; ++i) {
    bytes[i] = uint8_t(marker >> (8 * i));
    bytes[bytes.size() - 4 + i] = uint8_t((marker + 1) >> (8 * i));
  }
  expect(full::full_write(rt.memory, address.bo, address.offset,
                          bytes.data(), uint32_t(bytes.size())),
         Status::OK, "physical owner row write");
  std::array<uint8_t, 4> observed{};
  expect(full::full_read(rt.memory, address.bo, address.offset,
                         observed.data(), observed.size()),
         Status::OK, "physical owner row readback");
  require(std::memcmp(observed.data(), bytes.data(), observed.size()) == 0,
          "owner row write/readback identity");
}

void write_and_cover(full::FullRuntime& rt, const full::FullOwnerSpec& s,
                     uint8_t batch, uint16_t row0, uint16_t rows,
                     uint32_t marker) {
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    write_row(rt, s, batch, row, marker + row);
  expect(full::full_cover_owner(rt, s, batch, row0, rows), Status::OK,
         "covered only after physical row writes");
}

void write_qkv(full::FullRuntime& rt, uint8_t plane, uint8_t head,
               uint8_t batch, uint16_t row) {
  Address address;
  expect(qkv_address(plane, batch, head, row, 0,
                     rt.inputs.identity.B, rt.inputs.identity.S, address),
         Status::OK, "physical QKV address");
  std::array<uint8_t, 64 * 4> bytes{};
  bytes[0] = uint8_t(1 + plane + head + batch + row);
  expect(full::full_write(rt.memory, address.bo, address.offset,
                          bytes.data(), bytes.size()),
         Status::OK, "physical QKV head write");
}

void write_att_head(full::FullRuntime& rt, const full::FullOwnerSpec& s,
                    uint8_t head, uint8_t batch, uint16_t row) {
  Address address;
  expect(full::full_f32_address(rt, s.ref, s.region, batch, row,
                                uint16_t(head * 64), address),
         Status::OK, "physical ATT_OUT address");
  std::array<uint8_t, 64 * 4> bytes{};
  bytes[0] = uint8_t(1 + head + batch + row);
  expect(full::full_write(rt.memory, address.bo, address.offset,
                          bytes.data(), bytes.size()),
         Status::OK, "physical ATT_OUT head write");
}

void store64(uint8_t* dst, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) dst[i] = uint8_t(value >> (8 * i));
}

uint32_t load32(const uint8_t* src) {
  return uint32_t(src[0]) | uint32_t(src[1]) << 8 |
         uint32_t(src[2]) << 16 | uint32_t(src[3]) << 24;
}

full::FullTensorDescriptor tensor_named(const char* name) {
  for (unsigned i = 0; i < 153; ++i) {
    full::FullTensorDescriptor tensor;
    expect(full::full_tensor_descriptor(uint16_t(i), tensor), Status::OK,
           "generated tensor descriptor lookup");
    if (std::strcmp(tensor.name, name) == 0) return tensor;
  }
  require(false, "named tensor descriptor exists");
  return {};
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 3, "usage: full_owner_tb PACKAGE_DIR REQUEST_V1_BIN");
  std::vector<uint8_t> request = read_file(argv[2]);
  std::vector<uint8_t> aux = read_file(std::string(argv[1]) + "/aux.bin");
  require(request.size() == 1856 && aux.size() >= 128,
          "real B2/S128 ABI request and package aux sizes");
  std::memcpy(request.data() + 40, aux.data() + 32, 64);

  std::vector<uint8_t> io(32768, 0), state0(17u << 20, 0),
      state1(17u << 20, 0), qkv0(12u << 20, 0), qkv1(12u << 20, 0),
      ff0(42u << 20, 0), att(8u << 20, 0);
  std::memcpy(io.data(), request.data(), request.size());
  static full::FullRuntime rt;
  rt.memory.io = io.data(); rt.memory.io_bytes = io.size();
  rt.memory.aux = aux.data(); rt.memory.aux_bytes = aux.size();
  rt.memory.state0 = state0.data(); rt.memory.state0_bytes = state0.size();
  rt.memory.state1 = state1.data(); rt.memory.state1_bytes = state1.size();
  rt.memory.qkv0 = qkv0.data(); rt.memory.qkv0_bytes = qkv0.size();
  rt.memory.qkv1 = qkv1.data(); rt.memory.qkv1_bytes = qkv1.size();
  rt.memory.ff0 = ff0.data(); rt.memory.ff0_bytes = ff0.size();
  rt.memory.att_out = att.data(); rt.memory.att_out_bytes = att.size();
  store64(io.data() + 24, 97);

  const auto wi = spec({Buffer::WI, 0, 1}, 0, 2, 0, 0,
                       RowSpace::TOKEN, 0, 1, 5248, Content::F32);
  expect(full::full_claim_owner(rt, wi), Status::E_PROTOCOL,
         "claim is gated before request parse");
  expect(full::full_parse_request(rt), Status::OK, "real request parse");
  require(rt.inputs.identity.B == 2 && rt.inputs.identity.S == 128,
          "real B2/S128 owner scope");
  const uint64_t first_request_id = rt.inputs.identity.request_id;
  expect(full::full_parse_request(rt), Status::E_PROTOCOL,
         "accepted request ID cannot be replayed before any task");
  require(!rt.request_valid && rt.tasks_retired == 0,
          "duplicate accepted ID closes task gate without retirement");
  store64(io.data() + 24, first_request_id + 1);
  expect(full::full_parse_request(rt), Status::OK,
         "strictly newer same-generation request accepted");
  TaskDone early_failure;
  expect(full::full_load_weight(rt, {0, 255}, {Buffer::WEIGHT, 0, 1},
                                early_failure), Status::E_MODEL,
         "bad WeightKey fails before task retirement");
  require(rt.tasks_retired == 0 && rt.last_task_id == 0,
          "early accepted execution failure has no retired task");
  expect(full::full_parse_request(rt), Status::E_PROTOCOL,
         "accepted ID consumed despite pre-retirement execution failure");
  store64(io.data() + 24, first_request_id + 2);
  io[40] ^= 1;
  expect(full::full_parse_request(rt), Status::E_MODEL,
         "malformed new ID rejected before acceptance");
  expect(full::full_claim_owner(rt, wi), Status::E_PROTOCOL,
         "failed parse closes owner claims");
  io[40] ^= 1;
  expect(full::full_parse_request(rt), Status::OK,
         "corrected malformed new ID remains available for acceptance");

  expect(full::full_claim_owner(rt, wi), Status::OK, "claim WI");
  expect(full::full_publish_owner(rt, wi), Status::E_BUFFER,
         "unwritten WI cannot publish");
  write_and_cover(rt, wi, 0, 0, 1, 0x3f800000u);
  expect(full::full_publish_owner(rt, wi), Status::OK, "publish written WI");
  expect(full::full_acquire_owner(rt, wi, 0, 0, 1), Status::OK,
         "acquire WI read lease");
  expect(full::full_cover_owner(rt, wi, 0, 0, 1), Status::E_BUFFER,
         "READ owner rejects writer");
  expect(full::full_release_owner(rt, wi), Status::E_BUFFER,
         "READ owner cannot release physical storage");
  expect(full::full_release_read_owner(rt, wi), Status::OK,
         "release WI read lease");
  const uint64_t request_id = rt.inputs.identity.request_id;
  ++rt.inputs.identity.request_id;
  expect(full::full_require_owner(rt, wi, 0, 0, 1), Status::E_BUFFER,
         "wrong request identity rejects stale owner");
  rt.inputs.identity.request_id = request_id;
  const auto dec2 = spec({Buffer::DEC_FF, 0, 2}, 0, 2, 0, 0,
                         RowSpace::TOKEN, 0, 1, 4096, Content::F32);
  expect(full::full_claim_owner(rt, dec2), Status::E_BUFFER,
         "WI and DEC_FF share physical lock");
  expect(full::full_release_owner(rt, wi), Status::OK, "release WI");
  auto dec1 = dec2;
  dec1.ref.epoch = 1;
  expect(full::full_claim_owner(rt, dec1), Status::E_BUFFER,
         "WI to DEC_FF cannot reuse physical epoch");
  expect(full::full_claim_owner(rt, dec2), Status::OK,
         "DEC_FF advances shared physical epoch");
  write_and_cover(rt, dec2, 0, 0, 1, 0x40000000u);
  expect(full::full_publish_owner(rt, dec2), Status::OK,
         "publish written DEC_FF");
  expect(full::full_release_owner(rt, dec2), Status::OK, "release DEC_FF");

  const full::FullOwnerSpec qkv[2] = {
      spec({Buffer::QKV, 0, 1}, 0, 2, 0, 255,
           RowSpace::TOKEN, 0, 128, 64, Content::QKV_RAW),
      spec({Buffer::QKV, 1, 1}, 0, 2, 0, 255,
           RowSpace::TOKEN, 0, 128, 64, Content::QKV_RAW)};
  const full::FullOwnerSpec duplicate[2] = {qkv[0], qkv[0]};
  expect(full::full_claim_qkv_pair(rt, duplicate), Status::E_BUFFER,
         "duplicate QKV shard pair rejected atomically");
  full::FullOwnerRecord snapshot;
  expect(full::full_owner_snapshot(rt, qkv[0].ref, 0, snapshot),
         Status::E_BUFFER, "rejected QKV pair leaves shard unclaimed");
  expect(full::full_claim_qkv_pair(rt, qkv), Status::OK,
         "claim both QKV shards atomically");
  expect(full::full_publish_qkv_pair(rt, qkv), Status::E_BUFFER,
         "QKV cannot publish without head-plane coverage");
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned batch = 0; batch < 2; ++batch) {
        const unsigned rows = plane == 2 && head == 15 && batch == 1 ? 127 : 128;
        for (unsigned row = 0; row < rows; ++row)
          write_qkv(rt, uint8_t(plane), uint8_t(head), uint8_t(batch),
                    uint16_t(row));
        expect(full::full_cover_qkv(rt, qkv, uint8_t(plane), uint8_t(head),
                                    uint8_t(batch), 0, uint16_t(rows)),
               Status::OK, "QKV cover after physical shard writes");
      }
  expect(full::full_publish_qkv_pair(rt, qkv), Status::E_BUFFER,
         "one missing QKV head-plane row blocks both shards");
  write_qkv(rt, 2, 15, 1, 127);
  expect(full::full_cover_qkv(rt, qkv, 2, 15, 1, 127, 1), Status::OK,
         "last QKV row covered after write");
  expect(full::full_publish_qkv_pair(rt, qkv), Status::OK,
         "all QKV head planes publish atomically");
  full::FullOwnerSpec final_qkv[2] = {qkv[0], qkv[1]};
  final_qkv[0].ref.epoch = 2;
  final_qkv[1].ref.epoch = 2;
  final_qkv[0].content = Content::QKV_FINAL;
  final_qkv[1].content = Content::QKV_FINAL;
  expect(full::full_begin_qkv_rope_pair(rt, qkv, final_qkv), Status::OK,
         "begin atomic RAW to FINAL RoPE pair");
  expect(full::full_require_owner(rt, qkv[0], 0, 0, 1), Status::E_BUFFER,
         "RAW QKV no longer readable during RoPE lease");
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned batch = 0; batch < 2; ++batch) {
      const unsigned rows = head == 15 && batch == 1 ? 127 : 128;
      for (unsigned row = 0; row < rows; ++row) {
        write_qkv(rt, 1, uint8_t(head), uint8_t(batch), uint16_t(row));
        write_qkv(rt, 2, uint8_t(head), uint8_t(batch), uint16_t(row));
      }
      expect(full::full_cover_qkv_rope(rt, final_qkv, uint8_t(head),
                                       uint8_t(batch), 0, uint16_t(rows)),
             Status::OK, "RoPE FINAL coverage after K/V physical writes");
    }
  expect(full::full_commit_qkv_rope_pair(rt, final_qkv), Status::E_BUFFER,
         "one missing RoPE row blocks both FINAL shards");
  write_qkv(rt, 1, 15, 1, 127);
  write_qkv(rt, 2, 15, 1, 127);
  expect(full::full_cover_qkv_rope(rt, final_qkv, 15, 1, 127, 1),
         Status::OK, "last RoPE K/V row covered after write");
  expect(full::full_commit_qkv_rope_pair(rt, final_qkv), Status::OK,
         "complete RoPE pair commits FINAL atomically");
  LoadTask kv_load{};
  kv_load.ctx = {1, Op::LOAD_KV, 2, 0, 0, RowSpace::BATCH, 0, 1};
  kv_load.kind = 1;
  kv_load.dst = {Buffer::KV, 0, 1};
  kv_load.head = 15;
  kv_load.planes = 3;
  kv_load.byte_count = 2u * 2u * 128u * 64u * 4u;
  TaskDone done;
  expect(full::full_run_task(rt, kv_load, done), Status::OK,
         "typed KV load from published FINAL QKV pair");
  require(done.task_id == 1 && done.drained &&
          done.output_elements == kv_load.byte_count &&
          done.output_unit == OutputUnit::BYTES,
          "KV load TaskDone byte contract");
  for (unsigned plane = 0; plane < 2; ++plane)
    for (unsigned batch = 0; batch < 2; ++batch)
      for (unsigned row = 0; row < 128; ++row)
        for (unsigned d = 0; d < 64; ++d) {
          Address address;
          expect(qkv_address(uint8_t(plane + 1), uint8_t(batch), 15,
                             uint16_t(row), uint8_t(d), 2, 128, address),
                 Status::OK, "KV source physical address");
          uint8_t bytes[4];
          expect(full::full_read(rt.memory, address.bo, address.offset,
                                 bytes, 4), Status::OK,
                 "KV source physical readback");
          require(numeric_f32_bits(rt.cache.kv[plane][batch][row][d]) ==
                      load32(bytes),
                  "typed KV cache exactly equals FINAL QKV physical bytes");
        }
  const auto kv_spec = spec(kv_load.dst, 0, 2, 0, 255,
                            RowSpace::TOKEN, 0, 128, 64, Content::F32);
  expect(full::full_release_owner(rt, kv_spec), Status::OK,
         "release loaded KV owner");
  for (unsigned shard = 0; shard < 2; ++shard) {
    expect(full::full_require_owner(rt, final_qkv[shard], 1, 127, 1),
           Status::OK, "both FINAL QKV shards readable");
    expect(full::full_release_owner(rt, final_qkv[shard]), Status::OK,
           "release FINAL QKV shard");
  }

  for (unsigned bank = 0; bank < 2; ++bank) {
    LoadTask gamma_load{};
    gamma_load.ctx = {uint32_t(2 + bank), Op::LOAD_LN_PARAMS,
                      uint8_t(bank ? 3 : 1), 255, 0,
                      RowSpace::BATCH, 0, 1};
    gamma_load.kind = 2;
    gamma_load.dst = {Buffer::LN_GAMMA, uint8_t(bank), 1};
    gamma_load.byte_count = 4096;
    expect(full::full_run_task(rt, gamma_load, done), Status::OK,
           "typed embedding/final gamma load");
    require(done.task_id == 2 + bank && done.drained &&
            done.output_elements == 4096 &&
            done.output_unit == OutputUnit::BYTES,
            "gamma load TaskDone byte contract");
    const auto tensor = tensor_named(bank ? "final_norm_w" : "emb_norm_w");
    require(tensor.bo == uint8_t(Bo::AUX) && tensor.span == 4096,
            "gamma tensor layout identity");
    for (unsigned i = 0; i < 1024; ++i)
      require(numeric_f32_bits(rt.cache.gamma[bank][i]) ==
                  load32(aux.data() + tensor.base + 4 * i),
              "typed gamma cache exactly equals real AUX bytes");
    const auto gamma_spec = spec(gamma_load.dst, 0,
                                 gamma_load.ctx.stage, 255, 0,
                                 RowSpace::BATCH, 0, 1, 1024, Content::F32);
    expect(full::full_require_owner(rt, gamma_spec, 0, 0, 1), Status::OK,
           "loaded gamma owner published");
    expect(full::full_release_owner(rt, gamma_spec), Status::OK,
           "release gamma owner");
  }
  for (unsigned mode = 0; mode < 2; ++mode) {
    LoadTask rope_load{};
    rope_load.ctx = {uint32_t(4 + mode), Op::LOAD_ROPE, 2,
                     uint8_t(mode), 0, RowSpace::BATCH, 0, 1};
    rope_load.kind = 3;
    rope_load.dst = {Buffer::ROPE_TABLE, uint8_t(mode),
                     uint32_t(mode + 1)};
    rope_load.byte_count = 2u * 1025u * 64u * 4u;
    expect(full::full_run_task(rt, rope_load, done), Status::OK,
           "typed full/slide RoPE load");
    require(done.task_id == 4 + mode && done.drained &&
            done.output_elements == rope_load.byte_count &&
            done.output_unit == OutputUnit::BYTES &&
            rt.loaded_rope_ref == rope_load.dst &&
            rt.loaded_rope_mode == mode,
            "RoPE load TaskDone and current mode");
    const auto cosine = tensor_named(mode ? "cos_slide" : "cos_full");
    const auto sine = tensor_named(mode ? "sin_slide" : "sin_full");
    require(cosine.bo == uint8_t(Bo::AUX) &&
            sine.bo == uint8_t(Bo::AUX) &&
            cosine.span == 262400 && sine.span == 262400,
            "RoPE table layout identity");
    const full::FullTensorDescriptor tables[2] = {cosine, sine};
    for (unsigned table = 0; table < 2; ++table)
      for (unsigned pos = 0; pos < 1025; ++pos)
        for (unsigned j = 0; j < 64; ++j)
          require(numeric_f32_bits(rt.cache.rope_table[table][pos][j]) ==
                      load32(aux.data() + tables[table].base +
                             4 * (pos * 64 + j)),
                  "typed RoPE cache exactly equals real AUX bytes");
    const auto rope_spec = spec(rope_load.dst, 0, 2,
                                uint8_t(mode), 0, RowSpace::BATCH,
                                0, 1, 64, Content::F32);
    expect(full::full_require_owner(rt, rope_spec, 0, 0, 1), Status::OK,
           "loaded RoPE owner published");
    if (mode == 1)
      expect(full::full_release_owner(rt, rope_spec), Status::OK,
             "release current RoPE table");
  }

  const auto att_spec = spec({Buffer::ATT_OUT, 0, 1}, 0, 2, 0, 255,
                             RowSpace::TOKEN, 0, 128, 1024, Content::F32);
  auto att_partial = att_spec;
  att_partial.rows = 1;
  expect(full::full_claim_owner(rt, att_partial), Status::E_BUFFER,
         "partial ATT_OUT scope rejected");
  expect(full::full_claim_owner(rt, att_spec), Status::OK,
         "claim complete ATT_OUT scope");
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned batch = 0; batch < 2; ++batch) {
      const unsigned rows = head == 15 && batch == 1 ? 127 : 128;
      for (unsigned row = 0; row < rows; ++row)
        write_att_head(rt, att_spec, uint8_t(head), uint8_t(batch),
                       uint16_t(row));
      expect(full::full_cover_att_head(rt, att_spec, uint8_t(head),
                                       uint8_t(batch), 0, uint16_t(rows)),
             Status::OK, "ATT_OUT head covered after physical write");
    }
  expect(full::full_publish_att(rt, att_spec), Status::E_BUFFER,
         "one missing ATT_OUT head row blocks publication");
  write_att_head(rt, att_spec, 15, 1, 127);
  expect(full::full_cover_att_head(rt, att_spec, 15, 1, 127, 1), Status::OK,
         "last ATT_OUT row covered after write");
  expect(full::full_publish_att(rt, att_spec), Status::OK,
         "all heads publish ATT_OUT");
  expect(full::full_release_owner(rt, att_spec), Status::OK,
         "release ATT_OUT");

  const auto scorer1 = spec({Buffer::HEAD_WORK, 0, 1},
                            uint8_t(Region::SCORER_ACT), 5, 255, 255,
                            RowSpace::MARKER, 0, 16, 1024, Content::F32);
  auto scorer2 = scorer1;
  scorer2.ref.epoch = 2;
  expect(full::full_claim_owner(rt, scorer1), Status::OK,
         "claim B2 scorer activation");
  for (unsigned batch = 0; batch < 2; ++batch) {
    write_and_cover(rt, scorer1, uint8_t(batch), 0, 16,
                    0x3f000000u + batch * 256u);
  }
  expect(full::full_publish_owner(rt, scorer1), Status::OK,
         "publish both scorer activation batches");
  auto illegal_inplace = scorer2;
  illegal_inplace.content = Content::PROB;
  expect(full::full_begin_inplace_owner(rt, scorer1, illegal_inplace),
         Status::E_BUFFER, "illegal inplace content transition rejected");
  expect(full::full_begin_inplace_owner(rt, scorer1, scorer2), Status::OK,
         "begin B2 scorer activation lease");
  expect(full::full_cover_owner(rt, scorer2, 0, 0, 1), Status::E_BUFFER,
         "inplace writer cannot overwrite unconsumed old row");
  expect(full::full_consume_inplace_rows(rt, scorer2, 0, 0, 16), Status::OK,
         "consume old scorer batch0");
  write_and_cover(rt, scorer2, 0, 0, 16, 0x40000000u);
  expect(full::full_commit_inplace_owner(rt, scorer2), Status::E_BUFFER,
         "B2 lease cannot commit before batch1");
  expect(full::full_consume_inplace_rows(rt, scorer2, 1, 0, 16), Status::OK,
         "consume old scorer batch1");
  write_and_cover(rt, scorer2, 1, 0, 16, 0x40400000u);
  expect(full::full_commit_inplace_owner(rt, scorer2), Status::OK,
         "B2 scorer lease commits after both batches");
  expect(full::full_require_owner(rt, scorer1, 0, 0, 1), Status::E_BUFFER,
         "old scorer epoch no longer readable");
  expect(full::full_release_owner(rt, scorer2), Status::OK,
         "release scorer activation");

  const auto types = spec({Buffer::TYPE_ROWS, 0, 1}, 0, 1, 255, 0,
                          RowSpace::BATCH, 0, 3, 1024, Content::F32);
  expect(full::full_claim_owner(rt, types), Status::OK,
         "claim shared type rows");
  write_and_cover(rt, types, 0, 0, 1, 0x3f800000u);
  expect(full::full_publish_owner(rt, types), Status::OK,
         "publish type0 only");
  write_and_cover(rt, types, 0, 2, 1, 0x40000000u);
  expect(full::full_require_owner(rt, types, 0, 2, 1), Status::E_BUFFER,
         "written type2 remains invisible before its publish");
  expect(full::full_require_owner(rt, types, 0, 0, 1), Status::OK,
         "published type0 stays readable during type2 extension");
  expect(full::full_publish_owner(rt, types), Status::OK,
         "publish type2 extension");
  expect(full::full_require_owner(rt, types, 0, 2, 1), Status::OK,
         "type2 visible after publish");
  expect(full::full_release_owner(rt, types), Status::OK,
         "release type rows");

  const auto run_quant_row = [&](uint32_t task_id, uint32_t epoch,
                                 uint32_t marker) {
    const auto source = spec({Buffer::HIDDEN, 0, epoch}, 0, 2, 0, 0,
                             RowSpace::TOKEN, 0, 1, 1024, Content::F32);
    expect(full::full_claim_owner(rt, source), Status::OK,
           "claim genuine Quant source");
    write_and_cover(rt, source, 0, 0, 1, marker);
    expect(full::full_publish_owner(rt, source), Status::OK,
           "publish physically written Quant source");
    expect(full::full_bind_quant_source(rt, source), Status::OK,
           "bind genuine Quant source");
    QuantTask quant{};
    quant.ctx = {task_id, Op::QUANT, 2, 0, 0, RowSpace::TOKEN, 0, 1};
    quant.src = source.ref;
    quant.a_dst = {Buffer::A8, 0, epoch};
    quant.K = 1024;
    quant.input_lanes = 8;
    TaskDone quant_done;
    expect(full::full_run_task(rt, quant, quant_done), Status::OK,
           "real typed Quant after request boundary");
    require(quant_done.task_id == task_id && quant_done.drained &&
            quant_done.output_unit == OutputUnit::Q8_GROUP &&
            quant_done.output_elements == 32 &&
            rt.cache.activation_meta.valid &&
            rt.cache.activation_meta.state == CacheState::READY &&
            rt.cache.activation_meta.ref == quant.a_dst,
            "fresh A8 owner and P1 numeric metadata READY");
  };

  run_quant_row(6, 1, 0x3f000000u);
  LinearTask failed_linear{};
  failed_linear.ctx = {7, Op::LIN_WO, 2, 0, 0,
                       RowSpace::TOKEN, 0, 1};
  failed_linear.a = {Buffer::A8, 0, 1};
  failed_linear.w = {Buffer::WEIGHT, 0, 1};
  failed_linear.ps = {Buffer::PS, 0, 1};
  failed_linear.dst = {Buffer::TMP, 0, 1};
  failed_linear.weight = {2, 0};
  failed_linear.K = 1024;
  failed_linear.N = 1024;
  TaskDone failed_done;
  expect(full::full_run_task(rt, failed_linear, failed_done), Status::E_MODEL,
         "accepted Linear fails without loaded model weight");
  require(failed_done.task_id == 7 && failed_done.drained &&
          rt.last_task_id == 7 && rt.tasks_retired == 7 &&
          rt.cache.activation_meta.valid,
          "failed task retires while prior A8 remains READY");
  full::FullOwnerRecord before_reset;
  expect(full::full_owner_snapshot(rt, {Buffer::A8, 0, 1}, 0,
                                   before_reset), Status::OK,
         "A8 pre-reset owner snapshot");
  require(before_reset.max_claimed_epoch == 1 && before_reset.valid,
          "pre-reset A8 epoch recorded");
  const uint64_t generation = rt.inputs.identity.generation;
  expect(full::full_soft_reset(rt, generation + 1), Status::OK,
         "soft reset after accepted failure with A8 READY");
  require(!rt.cache.activation_meta.valid &&
          rt.cache.activation_meta.state == CacheState::INVALID &&
          !rt.cache.activation_source_ledger.valid &&
          !rt.expected_quant_source_valid &&
          rt.last_task_id == 0 && rt.tasks_retired == 0,
          "soft reset invalidates P1 A8/source ledgers and task counters");
  expect(full::full_claim_owner(rt, wi), Status::E_PROTOCOL,
         "soft reset closes request gate");
  require(rt.inputs.identity.request_id == 99,
          "pre-reset accepted request ID is 99");
  store64(io.data() + 32, generation + 1);
  store64(io.data() + 24, 1);
  expect(full::full_parse_request(rt), Status::OK,
         "new generation request ID one reopens gate");
  auto wi_stale = wi;
  wi_stale.ref.epoch = 1;
  expect(full::full_claim_owner(rt, wi_stale), Status::E_BUFFER,
         "soft reset preserves WI/DEC_FF shared epoch history");
  auto wi3 = wi;
  wi3.ref.epoch = 3;
  expect(full::full_claim_owner(rt, wi3), Status::OK,
         "next physical epoch can claim after soft reset");
  write_and_cover(rt, wi3, 0, 0, 1, 0x40800000u);
  expect(full::full_publish_owner(rt, wi3), Status::OK,
         "post-reset real write publishes");
  Address wi3_address;
  expect(full::full_f32_address(rt, wi3.ref, 0, 0, 0, 0, wi3_address),
         Status::OK, "post-reset WI physical byte address");
  std::array<uint8_t, 4> wi3_before{}, wi3_after{};
  expect(full::full_read(rt.memory, wi3_address.bo, wi3_address.offset,
                         wi3_before.data(), wi3_before.size()), Status::OK,
         "post-reset WI physical bytes before read lease");
  expect(full::full_acquire_owner(rt, wi3, 0, 0, 1), Status::OK,
         "real published WI enters READ lease");
  expect(full::full_invalidate_owner(rt, wi3.ref, 0), Status::E_BUFFER,
         "invalidate cannot clear active READ lease");
  full::FullOwnerRecord protected_read;
  expect(full::full_owner_snapshot(rt, wi3.ref, 0, protected_read),
         Status::OK, "protected WI READ owner snapshot");
  expect(full::full_read(rt.memory, wi3_address.bo, wi3_address.offset,
                         wi3_after.data(), wi3_after.size()), Status::OK,
         "post-reset WI physical bytes after blocked invalidate");
  require(protected_read.state == CacheState::READ &&
          protected_read.readers == 1 && protected_read.valid &&
          protected_read.max_claimed_epoch == 3 &&
          wi3_before == wi3_after,
          "blocked invalidate preserves READ lease, epoch and bytes");
  expect(full::full_release_read_owner(rt, wi3), Status::OK,
         "release protected WI read lease");
  expect(full::full_invalidate_owner(rt, wi3.ref, 0), Status::OK,
         "invalidate succeeds after read lease release");
  expect(full::full_owner_snapshot(rt, wi3.ref, 0, protected_read),
         Status::OK, "invalidated WI owner retains history");
  require(protected_read.state == CacheState::INVALID &&
          !protected_read.valid && protected_read.readers == 0 &&
          protected_read.max_claimed_epoch == 3,
          "post-lease invalidate retains epoch watermark");

  run_quant_row(1, 2, 0x3f800000u);
  full::FullOwnerRecord after_reset;
  expect(full::full_owner_snapshot(rt, {Buffer::A8, 0, 2}, 0,
                                   after_reset), Status::OK,
         "A8 post-reset owner snapshot");
  require(after_reset.max_claimed_epoch == 2 && after_reset.valid,
          "post-reset Quant advances A8 epoch without stale meta");
  const uint64_t next_request_id = rt.inputs.identity.request_id + 1;
  store64(io.data() + 24, next_request_id);
  expect(full::full_parse_request(rt), Status::OK,
         "same-generation next request accepted after Quant");
  require(rt.inputs.identity.request_id == next_request_id &&
          rt.inputs.identity.generation == generation + 1 &&
          !rt.cache.activation_meta.valid &&
          rt.cache.activation_meta.state == CacheState::INVALID &&
          !rt.cache.activation_source_ledger.valid &&
          rt.last_task_id == 0 && rt.tasks_retired == 0,
          "same-generation next request invalidates A8 and task state");
  full::FullOwnerRecord next_request_owner;
  expect(full::full_owner_snapshot(rt, {Buffer::A8, 0, 2}, 0,
                                   next_request_owner), Status::OK,
         "same-generation A8 retained epoch snapshot");
  require(next_request_owner.max_claimed_epoch == 2 &&
          !next_request_owner.valid &&
          next_request_owner.state == CacheState::INVALID,
          "same-generation request preserves claimed epoch only");
  run_quant_row(1, 3, 0x40000000u);
  require(rt.cache.activation_meta.ref.epoch == 3,
          "same-generation next request claims fresh P1 A8 epoch");

  // A real Quant made both owners READY at E3. Releasing the public full
  // owner alone leaves the numeric A8 ledger READY, so a new Quant cannot
  // claim E4. A separately reserved and abandoned full owner may still
  // advance the public watermark; recycle must reconcile both histories.
  const auto a8_e3 = spec({Buffer::A8, 0, 3}, 0, 2, 0, 0,
                          RowSpace::TOKEN, 0, 1, 1024, Content::Q8_TILE);
  const auto source_e3 = spec({Buffer::HIDDEN, 0, 3}, 0, 2, 0, 0,
                              RowSpace::TOKEN, 0, 1, 1024, Content::F32);
  expect(full::full_release_owner(rt, a8_e3), Status::OK,
         "release real E3 full A8 owner while numeric ledger remains READY");
  require(rt.cache.activation_meta.valid &&
          rt.cache.activation_meta.state == CacheState::READY &&
          rt.cache.activation_meta.ref == a8_e3.ref,
          "real Quant E3 numeric owner remains READY");
  expect(full::full_release_owner(rt, source_e3), Status::OK,
         "release real E3 Quant source");
  const auto source_e4 = spec({Buffer::HIDDEN, 0, 4}, 0, 2, 0, 0,
                              RowSpace::TOKEN, 0, 1, 1024, Content::F32);
  expect(full::full_claim_owner(rt, source_e4), Status::OK,
         "claim fresh physical source for blocked E4 Quant");
  write_and_cover(rt, source_e4, 0, 0, 1, 0x40400000u);
  expect(full::full_publish_owner(rt, source_e4), Status::OK,
         "publish fresh E4 Quant source");
  expect(full::full_bind_quant_source(rt, source_e4), Status::OK,
         "bind fresh E4 Quant source");
  QuantTask blocked_quant{};
  blocked_quant.ctx = {2, Op::QUANT, 2, 0, 0,
                       RowSpace::TOKEN, 0, 1};
  blocked_quant.src = source_e4.ref;
  blocked_quant.a_dst = {Buffer::A8, 0, 4};
  blocked_quant.K = 1024;
  blocked_quant.input_lanes = 8;
  TaskDone blocked_done;
  expect(full::full_run_task(rt, blocked_quant, blocked_done),
         Status::E_BUFFER,
         "real E4 Quant rejects still-READY numeric A8 before full claim");
  require(blocked_done.task_id == 2 && blocked_done.drained &&
          rt.cache.activation_meta.ref == a8_e3.ref &&
          rt.cache.activation_meta.state == CacheState::READY,
          "rejected E4 Quant preserves numeric E3 history");
  full::FullOwnerRecord before_abandon;
  expect(full::full_owner_snapshot(rt, a8_e3.ref, 0, before_abandon),
         Status::OK, "snapshot public A8 after blocked Quant");
  require(before_abandon.max_claimed_epoch == 3 &&
          before_abandon.state == CacheState::FREE,
          "blocked Quant did not advance public A8 watermark");
  const auto a8_e4 = spec({Buffer::A8, 0, 4}, 0, 2, 0, 0,
                          RowSpace::TOKEN, 0, 1, 1024, Content::Q8_TILE);
  expect(full::full_claim_owner(rt, a8_e4), Status::OK,
         "public A8 E4 reservation advances only full-owner watermark");
  full::FullOwnerRecord reserved;
  expect(full::full_owner_snapshot(rt, a8_e4.ref, 0, reserved), Status::OK,
         "snapshot reserved A8 E4 owner");
  require(reserved.max_claimed_epoch == 4 &&
          reserved.state == CacheState::FILL &&
          rt.cache.activation_meta.ref.epoch == 3,
          "public and numeric A8 watermarks genuinely diverge");
  expect(full::full_invalidate_owner(rt, a8_e4.ref, 0), Status::OK,
         "abandon unfilled public A8 E4 reservation");
  expect(full::full_recycle_request(rt), Status::OK,
         "recycle reconciles public E4 and numeric E3 histories");
  full::FullOwnerRecord reconciled;
  expect(full::full_owner_snapshot(rt, a8_e4.ref, 0, reconciled),
         Status::OK, "snapshot reconciled A8 owner");
  require(reconciled.max_claimed_epoch == 4 &&
          reconciled.ref.epoch == 4 &&
          rt.cache.activation_meta.ref.epoch == 4 &&
          rt.cache.activation_meta.state == CacheState::INVALID &&
          !rt.cache.activation_meta.valid,
          "recycle retains maximum A8 epoch in both owner systems");
  store64(io.data() + 24, next_request_id + 1);
  expect(full::full_parse_request(rt), Status::OK,
         "next same-generation request after divergent A8 recycle");
  run_quant_row(1, 5, 0x40800000u);
  require(rt.cache.activation_meta.ref.epoch == 5,
          "real E5 Quant succeeds after max-watermark reconciliation");
  expect(full::full_parse_request(rt), Status::E_PROTOCOL,
         "duplicate same-generation ID rejected after Quant");
  store64(io.data() + 24, 1);
  expect(full::full_parse_request(rt), Status::E_PROTOCOL,
         "lower same-generation ID rejected after Quant");

  std::cout << "FULL_OWNER_PASS checks=" << checks << '\n';
  return 0;
}
