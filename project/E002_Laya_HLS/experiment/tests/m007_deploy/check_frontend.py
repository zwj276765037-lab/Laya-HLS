#!/usr/bin/env python3
"""Independent original-native comparisons for FRONTEND-02; no full forward."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import traceback

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from m007_deploy.frontend import (NativeFrontend, FrontendError, load_json_strict,
    prepare_json_requests, decode_prepared)
from m007_deploy.contract import Identity, decode_request
from m007_deploy.cpu_contract import GGUFWeights, strict_reference


class Oracle:
    def __init__(self, binary, model, output):
        self.err = (output / "oracle_stderr.log").open("w")
        self.process = subprocess.Popen([str(binary), str(model)], stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=self.err, text=True, encoding="utf-8", bufsize=1)
        assert json.loads(self.process.stdout.readline())["status"] == "ORACLE_READY"
    def call(self, data):
        self.process.stdin.write(json.dumps(data, ensure_ascii=False, allow_nan=False) + "\n")
        self.process.stdin.flush()
        line = self.process.stdout.readline()
        assert line, "independent native oracle ended"
        result = json.loads(line)
        assert result["status"] == "OK"
        return result
    def tokens(self, text):
        return self.call({"op": "tokenize", "text": text})["tokens"]
    def close(self):
        self.process.stdin.close(); self.process.wait(timeout=5)
        self.process.stdout.close(); self.err.close()


def choice(k=3, description=None):
    return {"type": "choice", "instructions": "Pick the best option.",
            "criteria": {f"option-{i}": (description if description is not None else f"value {i}")
                         for i in range(k)}}


def expected_uncut(oracle, state, question):
    """Independent assembly from original BPE and renderer, not the M007 assembler."""
    legacy = oracle.call({"op": "legacy-encode", "state": state, "questions": {"q": question}})
    options = legacy["questions"][0]["rendered_options"]
    # This helper is used only on boundary cases without injected special text.
    ids = [50281] + oracle.tokens(question["type"] + " question: " + question.get("instructions", "")) + [50282]
    markers = []
    option_lengths = []
    for option in options:
        markers.append(len(ids)); ids.append(50284)
        part = oracle.tokens(" " + option); option_lengths.append(len(part)); ids += part
    ids += [50282] + oracle.tokens(legacy["serialized_state"]) + [50282]
    return ids, markers, option_lengths, legacy


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--oracle", type=Path, required=True)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--assets", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--frozen", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"status": "RUNNING", "device": "NOT_RUN", "full_forward": "NOT_RUN",
              "cases": [], "scope": "structured business JSON and source-native functional comparisons"}
    oracle = None
    try:
        oracle = Oracle(args.oracle, args.model, args.output)
        with NativeFrontend(args.binary, args.model, args.assets, args.output / "native") as native:
            def check(name, condition, **details):
                if not condition: raise AssertionError(name)
                report["cases"].append({"name": name, "status": "PASS", **details})
            def reject(name, code, function):
                try: function()
                except FrontendError as error:
                    check(name, error.code == code, code=error.code)
                else: raise AssertionError(name + " did not reject")

            inputs = [
                {"state": "The customer accepted the offer.", "questions": {
                    "approved": {"type": "noul", "instructions": "Was the offer accepted?"}}},
                {"state": {"sender": "Ana", "urgent": True, "message": "请尽快确认"},
                 "questions": {"priority": choice()}},
                {"state": "[MASK] repeated [MASK], 中文测试 [CLS] text", "questions": {
                    "special": {"type": "choice", "instructions": "[MASK] Pick 中文 [SEP]",
                                "criteria": {"b": "same [MASK]", "a": "same [MASK]"}}}},
                {"state": ["ok", 3, None], "questions": {"score": {
                    "type": "score", "instructions": "Rate it.", "criteria": ["low", "middle", "high"]}}}
            ]
            for i, data in enumerate(inputs):
                actual = native.encode(data)
                expected = oracle.call({"op": "legacy-encode", **data})
                for a, e in zip(actual["questions"], expected["questions"]):
                    for field in ("token_ids", "attention_mask", "markers", "marker_mask", "qtype", "candidate_count", "live_tokens"):
                        check(f"native_nontruncating_{i}_{field}", a[field] == e[field])
                check(f"native_state_serialization_{i}", actual["serialized_state"] == expected["serialized_state"])
                (args.output / f"input_{i}.json").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")

            q = {"type": "choice", "instructions": "Pick.", "criteria": {"A": None}}
            base, _, _, _ = expected_uncut(oracle, "", q)
            state = " x" * (128 - len(base))
            expected, markers, _, _ = expected_uncut(oracle, state, q)
            check("independent_exact128_fixture", len(expected) == 128)
            exact = native.encode({"state": state, "questions": {"q": q}})["questions"][0]
            check("exact128_all_tokens", exact["token_ids"] == expected and exact["attention_mask"] == [1] * 128)
            check("exact128_all_markers", exact["markers"] == markers + [0] * 15)
            reject("sequence129_rejected", "LENGTH_ERROR", lambda: native.encode({"state": state + " x", "questions": {"q": q}}))
            reject("long_state_rejected", "LENGTH_ERROR", lambda: native.encode({"state": " x" * 300, "questions": {"q": q}}))
            long_q = {"type": "choice", "instructions": "Pick.", "criteria": {"A": " x" * 55}}
            expected, markers, lengths, legacy = expected_uncut(oracle, "", long_q)
            check("over48_legal_fixture", lengths[0] > 48 and len(expected) <= 128,
                  option_tokens=lengths[0], total_tokens=len(expected))
            actual = native.encode({"state": "", "questions": {"q": long_q}})["questions"][0]
            check("over48_option_retained", actual["token_ids"][:len(expected)] == expected and actual["live_tokens"] == len(expected))
            check("over48_intentional_legacy_difference", legacy["questions"][0]["raw_ids"] != expected,
                  scope="strict complete input policy, old clipped output not gold")
            reject("long_option_total_rejected", "LENGTH_ERROR", lambda: native.encode({"state": "", "questions": {"q": choice(1, " x" * 300)}}))
            reject("candidate17_rejected", "CANDIDATE_ERROR", lambda: native.encode({"state": "", "questions": {"q": choice(17)}}))
            reject("unknown_qtype", "QUESTION_ERROR", lambda: native.encode({"state": "", "questions": {"q": {"type": "unknown"}}}))
            reject("empty_choice", "QUESTION_ERROR", lambda: native.encode({"state": "", "questions": {"q": choice(0)}}))
            reject("empty_questions", "QUESTION_ERROR", lambda: native.encode({"state": "", "questions": {}}))

            for kind, counts in (("choice", (1, 2, 3, 5, 6, 10, 11, 16)), ("score", (1, 2, 3, 6, 16)), ("noul", (2,))):
                for k in counts:
                    question = (choice(k) if kind == "choice" else
                        {"type": kind, "instructions": "Rate.", "criteria": ["level"] * k}
                        if kind == "score" else {"type": "noul", "instructions": "True?"})
                    for pattern in ("normal", "equal", "one_ulp"):
                        values = np.linspace(-1, 2, k, dtype="<f4") if pattern == "normal" else np.zeros(k, dtype="<f4")
                        if pattern == "one_ulp" and k > 1: values[1] = np.float32(2 ** -23)
                        bits = np.full(18, -10000, dtype="<f4")
                        slots = list(range(k)) if k > 3 else ([0] if k == 1 else [0, 15] if k == 2 else [0, 3, 15])
                        bits[slots] = values
                        bits[16:] = np.asarray((0, 0 if pattern == "equal" else -2 ** -23), dtype="<f4")
                        mask = [int(i in slots) for i in range(16)]
                        qtype = {"choice": 0, "score": 1, "noul": 2}[kind]
                        actual = native.decode("q", question, bits, mask, qtype)
                        expected = oracle.call({"op": "decode", "question_id": "q", "question": question,
                            "candidate_u32": values.view("<u4").tolist(), "act_u32": bits[16:].view("<u4").tolist()})
                        check(f"decode_{kind}_{k}_{pattern}", actual["raw"] == expected["raw"] and actual["answer"] == expected["answer"],
                              raw=actual["raw"], answer=actual["answer"], temperature_u32=actual["temperature_u32"])
                        if pattern == "equal":
                            check(f"act_equal_half_{kind}_{k}", actual["raw"]["act_probability_u32"] == 0x3f000000)
                            if kind == "choice": check(f"tie_first_label_{k}", actual["raw"]["choice"] == "option-0")

            question, mask = choice(2), [1, 1] + [0] * 14
            valid = np.zeros(18, dtype="<f4")
            for label, bad in (("nan", np.nan), ("positive_inf", np.inf), ("negative_inf", -np.inf)):
                value = valid.copy(); value[15] = bad
                reject("reject_nonfinite_unused_" + label, "NUMERIC_ERROR", lambda value=value: native.decode("q", question, value, mask, 0))
            value = valid.copy(); value[:2] = [np.finfo(np.float32).max, -np.finfo(np.float32).max]
            reject("candidate_intermediate_overflow", "NUMERIC_ERROR", lambda: native.decode("q", question, value, mask, 0))
            value = valid.copy(); value[16:] = [np.finfo(np.float32).max, -np.finfo(np.float32).max]
            reject("ACT_intermediate_overflow", "NUMERIC_ERROR", lambda: native.decode("q", question, value, mask, 0))
            reject("decode_qtype_mismatch", "IDENTITY_ERROR", lambda: native.decode("q", question, valid, mask, 1))
            reject("decode_candidate_mismatch", "CANDIDATE_ERROR", lambda: native.decode("q", question, valid, [1] + [0] * 15, 0))
            check("decode_after_error_recovers", native.decode("q", question, valid, mask, 0)["status"] == "OK")

            for name, content in (("duplicate", '{"state":"", "state":"x", "questions":{}}'),
                                  ("nonfinite", '{"state":1e999, "questions":{}}')):
                path = args.output / (name + ".json"); path.write_text(content)
                reject("JSON_" + name, "JSON_ERROR", lambda path=path: load_json_strict(path))

            data = {"state": inputs[0]["state"], "questions": {**inputs[0]["questions"], "priority": choice(3)}}
            path = args.output / "prepare_input.json"; path.write_text(json.dumps(data))
            report["prepared_input_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
            prepared = args.output / "prepared"
            manifest = prepare_json_requests(path, native, prepared, 0x123456789abcdef0, 7)
            report["functional_stage_timing"] = manifest["functional_stage_timing"]
            report["H0_functional_elapsed_ns"] = [item["reference_h0_elapsed_ns"] for item in manifest["questions"]]
            expected = oracle.call({"op": "legacy-encode", **data})
            with GGUFWeights(args.model) as weights:
                ref = strict_reference()
                table = weights("tok_emb.weight")
                gamma = np.frombuffer(weights("emb_norm_w"), dtype="<f4")
                for index, item in enumerate(expected["questions"]):
                    folder = prepared / manifest["questions"][index]["folder"]
                    ids = np.asarray(item["token_ids"], dtype="<i4")
                    raw = np.stack([ref.embedding_row(table[int(token) * 1088:(int(token) + 1) * 1088]) for token in ids])
                    gold = ref.layernorm_many(raw, gamma)
                    check(f"frontend_H0_{index}", (folder / "H0.bin").read_bytes() == gold.tobytes(),
                          independent_reference_sha256=hashlib.sha256(gold.tobytes()).hexdigest())
                    req = decode_request((folder / "request.bin").read_bytes(), Identity(**manifest["identity"]))
                    check(f"frontend_request_{index}", req.markers == tuple(item["markers"]) and req.qtype == item["qtype"])
                    scenario = "B1_from_b0_S128" if index == 0 else "B1_from_b1_S128"
                    frozen = (args.frozen / scenario / "actual_logits18.bin").read_bytes()
                    result = decode_prepared(prepared, index, frozen, native)
                    check(f"frozen_tail_to_business_{index}", result["candidate_count"] == (2 if index == 0 else 3),
                          scope="frozen real logits with explicit synthetic question labels; no new full forward")

            manifest_path = prepared / "manifest.json"
            original = manifest_path.read_text()
            for label in ("source", "question", "generation", "path"):
                changed = json.loads(original)
                if label == "source": changed["source_json"]["state"] = "tampered"
                if label == "question": changed["questions"][0]["question"]["instructions"] = "tampered"
                if label == "generation": changed["questions"][0]["generation"] += 1
                if label == "path": changed["questions"][0]["folder"] = "../native"
                manifest_path.write_text(json.dumps(changed))
                reject("prepared_" + label + "_mismatch", "IDENTITY_ERROR",
                       lambda: decode_prepared(prepared, 0, bytes(72), native))
                manifest_path.write_text(original)
            reject("prepared_index", "FRAME_ERROR", lambda: decode_prepared(prepared, 2, bytes(72), native))
            reject("prepared_logit_length", "FRAME_ERROR", lambda: decode_prepared(prepared, 0, bytes(71), native))
            reject("multi_question_request_id_overflow", "IDENTITY_ERROR", lambda:
                   prepare_json_requests(path, native, args.output / "overflow_should_not_exist", (1 << 64) - 1, 1))
            check("overflow_no_partial_H0", not (args.output / "overflow_should_not_exist").exists())
            report["native_call_events"] = native.call_events

            report["status"] = "PASS_FRONTEND02"
            report["case_count"] = len(report["cases"])
            report["native_binary_sha256"] = native.binary_sha256
            print(f"M007_FRONTEND02_PASS checks={len(report['cases'])} native_baseline=1 exact128=1 reject129=1 business_decode=1 full_forward=NOT_RUN device=NOT_RUN", flush=True)
        return 0
    except Exception as error:
        report.update(status="FAIL", error=f"{type(error).__name__}: {error}", traceback=traceback.format_exc())
        print(report["error"], file=sys.stderr, flush=True)
        return 1
    finally:
        if oracle is not None: oracle.close()
        (args.output / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
