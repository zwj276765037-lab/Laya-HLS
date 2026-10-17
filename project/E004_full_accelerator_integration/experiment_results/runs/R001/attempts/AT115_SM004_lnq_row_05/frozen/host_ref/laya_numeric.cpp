#include "laya_numeric_tasks.h"
#include "laya_numeric_service_stats.h"

#include <cstring>

namespace laya {
#ifndef __SYNTHESIS__
NumericServiceStats& numeric_service_stats() {
  static NumericServiceStats stats;
  return stats;
}
void numeric_service_stats_reset() {
  numeric_service_stats() = NumericServiceStats{};
}
void numeric_service_stats_window(uint16_t K, uint16_t N) {
  NumericServiceStats& s = numeric_service_stats();
  ++s.tm4_owned_windows;
  const uint16_t shapes[7][2] = {{256,2},{1024,3072},{1024,1024},
      {1024,5248},{2624,1024},{1024,4096},{4096,1024}};
  for (unsigned i = 0; i < 7; ++i)
    if (K == shapes[i][0] && N == shapes[i][1]) ++s.tm4_shape_windows[i];
}
void numeric_service_stats_tm4_call(uint32_t active_mask) {
  NumericServiceStats& s = numeric_service_stats();
  ++s.tm4_group_calls;
  for (unsigned lane = 0; lane < 32; ++lane)
    s.tm4_active_lane_groups += (active_mask >> lane) & 1u;
}
#endif
namespace {
bool bytes_equal(const uint8_t* a, const uint8_t* b, unsigned n) {
  for (unsigned i = 0; i < n; ++i) if (a[i] != b[i]) return false;
  return true;
}
bool nonzero(const uint8_t* a, unsigned n) {
  for (unsigned i = 0; i < n; ++i) if (a[i]) return true;
  return false;
}
Check buffer_error(uint8_t object, uint16_t reason = 9) {
  return {Status::E_BUFFER, detail(4, object, reason)};
}
Check shape_error(uint8_t object, uint16_t reason = 5) {
  return {Status::E_SHAPE, detail(7, object, reason)};
}
bool model_equal(const NumericIdentity& a, const NumericIdentity& b) {
  return bytes_equal(a.model_tag, b.model_tag, 16);
}
bool row_equal(const F32TileMeta& a, const F32TileMeta& b) {
  return a.ref == b.ref && a.region == b.region &&
         a.row_space == b.row_space && a.batch == b.batch &&
         a.row0 == b.row0 && a.rows == b.rows && a.K == b.K &&
         a.state == b.state && a.content == b.content &&
         a.readers == b.readers && a.valid == b.valid;
}
bool owner_available(CacheState state, bool valid, uint8_t readers) {
  return !valid && readers == 0 &&
         (state == CacheState::FREE || state == CacheState::INVALID);
}
bool same_extent(const TaskContext& a, const TaskContext& b) {
  return a.batch == b.batch && a.row_space == b.row_space &&
         a.row0 == b.row0 && a.rows == b.rows;
}
bool next_epoch(BufferRef old_ref, BufferRef next_ref) {
  if (old_ref.id == Buffer::NONE)
    return old_ref.epoch == 0 && next_ref.epoch == 1;
  return old_ref.id == next_ref.id && old_ref.bank == next_ref.bank &&
         old_ref.epoch < kMaxEpoch && next_ref.epoch == old_ref.epoch + 1;
}
} // namespace

bool numeric_identity_valid(const NumericIdentity& x) {
  const bool legal_s = x.S == 64 || x.S == 128 || x.S == 256 ||
                       x.S == 512 || x.S == 1024;
  return x.request_id && x.generation && x.B >= 1 && x.B <= 2 && legal_s &&
         nonzero(x.model_tag, 16) && nonzero(x.numeric_tag, 16) &&
         nonzero(x.layout_tag, 16) && nonzero(x.build_tag, 16);
}

bool numeric_identity_equal(const NumericIdentity& a, const NumericIdentity& b) {
  return a.request_id == b.request_id && a.generation == b.generation &&
         a.B == b.B && a.S == b.S && model_equal(a, b) &&
         bytes_equal(a.numeric_tag, b.numeric_tag, 16) &&
         bytes_equal(a.layout_tag, b.layout_tag, 16) &&
         bytes_equal(a.build_tag, b.build_tag, 16);
}

bool numeric_source_equal(const F32TileMeta& a, const F32TileMeta& b) {
  if (!numeric_identity_equal(a.identity, b.identity) || !row_equal(a, b))
    return false;
  for (unsigned r = 0; r < 16; ++r)
    for (unsigned word = 0; word < 4; ++word)
      if (a.covered_groups[r][word] != b.covered_groups[r][word]) return false;
  return true;
}

bool numeric_binding_equal(const WeightBinding& a, const WeightBinding& b) {
  return bytes_equal(a.weight_sha256, b.weight_sha256, 32) &&
         a.weight_offset == b.weight_offset && a.weight_bytes == b.weight_bytes &&
         bytes_equal(a.bias_sha256, b.bias_sha256, 32) &&
         a.bias_offset == b.bias_offset && a.bias_bytes == b.bias_bytes;
}

bool numeric_coverage_complete(const uint32_t mask[][4], unsigned rows,
                               unsigned groups, unsigned capacity_rows) {
  if (!rows || rows > capacity_rows || groups > 128) return false;
  for (unsigned r = 0; r < capacity_rows; ++r) {
    for (unsigned w = 0; w < 4; ++w) {
      const unsigned first = w * 32;
      uint32_t expected = 0;
      if (r < rows && groups > first) {
        const unsigned count = groups - first >= 32 ? 32 : groups - first;
        expected = count == 32 ? UINT32_MAX : (uint32_t(1) << count) - 1u;
      }
      if (mask[r][w] != expected) return false;
    }
  }
  return true;
}

void numeric_cover_all(uint32_t mask[][4], unsigned rows, unsigned groups,
                       unsigned capacity_rows) {
  for (unsigned r = 0; r < capacity_rows; ++r)
    for (unsigned w = 0; w < 4; ++w) mask[r][w] = 0;
  if (rows > capacity_rows || groups > 128) return;
  for (unsigned r = 0; r < rows; ++r)
    for (unsigned g = 0; g < groups; ++g)
      mask[r][g / 32] |= uint32_t(1) << (g % 32);
}

Check numeric_check_context(const TaskContext& c, const NumericIdentity& id) {
  if (!numeric_identity_valid(id)) return {Status::E_MODEL, detail(4, 0, 4)};
  if (!c.task_id || c.task_id > kMaxEpoch || c.stage > 7 || c.rows < 1 ||
      c.rows > 16 || c.batch >= id.B) return shape_error(uint8_t(c.op));
  if (c.row_space == RowSpace::TOKEN) {
    if (uint32_t(c.row0) + c.rows > id.S) return shape_error(uint8_t(c.op));
  } else if (c.row_space == RowSpace::MARKER) {
    if (uint32_t(c.row0) + c.rows > 16) return shape_error(uint8_t(c.op));
  } else if (c.row_space == RowSpace::BATCH) {
    if (c.row0 || c.rows != 1) return shape_error(uint8_t(c.op));
  } else return shape_error(uint8_t(c.op));
  if (c.stage == 2 && (c.layer > 27 || c.row_space != RowSpace::TOKEN))
    return shape_error(uint8_t(c.op));
  if (c.stage == 4 && (c.layer > 1 || c.row_space != RowSpace::TOKEN))
    return shape_error(uint8_t(c.op));
  if (c.stage != 2 && c.stage != 4 && c.layer != 255)
    return shape_error(uint8_t(c.op));
  return ok();
}

Check numeric_check_ref(BufferRef r, uint8_t region) {
  if (r.id == Buffer::NONE) return buffer_error(0);
  const uint8_t id = uint8_t(r.id);
  if (!r.epoch || r.epoch > kMaxEpoch ||
      !((id >= 1 && id <= 11) || (id >= 0x20 && id <= 0x2b)))
    return buffer_error(id);
  const bool dual = id == 1 || id == 5 || (id >= 0x20 && id <= 0x2b);
  if (r.bank > (dual ? 1u : 0u) || (id == 10 ? region > 7 : region != 0))
    return buffer_error(id, 4);
  return ok();
}

Check numeric_check_weight(WeightKey w, uint8_t stage, uint8_t layer,
                           uint16_t K, uint16_t N) {
  const uint8_t f = w.family;
  uint16_t ek = 0, en = 0;
  switch (f) {
    case 1: case 5: ek = 1024; en = 3072; break;
    case 2: case 6: ek = 1024; en = 1024; break;
    case 3: ek = 1024; en = 5248; break;
    case 4: ek = 2624; en = 1024; break;
    case 7: ek = 1024; en = 4096; break;
    case 8: ek = 4096; en = 1024; break;
    case 9: ek = 1024; en = 1024; break;
    case 12: ek = 256; en = 2; break;
    default: return buffer_error(f, 4);
  }
  if (K != ek || N != en) return shape_error(f);
  if (f <= 4) {
    if (stage != 2 || layer > 27 || w.layer != layer) return buffer_error(f, 4);
  } else if (f <= 8) {
    if (stage != 4 || layer > 1 || w.layer != layer) return buffer_error(f, 4);
  } else {
    if (w.layer != 255 || layer != 255 || stage != (f == 9 ? 5 : 6))
      return buffer_error(f, 4);
  }
  return ok();
}

Check numeric_check_source(const F32TileMeta& src, const NumericIdentity& id,
                           BufferRef ref, uint8_t region, const TaskContext& c,
                           uint16_t K) {
  if (!model_equal(src.identity, id)) return {Status::E_MODEL, detail(4, 0, 4)};
  if (!numeric_identity_valid(src.identity) ||
      !numeric_identity_equal(src.identity, id) || !src.valid ||
      src.state != CacheState::READY || src.readers != 0 ||
      src.content != Content::F32 ||
      src.ref != ref || src.region != region ||
      src.row_space != c.row_space || src.batch != c.batch ||
      src.row0 != c.row0 || src.rows != c.rows || src.K != K ||
      !numeric_coverage_complete(src.covered_groups, c.rows, K / 32, 16))
    return buffer_error(uint8_t(ref.id));
  return numeric_check_ref(ref, region);
}

Check numeric_check_gamma(const GammaMeta& gamma, const NumericIdentity& id,
                          uint8_t kind) {
  if (kind == 0) return ok();
  if (!bytes_equal(gamma.model_tag, id.model_tag, 16))
    return {Status::E_MODEL, detail(4, 0, 4)};
  if (!gamma.valid || gamma.state != CacheState::READY ||
      gamma.ref.id != Buffer::LN_GAMMA || gamma.ref.bank != kind - 1 ||
      gamma.gamma_kind != kind || gamma.D != 1024 ||
      gamma.covered_groups != UINT32_MAX)
    return buffer_error(uint8_t(Buffer::LN_GAMMA));
  return numeric_check_ref(gamma.ref);
}

Check numeric_check_a8(const A8TileMeta& a, const NumericIdentity& id,
                       const LinearTask& task,
                       const F32TileMeta& expected_source) {
  if (!model_equal(a.identity, id) ||
      !model_equal(a.source.identity, id))
    return {Status::E_MODEL, detail(4, 0, 4)};
  Check c = numeric_check_source(expected_source, id, expected_source.ref,
                                 expected_source.region, task.ctx, task.K);
  if (!c) return c;
  const bool has_contexts = a.source_context.task_id || a.quant_context.task_id;
  if (!a.valid || a.state != CacheState::READY || a.content != Content::Q8_TILE ||
      a.readers != 0 ||
      !numeric_identity_equal(a.identity, id) || a.ref != task.a ||
      !numeric_source_equal(a.source, expected_source) ||
      !a.producer_task_id || a.producer_task_id >= task.ctx.task_id ||
      a.stage != task.ctx.stage || a.layer != task.ctx.layer ||
      a.row_space != task.ctx.row_space || a.batch != task.ctx.batch ||
      a.row0 != task.ctx.row0 || a.rows != task.ctx.rows || a.K != task.K ||
      (has_contexts &&
       (!check_context(a.source_context, id.B, id.S) ||
        !check_context(a.quant_context, id.B, id.S) ||
        a.quant_context.op != Op::QUANT ||
        a.quant_context.task_id != a.producer_task_id ||
        a.source_context.task_id >= a.quant_context.task_id ||
        a.quant_context.task_id >= task.ctx.task_id ||
        !same_extent(a.source_context, a.quant_context) ||
        a.quant_context.stage != task.ctx.stage ||
        a.quant_context.layer != task.ctx.layer ||
        !same_extent(a.quant_context, task.ctx))) ||
      !numeric_coverage_complete(a.covered_groups, task.ctx.rows,
                                 task.K / 32, 16))
    return buffer_error(uint8_t(task.a.id));
  return numeric_check_ref(task.a);
}

Check numeric_check_window(const WeightWindowMeta& w,
                           const NumericIdentity& id, const LinearTask& task,
                           const WeightBinding& expected, uint16_t n0,
                           uint8_t cols) {
  if (!model_equal(w.identity, id))
    return {Status::E_MODEL, detail(4, 0, 4)};
  if (!w.valid || w.state != CacheState::READY ||
      w.readers != 0 ||
      w.content != Content::Q8_WEIGHT ||
      !numeric_identity_equal(w.identity, id) || w.ref != task.w ||
      w.weight.family != task.weight.family ||
      w.weight.layer != task.weight.layer || w.K != task.K || w.N != task.N ||
      w.n0 != n0 || w.cols != cols || w.bias_kind != task.bias_kind ||
      !numeric_binding_equal(w.binding, expected) ||
      !numeric_coverage_complete(w.covered_groups, cols, task.K / 32, 8))
    return buffer_error(uint8_t(task.w.id));
  const uint32_t full_weight_bytes = uint32_t(task.N) * (task.K / 32u) * 34u;
  const uint32_t full_bias_bytes = uint32_t(task.N) * 4u;
  if (!nonzero(w.binding.weight_sha256, 32) ||
      w.binding.weight_bytes != full_weight_bytes ||
      w.binding.weight_offset > UINT64_MAX - w.binding.weight_bytes ||
      (task.bias_kind ?
       (!nonzero(w.binding.bias_sha256, 32) ||
        w.binding.bias_bytes != full_bias_bytes ||
        w.binding.bias_offset > UINT64_MAX - w.binding.bias_bytes) :
       (w.binding.bias_bytes != 0 ||
        nonzero(w.binding.bias_sha256, 32) || w.binding.bias_offset != 0)))
    return buffer_error(uint8_t(task.w.id));
  return numeric_check_ref(task.w);
}

Check numeric_claim_f32(F32TileMeta& owner, BufferRef next, uint8_t region) {
  if (!owner_available(owner.state, owner.valid, owner.readers) ||
      !next_epoch(owner.ref, next) ||
      (owner.ref.id != Buffer::NONE && owner.region != region))
    return buffer_error(uint8_t(next.id));
  owner = F32TileMeta{};
  owner.ref = next;
  owner.region = region;
  owner.state = CacheState::FILL;
  return ok();
}

Check numeric_claim_a8(A8TileMeta& owner, BufferRef next) {
  if (!owner_available(owner.state, owner.valid, owner.readers) ||
      !next_epoch(owner.ref, next))
    return buffer_error(uint8_t(next.id));
  owner = A8TileMeta{};
  owner.ref = next;
  owner.state = CacheState::FILL;
  return ok();
}

Check numeric_claim_window(NumericWindowResult& owner, BufferRef next_ps,
                           BufferRef next_dst, uint8_t dst_region) {
  if (!owner_available(owner.state, owner.valid, owner.readers) ||
      !next_epoch(owner.ps, next_ps) || !next_epoch(owner.dst, next_dst) ||
      (owner.dst.id != Buffer::NONE && owner.dst_region != dst_region))
    return buffer_error(uint8_t(next_dst.id));
  owner = NumericWindowResult{};
  owner.ps = next_ps;
  owner.dst = next_dst;
  owner.dst_region = dst_region;
  owner.state = CacheState::FILL;
  return ok();
}

Check numeric_release_f32(F32TileMeta& owner) {
  if (!owner.valid || owner.state != CacheState::READY || owner.readers)
    return buffer_error(uint8_t(owner.ref.id));
  owner.state = CacheState::FREE;
  owner.valid = false;
  return ok();
}
Check numeric_release_a8(A8TileMeta& owner) {
  if (!owner.valid || owner.state != CacheState::READY || owner.readers)
    return buffer_error(uint8_t(owner.ref.id));
  owner.state = CacheState::FREE;
  owner.valid = false;
  return ok();
}
Check numeric_release_window(NumericWindowResult& owner) {
  if (!owner.valid || owner.state != CacheState::READY || owner.readers)
    return buffer_error(uint8_t(owner.dst.id));
  owner.state = CacheState::FREE;
  owner.valid = false;
  return ok();
}
void numeric_reset_f32(F32TileMeta& owner) {
  owner.state = CacheState::INVALID; owner.valid = false; owner.readers = 0;
  for (unsigned r = 0; r < 16; ++r)
    for (unsigned word = 0; word < 4; ++word)
      owner.covered_groups[r][word] = 0;
}
void numeric_reset_a8(A8TileMeta& owner) {
  owner.state = CacheState::INVALID; owner.valid = false; owner.readers = 0;
  for (unsigned r = 0; r < 16; ++r)
    for (unsigned word = 0; word < 4; ++word)
      owner.covered_groups[r][word] = 0;
}
void numeric_reset_window(NumericWindowResult& owner) {
  owner.state = CacheState::INVALID; owner.valid = false; owner.readers = 0;
  owner.output_elements = 0; owner.output_beats = 0;
}

uint32_t numeric_f32_bits(float f) {
  uint32_t bits;
  std::memcpy(&bits, &f, sizeof(bits));
  return bits;
}
float numeric_bits_f32(uint32_t bits) {
  float f;
  std::memcpy(&f, &bits, sizeof(f));
  return f;
}

float numeric_half_to_f32(uint16_t h) {
  const uint32_t sign = uint32_t(h & 0x8000u) << 16;
  const uint32_t exp = (h >> 10) & 31u;
  uint32_t mant = h & 1023u;
  uint32_t bits;
  if (exp == 0) {
    if (!mant) bits = sign;
    else {
      int e = -14;
      for (unsigned step = 0; step < 10; ++step) {
        if (mant & 0x400u) break;
        mant <<= 1;
        --e;
      }
      bits = sign | (uint32_t(e + 127) << 23) | ((mant & 1023u) << 13);
    }
  } else if (exp == 31) bits = sign | 0x7f800000u | (mant << 13);
  else bits = sign | ((exp + 112u) << 23) | (mant << 13);
  return numeric_bits_f32(bits);
}

uint16_t numeric_f32_to_half_rne(float f) {
  const uint32_t bits = numeric_f32_bits(f);
  const uint16_t sign = uint16_t((bits >> 16) & 0x8000u);
  const uint32_t exponent = (bits >> 23) & 255u;
  uint32_t mantissa = bits & 0x7fffffu;
  if (exponent == 255u)
    return uint16_t(sign | (mantissa ? 0x7e00u : 0x7c00u));
  const int half_exp = int(exponent) - 127 + 15;
  if (half_exp >= 31) return uint16_t(sign | 0x7c00u);
  if (half_exp <= -11) return sign;
  if (half_exp <= 0) {
    mantissa |= 0x800000u;
    const unsigned shift = unsigned(14 - half_exp);
    uint32_t result = mantissa >> shift;
    const uint32_t remainder = mantissa & ((uint32_t(1) << shift) - 1u);
    const uint32_t halfway = uint32_t(1) << (shift - 1);
    if (remainder > halfway || (remainder == halfway && (result & 1u)))
      ++result;
    return uint16_t(sign | result);
  }
  uint32_t result = (uint32_t(half_exp) << 10) | (mantissa >> 13);
  const uint32_t remainder = mantissa & 0x1fffu;
  if (remainder > 0x1000u || (remainder == 0x1000u && (result & 1u)))
    ++result;
  return uint16_t(sign | result);
}

} // namespace laya
