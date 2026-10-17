`timescale 1ns/1ps
// The source peer supplies frozen offline actual C++ executor LAD1 bytes. The
// existing managed AXI portal performs full validation and owner installation;
// this TB neither clones that validator nor represents generated executor RTL.
module laya_executor_admission_transport_tb_v1;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;
  localparam logic [63:0] BO_CAPACITY=64'd16920576;
  logic [63:0] monitored_bo_base=BO_BASE,snapshot_base_address=BO_BASE;
  logic [63:0] snapshot_base_epoch=7,snapshot_base_capacity=BO_CAPACITY;
  logic adapter_pending_zero=1;
  logic [511:0] admission_owner_din=0,admission_owner_receipt_dout;
  logic admission_owner_write=0,admission_owner_full_n;
  logic admission_owner_receipt_empty_n,admission_owner_receipt_read=0;
  logic lpv_admission_valid,lpv_admission_ready,lpv_admission_accepted;
  logic [8191:0] lpv_admission_record,lpv_owner_record;
  logic lpv_owner_installed,lpv_owner_revoked;
  logic first_started,record_complete,isolated,receipt_done,cancel_seen,protocol_error;
  logic [31:0] admission_writes,admission_reads,portal_handshakes,portal_accepts;
  logic [31:0] receipt_writes,receipt_reads;
  logic [1:0] admission_occupancy,receipt_occupancy;
  logic [2:0] phase;
  logic [4:0] ingress_beats,collect_beats,echo_beats,echo_read_beats;
  logic transport_busy,scope_active,monitor_scope_active,source_lease_active;
  logic portal_protocol_error,m_axi_awvalid,m_axi_wvalid,m_axi_bready,s_axi_bvalid;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses,accepted_events;
  logic [31:0] semantic_rejections,terminal_tasks,forwarded_aw,forwarded_w,retired_b;
  logic [31:0] rejected_transactions;

  laya_executor_admission_transport_v1 bridge(
    .clk,.rst_n,.cancel,.admission_owner_din,.admission_owner_write,.admission_owner_full_n,
    .admission_owner_receipt_dout,.admission_owner_receipt_empty_n,.admission_owner_receipt_read,
    .lpv_admission_valid,.lpv_admission_ready,.lpv_admission_accepted,.lpv_admission_record,
    .first_started,.record_complete,.isolated,.receipt_done,.cancel_seen,.protocol_error,
    .admission_writes,.admission_reads,.portal_handshakes,.portal_accepts,
    .receipt_writes,.receipt_reads,.admission_occupancy,.receipt_occupancy,.phase,
    .ingress_beats,.collect_beats,.echo_beats,.echo_read_beats);

  // All portal inputs are explicit. STATE0 configuration and adapter idle are
  // controlled physical facts in this finite installation test, with no work.
  laya_generated_provenance_axi_portal_v1 #(.MONITORED_ROLE(6),.MANAGED_LPV_OWNER(1)) portal(
    .clk,.rst_n,.cancel,.lpv_admission_valid,.lpv_admission_ready,.lpv_admission_accepted,
    .lpv_admission_record,.lpv_owner_installed,.lpv_owner_revoked,.lpv_owner_record,
    .lpv_revoke_valid(1'b0),.lpv_revoke_owner(8192'd0),
    .lpv_candidate_valid(1'b0),.lpv_candidate_route(1'b0),.lpv_candidate_owner(8192'd0),
    .lpv_pending_valid(1'b0),.lpv_pending_route(1'b0),.lpv_pending_owner(8192'd0),
    .lpv_pending_packet(8192'd0),.lpv_response_route(1'b0),.lpv_response_owner(8192'd0),
    .provenance_cmd_din(512'd0),.provenance_cmd_write(1'b0),.provenance_rsp_read(1'b0),
    .checkpoint_command_din(512'd0),.checkpoint_command_write(1'b0),
    .checkpoint_response_read(1'b0),.checkpoint_start_permit(1'b0),
    .checkpoint_owner_revoked(1'b0),.checkpoint_executor_route(1'b0),
    .checkpoint_owner_key(8192'd0),.checkpoint_closed_valid(1'b0),.checkpoint_closed_key(8192'd0),
    .executor_provenance_cmd_din(512'd0),.executor_provenance_cmd_write(1'b0),
    .monitored_bo_base,.adapter_pending_zero,
    .source_query_valid(1'b0),.source_query_command(8192'd0),
    .source_release_valid(1'b0),.source_release_command(8192'd0),.source_release_drained(1'b1),
    .snapshot_request_valid(1'b0),.snapshot_request(6144'd0),.snapshot_response_ready(1'b0),
    .snapshot_base_valid(1'b1),.snapshot_base_epoch,.snapshot_base_address,.snapshot_base_capacity,
    .bootstrap_source_guard_active(1'b0),.bootstrap_source_guard_key(6144'd0),
    .s_axi_awaddr(64'd0),.s_axi_awlen(8'd0),.s_axi_awsize(3'd6),.s_axi_awburst(2'd1),
    .s_axi_awvalid(1'b0),.s_axi_wdata(512'd0),.s_axi_wstrb(64'd0),
    .s_axi_wlast(1'b1),.s_axi_wvalid(1'b0),.s_axi_bready(1'b0),
    .m_axi_awready(1'b1),.m_axi_wready(1'b1),.m_axi_bresp(2'd0),.m_axi_bvalid(1'b0),
    .transport_busy,.scope_active,.monitor_scope_active,.source_lease_active,
    .protocol_error(portal_protocol_error),.active_owners,.published_owners,
    .accepted_requests,.retired_responses,.accepted_events,.semantic_rejections,.terminal_tasks,
    .forwarded_aw,.forwarded_w,.retired_b,.rejected_transactions,
    .m_axi_awvalid,.m_axi_wvalid,.m_axi_bready,.s_axi_bvalid);

  string fixture;
  logic [511:0] fixture_beats[0:15];
  logic [8191:0] actual_a,literal_a,source_packet,received;
  logic [8191:0] held_record;
  logic [511:0] held_echo;
  logic record_was_complete=0,echo_was_held=0;
  integer cycles=0,diagnostic=0;
  integer observed_writes=0,observed_pops=0,observed_portal=0,observed_accepts=0;
  integer observed_echo_writes=0,observed_echo_reads=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>5000)$fatal(1,"admission cycle cap diagnostic=%0d phase=%0d",diagnostic,phase);
    if(!rst_n)begin
      observed_writes<=0;observed_pops<=0;observed_portal<=0;observed_accepts<=0;
      observed_echo_writes<=0;observed_echo_reads<=0;
      record_was_complete<=0;echo_was_held<=0;
    end else begin
      if(admission_writes!==observed_writes || admission_reads!==observed_pops ||
         portal_handshakes!==observed_portal || portal_accepts!==observed_accepts ||
         receipt_writes!==observed_echo_writes || receipt_reads!==observed_echo_reads)
        $fatal(1,"actual handshake counter mismatch diagnostic=%0d",diagnostic);
      if(admission_owner_write && admission_owner_full_n)observed_writes<=observed_writes+1;
      if(bridge.ingress_valid && bridge.ingress_pop)observed_pops<=observed_pops+1;
      if(lpv_admission_valid && lpv_admission_ready)observed_portal<=observed_portal+1;
      if(lpv_admission_valid && lpv_admission_ready && lpv_admission_accepted)
        observed_accepts<=observed_accepts+1;
      if(bridge.echo_push && bridge.echo_ready)observed_echo_writes<=observed_echo_writes+1;
      if(admission_owner_receipt_empty_n && admission_owner_receipt_read)
        observed_echo_reads<=observed_echo_reads+1;
      if(admission_occupancy>2 || receipt_occupancy>2 || admission_writes>16 ||
         admission_reads>16 || receipt_writes>16 || receipt_reads>16 || portal_handshakes>1)
        $fatal(1,"FIRST bounded transport exceeded quota");
      if(lpv_admission_valid && (admission_writes!=16 || admission_reads!=16 ||
                                 admission_occupancy!=0 || !record_complete))
        $fatal(1,"portal presented before complete actual FIFO drain");
      if(lpv_admission_accepted && !(lpv_admission_valid && lpv_admission_ready))
        $fatal(1,"portal accepted without actual complete handshake");
      if(record_complete && lpv_admission_record!==source_packet)
        $fatal(1,"collector changed original full A diagnostic=%0d",diagnostic);
      if(record_was_complete && lpv_admission_record!==held_record)
        $fatal(1,"retained complete A changed");
      if(echo_was_held && (!admission_owner_receipt_empty_n ||
                           admission_owner_receipt_dout!==held_echo))
        $fatal(1,"old echo changed under actual FIFO backpressure");
      if((receipt_writes!=0 || receipt_reads!=0 || admission_owner_receipt_empty_n) && portal_accepts!=1)
        $fatal(1,"echo preceded actual portal acceptance");
      if(lpv_owner_installed && (portal_accepts!=1 || lpv_owner_record!==literal_a))
        $fatal(1,"real portal installed wrong A");
      if(protocol_error || portal_protocol_error || transport_busy || scope_active ||
         monitor_scope_active || source_lease_active || active_owners!=0 || published_owners!=0 ||
         accepted_requests!=0 || retired_responses!=0 || accepted_events!=0 ||
         semantic_rejections!=0 || terminal_tasks!=0 || forwarded_aw!=0 || forwarded_w!=0 ||
         retired_b!=0 || rejected_transactions!=0 || m_axi_awvalid || m_axi_wvalid ||
         m_axi_bready || s_axi_bvalid)
        $fatal(1,"admission-only fixture created business/AXI work or protocol error");
      record_was_complete<=record_complete;held_record<=lpv_admission_record;
      echo_was_held<=admission_owner_receipt_empty_n && !admission_owner_receipt_read;
      held_echo<=admission_owner_receipt_dout;
    end
  end

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic load_packet(input string name,output logic [8191:0] packet);
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int beat=0;beat<16;beat++)packet[beat*512+:512]=fixture_beats[beat];
  endtask
  task automatic save_packet(input string name,input logic [8191:0] packet);
    integer fd;
    fd=$fopen({fixture,"/",name,".hex"},"w");
    if(fd==0)$fatal(1,"capture open failed %s",name);
    for(int beat=0;beat<16;beat++)$fdisplay(fd,"%0128x",packet[beat*512+:512]);
    $fclose(fd);
  endtask
  task automatic reset_case(input integer number,input logic [8191:0] packet);
    rst_n=0;cancel=0;admission_owner_write=0;admission_owner_receipt_read=0;
    monitored_bo_base=BO_BASE;snapshot_base_address=BO_BASE;
    snapshot_base_epoch=7;snapshot_base_capacity=BO_CAPACITY;adapter_pending_zero=1;
    diagnostic=number;source_packet=packet;
    repeat(3)tick();rst_n=1;repeat(3)tick();
  endtask
  task automatic send_beat(input integer beat,input logic [8191:0] packet);
    admission_owner_din=packet[beat*512+:512];admission_owner_write=1;
    do begin @(posedge clk);end while(!admission_owner_full_n);
    #1;@(negedge clk);admission_owner_write=0;
  endtask
  task automatic send_packet(input logic [8191:0] packet);
    for(int beat=0;beat<16;beat++)begin
      send_beat(beat,packet);
      if(beat==13 || beat==14)repeat(12)begin
        if(record_complete || lpv_admission_valid || lpv_owner_installed || receipt_writes!=0)
          $fatal(1,"partial A created full-record authority");
        tick();
      end
    end
    while(!record_complete)tick();
  endtask
  task automatic block_second_frame;
    admission_owner_din=~actual_a[0+:512];admission_owner_write=1;
    repeat(12)begin
      if(admission_owner_full_n || admission_writes!=16 || admission_reads!=16)
        $fatal(1,"second A reopened FIRST ingress");
      tick();
    end
    admission_owner_write=0;
  endtask
  task automatic reject_case(input integer number,input logic [8191:0] packet,input string name);
    reset_case(number,packet);send_packet(packet);
    while(!isolated)tick();
    if(portal_handshakes!=1 || portal_accepts!=0 || !lpv_admission_ready ||
       lpv_owner_installed || receipt_writes!=0 || receipt_reads!=0 ||
       admission_owner_receipt_empty_n || cancel_seen)
      $fatal(1,"ready-only real portal rejection created authority diagnostic=%0d",number);
    save_packet(name,lpv_admission_record);block_second_frame();
    repeat(12)begin
      if(lpv_admission_valid || lpv_owner_installed || receipt_writes!=0 ||
         lpv_admission_record!==packet)$fatal(1,"rejected A retried or lost");
      tick();
    end
  endtask
  task automatic check_cancel_isolation(input string name);
    while(!isolated)tick();
    if(!record_complete || !cancel_seen || portal_handshakes!=0 || portal_accepts!=0 ||
       lpv_owner_installed || receipt_writes!=0 || receipt_reads!=0 || admission_occupancy!=0)
      $fatal(1,"preaccept cancel lost old frame or installed/echoed it");
    save_packet(name,lpv_admission_record);block_second_frame();
    cancel=0;adapter_pending_zero=1;monitored_bo_base=BO_BASE;
    snapshot_base_address=BO_BASE;snapshot_base_epoch=7;snapshot_base_capacity=BO_CAPACITY;
    repeat(12)begin
      if(!isolated || lpv_admission_valid || lpv_owner_installed || receipt_writes!=0 ||
         lpv_admission_record!==actual_a)$fatal(1,"cancel deassertion retried isolated A");
      tick();
    end
  endtask

  initial begin : finite_cases
    logic [8191:0] mutant;
    logic [511:0] held;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    load_packet("actual_admission_owner",actual_a);
    load_packet("admission_owner",literal_a);
    if(actual_a!==literal_a)$fatal(1,"offline actual C++ A differs from independent literal");

    reset_case(1,actual_a);adapter_pending_zero=0;
    cancel=1;admission_owner_write=1;admission_owner_din=actual_a[0+:512];
    // Settle the combinational ingress gate before checking this new drive.
    #1;
    repeat(12)begin
      if(admission_owner_full_n || first_started || admission_writes!=0 || cancel_seen)
        $fatal(1,"cancel before source first write created an A");
      tick();
    end
    admission_owner_write=0;cancel=0;send_packet(actual_a);
    repeat(12)begin
      if(!lpv_admission_valid || lpv_admission_ready || lpv_admission_accepted ||
         portal_handshakes!=0 || lpv_owner_installed || receipt_writes!=0 ||
         lpv_admission_record!==literal_a)$fatal(1,"blocked real portal changed A or echoed early");
      tick();
    end
    adapter_pending_zero=1;
    while(portal_accepts==0)tick();
    if(portal_handshakes!=1 || !lpv_owner_installed || lpv_owner_record!==literal_a)
      $fatal(1,"full real portal did not install exact A once");
    save_packet("actual_installed_admission",lpv_owner_record);
    while(receipt_occupancy!=2)tick();
    held=admission_owner_receipt_dout;
    repeat(12)begin
      if(receipt_writes!=2 || receipt_reads!=0 || receipt_occupancy!=2 ||
         admission_owner_receipt_dout!==held)$fatal(1,"actual depth2 echo did not backpressure");
      tick();
    end
    // The installed old owner is revoked, while its original accepted receipt
    // remains a required finite cleanup. No reset occurs through this drain.
    cancel=1;snapshot_base_epoch=9;monitored_bo_base=BO_BASE+64;
    snapshot_base_address=BO_BASE+64;snapshot_base_capacity=BO_CAPACITY+64;
    repeat(12)tick();
    if(!lpv_owner_revoked || !cancel_seen || lpv_owner_record!==literal_a)
      $fatal(1,"real portal failed persistent old-owner revocation");
    received=0;
    for(int beat=0;beat<16;beat++)begin
      while(!admission_owner_receipt_empty_n)tick();
      held=admission_owner_receipt_dout;
      if(beat==14 || beat==15)repeat(12)begin
        if(receipt_reads!=beat || receipt_done ||
           admission_owner_receipt_dout!==held || !admission_owner_receipt_empty_n)
          $fatal(1,"old receipt tail changed or completed before real read");
        tick();
      end
      if(held!==literal_a[beat*512+:512])$fatal(1,"original echo byte mismatch beat=%0d",beat);
      received[beat*512+:512]=held;admission_owner_receipt_read=1;tick();
      admission_owner_receipt_read=0;
    end
    while(!receipt_done)tick();
    if(received!==literal_a || receipt_writes!=16 || receipt_reads!=16 || receipt_occupancy!=0 ||
       portal_accepts!=1 || portal_handshakes!=1 || !cancel_seen || !lpv_owner_revoked)
      $fatal(1,"accepted canceled original echo did not drain exactly once");
    save_packet("actual_admission_receipt",received);block_second_frame();
    cancel=0;repeat(12)begin
      if(!receipt_done || portal_accepts!=1 || !lpv_owner_revoked ||
         lpv_owner_record!==literal_a || receipt_writes!=16 || receipt_reads!=16)
        $fatal(1,"drained FIRST owner acquired replacement authority");
      tick();
    end

    mutant=actual_a;mutant[888*8+:8]=1;
    reject_case(2,mutant,"actual_rejected_reserved");
    mutant=actual_a;mutant[12*8+:32]=32;
    mutant[696*8+:192]=actual_a[720*8+:192];mutant[720*8+:192]=0;
    reject_case(3,mutant,"actual_rejected_unknown_state0");
    mutant=actual_a;mutant[720*8+:64]=8;
    reject_case(4,mutant,"actual_rejected_epoch");
    mutant=actual_a;mutant[728*8+:64]=BO_BASE+64;
    reject_case(5,mutant,"actual_rejected_address");
    mutant=actual_a;mutant[736*8+:64]=BO_CAPACITY+64;
    reject_case(6,mutant,"actual_rejected_capacity");

    reset_case(7,actual_a);adapter_pending_zero=0;
    for(int beat=0;beat<14;beat++)send_beat(beat,actual_a);
    repeat(12)tick();cancel=1;snapshot_base_epoch=9;
    monitored_bo_base=BO_BASE+64;snapshot_base_address=BO_BASE+64;
    repeat(12)begin
      if(admission_writes!=14 || record_complete || lpv_owner_installed || receipt_writes!=0)
        $fatal(1,"cancel cleared or completed partial A");
      tick();
    end
    send_beat(14,actual_a);repeat(12)begin
      if(admission_writes!=15 || record_complete || receipt_writes!=0)
        $fatal(1,"cancel blocked/lost old A tail2");
      tick();
    end
    send_beat(15,actual_a);check_cancel_isolation("actual_canceled_partial");

    reset_case(8,actual_a);adapter_pending_zero=0;send_packet(actual_a);
    repeat(12)tick();
    if(!lpv_admission_valid || lpv_admission_ready || portal_handshakes!=0)
      $fatal(1,"preaccept wait case did not reach actual blocked portal");
    cancel=1;adapter_pending_zero=1;check_cancel_isolation("actual_canceled_waiting");
    $display("FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_RTL_PASS diagnostics=8 actual_portal_validator_install=1 actual_depth2_ingress_echo=1 real_ingress_writes_pops=16 real_receipt_writes_reads=16 first_only=1 persistent_cancel_old_frame_drain=1 offline_actual_cpp_A=1 TB_source_peer=1 generated_executor_same_runtime_NOT_RUN=1 physical_request_closure_NOT_RUN=1 hardware_rearm_NOT_RUN=1");
    $finish;
  end
endmodule
