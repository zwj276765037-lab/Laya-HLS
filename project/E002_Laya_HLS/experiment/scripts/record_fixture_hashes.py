#!/usr/bin/env python3
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
base = root / "reference/runs/typed_q8_ref_20261005"
for profile in ("abi_replay", "original_native"):
    p = base / profile
    m = json.loads((p / "manifest.json").read_text())
    paths = [p / "manifest.json", p / "verification.json"]
    if profile == "abi_replay":
        paths += [p / "request_v1.bin", p / "fixture_metadata.json"]
        for name in ("input_ids", "attention_mask", "marker_pos", "marker_mask", "qtype"):
            paths.append(p / next(t["path"] for t in m["tensors"] if t.get("name") == name))
        for node in ("linear", "linear_3", "node_1808"):
            paths.append(p / next(s["path"] for s in m["native_quantized_activation_scratch"] if s["node"] == node))
        for name in ("enc0_q", "enc0_qkv"):
            paths.append(p / m["semantic_aliases"][name]["path"])
        for name in ("act_input1028", "candidate_raw_logits", "act_raw_logits", "act_probability_vector"):
            paths.append(p / m["semantic_aliases"][name]["path"])
        paths.append(p / next(t["path"] for t in m["tensors"] if t.get("id") == "ir_1470"))
    for path in paths:
        print(hashlib.sha256(path.read_bytes()).hexdigest(), path)
