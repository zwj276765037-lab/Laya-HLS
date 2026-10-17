`timescale 1ns/1ps
// The runner derives these names only after a strict 24-signal port audit.
`include "owned_program_ports.vh"
module laya_graph_program_owned_tb_v1;
  localparam int OWNER=0, OWNER_ECHO=1, PENDING=2, COMMAND=3;
  localparam int RESULT=4, ACTION=5, COMPLETION=6, COMPLETION_ECHO=7;
  logic clk=0, rst_n=0, cancel=0, result_consumed=0;
  wire isolated;
  always #5 clk=~clk;
  logic [8191:0] in_data[0:7];
  wire [8191:0] out_data[0:7];
  logic [7:0] peer_valid=0, peer_ready=0;
  wire [7:0] in_valid, in_ready, out_valid, out_ready;
  wire [1:0] occupancy[0:7];
  integer writes[0:7], reads[0:7];
  integer cycles=0, max_cycles=1000000, phase=0;
  string fixture_path, case_name;
  bit allocated, canceled, stale;
  logic [8191:0] owner_gold[0:0], next_owner_gold[0:0], pending_gold[0:0];
  logic [511:0] command_gold[0:3], action_gold[0:7];
  logic [511:0] success_completion[0:3], cancel_completion[0:3];
  logic [511:0] stale_completion[0:3];
  logic [511:0] success_result[0:3], cancel_result[0:3], local_result[0:3];
  logic [511:0] expected_completion[0:3], expected_result[0:3];

  for(genvar i=0;i<8;i++)begin: fifos
    localparam int W=(i<3)?8192:512;
    laya_private_fifo2_v1 #(.WIDTH(W)) queue(
      .clk, .rst_n, .in_valid(in_valid[i]), .in_ready(in_ready[i]),
      .in_data(in_data[i][W-1:0]), .out_valid(out_valid[i]),
      .out_ready(out_ready[i]), .out_data(out_data[i][W-1:0]),
      .occupancy(occupancy[i]));
    if(i>=3) assign out_data[i][8191:512]='0;
  end
  assign in_valid[OWNER]=peer_valid[OWNER];
  assign in_valid[COMMAND]=peer_valid[COMMAND];
  assign in_valid[COMPLETION]=peer_valid[COMPLETION];
  assign out_ready[OWNER_ECHO]=peer_ready[OWNER_ECHO];
  assign out_ready[PENDING]=peer_ready[PENDING];
  assign out_ready[RESULT]=peer_ready[RESULT];
  assign out_ready[ACTION]=peer_ready[ACTION];
  assign out_ready[COMPLETION_ECHO]=peer_ready[COMPLETION_ECHO];

  laya_graph_program_owned_sequencer dut(
    .`OWN_AP_CLK(clk), .`OWN_RESET(`OWN_RESET_VALUE),
    .`OWN_CANCEL(cancel), .`OWN_RESULT_CONSUMED(result_consumed),
    .`OWN_ISOLATED(isolated),
    .`OWN_PROGRAM_OWNER_DOUT(out_data[OWNER]),
    .`OWN_PROGRAM_OWNER_EMPTY_N(out_valid[OWNER]),
    .`OWN_PROGRAM_OWNER_READ(out_ready[OWNER]),
    .`OWN_PROGRAM_OWNER_RECEIPT_DIN(in_data[OWNER_ECHO]),
    .`OWN_PROGRAM_OWNER_RECEIPT_FULL_N(in_ready[OWNER_ECHO]),
    .`OWN_PROGRAM_OWNER_RECEIPT_WRITE(in_valid[OWNER_ECHO]),
    .`OWN_PROGRAM_PENDING_DIN(in_data[PENDING]),
    .`OWN_PROGRAM_PENDING_FULL_N(in_ready[PENDING]),
    .`OWN_PROGRAM_PENDING_WRITE(in_valid[PENDING]),
    .`OWN_ACCEPTED_COMMAND_DOUT(out_data[COMMAND][511:0]),
    .`OWN_ACCEPTED_COMMAND_EMPTY_N(out_valid[COMMAND]),
    .`OWN_ACCEPTED_COMMAND_READ(out_ready[COMMAND]),
    .`OWN_REQUEST_RESULT_DIN(in_data[RESULT][511:0]),
    .`OWN_REQUEST_RESULT_FULL_N(in_ready[RESULT]),
    .`OWN_REQUEST_RESULT_WRITE(in_valid[RESULT]),
    .`OWN_ACTION_REQUEST_DIN(in_data[ACTION][511:0]),
    .`OWN_ACTION_REQUEST_FULL_N(in_ready[ACTION]),
    .`OWN_ACTION_REQUEST_WRITE(in_valid[ACTION]),
    .`OWN_ACTION_COMPLETION_DOUT(out_data[COMPLETION][511:0]),
    .`OWN_ACTION_COMPLETION_EMPTY_N(out_valid[COMPLETION]),
    .`OWN_ACTION_COMPLETION_READ(out_ready[COMPLETION]),
    .`OWN_ACTION_COMPLETION_RECEIPT_DIN(in_data[COMPLETION_ECHO][511:0]),
    .`OWN_ACTION_COMPLETION_RECEIPT_FULL_N(in_ready[COMPLETION_ECHO]),
    .`OWN_ACTION_COMPLETION_RECEIPT_WRITE(in_valid[COMPLETION_ECHO]));

  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>=max_cycles)$fatal(1,"owned program cycle cap case=%s phase=%0d",case_name,phase);
    for(int i=0;i<8;i++)begin
      if(!rst_n)begin writes[i]<=0;reads[i]<=0;end
      else begin
        if(in_valid[i] && in_ready[i])writes[i]<=writes[i]+1;
        if(out_valid[i] && out_ready[i])reads[i]<=reads[i]+1;
        if(occupancy[i]>2)$fatal(1,"depth2 overflow channel=%0d",i);
        if((i==OWNER_ECHO || i==PENDING || i==RESULT || i==ACTION || i==COMPLETION_ECHO)
            && in_valid[i] && !in_ready[i])
          $fatal(1,"DUT write while full channel=%0d case=%s",i,case_name);
      end
    end
    if(rst_n && isolated)$fatal(1,"unexpected isolation case=%s phase=%0d",case_name,phase);
  end

  task automatic tick; @(posedge clk);#1;endtask
  task automatic push(input integer channel,input logic [8191:0] data);
    bit fire;
    @(negedge clk);in_data[channel]=data;peer_valid[channel]=1;
    do begin @(posedge clk);fire=in_ready[channel];#1;end while(!fire);
    @(negedge clk);peer_valid[channel]=0;
  endtask
  task automatic check_head(input integer channel,input logic [8191:0] expected);
    if(!out_valid[channel] || (channel<3 && out_data[channel]!==expected) ||
        (channel>=3 && out_data[channel][511:0]!==expected[511:0]))
      $fatal(1,"complete gold/head mismatch channel=%0d case=%s phase=%0d",channel,case_name,phase);
  endtask
  task automatic pop_check(input integer channel,input logic [8191:0] expected);
    while(!out_valid[channel])tick();
    check_head(channel,expected);
    @(negedge clk);peer_ready[channel]=1;
    @(posedge clk);
    if(!out_valid[channel])$fatal(1,"consumer read did not fire channel=%0d",channel);
    check_head(channel,expected);#1;
    @(negedge clk);peer_ready[channel]=0;
  endtask
  task automatic no_terminal;
    if(writes[RESULT]!=0 || writes[COMPLETION_ECHO]!=0)
      $fatal(1,"terminal before full bound completion case=%s phase=%0d",case_name,phase);
  endtask
  task automatic no_allocation;
    if(writes[PENDING]!=0 || writes[ACTION]!=0 || writes[COMPLETION_ECHO]!=0)
      $fatal(1,"action allocated during incomplete/local command case=%s",case_name);
  endtask
  task automatic wait_command_reads(input integer count);
    while(reads[COMMAND]!=count)tick();
  endtask
  task automatic wait_completion_reads(input integer count);
    while(reads[COMPLETION]!=count)tick();
  endtask
  task automatic command_frame;
    phase=2;
    push(COMMAND,command_gold[0]);push(COMMAND,command_gold[1]);
    wait_command_reads(2);
    if(!allocated)begin @(negedge clk);cancel=1;end
    repeat(12)begin tick();no_allocation();no_terminal();
      if(reads[COMMAND]!=2)$fatal(1,"command prefix accounting");end
    push(COMMAND,command_gold[2]);wait_command_reads(3);
    repeat(12)begin tick();no_allocation();no_terminal();end
    push(COMMAND,command_gold[3]);wait_command_reads(4);
  endtask
  task automatic consume_action;
    phase=3;
    while(!out_valid[PENDING])tick();
    check_head(PENDING,pending_gold[0]);
    if(canceled)begin @(negedge clk);cancel=1;end
    repeat(12)begin tick();check_head(PENDING,pending_gold[0]);no_terminal();
      if(writes[PENDING]!=1 || reads[COMMAND]!=4)$fatal(1,"LAP accounting");end
    pop_check(PENDING,pending_gold[0]);
    for(int i=0;i<6;i++)pop_check(ACTION,action_gold[i]);
    while(occupancy[ACTION]!=2)tick();
    repeat(12)begin tick();check_head(ACTION,action_gold[6]);no_terminal();
      if(writes[ACTION]!=8 || reads[ACTION]!=6)$fatal(1,"action tail2 accounting");end
    pop_check(ACTION,action_gold[6]);
    repeat(12)begin tick();check_head(ACTION,action_gold[7]);no_terminal();
      if(occupancy[ACTION]!=1 || writes[ACTION]!=8 || reads[ACTION]!=7)
        $fatal(1,"action tail1 accounting");end
    pop_check(ACTION,action_gold[7]);
  endtask
  task automatic completion_frame(input integer prior);
    phase=4;
    push(COMPLETION,expected_completion[0]);push(COMPLETION,expected_completion[1]);
    wait_completion_reads(prior+2);
    repeat(12)begin tick();no_terminal();end
    push(COMPLETION,expected_completion[2]);wait_completion_reads(prior+3);
    repeat(12)begin tick();no_terminal();end
    push(COMPLETION,expected_completion[3]);wait_completion_reads(prior+4);
  endtask
  task automatic consume_completion_echo;
    phase=5;
    while(occupancy[COMPLETION_ECHO]!=2)tick();
    repeat(12)begin tick();check_head(COMPLETION_ECHO,expected_completion[0]);
      if(writes[COMPLETION_ECHO]!=2 || writes[RESULT]!=0)
        $fatal(1,"receipt full must retain unwritten receipt tail");end
    pop_check(COMPLETION_ECHO,expected_completion[0]);
    pop_check(COMPLETION_ECHO,expected_completion[1]);
    while(occupancy[COMPLETION_ECHO]!=2)tick();
    // Once all receipt beats are WRITTEN the core may produce LGR. Receipt
    // consumer reads are checked, but are not invented as a core release gate.
    repeat(12)begin tick();check_head(COMPLETION_ECHO,expected_completion[2]);
      if(writes[COMPLETION_ECHO]!=4 || reads[COMPLETION_ECHO]!=2)
        $fatal(1,"receipt tail2 accounting");end
    pop_check(COMPLETION_ECHO,expected_completion[2]);
    repeat(12)begin tick();check_head(COMPLETION_ECHO,expected_completion[3]);
      if(occupancy[COMPLETION_ECHO]!=1 || reads[COMPLETION_ECHO]!=3)
        $fatal(1,"receipt tail1 accounting");end
    pop_check(COMPLETION_ECHO,expected_completion[3]);
  endtask
  task automatic replay_held;
    if(reads[OWNER]!=1 || writes[OWNER_ECHO]!=1 || reads[OWNER_ECHO]!=1 ||
        reads[COMMAND]!=4 || occupancy[OWNER]!=2 || occupancy[COMMAND]!=2 ||
        writes[PENDING]!=(allocated?1:0) || writes[ACTION]!=(allocated?8:0) ||
        writes[COMPLETION_ECHO]!=(allocated?4:0))
      $fatal(1,"FIRST replay/second command was consumed case=%s phase=%0d",case_name,phase);
  endtask
  task automatic consume_result;
    phase=6;
    while(occupancy[RESULT]!=2)tick();
    repeat(12)begin tick();check_head(RESULT,expected_result[0]);
      if(writes[RESULT]!=2 || result_consumed)$fatal(1,"result full prefix accounting");end
    pop_check(RESULT,expected_result[0]);pop_check(RESULT,expected_result[1]);
    while(occupancy[RESULT]!=2)tick();
    push(OWNER,owner_gold[0]);push(OWNER,next_owner_gold[0]);
    push(COMMAND,command_gold[0]);push(COMMAND,command_gold[1]);
    repeat(12)begin tick();check_head(RESULT,expected_result[2]);replay_held();
      if(writes[RESULT]!=4 || reads[RESULT]!=2 || result_consumed)
        $fatal(1,"result tail2 accounting");end
    pop_check(RESULT,expected_result[2]);
    repeat(12)begin tick();check_head(RESULT,expected_result[3]);replay_held();
      if(occupancy[RESULT]!=1 || reads[RESULT]!=3 || result_consumed)
        $fatal(1,"result tail1 accounting");end
    pop_check(RESULT,expected_result[3]);
    // Controlled abstract notification, supplied only after the fourth actual
    // result FIFO consumer handshake. It proves no executor/software retirement.
    @(negedge clk);result_consumed=1;phase=7;
    repeat(20000)begin tick();replay_held();
      if(writes[RESULT]!=4 || out_valid[RESULT] || reads[RESULT]!=4)
        $fatal(1,"terminal output repeated or result notification lost");end
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture_path))$fatal(1,"FIXTURE required");
    if(!$value$plusargs("CASE=%s",case_name))$fatal(1,"CASE required");
    if($value$plusargs("MAX_CYCLES=%d",max_cycles))begin
      if(max_cycles<20000 || max_cycles>1000000)$fatal(1,"invalid finite cycle cap");
    end
    allocated=(case_name!="cancel-command-prefix");
    canceled=(case_name=="cancel-allocated" || case_name=="stale-completion");
    stale=(case_name=="stale-completion");
    if(case_name!="success" && case_name!="cancel-command-prefix" &&
        case_name!="cancel-allocated" && case_name!="stale-completion")$fatal(1,"unknown case");
    $readmemh({fixture_path,"/owner.hex"},owner_gold);
    $readmemh({fixture_path,"/next_owner.hex"},next_owner_gold);
    $readmemh({fixture_path,"/pending.hex"},pending_gold);
    $readmemh({fixture_path,"/command.hex"},command_gold);
    $readmemh({fixture_path,"/action.hex"},action_gold);
    $readmemh({fixture_path,"/success_completion.hex"},success_completion);
    $readmemh({fixture_path,"/cancel_completion.hex"},cancel_completion);
    $readmemh({fixture_path,"/stale_completion.hex"},stale_completion);
    $readmemh({fixture_path,"/success_result.hex"},success_result);
    $readmemh({fixture_path,"/cancel_result.hex"},cancel_result);
    $readmemh({fixture_path,"/local_result.hex"},local_result);
    for(int i=0;i<4;i++)begin
      expected_completion[i]=canceled?cancel_completion[i]:success_completion[i];
      expected_result[i]=allocated?(canceled?cancel_result[i]:success_result[i]):local_result[i];
    end
    in_data[OWNER]='0;in_data[COMMAND]='0;in_data[COMPLETION]='0;
    repeat(8)tick();@(negedge clk);rst_n=1;phase=1;
    push(OWNER,owner_gold[0]);
    while(!out_valid[OWNER_ECHO])tick();
    repeat(12)begin tick();check_head(OWNER_ECHO,owner_gold[0]);no_allocation();no_terminal();
      if(reads[OWNER]!=1 || writes[OWNER_ECHO]!=1 || reads[COMMAND]!=0)
        $fatal(1,"owner installation/echo accounting");end
    pop_check(OWNER_ECHO,owner_gold[0]);
    command_frame();
    if(allocated)begin
      consume_action();
      if(stale)begin
        phase=8;
        for(int i=0;i<4;i++)push(COMPLETION,stale_completion[i]);
        wait_completion_reads(4);
        repeat(12)begin tick();no_terminal();
          if(reads[COMPLETION]!=4 || writes[PENDING]!=1 || writes[ACTION]!=8)
            $fatal(1,"stale completion altered allocated work");end
      end
      completion_frame(stale?4:0);consume_completion_echo();
    end else no_allocation();
    consume_result();
    for(int i=1;i<8;i++)if(i!=COMMAND && occupancy[i]!=0)
      $fatal(1,"terminal output/input queue not drained channel=%0d",i);
    if(reads[COMPLETION]!=(allocated?(stale?8:4):0) || reads[ACTION]!=(allocated?8:0) ||
        reads[PENDING]!=(allocated?1:0) || reads[COMPLETION_ECHO]!=(allocated?4:0))
      $fatal(1,"final consumer accounting");
    $display("FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_PASS case=%s cycles=%0d owner=1 echo=1 command=4 LAP=%0d action=%0d completion=%0d receipt=%0d result=4 tail2=1 tail1=1 waits12=1 depth2=8 FIRST_only=1 replay_owner_words_held=2 replay_command_beats_held=2 result_notification=CONTROLLED_ABSTRACT",case_name,cycles,allocated?1:0,allocated?8:0,allocated?(stale?8:4):0,allocated?4:0);
    $finish;
  end
endmodule
