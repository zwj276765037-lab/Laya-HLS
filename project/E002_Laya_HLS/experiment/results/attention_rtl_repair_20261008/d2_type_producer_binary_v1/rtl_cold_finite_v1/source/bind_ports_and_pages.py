#!/usr/bin/env python3
"""Source-only check of the actual generated top pins and sparse BO pages.

This reads existing files and writes one new JSON report. It does not invoke
EDA tools, allocate a DUT image, or materialize a page.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path


TYPE = Path(__file__).resolve().parents[2]
DESIGN = Path(__file__).with_name("design.md")
MAPPING = TYPE / "tb/static_mapping.json"
TOP = TYPE / "runs/hls_synthesis_v1/work/hls/syn/verilog/type_producer_binary_slice.v"
PORTS = ("hidden_input", "embedding", "io", "aux", "state0", "state1", "observed")
PAGE = 4096


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def ref(path: Path) -> dict:
    return {"path": str(path), "resolved_path": str(path.resolve(strict=True)),
            "bytes": path.stat().st_size, "sha256": sha(path)}


def integer(expr: str, params: dict[str, int]) -> int:
    node = ast.parse(expr.strip(), mode="eval").body

    def visit(item: ast.AST) -> int:
        if isinstance(item, ast.Constant) and type(item.value) is int:
            return item.value
        if isinstance(item, ast.Name) and item.id in params:
            return params[item.id]
        if isinstance(item, ast.BinOp):
            a, b = visit(item.left), visit(item.right)
            if isinstance(item.op, ast.Add):
                return a + b
            if isinstance(item.op, ast.Sub):
                return a - b
            if isinstance(item.op, ast.Mult):
                return a * b
            if isinstance(item.op, ast.Div) and b and a % b == 0:
                return a // b
        raise ValueError(f"unsupported generated width expression: {expr}")

    return visit(node)


def generated_ports() -> tuple[list[str], dict[str, dict]]:
    text = TOP.read_text()
    match = re.search(r"\bmodule\s+type_producer_binary_slice\s*\((.*?)\);", text, re.S)
    if not match:
        raise ValueError("generated top module header missing")
    ordered = re.findall(r"\b([A-Za-z_]\w*)\b", match.group(1))
    params: dict[str, int] = {}
    for name, expr in re.findall(r"^parameter\s+(\w+)\s*=\s*([^;]+);", text, re.M):
        if "'" in expr:
            continue
        params[name] = integer(expr, params)
    declarations: dict[str, dict] = {}
    pattern = re.compile(r"^(input|output)\s*(?:\[([^:]+):([^\]]+)\]\s*)?(\w+)\s*;", re.M)
    for direction, high, low, name in pattern.findall(text):
        if name in ordered:
            width = integer(high, params) - integer(low, params) + 1 if high else 1
            if width <= 0 or name in declarations:
                raise ValueError(f"bad or duplicate generated pin {name}")
            declarations[name] = {"direction": direction, "width": width,
                                  "declaration": f"{direction} [{high}:{low}]" if high else direction}
    if len(ordered) != len(set(ordered)) or set(ordered) != set(declarations):
        raise ValueError("generated header/declaration disagreement")
    return ordered, declarations


def check_axi(ports: dict[str, dict]) -> None:
    suffixes = {
        "AWVALID": 1, "AWREADY": 1, "AWADDR": 64, "AWID": 1,
        "AWLEN": 8, "AWSIZE": 3, "AWBURST": 2, "AWLOCK": 2,
        "AWCACHE": 4, "AWPROT": 3, "AWQOS": 4, "AWREGION": 4,
        "AWUSER": 1, "WVALID": 1, "WREADY": 1, "WDATA": 32,
        "WSTRB": 4, "WLAST": 1, "WID": 1, "WUSER": 1,
        "ARVALID": 1, "ARREADY": 1, "ARADDR": 64, "ARID": 1,
        "ARLEN": 8, "ARSIZE": 3, "ARBURST": 2, "ARLOCK": 2,
        "ARCACHE": 4, "ARPROT": 3, "ARQOS": 4, "ARREGION": 4,
        "ARUSER": 1, "RVALID": 1, "RREADY": 1, "RDATA": 32,
        "RLAST": 1, "RID": 1, "RUSER": 1, "RRESP": 2,
        "BVALID": 1, "BREADY": 1, "BRESP": 2, "BID": 1,
        "BUSER": 1,
    }
    outputs = {"AWVALID", "AWADDR", "AWID", "AWLEN", "AWSIZE", "AWBURST",
               "AWLOCK", "AWCACHE", "AWPROT", "AWQOS", "AWREGION", "AWUSER",
               "WVALID", "WDATA", "WSTRB", "WLAST", "WID", "WUSER",
               "ARVALID", "ARADDR", "ARID", "ARLEN", "ARSIZE", "ARBURST",
               "ARLOCK", "ARCACHE", "ARPROT", "ARQOS", "ARREGION", "ARUSER",
               "RREADY", "BREADY"}
    for port in PORTS:
        actual = {name[len(f"m_axi_{port}_"):]: item
                  for name, item in ports.items() if name.startswith(f"m_axi_{port}_")}
        if set(actual) != set(suffixes):
            raise ValueError(f"generated {port} channels differ: {set(actual) ^ set(suffixes)}")
        for suffix, width in suffixes.items():
            if actual[suffix]["width"] != width or actual[suffix]["direction"] != (
                    "output" if suffix in outputs else "input"):
                raise ValueError(f"generated {port}.{suffix} width/direction differs")
    if ports["ap_clk"] != {"direction": "input", "width": 1, "declaration": "input"} or \
            ports["ap_rst_n"] != {"direction": "input", "width": 1, "declaration": "input"}:
        raise ValueError("clock/reset pins differ")
    for name, address_width in (("s_axi_control", 4), ("s_axi_control_r", 7)):
        widths = {"AWVALID": 1, "AWREADY": 1, "AWADDR": address_width,
                  "WVALID": 1, "WREADY": 1, "WDATA": 32, "WSTRB": 4,
                  "ARVALID": 1, "ARREADY": 1, "ARADDR": address_width,
                  "RVALID": 1, "RREADY": 1, "RDATA": 32, "RRESP": 2,
                  "BVALID": 1, "BREADY": 1, "BRESP": 2}
        output_suffixes = {"AWREADY", "WREADY", "ARREADY", "RVALID",
                           "RDATA", "RRESP", "BVALID", "BRESP"}
        expected = {suffix: (width, "output" if suffix in output_suffixes else "input")
                    for suffix, width in widths.items()}
        actual = {pin[len(name) + 1:]: (item["width"], item["direction"])
                  for pin, item in ports.items()
                  if pin.startswith(name + "_") and not (
                      name == "s_axi_control" and pin.startswith("s_axi_control_r_"))}
        if actual != expected:
            raise ValueError(f"actual {name} CSR pin inventory differs: {actual}")


def checked_pages(mapping: dict) -> tuple[list[dict], dict[str, list[int]]]:
    if mapping["page_bytes"] != PAGE or mapping["mapped_page_total"] != 206:
        raise ValueError("accepted sparse mapping changed")
    entries, by_port, regions = [], {}, []
    for row in mapping["top_ports"]:
        name = row["name"]
        if name != PORTS[len(by_port)]:
            raise ValueError("port order changed")
        base, capacity = int(row["base_hex"], 16), row["capacity_bytes"]
        if base < 1 << 32 or base % PAGE or capacity <= 0 or base + capacity > 1 << 64:
            raise ValueError(f"port base/capacity invalid: {name}")
        for other_name, other_start, other_end in regions:
            if base < other_end and other_start < base + capacity:
                raise ValueError(f"BO regions overlap: {other_name}, {name}")
        regions.append((name, base, base + capacity))
        offsets = []
        for start, count in row["mapped_page_runs"]:
            if start < 0 or count <= 0 or start % PAGE:
                raise ValueError(f"invalid mapped page run: {name}")
            offsets.extend(start + i * PAGE for i in range(count))
        if len(offsets) != len(set(offsets)) or any(x < 0 or x >= capacity for x in offsets):
            raise ValueError(f"page not distinct/aligned/inside BO: {name}")
        by_port[name] = offsets
        for slot, offset in enumerate(offsets):
            valid_bytes = min(PAGE, capacity - offset)
            entries.append({"port": name, "slot": slot, "bo_offset": offset,
                            "physical_base": base + offset,
                            "bo_bytes_remaining": capacity - offset,
                            "valid_bo_bytes_on_page": valid_bytes,
                            "page_tail_outside_bo_bytes": PAGE - valid_bytes})
    if len(entries) != 206 or len({x["physical_base"] for x in entries}) != 206:
        raise ValueError("206 distinct physical pages not proven")
    if {key: len(value) for key, value in by_port.items()} != {
            "hidden_input": 64, "embedding": 1, "io": 8, "aux": 1,
            "state0": 67, "state1": 64, "observed": 1}:
        raise ValueError("per-port page geometry changed")
    for case in mapping["qtype_cases"]:
        for port, offset_key, length_key in (
                ("embedding", "type_q8_row_byte_offset", "type_q8_row_bytes"),
                ("state0", "type_f32_row_byte_offset", "type_f32_row_bytes")):
            start, length = case[offset_key], case[length_key]
            capacity = next(row["capacity_bytes"] for row in mapping["top_ports"]
                            if row["name"] == port)
            if length <= 0 or start < 0 or start + length > capacity or not any(
                    page["port"] == port and page["bo_offset"] <= start and
                    start + length <= page["bo_offset"] + page["valid_bo_bytes_on_page"]
                    for page in entries):
                raise ValueError(f"qtype {case['qtype']} selected {port} row is not fully mapped")
    return entries, by_port


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("release", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError(args.output)
    release = json.loads(args.release.read_text())
    if release["schema"] != "reviewer_source_preparation_release_v1" or \
            release["status"] != "COLD_FINITE_RTL_SOURCE_PREPARATION_ONLY_RELEASED" or \
            release["root"] != str(TYPE / "rtl_cold_finite_v1") or \
            release["design"]["sha256"] != sha(DESIGN) or \
            release["source_static_mapping"]["sha256"] != sha(MAPPING):
        raise ValueError("source-only release identity changed")
    ordered, ports = generated_ports()
    check_axi(ports)
    mapping = json.loads(MAPPING.read_text())
    entries, by_port = checked_pages(mapping)
    report = {"schema": "type_cold_finite_actual_port_page_binding_v1",
              "status": "SOURCE_ONLY_ACTUAL_GENERATED_PINS_AND_SPARSE_PAGES_BOUND",
              "created_utc": datetime.now(timezone.utc).isoformat(),
              "release": ref(args.release), "design": ref(DESIGN),
              "mapping": ref(MAPPING), "generated_top": ref(TOP),
              "ordered_top_pins": ordered, "top_pins": ports,
              "axi_ports": list(PORTS), "axi_data_bits": 32,
              "control_address_bits": 4, "control_r_address_bits": 7,
              "page_bytes": PAGE, "pages": entries,
              "page_offsets_by_port": by_port,
              "mapped_page_count": len(entries),
              "coverage_limit": "Sparse mapped pages plus forbidden-access assertions; no full-BO dump claim."}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"TYPE_PORT_PAGE_BIND_PASS pins={len(ordered)} pages={len(entries)}")


if __name__ == "__main__":
    main()
