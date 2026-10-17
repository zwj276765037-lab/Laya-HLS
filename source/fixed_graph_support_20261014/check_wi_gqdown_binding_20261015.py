"""Read saved bytes and identities only; no oracle, float arithmetic, or new gold."""
from pathlib import Path
import hashlib
import json
import time

ROOT = Path(__file__).resolve().parents[2]
E = ROOT / "project/E002_Laya_HLS/experiment"
A = E / "results/compute_throughput_optimization_20261010/attempts"
R = ROOT / "project/E005_full_request_performance/experiment_results/runs/R001/attempts"
OUT = Path(__file__).with_name("wi_gqdown_binding_20261015.json")
start = time.perf_counter()


def identity(p):
    p = Path(p)
    raw = p.read_bytes()
    return {"path": str(p.relative_to(ROOT)), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def saved(p, record):
    got = identity(p)
    assert got["sha256"] == record["sha256"] and got["bytes"] == record["bytes"], str(p)
    return got


def slice_id(p, size, layout):
    raw = p.read_bytes()[:size]
    assert len(raw) == size
    return {"path": str(p.relative_to(ROOT)), "offset": 0, "bytes": size,
            "sha256": hashlib.sha256(raw).hexdigest(), "layout": layout}


f = A / "t2_widown_av_fixtures_01/work/fixtures"
manifest = json.loads((f / "manifest.json").read_text())
cases = {c["name"]: c for c in manifest["cases"]}
products = {}
for name in ("wi_rows4", "down_rows4"):
    products[name] = {role: saved(f / (name + "_" + role + ".bin"), rec)
                      for role, rec in cases[name]["products"].items()}

g = A / "vector_wi_reference_01/reference"
gm = json.loads((g / "manifest.json").read_text())
ginput = A / "vector_wi_capture_run_01/work/capture/vector_enc0_wi_row0.f32.bin"
g_products = {n: saved(g / n, gm["products"][n])
              for n in ("gate_f32.bin", "gelu_steps_u32x10.bin")}
g_source = saved(ginput, gm["input"])
g_ref = saved(E / "vivado/module_design/vector_and_ffn/tb/vector_gelu_reference.py", gm["reference_source"])

ln_source = R / "AT040_LNF0_ffn4_02/fixture/source_rows4.f32.bin"
ln_gold = R / "AT040_LNF0_ffn4_02/fixture/gold_rows4.f32.bin"
wi_raw = (f / "wi_rows4_output_f32.bin").read_bytes()
g_raw = (g / "gate_f32.bin").read_bytes()
steps = (g / "gelu_steps_u32x10.bin").read_bytes()
down_source = (f / "down_rows4_source_f32.bin").read_bytes()
checks = {
    "at040_ln_gold_equals_wi_source_four_rows": ln_gold.read_bytes() == (f / "wi_rows4_source_f32.bin").read_bytes(),
    "wi_row0_equals_independent_g_input": wi_raw[:20992] == ginput.read_bytes(),
    "g_tenth_steps_equal_gate": b"".join(steps[i * 40 + 36:i * 40 + 40] for i in range(2624)) == g_raw,
    "independent_g_equals_down_source_row0": g_raw == down_source[:10496],
}

bridge = A / "t2_geglu_gate_quant_bridge_rtl_04/work/fixture"
bm = json.loads((bridge / "manifest.json").read_text())
bridge_products = {Path(r["path"]).name: saved(bridge / Path(r["path"]).name, r) for r in bm["outputs"]}
def mem_bytes(name, size):
    return b"".join(int(w, 16).to_bytes(size, "little") for w in (bridge / name).read_text().split())
checks.update({
    "bridge_wi_all_four_rows": mem_bytes("wi.mem", 4) == wi_raw,
    "bridge_g_all_four_rows": mem_bytes("gate.mem", 4) == down_source,
    "bridge_q_all_four_rows": mem_bytes("q.mem", 32) == (f / "down_rows4_a8_q.bin").read_bytes(),
    "bridge_scale_all_four_rows": mem_bytes("scale.mem", 2) == (f / "down_rows4_a8_scale.bin").read_bytes(),
})
row0 = {
    "pre_ln": slice_id(ln_source, 4096, "1024 little-endian F32"),
    "wi": slice_id(f / "wi_rows4_output_f32.bin", 20992, "5248 little-endian F32; x[0:2624], gate_operand[2624:5248]"),
    "g": slice_id(g / "gate_f32.bin", 10496, "2624 little-endian F32"),
    "g_steps": slice_id(g / "gelu_steps_u32x10.bin", 104960, "[column,10] little-endian u32; ordered_steps in G manifest"),
    "down_q": slice_id(f / "down_rows4_a8_q.bin", 2624, "[group82,32] signed int8"),
    "down_scale": slice_id(f / "down_rows4_a8_scale.bin", 164, "82 little-endian FP16 bit patterns"),
    "down_steps": slice_id(f / "down_rows4_steps_u32x6.bin", 2015232, "[group82,column1024,6] little-endian u32: dot,sa,sw,product,term,PS"),
    "down_final": slice_id(f / "down_rows4_output_f32.bin", 4096, "1024 little-endian F32; no bias"),
}
ds = (f / "down_rows4_steps_u32x6.bin").read_bytes()
last_ps = b"".join(ds[((81 * 1024 + col) * 6 + 5) * 4:((81 * 1024 + col) * 6 + 6) * 4] for col in range(1024))
checks["saved_down_last_group_ps_equals_final_row0"] = last_ps == (f / "down_rows4_output_f32.bin").read_bytes()[:4096]

res = R / "AT050_FFREF0_reference_01/output"
resm = json.loads((res / "ffn_residual_reference_report.json").read_text())
residual = {Path(rec["rows4"]["path"]).name:
            saved(res / Path(rec["rows4"]["path"]).name, rec["rows4"])
            for rec in resm["outputs"].values()}
checks["residual_skip_equals_at040_pre_ln_four_rows"] = (res / "enc0_skip_rows4.f32.bin").read_bytes() == ln_source.read_bytes()
checks["residual_ln_equals_at040_ln_four_rows"] = (res / "enc0_ln_ffn_rows4.f32.bin").read_bytes() == ln_gold.read_bytes()
checks["residual_down_equals_saved_down_four_rows"] = (res / "enc0_down_rows4.f32.bin").read_bytes() == (f / "down_rows4_output_f32.bin").read_bytes()
for name in ("enc0_skip_rows4.f32.bin", "enc0_enc0_out_rows4.f32.bin"):
    row0[name] = slice_id(res / name, 4096, "1024 little-endian F32; optional future residual, not part of proposed G/Q/Down service")
assert all(checks.values()), checks

module = E / "vivado/module_design"
source_paths = [
    "q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_lnq_wi_row_v1.sv",
    "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_ps_front_v2.sv",
    "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv",
    "q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_fp_restore_v1.sv",
    "hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv",
    "vector_and_ffn/rtl/geglu_canonical_core.sv",
    "vector_and_ffn/rtl/tanh_libm_canonical.sv",
    "vector_and_ffn/rtl/geglu_canonical_row_adapter.sv",
    "vector_and_ffn/rtl/geglu_row_bank_v1.sv",
    "layernorm_engine/rtl/laya_lnq_row_v1.sv",
    "activation_quantizer/rtl/quant16_stream_row.sv",
    "q8_linear_and_restore/tm1tn8_gs32_512/tb/make_widown_v4_fixtures.py",
]
sources = [identity(module / p) for p in source_paths]
core = next(x for x in sources if x["path"].endswith("/geglu_canonical_core.sv"))
assert core["sha256"] == "01f88f430070c9430e05487dfc775e53c2daa5bceb65395ecfab0ad1e851f000"
result = {
    "scope": "Saved-byte/SHA/layout checks only; no oracle import, floating-point arithmetic, generated expected values, EDA or simulation",
    "manifests": [identity(f / "manifest.json"), identity(g / "manifest.json"), identity(bridge / "manifest.json"), identity(res / "ffn_residual_reference_report.json")],
    "sources": sources, "g_reference_source": g_ref, "g_input": g_source,
    "matrix_products": products, "independent_g_products": g_products,
    "bridge_products": bridge_products, "residual_products": residual,
    "checks": checks, "row0": row0,
    "down_model_record": cases["down_rows4"]["model_record"],
    "static_counts": {"g_pairs": 2624, "g_pair_tile_reads": 656, "q_groups": 82, "q_halves": 164,
        "q_row_bytes": 2788, "q_row_growth_bytes": 1700,
        "down_tiles": 128, "down_stripes": 10496, "down_ps_lane_groups": 83968,
        "down_macs": 2686976, "down_final_bytes": 4096,
        "down_w_payload_bytes": 2854912, "down_w_payload_64B_beats": [20992,20992,2624],
        "wi_down_w_payload_bytes": 8564736},
    "process_seconds": time.perf_counter() - start,
}
OUT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"checks": checks, "row0": row0, "process_seconds": result["process_seconds"]}, ensure_ascii=False, indent=2))
