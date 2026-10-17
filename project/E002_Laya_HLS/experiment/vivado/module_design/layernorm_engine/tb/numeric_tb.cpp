#include "numeric_test_support.h"

#include <limits>

using namespace laya;

int main() {
  int cases = 0;
  const NumericIdentity id = test_identity();
  LayerNormTask task;
  task.ctx = {1, Op::LN_FFN, 2, 0, 0, RowSpace::TOKEN, 0, 2};
  task.src = {Buffer::HIDDEN, 0, 1};
  task.dst = {Buffer::NORM, 0, 1};
  F32TileMeta src = test_source(id, task.src, 0, task.ctx, 1024);
  GammaMeta unused;
  static float x[16][1024], y[16][1024], gamma[1024];
  float mean[16] = {}, variance[16] = {}, inverse[16] = {};
  F32TileMeta out;
  for (unsigned i = 0; i < 1024; ++i) {
    x[0][i] = 3.0f;
    x[1][i] = (i & 1) ? -7.0f : 7.0f;
  }
  Check c = layernorm_compute(task, id, src, unused, x, gamma, y,
                              mean, variance, inverse, out);
  nrequire(bool(c) && out.valid && out.state == CacheState::READY, "LN publish");
  nrequire(numeric_f32_bits(mean[0]) == 0x40400000u &&
           numeric_f32_bits(variance[0]) == 0, "constant row statistics");
  for (unsigned i = 0; i < 1024; ++i)
    nrequire(numeric_f32_bits(y[0][i]) == 0, "constant row output");
  nrequire(numeric_f32_bits(mean[1]) == 0 && variance[1] == 49.0f,
           "cancellation row statistics");
  ++cases;

  F32TileMeta bad_src = src;
  bad_src.covered_groups[1][0] &= ~1u;
  out = F32TileMeta{};
  c = layernorm_compute(task, id, bad_src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "missing source coverage");
  ++cases;
  bad_src = src; ++bad_src.ref.epoch;
  out = F32TileMeta{};
  c = layernorm_compute(task, id, bad_src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "source epoch");
  ++cases;
  bad_src = src; ++bad_src.identity.generation;
  out = F32TileMeta{};
  c = layernorm_compute(task, id, bad_src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "source generation");
  ++cases;
  bad_src = src; bad_src.state = CacheState::READ;
  out = F32TileMeta{};
  c = layernorm_compute(task, id, bad_src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "source READ lock");
  ++cases;
  x[0][0] = std::numeric_limits<float>::quiet_NaN();
  out = F32TileMeta{};
  c = layernorm_compute(task, id, src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid, "first NaN");
  ++cases;
  x[0][0] = 3.0f;
  x[1][1023] = std::numeric_limits<float>::infinity();
  out = F32TileMeta{};
  c = layernorm_compute(task, id, src, unused, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid, "last Inf");
  ++cases;
  x[1][1023] = -7.0f;

  LayerNormTask emb = task;
  emb.ctx = {2, Op::LN_EMB, 1, 255, 0, RowSpace::TOKEN, 0, 1};
  emb.gamma = 1;
  F32TileMeta emb_src = test_source(id, emb.src, 0, emb.ctx, 1024);
  GammaMeta gm = test_gamma(id, 1);
  for (unsigned i = 0; i < 1024; ++i) gamma[i] = 1.25f;
  out = F32TileMeta{};
  c = layernorm_compute(emb, id, emb_src, gm, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(bool(c) && out.valid, "embedding gamma");
  ++cases;
  gm.gamma_kind = 2;
  out = F32TileMeta{};
  c = layernorm_compute(emb, id, emb_src, gm, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid, "gamma kind");
  ++cases;
  gm = test_gamma(id, 1); gm.model_tag[15] ^= 1;
  out = F32TileMeta{};
  c = layernorm_compute(emb, id, emb_src, gm, x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_MODEL && !out.valid, "gamma model identity");
  ++cases;
  emb.dst = emb.src;
  out = F32TileMeta{};
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(!c && !out.valid, "physical source/destination alias");
  ++cases;
  emb.dst = {Buffer::NORM, 0, 1};
  out = F32TileMeta{};
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(bool(c) && out.valid, "recover after rejection");
  ++cases;
  const F32TileMeta published = out;
  const uint32_t old_y = numeric_f32_bits(y[0][0]);
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.ref == published.ref && numeric_f32_bits(y[0][0]) == old_y,
           "READY destination stays published on busy rejection");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.valid && out.readers == 1 &&
           numeric_f32_bits(y[0][0]) == old_y, "READ destination guard");
  nrequire(numeric_release_f32(out).code == Status::E_BUFFER,
           "cannot release with reader");
  ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_f32(out)) && !out.valid &&
           out.ref.epoch == 1, "release retains epoch");
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 1 &&
           out.state == CacheState::FREE, "stale destination epoch");
  ++cases;
  emb.dst.epoch = 2; emb.ctx.task_id = 3;
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 2,
           "legal new destination epoch");
  ++cases;
  numeric_reset_f32(out);
  nrequire(!out.valid && out.ref.epoch == 2 &&
           out.state == CacheState::INVALID &&
           !out.covered_groups[0][0], "reset clears coverage but keeps epoch");
  c = layernorm_compute(emb, id, emb_src, test_gamma(id, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 2,
           "reset cannot revive old epoch");
  ++cases;
  NumericIdentity next = id; ++next.generation;
  emb.dst.epoch = 3; emb.ctx.task_id = 4;
  F32TileMeta next_src = test_source(next, emb.src, 0, emb.ctx, 1024);
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1), x, gamma, y,
                        mean, variance, inverse, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 3 &&
           out.identity.generation == next.generation,
           "new generation requires monotonic epoch");
  ++cases;
  const uint32_t next_y = numeric_f32_bits(y[0][0]);
  F32TileMeta wrong_next_src = next_src;
  ++wrong_next_src.identity.request_id;
  c = layernorm_compute(emb, next, wrong_next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.state == CacheState::READY && out.ref.epoch == 3 &&
           numeric_f32_bits(y[0][0]) == next_y,
           "preclaim source error preserves published LN owner and array");
  ++cases;
  GammaMeta wrong_model = test_gamma(next, 1);
  wrong_model.model_tag[0] ^= 1;
  c = layernorm_compute(emb, next, next_src, wrong_model,
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_MODEL && out.valid &&
           out.state == CacheState::READY && out.ref.epoch == 3 &&
           numeric_f32_bits(y[0][0]) == next_y,
           "preclaim model error preserves published LN owner and array");
  ++cases;
  out.state = CacheState::READ; out.readers = 1;
  c = layernorm_compute(emb, next, wrong_next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.valid &&
           out.state == CacheState::READ && out.readers == 1 &&
           out.ref.epoch == 3 && numeric_f32_bits(y[0][0]) == next_y,
           "preclaim source error preserves READ LN owner");
  ++cases;
  out.state = CacheState::READY; out.readers = 0;
  nrequire(bool(numeric_release_f32(out)), "release LN before failure epoch");
  emb.dst.epoch = 4; emb.ctx.task_id = 5;
  x[0][0] = std::numeric_limits<float>::quiet_NaN();
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_NUMERICAL && !out.valid &&
           out.state == CacheState::INVALID && out.ref.epoch == 4,
           "LN numerical failure consumes claimed epoch");
  ++cases;
  x[0][0] = 3.0f;
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && !out.valid && out.ref.epoch == 4,
           "repaired LN input cannot reuse failed epoch");
  ++cases;
  emb.dst.epoch = 5; emb.ctx.task_id = 6;
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 5,
           "LN recovers on next epoch after numerical failure");
  ++cases;
  nrequire(bool(numeric_release_f32(out)), "release LN before FILL reservation");
  nrequire(bool(numeric_claim_f32(out, {Buffer::NORM, 0, 6}, 0)) &&
           out.state == CacheState::FILL && out.ref.epoch == 6,
           "reserve LN FILL epoch");
  numeric_reset_f32(out);
  nrequire(out.state == CacheState::INVALID && !out.valid &&
           out.ref.epoch == 6 && !out.covered_groups[0][0],
           "reset consumes LN FILL reservation and clears coverage");
  emb.dst.epoch = 6; emb.ctx.task_id = 7;
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(c.code == Status::E_BUFFER && out.ref.epoch == 6,
           "reset LN FILL reservation cannot revive old epoch");
  ++cases;
  emb.dst.epoch = 7; emb.ctx.task_id = 8;
  c = layernorm_compute(emb, next, next_src, test_gamma(next, 1),
                        x, gamma, y, mean, variance, inverse, out);
  nrequire(bool(c) && out.valid && out.ref.epoch == 7,
           "LN accepts epoch after reset FILL reservation");
  ++cases;

  // These bit patterns were fixed by the independent NumPy adjacent-tree
  // oracle, including a large offset and binary32 subnormal inputs.
  LayerNormTask edge = task;
  edge.ctx = {9, Op::LN_FFN, 2, 0, 0, RowSpace::TOKEN, 0, 1};
  edge.dst = {Buffer::NORM, 0, 1};
  F32TileMeta edge_src = test_source(id, edge.src, 0, edge.ctx, 1024);
  F32TileMeta edge_out;
  for (unsigned i = 0; i < 1024; ++i)
    x[0][i] = (i & 1) ? 1048576.25f : 1048576.0f;
  c = layernorm_compute(edge, id, edge_src, unused, x, gamma, y,
                        mean, variance, inverse, edge_out);
  nrequire(bool(c) && edge_out.valid &&
           numeric_f32_bits(mean[0]) == 0x49800001u &&
           numeric_f32_bits(variance[0]) == 0x3c800000u &&
           numeric_f32_bits(inverse[0]) == 0x40ffeb0au,
           "large-offset near-constant LN statistics oracle bits");
  for (unsigned i = 0; i < 1024; ++i)
    nrequire(numeric_f32_bits(y[0][i]) ==
                 ((i & 1) ? 0x3f7feb0au : 0xbf7feb0au),
             "large-offset near-constant LN output oracle bits");
  ++cases;
  nrequire(bool(numeric_release_f32(edge_out)), "release LN edge owner");
  edge.dst.epoch = 2; edge.ctx.task_id = 10;
  for (unsigned i = 0; i < 1024; ++i)
    x[0][i] = (i & 1) ? -std::numeric_limits<float>::denorm_min() :
                       std::numeric_limits<float>::denorm_min();
  c = layernorm_compute(edge, id, edge_src, unused, x, gamma, y,
                        mean, variance, inverse, edge_out);
  nrequire(bool(c) && edge_out.valid && edge_out.ref.epoch == 2 &&
           numeric_f32_bits(mean[0]) == 0 &&
           numeric_f32_bits(variance[0]) == 0 &&
           numeric_f32_bits(inverse[0]) == 0x439e1d28u,
           "subnormal LN statistics oracle bits");
  for (unsigned i = 0; i < 1024; ++i)
    nrequire(numeric_f32_bits(y[0][i]) ==
                 ((i & 1) ? 0x8000013cu : 0x0000013cu),
             "subnormal LN output oracle bits");
  ++cases;

  F32TileMeta max_owner;
  max_owner.ref = {Buffer::NORM, 0, kMaxEpoch};
  max_owner.state = CacheState::FREE;
  nrequire(numeric_claim_f32(max_owner, {Buffer::NORM, 0, 1}, 0).code ==
               Status::E_BUFFER && max_owner.ref.epoch == kMaxEpoch &&
           max_owner.state == CacheState::FREE,
           "owner epoch cannot wrap at kMaxEpoch");
  ++cases;
  std::cout << "NUMERIC_LN_TB_PASS cases=" << cases << '\n';
}
