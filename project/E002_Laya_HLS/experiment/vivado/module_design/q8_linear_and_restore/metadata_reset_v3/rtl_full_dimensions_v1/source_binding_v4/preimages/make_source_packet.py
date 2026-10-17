#!/usr/bin/env python3
"""Hash only existing source/input bytes; no fixture math or tool invocation."""
from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ISOLATED = HERE.parent
MODULE = ISOLATED.parent
BASE = HERE.parents[5]
MODEL = BASE / "build/model-attention-rtl-repair-20261008"
ACCEPTED = BASE / "results/engineering_p2/full_cpu_final_20261007"
REVIEW = BASE / "results/attention_rtl_repair_20261008"
RTL = MODULE / "runs/csynth_local_v1/work/hls/syn/verilog"
REPORT = MODULE / "runs/csynth_local_v1/work/hls/syn/report"
IP = MODULE / "runs/csynth_local_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado")
VITIS = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis")
ENDPOINT = REVIEW / "d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv"
ACT_TB = MODULE / "rtl_act_static_v1/tb"
G16 = REVIEW / "d2_controller_reachable/source/guard_16g.py"
G4 = REVIEW / "d2_axi_allocation_diagnostic/guard_trace_v5/tb/guard_runtime_4g.py"
OUT = ISOLATED / "source_binding_v3/source_packet.json"
PRIOR_CSIM_D = MODULE.parent / "runs/csim_legal_v1/work/hls/csim/build/obj"
HLS_DEPENDENCY_CLOSURE = MODULE / "runs/csynth_local_v1/preprocessed_dependency_closure.json"
CPU_INCLUDE_ROOTS = (VITIS / "include", BASE / "include", MODEL, MODULE / "source")
INCLUDE_RE = re.compile(r'^\s*#\s*include\s*([<"])([^">]+)[">]', re.M)


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def record(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "mode": oct(path.stat().st_mode & 0o777),
            "sha256": sha(path)}


def slice_record(path: Path, name: str, offset: int, count: int) -> dict:
    if offset < 0 or count <= 0 or offset + count > path.stat().st_size:
        raise ValueError(f"slice bounds {name}")
    with path.open("rb") as stream:
        stream.seek(offset)
        raw = stream.read(count)
    return {"name": name, "source_path": str(path.resolve()),
            "offset": offset, "bytes": count,
            "sha256": hashlib.sha256(raw).hexdigest()}


def cpu_literal_includes(source: Path) -> list[Path]:
    """Conservative union of literal project/vendor includes; no compiler run."""
    pending = [source]
    found = set()
    while pending:
        path = pending.pop().resolve()
        if path in found:
            continue
        found.add(path)
        for delimiter, name in INCLUDE_RE.findall(path.read_text(errors="replace")):
            roots = ((path.parent,) if delimiter == '"' else ()) + CPU_INCLUDE_ROOTS
            dependency = next((candidate for root in roots
                               if (candidate := root / name).is_file()), None)
            if dependency is not None:
                pending.append(dependency)
            elif delimiter == '"':
                raise ValueError(f"unresolved quoted include {name} from {path}")
    return sorted(found)


def prior_csim_dependencies(path: Path) -> list[Path]:
    # The old .d files were emitted by g++; their source TU entries are
    # relative to the old CSim build tree and are not reused as paths.
    data = path.read_text().replace("\\\n", " ")
    if ":" not in data:
        raise ValueError(f"malformed prior CSim dependency file: {path}")
    paths = []
    old_source = MODULE.parent / "source"
    for token in data.split(":", 1)[1].split():
        if not token.startswith("/"):
            continue
        candidate = Path(token)
        if candidate.parent == old_source:
            candidate = MODULE / "source" / candidate.name
        paths.append(candidate.resolve())
    return sorted(set(paths))


def main() -> int:
    verilog = sorted(RTL.glob("*.v"))
    dat = sorted(RTL.glob("*.dat"))
    wrappers = sorted(IP.glob("*/sim/*_ip.vhd"))
    if (len(verilog), len(dat), len(wrappers)) != (230, 108, 7):
        raise ValueError("frozen generated RTL/DAT/VHDL file counts")
    model = json.loads((MODEL / "manifest.json").read_text())
    weight = next(w for w in model["weights"] if w["family"] == 9 and w["layer"] == 255)
    if (weight["name"], weight["K"], weight["N"], weight["bias_name"],
        weight["q_base"], weight["scale_base"], weight["bias_base"]) != (
        "scorer_fc1.weight", 1024, 1024, "linear_120_baked_bias",
        [184156160, 184156160], 23019520, 1667776):
        raise ValueError("current scorer layout")
    gguf = Path(model["source_model"]["path"])
    tensors = {t["name"]: t for t in model["tensors"]}
    gguf_slices = [slice_record(gguf, name, tensors[name]["source_offset"],
                                tensors[name]["source_bytes"])
                   for name in ("scorer_fc1.weight", "linear_120_baked_bias")]
    for entry in gguf_slices:
        if entry["sha256"] != tensors[entry["name"]]["source_sha256"]:
            raise ValueError(f"GGUF tensor identity {entry['name']}")
    checkpoint_slices = []
    row_offset = (1 * 16 + 15) * 1024 * 4
    for side in ("oracle/B2_S128", "dut/dut/B2_S128"):
        for name in ("marker_norm.f32.bin", "scorer_fc1_baked.f32.bin"):
            checkpoint_slices.append(slice_record(ACCEPTED / side / name,
                                                  side + "/" + name,
                                                  row_offset, 4096))
    for i in (0, 1):
        if checkpoint_slices[i]["sha256"] != checkpoint_slices[i + 2]["sha256"]:
            raise ValueError("frozen oracle/DUT selected row mismatch")

    cpu_sources = (MODULE / "source/q8_joint_tm4tn8.cpp",
                   HERE / "test_q8_full_scorer.cpp")
    cpu_scan = {source.name: cpu_literal_includes(source) for source in cpu_sources}
    cpu_closure = set().union(*cpu_scan.values())
    prior_d = (PRIOR_CSIM_D / "q8_joint_tm4tn8.d",
               PRIOR_CSIM_D / "test_q8_joint.d")
    prior_cpu_headers = set().union(*(prior_csim_dependencies(p) for p in prior_d))
    if not prior_cpu_headers <= cpu_closure:
        raise ValueError("prior CSim vendor/project headers missing from CPU closure: " +
                         str(sorted(prior_cpu_headers - cpu_closure)))
    hls_closure = json.loads(HLS_DEPENDENCY_CLOSURE.read_text())
    if len(hls_closure["records"]) != 241:
        raise ValueError("prior HLS preprocessed dependency record count")
    for old in hls_closure["records"]:
        path = Path(old["path"])
        if not path.is_file() or path.stat().st_size != old["bytes"] or sha(path) != old["sha256"]:
            raise ValueError(f"prior HLS preprocessed dependency changed: {path}")

    local = [ISOLATED / "source" / name for name in (
        "design.md", "results.md", "observer_binding.json", "first_pilot_budget.json")]
    local += [ISOLATED / "rtl/README.md"]
    local += [HERE / name for name in (
        "generate_top.py", "q8_full_scorer_top.sv",
        "q8_full_scorer_control.svh", "q8_full_scorer_observer.svh",
        "materialize_scorer_pilot.py", "test_q8_full_scorer.cpp",
        "build_cpu_leaf.sh", "run_cpu_leaf.sh", "build_static.sh",
        "prepare_runtime.py", "run_pilot.sh", "check_pilot.py",
        "make_source_packet.py", "verify_source_binding.py")]
    adapters = [ACT_TB / name for name in (
        "q8_static_axi_stall.sv", "q8_axi_monitor.sv", "q8_axi_port.sv",
        "q8_axi_lite_master.sv")]
    hls = [MODULE / "source" / name for name in (
        "q8_joint_tm4tn8.cpp", "q8_joint_tm4tn8.h", "q8_joint_abi.h")]
    models = [MODEL / name for name in (
        "manifest.json", "laya_model_layout_generated.h",
        "numeric_preimage.txt", "layout_preimage.json", "build_preimage.json")]
    models += [MODEL / item["file"] for item in model["bo"].values()]
    models.append(gguf)
    reports = [ACCEPTED / name for name in (
        "full_final_gate_report.json", "compare/full_forward_dut_compare_report.json",
        "oracle/full_forward_oracle_report.json")]
    checkpoints = [ACCEPTED / side / name for side in (
        "oracle/B2_S128", "dut/dut/B2_S128") for name in (
        "marker_norm.f32.bin", "scorer_fc1_baked.f32.bin")]
    gates = [REVIEW / name for name in (
        "reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json",
        "reviewer_q8_full_dimensions_observer_numeric_boundary_preparation_addendum.json",
        "reviewer_q8_act_static_v1_full_functional_acceptance.json",
        "reviewer_q8_full_scorer_static_schedule_precheck.json")]
    schedule = [REPORT / name for name in (
        "q8_joint_tm4tn8_csynth.rpt",
        "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_583_21_VITIS_LOOP_584_22_VITIS_LOOP_587_23_csynth.rpt",
        "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_602_27_csynth.rpt",
        "q8_joint_tm4tn8_Pipeline_VITIS_LOOP_634_29_csynth.rpt")]
    libraries = []
    for rel in ("ip/floating_point_v7_1_21", "vhdl/unisim",
                "verilog/unisims_ver", "verilog/secureip", "ip/xpm", "vhdl/ieee"):
        library = VIVADO / "data/xsim" / rel
        if not library.is_dir():
            raise FileNotFoundError(library)
        libraries += [p for p in library.rglob("*") if p.is_file()]
    libraries += [VIVADO / "data/xsim/xsim.ini",
                  VIVADO / "doc/eng/man/xsim"]
    cpu_dependencies = [Path("/usr/bin/g++"),
                        Path("/lib/x86_64-linux-gnu/libm.so.6"),
                        Path("/lib/x86_64-linux-gnu/libstdc++.so.6"),
                        Path("/lib/x86_64-linux-gnu/libgcc_s.so.1"),
                        Path("/lib/x86_64-linux-gnu/libc.so.6"),
                        Path("/lib64/ld-linux-x86-64.so.2")]
    files = sorted(set(verilog + dat + wrappers + local + adapters + hls +
                       models + reports + checkpoints + gates + schedule +
                       libraries + cpu_dependencies + list(cpu_closure) + list(prior_d) +
                       [HLS_DEPENDENCY_CLOSURE, ENDPOINT, G16, G4,
                       BASE / "tests/full_reference.py"]))
    immutable = [record(p) for p in files]
    indexed = {r["path"]: r for r in immutable}
    for key in ("w_q0", "w_q1", "w_scale", "aux", "embedding"):
        entry = model["bo"][key]
        actual = indexed[str((MODEL / entry["file"]).resolve())]
        if (actual["bytes"], actual["sha256"]) != (entry["size"], entry["sha256"]):
            raise ValueError(f"BO manifest mismatch {key}")
    if (indexed[str(gguf.resolve())]["bytes"],
        indexed[str(gguf.resolve())]["sha256"]) != (
        model["source_model"]["size"], model["source_model"]["sha256"]):
        raise ValueError("complete GGUF identity")
    release = json.loads(gates[0].read_text())
    for pair in release["independently_hashed_checkpoint_pairs"]:
        if pair["name"] not in ("marker_norm", "scorer_fc1_baked"):
            continue
        for side in ("oracle", "dut"):
            frozen = pair[side]
            actual = indexed[str(Path(frozen["path"]).resolve())]
            if (actual["bytes"], actual["sha256"]) != (
                frozen["bytes"], frozen["sha256"]):
                raise ValueError(f"accepted checkpoint identity {pair['name']}/{side}")
    build = ISOLATED / "runs/static_build_v1"
    fixture = ISOLATED / "runs/first_pilot_v1/fixture"
    cpu = ISOLATED / "runs/first_pilot_v1/cpu"
    runtime = ISOLATED / "runs/first_pilot_v1/runtime"
    audit = ISOLATED / "runs/first_pilot_v1/log_audit.json"
    verifier = ["python3", str(HERE / "verify_source_binding.py"), str(OUT)]
    phase = ISOLATED / "runs/first_pilot_v1"
    fixture_post = phase / "fixture_binding_post.json"
    cpu_build_post = phase / "cpu_build_binding_post.json"
    static_post = phase / "static_binding_post.json"
    runtime_prepare_post = phase / "runtime_prepare_binding_post.json"
    snapshot = build / "xsim.dir"
    fixture_bind = ["--fixture", str(fixture),
                    "--expected-fixture-report", str(fixture_post)]
    static_bind = fixture_bind + ["--snapshot", str(snapshot),
                                  "--expected-snapshot-report", str(static_post)]
    prepared_bind = static_bind + ["--prepared", str(runtime),
                                    "--expected-prepared-report", str(runtime_prepare_post)]
    bindings = [
        {"stage": "materialize_fixture", "pre": verifier + ["--out", str(phase / "fixture_binding_pre.json")],
         "post": verifier + ["--fixture", str(fixture), "--out", str(fixture_post)]},
        {"stage": "build_cpu_leaf", "pre": verifier + fixture_bind + ["--out", str(phase / "cpu_build_binding_pre.json")],
         "post": verifier + fixture_bind + ["--cpu-binary", str(cpu / "test_q8_full_scorer"),
                                           "--out", str(cpu_build_post)]},
        {"stage": "run_cpu_leaf", "pre": verifier + fixture_bind + ["--cpu-binary", str(cpu / "test_q8_full_scorer"),
                                                 "--expected-cpu-report", str(cpu_build_post),
                                                 "--out", str(phase / "cpu_run_binding_pre.json")],
         "post": verifier + fixture_bind + ["--cpu-binary", str(cpu / "test_q8_full_scorer"),
                                            "--expected-cpu-report", str(cpu_build_post),
                                            "--out", str(phase / "cpu_run_binding_post.json")]},
        {"stage": "static_compile", "pre": verifier + fixture_bind + ["--out", str(phase / "static_binding_pre.json")],
         "post": verifier + fixture_bind + ["--snapshot", str(snapshot), "--out", str(static_post)]},
        {"stage": "prepare_runtime", "pre": verifier + static_bind + ["--out", str(phase / "runtime_prepare_binding_pre.json")],
         "post": verifier + static_bind + ["--prepared", str(runtime),
                                            "--out", str(runtime_prepare_post)]},
        {"stage": "rtl_first_three_commands", "pre": verifier + prepared_bind + ["--out", str(phase / "rtl_binding_pre.json")],
         "post": verifier + prepared_bind + ["--require-dat-links",
                                              "--archive-runtime-artifacts", str(phase / "snapshot_runtime_artifacts"),
                                              "--out", str(phase / "rtl_binding_post.json")]},
    ]
    packet = {
        "schema": "q8_full_scorer_first_pilot_source_packet_v3",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "status": "SOURCE_ONLY_UNCOMPILED_NO_FIXTURE_OR_CPU_OR_EDA_EXECUTED",
        "counts": {"generated_verilog": 230, "generated_dat": 108,
                   "fp_sim_vhdl": 7, "physical_pages": 341,
                   "immutable_files": len(immutable)},
        "immutable_files": immutable,
        "generated_dat_paths": [str(p.resolve()) for p in dat],
        "gguf_slices": gguf_slices,
        "checkpoint_slices": checkpoint_slices,
        "model_tags": model["tags"],
        "physical_weight": weight,
        "source_gate": str(gates[0]),
        "supersedes_source_preview": record(ISOLATED / "source_binding_v1/source_packet.json"),
        "supersedes_source_packet_v2": record(ISOLATED / "source_binding_v2/source_packet.json"),
        "cpu_dependency_contract": {
            "method": "Read-only recursive literal-include scan plus existing CSim .d and HLS preprocessor evidence; future two-TU -MMD files must name only immutable inputs",
            "include_roots": [str(p.resolve()) for p in CPU_INCLUDE_ROOTS],
            "literal_include_closure": {name: [str(p) for p in paths]
                                        for name, paths in cpu_scan.items()},
            "prior_csim_dependency_files": [record(p) for p in prior_d],
            "prior_csim_non_system_paths_mapped_to_v3": [str(p) for p in sorted(prior_cpu_headers)],
            "prior_hls_preprocessed_dependency_closure": record(HLS_DEPENDENCY_CLOSURE),
            "future_dependency_files": ["q8_joint_tm4tn8.d", "test_q8_full_scorer.d"],
        },
        "build_endpoint": str(ENDPOINT),
        "exact_commands_after_new_sequential_gate": [
            {"stage": "materialize_fixture", "argv": ["python3", str(HERE / "materialize_scorer_pilot.py"), str(fixture)]},
            {"stage": "build_cpu_leaf", "argv": [str(HERE / "build_cpu_leaf.sh"), str(cpu)]},
            {"stage": "run_cpu_leaf", "argv": [str(HERE / "run_cpu_leaf.sh"), str(cpu), str(fixture)]},
            {"stage": "static_compile", "argv": [str(HERE / "build_static.sh"), str(build)]},
            {"stage": "prepare_runtime", "argv": ["python3", str(HERE / "prepare_runtime.py"), str(fixture), str(build), str(runtime)]},
            {"stage": "rtl_first_three_commands", "argv": [str(HERE / "run_pilot.sh"), str(build), str(runtime)]},
            {"stage": "offline_log_audit", "argv": ["python3", str(HERE / "check_pilot.py"), str(runtime), str(audit)]}],
        "binding_check_argv": verifier,
        "planned_binding_commands": bindings,
        "guarded_stage_commands": [
            {"stage": "materialize_fixture", "cwd": str(ISOLATED),
             "argv": ["python3", str(G4), "--out", str(ISOLATED / "runs/first_pilot_v1/fixture_guard"),
                      "--cwd", str(ISOLATED), "--rss-gib", "4", "--timeout-seconds", "900",
                      "--", "python3", str(HERE / "materialize_scorer_pilot.py"), str(fixture)]},
            {"stage": "build_cpu_leaf", "cwd": str(ISOLATED),
             "argv": ["python3", str(G4), "--out", str(ISOLATED / "runs/first_pilot_v1/cpu_build_guard"),
                      "--cwd", str(ISOLATED), "--rss-gib", "4", "--timeout-seconds", "900",
                      "--", str(HERE / "build_cpu_leaf.sh"), str(cpu)]},
            {"stage": "run_cpu_leaf", "cwd": str(ISOLATED),
             "argv": ["python3", str(G4), "--out", str(ISOLATED / "runs/first_pilot_v1/cpu_run_guard"),
                      "--cwd", str(ISOLATED), "--rss-gib", "4", "--timeout-seconds", "900",
                      "--", str(HERE / "run_cpu_leaf.sh"), str(cpu), str(fixture)]},
            {"stage": "static_compile", "cwd": str(build),
             "argv": ["python3", str(G16), "--out", str(ISOLATED / "runs/first_pilot_v1/static_guard"),
                      "--cwd", str(build), "--rss-gib", "16", "--timeout-seconds", "900",
                      "--", str(HERE / "build_static.sh"), str(build)]},
            {"stage": "prepare_runtime", "cwd": str(ISOLATED),
             "argv": ["python3", str(G4), "--out", str(ISOLATED / "runs/first_pilot_v1/runtime_prepare_guard"),
                      "--cwd", str(ISOLATED), "--rss-gib", "4", "--timeout-seconds", "900",
                      "--", "python3", str(HERE / "prepare_runtime.py"), str(fixture), str(build), str(runtime)]},
            {"stage": "rtl_first_three_commands", "cwd": str(runtime),
             "argv": ["python3", str(G16), "--out", str(ISOLATED / "runs/first_pilot_v1/rtl_guard"),
                      "--cwd", str(runtime), "--rss-gib", "16", "--timeout-seconds", "36000",
                      "--", str(HERE / "run_pilot.sh"), str(build), str(runtime)]}],
        "compile_flags": ["-std=c++17", "-O2", "-ffp-contract=off", "-fno-fast-math",
                          "-MMD", "-MF", "-MT", "-c", "-lm"],
        "cpu_translation_units": [
            {"source": str(MODULE / "source/q8_joint_tm4tn8.cpp"),
             "object": "q8_joint_tm4tn8.o", "dependencies": "q8_joint_tm4tn8.d"},
            {"source": str(HERE / "test_q8_full_scorer.cpp"),
             "object": "test_q8_full_scorer.o", "dependencies": "test_q8_full_scorer.d"}],
        "xsim_snapshot_lookup": "runtime/xsim.dir is an absolute symlink to static_build_v1/xsim.dir; 108 absolute DAT symlinks are installed by run_pilot.sh",
        "snapshot_runtime_mutable_allowlist": [
            "q8_full_scorer/xsim_script.tcl",
            "q8_full_scorer/xsimSettings.ini",
            "q8_full_scorer/xsimkernel.log",
            "q8_full_scorer/xsimcrash.log"],
        "stage_contract": "Run each stage's exact pre binding command, guarded command, then post binding command even after a tool failure, preserving partial evidence; stop before any next stage on binding, tool, numerical, clock/RSS or wall failure. The materializer creates a fresh fixture; CPU and static build directories must exist fresh; runtime preparation creates a fresh runtime directory. Seal generated fixture, binary, snapshot and raw dumps before subsequent use. No ACT rerun or automatic later-family modes.",
        "resource_policy": "One Laya heavy tool, at most four CPUs, nice19, idle I/O, 0.2s owned RSS samples and MemAvailable strictly >192GiB. See first_pilot_budget.json for finite source estimates and watchdogs.",
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    if OUT.exists():
        raise FileExistsError("fresh source packet required; remove only by explicit source revision")
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"Q8_SCORER_SOURCE_PACKET_PASS files={len(immutable)} path={OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
