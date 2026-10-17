#include "attention_tile_service.h"
#include <array>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

std::vector<uint32_t> load(const std::string& dir,const std::string& name,size_t count) {
 std::ifstream in(dir+"/"+name+".mem");std::vector<uint32_t> out;uint32_t v;
 while(in>>std::hex>>v)out.push_back(v);
 if(out.size()!=count)throw std::runtime_error("Frozen fixture size "+name);
 return out;
}
uint64_t calls=0,checks=0;
uint32_t call(uint32_t cmd,uint32_t ix,uint32_t data,uint32_t ep,uint32_t expected=0) {
 uint32_t value=0,status=0;laya_attention_tile_service(cmd,ix,data,ep,value,status);++calls;
 if(status!=expected)throw std::runtime_error("Tile status cmd="+std::to_string(cmd)+" got="+std::to_string(status));return value;
}
void eq(uint32_t got,uint32_t gold,const char* kind,unsigned element) {
 ++checks;if(got!=gold){std::cerr<<"ATTENTION_TILE_CPU_DIFF "<<kind<<" index="<<std::dec<<element<<" got="<<std::hex<<got<<" gold="<<gold<<"\n";throw std::runtime_error("Independent bit comparison");}
}
int main(int argc,char** argv)try {
 if(argc!=2)throw std::runtime_error("fixture argument required");const std::string f=argv[1];
 const auto q=load(f,"q",8192),k=load(f,"k",8192),v=load(f,"v",8192),mask=load(f,"mask",128),id=load(f,"identity_words",21);
 const auto score=load(f,"score",16384),ex=load(f,"exp",16384),prob=load(f,"prob",16384),out=load(f,"out",8192),maximum=load(f,"maximum",128),sum=load(f,"sum",128);
 for(unsigned first=0;first<128;first+=16) {
  uint32_t ep=first/16+1;std::array<uint32_t,55> words{};call(0,0,0,ep);
  for(unsigned i=0;i<21;++i)words[i]=id[i];
  for(unsigned i=0;i<3;++i){words[21+4*i]=100+i;words[22+4*i]=0x250+i;words[23+4*i]=(16<<16)|first;}
  for(unsigned i=0;i<7;++i){words[33+3*i]=i==0?0x25:(i==3?0x28:(i==4?8:(i==5?5:(i==6?0x105:0x26))));words[34+3*i]=i==2?2:1;}
  for(unsigned i=0;i<55;++i)call(1,i,words[i],ep);
  for(unsigned i=0;i<55;++i)eq(call(17,i,0,ep),words[i],"binding",i);
  call(2,128,first|(1<<16),ep,2);call(2,128,first,ep);
  call(19,0,0,ep,2);
  for(unsigned i=0;i<8192;++i){call(4,i,k[i],ep);call(5,i,v[i],ep);}
  for(unsigned i=0;i<128;++i)call(6,i,mask[i],ep);
  for(unsigned i=0;i<1024;++i)call(18,i,q[first*64+i],ep);
  call(18,1024,0,ep,2);call(19,0,0,ep);
  for(unsigned r=first;r<first+16;++r){call(2,128,r,ep);for(unsigned key=0;key<128;++key)eq(call(10,key,0,ep),score[r*128+key],"score",r*128+key);}
  call(20,0,0,ep);
  for(unsigned r=first;r<first+16;++r){call(2,128,r,ep);
   if(r-first>=8){eq(call(13,0,0,ep),maximum[r],"max",r);eq(call(15,0,0,ep),sum[r],"sum",r);}
   else {call(13,0,0,ep,2);call(14,0,0,ep,2);call(15,0,0,ep,2);}
   for(unsigned key=0;key<128;++key){eq(call(11,key,0,ep),prob[r*128+key],"prob",r*128+key);if(r-first>=8)eq(call(14,key,0,ep),ex[r*128+key],"exp",r*128+key);}
  }
  call(21,0,0,ep);
  for(unsigned r=first;r<first+16;++r){call(2,128,r,ep);for(unsigned d=0;d<64;++d)eq(call(12,d,0,ep),out[r*64+d],"Y",r*64+d);}
  call(16,0,0,ep);call(12,0,0,ep,2);
 }
 // At key 5, finite max-normal products at d6/d7 overflow the first
 // adjacent-pair addition at parent 3. The original qk_row contract reports
 // key*64+parent, independently of the tile implementation's tree storage.
 {
  const uint32_t ep=9001;std::array<uint32_t,55> words{};call(0,0,0,ep);
  for(unsigned i=0;i<21;++i)words[i]=id[i];
  for(unsigned i=0;i<3;++i){words[21+4*i]=100+i;words[22+4*i]=0x250+i;words[23+4*i]=1<<16;}
  for(unsigned i=0;i<7;++i){words[33+3*i]=i==0?0x25:(i==3?0x28:(i==4?8:(i==5?5:(i==6?0x105:0x26))));words[34+3*i]=i==2?2:1;}
  for(unsigned i=0;i<55;++i)call(1,i,words[i],ep);call(2,128,0,ep);
  for(unsigned i=0;i<8192;++i){call(4,i,(i==5*64+6||i==5*64+7)?0x7f7fffffu:0,ep);call(5,i,0,ep);}
  for(unsigned i=0;i<128;++i)call(6,i,1,ep);
  for(unsigned i=0;i<64;++i)call(18,i,0x3f800000u,ep);
  eq(call(19,0,0,ep,1),5*64+3,"QK tree first-error",5*64+3);
  call(10,0,0,ep,2);call(16,0,0,ep);
  std::cout<<"ATTENTION_SERVICE_TILE_CPU_QK_TREE_ERROR_PASS key=5 parent=3 bad_element=323\n";
 }
 for(unsigned kind=0;kind<6;++kind) {
  const uint32_t ep=9100+kind,count=kind==4?16:2,expected=kind==0?323:(kind==3?7:(kind==5?4095:63));
  std::array<uint32_t,55> words{};call(0,0,0,ep);
  for(unsigned i=0;i<21;++i)words[i]=id[i];words[4]=(64<<16)|1;
  for(unsigned i=0;i<3;++i){words[21+4*i]=100+i;words[22+4*i]=0x250+i;words[23+4*i]=count<<16;}
  for(unsigned i=0;i<7;++i){words[33+3*i]=i==0?0x25:(i==3?0x28:(i==4?8:(i==5?5:(i==6?0x105:0x26))));words[34+3*i]=i==2?2:1;}
  for(unsigned i=0;i<55;++i)call(1,i,words[i],ep);call(2,64,0,ep);
  for(unsigned i=0;i<4096;++i){uint32_t kb=kind==5?(i==4095?0x7f7fffffu:0):((i==326||i==327)?0x7f7fffffu:0);call(4,i,kb,ep);call(5,i,0,ep);}
  for(unsigned i=0;i<64;++i)call(6,i,1,ep);
  for(unsigned i=0;i<count*64;++i) {
   uint32_t qb=kind==4||(kind==1&&i<64)?0:0x3f800000u;
   if(((kind==0||kind==5)&&i==127)||((kind==1||kind==2)&&i==63)||(kind==3&&(i==7||i==63||i==64))||(kind==4&&i==1023))qb=kind==4?0x7f800000u:0x7fc00000u;
   if(kind==5&&i==63)qb=0x40000000u;
   call(18,i,qb,ep);
  }
  eq(call(19,0,0,ep,1),expected,"ordered QK first-error",kind);
  call(10,0,0,ep,2);call(20,0,0,ep,2);call(16,0,0,ep);
  std::cout<<"ATTENTION_SERVICE_TILE_CPU_FIRST_ERROR_CASE_PASS kind="<<kind<<" bad_element="<<expected<<"\n";
 }
 std::cout<<"ATTENTION_SERVICE_TILE_CPU_PASS rows128 keys128 D64 all_tiles8 calls="<<calls<<" independent_checks="<<checks<<"\n";
 return 0;
}catch(const std::exception& e){std::cerr<<"ATTENTION_SERVICE_TILE_CPU_FAIL "<<e.what()<<"\n";return 1;}
