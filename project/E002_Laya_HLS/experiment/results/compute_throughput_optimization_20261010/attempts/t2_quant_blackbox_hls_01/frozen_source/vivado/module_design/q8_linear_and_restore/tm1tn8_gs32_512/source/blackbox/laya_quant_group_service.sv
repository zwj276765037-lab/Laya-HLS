`timescale 1ns/1ps
// Actual quant16 engine. Full NumericIdentity/TaskContext/source/A refs are
// held in owner_q until the physical arithmetic and output debts retire.
module laya_quant_group_service (
  input logic ap_clk,ap_rst,ap_ce,ap_start,ap_continue,
  output logic ap_idle,ap_ready,ap_done,
  input logic [63:0] owner0,
  input logic [63:0] owner1,
  input logic [63:0] owner2,
  input logic [63:0] owner3,
  input logic [63:0] owner4,
  input logic [63:0] owner5,
  input logic [63:0] owner6,
  input logic [63:0] owner7,
  input logic [63:0] owner8,
  input logic [63:0] owner9,
  input logic [63:0] owner10,
  input logic [63:0] owner11,
  input logic [63:0] owner12,
  input logic [63:0] owner13,
  input logic [63:0] x0,
  input logic [63:0] x1,
  input logic [63:0] x2,
  input logic [63:0] x3,
  input logic [63:0] x4,
  input logic [63:0] x5,
  input logic [63:0] x6,
  input logic [63:0] x7,
  input logic [63:0] x8,
  input logic [63:0] x9,
  input logic [63:0] x10,
  input logic [63:0] x11,
  input logic [63:0] x12,
  input logic [63:0] x13,
  input logic [63:0] x14,
  input logic [63:0] x15,
  input logic [31:0] row,
  output logic [63:0] echo0,
  output logic echo0_ap_vld,
  output logic [63:0] echo1,
  output logic echo1_ap_vld,
  output logic [63:0] echo2,
  output logic echo2_ap_vld,
  output logic [63:0] echo3,
  output logic echo3_ap_vld,
  output logic [63:0] echo4,
  output logic echo4_ap_vld,
  output logic [63:0] echo5,
  output logic echo5_ap_vld,
  output logic [63:0] echo6,
  output logic echo6_ap_vld,
  output logic [63:0] echo7,
  output logic echo7_ap_vld,
  output logic [63:0] echo8,
  output logic echo8_ap_vld,
  output logic [63:0] echo9,
  output logic echo9_ap_vld,
  output logic [63:0] echo10,
  output logic echo10_ap_vld,
  output logic [63:0] echo11,
  output logic echo11_ap_vld,
  output logic [63:0] echo12,
  output logic echo12_ap_vld,
  output logic [63:0] echo13,
  output logic echo13_ap_vld,
  output logic [63:0] q0,
  output logic q0_ap_vld,
  output logic [63:0] q1,
  output logic q1_ap_vld,
  output logic [63:0] q2,
  output logic q2_ap_vld,
  output logic [63:0] q3,
  output logic q3_ap_vld,
  output logic [31:0] scale,
  output logic scale_ap_vld,
  output logic [31:0] d_full,
  output logic d_full_ap_vld,
  output logic [31:0] reciprocal,
  output logic reciprocal_ap_vld,
  output logic [31:0] status,
  output logic status_ap_vld,
  output logic [31:0] bad_col,
  output logic bad_col_ap_vld
);
  typedef enum logic [2:0] {IDLE,START,FEED0,FEED1,DRAIN,REPORT} phase_t;
  phase_t phase;
  logic [895:0] owner_q;
  logic [1023:0] source_q;
  logic [15:0] row_q;
  logic start_ready,in_ready,out_valid,out_half,done_valid;
  logic [6:0] out_group;
  logic [127:0] out_q;
  logic [15:0] out_scale,first_bad_col;
  logic [31:0] out_d_full,out_reciprocal;
  logic [1:0] done_status;
  logic [31:0] accepted,covered,si,sr,ri,rr,ar,br,mi,mr;
  logic [1:0] received;
  logic [255:0] q_result;
  logic [31:0] scale_q,d_q,reciprocal_q,status_q,bad_q;
  assign ap_idle=phase==IDLE;
  assign ap_ready=phase==REPORT && ap_continue && ap_ce;
  assign ap_done=phase==REPORT;
  assign echo0=owner_q[0 +:64];
  assign echo1=owner_q[64 +:64];
  assign echo2=owner_q[128 +:64];
  assign echo3=owner_q[192 +:64];
  assign echo4=owner_q[256 +:64];
  assign echo5=owner_q[320 +:64];
  assign echo6=owner_q[384 +:64];
  assign echo7=owner_q[448 +:64];
  assign echo8=owner_q[512 +:64];
  assign echo9=owner_q[576 +:64];
  assign echo10=owner_q[640 +:64];
  assign echo11=owner_q[704 +:64];
  assign echo12=owner_q[768 +:64];
  assign echo13=owner_q[832 +:64];
  assign q0=q_result[0 +:64];
  assign q1=q_result[64 +:64];
  assign q2=q_result[128 +:64];
  assign q3=q_result[192 +:64];
  assign scale=scale_q;
  assign d_full=d_q;
  assign reciprocal=reciprocal_q;
  assign status=status_q;
  assign bad_col=bad_q;
  assign echo0_ap_vld=phase==REPORT;
  assign echo1_ap_vld=phase==REPORT;
  assign echo2_ap_vld=phase==REPORT;
  assign echo3_ap_vld=phase==REPORT;
  assign echo4_ap_vld=phase==REPORT;
  assign echo5_ap_vld=phase==REPORT;
  assign echo6_ap_vld=phase==REPORT;
  assign echo7_ap_vld=phase==REPORT;
  assign echo8_ap_vld=phase==REPORT;
  assign echo9_ap_vld=phase==REPORT;
  assign echo10_ap_vld=phase==REPORT;
  assign echo11_ap_vld=phase==REPORT;
  assign echo12_ap_vld=phase==REPORT;
  assign echo13_ap_vld=phase==REPORT;
  assign q0_ap_vld=phase==REPORT;
  assign q1_ap_vld=phase==REPORT;
  assign q2_ap_vld=phase==REPORT;
  assign q3_ap_vld=phase==REPORT;
  assign scale_ap_vld=phase==REPORT;
  assign d_full_ap_vld=phase==REPORT;
  assign reciprocal_ap_vld=phase==REPORT;
  assign status_ap_vld=phase==REPORT;
  assign bad_col_ap_vld=phase==REPORT;
  quant16_stream_row quant (
    .clk(ap_clk),.rst(ap_rst),.start_valid(phase==START && ap_ce),.start_ready,
    .cfg_task_id(owner_q[703:672]),.cfg_source_epoch(owner_q[799:768]),
    .cfg_row(row_q),.cfg_groups(8'd1),
    .in_valid((phase==FEED0 || phase==FEED1) && ap_ce),.in_ready,
    .in_lanes(phase==FEED1 ? source_q[1023:512] : source_q[511:0]),
    .in_task_id(owner_q[703:672]),.in_source_epoch(owner_q[799:768]),
    .in_row(row_q),.in_group(7'd0),.in_half(phase==FEED1),.in_mask(16'hffff),
    .out_valid,.out_ready(phase==DRAIN && ap_ce),.out_group,.out_half,.out_q,
    .out_scale,.out_d_full,.out_reciprocal,.done_valid,
    .done_ready(phase==DRAIN && ap_ce),.done_status,.first_bad_col,
    .accepted_groups(accepted),.covered_groups(covered),.scale_issues(si),
    .scale_returns(sr),.recip_issues(ri),.recip_returns(rr),
    .amax_read_beats(ar),.replay_read_beats(br),.mul_halves_issued(mi),
    .mul_halves_returned(mr));
  always_ff @(posedge ap_clk) begin
    if(ap_rst) begin
      phase<=IDLE;owner_q<=0;source_q<=0;row_q<=0;received<=0;q_result<=0;
      scale_q<=0;d_q<=0;reciprocal_q<=0;status_q<=0;bad_q<='1;
    end else if(ap_ce) begin
      case(phase)
        IDLE: if(ap_start) begin
          owner_q<={owner13,owner12,owner11,owner10,owner9,owner8,owner7,owner6,owner5,owner4,owner3,owner2,owner1,owner0};source_q<={x15,x14,x13,x12,x11,x10,x9,x8,x7,x6,x5,x4,x3,x2,x1,x0};row_q<=row[15:0];
          received<=0;q_result<=0;scale_q<=0;d_q<=0;reciprocal_q<=0;
          status_q<=0;bad_q<='1;phase<=START;
        end
        START: if(start_ready) phase<=FEED0;
        FEED0: if(in_ready) phase<=FEED1;
        FEED1: if(in_ready) phase<=DRAIN;
        DRAIN: begin
          if(out_valid) begin
            if(out_group!=0 || out_half!=received[0]) status_q<=2;
            q_result[out_half*128 +:128]<=out_q;received<=received+1;
            if(out_half) begin scale_q<={16'd0,out_scale};d_q<=out_d_full;reciprocal_q<=out_reciprocal;end
          end
          if(done_valid) begin
            if(done_status!=0) begin status_q<={30'd0,done_status};bad_q<={16'd0,first_bad_col};end
            else if(received!=2 || accepted!=1 || covered!=1 || si!=sr || ri!=rr || mi!=mr)
              status_q<=2;
            phase<=REPORT;
          end
        end
        REPORT: if(ap_continue) phase<=IDLE;
        default: phase<=IDLE;
      endcase
    end
  end
endmodule
