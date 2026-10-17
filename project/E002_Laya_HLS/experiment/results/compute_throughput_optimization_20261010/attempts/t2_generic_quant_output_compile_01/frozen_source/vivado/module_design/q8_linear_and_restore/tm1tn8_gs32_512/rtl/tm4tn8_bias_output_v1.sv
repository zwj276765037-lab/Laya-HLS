`timescale 1ns/1ps

module tm4tn8_bias_output_v1 (
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
  input logic bias_valid,
  output logic bias_ready,bias_loaded,
  input logic [415:0] bias_data,
  input logic ps_valid,
  output logic ps_ready,
  input logic [415:0] ps_data,
  output logic out_valid,
  input logic out_ready,
  output logic [415:0] out_data,
  input logic command_retire,
  output logic debt_zero,coverage_complete,protocol_error,numerical_error,
  output logic [63:0] first_error_rank,first_bad_element,
  output logic [31:0] first_error_detail,committed_elements,
  output logic [31:0] native_lane_issues,native_lane_returns,helper_lane_issues
);
  import tm4tn8_bias_bits_v1::*;
  typedef enum logic [1:0] {IDLE,READ,LAUNCH,WAIT} state_t;
  state_t state;
  logic configured,pending,held_kind;
  logic [3:0] quarantine;
  logic [15:0] N;
  logic [2:0] rows;
  logic [7:0] G;
  logic [9:0] T,bias_count,expected_tile,held_tile;
  logic [1:0] expected_row,held_row;
  logic [127:0] owner_tag;
  (* keep = "true" *) logic [671:0] numeric_identity;
  (* keep = "true" *) logic [95:0] linear_context;
  (* keep = "true" *) logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref;
  (* keep = "true" *) logic [3327:0] w_model_identity;
  logic kind[0:655];
  logic [255:0] bank_bias,held_ps,returned,helper_result,merged;
  logic [415:0] packet;
  logic [7:0] held_mask,held_bad,active,seen,add_valid,route,merged_bad;
  logic [255:0] add_result;
  logic config_ok,bias_ok,ps_ok,bias_accept,ps_accept,add_launch,finished;
  logic [7:0] bias_mask,ps_mask;
  function automatic logic shape_ok(input logic [15:0] K,input logic [15:0] n);
    return (K==1024 && (n==3072 || n==1024 || n==5248 || n==4096)) ||
      ((K==2624 || K==4096) && n==1024) || (K==256 && n==2);
  endfunction
  function automatic logic [7:0] mask_for(input logic [9:0] tile);
    return tile==T-1 && N[2:0]!=0 ? 8'((1<<N[2:0])-1) : 8'hff;
  endfunction
  assign debt_zero=state==IDLE && !pending;
  assign cfg_ready=!configured && debt_zero && quarantine==0;
  assign bias_loaded=configured && bias_count==T && !protocol_error;
  assign bias_ready=configured && bias_count<T && !protocol_error;
  assign ps_ready=bias_loaded && state==IDLE && (!pending || out_ready) && !protocol_error && !numerical_error;
  assign out_valid=pending;assign out_data=packet;
  assign coverage_complete=configured && committed_elements==32'(N)*32'(rows) && debt_zero && !protocol_error && !numerical_error;
  assign bias_accept=bias_valid && bias_ready && bias_ok;
  assign ps_accept=ps_valid && ps_ready && ps_ok;
  assign add_launch=state==LAUNCH && held_kind && quarantine==0;
  always_comb begin
    config_ok=cfg_owner_admitted && shape_ok(cfg_K,cfg_N) && (cfg_rows==1 || cfg_rows==4) &&
      cfg_G_count==cfg_K/32 && cfg_T_count==(cfg_N+7)/8 && cfg_linear_context[95:88]==cfg_rows &&
      cfg_linear_context[31:0]!=0 && cfg_a_ref[39:32]==8'h22 && cfg_w_ref[39:32]==8'h23 && cfg_ps_ref[39:32]==8'h24 &&
      cfg_source_ref[63:56]==0 && cfg_a_ref[63:56]==0 && cfg_w_ref[63:56]==0 && cfg_ps_ref[63:56]==0 && cfg_dst_ref[63:56]==0;
    bias_mask=mask_for(bias_count);ps_mask=mask_for(expected_tile);
    bias_ok=bias_count<T && bias_data[415:288]==owner_tag && bias_data[287:276]==0 &&
      bias_data[265:256]==bias_count && bias_data[273:266]==bias_mask && bias_data[275]==(bias_count==T-1);
    ps_ok=expected_tile<T && ps_data[415:288]==owner_tag && ps_data[287:285]==0 &&
      ps_data[265:256]==expected_tile && ps_data[267:266]==expected_row && ps_data[275:268]==ps_mask &&
      (ps_data[283:276] & ~ps_mask)==0 && ps_data[284]==(expected_tile==T-1 && expected_row==rows-1);
    for(int lane=0;lane<8;lane++) begin
      if(!bias_mask[lane] || !bias_data[274]) begin if(bias_data[lane*32 +:32]!=0) bias_ok=0;end
      else if(!finite(bias_data[lane*32 +:32])) bias_ok=0;
      if(ps_mask[lane] && !ps_data[276+lane] && !finite(ps_data[lane*32 +:32])) ps_ok=0;
    end
    merged=returned;merged_bad=held_bad;
    for(int lane=0;lane<8;lane++) begin
      if(add_valid[lane] && active[lane]) merged[lane*32 +:32]=route[lane] ? helper_result[lane*32 +:32] : add_result[lane*32 +:32];
      if(active[lane] && !finite(merged[lane*32 +:32])) merged_bad[lane]=1;
    end
    finished=state==WAIT && ((seen | add_valid) & active)==active;
  end
  for(genvar lane=0;lane<8;lane++) begin : lanes
    logic use_helper;
    assign use_helper=helper_route(held_ps[lane*32 +:32],bank_bias[lane*32 +:32]);
    tm4tn8_bias_bank_v1 bank(.clk,.we(rst_n && bias_accept),.waddr(bias_count),.wdata(bias_data[lane*32 +:32]),.re(rst_n && ps_accept),.raddr(expected_tile),.rdata(bank_bias[lane*32 +:32]));
    tm1tn8_fadd_ip fp(
      .aclk(clk),.aclken(1'b1),
      .s_axis_a_tvalid(add_launch && active[lane]),.s_axis_a_tdata(use_helper ? 32'd0 : held_ps[lane*32 +:32]),
      .s_axis_b_tvalid(add_launch && active[lane]),.s_axis_b_tdata(use_helper ? 32'd0 : bank_bias[lane*32 +:32]),
      .m_axis_result_tvalid(add_valid[lane]),.m_axis_result_tdata(add_result[lane*32 +:32]));
  end
  always_ff @(posedge clk) begin : controller
    logic [63:0] rank,bad_element,best;
    logic [2:0] best_lane;
    if(!rst_n) begin
      configured<=0;state<=IDLE;quarantine<=12;pending<=0;held_kind<=0;
      N<=0;rows<=0;G<=0;T<=0;bias_count<=0;expected_tile<=0;expected_row<=0;held_tile<=0;held_row<=0;
      owner_tag<=0;numeric_identity<=0;linear_context<=0;source_ref<=0;a_ref<=0;w_ref<=0;ps_ref<=0;dst_ref<=0;w_model_identity<=0;
      held_ps<=0;held_mask<=0;held_bad<=0;active<=0;seen<=0;returned<=0;route<=0;helper_result<=0;packet<=0;
      protocol_error<=0;numerical_error<=0;first_error_rank<='1;first_bad_element<='1;first_error_detail<=0;committed_elements<=0;
      native_lane_issues<=0;native_lane_returns<=0;helper_lane_issues<=0;
    end else begin
      if(quarantine!=0) quarantine<=quarantine-1;
      if(cfg_valid && cfg_ready) begin
        protocol_error<=!config_ok;
        if(config_ok) begin
          configured<=1;N<=cfg_N;rows<=cfg_rows;G<=cfg_G_count;T<=cfg_T_count;bias_count<=0;expected_tile<=0;expected_row<=0;
          owner_tag<={cfg_dst_ref[31:0],cfg_w_ref[31:0],cfg_a_ref[31:0],cfg_linear_context[31:0]};
          numeric_identity<=cfg_numeric_identity;linear_context<=cfg_linear_context;source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;w_ref<=cfg_w_ref;ps_ref<=cfg_ps_ref;dst_ref<=cfg_dst_ref;w_model_identity<=cfg_w_model_identity;
          numerical_error<=0;first_error_rank<='1;first_bad_element<='1;first_error_detail<=0;committed_elements<=0;
          native_lane_issues<=0;native_lane_returns<=0;helper_lane_issues<=0;
        end
      end
      if(bias_valid && bias_ready) begin
        if(!bias_ok) protocol_error<=1;
        else begin kind[bias_count]<=bias_data[274];bias_count<=bias_count+1;end
      end
      if(ps_valid && ps_ready) begin
        if(!ps_ok) protocol_error<=1;
        else begin
          held_tile<=expected_tile;held_row<=expected_row;held_ps<=ps_data[255:0];returned<=ps_data[255:0];
          held_mask<=ps_mask;held_bad<=ps_data[283:276];active<=ps_mask & ~ps_data[283:276];held_kind<=kind[expected_tile];seen<=0;state<=READ;
          if(expected_row==rows-1) begin expected_row<=0;expected_tile<=expected_tile+1;end
          else expected_row<=expected_row+1;
        end
      end
      if(state==READ) state<=LAUNCH;
      if(state==LAUNCH) begin
        state<=WAIT;
        if(held_kind) begin
          native_lane_issues<=native_lane_issues+32'($countones(active));
          for(int lane=0;lane<8;lane++) begin
            route[lane]<=helper_route(held_ps[lane*32 +:32],bank_bias[lane*32 +:32]);
            helper_result[lane*32 +:32]<=add_finite_rne(held_ps[lane*32 +:32],bank_bias[lane*32 +:32]);
          end
          helper_lane_issues<=helper_lane_issues+32'($countones(active & {
            helper_route(held_ps[255:224],bank_bias[255:224]),helper_route(held_ps[223:192],bank_bias[223:192]),
            helper_route(held_ps[191:160],bank_bias[191:160]),helper_route(held_ps[159:128],bank_bias[159:128]),
            helper_route(held_ps[127:96],bank_bias[127:96]),helper_route(held_ps[95:64],bank_bias[95:64]),
            helper_route(held_ps[63:32],bank_bias[63:32]),helper_route(held_ps[31:0],bank_bias[31:0])}));
        end else seen<=active;
      end
      if(state==WAIT && held_kind) begin
        for(int lane=0;lane<8;lane++) if(add_valid[lane]) begin
          if(!active[lane] || seen[lane]) protocol_error<=1;
          else begin seen[lane]<=1;returned[lane*32 +:32]<=merged[lane*32 +:32];end
        end
        if(|add_valid) native_lane_returns<=native_lane_returns+32'($countones(add_valid & active & ~seen));
      end
      if(finished) begin
        state<=IDLE;
        if((merged_bad & held_mask)==0 && !protocol_error && !numerical_error) begin
          pending<=1;packet<=0;packet[415:288]<=owner_tag;packet[255:0]<=merged;
          for(int lane=0;lane<8;lane++) if(!held_mask[lane]) packet[lane*32 +:32]<=0;
          packet[268:256]<={held_tile,3'b000};packet[270:269]<=held_row;packet[278:271]<=held_mask;packet[279]<=held_tile==T-1 && held_row==rows-1;
        end
        best='1;best_lane=0;
        for(int lane=0;lane<8;lane++) if(merged_bad[lane] && !held_bad[lane] && held_mask[lane]) begin
          rank=(((64'(held_tile)*4+64'(held_row))*8+64'(lane))*(64'(G)+1)+64'(G))*5;
          if(rank<best) begin best=rank;best_lane=3'(lane);end
        end
        if(best<first_error_rank) begin
          bad_element=64'(held_row)*5248*128+(64'(held_tile)*8+64'(best_lane))*128+64'(G);
          numerical_error<=1;first_error_rank<=best;first_bad_element<=bad_element;first_error_detail<={8'd7,linear_context[39:32],16'd15};
        end
      end
      if(out_valid && out_ready) begin pending<=0;committed_elements<=committed_elements+32'($countones(packet[278:271]));end
      if(command_retire && debt_zero) begin configured<=0;protocol_error<=0;numerical_error<=0;end
    end
  end
endmodule
