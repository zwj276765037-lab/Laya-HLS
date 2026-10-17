#!/usr/bin/env python3
"""Split the existing FFN simulation into one hardware top and a host TB.

This transformation only moves instance boundaries. All fixture, external
memory, checker and sequencer statements remain in the simulation sources.
The generated pair is a candidate until compilation and full-chain checks.
"""

from pathlib import Path
import re

from m005_build_representative_top_v1 import (
    INTERNAL_DRIVERS, PUBLIC_FEEDBACK, SOURCE_STAGE, collect, header_decls,
    instance_text,
)
from m005_top_extract_inventory import MODULES, TB, instance_ports, strip_comments

HERE = Path(__file__).resolve().parent
TOP = HERE.parent / "rtl/laya_ffn_representative_top_v1.sv"
OUT_HOST = HERE / "laya_ffn0_source_stage_host_v1.sv"
OUT_TB = HERE / "m005_ffn_top_tb_v1.sv"
HARDWARE = tuple(name for name in MODULES if name != "ln_shell")
SHELL_PORT_MAP = {
    "source_query_ready": "ln_query_ready",
    "source_query_granted": "ln_query_granted",
    "source_release_ready": "ln_source_release_ready",
    "source_lease_active": "ln_source_lease_active",
}


def shell_boundary():
    module, path = MODULES["ln_shell"]
    formals = header_decls(module, path)
    raw = instance_ports(strip_comments(SOURCE_STAGE.read_text()), "dut")
    explicit = {key: value for key, value in raw.items() if key != ".*"}
    connected = {**{name: name for name in formals}, **explicit}
    host_formals = header_decls("laya_ffn0_source_stage_v1", SOURCE_STAGE)
    promoted = {
        name: formals[name]
        for name, expression in connected.items()
        if expression == name and name not in host_formals
        and name not in {"cancel", "monitored_bo_base"}
    }
    shared_shell_outputs = {
        name for name, (direction, _) in formals.items()
        if direction == "output" and name in host_formals
    }
    return promoted, shared_shell_outputs


def remove_promoted_declarations(source, promoted):
    result = []
    removed = set()
    declaration = re.compile(r"^(\s*)(logic|wire)\s*(\[[^]]+\])?\s*(.*);\s*$")
    for line in source.splitlines():
        match = declaration.match(line)
        if not match:
            result.append(line)
            continue
        indent, kind, width, members = match.groups()
        parts = [part.strip() for part in members.split(",")]
        kept = []
        for part in parts:
            name = re.match(r"([A-Za-z_]\w*)", part)
            if name and name.group(1) in promoted:
                removed.add(name.group(1))
            else:
                kept.append(part)
        if kept:
            if len(kept) == len(parts):
                result.append(line)
            else:
                result.append(f"{indent}{kind} {width or ''} {','.join(kept)};")
    if removed != set(promoted):
        raise ValueError(f"source-stage declarations not found: {set(promoted)-removed}")
    return "\n".join(result) + "\n"


def build_host(promoted, shared_shell_outputs):
    source = SOURCE_STAGE.read_text()
    shell = instance_text(source, "dut")
    source = source.replace(shell, "// LN shell is the hardware top's ln_shell instance.", 1)
    source = source.replace("module laya_ffn0_source_stage_v1 (",
                            "module laya_ffn0_source_stage_host_v1 (", 1)
    reversals = (
        "output logic source_query_ready,source_query_granted",
        "output logic source_release_ready",
        "output logic source_lease_active",
    )
    if shared_shell_outputs != {
        "source_query_ready", "source_query_granted",
        "source_release_ready", "source_lease_active",
    }:
        raise ValueError(f"source-stage shared shell outputs changed: {shared_shell_outputs}")
    for original in reversals:
        if source.count(original) != 1:
            raise ValueError(f"cannot reverse host shell output {original}")
        source = source.replace(original, original.replace("output logic", "input logic"), 1)
    source = source.replace(
        "  output logic skip_rlast\n);",
        "  output logic skip_rlast,\n" +
        ",\n".join(
            f"  {'output' if direction == 'input' else 'input'} logic {width} {name}"
            for name, (direction, width) in sorted(promoted.items())
        ) + "\n);", 1)
    if "output logic skip_rlast," not in source:
        raise ValueError("source-stage port anchor changed")
    source = remove_promoted_declarations(source, promoted)
    # Observation remains in the host TB, pointed at the actual relocated
    # generated LN engine. It is never included in synthesis.
    source = re.sub(r"\bdut\.", "$root.m005_ffn_top_tb_v1.top.ln_shell.", source)
    OUT_HOST.write_text(source)


def build_tb(promoted):
    source = TB.read_text()
    source = source.replace("module ffn0_chain_tb_v1;",
                            "module m005_ffn_top_tb_v1;", 1)
    source = source.replace("module m005_ffn_top_tb_v1;",
                            "`default_nettype none\nmodule m005_ffn_top_tb_v1;", 1)
    for name in HARDWARE:
        snippet = instance_text(source, name)
        if source.count(snippet) != 1:
            raise ValueError(f"cannot uniquely remove instance {name}")
        source = source.replace(snippet, f"// {name} lives in top.", 1)
    host = instance_text(source, "ln_source")
    extra = ",\n" + ",\n".join(f"    .{name}({name})" for name in sorted(promoted))
    replacement = host.replace("laya_ffn0_source_stage_v1 ln_source(",
                               "laya_ffn0_source_stage_host_v1 ln_source(", 1)
    replacement = replacement[:-2] + extra + ");"
    source = source.replace(host, replacement, 1)

    top_ports = header_decls("laya_ffn_representative_top_v1", TOP)
    new_decls = [
        f"  logic {width} {name};"
        for name, (_, width) in sorted(promoted.items())
    ]
    for name in ("quant_axi_accounting_error", "quant_axi_burst_in_flight",
                 "quant_axi_beats_remaining"):
        if name not in promoted:
            new_decls.append(f"  logic {top_ports[name][1]} {name};")
    source = source.replace("module m005_ffn_top_tb_v1;",
                            "module m005_ffn_top_tb_v1;\n" +
                            "\n".join(new_decls), 1)
    top_instance = (
        "  laya_ffn_representative_top_v1 top(\n" +
        ",\n".join(f"    .{name}({SHELL_PORT_MAP.get(name, name if name != 'stage' else 'stage[0]')})"
                   for name in sorted(top_ports)) +
        "\n  );\n"
    )
    source = source.replace("// dut lives in top.",
                            "// All ten hardware leaves share this synthesis boundary.\n" +
                            top_instance, 1)
    # TB assertions and the external source response model still observe
    # internal hardware handshakes. These are read-only TB aliases.
    use, shapes, _ = collect()
    alias_names = []
    for name in sorted(shapes):
        drivers = [item for item in use[name] if item[0] == "output"]
        internal = name in INTERNAL_DRIVERS or (
            drivers and any(item[0] == "input" for item in use[name])
            and name not in PUBLIC_FEEDBACK
        )
        if not internal or name in {"matrix_cfg_valid", "ledger_claim_valid",
                                    "ledger_retire_debt_zero",
                                    "ln_query_ready", "ln_query_granted",
                                    "ln_source_release_ready"}:
            continue
        if name not in promoted and re.search(
            rf"^\s*(?:logic|wire|integer|bit|reg)\b[^;]*\b{re.escape(name)}\b[^;]*;",
            source, re.M
        ):
            alias_names.append(name)
    source, count = re.subn(
        r"  assign ln_physical_r_debt_zero=g_quant_task_debt_zero &&\s*"
        r"source_r_beats==source_ar_beats && !g_read_active && !g_m_axi_rvalid;",
        "", source, count=1
    )
    if count != 1:
        raise ValueError("old TB debt witness not found")
    aliases = "\n".join(f"  assign {name}=top.{name};" for name in alias_names)
    source = source.replace(top_instance, top_instance + aliases + "\n", 1)
    for name in HARDWARE:
        source = re.sub(rf"\b{re.escape(name)}\.", f"top.{name}.", source)
    OUT_TB.write_text(source + "\n`default_nettype wire\n")
    return len(top_ports), len(alias_names)


def main():
    promoted, shared = shell_boundary()
    build_host(promoted, shared)
    ports, aliases = build_tb(promoted)
    print(f"host_ports={len(promoted)} top_ports={ports} tb_aliases={aliases}")
    print(f"host={OUT_HOST}\ntb={OUT_TB}")


if __name__ == "__main__":
    main()
