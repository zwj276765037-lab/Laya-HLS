#include "laya_compute_portal.h"

namespace laya::portal {
namespace {
Check wire_error(unsigned byte) { return {Status::E_ABI, detail(4, 0, 20), byte}; }
bool zeros(const uint8_t* p, unsigned first, unsigned end) {
  for (unsigned i = first; i < end; ++i) if (p[i]) return false;
  return true;
}
bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
    a.layer == b.layer && a.batch == b.batch && a.row_space == b.row_space &&
    a.row0 == b.row0 && a.rows == b.rows;
}
bool same_window(const TaskContext& a, const TaskContext& b) {
  return a.stage == b.stage && a.layer == b.layer && a.batch == b.batch &&
    a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}
bool linear_op(Op op) { return uint8_t(op) >= 0x30 && uint8_t(op) <= 0x37; }
bool fields_ok(const Command& c) {
  if (!c.identity.request_id || !c.identity.generation ||
      !check_context(c.context, c.identity.B, c.identity.S)) return false;
  if (!check_ref(c.source, c.source_region) || !check_ref(c.a) || !check_ref(c.w) ||
      !check_ref(c.ps) || !check_ref(c.dst, c.dst_region) ||
      !check_ref(c.future_dst, c.future_dst_region)) return false;
  if (c.w.id != Buffer::WEIGHT || c.w.bank != c.w_slot || c.w.epoch != c.w_epoch) return false;
  if (c.service == Service::LOAD_W) return c.context.op == Op::LOAD_W;
  if (c.a.id != Buffer::A8 || c.a.bank != c.a_slot || c.a.epoch != c.a_epoch ||
      c.ps.id != Buffer::PS || c.source.id == Buffer::NONE || c.future_dst.id == Buffer::NONE ||
      !check_context(c.producer_context, c.identity.B, c.identity.S) ||
      !check_context(c.quant_context, c.identity.B, c.identity.S) ||
      !check_context(c.linear_context, c.identity.B, c.identity.S) ||
      c.quant_context.op != Op::QUANT || !linear_op(c.linear_context.op) ||
      !same_window(c.quant_context, c.linear_context) ||
      c.producer_context.task_id >= c.quant_context.task_id ||
      c.quant_context.task_id >= c.linear_context.task_id) return false;
  if (c.source.id == Buffer::GATE && (c.producer_context.op != Op::GEGLU ||
      !same_window(c.producer_context, c.quant_context))) return false;
  if (c.service == Service::MATRIX) {
    return same_context(c.context, c.linear_context) && c.dst == c.future_dst &&
      c.dst_region == c.future_dst_region && (c.rows == 1 || c.rows == 4) &&
      unsigned(c.row_block) + c.rows <= c.linear_context.rows;
  }
  if (c.row_block || c.rows != c.context.rows) return false;
  if (c.service == Service::QUANT) {
    return same_context(c.context, c.quant_context) && c.dst == c.a && !c.dst_region &&
      c.source_stride == uint64_t(c.K)*4 && c.row_stride == c.source_stride &&
      c.batch_stride == c.source_stride * (c.context.row_space == RowSpace::TOKEN ? 1024 :
          c.context.row_space == RowSpace::MARKER ? 16 : 1) && c.source_role >= Bo::STATE0;
  }
  return c.service == Service::GEGLU && same_context(c.context, c.producer_context) &&
    c.context.op == Op::GEGLU && c.linear_context.op == Op::LIN_DOWN &&
    same_window(c.producer_context, c.quant_context) && c.context.row_space == RowSpace::TOKEN &&
    c.K == 2624 && c.N == 1024 && c.source.id == Buffer::WI && c.dst.id == Buffer::GATE &&
    c.source_role == Bo::FF0 && c.output_role[0] == Bo::FF1 &&
    c.source_stride == uint64_t(c.K)*8 && c.row_stride == uint64_t(c.K)*4 &&
    c.batch_stride == c.row_stride*1024;
}
}
CommandPacket encode(const Command& c) {
  CommandPacket p{};
  put(p.data(), MAGIC, kCommandMagic, 4); put(p.data(), VERSION, kVersion, 2);
  put(p.data(), OP_STATUS, uint16_t(c.service), 2);
  put(p.data(), GENERATION, c.generation, 8); put(p.data(), TASK, c.context.task_id, 4);
  put(p.data(), COMMAND_BEATS, kCommandBeats, 2); put(p.data(), RESPONSE_BEATS, kResponseBeats, 2);
  put_identity(p.data(), IDENTITY, c.identity); put_context(p.data(), CONTEXT, c.context);
  put_ref(p.data(), SOURCE_REF, c.source, c.source_region); put_ref(p.data(), A_REF, c.a);
  put_ref(p.data(), W_REF, c.w); put_ref(p.data(), PS_REF, c.ps);
  put_ref(p.data(), DST_REF, c.dst, c.dst_region);
  for (unsigned i = 0; i < c.model_identity.size(); ++i) p[MODEL_IDENTITY + i] = c.model_identity[i];
  put(p.data(), K, c.K, 2); put(p.data(), N, c.N, 2);
  p[ROWS] = c.rows; p[ROW_BLOCK] = c.row_block; p[A_SLOT] = c.a_slot; p[W_SLOT] = c.w_slot;
  put(p.data(), A_EPOCH, c.a_epoch, 4); put(p.data(), W_EPOCH, c.w_epoch, 4);
  put(p.data(), WEIGHT_KEY, c.weight_key, 2); p[BIAS_KIND] = c.bias_kind;
  p[OUT0_ROLE] = uint8_t(c.output_role[0]); p[OUT1_ROLE] = uint8_t(c.output_role[1]);
  p[SOURCE_ROLE] = uint8_t(c.source_role);
  for (unsigned i = 0; i < 2; ++i) {
    put(p.data(), OUTPUT_RANGES + 24*i, c.output[i].bo_span, 8);
    put(p.data(), OUTPUT_RANGES + 24*i + 8, c.output[i].offset, 8);
    put(p.data(), OUTPUT_RANGES + 24*i + 16, c.output[i].span, 8);
  }
  put(p.data(), ROW_STRIDE, c.row_stride, 8); put(p.data(), BATCH_STRIDE, c.batch_stride, 8);
  for (unsigned i = 0; i < 3; ++i) {
    put(p.data(), WEIGHT_RANGES + 16*i, c.weight[i].offset, 8);
    put(p.data(), WEIGHT_RANGES + 16*i + 8, c.weight[i].span, 8);
  }
  for (unsigned i = 0; i < c.expected_aux_header.size(); ++i) p[EXPECTED_AUX_HEADER + i] = c.expected_aux_header[i];
  put(p.data(), AUX_OFFSET, c.aux_offset, 8); put(p.data(), BIAS_OFFSET, c.bias_offset, 8);
  put(p.data(), BIAS_BYTES, c.bias_bytes, 4); put(p.data(), SOURCE_OFFSET, c.source_range.offset, 8);
  put(p.data(), SOURCE_SPAN, c.source_range.span, 8); put(p.data(), SOURCE_STRIDE, c.source_stride, 8);
  put_context(p.data(), PRODUCER_CONTEXT, c.producer_context);
  put_context(p.data(), QUANT_CONTEXT, c.quant_context);
  put_context(p.data(), LINEAR_CONTEXT, c.linear_context);
  put_ref(p.data(), FUTURE_DST_REF, c.future_dst, c.future_dst_region);
  return p;
}
Check decode(const CommandPacket& p, Command& c) {
  if (get(p.data(), MAGIC, 4) != kCommandMagic || get(p.data(), VERSION, 2) != kVersion ||
      get(p.data(), COMMAND_BEATS, 2) != kCommandBeats || get(p.data(), RESPONSE_BEATS, 2) != kResponseBeats)
    return wire_error(0);
  if (!zeros(p.data(), 20, 24) || !zeros(p.data(), 28, 64) ||
      !zeros(p.data(), 638, 640) || !zeros(p.data(), 900, 904) ||
      !zeros(p.data(), COMMAND_USED, kCommandBytes)) return wire_error(20);
  const auto op = get(p.data(), OP_STATUS, 2);
  if (op < 1 || op > 4 || !get(p.data(), GENERATION, 8) ||
      !get(p.data(), TASK, 4) || get(p.data(), TASK, 4) != get(p.data(), CONTEXT, 4)) return wire_error(6);
  for (unsigned off = SOURCE_REF; off <= DST_REF; off += 8)
    if (p[off + 7] || ((off == A_REF || off == W_REF || off == PS_REF) && p[off + 6])) return wire_error(off);
  if (p[FUTURE_DST_REF + 7]) return wire_error(FUTURE_DST_REF);
  if (p[A_SLOT] > 1 || p[W_SLOT] > 1 || p[OUT0_ROLE] > 12 || p[OUT1_ROLE] > 12 ||
      p[SOURCE_ROLE] > 12 || p[BIAS_KIND] > 1) return wire_error(A_SLOT);
  c = Command{}; c.service = Service(op); c.generation = get(p.data(), GENERATION, 8);
  c.identity = get_identity(p.data(), IDENTITY); c.context = get_context(p.data(), CONTEXT);
  c.source = get_ref(p.data(), SOURCE_REF); c.source_region = p[SOURCE_REF + 6];
  c.a = get_ref(p.data(), A_REF); c.w = get_ref(p.data(), W_REF); c.ps = get_ref(p.data(), PS_REF);
  c.dst = get_ref(p.data(), DST_REF); c.dst_region = p[DST_REF + 6];
  for (unsigned i = 0; i < c.model_identity.size(); ++i) c.model_identity[i] = p[MODEL_IDENTITY + i];
  c.K = uint16_t(get(p.data(), K, 2)); c.N = uint16_t(get(p.data(), N, 2));
  c.rows = p[ROWS]; c.row_block = p[ROW_BLOCK]; c.a_slot = p[A_SLOT]; c.w_slot = p[W_SLOT];
  c.a_epoch = uint32_t(get(p.data(), A_EPOCH, 4)); c.w_epoch = uint32_t(get(p.data(), W_EPOCH, 4));
  c.weight_key = uint16_t(get(p.data(), WEIGHT_KEY, 2)); c.bias_kind = p[BIAS_KIND];
  c.output_role[0] = Bo(p[OUT0_ROLE]); c.output_role[1] = Bo(p[OUT1_ROLE]); c.source_role = Bo(p[SOURCE_ROLE]);
  for (unsigned i = 0; i < 2; ++i) {
    c.output[i].bo_span = get(p.data(), OUTPUT_RANGES + 24*i, 8);
    c.output[i].offset = get(p.data(), OUTPUT_RANGES + 24*i + 8, 8);
    c.output[i].span = get(p.data(), OUTPUT_RANGES + 24*i + 16, 8);
  }
  c.row_stride = get(p.data(), ROW_STRIDE, 8); c.batch_stride = get(p.data(), BATCH_STRIDE, 8);
  for (unsigned i = 0; i < 3; ++i) {
    c.weight[i].offset = get(p.data(), WEIGHT_RANGES + 16*i, 8);
    c.weight[i].span = get(p.data(), WEIGHT_RANGES + 16*i + 8, 8);
  }
  for (unsigned i = 0; i < c.expected_aux_header.size(); ++i) c.expected_aux_header[i] = p[EXPECTED_AUX_HEADER + i];
  c.aux_offset = get(p.data(), AUX_OFFSET, 8); c.bias_offset = get(p.data(), BIAS_OFFSET, 8);
  c.bias_bytes = uint32_t(get(p.data(), BIAS_BYTES, 4));
  c.source_range = {get(p.data(), SOURCE_OFFSET, 8), get(p.data(), SOURCE_SPAN, 8)};
  c.source_stride = get(p.data(), SOURCE_STRIDE, 8);
  c.producer_context = get_context(p.data(), PRODUCER_CONTEXT);
  c.quant_context = get_context(p.data(), QUANT_CONTEXT);
  c.linear_context = get_context(p.data(), LINEAR_CONTEXT);
  c.future_dst = get_ref(p.data(), FUTURE_DST_REF); c.future_dst_region = p[FUTURE_DST_REF + 6];
  if (c.service == Service::LOAD_W) {
    if (!zeros(p.data(), SOURCE_REF, W_REF) || !zeros(p.data(), PS_REF, MODEL_IDENTITY) ||
        !zeros(p.data(), PRODUCER_CONTEXT, COMMAND_USED) || c.rows || c.row_block || c.a_slot || c.a_epoch ||
        !zeros(p.data(), OUT0_ROLE, WEIGHT_RANGES) || !zeros(p.data(), SOURCE_OFFSET, PRODUCER_CONTEXT))
      return wire_error(PRODUCER_CONTEXT);
  } else {
    if (!zeros(p.data(), WEIGHT_RANGES, SOURCE_OFFSET)) return wire_error(WEIGHT_RANGES);
    if (c.service == Service::MATRIX && (c.source_role != Bo(0) ||
        !zeros(p.data(), SOURCE_OFFSET, PRODUCER_CONTEXT))) return wire_error(SOURCE_OFFSET);
    if (c.service == Service::QUANT && (!zeros(p.data(), OUT0_ROLE, SOURCE_ROLE) ||
        !zeros(p.data(), OUTPUT_RANGES, ROW_STRIDE))) return wire_error(OUTPUT_RANGES);
    if ((c.service == Service::GEGLU || (c.service == Service::MATRIX && c.context.op != Op::LIN_QKV)) &&
        (c.output_role[1] != Bo(0) || !zeros(p.data(), OUTPUT_RANGES + 24, ROW_STRIDE)))
      return wire_error(OUT1_ROLE);
  }
  return fields_ok(c) ? ok() : wire_error(CONTEXT);
}
ResponsePacket encode(const Response& r) {
  ResponsePacket p{};
  put(p.data(), MAGIC, kResponseMagic, 4); put(p.data(), VERSION, kVersion, 2);
  put(p.data(), OP_STATUS, uint16_t(r.status), 2); put(p.data(), GENERATION, r.generation, 8);
  put(p.data(), TASK, r.task_id, 4); put(p.data(), FLAGS_DETAIL, r.error_detail, 4);
  put(p.data(), RANK, r.first_error_rank, 8); put(p.data(), BAD_ELEMENT, r.bad_element, 8);
  put(p.data(), ELEMENTS, r.output_elements, 4); p[UNIT] = uint8_t(r.unit);
  p[RETIRE_FLAGS] = uint8_t(r.drained) | uint8_t(r.published) << 1;
  put(p.data(), CYCLES, r.cycles, 8);
  for (unsigned i = 0; i < r.counters.size(); ++i) put(p.data(), COUNTERS + 4*i, r.counters[i], 4);
  put_identity(p.data(), RESPONSE_IDENTITY, r.identity); put_context(p.data(), RESPONSE_CONTEXT, r.context);
  put_ref(p.data(), RESPONSE_REFS, r.source, r.source_region); put_ref(p.data(), RESPONSE_REFS + 8, r.a);
  put_ref(p.data(), RESPONSE_REFS + 16, r.w); put_ref(p.data(), RESPONSE_REFS + 24, r.ps);
  put_ref(p.data(), RESPONSE_REFS + 32, r.dst, r.dst_region);
  put(p.data(), RESPONSE_A_EPOCH, r.a_epoch, 4); put(p.data(), RESPONSE_W_EPOCH, r.w_epoch, 4);
  put_context(p.data(), RESPONSE_PRODUCER_CONTEXT, r.producer_context);
  put_context(p.data(), RESPONSE_QUANT_CONTEXT, r.quant_context);
  put_context(p.data(), RESPONSE_LINEAR_CONTEXT, r.linear_context);
  put_ref(p.data(), RESPONSE_FUTURE_DST_REF, r.future_dst, r.future_dst_region);
  p[RESPONSE_ROWS] = r.rows; p[RESPONSE_ROW_BLOCK] = r.row_block;
  put(p.data(), RESPONSE_SERVICE, uint16_t(r.service), 2);
  return p;
}
Check decode(const ResponsePacket& p, const Command& expected, Response& r) {
  if (get(p.data(), MAGIC, 4) != kResponseMagic || get(p.data(), VERSION, 2) != kVersion ||
      get(p.data(), OP_STATUS, 2) > uint16_t(Status::E_INTERNAL) || p[UNIT] > 3 ||
      (p[RETIRE_FLAGS] & ~3u) || !zeros(p.data(), 46, 48) || !zeros(p.data(), 56, 64) ||
      !zeros(p.data(), 120, 128) || !zeros(p.data(), RESPONSE_USED, kResponseBytes)) return wire_error(0);
  r = Response{}; r.status = Status(get(p.data(), OP_STATUS, 2));
  r.generation = get(p.data(), GENERATION, 8); r.task_id = uint32_t(get(p.data(), TASK, 4));
  r.error_detail = uint32_t(get(p.data(), FLAGS_DETAIL, 4));
  r.first_error_rank = get(p.data(), RANK, 8); r.bad_element = get(p.data(), BAD_ELEMENT, 8);
  r.output_elements = uint32_t(get(p.data(), ELEMENTS, 4)); r.unit = OutputUnit(p[UNIT]);
  r.drained = p[RETIRE_FLAGS] & 1; r.published = p[RETIRE_FLAGS] & 2; r.cycles = get(p.data(), CYCLES, 8);
  for (unsigned i = 0; i < r.counters.size(); ++i) r.counters[i] = uint32_t(get(p.data(), COUNTERS + 4*i, 4));
  r.identity = get_identity(p.data(), RESPONSE_IDENTITY); r.context = get_context(p.data(), RESPONSE_CONTEXT);
  r.source = get_ref(p.data(), RESPONSE_REFS); r.source_region = p[RESPONSE_REFS + 6];
  r.a = get_ref(p.data(), RESPONSE_REFS + 8); r.w = get_ref(p.data(), RESPONSE_REFS + 16);
  r.ps = get_ref(p.data(), RESPONSE_REFS + 24); r.dst = get_ref(p.data(), RESPONSE_REFS + 32);
  r.dst_region = p[RESPONSE_REFS + 38];
  r.a_epoch = uint32_t(get(p.data(), RESPONSE_A_EPOCH, 4)); r.w_epoch = uint32_t(get(p.data(), RESPONSE_W_EPOCH, 4));
  r.producer_context = get_context(p.data(), RESPONSE_PRODUCER_CONTEXT);
  r.quant_context = get_context(p.data(), RESPONSE_QUANT_CONTEXT);
  r.linear_context = get_context(p.data(), RESPONSE_LINEAR_CONTEXT);
  r.future_dst = get_ref(p.data(), RESPONSE_FUTURE_DST_REF); r.future_dst_region = p[RESPONSE_FUTURE_DST_REF + 6];
  r.rows = p[RESPONSE_ROWS]; r.row_block = p[RESPONSE_ROW_BLOCK];
  r.service = Service(get(p.data(), RESPONSE_SERVICE, 2));
  if (p[RESPONSE_FUTURE_DST_REF + 7]) return wire_error(RESPONSE_FUTURE_DST_REF);
  for (unsigned i = 0; i < 5; ++i) {
    unsigned off = RESPONSE_REFS + 8*i;
    if (p[off + 7] || ((i == 1 || i == 2 || i == 3) && p[off + 6])) return wire_error(off);
  }
  if (r.generation != expected.generation || r.task_id != expected.context.task_id ||
      !numeric_identity_equal(r.identity, expected.identity) || !same_context(r.context, expected.context) ||
      r.source != expected.source || r.a != expected.a || r.w != expected.w ||
      r.ps != expected.ps || r.dst != expected.dst || r.source_region != expected.source_region ||
      r.dst_region != expected.dst_region || r.a_epoch != expected.a_epoch || r.w_epoch != expected.w_epoch ||
      !same_context(r.producer_context, expected.producer_context) ||
      !same_context(r.quant_context, expected.quant_context) || !same_context(r.linear_context, expected.linear_context) ||
      r.future_dst != expected.future_dst || r.future_dst_region != expected.future_dst_region ||
      r.rows != expected.rows || r.row_block != expected.row_block || r.service != expected.service ||
      !r.drained || (r.published && r.status != Status::OK) ||
      (r.status != Status::OK && (r.output_elements || r.unit != OutputUnit::NONE)))
    return {Status::E_PROTOCOL, detail(4, 0, 21)};
  return {r.status, r.error_detail, r.bad_element};
}
} // namespace laya::portal
