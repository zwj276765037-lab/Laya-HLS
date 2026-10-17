#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

namespace laya::full {
namespace {
Check error(Status status, uint8_t domain, uint8_t object,
            uint16_t reason, uint64_t bad_element = UINT64_MAX) {
  return {status, detail(domain, object, reason), bad_element};
}
uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
uint64_t le64(const uint8_t* p) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i) value |= uint64_t(p[i]) << (8 * i);
  return value;
}
int32_t signed32(const uint8_t* p) {
  const uint32_t bits = le32(p);
  const int64_t value = bits <= INT32_MAX ? int64_t(bits) : int64_t(bits) - 0x100000000ll;
  return int32_t(value);
}
bool same(const uint8_t* a, const uint8_t* b, unsigned n) {
  for (unsigned i = 0; i < n; ++i) if (a[i] != b[i]) return false;
  return true;
}
bool legal_s(uint16_t s) {
  return s == 64 || s == 128 || s == 256 || s == 512 || s == 1024;
}
uint32_t payload_length(unsigned i, uint16_t B, uint16_t S) {
  switch (i) {
    case 0: return 4u * B * S;
    case 1: return uint32_t(B) * S;
    case 2: return 64u * B;
    case 3: return 16u * B;
    default: return 4u * B;
  }
}
uint32_t align64(uint32_t x) { return (x + 63u) & ~63u; }
Check check_directory(const uint8_t* d, unsigned i, uint16_t B,
                      uint16_t S, uint32_t offset, uint32_t frame_bytes) {
  const uint32_t length = payload_length(i, B, S);
  const uint16_t dim1 = i < 2 ? S : i == 4 ? 1 : 16;
  const uint32_t stride0 = i == 0 ? 4u * S :
                           i == 1 ? S : i == 2 ? 64u : i == 3 ? 16u : 4u;
  const uint32_t stride1 = i == 4 ? 0u : (i == 0 || i == 2 ? 4u : 1u);
  const uint32_t elements = i < 2 ? uint32_t(B) * S :
                            i == 4 ? B : 16u * B;
  if (le32(d + 28) != 0)
    return error(Status::E_ABI, 2, uint8_t(i + 1), 3);
  if (le32(d + 4) != offset)
    return error(Status::E_BUFFER, 2, uint8_t(i + 1), 7);
  if (le32(d + 8) != length || uint64_t(offset) + length > frame_bytes)
    return error(Status::E_BUFFER, 2, uint8_t(i + 1), 8);
  if (le16(d) != i + 1 || d[2] != (i == 1 || i == 3 ? 2 : 1) ||
      d[3] != (i == 4 ? 1 : 2) || le16(d + 12) != B ||
      le16(d + 14) != dim1 || le32(d + 16) != stride0 ||
      le32(d + 20) != stride1 || le32(d + 24) != elements)
    return error(Status::E_SHAPE, 2, uint8_t(i + 1), 6);
  return ok();
}
} // namespace

Check full_parse_request(FullRuntime& rt) {
  // A failed parse must never leave an earlier request authorized for a
  // subsequent model read.  Owner epochs remain intact across the attempt.
  rt.request_valid = false;
  rt.model_header_valid = false;
  rt.expected_quant_source_valid = false;
  rt.last_execution_error = ok();
  rt.last_cleanup_error = ok();
  rt.diagnostic_identity_valid = false;
  rt.diagnostic_shape_valid = false;
  rt.diagnostic_request_id = 0;
  rt.diagnostic_generation = 0;
  rt.diagnostic_B = 0;
  rt.diagnostic_S = 0;
  const FullMemory& m = rt.memory;
  Check c = full_span(m, Bo::IO, 0, kRequestHeaderBytes);
  if (!c) return error(Status::E_ABI, 1, 0, 8);
  const uint8_t* p = m.io;
  if (p[0] != 'L' || p[1] != 'Y' || p[2] != 'R' || p[3] != 'Q')
    return error(Status::E_ABI, 1, 0, 1);
  if (le16(p + 4) != 1 || le16(p + 6) != 0)
    return error(Status::E_ABI, 1, 4, 2);
  if (le16(p + 8) != 128 || le16(p + 10) != 32 || le16(p + 12) != 5)
    return error(Status::E_ABI, 1, 8, 5);
  if (le16(p + 14) != 0 || le64(p + 120) != 0)
    return error(Status::E_ABI, 1, 14, 3);

  FullInputs next;
  next.identity.B = le16(p + 20);
  next.identity.S = le16(p + 22);
  next.identity.request_id = le64(p + 24);
  next.identity.generation = le64(p + 32);
  if (!next.identity.request_id || !next.identity.generation)
    return error(Status::E_ABI, 1, 24, 4);
  // The fixed header is now trustworthy enough to identify this invocation.
  // Later tag, shape, directory and payload errors retain these two fields.
  rt.diagnostic_request_id = next.identity.request_id;
  rt.diagnostic_generation = next.identity.generation;
  rt.diagnostic_identity_valid = true;
  if (next.identity.B >= 1 && next.identity.B <= 2 &&
      legal_s(next.identity.S)) {
    rt.diagnostic_B = next.identity.B;
    rt.diagnostic_S = next.identity.S;
    rt.diagnostic_shape_valid = true;
  }
  for (unsigned i = 0; i < 16; ++i) {
    next.identity.model_tag[i] = p[40 + i];
    next.identity.numeric_tag[i] = p[56 + i];
    next.identity.layout_tag[i] = p[72 + i];
    next.identity.build_tag[i] = p[88 + i];
  }
  if (!same(next.identity.model_tag, kFullModelTag, 16))
    return error(Status::E_MODEL, 1, 40, 2);
  if (!same(next.identity.numeric_tag, kFullNumericTag, 16))
    return error(Status::E_ABI, 1, 56, 2);
  if (!same(next.identity.layout_tag, kFullLayoutTag, 16))
    return error(Status::E_ABI, 1, 72, 2);
  if (!same(next.identity.build_tag, kFullBuildTag, 16))
    return error(Status::E_ABI, 1, 88, 2);
  if (next.identity.B < 1 || next.identity.B > 2 ||
      !legal_s(next.identity.S))
    return error(Status::E_SHAPE, 1, 20, 5);
  const uint32_t frame_bytes = le32(p + 16);
  if (frame_bytes < kRequestPayloadOffset || frame_bytes > kRequestLimit ||
      (frame_bytes & 63u) || m.io_bytes < frame_bytes ||
      le32(p + 104) != 128 || le32(p + 108) != 320 ||
      le32(p + 112) != 16384 || le32(p + 116) != 4096)
    return error(Status::E_BUFFER, 1, 16, 8);
  for (unsigned i = 288; i < 320; ++i)
    if (p[i] != 0) return error(Status::E_ABI, 1, 108, 3);

  uint32_t offset = kRequestPayloadOffset;
  uint32_t directory_offset[5] = {};
  for (unsigned i = 0; i < 5; ++i) {
    c = check_directory(p + 128 + i * 32, i, next.identity.B,
                        next.identity.S, offset, frame_bytes);
    if (!c) return c;
    directory_offset[i] = offset;
    offset = align64(offset + payload_length(i, next.identity.B,
                                              next.identity.S));
  }
  if (offset != frame_bytes)
    return error(Status::E_BUFFER, 1, 16, 8);
  // All descriptors and frame bounds are known before reading any payload.
  for (unsigned i = 0; i < 5; ++i) {
    const uint32_t end = directory_offset[i] +
                         payload_length(i, next.identity.B, next.identity.S);
    for (uint32_t j = end; j < align64(end); ++j)
      if (p[j] != 0) return error(Status::E_ABI, 2, uint8_t(i + 1), 3);
  }

  for (unsigned b = 0; b < next.identity.B; ++b) {
    unsigned attended = 0, candidates = 0;
    for (unsigned s = 0; s < next.identity.S; ++s) {
      const unsigned index = b * next.identity.S + s;
      const int32_t token = signed32(p + directory_offset[0] + 4 * index);
      const uint8_t mask = p[directory_offset[1] + index];
      if (token < 0 || token >= kVocab || mask > 1)
        return error(Status::E_INDEX, 3, token < 0 || token >= kVocab ? 1 : 2,
                     4, index);
      next.token_ids[b][s] = token;
      next.attention_mask[b][s] = mask;
      attended += mask;
    }
    if (!attended) return error(Status::E_INDEX, 3, 2, 13, b);
    for (unsigned col = 0; col < 16; ++col) {
      const unsigned index = b * 16 + col;
      const int32_t marker = signed32(p + directory_offset[2] + 4 * index);
      const uint8_t mask = p[directory_offset[3] + index];
      if (mask > 1) return error(Status::E_INDEX, 3, 4, 4, index);
      if (mask) {
        if (marker < int32_t(b * next.identity.S) ||
            marker >= int32_t((b + 1) * next.identity.S) ||
            next.attention_mask[b][marker - b * next.identity.S] == 0)
          return error(Status::E_INDEX, 3, 3, 4, index);
      } else if (marker != int32_t(b * next.identity.S)) {
        return error(Status::E_INDEX, 3, 3, 4, index);
      }
      next.marker_positions[b][col] = marker;
      next.marker_mask[b][col] = mask;
      candidates += mask;
    }
    if (!candidates) return error(Status::E_INDEX, 3, 4, 13, b);
    const int32_t qtype = signed32(p + directory_offset[4] + 4 * b);
    if (qtype < 0 || qtype > 2)
      return error(Status::E_INDEX, 3, 5, 4, b);
    next.qtype[b] = uint8_t(qtype);
  }
  c = full_check_model_header(m, next.identity);
  if (!c) return c;
  if (rt.session_generation) {
    if (next.identity.generation < rt.session_generation ||
        (next.identity.generation == rt.session_generation &&
         next.identity.request_id <= rt.last_accepted_request_id))
      return error(Status::E_PROTOCOL, 1, 24, 4);
    if (next.identity.generation > rt.session_generation) {
      c = full_soft_reset(rt, next.identity.generation);
      if (!c) return c;
    } else if (rt.last_accepted_request_id) {
      c = full_recycle_request(rt);
      if (!c) return c;
    }
  }
  rt.inputs = next;
  rt.session_generation = next.identity.generation;
  rt.last_accepted_request_id = next.identity.request_id;
  rt.request_valid = true;
  rt.model_header_valid = true;
  return ok();
}

} // namespace laya::full
