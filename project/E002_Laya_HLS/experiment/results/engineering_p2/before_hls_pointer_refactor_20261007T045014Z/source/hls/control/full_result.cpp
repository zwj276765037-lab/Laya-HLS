#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

namespace laya::full {
namespace {
void put16(uint8_t* p, unsigned at, uint16_t value) {
  p[at] = uint8_t(value);
  p[at + 1] = uint8_t(value >> 8);
}
void put32(uint8_t* p, unsigned at, uint32_t value) {
  for (unsigned i = 0; i < 4; ++i) p[at + i] = uint8_t(value >> (8 * i));
}
void put64(uint8_t* p, unsigned at, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) p[at + i] = uint8_t(value >> (8 * i));
}
Check read_bits(const FullRuntime& rt, BufferRef ref, uint8_t region,
                uint8_t batch, uint16_t row, uint16_t col,
                uint32_t& bits) {
  Address address;
  Check c = full_f32_address(rt, ref, region, batch, row, col, address);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(rt.memory, address.bo, address.offset, raw, 4);
  if (!c) return c;
  bits = uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
         uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24;
  if ((bits & 0x7f800000u) == 0x7f800000u)
    return {Status::E_NUMERICAL,
            detail(7, uint8_t(Op::RESULT_COMMIT), 15),
            uint64_t(batch) *
                (region == uint8_t(Region::CAND_MASKED) ? 16u : 2u) + col};
  return ok();
}
} // namespace

Check full_write_result(FullRuntime& rt, Check result, bool accepted,
                        uint8_t error_stage, uint8_t error_op,
                        uint32_t error_task_id, BufferRef candidate,
                        BufferRef act) {
  uint8_t bytes[kResultBytes] = {};
  bytes[0] = 'L'; bytes[1] = 'Y'; bytes[2] = 'R'; bytes[3] = 'S';
  put16(bytes, 4, 1);
  put16(bytes, 8, 128);
  put32(bytes, 12, kResultBytes);
  put32(bytes, 104, 128);
  put32(bytes, 108, 256);
  for (unsigned i = 0; i < 16; ++i) {
    bytes[32 + i] = kFullModelTag[i];
    bytes[48 + i] = kFullNumericTag[i];
    bytes[64 + i] = kFullLayoutTag[i];
    bytes[80 + i] = kFullBuildTag[i];
  }
  uint32_t candidate_bits[32] = {}, act_bits[4] = {};
  const bool computation_succeeded = bool(result);
  if (result && accepted) {
    const FullOwnerSpec masked{candidate, uint8_t(Region::CAND_MASKED),
                                5, 255, 255, RowSpace::BATCH,
                                0, 1, 16, Content::F32};
    const FullOwnerSpec logits{act, uint8_t(Region::ACT_LOGITS),
                                6, 255, 255, RowSpace::BATCH,
                                0, 1, 2, Content::F32};
    for (unsigned b = 0; b < rt.inputs.identity.B && result; ++b) {
      result = full_acquire_owner(rt, masked, uint8_t(b), 0, 1);
      const bool masked_read = bool(result);
      if (result) result = full_acquire_owner(rt, logits, uint8_t(b), 0, 1);
      const bool logits_read = bool(result);
      for (unsigned c = 0; c < 16 && result; ++c)
        result = read_bits(rt, candidate, uint8_t(Region::CAND_MASKED),
                           uint8_t(b), 0, uint16_t(c),
                           candidate_bits[b * 16 + c]);
      for (unsigned a = 0; a < 2 && result; ++a)
        result = read_bits(rt, act, uint8_t(Region::ACT_LOGITS),
                           uint8_t(b), 0, uint16_t(a),
                           act_bits[b * 2 + a]);
      if (logits_read) {
        Check release = full_release_read_owner(rt, logits);
        if (result) result = release;
      }
      if (masked_read) {
        Check release = full_release_read_owner(rt, masked);
        if (result) result = release;
      }
    }
  }
  if (computation_succeeded && !result) {
    error_stage = 7;
    error_op = uint8_t(Op::RESULT_COMMIT);
    error_task_id = 0;
  }
  put16(bytes, 10, uint16_t(result.code));
  if (rt.diagnostic_identity_valid) {
    put64(bytes, 16, rt.diagnostic_request_id);
    put64(bytes, 24, rt.diagnostic_generation);
  }
  if (rt.diagnostic_shape_valid) {
    put16(bytes, 96, rt.diagnostic_B);
    put16(bytes, 98, rt.diagnostic_S);
  }
  if (result && accepted) {
    put16(bytes, 100, uint16_t(16 * rt.inputs.identity.B));
    put16(bytes, 102, uint16_t(2 * rt.inputs.identity.B));
    for (unsigned i = 0; i < 32; ++i)
      put32(bytes, 128 + i * 4, candidate_bits[i]);
    for (unsigned i = 0; i < 4; ++i)
      put32(bytes, 256 + i * 4, act_bits[i]);
  } else {
    put16(bytes, 116, error_stage);
    put16(bytes, 118, error_op);
    put32(bytes, 120, result.detail);
  }
  put32(bytes, 112, (rt.diagnostic_identity_valid ? 1u : 0u) |
                         (accepted ? 8u : 0u) |
                         (result && accepted ? 2u : 0u));
  if (accepted) {
    const uint64_t B = rt.inputs.identity.B, S = rt.inputs.identity.S;
    put64(bytes, 328, rt.tasks_retired);
    put64(bytes, 336, 2u * B * S + 33u * B);
    put64(bytes, 344, result ? 18u * B : 0u);
  }
  put64(bytes, 352, result ? UINT64_MAX : result.bad_element);
  put32(bytes, 360, result ? 0 : error_task_id);
  // The header is the commit record. Its data and diagnostics are written
  // first so a completed run never exposes a newly valid header with stale
  // logits from an earlier request.
  Check c = full_write(rt.memory, Bo::IO, kResultOffset + 128,
                       bytes + 128, kResultBytes - 128);
  if (c) c = full_write(rt.memory, Bo::IO, kResultOffset, bytes, 128);
  return c ? result : c;
}

} // namespace laya::full
