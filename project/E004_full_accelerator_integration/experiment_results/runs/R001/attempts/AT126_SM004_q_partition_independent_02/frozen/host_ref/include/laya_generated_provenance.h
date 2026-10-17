#pragma once

#include "laya_compute_portal.h"
#include <array>

namespace laya::provenance {

constexpr unsigned kRequestBytes = 1024, kResponseBytes = 512;
constexpr unsigned kRequestBeats = 16, kResponseBeats = 8;
constexpr uint32_t kRequestMagic = 0x3156504c;
constexpr uint32_t kResponseMagic = 0x3141504c;
constexpr uint16_t kVersion = 1;

enum class Action : uint16_t {
  CLAIM = 1, BEGIN = 2, END = 3, PUBLISH = 4,
  RELEASE = 5, INVALIDATE = 6
};

enum class Component : uint8_t {
  FULL_WIDTH = 0, ATT_HEAD = 1, QKV_PLANES = 2
};

struct OwnerDescriptor {
  BufferRef target_ref;
  uint8_t target_region = 0;
  BufferRef old_ref;
  uint8_t old_region = 0;
  uint8_t stage = 0, layer = 255, batch = 255;
  RowSpace row_space = RowSpace::TOKEN;
  uint16_t row0 = 0, rows = 0, width = 0;
  Content content = Content::UNDEFINED;
  uint8_t layout = 0;
  Bo role = Bo::IO;
  uint64_t bo_span = 0, owner_base_offset = 0;
  uint64_t row_stride = 0, batch_stride = 0, owner_extent_span = 0;
  uint64_t head_stride = 0, plane_stride = 0;
};

struct WriteGeometry {
  uint64_t first_offset = 0;
  uint32_t segment_bytes = 0;
  uint16_t row_count = 0, repeat_count = 0;
  uint64_t row_step = 0, repeat_step = 0, total_write_bytes = 0;
  Component component = Component::FULL_WIDTH;
  uint8_t head = 0, plane_mask = 0;
};

struct Request {
  Action action = Action::CLAIM;
  uint64_t event_seq = 0, origin_seq = 0;
  TaskContext context = portal::zero_context();
  Status reported_status = Status::OK;
  OutputUnit reported_unit = OutputUnit::NONE;
  uint32_t reported_elements = 0, reported_error_detail = 0;
  uint64_t reported_bad_element = 0;
  NumericIdentity identity;
  std::array<uint8_t, 416> model_identity{};
  uint8_t descriptor_count = 1;
  OutputUnit expected_unit = OutputUnit::NONE;
  uint32_t expected_elements = 0;
  uint64_t issued_store_bytes[2] = {};
  OwnerDescriptor descriptor[2];
  WriteGeometry geometry[2];
};

struct Response {
  Action action = Action::CLAIM;
  uint64_t event_seq = 0, origin_seq = 0;
  Status status = Status::E_INTERNAL;
  uint32_t error_detail = 0;
  uint64_t bad_element = UINT64_MAX;
  uint32_t output_elements = 0;
  OutputUnit unit = OutputUnit::NONE;
  bool drained = false, scope_active = false, owner_published = false;
  uint8_t descriptor_count = 0;
  uint64_t observed_store_bytes[2] = {};
  NumericIdentity identity;
  TaskContext context = portal::zero_context();
  BufferRef target_ref[2];
  uint8_t target_region[2] = {};
  BufferRef old_ref[2];
  uint8_t old_region[2] = {};
};

using RequestPacket = std::array<uint8_t, kRequestBytes>;
using ResponsePacket = std::array<uint8_t, kResponseBytes>;

RequestPacket encode(const Request&);
bool request_fields_valid(const Request&);
Check decode(const RequestPacket&, Request&);
ResponsePacket encode(const Response&);
Check decode(const ResponsePacket&, const Request&, Response&);

bool same_descriptor(const OwnerDescriptor&, const OwnerDescriptor&);
bool same_geometry(const WriteGeometry&, const WriteGeometry&);

} // namespace laya::provenance
