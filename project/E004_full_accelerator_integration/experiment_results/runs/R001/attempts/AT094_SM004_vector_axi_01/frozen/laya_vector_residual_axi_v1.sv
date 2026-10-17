// Fixed-graph residual service: two independent 512-bit read ports and one
// 512-bit write port. One AXI burst per command, one beat buffered per source.
// No owner/lease/descriptor portal is present; upstream sequences this service.
module laya_vector_residual_axi_v1 (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         cfg_valid,
    output logic         cfg_ready,
    input  logic [63:0]  cfg_src0_base,
    input  logic [63:0]  cfg_src1_base,
    input  logic [63:0]  cfg_dst_base,
    input  logic [31:0]  cfg_elements,
    output logic         done_valid,
    input  logic         done_ready,
    output logic [3:0]   done_status,
    output logic         m_ar0valid,
    input  logic         m_ar0ready,
    output logic [63:0]  m_ar0addr,
    output logic [7:0]   m_ar0len,
    output logic [2:0]   m_ar0size,
    output logic [1:0]   m_ar0burst,
    input  logic         m_r0valid,
    output logic         m_r0ready,
    input  logic [511:0] m_r0data,
    input  logic [1:0]   m_r0resp,
    input  logic         m_r0last,
    output logic         m_ar1valid,
    input  logic         m_ar1ready,
    output logic [63:0]  m_ar1addr,
    output logic [7:0]   m_ar1len,
    output logic [2:0]   m_ar1size,
    output logic [1:0]   m_ar1burst,
    input  logic         m_r1valid,
    output logic         m_r1ready,
    input  logic [511:0] m_r1data,
    input  logic [1:0]   m_r1resp,
    input  logic         m_r1last,
    output logic         m_awvalid,
    input  logic         m_awready,
    output logic [63:0]  m_awaddr,
    output logic [7:0]   m_awlen,
    output logic [2:0]   m_awburst,
    output logic [2:0]   m_awsize,
    output logic         m_wvalid,
    input  logic         m_wready,
    output logic [511:0] m_wdata,
    output logic [63:0]  m_wstrb,
    output logic         m_wlast,
    input  logic         m_bvalid,
    output logic         m_bready,
    input  logic [1:0]   m_bresp
);
  typedef enum logic [2:0] {IDLE,CMD,LOAD,ISSUE,WAIT_RESULTS,WRITE,WAIT_B,DONE} state_t;
  state_t state;
  logic [63:0] src0_base,src1_base,dst_base;
  logic [8:0] beat_count,beat_index;
  logic ar0_sent,ar1_sent,aw_sent,have0,have1,fault;
  logic [511:0] src0_beat,src1_beat,out_beat;
  logic [4:0] issue_index,retire_index;
  logic add_in_valid,add_in_ready,add_out_valid,add_out_ready;
  logic [31:0] add_a,add_b,add_bits;
  logic [64:0] end0,end1,endd;
  logic bad_cfg;

  always_comb begin
    end0={1'b0,cfg_src0_base}+{31'b0,cfg_elements,2'b0};
    end1={1'b0,cfg_src1_base}+{31'b0,cfg_elements,2'b0};
    endd={1'b0,cfg_dst_base}+{31'b0,cfg_elements,2'b0};
    bad_cfg=(cfg_elements==0 || cfg_elements>4096 || cfg_elements[3:0]!=0 ||
      cfg_src0_base[5:0]!=0 || cfg_src1_base[5:0]!=0 || cfg_dst_base[5:0]!=0 ||
      end0[64] || end1[64] || endd[64] ||
      (cfg_src0_base<end1 && cfg_src1_base<end0) ||
      (cfg_src0_base<endd && cfg_dst_base<end0) ||
      (cfg_src1_base<endd && cfg_dst_base<end1));
  end

  assign cfg_ready=(state==IDLE);
  assign done_valid=(state==DONE);
  assign m_ar0valid=(state==CMD && !ar0_sent);
  assign m_ar1valid=(state==CMD && !ar1_sent);
  assign m_awvalid=(state==CMD && !aw_sent);
  assign m_ar0addr=src0_base;
  assign m_ar1addr=src1_base;
  assign m_awaddr=dst_base;
  assign m_ar0len=beat_count[7:0]-1'b1;
  assign m_ar1len=beat_count[7:0]-1'b1;
  assign m_awlen=beat_count[7:0]-1'b1;
  assign m_ar0size=3'd6;
  assign m_ar1size=3'd6;
  assign m_awsize=3'd6;
  assign m_ar0burst=2'b01;
  assign m_ar1burst=2'b01;
  assign m_awburst=2'b01;
  assign m_r0ready=(state==LOAD && !have0);
  assign m_r1ready=(state==LOAD && !have1);
  assign add_in_valid=(state==ISSUE && issue_index<16);
  assign add_a=src0_beat[issue_index*32 +: 32];
  assign add_b=src1_beat[issue_index*32 +: 32];
  assign add_out_ready=(state==ISSUE || state==WAIT_RESULTS);
  assign m_wvalid=(state==WRITE);
  assign m_wdata=out_beat;
  assign m_wstrb=64'hffffffffffffffff;
  assign m_wlast=(beat_index==beat_count-1'b1);
  assign m_bready=(state==WAIT_B);

  laya_vector_add_stream_v1 add (
    .clk(clk),.rst_n(rst_n),.in_valid(add_in_valid),.in_ready(add_in_ready),
    .a(add_a),.b(add_b),.out_valid(add_out_valid),.out_ready(add_out_ready),.bits(add_bits));

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state<=IDLE; src0_base<=0; src1_base<=0; dst_base<=0;
      beat_count<=0; beat_index<=0; ar0_sent<=0; ar1_sent<=0; aw_sent<=0;
      have0<=0; have1<=0; fault<=0; done_status<=0;
      src0_beat<=0; src1_beat<=0; out_beat<=0;
      issue_index<=0; retire_index<=0;
    end else begin
      case (state)
        IDLE: if (cfg_valid) begin
          done_status<=0;
          fault<=0;
          if (bad_cfg) begin
            done_status<=4'd7;
            state<=DONE;
          end else begin
            src0_base<=cfg_src0_base;
            src1_base<=cfg_src1_base;
            dst_base<=cfg_dst_base;
            beat_count<=cfg_elements[12:4];
            beat_index<=0;
            ar0_sent<=0; ar1_sent<=0; aw_sent<=0;
            state<=CMD;
          end
        end
        CMD: begin
          if (m_ar0valid && m_ar0ready) ar0_sent<=1;
          if (m_ar1valid && m_ar1ready) ar1_sent<=1;
          if (m_awvalid && m_awready) aw_sent<=1;
          if (ar0_sent && ar1_sent && aw_sent) begin
            have0<=0; have1<=0;
            state<=LOAD;
          end
        end
        LOAD: begin
          if (m_r0valid && m_r0ready) begin
            src0_beat<=m_r0data; have0<=1;
            if (m_r0resp!=0 || m_r0last!=(beat_index==beat_count-1'b1)) fault<=1;
          end
          if (m_r1valid && m_r1ready) begin
            src1_beat<=m_r1data; have1<=1;
            if (m_r1resp!=0 || m_r1last!=(beat_index==beat_count-1'b1)) fault<=1;
          end
          if (have0 && have1) begin
            issue_index<=0; retire_index<=0; out_beat<=0;
            state<=ISSUE;
          end
        end
        ISSUE: begin
          if (add_in_valid && add_in_ready) issue_index<=issue_index+1'b1;
          if (add_out_valid && add_out_ready) begin
            out_beat[retire_index*32 +: 32]<=add_bits;
            retire_index<=retire_index+1'b1;
          end
          if (issue_index==16) state<=WAIT_RESULTS;
        end
        WAIT_RESULTS: begin
          if (add_out_valid && add_out_ready) begin
            out_beat[retire_index*32 +: 32]<=add_bits;
            retire_index<=retire_index+1'b1;
          end
          if (retire_index==16) state<=WRITE;
        end
        WRITE: if (m_wvalid && m_wready) begin
          if (m_wlast) state<=WAIT_B;
          else begin
            beat_index<=beat_index+1'b1;
            have0<=0; have1<=0;
            state<=LOAD;
          end
        end
        WAIT_B: if (m_bvalid && m_bready) begin
          done_status<=(fault || m_bresp!=0) ? 4'd8 : 4'd0;
          state<=DONE;
        end
        DONE: if (done_ready) state<=IDLE;
        default: state<=IDLE;
      endcase
    end
  end
endmodule
