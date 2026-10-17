#include "attention_tile_service.h"
#include "attention_exp_bits.h"

namespace {
float f32(uint32_t x) { union {uint32_t u;float f;} v;v.u=x;return v.f; }
uint32_t bits(float x) { union {uint32_t u;float f;} v;v.f=x;return v.u; }
bool finite(float x) {return (bits(x)&0x7f800000u)!=0x7f800000u;}
float mul(float a,float b) {volatile float r=a*b;return r;}
float add(float a,float b) {volatile float r=a+b;return r;}
float div(float a,float b) {volatile float r=a/b;return r;}
}

// Behavioral model only: physical banking and shared arithmetic are provided
// by attention_tile_service_v1.sv and charged by its matching OOC receipt.
void laya_attention_tile_service(uint32_t command,uint32_t index,
 uint32_t payload,uint32_t epoch,uint32_t &result,uint32_t &status) {
 static float q[1024],k[65536],v[65536],score[16384],prob[16384],y[1024];
 static float ex[8][1024],tree[1024],maximum[16],sum[16];
 static uint8_t mask[1024],scratch_row[8];static bool scratch_valid[8];
 static uint32_t binding[55],bound_epoch=0,bind_count=0,S=0,query=0,row0=0,rows=0,head=0;
 static uint32_t phase=0,nq=0,nk=0,nv=0,nmask=0;static bool sliding=false;
 result=0;status=0;
 if(command==0||command==16) {
  if(command==16&&epoch!=bound_epoch){status=2;return;}
  bound_epoch=epoch;bind_count=0;phase=0;S=0;nq=0;nk=0;nv=0;nmask=0;
  for(unsigned i=0;i<8;++i)scratch_valid[i]=false;
  return;
 }
 if(epoch!=bound_epoch||epoch==0){status=2;return;}
 if(command==1) {
  if(phase!=0||index!=bind_count||index>=55){status=2;return;}
  binding[index]=payload;++bind_count;return;
 }
 if(command==17) {if(index>=bind_count){status=2;return;}result=binding[index];return;}
 if(command==2) {
  bool bad=bind_count!=55||(index!=64&&index!=128&&index!=256&&index!=512&&index!=1024)||
   (payload&0xffffu)>=index||((payload>>16)&255u)>=16||(payload>>25)||
   (binding[4]>>16)!=index||(binding[4]&0xffffu)!=1||phase==6||
   (payload&0xffffu)<(binding[23]&0xffffu)||
   (payload&0xffffu)>=(binding[23]&0xffffu)+((binding[23]>>16)&255u)||
   binding[23]!=binding[27]||binding[23]!=binding[31]||
   (binding[22]&255u)!=0x50||(binding[26]&255u)!=0x51||(binding[30]&255u)!=0x52||
   (binding[22]>>8)!=(binding[26]>>8)||(binding[22]>>8)!=(binding[30]>>8)||
   (((binding[22]>>8)&255u)!=2&&((binding[22]>>8)&255u)!=4)||
   (binding[22]>>24)||binding[24]||binding[28]||binding[32]||
   ((binding[23]>>16)&255u)==0||((binding[23]>>16)&255u)>16||
   (binding[23]&0xffffu)+((binding[23]>>16)&255u)>index||
   binding[33]!=0x25||binding[36]!=0x26||binding[39]!=0x26||binding[42]!=0x28||
   binding[45]!=8||binding[48]!=5||binding[51]!=0x105||binding[40]!=binding[37]+1||
   (binding[54]&255u)!=((payload>>16)&255u)||((binding[54]>>8)&1u)!=((payload>>24)&1u)||
   ((payload>>24)&1u)!=((((binding[22]>>8)&255u)==2&&((binding[22]>>16)&255u)%3!=0)?1u:0u);
  for(unsigned i=0;i<7;++i)if(binding[35+3*i]||binding[34+3*i]==0)bad=true;
  if(bad){status=2;return;}
  S=index;query=payload&0xffffu;row0=binding[23]&0xffffu;rows=(binding[23]>>16)&255u;
  head=(payload>>16)&255u;sliding=((payload>>24)&1u)!=0;if(phase==0)phase=1;return;
 }
 if(command==4||command==5||command==6||command==18) {
  if(phase!=1){status=2;return;}
  if(command==6) {
   if(index!=nmask||index>=S||payload>1){status=2;return;}
   mask[index]=uint8_t(payload);++nmask;return;
  }
  uint32_t &count=command==18?nq:(command==4?nk:nv);
  if(index!=count||index>=(command==18?rows*64:S*64)){status=2;return;}
  if(!finite(f32(payload))){status=1;result=index;phase=6;return;}
  if(command==18)q[index]=f32(payload);else if(command==4)k[index]=f32(payload);else v[index]=f32(payload);
  ++count;return;
 }
 if(command>=19&&command<=21&&(index||payload)){status=2;return;}
 if(command==19) {
  if(phase!=1||nq!=rows*64||nk!=S*64||nv!=S*64||nmask!=S){status=2;return;}
  for(unsigned r=0;r<rows;++r)for(unsigned key=0;key<S;++key) {
   for(unsigned d=0;d<64;++d){tree[d]=mul(q[r*64+d],k[key*64+d]);if(!finite(tree[d])){status=1;result=key*64+d;phase=6;return;}}
   for(unsigned width=64;width>1;width/=2)for(unsigned i=0;i<width/2;++i){tree[i]=add(tree[2*i],tree[2*i+1]);if(!finite(tree[i])){status=1;result=key*64+i;phase=6;return;}}
   float scaled=mul(tree[0],0.125f);if(!finite(scaled)){status=1;result=key;phase=6;return;}
   float pad=add(mask[key]?1.0f:0.0f,-1.0f);if(!finite(pad)){status=1;result=key;phase=6;return;}
   pad=mul(pad,10000.0f);if(!finite(pad)){status=1;result=key;phase=6;return;}
   if(sliding){unsigned qr=row0+r;unsigned distance=qr>key?qr-key:key-qr;pad=add(distance>64?-10000.0f:0.0f,pad);if(!finite(pad)){status=1;result=key;phase=6;return;}}
   score[r*1024+key]=add(scaled,pad);if(!finite(score[r*1024+key])){status=1;result=key;phase=6;return;}
  }
  phase=2;return;
 }
 if(command==20) {
  if(phase!=2){status=2;return;}
  for(unsigned r=0;r<rows;++r) {
   unsigned slot=r%8;scratch_valid[slot]=true;scratch_row[slot]=uint8_t(r);maximum[r]=f32(0xff7fffff);
   for(unsigned key=0;key<S;++key){float x=score[r*1024+key];if(!finite(x)){status=1;result=key;phase=6;return;}if(x>maximum[r])maximum[r]=x;}
   for(unsigned key=0;key<S;++key){float shifted=add(score[r*1024+key],f32(bits(maximum[r])^0x80000000u));if(!finite(shifted)){status=1;result=key;phase=6;return;}ex[slot][key]=f32(attention_exp_bits(bits(shifted)));if(!finite(ex[slot][key])){status=1;result=key;phase=6;return;}tree[key]=ex[slot][key];}
   for(unsigned width=S;width>1;width/=2)for(unsigned i=0;i<width/2;++i){tree[i]=add(tree[2*i],tree[2*i+1]);if(!finite(tree[i])){status=1;result=i;phase=6;return;}}
   sum[r]=tree[0];if(!finite(sum[r])||!(sum[r]>0.0f)){status=1;phase=6;return;}
   for(unsigned key=0;key<S;++key){prob[r*1024+key]=div(ex[slot][key],sum[r]);if(!finite(prob[r*1024+key])){status=1;result=key;phase=6;return;}}
  }
  phase=3;return;
 }
 if(command==21) {
  if(phase!=3){status=2;return;}
  for(unsigned r=0;r<rows;++r)for(unsigned d=0;d<64;++d){float acc=0.0f;for(unsigned key=0;key<S;++key){float product=mul(prob[r*1024+key],v[key*64+d]);if(!finite(product)){status=1;result=key*64+d;phase=6;return;}acc=add(acc,product);if(!finite(acc)){status=1;result=key*64+d;phase=6;return;}}y[r*64+d]=acc;}
  phase=4;return;
 }
 unsigned r=query-row0;
 if(command==10&&phase>=2&&phase<=4&&index<S){result=bits(score[r*1024+index]);return;}
 if(command==11&&phase>=3&&phase<=4&&index<S){result=bits(prob[r*1024+index]);return;}
 if(command==12&&phase==4&&index<64){result=bits(y[r*64+index]);return;}
 if((command==13||command==14||command==15)&&phase>=3&&phase<=4&&scratch_valid[r%8]&&scratch_row[r%8]==r) {
  if(command==13){result=bits(maximum[r]);return;}if(command==15){result=bits(sum[r]);return;}if(index<S){result=bits(ex[r%8][index]);return;}
 }
 status=2;(void)head;
}
