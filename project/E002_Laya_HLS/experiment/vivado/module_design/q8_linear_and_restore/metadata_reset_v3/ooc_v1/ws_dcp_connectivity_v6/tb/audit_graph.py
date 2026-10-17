#!/usr/bin/env python3
"""Check v4 graph and semantic-property completeness; never certify Ws mapping."""

from __future__ import annotations

import argparse
import csv
import json
from collections import Counter, defaultdict
from pathlib import Path
import sys


BANKS = ("ws_U", "ws_8_U", "ws_9_U", "ws_10_U", "ws_11_U",
         "ws_12_U", "ws_13_U", "ws_14_U")
KNOWN_PRIMITIVES = frozenset((
    "RAMB36E2", "RAMB18E2", "URAM288", "LUT1", "LUT2", "LUT3", "LUT4",
    "LUT5", "LUT6", "MUXF7", "MUXF8", "MUXF9", "FDRE", "FDCE", "FDSE",
    "FDPE", "VCC", "GND", "CARRY8", "RAM128X1D", "RAM32X1D", "RAM64X1D",
))
CONTRACT = Path(__file__).resolve().parents[1] / "source/semantic_property_contract.json"
DRIVER_KINDS = frozenset((
    "SELECTED_PRIMITIVE", "EXTERNAL_DRIVER", "CONSTANT_ZERO", "CONSTANT_ONE",
    "TOP_INPUT", "HIERARCHY_ALIAS", "UNKNOWN_OWNER",
))
HEADERS = {
    "cells": "cell_id bank name_hex parent_hex ref_hex primitive_type_hex is_primitive",
    "properties": "cell_id property_hex value_hex read_status",
    "pins": "pin_id cell_id name_hex ref_pin_hex direction net_id",
    "boundaries": "bank signal bit pin_id net_id status",
    "nets": "net_id canonical_name_hex constant segments selected_pins active_drivers external_drivers",
    "net_segments": "net_id name_hex type_hex",
    "net_drivers": "net_id kind name_hex owner_hex owner_ref_hex selected_bank",
    "issues": "code bank_hex object_hex detail_hex",
    "coverage": "bank cells primitives pins boundaries status",
    "global_dsp": "name_hex parent_hex ref_hex",
    "clock_properties": "clock_hex property_hex value_hex read_status",
}


def unhex(value: str) -> str:
    return bytes.fromhex(value).decode("utf-8")


def rows(root: Path, table: str):
    path = root / f"{table}.tsv"
    with path.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        expected = HEADERS[table].split()
        if reader.fieldnames != expected:
            raise ValueError(f"{path}: header {reader.fieldnames!r} != {expected!r}")
        for number, row in enumerate(reader, 2):
            if None in row or any(value is None for value in row.values()):
                raise ValueError(f"{path}:{number}: malformed TSV row")
            yield row


def expected_boundaries():
    out = set()
    for bank in BANKS:
        for signal in ("address0", "address1"):
            out.update((bank, signal, str(bit)) for bit in range(15))
        for signal in ("d1", "q0"):
            out.update((bank, signal, str(bit)) for bit in range(16))
        out.update((bank, signal, "-1") for signal in
                   ("ce0", "ce1", "we1", "reset", "clk"))
    return out


def audit(root: Path, *, allow_property_gaps_for_explicit_join: bool = False) -> dict:
    errors: list[str] = []
    contract = json.loads(CONTRACT.read_text())
    required = {item["reference"]: set(item["required_property_names"])
                for item in contract["primitive_contracts"]}
    if set(required) != KNOWN_PRIMITIVES or sum(map(len, required.values())) != 348:
        raise ValueError("semantic property contract cardinality mismatch")
    cells = {}
    cell_names = {}
    bank_cells = Counter()
    bank_primitives = Counter()
    roots = set()
    for row in rows(root, "cells"):
        cid, bank, name = row["cell_id"], row["bank"], unhex(row["name_hex"])
        parent, ref = unhex(row["parent_hex"]), unhex(row["ref_hex"])
        unhex(row["primitive_type_hex"])
        if cid in cells:
            errors.append(f"duplicate cell id {cid}")
        if name in cell_names:
            errors.append(f"duplicate cell name {name}")
        cell_names[name] = cid
        if bank not in BANKS or not (name == bank or name.startswith(bank + "/")):
            errors.append(f"cell bank ownership mismatch {cid}: {bank}/{name}")
        if parent != name.rpartition("/")[0]:
            errors.append(f"cell parent mismatch {cid}")
        if name == bank:
            roots.add(bank)
        primitive = row["is_primitive"] == "1"
        if row["is_primitive"] not in ("0", "1"):
            errors.append(f"invalid primitive flag {cid}")
        cells[cid] = (bank, name, ref, primitive)
        bank_cells[bank] += 1
        if primitive:
            bank_primitives[bank] += 1
            if ref not in KNOWN_PRIMITIVES:
                errors.append(f"primitive semantics not bound {cid}:{ref}")
    if roots != set(BANKS):
        errors.append(f"bank roots differ: {sorted(roots)}")

    primitive_properties = defaultdict(set)
    seen_properties = set()
    property_rows = 0
    property_gap_count = 0
    for row in rows(root, "properties"):
        cid, key = row["cell_id"], unhex(row["property_hex"])
        value = unhex(row["value_hex"])
        property_rows += 1
        if cid not in cells or not cells[cid][3]:
            errors.append(f"property belongs to missing/nonprimitive cell {cid}")
        if (cid, key) in seen_properties:
            errors.append(f"duplicate primitive property {cid}:{key}")
        seen_properties.add((cid, key))
        primitive_properties[cid].add(key)
        status = row["read_status"]
        if status not in ("OK", "MISSING") or (status == "MISSING" and value):
            errors.append(f"terminal property status {cid}:{key}:{status}")
        if status != "OK" or not value:
            property_gap_count += 1
            if not allow_property_gaps_for_explicit_join:
                errors.append(f"required property gap {cid}:{key}:{row['read_status']}")
    for cid, (_, _, ref, primitive) in cells.items():
        if primitive and ref in required:
            missing = required[ref] - primitive_properties[cid]
            extra = primitive_properties[cid] - required[ref]
            for name in sorted(missing):
                property_gap_count += 1
                if not allow_property_gaps_for_explicit_join:
                    errors.append(f"required property absent {cid}:{ref}/{name}")
            for name in sorted(extra):
                errors.append(f"property outside reviewed contract {cid}:{ref}/{name}")
        elif primitive and primitive_properties[cid]:
            errors.append(f"unknown primitive has unreviewed property set {cid}:{ref}")

    ledger = root / "phase_ledger.tsv"
    if ledger.exists():
        with ledger.open(newline="", encoding="utf-8") as stream:
            phases = list(csv.DictReader(stream, delimiter="\t"))
    else:
        phases = []
    if not phases or set(phases[0]) != {"timestamp_utc", "phase", "event", "count", "detail_hex"}:
        errors.append("phase ledger missing or malformed")
    for phase in phases:
        unhex(phase["detail_hex"])
    if not any(p["phase"] == "output" and p["event"] == "FLUSHED" for p in phases):
        errors.append("normalized table flush marker missing")
    if not any(p["phase"] == "extraction" and p["event"] == "COMPLETE" for p in phases):
        errors.append("extraction completion marker missing")

    nets = {}
    for row in rows(root, "nets"):
        nid = row["net_id"]
        if nid in nets:
            errors.append(f"duplicate net id {nid}")
        canonical = unhex(row["canonical_name_hex"])
        if row["constant"] not in ("UNKNOWN", "0", "1"):
            errors.append(f"invalid constant marker {nid}")
        nets[nid] = (canonical, row)
    segments = defaultdict(list)
    alias_owner = {}
    for row in rows(root, "net_segments"):
        nid, name = row["net_id"], unhex(row["name_hex"])
        unhex(row["type_hex"])
        if nid not in nets:
            errors.append(f"segment refers to missing net {nid}")
        if name in alias_owner and alias_owner[name] != nid:
            errors.append(f"net segment shared by {alias_owner[name]} and {nid}: {name}")
        alias_owner[name] = nid
        segments[nid].append(name)
    for nid, (canonical, row) in nets.items():
        names = segments[nid]
        if not names or canonical != min(names) or len(names) != int(row["segments"]):
            errors.append(f"net segment/canonical mismatch {nid}")

    pins = {}
    pins_by_name = {}
    pin_names = set()
    net_pins = Counter()
    net_banks = defaultdict(set)
    bank_pins = Counter()
    for row in rows(root, "pins"):
        pid, cid, nid = row["pin_id"], row["cell_id"], row["net_id"]
        name = unhex(row["name_hex"])
        unhex(row["ref_pin_hex"])
        if pid in pins or name in pin_names:
            errors.append(f"duplicate pin id/name {pid}:{name}")
        pin_names.add(name)
        if cid not in cells:
            errors.append(f"pin refers to missing cell {pid}:{cid}")
            continue
        bank = cells[cid][0]
        if not name.startswith(cells[cid][1] + "/"):
            errors.append(f"pin owner/name mismatch {pid}")
        if row["direction"] not in ("IN", "OUT", "INOUT"):
            errors.append(f"unknown pin direction {pid}:{row['direction']}")
        if nid not in nets and nid not in ("UNCONNECTED", "UNRESOLVED"):
            errors.append(f"pin refers to missing net {pid}:{nid}")
        pins[pid] = (cid, bank, name, nid)
        pins_by_name[name] = (pid, row["direction"])
        bank_pins[bank] += 1
        if nid in nets:
            net_pins[nid] += 1
            net_banks[nid].add(bank)
    for nid, (_, row) in nets.items():
        if net_pins[nid] != int(row["selected_pins"]):
            errors.append(f"selected pin count mismatch {nid}")

    boundary_keys = set()
    bank_boundaries = Counter()
    for row in rows(root, "boundaries"):
        key = (row["bank"], row["signal"], row["bit"])
        if key in boundary_keys:
            errors.append(f"duplicate logical boundary {key}")
        boundary_keys.add(key)
        pid = row["pin_id"]
        if pid not in pins:
            errors.append(f"boundary missing pin {key}:{pid}")
            continue
        _, owner_bank, name, nid = pins[pid]
        suffix = row["signal"] + (f"[{row['bit']}]" if row["bit"] != "-1" else "")
        if owner_bank != row["bank"] or name != f"{row['bank']}/{suffix}":
            errors.append(f"boundary owner/name mismatch {key}")
        if row["net_id"] != nid or nid not in nets or row["status"] != "PRESENT":
            errors.append(f"boundary net/status mismatch {key}")
        bank_boundaries[row["bank"]] += 1
    if boundary_keys != expected_boundaries():
        errors.append(f"boundary set differs: missing={len(expected_boundaries()-boundary_keys)} extra={len(boundary_keys-expected_boundaries())}")

    net_active = Counter()
    net_external = Counter()
    net_constants = defaultdict(set)
    seen_drivers = set()
    for row in rows(root, "net_drivers"):
        nid, kind, name = row["net_id"], row["kind"], unhex(row["name_hex"])
        owner, owner_ref = unhex(row["owner_hex"]), unhex(row["owner_ref_hex"])
        owner_bank = unhex(row["selected_bank"])
        if nid not in nets:
            errors.append(f"driver refers to missing net {nid}")
        if kind not in DRIVER_KINDS:
            errors.append(f"unknown driver kind {nid}:{kind}")
        if (nid, kind, name) in seen_drivers:
            errors.append(f"duplicate net driver {nid}:{name}")
        seen_drivers.add((nid, kind, name))
        if kind == "UNKNOWN_OWNER":
            errors.append(f"driver owner unresolved {nid}:{name}")
        if kind == "SELECTED_PRIMITIVE":
            cid = cell_names.get(owner)
            if (cid is None or not cells[cid][3] or cells[cid][2] != owner_ref or
                    cells[cid][0] != owner_bank):
                errors.append(f"selected driver owner mismatch {nid}:{name}")
            if name not in pins_by_name:
                errors.append(f"selected driver pin absent {nid}:{name}")
            else:
                pid, direction = pins_by_name[name]
                if (direction != "OUT" or pins[pid][0] != cid or pins[pid][3] != nid):
                    errors.append(f"selected driver direction/net mismatch {nid}:{name}")
        if kind == "EXTERNAL_DRIVER":
            if not owner or not owner_ref or owner in cell_names or owner_bank:
                errors.append(f"external driver ownership mismatch {nid}:{name}")
        if kind in ("CONSTANT_ZERO", "CONSTANT_ONE"):
            required = "GND" if kind == "CONSTANT_ZERO" else "VCC"
            if not owner or owner_ref != required:
                errors.append(f"constant driver ref mismatch {nid}:{name}")
            if owner in cell_names and name not in pins_by_name:
                errors.append(f"selected constant driver pin absent {nid}:{name}")
        if kind == "TOP_INPUT" and (owner or owner_ref or owner_bank):
            errors.append(f"top input has a cell owner {nid}:{name}")
        if kind == "HIERARCHY_ALIAS" and not owner:
            errors.append(f"hierarchy alias owner absent {nid}:{name}")
        if kind in ("SELECTED_PRIMITIVE", "EXTERNAL_DRIVER", "CONSTANT_ZERO",
                    "CONSTANT_ONE", "TOP_INPUT"):
            net_active[nid] += 1
        if kind in ("EXTERNAL_DRIVER", "TOP_INPUT"):
            net_external[nid] += 1
        if kind == "CONSTANT_ZERO":
            net_constants[nid].add("0")
        if kind == "CONSTANT_ONE":
            net_constants[nid].add("1")
    for nid, (_, row) in nets.items():
        if net_active[nid] != int(row["active_drivers"]) or net_external[nid] != int(row["external_drivers"]):
            errors.append(f"driver count mismatch {nid}")
        if net_active[nid] != 1:
            errors.append(f"net lacks unique verified active driver {nid}:{net_active[nid]}")
        if row["constant"] != "UNKNOWN" and net_constants[nid] != {row["constant"]}:
            errors.append(f"constant driver evidence mismatch {nid}")
        if row["constant"] == "UNKNOWN" and net_constants[nid]:
            errors.append(f"unknown net has constant driver {nid}")

    coverage = {}
    for row in rows(root, "coverage"):
        bank = row["bank"]
        if bank in coverage:
            errors.append(f"duplicate coverage bank {bank}")
        coverage[bank] = row
        if (int(row["cells"]) != bank_cells[bank] or
                int(row["primitives"]) != bank_primitives[bank] or
                int(row["pins"]) != bank_pins[bank] or
                int(row["boundaries"]) != bank_boundaries[bank]):
            errors.append(f"coverage count mismatch {bank}")
    if set(coverage) != set(BANKS):
        errors.append("coverage lacks one or more banks")
    issue_codes = Counter(row["code"] for row in rows(root, "issues"))
    extracted_issues = sum(issue_codes.values())
    for row in rows(root, "global_dsp"):
        for key in ("name_hex", "parent_hex", "ref_hex"):
            unhex(row[key])
    for row in rows(root, "clock_properties"):
        for key in ("clock_hex", "property_hex", "value_hex"):
            unhex(row[key])
        if row["read_status"] != "OK":
            errors.append("clock property read failure")
    if allow_property_gaps_for_explicit_join:
        disallowed = {name: count for name, count in issue_codes.items()
                      if name != "REQUIRED_PROPERTY_GAP"}
        if disallowed:
            errors.append(f"extractor recorded non-property issue(s): {disallowed}")
        if issue_codes["REQUIRED_PROPERTY_GAP"] != property_gap_count:
            errors.append("extractor property-gap count differs from raw property table")
    elif extracted_issues:
        errors.append(f"extractor recorded {extracted_issues} issue(s)")
    return {
        "schema": "q8_ws_compact_graph_structural_audit_v1",
        "status": ("STRUCTURAL_PASS_SEMANTIC_JOIN_PENDING" if
                   allow_property_gaps_for_explicit_join and not errors else
                   "STRUCTURAL_PASS_PROOF_HELD" if not errors else
                   "STRUCTURAL_FAIL_PROOF_HELD"),
        "banks": len(BANKS), "cells": len(cells), "primitives": sum(bank_primitives.values()),
        "pins": len(pins), "nets": len(nets), "boundary_pins": len(boundary_keys),
        "cross_bank_net_components_for_review": [
            {"net_id": nid, "banks": sorted(banks)} for nid, banks in sorted(net_banks.items())
            if len(banks) > 1
        ],
        "extractor_issues": extracted_issues,
        "semantic_property_rows": property_rows,
        "semantic_property_gap_count": property_gap_count,
        "phase_ledger_rows": len(phases),
        "errors": errors[:200], "error_count": len(errors),
        "capacity_and_high_address_acceptance": "HELD_REQUIRES_INDEPENDENT_EXHAUSTIVE_MAPPING",
        "timing_board_acceptance": "NOT_ESTABLISHED",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report_dir", type=Path)
    parser.add_argument("--output", type=Path,
                        help="Optional fresh JSON result path; default prints to stdout")
    args = parser.parse_args()
    result = audit(args.report_dir)
    rendered = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        if args.output.exists():
            parser.error(f"output path must be fresh: {args.output}")
        args.output.write_text(rendered)
    else:
        sys.stdout.write(rendered)
    return 0 if result["error_count"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
