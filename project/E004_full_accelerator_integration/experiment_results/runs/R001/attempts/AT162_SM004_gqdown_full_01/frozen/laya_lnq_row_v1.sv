`timescale 1ns/1ps

// Fixed one-row LN -> quantize handoff. All arithmetic stays in the two
// existing services. The 1088-byte row is invisible until both retire.
module laya_lnq_row_v1 (
  input  logic         clk, rst_n,
  input  logic         cmd_valid,
  output logic         cmd_ready,
  input  logic         source_direct,
  input  logic [1:0]   gamma_kind,
  input  logic [15:0]  cmd_row,
  input  logic         x_valid,
  output logic         x_ready,
  input  logic [31:0]  x_bits,
  input  logic         gamma_valid,
  output logic         gamma_ready,
  input  logic [31:0]  gamma_bits,
  output logic         row_valid,
  input  logic         rd_valid,
  output logic         rd_ready,
  input  logic [6:0]   rd_group,
  output logic         rsp_valid,
  input  logic         rsp_ready,
  output logic [6:0]   rsp_group,
  output logic [255:0] rsp_q8,
  output logic [15:0]  rsp_scale,
  input  logic         row_release_valid,
  output logic         row_release_ready,
  output logic         done_valid,
  input  logic         done_ready,
  output logic [3:0]   done_status,
  output logic [31:0]  done_bad_element,
  output logic [31:0]  mean_bits, variance_bits, inverse_bits
);
  typedef enum logic [1:0] {IDLE, RUN, ROW, DONE} state_t;
  state_t state;
  logic [15:0] row;
  logic direct_mode;
  logic [511:0] pack;
  logic [4:0] pack_count;
  logic [11:0] ln_count;
  logic [7:0] half_sent, half_written;
  logic [6:0] scale_written;
  logic [127:0] q0_bank [0:81], q1_bank [0:81];
  logic [15:0] scale_bank [0:81];
  logic [1:0] q_coverage [0:81];
  logic [81:0] scale_cover;
  logic q_started, ln_done_seen, q_done_seen, drop_mode, local_protocol;
  logic [3:0] ln_status;
  logic [31:0] ln_bad;
  logic [1:0] q_status;
  logic [15:0] q_bad;
  logic [31:0] ln_mean, ln_variance, ln_inverse;
  logic [6:0] read_addr;
  logic read_pending;

  logic ln_cmd_valid,ln_cmd_ready,ln_x_ready,ln_gamma_ready;
  logic ln_out_valid,ln_out_ready,ln_out_last,ln_done_valid,ln_done_ready;
  logic [31:0] ln_out_bits,ln_bad_wire,ln_mean_wire,ln_var_wire,ln_inv_wire;
  logic [9:0] ln_out_index;
  logic [3:0] ln_status_wire;
  logic q_start_valid,q_start_ready,q_in_valid,q_in_ready,q_out_valid,q_out_ready;
  logic q_done_valid,q_done_ready,q_physical_debt_zero;
  logic [1:0] q_done_status;
  logic [15:0] q_first_bad;
  logic [6:0] q_in_group,q_out_group;
  logic q_in_half,q_out_half;
  logic [127:0] q_out_bits;
  logic [15:0] q_out_scale;
  logic [31:0] q_accepted_groups,q_covered_groups;
  wire cmd_fire=cmd_valid && cmd_ready;
  wire ln_out_fire=ln_out_valid && ln_out_ready;
  wire q_start_fire=q_start_valid && q_start_ready;
  wire q_in_fire=q_in_valid && q_in_ready;
  wire q_out_fire=q_out_valid && q_out_ready;
  wire q_done_fire=q_done_valid && q_done_ready;
  wire ln_done_fire=ln_done_valid && ln_done_ready;
  wire direct_x_fire=direct_mode && x_valid && x_ready;
  wire [11:0] source_words=direct_mode ? 12'd2624 : 12'd1024;
  wire [7:0] required_halves=direct_mode ? 8'd164 : 8'd64;
  wire [6:0] required_groups=direct_mode ? 7'd82 : 7'd32;
  wire source_done=direct_mode ? ln_count==12'd2624 : ln_done_seen;

  assign cmd_ready=(state==IDLE) && ln_cmd_ready && q_start_ready &&
                   q_physical_debt_zero && !q_done_valid;
  assign ln_cmd_valid=cmd_fire && !source_direct;
  assign q_start_valid=(state==RUN) && !q_started && !drop_mode &&
                       (direct_mode || (ln_out_valid && !ln_done_seen));
  assign ln_out_ready=(state==RUN) && !direct_mode && (drop_mode ||
                      (q_started && pack_count<5'd16));
  assign q_in_valid=(state==RUN) && q_started && !drop_mode &&
                    !q_done_seen && pack_count==5'd16;
  assign q_in_group=half_sent[7:1];
  assign q_in_half=half_sent[0];
  assign q_out_ready=(state==RUN);
  assign ln_done_ready=(state==RUN) && !ln_done_seen;
  assign q_done_ready=(state==RUN) && q_physical_debt_zero && !q_done_seen;
  assign row_valid=(state==ROW);
  assign rd_ready=(state==ROW) && !row_release_valid &&
                  rd_group<required_groups &&
                  !rsp_valid && !read_pending;
  assign row_release_ready=(state==ROW) && !rsp_valid && !read_pending;
  assign done_valid=(state==DONE);
  assign mean_bits=!direct_mode && (state==ROW || (state==DONE && done_status==0)) ? ln_mean : 0;
  assign variance_bits=!direct_mode && (state==ROW || (state==DONE && done_status==0)) ? ln_variance : 0;
  assign inverse_bits=!direct_mode && (state==ROW || (state==DONE && done_status==0)) ? ln_inverse : 0;

  laya_ln_row_v1 ln (
    .clk(clk),.rst_n(rst_n),.cmd_valid(ln_cmd_valid),.cmd_ready(ln_cmd_ready),
    .gamma_kind(gamma_kind),.x_valid(x_valid && state==RUN && !direct_mode),.x_ready(ln_x_ready),
    .x_bits(x_bits),.gamma_valid(gamma_valid && state==RUN),
    .gamma_ready(ln_gamma_ready),.gamma_bits(gamma_bits),
    .out_valid(ln_out_valid),.out_ready(ln_out_ready),.out_bits(ln_out_bits),
    .out_index(ln_out_index),.out_last(ln_out_last),
    .done_valid(ln_done_valid),.done_ready(ln_done_ready),
    .done_status(ln_status_wire),.done_bad_element(ln_bad_wire),
    .mean_bits(ln_mean_wire),.variance_bits(ln_var_wire),
    .inverse_bits(ln_inv_wire));
  assign x_ready=(state==RUN) && (direct_mode ?
    (ln_count<12'd2624 &&
      (drop_mode || (q_started && pack_count<5'd16))) :
    ln_x_ready);
  assign gamma_ready=(state==RUN) && !direct_mode && ln_gamma_ready;

  quant16_stream_row q (
    .clk(clk),.rst(!rst_n),.start_valid(q_start_valid),.start_ready(q_start_ready),
    .cfg_task_id(32'd1),.cfg_source_epoch(32'd1),.cfg_row(row),
    .cfg_groups(direct_mode ? 8'd82 : 8'd32),
    .in_valid(q_in_valid),.in_ready(q_in_ready),.in_lanes(pack),
    .in_task_id(32'd1),.in_source_epoch(32'd1),.in_row(row),
    .in_group(q_in_group),.in_half(q_in_half),.in_mask(16'hffff),
    .out_valid(q_out_valid),.out_ready(q_out_ready),.out_group(q_out_group),
    .out_half(q_out_half),.out_q(q_out_bits),.out_scale(q_out_scale),
    .out_d_full(),.out_reciprocal(),.done_valid(q_done_valid),
    .done_ready(q_done_ready),.done_status(q_done_status),
    .first_bad_col(q_first_bad),.accepted_groups(q_accepted_groups),
    .covered_groups(q_covered_groups),.scale_issues(),.scale_returns(),
    .recip_issues(),.recip_returns(),.amax_read_beats(),.replay_read_beats(),
    .mul_halves_issued(),.mul_halves_returned(),.input_read_debt_zero(),
    .slot_debt_zero(),.divider_helper_debt_zero(),.mul_return_debt_zero(),
    .physical_debt_zero(q_physical_debt_zero),.retired_d_full(),
    .retired_reciprocal(),.retired_scale());

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE; row<=0; direct_mode<=0; pack<=0; pack_count<=0;
      ln_count<=0; half_sent<=0; half_written<=0; scale_written<=0;
      q_started<=0; ln_done_seen<=0; q_done_seen<=0;
      drop_mode<=0; local_protocol<=0;
      ln_status<=0; ln_bad<=32'hffffffff; q_status<=0; q_bad<=16'hffff;
      ln_mean<=0; ln_variance<=0; ln_inverse<=0;
      done_status<=0; done_bad_element<=32'hffffffff;
      rsp_valid<=0; rsp_group<=0; rsp_q8<=0; rsp_scale<=0;
      read_pending<=0; read_addr<=0; scale_cover<=0;
      for(int i=0;i<82;i++) q_coverage[i]<=0;
    end else begin
      if(rsp_valid && rsp_ready) rsp_valid<=0;
      if(read_pending) begin
        rsp_q8<={q1_bank[read_addr],q0_bank[read_addr]};
        rsp_scale<=scale_bank[read_addr];
        rsp_group<=read_addr;
        rsp_valid<=1;
        read_pending<=0;
      end
      case(state)
        IDLE: if(cmd_fire) begin
          state<=RUN; row<=cmd_row; direct_mode<=source_direct;
          pack_count<=0; ln_count<=0;
          half_sent<=0; half_written<=0; scale_written<=0;
          q_started<=0; ln_done_seen<=0; q_done_seen<=0;
          drop_mode<=0; local_protocol<=0;
          ln_status<=0; ln_bad<=32'hffffffff; q_status<=0;
          q_bad<=16'hffff; ln_mean<=0; ln_variance<=0; ln_inverse<=0;
          scale_cover<=0; read_pending<=0; rsp_valid<=0;
          done_status<=0; done_bad_element<=32'hffffffff;
          for(int i=0;i<82;i++) q_coverage[i]<=0;
          if(source_direct && gamma_kind!=0) begin
            done_status<=4'd7;
            state<=DONE;
          end
        end
        RUN: begin
          if(q_start_fire) q_started<=1;
          if(ln_out_fire) begin
            if(ln_out_index!==ln_count[9:0] || ln_out_last!==(ln_count==12'd1023))
              local_protocol<=1;
            ln_count<=ln_count+1'b1;
            if(!drop_mode) begin
              pack[32*pack_count +:32]<=ln_out_bits;
              pack_count<=pack_count+1'b1;
            end
          end
          if(direct_x_fire) begin
            ln_count<=ln_count+1'b1;
            if(!drop_mode) begin
              pack[32*pack_count +:32]<=x_bits;
              pack_count<=pack_count+1'b1;
            end
          end
          if(q_in_fire) begin
            half_sent<=half_sent+1'b1;
            pack_count<=0;
          end
          if(q_out_fire) begin
            if(q_out_group>=required_groups || half_written>=required_halves) local_protocol<=1;
            else if(q_coverage[q_out_group][q_out_half]) local_protocol<=1;
            else begin
              q_coverage[q_out_group][q_out_half]<=1;
              if(q_out_half) begin
                q1_bank[q_out_group]<=q_out_bits;
                scale_bank[q_out_group]<=q_out_scale;
                if(scale_cover[q_out_group]) local_protocol<=1;
                else begin
                  scale_cover[q_out_group]<=1;
                  scale_written<=scale_written+1'b1;
                end
              end else q0_bank[q_out_group]<=q_out_bits;
              half_written<=half_written+1'b1;
            end
          end
          if(ln_done_fire) begin
            ln_done_seen<=1; ln_status<=ln_status_wire;
            ln_bad<=ln_bad_wire;
            ln_mean<=ln_mean_wire; ln_variance<=ln_var_wire;
            ln_inverse<=ln_inv_wire;
          end
          if(q_done_fire) begin
            q_done_seen<=1; q_status<=q_done_status; q_bad<=q_first_bad;
            if(q_done_status==2) begin
              drop_mode<=1;
              pack_count<=0;
            end
          end
          if(source_done && (!q_started || q_done_seen) && pack_count==0) begin
            if(ln_status!=0) begin
              done_status<=ln_status; done_bad_element<=ln_bad;
              state<=DONE;
            end else if(q_started && q_done_seen) begin
              if(q_status==1) begin
                done_status<=4'd6; done_bad_element<={16'd0,q_bad};
                state<=DONE;
              end else if(q_status==2 || local_protocol ||
                          ln_count!=source_words || half_sent!=required_halves ||
                          half_written!=required_halves || scale_written!=required_groups ||
                          q_accepted_groups!=32'(required_groups) ||
                          q_covered_groups!=32'(required_groups) ||
                          (direct_mode ? !(&scale_cover[81:0]) :
                                         !(&scale_cover[31:0]))) begin
                done_status<=4'd7; done_bad_element<=32'hffffffff;
                state<=DONE;
              end else begin
                state<=ROW;
              end
            end
          end
        end
        ROW: begin
          if(rd_valid && rd_ready) begin
            read_addr<=rd_group;
            read_pending<=1;
          end
          if(row_release_valid && row_release_ready) begin
            done_status<=0; done_bad_element<=32'hffffffff;
            state<=DONE;
          end
        end
        DONE: if(done_ready) state<=IDLE;
        default: state<=IDLE;
      endcase
    end
  end
endmodule
