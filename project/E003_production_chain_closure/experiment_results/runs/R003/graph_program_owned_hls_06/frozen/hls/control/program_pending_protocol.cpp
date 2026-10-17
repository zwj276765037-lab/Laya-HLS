#include "laya_packet_equal.h"
#include "laya_program_pending_protocol.h"
namespace laya::program_pending {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
}
bool same_key(const Key& a, const Key& b) {
  return a.session == b.session && a.accepted_request == b.accepted_request &&
      a.sequence == b.sequence && a.handoff == b.handoff;
}
Check validate(const Record& r) {
  if (!r.key.session || !r.key.accepted_request || !r.key.sequence ||
      !r.key.handoff || !program_wire::validate(r.command) ||
      !action::validate(r.action)) return protocol();
  // This diagnostic program has one precisely defined entry point. The
  // program supplies its actual allocated ordinal; all other semantics are
  // checked against the accepted command without allocating another action.
  action::Request expected;
  expected.kind = action::Kind::NORM; expected.pc = 0;
  expected.op = Op::LN_ATTN; expected.stage = 2; expected.layer = 1;
  expected.ordinal = r.action.ordinal; expected.identity = r.command.identity;
  expected.source = r.command.source;
  expected.target_slot = 1; expected.target_slot_version = 1;
  expected.target_buffer = Buffer::NORM; expected.weight.layer = 255;
  return packet_equal(action::encode(expected), action::encode(r.action)) ? ok() : protocol();
}
Packet encode(const Record& r) {
  Packet p{};
  portal::put(p.data(), 0, kMagic, 4); portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kBeats, 2); p[8] = 1;
  portal::put(p.data(), 16, r.key.session, 8);
  portal::put(p.data(), 24, r.key.accepted_request, 8);
  portal::put(p.data(), 32, r.key.sequence, 8);
  portal::put(p.data(), 40, r.key.handoff, 8);
  const auto c = program_wire::encode(r.command);
  const auto a = action::encode(r.action);
  for (unsigned i = 0; i < c.size(); ++i) p[kCommand + i] = c[i];
  for (unsigned i = 0; i < a.size(); ++i) p[kAction + i] = a[i];
  return p;
}
Check decode(const Packet& p, Record& out) {
  out = Record{};
  if (portal::get(p.data(), 0, 4) != kMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      portal::get(p.data(), 6, 2) != kBeats || p[8] != 1) return protocol();
  for (unsigned i = 9; i < 256; ++i)
    if ((i < 16 || i >= 48) && p[i]) return protocol();
  Record r;
  r.key = {portal::get(p.data(), 16, 8), portal::get(p.data(), 24, 8),
           portal::get(p.data(), 32, 8), portal::get(p.data(), 40, 8)};
  program_wire::CommandPacket c{}; action::RequestPacket a{};
  for (unsigned i = 0; i < c.size(); ++i) c[i] = p[kCommand + i];
  for (unsigned i = 0; i < a.size(); ++i) a[i] = p[kAction + i];
  if (!program_wire::decode(c, r.command) || !action::decode(a, r.action) ||
      !validate(r)) return protocol();
  out = r; return ok();
}
} // namespace laya::program_pending
