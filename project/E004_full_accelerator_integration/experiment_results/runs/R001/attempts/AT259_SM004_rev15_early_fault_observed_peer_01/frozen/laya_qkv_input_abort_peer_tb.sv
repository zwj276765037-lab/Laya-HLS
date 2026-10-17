`timescale 1ns/1ps
module laya_qkv_input_abort_peer_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1,cmd_mode=1;
  logic [6:0] cmd_row=0;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] cmd_id=0,cmd_w_epoch=1,cmd_down_w_epoch=0;
  logic [15:0] cmd_weight_key=16'h0001,cmd_down_weight_key=0;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0,cmd_down_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0,cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic x_valid,x_ready,gamma_valid,gamma_ready;
  logic [31:0] x_bits,gamma_bits;
  logic row_valid,rd_valid=0,rd_ready,rsp_valid,rsp_ready=0;
  logic [9:0] rd_tile=0,rsp_tile;
  logic [255:0] rsp_bits;
  logic row_release_valid=0,row_release_ready,done_valid,done_ready=0;
  logic [3:0] done_status,done_phase;
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
  logic cmd_tensor_begin=0;
  logic [31:0] cmd_tensor_epoch=1,done_id;
  logic [2:0][31:0] cmd_dst_epoch;
  logic [2:0][63:0] cmd_dst_base,cmd_dst_span;
  logic cmd_source_hidden_bank=0;
  logic tensor_release_valid=0,tensor_release_ready,tensor_release_discard=0;
  logic [31:0] tensor_release_epoch=0,tensor_epoch;
  logic [63:0] tensor_release_request=0,tensor_release_generation=0;
  logic tensor_raw_valid,tensor_failed;
  logic [127:0] row_written;
  logic [63:0] tensor_request,tensor_generation;
  logic [3327:0] tensor_model_identity;
  logic [671:0] tensor_numeric_identity;
  logic [2:0][31:0] tensor_dst_epoch;
  logic [2:0][63:0] tensor_dst_base,tensor_dst_span;
  logic [2:0][63:0] m_axi_awaddr;
  logic [2:0][7:0] m_axi_awlen;
  logic [2:0][2:0] m_axi_awsize;
  logic [2:0][1:0] m_axi_awburst;
  logic [2:0] m_axi_awvalid,m_axi_awready;
  logic [2:0][511:0] m_axi_wdata;
  logic [2:0][63:0] m_axi_wstrb;
  logic [2:0] m_axi_wlast,m_axi_wvalid,m_axi_wready;
  logic [2:0][1:0] m_axi_bresp;
  logic [2:0] m_axi_bvalid,m_axi_bready;
  logic [2:0][31:0] scratch_aw_count,scratch_w_count,scratch_b_count;
  logic [9:0] scratch_rsp_count;
  logic [5:0] scratch_flush_count;
  logic [1:0] scratch_error_dst,scratch_error_bresp;
  logic [31:0] scratch_error_ordinal;
  logic cmd_rope_enable=1;
  logic [63:0] cmd_rope_aux_base=0,cmd_rope_aux_span=64'd1142528;
  logic tensor_rope_enable,tensor_final_valid;
  logic [127:0] row_final;
  logic [2:0][31:0] tensor_final_dst_epoch;
  logic done_rope_check_valid,done_rope_plane;
  logic [127:0] done_rope_check;
  logic [3:0] done_rope_head;
  logic [1:0][63:0] rope_araddr;
  logic [1:0][7:0] rope_arlen;
  logic [1:0][2:0] rope_arsize;
  logic [1:0][1:0] rope_arburst;
  logic [1:0] rope_arvalid,rope_arready,rope_rlast,rope_rvalid,rope_rready;
  logic [1:0][511:0] rope_rdata;
  logic [1:0][1:0] rope_rresp;
  logic cmd_input_from_state0=0;
  logic [63:0] cmd_state0_base=64'h20000000;
  logic [63:0] cmd_state0_span=64'd8388608;
  logic [31:0] cmd_state0_epoch=1;
  logic [63:0] state0_araddr;
  logic [7:0] state0_arlen;
  logic [2:0] state0_arsize;
  logic [1:0] state0_arburst;
  logic state0_arvalid,state0_arready;
  logic [511:0] state0_rdata;
  logic [1:0] state0_rresp;
  logic state0_rlast,state0_rvalid,state0_rready;
  laya_qkv_scratch_row_v1 dut (
    .*
  );


  logic raw_active=0, gamma_active=0;
  logic early_fault_seen=0;
  integer raw_left=0,gamma_left=0,raw_r_total=0,gamma_r_total=0;
  assign state0_arready=!raw_active;
  assign state0_rvalid=raw_active;
  assign state0_rlast=raw_left==1;
  assign state0_rresp=0;
  assign state0_rdata={16{32'h3f800000}};
  assign aux_arready=!gamma_active;
  assign aux_rvalid=gamma_active;
  assign aux_rlast=gamma_left==1;
  assign aux_rresp=0;
  assign aux_rdata={4{32'h3f800000}};
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      raw_active<=0;gamma_active<=0;raw_left<=0;gamma_left<=0;
      raw_r_total<=0;gamma_r_total<=0;early_fault_seen<=0;
    end else begin
      if(dut.core.prep_fault && !early_fault_seen)begin
        early_fault_seen<=1;
        if(!dut.source_load_active || raw_r_total>=64)
          $fatal(1,"PREP_FAULT_NOT_EARLY rawR=%0d",raw_r_total);
        $display("PREP_FAULT_DURING_RAW_LOAD rawR=%0d",raw_r_total);
      end
      if(state0_arvalid && state0_arready)begin
        raw_active<=1;raw_left<=int'(state0_arlen)+1;
      end
      if(state0_rvalid && state0_rready)begin
        raw_r_total<=raw_r_total+1;
        raw_left<=raw_left-1;
        if(raw_left==1)raw_active<=0;
      end
      if(aux_arvalid && aux_arready)begin
        gamma_active<=1;gamma_left<=int'(aux_arlen)+1;
      end
      if(aux_rvalid && aux_rready)begin
        gamma_r_total<=gamma_r_total+1;
        gamma_left<=gamma_left-1;
        if(gamma_left==1)gamma_active<=0;
      end
      if(dut.core_prep_abort_valid &&
         (dut.source_load_active || dut.table_load_active ||
          dut.scratch_reader_out_valid || dut.table_reader_out_valid ||
          dut.input_hold_valid))
        $fatal(1,"PREP_ABORT_BEFORE_REAL_DRAIN raw=%0d gamma=%0d",raw_r_total,gamma_r_total);
    end
  end
  initial begin
    arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;
    m_axi_awready='0;m_axi_wready='0;m_axi_bvalid='0;m_axi_bresp='0;
    rope_arready='0;rope_rdata='0;rope_rresp='0;
    rope_rlast='0;rope_rvalid='0;
    x_valid=0;x_bits=0;gamma_valid=0;gamma_bits=0;
    cmd_input_from_state0=1;cmd_rope_enable=1;
    cmd_model_identity=0;
    cmd_numeric_identity={512'd0,16'd128,16'd1,64'd1,64'd3};
    cmd_task_context={8'd1,16'd0,8'd128,32'h01000001,32'd9};
    cmd_id=9;cmd_row=0;cmd_cold=1;cmd_tensor_begin=1;
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=64'd12582912;cmd_dst_span[1]=64'd12582912;
    cmd_dst_span[2]=64'd8388608;
    cmd_dst_epoch='{default:32'd1};
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"INPUT_FAULT_FIRST_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<3000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=7 || done_phase!=14 ||
       !early_fault_seen || raw_r_total!=64 || gamma_r_total!=0 ||
       dut.core.abort_count!=1 || dut.core.accepted_prepared_count!=0 ||
       !tensor_failed || row_written!=0 || row_final!=0 ||
       dut.source_load_active || dut.scratch_reader_out_valid)
      $fatal(1,"INPUT_FAULT_DRAIN_BAD rawR=%0d gammaR=%0d aborts=%0d status=%0d phase=%0d",
        raw_r_total,gamma_r_total,dut.core.abort_count,done_status,done_phase);
    repeat(3)begin @(negedge clk);if(!done_valid)$fatal(1,"INPUT_ERROR_DONE_NOT_HELD");end
    done_ready=1;@(negedge clk);done_ready=0;
    tensor_release_discard=1;tensor_release_epoch=1;
    tensor_release_request=3;tensor_release_generation=1;
    tensor_release_valid=1;
    #1ps;if(!tensor_release_ready)$fatal(1,"INPUT_FAULT_DISCARD_NOT_READY");
    @(negedge clk);tensor_release_valid=0;
    cmd_tensor_epoch=3;cmd_state0_epoch=3;cmd_dst_epoch='{default:32'd3};
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"INPUT_FAULT_RECOVERY_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<3000 && dut.core.accepted_prepared_count==0;guard++)
      @(negedge clk);
    if(dut.core.accepted_prepared_count!=1 || raw_r_total!=128 ||
       gamma_r_total!=256 || dut.core.abort_count!=1 ||
       dut.core.prep_fault || tensor_failed || dut.source_epoch!=3)
      $fatal(1,"INPUT_FAULT_RECOVERY_BAD rawR=%0d gammaR=%0d accepts=%0d",
        raw_r_total,gamma_r_total,dut.core.accepted_prepared_count);
    $display("SOURCE_EARLY_FAULT_DRAIN_RECOVERY_PASS rawR=%0d gammaR=%0d aborts=%0d",raw_r_total,gamma_r_total,dut.core.abort_count);
    $finish;
  end
endmodule
