#!/usr/bin/env python3
"""Rebind frozen request headers to a source-matched model build tag."""

import hashlib
import json
from pathlib import Path

base = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
stage = base / "results/encoder_decision_validation_20261009"
old = base / "results/attention_rtl_repair_20261008/d2_cpu_full_official/dut/inputs"
new = base / "build/frontend-requests-20261009"
manifest = json.loads((base / "build/model-encoder-decision-front-20261009/manifest.json").read_text())
old_tag = bytes.fromhex("fe067c8aa0627ad770096f9721394645")
new_tag = bytes.fromhex(manifest["tags"]["build"])
assert len(old_tag) == len(new_tag) == 16 and new_tag != old_tag
if new.exists():
    raise SystemExit(f"output already exists: {new}")
new.mkdir(parents=True)
names = ("B2_S128", "accepted_gamma_failure",
         "B1_from_b0_S128", "B1_from_b1_S128")
report = {"old_tag": old_tag.hex(), "new_tag": new_tag.hex(),
          "model_manifest": str(base / "build/model-encoder-decision-front-20261009/manifest.json"),
          "requests": []}
for name in names:
    src = old / f"{name}.request.bin"
    value = src.read_bytes()
    if value[:4] != b"LYRQ" or value[88:104] != old_tag:
        raise SystemExit(f"frozen request identity mismatch: {src}")
    rebound = value[:88] + new_tag + value[104:]
    assert len(rebound) == len(value)
    assert [i for i, (a, b) in enumerate(zip(value, rebound)) if a != b] == [
        i for i in range(88, 104) if old_tag[i - 88] != new_tag[i - 88]]
    dst = new / src.name
    dst.write_bytes(rebound)
    report["requests"].append({
        "name": name, "source": str(src), "output": str(dst),
        "bytes": len(value),
        "old_sha256": hashlib.sha256(value).hexdigest(),
        "new_sha256": hashlib.sha256(rebound).hexdigest(),
        "changed_offsets": [i for i in range(88, 104)
                            if value[i] != rebound[i]],
        "request_id": int.from_bytes(rebound[24:32], "little"),
        "generation": int.from_bytes(rebound[32:40], "little"),
        "B": int.from_bytes(rebound[20:22], "little"),
        "S": int.from_bytes(rebound[22:24], "little"),
    })
(new / "identity_rebind.json").write_text(json.dumps(report, indent=2) + "\n")
print(new / "identity_rebind.json")
