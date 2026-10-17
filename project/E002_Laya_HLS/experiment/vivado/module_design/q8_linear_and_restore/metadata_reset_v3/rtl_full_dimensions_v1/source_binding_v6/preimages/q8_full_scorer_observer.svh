  // Passive, fixed-capacity observations. No writes or forces into the DUT.
  localparam int O_PORTS = 9;
  localparam int O_CHANNELS = 5; // AW W B AR R
  integer o_lite_aw [0:COMMANDS-1], o_lite_w [0:COMMANDS-1];
  integer o_ap_accept [0:COMMANDS-1], o_ap_done [0:COMMANDS-1];
  integer o_issues [0:COMMANDS-1], o_first_issue [0:COMMANDS-1];
  integer o_retires [0:COMMANDS-1], o_first_retire [0:COMMANDS-1];
  integer o_last_retire [0:COMMANDS-1];
  integer o_last_issue [0:COMMANDS-1], o_max_issue_gap [0:COMMANDS-1];
  integer o_issue_hist [0:COMMANDS-1][0:4];
  integer o_issue_first_g [0:COMMANDS-1][0:7];
  integer o_issue_first_t [0:COMMANDS-1][0:7];
  integer o_issue_first_clk [0:COMMANDS-1][0:7];
  integer o_issue_last_g [0:COMMANDS-1][0:7];
  integer o_issue_last_t [0:COMMANDS-1][0:7];
  integer o_issue_last_clk [0:COMMANDS-1][0:7];
  integer o_fp_mul_lane0 [0:COMMANDS-1], o_fp_add_lane0 [0:COMMANDS-1];
  integer o_ps_reads [0:COMMANDS-1], o_ps_writes [0:COMMANDS-1];
  integer o_ps_use_count [0:COMMANDS-1], o_ps_use_min [0:COMMANDS-1];
  integer o_ps_use_max [0:COMMANDS-1];
  integer o_ps_write_clock [0:655], o_ps_write_seen [0:655];
  integer o_dut_stall [0:COMMANDS-1][0:O_PORTS-1][0:O_CHANNELS-1];
  integer o_ram_stall [0:COMMANDS-1][0:O_PORTS-1][0:O_CHANNELS-1];
  integer o_stall_intersection [0:COMMANDS-1];
  integer o_max_aw_debt [0:COMMANDS-1][0:O_PORTS-1];
  integer o_max_ar_debt [0:COMMANDS-1][0:O_PORTS-1];
  integer o_done_debt_checked [0:COMMANDS-1];
  // Subcall IDs: q-load, scale-load, activation-load, quant scan, quant pack.
  // Start counts are rising request markers. Done counts are rising completion
  // markers. Neither is mislabeled as a child acceptance handshake.
  integer o_sub_starts [0:COMMANDS-1][0:4], o_sub_dones [0:COMMANDS-1][0:4];
  integer o_sub_first_start [0:COMMANDS-1][0:4];
  integer o_sub_last_done [0:COMMANDS-1][0:4];
  bit o_sub_prev_start [0:4], o_sub_prev_done [0:4];
  // Scalar/fsm phases: scale validation, bias validation, quant-trace Q,
  // quant-trace scale, lane_bad init, output serialization, report entry.
  integer o_state_count [0:COMMANDS-1][0:6];
  integer o_state_first [0:COMMANDS-1][0:6], o_state_last [0:COMMANDS-1][0:6];

  task automatic observer_state(input int ci, input int phase);
    if (o_state_count[ci][phase]==0) o_state_first[ci][phase]=total_cycles;
    o_state_count[ci][phase]++;
    o_state_last[ci][phase]=total_cycles;
  endtask

  task automatic observer_reset_command(input int ci);
    o_lite_aw[ci]=0; o_lite_w[ci]=0;
    o_ap_accept[ci]=0; o_ap_done[ci]=0;
    o_issues[ci]=0; o_first_issue[ci]=0; o_last_issue[ci]=0;
    o_retires[ci]=0; o_first_retire[ci]=0; o_last_retire[ci]=0;
    o_done_debt_checked[ci]=0;
    o_max_issue_gap[ci]=0;
    o_fp_mul_lane0[ci]=0; o_fp_add_lane0[ci]=0;
    o_ps_reads[ci]=0; o_ps_writes[ci]=0;
    o_ps_use_count[ci]=0; o_ps_use_min[ci]=2147483647; o_ps_use_max[ci]=0;
    o_stall_intersection[ci]=0;
    for (int s=0;s<5;s++) begin
      o_sub_starts[ci][s]=0; o_sub_dones[ci][s]=0;
      o_sub_first_start[ci][s]=0; o_sub_last_done[ci][s]=0;
      o_sub_prev_start[s]=0; o_sub_prev_done[s]=0;
    end
    for (int ph=0;ph<7;ph++) begin
      o_state_count[ci][ph]=0; o_state_first[ci][ph]=0; o_state_last[ci][ph]=0;
    end
    for (int b=0;b<5;b++) o_issue_hist[ci][b]=0;
    for (int s=0;s<8;s++) begin
      o_issue_first_g[ci][s]=-1; o_issue_first_t[ci][s]=-1;
      o_issue_first_clk[ci][s]=0;
      o_issue_last_g[ci][s]=-1; o_issue_last_t[ci][s]=-1;
      o_issue_last_clk[ci][s]=0;
    end
    for (int a=0;a<656;a++) begin o_ps_write_clock[a]=0; o_ps_write_seen[a]=0; end
    for (int p=0;p<O_PORTS;p++) begin
      o_max_aw_debt[ci][p]=0; o_max_ar_debt[ci][p]=0;
      for (int ch=0;ch<O_CHANNELS;ch++) begin
        o_dut_stall[ci][p][ch]=0; o_ram_stall[ci][p][ch]=0;
      end
    end
  endtask

  // A per-channel VALID&&!READY sample is one clock, not a transaction.
  // Endpoint-side and DUT-side stalls can overlap and are reported separately.
`define Q8_OBSERVE_STALL(P,NAME) \
  if (m_axi_gmem_``NAME``_AWVALID && !m_axi_gmem_``NAME``_AWREADY) begin o_dut_stall[cmd_idx][P][0]++; any_dut_stall=1; end \
  if (m_axi_gmem_``NAME``_WVALID && !m_axi_gmem_``NAME``_WREADY) begin o_dut_stall[cmd_idx][P][1]++; any_dut_stall=1; end \
  if (m_axi_gmem_``NAME``_BVALID && !m_axi_gmem_``NAME``_BREADY) begin o_dut_stall[cmd_idx][P][2]++; any_dut_stall=1; end \
  if (m_axi_gmem_``NAME``_ARVALID && !m_axi_gmem_``NAME``_ARREADY) begin o_dut_stall[cmd_idx][P][3]++; any_dut_stall=1; end \
  if (m_axi_gmem_``NAME``_RVALID && !m_axi_gmem_``NAME``_RREADY) begin o_dut_stall[cmd_idx][P][4]++; any_dut_stall=1; end \
  if (u_port_``NAME``.e_awvalid && !u_port_``NAME``.e_awready) begin o_ram_stall[cmd_idx][P][0]++; any_ram_stall=1; end \
  if (u_port_``NAME``.e_wvalid && !u_port_``NAME``.e_wready) begin o_ram_stall[cmd_idx][P][1]++; any_ram_stall=1; end \
  if (u_port_``NAME``.e_bvalid && !u_port_``NAME``.e_bready) begin o_ram_stall[cmd_idx][P][2]++; any_ram_stall=1; end \
  if (u_port_``NAME``.e_arvalid && !u_port_``NAME``.e_arready) begin o_ram_stall[cmd_idx][P][3]++; any_ram_stall=1; end \
  if (u_port_``NAME``.e_rvalid && !u_port_``NAME``.e_rready) begin o_ram_stall[cmd_idx][P][4]++; any_ram_stall=1; end

`define Q8_OBSERVE_SUB(ID,START,DONE) \
  if ((START) && !o_sub_prev_start[ID]) begin \
    if (o_sub_starts[cmd_idx][ID]==0) o_sub_first_start[cmd_idx][ID]=total_cycles; \
    o_sub_starts[cmd_idx][ID]++; \
  end \
  if ((DONE) && !o_sub_prev_done[ID]) begin \
    o_sub_dones[cmd_idx][ID]++; o_sub_last_done[cmd_idx][ID]=total_cycles; \
  end \
  o_sub_prev_start[ID]=(START); o_sub_prev_done[ID]=(DONE);

  always @(posedge clk) begin : observe
    bit any_dut_stall, any_ram_stall;
    integer gap, address;
    if (resetn && running && cmd_idx<COMMANDS) begin
      any_dut_stall=0; any_ram_stall=0;
      if (s_axi_control_AWVALID && s_axi_control_AWREADY && o_lite_aw[cmd_idx]==0)
        o_lite_aw[cmd_idx]=total_cycles;
      if (s_axi_control_WVALID && s_axi_control_WREADY && o_lite_w[cmd_idx]==0)
        o_lite_w[cmd_idx]=total_cycles;
      if (dut.ap_CS_fsm_state1 && dut.ap_start && o_ap_accept[cmd_idx]==0)
        o_ap_accept[cmd_idx]=total_cycles;
      if (dut.ap_done && o_ap_done[cmd_idx]==0)
        o_ap_done[cmd_idx]=total_cycles;
      `Q8_OBSERVE_SUB(0,
        dut.grp_q8_joint_tm4tn8_Outline_VITIS_LOOP_521_12_fu_11720_ap_start,
        dut.grp_q8_joint_tm4tn8_Outline_VITIS_LOOP_521_12_fu_11720_ap_done)
      `Q8_OBSERVE_SUB(1,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_535_14_VITIS_LOOP_538_15_fu_11751_ap_start,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_535_14_VITIS_LOOP_538_15_fu_11751_ap_done)
      `Q8_OBSERVE_SUB(2,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_583_21_VITIS_LOOP_584_22_VITIS_LOOP_587_23_fu_11812_ap_start,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_583_21_VITIS_LOOP_584_22_VITIS_LOOP_587_23_fu_11812_ap_done)
      `Q8_OBSERVE_SUB(3,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_602_27_fu_11845_ap_start,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_602_27_fu_11845_ap_done)
      `Q8_OBSERVE_SUB(4,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_634_29_fu_11874_ap_start,
        dut.grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_634_29_fu_11874_ap_done)
      if (dut.ap_CS_fsm_state116) observer_state(cmd_idx,0);
      if (dut.ap_CS_fsm_state160) observer_state(cmd_idx,1);
      if (dut.ap_CS_fsm_state210) observer_state(cmd_idx,2);
      if (dut.ap_CS_fsm_state222) observer_state(cmd_idx,3);
      if (dut.ap_CS_fsm_state302) observer_state(cmd_idx,4);
      if (dut.ap_CS_fsm_state1637) observer_state(cmd_idx,5);
      if (dut.ap_CS_fsm_state1674) observer_state(cmd_idx,6);
      if (cmd_idx>0) begin
        // state312 is the one-cycle tile decision; !icmp accepts a real tile.
        if (dut.ap_CS_fsm_state312 && !dut.icmp_ln708_fu_23172_p2) begin
          if ($isunknown({dut.g_3_reg_6949,dut.tile_2_reg_6981}) ||
              dut.g_3_reg_6949>=32 || dut.tile_2_reg_6981>=128)
            $fatal(1,"Q8_SCORER_ISSUE_COORDINATE_UNKNOWN_OR_RANGE");
          if (dut.g_3_reg_6949 !== o_issues[cmd_idx]/128 ||
              dut.tile_2_reg_6981 !== o_issues[cmd_idx]%128)
            $fatal(1,"Q8_SCORER_ISSUE_ORDER ordinal=%0d g=%0d tile=%0d",
                   o_issues[cmd_idx],dut.g_3_reg_6949,dut.tile_2_reg_6981);
          if (o_issues[cmd_idx]==0) o_first_issue[cmd_idx]=total_cycles;
          else begin
            gap=total_cycles-o_last_issue[cmd_idx];
            if (gap>o_max_issue_gap[cmd_idx]) o_max_issue_gap[cmd_idx]=gap;
            if (gap<=1) o_issue_hist[cmd_idx][0]++;
            else if (gap<=8) o_issue_hist[cmd_idx][1]++;
            else if (gap<=64) o_issue_hist[cmd_idx][2]++;
            else if (gap<=512) o_issue_hist[cmd_idx][3]++;
            else o_issue_hist[cmd_idx][4]++;
          end
          if (o_issues[cmd_idx]<8) begin
            o_issue_first_g[cmd_idx][o_issues[cmd_idx]]=dut.g_3_reg_6949;
            o_issue_first_t[cmd_idx][o_issues[cmd_idx]]=dut.tile_2_reg_6981;
            o_issue_first_clk[cmd_idx][o_issues[cmd_idx]]=total_cycles;
          end
          address=o_issues[cmd_idx]%8;
          o_issue_last_g[cmd_idx][address]=dut.g_3_reg_6949;
          o_issue_last_t[cmd_idx][address]=dut.tile_2_reg_6981;
          o_issue_last_clk[cmd_idx][address]=total_cycles;
          o_last_issue[cmd_idx]=total_cycles;
          o_issues[cmd_idx]++;
          if (o_issues[cmd_idx]>4096)
            $fatal(1,"Q8_SCORER_ISSUE_CAPACITY_OVERFLOW");
        end
        if (dut.ap_CS_fsm_state1623 && !dut.ap_block_state1623) begin
          if (o_retires[cmd_idx]==0) o_first_retire[cmd_idx]=total_cycles;
          o_last_retire[cmd_idx]=total_cycles;
          o_retires[cmd_idx]++;
          if (o_retires[cmd_idx]>4096 || o_retires[cmd_idx]>o_issues[cmd_idx])
            $fatal(1,"Q8_SCORER_RETIRE_CAPACITY_OR_ORDER");
        end
        // The shared FP wrappers have CE=1. These scheduled operand mux
        // states are actual lane-0 launch opportunities for this legal RUN.
        if (dut.ap_CS_fsm_state319) o_fp_mul_lane0[cmd_idx]++;
        if (dut.ap_CS_fsm_state325) o_fp_add_lane0[cmd_idx]++;
        // ps_U is a representative physical PS bank, not all 32 lanes.
        if (dut.ps_U.ce0) begin
          address=dut.ps_U.address0;
          if ($isunknown(address) || address>=656)
            $fatal(1,"Q8_SCORER_PS_READ_ADDRESS");
          o_ps_reads[cmd_idx]++;
          if (o_ps_write_seen[address]) begin
            gap=total_cycles-o_ps_write_clock[address];
            o_ps_use_count[cmd_idx]++;
            if (gap<o_ps_use_min[cmd_idx]) o_ps_use_min[cmd_idx]=gap;
            if (gap>o_ps_use_max[cmd_idx]) o_ps_use_max[cmd_idx]=gap;
          end
        end
        if (dut.ps_U.ce1 && dut.ps_U.we1) begin
          address=dut.ps_U.address1;
          if ($isunknown(address) || address>=656)
            $fatal(1,"Q8_SCORER_PS_WRITE_ADDRESS");
          o_ps_writes[cmd_idx]++;
          o_ps_write_seen[address]=1;
          o_ps_write_clock[address]=total_cycles;
        end
      end
      `Q8_OBSERVE_STALL(0,descriptor)
      `Q8_OBSERVE_STALL(1,w_q0)
      `Q8_OBSERVE_STALL(2,w_q1)
      `Q8_OBSERVE_STALL(3,w_scale)
      `Q8_OBSERVE_STALL(4,aux)
      `Q8_OBSERVE_STALL(5,activation)
      `Q8_OBSERVE_STALL(6,out0)
      `Q8_OBSERVE_STALL(7,out1)
      `Q8_OBSERVE_STALL(8,observed)
      if (any_dut_stall && any_ram_stall) o_stall_intersection[cmd_idx]++;
      for (int p=0;p<O_PORTS;p++) begin
        gap=dut_aw_count[p]-dut_b_count[p];
        if (gap>o_max_aw_debt[cmd_idx][p]) o_max_aw_debt[cmd_idx][p]=gap;
        gap=dut_ar_count[p]-dut_rlast_count[p];
        if (gap>o_max_ar_debt[cmd_idx][p]) o_max_ar_debt[cmd_idx][p]=gap;
      end
    end
  end
`undef Q8_OBSERVE_STALL
`undef Q8_OBSERVE_SUB

  // Sample debt after every posedge monitor has retired that edge's R/B.
  // This is the first sampled ap_done edge, not a later CSR/check interval.
  always @(posedge clk) begin
    if (resetn && running && cmd_idx<COMMANDS && dut.ap_done &&
        !o_done_debt_checked[cmd_idx]) begin
      #1ps;
      if (!buses_drained())
        $fatal(1,"Q8_SCORER_DONE_EDGE_AXI_DEBT cmd=%0d",cmd_idx);
      o_done_debt_checked[cmd_idx]=1;
    end
  end

  task automatic observer_dump(input int ci);
    integer pre_issue, issue_span, post_issue;
    if (o_ap_accept[ci]==0 || o_ap_done[ci]==0 || !o_done_debt_checked[ci] ||
        o_ap_done[ci]<o_ap_accept[ci])
      $fatal(1,"Q8_SCORER_OBSERVER_MISSING_AP_HANDSHAKE cmd=%0d",ci);
    if (ci>0 && (o_issues[ci]!=4096 || o_retires[ci]!=4096))
      $fatal(1,"Q8_SCORER_OBSERVER_ISSUE_RETIRE_COUNT cmd=%0d issue=%0d retire=%0d",
             ci,o_issues[ci],o_retires[ci]);
    pre_issue=ci==0 ? 0 : o_first_issue[ci]-o_ap_accept[ci];
    issue_span=ci==0 ? 0 : o_last_issue[ci]-o_first_issue[ci]+1;
    post_issue=ci==0 ? 0 : o_ap_done[ci]-o_last_issue[ci]-1;
    if (ci>0 && (pre_issue<0 || issue_span<1 || post_issue<0 ||
                 pre_issue+issue_span+post_issue!=o_ap_done[ci]-o_ap_accept[ci]))
      $fatal(1,"Q8_SCORER_PHASE_PARTITION cmd=%0d",ci);
    $display("Q8_SCORER_OBSERVER_TIME cmd=%0d lite_aw=%0d lite_w=%0d ap_accept=%0d ap_done=%0d ap_cycles=%0d pre_issue_unknown=%0d issue_span=%0d post_issue_unknown=%0d",
             ci,o_lite_aw[ci],o_lite_w[ci],o_ap_accept[ci],o_ap_done[ci],
             o_ap_done[ci]-o_ap_accept[ci],pre_issue,issue_span,post_issue);
    $display("Q8_SCORER_OBSERVER_ISSUE cmd=%0d count=%0d retired=%0d first=%0d last=%0d first_retire=%0d last_retire=%0d max_gap=%0d hist=%0d,%0d,%0d,%0d,%0d",
             ci,o_issues[ci],o_retires[ci],o_first_issue[ci],o_last_issue[ci],
             o_first_retire[ci],o_last_retire[ci],o_max_issue_gap[ci],
             o_issue_hist[ci][0],o_issue_hist[ci][1],o_issue_hist[ci][2],
             o_issue_hist[ci][3],o_issue_hist[ci][4]);
    $display("Q8_SCORER_OBSERVER_PS_FP cmd=%0d ps_reads=%0d ps_writes=%0d dependent_uses=%0d min_gap=%0d max_gap=%0d lane0_fmul_launch=%0d lane0_fadd_launch=%0d",
             ci,o_ps_reads[ci],o_ps_writes[ci],o_ps_use_count[ci],
             o_ps_use_count[ci] ? o_ps_use_min[ci] : 0,o_ps_use_max[ci],
             o_fp_mul_lane0[ci],o_fp_add_lane0[ci]);
    for (int s=0;s<5;s++)
      $display("Q8_SCORER_OBSERVER_SUBCALL cmd=%0d sub=%0d starts=%0d dones=%0d first_start=%0d last_done=%0d",
               ci,s,o_sub_starts[ci][s],o_sub_dones[ci][s],
               o_sub_first_start[ci][s],o_sub_last_done[ci][s]);
    for (int ph=0;ph<7;ph++)
      $display("Q8_SCORER_OBSERVER_STATE cmd=%0d phase=%0d count=%0d first=%0d last=%0d",
               ci,ph,o_state_count[ci][ph],o_state_first[ci][ph],
               o_state_last[ci][ph]);
    for (int s=0;s<8;s++)
      if (s<o_issues[ci])
        $display("Q8_SCORER_OBSERVER_ISSUE_SAMPLE cmd=%0d slot=%0d first_g=%0d first_t=%0d first_clk=%0d last_g=%0d last_t=%0d last_clk=%0d",
                 ci,s,o_issue_first_g[ci][s],o_issue_first_t[ci][s],
                 o_issue_first_clk[ci][s],o_issue_last_g[ci][s],
                 o_issue_last_t[ci][s],o_issue_last_clk[ci][s]);
    for (int p=0;p<O_PORTS;p++)
      $display("Q8_SCORER_OBSERVER_AXI cmd=%0d port=%0d dut_stall=%0d,%0d,%0d,%0d,%0d ram_stall=%0d,%0d,%0d,%0d,%0d max_aw_debt=%0d max_ar_debt=%0d",
               ci,p,o_dut_stall[ci][p][0],o_dut_stall[ci][p][1],
               o_dut_stall[ci][p][2],o_dut_stall[ci][p][3],o_dut_stall[ci][p][4],
               o_ram_stall[ci][p][0],o_ram_stall[ci][p][1],
               o_ram_stall[ci][p][2],o_ram_stall[ci][p][3],o_ram_stall[ci][p][4],
               o_max_aw_debt[ci][p],o_max_ar_debt[ci][p]);
    $display("Q8_SCORER_OBSERVER_STALL_INTERSECTION cmd=%0d cycles=%0d",
             ci,o_stall_intersection[ci]);
  endtask
