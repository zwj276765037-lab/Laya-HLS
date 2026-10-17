`timescale 1ns/1ps
module laya_generated_source_lease_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic [511:0] provenance_cmd_din,provenance_rsp_dout;
  logic provenance_cmd_write=0,provenance_cmd_full_n;
  logic provenance_rsp_empty_n,provenance_rsp_read=0;
  logic physical_observation_valid=0,physical_observation_ready;
  logic [15:0] physical_status=0;
  logic [31:0] physical_error_detail=0;
  logic [63:0] physical_bad_element='1;
  logic [63:0] physical_observed_store_bytes0=0;
  logic [63:0] physical_observed_store_bytes1=0;
  logic physical_drained=1,physical_coverage_complete=1;
  logic source_query_valid=0,source_query_ready,source_query_granted;
  logic [8191:0] source_query_command=0;
  logic source_release_valid=0,source_release_ready;
  logic [8191:0] source_release_command=0;
  logic source_release_drained=0,source_lease_active;
  logic transport_busy,cancel_pending,protocol_error,scope_active,domain_drained;
  logic [63:0] last_event_seq;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses;
  logic [31:0] accepted_events,semantic_rejections,terminal_tasks;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;

  laya_generated_provenance_portal_v1 dut(.*);

  string fixture;
  logic [511:0] fixture_beats[0:15];
  logic [8191:0] packet,query_packet,active_query;
  logic [4095:0] received;
  int cycles=0,phase=0,query_grants=0,query_rejects=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>20000)$fatal(1,"source lease cycle cap phase=%0d",phase);
  end

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask

  task automatic load_packet(input string name,output logic [8191:0] value);
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int beat=0;beat<16;beat++)value[beat*512+:512]=fixture_beats[beat];
  endtask

  task automatic send_packet(input logic [8191:0] value,
      input logic use_physical,input logic [63:0] observed0,
      input logic coverage);
    if(use_physical)begin
      physical_status=0;physical_error_detail=0;
      physical_bad_element=64'hffffffffffffffff;
      physical_observed_store_bytes0=observed0;
      physical_observed_store_bytes1=0;
      physical_drained=1;physical_coverage_complete=coverage;
      physical_observation_valid=1;
    end
    for(int beat=0;beat<16;beat++)begin
      provenance_cmd_din=value[beat*512+:512];provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
    if(use_physical)begin
      while(!physical_observation_ready)tick();
      tick();physical_observation_valid=0;
    end
  endtask

  task automatic receive_packet(output logic [4095:0] value);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      repeat(2)begin
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"source lease response changed under backpressure phase=%0d",phase);
        tick();
      end
      value[beat*512+:512]=held;
      provenance_rsp_read=1;tick();provenance_rsp_read=0;
    end
    repeat(2)tick();
  endtask

  task automatic transact(input string name,input logic use_physical,
      input logic [63:0] observed0,input logic coverage,
      input logic [15:0] expected_status,input logic [7:0] expected_flags);
    load_packet(name,packet);
    send_packet(packet,use_physical,observed0,coverage);
    receive_packet(received);
    if(received[laya_generated_provenance_layout_v1::MAGIC*8+:32]!=RESPONSE_MAGIC ||
       received[laya_generated_provenance_layout_v1::ACTION*8+:16]!=
         packet[laya_generated_provenance_layout_v1::ACTION*8+:16] ||
       received[RESPONSE_STATUS*8+:16]!=expected_status ||
       received[RESPONSE_FLAGS*8+:8]!=expected_flags)
      $fatal(1,"source lease response mismatch name=%s status=%0d flags=%0h",
             name,received[RESPONSE_STATUS*8+:16],
             received[RESPONSE_FLAGS*8+:8]);
  endtask

  task automatic query_value(input logic [8191:0] value,input logic expected);
    @(negedge clk);source_query_command=value;source_query_valid=1;#1;
    if(!source_query_ready)$fatal(1,"source query unexpectedly not ready phase=%0d",phase);
    if(source_query_granted!==expected)
      $fatal(1,"source query decision phase=%0d got=%0d expected=%0d",
             phase,source_query_granted,expected);
    tick();@(negedge clk);source_query_valid=0;
    if(expected)begin
      active_query=value;query_grants=query_grants+1;
      if(!source_lease_active)$fatal(1,"granted source query did not establish lease");
    end else begin
      query_rejects=query_rejects+1;
      if(source_lease_active)$fatal(1,"rejected source query established lease");
    end
  endtask

  task automatic query_named(input string name,input logic expected);
    load_packet(name,query_packet);query_value(query_packet,expected);
  endtask

  task automatic release_active_query;
    @(negedge clk);source_release_command=active_query;
    source_release_drained=0;source_release_valid=1;#1;
    if(source_release_ready)$fatal(1,"undrained source lease released");
    repeat(3)begin tick();if(!source_lease_active)$fatal(1,"undrained lease lost");end
    @(negedge clk);source_release_drained=1;#1;
    if(!source_release_ready)$fatal(1,"drained matching source lease not releasable");
    tick();@(negedge clk);source_release_valid=0;source_release_drained=0;
    if(source_lease_active)$fatal(1,"source lease remained after release handshake");
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    provenance_cmd_din=0;
    repeat(5)tick();rst_n=1;tick();
    if(!domain_drained)$fatal(1,"initial source ledger not drained");

    for(int sparse=0;sparse<4;sparse++)begin
      phase=1+sparse*5;
      transact($sformatf("sparse_claim_%0d",sparse),0,0,1,0,8'h01);
      transact($sformatf("sparse_begin_%0d",sparse),0,0,1,0,8'h03);
      transact($sformatf("sparse_end_%0d",sparse),1,4096,1,E_PROTOCOL,8'h01);
      transact($sformatf("sparse_publish_%0d",sparse),1,0,1,E_BUFFER,8'h01);
      transact($sformatf("sparse_invalidate_%0d",sparse),1,0,1,0,8'h01);
      if(active_owners!=0 || published_owners!=0 || scope_active)
        $fatal(1,"sparse producer cleanup failed window=%0d",sparse);
    end

    phase=21;transact("source_claim",0,0,1,0,8'h01);
    for(int window=0;window<3;window++)begin
      phase=22+window*2;
      transact($sformatf("source_begin_%0d",window),0,0,1,0,8'h03);
      transact($sformatf("source_end_%0d",window),1,65536,1,0,8'h01);
    end
    if(terminal_tasks!=7 || published_owners!=0)
      $fatal(1,"three-window source coverage state");
    phase=28;transact("source_publish_early",1,0,1,E_BUFFER,8'h01);
    if(published_owners!=0)$fatal(1,"partial source tensor published");
    phase=29;query_named("query_0",0);

    phase=30;transact("source_begin_3",0,0,1,0,8'h03);
    phase=31;transact("source_end_3",1,65536,1,0,8'h01);
    phase=32;transact("source_publish",1,0,1,0,8'h05);
    if(published_owners!=1 || terminal_tasks!=4)
      $fatal(1,"complete source tensor did not publish");

    load_packet("query_0",query_packet);
    phase=33;query_packet[laya_compute_portal_layout_v1::PRODUCER_CONTEXT*8+:32]=2002;
    query_value(query_packet,0);
    load_packet("query_0",query_packet);
    phase=34;query_packet[laya_compute_portal_layout_v1::SOURCE_REF*8+:32]=101;
    query_value(query_packet,0);
    load_packet("query_0",query_packet);
    phase=35;query_packet[laya_compute_portal_layout_v1::IDENTITY*8+:64]=2001;
    query_value(query_packet,0);
    load_packet("query_0",query_packet);
    phase=36;query_packet[laya_compute_portal_layout_v1::MODEL_IDENTITY*8+:8]^=8'h01;
    query_value(query_packet,0);
    load_packet("query_0",query_packet);
    phase=37;query_packet[laya_compute_portal_layout_v1::SOURCE_SPAN*8+:64]=65536;
    query_value(query_packet,0);

    phase=38;query_named("query_0",1);
    if(source_query_ready)$fatal(1,"second query ready while source lease active");
    phase=39;transact("source_owner_release_busy",1,0,1,E_BUFFER,8'h01);
    if(!source_lease_active || published_owners!=1)
      $fatal(1,"owner release disturbed active source lease");
    release_active_query();

    for(int window=1;window<4;window++)begin
      phase=40+window;query_named($sformatf("query_%0d",window),1);
      release_active_query();
    end
    phase=44;query_named("query_3",0);
    phase=45;query_named("query_window0_new",1);release_active_query();
    phase=46;transact("source_owner_release",1,0,1,0,8'h01);

    if(active_owners!=0 || published_owners!=0 || source_lease_active ||
       !domain_drained || protocol_error || accepted_requests!=33 ||
       retired_responses!=33 || accepted_events!=33 ||
       semantic_rejections!=6 || terminal_tasks!=8 ||
       query_grants!=5 || query_rejects!=7)
      $fatal(1,"source lease final state owners=%0d published=%0d lease=%0d domain=%0d req=%0d retired=%0d events=%0d rejects=%0d terminal=%0d qgrant=%0d qreject=%0d",
        active_owners,published_owners,source_lease_active,domain_drained,
        accepted_requests,retired_responses,accepted_events,
        semantic_rejections,terminal_tasks,query_grants,query_rejects);
    $display("FULL_CURRENT_GENERATED_SOURCE_LEASE_PASS sparse_rows1_rejected=4 sparse_publish_rejected=4 windows=4 distinct_P=4 partial_publish_rejected=1 identity_model_ref_range_rejected=1 lease_atomic=1 read_debt_hold=1 owner_release_blocked=1 duplicate_generation_rejected=1 greater_generation_reread=1 query_grants=%0d query_rejects=%0d cycles=%0d",
      query_grants,query_rejects,cycles);
    $finish;
  end
endmodule
