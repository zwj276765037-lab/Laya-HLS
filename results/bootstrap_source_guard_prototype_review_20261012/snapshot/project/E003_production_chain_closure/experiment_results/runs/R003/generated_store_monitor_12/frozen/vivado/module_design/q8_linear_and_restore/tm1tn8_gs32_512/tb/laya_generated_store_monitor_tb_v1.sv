`timescale 1ns/1ps
module laya_generated_store_monitor_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;

  logic [511:0] provenance_cmd_din,provenance_rsp_dout;
  logic provenance_cmd_write=0,provenance_cmd_full_n;
  logic provenance_rsp_empty_n,provenance_rsp_read=0;
  logic [63:0] monitored_bo_base=BO_BASE;
  logic adapter_pending_zero=1;
  logic source_query_valid=0,source_query_ready,source_query_granted;
  logic [8191:0] source_query_command=0;
  logic source_release_valid=0,source_release_ready,source_release_drained=1;
  logic [8191:0] source_release_command=0;
  logic source_lease_active;
  logic [8191:0] accepted_begin_packet;
  logic [63:0] s_axi_awaddr=0;
  logic [7:0] s_axi_awlen=0;
  logic [2:0] s_axi_awsize=6;
  logic [1:0] s_axi_awburst=1;
  logic s_axi_awvalid=0,s_axi_awready;
  logic [511:0] s_axi_wdata=0;
  logic [63:0] s_axi_wstrb=0;
  logic s_axi_wlast=1,s_axi_wvalid=0,s_axi_wready;
  logic [1:0] s_axi_bresp;
  logic s_axi_bvalid,s_axi_bready=0;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid,m_axi_awready=1;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic m_axi_wlast,m_axi_wvalid,m_axi_wready=1;
  logic [1:0] m_axi_bresp=0;
  logic m_axi_bvalid=0,m_axi_bready;
  logic transport_busy,cancel_pending,protocol_error,scope_active,domain_drained;
  logic monitor_scope_active,monitor_drained,monitor_coverage_complete;
  logic [15:0] monitor_status;
  logic [63:0] monitor_observed0,monitor_observed1,last_event_seq;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses;
  logic [31:0] accepted_events,semantic_rejections,terminal_tasks;
  logic [31:0] forwarded_aw,forwarded_w,retired_b,rejected_transactions;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;

  laya_generated_provenance_axi_portal_v1 #(.MONITORED_ROLE(6)) dut(.*);

  logic peer_aw_seen=0;
  int peer_aw=0,peer_w=0,peer_b=0,peer_w_in_burst=0;
  int peer_expected_beats=0,peer_zero_w=0,cycles=0,phase=0;
  int forwarded_before=0,forwarded_w_before=0,zero_before=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>100000)$fatal(1,"store monitor cycle cap phase=%0d",phase);
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      peer_aw_seen<=0;m_axi_bvalid<=0;
      peer_aw<=0;peer_w<=0;peer_b<=0;peer_w_in_burst<=0;
      peer_expected_beats<=0;peer_zero_w<=0;
    end else begin
      if(m_axi_awvalid && m_axi_awready)begin
        if(peer_aw_seen || m_axi_awlen>63 || m_axi_awsize!=6 ||
           m_axi_awburst!=1)
          $fatal(1,"forwarded malformed AW");
        peer_aw_seen<=1;peer_expected_beats<=m_axi_awlen+1;
        peer_w_in_burst<=0;peer_aw<=peer_aw+1;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(!peer_aw_seen)$fatal(1,"forwarded W preceded peer AW");
        if(m_axi_wlast!==((peer_w_in_burst+1)==peer_expected_beats))
          $fatal(1,"forwarded WLAST mismatch beat=%0d expected=%0d",
                 peer_w_in_burst,peer_expected_beats);
        if(m_axi_wstrb=='0)peer_zero_w<=peer_zero_w+1;
        else if(m_axi_wstrb!='1)$fatal(1,"forwarded partial WSTRB");
        peer_w_in_burst<=peer_w_in_burst+1;peer_w<=peer_w+1;
        if((peer_w_in_burst+1)==peer_expected_beats)m_axi_bvalid<=1;
      end
      if(m_axi_bvalid && m_axi_bready)begin
        m_axi_bvalid<=0;peer_aw_seen<=0;peer_w_in_burst<=0;
        peer_expected_beats<=0;peer_b<=peer_b+1;
      end
    end
  end

  string fixture;
  logic [511:0] fixture_beats[0:15];
  logic [8191:0] packet;
  logic [4095:0] received;

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask

  task automatic load_packet(input string name,output logic [8191:0] value);
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int beat=0;beat<16;beat++)value[beat*512+:512]=fixture_beats[beat];
  endtask

  task automatic send_packet(input logic [8191:0] value);
    for(int beat=0;beat<16;beat++)begin
      provenance_cmd_din=value[beat*512+:512];provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
  endtask

  task automatic receive_packet(output logic [4095:0] value);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      repeat(2)begin
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"response changed under backpressure phase=%0d",phase);
        tick();
      end
      value[beat*512+:512]=held;
      provenance_rsp_read=1;tick();provenance_rsp_read=0;
    end
    repeat(2)tick();
  endtask

  task automatic check_response(input logic [8191:0] request_packet,
      input logic [15:0] expected_status,input logic [7:0] expected_flags,
      input logic [63:0] expected_observed);
    if(received[MAGIC*8+:32]!=RESPONSE_MAGIC ||
       received[ACTION*8+:16]!=request_packet[ACTION*8+:16] ||
       received[EVENT_SEQ*8+:64]!=request_packet[EVENT_SEQ*8+:64] ||
       received[RESPONSE_ORIGIN_SEQ*8+:64]!=request_packet[ORIGIN_SEQ*8+:64] ||
       received[RESPONSE_STATUS*8+:16]!=expected_status ||
       received[RESPONSE_FLAGS*8+:8]!=expected_flags ||
       received[RESPONSE_OBSERVED0*8+:64]!=expected_observed)
      $fatal(1,"response mismatch phase=%0d action=%0d status=%0d flags=%0h observed=%0d detail=%08x",
        phase,received[ACTION*8+:16],received[RESPONSE_STATUS*8+:16],
        received[RESPONSE_FLAGS*8+:8],received[RESPONSE_OBSERVED0*8+:64],
        received[RESPONSE_DETAIL*8+:32]);
  endtask

  task automatic transact(input string name,input logic [15:0] status,
      input logic [7:0] flags,input logic [63:0] observed);
    load_packet(name,packet);send_packet(packet);receive_packet(received);
    check_response(packet,status,flags,observed);
  endtask

  task automatic drive_write(input logic [63:0] address,
      input logic w_before_aw,input logic [1:0] expected_bresp,
      input logic hold_response);
    logic aw_done,w_done,aw_accept,w_accept;
    aw_done=0;w_done=0;s_axi_bready=0;
    s_axi_awaddr=address;s_axi_awlen=0;s_axi_awsize=6;s_axi_awburst=1;
    s_axi_wdata={8{address}};s_axi_wstrb='1;s_axi_wlast=1;
    if(w_before_aw)begin
      s_axi_wvalid=1;
      while(!w_done)begin
        @(posedge clk);aw_accept=0;w_accept=s_axi_wvalid && s_axi_wready;#1;
        if(w_accept)begin s_axi_wvalid=0;w_done=1;end
        @(negedge clk);
      end
      repeat(2)begin
        if(m_axi_wvalid)$fatal(1,"W escaped before an authorized AW");
        tick();
      end
      s_axi_awvalid=1;
    end else begin
      s_axi_awvalid=1;s_axi_wvalid=1;
    end
    while(!aw_done || !w_done)begin
      @(posedge clk);
      aw_accept=s_axi_awvalid && s_axi_awready;
      w_accept=s_axi_wvalid && s_axi_wready;#1;
      if(aw_accept)begin s_axi_awvalid=0;aw_done=1;end
      if(w_accept)begin s_axi_wvalid=0;w_done=1;end
      @(negedge clk);
    end
    while(!s_axi_bvalid)tick();
    if(s_axi_bresp!=expected_bresp)$fatal(1,"B response mismatch phase=%0d",phase);
    if(!hold_response)begin
      s_axi_bready=1;tick();s_axi_bready=0;tick();
    end
  endtask

  task automatic drive_burst(input logic [63:0] address,input integer beats,
      input logic w_before_aw,input logic [1:0] expected_bresp,
      input logic hold_response);
    logic aw_done,w_done,aw_accept,w_accept;
    integer first_beat;
    aw_done=0;w_done=0;s_axi_bready=0;first_beat=0;
    s_axi_awaddr=address;s_axi_awlen=beats-1;s_axi_awsize=6;s_axi_awburst=1;
    if(w_before_aw)begin
      s_axi_wdata={8{address}};s_axi_wstrb='1;
      s_axi_wlast=beats==1;s_axi_wvalid=1;
      while(!w_done)begin
        @(posedge clk);w_accept=s_axi_wvalid && s_axi_wready;#1;
        if(w_accept)begin s_axi_wvalid=0;w_done=1;end
        @(negedge clk);
      end
      repeat(2)begin
        if(m_axi_wvalid)$fatal(1,"burst W escaped before an authorized AW");
        tick();
      end
      first_beat=1;
    end
    s_axi_awvalid=1;
    while(!aw_done)begin
      @(posedge clk);aw_accept=s_axi_awvalid && s_axi_awready;#1;
      if(aw_accept)begin s_axi_awvalid=0;aw_done=1;end
      @(negedge clk);
    end
    for(int beat=first_beat;beat<beats;beat++)begin
      s_axi_wdata={8{address+64'(beat)*64}};s_axi_wstrb='1;
      s_axi_wlast=beat==beats-1;s_axi_wvalid=1;w_done=0;
      while(!w_done)begin
        @(posedge clk);w_accept=s_axi_wvalid && s_axi_wready;#1;
        if(w_accept)begin s_axi_wvalid=0;w_done=1;end
        @(negedge clk);
      end
    end
    while(!s_axi_bvalid)tick();
    if(s_axi_bresp!=expected_bresp)
      $fatal(1,"burst B response mismatch phase=%0d",phase);
    if(!hold_response)begin
      s_axi_bready=1;tick();s_axi_bready=0;tick();
    end
    s_axi_awlen=0;s_axi_wlast=1;
  endtask

  task automatic accept_held_b;
    if(!s_axi_bvalid)$fatal(1,"held B absent");
    s_axi_bready=1;tick();s_axi_bready=0;tick();
  endtask

  task automatic drive_partial_failure_two_beat(input logic [63:0] address);
    logic aw_done,w_done,aw_accept,w_accept;
    aw_done=0;w_done=0;s_axi_bready=0;
    s_axi_awaddr=address;s_axi_awlen=1;s_axi_awsize=6;s_axi_awburst=1;
    s_axi_wdata={8{address}};s_axi_wstrb='1;s_axi_wlast=0;
    s_axi_awvalid=1;s_axi_wvalid=1;
    while(!aw_done || !w_done)begin
      @(posedge clk);
      aw_accept=s_axi_awvalid && s_axi_awready;
      w_accept=s_axi_wvalid && s_axi_wready;#1;
      if(aw_accept)begin s_axi_awvalid=0;aw_done=1;end
      if(w_accept)begin s_axi_wvalid=0;w_done=1;end
      @(negedge clk);
    end
    // The declared final beat omits WLAST.  The monitor must forward this beat
    // with zero WSTRB, close the real peer burst, and drain to the source WLAST.
    while(!s_axi_wready)tick();
    s_axi_wdata={8{address+64}};s_axi_wstrb='1;
    s_axi_wlast=0;s_axi_wvalid=1;
    w_done=0;
    while(!w_done)begin
      @(posedge clk);w_accept=s_axi_wvalid && s_axi_wready;#1;
      if(w_accept)begin s_axi_wvalid=0;w_done=1;end
      @(negedge clk);
    end
    while(!s_axi_wready)begin
      if(s_axi_bvalid)$fatal(1,"malformed burst returned B before WLAST drain");
      tick();
    end
    s_axi_wdata=0;s_axi_wstrb=0;s_axi_wlast=1;s_axi_wvalid=1;
    w_done=0;
    while(!w_done)begin
      @(posedge clk);w_accept=s_axi_wvalid && s_axi_wready;#1;
      if(w_accept)begin s_axi_wvalid=0;w_done=1;end
      @(negedge clk);
    end
    while(!s_axi_bvalid)tick();
    if(s_axi_bresp!=2'b11)$fatal(1,"merged burst B was not DECERR");
    s_axi_bready=1;tick();s_axi_bready=0;tick();
    s_axi_awlen=0;s_axi_wstrb='1;s_axi_wlast=1;
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    provenance_cmd_din=0;
    repeat(5)tick();rst_n=1;tick();
    if(!domain_drained || !monitor_drained)$fatal(1,"initial domain not drained");

    phase=1;transact("claim1",0,8'h01,0);
    phase=2;transact("begin1",0,8'h03,0);
    if(!scope_active || !monitor_scope_active)$fatal(1,"BEGIN did not bind monitor");

    phase=3;
    for(int burst=0;burst<15;burst++)
      drive_burst(BO_BASE+64'(burst)*4096,64,burst==0,2'b00,0);
    if(forwarded_aw!=15 || forwarded_w!=960 || retired_b!=15)
      $fatal(1,"pre-final forwarding count mismatch");

    phase=4;drive_burst(BO_BASE+64'(15)*4096,64,0,2'b00,1);
    if(monitor_drained || !s_axi_bvalid || !monitor_coverage_complete)
      $fatal(1,"held final B did not block drain");
    load_packet("end1",packet);send_packet(packet);
    repeat(12)begin
      if(provenance_rsp_empty_n || monitor_drained)
        $fatal(1,"END retired before final B");
      tick();
    end
    adapter_pending_zero=0;accept_held_b();
    repeat(8)begin
      if(provenance_rsp_empty_n || monitor_drained)
        $fatal(1,"END retired before adapter fence");
      tick();
    end
    adapter_pending_zero=1;
    receive_packet(received);check_response(packet,0,8'h01,65536);
    if(scope_active || monitor_scope_active || terminal_tasks!=1)
      $fatal(1,"successful END did not close scope");
    phase=5;transact("publish1",0,8'h05,0);
    phase=6;transact("release1",0,8'h01,0);

    phase=7;transact("claim2",0,8'h01,0);
    phase=8;transact("begin2",0,8'h03,0);
    forwarded_before=forwarded_aw;forwarded_w_before=forwarded_w;
    drive_write(BO_BASE+65536+64,0,2'b11,0);
    if(forwarded_aw!=forwarded_before || forwarded_w!=forwarded_w_before ||
       rejected_transactions!=1 || monitor_observed0!=64 || monitor_status!=E_BUFFER)
      $fatal(1,"unauthorized write was not rejected before HBM");
    phase=9;transact("failed_end2",E_BUFFER,8'h01,64);
    if(scope_active || monitor_scope_active || terminal_tasks!=2)
      $fatal(1,"failed END did not safely close scope");
    phase=10;transact("invalidate2",0,8'h01,0);

    phase=11;transact("claim3",0,8'h01,0);
    phase=12;transact("begin3",0,8'h03,0);
    forwarded_before=forwarded_aw;forwarded_w_before=forwarded_w;
    zero_before=peer_zero_w;
    drive_partial_failure_two_beat(BO_BASE);
    if(forwarded_aw!=forwarded_before+1 ||
       forwarded_w!=forwarded_w_before+2 || peer_zero_w!=zero_before+1 ||
       rejected_transactions!=2 || monitor_observed0!=128 ||
       monitor_status!=E_PROTOCOL || !monitor_drained)
      $fatal(1,"partial burst failure did not zero/drain/merge");
    phase=13;transact("failed_end3",E_PROTOCOL,8'h01,128);
    if(scope_active || monitor_scope_active || terminal_tasks!=3)
      $fatal(1,"illegal-burst END did not safely close scope");
    phase=14;transact("invalidate3",0,8'h01,0);

    phase=15;transact("claim4",0,8'h01,0);
    phase=16;load_packet("begin4",packet);send_packet(packet);
    while(!provenance_rsp_empty_n)tick();
    repeat(4)begin
      if(!provenance_rsp_empty_n || !scope_active || !monitor_scope_active)
        $fatal(1,"BEGIN response backpressure lost active binding");
      tick();
    end
    receive_packet(received);check_response(packet,0,8'h03,0);

    // Let matching END reach the hub before the admitted producer's posted
    // store appears at AXI.  Even with an otherwise idle monitor/adapter, the
    // issued-byte commitment must hold END until the late WSTRB arrives.
    adapter_pending_zero=1;cancel=1;forwarded_before=forwarded_aw;
    forwarded_w_before=forwarded_w;
    phase=17;load_packet("cancel_end4",packet);send_packet(packet);
    repeat(8)begin
      if(provenance_rsp_empty_n || !monitor_drained)
        $fatal(1,"END retired before its issued store reached AXI");
      tick();
    end
    phase=18;drive_write(BO_BASE,1,2'b00,1);
    if(forwarded_aw!=forwarded_before+1 ||
       forwarded_w!=forwarded_w_before+1 ||
       !s_axi_bvalid || monitor_drained)
      $fatal(1,"active cancel blocked or prematurely drained posted store");
    repeat(8)begin
      if(provenance_rsp_empty_n)$fatal(1,"cancel END retired before last B");
      tick();
    end
    adapter_pending_zero=0;
    accept_held_b();
    repeat(6)begin
      if(provenance_rsp_empty_n || monitor_drained)
        $fatal(1,"cancel END retired before adapter fence");
      tick();
    end
    // The old work is now physically retired.  Releasing cancel permits the
    // terminal response to be delivered while the hub invalidates its owner.
    cancel=0;adapter_pending_zero=1;
    receive_packet(received);check_response(packet,E_PROTOCOL,8'h01,64);
    for(int wait_cycles=0;wait_cycles<40 && active_owners!=0;wait_cycles++)tick();
    if(active_owners!=0 || !domain_drained || transport_busy || scope_active ||
       monitor_scope_active)
      $fatal(1,"active-scope cancel did not converge and recover");

    phase=19;transact("unsupported_claim",0,8'h01,0);
    phase=20;transact("unsupported_begin",E_PROTOCOL,8'h01,0);
    if(scope_active || monitor_scope_active)
      $fatal(1,"unsupported BEGIN opened a physical scope");
    phase=21;transact("unsupported_invalidate",0,8'h01,0);

    if(protocol_error || accepted_requests!=19 || accepted_events!=19 ||
       retired_responses!=19 || semantic_rejections!=1 || terminal_tasks!=4 ||
       forwarded_aw!=18 || forwarded_w!=1027 || retired_b!=19 ||
       rejected_transactions!=2 || peer_aw!=18 || peer_w!=1027 ||
       peer_b!=18 || peer_zero_w!=1)
      $fatal(1,"final counts req=%0d events=%0d rsp=%0d rejects=%0d terminal=%0d aw=%0d w=%0d b=%0d local=%0d peer=%0d/%0d/%0d protocol=%0d",
        accepted_requests,accepted_events,retired_responses,semantic_rejections,
        terminal_tasks,forwarded_aw,forwarded_w,retired_b,rejected_transactions,
        peer_aw,peer_w,peer_b,protocol_error);
    $display("FULL_CURRENT_GENERATED_STORE_MONITOR_PASS events=%0d terminal=%0d aw=%0d w=%0d b=%0d rejected=%0d bytes=%0d bursts64=16 zero_w=1 held_b=12 adapter_fence=8 w_before_aw=1 partial_failure_drained=1 real_b_merged=1 active_cancel_converged=1 begin_rsp_backpressure=1 end_before_first_aw=1 cancel_posted_store=1 cancel_end_ingress=1 unsupported_begin_rejected=1 recovery=1 cycles=%0d",
      accepted_events,terminal_tasks,forwarded_aw,forwarded_w,retired_b,
      rejected_transactions,65536,cycles);
    $finish;
  end
endmodule
