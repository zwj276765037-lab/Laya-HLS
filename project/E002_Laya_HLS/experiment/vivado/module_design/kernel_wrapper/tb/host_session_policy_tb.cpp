#include "host_session_policy.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <limits>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace {
namespace fs = std::filesystem;
using namespace laya;
using namespace laya::host;

unsigned checks = 0;
void require(bool value, const std::string& message) {
  ++checks;
  if (!value) throw std::runtime_error(message);
}

uint32_t rotate(uint32_t x, unsigned n) { return (x >> n) | (x << (32 - n)); }
std::string sha256(const std::vector<uint8_t>& input) {
  // Independent fixture identity check; it does not use the Laya ABI codec.
  static constexpr uint32_t k[64] = {
      0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
      0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
      0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
      0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
      0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
      0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
      0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
      0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2};
  uint32_t h[8] = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
                   0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19};
  std::vector<uint8_t> bytes = input;
  bytes.push_back(0x80);
  while (bytes.size() % 64 != 56) bytes.push_back(0);
  const uint64_t bits = uint64_t(input.size()) * 8;
  for (int shift = 56; shift >= 0; shift -= 8)
    bytes.push_back(uint8_t(bits >> shift));
  for (size_t offset = 0; offset < bytes.size(); offset += 64) {
    uint32_t w[64] = {};
    for (unsigned i = 0; i < 16; ++i)
      for (unsigned j = 0; j < 4; ++j)
        w[i] = (w[i] << 8) | bytes[offset + 4*i + j];
    for (unsigned i = 16; i < 64; ++i) {
      const uint32_t s0 = rotate(w[i-15],7) ^ rotate(w[i-15],18) ^ (w[i-15] >> 3);
      const uint32_t s1 = rotate(w[i-2],17) ^ rotate(w[i-2],19) ^ (w[i-2] >> 10);
      w[i] = w[i-16] + s0 + w[i-7] + s1;
    }
    uint32_t a=h[0],b=h[1],c=h[2],d=h[3],e=h[4],f=h[5],g=h[6],v=h[7];
    for (unsigned i = 0; i < 64; ++i) {
      const uint32_t s1 = rotate(e,6) ^ rotate(e,11) ^ rotate(e,25);
      const uint32_t choose = (e & f) ^ (~e & g);
      const uint32_t t1 = v + s1 + choose + k[i] + w[i];
      const uint32_t s0 = rotate(a,2) ^ rotate(a,13) ^ rotate(a,22);
      const uint32_t majority = (a & b) ^ (a & c) ^ (b & c);
      const uint32_t t2 = s0 + majority;
      v=g;g=f;f=e;e=d+t1;d=c;c=b;b=a;a=t1+t2;
    }
    h[0]+=a;h[1]+=b;h[2]+=c;h[3]+=d;
    h[4]+=e;h[5]+=f;h[6]+=g;h[7]+=v;
  }
  std::ostringstream result;
  result << std::hex << std::setfill('0');
  for (uint32_t word : h) result << std::setw(8) << word;
  return result.str();
}

uint64_t little(const std::vector<uint8_t>& bytes, size_t at, unsigned width) {
  require(at + width <= bytes.size(), "independent little-endian bounds");
  uint64_t value = 0;
  for (unsigned i = 0; i < width; ++i)
    value |= uint64_t(bytes[at+i]) << (8*i);
  return value;
}
void put_little(std::vector<uint8_t>& bytes, size_t at, unsigned width,
                uint64_t value) {
  require(at + width <= bytes.size(), "independent byte mutation bounds");
  for (unsigned i = 0; i < width; ++i)
    bytes[at+i] = uint8_t(value >> (8*i));
}

std::vector<uint8_t> frozen(const fs::path& path, size_t bytes,
                            const char* digest) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "missing frozen fixture: " + path.string());
  std::vector<uint8_t> data{std::istreambuf_iterator<char>(stream),
                            std::istreambuf_iterator<char>()};
  require(data.size() == bytes, "frozen fixture size mismatch: " + path.string());
  require(sha256(data) == digest, "frozen fixture SHA mismatch: " + path.string());
  return data;
}

struct Fixtures {
  std::vector<uint8_t> b2, b1, err_request;
  std::vector<uint8_t> b2_result, b1_result, err_result;
};
Fixtures load_fixtures(const fs::path& root) {
  Fixtures f;
  f.b2 = frozen(root/"inputs/B2_S128.request.bin",1856,
      "d8e39bb3beca881ac6cce3a09b0bad81ca55c83e3ec26436ff21f6b70921e168");
  f.b1 = frozen(root/"inputs/B1_from_b0_S128.request.bin",1152,
      "17c47b88877644c5aba96cbf2e277b607896e303487202184f0c512b72068a6b");
  f.err_request = frozen(root/"inputs/accepted_gamma_failure.request.bin",1856,
      "31ad15be613727200f3705e4815754d7129bde62472adffa02ca183114ae7c92");
  f.b2_result = frozen(root/"dut/B2_S128/result.bin",384,
      "8a726530f8d8e8c01766aacda4d1c864d737d267377be332b6011d9d0cc7c197");
  f.b1_result = frozen(root/"dut/B1_from_b0_S128/result.bin",384,
      "0ac1644cd2477595da577204784365d93bd11934be2da9bf2fb82a63201d02bd");
  f.err_result = frozen(root/"dut/accepted_gamma_failure/result.bin",384,
      "93d0648a83d6e5bf144bd9bd56d8f34ecbd723272f7c2dfff6c2421c8bfd1afd");
  require(std::string(f.b2.begin(),f.b2.begin()+4)=="LYRQ", "B2 request magic");
  require(little(f.b2,20,2)==2 && little(f.b2,22,2)==128 &&
          little(f.b2,24,8)==1 && little(f.b2,32,8)==1,
          "B2 independent header vector");
  require(little(f.b1,20,2)==1 && little(f.b1,24,8)==3 &&
          little(f.b1,32,8)==1, "B1 independent header vector");
  require(little(f.err_result,10,2)==6 && little(f.err_result,16,8)==2,
          "nonOK independent header vector");
  const std::array<uint8_t,16> build = {0xfe,0x06,0x7c,0x8a,0xa0,0x62,0x7a,0xd7,
                                        0x70,0x09,0x6f,0x97,0x21,0x39,0x46,0x45};
  require(std::equal(build.begin(),build.end(),f.b2.begin()+88),
          "fe067 request build tag vector");
  for (unsigned i=16;i<32;++i)
    require(little(f.b1_result,128+4*i,4)==0,"B1 unused candidate lane");
  for (unsigned i=2;i<4;++i)
    require(little(f.b1_result,256+4*i,4)==0,"B1 unused act lane");
  return f;
}

struct Event {
  std::string kind;
  unsigned port=0, group=0;
  uint64_t offset=0, bytes=0;
  std::string file;
};
struct Ledger {
  std::vector<Event> events;
  std::vector<uint8_t> result, last_request;
  WaitState wait_state=WaitState::Completed;
  AbortState abort_state=AbortState::Aborted;
  bool throw_start=false, throw_wait=false, throw_abort=false;
  bool throw_sync=false, throw_read=false, destroyed=false;
  std::function<void()> on_start;
};
unsigned count(const Ledger& ledger, const std::string& kind) {
  return unsigned(std::count_if(ledger.events.begin(),ledger.events.end(),
      [&](const Event& event){return event.kind==kind;}));
}

class FakeBackend final : public EventBackend {
 public:
  explicit FakeBackend(std::shared_ptr<Ledger> log):log_(std::move(log)) {
    log_->events.reserve(256);
  }
  ~FakeBackend() override { log_->destroyed=true; }
  unsigned group_id(unsigned arg) override {
    add("group_id",arg);return 100+arg;
  }
  void allocate(unsigned arg,uint64_t bytes,unsigned group) override {
    add("allocate",arg,0,bytes,group);
  }
  void upload_model(unsigned arg,const char* file,uint64_t bytes) override {
    add("upload",arg,0,bytes,0,file);
  }
  void clear(unsigned arg,uint64_t bytes) override { add("clear",arg,0,bytes); }
  void write_request(const uint8_t* bytes,size_t count) override {
    add("write_request",kIoPort,0,count);
    log_->last_request.assign(bytes,bytes+count);
  }
  void sync_h2d(unsigned arg,uint64_t offset,uint64_t bytes) override {
    add("h2d",arg,offset,bytes);
  }
  void start() override {
    add("start");
    if (log_->on_start) log_->on_start();
    if (log_->throw_start) throw std::runtime_error("start after submit");
  }
  WaitState wait(uint32_t timeout_ms) override {
    add("wait",0,0,timeout_ms);
    if (log_->throw_wait) throw std::runtime_error("wait failed");
    return log_->wait_state;
  }
  AbortState abort() override {
    add("abort");
    if (log_->throw_abort) throw std::runtime_error("abort failed");
    return log_->abort_state;
  }
  void sync_d2h(unsigned arg,uint64_t offset,uint64_t bytes) override {
    add("d2h",arg,offset,bytes);
    if (log_->throw_sync) throw std::runtime_error("result sync failed");
  }
  std::vector<uint8_t> read_result(uint64_t offset,uint64_t bytes) override {
    add("read_result",kIoPort,offset,bytes);
    if (log_->throw_read) throw std::runtime_error("result read failed");
    return log_->result;
  }
  void release_all() noexcept override {
    try { add("release_all"); } catch (...) {}
  }
 private:
  void add(std::string kind,unsigned port=0,uint64_t offset=0,
           uint64_t bytes=0,unsigned group=0,std::string file={}) {
    log_->events.push_back({std::move(kind),port,group,offset,bytes,std::move(file)});
  }
  std::shared_ptr<Ledger> log_;
};

Attestation attested(const fs::path& package) {
  Attestation a;
  a.package_dir=package.string();a.identity=fe067_identity();
  a.manifest_verified=a.five_model_sha_verified=true;
  a.aux_header_verified=a.xclbin_sha_verified=true;
  return a;
}
std::unique_ptr<Session> ready(std::shared_ptr<Ledger> log,
                               const fs::path& package) {
  auto session=std::make_unique<Session>(std::make_unique<FakeBackend>(log));
  std::string error;
  require(session->initialize(attested(package),&error),"initialize: "+error);
  require(session->state()==State::Ready,"Ready after initialization");
  return session;
}

void check_codec_byte_order() {
  const std::array<uint8_t,8> fixed={0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01};
  require(read_u16(fixed.data(),0)==0x0708u,"codec u16 little endian");
  require(read_u32(fixed.data(),0)==0x05060708u,"codec u32 little endian");
  require(read_u64(fixed.data(),0)==0x0102030405060708ull,
          "codec u64 little endian");
  std::array<uint8_t,8> bytes{};
  write_u64(bytes.data(),0,0x0102030405060708ull);
  require(bytes==fixed,"codec u64 fixed output vector");
  bytes.fill(0);write_u32(bytes.data(),2,0x11223344u);
  require(bytes==std::array<uint8_t,8>{0,0,0x44,0x33,0x22,0x11,0,0},
          "codec u32 fixed output vector");
}

void test_initialization_and_two_requests(const Fixtures& f,
                                           const fs::path& package) {
  auto log=std::make_shared<Ledger>();
  Session session(std::make_unique<FakeBackend>(log));
  auto bad=attested(package);bad.manifest_verified=false;
  std::string error;
  require(!session.initialize(bad,&error) && session.state()==State::Cold,
          "failed attestation remains Cold");
  require(log->events.empty(),"failed attestation has no backend event");
  bad=attested(package);bad.package_dir="old-default-model";
  require(!session.initialize(bad,&error) && log->events.empty(),
          "old default package cannot initialize");
  require(session.initialize(attested(package),&error),"valid attestation opens");
  require(count(*log,"group_id")==13 && count(*log,"allocate")==13 &&
          count(*log,"upload")==5,"one 13-BO/5-model initialization");
  const auto sizes=fe067_port_sizes();
  uint64_t uploaded=0;
  for (const Event& event:log->events) {
    if(event.kind=="allocate")
      require(event.port<13 && event.bytes==sizes[event.port] &&
              event.group==100+event.port,"arg-index group_id/BO size");
    if(event.kind=="upload") uploaded+=event.bytes;
  }
  require(uploaded==448923648ull,"five model upload extent");
  log->result=f.b2_result;
  const Outcome first=session.run(f.b2,100);
  require(first.code==OutcomeCode::Ok && first.has_result &&
          first.result.request_id==1 && first.result.batch==2,
          "frozen B2 request/result delivered");
  require(session.state()==State::Ready && session.device_quiescent(),
          "completed B2 returns Ready with terminal proof");
  log->result=f.b1_result;
  const Outcome second=session.run(f.b1,100);
  require(second.code==OutcomeCode::Ok && second.has_result &&
          second.result.request_id==3 && second.result.batch==1,
          "frozen B1 after B2 delivered");
  require(count(*log,"allocate")==13 && count(*log,"upload")==5,
          "second request reuses model BOs");
  require(count(*log,"clear")==16 && count(*log,"h2d")==16 &&
          count(*log,"write_request")==2 && count(*log,"start")==2 &&
          count(*log,"wait")==2 && count(*log,"d2h")==2 &&
          count(*log,"read_result")==2,"two-request exact event counts");
  require(log->last_request==f.b1,"backend saw exact frozen B1 bytes");
  unsigned workspace_clears=0,io_clears=0;
  for (const Event& event:log->events) {
    if(event.kind=="clear" && event.port==kIoPort) {
      ++io_clears;require(event.bytes==32768,"IO zero extent");
    }
    if(event.kind=="clear" && event.port>=6) {
      ++workspace_clears;require(event.bytes==sizes[event.port],"workspace zero extent");
    }
    if(event.kind=="d2h" || event.kind=="read_result")
      require(event.offset==kResultOffset && event.bytes==384,
              "exact result transfer extent");
  }
  require(workspace_clears==14 && io_clears==2,"all workspace/IO clears");
  require(count(*log,"release_all")==0,"no release before close");
  session.close();
  require(count(*log,"release_all")==1 && log->destroyed,
          "terminal close releases once");
}

void test_preflight_and_order(const Fixtures& f,const fs::path& package) {
  auto log=std::make_shared<Ledger>();auto session=ready(log,package);
  const auto no_event=[&](const std::vector<uint8_t>& request) {
    const size_t before=log->events.size();
    const Outcome rejected=session->run(request,100);
    require(rejected.code==OutcomeCode::PreflightRejected &&
            !rejected.has_result && log->events.size()==before,
            "preflight rejects before backend mutation/start");
  };
  auto x=f.b2;x[40]^=1;no_event(x);
  x=f.b2;x[88]^=1;no_event(x);
  x=f.b2;x.push_back(0);no_event(x);
  x=f.b2;x.pop_back();no_event(x);
  x=f.b2;put_little(x,132,4,384);no_event(x);
  x=f.b2;put_little(x,20,2,0);no_event(x);
  x=f.b2;put_little(x,24,8,0);no_event(x);
  x=f.b2;put_little(x,14,2,1);no_event(x);
  require(session->run(f.b2,0).code==OutcomeCode::PreflightRejected,
          "zero timeout is preflight reject");
  log->result=f.b2_result;
  require(session->run(f.b2,100).code==OutcomeCode::Ok,
          "bad preflight did not consume submitted identity");
  no_event(f.b2);
  x=f.b1;put_little(x,24,8,1);no_event(x);
  x=f.b1;put_little(x,32,8,0);no_event(x);
  log->result=f.b1_result;
  require(session->run(f.b1,100).code==OutcomeCode::Ok,
          "later same-generation ID accepted");
  no_event(f.err_request);
}

void test_generation_max_and_busy(const Fixtures& f,const fs::path& package) {
  auto log=std::make_shared<Ledger>();auto session=ready(log,package);
  log->result=f.b2_result;
  log->on_start=[&] {
    const size_t before=log->events.size();
    const Outcome busy=session->run(f.b1,100);
    require(busy.code==OutcomeCode::Busy && log->events.size()==before,
            "in-flight admission has no backend side effect");
  };
  require(session->run(f.b2,100).code==OutcomeCode::Ok,
          "first request with reentrant busy check");
  log->on_start={};
  auto gen2=f.b1;put_little(gen2,24,8,1);put_little(gen2,32,8,2);
  auto gen2_result=f.b1_result;put_little(gen2_result,16,8,1);
  put_little(gen2_result,24,8,2);log->result=gen2_result;
  require(session->run(gen2,100).code==OutcomeCode::Ok,
          "higher generation may use a lower positive ID");
  session->close();

  auto maxlog=std::make_shared<Ledger>();auto maxsession=ready(maxlog,package);
  auto max_request=f.b2;put_little(max_request,24,8,UINT64_MAX);
  put_little(max_request,32,8,UINT64_MAX);
  auto max_result=f.b2_result;put_little(max_result,16,8,UINT64_MAX);
  put_little(max_result,24,8,UINT64_MAX);maxlog->result=max_result;
  require(maxsession->run(max_request,100).code==OutcomeCode::Ok,
          "maximum supplied identity accepted directly");
  const size_t before=maxlog->events.size();
  require(maxsession->run(max_request,100).code==OutcomeCode::PreflightRejected &&
          maxlog->events.size()==before,"maximum identity exhausted without wrap");
}

void test_error_frame_recovery(const Fixtures& f,const fs::path& package) {
  auto log=std::make_shared<Ledger>();auto session=ready(log,package);
  log->result=f.b2_result;
  require(session->run(f.b2,100).code==OutcomeCode::Ok,"B2 before nonOK");
  log->result=f.err_result;
  const Outcome error=session->run(f.err_request,100);
  require(error.code==OutcomeCode::ErrorFrame && error.has_result &&
          error.result.status==Status::E_NUMERICAL && session->state()==State::Ready,
          "valid completed nonOK frame delivered as error");
  log->result=f.b1_result;
  require(session->run(f.b1,100).code==OutcomeCode::Ok,
          "new submitted ID after nonOK frame can run");
  require(count(*log,"start")==3,"three serial starts, no error-frame replay");
}

void test_invalid_results(const Fixtures& f,const fs::path& package) {
  std::vector<std::pair<std::string,std::vector<uint8_t>>> invalid;
  invalid.push_back({"empty",{}});
  auto x=f.b2_result;x.pop_back();invalid.push_back({"383",x});
  x=f.b2_result;x.push_back(0);invalid.push_back({"385",x});
  x=f.b2_result;x[0]='X';invalid.push_back({"magic",x});
  x=f.b2_result;x[80]^=1;invalid.push_back({"tag",x});
  x=f.b2_result;put_little(x,16,8,2);invalid.push_back({"stale-id",x});
  x=f.b2_result;put_little(x,24,8,2);invalid.push_back({"wrong-generation",x});
  x=f.b2_result;put_little(x,96,2,1);invalid.push_back({"wrong-shape",x});
  x=f.b2_result;put_little(x,112,4,1);invalid.push_back({"invalid-flags",x});
  x=f.b2_result;x[124]=1;invalid.push_back({"reserved-header",x});
  x=f.b2_result;x[368]=1;invalid.push_back({"reserved-tail",x});
  x=f.b2_result;put_little(x,128,4,0x7f800000u);
  invalid.push_back({"nonfinite",x});
  for (const auto& item:invalid) {
    auto log=std::make_shared<Ledger>();auto session=ready(log,package);
    log->result=item.second;
    const Outcome out=session->run(f.b2,100);
    require(out.code==OutcomeCode::InvalidResult && !out.has_result &&
            session->state()==State::Poisoned && session->device_quiescent(),
            "malformed result poisons after completed readback: "+item.first);
    require(session->diagnostic_result()==item.second,
            "raw diagnostic bytes retained: "+item.first);
    const unsigned starts=count(*log,"start");
    require(session->run(f.b1,100).code==OutcomeCode::Unavailable &&
            count(*log,"start")==starts,
            "poisoned session forbids next launch: "+item.first);
    session->close();
    require(count(*log,"release_all")==1,
            "proven terminal permits cleanup: "+item.first);
  }
  for (unsigned lane=0;lane<2;++lane) {
    auto log=std::make_shared<Ledger>();auto session=ready(log,package);
    auto result=f.b1_result;
    result[lane==0 ? 128+4*16 : 256+4*2]=1;
    log->result=result;
    const Outcome out=session->run(f.b1,100);
    require(out.code==OutcomeCode::InvalidResult && !out.has_result &&
            session->state()==State::Poisoned && session->device_quiescent(),
            "B1 unused output lane is rejected");
  }
}

void test_uncertain_ownership(const Fixtures& f,const fs::path& package) {
  for (unsigned variant=0;variant<6;++variant) {
    auto log=std::make_shared<Ledger>();
    {
      auto session=ready(log,package);
      if(variant==0)log->throw_start=true;
      if(variant==1)log->throw_wait=true;
      if(variant==5)log->wait_state=WaitState::Unknown;
      if(variant>=2 && variant<=4) {
        log->wait_state=WaitState::Timeout;
        if(variant==2)log->throw_abort=true;
        if(variant==3)log->abort_state=AbortState::Nonterminal;
        if(variant==4)log->abort_state=AbortState::Unknown;
      }
      const Outcome out=session->run(f.b2,100);
      require((out.code==OutcomeCode::DeviceFault ||
               out.code==OutcomeCode::Timeout) &&
              session->state()==State::Poisoned &&
              !session->device_quiescent(),"uncertain submitted fault poisons");
      if(variant!=0) session->close();
      require(count(*log,"release_all")==0,
              "unknown ownership close cannot release BOs");
    }
    require(!log->destroyed && count(*log,"release_all")==0,
            "uncertain ownership survives destructor without release");
  }
}

void test_terminal_faults(const Fixtures& f,const fs::path& package) {
  {
    auto log=std::make_shared<Ledger>();auto session=ready(log,package);
    log->wait_state=WaitState::TerminalError;
    const Outcome out=session->run(f.b2,100);
    require(out.code==OutcomeCode::DeviceFault && !out.has_result &&
            session->state()==State::Poisoned && session->device_quiescent(),
            "terminal wait error poisons while permitting cleanup");
    session->close();
    require(count(*log,"release_all")==1,"terminal wait cleanup");
  }
  for (AbortState terminal:{AbortState::Completed,AbortState::Aborted}) {
    auto log=std::make_shared<Ledger>();auto session=ready(log,package);
    log->wait_state=WaitState::Timeout;log->abort_state=terminal;
    const Outcome out=session->run(f.b2,100);
    require(out.code==OutcomeCode::Timeout && !out.has_result &&
            session->state()==State::Poisoned && session->device_quiescent(),
            "terminal abort remains timeout and Poisoned");
    require(session->run(f.b1,100).code==OutcomeCode::Unavailable &&
            count(*log,"start")==1,"no retry after terminal abort");
    session->close();require(count(*log,"release_all")==1,
                             "terminal timeout cleanup");
  }
  for (unsigned which=0;which<2;++which) {
    auto log=std::make_shared<Ledger>();auto session=ready(log,package);
    log->result=f.b2_result;
    if(which==0)log->throw_sync=true;else log->throw_read=true;
    const Outcome out=session->run(f.b2,100);
    require(out.code==OutcomeCode::DeviceFault &&
            session->state()==State::Poisoned && session->device_quiescent(),
            "result sync/read exception poisons after terminal");
    session->close();require(count(*log,"release_all")==1,
                             "terminal sync/read failure cleanup");
  }
}

}  // namespace

int main(int argc,char** argv) {
  try {
    require(argc==3,"usage: host_session_policy_tb FROZEN_DUT_DIR FE067_PACKAGE_DIR");
    const fs::path fixture_root(argv[1]),package(argv[2]);
    require(package.filename()=="model-attention-rtl-repair-20261008" &&
            fs::is_regular_file(package/"manifest.json"),
            "explicit current fe067 package path");
    const Fixtures f=load_fixtures(fixture_root);
    check_codec_byte_order();
    test_initialization_and_two_requests(f,package);
    test_preflight_and_order(f,package);
    test_generation_max_and_busy(f,package);
    test_error_frame_recovery(f,package);
    test_invalid_results(f,package);
    test_uncertain_ownership(f,package);
    test_terminal_faults(f,package);
    std::cout<<"HOST_SESSION_POLICY_CPU_PASS checks="<<checks<<"\n";
    return 0;
  } catch(const std::exception& error) {
    std::cerr<<"HOST_SESSION_POLICY_CPU_FAIL "<<error.what()<<"\n";
    return 1;
  }
}
