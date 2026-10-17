#!/usr/bin/env python3
"""Materialize a separate adapted-domain suite from literal raw inputs and R0 reference."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import struct
from fractions import Fraction
from pathlib import Path

import original_r0_reference as r0


HERE = Path(__file__).resolve().parent
MANIFEST = HERE / "vector_manifest.json"
REFERENCE = HERE / "original_r0_reference.py"
ROUTE = {"D_ZERO": 0, "X_ZERO": 1, "SMALL_Q_ZERO": 1,
         "NORMAL_FP": 2, "SCALED_FP": 3}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def word(text: str) -> int:
    if len(text) != 8 or any(char not in "0123456789abcdefABCDEF" for char in text):
        raise ValueError(f"not an eight-digit raw word: {text}")
    return int(text, 16)


def case_id(text: str) -> str:
    if not text or not text.replace("_", "").isalnum():
        raise ValueError(f"invalid case id: {text}")
    return text


def expand_groups(manifest: dict) -> list[tuple[str, list[int], str]]:
    scorer = manifest["accepted_scorer_input"]
    scorer_path = Path(scorer["path"])
    data = scorer_path.read_bytes()
    if len(data) != scorer["bytes"] or sha(scorer_path) != scorer["sha256"]:
        raise RuntimeError("accepted Scorer input identity changed")
    start = scorer["group_byte_offset"]
    if scorer["group_bytes"] != 128 or start < 0 or start + 128 > len(data):
        raise RuntimeError("accepted Scorer group slice invalid")
    scorer_lanes = list(struct.unpack("<32I", data[start:start + 128]))
    expanded = []
    for row in manifest["groups"]:
        identifier = case_id(row["id"])
        kind = row.get("kind", "literal")
        if kind == "accepted_scorer":
            expanded.append((identifier, scorer_lanes, kind))
            continue
        fill = word(row["fill"])
        if kind == "sweep_nonfinite":
            value = word(row["value"])
            if r0.is_finite(value):
                raise RuntimeError("nonfinite sweep must use a nonfinite raw word")
            for lane in range(32):
                lanes = [fill] * 32
                lanes[lane] = value
                expanded.append((f"{identifier}_{lane:02d}", lanes, kind))
            continue
        if kind != "literal":
            raise ValueError(f"unknown group kind: {kind}")
        lanes = [fill] * 32
        for key, value in row.get("set", {}).items():
            lane = int(key)
            if not 0 <= lane < 32:
                raise ValueError(f"lane index out of range: {key}")
            lanes[lane] = word(value)
        expanded.append((identifier, lanes, kind))
    if len({row[0] for row in expanded}) != len(expanded):
        raise RuntimeError("duplicate expanded group id")
    return expanded


def packed_words(words: list[int], width: int) -> str:
    value = sum(item << (width * index) for index, item in enumerate(words))
    return f"{value:0{(len(words) * width + 3) // 4}x}"


def group_call(identifier: str, lanes: list[int], expected: dict) -> str:
    lane_by_index = {item["index"]: item for item in expected["lane_records"]}
    routes = [ROUTE[lane_by_index[i]["route"]] if i in lane_by_index else 0 for i in range(32)]
    products = [lane_by_index[i]["product_bits"] if i in lane_by_index and
                lane_by_index[i]["product_bits"] is not None else 0 for i in range(32)]
    product_mask = sum(1 << i for i in range(32) if i in lane_by_index and
                       lane_by_index[i]["product_bits"] is not None)
    q = [(item & 0xFF) for item in expected["q"]] if expected["q"] is not None else [0] * 32
    d = expected["d_bits"] if expected["d_bits"] is not None else 0xFFFFFFFF
    reciprocal = expected["reciprocal_bits"] if expected["reciprocal_bits"] is not None else 0xFFFFFFFF
    amax = expected["amax_bits"] if expected["amax_bits"] is not None else 0xFFFFFFFF
    saved = expected["saved_half"] if expected["saved_half"] is not None else 0xFFFF
    bad = expected["bad_element"] if expected["bad_element"] is not None else -1
    bad_literal = f"-32'sd{-bad}" if bad < 0 else f"32'sd{bad}"
    zero = int(bool(expected["d_zero_reciprocal"]))
    return (
        f'    run_group("{identifier}", 1024\'h{packed_words(lanes, 32)}, '
        f"32'h{amax:08x}, 32'h{d:08x}, 32'h{reciprocal:08x}, "
        f"16'h{saved:04x}, 1'b{zero}, 32'd{expected['status']}, "
        f"{bad_literal}, 1'b{int(expected['commit'])}, "
        f"256'h{packed_words(q, 8)}, 64'h{packed_words(routes, 2)}, "
        f"1024'h{packed_words(products, 32)}, 32'h{product_mask:08x});"
    )


def reciprocal_case(d_bits: int) -> dict:
    d_zero = d_bits & r0.F32_ABS_MASK == 0
    if d_zero:
        return {"d_bits": d_bits, "reciprocal_bits": 0, "divider_input_bits": 0,
                "normalized_divider_result_bits": 0, "d_zero_reciprocal": True,
                "d_zero_quantization": True, "normalized": False}
    if (d_bits & r0.F32_EXP_MASK) == 0:
        divider_input = r0.f32(r0.signed_rational(d_bits) * (1 << 24))
        normalized = True
    else:
        divider_input = d_bits
        normalized = False
    result = r0.f32_div_bits(0x3F800000, divider_input)
    reciprocal = r0.f32_div_bits(0x3F800000, d_bits)
    return {"d_bits": d_bits, "reciprocal_bits": reciprocal,
            "divider_input_bits": divider_input,
            "normalized_divider_result_bits": result,
            "d_zero_reciprocal": False, "d_zero_quantization": False,
            "normalized": normalized}


def restore_route(ps: int, bias: int) -> int:
    if ps == 0:
        return 0
    if ps == 0x80000000:
        return 3
    if (bias & r0.F32_ABS_MASK) < 0x00800000:
        return 1
    return 2


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output_dir", type=Path, help="fresh output directory for a separately released CPU run")
    args = parser.parse_args()
    out = args.output_dir.resolve()
    if out.exists():
        raise RuntimeError(f"fresh output directory required: {out}")
    manifest = json.loads(MANIFEST.read_text())
    if manifest["schema"] != "q8_r0_finite_domain_vector_source_v1":
        raise RuntimeError("unexpected vector source schema")
    lines = ["// Generated from vector_manifest.json using independent exact-rational R0 reference."]
    groups = []
    for identifier, lanes, kind in expand_groups(manifest):
        expected = r0.original_r0_group(lanes)
        groups.append({"id": identifier, "kind": kind,
                       "lanes_hex": [f"{bits:08x}" for bits in lanes], "expected": expected})
        lines.append(group_call(identifier, lanes, expected))
    reciprocals = []
    for raw in manifest["scalar_reciprocal_d"]:
        d = word(raw)
        row = reciprocal_case(d)
        reciprocals.append(row)
        lines.append(f"    run_recip_scalar(32'h{d:08x}, 32'h{row['divider_input_bits']:08x}, "
                     f"32'h{row['normalized_divider_result_bits']:08x}, "
                     f"32'h{row['reciprocal_bits']:08x}, 1'b{int(row['normalized'])}, "
                     f"1'b{int(row['d_zero_reciprocal'])});")
    halves = []
    for raw in manifest["scalar_half_d"]:
        d = word(raw)
        saved = r0.half_from_f32_bits(d)
        halves.append({"d_bits": d, "saved_half": saved})
        lines.append(f"    run_half_scalar(32'h{d:08x}, 16'h{saved:04x});")
    restore = []
    for row in manifest["restore"]:
        identifier = case_id(row["id"])
        kind = row.get("kind", "literal_ps")
        if kind == "dot_half_extreme":
            ps = r0.original_r0_restore_ps(
                int(row["dot"]), int(row["half_a"], 16),
                int(row["half_b"], 16), int(row["groups"]))
        elif kind == "literal_ps":
            ps = word(row["ps"])
        else:
            raise RuntimeError(f"unknown restore kind: {kind}")
        bias = word(row["bias"])
        route = restore_route(ps, bias)
        outside = bool(row.get("expect_domain_rejection", False))
        if outside != (route == 3):
            raise RuntimeError(f"restore domain classification mismatch: {identifier}")
        expected = None if outside else r0.original_r0_bias_add(ps, bias)
        restore.append({"id": identifier, "kind": kind,
                        "dot_half_source": {key: row[key] for key in
                                            ("dot", "half_a", "half_b", "groups")}
                        if kind == "dot_half_extreme" else None,
                        "ps_bits": ps, "bias_bits": bias,
                        "route": route, "expected_bits": expected,
                        "expect_domain_rejection": outside})
        lines.append(f'    run_restore("{identifier}", 32\'h{ps:08x}, 32\'h{bias:08x}, '
                     f"2'd{route}, 32'h{expected if expected is not None else 0:08x});")
    lines.append(f"    expected_group_cases = {len(groups)};")
    lines.append(f"    expected_scalar_cases = {len(reciprocals) + len(halves)};")
    lines.append(f"    expected_restore_cases = {len(restore)};")
    include_text = "\n".join(lines) + "\n"
    smoke = {"div": r0.f32_div_bits(0x3F800000, 0x3F800000),
             "mul2": r0.f32_mul_bits(0x3F800000, 0x3F800000),
             "mul3": r0.f32_mul_bits(0x3F800000, 0x3F800000),
             "add": r0.f32_add_bits(0x3F800000, 0x3F800000),
             "cmp1_eq": 1, "cmp2_eq": 1,
             "sitofp": r0.f32(Fraction(1))}
    table = {"schema": "q8_r0_finite_domain_generated_cases_v1",
             "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
             "status": "REFERENCE_EXPECTATIONS_GENERATED_NOT_RTL_VERIFIED",
             "vector_source_sha256": sha(MANIFEST), "independent_reference_sha256": sha(REFERENCE),
             "generated_include_sha256": hashlib.sha256(include_text.encode()).hexdigest(),
             "accepted_scorer_input_sha256": manifest["accepted_scorer_input"]["sha256"],
             "normal_wrapper_smoke": smoke,
             "groups": groups, "scalar_reciprocal": reciprocals,
             "scalar_half": halves, "restore": restore}
    out.mkdir(parents=True)
    (out / "case_table.json").write_text(json.dumps(table, indent=2) + "\n")
    (out / "generated_cases.svh").write_text(include_text)
    print(f"Q8_R0_VECTOR_SOURCE_MATERIALIZED groups={len(groups)} scalar={len(reciprocals)+len(halves)} restore={len(restore)}")


if __name__ == "__main__":
    main()
