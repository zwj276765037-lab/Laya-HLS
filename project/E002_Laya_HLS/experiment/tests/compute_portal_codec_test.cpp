#include "laya_compute_portal.h"
#include "laya_model_layout_generated.h"
#include <cassert>
#include <fstream>
#include <iostream>
#include <initializer_list>

using namespace laya;
using namespace laya::portal;

static std::array<uint8_t, 416> canonical_model_identity() {
  std::array<uint8_t, 416> value{};
  const uint8_t* tags[4] = {full::kFullModelTag, full::kFullNumericTag,
      full::kFullLayoutTag, full::kFullBuildTag};
  for (unsigned tag = 0; tag < 4; ++tag)
    for (unsigned byte = 0; byte < 16; ++byte)
      value[16 * tag + byte] = tags[tag][byte];
  put(value.data(), 64, 0x4d33314cu, 4);
  put(value.data(), 68, 1, 2); put(value.data(), 70, 416, 2);
  put(value.data(), 72, 0, 4); put(value.data(), 76, 1, 4);
  for (unsigned byte = 0; byte < 32; ++byte)
    value[80 + byte] = full::kFullSourceSha256[byte];
  put(value.data(), 112, 5, 4); put(value.data(), 116, 16, 4);
  put(value.data(), 120, 128, 4);
  constexpr uint32_t roles[5] = {0, 2, 3, 4, 5};
  for (unsigned index = 0; index < 5; ++index) {
    const unsigned entry = 128 + 16 * index;
    put(value.data(), entry, roles[index], 4);
    put(value.data(), entry + 4, 1, 4);
    put(value.data(), entry + 8, full::kFullModelBoSizes[index], 8);
  }
  return value;
}

static std::array<uint8_t, 128> canonical_aux_header() {
  std::array<uint8_t, 128> value{};
  value[0] = 'L'; value[1] = 'Y'; value[2] = 'M'; value[3] = 'P';
  put(value.data(), 4, 1, 2); put(value.data(), 6, 0, 2);
  put(value.data(), 8, 128, 4); put(value.data(), 12, 13, 4);
  put(value.data(), 16, 1, 4);
  const uint8_t* tags[4] = {full::kFullModelTag, full::kFullNumericTag,
      full::kFullLayoutTag, full::kFullBuildTag};
  for (unsigned tag = 0; tag < 4; ++tag)
    for (unsigned byte = 0; byte < 16; ++byte)
      value[32 + 16 * tag + byte] = tags[tag][byte];
  for (unsigned byte = 0; byte < 32; ++byte)
    value[96 + byte] = full::kFullSourceSha256[byte];
  return value;
}

static Command fixture(Service service) {
  Command c;
  c.service = service; c.generation = 0x8877665544332211ULL;
  c.identity.request_id = 0x0123456789abcdefULL;
  c.identity.generation = 0x1020304050607080ULL;
  c.identity.B = 2; c.identity.S = 128;
  for (unsigned i = 0; i < 16; ++i) {
    c.identity.model_tag[i] = full::kFullModelTag[i];
    c.identity.numeric_tag[i] = full::kFullNumericTag[i];
    c.identity.layout_tag[i] = full::kFullLayoutTag[i];
    c.identity.build_tag[i] = full::kFullBuildTag[i];
  }
  c.producer_context = {0x12345670, Op::GEGLU, 2, 27, 1, RowSpace::TOKEN, 7, 16};
  c.quant_context = {0x12345671, Op::QUANT, 2, 27, 1, RowSpace::TOKEN, 7, 16};
  c.linear_context = {0x12345678, Op::LIN_DOWN, 2, 27, 1, RowSpace::TOKEN, 7, 16};
  c.source = {Buffer::GATE, 0, 9}; c.a = {Buffer::A8, 0, 10};
  c.w = {Buffer::WEIGHT, 1, 11}; c.ps = {Buffer::PS, 0, 12};
  c.future_dst = {Buffer::HEAD_WORK, 0, 13}; c.future_dst_region = 3;
  c.model_identity = canonical_model_identity();
  c.K = 2624; c.N = 1024; c.w_slot = 1;
  c.a_epoch = 10; c.w_epoch = 11; c.weight_key = 0x1b04; c.bias_kind = 1;
  c.output[0] = {0x1234567800000000ULL, 0x1122334455667700ULL, 0x1020304050607000ULL};
  if (service == Service::LOAD_W) {
    c.context = {0x12345678, Op::LOAD_W, 2, 27, 0, RowSpace::BATCH, 0, 1};
    c.producer_context = c.quant_context = c.linear_context = zero_context();
    c.source = c.a = c.ps = c.future_dst = none(); c.future_dst_region = 0; c.a_epoch = 0;
    c.output[0] = {};
    for (unsigned i = 0; i < 3; ++i) c.weight[i] = {0x12340000 + 0x10000*i, 0x80000 + 0x40000*i};
    c.expected_aux_header = canonical_aux_header();
    c.aux_offset = 0x100; c.bias_offset = 0x200; c.bias_bytes = 4096;
  } else if (service == Service::MATRIX) {
    c.context = c.linear_context; c.dst = c.future_dst; c.dst_region = c.future_dst_region;
    c.rows = 4; c.row_block = 8; c.output_role[0] = Bo::STATE1;
    c.row_stride = 4096; c.batch_stride = 4194304;
  } else if (service == Service::QUANT) {
    c.context = c.quant_context; c.dst = c.a; c.rows = 16; c.output[0] = {};
    c.source_role = Bo::FF1; c.source_range = {0x9000, 0x10000};
    c.row_stride = c.source_stride = 10496; c.batch_stride = 10747904;
  } else {
    c.context = c.producer_context; c.source = {Buffer::WI, 0, 8}; c.dst = {Buffer::GATE, 0, 9};
    c.rows = 16; c.source_role = Bo::FF0; c.output_role[0] = Bo::FF1;
    c.source_range = {0x9000, 0x20000}; c.source_stride = 20992;
    c.row_stride = 10496; c.batch_stride = 10747904;
  }
  return c;
}
static Response response(const Command& c) {
  Response r;
  r.status = Status::OK; r.service = c.service; r.rows = c.rows; r.row_block = c.row_block;
  r.generation = c.generation; r.task_id = c.context.task_id;
  r.output_elements = c.service == Service::MATRIX ? 4096 : c.service == Service::QUANT ? 1312 :
    c.service == Service::GEGLU ? 41984 : 2854912;
  r.unit = c.service == Service::LOAD_W ? OutputUnit::BYTES :
    c.service == Service::QUANT ? OutputUnit::Q8_GROUP : OutputUnit::F32;
  r.drained = r.published = true; r.cycles = 0x0a0b0c0d0e0f1011ULL;
  for (unsigned i = 0; i < r.counters.size(); ++i) r.counters[i] = 0x10203040u + i;
  r.identity = c.identity; r.context = c.context; r.source = c.source; r.a = c.a;
  r.w = c.w; r.ps = c.ps; r.dst = c.dst; r.source_region = c.source_region; r.dst_region = c.dst_region;
  r.a_epoch = c.a_epoch; r.w_epoch = c.w_epoch;
  r.producer_context = c.producer_context; r.quant_context = c.quant_context; r.linear_context = c.linear_context;
  r.future_dst = c.future_dst; r.future_dst_region = c.future_dst_region;
  return r;
}
static void save(const std::string& path, const uint8_t* bytes, unsigned size) {
  std::ofstream(path, std::ios::binary).write(reinterpret_cast<const char*>(bytes), size);
}
int main(int argc, char** argv) {
  assert(argc == 2);
  unsigned mutations = 0;
  for (Service service : {Service::LOAD_W, Service::QUANT, Service::MATRIX, Service::GEGLU}) {
    Command c = fixture(service), decoded;
    auto packet = encode(c);
    assert(decode(packet, decoded)); assert(encode(decoded) == packet);
    auto reject = [&](unsigned off) {auto p = packet; p[off] ^= 1; assert(!decode(p, decoded)); ++mutations;};
    for (unsigned off : std::initializer_list<unsigned>{20u, 28u, 63u, 638u, 900u, 972u, 1023u, 175u, 971u, 16u}) reject(off);
    auto invalid = packet; invalid[VERSION] = 1; assert(!decode(invalid, decoded));
    invalid = packet; invalid[A_SLOT] = 2; assert(!decode(invalid, decoded));
    if (service == Service::LOAD_W) {
      for (unsigned off = PRODUCER_CONTEXT; off < COMMAND_USED; ++off) reject(off);
      for (unsigned off : std::initializer_list<unsigned>{SOURCE_REF, A_REF, PS_REF, DST_REF, ROWS, ROW_BLOCK, A_SLOT,
            A_EPOCH, OUT0_ROLE, OUT1_ROLE, SOURCE_ROLE, OUTPUT_RANGES, ROW_STRIDE,
            BATCH_STRIDE, SOURCE_OFFSET, SOURCE_SPAN, SOURCE_STRIDE}) reject(off);
      invalid = packet; put_context(invalid.data(), PRODUCER_CONTEXT, TaskContext{});
      assert(!decode(invalid, decoded)); // Nonzero C++ defaults cannot stand in for a zero extension.
    } else {
      for (unsigned off : std::initializer_list<unsigned>{WEIGHT_RANGES, EXPECTED_AUX_HEADER, AUX_OFFSET, BIAS_OFFSET, BIAS_BYTES}) reject(off);
      // Every component of the repeated Q/L/current Context is checked.
      unsigned repeated = service == Service::MATRIX ? LINEAR_CONTEXT :
          service == Service::QUANT ? QUANT_CONTEXT : PRODUCER_CONTEXT;
      for (unsigned off = repeated; off < repeated + 12; ++off) reject(off);
      invalid = packet; invalid[FUTURE_DST_REF + 6] = 8; assert(!decode(invalid, decoded));
      if (service == Service::MATRIX) {
        for (unsigned off : std::initializer_list<unsigned>{SOURCE_ROLE, SOURCE_OFFSET, SOURCE_SPAN, SOURCE_STRIDE, OUT1_ROLE,
              OUTPUT_RANGES + 24}) reject(off);
        invalid = packet; invalid[ROWS] = 4; invalid[ROW_BLOCK] = 14; assert(!decode(invalid, decoded));
      } else if (service == Service::QUANT) {
        for (unsigned off : std::initializer_list<unsigned>{OUTPUT_RANGES, OUT0_ROLE, OUT1_ROLE, ROW_STRIDE, BATCH_STRIDE,
              SOURCE_STRIDE, DST_REF, ROW_BLOCK}) reject(off);
      } else {
        for (unsigned off : std::initializer_list<unsigned>{K, N, SOURCE_REF + 4, DST_REF + 4, SOURCE_ROLE, OUT0_ROLE,
              SOURCE_STRIDE, ROW_STRIDE, BATCH_STRIDE, OUT1_ROLE, OUTPUT_RANGES + 24, ROW_BLOCK}) reject(off);
      }
    }
    Response r = response(c), result;
    auto reply = encode(r);
    assert(decode(reply, c, result)); assert(encode(result) == reply);
    for (unsigned off : std::initializer_list<unsigned>{46u, 56u, 120u, 320u, 511u, 231u, 8u, 211u, 45u}) {
      auto p = reply; p[off] ^= 1; assert(!decode(p, c, result)); ++mutations;
    }
    for (unsigned off = RESPONSE_PRODUCER_CONTEXT; off < RESPONSE_USED; ++off) {
      auto p = reply; p[off] ^= 1; assert(!decode(p, c, result)); ++mutations;
    }
    auto bad = reply; bad[VERSION] = 1; assert(!decode(bad, c, result));
    r.status = Status::E_NUMERICAL; r.output_elements = 0; r.unit = OutputUnit::NONE;
    r.published = false; r.error_detail = 0x0700000f; r.bad_element = 17;
    auto error = encode(r); auto check = decode(error, c, result);
    assert(check.code == Status::E_NUMERICAL && check.detail == r.error_detail && check.bad_element == 17);
    assert(result.drained && result.generation == c.generation);
    r.published = true; assert(decode(encode(r), c, result).code == Status::E_PROTOCOL);
    const std::string prefix = std::string(argv[1]) + "/" + std::to_string(uint16_t(service));
    save(prefix + "_command.bin", packet.data(), packet.size()); save(prefix + "_response.bin", reply.data(), reply.size());
    if (service == Service::MATRIX) {
      save(std::string(argv[1]) + "/command.bin", packet.data(), packet.size());
      save(std::string(argv[1]) + "/response.bin", reply.data(), reply.size());
    }
  }
  std::cout << "FULL_CURRENT_PORTAL_CODEC_PASS version=2 services=4 mutations=" << mutations << " command_bytes=1024 response_bytes=512\n";
}
