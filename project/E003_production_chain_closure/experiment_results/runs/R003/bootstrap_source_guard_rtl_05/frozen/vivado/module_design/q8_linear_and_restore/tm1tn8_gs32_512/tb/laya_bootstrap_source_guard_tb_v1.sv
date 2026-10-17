`timescale 1ns/1ps
module laya_bootstrap_source_guard_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;
  logic request_valid=0,request_ready,response_valid,response_ready=0;
  logic [8191:0] request=0,accepted_request=0;
  logic [4095:0] response;
  logic scope_active,domain_drained,cancel_pending;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_events,semantic_rejections,terminal_tasks;
  logic begin_ready,begin_supported,monitor_scope_active,monitor_drained;
  logic monitor_coverage_complete,monitor_protocol_error;
  logic [15:0] monitor_status;
  logic [31:0] monitor_error_detail;
  logic [63:0] monitor_bad_element,monitor_observed0,monitor_observed1;
  assign monitor_protocol_error=monitor_status!=0;
  logic adapter_pending_zero=1,begin_block;
  logic begin_valid,end_commit;
  logic physical_observation_ready;
  wire physical_observation_valid=request_valid &&
    ((request[ACTION*8+:16]==END_EVENT && monitor_scope_active && monitor_drained &&
      monitor_observed0==request[ISSUED0*8+:64]) ||
     (request[ACTION*8+:16]==PUBLISH && !monitor_scope_active && monitor_drained) ||
     (request[ACTION*8+:16]==INVALIDATE && !monitor_scope_active && monitor_drained));
  logic snapshot_request_valid=0,snapshot_request_ready,snapshot_response_valid;
  logic snapshot_response_ready=0;
  logic [6143:0] snapshot_request=0,snapshot_response;
  logic snapshot_base_valid=1,source_read_debt_zero=1;
  logic [63:0] snapshot_base_epoch=7,snapshot_base_address=BO_BASE;
  logic [63:0] snapshot_base_capacity=16920576,snapshot_sequence_high_water;
  wire snapshot_physical_quiescent=monitor_drained && !monitor_scope_active &&
    adapter_pending_zero && source_read_debt_zero && !monitor_protocol_error;
  logic [63:0] s_axi_awaddr=0,m_axi_awaddr;
  logic [7:0] s_axi_awlen=0,m_axi_awlen;
  logic [2:0] s_axi_awsize=6,m_axi_awsize;
  logic [1:0] s_axi_awburst=1,m_axi_awburst;
  logic s_axi_awvalid=0,s_axi_awready,m_axi_awvalid,m_axi_awready=1;
  logic [511:0] s_axi_wdata=0,m_axi_wdata;
  logic [63:0] s_axi_wstrb=0,m_axi_wstrb;
  logic s_axi_wlast=1,s_axi_wvalid=0,s_axi_wready,m_axi_wlast,m_axi_wvalid,m_axi_wready=1;
  logic [1:0] s_axi_bresp,m_axi_bresp=0;
  logic s_axi_bvalid,s_axi_bready=0,m_axi_bvalid=0,m_axi_bready;
  logic [31:0] forwarded_aw,forwarded_w,retired_b,rejected_transactions;
  laya_generated_provenance_hub_v1 #(.ENABLE_BOOTSTRAP_SNAPSHOT(1),.ENABLE_BOOTSTRAP_SOURCE_GUARD(1)) hub(
    .clk,.rst_n,.request_valid,.request_ready,.request,.cancel,
    .begin_external_ready(begin_ready),.begin_external_supported(begin_supported),
    .physical_observation_valid,.physical_observation_ready,
    .physical_status(request[ACTION*8+:16]==END_EVENT ? monitor_status : 16'd0),
    .physical_error_detail(request[ACTION*8+:16]==END_EVENT ? monitor_error_detail : 32'd0),
    .physical_bad_element(request[ACTION*8+:16]==END_EVENT ? monitor_bad_element : 64'hffffffffffffffff),
    .physical_observed_store_bytes0(request[ACTION*8+:16]==END_EVENT ? monitor_observed0 : 64'd0),
    .physical_observed_store_bytes1(64'd0),.physical_drained(monitor_drained),
    .physical_coverage_complete(request[ACTION*8+:16]==END_EVENT ? monitor_coverage_complete : 1'b1),
    .source_query_valid(query_valid),.source_query_ready(query_ready),
    .source_query_granted(query_granted),.source_lease_active(query_lease),
    .source_query_command(8192'd0),
    .source_release_valid(1'b0),.source_release_command(8192'd0),.source_release_drained(1'b0),
    .response_valid,.response_ready,.response,.scope_active,.domain_drained,.cancel_pending,
    .active_owners,.published_owners,.accepted_events,.semantic_rejections,.terminal_tasks,
    .snapshot_request_valid,.snapshot_request_ready,.snapshot_request,
    .snapshot_response_valid,.snapshot_response_ready,.snapshot_response,
    .snapshot_physical_quiescent,.snapshot_base_valid,.snapshot_base_epoch,
    .snapshot_base_address,.snapshot_base_capacity,.snapshot_sequence_high_water,
    .bootstrap_source_guard_active(guard_active),.bootstrap_source_guard_key(guard_key),
    .bootstrap_source_guard_match(guard_match));
  assign begin_valid=response_valid && response_ready &&
    response[ACTION*8+:16]==BEGIN_EVENT && response[RESPONSE_STATUS*8+:16]==0;
  assign end_commit=response_valid && response_ready &&
    response[ACTION*8+:16]==END_EVENT && !response[RESPONSE_FLAGS*8+1];
  assign begin_block=request_valid && request[ACTION*8+:16]==BEGIN_EVENT;
  always_ff @(posedge clk)if(request_valid && request_ready)accepted_request<=request;
  laya_generated_store_monitor_v1 #(.MONITORED_ROLE(6)) monitor(
    .clk,.rst_n,.cancel,.begin_valid,.begin_ready,.begin_block,
    .candidate_packet(request),.begin_packet(accepted_request),.bo_base(BO_BASE),.end_commit,
    .adapter_pending_zero,.begin_supported,.scope_active(monitor_scope_active),
    .physical_drained(monitor_drained),.coverage_complete(monitor_coverage_complete),
    .physical_status(monitor_status),.physical_error_detail(monitor_error_detail),
    .physical_bad_element(monitor_bad_element),.observed_store_bytes0(monitor_observed0),
    .observed_store_bytes1(monitor_observed1),
    .forwarded_aw,.forwarded_w,.retired_b,.rejected_transactions,
    .s_axi_awaddr,.s_axi_awlen,.s_axi_awsize,.s_axi_awburst,.s_axi_awvalid,.s_axi_awready,
    .s_axi_wdata,.s_axi_wstrb,.s_axi_wlast,.s_axi_wvalid,.s_axi_wready,.s_axi_bresp,.s_axi_bvalid,.s_axi_bready,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,.m_axi_awvalid,.m_axi_awready,
    .m_axi_wdata,.m_axi_wstrb,.m_axi_wlast,.m_axi_wvalid,.m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready);
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
  logic [511:0] fixture_beats[0:15],snapshot_beats[0:11];
  logic [8191:0] packet;
  logic [6143:0] snapshot_gold,query,held_snapshot;
  logic [63:0] next_snapshot=1;
  integer snapshot_accepts=0,lpv_accepts=0;
  logic query_valid=0,query_ready,query_granted,query_lease;
  always @(posedge clk)if(rst_n)begin
    if(request_valid && request_ready)lpv_accepts<=lpv_accepts+1;
    if(snapshot_request_valid && snapshot_request_ready)snapshot_accepts<=snapshot_accepts+1;
    if(request_valid && request_ready && snapshot_request_valid && snapshot_request_ready)
      $fatal(1,"both arbitration clients accepted in one cycle");
  end
  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic load_packet(input string name,output logic [8191:0] value);
    for(int i=0;i<16;i++)fixture_beats[i]=0;
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int i=0;i<16;i++)value[i*512+:512]=fixture_beats[i];
  endtask
  task automatic send_event(input string name,input bit hold_reply=0);
    load_packet(name,packet);request=packet;request_valid=1;
    do begin @(posedge clk);end while(!request_ready);
    #1;@(negedge clk);request_valid=0;
    while(!response_valid)tick();
    if(response[RESPONSE_STATUS*8+:16]!=0)$fatal(1,"prelude event rejected name=%s status=%0d",name,response[RESPONSE_STATUS*8+:16]);
    if(!hold_reply)begin response_ready=1;tick();response_ready=0;tick();end
  endtask
  task automatic snapshot(input logic [6143:0] value,input logic [15:0] status,
                           input logic [31:0] flags,input bit hold_reply=0);
    snapshot_request=value;snapshot_request_valid=1;
    do begin @(posedge clk);end while(!snapshot_request_ready);
    #1;@(negedge clk);snapshot_request_valid=0;
    while(!snapshot_response_valid)tick();
    if(snapshot_response[10*8+:16]!=status || snapshot_response[12*8+:32]!=flags)
      $fatal(1,"snapshot mismatch seq=%0d status=%0d flags=%0d expected=%0d/%0d",value[16*8+:64],snapshot_response[10*8+:16],snapshot_response[12*8+:32],status,flags);
    if(flags!=0 && (snapshot_response[16*8+:64]!=value[16*8+:64] ||
       snapshot_response[40*8+:576*8]!=value[40*8+:576*8] ||
       snapshot_response[616*8+:152*8]!=value[616*8+:152*8]))$fatal(1,"snapshot binding not echoed");
    if(!hold_reply)begin snapshot_response_ready=1;tick();snapshot_response_ready=0;tick();end
  endtask
  task automatic normal_query(input logic [15:0] status,input logic [31:0] flags);
    query=snapshot_gold;query[16*8+:64]=next_snapshot;next_snapshot=next_snapshot+1;
    snapshot(query,status,flags);
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

  // Keep VALID until the real request handshake. The source and old scope
  // must survive the rejection, including backpressure on its response.
  task automatic reject_source_mutation(input logic [8191:0] value,
                                        input bit expected_scope);
    integer events_before,terminal_before,aw_before;
    logic [4095:0] held;
    events_before=accepted_events;terminal_before=terminal_tasks;aw_before=forwarded_aw;
    request=value;request_valid=1;
    do begin @(posedge clk);end while(!request_ready);
    #1;@(negedge clk);request_valid=0;
    while(!response_valid)tick();
    held=response;
    if(response[RESPONSE_STATUS*8+:16]!=E_BUFFER ||
       response[RESPONSE_FLAGS*8+:8]!=(expected_scope ? 2 : 0) ||
       response[RESPONSE_IDENTITY*8+:672]!=value[IDENTITY*8+:672] ||
       response[RESPONSE_TARGET0*8+:64]!=value[DESCRIPTOR0*8+:64])
      $fatal(1,"conflict rejection lost binding or claimed drain");
    repeat(12)begin
      if(request_ready || !response_valid || response!==held || !guard_active ||
         !guard_match || scope_active!=expected_scope ||
         accepted_events!=events_before+1 || terminal_tasks!=terminal_before ||
         forwarded_aw!=aw_before)
        $fatal(1,"source conflict changed old state under response backpressure");
      tick();
    end
    response_ready=1;tick();response_ready=0;tick();
  endtask

  logic guard_active,proof_valid,guard_match,base_change_ready,guard_error;
  logic [6143:0] guard_key;
  logic action_valid=0,action_ready,producer_valid=0,producer_ready;
  logic [4095:0] action_key=0;
  logic [8191:0] producer_key=0;
  logic [2047:0] completion_key=0;
  logic guard_producer_active,guard_action_active;
  logic [31:0] read_debt;
  logic [63:0] raw_araddr=BO_BASE;
  logic [7:0] raw_arlen=0;
  logic raw_arvalid=0,ar_allowed,raw_rvalid=0,raw_rlast=0;
  integer source_peer_ar=0,source_peer_r=0;
  logic producer_in_valid=0,producer_in_ready,producer_out_valid,producer_out_read=0;
  logic [511:0] producer_in_data=0,producer_out_data;
  logic action_in_valid=0,action_in_ready,action_out_valid,action_out_read=0;
  logic [511:0] action_in_data=0,action_out_data;
  logic [1:0] producer_occupancy,action_occupancy;
  laya_private_fifo2_v1 producer_fifo(.clk,.rst_n,.in_valid(producer_in_valid),
    .in_ready(producer_in_ready),.in_data(producer_in_data),.out_valid(producer_out_valid),
    .out_ready(producer_out_read),.out_data(producer_out_data),.occupancy(producer_occupancy));
  laya_private_fifo2_v1 action_fifo(.clk,.rst_n,.in_valid(action_in_valid),
    .in_ready(action_in_ready),.in_data(action_in_data),.out_valid(action_out_valid),
    .out_ready(action_out_read),.out_data(action_out_data),.occupancy(action_occupancy));
  laya_bootstrap_source_guard_v1 guard(
    .clk,.rst_n,.cancel,.snapshot_accept(snapshot_request_valid && snapshot_request_ready),
    .snapshot_request,.snapshot_response_valid,.snapshot_response_ready,.snapshot_response,
    .source_still_matches(guard_match),.live_base_epoch(snapshot_base_epoch),
    .live_base_address(snapshot_base_address),.live_base_capacity(snapshot_base_capacity),
    .physical_safe(snapshot_physical_quiescent && !scope_active && !response_valid),
    .guard_active,.proof_valid,.guard_key,.base_change_ready,.action_valid,
    .action_request(action_key),.action_ready,.producer_valid,
    .producer_request(producer_key),.producer_ready,
    .producer_completion_empty_n(producer_out_valid),.producer_completion_read(producer_out_read),
    .action_completion_dout(action_out_data),.action_completion_empty_n(action_out_valid),
    .action_completion_read(action_out_read),.source_araddr(raw_araddr),.source_arlen(raw_arlen),
    .source_arsize(3'd6),.source_arburst(2'd1),.source_arvalid(raw_arvalid),.source_arready(1'b1),
    .source_ar_allowed(ar_allowed),.source_rvalid(raw_rvalid),.source_rready(1'b1),
    .source_rlast(raw_rlast),.source_rresp(2'd0),.read_debt,
    .producer_active(guard_producer_active),.action_active(guard_action_active),.protocol_error(guard_error));
  always @(posedge clk)if(rst_n)begin
    if(raw_arvalid && ar_allowed)source_peer_ar<=source_peer_ar+1;
    if(raw_rvalid)source_peer_r<=source_peer_r+1;
  end
  task automatic load_short(input string name,output logic [2047:0] value);
    logic [511:0] words[0:3];
    $readmemh({fixture,"/",name,".hex"},words);
    for(int i=0;i<4;i++)value[i*512+:512]=words[i];
  endtask
  task automatic consume_producer;
    fork
      begin
        for(int beat=0;beat<8;beat++)begin
          producer_in_data=512'(beat);producer_in_valid=1;
          do begin @(posedge clk);end while(!producer_in_ready);
          #1;@(negedge clk);producer_in_valid=0;
        end
      end
      begin
        for(int beat=0;beat<6;beat++)begin
          producer_out_read=1;do begin @(posedge clk);end while(!producer_out_valid);
          #1;@(negedge clk);producer_out_read=0;
        end
        while(producer_occupancy!=2)tick();
        repeat(12)begin if(!guard_active || !guard_producer_active || base_change_ready)$fatal(1,"producer tail2 released guard");tick();end
        producer_out_read=1;tick();producer_out_read=0;
        repeat(12)begin if(!guard_active || !guard_producer_active || base_change_ready)$fatal(1,"producer tail1 released guard");tick();end
        producer_out_read=1;tick();producer_out_read=0;tick();
      end
    join
  endtask
  task automatic consume_action(input logic [2047:0] value,input bit releases);
    fork
      begin
        for(int beat=0;beat<4;beat++)begin
          action_in_data=value[beat*512+:512];action_in_valid=1;
          do begin @(posedge clk);end while(!action_in_ready);
          #1;@(negedge clk);action_in_valid=0;
        end
      end
      begin
        for(int beat=0;beat<2;beat++)begin
          action_out_read=1;do begin @(posedge clk);end while(!action_out_valid);
          #1;@(negedge clk);action_out_read=0;
        end
        while(action_occupancy!=2)tick();
        held_snapshot={5632'd0,action_out_data};
        repeat(12)begin
          if(!guard_active || !guard_action_active || base_change_ready ||
             action_out_data!==held_snapshot[0+:512])$fatal(1,"action tail2 released/changed guard");
          tick();
        end
        action_out_read=1;tick();action_out_read=0;
        repeat(12)begin if(!guard_active || !guard_action_active || base_change_ready)$fatal(1,"action tail1 released guard");tick();end
        action_out_read=1;tick();action_out_read=0;tick();tick();
        if(releases && guard_active)$fatal(1,"safe consumed completion guard remained active");
      end
    join
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    $readmemh({fixture,"/snapshot.hex"},snapshot_beats);
    for(int i=0;i<12;i++)snapshot_gold[i*512+:512]=snapshot_beats[i];
    repeat(5)tick();rst_n=1;tick();
    phase=1;normal_query(E_BUFFER,3); // No owner.
    query=snapshot_gold;query[16*8+:64]=next_snapshot;next_snapshot=next_snapshot+1;
    snapshot_request=query;snapshot_request_valid=1;
    load_packet("claim",request);request_valid=1;#1;
    if(!request_ready || snapshot_request_ready)$fatal(1,"LPV idle priority missing");
    tick();request_valid=0;
    if(!response_valid || lpv_accepts!=1 || snapshot_accepts!=1)
      $fatal(1,"idle competitor accepted incorrectly");
    repeat(12)begin
      if(snapshot_request_ready || !snapshot_request_valid || !response_valid)
        $fatal(1,"unaccepted snapshot did not wait for LPV response consumption");
      tick();
    end
    response_ready=1;tick();response_ready=0;
    while(!snapshot_response_valid)tick();
    snapshot_request_valid=0;
    if(snapshot_response[10*8+:16]!=E_BUFFER || snapshot_response[12*8+:32]!=3 ||
       snapshot_response[16*8+:64]!=query[16*8+:64] || lpv_accepts!=1 || snapshot_accepts!=2)
      $fatal(1,"idle competitor query result or single acceptance mismatch");
    snapshot_response_ready=1;tick();snapshot_response_ready=0;tick();
    normal_query(E_BUFFER,3); // Unpublished.
    for(int window=0;window<4;window++)begin
      phase=2+window;send_event($sformatf("begin%0d",window));
      query=snapshot_gold;query[16*8+:64]=next_snapshot;
      if(window==3)next_snapshot=next_snapshot+1;
      snapshot_request=query;snapshot_request_valid=1;
      repeat(8)begin if(snapshot_request_ready)$fatal(1,"snapshot admitted active scope");tick();end
      if(window!=3)snapshot_request_valid=0;
      for(int row=0;row<16;row++)
        drive_burst(BO_BASE+64'(window*16+row)*4096,64,0,0,row==15);
      if(monitor_drained || retired_b!=window*16+15)$fatal(1,"last B debt not retained");
      if(window==3)begin
        fork
          send_event("end3",1);
          begin
            repeat(12)begin
              if(!snapshot_request_valid || snapshot_request_ready || snapshot_response_valid ||
                 request_ready || monitor_drained)
                $fatal(1,"END/snapshot bypassed real final B debt");
              tick();
            end
            s_axi_bready=1;tick();s_axi_bready=0;tick();
          end
        join
      end else begin
        s_axi_bready=1;tick();s_axi_bready=0;tick();
        send_event($sformatf("end%0d",window));
      end
      if(window==3)begin
        repeat(12)begin
          if(!snapshot_request_valid || snapshot_request_ready || snapshot_response_valid)
            $fatal(1,"snapshot admitted held END return");
          tick();
        end
        if(terminal_tasks!=4 || accepted_events!=9 || scope_active)
          $fatal(1,"held snapshot prevented old END cleanup");
        response_ready=1;tick();response_ready=0;
        while(!snapshot_response_valid)tick();
        snapshot_request_valid=0;
        if(snapshot_response[10*8+:16]!=E_BUFFER || snapshot_response[12*8+:32]!=3 ||
           snapshot_response[16*8+:64]!=query[16*8+:64])
          $fatal(1,"post-END unpublished snapshot result mismatch");
        snapshot_response_ready=1;tick();snapshot_response_ready=0;tick();
      end else normal_query(E_BUFFER,3);
    end
    phase=6;send_event("publish");
    if(active_owners!=1 || published_owners!=1 || terminal_tasks!=4 ||
       accepted_events!=10 || forwarded_aw!=64 || forwarded_w!=4096 || retired_b!=64 || domain_drained)
      $fatal(1,"full controlled source prelude mismatch");
    adapter_pending_zero=0;normal_query(E_PROTOCOL,3);
    if(guard_active || proof_valid || guard_error || published_owners!=1)
      $fatal(1,"negative nonquiescent snapshot poisoned cleanup/proof");
    adapter_pending_zero=1;normal_query(0,63);
    phase=7;
    if(!guard_active || !proof_valid || !guard_match || base_change_ready)
      $fatal(1,"source exclusion not established after snapshot consumption");
    load_packet("guard_claim",request);request_valid=1;
    // Legal non-overlapping destination CLAIM must progress during exclusion.
    do begin @(posedge clk);end while(!request_ready);
    #1;@(negedge clk);request_valid=0;
    while(!response_valid)tick();
    if(response[RESPONSE_STATUS*8+:16]!=0)$fatal(1,"guard blocked legitimate destination CLAIM");
    response_ready=1;tick();response_ready=0;tick();
    load_packet("invalidate",packet);reject_source_mutation(packet,0);
    packet[ACTION*8+:16]=CLAIM;packet[608*8+:32]=2;
    reject_source_mutation(packet,0);
    // Same-role overlap and a different role cannot acquire a write scope.
    load_packet("claim",packet);packet[612*8+:8]=3;
    reject_source_mutation(packet,0);
    packet[636*8+:8]=7;reject_source_mutation(packet,0);
    load_packet("claim",packet);packet[64*8+:64]=1102;
    reject_source_mutation(packet,0);
    // A held conflict cannot monopolize the portal ahead of old task cleanup.
    send_event("guard_begin");
    drive_burst(BO_BASE+262144,64,0,0,1);
    load_packet("invalidate",packet);reject_source_mutation(packet,1);
    if(!scope_active || retired_b!=64 || monitor_drained || !guard_match)
      $fatal(1,"conflict destroyed partial task/final B binding");
    load_packet("guard_end_partial",packet);request=packet;request_valid=1;
    repeat(12)begin
      if(request_ready || !scope_active || !guard_active || !guard_match)
        $fatal(1,"partial END bypassed final B/source protection");
      tick();
    end
    s_axi_bready=1;tick();s_axi_bready=0;
    do begin @(posedge clk);end while(!request_ready);
    #1;@(negedge clk);request_valid=0;
    while(!response_valid)tick();
    if(response[RESPONSE_STATUS*8+:16]!=E_PROTOCOL ||
       response[RESPONSE_DETAIL*8+:32]!=32'h0700000e ||
       response[RESPONSE_FLAGS*8+:8]!=1 ||
       response[RESPONSE_OBSERVED0*8+:64]!=4096 ||
       scope_active || terminal_tasks!=5 || retired_b!=65 || !guard_match)
      $fatal(1,"old partial END did not preserve first error/retire once");
    repeat(12)begin
      if(!response_valid || !guard_active || !guard_match || terminal_tasks!=5)
        $fatal(1,"held old END response lost source/typed binding");
      tick();
    end
    response_ready=1;tick();response_ready=0;tick();
    load_packet("guard_action",packet);action_key=packet[0+:4096];action_valid=1;#1;
    if(!action_ready)$fatal(1,"bound action rejected");
    tick();action_valid=0;
    load_packet("guard_producer",producer_key);
    producer_key[64*8+:64]=1102;producer_valid=1;
    repeat(12)begin if(producer_ready || source_peer_ar!=0)$fatal(1,"wrong producer identity read source");tick();end
    producer_valid=0;load_packet("guard_producer",producer_key);
    producer_key[576*8+:32]=2;producer_valid=1;
    repeat(12)begin if(producer_ready || source_peer_ar!=0)$fatal(1,"wrong source epoch read source");tick();end
    producer_valid=0;load_packet("guard_producer",producer_key);
    snapshot_base_epoch=8;producer_valid=1;
    repeat(12)begin if(producer_ready || base_change_ready || source_peer_ar!=0)$fatal(1,"changed base admitted read");tick();end
    producer_valid=0;snapshot_base_epoch=7;
    producer_valid=1;#1;if(!producer_ready)$fatal(1,"bound producer source gate rejected");
    tick();producer_valid=0;
    raw_araddr=BO_BASE+262144;raw_arvalid=1;#1;
    repeat(12)begin if(ar_allowed || source_peer_ar!=0)$fatal(1,"out-of-range source AR forwarded allow=%0d addr=%h peer=%0d",ar_allowed,raw_araddr,source_peer_ar);tick();end
    raw_arvalid=0;raw_araddr=BO_BASE;raw_arlen=63;raw_arvalid=1;#1;
    if(!ar_allowed)$fatal(1,"valid protected source AR blocked");
    tick();raw_arvalid=0;
    if(read_debt!=64 || source_peer_ar!=1)$fatal(1,"actual AR debt not recorded");
    repeat(12)begin if(!guard_active || base_change_ready || read_debt!=64)$fatal(1,"AR debt released guard");tick();end
    for(int beat=0;beat<64;beat++)begin
      raw_rvalid=1;raw_rlast=beat==63;tick();
    end
    raw_rvalid=0;raw_rlast=0;tick();
    if(read_debt!=0 || source_peer_r!=64 || !guard_active)$fatal(1,"actual R debt mismatch");
    // Two real depth2 FIFOs; retain tail beats after earlier consumer pops.
    consume_producer();
    if(guard_producer_active || !guard_active)$fatal(1,"producer consumption/source interval mismatch");
    load_packet("guard_invalidate",request);request_valid=1;
    do begin @(posedge clk);end while(!request_ready);
    #1;@(negedge clk);request_valid=0;
    while(!response_valid)tick();
    if(response[RESPONSE_STATUS*8+:16]!=0)$fatal(1,"destination cleanup blocked");
    response_ready=1;tick();response_ready=0;tick();
    load_short("guard_completion",completion_key);
    completion_key[24*8+:64]=2;consume_action(completion_key,0);
    if(!guard_active || !guard_action_active)$fatal(1,"wrong action key released source");
    load_short("guard_completion",completion_key);completion_key[16*8+:32]=3;
    consume_action(completion_key,0);
    if(!guard_active)$fatal(1,"nonterminal action released source");
    load_short("guard_completion",completion_key);completion_key[177*8+:8]=1;
    consume_action(completion_key,0);
    if(!guard_active)$fatal(1,"semantic bad completion released source");
    load_short("guard_completion",completion_key);completion_key[148*8+:16]=0;
    completion_key[16*8+:32]=79;consume_action(completion_key,0);
    if(!guard_active)$fatal(1,"LOCAL_REJECT OK completion released source");
    load_short("guard_completion",completion_key);consume_action(completion_key,1);
    if(guard_active || guard_action_active || !base_change_ready || guard_error)
      $fatal(1,"safe error consumption did not release clean guard");
    // Same runtime: new proof then cancel before producer admission. Source
    // stays published through the safe action completion's actual consumption.
    normal_query(0,63);
    load_packet("guard_action",packet);action_key=packet[0+:4096];action_key[24*8+:64]=2;
    action_valid=1;tick();action_valid=0;cancel=1;tick();cancel=0;
    load_packet("guard_producer",producer_key);producer_valid=1;
    repeat(12)begin
      if(producer_ready || !guard_active || !guard_match || published_owners!=1 || source_peer_ar!=1)
        $fatal(1,"prestart cancel consumed/recycled guarded source");
      tick();
    end
    producer_valid=0;load_short("guard_completion",completion_key);completion_key[24*8+:64]=2;
    consume_action(completion_key,1);repeat(4)tick();
    if(guard_active || cancel_pending || published_owners!=0 || active_owners!=0 || guard_error)
      $fatal(1,"cancel safe consumption did not finish hub cleanup");
    normal_query(E_BUFFER,3);
    if(guard_active || producer_occupancy || action_occupancy || source_peer_ar!=1 || source_peer_r!=64 ||
       accepted_events!=20 || terminal_tasks!=5 || snapshot_sequence_high_water!=next_snapshot-1)
      $fatal(1,"source guard final highwater/debt/owner/FIFO mismatch");
    $display("FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_RTL_PASS cycles=%0d source_AR=1 source_R=64 read_debt=0 source_mutation_alias_epoch_rejected=1 different_role_rejected=1 conflict_response_held=1 old_partial_END_after_conflict=1 typed5_once=1 live_base_recheck=1 producer_identity_epoch_rejected=1 action_key_nonterminal_retained=1 depth2_tail2_tail1=1 safe_error_consumed_release=1 prestart_cancel_retained=1 readonly_snapshot=1 controlled_keys_completion=1 no_generated_producer_executor=1",cycles);
    $finish;
  end
endmodule
