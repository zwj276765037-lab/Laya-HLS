#!/usr/bin/env python3
"""Read-only source checks and event-order mock; never invokes a DUT or EDA tool."""
from __future__ import annotations

import ast
from datetime import datetime, timezone
import difflib
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
OLD = ROOT.parent / "rtl_static_finite_v1"
TB = ROOT / "tb"
OUT = ROOT / "source/source_static_audit.json"
DIFF = ROOT / "source/old_to_new_tb.diff"
EXPECTED_CHANGED = {
    "README.md", "att_axi_monitor.sv", "att_finite_control.svh",
    "build_static.sh", "run_mode.sh", "verify_binding.py",
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def record(path: Path) -> dict:
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": sha(path)}


def section(source: str, start: str, end: str) -> str:
    return source[source.index(start):source.index(end, source.index(start)) + len(end)]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def mock_capture(monitor: dict, adapter: dict, baseline: int) -> dict | None:
    if not adapter["full"] or not adapter["held_special"]:
        return None
    fields = ("valid", "ordinal", "address", "beat", "arlen", "arsize", "arid", "rid", "last")
    require(all(monitor.get(key) is not None for key in fields), "missing/unknown record")
    require(monitor["valid"] and monitor["last"], "missing valid or last")
    require(monitor["ordinal"] == monitor["endpoint_count"] == adapter["accepted_count"],
            "ordinal association")
    require(monitor["ordinal"] > baseline, "command baseline order")
    require(monitor["beat"] == monitor["arlen"], "last-beat association")
    require(monitor["rid"] == monitor["arid"], "ID association")
    return {"absolute": monitor["ordinal"], "relative": monitor["ordinal"] - baseline,
            "address": monitor["address"], "beat": monitor["beat"]}


def main() -> None:
    require(not OUT.exists(), "source static audit already sealed")
    old_files = {p.name: p for p in (OLD / "tb").iterdir() if p.is_file()}
    new_files = {p.name: p for p in TB.iterdir() if p.is_file()}
    require(set(new_files) - set(old_files) == {"README.md"} and
            not (set(old_files) - set(new_files)), "unexpected TB file-set change")
    changed = {"README.md"} | {name for name in old_files
                               if sha(old_files[name]) != sha(new_files[name])}
    require(changed == EXPECTED_CHANGED, f"unexpected TB changes: {changed}")
    unchanged = sorted(set(old_files) - changed)

    diff_lines: list[str] = []
    for name in sorted(changed):
        old_text = old_files[name].read_text() if name in old_files else ""
        new_text = new_files[name].read_text()
        diff_lines.extend(difflib.unified_diff(
            old_text.splitlines(keepends=True), new_text.splitlines(keepends=True),
            fromfile=f"rtl_static_finite_v1/tb/{name}",
            tofile=f"rtl_static_finite_monitor_v2/tb/{name}"))
    require(DIFF.read_text() == "".join(diff_lines), "exact TB diff changed")

    old_monitor = old_files["att_axi_monitor.sv"].read_text()
    monitor = new_files["att_axi_monitor.sv"].read_text()
    original_lines = iter(old_monitor.splitlines(keepends=True))
    need = next(original_lines, None)
    for line in monitor.splitlines(keepends=True):
        if line == need:
            need = next(original_lines, None)
    require(need is None, "an original monitor line was removed or changed")
    record_fields = ("valid", "ordinal", "address", "beat", "arlen", "arsize", "arid", "rid", "last")
    reset = section(monitor, "if (!resetn) begin", "end else begin")
    r_branch = section(monitor, "if (rvalid && rready) begin", "if (bvalid && bready) begin")
    for name in record_fields:
        field = "r_accept_" + name
        require(re.search(r"\b" + field + r"\s*=", reset) is not None, f"{field} reset")
        require(re.search(r"\b" + field + r"\s*=", r_branch) is not None, f"{field} capture")
        require(len(re.findall(r"\b" + field + r"\s*=", monitor)) == 2,
                f"{field} written outside reset/R accept")
    require(r_branch.index("ATT_AXI_R_RANGE") < r_branch.index("r_accept_valid=1'b1")
            < r_branch.index("r_count++") < r_branch.index("ar_head="),
            "record must follow checks and precede queue advance")
    require("r_accept_ordinal=r_count+32'd1;" in r_branch and
            "r_accept_address=first_byte[63:0];" in r_branch and
            "r_accept_beat=ar_beat[ar_head];" in r_branch,
            "ordinal, effective address or pre-advance beat mapping")

    old_control = old_files["att_finite_control.svh"].read_text()
    control = new_files["att_finite_control.svh"].read_text()
    for start, end in (("r_hold_reg <= cmd_idx==2", ";"),
                       ("b_hold_reg <= cmd_idx==2", ";"),
                       ("function automatic logic [10:0] hold_failure_bits()", "endfunction"),
                       ("task automatic print_hold_row", "endtask")):
        if start in old_control:
            require(section(old_control, start, end) == section(control, start, end),
                    f"original control section changed: {start}")
    require("ram_mon.ar_beat[" not in control and
            "ram_mon.ar_address[" not in control and
            "ram_mon.ar_size[" not in control,
            "live unpacked-array hierarchical read remains")
    for text in ("selected_r_adapter_full && selected_r_adapter_held_special",
                 "selected_r_accept_ordinal !== ram_r_count[SELECTED_PORT]",
                 "selected_r_accept_ordinal !== selected_r_adapter_accepted_count",
                 "r_selected_index=selected_r_accept_ordinal-before_r[SELECTED_PORT]",
                 "selected_r_accept_beat !== selected_r_accept_arlen",
                 "selected_r_accept_rid !== selected_r_accept_arid",
                 "ATT_FINITE_R_ACCEPT_CAPTURE", "ATT_FINITE_R_ACCEPT_ASSOCIATION",
                 "ATT_FINITE_SPECIAL_HOLD_MISSING"):
        require(text in control, f"missing association/check: {text}")
    require(control.count("ATT_FINITE_R_ACCEPT_CAPTURE") == 1,
            "acceptance capture log must occur once in source")

    parsed_python = []
    checked_shell = []
    for path in sorted(TB.iterdir()):
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=str(path))
            parsed_python.append(path.name)
        elif path.suffix == ".sh":
            result = subprocess.run(["/usr/bin/bash", "-n", str(path)], capture_output=True)
            require(result.returncode == 0, f"shell syntax: {path}: {result.stderr.decode()}")
            checked_shell.append(path.name)
    for path in sorted((ROOT / "source").glob("*.py")):
        ast.parse(path.read_text(), filename=str(path))
        parsed_python.append("source/" + path.name)

    monitor_event = {"valid": True, "ordinal": 8, "endpoint_count": 8,
                     "address": 0x2400012300, "beat": 15, "arlen": 15,
                     "arsize": 6, "arid": 1, "rid": 1, "last": True}
    adapter_event = {"full": True, "held_special": True, "accepted_count": 8}
    require(mock_capture(monitor_event, adapter_event, 7) ==
            {"absolute": 8, "relative": 1, "address": 0x2400012300, "beat": 15},
            "settled acceptance mock")
    require(mock_capture(monitor_event, {**adapter_event, "full": False}, 7) is None,
            "no capture before adapter full")
    for bad_monitor, bad_adapter in (({**monitor_event, "valid": None}, adapter_event),
                                     (monitor_event, {**adapter_event, "accepted_count": 7}),
                                     ({**monitor_event, "beat": 14}, adapter_event),
                                     ({**monitor_event, "rid": 0}, adapter_event)):
        try:
            mock_capture(bad_monitor, bad_adapter, 7)
        except AssertionError:
            pass
        else:
            raise AssertionError("mock accepted an inconsistent record")

    result = {
        "schema": "attention_v5_head15_passive_r_accept_source_static_audit_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "status": "SOURCE_ONLY_STATIC_CHECKS_PASS_NO_COMPILER_OR_DUT_EXECUTION",
        "old_source_packet_sha256": sha(OLD / "source/source_packet.json"),
        "design_sha256": sha(ROOT / "source/design.md"),
        "exact_diff": record(DIFF),
        "changed_tb_files": sorted(changed),
        "unchanged_tb_files": unchanged,
        "python_ast_parsed": parsed_python,
        "shell_syntax_checked": checked_shell,
        "monitor_old_lines_preserved": True,
        "monitor_reset_and_R_only_record_writes": True,
        "record_after_R_checks_before_queue_advance": True,
        "no_live_dynamic_array_capture": True,
        "original_hold_generation_and_predicates_unchanged": True,
        "mock_cases_passed": 6,
        "static_only_limit": "No SV compiler, EDA, DUT runtime, materialization or oracle was invoked."
    }
    OUT.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("ATT_FINITE_MONITOR_SOURCE_STATIC_PASS changed=%d unchanged=%d mock=6" %
          (len(changed), len(unchanged)))


if __name__ == "__main__":
    main()
