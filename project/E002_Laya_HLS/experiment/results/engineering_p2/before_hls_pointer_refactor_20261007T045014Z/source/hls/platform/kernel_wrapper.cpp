#include "kernel_wrapper.h"

namespace laya::kernel_wrapper {
const std::array<Port,kBoCount> ports{{
  {"embedding",Bo::EMBEDDING,0},{"io",Bo::IO,1},{"w_q0",Bo::W_Q0,4},{"w_q1",Bo::W_Q1,5},
  {"w_scale",Bo::W_SCALE,6},{"aux",Bo::AUX,7},{"state0",Bo::STATE0,12},{"state1",Bo::STATE1,13},
  {"qkv0",Bo::QKV0,14},{"qkv1",Bo::QKV1,15},{"ff0",Bo::FF0,16},{"ff1",Bo::FF1,17},{"att_out",Bo::ATT_OUT,18}
}};
Check validate_offline(const std::vector<uint8_t>& frame,Request& out){return parse_request(frame,out);}
Check validate_strict(const std::vector<uint8_t>& frame,const Identity& expected,Request& out){return parse_request(frame,out,&expected);}
}
