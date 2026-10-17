`timescale 1ns/1ps
module quant_generated_controller_tb;
  logic ap_clk=0, ap_rst=1, ap_ce=1, ap_start=0;
  always #5 ap_clk=~ap_clk;
  wire ap_done,ap_idle,ap_ready;
  wire [4:0] input_r_address0,input_r_address1,output_r_address0,output_r_address1;
  wire input_r_ce0,input_r_ce1,output_r_ce0,output_r_ce1,output_r_we0,output_r_we1;
  logic [63:0] input_r_q0=0,input_r_q1=0;
  wire [63:0] output_r_d0,output_r_d1;
  logic [63:0] inputs[0:3595],gold[0:2667],mem[0:30],out[0:22];
  integer writes[0:22];
  integer cycle=0,leaf_issues=0,leaf_returns=0,feed_beats=0,output_writes=0;
  integer previous_issue=-1,issue_min=1000000,issue_max=0,first_issue=-1,last_return=-1;
  integer first_call_cycle,wi_end,down_begin,down_end;
  string fixture;
  laya_quant_blackbox_smoke dut(.*);
  always @(posedge ap_clk) begin
    cycle<=cycle+1;
    if(input_r_ce0) input_r_q0<=mem[input_r_address0];
    if(input_r_ce1) input_r_q1<=mem[input_r_address1];
    if(!ap_rst && output_r_ce0 && output_r_we0) begin
      if(!ap_ce || output_r_address0>=23) $fatal(1,"illegal output0 write");
      out[output_r_address0]<=output_r_d0;writes[output_r_address0]<=writes[output_r_address0]+1;
      output_writes<=output_writes+1;
    end
    if(!ap_rst && output_r_ce1 && output_r_we1) begin
      if(!ap_ce || output_r_address1>=23) $fatal(1,"illegal output1 write");
      out[output_r_address1]<=output_r_d1;writes[output_r_address1]<=writes[output_r_address1]+1;
    end
    if(!ap_rst && dut.grp_laya_quant_group_service_fu_680_ap_start &&
       dut.grp_laya_quant_group_service_fu_680_ap_idle && dut.grp_laya_quant_group_service_fu_680_ap_ce) begin
      leaf_issues<=leaf_issues+1;
      if(first_issue<0) first_issue<=cycle;
      if(previous_issue>=0) begin
        if(cycle-previous_issue<issue_min) issue_min<=cycle-previous_issue;
        if(cycle-previous_issue>issue_max) issue_max<=cycle-previous_issue;
      end
      previous_issue<=cycle;
      $display("QUANT_GENERATED_ISSUE ordinal=%0d cycle=%0d",leaf_issues,cycle);
    end
    if(!ap_rst && dut.grp_laya_quant_group_service_fu_680_ap_done &&
       dut.grp_laya_quant_group_service_fu_680_ap_ce) begin
      leaf_returns<=leaf_returns+1;last_return<=cycle;
      $display("QUANT_GENERATED_RETURN ordinal=%0d cycle=%0d",leaf_returns,cycle);
    end
    if(!ap_rst && dut.grp_laya_quant_group_service_fu_680.quant.in_valid &&
       dut.grp_laya_quant_group_service_fu_680.quant.in_ready) feed_beats<=feed_beats+1;
    if(cycle>40000) $fatal(1,"controller cycle cap");
  end
  task automatic run_group(input integer g,input bit pause_ce);
    integer started;
    begin
      @(negedge ap_clk);
      for(integer i=0;i<31;i++) mem[i]=inputs[g*31+i];
      for(integer i=0;i<23;i++) begin out[i]='x;writes[i]=0;end
      started=cycle;ap_start=1;
      @(negedge ap_clk);ap_start=0;
      if(pause_ce) begin
        repeat(40) @(negedge ap_clk);ap_ce=0;
        repeat(13) @(negedge ap_clk);ap_ce=1;
      end
      while(!ap_done) begin
        @(negedge ap_clk);
        if(cycle-started>512) $fatal(1,"generated top timeout group=%0d leaf_issues=%0d returns=%0d state=%h",g,leaf_issues,leaf_returns,dut.ap_CS_fsm);
      end
      for(integer i=0;i<23;i++) begin
        if(writes[i]!=1) $fatal(1,"output coverage group=%0d word=%0d writes=%0d",g,i,writes[i]);
        if(out[i]!==gold[g*23+i]) $fatal(1,"gold group=%0d word=%0d got=%h gold=%h",g,i,out[i],gold[g*23+i]);
      end
      $display("QUANT_GENERATED_GROUP_PASS group=%0d cycles=%0d ce_pause=%0d",g,cycle-started,pause_ce);
      @(negedge ap_clk);
    end
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture)) $fatal(1,"fixture required");
    $readmemh({fixture,"/input.hex"},inputs);$readmemh({fixture,"/gold.hex"},gold);
    repeat(5) @(negedge ap_clk);ap_rst=0;
    repeat(20) @(negedge ap_clk);first_call_cycle=cycle;
    for(integer g=0;g<32;g++) run_group(g,0);
    wi_end=cycle;down_begin=cycle;
    for(integer g=32;g<114;g++) run_group(g,0);
    down_end=cycle;
    run_group(114,0);run_group(115,1);
    if(leaf_issues!=116 || leaf_returns!=116 || feed_beats!=232) $fatal(1,"service counts %0d %0d %0d",leaf_issues,leaf_returns,feed_beats);
    $display("QUANT_GENERATED_CONTROLLER_PASS real_groups=114 calls=116 full_owner_bits=896 late_error=31 recovery=1 ce_pause=13 wi_cycles=%0d down_cycles=%0d issue_interval_min=%0d issue_interval_max=%0d first_issue=%0d last_return=%0d cycles=%0d",wi_end-first_call_cycle,down_end-down_begin,issue_min,issue_max,first_issue,last_return,cycle);
    $finish;
  end
endmodule
