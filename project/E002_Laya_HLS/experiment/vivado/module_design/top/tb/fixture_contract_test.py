#!/usr/bin/env python3
"""Read-only native Typed Q8 evidence for the P0 format and layout contract."""
import hashlib
import json
import pathlib
import struct
import subprocess
import sys


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def checked_file(root, entry):
    path = root / entry["path"]
    data = path.read_bytes()
    require(hashlib.sha256(data).hexdigest() == entry["sha256"], f"hash {path}")
    span = entry.get("storage_span_bytes", entry.get("storage_bytes"))
    require(len(data) == int(span), f"length {path}")
    return data


def native_tensor(manifest, name):
    return next(t for t in manifest["tensors"] if t.get("name") == name)


def exact_mask(raw):
    require(len(raw) % 4 == 0, "F32 mask length")
    words = struct.unpack("<" + "I" * (len(raw) // 4), raw)
    require(set(words) <= {0x00000000, 0x3F800000}, "mask must be exact +0/+1")
    return bytes(int(x == 0x3F800000) for x in words)


def main():
    require(len(sys.argv) == 3, "usage: fixture_contract_test.py ROOT CPP_CHECKER")
    root, checker = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    capture_root = root / "reference/runs/typed_q8_ref_20261005"
    replay, original = (capture_root / p for p in ("abi_replay", "original_native"))
    m = json.loads((replay / "manifest.json").read_text())
    old = json.loads((original / "manifest.json").read_text())
    require(m["request_profile"].startswith("abi_replay S128"), "S128 profile")
    require(old["request_profile"].startswith("original_native S94"), "S94 profile")
    require(m["model"]["sha256"] == old["model"]["sha256"], "same bound GGUF")
    require(json.loads((replay / "verification.json").read_text())["status"] == "PASS", "verification record")

    fixture = replay / "request_v1.bin"
    frame = fixture.read_bytes()
    require(hashlib.sha256(frame).hexdigest() == "2c5fb86724422dc82b47c0b3342d6d03bb308d28bfc81e4778dc9afd66e5e899", "fixture SHA256")
    require(len(frame) == 1856, "frame bytes")
    offsets = (320, 1344, 1600, 1728, 1792)
    lengths = (1024, 256, 128, 32, 8)
    names = ("input_ids", "attention_mask", "marker_pos", "marker_mask", "qtype")
    for i, (name, offset, length) in enumerate(zip(names, offsets, lengths)):
        entry = native_tensor(m, name)
        raw = checked_file(replay, entry)
        converted = exact_mask(raw) if name.endswith("mask") else raw
        require(len(converted) == length, f"{name} length")
        require(frame[offset : offset + length] == converted, f"{name} payload")
        require(struct.unpack_from("<I", frame, 128 + i * 32 + 4)[0] == offset, f"{name} directory")

    q = m["semantic_aliases"]["enc0_q"]
    qkv = m["semantic_aliases"]["enc0_qkv"]
    q_data, qkv_data = checked_file(replay, q), checked_file(replay, qkv)
    require(q["storage_span_bytes"] > q["logical_bytes"], "non-contiguous view")
    require(q["ggml_nb_bytes"][1] == 12288, "native Q stride")
    for batch, token, feature in ((0, 0, 0), (0, 127, 1023), (1, 7, 31), (1, 127, 1023)):
        offset = feature * q["ggml_nb_bytes"][0] + token * q["ggml_nb_bytes"][1] + batch * q["ggml_nb_bytes"][2]
        other = feature * qkv["ggml_nb_bytes"][0] + token * qkv["ggml_nb_bytes"][1] + batch * qkv["ggml_nb_bytes"][2]
        require(q_data[offset : offset + 4] == qkv_data[other : other + 4], "Q view stride")

    selected = []
    for node in ("linear", "linear_3", "node_1808"):
        entry = next(s for s in m["native_quantized_activation_scratch"] if s["node"] == node)
        checked_file(replay, entry)
        require(entry["block_format"].startswith("IEEE FP16 d bytes0..1"), "native Q8_0 block format")
        selected.append(replay / entry["path"])

    aliases = m["semantic_aliases"]
    paths = []
    for name in ("act_input1028", "candidate_raw_logits", "act_raw_logits", "act_probability_vector"):
        checked_file(replay, aliases[name])
        paths.append(replay / aliases[name]["path"])
    require(paths[3].name == "preclamp_31.bin", "probability capture timing")
    terminal = next(t for t in m["tensors"] if t.get("id") == "ir_1470")
    require(checked_file(replay, terminal) != paths[3].read_bytes(), "terminal softmax is overwritten")
    require(aliases["act_probability_vector"]["capture_stage"] == "native CPU before inplace clamp_min", "pre-CLAMP stage")

    command = [str(checker), str(fixture), *(str(p) for p in selected), *(str(p) for p in paths[:3])]
    subprocess.run(command, check=True)
    print("REAL_FIXTURE_MANIFEST_PASS profiles=S94,S128 inputs=5 stride_view=1 q8_scratch=3 preclamp=1")


if __name__ == "__main__":
    main()
