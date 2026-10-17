`timescale 1ns/1ps
module laya_ffn0_source_stage_host_v1 (
  input logic clk,rst_n,
  input logic source_query_valid,
  input logic source_query_ready,source_query_granted,
  input logic [8191:0] source_query_command,
  input logic source_release_valid,
  input logic source_release_ready,
  input logic [8191:0] source_release_command,
  input logic source_release_drained,
  input logic source_lease_active,
  output logic ln_published,ln_owner_released,
  input logic [63:0] shared_read_addr,
  output logic [511:0] shared_read_data,
  output logic [63:0] shared_read_written,
  input logic skip_arvalid,
  output logic skip_arready,
  input logic [63:0] skip_araddr,
  input logic [7:0] skip_arlen,
  input logic [2:0] skip_arsize,
  output logic skip_rvalid,
  input logic skip_rready,
  output logic [511:0] skip_rdata,
  output logic [1:0] skip_rresp,
  output logic skip_rlast,
  input logic [31:0] accepted_events,
  input logic [31:0] accepted_requests,
  input logic [5:0] active_owners,
  input logic  adapter_pending_zero,
  input logic  base_configured,
  input logic [63:0] destination_axi_awaddr,
  input logic [1:0] destination_axi_awburst,
  input logic [7:0] destination_axi_awlen,
  output logic  destination_axi_awready,
  input logic [2:0] destination_axi_awsize,
  input logic  destination_axi_awvalid,
  input logic  destination_axi_bready,
  output logic [1:0] destination_axi_bresp,
  output logic  destination_axi_bvalid,
  input logic [511:0] destination_axi_wdata,
  input logic  destination_axi_wlast,
  output logic  destination_axi_wready,
  input logic [63:0] destination_axi_wstrb,
  input logic  destination_axi_wvalid,
  input logic [31:0] forwarded_aw,
  input logic [31:0] forwarded_w,
  input logic  job_active,
  input logic [63:0] last_event_seq,
  input logic  ledger_domain_drained,
  input logic  ledger_protocol_error,
  input logic  ledger_scope_active,
  input logic  monitor_coverage_complete,
  input logic  monitor_drained,
  input logic [63:0] monitor_observed0,
  input logic  monitor_scope_active,
  input logic [15:0] monitor_status,
  input logic [511:0] producer_completion_din,
  output logic  producer_completion_full_n,
  input logic  producer_completion_write,
  output logic [511:0] producer_request_dout,
  output logic  producer_request_empty_n,
  input logic  producer_request_read,
  output logic [511:0] provenance_cmd_din,
  input logic  provenance_cmd_full_n,
  output logic  provenance_cmd_write,
  input logic [511:0] provenance_rsp_dout,
  input logic  provenance_rsp_empty_n,
  output logic  provenance_rsp_read,
  input logic [5:0] published_owners,
  input logic [31:0] retired_b,
  input logic [31:0] retired_responses,
  input logic [31:0] semantic_rejections,
  input logic  shell_protocol_error,
  input logic [63:0] source_axi_araddr,
  input logic [1:0] source_axi_arburst,
  input logic [7:0] source_axi_arlen,
  output logic  source_axi_arready,
  input logic [2:0] source_axi_arsize,
  input logic  source_axi_arvalid,
  output logic [511:0] source_axi_rdata,
  output logic  source_axi_rlast,
  input logic  source_axi_rready,
  output logic [1:0] source_axi_rresp,
  output logic  source_axi_rvalid,
  input logic [31:0] source_outstanding_beats,
  input logic [31:0] terminal_tasks
);
  import laya_generated_provenance_layout_v1::*;
  logic cancel=0;
  logic [63:0] monitored_bo_base=64'h0000000300000000;
  localparam logic [63:0] DESTINATION_FIRST=64'h0000000300800000;


  // LN shell is the hardware top's ln_shell instance.

  string fixture;
  logic [511:0] packet_beats[0:15],producer_beats[0:15];
  logic [8191:0] provenance_packet,query_packet;
  logic [4095:0] provenance_response,completion_packet;
  logic [31:0] source_mem[0:16383],gold_mem[0:16383];
  logic [31:0] destination_mem[0:16383];
  bit destination_written[0:16383];
  integer cycles=0,phase=0,target_rows=4;
  integer producer_index=0,completion_index=0;
  integer source_ar_count=0,source_r_count=0;
  integer source_read_index=0,source_read_left=0,source_delay=0;
  integer skip_read_index=0,skip_ar_count=0,skip_r_count=0;
  logic skip_read_pending=0;
  integer destination_aw_count=0,destination_w_count=0;
  integer destination_word_index=0,destination_write_left=0;
  integer destination_b_delay=0,destination_b_count=0;
  integer destination_store_bytes=0;
  logic source_read_active=0,destination_write_active=0;
  logic producer_loaded=0,completion_seen=0,end_sent=0;
  logic [511:0] completion_hold;
  // END-time evidence is transient: the monitor drops coverage_complete
  // when its physical scope closes. Keep the actual sampled packet/key and
  // counters for the post-PUBLISH checker; this is observation-only TB state.
  logic coverage_witness_valid=0,coverage_witness_complete=0;
  logic coverage_witness_scope_active=0,coverage_witness_drained=0;
  logic [15:0] coverage_witness_status=0;
  logic [63:0] coverage_witness_bytes=0;
  logic [8191:0] coverage_witness_packet=0;
  integer coverage_witness_cycle=-1;
  integer coverage_witness_source_ar=0,coverage_witness_source_r=0;
  integer coverage_witness_destination_aw=0,coverage_witness_destination_w=0;
  integer coverage_witness_destination_b=0,coverage_witness_store_bytes=0;
  logic end_response_witness_valid=0,publish_response_witness_valid=0;
  logic [4095:0] end_response_witness=0,publish_response_witness=0;
  integer end_response_witness_cycle=-1,publish_response_witness_cycle=-1;
  always @(negedge rst_n)begin
    coverage_witness_valid=0;
    end_response_witness_valid=0;
    publish_response_witness_valid=0;
  end
  integer observed_real_row=-1;
  integer observed_pass0_bucket=-1,observed_pass1_bucket=-1;
  integer semantic_progress_count=0;
  always @(posedge clk)begin
    if(rst_n && job_active &&
       $root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.local_row_fu_222<=4 &&
       int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.local_row_fu_222)!=
         observed_real_row)begin
      observed_real_row=int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.local_row_fu_222);
      observed_pass0_bucket=-1;observed_pass1_bucket=-1;
      semantic_progress_count++;
      $display("MATRIX_PROGRESS cycle=%0d LN_generated_row_cursor=%0d",
               cycles,observed_real_row);
    end
    if(rst_n && job_active &&
       $root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
         grp_layernorm_row_arithmetic_fu_1698.ap_idle==0)begin
      if($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_fu_108>=128 &&
         $root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_fu_108[6:0]==0 &&
         observed_pass0_bucket!=int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_fu_108[10:7]))begin
        observed_pass0_bucket=int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
          grp_layernorm_row_arithmetic_fu_1698.i_fu_108[10:7]);
        semantic_progress_count++;
        $display("MATRIX_PROGRESS cycle=%0d LN_row=%0d arithmetic_pass0_cursor=%0d",
          cycles,observed_real_row,observed_pass0_bucket*128);
      end
      if($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_2_fu_124>=128 &&
         $root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_2_fu_124[6:0]==0 &&
         observed_pass1_bucket!=int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
           grp_layernorm_row_arithmetic_fu_1698.i_2_fu_124[10:7]))begin
        observed_pass1_bucket=int'($root.m005_ffn_top_tb_v1.top.ln_shell.engine.grp_p_anonymous_namespace_run_fu_741.
          grp_layernorm_row_arithmetic_fu_1698.i_2_fu_124[10:7]);
        semantic_progress_count++;
        $display("MATRIX_PROGRESS cycle=%0d LN_row=%0d arithmetic_pass1_cursor=%0d",
          cycles,observed_real_row,observed_pass1_bucket*128);
      end
    end
  end

  // This read port observes the exact array modified by accepted LN AXI W.
  // No second NORM image or fixture refill exists on the Q side.
  always_comb begin
    shared_read_data='x;shared_read_written=0;
    if(shared_read_addr>=DESTINATION_FIRST &&
       shared_read_addr+64<=DESTINATION_FIRST+64'(target_rows)*4096)begin
      for(int lane=0;lane<16;lane++)begin
        shared_read_data[lane*32+:32]=
          destination_mem[int'((shared_read_addr-DESTINATION_FIRST)>>2)+lane];
        for(int octet=0;octet<4;octet++)
          shared_read_written[lane*4+octet]=
            destination_written[int'((shared_read_addr-DESTINATION_FIRST)>>2)+lane];
      end
    end
  end

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
    skip_arready=rst_n && !skip_read_pending && !skip_rvalid;
    if(skip_read_pending && !skip_rvalid)begin
      for(int lane=0;lane<16;lane++)
        skip_rdata[lane*32+:32]=source_mem[skip_read_index*16+lane];
      skip_rvalid=1;
      skip_rresp=0;
      skip_rlast=1;
    end
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
      skip_read_pending=0;skip_rvalid<=0;skip_read_index=0;
      skip_ar_count=0;skip_r_count=0;
      source_read_active=0;source_axi_rvalid=0;source_read_index=0;
      source_read_left=0;source_delay=0;source_ar_count=0;source_r_count=0;
      destination_write_active=0;destination_axi_bvalid=0;
      destination_word_index=0;destination_write_left=0;
      destination_b_delay=0;destination_aw_count=0;destination_w_count=0;
      destination_b_count=0;destination_store_bytes=0;
    end else begin
      if(skip_arvalid && skip_arready)begin
        if(skip_read_pending || skip_arlen!=0 || skip_arsize!=6 ||
           skip_araddr<monitored_bo_base ||
           skip_araddr+64<skip_araddr ||
           skip_araddr+64>monitored_bo_base+64'(target_rows)*4096 ||
           skip_araddr[5:0]!=0)
          $fatal(1,"FFN0 skip AR address/length addr=%h len=%0d size=%0d",
                 skip_araddr,skip_arlen,skip_arsize);
        skip_read_pending=1;
        skip_read_index=int'((skip_araddr-monitored_bo_base)>>6);
        skip_ar_count++;
      end
      if(skip_rvalid && skip_rready)begin
        if(!skip_read_pending || !skip_rlast || skip_rresp!=0)
          $fatal(1,"FFN0 skip R without matching AR");
        skip_rvalid<=0;
        skip_read_pending=0;
        skip_r_count++;
      end
      if(source_axi_arvalid && source_axi_arready)begin
        if(source_read_active || source_axi_arsize!=6 ||
           source_axi_arburst!=1 || source_axi_arlen!=63 ||
           source_axi_araddr<monitored_bo_base ||
           source_axi_araddr+4096>monitored_bo_base+64'(target_rows)*4096 ||
           (source_axi_araddr-monitored_bo_base)%4096!=0)
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
           destination_axi_awaddr+4096>DESTINATION_FIRST+64'(target_rows)*4096 ||
           (destination_axi_awaddr-DESTINATION_FIRST)%4096!=0 ||
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
        for(int lane=0;lane<16;lane++)begin
          if(destination_written[destination_word_index+lane])
            $fatal(1,"duplicate LN destination word=%0d",destination_word_index+lane);
          destination_mem[destination_word_index+lane]=
            destination_axi_wdata[lane*32+:32];
          destination_written[destination_word_index+lane]=1;
        end
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
    ln_published=0;ln_owner_released=0;
    coverage_witness_valid=0;
    end_response_witness_valid=0;publish_response_witness_valid=0;
    provenance_cmd_din=0;provenance_cmd_write=0;provenance_rsp_read=0;
    source_axi_arready=0;source_axi_rdata=0;source_axi_rresp=0;
    source_axi_rlast=0;source_axi_rvalid=0;
    skip_arready=0;skip_rvalid=0;skip_rdata=0;skip_rresp=0;skip_rlast=0;
    destination_axi_awready=0;destination_axi_wready=0;
    destination_axi_bresp=0;destination_axi_bvalid=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"LayerNorm producer portal fixture path");
    if($value$plusargs("ROWS=%d",target_rows) &&
       target_rows!=4)$fatal(1,"LNQ0 requires four source rows");
    $readmemh({fixture,"/producer_request.hex"},producer_beats);
    $readmemh({fixture,"/source.mem"},source_mem);
    // The frozen four-row fixture contains 4096 F32 words. Keep the rest of
    // the declared 64 KiB source window immutable and explicit for the scan.
    for(int i=4096;i<16384;i++)source_mem[i]=32'ha5a5a5a5;
    $readmemh({fixture,"/gold.mem"},gold_mem);
    for(int i=0;i<16384;i++)begin
      destination_mem[i]=32'ha5a5a5a5;destination_written[i]=0;
    end
    producer_loaded=1;
    wait(rst_n);repeat(4)tick();
    while(!base_configured)tick();repeat(4)tick();
    if(adapter_pending_zero!==1 || producer_index!=0 || shell_protocol_error)
      $fatal(1,"base initialization/fence failed");
    $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS base_configured cycles=%0d",cycles);

    // This shell runs one task after the initial reset. New CLAIM starts
    // with no evidence inherited from a prior task or reset.
    coverage_witness_valid=0;
    end_response_witness_valid=0;publish_response_witness_valid=0;
    phase=1;transact("claim",CLAIM,8'h01);
    phase=2;transact("begin",BEGIN_EVENT,8'h03);
    $display("FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_PROGRESS begin_response_complete cycles=%0d",cycles);
    while(producer_index<16)tick();
    while(!job_active && !shell_protocol_error)tick();
    if(!job_active || !monitor_scope_active || adapter_pending_zero)
      $fatal(1,"producer did not enter bound active scope");

    phase=3;
    // The original completion is produced by the generated LN engine. END
    // carries its real status, coverage, and consumed byte count.
    while(!completion_seen)tick();
    load_packet("end",provenance_packet);
    provenance_packet[REPORTED_STATUS*8+:16]=completion_packet[10*8+:16];
    provenance_packet[REPORTED_UNIT*8+:8]=completion_packet[12*8+:8];
    provenance_packet[REPORTED_ELEMENTS*8+:32]=completion_packet[36*8+:32];
    provenance_packet[REPORTED_DETAIL*8+:32]=completion_packet[32*8+:32];
    provenance_packet[REPORTED_BAD*8+:64]=completion_packet[40*8+:64];
    provenance_packet[ISSUED0*8+:64]=completion_packet[48*8+:64];
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);provenance_cmd_din=provenance_packet[beat*512+:512];
      provenance_cmd_write=1;
      do begin @(posedge clk);end while(!provenance_cmd_full_n);
      #1;@(negedge clk);provenance_cmd_write=0;
    end
    end_sent=1;
    if(!monitor_coverage_complete)
      $fatal(1,"monitor did not close real WSTRB coverage before END response");
    coverage_witness_valid=1;
    coverage_witness_complete=monitor_coverage_complete;
    coverage_witness_scope_active=monitor_scope_active;
    coverage_witness_drained=monitor_drained;
    coverage_witness_status=monitor_status;
    coverage_witness_bytes=monitor_observed0;
    coverage_witness_packet=provenance_packet;
    coverage_witness_cycle=cycles;
    coverage_witness_source_ar=source_ar_count;
    coverage_witness_source_r=source_r_count;
    coverage_witness_destination_aw=destination_aw_count;
    coverage_witness_destination_w=destination_w_count;
    coverage_witness_destination_b=destination_b_count;
    coverage_witness_store_bytes=destination_store_bytes;
    $display("LNQ1_WITNESS_END_SAMPLE cycle=%0d scope=%0d coverage=%0d drained=%0d status=%0d bytes=%0d source=%0d/%0d destination=%0d/%0d/%0d store_bytes=%0d task=%0d context=%h descriptor=%h geometry=%h",
      coverage_witness_cycle,coverage_witness_scope_active,
      coverage_witness_complete,coverage_witness_drained,
      coverage_witness_status,coverage_witness_bytes,
      coverage_witness_source_ar,coverage_witness_source_r,
      coverage_witness_destination_aw,coverage_witness_destination_w,
      coverage_witness_destination_b,coverage_witness_store_bytes,
      coverage_witness_packet[TASK*8+:64],
      coverage_witness_packet[CONTEXT*8+:96],
      coverage_witness_packet[DESCRIPTOR0*8+:1024],
      coverage_witness_packet[GEOMETRY0*8+:512]);
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
    end_response_witness=provenance_response;
    end_response_witness_valid=1;
    end_response_witness_cycle=cycles;
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
      if(!destination_written[i] || destination_mem[i]!==gold_mem[i])
        $fatal(1,"LayerNorm gold mismatch element=%0d got=%h expected=%h",
               i,destination_mem[i],gold_mem[i]);
    for(int i=target_rows*1024;i<16384;i++)
      if(destination_written[i] || destination_mem[i]!==32'ha5a5a5a5)
        $fatal(1,"LN NORM guard changed word=%0d",i);

    phase=4;transact("publish",PUBLISH,8'h05);
    publish_response_witness=provenance_response;
    publish_response_witness_valid=1;
    publish_response_witness_cycle=cycles;
    ln_published=1;
    $display("MATRIX_PROGRESS cycle=%0d LN_publish=1 last_B=%0d",cycles,destination_b_count);
    wait(source_lease_active);
    wait(!source_lease_active);
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
    ln_owner_released=1;
    $display("LNQ0_LN_SOURCE_PASS rows=%0d D=1024 source_AR=%0d source_R=%0d destination_AW=%0d destination_W=%0d destination_B=%0d store_bytes=%0d completion_beats=%0d gold_elements=%0d source_query_granted=1 source_lease_released=1 cycles=%0d",
      target_rows,source_ar_count,source_r_count,destination_aw_count,destination_w_count,
      destination_b_count,destination_store_bytes,completion_index,target_rows*1024,cycles);
  end
endmodule
