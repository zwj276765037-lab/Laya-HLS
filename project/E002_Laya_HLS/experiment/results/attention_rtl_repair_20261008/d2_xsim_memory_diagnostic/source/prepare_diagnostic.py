#!/usr/bin/env python3
"""Freeze generated file agents and make exact diagnostic-only instrumentation."""

from __future__ import annotations

import difflib
import hashlib
import json
from pathlib import Path
import shutil
import struct


HERE = Path(__file__).resolve().parent
MODULE = HERE.parent
RESULTS = MODULE.parent
ORIGINAL = RESULTS / "d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/verilog/file_agent"
TV_ORIGINAL = RESULTS / "d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/tv/cdatafile"
RAW = HERE / "original"
RTL = MODULE / "rtl"
DATA = MODULE / "tb/data"
TRAILER = bytes.fromhex("5a5aa5a50f0ff0f0")
DEPTHS = (1024, 4096, 16384, 65536)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def replace_once(source: str, before: str, after: str) -> str:
    count = source.count(before)
    if count != 1:
        raise ValueError(f"expected exactly one occurrence ({count}): {before[:80]!r}")
    return source.replace(before, after, 1)


def main() -> None:
    for path in (RAW, RTL, DATA):
        path.mkdir(parents=True, exist_ok=True)
    files = ("file_agent_pkg.sv", "file_read_agent.sv", "file_write_agent.sv", "mem_model.sv")
    for name in files:
        shutil.copyfile(ORIGINAL / name, RAW / name)
        shutil.copyfile(ORIGINAL / name, RTL / name)

    pkg = (RTL / "file_agent_pkg.sv").read_text()
    pkg = replace_once(pkg, "        import uvm_pkg::*;\n", "        import uvm_pkg::*;\n        import \"DPI-C\" function void diag_stage(input string label, input longint elements, input longint aux);\n")
    (RTL / "file_agent_pkg.sv").write_text(pkg)

    reader = (RTL / "file_read_agent.sv").read_text()
    reader = replace_once(reader, "        DATA_QUEUE_TYPE TV_Queue[$];\n", "        DATA_QUEUE_TYPE TV_Queue[$];\n        longint diag_fread_bytes = 0;\n        longint diag_payload_bytes = 0;\n        longint diag_copy_elements = 0;\n        int diag_transactions = 0;\n        longint diag_last_ftell = 0;\n")
    reader = replace_once(reader,
        "        TV_Queue.delete();\n        ret = $fread(trans_depth, fp);\n        while(trans_depth != 64'h5a5aa5a50f0ff0f0) begin\n",
        "        TV_Queue.delete();\n        diag_fread_bytes = 0;\n        diag_payload_bytes = 0;\n        diag_copy_elements = 0;\n        diag_transactions = 0;\n        ret = $fread(trans_depth, fp);\n        if (ret != 8) `uvm_fatal(this.get_full_name(), \"diagnostic: incomplete 8-byte header\");\n        diag_fread_bytes += ret;\n        diag_stage(\"reader_header\", trans_depth, ret);\n        while(trans_depth != 64'h5a5aa5a50f0ff0f0) begin\n")
    reader = replace_once(reader,
        "                TV.push_back(data);                \n                trans_depth = trans_depth - 1;\n",
        "                if (ret != DATA_WIDTH/8) `uvm_fatal(this.get_full_name(), \"diagnostic: incomplete payload element\");\n                diag_fread_bytes += ret;\n                diag_payload_bytes += ret;\n                TV.push_back(data);                \n                if (TV.size() >= 1024 && ((TV.size() & (TV.size()-1)) == 0))\n                    diag_stage(\"reader_queue_power2\", TV.size(), diag_fread_bytes);\n                trans_depth = trans_depth - 1;\n")
    reader = replace_once(reader,
        "            TV_Queue.push_back(TV);\n            ret = $fread(trans_depth, fp);\n",
        "            diag_stage(\"reader_before_2d_copy\", TV.size(), TV_Queue.size());\n            TV_Queue.push_back(TV);\n            diag_copy_elements += TV.size();\n            diag_transactions++;\n            diag_stage(\"reader_after_2d_copy\", TV_Queue[TV_Queue.size()-1].size(), TV_Queue.size());\n            ret = $fread(trans_depth, fp);\n            if (ret != 8) `uvm_fatal(this.get_full_name(), \"diagnostic: incomplete 8-byte trailer/header\");\n            diag_fread_bytes += ret;\n            diag_last_ftell = $ftell(fp);\n            diag_stage(\"reader_after_trailer\", trans_depth, diag_fread_bytes);\n")
    (RTL / "file_read_agent.sv").write_text(reader)

    memory = (RTL / "mem_model.sv").read_text()
    memory = replace_once(memory,
        "        mem = new[depth];\n        IsWr = new[depth];\n        for(int i=0; i<depth; i++) IsWr[i] = 0;\n",
        "        mem = new[depth];\n        diag_stage(\"mem_after_mem_alloc\", depth, WIDTH);\n        IsWr = new[depth];\n        diag_stage(\"mem_after_iswr_alloc\", depth, WIDTH);\n        for(int i=0; i<depth; i++) IsWr[i] = 0;\n        diag_stage(\"mem_after_iswr_clear\", depth, WIDTH);\n")
    memory = replace_once(memory,
        "    int is_binary;\n\n    `uvm_object_param_utils_begin(mem_model_pages#(DATA_WIDTH,ELE_WIDTH))",
        "    int is_binary;\n    longint diag_copy_count = 0;\n\n    `uvm_object_param_utils_begin(mem_model_pages#(DATA_WIDTH,ELE_WIDTH))")
    memory = replace_once(memory,
        "            if(ispagechk) continue;\n            for(int j=0; j<fr.TV_Queue[i].size; j++)\n                for(int k=0; k<elenum; k++) \n                    void'(blk.write_one_elem( (fr.TV_Queue[i][j]>>(k*ELE_WIDTH)) & (2**ELE_WIDTH-1), j*elenum+k+offset ));\n",
        "            if(ispagechk) continue;\n            diag_stage(\"pages_before_copy\", fr.TV_Queue[i].size(), elenum);\n            for(int j=0; j<fr.TV_Queue[i].size; j++)\n                for(int k=0; k<elenum; k++) begin\n                    void'(blk.write_one_elem( (fr.TV_Queue[i][j]>>(k*ELE_WIDTH)) & (2**ELE_WIDTH-1), j*elenum+k+offset ));\n                    diag_copy_count++;\n                end\n            diag_stage(\"pages_after_copy\", diag_copy_count, pages.size());\n")
    memory = replace_once(memory,
        "                min_offset = (min_offset>frtmp.TV_Queue[0][0]) ? frtmp.TV_Queue[0][0] : min_offset;\n            end while(maxi_bundlevar_fpath.next(varname));\n",
        "                min_offset = (min_offset>frtmp.TV_Queue[0][0]) ? frtmp.TV_Queue[0][0] : min_offset;\n                diag_stage(\"offset_bound\", frtmp.TV_Queue[0][0], maxi_bundlevar_offset.num());\n            end while(maxi_bundlevar_fpath.next(varname));\n")
    (RTL / "mem_model.sv").write_text(memory)

    fixture = TV_ORIGINAL / "c.attention_slice.autotvin_fixture.dat"
    offset = TV_ORIGINAL / "c.attention_slice.autotvin_fixture_r.dat"
    payload = fixture.read_bytes()
    if len(payload) != 8 + 786432 + 8 or struct.unpack(">Q", payload[:8])[0] != 786432 or payload[-8:] != TRAILER:
        raise ValueError("frozen fixture frame length/header/trailer mismatch")
    payload = payload[8:-8]
    shutil.copyfile(offset, DATA / "offset_r.dat")
    for depth in DEPTHS:
        (DATA / f"tv_{depth}.dat").write_bytes(struct.pack(">Q", depth) + payload[:depth] + TRAILER)
        (DATA / f"raw_{depth}.dat").write_bytes(payload[:depth])
        frame = (DATA / f"tv_{depth}.dat").read_bytes()
        if len(frame) != depth + 16 or struct.unpack(">Q", frame[:8])[0] != depth or frame[-8:] != TRAILER or frame[8:-8] != payload[:depth]:
            raise ValueError(f"generated TV verification failed: {depth}")

    diffs = []
    for name in files:
        original = (RAW / name).read_text().splitlines(keepends=True)
        modified = (RTL / name).read_text().splitlines(keepends=True)
        diffs.extend(difflib.unified_diff(original, modified, fromfile=f"original/{name}", tofile=f"rtl/{name}"))
    (HERE / "instrumentation.diff").write_text("".join(diffs))
    artifacts = [*RAW.glob("*"), *RTL.glob("*"), *DATA.glob("*"), fixture, offset, HERE / "instrumentation.diff", Path(__file__)]
    manifest = {"original_source_directory": str(ORIGINAL), "fixture_source": str(fixture), "offset_source": str(offset),
                "depths": DEPTHS, "artifacts": {str(p.resolve()): {"sha256": sha(p), "bytes": p.stat().st_size} for p in sorted(artifacts)}}
    (HERE / "source_manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
