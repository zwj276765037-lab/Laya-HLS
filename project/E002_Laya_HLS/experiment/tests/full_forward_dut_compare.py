#!/usr/bin/env python3
"""Compare native P2 controller checkpoints to the independent GGUF oracle."""

from __future__ import annotations

import hashlib
import json
import pathlib
import struct
import sys
import traceback


SCENARIOS = ("B2_S128", "B1_from_b0_S128", "B1_from_b1_S128")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def hex_bytes(value: object, size: int, label: str) -> None:
    require(isinstance(value, str) and len(value) == 2 * size and
            all(c in "0123456789abcdef" for c in value),
            f"{label} lowercase hex identity")


def compare_bytes(name: str, wanted: bytes, got: bytes) -> None:
    require(len(got) == len(wanted), f"{name} output byte count")
    if wanted == got:
        return
    at = next(i for i, (a, b) in enumerate(zip(wanted, got)) if a != b)
    word = at // 4
    expected = struct.unpack_from("<I", wanted, word * 4)[0]
    actual = struct.unpack_from("<I", got, word * 4)[0]
    raise AssertionError(
        f"{name} first bit mismatch F32 index={word} byte={at} "
        f"expected_bits=0x{expected:08x} actual_bits=0x{actual:08x}")


def compare(oracle_path: pathlib.Path, package: pathlib.Path,
            dut_root: pathlib.Path, output: pathlib.Path) -> dict:
    oracle = json.loads(oracle_path.read_text())
    manifest = json.loads((package / "manifest.json").read_text())
    result: dict = {
        "status": "COMPARING",
        "role": "independent_47_checkpoint_bitwise_full_forward_DUT_comparison",
        "oracle_report_sha256": sha256(oracle_path),
        "model_manifest_sha256": sha256(package / "manifest.json"),
        "comparator_sha256": sha256(pathlib.Path(__file__)),
        "runs": {},
    }
    try:
        require(oracle["status"] ==
                "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON",
                "independent oracle status")
        require(set(oracle["runs"]) == set(SCENARIOS),
                "independent oracle scenario set")
        tags = manifest["tags"]
        for key in ("model", "numeric", "layout", "build"):
            hex_bytes(tags[key], 16, f"package {key} tag")
        source_build = None
        session_id = None
        all_dut: dict[str, dict[str, bytes]] = {}
        for scenario_index, scenario in enumerate(SCENARIOS):
            one = oracle["runs"][scenario]
            expected_records = {entry["name"]: entry
                                for entry in one["checkpoints"]}
            require(len(one["checkpoints"]) == len(expected_records) == 47,
                    f"{scenario} exact 47 oracle checkpoints")
            metadata_path = dut_root / scenario / "metadata.json"
            metadata = json.loads(metadata_path.read_text())
            expected_B = 2 if scenario == "B2_S128" else 1
            require(metadata["scenario"] == scenario and
                    metadata["B"] == expected_B and metadata["S"] == 128,
                    f"{scenario} DUT shape identity")
            require(isinstance(metadata["request_id"], int) and
                    metadata["request_id"] ==
                    (1 if scenario_index == 0 else scenario_index + 2) and
                    isinstance(metadata["generation"], int) and
                    metadata["generation"] > 0,
                    f"{scenario} request identity")
            require(metadata["input_marker_rebased"] == (expected_B == 1),
                    f"{scenario} B1 marker rebasing record")
            require(metadata["tags"] == tags,
                    f"{scenario} four package tags")
            build_hash = metadata["source_build_sha256"]
            hex_bytes(build_hash, 32, f"{scenario} source build hash")
            if source_build is None:
                source_build = build_hash
            require(build_hash == source_build,
                    f"{scenario} shared source build")
            run_session = metadata["run_session_id"]
            require(isinstance(run_session, str) and run_session,
                    f"{scenario} run session id")
            if session_id is None:
                session_id = run_session
            require(run_session == session_id,
                    f"{scenario} same persistent runtime session")
            require(isinstance(metadata["pre_runtime"], dict) and
                    isinstance(metadata["post_runtime"], dict) and
                    metadata["pre_runtime"] and metadata["post_runtime"],
                    f"{scenario} runtime state snapshots")
            dut_entries = metadata["checkpoints"]
            dut_records = {entry["name"]: entry for entry in dut_entries}
            require(len(dut_entries) == len(dut_records) == 47 and
                    set(dut_records) == set(expected_records),
                    f"{scenario} exact 47 DUT checkpoint names")
            captured: dict[str, bytes] = {}
            checked = []
            for name, expected in expected_records.items():
                oracle_file = pathlib.Path(expected["path"])
                require(oracle_file.resolve() ==
                        (oracle_path.parent / scenario /
                         f"{name}.f32.bin").resolve(),
                        f"{scenario}:{name} oracle path identity")
                require(oracle_file.stat().st_size == expected["bytes"] and
                        sha256(oracle_file) == expected["sha256"],
                        f"{scenario}:{name} oracle hash identity")
                entry = dut_records[name]
                require(entry["shape"] == expected["shape"] and
                        entry["bytes"] == expected["bytes"],
                        f"{scenario}:{name} DUT shape/byte count")
                path = dut_root / scenario / f"{name}.f32.bin"
                require(path.stat().st_size == entry["bytes"] and
                        sha256(path) == entry["sha256"],
                        f"{scenario}:{name} DUT hash identity")
                wanted, got = oracle_file.read_bytes(), path.read_bytes()
                compare_bytes(f"{scenario}:{name}", wanted, got)
                captured[name] = got
                checked.append({"name": name, "shape": expected["shape"],
                                "bytes": expected["bytes"],
                                "sha256": entry["sha256"]})
            all_dut[scenario] = captured
            result["runs"][scenario] = {
                "metadata_sha256": sha256(metadata_path),
                "request_id": metadata["request_id"],
                "generation": metadata["generation"],
                "run_session_id": run_session,
                "input_marker_rebased": metadata["input_marker_rebased"],
                "pre_runtime": metadata["pre_runtime"],
                "post_runtime": metadata["post_runtime"],
                "checkpoint_count": len(checked),
                "checkpoints": checked,
                "status": "BITWISE_PASS",
            }
            print(f"{scenario}: 47/47 DUT checkpoints bitwise PASS", flush=True)
        failure_path = dut_root / "accepted_gamma_failure/metadata.json"
        failure = json.loads(failure_path.read_text())
        failure_frame = dut_root / "accepted_gamma_failure/result.bin"
        frame = failure_frame.read_bytes()
        require(failure["status"] ==
                "ACCEPTED_IN_GRAPH_NUMERICAL_FAILURE_OBSERVED" and
                failure["request_id"] == 2 and
                failure["generation"] ==
                result["runs"]["B2_S128"]["generation"] and
                failure["run_session_id"] == session_id and
                failure["source_build_sha256"] == source_build and
                failure["pre_runtime"] ==
                result["runs"]["B2_S128"]["post_runtime"] and
                failure["post_runtime"] ==
                result["runs"]["B1_from_b0_S128"]["pre_runtime"] and
                result["runs"]["B1_from_b0_S128"]["post_runtime"] ==
                result["runs"]["B1_from_b1_S128"]["pre_runtime"] and
                failure["result_frame_sha256"] == sha256(failure_frame) and
                len(frame) == 384 and frame[:4] == b"LYRS" and
                struct.unpack_from("<H", frame, 10)[0] == 6 and
                struct.unpack_from("<I", frame, 112)[0] == 9 and
                frame[128:320] == bytes(192) and
                struct.unpack_from("<Q", frame, 336)[0] == 578 and
                struct.unpack_from("<Q", frame, 344)[0] == 0,
                "same-session accepted numerical failure and B1 recovery")
        result["accepted_failure"] = {
            "metadata_sha256": sha256(failure_path),
            "result_frame_sha256": sha256(failure_frame),
            "request_id": 2,
            "post_runtime": failure["post_runtime"],
            "status": "ACCEPTED_FAILURE_RECOVERED",
        }
        for index, one_name in enumerate(SCENARIOS[1:]):
            for record in oracle["runs"]["B2_S128"]["checkpoints"]:
                name = record["name"]
                shape = record["shape"]
                require(shape[0] == 2, f"{name} B2 batch axis")
                b2_bytes = all_dut["B2_S128"][name]
                half = len(b2_bytes) // 2
                compare_bytes(f"{one_name}:{name} persistent B2 slice",
                              b2_bytes[index * half:(index + 1) * half],
                              all_dut[one_name][name])
        result["run_session_id"] = session_id
        result["source_build_sha256"] = source_build
        result["checkpoint_count"] = 141
        result["status"] = "DUT_FORWARD_141_CHECKPOINT_BITWISE_PASS"
    except Exception as exc:
        result["status"] = "DUT_FORWARD_CHECKPOINT_FAIL"
        result["error"] = f"{type(exc).__name__}: {exc}"
        result["traceback"] = traceback.format_exc()
        print(result["error"], file=sys.stderr)
    finally:
        output.mkdir(parents=True, exist_ok=True)
        (output / "full_forward_dut_compare_report.json").write_text(
            json.dumps(result, indent=2) + "\n")
    return result


def main() -> int:
    if len(sys.argv) != 5:
        print("usage: full_forward_dut_compare.py ORACLE_REPORT "
              "PACKAGE DUT_DUMP_ROOT OUTPUT_DIR", file=sys.stderr)
        return 2
    oracle, package, dut, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:])
    report = compare(oracle, package, dut, output)
    return 0 if report["status"] == \
        "DUT_FORWARD_141_CHECKPOINT_BITWISE_PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
