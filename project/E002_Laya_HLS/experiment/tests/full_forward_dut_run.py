#!/usr/bin/env python3
"""Build real ABI B2/B1 requests and record one persistent DUT run.

The C++ runner reads production BO bytes through the controller's checkpoint
callback. This wrapper only constructs request frames and hashes observations;
the separate comparator owns every independent numerical expectation.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import struct
import subprocess
import sys
import traceback
import uuid


SCENARIOS = ("B2_S128", "B1_from_b0_S128", "B1_from_b1_S128")
OP_NAMES = {
    0x01: "EMB_TOKEN", 0x02: "EMB_TYPE",
    0x10: "LN_EMB", 0x11: "LN_ATTN", 0x12: "LN_FFN",
    0x13: "LN_FINAL", 0x14: "LN_MARKER", 0x20: "QUANT",
    0x30: "LIN_QKV", 0x31: "LIN_WO", 0x32: "LIN_WI",
    0x33: "LIN_DOWN", 0x34: "LIN_DEC_FC1", 0x35: "LIN_DEC_FC2",
    0x36: "LIN_SCORER_FC1", 0x37: "LIN_ACT_FC2",
    0x40: "ROPE", 0x50: "QK", 0x51: "SOFTMAX_ATT",
    0x52: "AV", 0x53: "FP_SCORER_FC2", 0x54: "FP_ACT_FC1",
    0x55: "SOFTMAX_CAND", 0x60: "GEGLU", 0x61: "RELU",
    0x62: "ADD_RESIDUAL", 0x63: "ADD_TYPE",
    0x64: "BIAS_GELU_SCORER", 0x65: "BIAS_GELU_ACT",
    0x66: "APPLY_CAND_MASK", 0x70: "GATHER_MARKER",
    0x71: "CAND_STATS", 0x72: "CONCAT_ACT",
    0x80: "LOAD_W", 0x81: "LOAD_KV", 0x82: "LOAD_LN_PARAMS",
    0x83: "LOAD_ROPE", 0x84: "IO_VALIDATE",
    0x85: "RESULT_COMMIT",
}
OP_CODES = {name: code for code, name in OP_NAMES.items()}
Q8_LINEAR_CODES = tuple(range(0x30, 0x38))
LN_CODES = tuple(range(0x10, 0x15))


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def align64(size: int) -> int:
    return (size + 63) & ~63


def source_payloads(frame: bytes) -> list[bytes]:
    require(len(frame) == 1856 and frame[:4] == b"LYRQ" and
            struct.unpack_from("<HH", frame, 20) == (2, 128),
            "frozen B2/S128 ABI source request")
    payloads = []
    for index, size in enumerate((1024, 256, 128, 32, 8)):
        directory = 128 + index * 32
        offset, length = struct.unpack_from("<II", frame, directory + 4)
        require(length == size and offset + length <= len(frame),
                f"frozen source payload {index}")
        payloads.append(frame[offset:offset + length])
    return payloads


def make_request(source: bytes, package_tags: bytes,
                 selected: int | None, request_id: int) -> bytes:
    payloads = source_payloads(source)
    B, S = (2 if selected is None else 1), 128
    if selected is not None:
        require(selected in (0, 1), "B1 selected source batch")
        sizes = (S * 4, S, 16 * 4, 16, 4)
        payloads = [data[selected * size:(selected + 1) * size]
                    for data, size in zip(payloads, sizes)]
        markers = [struct.unpack_from("<i", payloads[2], i * 4)[0] -
                   selected * S for i in range(16)]
        require(all(0 <= marker < S for marker in markers),
                "B1 marker positions rebased into local token space")
        payloads[2] = struct.pack("<16i", *markers)
    output = bytearray(source[:320])
    output[40:104] = package_tags
    struct.pack_into("<H", output, 20, B)
    struct.pack_into("<Q", output, 24, request_id)
    offset = 320
    for index, data in enumerate(payloads):
        dtype = 2 if index in (1, 3) else 1
        rank = 1 if index == 4 else 2
        dim1 = S if index < 2 else 1 if index == 4 else 16
        stride0 = (4 * S, S, 64, 16, 4)[index]
        stride1 = (4, 1, 4, 1, 0)[index]
        elements = B if index == 4 else B * (S if index < 2 else 16)
        struct.pack_into("<HBBIIHHIIII", output, 128 + index * 32,
                         index + 1, dtype, rank, offset, len(data),
                         B, dim1, stride0, stride1, elements, 0)
        require(len(output) <= offset, "monotonic request payload offsets")
        output.extend(b"\x00" * (offset - len(output)))
        output.extend(data)
        output.extend(b"\x00" * (align64(len(output)) - len(output)))
        offset = len(output)
    struct.pack_into("<I", output, 16, len(output))
    require(len(output) == (1856 if B == 2 else 1152),
            "exact real ABI frame byte size")
    return bytes(output)


def parse_state(path: pathlib.Path) -> tuple[dict, dict]:
    lines = [line.split("\t") for line in path.read_text().splitlines()]
    require(len(lines) == 2 and lines[0][0] == "pre" and
            lines[1][0] == "post" and all(len(line) == 272 for line in lines),
            "production runtime pre/post snapshots")
    keys = ("session_generation", "last_accepted_request_id",
            "last_task_id", "tasks_retired", "request_valid",
            "model_header_valid", "valid_owner_count",
            "nonfree_owner_count", "a8_max_epoch", "ln_gamma_max_epoch",
            "numeric_a8_epoch",
            "owner_claims", "owner_leases", "encoder_layers_completed",
            "decision_layers_completed")
    snapshots = []
    for line in lines:
        snapshot = {key: int(value) for key, value in
                    zip(keys, line[1:1 + len(keys)])}
        calls = [int(value) for value in line[1 + len(keys):]]
        require(len(calls) == 256 and all(count >= 0 for count in calls),
                "actual per-Op call vector")
        snapshot["op_calls_by_code"] = calls
        snapshot["op_calls_total"] = sum(calls)
        snapshots.append(snapshot)
    return tuple(snapshots)


def observed_counts(state: dict) -> dict:
    calls = state["op_calls_by_code"]
    return {
        "task_retirements": state["tasks_retired"],
        "owner_claims": state["owner_claims"],
        "owner_leases": state["owner_leases"],
        "a8_max_epoch": state["a8_max_epoch"],
        "numeric_a8_epoch": state["numeric_a8_epoch"],
        "ln_gamma_max_epoch": state["ln_gamma_max_epoch"],
        "encoder_layers_completed": state["encoder_layers_completed"],
        "decision_layers_completed": state["decision_layers_completed"],
        "q8_weight_loads": calls[OP_CODES["LOAD_W"]],
        "kv_loads": calls[OP_CODES["LOAD_KV"]],
        "ln_parameter_loads": calls[OP_CODES["LOAD_LN_PARAMS"]],
        "rope_table_loads": calls[OP_CODES["LOAD_ROPE"]],
        "quant_tiles": calls[OP_CODES["QUANT"]],
        "q8_linear_tiles": sum(calls[code] for code in Q8_LINEAR_CODES),
        "ln_tiles": sum(calls[code] for code in LN_CODES),
        "op_calls_by_name": {
            OP_NAMES.get(code, f"OP_{code:02X}"): count
            for code, count in enumerate(calls) if count
        },
    }


def check_design_counts(scenario: str, observed: dict,
                        design: dict) -> None:
    expected = design["expected_calls"]
    actual_ops = observed["op_calls_by_name"]
    for name, wanted in expected.items():
        got = (observed["q8_linear_tiles"] if name == "Q8_LINEAR_all"
               else actual_ops.get(name, 0))
        require(got == wanted,
                f"{scenario} observed {name}={got}, design expected {wanted}")
    for actual_key, expected_key in (
            ("task_retirements", "sum_without_io_validate_or_result_commit"),
            ("q8_weight_loads", "q8_weight_loads"),
            ("quant_tiles", "q8_quant_tiles"),
            ("ln_tiles", "ln_tiles")):
        got, wanted = observed[actual_key], design[expected_key]
        require(got == wanted,
                f"{scenario} observed {actual_key}={got}, design expected {wanted}")


def parse_checkpoints(directory: pathlib.Path, B: int) -> list[dict]:
    entries = []
    for line in (directory / "checkpoints.tsv").read_text().splitlines():
        fields = line.split("\t")
        require(len(fields) == 10, "physical checkpoint record width")
        name = fields[0]
        b, rows, width, space, buffer_id, bank, epoch, region, count = (
            int(value) for value in fields[1:])
        require(b == B and rows > 0 and width > 0 and
                count == B * rows * width * 4 and space in (0, 1, 2),
                f"{name} callback shape and byte count")
        shape = ([B, rows, width] if space == 0 or
                 (space == 1 and width != 1) else [B, rows] if space == 1
                 else [B, width])
        path = directory / f"{name}.f32.bin"
        require(path.stat().st_size == count,
                f"{name} physical dump byte count")
        entries.append({"name": name, "shape": shape, "bytes": count,
                        "sha256": sha256(path), "path": str(path),
                        "source": "ABI_RESULT_FRAME" if name == "final18"
                        else "PRODUCTION_PHYSICAL_BUFFER",
                        "buffer_id": buffer_id, "bank": bank,
                        "epoch": epoch, "region": region,
                        "row_space": space})
    require(len(entries) == len({entry["name"] for entry in entries}) == 47,
            "exact 47 distinct checkpoints")
    return entries


def main() -> int:
    if len(sys.argv) not in (6, 7):
        print("usage: full_forward_dut_run.py ROOT PACKAGE FROZEN_B2_REQUEST "
              "EXECUTABLE OUTPUT_DIR [SOURCE_CLOSURE_REPORT]", file=sys.stderr)
        return 2
    root, package, frozen, executable, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:6])
    closure = pathlib.Path(sys.argv[6]).resolve() if len(sys.argv) == 7 else None
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "PREPARING",
                    "role": "one_persistent_production_forward_controller_session"}
    try:
        source = frozen.read_bytes()
        package_manifest = package / "manifest.json"
        manifest = json.loads(package_manifest.read_text())
        design_count_path = (root / "results/p2_environment_20261007/"
                             "f0_expected_task_counts_s128.json")
        design_counts = json.loads(design_count_path.read_text())
        require(set(SCENARIOS[:1]) | {"B1_S128"} <= set(design_counts),
                "independent S128 design count cases")
        aux_path = package / "aux.bin"
        aux_original_sha256 = sha256(aux_path)
        aux = aux_path.read_bytes()
        tags = manifest["tags"]
        package_tags = aux[32:96]
        require(len(package_tags) == 64 and all(
            package_tags[i * 16:(i + 1) * 16].hex() == tags[key]
            for i, key in enumerate(("model", "numeric", "layout", "build"))),
            "package AUX identity matches four manifest tags")
        generation = struct.unpack_from("<Q", source, 32)[0]
        require(generation > 0, "frozen request generation")
        inputs = output / "inputs"
        dut = output / "dut"
        inputs.mkdir(parents=True, exist_ok=True)
        dut.mkdir(parents=True, exist_ok=True)
        input_records = {}
        for index, scenario in enumerate(SCENARIOS):
            selected = None if index == 0 else index - 1
            request_id = 1 if index == 0 else index + 2
            path = inputs / f"{scenario}.request.bin"
            path.write_bytes(make_request(source, package_tags,
                                          selected, request_id))
            input_records[scenario] = {"path": str(path),
                                       "sha256": sha256(path),
                                       "bytes": path.stat().st_size,
                                       "request_id": request_id,
                                       "marker_rebased": selected is not None}
        fault_name = "accepted_gamma_failure"
        fault_request = inputs / f"{fault_name}.request.bin"
        fault_request.write_bytes(make_request(source, package_tags, None, 2))
        input_records[fault_name] = {
            "path": str(fault_request), "sha256": sha256(fault_request),
            "bytes": fault_request.stat().st_size, "request_id": 2,
            "role": "accepted_in_graph_numeric_failure_input",
        }
        library = executable.parent / "liblaya_full.a"
        require(library.is_file(), "linked production DUT archive")
        if closure is not None:
            closure_report = json.loads(closure.read_text())
            require(closure_report["status"] == "DUT_SOURCE_CLOSURE_COMPLETE" and
                    closure_report["library_sha256"] == sha256(library),
                    "exact hash-bound final source closure")
            source_build_hash = sha256(closure)
            source_build_kind = "complete_compiler_dependency_closure"
        else:
            source_build_hash = sha256(library)
            source_build_kind = "archive_hash_preliminary"
        session = uuid.uuid4().hex
        command = ([str(executable), str(package)] +
                   [input_records[name]["path"] for name in
                    (SCENARIOS[0], fault_name, *SCENARIOS[1:])] +
                   [str(dut), session])
        report.update({
            "command": command, "run_session_id": session,
            "source_build_sha256": source_build_hash,
            "source_build_kind": source_build_kind,
            "model_manifest_sha256": sha256(package_manifest),
            "model_aux_original_sha256": aux_original_sha256,
            "design_count_table_path": str(design_count_path),
            "design_count_table_sha256": sha256(design_count_path),
            "frozen_request_sha256": sha256(frozen),
            "executable_sha256": sha256(executable),
            "library_sha256": sha256(library),
            "runner_source_sha256": sha256(
                root / "tests/full_forward_dut_runner.cpp"),
            "wrapper_source_sha256": sha256(pathlib.Path(__file__)),
            "inputs": input_records, "dut_dump_root": str(dut),
            "runs": {},
        })
        report["status"] = "RUNNING"
        lines: list[str] = []
        with subprocess.Popen(command, cwd=root, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True,
                              bufsize=1) as process:
            require(process.stdout is not None, "production runner pipe")
            for line in process.stdout:
                lines.append(line)
                print(line, end="", flush=True)
            return_code = process.wait(timeout=4 * 3600)
        combined_log = "".join(lines)
        report["exit_code"] = return_code
        report["combined_log"] = combined_log
        (output / "runner_combined.log").write_text(combined_log)
        require(sha256(aux_path) == aux_original_sha256,
                "model package AUX file unchanged by in-memory fault")
        require(return_code == 0 and
                "FULL_FORWARD_DUT_RUNNER_PASS persistent_requests=4 "
                "successful_requests=3 checkpoints=141 "
                "accepted_failure_recovered=1" in combined_log,
                "production persistent controller run")
        fault_directory = dut / fault_name
        fault_pre, fault_post = parse_state(fault_directory / "runtime.tsv")
        mutation_fields = (fault_directory / "mutation.tsv").read_text(
        ).strip().split("\t")
        require(len(mutation_fields) == 7 and
                mutation_fields[-1] == session,
                "actual temporary gamma mutation record")
        gamma_offset, original_bits, injected_bits, fault_status, \
            fault_detail, fault_tasks = (int(value) for value in
                                        mutation_fields[:6])
        require(gamma_offset >= 128 and gamma_offset + 4 <= len(aux) and
                struct.unpack_from("<I", aux, gamma_offset)[0] ==
                original_bits and
                original_bits & 0x7f800000 != 0x7f800000 and
                injected_bits == 0x7f800000,
                "original finite model gamma and injected nonfinite word")
        fault_frame = fault_directory / "result.bin"
        error = fault_frame.read_bytes()
        require(len(error) == 384 and error[:4] == b"LYRS" and
                struct.unpack_from("<H", error, 10)[0] == 6 and
                struct.unpack_from("<QQ", error, 16) == (2, generation) and
                struct.unpack_from("<HHHH", error, 96) == (2, 128, 0, 0) and
                struct.unpack_from("<I", error, 112)[0] == 9 and
                error[32:96] == package_tags and
                struct.unpack_from("<HHI", error, 116) ==
                (1, 0x82, fault_detail) and
                error[128:320] == bytes(192) and
                struct.unpack_from("<Q", error, 320)[0] == 0 and
                struct.unpack_from("<Q", error, 328)[0] == fault_tasks and
                struct.unpack_from("<Q", error, 336)[0] == 578 and
                struct.unpack_from("<Q", error, 344)[0] == 0 and
                struct.unpack_from("<Q", error, 352)[0] ==
                0xffffffffffffffff and
                struct.unpack_from("<I", error, 360)[0] == fault_tasks and
                struct.unpack_from("<I", error, 364)[0] == 0 and
                fault_status == 6 and fault_detail ==
                ((7 << 24) | (0x82 << 16) | 15),
                "accepted failure result identity, first cause, zero logits")
        require(fault_post["session_generation"] == generation and
                fault_post["last_accepted_request_id"] == 2 and
                fault_post["last_task_id"] == fault_tasks and
                fault_post["tasks_retired"] == fault_tasks and
                fault_post["op_calls_total"] == fault_tasks and
                fault_post["encoder_layers_completed"] == 0 and
                fault_post["decision_layers_completed"] == 0 and
                fault_post["ln_gamma_max_epoch"] >
                fault_pre["ln_gamma_max_epoch"] and
                fault_post["a8_max_epoch"] >=
                fault_pre["a8_max_epoch"] > 0 and
                fault_post["numeric_a8_epoch"] >=
                fault_pre["numeric_a8_epoch"] > 0 and
                fault_post["owner_claims"] > 0,
                "accepted numerical failure observed in same runtime")
        fault_metadata = {
            "scenario": fault_name, "B": 2, "S": 128,
            "request_id": 2, "generation": generation,
            "input_sha256": input_records[fault_name]["sha256"],
            "model_aux_original_sha256": aux_original_sha256,
            "mutation": {"aux_offset": gamma_offset,
                         "original_bits": original_bits,
                         "original_bytes_hex": aux[gamma_offset:
                                                   gamma_offset + 4].hex(),
                         "injected_bits": injected_bits,
                         "injected_bytes_hex":
                         struct.pack("<I", injected_bits).hex(),
                         "restored_before_next_request": True,
                         "entire_aux_memory_restored_bit_identical": True,
                         "package_file_unchanged": True},
            "run_session_id": session,
            "source_build_sha256": source_build_hash,
            "source_build_kind": source_build_kind,
            "pre_runtime": fault_pre, "post_runtime": fault_post,
            "observed_counts": observed_counts(fault_post),
            "observed_error_result": {
                "status": struct.unpack_from("<H", error, 10)[0],
                "flags": struct.unpack_from("<I", error, 112)[0],
                "error_stage": struct.unpack_from("<H", error, 116)[0],
                "error_op": struct.unpack_from("<H", error, 118)[0],
                "error_detail": struct.unpack_from("<I", error, 120)[0],
                "error_task_id": struct.unpack_from("<I", error, 360)[0],
                "tasks_retired": struct.unpack_from("<Q", error, 328)[0],
                "accepted_input_elements":
                    struct.unpack_from("<Q", error, 336)[0],
                "committed_output_elements":
                    struct.unpack_from("<Q", error, 344)[0],
                "first_bad_element": struct.unpack_from("<Q", error, 352)[0],
                "output_payload_all_zero": error[128:320] == bytes(192),
            },
            "result_frame_sha256": sha256(fault_frame),
            "status": "ACCEPTED_IN_GRAPH_NUMERICAL_FAILURE_OBSERVED",
        }
        fault_metadata_path = fault_directory / "metadata.json"
        fault_metadata_path.write_text(json.dumps(fault_metadata, indent=2) + "\n")
        report["accepted_failure"] = {
            "metadata_path": str(fault_metadata_path),
            "metadata_sha256": sha256(fault_metadata_path),
            "result_frame_sha256": sha256(fault_frame),
            "pre_runtime": fault_pre, "post_runtime": fault_post,
            "observed_counts": fault_metadata["observed_counts"],
            "observed_error_result": fault_metadata["observed_error_result"],
        }
        for index, scenario in enumerate(SCENARIOS):
            directory = dut / scenario
            B = 2 if index == 0 else 1
            pre, post = parse_state(directory / "runtime.tsv")
            require(post["session_generation"] == generation and
                    post["last_accepted_request_id"] ==
                    input_records[scenario]["request_id"] and
                    post["last_task_id"] == post["tasks_retired"] and
                    post["op_calls_total"] == post["tasks_retired"] and
                    post["encoder_layers_completed"] == 28 and
                    post["decision_layers_completed"] == 2 and
                    post["owner_claims"] > 0 and
                    post["owner_leases"] > 0 and
                    post["request_valid"] == 1 and
                    post["model_header_valid"] == 1,
                    f"{scenario} actual post-controller state")
            if index == 0:
                require(fault_pre == post,
                        "accepted fault inherits exact B2 runtime state")
            elif index == 1:
                require(pre == fault_post,
                        "first B1 inherits exact accepted-failure state")
            else:
                require(pre == report["runs"][SCENARIOS[index - 1]]
                        ["post_runtime"],
                        f"{scenario} inherits exact prior runtime state")
            actual = observed_counts(post)
            expected = design_counts["B2_S128" if B == 2 else "B1_S128"]
            check_design_counts(scenario, actual, expected)
            checkpoints = parse_checkpoints(directory, B)
            frame = directory / "result.bin"
            require(frame.stat().st_size == 384,
                    f"{scenario} actual ABI result frame")
            metadata = {
                "scenario": scenario, "B": B, "S": 128,
                "request_id": input_records[scenario]["request_id"],
                "generation": generation,
                "input_marker_rebased": index > 0,
                "input_sha256": input_records[scenario]["sha256"],
                "tags": tags, "run_session_id": session,
                "source_build_sha256": source_build_hash,
                "source_build_kind": source_build_kind,
                "pre_runtime": pre, "post_runtime": post,
                "observed_counts": actual,
                "design_expected_counts": expected,
                "design_count_table_sha256": sha256(design_count_path),
                "result_frame_sha256": sha256(frame),
                "checkpoints": checkpoints,
            }
            metadata_path = directory / "metadata.json"
            metadata_path.write_text(json.dumps(metadata, indent=2) + "\n")
            report["runs"][scenario] = {
                "metadata_path": str(metadata_path),
                "metadata_sha256": sha256(metadata_path),
                "result_frame_sha256": sha256(frame),
                "pre_runtime": pre, "post_runtime": post,
                "observed_counts": actual,
                "design_expected_counts": expected,
                "checkpoint_count": len(checkpoints),
            }
            print(f"{scenario}: production DUT dumped 47 checkpoints",
                  flush=True)
        report["status"] = "DUT_FORWARD_DUMPS_COMPLETE"
    except Exception as exc:
        report["status"] = "DUT_FORWARD_DUMP_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
    (output / "full_forward_dut_run_report.json").write_text(
        json.dumps(report, indent=2) + "\n")
    return 0 if report["status"] == "DUT_FORWARD_DUMPS_COMPLETE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
