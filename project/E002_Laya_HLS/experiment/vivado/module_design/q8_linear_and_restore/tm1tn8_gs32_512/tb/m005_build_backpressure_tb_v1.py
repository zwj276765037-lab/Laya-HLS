#!/usr/bin/env python3
"""Derive a deterministic external-memory stress profile for the same M005 top.

Only the testbench's response timing changes. The DUT, fixture, reference,
descriptor sequence, and final checks must retain their normal-run identities.
"""

import argparse
from pathlib import Path


SEED = "32'h5a17"
REPLACEMENTS = (
    ("  logic output_seen[0:20991];", "  localparam int M005_BP_SEED = " + SEED + ";\n"
     "  logic output_seen[0:20991];"),
    ("cycle%3!=pp", "((cycle+M005_BP_SEED+pp*3)%11)>=3"),
    ("cycle%3!=0", "((cycle+M005_BP_SEED)%7)>=2"),
    ("m_axi_awready[0]=rst_n && !aw_seen && cycle%7!=0;",
     "m_axi_awready[0]=rst_n && !aw_seen && ((cycle+M005_BP_SEED)%9)>=2;"),
    ("m_axi_wready[0]=rst_n && !w_seen && cycle%11!=0;",
     "m_axi_wready[0]=rst_n && !w_seen && ((cycle+M005_BP_SEED)%13)>=3;"),
    ("bdelay=17+(output_beats%3);", "bdelay=20+(output_beats%5);"),
    ("ffn_down_read_pending && !ffn_down_rvalid)begin",
     "ffn_down_read_pending && !ffn_down_rvalid &&\n"
     "       ((cycle+M005_BP_SEED)%4)!=0)begin"),
    ("ffn_res_aw_seen && !ffn_res_bvalid &&\n                    cycle%7!=0;",
     "ffn_res_aw_seen && !ffn_res_bvalid &&\n"
     "                    ((cycle+M005_BP_SEED)%9)>=2;"),
    ("ffn_res_w_seen && !ffn_res_bvalid &&\n                   cycle%11!=0;",
     "ffn_res_w_seen && !ffn_res_bvalid &&\n"
     "                   ((cycle+M005_BP_SEED)%13)>=3;"),
    ("ffn_res_bdelay=12+(ffn_res_write_beats%3);",
     "ffn_res_bdelay=15+(ffn_res_write_beats%5);"),
    ("wi_arready=rst_n && !wi_read_active && !wi_rvalid && cycle%5!=0;",
     "wi_arready=rst_n && !wi_read_active && !wi_rvalid &&\n"
     "               ((cycle+M005_BP_SEED)%7)>=2;"),
    ("wi_rdelay=1+(wi_read_beats%4);",
     "wi_rdelay=2+(wi_read_beats%4);"),
    ("g_m_axi_awready=rst_n && !g_aw_seen && cycle%7!=0;",
     "g_m_axi_awready=rst_n && !g_aw_seen &&\n"
     "                     ((cycle+M005_BP_SEED)%9)>=2;"),
    ("g_m_axi_wready=rst_n && !g_w_seen && cycle%11!=0;",
     "g_m_axi_wready=rst_n && !g_w_seen &&\n"
     "                    ((cycle+M005_BP_SEED)%13)>=3;"),
    ("g_m_axi_arready=rst_n && !g_read_active && !g_m_axi_rvalid && cycle%5!=0;",
     "g_m_axi_arready=rst_n && !g_read_active && !g_m_axi_rvalid &&\n"
     "                     ((cycle+M005_BP_SEED)%7)>=2;"),
    ("g_bdelay=17+(index%3);", "g_bdelay=20+(index%5);"),
    ("g_rdelay=1+(g_read_beats%4);",
     "g_rdelay=2+(g_read_beats%4);"),
    ("    pilot=$test$plusargs(\"PILOT\");",
     "    pilot=$test$plusargs(\"PILOT\");\n"
     "    $display(\"M005_BACKPRESSURE_PROFILE seed=%h read=1 write=1 B=1 hold=11\", M005_BP_SEED);"),
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--normal-tb", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    source = args.normal_tb.read_text()
    for old, new in REPLACEMENTS:
        if source.count(old) != 1:
            raise ValueError(f"testbench anchor changed: {old!r}")
        source = source.replace(old, new, 1)
    if source.count("repeat(7)begin") != 5:
        raise ValueError("expected five independent held-response checks")
    source = source.replace("repeat(7)begin", "repeat(11)begin")
    if source.count("module m005_ffn_top_tb_v1;") != 1:
        raise ValueError("unexpected testbench top")
    args.out.write_text(source)
    print("M005_BACKPRESSURE_TB_READY seed=0x5a17 held_response_cycles=11")


if __name__ == "__main__":
    main()
