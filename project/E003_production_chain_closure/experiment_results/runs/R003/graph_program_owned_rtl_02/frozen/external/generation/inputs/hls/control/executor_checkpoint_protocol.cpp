#include "laya_executor_checkpoint.h"

namespace laya::checkpoint {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
bool zero(const Packet& p, unsigned a, unsigned b) {
  for (unsigned i = a; i < b; ++i) if (p[i]) return false;
  return true;
}
Packet binding_packet(const Request& r, uint32_t magic) {
  Packet p{};
  const auto v1 = bootstrap::encode(r.source);
  for (unsigned i = 0; i < 664; ++i) p[i] = v1[i];
  portal::put(p.data(), 0, magic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kBeats, 2);
  portal::put(p.data(), kModeOffset, r.mode, 2);
  p[kTarget] = uint8_t(r.target.buffer); p[kTarget + 1] = r.target.bank;
  p[kTarget + 2] = r.target.region; p[kTarget + 3] = uint8_t(r.target.role);
  portal::put(p.data(), kHandoff, r.handoff_epoch, 8);
  const uint64_t values[] = {r.target.base_epoch, r.target.base_address,
      r.target.capacity, r.target.offset, r.target.extent,
      r.target.row_stride, r.target.batch_stride};
  for (unsigned i = 0; i < 7; ++i)
    portal::put(p.data(), kTargetBase + i * 8, values[i], 8);
  return p;
}
bool header(const Packet& p, uint32_t magic) {
  return portal::get(p.data(), 0, 4) == magic &&
      portal::get(p.data(), 4, 2) == kVersion &&
      portal::get(p.data(), 6, 2) == kBeats &&
      zero(p, 28, 32) && zero(p, 664, 672) && !p[679] &&
      zero(p, 764, 768) && zero(p, 776, kBytes);
}
Check binding(const Packet& p, Request& r) {
  bootstrap::Packet prefix{};
  for (unsigned i = 0; i < 664; ++i) prefix[i] = p[i];
  portal::put(prefix.data(), 0, bootstrap::kRequestMagic, 4);
  portal::put(prefix.data(), 4, bootstrap::kVersion, 2);
  portal::put(prefix.data(), 6, bootstrap::kBeats, 2);
  // These fields belong to the v2 response, not its echoed request binding.
  for (unsigned i = 10; i < 16; ++i) prefix[i] = 0;
  for (unsigned i = 24; i < 40; ++i) prefix[i] = 0;
  Check c = bootstrap::decode(prefix, r.source);
  if (!c) return c;
  r.mode = uint16_t(portal::get(p.data(), kModeOffset, 2));
  r.handoff_epoch = portal::get(p.data(), kHandoff, 8);
  r.target.buffer = Buffer(p[kTarget]); r.target.bank = p[kTarget + 1];
  r.target.region = p[kTarget + 2]; r.target.role = Bo(p[kTarget + 3]);
  r.target.base_epoch = portal::get(p.data(), 688, 8);
  r.target.base_address = portal::get(p.data(), 696, 8);
  r.target.capacity = portal::get(p.data(), 704, 8);
  r.target.offset = portal::get(p.data(), 712, 8);
  r.target.extent = portal::get(p.data(), 720, 8);
  r.target.row_stride = portal::get(p.data(), 728, 8);
  r.target.batch_stride = portal::get(p.data(), 736, 8);
  return validate(r);
}
} // namespace
Check validate_description(const Request& r) {
  const auto& t = r.target;
  if (!bootstrap::validate(r.source) || r.mode != kMode ||
      t.buffer != Buffer::NORM || t.bank || t.region || t.role != Bo::STATE0 ||
      t.base_epoch != r.source.base_epoch || t.base_address != r.source.base_address ||
      t.capacity != r.source.base_capacity || t.offset != 8ull * 1024 * 1024 ||
      t.extent != r.source.source.owner_extent_span || t.row_stride != 4096 ||
      t.batch_stride != 4194304 || t.offset > t.capacity ||
      t.extent > t.capacity - t.offset)
    return protocol();
  return ok();
}
Check validate(const Request& r) {
  return r.handoff_epoch ? validate_description(r) : protocol();
}
Check validate(const Response& r) {
  if (!validate(r.binding) || uint16_t(r.result.code) > uint16_t(Status::E_INTERNAL))
    return protocol();
  if (!r.result) {
    if (r.flags != (bootstrap::FRAME_COMPLETE | bootstrap::BINDING_OK) ||
        r.known || r.complete || r.task_floor || r.source_epoch_floor ||
        r.target_epoch_floor || r.lpv_floor || r.target_state != TargetState::UNKNOWN)
      return protocol();
    return ok();
  }
  if (r.flags != kSuccessFlags || r.known != kDomains || r.complete != kDomains ||
      !r.task_floor || r.task_floor > kMaxEpoch ||
      r.source_epoch_floor < r.binding.source.source.target_ref.epoch ||
      r.source_epoch_floor > kMaxEpoch || r.target_epoch_floor > kMaxEpoch ||
      (r.target_state != TargetState::UNUSED && r.target_state != TargetState::INACTIVE) ||
      (r.target_state == TargetState::UNUSED && r.target_epoch_floor) ||
      (r.target_state == TargetState::INACTIVE && !r.target_epoch_floor) ||
      !r.lpv_floor)
    return protocol();
  return ok();
}
bool same_binding(const Request& a, const Request& b) {
  const auto& x = a.target; const auto& y = b.target;
  return bootstrap::same_binding(a.source, b.source) && a.mode == b.mode &&
      a.handoff_epoch == b.handoff_epoch && x.buffer == y.buffer && x.bank == y.bank &&
      x.region == y.region && x.role == y.role && x.base_epoch == y.base_epoch &&
      x.base_address == y.base_address && x.capacity == y.capacity &&
      x.offset == y.offset && x.extent == y.extent &&
      x.row_stride == y.row_stride && x.batch_stride == y.batch_stride;
}
Packet encode(const Request& r) { return binding_packet(r, kRequestMagic); }
Packet encode(const Response& r) {
  Packet p = binding_packet(r.binding, kResponseMagic);
  portal::put(p.data(), 10, uint16_t(r.result.code), 2);
  portal::put(p.data(), 12, r.flags, 4); portal::put(p.data(), 24, r.result.detail, 4);
  portal::put(p.data(), 32, r.result.bad_element, 8);
  p[kTargetState] = uint8_t(r.target_state);
  portal::put(p.data(), kKnown, r.known, 4);
  portal::put(p.data(), kComplete, r.complete, 4);
  portal::put(p.data(), kTask, r.task_floor, 4);
  portal::put(p.data(), kSourceEpoch, r.source_epoch_floor, 4);
  portal::put(p.data(), kTargetEpoch, r.target_epoch_floor, 4);
  portal::put(p.data(), kLpv, r.lpv_floor, 8);
  return p;
}
Check decode(const Packet& p, Request& out) {
  out = Request{};
  if (!header(p, kRequestMagic) || !zero(p, 10, 16) || !zero(p, 24, 40) ||
      p[kTargetState] || !zero(p, kKnown, 764) || !zero(p, kLpv, 776))
    return protocol();
  Request decoded;
  Check c = binding(p, decoded);
  if (!c) return c;
  out = decoded; return ok();
}
Check decode(const Packet& p, const Request& expected, Response& out) {
  out = Response{};
  if (!header(p, kResponseMagic)) return protocol();
  Response decoded;
  if (!binding(p, decoded.binding) || !same_binding(expected, decoded.binding))
    return protocol();
  decoded.result = {Status(portal::get(p.data(), 10, 2)),
      uint32_t(portal::get(p.data(), 24, 4)), portal::get(p.data(), 32, 8)};
  decoded.flags = uint32_t(portal::get(p.data(), 12, 4));
  decoded.target_state = TargetState(p[kTargetState]);
  decoded.known = uint32_t(portal::get(p.data(), kKnown, 4));
  decoded.complete = uint32_t(portal::get(p.data(), kComplete, 4));
  decoded.task_floor = uint32_t(portal::get(p.data(), kTask, 4));
  decoded.source_epoch_floor = uint32_t(portal::get(p.data(), kSourceEpoch, 4));
  decoded.target_epoch_floor = uint32_t(portal::get(p.data(), kTargetEpoch, 4));
  decoded.lpv_floor = portal::get(p.data(), kLpv, 8);
  if (!validate(decoded)) return protocol();
  out = decoded; return decoded.result;
}
} // namespace laya::checkpoint
