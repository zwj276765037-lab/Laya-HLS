`timescale 1ns/1ps

// Physical GATE endpoint and task-local owner publication ledger. The admitted
// producer command is immutable until its real write/response debts retire.
// Source acquisition is possible only after actual complete task publication.
module geglu_gate_writer_ledger_v1 (
  input logic clk,rst_n,
  input logic cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic cfg_owner_admitted,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_producer_context,cfg_quant_context,cfg_consumer_context,
  input logic [63:0] cfg_source_ref,cfg_gate_ref,cfg_a_ref,cfg_w_ref,cfg_down_dst_ref,
  input logic [4:0] cfg_rows,
  input logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic row_success,
  input logic [15:0] row_success_row,
  input logic v_valid,
  output logic v_ready,
  input logic [31:0] v_data,v_status,v_frame_tag,
  input logic [15:0] v_row,
  input logic [12:0] v_col,
  input logic v_last,
  output logic row_write_done_valid,
  input logic row_write_done_ready,
  output logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch,
  output logic [15:0] row_write_row,
  output logic [63:0] row_write_bad_element,
  output logic row_write_debt_zero,
  input logic service_done_valid,
  output logic service_done_ready,
  input logic [31:0] service_done_status,
  input logic [63:0] service_done_bad_element,
  input logic [15:0] service_done_bad_row,
  input logic service_read_debt_zero,service_arithmetic_debt_zero,
  output logic producer_done_valid,
  input logic producer_done_ready,
  output logic [31:0] producer_done_status,producer_done_task_id,producer_done_dst_epoch,
  output logic [63:0] producer_done_bad_element,
  output logic [15:0] producer_done_covered_rows,
  output logic producer_done_write_debt_zero,
  output logic [2:0] gate_owner_state,
  input logic gate_acquire_valid,
  output logic gate_acquire_ready,gate_acquire_done,gate_acquire_error,
  input logic [671:0] gate_acquire_numeric_identity,
  input logic [95:0] gate_acquire_quant_context,
  input logic [63:0] gate_acquire_ref,
  input logic gate_release_valid,
  output logic gate_release_ready,gate_release_done,gate_release_error,
  input logic [671:0] gate_release_numeric_identity,
  input logic [95:0] gate_release_quant_context,
  input logic [63:0] gate_release_ref,
  input logic gate_release_read_debt_zero,
  output logic [671:0] bound_numeric_identity,
  output logic [95:0] bound_quant_context,bound_consumer_context,
  output logic [63:0] bound_gate_ref,bound_a_ref,bound_w_ref,bound_down_dst_ref,
  output logic [31:0] aw_count,w_count,b_count,accepted_words,
  output logic [63:0] useful_bytes,physical_bytes,
  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast,m_axi_wvalid,
  input logic m_axi_wready,
  input logic [1:0] m_axi_bresp,
  input logic m_axi_bvalid,
  output logic m_axi_bready
);
  localparam logic [2:0] EMPTY=0,FILL=1,READY=2,LEASED=3,INVALID=4;
  logic configured,failed,tx_valid,tx_aw_sent,tx_w_sent,tx_row_last,row_input_complete;
  logic [31:0] failure_status,last_gate_epoch;
  logic [63:0] failure_bad_element;
  logic [95:0] producer_ctx;
  logic [63:0] source_ref,region_base;
  logic [4:0] rows,row_local;
  logic [15:0] row0;
  logic [7:0] batch;
  logic [12:0] expected_col;
  logic [511:0] pack_data,tx_data;
  logic [63:0] tx_addr;
  logic [15:0] covered_rows;
  logic config_ok,word_ok,lease_ok,release_ok,b_fire;
  wire v_fire=v_valid && v_ready;
  wire debt_zero=!tx_valid && expected_col[3:0]==0;
  always_comb begin : config_check
    logic [64:0] bend,rend;
    logic [127:0] first_addr,last_end;
    logic [16:0] endrow;
    bend={1'b0,cfg_bo_base}+{1'b0,cfg_bo_span};rend={1'b0,cfg_region_base}+{1'b0,cfg_region_span};
    first_addr=128'(cfg_region_base)+128'(cfg_producer_context[63:56])*1024*10496+128'(cfg_producer_context[87:72])*10496;
    last_end=first_addr+128'(cfg_rows)*10496;
    endrow={1'b0,cfg_producer_context[87:72]}+17'(cfg_rows);
    config_ok=cfg_owner_admitted && cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 &&
      cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 && cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 &&
      cfg_rows>=1 && cfg_rows<=16 && cfg_producer_context[95:88]==cfg_rows && endrow<=cfg_numeric_identity[159:144] &&
      cfg_producer_context[31:0]!=0 && cfg_producer_context[39:32]==8'h60 && cfg_producer_context[47:40]==2 && cfg_producer_context[71:64]==0 &&
      cfg_producer_context[63:56]<cfg_numeric_identity[143:128] && cfg_source_ref[39:32]==6 && cfg_gate_ref[39:32]==7 &&
      cfg_source_ref[31:0]!=0 && cfg_gate_ref[31:0]!=0 && cfg_source_ref[63:56]==0 && cfg_gate_ref[63:56]==0 &&
      cfg_gate_ref[31:0]>last_gate_epoch && cfg_source_ref[55:48]==cfg_gate_ref[55:48] &&
      cfg_quant_context[87:40]==cfg_producer_context[87:40] && cfg_quant_context[95:88]==cfg_rows &&
      cfg_consumer_context[87:40]==cfg_producer_context[87:40] && cfg_consumer_context[95:88]==cfg_rows &&
      cfg_quant_context[31:0]!=0 && cfg_consumer_context[31:0]!=0 && cfg_a_ref[39:32]==8'h22 && cfg_w_ref[39:32]==8'h23 && cfg_down_dst_ref[39:32]==3 &&
      cfg_bo_span!=0 && cfg_region_span!=0 && !bend[64] && !rend[64] && cfg_region_base>=cfg_bo_base && rend<=bend &&
      first_addr[127:64]==0 && last_end[127:64]==0 && first_addr[5:0]==0 && last_end<=128'(rend) && last_end<=128'(bend);
    word_ok=row_success && row_success_row==row0+16'(row_local) && v_status==0 && v_frame_tag==producer_ctx[31:0] &&
      v_row==row0+16'(row_local) && v_col==expected_col && v_col<2624 && v_last==(expected_col==2623) && v_data[30:23]!=8'hff;
    lease_ok=gate_owner_state==READY && gate_acquire_numeric_identity==bound_numeric_identity && gate_acquire_quant_context==bound_quant_context && gate_acquire_ref==bound_gate_ref;
    release_ok=gate_owner_state==LEASED && gate_release_numeric_identity==bound_numeric_identity && gate_release_quant_context==bound_quant_context && gate_release_ref==bound_gate_ref;
  end
  assign cfg_ready=rst_n && !configured && !producer_done_valid && (gate_owner_state==EMPTY || gate_owner_state==INVALID);
  // Faults drain the producer's remaining offered row words, while immutable
  // AXI work already offered still completes before failure is returned.
  assign v_ready=rst_n && configured && !row_write_done_valid && row_local<rows && !row_input_complete && (failed || !tx_valid);
  assign row_write_task_id=producer_ctx[31:0];
  assign row_write_dst_epoch=bound_gate_ref[31:0];
  assign row_write_row=row0+16'(row_local);
  assign row_write_debt_zero=!tx_valid && (failed || expected_col[3:0]==0);
  assign service_done_ready=rst_n && configured && !producer_done_valid && !row_write_done_valid && row_write_debt_zero && service_read_debt_zero && service_arithmetic_debt_zero;
  assign producer_done_task_id=producer_ctx[31:0];
  assign producer_done_dst_epoch=bound_gate_ref[31:0];
  assign producer_done_covered_rows=covered_rows;
  assign producer_done_write_debt_zero=row_write_debt_zero;
  assign gate_acquire_ready=rst_n && !configured && !producer_done_valid;
  assign gate_release_ready=rst_n && gate_release_read_debt_zero;
  assign m_axi_awaddr=tx_addr;
  assign m_axi_awlen=0;assign m_axi_awsize=6;assign m_axi_awburst=1;
  assign m_axi_awvalid=rst_n && tx_valid && !tx_aw_sent;
  assign m_axi_wdata=tx_data;assign m_axi_wstrb=64'hffffffffffffffff;assign m_axi_wlast=1;
  assign m_axi_wvalid=rst_n && tx_valid && !tx_w_sent;
  assign m_axi_bready=rst_n && tx_valid && tx_aw_sent && tx_w_sent;
  assign b_fire=m_axi_bvalid && m_axi_bready;
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      configured<=0;failed<=0;tx_valid<=0;tx_aw_sent<=0;tx_w_sent<=0;tx_row_last<=0;row_input_complete<=0;
      failure_status<=0;last_gate_epoch<=0;failure_bad_element<='1;producer_ctx<=0;source_ref<=0;region_base<=0;
      bound_numeric_identity<=0;bound_quant_context<=0;bound_consumer_context<=0;bound_gate_ref<=0;bound_a_ref<=0;bound_w_ref<=0;bound_down_dst_ref<=0;
      rows<=0;row_local<=0;row0<=0;batch<=0;expected_col<=0;pack_data<=0;tx_data<=0;tx_addr<=0;covered_rows<=0;
      row_write_done_valid<=0;row_write_status<=0;row_write_bad_element<='1;producer_done_valid<=0;producer_done_status<=0;producer_done_bad_element<='1;
      cfg_reject<=0;gate_owner_state<=EMPTY;gate_acquire_done<=0;gate_acquire_error<=0;gate_release_done<=0;gate_release_error<=0;
      aw_count<=0;w_count<=0;b_count<=0;accepted_words<=0;useful_bytes<=0;physical_bytes<=0;
    end else begin
      cfg_reject<=0;gate_acquire_done<=0;gate_acquire_error<=0;gate_release_done<=0;gate_release_error<=0;
      if(cfg_valid && cfg_ready) begin
        if(!config_ok)cfg_reject<=1;
        else begin
          configured<=1;failed<=0;failure_status<=0;failure_bad_element<='1;gate_owner_state<=FILL;
          bound_numeric_identity<=cfg_numeric_identity;producer_ctx<=cfg_producer_context;bound_quant_context<=cfg_quant_context;bound_consumer_context<=cfg_consumer_context;
          source_ref<=cfg_source_ref;bound_gate_ref<=cfg_gate_ref;bound_a_ref<=cfg_a_ref;bound_w_ref<=cfg_w_ref;bound_down_dst_ref<=cfg_down_dst_ref;
          region_base<=cfg_region_base;rows<=cfg_rows;row_local<=0;row0<=cfg_producer_context[87:72];batch<=cfg_producer_context[63:56];
          expected_col<=0;row_input_complete<=0;covered_rows<=0;pack_data<=0;last_gate_epoch<=cfg_gate_ref[31:0];
          aw_count<=0;w_count<=0;b_count<=0;accepted_words<=0;useful_bytes<=0;physical_bytes<=0;
        end
      end
      if(m_axi_awvalid && m_axi_awready)begin tx_aw_sent<=1;aw_count<=aw_count+1;end
      if(m_axi_wvalid && m_axi_wready)begin tx_w_sent<=1;w_count<=w_count+1;physical_bytes<=physical_bytes+64;end
      if(v_fire) begin
        expected_col<=expected_col+1;
        if(expected_col==2623) row_input_complete<=1;
        if(!failed) begin
          if(!word_ok)begin failed<=1;failure_status<=2;failure_bad_element<='1;gate_owner_state<=INVALID;pack_data<=0;end
          else begin
            accepted_words<=accepted_words+1;useful_bytes<=useful_bytes+4;
            pack_data[expected_col[3:0]*32+:32]<=v_data;
            if(expected_col[3:0]==15) begin
              tx_valid<=1;tx_aw_sent<=0;tx_w_sent<=0;tx_row_last<=expected_col==2623;
              tx_data<={v_data,pack_data[479:0]};
              tx_addr<=region_base+64'(batch)*1024*10496+64'(row0+16'(row_local))*10496+64'(expected_col>>4)*64;
              pack_data<=0;
            end
          end
        end
      end
      if(b_fire)begin
        tx_valid<=0;tx_aw_sent<=0;tx_w_sent<=0;b_count<=b_count+1;
        if(m_axi_bresp!=0)begin failed<=1;failure_status<=3;failure_bad_element<='1;gate_owner_state<=INVALID;pack_data<=0;end
        if(tx_row_last && !failed && m_axi_bresp==0) begin
          covered_rows[row_local]<=1;row_write_done_valid<=1;row_write_status<=0;row_write_bad_element<='1;
        end
      end
      if(failed && row_input_complete && !tx_valid && !row_write_done_valid)begin
        row_write_done_valid<=1;row_write_status<=failure_status;row_write_bad_element<=failure_bad_element;
      end
      if(row_write_done_valid && row_write_done_ready)begin
        row_write_done_valid<=0;row_local<=row_local+1;expected_col<=0;row_input_complete<=0;pack_data<=0;
      end
      if(service_done_valid && service_done_ready)begin
        producer_done_valid<=1;
        if(!failed && service_done_status==0 && row_local==rows && covered_rows==(16'hffff>>(16-rows)) && aw_count==w_count && w_count==b_count)begin
          producer_done_status<=0;producer_done_bad_element<='1;
        end else begin
          producer_done_status<=failed ? failure_status : service_done_status!=0 ? service_done_status : 2;
          producer_done_bad_element<=failed ? failure_bad_element : service_done_bad_element;
          gate_owner_state<=INVALID;
        end
      end
      if(producer_done_valid && producer_done_ready)begin
        producer_done_valid<=0;configured<=0;
        if(producer_done_status==0)gate_owner_state<=READY;else gate_owner_state<=INVALID;
      end
      if(gate_acquire_valid && gate_acquire_ready)begin
        gate_acquire_done<=1;if(lease_ok)gate_owner_state<=LEASED;else gate_acquire_error<=1;
      end
      if(gate_release_valid && gate_release_ready)begin
        gate_release_done<=1;if(release_ok)gate_owner_state<=EMPTY;else gate_release_error<=1;
      end
    end
  end
endmodule
