`timescale 1ns/1ps

// One source lease, two complete 4096-F32 row slots, one quant row in flight.
// Every row is physically captured from AXI before its quant start is offered.
// The source owner must already have published the entire admitted task.
module quant_f32_two_row_feeder_v1 (
  input logic clk,rst_n,
  input logic cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic cfg_owner_admitted,cfg_source_published,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_producer_context,cfg_quant_context,
  input logic [63:0] cfg_source_ref,
  input logic [12:0] cfg_K,
  input logic [4:0] cfg_rows,
  input logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes,
  output logic [63:0] m_axi_araddr,
  output logic [7:0] m_axi_arlen,
  output logic [2:0] m_axi_arsize,
  output logic [1:0] m_axi_arburst,
  output logic m_axi_arvalid,
  input logic m_axi_arready,
  input logic [511:0] m_axi_rdata,
  input logic [1:0] m_axi_rresp,
  input logic m_axi_rlast,m_axi_rvalid,
  output logic m_axi_rready,
  output logic row_start_valid,
  input logic row_start_ready,
  output logic [31:0] row_cfg_task_id,row_cfg_source_epoch,
  output logic [15:0] row_cfg_row,
  output logic [7:0] row_cfg_groups,
  output logic in_valid,
  input logic in_ready,
  output logic [511:0] in_lanes,
  output logic [31:0] in_task_id,in_source_epoch,
  output logic [15:0] in_row,
  output logic [6:0] in_group,
  output logic in_half,
  output logic [15:0] in_mask,
  input logic row_done_valid,
  output logic row_done_ready,
  input logic [1:0] row_done_status,
  input logic [15:0] row_done_bad_col,
  input logic row_done_debt_zero,
  output logic done_valid,
  input logic done_ready,
  output logic [2:0] done_status,
  output logic [63:0] done_bad_element,
  output logic debt_zero,
  output logic [31:0] ar_count,r_count,complete_rows,quant_starts,input_beats,quant_rows,
  output logic [1:0][2:0] slot_state
);
  localparam logic [2:0] EMPTY=0,FILL=1,READY=2,READING=3;
  localparam logic [1:0] RX_IDLE=0,RX_ADDR=1,RX_DATA=2;
  logic active,failed,q_active,q_slot,fill_slot;
  logic [2:0] failure_status;
  logic [4:0] failure_row;
  logic [671:0] numeric_id;
  logic [95:0] producer_ctx,quant_ctx;
  logic [63:0] source_ref,bo_base,bo_span,region_base,region_span,row_stride,batch_stride;
  logic [12:0] K;
  logic [4:0] rows,next_load,next_quant;
  logic [15:0] row0;
  logic [7:0] batch,groups;
  logic [8:0] beats,rx_beat,tx_issued,tx_accepted;
  logic [3:0] slot_row[0:1];
  logic [1:0] rx_state;
  logic [63:0] rx_addr;
  logic [6:0] burst_beats,burst_received;
  logic command_ok,free_found,free_slot,rx_write,rx_response_bad;
  logic bank_pending;
  logic [8:0] pending_beat;
  logic [1:0][15:0][31:0] bank_data;
  logic bank_read;
  wire cfg_fire=cfg_valid && cfg_ready;
  wire r_fire=m_axi_rvalid && m_axi_rready;
  wire row_start_fire=row_start_valid && row_start_ready;
  wire in_fire=in_valid && in_ready;

  function automatic logic source_ok(input logic [12:0] k,input logic [95:0] ctx,input logic [63:0] refword);
    case(ctx[47:40])
      2: return ctx[71:64]==0 && ((k==1024 && (refword[39:32]==1 || refword[39:32]==2 || refword[39:32]==8)) || (k==2624 && refword[39:32]==7));
      4: return ctx[71:64]==0 && ((k==1024 && (refword[39:32]==1 || refword[39:32]==2 || refword[39:32]==8)) || (k==4096 && refword[39:32]==9));
      5: return ctx[71:64]==1 && k==1024 && refword[39:32]==10 && refword[55:48]==0;
      6: return ctx[71:64]==2 && k==256 && refword[39:32]==10 && refword[55:48]==2;
      default:return 0;
    endcase
  endfunction
  always_comb begin : config_check
    logic [64:0] bend,rend;
    logic [127:0] first_addr,last_end,expected_row_stride,expected_batch_stride;
    logic [16:0] endrow;
    logic [15:0] row_limit;
    row_limit=cfg_quant_context[71:64]==0 ? cfg_numeric_identity[159:144] : cfg_quant_context[71:64]==1 ? 16 : 1;
    endrow={1'b0,cfg_quant_context[87:72]}+17'(cfg_rows);
    expected_row_stride=128'(cfg_K)*4;
    expected_batch_stride=expected_row_stride*(cfg_quant_context[71:64]==0 ? 1024 : cfg_quant_context[71:64]==1 ? 16 : 1);
    bend={1'b0,cfg_bo_base}+{1'b0,cfg_bo_span};rend={1'b0,cfg_region_base}+{1'b0,cfg_region_span};
    first_addr=128'(cfg_region_base)+128'(cfg_quant_context[63:56])*128'(cfg_batch_stride_bytes)+128'(cfg_quant_context[87:72])*128'(cfg_row_stride_bytes);
    last_end=first_addr+128'(cfg_rows)*128'(cfg_row_stride_bytes);
    command_ok=cfg_owner_admitted && cfg_source_published && source_ok(cfg_K,cfg_quant_context,cfg_source_ref) &&
      cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 &&
      cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 &&
      cfg_quant_context[31:0]!=0 && cfg_quant_context[63:56]<cfg_numeric_identity[143:128] &&
      cfg_source_ref[31:0]!=0 && cfg_rows>=1 && cfg_rows<=16 && cfg_quant_context[95:88]==cfg_rows && endrow<=row_limit &&
      cfg_row_stride_bytes==expected_row_stride && cfg_batch_stride_bytes==expected_batch_stride &&
      cfg_bo_span!=0 && cfg_region_span!=0 && !bend[64] && !rend[64] &&
      cfg_region_base>=cfg_bo_base && rend<=bend && first_addr>=128'(cfg_region_base) &&
      last_end<=128'(rend) && last_end<=128'(bend) && first_addr[127:64]==0 && last_end[127:64]==0 && first_addr[5:0]==0;
  end
  always_comb begin
    free_found=0;free_slot=0;
    for(int ss=0;ss<2;ss++) if(!free_found && slot_state[ss]==EMPTY) begin free_found=1;free_slot=1'(ss);end
  end
  assign cfg_ready=rst_n && !active && !done_valid;
  assign m_axi_araddr=rx_addr;
  assign m_axi_arlen=8'(burst_beats-1);
  assign m_axi_arsize=6;
  assign m_axi_arburst=1;
  assign m_axi_arvalid=rst_n && rx_state==RX_ADDR;
  assign m_axi_rready=rst_n && rx_state==RX_DATA;
  assign rx_response_bad=m_axi_rresp!=0 || m_axi_rlast!=(burst_received+1==burst_beats);
  assign rx_write=r_fire && !failed && !rx_response_bad && rx_beat<beats && slot_state[fill_slot]==FILL;
  assign row_start_valid=rst_n && active && !failed && !q_active && next_quant<rows &&
    ((slot_state[0]==READY && slot_row[0]==next_quant) || (slot_state[1]==READY && slot_row[1]==next_quant));
  assign row_cfg_task_id=quant_ctx[31:0];
  assign row_cfg_source_epoch=source_ref[31:0];
  assign row_cfg_row=row0+16'(next_quant);
  assign row_cfg_groups=groups;
  assign in_task_id=quant_ctx[31:0];
  assign in_source_epoch=source_ref[31:0];
  assign in_row=row0+16'(next_quant);
  assign in_mask=16'hffff;
  assign bank_read=q_active && tx_issued<beats && !bank_pending && (!in_valid || in_ready);
  assign row_done_ready=rst_n && q_active && row_done_debt_zero && !bank_pending && !in_valid;
  assign debt_zero=rx_state==RX_IDLE && !bank_pending && !in_valid && !q_active;
  generate for(genvar ss=0;ss<2;ss++) begin: slots
    for(genvar lane=0;lane<16;lane++) begin: lanes
      quant_f32_row_bank_v1 bank(.clk(clk),.we(rx_write && fill_slot==ss),.wbeat(rx_beat[7:0]),
        .wdata(m_axi_rdata[lane*32+:32]),.re(bank_read && q_slot==ss),.rbeat(tx_issued[7:0]),.rdata(bank_data[ss][lane]));
    end
  end endgenerate

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      active<=0;failed<=0;failure_status<=0;failure_row<=31;q_active<=0;q_slot<=0;fill_slot<=0;
      numeric_id<=0;producer_ctx<=0;quant_ctx<=0;source_ref<=0;bo_base<=0;bo_span<=0;region_base<=0;region_span<=0;row_stride<=0;batch_stride<=0;
      K<=0;rows<=0;next_load<=0;next_quant<=0;row0<=0;batch<=0;groups<=0;beats<=0;rx_beat<=0;tx_issued<=0;tx_accepted<=0;
      slot_state<='0;slot_row[0]<=0;slot_row[1]<=0;rx_state<=RX_IDLE;rx_addr<=0;burst_beats<=0;burst_received<=0;
      bank_pending<=0;pending_beat<=0;in_valid<=0;in_lanes<=0;in_group<=0;in_half<=0;
      cfg_reject<=0;done_valid<=0;done_status<=0;done_bad_element<='1;
      ar_count<=0;r_count<=0;complete_rows<=0;quant_starts<=0;input_beats<=0;quant_rows<=0;
    end else begin
      cfg_reject<=0;
      if(done_valid && done_ready) done_valid<=0;
      if(cfg_fire) begin
        if(!command_ok) cfg_reject<=1;
        else begin
          active<=1;failed<=0;failure_status<=0;failure_row<=31;done_bad_element<='1;
          numeric_id<=cfg_numeric_identity;producer_ctx<=cfg_producer_context;quant_ctx<=cfg_quant_context;source_ref<=cfg_source_ref;
          bo_base<=cfg_bo_base;bo_span<=cfg_bo_span;region_base<=cfg_region_base;region_span<=cfg_region_span;row_stride<=cfg_row_stride_bytes;batch_stride<=cfg_batch_stride_bytes;
          K<=cfg_K;groups<=8'(cfg_K>>5);beats<=9'(cfg_K>>4);rows<=cfg_rows;next_load<=0;next_quant<=0;row0<=cfg_quant_context[87:72];batch<=cfg_quant_context[63:56];
          ar_count<=0;r_count<=0;complete_rows<=0;quant_starts<=0;input_beats<=0;quant_rows<=0;
        end
      end
      if(active && !failed && rx_state==RX_IDLE && free_found && next_load<rows) begin : begin_row
        logic [127:0] address;
        logic [8:0] boundary,remaining;
        address=128'(region_base)+128'(batch)*128'(batch_stride)+128'(row0+16'(next_load))*128'(row_stride);
        boundary=9'((4096-address[11:0])>>6);remaining=beats;
        fill_slot<=free_slot;slot_state[free_slot]<=FILL;slot_row[free_slot]<=4'(next_load);
        rx_addr<=address[63:0];rx_beat<=0;burst_received<=0;
        burst_beats<=7'(remaining<boundary ? remaining : boundary);rx_state<=RX_ADDR;
      end
      if(m_axi_arvalid && m_axi_arready) begin rx_state<=RX_DATA;ar_count<=ar_count+1;end
      if(r_fire) begin
        r_count<=r_count+1;rx_beat<=rx_beat+1;burst_received<=burst_received+1;
        if(rx_response_bad) begin
          failed<=1;
          if({1'b0,slot_row[fill_slot]}<=failure_row) begin failure_status<=3;failure_row<={1'b0,slot_row[fill_slot]};done_bad_element<='1;end
        end
        if(burst_received+1==burst_beats) begin
          if(failed || rx_response_bad) begin rx_state<=RX_IDLE;slot_state[fill_slot]<=EMPTY;end
          else if(rx_beat+1==beats) begin
            rx_state<=RX_IDLE;slot_state[fill_slot]<=READY;complete_rows<=complete_rows+1;next_load<=next_load+1;
          end else begin : next_burst
            logic [63:0] address;
            logic [8:0] remaining,boundary;
            address=rx_addr+64'(burst_beats)*64;
            remaining=beats-rx_beat-1;boundary=9'((4096-address[11:0])>>6);
            rx_addr<=address;burst_received<=0;burst_beats<=7'(remaining<boundary ? remaining : boundary);rx_state<=RX_ADDR;
          end
        end
      end
      if(row_start_fire) begin
        q_active<=1;q_slot<=!(slot_state[0]==READY && slot_row[0]==next_quant);
        if(slot_state[0]==READY && slot_row[0]==next_quant)slot_state[0]<=READING;else slot_state[1]<=READING;
        tx_issued<=0;tx_accepted<=0;quant_starts<=quant_starts+1;
      end
      if(in_fire) begin
        in_valid<=0;tx_accepted<=tx_accepted+1;input_beats<=input_beats+1;
        if(tx_accepted+1==beats)slot_state[q_slot]<=EMPTY;
      end
      if(bank_read) begin bank_pending<=1;pending_beat<=tx_issued;tx_issued<=tx_issued+1;end
      if(bank_pending) begin
        bank_pending<=0;in_valid<=1;in_lanes<=bank_data[q_slot];in_group<=7'(pending_beat>>1);in_half<=pending_beat[0];
      end
      if(row_done_valid && row_done_ready) begin
        q_active<=0;slot_state[q_slot]<=EMPTY;bank_pending<=0;in_valid<=0;quant_rows<=quant_rows+1;
        if(row_done_status==0 && tx_accepted==beats && !bank_pending && !in_valid) next_quant<=next_quant+1;
        else begin
          failed<=1;
          if(next_quant<failure_row) begin
            failure_row<=next_quant;
            failure_status<=row_done_status==1 && row_done_bad_col<K ? 1 : 2;
            if(row_done_status==1 && row_done_bad_col<K) done_bad_element<=64'(next_quant)*4096+64'(row_done_bad_col);
          end
        end
      end
      if(active && debt_zero && ((failed) || next_quant==rows)) begin
        active<=0;done_valid<=1;done_status<=failed ? failure_status : 0;slot_state<='0;
      end
    end
  end
endmodule
