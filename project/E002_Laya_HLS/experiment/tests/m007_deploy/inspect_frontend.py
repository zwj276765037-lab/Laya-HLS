#!/usr/bin/env python3
"""Bounded source evidence for the actual native tokenizer/compatibility recipe."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assets", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    assets = json.loads(args.assets.read_text())
    assert assets["status"] == "ASSETS_VERIFIED"
    base = "reference/vendor/ggmlc/"
    paths = [base + "examples/laya/src/" + name + ".cpp"
             for name in ("recipe", "sequence", "engine", "questions")]
    paths += [base + "examples/laya/include/" + name + ".h"
              for name in ("recipe", "sequence", "questions")]
    paths += [base + "runtime/include/ggmlc/pipeline/tokenizer.h",
              base + "runtime/src/pipeline/tokenizer.cpp"]
    records = {}
    for name in paths:
        path = ROOT / name
        data = path.read_bytes()
        records[name] = {"sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}
    metadata = assets["gguf"]["metadata"]
    present = "ggmlc.decision" in metadata
    assert not present, "this evidence is specific to the verified compatibility model"
    source = (ROOT / (base + "examples/laya/src/sequence.cpp")).read_text().splitlines()
    report = {"schema": "m007-native-frontend-evidence-v1", "sources": records,
        "model_sha256": assets["model"]["whole_file_sha256"],
        "ggmlc_decision_present": present, "recipe_mode": "explicit_native_laya_compat",
        "qtype_mapping": {"Choice": 0, "Score": 1, "Noul": 2},
        "noul_candidates": 2,
        "model_metadata": {key: metadata[key] for key in metadata
            if key.startswith("laya.") or key.startswith("tokenizer.")},
        "sequence_resize_sites": [{"line": i + 1, "text": text.strip()}
                                  for i, text in enumerate(source) if ".resize(" in text],
        "production_strict_S128_frontend": "NOT_IMPLEMENTED",
        "business_decoder": "existing_native_engine_decode_answer_identified_not_adapted",
        "scope": "source_and_model_identity_only; not a new native runtime execution"}
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print("M007_FRONTEND_IDENTITY_PASS sources=9 ggmlc_decision=absent recipe=laya_compat strict_S128_frontend=NOT_IMPLEMENTED")


if __name__ == "__main__":
    main()
