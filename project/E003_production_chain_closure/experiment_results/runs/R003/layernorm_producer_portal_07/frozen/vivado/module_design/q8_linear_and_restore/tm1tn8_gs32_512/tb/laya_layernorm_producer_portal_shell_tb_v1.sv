`timescale 1ns/1ps
module laya_layernorm_producer_portal_shell_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;always #3.333 clk=~clk;
  logic [63:0] monitored_bo_base=64'h0000000300000000;
  localparam logic [63:0] DESTINATION_FIRST=64'h0000000300800000;

  logic [511:0] provenance_cmd_din;
  logic provenance_cmd_write,provenance_cmd_full_n;
  logic [511:0] provenance_rsp_dout;
  logic provenance_rsp_empty_n,provenance_rsp_read;
  logic [511:0] producer_request_dout;
  logic producer_request_empty_n,producer_request_read;
  logic [511:0] producer_completion_din;
  logic producer_completion_full_n,producer_completion_write;
  logic source_query_valid,source_query_ready,source_query_granted;
  logic [8191:0] source_query_command;
  logic source_release_valid,source_release_ready,source_release_drained;
  logic [8191:0] source_release_command;
  logic source_lease_active;
  logic [63:0] source_axi_araddr;
  logic [7:0] source_axi_arlen;
  logic [2:0] source_axi_arsize;
  logic [1:0] source_axi_arburst;
  logic source_axi_arvalid,source_axi_arready;
  logic [511:0] source_axi_rdata;
  logic [1:0] source_axi_rresp;
  logic source_axi_rlast,source_axi_rvalid,source_axi_rready;
  logic [63:0] destination_axi_awaddr;
  logic [7:0] destination_axi_awlen;
  logic [2:0] destination_axi_awsize;
  logic [1:0] destination_axi_awburst;
  logic destination_axi_awvalid,destination_axi_awready;
  logic [511:0] destination_axi_wdata;
  logic [63:0] destination_axi_wstrb;
  logic destination_axi_wlast,destination_axi_wvalid,destination_axi_wready;
  logic [1:0] destination_axi_bresp;
  logic destination_axi_bvalid,destination_axi_bready;
  logic base_configured,adapter_pending_zero,job_active;
  logic shell_protocol_error,ledger_protocol_error;
  logic ledger_scope_active,ledger_domain_drained;
  logic monitor_scope_active,monitor_drained,monitor_coverage_complete;
  logic [15:0] monitor_status;
  logic [63:0] monitor_observed0;
  logic [31:0] forwarded_aw,forwarded_w,retired_b;
  logic [31:0] source_outstanding_beats;
  logic [63:0] last_event_seq;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses;
  logic [31:0] accepted_events,semantic_rejections,terminal_tasks;

  laya_layernorm_producer_portal_shell_v1 dut(.*);

  string fixture;
  logic [511:0] packet_beats[0:15],producer_beats[0:15];
  logic [8191:0] provenance_packet,query_packet;
  logic [4095:0] provenance_response,completion_packet;
  logic [31:0] source_mem[0:16383],gold_mem[0:16383];
  logic [31:0] destination_mem[0:16383];
  integer cycles=0,phase=0,target_rows=16;
  integer producer_index=0,completion_index=0;
  integer source_ar_count=0,source_r_count=0;
  integer source_read_index=0,source_read_left=0,source_delay=0;
  integer destination_aw_count=0,destination_w_count=0;
  integer destination_word_index=0,destination_write_left=0;
  integer destination_b_delay=0,destination_b_count=0;
  integer destination_store_bytes=0;
  logic source_read_active=0,destination_write_active=0;
  logic producer_loaded=0,completion_seen=0,end_sent=0;
  logic [511:0] completion_hold;

  task automatic tick;@(posedge clk);#1;endtask
  task automatic load_packet(input string name,output logic [8191:0] value);
    $readmemh({fixture,"/",name,".hex"},packet_beats);
    for(int beat=0;beat<16;beat++)value[beat*512+:512]=packet_beats[beat];
  endtask
  task automatic send_provenance(input string name);
    load_packet(name,provenance_packet);
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);provenance_cmd_din=provenance_packet[beat*512+:512];
      provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
  endtask
  task automatic receive_provenance(
      input logic [15:0] expected_action,input logic [15:0] expected_status,
      input logic [7:0] expected_flags);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      if(beat==7 && expected_action==BEGIN_EVENT &&
         (producer_index!=0 || source_ar_count!=0 || destination_aw_count!=0))
        $fatal(1,"producer escaped before complete BEGIN response");
      repeat(beat==0 ? 3 : 1)begin
        tick();
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"provenance response changed under backpressure phase=%0d",phase);
      end
      provenance_response[beat*512+:512]=held;
      @(negedge clk);provenance_rsp_read=1;tick();
      @(negedge clk);provenance_rsp_read=0;
    end
    if(provenance_response[ACTION*8+:16]!=expected_action ||
       provenance_response[RESPONSE_STATUS*8+:16]!=expected_status ||
       provenance_response[RESPONSE_FLAGS*8+:8]!=expected_flags)
      $fatal(1,"provenance response action=%0d status=%0d flags=%0h phase=%0d",
        provenance_response[ACTION*8+:16],
        provenance_response[RESPONSE_STATUS*8+:16],
        provenance_response[RESPONSE_FLAGS*8+:8],phase);
  endtask
  task automatic transact(input string name,input logic [15:0] action,
      input logic [7:0] flags);
    send_provenance(name);receive_provenance(action,0,flags);
  endtask

  always_comb begin
    producer_request_empty_n=producer_loaded && producer_index<16;
    producer_request_dout=producer_index<16 ? producer_beats[producer_index] : 0;
    producer_completion_full_n=cycles%7!=3;
  end

  always @(posedge clk)begin
    cycles=cycles+1;
    if(cycles>5000000)$fatal(1,"LayerNorm portal cycle cap phase=%0d",phase);
    if(!rst_n)begin
      producer_index<=0;completion_index=0;completion_seen=0;
    end else begin
      if(producer_request_read && producer_request_empty_n)begin
        producer_index<=producer_index+1;
        if(producer_index==15)
          $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS producer_request_complete cycles=%0d",cycles);
      end
      if(producer_completion_write)begin
        if(!producer_completion_full_n)
          $fatal(1,"completion write while full");
        if(completion_index==0 && retired_b!=target_rows)
          $fatal(1,"completion preceded real engine B retirement count=%0d status=%0d unit=%0d finished=%0d seq=%0d origin=%0d detail=%h bad=%h issued=%0d consumed=%0d",
            retired_b,producer_completion_din[10*8+:16],
            producer_completion_din[12*8+:8],producer_completion_din[13*8+:8],
            producer_completion_din[16*8+:64],producer_completion_din[24*8+:64],
            producer_completion_din[32*8+:32],producer_completion_din[40*8+:64],
            producer_completion_din[48*8+:64],producer_completion_din[56*8+:64]);
        completion_packet[completion_index*512+:512]=producer_completion_din;
        completion_index=completion_index+1;
        if(completion_index==8)begin
          completion_seen=1;
          $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS completion_complete cycles=%0d",cycles);
        end
      end
      if(job_active && completion_index<8 && adapter_pending_zero)
        $fatal(1,"adapter fence opened before completion delivery");
    end
  end

  always @(negedge clk)begin
    source_axi_arready=rst_n && !source_read_active && !source_axi_rvalid &&
                       cycles%5!=0;
    if(source_read_active && !source_axi_rvalid)begin
      if(source_delay>0)source_delay=source_delay-1;
      else begin
        source_axi_rvalid=1;source_axi_rresp=0;
        source_axi_rlast=source_read_left==1;
        for(int lane=0;lane<16;lane++)
          source_axi_rdata[lane*32+:32]=source_mem[source_read_index*16+lane];
      end
    end
    destination_axi_awready=rst_n && !destination_write_active &&
                            !destination_axi_bvalid && cycles%4!=0;
    destination_axi_wready=rst_n && destination_write_active &&
                           !destination_axi_bvalid && cycles%6!=0;
    if(destination_b_delay>0)destination_b_delay=destination_b_delay-1;
    else if(destination_write_active && destination_write_left==0 &&
            !destination_axi_bvalid)begin
      destination_axi_bvalid=1;destination_axi_bresp=0;
    end
  end

  always @(posedge clk)begin
    if(!rst_n)begin
      source_read_active=0;source_axi_rvalid=0;source_read_index=0;
      source_read_left=0;source_delay=0;source_ar_count=0;source_r_count=0;
      destination_write_active=0;destination_axi_bvalid=0;
      destination_word_index=0;destination_write_left=0;
      destination_b_delay=0;destination_aw_count=0;destination_w_count=0;
      destination_b_count=0;destination_store_bytes=0;
    end else begin
      if(source_axi_arvalid && source_axi_arready)begin
        if(source_read_active || source_axi_arsize!=6 ||
           source_axi_arburst!=1 || source_axi_arlen!=63 ||
           source_axi_araddr<monitored_bo_base ||
           source_axi_araddr+4096>monitored_bo_base+65536)
          $fatal(1,"source AR addr=%h len=%0d",source_axi_araddr,source_axi_arlen);
        source_read_active=1;
        source_read_index=int'((source_axi_araddr-monitored_bo_base)>>6);
        source_read_left=int'(source_axi_arlen)+1;source_delay=1;
        source_ar_count=source_ar_count+1;
        $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS source_AR row=%0d cycles=%0d",
          source_ar_count-1,cycles);
      end
      if(source_axi_rvalid && source_axi_rready)begin
        source_axi_rvalid<=0;source_read_index=source_read_index+1;
        source_read_left=source_read_left-1;source_r_count=source_r_count+1;
        source_delay=1+(source_r_count%3);
        if(source_read_left==0)source_read_active=0;
      end
      if(destination_axi_awvalid && destination_axi_awready)begin
        if(destination_write_active || destination_axi_awaddr<DESTINATION_FIRST ||
           destination_axi_awaddr+4096>DESTINATION_FIRST+65536 ||
           destination_axi_awlen!=63 || destination_axi_awsize!=6 ||
           destination_axi_awburst!=1)
          $fatal(1,"destination AW addr=%h len=%0d",destination_axi_awaddr,
                 destination_axi_awlen);
        destination_write_active=1;
        destination_word_index=int'((destination_axi_awaddr-DESTINATION_FIRST)>>2);
        destination_write_left=64;destination_aw_count=destination_aw_count+1;
      end
      if(destination_axi_wvalid && destination_axi_wready)begin
        if(!destination_write_active ||
           destination_axi_wlast!=(destination_write_left==1) ||
           destination_axi_wstrb!==64'hffffffffffffffff)
          $fatal(1,"destination W protocol left=%0d last=%0d strb=%h",
                 destination_write_left,destination_axi_wlast,
                 destination_axi_wstrb);
        for(int lane=0;lane<16;lane++)
          destination_mem[destination_word_index+lane]=
            destination_axi_wdata[lane*32+:32];
        destination_word_index=destination_word_index+16;
        destination_write_left=destination_write_left-1;
        destination_w_count=destination_w_count+1;
        destination_store_bytes=destination_store_bytes+64;
        if(destination_write_left==0)destination_b_delay=12;
      end
      if(destination_axi_bvalid && destination_axi_bready)begin
        destination_axi_bvalid<=0;destination_write_active=0;
        destination_b_count=destination_b_count+1;
        $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS destination_B row=%0d cycles=%0d",
          destination_b_count-1,cycles);
      end
    end
  end

  initial begin
    provenance_cmd_din=0;provenance_cmd_write=0;provenance_rsp_read=0;
    source_query_valid=0;source_query_command=0;source_release_valid=0;
    source_release_command=0;source_release_drained=1;
    source_axi_arready=0;source_axi_rdata=0;source_axi_rresp=0;
    source_axi_rlast=0;source_axi_rvalid=0;
    destination_axi_awready=0;destination_axi_wready=0;
    destination_axi_bresp=0;destination_axi_bvalid=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"LayerNorm producer portal fixture path");
    if($value$plusargs("ROWS=%d",target_rows) &&
       target_rows!=1 && target_rows!=16)$fatal(1,"unsupported test rows");
    $readmemh({fixture,"/producer_request.hex"},producer_beats);
    $readmemh({fixture,"/source.mem"},source_mem);
    $readmemh({fixture,"/gold.mem"},gold_mem);
    for(int i=0;i<16384;i++)destination_mem[i]='x;
    producer_loaded=1;
    repeat(8)tick();@(negedge clk);rst_n=1;
    while(!base_configured)tick();repeat(4)tick();
    if(adapter_pending_zero!==1 || producer_index!=0 || shell_protocol_error)
      $fatal(1,"base initialization/fence failed");
    $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS base_configured cycles=%0d",cycles);

    phase=1;transact("claim",CLAIM,8'h01);
    phase=2;transact("begin",BEGIN_EVENT,8'h03);
    $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS begin_response_complete cycles=%0d",cycles);
    while(producer_index<16)tick();
    while(!job_active && !shell_protocol_error)tick();
    if(!job_active || !monitor_scope_active || adapter_pending_zero)
      $fatal(1,"producer did not enter bound active scope");

    phase=3;send_provenance("end");end_sent=1;
    repeat(20)begin
      tick();
      if(provenance_rsp_empty_n)$fatal(1,"END responded before physical fence");
    end
    while(!completion_seen)begin
      tick();
      if(provenance_rsp_empty_n)$fatal(1,"END responded before completion fence");
    end
    if(!monitor_coverage_complete)
      $fatal(1,"monitor did not close real WSTRB coverage before END response");
    if(completion_packet[0+:32]!=32'h3143504c ||
       completion_packet[10*8+:16]!=0 || completion_packet[12*8+:8]!=1 ||
       completion_packet[13*8+:8]!=1 ||
       completion_packet[16*8+:64]!=41 ||
       completion_packet[24*8+:64]!=301 ||
       completion_packet[36*8+:32]!=target_rows*1024 ||
       completion_packet[40*8+:64]!=64'hffffffffffffffff ||
       completion_packet[48*8+:64]!=target_rows*4096 ||
       completion_packet[56*8+:64]!=target_rows*4096)
      $fatal(1,"producer completion fields mismatch");
    while(!provenance_rsp_empty_n)tick();
    receive_provenance(END_EVENT,0,8'h01);
    if(monitor_observed0!=target_rows*4096 || monitor_status!=0 ||
       source_outstanding_beats!=0 ||
       forwarded_aw!=target_rows || forwarded_w!=target_rows*64 || retired_b!=target_rows ||
       source_ar_count!=target_rows || source_r_count!=target_rows*64 ||
       destination_aw_count!=target_rows || destination_w_count!=target_rows*64 ||
       destination_b_count!=target_rows || destination_store_bytes!=target_rows*4096)
      $fatal(1,"physical counters source=%0d/%0d destination=%0d/%0d/%0d bytes=%0d monitor=%0d/%0d/%0d",
        source_ar_count,source_r_count,destination_aw_count,destination_w_count,
        destination_b_count,destination_store_bytes,forwarded_aw,forwarded_w,retired_b);
    for(int i=0;i<target_rows*1024;i++)
      if(destination_mem[i]!==gold_mem[i])
        $fatal(1,"LayerNorm gold mismatch element=%0d got=%h expected=%h",
               i,destination_mem[i],gold_mem[i]);

    phase=4;transact("publish",PUBLISH,8'h05);
    // The rows1 pilot measures this engine/fence.  The production stage2
    // QUANT shape is rows16 and is exercised by the full workload below.
    if(target_rows==16)begin
      load_packet("source_query",query_packet);
      @(negedge clk);
      source_query_command=query_packet;source_query_valid=1;
      #1;
      while(!source_query_ready)begin @(negedge clk);#1;end
      if(!source_query_granted)$fatal(1,"published LayerNorm source query rejected frame_ok=%0d owners=%0d published=%0d scope=%0d",
        laya_compute_portal_layout_v1::command_frame_ok(query_packet),
        active_owners,published_owners,ledger_scope_active);
      tick();@(negedge clk);source_query_valid=0;
      if(!source_lease_active)$fatal(1,"source lease did not latch");
      source_release_command=query_packet;source_release_valid=1;
      #1;
      while(!source_release_ready)begin @(negedge clk);#1;end
      tick();
      @(negedge clk);source_release_valid=0;
      if(source_lease_active)$fatal(1,"source lease did not retire");
    end
    phase=5;transact("release",RELEASE,8'h01);
    if(active_owners!=0 || published_owners!=0 ||
       accepted_requests!=5 || retired_responses!=5 ||
       accepted_events!=5 || semantic_rejections!=0 || terminal_tasks!=1 ||
       shell_protocol_error || ledger_protocol_error ||
       !ledger_domain_drained || !adapter_pending_zero)
      $fatal(1,"final shell/ledger state owners=%0d/%0d req=%0d rsp=%0d events=%0d rejects=%0d terminal=%0d shell=%0d ledger=%0d drained=%0d adapter=%0d",
        active_owners,published_owners,accepted_requests,retired_responses,
        accepted_events,semantic_rejections,terminal_tasks,
        shell_protocol_error,ledger_protocol_error,ledger_domain_drained,
        adapter_pending_zero);
    $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PASS rows=%0d D=1024 source_AR=%0d source_R=%0d destination_AW=%0d destination_W=%0d destination_B=%0d store_bytes=%0d completion_beats=%0d gold_elements=%0d begin_gated=1 early_END_held=1 source_query_granted=%0d source_lease_released=%0d cycles=%0d",
      target_rows,source_ar_count,source_r_count,destination_aw_count,destination_w_count,
      destination_b_count,destination_store_bytes,completion_index,target_rows*1024,
      target_rows==16,target_rows==16,cycles);
    $finish;
  end
endmodule
