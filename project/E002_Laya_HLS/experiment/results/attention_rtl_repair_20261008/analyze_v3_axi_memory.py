#!/usr/bin/env python3
"""Read-only source and RSS audit of the guarded D2-R v3 AXI simulator."""

from __future__ import annotations

import csv
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re


BASE = Path(__file__).resolve().parent
RUN = BASE / "d2_attention_slice/runs/depth_v3"
SIM = RUN / "csynth_work/hls/sim/verilog"
GUARD = RUN / "xsim_guard_16g"


def file_sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def location(text: str, snippet: str) -> int:
    assert snippet in text, snippet
    return text[:text.index(snippet)].count("\n") + 1


def last_location(text: str, snippet: str) -> int:
    assert snippet in text, snippet
    return text[:text.rindex(snippet)].count("\n") + 1


def main() -> None:
    reference = SIM / "attention_slice_subsystem/attention_slice_reference_model.sv"
    mem_model = SIM / "file_agent/mem_model.sv"
    reader = SIM / "file_agent/file_read_agent.sv"
    ref_text, mem_text, read_text = (p.read_text() for p in
                                     (reference, mem_model, reader))
    ports = {}
    pattern = (r"mem_blk_pages_(\w+)\.tvinload_pagechk_atinit\(fpath, "
               r"(\d+)\*\(\((\d+)\+7\)/8\), 0, 0\);")
    for match in re.finditer(pattern, ref_text):
        name, elements, bit_width = match.groups()
        elements, bit_width = int(elements), int(bit_width)
        depth_bytes = elements * ((bit_width + 7) // 8)
        ports[name] = {"depth_elements": elements, "element_bits": bit_width,
                       "memory_model_depth_bytes": depth_bytes,
                       "call_line": ref_text[:match.start()].count("\n") + 1}
    assert set(ports) == {"fixture", "io", "aux", "qkv0", "qkv1",
                          "att_out", "observed"}
    assert all(ports[name]["element_bits"] == 8 for name in ports
               if name != "observed")
    assert ports["observed"]["element_bits"] == 32
    total_bytes = sum(p["memory_model_depth_bytes"] for p in ports.values())
    assert total_bytes == 21304580

    guard = json.loads((GUARD / "guard_result.json").read_text())
    trigger = json.loads((GUARD / "guard_trigger.json").read_text())
    assert guard["trigger"] == "owned_rss_at_or_above_limit"
    rows = list(csv.DictReader((GUARD / "memory_timeline.csv").open()))
    t0 = datetime.fromisoformat(rows[0]["utc"])
    series = [((datetime.fromisoformat(r["utc"]) - t0).total_seconds(),
               int(r["owned_rss_kb"])) for r in rows]
    steady = [(t, rss) for t, rss in series if 120 <= t <= series[-1][0] - 5]
    t_mean = sum(t for t, _ in steady) / len(steady)
    r_mean = sum(r for _, r in steady) / len(steady)
    slope = (sum((t - t_mean) * (rss - r_mean) for t, rss in steady) /
             sum((t - t_mean) ** 2 for t, _ in steady))
    intercept = r_mean - slope * t_mean
    residual = sum((rss - (intercept + slope * t)) ** 2 for t, rss in steady)
    total = sum((rss - r_mean) ** 2 for _, rss in steady)
    rtl_files = sorted((RUN / "csynth_work/hls/sim/tv/rtldatafile").glob(
        "rtl.attention_slice.autotvout_*.dat"))
    assert len(rtl_files) == 5
    output = {
        "status": "RESOURCE_STOP_NO_RTL_NUMERICAL_CONCLUSION",
        "generated_source_sha256": {str(p): file_sha(p) for p in
                                    (reference, mem_model, reader)},
        "memory_model_calls": ports,
        "total_declared_memory_model_payload_bytes": total_bytes,
        "qkv_payload_share": (ports["qkv0"]["memory_model_depth_bytes"] +
                              ports["qkv1"]["memory_model_depth_bytes"]) /
                             total_bytes,
        "source_level_allocations": {
            "input_queue": {"declaration_line": location(read_text, "DATA_QUEUE_TYPE TV_Queue[$]"),
                            "per_input_item_bits": "8 for byte ports; 32 for observed"},
            "temporary_queue_push": {"line": last_location(read_text, "TV.push_back(data);")},
            "queue_copy_or_move": {"line": last_location(read_text, "TV_Queue.push_back(TV);")},
            "memory_array": {"line": location(mem_text, "logic[WIDTH-1:0] mem[];")},
            "written_bitmap_array": {"line": location(mem_text, "bit IsWr[];")},
            "memory_alloc": {"line": location(mem_text, "mem = new[depth];")},
            "written_bitmap_alloc": {"line": location(mem_text, "IsWr = new[depth];")},
            "written_bitmap_zero_loop": {"line": location(mem_text,
                                                    "for(int i=0; i<depth; i++) IsWr[i] = 0;")},
            "input_to_memory_copy_loop": {"line": location(mem_text,
                "for(int j=0; j<fr.TV_Queue[i].size; j++)")},
        },
        "source_level_nominal_bits": {
            "one_qkv_port_8bit_queue_plus_8bit_logic_array_plus_1bit_IsWr":
                ports["qkv0"]["memory_model_depth_bytes"] * 17,
            "seven_port_sum_if_corresponding_objects_coexist": total_bytes * 17,
            "note": "Bit-width accounting only. Source does not prove concurrent lifetime or actual SV queue/dynamic-array host representation."
        },
        "guard": guard,
        "peak_rss_bytes_per_total_planned_payload_byte_noncausal":
            guard["peak_owned_rss_kb"] * 1024 / total_bytes,
        "peak_xsimk_rss_kb": next(item["rss_kb"] for item in
                                   trigger["snapshot"] if item["command"] == "xsimk"),
        "rss_steady_interval_seconds": [120, series[-1][0] - 5],
        "rss_steady_slope_kib_per_second": slope,
        "rss_steady_slope_mib_per_second": slope / 1024,
        "rss_steady_linear_fit_r2": 1 - residual / total,
        "rtl_outputs": [{"path": str(p), "bytes": p.stat().st_size} for p in rtl_files],
        "sim_progress": "0/1 at time 117000; no later progress line",
        "stage_limit": "UVM_VERBOSITY=UVM_NONE suppressed per-port read/initialization markers; current trace cannot identify the exact active allocation or bytes processed at stop.",
    }
    path = GUARD / "axi_memory_static_audit.json"
    path.write_text(json.dumps(output, indent=2) + "\n")
    print(path, file_sha(path))


if __name__ == "__main__":
    main()
