#!/usr/bin/env python3
"""Build the bounded GQD0 diagnostic TB from the frozen Down observation TB.

Only the diagnostic driver changes: physical G bridge produces the shared
dual-A, and the existing Down DUT consumes it. The old TB stays untouched.
"""
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
MODULE = HERE.parents[2]
BRIDGE = MODULE / "activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv"
BASE = HERE / "tm4tn8_down_measurement_tb_v1.sv"
OUT = HERE / "gqd0_chain_tb_v1.sv"


def once(s, old, new):
    assert s.count(old) == 1, (old[:80], s.count(old))
    return s.replace(old, new)


def bridge_ports():
    header = BRIDGE.read_text().split(");", 1)[0]
    ports = []
    for raw in header.splitlines():
        line = raw.strip().rstrip(",")
        if not line or line.startswith(("//", "module ", "`timescale")):
            continue
        match = re.fullmatch(r"(input|output) logic(?: (\[[^ ]+\]))? (.+)", line)
        assert match, raw
        direction, width, names = match.groups()
        for name in names.split(","):
            ports.append((direction, width or "", name.strip()))
    return ports


def map_port(name):
    if name in {"clk", "rst_n"}:
        return name
    if name.startswith(("acquire_", "read_", "ret_", "release_")):
        return "a_" + name
    aliases = {
        "read_debt_zero": "a_read_debt_zero",
        "slot_state": "fa_slot_state",
        "slot_epoch": "fa_slot_epoch",
        "slot_rows_done": "fa_slot_rows_done",
        "physical_half_commits": "fa_physical_half_commits",
        "physical_scale_commits": "fa_physical_scale_commits",
    }
    return aliases.get(name, "g_" + name)


def main():
    s = BASE.read_text()
    s = once(s, "module tm4tn8_matrix_resident_tb_v2;", "module gqd0_chain_tb_v1;")
    s = once(s, "// Local physical-cache test with immutable prequantized A input. No G/quant/13BO binding proof.",
             "// Four-row same-runtime real GATE AXI -> quant -> shared dualA -> KB1 Down.")
    start = s.index("  quant_dual_a_v1 astore (")
    end = s.index("  t4_dual_w_cache_v1 wcache (", start)
    ports = bridge_ports()
    decls = []
    for _, width, name in ports:
        if map_port(name) == "g_" + name:
            decls.append(f"  logic {width} g_{name};")
    connection = ",\n".join(f"    .{name}({map_port(name)})" for _, _, name in ports)
    inst = "\n".join(decls) + "\n  geglu_gate_quant_bridge_v1 producer (\n" + connection + "\n  );\n"
    s = s[:start] + inst + s[end:]
    s = once(s, "if(fa_fill_valid && fa_fill_ready && measure_a_start<0)measure_a_start=cycle;",
             "if(g_cfg_valid && g_cfg_ready && !g_cfg_reject && measure_a_start<0)measure_a_start=cycle;")
    s = once(s, '    $readmemh({afixture,"/q.mem"},aq);',
             '    $readmemh({gfixture,"/wi.mem"},wi_fixture);$readmemh({gfixture,"/gate.mem"},gate_gold);\n'
             '    $readmemh({gfixture,"/d.mem"},d_gold);$readmemh({gfixture,"/recip.mem"},recip_gold);\n'
             '    $readmemh({afixture,"/q.mem"},aq);')
    s = once(s, '|| !$value$plusargs("STREAMS=%s",streams))',
             '|| !$value$plusargs("STREAMS=%s",streams) || !$value$plusargs("GFIXTURE=%s",gfixture))')
    s = once(s, "cfg_linear_context[87:72]=7;cfg_linear_context[95:88]=4;",
             "cfg_linear_context[63:56]=1;cfg_linear_context[87:72]=7;cfg_linear_context[95:88]=4;")
    assert s.count("cfg_region_base[0]+7*4096") == 2
    s = s.replace("cfg_region_base[0]+7*4096", "cfg_region_base[0]+cfg_batch_stride_bytes+7*4096")
    s = once(s, "cfg_region_base[0]+11*4096", "cfg_region_base[0]+cfg_batch_stride_bytes+11*4096")
    begin = s.index("    @(negedge clk);\n    fa_fill_owner_admitted=1;")
    end = s.index("    wc_load_slot=0;", begin)
    s = s[:begin] + '''    @(negedge clk);
    g_cfg_numeric_identity=cfg_numeric_identity;
    g_cfg_producer_context=cfg_linear_context;
    g_cfg_producer_context[31:0]=32'hac000001;
    g_cfg_producer_context[39:32]=8'h60;
    g_cfg_quant_context=cfg_linear_context;
    g_cfg_quant_context[31:0]=32'hac000002;
    g_cfg_quant_context[39:32]=8'h61;
    g_cfg_linear_context=cfg_linear_context;
    g_cfg_wi_ref=64'h0000000600000001;
    g_cfg_gate_ref=cfg_source_ref;
    g_cfg_a_ref=cfg_a_ref;g_cfg_w_ref=cfg_w_ref;g_cfg_down_dst_ref=cfg_dst_ref;
    g_cfg_rows=4;g_cfg_a_slot=cfg_a_slot;g_cfg_a_slot_epoch=cfg_a_epoch;
    g_cfg_bo_base=64'h100000000;g_cfg_bo_span=64'h3000000;
    g_cfg_region_base=g_cfg_bo_base+4096;g_cfg_region_span=64'h2000000;
    g_first_addr=g_cfg_region_base+10747904+7*10496;
    // The original outer admission rejection remains a zero-issue check.
    g_cfg_owner_admitted=0;g_cfg_valid=1;
    @(posedge clk);while(!g_cfg_ready)@(posedge clk);#1;
    if(!g_cfg_reject || g_aw_count!=0 || producer.vector_row.issued!=0 || g_quant_starts!=0)
      $fatal(1,"GQD0 rejected G admission issued work");
    @(negedge clk);g_cfg_valid=0;g_cfg_owner_admitted=1;tick();
    @(negedge clk);g_cfg_valid=1;tick();
    if(g_cfg_reject)$fatal(1,"GQD0 legal G command rejected");
    @(negedge clk);g_cfg_valid=0;
    $display("MATRIX_PROGRESS cycle=%0d GQD0_cfg_accepted=1",cycle);
    for(int row=0;row<4;row++)begin
      integer held_issued,held_aw;
      for(int col=0;col<5248;col++)begin
        @(negedge clk);g_wi_valid=1;g_wi_data=wi_fixture[row*5248+col];
        g_wi_status=0;g_wi_numeric_identity=g_cfg_numeric_identity;
        g_wi_source_ref=g_cfg_wi_ref;g_wi_row=16'(7+row);g_wi_index=13'(col);
        @(posedge clk);while(!g_wi_ready)@(posedge clk);#1;
      end
      @(negedge clk);g_wi_valid=0;g_wi_row_done_valid=1;
      g_wi_row_done_status=0;g_wi_read_debt_zero=0;
      held_issued=producer.vector_row.issued;held_aw=g_aw_count;
      repeat(19)begin tick();if(g_wi_row_done_ready ||
        producer.vector_row.issued!=held_issued || g_aw_count!=held_aw)
        $fatal(1,"GQD0 Wi read barrier row=%0d",row);end
      @(negedge clk);g_wi_read_debt_zero=1;
      @(posedge clk);while(!g_wi_row_done_ready)@(posedge clk);#1;
      @(negedge clk);g_wi_row_done_valid=0;
      $display("MATRIX_PROGRESS cycle=%0d GQD0_Wi_row=%0d gate_W=%0d gate_B=%0d",cycle,row,g_w_count,g_b_count);
      if(pilot && row==0)begin
        while(g_b_count<164)tick();
        if(g_w_count!=164 || g_aw_count!=164 || g_b_count!=164)
          $fatal(1,"GQD0 first physical GATE row coverage");
        $display("GQD0_PILOT_PASS cycle=%0d real_Wi_words=5248 gate_AW=164 gate_W=164 gate_B=164 quant_and_Down=NOT_RUN",cycle);
        $finish;
      end
    end
    while(!g_done_valid)tick();
    if(g_done_status!=0 || g_gate_owner_state!=0 || fa_slot_state[0]!=2 ||
       fa_slot_rows_done[0]!=16'hf || g_quant_starts!=4 || g_quant_rows!=4 ||
       g_quant_input_beats!=656 || fa_physical_half_commits!=656 ||
       fa_physical_scale_commits!=328 || g_source_complete_rows!=4 ||
       g_source_r_count!=656 || g_write_beats!=656 || g_read_beats!=656 ||
       g_quant_halves!=656)
      $fatal(1,"GQD0 bridge completion/physical debt");
    repeat(7)begin tick();if(!g_done_valid || fa_slot_state[0]!=2)
      $fatal(1,"GQD0 held bridge response");end
    @(negedge clk);g_done_ready=1;tick();
    @(negedge clk);g_done_ready=0;tick();
    if(g_done_valid || fa_slot_state[0]!=2)$fatal(1,"GQD0 bridge consume");
    measure_a_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d GQD0_A_ready=1 gate_AW=%0d gate_W=%0d gate_B=%0d gate_AR=%0d gate_R=%0d quant_groups=%0d",cycle,g_aw_count,g_w_count,g_b_count,g_source_ar_count,g_source_r_count,fa_physical_scale_commits);
''' + s[end:]
    s = once(s, "    measurement_report(\"full\");\n    $display(\"TM4_MATRIX_RESIDENT_FULL_PASS",
             "    measurement_report(\"full\");\n    $display(\"GQD0_CHAIN_PASS gate_W=%0d gate_R=%0d quant_groups=%0d Down_A_reads=%0d Down_A_returns=%0d Down_AW=%0d Down_W=%0d Down_B=%0d cycle=%0d\",g_write_beats,g_read_beats,fa_physical_scale_commits,actual_a_reads,actual_a_returns,actual_aw_count[0],actual_w_count[0],actual_b_count[0],cycle);\n    $display(\"TM4_MATRIX_RESIDENT_FULL_PASS")
    s = once(s, "A_fixture_prequantized=1", "A_fixture_prequantized=0")
    s = once(s, "  initial begin : run", GATE_MONITOR + "\n  initial begin : run")
    s = once(s, "    rst_n=0;", GATE_INIT + "\n    rst_n=0;")
    OUT.write_text(s)


GATE_MONITOR = r'''
  logic [31:0] wi_fixture[0:20991],gate_gold[0:10495],d_gold[0:327],recip_gold[0:327];
  logic [511:0] gate_mem[0:2623];
  logic gate_written[0:2623];
  string gfixture;
  integer g_write_beats=0,g_read_beats=0,g_quant_halves=0,g_held_b=0;
  integer g_bdelay=0,g_rdelay=0,g_rleft=0,g_rindex=0;
  logic g_aw_seen=0,g_w_seen=0,g_stored=0,g_read_active=0;
  logic [63:0] g_aw_addr,g_first_addr;
  logic [511:0] g_w_data;
  always @(negedge clk)begin
    g_m_axi_awready=rst_n && !g_aw_seen && cycle%7!=0;
    g_m_axi_wready=rst_n && !g_w_seen && cycle%11!=0;
    g_m_axi_arready=rst_n && !g_read_active && !g_m_axi_rvalid && cycle%5!=0;
    if(g_bdelay>0)begin
      g_bdelay--;g_held_b++;
      if(g_bdelay==0)begin g_m_axi_bvalid=1;g_m_axi_bresp=0;end
    end
    if(g_read_active && !g_m_axi_rvalid)begin
      if(g_rdelay>0)g_rdelay--;
      else begin
        if(!gate_written[g_rindex])$fatal(1,"GQD0 quant read unwritten GATE beat=%0d",g_rindex);
        g_m_axi_rvalid=1;g_m_axi_rdata=gate_mem[g_rindex];
        g_m_axi_rresp=0;g_m_axi_rlast=g_rleft==1;
      end
    end
  end
  always @(posedge clk)begin
    if(!rst_n)begin
      g_aw_seen=0;g_w_seen=0;g_stored=0;g_read_active=0;
      g_bdelay=0;g_rdelay=0;g_rleft=0;
      g_m_axi_bvalid<=0;g_m_axi_rvalid<=0;
      for(int i=0;i<2624;i++)gate_written[i]=0;
    end else begin
      if(g_m_axi_awvalid && g_m_axi_awready)begin
        if(g_aw_seen || g_m_axi_awsize!=6 || g_m_axi_awlen!=0 || g_m_axi_awburst!=1)
          $fatal(1,"GQD0 GATE AW");
        g_aw_seen=1;g_aw_addr=g_m_axi_awaddr;
      end
      if(g_m_axi_wvalid && g_m_axi_wready)begin
        if(g_w_seen || g_m_axi_wstrb!==64'hffffffffffffffff || !g_m_axi_wlast)
          $fatal(1,"GQD0 GATE W");
        g_w_seen=1;g_w_data=g_m_axi_wdata;
      end
      if(g_aw_seen && g_w_seen && !g_stored)begin
        int index;
        if(g_aw_addr!==g_first_addr+64'(g_write_beats)*64)
          $fatal(1,"GQD0 GATE physical address");
        index=int'((g_aw_addr-g_first_addr)>>6);
        for(int lane=0;lane<16;lane++)
          if(g_w_data[lane*32+:32]!==gate_gold[index*16+lane])
            $fatal(1,"GQD0 GATE gold row=%0d col=%0d",index/164,(index%164)*16+lane);
        gate_mem[index]=g_w_data;gate_written[index]=1;
        g_stored=1;g_write_beats++;g_bdelay=17+(index%3);
      end
      if(g_m_axi_bvalid && g_m_axi_bready)begin
        g_m_axi_bvalid<=0;g_aw_seen=0;g_w_seen=0;g_stored=0;
      end
      if(g_m_axi_arvalid && g_m_axi_arready)begin
        if(g_gate_owner_state!=3 || g_aw_count!=656 || g_b_count!=656 ||
           g_m_axi_arsize!=6 || g_m_axi_arburst!=1 ||
           g_m_axi_araddr<g_first_addr ||
           g_m_axi_araddr+64'(g_m_axi_arlen+1)*64>g_first_addr+4*10496 ||
           g_m_axi_araddr[11:0]+(int'(g_m_axi_arlen)+1)*64>4096)
          $fatal(1,"GQD0 quant AR publication/bounds");
        g_read_active=1;g_rindex=int'((g_m_axi_araddr-g_first_addr)>>6);
        g_rleft=int'(g_m_axi_arlen)+1;g_rdelay=3;
      end
      if(g_m_axi_rvalid && g_m_axi_rready)begin
        g_m_axi_rvalid<=0;g_rindex++;g_rleft--;g_read_beats++;
        g_rdelay=1+(g_read_beats%4);
        if(g_rleft==0)g_read_active=0;
      end
      if(producer.quant_task.q_out_valid && producer.quant_task.q_out_ready)begin
        int g,h;
        g=int'(producer.quant_task.active_row)*82+int'(producer.quant_task.q_out_group);
        h=producer.quant_task.q_out_half;
        if(producer.quant_task.q_out!==aq[g][h*128+:128] ||
           producer.quant_task.q_d!==d_gold[g] ||
           producer.quant_task.q_recip!==recip_gold[g] ||
           (h && producer.quant_task.q_scale!==asc[g]))
          $fatal(1,"GQD0 quant gold group=%0d half=%0d",g,h);
        g_quant_halves++;
      end
    end
  end
'''

GATE_INIT = r'''
    g_cfg_valid=0;g_cfg_owner_admitted=0;g_cfg_numeric_identity=0;
    g_cfg_producer_context=0;g_cfg_quant_context=0;g_cfg_linear_context=0;
    g_cfg_wi_ref=0;g_cfg_gate_ref=0;g_cfg_a_ref=0;g_cfg_w_ref=0;
    g_cfg_down_dst_ref=0;g_cfg_rows=0;g_cfg_a_slot=0;g_cfg_a_slot_epoch=0;
    g_cfg_bo_base=0;g_cfg_bo_span=0;g_cfg_region_base=0;g_cfg_region_span=0;
    g_wi_valid=0;g_wi_data=0;g_wi_status=0;g_wi_numeric_identity=0;
    g_wi_source_ref=0;g_wi_row=0;g_wi_index=0;g_wi_row_done_valid=0;
    g_wi_row_done_status=0;g_wi_row_bad_element=0;g_wi_read_debt_zero=0;
    g_done_ready=0;g_m_axi_awready=0;g_m_axi_wready=0;
    g_m_axi_bresp=0;g_m_axi_bvalid=0;g_m_axi_arready=0;
    g_m_axi_rdata=0;g_m_axi_rresp=0;g_m_axi_rlast=0;g_m_axi_rvalid=0;
'''

if __name__ == "__main__":
    main()
