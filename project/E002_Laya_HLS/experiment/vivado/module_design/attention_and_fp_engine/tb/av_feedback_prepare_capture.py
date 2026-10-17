#!/usr/bin/env python3
"""Add read-only Q/K head-0 observations to the proven v4 V capture copy."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def replace_once(source: str, before: str, after: str) -> str:
    if source.count(before) != 1:
        raise ValueError(f"expected unique capture anchor: {before[:60]!r}")
    return source.replace(before, after, 1)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("prior_capture_sources", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    prior = args.prior_capture_sources.resolve()
    output = args.output.resolve()
    manifest_path = prior / "source_manifest.json"
    manifest = json.loads(manifest_path.read_text())
    if manifest["schema"] != "t2_widown_av_observation_sources_v2":
        raise ValueError("unexpected producer capture source schema")
    for name, expected in manifest["generated_sources"].items():
        if digest(Path(name)) != expected:
            raise ValueError(f"prior generated source changed: {name}")
    controller_path = prior / "full_forward_controller_t2_capture.cpp"
    testbench_path = prior / "persistent_cpu_full_csim_t2_capture_tb.cpp"
    controller = replace_once(controller_path.read_text(),
        '''    if (stage == 2 && layer == 0)
      checkpoint("t2_enc0_v_head0_source", final[0]);''',
        '''    if (stage == 2 && layer == 0) {
      checkpoint("t2_enc0_q_head0_source", final[0]);
      checkpoint("t2_enc0_k_head0_source", final[0]);
      checkpoint("t2_enc0_v_head0_source", final[0]);
    }''')
    testbench = testbench_path.read_text()
    testbench = replace_once(testbench,
        'if (label == "t2_enc0_v_head0_source") {',
        '''if (label == "t2_enc0_q_head0_source" ||
      label == "t2_enc0_k_head0_source" ||
      label == "t2_enc0_v_head0_source") {
    const unsigned plane = label == "t2_enc0_q_head0_source" ? 0 :
                           label == "t2_enc0_k_head0_source" ? 1 : 2;''')
    testbench = replace_once(testbench,
        'laya::qkv_address(2, 0, 0, uint16_t(row), uint8_t(d),',
        'laya::qkv_address(plane, 0, 0, uint16_t(row), uint8_t(d),')
    testbench = replace_once(testbench,
        'directory / "t2_enc0_v_head0_source.f32.bin";',
        'directory / (label + ".f32.bin");')
    testbench = replace_once(testbench,
        '"T2_PRODUCER_CAPTURE name=t2_enc0_v_head0_source"',
        '"T2_PRODUCER_CAPTURE name=" << label')
    testbench = replace_once(testbench,
        '" request=3 generation=1 rows=128 width=64 plane=V head=0"',
        '" request=3 generation=1 rows=128 width=64 plane=" << plane << " head=0"')
    output.mkdir(parents=True, exist_ok=False)
    controller_out = output / controller_path.name
    testbench_out = output / testbench_path.name
    controller_out.write_text(controller)
    testbench_out.write_text(testbench)
    result = {
        "schema": "av_feedback_qkv_capture_sources_v1",
        "purpose": "read-only same-checkpoint encoder0 head0 Q/K/V for request3 B1/S128",
        "prior_manifest": {"path": str(manifest_path), "sha256": digest(manifest_path)},
        "prior_sources": {str(controller_path): digest(controller_path),
                          str(testbench_path): digest(testbench_path)},
        "generated_sources": {str(controller_out): digest(controller_out),
                              str(testbench_out): digest(testbench_out)},
        "generator": {"path": str(Path(__file__).resolve()),
                      "sha256": digest(Path(__file__))},
        "numeric_gold_role": "none; actual producer BO observations only",
    }
    (output / "source_manifest.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("AV_FEEDBACK_QKV_CAPTURE_SOURCES_PREPARED")


if __name__ == "__main__":
    main()
