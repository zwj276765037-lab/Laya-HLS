#!/usr/bin/env python3
"""Verify the frozen Controller F1b regression attempt and emit its receipt."""

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[6]
ATTEMPT = PROJECT / (
    "project/E003_production_chain_closure/experiment_results/runs/R003/"
    "portal_controller_31")
OUTPUT = Path(__file__).with_name("verification.json")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_record(record: dict, mismatches: list[dict]) -> bool:
    path = Path(record["path"])
    actual = digest(path) if path.is_file() else None
    if actual != record["sha256"]:
        mismatches.append({"path": str(path), "declared": record["sha256"],
                           "actual": actual})
        return False
    return True


def referenced_records(value):
    if isinstance(value, dict):
        if set(("path", "sha256")).issubset(value):
            yield value
        for child in value.values():
            yield from referenced_records(child)
    elif isinstance(value, list):
        for child in value:
            yield from referenced_records(child)


manifest_path = ATTEMPT / "input_manifest.json"
receipt_path = ATTEMPT / "receipt.json"
manifest = json.loads(manifest_path.read_text())
receipt = json.loads(receipt_path.read_text())
mismatches = []

pairs = manifest["files"]
current_matches = 0
frozen_matches = 0
pair_matches = 0
for pair in pairs:
    current_ok = check_record(pair["original"], mismatches)
    frozen_ok = check_record(pair["frozen"], mismatches)
    current_matches += int(current_ok)
    frozen_matches += int(frozen_ok)
    pair_ok = pair["original"]["sha256"] == pair["frozen"]["sha256"]
    pair_matches += int(pair_ok)
    if not pair_ok:
        mismatches.append({"pair": [pair["original"]["path"],
                                    pair["frozen"]["path"]],
                           "reason": "declared pair hashes differ"})

references = list(referenced_records(manifest)) + list(referenced_records(receipt))
reference_matches = sum(check_record(record, mismatches)
                        for record in references)
markers = [line for line in (ATTEMPT / "run.log").read_text().splitlines()
           if "FULL_CURRENT_PORTAL_CONTROLLER_PASS" in line]

result = {
    "schema": "laya-generated-provenance-controller-f1b-stage-verification-v1",
    "created_at": datetime.now(timezone.utc).isoformat(),
    "project": "Laya-HLS",
    "mission": "M003",
    "small_mission": "SM003",
    "experiment": "E003",
    "run": "R003",
    "review_followup": "R-SM003-GENERATED-PROVENANCE-CANCEL-FENCE-20261012",
    "verdict": "PASS_SCOPED" if receipt["status"] == "PASS" and not mismatches
               else "FAIL",
    "scope": (
        "Controller END terminality F1b: fully bound non-OK responses with "
        "drained=0 retain the generated-store tracker, binding, issued bytes, "
        "and typed counters for both scope_active states; existing terminal "
        "success/failure and same-session recovery behavior remains covered."),
    "record": {
        "attempt": "portal_controller_31",
        "status": receipt["status"],
        "elapsed_seconds": receipt["elapsed_seconds"],
        "peak_owned_rss_kib": receipt["max_rss_kib"],
        "receipt": {"path": str(receipt_path.relative_to(PROJECT)),
                    "bytes": receipt_path.stat().st_size,
                    "sha256": digest(receipt_path)},
        "input_manifest": {"path": str(manifest_path.relative_to(PROJECT)),
                           "bytes": manifest_path.stat().st_size,
                           "sha256": digest(manifest_path)},
        "file_pairs": {"declared": len(pairs),
                       "current_hash_matches": current_matches,
                       "frozen_hash_matches": frozen_matches,
                       "declared_pair_hash_matches": pair_matches},
        "referenced_files": {"declared": len(references),
                             "matching": reference_matches},
        "marker": markers,
    },
    "evidence_boundaries": [
        "This is a controlled C++ Controller metadata/retirement regression; it does not execute the persistent RTL hub, real AXI monitor, generated adapter fence, numerical full graph, or hardware.",
        "The retained tracker is verified at the Controller boundary; production cancellation/fence resumption remains dependent on the persistent hub and adapter integration evidence.",
        "No OOC, place-and-route, or board run was performed."
    ],
    "mismatches": mismatches,
}
OUTPUT.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"verdict": result["verdict"],
                  "pairs": len(pairs),
                  "references": len(references),
                  "mismatches": len(mismatches)}))
raise SystemExit(0 if result["verdict"] == "PASS_SCOPED" else 1)
