#include "laya_io.h"
#include <algorithm>
#include <cstring>
#include <limits>

namespace laya {
uint16_t read_u16(const uint8_t* p,size_t n){return uint16_t(p[n]|uint16_t(p[n+1])<<8);}
uint32_t read_u32(const uint8_t* p,size_t n){uint32_t v=0;for(unsigned i=0;i<4;i++)v|=uint32_t(p[n+i])<<(8*i);return v;}
uint64_t read_u64(const uint8_t* p,size_t n){uint64_t v=0;for(unsigned i=0;i<8;i++)v|=uint64_t(p[n+i])<<(8*i);return v;}
void write_u16(uint8_t* p,size_t n,uint16_t v){for(unsigned i=0;i<2;i++)p[n+i]=uint8_t(v>>(8*i));}
void write_u32(uint8_t* p,size_t n,uint32_t v){for(unsigned i=0;i<4;i++)p[n+i]=uint8_t(v>>(8*i));}
void write_u64(uint8_t* p,size_t n,uint64_t v){for(unsigned i=0;i<8;i++)p[n+i]=uint8_t(v>>(8*i));}
bool zero_tag(const Tag& t){return std::all_of(t.begin(),t.end(),[](uint8_t x){return x==0;});}
namespace {
Check bad(Status s,uint8_t domain,uint8_t object,uint16_t reason,uint64_t i=UINT64_MAX){return {s,detail(domain,object,reason),i};}
uint64_t align64(uint64_t x){return (x+63u)&~uint64_t(63);}
void copy_tag(Tag& t,const uint8_t* p,size_t n){std::copy_n(p+n,16,t.begin());}
void put_tag(uint8_t* p,size_t n,const Tag& t){std::copy(t.begin(),t.end(),p+n);}
bool seq_ok(uint16_t s){return s==64||s==128||s==256||s==512||s==1024;}
uint32_t len(unsigned i,uint16_t b,uint16_t s){switch(i){case 0:return 4u*b*s;case 1:return uint32_t(b)*s;case 2:return 64u*b;case 3:return 16u*b;default:return 4u*b;}}
Directory standard_dir(unsigned i,uint16_t b,uint16_t s,uint32_t offset){
  Directory d;d.tensor_id=uint16_t(i+1);d.dtype=(i==1||i==3)?2:1;d.rank=i==4?1:2;d.offset=offset;d.byte_length=len(i,b,s);d.dim0=b;d.dim1=i<2?s:(i==4?1:16);d.stride0=i==0?4u*s:(i==1?s:(i==2?64u:(i==3?16u:4u)));d.stride1=i==4?0:(d.dtype==1?4:1);d.element_count=i<2?uint32_t(b)*s:(i==4?b:16u*b);return d;
}
bool eq(const Directory& a,const Directory& b){return a.tensor_id==b.tensor_id&&a.dtype==b.dtype&&a.rank==b.rank&&a.offset==b.offset&&a.byte_length==b.byte_length&&a.dim0==b.dim0&&a.dim1==b.dim1&&a.stride0==b.stride0&&a.stride1==b.stride1&&a.element_count==b.element_count;}
void get_dir(const uint8_t* p,size_t n,Directory& d){d.tensor_id=read_u16(p,n);d.dtype=p[n+2];d.rank=p[n+3];d.offset=read_u32(p,n+4);d.byte_length=read_u32(p,n+8);d.dim0=read_u16(p,n+12);d.dim1=read_u16(p,n+14);d.stride0=read_u32(p,n+16);d.stride1=read_u32(p,n+20);d.element_count=read_u32(p,n+24);}
void put_dir(uint8_t* p,size_t n,const Directory& d){write_u16(p,n,d.tensor_id);p[n+2]=d.dtype;p[n+3]=d.rank;write_u32(p,n+4,d.offset);write_u32(p,n+8,d.byte_length);write_u16(p,n+12,d.dim0);write_u16(p,n+14,d.dim1);write_u32(p,n+16,d.stride0);write_u32(p,n+20,d.stride1);write_u32(p,n+24,d.element_count);}
Check check_inputs(const Request& r){
  for(uint16_t b=0;b<r.batch;b++){
    unsigned tokens=0,candidates=0;
    for(uint16_t s=0;s<r.seq_len;s++){
      uint64_t i=uint64_t(b)*r.seq_len+s;uint32_t id=read_u32(r.tensor[0].data(),4*i);uint8_t mask=r.tensor[1][i];
      if(id>=kVocab||mask>1)return bad(Status::E_INDEX,3,id>=kVocab?1:2,4,i);
      tokens+=mask;
    }
    if(!tokens)return bad(Status::E_INDEX,3,2,13,b);
    for(uint16_t c=0;c<16;c++){
      uint64_t i=uint64_t(b)*16+c;uint32_t marker=read_u32(r.tensor[2].data(),4*i);uint8_t mask=r.tensor[3][i];
      if(mask>1)return bad(Status::E_INDEX,3,4,4,i);
      candidates+=mask;
      if(mask){if(marker<uint32_t(b)*r.seq_len||marker>=uint32_t(b+1)*r.seq_len||r.tensor[1][marker]==0)return bad(Status::E_INDEX,3,3,4,i);}
      else if(marker!=uint32_t(b)*r.seq_len)return bad(Status::E_INDEX,3,3,4,i);
    }
    if(!candidates)return bad(Status::E_INDEX,3,4,13,b);
    if(read_u32(r.tensor[4].data(),4*b)>2)return bad(Status::E_INDEX,3,5,4,b);
  }
  return ok();
}
Check check_identity(const Identity& a,const Identity* e){
  if(!e)return ok();
  if(zero_tag(a.model)||a.model!=e->model)return bad(Status::E_MODEL,1,40,2);
  if(zero_tag(a.numeric)||a.numeric!=e->numeric)return bad(Status::E_ABI,1,56,2);
  if(zero_tag(a.layout)||a.layout!=e->layout)return bad(Status::E_ABI,1,72,2);
  if(zero_tag(a.build)||a.build!=e->build)return bad(Status::E_ABI,1,88,2);
  return ok();
}
}
Check parse_request(const std::vector<uint8_t>& in,Request& out,const Identity* expected){
  if(in.size()<kRequestHeaderBytes)return bad(Status::E_ABI,1,0,8);
  const uint8_t* p=in.data();
  if(std::memcmp(p,"LYRQ",4))return bad(Status::E_ABI,1,0,1);
  if(read_u16(p,4)!=1||read_u16(p,6)!=0)return bad(Status::E_ABI,1,4,2);
  if(read_u16(p,8)!=128||read_u16(p,10)!=32||read_u16(p,12)!=5)return bad(Status::E_ABI,1,8,5);
  if(read_u16(p,14)||read_u64(p,120))return bad(Status::E_ABI,1,14,3);
  if(read_u64(p,24)==0||read_u64(p,32)==0)return bad(Status::E_ABI,1,24,4);
  Request r;r.request_id=read_u64(p,24);r.generation=read_u64(p,32);
  copy_tag(r.identity.model,p,40);copy_tag(r.identity.numeric,p,56);copy_tag(r.identity.layout,p,72);copy_tag(r.identity.build,p,88);
  Check c=check_identity(r.identity,expected);if(!c)return c;
  r.batch=read_u16(p,20);r.seq_len=read_u16(p,22);
  if(r.batch<1||r.batch>2||!seq_ok(r.seq_len))return bad(Status::E_SHAPE,1,20,5);
  r.frame_bytes=read_u32(p,16);
  if(r.frame_bytes<kRequestPayloadOffset||r.frame_bytes>kRequestLimit||r.frame_bytes%64||in.size()<r.frame_bytes||read_u32(p,104)!=128||read_u32(p,108)!=320||read_u32(p,112)!=16384||read_u32(p,116)!=4096)return bad(Status::E_BUFFER,1,16,8);
  for(size_t n=288;n<320;n++)if(p[n])return bad(Status::E_ABI,1,108,3);
  uint64_t offset=320;
  for(unsigned i=0;i<5;i++){
    size_t at=128+32*i;get_dir(p,at,r.dirs[i]);
    if(read_u32(p,at+28))return bad(Status::E_ABI,2,uint8_t(i+1),3);
    if(offset>UINT32_MAX)return bad(Status::E_BUFFER,2,uint8_t(i+1),8);
    Directory want=standard_dir(i,r.batch,r.seq_len,uint32_t(offset));
    if(r.dirs[i].offset!=want.offset)return bad(Status::E_BUFFER,2,uint8_t(i+1),7);
    if(r.dirs[i].byte_length!=want.byte_length)return bad(Status::E_BUFFER,2,uint8_t(i+1),8);
    if(!eq(r.dirs[i],want))return bad(Status::E_SHAPE,2,uint8_t(i+1),6);
    if(offset+want.byte_length>r.frame_bytes)return bad(Status::E_BUFFER,2,uint8_t(i+1),8);
    offset=align64(offset+want.byte_length);
  }
  if(offset!=r.frame_bytes)return bad(Status::E_BUFFER,1,16,8);
  // No tensor payload is touched until all five descriptors and their bounds pass.
  for(unsigned i=0;i<5;i++){
    const Directory& d=r.dirs[i];
    r.tensor[i].assign(p+d.offset,p+d.offset+d.byte_length);
    uint64_t end=uint64_t(d.offset)+d.byte_length,next=align64(end);
    for(uint64_t j=end;j<next;j++)if(p[j])return bad(Status::E_ABI,2,uint8_t(i+1),3);
  }
  c=check_inputs(r);if(!c)return c;out=std::move(r);return ok();
}
Check encode_request(const Request& r,std::vector<uint8_t>& out,const Identity* expected){
  if(r.batch<1||r.batch>2||!seq_ok(r.seq_len)||!r.request_id||!r.generation)return bad(Status::E_SHAPE,1,20,5);
  Check c=check_identity(r.identity,expected);if(!c)return c;
  uint64_t offset=320;std::array<Directory,5> dirs{};
  for(unsigned i=0;i<5;i++){dirs[i]=standard_dir(i,r.batch,r.seq_len,uint32_t(offset));if(r.tensor[i].size()!=dirs[i].byte_length)return bad(Status::E_SHAPE,2,uint8_t(i+1),6);offset=align64(offset+dirs[i].byte_length);}
  if(offset>kRequestLimit)return bad(Status::E_BUFFER,1,16,8);
  c=check_inputs(r);if(!c)return c;
  out.assign(offset,0);uint8_t* p=out.data();std::memcpy(p,"LYRQ",4);write_u16(p,4,1);write_u16(p,8,128);write_u16(p,10,32);write_u16(p,12,5);write_u32(p,16,uint32_t(offset));write_u16(p,20,r.batch);write_u16(p,22,r.seq_len);write_u64(p,24,r.request_id);write_u64(p,32,r.generation);
  put_tag(p,40,r.identity.model);put_tag(p,56,r.identity.numeric);put_tag(p,72,r.identity.layout);put_tag(p,88,r.identity.build);
  write_u32(p,104,128);write_u32(p,108,320);write_u32(p,112,16384);write_u32(p,116,4096);
  for(unsigned i=0;i<5;i++){put_dir(p,128+32*i,dirs[i]);std::copy(r.tensor[i].begin(),r.tensor[i].end(),p+dirs[i].offset);}return ok();
}
Check validate_result(const Result& r){
  if(uint16_t(r.status)>8||r.flags&~15u||r.batch>2)return bad(Status::E_ABI,1,10,4);
  if((r.flags&1)==0 && (r.request_id||r.generation))return bad(Status::E_ABI,1,112,14);
  if((r.flags&1)!=0 && (!r.request_id||!r.generation))return bad(Status::E_ABI,1,112,14);
  if(r.batch==0){if(r.seq_len!=0)return bad(Status::E_ABI,1,98,5);}
  else if(!seq_ok(r.seq_len))return bad(Status::E_ABI,1,98,5);
  if((r.flags&4)==0){if(r.prewrite_cycles||r.counter_scope)return bad(Status::E_ABI,1,112,14);}
  else if(r.counter_scope!=1)return bad(Status::E_ABI,1,112,14);
  if((r.flags&8)==0 && (r.tasks_retired||r.accepted_input_elements||r.committed_output_elements))return bad(Status::E_ABI,1,112,14);

  if(r.status==Status::OK){
    if((r.flags&3)!=3||r.batch<1||r.error_stage||r.error_operator||r.error_detail||r.error_task_id||r.first_bad_element!=UINT64_MAX)return bad(Status::E_ABI,1,112,14);
    if((r.flags&8)!=0 && r.committed_output_elements!=18u*r.batch)return bad(Status::E_ABI,1,112,14);
    for(unsigned i=16*r.batch;i<32;i++)if(r.candidate_bits[i])return bad(Status::E_ABI,1,100,3);
    for(unsigned i=2*r.batch;i<4;i++)if(r.act_bits[i])return bad(Status::E_ABI,1,102,3);
  }else{
    if(r.flags&2||r.committed_output_elements)return bad(Status::E_ABI,1,112,14);
    for(auto x:r.candidate_bits)if(x)return bad(Status::E_ABI,1,100,3);
    for(auto x:r.act_bits)if(x)return bad(Status::E_ABI,1,102,3);
  }
  return ok();
}
Check encode_result(const Result& r,std::array<uint8_t,kResultBytes>& out){
  Check c=validate_result(r);if(!c)return c;out.fill(0);uint8_t* p=out.data();std::memcpy(p,"LYRS",4);write_u16(p,4,1);write_u16(p,8,128);write_u16(p,10,uint16_t(r.status));write_u32(p,12,384);write_u64(p,16,r.request_id);write_u64(p,24,r.generation);put_tag(p,32,r.identity.model);put_tag(p,48,r.identity.numeric);put_tag(p,64,r.identity.layout);put_tag(p,80,r.identity.build);write_u16(p,96,r.batch);write_u16(p,98,r.seq_len);write_u16(p,100,r.status==Status::OK?16*r.batch:0);write_u16(p,102,r.status==Status::OK?2*r.batch:0);write_u32(p,104,128);write_u32(p,108,256);write_u32(p,112,r.flags);write_u16(p,116,r.error_stage);write_u16(p,118,r.error_operator);write_u32(p,120,r.error_detail);
  for(unsigned i=0;i<32;i++)write_u32(p,128+4*i,r.candidate_bits[i]);
  for(unsigned i=0;i<4;i++)write_u32(p,256+4*i,r.act_bits[i]);
  write_u64(p,320,r.prewrite_cycles);write_u64(p,328,r.tasks_retired);write_u64(p,336,r.accepted_input_elements);write_u64(p,344,r.committed_output_elements);write_u64(p,352,r.first_bad_element);write_u32(p,360,r.error_task_id);write_u32(p,364,r.counter_scope);return ok();
}
Check decode_result(const std::vector<uint8_t>& in,Result& out,const Identity* expected){
  if(in.size()<kResultBytes)return bad(Status::E_ABI,1,12,8);
  const uint8_t* p=in.data();
  if(std::memcmp(p,"LYRS",4)||read_u16(p,4)!=1||read_u16(p,6)!=0||read_u16(p,8)!=128||read_u32(p,12)!=384||read_u32(p,104)!=128||read_u32(p,108)!=256)return bad(Status::E_ABI,1,0,1);
  if(read_u32(p,124))return bad(Status::E_ABI,1,124,3);
  for(unsigned i=272;i<320;i++)if(p[i])return bad(Status::E_ABI,1,104,3);
  for(unsigned i=368;i<384;i++)if(p[i])return bad(Status::E_ABI,1,124,3);
  Result r;r.status=Status(read_u16(p,10));r.request_id=read_u64(p,16);r.generation=read_u64(p,24);copy_tag(r.identity.model,p,32);copy_tag(r.identity.numeric,p,48);copy_tag(r.identity.layout,p,64);copy_tag(r.identity.build,p,80);Check c=check_identity(r.identity,expected);if(!c)return c;
  r.batch=read_u16(p,96);r.seq_len=read_u16(p,98);r.flags=read_u32(p,112);r.error_stage=read_u16(p,116);r.error_operator=read_u16(p,118);r.error_detail=read_u32(p,120);
  for(unsigned i=0;i<32;i++)r.candidate_bits[i]=read_u32(p,128+4*i);
  for(unsigned i=0;i<4;i++)r.act_bits[i]=read_u32(p,256+4*i);
  r.prewrite_cycles=read_u64(p,320);r.tasks_retired=read_u64(p,328);r.accepted_input_elements=read_u64(p,336);r.committed_output_elements=read_u64(p,344);r.first_bad_element=read_u64(p,352);r.error_task_id=read_u32(p,360);r.counter_scope=read_u32(p,364);
  if(read_u16(p,100)!=(r.status==Status::OK?16*r.batch:0)||read_u16(p,102)!=(r.status==Status::OK?2*r.batch:0))return bad(Status::E_ABI,1,100,14);
  c=validate_result(r);if(!c)return c;out=r;return ok();
}
}
