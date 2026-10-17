#!/usr/bin/env python3
"""Record the complete project-source closure of a built P2 DUT library.

Read compiler-generated dependency files, not a hand-picked source list. The
compile database and CMake source list must agree, all objects must be present,
and no project dependency may be newer than its compiled object.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import re
import shlex
import sys
import traceback


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def inside(path: pathlib.Path, directory: pathlib.Path) -> bool:
    try:
        path.relative_to(directory)
        return True
    except ValueError:
        return False


def cmake_value(cache: str, name: str) -> str:
    matches = re.findall(rf"(?m)^{re.escape(name)}:[^=]*=(.*)$", cache)
    require(len(matches) == 1, f"unique {name} in CMake cache")
    return matches[0].strip()


def dependencies(path: pathlib.Path) -> list[pathlib.Path]:
    text = path.read_text().replace("\\\n", " ")
    require(":" in text, f"dependency file has target: {path}")
    return [pathlib.Path(name).resolve() for name in
            shlex.split(text.split(":", 1)[1])]


def main() -> int:
    if len(sys.argv) != 6:
        print("usage: full_source_closure.py ROOT BUILD_DIR MODEL_DIR "
              "COMMAND_LOG OUTPUT_DIR", file=sys.stderr)
        return 2
    root, build, model, command_log, output = (
        pathlib.Path(name).resolve() for name in sys.argv[1:])
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "CHECKING",
                    "role": "compiled_laya_full_source_header_command_closure"}
    try:
        cache_path = build / "CMakeCache.txt"
        database_path = build / "compile_commands.json"
        source_list_path = root / "config/full_sources.cmake"
        library_path = build / "liblaya_full.a"
        require(all(path.is_file() for path in
                    (cache_path, database_path, source_list_path,
                     library_path, command_log)),
                "build database, library, and command log exist")
        cache = cache_path.read_text()
        require(cmake_value(cache, "CMAKE_HOME_DIRECTORY") == str(root),
                "CMake source root")
        require(cmake_value(cache, "LAYA_FULL_MODEL_DIR") == str(model),
                "CMake model directory")
        require(cmake_value(cache, "LAYA_ENABLE_FULL_FORWARD") == "ON",
                "full forward build enabled")
        require(cmake_value(cache, "CMAKE_EXPORT_COMPILE_COMMANDS") == "ON",
                "complete compiler command database")
        source_list = source_list_path.read_text()
        listed = set(re.findall(r"(?m)^\s*(hls/\S+\.cpp)\s*$",
                                source_list))
        require(listed, "nonempty CMake DUT source list")
        database = json.loads(database_path.read_text())
        compiled: dict[str, dict] = {}
        project_deps: set[pathlib.Path] = set()
        system_deps: set[pathlib.Path] = set()
        for entry in database:
            object_rel = entry.get("output", "")
            if not object_rel.startswith("CMakeFiles/laya_full.dir/"):
                continue
            source = pathlib.Path(entry["file"]).resolve()
            require(inside(source, root) and source.is_file(),
                    f"DUT source path: {source}")
            rel = source.relative_to(root).as_posix()
            require(rel not in compiled, f"DUT source compiled once: {rel}")
            obj = build / object_rel
            depfile = pathlib.Path(str(obj) + ".d")
            require(obj.is_file() and depfile.is_file(),
                    f"compiled object and dependency file: {rel}")
            all_deps = dependencies(depfile)
            require(source in all_deps, f"compiler dependency includes source: {rel}")
            local_deps = set()
            for dep in all_deps:
                if inside(dep, root) or inside(dep, model):
                    require(dep.is_file(), f"compiled project dependency exists: {dep}")
                    require(dep.stat().st_mtime_ns <= obj.stat().st_mtime_ns,
                            f"compiled object is newer than dependency: {rel} {dep}")
                    project_deps.add(dep)
                    local_deps.add(str(dep))
                else:
                    system_deps.add(dep)
            compiled[rel] = {
                "source_sha256": sha256(source),
                "object": str(obj), "object_sha256": sha256(obj),
                "dependency_file_sha256": sha256(depfile),
                "project_dependencies": sorted(local_deps),
                "compile_command": entry["command"],
                "compile_command_sha256": hashlib.sha256(
                    entry["command"].encode()).hexdigest(),
            }
        require(set(compiled) == listed,
                "CMake DUT source list equals compiler command sources; "
                f"missing={sorted(listed - set(compiled))} "
                f"extra={sorted(set(compiled) - listed)}")
        generated_header = model / "laya_model_layout_generated.h"
        require(generated_header in project_deps,
                "generated package header in compiled dependency closure")
        dependency_hashes = {str(path): sha256(path)
                             for path in sorted(project_deps)}
        command_text = command_log.read_text()
        require("cmake" in command_text and "--build" in command_text and
                str(model) in command_text and str(build) in command_text,
                "command log records configure and build with exact paths")
        link_path = build / "CMakeFiles/laya_full.dir/link.txt"
        require(link_path.is_file(), "DUT archive link command exists")
        report.update({
            "root": str(root), "build": str(build), "model": str(model),
            "cmake_build_type": cmake_value(cache, "CMAKE_BUILD_TYPE"),
            "cmake_cache_sha256": sha256(cache_path),
            "compile_database_sha256": sha256(database_path),
            "cmake_source_list_sha256": sha256(source_list_path),
            "cmake_lists_sha256": sha256(root / "CMakeLists.txt"),
            "build_commands": command_text,
            "build_commands_sha256": sha256(command_log),
            "archive_link_command": link_path.read_text().strip(),
            "archive_link_command_sha256": sha256(link_path),
            "library_sha256": sha256(library_path),
            "compiled_sources": compiled,
            "project_dependency_sha256": dependency_hashes,
            "project_dependency_count": len(project_deps),
            "system_dependency_count_excluded_from_source_hashes":
                len(system_deps),
            "note": "System/compiler headers are enumerated by dependency "
                    "count, while every project and generated model header "
                    "is hashed. Package binaries are checked separately.",
        })
        report["status"] = "DUT_SOURCE_CLOSURE_COMPLETE"
        print("DUT_SOURCE_CLOSURE_COMPLETE sources=" + str(len(compiled)) +
              " project_dependencies=" + str(len(project_deps)))
    except Exception as exc:
        report["status"] = "DUT_SOURCE_CLOSURE_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
    (output / "full_source_closure_report.json").write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n")
    return 0 if report["status"] == "DUT_SOURCE_CLOSURE_COMPLETE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
