#!/usr/bin/env python3
"""Bind V6 source preparation without invoking CPU or EDA tools."""

from __future__ import annotations

import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import re


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
V5 = MODULE.parent / "v5"
RELEASE = MODULE.parents[1] / "reviewer_attention_v6_metadata_reset_source_preparation_release.json"


def digest(path: Path) -> dict[str, object]:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def main() -> None:
    release = json.loads(RELEASE.read_text())
    for expected in release["source_records"]:
        actual = digest(Path(expected["path"]))
        require(actual == expected, f"frozen source changed: {expected['path']}")

    for name, old in (
        ("source/attention_preloaded_abi.h", V5 / "source/attention_preloaded_abi.h"),
        ("tb/sha256_test_only.h", V5 / "tb/sha256_test_only.h"),
    ):
        require(digest(MODULE / name)["sha256"] == digest(old)["sha256"],
                f"copied V5 input changed: {name}")

    before = (V5 / "source/attention_preloaded_slice.cpp").read_text().splitlines(True)
    after = (MODULE / "source/attention_preloaded_slice.cpp").read_text().splitlines(True)
    diff = "".join(difflib.unified_diff(before, after,
                   fromfile="v5/source/attention_preloaded_slice.cpp",
                   tofile="v6_metadata_reset/source/attention_preloaded_slice.cpp"))
    require(diff, "top source has no V6 delta")
    diff_path = MODULE / "source/v5_to_v6_metadata_only.diff"
    diff_path.write_text(diff)

    top = "".join(after)
    start = top.index("void reset_metadata(")
    end = top.index("\nuint64_t wide(", start)
    initializer = top[start:end]
    require(top.count("#pragma HLS reset variable=metadata_initialized") == 1,
            "single reset pragma missing")
    require(top.index("if (!metadata_initialized)") < top.index("FullMemory memory{"),
            "metadata gate must precede memory binding")
    require(top.index("metadata_initialized = true;") < top.index("FullMemory memory{"),
            "metadata completion must precede memory binding")
    for forbidden in ("FullRuntime{}", "FullCache{}", "memset", "numeric_reset_",
                      "full_recycle_request", "full_soft_reset", "full_cache_",
                      "weight_q", "weight_scale", "weight_bias", "activation_q",
                      "activation_scale", "input_tile", "ps_tile", "gamma[",
                      "rope_table", "kv[", "score[", "av_partial", "fp_act_weight"):
        require(forbidden not in initializer,
                f"reset initializer references forbidden payload/helper: {forbidden}")
    require(re.search(r"extern \"C\" void attention_preloaded_test_only_clear_metadata_initialized\(\) \{\s*laya::full::metadata_initialized = false;\s*\}", top),
            "test-only hook must clear only the scalar")
    require("#if !defined(__SYNTHESIS__) && defined(D2_PRELOADED_RESET_TEST_HOOK)" in top,
            "test-only hook guard missing")

    config = (MODULE / "config.cfg").read_text()
    require(f"syn.file={MODULE / 'source/attention_preloaded_slice.cpp'}" in config,
            "V6 HLS top path missing")
    require(f"tb.file={MODULE / 'tb/test_attention_preloaded.cpp'}" in config,
            "V6 HLS TB path missing")
    require("-DD2_PRELOADED_RESET_TEST_HOOK" in config,
            "CSim top must expose CPU stimulus hook")

    cmake = (ROOT / "config/full_sources.cmake").read_text()
    official = re.findall(r"^  (hls/\S+\.cpp)$", cmake, re.MULTILINE)
    require(len(official) == 25 and len(set(official)) == 25 and
            official.count("hls/control/full_forward_controller.cpp") == 1,
            "official production source closure changed")

    fixture = V5 / "tb/fixture_preloaded"
    old_fixture = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision"
    package = ROOT / "build/model-attention-rtl-repair-20261008"
    inputs = [ROOT / name for name in official]
    inputs += [ROOT / "config/full_sources.cmake",
               ROOT / "tests/full_reference.py", RELEASE,
               V5 / "source/attention_preloaded_slice.cpp",
               V5 / "source/attention_preloaded_abi.h",
               V5 / "tb/test_attention_preloaded.cpp",
               V5 / "tb/sha256_test_only.h",
               V5 / "tb/generate_preloaded_fixture.py",
               old_fixture / "request.bin", old_fixture / "qkv_final.f32.bin",
               old_fixture / "attention_mask.u8.bin", old_fixture / "score.f32.bin",
               old_fixture / "probability.f32.bin", old_fixture / "av.f32.bin",
               old_fixture / "fixture_report.json", package / "manifest.json",
               package / "aux.bin", package / "laya_model_layout_generated.h"]
    inputs += sorted((ROOT / "include").glob("*.h"))
    inputs += sorted((ROOT / "hls").rglob("*.h"))
    inputs += sorted(fixture.iterdir())
    prepared = [MODULE / name for name in (
        "config.cfg", "source/attention_preloaded_slice.cpp",
        "source/attention_preloaded_abi.h", "source/run_preloaded_cpu.py",
        "source/design.md", "source/results.md", "source/metadata_field_checklist.md",
        "source/v5_to_v6_metadata_only.diff", "source/make_source_packet.py",
        "source/execution_plan.json",
        "tb/test_attention_preloaded.cpp", "tb/sha256_test_only.h",
        "rtl/README.md")]
    all_paths = sorted({p.resolve() for p in inputs})
    require(all(p.is_file() for p in all_paths + prepared), "packet input missing")
    packet = {
        "schema": "d2_attention_v6_metadata_reset_source_preparation_v1",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "status": "SOURCE_PREPARED_NO_CPU_CSIM_HLS_OR_RTL_EXECUTION",
        "authority": digest(RELEASE),
        "baseline_top": digest(V5 / "source/attention_preloaded_slice.cpp"),
        "source_diff": digest(diff_path),
        "official_production_translation_units": len(official),
        "official_production_paths": [str(ROOT / name) for name in official],
        "v5_fixture_root": str(fixture),
        "hls_config": digest(MODULE / "config.cfg"),
        "immutable_inputs": [digest(path) for path in all_paths],
        "prepared_files": [digest(path) for path in prepared],
        "execution": {"cpu_build": "not_run", "cpu": "not_run",
                      "csim": "not_run", "hls": "not_run",
                      "rtl_static": "not_run", "rtl_runtime": "not_run"},
        "review_obligations": [
            "review exact diff and every checklist field/default/bound",
            "review only scalar HLS reset and first-command dominance",
            "review no payload reset/store sweep in generated RTL",
            "review no new FullMemory/pointer escape",
            "separate guarded CPU, CSim, HLS and actual-pin RTL releases",
        ],
    }
    output = MODULE / "source/source_packet.json"
    output.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"V6_SOURCE_PACKET_PREPARED inputs={len(all_paths)} files={len(prepared)} "
          f"diff_bytes={diff_path.stat().st_size} packet_sha256={digest(output)['sha256']}")


if __name__ == "__main__":
    main()
