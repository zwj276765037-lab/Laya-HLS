`timescale 1ns/1ps

// One fixed Wi -> canonical G -> Down row with shared Q/matrix/W services.
module laya_qkv_scratch_row_v1 (
  input logic clk, rst_n,
  input logic cmd_valid,
  output logic cmd_ready,
  input logic [31:0] cmd_id,
  input logic cmd_cold,
  input logic cmd_mode,
  input logic [6:0] cmd_row,
  input logic [31:0] cmd_w_epoch,
  input logic [15:0] cmd_weight_key,
  input logic [3327:0] cmd_model_identity,
  input logic [671:0] cmd_numeric_identity,
  input logic [95:0] cmd_task_context,
  input logic [1023:0] cmd_expected_aux_header,
  input logic [2:0][63:0] cmd_load_base,
  input logic [2:0][31:0] cmd_load_bytes,
  input logic [63:0] cmd_aux_base,
  input logic [63:0] cmd_bias_base,
  input logic [31:0] cmd_bias_bytes,
  input logic [31:0] cmd_down_w_epoch,
  input logic [15:0] cmd_down_weight_key,
  input logic [1023:0] cmd_down_expected_aux_header,
  input logic [2:0][63:0] cmd_down_load_base,
  input logic [2:0][31:0] cmd_down_load_bytes,
  input logic [63:0] cmd_down_aux_base,
  input logic [63:0] cmd_down_bias_base,
  input logic [31:0] cmd_down_bias_bytes,
  input logic x_valid,
  output logic x_ready,
  input logic [31:0] x_bits,
  input logic gamma_valid,
  output logic gamma_ready,
  input logic [31:0] gamma_bits,
  output logic row_valid,
  input logic rd_valid,
  output logic rd_ready,
  input logic [9:0] rd_tile,
  output logic rsp_valid,
  input logic rsp_ready,
  output logic [9:0] rsp_tile,
  output logic [255:0] rsp_bits,
  input logic row_release_valid,
  output logic row_release_ready,
  output logic done_valid,
  input logic done_ready,
  output logic [3:0] done_status,
  output logic [3:0] done_phase,
  output logic result_mode,
  output logic [6:0] result_row,
  output logic [31:0] done_bad_element,
  output logic [31:0] mean_bits, variance_bits, inverse_bits,
  output logic [31:0] actual_w_reads, actual_w_returns,
  output logic [31:0] actual_stripes, actual_ps_commits,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,
  input logic cmd_tensor_begin,
  input logic [31:0] cmd_tensor_epoch,
  input logic [2:0][31:0] cmd_dst_epoch,
  input logic [2:0][63:0] cmd_dst_base, cmd_dst_span,
  input logic cmd_source_hidden_bank,
  input logic cmd_rope_enable,
  input logic [63:0] cmd_rope_aux_base, cmd_rope_aux_span,
  input logic cmd_input_from_state0,
  input logic cmd_staged_ln,
  input logic cmd_stage_discard_norm,
  input logic [63:0] cmd_state0_base, cmd_state0_span,
  input logic [31:0] cmd_state0_epoch,
  output logic [63:0] state0_araddr,
  output logic [7:0] state0_arlen,
  output logic [2:0] state0_arsize,
  output logic [1:0] state0_arburst,
  output logic state0_arvalid,
  input logic state0_arready,
  input logic [511:0] state0_rdata,
  input logic [1:0] state0_rresp,
  input logic state0_rlast, state0_rvalid,
  output logic state0_rready,
  output logic [31:0] done_id,
  input logic tensor_release_valid,
  output logic tensor_release_ready,
  input logic tensor_release_discard,
  input logic [31:0] tensor_release_epoch,
  input logic [63:0] tensor_release_request, tensor_release_generation,
  output logic tensor_raw_valid,
  output logic tensor_rope_enable,
  output logic [127:0] row_final,
  output logic tensor_final_valid,
  output logic [2:0][31:0] tensor_final_dst_epoch,
  output logic [127:0] row_written,
  output logic [127:0] norm_written,
  output logic norm_stage_ready,
  output logic stage_store_fault,
  output logic tensor_failed,
  output logic [31:0] tensor_epoch,
  output logic [63:0] tensor_request, tensor_generation,
  output logic [3327:0] tensor_model_identity,
  output logic [671:0] tensor_numeric_identity,
  output logic [2:0][31:0] tensor_dst_epoch,
  output logic [2:0][63:0] tensor_dst_base, tensor_dst_span,
  output logic [2:0][63:0] m_axi_awaddr,
  output logic [2:0][7:0] m_axi_awlen,
  output logic [2:0][2:0] m_axi_awsize,
  output logic [2:0][1:0] m_axi_awburst,
  output logic [2:0] m_axi_awvalid,
  input logic [2:0] m_axi_awready,
  output logic [2:0][511:0] m_axi_wdata,
  output logic [2:0][63:0] m_axi_wstrb,
  output logic [2:0] m_axi_wlast, m_axi_wvalid,
  input logic [2:0] m_axi_wready,
  input logic [2:0][1:0] m_axi_bresp,
  input logic [2:0] m_axi_bvalid,
  output logic [2:0] m_axi_bready,
  output logic [2:0][31:0] scratch_aw_count, scratch_w_count,
  output logic [2:0][31:0] scratch_b_count,
  output logic [9:0] scratch_rsp_count,
  output logic [5:0] scratch_flush_count,
  output logic [1:0] scratch_error_dst,
  output logic [31:0] scratch_error_ordinal,
  output logic [1:0] scratch_error_bresp,
  output logic done_rope_check_valid,
  output logic [127:0] done_rope_check,
  output logic [3:0] done_rope_head,
  output logic done_rope_plane,
  output logic [7:0] done_op,
  output logic [15:0] done_check_status,
  output logic [31:0] done_detail,
  output logic [63:0] done_bad64,
  output logic [1:0][63:0] rope_araddr,
  output logic [1:0][7:0] rope_arlen,
  output logic [1:0][2:0] rope_arsize,
  output logic [1:0][1:0] rope_arburst,
  output logic [1:0] rope_arvalid,
  input logic [1:0] rope_arready,
  input logic [1:0][511:0] rope_rdata,
  input logic [1:0][1:0] rope_rresp,
  input logic [1:0] rope_rlast, rope_rvalid,
  output logic [1:0] rope_rready
);

  int accepted=0,delay_count=0;
  bit busy=0, numeric_later=0;
  initial numeric_later=$test$plusargs("NUMERIC_LATER");
  assign cmd_ready=!busy && !done_valid;
  assign tensor_release_ready=tensor_epoch!=0;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      accepted<=0;delay_count<=0;busy<=0;done_valid<=0;
      done_status<=0;done_phase<=7;done_bad_element<='1;
      done_op<=0;done_check_status<=0;done_detail<=0;done_bad64<='1;
      done_id<=0;result_mode<=0;result_row<=0;
      tensor_epoch<=0;tensor_final_valid<=0;tensor_failed<=0;
      row_written<=0;row_final<=0;norm_written<=0;
      norm_stage_ready<=0;stage_store_fault<=0;
      done_rope_check_valid<=0;done_rope_check<=0;
      done_rope_head<=0;done_rope_plane<=0;
      scratch_error_bresp<=0;
    end else begin
      if(tensor_release_valid && tensor_release_ready)begin
        tensor_epoch<=0;tensor_failed<=0;stage_store_fault<=0;
        row_written<=0;row_final<=0;norm_written<=0;
      end
      if(cmd_valid && cmd_ready)begin
        if(accepted>=16 || cmd_id!=32'(81+accepted) ||
           cmd_row!=7'(accepted) || cmd_cold ||
           cmd_tensor_begin!=(accepted==0) ||
           cmd_stage_discard_norm!=(accepted>=2) ||
           !cmd_staged_ln || !cmd_mode || !cmd_rope_enable ||
           !cmd_input_from_state0 || cmd_state0_epoch!=1 ||
           cmd_tensor_epoch!=1 || cmd_task_context[87:72]!=16'(accepted))
          $fatal(1,"STORE_PRIORITY_ROW_BAD ordinal=%0d id=%0d discard=%b",
            accepted,cmd_id,cmd_stage_discard_norm);
        if(accepted==0)tensor_epoch<=1;
        busy<=1;delay_count<=3;done_id<=cmd_id;
        result_row<=cmd_row;result_mode<=1;
        done_op<=8'h10;done_bad_element<=32'hffffffff;
        done_bad64<=64'hffff_ffff_ffff_ffff;
        done_status<=0;done_phase<=7;
        done_check_status<=0;done_detail<=0;
        if(accepted==1)begin
          done_status<=7;done_phase<=12;done_check_status<=7;
          done_detail<=32'h0710_0005;
          scratch_error_bresp<=2'd2;
        end else if(accepted==7 && numeric_later)begin
          done_status<=6;done_phase<=14;done_check_status<=6;
          done_detail<=32'h0710_000f;
          done_bad_element<=0;done_bad64<=64'd7168;
        end
      end
      if(busy && delay_count!=0)delay_count<=delay_count-1;
      if(busy && delay_count==1)begin
        done_valid<=1;
        if(accepted==1)begin
          stage_store_fault<=1;tensor_failed<=1;
        end
      end
      if(done_valid && done_ready)begin
        done_valid<=0;busy<=0;
        if(accepted==0)norm_written[0]<=1;
        accepted<=accepted+1;
      end
    end
  end
endmodule

module laya_staged_ln_store_priority_peer_tb;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,request_valid=0,request_ready;
  logic request_staged_ln=0;
  logic [31:0] request_base_cmd_id=0;
  logic request_done_valid,request_done_ready=0;
  logic [3:0] request_done_status,request_done_phase;
  logic [31:0] request_done_bad_element,request_done_id;
  logic [6:0] request_done_row;
  logic request_done_rope_check_valid,request_done_rope_plane;
  logic [127:0] request_done_rope_check;
  logic [3:0] request_done_rope_head;
  logic [31:0] cmd_w_epoch=1,cmd_down_w_epoch=0;
  logic [15:0] cmd_weight_key=16'h0001,cmd_down_weight_key=0;
  logic [3327:0] cmd_model_identity='0;
  logic [671:0] cmd_numeric_identity='0;
  logic [95:0] cmd_task_context='0;
  logic [1023:0] cmd_expected_aux_header='0,cmd_down_expected_aux_header='0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0;
  logic [63:0] cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic [31:0] cmd_tensor_epoch=1;
  logic [2:0][31:0] cmd_dst_epoch='0;
  logic [2:0][63:0] cmd_dst_base='0,cmd_dst_span='0;
  logic [63:0] cmd_rope_aux_base=0,cmd_rope_aux_span=64'd1142528;
  logic [63:0] cmd_state0_base=64'h20000000;
  logic [63:0] cmd_state0_span=64'd8388608;
  logic [31:0] cmd_state0_epoch=1;
  logic tensor_release_valid=0,tensor_release_ready;
  logic tensor_release_discard=0;
  logic [31:0] tensor_release_epoch=2,tensor_epoch;
  logic [63:0] tensor_release_request=3,tensor_release_generation=1;
  logic tensor_final_valid,tensor_raw_valid,tensor_failed;
  logic [127:0] row_written,row_final;
  logic [127:0] norm_written;
  logic norm_stage_ready;
  logic [7:0] request_done_op;
  logic [15:0] request_done_check_status;
  logic [31:0] request_done_detail;
  logic [63:0] request_done_bad64;
  laya_qkv_s128_request_v1 dut(
    .clk,.rst_n,.request_valid,.request_ready,.request_base_cmd_id,
    .request_staged_ln,.norm_written,.norm_stage_ready,
    .request_done_op,.request_done_check_status,
    .request_done_detail,.request_done_bad64,
    .request_done_valid,.request_done_ready,.request_done_status,
    .request_done_phase,.request_done_bad_element,.request_done_id,
    .request_done_row,.request_done_rope_check_valid,
    .request_done_rope_check,.request_done_rope_head,
    .request_done_rope_plane,
    .cmd_w_epoch,.cmd_down_w_epoch,.cmd_weight_key,
    .cmd_down_weight_key,.cmd_model_identity,.cmd_numeric_identity,
    .cmd_task_context,.cmd_expected_aux_header,
    .cmd_down_expected_aux_header,.cmd_load_base,.cmd_load_bytes,
    .cmd_down_load_base,.cmd_down_load_bytes,.cmd_aux_base,
    .cmd_bias_base,.cmd_bias_bytes,.cmd_down_aux_base,
    .cmd_down_bias_base,.cmd_down_bias_bytes,
    .cmd_tensor_epoch,.cmd_dst_epoch,.cmd_dst_base,.cmd_dst_span,
    .cmd_rope_aux_base,.cmd_rope_aux_span,
    .cmd_state0_base,.cmd_state0_span,.cmd_state0_epoch,
    .tensor_release_valid,.tensor_release_ready,
    .tensor_release_discard,.tensor_release_epoch,
    .tensor_release_request,.tensor_release_generation,
    .tensor_epoch,.tensor_final_valid,.tensor_raw_valid,.tensor_failed,
    .row_written,.row_final
  );
  string testcase;
  int expected_count;
  initial begin
    if(!$value$plusargs("CASE=%s",testcase))$fatal(1,"STORE_PRIORITY_CASE");
    if(testcase!="store_only" && testcase!="store_numeric")
      $fatal(1,"STORE_PRIORITY_UNKNOWN_CASE");
    expected_count=testcase=="store_only" ? 16 : 8;
    cmd_load_bytes[0]=1572864;cmd_load_bytes[1]=1572864;
    cmd_load_bytes[2]=196608;
    cmd_dst_epoch='{default:32'd1};
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=12582912;cmd_dst_span[1]=12582912;
    cmd_dst_span[2]=8388608;
    cmd_task_context[31:0]=42;
    cmd_model_identity=3328'h1;cmd_numeric_identity=672'h3;
    repeat(4)@(negedge clk);rst_n=1;
    @(negedge clk);
    request_staged_ln=1;request_base_cmd_id=81;request_valid=1;
    #1ps;if(!request_ready)$fatal(1,"STORE_PRIORITY_REQ_NOT_READY");
    @(negedge clk);request_valid=0;
    cmd_model_identity='1;cmd_numeric_identity='1;
    cmd_task_context='0;cmd_state0_base=0;cmd_state0_epoch=0;
    cmd_dst_base='0;cmd_dst_epoch='0;
    for(int guard=0;guard<500 && !request_done_valid;guard++)begin
      @(negedge clk);
      if(request_done_valid && dut.row_engine.accepted<expected_count)
        $fatal(1,"STORE_PRIORITY_EARLY_DONE rows=%0d",dut.row_engine.accepted);
      if(norm_stage_ready || tensor_final_valid || tensor_raw_valid ||
         row_written!=0 || row_final!=0)
        $fatal(1,"STORE_PRIORITY_FALSE_PUBLICATION");
    end
    if(!request_done_valid || dut.row_engine.accepted!=expected_count ||
       !tensor_failed || norm_written!=128'd1 ||
       request_done_op!=8'h10 ||
       (testcase=="store_only" &&
          (request_done_status!=7 || request_done_phase!=12 ||
           request_done_id!=82 || request_done_row!=1 ||
           request_done_check_status!=7 ||
           request_done_detail!=32'h0710_0005 ||
           request_done_bad64!=64'hffff_ffff_ffff_ffff)) ||
       (testcase=="store_numeric" &&
          (request_done_status!=6 || request_done_phase!=14 ||
           request_done_id!=88 || request_done_row!=7 ||
           request_done_check_status!=6 ||
           request_done_detail!=32'h0710_000f ||
           request_done_bad64!=64'd7168)))
      $fatal(1,"STORE_PRIORITY_RESULT case=%s rows=%0d status=%0d phase=%0d id=%0d",
        testcase,dut.row_engine.accepted,request_done_status,
        request_done_phase,request_done_id);
    repeat(3)begin
      @(negedge clk);
      if(!request_done_valid || request_ready)
        $fatal(1,"STORE_PRIORITY_DONE_HOLD");
    end
    request_done_ready=1;
    @(negedge clk);request_done_ready=0;
    if(request_ready)$fatal(1,"STORE_PRIORITY_RELEASE_BARRIER");
    tensor_release_discard=1;tensor_release_epoch=1;
    tensor_release_valid=1;
    #1ps;if(!tensor_release_ready)$fatal(1,"STORE_PRIORITY_DISCARD_READY");
    @(negedge clk);tensor_release_valid=0;
    if(!request_ready || tensor_epoch!=0)$fatal(1,"STORE_PRIORITY_DISCARD");
    $display("STAGED_LN_STORE_PRIORITY_PEER_PASS case=%s rows=%0d norm_written=1",
             testcase,expected_count);
    $finish;
  end
endmodule
