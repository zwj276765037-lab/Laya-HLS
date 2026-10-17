#!/usr/bin/env python3
"""Summarize measured XSim stages without extrapolating beyond 64 KiB."""

import hashlib
import json
from pathlib import Path


MODULE = Path(__file__).resolve().parent.parent
RUNS = MODULE / "runs"
DEPTHS = (1024, 4096, 16384, 65536)
MODES = ("Q", "M", "F")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    record = json.loads((RUNS / "diagnostic_results.json").read_text())
    jobs = {(j["mode"], j["depth"]): j for j in record["results"]}
    rows = []
    for depth in DEPTHS:
        for mode in MODES:
            job = jobs[mode, depth]
            stages = {s["label"]: s for s in job["stages"]}
            base = stages["process_baseline"]["rss_kb"]
            end = stages["readback_verified"]["rss_kb"]
            row = {"mode": mode, "depth_bytes": depth,
                   "baseline_rss_kb": base, "readback_rss_kb": end,
                   "readback_minus_baseline_kb": end - base,
                   "process_peak_kb": max(s["hwm_kb"] for s in job["stages"]),
                   "tree_peak_kb": job["guard"]["peak_owned_rss_kb"],
                   "elapsed_seconds": job["guard"]["elapsed_seconds"],
                   "minimum_mem_available_kb": job["guard"]["minimum_mem_available_kb"]}
            if mode in ("Q", "F"):
                row.update({"reader_header_minus_baseline_kb": stages["reader_header"]["rss_kb"] - base,
                            "queue_before_copy_minus_baseline_kb": stages["reader_before_2d_copy"]["rss_kb"] - base,
                            "queue_copy_rss_delta_kb": stages["reader_after_2d_copy"]["rss_kb"] - stages["reader_before_2d_copy"]["rss_kb"],
                            "reader_fread_bytes": stages["reader_after_trailer"]["aux"],
                            "reader_queue_elements": stages["reader_after_2d_copy"]["elements"],
                            "reader_transactions": stages["reader_after_2d_copy"]["aux"]})
            if mode in ("M", "F"):
                row.update({"mem_alloc_rss_delta_kb": stages["mem_after_mem_alloc"]["rss_kb"] -
                            (stages["process_baseline"]["rss_kb"] if mode == "M" else stages["reader_after_trailer"]["rss_kb"]),
                            "iswr_alloc_rss_delta_kb": stages["mem_after_iswr_alloc"]["rss_kb"] - stages["mem_after_mem_alloc"]["rss_kb"],
                            "mem_declared_depth": stages["mem_after_mem_alloc"]["elements"]})
            if mode == "F":
                row.update({"page_copy_count": stages["pages_after_copy"]["elements"],
                            "page_copy_rss_delta_kb": stages["pages_after_copy"]["rss_kb"] - stages["pages_before_copy"]["rss_kb"],
                            "offset_bind_rss_delta_kb": stages["offset_bound"]["rss_kb"] - stages["pages_after_copy"]["rss_kb"],
                            "offset_value": stages["offset_bound"]["elements"],
                            "offset_binding_count": stages["offset_bound"]["aux"]})
            rows.append(row)
    adjacent = []
    for mode in MODES:
        prior = None
        for depth in DEPTHS:
            current = next(row for row in rows if row["mode"] == mode and row["depth_bytes"] == depth)
            if prior is not None:
                span = depth - prior["depth_bytes"]
                metrics = ["readback_minus_baseline_kb"]
                if mode in ("Q", "F"):
                    metrics += ["queue_before_copy_minus_baseline_kb", "queue_copy_rss_delta_kb"]
                if mode in ("M", "F"):
                    metrics += ["mem_alloc_rss_delta_kb", "iswr_alloc_rss_delta_kb"]
                adjacent.append({"mode": mode, "from_depth": prior["depth_bytes"],
                                 "to_depth": depth, "delta_payload_bytes": span,
                                 "incremental_rss_bytes_per_payload_byte": {
                                     metric: (current[metric] - prior[metric]) * 1024 / span
                                     for metric in metrics}})
            prior = current
    result = {"evidence": "measured stage current RSS and HWM; 0.1 s external process-tree guard",
              "bounds": {"max_tree_rss_kb": 2 * 1024 * 1024, "max_seconds_per_job": 120,
                         "min_host_available_kb": 192 * 1024 * 1024, "sample_seconds": 0.1},
              "source_result_sha256": sha(RUNS / "diagnostic_results.json"),
              "rows": rows, "adjacent_depth_slopes": adjacent,
              "interpretation_limit": "Only 1-64 KiB single-transaction fixture prefixes are measured; no full Attention bound or numerical RTL conclusion."}
    (RUNS / "analysis.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
