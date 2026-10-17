`timescale 1ns/1ps
`default_nettype none
module geglu_gate_tensor_store_tb_v2;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic claim_valid,claim_ready,claim_admitted,claim_rejected,claim_plan_admitted;
  logic [671:0] claim_numeric_identity;
  logic [95:0] claim_producer_context,claim_quant_context,claim_linear_context;
  logic [63:0] claim_source_ref,claim_gate_ref,claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref;
  logic [7:0] claim_gate_region,claim_dst_region;
  logic [327:0] claim_output_binding;
  logic [63:0] claim_bo_base,claim_bo_span,claim_region_base,claim_region_span;
  logic row_success;
  logic [15:0] row_success_row;
  logic v_valid,v_ready;
  logic [31:0] v_data,v_status,v_frame_tag;
  logic [15:0] v_row;
  logic [12:0] v_col;
  logic v_last;
  logic row_write_done_valid,row_write_done_ready;
  logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch;
  logic [15:0] row_write_row;
  logic [63:0] row_write_bad_element;
  logic row_write_debt_zero;
  logic service_done_valid,service_done_ready;
  logic [31:0] service_done_status;
  logic [63:0] service_done_bad_element;
  logic service_read_debt_zero,service_arithmetic_debt_zero;
  logic producer_done_valid,producer_done_ready;
  logic [31:0] producer_done_status,producer_done_task_id,producer_done_dst_epoch;
  logic [63:0] producer_done_bad_element;
  logic [15:0] producer_done_covered_rows;
  logic producer_done_write_debt_zero,tensor_published,cancel_done,writer_busy;
  logic [2:0] gate_owner_state;
  logic [7:0] next_window;
  logic [127:0] valid_windows,covered_windows,consumed_windows;
  logic [2047:0] covered_rows;
  logic gate_acquire_valid,gate_acquire_ready,gate_acquire_done,gate_acquire_error;
  logic [671:0] gate_acquire_numeric_identity;
  logic [63:0] gate_acquire_ref;
  logic [6:0] gate_acquire_window;
  logic [551:0] gate_acquire_binding;
  logic gate_release_valid,gate_release_ready,gate_release_done,gate_release_error;
  logic [671:0] gate_release_numeric_identity;
  logic [63:0] gate_release_ref;
  logic [6:0] gate_release_window;
  logic [551:0] gate_release_binding;
  logic gate_release_read_debt_zero;
  logic tensor_release_valid,tensor_release_ready,tensor_release_done,tensor_release_error;
  logic [671:0] tensor_release_numeric_identity;
  logic [63:0] tensor_release_ref;
  logic tensor_release_debt_zero;
  logic [31:0] aw_count,w_count,b_count,accepted_words;
  logic [63:0] useful_bytes,physical_bytes;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid,m_axi_awready;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic m_axi_wlast,m_axi_wvalid,m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic m_axi_bvalid,m_axi_bready;
  logic hold_b;
  logic aw_pending,w_pending;
  logic [63:0] held_awaddr;
  logic [511:0] held_wdata;
  int cycles=0,total_aw=0,total_w=0,total_b=0,producer_completions=0,publishes=0;
  int current_epoch,current_request,current_window,current_rows;

  geglu_gate_tensor_store_v2 dut(.*);

  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;
    if(cycles%50000==0)
      $display("FULL_CURRENT_GATE_TENSOR_STORE_PROGRESS cycles=%0d window=%0d row_local=%0d col=%0d tx=%b awp=%b wp=%b bv=%b rowdone=%b svcdone=%b windone=%b state=%0d next=%0d",
        cycles,current_window,dut.writer.row_local,dut.writer.expected_col,dut.writer.tx_valid,
        aw_pending,w_pending,m_axi_bvalid,row_write_done_valid,service_done_valid,
        dut.writer_done_valid,gate_owner_state,next_window);
    if(cycles>400000)$fatal(1,"GATE tensor store cycle cap");
    if(tensor_published)publishes++;
    if(producer_done_valid && producer_done_ready)producer_completions++;
  end

  // One-outstanding AXI memory peer. It checks the physical address and the
  // first/last packed F32 word before returning B.
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      aw_pending<=0;w_pending<=0;m_axi_bvalid<=0;m_axi_bresp<=0;
      held_awaddr<=0;held_wdata<=0;total_aw<=0;total_w<=0;total_b<=0;
    end else begin
      if(m_axi_awvalid && m_axi_awready)begin
        if(aw_pending || m_axi_awlen!=0 || m_axi_awsize!=6 || m_axi_awburst!=1)
          $fatal(1,"GATE AW framing");
        aw_pending<=1;held_awaddr<=m_axi_awaddr;total_aw<=total_aw+1;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(w_pending || !m_axi_wlast || m_axi_wstrb!='1)$fatal(1,"GATE W framing");
        w_pending<=1;held_wdata<=m_axi_wdata;total_w<=total_w+1;
      end
      if(aw_pending && w_pending && !hold_b && !m_axi_bvalid)m_axi_bvalid<=1;
      if(m_axi_bvalid && m_axi_bready)begin
        longint unsigned offset;
        int row,beat;
        offset=held_awaddr-claim_region_base;
        row=offset/10496;beat=(offset%10496)/64;
        if(held_awaddr!=claim_region_base+64'(row)*10496+64'(beat)*64 ||
           held_wdata[31:0]!={16'(row),16'(beat*16)} ||
           held_wdata[511:480]!={16'(row),16'(beat*16+15)})
          $fatal(1,"GATE physical payload/address row=%0d beat=%0d addr=%h lo=%h hi=%h",
            row,beat,held_awaddr,held_wdata[31:0],held_wdata[511:480]);
        m_axi_bvalid<=0;aw_pending<=0;w_pending<=0;total_b<=total_b+1;
      end
    end
  end
  assign m_axi_awready=rst_n && !aw_pending;
  assign m_axi_wready=rst_n && !w_pending;

  function automatic logic [551:0] binding_for(input int window,input int rows);
    logic [95:0] p,q,l;
    logic [63:0] a,ps;
    p=0;p[31:0]=32'(100+window);p[39:32]=8'h60;p[47:40]=2;
    p[55:48]=7;p[87:72]=16'(window*16);p[95:88]=8'(rows);
    q=p;q[31:0]=32'(300+2*window);q[39:32]=8'h20;
    l=p;l[31:0]=32'(301+2*window);l[39:32]=8'h33;
    a=64'h0000002200000000|64'(window+1);
    ps=64'h0000002400000000|64'(window+1);
    return {p,q,l,a,64'h0000002300000001,ps,64'h0000000300000001,8'd0};
  endfunction

  task automatic prepare(input int request_id,input int epoch,input int window,input int rows);
    claim_numeric_identity=0;claim_numeric_identity[63:0]=64'(request_id);
    claim_numeric_identity[127:64]=1;claim_numeric_identity[143:128]=1;
    claim_numeric_identity[159:144]=64;
    claim_producer_context=0;claim_producer_context[31:0]=32'(100+window);
    claim_producer_context[39:32]=8'h60;claim_producer_context[47:40]=2;
    claim_producer_context[55:48]=7;claim_producer_context[87:72]=16'(window*16);
    claim_producer_context[95:88]=8'(rows);
    claim_quant_context=claim_producer_context;
    claim_quant_context[31:0]=32'(300+2*window);claim_quant_context[39:32]=8'h20;
    claim_linear_context=claim_producer_context;
    claim_linear_context[31:0]=32'(301+2*window);claim_linear_context[39:32]=8'h33;
    claim_source_ref=64'h0000000600000001;
    claim_gate_ref=64'h0000000700000000|64'(epoch);
    claim_a_ref=64'h0000002200000000|64'(window+1);
    claim_w_ref=64'h0000002300000001;
    claim_ps_ref=64'h0000002400000000|64'(window+1);
    claim_dst_ref=64'h0000000300000001;
    claim_gate_region=0;claim_dst_region=0;claim_output_binding=328'h123456;
    claim_plan_admitted=1;
    current_epoch=epoch;current_request=request_id;current_window=window;current_rows=rows;
  endtask

  task automatic claim_window;
    claim_valid=1;#1;
    if(!claim_ready || !claim_admitted)$fatal(1,"physical GATE claim rejected window=%0d",current_window);
    tick();@(negedge clk);claim_valid=0;
    if(claim_rejected || !writer_busy)$fatal(1,"physical GATE claim did not start writer");
  endtask

  task automatic drive_row(input int row,input bit hold_last_b);
    row_success=1;row_success_row=16'(row);
    for(int col=0;col<2624;col++)begin
      if(hold_last_b && col==2608)hold_b=1;
      @(negedge clk);v_valid=1;v_data={16'(row),16'(col)};v_status=0;
      v_frame_tag=claim_producer_context[31:0];v_row=16'(row);v_col=13'(col);
      v_last=col==2623;
      while(!v_ready)tick();
      tick();
    end
    @(negedge clk);v_valid=0;
    if(hold_last_b)begin
      repeat(8)begin
        tick();
        if(row_write_done_valid || producer_done_valid || tensor_published)
          $fatal(1,"GATE retired before held final B");
      end
      @(negedge clk);hold_b=0;
    end
    while(!row_write_done_valid)tick();
    if(row_write_status!=0 || row_write_row!=row || !row_write_debt_zero)
      $fatal(1,"GATE row write completion row=%0d status=%0d",row_write_row,row_write_status);
    tick();
  endtask

  task automatic finish_window(input bit expect_publish);
    service_done_status=0;service_done_bad_element='1;service_done_valid=1;
    while(!service_done_ready)tick();
    tick();
    @(negedge clk);service_done_valid=0;
    while(!producer_done_valid)tick();
    if(producer_done_status!=0 || producer_done_task_id!=claim_producer_context[31:0] ||
       producer_done_dst_epoch!=current_epoch || !producer_done_write_debt_zero ||
       producer_done_covered_rows!=(16'hffff>>(16-current_rows)))
      $fatal(1,"GATE producer completion binding/status");
    repeat(5)begin tick();if(!producer_done_valid)$fatal(1,"GATE producer response not held");end
    @(negedge clk);producer_done_ready=1;tick();
    if(tensor_published!=expect_publish)$fatal(1,"GATE tensor publish expected=%0d",expect_publish);
    @(negedge clk);producer_done_ready=0;tick();
  endtask

  task automatic acquire(input int window,input bit accepted,input bit corrupt_binding=0);
    gate_acquire_numeric_identity=claim_numeric_identity;gate_acquire_ref=claim_gate_ref;
    gate_acquire_window=7'(window);gate_acquire_binding=binding_for(window,window==0&&current_epoch==2?1:16);
    if(corrupt_binding)gate_acquire_binding[0]=~gate_acquire_binding[0];
    gate_acquire_valid=1;tick();
    if(!gate_acquire_done || gate_acquire_error==accepted)
      $fatal(1,"GATE acquire expected=%0d window=%0d error=%0d",accepted,window,gate_acquire_error);
    @(negedge clk);gate_acquire_valid=0;
  endtask

  task automatic release_window(input int window);
    gate_release_numeric_identity=gate_acquire_numeric_identity;
    gate_release_ref=gate_acquire_ref;gate_release_window=7'(window);
    gate_release_binding=gate_acquire_binding;gate_release_valid=1;
    gate_release_read_debt_zero=0;
    repeat(4)begin tick();if(gate_release_ready || gate_release_done)$fatal(1,"GATE released with read debt");end
    @(negedge clk);gate_release_read_debt_zero=1;tick();
    if(!gate_release_done || gate_release_error)$fatal(1,"GATE release failed");
    @(negedge clk);gate_release_valid=0;gate_release_read_debt_zero=0;tick();
  endtask

  task automatic fail_active_window;
    service_done_status=2;service_done_bad_element=9;service_done_valid=1;
    while(!service_done_ready)tick();tick();@(negedge clk);service_done_valid=0;
    while(!producer_done_valid)tick();
    if(producer_done_status==0)$fatal(1,"failed physical GATE window succeeded");
    @(negedge clk);producer_done_ready=1;tick();@(negedge clk);producer_done_ready=0;tick();
  endtask

  initial begin
    claim_valid=0;claim_plan_admitted=0;claim_numeric_identity=0;claim_producer_context=0;
    claim_quant_context=0;claim_linear_context=0;claim_source_ref=0;claim_gate_ref=0;
    claim_a_ref=0;claim_w_ref=0;claim_ps_ref=0;claim_dst_ref=0;claim_gate_region=0;
    claim_dst_region=0;claim_output_binding=0;claim_bo_base=64'h100000000;
    claim_bo_span=64'h40000000;claim_region_base=64'h100000000;claim_region_span=64'h40000000;
    row_success=0;row_success_row=0;v_valid=0;v_data=0;v_status=0;v_frame_tag=0;
    v_row=0;v_col=0;v_last=0;row_write_done_ready=1;service_done_valid=0;
    service_done_status=0;service_done_bad_element='1;service_read_debt_zero=1;
    service_arithmetic_debt_zero=1;producer_done_ready=0;gate_acquire_valid=0;
    gate_acquire_numeric_identity=0;gate_acquire_ref=0;gate_acquire_window=0;
    gate_acquire_binding=0;gate_release_valid=0;gate_release_numeric_identity=0;
    gate_release_ref=0;gate_release_window=0;gate_release_binding=0;
    gate_release_read_debt_zero=0;tensor_release_valid=0;tensor_release_numeric_identity=0;
    tensor_release_ref=0;tensor_release_debt_zero=0;hold_b=0;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(4)tick();

    // Four physical rows16 windows share one GATE Ref/epoch. Each GEGLU
    // command returns independently; only the final real B makes tensor READY.
    for(int w=0;w<4;w++)begin
      prepare(1,1,w,16);claim_window();
      for(int r=0;r<16;r++)drive_row(w*16+r,w==3 && r==15);
      finish_window(w==3);
      if(w==0)acquire(0,0);
      if(w<3 && gate_owner_state!=1)$fatal(1,"physical GATE tensor READY early");
    end
    if(gate_owner_state!=2 || publishes!=1 || producer_completions!=4 ||
       $countones(covered_windows)!=4 || $countones(covered_rows)!=64 ||
       total_aw!=10496 || total_w!=10496 || total_b!=10496)
      $fatal(1,"physical GATE tensor coverage/traffic AW/W/B=%0d/%0d/%0d",total_aw,total_w,total_b);

    acquire(0,0,1);
    for(int w=0;w<4;w++)begin acquire(w,1);release_window(w);end
    acquire(0,0);
    if($countones(consumed_windows)!=4)$fatal(1,"physical GATE consumed coverage");
    tensor_release_numeric_identity=claim_numeric_identity;tensor_release_ref=claim_gate_ref;
    tensor_release_valid=1;tensor_release_debt_zero=1;tick();
    if(!tensor_release_done || tensor_release_error || gate_owner_state!=0)$fatal(1,"physical GATE tensor release");
    @(negedge clk);tensor_release_valid=0;tensor_release_debt_zero=0;tick();

    // A short first window is enough to create a real inter-window gap; cancel
    // burns epoch 2, then a larger request in the same session claims epoch 3.
    prepare(2,2,0,1);claim_window();drive_row(0,0);finish_window(0);
    cancel=1;tick();@(negedge clk);cancel=0;tick();
    if(!cancel_done || gate_owner_state!=4)$fatal(1,"physical GATE inter-window cancel");
    prepare(3,3,0,1);claim_window();fail_active_window();
    if(gate_owner_state!=4 || publishes!=1)$fatal(1,"physical GATE recovery/failure state");
    $display("FULL_CURRENT_GATE_TENSOR_STORE_PASS same_epoch_windows=4 physical_rows=65 actual_AW=%0d actual_W=%0d actual_B=%0d final_B_publication=1 producer_responses=6 quant_before_ready_reject=1 binding_reject=1 duplicate_reject=1 held_read_debt=1 inter_window_cancel=1 same_session_recovery=1 cycles=%0d",
      total_aw,total_w,total_b,cycles);$finish;
  end
endmodule
`default_nettype wire
