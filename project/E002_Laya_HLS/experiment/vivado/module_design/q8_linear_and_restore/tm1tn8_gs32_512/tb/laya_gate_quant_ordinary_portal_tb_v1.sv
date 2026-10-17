`timescale 1ns/1ps
module laya_gate_quant_ordinary_portal_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk=0,rst_n=0;always #3.333 clk=~clk;
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

  string fixture;
  logic [31:0] source_mem[0:255];logic [7:0] q_gold[0:255];logic [15:0] scale_gold[0:7];
  integer cycles=0,source_ar=0,source_r=0,read_index=0,read_left=0,read_delay=0;
  integer a_groups_checked=0;
  logic read_active=0;
  localparam logic [63:0] SOURCE_FIRST=64'h300001000;
  task automatic tick;@(posedge clk);#1;endtask
  task automatic make_context(output logic [95:0] c,input int task_id,input int op);
    c=0;c[31:0]=32'(task_id);c[39:32]=8'(op);c[47:40]=6;c[55:48]=8'hff;
    c[63:56]=0;c[71:64]=2;c[87:72]=0;c[95:88]=1;
  endtask
  task automatic make_q_command(input longint generation);
    logic [95:0] p,q,l;
    service_command=0;make_context(p,1,8'h65);make_context(q,2,8'h20);make_context(l,3,8'h37);
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=2;service_command[GENERATION*8+:64]=64'(generation);
    service_command[TASK*8+:32]=2;service_command[COMMAND_BEATS*8+:16]=CMD_BEATS;
    service_command[RESPONSE_BEATS*8+:16]=RSP_BEATS;
    service_command[IDENTITY*8+:64]=64'h100000001;
    service_command[(IDENTITY+8)*8+:64]=64'h200000001;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=64;
    service_command[CONTEXT*8+:96]=q;service_command[PRODUCER_CONTEXT*8+:96]=p;
    service_command[QUANT_CONTEXT*8+:96]=q;service_command[LINEAR_CONTEXT*8+:96]=l;
    service_command[SOURCE_REF*8+:64]=64'h0002000a00000001;
    service_command[A_REF*8+:64]=64'h0000002200000001;
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000001;
    service_command[DST_REF*8+:64]=service_command[A_REF*8+:64];
    service_command[FUTURE_DST_REF*8+:64]=64'h0004000a00000002;
    service_command[K*8+:16]=256;service_command[N*8+:16]=2;
    service_command[ROWS*8+:8]=1;service_command[A_SLOT*8]=0;service_command[W_SLOT*8]=0;
    service_command[A_EPOCH*8+:32]=1;service_command[W_EPOCH*8+:32]=1;
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
    @(negedge clk);q_service_command_valid=1;tick();@(negedge clk);q_service_command_valid=0;
  endtask

  assign wi_axi_physical_debt_zero=1;
  assign gate_write_physical_debt_zero=1;
  assign gate_read_physical_debt_zero=!read_active && !gate_axi_rvalid;
  always @(negedge clk)begin
    gate_axi_arready=rst_n && !read_active && !gate_axi_rvalid && cycles%5!=0;
    if(read_active && !gate_axi_rvalid)begin
      if(read_delay>0)read_delay=read_delay-1;
      else begin
        gate_axi_rvalid=1;gate_axi_rresp=0;gate_axi_rlast=read_left==1;
        for(int lane=0;lane<16;lane++)gate_axi_rdata[lane*32+:32]=source_mem[read_index*16+lane];
      end
    end
  end
  always @(posedge clk)begin
    cycles=cycles+1;if(cycles>100000)$fatal(1,"ordinary Q cycle cap phase=%0d",dut.split.phase);
    if(!rst_n)begin read_active=0;gate_axi_rvalid=0;read_index=0;read_left=0;read_delay=0;end
    else begin
      if(gate_axi_arvalid && gate_axi_arready)begin
        if(read_active || gate_axi_arsize!=6 || gate_axi_arburst!=1 ||
           gate_axi_araddr<SOURCE_FIRST ||
           gate_axi_araddr+64'(gate_axi_arlen+1)*64>SOURCE_FIRST+1024 ||
           gate_axi_araddr[11:0]+(int'(gate_axi_arlen)+1)*64>4096)
          $fatal(1,"ordinary Q source AR addr=%h len=%0d",gate_axi_araddr,gate_axi_arlen);
        read_active=1;read_index=int'((gate_axi_araddr-SOURCE_FIRST)>>6);
        read_left=int'(gate_axi_arlen)+1;read_delay=1;source_ar=source_ar+1;
      end
      if(gate_axi_rvalid && gate_axi_rready)begin
        gate_axi_rvalid<=0;read_index=read_index+1;read_left=read_left-1;
        source_r=source_r+1;read_delay=1+(source_r%3);if(read_left==0)read_active=0;
      end
      if(wi_axi_arvalid || gate_axi_awvalid || gate_axi_wvalid)
        $fatal(1,"ordinary Q activated GEGLU/WI/GATE writer");
      if(g_service_completion_valid)$fatal(1,"ordinary Q produced G completion");
    end
  end

  task automatic acquire_a;
    a_acquire_slot=0;a_acquire_slot_epoch=1;a_acquire_K=256;a_acquire_rows=1;
    a_acquire_numeric_identity=service_command[IDENTITY*8+:672];
    a_acquire_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_acquire_a_ref=service_command[A_REF*8+:64];a_acquire_w_ref=service_command[W_REF*8+:64];
    a_acquire_dst_ref=service_command[FUTURE_DST_REF*8+:64];a_acquire_valid=1;
    while(!a_acquire_ready)tick();tick();
    if(!a_acquire_done || a_acquire_error)$fatal(1,"ordinary Q A acquire");
    @(negedge clk);a_acquire_valid=0;
  endtask
  task automatic check_group(input int group);
    logic [255:0] expected;
    for(int lane=0;lane<32;lane++)expected[lane*8+:8]=q_gold[group*32+lane];
    @(negedge clk);a_read_slot=0;a_read_slot_epoch=1;
    a_read_numeric_identity=service_command[IDENTITY*8+:672];
    a_read_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_read_a_ref=service_command[A_REF*8+:64];a_read_row_block_base=0;
    a_read_rows=1;a_read_group=7'(group);a_read_valid=1;
    while(!a_read_ready)tick();tick();if(a_read_error)$fatal(1,"ordinary Q A read admission");
    @(negedge clk);a_read_valid=0;while(!a_ret_valid)tick();
    if(a_ret_group!=group || a_ret_rows!=1 || a_ret_row_block_base!=0 ||
       a_ret_q[0]!==expected || a_ret_scale[0]!==scale_gold[group] ||
       a_ret_q[1]!==0 || a_ret_q[2]!==0 || a_ret_q[3]!==0)
      $fatal(1,"ordinary Q A payload group=%0d got_scale=%h want=%h",group,a_ret_scale[0],scale_gold[group]);
    @(negedge clk);a_ret_ready=1;tick();@(negedge clk);a_ret_ready=0;a_groups_checked=a_groups_checked+1;
  endtask
  task automatic release_a;
    a_release_slot=0;a_release_slot_epoch=1;
    a_release_numeric_identity=service_command[IDENTITY*8+:672];
    a_release_linear_context=service_command[LINEAR_CONTEXT*8+:96];
    a_release_a_ref=service_command[A_REF*8+:64];a_release_valid=1;
    while(!a_release_ready)tick();tick();
    if(!a_release_done || a_release_error || !a_read_debt_zero)$fatal(1,"ordinary Q A release");
    @(negedge clk);a_release_valid=0;
  endtask

  initial begin
    g_service_cancel=0;q_service_cancel=0;
    g_service_command_valid=0;q_service_command_valid=0;service_command=0;
    g_service_completion_ready=0;q_service_completion_ready=0;
    latched_bo_base=0;latched_bo_span=0;
    latched_bo_base[6]=64'h300000000;latched_bo_span[6]=64'h4000000;
    wi_axi_arready=0;wi_axi_rdata=0;wi_axi_rresp=0;wi_axi_rlast=0;wi_axi_rvalid=0;
    gate_axi_awready=0;gate_axi_wready=0;gate_axi_bresp=0;gate_axi_bvalid=0;
    gate_axi_arready=0;gate_axi_rdata=0;gate_axi_rresp=0;gate_axi_rlast=0;gate_axi_rvalid=0;
    a_acquire_valid=0;a_acquire_slot=0;a_acquire_slot_epoch=0;a_acquire_K=0;a_acquire_rows=0;
    a_acquire_numeric_identity=0;a_acquire_linear_context=0;a_acquire_a_ref=0;a_acquire_w_ref=0;a_acquire_dst_ref=0;
    a_read_valid=0;a_read_slot=0;a_read_slot_epoch=0;a_read_numeric_identity=0;
    a_read_linear_context=0;a_read_a_ref=0;a_read_row_block_base=0;a_read_rows=0;a_read_group=0;a_ret_ready=0;
    a_release_valid=0;a_release_slot=0;a_release_slot_epoch=0;a_release_numeric_identity=0;
    a_release_linear_context=0;a_release_a_ref=0;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"ordinary Q fixture path");
    $readmemh({fixture,"/source.mem"},source_mem);$readmemh({fixture,"/q.mem"},q_gold);
    $readmemh({fixture,"/scale.mem"},scale_gold);
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(20)tick();

    make_q_command(201);send_q();while(!q_service_completion_valid)tick();
    if(q_service_completion[OP_STATUS*8+:16]!=5 || source_ar!=0 || gate_axi_arvalid)
      $fatal(1,"ordinary Q missing-provenance admission");
    @(negedge clk);q_service_completion_ready=1;tick();@(negedge clk);q_service_completion_ready=0;

    make_q_command(202);source_query_granted=1;source_release_ready=1;send_q();
    while(!q_service_completion_valid)tick();
    if(!response_binding_ok(q_service_completion,service_command) ||
       q_service_completion[OP_STATUS*8+:16]!=0 ||
       q_service_completion[ELEMENTS*8+:32]!=8 || q_service_completion[UNIT*8+:8]!=2 ||
       q_service_completion[COUNTERS*8+:32]!=1 ||
       q_service_completion[(COUNTERS+4)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+8)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+12)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+16)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+20)*8+:32]!=1 ||
       q_service_completion[(COUNTERS+24)*8+:32]!=16 ||
       q_service_completion[(COUNTERS+28)*8+:32]!=8)
      $fatal(1,"ordinary Q response/counters AR=%0d R=%0d state=%0d rows=%h",
        source_ar,source_r,a_slot_state[0],a_slot_rows_done[0]);
    if(gate_owner_state!=0 || dut.split.q_gate_source || a_slot_state[0]!=2 ||
       a_slot_rows_done[0]!=1 || !q_persistent_active)
      $fatal(1,"ordinary Q did not use direct shared quant/fullA path");
    repeat(5)begin tick();if(!q_service_completion_valid)$fatal(1,"ordinary Q response not held");end
    @(negedge clk);q_service_completion_ready=1;tick();@(negedge clk);q_service_completion_ready=0;
    acquire_a();for(int group=0;group<8;group++)check_group(group);release_a();
    $display("FULL_CURRENT_GATE_QUANT_ORDINARY_PORTAL_PASS rejected_unpublished=1 Q_commands=1 K=256 rows=1 source_AR=%0d source_R=%0d quant_groups=8 half_commits=16 scale_commits=8 fullA_groups_checked=%0d gate_lease_used=0 unique_quant_instance=1 cycles=%0d",
      source_ar,source_r,a_groups_checked,cycles);
    $finish;
  end
endmodule
