`timescale 1ns/1ps
module laya_prepared_token_boundary_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1;
  logic cmd_mode=0;
  logic [6:0] cmd_row=0;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] cmd_id=1,cmd_w_epoch=1,cmd_down_w_epoch=1;
  logic [15:0] cmd_weight_key=3,cmd_down_weight_key=4;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0,cmd_down_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0,cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic x_valid,x_ready,drive_source=0;
  logic [31:0] x_bits;
  logic gamma_valid=0,gamma_ready;
  logic [31:0] gamma_bits=0;
  logic row_valid,rd_valid=0,rd_ready;
  logic [9:0] rd_tile=0,rsp_tile;
  logic rsp_valid,rsp_ready=0;
  logic [255:0] rsp_bits;
  logic row_release_valid=0,row_release_ready;
  logic done_valid,done_ready=0;
  logic [3:0] done_status;
  logic [3:0] done_phase;
  logic [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [31:0] actual_w_reads,actual_w_returns,actual_stripes,actual_ps_commits;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst;
  logic [2:0] arvalid,arready;
  logic [2:0][511:0] rdata;
  logic [2:0][1:0] rresp;
  logic [2:0] rlast,rvalid,rready;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize,aux_arburst;
  logic aux_arvalid,aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast,aux_rvalid,aux_rready;

  logic cmd_prepared_source=1;
  logic [31:0] cmd_source_epoch=1;
  logic prep_begin_valid=0,prep_begin_ready;
  logic [31:0] prep_id=11,prep_epoch=1;
  logic [6:0] prep_row=0;
  logic prep_write_valid=0,prep_write_ready;
  logic [10:0] prep_write_index=0;
  logic [31:0] prep_write_bits=0;
  logic prep_commit_valid=0,prep_commit_ready;
  logic prep_abort_valid=0,prep_abort_ready;
  logic prep_token_valid,prep_fault;
  laya_lnq_wi_gqdown_row_v1 dut(.*, .cmd_exec(3'd0),.cmd_gamma_aux_base('0),.cmd_gamma_aux_span('0),
    .prep_kind(2'b00),.prep_model_identity('0),.prep_numeric_identity('0),
    .prep_gamma_aux_base('0),.prep_gamma_aux_span('0),
    .gamma_token_valid(),.a_window_ready(),
    .a_window_release_valid(1'b0),.a_window_discard(1'b0),
    .a_window_release_ready(),.row_release_discard(1'b0),
    .done_op(),.done_check_status(),.done_detail(),.done_bad64(),
    .result_exec());
  initial begin
    arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;
    aux_arready=0;aux_rdata=0;aux_rresp=0;aux_rlast=0;aux_rvalid=0;
    cmd_mode=1;cmd_weight_key=16'h0001;cmd_load_bytes[0]=1572864;
    cmd_load_bytes[1]=1572864;cmd_load_bytes[2]=196608;
    cmd_task_context={8'd1,16'd0,8'd128,32'h01000001,32'd11};
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_id=11;cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"PREP_MISSING_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<8 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=7 || done_phase!=14 ||
       row_valid || prep_token_valid || arvalid!='0 || aux_arvalid)
      $fatal(1,"PREP_MISSING_TOKEN_NOT_REJECTED");
    done_ready=1;@(negedge clk);done_ready=0;
    @(negedge clk);prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"PREP_BEGIN_NOT_READY");
    @(negedge clk);prep_begin_valid=0;
    cmd_prepared_source=0;cmd_valid=1;
    #1ps;if(cmd_ready)$fatal(1,"ORDINARY_CMD_ENTERED_OWNED_BANK");
    @(negedge clk);cmd_valid=0;cmd_prepared_source=1;
    for(int i=0;i<2048;i++)begin
      prep_write_valid=1;prep_write_index=11'(i);
      prep_write_bits=32'h3f800000+32'(i);
      #1ps;if(!prep_write_ready)$fatal(1,"PREP_ORDERED_WRITE_REFUSED index=%0d",i);
      @(negedge clk);
    end
    prep_write_valid=0;prep_commit_valid=1;
    #1ps;if(!prep_commit_ready || prep_fault || prep_token_valid)
      $fatal(1,"PREP_COMMIT_EARLY_OR_REFUSED count=%0d",dut.prep_count);
    @(negedge clk);prep_commit_valid=0;
    if(!prep_token_valid || dut.prep_count!=2048 ||
       dut.final_bank[0][0]!==32'h3f800000 ||
       dut.final_bank[7][255]!==32'h3f8007ff)
      $fatal(1,"PREP_BANK_TOKEN_BAD");
    cmd_id=12;cmd_task_context[31:0]=12;cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"PREP_MISMATCH_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<8 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=7 || done_phase!=14 ||
       prep_token_valid || row_valid || arvalid!='0 || aux_arvalid ||
       x_ready || gamma_ready)
      $fatal(1,"PREP_MISMATCH_TOKEN_NOT_REJECTED");
    repeat(3)begin @(negedge clk);if(!done_valid)$fatal(1,"PREP_ERROR_DONE_NOT_HELD");end
    $display("PREPARED_TOKEN_BOUNDARY_PASS missing=1 owned_bank=1 writes=2048 mismatch=1 phase=14");
    $finish;
  end
endmodule
