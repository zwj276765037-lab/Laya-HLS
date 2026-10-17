#include "laya_executor_transaction_pending.h"
#ifdef LAYA_TRANSACTION_SEQUENCER_CODEC
#error "This test requires the real full transaction Request decoder"
#endif
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

using namespace laya;
namespace pending = laya::transaction_pending;
namespace {
unsigned rejects=0;
void require(bool value, const std::string& why) {
  if (!value) throw std::runtime_error(why);
}
template<unsigned N> std::array<uint8_t,N> load(const std::string& path) {
  std::array<uint8_t,N> p{}; std::ifstream f(path,std::ios::binary);
  require(f.good(), "fixture open: "+path);
  f.read(reinterpret_cast<char*>(p.data()), N);
  require(f.gcount()==static_cast<std::streamsize>(N) && f.peek()==std::ifstream::traits_type::eof(),
          "exact fixture size: "+path);
  return p;
}
void compare(const pending::Packet& p,const pending::Packet& gold,const std::string& where) {
  for (unsigned i=0;i<pending::kBytes;++i)
    require(p[i]==gold[i],where+" byte "+std::to_string(i));
}
void save(const std::string& path,const pending::Packet& p) {
  std::ofstream f(path,std::ios::binary); f.write(reinterpret_cast<const char*>(p.data()),p.size());
  require(f.good(), "capture write: "+path);
}
void cleared(const pending::Record& r) {
  require(!r.route && !r.key.session && !r.key.accepted_request && !r.key.source_sequence &&
          !r.key.handoff_epoch && !r.key.has_hold,"failed decode clears all metadata");
  for(auto byte:r.action_packet)require(!byte,"failed decode clears complete action");
  for(auto byte:r.transaction_packet)require(!byte,"failed decode clears complete transaction");
}
void reject(const pending::Packet& p,const admission_owner::Record& a,
            const pending::Record& expected,const std::string& why) {
  pending::Record out=expected; out.action_packet.fill(0xa5);out.transaction_packet.fill(0x5a);
  require(!pending::decode(p,a,expected,out),"must reject "+why);cleared(out);++rejects;
}
} // namespace

int main(int argc,char** argv) {
  try {
    require(argc==2,"usage: executable FIXTURE"); const std::string fixture=argv[1];
    admission_owner::Record owner;
    require(bool(admission_owner::decode(load<1024>(fixture+"/owner.bin"),owner)),"real full A decoder");
    const auto action_packet=load<512>(fixture+"/action.bin");
    const pending::Key key{29,101,1,19,true};
    const char* names[]={"end_cleanup","end_ordinary","invalidate_cleanup","invalidate_ordinary",
                         "release","claim","begin","publish","compute","producer"};
    pending::Record original; pending::Packet original_gold{};
    for(unsigned index=0;index<10;++index) {
      const std::string name=names[index];
      const auto tx=load<1536>(fixture+"/"+name+"_ltx.bin");
      const auto gold=load<2112>(fixture+"/"+name+"_ltp.bin");
      pending::Record record;
      require(bool(pending::capture(key,1,action_packet,tx,owner,record)),"complete capture "+name);
      const auto encoded=pending::encode(record);compare(encoded,gold,name+" independent literal gold");
      save(fixture+"/actual_"+name+".bin",encoded);
      pending::Record decoded;
      require(bool(pending::decode(gold,owner,key,1,decoded)),"full codec decode "+name);
      require(pending::same_record(record,decoded),"complete retained bytes "+name);
      require(bool(pending::decode(gold,owner,record,decoded)),"actual FSM snapshot byte binding "+name);
      require(pending::managed_cleanup_candidate(decoded)==(index==0 || index==2),
              "exact managed cleanup type predicate "+name);
      // No retirement/replay ledger lives in a codec. The next real slot may
      // legitimately carry an identical END/INVALIDATE retry packet.
      require(bool(pending::decode(gold,owner,record,decoded)),"identical next occupancy record allowed");
      if(index==0) { original=record;original_gold=gold; }
    }
    pending::Record no_hold;
    const pending::Key no_hold_key{29,101,0,0,false};
    require(bool(pending::capture(no_hold_key,0,action_packet,original.transaction_packet,owner,no_hold)),
            "real A with no invented HOLD sequence/handoff");
    compare(pending::encode(no_hold),load<2112>(fixture+"/no_hold_ltp.bin"),"no HOLD literal");
    save(fixture+"/actual_no_hold.bin",pending::encode(no_hold));
    pending::Record decoded;
    require(bool(pending::decode(pending::encode(no_hold),owner,no_hold,decoded)),"no HOLD decode");

    for(unsigned i: {0u,4u,6u,8u,9u,16u,24u,32u,40u,10u,15u,48u,63u,
                     64u,64u+13u,64u+511u,576u,576u+12u,576u+35u,2111u}) {
      auto bad=original_gold;bad[i]^=0x80;reject(bad,owner,original,"header/key/body/tail "+std::to_string(i));
    }
    for(unsigned i=10;i<16;++i) { auto p=original_gold;p[i]=1;reject(p,owner,original,"all first reserved bytes"); }
    for(unsigned i=48;i<64;++i) { auto p=original_gold;p[i]=1;reject(p,owner,original,"all second reserved bytes"); }
    auto bad_owner=owner;bad_owner.session++;reject(original_gold,bad_owner,original,"wrong A session");
    bad_owner=owner;bad_owner.accepted_request++;reject(original_gold,bad_owner,original,"wrong A request");
    bad_owner=owner;bad_owner.identity.request_id++;reject(original_gold,bad_owner,original,"wrong full A identity");
    bad_owner=owner;bad_owner.model_identity[415]^=1;reject(original_gold,bad_owner,original,"wrong full A model tail");
    for(unsigned part=0;part<5;++part) {
      auto expected=original;
      if(part==0)++expected.key.session;
      if(part==1)++expected.key.accepted_request;
      if(part==2)++expected.key.source_sequence;
      if(part==3)++expected.key.handoff_epoch;
      if(part==4)expected.key.has_hold=false;
      reject(original_gold,owner,expected,"wrong actual persistent K component");
    }
    auto expected=original;expected.route=0;reject(original_gold,owner,expected,"wrong actual route");
    auto changed=original_gold;portal::put(changed.data(),64+24,9001,8);
    require(bool(pending::decode(changed,owner,key,1,decoded)),"foreign complete valid action is syntactically valid");
    reject(changed,owner,original,"foreign complete valid action vs actual snapshot");
    changed=original_gold;portal::put(changed.data(),576+16,9002,8);
    require(bool(pending::decode(changed,owner,key,1,decoded)),"foreign complete valid LTX is syntactically valid");
    reject(changed,owner,original,"foreign complete valid full LTX vs actual snapshot");
    changed=original_gold;changed[576+160+415]^=1;
    reject(changed,owner,original,"complete 416B transaction model vs retained A");
    changed=original_gold;changed[576+160]^=1;
    reject(changed,owner,original,"transaction model tag vs retained A");
    changed=original_gold;changed[64+64+83]^=1;
    reject(changed,owner,original,"complete action NumericIdentity tail");
    changed=original_gold;changed[576+64+83]^=1;
    reject(changed,owner,original,"complete transaction NumericIdentity tail");
    changed=pending::encode(no_hold);portal::put(changed.data(),32,1,8);
    reject(changed,owner,no_hold,"invented source sequence without HOLD");
    changed=pending::encode(no_hold);portal::put(changed.data(),40,19,8);
    reject(changed,owner,no_hold,"invented handoff without HOLD");
    changed=original_gold;portal::put(changed.data(),32,0,8);
    reject(changed,owner,original,"HAS_HOLD with zero source sequence");
    changed=original_gold;portal::put(changed.data(),40,0,8);
    reject(changed,owner,original,"HAS_HOLD with zero handoff");
    transaction::Request t;
    require(bool(transaction::decode(original.transaction_packet,t)),"actual END codec");
    t.flags=3;require(!pending::managed_cleanup_candidate(t),"unknown pseudo cleanup flags");
    t.flags=0;require(!pending::managed_cleanup_candidate(t),"END ordinary flags no permit");
    auto forged=original;portal::put(forged.transaction_packet.data(),32,3,4);
    require(!pending::managed_cleanup_candidate(forged),"bad frame cannot qualify via cleanup flag");
    pending::Record out=original;
    require(!pending::capture(key,2,action_packet,original.transaction_packet,owner,out),"capture invalid route");cleared(out);
    std::cout<<"FULL_CURRENT_EXECUTOR_TRANSACTION_PENDING_HOST_PASS"
             <<" record_bytes=2112 beats=33 literal_records=11 ordinary_kinds=3"
             <<" complete_action_bytes=512 complete_transaction_bytes=1536 reject_checks="<<rejects
             <<" duplicate_same_packet_allowed=1 owner_tables_created=0"
             <<" cleanup_predicate_is_NOT_permission=1 collector_adapter_pop_NOT_RUN=1"
             <<" allocator_retirement_NOT_RUN=1\n";
    return 0;
  } catch(const std::exception& error) {
    std::cerr<<"TRANSACTION_PENDING_HOST_FAIL: "<<error.what()<<'\n';return 1;
  }
}
