"""Read-only identity rules for the accepted a2 project and a future clone."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import stat
import xml.etree.ElementTree as ET


OOC = Path(__file__).resolve().parents[2]
ACCEPTANCE = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/"
                  "Laya-baseline/results/attention_rtl_repair_20261008/"
                  "reviewer_q8_ooc_a2_actual_project_compile_closure_acceptance.json")
ACCEPTANCE_SHA256 = "8f60db03f77021d0e665de5fe6fc21362f466577980ca67db22ffd31d876be60"
SOURCE = OOC / "runs/project_prepare_local_import_v2_a2"
XPR = Path("vivado/q8_same_source_ooc.xpr")
SOURCE_FILE_COUNT = 438
COMPILE_COUNT = 243


def record(path: Path) -> dict:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": digest.hexdigest()}


def matches(row: dict) -> bool:
    actual = record(Path(row["path"]))
    return all(actual[key] == row[key] for key in ("bytes", "sha256"))


def accepted_evidence() -> tuple[dict, dict]:
    if record(ACCEPTANCE)["sha256"] != ACCEPTANCE_SHA256:
        raise RuntimeError("Astra a2 acceptance identity changed")
    acceptance = json.loads(ACCEPTANCE.read_text())
    if (acceptance["status"] !=
            "ACCEPTED_ACTUAL_PROJECT_AND_EXACT_SYNTHESIS_SOURCE_CLOSURE_NO_TOP_SYNTHESIS" or
            Path(acceptance["accepted_run_root"]) != SOURCE or
            not matches(acceptance["evidence"]) or
            not matches(acceptance["accepted_project_xpr"])):
        raise RuntimeError("accepted a2 project/evidence binding changed")
    evidence = json.loads(Path(acceptance["evidence"]["path"]).read_text())
    if (evidence["status"] != "PROJECT_AND_PRODUCT_IDENTITY_PASS_NO_TOP_SYNTHESIS" or
            evidence["run_root"] != str(SOURCE) or
            evidence["top_synthesis"] != "NOT_RELEASED_NOT_RUN" or
            evidence["original_input_count"] != 366 or
            evidence["staged_count"] != 359 or
            len(evidence["actual_compile_closure"]) != COMPILE_COUNT):
        raise RuntimeError("accepted a2 closure structure changed")
    return acceptance, evidence


def tree(root: Path) -> list[dict]:
    if not root.is_dir():
        raise RuntimeError(f"project tree absent: {root}")
    rows = []
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            if path.is_symlink():
                raise RuntimeError(f"symlink forbidden in isolated project: {path}")
            if not (path.is_dir() or path.is_file()):
                raise RuntimeError(f"special file forbidden: {path}")
        for name in files:
            path = Path(directory) / name
            rows.append({"relative_path": str(path.relative_to(root)),
                         "mode": oct(stat.S_IMODE(path.stat().st_mode)),
                         **{key: value for key, value in record(path).items()
                            if key != "path"}})
    return sorted(rows, key=lambda item: item["relative_path"])


def check_source() -> tuple[dict, list[dict]]:
    acceptance, evidence = accepted_evidence()
    for key in ("original_inputs", "staged_inputs", "actual_compile_closure"):
        if not all(matches(row) for row in evidence[key]):
            raise RuntimeError(f"accepted {key} content drift")
    for row in evidence["product_identity"]["generated_ip_products"]:
        if not all(matches(row[key]) for key in
                   ("original", "actual_synthesis", "generated_simulation")):
            raise RuntimeError("accepted generated FP product drift")
    for row in evidence["product_identity"]["shared_library_candidates"]:
        if not matches(row["original"]):
            raise RuntimeError("accepted shared library drift")
    rows = tree(SOURCE)
    if len(rows) != SOURCE_FILE_COUNT:
        raise RuntimeError(f"accepted a2 tree file count changed: {len(rows)}")
    if len([row for row in rows if row["relative_path"] == str(XPR)]) != 1:
        raise RuntimeError("accepted project XPR absent")
    return {"acceptance": record(ACCEPTANCE),
            "a2_final_evidence": record(Path(acceptance["evidence"]["path"])),
            "original_inputs": 366, "staged_inputs": 359,
            "compiled_files": COMPILE_COUNT}, rows


def rebound_xpr(original: bytes, destination: Path) -> bytes:
    old_path = str(SOURCE / XPR).encode()
    new_path = str(destination / XPR).encode()
    old_token = b'Path="' + old_path + b'"'
    new_token = b'Path="' + new_path + b'"'
    if original.count(old_token) != 1 or original.count(str(SOURCE).encode()) != 1:
        raise RuntimeError("XPR is not a one-attribute project-path rebind")
    result = original.replace(old_token, new_token)
    if result.replace(new_token, old_token) != original:
        raise RuntimeError("XPR rebind changed other bytes")
    old_root, new_root = ET.fromstring(original), ET.fromstring(result)
    if old_root.tag != "Project" or new_root.tag != "Project" or \
            old_root.attrib["Path"] != str(SOURCE / XPR) or \
            new_root.attrib["Path"] != str(destination / XPR):
        raise RuntimeError("XPR root project path parse mismatch")
    return result


def check_clone(destination: Path, source_rows: list[dict]) -> dict:
    destination = destination.resolve()
    if destination == SOURCE or destination.is_relative_to(SOURCE) or \
            SOURCE.is_relative_to(destination):
        raise RuntimeError("clone destination overlaps accepted a2 project")
    clone_rows = tree(destination)
    old_by_name = {row["relative_path"]: row for row in source_rows}
    new_by_name = {row["relative_path"]: row for row in clone_rows}
    if set(old_by_name) != set(new_by_name):
        raise RuntimeError("clone file set differs from accepted a2 project")
    for name, original in old_by_name.items():
        copied = new_by_name[name]
        if copied["mode"] != original["mode"]:
            raise RuntimeError(f"clone mode changed: {name}")
        if name == str(XPR):
            expected = rebound_xpr((SOURCE / XPR).read_bytes(), destination)
            if (destination / XPR).read_bytes() != expected:
                raise RuntimeError("clone XPR has changes beyond Project Path")
        elif (copied["bytes"], copied["sha256"]) != \
                (original["bytes"], original["sha256"]):
            raise RuntimeError(f"clone content changed: {name}")
    _, evidence = accepted_evidence()
    closure = []
    for row in evidence["actual_compile_closure"]:
        relative = Path(row["path"]).relative_to(SOURCE)
        clone_path = destination / relative
        actual = record(clone_path)
        if (actual["bytes"], actual["sha256"]) != \
                (row["bytes"], row["sha256"]):
            raise RuntimeError(f"cloned compile input changed: {relative}")
        closure.append({"library": row["library"], "file_type": row["file_type"],
                        **actual})
    import_report = json.loads((SOURCE / "vivado/ip_import_preflight.json").read_text())
    if import_report["status"] != "PASS" or len(import_report["ip_checks"]) != 7:
        raise RuntimeError("accepted imported-IP preflight changed")
    for row in import_report["ip_checks"]:
        name = row["ip"]
        imported = destination / Path(row["imported"]["path"]).relative_to(SOURCE)
        data = json.loads(imported.read_text())
        expected = destination / "vivado/q8_same_source_ooc.gen/sources_1/ip" / name
        gen = data["ip_inst"]["gen_directory"]
        output = data["ip_inst"]["parameters"]["runtime_parameters"]["OUTPUTDIR"]
        if not isinstance(output, list) or len(output) != 1 or \
                not isinstance(output[0], dict) or set(output[0]) != {"value"}:
            raise RuntimeError(f"cloned IP OUTPUTDIR structure changed: {name}")
        if (imported.parent / gen).resolve() != expected.resolve() or \
                (imported.parent / output[0]["value"]).resolve() != expected.resolve():
            raise RuntimeError(f"cloned IP output path escapes fresh project: {name}")
    return {"clone_file_count": len(clone_rows), "clone_files": clone_rows,
            "actual_compile_closure": closure,
            "compiled_breakdown": {"verilog": 230, "fp_synth_vhdl": 7,
                                   "shared_synth_vhdl": 6},
            "imported_ip_count": 7,
            "historical_import_map_is_not_active_binding": True}
