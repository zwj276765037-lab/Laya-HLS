#include "contract_test.h"
#include "result_status.h"
int main(){using namespace laya;Result r;r.status=Status::E_SHAPE;r.batch=0;r.seq_len=0;r.first_bad_element=UINT64_MAX;std::array<uint8_t,kResultBytes> bytes;test::require(result_status::encode_contract(r,bytes),"shape error has unknown B/S");Result decoded;test::require(decode_result({bytes.begin(),bytes.end()},decoded)&&decoded.status==Status::E_SHAPE,"error roundtrip");
  r.status=Status::OK;r.flags=3;r.request_id=1;r.generation=1;r.batch=1;r.seq_len=128;r.candidate_bits[0]=0x7f800000;test::require(result_status::encode_contract(r,bytes),"OK without event counters");r.candidate_bits[16]=1;test::require(!result_status::encode_contract(r,bytes),"B1 unused row must clear");}
