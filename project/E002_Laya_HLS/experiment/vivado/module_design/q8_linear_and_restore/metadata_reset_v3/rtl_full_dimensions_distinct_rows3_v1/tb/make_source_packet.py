#!/usr/bin/env python3
"""Bind the dormant distinct-valid-row Scorer source and frozen lineage."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import importlib.metadata
import importlib.util
import json
from pathlib import Path
import sys

import request_binding as binding

HERE = Path(__file__).resolve().parent
ISOLATED = HERE.parent
MODULE = ISOLATED.parent
BASE = binding.ROOT
MODEL = BASE / "build/model-attention-rtl-repair-20261008"
ACCEPTED = BASE / "results/engineering_p2/full_cpu_final_20261007"
REVIEW = BASE / "results/attention_rtl_repair_20261008"
RTL = MODULE / "runs/csynth_local_v1/work/hls/syn/verilog"
IP = MODULE / "runs/csynth_local_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
ACT_TB = MODULE / "rtl_act_static_v1/tb"
V6 = MODULE / "rtl_full_dimensions_v1/source_binding_v6/source_packet.json"
PRIOR = MODULE / "rtl_full_dimensions_rows3_v1"
PRIOR_PACKET = PRIOR / "source/source_packet.json"
PRIOR_CHECK = PRIOR / "source/source_check.json"
STATIC = ISOLATED / "source/static_contract.json"
GATE = binding.GATE
OUT = ISOLATED / "source/source_packet.json"

V6_SHA = "872b13e1efa71cff1aee87873b918d4e595d8046caf6ec4da9cc9917a3a91611"
PRIOR_PACKET_SHA = "595c5f5ecc5b60ce14e9edcf9c25f8ad1a047aaa21d0a3eb8f5ea438c2812a78"
PRIOR_CHECK_SHA = "7b6597acec7cf61c8e07067de1a30fb24cf4cff8257817e867e16d991ecbe3f1"
STATIC_SHA = "5c01f2749b157c17b84d1637cae1382c8cb0529b1b925b8cd3f43e563f92dac8"
DESIGN_SHA = "76d7a3c525f0208c387f444776a81e4b6dc56beec99511f12efb5c97389e7a48"


def record(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "mode": oct(path.stat().st_mode & 0o777), "sha256": h.hexdigest()}


def exact(path: Path, digest: str) -> dict:
    item = record(path)
    if item["sha256"] != digest:
        raise ValueError(f"frozen identity drift: {path}")
    return item


def same_record(path: Path, expected: dict) -> dict:
    item = record(path)
    if any(item[key] != expected[key] for key in ("path", "bytes", "sha256")):
        raise ValueError(f"bound identity drift: {path}")
    if "mode" in expected and item["mode"] != expected["mode"]:
        raise ValueError(f"bound mode drift: {path}")
    return item


def numpy_oracle_dependencies() -> tuple[str, list[dict]]:
    spec = importlib.util.find_spec("numpy")
    if spec is None or spec.origin is None:
        raise ValueError("NumPy installation missing")
    package = Path(spec.origin).parent
    dist = importlib.metadata.distribution("numpy")
    core = list(package.glob("core/_multiarray_umath*.so"))
    if len(core) != 1:
        raise ValueError("NumPy core binary identity ambiguous")
    dist_info = Path(dist._path)
    if (dist_info / "RECORD").exists():
        raise ValueError("expected Debian NumPy installation without wheel RECORD")
    debian_list = Path("/var/lib/dpkg/info/python3-numpy.list")
    debian_md5 = Path("/var/lib/dpkg/info/python3-numpy.md5sums")
    selected = [package / "__init__.py", package / "core/__init__.py",
                core[0], package / "core/numeric.py",
                package / "core/fromnumeric.py", package / "core/_methods.py",
                package / "core/multiarray.py", package / "core/umath.py"]
    installed = set(debian_list.read_text().splitlines())
    checksums = {line.split("  ", 1)[1] for line in debian_md5.read_text().splitlines()}
    for path in selected:
        if str(path) not in installed or str(path).lstrip("/") not in checksums:
            raise ValueError(f"selected NumPy oracle dependency lacks Debian manifest entry: {path}")
    dependencies = [Path(sys.executable).resolve(), package / "__init__.py",
                    package / "core/__init__.py", core[0],
                    package / "core/numeric.py", package / "core/fromnumeric.py",
                    package / "core/_methods.py", package / "core/multiarray.py",
                    package / "core/umath.py", dist_info / "METADATA",
                    dist_info / "WHEEL", dist_info / "INSTALLER",
                    debian_list, debian_md5,
                    Path("/lib/x86_64-linux-gnu/libm.so.6").resolve(),
                    BASE / "tests/full_reference.py"]
    return dist.version, [record(path) for path in dependencies]


def construct(created_utc: str) -> dict:
    gate = binding.load_gate()
    gate_record = exact(GATE, binding.GATE_SHA256)
    v6_record = exact(V6, V6_SHA)
    prior_packet_record = exact(PRIOR_PACKET, PRIOR_PACKET_SHA)
    prior_check_record = exact(PRIOR_CHECK, PRIOR_CHECK_SHA)
    static_record = exact(STATIC, STATIC_SHA)
    exact(ISOLATED / "source/design.md", DESIGN_SHA)
    inherited = json.loads(V6.read_text())
    old_packet = json.loads(PRIOR_PACKET.read_text())
    static = json.loads(STATIC.read_text())
    model = json.loads((MODEL / "manifest.json").read_text())
    old_immutable = {item["path"]: item for item in inherited["immutable_files"]}
    if (inherited["counts"]["physical_pages"] != 341 or
        old_packet["inherited_single_row_packet"]["sha256"] != V6_SHA or
        old_packet["counts"] != {"generated_verilog": 230, "generated_dat": 108,
                                 "fp_sim_vhdl": 7, "local_source": 18,
                                 "imported_inputs": 20, "physical_pages": 341} or
        static["schema"] != "q8_full_scorer_distinct_rows3_static_contract_v1" or
        static["authority"]["sha256"] != binding.GATE_SHA256 or
        static["inherited_v6"]["sha256"] != V6_SHA or
        static["inherited_rows3_static"]["sha256"] !=
            old_packet["static_contract"]["sha256"] or
        static["shape"] != {"B": 2, "S": 128, "batch": 1, "row0": 0,
                            "rows": 3, "K": 1024, "N": 1024, "G": 32,
                            "T": 128} or
        static["checkpoint_source_interval"] != [65536, 77824] or
        static["page_count"] != 341 or
        static["work_per_run"]["logical_MAC"] != 3145728 or
        static["work_per_run"]["issued_and_retired_groups"] != 4096 or
        static["trace"]["observed_valid_bytes"] != 5312):
        raise ValueError("distinct valid-row static contract drift")
    request = binding.request_identity(gate, model["tags"])
    if request != static["frozen_request"]:
        raise ValueError("frozen request/static contract drift")
    expected_rows = {row["name"]: row["row_sha256"] for row in gate["checkpoint_slices"]}
    if static["selected_row_sha256"] != expected_rows:
        raise ValueError("three distinct checkpoint row identities changed")

    verilog = sorted(RTL.glob("*.v"))
    dat = sorted(RTL.glob("*.dat"))
    wrappers = sorted(IP.glob("*/sim/*_ip.vhd"))
    if (len(verilog), len(dat), len(wrappers)) != (230, 108, 7):
        raise ValueError("inherited generated closure count")
    generated = [record(path) for path in verilog + dat + wrappers]
    old_generated = {item["path"]: item for item in old_packet["generated_closure"]}
    if len(old_generated) != len(generated):
        raise ValueError("old generated closure duplicate/missing path")
    for item in generated:
        if old_generated.get(item["path"]) != item or old_immutable.get(item["path"]) != item:
            raise ValueError(f"generated closure differs from accepted V6/rows3: {item['path']}")

    local = [ISOLATED / "source" / name for name in
             ("design.md", "results.md", "static_contract.json", "observer_binding.json")]
    local.append(ISOLATED / "rtl/README.md")
    local += sorted(path for path in HERE.iterdir() if path.is_file() and
                    path.suffix in {".py", ".sh", ".sv", ".svh", ".cpp"})
    if len(local) != 19:
        raise ValueError(f"local source count drift: {len(local)}")
    local_records = [record(path) for path in local]
    if (record(HERE / "q8_scorer_distinct_rows3_observer.svh")["sha256"] !=
        record(PRIOR / "tb/q8_scorer_rows3_observer.svh")["sha256"]):
        raise ValueError("reviewed passive observer changed")
    old_top = (PRIOR / "tb/q8_scorer_rows3_top.sv").read_bytes()
    expected_top = old_top.replace(b"rows3", b"distinct_rows3").replace(
        b"ROWS3", b"DISTINCT_ROWS3")
    if (ISOLATED / "tb/q8_scorer_distinct_rows3_top.sv").read_bytes() != expected_top:
        raise ValueError("top changed beyond unique module/include names")

    old_imported = old_packet["imported_inputs"]
    imported = [same_record(Path(item["path"]), item) for item in old_imported]
    for item in imported:
        if old_immutable.get(item["path"]) != item:
            raise ValueError(f"imported input differs from accepted V6: {item['path']}")
    old_preimages = [same_record(Path(item["path"]), item)
                     for item in old_packet["local_source"]]
    if len(old_preimages) != 18:
        raise ValueError("prior rows3 source preimage count")
    extra = [gate["frozen_request"], gate["request_run_report"],
             gate["oracle_report"], gate["accepted_comparator"],
             gate["accepted_single_row"], gate["basis_rows3_source_review"]]
    additional = [same_record(Path(item["path"]), item) for item in extra]
    prior_gate = same_record(Path(gate["prior_rows3_packet"]["path"]),
                             gate["prior_rows3_packet"])
    if prior_gate != prior_packet_record:
        raise ValueError("prior rows3 gate packet mismatch")
    for name in ("w_q0", "w_q1", "w_scale", "aux"):
        entry = model["bo"][name]
        same_record(MODEL / entry["file"],
                    {"path": str((MODEL / entry["file"]).resolve()),
                     "bytes": entry["size"], "sha256": entry["sha256"]})
    gguf = Path(model["source_model"]["path"])
    same_record(gguf, {"path": str(gguf.resolve()),
                       "bytes": model["source_model"]["size"],
                       "sha256": model["source_model"]["sha256"]})
    for item in static["checkpoints"]:
        same_record(Path(item["source"]["path"]), item["source"])
    library_records = [same_record(Path(item["path"]), item)
                       for item in inherited["immutable_files"]
                       if "/data/xsim/ip/floating_point_v7_1_21/" in item["path"]]
    if len(library_records) != 3:
        raise ValueError("installed floating-point simulation library closure")
    numpy_version, oracle_deps = numpy_oracle_dependencies()
    return {
        "schema": "q8_full_scorer_distinct_rows3_source_packet_v1",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_NUMERICAL_OR_CPU_OR_EDA_EXECUTION_RELEASE",
        "source_preparation_authority": gate_record,
        "inherited_single_row_packet": v6_record,
        "inherited_rows3_packet": prior_packet_record,
        "inherited_rows3_source_check": prior_check_record,
        "inherited_rows3_local_preimages": old_preimages,
        "static_contract": static_record,
        "counts": {"generated_verilog": 230, "generated_dat": 108,
                   "fp_sim_vhdl": 7, "local_source": len(local_records),
                   "imported_inputs": len(imported),
                   "additional_evidence": len(additional),
                   "physical_pages": 341},
        "generated_closure": generated,
        "local_source": local_records,
        "imported_inputs": imported,
        "additional_evidence": additional,
        "installed_fp_simulation_libraries": library_records,
        "independent_oracle_dependencies": oracle_deps,
        "numpy_version": numpy_version,
        "frozen_request_identity": request,
        "build_tag_provenance": {
            "frozen_full_cpu_request_checkpoint_build": request["request_tags"]["build"],
            "current_q8_descriptor_package_build": model["tags"]["build"],
            "shared_model_numeric_layout_tags":
                {key: model["tags"][key] for key in ("model", "numeric", "layout")},
            "frozen_request_role": "Source identity and marker validation only; not passed into the Q8 DUT.",
            "current_package_role": "Descriptor tags, full Q8 BOs and actual generated RTL.",
        },
        "checkpoint_source_interval": [65536, 77824],
        "selected_row_sha256": expected_rows,
        "shape": static["shape"], "trace": static["trace"],
        "work_per_run": static["work_per_run"],
        "planned_sequence": ["load_w", "run_trace_on", "run_trace_off"],
        "execution_limit": "Source review only; no fixture/oracle materialization, CPU compile/run, Vivado/XSim or synthesis.",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--create", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.create:
        if OUT.exists():
            raise FileExistsError("source packet already exists")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    else:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise ValueError("distinct valid-row source packet binding drift")
    item = record(OUT)
    count = sum(packet["counts"][key] for key in
                ("generated_verilog", "generated_dat", "fp_sim_vhdl",
                 "local_source", "imported_inputs", "additional_evidence"))
    print(f"Q8_SCORER_DISTINCT_ROWS3_SOURCE_PACKET_PASS files={count} sha256={item['sha256']}")


if __name__ == "__main__":
    main()
