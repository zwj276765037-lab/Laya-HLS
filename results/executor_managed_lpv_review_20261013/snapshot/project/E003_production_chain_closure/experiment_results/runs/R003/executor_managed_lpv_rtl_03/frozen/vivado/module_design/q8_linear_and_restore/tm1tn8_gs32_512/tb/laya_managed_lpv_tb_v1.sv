`timescale 1ns/1ps
module laya_managed_lpv_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;

  logic [511:0] provenance_cmd_din,provenance_rsp_dout;
  logic provenance_cmd_write=0,provenance_cmd_full_n;
  logic provenance_rsp_empty_n,provenance_rsp_read=0;
  logic [63:0] monitored_bo_base=BO_BASE;
  logic adapter_pending_zero=1;
  logic lpv_admission_valid=0,lpv_admission_ready,lpv_admission_accepted;
  logic [8191:0] lpv_admission_record=0,lpv_owner_record,lpv_frame_owner;
  logic lpv_revoke_valid=0,lpv_candidate_valid=1,lpv_candidate_route=0;
  logic [8191:0] lpv_revoke_owner=0,lpv_candidate_owner=0;
  logic lpv_pending_valid=0,lpv_pending_route=0;
  logic [8191:0] lpv_pending_owner=0,lpv_pending_packet=0;
  logic lpv_response_route=0;
  logic [8191:0] lpv_response_owner=0;
  logic lpv_owner_installed,lpv_owner_revoked,lpv_frame_owned,lpv_frame_route;
  logic [63:0] snapshot_base_epoch=7;
  logic [511:0] executor_provenance_cmd_din=0;
  logic executor_provenance_cmd_write=0,executor_provenance_cmd_full_n;
  integer cmd_reads=0,rsp_reads=0,case_cmd0,case_rsp0;
  logic [511:0] held_rsp;logic rsp_was_held=0;
  always @(posedge clk)begin
    if(!rst_n)begin cmd_reads<=0;rsp_reads<=0;rsp_was_held<=0;end
    else begin
      if(provenance_cmd_write && provenance_cmd_full_n)cmd_reads<=cmd_reads+1;
      if(dut.transport.rsp_pop)rsp_reads<=rsp_reads+1;
      if(rsp_was_held && (!provenance_rsp_empty_n || provenance_rsp_dout!==held_rsp))
        $fatal(1,"old LPV response changed before real tagged pop");
      rsp_was_held<=provenance_rsp_empty_n && !dut.transport.rsp_pop;
      held_rsp<=provenance_rsp_dout;
      if(lpv_frame_owned && lpv_frame_owner!==lpv_admission_record)
        $fatal(1,"LPV first-beat A rebound");
    end
  end

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

  laya_generated_provenance_axi_portal_v1 #(.MONITORED_ROLE(6),.MANAGED_LPV_OWNER(1)) dut(
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

  logic peer_aw_seen=0;
  int peer_aw=0,peer_w=0,peer_b=0,peer_w_in_burst=0;
  int peer_expected_beats=0,peer_zero_w=0,cycles=0,phase=0;
  int forwarded_before=0,forwarded_w_before=0,zero_before=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>12000)$fatal(1,"store monitor cycle cap phase=%0d",phase);
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
      repeat(beat>=6 ? 12 : 2)begin
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

  task automatic accept_held_b;
    s_axi_bready=1;tick();s_axi_bready=0;tick();
  endtask

  task automatic send_range(input logic [8191:0] value,input integer first,after);
    for(int beat=first;beat<after;beat++)begin
      provenance_cmd_din=value[beat*512+:512];provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
  endtask

  task automatic literal_result(input string name);
    logic [511:0] gold_beats[0:7];logic [4095:0] gold;
    receive_packet(received);
    $readmemh({fixture,"/",name,"_gold.hex"},gold_beats);
    for(int beat=0;beat<8;beat++)gold[beat*512+:512]=gold_beats[beat];
    if(received!==gold || !response_binding_ok(received,packet))
      $fatal(1,"complete literal response mismatch name=%s status=%0d flags=%0h detail=%08x",
        name,received[24*8+:16],received[26*8+:8],received[28*8+:32]);
    if(lpv_frame_owned || transport_busy || command_fifo_occupancy!=0 || response_fifo_occupancy!=0)
      $fatal(1,"frame released before/without all 16/8 transfers name=%s",name);
  endtask

  task automatic literal_transact(input string name);
    load_packet(name,packet);send_packet(packet);literal_result(name);
  endtask

  task automatic install_case(input integer n);
    rst_n=0;cancel=0;provenance_cmd_write=0;provenance_rsp_read=0;
    lpv_admission_valid=0;lpv_revoke_valid=0;lpv_pending_valid=0;
    lpv_candidate_route=0;lpv_response_route=0;lpv_candidate_valid=1;
    monitored_bo_base=BO_BASE;snapshot_base_epoch=7;adapter_pending_zero=1;
    s_axi_awvalid=0;s_axi_wvalid=0;s_axi_bready=0;
    repeat(4)tick();rst_n=1;repeat(2)tick();
    load_packet("admission",lpv_admission_record);
    if(!laya_admission_owner_layout_v1::record_ok(lpv_admission_record))
      $fatal(1,"actual C++ captured A failed executed SV complete codec");
    for(int mutant=0;mutant<11;mutant++)begin
      logic [8191:0] bad;bad=lpv_admission_record;
      case(mutant)
        0:bad[0+:32]=0;1:bad[4*8+:16]=2;2:bad[6*8+:16]=15;
        3:bad[8*8+:32]=1;4:bad[12*8+:32]=0;5:bad[16*8+:64]=0;
        6:bad[24*8+:64]=0;7:bad[32*8+:8]=1;
        8:bad[148*8+:8]=1;9:bad[720*8+:64]=0;10:bad[888*8+:8]=1;
      endcase
      if(laya_admission_owner_layout_v1::record_ok(bad))$fatal(1,"bad complete A accepted mutant=%0d",mutant);
    end
    lpv_candidate_owner=lpv_admission_record;lpv_response_owner=lpv_admission_record;
    lpv_admission_valid=1;#1;
    if(!lpv_admission_accepted)$fatal(1,"complete A install did not accept");
    tick();lpv_admission_valid=0;
    if(!lpv_owner_installed || lpv_owner_record!==lpv_admission_record)$fatal(1,"A install changed fields");
    // A cannot be replaced by another record or by a per-frame return.
    lpv_admission_valid=1;repeat(3)begin
      if(lpv_admission_ready)$fatal(1,"live A became reusable");tick();
    end
    lpv_admission_valid=0;phase=n;case_cmd0=cmd_reads;case_rsp0=rsp_reads;
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE missing");
    // CLAIM-only owner and already presented successful return survive revoke.
    install_case(1);load_packet("claim",packet);send_packet(packet);
    while(!provenance_rsp_empty_n)tick();
    cancel=1;snapshot_base_epoch=8;
    lpv_candidate_route=1;lpv_response_route=1;
    provenance_rsp_read=1;repeat(12)tick();provenance_rsp_read=0;
    if(rsp_reads!=0 || active_owners!=1 || terminal_tasks!=0 || !lpv_owner_revoked ||
       !lpv_frame_owned || lpv_frame_route!=0)$fatal(1,"CLAIM response lost old A/route under revoke");
    lpv_response_route=0;lpv_response_owner[24*8+:64]=102;
    provenance_rsp_read=1;repeat(12)tick();provenance_rsp_read=0;
    if(rsp_reads!=0)$fatal(1,"wrong full response owner popped old return");
    lpv_response_owner=lpv_admission_record;literal_result("claim");
    cancel=0;snapshot_base_epoch=7;lpv_candidate_route=0;
    if(!lpv_owner_revoked || active_owners!=1 || domain_drained)$fatal(1,"input restore destroyed CLAIM-only owner");
    for(int foreign=0;foreign<2;foreign++)begin
      lpv_candidate_owner=lpv_admission_record;
      lpv_candidate_owner[(foreign==0 ? 16 : 24)*8+:64]=999;
      load_packet("invalidate",packet);provenance_cmd_din=packet[0+:512];provenance_cmd_write=1;
      repeat(12)begin if(provenance_cmd_full_n)$fatal(1,"foreign A gained first-beat candidate");tick();end
      provenance_cmd_write=0;
    end
    lpv_candidate_owner=lpv_admission_record;
    literal_transact("wrong_epoch");literal_transact("wrong_ref");literal_transact("wrong_offset");
    literal_transact("unknown_role");
    if(active_owners!=1 || terminal_tasks!=0)$fatal(1,"wrong cleanup changed real CLAIM-only owner");
    literal_transact("invalidate");
    if(active_owners!=0 || !domain_drained || terminal_tasks!=0 || forwarded_aw!=0 || forwarded_w!=0 ||
       last_event_seq!=10 || cmd_reads!=96 || rsp_reads!=48 || !lpv_owner_installed || !lpv_owner_revoked)
      $fatal(1,"CLAIM-only cleanup count/lower-bound mismatch");
    $display("FULL_CURRENT_MANAGED_LPV_CASE_PASS case=1 claim_only=1 actual16_8=6 tail2_tail1=12 wrong_A_route_no_pop=1 precise_cleanup=1 no_typed_or_AXI=1");

    // Partial ordinary request is collected on the old lane, rejected before
    // hub side effects, and cannot reopen after cancel/base input recovery.
    install_case(2);load_packet("claim_partial",packet);send_range(packet,0,2);
    cancel=1;monitored_bo_base=BO_BASE+64;lpv_candidate_route=1;
    send_range(packet,2,16);literal_result("claim_partial");
    cancel=0;monitored_bo_base=BO_BASE;lpv_candidate_route=0;
    if(accepted_events!=0 || active_owners!=0 || !lpv_owner_revoked || last_event_seq!=20)
      $fatal(1,"partial ordinary frame escaped revoke");
    load_packet("preowned_claim",packet);provenance_cmd_din=packet[0+:512];provenance_cmd_write=1;
    repeat(12)begin if(provenance_cmd_full_n)$fatal(1,"ordinary new first beat reopened");tick();end
    provenance_cmd_write=0;
    lpv_pending_valid=1;lpv_pending_owner=lpv_admission_record;lpv_pending_packet=packet;
    send_packet(packet);lpv_pending_valid=0;literal_result("preowned_claim");
    if(accepted_requests!=0 || accepted_events!=0 || terminal_tasks!=0 || cmd_reads!=32 || rsp_reads!=16 ||
       forwarded_aw!=0 || forwarded_w!=0 || last_event_seq!=21 || protocol_error)
      $fatal(1,"preowned drain invented a hub event/reservation");
    $display("FULL_CURRENT_MANAGED_LPV_CASE_PASS case=2 partial2_then_persistent_base_cancel=1 old_lane_retained=1 controlled_full_preowned_frame_rejected=1 new_business0=1");

    // Real monitor B debt and adapter fence remain independent of cancel/A.
    install_case(3);literal_transact("active_claim");literal_transact("begin");
    drive_write(BO_BASE,1,2'b00,1);adapter_pending_zero=0;cancel=1;
    snapshot_base_epoch=8;lpv_candidate_route=0;
    literal_transact("bad_end");
    if(terminal_tasks!=0 || !scope_active || !monitor_scope_active || !s_axi_bvalid)
      $fatal(1,"wrong END lost old scope/debt");
    load_packet("end",packet);send_range(packet,0,2);lpv_candidate_route=1;send_range(packet,2,16);
    while(!dut.hub.pending_end)begin
      if(provenance_rsp_empty_n || terminal_tasks!=0)$fatal(1,"END retired before actual hub acceptance/B debt");tick();
    end
    repeat(12)begin
      if(provenance_rsp_empty_n || terminal_tasks!=0 || !dut.hub.pending_end)$fatal(1,"END passed real held B debt");tick();
    end
    accept_held_b();repeat(12)begin
      if(provenance_rsp_empty_n || terminal_tasks!=0 || monitor_drained)$fatal(1,"END passed old adapter fence");tick();
    end
    adapter_pending_zero=1;literal_result("end");
    if(scope_active || monitor_scope_active || terminal_tasks!=1 || active_owners!=1 || !cancel)
      $fatal(1,"persistent revoke blocked or duplicated real END");
    lpv_candidate_route=0;literal_transact("active_invalidate");literal_transact("repeated_invalidate");
    if(terminal_tasks!=1 || active_owners!=0 || !domain_drained || forwarded_aw!=1 || forwarded_w!=1 ||
       retired_b!=1 || cmd_reads!=96 || rsp_reads!=48 || last_event_seq!=35 || protocol_error)
      $fatal(1,"real END/INVALIDATE counts/lower bounds changed");
    $display("FULL_CURRENT_MANAGED_LPV_CASE_PASS case=3 actual_old_END=1 held_B=12 adapter_fence=12 persistent_cancel=1 typed_once=1 actual_AW_W_B=1 replay_cleanup_rejected=1");

    // Damaged model is isolated after full old framing; no fabricated owner.
    install_case(4);literal_transact("claim");cancel=1;literal_transact("wrong_model");
    if(!protocol_error || active_owners!=1 || terminal_tasks!=0 || last_event_seq!=6)
      $fatal(1,"damaged model did not preserve isolation/owner");
    $display("FULL_CURRENT_MANAGED_LPV_CASE_PASS case=4 bad_complete_model_isolated=1 old_owner_kept=1 no_recovery_claim=1");
    $display("FULL_CURRENT_MANAGED_LPV_PASS cases=4 actual_cpp_A=1 whole_A_install_controlled=1 executed_SV_codec=1 A_wire_rejects=11 depth2_16_8=1 unique_hub=1 route_tagged=1 persistent_revoke=1 exact_claim_only_cleanup=1 real_END_B_fence=1 no_reset_within_case=1 rearm_NOT_RUN=1 all13BO_NOT_RUN=1 cycles=%0d",cycles);
    $finish;
  end
endmodule
