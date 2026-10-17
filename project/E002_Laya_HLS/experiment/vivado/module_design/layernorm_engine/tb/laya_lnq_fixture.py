#!/usr/bin/env python3
"""Transcode existing P1 oracle-checked row files for XSim; no new gold."""
import hashlib
import json
import pathlib
import struct
import sys

root = pathlib.Path(sys.argv[2]).resolve()
source = root / "results/engineering_p1/20261007T021236Z-1800667/fixture/cases"
out = pathlib.Path(sys.argv[1]).resolve()
out.mkdir(parents=True, exist_ok=False)
manifest = {}
for tag, case in (("0", "wi_ln_rows1"), ("1", "qkv_ln_rows1")):
    here = source / case
    raw = {}
    for name in ("input_f32.bin", "dut.ln.bin", "dut.ln_stats.bin", "dut.q8.bin"):
        raw[name] = (here / name).read_bytes()
    if tag == "1":
        raw["gamma_f32.bin"] = (here / "gamma_f32.bin").read_bytes()
    assert len(raw["input_f32.bin"]) == len(raw["dut.ln.bin"]) == 4096
    assert len(raw["dut.ln_stats.bin"]) == 12 and len(raw["dut.q8.bin"]) == 1088
    def words(data):
        return list(struct.unpack("<" + "I" * (len(data)//4), data))
    files = {
        f"x{tag}.mem": (32, words(raw["input_f32.bin"])),
        f"y{tag}.mem": (32, words(raw["dut.ln.bin"])),
        f"st{tag}.mem": (32, words(raw["dut.ln_stats.bin"])),
    }
    if tag == "1":
        files["g1.mem"] = (32, words(raw["gamma_f32.bin"]))
    q = raw["dut.q8.bin"]
    files[f"scale{tag}.mem"] = (16, [struct.unpack_from("<H", q, 34*g)[0] for g in range(32)])
    files[f"q{tag}.mem"] = (8, [q[34*g + 2 + i] for g in range(32) for i in range(32)])
    for name, (width, values) in files.items():
        path = out / name
        path.write_text("".join(f"{v:0{width//4}x}\n" for v in values))
    manifest[case] = {name: {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
                      for name, data in raw.items()}
(out / "source_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
