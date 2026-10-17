`timescale 1ns/1ps
// One atomic 4-row stripe, with full 1024-bit owner retention in the HLS call.
// Actual four Q35/D4 row pipelines independently return; done waits for all
// accepted commits and the actual reservation credit to retire.
module laya_tm4_group_service (
  input wire ap_clk,ap_rst,ap_ce,ap_start,ap_continue,
  output wire ap_idle,ap_ready,ap_done,
  input wire [63:0] owner0,
  input wire [63:0] owner1,
  input wire [63:0] owner2,
  input wire [63:0] owner3,
  input wire [63:0] owner4,
  input wire [63:0] owner5,
  input wire [63:0] owner6,
  input wire [63:0] owner7,
  input wire [63:0] owner8,
  input wire [63:0] owner9,
  input wire [63:0] owner10,
  input wire [63:0] owner11,
  input wire [63:0] owner12,
  input wire [63:0] owner13,
  input wire [63:0] owner14,
  input wire [63:0] owner15,
  input wire [63:0] aq0,
  input wire [63:0] aq1,
  input wire [63:0] aq2,
  input wire [63:0] aq3,
  input wire [63:0] aq4,
  input wire [63:0] aq5,
  input wire [63:0] aq6,
  input wire [63:0] aq7,
  input wire [63:0] aq8,
  input wire [63:0] aq9,
  input wire [63:0] aq10,
  input wire [63:0] aq11,
  input wire [63:0] aq12,
  input wire [63:0] aq13,
  input wire [63:0] aq14,
  input wire [63:0] aq15,
  input wire [63:0] wq0,
  input wire [63:0] wq1,
  input wire [63:0] wq2,
  input wire [63:0] wq3,
  input wire [63:0] wq4,
  input wire [63:0] wq5,
  input wire [63:0] wq6,
  input wire [63:0] wq7,
  input wire [63:0] wq8,
  input wire [63:0] wq9,
  input wire [63:0] wq10,
  input wire [63:0] wq11,
  input wire [63:0] wq12,
  input wire [63:0] wq13,
  input wire [63:0] wq14,
  input wire [63:0] wq15,
  input wire [63:0] wq16,
  input wire [63:0] wq17,
  input wire [63:0] wq18,
  input wire [63:0] wq19,
  input wire [63:0] wq20,
  input wire [63:0] wq21,
  input wire [63:0] wq22,
  input wire [63:0] wq23,
  input wire [63:0] wq24,
  input wire [63:0] wq25,
  input wire [63:0] wq26,
  input wire [63:0] wq27,
  input wire [63:0] wq28,
  input wire [63:0] wq29,
  input wire [63:0] wq30,
  input wire [63:0] wq31,
  input wire [31:0] sa0,
  input wire [31:0] sa1,
  input wire [31:0] sa2,
  input wire [31:0] sa3,
  input wire [31:0] sw0,
  input wire [31:0] sw1,
  input wire [31:0] sw2,
  input wire [31:0] sw3,
  input wire [31:0] sw4,
  input wire [31:0] sw5,
  input wire [31:0] sw6,
  input wire [31:0] sw7,
  input wire [31:0] old0,
  input wire [31:0] old1,
  input wire [31:0] old2,
  input wire [31:0] old3,
  input wire [31:0] old4,
  input wire [31:0] old5,
  input wire [31:0] old6,
  input wire [31:0] old7,
  input wire [31:0] old8,
  input wire [31:0] old9,
  input wire [31:0] old10,
  input wire [31:0] old11,
  input wire [31:0] old12,
  input wire [31:0] old13,
  input wire [31:0] old14,
  input wire [31:0] old15,
  input wire [31:0] old16,
  input wire [31:0] old17,
  input wire [31:0] old18,
  input wire [31:0] old19,
  input wire [31:0] old20,
  input wire [31:0] old21,
  input wire [31:0] old22,
  input wire [31:0] old23,
  input wire [31:0] old24,
  input wire [31:0] old25,
  input wire [31:0] old26,
  input wire [31:0] old27,
  input wire [31:0] old28,
  input wire [31:0] old29,
  input wire [31:0] old30,
  input wire [31:0] old31,
  input wire [31:0] lane_masks,
  input wire [31:0] group,
  input wire [31:0] tile,
  input wire [31:0] \sequence ,
  output wire [63:0] echo0,
  output wire echo0_ap_vld,
  output wire [63:0] echo1,
  output wire echo1_ap_vld,
  output wire [63:0] echo2,
  output wire echo2_ap_vld,
  output wire [63:0] echo3,
  output wire echo3_ap_vld,
  output wire [63:0] echo4,
  output wire echo4_ap_vld,
  output wire [63:0] echo5,
  output wire echo5_ap_vld,
  output wire [63:0] echo6,
  output wire echo6_ap_vld,
  output wire [63:0] echo7,
  output wire echo7_ap_vld,
  output wire [63:0] echo8,
  output wire echo8_ap_vld,
  output wire [63:0] echo9,
  output wire echo9_ap_vld,
  output wire [63:0] echo10,
  output wire echo10_ap_vld,
  output wire [63:0] echo11,
  output wire echo11_ap_vld,
  output wire [63:0] echo12,
  output wire echo12_ap_vld,
  output wire [63:0] echo13,
  output wire echo13_ap_vld,
  output wire [63:0] echo14,
  output wire echo14_ap_vld,
  output wire [63:0] echo15,
  output wire echo15_ap_vld,
  output wire [31:0] next0,
  output wire next0_ap_vld,
  output wire [31:0] next1,
  output wire next1_ap_vld,
  output wire [31:0] next2,
  output wire next2_ap_vld,
  output wire [31:0] next3,
  output wire next3_ap_vld,
  output wire [31:0] next4,
  output wire next4_ap_vld,
  output wire [31:0] next5,
  output wire next5_ap_vld,
  output wire [31:0] next6,
  output wire next6_ap_vld,
  output wire [31:0] next7,
  output wire next7_ap_vld,
  output wire [31:0] next8,
  output wire next8_ap_vld,
  output wire [31:0] next9,
  output wire next9_ap_vld,
  output wire [31:0] next10,
  output wire next10_ap_vld,
  output wire [31:0] next11,
  output wire next11_ap_vld,
  output wire [31:0] next12,
  output wire next12_ap_vld,
  output wire [31:0] next13,
  output wire next13_ap_vld,
  output wire [31:0] next14,
  output wire next14_ap_vld,
  output wire [31:0] next15,
  output wire next15_ap_vld,
  output wire [31:0] next16,
  output wire next16_ap_vld,
  output wire [31:0] next17,
  output wire next17_ap_vld,
  output wire [31:0] next18,
  output wire next18_ap_vld,
  output wire [31:0] next19,
  output wire next19_ap_vld,
  output wire [31:0] next20,
  output wire next20_ap_vld,
  output wire [31:0] next21,
  output wire next21_ap_vld,
  output wire [31:0] next22,
  output wire next22_ap_vld,
  output wire [31:0] next23,
  output wire next23_ap_vld,
  output wire [31:0] next24,
  output wire next24_ap_vld,
  output wire [31:0] next25,
  output wire next25_ap_vld,
  output wire [31:0] next26,
  output wire next26_ap_vld,
  output wire [31:0] next27,
  output wire next27_ap_vld,
  output wire [31:0] next28,
  output wire next28_ap_vld,
  output wire [31:0] next29,
  output wire next29_ap_vld,
  output wire [31:0] next30,
  output wire next30_ap_vld,
  output wire [31:0] next31,
  output wire next31_ap_vld,
  output wire [31:0] bad0,
  output wire bad0_ap_vld,
  output wire [31:0] bad1,
  output wire bad1_ap_vld,
  output wire [31:0] bad2,
  output wire bad2_ap_vld,
  output wire [31:0] bad3,
  output wire bad3_ap_vld,
  output wire [31:0] phases0,
  output wire phases0_ap_vld,
  output wire [31:0] phases1,
  output wire phases1_ap_vld,
  output wire [31:0] phases2,
  output wire phases2_ap_vld,
  output wire [31:0] phases3,
  output wire phases3_ap_vld,
  output wire [31:0] status,
  output wire status_ap_vld
);
  typedef enum logic [1:0] {IDLE,ISSUE,DRAIN,REPORT} phase_t;
  phase_t phase;
  logic [1023:0] owner_q,aq_q,old_q,next_q;
  logic [2047:0] wq_q;
  logic [127:0] sa_q;
  logic [255:0] sw_q;
  logic [31:0] masks_q,status_q;
  logic [6:0] group_q;
  logic [9:0] tile_q;
  logic [26:0] sequence_q;
  logic [3:0] active_rows,received,ready_rows,commit_valid,protocol;
  logic [31:0] bad_q;
  logic [95:0] phases_q;
  logic [191:0] request_tag,commit_tag[0:3];
  logic [9:0] commit_tile[0:3];
  logic [7:0] commit_mask[0:3],commit_bad[0:3];
  logic [23:0] commit_phase[0:3];
  logic [255:0] commit_ps[0:3];
  logic [5:0] free_rows[0:3],reserved_rows[0:3],returned_rows[0:3];
  logic [2:0] trace_free[0:3];
  logic all_ready,all_free;
  wire issue_fire=phase==ISSUE && all_ready && ap_ce;
  assign ap_idle=phase==IDLE;
  assign ap_done=phase==REPORT;
  assign ap_ready=phase==REPORT && ap_continue && ap_ce;
  assign request_tag={32'd0,owner_q[703:672],owner_q[799:768],owner_q[863:832],
                      1'b0,sequence_q,36'd0};
  always_comb begin
    all_ready=1;all_free=1;
    for(int r=0;r<4;r++) begin
      if(active_rows[r] && !ready_rows[r]) all_ready=0;
      if(free_rows[r]!=35 || reserved_rows[r]!=0 || returned_rows[r]!=0 || trace_free[r]!=4 || commit_valid[r])all_free=0;
    end
  end
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
  assign echo14=owner_q[896 +:64];
  assign echo15=owner_q[960 +:64];
  assign next0=next_q[0 +:32];
  assign next1=next_q[32 +:32];
  assign next2=next_q[64 +:32];
  assign next3=next_q[96 +:32];
  assign next4=next_q[128 +:32];
  assign next5=next_q[160 +:32];
  assign next6=next_q[192 +:32];
  assign next7=next_q[224 +:32];
  assign next8=next_q[256 +:32];
  assign next9=next_q[288 +:32];
  assign next10=next_q[320 +:32];
  assign next11=next_q[352 +:32];
  assign next12=next_q[384 +:32];
  assign next13=next_q[416 +:32];
  assign next14=next_q[448 +:32];
  assign next15=next_q[480 +:32];
  assign next16=next_q[512 +:32];
  assign next17=next_q[544 +:32];
  assign next18=next_q[576 +:32];
  assign next19=next_q[608 +:32];
  assign next20=next_q[640 +:32];
  assign next21=next_q[672 +:32];
  assign next22=next_q[704 +:32];
  assign next23=next_q[736 +:32];
  assign next24=next_q[768 +:32];
  assign next25=next_q[800 +:32];
  assign next26=next_q[832 +:32];
  assign next27=next_q[864 +:32];
  assign next28=next_q[896 +:32];
  assign next29=next_q[928 +:32];
  assign next30=next_q[960 +:32];
  assign next31=next_q[992 +:32];
  assign bad0={24'd0,bad_q[0 +:8]};assign phases0={8'd0,phases_q[0 +:24]};
  assign bad1={24'd0,bad_q[8 +:8]};assign phases1={8'd0,phases_q[24 +:24]};
  assign bad2={24'd0,bad_q[16 +:8]};assign phases2={8'd0,phases_q[48 +:24]};
  assign bad3={24'd0,bad_q[24 +:8]};assign phases3={8'd0,phases_q[72 +:24]};
  assign status=status_q;
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
  assign echo14_ap_vld=phase==REPORT;
  assign echo15_ap_vld=phase==REPORT;
  assign next0_ap_vld=phase==REPORT;
  assign next1_ap_vld=phase==REPORT;
  assign next2_ap_vld=phase==REPORT;
  assign next3_ap_vld=phase==REPORT;
  assign next4_ap_vld=phase==REPORT;
  assign next5_ap_vld=phase==REPORT;
  assign next6_ap_vld=phase==REPORT;
  assign next7_ap_vld=phase==REPORT;
  assign next8_ap_vld=phase==REPORT;
  assign next9_ap_vld=phase==REPORT;
  assign next10_ap_vld=phase==REPORT;
  assign next11_ap_vld=phase==REPORT;
  assign next12_ap_vld=phase==REPORT;
  assign next13_ap_vld=phase==REPORT;
  assign next14_ap_vld=phase==REPORT;
  assign next15_ap_vld=phase==REPORT;
  assign next16_ap_vld=phase==REPORT;
  assign next17_ap_vld=phase==REPORT;
  assign next18_ap_vld=phase==REPORT;
  assign next19_ap_vld=phase==REPORT;
  assign next20_ap_vld=phase==REPORT;
  assign next21_ap_vld=phase==REPORT;
  assign next22_ap_vld=phase==REPORT;
  assign next23_ap_vld=phase==REPORT;
  assign next24_ap_vld=phase==REPORT;
  assign next25_ap_vld=phase==REPORT;
  assign next26_ap_vld=phase==REPORT;
  assign next27_ap_vld=phase==REPORT;
  assign next28_ap_vld=phase==REPORT;
  assign next29_ap_vld=phase==REPORT;
  assign next30_ap_vld=phase==REPORT;
  assign next31_ap_vld=phase==REPORT;
  assign bad0_ap_vld=phase==REPORT;
  assign bad1_ap_vld=phase==REPORT;
  assign bad2_ap_vld=phase==REPORT;
  assign bad3_ap_vld=phase==REPORT;
  assign phases0_ap_vld=phase==REPORT;
  assign phases1_ap_vld=phase==REPORT;
  assign phases2_ap_vld=phase==REPORT;
  assign phases3_ap_vld=phase==REPORT;
  assign status_ap_vld=phase==REPORT;
  for(genvar r=0;r<4;r++) begin:row
    tm4tn8_row_pipeline_v1 arithmetic (
      .clk(ap_clk),.rst_n(!ap_rst),.issue_valid(issue_fire && active_rows[r]),
      .issue_ready(ready_rows[r]),.issue_identity_tag(request_tag),.issue_tile(tile_q),
      .issue_lane_mask(masks_q[r*8 +:8]),.issue_trace(1'b0),.issue_trace_lane(3'd0),
      .issue_group(group_q),.issue_row(2'(r)),.issue_a8(aq_q[r*256 +:256]),
      .issue_w8(wq_q),.issue_old_ps(old_q[r*256 +:256]),.issue_sa(sa_q[r*32 +:32]),.issue_sw(sw_q),
      .commit_valid(commit_valid[r]),.commit_ready(phase==DRAIN && ap_ce),
      .commit_tag(commit_tag[r]),.commit_tile(commit_tile[r]),.commit_lane_mask(commit_mask[r]),
      .commit_bad_mask(commit_bad[r]),.commit_phase(commit_phase[r]),.commit_next_ps(commit_ps[r]),
      .trace_valid(),.trace_ready(1'b1),.trace_slot(),.trace_tag(),.trace_payload(),
      .trace_ack_valid(1'b0),.trace_ack_slot(2'd0),.trace_ack_tag(192'd0),.trace_ack_ok(1'b1),
      .result_free(free_rows[r]),.result_reserved(reserved_rows[r]),.result_returned(returned_rows[r]),
      .trace_free(trace_free[r]),.protocol_error(protocol[r]));
  end
  always_ff @(posedge ap_clk) begin
    if(ap_rst) begin
      phase<=IDLE;owner_q<=0;aq_q<=0;wq_q<=0;sa_q<=0;sw_q<=0;old_q<=0;next_q<=0;
      masks_q<=0;status_q<=0;group_q<=0;tile_q<=0;sequence_q<=0;active_rows<=0;
      received<=0;bad_q<=0;phases_q<=0;
    end else if(ap_ce) begin
      case(phase)
        IDLE: if(ap_start) begin
          owner_q<={owner15,owner14,owner13,owner12,owner11,owner10,owner9,owner8,owner7,owner6,owner5,owner4,owner3,owner2,owner1,owner0};aq_q<={aq15,aq14,aq13,aq12,aq11,aq10,aq9,aq8,aq7,aq6,aq5,aq4,aq3,aq2,aq1,aq0};wq_q<={wq31,wq30,wq29,wq28,wq27,wq26,wq25,wq24,wq23,wq22,wq21,wq20,wq19,wq18,wq17,wq16,wq15,wq14,wq13,wq12,wq11,wq10,wq9,wq8,wq7,wq6,wq5,wq4,wq3,wq2,wq1,wq0};sa_q<={sa3,sa2,sa1,sa0};sw_q<={sw7,sw6,sw5,sw4,sw3,sw2,sw1,sw0};
          old_q<={old31,old30,old29,old28,old27,old26,old25,old24,old23,old22,old21,old20,old19,old18,old17,old16,old15,old14,old13,old12,old11,old10,old9,old8,old7,old6,old5,old4,old3,old2,old1,old0};next_q<={old31,old30,old29,old28,old27,old26,old25,old24,old23,old22,old21,old20,old19,old18,old17,old16,old15,old14,old13,old12,old11,old10,old9,old8,old7,old6,old5,old4,old3,old2,old1,old0};masks_q<=lane_masks;group_q<=group[6:0];
          tile_q<=tile[9:0];sequence_q<=\sequence [26:0];
          for(int r=0;r<4;r++) active_rows[r]<=|lane_masks[r*8 +:8];
          received<=0;bad_q<=0;phases_q<={32{3'd4}};
          if(group>127 || tile>655 || \sequence >32'h7ffffff) begin status_q<=2;phase<=REPORT;end
          else begin status_q<=0;phase<=ISSUE;end
        end
        ISSUE: if(issue_fire) phase<=DRAIN;
        DRAIN: begin
          for(int r=0;r<4;r++) if(commit_valid[r]) begin
            if(!active_rows[r] || received[r] || commit_tile[r]!=tile_q || commit_mask[r]!=masks_q[r*8 +:8] ||
               commit_tag[r][159:64]!=request_tag[159:64] || commit_tag[r][62:36]!=sequence_q ||
               {commit_tag[r][160],commit_tag[r][16:11]}!=group_q ||
               commit_tag[r][27:26]!=r || commit_tag[r][167:164]!=1 || commit_tag[r][191:168]!=0)
              status_q<=2;
            received[r]<=1;next_q[r*256 +:256]<=commit_ps[r];
            bad_q[r*8 +:8]<=commit_bad[r];phases_q[r*24 +:24]<=commit_phase[r];
          end
          if((received&active_rows)==active_rows && all_free) begin
            if(|protocol)status_q<=2;
            else if(status_q==0 && |bad_q)status_q<=1;
            phase<=REPORT;
          end
        end
        REPORT: if(ap_continue) phase<=IDLE;
      endcase
    end
  end
endmodule
