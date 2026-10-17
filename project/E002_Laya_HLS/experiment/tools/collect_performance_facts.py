#!/usr/bin/env python3
"""Collect reproducible F0 performance evidence without running hardware tools.

The row-level schedule is reconstructed from the current controller source. Its
aggregate counts are checked against the production CPU trace metadata; rows
are not presented as hardware-measured events or cycle measurements.
"""

from __future__ import annotations

import csv
import hashlib
import json
import math
import re
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "results/performance_estimate_20261008"
ARCHIVE = ROOT / "results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1"
HLS = ARCHIVE / "csynth_full/artifacts/reports"
RTL = ARCHIVE / "csynth_full/artifacts/rtl_verilog"
VIVADO = ROOT / "vivado/project/build/20261008T022231Z-2961016"
HIER = VIVADO / "reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt"
TRACE = ARCHIVE / "cpu_full/dut/dut"


def relative(path: Path) -> str:
    return str(path.relative_to(ROOT))


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def write_json(name: str, data: object) -> None:
    (OUT / name).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


def xml_value(node: ET.Element | None) -> object:
    if node is None:
        return None
    children = list(node)
    if not children:
        return node.text.strip() if node.text else None
    if len(children) == 1 and children[0].tag == "range":
        return {x.tag: xml_value(x) for x in children[0]}
    return {x.tag: xml_value(x) for x in children}


def hls_reports() -> dict:
    reports = {}
    for path in sorted(HLS.glob("*_csynth.xml")):
        root = ET.parse(path).getroot()
        perf = root.find("PerformanceEstimates")
        summary = perf.find("SummaryOfOverallLatency") if perf is not None else None
        report = {
            "source": relative(path),
            "source_sha256": sha256(path),
            "target_clock_ns": xml_value(root.find("UserAssignments/TargetClockPeriod")),
            "estimated_clock_ns": xml_value(root.find("PerformanceEstimates/SummaryOfTimingAnalysis/EstimatedClockPeriod")),
            "overall_latency": {x.tag: xml_value(x) for x in summary} if summary is not None else None,
            "loops": [],
        }
        rpt = path.with_suffix(".rpt")
        if rpt.exists():
            report["text_report"] = relative(rpt)
            report["text_report_sha256"] = sha256(rpt)

        def loops(node: ET.Element, parents: tuple[str, ...] = ()) -> None:
            for child in node:
                if not child.tag.startswith("VITIS_LOOP_"):
                    continue
                record = {
                    "name": child.tag,
                    "path": list(parents + (child.tag,)),
                    "trip_count": xml_value(child.find("TripCount")),
                    "latency_cycles": xml_value(child.find("Latency")),
                    "iteration_latency_cycles": xml_value(child.find("IterationLatency")),
                    "performance_pragma": xml_value(child.find("PerformancePragma")),
                }
                report["loops"].append(record)
                loops(child, parents + (child.tag,))

        loop_root = root.find("PerformanceEstimates/SummaryOfLoopLatency")
        if loop_root is not None:
            loops(loop_root)
        reports[path.stem.replace("_csynth", "")] = report
    return {"schema": "laya_hls_report_facts_v1", "report_count": len(reports), "reports": reports}


def trace_metadata() -> dict:
    scenarios = {}
    for name in ("B2_S128", "B1_from_b0_S128", "B1_from_b1_S128"):
        path = TRACE / name / "metadata.json"
        data = json.loads(path.read_text())
        assert data["tags"]["build"] == "04934c15b3f83e842ec2e92ac2a81bf2"
        scenarios[name] = {
            "source": relative(path), "source_sha256": sha256(path),
            "B": data["B"], "S": data["S"],
            "request_id": data["request_id"], "tags": data["tags"],
            "observed_counts": data["observed_counts"],
            "design_expected_counts": data["design_expected_counts"],
        }
    return {"schema": "laya_production_trace_aggregates_v1", "scenarios": scenarios}


def weight_facts(traces: dict) -> dict:
    path = ROOT / "build/model-repair/manifest.json"
    manifest = json.loads(path.read_text())
    weights = []
    per_scenario = {}
    for scenario, trace in traces["scenarios"].items():
        B = trace["B"]
        by_family: dict[str, dict] = defaultdict(lambda: {
            "weight_count": 0, "task_calls": 0, "output_elements": 0,
            "output_groups": 0, "int8_macs": 0, "declared_load_bytes": 0,
            "group_loop_cycles_179": 0, "group_loop_cycles_199": 0,
            "inner_mac_loop_cycles_160": 0,
        })
        for w in manifest["weights"]:
            if w["dtype"] != 8:
                continue
            family, K, N = w["family"], w["K"], w["N"]
            rows = (16 if family == 9 else 1 if family == 12 else trace["S"]) * B
            groups = K // 32
            output_elements = rows * N
            group_iterations = output_elements * groups
            load_bytes = ((N + 7) & ~7) * groups * 34
            bucket = by_family[str(family)]
            bucket["weight_count"] += 1
            bucket["task_calls"] += B * math.ceil((rows // B) / 16)
            bucket["output_elements"] += output_elements
            bucket["output_groups"] += group_iterations
            bucket["int8_macs"] += output_elements * K
            bucket["declared_load_bytes"] += load_bytes
            bucket["group_loop_cycles_179"] += group_iterations * 179
            bucket["group_loop_cycles_199"] += group_iterations * 199
            bucket["inner_mac_loop_cycles_160"] += group_iterations * 160
        total = {key: sum(v[key] for v in by_family.values()) for key in next(iter(by_family.values()))}
        per_scenario[scenario] = {"by_family": dict(by_family), "total": total}
        assert total["weight_count"] == 122
        assert total["task_calls"] == trace["observed_counts"]["q8_linear_tiles"]
        assert total["declared_load_bytes"] == sum(
            ((w["N"] + 7) & ~7) * (w["K"] // 32) * 34
            for w in manifest["weights"] if w["dtype"] == 8
        )
    for w in manifest["weights"]:
        weights.append({k: w.get(k) for k in (
            "name", "family", "layer", "K", "N", "dtype", "q_span",
            "scale_span", "aux_span", "bias_span"
        )})
    return {
        "schema": "laya_model_weight_and_q8_work_v1",
        "source": relative(path), "source_sha256": sha256(path),
        "weight_count": len(weights), "weights": weights,
        "q8_group_loop_evidence": {
            "report": relative(HLS / "p_anonymous_namespace_compute_one_csynth.xml"),
            "source_code": "hls/operators/q8_linear_compute.cpp:65",
            "inner_trip": 32, "inner_latency_cycles": 160,
            "group_iteration_latency_cycles_min": 179,
            "group_iteration_latency_cycles_max": 199,
            "full_function_latency": "undefined_in_HLS_report",
            "interpretation": "Only the Q8 arithmetic group-loop component; not full task or request latency.",
        },
        "scenarios": per_scenario,
    }


def schedule_rows(name: str, trace: dict, weights: list[dict]) -> list[dict]:
    B, S = trace["B"], trace["S"]
    rows: list[dict] = []

    def add(op: str, stage: int, layer: int, b: int = 0, row0: int = 0,
            count_rows: int = 1, head: int = 255, K: int | None = None,
            N: int | None = None, length: int | None = None,
            source: str = "", bytes_declared: int | None = None,
            family: int | None = None, substage: str = "") -> None:
        rows.append({"scenario": name, "op": op, "stage": stage,
                     "layer": layer, "batch": b, "row0": row0,
                     "rows": count_rows, "head": head, "K": K, "N": N,
                     "length": length, "family": family,
                     "substage": substage, "declared_bytes": bytes_declared,
                     "source_anchor": source,
                     "provenance": "controller_source_reconstruction_validated_by_op_counts"})

    def tile(op: str, stage: int, layer: int, width: int | None = None,
             head: int = 255, substage: str = "", source: str = "") -> None:
        for b in range(B):
            for row0 in range(0, S, 16):
                add(op, stage, layer, b, row0, 16, head,
                    length=width, substage=substage, source=source)

    # Front and layer-normalization graph.
    for b in range(B):
        for row0 in range(0, S, 16):
            add("EMB_TOKEN", 1, 255, b, row0, 16, length=1024,
                source="hls/control/full_forward_controller.cpp:119-133")
    add("LOAD_LN_PARAMS", 1, 255, bytes_declared=4096,
        source="hls/control/full_forward_controller.cpp:86-99")
    for op, stage, layers, width, substage, anchor in (
        ("LN_EMB", 1, [255], 1024, "", "hls/control/full_forward_controller.cpp:546-552"),
        ("LN_ATTN", 2, list(range(1, 28)), 1024, "", "hls/control/full_forward_controller.cpp:568-576"),
        ("LN_FFN", 2, list(range(28)), 1024, "", "hls/control/full_forward_controller.cpp:594-600"),
        ("LN_FINAL", 3, [255], 1024, "", "hls/control/full_forward_controller.cpp:619-625"),
        ("LN_ATTN", 4, [0, 1], 1024, "", "hls/control/full_forward_controller.cpp:639-643"),
        ("LN_FFN", 4, [0, 1], 1024, "", "hls/control/full_forward_controller.cpp:658-665"),
    ):
        for layer in layers:
            tile(op, stage, layer, width, substage=substage, source=anchor)
    add("LOAD_LN_PARAMS", 3, 255, bytes_declared=4096,
        source="hls/control/full_forward_controller.cpp:86-99")
    used_types = [2, 0] if name == "B2_S128" else [2] if name == "B1_from_b0_S128" else [0]
    for type_id in used_types:
        add("EMB_TYPE", 3, 255, length=1024, substage=f"type_id={type_id}",
            source="hls/control/full_forward_controller.cpp:397-413")
    tile("ADD_TYPE", 3, 255, 1024, source="hls/control/full_forward_controller.cpp:414-421")

    # One Q8 load per descriptor, with quantize/linear per 16-row tile.
    family_op = {1: "LIN_QKV", 2: "LIN_WO", 3: "LIN_WI", 4: "LIN_DOWN",
                 5: "LIN_QKV", 6: "LIN_WO", 7: "LIN_DEC_FC1",
                 8: "LIN_DEC_FC2", 9: "LIN_SCORER_FC1", 12: "LIN_ACT_FC2"}
    for w in weights:
        if w["dtype"] != 8:
            continue
        family, K, N, layer = w["family"], w["K"], w["N"], w["layer"]
        stage = 2 if family < 5 else 4 if family < 9 else 5 if family == 9 else 6
        load_bytes = ((N + 7) & ~7) * (K // 32) * 34
        add("LOAD_W", stage, layer, family=family, K=K, N=N,
            bytes_declared=load_bytes,
            source="hls/control/full_forward_controller.cpp:100-115")
        source_rows = 16 if family == 9 else 1 if family == 12 else S
        for b in range(B):
            for row0 in range(0, source_rows, 16):
                actual_rows = min(16, source_rows - row0)
                for op in ("QUANT", family_op[family]):
                    add(op, stage, layer, b, row0, actual_rows,
                        K=K, N=N, family=family,
                        source="hls/control/full_forward_controller.cpp:219-249")

    # Attention, RoPE, vector and residual calls.
    for stage, layers in ((2, range(28)), (4, range(2))):
        for layer in layers:
            if stage == 2:
                add("LOAD_ROPE", stage, layer, bytes_declared=2 * 1025 * 64 * 4,
                    source="hls/control/full_forward_controller.cpp:260-273")
                for head in range(16):
                    tile("ROPE", stage, layer, 64, head,
                         source="hls/control/full_forward_controller.cpp:276-291")
            for head in range(16):
                add("LOAD_KV", stage, layer, head=head,
                    bytes_declared=2 * B * S * 64 * 4,
                    source="hls/control/full_forward_controller.cpp:309-319")
                for op in ("QK", "SOFTMAX_ATT", "AV"):
                    tile(op, stage, layer, 128 if op == "SOFTMAX_ATT" else 64,
                         head, source="hls/control/full_forward_controller.cpp:321-359")
            for substage in ("attention", "ffn"):
                tile("ADD_RESIDUAL", stage, layer, 1024, substage=substage,
                     source="hls/control/full_forward_controller.cpp:390-396")
            if stage == 2:
                tile("GEGLU", stage, layer, 2624,
                     source="hls/control/full_forward_controller.cpp:605-610")
            else:
                tile("RELU", stage, layer, 4096,
                     source="hls/control/full_forward_controller.cpp:667-673")

    # Final marker/scorer/action phases.
    for b in range(B):
        for op, stage, row_count, length, anchor in (
            ("GATHER_MARKER", 5, 16, 1024, "hls/control/full_forward_controller.cpp:450-468"),
            ("LN_MARKER", 5, 16, 1024, "hls/control/full_forward_controller.cpp:688-695"),
            ("BIAS_GELU_SCORER", 5, 16, 1024, "hls/control/full_forward_controller.cpp:714-720"),
            ("FP_SCORER_FC2", 5, 16, 1024, "hls/control/full_forward_controller.cpp:724-728"),
            ("APPLY_CAND_MASK", 5, 1, 16, "hls/control/full_forward_controller.cpp:473-480"),
            ("SOFTMAX_CAND", 6, 1, 16, "hls/control/full_forward_controller.cpp:484-507"),
            ("CAND_STATS", 6, 1, 4, "hls/control/full_forward_controller.cpp:509-535"),
            ("CONCAT_ACT", 6, 1, 1028, "hls/control/full_forward_controller.cpp:537-560"),
            ("FP_ACT_FC1", 6, 1, 1028, "hls/control/full_forward_controller.cpp:741-746"),
            ("BIAS_GELU_ACT", 6, 1, 256, "hls/control/full_forward_controller.cpp:747-754"),
        ):
            add(op, stage, 255, b, 0, row_count, length=length, source=anchor)
    return rows


def schedules(traces: dict, model: dict) -> dict:
    weights = model["weights"]
    aggregates = {}
    csv_path = OUT / "task_schedule_reconstructed.csv"
    fields = ("scenario", "op", "stage", "layer", "batch", "row0", "rows",
              "head", "family", "K", "N", "length", "substage",
              "declared_bytes", "source_anchor", "provenance")
    with csv_path.open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for name, trace in traces["scenarios"].items():
            rows = schedule_rows(name, trace, weights)
            writer.writerows(rows)
            observed = trace["observed_counts"]["op_calls_by_name"]
            counts = Counter(row["op"] for row in rows)
            assert counts == observed, (name, counts - observed, observed - counts)
            assert len(rows) == trace["observed_counts"]["task_retirements"]
            declared_bytes = Counter()
            for row in rows:
                if row["declared_bytes"] is not None:
                    declared_bytes[row["op"]] += row["declared_bytes"]
            aggregates[name] = {
                "task_count": len(rows), "op_calls": dict(counts),
                "declared_load_bytes_by_op": dict(declared_bytes),
                "trace_source": trace["source"],
                "trace_sha256": trace["source_sha256"],
            }
    return {
        "schema": "laya_controller_schedule_reconstruction_v1",
        "schedule_csv": relative(csv_path), "schedule_csv_sha256": sha256(csv_path),
        "provenance": "Static controller-source reconstruction validated against current production observed op counts. Individual row/head/layer events were not recorded by the CPU trace.",
        "controller_source": "hls/control/full_forward_controller.cpp",
        "controller_source_sha256": sha256(ROOT / "hls/control/full_forward_controller.cpp"),
        "scenarios": aggregates,
    }


def rtl_interfaces() -> dict:
    top = RTL / "laya_typed_q8_forward.v"
    wrapper = ROOT / "hls/platform/full_kernel_wrapper.cpp"
    source = top.read_text(errors="replace")
    pragma = wrapper.read_text()
    bundles = []
    for match in re.finditer(r"^#pragma HLS INTERFACE m_axi port=(\w+).*bundle=(\w+).*$", pragma, re.M):
        port, bundle = match.group(1), match.group(2)
        key = bundle.upper()
        addr = re.search(rf"^parameter\s+C_M_AXI_{key}_ADDR_WIDTH\s*=\s*(\d+);", source, re.M)
        data = re.search(rf"^parameter\s+C_M_AXI_{key}_DATA_WIDTH\s*=\s*(\d+);", source, re.M)
        assert addr and data, bundle
        line = pragma.count("\n", 0, match.start()) + 1
        bundles.append({"bundle": bundle, "pointer": port,
                        "address_width_bits": int(addr.group(1)),
                        "data_width_bits": int(data.group(1)),
                        "wrapper_source_line": line})
    assert len(bundles) == 13
    for b in bundles:
        assert b["address_width_bits"] == 64 and b["data_width_bits"] == 32
    lite = {}
    for key in ("CONTROL", "CONTROL_R"):
        lite[key.lower()] = {
            "data_width_bits": int(re.search(rf"^parameter\s+C_S_AXI_{key}_DATA_WIDTH\s*=\s*(\d+);", source, re.M).group(1)),
            "address_width_bits": int(re.search(rf"^parameter\s+C_S_AXI_{key}_ADDR_WIDTH\s*=\s*(\d+);", source, re.M).group(1)),
        }
    return {"schema": "laya_generated_rtl_external_interfaces_v1",
            "top_rtl": relative(top), "top_rtl_sha256": sha256(top),
            "wrapper_source": relative(wrapper), "wrapper_source_sha256": sha256(wrapper),
            "m_axi": bundles, "s_axi_lite": lite,
            "note": "max_widen_bitwidth=512 is a pragma limit, while generated ports are 32-bit."}


def hierarchy() -> dict:
    selected = []
    stack: list[tuple[int, str]] = []
    terms = ("grp_p_anonymous_namespace_compute_one_fu", "grp_full_run_task_37_fu",
             "grp_full_execute_request_fu", "grp_p_anonymous_namespace_graph_fu",
             "grp_p_anonymous_namespace_linear_15_fu", "grp_p_anonymous_namespace_linear_16_fu",
             "grp_p_anonymous_namespace_issue_QKTask_s_fu",
             "grp_p_anonymous_namespace_issue_AVTask_s_fu",
             "grp_p_anonymous_namespace_issue_SoftmaxTask_s_fu")
    for line_no, line in enumerate(HIER.open(errors="replace"), 1):
        if not line.startswith("| ") or " | " not in line:
            continue
        cols = line.split("|")
        name = cols[1].rstrip()
        if not name.strip() or name.strip() == "Instance":
            continue
        depth = (len(name) - len(name.lstrip())) // 2
        while stack and stack[-1][0] >= depth:
            stack.pop()
        path = [x[1] for x in stack] + [name.strip()]
        cells = [x.strip() for x in cols[3:11]]
        if all(re.fullmatch(r"\d+", x) for x in cells) and (depth == 0 or any(t in name for t in terms)):
            selected.append({"line": line_no, "path": path, "instance": name.strip(),
                             "exclusive_row": name.strip().startswith("("),
                             "lut": int(cells[0]), "logic_lut": int(cells[1]),
                             "lutram": int(cells[2]), "srl": int(cells[3]),
                             "ff": int(cells[4]), "ramb36": int(cells[5]),
                             "ramb18": int(cells[6]), "uram": int(cells[7]),
                             "dsp": int(cols[11].strip())})
        stack.append((depth, name.strip()))
    return {"schema": "laya_vivado_selected_hierarchy_v1",
            "source": relative(HIER), "source_sha256": sha256(HIER),
            "note": "Non-parenthesized hierarchy rows include descendant resources; do not add ancestors and descendants. Parenthesized rows denote resources local to that instance.",
            "rows": selected}


def verilog_module_ports(name: str, preferred: tuple[str, ...] = ()) -> dict:
    """Sample declared RTL ports, preserving their actual directions and widths."""
    path = RTL / f"laya_typed_q8_forward_{name}.v" if name else RTL / "laya_typed_q8_forward.v"
    source = path.read_text(errors="replace")
    body = source.split(");", 1)[1]
    params = {m.group(1): int(m.group(2)) for m in re.finditer(
        r"^parameter\s+(\w+)\s*=\s*(\d+);", source, re.M)}
    declarations = []
    for m in re.finditer(r"^\s*(input|output|inout)\s*(\[[^]]+\])?\s*(\w+)\s*;", body, re.M):
        direction, width_expr, port = m.groups()
        width_bits = 1
        if width_expr:
            match = re.fullmatch(r"\[\s*(\w+)\s*(?:-\s*1)?\s*:\s*0\s*\]", width_expr)
            if match:
                upper = match.group(1)
                width_bits = int(upper) + 1 if upper.isdigit() else params.get(upper)
                if upper in params and "-" not in width_expr:
                    width_bits += 1
            else:
                width_bits = None
        declarations.append({"name": port, "direction": direction,
                             "width_bits": width_bits, "width_expression": width_expr or ""})
    assert declarations, path
    selected = []
    seen = set()
    for pattern in ("^ap_clk$", "^ap_start$", "^ap_done$") + preferred:
        for port in declarations:
            if re.search(pattern, port["name"]) and port["name"] not in seen:
                selected.append(port)
                seen.add(port["name"])
                break
    for port in declarations:
        if len(selected) >= 12:
            break
        if re.search(r"_(?:address0|ce0|we0|d0|q0)$", port["name"]) and port["name"] not in seen:
            selected.append(port)
            seen.add(port["name"])
    return {"rtl_module": "laya_typed_q8_forward" + (f"_{name}" if name else ""),
            "source": relative(path), "source_sha256": sha256(path),
            "declared_port_count": len(declarations), "representative_ports": selected}


def logical_module_interfaces() -> dict:
    registry_path = ROOT / "config/full_module_registry.json"
    registry = json.loads(registry_path.read_text())
    # One logical registry entry may span several HLS-generated RTL modules.
    mapping = {
        "top": ("",),
        "common": (),
        "kernel_wrapper": ("",),
        "forward_controller": ("full_execute_request", "p_anonymous_namespace_graph"),
        "memory_map": ("full_read", "full_write"),
        "hbm_loader_and_cache": ("full_load_weight", "full_run_task_30"),
        "embedding_engine": ("embedding_row", "full_run_task"),
        "layernorm_engine": ("layernorm_row_arithmetic", "full_run_task_31"),
        "activation_quantizer": ("activation_quantizer_compute", "full_run_task_36"),
        "q8_linear_and_restore": ("p_anonymous_namespace_compute_one", "full_run_task_37"),
        "rope_and_mask": ("p_anonymous_namespace_attention",),
        "attention_and_fp_engine": ("full_run_task_33", "full_run_task_34", "full_run_task_35", "fp_act_row"),
        "vector_and_ffn": ("geglu_row", "full_run_task_38"),
        "decision_scorer_act": ("candidate_stats", "full_run_task_39", "full_run_task_41", "full_run_task_42"),
        "result_status": ("full_write_result",),
    }
    preferred = {
        "": (r"^ap_rst_n$", r"^m_axi_embedding_ARADDR$", r"^m_axi_embedding_WDATA$",
             r"^m_axi_io_ARADDR$", r"^m_axi_io_WDATA$", r"^s_axi_control_AWADDR$",
             r"^s_axi_control_WDATA$", r"^s_axi_control_r_AWADDR$", r"^s_axi_control_r_WDATA$"),
        "full_execute_request": (r"^m_axi_io_0_ARADDR$", r"^m_axi_io_0_WDATA$"),
        "p_anonymous_namespace_graph": (r"^m_axi_io_0_ARADDR$",),
        "full_read": (r"^m_axi_io_0_ARADDR$", r"^m_axi_io_0_RDATA$"),
        "full_write": (r"^m_axi_io_0_AWADDR$", r"^m_axi_io_0_WDATA$", r"^src_address0$", r"^src_q0$"),
        "full_load_weight": (r"^m_axi_w_q0_0_ARADDR$", r"^m_axi_w_q0_0_RDATA$"),
        "full_run_task_30": (r"^t_kind_val$", r"^t_byte_count_read$"),
        "embedding_row": (r"^raw_address0$", r"^raw_q0$", r"^y_address0$", r"^y_we0$", r"^y_d0$"),
        "layernorm_row_arithmetic": (r"^op$", r"^row_index$", r"^x_address0$", r"^x_q0$", r"^gamma_address0$", r"^gamma_q0$", r"^y_address0$", r"^y_we0$", r"^y_d0$"),
        "activation_quantizer_compute": (r"^task_ctx_rows_val$", r"^task_K_val$", r"^x_address0$", r"^q_address0$", r"^scale_bits_address0$"),
        "p_anonymous_namespace_compute_one": (r"^groups$", r"^wq_address0$", r"^wq_q0$", r"^ws_address0$", r"^ws_q0$", r"^g_full_cache_activation_q_address0$", r"^g_full_cache_activation_q_q0$"),
        "full_run_task_33": (r"^t_ctx_task_id_val$", r"^t_ctx_row0_val$", r"^p_anonymous_namespace_runtime_tasks_retired_o$"),
        "full_run_task_34": (r"^t_ctx_rows_val$", r"^t_length_val$", r"^t_mode_val$"),
        "full_run_task_35": (r"^t_ctx_task_id_val$", r"^t_ctx_row0_val$", r"^p_anonymous_namespace_runtime_tasks_retired_o$"),
        "fp_act_row": (r"^x_address0$", r"^x_q0$", r"^g_full_cache_fp_act_weight_address0$", r"^g_full_cache_fp_act_weight_q0$", r"^y_address0$", r"^y_we0$", r"^y_d0$"),
        "geglu_row": (r"^wi_address0$", r"^wi_q0$", r"^y_address0$", r"^y_we0$", r"^y_d0$"),
        "candidate_stats": (r"^p_address0$", r"^p_q0$", r"^stats_address0$", r"^stats_we0$", r"^stats_d0$"),
        "full_write_result": (r"^m_axi_io_0_AWADDR$", r"^m_axi_io_0_WDATA$"),
    }
    modules = {}
    for logical, sources in registry["modules"].items():
        rtl_names = mapping[logical]
        examples = [verilog_module_ports(n, preferred.get(n, ())) for n in rtl_names]
        for name, example in zip(rtl_names, examples):
            if name in ("full_run_task_33", "full_run_task_35"):
                example["interface_observation"] = (
                    "Only task-context/completion ports; no QK/AV operand or numeric-result RAM ports. "
                    "See attention_synthesis_anomaly.json for fixed E_SHAPE RTL behavior.")
        modules[logical] = {
            "production_sources": [{"path": p, "sha256": sha256(ROOT / p)} for p in sources],
            "rtl_boundary": "shared_definitions_only" if logical == "common" else
                            "same_top_as_top" if logical == "kernel_wrapper" else
                            "related_controller_only_no_rope_leaf" if logical == "rope_and_mask" else
                            "representative_generated_modules",
            "rtl_examples": examples,
        }
        if logical == "rope_and_mask":
            modules[logical]["interface_observation"] = (
                "The shown attention module is related controller logic; no standalone RopeTask "
                "or rope_head RTL module was found in this capture.")
    assert len(modules) == 15
    return {
        "schema": "laya_logical_module_rtl_interface_examples_v1",
        "registry": relative(registry_path), "registry_sha256": sha256(registry_path),
        "note": "Ports are sampled from actual generated Verilog declarations. Logical source groups are not necessarily standalone RTL boundaries; nested task and parent ports must not be interpreted as separate external interfaces. See rtl_external_interfaces.json for the complete top-level AXI widths.",
        "modules": modules,
    }


def attention_synthesis_anomaly() -> dict:
    source = ROOT / "hls/operators/full_tasks_attention.cpp"
    compiled = ROOT.parent / "Laya-repair-20261007/hls/operators/full_tasks_attention.cpp"
    assert compiled.exists() and sha256(source) == sha256(compiled)
    cases = {}
    for op, number, detail_code, issue_name, task_line, leaf_lines in (
        ("QK", 33, 122683397, "p_anonymous_namespace_issue_QKTask_s", 138, [21, 32, 33, 38]),
        ("AV", 35, 122814469, "p_anonymous_namespace_issue_AVTask_s", 307, [95, 104, 106]),
    ):
        rtl = RTL / f"laya_typed_q8_forward_full_run_task_{number}.v"
        report = HLS / f"full_run_task_{number}_csynth.rpt"
        issue_report = HLS / f"{issue_name}_csynth.rpt"
        lines = rtl.read_text().splitlines()

        def locate(fragment: str) -> int:
            hits = [i + 1 for i, line in enumerate(lines) if fragment in line]
            assert hits, (rtl, fragment)
            return hits[0]

        children = sorted(set(re.findall(
            r"^laya_typed_q8_forward_(\w+)\s+\w+\s*\(", "\n".join(lines), re.M)))
        assert children == ["finish_r"]
        assert "grp_check_context" in "\n".join(lines)
        assert "full_run_task_%s" % number in issue_report.read_text()
        shape_hex = hex(detail_code)
        assert (detail_code >> 16) & 0xff == {"QK": 0x50, "AV": 0x52}[op]
        cases[op] = {
            "task_source": f"hls/operators/full_tasks_attention.cpp:{task_line}",
            "task_source_sha256": sha256(source),
            "numeric_leaf_source": [f"hls/operators/attention_full_compute.cpp:{line}" for line in leaf_lines],
            "numeric_leaf_source_sha256": sha256(ROOT / "hls/operators/attention_full_compute.cpp"),
            "issue_report": relative(issue_report), "issue_report_sha256": sha256(issue_report),
            "task_report": relative(report), "task_report_sha256": sha256(report),
            "task_rtl": relative(rtl), "task_rtl_sha256": sha256(rtl),
            "task_rtl_direct_instantiated_modules": children,
            "context_check_subcall_signal": "grp_check_context",
            "rtl_evidence_lines": {
                "context_ok_comparator": locate("assign icmp_ln9_fu_370_p2 ="),
                "fixed_shape_status": locate("grp_finish_r_fu_221_done_status_write = 4'd3;"),
                "fixed_shape_detail": locate(f"grp_finish_r_fu_221_done_error_detail_write = 32'd{detail_code};"),
                "fixed_zero_elements": locate(".elements(20'd0)"),
            },
            "shape_detail_decimal": detail_code, "shape_detail_hex": shape_hex,
            "successful_context_rtl_result": "E_SHAPE (Status=3), zero elements; no QK/AV numeric datapath in this task RTL",
            "reported_task_latency_cycles": "3-5",
        }
    return {
        "schema": "laya_attention_synthesis_anomaly_evidence_v1",
        "status_enum": "include/laya_types.h:8", "status_enum_sha256": sha256(ROOT / "include/laya_types.h"),
        "compiled_source_snapshot": relative(compiled) if compiled.is_relative_to(ROOT) else str(compiled),
        "compiled_source_matches_current_sha256": True,
        "scope": "Captured HLS task RTL from the existing csynth run; no fresh simulation or hardware execution.",
        "interpretation": "The QK and AV task RTL has only context/finish logic and returns E_SHAPE when context succeeds. The HLS 3-5-cycle estimates describe this anomalous synthesized path, not a successful QK/AV computation. This evidence alone does not establish the root cause or end-to-end runtime behavior.",
        "cases": cases,
    }


def loop_evidence(reports: dict, schedule: dict) -> dict:
    selected = {
        "quantization": {
            "source": "hls/operators/activation_quantizer_compute.cpp:63-94",
            "source_bounds_at_S128": "rows <= 16; groups = K/32; two 32-element passes per group",
            "reports": ("activation_quantizer_compute",),
            "comment": "The first 32-element pass has 3-cycle reported iteration latency; the second has 3-8. Full task cycles depend on dynamic bounds and other work.",
        },
        "layernorm": {
            "source": "hls/operators/layernorm_compute.cpp:60-120",
            "source_bounds_at_S128": "per row: 1024-element load, two 1024-to-1 tree reductions, 1024-element variance pass, 1024-element output pass",
            "reports": ("layernorm_row_arithmetic",),
            "comment": "HLS tree-reduction maxima reflect unconstrained dynamic width analysis and must not be used as S128 cycle predictions.",
        },
        "qk": {
            "source": "hls/operators/attention_full_compute.cpp:21-58",
            "source_bounds_at_S128": "per query row: 128 keys x 64 multiplications, with a 64-to-1 reduction and mask/bias per key",
            "reports": ("full_run_task_33", "p_anonymous_namespace_issue_QKTask_s"),
            "comment": "Captured task RTL is anomalous: successful context goes to E_SHAPE with zero elements. Its 3-5-cycle task report is not a successful QK runtime estimate.",
        },
        "av": {
            "source": "hls/operators/attention_full_compute.cpp:95-115",
            "source_bounds_at_S128": "per query row: 64 outputs x 128 key multiplications and accumulations",
            "reports": ("full_run_task_35", "p_anonymous_namespace_issue_AVTask_s"),
            "comment": "Captured task RTL is anomalous: successful context goes to E_SHAPE with zero elements. Its 3-5-cycle task report is not a successful AV runtime estimate.",
        },
        "attention_softmax": {
            "source": "hls/operators/attention_full_compute.cpp:60-93",
            "source_bounds_at_S128": "three length=128 scans plus a 128-to-1 sum tree per attention row; candidate softmax uses length=16",
            "reports": ("softmax_row_1", "full_run_task_34"),
            "comment": "Dynamic HLS worst-case maxima are not the fixed S128 workload.",
        },
        "geglu": {
            "source": "hls/operators/vector_full_compute.cpp:44-55",
            "source_bounds_at_S128": "2624 output elements per row, with GELU/tanh and elementwise gating",
            "reports": ("geglu_row",),
            "comment": "The reported 38-78-cycle iteration range is leaf-loop evidence, not a full vector task latency.",
        },
        "embedding": {
            "source": "hls/operators/embedding_full_compute.cpp:13-34",
            "source_bounds_at_S128": "32 Q8 groups x 32 lanes to produce 1024 float values per token row",
            "reports": ("embedding_row",),
            "comment": "Includes half-scale conversion and Q8 element restore; full embedding task also accesses external memory.",
        },
        "fp_scorer_and_action": {
            "source": "hls/operators/attention_full_compute.cpp:117-157",
            "source_bounds_at_S128": "scorer: 1024 F32 MACs per marker; action: 256 output channels x 1028 F16 weights per batch item",
            "reports": ("fp_act_row", "full_run_task_40"),
            "comment": "Scorer leaf lacks a separate HLS report; no whole-task cycle estimate is asserted.",
        },
        "rope": {
            "source": "hls/operators/rope_full_compute.cpp:13-42",
            "source_bounds_at_S128": "per head/row: read 64 F32 entries, then rotate 32 pairs for each of Q and K",
            "reports": (),
            "comment": "No standalone rope_head task/leaf report or RTL boundary was identified in this captured HLS output.",
        },
    }
    for entry in selected.values():
        source_path = ROOT / entry["source"].split(":", 1)[0]
        entry["source_sha256"] = sha256(source_path)
        entry["hls_reports"] = []
        for name in entry.pop("reports"):
            report = reports["reports"][name]
            entry["hls_reports"].append({
                "module": name, "source": report["source"],
                "source_sha256": report["source_sha256"],
                "overall_latency_cycles": report["overall_latency"],
                "loops": report["loops"],
            })
    ops = ("EMB_TOKEN", "LN_EMB", "LN_ATTN", "LN_FFN", "LN_FINAL", "LN_MARKER",
           "QUANT", "QK", "SOFTMAX_ATT", "SOFTMAX_CAND", "AV", "GEGLU",
           "FP_SCORER_FC2", "FP_ACT_FC1", "ROPE")
    counts = {name: {op: data["op_calls"].get(op, 0) for op in ops}
              for name, data in schedule["scenarios"].items()}
    return {
        "schema": "laya_non_q8_source_bounds_and_hls_loop_evidence_v1",
        "schedule": schedule["schedule_csv"], "schedule_sha256": schedule["schedule_csv_sha256"],
        "task_counts_by_scenario": counts,
        "note": "Source loop bounds describe successful production C++ work at physical S=128. HLS loop figures are existing synthesis estimates and dynamic maxima; they are neither observed request cycles nor additive full-task estimates. QK/AV captured RTL anomaly is separately documented.",
        "operations": selected,
    }


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    collected_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
    traces = trace_metadata()
    model = weight_facts(traces)
    reports = hls_reports()
    schedule = schedules(traces, model)
    write_json("trace_observed.json", traces)
    write_json("model_weights_q8_work.json", model)
    write_json("hls_reports.json", reports)
    write_json("rtl_external_interfaces.json", rtl_interfaces())
    write_json("vivado_hierarchy_selected.json", hierarchy())
    write_json("task_schedule_reconstructed.json", schedule)
    write_json("logical_module_interfaces.json", logical_module_interfaces())
    write_json("attention_synthesis_anomaly.json", attention_synthesis_anomaly())
    write_json("loop_evidence.json", loop_evidence(reports, schedule))
    registry = ROOT / "config/full_module_registry.json"
    sources = ROOT / "config/full_sources.cmake"
    registry_data = json.loads(registry.read_text())
    source_paths = set(sum(registry_data["modules"].values(), []))
    source_paths.update(("include/laya_tasks.h", "include/laya_types.h"))
    write_json("evidence_index.json", {
        "schema": "laya_f0_performance_evidence_index_v1",
        "collection_utc": collected_at,
        "extraction_status": "success",
        "extraction_script": {"path": relative(Path(__file__).resolve()),
                              "sha256": sha256(Path(__file__).resolve())},
        "build_tag": "04934c15b3f83e842ec2e92ac2a81bf2",
        "vivado_run_id": "20261008T022231Z-2961016",
        "provenance": "Read-only source/report parsing and exact integer workload reconstruction; no new HLS/Vivado/CPU run.",
        "registry": {"path": relative(registry), "sha256": sha256(registry)},
        "production_sources": {"path": relative(sources), "sha256": sha256(sources)},
        "production_source_sha256": {path: sha256(ROOT / path) for path in sorted(source_paths)},
        "generated_descriptor": {"path": "build/model-repair/laya_model_layout_generated.h",
                                 "sha256": sha256(ROOT / "build/model-repair/laya_model_layout_generated.h")},
        "artifacts": {name: sha256(OUT / name) for name in (
            "trace_observed.json", "model_weights_q8_work.json", "hls_reports.json",
            "rtl_external_interfaces.json", "vivado_hierarchy_selected.json",
            "task_schedule_reconstructed.json", "task_schedule_reconstructed.csv",
            "logical_module_interfaces.json", "attention_synthesis_anomaly.json",
            "loop_evidence.json")},
    })
    print(f"Collected performance facts in {OUT}")


if __name__ == "__main__":
    main()
