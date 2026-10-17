#!/usr/bin/env python3
"""Seal existing v7 HLS outputs; never invoke a compiler or simulator."""

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

RUN = Path(__file__).resolve().parent
WORK = RUN / "work"
PRE = RUN / "source_binding_pre.json"
RELEASE_SHA = "89773b4a566d2bad66d146983998d0779da7c30d69836aaa7f6ddb234d183373"
MARKER = re.compile(rb'^#\s+\d+\s+"([^"]+)"', re.MULTILINE)


def identity(path):
    path = Path(path)
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            h.update(chunk)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def check(expected):
    actual = identity(expected["path"])
    if (actual["bytes"], actual["sha256"]) != (expected["bytes"], expected["sha256"]):
        raise RuntimeError(f"bound input changed: {expected['path']}")
    return actual


def save(name, obj):
    path = RUN / name
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")
    return identity(path)


def main():
    now = datetime.now(timezone.utc).isoformat()
    pre = json.loads(PRE.read_text())
    if not pre["all_match"] or pre["release"]["sha256"] != RELEASE_SHA:
        raise RuntimeError("precheck or release mismatch")
    for key in ("release", "source_packet", "guard", "guard_helper", "vplusplus_entry"):
        check(pre[key])
    for key, count in (("prepared_files", 15), ("frozen_prior_checks", 202), ("config_sources", 25)):
        if len(pre[key]) != count:
            raise RuntimeError(f"unexpected {key} count")
    prepared = [check(x) for x in pre["prepared_files"]]
    frozen = [check(x) for x in pre["frozen_prior_checks"]]
    release = json.loads(Path(pre["release"]["path"]).read_text())
    guard = json.loads((RUN / "guard/guard_result.json").read_text())
    launch = json.loads((RUN / "guard/launch.json").read_text())
    plan = json.loads((RUN / "guard/guard_plan.json").read_text())
    policy = json.loads((RUN / "guard/policy_checks.json").read_text())
    if guard["child_exit_code"] != 0 or guard["trigger"] is not None:
        raise RuntimeError("HLS guard failed")
    if release["exact_guard_argv"] != pre["exact_guard_argv"]:
        raise RuntimeError("guard argv changed")
    if (plan["command"][-len(release["exact_payload_argv"]):] != release["exact_payload_argv"]
            or plan["cwd"] != release["working_directory"]
            or plan["maximum_owned_rss_kb"] != 16 * 1024 * 1024
            or plan["maximum_seconds"] != 1800
            or plan["selected_cpu_ids"] != [0, 1, 2, 3]
            or not launch["leader_pid"]
            or not policy or not all(item["matches"] for item in policy)):
        raise RuntimeError("actual guard launch or process policy mismatch")
    post = dict(pre)
    post.update(schema="attention_v7_single_hls_source_binding_post_v1",
                created_utc=now, phase="post", prepared_files=prepared,
                frozen_prior_checks=frozen, all_match=True)
    post_id = save("source_binding_post.json", post)

    pp_files = sorted((WORK / "hls/.autopilot/db").glob("*.pp.*.cpp"))
    if len(pp_files) != 25:
        raise RuntimeError(f"expected 25 preprocessed TUs, got {len(pp_files)}")
    all_deps, synthetic, per_tu = set(), set(), []
    for pp in pp_files:
        names = {m.decode("utf-8", "surrogateescape") for m in MARKER.findall(pp.read_bytes())}
        deps = []
        for name in sorted(names):
            if name == "directive" or (name.startswith("<") and name.endswith(">")):
                synthetic.add(name)
            elif Path(name).is_absolute() and Path(name).is_file():
                deps.append(name)
                all_deps.add(name)
            else:
                raise RuntimeError(f"unresolved preprocessor marker: {name}")
        per_tu.append({"preprocessed_file": identity(pp),
                       "dependency_count": len(deps), "dependencies": deps})
    closure_id = save("actual_preprocessed_dependency_closure.json", {
        "schema": "attention_v7_actual_preprocessed_dependency_closure_v1",
        "created_utc": now, "source": "Vitis-generated .pp.0.cpp line markers; no new compiler invocation",
        "preprocessed_tu_count": len(pp_files), "per_translation_unit": per_tu,
        "unique_real_file_count": len(all_deps),
        "unique_real_files": [identity(x) for x in sorted(all_deps)],
        "synthetic_markers": sorted(synthetic), "unresolved_markers": []})

    report = WORK / "hls/syn/report/attention_preloaded_slice_csynth.rpt"
    top = WORK / "hls/syn/verilog/attention_preloaded_slice.v"
    vhdl = WORK / "hls/syn/vhdl/attention_preloaded_slice.vhd"
    ipzip = WORK / "hls/impl/ip/xilinx_com_hls_attention_preloaded_slice_1_0.zip"
    generated = {name: identity(path) for name, path in (("report", report),
                 ("top_verilog", top), ("top_vhdl", vhdl), ("ip_zip", ipzip))}
    rpt = report.read_text(errors="replace")
    rtl = top.read_text(errors="replace")
    clock = re.search(r"\|ap_clk\s*\|\s*([\d.]+) ns\|\s*([\d.]+) ns\|\s*([\d.]+) ns\|", rpt)
    resources = re.search(r"^\|Total\s*\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|", rpt, re.MULTILINE)
    if not clock or not resources:
        raise RuntimeError("HLS report summary missing")
    m_axi = sorted(set(re.findall(r"^\|m_axi_(\w+)_AWVALID\s*\|", rpt, re.MULTILINE)))
    s_axi = sorted(set(re.findall(r"^\|s_axi_(\w+)_AWVALID\s*\|", rpt, re.MULTILINE)))
    if m_axi != sorted(("descriptor", "io", "aux", "qkv0", "qkv1", "att_out", "observed")) or s_axi != ["control", "control_r"]:
        raise RuntimeError("unexpected generated AXI interface shape")
    scalar_reset = re.search(r"always @ \(posedge ap_clk\) begin\s*if \(ap_rst_n_inv == 1'b1\) begin\s*laya_full_anonymous_namespace_metadata_initialized <= 1'd0;", rtl)
    scalar_set = "laya_full_anonymous_namespace_metadata_initialized <= 1'd1;" in rtl
    init_start = "grp_p_anonymous_namespace_reset_metadata_fu_1626_ap_start_reg <= 1'b1;" in rtl
    init_block = "ap_block_state2_on_subcall_done = ((grp_p_anonymous_namespace_reset_metadata_fu_1626_ap_done == 1'b0) & (laya_full_anonymous_namespace_metadata_initialized_load_reg_6313 == 1'd0));" in rtl
    if not all((scalar_reset, scalar_set, init_start, init_block)):
        raise RuntimeError("scalar reset or initialization gate not found")
    payload_names = ("g_full_cache_kv", "g_full_cache_score", "g_full_cache_av_partial")
    payload = []
    for name in payload_names:
        modules = sorted((WORK / "hls/syn/verilog").glob(f"*{name}_RAM_*.v"))
        if len(modules) != 1:
            raise RuntimeError(f"payload RAM module count for {name}: {len(modules)}")
        path = modules[0]
        body = path.read_text(errors="replace")
        if not re.search(r"initial begin\s*\$readmemh\(", body):
            raise RuntimeError(f"cold DAT initialization missing: {name}")
        if not re.search(r"if \(we0\)\s*ram\[address0\] <= d0;", body):
            raise RuntimeError(f"normal RAM write missing: {name}")
        if re.search(r"\breset\b", body[body.index("// read first"):]):
            raise RuntimeError(f"reset signal appears in RAM write process: {name}")
        instances = sorted((WORK / "hls/syn/verilog").glob("*.v"))
        matches = []
        module = path.stem
        inst_pattern = re.compile(re.escape(module) + r"\s*#\([^;]*?\)\s*(\w+)\(\s*\.clk\(ap_clk\),\s*\.reset\(([^)]+)\)", re.S)
        for parent in instances:
            for match in inst_pattern.finditer(parent.read_text(errors="replace")):
                matches.append({"parent": str(parent), "instance": match.group(1), "reset_connection": match.group(2)})
        if not matches:
            raise RuntimeError(f"no instantiation of {name} RAM")
        payload.append({"name": name, "module": identity(path), "instances": matches,
                        "cold_dat_only": True, "write_only_when_ce0_we0": True,
                        "reset_used_in_ram_process": False})
    static_id = save("generated_rtl_static_audit.json", {
        "schema": "attention_v7_generated_rtl_static_audit_v1", "created_utc": now,
        "top_verilog": generated["top_verilog"],
        "metadata_initialized": {"synchronous_active_low_pin_reset_clears_zero": True,
            "first_command_starts_reset_metadata_when_zero": True,
            "state2_waits_for_reset_metadata_done_when_zero": True,
            "sets_true_after_reset_metadata_done": True,
            "runtime_first_command_behavior": "NOT_SIMULATED"},
        "persistent_numeric_payload_ram_modules": payload,
        "interpretation": "Structural RTL observations only. Cold $readmemh DAT loading is not pin-reset clearing; no RTL simulation, OOC, or physical timing was run."})

    files, directories, symlinks, other = [], [], [], []
    for path in sorted(RUN.rglob("*")):
        rel = str(path.relative_to(RUN))
        if path.name in ("archive_inventory.json", "actual_result_evidence.json"):
            continue
        if path.is_symlink():
            symlinks.append({"relative_path": rel, "target": str(path.readlink())})
        elif path.is_dir():
            directories.append(rel)
        elif path.is_file():
            item = identity(path)
            item["relative_path"] = rel
            files.append(item)
        else:
            other.append(rel)
    if symlinks or other:
        raise RuntimeError(f"unexpected archive entries: symlink {len(symlinks)}, other {len(other)}")
    inventory_id = save("archive_inventory.json", {
        "schema": "attention_v7_single_hls_archive_inventory_v1", "created_utc": now,
        "root": str(RUN), "file_count": len(files), "files": files,
        "directory_count": len(directories), "directories": directories,
        "symlink_count": 0, "symlinks": [], "other_count": 0, "other": [],
        "total_file_bytes": sum(x["bytes"] for x in files)})
    driver = RUN / "guard/driver.log"
    compile_log = WORK / "logs/hls_compile.log"
    log_lines = compile_log.read_text(errors="replace").splitlines()
    evidence = {
        "schema": "attention_v7_single_hls_actual_result_evidence_v1", "created_utc": now,
        "status": "SYNTHESIS_SUCCESS_GENERATED_STATIC_REVIEW_PENDING",
        "release": check(pre["release"]), "source_packet": check(pre["source_packet"]),
        "precheck": identity(PRE), "postcheck": post_id, "postcheck_all_match": True,
        "actual_preprocessed_dependencies": closure_id,
        "generated_rtl_static_audit": static_id, "archive_inventory": inventory_id,
        "archive_file_count": len(files), "archive_directory_count": len(directories),
        "archive_symlink_count": 0, "guard": guard,
        "guard_launch": identity(RUN / "guard/launch.json"),
        "guard_plan": identity(RUN / "guard/guard_plan.json"),
        "guard_policy_checks": identity(RUN / "guard/policy_checks.json"),
        "all_guard_policy_checks_match": True,
        "guard_policy_process_count": len(policy),
        "guard_memory_timeline": identity(RUN / "guard/memory_timeline.csv"),
        "raw_driver_log": identity(driver), "hls_compile_log": identity(compile_log),
        "exact_guard_argv": pre["exact_guard_argv"],
        "launch_matches_release": True,
        "generated": generated,
        "interface_shape": {"m_axi_bundles": m_axi, "s_axi_bundles": s_axi,
                            "ap_rst_n_present": "|ap_rst_n " in rpt},
        "generated_verilog_count": len(list((WORK / "hls/syn/verilog").glob("*.v"))),
        "generated_vhdl_count": len(list((WORK / "hls/syn/vhdl").glob("*.vhd"))),
        "hls_report": {"target_clock_ns": float(clock.group(1)),
                       "estimated_clock_ns": float(clock.group(2)),
                       "uncertainty_ns": float(clock.group(3)),
                       "effective_budget_ns": round(float(clock.group(1)) - float(clock.group(3)), 3),
                       "estimated_margin_to_effective_budget_ns": round(float(clock.group(1)) - float(clock.group(3)) - float(clock.group(2)), 3),
                       "resource_estimates": dict(zip(("BRAM_18K", "DSP", "FF", "LUT", "URAM"), map(int, resources.groups()))),
                       "top_latency_cycles": "unknown", "top_interval_cycles": "unknown",
                       "top_pipeline": "no", "reset_metadata_instance_latency_cycles": 6738},
        "source_check_warnings": [line for line in log_lines if line.startswith("WARNING:")],
        "source_check_errors": [line for line in log_lines if line.startswith("ERROR:")],
        "functional_cpu_and_csim": "V6_ACCEPTED_SEPARATELY_V7_NOT_RERUN",
        "rtl_runtime_ooc_pnr_board": "NOT_RUN_HELD",
        "interpretation": "Successful HLS generation and structural RTL reset observations; estimates are not timing closure or runtime reset acceptance."}
    if evidence["source_check_errors"]:
        raise RuntimeError("source check contains error")
    result_id = save("actual_result_evidence.json", evidence)
    print(json.dumps({"status": evidence["status"], "files": len(files),
                      "preprocessed_tus": len(pp_files), "dependencies": len(all_deps),
                      "result_sha256": result_id["sha256"]}, sort_keys=True))


if __name__ == "__main__":
    main()
