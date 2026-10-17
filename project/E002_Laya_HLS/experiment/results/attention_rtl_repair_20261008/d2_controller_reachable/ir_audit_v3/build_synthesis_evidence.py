#!/usr/bin/env python3
"""Freeze factual D2-I v3 synthesis evidence from already completed runs."""

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
AUDIT = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def artifact(path):
    path = Path(path)
    return {"path": str(path), "sha256": digest(path)}


source_path = ROOT / "source_list_manifest.json"
decode_path = AUDIT / "decode_manifest.json"
rtl_path = AUDIT / "rtl_hash_manifest.json"
sources = json.loads(source_path.read_text())
decode = json.loads(decode_path.read_text())
rtl = json.loads(rtl_path.read_text())

assert digest(sources["included_controller"]["path"]) == sources["included_controller"]["sha256"]
assert sources["included_controller"]["sha256"] == "23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623"
assert len(sources["linked_production_sources"]) == 24
for item in sources["linked_production_sources"]:
    assert digest(item["path"]) == item["sha256"]
for item in sources["isolated_tops"].values():
    for key in ("wrapper", "tb", "config"):
        assert digest(item[key]["path"]) == item[key]["sha256"]
for item in decode["files"]:
    assert item["exit_code"] == 0
    assert digest(item["input"]) == item["input_sha256"]
    assert digest(item["output"]) == item["output_sha256"]
for languages in rtl["runs"].values():
    for data in languages.values():
        assert len(data["files"]) == data["count"]
        for item in data["files"]:
            assert digest(ROOT / item["path"]) == item["sha256"]


def anchor(relative, first, last, terms, observation):
    path = ROOT / relative
    lines = path.read_text().splitlines()
    assert 1 <= first <= last <= len(lines), (relative, first, last)
    excerpt = "\n".join(lines[first - 1:last])
    for term in terms:
        assert term in excerpt, (relative, first, last, term)
    return {
        **artifact(path),
        "lines": [first, last],
        "checked_terms": terms,
        "observation": observation,
    }


def ir(name, stage, first, last, terms, observation):
    filename = {"gdce": "a.g.ld.5.gdce.ll", "final": "a.o.3.ll"}[stage]
    return anchor(f"ir_audit_v3/{name}/{filename}", first, last, terms, observation)


def vhdl(name, filename, first, last, terms, observation):
    return anchor(
        f"runs/v3/csynth_{name}_work/hls/impl/vhdl/{filename}",
        first, last, terms, observation,
    )


linear_ir = [
    ir("linear", "gdce", 34443, 34554, ["Controller6linear", "linear_impl"], "GDCE retains both production Controller::linear overloads and linear_impl."),
    ir("linear", "final", 3309, 3379, ["full_claim_owner", "full_write", "full_cover_owner", "full_publish_owner"], "Top builds a real NORM source with owner claim, external write, cover, and publish."),
    ir("linear", "final", 3468, 3515, ["linear_impl", "i1 true", "i1 false"], "Runtime pair selection reaches the production core with both explicit presence values."),
    ir("linear", "final", 22036, 22057, ["load_weight", "pair_present_read", "full_claim_qkv_pair"], "Weight load precedes the pair-presence branch; the present branch calls pair claim."),
    ir("linear", "final", 22144, 22171, ["issue<QuantTask>", "issue<LinearTask>"], "The pair-present path retains quant and linear task issue."),
    ir("linear", "final", 22205, 22270, ["full_publish_qkv_pair", "pair_output_ref_id_addr", "pair_output_ref_id_addr_1"], "After tasks, the path calls pair publish and writes both returned pair descriptors."),
    ir("linear", "final", 22270, 22281, ["117440516", "[ 8, %if.end ]"], "The no-pair branch retains code 8/detail 0x07000004 after weight load."),
    ir("linear", "final", 15467, 15653, ["claim_index", "store i3 1", "owner_claims_load, 2"], "Pair claim allocates two indices, writes both claimed states, and adds two to the claim count."),
    ir("linear", "final", 8675, 8683, ["store i3 2", "final_qkv_ref_id_0", "final_qkv_ref_id_1"], "Pair publish writes both READY states and both final references."),
    ir("linear", "final", 5087, 5182, ["compute_one", "write_linear_output"], "LinearTask calls numeric compute_one then write_linear_output."),
    ir("linear", "final", 20905, 20908, ["full_write.8"], "The output writer passes F32 bytes to full_write."),
    ir("linear", "final", 3749, 3761, ["_ssdm_op_Write.m_axi.i8P1A", "%qkv0_addr", "%qkv1_addr"], "Final memory helper retains writes to both external QKV banks."),
]

linear_rtl = [
    vhdl("linear", "linear_controller_slice.vhd", 445, 513, ["m_axi_qkv0_AWADDR", "m_axi_qkv0_WDATA", "m_axi_qkv1_AWADDR", "m_axi_qkv1_WDATA"], "Top exposes both QKV AXI write interfaces."),
    vhdl("linear", "linear_controller_slice.vhd", 9899, 9906, ["component linear_controller_slice_p_anonymous_namespace_linear_impl", "ap_start", "ap_done"], "Top instantiates the linear core with a start/done handshake."),
    vhdl("linear", "linear_controller_slice_p_anonymous_namespace_linear_impl.vhd", 7480, 7482, ["component linear_controller_slice_full_claim_qkv_pair"], "Linear core instantiates pair claim."),
    vhdl("linear", "linear_controller_slice_p_anonymous_namespace_linear_impl.vhd", 7675, 7677, ["component linear_controller_slice_full_publish_qkv_pair"], "Linear core instantiates pair publish."),
    vhdl("linear", "linear_controller_slice_p_anonymous_namespace_linear_impl.vhd", 7830, 7832, ["component linear_controller_slice_p_anonymous_namespace_issue_QuantTask_s"], "Linear core instantiates quant issue."),
    vhdl("linear", "linear_controller_slice_p_anonymous_namespace_linear_impl.vhd", 8690, 8692, ["component linear_controller_slice_p_anonymous_namespace_issue_LinearTask_s"], "Linear core instantiates linear issue."),
    vhdl("linear", "linear_controller_slice_p_anonymous_namespace_issue_LinearTask_s.vhd", 1768, 1770, ["component linear_controller_slice_full_run_task_6"], "Linear issue instantiates production LinearTask executor."),
    vhdl("linear", "linear_controller_slice_full_run_task_6.vhd", 5652, 5696, ["wq_U", "ws_U", "y_U"], "Task executor instantiates weight, scale, and result RAM."),
]

vector_ir = [
    ir("vector", "gdce", 45016, 45138, ["Controller6vector", "vector_impl", "i1 zeroext true", "i1 zeroext false"], "GDCE retains both production Controller::vector overloads and explicit presence."),
    ir("vector", "final", 662, 670, ["vector_controller_slice", "src1_input"], "Top retains runtime mode and second input interface."),
    ir("vector", "final", 807, 812, ["produce_f32", "src1_input"], "Binary mode builds the second F32 source via the producer helper."),
    ir("vector", "final", 13810, 13813, ["src1_present_read", "t_src1_id", "t_src1_bank", "t_src1_epoch"], "Core selects second-source reference fields from explicit presence."),
    ir("vector", "final", 13862, 13871, ["bind", "src1_present_read"], "First bind is followed by a conditional second bind."),
    ir("vector", "final", 13884, 13885, ["issue<VectorTask>", "%t_src1_id", "%t_src1_bank", "%t_src1_epoch"], "Issued VectorTask receives the second-source reference."),
    ir("vector", "final", 13923, 13924, ["full_publish_owner"], "Controller publishes destination after the task loop succeeds."),
    ir("vector", "final", 2197, 2198, ["vector_shape"], "Task executor retains production shape validation."),
    ir("vector", "final", 2423, 2565, ["@source", "@full_acquire_owner", "%t_src1_id_val_read"], "Task derives second source and acquires both source owners."),
    ir("vector", "final", 3040, 3082, ["@read", "%t_src0_id_val_read", "%t_src1_id_val_read"], "Task reads numeric data from both source references."),
    ir("vector", "final", 3119, 3126, ["%lhs", "%rhs", "fadd float %lhs, %rhs"], "Vector add computes F32 sum from two loaded arrays."),
    ir("vector", "final", 3164, 3169, ["@write", "%y_4_load"], "Task writes computed result via destination memory helper."),
    ir("vector", "final", 3201, 3205, ["full_release_read_owner", "src1_ref_id"], "Task retains conditional second-source owner release."),
    ir("vector", "final", 1201, 1215, ["full_f32_address", "full_read"], "Read helper resolves F32 address and performs external read."),
    ir("vector", "final", 604, 620, ["full_write.2"], "Write helper passes F32 bytes to the external-memory write helper."),
    ir("vector", "final", 1664, 1680, ["%state0_addr", "%state1_addr", "_ssdm_op_Write.m_axi.i8P1A"], "Final memory helper retains writes to both external state banks."),
]

vector_rtl = [
    vhdl("vector", "vector_controller_slice.vhd", 162, 169, ["m_axi_src1_input_ARADDR"], "Top exposes second-input AXI read interface."),
    vhdl("vector", "vector_controller_slice.vhd", 279, 344, ["m_axi_state0_AWADDR", "m_axi_state0_WDATA", "m_axi_state1_AWADDR", "m_axi_state1_WDATA"], "Top exposes both state-bank AXI write interfaces."),
    vhdl("vector", "vector_controller_slice.vhd", 6139, 6147, ["component vector_controller_slice_p_anonymous_namespace_vector_impl", "ap_start", "ap_done"], "Top instantiates vector core with start/done handshake."),
    vhdl("vector", "vector_controller_slice_p_anonymous_namespace_vector_impl.vhd", 2860, 2862, ["component vector_controller_slice_p_anonymous_namespace_issue_VectorTask_s"], "Vector core instantiates VectorTask issue."),
    vhdl("vector", "vector_controller_slice_p_anonymous_namespace_issue_VectorTask_s.vhd", 1308, 1310, ["component vector_controller_slice_full_run_task"], "Vector issue instantiates production task executor."),
    vhdl("vector", "vector_controller_slice_full_run_task.vhd", 5629, 5660, ["a_U", "b_U", "y_4_U"], "Task executor instantiates both operand RAMs and result RAM."),
    vhdl("vector", "vector_controller_slice_full_run_task.vhd", 7773, 7776, ["component vector_controller_slice_faddfsub_32ns_32ns_32_4_full_dsp_1"], "Task executor instantiates F32 add/subtract hardware."),
]

source_by_name = {Path(item["path"]).name: item for item in sources["linked_production_sources"]}
source_mapping = {"controller": sources["included_controller"]}
for label, name in (
    ("owner_helpers", "laya_full_owner.cpp"),
    ("memory_helpers", "laya_full_memory.cpp"),
    ("linear_task", "full_tasks.cpp"),
    ("linear_numeric", "q8_linear_compute.cpp"),
    ("vector_task", "full_tasks_vector.cpp"),
    ("vector_numeric", "vector_full_compute.cpp"),
):
    source_mapping[label] = source_by_name[name]


def run(name, top, estimates, ir_anchors, rtl_anchors):
    base = ROOT / "runs" / "v3"
    guard_dir = base / f"csynth_{name}_guard"
    hls_dir = base / f"csynth_{name}_work" / "hls"
    guard = json.loads((guard_dir / "guard_result.json").read_text())
    plan = json.loads((guard_dir / "guard_plan.json").read_text())
    assert guard["child_exit_code"] == 0 and guard["trigger"] is None
    assert plan["command"][-4:] == ["--config", str(ROOT / f"config_{name}.cfg"), "--work_dir", str(base / f"csynth_{name}_work")]
    return {
        "top": top,
        "config": sources["isolated_tops"][name]["config"],
        "wrapper": sources["isolated_tops"][name]["wrapper"],
        "testbench": sources["isolated_tops"][name]["tb"],
        "guard_result": {**artifact(guard_dir / "guard_result.json"), **guard},
        "guard_plan": {**artifact(guard_dir / "guard_plan.json"), "command": plan["command"], "maximum_owned_rss_kb": plan["maximum_owned_rss_kb"], "maximum_seconds": plan["maximum_seconds"], "minimum_mem_available_kb": plan["minimum_mem_available_kb"]},
        "driver_log": artifact(guard_dir / "driver.log"),
        "reports": {"summary": artifact(hls_dir / "syn/report/csynth.rpt"), "top_detail": artifact(hls_dir / f"syn/report/{top}_csynth.rpt")},
        "hls_estimates_only": estimates,
        "ir_anchors": ir_anchors,
        "rtl_anchors": rtl_anchors,
        "rtl_file_counts": {language: rtl["runs"][name][language]["count"] for language in ("vhdl", "verilog")},
    }


packet = {
    "schema": "d2_i_v3_synthesis_evidence_v1",
    "purpose": "Factual generated-path evidence for independent technical review; no acceptance decision.",
    "builder": artifact(__file__),
    "contract": {**artifact(ROOT.parent / "repair_contract.md"), "section": "7.6"},
    "source_identity": {"manifest": artifact(source_path), "production_sources_verified_against_live_files": 24, "directly_included_controller_verified_against_live_file": True, "relevant_sources": source_mapping},
    "decoder": {"manifest": artifact(decode_path), "tool": decode["tool"], "tool_sha256": decode["tool_sha256"], "tool_version": decode["tool_version"], "decoded_file_count": len(decode["files"]), "all_decode_exit_codes_zero_and_hashes_rechecked": True},
    "generated_rtl": {"manifest": artifact(rtl_path), "all_listed_file_hashes_rechecked": True},
    "runs": {
        "linear": run("linear", "linear_controller_slice", {"requested_frequency_hz": 150000000, "target_device": "xcu55c-fsvh2892-2L-e", "hls_version": "2025.2 build 6295257", "bram_18k": 102, "dsp": 36, "ff": 59265, "lut": 216224, "uram": 0, "reported_slack_ns": -0.31, "top_latency_cycles": None}, linear_ir, linear_rtl),
        "vector": run("vector", "vector_controller_slice", {"requested_frequency_hz": 150000000, "target_device": "xcu55c-fsvh2892-2L-e", "hls_version": "2025.2 build 6295257", "bram_18k": 60, "dsp": 65, "ff": 41066, "lut": 131019, "uram": 3, "reported_slack_ns": -0.31, "top_latency_cycles": None}, vector_ir, vector_rtl),
    },
    "limits": [
        "IR and generated RTL show retained logic, memory interfaces, and module wiring; they do not establish that a test transaction exercised those paths in RTL.",
        "These synthesis runs did not execute complete 64-row QKV RTL or the full controller graph.",
        "Reported area and slack are HLS estimates, not post-route timing closure or measured latency. Both top latencies are undefined in HLS reports.",
        "Dynamic binary, unary, and negative branches in IR are structural evidence only; functional outcomes require separate run evidence.",
        "The identity manifest hashes linked production .cpp files, the included controller, wrappers, testbenches, and configs. It does not enumerate every transitive header or tool-installation file.",
        "Listed source/config and generated outputs are bound to packet hashes; later edits require a new evidence identity.",
    ],
}

output = AUDIT / "synthesis_evidence.json"
output.write_text(json.dumps(packet, indent=2) + "\n")
print(output)
print("sha256", digest(output))
print("anchors", len(linear_ir), len(linear_rtl), len(vector_ir), len(vector_rtl))
