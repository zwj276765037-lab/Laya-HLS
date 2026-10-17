`timescale 1ns/1ps
module laya_gate_quant_source_lease_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk=0,rst_n=0;always #3.333 clk=~clk;
  logic g_service_cancel,q_service_cancel;
  logic source_query_valid,source_query_ready,source_query_granted;
  logic [8191:0] source_query_command;
  logic source_release_valid,source_release_ready,source_release_drained;
  logic [8191:0] source_release_command;
  logic q_source_lease_active;
  logic g_service_command_valid,g_service_command_ready;
  logic q_service_command_valid,q_service_command_ready;
  logic [8191:0] service_command;
  logic g_service_completion_valid,g_service_completion_ready;
  logic [4095:0] g_service_completion;
  logic q_service_completion_valid,q_service_completion_ready;
  logic [4095:0] q_service_completion;
  logic [12:0][63:0] latched_bo_base,latched_bo_span;
  logic wi_axi_physical_debt_zero,gate_write_physical_debt_zero;
  logic gate_read_physical_debt_zero,g_physical_debt_zero,q_physical_debt_zero;
  logic g_persistent_active,q_persistent_active;
  logic [63:0] wi_axi_araddr;logic [7:0] wi_axi_arlen;
  logic [2:0] wi_axi_arsize;logic [1:0] wi_axi_arburst;
  logic wi_axi_arvalid,wi_axi_arready;
  logic [511:0] wi_axi_rdata;logic [1:0] wi_axi_rresp;
  logic wi_axi_rlast,wi_axi_rvalid,wi_axi_rready;
  logic [63:0] gate_axi_awaddr;logic [7:0] gate_axi_awlen;
  logic [2:0] gate_axi_awsize;logic [1:0] gate_axi_awburst;
  logic gate_axi_awvalid,gate_axi_awready;
  logic [511:0] gate_axi_wdata;logic [63:0] gate_axi_wstrb;
  logic gate_axi_wlast,gate_axi_wvalid,gate_axi_wready;
  logic [1:0] gate_axi_bresp;logic gate_axi_bvalid,gate_axi_bready;
  logic [63:0] gate_axi_araddr;logic [7:0] gate_axi_arlen;
  logic [2:0] gate_axi_arsize;logic [1:0] gate_axi_arburst;
  logic gate_axi_arvalid,gate_axi_arready;
  logic [511:0] gate_axi_rdata;logic [1:0] gate_axi_rresp;
  logic gate_axi_rlast,gate_axi_rvalid,gate_axi_rready;
  logic a_acquire_valid,a_acquire_ready,a_acquire_done,a_acquire_error;
  logic a_acquire_slot;logic [31:0] a_acquire_slot_epoch;logic [12:0] a_acquire_K;
  logic [4:0] a_acquire_rows;logic [671:0] a_acquire_numeric_identity;
  logic [95:0] a_acquire_linear_context;
  logic [63:0] a_acquire_a_ref,a_acquire_w_ref,a_acquire_dst_ref;
  logic a_read_valid,a_read_ready,a_read_error,a_read_slot;
  logic [31:0] a_read_slot_epoch;logic [671:0] a_read_numeric_identity;
  logic [95:0] a_read_linear_context;logic [63:0] a_read_a_ref;
  logic [3:0] a_read_row_block_base;logic [2:0] a_read_rows;logic [6:0] a_read_group;
  logic a_ret_valid,a_ret_ready,a_ret_slot;logic [31:0] a_ret_slot_epoch;
  logic [671:0] a_ret_numeric_identity;logic [95:0] a_ret_linear_context;
  logic [63:0] a_ret_a_ref;logic [3:0] a_ret_row_block_base;
  logic [2:0] a_ret_rows;logic [6:0] a_ret_group;
  logic [3:0][255:0] a_ret_q;logic [3:0][15:0] a_ret_scale;
  logic a_release_valid,a_release_ready,a_release_done,a_release_error,a_release_slot;
  logic [31:0] a_release_slot_epoch;logic [671:0] a_release_numeric_identity;
  logic [95:0] a_release_linear_context;logic [63:0] a_release_a_ref;
  logic a_read_debt_zero;logic [1:0][2:0] a_slot_state;
  logic [1:0][31:0] a_slot_epoch;logic [1:0][15:0] a_slot_rows_done;
  logic [2:0] gate_owner_state;logic [7:0] gate_next_window;
  logic [127:0] gate_valid_windows,gate_covered_windows,gate_consumed_windows;
  logic [2047:0] gate_covered_rows;
  laya_gate_quant_portal_binding_v1 dut(.*);

  string fixture;
  logic [31:0] source_mem[0:4095];logic [7:0] q_gold[0:4095];
  logic [15:0] scale_gold[0:127];
  logic [511:0] provenance_cmd_din,provenance_rsp_dout,fixture_beats[0:15];
  logic provenance_cmd_write=0,provenance_cmd_full_n;
  logic provenance_rsp_empty_n,provenance_rsp_read=0;
  logic ledger_cancel=0,physical_observation_valid=0,physical_observation_ready;
  logic [15:0] physical_status=0;logic [31:0] physical_error_detail=0;
  logic [63:0] physical_bad_element='1;
  logic [63:0] physical_observed_store_bytes0=0,physical_observed_store_bytes1=0;
  logic physical_drained=1,physical_coverage_complete=1,source_lease_active;
  logic ledger_transport_busy,ledger_cancel_pending,ledger_protocol_error;
  logic ledger_scope_active,ledger_domain_drained;logic [63:0] last_event_seq;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses,accepted_events;
  logic [31:0] semantic_rejections,terminal_tasks;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;
  logic [8191:0] ledger_packet;logic [4095:0] ledger_response;
  integer cycles=0,source_ar=0,source_r=0,read_index=0,read_left=0,read_delay=0;
  integer a_groups_checked=0,phase=0;
  logic read_active=0;
  localparam logic [63:0] SOURCE_FIRST=64'h300001000;

  laya_generated_provenance_portal_v1 ledger(
    .clk,.rst_n,.cancel(ledger_cancel),
    .provenance_cmd_din,.provenance_cmd_write,.provenance_cmd_full_n,
    .provenance_rsp_dout,.provenance_rsp_empty_n,.provenance_rsp_read,
    .physical_observation_valid,.physical_observation_ready,
    .physical_status,.physical_error_detail,.physical_bad_element,
    .physical_observed_store_bytes0,.physical_observed_store_bytes1,
    .physical_drained,.physical_coverage_complete,
    .source_query_valid,.source_query_ready,.source_query_command,
    .source_query_granted,.source_release_valid,.source_release_ready,
    .source_release_command,.source_release_drained,.source_lease_active,
    .transport_busy(ledger_transport_busy),
    .cancel_pending(ledger_cancel_pending),.protocol_error(ledger_protocol_error),
    .scope_active(ledger_scope_active),.domain_drained(ledger_domain_drained),
    .last_event_seq,.active_owners,.published_owners,
    .accepted_requests,.retired_responses,.accepted_events,
    .semantic_rejections,.terminal_tasks,
    .command_fifo_occupancy,.response_fifo_occupancy);
  task automatic tick;@(posedge clk);#1;endtask
  task automatic load_packet(input string name,output logic [8191:0] value);
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int beat=0;beat<16;beat++)value[beat*512+:512]=fixture_beats[beat];
  endtask
  task automatic send_ledger_packet(input logic [8191:0] value,
      input logic use_physical,input logic [63:0] observed0);
    if(use_physical)begin
      physical_observed_store_bytes0=observed0;physical_observed_store_bytes1=0;
      physical_status=0;physical_error_detail=0;physical_bad_element='1;
      physical_drained=1;physical_coverage_complete=1;
      physical_observation_valid=1;
    end
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);provenance_cmd_din=value[beat*512+:512];
      provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
    if(use_physical)begin
      while(!physical_observation_ready)tick();
      tick();@(negedge clk);physical_observation_valid=0;
    end
  endtask
  task automatic receive_ledger_packet(output logic [4095:0] value);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      repeat(2)begin
        tick();
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"ledger response changed under backpressure phase=%0d",phase);
      end
      value[beat*512+:512]=held;
      @(negedge clk);provenance_rsp_read=1;tick();
      @(negedge clk);provenance_rsp_read=0;
    end
    repeat(2)tick();
  endtask
  task automatic ledger_transact(input string name,input logic use_physical,
      input logic [63:0] observed0,input logic [15:0] expected_status,
      input logic [7:0] expected_flags);
    load_packet(name,ledger_packet);
    send_ledger_packet(ledger_packet,use_physical,observed0);
    receive_ledger_packet(ledger_response);
    if(ledger_response[laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16]
          !=expected_status ||
       ledger_response[laya_generated_provenance_layout_v1::RESPONSE_FLAGS*8+:8]
          !=expected_flags)
      $fatal(1,"ledger response name=%s status=%0d flags=%0h",name,
        ledger_response[laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16],
        ledger_response[laya_generated_provenance_layout_v1::RESPONSE_FLAGS*8+:8]);
  endtask
  task automatic send_q;
    while(!q_service_command_ready)tick();
    @(negedge clk);q_service_command_valid=1;tick();@(negedge clk);q_service_command_valid=0;
  endtask

  assign wi_axi_physical_debt_zero=1;
  assign gate_write_physical_debt_zero=1;
  assign gate_read_physical_debt_zero=!read_active && !gate_axi_rvalid;
  always @(negedge clk)begin
    gate_axi_arready=rst_n && !read_active && !gate_axi_rvalid && cycles%5!=0;
    if(read_active && !gate_axi_rvalid)begin
      if(read_delay>0)read_delay=read_delay-1;
      else begin
        gate_axi_rvalid=1;gate_axi_rresp=0;gate_axi_rlast=read_left==1;
        for(int lane=0;lane<16;lane++)gate_axi_rdata[lane*32+:32]=source_mem[read_index*16+lane];
      end
    end
  end
  always @(posedge clk)begin
    cycles=cycles+1;if(cycles>500000)$fatal(1,"source-lease Q cycle cap phase=%0d",dut.split.phase);
    if(!rst_n)begin read_active=0;gate_axi_rvalid=0;read_index=0;read_left=0;read_delay=0;end
    else begin
      if(gate_axi_arvalid && gate_axi_arready)begin
        if(read_active || gate_axi_arsize!=6 || gate_axi_arburst!=1 ||
           gate_axi_araddr<SOURCE_FIRST ||
           gate_axi_araddr+64'(gate_axi_arlen+1)*64>SOURCE_FIRST+16*1024 ||
           gate_axi_araddr[11:0]+(int'(gate_axi_arlen)+1)*64>4096)
          $fatal(1,"ordinary Q source AR addr=%h len=%0d",gate_axi_araddr,gate_axi_arlen);
        read_active=1;read_index=int'((gate_axi_araddr-SOURCE_FIRST)>>6);
        read_left=int'(gate_axi_arlen)+1;read_delay=1;source_ar=source_ar+1;
      end
      if(gate_axi_rvalid && gate_axi_rready)begin
        gate_axi_rvalid<=0;read_index=read_index+1;read_left=read_left-1;
        source_r=source_r+1;read_delay=1+(source_r%3);if(read_left==0)read_active=0;
      end
      if(wi_axi_arvalid || gate_axi_awvalid || gate_axi_wvalid)
        $fatal(1,"ordinary Q activated GEGLU/WI/GATE writer");
      if(g_service_completion_valid)$fatal(1,"ordinary Q produced G completion");
    end
  end

  task automatic acquire_a;
    a_acquire_slot=0;a_acquire_slot_epoch=1;a_acquire_K=256;a_acquire_rows=16;
    a_acquire_numeric_identity=service_command[IDENTITY*8+:672];
    a_acquire_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_acquire_a_ref=service_command[A_REF*8+:64];a_acquire_w_ref=service_command[W_REF*8+:64];
    a_acquire_dst_ref=service_command[FUTURE_DST_REF*8+:64];a_acquire_valid=1;
    while(!a_acquire_ready)tick();tick();
    if(!a_acquire_done || a_acquire_error)$fatal(1,"ordinary Q A acquire");
    @(negedge clk);a_acquire_valid=0;
  endtask
  task automatic check_group(input int row_block,input int group);
    logic [3:0][255:0] expected;
    for(int row=0;row<4;row++)
      for(int lane=0;lane<32;lane++)
        expected[row][lane*8+:8]=q_gold[(row_block+row)*256+group*32+lane];
    @(negedge clk);a_read_slot=0;a_read_slot_epoch=1;
    a_read_numeric_identity=service_command[IDENTITY*8+:672];
    a_read_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_read_a_ref=service_command[A_REF*8+:64];a_read_row_block_base=4'(row_block);
    a_read_rows=4;a_read_group=7'(group);a_read_valid=1;
    while(!a_read_ready)tick();tick();if(a_read_error)$fatal(1,"ordinary Q A read admission");
    @(negedge clk);a_read_valid=0;while(!a_ret_valid)tick();
    if(a_ret_group!=group || a_ret_rows!=4 ||
       a_ret_row_block_base!=row_block)
      $fatal(1,"source lease Q A metadata row_block=%0d group=%0d",row_block,group);
    for(int row=0;row<4;row++)
      if(a_ret_q[row]!==expected[row] ||
         a_ret_scale[row]!==scale_gold[(row_block+row)*8+group])
        $fatal(1,"source lease Q A payload row=%0d group=%0d",row_block+row,group);
    @(negedge clk);a_ret_ready=1;tick();@(negedge clk);a_ret_ready=0;a_groups_checked=a_groups_checked+1;
  endtask
  task automatic release_a;
    a_release_slot=0;a_release_slot_epoch=1;
    a_release_numeric_identity=service_command[IDENTITY*8+:672];
    a_release_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_release_a_ref=service_command[A_REF*8+:64];a_release_valid=1;
    while(!a_release_ready)tick();tick();
    if(!a_release_done || a_release_error || !a_read_debt_zero)$fatal(1,"ordinary Q A release");
    @(negedge clk);a_release_valid=0;
  endtask

  initial begin
    g_service_cancel=0;q_service_cancel=0;
    provenance_cmd_din=0;
    g_service_command_valid=0;q_service_command_valid=0;service_command=0;
    g_service_completion_ready=0;q_service_completion_ready=0;
    latched_bo_base=0;latched_bo_span=0;
    latched_bo_base[6]=64'h300000000;latched_bo_span[6]=64'h4000000;
    wi_axi_arready=0;wi_axi_rdata=0;wi_axi_rresp=0;wi_axi_rlast=0;wi_axi_rvalid=0;
    gate_axi_awready=0;gate_axi_wready=0;gate_axi_bresp=0;gate_axi_bvalid=0;
    gate_axi_arready=0;gate_axi_rdata=0;gate_axi_rresp=0;gate_axi_rlast=0;gate_axi_rvalid=0;
    a_acquire_valid=0;a_acquire_slot=0;a_acquire_slot_epoch=0;a_acquire_K=0;a_acquire_rows=0;
    a_acquire_numeric_identity=0;a_acquire_linear_context=0;a_acquire_a_ref=0;a_acquire_w_ref=0;a_acquire_dst_ref=0;
    a_read_valid=0;a_read_slot=0;a_read_slot_epoch=0;a_read_numeric_identity=0;
    a_read_linear_context=0;a_read_a_ref=0;a_read_row_block_base=0;a_read_rows=0;a_read_group=0;a_ret_ready=0;
    a_release_valid=0;a_release_slot=0;a_release_slot_epoch=0;a_release_numeric_identity=0;
    a_release_linear_context=0;a_release_a_ref=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"source lease Q fixture path");
    $readmemh({fixture,"/source.mem"},source_mem);$readmemh({fixture,"/q.mem"},q_gold);
    $readmemh({fixture,"/scale.mem"},scale_gold);
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(20)tick();

    load_packet("query_unpublished",service_command);
    send_q();while(!q_service_completion_valid)tick();
    if(q_service_completion[OP_STATUS*8+:16]!=5 || source_ar!=0 || gate_axi_arvalid)
      $fatal(1,"source lease Q missing-publication admission");
    @(negedge clk);q_service_completion_ready=1;tick();@(negedge clk);q_service_completion_ready=0;

    phase=1;ledger_transact("source_claim",0,0,0,8'h01);
    for(int window=0;window<4;window++)begin
      phase=2+window*2;
      ledger_transact($sformatf("source_begin_%0d",window),0,0,0,8'h03);
      ledger_transact($sformatf("source_end_%0d",window),1,16384,0,8'h01);
    end
    phase=10;ledger_transact("source_publish",1,0,0,8'h05);
    if(published_owners!=1 || terminal_tasks!=4)
      $fatal(1,"source ledger did not publish four-window tensor");

    load_packet("query_window0",service_command);send_q();
    while(!q_service_completion_valid)tick();
    if(!response_binding_ok(q_service_completion,service_command) ||
       q_service_completion[OP_STATUS*8+:16]!=0 ||
       q_service_completion[ELEMENTS*8+:32]!=128 || q_service_completion[UNIT*8+:8]!=2 ||
       q_service_completion[COUNTERS*8+:32]!=16 ||
       q_service_completion[(COUNTERS+4)*8+:32]!=256 ||
       q_service_completion[(COUNTERS+8)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+12)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+16)*8+:32]!=256 ||
       q_service_completion[(COUNTERS+20)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+24)*8+:32]!=256 ||
       q_service_completion[(COUNTERS+28)*8+:32]!=128)
      $fatal(1,"source lease Q response/counters AR=%0d R=%0d state=%0d rows=%h",
        source_ar,source_r,a_slot_state[0],a_slot_rows_done[0]);
    if(gate_owner_state!=0 || dut.split.q_gate_source || a_slot_state[0]!=2 ||
       a_slot_rows_done[0]!=16'hffff || !q_persistent_active ||
       !source_lease_active || !q_source_lease_active)
      $fatal(1,"source lease Q did not use direct shared quant/fullA path");
    repeat(5)begin
      tick();
      if(!q_service_completion_valid || !source_lease_active ||
         !q_source_lease_active || source_release_valid)
        $fatal(1,"source lease Q response/lease not held");
    end
    @(negedge clk);q_service_completion_ready=1;tick();@(negedge clk);q_service_completion_ready=0;
    if(source_lease_active || q_source_lease_active)
      $fatal(1,"source lease Q did not release on response retirement");
    acquire_a();
    for(int row_block=0;row_block<16;row_block+=4)
      for(int group=0;group<8;group++)check_group(row_block,group);
    release_a();
    phase=11;ledger_transact("source_release",1,0,0,8'h01);
    if(active_owners!=0 || !ledger_domain_drained || ledger_protocol_error ||
       accepted_requests!=11 || retired_responses!=11 ||
       accepted_events!=11 || semantic_rejections!=0 || terminal_tasks!=4)
      $fatal(1,"source lease Q ledger final state owners=%0d domain=%0d req=%0d retired=%0d events=%0d rejects=%0d terminal=%0d",
        active_owners,ledger_domain_drained,accepted_requests,retired_responses,
        accepted_events,semantic_rejections,terminal_tasks);
    $display("FULL_CURRENT_GATE_QUANT_SOURCE_LEASE_PASS rejected_unpublished=1 windows_published=4 Q_commands=1 K=256 rows=16 source_AR=%0d source_R=%0d quant_groups=128 half_commits=256 scale_commits=128 lease_held_through_response=1 lease_released_after_read_debt_and_retirement=1 fullA_groups_checked=%0d gate_lease_used=0 unique_quant_instance=1 cycles=%0d",
      source_ar,source_r,a_groups_checked,cycles);
    $finish;
  end
endmodule
