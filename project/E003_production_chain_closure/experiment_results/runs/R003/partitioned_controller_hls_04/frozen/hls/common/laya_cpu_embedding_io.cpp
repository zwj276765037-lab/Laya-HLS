#include "laya_full_runtime.h"

namespace laya::full {
namespace {
constexpr uint32_t kDescriptorOffset = 20480;
constexpr uint32_t kDescriptorBytes = 256;
constexpr uint32_t kRowStride = 4096;
constexpr uint32_t kBatchStride = 4194304;

uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
uint64_t le64(const uint8_t* p) {
  uint64_t result = 0;
  for (unsigned i = 0; i < 8; ++i) result |= uint64_t(p[i]) << (8u * i);
  return result;
}
bool same(const uint8_t* a, const uint8_t* b, unsigned count) {
  for (unsigned i = 0; i < count; ++i)
    if (a[i] != b[i]) return false;
  return true;
}
uint32_t crc_byte(uint32_t crc, uint8_t byte) {
  crc ^= byte;
  for (unsigned i = 0; i < 8; ++i)
    crc = (crc >> 1) ^ ((crc & 1) ? 0x82f63b78u : 0u);
  return crc;
}
uint32_t crc_bytes(const uint8_t* p, uint32_t bytes,
                   uint32_t zero0 = UINT32_MAX, uint32_t zero1 = UINT32_MAX) {
  uint32_t crc = 0xffffffffu;
  for (uint32_t i = 0; i < bytes; ++i)
    crc = crc_byte(crc, i >= zero0 && i < zero1 ? 0 : p[i]);
  return crc ^ 0xffffffffu;
}
Check descriptor_error(FullRuntime& rt, Status status, uint16_t reason,
                       uint32_t offset) {
  rt.cpu_import.descriptor_error_offset = offset;
  return {status, detail(0x0a, 0x01, reason), UINT64_MAX};
}
Check import_error(Status status, uint16_t reason,
                   uint64_t bad_element = UINT64_MAX) {
  return {status, detail(0x0a, 0x01, reason), bad_element};
}
} // namespace

Check full_validate_cpu_raw_descriptor(FullRuntime& rt, const FullMemory& m,
                                       const FullInputs& next,
                                       uint32_t frame_bytes) {
  auto& d = rt.cpu_import;
  d.reached_phase = 1;
  if (!full_span(m, Bo::IO, kDescriptorOffset, kDescriptorBytes))
    return descriptor_error(rt, Status::E_BUFFER, 1, 0);
  const uint8_t* p = m.io + kDescriptorOffset;
  d.expected_request_crc = le32(p + 148);
  d.expected_raw_crc = le32(p + 152);
  d.expected_descriptor_crc = le32(p + 156);
  if (!same(p, reinterpret_cast<const uint8_t*>("LYER"), 4))
    return descriptor_error(rt, Status::E_ABI, 2, 0);
  if (le16(p + 4) != 1)
    return descriptor_error(rt, Status::E_ABI, 3, 4);
  if (le16(p + 6) != kDescriptorBytes)
    return descriptor_error(rt, Status::E_ABI, 3, 6);
  if (le32(p + 8) != 1)
    return descriptor_error(rt, Status::E_ABI, 3, 8);
  if (le32(p + 12) != 0)
    return descriptor_error(rt, Status::E_ABI, 4, 12);
  if (le32(p + 108) != 0)
    return descriptor_error(rt, Status::E_ABI, 4, 108);
  for (unsigned i = 160; i < kDescriptorBytes; ++i)
    if (p[i]) return descriptor_error(rt, Status::E_ABI, 4, i);
  d.actual_descriptor_crc = crc_bytes(p, kDescriptorBytes, 156, 160);
  if (d.actual_descriptor_crc != d.expected_descriptor_crc)
    return descriptor_error(rt, Status::E_ABI, 5, 156);
  d.descriptor_crc_valid = true;
  if (le64(p + 16) != next.identity.request_id)
    return descriptor_error(rt, Status::E_PROTOCOL, 6, 16);
  if (le64(p + 24) != next.identity.generation)
    return descriptor_error(rt, Status::E_PROTOCOL, 6, 24);
  if (!same(p + 32, next.identity.model_tag, 16))
    return descriptor_error(rt, Status::E_MODEL, 7, 32);
  if (!same(p + 48, next.identity.numeric_tag, 16))
    return descriptor_error(rt, Status::E_ABI, 8, 48);
  if (!same(p + 64, next.identity.layout_tag, 16))
    return descriptor_error(rt, Status::E_ABI, 8, 64);
  if (!same(p + 80, next.identity.build_tag, 16))
    return descriptor_error(rt, Status::E_ABI, 8, 80);
  if (le16(p + 96) != next.identity.B)
    return descriptor_error(rt, Status::E_SHAPE, 9, 96);
  if (le16(p + 98) != next.identity.S)
    return descriptor_error(rt, Status::E_SHAPE, 9, 98);
  if (le16(p + 100) != 1024)
    return descriptor_error(rt, Status::E_SHAPE, 9, 100);
  if (le16(p + 102) != 1)
    return descriptor_error(rt, Status::E_ABI, 10, 102);
  if (le32(p + 104) != 0)
    return descriptor_error(rt, Status::E_ABI, 10, 104);
  if (le64(p + 112) != 0)
    return descriptor_error(rt, Status::E_BUFFER, 11, 112);
  if (le32(p + 120) != kRowStride)
    return descriptor_error(rt, Status::E_BUFFER, 11, 120);
  if (le32(p + 124) != kBatchStride)
    return descriptor_error(rt, Status::E_BUFFER, 11, 124);
  const uint64_t payload = uint64_t(next.identity.B) * next.identity.S *
                           kRowStride;
  const uint64_t extent = uint64_t(next.identity.B - 1) * kBatchStride +
                          uint64_t(next.identity.S) * kRowStride;
  if (le64(p + 128) != payload)
    return descriptor_error(rt, Status::E_BUFFER, 12, 128);
  if (le64(p + 136) != extent ||
      !full_span(m, Bo::STATE0, 0, extent))
    return descriptor_error(rt, Status::E_BUFFER, 12, 136);
  if (le32(p + 144) != frame_bytes)
    return descriptor_error(rt, Status::E_BUFFER, 13, 144);
  d.actual_request_crc = crc_bytes(m.io, frame_bytes);
  if (d.actual_request_crc != d.expected_request_crc)
    return descriptor_error(rt, Status::E_ABI, 14, 148);
  d.request_crc_valid = true;
  d.descriptor_valid = true;
  return ok();
}

Check full_import_cpu_raw(FullRuntime& rt, FullMemory& memory,
                          FullOwnerSpec& hidden) {
  auto& d = rt.cpu_import;
  uint32_t epoch = 1;
  for (unsigned i = 0; i < 32; ++i) {
    const FullOwnerRecord& r = rt.owners.record[i];
    if (r.ref.id == Buffer::HIDDEN && r.ref.bank == 0 && r.region == 0) {
      epoch = r.max_claimed_epoch < kMaxEpoch ?
              r.max_claimed_epoch + 1 : 0;
      break;
    }
  }
  hidden = {{Buffer::HIDDEN, 0, epoch}, 0, 1, 255, 255,
            RowSpace::TOKEN, 0, rt.inputs.identity.S, 1024, Content::F32};
  Check c = full_claim_owner(rt, hidden);
  if (!c) return c;
  d.imports_started = true;
  d.reached_phase = 3;
  uint32_t crc = 0xffffffffu;
  for (unsigned b = 0; b < rt.inputs.identity.B; ++b)
    for (unsigned row = 0; row < rt.inputs.identity.S; ++row)
      for (unsigned col = 0; col < 1024; ++col) {
        const uint64_t offset = uint64_t(b) * kBatchStride +
                                uint64_t(row) * kRowStride + col * 4u;
        uint8_t raw[4];
        c = full_read(memory, Bo::STATE0, offset, raw, 4);
        if (!c) {
          d.actual_raw_crc = crc ^ 0xffffffffu;
          return c;
        }
        for (uint8_t byte : raw) crc = crc_byte(crc, byte);
        d.raw_elements_scanned++;
        d.raw_bytes_scanned += 4;
        const uint32_t bits = le32(raw);
        if ((bits & 0x7f800000u) == 0x7f800000u) {
          const uint64_t index =
              (uint64_t(b) * rt.inputs.identity.S + row) * 1024u + col;
          d.import_bad_element = index;
          d.actual_raw_crc = crc ^ 0xffffffffu;
          d.reached_phase = 4;
          return import_error(Status::E_NUMERICAL, 15, index);
        }
      }
  d.actual_raw_crc = crc ^ 0xffffffffu;
  d.scan_complete = true;
  d.reached_phase = 4;
  if (d.actual_raw_crc != d.expected_raw_crc)
    return import_error(Status::E_ABI, 16);
  d.raw_verified = true;
  for (unsigned b = 0; b < rt.inputs.identity.B; ++b) {
    c = full_cover_owner(rt, hidden, uint8_t(b), 0, rt.inputs.identity.S);
    if (!c) return c;
    d.import_rows_covered += rt.inputs.identity.S;
  }
  c = full_publish_owner(rt, hidden);
  if (!c) return c;
  d.imports_committed = true;
  d.reached_phase = 5;
  return ok();
}

} // namespace laya::full
