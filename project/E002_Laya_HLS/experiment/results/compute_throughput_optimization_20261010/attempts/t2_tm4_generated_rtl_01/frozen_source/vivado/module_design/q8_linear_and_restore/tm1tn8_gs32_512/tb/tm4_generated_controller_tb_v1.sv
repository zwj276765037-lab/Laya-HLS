`timescale 1ns/1ps
module tm4_generated_controller_tb_v1;
  logic ap_clk=0,ap_rst=1,ap_ce=1,ap_start=0;
  always #3.333 ap_clk=~ap_clk;
  wire ap_done,ap_idle,ap_ready;
  wire [6:0] input_r_address0,input_r_address1;
  wire [5:0] output_r_address0,output_r_address1;
  wire input_r_ce0,input_r_ce1,output_r_ce0,output_r_ce1,output_r_we0,output_r_we1;
  logic [63:0] input_r_q0=0,input_r_q1=0;
  wire [63:0] output_r_d0,output_r_d1;
  logic [63:0] inputs[0:13327],gold[0:6782],mem[0:111],out[0:56];
  logic [31:0] prior_actual[0:31];
  integer writes[0:56];
  integer cycle=0,leaf_issues=0,leaf_returns=0,row_issues=0,row_commits=0;
  integer previous_issue=-1,issue_min=1000000,issue_max=0,first_issue=-1,last_return=-1;
  integer wi_begin,wi_end,down_end;
  string fixture;
  laya_tm4_blackbox_smoke dut(.*);
  wire [56:0] leaf_vlds={dut.grp_laya_tm4_group_service_fu_2013.echo0_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo1_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo2_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo3_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo4_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo5_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo6_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo7_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo8_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo9_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo10_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo11_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo12_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo13_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo14_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.echo15_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next0_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next1_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next2_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next3_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next4_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next5_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next6_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next7_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next8_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next9_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next10_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next11_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next12_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next13_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next14_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next15_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next16_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next17_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next18_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next19_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next20_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next21_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next22_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next23_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next24_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next25_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next26_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next27_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next28_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next29_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next30_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.next31_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.bad0_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.bad1_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.bad2_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.bad3_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.phases0_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.phases1_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.phases2_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.phases3_ap_vld, dut.grp_laya_tm4_group_service_fu_2013.status_ap_vld};
  always @(posedge ap_clk)begin
    cycle<=cycle+1;
    if(input_r_ce0)input_r_q0<=mem[input_r_address0];
    if(input_r_ce1)input_r_q1<=mem[input_r_address1];
    if(!ap_rst && output_r_ce0 && output_r_we0)begin
      if(!ap_ce || output_r_address0>=57)$fatal(1,"illegal output0 write");
      out[output_r_address0]<=output_r_d0;writes[output_r_address0]<=writes[output_r_address0]+1;
    end
    if(!ap_rst && output_r_ce1 && output_r_we1)begin
      if(!ap_ce || output_r_address1>=57)$fatal(1,"illegal output1 write");
      if(output_r_we0 && output_r_ce0 && output_r_address0==output_r_address1)$fatal(1,"duplicate output write address");
      out[output_r_address1]<=output_r_d1;writes[output_r_address1]<=writes[output_r_address1]+1;
    end
    if(!ap_rst && dut.grp_laya_tm4_group_service_fu_2013_ap_start &&
       dut.grp_laya_tm4_group_service_fu_2013_ap_idle && dut.grp_laya_tm4_group_service_fu_2013_ap_ce)begin
      leaf_issues<=leaf_issues+1;
      if(first_issue<0)first_issue<=cycle;
      if(previous_issue>=0)begin
        if(cycle-previous_issue<issue_min)issue_min<=cycle-previous_issue;
        if(cycle-previous_issue>issue_max)issue_max<=cycle-previous_issue;
      end
      previous_issue<=cycle;
      $display("TM4_GENERATED_ISSUE ordinal=%0d cycle=%0d",leaf_issues,cycle);
    end
    if(!ap_rst && dut.grp_laya_tm4_group_service_fu_2013_ap_done &&
       dut.grp_laya_tm4_group_service_fu_2013_ap_ce)begin
      if(leaf_vlds!=={57{1'b1}})$fatal(1,"all 57 leaf output valid coverage");
      leaf_returns<=leaf_returns+1;last_return<=cycle;
      $display("TM4_GENERATED_RETURN ordinal=%0d cycle=%0d",leaf_returns,cycle);
    end
    if(!ap_rst && dut.grp_laya_tm4_group_service_fu_2013.issue_fire)
      row_issues<=row_issues+$countones(dut.grp_laya_tm4_group_service_fu_2013.active_rows);
    if(!ap_rst && dut.grp_laya_tm4_group_service_fu_2013.phase==2 &&
       dut.grp_laya_tm4_group_service_fu_2013.ap_ce)
      row_commits<=row_commits+$countones(dut.grp_laya_tm4_group_service_fu_2013.commit_valid);
    if(cycle>80000)$fatal(1,"controller cycle cap");
  end
  task automatic run_group(input integer ordinal,input integer pause_mode);
    integer started;
    logic [63:0] held_owner;
    logic [31:0] held_next;
    begin
      @(negedge ap_clk);
      for(int i=0;i<112;i++)mem[i]=inputs[ordinal*112+i];
      if(ordinal<114)begin
        if(mem[109]==0)for(int i=0;i<32;i++)prior_actual[i]=0;
        for(int i=0;i<32;i++)begin
          if(mem[76+i]!=={32'd0,prior_actual[i]})$fatal(1,"independent old-PS feedback ordinal=%0d lane=%0d",ordinal,i);
          mem[76+i]={32'd0,prior_actual[i]};
        end
      end
      for(int i=0;i<57;i++)begin out[i]='x;writes[i]=0;end
      started=cycle;ap_start=1;@(negedge ap_clk);ap_start=0;
      if(pause_mode==1)begin
        repeat(60)@(negedge ap_clk);ap_ce=0;
        repeat(13)@(negedge ap_clk);ap_ce=1;
      end
      if(pause_mode==2)begin
        while(!dut.grp_laya_tm4_group_service_fu_2013_ap_done)@(negedge ap_clk);
        ap_ce=0;
        held_owner=dut.grp_laya_tm4_group_service_fu_2013.echo15;
        held_next=dut.grp_laya_tm4_group_service_fu_2013.next31;
        repeat(8)begin
          @(negedge ap_clk);
          if(!dut.grp_laya_tm4_group_service_fu_2013_ap_done ||
             dut.grp_laya_tm4_group_service_fu_2013_ap_ready ||
             dut.grp_laya_tm4_group_service_fu_2013.echo15!==held_owner ||
             dut.grp_laya_tm4_group_service_fu_2013.next31!==held_next)
            $fatal(1,"caller held child return changed");
        end
        ap_ce=1;
      end
      while(!ap_done)begin
        @(negedge ap_clk);
        if(cycle-started>1024)$fatal(1,"generated TM4 top timeout ordinal=%0d leaf_issues=%0d returns=%0d state=%h leafphase=%0d",ordinal,leaf_issues,leaf_returns,dut.ap_CS_fsm,dut.grp_laya_tm4_group_service_fu_2013.phase);
      end
      @(posedge ap_clk);if(!ap_done || !ap_ce)$fatal(1,"actual top completion edge");#1;
      for(int i=0;i<57;i++)begin
        if(writes[i]!=1)$fatal(1,"output coverage ordinal=%0d word=%0d writes=%0d",ordinal,i,writes[i]);
        if(out[i]!==gold[ordinal*57+i])$fatal(1,"independent gold ordinal=%0d word=%0d got=%h gold=%h",ordinal,i,out[i],gold[ordinal*57+i]);
      end
      if(ordinal<114)for(int i=0;i<32;i++)prior_actual[i]=out[16+i][31:0];
      $display("TM4_GENERATED_GROUP_PASS ordinal=%0d cycles=%0d caller_pause=%0d",ordinal,cycle-started,pause_mode);
      @(negedge ap_clk);
    end
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture required");
    $readmemh({fixture,"/input.hex"},inputs);$readmemh({fixture,"/gold.hex"},gold);
    repeat(5)@(negedge ap_clk);ap_rst=0;repeat(20)@(negedge ap_clk);wi_begin=cycle;
    for(int g=0;g<32;g++)run_group(g,0);
    wi_end=cycle;
    for(int g=32;g<114;g++)run_group(g,g==70 ? 1 : 0);
    down_end=cycle;
    run_group(114,0);run_group(115,0);run_group(116,0);run_group(117,0);run_group(118,2);
    if(leaf_issues!=119 || leaf_returns!=119 || row_issues!=472 || row_commits!=472)
      $fatal(1,"actual service coverage issues=%0d returns=%0d rows=%0d commits=%0d",leaf_issues,leaf_returns,row_issues,row_commits);
    $display("TM4_GENERATED_CONTROLLER_PASS real_groups=114 calls=119 rows=4 full_owner_bits=1024 output_words_per_call=57 actual_PS_feedback=1 max_group=127 max_tile=655 late_row_scale_error=1 group_reject=1 recovery=1 caller_pause=13 caller_return_hold=8 full_domain_ce=NOT_PROVEN wi_cycles=%0d down_cycles=%0d issue_interval_min=%0d issue_interval_max=%0d first_issue=%0d last_return=%0d cycles=%0d",wi_end-wi_begin,down_end-wi_end,issue_min,issue_max,first_issue,last_return,cycle);
    $finish;
  end
endmodule

