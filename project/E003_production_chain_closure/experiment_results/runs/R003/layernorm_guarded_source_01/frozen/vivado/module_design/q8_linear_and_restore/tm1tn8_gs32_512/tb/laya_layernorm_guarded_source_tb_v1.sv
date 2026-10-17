`timescale 1ns/1ps
module laya_layernorm_guarded_source_tb_v1;
  import laya_generated_provenance_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;always #5 clk=~clk;
  localparam logic [63:0] BO_BASE=64'h0000001200000000;
  localparam logic [63:0] NORM_BASE=BO_BASE+8388608;
  logic [63:0] monitored_bo_base=BO_BASE,source_base_epoch=7,source_base_capacity=16920576;
  logic [511:0] provenance_cmd_din=0,provenance_rsp_dout;
  logic provenance_cmd_write=0,provenance_cmd_full_n,provenance_rsp_empty_n,provenance_rsp_read=0;
  logic [511:0] producer_request_dout,producer_completion_din,producer_completion_dout;
  logic producer_request_empty_n,producer_request_read,producer_completion_full_n,producer_completion_write;
  logic producer_completion_empty_n,producer_completion_read=0;
  logic [1:0] producer_completion_occupancy;
  logic source_query_valid=0,source_query_ready,source_query_granted,source_lease_active;
  logic [8191:0] source_query_command=0,source_release_command=0;
  logic source_release_valid=0,source_release_ready,source_release_drained=0;
  logic [63:0] source_axi_araddr;
  logic [7:0] source_axi_arlen;
  logic [2:0] source_axi_arsize;
  logic [1:0] source_axi_arburst;
  logic source_axi_arvalid,source_axi_arready=0;
  logic [511:0] source_axi_rdata=0;
  logic [1:0] source_axi_rresp=0;
  logic source_axi_rlast=0,source_axi_rvalid=0,source_axi_rready;
  logic [63:0] destination_axi_awaddr;
  logic [7:0] destination_axi_awlen;
  logic [2:0] destination_axi_awsize;
  logic [1:0] destination_axi_awburst;
  logic destination_axi_awvalid,destination_axi_awready=0;
  logic [511:0] destination_axi_wdata;
  logic [63:0] destination_axi_wstrb;
  logic destination_axi_wlast,destination_axi_wvalid,destination_axi_wready=0;
  logic [1:0] destination_axi_bresp=0;
  logic destination_axi_bvalid=0,destination_axi_bready;
  logic base_configured,adapter_pending_zero,job_active,shell_protocol_error,ledger_protocol_error;
  logic ledger_scope_active,ledger_domain_drained,monitor_scope_active,monitor_drained,monitor_coverage_complete;
  logic [15:0] monitor_status;
  logic [63:0] monitor_observed0,last_event_seq;
  logic [31:0] forwarded_aw,forwarded_w,retired_b,source_outstanding_beats;
  logic [5:0] active_owners,published_owners;
  logic [31:0] accepted_requests,retired_responses,accepted_events,semantic_rejections,terminal_tasks;
  logic snapshot_request_valid=0,snapshot_request_ready,snapshot_response_valid,snapshot_response_ready=0;
  logic [6143:0] snapshot_request=0,snapshot_response;
  logic [63:0] snapshot_sequence_high_water;
  logic action_valid=0,action_ready;
  logic [4095:0] action_request=0;
  logic [511:0] action_completion_dout,action_completion_din=0;
  logic action_completion_empty_n,action_completion_read=0,action_completion_full_n,action_completion_write=0;
  logic [1:0] action_completion_occupancy;
  logic source_guard_active,source_proof_valid,source_guard_error;
  logic source_guard_action_active,source_guard_producer_active,base_change_ready;
  logic [31:0] source_guard_read_debt;
  logic bootstrap_write_select=0;
  logic [63:0] bootstrap_axi_awaddr=0;
  logic [7:0] bootstrap_axi_awlen=63;
  logic [2:0] bootstrap_axi_awsize=6;
  logic [1:0] bootstrap_axi_awburst=1;
  logic bootstrap_axi_awvalid=0,bootstrap_axi_awready;
  logic [511:0] bootstrap_axi_wdata=0;
  logic [63:0] bootstrap_axi_wstrb='1;
  logic bootstrap_axi_wlast=0,bootstrap_axi_wvalid=0,bootstrap_axi_wready;
  logic [1:0] bootstrap_axi_bresp;
  logic bootstrap_axi_bvalid,bootstrap_axi_bready=0;
  laya_layernorm_producer_portal_shell_v1 #(.ENABLE_BOOTSTRAP_SOURCE_GUARD(1),
      .ENABLE_BOOTSTRAP_WRITE_PORT(1)) dut(.*);
  laya_private_fifo2_v1 producer_fifo(.clk,.rst_n,.in_valid(producer_completion_write),
      .in_ready(producer_completion_full_n),.in_data(producer_completion_din),
      .out_valid(producer_completion_empty_n),.out_ready(producer_completion_read),
      .out_data(producer_completion_dout),.occupancy(producer_completion_occupancy));
  laya_private_fifo2_v1 action_fifo(.clk,.rst_n,.in_valid(action_completion_write),
      .in_ready(action_completion_full_n),.in_data(action_completion_din),
      .out_valid(action_completion_empty_n),.out_ready(action_completion_read),
      .out_data(action_completion_dout),.occupancy(action_completion_occupancy));
  string fixture;
  logic [511:0] packet_words[0:15],producer_words[0:15],snapshot_words[0:11],action_words[0:3];
  logic [8191:0] packet;
  logic [4095:0] response,actual_completion=0;
  logic [2047:0] action_error;
  logic [31:0] fixture_source[0:16383],gold[0:16383];
  // Source and destination begin unknown, and only real forwarded W fills them.
  logic [31:0] checkpoint_mem[0:65535],destination_mem[0:1023];
  int cycles=0,phase=0,producer_index=0,completion_index=0;
  bit producer_loaded=0,read_active=0,write_active=0,writing_checkpoint=0;
  int read_index=0,read_left=0,read_delay=0,write_index=0,write_left=0,b_delay=0;
  int source_ar=0,source_r=0,peer_aw=0,peer_w=0,peer_b=0,checkpoint_w=0,norm_w=0;
  task automatic tick;@(posedge clk);#1;@(negedge clk);endtask
  task automatic load(input string name,output logic [8191:0] value);
    for(int i=0;i<16;i++)packet_words[i]=0;
    $readmemh({fixture,"/",name,".hex"},packet_words);
    for(int i=0;i<16;i++)value[i*512+:512]=packet_words[i];
  endtask
  task automatic send(input logic [8191:0] value);
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);provenance_cmd_din=value[beat*512+:512];provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
  endtask
  task automatic receive(input logic [15:0] kind,status,input logic [7:0] flags);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!provenance_rsp_empty_n)tick();
      held=provenance_rsp_dout;
      repeat(beat==0 ? 12 : 1)begin
        if(!provenance_rsp_empty_n || provenance_rsp_dout!==held)
          $fatal(1,"LPV response changed under pressure phase=%0d",phase);
        tick();
      end
      response[beat*512+:512]=held;
      provenance_rsp_read=1;tick();provenance_rsp_read=0;
    end
    if(response[ACTION*8+:16]!=kind || response[RESPONSE_STATUS*8+:16]!=status ||
       response[RESPONSE_FLAGS*8+:8]!=flags)$fatal(1,"LPV mismatch phase=%0d kind=%0d status=%0d flags=%0d",phase,response[ACTION*8+:16],response[RESPONSE_STATUS*8+:16],response[RESPONSE_FLAGS*8+:8]);
    tick();
  endtask
  task automatic transaction(input string name,input logic [15:0] kind,status,input logic [7:0] flags);
    load(name,packet);send(packet);receive(kind,status,flags);
  endtask
  task automatic write_checkpoint_row(input int row);
    bootstrap_axi_awaddr=BO_BASE+64'(row)*4096;bootstrap_axi_awvalid=1;
    do begin @(posedge clk);end while(!bootstrap_axi_awready);
    #1;@(negedge clk);bootstrap_axi_awvalid=0;
    for(int beat=0;beat<64;beat++)begin
      for(int lane=0;lane<16;lane++)bootstrap_axi_wdata[lane*32+:32]=fixture_source[(row%16)*1024+beat*16+lane];
      bootstrap_axi_wlast=beat==63;bootstrap_axi_wvalid=1;
      do begin @(posedge clk);end while(!bootstrap_axi_wready);
      #1;@(negedge clk);bootstrap_axi_wvalid=0;
    end
    while(!bootstrap_axi_bvalid)tick();
    if(bootstrap_axi_bresp!=0)$fatal(1,"prelude store failed");
    bootstrap_axi_bready=1;tick();bootstrap_axi_bready=0;tick();
  endtask
  always_comb begin
    producer_request_empty_n=producer_loaded && producer_index<16;
    producer_request_dout=producer_index<16 ? producer_words[producer_index] : 0;
  end
  always @(posedge clk)begin
    cycles=cycles+1;
    if(cycles>100000)$fatal(1,"finite guarded LN cycle cap phase=%0d",phase);
    if(rst_n && producer_request_read && producer_request_empty_n)producer_index<=producer_index+1;
    if(rst_n && producer_completion_read && producer_completion_empty_n)begin
      actual_completion[completion_index*512+:512]=producer_completion_dout;
      completion_index=completion_index+1;
    end
    if(rst_n && source_guard_active && bootstrap_axi_awready)
      $fatal(1,"bootstrap write bypass open during protection");
  end
  always @(negedge clk)begin
    source_axi_arready=rst_n && !read_active && !source_axi_rvalid && cycles%5!=0;
    if(read_active && !source_axi_rvalid)begin
      if(read_delay>0)read_delay=read_delay-1;
      else begin
        source_axi_rvalid=1;source_axi_rlast=read_left==1;
        for(int lane=0;lane<16;lane++)source_axi_rdata[lane*32+:32]=checkpoint_mem[read_index*16+lane];
      end
    end
    destination_axi_awready=rst_n && !write_active && !destination_axi_bvalid && cycles%4!=0;
    destination_axi_wready=rst_n && write_active && !destination_axi_bvalid && cycles%6!=0;
    if(b_delay>0)b_delay=b_delay-1;
    else if(write_active && write_left==0 && !destination_axi_bvalid)destination_axi_bvalid=1;
  end
  always @(posedge clk)if(rst_n)begin
    if(source_axi_arvalid && source_axi_arready)begin
      if(!source_guard_active || !source_proof_valid || !source_guard_producer_active ||
         source_axi_araddr!=BO_BASE || source_axi_arlen!=63 || source_axi_arsize!=6 ||
         source_axi_arburst!=1)$fatal(1,"unprotected real engine read");
      read_active=1;read_index=0;read_left=64;read_delay=12;source_ar=source_ar+1;
      $display("FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_PROGRESS source_AR cycles=%0d",cycles);
    end
    if(source_axi_rvalid && source_axi_rready)begin
      source_axi_rvalid<=0;read_index=read_index+1;read_left=read_left-1;source_r=source_r+1;
      read_delay=1+source_r%3;if(read_left==0)read_active=0;
    end
    if(destination_axi_awvalid && destination_axi_awready)begin
      if(write_active || destination_axi_awlen!=63 || destination_axi_awsize!=6 || destination_axi_awburst!=1)
        $fatal(1,"bad shared monitored AW");
      writing_checkpoint=destination_axi_awaddr<NORM_BASE;
      if(writing_checkpoint)begin
        if(source_guard_active || destination_axi_awaddr<BO_BASE || destination_axi_awaddr+4096>BO_BASE+262144)
          $fatal(1,"source write escaped exclusion");
        write_index=int'((destination_axi_awaddr-BO_BASE)>>2);
      end else begin
        if(destination_axi_awaddr!=NORM_BASE)$fatal(1,"target store out of bounds");
        write_index=0;
      end
      write_active=1;write_left=64;peer_aw=peer_aw+1;
    end
    if(destination_axi_wvalid && destination_axi_wready)begin
      if(!write_active || destination_axi_wlast!=(write_left==1) || destination_axi_wstrb!=='1)
        $fatal(1,"bad shared monitored W");
      for(int lane=0;lane<16;lane++)begin
        if(writing_checkpoint)checkpoint_mem[write_index+lane]=destination_axi_wdata[lane*32+:32];
        else destination_mem[write_index+lane]=destination_axi_wdata[lane*32+:32];
      end
      write_index=write_index+16;write_left=write_left-1;peer_w=peer_w+1;
      if(writing_checkpoint)checkpoint_w=checkpoint_w+1;else norm_w=norm_w+1;
      if(write_left==0)b_delay=12;
    end
    if(destination_axi_bvalid && destination_axi_bready)begin
      destination_axi_bvalid<=0;write_active=0;peer_b=peer_b+1;
    end
  end
  task automatic pop_producer;
    while(!producer_completion_empty_n)tick();
    producer_completion_read=1;tick();producer_completion_read=0;
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture required");
    $readmemh({fixture,"/source.mem"},fixture_source);$readmemh({fixture,"/gold.mem"},gold);
    $readmemh({fixture,"/producer_request.hex"},producer_words);
    for(int i=0;i<65536;i++)checkpoint_mem[i]='x;
    for(int i=0;i<1024;i++)destination_mem[i]='x;
    repeat(8)tick();rst_n=1;while(!base_configured)tick();
    bootstrap_write_select=1;repeat(4)tick();
    phase=1;transaction("claim",CLAIM,0,1);
    for(int window=0;window<4;window++)begin
      phase=2+window;transaction($sformatf("begin%0d",window),BEGIN_EVENT,0,3);
      for(int row=0;row<16;row++)write_checkpoint_row(window*16+row);
      transaction($sformatf("end%0d",window),END_EVENT,0,1);
    end
    transaction("publish",PUBLISH,0,5);
    bootstrap_write_select=0;repeat(4)tick();
    if(terminal_tasks!=4 || peer_aw!=64 || peer_w!=4096 || peer_b!=64 || published_owners!=1 || source_ar!=0)
      $fatal(1,"normal four-window prelude mismatch");
    for(int i=0;i<65536;i++)if(checkpoint_mem[i]!==fixture_source[i%16384])$fatal(1,"prelude memory not from actual W");
    phase=6;$readmemh({fixture,"/snapshot.hex"},snapshot_words);
    for(int i=0;i<12;i++)snapshot_request[i*512+:512]=snapshot_words[i];
    snapshot_request_valid=1;do begin @(posedge clk);end while(!snapshot_request_ready);
    #1;@(negedge clk);snapshot_request_valid=0;
    while(!snapshot_response_valid)tick();
    repeat(12)begin
      if(!source_guard_active || source_proof_valid || source_ar!=0)$fatal(1,"snapshot write/read exclusion failed");tick();
    end
    if(snapshot_response[10*8+:16]!=0 || snapshot_response[12*8+:32]!=63)$fatal(1,"full snapshot rejected");
    snapshot_response_ready=1;tick();snapshot_response_ready=0;tick();
    if(!source_proof_valid)$fatal(1,"snapshot proof not retained");
    transaction("source_conflict_before",INVALIDATE,E_BUFFER,0);
    load("action",packet);action_request=packet[0+:4096];action_valid=1;#1;
    if(!action_ready)$fatal(1,"real shell action key rejected");tick();action_valid=0;
    transaction("target_claim",CLAIM,0,1);
    transaction("target_begin",BEGIN_EVENT,0,3);producer_loaded=1;
    while(source_ar==0)tick();
    transaction("source_conflict_live",INVALIDATE,E_BUFFER,2);
    while(completion_index<6)pop_producer();
    while(producer_completion_occupancy!=2)tick();
    repeat(12)begin
      if(!job_active || !source_guard_producer_active || !source_guard_active || adapter_pending_zero)
        $fatal(1,"LPC1 tail2 enqueue released fence");tick();
    end
    pop_producer();repeat(12)begin
      if(!job_active || !source_guard_producer_active || !source_guard_active || adapter_pending_zero)
        $fatal(1,"LPC1 tail1 enqueue released fence");tick();
    end
    pop_producer();tick();
    if(actual_completion[0+:32]!=32'h3143504c || actual_completion[10*8+:16]!=0 ||
       actual_completion[36*8+:32]!=1024 || actual_completion[48*8+:64]!=4096 ||
       actual_completion[56*8+:64]!=4096 || completion_index!=8 || source_ar!=1 || source_r!=64 ||
       job_active || source_guard_producer_active || source_guard_read_debt || source_outstanding_beats)
      $fatal(1,"actual F9 verified producer completion/debt mismatch");
    for(int i=0;i<1024;i++)if(destination_mem[i]!==gold[i])$fatal(1,"guarded LN independent gold element=%0d got=%h expected=%h",i,destination_mem[i],gold[i]);
    // Caller simulation copies every END result field from real LPC1, as in
    // the earlier numerical chain. This remains a finite caller diagnostic.
    phase=7;load("target_end_template",packet);
    packet[REPORTED_STATUS*8+:16]=actual_completion[10*8+:16];
    packet[REPORTED_UNIT*8+:8]=actual_completion[12*8+:8];
    packet[REPORTED_ELEMENTS*8+:32]=actual_completion[36*8+:32];
    packet[REPORTED_DETAIL*8+:32]=actual_completion[32*8+:32];
    packet[REPORTED_BAD*8+:64]=actual_completion[40*8+:64];
    packet[ISSUED0*8+:64]=actual_completion[48*8+:64];
    send(packet);receive(END_EVENT,E_PROTOCOL,1);
    if(terminal_tasks!=5 || response[RESPONSE_OBSERVED0*8+:64]!=4096 || !source_guard_active)
      $fatal(1,"short owner END did not reject/retire honestly");
    transaction("target_invalidate",INVALIDATE,0,1);
    $readmemh({fixture,"/action_error_template.hex"},action_words);
    for(int i=0;i<4;i++)action_error[i*512+:512]=action_words[i];
    phase=8;fork
      begin
        for(int i=0;i<4;i++)begin
          action_completion_din=action_error[i*512+:512];action_completion_write=1;
          do begin @(posedge clk);end while(!action_completion_full_n);
          #1;@(negedge clk);action_completion_write=0;
        end
      end
      begin
        for(int i=0;i<2;i++)begin
          while(!action_completion_empty_n)tick();action_completion_read=1;tick();action_completion_read=0;
        end
        while(action_completion_occupancy!=2)tick();
        repeat(12)begin if(!source_guard_active || !source_guard_action_active || base_change_ready)$fatal(1,"LAC1 tail2 released source");tick();end
        action_completion_read=1;tick();action_completion_read=0;
        repeat(12)begin if(!source_guard_active || !source_guard_action_active || base_change_ready)$fatal(1,"LAC1 tail1 released source");tick();end
        action_completion_read=1;tick();action_completion_read=0;repeat(3)tick();
      end
    join
    if(source_guard_active || source_guard_action_active || !base_change_ready || source_guard_error || shell_protocol_error || ledger_protocol_error)
      $fatal(1,"real consumer/fence release failed");
    phase=9;transaction("source_invalidate",INVALIDATE,0,1);
    if(peer_aw!=65 || peer_w!=4160 || peer_b!=65 || checkpoint_w!=4096 || norm_w!=64 ||
       active_owners || published_owners || !ledger_domain_drained || !adapter_pending_zero ||
       producer_completion_occupancy || action_completion_occupancy || accepted_events!=17 ||
       retired_responses!=17 || terminal_tasks!=5 || semantic_rejections!=3 || snapshot_sequence_high_water!=1)
      $fatal(1,"guarded LN final state events=%0d responses=%0d rejected=%0d typed=%0d",accepted_events,retired_responses,semantic_rejections,terminal_tasks);
    $display("FULL_CURRENT_LAYERNORM_GUARDED_SOURCE_PASS cycles=%0d prelude_AW=64 prelude_W=4096 prelude_B=64 source_AR=1 source_R=64 LN_AW=1 LN_W=64 LN_B=1 gold_elements=1024 LPC1_verified_consumer_tail2_tail1=1 completion_to_END=1 short_window_rejected=1 typed5_once=1 LAC1_controlled_consumer_tail2_tail1=1 source_mutation_rejected=2 all_writer_single_monitor=1 no_executor_program=1",cycles);
    $finish;
  end
endmodule
