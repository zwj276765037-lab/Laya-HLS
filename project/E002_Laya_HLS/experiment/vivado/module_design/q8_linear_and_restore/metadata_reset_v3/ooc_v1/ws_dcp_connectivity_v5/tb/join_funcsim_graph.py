#!/usr/bin/env python3
"""Source-only structural and semantic join; actual invocation needs a new gate.

The default entrypoint never opens reports. Import bind() for synthetic cases.
"""

from __future__ import annotations

from collections import defaultdict
import hashlib
import json
from pathlib import Path
import re
import sys

from audit_graph import BANKS, audit, rows, unhex
from funcsim_structure import (Cursor, Expanded, Literal, Token, Unsupported,
                               lex, parse_literal, parse_range, read_export,
                               split_top)

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "source/semantic_property_contract.json"
REQUIRED_RAM_INVERSIONS = (
    "IS_CLKARDCLK_INVERTED", "IS_CLKBWRCLK_INVERTED",
    "IS_ENARDEN_INVERTED", "IS_ENBWREN_INVERTED",
    "IS_RSTRAMARSTRAM_INVERTED", "IS_RSTRAMB_INVERTED",
    "IS_RSTREGARSTREG_INVERTED", "IS_RSTREGB_INVERTED")
BUS_BIT = re.compile(r"^(.+)\[(\d+)\]$")


def identity(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def unisim_port_signature(entry: dict) -> dict[str, dict]:
    """Read only pin shape/direction from the hash-bound UNISIM declaration."""
    source = entry["semantics_file"]
    path = Path(source["path"])
    if identity(path) != source:
        raise Unsupported(f"UNISIM source identity drift: {path}")
    # The bound files use preprocessor conditionals only around parameters and
    # simulation bodies. They are not used to infer any actual parameter value.
    contents = "\n".join(line for line in path.read_text(encoding="ascii").splitlines()
                         if not line.lstrip().startswith("`"))
    reference = entry["reference"]
    match = re.search(r"^\s*module\s+" + re.escape(reference) + r"\b", contents, re.MULTILINE)
    if match is None:
        raise Unsupported(f"missing UNISIM declaration {reference}")
    # Source identities make this finite header extraction exact. Its closing
    # semicolon is checked by the structural token parser below.
    end = contents.find(";", match.start())
    if end < 0:
        raise Unsupported(f"incomplete UNISIM declaration {reference}")
    cursor = Cursor(lex(contents[match.start():end + 1]))
    cursor.expect("module")
    if cursor.name() != reference:
        raise Unsupported(f"UNISIM declaration name mismatch {reference}")
    if cursor.peek() == "#":
        cursor.take()
        cursor.balanced("(", ")")
    header = cursor.balanced("(", ")")
    cursor.expect(";")
    if cursor.peek():
        raise Unsupported(f"extra UNISIM header tokens {reference}")
    signature = {}
    non_ansi = []
    for part in split_top(header, ","):
        port = Cursor(part)
        direction = port.peek()
        if direction not in ("input", "output", "inout"):
            if len(part) != 1:
                raise Unsupported(f"malformed non-ANSI UNISIM port in {reference}")
            non_ansi.append(port.name())
            continue
        port.take()
        while port.peek() in ("wire", "reg", "tri", "logic", "signed"):
            port.take()
        indices = parse_range(port)
        name = port.name()
        if port.peek() or name in signature:
            raise Unsupported(f"duplicate/malformed UNISIM port {reference}/{name}")
        signature[name] = {"direction": {"input": "IN", "output": "OUT", "inout": "INOUT"}[direction],
                           "indices": indices if indices is not None else [0],
                           "scalar": indices is None}
    if non_ansi:
        if signature or len(non_ansi) != len(set(non_ansi)):
            raise Unsupported(f"mixed or duplicate UNISIM port syntax {reference}")
        body = contents[end + 1:contents.find("endmodule", end + 1)]
        for match in re.finditer(r"(?m)^\s*(?:input|output|inout)\b[^;]*;", body):
            port = Cursor(lex(match.group()))
            direction = port.take().value
            while port.peek() in ("wire", "reg", "tri", "logic", "signed"):
                port.take()
            indices = parse_range(port)
            while True:
                name = port.name()
                if name not in non_ansi or name in signature:
                    raise Unsupported(f"unexpected/duplicate UNISIM port {reference}/{name}")
                signature[name] = {
                    "direction": {"input": "IN", "output": "OUT", "inout": "INOUT"}[direction],
                    "indices": indices if indices is not None else [0],
                    "scalar": indices is None}
                if port.peek() != ",":
                    break
                port.take()
            port.expect(";")
            if port.peek():
                raise Unsupported(f"malformed UNISIM port declaration {reference}")
        if set(signature) != set(non_ansi):
            raise Unsupported(f"incomplete UNISIM port declarations {reference}")
    if not signature:
        raise Unsupported(f"empty UNISIM pin signature {reference}")
    return signature


def comparable(literal: Literal) -> tuple:
    if literal.kind == "integer":
        return ("integer", int(literal.value))
    if literal.kind == "string":
        return ("string", str(literal.value))
    raise Unsupported("unknown parameter kind")


def dcp_literal(raw: str) -> Literal:
    if raw == "":
        raise Unsupported("empty DCP property")
    token = Token(raw, 0, len(raw.encode("ascii")))
    if raw.startswith('"'):
        return parse_literal(token)
    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", raw):
        return parse_literal(token, allow_bare_word=True)
    return parse_literal(token)


def graph_tables(root: Path) -> tuple[dict, dict, dict, dict, dict, dict]:
    cells = {}
    by_name = {}
    for row in rows(root, "cells"):
        cid = row["cell_id"]
        name = unhex(row["name_hex"])
        if cid in cells or name in by_name:
            raise Unsupported(f"duplicate DCP cell {cid}/{name}")
        record = {"id": cid, "bank": row["bank"], "name": name,
                  "reference": unhex(row["ref_hex"]),
                  "primitive": row["is_primitive"] == "1"}
        cells[cid] = record
        by_name[name] = record
    pins = defaultdict(list)
    for row in rows(root, "pins"):
        if row["cell_id"] not in cells:
            raise Unsupported(f"orphan DCP pin {row['pin_id']}")
        pins[row["cell_id"]].append({"id": row["pin_id"],
             "name": unhex(row["name_hex"]), "ref_pin": unhex(row["ref_pin_hex"]),
             "direction": row["direction"], "net": row["net_id"]})
    boundaries = defaultdict(dict)
    for row in rows(root, "boundaries"):
        key = (row["signal"] if row["bit"] == "-1" else
               f"{row['signal']}[{row['bit']}]")
        if key in boundaries[row["bank"]]:
            raise Unsupported(f"duplicate DCP boundary {row['bank']}/{key}")
        boundaries[row["bank"]][key] = row["net_id"]
    nets = {}
    for row in rows(root, "nets"):
        if row["net_id"] in nets:
            raise Unsupported(f"duplicate DCP net {row['net_id']}")
        nets[row["net_id"]] = row["constant"]
    props = defaultdict(dict)
    for row in rows(root, "properties"):
        key = unhex(row["property_hex"])
        cid = row["cell_id"]
        if key in props[cid]:
            raise Unsupported(f"duplicate DCP property {cid}/{key}")
        props[cid][key] = {"raw": unhex(row["value_hex"]),
                           "read_status": row["read_status"]}
    return cells, by_name, pins, boundaries, nets, props


def pin_port(ref_pin: str) -> tuple[str, int | None]:
    match = BUS_BIT.fullmatch(ref_pin)
    return (match.group(1), int(match.group(2))) if match else (ref_pin, None)


def bind_bank(bank: str, expanded: Expanded, dcp: tuple,
              contract: dict) -> tuple[list[dict], dict[str, str]]:
    cells, by_name, pins, boundaries, nets, props = dcp
    selected = {name: cell for name, cell in by_name.items()
                if cell["primitive"] and cell["bank"] == bank}
    if set(selected) != set(expanded.primitives):
        missing = sorted(set(selected) - set(expanded.primitives))[:8]
        extra = sorted(set(expanded.primitives) - set(selected))[:8]
        raise Unsupported(f"primitive bijection failure {bank}: missing={missing} extra={extra}")
    if bank not in by_name or by_name[bank]["reference"] == "":
        raise Unsupported(f"missing exact DCP bank root {bank}")
    hierarchy = {name: cell for name, cell in by_name.items()
                 if not cell["primitive"] and cell["bank"] == bank}
    if set(hierarchy) != set(expanded.hierarchy):
        raise Unsupported(f"hierarchy cell bijection failure {bank}")
    normalized_boundaries = {key if "[" in key else f"{key}[0]": net
                             for key, net in boundaries[bank].items()}
    if set(normalized_boundaries) != set(expanded.boundaries):
        raise Unsupported(f"boundary bit bijection failure {bank}")

    net_to_component: dict[str, str] = {}
    component_to_net: dict[str, str] = {}

    def attach(net: str, node: str | None, endpoint: str) -> None:
        if net in ("UNCONNECTED", "UNRESOLVED"):
            if node is not None:
                raise Unsupported(f"connected HDL endpoint is {net} in DCP: {endpoint}")
            return
        if node is None or net not in nets:
            raise Unsupported(f"missing HDL/DCP net for {endpoint}")
        comp = expanded.components.find(node)
        previous = net_to_component.setdefault(net, comp)
        if previous != comp:
            raise Unsupported(f"DCP net {net} splits in HDL: {endpoint}")
        prior_net = component_to_net.setdefault(comp, net)
        if prior_net != net:
            raise Unsupported(f"HDL aliases distinct DCP nets {prior_net}/{net}: {endpoint}")
        actual_const = expanded.components.constant.get(comp)
        dcp_const = nets[net]
        if actual_const is not None and dcp_const != str(actual_const):
            raise Unsupported(f"constant identity mismatch {net}: {endpoint}")
        if dcp_const in ("0", "1") and actual_const is None:
            raise Unsupported(f"DCP constant lacks explicit HDL source {net}: {endpoint}")

    for signal, net in normalized_boundaries.items():
        node = expanded.boundaries.get(signal)
        attach(net, node, f"{bank}/{signal}")

    for path, module_name in sorted(expanded.hierarchy.items()):
        cell = hierarchy[path]
        if path != bank and cell["reference"] != module_name:
            raise Unsupported(f"hierarchy REF_NAME conflict {path}: {module_name}/{cell['reference']}")
        module = expanded.modules[module_name]
        expected_pins = {}
        for port in module.header_ports:
            if port not in module.directions or port not in module.ranges:
                raise Unsupported(f"undeclared hierarchy port {path}/{port}")
            for index in module.ranges[port]:
                key = (port, index if port in module.vector_ports else None)
                if key in expected_pins:
                    raise Unsupported(f"duplicate hierarchy pin definition {path}/{key}")
                expected_pins[key] = ({"input": "IN", "output": "OUT", "inout": "INOUT"}[module.directions[port]],
                                      f"{path}/{port}[{index}]")
        observed = {}
        for pin in pins[cell["id"]]:
            key = pin_port(pin["ref_pin"])
            if key in observed:
                raise Unsupported(f"duplicate hierarchy DCP pin {path}/{key}")
            observed[key] = pin
        if set(observed) != set(expected_pins):
            raise Unsupported(f"hierarchy pin bijection failure {path}")
        for key, (direction, node) in expected_pins.items():
            pin = observed[key]
            if pin["direction"] != direction:
                raise Unsupported(f"hierarchy pin direction mismatch {path}/{key}")
            if node not in expanded.components.parent:
                raise Unsupported(f"missing hierarchy HDL pin node {path}/{key}")
            attach(pin["net"], node, f"{path}/{key}")

    semantic = []
    for path, primitive in sorted(expanded.primitives.items()):
        cell = selected[path]
        if primitive.reference != cell["reference"]:
            raise Unsupported(f"REF_NAME conflict {path}: {primitive.reference}/{cell['reference']}")
        signature = contract[primitive.reference]["port_signature"]
        grouped = defaultdict(list)
        for pin in pins[cell["id"]]:
            base, index = pin_port(pin["ref_pin"])
            grouped[base].append((index, pin))
        if set(grouped) != set(primitive.ports) or set(grouped) != set(signature):
            raise Unsupported(f"named primitive pin bijection failure {path}")
        for port, dcp_pins in grouped.items():
            vector = primitive.ports[port]
            expected = signature[port]
            expected_indices = [None] if expected["scalar"] else expected["indices"]
            observed_indices = [index for index, _ in dcp_pins]
            if len(dcp_pins) != len(expected_indices) or \
                    set(observed_indices) != set(expected_indices):
                raise Unsupported(f"primitive pin index set mismatch {path}/{port}")
            for _, pin in dcp_pins:
                if pin["direction"] != expected["direction"]:
                    raise Unsupported(f"primitive pin direction mismatch {path}/{port}")
            if vector is None:
                if any(p["net"] not in ("UNCONNECTED", "UNRESOLVED") for _, p in dcp_pins):
                    raise Unsupported(f"open HDL port has connected DCP pin {path}/{port}")
                continue
            if len(vector) != len(dcp_pins):
                raise Unsupported(f"primitive pin width mismatch {path}/{port}")
            if expected["scalar"]:
                attach(dcp_pins[0][1]["net"], vector[0], f"{path}/{port}")
            else:
                positions = {index: position for position, index in enumerate(expected["indices"])}
                for index, pin in dcp_pins:
                    attach(pin["net"], vector[positions[index]], f"{path}/{port}[{index}]")

        required = set(contract[primitive.reference]["required_property_names"])
        dcp_values = props[cell["id"]]
        if set(dcp_values) != required:
            raise Unsupported(f"DCP semantic property names differ {path}")
        classifications = {p["name"]: p["classification"] for p in
                           contract[primitive.reference]["parameters"]}
        for name in primitive.parameters:
            if name not in classifications:
                raise Unsupported(f"unknown exported primitive parameter {path}/{name}")
        for name in sorted(required):
            exported = primitive.parameters.get(name)
            dcp_record = dcp_values[name]
            dcp_raw = dcp_record["raw"]
            dcp_value = None
            if dcp_record["read_status"] == "OK" and dcp_raw != "":
                dcp_value = dcp_literal(dcp_raw)
            if exported is not None and dcp_value is not None and comparable(exported) != comparable(dcp_value):
                raise Unsupported(f"DCP/export parameter conflict {path}/{name}")
            if exported is not None and dcp_value is not None and \
                    dcp_value.width is not None and \
                    (exported.width != dcp_value.width or exported.signed != dcp_value.signed):
                raise Unsupported(f"DCP/export width or signedness conflict {path}/{name}")
            if primitive.reference == "RAMB36E2" and name in REQUIRED_RAM_INVERSIONS:
                if exported is None or exported.kind != "integer" or \
                        exported.width != 1 or exported.value not in (0, 1):
                    raise Unsupported(f"explicit known one-bit override missing {path}/{name}")
            if exported is None and dcp_value is None:
                raise Unsupported(f"required actual parameter absent {path}/{name}")
            chosen = exported if exported is not None else dcp_value
            assert chosen is not None
            semantic.append({"primitive": path, "reference": primitive.reference,
                "parameter": name,
                "provenance": "EXPLICIT_FUNCSIM_OVERRIDE" if exported is not None else "ACTUAL_DCP_PROPERTY",
                "value_kind": chosen.kind, "decoded_value": chosen.value,
                "width": chosen.width, "signed": chosen.signed,
                "export": None if exported is None else {
                    "raw": exported.raw, "start_byte": exported.start, "end_byte": exported.end},
                "dcp_original": dcp_record})
        for name, value in primitive.parameters.items():
            if classifications[name] == "simulation_diagnostic_not_mapping":
                semantic.append({"primitive": path, "reference": primitive.reference,
                    "parameter": name, "classification": "simulation_only",
                    "provenance": "EXPLICIT_FUNCSIM_OVERRIDE",
                    "raw": value.raw, "start_byte": value.start,
                    "end_byte": value.end})
    selected_net_ids = {pin["net"] for cell in cells.values() if cell["bank"] == bank
                        for pin in pins[cell["id"]]
                        if pin["net"] not in ("UNCONNECTED", "UNRESOLVED")}
    if selected_net_ids != set(net_to_component):
        raise Unsupported(f"selected DCP net components lack HDL mapping {bank}: "
                          f"missing={sorted(selected_net_ids - set(net_to_component))[:8]} "
                          f"extra={sorted(set(net_to_component) - selected_net_ids)[:8]}")
    return semantic, net_to_component


def bind(graph_root: Path, export_root: Path) -> dict:
    structure = audit(graph_root, allow_property_gaps_for_explicit_join=True)
    if structure["error_count"]:
        raise Unsupported(f"DCP graph structural audit failed: {structure['errors'][:3]}")
    contract_raw = json.loads(CONTRACT.read_text())
    contract = {entry["reference"]: entry for entry in contract_raw["primitive_contracts"]}
    if len(contract) != 22 or sum(len(x["required_property_names"]) for x in contract.values()) != 348:
        raise Unsupported("semantic property contract cardinality changed")
    for entry in contract.values():
        entry["port_signature"] = unisim_port_signature(entry)
    dcp = graph_tables(graph_root)
    semantic, graphs, exports = [], [], []
    raw_funcsim_parameters, graph_correspondence = [], []
    raw_dcp_properties = [
        {"source_file": str(graph_root / "properties.tsv"),
         "cell_id": cid, "instance_path": dcp[0][cid]["name"],
         "reference": dcp[0][cid]["reference"], "parameter": name,
         "raw": record["raw"], "read_status": record["read_status"]}
        for cid, values in sorted(dcp[5].items()) for name, record in sorted(values.items())
    ]
    for bank in BANKS:
        path = export_root / f"{bank}.v"
        if not path.is_file():
            raise Unsupported(f"missing exact functional export {bank}")
        expanded = read_export(path, set(contract), bank)
        joined, mapped = bind_bank(bank, expanded, dcp, contract)
        for row in joined:
            row["evidence_file"] = str(path if row["provenance"] == "EXPLICIT_FUNCSIM_OVERRIDE"
                                       else graph_root / "properties.tsv")
        semantic.extend(joined)
        source_bytes = path.read_bytes()
        for primitive in expanded.primitives.values():
            for name, literal in primitive.parameters.items():
                if source_bytes[literal.start:literal.end].decode("ascii") != literal.raw:
                    raise Unsupported(f"functional export literal span mismatch {primitive.path}/{name}")
                raw_funcsim_parameters.append({
                    "source_file": str(path), "bank": bank,
                    "module_definition": primitive.source_module,
                    "instance_path": primitive.path,
                    "source_instance": primitive.source_instance,
                    "reference": primitive.reference, "parameter": name,
                    "raw": literal.raw, "start_byte": literal.start,
                    "end_byte": literal.end, "width": literal.width,
                    "signed": literal.signed, "kind": literal.kind,
                    "decoded_value": literal.value})
        graph_correspondence.extend(
            {"bank": bank, "dcp_net_id": net, "hdl_component_node": component}
            for net, component in sorted(mapped.items()))
        graphs.append({"bank": bank, "top_module": expanded.top_module,
                       "dcp_root_ref": dcp[1][bank]["reference"],
                       "root_binding": {"selected_dcp_cell_name": bank,
                                        "export_file": str(path),
                                        "export_top_module": expanded.top_module},
                       "hierarchy_count": len(expanded.hierarchy),
                       "primitive_count": len(expanded.primitives),
                       "node_count": len(expanded.components.parent),
                       "alias_edge_count": expanded.components.edges,
                       "mapped_net_components": len(mapped)})
        exports.append(identity(path))
    if set(p.name for p in export_root.iterdir() if p.is_file()) != {f"{x}.v" for x in BANKS}:
        raise Unsupported("unexpected export file set")
    return {"schema": "q8_ws_v5_actual_funcsim_graph_semantic_join_v1",
            "status": "STRUCTURAL_AND_PARAMETER_JOIN_ONLY_MAPPING_HELD",
            "graph_structural_audit": structure, "exports": exports,
            "contract": identity(CONTRACT), "per_bank": graphs,
            "raw_dcp_property_source": identity(graph_root / "properties.tsv"),
            "raw_dcp_properties": raw_dcp_properties,
            "raw_funcsim_parameters": raw_funcsim_parameters,
            "graph_correspondence": graph_correspondence,
            "semantic_property_count": len(semantic),
            "semantic_properties": semantic,
            "capacity_address_mapping": "NOT_EVALUATED_HELD",
            "physical_timing_board": "NOT_ESTABLISHED"}


if __name__ == "__main__":
    sys.stderr.write("Actual parser/evaluator invocation is held pending an independent release.\n")
    raise SystemExit(2)
