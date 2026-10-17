"""Verify frozen bytes and output field layout; does not evaluate any oracle."""
import hashlib
import json
import os
from pathlib import Path
import resource
import struct
import time

ROOT = Path(__file__).resolve().parents[3]
RUN = Path(__file__).resolve().parent / "run01"
start=time.monotonic()
manifest_bytes=(RUN/"manifest.json").read_bytes()
m=json.loads(manifest_bytes)
def sha(b): return hashlib.sha256(b).hexdigest()
checked=[]
for entry in m["sources"]:
    b=(ROOT/entry["path"]).read_bytes()
    assert len(b)==entry["bytes"] and sha(b)==entry["sha256"], entry["path"]
    checked.append(entry["path"])
for entry in m["inputs"]:
    b=(ROOT/entry["frozen_path"]).read_bytes()
    assert len(b)==entry["bytes"] and sha(b)==entry["sha256"]
    p=(ROOT/entry["parent"]["path"]).read_bytes()
    off=entry["offset_bytes"]
    assert p[off:off+entry["bytes"]]==b
    checked.append(entry["frozen_path"])
for entry in m["products"]:
    b=(ROOT/entry["path"]).read_bytes()
    assert len(b)==entry["bytes"] and sha(b)==entry["sha256"]
    checked.append(entry["path"])
assert (RUN/"prepare_reference.frozen.py").read_bytes()==(ROOT/m["caller"]["path"]).read_bytes()
assert sha((RUN/"prepare_reference.frozen.py").read_bytes())==m["caller"]["sha256"]
for row in range(2):
    final=(RUN/"products"/f"row{row}_full_FINAL.f32.bin").read_bytes()
    trace=(RUN/"products"/f"row{row}_steps_ab_lower_cd_upper.f32.bin").read_bytes()
    f=struct.unpack("<3072I",final)
    t=struct.unpack("<6144I",trace)
    assert all(x&0x7f800000 != 0x7f800000 for x in f+t)
    for plane in range(2):
        for head in range(16):
            for pair in range(32):
                index=((plane*16+head)*32+pair)*6
                lo=plane*1024+head*64+pair
                assert t[index+2]==f[lo] and t[index+5]==f[lo+32]
    original=(RUN/"inputs/current_rows01_pre.f32.bin").read_bytes()[row*12288:(row+1)*12288]
    assert final[8192:]==original[8192:]
    norm=(RUN/"products"/f"row{row}_norm_unchanged.f32.bin").read_bytes()
    assert norm==(RUN/"inputs/current_rows01_norm.f32.bin").read_bytes()[row*4096:(row+1)*4096]
result=dict(status="PASS_BYTE_INTEGRITY_AND_DIAGNOSTIC_LAYOUT",manifest_sha256=sha(manifest_bytes),verifier_sha256=sha(Path(__file__).read_bytes()),identity_checks=len(checked),all_original_sources_and_frozen_windows_unchanged=True,diagnostic_output_fields_checked=4096,no_oracle_calls=True,sampling=dict(wall_seconds_inside_script=time.monotonic()-start,maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0)))
with (RUN/"artifact_verification.json").open("x") as out:
    out.write(json.dumps(result,ensure_ascii=False,indent=2)+"\n")
print(json.dumps(result,ensure_ascii=False))
