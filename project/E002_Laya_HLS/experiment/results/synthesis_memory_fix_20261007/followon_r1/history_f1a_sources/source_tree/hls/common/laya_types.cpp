#include "laya_types.h"
#include <algorithm>

namespace laya {
namespace {
template<size_t N> void put(std::array<uint8_t,N>& a,unsigned lo,unsigned width,uint64_t v) {
  for(unsigned i=0;i<width;i++) if((v>>i)&1u) a[(lo+i)/8]|=uint8_t(1u<<((lo+i)%8));
}
template<size_t N> uint64_t get(const std::array<uint8_t,N>& a,unsigned lo,unsigned width) {
  uint64_t v=0; for(unsigned i=0;i<width;i++) v|=uint64_t((a[(lo+i)/8]>>((lo+i)%8))&1u)<<i; return v;
}
template<class T> PackedF32 pack_f32(const T& b,uint8_t count) {
  PackedF32 p{}; for(unsigned i=0;i<8;i++) put(p,i*32,32,b.data[i]);
  put(p,256,32,b.task_id);put(p,288,32,b.epoch);put(p,320,16,b.row);put(p,336,16,b.col);
  put(p,352,4,count);put(p,356,1,b.row_last);put(p,357,1,b.task_last);return p;
}
template<class T> void unpack_f32(const PackedF32& p,T& b,uint8_t& count) {
  for(unsigned i=0;i<8;i++) b.data[i]=uint32_t(get(p,i*32,32));
  b.task_id=uint32_t(get(p,256,32));b.epoch=uint32_t(get(p,288,32));
  b.row=uint16_t(get(p,320,16));b.col=uint16_t(get(p,336,16));count=uint8_t(get(p,352,4));
  b.row_last=get(p,356,1);b.task_last=get(p,357,1);
}
}
PackedF32 pack(const F32Beat& b) { return pack_f32(b,b.valid_count); }
PackedF32 pack(const WiPairBeat& b) { return pack_f32(b,b.pair_count); }
PackedQ8 pack(const Q8Group& b) {
  PackedQ8 p{};for(unsigned i=0;i<32;i++)put(p,i*8,8,uint8_t(b.q[i]));
  put(p,256,16,b.scale_bits);put(p,272,32,b.task_id);put(p,304,32,b.epoch);
  put(p,336,4,b.row_local);put(p,340,8,b.group);put(p,348,1,b.row_last);put(p,349,1,b.tile_last);return p;
}
Check unpack(const PackedF32& p,F32Beat& b) {
  if(p[44]&0xc0) return {Status::E_PROTOCOL,detail(6,1,3)};
  unpack_f32(p,b,b.valid_count);return b.valid_count>=1&&b.valid_count<=8?ok():Check{Status::E_PROTOCOL,detail(6,1,4)};
}
Check unpack(const PackedF32& p,WiPairBeat& b) {
  if(p[44]&0xc0) return {Status::E_PROTOCOL,detail(6,3,3)};
  unpack_f32(p,b,b.pair_count);return b.pair_count>=1&&b.pair_count<=4?ok():Check{Status::E_PROTOCOL,detail(6,3,4)};
}
Check unpack(const PackedQ8& p,Q8Group& b) {
  if(p[43]&0xc0) return {Status::E_PROTOCOL,detail(6,2,3)};
  for(unsigned i=0;i<32;i++) b.q[i]=int8_t(uint8_t(get(p,i*8,8)));
  b.scale_bits=uint16_t(get(p,256,16));b.task_id=uint32_t(get(p,272,32));b.epoch=uint32_t(get(p,304,32));
  b.row_local=uint8_t(get(p,336,4));b.group=uint8_t(get(p,340,8));
  b.row_last=get(p,348,1);b.tile_last=get(p,349,1);return ok();
}
Check check_beat(const F32Beat& b,uint16_t width,uint16_t last_row,uint8_t lanes) {
  if(lanes!=4&&lanes!=8) return {Status::E_PROTOCOL,detail(6,1,4)};
  if(!b.task_id||b.task_id>kMaxEpoch||!b.epoch||b.epoch>kMaxEpoch||b.row>last_row||b.col>=width||!b.valid_count||b.valid_count>lanes) return {Status::E_PROTOCOL,detail(6,1,4)};
  const uint8_t expected=uint8_t(std::min<unsigned>(lanes,width-b.col));
  if(b.valid_count!=expected||b.col%lanes||b.row_last!=(b.col+b.valid_count==width)||b.task_last!=(b.row==last_row&&b.row_last)) return {Status::E_PROTOCOL,detail(6,1,12)};
  for(unsigned i=b.valid_count;i<8;i++)if(b.data[i])return {Status::E_PROTOCOL,detail(6,1,3)};
  return ok();
}
Check check_beat(const WiPairBeat& b,uint16_t last_row) {
  if(!b.task_id||b.task_id>kMaxEpoch||!b.epoch||b.epoch>kMaxEpoch||b.row>last_row||b.col>=2624||!b.pair_count||b.pair_count>4) return {Status::E_PROTOCOL,detail(6,3,4)};
  if(b.col%4||b.pair_count!=std::min<unsigned>(4,2624-b.col)||b.row_last!=(b.col+b.pair_count==2624)||b.task_last!=(b.row==last_row&&b.row_last))return {Status::E_PROTOCOL,detail(6,3,12)};
  for(unsigned i=b.pair_count;i<4;i++)if(b.data[i]||b.data[i+4])return {Status::E_PROTOCOL,detail(6,3,3)};
  return ok();
}
Check check_group(const Q8Group& b,uint8_t rows,uint8_t groups) {
  if(!b.task_id||b.task_id>kMaxEpoch||!b.epoch||b.epoch>kMaxEpoch||!rows||rows>16||!groups||groups>128||b.row_local>=rows||b.group>=groups)return {Status::E_PROTOCOL,detail(6,2,4)};
  if(b.row_last!=(b.group+1==groups)||b.tile_last!=(b.row_local+1==rows&&b.row_last))return {Status::E_PROTOCOL,detail(6,2,12)};
  return ok();
}
Check check_dot_issue(const DotIssue& d,uint8_t rows,uint16_t K,uint16_t N){
  if(!d.task_id||d.task_id>kMaxEpoch||!d.a_epoch||d.a_epoch>kMaxEpoch||!d.w_epoch||d.w_epoch>kMaxEpoch||!d.ps_epoch||d.ps_epoch>kMaxEpoch||rows<1||rows>16||K%32||K<32||K>4096||N<1||N>5248)return {Status::E_PROTOCOL,detail(6,2,4)};
  if(d.group>=K/32||d.n0>=N||d.n0%8||d.valid_rows!=rows||d.valid_cols!=std::min<unsigned>(8,N-d.n0))return {Status::E_PROTOCOL,detail(6,2,12)};
  return ok();
}
}
