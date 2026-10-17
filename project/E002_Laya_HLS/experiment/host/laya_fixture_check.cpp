#include "kernel_wrapper.h"
#include <fstream>
#include <iostream>
#include <iterator>
#include <array>
#include <cstring>

namespace {
std::vector<uint8_t> read_file(const char* path){
  std::ifstream f(path,std::ios::binary);
  return f?std::vector<uint8_t>(std::istreambuf_iterator<char>{f},{}):std::vector<uint8_t>{};
}
bool check_q8(const char* path,unsigned groups,unsigned rows){
  auto v=read_file(path);
  if(v.size()!=uint64_t(groups)*rows*34)return false;
  for(uint64_t index:std::array<uint64_t,3>{0,uint64_t(groups),uint64_t(groups)*rows-1}){
    auto pos=index*34;
    laya::Q8Group g;
    g.scale_bits=laya::read_u16(v.data(),pos);
    std::memcpy(g.q.data(),v.data()+pos+2,32);
    g.task_id=1;g.epoch=1;g.row_local=(index/groups)%16;g.group=index%groups;
    g.row_last=g.group+1==groups;
    g.tile_last=g.row_last&&(g.row_local==15||index==uint64_t(groups)*rows-1);
    auto packed=laya::pack(g);
    laya::Q8Group back;
    if(!laya::unpack(packed,back)||!laya::check_group(back,g.row_local+1,groups)||back.scale_bits!=g.scale_bits||back.q!=g.q)return false;
  }
  return true;
}
}

int main(int argc,char** argv){
  if(argc!=2&&argc!=8){std::cerr<<"usage: laya_fixture_check request_v1.bin [qkv.q8 down.q8 act.q8 act_input.bin candidate.bin act.bin]\n";return 2;}
  std::vector<uint8_t> bytes=read_file(argv[1]);
  if(bytes.empty()){std::cerr<<"cannot open fixture\n";return 2;}
  laya::Request r;
  auto c=laya::kernel_wrapper::validate_offline(bytes,r);
  if(!c){std::cerr<<"request rejected status="<<unsigned(c.code)<<" detail="<<c.detail<<" index="<<c.bad_element<<"\n";return 1;}
  std::vector<uint8_t> encoded;
  c=laya::encode_request(r,encoded);
  if(!c||encoded!=bytes){std::cerr<<"request re-encode mismatch\n";return 1;}
  if(r.batch!=2||r.seq_len!=128||bytes.size()!=1856){std::cerr<<"wrong fixture profile\n";return 1;}
  std::cout<<"ABI_OFFLINE_FIXTURE_PASS B="<<r.batch<<" S="<<r.seq_len<<" bytes="<<bytes.size()<<" production_eligible=0\n";
  if(argc==8){
    if(!check_q8(argv[2],32,256)||!check_q8(argv[3],82,256)||!check_q8(argv[4],8,2)){
      std::cerr<<"real Q8 scratch bitwise pack/unpack failed\n";return 1;
    }
    auto act_input=read_file(argv[5]);
    if(act_input.size()!=8224){std::cerr<<"act input1028 size\n";return 1;}
    for(unsigned batch=0;batch<2;batch++){
      laya::F32Beat b;b.task_id=1;b.epoch=1;b.row=batch;b.col=1024;b.valid_count=4;
      b.row_last=true;b.task_last=batch==1;
      for(unsigned lane=0;lane<4;lane++)b.data[lane]=laya::read_u32(act_input.data(),4*(batch*1028+1024+lane));
      laya::F32Beat unpacked;
      if(!laya::check_beat(b,1028,1)||!laya::unpack(laya::pack(b),unpacked)||unpacked.data!=b.data){
        std::cerr<<"real act 1028 tail failed\n";return 1;
      }
    }
    auto candidate=read_file(argv[6]),act=read_file(argv[7]);
    if(candidate.size()!=128||act.size()!=16){std::cerr<<"native logits size\n";return 1;}
    laya::Result result;result.status=laya::Status::OK;result.flags=3;result.request_id=r.request_id;
    result.generation=r.generation;result.identity=r.identity;result.batch=2;result.seq_len=128;
    for(unsigned i=0;i<32;i++)result.candidate_bits[i]=laya::read_u32(candidate.data(),4*i);
    for(unsigned i=0;i<4;i++)result.act_bits[i]=laya::read_u32(act.data(),4*i);
    std::array<uint8_t,laya::kResultBytes> frame{};laya::Result got;
    if(!laya::encode_result(result,frame)||!laya::decode_result({frame.begin(),frame.end()},got)||got.candidate_bits!=result.candidate_bits||got.act_bits!=result.act_bits){
      std::cerr<<"native logits result-format roundtrip failed\n";return 1;
    }
    std::cout<<"REAL_NATIVE_FORMAT_PASS q8=3 act_tail=2 candidate=32 act=4 numerical_forward=NOT_RUN\n";
  }
  return 0;
}
