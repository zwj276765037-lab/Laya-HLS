`timescale 1ns/1ps
// Controlled LTX and AXI producer peers; actual generated F10, frozen sidecar,
// and one actual managed portal/hub. No executor or full tensor claim.
module laya_executor_adapter_lpv_generated_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;
  logic [511:0] provenance_cmd_din,provenance_rsp_dout;
  logic provenance_cmd_write,provenance_cmd_full_n;
  logic provenance_rsp_empty_n,provenance_rsp_read;
  logic [63:0] monitored_bo_base=BO_BASE;
  logic adapter_pending_zero;
  logic lpv_admission_valid=0,lpv_admission_ready,lpv_admission_accepted;
  logic [8191:0] lpv_admission_record=0,lpv_owner_record,lpv_frame_owner;
  logic lpv_revoke_valid=0,lpv_candidate_valid,lpv_candidate_route;
  logic [8191:0] lpv_revoke_owner=0,lpv_candidate_owner;
  logic lpv_pending_valid,lpv_pending_route;
  logic [8191:0] lpv_pending_owner,lpv_pending_packet;
  logic lpv_response_route;
  logic [8191:0] lpv_response_owner;
  logic lpv_owner_installed,lpv_owner_revoked,lpv_frame_owned,lpv_frame_route;
  logic [63:0] snapshot_base_epoch=7;
  logic [511:0] executor_provenance_cmd_din=0;
  logic executor_provenance_cmd_write=0,executor_provenance_cmd_full_n;
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

  laya_generated_provenance_axi_portal_v1 #(.MONITORED_ROLE(6),.MANAGED_LPV_OWNER(1)) portal(
    .checkpoint_start_permit(1'b0),.checkpoint_owner_revoked(1'b0),.checkpoint_executor_route(1'b0),
    .checkpoint_owner_key(8192'd0),.checkpoint_closed_valid(1'b0),.checkpoint_closed_key(8192'd0),
    .checkpoint_ingress_started(),.checkpoint_query_accepted(),.checkpoint_query_drained(),.checkpoint_query_request(),
    
    .checkpoint_command_din(512'd0),.checkpoint_command_write(1'b0),.checkpoint_command_full_n(),
    .checkpoint_response_dout(),.checkpoint_response_empty_n(),.checkpoint_response_read(1'b0),
    .executor_provenance_cmd_din,.executor_provenance_cmd_write,.executor_provenance_cmd_full_n,
    .checkpoint_dispatch_held(),.checkpoint_handoff_complete(),.checkpoint_handoff_pulse(),
    .checkpoint_authority_valid(),.checkpoint_protocol_error(),.checkpoint_accepted_queries(),
    .checkpoint_consumed_responses(),.checkpoint_sequence_high_water(),.checkpoint_handoff_high_water(),
    .checkpoint_command_occupancy(),.checkpoint_response_occupancy(),
    .snapshot_request_valid(1'b0),.snapshot_request_ready(),.snapshot_request(6144'd0),
    .snapshot_response_valid(),.snapshot_response_ready(1'b0),.snapshot_response(),
    .snapshot_base_valid(1'b1),.snapshot_base_epoch,
    .snapshot_base_address(BO_BASE),.snapshot_base_capacity(64'd16920576),
    .snapshot_sequence_high_water(),.bootstrap_source_guard_active(1'b0),
    .bootstrap_source_guard_key(6144'd0),.bootstrap_source_guard_match(),
    .bootstrap_physical_safe(),.*);


  logic [511:0] transaction_request_dout,transaction_completion_din;
  logic transaction_request_empty_n,transaction_request_read;
  logic transaction_completion_full_n,transaction_completion_write;
  logic [511:0] compute_command_din,compute_response_dout;
  logic compute_command_full_n,compute_command_write,compute_response_empty_n,compute_response_read;
  logic [511:0] raw_cmd_din,raw_rsp_dout,producer_request_din,producer_completion_dout;
  logic raw_cmd_write,raw_cmd_full_n,raw_rsp_empty_n,raw_rsp_read;
  logic producer_request_full_n,producer_request_write,producer_completion_empty_n,producer_completion_read;
  logic ltx_in_valid=0,ltx_in_ready,ltx_out_valid,ltx_out_ready;
  logic [511:0] ltx_in_data=0;
  logic [1:0] ltx_occupancy,ltc_occupancy,unused_cc_occupancy,unused_cr_occupancy;
  logic [1:0] unused_pr_occupancy,unused_pc_occupancy;
  logic ltc_valid,ltc_read=0;
  logic [511:0] ltc_data;
  logic unused_cc_valid,unused_pr_valid;
  logic [511:0] unused_cc_data,unused_pr_data;
  laya_private_fifo2_v1 ltx_fifo(.clk,.rst_n,.in_valid(ltx_in_valid),.in_ready(ltx_in_ready),
    .in_data(ltx_in_data),.out_valid(ltx_out_valid),.out_ready(ltx_out_ready),
    .out_data(transaction_request_dout),.occupancy(ltx_occupancy));
  laya_private_fifo2_v1 ltc_fifo(.clk,.rst_n,.in_valid(transaction_completion_write),
    .in_ready(transaction_completion_full_n),.in_data(transaction_completion_din),
    .out_valid(ltc_valid),.out_ready(ltc_read),.out_data(ltc_data),.occupancy(ltc_occupancy));
  // The four unused adapter interfaces are actual empty controlled depth2 peers.
  // Any compute/producer traffic is a failure for this provenance-only test.
  laya_private_fifo2_v1 unused_compute_command(.clk,.rst_n,.in_valid(compute_command_write),
    .in_ready(compute_command_full_n),.in_data(compute_command_din),
    .out_valid(unused_cc_valid),.out_ready(1'b0),.out_data(unused_cc_data),.occupancy(unused_cc_occupancy));
  laya_private_fifo2_v1 unused_compute_response(.clk,.rst_n,.in_valid(1'b0),.in_ready(),
    .in_data(512'd0),.out_valid(compute_response_empty_n),.out_ready(compute_response_read),
    .out_data(compute_response_dout),.occupancy(unused_cr_occupancy));
  laya_private_fifo2_v1 unused_producer_request(.clk,.rst_n,.in_valid(producer_request_write),
    .in_ready(producer_request_full_n),.in_data(producer_request_din),
    .out_valid(unused_pr_valid),.out_ready(1'b0),.out_data(unused_pr_data),.occupancy(unused_pr_occupancy));
  laya_private_fifo2_v1 unused_producer_completion(.clk,.rst_n,.in_valid(1'b0),.in_ready(),
    .in_data(512'd0),.out_valid(producer_completion_empty_n),.out_ready(producer_completion_read),
    .out_data(producer_completion_dout),.occupancy(unused_pc_occupancy));

  logic txn_start,txn_done,txn_route=0,txn_start_ready;
  logic txn_owned,txn_revoked,txn_drained,sidecar_error;
  logic [4:0] command_captured,command_sent;
  logic [3:0] response_received,response_consumed;
  logic [1:0] sidecar_response_occupancy;
  logic [31:0] transactions_started,transactions_released,invalid_done;
  logic [511:0] sc_portal_cmd,sc_adapter_rsp;
  logic sc_portal_write,sc_portal_full_n,sc_portal_read;
  logic sc_adapter_full_n,sc_adapter_empty_n;
  // These gates supply controlled link backpressure only. Both sides count the
  // same actual handshake; all A/route/pending fields come from the sidecar.
  logic raw_link_open=1,command_link_open=1,portal_return_open=1,adapter_return_open=1;
  integer ltx_pops=0,raw_pushes=0,portal_pushes=0,portal_pops=0,adapter_pops=0;
  integer ltc_writes=0,ltc_pops=0;
  wire ltx_pop=transaction_request_read && transaction_request_empty_n;
  wire ltc_pop=ltc_valid && ltc_read;
  assign transaction_request_empty_n=ltx_out_valid && (txn_owned || txn_start_ready);
  assign ltx_out_ready=ltx_pop;
  assign txn_start=ltx_pop && (ltx_pops%24)==0;
  assign txn_done=ltc_pop && (ltc_pops%16)==15;
  assign raw_cmd_full_n=sc_adapter_full_n && raw_link_open;
  assign provenance_cmd_din=sc_portal_cmd;
  assign provenance_cmd_write=sc_portal_write && command_link_open;
  assign sc_portal_full_n=provenance_cmd_full_n && command_link_open;
  assign provenance_rsp_read=sc_portal_read && portal_return_open;
  assign raw_rsp_dout=sc_adapter_rsp;
  assign raw_rsp_empty_n=sc_adapter_empty_n && adapter_return_open;
  laya_executor_adapter_lpv_owner_v1 sidecar(
    .clk,.rst_n,.cancel,.installed_owner_valid(lpv_owner_installed),
    .owner_revoked(lpv_owner_revoked),.installed_owner(lpv_owner_record),
    .txn_start,.txn_route,.txn_owner(lpv_owner_record),.txn_start_ready,.txn_done,
    .txn_owned,.txn_revoked,.txn_drained,.protocol_error(sidecar_error),
    .adapter_cmd_din(raw_cmd_din),.adapter_cmd_write(raw_cmd_write && raw_link_open),
    .adapter_cmd_full_n(sc_adapter_full_n),.portal_cmd_din(sc_portal_cmd),
    .portal_cmd_write(sc_portal_write),.portal_cmd_full_n(sc_portal_full_n),
    .portal_rsp_dout(provenance_rsp_dout),
    .portal_rsp_empty_n(provenance_rsp_empty_n && portal_return_open),
    .portal_rsp_read(sc_portal_read),.adapter_rsp_dout(sc_adapter_rsp),
    .adapter_rsp_empty_n(sc_adapter_empty_n),
    .adapter_rsp_read(raw_rsp_read && adapter_return_open),
    .lpv_candidate_valid,.lpv_candidate_route,.lpv_candidate_owner,
    .lpv_pending_valid,.lpv_pending_route,.lpv_pending_owner,.lpv_pending_packet,
    .lpv_response_route,.lpv_response_owner,.command_captured,.command_sent,
    .response_received,.response_consumed,.response_occupancy(sidecar_response_occupancy),
    .transactions_started,.transactions_released,.invalid_done);
  laya_controller_transaction_adapter_shell_v1 f10(
    .ap_clk(clk),.ap_rst(!rst_n),.cancel,.transaction_request_dout,
    .transaction_request_empty_n,.transaction_request_read,.transaction_completion_din,
    .transaction_completion_full_n,.transaction_completion_write,
    .transaction_completion_consumer_read(ltc_read),
    .transaction_completion_consumer_empty_n(ltc_valid),
    .compute_command_din,.compute_command_full_n,.compute_command_write,
    .compute_response_dout,.compute_response_empty_n,.compute_response_read,
    .provenance_command_din(raw_cmd_din),.provenance_command_full_n(raw_cmd_full_n),
    .provenance_command_write(raw_cmd_write),.provenance_response_dout(raw_rsp_dout),
    .provenance_response_empty_n(raw_rsp_empty_n),.provenance_response_read(raw_rsp_read),
    .producer_request_din,.producer_request_full_n,.producer_request_write,
    .producer_completion_dout,.producer_completion_empty_n,.producer_completion_read);

  // Controlled producer-local fence, causally created by a real upstream AW.
  // It keeps a local finish obligation after its final B is actually consumed.
  // A valid/ready finish edge can clear it only after that B. It is independent
  // of the current LPV transaction and is not sidecar.txn_drained.
  logic producer_owed=0,producer_b_owed=0,producer_finish_ready=0;
  wire producer_finish_valid=producer_owed && !producer_b_owed;
  wire producer_finish_fire=producer_finish_valid && producer_finish_ready;
  assign adapter_pending_zero=!producer_owed;
  integer producer_finishes=0,upstream_aw=0,upstream_w=0,upstream_b=0;
  logic peer_aw_seen=0;
  integer peer_aw=0,peer_w=0,peer_b=0;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      producer_owed<=0;producer_b_owed<=0;producer_finishes<=0;
      upstream_aw<=0;upstream_w<=0;upstream_b<=0;
      peer_aw_seen<=0;m_axi_bvalid<=0;peer_aw<=0;peer_w<=0;peer_b<=0;
    end else begin
      if(s_axi_awvalid && s_axi_awready)begin
        if(producer_owed)$fatal(1,"controlled producer accepted a second AW");
        producer_owed<=1;producer_b_owed<=1;upstream_aw<=upstream_aw+1;
      end
      if(s_axi_wvalid && s_axi_wready)upstream_w<=upstream_w+1;
      if(s_axi_bvalid && s_axi_bready)begin
        if(!producer_b_owed)$fatal(1,"final B without controlled producer debt");
        producer_b_owed<=0;upstream_b<=upstream_b+1;
      end
      if(producer_finish_fire)begin
        if(producer_b_owed || upstream_b!=1)$fatal(1,"producer fence passed before actual final B");
        producer_owed<=0;producer_finishes<=producer_finishes+1;
      end
      if(m_axi_awvalid && m_axi_awready)begin
        if(peer_aw_seen || m_axi_awaddr!=BO_BASE || m_axi_awlen!=0 ||
           m_axi_awsize!=6 || m_axi_awburst!=1)$fatal(1,"memory peer malformed actual AW");
        peer_aw_seen<=1;peer_aw<=peer_aw+1;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(!peer_aw_seen || !m_axi_wlast || m_axi_wstrb!='1 ||
           m_axi_wdata!={8{BO_BASE}})$fatal(1,"memory peer actual W mismatch");
        peer_w<=peer_w+1;m_axi_bvalid<=1;
      end
      if(m_axi_bvalid && m_axi_bready)begin
        m_axi_bvalid<=0;peer_aw_seen<=0;peer_b<=peer_b+1;
      end
    end
  end

  string fixture,capture;
  integer selected_case=0,cycles=0,phase=0;
  logic expected_valid=0,probe_must_block=0;
  logic [511:0] expected_ltx[0:23],expected_lpv[0:15],expected_lpa[0:7],expected_ltc[0:15];
  logic [8191:0] expected_packet;
  integer old_ltx=0,old_raw=0,old_cmd=0,old_prsp=0,old_arsp=0,old_ltcw=0,old_ltcr=0;
  logic held_lpa_valid=0,held_ltc_valid=0,held_adapter_valid=0;
  logic [511:0] held_lpa,held_ltc,held_adapter;
  integer capture_ltx,capture_raw,capture_lpa,capture_ltc;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>=500000)$fatal(1,"generated adapter finite cycle cap case=%0d phase=%0d",selected_case,phase);
    if(!rst_n)begin
      ltx_pops<=0;raw_pushes<=0;portal_pushes<=0;portal_pops<=0;adapter_pops<=0;
      ltc_writes<=0;ltc_pops<=0;held_lpa_valid<=0;held_ltc_valid<=0;held_adapter_valid<=0;
    end else begin
      if(compute_command_write || compute_response_read || producer_request_write || producer_completion_read)
        $fatal(1,"unexpected unused adapter channel traffic");
      if(sidecar_error || invalid_done!=0 || protocol_error)$fatal(1,"actual transport protocol error");
      if(held_lpa_valid && (!provenance_rsp_empty_n || provenance_rsp_dout!==held_lpa))
        $fatal(1,"actual portal return changed under backpressure");
      if(held_ltc_valid && (!ltc_valid || ltc_data!==held_ltc))
        $fatal(1,"actual LTC FIFO changed under caller backpressure");
      if(held_adapter_valid && (!sc_adapter_empty_n || sc_adapter_rsp!==held_adapter))
        $fatal(1,"sidecar return changed under generated adapter backpressure");
      held_lpa_valid<=provenance_rsp_empty_n && !portal.transport.rsp_pop;
      held_ltc_valid<=ltc_valid && !ltc_pop;
      held_adapter_valid<=sc_adapter_empty_n && !(raw_rsp_read && raw_rsp_empty_n);
      held_lpa<=provenance_rsp_dout;held_ltc<=ltc_data;held_adapter<=sc_adapter_rsp;
      if(txn_owned && (!lpv_candidate_valid || lpv_candidate_owner!==lpv_admission_record ||
          lpv_candidate_route!=0 || lpv_response_route!=0 || lpv_response_owner!==lpv_admission_record))
        $fatal(1,"sidecar retained A/route rebound");
      if(lpv_pending_valid && (lpv_pending_owner!==lpv_admission_record || lpv_pending_route!=0 ||
          lpv_pending_packet!==expected_packet || command_captured!=16))
        $fatal(1,"sidecar pending did not come from actual complete 16 pushes");
      if(lpv_frame_owned && (lpv_frame_owner!==lpv_admission_record || lpv_frame_route!=0))
        $fatal(1,"actual portal frame A/route mismatch");
      if(portal.transport.rsp_pop!==provenance_rsp_read)
        $fatal(1,"portal tagged return pop differs from actual sidecar handshake");
      if(ltx_pop)begin
        if(probe_must_block || !expected_valid ||
            transaction_request_dout!==expected_ltx[ltx_pops-old_ltx])
          $fatal(1,"actual LTX pop mismatch/early next request phase=%0d beat=%0d",phase,ltx_pops-old_ltx);
        $fdisplay(capture_ltx,"%0128h",transaction_request_dout);ltx_pops<=ltx_pops+1;
      end
      if(raw_cmd_write && raw_cmd_full_n)begin
        if(!expected_valid || raw_cmd_din!==expected_lpv[raw_pushes-old_raw])
          $fatal(1,"actual generated LPV push mismatch phase=%0d beat=%0d",phase,raw_pushes-old_raw);
        $fdisplay(capture_raw,"%0128h",raw_cmd_din);raw_pushes<=raw_pushes+1;
      end
      if(provenance_cmd_write && provenance_cmd_full_n)begin
        if(command_captured!=16 || !lpv_pending_valid ||
            provenance_cmd_din!==expected_lpv[portal_pushes-old_cmd])
          $fatal(1,"actual portal command mismatch or premature first beat");
        portal_pushes<=portal_pushes+1;
      end
      if(portal.transport.rsp_pop)begin
        if(provenance_rsp_dout!==expected_lpa[portal_pops-old_prsp])
          $fatal(1,"actual LPA pop differs from independent literal phase=%0d beat=%0d",phase,portal_pops-old_prsp);
        $fdisplay(capture_lpa,"%0128h",provenance_rsp_dout);portal_pops<=portal_pops+1;
      end
      if(raw_rsp_read && raw_rsp_empty_n)begin
        if(raw_rsp_dout!==expected_lpa[adapter_pops-old_arsp])
          $fatal(1,"actual generated adapter return pop mismatch");
        adapter_pops<=adapter_pops+1;
      end
      if(transaction_completion_write && transaction_completion_full_n)begin
        if(transaction_completion_din!==expected_ltc[ltc_writes-old_ltcw])
          $fatal(1,"actual normalized LTC write mismatch phase=%0d beat=%0d",phase,ltc_writes-old_ltcw);
        ltc_writes<=ltc_writes+1;
      end
      if(ltc_pop)begin
        if(ltc_data!==expected_ltc[ltc_pops-old_ltcr])
          $fatal(1,"actual final caller LTC pop mismatch phase=%0d beat=%0d",phase,ltc_pops-old_ltcr);
        $fdisplay(capture_ltc,"%0128h",ltc_data);ltc_pops<=ltc_pops+1;
      end
    end
  end

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic load_transaction(input string name);
    if(txn_owned || ltc_occupancy!=0 || sidecar_response_occupancy!=0)
      $fatal(1,"changed independent oracle during old debt");
    $readmemh({fixture,"/",name,"_ltx.hex"},expected_ltx);
    $readmemh({fixture,"/",name,".hex"},expected_lpv);
    $readmemh({fixture,"/",name,"_gold.hex"},expected_lpa);
    $readmemh({fixture,"/",name,"_ltc.hex"},expected_ltc);
    for(int i=0;i<16;i++)expected_packet[i*512+:512]=expected_lpv[i];
    old_ltx=ltx_pops;old_raw=raw_pushes;old_cmd=portal_pushes;
    old_prsp=portal_pops;old_arsp=adapter_pops;old_ltcw=ltc_writes;old_ltcr=ltc_pops;
    expected_valid=1;probe_must_block=0;phase=phase+1;
  endtask
  task automatic push_ltx(input logic [511:0] value);
    ltx_in_data=value;ltx_in_valid=1;
    do begin @(posedge clk);end while(!ltx_in_ready);
    #1;@(negedge clk);ltx_in_valid=0;
  endtask
  task automatic send_ltx(input integer first,after);
    for(int i=first;i<after;i++)push_ltx(expected_ltx[i]);
  endtask
  task automatic queue_next_two;
    logic [511:0] next_ltx[0:23];
    $readmemh({fixture,"/active_invalidate_ltx.hex"},next_ltx);
    probe_must_block=1;push_ltx(next_ltx[0]);push_ltx(next_ltx[1]);
    if(ltx_occupancy!=2)$fatal(1,"next controlled LTX was not physically queued");
  endtask
  task automatic receive_ltc(input logic queue_cleanup);
    logic [511:0] held;
    for(int i=0;i<16;i++)begin
      while(!ltc_valid)tick();
      held=ltc_data;
      if(i==14 && queue_cleanup)queue_next_two();
      if(i>=14)repeat(12)begin
        if(!txn_owned || txn_start_ready || !f10.awaiting_completion_consumption ||
            ltc_pops-old_ltcr!=i || !ltc_valid || ltc_data!==held ||
            lpv_candidate_owner!==lpv_admission_record || lpv_candidate_route!=0)
          $fatal(1,"LTC tail released real transaction ownership early beat=%0d",i);
        if(queue_cleanup && (ltx_pops-old_ltx!=24 || ltx_occupancy!=2))
          $fatal(1,"queued next LTX passed actual F10 final caller pop fence");
        tick();
      end
      ltc_read=1;tick();ltc_read=0;
    end
    if(txn_owned || !txn_drained || ltc_occupancy!=0 || sidecar_response_occupancy!=0 ||
        ltx_pops-old_ltx!=24 || raw_pushes-old_raw!=16 || portal_pushes-old_cmd!=16 ||
        portal_pops-old_prsp!=8 || adapter_pops-old_arsp!=8 ||
        ltc_writes-old_ltcw!=16 || ltc_pops-old_ltcr!=16 ||
        f10.awaiting_completion_consumption || f10.adapter.state!=0 ||
        f10.adapter.beat!=0 || f10.adapter.cancel_at_accept!=0 ||
        lpv_frame_owned || transport_busy || command_fifo_occupancy!=0 || response_fifo_occupancy!=0)
      $fatal(1,"actual adapter terminal/24_16_8_16 drain mismatch phase=%0d state=%0d beat=%0d",
        phase,f10.adapter.state,f10.adapter.beat);
    if(!lpv_owner_installed || lpv_owner_record!==lpv_admission_record)
      $fatal(1,"final LTC caller pop released external installed A");
    $display("GENERATED_ADAPTER_TRANSACTION_PASS case=%0d phase=%0d actual_LTX=24 actual_LPV=16 actual_LPA=8 actual_LTC=16 HLS_state=0 HLS_beat=0 caller_final_pop=1 cycles=%0d",selected_case,phase,cycles);
  endtask
  task automatic transact(input string name);
    load_transaction(name);send_ltx(0,24);receive_ltc(0);
  endtask
  task automatic drive_store;
    logic aw_done,w_done,aw_fire,w_fire;
    aw_done=0;w_done=0;s_axi_bready=0;
    s_axi_awaddr=BO_BASE;s_axi_awlen=0;s_axi_awsize=6;s_axi_awburst=1;
    s_axi_wdata={8{BO_BASE}};s_axi_wstrb='1;s_axi_wlast=1;
    s_axi_awvalid=1;s_axi_wvalid=1;
    while(!aw_done || !w_done)begin
      @(posedge clk);aw_fire=s_axi_awvalid && s_axi_awready;
      w_fire=s_axi_wvalid && s_axi_wready;#1;
      if(aw_fire)begin aw_done=1;s_axi_awvalid=0;end
      if(w_fire)begin w_done=1;s_axi_wvalid=0;end
      @(negedge clk);
    end
    while(!s_axi_bvalid)tick();
    if(s_axi_bresp!=0 || !producer_owed || !producer_b_owed || adapter_pending_zero ||
        monitor_observed0!=64 || upstream_aw!=1 || upstream_w!=1 || upstream_b!=0 ||
        peer_aw!=1 || peer_w!=1 || peer_b!=1 || retired_b!=0)
      $fatal(1,"real held final B did not create monitor/producer debt");
  endtask
  task automatic drain_physical_end;
    while(!portal.hub.pending_end)begin
      if(provenance_rsp_empty_n || terminal_tasks!=0)$fatal(1,"END passed before actual hub pending acceptance");tick();
    end
    repeat(12)begin
      if(!portal.hub.pending_end || provenance_rsp_empty_n || terminal_tasks!=0 ||
          !s_axi_bvalid || monitor_drained || adapter_pending_zero)
        $fatal(1,"END passed held actual final B");tick();
    end
    s_axi_bready=1;tick();s_axi_bready=0;
    repeat(12)begin
      if(provenance_rsp_empty_n || terminal_tasks!=0 || monitor_drained || adapter_pending_zero ||
          s_axi_bvalid || !producer_finish_valid || upstream_b!=1 || retired_b!=1)
        $fatal(1,"END passed independent controlled producer-local finish fence");tick();
    end
    producer_finish_ready=1;tick();producer_finish_ready=0;
    if(!adapter_pending_zero || producer_finishes!=1)$fatal(1,"real controlled finish edge was not observed");
  endtask
  task automatic hold_return_tails;
    adapter_return_open=1;
    while(response_received<6)tick();portal_return_open=0;
    if(response_received!=6)$fatal(1,"missed actual LPA remaining-two breakpoint");
    repeat(12)begin
      if(response_received!=6 || !provenance_rsp_empty_n || !txn_owned ||
          lpv_response_owner!==lpv_admission_record || lpv_response_route!=0)
        $fatal(1,"old LPA remaining-two return rebound");tick();
    end
    portal_return_open=1;while(response_received<7)tick();portal_return_open=0;
    if(response_received!=7)$fatal(1,"expected exactly one real old LPA pop");
    repeat(12)begin
      if(response_received!=7 || !provenance_rsp_empty_n || !txn_owned)
        $fatal(1,"old LPA final return lost");tick();
    end
    portal_return_open=1;
  endtask
  task automatic assert_blocked_cleanup_gap;
    cancel=0;snapshot_base_epoch=7;txn_route=0;
    repeat(12)begin
      if(txn_start_ready || transaction_request_read || ltx_occupancy!=2 ||
          !txn_revoked || !lpv_owner_revoked || !lpv_owner_installed ||
          lpv_owner_record!==lpv_admission_record)
        $fatal(1,"frozen sidecar unexpectedly reopened cleanup after sticky revoke");tick();
    end
    $display("GENERATED_ADAPTER_KNOWN_GAP case=%0d frozen_sidecar_new_cleanup_blocked=1 queued_cleanup_first2=1 cleanup_NOT_RUN=1",selected_case);
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture) || !$value$plusargs("CAPTURE=%s",capture) ||
        !$value$plusargs("CASE=%d",selected_case))$fatal(1,"FIXTURE/CAPTURE/CASE missing");
    if(selected_case<0 || selected_case>3)$fatal(1,"unknown finite case");
    capture_ltx=$fopen({capture,"/actual_ltx.hex"},"w");
    capture_raw=$fopen({capture,"/actual_generated_lpv.hex"},"w");
    capture_lpa=$fopen({capture,"/actual_portal_lpa.hex"},"w");
    capture_ltc=$fopen({capture,"/actual_caller_ltc.hex"},"w");
    if(!capture_ltx || !capture_raw || !capture_lpa || !capture_ltc)$fatal(1,"actual capture open failed");
    repeat(4)tick();rst_n=1;repeat(2)tick();
    $readmemh({fixture,"/admission.hex"},expected_lpv);
    for(int i=0;i<16;i++)lpv_admission_record[i*512+:512]=expected_lpv[i];
    if(!laya_admission_owner_layout_v1::record_ok(lpv_admission_record))
      $fatal(1,"actual captured complete A failed executed full SV codec");
    lpv_admission_valid=1;#1;
    if(!lpv_admission_accepted)$fatal(1,"actual whole A install was not accepted");
    tick();lpv_admission_valid=0;
    if(!lpv_owner_installed || lpv_owner_record!==lpv_admission_record || !txn_start_ready)
      $fatal(1,"actual installed A/first LTX admission mismatch");
    if(selected_case==0 || selected_case==1)begin
      transact("active_claim");transact("begin");
      if(!scope_active || !monitor_scope_active || terminal_tasks!=0 || active_owners!=1 || !adapter_pending_zero)
        $fatal(1,"actual CLAIM/BEGIN did not establish one scope");
      drive_store();
      if(selected_case==0)begin
        transact("bad_end");
        if(terminal_tasks!=0 || !scope_active || !monitor_scope_active || !s_axi_bvalid || !producer_b_owed)
          $fatal(1,"actual wrong-origin END altered old scope/final B");
      end
      load_transaction("end");send_ltx(0,24);
      if(selected_case==1)begin
        while(command_captured<2)tick();raw_link_open=0;
        if(command_captured!=2 || ltx_pops-old_ltx!=24 || transactions_started!=3 ||
            !txn_owned || f10.adapter.cancel_at_accept!=0 || portal_pushes-old_cmd!=0)
          $fatal(1,"cancel was not after actual old END first LTX acceptance/raw partial frame");
        cancel=1;snapshot_base_epoch=8;txn_route=1;tick();
        repeat(12)begin
          if(command_captured!=2 || portal_pushes-old_cmd!=0 || !txn_owned ||
              !txn_revoked || !lpv_owner_revoked)$fatal(1,"cancel lost actual partial generated LPV");tick();
        end
        raw_link_open=1;
        while(command_sent<2)tick();command_link_open=0;
        if(command_sent!=2 || command_captured!=16 || !lpv_frame_owned)
          $fatal(1,"actual portal partial frame not retained");
        repeat(12)begin
          if(command_sent!=2 || !lpv_pending_valid || !lpv_frame_owned ||
              lpv_frame_owner!==lpv_admission_record || lpv_frame_route!=0)
            $fatal(1,"old half portal frame lost A/route under persistent revoke");tick();
        end
        command_link_open=1;adapter_return_open=0;
      end
      drain_physical_end();
      if(selected_case==1)begin
        while(sidecar_response_occupancy<2)tick();
        repeat(12)begin
          if(sidecar_response_occupancy!=2 || response_consumed!=0 || !txn_owned || !cancel)
            $fatal(1,"actual old private return FIFO lost response backpressure");tick();
        end
        hold_return_tails();receive_ltc(1);
        if(terminal_tasks!=1 || scope_active || monitor_scope_active || active_owners!=1 ||
            transactions_started!=3 || transactions_released!=3 || !txn_revoked ||
            forwarded_aw!=1 || forwarded_w!=1 || retired_b!=1 || producer_finishes!=1)
          $fatal(1,"actual pre-cancel END did not retire once after independent physical debts");
        assert_blocked_cleanup_gap();
      end else begin
        receive_ltc(1);
        if(terminal_tasks!=1 || scope_active || monitor_scope_active || active_owners!=1 ||
            transactions_started!=4 || transactions_released!=4)
          $fatal(1,"normal actual END did not retire exactly once");
        load_transaction("active_invalidate");send_ltx(2,24);receive_ltc(0);
        if(active_owners!=0 || !domain_drained || terminal_tasks!=1 || last_event_seq!=34 ||
            transactions_started!=5 || transactions_released!=5 || accepted_requests!=5 || retired_responses!=5 ||
            forwarded_aw!=1 || forwarded_w!=1 || retired_b!=1 || producer_finishes!=1)
          $fatal(1,"actual normal lifecycle count/unique retirement mismatch");
      end
    end else if(selected_case==2)begin
      load_transaction("claim");portal_return_open=0;adapter_return_open=0;send_ltx(0,24);
      while(!provenance_rsp_empty_n)tick();
      cancel=1;snapshot_base_epoch=8;txn_route=1;tick();
      repeat(12)begin
        if(portal_pops!=0 || response_consumed!=0 || !provenance_rsp_empty_n ||
            !txn_owned || !lpv_owner_revoked || active_owners!=1 || terminal_tasks!=0)
          $fatal(1,"already presented actual CLAIM return lost old A/route");tick();
      end
      portal_return_open=1;
      while(sidecar_response_occupancy<2)tick();
      repeat(12)begin
        if(response_consumed!=0 || sidecar_response_occupancy!=2 || !txn_owned)
          $fatal(1,"actual CLAIM private response debt was discarded");tick();
      end
      hold_return_tails();receive_ltc(1);
      if(transactions_started!=1 || transactions_released!=1 || active_owners!=1 || terminal_tasks!=0 ||
          forwarded_aw!=0 || forwarded_w!=0 || retired_b!=0 || producer_finishes!=0)
        $fatal(1,"actual revoked CLAIM invented physical/typed retirement");
      assert_blocked_cleanup_gap();
    end else begin
      transact("claim");
      if(active_owners!=1 || terminal_tasks!=0 || scope_active || monitor_scope_active)
        $fatal(1,"actual CLAIM-only created a scope/typed task");
      transact("invalidate");
      if(active_owners!=0 || !domain_drained || terminal_tasks!=0 || scope_active || monitor_scope_active ||
          forwarded_aw!=0 || forwarded_w!=0 || retired_b!=0 || upstream_aw!=0 || upstream_w!=0 ||
          producer_finishes!=0 || transactions_started!=2 || transactions_released!=2 ||
          accepted_requests!=2 || retired_responses!=2 || last_event_seq!=10)
        $fatal(1,"actual CLAIM-only INVALIDATE invented scope/physical/typed work");
    end
    $fclose(capture_ltx);$fclose(capture_raw);$fclose(capture_lpa);$fclose(capture_ltc);
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_CASE_PASS case=%0d transactions=%0d actual_generated=1 actual_sidecar=1 actual_portal=1 controlled_LTX_AXI_fence_peers=1 whole_24_16_8_16=1 final_LTC_owner=1 cycles=%0d",selected_case,transactions_released,cycles);
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_PASS case=%0d unique_hub=1 full_chain_NOT_RUN=1 post_revoke_new_cleanup_NOT_RUN=1 cycles=%0d",selected_case,cycles);
    $finish;
  end
endmodule
