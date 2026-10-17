#include "laya_packet_equal.h"
#include "laya_admission_owner.h"

namespace laya::admission_owner {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7,0,14)}; }
bool zeros(const uint8_t* p,unsigned begin,unsigned end) {
  for(unsigned i=begin;i<end;++i)if(p[i])return false;
  return true;
}
}
Check validate(const Record& r) {
  if(!r.session || !r.accepted_request || !numeric_identity_valid(r.identity) ||
     !r.physical.known_roles || (r.physical.known_roles & ~kAllRoles))return protocol();
  portal::ModelBinding canonical;
  Check c=portal::build_l13m_model_binding(canonical);
  if(!c)return c;
  if(!packet_equal(canonical.identity,r.model_identity))return {Status::E_MODEL,detail(4,0,4)};
  c=portal::validate_l13m_model_binding(r.identity,canonical);
  if(!c)return c;
  for(unsigned i=0;i<kRoles;++i) {
    const auto& m=r.physical.role[i];
    if((r.physical.known_roles>>i)&1u) {
      if(!m.epoch || !m.address || (m.address&63) || !m.capacity ||
         m.capacity>UINT64_MAX-m.address)return protocol();
    } else if(m.epoch || m.address || m.capacity)return protocol();
  }
  return ok();
}
Packet encode(const Record& r) {
  Packet p{};
  portal::put(p.data(),0,kMagic,4);portal::put(p.data(),4,kVersion,2);
  portal::put(p.data(),6,kBeats,2);portal::put(p.data(),8,kKnownComplete,4);
  portal::put(p.data(),12,r.physical.known_roles,4);
  portal::put(p.data(),16,r.session,8);portal::put(p.data(),24,r.accepted_request,8);
  portal::put_identity(p.data(),kIdentity,r.identity);
  for(unsigned i=0;i<416;++i)p[kModel+i]=r.model_identity[i];
  for(unsigned i=0;i<kRoles;++i) {
    const auto& m=r.physical.role[i];const unsigned at=kMappings+i*kMappingBytes;
    portal::put(p.data(),at,m.epoch,8);portal::put(p.data(),at+8,m.address,8);
    portal::put(p.data(),at+16,m.capacity,8);
  }
  return p;
}
Check decode(const Packet& p,Record& out) {
  out=Record{};
  if(portal::get(p.data(),0,4)!=kMagic || portal::get(p.data(),4,2)!=kVersion ||
     portal::get(p.data(),6,2)!=kBeats || portal::get(p.data(),8,4)!=kKnownComplete ||
     !zeros(p.data(),32,64) || !zeros(p.data(),148,160) ||
     !zeros(p.data(),kReserved,kBytes))return protocol();
  Record r;r.session=portal::get(p.data(),16,8);r.accepted_request=portal::get(p.data(),24,8);
  r.identity=portal::get_identity(p.data(),kIdentity);
  r.physical.known_roles=uint32_t(portal::get(p.data(),12,4));
  for(unsigned i=0;i<416;++i)r.model_identity[i]=p[kModel+i];
  for(unsigned i=0;i<kRoles;++i) {
    auto& m=r.physical.role[i];const unsigned at=kMappings+i*kMappingBytes;
    m.epoch=portal::get(p.data(),at,8);m.address=portal::get(p.data(),at+8,8);
    m.capacity=portal::get(p.data(),at+16,8);
  }
  Check c=validate(r);if(c)out=r;return c;
}
Check capture(const full::FullRuntime& rt,const full::FullMemory& memory,
              uint64_t session,uint64_t accepted_request,const PhysicalMap& physical,Record& out) {
  out=Record{};
  if(!rt.request_valid || !rt.model_header_valid)return protocol();
  Record r;r.session=session;r.accepted_request=accepted_request;
  r.identity=rt.inputs.identity;r.physical=physical;
  portal::ModelBinding model;Check c=portal::build_l13m_model_binding(model);
  if(!c)return c;
  r.model_identity=model.identity;
  c=validate(r);if(!c)return c;
  for(unsigned i=0;i<kRoles;++i)
    if((physical.known_roles>>i)&1u)
      if(physical.role[i].capacity!=full::full_bo_capacity(memory,Bo(i)))return protocol();
  out=r;return ok();
}
bool same(const Record& a,const Record& b) { return packet_equal(encode(a),encode(b)); }
} // namespace laya::admission_owner
