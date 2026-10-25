#!/usr/bin/env python3
"""Build persistent native CPU library; freeze sources, actual libm and binary."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import platform
import shlex
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
NATIVE = ROOT / "reference/vendor/ggmlc"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def libm_identity():
    lib = ctypes.CDLL("libm.so.6")
    # Resolve the file actually providing reference expf/tanhf/logf in this process.
    class DlInfo(ctypes.Structure):
        _fields_ = [("fname", ctypes.c_char_p), ("base", ctypes.c_void_p),
                    ("sname", ctypes.c_char_p), ("addr", ctypes.c_void_p)]
    dl = ctypes.CDLL(None)
    dl.dladdr.argtypes = [ctypes.c_void_p, ctypes.POINTER(DlInfo)]
    paths = {}
    for name in ("tanhf", "expf", "logf", "sqrtf", "roundf"):
        info = DlInfo()
        if not dl.dladdr(ctypes.cast(getattr(lib, name), ctypes.c_void_p), ctypes.byref(info)):
            raise RuntimeError("cannot bind actual libm: " + name)
        path = Path(info.fname.decode()).resolve()
        paths[name] = {"path": str(path), "sha256": sha(path)}
    return {"libc": platform.libc_ver(), "symbols": paths,
            "reference_calling_convention": "ctypes c_float -> libm scalar -> c_float",
            "native_calling_convention": "direct scalar libm float -> float; no builtin replacement"}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--baseline", type=Path, required=True)
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    baseline = json.loads(args.baseline.read_text())
    # Original shared dependencies stay read-only and must match accepted v3.
    for name, expected in baseline["source_sha256"].items():
        if name.startswith("reference/") and sha(ROOT / name) != expected:
            raise ValueError("original dependency changed: " + name)
    engine = NATIVE / "examples/laya/src/engine.cpp"
    text = engine.read_text()
    start = text.index("Answer DecisionEngine::decode_answer(")
    stop = text.index("\nDecideResult DecisionEngine::decide_one(", start)
    member = text[start:stop]
    body = member[member.index("{"):]
    if hashlib.sha256(body.encode()).hexdigest() != "6178b69b279de78bec6e84e726426b30c9acbf88c2328b358fe60f8752095a1c":
        raise ValueError("original decoder body changed")
    generated = args.output / "native_decode_generated.inc"
    generated.write_text("namespace laya {\nAnswer decode_original_adapter(const DecisionRecipe& recipe_, bool has_act_, const Question& q, const float* logits, int k, const float* act) " + body + "\n}\n")
    sources = [ROOT / "host/m007_deploy/native_session.cpp",
        NATIVE / "runtime/src/pipeline/tokenizer.cpp"] + [
        NATIVE / "examples/laya/src" / (name + ".cpp")
        for name in ("questions", "recipe", "sequence", "language")]
    sources += [ROOT / "hls/operators" / (name + ".cpp") for name in
        ("embedding_full_compute", "layernorm_compute", "attention_full_compute", "decision_full_compute")]
    sources += [ROOT / "hls/common/laya_numeric.cpp"]
    includes = [ROOT / "include", NATIVE / "runtime/include", NATIVE / "third_party/ggml/include",
                NATIVE / "examples/laya/include", args.output]
    flags = ["c++", "-std=c++17", "-O3", "-mavx2", "-mavx512f", "-mavx512bw", "-mavx512vnni", "-fPIC", "-shared", "-pthread", "-fvisibility=hidden",
        "-fno-fast-math", "-ffp-contract=off", "-frounding-math",
        "-fno-builtin-tanhf", "-fno-builtin-expf", "-fno-builtin-logf",
        "-fno-builtin-sqrtf", "-fno-builtin-roundf", "-ffunction-sections", "-fdata-sections",
        "-Wl,--gc-sections", "-Wl,-z,defs", "-Wall", "-Wextra"]
    flags += ["-I" + str(path) for path in includes]
    binary = args.output / "libm007_session.so"
    command = flags + [str(path) for path in sources] + ["-o", str(binary), "-lm"]
    print(subprocess.check_output(["c++", "--version"], text=True), flush=True)
    print("compile_session=" + repr(command), flush=True)
    subprocess.run(command, check=True)
    loaded = ctypes.CDLL(str(binary))
    exports = ("m007_create", "m007_destroy", "m007_error", "m007_json", "m007_prepare",
               "m007_finish", "m007_cancel", "m007_checkpoint", "m007_metrics", "m007_cache_info", "m007_fenv", "m007_dot32_diagnostic")
    for symbol in exports:
        getattr(loaded, symbol)
    dependencies = {}
    for source in sources:
        listing = subprocess.check_output(["c++", "-std=c++17", "-MM"] +
            ["-I" + str(path) for path in includes] + [str(source)], text=True).replace("\\\n", " ")
        for name in shlex.split(listing.split(":", 1)[1]):
            path = Path(name).resolve()
            if path.is_relative_to(ROOT):
                dependencies[str(path.relative_to(ROOT))] = sha(path)
    # Wrapper and contract are part of this same-version production identity.
    for path in sorted((ROOT / "host/m007_deploy").iterdir()):
        if path.suffix in (".py", ".h", ".json", ".cpp"):
            dependencies[str(path.relative_to(ROOT))] = sha(path)
    closure = args.output / "native_sources.tar.gz"
    with tarfile.open(closure,"w:gz") as archive:
        for name in sorted(dependencies):
            archive.add(ROOT/name,arcname=name,recursive=False)
        archive.add(generated,arcname="generated/native_decode_generated.inc",recursive=False)
    report = {"schema": "m007-native-session-build-v1", "binary_sha256": sha(binary),
        "source_sha256": dependencies, "command": command, "libm": libm_identity(),
        "recoverable_native_sources":{"path":str(closure),"sha256":sha(closure),"file_count":len(dependencies)+1},
        "required_ISA":["x86_64","avx512f","avx512bw","avx512_vnni"],
        "original_decode_body_sha256": hashlib.sha256(body.encode()).hexdigest(),
        "generated_decode_sha256": sha(generated), "device": "NOT_RUN",
        "CPU_backend": "native_cpu_contract", "threads": 4,
        "cache": "50368 post-initial-gamma-LN rows, model Session owned, 206307328 bytes",
        "exports_verified": list(exports), "numerical_equivalence": "NOT_RUN", "performance": "NOT_RUN"}
    binary.with_suffix(".identity.json").write_text(json.dumps(report, indent=2) + "\n")
    print("M007_NATIVE_SESSION_BUILD_PASS native_cpu_contract=1 device=NOT_RUN", flush=True)


if __name__ == "__main__":
    main()
