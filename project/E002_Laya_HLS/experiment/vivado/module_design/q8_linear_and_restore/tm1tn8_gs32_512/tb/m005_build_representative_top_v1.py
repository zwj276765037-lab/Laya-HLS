#!/usr/bin/env python3
"""Build the FFN representative hardware wrapper from frozen named instances.

The script only rearranges instance wiring. It deliberately leaves stimulus,
fixture arrays, AXI response models, and the sequencer outside the wrapper.
The emitted RTL is a candidate until static and whole-chain simulation pass.
"""

from collections import defaultdict
from pathlib import Path
import re

from m005_top_extract_inventory import (HERE, MODULES, TB, instance_ports,
                                        module_ports, parenthesized,
                                        split_commas, strip_comments)

OUTPUT = HERE.parent / "rtl/laya_ffn_representative_top_v1.sv"
SOURCE_STAGE = HERE / "laya_ffn0_source_stage_v1.sv"

# Real configuration and completion pins used by an external task sequencer.
PUBLIC_FEEDBACK = {
    "cfg_ready", "cfg_reject", "cfg_owner_admitted", "done_valid",
    "done_status", "done_first_error_rank", "done_bad_element",
    "g_cfg_ready", "g_cfg_reject", "g_done_valid", "g_done_status",
    "wc_request_ready", "wc_request_reject", "wc_load_done",
    "wc_load_error", "wi_cfg_ready", "wi_cfg_reject",
    "ln_candidate_ready", "ln_candidate_reject", "ln_lease_pending",
    "source_lease_active", "ffn_res_rsp_valid", "ffn_res_rsp_status",
    "ffn_hidden_published", "ffn_handoff_error",
}
PARAMETERS = {
    "STATE1_BASE": "64'h310000000", "TMP_BASE": "64'h310800000",
    "WI_BO_BASE": "64'h100000000", "WI_BO_SPAN": "64'h2000000",
    "WI_REGION_BASE": "64'h100001000", "WI_REGION_SPAN": "64'h1000000",
    "WI_ROW_STRIDE": "64'd20992", "WI_BATCH_STRIDE": "64'd21495808",
    "monitored_bo_base": "64'h300000000",
}
CONSTANT_BITS = {"cancel": "1'b0"}
GATE_K = "13'd2624"
INTERNAL_DRIVERS = {
    "matrix_cfg_valid", "ledger_claim_valid", "ledger_retire_debt_zero",
    "source_query_valid", "source_query_command",
    "source_release_valid", "source_release_command",
    "source_release_drained", "ln_query_ready", "ln_query_granted",
    "ln_source_release_ready", "ln_source_lease_active",
    "g_quant_task_debt_zero", "ln_physical_r_debt_zero",
}


def header_decls(module, path):
    source = strip_comments(path.read_text())
    match = re.search(r"\bmodule\s+" + re.escape(module) + r"\b", source)
    opening = source.find("(", match.end())
    body, end = parenthesized(source, opening)
    if source[end:].lstrip().startswith("("):
        body, _ = parenthesized(source, source.find("(", end))
    direction, width = None, ""
    result = {}
    for part in split_commas(body):
        dm = re.search(r"\b(input|output|inout)\b", part)
        if dm:
            direction = dm.group(1)
            width = "".join(re.findall(r"\[[^]]+\]", part))
        name = re.search(r"([A-Za-z_]\w*)\s*(?:\[[^]]+\]\s*)*(?:=.+)?$", part)
        if name and direction:
            result[name.group(1)] = (direction, width)
    return result


def instance_text(source, name):
    match = re.search(r"\b" + re.escape(name) + r"\s*\(", source)
    if not match:
        raise ValueError(f"missing {name}")
    # Include the module name and optional #(...) parameterization.
    line = source.rfind("\n", 0, match.start()) + 1
    opening = source.find("(", match.start())
    _, end = parenthesized(source, opening)
    return source[line:end + 1].strip()


def collect():
    tb = TB.read_text()
    stage = SOURCE_STAGE.read_text()
    use = defaultdict(list)
    shapes = {}
    snippets = []
    for instance, (module, path) in MODULES.items():
        source = stage if instance == "ln_shell" else tb
        old_name = "dut" if instance == "ln_shell" else instance
        connections = instance_ports(strip_comments(source), old_name)
        if connections.pop(".*", None):
            connections = {**{name: name for name in module_ports(module, path)},
                           **connections}
        decls = header_decls(module, path)
        for port, expression in connections.items():
            if port not in decls:
                raise ValueError(f"{instance}.{port} absent from module header")
            if re.fullmatch(r"[A-Za-z_]\w*", expression):
                name = expression
                use[name].append((decls[port][0], instance, port))
                width = decls[port][1]
                if name in shapes and shapes[name] != width:
                    def bits(packed):
                        product = 1
                        for left, right in re.findall(r"\[(\d+):(\d+)\]", packed):
                            product *= abs(int(left) - int(right)) + 1
                        return product
                    if bits(width) > bits(shapes[name]):
                        shapes[name] = width
                else:
                    shapes[name] = width
        snippet = instance_text(source, old_name)
        if instance == "ln_shell":
            snippet = re.sub(r"\bdut\s*\(", "ln_shell(", snippet, count=1)
        if instance == "w_binding":
            snippet = snippet.replace(".K(wc_load_k)", ".K(wc_load_k[15:0])")
            snippet = snippet.replace(".N(wc_load_n)", ".N(wc_load_n[15:0])")
        if instance == "ffn_handoff":
            snippet = snippet.replace(".gate_rows(g_cfg_rows)",
                                      ".gate_rows(g_cfg_rows[2:0])")
        snippets.append(snippet)
    return use, shapes, snippets


def main():
    use, shapes, snippets = collect()
    # The source shell's query names are bridged to the existing admission
    # names; the wrapper itself owns these wires.
    for name, width in {
        "source_query_valid": "", "source_query_command": "[8191:0]",
        "source_release_valid": "", "source_release_command": "[8191:0]",
        "source_release_drained": "", "ln_query_ready": "",
        "ln_query_granted": "", "ln_source_release_ready": "",
        "ln_source_lease_active": "", "stage": "",
        "cfg_valid": "", "ln_physical_r_debt_zero": "",
    }.items():
        shapes.setdefault(name, width)
    public = {}
    internal = {}
    for name, width in sorted(shapes.items()):
        if name in PARAMETERS or name in CONSTANT_BITS or name == "GATE_K":
            continue
        drivers = [f"{inst}.{port}" for direction, inst, port in use[name]
                   if direction == "output"]
        if len(drivers) > 1:
            raise ValueError(f"more than one driver of {name}: {drivers}")
        if name in INTERNAL_DRIVERS or (drivers and
                any(direction == "input" for direction, _, _ in use[name]) and
                name not in PUBLIC_FEEDBACK):
            internal[name] = width
        else:
            public[name] = ("output" if drivers else "input", width)
    for name in ("stage", "cfg_valid"):
        public[name] = ("input", shapes[name])
        internal.pop(name, None)
    # The LN release witness is generated from the bridge's actual AXI port.
    internal["ln_physical_r_debt_zero"] = ""
    public.pop("ln_physical_r_debt_zero", None)
    public["quant_axi_beats_remaining"] = ("output", "[8:0]")
    public["quant_axi_burst_in_flight"] = ("output", "")
    public["quant_axi_accounting_error"] = ("output", "")
    lines = ["`timescale 1ns/1ps", "`default_nettype none",
             "// Candidate hardware-only FFN top; external AXI/commands are ports.",
             "module laya_ffn_representative_top_v1 ("
             ]
    ports = [f"  {direction} logic {width} {name}".replace("  ", " ", 1)
             for name, (direction, width) in sorted(public.items())]
    lines.append(",\n".join(ports))
    lines.append(");")
    for name, value in PARAMETERS.items():
        lines.append(f"  localparam logic [63:0] {name} = {value};")
    lines.append(f"  localparam logic [12:0] GATE_K = {GATE_K};")
    for name, value in CONSTANT_BITS.items():
        lines.append(f"  localparam logic {name} = {value};")
    for name, width in sorted(internal.items()):
        lines.append(f"  logic {width} {name};")
    lines += [
        "  assign matrix_cfg_valid = stage==0 ? cfg_valid : ffn_matrix_cfg_valid;",
        "  assign ledger_claim_valid = matrix_cfg_valid;",
        "  assign ledger_retire_debt_zero = a_read_debt_zero && !a_ret_valid && !w_ret_valid &&",
        "    wc_slot_readers[0]==0 && fa_slot_state[0]==0 &&",
        "    actual_aw_count[0]==actual_b_count[0] && actual_w_count[0]==actual_b_count[0];",
        "  assign source_query_valid = ln_query_valid;",
        "  assign source_query_command = ln_source_query_command;",
        "  assign ln_query_ready = source_query_ready;",
        "  assign ln_query_granted = source_query_granted;",
        "  assign source_release_valid = ln_source_release_valid;",
        "  assign source_release_command = ln_source_release_command;",
        "  assign source_release_drained = ln_source_release_drained;",
        "  assign ln_source_release_ready = source_release_ready;",
        "  assign ln_source_lease_active = source_lease_active;",
        "  laya_quant_axi_debt_monitor_v1 quant_axi_debt_monitor(",
        "    .clk, .rst_n,",
        "    .arvalid(g_m_axi_arvalid), .arready(g_m_axi_arready),",
        "    .arlen(g_m_axi_arlen), .rvalid(g_m_axi_rvalid),",
        "    .rready(g_m_axi_rready), .rlast(g_m_axi_rlast),",
        "    .quant_task_debt_zero(g_quant_task_debt_zero),",
        "    .physical_and_task_debt_zero(ln_physical_r_debt_zero),",
        "    .beats_remaining(quant_axi_beats_remaining),",
        "    .burst_in_flight(quant_axi_burst_in_flight),",
        "    .accounting_error(quant_axi_accounting_error));",
        "",
    ]
    lines += snippets
    lines.append("endmodule\n`default_nettype wire\n")
    OUTPUT.write_text("\n".join(lines))
    print(f"candidate={OUTPUT} ports={len(public)} internal={len(internal)}")


if __name__ == "__main__":
    main()
