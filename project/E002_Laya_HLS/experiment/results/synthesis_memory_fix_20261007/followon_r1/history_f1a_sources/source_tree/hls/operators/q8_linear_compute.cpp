#include "laya_numeric.h"

namespace laya {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check numerical(Op op, unsigned row, unsigned col, unsigned group) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15),
          uint64_t(row) * 5248 * 128 + uint64_t(col) * 128 + group};
}
Check validate_task(const LinearTask& t, const NumericIdentity& id) {
  Check c = numeric_check_context(t.ctx, id);
  if (!c) return c;
  c = numeric_check_ref(t.a); if (!c) return c;
  c = numeric_check_ref(t.w); if (!c) return c;
  c = numeric_check_ref(t.ps); if (!c) return c;
  c = numeric_check_ref(t.dst, t.dst_region); if (!c) return c;
  if (t.a.id != Buffer::A8 || t.w.id != Buffer::WEIGHT ||
      t.ps.id != Buffer::PS || t.bias_kind > 1)
    return {Status::E_BUFFER, detail(4, 0, 4)};
  uint8_t family = 0;
  switch (t.ctx.op) {
    case Op::LIN_QKV: family = t.ctx.stage == 2 ? 1 : t.ctx.stage == 4 ? 5 : 0; break;
    case Op::LIN_WO: family = t.ctx.stage == 2 ? 2 : t.ctx.stage == 4 ? 6 : 0; break;
    case Op::LIN_WI: family = t.ctx.stage == 2 ? 3 : 0; break;
    case Op::LIN_DOWN: family = t.ctx.stage == 2 ? 4 : 0; break;
    case Op::LIN_DEC_FC1: family = t.ctx.stage == 4 ? 7 : 0; break;
    case Op::LIN_DEC_FC2: family = t.ctx.stage == 4 ? 8 : 0; break;
    case Op::LIN_SCORER_FC1: family = t.ctx.stage == 5 ? 9 : 0; break;
    case Op::LIN_ACT_FC2: family = t.ctx.stage == 6 ? 12 : 0; break;
    default: break;
  }
  if (!family || t.weight.family != family) return {Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
  if ((t.ctx.stage == 5 && t.ctx.row_space != RowSpace::MARKER) ||
      (t.ctx.stage == 6 && t.ctx.row_space != RowSpace::BATCH) ||
      ((t.ctx.stage == 2 || t.ctx.stage == 4) &&
       t.ctx.row_space != RowSpace::TOKEN))
    return {Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
  c = numeric_check_weight(t.weight, t.ctx.stage, t.ctx.layer, t.K, t.N);
  if (!c) return c;
  if ((t.ctx.op == Op::LIN_QKV && t.dst.id != Buffer::QKV) ||
      ((t.ctx.op == Op::LIN_WO || t.ctx.op == Op::LIN_DOWN ||
        t.ctx.op == Op::LIN_DEC_FC2) && t.dst.id != Buffer::TMP) ||
      (t.ctx.op == Op::LIN_WI && t.dst.id != Buffer::WI) ||
      (t.ctx.op == Op::LIN_DEC_FC1 && t.dst.id != Buffer::DEC_FF) ||
      (t.ctx.op == Op::LIN_SCORER_FC1 &&
       (t.dst.id != Buffer::HEAD_WORK ||
        t.dst_region != uint8_t(Region::SCORER_ACT))) ||
      (t.ctx.op == Op::LIN_ACT_FC2 &&
       (t.dst.id != Buffer::HEAD_WORK ||
        t.dst_region != uint8_t(Region::ACT_LOGITS))))
    return {Status::E_BUFFER, detail(4, uint8_t(t.dst.id), 4)};
  return ok();
}

Check compute_one(Op op, uint16_t n0, uint8_t bias_kind,
                  unsigned row, unsigned col, unsigned groups,
                  const int8_t aq[16][128][32],
                  const uint16_t as[16][128],
                  const int8_t wq[8][128][32],
                  const uint16_t ws[8][128], const float bias[8],
                  float& output, NumericGroupTrace trace[128]) {
  float acc = 0.0f;
  for (unsigned g = 0; g < groups; ++g) {
    int32_t dot = 0;
    for (unsigned k = 0; k < 32; ++k)
      dot += int32_t(aq[row][g][k]) * int32_t(wq[col][g][k]);
    const float sa = numeric_half_to_f32(as[row][g]);
    const float sw = numeric_half_to_f32(ws[col][g]);
    if (!finite32(sa) || !finite32(sw) || sa < 0.0f || sw < 0.0f)
      return numerical(op, row, n0 + col, g);
    const float product = sa * sw;
    if (!finite32(product)) return numerical(op, row, n0 + col, g);
    const float term = product * float(dot);
    if (!finite32(term)) return numerical(op, row, n0 + col, g);
    acc = acc + term;
    if (!finite32(acc)) return numerical(op, row, n0 + col, g);
    if (trace != nullptr) {
      trace[g].dot = dot;
      trace[g].term_bits = numeric_f32_bits(term);
      trace[g].partial_bits = numeric_f32_bits(acc);
    }
  }
  if (bias_kind) {
    if (!finite32(bias[col])) return numerical(op, row, n0 + col, groups);
    acc = acc + bias[col];
    if (!finite32(acc)) return numerical(op, row, n0 + col, groups);
  }
  output = acc;
  return ok();
}
} // namespace

Check q8_linear_window_arithmetic(Op op, uint16_t n0, uint8_t bias_kind,
                                  uint8_t rows, uint16_t K, uint8_t cols,
                                  const int8_t aq[16][128][32],
                                  const uint16_t as[16][128],
                                  const int8_t wq[8][128][32],
                                  const uint16_t ws[8][128],
                                  const float bias[8], float y[16][8],
                                  NumericTraceRequest trace_request,
                                  NumericGroupTrace trace[128]) {
  if (!rows || rows > 16 || !K || K > 4096 || K % 32 ||
      !cols || cols > 8 || n0 % 8 || bias_kind > 1 ||
      (trace_request.enabled &&
       (trace == nullptr || trace_request.row_local >= rows ||
        trace_request.col_local >= cols)))
    return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
  const unsigned groups = K / 32;
  for (unsigned r = 0; r < rows; ++r)
    for (unsigned col = 0; col < cols; ++col) {
      NumericGroupTrace* selected =
          trace_request.enabled && r == trace_request.row_local &&
          col == trace_request.col_local ? trace : nullptr;
      Check c = compute_one(op, n0, bias_kind, r, col, groups,
                            aq, as, wq, ws, bias, y[r][col], selected);
      if (!c) return c;
    }
  return ok();
}

Check q8_linear_compute(const LinearTask& task,
                        const NumericIdentity& request,
                        const F32TileMeta& expected_source,
                        const A8TileMeta& activation,
                        const WeightWindowMeta& weight,
                        const WeightBinding& expected_binding,
                        uint16_t n0, uint8_t cols,
                        const int8_t aq[16][128][32],
                        const uint16_t as[16][128],
                        const int8_t wq[8][128][32],
                        const uint16_t ws[8][128],
                        const float bias[8], float y[16][8],
                        NumericWindowResult& result,
                        NumericTraceRequest trace_request,
                        NumericGroupTrace trace[128]) {
  Check c = validate_task(task, request);
  if (!c) return c;
  if (n0 >= task.N || n0 % 8 || !cols || cols > 8 ||
      cols != (task.N - n0 < 8 ? task.N - n0 : 8))
    return {Status::E_SHAPE, detail(7, uint8_t(task.ctx.op), 5)};
  if (trace_request.enabled &&
      (trace == nullptr || trace_request.row_local >= task.ctx.rows ||
       trace_request.col_local >= cols))
    return {Status::E_SHAPE, detail(7, uint8_t(task.ctx.op), 5)};
  c = numeric_check_a8(activation, request, task, expected_source);
  if (!c) return c;
  c = numeric_check_window(weight, request, task, expected_binding, n0, cols);
  if (!c) return c;
  c = numeric_claim_window(result, task.ps, task.dst, task.dst_region);
  if (!c) return c;
  result.identity = request;

  c = q8_linear_window_arithmetic(task.ctx.op, n0, task.bias_kind,
                                  task.ctx.rows, task.K, cols, aq, as,
                                  wq, ws, bias, y, trace_request, trace);
  if (!c) {
    result.state = CacheState::INVALID;
    result.valid = false;
    return c;
  }

  result.identity = request;
  result.ps = task.ps;
  result.dst = task.dst;
  result.task_id = task.ctx.task_id;
  result.dst_region = task.dst_region;
  result.row_space = task.ctx.row_space;
  result.batch = task.ctx.batch;
  result.row0 = task.ctx.row0;
  result.rows = task.ctx.rows;
  result.N = task.N;
  result.n0 = n0;
  result.cols = cols;
  result.output_elements = uint32_t(task.ctx.rows) * cols;
  result.output_beats = 0;
  result.status = Status::OK;
  result.state = CacheState::READY;
  result.valid = true;
  return ok();
}

Check q8_linear_trace(const LinearTask& task,
                      const NumericIdentity& request,
                      const F32TileMeta& expected_source,
                      const A8TileMeta& activation,
                      const WeightWindowMeta& weight,
                      const WeightBinding& expected_binding,
                      uint16_t n0, uint8_t cols, uint8_t row_local,
                      uint8_t col_local,
                      const int8_t aq[16][128][32],
                      const uint16_t as[16][128],
                      const int8_t wq[8][128][32],
                      const uint16_t ws[8][128],
                      const float bias[8], NumericGroupTrace trace[128]) {
  Check c = validate_task(task, request);
  if (!c) return c;
  if (n0 >= task.N || n0 % 8 || !cols || cols > 8 ||
      cols != (task.N - n0 < 8 ? task.N - n0 : 8) ||
      row_local >= task.ctx.rows || col_local >= cols || trace == nullptr)
    return {Status::E_SHAPE, detail(7, uint8_t(task.ctx.op), 5)};
  c = numeric_check_a8(activation, request, task, expected_source);
  if (!c) return c;
  c = numeric_check_window(weight, request, task, expected_binding, n0, cols);
  if (!c) return c;
  float unused_output = 0.0f;
  return compute_one(task.ctx.op, n0, task.bias_kind, row_local, col_local,
                     task.K / 32, aq, as, wq, ws, bias, unused_output, trace);
}

} // namespace laya
