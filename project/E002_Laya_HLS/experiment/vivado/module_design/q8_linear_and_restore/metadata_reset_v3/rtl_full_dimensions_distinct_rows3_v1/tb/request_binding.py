#!/usr/bin/env python3
"""Read-only binding of the frozen B2/S128 request and three valid rows."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[6]
GATE = ROOT / "results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_design_source_preparation_release.json"
GATE_SHA256 = "cd998108174c6dfc3409adbd6bce5ea2aff741379c9f35e46abeb272fe59cb96"
PAGE = 4096
FROZEN_REQUEST_BUILD_TAG = "4f12ecfe940ecf2a8998a8626fc1ed1c"


def need(ok: bool, reason: str) -> None:
    if not ok:
        raise ValueError(reason)


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def record(path: Path, raw: bytes | None = None) -> dict:
    data = path.read_bytes() if raw is None else raw
    return {"path": str(path), "bytes": len(data), "sha256": sha(data)}


def load_gate() -> dict:
    raw = GATE.read_bytes()
    need(sha(raw) == GATE_SHA256, "distinct-row source gate changed")
    gate = json.loads(raw)
    need(gate["schema"] == "reviewer_q8_scorer_distinct_valid_rows3_source_preparation_release_v1",
         "distinct-row source gate schema")
    return gate


def request_identity(gate: dict, tags: dict | None = None) -> dict:
    if tags is None:
        manifest_record = gate["production_manifest"]
        manifest_raw = Path(manifest_record["path"]).read_bytes()
        need(len(manifest_raw) == manifest_record["bytes"] and
             sha(manifest_raw) == manifest_record["sha256"],
             "packaged model manifest identity")
        tags = json.loads(manifest_raw)["tags"]
    bound = gate["frozen_request"]
    path = Path(bound["path"])
    raw = path.read_bytes()
    need(len(raw) == bound["bytes"] == 1856 and sha(raw) == bound["sha256"],
         "frozen request identity")
    u16 = lambda offset: struct.unpack_from("<H", raw, offset)[0]
    u32 = lambda offset: struct.unpack_from("<I", raw, offset)[0]
    u64 = lambda offset: struct.unpack_from("<Q", raw, offset)[0]
    need(raw[:4] == b"LYRQ" and (u16(4), u16(6), u16(8), u16(10), u16(12), u16(14)) ==
         (1, 0, 128, 32, 5, 0), "request ABI header")
    need((u32(16), u16(20), u16(22), u64(24), u64(32)) == (1856, 2, 128, 1, 1),
         "request frame/shape/identity")
    need((u32(104), u32(108), u32(112), u32(116), u64(120)) ==
         (128, 320, 16384, 4096, 0), "request limits")
    request_tags = {name: raw[offset:offset+16].hex() for offset, name in
                    ((40, "model"), (56, "numeric"), (72, "layout"), (88, "build"))}
    need(request_tags["build"] == FROZEN_REQUEST_BUILD_TAG,
         "frozen accepted request build tag")
    if tags is not None:
        for offset, name in ((40, "model"), (56, "numeric"), (72, "layout")):
            need(raw[offset:offset+16] == bytes.fromhex(tags[name]),
                 f"request {name} tag")
    lengths = (1024, 256, 128, 32, 8)
    offsets = (320, 1344, 1600, 1728, 1792)
    names = ("tokens", "attention_mask", "marker_indices", "marker_mask", "qtype")
    rows = []
    for i, (name, offset, length) in enumerate(zip(names, offsets, lengths)):
        desc = 128 + 32*i
        dim1 = 128 if i < 2 else 1 if i == 4 else 16
        stride0 = (512, 128, 64, 16, 4)[i]
        stride1 = 0 if i == 4 else 4 if i in (0, 2) else 1
        elements = 2 if i == 4 else 256 if i < 2 else 32
        need((u16(desc), raw[desc+2], raw[desc+3], u32(desc+4), u32(desc+8),
              u16(desc+12), u16(desc+14), u32(desc+16), u32(desc+20),
              u32(desc+24), u32(desc+28)) ==
             (i+1, 2 if i in (1,3) else 1, 1 if i == 4 else 2,
              offset, length, 2, dim1, stride0, stride1, elements, 0),
             f"request directory {name}")
        end = offset + length
        next_offset = offsets[i+1] if i+1 < len(offsets) else len(raw)
        need(end <= next_offset and not any(raw[end:next_offset]),
             f"request padding {name}")
        rows.append({"name": name, "offset": offset, "bytes": length})
    expected = gate["real_candidate_evidence"]
    need(expected["batch"] == 1 and expected["rows"] == [0, 1, 2],
         "reviewed request row selection")
    marker_indices = [u32(offsets[2] + 4*(16 + row)) for row in range(3)]
    marker_masks = [raw[offsets[3] + 16 + row] for row in range(3)]
    positions = [index - 128 for index in marker_indices]
    attended = [raw[offsets[1] + index] for index in marker_indices]
    need(marker_indices == expected["marker_indices_flat"] == [147, 163, 174] and
         positions == expected["marker_positions_in_batch"] == [19, 35, 46] and
         marker_masks == expected["marker_mask"] == [1, 1, 1] and
         attended == [1, 1, 1], "three distinct valid attended markers")
    return {"source": record(path, raw), "request_id": u64(24),
            "generation": u64(32), "shape": {"B": u16(20), "S": u16(22)},
            "request_tags": request_tags,
            "packaged_model_build_tag": tags["build"],
            "directory": rows, "batch": 1, "rows": [0, 1, 2],
            "marker_indices_flat": marker_indices,
            "marker_positions_in_batch": positions,
            "marker_mask": marker_masks, "attention_mask_at_markers": attended}


def checkpoint_slice(gate: dict, name: str, oracle: bytes, dut: bytes) -> tuple[bytes, dict]:
    item = next(x for x in gate["checkpoint_slices"] if x["name"] == name)
    need(len(oracle) == len(dut) == 131072 and oracle == dut and
         sha(oracle) == item["oracle"]["sha256"] ==
         item["accepted_cpu_dut_checkpoint"]["sha256"],
         f"frozen checkpoint full-file identity: {name}")
    start, end = item["offset"], item["end_exclusive"]
    need((start, end, item["bytes"]) == (65536, 77824, 12288),
         f"checkpoint interval: {name}")
    selected = oracle[start:end]
    row_hashes = [sha(selected[i*PAGE:(i+1)*PAGE]) for i in range(3)]
    need(sha(selected) == item["selected_sha256"] and
         row_hashes == item["row_sha256"] and len(set(row_hashes)) == 3,
         f"three distinct frozen checkpoint rows: {name}")
    return selected, {"name": name, "offset": start, "bytes": len(selected),
                      "sha256": sha(selected), "row_sha256": row_hashes}
