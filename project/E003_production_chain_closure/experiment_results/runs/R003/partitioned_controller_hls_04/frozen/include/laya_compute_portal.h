#pragma once

#include "laya_numeric_tasks.h"
#include <array>

namespace laya::portal {

// Private controller/service wire format. Byte positions are little endian;
// no C++ object representation or pointer value is serialized.
constexpr unsigned kCommandBytes = 1024, kResponseBytes = 512;
constexpr unsigned kCommandBeats = 16, kResponseBeats = 8;
constexpr uint32_t kCommandMagic = 0x3150434c, kResponseMagic = 0x3152434c;
constexpr uint16_t kVersion = 2;
enum class Service : uint16_t { LOAD_W = 1, QUANT = 2, MATRIX = 3, GEGLU = 4 };
enum Offset : unsigned {
  MAGIC = 0, VERSION = 4, OP_STATUS = 6, GENERATION = 8, TASK = 16,
  FLAGS_DETAIL = 20, COMMAND_BEATS = 24, RESPONSE_BEATS = 26,
  IDENTITY = 64, CONTEXT = 148, SOURCE_REF = 160, A_REF = 168,
  W_REF = 176, PS_REF = 184, DST_REF = 192, MODEL_IDENTITY = 200,
  K = 616, N = 618, ROWS = 620, ROW_BLOCK = 621, A_SLOT = 622,
  W_SLOT = 623, A_EPOCH = 624, W_EPOCH = 628, WEIGHT_KEY = 632,
  BIAS_KIND = 634, OUT0_ROLE = 635, OUT1_ROLE = 636, SOURCE_ROLE = 637,
  OUTPUT_RANGES = 640, ROW_STRIDE = 688, BATCH_STRIDE = 696,
  WEIGHT_RANGES = 704, EXPECTED_AUX_HEADER = 752, AUX_OFFSET = 880,
  BIAS_OFFSET = 888, BIAS_BYTES = 896, SOURCE_OFFSET = 904,
  SOURCE_SPAN = 912, SOURCE_STRIDE = 920,
  PRODUCER_CONTEXT = 928, QUANT_CONTEXT = 940, LINEAR_CONTEXT = 952,
  FUTURE_DST_REF = 964, COMMAND_USED = 972,
  RANK = 24, BAD_ELEMENT = 32, ELEMENTS = 40, UNIT = 44,
  RETIRE_FLAGS = 45, CYCLES = 48, COUNTERS = 64,
  RESPONSE_IDENTITY = 128, RESPONSE_CONTEXT = 212,
  RESPONSE_REFS = 224, RESPONSE_A_EPOCH = 264,
  RESPONSE_W_EPOCH = 268, RESPONSE_PRODUCER_CONTEXT = 272,
  RESPONSE_QUANT_CONTEXT = 284, RESPONSE_LINEAR_CONTEXT = 296,
  RESPONSE_FUTURE_DST_REF = 308, RESPONSE_ROWS = 316,
  RESPONSE_ROW_BLOCK = 317, RESPONSE_SERVICE = 318, RESPONSE_USED = 320
};
using CommandPacket = std::array<uint8_t, kCommandBytes>;
using ResponsePacket = std::array<uint8_t, kResponseBytes>;
struct Range { uint64_t offset = 0, span = 0; };
struct OutputRange { uint64_t bo_span = 0, offset = 0, span = 0; };
// Explicit all-zero wire Context for unused extension fields. TaskContext{}
// has nonzero defaults and must never stand in for an unused wire field.
constexpr TaskContext zero_context() { return {0, Op(0), 0, 0, 0, RowSpace(0), 0, 0}; }
struct Command {
  Service service = Service::MATRIX;
  uint64_t generation = 0;
  NumericIdentity identity;
  TaskContext context;
  TaskContext producer_context = zero_context(), quant_context = zero_context(), linear_context = zero_context();
  BufferRef source, a, w, ps, dst, future_dst;
  uint8_t future_dst_region = 0;
  uint8_t source_region = 0, dst_region = 0;
  std::array<uint8_t, 416> model_identity{};
  uint16_t K = 0, N = 0, weight_key = 0;
  uint8_t rows = 0, row_block = 0, a_slot = 0, w_slot = 0, bias_kind = 0;
  uint32_t a_epoch = 0, w_epoch = 0;
  Bo output_role[2] = {Bo(0), Bo(0)};
  Bo source_role = Bo(0);
  OutputRange output[2];
  uint64_t row_stride = 0, batch_stride = 0;
  Range weight[3];
  std::array<uint8_t, 128> expected_aux_header{};
  uint64_t aux_offset = 0, bias_offset = 0;
  uint32_t bias_bytes = 0;
  Range source_range;
  uint64_t source_stride = 0;
};
struct Response {
  Status status = Status::E_INTERNAL;
  Service service = Service::MATRIX;
  uint8_t rows = 0, row_block = 0;
  uint64_t generation = 0;
  uint32_t task_id = 0, error_detail = 0;
  uint64_t first_error_rank = UINT64_MAX, bad_element = UINT64_MAX;
  uint32_t output_elements = 0;
  OutputUnit unit = OutputUnit::NONE;
  bool drained = false, published = false;
  uint64_t cycles = 0;
  std::array<uint32_t, 14> counters{};
  NumericIdentity identity;
  TaskContext context;
  TaskContext producer_context = zero_context(), quant_context = zero_context(), linear_context = zero_context();
  BufferRef source, a, w, ps, dst, future_dst;
  uint8_t future_dst_region = 0;
  uint8_t source_region = 0, dst_region = 0;
  uint32_t a_epoch = 0, w_epoch = 0;
};

inline void put(uint8_t* p, unsigned off, uint64_t x, unsigned bytes) {
  for (unsigned i = 0; i < bytes; ++i) p[off + i] = uint8_t(x >> (8 * i));
}
inline uint64_t get(const uint8_t* p, unsigned off, unsigned bytes) {
  uint64_t value = 0;
  for (unsigned i = 0; i < bytes; ++i) value |= uint64_t(p[off + i]) << (8 * i);
  return value;
}
inline void put_identity(uint8_t* p, unsigned off, const NumericIdentity& id) {
  put(p, off, id.request_id, 8); put(p, off + 8, id.generation, 8);
  put(p, off + 16, id.B, 2); put(p, off + 18, id.S, 2);
  for (unsigned i = 0; i < 16; ++i) {
    p[off + 20 + i] = id.model_tag[i]; p[off + 36 + i] = id.numeric_tag[i];
    p[off + 52 + i] = id.layout_tag[i]; p[off + 68 + i] = id.build_tag[i];
  }
}
inline NumericIdentity get_identity(const uint8_t* p, unsigned off) {
  NumericIdentity id;
  id.request_id = get(p, off, 8); id.generation = get(p, off + 8, 8);
  id.B = uint16_t(get(p, off + 16, 2)); id.S = uint16_t(get(p, off + 18, 2));
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = p[off + 20 + i]; id.numeric_tag[i] = p[off + 36 + i];
    id.layout_tag[i] = p[off + 52 + i]; id.build_tag[i] = p[off + 68 + i];
  }
  return id;
}
inline void put_context(uint8_t* p, unsigned off, const TaskContext& c) {
  put(p, off, c.task_id, 4); p[off + 4] = uint8_t(c.op);
  p[off + 5] = c.stage; p[off + 6] = c.layer; p[off + 7] = c.batch;
  p[off + 8] = uint8_t(c.row_space); put(p, off + 9, c.row0, 2);
  p[off + 11] = c.rows;
}
inline TaskContext get_context(const uint8_t* p, unsigned off) {
  TaskContext c;
  c.task_id = uint32_t(get(p, off, 4)); c.op = Op(p[off + 4]);
  c.stage = p[off + 5]; c.layer = p[off + 6]; c.batch = p[off + 7];
  c.row_space = RowSpace(p[off + 8]); c.row0 = uint16_t(get(p, off + 9, 2));
  c.rows = p[off + 11]; return c;
}
inline void put_ref(uint8_t* p, unsigned off, BufferRef r, uint8_t region = 0) {
  put(p, off, r.epoch, 4); p[off + 4] = uint8_t(r.id);
  p[off + 5] = r.bank; p[off + 6] = region; p[off + 7] = 0;
}
inline BufferRef get_ref(const uint8_t* p, unsigned off) {
  return {Buffer(p[off + 4]), p[off + 5], uint32_t(get(p, off, 4))};
}

CommandPacket encode(const Command&);
Check decode(const CommandPacket&, Command&);
ResponsePacket encode(const Response&);
Check decode(const ResponsePacket&, const Command& expected, Response&);

} // namespace laya::portal
