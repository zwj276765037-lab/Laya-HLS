`timescale 1ns/1ps

// The producer has already admitted the complete immutable owner command.
// This bounded adapter copies one tile's final PS returns and orders its rows.
// It neither claims nor publishes a buffer owner.
module tm4tn8_final_ps_adapter_v1 (
  input logic clk,rst_n,
  input logic cfg_valid,
  output logic cfg_ready,
  input logic cfg_owner_admitted,
  input logic [15:0] cfg_K,cfg_N,
  input logic [2:0] cfg_rows,
  input logic [7:0] cfg_G_count,
  input logic [9:0] cfg_T_count,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_linear_context,
  input logic [63:0] cfg_source_ref,cfg_a_ref,cfg_w_ref,cfg_ps_ref,cfg_dst_ref,
  input logic [3327:0] cfg_w_model_identity,
  input logic [3:0] final_valid,
  input logic [3:0] final_skip_valid,
  output logic [3:0] final_skip_ready,
  input logic [9:0] final_skip_tile,
  input logic [7:0] final_skip_mask,
  output logic [3:0] final_ready,
  input logic [767:0] final_tag,
  input logic [39:0] final_tile,
  input logic [31:0] final_mask,final_bad,
  input logic [1023:0] final_ps,
  output logic out_valid,
  input logic out_ready,
  output logic [415:0] out_data,
  input logic command_retire,
  output logic debt_zero,coverage_complete,protocol_error,
  output logic [31:0] copied_packets,retired_packets
);
  logic configured;
  logic [15:0] N;
  logic [2:0] rows;
  logic [7:0] G;
  logic [9:0] T,tile;
  logic [1:0] next_row;
  logic [3:0] stored;
  logic [415:0] packet[0:3];
  // Retain every identity bit until all copies have retired.
  (* keep = "true" *) logic [671:0] numeric_identity;
  (* keep = "true" *) logic [95:0] linear_context;
  (* keep = "true" *) logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref;
  (* keep = "true" *) logic [3327:0] w_model_identity;
  logic [127:0] owner_tag;
  logic config_ok;
  logic [7:0] expected_mask;
  logic [3:0] return_ok;
  logic [26:0] expected_sequence;
  function automatic logic shape_ok(input logic [15:0] K,input logic [15:0] n);
    return (K==1024 && (n==3072 || n==1024 || n==5248 || n==4096)) ||
           ((K==2624 || K==4096) && n==1024) || (K==256 && n==2);
  endfunction
  assign debt_zero=stored==0;
  assign coverage_complete=configured && tile==T && debt_zero;
  assign cfg_ready=!configured && debt_zero;
  assign out_valid=configured && stored[next_row];
  assign out_data=packet[next_row];
  always_comb begin
    config_ok=cfg_owner_admitted && shape_ok(cfg_K,cfg_N) &&
      (cfg_rows==1 || cfg_rows==4) && cfg_G_count==cfg_K/32 &&
      cfg_T_count==(cfg_N+7)/8 && cfg_linear_context[95:88]==cfg_rows &&
      cfg_linear_context[31:0]!=0 && cfg_a_ref[39:32]==8'h22 &&
      cfg_w_ref[39:32]==8'h23 && cfg_ps_ref[39:32]==8'h24 &&
      cfg_source_ref[63:56]==0 && cfg_a_ref[63:56]==0 && cfg_w_ref[63:56]==0 &&
      cfg_ps_ref[63:56]==0 && cfg_dst_ref[63:56]==0;
    expected_mask=(tile==T-1 && N[2:0]!=0) ? 8'((1<<N[2:0])-1) : 8'hff;
    expected_sequence=(32'(G)-1)*32'(T)+32'(tile);
    final_ready=0;return_ok=0;
    final_skip_ready=0;
    for(int row=0;row<4;row++) begin
      // Illegal handshakes are consumed for reporting without indexing RAM.
      final_ready[row]=configured && !protocol_error && tile<T && !stored[row] && row>=next_row;
      final_skip_ready[row]=final_ready[row] && final_skip_tile==tile && final_skip_mask==expected_mask;
      return_ok[row]=row<rows && final_tile[row*10 +:10]==tile &&
        final_mask[row*8 +:8]==expected_mask &&
        (final_bad[row*8 +:8] & ~expected_mask)==0 &&
        final_tag[row*192+159 -:96]=={linear_context[31:0],a_ref[31:0],w_ref[31:0]} &&
        final_tag[row*192+62 -:27]==expected_sequence &&
        {final_tag[row*192+160],final_tag[row*192+11 +:6]}==G-1 &&
        {final_tag[row*192+161],final_tag[row*192+17 +:9]}==tile &&
        final_tag[row*192+26 +:2]==2'(row) &&
        final_tag[row*192+28 +:8]==expected_mask &&
        final_tag[row*192+164 +:4]==4'd1 &&
        final_tag[row*192+168 +:24]==0 && final_tag[row*192+162 +:2]==0 &&
        final_tag[row*192+7]==0 && final_tag[row*192+8 +:3]==0 &&
        {final_tag[row*192+63],final_tag[row*192 +:5]}<35;
    end
  end
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      configured<=0;N<=0;rows<=0;G<=0;T<=0;tile<=0;next_row<=0;stored<=0;
      protocol_error<=0;copied_packets<=0;retired_packets<=0;owner_tag<=0;
      numeric_identity<=0;linear_context<=0;source_ref<=0;a_ref<=0;w_ref<=0;ps_ref<=0;dst_ref<=0;w_model_identity<=0;
    end else begin
      if(cfg_valid && cfg_ready) begin
        protocol_error<=!config_ok;
        if(config_ok) begin
          configured<=1;N<=cfg_N;rows<=cfg_rows;G<=cfg_G_count;T<=cfg_T_count;
          tile<=0;next_row<=0;stored<=0;copied_packets<=0;retired_packets<=0;
          numeric_identity<=cfg_numeric_identity;linear_context<=cfg_linear_context;
          source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;w_ref<=cfg_w_ref;ps_ref<=cfg_ps_ref;dst_ref<=cfg_dst_ref;w_model_identity<=cfg_w_model_identity;
          owner_tag<={cfg_dst_ref[31:0],cfg_w_ref[31:0],cfg_a_ref[31:0],cfg_linear_context[31:0]};
        end
      end
      for(int row=0;row<4;row++) begin
        // An all-poison final group has no FP return or PS write. It still
        // advances the checked row/tile sequence with an explicitly poisoned
        // packet; this does not count as a physical PS copy.
        if(final_skip_valid[row] && final_skip_ready[row])begin
          stored[row]<=1;packet[row]<=0;
          packet[row][415:288]<=owner_tag;packet[row][265:256]<=tile;
          packet[row][267:266]<=2'(row);packet[row][275:268]<=expected_mask;
          packet[row][283:276]<=expected_mask;
          packet[row][284]<=tile==T-1 && row==rows-1;
        end
        if(final_valid[row] && final_ready[row]) begin
          if(!return_ok[row]) protocol_error<=1;
          else begin
            stored[row]<=1;packet[row]<=0;
            packet[row][415:288]<=owner_tag;packet[row][255:0]<=final_ps[row*256 +:256];
            packet[row][265:256]<=tile;packet[row][267:266]<=2'(row);
            packet[row][275:268]<=expected_mask;packet[row][283:276]<=final_bad[row*8 +:8];
            packet[row][284]<=tile==T-1 && row==rows-1;
          end
        end
      end
      // Count simultaneous independent row copies without last-NBA loss.
      if(|(final_valid & final_ready & return_ok))
        copied_packets<=copied_packets+32'($countones(final_valid & final_ready & return_ok));
      if(out_valid && out_ready) begin
        stored[next_row]<=0;retired_packets<=retired_packets+1;
        if(next_row==rows-1) begin next_row<=0;tile<=tile+1;end
        else next_row<=next_row+1;
      end
      // An already offered packet remains immutable under backpressure.
      // Unoffered local copies may be discarded after protocol failure;
      // their real producer credits were returned only after this copy.
      if(protocol_error && (!out_valid || out_ready)) stored<=0;
      if(command_retire && debt_zero) begin configured<=0;protocol_error<=0;end
    end
  end
endmodule
