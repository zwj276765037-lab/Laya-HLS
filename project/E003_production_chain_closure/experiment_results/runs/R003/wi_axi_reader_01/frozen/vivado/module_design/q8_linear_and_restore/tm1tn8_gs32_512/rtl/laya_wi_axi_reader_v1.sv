`timescale 1ns/1ps
// Physical WI reader for one GEGLU window.  It converts aligned AXI512 beats
// into the canonical 2*K scalar stream and does not issue a later row until
// the row adapter has accepted the prior row's terminal status.
module laya_wi_axi_reader_v1(
  input logic clk,rst_n,cancel,
  input logic cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_producer_context,
  input logic [63:0] cfg_source_ref,
  input logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes,
  output logic wi_valid,
  input logic wi_ready,
  output logic [31:0] wi_data,wi_status,
  output logic [671:0] wi_numeric_identity,
  output logic [63:0] wi_source_ref,
  output logic [15:0] wi_row,
  output logic [12:0] wi_index,
  output logic wi_row_done_valid,
  input logic wi_row_done_ready,
  output logic [31:0] wi_row_done_status,
  output logic [63:0] wi_row_bad_element,
  output logic read_debt_zero,active,
  output logic [31:0] ar_count,r_count,complete_rows,
  output logic [63:0] m_axi_araddr,
  output logic [7:0] m_axi_arlen,
  output logic [2:0] m_axi_arsize,
  output logic [1:0] m_axi_arburst,
  output logic m_axi_arvalid,
  input logic m_axi_arready,
  input logic [511:0] m_axi_rdata,
  input logic [1:0] m_axi_rresp,
  input logic m_axi_rlast,m_axi_rvalid,
  output logic m_axi_rready
);
  localparam int WORDS_PER_ROW=5248,BEATS_PER_ROW=328;
  typedef enum logic [2:0] {IDLE,WAIT_ROW,ADDR,DATA,DRAIN,REPORT} state_t;
  state_t state;
  logic [671:0] numeric_identity;
  logic [95:0] producer_context;
  logic [63:0] source_ref,bo_base,bo_span,region_base,region_span,row_stride,batch_stride;
  logic [4:0] rows,row_local;
  logic [15:0] row0;
  logic [7:0] batch;
  logic [63:0] read_address;
  logic [8:0] beat_index;
  logic [8:0] burst_beats,burst_received;
  logic [13:0] word_count;
  logic [3:0] word_in_beat;
  logic beat_valid,beat_ends_burst,late_after_beat,synthetic;
  logic [511:0] beat_data;
  logic [31:0] beat_status;
  logic row_error;
  logic [63:0] row_bad;
  logic command_ok,word_fire,r_fire,expected_last,response_bad;

  always_comb begin : config_check
    logic [64:0] bo_end,region_end;
    logic [127:0] first_addr,last_end;
    logic [16:0] row_end;
    bo_end={1'b0,cfg_bo_base}+{1'b0,cfg_bo_span};
    region_end={1'b0,cfg_region_base}+{1'b0,cfg_region_span};
    first_addr=128'(cfg_region_base)+128'(cfg_producer_context[63:56])*128'(cfg_batch_stride_bytes)+
      128'(cfg_producer_context[87:72])*128'(cfg_row_stride_bytes);
    last_end=first_addr+128'(cfg_producer_context[95:88])*128'(cfg_row_stride_bytes);
    row_end={1'b0,cfg_producer_context[87:72]}+17'(cfg_producer_context[95:88]);
    command_ok=cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 &&
      cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 &&
      cfg_producer_context[31:0]!=0 && cfg_producer_context[39:32]==8'h60 &&
      cfg_producer_context[47:40]==2 && cfg_producer_context[71:64]==0 &&
      cfg_producer_context[63:56]<cfg_numeric_identity[143:128] &&
      cfg_producer_context[95:88]>=1 && cfg_producer_context[95:88]<=16 &&
      row_end<=cfg_numeric_identity[159:144] && cfg_source_ref[39:32]==6 &&
      cfg_source_ref[31:0]!=0 && cfg_row_stride_bytes==64'd20992 &&
      cfg_batch_stride_bytes==64'd21495808 && cfg_bo_span!=0 && cfg_region_span!=0 &&
      !bo_end[64] && !region_end[64] && cfg_region_base>=cfg_bo_base && region_end<=bo_end &&
      first_addr>=128'(cfg_region_base) && last_end<=128'(region_end) &&
      first_addr[127:64]==0 && last_end[127:64]==0 && first_addr[5:0]==0;
  end

  assign cfg_ready=rst_n && state==IDLE;
  assign active=state!=IDLE;
  assign m_axi_araddr=read_address;
  assign m_axi_arlen=8'(burst_beats-1);
  assign m_axi_arsize=3'd6;
  assign m_axi_arburst=2'd1;
  assign m_axi_arvalid=rst_n && state==ADDR && !cancel;
  assign m_axi_rready=rst_n && (state==DRAIN || (state==DATA && !beat_valid && !synthetic));
  assign r_fire=m_axi_rvalid && m_axi_rready;
  assign expected_last=burst_received+1==burst_beats;
  assign response_bad=m_axi_rresp!=0;
  assign wi_valid=beat_valid;
  assign wi_data=beat_data[word_in_beat*32+:32];
  assign wi_status=beat_status;
  assign wi_numeric_identity=numeric_identity;
  assign wi_source_ref=source_ref;
  assign wi_row=row0+16'(row_local);
  assign wi_index=word_count[12:0];
  assign word_fire=wi_valid && wi_ready;
  assign wi_row_done_valid=state==REPORT;
  assign wi_row_done_status=row_error || cancel ? 32'd3 : 32'd0;
  assign wi_row_bad_element=row_error ? row_bad : cancel ? 64'hffffffffffffffff : 64'd0;
  assign read_debt_zero=state!=ADDR && state!=DATA && state!=DRAIN && !beat_valid;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=IDLE;numeric_identity<=0;producer_context<=0;source_ref<=0;
      bo_base<=0;bo_span<=0;region_base<=0;region_span<=0;row_stride<=0;batch_stride<=0;
      rows<=0;row_local<=0;row0<=0;batch<=0;read_address<=0;beat_index<=0;
      burst_beats<=0;burst_received<=0;word_count<=0;word_in_beat<=0;
      beat_valid<=0;beat_ends_burst<=0;late_after_beat<=0;synthetic<=0;
      beat_data<=0;beat_status<=0;row_error<=0;row_bad<='1;cfg_reject<=0;
      ar_count<=0;r_count<=0;complete_rows<=0;
    end else begin
      cfg_reject<=0;
      if(cfg_valid && cfg_ready)begin
        if(!command_ok)cfg_reject<=1;
        else begin
          numeric_identity<=cfg_numeric_identity;producer_context<=cfg_producer_context;
          source_ref<=cfg_source_ref;bo_base<=cfg_bo_base;bo_span<=cfg_bo_span;
          region_base<=cfg_region_base;region_span<=cfg_region_span;
          row_stride<=cfg_row_stride_bytes;batch_stride<=cfg_batch_stride_bytes;
          rows<=5'(cfg_producer_context[95:88]);row_local<=0;
          row0<=cfg_producer_context[87:72];batch<=cfg_producer_context[63:56];
          ar_count<=0;r_count<=0;complete_rows<=0;state<=WAIT_ROW;
        end
      end
      if(state==WAIT_ROW && wi_ready && !cancel)begin : start_row
        logic [127:0] address;
        logic [8:0] boundary;
        address=128'(region_base)+128'(batch)*128'(batch_stride)+
          128'(row0+16'(row_local))*128'(row_stride);
        boundary=9'((4096-address[11:0])>>6);
        read_address<=address[63:0];beat_index<=0;burst_received<=0;
        burst_beats<=boundary<BEATS_PER_ROW ? boundary : 9'd256;
        word_count<=0;word_in_beat<=0;beat_valid<=0;synthetic<=0;
        row_error<=0;row_bad<='1;state<=ADDR;
      end
      if(m_axi_arvalid && m_axi_arready)begin
        ar_count<=ar_count+1;burst_received<=0;state<=DATA;
      end
      if(r_fire && state==DATA)begin
        r_count<=r_count+1;beat_valid<=1;beat_data<=m_axi_rdata;word_in_beat<=0;
        beat_status<=row_error || response_bad || (m_axi_rlast!=expected_last) ? 32'd3 : 32'd0;
        beat_ends_burst<=m_axi_rlast;
        late_after_beat<=expected_last && !m_axi_rlast;
        burst_received<=burst_received+1;beat_index<=beat_index+1;
        if(response_bad || m_axi_rlast!=expected_last)begin
          if(!row_error)row_bad<=64'(word_count);
          row_error<=1;
        end
      end
      if(word_fire)begin
        word_count<=word_count+1;
        if(word_in_beat==15)begin
          beat_valid<=0;word_in_beat<=0;
          if(word_count+1==WORDS_PER_ROW)state<=REPORT;
          else if(late_after_beat)state<=DRAIN;
          else if(beat_ends_burst)begin
            if(row_error || beat_status!=0)begin synthetic<=1;state<=DATA;end
            else begin : next_burst
              logic [63:0] address;
              logic [8:0] remaining,boundary,next_count;
              address=read_address+64'(burst_beats)*64;
              remaining=BEATS_PER_ROW-beat_index;
              boundary=9'((4096-address[11:0])>>6);
              next_count=remaining<boundary ? remaining : boundary;
              if(next_count>256)next_count=256;
              read_address<=address;burst_beats<=next_count;burst_received<=0;state<=ADDR;
            end
          end
        end else word_in_beat<=word_in_beat+1;
      end
      if(state==DATA && synthetic && !beat_valid && word_count<WORDS_PER_ROW)begin
        beat_valid<=1;beat_data<=0;beat_status<=32'd3;word_in_beat<=0;
        beat_ends_burst<=word_count+16>=WORDS_PER_ROW;late_after_beat<=0;
      end
      if(state==DRAIN && r_fire)begin
        r_count<=r_count+1;
        if(m_axi_rlast)begin synthetic<=1;state<=DATA;end
      end
      if(cancel && state!=IDLE && read_debt_zero)state<=REPORT;
      if(wi_row_done_valid && wi_row_done_ready)begin
        complete_rows<=complete_rows+1;
        if(row_local+1==rows || row_error || cancel)state<=IDLE;
        else begin row_local<=row_local+1;state<=WAIT_ROW;end
      end
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    if(m_axi_arvalid)assert(!row_error && !synthetic)
      else $fatal(1,"WI reader issued new AR after physical source error");
    if(wi_row_done_valid)assert(read_debt_zero)
      else $fatal(1,"WI reader reported a row before AXI drain");
  end
`endif
endmodule
