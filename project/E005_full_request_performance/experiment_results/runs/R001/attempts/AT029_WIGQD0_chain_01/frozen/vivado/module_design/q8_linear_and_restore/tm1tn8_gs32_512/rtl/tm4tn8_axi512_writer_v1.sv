`timescale 1ns/1ps

// KB1 candidate relative to resident_regression_02 frozen writer.
// One admitted command and held TN8 packet; four row-indexed pack beats share
// the original single immutable AXI transaction. All packet/address/identity
// checks and final-B completion remain. No arithmetic or testbench delay change.
// The module name is intentionally unchanged for a frozen source override;
// never compile this alternative beside tm4tn8_axi512_writer_v1.sv.
// cfg_owner_admitted/target_invalidated come from the production ledger;
// this endpoint cannot claim, invalidate, or publish an owner by itself.
module tm4tn8_axi512_writer_v1 #(parameter bit SHARD=0) (
  input logic clk,rst_n,
  input logic cfg_valid,
  output logic cfg_ready,
  input logic cfg_owner_admitted,cfg_target_invalidated,
  input logic [15:0] cfg_K,cfg_N,cfg_row0,
  input logic [2:0] cfg_rows,
  input logic [7:0] cfg_batch,cfg_op,cfg_G_count,
  input logic [9:0] cfg_T_count,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_linear_context,
  input logic [63:0] cfg_source_ref,cfg_a_ref,cfg_w_ref,cfg_ps_ref,cfg_dst_ref,
  input logic [3327:0] cfg_w_model_identity,
  input logic [1:0][63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes,
  input logic packet_valid,
  output logic packet_ready,
  input logic [415:0] packet_data,
  input logic flush_valid,
  output logic flush_ready,flush_done,debt_zero,coverage_complete,
  input logic command_retire,
  output logic fault,
  output logic [15:0] status,
  output logic [63:0] first_error_rank,first_bad_element,
  output logic [31:0] aw_count,w_count,b_count,accepted_elements,
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
  logic configured,qkv,flushing,flush_reported;
  logic [15:0] K,N,row0,S,B;
  logic [2:0] rows;
  logic [7:0] batch,op;
  logic [9:0] T,expected_tile;
  logic [1:0] expected_row;
  logic [63:0] bo_base,bo_span,region_base,region_span,row_stride,batch_stride;
  logic [127:0] owner_tag;
  (* keep = "true" *) logic [671:0] numeric_identity;
  (* keep = "true" *) logic [95:0] linear_context;
  (* keep = "true" *) logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref;
  (* keep = "true" *) logic [3327:0] w_model_identity;
  logic held_valid,tx_valid,tx_aw_sent,tx_w_sent;
  logic [3:0] pack_valid;
  logic [415:0] held_packet;
  logic [7:0] held_pending;
  logic [63:0] pack_addr[0:3],pack_strb[0:3],tx_addr,tx_strb;
  logic [511:0] pack_data[0:3],tx_data;
  logic [63:0] lane_addr[0:7],next_beat;
  logic [7:0] beat_mask,pending_after_merge,expected_mask;
  logic config_ok,packet_ok,bad_held,b_fire,b_error,transfer_pack,merge_tile;
  logic [3:0] seal_pack;
  logic pack_select_valid;
  logic [1:0] pack_select,held_row;
  logic [31:0] expected_elements;

  function automatic logic shape_ok(input logic [15:0] k,input logic [15:0] n);
    return (k==1024 && (n==3072 || n==1024 || n==5248 || n==4096)) ||
      ((k==2624 || k==4096) && n==1024) || (k==256 && n==2);
  endfunction
  function automatic logic [9:0] next_tile(input logic [9:0] tile,input logic is_qkv);
    logic [10:0] candidate;
    candidate={1'b0,tile}+1;
    if(is_qkv && candidate[3]!=SHARD) candidate=candidate+8;
    return candidate[9:0];
  endfunction
  always_comb begin : config_validation
    logic layout_ok;
    logic [16:0] endrow;
    logic [63:0] stride,limit;
    logic [64:0] bo_end,region_end;
    layout_ok=0;stride=0;limit=0;
    case(cfg_op)
      8'h30: begin layout_ok=cfg_K==1024 && cfg_N==3072 && cfg_dst_ref[39:32]==5 && cfg_linear_context[71:64]==0;limit=cfg_numeric_identity[159:144];end
      8'h31,8'h33,8'h35: begin layout_ok=cfg_N==1024 && cfg_K==(cfg_op==8'h31 ? 1024 : cfg_op==8'h33 ? 2624 : 4096) && cfg_dst_ref[39:32]==3 && cfg_linear_context[71:64]==0;stride=4096;limit=cfg_numeric_identity[159:144];end
      8'h32: begin layout_ok=cfg_K==1024 && cfg_N==5248 && cfg_dst_ref[39:32]==6 && cfg_linear_context[71:64]==0;stride=20992;limit=cfg_numeric_identity[159:144];end
      8'h34: begin layout_ok=cfg_K==1024 && cfg_N==4096 && cfg_dst_ref[39:32]==9 && cfg_linear_context[71:64]==0;stride=16384;limit=cfg_numeric_identity[159:144];end
      8'h36: begin layout_ok=cfg_K==1024 && cfg_N==1024 && cfg_dst_ref[39:32]==10 && cfg_dst_ref[55:48]==0 && cfg_linear_context[71:64]==1;stride=4096;limit=16;end
      8'h37: begin layout_ok=cfg_K==256 && cfg_N==2 && cfg_dst_ref[39:32]==10 && cfg_dst_ref[55:48]==4 && cfg_linear_context[71:64]==2 && cfg_rows==1;stride=8;limit=1;end
      default: layout_ok=0;
    endcase
    endrow={1'b0,cfg_row0}+17'(cfg_rows);
    bo_end={1'b0,cfg_bo_base[SHARD]}+{1'b0,cfg_bo_span[SHARD]};
    region_end={1'b0,cfg_region_base[SHARD]}+{1'b0,cfg_region_span[SHARD]};
    config_ok=cfg_owner_admitted && shape_ok(cfg_K,cfg_N) && layout_ok &&
      (cfg_rows==1 || cfg_rows==4) && endrow<=limit &&
      cfg_batch<cfg_numeric_identity[143:128] && cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]<=1024 && cfg_numeric_identity[159:144]>=64 &&
      cfg_G_count==cfg_K/32 && cfg_T_count==(cfg_N+7)/8 &&
      cfg_linear_context[31:0]!=0 && cfg_linear_context[39:32]==cfg_op &&
      cfg_linear_context[63:56]==cfg_batch && cfg_linear_context[87:72]==cfg_row0 && cfg_linear_context[95:88]==cfg_rows &&
      cfg_a_ref[39:32]==8'h22 && cfg_w_ref[39:32]==8'h23 && cfg_ps_ref[39:32]==8'h24 &&
      cfg_source_ref[63:56]==0 && cfg_a_ref[63:56]==0 && cfg_w_ref[63:56]==0 && cfg_ps_ref[63:56]==0 && cfg_dst_ref[63:56]==0 &&
      cfg_bo_span[SHARD]>=64 && cfg_bo_base[SHARD][5:0]==0 && !bo_end[64] && !region_end[64] &&
      cfg_region_base[SHARD][1:0]==0 && cfg_region_base[SHARD]>=cfg_bo_base[SHARD] && region_end<=bo_end &&
      (cfg_op==8'h30 || (SHARD==0 && cfg_row_stride_bytes==stride &&
         cfg_batch_stride_bytes==(cfg_op==8'h36 ? 16*stride : cfg_op==8'h37 ? stride : 1024*stride)));
  end
  assign cfg_ready=!configured && debt_zero;
  assign expected_elements=32'(rows)*32'(N)/(qkv ? 2 : 1);
  assign coverage_complete=configured && accepted_elements==expected_elements;
  assign expected_mask=expected_tile==T-1 && N[2:0]!=0 ? 8'((1<<N[2:0])-1) : 8'hff;
  assign packet_ok=packet_data[415:288]==owner_tag && packet_data[287:280]==0 &&
    packet_data[268:256]=={expected_tile,3'b000} && expected_tile<T &&
    packet_data[270:269]==expected_row && expected_row<rows &&
    packet_data[278:271]==expected_mask &&
    packet_data[279]==(expected_tile==T-1 && expected_row==rows-1) &&
    (!qkv || packet_data[262]==SHARD);
  always_comb begin : address_decode
    logic [13:0] col;
    logic [16:0] global_row;
    logic [63:0] relative_byte,beat;
    logic [127:0] wide_relative;
    logic [64:0] sum,bo_end,region_end;
    logic found;
    bad_held=0;next_beat=0;beat_mask=0;found=0;
    global_row={1'b0,row0}+17'(held_packet[270:269]);
    bo_end={1'b0,bo_base}+{1'b0,bo_span};region_end={1'b0,region_base}+{1'b0,region_span};
    for(int lane=0;lane<8;lane++) begin
      col={1'b0,held_packet[268:256]}+14'(lane);
      if(qkv) begin
        wide_relative=128'(col/1024)*2+128'(batch);
        wide_relative=wide_relative*8+128'((col%1024)/128);
        wide_relative=wide_relative*1024+128'(global_row);
        wide_relative=(wide_relative*64+128'(col%64))*4;
      end
      else wide_relative=128'(batch)*128'(batch_stride)+128'(global_row)*128'(row_stride)+128'(col)*4;
      relative_byte=wide_relative[63:0];sum={1'b0,region_base}+{1'b0,relative_byte};
      lane_addr[lane]=sum[63:0];beat={sum[63:6],6'b0};
      if(held_valid && held_packet[271+lane]) begin
        if(wide_relative[127:64]!=0 || sum[64] || col>=N || global_row>=1024 ||
          {1'b0,sum[63:0]}<{1'b0,region_base} || {1'b0,sum[63:0]}+65'd4>region_end ||
          {1'b0,beat}<{1'b0,bo_base} || {1'b0,beat}+65'd64>bo_end ||
          (qkv && ((col%1024)/64)%2!=SHARD)) bad_held=1;
      end
      if(held_valid && held_pending[lane] && !found) begin next_beat=beat;found=1;end
    end
    for(int lane=0;lane<8;lane++)
      if(held_valid && held_pending[lane] && {lane_addr[lane][63:6],6'b0}==next_beat) beat_mask[lane]=1;
  end
  assign b_fire=tx_valid && tx_aw_sent && tx_w_sent && m_axi_bvalid;
  assign b_error=b_fire && m_axi_bresp!=0;
  assign held_row=held_packet[270:269];
  always_comb begin : choose_sealed_row
    seal_pack='0;pack_select_valid=0;pack_select=0;
    for(int row=0;row<4;row++) begin
      seal_pack[row]=pack_valid[row] && (pack_strb[row]=='1 ||
        (held_valid && held_pending!=0 && held_row==2'(row) && pack_addr[row]!=next_beat) ||
        (flushing && !held_valid));
      if(seal_pack[row] && !pack_select_valid) begin
        pack_select_valid=1;pack_select=2'(row);
      end
    end
  end
  assign transfer_pack=pack_select_valid && (!tx_valid || b_fire) && !b_error && !fault && !bad_held;
  assign merge_tile=held_valid && held_pending!=0 && !bad_held && !fault && !b_error &&
    (!pack_valid[held_row] || pack_addr[held_row]==next_beat ||
      (transfer_pack && pack_select==held_row)) &&
    (!seal_pack[held_row] || (transfer_pack && pack_select==held_row));
  assign pending_after_merge=held_pending & ~beat_mask;
  assign packet_ready=configured && !fault && !flushing && !flush_valid &&
    (!held_valid || (merge_tile && pending_after_merge==0));
  assign flush_ready=configured && !flushing;
  assign debt_zero=!held_valid && pack_valid=='0 && !tx_valid;
  assign first_error_rank='1;assign first_bad_element='1;
  assign m_axi_awaddr=tx_addr;assign m_axi_awlen=0;assign m_axi_awsize=6;assign m_axi_awburst=1;
  assign m_axi_awvalid=tx_valid && !tx_aw_sent;
  assign m_axi_wdata=tx_data;assign m_axi_wstrb=tx_strb;assign m_axi_wlast=1;
  assign m_axi_wvalid=tx_valid && !tx_w_sent;assign m_axi_bready=tx_valid && tx_aw_sent && tx_w_sent;
  always_ff @(posedge clk) begin : registers
    logic h,t;
    logic [3:0] p;
    logic [7:0] pending;
    logic [63:0] pa[0:3],ps[0:3];
    logic [511:0] pd[0:3];
    logic [31:0] added;
    if(!rst_n) begin
      configured<=0;qkv<=0;flushing<=0;flush_reported<=0;flush_done<=0;fault<=0;status<=0;
      K<=0;N<=0;rows<=0;row0<=0;S<=0;B<=0;batch<=0;op<=0;T<=0;expected_tile<=0;expected_row<=0;
      bo_base<=0;bo_span<=0;region_base<=0;region_span<=0;row_stride<=0;batch_stride<=0;
      numeric_identity<=0;linear_context<=0;source_ref<=0;a_ref<=0;w_ref<=0;ps_ref<=0;dst_ref<=0;w_model_identity<=0;owner_tag<=0;
      held_valid<=0;held_packet<=0;held_pending<=0;pack_valid<=0;
      for(int row=0;row<4;row++) begin pack_addr[row]<=0;pack_strb[row]<=0;pack_data[row]<=0;end
      tx_valid<=0;tx_addr<=0;tx_strb<=0;tx_data<=0;tx_aw_sent<=0;tx_w_sent<=0;
      aw_count<=0;w_count<=0;b_count<=0;accepted_elements<=0;useful_bytes<=0;physical_bytes<=0;
    end else begin
      h=held_valid;p=pack_valid;t=tx_valid;pending=held_pending;added=0;flush_done<=0;
      for(int row=0;row<4;row++) begin pa[row]=pack_addr[row];ps[row]=pack_strb[row];pd[row]=pack_data[row];end
      if(cfg_valid && cfg_ready) begin
        fault<=!config_ok;status<=config_ok ? 0 : 7;
        if(config_ok) begin
          configured<=1;K<=cfg_K;N<=cfg_N;rows<=cfg_rows;row0<=cfg_row0;batch<=cfg_batch;op<=cfg_op;
          S<=cfg_numeric_identity[159:144];B<=cfg_numeric_identity[143:128];qkv<=cfg_op==8'h30;T<=cfg_T_count;
          expected_tile<=cfg_op==8'h30 && SHARD ? 8 : 0;expected_row<=0;
          bo_base<=cfg_bo_base[SHARD];bo_span<=cfg_bo_span[SHARD];region_base<=cfg_region_base[SHARD];region_span<=cfg_region_span[SHARD];
          row_stride<=cfg_row_stride_bytes;batch_stride<=cfg_batch_stride_bytes;
          numeric_identity<=cfg_numeric_identity;linear_context<=cfg_linear_context;source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;w_ref<=cfg_w_ref;ps_ref<=cfg_ps_ref;dst_ref<=cfg_dst_ref;w_model_identity<=cfg_w_model_identity;
          owner_tag<={cfg_dst_ref[31:0],cfg_w_ref[31:0],cfg_a_ref[31:0],cfg_linear_context[31:0]};
          flushing<=0;flush_reported<=0;accepted_elements<=0;aw_count<=0;w_count<=0;b_count<=0;useful_bytes<=0;physical_bytes<=0;
        end
      end
      if(flush_valid && flush_ready) flushing<=1;
      if(m_axi_awvalid && m_axi_awready) begin tx_aw_sent<=1;aw_count<=aw_count+1;end
      if(m_axi_wvalid && m_axi_wready) begin tx_w_sent<=1;w_count<=w_count+1;physical_bytes<=physical_bytes+64;end
      if(b_fire) begin t=0;tx_aw_sent<=0;tx_w_sent<=0;b_count<=b_count+1;end
      if(transfer_pack) begin
        tx_addr<=pack_addr[pack_select];tx_strb<=pack_strb[pack_select];tx_data<=pack_data[pack_select];
        t=1;tx_aw_sent<=0;tx_w_sent<=0;p[pack_select]=0;ps[pack_select]=0;pd[pack_select]=0;
      end
      if(merge_tile) begin
        if(!p[held_row]) begin p[held_row]=1;pa[held_row]=next_beat;ps[held_row]=0;pd[held_row]=0;end
        for(int lane=0;lane<8;lane++) if(beat_mask[lane]) begin
          pd[held_row][lane_addr[lane][5:2]*32 +:32]=held_packet[lane*32 +:32];
          ps[held_row][lane_addr[lane][5:2]*4 +:4]=4'hf;added=added+4;
        end
        pending=pending_after_merge;if(pending==0) h=0;
      end
      if(added!=0) useful_bytes<=useful_bytes+added;
      if(packet_valid && packet_ready && packet_ok && !bad_held && !b_error) begin
        held_packet<=packet_data;pending=packet_data[278:271];h=1;
        accepted_elements<=accepted_elements+32'($countones(packet_data[278:271]));
        if(expected_row==rows-1) begin expected_row<=0;expected_tile<=next_tile(expected_tile,qkv);end
        else expected_row<=expected_row+1;
        if(packet_data[279]) flushing<=1;
      end
      if(bad_held || b_error || (packet_valid && packet_ready && !packet_ok)) begin
        fault<=1;if(!fault) status<=b_error ? 5 : 7;
        h=0;pending=0;p=0;
        for(int row=0;row<4;row++) begin ps[row]=0;pd[row]=0;end
      end
      if(m_axi_bvalid && !tx_valid) begin fault<=1;if(!fault) status<=7;end
      held_valid<=h;held_pending<=pending;pack_valid<=p;tx_valid<=t;
      for(int row=0;row<4;row++) begin pack_addr[row]<=pa[row];pack_strb[row]<=ps[row];pack_data[row]<=pd[row];end
      if(flushing && !flush_reported && !h && p=='0 && !t) begin
        flush_done<=1;flush_reported<=1;
        if(!coverage_complete && !fault) begin fault<=1;status<=7;end
      end
      if(command_retire && debt_zero && ((!fault && flush_reported && coverage_complete) || (fault && cfg_target_invalidated))) begin
        configured<=0;fault<=0;status<=0;flushing<=0;flush_reported<=0;
      end
    end
  end
endmodule
