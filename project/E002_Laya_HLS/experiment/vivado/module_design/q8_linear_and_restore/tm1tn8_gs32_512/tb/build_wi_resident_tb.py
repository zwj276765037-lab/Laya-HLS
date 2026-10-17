#!/usr/bin/env python3
"""Derive the WI0 observation TB from the frozen KB1 resident TB.

Only fixture geometry, command identity, output addressing and observation
limits change. The numerical checks, response policy and real cache/AXI paths
remain in the inherited TB.
"""
from pathlib import Path


ROOT = Path(__file__).resolve().parents[5]
PROJECT = ROOT.parents[2]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
BASE = (PROJECT / "project/E005_full_request_performance/experiment_results/runs/R001"
        "/attempts/AT002_KB1_Down_rowpack/evidence/measurement/frozen" / MODULE
        / "tb/tm4tn8_matrix_resident_tb_v2.sv")
OUT = ROOT / MODULE / "tb/tm4tn8_wi_resident_tb_v1.sv"


def change(text: str, before: str, after: str, count: int = 1) -> str:
    found = text.count(before)
    if found != count:
        raise RuntimeError(f"WI0 derivation anchor expected {count}, found {found}: {before[:90]}")
    return text.replace(before, after)


def main() -> None:
    s = BASE.read_text()
    s = change(s, "tm4tn8_matrix_resident_tb_v2", "tm4tn8_wi_resident_tb_v1")
    s = s.replace("DOWN_MEASURE_", "WI_MEASURE_")
    s = change(s, "expected_output_beats=512;", "expected_output_beats=1312;", 2)
    s = change(s, "measure_useful_bytes!=16384", "measure_useful_bytes!=83968")
    s = change(s, "logic [255:0] aq[0:327];logic [15:0] asc[0:327];logic [31:0] outgold[0:4095];",
               "logic [255:0] aq[0:127];logic [15:0] asc[0:127];logic [31:0] outgold[0:20991];")
    s = change(s, "logic [511:0] wq0[0:20991],wq1[0:20991],wsc[0:2623];",
               "logic [511:0] wq0[0:41983],wq1[0:41983],wsc[0:5247];")
    s = change(s, "logic [2047:0] vw[0:10495];logic [1023:0] vps[0:10495];",
               "logic [2047:0] vw[0:20991];logic [1023:0] vps[0:20991];")
    s = change(s, "logic output_seen[0:4095];", "logic output_seen[0:20991];")
    s = change(s, "aq[r*82+int'(a_ret_group)]", "aq[r*32+int'(a_ret_group)]")
    s = change(s, "asc[r*82+int'(a_ret_group)]", "asc[r*32+int'(a_ret_group)]")
    s = change(s, "seq=w_checks;g=seq/128;t=seq%128;",
               "seq=w_checks;g=seq/656;t=seq%656;")
    s = change(s, "aw_addr<cfg_region_base[0]+7*4096 || aw_addr>=cfg_region_base[0]+11*4096",
               "aw_addr<cfg_region_base[0] || aw_addr>=cfg_region_base[0]+83968")
    s = change(s, "(aw_addr-(cfg_region_base[0]+7*4096))/4",
               "(aw_addr-cfg_region_base[0])/4")
    s = change(s, "idx+lane>=4096", "idx+lane>=20992")
    s = change(s, "output_words!=4096", "output_words!=20992", 2)
    s = change(s, "for(int i=0;i<4096;i++)output_seen[i]=0;",
               "for(int i=0;i<20992;i++)output_seen[i]=0;")
    s = change(s, "expected_output_beats!=512 && expected_output_beats!=256",
               "expected_output_beats!=1312")
    s = change(s, '"/down_config.hex"', '"/wi_config.hex"')
    s = change(s, '"/down_q0.hex"', '"/wi_q0.hex"')
    s = change(s, '"/down_q1.hex"', '"/wi_q1.hex"')
    s = change(s, '"/down_scale.hex"', '"/wi_scale.hex"')
    s = change(s, "cfg_K=2624;cfg_N=1024;cfg_rows=4;", "cfg_K=1024;cfg_N=5248;cfg_rows=4;")
    s = change(s, "cfg_linear_context[39:32]=8'h33;", "cfg_linear_context[39:32]=8'h32;")
    s = change(s, "cfg_linear_context[87:72]=7;", "cfg_linear_context[87:72]=0;")
    s = change(s, "cfg_dst_ref=64'h0000000300000001;", "cfg_dst_ref=64'h0000000600000001;")
    s = change(s, "cfg_source_ref=64'h0000000700000001;",
               "cfg_source_ref=64'h0000000200000001;")
    s = change(s, "cfg_weight_key=4;", "cfg_weight_key=3;")
    s = change(s, "cfg_row_stride_bytes=4096;cfg_batch_stride_bytes=4194304;",
               "cfg_row_stride_bytes=20992;cfg_batch_stride_bytes=21495808;")
    s = change(s, "fa_fill_K=2624;", "fa_fill_K=1024;")
    s = change(s, "for(int g=0;g<82;g++)", "for(int g=0;g<32;g++)")
    s = change(s, "aq[r*82+g]", "aq[r*32+g]")
    s = change(s, "asc[r*82+g]", "asc[r*32+g]")
    s = change(s, "fa_physical_half_commits!=656 || fa_physical_scale_commits!=328",
               "fa_physical_half_commits!=256 || fa_physical_scale_commits!=128")
    s = change(s, "wc_load_k=2624;wc_load_n=1024;wc_load_weight_key=4;",
               "wc_load_k=1024;wc_load_n=5248;wc_load_weight_key=3;")
    s = change(s, "wc_load_scale_checks!=83968", "wc_load_scale_checks!=167936")
    s = change(s, "actual_stripes!=10496 || actual_ps_commits!=41984 || actual_final_copies!=512 || a_checks!=82 || w_checks!=10496",
               "actual_stripes!=20992 || actual_ps_commits!=83968 || actual_final_copies!=2624 || a_checks!=32 || w_checks!=20992")
    s = change(s, "actual_a_reads!=82 || actual_a_returns!=82 || actual_w_reads!=10496 || actual_w_returns!=10496",
               "actual_a_reads!=32 || actual_a_returns!=32 || actual_w_reads!=20992 || actual_w_returns!=20992")
    s = change(s, "ps_checks[r]!=10496", "ps_checks[r]!=20992")
    s = change(s, "TM4_MATRIX_RESIDENT_FULL_PASS rows=4 K=2624 N=1024 real_stripes=%0d PS_lane_groups=335872",
               "WI_RESIDENT_FULL_PASS rows=4 K=1024 N=5248 real_stripes=%0d PS_lane_groups=671744")
    s = change(s, "TM4_MATRIX_RESIDENT_PILOT_PASS", "WI_RESIDENT_PILOT_PASS")
    s = change(s, "Down declared physical beat coverage", "Wi declared physical beat coverage")
    s = change(
        s,
        "q_index[pp]<=q_index[pp]+1;q_left[pp]<=q_left[pp]-1;q_beats[pp]<=q_beats[pp]+1;if(wc_rlast[pp])q_active[pp]<=0;",
        "q_index[pp]<=q_index[pp]+1;q_left[pp]<=q_left[pp]-1;q_beats[pp]<=q_beats[pp]+1;"
        "if(pp==0 && (q_beats[0]+1)%512==0)"
        "$display(\"MATRIX_PROGRESS cycle=%0d Wi_W_q0_R=%0d q1_R=%0d scale_R=%0d\","
        "cycle,q_beats[0]+1,q_beats[1],q_beats[2]);"
        "if(wc_rlast[pp])q_active[pp]<=0;")
    s = change(
        s,
        "      if(wc_aux_arvalid && wc_aux_arready)begin",
        "      if(pilot && q_beats[0]>=1024 && q_beats[1]>=1024 && q_beats[2]>=128)begin\n"
        "        if(fa_slot_state[0]!=2 || fa_physical_half_commits!=256 || fa_physical_scale_commits!=128)"
        "$fatal(1,\"WI pilot A publication lost\");\n"
        "        $display(\"WI_RESIDENT_PILOT_PASS cycle=%0d physical_A_halves=%0d physical_A_scales=%0d "
        "W_q0_R=%0d W_q1_R=%0d W_scale_R=%0d W_ready=NOT_RUN PS=NOT_RUN output_B=NOT_RUN\","
        "cycle,fa_physical_half_commits,fa_physical_scale_commits,q_beats[0],q_beats[1],q_beats[2]);\n"
        "        measurement_report(\"pilot\");$finish;\n"
        "      end\n"
        "      if(wc_aux_arvalid && wc_aux_arready)begin")
    OUT.write_text(s)
    print(f"WI_RESIDENT_TB_DERIVED {OUT} bytes={OUT.stat().st_size}")


if __name__ == "__main__":
    main()
