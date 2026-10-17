#include "contract_test.h"
#include "laya_io.h"
#include <fstream>
#include <iterator>
#include <vector>

int main(int argc,char** argv){
  using namespace laya;
  test::require(argc==2,"fixture path argument");
  std::ifstream f(argv[1],std::ios::binary);
  test::require(bool(f),"open real fixture");
  std::vector<uint8_t> fixture(std::istreambuf_iterator<char>{f},{});
  Request real;
  test::require(parse_request(fixture,real),"parse real request");
  test::require(real.batch==2&&real.seq_len==128&&real.frame_bytes==1856,"real shape");
  std::vector<uint8_t> roundtrip;
  test::require(encode_request(real,roundtrip)&&roundtrip==fixture,"byte exact re-encode");

  Identity synthetic=real.identity;
  synthetic.numeric.fill(0x31);synthetic.layout.fill(0x42);synthetic.build.fill(0x53);
  test::require(parse_request(fixture,real,&synthetic).code==Status::E_ABI,"zero tag strict reject");
  Request tagged=real;tagged.identity=synthetic;
  std::vector<uint8_t> valid;
  test::require(encode_request(tagged,valid,&synthetic),"supplemental nonzero identity encode");
  Request decoded;
  test::require(parse_request(valid,decoded,&synthetic),"supplemental strict accept");

  auto changed=valid;
  changed[56]^=1;
  test::require(parse_request(changed,decoded,&synthetic).detail==detail(1,56,2),"numeric identity exact field");
  changed=valid;changed[72]^=1;
  test::require(parse_request(changed,decoded,&synthetic).detail==detail(1,72,2),"layout identity exact field");
  changed=valid;changed[88]^=1;
  test::require(parse_request(changed,decoded,&synthetic).detail==detail(1,88,2),"build identity exact field");

  changed=valid;changed.resize(200);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_BUFFER,"truncated payload");
  changed=valid;write_u32(changed.data(),128+4,256);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_BUFFER,"overlap offset");
  changed=valid;write_u32(changed.data(),128+4,UINT32_MAX);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_BUFFER,"huge offset");
  changed=valid;write_u32(changed.data(),128+16,999);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_SHAPE,"wrong stride");
  changed=valid;write_u32(changed.data(),320,50368);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_INDEX,"illegal token");
  changed=valid;changed[1344]=2;
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_INDEX,"illegal mask");
  changed=valid;
  unsigned valid_marker=0;
  while(valid_marker<32&&real.tensor[3][valid_marker]==0)valid_marker++;
  test::require(valid_marker<32,"real valid marker");
  write_u32(changed.data(),1600+4*valid_marker,UINT32_MAX);
  test::require(parse_request(changed,decoded,&synthetic).code==Status::E_INDEX,"illegal marker");

  TaskContext unknown=test::ctx(static_cast<Op>(0xff),2,0);
  test::require(check_context(unknown,2,128).code==Status::E_PROTOCOL,"unknown op");
  Result error;error.status=Status::E_SHAPE;
  std::array<uint8_t,kResultBytes> output;
  test::require(encode_result(error,output),"unknown shape error result");
  error.request_id=1;
  test::require(!encode_result(error,output),"identity invalid cannot echo ID");
  error=Result{};error.status=Status::OK;error.request_id=1;error.generation=1;error.flags=3;error.batch=1;error.seq_len=128;
  test::require(encode_result(error,output),"OK with counters absent");
  error.flags=7;error.counter_scope=0;
  test::require(!encode_result(error,output),"cycles flag needs scope");
  error.counter_scope=1;
  test::require(encode_result(error,output),"cycles scope valid");
  error.flags=15;error.committed_output_elements=0;
  test::require(!encode_result(error,output),"event count must match output");
  error.committed_output_elements=18;
  test::require(encode_result(error,output),"event count valid");
  std::cout<<"ABI_BAD_FRAME_CONTRACT_PASS supplemental_mutations=10\n";
}
