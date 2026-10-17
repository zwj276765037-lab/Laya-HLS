`timescale 1ns/1ps
module laya_ln_only_local_reject_tb;
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
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst;
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
  logic [1:0] prep_kind=0;
  logic [7:0] done_op;
  logic [15:0] done_check_status;
  logic [31:0] done_detail;
  logic [63:0] done_bad64;
  logic [2:0] result_exec;
  int lower_accepts=0, axi_reads=0;
  always @(posedge clk) if(rst_n) begin
    if(dut.bank_service.staged_ln_cmd_valid &&
       dut.bank_service.staged_ln_cmd_ready)
      lower_accepts<=lower_accepts+1;
    if(arvalid!='0 || aux_arvalid) axi_reads<=axi_reads+1;
  end
  laya_lnq_wi_gqdown_row_v1 dut(.*, .cmd_exec(3'd1),.cmd_gamma_aux_base(64'h1000),.cmd_gamma_aux_span(64'd1142528),
    .prep_kind(prep_kind),.prep_model_identity('0),.prep_numeric_identity('0),
    .prep_gamma_aux_base(64'h1000),.prep_gamma_aux_span(64'd1142528),
    .gamma_token_valid(),.a_window_ready(),
    .a_window_release_valid(1'b0),.a_window_discard(1'b0),
    .a_window_release_ready(),.row_release_discard(1'b0),
    .done_op,.done_check_status,.done_detail,.done_bad64,
    .result_exec);
  task automatic prepare(input logic [1:0] kind,input logic [31:0] bits);
    @(negedge clk);prep_kind=kind;prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"LN_LOCAL_PREP_BEGIN kind=%0d",kind);
    @(negedge clk);prep_begin_valid=0;
    for(int i=0;i<1024;i++)begin
      prep_write_valid=1;prep_write_index=11'(i);prep_write_bits=bits;
      #1ps;if(!prep_write_ready)$fatal(1,"LN_LOCAL_PREP_WRITE kind=%0d index=%0d",kind,i);
      @(negedge clk);
    end
    prep_write_valid=0;prep_commit_valid=1;
    #1ps;if(!prep_commit_ready || prep_fault)$fatal(1,"LN_LOCAL_PREP_COMMIT kind=%0d",kind);
    @(negedge clk);prep_commit_valid=0;
  endtask
  initial begin
    arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;
    aux_arready=0;aux_rdata=0;aux_rresp=0;aux_rlast=0;aux_rvalid=0;
    x_valid=0;x_bits=0;cmd_mode=1;cmd_id=11;prep_id=11;
    cmd_task_context={8'd1,16'd0,8'd128,32'h01000001,32'd11};
    repeat(5)@(negedge clk);rst_n=1;
    prepare(2'b11,32'h3f800000);
    if(!dut.bank_service.gamma_token_valid)$fatal(1,"LN_LOCAL_GAMMA_TOKEN");
    prepare(2'b01,32'h00000000);
    if(!prep_token_valid)$fatal(1,"LN_LOCAL_RAW_TOKEN");
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"LN_LOCAL_FIRST_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<50000 && !row_valid && !done_valid;guard++)@(negedge clk);
    if(!row_valid || done_valid)$fatal(1,"LN_LOCAL_FIRST_NO_VIEW status=%0d",done_status);
    row_release_valid=1;
    #1ps;if(!row_release_ready)$fatal(1,"LN_LOCAL_FIRST_RELEASE");
    @(negedge clk);row_release_valid=0;
    for(int guard=0;guard<16 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_check_status!=0 ||
       done_detail!=0 || done_op!=8'h10 || result_exec!=3'd1 ||
       done_bad64!=64'hffff_ffff_ffff_ffff || lower_accepts!=1)
      $fatal(1,"LN_LOCAL_FIRST_DONE status=%0d check=%0d lower=%0d",done_status,done_check_status,lower_accepts);
    done_ready=1;@(negedge clk);done_ready=0;
    if(prep_token_valid)$fatal(1,"LN_LOCAL_TOKEN_STILL_VALID");
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"LN_LOCAL_REPEAT_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<16 && !done_valid;guard++)@(negedge clk);
    if($test$plusargs("EXPECT_OLD"))begin
      if(!done_valid || done_status!=7 || done_phase!=14 ||
         done_op!=8'h10 || done_check_status!=0 || done_detail!=0 ||
         done_bad64!=64'hffff_ffff_ffff_ffff ||
         lower_accepts!=1 || axi_reads!=0)
        $fatal(1,"LN_LOCAL_OLD_REPRO_MISMATCH status=%0d phase=%0d op=%0d check=%0d detail=%h bad=%h lower=%0d axi=%0d",
          done_status,done_phase,done_op,done_check_status,done_detail,done_bad64,lower_accepts,axi_reads);
      $display("LN_LOCAL_OLD_CHECK_BUG_REPRODUCED status=7 check=0 detail=0 lower_accepts=1");
    end else if(!done_valid || done_status!=7 || done_phase!=14 ||
       done_op!=8'h10 || done_check_status!=16'd7 ||
       done_detail!=32'h0710_0005 ||
       done_bad64!=64'hffff_ffff_ffff_ffff ||
       lower_accepts!=1 || axi_reads!=0)
      $fatal(1,"LN_LOCAL_REPEAT_CHECK status=%0d phase=%0d op=%0d check=%0d detail=%h bad=%h lower=%0d axi=%0d",
        done_status,done_phase,done_op,done_check_status,done_detail,done_bad64,lower_accepts,axi_reads);
    repeat(3)begin
      @(negedge clk);
      if(!done_valid ||
         ($test$plusargs("EXPECT_OLD") ?
          (done_check_status!=0 || done_detail!=0) :
          (done_check_status!=7 || done_detail!=32'h0710_0005)))
        $fatal(1,"LN_LOCAL_REPEAT_HOLD");
    end
    if(!$test$plusargs("EXPECT_OLD"))
      $display("LN_LOCAL_REJECT_CHECK_PASS first_lower=1 second_lower=0 axi=0");
    done_ready=1;
    @(negedge clk);done_ready=0;
    if(done_valid)$fatal(1,"LN_LOCAL_REJECT_NOT_CONSUMED");
    prepare(2'b01,32'h00000000);
    if(!prep_token_valid)$fatal(1,"LN_LOCAL_RECOVERY_TOKEN");
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"LN_LOCAL_RECOVERY_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<50000 && !row_valid && !done_valid;guard++)
      @(negedge clk);
    if(!row_valid || done_valid || lower_accepts!=2 || axi_reads!=0)
      $fatal(1,"LN_LOCAL_RECOVERY_NO_VIEW lower=%0d axi=%0d",
             lower_accepts,axi_reads);
    row_release_valid=1;
    #1ps;if(!row_release_ready)$fatal(1,"LN_LOCAL_RECOVERY_RELEASE");
    @(negedge clk);row_release_valid=0;
    for(int guard=0;guard<16 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_check_status!=0 ||
       done_detail!=0 || done_op!=8'h10 || result_exec!=3'd1 ||
       done_bad64!=64'hffff_ffff_ffff_ffff || lower_accepts!=2 ||
       axi_reads!=0)
      $fatal(1,"LN_LOCAL_RECOVERY_DONE status=%0d check=%0d lower=%0d",
             done_status,done_check_status,lower_accepts);
    $display("LN_LOCAL_REJECT_CONSUMED_RECOVERY_PASS lower=2 axi=0");
    $finish;
  end
endmodule
