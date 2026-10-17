#!/usr/bin/env python3
"""Build WI0 read-only-reference files from this project's frozen Wi fixture."""
import hashlib
import json
from pathlib import Path
import shutil
import struct
import subprocess
import sys


EXPERIMENT = Path(__file__).resolve().parents[5]
PROJECT = EXPERIMENT.parents[2]
HIST = (PROJECT / "project/E002_Laya_HLS/experiment/results"
        "/compute_throughput_optimization_20261010/attempts")
SOURCE = HIST / "t2_widown_av_fixtures_01/work/fixtures"
WEIGHT = HIST / "t4_dual_w_fixture_01/work"
PACKER = (EXPERIMENT / "vivado/module_design/q8_linear_and_restore/"
          "tm1tn8_gs32_512/tb/make_tm4_real_streams.py")


def identity(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def checked(path: Path, record: dict) -> bytes:
    raw = path.read_bytes()
    if len(raw) != record["bytes"] or hashlib.sha256(raw).hexdigest() != record["sha256"]:
        raise RuntimeError(f"frozen independent product changed: {path}")
    return raw


def mem_words(raw: bytes, width: int) -> str:
    if len(raw) % width:
        raise RuntimeError("unaligned independent fixture")
    return "".join(f"{int.from_bytes(raw[i:i+width], 'little'):0{width*2}x}\n"
                   for i in range(0, len(raw), width))


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: make_wi_resident_fixture.py NEW_ATTEMPT_WORK")
    work = Path(sys.argv[1]).resolve()
    if work.exists():
        raise RuntimeError(f"refusing existing WI0 work directory: {work}")
    if not work.is_relative_to(PROJECT / "project/E005_full_request_performance/experiment_results/runs/R001"):
        raise RuntimeError("WI0 work must be under E005/R001")
    manifest = json.loads((SOURCE / "manifest.json").read_text())
    if manifest["schema"] != "t2_widown_v4_b1_four_row_fixtures_v1" or manifest["session"] != {
            "request_id": 3, "generation": 1, "B": 1, "S": 128}:
        raise RuntimeError("unexpected independent Wi fixture identity")
    selected = [x for x in manifest["cases"] if x["name"] == "wi_rows4"]
    if len(selected) != 1:
        raise RuntimeError("missing unique Wi case")
    case = selected[0]
    if (case["rows"], case["K"], case["N"]) != (4, 1024, 5248):
        raise RuntimeError("unexpected Wi geometry")
    products = case["products"]
    sources = {}
    localized = json.loads(json.dumps(manifest))
    local_case = next(x for x in localized["cases"] if x["name"] == "wi_rows4")
    for name, record in products.items():
        source = SOURCE / Path(record["path"]).name
        sources[name] = checked(source, record)
        local_case["products"][name]["path"] = str(source)
    work.mkdir(parents=True)
    fixture_root = work / "fixtures"
    a, w = fixture_root / "a", fixture_root / "w"
    a.mkdir(parents=True)
    w.mkdir(parents=True)
    (a / "q.mem").write_text(mem_words(sources["a8_q"], 32))
    (a / "scale.mem").write_text(mem_words(sources["a8_scale"], 2))
    (a / "output.mem").write_text(mem_words(sources["output_f32"], 4))
    for stem in ("model_identity", "expected_aux_header", "aux_header"):
        shutil.copyfile(WEIGHT / f"{stem}.hex", w / f"{stem}.hex")
    shutil.copyfile(WEIGHT / "wi_config.hex", w / "wi_config.hex")
    for stem, source_name in (("q0", "w_q0"), ("q1", "w_q1"), ("scale", "w_scale")):
        path = WEIGHT / f"wi_{stem}.hex"
        lines = path.read_text().splitlines()
        represented = b"".join(bytes.fromhex(line)[::-1] for line in lines)
        if represented != sources[source_name]:
            raise RuntimeError(f"Wi physical W fixture differs from independent {source_name}")
        shutil.copyfile(path, w / path.name)
    localized_path = fixture_root / "source_manifest_local.json"
    localized_path.write_text(json.dumps(localized, indent=2) + "\n")
    streams = fixture_root / "streams"
    subprocess.run([sys.executable, str(PACKER), str(localized_path), "wi_rows4",
                    str(streams)], check=True)
    record = {"schema": "wi_resident_fixture_v1",
              "source_manifest": identity(SOURCE / "manifest.json"),
              "source_products": {name: identity(SOURCE / Path(item["path"]).name)
                                  for name, item in products.items()},
              "local_manifest": identity(localized_path),
              "packer": identity(PACKER),
              "generated": {str(path.relative_to(fixture_root)): identity(path)
                            for path in sorted(fixture_root.rglob("*")) if path.is_file()}}
    (fixture_root / "wi_fixture_identity.json").write_text(json.dumps(record, indent=2) + "\n")
    print("WI_RESIDENT_FIXTURE_PREPARED rows=4 K=1024 N=5248 q_words=128 output_words=20992")


if __name__ == "__main__":
    main()
