#!/usr/bin/env python3
"""Build the current production graph and its affected arithmetic checks."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def record(path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--current-sources", action="store_true",
                        help="build the current E002 source closure; preserve package/gold")
    args = parser.parse_args()
    package, work = args.package.resolve(), args.work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    preimage = json.loads((package / "build_preimage.json").read_text())
    preimage_differences = []
    for item in preimage["sources"]:
        current = record(ROOT / item["path"])
        if current["sha256"] != item["sha256"]:
            preimage_differences.append(item["path"])
    if not args.current_sources:
        assert not preimage_differences, preimage_differences[0]
    sources = re.findall(r"^\s*(hls/[^\s]+\.cpp)\s*$",
                         (ROOT / "config/full_sources.cmake").read_text(), re.M)
    assert len(sources) == (41 if args.current_sources else 27)
    assert len(set(sources)) == len(sources)
    cpu_services = re.findall(r"^\s*(vivado/module_design/[^\s]+\.cpp)\s*$",
                             (ROOT / "config/full_sources.cmake").read_text(), re.M)
    assert len(cpu_services) == 2
    sources += cpu_services
    flags = ["-std=c++17", "-O2", "-Wall", "-Wextra", "-Wpedantic",
             "-fno-fast-math", "-fno-associative-math", "-ffp-contract=off",
             "-I" + str(ROOT / "include"), "-I" + str(ROOT / "hls"),
             "-I" + str(ROOT / "tests"), "-I" + str(package)]
    objects, dependencies = {}, []

    def compile_one(source):
        source = Path(source).resolve()
        key = str(source.relative_to(ROOT)).replace("/", "_")
        output, dep = work / (key + ".o"), work / (key + ".d")
        subprocess.run(["/usr/bin/g++", *flags, "-MMD", "-MF", str(dep),
                        "-c", str(source), "-o", str(output)], check=True, cwd=ROOT)
        objects[source] = output
        dependencies.append(dep)
        print("FULL_CURRENT_COMPILED source=" + str(source.relative_to(ROOT)), flush=True)
        return output

    for name in sources:
        compile_one(ROOT / name)
    tb = ROOT / "tests/current_production_full_csim_tb.cpp"
    tb_object = compile_one(tb)
    targets = {}

    def link(name, inputs):
        output = work / name
        subprocess.run(["/usr/bin/g++", *map(str, inputs), "-o", str(output)], check=True)
        targets[name] = record(output)
        print("FULL_CURRENT_LINKED target=" + name, flush=True)

    link("full_csim", [objects[ROOT / name] for name in sources] + [tb_object])
    raw_object = compile_one(ROOT / "host/cpu_embedding_raw.cpp")
    link("cpu_embedding_raw", [raw_object])
    numeric = [objects[ROOT / name] for name in
               ("hls/common/laya_numeric.cpp",
                "hls/operators/activation_quantizer_compute.cpp",
                "hls/operators/q8_linear_compute.cpp")]
    if args.current_sources:
        numeric.append(objects[ROOT / "hls/common/laya_tasks.cpp"])
    for module in ("activation_quantizer", "q8_linear_and_restore"):
        unit = compile_one(ROOT / "vivado/module_design" / module / "tb/numeric_tb.cpp")
        link("numeric_" + module, numeric + [unit])
        subprocess.run([str(work / ("numeric_" + module))], check=True, cwd=ROOT)
        print("FULL_CURRENT_NUMERIC_PASS module=" + module, flush=True)
    closure = set(objects)
    for dep in dependencies:
        text = dep.read_text().replace("\\\n", " ")
        closure.update(Path(x).resolve() for x in text.split(":", 1)[1].split())
    # Check the actual compiled dependency closure against the exporter inputs.
    production = {str((ROOT / item["path"]).resolve()): item["sha256"]
                  for item in preimage["sources"]}
    for path in closure:
        if path.is_relative_to(ROOT / "hls") or path.is_relative_to(ROOT / "include") or \
           path.is_relative_to(ROOT / "vivado/module_design"):
            if not args.current_sources:
                assert production[str(path)] == record(path)["sha256"], str(path)
    report = {"schema": "laya-current-production-build-v1", "flags": flags,
              "source_mode": "current-E002" if args.current_sources else "package-preimage",
              "package_preimage_differences": preimage_differences,
              "package_manifest": record(package / "manifest.json"),
              "build_preimage": record(package / "build_preimage.json"),
              "compiler": subprocess.check_output(["/usr/bin/g++", "--version"], text=True),
              "compiled_dependencies": [record(p) for p in sorted(closure)],
              "objects": [record(p) for p in objects.values()], "targets": targets}
    (work / "build_manifest.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("FULL_CURRENT_BUILD_PASS production_sources=" + str(len(sources)) +
          " numeric_modules=2 source_mode=" + report["source_mode"], flush=True)


if __name__ == "__main__":
    main()
