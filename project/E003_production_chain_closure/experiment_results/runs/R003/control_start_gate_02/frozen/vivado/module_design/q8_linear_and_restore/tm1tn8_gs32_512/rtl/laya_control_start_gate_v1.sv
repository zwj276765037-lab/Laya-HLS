`timescale 1ns/1ps
// AXI-Lite proxy for the generated ap_ctrl_hs register bank.  It preserves
// the public control ABI and forwards every ordinary access unchanged.  A
// write that sets ap_start is forwarded only when the persistent 13-BO model
// binding accepts the current pointer snapshot; rejection returns SLVERR.
module laya_control_start_gate_v1 #(
  parameter int ADDR_WIDTH=4
)(
  input  logic clk,rst_n,
  input  logic [ADDR_WIDTH-1:0] s_awaddr,
  input  logic s_awvalid,
  output logic s_awready,
  input  logic [31:0] s_wdata,
  input  logic [3:0] s_wstrb,
  input  logic s_wvalid,
  output logic s_wready,
  output logic [1:0] s_bresp,
  output logic s_bvalid,
  input  logic s_bready,
  input  logic [ADDR_WIDTH-1:0] s_araddr,
  input  logic s_arvalid,
  output logic s_arready,
  output logic [31:0] s_rdata,
  output logic [1:0] s_rresp,
  output logic s_rvalid,
  input  logic s_rready,
  output logic [ADDR_WIDTH-1:0] m_awaddr,
  output logic m_awvalid,
  input  logic m_awready,
  output logic [31:0] m_wdata,
  output logic [3:0] m_wstrb,
  output logic m_wvalid,
  input  logic m_wready,
  input  logic [1:0] m_bresp,
  input  logic m_bvalid,
  output logic m_bready,
  output logic [ADDR_WIDTH-1:0] m_araddr,
  output logic m_arvalid,
  input  logic m_arready,
  input  logic [31:0] m_rdata,
  input  logic [1:0] m_rresp,
  input  logic m_rvalid,
  output logic m_rready,
  output logic host_start_valid,
  input  logic host_start_ready,
  output logic start_accepted,start_rejected,
  output logic write_idle,read_idle,
  output logic [31:0] forwarded_writes,rejected_starts
);
  typedef enum logic [2:0] {W_IDLE,W_DATA,W_SEND_AW,W_SEND_W,
    W_WAIT_B,W_REJECT_B} write_state_t;
  typedef enum logic [1:0] {R_IDLE,R_SEND_AR,R_WAIT_R} read_state_t;
  write_state_t write_state;
  read_state_t read_state;
  logic [ADDR_WIDTH-1:0] held_awaddr,held_araddr;
  logic [31:0] held_wdata;
  logic [3:0] held_wstrb;
  logic incoming_start;

  assign incoming_start=held_awaddr=='0 && s_wstrb[0] && s_wdata[0];
  assign host_start_valid=write_state==W_DATA && s_wvalid && incoming_start;
  assign start_accepted=host_start_valid && host_start_ready;
  assign start_rejected=host_start_valid && !host_start_ready;
  assign write_idle=write_state==W_IDLE;
  assign read_idle=read_state==R_IDLE;

  always_comb begin
    s_awready=write_state==W_IDLE;
    s_wready=write_state==W_DATA;
    s_bvalid=1'b0;s_bresp=2'b00;
    m_awaddr=held_awaddr;m_awvalid=write_state==W_SEND_AW;
    m_wdata=held_wdata;m_wstrb=held_wstrb;m_wvalid=write_state==W_SEND_W;
    m_bready=write_state==W_WAIT_B && s_bready;
    if(write_state==W_WAIT_B)begin
      s_bvalid=m_bvalid;s_bresp=m_bresp;
    end else if(write_state==W_REJECT_B)begin
      s_bvalid=1'b1;s_bresp=2'b10;
    end
    s_arready=read_state==R_IDLE;
    m_araddr=held_araddr;m_arvalid=read_state==R_SEND_AR;
    s_rvalid=read_state==R_WAIT_R && m_rvalid;
    s_rdata=m_rdata;s_rresp=m_rresp;
    m_rready=read_state==R_WAIT_R && s_rready;
  end

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      write_state<=W_IDLE;read_state<=R_IDLE;
      held_awaddr<='0;held_araddr<='0;held_wdata<=0;held_wstrb<=0;
      forwarded_writes<=0;rejected_starts<=0;
    end else begin
      case(write_state)
        W_IDLE:if(s_awvalid)begin held_awaddr<=s_awaddr;write_state<=W_DATA;end
        W_DATA:if(s_wvalid)begin
          held_wdata<=s_wdata;held_wstrb<=s_wstrb;
          if(incoming_start && !host_start_ready)begin
            write_state<=W_REJECT_B;rejected_starts<=rejected_starts+1'b1;
          end else write_state<=W_SEND_AW;
        end
        W_SEND_AW:if(m_awready)write_state<=W_SEND_W;
        W_SEND_W:if(m_wready)begin
          write_state<=W_WAIT_B;forwarded_writes<=forwarded_writes+1'b1;
        end
        W_WAIT_B:if(m_bvalid && s_bready)write_state<=W_IDLE;
        W_REJECT_B:if(s_bready)write_state<=W_IDLE;
        default:write_state<=W_IDLE;
      endcase
      case(read_state)
        R_IDLE:if(s_arvalid)begin held_araddr<=s_araddr;read_state<=R_SEND_AR;end
        R_SEND_AR:if(m_arready)read_state<=R_WAIT_R;
        R_WAIT_R:if(m_rvalid && s_rready)read_state<=R_IDLE;
        default:read_state<=R_IDLE;
      endcase
    end
  end
endmodule
