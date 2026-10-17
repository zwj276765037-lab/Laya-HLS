#include "numeric_test_support.h"

#include <cmath>
#include <limits>

using namespace laya;

int main() {
  int cases = 0;
  const NumericIdentity id = test_identity();
  QuantTask task;
  task.ctx = {3, Op::QUANT, 2, 0, 0, RowSpace::TOKEN, 0, 1};
  task.src = {Buffer::NORM, 0, 1};
  task.a_dst = {Buffer::A8, 0, 1};
  task.K = 1024;
  F32TileMeta src = test_source(id, task.src, 0, task.ctx, task.K);
  static float x[16][4096];
  static int8_t q[16][128][32];
  static uint16_t scale[16][128];
  A8TileMeta out;
  Check c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && out.valid && out.state == CacheState::READY &&
           scale[0][0] == 0 && q[0][0][0] == 0,
           "zero group and READY A8");
  ++cases;
  x[0][0] = -0.0f;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && scale[0][0] == 0 && q[0][0][0] == 0,
           "negative zero amax and scale");
  ++cases;
  x[0][0] = 127.0f; x[0][1] = 0.5f; x[0][2] = -0.5f;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && scale[0][0] == 0x3c00 && q[0][0][0] == 127 &&
           q[0][0][1] == 1 && q[0][0][2] == -1,
           "ties away from zero");
  ++cases;
  nrequire(numeric_f32_to_half_rne(1.0f) == 0x3c00 &&
           numeric_f32_to_half_rne(1.00048828125f) == 0x3c00 &&
           numeric_f32_to_half_rne(1.00146484375f) == 0x3c02 &&
           numeric_f32_to_half_rne(std::ldexp(1.0f, -24)) == 1 &&
           numeric_f32_to_half_rne(std::ldexp(1.0f, -25)) == 0 &&
           numeric_f32_to_half_rne(65520.0f) == 0x7c00,
           "independent half boundary constants");
  ++cases;
  x[0][0] = 127.0f * std::ldexp(1.0f, -24);
  x[0][1] = x[0][2] = 0.0f;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && scale[0][0] == 1 && q[0][0][0] == 127,
           "FP16 subnormal scale");
  ++cases;
  x[0][0] = std::numeric_limits<float>::denorm_min();
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && scale[0][0] == 0 && q[0][0][0] == 0,
           "d_full underflow to zero");
  ++cases;
  x[0][0] = 127.0f * std::numeric_limits<float>::denorm_min();
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid,
           "reciprocal overflow rejects publication");
  ++cases;
  x[0][0] = 1e10f;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid,
           "FP16 overflow rejects publication");
  ++cases;
  x[0][0] = 0.0f;
  x[0][1023] = std::numeric_limits<float>::infinity();
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid, "last valid Inf");
  ++cases;
  x[0][1023] = 0.0f;
  F32TileMeta bad = src;
  bad.covered_groups[0][0] &= ~1u;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, bad, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "missing source group");
  ++cases;
  bad = src; bad.state = CacheState::FILL;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, bad, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "FILL source");
  ++cases;
  bad = src; ++bad.ref.epoch;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, bad, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "source epoch");
  ++cases;
  bad = src; ++bad.identity.request_id;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, bad, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "cross-request source");
  ++cases;
  bad = src; bad.identity.model_tag[0] ^= 1;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, bad, x, q, scale, out);
  nrequire(c.code == Status::E_MODEL && !out.valid, "model mismatch");
  ++cases;
  task.K = 256;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_SHAPE && !out.valid, "wrong task K");
  ++cases;
  task.K = 1024;
  out = A8TileMeta{};
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && out.valid, "recover after rejection");
  ++cases;
  const A8TileMeta published = out;
  const int8_t old_q = q[0][0][0];
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.ref == published.ref && q[0][0][0] == old_q,
           "READY A8 destination guard");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.valid && out.readers == 1 &&
           q[0][0][0] == old_q, "READ A8 destination guard");
  nrequire(numeric_release_a8(out).code == Status::E_BUFFER,
           "A8 reader prevents release");
  ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_a8(out)) && !out.valid &&
           out.ref.epoch == 1, "A8 release keeps epoch");
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 1,
           "old A8 epoch rejected");
  ++cases;
  task.a_dst.epoch = 2; task.ctx.task_id = 4;
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 2,
           "new A8 epoch accepted");
  ++cases;
  numeric_reset_a8(out);
  nrequire(!out.covered_groups[0][0], "reset clears A8 coverage");
  c = activation_quantizer_compute(task, id, src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 2 && !out.valid,
           "reset A8 epoch cannot revive");
  ++cases;
  NumericIdentity next = id; ++next.generation;
  task.a_dst.epoch = 3; task.ctx.task_id = 5;
  F32TileMeta next_src = test_source(next, task.src, 0, task.ctx, 1024);
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 3 &&
           out.identity.generation == next.generation,
           "new A8 generation uses next epoch");
  ++cases;
  const int8_t next_q = q[0][0][0];
  const uint16_t next_scale = scale[0][0];
  x[0][0] = 63.5f;
  F32TileMeta wrong_next_src = next_src;
  ++wrong_next_src.identity.request_id;
  c = activation_quantizer_compute(task, next, wrong_next_src,
                                   x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.state == CacheState::READY && out.ref.epoch == 3 &&
           q[0][0][0] == next_q && scale[0][0] == next_scale,
           "preclaim source error preserves published A8 and array");
  ++cases;
  wrong_next_src = next_src;
  wrong_next_src.identity.model_tag[0] ^= 1;
  c = activation_quantizer_compute(task, next, wrong_next_src,
                                   x, q, scale, out);
  nrequire(c.code == Status::E_MODEL && out.valid &&
           out.state == CacheState::READY && out.ref.epoch == 3 &&
           q[0][0][0] == next_q && scale[0][0] == next_scale,
           "preclaim model error preserves published A8 and array");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = activation_quantizer_compute(task, next, wrong_next_src,
                                   x, q, scale, out);
  nrequire(c.code == Status::E_MODEL && out.valid &&
           out.state == CacheState::READ && out.readers == 1 &&
           out.ref.epoch == 3 && q[0][0][0] == next_q,
           "preclaim model error preserves READ A8 owner");
  ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_a8(out)), "release A8 before failure epoch");
  task.a_dst.epoch = 4; task.ctx.task_id = 6;
  x[0][0] = 1e10f;
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid &&
           out.state == CacheState::INVALID && out.ref.epoch == 4,
           "A8 numerical failure consumes claimed epoch");
  ++cases;
  x[0][0] = 0.0f;
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid && out.ref.epoch == 4,
           "repaired quant input cannot reuse failed epoch");
  ++cases;
  task.a_dst.epoch = 5; task.ctx.task_id = 7;
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 5,
           "A8 recovers on next epoch after numerical failure");
  ++cases;
  nrequire(bool(numeric_release_a8(out)), "release A8 before FILL reservation");
  nrequire(bool(numeric_claim_a8(out, {Buffer::A8, 0, 6})) &&
           out.state == CacheState::FILL && out.ref.epoch == 6,
           "reserve A8 FILL epoch");
  numeric_reset_a8(out);
  nrequire(out.state == CacheState::INVALID && !out.valid &&
           out.ref.epoch == 6 && !out.covered_groups[0][0],
           "reset consumes A8 FILL reservation and clears coverage");
  task.a_dst.epoch = 6; task.ctx.task_id = 8;
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 6,
           "reset A8 FILL reservation cannot revive old epoch");
  ++cases;
  task.a_dst.epoch = 7; task.ctx.task_id = 9;
  c = activation_quantizer_compute(task, next, next_src, x, q, scale, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 7,
           "A8 accepts epoch after reset FILL reservation");
  ++cases;
  std::cout << "NUMERIC_QUANT_TB_PASS cases=" << cases << '\n';
}
