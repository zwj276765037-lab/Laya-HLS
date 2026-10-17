`timescale 1ns/1ps
module geglu_gate_quant_bridge_tb_v1;
  logic  clk,rst_n,cfg_valid;
  logic  cfg_ready,cfg_reject;
  logic  cfg_owner_admitted;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_producer_context,cfg_quant_context,cfg_linear_context;
  logic [63:0] cfg_wi_ref,cfg_gate_ref,cfg_a_ref,cfg_w_ref,cfg_down_dst_ref;
  logic [4:0] cfg_rows;
  logic  cfg_a_slot;
  logic [31:0] cfg_a_slot_epoch;
  logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span;
  logic  wi_valid;
  logic  wi_ready;
  logic [31:0] wi_data,wi_status;
  logic [671:0] wi_numeric_identity;
  logic [63:0] wi_source_ref;
  logic [15:0] wi_row;
  logic [12:0] wi_index;
  logic  wi_row_done_valid;
  logic  wi_row_done_ready;
  logic [31:0] wi_row_done_status;
  logic [63:0] wi_row_bad_element;
  logic  wi_read_debt_zero;
  logic  done_valid;
  logic  done_ready;
  logic [31:0] done_status;
  logic [63:0] done_bad_element;
  logic [2:0] gate_owner_state;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch;
  logic [1:0][15:0] slot_rows_done;
  logic [31:0] aw_count,w_count,b_count,accepted_words;
  logic [63:0] useful_bytes,physical_bytes;
  logic [31:0] physical_half_commits,physical_scale_commits;
  logic [31:0] source_ar_count,source_r_count,source_complete_rows,quant_starts,quant_input_beats,quant_rows;
  logic [31:0] scale_issues,scale_returns,recip_issues,recip_returns,mul_halves_issued,mul_halves_returned;
  logic [63:0] quant_command_cycles;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic  m_axi_awvalid;
  logic  m_axi_awready;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic  m_axi_wlast,m_axi_wvalid;
  logic  m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic  m_axi_bvalid;
  logic  m_axi_bready;
  logic [63:0] m_axi_araddr;
  logic [7:0] m_axi_arlen;
  logic [2:0] m_axi_arsize;
  logic [1:0] m_axi_arburst;
  logic  m_axi_arvalid;
  logic  m_axi_arready;
  logic [511:0] m_axi_rdata;
  logic [1:0] m_axi_rresp;
  logic  m_axi_rlast,m_axi_rvalid;
  logic  m_axi_rready;
  logic  acquire_valid;
  logic  acquire_ready,acquire_done,acquire_error;
  logic  acquire_slot;
  logic [31:0] acquire_slot_epoch;
  logic [12:0] acquire_K;
  logic [4:0] acquire_rows;
  logic [671:0] acquire_numeric_identity;
  logic [95:0] acquire_linear_context;
  logic [63:0] acquire_a_ref,acquire_w_ref,acquire_dst_ref;
  logic  read_valid;
  logic  read_ready,read_error;
  logic  read_slot;
  logic [31:0] read_slot_epoch;
  logic [671:0] read_numeric_identity;
  logic [95:0] read_linear_context;
  logic [63:0] read_a_ref;
  logic [3:0] read_row_block_base;
  logic [2:0] read_rows;
  logic [6:0] read_group;
  logic  ret_valid;
  logic  ret_ready;
  logic  ret_slot;
  logic [31:0] ret_slot_epoch;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_linear_context;
  logic [63:0] ret_a_ref;
  logic [3:0] ret_row_block_base;
  logic [2:0] ret_rows;
  logic [6:0] ret_group;
  logic [3:0][255:0] ret_q;
  logic [3:0][15:0] ret_scale;
  logic  release_valid;
  logic  release_ready,release_done,release_error;
  logic  release_slot;
  logic [31:0] release_slot_epoch;
  logic [671:0] release_numeric_identity;
  logic [95:0] release_linear_context;
  logic [63:0] release_a_ref;
  logic  read_debt_zero;

  geglu_gate_quant_bridge_v1 dut(.*);
  initial clk=0;always #3.333 clk=~clk;
  logic [31:0] wi_fixture[0:5247],steps[0:26239],d_gold[0:81],recip_gold[0:81];
  logic [255:0] q_gold[0:81];logic [15:0] scale_gold[0:81];
  logic [511:0] gate_mem[0:2623];logic gate_written[0:2623];
  string fixture;
  integer cycles=0,write_beats=0,read_beats=0,quant_halves=0,held_b=0;
  integer bdelay=0,rdelay=0,rleft=0,rindex=0;
  logic aw_seen=0,w_seen=0,stored=0,read_active=0;
  logic [63:0] aw_addr;
  logic [511:0] w_data;
  logic [63:0] first_addr;
  task automatic tick;@(posedge clk);#1;endtask
  always @(negedge clk)begin
    m_axi_awready=rst_n && !aw_seen && cycles%7!=0;
    m_axi_wready=rst_n && !w_seen && cycles%11!=0;
    m_axi_arready=rst_n && !read_active && !m_axi_rvalid && cycles%5!=0;
    if(bdelay>0)begin
      bdelay=bdelay-1;held_b=held_b+1;
      if(bdelay==0)begin m_axi_bvalid=1;m_axi_bresp=0;end
    end
    if(read_active && !m_axi_rvalid)begin
      if(rdelay>0)rdelay=rdelay-1;
      else begin
        if(!gate_written[rindex])$fatal(1,"quant read unwritten physical GATE index=%0d",rindex);
        m_axi_rvalid=1;m_axi_rdata=gate_mem[rindex];m_axi_rresp=0;m_axi_rlast=rleft==1;
      end
    end
  end
  always @(posedge clk)begin
    cycles=cycles+1;
    if(cycles>180000)$fatal(1,"bridge timeout phase=%0d writerrow=%0d col=%0d tx=%0d qphase=%0d qactive=%0d starts=%0d owner=%0d",dut.phase,dut.writer.row_local,dut.writer.expected_col,dut.writer.tx_valid,dut.quant_task.phase,dut.quant_task.quant.active,quant_starts,gate_owner_state);
    if(!rst_n)begin
      aw_seen=0;w_seen=0;stored=0;read_active=0;bdelay=0;rdelay=0;rleft=0;m_axi_bvalid<=0;m_axi_rvalid<=0;
      for(int i=0;i<2624;i++)gate_written[i]=0;
    end else begin
      if(m_axi_awvalid && m_axi_awready)begin
        if(aw_seen || m_axi_awsize!=6 || m_axi_awlen!=0 || m_axi_awburst!=1)$fatal(1,"physical GATE AW");
        aw_seen=1;aw_addr=m_axi_awaddr;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(w_seen || m_axi_wstrb!==64'hffffffffffffffff || !m_axi_wlast)$fatal(1,"physical GATE W");
        w_seen=1;w_data=m_axi_wdata;
      end
      if(aw_seen && w_seen && !stored)begin
        int index;
        if(aw_addr!==first_addr+64'(write_beats)*64)$fatal(1,"actual GATE write physical address");
        index=int'((aw_addr-first_addr)>>6);
        for(int lane=0;lane<16;lane++)
          if(w_data[lane*32+:32]!==steps[(index*16+lane)*10+9])$fatal(1,"actual GATE numerical payload col=%0d got=%h gold=%h",index*16+lane,w_data[lane*32+:32],steps[(index*16+lane)*10+9]);
        gate_mem[index]=w_data;gate_written[index]=1;stored=1;write_beats=write_beats+1;bdelay=17+(index%3);
      end
      if(m_axi_bvalid && m_axi_bready)begin m_axi_bvalid<=0;aw_seen=0;w_seen=0;stored=0;end
      if(m_axi_arvalid && m_axi_arready)begin
        if(gate_owner_state!=3 || aw_count!=164 || b_count!=164 || m_axi_arsize!=6 || m_axi_arburst!=1 || m_axi_araddr<first_addr || m_axi_araddr+64'(m_axi_arlen+1)*64>first_addr+10496 || m_axi_araddr[11:0]+(int'(m_axi_arlen)+1)*64>4096)$fatal(1,"quant read before publication or wrong physical bounds");
        read_active=1;rindex=int'((m_axi_araddr-first_addr)>>6);rleft=int'(m_axi_arlen)+1;rdelay=3;
      end
      if(m_axi_rvalid && m_axi_rready)begin
        m_axi_rvalid<=0;rindex=rindex+1;rleft=rleft-1;read_beats=read_beats+1;rdelay=1+(read_beats%4);
        if(rleft==0)read_active=0;
      end
      if(dut.quant_task.q_out_valid && dut.quant_task.q_out_ready)begin
        int g,h;
        g=dut.quant_task.q_out_group;h=dut.quant_task.q_out_half;
        if(dut.quant_task.q_out!==q_gold[g][h*128+:128] || dut.quant_task.q_d!==d_gold[g] || dut.quant_task.q_recip!==recip_gold[g] || (h && dut.quant_task.q_scale!==scale_gold[g]))$fatal(1,"actual quant group gold g=%0d half=%0d",g,h);
        quant_halves=quant_halves+1;
      end
      if(quant_starts>1)$fatal(1,"Group32 loops caused more than one complete row command");
    end
  end
  task automatic configure;
    @(negedge clk);
    cfg_numeric_identity=672'h8afedcba76543210;cfg_numeric_identity[63:0]=64'h100000001;cfg_numeric_identity[127:64]=64'h200000001;
    cfg_numeric_identity[143:128]=2;cfg_numeric_identity[159:144]=128;
    cfg_producer_context=0;cfg_producer_context[31:0]=32'hac000001;cfg_producer_context[39:32]=8'h60;cfg_producer_context[47:40]=2;
    cfg_producer_context[63:56]=1;cfg_producer_context[87:72]=7;cfg_producer_context[95:88]=1;
    cfg_quant_context=cfg_producer_context;cfg_quant_context[31:0]=32'hac000002;cfg_quant_context[39:32]=8'h61;
    cfg_linear_context=cfg_producer_context;cfg_linear_context[31:0]=32'hac000003;cfg_linear_context[39:32]=8'h33;
    cfg_wi_ref=64'h0000000600000001;cfg_gate_ref=64'h0000000700000001;cfg_a_ref=64'h0000002200000001;cfg_w_ref=64'h0000002300000001;cfg_down_dst_ref=64'h0000000300000001;
    cfg_rows=1;cfg_a_slot=0;cfg_a_slot_epoch=1;cfg_bo_base=64'h100000000;cfg_bo_span=64'h3000000;cfg_region_base=cfg_bo_base+4096;cfg_region_span=64'h2000000;
    first_addr=cfg_region_base+10747904+7*10496;
    cfg_owner_admitted=0;cfg_valid=1;@(posedge clk);while(!cfg_ready)@(posedge clk);#1;
    if(!cfg_reject || aw_count!=0 || dut.vector_row.issued!=0 || quant_starts!=0)$fatal(1,"bad outer owner admission issued work");
    @(negedge clk);cfg_valid=0;cfg_owner_admitted=1;tick();@(negedge clk);cfg_valid=1;tick();
    if(cfg_reject)$fatal(1,"legal atomic bridge command rejected");@(negedge clk);cfg_valid=0;
  endtask
  task automatic read_A;
    @(negedge clk);acquire_valid=1;acquire_slot=0;acquire_slot_epoch=1;acquire_K=2624;acquire_rows=1;
    acquire_numeric_identity=cfg_numeric_identity;acquire_linear_context=cfg_linear_context;acquire_a_ref=cfg_a_ref;acquire_w_ref=cfg_w_ref;acquire_dst_ref=cfg_down_dst_ref;
    @(posedge clk);while(!acquire_ready)@(posedge clk);#1;if(!acquire_done || acquire_error)$fatal(1,"actual A lease");@(negedge clk);acquire_valid=0;
    for(int g=0;g<82;g++)begin
      @(negedge clk);read_valid=1;read_slot=0;read_slot_epoch=1;read_numeric_identity=cfg_numeric_identity;read_linear_context=cfg_linear_context;read_a_ref=cfg_a_ref;read_row_block_base=0;read_rows=1;read_group=7'(g);
      @(posedge clk);while(!read_ready)@(posedge clk);#1;if(read_error)$fatal(1,"actual A read admission");@(negedge clk);read_valid=0;
      while(!ret_valid)tick();
      if(ret_q[0]!==q_gold[g] || ret_scale[0]!==scale_gold[g] || ret_numeric_identity!==cfg_numeric_identity || ret_linear_context!==cfg_linear_context || ret_a_ref!==cfg_a_ref || ret_group!=g)$fatal(1,"resident A q/scale/owner gold group=%0d",g);
      repeat(3)begin tick();if(!ret_valid || ret_q[0]!==q_gold[g])$fatal(1,"resident A return hold");end
      @(negedge clk);ret_ready=1;tick();@(negedge clk);ret_ready=0;
    end
    @(negedge clk);release_valid=1;release_slot=0;release_slot_epoch=1;release_numeric_identity=cfg_numeric_identity;release_linear_context=cfg_linear_context;release_a_ref=cfg_a_ref;
    @(posedge clk);while(!release_ready)@(posedge clk);#1;if(!release_done || release_error || !read_debt_zero || slot_state[0]!=0)$fatal(1,"actual A lease release");@(negedge clk);release_valid=0;
  endtask
  initial begin
    rst_n=0;
    cfg_valid=0;cfg_owner_admitted=0;cfg_numeric_identity=0;cfg_producer_context=0;cfg_quant_context=0;cfg_linear_context=0;cfg_wi_ref=0;cfg_gate_ref=0;cfg_a_ref=0;cfg_w_ref=0;cfg_down_dst_ref=0;cfg_rows=0;cfg_a_slot=0;cfg_a_slot_epoch=0;cfg_bo_base=0;cfg_bo_span=0;cfg_region_base=0;cfg_region_span=0;wi_valid=0;wi_data=0;wi_status=0;wi_numeric_identity=0;wi_source_ref=0;wi_row=0;wi_index=0;wi_row_done_valid=0;wi_row_done_status=0;wi_row_bad_element=0;wi_read_debt_zero=0;done_ready=0;m_axi_awready=0;m_axi_wready=0;m_axi_bresp=0;m_axi_bvalid=0;m_axi_arready=0;m_axi_rdata=0;m_axi_rresp=0;m_axi_rlast=0;m_axi_rvalid=0;acquire_valid=0;acquire_slot=0;acquire_slot_epoch=0;acquire_K=0;acquire_rows=0;acquire_numeric_identity=0;acquire_linear_context=0;acquire_a_ref=0;acquire_w_ref=0;acquire_dst_ref=0;read_valid=0;read_slot=0;read_slot_epoch=0;read_numeric_identity=0;read_linear_context=0;read_a_ref=0;read_row_block_base=0;read_rows=0;read_group=0;ret_ready=0;release_valid=0;release_slot=0;release_slot_epoch=0;release_numeric_identity=0;release_linear_context=0;release_a_ref=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture path");
    $readmemh({fixture,"/wi.mem"},wi_fixture);$readmemh({fixture,"/steps.mem"},steps);$readmemh({fixture,"/q.mem"},q_gold);$readmemh({fixture,"/scale.mem"},scale_gold);$readmemh({fixture,"/d.mem"},d_gold);$readmemh({fixture,"/recip.mem"},recip_gold);
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(15)tick();configure();
    for(int col=0;col<5248;col++)begin
      @(negedge clk);wi_valid=1;wi_data=wi_fixture[col];wi_status=0;wi_numeric_identity=cfg_numeric_identity;wi_source_ref=cfg_wi_ref;wi_row=7;wi_index=13'(col);
      @(posedge clk);while(!wi_ready)@(posedge clk);#1;@(negedge clk);wi_valid=0;
    end
    @(negedge clk);wi_row_done_valid=1;wi_row_done_status=0;wi_read_debt_zero=0;
    repeat(19)begin tick();if(wi_row_done_ready || dut.vector_row.issued!=0 || aw_count!=0)$fatal(1,"complete WI read barrier");end
    @(negedge clk);wi_read_debt_zero=1;@(posedge clk);while(!wi_row_done_ready)@(posedge clk);#1;@(negedge clk);wi_row_done_valid=0;
    while(!done_valid)tick();
    if(done_status!=0 || gate_owner_state!=0 || slot_state[0]!=2 || slot_rows_done[0]!=1 || quant_starts!=1 || quant_rows!=1 || quant_input_beats!=164 || physical_half_commits!=164 || physical_scale_commits!=82 || source_complete_rows!=1 || source_r_count!=164 || write_beats!=164 || read_beats!=164 || quant_halves!=164)$fatal(1,"complete bridge counters status=%0d gate=%0d A=%0d starts=%0d rows=%0d halves=%0d scales=%0d",done_status,gate_owner_state,slot_state[0],quant_starts,quant_rows,physical_half_commits,physical_scale_commits);
    repeat(7)begin tick();if(!done_valid || slot_state[0]!=2)$fatal(1,"held bridge terminal");end
    @(negedge clk);done_ready=1;tick();@(negedge clk);done_ready=0;read_A();
    $display("GEGLU_GATE_QUANT_BRIDGE_PASS real_WI_words=5248 real_gate_words=2624 actual_AXI_write_beats=164 actual_AXI_read_beats=164 real_quant_groups=82 row_commands=1 full_dual_A=1 A_groups_checked=82 no_preloaded_gate_q_ps=1 owner_reject_zero_issue=1 final_B_publication=1 source_read_debt=1 held_b=%0d quant_cycles=%0d cycles=%0d",held_b,quant_command_cycles,cycles);$finish;
  end
endmodule
