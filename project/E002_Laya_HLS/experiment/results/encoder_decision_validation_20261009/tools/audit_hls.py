#!/usr/bin/env python3
"""Check the generated fe067 full-top HLS structure without claiming RTL execution."""

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STAGE = Path(__file__).resolve().parents[1]
ATTEMPT = STAGE / "attempts/full_hls_01"
WORK = ATTEMPT / "work/hls"
VERILOG = WORK / "syn/verilog"
REPORT = WORK / "syn/report"


def read(path):
    assert path.is_file(), path
    return path.read_text(errors="replace")


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def check(condition, name):
    assert condition, name
    checks.append(name)


checks = []
guard = json.loads(read(ATTEMPT / "guard/guard_result.json"))
check(guard["child_exit_code"] == 0 and guard["trigger"] is None,
      "v++ HLS exit0, resource guard clear")
check(guard["rss_captured"] and guard["rss_sample_count"] > 5000,
      "0.2s owned-RSS timeline present")
cfg = ROOT / "build/full-top-encoder-decision-20261009/full_top.cfg"
old_cfg = ROOT / "build/full-top-d2-csim-official-20261008/full_top.cfg"
check(sha(cfg) == sha(old_cfg), "25-TU production config byte-identical")
check(read(cfg).count("syn.file=") == 25, "25 production translation units")
manifest = json.loads(read(ATTEMPT / "input_manifest.json"))
check(any(x["path"].endswith("/build/model-attention-rtl-repair-20261008/manifest.json") and
          x["sha256"] == "128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa"
          for x in manifest["inputs"]), "official fe067 model manifest sealed")

top_report = read(REPORT / "laya_typed_q8_forward_csynth.rpt")
top = read(VERILOG / "laya_typed_q8_forward.v")
execute = read(VERILOG / "laya_typed_q8_forward_full_execute_request.v")
graph = read(VERILOG / "laya_typed_q8_forward_p_anonymous_namespace_graph.v")
graph_report = read(REPORT / "p_anonymous_namespace_graph_csynth.rpt")
ports = ("embedding", "io", "w_q0", "w_q1", "w_scale", "aux", "state0",
         "state1", "qkv0", "qkv1", "ff0", "ff1", "att_out")
widths = {}
for port in ports:
    widths[port] = {}
    for direction in ("RDATA", "WDATA"):
        pattern = rf"\|m_axi_{port}_{direction}\s+\|\s*(?:in|out)\|\s*(\d+)\|"
        match = re.search(pattern, top_report)
        check(bool(match), f"generated {port} {direction} interface")
        widths[port][direction] = int(match.group(1))
        check(widths[port][direction] == 32,
              f"generated {port} {direction} is actual 32-bit")
check("laya_typed_q8_forward_full_execute_request grp_" in top,
      "top instantiates full_execute_request")
check("laya_typed_q8_forward_p_anonymous_namespace_graph grp_" in execute and
      "laya_typed_q8_forward_full_write_result grp_" in execute,
      "execute instantiates graph and result commit")
check("0 ~ 28" in graph_report and "0 ~ 2" in graph_report,
      "generated graph retains 28 Encoder and 2 Decision loop bounds")
graph_modules = ("embed_tokens", "attention", "residual", "type_add",
                 "gather", "candidate_probability", "candidate_statistics",
                 "act_concat")
for name in graph_modules:
    check(f"laya_typed_q8_forward_p_anonymous_namespace_{name} grp_" in graph,
          f"generated graph reaches {name}")

attention = read(VERILOG / "laya_typed_q8_forward_p_anonymous_namespace_attention.v")
for name in ("QK", "AV"):
    check(f"laya_typed_q8_forward_p_anonymous_namespace_issue_{name}Task_s grp_" in attention,
          f"attention instantiates production {name} issue")
for task_number, arithmetic, data_inputs, data_outputs in (
    (20, "qk_row", ("q_q0", "k_q0", "mask_q0"), ("score_d0", "score_we0")),
    (22, "av_row", ("p_q0", "v_q0"), ("y_d0", "y_we0")),
):
    task = read(VERILOG / f"laya_typed_q8_forward_full_run_task_{task_number}.v")
    arith = read(VERILOG / f"laya_typed_q8_forward_{arithmetic}.v")
    check(f"laya_typed_q8_forward_{arithmetic} grp_" in task,
          f"production task {task_number} instantiates {arithmetic}")
    check(all(re.search(rf"\b{signal}\b", arith) for signal in data_inputs + data_outputs),
          f"{arithmetic} has real numeric data input/output ports")
    check("ap_start_reg <= 1'b1" in task,
          f"production task {task_number} has launched arithmetic state")

vector = read(VERILOG / "laya_typed_q8_forward_full_run_task_23.v")
check(all(x in vector for x in ("t_src0_id_val", "t_src1_id_val",
                                "t_src1_bank_val", "m_axi_state0_0_RDATA",
                                "m_axi_state1_0_RDATA")),
      "generated VectorTask retains both residual sources and state reads")
check("full_publish_owner" in " ".join(p.name for p in VERILOG.glob("*.v")) and
      "full_acquire_owner" in " ".join(p.name for p in VERILOG.glob("*.v")),
      "generated owner publication and acquisition modules exist")
driver = read(ATTEMPT / "guard/driver.log")
check("runtime_session_generation' is power-on initialization" in driver and
      "runtime_last_accepted_request_id' is power-on initialization" in driver,
      "power-on initialization reported for session metadata")
compute = read(REPORT / "p_anonymous_namespace_compute_one_csynth.rpt")
check("179 ~ 199" in compute and "160|      160" in compute,
      "current GS32 Q8 schedule retains 179-199 cycles")

artifacts = {str(p.relative_to(ATTEMPT)): sha(p) for p in (
    ATTEMPT / "work/laya_typed_q8_forward.zip",
    WORK / "impl/ip/component.xml",
    REPORT / "laya_typed_q8_forward_csynth.rpt",
    VERILOG / "laya_typed_q8_forward.v",
    VERILOG / "laya_typed_q8_forward_full_run_task_20.v",
    VERILOG / "laya_typed_q8_forward_full_run_task_22.v",
    VERILOG / "laya_typed_q8_forward_qk_row.v",
    VERILOG / "laya_typed_q8_forward_av_row.v",
)}
result = {
    "decision": "STRUCTURAL_AUDIT_PASS_DYNAMIC_RTL_PENDING",
    "scope": "Generated hierarchy/interfaces/QK-AV numeric datapaths and selected owner/residual structure; no RTL runtime or AXI debt claim",
    "checks": checks,
    "actual_m_axi_data_widths": widths,
    "hls_resources": {"LUT": 1810065, "FF": 466070, "DSP": 456,
                      "BRAM18": 537, "URAM": 45},
    "hls_top_latency": "unknown",
    "guard": guard,
    "artifact_sha256": artifacts,
}
out = ATTEMPT / "static_audit.json"
out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
print(json.dumps({"decision": result["decision"], "checks": len(checks),
                  "report": str(out)}))
