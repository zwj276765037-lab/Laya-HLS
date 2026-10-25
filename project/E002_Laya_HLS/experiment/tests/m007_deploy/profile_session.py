#!/usr/bin/env python3
"""Short persistent real-wrapper CPU profile after identical-build function PASS.

Real JSON drives prepare; frozen compact hidden frames supply local finish input.
These pairings measure CPU boundary latency, never whole-model quality or QPS.
"""
import argparse
import hashlib
import importlib.abc
import importlib.util
import json
from pathlib import Path
import platform
import statistics
import sys
import time
import traceback

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))


class BlockReference(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path=None, target=None):
        if "full_reference" in fullname or "frozen_reference" in fullname:
            raise RuntimeError("production process forbids Python numerical reference import")


sys.meta_path.insert(0, BlockReference())
original_spec = importlib.util.spec_from_file_location
def deny_reference(name, location, *args, **kwargs):
    if "full_reference" in str(location) or "frozen_reference" in name:
        raise RuntimeError("production process forbids reference source execution")
    return original_spec(name, location, *args, **kwargs)
importlib.util.spec_from_file_location = deny_reference
from m007_deploy.native_session import NativeSession


def summary(values):
    ordered = sorted(values)
    return {"n": len(values), "min_ns": ordered[0], "median_ns": statistics.median(values),
            "p95_ns": ordered[int(np.ceil(.95*len(values)))-1], "max_ns": ordered[-1]}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("library", "model", "assets", "functional", "frontend_inputs", "frozen", "output"):
        p.add_argument("--"+name.replace("_", "-"), dest=name, type=Path, required=True)
    p.add_argument("--samples", type=int, default=32)
    p.add_argument("--pilot", action="store_true")
    p.add_argument("--cache-mode",choices=("full","lazy"),default="full")
    args = p.parse_args()
    if not (args.pilot and 1 <= args.samples <= 8 or not args.pilot and 32 <= args.samples <= 200):
        p.error("pilot1..8 or full32..200 actual hot requests required")
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"status":"RUNNING", "samples":[], "cold_token_samples":[], "new_word_samples":[], "pilot":args.pilot,"cache_mode":args.cache_mode,
        "scope":"native_cpu_contract real JSON/ctypes/copy/validation/synchronization/business decode",
        "timing_definition":{"prepare_ns":"input_end_to_end_ns: one session.prepare(data) call, including its internal encode(JSON/BPE/recipe), request binding, H0, validation and copies",
            "finish_ns":"one session.finish call, including compact-tail validation/copy, native tail, synchronization and original business decode",
            "auxiliary_real_encode_JSON_ns":"separate diagnostic operation; already included inside full prepare and must never be added again"},
        "device":"NOT_RUN", "Attention":"NOT_RUN", "whole_model_quality":"NOT_RUN",
        "whole_system_QPS":"NOT_CLAIMED", "target_prepare_ns":750000,"target_finish_ns":2250000,
        "platform":{"python":platform.python_version(),"libc":platform.libc_ver(),"numpy":np.__version__}}
    session = None
    try:
        functional = json.loads(args.functional.read_text())
        build = json.loads(args.library.with_suffix(".identity.json").read_text())
        if (functional["status"] != "PASS_NATIVE_SESSION_FUNCTIONAL" or
            functional["native_build"]["binary_sha256"] != build["binary_sha256"] or
            functional["native_build"]["source_sha256"] != build["source_sha256"]):
            raise RuntimeError("identical production-build functional PASS required before profiling")
        inputs = [json.loads((args.frontend_inputs / f"input_{i}.json").read_text()) for i in range(2)]
        tails = [(args.frozen / f"B1_from_b{i}_S128/tail.bin").read_bytes() for i in range(2)]
        report["input_identity"] = [{"real_JSON":item,"JSON_sha256":hashlib.sha256(json.dumps(item,ensure_ascii=False).encode()).hexdigest(),
            "tail_sha256":hashlib.sha256(tails[i]).hexdigest(),
            "tail_scope":"independent frozen hidden paired with explicit question labels for local CPU timing"}for i,item in enumerate(inputs)]
        session = NativeSession(args.library,args.model,args.assets,cache_mode=args.cache_mode)
        report["cold_initialization_ns"] = session.initialization_ns
        report["native_build"] = session.build_identity
        report["initial_cache_metrics"]=session.metrics()
        report["actual_thread_affinity"]={path.parent.name:next(line.split(":",1)[1].strip()for line in path.read_text().splitlines()
            if line.startswith("Cpus_allowed_list:"))for path in Path("/proc/self/task").glob("*/status")}
        identifier = 10000
        def request(data,tail,tag):
            nonlocal identifier
            before = session.metrics()
            began = time.perf_counter_ns()
            prepared = session.prepare(data, identifier, 1)
            prepare_ns = time.perf_counter_ns()-began
            if len(prepared)!=1:raise AssertionError("profile workload must have exactly one question")
            identifier+=1
            after_prepare = session.metrics()
            began = time.perf_counter_ns()
            result = session.finish(prepared[0],tail)
            finish_ns = time.perf_counter_ns()-began
            metrics=session.metrics()
            if result.logits18.size!=18 or result.backend!="native_cpu_contract":raise AssertionError("real result required")
            return {"tag":tag,"prepare_ns":prepare_ns,"input_end_to_end_ns":prepare_ns,"finish_ns":finish_ns,
                "new_token_misses":after_prepare["cache_misses"]-before["cache_misses"],
                "token_row_hits":after_prepare["cache_hits"]-before["cache_hits"],
                "native_prepare_ns":after_prepare["native_prepare_ns"],
                "marker_ln_ns":metrics["marker_ln_ns"],"scorer_ns":metrics["scorer_ns"],
                "act_ns":metrics["act_ns"],"native_finish_ns":metrics["native_finish_ns"],
                "wrapper_prepare_over_native_ns":prepare_ns-after_prepare["native_prepare_ns"],
                "wrapper_finish_over_native_ns":finish_ns-metrics["native_finish_ns"]}
        report["first_requests"]=[request(inputs[i],tails[i],f"initial_real_json_{i}")for i in range(2)]
        # BPE+JSON is a real auxiliary operation. Top-level accepted latency is
        # still the whole prepare call, not a subtraction using this diagnostic.
        bpe=[]
        for i in range(4 if args.pilot else 32):
            began=time.perf_counter_ns();session.encode(inputs[i%2]);bpe.append(time.perf_counter_ns()-began)
        report["auxiliary_real_encode_JSON_ns"]=summary(bpe)
        for i in range(args.samples):
            sample=request(inputs[i%2],tails[i%2],f"warm_{i%2}")
            if sample["new_token_misses"]:raise AssertionError("warm sample unexpectedly missed cache")
            report["samples"].append(sample)
        # New words are encoded normally. Count only actual measured new-token
        # misses as cold-token requests; do not identify or prefill fixture rows.
        words=("xylophone quartz jovial zephyr amethyst bumblebee cadenza daffodil epiphany fjord gazebo "
               "haberdashery iguana jigsaw kaleidoscope labyrinth marzipan nebula obelisk paprika quixotic "
               "rhapsody sapphire tangerine umbrella vermilion wisteria xenon yodel zirconium apricot "
               "basilisk chrysanthemum dodecahedron eucalyptus flamingo gossamer heliotrope iridescent "
               "javelin kerosene loquacious magnolia nocturnal opalescent pterodactyl quintessential "
               "rhododendron soliloquy thunderbolt ultraviolet valkyrie whimsical ytterbium zoology").split()
        cold_goal=2 if args.pilot else 32
        for word in words:
            data=json.loads(json.dumps(inputs[0]))
            data["state"] += " " + word
            sample=request(data,tails[0],"new_word_"+word)
            report["new_word_samples"].append(sample)
            if sample["new_token_misses"]:report["cold_token_samples"].append(sample)
            if (args.cache_mode=="full" and len(report["new_word_samples"])>=cold_goal or
                    args.cache_mode=="lazy" and len(report["cold_token_samples"])>=cold_goal):break
        fields=("prepare_ns","finish_ns","native_prepare_ns","marker_ln_ns","scorer_ns","act_ns",
                "native_finish_ns","wrapper_prepare_over_native_ns","wrapper_finish_over_native_ns")
        report["warm_distribution"]={key:summary([item[key]for item in report["samples"]])for key in fields}
        report["cold_token_distribution"]={key:summary([item[key]for item in report["cold_token_samples"]])for key in fields}if report["cold_token_samples"]else None
        report["new_word_distribution"]={key:summary([item[key]for item in report["new_word_samples"]])for key in fields}
        report["cold_token_note"]="All50368 model-token rows initialized once; newly encountered request words are cache hits, no hot miss exists"if args.cache_mode=="full"else"Measured true lazy-cache new-token misses; counts recorded per actual request"
        report["warm_prepare_over_target"]=sum(item["prepare_ns"]>750000 for item in report["samples"])
        report["warm_finish_over_target"]=sum(item["finish_ns"]>2250000 for item in report["samples"])
        report["cold_prepare_over_target"]=sum(item["prepare_ns"]>750000 for item in report["cold_token_samples"])
        report["cold_finish_over_target"]=sum(item["finish_ns"]>2250000 for item in report["cold_token_samples"])
        report["initial_prepare_over_target"]=sum(item["prepare_ns"]>750000 for item in report["first_requests"])
        report["initial_finish_over_target"]=sum(item["finish_ns"]>2250000 for item in report["first_requests"])
        report["new_word_prepare_over_target"]=sum(item["prepare_ns"]>750000 for item in report["new_word_samples"])
        report["new_word_finish_over_target"]=sum(item["finish_ns"]>2250000 for item in report["new_word_samples"])
        report["reference_blocked"]=not any("full_reference" in name or "frozen_reference" in name for name in sys.modules)
        if not report["reference_blocked"]:raise AssertionError("reference arithmetic leaked into production process")
        report["status"]="PROFILE_MEASURED"
        report["warm_verdict"]="PASS" if not (report["warm_prepare_over_target"] or report["warm_finish_over_target"])else"FAIL"
        report["cold_token_verdict"]="PASS" if not (report["cold_prepare_over_target"] or report["cold_finish_over_target"])else"FAIL"
        report["initial_request_verdict"]="PASS" if not (report["initial_prepare_over_target"] or report["initial_finish_over_target"])else"FAIL"
        report["new_word_verdict"]="PASS" if not (report["new_word_prepare_over_target"] or report["new_word_finish_over_target"])else"FAIL"
        report["performance_verdict"]="PASS_ALL_MEASURED_REQUEST_LIMITS" if all(report[key]=="PASS" for key in
            ("warm_verdict","cold_token_verdict","initial_request_verdict","new_word_verdict"))else"FAIL_SAMPLED_LIMITS"
        print(json.dumps({"status":report["status"],"verdict":report["performance_verdict"],
            "warm":report["warm_distribution"],"cold":report["cold_token_distribution"]}),flush=True)
        return 0
    except Exception as error:
        report.update(status="FAIL",error=f"{type(error).__name__}: {error}",traceback=traceback.format_exc())
        print(report["error"],file=sys.stderr,flush=True)
        return 1
    finally:
        if session is not None:session.close()
        (args.output/"report.json").write_text(json.dumps(report,indent=2,ensure_ascii=False,allow_nan=False)+"\n")


if __name__=="__main__":
    raise SystemExit(main())
