#!/usr/bin/env python3
"""Read-only verification of the frozen source packet before a later stage."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import shlex
import shutil
import stat
from pathlib import Path

RUNTIME_ARTIFACTS = {f"q8_full_scorer/{name}" for name in (
    "xsim_script.tcl", "xsimSettings.ini", "xsimkernel.log", "xsimcrash.log")}


def digest(path: Path) -> tuple[int, str]:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return path.stat().st_size, h.hexdigest()


def inventory(root: Path) -> list[dict]:
    if not root.is_dir():
        raise ValueError(f"snapshot absent: {root}")
    result = []
    for path in sorted(root.rglob("*")):
        if path.is_file():
            size, sha = digest(path)
            result.append({"relative_path": str(path.relative_to(root)),
                           "bytes": size, "sha256": sha})
    return result


def verify_cpu_build(binary: Path, packet: dict) -> dict:
    if not binary.is_file() or binary.is_symlink():
        raise ValueError(f"CPU binary absent or linked: {binary}")
    immutable = {item["path"] for item in packet["immutable_files"]}
    contract = packet["cpu_dependency_contract"]
    closure = contract["literal_include_closure"]
    dependency_files = []
    objects = []
    for stem, source_name in (("q8_joint_tm4tn8", "q8_joint_tm4tn8.cpp"),
                              ("test_q8_full_scorer", "test_q8_full_scorer.cpp")):
        depfile = binary.parent / f"{stem}.d"
        objfile = binary.parent / f"{stem}.o"
        if (not depfile.is_file() or depfile.is_symlink() or
            not objfile.is_file() or objfile.is_symlink()):
            raise ValueError(f"CPU translation-unit evidence absent: {stem}")
        raw = depfile.read_text().replace("\\\n", " ")
        if ":" not in raw:
            raise ValueError(f"malformed CPU dependency file: {depfile}")
        paths = shlex.split(raw.split(":", 1)[1])
        if not paths or any(not Path(path).is_absolute() for path in paths):
            raise ValueError(f"non-absolute CPU dependency path: {depfile}")
        resolved = sorted({str(Path(path).resolve()) for path in paths})
        uncovered = set(resolved) - immutable
        unscanned = set(resolved) - set(closure[source_name])
        if uncovered or unscanned:
            raise ValueError(f"unbound CPU dependency from {depfile}: " +
                             str({"unhashed": sorted(uncovered),
                                  "outside_literal_scan": sorted(unscanned)}))
        if not any(Path(path).name == source_name for path in resolved):
            raise ValueError(f"CPU dependency file omits source: {depfile}")
        dependency_files.append({"path": str(depfile.resolve()),
                                 "bytes": digest(depfile)[0],
                                 "sha256": digest(depfile)[1],
                                 "dependencies": resolved})
        objects.append({"path": str(objfile.resolve()),
                        "bytes": digest(objfile)[0],
                        "sha256": digest(objfile)[1]})
    return {"path": str(binary.resolve()), "bytes": digest(binary)[0],
            "sha256": digest(binary)[1],
            "mode": oct(stat.S_IMODE(binary.stat().st_mode)),
            "dependency_files": dependency_files, "objects": objects}


def verify_fixture(root: Path, packet: dict) -> dict:
    report_path = root / "fixture_report.json"
    report = json.loads(report_path.read_text())
    if (report["schema"] != "q8_full_scorer_first_pilot_fixture_v1" or
        report["status"] != "INDEPENDENT_FULL_K_N_R0_AND_FROZEN_NODE_BIT_EXACT" or
        report["page_count"] != 341 or len(report["commands"]) != 3):
        raise ValueError("fixture contract")
    entries = list(report["products"].values())
    entries += [p["image"] for p in report["pages"].values()]
    for command in report["commands"]:
        entries += [command[key] for key in (
            "descriptor", "header", "observed", "out0", "out1")]
    for entry in entries:
        path = root / entry["relative_path"]
        if (not path.is_file() or path.is_symlink() or
            digest(path) != (entry["bytes"], entry["sha256"])):
            raise ValueError(f"fixture product changed: {path}")
    preserved = packet["first_attempt_preserved_fixture_products"]
    if len(preserved) != 9:
        raise ValueError("first-attempt fixture product contract")
    for entry in preserved:
        relative = entry["relative_path"]
        if not relative.startswith("fixture/"):
            raise ValueError(f"first-attempt fixture path: {relative}")
        path = root / relative.removeprefix("fixture/")
        if digest(path) != (entry["bytes"], entry["sha256"]):
            raise ValueError(f"first-attempt fixture product changed: {path}")
    contract = packet["aux_final_page_contract"]
    if contract != {"bo_bytes": 1671872, "bias_base": 1667776,
                    "bias_span": 4096, "page_base": 1671168,
                    "source_prefix_bytes": 704, "forbidden_suffix_bytes": 3392,
                    "sentinel": 165}:
        raise ValueError("AUX final page contract")
    expected_partial = {"port": "aux", "slot": 2, "bo_offset": 1671168,
                        "source_prefix_interval": [1671168, 1671872],
                        "source_prefix_bytes": 704,
                        "forbidden_suffix_interval": [1671872, 1675264],
                        "forbidden_suffix_bytes": 3392, "sentinel": 165}
    if report.get("partial_model_pages") != [expected_partial]:
        raise ValueError("AUX partial page metadata")
    aux_page = (root / "pages/aux.bin").read_bytes()
    aux_bo = Path(packet["model_aux_bo"]["path"]).read_bytes()
    if (len(aux_page) != 3 * 4096 or len(aux_bo) != 1671872 or
        aux_page[:4096] != aux_bo[:4096] or
        aux_page[4096:8192] != aux_bo[1667072:1671168] or
        aux_page[8192:8192 + 704] != aux_bo[1671168:] or
        aux_page[8192 + 704:] != bytes([165]) * 3392):
        raise ValueError("AUX original source and forbidden suffix")
    return {"path": str(report_path.resolve()), "bytes": report_path.stat().st_size,
            "sha256": digest(report_path)[1], "product_count": len(entries)}


def verify_prepared(root: Path, packet: dict, snapshot: Path,
                    require_dat: bool) -> dict:
    metadata_path = root / "runtime_input.json"
    metadata = json.loads(metadata_path.read_text())
    if (metadata["schema"] != "q8_full_scorer_first_pilot_runtime_input_v1" or
        metadata["commands"] != ["load_w", "run_trace_on", "run_trace_off"]):
        raise ValueError("prepared runtime contract")
    fixture = verify_fixture(Path(metadata["fixture_root"]), packet)
    if fixture["sha256"] != metadata["fixture_report_sha256"]:
        raise ValueError("prepared fixture changed")
    files = []
    for name, entry in sorted(metadata["files"].items()):
        path = Path(entry["path"])
        if (path != root / f"{name}.memh" or path.is_symlink() or
            digest(path) != (entry["bytes"], entry["sha256"])):
            raise ValueError(f"prepared input changed: {path}")
        files.append({"name": name, "bytes": entry["bytes"],
                      "sha256": entry["sha256"]})
    if {p.name for p in root.glob("*.memh")} != {f"{x['name']}.memh" for x in files}:
        raise ValueError("prepared memh set changed")
    build = Path(packet["static_build_root"])
    bound_snapshot = build / "xsim.dir"
    if not bound_snapshot.is_dir() or snapshot.resolve(strict=True) != bound_snapshot.resolve(strict=True):
        raise ValueError("prepared snapshot argument differs from bound static build")
    link = root / "xsim.dir"
    if (not link.is_symlink() or not link.readlink().is_absolute() or
        link.readlink() != bound_snapshot or
        metadata["snapshot"] != str(build)):
        raise ValueError("prepared snapshot link changed")
    sources = {Path(x).name: Path(x) for x in packet["generated_dat_paths"]}
    links = list(root.glob("*.dat"))
    if links and len(links) != 108:
        raise ValueError("prepared DAT link set incomplete")
    if require_dat and len(links) != 108:
        raise ValueError("prepared DAT links missing")
    for path in links:
        if (path.name not in sources or not path.is_symlink() or
            path.readlink() != sources[path.name]):
            raise ValueError(f"prepared DAT link changed: {path}")
    return {"runtime_input": {"path": str(metadata_path.resolve()),
                              "bytes": metadata_path.stat().st_size,
                              "sha256": digest(metadata_path)[1]},
            "files": files, "snapshot_link": str(link.readlink()),
            "dat_link_count": len(links), "fixture": fixture}


def archive_runtime(snapshot: Path, out: Path) -> list[dict]:
    out.mkdir(parents=True, exist_ok=False)
    archived = []
    for relative in sorted(RUNTIME_ARTIFACTS):
        source = snapshot / relative
        if source.is_file():
            target = out / source.name
            shutil.copy2(source, target)
            archived.append({"relative_path": relative, "bytes": target.stat().st_size,
                             "sha256": digest(target)[1]})
    (out / "manifest.json").write_text(json.dumps({
        "schema": "q8_full_scorer_xsim_runtime_artifact_archive_v1",
        "source_snapshot": str(snapshot.resolve()), "files": archived,
        "missing": sorted(RUNTIME_ARTIFACTS - {x["relative_path"] for x in archived})},
        sort_keys=True, indent=2) + "\n")
    if len(archived) != 4:
        raise ValueError("incomplete XSim runtime artifact archive; partial evidence retained")
    return archived


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("packet", type=Path)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--fixture", type=Path)
    parser.add_argument("--expected-fixture-report", type=Path)
    parser.add_argument("--cpu-binary", type=Path)
    parser.add_argument("--expected-cpu-report", type=Path)
    parser.add_argument("--snapshot", type=Path)
    parser.add_argument("--expected-snapshot-report", type=Path)
    parser.add_argument("--prepared", type=Path)
    parser.add_argument("--expected-prepared-report", type=Path)
    parser.add_argument("--require-dat-links", action="store_true")
    parser.add_argument("--archive-runtime-artifacts", type=Path)
    args = parser.parse_args()
    if args.expected_fixture_report and not args.fixture:
        parser.error("--expected-fixture-report requires --fixture")
    if args.expected_cpu_report and not args.cpu_binary:
        parser.error("--expected-cpu-report requires --cpu-binary")
    if args.expected_snapshot_report and not args.snapshot:
        parser.error("--expected-snapshot-report requires --snapshot")
    if args.expected_prepared_report and not args.prepared:
        parser.error("--expected-prepared-report requires --prepared")
    if args.prepared and not args.snapshot:
        parser.error("--prepared requires --snapshot")
    if args.archive_runtime_artifacts and not args.snapshot:
        parser.error("--archive-runtime-artifacts requires --snapshot")
    packet = json.loads(args.packet.read_text())
    if packet["schema"] != "q8_full_scorer_first_pilot_source_packet_v5":
        raise ValueError("source packet schema")
    build = Path(packet["static_build_root"])
    static = [x["argv"] for x in packet["exact_commands_after_new_sequential_gate"]
              if x["stage"] == "static_compile"]
    if (not build.is_absolute() or len(static) != 1 or
        static[0] != ["/usr/bin/bash", str(Path(__file__).resolve().parent / "build_static.sh"),
                      str(build)]):
        raise ValueError("bound static command differs from explicit build root")
    if set(packet["snapshot_runtime_mutable_allowlist"]) != RUNTIME_ARTIFACTS:
        raise ValueError("packet and verifier XSim mutable-path mismatch")
    for key in ("supersedes_source_preview", "supersedes_source_packet_v2",
                "supersedes_source_packet_v3", "supersedes_source_packet_v4",
                "first_failure_evidence", "static_entry_first_failure",
                "static_tb_first_failure", "accepted_v4_cpu_evidence",
                "accepted_v4_cpu_review", "prior_static_bash_release",
                "source_repair_release", "v5_source_repair_release",
                "v4_source_preimage_manifest", "source_preimage_manifest",
                "model_aux_bo"):
        item = packet[key]
        path = Path(item["path"])
        if (digest(path) != (item["bytes"], item["sha256"]) or
            oct(stat.S_IMODE(path.stat().st_mode)) != item["mode"]):
            raise ValueError(f"source-packet lineage changed: {path}")
    for item in packet["immutable_files"]:
        path = Path(item["path"])
        if (digest(path) != (item["bytes"], item["sha256"]) or
            oct(stat.S_IMODE(path.stat().st_mode)) != item["mode"]):
            raise ValueError(f"source binding changed: {path}")
    gguf = Path(packet["gguf_slices"][0]["source_path"])
    with gguf.open("rb") as stream:
        for item in packet["gguf_slices"]:
            stream.seek(item["offset"])
            raw = stream.read(item["bytes"])
            if len(raw) != item["bytes"] or hashlib.sha256(raw).hexdigest() != item["sha256"]:
                raise ValueError(f"GGUF slice changed: {item['name']}")
    for item in packet["checkpoint_slices"]:
        with Path(item["source_path"]).open("rb") as stream:
            stream.seek(item["offset"])
            raw = stream.read(item["bytes"])
        if len(raw) != item["bytes"] or hashlib.sha256(raw).hexdigest() != item["sha256"]:
            raise ValueError(f"checkpoint slice changed: {item['name']}")
    fixture = verify_fixture(args.fixture, packet) if args.fixture else None
    if args.expected_fixture_report:
        baseline = json.loads(args.expected_fixture_report.read_text())
        if fixture != baseline["fixture"]:
            raise ValueError("fixture differs from baseline binding")
    cpu_binary = verify_cpu_build(args.cpu_binary, packet) if args.cpu_binary else None
    if args.expected_cpu_report:
        baseline = json.loads(args.expected_cpu_report.read_text())
        if cpu_binary != baseline["cpu_binary"]:
            raise ValueError("CPU leaf binary changed")
    snapshot = inventory(args.snapshot) if args.snapshot else []
    archived = archive_runtime(args.snapshot, args.archive_runtime_artifacts) if args.archive_runtime_artifacts else []
    if args.expected_snapshot_report:
        baseline = json.loads(args.expected_snapshot_report.read_text())
        fixed = lambda rows: [x for x in rows if x["relative_path"] not in RUNTIME_ARTIFACTS]
        if fixed(snapshot) != fixed(baseline["snapshot"]):
            raise ValueError("compiled snapshot changed outside four XSim runtime files")
    prepared = verify_prepared(args.prepared, packet, args.snapshot,
                               args.require_dat_links) if args.prepared else None
    if args.expected_prepared_report:
        baseline = json.loads(args.expected_prepared_report.read_text())
        prior = baseline["prepared"]
        for key in ("runtime_input", "files", "snapshot_link", "fixture"):
            if prepared[key] != prior[key]:
                raise ValueError(f"prepared runtime changed: {key}")
    if args.out:
        result = {"schema": "q8_full_scorer_source_snapshot_binding_v1",
                  "created_utc": datetime.now(timezone.utc).isoformat(),
                  "packet_sha256": digest(args.packet)[1],
                  "source_file_count": len(packet["immutable_files"]),
                  "fixture": fixture, "cpu_binary": cpu_binary,
                  "snapshot": snapshot,
                  "prepared": prepared, "archived_runtime_artifacts": archived}
        args.out.parent.mkdir(parents=True, exist_ok=True)
        if args.out.exists():
            raise FileExistsError(args.out)
        args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"Q8_SCORER_SOURCE_BINDING_PASS files={len(packet['immutable_files'])} snapshot={len(snapshot)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
