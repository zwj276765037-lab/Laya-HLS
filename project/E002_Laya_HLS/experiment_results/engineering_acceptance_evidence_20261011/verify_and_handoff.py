"""Verify completed engineering deliverables, then write the handoff marker last."""
from pathlib import Path
from datetime import datetime, timezone
from collections import Counter
import hashlib, json, re, runpy

ROOT=Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS")
EVIDENCE=Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011")
RESULTS=ROOT/"project/E002_Laya_HLS/experiment_results"
THREAD="01a129af-29ef-7102-b86a-a43995a36279"

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def read(p):
    return json.loads(p.read_text())

inputs=read(EVIDENCE/"input_checks.json")
manifest=read(ROOT/"project/E002_Laya_HLS/experiment/build/model-current-production-v2-20261011/manifest.json")
counts=Counter(str(x["dtype"]) for x in manifest["weights"])
assert counts["8"]==122, counts
protected=inputs["protected_file_sha256_before_delivery"]
protected_now={path:sha(ROOT/path) for path in protected}
assert protected_now==protected, "Protected controller/research files changed; do not write completed handoff."

identity=read(EVIDENCE/"identity_audit.json")
source_checks=[]
for doc in identity["documents"]:
    if doc["document_path"].endswith("t2_production_stage_close_01/working_source_manifest.json"):
        for row in doc["references"]:
            p=Path(row["mapped_path"])
            source_checks.append({"path":str(p.relative_to(ROOT)),"unchanged":sha(p)==row["actual_sha256"]})
supplement=read(EVIDENCE/"supplemental_identity_audit.json")
for row in supplement["current_production_source_comparison_to_old_csim"]:
    p=ROOT/row["current_path"]
    source_checks.append({"path":row["current_path"],"unchanged":sha(p)==row["current_sha256"]})
assert source_checks and all(x["unchanged"] for x in source_checks), "Implementation changed during assessment."
assert all(x["status"]=="MATCH" for x in inputs["package_BO_checks"])
assert all(x["status"]=="MATCH" for x in inputs["requests"])

report_path="project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md"
result_path="agent/A002/result.md"
summary_paths=["project/E002_Laya_HLS/experiment_source/summary.md",
               "project/E002_Laya_HLS/experiment_results/summary.md",
               "project/E002_Laya_HLS/experiment_status/summary.md"]
state=read(ROOT/"agent/A002/state.json")
assert state["execution_state"]=="completed"
assert state["thread_id"]==THREAD
assert state.get("actual_model") is None and state.get("actual_effort") is None
assert "engineering_acceptance" in state["stage"]
publication=read(EVIDENCE/"publication_input.json")
assert publication["execution_state"]=="completed" and publication["verdict"]=="inconclusive"
assert "NOT_ACCEPTED" in (ROOT/report_path).read_text()
for kind,path in zip(["source","results","status"],summary_paths):
    assert publication[kind] in (ROOT/path).read_text(), path

broken=[]
for rel in [report_path,result_path,*summary_paths]:
    p=ROOT/rel
    for target in re.findall(r"\]\(([^)]+)\)",p.read_text()):
        if target.startswith(("https://","http://","#")):continue
        clean=re.sub(r":\d+$","",target.split("#",1)[0])
        link=Path(clean) if clean.startswith("/") else p.parent/clean
        if not link.exists():broken.append({"document":rel,"target":target})
assert not broken, broken

history=RESULTS/"publication_history/P0aa6533d50e24ddbae22f0ce17a43cc8"
assert history.is_dir()
history_files=[str(p.relative_to(ROOT)) for p in history.iterdir() if p.is_file()]
assert history_files

# Point-in-time observation only; never starts or controls processes.
module=runpy.run_path(str(EVIDENCE/"audit.py"),run_name="acceptance_import")
process=module["processes"]()
verification={"schema":1,"verified_at":datetime.now(timezone.utc).isoformat(),
              "engineering_delivery_complete":True,"complete_accelerator_passed":False,
              "protected_controller_files_unchanged":True,"protected_file_sha256":protected_now,
              "implementation_identity_unchanged_during_delivery":source_checks,
              "package_dtype_counts":dict(counts),"summary_publication_verified":True,
              "publication_history_path":str(history.relative_to(ROOT)),
              "publication_history_files":history_files,"broken_markdown_links":broken,
              "process_check":process}
(EVIDENCE/"delivery_verification.json").write_text(json.dumps(verification,ensure_ascii=False,indent=2)+"\n")
thread_evidence=read(EVIDENCE/"thread_runtime_evidence.json")
files=[report_path,result_path,*summary_paths,"agent/A002/state.json","agent/A002/status.md"]
files.extend(str(p.relative_to(ROOT)) for p in EVIDENCE.iterdir() if p.is_file())
entries=[{"path":rel,"sha256":sha(ROOT/rel),"bytes":(ROOT/rel).stat().st_size} for rel in sorted(set(files))]
handoff={"schema":1,"project_root":str(ROOT),"engineering_thread_id":THREAD,
         "turn_id":thread_evidence["turn_id"],"previous_interrupted_turn_id":thread_evidence["previous_interrupted_turn_id"],
         "stage":"engineering_acceptance","status":"completed",
         "completed_at":datetime.now(timezone.utc).isoformat(),
         "report_path":report_path,"result_path":result_path,"summary_paths":summary_paths,
         "state_paths":["agent/A002/state.json","agent/A002/status.md"],
         "requested_model":"gpt-6.1-sol","requested_effort":"xhigh",
         "actual_model":None,"actual_effort":None,
         "complete_accelerator_passed":False,"accelerator_verdict":"NOT_ACCEPTED_EVIDENCE_INSUFFICIENT",
         "meaning":"This marker certifies completion of the engineering assessment deliverables only; it does not accept the complete accelerator or complete M002/SM002.",
         "publication_history_path":str(history.relative_to(ROOT)),
         "files":entries,"sha256":{x["path"]:x["sha256"] for x in entries}}
# This marker is intentionally the final filesystem mutation of the delivery.
handoff_path=RESULTS/"engineering_acceptance_handoff_20261011.json"
handoff_path.write_text(json.dumps(handoff,ensure_ascii=False,indent=2)+"\n")
print(json.dumps({"handoff_path":str(handoff_path),"status":handoff["status"],
                  "turn_id":handoff["turn_id"],"files_verified":len(entries),
                  "protected_files_unchanged":True,"implementation_checks":len(source_checks),
                  "package_dtype_counts":dict(counts),"project_heavy_processes":process["project_heavy_processes"]},ensure_ascii=False))
