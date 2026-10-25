#!/usr/bin/env python3
"""Build bounded native frontend and independent source-native oracle locally."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess

ROOT = Path(__file__).resolve().parents[2]
NATIVE = ROOT / "reference/vendor/ggmlc"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--identity", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    baseline = json.loads(args.identity.read_text())
    for name, record in baseline["sources"].items():
        if sha(ROOT / name) != record["sha256"]:
            raise ValueError("original frontend source changed: " + name)
    engine = NATIVE / "examples/laya/src/engine.cpp"
    text = engine.read_text()
    start = text.index("Answer DecisionEngine::decode_answer(")
    stop = text.index("\nDecideResult DecisionEngine::decide_one(", start)
    member = text[start:stop]
    body = member[member.index("{"):]
    adapter = ("// Generated from original engine.cpp; arithmetic body unchanged.\nnamespace laya {\n"
        "Answer decode_original_adapter(const DecisionRecipe& recipe_, bool has_act_, "
        "const Question& q, const float* logits, int k, const float* act) " + body + "\n}\n")
    oracle = "namespace laya {\n" + member.replace("DecisionEngine::", "OriginalDecodeOracle::", 1) + "\n}\n"
    (args.output / "native_decode_generated.inc").write_text(adapter)
    (args.output / "oracle_decode_generated.inc").write_text(oracle)
    sources = [NATIVE / "runtime/src/pipeline/tokenizer.cpp"] + [
        NATIVE / "examples/laya/src" / (name + ".cpp")
        for name in ("questions", "recipe", "sequence", "language")]
    includes = [NATIVE / "runtime/include", NATIVE / "third_party/ggml/include",
                NATIVE / "examples/laya/include", args.output]
    flags = ["c++", "-std=c++17", "-O2", "-fno-fast-math", "-ffp-contract=off",
             "-ffunction-sections", "-fdata-sections", "-Wl,--gc-sections", "-Wall", "-Wextra"]
    flags += ["-I" + str(path) for path in includes]
    print(subprocess.check_output(["c++", "--version"], text=True), flush=True)
    binary = args.output / "native_frontend"
    owned = ROOT / "host/m007_deploy/native_frontend.cpp"
    command = flags + [str(owned)] + [str(path) for path in sources] + ["-o", str(binary), "-lm"]
    print("compile_native=" + repr(command), flush=True)
    subprocess.run(command, check=True)
    lib = ROOT / "reference/build/cpu/libggml_lib.a"
    oracle_binary = args.output / "native_frontend_oracle"
    command = flags + [str(ROOT / "tests/m007_deploy/native_frontend_oracle.cpp")] + [str(path) for path in sources]
    command += [str(lib), "-o", str(oracle_binary), "-lm", "-pthread", "-fopenmp", "-ldl"]
    print("compile_oracle=" + repr(command), flush=True)
    subprocess.run(command, check=True)
    dependencies = {str(path.relative_to(ROOT)): sha(path) for path in sources + [owned, engine]}
    for path in sources + [owned, ROOT / "tests/m007_deploy/native_frontend_oracle.cpp"]:
        command = ["c++", "-std=c++17", "-MM"] + ["-I" + str(item) for item in includes] + [str(path)]
        listing = subprocess.check_output(command, text=True).replace("\\\n", " ")
        for name in shlex.split(listing.split(":", 1)[1]):
            dependency = Path(name).resolve()
            if dependency.is_relative_to(ROOT):
                dependencies[str(dependency.relative_to(ROOT))] = sha(dependency)
    for name, record in baseline["sources"].items():
        dependencies[name] = record["sha256"]
    report = {"schema": "m007-native-frontend-build-v1", "binary_sha256": sha(binary),
              "source_sha256": dependencies, "original_decode_member_sha256": hashlib.sha256(member.encode()).hexdigest(),
              "original_decode_body_sha256": hashlib.sha256(body.encode()).hexdigest(),
              "generated_adapter_sha256": sha(args.output / "native_decode_generated.inc"),
              "oracle_binary_sha256": sha(oracle_binary), "native_GGUF_library_sha256": sha(lib),
              "floating_flags": ["-fno-fast-math", "-ffp-contract=off"],
              "no_ModelExecutor": True, "device": "NOT_RUN"}
    binary.with_suffix(".identity.json").write_text(json.dumps(report, indent=2) + "\n")
    print("M007_FRONTEND_BUILD_PASS production_native=1 independent_source_oracle=1 device=NOT_RUN", flush=True)


if __name__ == "__main__":
    main()
