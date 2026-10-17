#!/usr/bin/env python3
"""Literal v2 oracle and normal LPV prelude. No hierarchical owner setup."""
import argparse,struct,subprocess,sys
from pathlib import Path

def save(root,name,data):
    (root/(name+'.bin')).write_bytes(data)
    (root/(name+'.hex')).write_text(''.join(data[i:i+64][::-1].hex()+'\n' for i in range(0,len(data),64)))
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--host-fixture',type=Path,required=True);ap.add_argument('--output',type=Path,required=True)
    a=ap.parse_args();a.output.mkdir(exist_ok=False)
    subprocess.run([sys.executable,str(Path(__file__).with_name('bootstrap_snapshot_rtl_fixture.py')),'--host-fixture',str(a.host_fixture),'--output',str(a.output/'prelude')],check=True)
    source=(a.output/'prelude/snapshot.bin').read_bytes()
    ident=source[64:148];model=source[160:576];src=source[576:704]
    target=bytearray(src);struct.pack_into('<I',target,0,7);target[4]=2;struct.pack_into('<H',target,22,48)
    struct.pack_into('<Q',target,40,8388608);struct.pack_into('<Q',target,64,196608)
    def event(action,seq,d,task=0,row=0,origin=0):
        p=bytearray(1024);struct.pack_into('<IHHQ',p,0,0x3156504c,1,action,seq);struct.pack_into('<HH',p,24,16,8)
        p[64:148]=ident;p[160:576]=model;p[576]=1;p[608:736]=d
        if task:
            struct.pack_into('<I',p,16,task);struct.pack_into('<Q',p,32,seq if action==2 else origin)
            struct.pack_into('<IBBBBBHB',p,148,task,0x62,d[16],d[17],0,0,row,16)
            p[578]=1;struct.pack_into('<I',p,580,16384)
            struct.pack_into('<QIHHQQQBBB',p,864,struct.unpack_from('<Q',d,40)[0]+row*4096,4096,16,1,4096,0,65536,0,255,0)
            if action==3:
                p[42]=1;struct.pack_into('<I',p,44,16384);struct.pack_into('<Q',p,56,2**64-1);struct.pack_into('<Q',p,584,65536)
        return p
    save(a.output,'target_claim',event(1,100,target))
    for i in range(3):
        save(a.output,'target_begin'+str(i),event(2,101+i*2,target,i+1,i*16))
        save(a.output,'target_end'+str(i),event(3,102+i*2,target,i+1,i*16,101+i*2))
    save(a.output,'target_invalidate',event(6,107,target))
    save(a.output,'claim',event(1,108,src))
    for i in range(4):
        save(a.output,'begin'+str(i),event(2,109+i*2,src,i+4,i*16))
        save(a.output,'end'+str(i),event(3,110+i*2,src,i+4,i*16,109+i*2))
    save(a.output,'publish',event(4,117,src))
    bad=event(1,177,src);bad[576]=0;save(a.output,'trusted_bad',bad)
    q=bytearray(1024);q[:664]=source[:664];struct.pack_into('<IHH',q,0,0x3253424c,2,16)
    struct.pack_into('<H6B',q,672,1,2,0,0,6,0,0);struct.pack_into('<8Q',q,680,1,7,0x1200000000,16920576,8388608,262144,4096,4194304)
    save(a.output,'checkpoint',q)
    good=bytearray(q);struct.pack_into('<I',good,0,0x3252424c);struct.pack_into('<I',good,12,255);struct.pack_into('<Q',good,32,2**64-1)
    good[678]=2;struct.pack_into('<5I',good,744,15,15,7,1,7);struct.pack_into('<Q',good,768,177)
    save(a.output,'checkpoint_good',good)
    print('FULL_CURRENT_EXECUTOR_CHECKPOINT_RTL_FIXTURE_PASS tasks=7 lpv_floor=177 target_epoch=7')
if __name__=='__main__':main()
