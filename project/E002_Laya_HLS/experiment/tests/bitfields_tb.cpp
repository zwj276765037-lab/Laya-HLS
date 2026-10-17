#include "contract_test.h"
#include "laya_types.h"

// Byte-level oracle intentionally does not call the production bit get/put helpers.
static uint32_t le32(const uint8_t* p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
static uint16_t le16(const uint8_t* p){return uint16_t(p[0])|uint16_t(p[1])<<8;}
int main(){using namespace laya;
  F32Beat f{};for(unsigned i=0;i<8;i++)f.data[i]=0x01020304u+i*0x10101010u;
  f.task_id=0xdeadbeefu;f.epoch=0x12345678u;f.row=0xabcd;f.col=0x2468;f.valid_count=4;f.row_last=true;f.task_last=true;
  auto fb=pack(f);
  for(unsigned i=0;i<8;i++)test::require(le32(fb.data()+4*i)==f.data[i],"F32 independent data lane");
  test::require(le32(fb.data()+32)==f.task_id&&le32(fb.data()+36)==f.epoch,"F32 independent task/epoch");
  test::require(le16(fb.data()+40)==f.row&&le16(fb.data()+42)==f.col,"F32 independent row/col");
  test::require((fb[44]&15)==4&&((fb[44]>>4)&1)==1&&((fb[44]>>5)&1)==1&&(fb[44]&0xc0)==0,"F32 independent tail flags/pad");
  WiPairBeat w{};w.data=f.data;w.task_id=0x013579bdu;w.epoch=0x2468ace0u;w.row=9;w.col=2620;w.pair_count=4;w.row_last=w.task_last=true;
  auto wb=pack(w);
  for(unsigned i=0;i<8;i++)test::require(le32(wb.data()+4*i)==w.data[i],"WiPair independent U/G lanes");
  test::require(le32(wb.data()+32)==w.task_id&&le32(wb.data()+36)==w.epoch&&le16(wb.data()+40)==9&&le16(wb.data()+42)==2620,"WiPair independent meta");
  test::require((wb[44]&15)==4&&((wb[44]>>4)&1)&&((wb[44]>>5)&1)&&(wb[44]&0xc0)==0,"WiPair independent pair_count/last");
  Q8Group q{};for(unsigned i=0;i<32;i++)q.q[i]=int8_t(i-16);q.scale_bits=0x7bcd;q.task_id=0x87654321;q.epoch=0x12345678;q.row_local=0xd;q.group=0xa5;q.row_last=q.tile_last=true;
  auto qb=pack(q);
  for(unsigned i=0;i<32;i++)test::require(qb[i]==uint8_t(q.q[i]),"Q8 independent q bytes");
  test::require(le16(qb.data()+32)==q.scale_bits&&le32(qb.data()+34)==q.task_id&&le32(qb.data()+38)==q.epoch,"Q8 independent scale/task/epoch");
  unsigned group=((qb[42]>>4)&15)|((qb[43]&15)<<4);
  test::require((qb[42]&15)==13&&group==0xa5&&((qb[43]>>4)&1)&&((qb[43]>>5)&1)&&(qb[43]&0xc0)==0,"Q8 independent row/group/last/pad");
  f.task_id=UINT32_MAX;f.row=0;f.col=0;f.valid_count=8;f.row_last=f.task_last=true;
  test::require(!check_beat(f,8,0),"F32 task upper bound");
  w.task_id=UINT32_MAX;w.row=0;test::require(!check_beat(w,0),"WiPair task upper bound");
  q.task_id=UINT32_MAX;q.row_local=0;q.group=0;q.row_last=q.tile_last=false;
  test::require(!check_group(q,16,128),"Q8 task upper bound");
  q.task_id=1;test::require(!check_group(q,16,129),"Q8 group count bound");
}
