#!/usr/bin/env python3
"""Join independent native primitive expected values; no DUT numerical helpers."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('mul',type=Path);p.add_argument('add',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
muls=a.mul.read_text().splitlines();adds=a.add.read_text().splitlines()
assert len(muls)==217304 and len(adds)==191904
assert all(len(x)==24 for x in muls+adds)
identity=next(x for x in muls if x[:16]=='000000013f800000')
assert identity[16:]=='00000001'
a.output.parent.mkdir(parents=True,exist_ok=True);small=a.output.with_name('vectors4.hex')
with a.output.open('w') as full,small.open('w') as four:
 for i in range(262144):
  mul=identity if i==0 else muls[(i*104729)%len(muls)]
  add=adds[(i*65537)%len(adds)]
  record=mul+add+'\n';full.write(record)
  if i<16384:four.write(record)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
meta={'mul_source':str(a.mul),'mul_sha256':sha(a.mul),'mul_count':len(muls),'add_source':str(a.add),'add_sha256':sha(a.add),'add_count':len(adds),'full_count':262144,'full_sha256':sha(a.output),'four_count':16384,'four_sha256':sha(small),'first_mul':'00000001 * 3f800000 = 00000001 from independent native fixture','permutation':'mul i*104729 mod217304, add i*65537 mod191904; record0 exact native counterexample identity'}
a.output.with_name('native_fixture_identity.json').write_text(json.dumps(meta,indent=2)+'\n')
print('SHARED_STRICT_FIXTURE_PASS full_records=262144 four_records=16384 old_counterexample_in_record0=1 native_finite_domain_including_under_overflow')
