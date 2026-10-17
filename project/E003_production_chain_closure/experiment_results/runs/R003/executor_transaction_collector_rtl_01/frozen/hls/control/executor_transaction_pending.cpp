#include "laya_executor_transaction_pending.h"
#include "laya_packet_equal.h"

namespace laya::transaction_pending {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
bool key_shape(const Key& k) {
  return k.session && k.accepted_request &&
      (k.has_hold ? (k.source_sequence && k.handoff_epoch) :
                    (!k.source_sequence && !k.handoff_epoch));
}
#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
bool zeros(const uint8_t* p, unsigned begin, unsigned end) {
  for (unsigned i=begin; i<end; ++i) if (p[i]) return false;
  return true;
}
const NumericIdentity& identity(const transaction::Request& r) {
  if (r.kind == transaction::Kind::COMPUTE_TRANSACTION) return r.compute.identity;
  if (r.kind == transaction::Kind::PROVENANCE_TRANSACTION) return r.provenance.identity;
  return r.producer.identity;
}
const std::array<uint8_t,416>& model(const transaction::Request& r) {
  if (r.kind == transaction::Kind::COMPUTE_TRANSACTION) return r.compute.model_identity;
  if (r.kind == transaction::Kind::PROVENANCE_TRANSACTION) return r.provenance.model_identity;
  return r.producer.model_identity;
}
#endif
} // namespace

bool same_key(const Key& a, const Key& b) {
  return a.session == b.session && a.accepted_request == b.accepted_request &&
      a.source_sequence == b.source_sequence && a.handoff_epoch == b.handoff_epoch &&
      a.has_hold == b.has_hold;
}
Check validate_metadata(const Record& r, const Key& expected, uint8_t expected_route) {
  return r.route <= 1 && expected_route <= 1 && r.route == expected_route &&
      key_shape(r.key) && key_shape(expected) && same_key(r.key, expected) ? ok() : protocol();
}
Packet encode(const Record& r) {
  Packet p{};
  portal::put(p.data(), 0, kMagic, 4); portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kBeats, 2); p[8]=r.route; p[9]=r.key.has_hold ? HAS_HOLD : 0;
  portal::put(p.data(), 16, r.key.session, 8);
  portal::put(p.data(), 24, r.key.accepted_request, 8);
  portal::put(p.data(), 32, r.key.source_sequence, 8);
  portal::put(p.data(), 40, r.key.handoff_epoch, 8);
  for (unsigned i=0; i<action::kRequestBytes; ++i) {
#pragma HLS unroll off
    p[kAction+i]=r.action_packet[i];
  }
  for (unsigned i=0; i<transaction::kRequestBytes; ++i) {
#pragma HLS unroll off
    p[kTransaction+i]=r.transaction_packet[i];
  }
  return p;
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
Check validate(const Record& r, const admission_owner::Record& owner,
               const Key& expected, uint8_t expected_route) {
  Check c=validate_metadata(r, expected, expected_route); if (!c) return c;
  c=admission_owner::validate(owner); if (!c) return c;
  if (r.key.session != owner.session || r.key.accepted_request != owner.accepted_request)
    return protocol();
  action::Request a;
  c=action::decode(r.action_packet, a); if (!c) return c;
  if (!packet_equal(action::encode(a), r.action_packet)) return protocol();
  transaction::Request t;
  c=transaction::decode(r.transaction_packet, t); if (!c) return c;
  if (!packet_equal(transaction::encode(t), r.transaction_packet)) return protocol();
  if (!numeric_identity_equal(a.identity, owner.identity) ||
      !numeric_identity_equal(identity(t), owner.identity) ||
      !packet_equal(model(t), owner.model_identity)) return protocol();
  // LAX has no model/K/route fields, and LTX has no action ordinal/PC. Full
  // linkage comes from the original FSM snapshot plus the strict overload,
  // not from inventing a relation between otherwise absent wire fields.
  return ok();
}
Check capture(const Key& key, uint8_t route, const action::RequestPacket& action_packet,
              const transaction::RequestPacket& transaction_packet,
              const admission_owner::Record& owner, Record& out) {
  Record r; r.key=key; r.route=route;
  r.action_packet=action_packet; r.transaction_packet=transaction_packet;
  out=Record{};
  Check c=validate(r, owner, key, route); if (c) out=r;
  return c;
}
Check decode(const Packet& p, const admission_owner::Record& owner,
             const Key& expected, uint8_t expected_route, Record& out) {
  out=Record{};
  if (portal::get(p.data(),0,4)!=kMagic || portal::get(p.data(),4,2)!=kVersion ||
      portal::get(p.data(),6,2)!=kBeats || (p[9]&~HAS_HOLD) ||
      !zeros(p.data(),10,16) || !zeros(p.data(),48,64)) return protocol();
  Record r; r.route=p[8]; r.key.has_hold=p[9]&HAS_HOLD;
  r.key.session=portal::get(p.data(),16,8);
  r.key.accepted_request=portal::get(p.data(),24,8);
  r.key.source_sequence=portal::get(p.data(),32,8);
  r.key.handoff_epoch=portal::get(p.data(),40,8);
  for (unsigned i=0; i<action::kRequestBytes; ++i) r.action_packet[i]=p[kAction+i];
  for (unsigned i=0; i<transaction::kRequestBytes; ++i) r.transaction_packet[i]=p[kTransaction+i];
  Check c=validate(r, owner, expected, expected_route);
  if (!c) return c;
  if (!packet_equal(encode(r),p)) return protocol();
  out=r; return ok();
}
bool same_record(const Record& a, const Record& b) {
  return a.route==b.route && same_key(a.key,b.key) &&
      packet_equal(a.action_packet,b.action_packet) &&
      packet_equal(a.transaction_packet,b.transaction_packet);
}
Check decode(const Packet& p, const admission_owner::Record& owner,
             const Record& expected, Record& out) {
  out=Record{};
  Check c=validate(expected,owner,expected.key,expected.route); if (!c) return c;
  Record r; c=decode(p,owner,expected.key,expected.route,r); if (!c) return c;
  if (!same_record(r,expected)) return protocol();
  out=r; return ok();
}
bool managed_cleanup_candidate(const transaction::Request& r) {
  return r.kind==transaction::Kind::PROVENANCE_TRANSACTION &&
      r.flags==uint32_t(transaction::CANCEL_CLEANUP) &&
      (r.provenance.action==provenance::Action::END ||
       r.provenance.action==provenance::Action::INVALIDATE);
}
bool managed_cleanup_candidate(const Record& r) {
  transaction::Request t;
  return bool(transaction::decode(r.transaction_packet,t)) &&
      packet_equal(transaction::encode(t),r.transaction_packet) && managed_cleanup_candidate(t);
}
#endif
} // namespace laya::transaction_pending
