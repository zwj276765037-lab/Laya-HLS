#!/usr/bin/env python3
"""Seal exactly the XSim log and eight full byte dumps before offline checking."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('mode',choices=('base_h15_r63','changed_h0_r0'))
p.add_argument('runtime_dir',type=Path)
args=p.parse_args()
names=['xsim.log',*[f'observed_{i}.hex' for i in range(4)],
       *[f'att_out_{i}.hex' for i in range(4)]]
files={}
for name in names:
    path=args.runtime_dir/name
    assert path.is_file(),path
    data=path.read_bytes()
    files[name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
output=args.runtime_dir/'runtime_seal.json'
assert not output.exists(),output
output.write_text(json.dumps({
    'schema':'attention_v5_finite_runtime_seal_v1','mode':args.mode,'files':files},indent=2,sort_keys=True)+'\n')
print(f'ATT_FINITE_RUNTIME_SEALED mode={args.mode} files=9')
