#!/usr/bin/env python3
"""Post-build Q8S2 preparation evidence on a byte-exact memory endpoint."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys
import time
import argparse

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "results/compute_throughput_optimization_20261010/tools"))
from t3_offline_session import Candidate, MemoryEndpoint, PROFILE, State, StaticModelSession


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for part in iter(lambda: stream.read(1 << 20), b""):
            h.update(part)
    return h.hexdigest()


def save(path: Path, data: dict) -> str:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    return sha(path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(exist_ok=False)
    package = args.package.resolve()
    manifest = json.loads((package / "manifest.json").read_bytes())
    build_sha = sha(package / "build_preimage.json")
    assert manifest["tags"]["build"] == build_sha[:32]
    hls_path = ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/q8_tm1tn8_session_dma_v2.cpp"
    hls_sha = sha(hls_path)
    preimage = json.loads((package / "build_preimage.json").read_bytes())
    assert {entry["path"]: entry["sha256"] for entry in preimage["sources"]}[
        hls_path.relative_to(ROOT).as_posix()] == hls_sha
    candidate = Candidate(tags=manifest["tags"], kernel_sha256=hls_sha)
    session = StaticModelSession(package, candidate,
                                 device="offline-memory-device-0",
                                 context="offline-memory-context-q8s2",
                                 endpoint=MemoryEndpoint())
    started = time.perf_counter()
    first = session.prepare(out / "validated_model_first.json")
    assert session.state == State.PACKAGE_CHECKED
    session.upload()
    assert session.state == State.UPLOADED
    session.verify_readback()
    assert session.state == State.READBACK_VERIFIED
    first_active = session.activate()
    first_active_sha = save(out / "active_first.json", first_active)
    assert session.state == State.ACTIVE and session.scale_scan_count == 1
    assert session.record["q8_matrix_count"] == 122
    assert session.record["scale_halves_checked"] == 11_542_592
    args = {"profile": PROFILE, "generation": session.generation,
            "candidate": candidate, "record_sha256": session.record_sha256,
            "allocations": session.allocations.copy(), "weight_key": (12, 255),
            "K": 256, "N": 2, "cache_epoch": session.cache_epoch}
    assert session.authorize_load(**args)
    assert session.warm_reuse()["scale_scan_count"] == 1
    old_generation = session.generation
    old_allocations = session.allocations.copy()
    session.reset()
    assert session.state == State.INVALID
    assert not session.authorize_load(**args)
    second = session.prepare(out / "validated_model_after_reset.json")
    session.upload()
    session.verify_readback()
    second_active = session.activate()
    second_active_sha = save(out / "active_after_reset.json", second_active)
    assert session.generation > old_generation
    assert session.allocations != old_allocations
    assert session.scale_scan_count == 2
    args.update(generation=session.generation,
                record_sha256=session.record_sha256,
                allocations=session.allocations.copy())
    assert session.authorize_load(**args)
    report = {
        "schema": "laya-q8s2-offline-memory-lifecycle-v1",
        "status": "PASS",
        "scope": "actual Q8S2 package CPU scan and offline memory upload/readback only",
        "device_register": "NOT_RUN",
        "xrt_pcie_hbm_readback": "NOT_MEASURED",
        "package": str(package),
        "manifest_sha256": sha(package / "manifest.json"),
        "candidate_build_preimage_sha256": build_sha,
        "kernel_hls_source_sha256": hls_sha,
        "first": first, "second": second,
        "first_active_sha256": first_active_sha,
        "second_active_sha256": second_active_sha,
        "first_record_sha256": sha(out / "validated_model_first.json"),
        "second_record_sha256": sha(out / "validated_model_after_reset.json"),
        "scans": session.scale_scan_count,
        "elapsed_seconds": time.perf_counter() - started,
    }
    digest = save(out / "report.json", report)
    print(json.dumps({"status": "PASS", "report_sha256": digest,
                      "scans": report["scans"],
                      "elapsed_seconds": report["elapsed_seconds"]}))


if __name__ == "__main__":
    main()
