"""Saved identities/bytes and log counters only: no oracle or floating arithmetic."""
from pathlib import Path
import hashlib
import json
import os
import re
import resource
import time

ROOT = Path(__file__).resolve().parents[2]
E = ROOT / "project/E002_Laya_HLS/experiment"
A = ROOT / "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts"
R = ROOT / "project/E005_full_request_performance/experiment_results/runs/R001/attempts"
start = time.perf_counter()


def identity(p):
    raw = p.read_bytes()
    return {"path": str(p.relative_to(ROOT)), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def saved(p, rec):
    got = identity(p)
    assert (got["bytes"], got["sha256"]) == (rec["bytes"], rec["sha256"]), str(p)
    return got


def row0(p):
    raw = p.read_bytes()[:4096]
    assert len(raw) == 4096
    return {"path": str(p.relative_to(ROOT)), "offset": 0, "bytes": 4096,
            "layout": "1024 little-endian F32 bit patterns; no arithmetic performed",
            "sha256": hashlib.sha256(raw).hexdigest()}


at166 = A / "AT166_SM004_down_ret_pair_index_full_01"
m166 = json.loads((at166 / "source_manifest.json").read_text())
fixture_names = ["ln_source_row0.hex", "ln_gold_row0.hex", "final_row0.hex", "g_row0.hex", "down_final_row0.hex"]
fixtures = {n: saved(at166 / "fixture" / n, m166["files"]["fixture/" + n]) for n in fixture_names}


def decode(n):
    words = (at166 / "fixture" / n).read_text().split()
    assert all(re.fullmatch(r"[0-9a-fA-F]{8}", w) for w in words)
    return b"".join(int(w, 16).to_bytes(4, "little") for w in words)


res = R / "AT050_FFREF0_reference_01/output"
rm = json.loads((res / "ffn_residual_reference_report.json").read_text())
products = {role: saved(res / Path(rec["rows4"]["path"]).name, rec["rows4"])
            for role, rec in rm["outputs"].items()}
skip = res / "enc0_skip_rows4.f32.bin"
ln = res / "enc0_ln_ffn_rows4.f32.bin"
down = res / "enc0_down_rows4.f32.bin"
final = res / "enc0_enc0_out_rows4.f32.bin"
src040 = R / "AT040_LNF0_ffn4_02/fixture/source_rows4.f32.bin"
mat = E / "results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures"
g = E / "results/compute_throughput_optimization_20261010/attempts/vector_wi_reference_01/reference/gate_f32.bin"
checks = {
    "at050_skip_equals_at040_source_four_rows": skip.read_bytes() == src040.read_bytes(),
    "at166_actual_source_decoded_equals_at050_skip_row0": decode("ln_source_row0.hex") == skip.read_bytes()[:4096],
    "at166_ln_decoded_equals_at050_ln_row0": decode("ln_gold_row0.hex") == ln.read_bytes()[:4096],
    "at166_wi_decoded_equals_saved_wi_row0": decode("final_row0.hex") == (mat / "wi_rows4_output_f32.bin").read_bytes()[:20992],
    "at166_g_decoded_equals_saved_independent_g": decode("g_row0.hex") == g.read_bytes(),
    "at166_down_decoded_equals_at050_down_row0": decode("down_final_row0.hex") == down.read_bytes()[:4096],
    "at050_down_equals_saved_matrix_down_four_rows": down.read_bytes() == (mat / "down_rows4_output_f32.bin").read_bytes(),
}
module = E / "vivado/module_design"
top_rel = "q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_lnq_wi_gqdown_row_v1.sv"
frozen_top = saved(at166 / "frozen/laya_lnq_wi_gqdown_row_v1.sv", m166["files"]["frozen/laya_lnq_wi_gqdown_row_v1.sv"])
current_top = identity(module / top_rel)
at093 = A / "AT093_SM004_vector_stream_01"
m093 = json.loads((at093 / "source_manifest.json").read_text())
add_sources = {n: saved(Path(m093["files"][n]["origin"]), m093["files"][n])
               for n in ("laya_vector_add_stream_v1.sv", "attention_ce_add.v")}
for name, p in (("skip.bin", skip), ("down.bin", down), ("gold.bin", final)):
    saved(p, m093["files"][name])
checks["at093_uses_same_at050_skip_down_final_products"] = True
assert all(checks.values()), checks

attempts = {}
for name in ("AT166_SM004_down_ret_pair_index_full_01", "AT168_SM004_wi_fp_reset_guard_epoch_02", "AT169_SM004_g_inflight_common_reset_01"):
    p = A / name
    guard = json.loads((p / "guard_rtl/guard_result.json").read_text())
    attempts[name] = {"manifest": identity(p / "source_manifest.json"),
                      "log": identity(p / "guard_rtl/driver.log"),
                      "guard": identity(p / "guard_rtl/guard_result.json"),
                      "measured": {k: guard[k] for k in ("elapsed_seconds", "peak_owned_rss_kb", "child_exit_code", "trigger")}}
log = (at166 / "guard_rtl/driver.log").read_text()
visible = [int(v) for v in re.findall(r"GQDOWN_ROW_VISIBLE cycle=(\d+)", log)]
spans = []
for v in visible:
    if spans and v == spans[-1][1] + 1:
        spans[-1][1] = v
    else:
        spans.append([v, v])
cmds = [{"cmd": int(c), "cycle": int(cyc)} for c, cyc in re.findall(r"GQDOWN_CMD_PASS cmd=(\d+) cycle=(\d+)", log)]
out = {
    "scope": "Read-only saved SHA/byte/layout/log checks; static design, no new RTL/gold/simulation/EDA",
    "checks": checks, "reference_report": identity(res / "ffn_residual_reference_report.json"),
    "at050_products": products, "row0": {"skip": row0(skip), "down": row0(down), "residual": row0(final)},
    "at166_fixtures": fixtures, "at166_manifest": identity(at166 / "source_manifest.json"),
    "additional_saved_sources": [identity(src040), identity(mat / "wi_rows4_output_f32.bin"), identity(mat / "down_rows4_output_f32.bin"), identity(g)],
    "add_manifest": identity(at093 / "source_manifest.json"), "add_sources": add_sources,
    "frozen_at166_top": frozen_top, "current_top_snapshot": current_top,
    "current_top_matches_at166": current_top["sha256"] == frozen_top["sha256"],
    "other_sources": [identity(module / "q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_lnq_wi_gqdown_row_v1_tb.sv"),
                      identity(module / "vector_and_ffn/rtl/laya_vector_residual_axi_v1.sv"),
                      identity(E / "hls/operators/vector_full_compute.cpp")],
    "attempts": attempts,
    "raw_at166_markers": {"row_valid_spans": spans, "cmd_pass": cmds,
                           "boundary": "Absolute TB markers, not cmd-handshake-to-row latency or II"},
    "proposed_counts_not_measurement": {"skip_bytes": 4096, "operand_holding_bytes": 8,
        "elements": 1024, "result_tiles": 128, "done_phase_width": 4,
        "residual_phase_code": 8, "no_stall_tail_cycle_budget": 2060},
    "sampling": {"process_seconds": time.perf_counter() - start,
        "maxrss_kib": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        "affinity": sorted(os.sched_getaffinity(0)), "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "interactive_reads_cumulative": "UNKNOWN; not backfilled as zero"},
}
Path(__file__).with_name("down_residual_binding_20261015.json").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"checks": checks, "current_top_matches_at166": out["current_top_matches_at166"], "row0": out["row0"], "sampling": out["sampling"]}, ensure_ascii=False, indent=2))
