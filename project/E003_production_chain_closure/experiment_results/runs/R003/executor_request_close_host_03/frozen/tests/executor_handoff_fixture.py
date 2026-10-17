#!/usr/bin/env python3
"""Literal LHC1 oracle; no DUT encode or DUT result is an input."""
import argparse,struct,subprocess,sys
from pathlib import Path

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--model-header',type=Path,required=True)
    ap.add_argument('--model-aux',type=Path,required=True)
    ap.add_argument('--output',type=Path,required=True)
    a=ap.parse_args();a.output.mkdir(exist_ok=False)
    subprocess.run([sys.executable,str(Path(__file__).with_name('executor_checkpoint_fixture.py')),
        '--model-header',str(a.model_header),'--model-aux',str(a.model_aux),
        '--output',str(a.output/'v2')],check=True)
    base=bytearray((a.output/'v2/checkpoint_request.bin').read_bytes())
    struct.pack_into('<IHH',base,0,0x3143484c,1,16)
    struct.pack_into('<Q',base,32,(1<<64)-1)
    struct.pack_into('<QQ',base,776,29,101)
    frames=[]
    for kind in range(1,8):
        p=bytearray(base);p[8]=kind
        struct.pack_into('<Q',p,680,0 if kind==1 else 19)
        p[792]=int(kind in [3,4])
        if kind>=5:
            struct.pack_into('<H',p,10,7)
            struct.pack_into('<I',p,24,0x0700000e)
        (a.output/('control_'+str(kind)+'.bin')).write_bytes(p)
        frames.append(p)
    (a.output/'all_control.bin').write_bytes(b''.join(frames))
    # Preserve the seven historical frames byte for byte. The internal opcode
    # extension has separate literal success/error and commit0/1 fixtures.
    closing=[]
    for kind in [8,9]:
        for failed in [False,True]:
            for committed in [0,1]:
                p=bytearray(base);p[8]=kind;p[792]=committed
                struct.pack_into('<Q',p,680,19)
                if failed:
                    struct.pack_into('<H',p,10,7)
                    struct.pack_into('<I',p,24,0x0700000e)
                name=('close' if kind==8 else 'closed')+('_error' if failed else '_ok')+'_c'+str(committed)
                (a.output/(name+'.bin')).write_bytes(p);closing.append(p)
    (a.output/'all_close_control.bin').write_bytes(b''.join(closing))
    subprocess.run([sys.executable,str(Path(__file__).with_name('program_pending_fixture.py')),
        '--output',str(a.output)],check=True)
    print('FULL_CURRENT_EXECUTOR_HANDOFF_FIXTURE_PASS control_bytes=7168 close_bytes=8192 independent=1')
if __name__=='__main__':main()
