#!/usr/bin/env python3
"""Actual-helper stimuli, with control returns from the frozen literal oracle."""
import argparse,json,struct,hashlib
from pathlib import Path

def hexfile(path,p):
    path.write_text(''.join(p[i:i+64][::-1].hex()+'\n' for i in range(0,len(p),64)))
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--helper',type=Path,required=True)
    ap.add_argument('--output',type=Path,required=True);a=ap.parse_args();a.output.mkdir(exist_ok=False)
    for source,name in [('actual_helper_hold.bin','hold'),('actual_helper_query.bin','query'),
        ('helper_proof_stimulus.bin','proof'),('actual_helper_import_ok.bin','import_ok'),
        ('actual_helper_abort.bin','abort')]:
        p=(a.helper/source).read_bytes();assert len(p)==1024;hexfile(a.output/(name+'.hex'),p)
    # HELD/GRANTED/ABORT_CLOSED are expected frames from a literal C-independent
    # layout, not captured shell response bytes.
    for kind,name in [(2,'held_gold'),(4,'grant_gold'),(6,'abort_closed_gold')]:
        p=bytearray((a.helper/('control_'+str(kind)+'.bin')).read_bytes())
        struct.pack_into('<Q',p,680,1);hexfile(a.output/(name+'.hex'),p)
    literal=bytearray((a.helper/'control_3.bin').read_bytes());struct.pack_into('<Q',literal,680,1)
    assert literal==(a.helper/'actual_helper_import_ok.bin').read_bytes()
    aborted=(a.helper/'actual_helper_abort.bin').read_bytes()
    assert aborted[792]==0 and struct.unpack_from('<HI',aborted,10)[0]==7
    assert struct.unpack_from('<I',aborted,24)[0]==0x0700000e
    receipt=a.helper.parent/'helper_run/receipt.json'
    run=json.loads(receipt.read_text())
    (a.output/'scope.json').write_text(json.dumps({'scope':'offline actual C++ helper control outputs; literal control response gold','hardware_helper_same_runtime':False,
      'helper_receipt':{'path':str(receipt.resolve()),'sha256':hashlib.sha256(receipt.read_bytes()).hexdigest()},
      'actual_rtl_capture_import':any('actual_rtl_capture=1' in s for s in run['run']['markers'])},indent=2)+'\n')
    print('FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_FIXTURE_PASS actual_helper_success_failure=1 independent_control_gold=1')
if __name__=='__main__':main()
