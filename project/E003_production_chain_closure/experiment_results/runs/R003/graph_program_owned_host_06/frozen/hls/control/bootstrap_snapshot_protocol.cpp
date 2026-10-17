#include "laya_packet_equal.h"
#include "laya_bootstrap_snapshot.h"

namespace laya::bootstrap {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
bool zeros(const uint8_t* p, unsigned a, unsigned b) {
  for (unsigned i = a; i < b; ++i) if (p[i]) return false;
  return true;
}
void put_owner(uint8_t* p, const provenance::OwnerDescriptor& d) {
  portal::put_ref(p, 0, d.target_ref, d.target_region);
  portal::put_ref(p, 8, d.old_ref, d.old_region);
  p[16] = d.stage; p[17] = d.layer; p[18] = d.batch;
  p[19] = uint8_t(d.row_space);
  portal::put(p, 20, d.row0, 2); portal::put(p, 22, d.rows, 2);
  portal::put(p, 24, d.width, 2); p[26] = uint8_t(d.content);
  p[27] = d.layout; p[28] = uint8_t(d.role);
  portal::put(p, 32, d.bo_span, 8); portal::put(p, 40, d.owner_base_offset, 8);
  portal::put(p, 48, d.row_stride, 8); portal::put(p, 56, d.batch_stride, 8);
  portal::put(p, 64, d.owner_extent_span, 8);
  portal::put(p, 72, d.head_stride, 8); portal::put(p, 80, d.plane_stride, 8);
}
provenance::OwnerDescriptor get_owner(const uint8_t* p) {
  provenance::OwnerDescriptor d;
  d.target_ref = portal::get_ref(p, 0); d.target_region = p[6];
  d.old_ref = portal::get_ref(p, 8); d.old_region = p[14];
  d.stage = p[16]; d.layer = p[17]; d.batch = p[18];
  d.row_space = RowSpace(p[19]); d.row0 = uint16_t(portal::get(p, 20, 2));
  d.rows = uint16_t(portal::get(p, 22, 2)); d.width = uint16_t(portal::get(p, 24, 2));
  d.content = Content(p[26]); d.layout = p[27]; d.role = Bo(p[28]);
  d.bo_span = portal::get(p, 32, 8); d.owner_base_offset = portal::get(p, 40, 8);
  d.row_stride = portal::get(p, 48, 8); d.batch_stride = portal::get(p, 56, 8);
  d.owner_extent_span = portal::get(p, 64, 8);
  d.head_stride = portal::get(p, 72, 8); d.plane_stride = portal::get(p, 80, 8);
  return d;
}
Packet binding_packet(const Request& r, uint32_t magic) {
  Packet p{};
  portal::put(p.data(), 0, magic, 4); portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kBeats, 2); portal::put(p.data(), 8, uint16_t(r.purpose), 2);
  portal::put(p.data(), 16, r.sequence, 8); portal::put(p.data(), 40, r.base_epoch, 8);
  portal::put(p.data(), 48, r.base_address, 8);
  portal::put(p.data(), 56, r.base_capacity, 8);
  portal::put_identity(p.data(), kIdentity, r.identity);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    p[kModel + i] = r.model_identity[i];
  put_owner(p.data() + kOwner, r.source);
  return p;
}
Request get_binding(const uint8_t* p) {
  Request r;
  r.purpose = Purpose(portal::get(p, 8, 2)); r.sequence = portal::get(p, 16, 8);
  r.base_epoch = portal::get(p, 40, 8); r.base_address = portal::get(p, 48, 8);
  r.base_capacity = portal::get(p, 56, 8);
  r.identity = portal::get_identity(p, kIdentity);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    r.model_identity[i] = p[kModel + i];
  r.source = get_owner(p + kOwner);
  return r;
}
bool header(const uint8_t* p, uint32_t magic) {
  return portal::get(p, 0, 4) == magic && portal::get(p, 4, 2) == kVersion &&
      portal::get(p, 6, 2) == kBeats && zeros(p, 28, 32) &&
      zeros(p, 148, kModel) && !p[kOwner + 7] && !p[kOwner + 15] &&
      zeros(p, kOwner + 29, kOwner + 32) && zeros(p, kOwner + 88, kBytes);
}
Check validate_fields(const Request& r, Purpose purpose) {
#pragma HLS inline off
  const auto& d = r.source;
  if (purpose != Purpose::NORM_LAYER1_ATTN || !r.sequence || !r.base_epoch ||
      !r.base_address || (r.base_address & 63) || !r.base_capacity ||
      r.base_capacity > UINT64_MAX - r.base_address ||
      !numeric_identity_valid(r.identity) || !check_ref(d.target_ref, d.target_region) ||
      d.target_ref.id != Buffer::HIDDEN || d.target_ref.bank != 0 || d.target_region ||
      d.old_ref.id != Buffer::NONE || d.old_ref.bank || d.old_ref.epoch || d.old_region ||
      d.stage != 2 || d.layer != 0 || d.batch != 255 ||
      d.row_space != RowSpace::TOKEN || d.row0 || d.rows != r.identity.S ||
      d.width != 1024 || d.content != Content::F32 || d.layout || d.head_stride ||
      d.plane_stride || d.role != Bo::STATE0 || d.owner_base_offset ||
      d.bo_span != r.base_capacity || d.bo_span < 8ull * 1024 * 1024 ||
      d.row_stride != 4096 || d.batch_stride != 4194304 ||
      d.owner_extent_span != uint64_t(r.identity.B - 1) * 4194304 +
          uint64_t(r.identity.S) * 4096 || d.owner_extent_span > d.bo_span)
    return protocol();
  portal::ModelBinding model;
  model.identity = r.model_identity;
  // LYMP has already been read by request admission.  This check is the L13M
  // wire contract; it never treats a response's tags as a replacement header.
  Check canonical = portal::build_l13m_model_binding(model);
  if (!canonical || !packet_equal(model.identity, r.model_identity)) return protocol();
  return portal::validate_l13m_model_binding(r.identity, model);
}

} // namespace

Check validate(const Request& r) {
#pragma HLS inline
  // The nested Request can share a packed parent Message memory. Extract the
  // actual field in that caller context before crossing the validator boundary;
  // all remaining source and model checks are unchanged.
  return validate_fields(r, r.purpose);
}

bool same_binding(const Request& a, const Request& b) {
  const auto& x = a.source;
  const auto& y = b.source;
  return a.purpose == b.purpose && a.sequence == b.sequence &&
      a.base_epoch == b.base_epoch && a.base_address == b.base_address &&
      a.base_capacity == b.base_capacity && numeric_identity_equal(a.identity, b.identity) &&
      packet_equal(a.model_identity, b.model_identity) && x.target_ref == y.target_ref &&
      x.target_region == y.target_region && x.old_ref == y.old_ref &&
      x.old_region == y.old_region && x.stage == y.stage && x.layer == y.layer &&
      x.batch == y.batch && x.row_space == y.row_space && x.row0 == y.row0 &&
      x.rows == y.rows && x.width == y.width && x.content == y.content &&
      x.layout == y.layout && x.role == y.role && x.bo_span == y.bo_span &&
      x.owner_base_offset == y.owner_base_offset && x.row_stride == y.row_stride &&
      x.batch_stride == y.batch_stride && x.owner_extent_span == y.owner_extent_span &&
      x.head_stride == y.head_stride && x.plane_stride == y.plane_stride;
}
Packet encode(const Request& r) { return binding_packet(r, kRequestMagic); }
Packet encode(const Response& r) {
  Packet p = binding_packet(r.binding, kResponseMagic);
  portal::put(p.data(), 10, uint16_t(r.result.code), 2);
  portal::put(p.data(), 12, r.flags, 4); portal::put(p.data(), 24, r.result.detail, 4);
  portal::put(p.data(), 32, r.result.bad_element, 8);
  return p;
}
Check decode(const Packet& p, Request& out) {
  out = Request{};
  if (!header(p.data(), kRequestMagic) || !zeros(p.data(), 10, 16) ||
      !zeros(p.data(), 24, 40)) return protocol();
  Request decoded = get_binding(p.data());
  Check valid = validate(decoded);
  if (!valid) return valid;
  out = decoded;
  return ok();
}
Check decode(const Packet& p, const Request& expected, Response& out) {
  out = Response{};
  if (!header(p.data(), kResponseMagic)) return protocol();
  Response decoded;
  decoded.binding = get_binding(p.data());
  decoded.flags = uint32_t(portal::get(p.data(), 12, 4));
  decoded.result = {Status(portal::get(p.data(), 10, 2)),
                    uint32_t(portal::get(p.data(), 24, 4)),
                    portal::get(p.data(), 32, 8)};
  if (!validate(decoded.binding) || !same_binding(expected, decoded.binding) ||
      uint16_t(decoded.result.code) > uint16_t(Status::E_INTERNAL) ||
      (decoded.result ? decoded.flags != kSuccessFlags :
                       decoded.flags != (FRAME_COMPLETE | BINDING_OK)))
    return protocol();
  out = decoded;
  return decoded.result;
}
} // namespace laya::bootstrap
