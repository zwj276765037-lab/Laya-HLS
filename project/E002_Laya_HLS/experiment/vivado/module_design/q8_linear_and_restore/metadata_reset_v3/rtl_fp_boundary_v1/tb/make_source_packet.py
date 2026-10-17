#!/usr/bin/env python3
"""Seal the 28 actual FP inputs, tools, libraries, and maintained bench source."""

import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "source/source_packet.json"
RELEASE = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_source_preparation_release.json")
SCORER = ROOT.parent / "rtl_full_dimensions_v1/source_binding_v6/source_packet.json"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
RELEASE_SHA256 = "89b847de5851a6a8a836a70fba31bac78c468e8a847f3f110b19c3aa77c2830d"


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def main() -> None:
    if OUT.exists():
        raise RuntimeError("source packet already exists")
    if record(RELEASE)["sha256"] != RELEASE_SHA256:
        raise RuntimeError("design release identity mismatch")
    release = json.loads(RELEASE.read_text())
    assert len(release["exact_wrappers"]) == 7
    table = json.loads((ROOT / "tb/frozen_case_table.json").read_text())
    if table["source_release_sha256"] != RELEASE_SHA256:
        raise RuntimeError("case table release identity mismatch")
    selected = [("fdiv", "fdiv", 0), ("both_fmul_wrappers_each", "fmul2", 1),
                ("both_fmul_wrappers_each", "fmul3", 2), ("fadd", "fadd", 3),
                ("sitofp", "sitofp", 4), ("both_fcmp_wrappers_each", "fcmp1", 5),
                ("both_fcmp_wrappers_each", "fcmp2", 6)]
    reconstructed = []
    for group, name, wrapper_id in selected:
        for case in release["mandatory_vectors"][group]:
            if group == "both_fcmp_wrappers_each":
                for opname, op in (("AP_OEQ_1", 1), ("AP_OGT_2", 2), ("AP_OGE_3", 3),
                                   ("AP_OLT_4", 4), ("AP_OLE_5", 5), ("AP_ONE_6", 6),
                                   ("AP_UNO_8", 8)):
                    reconstructed.append({"wrapper": name, "wrapper_id": wrapper_id,
                                          "case_id": case["id"] + "_" + opname,
                                          "a_bits": case["a_bits"], "b_bits": case["b_bits"],
                                          "opcode": op, "expected_bits": f"{case['R0_expected'][opname]:08x}",
                                          "source_group": group})
            else:
                reconstructed.append({"wrapper": name, "wrapper_id": wrapper_id,
                                      "case_id": case["id"],
                                      "a_bits": case.get("a_bits", case.get("i32_bits")),
                                      "b_bits": case.get("b_bits", "00000000"),
                                      "opcode": 0, "expected_bits": case["R0_expected_bits"],
                                      "source_group": group})
    if table["case_count"] != 119 or table["rows"] != reconstructed:
        raise RuntimeError("frozen cases differ from the reviewed 119-vector table")
    inputs = []
    for item in release["exact_wrappers"]:
        for key in ("outer_verilog", "simulation_vhdl", "Tcl", "XCI"):
            expected = item[key]
            actual = record(Path(expected["path"]))
            if actual["bytes"] != expected["bytes"] or actual["sha256"] != expected["sha256"]:
                raise RuntimeError(f"released input drift: {actual['path']}")
            inputs.append({"wrapper": item["name"], "kind": key, **actual})
    scorer = json.loads(SCORER.read_text())
    libs = [item for item in scorer["immutable_files"] if "/data/xsim/ip/floating_point_v7_1_21/" in item["path"]]
    if len(libs) != 3:
        raise RuntimeError(f"unexpected accepted FP library closure: {len(libs)}")
    for item in libs:
        actual = record(Path(item["path"]))
        if actual["sha256"] != item["sha256"] or actual["bytes"] != item["bytes"]:
            raise RuntimeError(f"installed FP library drift: {item['path']}")
    tools = [record(VIVADO / "bin" / tool) for tool in ("xvhdl", "xvlog", "xelab", "xsim")]
    source = [ROOT / "tb/fp_boundary_top.sv", ROOT / "tb/frozen_case_table.json",
              ROOT / "tb/frozen_cases.svh", ROOT / "tb/generate_cases.py",
              ROOT / "tb/independent_check.py", ROOT / "tb/build_static.sh",
              ROOT / "tb/run_boundary.sh", ROOT / "tb/verify_source_binding.py",
              ROOT / "tb/make_source_packet.py", ROOT / "source/design.md",
              ROOT / "source/results.md", ROOT / "rtl/README.md"]
    maintained = [record(path) for path in source]
    packet = {"schema": "q8_actual_fp_boundary_source_packet_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "SOURCE_ONLY_NO_COMPILER_OR_SIMULATOR_EXECUTION",
              "release": record(RELEASE), "inherited_accepted_scorer_packet": record(SCORER),
              "source_inputs": inputs, "installed_fp_library_files": libs,
              "tool_launchers": tools, "maintained_source": maintained,
              "bound_wrapper_count": 7, "bound_input_count": 28,
              "xsim_link_libraries": ["floating_point_v7_1_21", "unisims_ver", "xpm", "secureip"],
              "snapshot_runtime_mutable_allowlist": ["fp_boundary/xsim_script.tcl",
                                                       "fp_boundary/xsimSettings.ini",
                                                       "fp_boundary/xsimkernel.log",
                                                       "fp_boundary/xsimcrash.log"]}
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"FP_SOURCE_PACKET_CREATED inputs={len(inputs)} maintained={len(maintained)} sha256={record(OUT)['sha256']}")


if __name__ == "__main__":
    main()
