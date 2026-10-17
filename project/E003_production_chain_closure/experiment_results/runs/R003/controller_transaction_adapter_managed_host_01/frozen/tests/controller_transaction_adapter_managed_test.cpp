#include "laya_controller_transaction_adapter.h"

#include <array>
#include <cassert>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#if !defined(LAYA_MANAGED_TRANSACTION_ADAPTER) || !LAYA_MANAGED_TRANSACTION_ADAPTER
#error "managed test requires LAYA_MANAGED_TRANSACTION_ADAPTER=1"
#endif

using namespace laya;
namespace {
using Request = transaction::Request;
using Ltx = transaction::RequestPacket;
using Ltc = transaction::CompletionPacket;
using RawCommand = std::array<uint8_t, 1024>;
using RawResponse = std::array<uint8_t, 512>;
std::string fixture, capture;
unsigned cases = 0, rejects = 0, remotes = 0;

struct Streams {
  hls::stream<ap_uint<512>> in{"transaction_request"}, out{"transaction_completion"};
  hls::stream<ap_uint<512>> cc{"compute_command"}, cr{"compute_response"};
  hls::stream<ap_uint<512>> pc{"provenance_command"}, pr{"provenance_response"};
  hls::stream<ap_uint<512>> lc{"producer_request"}, lr{"producer_completion"};
};
void step(Streams& s, bool cancel = false) {
  laya_command_provenance_adapter(cancel, s.in, s.out, s.cc, s.cr,
                                  s.pc, s.pr, s.lc, s.lr);
}
template<std::size_t N>
ap_uint<512> word(const std::array<uint8_t, N>& bytes, unsigned beat) {
  ap_uint<512> value = 0;
  for (unsigned b = 0; b < 64; ++b)
    value.range(8*b+7, 8*b) = bytes[64*beat+b];
  return value;
}
template<std::size_t N>
std::array<uint8_t, N> read_literal(const std::string& name) {
  std::ifstream f(fixture + "/" + name + ".hex");
  assert(f);
  std::array<uint8_t, N> out{};
  std::string line;
  for (unsigned i = 0; i < N/64; ++i) {
    assert(bool(std::getline(f, line)) && line.size() == 128);
    for (unsigned j = 0; j < 64; ++j)
      out[64*i+j] = uint8_t(std::stoul(line.substr(126-2*j, 2), nullptr, 16));
  }
  assert(!std::getline(f, line));
  return out;
}
template<std::size_t N>
void save(const std::string& name, const std::array<uint8_t, N>& bytes) {
  static constexpr char hex[] = "0123456789abcdef";
  std::ofstream f(capture + "/case_" + std::to_string(cases) + "_" + name + ".hex");
  assert(f);
  for (unsigned i = 0; i < N/64; ++i) {
    for (int j = 63; j >= 0; --j) {
      uint8_t byte = bytes[64*i+unsigned(j)];
      f << hex[byte >> 4] << hex[byte & 15];
    }
    f << '\n';
  }
  assert(f.good());
}
template<std::size_t N>
void copy(std::array<uint8_t, N>& to, unsigned dst, const Ltx& from,
          unsigned src, unsigned count) {
  for (unsigned i = 0; i < count; ++i) to[dst+i] = from[src+i];
}
Ltc local_gold(const Ltx& request) {
  // Independent fixed LTC1 wire offsets. Never call make_local_reject or the
  // adapter normalizer for the expected complete response.
  Ltc out{};
  portal::put(out.data(), 0, 0x3143544cu, 4);
  portal::put(out.data(), 4, 1, 2); portal::put(out.data(), 6, 16, 2);
  copy(out, 8, request, 8, 4);
  portal::put(out.data(), 12, 0x41, 4); // FRAME_COMPLETE | LOCAL_REJECT only
  copy(out, 16, request, 16, 16);
  portal::put(out.data(), 32, 7, 2); // E_PROTOCOL
  portal::put(out.data(), 36, 0x0700000eu, 4);
  portal::put(out.data(), 40, UINT64_MAX, 8);
  copy(out, 72, request, 64, 96);
  const auto kind = transaction::Kind(portal::get(request.data(), 8, 2));
  if (kind == transaction::Kind::PROVENANCE_TRANSACTION) {
    out[35] = request[579];
    for (unsigned i = 0; i < 2; ++i) {
      const unsigned src = 624 + 128*i;
      copy(out, 168+16*i, request, src, 6);
      copy(out, 176+16*i, request, src+8, 6);
      out[200+2*i] = request[src+16]; out[201+2*i] = request[src+17];
    }
  } else if (kind == transaction::Kind::COMPUTE_TRANSACTION) {
    copy(out, 168, request, 576, 36);
    for (unsigned i = 0; i < 6; ++i) copy(out, 204+8*i, request, 612+8*i, 6);
    out[252]=request[660];out[253]=request[661];out[254]=request[662];
    out[255]=request[682];out[256]=request[683];
    copy(out, 260, request, 668, 8); copy(out, 268, request, 148, 4);
    portal::put(out.data(), 272, UINT64_MAX, 8); // default first_error_rank
  } else {
    copy(out, 168, request, 576, 6); copy(out, 176, request, 584, 6);
    out[184]=request[592];out[185]=request[593];out[186]=request[594];
    out[187]=request[595];out[188]=request[596];
    copy(out, 192, request, 600, 2); copy(out, 196, request, 608, 8);
    copy(out, 204, request, 616, 32);
  }
  return out;
}
Request from_literal(const std::string& name) {
  Request q;
  const Ltx p = read_literal<1536>(name + "_request");
  assert(transaction::decode(p, q));
  assert(transaction::encode(q) == p);
  return q;
}
Request ordinary_lpv(provenance::Action action) {
  Request q = from_literal("begin");
  auto& p = q.provenance;
  p.action=action;p.event_seq=200+uint16_t(action);p.origin_seq=0;
  p.context=portal::zero_context();p.reported_status=Status::OK;p.reported_unit=OutputUnit::NONE;
  p.reported_elements=0;p.reported_error_detail=0;p.reported_bad_element=0;
  p.expected_unit=OutputUnit::NONE;p.expected_elements=0;
  p.issued_store_bytes[0]=0;p.issued_store_bytes[1]=0;
  p.geometry[0]={};p.geometry[1]={};q.flags=0;
  return q;
}
hls::stream<ap_uint<512>>& command(Streams& s, transaction::Kind k) {
  if (k==transaction::Kind::COMPUTE_TRANSACTION) return s.cc;
  if (k==transaction::Kind::PROVENANCE_TRANSACTION) return s.pc;
  return s.lc;
}
hls::stream<ap_uint<512>>& response(Streams& s, transaction::Kind k) {
  if (k==transaction::Kind::COMPUTE_TRANSACTION) return s.cr;
  if (k==transaction::Kind::PROVENANCE_TRANSACTION) return s.pr;
  return s.lr;
}
void no_external(Streams& s) {
  assert(s.cc.empty() && s.pc.empty() && s.lc.empty());
}
RawCommand external_gold(const Request& q) {
  if (q.kind==transaction::Kind::COMPUTE_TRANSACTION) return portal::encode(q.compute);
  if (q.kind==transaction::Kind::PROVENANCE_TRANSACTION) return provenance::encode(q.provenance);
  return producer::encode(q.producer);
}
RawResponse controlled_response(const Request& q) {
  if (q.kind==transaction::Kind::COMPUTE_TRANSACTION) return read_literal<512>("compute_response");
  if (q.kind==transaction::Kind::PRODUCER_TRANSACTION) return read_literal<512>("producer_response");
  const auto& p=q.provenance;
  if (p.action==provenance::Action::END) return read_literal<512>("end_response");
  provenance::Response r;
  r.action=p.action;r.event_seq=p.event_seq;r.origin_seq=p.origin_seq;
  r.identity=p.identity;r.context=p.context;r.descriptor_count=p.descriptor_count;
  r.status=p.action==provenance::Action::BEGIN ? Status::OK : Status::E_BUFFER;
  r.error_detail=r.status==Status::OK ? 0 : 0x04000008u;
  r.drained=true;r.scope_active=p.action==provenance::Action::BEGIN;
  for (unsigned i=0;i<2;++i) {
    r.target_ref[i]=p.descriptor[i].target_ref;r.old_ref[i]=p.descriptor[i].old_ref;
    r.target_region[i]=p.descriptor[i].target_region;r.old_region[i]=p.descriptor[i].old_region;
  }
  return provenance::encode(r);
}
Ltc remote_gold(const Request& q, const RawResponse& r) {
  if (q.kind==transaction::Kind::COMPUTE_TRANSACTION) return read_literal<1024>("compute_completion");
  if (q.kind==transaction::Kind::PRODUCER_TRANSACTION) return read_literal<1024>("producer_completion");
  Ltc out{};
  portal::put(out.data(),0,0x3143544cu,4);portal::put(out.data(),4,1,2);
  portal::put(out.data(),6,16,2);portal::put(out.data(),8,2,2);
  for(unsigned i=0;i<2;++i)out[10+i]=r[6+i];
  uint32_t flags=1|2|(r[26]&1 ? 4 : 0)|(r[26]&2 ? 8 : 0)|
      ((r[26]&1) && !(r[26]&2) ? 16 : 0)|(r[26]&4 ? 32 : 0);
  portal::put(out.data(),12,flags,4);
  auto field=[&](unsigned dst,unsigned src,unsigned n) {
    for(unsigned i=0;i<n;++i)out[dst+i]=r[src+i];
  };
  field(16,8,16);field(32,24,2);out[34]=r[44];out[35]=r[45];
  field(36,28,12);field(48,40,4);field(56,48,16);field(72,64,96);
  for(unsigned i=0;i<4;++i) {
    field(168+8*i,160+8*i,6);out[200+i]=r[166+8*i];
  }
  return out;
}
Request wrong_expected(Request q,unsigned mutant) {
  if(mutant==5) {
    q.kind=q.kind==transaction::Kind::COMPUTE_TRANSACTION ?
        transaction::Kind::PROVENANCE_TRANSACTION : transaction::Kind::COMPUTE_TRANSACTION;
    return q;
  }
  if(q.kind==transaction::Kind::COMPUTE_TRANSACTION) {
    auto& r=q.compute;
    if(mutant==0)++r.generation;else if(mutant==1)++r.identity.request_id;
    else if(mutant==2)++r.context.task_id;else if(mutant==3)++r.source.epoch;
    else if(mutant==4)r.source_region^=1;else r.quant_context.rows^=1;
  } else if(q.kind==transaction::Kind::PROVENANCE_TRANSACTION) {
    auto& r=q.provenance;
    if(mutant==0)++r.event_seq;else if(mutant==1)++r.identity.request_id;
    else if(mutant==2)++r.context.task_id;else if(mutant==3)++r.descriptor[0].target_ref.epoch;
    else if(mutant==4)r.descriptor[0].target_region^=1;else ++r.descriptor[0].old_ref.epoch;
  } else {
    auto& r=q.producer;
    if(mutant==0)++r.request_seq;else if(mutant==1)++r.identity.request_id;
    else if(mutant==2)++r.context.task_id;else if(mutant==3)++r.source.epoch;
    else if(mutant==4)r.source_region^=1;else r.eps_bits^=1;
  }
  return q;
}
enum Timing : unsigned { FIRST_POP, EMPTY_AFTER_FIRST, HALF_READ, LAST_POP, PREPARE,
                         BEFORE_FIRST_WRITE, AFTER_FIRST_WRITE, NEVER };
void perform(Request q, Timing timing, bool remote) {
  const Ltx ltx=transaction::encode(q);
  Request checked;
  assert(transaction::decode(ltx,checked)); // only complete legal pending frames
  assert(transaction::encode(checked)==ltx);
  const RawCommand expected_external=external_gold(q);
  const RawResponse peer=controlled_response(q);
  const Ltc expected=remote ? remote_gold(q,peer) : local_gold(ltx);
  save("ltx",ltx);save("expected_ltc",expected);
  Streams s;
  for(unsigned i=0;i<24;++i) {
    s.in.write(word(ltx,i));
    step(s,(timing==FIRST_POP && i==0) || (timing==HALF_READ && i==12) ||
           (timing==LAST_POP && i==23));
    assert(s.in.empty());no_external(s);assert(s.out.empty());
    if(i==0 && timing==EMPTY_AFTER_FIRST) {
      step(s,true);step(s,false); // revoke while read_nb finds no next word
      assert(s.in.empty());no_external(s);assert(s.out.empty());
    }
  }
  step(s,timing==PREPARE);
  no_external(s);assert(s.out.empty());
  if(timing==BEFORE_FIRST_WRITE) {
    step(s,true);
    if(remote)assert(command(s,q.kind).size()==1);else no_external(s);
    assert(s.out.empty());
  } else if(timing==AFTER_FIRST_WRITE) {
    step(s,false);assert(command(s,q.kind).size()==1);assert(s.out.empty());
    step(s,true);assert(command(s,q.kind).size()==2);assert(s.out.empty());
  }
  if(remote) {
    for(unsigned i=0;i<200 && command(s,q.kind).size()<16;++i)step(s,false);
    assert(command(s,q.kind).size()==16 && s.out.empty());
    RawCommand actual{};
    for(unsigned i=0;i<16;++i) {
      ap_uint<512> w=command(s,q.kind).read();
      for(unsigned j=0;j<64;++j)actual[i*64+j]=uint8_t(w.range(j*8+7,j*8));
    }
    assert(actual==expected_external);save("actual_external",actual);no_external(s);
    response(s,q.kind).write(word(peer,0));
    for(unsigned i=0;i<4;++i)step(s,true);
    assert(s.out.empty()); // old partial response cannot become local reject
    for(unsigned i=1;i<8;++i)response(s,q.kind).write(word(peer,i));
    save("controlled_response",peer);
    for(unsigned i=0;i<200 && s.out.size()<16;++i)step(s,true);
    ++remotes;
  } else {
    for(unsigned i=0;i<200 && s.out.size()<16;++i) {
      step(s,false);no_external(s);
    }
    ++rejects;
  }
  assert(s.out.size()==16 && s.in.empty());no_external(s);
  Ltc actual{};
  for(unsigned i=0;i<16;++i) {
    if(i==14 || i==15) {
      for(unsigned wait=0;wait<12;++wait) {
        step(s,true);assert(s.out.size()==16-i);no_external(s);
      }
    }
    ap_uint<512> w=s.out.read();
    for(unsigned j=0;j<64;++j)actual[i*64+j]=uint8_t(w.range(j*8+7,j*8));
  }
  assert(actual==expected);save("actual_ltc",actual);
  transaction::Completion completion;
  const Check decoded=transaction::decode(actual,q,completion);
  assert(transaction::completion_frame_complete(completion));
  if(!remote) {
    assert(decoded.code==Status::E_PROTOCOL && decoded.detail==0x0700000eu &&
           decoded.bad_element==UINT64_MAX && completion.flags==0x41);
    assert(!transaction::completion_binding_ok(completion) &&
           !transaction::completion_safe_terminal(completion));
    for(unsigned mutant=0;mutant<7;++mutant) {
      transaction::Completion bad;
      const Check result=transaction::decode(actual,wrong_expected(q,mutant),bad);
      assert(result.code==Status::E_PROTOCOL && !transaction::completion_frame_complete(bad) &&
             !transaction::completion_binding_ok(bad) && !transaction::completion_safe_terminal(bad));
    }
  } else {
    assert(transaction::completion_binding_ok(completion) && !(completion.flags & transaction::LOCAL_REJECT));
    assert(decoded.code==(q.kind==transaction::Kind::PROVENANCE_TRANSACTION ?
           Status(portal::get(peer.data(),24,2)) : Status::OK));
  }
  for(unsigned i=0;i<4;++i)step(s,true);
  assert(s.in.empty() && s.out.empty() && s.cc.empty() && s.cr.empty() &&
         s.pc.empty() && s.pr.empty() && s.lc.empty() && s.lr.empty());
  std::cout << "MANAGED_ADAPTER_CASE_PASS case=" << cases++ << " kind=" << unsigned(q.kind)
            << " protocol=" << unsigned(portal::get(ltx.data(),10,2)) << " timing=" << unsigned(timing)
            << " flags=" << q.flags << " local_reject=" << !remote
            << " full_binding=1 actual_LTX24=1 actual_LTC16=1 no_double_response=1\n";
}
} // namespace

int main(int argc,char** argv) {
  assert(argc==3);fixture=argv[1];capture=argv[2];
  std::vector<Request> q={from_literal("compute"),from_literal("producer"),
      ordinary_lpv(provenance::Action::CLAIM),from_literal("begin"),
      ordinary_lpv(provenance::Action::PUBLISH),ordinary_lpv(provenance::Action::RELEASE),
      from_literal("end"),ordinary_lpv(provenance::Action::INVALIDATE)};
  for(auto& request:q)request.flags=0;
  for(const auto& request:q)
    for(unsigned timing=FIRST_POP;timing<=BEFORE_FIRST_WRITE;++timing)
      perform(request,Timing(timing),false);
  for(unsigned i=0;i<6;++i) {
    auto forged=q[i];forged.flags=transaction::CANCEL_CLEANUP;
    perform(forged,HALF_READ,false);perform(forged,BEFORE_FIRST_WRITE,false);
  }
  for(unsigned i=6;i<8;++i) {
    auto cleanup=q[i];cleanup.flags=transaction::CANCEL_CLEANUP;
    for(unsigned timing=FIRST_POP;timing<=BEFORE_FIRST_WRITE;++timing)
      perform(cleanup,Timing(timing),true);
  }
  for(const auto& request:q)perform(request,AFTER_FIRST_WRITE,true);
  for(const auto& request:q)perform(request,NEVER,true);
  assert(cases==88 && rejects==60 && remotes==28);
  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_PASS cases=" << cases
            << " local_rejects=" << rejects << " remote_returns=" << remotes
            << " precise_END_INVALIDATE=1 legacy_RELEASE_managed_denied=1 complete_binding=1"
            << " host_unbounded=1 external_attempt_without_accept_NOT_RUN=1"
            << " depth2_backpressure_NOT_RUN=1 wrapper_A_pending_NOT_RUN=1 HLS_RTL_NOT_RUN=1\n";
  return 0;
}
