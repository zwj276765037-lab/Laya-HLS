#include "laya_executor_hls.h"
#include "laya_executor_cold_init.h"
#include "laya_model_layout_generated.h"
#include <algorithm>
#include <array>
#include <cassert>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;
namespace {
using Packet = std::array<uint8_t, 1024>;
std::vector<uint8_t> bytes(const std::string& path) {
  std::ifstream f(path, std::ios::binary); assert(f);
  return {std::istreambuf_iterator<char>(f), std::istreambuf_iterator<char>()};
}
Packet literal(const std::string& path) {
  const auto b = bytes(path); assert(b.size() == 1024);
  Packet p{}; std::copy(b.begin(), b.end(), p.begin()); return p;
}
// Independent little-endian construction: expected records never use a DUT
// encoder or fields copied from the DUT's admission/control output.
void put(Packet& p, unsigned at, uint64_t value, unsigned count) {
  for (unsigned i = 0; i < count; ++i) p[at + i] = uint8_t(value >> (8 * i));
}
template<std::size_t N> ap_uint<512> word(const std::array<uint8_t, N>& p, unsigned beat) {
  ap_uint<512> w = 0;
  for (unsigned b = 0; b < 64; ++b) w.range(8*b+7, 8*b) = p[beat*64+b];
  return w;
}
ap_uint<8192> whole(const Packet& p) {
  ap_uint<8192> w=0;
  for(unsigned b=0;b<1024;++b)w.range(8*b+7,8*b)=p[b];
  return w;
}
Packet whole_packet(const ap_uint<8192>& w) {
  Packet p{};
  for(unsigned b=0;b<1024;++b)p[b]=uint8_t(w.range(8*b+7,8*b));
  return p;
}
template<std::size_t N> void read_word(std::array<uint8_t, N>& p,
                                      hls::stream<ap_uint<512>>& s, unsigned beat) {
  assert(!s.empty()); const auto w = s.read();
  for (unsigned b = 0; b < 64; ++b) p[beat*64+b] = uint8_t(w.range(8*b+7, 8*b));
}
struct Aligned {
  uint8_t* data = nullptr;
  explicit Aligned(std::size_t n) { assert(posix_memalign(reinterpret_cast<void**>(&data), 64, n) == 0); std::memset(data, 0, n); }
  ~Aligned() { std::free(data); }
  Aligned(const Aligned&) = delete;
  Aligned& operator=(const Aligned&) = delete;
};
struct Harness {
  Aligned io{32768}, aux{full::kFullModelBoSizes[4]};
  admission_owner::PhysicalMap map;
  ap_uint<2496> config = 0;
  bool first_valid=false, physical_safe=true, cancel=false, checkpoint_valid=true;
  uint64_t session=29, handoff_epoch=19;
  bool first_ready=false, admission_valid=false, admission_rejected=false;
  bool result_consumed=false;
  hls::stream<ap_uint<8192>> response_receipts, response_rejections;
  hls::stream<ap_uint<8192>> program_owners, program_owner_echo, pending;
  hls::stream<ap_uint<512>> owner, owner_receipt, control, control_receipt, response;
  hls::stream<ap_uint<512>> host_receipt, query, proof, commands, program_results;
  hls::stream<ap_uint<512>> results, actions, completions, transactions, transaction_results, action_receipt;
  unsigned calls=0, handshakes=0, init_calls=0;
  explicit Harness(const std::string& fixture) {
    const auto request=bytes(fixture+"/v2/v1/request.bin");
    const auto header=bytes(fixture+"/v2/v1/aux_header.bin");
    assert(request.size()==832 && header.size()==128);
    std::copy(request.begin(),request.end(),io.data);
    std::copy(header.begin(),header.end(),aux.data);
    const uint64_t capacities[13]={full::kFullModelBoSizes[0],32768,
      full::kFullModelBoSizes[1],full::kFullModelBoSizes[2],full::kFullModelBoSizes[3],
      full::kFullModelBoSizes[4],16920576,16919104,12ull*1024*1024,12ull*1024*1024,
      41ull*1024*1024,21ull*1024*1024-512ull*1024,8ull*1024*1024};
    map.known_roles=8191;
    for(unsigned r=0;r<13;++r) {
      // Eleven adapter-owned BO addresses are controlled metadata in this
      // host-only test. Only IO and AUX are dereferenced by this partition.
      const uint64_t address=r==1?uint64_t(reinterpret_cast<uintptr_t>(io.data)):
        r==5?uint64_t(reinterpret_cast<uintptr_t>(aux.data)):
        r==6?0x1200000000ull:0x2000000000ull+uint64_t(r)*0x100000000ull;
      map.role[r]={r==6?7ull:100ull+r,address,capacities[r]};
    }
    configure();
  }
  void configure() {
    config=0;
    for(unsigned r=0;r<13;++r) {
      const unsigned bit=r*192;
      config.range(bit+63,bit)=map.role[r].epoch;
      config.range(bit+127,bit+64)=map.role[r].address;
      config.range(bit+191,bit+128)=map.role[r].capacity;
    }
  }
  void call() {
    assert(++calls<full::kColdInitMaxSteps+2000);
    laya_task_lifecycle_executor(io.data,aux.data,first_valid,session,config,
      physical_safe,cancel,checkpoint_valid,1,handoff_epoch,true,true,true,
      first_ready,admission_valid,admission_rejected,
      result_consumed,response_receipts,response_rejections,
      owner,owner_receipt,control,control_receipt,response,host_receipt,
      query,proof,commands,program_results,results,actions,completions,transactions,
      transaction_results,action_receipt,program_owners,program_owner_echo,pending);
    if(first_valid && first_ready)++handshakes;
  }
  void no_dispatch() {
    assert(commands.empty() && actions.empty() && completions.empty() && transactions.empty() && results.empty());
  }
  void no_authority() { assert(!admission_valid && control.empty() && query.empty()); no_dispatch(); }
  void wait(unsigned n=12) { for(unsigned i=0;i<n;++i)call(); }
  void start() {
    // Every input is queued during INIT. Its actual FIFO size must remain
    // unchanged; the caller removes these never-accepted sentinel inputs
    // before starting the original fixture. No top reset is used.
    const ap_uint<512> sentinel = 0x7135;
    owner_receipt.write(sentinel); control_receipt.write(sentinel);
    response.write(sentinel); host_receipt.write(sentinel);
    proof.write(sentinel); program_results.write(sentinel);
    actions.write(sentinel); transaction_results.write(sentinel);
    action_receipt.write(sentinel);
    program_owner_echo.write(ap_uint<8192>(0x93));
    pending.write(ap_uint<8192>(0x94));
    const auto initial_config = config;
    first_valid = true;
    for (unsigned i = 0; i < full::kColdInitMaxSteps; ++i) {
      session = 1000 + i; config = initial_config;
      config.range(63,0) = 9000 + i;
      physical_safe = (i % 3 != 0); cancel = (i % 2 != 0);
      call(); ++init_calls;
      assert(!first_ready && !admission_valid && !admission_rejected &&
             !result_consumed && handshakes == 0);
      no_authority();
      assert(owner.empty() && response_receipts.empty() &&
             response_rejections.empty() && program_owners.empty());
      assert(owner_receipt.size()==1 && control_receipt.size()==1 &&
             response.size()==1 && host_receipt.size()==1 && proof.size()==1 &&
             program_results.size()==1 && actions.size()==1 &&
             transaction_results.size()==1 && action_receipt.size()==1 &&
             program_owner_echo.size()==1 && pending.size()==1);
    }
    assert(owner_receipt.read()==sentinel && control_receipt.read()==sentinel &&
           response.read()==sentinel && host_receipt.read()==sentinel &&
           proof.read()==sentinel && program_results.read()==sentinel &&
           actions.read()==sentinel && transaction_results.read()==sentinel &&
           action_receipt.read()==sentinel);
    assert(program_owner_echo.read()==ap_uint<8192>(0x93) &&
           pending.read()==ap_uint<8192>(0x94));
    session = 29; config = initial_config; cancel = false;
    physical_safe=false;first_valid=true;call();assert(!first_ready);no_authority();
    physical_safe=true;cancel=true;call();assert(!first_ready);no_authority();
    cancel=false;first_valid=false;call();assert(first_ready);no_authority();
    first_valid=true;call();assert(first_ready && handshakes==1);
    first_valid=false;call();assert(!first_ready);no_authority();
    for(unsigned i=0;i<48 && owner.size()<16 && !admission_rejected;++i)call();
  }
  template<std::size_t N> std::array<uint8_t,N> consume(hls::stream<ap_uint<512>>& s,
                                                        bool admission=false) {
    constexpr unsigned beats=N/64;
    for(unsigned i=0;i<48 && s.size()<beats;++i)call();
    assert(s.size()==beats);std::array<uint8_t,N> p{};
    for(unsigned b=0;b<beats;++b) {
      if(b>=beats-2)for(unsigned i=0;i<12;++i) {
        call();assert(s.size()==beats-b);no_dispatch();
        if(admission)no_authority();
      }
      read_word(p,s,b);
    }
    assert(s.empty());return p;
  }
  template<std::size_t N> void send_tail(hls::stream<ap_uint<512>>& s,
    const std::array<uint8_t,N>& p, bool admission=false, bool expect_no_query=false) {
    constexpr unsigned beats=N/64;
    for(unsigned b=0;b<beats;++b) {
      if(b>=beats-2)for(unsigned i=0;i<12;++i) {
        call();assert(s.empty());no_dispatch();
        if(admission)no_authority();
        if(expect_no_query)assert(query.empty());
      }
      s.write(word(p,b));call();assert(s.empty());
    }
  }
  void response_receipt(const Packet& expected) {
    for(unsigned i=0;i<48 && response_receipts.empty();++i) { call();no_dispatch(); }
    assert(response_receipts.size()==1 && response_rejections.empty());
    for(unsigned i=0;i<12;++i) { call();no_dispatch();assert(response_receipts.size()==1 && response_rejections.empty()); }
    const auto receipt=response_receipts.read();Packet p{};
    for(unsigned i=0;i<1024;++i)p[i]=uint8_t(receipt.range(8*i+7,8*i));
    handoff::Message decoded;assert(p==expected && handoff::decode(p,decoded));
    call();assert(response_receipts.empty() && response_rejections.empty());
  }
};
Packet expected_owner(const std::string& fixture,const Harness& h) {
  const auto source=literal(fixture+"/v2/checkpoint_request.bin");
  Packet p{};put(p,0,0x3144414c,4);put(p,4,1,2);put(p,6,16,2);
  put(p,8,3,4);put(p,12,8191,4);put(p,16,29,8);put(p,24,1,8);
  std::copy(source.begin()+64,source.begin()+148,p.begin()+64);
  std::copy(source.begin()+160,source.begin()+576,p.begin()+160);
  for(unsigned r=0;r<13;++r) {
    const unsigned at=576+24*r;const auto& m=h.map.role[r];
    put(p,at,m.epoch,8);put(p,at+8,m.address,8);put(p,at+16,m.capacity,8);
  }
  return p;
}
Packet control_literal(const std::string& fixture,unsigned kind) {
  auto p=literal(fixture+"/control_"+std::to_string(kind)+".bin");
  put(p,784,1,8);return p;
}
void rejected(Harness& h) {
  for(unsigned i=0;i<48 && !h.admission_rejected;++i)h.call();
  assert(h.admission_rejected && !h.admission_valid && !h.first_ready);
  h.no_authority();
  h.first_valid=true;
  for(unsigned i=0;i<32;++i) { h.call();assert(h.admission_rejected && !h.first_ready);h.no_authority(); }
  assert(h.handshakes==1 && h.owner.empty());
}
void success(Harness& h,const std::string& fixture,bool bad_program_echo=false) {
  h.start();assert(h.owner.size()==16 && !h.admission_rejected);
  const auto a=h.consume<1024>(h.owner,true);assert(a==expected_owner(fixture,h));
  admission_owner::Record admitted;assert(admission_owner::decode(a,admitted));
  assert(admitted.physical.known_roles==8191 && admitted.accepted_request==1);
  for(unsigned r=0;r<13;++r) {
    const auto& x=admitted.physical.role[r];const auto& y=h.map.role[r];
    assert(x.epoch==y.epoch && x.address==y.address && x.capacity==y.capacity);
  }
  h.wait();h.no_authority(); // FIFO empty alone grants no permission.
  h.send_tail(h.owner_receipt,a,true);assert(!h.admission_valid);h.no_authority();
  for(unsigned i=0;i<48 && h.control.size()<16;++i)h.call();
  assert(h.admission_valid && !h.admission_rejected && h.handshakes==1);
  const auto hold=h.consume<1024>(h.control);assert(hold==control_literal(fixture,1));
  handoff::Message held;assert(handoff::decode(hold,held) && held.kind==handoff::Kind::HOLD);
  const auto held_packet=control_literal(fixture,2);
  // A valid early response is retained until the real HOLD consumer's
  // complete original-packet receipt, never authorized by FIFO emptiness.
  h.send_tail(h.response,held_packet,false,true);h.wait();assert(h.query.empty() && h.response_receipts.empty() && h.response_rejections.empty());
  h.send_tail(h.control_receipt,hold,false,true);
  h.response_receipt(held_packet);
  const auto query=h.consume<1024>(h.query);assert(query==literal(fixture+"/v2/checkpoint_request.bin"));
  checkpoint::Request request;assert(checkpoint::decode(query,request));
  const auto proof=literal(fixture+"/v2/checkpoint_response.bin");
  checkpoint::Response decoded;assert(checkpoint::decode(proof,request,decoded));
  h.send_tail(h.proof,proof);h.no_dispatch();
  const auto imported=h.consume<1024>(h.control);assert(imported==control_literal(fixture,3));
  handoff::Message import;assert(handoff::decode(imported,import) && import.local_committed && import.kind==handoff::Kind::IMPORT_OK);
  h.wait();h.no_dispatch();
  const auto granted=control_literal(fixture,4);
  h.send_tail(h.response,granted);h.wait();h.no_dispatch();assert(h.response_receipts.empty() && h.response_rejections.empty());
  h.send_tail(h.control_receipt,imported);h.response_receipt(granted);
  // The owner comes from the accepted original GRANTED after the actual
  // shell receipt handshake. The program must consume/decode this complete
  // record and echo it before any LGP1 may be written.
  for(unsigned i=0;i<48 && h.program_owners.empty();++i) { h.call();h.no_dispatch(); }
  assert(h.program_owners.size()==1);
  for(unsigned i=0;i<12;++i) { h.call();h.no_dispatch();assert(h.program_owners.size()==1); }
  const auto actual_owner=whole_packet(h.program_owners.read());
  handoff::Message program_owner;
  assert(actual_owner==granted && handoff::decode(actual_owner,program_owner) &&
    program_owner.kind==handoff::Kind::GRANTED && program_owner.local_committed &&
    program_owner.session==29 && program_owner.accepted_request==1);
  for(unsigned i=0;i<12;++i) { h.call();h.no_dispatch();assert(h.program_owners.empty()); }
  if(bad_program_echo) {
    auto foreign=actual_owner;put(foreign,784,2,8);
    handoff::Message decoded_foreign;
    assert(handoff::decode(foreign,decoded_foreign) && decoded_foreign.accepted_request==2);
    h.program_owner_echo.write(whole(foreign));
    for(unsigned i=0;i<12;++i) { h.call();h.no_dispatch();assert(!h.first_ready && h.program_owners.empty()); }
    assert(h.program_owner_echo.empty());
    const auto aborted=h.consume<1024>(h.control);
    auto expected_abort=control_literal(fixture,5);expected_abort[792]=1;
    handoff::Message abort;
    assert(aborted==expected_abort && handoff::decode(aborted,abort) &&
      abort.kind==handoff::Kind::ABORT && abort.local_committed &&
      !abort.result && handoff::same_key(abort,program_owner));
    // A valid old echo cannot replace the foreign record or reopen this
    // isolated process. The retained static top and old wire state survive.
    h.program_owner_echo.write(whole(actual_owner));
    h.first_valid=true;
    for(unsigned i=0;i<32;++i) { h.call();h.no_dispatch();assert(!h.first_ready && h.program_owners.empty() && h.owner.empty() && h.program_owner_echo.size()==1); }
    assert(h.handshakes==1);return;
  }
  h.program_owner_echo.write(whole(actual_owner));h.call();
  for(unsigned i=0;i<48 && h.commands.size()<4;++i)h.call();
  assert(h.commands.size()==4);
  program_wire::CommandPacket command{};
  for(unsigned b=0;b<4;++b)read_word(command,h.commands,b);
  program_wire::Command accepted;assert(program_wire::decode(command,accepted));
  assert(accepted.identity.request_id==1101 && accepted.identity.generation==51 &&
    accepted.identity.B==1 && accepted.identity.S==64 && accepted.flags==program_wire::SOURCE_READY_PROOF &&
    accepted.source.version==1 && accepted.source.owner.ref.epoch==1);
  // Static top is never reset in this process. A second candidate cannot
  // produce another A, HOLD, query or command even if FIRST remains asserted.
  for(unsigned b=0;b<8;++b) {
    h.io.data[24+b]=uint8_t(2202ull>>(8*b));
    h.io.data[32+b]=uint8_t(52ull>>(8*b));
  }
  h.first_valid=true;
  for(unsigned i=0;i<32;++i) { h.call();assert(!h.first_ready && h.admission_valid && !h.admission_rejected);h.no_dispatch();assert(h.owner.empty() && h.control.empty() && h.query.empty()); }
  assert(h.handshakes==1);
}
} // namespace
int main(int argc,char** argv) {
  assert(argc==3);const std::string fixture=argv[1],mode=argv[2];Harness h(fixture);
  if(mode=="success")success(h,fixture);
  else if(mode=="bad-program-owner-echo")success(h,fixture,true);
  else if(mode=="bad-owner-echo") {
    h.start();const auto a=h.consume<1024>(h.owner,true);assert(a==expected_owner(fixture,h));
    admission_owner::Record r;assert(admission_owner::decode(a,r));
    auto foreign=a;put(foreign,24,2,8);assert(admission_owner::decode(foreign,r));
    h.send_tail(h.owner_receipt,foreign,true);rejected(h);
    for(unsigned b=0;b<16;++b)h.owner_receipt.write(word(a,b));
    h.wait();assert(h.owner_receipt.size()==16);h.no_authority();
  } else if(mode=="io-address-mismatch" || mode=="aux-address-mismatch") {
    h.map.role[mode=="io-address-mismatch"?1:5].address+=64;h.configure();h.start();rejected(h);
  } else if(mode=="bad-request" || mode=="bad-model") {
    if(mode=="bad-request")h.io.data[0]^=1;else h.aux.data[32]^=1;
    h.start();rejected(h);
  } else assert(false && "unknown independent-process case");
  std::cout<<"FULL_CURRENT_EXECUTOR_HLS_TOP_PASS case="<<mode
    <<" FIRST_handshakes="<<h.handshakes<<" bounded_calls="<<h.calls
    <<" INIT_actual_calls="<<h.init_calls<<" INIT_input_FIFO_pops=0"
    <<" all13_configuration=1 actual_aligned_IO_AUX=1 independent_process=1"
    <<" close_rearm_NOT_RUN=1 whole_production_chain_NOT_RUN=1\n";
}
