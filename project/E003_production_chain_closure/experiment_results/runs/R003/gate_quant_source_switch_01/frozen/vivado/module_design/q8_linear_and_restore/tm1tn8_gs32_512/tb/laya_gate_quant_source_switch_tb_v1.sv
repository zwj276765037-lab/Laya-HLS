`timescale 1ns/1ps
module laya_gate_quant_source_switch_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk=0,rst_n=0;
  always #3.333 clk=~clk;

  logic g_service_cancel,q_service_cancel;
  logic source_query_valid,source_query_ready=1,source_query_granted=0;
  logic [8191:0] source_query_command;
  logic source_release_valid,source_release_ready=0,source_release_drained;
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

  logic [31:0] wi_fixture[0:20991],gate_gold[0:10495];
  logic [31:0] source_mem[0:255];logic [7:0] q_gold[0:255];
  logic [15:0] scale_gold[0:7];
  string fixture;
  integer cycles=0,wi_ar_count=0,wi_r_count=0,gate_aw_count=0,gate_w_count=0,gate_b_count=0;
  integer progress_work=0,last_progress_work=0;
  integer source_ar=0,source_r=0,read_index=0,read_left=0,read_delay=0;
  integer a_groups_checked=0;
  integer wi_rindex=0,wi_rleft=0,wi_rdelay=0;
  integer gate_bdelay=0,gate_index=0,final_b_held_cycles=0;
  logic wi_read_active=0,gate_aw_seen=0,gate_w_seen=0,gate_stored=0,final_b_pending=0;
  logic ordinary_phase=0,source_read_active=0;
  logic [63:0] held_gate_awaddr;logic [511:0] held_gate_wdata;
  localparam logic [63:0] WI_FIRST=64'h100001000,GATE_FIRST=64'h200001000;
  localparam logic [63:0] SOURCE_FIRST=64'h300001000;

  task automatic tick;@(posedge clk);#1;endtask
  task automatic make_context(output logic [95:0] c,input int task_id,input int op);
    c=0;c[31:0]=32'(task_id);c[39:32]=8'(op);c[47:40]=2;c[55:48]=0;
    c[63:56]=0;c[71:64]=0;c[87:72]=0;c[95:88]=1;
  endtask
  task automatic make_g_command;
    logic [95:0] p,q,l;
    service_command=0;
    make_context(p,1,8'h60);make_context(q,2,8'h20);make_context(l,3,8'h33);
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=4;service_command[GENERATION*8+:64]=64'd101;
    service_command[TASK*8+:32]=1;service_command[COMMAND_BEATS*8+:16]=CMD_BEATS;
    service_command[RESPONSE_BEATS*8+:16]=RSP_BEATS;
    service_command[IDENTITY*8+:64]=64'h100000001;
    service_command[(IDENTITY+8)*8+:64]=64'h200000001;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=64;
    service_command[CONTEXT*8+:96]=p;service_command[PRODUCER_CONTEXT*8+:96]=p;
    service_command[QUANT_CONTEXT*8+:96]=q;service_command[LINEAR_CONTEXT*8+:96]=l;
    service_command[SOURCE_REF*8+:64]=64'h0000000600000001;
    service_command[A_REF*8+:64]=64'h0000002200000001;
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000001;
    service_command[DST_REF*8+:64]=64'h0000000700000001;
    service_command[FUTURE_DST_REF*8+:64]=64'h0000000300000001;
    service_command[K*8+:16]=2624;service_command[N*8+:16]=1024;
    service_command[ROWS*8+:8]=1;service_command[A_SLOT*8]=0;service_command[W_SLOT*8]=0;
    service_command[A_EPOCH*8+:32]=1;service_command[W_EPOCH*8+:32]=1;
    service_command[WEIGHT_KEY*8+:16]=4;
    service_command[OUT0_ROLE*8+:8]=11;service_command[SOURCE_ROLE*8+:8]=10;
    service_command[OUTPUT_RANGES*8+:64]=latched_bo_span[11];
    service_command[(OUTPUT_RANGES+8)*8+:64]=64'h1000;
    service_command[(OUTPUT_RANGES+16)*8+:64]=64'h100000;
    service_command[ROW_STRIDE*8+:64]=10496;
    service_command[BATCH_STRIDE*8+:64]=10747904;
    service_command[SOURCE_OFFSET*8+:64]=64'h1000;
    service_command[SOURCE_SPAN*8+:64]=64'h200000;
    service_command[SOURCE_STRIDE*8+:64]=20992;
  endtask

  task automatic make_q_context(output logic [95:0] c,input int task_id,input int op);
    c=0;c[31:0]=32'(task_id);c[39:32]=8'(op);c[47:40]=6;c[55:48]=8'hff;
    c[63:56]=0;c[71:64]=2;c[87:72]=0;c[95:88]=1;
  endtask
  task automatic make_q_command;
    logic [95:0] p,q,l;
    service_command=0;
    make_q_context(p,4,8'h65);make_q_context(q,5,8'h20);make_q_context(l,6,8'h37);
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=2;service_command[GENERATION*8+:64]=64'd102;
    service_command[TASK*8+:32]=5;service_command[COMMAND_BEATS*8+:16]=CMD_BEATS;
    service_command[RESPONSE_BEATS*8+:16]=RSP_BEATS;
    service_command[IDENTITY*8+:64]=64'h100000001;
    service_command[(IDENTITY+8)*8+:64]=64'h200000001;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=64;
    service_command[CONTEXT*8+:96]=q;service_command[PRODUCER_CONTEXT*8+:96]=p;
    service_command[QUANT_CONTEXT*8+:96]=q;service_command[LINEAR_CONTEXT*8+:96]=l;
    service_command[SOURCE_REF*8+:64]=64'h0002000a00000001;
    service_command[A_REF*8+:64]=64'h0000002200000002;
    service_command[W_REF*8+:64]=64'h0000002300000002;
    service_command[PS_REF*8+:64]=64'h0000002400000002;
    service_command[DST_REF*8+:64]=service_command[A_REF*8+:64];
    service_command[FUTURE_DST_REF*8+:64]=64'h0004000a00000002;
    service_command[K*8+:16]=256;service_command[N*8+:16]=2;
    service_command[ROWS*8+:8]=1;service_command[A_SLOT*8]=0;service_command[W_SLOT*8]=0;
    service_command[A_EPOCH*8+:32]=2;service_command[W_EPOCH*8+:32]=2;
    service_command[WEIGHT_KEY*8+:16]=16'hff0c;
    service_command[SOURCE_ROLE*8+:8]=6;
    service_command[SOURCE_OFFSET*8+:64]=64'h1000;
    service_command[SOURCE_SPAN*8+:64]=64'h1000;
    service_command[SOURCE_STRIDE*8+:64]=1024;
    service_command[ROW_STRIDE*8+:64]=1024;
    service_command[BATCH_STRIDE*8+:64]=1024;
  endtask
  task automatic send_q;
    while(!q_service_command_ready)tick();
    @(negedge clk);q_service_command_valid=1;tick();
    @(negedge clk);q_service_command_valid=0;
  endtask

  assign wi_axi_physical_debt_zero=!wi_read_active && !wi_axi_rvalid;
  assign gate_write_physical_debt_zero=!gate_aw_seen && !gate_w_seen && !gate_stored &&
    !gate_axi_bvalid && gate_bdelay==0;
  assign gate_read_physical_debt_zero=!source_read_active && !gate_axi_rvalid;

  always @(negedge clk)begin
    wi_axi_arready=rst_n && !wi_read_active && !wi_axi_rvalid && cycles%5!=0;
    gate_axi_awready=rst_n && !gate_aw_seen && cycles%7!=0;
    gate_axi_wready=rst_n && !gate_w_seen && cycles%11!=0;
    gate_axi_arready=ordinary_phase && rst_n && !source_read_active &&
      !gate_axi_rvalid && cycles%5!=0;
    if(wi_read_active && !wi_axi_rvalid)begin
      if(wi_rdelay>0)wi_rdelay=wi_rdelay-1;
      else begin
        wi_axi_rvalid=1;wi_axi_rresp=0;wi_axi_rlast=wi_rleft==1;
        for(int lane=0;lane<16;lane++)wi_axi_rdata[lane*32+:32]=wi_fixture[wi_rindex*16+lane];
      end
    end
    if(gate_bdelay>0)begin
      gate_bdelay=gate_bdelay-1;
      if(final_b_pending)final_b_held_cycles=final_b_held_cycles+1;
      if(gate_bdelay==0)begin gate_axi_bvalid=1;gate_axi_bresp=0;end
    end
    if(source_read_active && !gate_axi_rvalid)begin
      if(read_delay>0)read_delay=read_delay-1;
      else begin
        gate_axi_rvalid=1;gate_axi_rresp=0;gate_axi_rlast=read_left==1;
        for(int lane=0;lane<16;lane++)
          gate_axi_rdata[lane*32+:32]=source_mem[read_index*16+lane];
      end
    end
  end

  always @(posedge clk)begin
    cycles=cycles+1;
    if(cycles>400000)$fatal(1,"source switch pilot cycle cap phase=%0d owner=%0d",dut.split.phase,gate_owner_state);
    progress_work=wi_r_count+gate_b_count+source_r;
    if(cycles%20000==0 && progress_work>last_progress_work)begin
      last_progress_work=progress_work;
      $display("FULL_CURRENT_GATE_QUANT_PORTAL_PROGRESS work=%0d wi_R=%0d gate_B=%0d phase=%0d owner=%0d",
        progress_work,wi_r_count,gate_b_count,dut.split.phase,gate_owner_state);
    end
    if(!rst_n)begin
      wi_read_active=0;wi_axi_rvalid=0;wi_rindex=0;wi_rleft=0;wi_rdelay=0;
      gate_aw_seen=0;gate_w_seen=0;gate_stored=0;gate_axi_bvalid=0;gate_bdelay=0;
      final_b_pending=0;final_b_held_cycles=0;
      source_read_active=0;gate_axi_rvalid=0;read_index=0;read_left=0;read_delay=0;
    end else begin
      if(wi_axi_arvalid && wi_axi_arready)begin
        if(wi_read_active || wi_axi_arsize!=6 || wi_axi_arburst!=1 ||
           wi_axi_araddr<WI_FIRST || wi_axi_araddr+64'(wi_axi_arlen+1)*64>WI_FIRST+20992 ||
           wi_axi_araddr[11:0]+(int'(wi_axi_arlen)+1)*64>4096)
          $fatal(1,"portal WI AR invalid addr=%h len=%0d",wi_axi_araddr,wi_axi_arlen);
        wi_read_active=1;wi_rindex=int'((wi_axi_araddr-WI_FIRST)>>6);
        wi_rleft=int'(wi_axi_arlen)+1;wi_rdelay=1;wi_ar_count=wi_ar_count+1;
      end
      if(wi_axi_rvalid && wi_axi_rready)begin
        // Deassert in the NBA region so the DUT and peer agree on the beat
        // sampled at this edge.  A blocking deassert here races the DUT.
        wi_axi_rvalid<=0;wi_rindex=wi_rindex+1;wi_rleft=wi_rleft-1;
        wi_r_count=wi_r_count+1;wi_rdelay=1+(wi_r_count%3);
        if(wi_rleft==0)wi_read_active=0;
      end
      if(gate_axi_awvalid && gate_axi_awready)begin
        if(gate_aw_seen || gate_axi_awlen!=0 || gate_axi_awsize!=6 || gate_axi_awburst!=1)
          $fatal(1,"portal GATE AW protocol");
        gate_aw_seen=1;held_gate_awaddr=gate_axi_awaddr;gate_aw_count=gate_aw_count+1;
      end
      if(gate_axi_wvalid && gate_axi_wready)begin
        if(gate_w_seen || gate_axi_wstrb!==64'hffffffffffffffff || !gate_axi_wlast)
          $fatal(1,"portal GATE W protocol");
        gate_w_seen=1;held_gate_wdata=gate_axi_wdata;gate_w_count=gate_w_count+1;
      end
      if(gate_aw_seen && gate_w_seen && !gate_stored)begin
        int row,col;
        gate_index=int'((held_gate_awaddr-GATE_FIRST)>>6);
        if(held_gate_awaddr<GATE_FIRST || gate_index<0 || gate_index>=164 ||
           held_gate_awaddr!==GATE_FIRST+64'(gate_index)*64)
          $fatal(1,"portal GATE address addr=%h index=%0d",held_gate_awaddr,gate_index);
        row=gate_index/164;
        for(int lane=0;lane<16;lane++)begin
          col=(gate_index%164)*16+lane;
          if(held_gate_wdata[lane*32+:32]!==gate_gold[row*2624+col])
            $fatal(1,"portal GATE gold row=%0d col=%0d",row,col);
        end
        gate_stored=1;
        if(gate_index==163)begin gate_bdelay=12;final_b_pending=1;end
        else gate_bdelay=2+(gate_index%3);
      end
      if(final_b_pending && !gate_axi_bvalid && g_service_completion_valid)
        $fatal(1,"portal response visible before held final B");
      if(gate_axi_bvalid && gate_axi_bready)begin
        // As above, preserve BVALID through the active sampling region.
        gate_axi_bvalid<=0;gate_aw_seen=0;gate_w_seen=0;gate_stored=0;
        gate_b_count=gate_b_count+1;if(final_b_pending)final_b_pending=0;
      end
      if(gate_axi_arvalid && gate_axi_arready)begin
        if(!ordinary_phase || source_read_active || gate_axi_arsize!=6 ||
           gate_axi_arburst!=1 || gate_axi_araddr<SOURCE_FIRST ||
           gate_axi_araddr+64'(gate_axi_arlen+1)*64>SOURCE_FIRST+1024 ||
           gate_axi_araddr[11:0]+(int'(gate_axi_arlen)+1)*64>4096)
          $fatal(1,"ordinary source AR addr=%h len=%0d",gate_axi_araddr,gate_axi_arlen);
        source_read_active=1;read_index=int'((gate_axi_araddr-SOURCE_FIRST)>>6);
        read_left=int'(gate_axi_arlen)+1;read_delay=1;source_ar=source_ar+1;
      end
      if(gate_axi_rvalid && gate_axi_rready)begin
        gate_axi_rvalid<=0;read_index=read_index+1;read_left=read_left-1;
        source_r=source_r+1;read_delay=1+(source_r%3);
        if(read_left==0)source_read_active=0;
      end
      if(!ordinary_phase && gate_axi_arvalid)$fatal(1,"portal G issued GATE read before Q command");
      if(!ordinary_phase && q_service_completion_valid)$fatal(1,"portal Q completion without Q command");
      if(ordinary_phase && (wi_axi_arvalid || gate_axi_awvalid || gate_axi_wvalid))
        $fatal(1,"ordinary Q reused GEGLU/WI/GATE writer path");
    end
  end

  task automatic acquire_a;
    a_acquire_slot=0;a_acquire_slot_epoch=2;a_acquire_K=256;a_acquire_rows=1;
    a_acquire_numeric_identity=service_command[IDENTITY*8+:672];
    a_acquire_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_acquire_a_ref=service_command[A_REF*8+:64];
    a_acquire_w_ref=service_command[W_REF*8+:64];
    a_acquire_dst_ref=service_command[FUTURE_DST_REF*8+:64];a_acquire_valid=1;
    while(!a_acquire_ready)tick();tick();
    if(!a_acquire_done || a_acquire_error)$fatal(1,"switch ordinary A acquire");
    @(negedge clk);a_acquire_valid=0;
  endtask
  task automatic check_group(input int group);
    logic [255:0] expected;
    for(int lane=0;lane<32;lane++)expected[lane*8+:8]=q_gold[group*32+lane];
    @(negedge clk);a_read_slot=0;a_read_slot_epoch=2;
    a_read_numeric_identity=service_command[IDENTITY*8+:672];
    a_read_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_read_a_ref=service_command[A_REF*8+:64];a_read_row_block_base=0;
    a_read_rows=1;a_read_group=7'(group);a_read_valid=1;
    while(!a_read_ready)tick();tick();if(a_read_error)$fatal(1,"switch ordinary A read");
    @(negedge clk);a_read_valid=0;while(!a_ret_valid)tick();
    if(a_ret_group!=group || a_ret_rows!=1 || a_ret_row_block_base!=0 ||
       a_ret_q[0]!==expected || a_ret_scale[0]!==scale_gold[group] ||
       a_ret_q[1]!==0 || a_ret_q[2]!==0 || a_ret_q[3]!==0)
      $fatal(1,"switch ordinary A payload group=%0d",group);
    @(negedge clk);a_ret_ready=1;tick();
    @(negedge clk);a_ret_ready=0;a_groups_checked=a_groups_checked+1;
  endtask
  task automatic release_a;
    a_release_slot=0;a_release_slot_epoch=2;
    a_release_numeric_identity=service_command[IDENTITY*8+:672];
    a_release_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_release_a_ref=service_command[A_REF*8+:64];a_release_valid=1;
    while(!a_release_ready)tick();tick();
    if(!a_release_done || a_release_error || !a_read_debt_zero)
      $fatal(1,"switch ordinary A release");
    @(negedge clk);a_release_valid=0;
  endtask

  initial begin
    g_service_cancel=0;q_service_cancel=0;
    g_service_command_valid=0;q_service_command_valid=0;
    service_command=0;g_service_completion_ready=0;q_service_completion_ready=0;
    latched_bo_base=0;latched_bo_span=0;
    latched_bo_base[10]=64'h100000000;latched_bo_span[10]=64'h4000000;
    latched_bo_base[11]=64'h200000000;latched_bo_span[11]=64'h4000000;
    latched_bo_base[6]=64'h300000000;latched_bo_span[6]=64'h4000000;
    wi_axi_arready=0;wi_axi_rdata=0;wi_axi_rresp=0;wi_axi_rlast=0;wi_axi_rvalid=0;
    gate_axi_awready=0;gate_axi_wready=0;gate_axi_bresp=0;gate_axi_bvalid=0;
    gate_axi_arready=0;gate_axi_rdata=0;gate_axi_rresp=0;gate_axi_rlast=0;gate_axi_rvalid=0;
    a_acquire_valid=0;a_acquire_slot=0;a_acquire_slot_epoch=0;a_acquire_K=0;a_acquire_rows=0;
    a_acquire_numeric_identity=0;a_acquire_linear_context=0;a_acquire_a_ref=0;
    a_acquire_w_ref=0;a_acquire_dst_ref=0;a_read_valid=0;a_read_slot=0;
    a_read_slot_epoch=0;a_read_numeric_identity=0;a_read_linear_context=0;a_read_a_ref=0;
    a_read_row_block_base=0;a_read_rows=0;a_read_group=0;a_ret_ready=0;
    a_release_valid=0;a_release_slot=0;a_release_slot_epoch=0;a_release_numeric_identity=0;
    a_release_linear_context=0;a_release_a_ref=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"source switch fixture path");
    $readmemh({fixture,"/wi.mem"},wi_fixture);$readmemh({fixture,"/gate.mem"},gate_gold);
    $readmemh({fixture,"/source.mem"},source_mem);$readmemh({fixture,"/q.mem"},q_gold);
    $readmemh({fixture,"/scale.mem"},scale_gold);
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(15)tick();
    make_g_command();#1;
    if(!g_service_command_ready)$fatal(1,"legal portal G command not ready");
    g_service_command_valid=1;tick();@(negedge clk);g_service_command_valid=0;
    while(!g_service_completion_valid)tick();
    if(!response_binding_ok(g_service_completion,service_command) ||
       g_service_completion[OP_STATUS*8+:16]!=0 ||
       g_service_completion[ELEMENTS*8+:32]!=2624 ||
       g_service_completion[UNIT*8+:8]!=1 ||
       g_service_completion[COUNTERS*8+:32]!=6 ||
       g_service_completion[(COUNTERS+4)*8+:32]!=328 ||
       g_service_completion[(COUNTERS+8)*8+:32]!=1 ||
       g_service_completion[(COUNTERS+12)*8+:32]!=164 ||
       g_service_completion[(COUNTERS+16)*8+:32]!=164 ||
       g_service_completion[(COUNTERS+20)*8+:32]!=164)
      $fatal(1,"portal G response/counters invalid AR=%0d R=%0d AW=%0d W=%0d B=%0d",
        wi_ar_count,wi_r_count,gate_aw_count,gate_w_count,gate_b_count);
    if(final_b_held_cycles<10 || gate_owner_state!=1 ||
       dut.quant_starts!=0 || dut.source_ar_count!=0)
      $fatal(1,"portal G terminal state hold=%0d owner=%0d qstarts=%0d qar=%0d",
        final_b_held_cycles,gate_owner_state,dut.quant_starts,dut.source_ar_count);
    repeat(4)begin tick();if(!g_service_completion_valid)$fatal(1,"portal G response not held");end
    @(negedge clk);g_service_completion_ready=1;tick();@(negedge clk);g_service_completion_ready=0;
    if(gate_owner_state!=1 || gate_covered_rows[0]!==1'b1)
      $fatal(1,"portal G ledger did not retire with response handshake owner=%0d covered=%h",
        gate_owner_state,gate_covered_rows[15:0]);
    repeat(31)begin
      tick();
      if(gate_axi_arvalid || dut.quant_starts!=0 || dut.source_ar_count!=0)
        $fatal(1,"portal G fused Q without Q command");
    end
    ordinary_phase=1;source_query_granted=1;source_release_ready=1;
    make_q_command();send_q();while(!q_service_completion_valid)tick();
    if(!response_binding_ok(q_service_completion,service_command) ||
       q_service_completion[OP_STATUS*8+:16]!=0 ||
       q_service_completion[ELEMENTS*8+:32]!=8 ||
       q_service_completion[UNIT*8+:8]!=2 ||
       q_service_completion[COUNTERS*8+:32]!=1 ||
       q_service_completion[(COUNTERS+4)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+8)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+12)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+16)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+20)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+24)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+28)*8+:32]!=8)
      $fatal(1,"switch ordinary response/counters AR=%0d R=%0d",source_ar,source_r);
    if(gate_owner_state!=1 || dut.split.q_gate_source || a_slot_state[0]!=2 ||
       a_slot_rows_done[0]!=1 || !q_source_lease_active)
      $fatal(1,"switch ordinary source route contaminated by resident GATE state");
    repeat(5)begin tick();if(!q_service_completion_valid)$fatal(1,"switch Q response not held");end
    @(negedge clk);q_service_completion_ready=1;tick();
    @(negedge clk);q_service_completion_ready=0;
    acquire_a();for(int group=0;group<8;group++)check_group(group);release_a();
    $display("FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_PASS no_reset=1 G_commands=1 G_rows=1 WI_AR=%0d WI_R=%0d GATE_AW=%0d GATE_W=%0d GATE_B=%0d held_final_B_cycles=%0d ordinary_Q_commands=1 ordinary_role=6 ordinary_K=256 source_AR=%0d source_R=%0d fullA_groups_checked=%0d gate_owner_resident=1 gate_lease_used_by_ordinary=0 unique_quant_instance=1 cycles=%0d",
      wi_ar_count,wi_r_count,gate_aw_count,gate_w_count,gate_b_count,
      final_b_held_cycles,source_ar,source_r,a_groups_checked,cycles);
    $finish;
  end
endmodule
