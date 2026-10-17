#!/usr/bin/env python3
"""Prepare Q8S2 ACT physical windows and command descriptors from frozen inputs."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct

BO_NAMES = ("embedding", "w_q0", "w_q1", "w_scale", "aux")
BO_BASES = (0x300000000, 0x500000000, 0x600000000,
            0x700000000, 0x800000000)
BO_ROLES = (0, 2, 3, 4, 5)
ACT_BASE = 0x900000000
OUT0_BASE = 0x200000000


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def slice_bo(path: Path, offset: int, length: int) -> bytes:
    require(0 <= offset and 0 <= length and offset + length <= path.stat().st_size,
            "package BO window out of bounds")
    with path.open("rb") as stream:
        stream.seek(offset)
        result = stream.read(length)
    require(len(result) == length, "short package BO read")
    return result


def emit(path: Path, value: bytes, beat_bytes: int) -> dict:
    require(len(value) % beat_bytes == 0, "unaligned memory image")
    path.write_text("".join(
        f"{int.from_bytes(value[i:i+beat_bytes], 'little'):0{2*beat_bytes}x}\n"
        for i in range(0, len(value), beat_bytes)))
    return digest(path)


def set_u64(words: list[int], index: int, value: int) -> None:
    words[index:index+2] = (value & 0xffffffff, value >> 32)


def set_bytes(words: list[int], index: int, value: bytes) -> None:
    require(len(value) % 4 == 0, "descriptor byte alignment")
    words[index:index+len(value)//4] = struct.unpack("<" + "I"*(len(value)//4), value)


def descriptor(v1: bytes | None, command: int, profile: int, tags: dict,
               record_sha: str, manifest_sha: str, build_sha: str,
               source_sha: str, context: bytes, bo_sizes: list[int]) -> list[int]:
    words = [0] * 256
    if v1 is not None:
        require(len(v1) == 512, "v1 ACT descriptor length")
        words[:32] = struct.unpack("<32I", v1[:128])
        words[48:62] = struct.unpack("<14I", v1[192:248])
    words[0:3] = (0x32533851, 2, command)
    for index, name in enumerate(("model", "numeric", "layout", "build")):
        set_bytes(words, 32 + index*4, bytes.fromhex(tags[name]))
    words[62:66] = (32768, 1024, profile, 0)
    set_u64(words, 66, 1)
    set_bytes(words, 68, context)
    for index, sha in ((72, record_sha), (80, manifest_sha),
                       (88, build_sha), (96, source_sha)):
        set_bytes(words, index, bytes.fromhex(sha))
    words[104:107] = (5, 32, 18)
    for i, (role, base, size) in enumerate(zip(BO_ROLES, BO_BASES, bo_sizes)):
        j = 112 + 8*i
        words[j:j+2] = (role, 1)
        set_u64(words, j+2, base)
        set_u64(words, j+4, size)
        set_u64(words, j+6, 0xabc001 + i)
    return words


def words_bytes(words: list[int]) -> bytes:
    return struct.pack("<" + "I"*len(words), *words)


def main() -> None:
    parser = argparse.ArgumentParser()
    for name in ("package", "validation_record", "fixtures", "v1_descriptors",
                 "output"):
        parser.add_argument(name, type=Path)
    parser.add_argument("--profile", choices=("strict", "fast"), required=True)
    parser.add_argument("--trace-off", action="store_true")
    args = parser.parse_args()
    package, validation, fixtures, old_desc, output = (
        getattr(args, name).resolve() for name in
        ("package", "validation_record", "fixtures", "v1_descriptors", "output"))
    require(not output.exists(), "fresh Q8S2 ACT input directory")
    pm = json.loads((package / "manifest.json").read_text())
    vr = json.loads(validation.read_text())
    build_sha = pm["tag_preimages"]["build"]["sha256"]
    fm = json.loads((fixtures / "manifest.json").read_text())
    act = next(x for x in fm["cases"] if x["name"] == "act")
    record = act["model_record"]
    require(pm["candidate_schema"] == "laya-q8-session-v2-package" and
            build_sha == digest(package / "build_preimage.json")["sha256"] and
            pm["tags"]["build"] == build_sha[:32] and
            vr["status"] == "PASS" and
            vr["independent_package_check"]["status"] == "MODEL_PACKAGE_PASS" and
            vr["manifest_sha256"] == digest(package / "manifest.json")["sha256"] and
            vr["source_gguf_sha256"] == pm["source_model"]["sha256"],
            "frozen Q8S2 package/record identity")
    require(record["family"] == 12 and record["layer"] == 255 and
            record["q0_span"] == 2048 and record["q1_span"] == 0 and
            record["scale_span"] == 128 and record["bias_span"] == 8,
            "ACT window shape")
    require(fm["session"] == {"request_id": 3, "generation": 1,
                              "B": 1, "S": 128}, "independent ACT fixture session")
    model_weight = next(x for x in pm["weights"] if x["family"] == 12
                        and x["layer"] == 255)
    require((model_weight["q_base"][0], model_weight["scale_base"],
             model_weight["bias_base"]) ==
            (record["q0_offset"], record["scale_offset"], record["bias_offset"]),
            "ACT window changed between fixture and Q8S2 package")
    bo_sizes = [pm["bo"][name]["size"] for name in BO_NAMES]
    source = (fixtures / "act_source_f32.bin").read_bytes()
    q0 = slice_bo(package / "w_q0.bin", record["q0_offset"], 2048)
    scale = slice_bo(package / "w_scale.bin", record["scale_offset"], 128)
    aux_header = slice_bo(package / "aux.bin", 0, 128)
    bias = slice_bo(package / "aux.bin", record["bias_offset"], 8)
    for package_bytes, fixture_name in ((q0, "act_q0.bin"),
                                        (scale, "act_w_scale.bin"),
                                        (bias, "act_bias.bin")):
        require(package_bytes == (fixtures / fixture_name).read_bytes(),
                "actual Q8S2 package differs from independent GGUF fixture")
    require(len(source) == 1024 and
            hashlib.sha256(source).hexdigest() == act["source_slice"]["sha256"],
            "ACT source identity")
    context = hashlib.sha256(
        bytes.fromhex(vr["manifest_sha256"]) + bytes.fromhex(build_sha)
    ).digest()[:16]
    binding = [int.from_bytes(context[:8], "little"),
               int.from_bytes(context[8:], "little"), 1]
    for i, base in enumerate(BO_BASES):
        binding += [base, bo_sizes[i], 0xabc001 + i]
    require(len(binding) == 18, "complete live binding")
    old_load = (old_desc / "act_load.bin").read_bytes()
    old_run = (old_desc / "act_run_trace.bin").read_bytes()
    require(len(old_load) == len(old_run) == 512, "v1 ACT descriptor shape")
    profile = 0 if args.profile == "strict" else 1
    common = (profile, pm["tags"], digest(validation)["sha256"],
              digest(package / "manifest.json")["sha256"], build_sha,
              pm["source_model"]["sha256"], context, bo_sizes)
    register = descriptor(None, 2, *common)
    revoke = descriptor(None, 3, *common)
    load1 = descriptor(old_load, 0, *common)
    run1 = descriptor(old_run, 1, *common)
    load2 = load1.copy()
    run2 = run1.copy()
    load2[8], load2[27], load2[29] = 4, 2, 2
    run2[8], run2[27], run2[29], run2[30], run2[31] = 6, 2, 2, 2, 5
    for run in (run1, run2):
        set_u64(run, 50, OUT0_BASE)
        if args.trace_off:
            run[3] = run[60] = run[61] = 0
    steps_data = (fixtures / "act_steps_u32x6.bin").read_bytes()
    steps = struct.unpack("<" + "I"*(len(steps_data)//4), steps_data)
    require(len(steps) == 8*2*6, "ACT independent group trace shape")
    trace = b"".join(struct.pack("<8I", *(steps[g*12:g*12+6] + (g, 1)))
                     for g in range(8))
    outputs = {
        "register.hex": (words_bytes(register), 4),
        "load1.hex": (words_bytes(load1), 4),
        "run1.hex": (words_bytes(run1), 4),
        "load2.hex": (words_bytes(load2), 4),
        "run2.hex": (words_bytes(run2), 4),
        "revoke.hex": (words_bytes(revoke), 4),
        "binding.hex": (struct.pack("<18Q", *binding), 8),
        "q0.hex": (q0, 64), "scale.hex": (scale, 64),
        "aux_header.hex": (aux_header, 4), "bias.hex": (bias, 4),
        "activation.hex": (source, 64),
        "a8q.hex": ((fixtures / "act_a8_q.bin").read_bytes(), 4),
        "a8half.hex": ((fixtures / "act_a8_scale.bin").read_bytes(), 4),
        "output.hex": ((fixtures / "act_output_f32.bin").read_bytes(), 4),
        "trace.hex": (trace, 4),
    }
    output.mkdir(parents=True)
    produced = {name: emit(output / name, value, width)
                for name, (value, width) in outputs.items()}
    manifest = {"schema": "tm1tn8_session_dma_act_inputs_v2",
                "profile": args.profile, "trace_on": not args.trace_off,
                "model_record": record, "actual_binding_beats": 18,
                "candidate_build_sha256": build_sha,
                "inputs": [digest(package / "manifest.json"), digest(validation),
                           digest(fixtures / "manifest.json"),
                           digest(old_desc / "manifest.json"),
                           digest(Path(__file__))],
                "outputs": produced}
    (output / "manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("TM1TN8_SESSION_DMA_ACT_INPUTS_V2_PASS profile=" + args.profile)


if __name__ == "__main__":
    main()
