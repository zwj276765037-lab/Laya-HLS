#include "contract_test.h"
#include "kernel_wrapper.h"
#include <array>
int main(){using namespace laya;using namespace laya::kernel_wrapper;test::require(ports.size()==13,"13 ports");
  std::array<uint8_t,13> banks{0,1,4,5,6,7,12,13,14,15,16,17,18};
  for(unsigned i=0;i<13;i++){test::require(unsigned(ports[i].bo)==i,"arg index");test::require(ports[i].candidate_hbm==banks[i],"candidate bank");}
  Request r;test::require(validate_offline({},r).code==Status::E_ABI,"short frame rejected");}
