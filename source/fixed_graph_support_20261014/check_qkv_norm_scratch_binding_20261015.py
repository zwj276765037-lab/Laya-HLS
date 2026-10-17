"""Bounded saved-byte/source identity and integer address checks; no model math."""
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import struct
import time

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).with_name("qkv_norm_scratch_binding_20261015.json")
E = "project/E002_Laya_HLS/experiment/"
M = E + "vivado/module_design/"
Q = M + "q8_linear_and_restore/tm1tn8_gs32_512/"
A = "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/"
F = E + "results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/"
W109 = E + "results/cpu_embedding_q8_validation_20261010/attempts/task2_writer_q35_current_109/"
AT192 = A + "AT192_SM004_rev12_crossmode_ready_stall_recompile_01/"
AT194 = A + "AT194_SM004_rev12_crossmode_focused_recompile_01/"
AT193 = A + "AT193_SM004_rev12_qkv_ffn_switch_full_fix_01/"
AT195 = A + "AT195_SM004_rev12_qkv_ffn_focused_full_01/"
start = time.monotonic()
records = {}
checks = {}

def blob(path):
    return (ROOT / path).read_bytes()

def identity(path, offset=0, size=None):
    with (ROOT / path).open("rb") as f:
        f.seek(offset)
        data = f.read() if size is None else f.read(size)
    if size is not None:
        assert len(data) == size
    result = dict(path=path, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    if offset or size is not None:
        result["offset"] = offset
    records[path + (f"@{offset}:{size}" if size is not None else "")] = result
    return result

def check(key, condition):
    checks[key] = bool(condition)
    assert condition, key

writer = identity(Q + "rtl/tm1tn8_axi512_writer.sv")
wm = json.loads(blob(W109 + "input_manifest.json"))
decl = next(x for x in wm["inputs"] if x["path"].endswith("/tm1tn8_axi512_writer.sv"))
check("writer_matches_historical_109_manifest", (writer["sha256"], writer["bytes"]) == (decl["sha256"], decl["bytes"]))
for name in ("input_manifest.json", "work/xsim.log", "guard/guard_result.json"):
    identity(W109 + name)
check("109_log_has_pass_marker", wm["pass_marker"] in blob(W109 + "work/xsim.log").decode())
check("109_log_and_guard_match_manifest", all(identity(W109 + p)["sha256"] == wm[k]["sha256"] for k, p in (("xsim_log", "work/xsim.log"), ("guard_result", "guard/guard_result.json"))))

pairs = []
for path in (Q + "rtl/laya_lnq_wi_gqdown_row_v1.sv", M + "layernorm_engine/rtl/laya_lnq_row_v1.sv", M + "activation_quantizer/rtl/quant16_stream_row.sv", Q + "rtl/tm4tn8_sync_ps_front_v2.sv", Q + "rtl/tm4tn8_row_pipeline_v1.sv", Q + "rtl/tm4tn8_fp_restore_v1.sv", M + "hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv"):
    current = identity(path)
    copies = [identity(p + "frozen/" + Path(path).name) for p in (AT192, AT194)]
    eq = all(c["sha256"] == current["sha256"] for c in copies)
    check("same_192_194_" + Path(path).name, eq)
    pairs.append(dict(current=current, frozen=copies, equal=eq))
vector_path = M + "vector_and_ffn/rtl/laya_vector_residual_axi_v1.sv"
check("vector_matches_corrected_AT101", identity(vector_path)["sha256"] == identity(A + "AT101_SM004_vector_axi_4k_finite_02/frozen/laya_vector_residual_axi_v1.sv")["sha256"])
for path in (Q + "rtl/tm4tn8_axi512_writer_v1.sv", M + "activation_quantizer/rtl/geglu_gate_window_writer_v2.sv", E + "hls/common/laya_memory_map.cpp", E + "hls/control/full_forward_controller.cpp", Q + "tb/make_real_fixtures.py", AT192 + "source_manifest.json", AT194 + "source_manifest.json"):
    identity(path)
for p, compiled in ((AT193, AT192), (AT195, AT194)):
    manifest = json.loads(blob(p + "source_manifest.json"))
    identity(p + "source_manifest.json")
    check("compiled_manifest_" + manifest["attempt"], manifest["compiled_manifest_sha256"] == identity(compiled + "source_manifest.json")["sha256"])

row_results = []
full_final = blob(F + "qkv_rows4_output_f32.bin")
full_norm = blob(F + "qkv_rows4_source_f32.bin")
full_scatter = blob(F + "qkv_rows4_scatter_u32x4.bin")
for name in ("manifest.json", "qkv_rows4_output_f32.bin", "qkv_rows4_source_f32.bin", "qkv_rows4_scatter_u32x4.bin"):
    identity(F + name)
norm_parent = E + "results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/embedding_norm.f32.bin"
row0 = blob(F + "qkv_row1_output_f32.bin")
check("rows4_row0_equals_one_row_final", full_final[:12288] == row0)
for s in (0, 1):
    final = full_final[s * 12288:(s + 1) * 12288]
    norm = full_norm[s * 4096:(s + 1) * 4096]
    scatter = list(struct.iter_unpack("<4I", full_scatter[s * 49152:(s + 1) * 49152]))
    words = struct.unpack("<3072I", final)
    expected = []
    beats = {}
    for n, bits in enumerate(words):
        plane, feature = divmod(n, 1024)
        head, d = divmod(feature, 64)
        shard = head & 1
        offset = (((plane * 2 * 8 + head // 2) * 1024 + s) * 64 + d) * 4
        expected.append((shard, offset, bits, s))
        # Integer byte packing only, independent of any hardware simulation.
        key = (shard, offset // 64 * 64)
        if key not in beats:
            beats[key] = {}
        check(f"unique_row{s}_word{n}", offset % 64 not in beats[key])
        beats[key][offset % 64] = final[n * 4:n * 4 + 4]
    check(f"row{s}_saved_scatter_matches", scatter == expected)
    check(f"row{s}_all_qkv_beats_full_aligned_single_page", len(beats) == 192 and all(len(v) == 16 and a % 64 == 0 and a % 4096 + 64 <= 4096 for (_, a), v in beats.items()))
    check(f"row{s}_norm_matches_saved_parent", identity(norm_parent, s * 4096, 4096)["sha256"] == hashlib.sha256(norm).hexdigest())
    row_results.append(dict(row=s, final=identity(F + "qkv_rows4_output_f32.bin", s * 12288, 12288), norm=identity(F + "qkv_rows4_source_f32.bin", s * 4096, 4096), scatter=identity(F + "qkv_rows4_scatter_u32x4.bin", s * 49152, 49152), qkv_aw_w_b_per_shard=[sum(k[0] == j for k in beats) for j in (0, 1)], norm_aw_w_b=64, total_aw_w_b=256, norm_first_offset=s * 4096, norm_end_offset=(s + 1) * 4096, qkv_first_offset=min(k[1] for k in beats), qkv_end_offset=max(k[1] for k in beats) + 64))
# Collapse per-word internal assertions into one readable identity result.
unique_checks = [checks.pop(k) for k in list(checks) if k.startswith("unique_row")]
checks["row0_row1_6144_unique_word_positions"] = all(unique_checks)
full_span_end = (((2 * 2 * 8 + 7) * 1024 + 127) * 64 + 63) * 4 + 4
check("S128_qkv_span_fits_12MiB_per_shard", full_span_end <= 12 * 1024 * 1024)

cost = {}
for label, prefix in (("AT193", AT193), ("AT195", AT195)):
    identity(prefix + "sim_stdout.log")
    identity(prefix + "guard_rtl/guard_result.json")
    log = blob(prefix + "sim_stdout.log").decode()
    markers = [line for line in log.splitlines() if re.match(r"QKV_CMD_ACCEPT|QKV_ROW_VISIBLE|QKV_DONE|QKV_ROW_COLD_WARM_PASS|SWITCH_WRONG_WARM_PASS|SWITCH_FFN_ACCEPT|SWITCH_QKV_PREFIX_PASS|Fatal:", line)]
    cost[label] = dict(guard=json.loads(blob(prefix + "guard_rtl/guard_result.json")), markers=markers, final_lines=log.splitlines()[-4:])
data = dict(scope="Static identities and saved bytes/integer layouts only; no EDA, model math, new gold or simulation", checks=checks, source_pairs=pairs, rows=row_results, files=list(records.values()), structural_counts=dict(one_row_tiles=512, qkv_head_segments=48, norm_segments=1, flush_barriers=49, single_beat_axi_transactions=256, useful_bytes_per_row=16384, writer_existing_payload_bytes=160, existing_core_response_bytes=32, S128_effective_qkv_per_shard=786432, S128_effective_norm=524288, S128_qkv_relative_span_end=full_span_end, QKV_BO_per_shard=12582912, HIDDEN_region=8388608, S128_single_beat_transactions=32768, full_tensor_coverage_bits=128), historical_runtime=cost, sampling=dict(process_wall_seconds=time.monotonic()-start, maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss, affinity=sorted(os.sched_getaffinity(0)), nice=os.getpriority(os.PRIO_PROCESS, 0), interactive_reads="UNKNOWN"))
OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
print(json.dumps(dict(checks=len(checks), all_true=all(checks.values()), source_files=len(records), writer_sha=writer["sha256"], rows=row_results, counts=data["structural_counts"], sampling=data["sampling"]), ensure_ascii=False))
