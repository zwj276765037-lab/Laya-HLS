#!/usr/bin/env python3
"""Independent frozen checkpoints, native frontend oracle and Session failures."""
from dataclasses import replace
import argparse
import ctypes as C
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import traceback

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from m007_deploy.native_session import NativeSession
from m007_deploy.contract import Identity, Request, decode_request, encode_request, ContractError, _encode
from m007_deploy.frontend import FrontendError
from m007_deploy.cpu_contract import GGUFWeights, prepare_h0, finish_tail_cpu_contract
sys.path.insert(0, str(Path(__file__).parent))
from replay_frozen import Fixtures
from check_frontend import Oracle, choice, expected_uncut


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("library", "model", "assets", "frozen", "oracle", "output"):
        p.add_argument("--" + name, type=Path, required=True)
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"status": "RUNNING", "checks": [], "scenarios": [], "device": "NOT_RUN",
              "full_graph_recomputed": False, "performance_acceptance": "NOT_RUN"}
    start = time.monotonic()
    oracle = None
    session = None
    def check(name, condition, **detail):
        report["checks"].append({"name": name, "status": "PASS" if condition else "FAIL", **detail})
        if not condition:
            raise AssertionError(name)
    def reject(name, function):
        try:
            function()
        except (ContractError, ArithmeticError, ValueError, OSError) as error:
            check(name, True, error=str(error))
        else:
            check(name, False)
    def compare(name, actual, expected):
        a, b = np.asarray(actual, dtype="<f4"), np.asarray(expected, dtype="<f4")
        if a.shape != b.shape:
            raise AssertionError("shape " + name)
        indices = np.flatnonzero((a.view("<u4") != b.view("<u4")).ravel())
        return {"name": name, "elements": a.size, "bit_mismatches": indices.size,
                "first_flat_index": int(indices[0]) if indices.size else None,
                "actual_first_u32": int(a.view("<u4").ravel()[indices[0]]) if indices.size else None,
                "expected_first_u32": int(b.view("<u4").ravel()[indices[0]]) if indices.size else None,
                "actual_sha256": hashlib.sha256(a.tobytes()).hexdigest(),
                "expected_sha256": hashlib.sha256(b.tobytes()).hexdigest()}
    try:
        fixtures = Fixtures(args.assets)
        session = NativeSession(args.library, args.model, args.assets,cache_mode="lazy")
        report["initialization_ns"] = session.initialization_ns
        report["native_build"] = session.build_identity
        report["identity"] = vars(session.identity)
        # I32 primitive independent gold covers signed limits, cancellation and
        # random complete groups, including -128 outside production Q8-F domain.
        primitive = session._lib.m007_dot32_diagnostic
        primitive.argtypes = [C.c_void_p,C.c_void_p,C.c_void_p]
        rng = np.random.default_rng(20261021)
        patterns = [np.full(32,value,dtype=np.int8) for value in (-128,-127,-1,0,1,127)]
        patterns += [np.tile(np.asarray((-128,127),dtype=np.int8),16)]
        patterns += [rng.integers(-128,128,32,dtype=np.int16).astype(np.int8) for _ in range(16)]
        for index, activation in enumerate(patterns):
            weight = rng.integers(-128,128,(16,32),dtype=np.int16).astype(np.int8)
            weight[0].fill(-128);weight[1].fill(127)
            output = np.empty(16,dtype="<i4")
            primitive(activation.ctypes.data,weight.ctypes.data,output.ctypes.data)
            expected = weight.astype(np.int32) @ activation.astype(np.int32)
            check(f"vnni_full_group_{index}", np.array_equal(output,expected))
        retained = None
        fixture_ids = set()
        for batch in (0, 1):
            name = f"B1_from_b{batch}_S128"
            folder = args.frozen / name
            old_identity = Identity(**json.loads((folder / "identity.json").read_text()))
            old_request = decode_request((folder / "request.bin").read_bytes(), old_identity)
            request = replace(old_request, identity=session.identity)
            ids = np.frombuffer((folder / "token_ids.i32.bin").read_bytes(), dtype="<i4").copy()
            fixture_ids.update(ids.tolist())
            question = {"type": "noul", "instructions": "True?"} if request.qtype == 2 else choice(request.candidate_count)
            prepared = session.prepare_tokens(ids, request, question_id="q", question=question)
            retained = prepared
            tail = (folder / "tail.bin").read_bytes()
            before_tail = hashlib.sha256(tail).hexdigest()
            checks = [compare("H0", prepared.h0, fixtures.checkpoint(name, "embedding_norm")[0])]
            result = session.finish(prepared, tail, trace=True)
            for checkpoint in ("marker_gather", "marker_norm", "scorer_fc1_baked", "scorer_post_bias_gelu",
                    "candidate_raw", "candidate_masked", "candidate_prob", "stats", "act_input",
                    "act_dot", "act_hidden", "act_logits", "final18"):
                expected = fixtures.checkpoint(name, checkpoint)[0]
                actual = session.checkpoint(checkpoint, expected.shape)
                checks.append(compare(checkpoint, actual, expected))
                (args.output / (name + "_" + checkpoint + ".f32.bin")).write_bytes(actual.tobytes())
            checks.append(compare("raw_cls", session.checkpoint("raw_cls", (1024,)), np.frombuffer(tail, dtype="<f4")[-1024:]))
            checks.append(compare("returned_final18", result.logits18, fixtures.checkpoint(name, "final18")[0]))
            scenario = {"name": name, "qtype": request.qtype, "candidates": request.candidate_count,
                        "checks": checks, "metrics": session.metrics(), "answer": result.answer,
                        "business_scope": "frozen real logits with explicit synthetic labels; no new full forward",
                        "input_sha256": {path.name: hashlib.sha256(path.read_bytes()).hexdigest() for path in
                            (folder / "token_ids.i32.bin", folder / "request.bin", folder / "tail.bin")}}
            report["scenarios"].append(scenario)
            check(name + "_all_checkpoints", all(item["bit_mismatches"] == 0 for item in checks))
            check(name + "_tail_input_unchanged", before_tail == hashlib.sha256(tail).hexdigest())
            reject(name + "_finish_consumed", lambda: session.finish(prepared, tail))
            print(f"M007_NATIVE_FROZEN_PASS {name} checkpoints={len(checks)} all_bits_exact=1", flush=True)
        report["frozen_complete"] = True

        oracle = Oracle(args.oracle, args.model, args.output)
        # Four actually used business JSON requests, checked against original native sources.
        for i in range(4):
            source = args.frozen.parents[1] / "AT021_frontend02_identity_checks/checks" / f"input_{i}.json"
            data = json.loads(source.read_text())
            actual, expected = session.encode(data), oracle.call({"op": "legacy-encode", **data})
            fields = ("question_id","token_ids","attention_mask","markers","marker_mask","qtype","candidate_count","live_tokens")
            check(f"real_json_{i}", all(a[field] == e[field] for a,e in zip(actual["questions"],expected["questions"])
                  for field in fields) and actual["serialized_state"] == expected["serialized_state"])
        boundary_q = {"type":"choice","instructions":"Pick.","criteria":{"A":None}}
        base_ids, _, _, _ = expected_uncut(oracle,"",boundary_q)
        state = " x" * (128-len(base_ids))
        gold_ids, positions, _, _ = expected_uncut(oracle,state,boundary_q)
        boundary = session.encode({"state":state,"questions":{"q":boundary_q}})["questions"][0]
        check("strict_exact128", len(gold_ids)==128 and boundary["token_ids"]==gold_ids and
              boundary["markers"]==positions+[0]*15 and boundary["attention_mask"]==[1]*128)
        reject("strict129",lambda:session.encode({"state":state+" x","questions":{"q":boundary_q}}))
        reject("long_state",lambda:session.encode({"state":" x"*300,"questions":{"q":boundary_q}}))
        long_q={"type":"choice","instructions":"Pick.","criteria":{"A":" x"*55}}
        gold_ids,_,lengths,_=expected_uncut(oracle,"",long_q)
        boundary=session.encode({"state":"","questions":{"q":long_q}})["questions"][0]
        check("legal_option_over48_retained",lengths[0]>48 and len(gold_ids)<=128 and
              boundary["token_ids"][:len(gold_ids)]==gold_ids)
        reject("long_option_total",lambda:session.encode({"state":"","questions":{"q":choice(1," x"*300)}}))
        reject("candidate17",lambda:session.encode({"state":"","questions":{"q":choice(17)}}))
        # Same source-native decode suite, independent of new numerical Session.
        for kind, counts in (("choice", (1,2,3,5,6,10,11,16)), ("score", (1,2,3,6,16)), ("noul", (2,))):
            for count in counts:
                question = choice(count) if kind == "choice" else {"type": kind, "instructions": "Rate.",
                    "criteria": ["level"] * count} if kind == "score" else {"type": "noul", "instructions": "True?"}
                for pattern in ("normal", "equal", "one_ulp"):
                    values = np.linspace(-1, 2, count, dtype="<f4") if pattern == "normal" else np.zeros(count, dtype="<f4")
                    if pattern == "one_ulp" and count > 1: values[1] = np.float32(2**-23)
                    slots = list(range(count)) if count > 3 else [0] if count == 1 else [0,15] if count == 2 else [0,3,15]
                    logits = np.full(18, -10000, dtype="<f4"); logits[slots] = values
                    logits[16:] = (0, 0 if pattern == "equal" else -2**-23)
                    mask = [int(i in slots) for i in range(16)]
                    actual = session.decode("q", question, logits, mask, {"choice":0,"score":1,"noul":2}[kind])
                    expected = oracle.call({"op":"decode", "question_id":"q", "question":question,
                        "candidate_u32":values.view("<u4").tolist(), "act_u32":logits[16:].view("<u4").tolist()})
                    check(f"decode_{kind}_{count}_{pattern}", actual["answer"] == expected["answer"] and actual["raw"] == expected["raw"])

        with GGUFWeights(args.model) as weights:
            token = next(i for i in range(50368) if i not in fixture_ids)
            ids = np.full(128, token, dtype="<i4")
            base = retained.request
            request = replace(base, request_id=500, generation=1)
            before = session.metrics()
            cold = session.prepare_tokens(ids, request)
            after = session.metrics()
            warm = session.prepare_tokens(ids, replace(request, request_id=501))
            check("true_new_token_miss", after["cache_misses"] - before["cache_misses"] == 1, token=token)
            check("hit_equals_miss", cold.h0.tobytes() == warm.h0.tobytes())
            check("cold_equals_independent_reference", cold.h0.tobytes() == prepare_h0(ids, weights).tobytes())
            # Dup markers and holes remain legal; compare all local tail math independently.
            markers = (0,0) + (0,)*14
            mask = (1,1) + (0,)*14
            dup_req = replace(base, request_id=502, qtype=2, candidate_count=2, markers=markers, marker_mask=mask)
            dup = session.prepare_tokens(ids, dup_req)
            tail = np.zeros((17,1024), dtype="<f4")
            tail[16] = np.linspace(-1, 1, 1024, dtype="<f4")
            raw = tail[16].copy()
            result = session.finish(dup, tail, decode=False, trace=True)
            gold = finish_tail_cpu_contract(tail.tobytes(), dup_req, weights)
            check("duplicate_markers_tail_exact", result.logits18.tobytes() == gold.logits18.tobytes())
            check("raw_cls_preserved", tail[16].tobytes() == raw.tobytes())
            # Additional independent local-tail reference input, not a new
            # full-model gold. Exercise SIMD tree and ordered dense reductions.
            random_tail = rng.normal(0,.2,(17,1024)).astype("<f4")
            random_req = replace(base,request_id=503)
            random_prepared = session.prepare_tokens(ids,random_req)
            actual_stages = {}
            result = session.finish(random_prepared,random_tail,decode=False,trace=True)
            gold = finish_tail_cpu_contract(random_tail.tobytes(),random_req,weights,
                checkpoint=lambda name,value:actual_stages.update({name:value}))
            for name,value in actual_stages.items():
                check("random_tail_"+name,session.checkpoint(name,value.shape).tobytes()==value.tobytes())
            check("random_tail_returned",result.logits18.tobytes()==gold.logits18.tobytes())

        # Failure must leave caller-owned output sentinel untouched; retry remains valid.
        bad = np.zeros((17,1024), dtype="<f4"); bad[0,0] = np.nan
        sentinel = np.full(18, np.float32(123.25), dtype="<f4")
        original_affinity=os.sched_getaffinity(0)
        rc = session._lib.m007_finish(session._handle, C.c_char_p(encode_request(cold.request)),
                                     bad.ctypes.data, sentinel.ctypes.data, 0)
        check("nonfinite_does_not_pollute_output", rc != 0 and np.all(sentinel == np.float32(123.25)))
        check("affinity_restored_after_native_error",os.sched_getaffinity(0)==original_affinity)
        bad.fill(np.finfo(np.float32).max)
        rc = session._lib.m007_finish(session._handle, C.c_char_p(encode_request(cold.request)),
                                     bad.ctypes.data, sentinel.ctypes.data, 0)
        check("finite_overflow_does_not_pollute_output", rc != 0 and np.all(sentinel == np.float32(123.25)))
        h0_sentinel=np.full((128,1024),np.float32(42.5),dtype="<f4")
        invalid_ids=np.full(128,50368,dtype="<i4")
        invalid_req=replace(cold.request,request_id=902)
        rc=session._lib.m007_prepare(session._handle,invalid_ids.ctypes.data,C.c_char_p(encode_request(invalid_req)),h0_sentinel.ctypes.data)
        check("invalid_token_does_not_pollute_H0",rc!=0 and np.all(h0_sentinel==np.float32(42.5)))
        reject("cross_request_finish", lambda: session.finish(replace(cold, request=replace(cold.request, generation=2)), bytes(69632), decode=False))
        reject("changed_question_binding", lambda: session.finish(replace(cold,question_json='{"type":"noul","instructions":"changed"}'),bytes(69632),decode=False))
        reject("changed_source_binding", lambda: session.finish(replace(cold,source_sha256="1"*64),bytes(69632),decode=False))
        reject("short_tail", lambda: session.finish(cold, bytes(69631), decode=False))
        reject("wrong_model_identity", lambda: session.prepare_tokens(ids, replace(cold.request, identity=replace(session.identity, model="1"*64))))
        reject("invalid_token", lambda: session.prepare_tokens(np.full(128,50368,dtype="<i4"), replace(cold.request,request_id=900)))
        reject("marker128", lambda: session.prepare_tokens(ids, replace(cold.request, request_id=901, markers=(128,)+cold.request.markers[1:])))
        reject("stale_completion", lambda: session.finish(cold, bytes(69632), completion=_encode(replace(cold.request,generation=2),2,0,17408),decode=False))
        session.finish(cold, bytes(69632), decode=False)
        check("recovery_after_numeric_errors", True)
        # Actual local FE state is restored after each native call.
        libc = C.CDLL(None); libc.fegetround.restype = C.c_int
        saved = libc.fegetround()
        libc.fesetround(0x400)  # FE_DOWNWARD on this bound x86_64 platform.
        state = session.fenv()
        session.decode("q", choice(2), np.zeros(18,dtype="<f4"), [1,1]+[0]*14, 0)
        after_state = session.fenv()
        check("caller_fenv_restored", libc.fegetround() == 0x400 and
              (after_state["mxcsr"] & 0xffc0) == (state["mxcsr"] & 0xffc0))
        check("caller_affinity_restored_success",os.sched_getaffinity(0)==original_affinity)
        libc.fesetround(saved)
        session.close()
        reject("closed_session", lambda: session.finish(warm, bytes(69632), decode=False))
        session = NativeSession(args.library, args.model, args.assets,cache_mode="lazy")
        check("reload_cache_invalidated", session.metrics()["cache_hits"] == 0 and session.metrics()["cache_misses"] == 0)
        reject("reload_rejects_old_prepared", lambda: session.finish(warm, bytes(69632), decode=False))
        fresh = session.prepare_tokens(ids, replace(warm.request, identity=session.identity, request_id=1000))
        check("reload_new_miss_same_H0", fresh.h0.tobytes() == warm.h0.tobytes() and session.metrics()["cache_misses"] == 1)
        # Initialization identity failure must not prevent a subsequent correct Session.
        reject("initialization_bad_library", lambda: NativeSession(args.library.with_name("missing.so"), args.model, args.assets))
        id_bytes=b"".join(bytes.fromhex(getattr(session.identity,name))for name in("model","graph","numeric","layout","build"))
        failed=session._lib.m007_create(b"{}",-1,C.c_char_p(id_bytes))
        check("native_initialization_error",not failed and bool(session._lib.m007_error(None)))
        check("existing_session_after_failed_init",session.metrics()["cache_misses"]==1)
        session.close()
        session = NativeSession(args.library,args.model,args.assets)
        report["production_full_cache_initialization_ns"]=session.initialization_ns
        report["production_full_cache_metrics"]=session.metrics()
        check("production_full_cache_all_tokens",session.metrics()["cache_initialized_rows"]==50368 and session.metrics()["cache_misses"]==0)
        for batch in (0,1):
            name=f"B1_from_b{batch}_S128";folder=args.frozen/name
            identity=Identity(**json.loads((folder/"identity.json").read_text()))
            request=replace(decode_request((folder/"request.bin").read_bytes(),identity),identity=session.identity,request_id=2000+batch)
            tokens=np.frombuffer((folder/"token_ids.i32.bin").read_bytes(),dtype="<i4")
            prepared=session.prepare_tokens(tokens,request)
            check("full_cache_"+name+"_H0",prepared.h0.tobytes()==fixtures.checkpoint(name,"embedding_norm")[0].tobytes())
            result=session.finish(prepared,(folder/"tail.bin").read_bytes(),decode=False,trace=True)
            for checkpoint in ("marker_gather","marker_norm","scorer_fc1_baked","scorer_post_bias_gelu","candidate_raw",
                    "candidate_masked","candidate_prob","stats","act_input","act_dot","act_hidden","act_logits","final18"):
                expected=fixtures.checkpoint(name,checkpoint)[0]
                check("full_cache_"+name+"_"+checkpoint,session.checkpoint(checkpoint,expected.shape).tobytes()==expected.tobytes())
            check("full_cache_"+name+"_returned",result.logits18.tobytes()==fixtures.checkpoint(name,"final18")[0].tobytes())
        check("full_cache_no_request_misses",session.metrics()["cache_misses"]==0)
        arbitrary=session.prepare_tokens(ids,replace(warm.request,identity=session.identity,request_id=3000))
        check("full_cache_arbitrary_token_equals_independent_miss",arbitrary.h0.tobytes()==warm.h0.tobytes() and session.metrics()["cache_misses"]==0)
        reject("full_cache_rejects_old_session",lambda:session.finish(warm,bytes(69632),decode=False))
        report["status"] = "PASS_NATIVE_SESSION_FUNCTIONAL"
        report["check_count"] = len(report["checks"])
        report["checked_fixtures"] = fixtures.checked
        report["production_reference_arithmetic"] = "NOT_CALLED; separate blocked-import smoke required"
        print(f"M007_NATIVE_SESSION_FUNCTIONAL_PASS checks={len(report['checks'])} frozen_requests=2 device=NOT_RUN",flush=True)
        return 0
    except Exception as error:
        report.update(status="FAIL",error=f"{type(error).__name__}: {error}",traceback=traceback.format_exc())
        print(report["error"],file=sys.stderr,flush=True)
        return 1
    finally:
        if session is not None: session.close()
        if oracle is not None: oracle.close()
        report["elapsed_s"] = time.monotonic()-start
        (args.output/"report.json").write_text(json.dumps(report,indent=2,ensure_ascii=False,allow_nan=False,default=int)+"\n")


if __name__ == "__main__":
    raise SystemExit(main())
