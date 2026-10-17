#include "laya_generated_provenance.h"

namespace laya::provenance {
namespace {

Check wire_error(unsigned byte) {
  return {Status::E_ABI, detail(4, 0, 22), byte};
}
Check protocol_error() {
  return {Status::E_PROTOCOL, detail(4, 0, 23)};
}
bool zeros(const uint8_t* p, unsigned first, unsigned end) {
  for (unsigned i = first; i < end; ++i) if (p[i]) return false;
  return true;
}
bool zero_context(const TaskContext& c) {
  return !c.task_id && !uint8_t(c.op) && !c.stage && !c.layer && !c.batch &&
         !uint8_t(c.row_space) && !c.row0 && !c.rows;
}
bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}
bool valid_action(uint64_t value) { return value >= 1 && value <= 6; }
bool valid_status(Status value) {
  return uint16_t(value) <= uint16_t(Status::E_INTERNAL);
}
bool valid_unit(OutputUnit value) { return uint8_t(value) <= 3; }

void put_descriptor(uint8_t* p, unsigned off, const OwnerDescriptor& d) {
  portal::put_ref(p, off, d.target_ref, d.target_region);
  portal::put_ref(p, off + 8, d.old_ref, d.old_region);
  p[off + 16] = d.stage; p[off + 17] = d.layer;
  p[off + 18] = d.batch; p[off + 19] = uint8_t(d.row_space);
  portal::put(p, off + 20, d.row0, 2); portal::put(p, off + 22, d.rows, 2);
  portal::put(p, off + 24, d.width, 2); p[off + 26] = uint8_t(d.content);
  p[off + 27] = d.layout; p[off + 28] = uint8_t(d.role);
  portal::put(p, off + 32, d.bo_span, 8);
  portal::put(p, off + 40, d.owner_base_offset, 8);
  portal::put(p, off + 48, d.row_stride, 8);
  portal::put(p, off + 56, d.batch_stride, 8);
  portal::put(p, off + 64, d.owner_extent_span, 8);
  portal::put(p, off + 72, d.head_stride, 8);
  portal::put(p, off + 80, d.plane_stride, 8);
}
OwnerDescriptor get_descriptor(const uint8_t* p, unsigned off) {
  OwnerDescriptor d;
  d.target_ref = portal::get_ref(p, off); d.target_region = p[off + 6];
  d.old_ref = portal::get_ref(p, off + 8); d.old_region = p[off + 14];
  d.stage = p[off + 16]; d.layer = p[off + 17]; d.batch = p[off + 18];
  d.row_space = RowSpace(p[off + 19]);
  d.row0 = uint16_t(portal::get(p, off + 20, 2));
  d.rows = uint16_t(portal::get(p, off + 22, 2));
  d.width = uint16_t(portal::get(p, off + 24, 2));
  d.content = Content(p[off + 26]); d.layout = p[off + 27];
  d.role = Bo(p[off + 28]); d.bo_span = portal::get(p, off + 32, 8);
  d.owner_base_offset = portal::get(p, off + 40, 8);
  d.row_stride = portal::get(p, off + 48, 8);
  d.batch_stride = portal::get(p, off + 56, 8);
  d.owner_extent_span = portal::get(p, off + 64, 8);
  d.head_stride = portal::get(p, off + 72, 8);
  d.plane_stride = portal::get(p, off + 80, 8);
  return d;
}
bool descriptor_ok(const OwnerDescriptor& d) {
  return d.target_ref.id != Buffer::NONE &&
         check_ref(d.target_ref, d.target_region) &&
         (d.old_ref.id == Buffer::NONE || check_ref(d.old_ref, d.old_region)) &&
         uint8_t(d.row_space) <= uint8_t(RowSpace::BATCH) &&
         d.rows && d.width && uint8_t(d.content) <= uint8_t(Content::PROB) &&
         d.layout <= 1 && uint8_t(d.role) <= uint8_t(Bo::ATT_OUT) &&
         d.bo_span && d.owner_extent_span &&
         d.owner_base_offset <= d.bo_span &&
         d.owner_extent_span <= d.bo_span - d.owner_base_offset &&
         ((d.layout == 0 && !d.head_stride && !d.plane_stride) ||
          (d.layout == 1 && d.head_stride && d.plane_stride));
}

void put_geometry(uint8_t* p, unsigned off, const WriteGeometry& g) {
  portal::put(p, off, g.first_offset, 8);
  portal::put(p, off + 8, g.segment_bytes, 4);
  portal::put(p, off + 12, g.row_count, 2);
  portal::put(p, off + 14, g.repeat_count, 2);
  portal::put(p, off + 16, g.row_step, 8);
  portal::put(p, off + 24, g.repeat_step, 8);
  portal::put(p, off + 32, g.total_write_bytes, 8);
  p[off + 40] = uint8_t(g.component); p[off + 41] = g.head;
  p[off + 42] = g.plane_mask;
}
WriteGeometry get_geometry(const uint8_t* p, unsigned off) {
  WriteGeometry g;
  g.first_offset = portal::get(p, off, 8);
  g.segment_bytes = uint32_t(portal::get(p, off + 8, 4));
  g.row_count = uint16_t(portal::get(p, off + 12, 2));
  g.repeat_count = uint16_t(portal::get(p, off + 14, 2));
  g.row_step = portal::get(p, off + 16, 8);
  g.repeat_step = portal::get(p, off + 24, 8);
  g.total_write_bytes = portal::get(p, off + 32, 8);
  g.component = Component(p[off + 40]); g.head = p[off + 41];
  g.plane_mask = p[off + 42]; return g;
}
bool geometry_ok(const WriteGeometry& g) {
  if (!g.segment_bytes || (g.segment_bytes & 3) || !g.row_count ||
      !g.repeat_count || uint8_t(g.component) > 2) return false;
  if ((g.row_count == 1) != (g.row_step == 0) ||
      (g.repeat_count == 1) != (g.repeat_step == 0)) return false;
  const uint64_t rows = uint64_t(g.segment_bytes) * g.row_count;
  if (rows / g.row_count != g.segment_bytes ||
      rows > UINT64_MAX / g.repeat_count ||
      g.total_write_bytes != rows * g.repeat_count) return false;
  if (g.component == Component::FULL_WIDTH)
    return g.head == 255 && !g.plane_mask;
  if (g.head >= 16) return false;
  return g.component == Component::ATT_HEAD ? !g.plane_mask :
         (g.plane_mask && !(g.plane_mask & ~7u));
}
bool zero_geometry(const WriteGeometry& g) {
  return !g.first_offset && !g.segment_bytes && !g.row_count &&
         !g.repeat_count && !g.row_step && !g.repeat_step &&
         !g.total_write_bytes && g.component == Component::FULL_WIDTH &&
         !g.head && !g.plane_mask;
}
bool request_fields_ok(const Request& r) {
  if (!r.event_seq || !r.identity.request_id || !r.identity.generation ||
      r.identity.B < 1 || r.identity.B > 2 ||
      r.identity.S < 64 || r.identity.S > 1024 ||
      r.descriptor_count < 1 || r.descriptor_count > 2 ||
      !valid_status(r.reported_status) || !valid_unit(r.reported_unit) ||
      !valid_unit(r.expected_unit)) return false;
  for (unsigned i = 0; i < r.descriptor_count; ++i)
    if (!descriptor_ok(r.descriptor[i])) return false;
  const bool task_event = r.action == Action::BEGIN || r.action == Action::END;
  if (!task_event) {
    if (!zero_context(r.context) || r.origin_seq ||
        r.reported_status != Status::OK || r.reported_unit != OutputUnit::NONE ||
        r.reported_elements || r.reported_error_detail ||
        r.reported_bad_element || r.expected_unit != OutputUnit::NONE ||
        r.expected_elements || r.issued_store_bytes[0] ||
        r.issued_store_bytes[1]) return false;
    for (unsigned i = 0; i < 2; ++i)
      if (!zero_geometry(r.geometry[i])) return false;
    return true;
  }
  if (!check_context(r.context, r.identity.B, r.identity.S) ||
      !r.context.task_id || r.expected_unit != OutputUnit::F32 ||
      !r.expected_elements) return false;
  for (unsigned i = 0; i < r.descriptor_count; ++i)
    if (!geometry_ok(r.geometry[i])) return false;
  if (r.action == Action::BEGIN)
    return r.origin_seq == r.event_seq && r.reported_status == Status::OK &&
           r.reported_unit == OutputUnit::NONE && !r.reported_elements &&
           !r.reported_error_detail && !r.reported_bad_element &&
           !r.issued_store_bytes[0] && !r.issued_store_bytes[1];
  if (!r.origin_seq || r.origin_seq == r.event_seq) return false;
  if (r.reported_status == Status::OK)
    return r.reported_unit == r.expected_unit &&
           r.reported_elements == r.expected_elements;
  return r.reported_unit == OutputUnit::NONE && !r.reported_elements;
}

} // namespace

bool request_fields_valid(const Request& r) {
  return valid_action(uint16_t(r.action)) && request_fields_ok(r);
}

bool same_descriptor(const OwnerDescriptor& a, const OwnerDescriptor& b) {
  return a.target_ref == b.target_ref && a.target_region == b.target_region &&
         a.old_ref == b.old_ref && a.old_region == b.old_region &&
         a.stage == b.stage && a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows &&
         a.width == b.width && a.content == b.content && a.layout == b.layout &&
         a.role == b.role && a.bo_span == b.bo_span &&
         a.owner_base_offset == b.owner_base_offset &&
         a.row_stride == b.row_stride && a.batch_stride == b.batch_stride &&
         a.owner_extent_span == b.owner_extent_span &&
         a.head_stride == b.head_stride && a.plane_stride == b.plane_stride;
}
bool same_geometry(const WriteGeometry& a, const WriteGeometry& b) {
  return a.first_offset == b.first_offset &&
         a.segment_bytes == b.segment_bytes && a.row_count == b.row_count &&
         a.repeat_count == b.repeat_count && a.row_step == b.row_step &&
         a.repeat_step == b.repeat_step &&
         a.total_write_bytes == b.total_write_bytes &&
         a.component == b.component && a.head == b.head &&
         a.plane_mask == b.plane_mask;
}

RequestPacket encode(const Request& r) {
  RequestPacket p{};
  portal::put(p.data(), 0, kRequestMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, uint16_t(r.action), 2);
  portal::put(p.data(), 8, r.event_seq, 8);
  portal::put(p.data(), 16, r.context.task_id, 4);
  portal::put(p.data(), 24, kRequestBeats, 2);
  portal::put(p.data(), 26, kResponseBeats, 2);
  portal::put(p.data(), 32, r.origin_seq, 8);
  portal::put(p.data(), 40, uint16_t(r.reported_status), 2);
  p[42] = uint8_t(r.reported_unit);
  portal::put(p.data(), 44, r.reported_elements, 4);
  portal::put(p.data(), 48, r.reported_error_detail, 4);
  portal::put(p.data(), 56, r.reported_bad_element, 8);
  portal::put_identity(p.data(), 64, r.identity);
  portal::put_context(p.data(), 148, r.context);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    p[160 + i] = r.model_identity[i];
  p[576] = r.descriptor_count; p[578] = uint8_t(r.expected_unit);
  portal::put(p.data(), 580, r.expected_elements, 4);
  portal::put(p.data(), 584, r.issued_store_bytes[0], 8);
  portal::put(p.data(), 592, r.issued_store_bytes[1], 8);
  for (unsigned i = 0; i < r.descriptor_count && i < 2; ++i) {
    put_descriptor(p.data(), 608 + 128 * i, r.descriptor[i]);
    if (r.action == Action::BEGIN || r.action == Action::END)
      put_geometry(p.data(), 864 + 64 * i, r.geometry[i]);
  }
  return p;
}

Check decode(const RequestPacket& p, Request& r) {
  if (portal::get(p.data(), 0, 4) != kRequestMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      !valid_action(portal::get(p.data(), 6, 2)) ||
      portal::get(p.data(), 24, 2) != kRequestBeats ||
      portal::get(p.data(), 26, 2) != kResponseBeats ||
      !zeros(p.data(), 20, 24) || !zeros(p.data(), 28, 32) ||
      p[43] || !zeros(p.data(), 52, 56) || p[577] || p[579] ||
      !zeros(p.data(), 600, 608) || !zeros(p.data(), 992, 1024))
    return wire_error(0);
  for (unsigned i = 0; i < 2; ++i) {
    const unsigned d = 608 + 128 * i, g = 864 + 64 * i;
    if (p[d + 7] || p[d + 15] || !zeros(p.data(), d + 29, d + 32) ||
        !zeros(p.data(), d + 88, d + 128) ||
        !zeros(p.data(), g + 43, g + 64)) return wire_error(d);
  }
  r = Request{};
  r.action = Action(portal::get(p.data(), 6, 2));
  r.event_seq = portal::get(p.data(), 8, 8);
  r.origin_seq = portal::get(p.data(), 32, 8);
  r.reported_status = Status(portal::get(p.data(), 40, 2));
  r.reported_unit = OutputUnit(p[42]);
  r.reported_elements = uint32_t(portal::get(p.data(), 44, 4));
  r.reported_error_detail = uint32_t(portal::get(p.data(), 48, 4));
  r.reported_bad_element = portal::get(p.data(), 56, 8);
  r.identity = portal::get_identity(p.data(), 64);
  r.context = portal::get_context(p.data(), 148);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    r.model_identity[i] = p[160 + i];
  r.descriptor_count = p[576]; r.expected_unit = OutputUnit(p[578]);
  r.expected_elements = uint32_t(portal::get(p.data(), 580, 4));
  r.issued_store_bytes[0] = portal::get(p.data(), 584, 8);
  r.issued_store_bytes[1] = portal::get(p.data(), 592, 8);
  for (unsigned i = 0; i < 2; ++i) {
    r.descriptor[i] = get_descriptor(p.data(), 608 + 128 * i);
    r.geometry[i] = get_geometry(p.data(), 864 + 64 * i);
  }
  if (uint32_t(portal::get(p.data(), 16, 4)) != r.context.task_id ||
      !request_fields_valid(r)) return wire_error(16);
  if (r.descriptor_count == 1 &&
      (!zeros(p.data(), 736, 864) || !zeros(p.data(), 928, 992)))
    return wire_error(736);
  return ok();
}

ResponsePacket encode(const Response& r) {
  ResponsePacket p{};
  portal::put(p.data(), 0, kResponseMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, uint16_t(r.action), 2);
  portal::put(p.data(), 8, r.event_seq, 8);
  portal::put(p.data(), 16, r.origin_seq, 8);
  portal::put(p.data(), 24, uint16_t(r.status), 2);
  p[26] = uint8_t(r.drained) | uint8_t(r.scope_active) << 1 |
          uint8_t(r.owner_published) << 2;
  portal::put(p.data(), 28, r.error_detail, 4);
  portal::put(p.data(), 32, r.bad_element, 8);
  portal::put(p.data(), 40, r.output_elements, 4); p[44] = uint8_t(r.unit);
  p[45] = r.descriptor_count;
  portal::put(p.data(), 48, r.observed_store_bytes[0], 8);
  portal::put(p.data(), 56, r.observed_store_bytes[1], 8);
  portal::put_identity(p.data(), 64, r.identity);
  portal::put_context(p.data(), 148, r.context);
  portal::put_ref(p.data(), 160, r.target_ref[0], r.target_region[0]);
  portal::put_ref(p.data(), 168, r.old_ref[0], r.old_region[0]);
  portal::put_ref(p.data(), 176, r.target_ref[1], r.target_region[1]);
  portal::put_ref(p.data(), 184, r.old_ref[1], r.old_region[1]);
  return p;
}

Check decode(const ResponsePacket& p, const Request& expected, Response& r) {
  if (portal::get(p.data(), 0, 4) != kResponseMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      !valid_action(portal::get(p.data(), 6, 2)) ||
      portal::get(p.data(), 24, 2) > uint16_t(Status::E_INTERNAL) ||
      (p[26] & ~7u) || p[27] || p[44] > 3 ||
      !zeros(p.data(), 46, 48) || !zeros(p.data(), 192, 512))
    return wire_error(0);
  for (unsigned off = 160; off < 192; off += 8)
    if (p[off + 7]) return wire_error(off);
  r = Response{};
  r.action = Action(portal::get(p.data(), 6, 2));
  r.event_seq = portal::get(p.data(), 8, 8);
  r.origin_seq = portal::get(p.data(), 16, 8);
  r.status = Status(portal::get(p.data(), 24, 2));
  r.drained = p[26] & 1; r.scope_active = p[26] & 2;
  r.owner_published = p[26] & 4;
  r.error_detail = uint32_t(portal::get(p.data(), 28, 4));
  r.bad_element = portal::get(p.data(), 32, 8);
  r.output_elements = uint32_t(portal::get(p.data(), 40, 4));
  r.unit = OutputUnit(p[44]); r.descriptor_count = p[45];
  r.observed_store_bytes[0] = portal::get(p.data(), 48, 8);
  r.observed_store_bytes[1] = portal::get(p.data(), 56, 8);
  r.identity = portal::get_identity(p.data(), 64);
  r.context = portal::get_context(p.data(), 148);
  r.target_ref[0] = portal::get_ref(p.data(), 160); r.target_region[0] = p[166];
  r.old_ref[0] = portal::get_ref(p.data(), 168); r.old_region[0] = p[174];
  r.target_ref[1] = portal::get_ref(p.data(), 176); r.target_region[1] = p[182];
  r.old_ref[1] = portal::get_ref(p.data(), 184); r.old_region[1] = p[190];
  const bool scope_valid = expected.action == Action::BEGIN ?
      r.scope_active == (r.status == Status::OK) :
      expected.action == Action::END ?
          (r.status != Status::OK || !r.scope_active) : !r.scope_active;
  if (r.action != expected.action || r.event_seq != expected.event_seq ||
      r.origin_seq != expected.origin_seq ||
      !numeric_identity_equal(r.identity, expected.identity) ||
      !same_context(r.context, expected.context) ||
      r.descriptor_count != expected.descriptor_count ||
      (r.status == Status::OK && !r.drained) ||
      !scope_valid ||
      (r.owner_published != (expected.action == Action::PUBLISH && r.status == Status::OK)))
    return protocol_error();
  for (unsigned i = 0; i < 2; ++i) {
    const bool used = i < expected.descriptor_count;
    if ((used && (r.target_ref[i] != expected.descriptor[i].target_ref ||
                  r.target_region[i] != expected.descriptor[i].target_region ||
                  r.old_ref[i] != expected.descriptor[i].old_ref ||
                  r.old_region[i] != expected.descriptor[i].old_region)) ||
        (!used && (r.target_ref[i].id != Buffer::NONE ||
                   r.old_ref[i].id != Buffer::NONE || r.target_region[i] ||
                   r.old_region[i] || r.observed_store_bytes[i])))
      return protocol_error();
  }
  if (expected.action == Action::END && r.status == Status::OK) {
    if (expected.reported_status != Status::OK ||
        r.output_elements != expected.expected_elements ||
        r.unit != expected.expected_unit) return protocol_error();
    for (unsigned i = 0; i < expected.descriptor_count; ++i)
      if (r.observed_store_bytes[i] != expected.issued_store_bytes[i])
        return protocol_error();
  } else if (r.output_elements || r.unit != OutputUnit::NONE ||
             (expected.action != Action::END &&
              (r.observed_store_bytes[0] || r.observed_store_bytes[1])))
    return protocol_error();
  return {r.status, r.error_detail, r.bad_element};
}

} // namespace laya::provenance
