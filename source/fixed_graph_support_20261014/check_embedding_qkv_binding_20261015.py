"""Saved-byte identities and integer layouts only; no oracle/model/new gold."""
from pathlib import Path
import hashlib
import json
import os
import re
import resource
import struct
import time

ROOT = Path(__file__).resolve().parents[2]
E = ROOT / "project/E002_Laya_HLS/experiment"
A = ROOT / "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts"
start = time.perf_counter()


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def ident(p):
    raw = p.read_bytes()
    return {"path": str(p.relative_to(ROOT)), "bytes": len(raw), "sha256": digest(raw)}


def saved(p, rec):
    got = ident(p)
    assert (got["bytes"], got["sha256"]) == (rec["bytes"], rec["sha256"]), str(p)
    return got


def window(p, offset, size):
    with p.open("rb") as f:
        f.seek(offset)
        raw = f.read(size)
    assert len(raw) == size
    return raw, {"path": str(p.relative_to(ROOT)), "offset": offset, "bytes": size, "sha256": digest(raw)}


f = E / "results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures"
fm = json.loads((f / "manifest.json").read_text())
cases = {c["name"]: c for c in fm["cases"] if c["name"].startswith("qkv")}
products = {name: {role: saved(f / Path(rec["path"]).name, rec) for role, rec in c["products"].items()}
            for name, c in cases.items()}
assert fm["session"] == {"request_id": 3, "generation": 1, "B": 1, "S": 128}
prepath = A / "AT091_SM004_full_software_b1_04/preflight.json"
pre = json.loads(prepath.read_text())
prerecs = {Path(rec["path"]).name: rec for rec in pre["files"]}
oracle = E / "results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128"
orecs = {Path(rec["path"]).name: rec for rec in pre["oracle_files"]}
oracle_ids = {n: saved(oracle / n, orecs[n]) for n in ("embedding_raw.f32.bin", "embedding_norm.f32.bin")}
raw = (oracle / "embedding_raw.f32.bin").read_bytes()
norm = (oracle / "embedding_norm.f32.bin").read_bytes()
statep = E / "results/compute_throughput_optimization_20261010/attempts/new_raw_B1_from_b0_S128_production_02/work/state0.bin"
stateid = saved(statep, prerecs["state0.bin"])
state_raw, state_slice = window(statep, 0, 128 * 4096)
v4m = E / "build/model-cpu-embedding-ln-v4-20261010"
curm = E / "build/model-current-production-v2-20261011"
req4m = E / "build/cpu-embedding-requests-v4-20261010/identity_manifest.json"
r4 = json.loads(req4m.read_text())
r4rec = next(x for x in r4["requests"] if x["name"] == "B1_from_b0_S128")
req4 = E / r4rec["target"]
assert ident(req4)["sha256"] == r4rec["target_sha256"]
reqcur = E / "build/current-production-requests-v2-20261011/B1_from_b0_S128.request.bin"
curreqid = saved(reqcur, prerecs["B1_from_b0_S128.request.bin"])
curauxid = saved(curm / "aux.bin", prerecs["aux.bin"])
gamma, gamma_id = window(curm / "aux.bin", 128, 4096)
gamma4, gamma4_id = window(v4m / "aux.bin", 128, 4096)
assert digest(gamma) == "dfb0f4aaaedeb189d0698f68603641bf325c60b9857ecb19a5f9fe4f9df0aa2d"

checks = {
    "at091_cpu_raw_state0_full_B1S128_equals_independent_embedding_raw": state_raw == raw,
    "qkv_fixture_source_parent_equals_at091_norm_oracle": ident(oracle / "embedding_norm.f32.bin")["sha256"] == cases["qkv_row1"]["source"]["sha256"],
    "qkv_row1_source_equals_norm_row0": (f / "qkv_row1_source_f32.bin").read_bytes() == norm[:4096],
    "qkv_rows4_source_equals_norm_first4": (f / "qkv_rows4_source_f32.bin").read_bytes() == norm[:16384],
    "gamma_v4_equals_at091_current_package": gamma4 == gamma,
}
model_windows = {}
for role, fname, size in (("q0", "w_q0.bin", 1572864), ("q1", "w_q1.bin", 1572864), ("w_scale", "w_scale.bin", 196608)):
    cur, curid = window(curm / fname, 0, size)
    old, oldid = window(v4m / fname, 0, size)
    reference = (f / ("qkv_row1_" + role + ".bin")).read_bytes()
    checks[role + "_v4_current_saved_independent_equal"] = cur == old == reference
    model_windows[role] = {"current": curid, "v4": oldid,
        "current_parent_declared_by_at091_not_rehashed": prerecs[fname]}

q0 = (f / "qkv_row1_q0.bin").read_bytes()
q1 = (f / "qkv_row1_q1.bin").read_bytes()
ws = (f / "qkv_row1_w_scale.bin").read_bytes()
canonical = bytearray()
for n in range(3072):
    tile, lane = divmod(n, 8)
    for g in range(32):
        qi = (((tile // 2) * 32 + g) * 8 + lane) * 32
        si = ((tile * 32 + g) * 8 + lane) * 2
        canonical += ws[si:si+2] + (q1 if tile & 1 else q0)[qi:qi+32]
checks["reconstructed_Q8_0_bytes_equal_original_weight_sha"] = digest(canonical) == "83723a85bf4b54a5399d4452c64eb446246f7d7af04d48bbc3e9d81314564dfe"
for role in ("source_f32", "a8_q", "a8_scale", "steps_u32x6", "output_f32"):
    one = (f / ("qkv_row1_" + role + ".bin")).read_bytes()
    four = (f / ("qkv_rows4_" + role + ".bin")).read_bytes()
    checks[role + "_row0_same_in_rows1_and_rows4"] = four[:len(one)] == one
steps = (f / "qkv_row1_steps_u32x6.bin").read_bytes()
final = (f / "qkv_row1_output_f32.bin").read_bytes()
last_ps = b"".join(steps[((31 * 3072 + n) * 6 + 5) * 4:((31 * 3072 + n) * 6 + 6) * 4] for n in range(3072))
checks["last_group_saved_PS_equals_all3072_final"] = last_ps == final
scatter = (f / "qkv_row1_scatter_u32x4.bin").read_bytes()
scatter_ok = True
for n in range(3072):
    plane, rem = divmod(n, 1024)
    head, d = divmod(rem, 64)
    off = ((((plane * 2) * 8 + head // 2) * 1024) * 64 + d) * 4
    record = struct.unpack_from("<4I", scatter, 16 * n)
    scatter_ok &= record == (head & 1, off, int.from_bytes(final[n*4:n*4+4], "little"), 0)
checks["saved_scatter_matches_production_head_parity_stride"] = bool(scatter_ok)
assert all(checks.values()), checks

p1 = E / "results/engineering_p1/20261007T021236Z-1800667/fixture/cases/qkv_ln_rows1"
p1_ids = [ident(p1 / n) for n in ("input_f32.bin", "gamma_f32.bin", "dut.ln.bin", "dut.ln_stats.bin", "dut.q8.bin")]
p1_compare = {"input_equals_selected_row0": (p1 / "input_f32.bin").read_bytes() == raw[:4096],
    "gamma_equals_model": (p1 / "gamma_f32.bin").read_bytes() == gamma,
    "ln_equals_norm_row0": (p1 / "dut.ln.bin").read_bytes() == norm[:4096],
    "scope": "P1 retains its own request/oracle history even if a row is byte-identical"}
p1q = (p1 / "dut.q8.bin").read_bytes()
assert len(p1q) == 32 * 34
p1_compare["packed_q_equals_qkv_row0_independent_q"] = b"".join(p1q[i*34+2:(i+1)*34] for i in range(32)) == (f / "qkv_row1_a8_q.bin").read_bytes()
p1_compare["packed_scale_equals_qkv_row0_independent_scale"] = b"".join(p1q[i*34:i*34+2] for i in range(32)) == (f / "qkv_row1_a8_scale.bin").read_bytes()
module = E / "vivado/module_design"
rels = ["q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_lnq_wi_gqdown_row_v1.sv",
        "layernorm_engine/rtl/laya_lnq_row_v1.sv", "layernorm_engine/rtl/laya_ln_row_v1.sv",
        "activation_quantizer/rtl/quant16_stream_row.sv",
        "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_ps_front_v2.sv",
        "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv",
        "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_fp_restore_v1.sv",
        "hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv",
        "vector_and_ffn/rtl/geglu_canonical_core.sv",
        "vector_and_ffn/rtl/laya_vector_add_stream_v1.sv",
        "attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv"]
sources = [ident(module / n) for n in rels]
at173dirs = list(A.glob("AT173*"))
assert len(at173dirs) == 1
at173 = at173dirs[0]
source_comparison = []
for rec in sources:
    name = Path(rec["path"]).name
    frozen = at173 / "frozen" / ("ln_add_stream.sv" if name == "laya_vector_add_stream_v1.sv" else name)
    source_comparison.append({"source": rec, "at173_frozen": ident(frozen) if frozen.exists() else None,
        "same_as_at173": ident(frozen)["sha256"] == rec["sha256"] if frozen.exists() else None})
row_ids = {}
for name, p, offset, size in (("raw_row0", oracle / "embedding_raw.f32.bin", 0, 4096),
                            ("norm_row0", oracle / "embedding_norm.f32.bin", 0, 4096),
                            ("raw_row1", oracle / "embedding_raw.f32.bin", 4096, 4096),
                            ("final_row1", f / "qkv_rows4_output_f32.bin", 12288, 12288)):
    _, row_ids[name] = window(p, offset, size)
out = {"scope": "Saved-byte/SHA/integer layout inspection; no oracle import, floating arithmetic, new gold, EDA or simulation",
    "session": fm["session"], "checks": checks, "fixture_manifest": ident(f / "manifest.json"),
    "fixture_products": products, "qkv_record": cases["qkv_row1"]["model_record"],
    "reference_sources": [saved(E / "tests/full_reference.py", fm["oracle_source"]),
        saved(module / "q8_linear_and_restore/tm1tn8_gs32_512/tb/make_real_fixtures.py", fm["generator_source"])],
    "at091_preflight": ident(prepath), "at091_receipt": ident(A / "AT091_SM004_full_software_b1_04/receipt.json"),
    "oracle": oracle_ids, "cpu_state0": stateid, "cpu_raw_slice": state_slice,
    "requests": {"v4_manifest": ident(req4m), "v4": ident(req4), "at091": curreqid,
        "wire_equal": req4.read_bytes() == reqcur.read_bytes(), "boundary": "Same semantic B1/S128 request3/gen1 and checked payloads; distinct package/build/wire identities retained"},
    "model_windows": model_windows, "gamma_current": gamma_id, "gamma_v4": gamma4_id,
    "current_aux_parent": curauxid,
    "headers": [ident(curm / "laya_model_layout_generated.h"), ident(v4m / "laya_model_layout_generated.h")],
    "row_slices": row_ids, "p1_ids": p1_ids, "p1_comparison": p1_compare,
    "source_snapshots": source_comparison,
    "graph_sources": [ident(E / "hls/control/full_forward_controller.cpp"), ident(E / "hls/common/laya_cpu_embedding_io.cpp"), ident(E / "hls/operators/rope_full_compute.cpp")],
    "historical_matrix_measurement": {"scope": "Old four-row prequantized stream replay, no LN/cold W/current wrapper",
        "log": ident(E / "results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_qkv_lut_full_01/guard/driver.log"),
        "guard": ident(E / "results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_qkv_lut_full_01/guard/guard_result.json"),
        "raw_guard": json.loads((E / "results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_qkv_lut_full_01/guard/guard_result.json").read_text())},
    "structural_counts_not_measurement": {"qkv_groups": 32, "qkv_tiles": 384, "row_stripes": 12288,
        "row_lane_group_PS": 98304, "qkv_row_bytes": 12288, "normalized_skip_row_bytes": 4096,
        "combined_existing_bank_tiles": 512, "matrix_payload_bytes": 3342336,
        "payload_beats64": [24576, 24576, 3072], "S128_QKV_bytes": 1572864,
        "S128_norm_skip_bytes": 524288, "S128_row_stripes": 1572864,
        "independent_QKV_rows_saved_here": 4},
    "sampling": {"process_seconds": time.perf_counter() - start,
        "maxrss_kib": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
        "affinity": sorted(os.sched_getaffinity(0)), "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "interactive_reads_cumulative": "UNKNOWN"}}
Path(__file__).with_name("embedding_qkv_binding_20261015.json").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"checks": checks, "p1_comparison": p1_compare, "row_slices": row_ids,
    "source_matches_at173": {Path(r["source"]["path"]).name: r["same_as_at173"] for r in source_comparison},
    "sampling": out["sampling"]}, ensure_ascii=False, indent=2))
