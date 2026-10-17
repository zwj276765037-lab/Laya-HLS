`timescale 1ns/1ps
module laya_layernorm_ffn_quant_source_tb_v1;
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

  logic q_source_lease_active;
  logic q_service_command_valid;
  logic q_service_command_ready;
  logic [8191:0] service_command;
  logic q_service_completion_valid;
  logic q_service_completion_ready;
  logic [4095:0] q_service_completion;
  logic [12:0][63:0] latched_bo_base;
  logic [12:0][63:0] latched_bo_span;
  logic q_physical_debt_zero;
  logic q_persistent_active;
  logic [63:0] quant_axi_araddr;
  logic [7:0] quant_axi_arlen;
  logic [2:0] quant_axi_arsize;
  logic [1:0] quant_axi_arburst;
  logic quant_axi_arvalid;
  logic quant_axi_arready;
  logic [511:0] quant_axi_rdata;
  logic [1:0] quant_axi_rresp;
  logic quant_axi_rlast;
  logic quant_axi_rvalid;
  logic quant_axi_rready;
  logic a_acquire_valid;
  logic a_acquire_ready;
  logic a_acquire_done;
  logic a_acquire_error;
  logic a_acquire_slot;
  logic [31:0] a_acquire_slot_epoch;
  logic [12:0] a_acquire_K;
  logic [4:0] a_acquire_rows;
  logic [671:0] a_acquire_numeric_identity;
  logic [95:0] a_acquire_linear_context;
  logic [63:0] a_acquire_a_ref;
  logic [63:0] a_acquire_w_ref;
  logic [63:0] a_acquire_dst_ref;
  logic a_read_valid;
  logic a_read_ready;
  logic a_read_error;
  logic a_read_slot;
  logic [31:0] a_read_slot_epoch;
  logic [671:0] a_read_numeric_identity;
  logic [95:0] a_read_linear_context;
  logic [63:0] a_read_a_ref;
  logic [3:0] a_read_row_block_base;
  logic [2:0] a_read_rows;
  logic [6:0] a_read_group;
  logic a_ret_valid;
  logic a_ret_ready;
  logic a_ret_slot;
  logic [31:0] a_ret_slot_epoch;
  logic [671:0] a_ret_numeric_identity;
  logic [95:0] a_ret_linear_context;
  logic [63:0] a_ret_a_ref;
  logic [3:0] a_ret_row_block_base;
  logic [2:0] a_ret_rows;
  logic [6:0] a_ret_group;
  logic [3:0][255:0] a_ret_q;
  logic [3:0][15:0] a_ret_scale;
  logic a_release_valid;
  logic a_release_ready;
  logic a_release_done;
  logic a_release_error;
  logic a_release_slot;
  logic [31:0] a_release_slot_epoch;
  logic [671:0] a_release_numeric_identity;
  logic [95:0] a_release_linear_context;
  logic [63:0] a_release_a_ref;
  logic a_read_debt_zero;
  logic [1:0][2:0] a_slot_state;
  logic [1:0][31:0] a_slot_epoch;
  logic [1:0][15:0] a_slot_rows_done;
  logic [31:0] quant_outstanding_beats;
  logic quant_protocol_error;
  laya_layernorm_quant_source_shell_v1 dut(.*);

  string fixture;
  logic [511:0] packet_beats[0:15],producer_beats[0:15];
  logic [8191:0] provenance_packet,query_packet;
  logic [4095:0] provenance_response,completion_packet;
  logic [31:0] source_mem[0:16383],gold_mem[0:16383];
  logic [31:0] destination_mem[0:16383];
  bit destination_written[0:16383];
  logic [7:0] q_gold[0:16383];logic [15:0] scale_gold[0:511];
  logic [8191:0] producer_packet;
  integer quant_ar_count=0,quant_r_count=0,quant_read_index=0;
  integer quant_read_left=0,quant_delay=0,a_groups_checked=0;
  logic quant_read_active=0;
  integer cycles=0,phase=0,target_rows=4,reject_case=0;
  logic [511:0] injected_completion;
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

  // Observation only: all counters sample the same accepting posedge.  The
  // original driver, memory response schedule and gold checks are unchanged.
  integer m_cycle=0;
  integer m_phase[0:5];
  integer m_source_ar=0,m_source_r=0,m_destination_aw=0,m_destination_w=0,m_destination_b=0;
  integer m_quant_ar=0,m_quant_r=0,m_math_start=0,m_math_done=0;
  integer m_source_ar_first=-1,m_source_ar_last=-1,m_source_r_first=-1,m_source_r_last=-1;
  integer m_destination_aw_first=-1,m_destination_aw_last=-1;
  integer m_destination_w_first=-1,m_destination_w_last=-1;
  integer m_destination_b_first=-1,m_destination_b_last=-1;
  integer m_quant_ar_first=-1,m_quant_ar_last=-1,m_quant_r_first=-1,m_quant_r_last=-1;
  integer m_math_first=-1,m_math_last=-1,m_math_done_first=-1,m_math_done_last=-1;
  integer m_request_first=-1,m_request_last=-1,m_completion_first=-1,m_completion_last=-1;
  integer m_q_accept=-1,m_q_valid=-1,m_q_consume=-1,m_lease_on=-1,m_lease_off=-1;
  integer m_end_consume=-1,m_publish_consume=-1,m_fulla_acquire=-1;
  integer m_fulla_last_check=-1,m_fulla_release=-1,m_zero_debt=-1;
  integer m_source_ar_wait=0,m_source_r_wait=0,m_destination_aw_wait=0;
  integer m_destination_w_wait=0,m_destination_b_wait=0,m_quant_ar_wait=0,m_quant_r_wait=0;
  logic m_math_start_prev=0,m_math_done_prev=0,m_q_valid_seen=0,m_lease_prev=0;
  initial for(integer i=0;i<6;i=i+1)m_phase[i]=0;
  always @(posedge clk)begin
    m_cycle=m_cycle+1;
    if(phase>=0 && phase<=5)m_phase[phase]=m_phase[phase]+1;
    if(rst_n)begin
      if(producer_request_read && producer_request_empty_n)begin
        if(m_request_first<0)m_request_first=m_cycle;
        m_request_last=m_cycle;
      end
      if(producer_completion_write && producer_completion_full_n)begin
        if(m_completion_first<0)m_completion_first=m_cycle;
        m_completion_last=m_cycle;
      end
      if(source_axi_arvalid && source_axi_arready)begin
        if(m_source_ar_first<0)m_source_ar_first=m_cycle;
        m_source_ar_last=m_cycle;m_source_ar=m_source_ar+1;
      end
      if(source_axi_rvalid && source_axi_rready)begin
        if(m_source_r_first<0)m_source_r_first=m_cycle;
        m_source_r_last=m_cycle;m_source_r=m_source_r+1;
      end
      if(destination_axi_awvalid && destination_axi_awready)begin
        if(m_destination_aw_first<0)m_destination_aw_first=m_cycle;
        m_destination_aw_last=m_cycle;m_destination_aw=m_destination_aw+1;
      end
      if(destination_axi_wvalid && destination_axi_wready)begin
        if(m_destination_w_first<0)m_destination_w_first=m_cycle;
        m_destination_w_last=m_cycle;m_destination_w=m_destination_w+1;
      end
      if(destination_axi_bvalid && destination_axi_bready)begin
        if(m_destination_b_first<0)m_destination_b_first=m_cycle;
        m_destination_b_last=m_cycle;m_destination_b=m_destination_b+1;
      end
      if(destination_b_count<target_rows &&
         (published_owners!=0 || q_service_command_ready && q_service_command_valid))
        $fatal(1,"publication or Q admission preceded final B");
      if(quant_axi_arvalid && quant_axi_arready)begin
        if(m_quant_ar_first<0)m_quant_ar_first=m_cycle;
        m_quant_ar_last=m_cycle;m_quant_ar=m_quant_ar+1;
      end
      if(quant_axi_rvalid && quant_axi_rready)begin
        if(m_quant_r_first<0)m_quant_r_first=m_cycle;
        m_quant_r_last=m_cycle;m_quant_r=m_quant_r+1;
      end
      // This named generated subgraph is only an arithmetic envelope.  Its
      // duration may include internal memory and pipeline waits.
      if(dut.producer.engine.grp_p_anonymous_namespace_run_fu_741_ap_start && !m_math_start_prev)begin
        if(m_math_first<0)m_math_first=m_cycle;
        m_math_last=m_cycle;m_math_start=m_math_start+1;
      end
      if(dut.producer.engine.grp_p_anonymous_namespace_run_fu_741_ap_done &&
         !m_math_done_prev && m_math_start>m_math_done)begin
        if(m_math_done_first<0)m_math_done_first=m_cycle;
        m_math_done_last=m_cycle;m_math_done=m_math_done+1;
      end
      m_math_start_prev=dut.producer.engine.grp_p_anonymous_namespace_run_fu_741_ap_start;
      m_math_done_prev=dut.producer.engine.grp_p_anonymous_namespace_run_fu_741_ap_done;
      if(q_service_command_valid && q_service_command_ready && m_q_accept<0)m_q_accept=m_cycle;
      if(q_service_completion_valid && !m_q_valid_seen)begin m_q_valid=m_cycle;m_q_valid_seen=1;end
      if(q_service_completion_valid && q_service_completion_ready)m_q_consume=m_cycle;
      if(source_lease_active && !m_lease_prev)m_lease_on=m_cycle;
      if(!source_lease_active && m_lease_prev)m_lease_off=m_cycle;
      m_lease_prev=source_lease_active;
      if(source_axi_arvalid && !source_axi_arready)m_source_ar_wait=m_source_ar_wait+1;
      if(source_axi_rvalid && !source_axi_rready)m_source_r_wait=m_source_r_wait+1;
      if(destination_axi_awvalid && !destination_axi_awready)m_destination_aw_wait=m_destination_aw_wait+1;
      if(destination_axi_wvalid && !destination_axi_wready)m_destination_w_wait=m_destination_w_wait+1;
      if(destination_axi_bvalid && !destination_axi_bready)m_destination_b_wait=m_destination_b_wait+1;
      if(quant_axi_arvalid && !quant_axi_arready)m_quant_ar_wait=m_quant_ar_wait+1;
      if(quant_axi_rvalid && !quant_axi_rready)m_quant_r_wait=m_quant_r_wait+1;
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
            $fatal(1,"duplicate destination byte word=%0d",destination_word_index+lane);
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

  task automatic send_q;
    while(!q_service_command_ready)tick();
    @(negedge clk);q_service_command_valid=1;tick();@(negedge clk);q_service_command_valid=0;
  endtask

  task automatic acquire_a;
    a_acquire_slot=0;a_acquire_slot_epoch=1;a_acquire_K=1024;a_acquire_rows=5'(target_rows);
    a_acquire_numeric_identity=service_command[laya_compute_portal_layout_v1::IDENTITY*8+:672];
    a_acquire_linear_context=service_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
    a_acquire_a_ref=service_command[laya_compute_portal_layout_v1::A_REF*8+:64];a_acquire_w_ref=service_command[laya_compute_portal_layout_v1::W_REF*8+:64];
    a_acquire_dst_ref=service_command[laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64];a_acquire_valid=1;
    while(!a_acquire_ready)tick();tick();
    if(!a_acquire_done || a_acquire_error)$fatal(1,"ordinary Q A acquire");
    @(negedge clk);a_acquire_valid=0;
  endtask
  task automatic check_group(input int row_block,input int group);
    logic [3:0][255:0] expected;
    for(int row=0;row<4;row++)
      for(int lane=0;lane<32;lane++)
        expected[row][lane*8+:8]=q_gold[(row_block+row)*1024+group*32+lane];
    @(negedge clk);a_read_slot=0;a_read_slot_epoch=1;
    a_read_numeric_identity=service_command[laya_compute_portal_layout_v1::IDENTITY*8+:672];
    a_read_linear_context=service_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
    a_read_a_ref=service_command[laya_compute_portal_layout_v1::A_REF*8+:64];a_read_row_block_base=4'(row_block);
    a_read_rows=4;a_read_group=7'(group);a_read_valid=1;
    while(!a_read_ready)tick();tick();if(a_read_error)$fatal(1,"ordinary Q A read admission");
    @(negedge clk);a_read_valid=0;while(!a_ret_valid)tick();
    if(a_ret_group!=group || a_ret_rows!=4 ||
       a_ret_row_block_base!=row_block)
      $fatal(1,"source lease Q A metadata row_block=%0d group=%0d",row_block,group);
    for(int row=0;row<4;row++)
      if(a_ret_q[row]!==expected[row] ||
         a_ret_scale[row]!==scale_gold[(row_block+row)*32+group])
        $fatal(1,"source lease Q A payload row=%0d group=%0d",row_block+row,group);
    @(negedge clk);a_ret_ready=1;tick();@(negedge clk);a_ret_ready=0;a_groups_checked=a_groups_checked+1;
  endtask
  task automatic release_a;
    a_release_slot=0;a_release_slot_epoch=1;
    a_release_numeric_identity=service_command[laya_compute_portal_layout_v1::IDENTITY*8+:672];
    a_release_linear_context=service_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
    a_release_a_ref=service_command[laya_compute_portal_layout_v1::A_REF*8+:64];a_release_valid=1;
    while(!a_release_ready)tick();tick();
    if(!a_release_done || a_release_error || !a_read_debt_zero)$fatal(1,"ordinary Q A release");
    @(negedge clk);a_release_valid=0;
  endtask


  // The Q reader sees only words actually accepted from the producer W stream.
  always @(negedge clk)begin
    quant_axi_arready=rst_n && !quant_read_active && !quant_axi_rvalid && cycles%5!=0;
    if(quant_read_active && !quant_axi_rvalid)begin
      if(quant_delay>0)quant_delay=quant_delay-1;
      else begin
        quant_axi_rvalid=1;quant_axi_rresp=0;quant_axi_rlast=quant_read_left==1;
        for(int lane=0;lane<16;lane++)begin
          if(!destination_written[quant_read_index*16+lane])
            $fatal(1,"QUANT read before actual producer store row=%0d",quant_read_index/64);
          quant_axi_rdata[lane*32+:32]=destination_mem[quant_read_index*16+lane];
        end
      end
    end
  end
  always @(posedge clk)begin
    if(!rst_n)begin
      quant_read_active=0;quant_axi_rvalid=0;quant_read_index=0;
      quant_read_left=0;quant_delay=0;quant_ar_count=0;quant_r_count=0;
    end else begin
      if(quant_axi_arvalid && quant_axi_arready)begin
        if(!source_lease_active || !q_source_lease_active || quant_read_active ||
           quant_axi_arsize!=6 || quant_axi_arburst!=1 ||
           quant_axi_araddr<DESTINATION_FIRST ||
           quant_axi_araddr+64'(quant_axi_arlen+1)*64>DESTINATION_FIRST+64'(target_rows)*4096 ||
           quant_axi_araddr[11:0]+(int'(quant_axi_arlen)+1)*64>4096)
          $fatal(1,"QUANT actual source AR/lease addr=%h",quant_axi_araddr);
        quant_read_active=1;quant_read_index=int'((quant_axi_araddr-DESTINATION_FIRST)>>6);
        quant_read_left=int'(quant_axi_arlen)+1;quant_delay=1;
        quant_ar_count=quant_ar_count+1;
        $display("FULL_CURRENT_LAYERNORM_QUANT_PROGRESS quant_AR row=%0d cycles=%0d",quant_ar_count-1,cycles);
      end
      if(quant_axi_rvalid && quant_axi_rready)begin
        if(!source_lease_active || !q_source_lease_active)
          $fatal(1,"QUANT source lease released with read debt");
        quant_axi_rvalid<=0;quant_read_index=quant_read_index+1;
        quant_read_left=quant_read_left-1;quant_r_count=quant_r_count+1;
        quant_delay=1+(quant_r_count%3);
        if(quant_read_left==0)quant_read_active=0;
      end
    end
  end

  initial begin
    provenance_cmd_din=0;provenance_cmd_write=0;provenance_rsp_read=0;
    q_service_command_valid=0;q_service_completion_ready=0;service_command=0;
    latched_bo_base=0;latched_bo_span=0;
    latched_bo_base[6]=monitored_bo_base;latched_bo_span[6]=16920576;
    quant_axi_arready=0;quant_axi_rdata=0;quant_axi_rresp=0;
    quant_axi_rlast=0;quant_axi_rvalid=0;
    a_acquire_valid=0;a_acquire_slot=0;a_acquire_slot_epoch=0;a_acquire_K=0;a_acquire_rows=0;
    a_acquire_numeric_identity=0;a_acquire_linear_context=0;a_acquire_a_ref=0;a_acquire_w_ref=0;a_acquire_dst_ref=0;
    a_read_valid=0;a_read_slot=0;a_read_slot_epoch=0;a_read_numeric_identity=0;
    a_read_linear_context=0;a_read_a_ref=0;a_read_row_block_base=0;a_read_rows=0;a_read_group=0;a_ret_ready=0;
    a_release_valid=0;a_release_slot=0;a_release_slot_epoch=0;
    a_release_numeric_identity=0;a_release_linear_context=0;a_release_a_ref=0;
    source_axi_arready=0;source_axi_rdata=0;source_axi_rresp=0;
    source_axi_rlast=0;source_axi_rvalid=0;
    destination_axi_awready=0;destination_axi_wready=0;
    destination_axi_bresp=0;destination_axi_bvalid=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"LayerNorm producer portal fixture path");
    if($value$plusargs("ROWS=%d",target_rows) &&
       target_rows!=1 && target_rows!=4)$fatal(1,"unsupported test rows");
    $readmemh({fixture,"/producer_request.hex"},producer_beats);
    $readmemh({fixture,"/source.mem"},source_mem);
    $readmemh({fixture,"/gold.mem"},gold_mem);
    $readmemh({fixture,"/q.mem"},q_gold);$readmemh({fixture,"/scale.mem"},scale_gold);
    for(int beat=0;beat<16;beat++)producer_packet[beat*512+:512]=producer_beats[beat];
    void'($value$plusargs("REJECT_CASE=%d",reject_case));
    case(reject_case)
      1:producer_packet[148*8+:32]=12; // same origin, another legal task
      2:producer_packet[64*8+:64]=2101;
      3:producer_packet[72*8+:64]=74;
      4:producer_packet[584*8+:32]=10; // same physical destination, wrong epoch
      default:;
    endcase
    for(int beat=0;beat<16;beat++)producer_beats[beat]=producer_packet[beat*512+:512];
    for(int i=0;i<16384;i++)begin
      destination_mem[i]=32'ha5a5a5a5;
      destination_written[i]=0;
    end
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
    if(reject_case>=1 && reject_case<=4)begin
      repeat(30)tick();
      if(!shell_protocol_error || job_active || !ledger_scope_active ||
         !monitor_scope_active || adapter_pending_zero || monitor_coverage_complete ||
         source_ar_count!=0 || destination_aw_count!=0 || destination_w_count!=0 ||
         published_owners!=0 || terminal_tasks!=0 || completion_index!=0 ||
         dut.producer.request_packet!==producer_packet ||
         dut.producer.accepted_begin_packet[148*8+:32]!=11)
        $fatal(1,"F9 request mismatch was not isolated before real AXI case=%0d",reject_case);
      $display("FULL_CURRENT_LAYERNORM_QUANT_F9_REJECT_PASS case=%0d source_AR=0 destination_AW=0 destination_W=0 scope_retained=1 published=0",reject_case);
      $finish;
    end
    while(!job_active && !shell_protocol_error)tick();
    if(!job_active || !monitor_scope_active || adapter_pending_zero)
      $fatal(1,"producer did not enter bound active scope");

    phase=3;
    if(reject_case==5 || reject_case==6)begin
      // Corrupt the actual generated return at its boundary, retaining all
      // real producer traffic. No substituted completion reaches the caller.
      wait(dut.producer.engine_completion_write && dut.producer.engine_completion_full_n);
      @(negedge clk);
      injected_completion=dut.producer.engine_completion_din;
      if(reject_case==5)injected_completion[16*8+:64]=40;
      else injected_completion[24*8+:64]=300;
      force dut.producer.engine_completion_din=injected_completion;
      @(posedge clk);#1;@(negedge clk);
      release dut.producer.engine_completion_din;
      while(!dut.producer.completion_loaded)tick();
      repeat(20)tick();
      if(!shell_protocol_error || !job_active || adapter_pending_zero ||
         !ledger_scope_active || !monitor_scope_active || completion_index!=0 ||
         published_owners!=0 || terminal_tasks!=0 ||
         source_ar_count!=target_rows || destination_b_count!=target_rows ||
         dut.producer.request_packet!==producer_packet)
        $fatal(1,"F9 completion mismatch released old scope case=%0d",reject_case);
      $display("FULL_CURRENT_LAYERNORM_QUANT_F9_REJECT_PASS case=%0d real_producer_rows=%0d caller_completion=0 scope_retained=1 tracker_retained=1",reject_case,target_rows);
      $finish;
    end
    while(!completion_seen)tick();
    if(completion_packet[64*8+:84*8]!==producer_packet[64*8+:84*8] ||
       completion_packet[148*8+:12*8]!==producer_packet[148*8+:12*8] ||
       completion_packet[160*8+:16*8]!==producer_packet[576*8+:16*8] ||
       completion_packet[180*8+:16]!==producer_packet[592*8+:16] ||
       completion_packet[192*8+:32*8]!==producer_packet[608*8+:32*8])
      $fatal(1,"real producer completion lost full identity/Refs/geometry binding");
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
    m_end_consume=cycles;
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
        $fatal(1,"LN local destination guard overwritten element=%0d",i);
    if(m_destination_b_last-m_destination_w_last<7)
      $fatal(1,"final B was not delayed for at least seven cycles");

    phase=4;transact("publish",PUBLISH,8'h05);
    m_publish_consume=cycles;
    // Single-row pilot retains the producer workload; full runs the actual Q.
    if(target_rows==4)begin
    load_packet("source_query",service_command);send_q();
    while(!q_service_completion_valid)tick();
    if(!laya_compute_portal_layout_v1::response_binding_ok(q_service_completion,service_command) ||
       q_service_completion[laya_compute_portal_layout_v1::OP_STATUS*8+:16]!=0 ||
       q_service_completion[laya_compute_portal_layout_v1::ELEMENTS*8+:32]!=128 || q_service_completion[laya_compute_portal_layout_v1::UNIT*8+:8]!=2 ||
       q_service_completion[laya_compute_portal_layout_v1::COUNTERS*8+:32]!=4 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+4)*8+:32]!=256 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+8)*8+:32]!=4 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+12)*8+:32]!=4 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+16)*8+:32]!=256 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+20)*8+:32]!=4 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+24)*8+:32]!=256 ||
       q_service_completion[(laya_compute_portal_layout_v1::COUNTERS+28)*8+:32]!=128 ||
       quant_ar_count!=4 || quant_r_count!=256)
      $fatal(1,"source lease Q response/counters AR=%0d R=%0d state=%0d rows=%h",
        quant_ar_count,quant_r_count,a_slot_state[0],a_slot_rows_done[0]);
    if(dut.quant.gate_owner_state!=0 || dut.quant.split.q_gate_source || a_slot_state[0]!=2 ||
       a_slot_rows_done[0]!=16'h000f || !q_persistent_active ||
       !source_lease_active || !q_source_lease_active)
      $fatal(1,"source lease Q did not use direct shared quant/fullA path");
    repeat(5)begin
      tick();
      if(!q_service_completion_valid || !source_lease_active ||
         !q_source_lease_active || dut.source_release_valid)
        $fatal(1,"source lease Q response/lease not held");
    end
    @(negedge clk);q_service_completion_ready=1;tick();@(negedge clk);q_service_completion_ready=0;
    if(source_lease_active || q_source_lease_active)
      $fatal(1,"source lease Q did not release on response retirement");
    acquire_a();
    m_fulla_acquire=cycles;
    for(int row_block=0;row_block<4;row_block+=4)
      for(int group=0;group<32;group++)check_group(row_block,group);
    m_fulla_last_check=cycles;
    if(a_groups_checked!=32)$fatal(1,"source lease Q did not verify every fullA group");
    release_a();
    m_fulla_release=cycles;
      if(quant_outstanding_beats!=0 || quant_protocol_error)
        $fatal(1,"QUANT external read debt/protocol did not close");
    end
    phase=5;transact("release",RELEASE,8'h01);
    if(active_owners!=0 || published_owners!=0 ||
       accepted_requests!=5 || retired_responses!=5 ||
       accepted_events!=5 || semantic_rejections!=0 || terminal_tasks!=1 ||
       shell_protocol_error || ledger_protocol_error ||
       !ledger_domain_drained || !adapter_pending_zero || quant_protocol_error)
      $fatal(1,"final shell/ledger state owners=%0d/%0d req=%0d rsp=%0d events=%0d rejects=%0d terminal=%0d shell=%0d ledger=%0d drained=%0d adapter=%0d",
        active_owners,published_owners,accepted_requests,retired_responses,
        accepted_events,semantic_rejections,terminal_tasks,
        shell_protocol_error,ledger_protocol_error,ledger_domain_drained,
        adapter_pending_zero);
    for(int i=0;i<target_rows*1024;i++)
      if(!destination_written[i] || destination_mem[i]!==gold_mem[i])
        $fatal(1,"LN destination final readback changed element=%0d",i);
    for(int i=target_rows*1024;i<16384;i++)
      if(destination_written[i] || destination_mem[i]!==32'ha5a5a5a5)
        $fatal(1,"LN destination final guard changed element=%0d",i);
    m_zero_debt=cycles;
    if(m_cycle!=cycles || m_source_ar!=source_ar_count || m_source_r!=source_r_count ||
       m_destination_aw!=destination_aw_count || m_destination_w!=destination_w_count ||
       m_destination_b!=destination_b_count || m_quant_ar!=quant_ar_count ||
       m_quant_r!=quant_r_count)
      $fatal(1,"LQ0 observer changed or missed physical handshakes");
    if(m_math_start!=1 || m_math_done!=1 || m_math_done_last<=m_math_first ||
       m_end_consume<0 || m_publish_consume<0 || m_zero_debt<0 ||
       (target_rows==4 && (m_fulla_acquire<0 || m_fulla_last_check<0 ||
                           m_fulla_release<0 || m_q_consume<0 || m_lease_off<0)))
      $fatal(1,"LQ0 observer missed actual lifecycle or generated run edge");
    $display("LQ0_EVENT cycles=%0d phase0=%0d phase1=%0d phase2=%0d phase3=%0d phase4=%0d phase5=%0d request_first=%0d request_last=%0d completion_first=%0d completion_last=%0d q_accept=%0d q_valid=%0d q_consume=%0d lease_on=%0d lease_off=%0d",
      m_cycle,m_phase[0],m_phase[1],m_phase[2],m_phase[3],m_phase[4],m_phase[5],
      m_request_first,m_request_last,m_completion_first,m_completion_last,
      m_q_accept,m_q_valid,m_q_consume,m_lease_on,m_lease_off);
    $display("LQ0_AXI source_ar=%0d,%0d source_r=%0d,%0d destination_aw=%0d,%0d destination_w=%0d,%0d destination_b=%0d,%0d quant_ar=%0d,%0d quant_r=%0d,%0d math_start=%0d,%0d math_done=%0d,%0d math_count=%0d,%0d",
      m_source_ar_first,m_source_ar_last,m_source_r_first,m_source_r_last,
      m_destination_aw_first,m_destination_aw_last,m_destination_w_first,m_destination_w_last,
      m_destination_b_first,m_destination_b_last,m_quant_ar_first,m_quant_ar_last,
      m_quant_r_first,m_quant_r_last,m_math_first,m_math_last,
      m_math_done_first,m_math_done_last,m_math_start,m_math_done);
    $display("LQ0_WAIT source_ar=%0d source_r=%0d destination_aw=%0d destination_w=%0d destination_b=%0d quant_ar=%0d quant_r=%0d",
      m_source_ar_wait,m_source_r_wait,m_destination_aw_wait,m_destination_w_wait,
      m_destination_b_wait,m_quant_ar_wait,m_quant_r_wait);
    $display("LQ0_LIFECYCLE end_consume=%0d publish_consume=%0d fulla_acquire=%0d fulla_last_check=%0d fulla_release=%0d zero_debt=%0d",
      m_end_consume,m_publish_consume,m_fulla_acquire,m_fulla_last_check,
      m_fulla_release,m_zero_debt);
    $display("FULL_CURRENT_LAYERNORM_QUANT_SOURCE_PASS rows=%0d D=1024 source_AR=%0d source_R=%0d destination_AW=%0d destination_W=%0d destination_B=%0d store_bytes=%0d completion_beats=%0d gold_elements=%0d begin_gated=1 END_from_real_completion=1 source_query_granted=%0d source_lease_released=%0d quant_AR=%0d quant_R=%0d fullA_groups=%0d cycles=%0d",
      target_rows,source_ar_count,source_r_count,destination_aw_count,destination_w_count,
      destination_b_count,destination_store_bytes,completion_index,target_rows*1024,
      target_rows==4,target_rows==4,quant_ar_count,quant_r_count,a_groups_checked,cycles);
    $finish;
  end
endmodule
