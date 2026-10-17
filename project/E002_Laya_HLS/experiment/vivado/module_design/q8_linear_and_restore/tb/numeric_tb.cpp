#include "numeric_test_support.h"

#include <cmath>
#include <limits>

using namespace laya;

int main() {
  int cases = 0;
  const NumericIdentity id = test_identity();
  LinearTask task;
  task.ctx = {5, Op::LIN_QKV, 2, 0, 0, RowSpace::TOKEN, 0, 2};
  task.a = {Buffer::A8, 0, 1};
  task.w = {Buffer::WEIGHT, 0, 1};
  task.ps = {Buffer::PS, 0, 1};
  task.dst = {Buffer::QKV, 0, 1};
  task.weight = {1, 0}; task.K = 1024; task.N = 3072;
  F32TileMeta src = test_source(id, {Buffer::NORM, 0, 1}, 0, task.ctx, task.K);
  A8TileMeta a;
  a.identity = id; a.ref = task.a; a.source = src;
  a.producer_task_id = 4; a.stage = 2; a.layer = 0;
  a.row_space = RowSpace::TOKEN; a.batch = 0; a.row0 = 0;
  a.rows = 2; a.K = 1024;
  numeric_cover_all(a.covered_groups, 2, 32, 16);
  a.state = CacheState::READY; a.content = Content::Q8_TILE; a.valid = true;
  const WeightBinding binding = test_binding(task.K, task.N);
  WeightWindowMeta w = test_window(id, task, 0, 8, binding);
  static int8_t aq[16][128][32], wq[8][128][32];
  static uint16_t as[16][128], ws[8][128];
  static float y[16][8], bias[8];
  NumericWindowResult out;
  NumericGroupTrace trace[128];
  const NumericTraceRequest probe{true, 0, 0};
  for (unsigned r = 0; r < 2; ++r)
    for (unsigned g = 0; g < 32; ++g) {
      as[r][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k) aq[r][g][k] = 1;
    }
  for (unsigned col = 0; col < 8; ++col)
    for (unsigned g = 0; g < 32; ++g) {
      ws[col][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k) wq[col][g][k] = 1;
    }
  for (unsigned r = 0; r < 16; ++r)
    for (unsigned col = 0; col < 8; ++col) y[r][col] = -999.0f;
  Check c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                              aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.output_elements == 16 &&
           out.output_beats == 0 && y[0][0] == 1024.0f &&
           y[1][7] == 1024.0f && y[2][0] == -999.0f,
           "full K QKV window, row guard");
  nrequire(trace[0].dot == 32 && trace[0].term_bits == 0x42000000u &&
           trace[31].partial_bits == 0x44800000u,
           "dot/term/partial trace");
  ++cases;

  A8TileMeta bad_a = a; bad_a.K = 256;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, bad_a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "A8 K mismatch"); ++cases;
  bad_a = a; ++bad_a.source.ref.epoch;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, bad_a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "A8 source epoch"); ++cases;
  bad_a = a; bad_a.covered_groups[1][0] &= ~1u;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, bad_a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "A8 missing group"); ++cases;
  bad_a = a; bad_a.state = CacheState::READ;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, bad_a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "A8 READ lock"); ++cases;
  bad_a = a; ++bad_a.identity.generation;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, bad_a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "A8 old generation"); ++cases;

  WeightWindowMeta bad_w = w; bad_w.weight.family = 2;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, bad_w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "W family"); ++cases;
  bad_w = w; bad_w.covered_groups[7][0] &= ~1u;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, bad_w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "W missing group"); ++cases;
  bad_w = w; bad_w.state = CacheState::FILL;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, bad_w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "W FILL"); ++cases;
  bad_w = w; bad_w.binding.weight_sha256[0] ^= 1;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, bad_w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "W immutable binding"); ++cases;
  bad_w = w; bad_w.n0 = 8;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, bad_w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "W window identity"); ++cases;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 1, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_SHAPE && !out.valid, "unaligned n0"); ++cases;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 7,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_SHAPE && !out.valid, "partial non-tail cols"); ++cases;
  LinearTask wrong = task; wrong.N = 1024;
  out = NumericWindowResult{};
  c = q8_linear_compute(wrong, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_SHAPE && !out.valid, "wrong full N"); ++cases;
  as[0][0] = 0x7c00;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid, "nonfinite scale"); ++cases;
  as[0][0] = 0x3c00;
  ws[0][0] = 0x8000;
  for (unsigned k = 0; k < 32; ++k) wq[0][0][k] = -1;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && trace[0].term_bits == 0x00000000u,
           "negative-zero scale and negative dot signed term"); ++cases;
  ws[0][0] = 0x3c00;
  for (unsigned k = 0; k < 32; ++k) wq[0][0][k] = 1;
  ws[0][0] = 0x0000;
  for (unsigned k = 0; k < 32; ++k) wq[0][0][k] = -1;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && trace[0].dot == -32 &&
           trace[0].term_bits == 0x80000000u,
           "positive-zero scale times negative dot has negative-zero term");
  ++cases;
  ws[0][0] = 0x3c00;

  for (unsigned r = 0; r < 2; ++r)
    for (unsigned g = 0; g < 32; ++g) {
      as[r][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k) aq[r][g][k] = 127;
    }
  for (unsigned col = 0; col < 8; ++col)
    for (unsigned g = 0; g < 32; ++g) {
      ws[col][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k)
        wq[col][g][k] = col == 0 ? 127 : col == 1 ? -127 :
                        col == 2 ? (k & 1 ? -127 : 127) : 1;
    }
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && trace[0].dot == 516128 &&
           y[0][0] == 16516096.0f && y[0][1] == -16516096.0f &&
           numeric_f32_bits(y[0][2]) == 0,
           "S8 positive/negative dot limits and within-group cancellation");
  NumericGroupTrace extreme_trace[128];
  nrequire(bool(q8_linear_trace(task, id, src, a, w, binding, 0, 8,
                                0, 1, aq, as, wq, ws, bias, extreme_trace)) &&
           extreme_trace[0].dot == -516128,
           "negative S8 dot bound in independent trace slot");
  nrequire(bool(q8_linear_trace(task, id, src, a, w, binding, 0, 8,
                                0, 2, aq, as, wq, ws, bias, extreme_trace)) &&
           extreme_trace[0].dot == 0,
           "positive/negative S8 products cancel in I32");
  ++cases;

  // Group terms 2^24, 1, -2^24 must retire in that order.  Regrouping
  // the first and last terms would produce 1 instead of the R0 result 0.
  for (unsigned r = 0; r < 2; ++r)
    for (unsigned g = 0; g < 32; ++g) {
      as[r][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k) aq[r][g][k] = 0;
    }
  for (unsigned col = 0; col < 8; ++col)
    for (unsigned g = 0; g < 32; ++g) {
      ws[col][g] = 0x3c00;
      for (unsigned k = 0; k < 32; ++k) wq[col][g][k] = 0;
    }
  for (unsigned g = 0; g < 3; ++g) aq[0][g][0] = 1;
  wq[0][0][0] = 1; wq[0][1][0] = 1; wq[0][2][0] = -1;
  as[0][0] = as[0][2] = ws[0][0] = ws[0][2] = 0x6c00;
  out = NumericWindowResult{};
  c = q8_linear_compute(task, id, src, a, w, binding, 0, 8,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && trace[0].term_bits == 0x4b800000u &&
           trace[1].term_bits == 0x3f800000u &&
           trace[1].partial_bits == 0x4b800000u &&
           trace[2].term_bits == 0xcb800000u &&
           trace[2].partial_bits == 0 && numeric_f32_bits(y[0][0]) == 0,
           "group-order FP32 rounding counterexample");
  ++cases;

  LinearTask act;
  act.ctx = {9, Op::LIN_ACT_FC2, 6, 255, 1, RowSpace::BATCH, 0, 1};
  act.a = {Buffer::A8, 1, 1}; act.w = {Buffer::WEIGHT, 1, 1};
  act.ps = {Buffer::PS, 1, 1}; act.dst = {Buffer::HEAD_WORK, 0, 1};
  act.weight = {12, 255}; act.K = 256; act.N = 2;
  act.dst_region = uint8_t(Region::ACT_LOGITS); act.bias_kind = 1;
  F32TileMeta act_src = test_source(id, {Buffer::HEAD_WORK, 0, 1},
                                    uint8_t(Region::ACT_HIDDEN), act.ctx, 256);
  A8TileMeta act_a;
  act_a.identity = id; act_a.ref = act.a; act_a.source = act_src;
  act_a.producer_task_id = 8; act_a.stage = 6; act_a.layer = 255;
  act_a.row_space = RowSpace::BATCH; act_a.batch = 1;
  act_a.row0 = 0; act_a.rows = 1; act_a.K = 256;
  numeric_cover_all(act_a.covered_groups, 1, 8, 16);
  act_a.state = CacheState::READY; act_a.content = Content::Q8_TILE; act_a.valid = true;
  const WeightBinding act_binding = test_binding(act.K, act.N, true);
  WeightWindowMeta act_w = test_window(id, act, 0, 2, act_binding);
  for (unsigned g = 0; g < 8; ++g) {
    as[0][g] = 0x3c00;
    for (unsigned col = 0; col < 2; ++col) ws[col][g] = 0x3c00;
    for (unsigned k = 0; k < 32; ++k) {
      aq[0][g][k] = 1; wq[0][g][k] = 1; wq[1][g][k] = 1;
    }
  }
  bias[0] = 0.25f; bias[1] = -0.5f;
  for (unsigned col = 0; col < 8; ++col) y[0][col] = -999.0f;
  out = NumericWindowResult{};
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.output_elements == 2 &&
           y[0][0] == 256.25f && y[0][1] == 255.5f,
           "act N2 full K and bound bias");
  for (unsigned col = 2; col < 8; ++col)
    nrequire(y[0][col] == -999.0f, "N2 invalid lane guard");
  ++cases;
  bias[1] = std::numeric_limits<float>::infinity();
  out = NumericWindowResult{};
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid &&
           out.state == CacheState::INVALID &&
           ((c.detail >> 16) & 0xffu) == uint8_t(Op::LIN_ACT_FC2),
           "act bias nonfinite prevents publication"); ++cases;
  bias[1] = -0.5f;
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid &&
           out.ps.epoch == 1 && out.dst.epoch == 1,
           "repaired act bias cannot reuse failed PS/destination epochs");
  ++cases;
  act.ps.epoch = 2; act.dst.epoch = 2; act.ctx.task_id = 10;
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.state == CacheState::READY &&
           out.ps.epoch == 2 && out.dst.epoch == 2,
           "consumed failure epoch then legal new slice"); ++cases;
  const NumericWindowResult published = out;
  const uint32_t old_y = numeric_f32_bits(y[0][0]);
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.valid && out.dst == published.dst &&
           numeric_f32_bits(y[0][0]) == old_y, "READY slice destination guard");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.valid && out.readers == 1 &&
           numeric_f32_bits(y[0][0]) == old_y, "READ slice destination guard");
  nrequire(numeric_release_window(out).code == Status::E_BUFFER,
           "slice reader prevents release"); ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_window(out)) && !out.valid &&
           out.ps.epoch == 2 && out.dst.epoch == 2,
           "slice release retains PS and destination epochs");
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.state == CacheState::FREE,
           "stale slice destination epoch"); ++cases;
  act.ps.epoch = 3; act.dst.epoch = 3; act.ctx.task_id = 11;
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.ps.epoch == 3 && out.dst.epoch == 3,
           "new PS/destination epoch accepted"); ++cases;
  numeric_reset_window(out);
  nrequire(out.output_elements == 0 && out.output_beats == 0 &&
           out.ps.epoch == 3 && out.dst.epoch == 3,
           "reset clears slice count but keeps both epochs");
  c = q8_linear_compute(act, id, act_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid && out.ps.epoch == 3,
           "reset cannot revive PS epoch"); ++cases;
  NumericIdentity next = id; ++next.generation;
  act.ps.epoch = 4; act.dst.epoch = 4; act.ctx.task_id = 12;
  F32TileMeta next_src = test_source(next, act_src.ref,
                                     uint8_t(Region::ACT_HIDDEN), act.ctx, 256);
  act_a.identity = next; act_a.source = next_src;
  act_w.identity = next;
  c = q8_linear_compute(act, next, next_src, act_a, act_w, act_binding, 0, 2,
                        aq, as, wq, ws, bias, y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.ps.epoch == 4 && out.dst.epoch == 4 &&
           out.identity.generation == next.generation,
           "new generation requires monotonic PS/destination epochs");
  ++cases;
  const uint32_t next_y = numeric_f32_bits(y[0][0]);
  F32TileMeta wrong_next_src = next_src;
  ++wrong_next_src.identity.request_id;
  c = q8_linear_compute(act, next, wrong_next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.state == CacheState::READY && out.ps.epoch == 4 &&
           out.dst.epoch == 4 && numeric_f32_bits(y[0][0]) == next_y,
           "preclaim source error preserves published slice and array");
  ++cases;
  WeightWindowMeta wrong_model = act_w;
  wrong_model.identity.model_tag[0] ^= 1;
  c = q8_linear_compute(act, next, next_src, act_a, wrong_model,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_MODEL && out.valid &&
           out.state == CacheState::READY && out.ps.epoch == 4 &&
           out.dst.epoch == 4 && numeric_f32_bits(y[0][0]) == next_y,
           "preclaim model error preserves published slice and array");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = q8_linear_compute(act, next, next_src, act_a, wrong_model,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_MODEL && out.valid &&
           out.state == CacheState::READ && out.readers == 1 &&
           out.ps.epoch == 4 && out.dst.epoch == 4 &&
           numeric_f32_bits(y[0][0]) == next_y,
           "preclaim model error preserves READ slice owner");
  ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_window(out)), "release slice for dual-ref checks");
  act.ps.epoch = 5; act.dst.epoch = 4; act.ctx.task_id = 13;
  c = q8_linear_compute(act, next, next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.state == CacheState::FREE &&
           !out.valid && out.ps.epoch == 4 && out.dst.epoch == 4 &&
           numeric_f32_bits(y[0][0]) == next_y,
           "advancing PS alone cannot claim slice owner");
  ++cases;
  act.ps.epoch = 4; act.dst.epoch = 5;
  c = q8_linear_compute(act, next, next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && out.state == CacheState::FREE &&
           !out.valid && out.ps.epoch == 4 && out.dst.epoch == 4 &&
           numeric_f32_bits(y[0][0]) == next_y,
           "advancing destination alone cannot claim slice owner");
  ++cases;
  act.ps.epoch = 5; act.dst.epoch = 5;
  c = q8_linear_compute(act, next, next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.ps.epoch == 5 && out.dst.epoch == 5,
           "both PS and destination advance together");
  ++cases;
  nrequire(bool(numeric_release_window(out)), "release slice before FILL reservation");
  nrequire(bool(numeric_claim_window(out, {Buffer::PS, 1, 6},
                                     {Buffer::HEAD_WORK, 0, 6},
                                     uint8_t(Region::ACT_LOGITS))) &&
           out.state == CacheState::FILL && out.ps.epoch == 6 &&
           out.dst.epoch == 6, "reserve both slice FILL epochs");
  numeric_reset_window(out);
  nrequire(out.state == CacheState::INVALID && !out.valid &&
           out.ps.epoch == 6 && out.dst.epoch == 6 &&
           out.output_elements == 0 && out.output_beats == 0,
           "reset consumes slice FILL reservation");
  act.ps.epoch = 6; act.dst.epoch = 6; act.ctx.task_id = 14;
  c = q8_linear_compute(act, next, next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(c.code == Status::E_BUFFER && !out.valid &&
           out.ps.epoch == 6 && out.dst.epoch == 6,
           "reset slice FILL reservation cannot revive old epochs");
  ++cases;
  act.ps.epoch = 7; act.dst.epoch = 7; act.ctx.task_id = 15;
  c = q8_linear_compute(act, next, next_src, act_a, act_w,
                        act_binding, 0, 2, aq, as, wq, ws, bias,
                        y, out, probe, trace);
  nrequire(bool(c) && out.valid && out.ps.epoch == 7 && out.dst.epoch == 7,
           "slice accepts epochs after reset FILL reservation");
  ++cases;

  const uint32_t bound_y = numeric_f32_bits(y[0][0]);
  auto reject_a8_field = [&](const A8TileMeta& candidate, Status expected,
                             const char* label) {
    const Check check = q8_linear_compute(act, next, next_src, candidate,
                                          act_w, act_binding, 0, 2,
                                          aq, as, wq, ws, bias, y, out,
                                          probe, trace);
    nrequire(check.code == expected && out.valid &&
             out.state == CacheState::READY && out.ps.epoch == 7 &&
             out.dst.epoch == 7 && out.output_elements == 2 &&
             numeric_f32_bits(y[0][0]) == bound_y, label);
    ++cases;
  };
  A8TileMeta a_variant = act_a;
  a_variant.rows = 2;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 rows binding");
  a_variant = act_a; a_variant.batch = 0;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 batch binding");
  a_variant = act_a; a_variant.row0 = 1;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 row0 binding");
  a_variant = act_a; a_variant.row_space = RowSpace::TOKEN;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 row-space binding");
  a_variant = act_a; a_variant.identity.numeric_tag[0] ^= 1;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 numeric tag binding");
  a_variant = act_a; a_variant.identity.layout_tag[0] ^= 1;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 layout tag binding");
  a_variant = act_a; a_variant.identity.build_tag[0] ^= 1;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 build tag binding");
  a_variant = act_a; a_variant.source.identity.numeric_tag[0] ^= 1;
  reject_a8_field(a_variant, Status::E_BUFFER, "A8 source numeric tag binding");

  auto reject_weight_field = [&](const WeightWindowMeta& candidate,
                                 const WeightBinding& expected_binding,
                                 const char* label) {
    const Check check = q8_linear_compute(act, next, next_src, act_a,
                                          candidate, expected_binding, 0, 2,
                                          aq, as, wq, ws, bias, y, out,
                                          probe, trace);
    nrequire(check.code == Status::E_BUFFER && out.valid &&
             out.state == CacheState::READY && out.ps.epoch == 7 &&
             out.dst.epoch == 7 && out.output_elements == 2 &&
             numeric_f32_bits(y[0][0]) == bound_y, label);
    ++cases;
  };
  WeightWindowMeta w_variant = act_w;
  w_variant.K = 1024;
  reject_weight_field(w_variant, act_binding, "W full K binding");
  w_variant = act_w; w_variant.N = 1024;
  reject_weight_field(w_variant, act_binding, "W full N binding");
  w_variant = act_w; w_variant.cols = 1;
  reject_weight_field(w_variant, act_binding, "W cols binding");
  w_variant = act_w; ++w_variant.ref.epoch;
  reject_weight_field(w_variant, act_binding, "W epoch binding");
  w_variant = act_w; w_variant.identity.numeric_tag[0] ^= 1;
  reject_weight_field(w_variant, act_binding, "W numeric tag binding");
  w_variant = act_w; w_variant.identity.layout_tag[0] ^= 1;
  reject_weight_field(w_variant, act_binding, "W layout tag binding");
  w_variant = act_w; w_variant.identity.build_tag[0] ^= 1;
  reject_weight_field(w_variant, act_binding, "W build tag binding");
  WeightBinding invalid_binding = act_binding;
  ++invalid_binding.weight_bytes;
  w_variant = act_w; w_variant.binding = invalid_binding;
  reject_weight_field(w_variant, invalid_binding, "W full weight byte span");
  invalid_binding = act_binding; ++invalid_binding.bias_bytes;
  w_variant = act_w; w_variant.binding = invalid_binding;
  reject_weight_field(w_variant, invalid_binding, "W full bias byte span");
  invalid_binding = act_binding;
  invalid_binding.weight_offset =
      std::numeric_limits<uint64_t>::max() - invalid_binding.weight_bytes + 1;
  w_variant = act_w; w_variant.binding = invalid_binding;
  reject_weight_field(w_variant, invalid_binding, "W weight offset overflow");
  invalid_binding = act_binding;
  invalid_binding.bias_offset =
      std::numeric_limits<uint64_t>::max() - invalid_binding.bias_bytes + 1;
  w_variant = act_w; w_variant.binding = invalid_binding;
  reject_weight_field(w_variant, invalid_binding, "W bias offset overflow");

  // Supplemental maximum-K decoder FC2 slice.  This is not a captured
  // Decision path; it proves all 128 groups including the last are visited.
  LinearTask max_k;
  max_k.ctx = {16, Op::LIN_DEC_FC2, 4, 0, 0, RowSpace::TOKEN, 0, 1};
  max_k.a = {Buffer::A8, 0, 1}; max_k.w = {Buffer::WEIGHT, 0, 1};
  max_k.ps = {Buffer::PS, 0, 1}; max_k.dst = {Buffer::TMP, 0, 1};
  max_k.weight = {8, 0}; max_k.K = 4096; max_k.N = 1024;
  F32TileMeta max_src = test_source(id, {Buffer::DEC_FF, 0, 1},
                                    0, max_k.ctx, max_k.K);
  A8TileMeta max_a;
  max_a.identity = id; max_a.ref = max_k.a; max_a.source = max_src;
  max_a.producer_task_id = 15; max_a.stage = 4; max_a.layer = 0;
  max_a.row_space = RowSpace::TOKEN; max_a.batch = 0; max_a.row0 = 0;
  max_a.rows = 1; max_a.K = 4096;
  numeric_cover_all(max_a.covered_groups, 1, 128, 16);
  max_a.state = CacheState::READY; max_a.content = Content::Q8_TILE;
  max_a.valid = true;
  const WeightBinding max_binding = test_binding(4096, 1024);
  const WeightWindowMeta max_window =
      test_window(id, max_k, 1016, 8, max_binding);
  for (unsigned g = 0; g < 128; ++g) {
    as[0][g] = 0x3c00;
    for (unsigned col = 0; col < 8; ++col) ws[col][g] = 0x3c00;
    for (unsigned k = 0; k < 32; ++k) {
      aq[0][g][k] = 1;
      for (unsigned col = 0; col < 8; ++col) wq[col][g][k] = 1;
    }
  }
  NumericWindowResult max_result;
  for (unsigned col = 0; col < 8; ++col) y[1][col] = -999.0f;
  c = q8_linear_compute(max_k, id, max_src, max_a, max_window,
                        max_binding, 1016, 8, aq, as, wq, ws, bias,
                        y, max_result, probe, trace);
  nrequire(bool(c) && max_result.valid && max_result.output_elements == 8 &&
           trace[127].dot == 32 &&
           trace[127].partial_bits == numeric_f32_bits(4096.0f) &&
           y[0][0] == 4096.0f && y[0][7] == 4096.0f &&
           y[1][0] == -999.0f,
           "supplemental K4096 decoder window visits all 128 groups");
  ++cases;
  std::cout << "NUMERIC_LINEAR_TB_PASS cases=" << cases << '\n';
}
