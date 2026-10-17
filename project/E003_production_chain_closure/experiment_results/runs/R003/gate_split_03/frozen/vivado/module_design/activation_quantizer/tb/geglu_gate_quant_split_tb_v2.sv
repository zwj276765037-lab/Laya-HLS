`timescale 1ns/1ps
module geglu_gate_quant_split_tb_v2;
  logic clk=0,rst_n=0,cancel=0;
  always #3.333 clk=~clk;
  logic g_cfg_valid,g_cfg_ready,g_cfg_reject,g_cfg_owner_admitted,g_cfg_plan_admitted;
  logic [671:0] g_cfg_numeric_identity;
  logic [95:0] g_cfg_producer_context,g_cfg_quant_context,g_cfg_linear_context;
  logic [63:0] g_cfg_wi_ref,g_cfg_gate_ref,g_cfg_a_ref,g_cfg_w_ref,g_cfg_ps_ref,g_cfg_down_dst_ref;
  logic [7:0] g_cfg_gate_region,g_cfg_dst_region;
  logic [327:0] g_cfg_output_binding;
  logic g_cfg_a_slot;
  logic [31:0] g_cfg_a_slot_epoch;
  logic [63:0] g_cfg_bo_base,g_cfg_bo_span,g_cfg_region_base,g_cfg_region_span;
  logic wi_valid,wi_ready;
  logic [31:0] wi_data,wi_status;
  logic [671:0] wi_numeric_identity;
  logic [63:0] wi_source_ref;
  logic [15:0] wi_row;
  logic [12:0] wi_index;
  logic wi_row_done_valid,wi_row_done_ready;
  logic [31:0] wi_row_done_status;
  logic [63:0] wi_row_bad_element;
  logic wi_read_debt_zero;
  logic g_done_valid,g_done_ready;
  logic [31:0] g_done_status,g_done_task_id,g_done_dst_epoch;
  logic [63:0] g_done_bad_element;
  logic [15:0] g_done_covered_rows;
  logic q_cfg_valid,q_cfg_ready,q_cfg_reject,q_cfg_owner_admitted;
  logic [671:0] q_cfg_numeric_identity;
  logic [95:0] q_cfg_producer_context,q_cfg_quant_context,q_cfg_linear_context;
  logic [63:0] q_cfg_gate_ref,q_cfg_a_ref,q_cfg_w_ref,q_cfg_ps_ref,q_cfg_down_dst_ref;
  logic [7:0] q_cfg_dst_region;
  logic [6:0] q_cfg_window;
  logic q_cfg_a_slot;
  logic [31:0] q_cfg_a_slot_epoch;
  logic [63:0] q_cfg_bo_base,q_cfg_bo_span,q_cfg_region_base,q_cfg_region_span;
  logic q_done_valid,q_done_ready;
  logic [31:0] q_done_status;
  logic [63:0] q_done_bad_element;
  logic tensor_published,cancel_done,writer_busy;
  logic [2:0] gate_owner_state;
  logic [7:0] next_window;
  logic [127:0] valid_windows,covered_windows,consumed_windows;
  logic [2047:0] covered_rows;
  logic tensor_release_valid,tensor_release_ready,tensor_release_done,tensor_release_error;
  logic [671:0] tensor_release_numeric_identity;
  logic [63:0] tensor_release_ref;
  logic tensor_release_debt_zero;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch;
  logic [1:0][15:0] slot_rows_done;
  logic [31:0] aw_count,w_count,b_count,accepted_words;
  logic [63:0] useful_bytes,physical_bytes;
  logic [31:0] physical_half_commits,physical_scale_commits;
  logic [31:0] source_ar_count,source_r_count,source_complete_rows;
  logic [31:0] quant_starts,quant_input_beats,quant_rows;
  logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns;
  logic [31:0] mul_halves_issued,mul_halves_returned;
  logic [63:0] quant_command_cycles;
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
  logic [63:0] m_axi_araddr;
  logic [7:0] m_axi_arlen;
  logic [2:0] m_axi_arsize;
  logic [1:0] m_axi_arburst;
  logic m_axi_arvalid,m_axi_arready;
  logic [511:0] m_axi_rdata;
  logic [1:0] m_axi_rresp;
  logic m_axi_rlast,m_axi_rvalid,m_axi_rready;
  logic acquire_valid,acquire_ready,acquire_done,acquire_error,acquire_slot;
  logic [31:0] acquire_slot_epoch;
  logic [12:0] acquire_K;
  logic [4:0] acquire_rows;
  logic [671:0] acquire_numeric_identity;
  logic [95:0] acquire_linear_context;
  logic [63:0] acquire_a_ref,acquire_w_ref,acquire_dst_ref;
  logic read_valid,read_ready,read_error,read_slot;
  logic [31:0] read_slot_epoch;
  logic [671:0] read_numeric_identity;
  logic [95:0] read_linear_context;
  logic [63:0] read_a_ref;
  logic [3:0] read_row_block_base;
  logic [2:0] read_rows;
  logic [6:0] read_group;
  logic ret_valid,ret_ready,ret_slot;
  logic [31:0] ret_slot_epoch;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_linear_context;
  logic [63:0] ret_a_ref;
  logic [3:0] ret_row_block_base;
  logic [2:0] ret_rows;
  logic [6:0] ret_group;
  logic [3:0][255:0] ret_q;
  logic [3:0][15:0] ret_scale;
  logic release_valid,release_ready,release_done,release_error,release_slot;
  logic [31:0] release_slot_epoch;
  logic [671:0] release_numeric_identity;
  logic [95:0] release_linear_context;
  logic [63:0] release_a_ref;
  logic read_debt_zero;

  geglu_gate_quant_split_v2 dut(.*);
  logic [31:0] wi_fixture[0:20991],gate_gold[0:10495],d_gold[0:327],recip_gold[0:327];
  logic [255:0] q_gold[0:327];
  logic [15:0] scale_gold[0:327];
  logic [511:0] gate_mem[0:10495];
  logic gate_written[0:10495];
  string fixture;
  integer pilot,cycles=0,write_beats=0,read_beats=0,quant_halves=0,a_words=0;
  integer bdelay=0,rdelay=0,rleft=0,rindex=0;
  logic aw_seen=0,w_seen=0,stored=0,read_active=0;
  logic [63:0] aw_addr,first_addr;
  logic [511:0] w_data;

  task automatic tick;@(posedge clk);#1;endtask
  always @(negedge clk)begin
    m_axi_awready=rst_n && !aw_seen && cycles%7!=0;
    m_axi_wready=rst_n && !w_seen && cycles%11!=0;
    m_axi_arready=rst_n && !read_active && !m_axi_rvalid && cycles%5!=0;
    if(bdelay>0)begin
      bdelay=bdelay-1;
      if(bdelay==0)begin m_axi_bvalid=1;m_axi_bresp=0;end
    end
    if(read_active && !m_axi_rvalid)begin
      if(rdelay>0)rdelay=rdelay-1;
      else begin
        if(!gate_written[rindex])$fatal(1,"split QUANT read unwritten GATE beat=%0d",rindex);
        m_axi_rvalid=1;m_axi_rdata=gate_mem[rindex];m_axi_rresp=0;m_axi_rlast=rleft==1;
      end
    end
  end
  always @(posedge clk)begin
    cycles=cycles+1;
    if(cycles>2000000)$fatal(1,"split bridge cycle cap phase=%0d Gstate=%0d row=%0d Qstate=%0d starts=%0d owner=%0d",
      dut.phase,dut.vector_row.state,dut.store.writer.row_local,dut.quant_task.phase,quant_starts,gate_owner_state);
    if(cycles%100000==0)$display("FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS cycles=%0d phase=%0d vstate=%0d loaded=%0d issued=%0d returned=%0d next=%0d rows=%0d writes=%0d reads=%0d qrows=%0d",
      cycles,dut.phase,dut.vector_row.state,dut.vector_row.loaded,dut.vector_row.issued,
      dut.vector_row.returned,next_window,$countones(covered_rows),write_beats,read_beats,quant_rows);
    if(!rst_n)begin
      aw_seen=0;w_seen=0;stored=0;read_active=0;bdelay=0;rdelay=0;rleft=0;
      m_axi_bvalid<=0;m_axi_rvalid<=0;
      for(int i=0;i<10496;i++)gate_written[i]=0;
    end else begin
      if(m_axi_awvalid && m_axi_awready)begin
        if(aw_seen || m_axi_awsize!=6 || m_axi_awlen!=0 || m_axi_awburst!=1)$fatal(1,"split GATE AW");
        aw_seen=1;aw_addr=m_axi_awaddr;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(w_seen || m_axi_wstrb!==64'hffffffffffffffff || !m_axi_wlast)$fatal(1,"split GATE W");
        w_seen=1;w_data=m_axi_wdata;
      end
      if(aw_seen && w_seen && !stored)begin
        int index,row,col;
        index=int'((aw_addr-first_addr)>>6);row=index/164;
        if(index<0 || index>=10496 || aw_addr!==first_addr+64'(index)*64)$fatal(1,"split GATE write address");
        for(int lane=0;lane<16;lane++)begin
          col=(index%164)*16+lane;
          if(w_data[lane*32+:32]!==gate_gold[(row%4)*2624+col])
            $fatal(1,"split GATE gold row=%0d col=%0d",row,col);
        end
        gate_mem[index]=w_data;gate_written[index]=1;stored=1;write_beats=write_beats+1;
        bdelay=2+(index%3);
      end
      if(m_axi_bvalid && m_axi_bready)begin
        m_axi_bvalid<=0;aw_seen=0;w_seen=0;stored=0;
      end
      if(m_axi_arvalid && m_axi_arready)begin
        if(gate_owner_state!=3 || m_axi_arsize!=6 || m_axi_arburst!=1 ||
           m_axi_araddr<first_addr || m_axi_araddr+64'(m_axi_arlen+1)*64>first_addr+16*10496 ||
           m_axi_araddr[11:0]+(int'(m_axi_arlen)+1)*64>4096)
          $fatal(1,"split QUANT AR before lease or out of window");
        read_active=1;rindex=int'((m_axi_araddr-first_addr)>>6);
        rleft=int'(m_axi_arlen)+1;rdelay=1;
      end
      if(m_axi_rvalid && m_axi_rready)begin
        m_axi_rvalid<=0;rindex=rindex+1;rleft=rleft-1;read_beats=read_beats+1;
        rdelay=1+(read_beats%3);if(rleft==0)read_active=0;
      end
      if(dut.quant_task.q_out_valid && dut.quant_task.q_out_ready)begin
        int row,g,h,gold_index;
        row=int'(dut.quant_task.active_row);g=int'(dut.quant_task.q_out_group);
        h=dut.quant_task.q_out_half;gold_index=(row%4)*82+g;
        if(dut.quant_task.q_out!==q_gold[gold_index][h*128+:128] ||
           dut.quant_task.q_d!==d_gold[gold_index] || dut.quant_task.q_recip!==recip_gold[gold_index] ||
           (h && dut.quant_task.q_scale!==scale_gold[gold_index]))
          $fatal(1,"split QUANT gold row=%0d group=%0d half=%0d",row,g,h);
        quant_halves=quant_halves+1;
      end
    end
  end

  task automatic prepare_g(input int window,input int rows);
    @(negedge clk);
    g_cfg_numeric_identity=0;g_cfg_numeric_identity[63:0]=64'h100000001;
    g_cfg_numeric_identity[127:64]=64'h200000001;g_cfg_numeric_identity[143:128]=1;
    g_cfg_numeric_identity[159:144]=64;
    g_cfg_producer_context=0;g_cfg_producer_context[31:0]=32'(100+window);
    g_cfg_producer_context[39:32]=8'h60;g_cfg_producer_context[47:40]=2;
    g_cfg_producer_context[55:48]=7;g_cfg_producer_context[87:72]=16'(window*16);
    g_cfg_producer_context[95:88]=8'(rows);
    g_cfg_quant_context=g_cfg_producer_context;g_cfg_quant_context[31:0]=32'(300+2*window);
    g_cfg_quant_context[39:32]=8'h20;
    g_cfg_linear_context=g_cfg_producer_context;g_cfg_linear_context[31:0]=32'(301+2*window);
    g_cfg_linear_context[39:32]=8'h33;
    g_cfg_wi_ref=64'h0000000600000001;g_cfg_gate_ref=64'h0000000700000001;
    g_cfg_a_ref=64'h0000002200000000|64'(window+1);g_cfg_w_ref=64'h0000002300000001;
    g_cfg_ps_ref=64'h0000002400000000|64'(window+1);g_cfg_down_dst_ref=64'h0000000300000001;
    g_cfg_gate_region=0;g_cfg_dst_region=0;g_cfg_output_binding=328'h123456;
    g_cfg_a_slot=0;g_cfg_a_slot_epoch=32'(window+1);
    g_cfg_owner_admitted=1;g_cfg_plan_admitted=1;
  endtask
  task automatic start_g;
    // prepare_g changes fields that feed the adapter's combinational legal-command
    // test on this same negedge.  Allow that test to settle before sampling ready;
    // otherwise the first tick can perform the handshake while the while-loop still
    // believes ready was low and then wait forever after phase advances to G_RUN.
    g_cfg_valid=1;#1;
    if(!g_cfg_ready)$fatal(1,"split legal G not immediately ready");
    tick();@(negedge clk);g_cfg_valid=0;
    if(g_cfg_reject)$fatal(1,"split legal G rejected");
  endtask
  task automatic drive_wi_row(input int global_row);
    int fixture_row;
    fixture_row=global_row%4;
    for(int col=0;col<5248;col++)begin
      @(negedge clk);wi_valid=1;wi_data=wi_fixture[fixture_row*5248+col];wi_status=0;
      wi_numeric_identity=g_cfg_numeric_identity;wi_source_ref=g_cfg_wi_ref;
      wi_row=16'(global_row);wi_index=13'(col);
      while(!wi_ready)tick();tick();
    end
    @(negedge clk);wi_valid=0;wi_row_done_valid=1;wi_row_done_status=0;
    wi_row_bad_element='1;wi_read_debt_zero=global_row!=0;
    #1;
    if(global_row==0)begin
      repeat(9)begin tick();if(wi_row_done_ready)$fatal(1,"split WI read debt ignored");end
      @(negedge clk);wi_read_debt_zero=1;
      #1;
    end
    if(!wi_row_done_ready)$fatal(1,"split completed WI row not ready after debt retirement");
    tick();
    @(negedge clk);wi_row_done_valid=0;
  endtask
  task automatic finish_g(input int window,input int rows,input bit publish);
    while(!g_done_valid)tick();
    if(g_done_status!=0 || g_done_task_id!=100+window || g_done_dst_epoch!=1 ||
       g_done_covered_rows!=(16'hffff>>(16-rows)))$fatal(1,"split G completion");
    repeat(3)begin tick();if(!g_done_valid)$fatal(1,"split G response hold");end
    @(negedge clk);g_done_ready=1;tick();
    if(tensor_published!=publish)$fatal(1,"split tensor publication expected=%0d",publish);
    @(negedge clk);g_done_ready=0;tick();
  endtask
  task automatic start_q0;
    @(negedge clk);
    q_cfg_numeric_identity=g_cfg_numeric_identity;q_cfg_producer_context=0;
    q_cfg_producer_context[31:0]=100;q_cfg_producer_context[39:32]=8'h60;
    q_cfg_producer_context[47:40]=2;q_cfg_producer_context[55:48]=7;
    q_cfg_producer_context[87:72]=0;q_cfg_producer_context[95:88]=16;
    q_cfg_quant_context=q_cfg_producer_context;q_cfg_quant_context[31:0]=300;
    q_cfg_quant_context[39:32]=8'h20;
    q_cfg_linear_context=q_cfg_producer_context;q_cfg_linear_context[31:0]=301;
    q_cfg_linear_context[39:32]=8'h33;
    q_cfg_gate_ref=64'h0000000700000001;q_cfg_a_ref=64'h0000002200000001;
    q_cfg_w_ref=64'h0000002300000001;q_cfg_ps_ref=64'h0000002400000001;
    q_cfg_down_dst_ref=64'h0000000300000001;q_cfg_dst_region=0;q_cfg_window=0;
    q_cfg_a_slot=0;q_cfg_a_slot_epoch=1;q_cfg_owner_admitted=1;
    q_cfg_bo_base=g_cfg_bo_base;q_cfg_bo_span=g_cfg_bo_span;
    q_cfg_region_base=g_cfg_region_base;q_cfg_region_span=g_cfg_region_span;
    q_cfg_valid=1;while(!q_cfg_ready)tick();tick();@(negedge clk);q_cfg_valid=0;
    if(q_cfg_reject)$fatal(1,"split legal Q rejected");
  endtask
  task automatic verify_a;
    acquire_slot=0;acquire_slot_epoch=1;acquire_K=2624;acquire_rows=16;
    acquire_numeric_identity=q_cfg_numeric_identity;acquire_linear_context=q_cfg_linear_context;
    acquire_a_ref=q_cfg_a_ref;acquire_w_ref=q_cfg_w_ref;acquire_dst_ref=q_cfg_down_dst_ref;
    acquire_valid=1;while(!acquire_ready)tick();tick();
    if(!acquire_done || acquire_error)$fatal(1,"split A acquire");
    @(negedge clk);acquire_valid=0;
    for(int block=0;block<16;block+=4)for(int g=0;g<82;g++)begin
      @(negedge clk);read_slot=0;read_slot_epoch=1;read_numeric_identity=q_cfg_numeric_identity;
      read_linear_context=q_cfg_linear_context;read_a_ref=q_cfg_a_ref;
      read_row_block_base=4'(block);read_rows=4;read_group=7'(g);read_valid=1;
      while(!read_ready)tick();tick();if(read_error)$fatal(1,"split A read admission");
      @(negedge clk);read_valid=0;while(!ret_valid)tick();
      if(ret_group!=g || ret_row_block_base!=block || ret_rows!=4)$fatal(1,"split A return identity");
      for(int r=0;r<4;r++)begin
        if(ret_q[r]!==q_gold[((block+r)%4)*82+g] ||
           ret_scale[r]!==scale_gold[((block+r)%4)*82+g])$fatal(1,"split A payload");
        a_words=a_words+1;
      end
      @(negedge clk);ret_ready=1;tick();@(negedge clk);ret_ready=0;
    end
    release_slot=0;release_slot_epoch=1;release_numeric_identity=q_cfg_numeric_identity;
    release_linear_context=q_cfg_linear_context;release_a_ref=q_cfg_a_ref;release_valid=1;
    while(!release_ready)tick();tick();
    if(!release_done || release_error || !read_debt_zero)$fatal(1,"split A release");
    @(negedge clk);release_valid=0;
  endtask

  initial begin
    g_cfg_valid=0;g_cfg_owner_admitted=0;g_cfg_plan_admitted=0;g_cfg_numeric_identity=0;
    g_cfg_producer_context=0;g_cfg_quant_context=0;g_cfg_linear_context=0;
    g_cfg_wi_ref=0;g_cfg_gate_ref=0;g_cfg_a_ref=0;g_cfg_w_ref=0;g_cfg_ps_ref=0;
    g_cfg_down_dst_ref=0;g_cfg_gate_region=0;g_cfg_dst_region=0;g_cfg_output_binding=0;
    g_cfg_a_slot=0;g_cfg_a_slot_epoch=0;g_cfg_bo_base=64'h100000000;
    g_cfg_bo_span=64'h3000000;g_cfg_region_base=64'h100001000;g_cfg_region_span=64'h2000000;
    wi_valid=0;wi_data=0;wi_status=0;wi_numeric_identity=0;wi_source_ref=0;wi_row=0;
    wi_index=0;wi_row_done_valid=0;wi_row_done_status=0;wi_row_bad_element=0;
    wi_read_debt_zero=0;g_done_ready=0;q_cfg_valid=0;q_cfg_owner_admitted=0;
    q_cfg_numeric_identity=0;q_cfg_producer_context=0;q_cfg_quant_context=0;
    q_cfg_linear_context=0;q_cfg_gate_ref=0;q_cfg_a_ref=0;q_cfg_w_ref=0;q_cfg_ps_ref=0;
    q_cfg_down_dst_ref=0;q_cfg_dst_region=0;q_cfg_window=0;q_cfg_a_slot=0;
    q_cfg_a_slot_epoch=0;q_cfg_bo_base=0;q_cfg_bo_span=0;q_cfg_region_base=0;
    q_cfg_region_span=0;q_done_ready=0;tensor_release_valid=0;
    tensor_release_numeric_identity=0;tensor_release_ref=0;tensor_release_debt_zero=0;
    m_axi_awready=0;m_axi_wready=0;m_axi_bresp=0;m_axi_bvalid=0;m_axi_arready=0;
    m_axi_rdata=0;m_axi_rresp=0;m_axi_rlast=0;m_axi_rvalid=0;acquire_valid=0;
    acquire_slot=0;acquire_slot_epoch=0;acquire_K=0;acquire_rows=0;
    acquire_numeric_identity=0;acquire_linear_context=0;acquire_a_ref=0;acquire_w_ref=0;
    acquire_dst_ref=0;read_valid=0;read_slot=0;read_slot_epoch=0;read_numeric_identity=0;
    read_linear_context=0;read_a_ref=0;read_row_block_base=0;read_rows=0;read_group=0;
    ret_ready=0;release_valid=0;release_slot=0;release_slot_epoch=0;
    release_numeric_identity=0;release_linear_context=0;release_a_ref=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"split fixture path");
    pilot=$test$plusargs("PILOT");
    $readmemh({fixture,"/wi.mem"},wi_fixture);$readmemh({fixture,"/gate.mem"},gate_gold);
    $readmemh({fixture,"/q.mem"},q_gold);$readmemh({fixture,"/scale.mem"},scale_gold);
    $readmemh({fixture,"/d.mem"},d_gold);$readmemh({fixture,"/recip.mem"},recip_gold);
    first_addr=g_cfg_region_base;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(15)tick();
    if(pilot)begin
      prepare_g(0,1);start_g();drive_wi_row(0);finish_g(0,1,0);
      repeat(31)begin tick();if(m_axi_arvalid || quant_starts!=0 || source_ar_count!=0)$fatal(1,"split pilot fused Q");end
      $display("FULL_CURRENT_GATE_QUANT_SPLIT_PILOT_PASS actual_G_rows=1 actual_WI_words=5248 actual_G_words=2624 actual_AW=%0d actual_B=%0d no_Q_before_command=1 tensor_ready=0 cycles=%0d",
        write_beats,write_beats,cycles);$finish;
    end
    for(int w=0;w<4;w++)begin
      prepare_g(w,16);start_g();
      for(int r=0;r<16;r++)drive_wi_row(w*16+r);
      finish_g(w,16,w==3);
      if(w<3 && gate_owner_state!=1)$fatal(1,"split G tensor READY early");
    end
    if(gate_owner_state!=2 || $countones(covered_rows)!=64 || write_beats!=10496 ||
       quant_starts!=0 || source_ar_count!=0)$fatal(1,"split all-G barrier");
    repeat(37)begin tick();if(m_axi_arvalid || quant_starts!=0)$fatal(1,"split Q started before command");end
    start_q0();while(!q_done_valid)tick();
    if(q_done_status!=0 || gate_owner_state!=2 || !consumed_windows[0] ||
       quant_starts!=16 || quant_rows!=16 || source_r_count!=2624 ||
       read_beats!=2624 || quant_halves!=2624 || slot_state[0]!=2 ||
       slot_rows_done[0]!=16'hffff)$fatal(1,"split Q completion status=%0d starts=%0d rows=%0d R=%0d halves=%0d",
         q_done_status,quant_starts,quant_rows,source_r_count,quant_halves);
    repeat(5)begin tick();if(!q_done_valid)$fatal(1,"split Q response hold");end
    @(negedge clk);q_done_ready=1;tick();@(negedge clk);q_done_ready=0;
    verify_a();
    cancel=1;tick();@(negedge clk);cancel=0;while(!cancel_done)tick();
    if(gate_owner_state!=4)$fatal(1,"split tensor cancel cleanup");
    $display("FULL_CURRENT_GATE_QUANT_SPLIT_FULL_PASS G_commands=4 G_rows=64 same_gate_epoch=1 actual_WI_words=335872 actual_G_words=167936 actual_AW=%0d actual_B=%0d tensor_after_all_G=1 Q_commands=1 delayed_Q=1 actual_AR=%0d actual_R=%0d quant_rows=%0d quant_halves=%0d fullA_rows=16 A_words_checked=%0d gate_window_release=1 tensor_cancel_cleanup=1 cycles=%0d",
      write_beats,write_beats,source_ar_count,source_r_count,quant_rows,quant_halves,a_words,cycles);$finish;
  end
endmodule
