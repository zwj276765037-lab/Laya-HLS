#!/usr/bin/env python3
"""Bind independent QKV gold to actual wide model BO slices for RTL replay."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct

from make_joint_dma_act_inputs import digest, emit_hex, require, window

OUT0_BASE = 0x0000000200000000
OUT1_BASE = 0x0000000300000000


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("model_package", type=Path)
    ap.add_argument("descriptors", type=Path)
    ap.add_argument("fixtures", type=Path)
    ap.add_argument("case", choices=("qkv_row1", "qkv_rows4"))
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    model, desc, fixtures, out = (x.resolve() for x in
                                   (args.model_package, args.descriptors,
                                    args.fixtures, args.output))
    require(not out.exists(), "fresh QKV AXI input directory")
    fm = json.loads((fixtures / "manifest.json").read_text())
    require(fm["schema"] == "tm1tn8_real_fixtures_v2" and
            fm["session"] == {"request_id": 3, "generation": 1,
                              "B": 1, "S": 128}, "fixed QKV fixture session")
    case = next(c for c in fm["cases"] if c["name"] == args.case)
    rows = case["shape"]["rows"]
    require(case["source_profile"] == {
        "id": 1, "bank": 1, "region": 0, "epoch": 1,
        "stage": 1, "layer": 255, "row_space": "TOKEN", "width": 1024,
        "batch": 0, "row0": 0, "rows": rows, "dtype": "F32",
        "semantic_node": "embedding_norm"}, "QKV source profile")
    record = case["model_record"]
    require(record["family"] == 1 and record["layer"] == 0 and
            record["q0_span"] == record["q1_span"] == 1572864 and
            record["scale_span"] == 196608 and record["bias_span"] == 0,
            "QKV model window")
    load = (desc / "qkv_load.bin").read_bytes()
    run_name = "qkv_run1_trace.bin" if rows == 1 else "qkv_run4_trace.bin"
    run = bytearray((desc / run_name).read_bytes())
    require(len(load) == len(run) == 512 and
            struct.unpack_from("<Q", run, 4*50)[0] == 0 and
            struct.unpack_from("<Q", run, 4*52)[0] == 0,
            "QKV descriptor output bases initially zero")
    if rows == 4:
        # The shared descriptor sequence uses task5 after an earlier one-row
        # RUN. This isolated cold four-row test starts from a fresh LOAD_W.
        require(tuple(struct.unpack_from("<I", run, 4*i)[0]
                      for i in (8, 27, 30, 31)) == (5, 2, 2, 4),
                "QKV four-row continuation descriptor identity")
        for i, value in ((8, 3), (27, 1), (30, 1), (31, 2)):
            struct.pack_into("<I", run, 4*i, value)
    struct.pack_into("<Q", run, 4*50, OUT0_BASE)
    struct.pack_into("<Q", run, 4*52, OUT1_BASE)
    prefix = args.case + "_"
    source = (fixtures / (prefix + "source_f32.bin")).read_bytes()
    require(len(source) == rows*4096 and
            hashlib.sha256(source).hexdigest() ==
            case["source_slice"]["sha256"], "independent QKV source slice")
    q0 = window(model / "w_q0.bin", record["q0_offset"], 1572864)
    q1 = window(model / "w_q1.bin", record["q1_offset"], 1572864)
    scale = window(model / "w_scale.bin", record["scale_offset"], 196608)
    require(q0 == (fixtures / (prefix + "q0.bin")).read_bytes() and
            q1 == (fixtures / (prefix + "q1.bin")).read_bytes() and
            scale == (fixtures / (prefix + "w_scale.bin")).read_bytes(),
            "actual QKV BO differs from independent GGUF fixture")
    steps_raw = (fixtures / (prefix + "steps_u32x6.bin")).read_bytes()
    steps = memoryview(steps_raw).cast("I")
    require(len(steps) == rows*32*3072*6, "QKV independent steps")
    trace = bytearray()
    for g in range(32):
        at = g*3072*6
        trace += struct.pack("<8I", *(list(steps[at:at+6]) + [g, 1]))
    data = {
        "desc_load.hex": (load, 4), "desc_run.hex": (run, 4),
        "q0.hex": (q0, 64), "q1.hex": (q1, 64),
        "scale.hex": (scale, 64),
        "aux_header.hex": (window(model / "aux.bin", 0, 128), 4),
        "activation.hex": (source, 64),
        "a8q.hex": ((fixtures / (prefix + "a8_q.bin")).read_bytes(), 4),
        "a8half.hex": ((fixtures / (prefix + "a8_scale.bin")).read_bytes(), 4),
        "output.hex": ((fixtures / (prefix + "output_f32.bin")).read_bytes(), 4),
        "trace.hex": (trace, 4),
    }
    out.mkdir(parents=True)
    outputs = {name: emit_hex(out/name, bytes(payload), beat)
               for name, (payload, beat) in data.items()}
    manifest = {"schema": "tm1tn8_joint_dma_qkv_axi_inputs_v1",
                "case": args.case, "rows": rows, "session": fm["session"],
                "source_profile": case["source_profile"],
                "source_slice": case["source_slice"],
                "package_tags_hex": fm["package_tags_hex"],
                "model_record": record,
                "out0_base": OUT0_BASE, "out1_base": OUT1_BASE,
                "inputs": [digest(model/"laya_model_layout_generated.h"),
                           digest(desc/"manifest.json"),
                           digest(fixtures/"manifest.json"),
                           digest(Path(__file__))], "outputs": outputs}
    (out/"manifest.json").write_text(json.dumps(manifest, indent=2,
                                                  sort_keys=True)+"\n")
    print(f"TM1TN8_JOINT_DMA_QKV_INPUTS_PASS rows={rows}")


if __name__ == "__main__":
    main()
