#include "laya_full_runtime.h"

namespace laya::full {
namespace {
Check error(Buffer id, uint16_t reason = 9) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), reason)};
}
Check protocol(uint16_t reason = 4) {
  return {Status::E_PROTOCOL, detail(7, 0, reason)};
}
bool same_physical(BufferRef a, uint8_t ar, BufferRef b, uint8_t br) {
  if (ar != br) return false;
  if (a.id == Buffer::ROPE_TABLE && b.id == Buffer::ROPE_TABLE)
    return true; // one current-mode table; mode bank is a logical label.
  if (a.bank != b.bank) return false;
  if (a.id == b.id) return true;
  return (a.id == Buffer::WI && b.id == Buffer::DEC_FF) ||
         (a.id == Buffer::DEC_FF && b.id == Buffer::WI);
}
bool same_spec(const FullOwnerRecord& r, const FullOwnerSpec& s) {
  return r.ref == s.ref && r.region == s.region && r.stage == s.stage &&
         r.layer == s.layer && r.batch == s.batch &&
         r.row_space == s.row_space && r.row0 == s.row0 &&
         r.rows == s.rows && r.width == s.width && r.content == s.content;
}
uint16_t legal_width(Buffer id, uint8_t region) {
  switch (id) {
    case Buffer::HIDDEN: case Buffer::NORM: case Buffer::TMP:
    case Buffer::MARKER: case Buffer::ATT_OUT: case Buffer::TYPE_ROWS:
    case Buffer::LN_ROW: case Buffer::LN_GAMMA: return 1024;
    case Buffer::WI: return 5248;
    case Buffer::GATE: return 2624;
    case Buffer::DEC_FF: return 4096;
    case Buffer::QKV: case Buffer::KV: case Buffer::Q_TILE:
    case Buffer::AV_PARTIAL: case Buffer::ROPE_HEAD: return 64;
    case Buffer::HEAD_WORK: {
      constexpr uint16_t widths[8] = {1024, 1028, 256, 16, 2, 4, 16, 16};
      if (region == uint8_t(Region::CAND_RAW)) return 0;
      return region < 8 ? widths[region] : 0;
    }
    case Buffer::SCORE_PROB: return 0; // logical width is the request S.
    case Buffer::ROPE_TABLE: return 64;
    default: return 0; // A8, PS, WEIGHT, QUANT_INPUT vary by operator.
  }
}
bool legal_spec(const FullRuntime& rt, const FullOwnerSpec& s) {
  if (!check_ref(s.ref, s.region) || s.ref.id == Buffer::NONE ||
      !numeric_identity_valid(rt.inputs.identity) ||
      s.stage > 7 || s.rows == 0 || s.width == 0 || s.width > 5248)
    return false;
  const uint8_t id = uint8_t(s.ref.id);
  if (id >= uint8_t(Buffer::LN_ROW) &&
      id <= uint8_t(Buffer::ROPE_HEAD) && s.ref.bank != 0)
    return false;
  const uint16_t fixed = legal_width(s.ref.id, s.region);
  if (fixed && s.width != fixed) return false;
  if (s.ref.id == Buffer::SCORE_PROB && s.width != rt.inputs.identity.S)
    return false;
  if (s.ref.id == Buffer::HEAD_WORK &&
      s.region == uint8_t(Region::CAND_RAW) &&
      !(s.row_space == RowSpace::MARKER && s.width == 1 &&
        s.row0 == 0 && s.rows == 16)) return false;
  const uint16_t extent = s.row_space == RowSpace::TOKEN ? rt.inputs.identity.S :
                          s.row_space == RowSpace::MARKER ? 16 :
                          s.row_space == RowSpace::BATCH ? 3 : 0;
  if (!extent || uint32_t(s.row0) + s.rows > extent ||
      (s.batch != 255 && s.batch >= rt.inputs.identity.B)) return false;
  if (s.ref.id == Buffer::TYPE_ROWS)
    return s.batch == 0 && s.row_space == RowSpace::BATCH &&
           s.row0 == 0 && s.rows == 3;
  if (s.ref.id == Buffer::ATT_OUT)
    return s.batch == 255 && s.row_space == RowSpace::TOKEN &&
           s.row0 == 0 && s.rows == rt.inputs.identity.S;
  if (s.ref.id == Buffer::WEIGHT || s.ref.id == Buffer::LN_GAMMA ||
      s.ref.id == Buffer::ROPE_TABLE)
    return s.batch == 0 && s.row_space == RowSpace::BATCH &&
           s.row0 == 0 && s.rows == 1;
  if (s.row_space == RowSpace::BATCH)
    return s.row0 == 0 && s.rows == 1;
  return true;
}
unsigned bit_index(const FullOwnerSpec& s, uint8_t batch, uint16_t row) {
  if (s.ref.id == Buffer::TYPE_ROWS) return row;
  const unsigned stride = s.row_space == RowSpace::TOKEN ? 1024 :
                          s.row_space == RowSpace::MARKER ? 16 : 1;
  return unsigned(batch) * stride + row;
}
bool in_scope(const FullRuntime& rt, const FullOwnerSpec& s,
              uint8_t batch, uint16_t row0, uint16_t rows) {
  if (!rows || batch >= rt.inputs.identity.B ||
      (s.batch != 255 && s.batch != batch) ||
      row0 < s.row0 || uint32_t(row0) + rows > uint32_t(s.row0) + s.rows)
    return false;
  if (s.ref.id == Buffer::TYPE_ROWS && batch != 0) return false;
  return true;
}
bool bit(const uint32_t bits[64], unsigned index) {
  return (bits[index / 32] >> (index % 32)) & 1u;
}
void set_bit(uint32_t bits[64], unsigned index) {
  bits[index / 32] |= uint32_t(1) << (index % 32);
}
bool covered(const FullRuntime& rt, const FullOwnerSpec& s,
             const uint32_t bits[64]) {
  const uint8_t first = s.batch == 255 ? 0 : s.batch;
  const uint8_t last = s.batch == 255 ? rt.inputs.identity.B : uint8_t(first + 1);
  for (uint8_t b = first; b < last; ++b) {
    for (uint16_t row = s.row0; row < uint32_t(s.row0) + s.rows; ++row) {
      if (!bit(bits, bit_index(s, b, row))) return false;
    }
  }
  return true;
}
constexpr unsigned kNoOwnerIndex = 32;
unsigned find_index(const FullRuntime& rt, BufferRef ref, uint8_t region) {
  for (unsigned i = 0; i < kNoOwnerIndex; ++i) {
    const FullOwnerRecord& r = rt.owners.record[i];
    if (r.ref.id != Buffer::NONE && same_physical(r.ref, r.region, ref, region))
      return i;
  }
  return kNoOwnerIndex;
}
unsigned empty_index(const FullRuntime& rt, unsigned excluded = kNoOwnerIndex) {
  for (unsigned i = 0; i < kNoOwnerIndex; ++i)
    if (i != excluded && rt.owners.record[i].ref.id == Buffer::NONE) return i;
  return kNoOwnerIndex;
}
void clear_bits(uint32_t bits[64]) {
  for (unsigned i = 0; i < 64; ++i) bits[i] = 0;
}
unsigned claim_index(const FullRuntime& rt, const FullOwnerSpec& s) {
  unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) index = empty_index(rt);
  if (index == kNoOwnerIndex) return kNoOwnerIndex;
  const FullOwnerRecord& r = rt.owners.record[index];
  if (r.valid || r.readers ||
      (r.state != CacheState::FREE && r.state != CacheState::INVALID) ||
      r.max_claimed_epoch >= kMaxEpoch ||
      s.ref.epoch != r.max_claimed_epoch + 1) return kNoOwnerIndex;
  return index;
}
void fill_record(FullOwnerRecord& r, const FullOwnerSpec& s,
                 const NumericIdentity& identity) {
  r.identity = identity;
  r.ref = s.ref;
  r.lease_old_ref = none();
  r.max_claimed_epoch = s.ref.epoch;
  r.region = s.region; r.stage = s.stage; r.layer = s.layer;
  r.batch = s.batch; r.row_space = s.row_space;
  r.row0 = s.row0; r.rows = s.rows; r.width = s.width;
  r.content = s.content; r.state = CacheState::FILL;
  r.readers = 0; r.valid = false;
  clear_bits(r.covered_rows);
  clear_bits(r.old_consumed_rows);
}
bool all_rows(const uint32_t bits[32], uint16_t S) {
  for (uint16_t row = 0; row < S; ++row)
    if (!(bits[row / 32] & (uint32_t(1) << (row % 32)))) return false;
  return true;
}
bool qkv_pair_specs(const FullRuntime& rt, const FullOwnerSpec (&s)[2]) {
  return legal_spec(rt, s[0]) && legal_spec(rt, s[1]) &&
         s[0].ref.id == Buffer::QKV && s[1].ref.id == Buffer::QKV &&
         s[0].ref.bank == 0 && s[1].ref.bank == 1 &&
         s[0].region == 0 && s[1].region == 0 &&
         s[0].batch == 255 && s[1].batch == 255 &&
         s[0].row_space == RowSpace::TOKEN &&
         s[1].row_space == RowSpace::TOKEN &&
         s[0].row0 == 0 && s[1].row0 == 0 &&
         s[0].rows == rt.inputs.identity.S &&
         s[1].rows == rt.inputs.identity.S &&
         s[0].stage == s[1].stage && s[0].layer == s[1].layer &&
         s[0].width == 64 && s[1].width == 64 &&
         s[0].content == s[1].content &&
         ((s[0].stage == 2 && s[0].content == Content::QKV_RAW) ||
          (s[0].stage == 4 && s[0].content == Content::QKV_FINAL));
}
bool qkv_rope_specs(const FullRuntime& rt,
                    const FullOwnerSpec (&old_s)[2],
                    const FullOwnerSpec (&next_s)[2]) {
  if (!qkv_pair_specs(rt, old_s) || old_s[0].stage != 2 ||
      old_s[0].content != Content::QKV_RAW) return false;
  for (unsigned shard = 0; shard < 2; ++shard) {
    const FullOwnerSpec& a = old_s[shard];
    const FullOwnerSpec& b = next_s[shard];
    if (!legal_spec(rt, b) || b.ref.id != Buffer::QKV ||
        b.ref.bank != shard || b.ref.epoch != a.ref.epoch + 1 ||
        b.region != a.region || b.stage != a.stage || b.layer != a.layer ||
        b.batch != a.batch || b.row_space != a.row_space ||
        b.row0 != a.row0 || b.rows != a.rows || b.width != a.width ||
        b.content != Content::QKV_FINAL) return false;
  }
  return true;
}
} // namespace

Check full_claim_owner(FullRuntime& rt, const FullOwnerSpec& s) {
  if (!rt.request_valid || !rt.model_header_valid) return protocol();
  if (!legal_spec(rt, s) || s.ref.id == Buffer::QKV)
    return error(s.ref.id, 5);
  const unsigned index = claim_index(rt, s);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  fill_record(rt.owners.record[index], s, rt.inputs.identity);
  ++rt.owner_claims;
  if (s.ref.id == Buffer::TYPE_ROWS)
    for (bool& v : rt.owners.type_valid) v = false;
  if (s.ref.id == Buffer::ATT_OUT)
    for (auto& head : rt.owners.att_head_rows)
      for (auto& batch : head)
        for (uint32_t& word : batch) word = 0;
  return ok();
}

Check full_check_fill_owner(const FullRuntime& rt, const FullOwnerSpec& s) {
  if (!rt.request_valid || !rt.model_header_valid || !legal_spec(rt, s))
    return error(s.ref.id);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  const FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::FILL ||
      !numeric_identity_equal(r.identity, rt.inputs.identity))
    return error(s.ref.id);
  return ok();
}

Check full_check_uncovered_owner(const FullRuntime& rt,
                                 const FullOwnerSpec& s, uint8_t batch,
                                 uint16_t row0, uint16_t rows) {
  Check c = full_check_fill_owner(rt, s);
  if (!c || !in_scope(rt, s, batch, row0, rows)) return error(s.ref.id);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  const FullOwnerRecord& r = rt.owners.record[index];
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    if (bit(r.covered_rows, bit_index(s, batch, row)))
      return error(s.ref.id);
  return ok();
}

Check full_check_uncovered_qkv(const FullRuntime& rt,
                               const FullOwnerSpec (&s)[2], uint8_t batch,
                               uint16_t row0, uint16_t rows) {
  if (!qkv_pair_specs(rt, s) || batch >= rt.inputs.identity.B ||
      !rows || uint32_t(row0) + rows > rt.inputs.identity.S)
    return error(Buffer::QKV, 5);
  Check c = full_check_fill_owner(rt, s[0]);
  if (c) c = full_check_fill_owner(rt, s[1]);
  if (!c) return c;
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
        if (rt.owners.qkv_plane_head_rows[head % 2][plane][head][batch]
                                         [row / 32] &
            (uint32_t(1) << (row % 32)))
          return error(Buffer::QKV);
  return ok();
}

Check full_claim_qkv_pair(FullRuntime& rt, const FullOwnerSpec (&s)[2]) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !qkv_pair_specs(rt, s)) return error(Buffer::QKV, 5);
  const unsigned first = claim_index(rt, s[0]);
  unsigned second = claim_index(rt, s[1]);
  if (first != kNoOwnerIndex && second == first &&
      rt.owners.record[first].ref.id == Buffer::NONE)
    second = empty_index(rt, first);
  if (first == kNoOwnerIndex || second == kNoOwnerIndex || first == second)
    return error(Buffer::QKV);
  fill_record(rt.owners.record[first], s[0], rt.inputs.identity);
  fill_record(rt.owners.record[second], s[1], rt.inputs.identity);
  rt.owner_claims += 2;
  for (auto& shard : rt.owners.qkv_plane_head_rows)
    for (auto& plane : shard)
      for (auto& head : plane)
        for (auto& batch : head)
          for (uint32_t& word : batch) word = 0;
  for (auto& shard : rt.owners.qkv_rope_rows)
    for (auto& plane : shard)
      for (auto& head : plane)
        for (auto& batch : head)
          for (uint32_t& word : batch) word = 0;
  return ok();
}

Check full_cover_qkv(FullRuntime& rt, const FullOwnerSpec (&s)[2],
                     uint8_t plane, uint8_t head, uint8_t batch,
                     uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid || !qkv_pair_specs(rt, s) ||
      plane >= 3 ||
      head >= 16 || batch >= rt.inputs.identity.B || !rows ||
      uint32_t(row0) + rows > rt.inputs.identity.S) return error(Buffer::QKV, 5);
  for (unsigned shard = 0; shard < 2; ++shard) {
    const unsigned index = find_index(rt, s[shard].ref, 0);
    if (index == kNoOwnerIndex) return error(Buffer::QKV);
    const FullOwnerRecord& r = rt.owners.record[index];
    if (!same_spec(r, s[shard]) || r.state != CacheState::FILL ||
        !numeric_identity_equal(r.identity, rt.inputs.identity))
      return error(Buffer::QKV);
  }
  uint32_t (&bits)[32] = rt.owners.qkv_plane_head_rows[head % 2][plane][head][batch];
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    if (bits[row / 32] & (uint32_t(1) << (row % 32)))
      return error(Buffer::QKV);
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    bits[row / 32] |= uint32_t(1) << (row % 32);
  return ok();
}

Check full_publish_qkv_pair(FullRuntime& rt, const FullOwnerSpec (&s)[2]) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !qkv_pair_specs(rt, s)) return error(Buffer::QKV);
  const unsigned first_index = find_index(rt, s[0].ref, 0);
  const unsigned second_index = find_index(rt, s[1].ref, 0);
  if (first_index == kNoOwnerIndex || second_index == kNoOwnerIndex)
    return error(Buffer::QKV);
  FullOwnerRecord& first = rt.owners.record[first_index];
  FullOwnerRecord& second = rt.owners.record[second_index];
  if (!same_spec(first, s[0]) || !same_spec(second, s[1]) ||
      first.state != CacheState::FILL || second.state != CacheState::FILL ||
      !numeric_identity_equal(first.identity, rt.inputs.identity) ||
      !numeric_identity_equal(second.identity, rt.inputs.identity))
    return error(Buffer::QKV);
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
        if (!all_rows(rt.owners.qkv_plane_head_rows[head % 2][plane][head][batch],
                      rt.inputs.identity.S)) return error(Buffer::QKV);
  for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
    for (unsigned row = 0; row < rt.inputs.identity.S; ++row) {
      set_bit(first.covered_rows, batch * 1024 + row);
      set_bit(second.covered_rows, batch * 1024 + row);
    }
  first.state = CacheState::READY;
  first.valid = true;
  second.state = CacheState::READY;
  second.valid = true;
  if (s[0].content == Content::QKV_FINAL) {
    rt.final_qkv_ref[0] = s[0].ref;
    rt.final_qkv_ref[1] = s[1].ref;
  }
  return ok();
}

Check full_begin_qkv_rope_pair(FullRuntime& rt,
                               const FullOwnerSpec (&old_s)[2],
                               const FullOwnerSpec (&next_s)[2]) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !qkv_rope_specs(rt, old_s, next_s)) return error(Buffer::QKV, 5);
  const unsigned first_index = find_index(rt, old_s[0].ref, 0);
  const unsigned second_index = find_index(rt, old_s[1].ref, 0);
  if (first_index == kNoOwnerIndex || second_index == kNoOwnerIndex)
    return error(Buffer::QKV);
  FullOwnerRecord& first = rt.owners.record[first_index];
  FullOwnerRecord& second = rt.owners.record[second_index];
  if (!same_spec(first, old_s[0]) || !same_spec(second, old_s[1]) ||
      !first.valid || !second.valid ||
      first.state != CacheState::READY || second.state != CacheState::READY ||
      first.readers || second.readers ||
      first.max_claimed_epoch >= kMaxEpoch ||
      second.max_claimed_epoch >= kMaxEpoch ||
      !numeric_identity_equal(first.identity, rt.inputs.identity) ||
      !numeric_identity_equal(second.identity, rt.inputs.identity) ||
      !covered(rt, old_s[0], first.covered_rows) ||
      !covered(rt, old_s[1], second.covered_rows))
    return error(Buffer::QKV);
  first.lease_old_ref = old_s[0].ref;
  first.ref = next_s[0].ref;
  first.max_claimed_epoch = next_s[0].ref.epoch;
  first.content = Content::QKV_FINAL;
  first.state = CacheState::EXCLUSIVE_RW;
  first.valid = false;
  clear_bits(first.covered_rows);
  clear_bits(first.old_consumed_rows);
  second.lease_old_ref = old_s[1].ref;
  second.ref = next_s[1].ref;
  second.max_claimed_epoch = next_s[1].ref.epoch;
  second.content = Content::QKV_FINAL;
  second.state = CacheState::EXCLUSIVE_RW;
  second.valid = false;
  clear_bits(second.covered_rows);
  clear_bits(second.old_consumed_rows);
  rt.owner_leases += 2;
  for (auto& shard : rt.owners.qkv_rope_rows)
    for (auto& plane : shard)
      for (auto& head : plane)
        for (auto& batch : head)
          for (uint32_t& word : batch) word = 0;
  return ok();
}

Check full_cover_qkv_rope(FullRuntime& rt,
                          const FullOwnerSpec (&next_s)[2],
                          uint8_t head, uint8_t batch,
                          uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid || head >= 16 ||
      batch >= rt.inputs.identity.B || !rows ||
      uint32_t(row0) + rows > rt.inputs.identity.S)
    return error(Buffer::QKV, 5);
  for (unsigned shard = 0; shard < 2; ++shard) {
    const unsigned index = find_index(rt, next_s[shard].ref, 0);
    if (index == kNoOwnerIndex) return error(Buffer::QKV);
    const FullOwnerRecord& r = rt.owners.record[index];
    if (!same_spec(r, next_s[shard]) ||
        r.state != CacheState::EXCLUSIVE_RW ||
        r.lease_old_ref.id != Buffer::QKV ||
        r.content != Content::QKV_FINAL ||
        !numeric_identity_equal(r.identity, rt.inputs.identity))
      return error(Buffer::QKV);
  }
  if (next_s[0].ref.bank != 0 || next_s[1].ref.bank != 1 ||
      next_s[0].stage != 2 || next_s[1].stage != 2)
    return error(Buffer::QKV, 5);
  for (unsigned plane = 0; plane < 2; ++plane) {
    uint32_t (&bits)[32] = rt.owners.qkv_rope_rows[head % 2][plane][head][batch];
    for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
      if (bits[row / 32] & (uint32_t(1) << (row % 32)))
        return error(Buffer::QKV);
  }
  for (unsigned plane = 0; plane < 2; ++plane) {
    uint32_t (&bits)[32] = rt.owners.qkv_rope_rows[head % 2][plane][head][batch];
    for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
      bits[row / 32] |= uint32_t(1) << (row % 32);
  }
  return ok();
}

Check full_commit_qkv_rope_pair(FullRuntime& rt,
                                const FullOwnerSpec (&next_s)[2]) {
  if (!rt.request_valid || !rt.model_header_valid ||
      next_s[0].ref.id != Buffer::QKV ||
      next_s[1].ref.id != Buffer::QKV ||
      next_s[0].ref.bank != 0 || next_s[1].ref.bank != 1 ||
      next_s[0].content != Content::QKV_FINAL ||
      next_s[1].content != Content::QKV_FINAL)
    return error(Buffer::QKV, 5);
  const unsigned first_index = find_index(rt, next_s[0].ref, 0);
  const unsigned second_index = find_index(rt, next_s[1].ref, 0);
  if (first_index == kNoOwnerIndex || second_index == kNoOwnerIndex)
    return error(Buffer::QKV);
  FullOwnerRecord& first = rt.owners.record[first_index];
  FullOwnerRecord& second = rt.owners.record[second_index];
  if (!same_spec(first, next_s[0]) || !same_spec(second, next_s[1]) ||
      first.state != CacheState::EXCLUSIVE_RW ||
      second.state != CacheState::EXCLUSIVE_RW ||
      first.lease_old_ref.id != Buffer::QKV ||
      second.lease_old_ref.id != Buffer::QKV ||
      !numeric_identity_equal(first.identity, rt.inputs.identity) ||
      !numeric_identity_equal(second.identity, rt.inputs.identity))
    return error(Buffer::QKV);
  for (unsigned plane = 0; plane < 2; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
        if (!all_rows(rt.owners.qkv_rope_rows[head % 2][plane][head][batch],
                      rt.inputs.identity.S)) return error(Buffer::QKV);
  for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
    for (unsigned row = 0; row < rt.inputs.identity.S; ++row) {
      set_bit(first.covered_rows, batch * 1024 + row);
      set_bit(second.covered_rows, batch * 1024 + row);
    }
  first.state = CacheState::READY;
  first.valid = true;
  first.lease_old_ref = none();
  second.state = CacheState::READY;
  second.valid = true;
  second.lease_old_ref = none();
  rt.final_qkv_ref[0] = next_s[0].ref;
  rt.final_qkv_ref[1] = next_s[1].ref;
  return ok();
}

Check full_cover_att_head(FullRuntime& rt, const FullOwnerSpec& s,
                          uint8_t head, uint8_t batch,
                          uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid || head >= 16 ||
      batch >= rt.inputs.identity.B || !rows ||
      uint32_t(row0) + rows > rt.inputs.identity.S ||
      s.ref.id != Buffer::ATT_OUT) return error(Buffer::ATT_OUT, 5);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(Buffer::ATT_OUT);
  const FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::FILL ||
      !numeric_identity_equal(r.identity, rt.inputs.identity))
    return error(Buffer::ATT_OUT);
  uint32_t (&bits)[32] = rt.owners.att_head_rows[head][batch];
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    if (bits[row / 32] & (uint32_t(1) << (row % 32)))
      return error(Buffer::ATT_OUT);
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    bits[row / 32] |= uint32_t(1) << (row % 32);
  return ok();
}

Check full_publish_att(FullRuntime& rt, const FullOwnerSpec& s) {
  if (!rt.request_valid || !rt.model_header_valid ||
      s.ref.id != Buffer::ATT_OUT) return error(Buffer::ATT_OUT);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(Buffer::ATT_OUT);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::FILL ||
      !numeric_identity_equal(r.identity, rt.inputs.identity))
    return error(Buffer::ATT_OUT);
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
      if (!all_rows(rt.owners.att_head_rows[head][batch], rt.inputs.identity.S))
        return error(Buffer::ATT_OUT);
  for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
    for (unsigned row = 0; row < rt.inputs.identity.S; ++row)
      set_bit(r.covered_rows, batch * 1024 + row);
  r.state = CacheState::READY;
  r.valid = true;
  return ok();
}

Check full_require_owner(const FullRuntime& rt, const FullOwnerSpec& s,
                         uint8_t batch, uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !legal_spec(rt, s) || !in_scope(rt, s, batch, row0, rows))
    return error(s.ref.id);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  const FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) ||
      !numeric_identity_equal(r.identity, rt.inputs.identity) ||
      !r.valid || (r.state != CacheState::READY &&
                   r.state != CacheState::READ)) return error(s.ref.id);
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    if (!bit(r.covered_rows, bit_index(s, batch, row)) ||
        (s.ref.id == Buffer::TYPE_ROWS && !rt.owners.type_valid[row]))
      return error(s.ref.id);
  return ok();
}

Check full_acquire_owner(FullRuntime& rt, const FullOwnerSpec& s,
                         uint8_t batch, uint16_t row0, uint16_t rows) {
  Check c = full_require_owner(rt, s, batch, row0, rows);
  if (!c) return c;
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (r.readers == UINT8_MAX) return error(s.ref.id);
  ++r.readers;
  r.state = CacheState::READ;
  return ok();
}

Check full_release_read_owner(FullRuntime& rt, const FullOwnerSpec& s) {
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::READ ||
      !r.readers || !r.valid) return error(s.ref.id);
  --r.readers;
  if (!r.readers) r.state = CacheState::READY;
  return ok();
}

Check full_cover_owner(FullRuntime& rt, const FullOwnerSpec& s,
                       uint8_t batch, uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !legal_spec(rt, s) || !in_scope(rt, s, batch, row0, rows) ||
      s.ref.id == Buffer::QKV || s.ref.id == Buffer::ATT_OUT)
    return error(s.ref.id, 5);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  const bool type_extend = s.ref.id == Buffer::TYPE_ROWS &&
                           r.state == CacheState::READY &&
                           r.valid && r.readers == 0;
  if (!same_spec(r, s) ||
      !numeric_identity_equal(r.identity, rt.inputs.identity) ||
      (r.state != CacheState::FILL && r.state != CacheState::EXCLUSIVE_RW &&
       !type_extend))
    return error(s.ref.id);
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row) {
    const unsigned idx = bit_index(s, batch, row);
    if (bit(r.covered_rows, idx) ||
        (r.state == CacheState::EXCLUSIVE_RW &&
         !bit(r.old_consumed_rows, idx))) return error(s.ref.id);
  }
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    set_bit(r.covered_rows, bit_index(s, batch, row));
  return ok();
}

Check full_publish_owner(FullRuntime& rt, const FullOwnerSpec& s) {
  if (!rt.request_valid || !rt.model_header_valid ||
      s.ref.id == Buffer::QKV || s.ref.id == Buffer::ATT_OUT)
    return error(s.ref.id);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) ||
      (r.state != CacheState::FILL &&
       !(s.ref.id == Buffer::TYPE_ROWS && r.state == CacheState::READY &&
         r.readers == 0)) ||
      !numeric_identity_equal(r.identity, rt.inputs.identity))
    return error(s.ref.id);
  if (s.ref.id == Buffer::TYPE_ROWS) {
    if ((r.covered_rows[0] & 7u) == 0) return error(s.ref.id);
    for (unsigned t = 0; t < 3; ++t)
      rt.owners.type_valid[t] = bit(r.covered_rows, t);
  } else if (!covered(rt, s, r.covered_rows)) return error(s.ref.id);
  r.state = CacheState::READY;
  r.valid = true;
  return ok();
}

Check full_release_owner(FullRuntime& rt, const FullOwnerSpec& s) {
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || !r.valid ||
      r.state != CacheState::READY || r.readers)
    return error(s.ref.id);
  r.state = CacheState::FREE;
  r.valid = false;
  if (s.ref.id == Buffer::TYPE_ROWS)
    for (bool& v : rt.owners.type_valid) v = false;
  clear_bits(r.covered_rows);
  return ok();
}

Check full_invalidate_owner(FullRuntime& rt, BufferRef ref, uint8_t region) {
  const unsigned index = find_index(rt, ref, region);
  if (index == kNoOwnerIndex) return error(ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (r.ref != ref && r.lease_old_ref != ref) return error(ref.id);
  if (r.state == CacheState::READ || r.readers) return error(ref.id);
  r.state = CacheState::INVALID;
  r.valid = false;
  r.lease_old_ref = none();
  if (r.ref.id == Buffer::TYPE_ROWS)
    for (bool& v : rt.owners.type_valid) v = false;
  clear_bits(r.covered_rows);
  clear_bits(r.old_consumed_rows);
  return ok();
}

Check full_begin_inplace_owner(FullRuntime& rt, const FullOwnerSpec& old_s,
                               const FullOwnerSpec& next_s) {
  const bool allowed =
      (old_s.ref.id == Buffer::SCORE_PROB &&
       old_s.content == Content::SCORE && next_s.content == Content::PROB) ||
      (old_s.ref.id == Buffer::DEC_FF &&
       old_s.content == Content::F32 && next_s.content == Content::F32) ||
      (old_s.ref.id == Buffer::HEAD_WORK &&
       (old_s.region == uint8_t(Region::SCORER_ACT) ||
        old_s.region == uint8_t(Region::ACT_HIDDEN)) &&
       old_s.content == Content::F32 && next_s.content == Content::F32);
  if (!rt.request_valid || !rt.model_header_valid ||
      !allowed ||
      !legal_spec(rt, old_s) || !legal_spec(rt, next_s) ||
      !same_physical(old_s.ref, old_s.region, next_s.ref, next_s.region) ||
      old_s.region != next_s.region || old_s.row_space != next_s.row_space ||
      old_s.batch != next_s.batch || old_s.row0 != next_s.row0 ||
      old_s.rows != next_s.rows || old_s.width != next_s.width ||
      old_s.stage != next_s.stage || old_s.layer != next_s.layer)
    return error(next_s.ref.id, 5);
  const unsigned index = find_index(rt, old_s.ref, old_s.region);
  if (index == kNoOwnerIndex) return error(next_s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, old_s) || !r.valid ||
      r.state != CacheState::READY || r.readers ||
      !numeric_identity_equal(r.identity, rt.inputs.identity) ||
      !covered(rt, old_s, r.covered_rows) ||
      r.max_claimed_epoch >= kMaxEpoch ||
      next_s.ref.epoch != r.max_claimed_epoch + 1)
    return error(next_s.ref.id);
  r.lease_old_ref = old_s.ref;
  r.ref = next_s.ref;
  r.max_claimed_epoch = next_s.ref.epoch;
  r.stage = next_s.stage; r.layer = next_s.layer;
  r.content = next_s.content; r.state = CacheState::EXCLUSIVE_RW;
  r.valid = false;
  clear_bits(r.covered_rows);
  clear_bits(r.old_consumed_rows);
  ++rt.owner_leases;
  return ok();
}

Check full_consume_inplace_rows(FullRuntime& rt, const FullOwnerSpec& s,
                                uint8_t batch, uint16_t row0, uint16_t rows) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !in_scope(rt, s, batch, row0, rows)) return error(s.ref.id, 5);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::EXCLUSIVE_RW ||
      r.lease_old_ref.id == Buffer::NONE ||
      !numeric_identity_equal(r.identity, rt.inputs.identity))
    return error(s.ref.id);
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row) {
    const unsigned idx = bit_index(s, batch, row);
    if (bit(r.old_consumed_rows, idx) || bit(r.covered_rows, idx))
      return error(s.ref.id);
  }
  for (uint16_t row = row0; row < uint32_t(row0) + rows; ++row)
    set_bit(r.old_consumed_rows, bit_index(s, batch, row));
  return ok();
}

Check full_commit_inplace_owner(FullRuntime& rt, const FullOwnerSpec& s) {
  if (!rt.request_valid || !rt.model_header_valid) return error(s.ref.id);
  const unsigned index = find_index(rt, s.ref, s.region);
  if (index == kNoOwnerIndex) return error(s.ref.id);
  FullOwnerRecord& r = rt.owners.record[index];
  if (!same_spec(r, s) || r.state != CacheState::EXCLUSIVE_RW ||
      !numeric_identity_equal(r.identity, rt.inputs.identity) ||
      !covered(rt, s, r.old_consumed_rows) ||
      !covered(rt, s, r.covered_rows)) return error(s.ref.id);
  r.state = CacheState::READY;
  r.valid = true;
  r.lease_old_ref = none();
  return ok();
}

Check full_owner_snapshot(const FullRuntime& rt, BufferRef ref,
                          uint8_t region, FullOwnerRecord& output) {
  if (!check_ref(ref, region)) return error(ref.id);
  const unsigned index = find_index(rt, ref, region);
  if (index == kNoOwnerIndex) return error(ref.id);
  const FullOwnerRecord& r = rt.owners.record[index];
  if (r.ref != ref) return error(ref.id);
  output = r;
  return ok();
}

Check full_bind_quant_source(FullRuntime& rt, const FullOwnerSpec& expected) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !legal_spec(rt, expected) || expected.content != Content::F32 ||
      expected.ref.id == Buffer::NONE) return error(expected.ref.id);
  rt.expected_quant_source = expected;
  rt.expected_quant_source_valid = true;
  return ok();
}

Check full_bind_task_source(FullRuntime& rt, const FullOwnerSpec& expected) {
  if (!rt.request_valid || !rt.model_header_valid ||
      !legal_spec(rt, expected) || expected.ref.id == Buffer::NONE ||
      rt.expected_task_source_count >= 4)
    return error(expected.ref.id);
  rt.expected_task_source[rt.expected_task_source_count++] = expected;
  return ok();
}

Check full_recycle_request(FullRuntime& rt) {
  for (unsigned i = 0; i < kNoOwnerIndex; ++i) {
    const FullOwnerRecord& r = rt.owners.record[i];
    if (r.state == CacheState::FILL || r.state == CacheState::READ ||
        r.state == CacheState::EXCLUSIVE_RW || r.state == CacheState::DRAIN ||
        r.readers) return protocol();
  }
  unsigned a8_index = find_index(rt, BufferRef{Buffer::A8, 0, 1}, 0);
  const BufferRef numeric_ref = rt.cache.activation_meta.ref;
  if (numeric_ref.id == Buffer::A8 && numeric_ref.bank == 0 &&
      numeric_ref.epoch && a8_index == kNoOwnerIndex) {
    a8_index = empty_index(rt);
    if (a8_index == kNoOwnerIndex) return protocol();
    FullOwnerRecord& a8 = rt.owners.record[a8_index];
    a8.ref = numeric_ref;
    a8.max_claimed_epoch = numeric_ref.epoch;
    a8.state = CacheState::INVALID;
  }
  if (a8_index != kNoOwnerIndex) {
    FullOwnerRecord& a8 = rt.owners.record[a8_index];
    uint32_t high = a8.max_claimed_epoch;
    if (numeric_ref.id == Buffer::A8 && numeric_ref.bank == 0 &&
        numeric_ref.epoch > high) high = numeric_ref.epoch;
    a8.ref.epoch = high;
    a8.max_claimed_epoch = high;
    rt.cache.activation_meta.ref = {Buffer::A8, 0, high};
  }
  for (unsigned i = 0; i < kNoOwnerIndex; ++i) {
    FullOwnerRecord& r = rt.owners.record[i];
    r.state = CacheState::INVALID;
    r.valid = false;
    r.readers = 0;
    r.lease_old_ref = none();
    clear_bits(r.covered_rows);
    clear_bits(r.old_consumed_rows);
  }
  for (auto& shard : rt.owners.qkv_plane_head_rows)
    for (auto& plane : shard)
      for (auto& head : plane)
        for (auto& batch : head)
          for (uint32_t& word : batch) word = 0;
  for (auto& shard : rt.owners.qkv_rope_rows)
    for (auto& plane : shard)
      for (auto& head : plane)
        for (auto& batch : head)
          for (uint32_t& word : batch) word = 0;
  for (auto& head : rt.owners.att_head_rows)
    for (auto& batch : head)
      for (uint32_t& word : batch) word = 0;
  for (unsigned b = 0; b < 2; ++b) {
    rt.owners.scorer_old_consumed[b] = 0;
    rt.owners.scorer_new_written[b] = 0;
  }
  for (bool& v : rt.owners.type_valid) v = false;
  rt.current_weight = FullWeightDescriptor{};
  rt.current_weight_ref = none();
  rt.loaded_gamma_ref[0] = none();
  rt.loaded_gamma_ref[1] = none();
  rt.final_qkv_ref[0] = none();
  rt.final_qkv_ref[1] = none();
  rt.loaded_kv_ref = none();
  rt.loaded_rope_ref = none();
  rt.loaded_rope_mode = 255;
  rt.loaded_kv_head = 255;
  rt.score_ref = none();
  rt.score_kv_ref = none();
  rt.score_qkv_ref[0] = none();
  rt.score_qkv_ref[1] = none();
  rt.score_head = 255;
  rt.score_batch = 255;
  rt.score_rows = 0;
  rt.score_valid = false;
  numeric_reset_a8(rt.cache.activation_meta);
  numeric_reset_f32(rt.cache.activation_source_ledger);
  rt.request_valid = false;
  rt.model_header_valid = false;
  rt.expected_quant_source = FullOwnerSpec{};
  rt.expected_quant_source_valid = false;
  rt.expected_task_source_count = 0;
  rt.last_task_id = 0;
  rt.tasks_retired = 0;
  for (uint32_t& count : rt.op_calls) count = 0;
  rt.owner_claims = 0;
  rt.owner_leases = 0;
  rt.encoder_layers_completed = 0;
  rt.decision_layers_completed = 0;
  return ok();
}

Check full_soft_reset(FullRuntime& rt, uint64_t new_generation) {
  if (!new_generation ||
      (rt.inputs.identity.generation &&
       new_generation <= rt.inputs.identity.generation)) return protocol();
  Check c = full_recycle_request(rt);
  if (!c) return c;
  rt.inputs.identity.generation = new_generation;
  rt.session_generation = new_generation;
  rt.last_accepted_request_id = 0;
  return ok();
}

} // namespace laya::full
