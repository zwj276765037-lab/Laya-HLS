`timescale 1ns/1ps
module laya_executor_checkpoint_tb_v2;
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

  logic [511:0] checkpoint_command_din=0,checkpoint_response_dout;
  logic checkpoint_command_write=0,checkpoint_command_full_n;
  logic checkpoint_response_empty_n,checkpoint_response_read=0;
  logic [511:0] executor_provenance_cmd_din=0;
  logic executor_provenance_cmd_write=0,executor_provenance_cmd_full_n;
  logic checkpoint_dispatch_held,checkpoint_handoff_complete;
  logic checkpoint_handoff_pulse,checkpoint_authority_valid,checkpoint_protocol_error;
  logic [31:0] checkpoint_accepted_queries,checkpoint_consumed_responses;
  logic [63:0] checkpoint_sequence_high_water,checkpoint_handoff_high_water;
  logic [1:0] checkpoint_command_occupancy,checkpoint_response_occupancy;
  logic snapshot_base_valid=1;
  logic [63:0] snapshot_base_epoch=7,snapshot_base_address=BO_BASE,snapshot_base_capacity=16920576;
  laya_generated_provenance_axi_portal_v1 #(.MONITORED_ROLE(6),.ENABLE_EXECUTOR_CHECKPOINT(1)) dut(
    .snapshot_request_valid(1'b0),.snapshot_request_ready(),.snapshot_request(6144'd0),
    .snapshot_response_valid(),.snapshot_response_ready(1'b0),.snapshot_response(),
    .snapshot_base_valid,.snapshot_base_epoch,.snapshot_base_address,.snapshot_base_capacity,
    .snapshot_sequence_high_water(),.bootstrap_source_guard_active(1'b0),
    .bootstrap_source_guard_key(6144'd0),.bootstrap_source_guard_match(),
    .bootstrap_physical_safe(),.*);

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

  logic [8191:0] query,checkpoint_received,checkpoint_gold,held_reply;
  integer handoffs=0,total_handoffs=0,mode=0,capture;
  always @(posedge clk)if(rst_n && checkpoint_handoff_pulse)begin
    handoffs<=handoffs+1;total_handoffs<=total_handoffs+1;
  end
  task automatic send_checkpoint(input logic [8191:0] p);
    for(int i=0;i<16;i++)begin
      checkpoint_command_din=p[i*512+:512];checkpoint_command_write=1;
      do begin @(posedge clk);end while(!checkpoint_command_full_n);
      #1;@(negedge clk);checkpoint_command_write=0;
    end
  endtask
  task automatic receive_checkpoint(input int status,input int flags,input bit expect_handoff=0);
    logic [511:0] held;
    int accepted_before,events_before,terminal_before;
    accepted_before=accepted_events;terminal_before=terminal_tasks;
    for(int i=0;i<16;i++)begin
      while(!checkpoint_response_empty_n)tick();
      held=checkpoint_response_dout;
      if(i==14 || i==15)repeat(12)begin
        provenance_cmd_write=1;provenance_cmd_din='0;
        executor_provenance_cmd_write=1;executor_provenance_cmd_din='0;
        if(!checkpoint_response_empty_n || checkpoint_response_dout!==held ||
           !checkpoint_dispatch_held || checkpoint_handoff_complete ||
           checkpoint_authority_valid || provenance_cmd_full_n || executor_provenance_cmd_full_n ||
           accepted_events!=accepted_before || terminal_tasks!=terminal_before)
          $fatal(1,"v2 held response leaked dispatch/changed tail=%0d",i);
        tick();
      end
      provenance_cmd_write=0;executor_provenance_cmd_write=0;
      checkpoint_received[i*512+:512]=held;
      checkpoint_response_read=1;tick();checkpoint_response_read=0;
      if(i<15 && checkpoint_handoff_complete)$fatal(1,"early handoff");
    end
    repeat(3)tick();
    if(checkpoint_received[10*8+:16]!=status || checkpoint_received[12*8+:32]!=flags)
      $fatal(1,"v2 status/flags mismatch mode=%0d got=%0d/%0d expected=%0d/%0d",mode,
        checkpoint_received[10*8+:16],checkpoint_received[12*8+:32],status,flags);
    if(checkpoint_handoff_complete!==expect_handoff ||
       checkpoint_authority_valid!==expect_handoff)$fatal(1,"v2 final consumer transfer mismatch");
  endtask
  task automatic event_ok(input string name);
    transact(name,0,name=="publish" ? 5 : name.substr(0,4)=="begin" || name.substr(0,11)=="target_begin" ? 3 : 1,
      name.substr(0,2)=="end" || name.substr(0,9)=="target_end" ? 65536 : 0);
  endtask
  task automatic reset_session;
    rst_n=0;cancel=0;provenance_cmd_write=0;checkpoint_command_write=0;
    checkpoint_response_read=0;snapshot_base_epoch=7;monitored_bo_base=BO_BASE;handoffs=0;
    repeat(5)tick();rst_n=1;tick();
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    load_packet("checkpoint",query);load_packet("checkpoint_good",checkpoint_gold);
    // Explicit reset-separated diagnostics; no accepted-request recovery claim.
    for(mode=0;mode<5;mode++)begin
      reset_session();phase=10+mode;
      event_ok("target_claim");
      for(int w=0;w<3;w++)begin
        event_ok($sformatf("target_begin%0d",w));
        for(int burst=0;burst<16;burst++)drive_burst(BO_BASE+8388608+w*65536+burst*4096,64,0,0,0);
        event_ok($sformatf("target_end%0d",w));
      end
      event_ok("target_invalidate");event_ok("claim");
      for(int w=0;w<4;w++)begin
        load_packet($sformatf("begin%0d",w),packet);
        if(mode==3 && w>=2)begin packet[TASK*8+:32]=packet[TASK*8+:32]+1;
          packet[CONTEXT*8+:32]=packet[CONTEXT*8+:32]+1;end
        send_packet(packet);receive_packet(received);check_response(packet,0,3,0);
        for(int burst=0;burst<16;burst++)drive_burst(BO_BASE+w*65536+burst*4096,64,0,0,
          mode==0 && w==3 && burst==15);
        if(mode==0 && w==3)begin
          query[16*8+:64]=1;query[680*8+:64]=1;send_checkpoint(query);
          load_packet("end3",packet);send_packet(packet);
          repeat(12)begin
            if(checkpoint_response_empty_n || checkpoint_dispatch_held || !scope_active ||
               terminal_tasks!=6)$fatal(1,"v2 blocked cleanup or passed final-B");tick();
          end
          s_axi_bready=1;tick();s_axi_bready=0;
          while(!provenance_rsp_empty_n)tick();
          repeat(12)begin
            if(checkpoint_response_empty_n || checkpoint_dispatch_held ||
               terminal_tasks!=7)$fatal(1,"v2 acquired before old response consumed");tick();
          end
          receive_packet(received);check_response(packet,0,1,65536);
          receive_checkpoint(E_BUFFER,3,0);
        end else begin
          load_packet($sformatf("end%0d",w),packet);
          if(mode==3 && w>=2)begin packet[TASK*8+:32]=packet[TASK*8+:32]+1;
            packet[CONTEXT*8+:32]=packet[CONTEXT*8+:32]+1;end
          send_packet(packet);receive_packet(received);check_response(packet,0,1,65536);
        end
      end
      event_ok("publish");
      load_packet("trusted_bad",packet);send_packet(packet);receive_packet(received);
      if(received[RESPONSE_STATUS*8+:16]==0 || last_event_seq!=177 || accepted_events!=18 || terminal_tasks!=7)
        $fatal(1,"LPV transport highwater fixture did not isolate trusted header耗号");
      if(peer_aw!=112 || peer_w!=7168 || peer_b!=112 ||
         active_owners!=1 || published_owners!=1)$fatal(1,"normal prelude coverage/count mismatch");
      if(mode==0)begin
        // Active target is a real CLAIM, not an injected array or a proof bit.
        load_packet("target_claim",packet);packet[EVENT_SEQ*8+:64]=178;packet[DESCRIPTOR0*8+:32]=8;
        send_packet(packet);receive_packet(received);check_response(packet,0,1,0);
        query[16*8+:64]=2;query[680*8+:64]=2;send_checkpoint(query);receive_checkpoint(E_BUFFER,3,0);
        load_packet("target_invalidate",packet);packet[EVENT_SEQ*8+:64]=179;packet[DESCRIPTOR0*8+:32]=8;
        send_packet(packet);receive_packet(received);check_response(packet,0,1,0);
        send_checkpoint(query);receive_checkpoint(E_PROTOCOL,3,0); // stale full key
        query[16*8+:64]=3;query[680*8+:64]=3;query[48*8+:64]=BO_BASE+64;
        query[696*8+:64]=BO_BASE+64;send_checkpoint(query);receive_checkpoint(E_PROTOCOL,3,0);
        query[48*8+:64]=BO_BASE;query[696*8+:64]=BO_BASE;
        query[16*8+:64]=4;query[680*8+:64]=4;query[776*8+:8]=1;
        send_checkpoint(query);receive_checkpoint(E_ABI,0,0);query[776*8+:8]=0;
      end
      query[16*8+:64]=mode==0 ? 4 : 1;query[680*8+:64]=mode==0 ? 4 : 1;
      send_checkpoint(query);while(!checkpoint_response_empty_n)tick();
      if(mode==1)begin snapshot_base_epoch=8;repeat(12)tick();end
      if(mode==4)begin monitored_bo_base=BO_BASE+64;repeat(12)tick();end
      if(mode==2)begin cancel=1;tick();cancel=0;repeat(12)tick();end
      receive_checkpoint(mode==3 ? E_PROTOCOL : 0,mode==3 ? 3 : 255,mode==0);
      if(mode==0)begin
        checkpoint_gold[16*8+:64]=4;checkpoint_gold[680*8+:64]=4;
        if(checkpoint_received!==checkpoint_gold)$fatal(1,"v2 full byte oracle mismatch");
        if(handoffs!=1 || !checkpoint_dispatch_held || provenance_cmd_full_n || !executor_provenance_cmd_full_n)
          $fatal(1,"unique dispatch handoff mismatch");
        capture=$fopen({fixture,"/actual_checkpoint.hex"},"w");
        for(int i=0;i<16;i++)$fdisplay(capture,"%0128h",checkpoint_received[i*512+:512]);$fclose(capture);
        // An executor-side target CLAIM uses the same real LPV transport.
        load_packet("target_claim",packet);packet[EVENT_SEQ*8+:64]=180;
        packet[DESCRIPTOR0*8+:32]=9;
        for(int i=0;i<16;i++)begin
          executor_provenance_cmd_din=packet[i*512+:512];executor_provenance_cmd_write=1;
          do begin @(posedge clk);end while(!executor_provenance_cmd_full_n);
          #1;@(negedge clk);executor_provenance_cmd_write=0;
        end
        receive_packet(received);check_response(packet,0,1,0);
        if(accepted_events!=21 || terminal_tasks!=7 || last_event_seq!=180)
          $fatal(1,"successor dispatch did not retain true highwater");
        cancel=1;tick();cancel=0;repeat(3)tick();
        if(checkpoint_authority_valid || executor_provenance_cmd_full_n)
          $fatal(1,"cancel failed to revoke acquired dispatch");
      end else if(mode==1 || mode==2 || mode==4)begin
        if(!checkpoint_protocol_error || handoffs!=0 || executor_provenance_cmd_full_n)
          $fatal(1,"changed config/cancel generated stale handoff");
      end
      if(checkpoint_response_occupancy!=0 || checkpoint_command_occupancy!=0)
        $fatal(1,"v2 FIFOs not empty at diagnostic end");
    end
    $display("FULL_CURRENT_EXECUTOR_CHECKPOINT_RTL_PASS modes=5 actual_task_floor=7 lpv_floor=179 target_epoch=8 wire_active_stale_base_rejects=4 handoffs=%0d continuous_frontier_reject=1 tail_stalls=2 old_end_progress=1 cancel_base_revoke=3 physical_base_revoke=1",total_handoffs);
    $finish;
  end
endmodule
