#include "attention_service.h"
#include "attention_exp_bits.h"

static float f32(uint32_t x) {
#pragma HLS inline
  union { uint32_t u; float f; } v; v.u=x; return v.f;
}
static uint32_t bits(float x) {
#pragma HLS inline
  union { uint32_t u; float f; } v; v.f=x; return v.u;
}
static bool finite(float x) {
#pragma HLS inline
  return (bits(x)&0x7f800000u)!=0x7f800000u;
}
float attention_mul(float a, float b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
  float value=a*b;
#pragma HLS bind_op variable=value op=fmul impl=maxdsp latency=6
  return value;
}
float attention_add(float a, float b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
  float value=a+b;
#pragma HLS bind_op variable=value op=fadd impl=fulldsp latency=11
  return value;
}
float attention_div(float a, float b) {
#pragma HLS inline off
#pragma HLS pipeline II=1
  return a/b;
}
void laya_attention_service(uint32_t command, uint32_t index,
                            uint32_t payload, uint32_t epoch,
                            uint32_t &result, uint32_t &status) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=command
#pragma HLS interface ap_none port=index
#pragma HLS interface ap_none port=payload
#pragma HLS interface ap_none port=epoch
#pragma HLS interface ap_vld port=result
#pragma HLS interface ap_vld port=status
#pragma HLS allocation function instances=attention_mul limit=1
#pragma HLS allocation function instances=attention_add limit=1
#pragma HLS allocation function instances=attention_div limit=1
  static float q[64],k[65536],v[65536],score[16384],prob[16384],ex[1024],tree[1024],y[64];
  static uint8_t row_phase[16];
  static uint8_t mask[1024];
  static uint32_t binding[55];
  static uint32_t bound_epoch=0,bind_count=0,nq=0,nk=0,nv=0,nmask=0,S=0,query=0,head=0;
  static uint32_t phase=0;
  static bool sliding=false;
  static float maximum=0,sum=0;
#pragma HLS reset variable=bound_epoch
#pragma HLS reset variable=bind_count
#pragma HLS reset variable=nq
#pragma HLS reset variable=nk
#pragma HLS reset variable=nv
#pragma HLS reset variable=nmask
#pragma HLS reset variable=S
#pragma HLS reset variable=phase
#pragma HLS bind_storage variable=k type=ram_1p impl=bram
#pragma HLS bind_storage variable=v type=ram_1p impl=bram
#pragma HLS bind_storage variable=score type=ram_1p impl=bram
#pragma HLS bind_storage variable=prob type=ram_1p impl=bram
#pragma HLS bind_storage variable=ex type=ram_1p impl=bram
#pragma HLS bind_storage variable=tree type=ram_2p impl=bram
#pragma HLS array_partition variable=tree cyclic factor=2 dim=1
#pragma HLS bind_storage variable=y type=ram_s2p impl=bram
  result=0; status=0;
  // No command overlaps another; RELEASE/RESET occurs after all FP returns.
  if (command==0 || command==16) {
    if (command==16 && epoch!=bound_epoch) { status=2; return; }
    bind_count=0;nq=0;nk=0;nv=0;nmask=0;S=0;phase=0;bound_epoch=epoch;
    for(unsigned row=0;row<16;++row)row_phase[row]=1;
    return;
  }
  if (epoch!=bound_epoch || !epoch) { status=2; return; }
  if (command==17) {
    if(index>=bind_count) {status=2;return;}
    result=binding[index];return;
  }
  if (command==1) {
    if (phase || index!=bind_count || index>=55) { status=2; return; }
    binding[index]=payload; ++bind_count; return;
  }
  if (command==2) {
    bool bad_ref=false;
    for(unsigned ref=0;ref<7;++ref)
      if(binding[35+ref*3] || !binding[34+ref*3])bad_ref=true;
    if (bind_count!=55 || (index!=64&&index!=128&&index!=256&&index!=512&&index!=1024) ||
        (payload&0xffffu)>=index || ((payload>>16)&255)>=16 || (payload>>25) ||
        ((binding[4]>>16)!=index) || ((binding[4]&0xffffu)!=1) ||
        phase>4 ||
        (payload&0xffffu)<(binding[23]&0xffffu) ||
        (payload&0xffffu)>=(binding[23]&0xffffu)+((binding[23]>>16)&255) ||
        (binding[23]!=binding[27]) || (binding[23]!=binding[31]) ||
        (binding[22]&255)!=0x50 || (binding[26]&255)!=0x51 || (binding[30]&255)!=0x52 ||
        (binding[22]>>8)!=(binding[26]>>8) || (binding[22]>>8)!=(binding[30]>>8) ||
        (((binding[22]>>8)&255)!=2 && ((binding[22]>>8)&255)!=4) ||
        ((binding[22]>>24)!=0) || binding[24]!=0 || binding[28]!=0 || binding[32]!=0 ||
        ((binding[23]>>16)&255)==0 || ((binding[23]>>16)&255)>16 ||
        binding[33]!=0x25 || binding[36]!=0x26 || binding[39]!=0x26 ||
        binding[42]!=0x28 || binding[45]!=8 || binding[48]!=5 || binding[51]!=0x105 ||
        binding[40]!=binding[37]+1 ||
        ((binding[54]&255)!=((payload>>16)&255)) ||
        (((binding[54]>>8)&1)!=((payload>>24)&1)) || bad_ref ||
        (((payload>>24)&1)!=((((binding[22]>>8)&255)==2 &&
                                ((binding[22]>>16)&255)%3!=0)?1u:0u))) {
      status=2; return;
    }
    // A new query may reuse immutable complete K/V/mask under this binding.
    S=index;query=payload&0xffffu;head=(payload>>16)&255;sliding=((payload>>24)&1)!=0;
    phase=row_phase[query-(binding[23]&0xffffu)];
    if(phase==1)nq=0;
    return;
  }
  if (command>=3 && command<=6) {
    if (phase!=1) { status=2;return; }
    if (command==3) {
      if (index!=nq || index>=64) { status=2;return; }
      if (!finite(f32(payload))) { status=1;phase=6;result=index;return; }
      q[index]=f32(payload);++nq;
    } else if (command==4 || command==5) {
      uint32_t &count=command==4?nk:nv;
      if (index!=count || index>=S*64) {status=2;return;}
      if (!finite(f32(payload))) {status=1;phase=6;result=index;return;}
      if(command==4) k[index]=f32(payload);else v[index]=f32(payload);
      ++count;
    } else {
      if(index!=nmask || index>=S || payload>1) {status=2;return;}
      mask[index]=uint8_t(payload);++nmask;
    }
    return;
  }
  unsigned row_local=query-(binding[23]&0xffffu),row_base=row_local*1024;
  if(command==7) {
    if(phase!=1||nq!=64||nk!=S*64||nv!=S*64||nmask!=S) {status=2;return;}
    for(unsigned key=0;key<S;++key) {
      unsigned bad_product=64;
      for(unsigned d=0;d<64;++d) {
#pragma HLS pipeline II=1
        tree[d]=attention_mul(q[d],k[key*64+d]);
        if(!finite(tree[d])&&d<bad_product)bad_product=d;
      }
      if(bad_product<64) {status=1;phase=6;result=key*64+bad_product;return;}
      for(unsigned width=64;width>1;width/=2) {
        unsigned bad_parent=width;
        for(unsigned i=0;i<width/2;++i) {
#pragma HLS pipeline II=1
          tree[i]=attention_add(tree[2*i],tree[2*i+1]);
          if(!finite(tree[i])&&i<bad_parent)bad_parent=i;
        }
        if(bad_parent<width) {status=1;phase=6;result=key*64+bad_parent;return;}
      }
      float scaled=attention_mul(tree[0],0.125f);
      if(!finite(scaled)) {status=1;phase=6;result=key;return;}
      float pad=attention_mul(attention_add(float(mask[key]),-1.0f),10000.0f);
      unsigned distance=query>key?query-key:key-query;
      float bias=sliding?attention_add(distance>64?-10000.0f:0.0f,pad):pad;
      float value=attention_add(scaled,bias);
      if(!finite(scaled)||!finite(pad)||!finite(bias)||!finite(value)) {status=1;phase=6;result=key;return;}
      score[row_base+key]=value;
    }
    phase=2;row_phase[row_local]=2;return;
  }
  if(command==8) {
    if(phase!=2) {status=2;return;}
    for(unsigned row=0;row<((binding[23]>>16)&255);++row)
      if(row_phase[row]<2) {status=2;return;}
    maximum=score[row_base];
    for(unsigned key=1;key<S;++key) if(score[row_base+key]>maximum) maximum=score[row_base+key];
    for(unsigned key=0;key<S;++key) {
      float z=attention_add(score[row_base+key],f32(bits(maximum)^0x80000000u));
      if(!finite(z)) {status=1;phase=6;result=key;return;}
      float e=f32(attention_exp_bits(bits(z)));
      if(!finite(e)) {status=1;phase=6;result=key;return;}
      ex[key]=e;tree[key]=e;
    }
    for(unsigned width=S;width>1;width/=2) {
      unsigned bad_parent=width;
      for(unsigned i=0;i<width/2;++i) {
#pragma HLS pipeline II=1
        tree[i]=attention_add(tree[2*i],tree[2*i+1]);
        if(!finite(tree[i])&&i<bad_parent)bad_parent=i;
      }
      if(bad_parent<width) {status=1;phase=6;result=bad_parent;return;}
    }
    sum=tree[0];
    if(!finite(sum)||sum<=0.0f) {status=1;phase=6;return;}
    unsigned bad_probability=S;
    for(unsigned key=0;key<S;++key) {
#pragma HLS pipeline II=1
      float p=attention_div(ex[key],sum);
      if(!finite(p)&&key<bad_probability)bad_probability=key;
      prob[row_base+key]=p;
    }
    if(bad_probability<S) {status=1;phase=6;result=bad_probability;return;}
    phase=3;row_phase[row_local]=3;return;
  }
  if(command==9) {
    if(phase!=3) {status=2;return;}
    for(unsigned row=0;row<((binding[23]>>16)&255);++row)
      if(row_phase[row]<3) {status=2;return;}
    for(unsigned d=0;d<64;++d) y[d]=0.0f;
    // Feature interleaving changes no per-feature key order. The 64 independent
    // addresses pay actual read/FADD/write feedback, not a presumed 11 cycles.
    unsigned first_rank=S*64,bad=0;
    for(unsigned key=0;key<S;++key) {
      for(unsigned d=0;d<64;++d) {
#pragma HLS pipeline II=1
        float p=attention_mul(prob[row_base+key],v[key*64+d]);
        float acc=attention_add(y[d],p);
        if((!finite(p)||!finite(acc)) && d*S+key<first_rank) {
          first_rank=d*S+key;bad=key*64+d;
        }
        y[d]=acc;
      }
    }
    if(first_rank<S*64) {status=1;phase=6;result=bad;return;}
    phase=4;row_phase[row_local]=4;return;
  }
  if(command==10&&phase>=2&&phase<=4&&index<S) {result=bits(score[row_base+index]);return;}
  if(command==11&&phase>=3&&phase<=4&&index<S) {result=bits(prob[row_base+index]);return;}
  if(command==12&&phase==4&&index<64) {result=bits(y[index]);return;}
  if(command==13&&phase>=3&&phase<=4) {result=bits(maximum);return;}
  if(command==14&&phase>=3&&phase<=4&&index<S) {result=bits(ex[index]);return;}
  if(command==15&&phase>=3&&phase<=4) {result=bits(sum);return;}
  status=2;
}
