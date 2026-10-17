#!/usr/bin/env python3
"""Recalculate the fixed B1/S128 full-pipeline necessary conditions.

Read-only inputs are identity checked. All timing figures are conditional
service calculations or explicitly identified isolated fixture observations.
No GGUF payload, simulator, HLS, or EDA tool is opened by this script.
"""

from __future__ import annotations

import hashlib
import json
import math
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESULT = ROOT / "results/cpu_embedding_q8_validation_20261010"
MANIFEST = ROOT / "build/model-cpu-embedding-ln-v4-20261010/manifest.json"
OLD_MANIFEST = ROOT / "build/model-attention-rtl-repair-20261008/manifest.json"
CONTROLLER = ROOT / "hls/control/full_forward_controller.cpp"
FROZEN = ROOT / "results/attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md"
OOC_SUMMARY = ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/results.md"
OOC_REPORT = ROOT / "results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_ooc_42/work/utilization.rpt"
Q8_JOINT_SOURCE = ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/q8_tm1tn8_joint_dma.cpp"
HOST_SOURCE = ROOT / "host/laya_host.cpp"
FRONT = RESULT / "attempts/cpu_front_rtl_03/phase_observations.json"
EXPECTED_SHA = {
    MANIFEST: "093bd662096f8c539529072d09d33f3b5a7f666125e21adaaf7ece20348c5915",
    CONTROLLER: "e570e2c8e44dffa7c06f62b0f14b8e18c213de482d25ab2c0e12f0fdf8678838",
}
FREQ_MHZ = (100, 150, 200)
GEOMETRIES = ((1, 8), (4, 8), (16, 8), (16, 16), (16, 24), (16, 32), (32, 16))


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def ms(cycles: int | float, mhz: int) -> float:
    return cycles / (mhz * 1000)


def ceildiv(a: int, b: int) -> int:
    return (a + b - 1) // b


def measured_case(name: str, kind: str) -> dict:
    path = RESULT / "attempts" / name / "work/vivado" / (
        f"tm1tn8_joint_dma_{kind}.sim/sim_1/behav/xsim/simulate.log"
    )
    raw = path.read_text()
    require(f"TM1TN8_JOINT_DMA_{kind.upper()}_PASS" in raw, f"missing PASS: {path}")
    services = []
    stages = []
    for line in raw.splitlines():
        if f"TM1TN8_JOINT_DMA_{kind.upper()}_SERVICE" in line:
            services.append({k: float(v) if "." in v else int(v)
                             for k, v in re.findall(r"([a-z][a-z0-9_]*)=(-?[0-9]+(?:\.[0-9]+)?)", line)})
        if f"TM1TN8_JOINT_DMA_{kind.upper()}_STAGE" in line:
            stages.append({k: float(v) if "." in v else int(v)
                           for k, v in re.findall(r"([a-z][a-z0-9_]*)=(-?[0-9]+(?:\.[0-9]+)?)", line)})
    require(services and stages, f"missing service/stage: {path}")
    return {"source": str(path.relative_to(ROOT)), "sha256": digest(path),
            "wrapper_accept_to_first_done_cycles": [v["done"] - v["accept"] for v in services],
            "run_tb_cycles": [v["run_tb_cycles"] for v in stages],
            "issue_span_cycles": [v["issue_span"] for v in stages],
            "issue_count": [v["issue_count"] for v in stages],
            "result_credit_stall_cycles": [v["result_credit_stall"] for v in stages]}


def main() -> None:
    for path, wanted in EXPECTED_SHA.items():
        require(digest(path) == wanted, f"input identity changed: {path}")
    manifest = json.loads(MANIFEST.read_text())
    require(manifest["tags"]["build"] == "147c8e8554927239ed5981bdde25861c",
            "current CPU-embedding build tag changed")
    require(digest(OLD_MANIFEST) ==
            "128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa",
            "historical comparison manifest changed")
    old = json.loads(OLD_MANIFEST.read_text())
    shape_fields = ("family", "K", "N", "dtype", "q_span", "scale_span", "bias_span")
    require([[w[k] for k in shape_fields] for w in manifest["weights"]] ==
            [[w[k] for k in shape_fields] for w in old["weights"]],
            "current versus historical Q8 geometry/byte extents changed")
    weights = manifest["weights"]
    q8 = [w for w in weights if w["dtype"] == 8]
    require(len(weights) == 124 and len(q8) == 122, "weight population changed")
    non_q8 = [(w["family"], w["name"], w["dtype"]) for w in weights if w["dtype"] != 8]
    require({f for f, _, _ in non_q8} == {10, 11}, "non-Q8 family changed")
    ctl = CONTROLLER.read_text()
    require("row += 16" in ctl and "Op::QUANT" in ctl and "Op::LOAD_W" in ctl,
            "controller task schedule changed")
    frozen = FROZEN.read_text()
    require("47160754688" in frozen and "1473773584" in frozen and
            "695816" in frozen and "158138376" in frozen,
            "frozen comparison changed")
    ooc = OOC_SUMMARY.read_text()
    require("tm1tn8_integer_tree" in ooc and "320" in ooc and "256" in ooc and
            "64" in ooc and "DSP458" in ooc, "OOC mapping evidence changed")
    require("DSPs" in OOC_REPORT.read_text() and "458" in OOC_REPORT.read_text(),
            "OOC utilization changed")

    family_names = {1: "encoder_qkv", 2: "encoder_wo", 3: "encoder_wi",
                    4: "encoder_down", 5: "decision_qkv", 6: "decision_wo",
                    7: "decision_fc1", 8: "decision_fc2", 9: "scorer_fc1",
                    12: "act_fc2"}
    rows_by_family = {f: (16 if f == 9 else 1 if f == 12 else 128)
                      for f in family_names}
    family = defaultdict(lambda: Counter())
    totals = Counter()
    matrix_records = []
    for w in q8:
        f, k, n = w["family"], w["K"], w["N"]
        require(f in rows_by_family and k % 32 == 0 and k > 0 and n > 0,
                f"unsupported Q8 shape: {w['name']}")
        rows, groups = rows_by_family[f], k // 32
        tiles = ceildiv(rows, 16)
        mac = rows * k * n
        dot = rows * n * groups
        quant = rows * groups
        padded_cols = ceildiv(n, 8) * 8
        require(w["scale_span"] == padded_cols * groups * 2, f"scale extent: {w['name']}")
        require(sum(w["q_span"]) == padded_cols * groups * 32,
                f"Q extent: {w['name']}")
        item = Counter(matrices=1, mac=mac, dot_groups=dot,
                       quant_groups=quant, quant_input_elements=rows * k,
                       output_elements=rows * n, quant_tasks=tiles,
                       linear_tasks=tiles, q0_bytes=w["q_span"][0],
                       q1_bytes=w["q_span"][1], scale_bytes=w["scale_span"],
                       bias_bytes=w["bias_span"],
                       scale_checks_padded=padded_cols * groups,
                       scale_checks_valid=n * groups)
        family[family_names[f]].update(item)
        totals.update(item)
        matrix_records.append((w, rows, groups))
    require(totals["mac"] == 47_160_754_688 and
            totals["dot_groups"] == 1_473_773_584 and
            totals["quant_groups"] == 695_816 and
            totals["quant_input_elements"] == 22_266_112 and
            totals["output_elements"] == 39_534_594 and
            (totals["q0_bytes"], totals["q1_bytes"], totals["scale_bytes"]) ==
            (184_682_496, 184_680_448, 23_085_184), "independent manifest totals differ")
    require(totals["quant_tasks"] == 962 and totals["linear_tasks"] == 962,
            "controller task count changed")
    require(totals["scale_checks_padded"] == 11_542_592 and
            totals["scale_checks_padded"] - totals["scale_checks_valid"] == 48,
            "padded scale validation changed")
    total_bytes = totals["q0_bytes"] + totals["q1_bytes"] + totals["scale_bytes"]
    output_bytes = 4 * totals["output_elements"]

    geometries = []
    for tm, tn in GEOMETRIES:
        issues = 0
        for w, rows, groups in matrix_records:
            # A controller task contains at most 16 rows; no cross-task packing.
            row0 = 0
            while row0 < rows:
                chunk = min(16, rows - row0)
                issues += ceildiv(chunk, tm) * ceildiv(w["N"], tn) * groups
                row0 += chunk
        channels = tm * tn
        issued_lanes = issues * channels
        valid = totals["dot_groups"]
        require(issued_lanes >= valid, "negative tail overhead")
        geometries.append({"TM": tm, "TN": tn, "dot_groups_per_clock_if_II1": channels,
                           "issued_vector_clocks": issues,
                           "valid_dot_groups": valid,
                           "padded_dot_group_slots": issued_lanes - valid,
                           "valid_lane_fraction": valid / issued_lanes,
                           "ideal_q8_ms_150mhz": ms(issues, 150),
                           "dsp_current_tree_and_r0_p1": channels * 48,
                           "dsp_tree_lut_unproven_p1": channels * 40,
                           "dsp_current_tree_and_r0_p2_unproven": channels * 32,
                           "dsp_tree_lut_and_p2_both_unproven": channels * 24})

    # Dense attention for 30 encoder/decision layers, 16 heads, 128x128, d=64.
    layers, heads, seq, head_dim = 30, 16, 128, 64
    scores = layers * heads * seq * seq
    qk = scores * head_dim
    av = qk
    qk_tree_add = scores * (head_dim - 1)
    softmax_rows = layers * heads * seq
    require((qk, av, scores, softmax_rows) ==
            (503_316_480, 503_316_480, 7_864_320, 61_440), "attention arithmetic changed")
    attn_dsp_clocks = 3 * (qk + av) + 2 * (qk_tree_add + av)
    ln_elements = (61 * seq + 16) * 1024
    geglu_elements = 28 * seq * 2624
    require((ln_elements, geglu_elements) == (8_011_776, 9_404_416),
            "vector arithmetic changed")

    measured = {
        "cold_front_B1_S128": {"source": str(FRONT.relative_to(ROOT)),
                                "sha256": digest(FRONT),
                                "first_done_from_reset_release_tb_cycles":
                                json.loads(FRONT.read_text())["first_done_tb_counter_cycles"],
                                "scope": "isolated cold front fixture; includes AXI/testbench/control holds"},
        "act_trace_off_two_runs": measured_case("task2_joint_dma_act_timing_103", "act"),
        "qkv_one_row_trace_off_two_runs": measured_case("task2_joint_dma_qkv_row1_cont_104", "qkv"),
        "qkv_four_rows_trace_off": measured_case("task2_joint_dma_qkv_rows4_reg_107", "qkv"),
        "qkv_one_row_trace_on": measured_case("task2_joint_dma_qkv_row1_on_108", "qkv"),
    }
    require(measured["cold_front_B1_S128"]["first_done_from_reset_release_tb_cycles"] == 31_158_417,
            "cold front observation changed")
    for key, expected in (("act_trace_off_two_runs", [3471, 3471]),
                          ("qkv_one_row_trace_off_two_runs", [18933, 18933]),
                          ("qkv_four_rows_trace_off", [65463]),
                          ("qkv_one_row_trace_on", [20797])):
        require(measured[key]["wrapper_accept_to_first_done_cycles"] == expected,
                f"fixture timing changed: {key}")

    h2d = 192_937_984 + 32_768
    d2h = 384
    # One FP restore channel has two FMUL (3 DSP each) and one FADD (2 DSP).
    # Observed OOC42 tree: 32 product DSP + 8 tree-add/PCIN DSP per channel.
    q8_dsp_work = {"observed_tree_p1": 48 * totals["dot_groups"],
                   "tree_lut_unproven_p1": 40 * totals["dot_groups"],
                   "observed_tree_p2_unproven": 32 * totals["dot_groups"],
                   "tree_lut_and_p2_both_unproven": 24 * totals["dot_groups"]}
    # Current scalar validation is budgeted at four clocks per padded scale
    # from the existing HLS schedule; 1/check is a separate future condition.
    scale_checks_four_cycle = totals["scale_checks_padded"] * 4
    weight_payload_cycles = (ceildiv(totals["q0_bytes"] + totals["q1_bytes"], 64)
                             + ceildiv(totals["scale_bytes"], 16))
    freq_rows = {}
    for f in FREQ_MHZ:
        ideal_q8_cycles = geometries[0]["issued_vector_clocks"]
        q8_tm1tn8 = ms(ideal_q8_cycles, f)
        q8_tm16tn16 = ms(next(g["issued_vector_clocks"] for g in geometries
                                if g["TM"] == 16 and g["TN"] == 16), f)
        freq_rows[str(f)] = {
            "q8_tm1tn8_ideal_ms": q8_tm1tn8,
            "q8_tm16tn16_ideal_ms": q8_tm16tn16,
            "q8_current_256_mac_division_only_ms": ms(ceildiv(totals["mac"], 256), f),
            "attention_qk_av_512lane_ideal_ms": ms(ceildiv(qk + av, 512), f),
            "quant_two_pass_8lane_ideal_ms": ms(ceildiv(2 * totals["quant_input_elements"], 8), f),
            "ln_three_pass_8lane_ideal_ms": ms(ceildiv(3 * ln_elements, 8), f),
            "geglu_4lane_ideal_ms": ms(ceildiv(geglu_elements, 4), f),
            "weight_q0_then_q1_64Bclk_ms": ms(ceildiv(totals["q0_bytes"] + totals["q1_bytes"], 64), f),
            "weight_scale_unpack_16Bclk_ms": ms(ceildiv(totals["scale_bytes"], 16), f),
            "scale_validation_1check_clk_ideal_ms": ms(totals["scale_checks_padded"], f),
            "scale_validation_current_scalar_4cycles_check_ms": ms(scale_checks_four_cycle, f),
            "serialized_q_scale_payload_plus_current_validation_ms":
                ms(weight_payload_cycles + scale_checks_four_cycle, f),
            "historical_32bit_out0_protocol_floor_ms": ms(ceildiv(output_bytes - 23_592_960, 4), f),
            "whole_graph_512bit_out0_if_migrated_payload_floor_ms":
                ms(ceildiv(output_bytes - 23_592_960, 64), f),
            "q8_dsp_only_lower_ms_9024":
                {key: ms(work / 9024, f) for key, work in q8_dsp_work.items()},
            "q8_plus_attention_shared_dsp_work_lower_ms_9024":
                {key: ms((work + attn_dsp_clocks) / 9024, f)
                 for key, work in q8_dsp_work.items()},
            "q8_plus_attention_independent_resource_serial_lower_ms_9024":
                {key: ms((math.sqrt(work) + math.sqrt(attn_dsp_clocks)) ** 2 / 9024, f)
                 for key, work in q8_dsp_work.items()},
            "q8_attention_independent_resource_pipeline_max_lower_ms_9024":
                {key: ms((work + attn_dsp_clocks) / 9024, f)
                 for key, work in q8_dsp_work.items()},
        }

    throughput = []
    for rps in (10, 20, 40):
        throughput.append({"B1_requests_per_second_example": rps,
                           "interarrival_interval_ms": 1000 / rps,
                           "required_q8_GMAC_per_second": totals["mac"] * rps / 1e9,
                           "required_valid_q8_MAC_per_clock_150mhz": totals["mac"] * rps / 150e6,
                           "required_attention_multiply_per_clock_150mhz":
                           (qk + av) * rps / 150e6,
                           "required_H2D_GB_per_second": h2d * rps / 1e9,
                           "required_q8_weight_load_GB_per_second": total_bytes * rps / 1e9,
                           "requires_cross_request_overlap_or_extra_context": True})

    out0 = output_bytes - 23_592_960
    require(out0 == 134_545_416 and output_bytes == 158_138_376,
            "QKV output-port split changed")
    joint_examples = []
    for tm, tn, attn_lanes, mapping in ((16, 8, 512, "observed_tree_p1"),
                                       (16, 16, 128, "observed_tree_p2_unproven"),
                                       (16, 16, 512, "tree_lut_and_p2_both_unproven")):
        q = next(g for g in geometries if (g["TM"], g["TN"]) == (tm, tn))
        dsp_per_channel = {"observed_tree_p1": 48,
                           "observed_tree_p2_unproven": 32,
                           "tree_lut_and_p2_both_unproven": 24}[mapping]
        q_dsp = tm * tn * dsp_per_channel
        a_dsp = attn_lanes * 5
        a_cycles = ceildiv(qk + av, attn_lanes)
        joint_examples.append({"TM": tm, "TN": tn, "attention_lanes": attn_lanes,
                               "mapping": mapping, "Q8_DSP": q_dsp,
                               "attention_DSP": a_dsp,
                               "bare_9024_DSP_remaining_before_quant_vector_shell": 9024 - q_dsp - a_dsp,
                               "Q8_plus_attention_serial_ideal_ms_150mhz":
                                   ms(q["issued_vector_clocks"] + a_cycles, 150),
                               "pipeline_independent_engines_max_ideal_ms_150mhz":
                                   ms(max(q["issued_vector_clocks"], a_cycles), 150),
                               "LN_GEGLU_quant_DSP_and_ports": "unallocated; nonzero physical cost"})
    selected_q8 = next(g for g in geometries if (g["TM"], g["TN"]) == (16, 8))
    softmax_three_scan_cycles = (ceildiv(scores, 8) + ceildiv(scores, 4)
                                 + ceildiv(scores, 8))
    av_feedback_cycles = ceildiv(av * 11, 16 * head_dim)
    selected_joint = {
        "status": "conditional arithmetic/service allocation, not physical resource PASS",
        "Q8_TM_TN": [16, 8], "Q8_channels": 128,
        "Q8_DSP_observed_tree_plus_R0": 128 * 48,
        "attention_QK_AV_shared_FP_lanes": 256,
        "attention_DSP_FMUL3_FADD2": 256 * 5,
        "vector_quant_LN_nonlinear_DSP_planning_reserve": 512,
        "control_bias_conversion_DSP_planning_reserve": 256,
        "total_planning_DSP": 128 * 48 + 256 * 5 + 512 + 256,
        "bare_9024_DSP_unreserved": 9024 - (128 * 48 + 256 * 5 + 512 + 256),
        "shell_and_actual_nonlinear_cost_unknown": True,
        "Q8_ideal_ms_150mhz": ms(selected_q8["issued_vector_clocks"], 150),
        "QK_plus_AV_F256_ideal_ms_150mhz": ms(ceildiv(qk + av, 256), 150),
        "softmax_8_4_8_three_scan_ideal_ms_150mhz":
            ms(softmax_three_scan_cycles, 150),
        "AV_partial_addresses_per_task": 16 * head_dim,
        "conditional_AV_safe_revisit_clocks": 11,
        "AV_feedback_max_contributions_per_clock_without_bypass_or_more_context":
            16 * head_dim / 11,
        "QK_plus_feedback_limited_AV_plus_softmax_ideal_ms_150mhz":
            ms(ceildiv(qk, 256) + av_feedback_cycles + softmax_three_scan_cycles, 150),
        "serialized_current_LOAD_plus_Q8_ideal_ms_150mhz":
            ms(weight_payload_cycles + scale_checks_four_cycle +
               selected_q8["issued_vector_clocks"], 150),
        "serialized_1check_clk_unimplemented_LOAD_plus_Q8_ideal_ms_150mhz":
            ms(weight_payload_cycles + totals["scale_checks_padded"] +
               selected_q8["issued_vector_clocks"], 150),
        "caveat": "AV revisit=11 is a conditional feedback model; more query/context or proven bypass may change it. LOAD is serialized with compute by current single W cache."}
    data = {
        "schema": "laya_b1_s128_pipeline_budget_recalculation_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "scope": "fixed B1/S128, 122 Q8 weights, current synchronous controller; offline necessary conditions",
        "source_identity": {str(path.relative_to(ROOT)): sha for path, sha in EXPECTED_SHA.items()},
        "other_evidence_identity": {
            str(path.relative_to(ROOT)): digest(path)
            for path in (OOC_SUMMARY, OOC_REPORT, Q8_JOINT_SOURCE, HOST_SOURCE, FRONT)},
        "current_model_tags": manifest["tags"],
        "comparison": {"frozen_joint_budget": str(FROZEN.relative_to(ROOT)),
                       "historical_manifest": str(OLD_MANIFEST.relative_to(ROOT)),
                       "historical_manifest_sha256": digest(OLD_MANIFEST),
                       "role": "cross-check only; current manifest and formulas generate totals"},
        "q8": {"families": {key: dict(value) for key, value in family.items()},
               "totals": dict(totals), "output_bytes": output_bytes,
               "weight_payload_bytes": total_bytes,
               "load_weight_commands": len(q8),
               "scale_validation": {
                   "padded_checks": totals["scale_checks_padded"],
                   "valid_lane_checks": totals["scale_checks_valid"],
                   "padded_extra_checks": 48,
                   "isolated_qkv_checks": 3072 * 32,
                   "current_scalar_loop_conditional_clocks_per_check": 4,
                   "current_scalar_loop_service_clocks": scale_checks_four_cycle,
                   "current_scalar_loop_service_ms_150mhz": ms(scale_checks_four_cycle, 150),
                   "source_order": "LOAD reads q0, q1, scales, then bias; validation checks padded scale n then g, followed by bias",
                   "one_check_per_clock_only_optimistic_assumption": True},
               "geometry": geometries,
               "current_tm1tn8_math_only_min_cycles": geometries[0]["issued_vector_clocks"],
               "tree_and_restore_dsp_per_channel": {
                   "observed_integer_tree_product": 32,
                   "observed_integer_tree_add_Pcin": 8,
                   "R0_two_FMUL3_one_FADD2": 8,
                   "observed_tree_plus_R0_p1": 48,
                   "LUT_tree_p1_unproven": 40,
                   "observed_tree_p2_unproven": 32,
                   "LUT_tree_p2_both_unproven": 24,
                   "i32_to_f32_and_PS_ports_per_channel": 1,
                   "FMUL_services_per_channel": 2,
                   "FADD_services_per_channel": 1}},
        "attention": {"layers": layers, "heads": heads, "queries_per_head": seq,
                      "keys_per_query": seq, "head_dim": head_dim,
                      "qk_multiplies": qk, "qk_tree_adds": qk_tree_add,
                      "av_multiplies": av, "av_adds": av,
                      "softmax_elements": scores, "softmax_rows": softmax_rows,
                      "conditional_FP_DSP_work_clocks": attn_dsp_clocks,
                      "excludes": "softmax exp/div, score scale, mask, fill/drain, KV/Q load and output"},
        "vector": {"LN_elements": ln_elements, "GEGLU_outputs": geglu_elements,
                   "residual_adds": 7_864_320, "decision_ReLU_elements": 1_048_576,
                   "type_adds": 131_072},
        "host": {"historical_host_source": "host/laya_host.cpp",
                 "historical_host_profile": "old 13-BO full-forward host; new CPU-raw producer path not integrated",
                 "session_model_upload_once_bytes": 448_923_648,
                 "request_workspace_clear_H2D_bytes": 192_937_984,
                 "request_IO_H2D_bytes": 32_768, "request_H2D_total_bytes": h2d,
                 "request_D2H_bytes": d2h, "one_in_flight_current_contract": True,
                 "new_CPU_raw_profile_status": "producer/descriptor and STATE0 import validated in isolated CPU/front-end; board Host lifecycle/transfer unimplemented",
                 "new_CPU_raw_bytes_B1_S128": 524_288,
                 "new_CPU_raw_descriptor_bytes": 256,
                 "raw_and_descriptor_are_inside_existing_STATE0_and_IO_BO_extents": True,
                 "incremental_H2D_bytes_cannot_be_added_without_new_host_contract": True,
                 "conditional_gen3x16_line_rate_GBps": 8 * 16 * 128 / 130 / 8,
                 "conditional_gen3x16_H2D_payload_floor_ms":
                     h2d / (8 * 16 * 128 / 130 / 8 * 1e6)},
        "memory_ports": {"q0_bytes": totals["q0_bytes"], "q1_bytes": totals["q1_bytes"],
                         "scale_bytes": totals["scale_bytes"], "out0_bytes": out0,
                         "out1_bytes": 23_592_960,
                         "historical_32bit_output_two_port_protocol_floor_ms_150mhz":
                             output_bytes / (2 * 4 * 150_000),
                         "output_port_scope": "32-bit floors are historical/protocol conditions, not the current Q35 local 512-bit pack/TX prototype. Whole-graph 512-bit output migration and on-chip consumption are unverified.",
                         "current_LOAD_order": "q0 then q1 then scale then bias read then padded-scale validation then bias validation",
                         "unimplemented_overlap_requirements":
                             ["W double buffering", "independent bank ownership and credit",
                              "whole-graph 512-bit output migration or validated on-chip consumption"]},
        "frequency_conditional_ideal_service": freq_rows,
        "joint_resource_examples": joint_examples,
        "joint_resource_selected_conditional": selected_joint,
        "resource_mapping_limit": "OOC42 measured an eight-lane tree (320 DSP), not the enlarged full-graph instance; 48 DSP/channel and joint allocation extrapolate that mapping and older FP coefficients. No physical/timing fit is shown.",
        "throughput_examples": throughput,
        "measured_isolated_fixtures": measured,
        "latency_and_pipeline_rules": {
            "current_synchronous_controller":
                "single request task order serializes LOAD, QUANT, LINEAR and stage tasks; sum nonoverlapped service",
            "serial_arithmetic_optimistic_example_150mhz_ms":
                freq_rows["150"]["q8_tm16tn16_ideal_ms"] +
                freq_rows["150"]["attention_qk_av_512lane_ideal_ms"],
            "independent_engine_pipeline_bound":
                "max(engine service times) only after proven overlap and per-request contexts; not current controller",
            "shared_resource_bound":
                "sum DSP work / (available DSP * realized clock), even if stages overlap",
            "50ms_interval_vs_latency":
                "20 B1/s is a throughput interval example; full request latency may differ",
            "unknown_or_unimplemented": ["realized Fmax and shell-available resources",
                "signed two-products-per-DSP packing and precision", "tree remap to LUT",
                "end-to-end full graph RTL service", "scale-check throughput",
                "W double buffering", "multi-request contexts", "vector/quant fusion",
                "Host BO lifecycle changes", "actual PCIe effective bandwidth"]}}
    RESULT.mkdir(parents=True, exist_ok=True)
    out = RESULT / "pipeline_budget.json"
    out.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print(f"WROTE {out}")
    print(f"Q8 MAC={totals['mac']} dot={totals['dot_groups']} quant={totals['quant_groups']}")
    print(f"Q8 weights={total_bytes} B scale_checks={totals['scale_checks_padded']} output={output_bytes} B")
    print(f"TM1TN8 ideal={freq_rows['150']['q8_tm1tn8_ideal_ms']:.6f} ms @150 MHz")
    print(f"TM16TN16 ideal={freq_rows['150']['q8_tm16tn16_ideal_ms']:.6f} ms @150 MHz")
    print(f"OOC42 tree=320 DSP/8 lane; integer+R0=48 DSP/channel p1")
    print("PASS: identities, frozen totals, fixture timing, and independent formulas")


if __name__ == "__main__":
    main()
