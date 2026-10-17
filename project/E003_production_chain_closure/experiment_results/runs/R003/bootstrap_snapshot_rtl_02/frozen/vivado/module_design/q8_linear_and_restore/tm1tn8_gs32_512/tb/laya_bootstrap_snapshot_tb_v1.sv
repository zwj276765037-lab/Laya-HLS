`timescale 1ns/1ps
module laya_bootstrap_snapshot_tb_v1;
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
  laya_generated_provenance_hub_v1 #(.ENABLE_BOOTSTRAP_SNAPSHOT(1)) hub(
    .clk,.rst_n,.request_valid,.request_ready,.request,.cancel,
    .begin_external_ready(begin_ready),.begin_external_supported(begin_supported),
    .physical_observation_valid,.physical_observation_ready,
    .physical_status(request[ACTION*8+:16]==END_EVENT ? monitor_status : 16'd0),
    .physical_error_detail(request[ACTION*8+:16]==END_EVENT ? monitor_error_detail : 32'd0),
    .physical_bad_element(request[ACTION*8+:16]==END_EVENT ? monitor_bad_element : 64'hffffffffffffffff),
    .physical_observed_store_bytes0(request[ACTION*8+:16]==END_EVENT ? monitor_observed0 : 64'd0),
    .physical_observed_store_bytes1(64'd0),.physical_drained(monitor_drained),
    .physical_coverage_complete(request[ACTION*8+:16]==END_EVENT ? monitor_coverage_complete : 1'b1),
    .source_query_valid(1'b0),.source_query_command(8192'd0),
    .source_release_valid(1'b0),.source_release_command(8192'd0),.source_release_drained(1'b0),
    .response_valid,.response_ready,.response,.scope_active,.domain_drained,.cancel_pending,
    .active_owners,.published_owners,.accepted_events,.semantic_rejections,.terminal_tasks,
    .snapshot_request_valid,.snapshot_request_ready,.snapshot_request,
    .snapshot_response_valid,.snapshot_response_ready,.snapshot_response,
    .snapshot_physical_quiescent,.snapshot_base_valid,.snapshot_base_epoch,
    .snapshot_base_address,.snapshot_base_capacity,.snapshot_sequence_high_water);
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
  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic load_packet(input string name,output logic [8191:0] value);
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

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    $readmemh({fixture,"/snapshot.hex"},snapshot_beats);
    for(int i=0;i<12;i++)snapshot_gold[i*512+:512]=snapshot_beats[i];
    repeat(5)tick();rst_n=1;tick();
    phase=1;normal_query(E_BUFFER,3); // No owner.
    send_event("claim");normal_query(E_BUFFER,3); // Unpublished.
    for(int window=0;window<4;window++)begin
      phase=2+window;send_event($sformatf("begin%0d",window));
      snapshot_request=snapshot_gold;snapshot_request_valid=1;
      repeat(8)begin if(snapshot_request_ready)$fatal(1,"snapshot admitted active scope");tick();end
      snapshot_request_valid=0;
      for(int row=0;row<16;row++)
        drive_burst(BO_BASE+64'(window*16+row)*4096,64,0,0,row==15);
      if(monitor_drained || retired_b!=window*16+15)$fatal(1,"last B debt not retained");
      s_axi_bready=1;tick();s_axi_bready=0;tick();
      send_event($sformatf("end%0d",window),window==3);
      if(window==3)begin
        snapshot_request=snapshot_gold;snapshot_request_valid=1;
        repeat(8)begin if(snapshot_request_ready)$fatal(1,"snapshot admitted held END return");tick();end
        snapshot_request_valid=0;response_ready=1;tick();response_ready=0;tick();
      end else normal_query(E_BUFFER,3);
    end
    phase=6;send_event("publish");
    if(active_owners!=1 || published_owners!=1 || terminal_tasks!=4 ||
       accepted_events!=10 || forwarded_aw!=64 || forwarded_w!=4096 || retired_b!=64 || domain_drained)
      $fatal(1,"full controlled source prelude mismatch");
    normal_query(0,63);
    phase=7;source_read_debt_zero=0;normal_query(E_PROTOCOL,3);source_read_debt_zero=1;
    adapter_pending_zero=0;normal_query(E_PROTOCOL,3);adapter_pending_zero=1;
    snapshot_base_epoch=8;normal_query(E_PROTOCOL,3);snapshot_base_epoch=7;
    snapshot_base_address=BO_BASE+4096;normal_query(E_PROTOCOL,3);snapshot_base_address=BO_BASE;
    for(int bad=0;bad<6;bad++)begin
      query=snapshot_gold;query[16*8+:64]=next_snapshot;next_snapshot=next_snapshot+1;
      case(bad)
        0:query[64*8+:64]=1102;
        1:query[72*8+:64]=52;
        2:query[576*8+:32]=2;
        3:query[(576+28)*8+:8]=7;
        4:query[(576+22)*8+:16]=16;
        5:query[160*8+:8]=query[160*8+:8]^1;
      endcase
      snapshot(query,bad<3 ? E_BUFFER : E_ABI,bad<3 ? 32'd3 : 32'd0);
    end
    phase=8;normal_query(0,63);
    snapshot(query,E_PROTOCOL,3); // The immediately preceding key is stale.
    query=snapshot_gold;query[16*8+:64]=next_snapshot;next_snapshot=next_snapshot+1;
    snapshot(query,0,63,1);held_snapshot=snapshot_response;
    load_packet("invalidate",request);request_valid=1;
    repeat(12)begin
      if(!snapshot_response_valid || snapshot_response!==held_snapshot || request_ready)
        $fatal(1,"snapshot response/source changed under backpressure");
      tick();
    end
    request_valid=0;snapshot_response_ready=1;tick();snapshot_response_ready=0;tick();
    if(accepted_events!=10 || terminal_tasks!=4 || published_owners!=1)
      $fatal(1,"readonly query changed production counters/owner");
    phase=9;send_event("invalidate");normal_query(E_BUFFER,3);
    if(active_owners!=0 || published_owners!=0 || terminal_tasks!=4 ||
       snapshot_sequence_high_water!=next_snapshot-1 || snapshot_response_valid || response_valid)
      $fatal(1,"snapshot final state mismatch");
    $display("FULL_CURRENT_BOOTSTRAP_SNAPSHOT_RTL_PASS cycles=%0d prelude_tasks=4 prelude_events=10 source_aw=64 source_w=4096 source_b=64 source_bytes=262144 readonly=1 full_owner=1 query_backpressure=1 scope_return_debt_base_negatives=1 stale=1 snapshot_only_no_source_read_guard=1",cycles);
    $finish;
  end
endmodule
