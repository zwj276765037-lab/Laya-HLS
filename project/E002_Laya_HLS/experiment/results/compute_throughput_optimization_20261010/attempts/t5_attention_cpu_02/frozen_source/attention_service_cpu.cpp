#include "attention_service.h"
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>
static std::vector<uint32_t> read(std::string p){std::ifstream f(p,std::ios::binary);if(!f)std::exit(2);std::vector<uint32_t>v;uint32_t x;while(f.read((char*)&x,4))v.push_back(x);return v;}
static uint32_t call(unsigned cmd,unsigned idx,unsigned data,unsigned epoch,unsigned expected=0){uint32_t r,s;laya_attention_service(cmd,idx,data,epoch,r,s);if(s!=expected){std::printf("FAIL command%u index%u status%u expected%u\n",cmd,idx,s,expected);std::exit(1);}return r;}
static void check(const char *phase,unsigned i,uint32_t got,uint32_t gold){if(got!=gold){std::printf("FAIL %s index%u got%08x gold%08x\n",phase,i,got,gold);std::exit(1);}}
int main(int argc,char**argv){
 if(argc!=2)return 2;std::string p=argv[1];
 auto q=read(p+"/q.bin"),k=read(p+"/k.bin"),v=read(p+"/v.bin"),score=read(p+"/score.bin"),ex=read(p+"/exp.bin"),prob=read(p+"/prob.bin"),y=read(p+"/out.bin"),mx=read(p+"/maximum.bin"),sum=read(p+"/sum.bin");
 std::ifstream mf(p+"/mask.mem"),idf(p+"/identity_words.mem");uint32_t mask[128],id[21];for(auto&x:mask)mf>>std::hex>>x;for(auto&x:id)idf>>std::hex>>x;
 unsigned epoch=0;
 for(unsigned tile=0;tile<8;++tile){
  ++epoch;call(0,0,0,epoch);uint32_t bind[55]={};for(unsigned i=0;i<21;++i)bind[i]=id[i];
  for(unsigned j=0;j<3;++j){unsigned i=21+j*4;bind[i]=100+j+tile*3;bind[i+1]=0x200+(0x50+j);bind[i+2]=(16<<16)+tile*16;bind[i+3]=0;}
  for(unsigned j=0;j<7;++j){bind[33+j*3]=j==0?0x25:(j==3?0x28:(j==4?8:(j==5?5:(j==6?0x105:0x26))));bind[34+j*3]=j==2?2:1;}
  for(unsigned i=0;i<55;++i)call(1,i,bind[i],epoch);
  for(unsigned i=0;i<55;++i)check("full binding",i,call(17,i,0,epoch),bind[i]);
  call(2,128,tile*16,epoch);call(7,0,0,epoch,2); // No fake READY before full loading.
  for(unsigned i=0;i<8192;++i){call(4,i,k[i],epoch);call(5,i,v[i],epoch);}
  for(unsigned i=0;i<128;++i)call(6,i,mask[i],epoch);
  for(unsigned row=tile*16;row<tile*16+16;++row){
   if(row!=tile*16)call(2,128,row,epoch);
   call(3,0,0,epoch+100,2); // Wrong epoch cannot change coverage/data.
   for(unsigned d=0;d<64;++d)call(3,d,q[row*64+d],epoch);
   call(7,0,0,epoch);
   for(unsigned key=0;key<128;++key)check("score",row*128+key,call(10,key,0,epoch),score[row*128+key]);
  }
  for(unsigned row=tile*16;row<tile*16+16;++row){
   call(2,128,row,epoch);
   call(8,0,0,epoch);check("max",row,call(13,0,0,epoch),mx[row]);check("sum",row,call(15,0,0,epoch),sum[row]);
   for(unsigned key=0;key<128;++key){check("exp",row*128+key,call(14,key,0,epoch),ex[row*128+key]);check("prob",row*128+key,call(11,key,0,epoch),prob[row*128+key]);}
  }
  for(unsigned row=tile*16;row<tile*16+16;++row){
   call(2,128,row,epoch);
   call(9,0,0,epoch);for(unsigned d=0;d<64;++d)check("out",row*64+d,call(12,d,0,epoch),y[row*64+d]);
  }
  call(16,0,0,epoch);call(12,0,0,epoch,2);
  std::printf("ATTENTION_SERVICE_PROGRESS rows=%u\n",(tile+1)*16);std::fflush(stdout);
 }
 std::puts("ATTENTION_SERVICE_CPU_PASS rows128 keys128 D64 score_exp_prob_out_exact");
}
