#!/usr/bin/env python3
"""Audit immutable native CPU03 evidence; never recompute full-model gold."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[2]
PROJECT=ROOT.parents[2]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--run",type=Path,required=True)
    p.add_argument("--output",type=Path,required=True)
    args=p.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    run=args.run.resolve()
    build_dir=run/"AT022_native_session_regex_init_build/build"
    library=build_dir/"libm007_session.so"
    build=json.loads(library.with_suffix(".identity.json").read_text())
    assert sha(library)==build["binary_sha256"]
    sources=[]
    for name,expected in build["source_sha256"].items():
        assert sha(ROOT/name)==expected,name
        sources.append({"path":name,"sha256":expected})
    closure=Path(build["recoverable_native_sources"]["path"])
    assert sha(closure)==build["recoverable_native_sources"]["sha256"]
    with tarfile.open(closure,"r:gz")as archive:
        for record in sources:
            member=archive.extractfile(record["path"])
            assert member and hashlib.sha256(member.read()).hexdigest()==record["sha256"],record["path"]
    listing=subprocess.check_output(["objdump","-d",str(library)],text=True)
    assert re.search(r"\bvpdpbusd\b",listing),"non-saturating VNNI absent"
    assert not re.search(r"\bvpdpbusds\b",listing),"saturating VNNI present"
    assert not re.search(r"\bv(?:fmadd|fmsub|fnmadd|fnmsub)\w*\b",listing),"FMA present"
    assembly={"non_saturating_vpdpbusd":len(re.findall(r"\bvpdpbusd\b",listing)),
              "saturating_vpdpbusds":0,"FMA_instructions":0,
              "disassembly_sha256":hashlib.sha256(listing.encode()).hexdigest()}
    (args.output/"native_asm_audit.json").write_text(json.dumps(assembly,indent=2)+"\n")
    paths={"functional":run/"AT023_native_session_final_functional/checks/report.json",
           "startup_pilot":run/"AT024_native_session_final_pilot/profile/report.json",
           "full_profile":run/"AT025_native_session_final_profile200/profile/report.json",
           "lazy_profile":run/"AT026_native_session_final_lazy32/profile/report.json"}
    records={name:json.loads(path.read_text())for name,path in paths.items()}
    assert records["functional"]["status"]=="PASS_NATIVE_SESSION_FUNCTIONAL"
    assert records["functional"]["check_count"]==156
    for name,record in records.items():
        assert record["native_build"]["binary_sha256"]==build["binary_sha256"],name
        assert record["native_build"]["source_sha256"]==build["source_sha256"],name
    for name in ("startup_pilot","full_profile","lazy_profile"):
        assert records[name]["status"]=="PROFILE_MEASURED"and records[name]["reference_blocked"]
    assert len(records["full_profile"]["samples"])==200
    assert len(records["lazy_profile"]["samples"])==32
    assert len(records["lazy_profile"]["cold_token_samples"])>=32
    assert records["full_profile"]["initial_cache_metrics"]["cache_initialized_rows"]==50368
    attempts=[]
    spent={"reference_unit":0.,"compile":0.,"cpu_profile":0.}
    for path in sorted(run.glob("AT*/receipt.json")):
        record=json.loads(path.read_text());spent[record["phase"]]+=record.get("child_wall_s",0)
        attempts.append({"path":str(path.relative_to(PROJECT)),"sha256":sha(path),
            "phase":record["phase"],"status":record["status"],"child_wall_s":record.get("child_wall_s",0),
            "RSS_sampled_peak_bytes":record.get("RSS_sampled_peak_bytes"),
            "note":"current final-audit receipt may still be RUNNING; final receipt remains authoritative"if record["status"]=="RUNNING"else None})
    report={"schema":"m007-native-cpu03-release-v4", "execution_state":"completed",
        "functional_verdict":"PASS_SCOPED_NATIVE_CPU_SESSION", "performance_verdict":"FAIL_SAMPLED_LIMITS",
        "scope":"persistent CPU H0 and compact tail only; no Attention/XRT/board/whole-model performance",
        "binary":{"path":str(library.relative_to(PROJECT)),"sha256":sha(library)},
        "build_identity":{"path":str(library.with_suffix('.identity.json').relative_to(PROJECT)),
                          "sha256":sha(library.with_suffix('.identity.json'))},
        "source_files":sources,"recoverable_native_sources":build["recoverable_native_sources"],
        "assembly":assembly,"libm":build["libm"],
        "artifacts":{name:{"path":str(path.relative_to(PROJECT)),"sha256":sha(path)}for name,path in paths.items()},
        "function_checks":records["functional"]["check_count"],
        "frozen_requests":records["functional"]["scenarios"],
        "full_cache_bytes":206307328,"full_vocabulary_rows":50368,
        "full_initialization_ns":records["full_profile"]["cold_initialization_ns"],
        "cache_fill_ns":records["full_profile"]["initial_cache_metrics"]["cache_fill_ns"],
        "cohorts":{name:{"mode":record["cache_mode"],"actual_complete_requests":len(record["first_requests"])+len(record["samples"])+len(record["new_word_samples"]),
            "warm_n":len(record["samples"]),"new_word_n":len(record["new_word_samples"]),"true_miss_n":len(record["cold_token_samples"]),
            "first_requests":record["first_requests"],"warm_distribution":record["warm_distribution"],
            "new_word_distribution":record["new_word_distribution"],"cold_token_distribution":record["cold_token_distribution"],
            "violations":{key:value for key,value in record.items()if key.endswith("over_target")},
            "verdict":record["performance_verdict"],"actual_thread_affinity":record["actual_thread_affinity"]}
            for name,record in records.items()if name!="functional"},
        "budget_spent_before_final_audit_receipt_s":spent,"attempts":attempts,
        "remaining_gap":"first real input exceeds750000ns even after general cache/regex initialization; final200 tail samples include2250000ns violations",
        "next_CPU_optimization_boundary":"fuse native JSON/metadata/request binding into one C ABI call to remove large token/mask JSON roundtrip; improve scorer scheduling/layout with new causal evidence; no repeated same-binary200 reruns",
        "no_whole_system_QPS":True,"device":"NOT_RUN","GPU_benchmark":"NOT_RUN",
        "predecessor_archive_record":str((run/"predecessor_v3_archive_record.json").relative_to(PROJECT))}
    (run/"release_evidence_v4.json").write_text(json.dumps(report,indent=2,ensure_ascii=False,allow_nan=False)+"\n")
    print(f"M007_NATIVE_CPU03_HANDOFF_AUDIT_PASS functional_checks=156 production_sources={len(sources)} functional=PASS performance=FAIL device=NOT_RUN",flush=True)


if __name__=="__main__":
    main()
