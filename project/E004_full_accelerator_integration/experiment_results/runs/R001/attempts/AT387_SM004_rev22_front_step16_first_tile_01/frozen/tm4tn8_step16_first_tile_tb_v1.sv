`timescale 1ns/1ps

// Full 16-row descriptor, stopped after the first tile's four real steps.
// This focused control test does not replace the production A/W/PS chain.
module tm4tn8_step16_first_tile_tb_v1;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0;
  logic config_valid=0, config_ready;
  logic issue_valid=0, issue_ready;
  logic abort_valid=0, abort_ready;
  logic [3:0] commit_valid, final_skip_valid;
  logic [767:0] commit_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_lane_mask,commit_bad_mask;
  logic [95:0] commit_phase;
  logic [1023:0] commit_next_ps;
  logic [9:0] final_skip_tile;
  logic [7:0] final_skip_mask;
  logic [23:0] result_free,result_reserved,result_returned;
  logic [11:0] trace_free;
  logic done_valid,done_error,protocol_failure;
  logic [63:0] first_error_rank;
  logic [31:0] first_bad_element;
  logic [26:0] accepted_stripes;
  logic step_valid=0,step_ready,step_done_valid,step_done_ready=0;
  logic [9:0] step_tile,step_done_tile;
  logic [1:0] step_block,step_done_block;
  logic [5:0] step_done_accepted;
  logic [7:0] step_done_row_retired;
  logic [2:0] step_done_terminal;
  logic step_done_error,step_done_protocol;
  logic [63:0] step_done_first_rank;
  logic [31:0] step_done_bad;
  logic [26:0] issue_sequence;
  logic [6:0] issue_group;
  logic [1:0] issue_block;
  logic [9:0] issue_tile;
  localparam logic [159:0] IDENTITY={32'h11,32'h22,32'h33,32'h44,32'h55};
  int cycles=0, committed=0, terminal=0;

  tm4tn8_sync_ps_front_v2 dut (
    .clk,.rst_n,.config_valid,.config_ready,.config_k(16'd1024),
    .config_n(16'd3072),.config_rows(5'd16),.config_step16(1'b1),
    .config_row0(16'd0),.config_identity(IDENTITY),
    .issue_valid,.issue_ready,.issue_identity(IDENTITY[159:64]),
    .issue_version(4'd1),.issue_sequence,.issue_group,.issue_tile,
    .issue_block,.issue_lane_mask(8'hff),.issue_trace_mask(4'd0),
    .issue_trace_lane(12'd0),.issue_a8(1024'd0),
    .issue_sa({4{32'h3f800000}}),.issue_w8(2048'd0),
    .issue_sw({8{32'h3f800000}}),.abort_valid,.abort_ready,
    .commit_valid,.commit_ready(4'hf),.commit_tag,.commit_tile,
    .commit_lane_mask,.commit_bad_mask,.commit_phase,.commit_next_ps,
    .final_skip_valid,.final_skip_ready(4'hf),.final_skip_tile,
    .final_skip_mask,.trace_valid(),.trace_ready(4'd0),.trace_slot(),
    .trace_tag(),.trace_payload(),.trace_ack_valid(4'd0),
    .trace_ack_slot(8'd0),.trace_ack_tag(768'd0),.trace_ack_ok(4'hf),
    .result_free,.result_reserved,.result_returned,.trace_free,
    .done_valid,.done_error,.protocol_failure,.first_error_rank,
    .first_bad_element,.accepted_stripes,
    .step_valid,.step_ready,.step_tile,.step_block,.step_done_valid,
    .step_done_ready,.step_done_tile,.step_done_block,
    .step_done_accepted,.step_done_row_retired,.step_done_terminal,
    .step_done_error,.step_done_protocol,.step_done_first_rank,.step_done_bad);

  always @(posedge clk) if(rst_n) begin
    cycles++;
    if(cycles>200000) $fatal(1,"STEP16 first tile stalled");
    if(|final_skip_valid) $fatal(1,"STEP16 unexpected final skip");
    if(done_valid || done_error || protocol_failure)
      $fatal(1,"STEP16 full task completed during first tile");
    for(int p=0;p<4;p++) if(commit_valid[p]) begin
      if(commit_tile[p*10+:10]!==10'd0 ||
         commit_lane_mask[p*8+:8]!==8'hff ||
         commit_bad_mask[p*8+:8]!==8'd0)
        $fatal(1,"STEP16 bad first-tile commit p=%0d",p);
      for(int lane=0;lane<8;lane++)
        if(commit_next_ps[p*256+lane*32+:32]!==32'd0)
          $fatal(1,"STEP16 zero-dot PS mismatch p=%0d lane=%0d",p,lane);
      committed++;
      if({commit_tag[p*192+160],commit_tag[p*192+11+:6]}==7'd31)
        terminal++;
    end
  end

  initial begin
    step_tile=0;step_block=0;issue_tile=0;issue_block=0;
    issue_sequence=0;issue_group=0;
    repeat(5) @(negedge clk);
    rst_n=1;
    @(negedge clk);
    config_valid=1;
    #1ps;if(!config_ready) $fatal(1,"STEP16 config unavailable");
    @(posedge clk);@(negedge clk);config_valid=0;
    for(int b=0;b<4;b++) begin
      step_tile=0;step_block=2'(b);step_valid=1;
      #1ps;if(!step_ready) $fatal(1,"STEP16 step %0d unavailable",b);
      @(posedge clk);@(negedge clk);step_valid=0;
      for(int g=0;g<32;g++) begin
        issue_tile=0;issue_block=2'(b);issue_group=7'(g);
        issue_sequence=27'(b*32+g);issue_valid=1;
        #1ps;
        while(!issue_ready) begin
          @(negedge clk);#1ps;
        end
        if(!dut.header_ok) $fatal(1,"STEP16 header rejected b=%0d g=%0d",b,g);
        @(posedge clk);@(negedge clk);issue_valid=0;
      end
      while(!step_done_valid) @(negedge clk);
      if(step_done_tile!==10'd0 || step_done_block!==2'(b) ||
         step_done_accepted!==6'd32 || step_done_row_retired!==8'd128 ||
         step_done_terminal!==3'd4 || step_done_error || step_done_protocol ||
         step_done_first_rank!=='1 || step_done_bad!=='1 ||
         committed!=(b+1)*128 || terminal!=(b+1)*4)
        $fatal(1,"STEP16 step %0d retirement mismatch accepted=%0d row=%0d terminal=%0d commits=%0d",
               b,step_done_accepted,step_done_row_retired,step_done_terminal,committed);
      repeat(3) begin
        @(negedge clk);
        if(!step_done_valid || step_done_tile!==10'd0 ||
           step_done_block!==2'(b) || step_done_accepted!==6'd32 ||
           step_done_row_retired!==8'd128 || step_done_terminal!==3'd4)
          $fatal(1,"STEP16 held step fields changed b=%0d",b);
      end
      step_done_ready=1;
      @(posedge clk);@(negedge clk);step_done_ready=0;
    end
    if(accepted_stripes!==27'd128 || committed!=512 || terminal!=16 ||
       done_valid || dut.next_tile!==10'd1 || dut.next_block!==2'd0 ||
       result_free!=={4{6'd35}} || result_reserved!=0 ||
       result_returned!=0 || trace_free!=={4{3'd4}})
      $fatal(1,"STEP16 first tile boundary mismatch");
    $display("STEP16_FIRST_TILE_PASS stripes=%0d commits=%0d terminal=%0d cycles=%0d",
             accepted_stripes,committed,terminal,cycles);
    $finish;
  end
endmodule
