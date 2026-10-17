`timescale 1ns/1ps

// Complete two-slot A store. Payload is 2*16*(128*256+128*16) bits.
// Admission is supplied by the production owner ledger. This module publishes
// only its local complete A handle; it does not manufacture a source owner.
module quant_dual_a_v1 (
  input logic clk,rst_n,
  input logic fill_valid,
  output logic fill_ready,fill_reject,
  input logic fill_owner_admitted,fill_source_published,fill_slot,
  input logic [31:0] fill_slot_epoch,
  input logic [12:0] fill_K,
  input logic [4:0] fill_rows,
  input logic [671:0] fill_numeric_identity,
  input logic [95:0] fill_producer_context,fill_quant_context,fill_linear_context,
  input logic [63:0] fill_source_ref,fill_a_ref,fill_w_ref,fill_dst_ref,
  input logic commit_valid,
  output logic commit_ready,commit_error,
  input logic [671:0] commit_numeric_identity,
  input logic [95:0] commit_quant_context,
  input logic [63:0] commit_a_ref,
  input logic [3:0] commit_row,
  input logic [6:0] commit_group,
  input logic commit_half,
  input logic [127:0] commit_q,
  input logic [15:0] commit_scale,
  input logic row_done_valid,
  output logic row_done_ready,
  input logic [3:0] row_done_row,
  input logic [1:0] row_done_status,
  input logic [15:0] row_done_bad_col,
  input logic row_done_debt_zero,
  input logic finish_valid,
  output logic finish_ready,fill_done,fill_error,publish_valid,
  input logic finish_debt_zero,
  output logic [63:0] fill_bad_element,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch,
  output logic [1:0][15:0] slot_rows_done,
  output logic [31:0] physical_half_commits,physical_scale_commits,
  input logic acquire_valid,
  output logic acquire_ready,acquire_done,acquire_error,
  input logic acquire_slot,
  input logic [31:0] acquire_slot_epoch,
  input logic [12:0] acquire_K,
  input logic [4:0] acquire_rows,
  input logic [671:0] acquire_numeric_identity,
  input logic [95:0] acquire_linear_context,
  input logic [63:0] acquire_a_ref,acquire_w_ref,acquire_dst_ref,
  input logic read_valid,
  output logic read_ready,read_error,
  input logic read_slot,
  input logic [31:0] read_slot_epoch,
  input logic [671:0] read_numeric_identity,
  input logic [95:0] read_linear_context,
  input logic [63:0] read_a_ref,
  input logic [3:0] read_row_block_base,
  input logic [2:0] read_rows,
  input logic [6:0] read_group,
  output logic ret_valid,
  input logic ret_ready,
  output logic ret_slot,
  output logic [31:0] ret_slot_epoch,
  output logic [671:0] ret_numeric_identity,
  output logic [95:0] ret_linear_context,
  output logic [63:0] ret_a_ref,
  output logic [3:0] ret_row_block_base,
  output logic [2:0] ret_rows,
  output logic [6:0] ret_group,
  output logic [3:0][255:0] ret_q,
  output logic [3:0][15:0] ret_scale,
  input logic release_valid,
  output logic release_ready,release_done,release_error,
  input logic release_slot,
  input logic [31:0] release_slot_epoch,
  input logic [671:0] release_numeric_identity,
  input logic [95:0] release_linear_context,
  input logic [63:0] release_a_ref,
  output logic read_debt_zero
);
  localparam logic [2:0] EMPTY=0,FILL=1,READY=2,IN_USE=3,INVALID=4;
  logic [671:0] numeric_id[0:1];
  logic [95:0] producer_ctx[0:1],quant_ctx[0:1],linear_ctx[0:1];
  logic [63:0] source_ref[0:1],a_ref[0:1],w_ref[0:1],dst_ref[0:1];
  logic [12:0] K[0:1];
  logic [4:0] rows[0:1];
  logic [7:0] groups[0:1];
  logic [127:0] half0_cover[0:1][0:15],half1_cover[0:1][0:15],scale_cover[0:1][0:15];
  logic fill_active,active_slot,fill_failed;
  logic [4:0] expected_row;
  logic [7:0] expected_group;
  logic expected_half;
  logic command_ok,commit_ok,row_ok,acquire_ok,read_ok,release_ok;
  logic pending,pending_slot;
  logic [3:0] pending_row;
  logic [2:0] pending_rows;
  logic [6:0] pending_group;
  logic [1:0][15:0][255:0] bank_q;
  logic [1:0][15:0][15:0] bank_scale;
  logic [1:0][15:0] bank_re;
  wire fill_fire=fill_valid && fill_ready;
  wire commit_fire=commit_valid && commit_ready;
  wire read_fire=read_valid && read_ready;

  function automatic logic source_ok(input logic [12:0] k,input logic [95:0] ctx,input logic [63:0] refword);
    logic [7:0] stage,rowspace,id,region;
    stage=ctx[47:40];rowspace=ctx[71:64];id=refword[39:32];region=refword[55:48];
    source_ok=0;
    case(stage)
      2: source_ok=rowspace==0 && ((k==1024 && (id==1 || id==2 || id==8)) || (k==2624 && id==7));
      4: source_ok=rowspace==0 && ((k==1024 && (id==1 || id==2 || id==8)) || (k==4096 && id==9));
      5: source_ok=rowspace==1 && k==1024 && id==10 && region==0;
      6: source_ok=rowspace==2 && k==256 && id==10 && region==2;
      default: source_ok=0;
    endcase
  endfunction
  always_comb begin : validate
    logic [16:0] endrow;
    logic [15:0] row_limit;
    row_limit=fill_quant_context[71:64]==0 ? fill_numeric_identity[159:144] :
      fill_quant_context[71:64]==1 ? 16 : 1;
    endrow={1'b0,fill_quant_context[87:72]}+17'(fill_rows);
    command_ok=fill_owner_admitted && fill_source_published &&
      fill_numeric_identity[63:0]!=0 && fill_numeric_identity[127:64]!=0 &&
      fill_numeric_identity[143:128]>=1 && fill_numeric_identity[143:128]<=2 &&
      fill_numeric_identity[159:144]>=64 && fill_numeric_identity[159:144]<=1024 &&
      fill_quant_context[63:56]<fill_numeric_identity[143:128] &&
      fill_rows>=1 && fill_rows<=16 && fill_quant_context[95:88]==fill_rows && endrow<=row_limit &&
      source_ok(fill_K,fill_quant_context,fill_source_ref) &&
      fill_source_ref[31:0]!=0 && fill_a_ref[31:0]!=0 &&
      fill_a_ref[39:32]==8'h22 && fill_a_ref[47:40]=={7'd0,fill_slot} &&
      fill_a_ref[63:56]==0 && fill_slot_epoch!=0 && slot_epoch[fill_slot]!=32'hffffffff &&
      fill_slot_epoch==slot_epoch[fill_slot]+1 &&
      (slot_state[fill_slot]==EMPTY || slot_state[fill_slot]==INVALID) &&
      fill_quant_context[31:0]!=0 && fill_linear_context[31:0]!=0 &&
      fill_quant_context[87:48]==fill_linear_context[87:48] &&
      fill_quant_context[95:88]==fill_linear_context[95:88];
    commit_ok=fill_active && !fill_failed && expected_row<rows[active_slot] &&
      expected_group<groups[active_slot] && commit_row==expected_row &&
      commit_group==expected_group && commit_half==expected_half &&
      commit_numeric_identity==numeric_id[active_slot] &&
      commit_quant_context==quant_ctx[active_slot] && commit_a_ref==a_ref[active_slot] &&
      (commit_half || commit_scale==0);
    row_ok=fill_active && !fill_failed && row_done_row==expected_row &&
      expected_row<rows[active_slot] && row_done_status==0 && row_done_debt_zero &&
      expected_group==groups[active_slot] && !expected_half;
    acquire_ok=slot_state[acquire_slot]==READY && acquire_slot_epoch==slot_epoch[acquire_slot] &&
      acquire_K==K[acquire_slot] && acquire_rows==rows[acquire_slot] &&
      acquire_numeric_identity==numeric_id[acquire_slot] && acquire_linear_context==linear_ctx[acquire_slot] &&
      acquire_a_ref==a_ref[acquire_slot] && acquire_w_ref==w_ref[acquire_slot] && acquire_dst_ref==dst_ref[acquire_slot];
    read_ok=slot_state[read_slot]==IN_USE && read_slot_epoch==slot_epoch[read_slot] &&
      read_numeric_identity==numeric_id[read_slot] && read_linear_context==linear_ctx[read_slot] &&
      read_a_ref==a_ref[read_slot] && (read_rows==1 || read_rows==4) &&
      ({1'b0,read_row_block_base}+5'(read_rows))<=rows[read_slot] &&
      {1'b0,read_group}<groups[read_slot];
    release_ok=slot_state[release_slot]==IN_USE && release_slot_epoch==slot_epoch[release_slot] &&
      release_numeric_identity==numeric_id[release_slot] && release_linear_context==linear_ctx[release_slot] &&
      release_a_ref==a_ref[release_slot];
  end
  assign fill_ready=rst_n && !fill_active;
  assign commit_ready=rst_n && fill_active && !finish_valid && !row_done_valid;
  assign row_done_ready=rst_n && fill_active && !finish_valid;
  assign finish_ready=rst_n && fill_active && finish_debt_zero && !commit_valid && !row_done_valid;
  assign acquire_ready=rst_n;
  assign read_ready=rst_n && !pending && (!ret_valid || ret_ready);
  assign release_ready=rst_n && !(read_fire && read_ok && read_slot==release_slot) && !(pending && pending_slot==release_slot) && !(ret_valid && ret_slot==release_slot);
  assign read_debt_zero=!pending && !ret_valid;
  always_comb begin
    bank_re='0;
    if(read_fire && read_ok)
      for(int rr=0;rr<16;rr++)
        if(rr>=read_row_block_base && rr<read_row_block_base+read_rows) bank_re[read_slot][rr]=1;
  end
  generate for(genvar ss=0;ss<2;ss++) begin: slots
    for(genvar rr=0;rr<16;rr++) begin: rowbanks
      wire wr=commit_fire && commit_ok && active_slot==ss && commit_row==rr;
      quant_a_row_bank_v1 bank(.clk(clk),.q0_we(wr && !commit_half),.q1_we(wr && commit_half),
        .scale_we(wr && commit_half),.wgroup(commit_group),.q_wdata(commit_q),.scale_wdata(commit_scale),
        .re(bank_re[ss][rr]),.rgroup(read_group),.q_rdata(bank_q[ss][rr]),.scale_rdata(bank_scale[ss][rr]));
    end
  end endgenerate

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      slot_state<='0;slot_epoch<='0;slot_rows_done<='0;
      fill_active<=0;active_slot<=0;fill_failed<=0;expected_row<=0;expected_group<=0;expected_half<=0;
      fill_reject<=0;commit_error<=0;fill_done<=0;fill_error<=0;publish_valid<=0;fill_bad_element<='1;
      physical_half_commits<=0;physical_scale_commits<=0;
      acquire_done<=0;acquire_error<=0;read_error<=0;release_done<=0;release_error<=0;
      pending<=0;pending_slot<=0;pending_row<=0;pending_rows<=0;pending_group<=0;ret_valid<=0;
      ret_slot<=0;ret_slot_epoch<=0;ret_numeric_identity<=0;ret_linear_context<=0;ret_a_ref<=0;
      ret_row_block_base<=0;ret_rows<=0;ret_group<=0;ret_q<=0;ret_scale<=0;
      for(int ss=0;ss<2;ss++) begin
        numeric_id[ss]<=0;producer_ctx[ss]<=0;quant_ctx[ss]<=0;linear_ctx[ss]<=0;
        source_ref[ss]<=0;a_ref[ss]<=0;w_ref[ss]<=0;dst_ref[ss]<=0;K[ss]<=0;rows[ss]<=0;groups[ss]<=0;
        for(int rr=0;rr<16;rr++) begin half0_cover[ss][rr]<=0;half1_cover[ss][rr]<=0;scale_cover[ss][rr]<=0;end
      end
    end else begin
      fill_reject<=0;commit_error<=0;fill_done<=0;fill_error<=0;publish_valid<=0;
      acquire_done<=0;acquire_error<=0;read_error<=0;release_done<=0;release_error<=0;
      if(ret_valid && ret_ready) ret_valid<=0;
      if(fill_fire) begin
        if(!command_ok) fill_reject<=1;
        else begin
          fill_active<=1;active_slot<=fill_slot;fill_failed<=0;fill_bad_element<='1;
          expected_row<=0;expected_group<=0;expected_half<=0;
          slot_state[fill_slot]<=FILL;slot_epoch[fill_slot]<=fill_slot_epoch;slot_rows_done[fill_slot]<=0;
          numeric_id[fill_slot]<=fill_numeric_identity;producer_ctx[fill_slot]<=fill_producer_context;
          quant_ctx[fill_slot]<=fill_quant_context;linear_ctx[fill_slot]<=fill_linear_context;
          source_ref[fill_slot]<=fill_source_ref;a_ref[fill_slot]<=fill_a_ref;w_ref[fill_slot]<=fill_w_ref;dst_ref[fill_slot]<=fill_dst_ref;
          K[fill_slot]<=fill_K;groups[fill_slot]<=8'(fill_K>>5);rows[fill_slot]<=fill_rows;
          physical_half_commits<=0;physical_scale_commits<=0;
          for(int rr=0;rr<16;rr++) begin half0_cover[fill_slot][rr]<=0;half1_cover[fill_slot][rr]<=0;scale_cover[fill_slot][rr]<=0;end
        end
      end
      if(commit_fire) begin
        if(!commit_ok) begin commit_error<=1;fill_failed<=1;slot_state[active_slot]<=INVALID;end
        else begin
          physical_half_commits<=physical_half_commits+1;
          if(commit_half) begin
            half1_cover[active_slot][commit_row][commit_group]<=1;
            scale_cover[active_slot][commit_row][commit_group]<=1;
            physical_scale_commits<=physical_scale_commits+1;
            expected_half<=0;expected_group<=expected_group+1;
          end else begin half0_cover[active_slot][commit_row][commit_group]<=1;expected_half<=1;end
        end
      end
      if(row_done_valid && row_done_ready) begin
        if(row_ok) begin
          slot_rows_done[active_slot][row_done_row]<=1;expected_row<=expected_row+1;expected_group<=0;
        end else begin
          fill_failed<=1;slot_state[active_slot]<=INVALID;
          if(!fill_failed && row_done_status==1 && row_done_row==expected_row && row_done_bad_col<K[active_slot])
            fill_bad_element<=64'(expected_row)*4096+64'(row_done_bad_col);
        end
      end
      if(finish_valid && finish_ready) begin
        fill_active<=0;fill_done<=1;
        if(!fill_failed && expected_row==rows[active_slot] && physical_half_commits==32'(rows[active_slot])*32'(groups[active_slot])*2 &&
          physical_scale_commits==32'(rows[active_slot])*32'(groups[active_slot])) begin
          slot_state[active_slot]<=READY;publish_valid<=1;
        end else begin slot_state[active_slot]<=INVALID;fill_error<=1;end
      end
      if(acquire_valid && acquire_ready) begin
        acquire_done<=1;
        if(acquire_ok) slot_state[acquire_slot]<=IN_USE;else acquire_error<=1;
      end
      if(read_fire) begin
        if(!read_ok) read_error<=1;
        else begin
          pending<=1;pending_slot<=read_slot;pending_row<=read_row_block_base;pending_rows<=read_rows;pending_group<=read_group;
        end
      end
      if(pending) begin
        pending<=0;ret_valid<=1;ret_slot<=pending_slot;ret_slot_epoch<=slot_epoch[pending_slot];
        ret_numeric_identity<=numeric_id[pending_slot];ret_linear_context<=linear_ctx[pending_slot];ret_a_ref<=a_ref[pending_slot];
        ret_row_block_base<=pending_row;ret_rows<=pending_rows;ret_group<=pending_group;
        for(int rr=0;rr<4;rr++) begin
          if(rr<pending_rows) begin ret_q[rr]<=bank_q[pending_slot][pending_row+rr];ret_scale[rr]<=bank_scale[pending_slot][pending_row+rr];end
          else begin ret_q[rr]<=0;ret_scale[rr]<=0;end
        end
      end
      if(release_valid && release_ready) begin
        release_done<=1;
        if(release_ok) slot_state[release_slot]<=EMPTY;else release_error<=1;
      end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk) if(rst_n) begin
    for(int ss=0;ss<2;ss++) for(int rr=0;rr<16;rr++)
      assert(!(bank_re[ss][rr] && commit_fire && commit_ok && active_slot==ss && commit_row==rr))
        else $fatal(1,"A same-slot fill/read conflict");
  end
`endif
endmodule
