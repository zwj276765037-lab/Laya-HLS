#!/usr/bin/env python3
"""Check the bounded record wiring and exact v2 diff without EDA execution."""
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
V2 = ROOT.parent / "rtl_static_finite_monitor_v2"
HERE = ROOT / "source"
DIFF = HERE / "v2_to_v3_tb_runner.diff"
OUT = HERE / "source_static_audit.json"
ARCHIVE = HERE / "v2_preimage_archive.json"
CHANGED = {
    "rtl/README.md", "tb/README.md", "tb/att_axi_monitor.sv",
    "tb/att_axi_port.sv", "tb/att_finite_base_h15_r63_top.sv",
    "tb/att_finite_changed_h0_r0_top.sv", "tb/att_finite_control.svh",
    "tb/build_static.sh", "tb/generate_top.py", "tb/run_mode.sh",
    "tb/verify_binding.py",
}
FIELD_MAP = {
    "RREC_VALID_BIT": 118, "RREC_ORD_HI": 117, "RREC_ORD_LO": 86,
    "RREC_ADDR_HI": 85, "RREC_ADDR_LO": 22,
    "RREC_BEAT_HI": 21, "RREC_BEAT_LO": 14,
    "RREC_LEN_HI": 13, "RREC_LEN_LO": 6,
    "RREC_SIZE_HI": 5, "RREC_SIZE_LO": 3,
    "RREC_ARID_BIT": 2, "RREC_RID_BIT": 1, "RREC_LAST_BIT": 0,
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def record(path: Path) -> dict:
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": sha(path)}


def section(source: str, begin: str, end: str) -> str:
    i = source.index(begin)
    return source[i:source.index(end, i) + len(end)]


def main() -> None:
    if DIFF.exists() or OUT.exists():
        raise FileExistsError("source audit and diff require fresh paths")
    prior = json.loads((V2 / "source/source_packet.json").read_text())
    archive = json.loads(ARCHIVE.read_text())
    assert prior["schema"] == "attention_v5_head15_passive_r_accept_monitor_source_packet_v1"
    assert archive["record_count"] == 30 and len(archive["records"]) == 30
    accepted = {str(Path(row["path"]).relative_to(V2)): row
                for row in prior["testbench_and_runner"]}
    accepted["source/source_packet.json"] = {
        "bytes": (V2 / "source/source_packet.json").stat().st_size,
        "sha256": sha(V2 / "source/source_packet.json")}
    assert set(accepted) == {row["relative_path"] for row in archive["records"]}
    for row in archive["records"]:
        name = row["relative_path"]
        original = V2 / name
        copy = Path(row["archived_path"])
        assert copy.is_file() and original.is_file()
        assert row["bytes"] == accepted[name]["bytes"] == copy.stat().st_size
        assert row["sha256"] == accepted[name]["sha256"] == sha(copy) == sha(original)

    old_paths = {str(path.relative_to(V2)): path
                 for folder in ("tb", "rtl")
                 for path in (V2 / folder).iterdir() if path.is_file()}
    active_paths = {str(path.relative_to(ROOT)): path
                    for folder in ("tb", "rtl")
                    for path in (ROOT / folder).iterdir() if path.is_file()}
    assert set(active_paths) == set(old_paths), "maintained TB/RTL file-set changed"
    changed = {name for name, path in old_paths.items() if sha(path) != sha(active_paths[name])}
    assert changed == CHANGED, f"unexpected active changes: {changed ^ CHANGED}"
    diff_lines = []
    for name in sorted(changed):
        diff_lines.extend(difflib.unified_diff(
            old_paths[name].read_text().splitlines(keepends=True),
            active_paths[name].read_text().splitlines(keepends=True),
            fromfile=f"rtl_static_finite_monitor_v2/{name}",
            tofile=f"rtl_static_finite_monitor_v3/{name}"))
    DIFF.write_text("".join(diff_lines))

    monitor = (ROOT / "tb/att_axi_monitor.sv").read_text()
    port = (ROOT / "tb/att_axi_port.sv").read_text()
    control = (ROOT / "tb/att_finite_control.svh").read_text()
    old_control = (V2 / "tb/att_finite_control.svh").read_text()
    packed = re.sub(r"\s+", "", monitor)
    expected_pack = ("accepted_r_record={1'b1,r_count+32'd1,first_byte[63:0],"
                     "ar_beat[ar_head],ar_length[ar_head],ar_size[ar_head],"
                     "ar_id[ar_head],rid,rlast};")
    assert expected_pack in packed
    assert "output logic [118:0] accepted_r_record" in monitor
    assert len(re.findall(r"\baccepted_r_record\s*=(?!=)", monitor)) == 2
    r_branch = section(monitor, "if (rvalid && rready) begin", "if (bvalid && bready) begin")
    assert r_branch.index("ATT_AXI_R_RANGE") < r_branch.index("accepted_r_record=") < \
           r_branch.index("r_count++") < r_branch.index("ar_head=")
    assert "accepted_r_record='0;" in section(monitor, "if (!resetn) begin", "end else begin")
    assert port.count(".accepted_r_record(") == 2
    assert port.count("assign ram_accepted_r_record = ram_monitor_accepted_r_record;") == 1
    assert "output logic [118:0] ram_accepted_r_record" in port
    for name in ("base_h15_r63", "changed_h0_r0"):
        top = (ROOT / f"tb/att_finite_{name}_top.sv").read_text()
        assert "logic [118:0] ram_accepted_r_record [0:6];" in top
        assert len(re.findall(r"\.ram_accepted_r_record\(ram_accepted_r_record\[[0-6]\]\)", top)) == 7
        assert "`include \"att_finite_control.svh\"" in top
    constants = {name: int(value) for name, value in
                 re.findall(r"\b(RREC_[A-Z_]+)\s*=\s*(\d+)", control)}
    assert constants == FIELD_MAP
    assert 1 + 32 + 64 + 8 + 8 + 3 + 1 + 1 + 1 == 119
    assert "selected_r_accept_record=ram_accepted_r_record[SELECTED_PORT]" in control
    assert "ram_mon.r_accept_" not in control
    for code in ("ATT_R_RECORD_MON_RESET", "ATT_R_RECORD_MON_FIRST"):
        assert code in monitor
    for code in ("ATT_R_RECORD_PORT_RESET", "ATT_R_RECORD_PORT_FIRST"):
        assert code in port
    for code in ("ATT_R_RECORD_TOP_RESET", "ATT_R_RECORD_TOP_FIRST"):
        assert code in control
    assert "port_reset_seen_posedge <= !resetn" in port
    assert "top_reset_seen_posedge <= !resetn" in control
    assert set(re.findall(r"ATT_FINITE_[A-Z_]+", old_control)) == \
           set(re.findall(r"ATT_FINITE_[A-Z_]+", control))
    for begin, end in (("r_hold_reg <= cmd_idx==2", ";"),
                       ("b_hold_reg <= cmd_idx==2", ";"),
                       ("function automatic logic [10:0] hold_failure_bits()", "endfunction"),
                       ("task automatic print_case_diagnostics", "endtask")):
        assert section(old_control, begin, end) == section(control, begin, end)
    for item in ("selected_r_adapter_full && selected_r_adapter_held_special",
                 "selected_r_accept_ordinal !== ram_r_count[SELECTED_PORT]",
                 "selected_r_accept_ordinal !== selected_r_adapter_accepted_count",
                 "r_selected_index=selected_r_accept_ordinal-before_r[SELECTED_PORT]",
                 "selected_r_accept_beat !== selected_r_accept_arlen",
                 "selected_r_accept_rid !== selected_r_accept_arid",
                 "ATT_FINITE_R_ACCEPT_ASSOCIATION", "ATT_FINITE_SPECIAL_HOLD_MISSING"):
        assert item in control, item

    parsed = []
    shell = []
    for path in sorted((ROOT / "tb").iterdir()):
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=str(path))
            parsed.append(str(path))
        elif path.suffix == ".sh":
            proc = subprocess.run(["/usr/bin/bash", "-n", str(path)], capture_output=True)
            assert proc.returncode == 0, (path, proc.stderr)
            shell.append(str(path))
    for path in sorted(HERE.glob("*.py")):
        ast.parse(path.read_text(), filename=str(path))
        parsed.append(str(path))
    result = {
        "schema": "head15_monitor_v3_source_static_audit_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "status": "SOURCE_ONLY_STATIC_CHECKS_PASS_NO_EDA",
        "v2_source_packet_sha256": sha(V2 / "source/source_packet.json"),
        "archive": record(ARCHIVE), "design_sha256": sha(HERE / "design.md"),
        "diff": record(DIFF), "changed_files": sorted(changed),
        "unchanged_file_count": len(old_paths) - len(changed),
        "python_ast_parsed": parsed, "shell_syntax_checked": shell,
        "record_bits": 119, "field_map": FIELD_MAP,
        "monitor_record_procedural_writes": 2,
        "named_monitor_outputs_per_port": 2,
        "named_top_port_records_per_variant": 7,
        "original_hold_and_fatal_tags_preserved": True,
        "limits": "No compiler, simulator, DUT, materializer, oracle, HLS or Vivado tool invoked.",
    }
    OUT.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"HEAD15_V3_SOURCE_STATIC_PASS changed={len(changed)} unchanged={len(old_paths)-len(changed)}")


if __name__ == "__main__":
    main()
