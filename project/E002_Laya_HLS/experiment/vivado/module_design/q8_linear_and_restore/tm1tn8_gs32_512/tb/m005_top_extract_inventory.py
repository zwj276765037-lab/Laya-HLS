#!/usr/bin/env python3
"""List the RTL instance boundary that must move out of the FFN testbench.

This is a read-only source inventory. It intentionally does not generate a
top or infer hardware direction from testbench assignments.
"""

from collections import defaultdict
from pathlib import Path
import json
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TB = HERE / "ffn0_chain_tb_v1.sv"
MODULES = {
    "ln_shell": ("laya_layernorm_producer_portal_shell_v1", HERE.parent / "rtl/laya_layernorm_producer_portal_shell_v1.sv"),
    "dut": ("tm4tn8_matrix_resident_v2", HERE.parent / "kb2/rtl/tm4tn8_matrix_resident_v2.sv"),
    "wi_reader": ("laya_wi_axi_reader_v1", HERE.parent / "rtl/laya_wi_axi_reader_v1.sv"),
    "producer": ("geglu_gate_quant_bridge_v1", ROOT / "activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv"),
    "w_binding": ("laya_lnq0_w_binding_v1", HERE.parent / "rtl/laya_lnq0_w_binding_v1.sv"),
    "wcache": ("t4_dual_w_cache_v1", ROOT / "hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv"),
    "ledger": ("tm4tn8_matrix_owner_ledger_v2", HERE.parent / "rtl/tm4tn8_matrix_owner_ledger_v2.sv"),
    "ln_q_admit": ("laya_lnq0_external_quant_admission_v1", HERE.parent / "rtl/laya_lnq0_external_quant_admission_v1.sv"),
    "ffn_handoff": ("laya_ffn0_down_residual_admission_v1", ROOT / "vector_and_ffn/rtl/laya_ffn0_down_residual_admission_v1.sv"),
    "ffn_residual": ("laya_ffn0_residual_four_row_v1", ROOT / "vector_and_ffn/rtl/laya_ffn0_residual_four_row_v1.sv"),
}


def strip_comments(source):
    return re.sub(r"//[^\n]*|/\*.*?\*/", "", source, flags=re.S)


def parenthesized(source, opening):
    assert source[opening] == "("
    depth = 1
    for index in range(opening + 1, len(source)):
        if source[index] == "(":
            depth += 1
        elif source[index] == ")":
            depth -= 1
            if depth == 0:
                return source[opening + 1:index], index + 1
    raise ValueError(f"unclosed parenthesis at offset {opening}")


def split_commas(source):
    parts = []
    start = 0
    depth = 0
    for index, char in enumerate(source):
        if char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        elif char == "," and depth == 0:
            parts.append(source[start:index].strip())
            start = index + 1
    parts.append(source[start:].strip())
    return parts


def module_ports(module, path):
    source = strip_comments(path.read_text())
    match = re.search(r"\bmodule\s+" + re.escape(module) + r"\b", source)
    if not match:
        raise ValueError(f"{module} not found in {path}")
    opening = source.find("(", match.end())
    body, end = parenthesized(source, opening)
    if source[end:].lstrip().startswith("("):
        opening = source.find("(", end)
        body, _ = parenthesized(source, opening)
    direction = None
    result = {}
    for part in split_commas(body):
        dm = re.search(r"\b(input|output|inout)\b", part)
        if dm:
            direction = dm.group(1)
        name = re.search(r"([A-Za-z_]\w*)\s*(?:\[[^]]+\]\s*)*(?:=.+)?$", part)
        if name and direction:
            result[name.group(1)] = direction
    return result


def instance_ports(source, name):
    match = re.search(r"\b" + re.escape(name) + r"\s*\(", source)
    if not match:
        raise ValueError(f"missing instance {name}")
    body, _ = parenthesized(source, source.find("(", match.start()))
    result = {}
    for part in split_commas(body):
        if part == ".*":
            result[".*"] = ".*"
            continue
        named = re.fullmatch(r"\.([A-Za-z_]\w*)\s*\((.*)\)", part, flags=re.S)
        if named:
            result[named.group(1)] = named.group(2).strip()
        else:
            short = re.fullmatch(r"\.([A-Za-z_]\w*)", part)
            if not short:
                raise ValueError(f"unrecognized connection {name}: {part[:80]}")
            result[short.group(1)] = short.group(1)
    return result


def main():
    tb = strip_comments(TB.read_text())
    source_stage = strip_comments((HERE / "laya_ffn0_source_stage_v1.sv").read_text())
    signals = defaultdict(list)
    modules = {}
    for instance, (module, path) in MODULES.items():
        directions = module_ports(module, path)
        connections = instance_ports(source_stage if instance == "ln_shell" else tb,
                                     "dut" if instance == "ln_shell" else instance)
        if connections.pop(".*", None):
            connections = {**{port: port for port in directions}, **connections}
        unknown = sorted(set(connections) - set(directions))
        if unknown:
            raise ValueError(f"{instance}: unknown formal ports {unknown}")
        for port, expression in connections.items():
            if re.fullmatch(r"[A-Za-z_]\w*", expression):
                signals[expression].append((instance, port, directions[port]))
        modules[instance] = {"module": module, "source": str(path),
                             "connected_ports": len(connections),
                             "formal_ports": len(directions)}
    boundary = {}
    for signal, uses in sorted(signals.items()):
        drivers = [f"{instance}.{port}" for instance, port, direction in uses
                   if direction == "output"]
        readers = [f"{instance}.{port}" for instance, port, direction in uses
                   if direction == "input"]
        if len(drivers) > 1:
            raise ValueError(f"multiple hardware drivers for {signal}: {drivers}")
        boundary[signal] = {"driver": drivers[0] if drivers else None,
                            "readers": readers}
    print(json.dumps({"modules": modules, "signals": boundary}, indent=2,
                     sort_keys=True))


if __name__ == "__main__":
    main()
