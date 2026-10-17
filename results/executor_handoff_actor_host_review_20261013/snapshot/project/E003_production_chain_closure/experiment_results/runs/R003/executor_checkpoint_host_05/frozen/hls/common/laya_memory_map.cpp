#include "laya_memory_map.h"

namespace laya {
namespace {
Check bad(Buffer id,uint16_t reason=4){return {Status::E_BUFFER,detail(4,uint8_t(id),reason)};}
constexpr uint32_t MB=1024u*1024u;
}
Check span(BufferRef r,uint8_t region,Span& out){
  Check c=check_ref(r,region);if(!c)return c;
  switch(r.id){
    case Buffer::HIDDEN:out={r.bank?Bo::STATE1:Bo::STATE0,0,8*MB};break;
    case Buffer::NORM:out={Bo::STATE0,8*MB,8*MB};break;
    case Buffer::TMP:out={Bo::STATE1,8*MB,8*MB};break;
    case Buffer::MARKER:out={Bo::STATE0,16*MB,131072};break;
    case Buffer::QKV:out={r.bank?Bo::QKV1:Bo::QKV0,0,12*MB};break;
    case Buffer::WI:out={Bo::FF0,0,41*MB};break;
    case Buffer::GATE:out={Bo::FF1,0,21*MB-512*1024};break;
    case Buffer::ATT_OUT:out={Bo::ATT_OUT,0,8*MB};break;
    case Buffer::DEC_FF:out={Bo::FF0,0,32*MB};break;
    case Buffer::TYPE_ROWS:out={Bo::STATE0,16908288,12288};break;
    case Buffer::HEAD_WORK:{
      static constexpr uint32_t bases[]={0,131072,139328,141376,141504,141568,141632,141760};
      static constexpr uint32_t bytes[]={131072,8224,2048,128,64,64,128,128};
      out={Bo::STATE1,16777216+bases[region],bytes[region]};break;
    }
    default:return bad(r.id);
  }
  return ok();
}
Check byte_address(BufferRef r,uint8_t region,uint64_t relative,uint32_t size,Address& out){
  Span s;Check c=span(r,region,s);if(!c)return c;
  if(size==0||relative>UINT32_MAX||relative+uint64_t(size)>s.bytes||uint64_t(s.base)+relative+size>UINT32_MAX)return bad(r.id,8);
  out={s.bo,uint32_t(uint64_t(s.base)+relative)};return ok();
}
Check f32_address(BufferRef r,uint8_t region,uint8_t batch,uint16_t row,uint16_t col,uint16_t B,uint16_t S,Address& out){
  if(batch>=B||B<1||B>2||S<64||S>1024||row>=S)return bad(r.id,5);
  uint32_t width=0;uint64_t index=0;
  switch(r.id){
    case Buffer::HIDDEN:case Buffer::NORM:case Buffer::TMP:case Buffer::ATT_OUT:width=1024;index=(uint64_t(batch)*1024+row)*width+col;break;
    case Buffer::WI:width=5248;index=(uint64_t(batch)*1024+row)*width+col;break;
    case Buffer::GATE:width=2624;index=(uint64_t(batch)*1024+row)*width+col;break;
    case Buffer::DEC_FF:width=4096;index=(uint64_t(batch)*1024+row)*width+col;break;
    default:return bad(r.id);
  }
  if(col>=width)return bad(r.id,4);
  return byte_address(r,region,index*4,4,out);
}
Check qkv_address(uint8_t plane,uint8_t batch,uint8_t head,uint16_t token,uint8_t d,uint16_t B,uint16_t S,Address& out){
  if(plane>=3||batch>=B||B<1||B>2||head>=16||token>=S||S>1024||d>=64)return bad(Buffer::QKV,4);
  const uint8_t shard=head%2,local_head=head/2;
  const uint64_t index=(((((uint64_t(plane)*2+batch)*8+local_head)*1024+token)*64)+d);
  return byte_address({Buffer::QKV,shard,1},0,index*4,4,out);
}
Check marker_token_row(uint32_t marker,uint8_t batch,uint16_t S,uint16_t& physical_row){
  if(S<64||S>1024||batch>1||marker<uint32_t(batch)*S||marker>=uint32_t(batch+1)*S)return bad(Buffer::MARKER,4);
  physical_row=uint16_t(uint32_t(batch)*1024+(marker-uint32_t(batch)*S));return ok();
}
Check q8_weight_addresses(const Q8Descriptor& d,uint16_t n,uint16_t k,Address& q,Address& scale){
  if(!d.N||!d.K||d.K%32||n>=d.N||k>=d.K)return bad(Buffer::WEIGHT,5);
  const uint64_t G=d.K/32,t=n/8,lane=n%8,g=k/32,j=k%32,shard=t%2,local_t=t/2;
  const uint64_t qo=(((local_t*G+g)*8+lane)*32+j),so=((t*G+g)*8+lane)*2;
  if(qo>=d.q_span[shard]||so+2>d.scale_span||uint64_t(d.q_base[shard])+qo>UINT32_MAX||uint64_t(d.scale_base)+so+2>UINT32_MAX)return bad(Buffer::WEIGHT,8);
  q={shard?Bo::W_Q1:Bo::W_Q0,uint32_t(uint64_t(d.q_base[shard])+qo)};
  scale={Bo::W_SCALE,uint32_t(uint64_t(d.scale_base)+so)};return ok();
}
}
