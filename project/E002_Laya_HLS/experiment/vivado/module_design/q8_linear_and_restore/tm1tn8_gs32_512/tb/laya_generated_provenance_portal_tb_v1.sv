`timescale 1ns/1ps
module laya_generated_provenance_portal_tb_v1;
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
  logic source_release_valid=0,source_release_ready,source_release_drained=1;
  logic [8191:0] source_release_command=0;
  logic source_lease_active;
  logic transport_busy,cancel_pending,protocol_error,scope_active,domain_drained;
  logic [63:0] last_event_seq;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses;
  logic [31:0] accepted_events,semantic_rejections,terminal_tasks;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;

  laya_generated_provenance_portal_v1 dut(.*);

  string fixture;
  logic [511:0] fixture_beats[0:15];
  logic [8191:0] packet;
  logic [4095:0] received;
  int cycles=0,phase=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>30000)$fatal(1,"provenance portal cycle cap phase=%0d transport=%0d scope=%0d owners=%0d",
      phase,dut.transport.state,scope_active,active_owners);
  end

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask

  task automatic load_packet(input string name,output logic [8191:0] value);
    $readmemh({fixture,"/",name,".hex"},fixture_beats);
    for(int beat=0;beat<16;beat++)value[beat*512+:512]=fixture_beats[beat];
  endtask

  task automatic send_packet(input logic [8191:0] value,
      input logic use_physical,input logic [15:0] pstatus,
      input logic [63:0] observed0,input logic coverage,
      input logic drained);
    if(use_physical)begin
      physical_status=pstatus;
      physical_error_detail=pstatus ? 32'h04000008 : 0;
      physical_bad_element=pstatus ? 64'd7 : 64'hffffffffffffffff;
      physical_observed_store_bytes0=observed0;
      physical_observed_store_bytes1=0;
      physical_drained=drained;physical_coverage_complete=coverage;
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

  task automatic send_observation(input logic [15:0] pstatus,
      input logic [63:0] observed0,input logic coverage,input logic drained);
    physical_status=pstatus;
    physical_error_detail=pstatus ? 32'h04000008 : 0;
    physical_bad_element=pstatus ? 64'd7 : 64'hffffffffffffffff;
    physical_observed_store_bytes0=observed0;
    physical_observed_store_bytes1=0;
    physical_drained=drained;physical_coverage_complete=coverage;
    physical_observation_valid=1;
    while(!physical_observation_ready)tick();
    tick();physical_observation_valid=0;
  endtask

  task automatic receive_packet(output logic [4095:0] value);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      repeat(2)begin
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"response changed under caller backpressure phase=%0d",phase);
        tick();
      end
      value[beat*512+:512]=held;
      provenance_rsp_read=1;tick();provenance_rsp_read=0;
    end
    repeat(2)tick();
  endtask

  task automatic transact(input string name,input logic use_physical,
      input logic [15:0] pstatus,input logic [63:0] observed0,
      input logic coverage,input logic [15:0] expected_status,
      input logic [7:0] expected_flags);
    load_packet(name,packet);
    send_packet(packet,use_physical,pstatus,observed0,coverage,1);
    receive_packet(received);
    if(received[MAGIC*8+:32]!=RESPONSE_MAGIC ||
       received[ACTION*8+:16]!=packet[ACTION*8+:16] ||
       received[EVENT_SEQ*8+:64]!=packet[EVENT_SEQ*8+:64] ||
       received[RESPONSE_STATUS*8+:16]!=expected_status ||
       received[RESPONSE_FLAGS*8+:8]!=expected_flags ||
       received[RESPONSE_IDENTITY*8+:672]!=packet[IDENTITY*8+:672] ||
       received[RESPONSE_CONTEXT*8+:96]!=packet[CONTEXT*8+:96])
      $fatal(1,"response mismatch name=%s status=%0d flags=%0h detail=%08x accepted_requests=%0d accepted_events=%0d semantic_rejections=%0d protocol_error=%0d",
             name,received[RESPONSE_STATUS*8+:16],
             received[RESPONSE_FLAGS*8+:8],
             received[RESPONSE_DETAIL*8+:32],accepted_requests,
             accepted_events,semantic_rejections,protocol_error);
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    provenance_cmd_din=0;
    repeat(5)tick();rst_n=1;tick();
    if(!domain_drained || active_owners!=0)$fatal(1,"initial ledger not drained");

    phase=1;transact("claim1",0,0,0,1,0,8'h01);
    if(active_owners!=1 || published_owners!=0)$fatal(1,"claim state");
    phase=2;transact("begin1",0,0,0,1,0,8'h03);
    if(!scope_active)$fatal(1,"BEGIN scope absent");
    // A transport-generated rejection during an active scope cannot claim the
    // physical domain is drained.  Corrupt magic so this frame never reaches
    // the semantic hub or consumes its trusted sequence.
    phase=3;load_packet("bad_end1",packet);packet[MAGIC*8+:8]^=8'h01;
    send_packet(packet,0,0,0,0,0);receive_packet(received);
    if(received[RESPONSE_STATUS*8+:16]!=E_ABI ||
       received[RESPONSE_FLAGS*8+:8]!=8'h02 || accepted_events!=2 ||
       !scope_active)$fatal(1,"transport rejection falsified drain/scope");
    phase=4;load_packet("bad_end1",packet);
    send_packet(packet,1,0,65536,1,0);receive_packet(received);
    if(received[RESPONSE_STATUS*8+:16]!=E_PROTOCOL ||
       received[RESPONSE_FLAGS*8+:8]!=8'h02 || !scope_active)
      $fatal(1,"undrained wrong-origin END released scope or claimed drain");
    phase=5;load_packet("end1",packet);
    send_packet(packet,1,0,4096,0,0);
    repeat(3)tick();
    if(!scope_active || provenance_rsp_empty_n || terminal_tasks!=0)
      $fatal(1,"undrained END produced a terminal response");
    send_observation(0,65536,1,1);
    receive_packet(received);
    if(received[RESPONSE_STATUS*8+:16]!=0 ||
       received[RESPONSE_FLAGS*8+:8]!=8'h01 ||
       received[EVENT_SEQ*8+:64]!=packet[EVENT_SEQ*8+:64])
      $fatal(1,"fenced END response mismatch");
    if(scope_active || terminal_tasks!=1)$fatal(1,"good END did not close");

    phase=6;transact("duplicate_end1",1,0,65536,1,E_PROTOCOL,8'h01);
    if(scope_active || terminal_tasks!=1)$fatal(1,"duplicate END changed terminal state");
    // PUBLISH also waits for a real fence.  Preserve the first error observed
    // while undrained even if the final observation itself returns OK.
    phase=7;load_packet("publish_incomplete",packet);
    send_packet(packet,1,0,0,0,0);
    repeat(3)tick();
    if(provenance_rsp_empty_n || published_owners!=0)
      $fatal(1,"undrained PUBLISH produced a response");
    send_observation(E_BUFFER,0,0,0);
    repeat(2)tick();
    if(provenance_rsp_empty_n)$fatal(1,"mid-fence error became terminal");
    send_observation(0,0,1,1);receive_packet(received);
    if(received[RESPONSE_STATUS*8+:16]!=E_BUFFER ||
       received[RESPONSE_FLAGS*8+:8]!=8'h01)
      $fatal(1,"PUBLISH lost first undrained error");
    if(published_owners!=0)$fatal(1,"incomplete publication admitted");
    phase=8;transact("publish1",1,0,0,1,0,8'h05);
    if(published_owners!=1)$fatal(1,"publication state absent");
    phase=9;transact("release1",1,0,0,1,0,8'h01);
    if(active_owners!=0)$fatal(1,"release did not free owner");

    phase=10;transact("claim2",0,0,0,1,0,8'h01);
    phase=11;transact("begin2",0,0,0,1,0,8'h03);
    phase=12;load_packet("failed_end2",packet);
    send_packet(packet,1,0,4096,0,0);
    send_observation(E_BUFFER,4096,0,0);
    send_observation(0,4096,0,1);receive_packet(received);
    if(received[RESPONSE_STATUS*8+:16]!=E_BUFFER ||
       received[RESPONSE_FLAGS*8+:8]!=8'h01)
      $fatal(1,"END fence lost intermediate physical first error");
    if(scope_active || terminal_tasks!=2)$fatal(1,"failed END terminal state");
    phase=13;transact("invalidate2",1,0,0,1,0,8'h01);
    if(active_owners!=0)$fatal(1,"invalidate did not free failed owner");

    phase=14;transact("qkv_claim",0,0,0,1,0,8'h01);
    if(active_owners!=2)$fatal(1,"QKV pair not atomic on claim");
    phase=15;transact("qkv_invalidate",1,0,0,1,0,8'h01);
    if(active_owners!=0)$fatal(1,"QKV pair not atomic on invalidate");

    phase=16;transact("replay",0,0,0,1,E_PROTOCOL,8'h01);
    if(accepted_events!=14)$fatal(1,"replay reached semantic hub");
    phase=17;transact("bad_model",0,0,0,1,E_MODEL,8'h01);
    if(accepted_events!=14)$fatal(1,"bad model reached semantic hub");
    phase=18;transact("bad_header",0,0,0,1,E_ABI,8'h01);
    if(last_event_seq!=15)$fatal(1,"untrusted large sequence polluted high-water");
    phase=19;transact("claim3",0,0,0,1,0,8'h01);
    if(last_event_seq!=16 || active_owners!=1)$fatal(1,"post-bad-header recovery");

    phase=20;cancel=1;
    for(int wait_cycles=0;wait_cycles<30 && active_owners!=0;wait_cycles++)tick();
    if(active_owners!=0)$fatal(1,"gap cancel did not invalidate owner");
    cancel=0;repeat(4)tick();
    if(!domain_drained || transport_busy || scope_active)
      $fatal(1,"cancelled ledger did not drain");

    for(int request_index=0;request_index<33;request_index++)begin
      phase=21+request_index*4;
      transact($sformatf("loop_claim_%0d",request_index),0,0,0,1,0,8'h01);
      transact($sformatf("loop_begin_%0d",request_index),0,0,0,1,0,8'h03);
      transact($sformatf("loop_end_%0d",request_index),1,
               request_index==0 ? E_BUFFER : 0,65536,1,
               request_index==0 ? E_BUFFER : 0,8'h01);
      transact($sformatf("loop_invalidate_%0d",request_index),1,0,0,1,0,8'h01);
      if(active_owners!=0 || scope_active)
        $fatal(1,"typed recycle request did not drain index=%0d",request_index);
    end
    phase=153;transact("stale_claim",0,0,0,1,E_PROTOCOL,8'h01);
    if(active_owners!=0 || scope_active)
      $fatal(1,"stale request changed ledger state");

    if(protocol_error || accepted_requests!=148 || accepted_events!=148 ||
       retired_responses!=152 || semantic_rejections!=4 || terminal_tasks!=35)
      $fatal(1,"final counts req=%0d events=%0d retired=%0d rejects=%0d terminal=%0d",
        accepted_requests,accepted_events,retired_responses,
        semantic_rejections,terminal_tasks);
    $display("FULL_CURRENT_GENERATED_PROVENANCE_PORTAL_PASS accepted=%0d retired=%0d semantic_rejections=%0d terminal_tasks=%0d scope_retention=1 honest_undrained=1 physical_first_error=1 owner_fence_wait=1 duplicate_end=1 qkv_atomic=1 bad_header_highwater=1 cancel_cleanup=1 typed_recycle_requests=33 stale_request_rejected=1 cycles=%0d",
      accepted_events,retired_responses,semantic_rejections,terminal_tasks,cycles);
    $finish;
  end
endmodule
