#include "laya_tm4_group_service.h"
#include "laya_numeric.h"

void laya_tm4_group_service(
  uint64_t owner0,
  uint64_t owner1,
  uint64_t owner2,
  uint64_t owner3,
  uint64_t owner4,
  uint64_t owner5,
  uint64_t owner6,
  uint64_t owner7,
  uint64_t owner8,
  uint64_t owner9,
  uint64_t owner10,
  uint64_t owner11,
  uint64_t owner12,
  uint64_t owner13,
  uint64_t owner14,
  uint64_t owner15,
  uint64_t aq0,
  uint64_t aq1,
  uint64_t aq2,
  uint64_t aq3,
  uint64_t aq4,
  uint64_t aq5,
  uint64_t aq6,
  uint64_t aq7,
  uint64_t aq8,
  uint64_t aq9,
  uint64_t aq10,
  uint64_t aq11,
  uint64_t aq12,
  uint64_t aq13,
  uint64_t aq14,
  uint64_t aq15,
  uint64_t wq0,
  uint64_t wq1,
  uint64_t wq2,
  uint64_t wq3,
  uint64_t wq4,
  uint64_t wq5,
  uint64_t wq6,
  uint64_t wq7,
  uint64_t wq8,
  uint64_t wq9,
  uint64_t wq10,
  uint64_t wq11,
  uint64_t wq12,
  uint64_t wq13,
  uint64_t wq14,
  uint64_t wq15,
  uint64_t wq16,
  uint64_t wq17,
  uint64_t wq18,
  uint64_t wq19,
  uint64_t wq20,
  uint64_t wq21,
  uint64_t wq22,
  uint64_t wq23,
  uint64_t wq24,
  uint64_t wq25,
  uint64_t wq26,
  uint64_t wq27,
  uint64_t wq28,
  uint64_t wq29,
  uint64_t wq30,
  uint64_t wq31,
  uint32_t sa0,
  uint32_t sa1,
  uint32_t sa2,
  uint32_t sa3,
  uint32_t sw0,
  uint32_t sw1,
  uint32_t sw2,
  uint32_t sw3,
  uint32_t sw4,
  uint32_t sw5,
  uint32_t sw6,
  uint32_t sw7,
  uint32_t old0,
  uint32_t old1,
  uint32_t old2,
  uint32_t old3,
  uint32_t old4,
  uint32_t old5,
  uint32_t old6,
  uint32_t old7,
  uint32_t old8,
  uint32_t old9,
  uint32_t old10,
  uint32_t old11,
  uint32_t old12,
  uint32_t old13,
  uint32_t old14,
  uint32_t old15,
  uint32_t old16,
  uint32_t old17,
  uint32_t old18,
  uint32_t old19,
  uint32_t old20,
  uint32_t old21,
  uint32_t old22,
  uint32_t old23,
  uint32_t old24,
  uint32_t old25,
  uint32_t old26,
  uint32_t old27,
  uint32_t old28,
  uint32_t old29,
  uint32_t old30,
  uint32_t old31,
  uint32_t lane_masks,
  uint32_t group,
  uint32_t tile,
  uint32_t sequence,
  uint64_t &echo0,
  uint64_t &echo1,
  uint64_t &echo2,
  uint64_t &echo3,
  uint64_t &echo4,
  uint64_t &echo5,
  uint64_t &echo6,
  uint64_t &echo7,
  uint64_t &echo8,
  uint64_t &echo9,
  uint64_t &echo10,
  uint64_t &echo11,
  uint64_t &echo12,
  uint64_t &echo13,
  uint64_t &echo14,
  uint64_t &echo15,
  uint32_t &next0,
  uint32_t &next1,
  uint32_t &next2,
  uint32_t &next3,
  uint32_t &next4,
  uint32_t &next5,
  uint32_t &next6,
  uint32_t &next7,
  uint32_t &next8,
  uint32_t &next9,
  uint32_t &next10,
  uint32_t &next11,
  uint32_t &next12,
  uint32_t &next13,
  uint32_t &next14,
  uint32_t &next15,
  uint32_t &next16,
  uint32_t &next17,
  uint32_t &next18,
  uint32_t &next19,
  uint32_t &next20,
  uint32_t &next21,
  uint32_t &next22,
  uint32_t &next23,
  uint32_t &next24,
  uint32_t &next25,
  uint32_t &next26,
  uint32_t &next27,
  uint32_t &next28,
  uint32_t &next29,
  uint32_t &next30,
  uint32_t &next31,
  uint32_t &bad0,
  uint32_t &bad1,
  uint32_t &bad2,
  uint32_t &bad3,
  uint32_t &phases0,
  uint32_t &phases1,
  uint32_t &phases2,
  uint32_t &phases3,
  uint32_t &status) {
#pragma HLS inline off
  echo0=owner0;echo1=owner1;echo2=owner2;echo3=owner3;echo4=owner4;echo5=owner5;echo6=owner6;echo7=owner7;echo8=owner8;echo9=owner9;echo10=owner10;echo11=owner11;echo12=owner12;echo13=owner13;echo14=owner14;echo15=owner15;
  const uint64_t a[16]={aq0,aq1,aq2,aq3,aq4,aq5,aq6,aq7,aq8,aq9,aq10,aq11,aq12,aq13,aq14,aq15},w[32]={wq0,wq1,wq2,wq3,wq4,wq5,wq6,wq7,wq8,wq9,wq10,wq11,wq12,wq13,wq14,wq15,wq16,wq17,wq18,wq19,wq20,wq21,wq22,wq23,wq24,wq25,wq26,wq27,wq28,wq29,wq30,wq31};
  const uint32_t scales_a[4]={sa0,sa1,sa2,sa3},scales_w[8]={sw0,sw1,sw2,sw3,sw4,sw5,sw6,sw7},old_bits[32]={old0,old1,old2,old3,old4,old5,old6,old7,old8,old9,old10,old11,old12,old13,old14,old15,old16,old17,old18,old19,old20,old21,old22,old23,old24,old25,old26,old27,old28,old29,old30,old31};
  uint32_t next_bits[32],bad_mask[4]={},phase_bits[4]={};
  status=0;
  if(group>127 || tile>655 || sequence>0x7ffffffu)status=2;
  for(unsigned r=0;r<4;++r)for(unsigned n=0;n<8;++n) {
    const unsigned index=r*8+n;
    next_bits[index]=old_bits[index];
    unsigned phase=4;
    if(!status && ((lane_masks>>(r*8+n))&1u)) {
      int32_t tree[32];
      for(unsigned k=0;k<32;++k)
        tree[k]=int32_t(int8_t(a[r*4+k/8]>>(8*(k%8))))*
                int32_t(int8_t(w[n*4+k/8]>>(8*(k%8))));
      for(unsigned count=32;count>1;count/=2)
        for(unsigned k=0;k<count/2;++k)tree[k]=tree[2*k]+tree[2*k+1];
      const float sa=laya::numeric_bits_f32(scales_a[r]),sw=laya::numeric_bits_f32(scales_w[n]);
      const auto finite=[](float f){return (laya::numeric_f32_bits(f)&0x7f800000u)!=0x7f800000u;};
      const float product=sa*sw;
      float term=product*float(tree[0]);
      if(!finite(sa)||!finite(sw)||sa<0||sw<0)phase=0;
      else if(!finite(product))phase=1;
      else if(!finite(term))phase=2;
      float prior=laya::numeric_bits_f32(old_bits[index]);
      if(phase!=4){term=0.0f;prior=0.0f;}
      const float result=term+prior;
      next_bits[index]=laya::numeric_f32_bits(result);
      if(phase==4&&!finite(result))phase=3;
      if(phase!=4)bad_mask[r]|=1u<<n;
    }
    phase_bits[r]|=phase<<(n*3);
  }
  if(!status && (bad_mask[0]|bad_mask[1]|bad_mask[2]|bad_mask[3]))status=1;
  next0=next_bits[0];
  next1=next_bits[1];
  next2=next_bits[2];
  next3=next_bits[3];
  next4=next_bits[4];
  next5=next_bits[5];
  next6=next_bits[6];
  next7=next_bits[7];
  next8=next_bits[8];
  next9=next_bits[9];
  next10=next_bits[10];
  next11=next_bits[11];
  next12=next_bits[12];
  next13=next_bits[13];
  next14=next_bits[14];
  next15=next_bits[15];
  next16=next_bits[16];
  next17=next_bits[17];
  next18=next_bits[18];
  next19=next_bits[19];
  next20=next_bits[20];
  next21=next_bits[21];
  next22=next_bits[22];
  next23=next_bits[23];
  next24=next_bits[24];
  next25=next_bits[25];
  next26=next_bits[26];
  next27=next_bits[27];
  next28=next_bits[28];
  next29=next_bits[29];
  next30=next_bits[30];
  next31=next_bits[31];
  bad0=bad_mask[0];phases0=phase_bits[0];
  bad1=bad_mask[1];phases1=phase_bits[1];
  bad2=bad_mask[2];phases2=phase_bits[2];
  bad3=bad_mask[3];phases3=phase_bits[3];
}
