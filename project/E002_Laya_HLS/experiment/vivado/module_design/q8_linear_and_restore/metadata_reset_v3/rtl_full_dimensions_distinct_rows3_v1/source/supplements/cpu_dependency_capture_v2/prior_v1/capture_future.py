#!/usr/bin/env python3
"""Future-gated, sequential CPU build with actual dependency capture.

The default action checks frozen source and command identities only. Neither
the compiler nor the preprocessor is invoked without a separate build release.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "command_manifest.json"
SOURCE_PACKET = HERE / "source_packet.json"
RELEASE_PATH_PLACEHOLDER = "<release_path>"
REQUIRED_ENV = {"PATH": "/usr/bin:/bin", "LC_ALL": "C", "LANG": "C"}


def require(ok: bool, reason: str) -> None:
    if not ok:
        raise RuntimeError(reason)


def sha_bytes(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def record(path: Path) -> dict:
    path = Path(path)
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return {"path": str(path), "resolved_path": str(path.resolve(strict=True)),
            "bytes": path.stat().st_size, "sha256": digest.hexdigest()}


def checked(item: dict) -> dict:
    actual = record(Path(item["path"]))
    for key in ("path", "bytes", "sha256", "resolved_path"):
        if key in item:
            require(actual[key] == item[key], f"bound file changed: {item['path']} ({key})")
    return actual


def argv_sha(argv: list[str]) -> str:
    return sha_bytes(json.dumps(argv, separators=(",", ":")).encode())


def command_rows(manifest: dict) -> tuple[list[dict], dict]:
    root = Path(manifest["build_root"])
    common = ["/usr/bin/g++", *manifest["strict_flags"],
              *("-I" + root for root in manifest["include_roots"])]
    rows = []
    for index, (unit, name) in enumerate(zip(manifest["translation_units"],
                                             manifest["unit_names"], strict=True)):
        obj = root / "obj" / (name + ".o")
        dep = root / "deps" / (name + ".d")
        argv = [*common, "-MD", "-MF", str(dep), "-MT", str(obj),
                "-c", unit["path"], "-o", str(obj)]
        rows.append({"index": index, "source": unit["path"],
                     "object": str(obj), "depfile": str(dep),
                     "argv": argv, "argv_sha256": argv_sha(argv)})
    output = root / manifest["executable_name"]
    link_argv = ["/usr/bin/g++", *manifest["strict_flags"], "-Wl,-t",
                 *(row["object"] for row in rows), "-lm", "-o", str(output)]
    link = {"output": str(output), "argv": link_argv,
            "argv_sha256": argv_sha(link_argv)}
    return rows, link


def guard_argv(manifest: dict, release_path: str) -> list[str]:
    control = Path(manifest["control_root"])
    budget = manifest["candidate_budget"]
    return ["/usr/bin/taskset", "-c", "0,1,2,3", "/usr/bin/python3",
            manifest["guard"]["path"], "--out", str(control / "guard"),
            "--cwd", str(control), "--rss-gib", str(budget["rss_gib"]),
            "--timeout-seconds", str(budget["wall_seconds"]), "--",
            "/usr/bin/python3", str(Path(__file__).resolve()),
            "--guard-child", "--release", release_path]


def checked_manifest(*, deep: bool = True) -> tuple[dict, dict]:
    manifest = json.loads(MANIFEST.read_text())
    source_packet = json.loads(SOURCE_PACKET.read_text())
    require(manifest["schema"] == "cpu_actual_dependency_capture_command_manifest_v1" and
            source_packet["schema"] == "cpu_actual_dependency_capture_source_packet_v1" and
            source_packet["status"] == "SOURCE_ONLY_NO_COMPILER_OR_DUT_EXECUTION",
            "source-only manifest schema/status")
    require(checked(source_packet["command_manifest"]) == record(MANIFEST) and
            checked(source_packet["driver"]) == record(Path(__file__).resolve()) and
            checked(manifest["driver"]) == record(Path(__file__).resolve()),
            "driver and command manifest identities")
    require(manifest["variant"] == source_packet["variant"] and
            manifest["authority"] == source_packet["authority"] and
            manifest["frozen_source_packet"] == source_packet["frozen_source_packet"],
            "source packet relationship")
    require(manifest["strict_flags"] in
            (["-std=c++17", "-O2", "-fno-fast-math", "-ffp-contract=off"],
             ["-std=c++17", "-O2", "-ffp-contract=off", "-fno-fast-math"]),
            "strict numerical flags")
    require(manifest["declared_environment"] == REQUIRED_ENV and
            len(manifest["translation_units"]) == len(manifest["unit_names"]) and
            len(set(manifest["unit_names"])) == len(manifest["unit_names"]),
            "environment and unique translation units")
    require(manifest["original_argv_sha256"] == argv_sha(manifest["original_argv"]),
            "original argv hash")
    rows, link = command_rows(manifest)
    require(rows == manifest["compile_commands"] and link == manifest["link_command"] and
            guard_argv(manifest, RELEASE_PATH_PLACEHOLDER) ==
            manifest["candidate_guard_argv_template"], "exact candidate commands")
    for key in ("authority", "frozen_source_packet", "fixture_acceptance",
                "fixture_execution_packet", "host_chain_manifest", "driver", "guard",
                "guard_helper", "readelf", "loader"):
        checked(manifest[key])
    checked_groups = ("host_chain_files", "translation_units", "lexical_local_headers")
    if deep:
        checked_groups = ("presealed_inputs", *checked_groups)
    for key in checked_groups:
        for item in manifest[key]:
            checked(item)
    require(all(Path(x).is_dir() for x in manifest["include_roots"]),
            "ordered include roots")
    require(all(row["source"] == unit["path"] for row, unit in
                zip(rows, manifest["translation_units"], strict=True)),
            "source order")
    require(source_packet["presealed_input_count"] == len(manifest["presealed_inputs"]) and
            source_packet["host_chain_file_count"] == len(manifest["host_chain_files"]) and
            source_packet["translation_unit_count"] == len(rows),
            "source packet counts")
    if "results" in source_packet:
        checked(source_packet["results"])
    return manifest, source_packet


def _split_tokens(raw: str, *, target: bool) -> list[str]:
    tokens, token = [], []
    index = 0
    while index < len(raw):
        ch = raw[index]
        if ch == "\\":
            require(index + 1 < len(raw) and raw[index + 1] in " \\#:\t",
                    "unsupported or dangling Make escape")
            token.append(raw[index + 1]); index += 2; continue
        require(ch not in "$\r\n" and (target or ch not in ":#"),
                "unsupported Make expansion, comment or second rule")
        if ch.isspace():
            if token:
                tokens.append("".join(token)); token = []
        else:
            token.append(ch)
        index += 1
    if token:
        tokens.append("".join(token))
    return tokens


def parse_depfile(raw: bytes, expected_target: str) -> list[str]:
    text = raw.decode("utf-8", errors="strict")
    text = text.replace("\\\r\n", " ").replace("\\\n", " ")
    require("\n" not in text.strip() and "\r" not in text,
            "depfile has multiple rules or bare newline")
    text = text.strip()
    escaped = False
    separator = None
    for index, ch in enumerate(text):
        if escaped:
            escaped = False; continue
        if ch == "\\":
            escaped = True
        elif ch == ":":
            separator = index; break
    require(separator is not None and not escaped, "depfile target separator")
    targets = _split_tokens(text[:separator], target=True)
    require(targets == [expected_target], "depfile target differs from -MT")
    dependencies = _split_tokens(text[separator + 1:], target=False)
    require(dependencies and len(dependencies) == len(set(dependencies)),
            "empty or repeated depfile prerequisite")
    return dependencies


def self_test() -> None:
    raw = b"/tmp/target\\ file.o: /tmp/source.cpp /tmp/a\\ b.h \\\n /tmp/hash\\#x.h /tmp/colon\\:x.h\n"
    assert parse_depfile(raw, "/tmp/target file.o") == [
        "/tmp/source.cpp", "/tmp/a b.h", "/tmp/hash#x.h", "/tmp/colon:x.h"]
    for bad in (b"a.o: x.h\ny.o: z.h\n", b"a.o: x.h $bad\n",
                b"a.o: x.h #comment\n", b"a.o: x.h \\"):
        try:
            parse_depfile(bad, "a.o")
        except (RuntimeError, ValueError):
            pass
        else:
            raise AssertionError("ambiguous depfile was accepted")


def clean_environment(slot: str) -> dict[str, str]:
    return {**REQUIRED_ENV, "LAYA_CPU_HEAVY_SLOT": slot}


def load_release(path: Path, manifest: dict, source_packet: dict) -> dict:
    release = json.loads(path.read_text())
    require(release.get("schema") == "cpu_actual_dependency_capture_build_release_v1" and
            release.get("status") == "CPU_DEPENDENCY_CAPTURE_BUILD_RELEASED" and
            release.get("variant") == manifest["variant"] and
            release.get("command_manifest_sha256") == record(MANIFEST)["sha256"] and
            release.get("source_packet_sha256") == record(SOURCE_PACKET)["sha256"] and
            release.get("fixture_acceptance_sha256") ==
            manifest["fixture_acceptance"]["sha256"],
            "independent exact CPU build release is absent")
    slot = release.get("root_heavy_slot_token")
    require(isinstance(slot, str) and slot and os.environ.get("LAYA_CPU_HEAVY_SLOT") == slot,
            "root has not assigned the single heavy slot")
    require(release.get("finite_budget") == manifest["candidate_budget"] and
            type(release.get("allow_loader_list")) is bool,
            "finite budget and loader-list permission")
    return release


def run_logged(argv: list[str], cwd: Path, env: dict[str, str],
               stdout: Path, stderr: Path) -> int:
    with stdout.open("xb") as out, stderr.open("xb") as err:
        return subprocess.run(argv, cwd=cwd, env=env, stdout=out,
                              stderr=err, check=False).returncode


def local_class(path: Path, manifest: dict) -> str:
    resolved = path.resolve(strict=True)
    project = Path(manifest["project_root"])
    vendor = [Path(x) for x in manifest.get("vendor_roots", [])]
    if resolved == project or project in resolved.parents:
        return "project"
    if any(resolved == root or root in resolved.parents for root in vendor):
        return "vendor"
    return "system"


def observed_dependencies(raw: bytes, row: dict, cwd: Path,
                          manifest: dict, cache: dict[str, dict]) -> list[dict]:
    names = parse_depfile(raw, row["object"])
    records = []
    for name in names:
        path = Path(name)
        if not path.is_absolute():
            path = cwd / path
        canonical = path.resolve(strict=True)
        require(canonical.is_file(), f"depfile prerequisite is not a file: {name}")
        key = str(canonical)
        if key not in cache:
            cache[key] = record(canonical)
        records.append({"emitted": name, "canonical_path": key,
                        "classification": local_class(canonical, manifest)})
    require(str(Path(row["source"]).resolve(strict=True)) in
            {item["canonical_path"] for item in records},
            "source missing from actual depfile")
    return records


def parse_link_trace(path: Path, cwd: Path) -> tuple[list[dict], list[str]]:
    files, unresolved = [], []
    for raw_line in path.read_text(errors="replace").splitlines():
        line = raw_line.strip()
        if not line:
            continue
        candidate = line.removeprefix("LOAD ")
        member = None
        if candidate.endswith(")") and "(" in candidate:
            candidate, member = candidate.rsplit("(", 1)
            member = member[:-1]
        path_candidate = Path(candidate)
        if not path_candidate.is_absolute():
            path_candidate = cwd / path_candidate
        if path_candidate.is_file():
            item = record(path_candidate)
            if member is not None:
                item["archive_member"] = member
            files.append(item)
        else:
            unresolved.append(raw_line)
    unique = {item["resolved_path"]: item for item in files}
    return list(unique.values()), unresolved


def readelf_inspect(path: Path, cwd: Path, env: dict[str, str],
                    tool: str, log_prefix: Path,
                    *, require_interpreter: bool = True) -> dict:
    outputs = {}
    for option, suffix in (("-h", "header"), ("-l", "program"), ("-d", "dynamic")):
        stdout = log_prefix.with_name(log_prefix.name + f"_{suffix}.stdout.log")
        stderr = log_prefix.with_name(log_prefix.name + f"_{suffix}.stderr.log")
        rc = run_logged([tool, option, str(path)], cwd, env, stdout, stderr)
        require(rc == 0, f"readelf {option} failed")
        outputs[suffix] = {"stdout": record(stdout), "stderr": record(stderr)}
    header = Path(outputs["header"]["stdout"]["path"]).read_text()
    program = Path(outputs["program"]["stdout"]["path"]).read_text()
    dynamic = Path(outputs["dynamic"]["stdout"]["path"]).read_text()
    require(re.search(r"Class:\s+ELF64", header) is not None,
            "final binary is not ELF64")
    interpreters = re.findall(r"\[Requesting program interpreter: ([^\]]+)\]", program)
    needed = re.findall(r"\(NEEDED\).*Shared library: \[([^\]]+)\]", dynamic)
    require(len(interpreters) == (1 if require_interpreter else 0),
            "ELF interpreter cardinality")
    return {"file": record(path), "interpreter": interpreters[0] if interpreters else None,
            "needed": needed, "logs": outputs}


def loader_list(path: Path, manifest: dict, cwd: Path,
                env: dict[str, str], log_root: Path) -> dict:
    loader = manifest["loader"]["path"]
    out, err = log_root / "loader_list.stdout.log", log_root / "loader_list.stderr.log"
    rc = run_logged([loader, "--list", str(path)], cwd, env, out, err)
    require(rc == 0, "bound glibc loader --list failed")
    libraries, unresolved = [], []
    for raw in out.read_text(errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("linux-vdso.so"):
            continue
        if "=>" in line:
            soname, right = (part.strip() for part in line.split("=>", 1))
            value = right.split(" (", 1)[0]
        elif line.startswith("/"):
            value = line.split(" (", 1)[0]
            soname = Path(value).name
        else:
            unresolved.append(raw)
            continue
        if Path(value).is_file():
            libraries.append({"soname": soname, "file": record(Path(value))})
        else:
            unresolved.append(raw)
    require(not unresolved, "loader --list has unresolved entries")
    return {"stdout": record(out), "stderr": record(err),
            "libraries": list({x["soname"]: x for x in libraries}.values())}


def build(manifest: dict, release: dict, release_path: Path) -> int:
    build_root = Path(manifest["build_root"])
    control = Path(manifest["control_root"])
    require(control.is_dir() and not build_root.exists(), "fresh build root")
    env = clean_environment(release["root_heavy_slot_token"])
    progress = {"schema": "cpu_actual_dependency_capture_build_packet_v1",
                "variant": manifest["variant"], "started_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                "release": record(release_path), "manifest": record(MANIFEST),
                "source_packet": record(SOURCE_PACKET), "compile_records": [],
                "status": "IN_PROGRESS", "automatic_retry_count": 0,
                "compiler_invocation_count": 0, "link_invocation_count": 0}
    packet_path = control / "build_execution_packet.json"
    require(not packet_path.exists(), "single first attempt")
    cache: dict[str, dict] = {}
    try:
        for item in manifest["presealed_inputs"] + manifest["host_chain_files"]:
            checked(item)
        progress["precheck_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
        (build_root / "obj").mkdir(parents=True)
        (build_root / "deps").mkdir()
        (control / "logs").mkdir()
        for row in manifest["compile_commands"]:
            index = row["index"]
            out = control / "logs" / f"compile_{index:02d}.stdout.log"
            err = control / "logs" / f"compile_{index:02d}.stderr.log"
            progress["compiler_invocation_count"] += 1
            rc = run_logged(row["argv"], control, env, out, err)
            entry = {"index": index, "argv": row["argv"],
                     "argv_sha256": row["argv_sha256"], "exit_code": rc,
                     "stdout": record(out), "stderr": record(err)}
            progress["compile_records"].append(entry)
            require(rc == 0, f"compile {index} failed")
            dep = record(Path(row["depfile"]))
            obj = record(Path(row["object"]))
            entry.update(depfile=dep, object=obj,
                         dependencies=observed_dependencies(
                             Path(row["depfile"]).read_bytes(), row, control,
                             manifest, cache))
        progress["discovered_dependency_records"] = list(cache.values())
        seen = set(cache)
        expected = {str(Path(x["path"]).resolve(strict=True))
                    for x in manifest["lexical_local_headers"]}
        progress["lexical_local_headers_not_emitted"] = sorted(expected - seen)
        progress["observed_extra_local_headers"] = sorted(
            x for x in seen - expected if local_class(Path(x), manifest) != "system")
        link = manifest["link_command"]
        out, err = control / "logs/link.stdout.log", control / "logs/link.stderr.log"
        progress["link_invocation_count"] = 1
        rc = run_logged(link["argv"], control, env, out, err)
        progress["link_record"] = {"argv": link["argv"],
                                   "argv_sha256": link["argv_sha256"],
                                   "exit_code": rc, "stdout": record(out),
                                   "stderr": record(err)}
        require(rc == 0, "ordered object link failed")
        trace_files, trace_unresolved = parse_link_trace(out, control)
        progress["link_trace_files"] = trace_files
        progress["link_trace_unresolved_lines"] = trace_unresolved
        elf = readelf_inspect(Path(link["output"]), control, env,
                              manifest["readelf"]["path"], control / "logs/final_elf")
        progress["final_elf"] = elf
        require(Path(elf["interpreter"]).resolve(strict=True) ==
                Path(manifest["loader"]["path"]).resolve(strict=True),
                "final ELF interpreter differs from bound loader")
        if release["allow_loader_list"]:
            listed = loader_list(Path(link["output"]), manifest, control,
                                 env, control / "logs")
            progress["loader_list"] = listed
            resolved = {x["soname"] for x in listed["libraries"]}
            progress["needed_not_resolved_by_loader_list"] = sorted(
                x for x in elf["needed"] if x not in resolved)
            require(not progress["needed_not_resolved_by_loader_list"],
                    "ELF DT_NEEDED not resolved by bound loader")
            recursive = []
            for index, item in enumerate(listed["libraries"]):
                recursive.append(readelf_inspect(Path(item["file"]["path"]), control,
                                  env, manifest["readelf"]["path"],
                                  control / "logs" / f"needed_{index:02d}",
                                  require_interpreter=False))
            progress["resolved_library_elf_records"] = recursive
            progress["recursive_needed_not_resolved"] = sorted({
                soname for item in recursive for soname in item["needed"]
                if soname not in resolved})
            require(not progress["recursive_needed_not_resolved"],
                    "recursive library DT_NEEDED not resolved by bound loader")
        else:
            progress["loader_list"] = "HELD_BY_RELEASE"
        for item in manifest["presealed_inputs"] + manifest["host_chain_files"]:
            checked(item)
        for item in cache.values():
            checked(item)
        progress["postcheck_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
        progress["status"] = "BUILD_AND_ACTUAL_DEPENDENCY_CAPTURE_COMPLETE_REVIEW_REQUIRED"
        return 0
    except Exception as error:
        progress["status"] = "FIRST_FAILURE_PRESERVED"
        progress["failure"] = str(error)
        return 1
    finally:
        progress["finished_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
        packet_path.write_text(json.dumps(progress, indent=2, sort_keys=True) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--execute", action="store_true")
    group.add_argument("--guard-child", action="store_true")
    group.add_argument("--self-test", action="store_true")
    group.add_argument("--light-check", action="store_true")
    parser.add_argument("--release", type=Path)
    args = parser.parse_args()
    self_test()
    if args.self_test:
        require(args.release is None, "self-test takes no release")
        print("CPU_DEPFILE_PARSER_SELF_TEST_PASS")
        return 0
    manifest, source_packet = checked_manifest(deep=not args.light_check)
    if not args.execute and not args.guard_child:
        require(args.release is None, "release requires a build action")
        print("CPU_DEPENDENCY_CAPTURE_SOURCE_CHECK_PASS "
              f"variant={manifest['variant']} commands={len(manifest['compile_commands']) + 1} "
              f"manifest_sha256={record(MANIFEST)['sha256']} "
              f"presealed_refs_rehashed={not args.light_check}")
        return 0
    require(args.release is not None, "separate exact build release required")
    release_path = args.release.resolve(strict=True)
    release = load_release(release_path, manifest, source_packet)
    control = Path(manifest["control_root"])
    build_root = Path(manifest["build_root"])
    if args.guard_child:
        return build(manifest, release, release_path)
    require(not control.exists() and not build_root.exists(),
            "fresh control and output roots")
    control.mkdir(parents=True)
    argv = guard_argv(manifest, str(release_path))
    (control / "launch.json").write_text(json.dumps({
        "schema": "cpu_actual_dependency_capture_guard_launch_v1",
        "release": record(release_path), "manifest": record(MANIFEST),
        "argv": argv, "clean_environment": REQUIRED_ENV,
    }, indent=2, sort_keys=True) + "\n")
    rc = subprocess.run(argv, cwd=control,
                        env=clean_environment(release["root_heavy_slot_token"]),
                        check=False).returncode
    (control / "launcher_result.json").write_text(json.dumps({
        "guard_exit_code": rc, "finished_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "automatic_retry_count": 0,
    }, indent=2, sort_keys=True) + "\n")
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
