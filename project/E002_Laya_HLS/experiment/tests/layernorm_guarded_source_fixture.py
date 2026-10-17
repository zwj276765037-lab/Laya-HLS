#!/usr/bin/env python3
"""Independent finite guarded-LN diagnostic, with a normal four-window prelude."""
import argparse
import json
from pathlib import Path
import struct
import subprocess
import sys


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--host-fixture',type=Path,required=True)
    p.add_argument('--prelude-generator',type=Path,required=True)
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--gold',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--rows',type=int,choices=(1,),default=1)
    a=p.parse_args()
    subprocess.run([sys.executable,str(a.prelude_generator),'--host-fixture',str(a.host_fixture),'--output',str(a.out)],check=True,timeout=120)
    q=(a.out/'snapshot.bin').read_bytes()
    def save(name,b):
        (a.out/(name+'.bin')).write_bytes(b)
        (a.out/(name+'.hex')).write_text(''.join(b[i:i+64][::-1].hex()+'\n' for i in range(0,len(b),64)))
    claim=bytearray((a.out/'claim.bin').read_bytes())
    struct.pack_into('<Q',claim,8,12)
    claim[612]=2;claim[625]=1
    struct.pack_into('<Q',claim,648,8388608)
    save('target_claim',claim)
    begin=bytearray((a.out/'begin0.bin').read_bytes())
    struct.pack_into('<Q',begin,8,13);struct.pack_into('<I',begin,16,5)
    struct.pack_into('<HHQ',begin,24,16,8,0)
    struct.pack_into('<Q',begin,32,13)
    begin[608:736]=claim[608:736]
    struct.pack_into('<IBBBBBHB',begin,148,5,0x11,2,1,0,0,0,1)
    struct.pack_into('<I',begin,580,1024)
    struct.pack_into('<QIHHQQQBBB',begin,864,8388608,4096,1,1,0,0,4096,0,255,0)
    save('target_begin',begin)
    end=bytearray(begin)
    struct.pack_into('<H',end,6,3);struct.pack_into('<Q',end,8,16)
    # Status/unit/elements/detail/bad/issued are filled from actual LPC1 by TB.
    save('target_end_template',end)
    wrong_end=bytearray(end)
    struct.pack_into('<Q',wrong_end,8,15)
    struct.pack_into('<I',wrong_end,16,999)
    struct.pack_into('<I',wrong_end,148,999)
    struct.pack_into('<H',wrong_end,40,7)
    struct.pack_into('<I',wrong_end,48,0x04000017)
    struct.pack_into('<Q',wrong_end,56,(1<<64)-1)
    struct.pack_into('<Q',wrong_end,584,4096)
    save('wrong_end_active',wrong_end)
    invalid=bytearray(claim);struct.pack_into('<H',invalid,6,6);struct.pack_into('<Q',invalid,8,17)
    save('target_invalidate',invalid)
    for name,sequence in [('source_conflict_before',11),('source_conflict_live',14),('source_invalidate',18)]:
        b=bytearray((a.out/'invalidate.bin').read_bytes());struct.pack_into('<Q',b,8,sequence);save(name,b)
    r=bytearray(1024)
    struct.pack_into('<IHHHHH',r,0,0x3145504c,1,16,1,0,8)
    struct.pack_into('<QQ',r,16,1,13)
    r[64:148]=q[64:148];r[148:160]=begin[148:160];r[160:576]=q[160:576]
    r[576:584]=q[576:584];r[584:592]=claim[608:616]
    struct.pack_into('<H',r,592,1024);r[597:599]=bytes([6,6])
    struct.pack_into('<II6QI',r,600,0x3727c5ac,4096,0,8388608,4096,4096,16920576,16920576,1024)
    r[660]=1;save('producer_request',r)
    action=bytearray(512)
    struct.pack_into('<IHH',action,0,0x3158414c,1,8)
    action[8:13]=bytes([2,1,0x11,2,1]);struct.pack_into('<Q',action,24,1)
    action[64:148]=q[64:148];struct.pack_into('<Q',action,168,1)
    action[176:184]=q[576:584];action[184:195]=q[592:603]
    action[224:228]=bytes([1,2,0,0]);struct.pack_into('<Q',action,232,1);action[257]=255
    save('action',action)
    c=bytearray(256);c[:148]=action[:148]
    struct.pack_into('<IHH',c,0,0x3143414c,1,4)
    struct.pack_into('<I',c,16,47) # Safe error, typed retirement, no slot update.
    struct.pack_into('<H',c,148,7);struct.pack_into('<I',c,152,0x04000017)
    struct.pack_into('<Q',c,156,(1<<64)-1)
    struct.pack_into('<IIH',c,164,5,5,1);save('action_error_template',c)
    for name,path in [('source',a.source),('gold',a.gold)]:
        b=path.read_bytes()
        if len(b)!=65536:raise RuntimeError('frozen numerical input must have 16 rows')
        (a.out/(name+'.mem')).write_text(''.join(f'{w:08x}\n' for w in struct.unpack('<16384I',b)))
        (a.out/(name+'_rows16.f32.bin')).write_bytes(b)
    (a.out/'scope.json').write_text(json.dumps({'scope':'real generated one-row LN from normally monitored complete B1/S64 controlled checkpoint; source first16 frozen numerical input repeated for rows16..63; actual F9 verified LPC1 consumer, completion-derived END, honest short-window END rejection and task5 retirement; controlled LAC1 safe-error consumer, no executor/program/13BO success','source_initialized_by_real_W_only':True,'gold_words':1024},indent=2)+'\n')
    print('FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_FIXTURE_PASS rows=1 checkpoint_rows=64 controlled_predecessor=1')

if __name__=='__main__':main()
