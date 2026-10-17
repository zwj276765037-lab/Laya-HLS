#!/usr/bin/env python3
"""Check imported XCI identity and project-local paths before IP generation."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
MANIFEST = ROOT / "source/input_manifest.json"
ALLOWED_DIFFS = {
    "/ip_inst/gen_directory",
    "/checksum",
    "/ip_inst/parameters/runtime_parameters/OUTPUTDIR/0/value",
}


def digest(path: Path) -> dict:
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def differences(a: object, b: object, where: str = "") -> list[dict]:
    if isinstance(a, dict) and isinstance(b, dict):
        rows = []
        for key in sorted(a.keys() | b.keys()):
            path = where + "/" + key.replace("~", "~0").replace("/", "~1")
            if key not in a or key not in b:
                rows.append({"path": path, "original": a.get(key), "imported": b.get(key)})
            else:
                rows.extend(differences(a[key], b[key], path))
        return rows
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return [{"path": where, "original": a, "imported": b}]
        rows = []
        for index, (left, right) in enumerate(zip(a, b)):
            rows.extend(differences(left, right, f"{where}/{index}"))
        return rows
    return [] if type(a) is type(b) and a == b else [
        {"path": where, "original": a, "imported": b}
    ]


def real_inside(path: Path, root: Path) -> bool:
    return path.is_absolute() and path.resolve().is_relative_to(root.resolve()) and path.resolve() != root.resolve()


def outputdir_value(xci: dict) -> str:
    """Require the exact observed one-element runtime OUTPUTDIR structure."""
    rows = xci["ip_inst"]["parameters"]["runtime_parameters"]["OUTPUTDIR"]
    if (not isinstance(rows, list) or len(rows) != 1 or
            not isinstance(rows[0], dict) or set(rows[0]) != {"value"} or
            not isinstance(rows[0]["value"], str) or not rows[0]["value"]):
        raise ValueError("OUTPUTDIR must be one object containing only a nonempty string value")
    return rows[0]["value"]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("run_dir", type=Path)
    parser.add_argument("map_path", type=Path)
    args = parser.parse_args()
    run_dir = args.run_dir.resolve()
    project_dir = run_dir / "vivado"
    report_path = project_dir / "ip_import_preflight.json"
    failures = []
    manifest = json.loads(MANIFEST.read_text())
    original_by_name = {Path(row["path"]).stem: row for row in manifest["files"] if row["kind"] == "ip_xci"}
    with args.map_path.open(newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ["ip", "staged_xci", "imported_xci", "output_dir", "is_locked"]:
            raise RuntimeError("unexpected IP import map columns")
        mapping = list(reader)
    names = [row["ip"] for row in mapping]
    if len(mapping) != 7 or len(set(names)) != 7 or set(names) != set(original_by_name):
        raise RuntimeError("IP import map does not bind seven original IP names")
    imported_paths = [Path(row["imported_xci"]).resolve() for row in mapping]
    if len(set(imported_paths)) != 7 or len({path.parent for path in imported_paths}) != 7:
        failures.append("seven IPs do not have distinct imported XCI files and directories")
    checks = []
    for row in mapping:
        name = row["ip"]
        original_row = original_by_name[name]
        original = Path(original_row["path"])
        stage = Path(row["staged_xci"])
        imported = Path(row["imported_xci"])
        output = Path(row["output_dir"])
        expected_stage = run_dir / "stage/ip" / f"{name}.xci"
        expected_output = project_dir / "q8_same_source_ooc.gen/sources_1/ip" / name
        if row["is_locked"].lower() not in {"0", "false"}:
            failures.append(f"{name}: imported IP is locked: {row['is_locked']}")
        if stage.resolve() != expected_stage.resolve() or not real_inside(stage, run_dir / "stage/ip"):
            failures.append(f"{name}: staged XCI path mismatch or escape")
        if not real_inside(imported, project_dir) or not imported.is_file():
            failures.append(f"{name}: imported XCI missing or escapes project")
        if imported.name != f"{name}.xci" or imported.parent.name != name:
            failures.append(f"{name}: imported XCI is not in its own named directory")
        if not real_inside(output, project_dir) or output.resolve() != expected_output.resolve():
            failures.append(f"{name}: IP_OUTPUT_DIR mismatch or escape")
        original_hash = digest(original)
        stage_hash = digest(stage)
        imported_hash = digest(imported)
        if original_hash["bytes"] != original_row["bytes"] or original_hash["sha256"] != original_row["sha256"]:
            failures.append(f"{name}: original XCI drifted from manifest")
        if stage_hash["bytes"] != original_hash["bytes"] or stage_hash["sha256"] != original_hash["sha256"]:
            failures.append(f"{name}: staged XCI bytes differ from original")
        original_json = json.loads(original.read_text())
        imported_json = json.loads(imported.read_text())
        diff = differences(original_json, imported_json)
        unexpected = [item for item in diff if item["path"] not in ALLOWED_DIFFS]
        if unexpected:
            failures.append(f"{name}: imported XCI has non-path configuration differences")
        try:
            original_outputdir = outputdir_value(original_json)
            imported_outputdir = outputdir_value(imported_json)
        except (KeyError, TypeError, ValueError) as error:
            failures.append(f"{name}: malformed OUTPUTDIR structure: {error}")
            original_outputdir = None
            imported_outputdir = None
        if imported_outputdir is not None:
            outputdir_path = Path(imported_outputdir)
            resolved_outputdir = (outputdir_path if outputdir_path.is_absolute()
                                  else imported.parent / outputdir_path).resolve()
            if not real_inside(resolved_outputdir, project_dir) or resolved_outputdir != expected_output.resolve():
                failures.append(f"{name}: imported OUTPUTDIR does not resolve to project output")
        else:
            resolved_outputdir = None
        gen_directory = imported_json.get("ip_inst", {}).get("gen_directory")
        if not isinstance(gen_directory, str) or not gen_directory:
            failures.append(f"{name}: imported gen_directory missing")
            resolved_gen = None
        else:
            gen_path = Path(gen_directory)
            resolved_gen = (gen_path if gen_path.is_absolute() else imported.parent / gen_path).resolve()
            if not real_inside(resolved_gen, project_dir) or resolved_gen != expected_output.resolve():
                failures.append(f"{name}: imported gen_directory does not resolve to project output")
        checks.append({
            "ip": name,
            "original": original_hash,
            "staged": stage_hash,
            "imported": imported_hash,
            "is_locked": row["is_locked"],
            "ip_output_dir": str(output),
            "expected_output_dir": str(expected_output),
            "imported_gen_directory": gen_directory,
            "resolved_gen_directory": str(resolved_gen) if resolved_gen is not None else None,
            "original_runtime_outputdir": original_outputdir,
            "imported_runtime_outputdir": imported_outputdir,
            "resolved_runtime_outputdir": str(resolved_outputdir) if resolved_outputdir is not None else None,
            "exact_json_differences": diff,
        })
    result = {
        "schema": "q8_project_local_ip_import_preflight_v1",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "status": "PASS" if not failures else "FAIL",
        "manifest": digest(MANIFEST),
        "map": digest(args.map_path),
        "allowed_json_difference_paths": sorted(ALLOWED_DIFFS),
        "ip_checks": checks,
        "failures": failures,
    }
    if not args.check:
        if report_path.exists():
            raise RuntimeError(f"refusing to overwrite existing import preflight: {report_path}")
        report_path.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Q8_OOC_IMPORT_{result['status']} ip={len(checks)} failures={len(failures)}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
