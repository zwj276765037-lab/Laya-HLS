"""Static contract/delivery audit only; does not execute DUT or tools."""
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
import hashlib
import json
import shutil


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text())


def record(path):
    path = Path(path)
    return {"path": str(path.relative_to(ROOT)), "sha256": digest(path)}


v = read(HERE / "verification.json")
previous_path = ROOT / "results/executor_checkpoint_rtl_review_20261013/verification.json"
assert digest(previous_path) == "29634646e6f5c78021c0fdd5801301d05e0b77a41a693a4e51c1a809e41dae1e"
previous = read(previous_path)
run = ROOT / "project/E003_production_chain_closure/experiment_results/runs/R003"
correction = read(run / "executor_checkpoint_rtl_count_correction_20261013.json")
old = {(p["attempt"], p["path"], p["frozen_path"]): p for p in previous["pairs"]}
assert len(old) == len(correction["pairs"]) == 183
for p in correction["pairs"]:
    prior = old[(p["attempt"], p["original"]["path"], p["frozen"]["path"])]
    assert p["original"]["sha256"] == p["frozen"]["sha256"] == prior["expected"]
    assert digest(p["frozen"]["path"]) == prior["expected"]
    assert p["actual_current"]["sha256"] == prior["current"]
    assert (p["current_match"], p["frozen_match"], p["declared_pair_match"]) == (
        prior["current_match"], prior["frozen_match"], prior["pair_match"])
assert Counter((p["declared"]["path"], p["declared"]["sha256"], p["actual"]["sha256"], p["match"])
               for p in correction["recursive_references"]) == Counter(
    (p["path"], p["expected"], p["actual"], p["match"]) for p in previous["references"])
assert (correction["current_pairs_matching"], correction["references_matching"], correction["references"]) == (174, 612, 621)
for p in v["count_correction"]["historical_deliverables_checked_unchanged"]:
    assert digest(p["path"]) == p["sha256"]

message_id = "executor-checkpoint-import-handshake-answer-20261013"
receipt_path = ROOT / f".research-agent/communications/{message_id}.json"
reply_path = ROOT / "results/executor_checkpoint_import_handshake_reply_20261013.md"
d = read(receipt_path)
assert d["status"] == "delivered"
assert d["from_thread_id"] == "01a129af-0395-7fd0-95ac-edd54873bd5f"
assert d["to_thread_id"] == "01a129af-29ef-7102-b86a-a43995a36279"
assert d["in_reply_to"] == "executor-checkpoint-import-handshake-question-20261013"
assert d["text"] == reply_path.read_text()
fields = ("from_role", "from_thread_id", "to_role", "to_thread_id", "kind", "text", "in_reply_to")
payload = json.dumps({k: d[k] for k in fields}, sort_keys=True, ensure_ascii=False).encode("utf-8")
assert hashlib.sha256(payload).hexdigest() == d["payload_sha256"]

for name in (d["in_reply_to"], message_id):
    rel = Path(f".research-agent/communications/{name}.json")
    dst = HERE / "snapshot" / rel
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, dst)
        v["snapshots"].append({"original": str(rel), **record(dst)})
for p in v["snapshots"]:
    assert digest(ROOT / p["path"]) == p["sha256"]
check_path = HERE / "organization_check.json"
check = read(check_path)
assert check["ok"] and not check["broken_links"]
records = [
    "results/executor_checkpoint_import_handshake_contract_20261013.md",
    "results/executor_checkpoint_import_handshake_reply_20261013.md",
    "results/reviews/SM003.md", "results/review_queue.md", "results/overview.md",
    "mission/current.md", "agent/A001/result.md", "agent/A001/state.json",
    ".research-agent/discussions.json",
]
v["decision"] = {
    "prequery_hold": "independent_tagged_bounded_channel_preserve_strong_prepare_accept",
    "sequence": "reserve_existing_snapshot_sequence_once_before_hold_then_exact_pending_match",
    "handoff": "shell_assigns_epoch_on_hold_accept_preserves_consumed_high_water",
    "dispatch_gate": "true_full_response_consumption_and_actual_helper_import_OK_then_tagged_shell_GRANT",
    "cancel_base": "same_cycle_priority_sticky_revocation_for_key_no_high_water_rollback",
    "old_cleanup": "continues_until_real_action_boundary_and_physical_return_drain",
    "new_request": "safe_tagged_rearm_actual_results_consumed_persistent_authority_high_waters",
    "implementation_owner": "A002",
    "implementation_validated": False,
    "C009": "awaiting_implementation",
    "M003_M004_complete": False,
}
v["finalization"] = {
    "at": datetime.now(timezone.utc).isoformat(),
    "snapshot_count": len(v["snapshots"]), "snapshot_integrity_all": True,
    "delivery": {**record(receipt_path), "status": d["status"], "delivered_at": d["delivered_at"],
                 "payload_matches_reply": True, "structured_payload_hash_matches": True},
    "organization_check": {**record(check_path), "ok": True, "broken_links": [], "warnings": check["warnings"]},
    "controller_records": [record(ROOT / p) for p in records],
    "audit_script": record(Path(__file__).resolve()),
}
(HERE / "verification.json").write_text(json.dumps(v, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"delivery": "verified", "snapshots": len(v["snapshots"]),
                  "count_correction": "verified_closed", "organization": "ok",
                  "verification": record(HERE / "verification.json")}, ensure_ascii=False))
