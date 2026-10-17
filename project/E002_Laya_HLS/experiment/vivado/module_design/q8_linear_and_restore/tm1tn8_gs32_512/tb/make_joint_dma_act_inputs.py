#!/usr/bin/env python3
"""Sparse physical AXI contents for the generated-wrapper ACT cold smoke test."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct

OUT0_BASE = 0x0000000200000000


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def digest(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def window(path: Path, offset: int, count: int) -> bytes:
    require(offset >= 0 and count >= 0 and offset + count <= path.stat().st_size,
            "model BO window")
    with path.open("rb") as f:
        f.seek(offset)
        value = f.read(count)
    require(len(value) == count, "short model BO read")
    return value


def emit_hex(path: Path, value: bytes, beat: int) -> dict:
    require(len(value) % beat == 0, "hex beat alignment")
    path.write_text("".join(f"{int.from_bytes(value[i:i+beat], 'little'):0{2*beat}x}\n"
                            for i in range(0, len(value), beat)))
    return digest(path)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("model_package", type=Path)
    ap.add_argument("descriptors", type=Path)
    ap.add_argument("fixtures", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    model, desc, fixtures, out = (x.resolve() for x in
                                   (args.model_package, args.descriptors,
                                    args.fixtures, args.output))
    require(not out.exists(), "fresh ACT AXI input directory")
    fm = json.loads((fixtures / "manifest.json").read_text())
    require(fm["schema"] == "tm1tn8_real_fixtures_v2" and
            fm["session"] == {"request_id": 3, "generation": 1,
                              "B": 1, "S": 128}, "fixed ACT fixture profile")
    act = next(case for case in fm["cases"] if case["name"] == "act")
    require(act["source_profile"] == {
        "id": 10, "bank": 0, "region": 2, "epoch": 1,
        "stage": 6, "layer": 255, "row_space": "BATCH", "width": 256,
        "batch": 0, "row0": 0, "rows": 1, "dtype": "F32",
        "semantic_node": "act_hidden"}, "ACT source profile")
    record = act["model_record"]
    require(record["family"] == 12 and record["layer"] == 255 and
            record["q0_span"] == 2048 and record["q1_span"] == 0 and
            record["scale_span"] == 128 and record["bias_span"] == 8,
            "ACT model window")
    load = (desc / "act_load.bin").read_bytes()
    run = bytearray((desc / "act_run_trace.bin").read_bytes())
    require(len(load) == len(run) == 512, "Q8T1 descriptor bytes")
    require(struct.unpack_from("<I", run, 4*50)[0] == 0 and
            struct.unpack_from("<I", run, 4*51)[0] == 0,
            "descriptor out base initially zero")
    struct.pack_into("<Q", run, 4*50, OUT0_BASE)
    source = (fixtures / "act_source_f32.bin").read_bytes()
    require(hashlib.sha256(source).hexdigest() ==
            act["source_slice"]["sha256"] and len(source) == 1024,
            "independent source slice bytes")
    q0 = window(model / "w_q0.bin", record["q0_offset"], 2048)
    scale = window(model / "w_scale.bin", record["scale_offset"], 128)
    header = window(model / "aux.bin", 0, 128)
    bias = window(model / "aux.bin", record["bias_offset"], 8)
    require(q0 == (fixtures / "act_q0.bin").read_bytes() and
            scale == (fixtures / "act_w_scale.bin").read_bytes() and
            bias == (fixtures / "act_bias.bin").read_bytes(),
            "actual model BO differs from independent GGUF fixture")
    aq = (fixtures / "act_a8_q.bin").read_bytes()
    ah = (fixtures / "act_a8_scale.bin").read_bytes()
    steps = struct.unpack("<" + "I"*(len((fixtures / "act_steps_u32x6.bin").read_bytes())//4),
                          (fixtures / "act_steps_u32x6.bin").read_bytes())
    require(len(steps) == 8*2*6 and len(aq) == 256 and len(ah) == 16,
            "ACT independent trace shape")
    trace = bytearray()
    for g in range(8):
        trace += struct.pack("<8I", *(steps[(g*2)*6:(g*2)*6+6] +
                                      (g, 1)))
    out.mkdir(parents=True)
    data = {"desc_load.hex": (load, 4), "desc_run.hex": (run, 4),
            "q0.hex": (q0, 64), "scale.hex": (scale, 64),
            "aux_header.hex": (header, 4), "bias.hex": (bias, 4),
            "activation.hex": (source, 64), "a8q.hex": (aq, 4),
            "a8half.hex": (ah, 4),
            "output.hex": ((fixtures / "act_output_f32.bin").read_bytes(), 4),
            "trace.hex": (trace, 4)}
    outputs = {name: emit_hex(out / name, bytes(value), beat)
               for name, (value, beat) in data.items()}
    manifest = {"schema": "tm1tn8_joint_dma_act_axi_inputs_v1",
                "source_profile": act["source_profile"],
                "source_slice": act["source_slice"],
                "session": fm["session"], "package_tags_hex": fm["package_tags_hex"],
                "model_record": record,
                "out0_base": OUT0_BASE,
                "inputs": [digest(model / "laya_model_layout_generated.h"),
                           digest(fixtures / "manifest.json"),
                           digest(desc / "manifest.json"),
                           digest(Path(__file__))],
                "outputs": outputs}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2,
                                                  sort_keys=True) + "\n")
    print("TM1TN8_JOINT_DMA_ACT_INPUTS_PASS")


if __name__ == "__main__":
    main()
