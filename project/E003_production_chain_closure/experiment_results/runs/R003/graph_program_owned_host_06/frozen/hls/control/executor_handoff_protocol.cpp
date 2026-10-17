#include "laya_packet_equal.h"
#include "laya_executor_handoff_protocol.h"
namespace laya::handoff {
namespace { Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; } }
Check validate(const Message& m) {
  if (!m.session || !m.accepted_request || !checkpoint::validate_description(m.binding) ||
      uint16_t(m.result.code) > uint16_t(Status::E_INTERNAL)) return protocol();
  switch (m.kind) {
    case Kind::HOLD:
      if (m.binding.handoff_epoch || m.local_committed || !m.result) return protocol();
      break;
    case Kind::HELD:
      if (!m.binding.handoff_epoch || m.local_committed || !m.result) return protocol();
      break;
    case Kind::IMPORT_OK: case Kind::GRANTED:
      if (!m.binding.handoff_epoch || !m.local_committed || !m.result) return protocol();
      break;
    case Kind::ABORT:
      if (!m.binding.handoff_epoch || m.result) return protocol();
      break;
    case Kind::ABORT_CLOSED: case Kind::REJECT:
      if (!m.binding.handoff_epoch || m.local_committed || m.result) return protocol();
      break;
    case Kind::CLOSE: case Kind::CLOSED:
      // The status is the sealed request result, including a non-OK result
      // for a safely closed failed request. Commit is an echoed retained fact.
      if (!m.binding.handoff_epoch) return protocol();
      break;
    default: return protocol();
  }
  if (m.result && (m.result.detail || m.result.bad_element != UINT64_MAX)) return protocol();
  return ok();
}
bool same_key(const Message& a, const Message& b) {
  return a.session == b.session && a.accepted_request == b.accepted_request &&
      checkpoint::same_binding(a.binding, b.binding);
}
Packet encode(const Message& m) {
  Packet p = checkpoint::encode(m.binding);
  portal::put(p.data(), 0, kMagic, 4); portal::put(p.data(), 4, kVersion, 2);
  p[8] = uint8_t(m.kind);
  portal::put(p.data(), 10, uint16_t(m.result.code), 2);
  portal::put(p.data(), 24, m.result.detail, 4);
  portal::put(p.data(), 32, m.result.bad_element, 8);
  portal::put(p.data(), kSession, m.session, 8);
  portal::put(p.data(), kAcceptedRequest, m.accepted_request, 8);
  p[kCommitted] = m.local_committed;
  return p;
}
Check decode(const Packet& p, Message& out) {
  out = Message{};
  if (portal::get(p.data(), 0, 4) != kMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      portal::get(p.data(), 6, 2) != kBeats || p[kCommitted] > 1) return protocol();
  Message m;
  m.kind = Kind(p[8]); m.session = portal::get(p.data(), kSession, 8);
  m.accepted_request = portal::get(p.data(), kAcceptedRequest, 8);
  m.local_committed = p[kCommitted];
  m.result = {Status(portal::get(p.data(), 10, 2)),
      uint32_t(portal::get(p.data(), 24, 4)), portal::get(p.data(), 32, 8)};
  // Decode the source binding with its original v1 parser, clearing only
  // fields owned by this independent control header.
  bootstrap::Packet source{};
  for (unsigned i = 0; i < 664; ++i) source[i] = p[i];
  portal::put(source.data(), 0, bootstrap::kRequestMagic, 4);
  portal::put(source.data(), 4, bootstrap::kVersion, 2);
  portal::put(source.data(), 6, bootstrap::kBeats, 2);
  source[8] = 1; source[9] = 0;
  for (unsigned i = 10; i < 16; ++i) source[i] = 0;
  for (unsigned i = 24; i < 40; ++i) source[i] = 0;
  if (!bootstrap::decode(source, m.binding.source)) return protocol();
  m.binding.mode = uint16_t(portal::get(p.data(), 672, 2));
  m.binding.handoff_epoch = portal::get(p.data(), 680, 8);
  auto& t = m.binding.target;
  t.buffer = Buffer(p[674]); t.bank = p[675]; t.region = p[676]; t.role = Bo(p[677]);
  t.base_epoch = portal::get(p.data(), 688, 8);
  t.base_address = portal::get(p.data(), 696, 8);
  t.capacity = portal::get(p.data(), 704, 8); t.offset = portal::get(p.data(), 712, 8);
  t.extent = portal::get(p.data(), 720, 8); t.row_stride = portal::get(p.data(), 728, 8);
  t.batch_stride = portal::get(p.data(), 736, 8);
  // Canonical full-frame equality checks every reserved byte and all binding
  // fields. No short hash is used as the ownership key.
  if (!validate(m) || !packet_equal(encode(m), p)) return protocol();
  out = m; return ok();
}
} // namespace laya::handoff
