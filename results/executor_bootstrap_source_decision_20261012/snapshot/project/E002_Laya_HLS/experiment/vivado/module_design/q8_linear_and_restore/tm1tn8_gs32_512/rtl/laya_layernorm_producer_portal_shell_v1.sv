`timescale 1ns/1ps
// Production-side binding for the generated LayerNorm producer.  The private
// producer request is admitted only after the adapter has consumed a complete,
// successful provenance BEGIN response.  Destination writes pass through the
// persistent provenance monitor; completion delivery and real source read debt
// form the adapter fence used by END.
module laya_layernorm_producer_portal_shell_v1 (
  input  logic clk,rst_n,cancel,
  input  logic [63:0] monitored_bo_base,

  input  logic [511:0] provenance_cmd_din,
  input  logic provenance_cmd_write,
  output logic provenance_cmd_full_n,
  output logic [511:0] provenance_rsp_dout,
  output logic provenance_rsp_empty_n,
  input  logic provenance_rsp_read,

  input  logic [511:0] producer_request_dout,
  input  logic producer_request_empty_n,
  output logic producer_request_read,
  output logic [511:0] producer_completion_din,
  input  logic producer_completion_full_n,
  output logic producer_completion_write,

  input  logic source_query_valid,
  output logic source_query_ready,
  input  logic [8191:0] source_query_command,
  output logic source_query_granted,
  input  logic source_release_valid,
  output logic source_release_ready,
  input  logic [8191:0] source_release_command,
  input  logic source_release_drained,
  output logic source_lease_active,

  output logic [63:0] source_axi_araddr,
  output logic [7:0] source_axi_arlen,
  output logic [2:0] source_axi_arsize,
  output logic [1:0] source_axi_arburst,
  output logic source_axi_arvalid,
  input  logic source_axi_arready,
  input  logic [511:0] source_axi_rdata,
  input  logic [1:0] source_axi_rresp,
  input  logic source_axi_rlast,
  input  logic source_axi_rvalid,
  output logic source_axi_rready,

  output logic [63:0] destination_axi_awaddr,
  output logic [7:0] destination_axi_awlen,
  output logic [2:0] destination_axi_awsize,
  output logic [1:0] destination_axi_awburst,
  output logic destination_axi_awvalid,
  input  logic destination_axi_awready,
  output logic [511:0] destination_axi_wdata,
  output logic [63:0] destination_axi_wstrb,
  output logic destination_axi_wlast,
  output logic destination_axi_wvalid,
  input  logic destination_axi_wready,
  input  logic [1:0] destination_axi_bresp,
  input  logic destination_axi_bvalid,
  output logic destination_axi_bready,

  output logic base_configured,
  output logic adapter_pending_zero,
  output logic job_active,
  output logic shell_protocol_error,
  output logic ledger_protocol_error,
  output logic ledger_scope_active,
  output logic ledger_domain_drained,
  output logic monitor_scope_active,
  output logic monitor_drained,
  output logic monitor_coverage_complete,
  output logic [15:0] monitor_status,
  output logic [63:0] monitor_observed0,
  output logic [31:0] forwarded_aw,forwarded_w,retired_b,
  output logic [31:0] source_outstanding_beats,
  output logic [63:0] last_event_seq,
  output logic [5:0] active_owners,published_owners,
  output logic [31:0] accepted_requests,retired_responses,
  output logic [31:0] accepted_events,semantic_rejections,terminal_tasks
);
  localparam logic [31:0] LPE1_MAGIC=32'h3145504c;
  localparam logic [31:0] LPC1_MAGIC=32'h3143504c;
  localparam logic [31:0] LPA1_MAGIC=32'h3141504c;
  localparam logic [15:0] PROVENANCE_VERSION=1;
  localparam logic [15:0] BEGIN_EVENT=2;

  typedef enum logic [2:0] {
    CFG_CAPTURE,CFG_SEND,CFG_WAIT_B,CFG_DONE,CFG_ERROR
  } cfg_state_t;
  cfg_state_t cfg_state;
  logic [63:0] bound_bo_base;
  logic [1:0] cfg_index;
  logic cfg_aw_done,cfg_w_done,config_error;
  logic control_awvalid,control_awready;
  logic [5:0] control_awaddr;
  logic control_wvalid,control_wready;
  logic [31:0] control_wdata;
  logic [3:0] control_wstrb;
  logic control_bvalid,control_bready;
  logic [1:0] control_bresp;
  logic control_arready,control_rvalid;
  logic [31:0] control_rdata;
  logic [1:0] control_rresp;

  always_comb begin
    control_awvalid=cfg_state==CFG_SEND && !cfg_aw_done;
    control_wvalid=cfg_state==CFG_SEND && !cfg_w_done;
    control_wstrb=4'hf;
    control_bready=cfg_state==CFG_WAIT_B;
    case(cfg_index)
      0: begin control_awaddr=6'h10;control_wdata=bound_bo_base[31:0];end
      1: begin control_awaddr=6'h14;control_wdata=bound_bo_base[63:32];end
      2: begin control_awaddr=6'h1c;control_wdata=bound_bo_base[31:0];end
      default: begin control_awaddr=6'h20;control_wdata=bound_bo_base[63:32];end
    endcase
  end

  always_ff @(posedge clk) begin
    if(!rst_n)begin
      cfg_state<=CFG_CAPTURE;bound_bo_base<=0;cfg_index<=0;
      cfg_aw_done<=0;cfg_w_done<=0;config_error<=0;base_configured<=0;
    end else begin
      case(cfg_state)
        CFG_CAPTURE: begin
          bound_bo_base<=monitored_bo_base;cfg_index<=0;
          cfg_aw_done<=0;cfg_w_done<=0;cfg_state<=CFG_SEND;
        end
        CFG_SEND: begin
          if(control_awvalid && control_awready)cfg_aw_done<=1;
          if(control_wvalid && control_wready)cfg_w_done<=1;
          if((cfg_aw_done || (control_awvalid && control_awready)) &&
             (cfg_w_done || (control_wvalid && control_wready)))
            cfg_state<=CFG_WAIT_B;
        end
        CFG_WAIT_B: if(control_bvalid && control_bready)begin
          if(control_bresp!=0)begin
            config_error<=1;cfg_state<=CFG_ERROR;
          end else if(cfg_index==3)begin
            base_configured<=1;cfg_state<=CFG_DONE;
          end else begin
            cfg_index<=cfg_index+1'b1;cfg_aw_done<=0;cfg_w_done<=0;
            cfg_state<=CFG_SEND;
          end
        end
        CFG_DONE: if(monitored_bo_base!=bound_bo_base)begin
          base_configured<=0;config_error<=1;cfg_state<=CFG_ERROR;
        end
        default: begin base_configured<=0;config_error<=1;end
      endcase
    end
  end

  // One request and completion slot. No request beat reaches the generated
  // engine until the entire request agrees with the immutable accepted BEGIN.
  logic [8191:0] accepted_begin_packet,request_packet;
  logic [4095:0] completion_packet;
  logic [2:0] provenance_rsp_beat;
  logic [511:0] rsp_header;
  logic begin_grant_pending;
  logic [63:0] begin_event_seq;
  logic [4:0] request_capture_beat;
  logic [3:0] producer_request_beat,producer_completion_beat;
  logic [3:0] completion_capture_beat;
  logic request_loaded,request_verified,completion_loaded,completion_verified;
  logic fifo_protocol_error;
  logic engine_request_empty_n,engine_request_read;
  logic [511:0] engine_request_dout,engine_completion_din;
  logic engine_completion_full_n,engine_completion_write;

  function automatic logic request_begin_bound(input logic [8191:0] p,
                                               input logic [8191:0] b);
    logic [15:0] rows;
    rows={8'd0,p[159*8+:8]};
    return p[0+:32]==LPE1_MAGIC && p[4*8+:16]==1 &&
      p[6*8+:16]==16 && p[8*8+:16]==1 && p[12*8+:16]==8 &&
      p[16*8+:64]!=0 && p[24*8+:64]==b[8*8+:64] &&
      p[64*8+:96*8]==b[64*8+:96*8] &&
      p[160*8+:416*8]==b[160*8+:416*8] &&
      b[576*8+:8]==1 && p[584*8+:64]==b[608*8+:64] &&
      p[596*8+:8]==b[614*8+:8] &&
      p[598*8+:8]==b[636*8+:8] &&
      p[592*8+:16]==b[632*8+:16] &&
      p[159*8+:8]!=0 &&
      p[656*8+:32]==b[580*8+:32] && p[660*8+:8]==b[578*8+:8] &&
      p[648*8+:64]==b[640*8+:64] &&
      p[616*8+:64]==b[864*8+:64] &&
      p[604*8+:32]==b[872*8+:32] && rows==b[876*8+:16] &&
      b[878*8+:16]==1 &&
      (rows==1 ? b[880*8+:64]==0 : p[632*8+:64]==b[880*8+:64]) &&
      64'(p[604*8+:32])*64'(rows)==b[896*8+:64] &&
      b[904*8+:24]==24'h00ff00 &&
      b[635*8+:8]==0 && b[634*8+:8]==1;
  endfunction

  function automatic logic completion_request_bound(input logic [4095:0] c,
                                                    input logic [8191:0] p);
    logic [63:0] expected_bytes;
    expected_bytes=64'(p[656*8+:32])*4;
    return c[0+:32]==LPC1_MAGIC && c[4*8+:16]==1 &&
      c[6*8+:16]==8 && c[8*8+:16]==1 && c[10*8+:16]<=8 &&
      c[12*8+:8]<=3 && c[13*8+:8]==1 && c[14*8+:16]==0 &&
      c[16*8+:128]==p[16*8+:128] &&
      c[64*8+:96*8]==p[64*8+:96*8] &&
      c[160*8+:128]==p[576*8+:128] &&
      c[176*8+:8]==p[597*8+:8] && c[177*8+:8]==p[598*8+:8] &&
      c[178*8+:8]==p[595*8+:8] && c[179*8+:8]==p[596*8+:8] &&
      c[180*8+:24]==p[592*8+:24] && c[183*8+:8]==0 &&
      c[184*8+:64]==p[600*8+:64] &&
      c[192*8+:256]==p[608*8+:256] && c[224*8+:288*8]==0 &&
      c[48*8+:64]<=expected_bytes && c[56*8+:64]<=expected_bytes &&
      (c[10*8+:16]==0 ?
        (c[12*8+:8]==p[660*8+:8] && c[36*8+:32]==p[656*8+:32] &&
         c[32*8+:32]==0 && c[40*8+:64]==64'hffffffffffffffff &&
         c[48*8+:64]==expected_bytes && c[56*8+:64]==expected_bytes) :
        (c[12*8+:8]==0 && c[36*8+:32]==0));
  endfunction

  assign producer_request_read=producer_request_empty_n && base_configured &&
    !config_error && begin_grant_pending && !job_active && !request_loaded &&
    (request_capture_beat!=0 || !cancel);
  assign engine_request_empty_n=request_loaded && request_verified;
  assign engine_request_dout=request_packet[producer_request_beat*512+:512];
  assign engine_completion_full_n=job_active && !completion_loaded;
  assign producer_completion_din=completion_packet[producer_completion_beat*512+:512];
  assign producer_completion_write=completion_loaded && completion_verified &&
    producer_completion_full_n;

  always_ff @(posedge clk) begin
    if(!rst_n)begin
      provenance_rsp_beat<=0;rsp_header<=0;
      begin_grant_pending<=0;begin_event_seq<=0;
      request_capture_beat<=0;producer_request_beat<=0;
      completion_capture_beat<=0;producer_completion_beat<=0;
      request_packet<=0;completion_packet<=0;
      request_loaded<=0;request_verified<=0;
      completion_loaded<=0;completion_verified<=0;
      job_active<=0;fifo_protocol_error<=0;
    end else begin
      if(provenance_rsp_read && provenance_rsp_empty_n)begin
        if(provenance_rsp_beat==0)rsp_header<=provenance_rsp_dout;
        if(provenance_rsp_beat==7)begin
          provenance_rsp_beat<=0;
          if(rsp_header[0+:32]!=LPA1_MAGIC || rsp_header[4*8+:16]!=1)
            fifo_protocol_error<=1;
          else if(rsp_header[6*8+:16]==BEGIN_EVENT &&
                  rsp_header[24*8+:16]==0 && rsp_header[26*8+1])begin
            if(begin_grant_pending || job_active || request_loaded ||
               request_capture_beat!=0 ||
               rsp_header[8*8+:64]!=accepted_begin_packet[8*8+:64])
              fifo_protocol_error<=1;
            else begin
              begin_grant_pending<=1;
              begin_event_seq<=rsp_header[8*8+:64];
            end
          end else if(rsp_header[6*8+:16]==3 &&
                      rsp_header[16*8+:64]==begin_event_seq &&
                      rsp_header[26*8] && !rsp_header[26*8+1])
            begin_grant_pending<=0;
        end else provenance_rsp_beat<=provenance_rsp_beat+1'b1;
      end
      if(producer_request_read)begin
        request_packet[request_capture_beat*512+:512]<=producer_request_dout;
        if(request_capture_beat==15)begin
          request_capture_beat<=0;request_loaded<=1;
        end else request_capture_beat<=request_capture_beat+1'b1;
      end
      if(request_loaded && !request_verified && !job_active &&
         !fifo_protocol_error)begin
        if(!request_begin_bound(request_packet,accepted_begin_packet))
          fifo_protocol_error<=1;
        else begin
          request_verified<=1;job_active<=1;begin_grant_pending<=0;
        end
      end
      if(engine_request_read && engine_request_empty_n)begin
        if(producer_request_beat==15)begin
          producer_request_beat<=0;request_verified<=0;
        end else producer_request_beat<=producer_request_beat+1'b1;
      end
      if(engine_completion_write && engine_completion_full_n)begin
        completion_packet[completion_capture_beat*512+:512]<=engine_completion_din;
        if(completion_capture_beat==7)begin
          completion_capture_beat<=0;completion_loaded<=1;
        end else completion_capture_beat<=completion_capture_beat+1'b1;
      end
      if(completion_loaded && !completion_verified && !fifo_protocol_error)begin
        if(!completion_request_bound(completion_packet,request_packet))
          fifo_protocol_error<=1;
        else completion_verified<=1;
      end
      if(producer_completion_write)begin
        if(producer_completion_beat==7)begin
          producer_completion_beat<=0;job_active<=0;
          completion_loaded<=0;completion_verified<=0;request_loaded<=0;
        end else producer_completion_beat<=producer_completion_beat+1'b1;
      end
    end
  end

  logic engine_source_awvalid,engine_source_wvalid,engine_source_bready;
  logic [63:0] engine_source_awaddr;
  logic [7:0] engine_source_awlen;
  logic [2:0] engine_source_awsize;
  logic [1:0] engine_source_awburst;
  logic [511:0] engine_source_wdata;
  logic [63:0] engine_source_wstrb;
  logic engine_source_wlast;
  logic engine_destination_arvalid,engine_destination_rready;
  logic [63:0] engine_destination_araddr;
  logic [7:0] engine_destination_arlen;
  logic [2:0] engine_destination_arsize;
  logic [1:0] engine_destination_arburst;
  logic axi_protocol_error,source_outstanding_burst;
  logic source_ar_handshake,source_r_handshake;

  assign source_ar_handshake=source_axi_arvalid && source_axi_arready;
  assign source_r_handshake=source_axi_rvalid && source_axi_rready;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      source_outstanding_beats<=0;source_outstanding_burst<=0;
      axi_protocol_error<=0;
    end else begin
      if(base_configured && (engine_source_awvalid || engine_source_wvalid ||
                             engine_destination_arvalid))
        axi_protocol_error<=1;
      if(source_ar_handshake && source_outstanding_burst &&
         !(source_r_handshake && source_axi_rlast))
        axi_protocol_error<=1;
      if(source_r_handshake)begin
        if(!source_outstanding_burst || source_outstanding_beats==0 ||
           source_axi_rresp!=0 ||
           source_axi_rlast!=(source_outstanding_beats==1))
          axi_protocol_error<=1;
      end
      case({source_ar_handshake,source_r_handshake})
        2'b10: source_outstanding_beats<=source_outstanding_beats+
                 32'(source_axi_arlen)+1'b1;
        2'b01: if(source_outstanding_beats!=0)
                 source_outstanding_beats<=source_outstanding_beats-1'b1;
        2'b11: if(source_outstanding_beats!=0)
                 source_outstanding_beats<=source_outstanding_beats+
                   32'(source_axi_arlen);
        default: ;
      endcase
      if(source_ar_handshake && !(source_r_handshake && source_axi_rlast))
        source_outstanding_burst<=1;
      else if(!source_ar_handshake && source_r_handshake && source_axi_rlast)
        source_outstanding_burst<=0;
    end
  end

  assign adapter_pending_zero=base_configured && !config_error && !job_active &&
      !request_loaded && request_capture_beat==0 &&
      !completion_loaded && completion_capture_beat==0 &&
      producer_request_beat==0 && producer_completion_beat==0 &&
      source_outstanding_beats==0 && !source_outstanding_burst &&
      !source_axi_arvalid && !engine_source_awvalid && !engine_source_wvalid &&
      !destination_axi_awvalid && !destination_axi_wvalid &&
      !engine_destination_arvalid && !engine_completion_write;
  assign shell_protocol_error=config_error || fifo_protocol_error ||
                              axi_protocol_error;

  logic transport_busy,cancel_pending;
  logic [63:0] monitor_observed1;
  logic [31:0] rejected_transactions;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;
  logic [63:0] engine_destination_awaddr;
  logic [7:0] engine_destination_awlen;
  logic [2:0] engine_destination_awsize;
  logic [1:0] engine_destination_awburst;
  logic engine_destination_awvalid,engine_destination_awready;
  logic [511:0] engine_destination_wdata;
  logic [63:0] engine_destination_wstrb;
  logic engine_destination_wlast,engine_destination_wvalid;
  logic engine_destination_wready;
  logic [1:0] engine_destination_bresp;
  logic engine_destination_bvalid,engine_destination_bready;
  laya_generated_provenance_axi_portal_v1 portal(
    .clk,.rst_n,.cancel,
    .provenance_cmd_din,.provenance_cmd_write,.provenance_cmd_full_n,
    .provenance_rsp_dout,.provenance_rsp_empty_n,.provenance_rsp_read,
    .monitored_bo_base(bound_bo_base),.adapter_pending_zero,
    .accepted_begin_packet,
    .source_query_valid,.source_query_ready,.source_query_command,
    .source_query_granted,.source_release_valid,.source_release_ready,
    .source_release_command,.source_release_drained,.source_lease_active,
    .s_axi_awaddr(engine_destination_awaddr),
    .s_axi_awlen(engine_destination_awlen),
    .s_axi_awsize(engine_destination_awsize),
    .s_axi_awburst(engine_destination_awburst),
    .s_axi_awvalid(engine_destination_awvalid),
    .s_axi_awready(engine_destination_awready),
    .s_axi_wdata(engine_destination_wdata),
    .s_axi_wstrb(engine_destination_wstrb),
    .s_axi_wlast(engine_destination_wlast),
    .s_axi_wvalid(engine_destination_wvalid),
    .s_axi_wready(engine_destination_wready),
    .s_axi_bresp(engine_destination_bresp),
    .s_axi_bvalid(engine_destination_bvalid),
    .s_axi_bready(engine_destination_bready),
    .m_axi_awaddr(destination_axi_awaddr),.m_axi_awlen(destination_axi_awlen),
    .m_axi_awsize(destination_axi_awsize),
    .m_axi_awburst(destination_axi_awburst),
    .m_axi_awvalid(destination_axi_awvalid),
    .m_axi_awready(destination_axi_awready),
    .m_axi_wdata(destination_axi_wdata),.m_axi_wstrb(destination_axi_wstrb),
    .m_axi_wlast(destination_axi_wlast),
    .m_axi_wvalid(destination_axi_wvalid),
    .m_axi_wready(destination_axi_wready),
    .m_axi_bresp(destination_axi_bresp),.m_axi_bvalid(destination_axi_bvalid),
    .m_axi_bready(destination_axi_bready),
    .transport_busy,.cancel_pending,.protocol_error(ledger_protocol_error),
    .scope_active(ledger_scope_active),.domain_drained(ledger_domain_drained),
    .monitor_scope_active,.monitor_drained,.monitor_coverage_complete,
    .monitor_status,.monitor_observed0,.monitor_observed1,
    .last_event_seq,.active_owners,.published_owners,
    .accepted_requests,.retired_responses,.accepted_events,
    .semantic_rejections,.terminal_tasks,
    .forwarded_aw,.forwarded_w,.retired_b,.rejected_transactions,
    .command_fifo_occupancy,.response_fifo_occupancy
  );

  laya_layernorm_producer_engine engine(
    .ap_clk(clk),.ap_rst_n(rst_n),
    .m_axi_source_AWVALID(engine_source_awvalid),.m_axi_source_AWREADY(1'b0),
    .m_axi_source_AWADDR(engine_source_awaddr),.m_axi_source_AWID(),
    .m_axi_source_AWLEN(engine_source_awlen),.m_axi_source_AWSIZE(engine_source_awsize),
    .m_axi_source_AWBURST(engine_source_awburst),.m_axi_source_AWLOCK(),
    .m_axi_source_AWCACHE(),.m_axi_source_AWPROT(),.m_axi_source_AWQOS(),
    .m_axi_source_AWREGION(),.m_axi_source_AWUSER(),
    .m_axi_source_WVALID(engine_source_wvalid),.m_axi_source_WREADY(1'b0),
    .m_axi_source_WDATA(engine_source_wdata),.m_axi_source_WSTRB(engine_source_wstrb),
    .m_axi_source_WLAST(engine_source_wlast),.m_axi_source_WID(),
    .m_axi_source_WUSER(),
    .m_axi_source_ARVALID(source_axi_arvalid),.m_axi_source_ARREADY(source_axi_arready),
    .m_axi_source_ARADDR(source_axi_araddr),.m_axi_source_ARID(),
    .m_axi_source_ARLEN(source_axi_arlen),.m_axi_source_ARSIZE(source_axi_arsize),
    .m_axi_source_ARBURST(source_axi_arburst),.m_axi_source_ARLOCK(),
    .m_axi_source_ARCACHE(),.m_axi_source_ARPROT(),.m_axi_source_ARQOS(),
    .m_axi_source_ARREGION(),.m_axi_source_ARUSER(),
    .m_axi_source_RVALID(source_axi_rvalid),.m_axi_source_RREADY(source_axi_rready),
    .m_axi_source_RDATA(source_axi_rdata),.m_axi_source_RLAST(source_axi_rlast),
    .m_axi_source_RID(1'b0),.m_axi_source_RUSER(1'b0),
    .m_axi_source_RRESP(source_axi_rresp),.m_axi_source_BVALID(1'b0),
    .m_axi_source_BREADY(engine_source_bready),.m_axi_source_BRESP(2'b11),
    .m_axi_source_BID(1'b0),.m_axi_source_BUSER(1'b0),
    .m_axi_destination_AWVALID(engine_destination_awvalid),
    .m_axi_destination_AWREADY(engine_destination_awready),
    .m_axi_destination_AWADDR(engine_destination_awaddr),.m_axi_destination_AWID(),
    .m_axi_destination_AWLEN(engine_destination_awlen),
    .m_axi_destination_AWSIZE(engine_destination_awsize),
    .m_axi_destination_AWBURST(engine_destination_awburst),
    .m_axi_destination_AWLOCK(),.m_axi_destination_AWCACHE(),
    .m_axi_destination_AWPROT(),.m_axi_destination_AWQOS(),
    .m_axi_destination_AWREGION(),.m_axi_destination_AWUSER(),
    .m_axi_destination_WVALID(engine_destination_wvalid),
    .m_axi_destination_WREADY(engine_destination_wready),
    .m_axi_destination_WDATA(engine_destination_wdata),
    .m_axi_destination_WSTRB(engine_destination_wstrb),
    .m_axi_destination_WLAST(engine_destination_wlast),.m_axi_destination_WID(),
    .m_axi_destination_WUSER(),.m_axi_destination_ARVALID(engine_destination_arvalid),
    .m_axi_destination_ARREADY(1'b0),.m_axi_destination_ARADDR(engine_destination_araddr),
    .m_axi_destination_ARID(),.m_axi_destination_ARLEN(engine_destination_arlen),
    .m_axi_destination_ARSIZE(engine_destination_arsize),
    .m_axi_destination_ARBURST(engine_destination_arburst),
    .m_axi_destination_ARLOCK(),.m_axi_destination_ARCACHE(),
    .m_axi_destination_ARPROT(),.m_axi_destination_ARQOS(),
    .m_axi_destination_ARREGION(),.m_axi_destination_ARUSER(),
    .m_axi_destination_RVALID(1'b0),.m_axi_destination_RREADY(engine_destination_rready),
    .m_axi_destination_RDATA(512'd0),.m_axi_destination_RLAST(1'b0),
    .m_axi_destination_RID(1'b0),.m_axi_destination_RUSER(1'b0),
    .m_axi_destination_RRESP(2'b11),
    .m_axi_destination_BVALID(engine_destination_bvalid),
    .m_axi_destination_BREADY(engine_destination_bready),
    .m_axi_destination_BRESP(engine_destination_bresp),
    .m_axi_destination_BID(1'b0),.m_axi_destination_BUSER(1'b0),
    .request_stream_dout(engine_request_dout),
    .request_stream_empty_n(engine_request_empty_n),
    .request_stream_read(engine_request_read),
    .completion_stream_din(engine_completion_din),
    .completion_stream_full_n(engine_completion_full_n),
    .completion_stream_write(engine_completion_write),
    .s_axi_control_AWVALID(control_awvalid),.s_axi_control_AWREADY(control_awready),
    .s_axi_control_AWADDR(control_awaddr),.s_axi_control_WVALID(control_wvalid),
    .s_axi_control_WREADY(control_wready),.s_axi_control_WDATA(control_wdata),
    .s_axi_control_WSTRB(control_wstrb),.s_axi_control_ARVALID(1'b0),
    .s_axi_control_ARREADY(control_arready),.s_axi_control_ARADDR(6'd0),
    .s_axi_control_RVALID(control_rvalid),.s_axi_control_RREADY(1'b1),
    .s_axi_control_RDATA(control_rdata),.s_axi_control_RRESP(control_rresp),
    .s_axi_control_BVALID(control_bvalid),.s_axi_control_BREADY(control_bready),
    .s_axi_control_BRESP(control_bresp)
  );
endmodule
