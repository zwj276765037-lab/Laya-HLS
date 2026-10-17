`timescale 1ns/1ps
// Real binding/resident/native-FP control regression with controlled A/W lease
// endpoints and a real accepted-write/B ledger. Diagnostic zero operands are
// independent smoke inputs; this is not physical-cache or full-model proof.
module laya_matrix_portal_binding_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic  clk;
  logic  rst_n;
  logic  service_cancel;
  logic  service_command_valid;
  logic  service_command_ready;
  logic [8191:0] service_command;
  logic  service_completion_valid;
  logic  service_completion_ready;
  logic [4095:0] service_completion;
  logic  physical_debt_zero;
  logic [12:0][63:0] latched_bo_base;
  logic [12:0][63:0] latched_bo_span;
  logic [1:0][3:0] output_bo_role;
  logic [1:0][63:0] m_axi_awaddr;
  logic [1:0][7:0] m_axi_awlen;
  logic [1:0][2:0] m_axi_awsize;
  logic [1:0][1:0] m_axi_awburst;
  logic [1:0] m_axi_awvalid;
  logic [1:0] m_axi_awready;
  logic [1:0][511:0] m_axi_wdata;
  logic [1:0][63:0] m_axi_wstrb;
  logic [1:0] m_axi_wlast;
  logic [1:0] m_axi_wvalid;
  logic [1:0] m_axi_wready;
  logic [1:0][1:0] m_axi_bresp;
  logic [1:0] m_axi_bvalid;
  logic [1:0] m_axi_bready;
  logic  a_acquire_valid;
  logic  a_acquire_ready;
  logic  a_acquire_done;
  logic  a_acquire_error;
  logic  a_acquire_slot;
  logic [31:0] a_acquire_slot_epoch;
  logic [12:0] a_acquire_K;
  logic [4:0] a_acquire_rows;
  logic [671:0] a_acquire_numeric_identity;
  logic [95:0] a_acquire_linear_context;
  logic [63:0] a_acquire_a_ref;
  logic [63:0] a_acquire_w_ref;
  logic [63:0] a_acquire_dst_ref;
  logic  a_read_valid;
  logic  a_read_ready;
  logic  a_read_error;
  logic  a_read_slot;
  logic [31:0] a_read_slot_epoch;
  logic [671:0] a_read_numeric_identity;
  logic [95:0] a_read_linear_context;
  logic [63:0] a_read_a_ref;
  logic [3:0] a_read_row_block_base;
  logic [2:0] a_read_rows;
  logic [6:0] a_read_group;
  logic  a_ret_valid;
  logic  a_ret_ready;
  logic  a_ret_slot;
  logic [31:0] a_ret_slot_epoch;
  logic [671:0] a_ret_numeric_identity;
  logic [95:0] a_ret_linear_context;
  logic [63:0] a_ret_a_ref;
  logic [3:0] a_ret_row_block_base;
  logic [2:0] a_ret_rows;
  logic [6:0] a_ret_group;
  logic [3:0][255:0] a_ret_q;
  logic [3:0][15:0] a_ret_scale;
  logic  a_release_valid;
  logic  a_release_ready;
  logic  a_release_done;
  logic  a_release_error;
  logic  a_release_slot;
  logic [31:0] a_release_slot_epoch;
  logic [671:0] a_release_numeric_identity;
  logic [95:0] a_release_linear_context;
  logic [63:0] a_release_a_ref;
  logic  a_read_debt_zero;
  logic  w_lease_valid;
  logic  w_lease_ready;
  logic  w_lease_done;
  logic  w_lease_error;
  logic  w_lease_slot;
  logic [31:0] w_lease_epoch;
  logic [31:0] w_lease_k;
  logic [31:0] w_lease_n;
  logic [15:0] w_lease_weight_key;
  logic [3327:0] w_lease_model_identity;
  logic [671:0] w_lease_numeric_identity;
  logic [95:0] w_lease_task_context;
  logic  w_read_valid;
  logic  w_read_ready;
  logic  w_read_error;
  logic  w_read_slot;
  logic [31:0] w_read_epoch;
  logic [15:0] w_read_tile;
  logic [7:0] w_read_group;
  logic  w_read_pair;
  logic [3327:0] w_read_model_identity;
  logic [671:0] w_read_numeric_identity;
  logic [95:0] w_read_task_context;
  logic  w_ret_valid;
  logic  w_ret_ready;
  logic  w_ret_slot;
  logic  w_ret_pair;
  logic [31:0] w_ret_epoch;
  logic [15:0] w_ret_tile;
  logic [7:0] w_ret_group;
  logic [3327:0] w_ret_model_identity;
  logic [671:0] w_ret_numeric_identity;
  logic [95:0] w_ret_task_context;
  logic [1:0][7:0][255:0] w_ret_q;
  logic [1:0][7:0][15:0] w_ret_scale;
  logic [1:0][7:0][31:0] w_ret_bias;
  logic [1:0][7:0] w_ret_mask;
  logic  w_release_valid;
  logic  w_release_ready;
  logic  w_release_done;
  logic  w_release_error;
  logic  w_release_slot;
  logic [31:0] w_release_epoch;
  logic [671:0] w_release_numeric_identity;
  logic [95:0] w_release_task_context;
  laya_matrix_portal_binding_v1 dut(
    .clk,
    .rst_n,
    .service_cancel,
    .service_command_valid,
    .service_command_ready,
    .service_command,
    .service_completion_valid,
    .service_completion_ready,
    .service_completion,
    .physical_debt_zero,
    .latched_bo_base,
    .latched_bo_span,
    .output_bo_role,
    .m_axi_awaddr,
    .m_axi_awlen,
    .m_axi_awsize,
    .m_axi_awburst,
    .m_axi_awvalid,
    .m_axi_awready,
    .m_axi_wdata,
    .m_axi_wstrb,
    .m_axi_wlast,
    .m_axi_wvalid,
    .m_axi_wready,
    .m_axi_bresp,
    .m_axi_bvalid,
    .m_axi_bready,
    .a_acquire_valid,
    .a_acquire_ready,
    .a_acquire_done,
    .a_acquire_error,
    .a_acquire_slot,
    .a_acquire_slot_epoch,
    .a_acquire_K,
    .a_acquire_rows,
    .a_acquire_numeric_identity,
    .a_acquire_linear_context,
    .a_acquire_a_ref,
    .a_acquire_w_ref,
    .a_acquire_dst_ref,
    .a_read_valid,
    .a_read_ready,
    .a_read_error,
    .a_read_slot,
    .a_read_slot_epoch,
    .a_read_numeric_identity,
    .a_read_linear_context,
    .a_read_a_ref,
    .a_read_row_block_base,
    .a_read_rows,
    .a_read_group,
    .a_ret_valid,
    .a_ret_ready,
    .a_ret_slot,
    .a_ret_slot_epoch,
    .a_ret_numeric_identity,
    .a_ret_linear_context,
    .a_ret_a_ref,
    .a_ret_row_block_base,
    .a_ret_rows,
    .a_ret_group,
    .a_ret_q,
    .a_ret_scale,
    .a_release_valid,
    .a_release_ready,
    .a_release_done,
    .a_release_error,
    .a_release_slot,
    .a_release_slot_epoch,
    .a_release_numeric_identity,
    .a_release_linear_context,
    .a_release_a_ref,
    .a_read_debt_zero,
    .w_lease_valid,
    .w_lease_ready,
    .w_lease_done,
    .w_lease_error,
    .w_lease_slot,
    .w_lease_epoch,
    .w_lease_k,
    .w_lease_n,
    .w_lease_weight_key,
    .w_lease_model_identity,
    .w_lease_numeric_identity,
    .w_lease_task_context,
    .w_read_valid,
    .w_read_ready,
    .w_read_error,
    .w_read_slot,
    .w_read_epoch,
    .w_read_tile,
    .w_read_group,
    .w_read_pair,
    .w_read_model_identity,
    .w_read_numeric_identity,
    .w_read_task_context,
    .w_ret_valid,
    .w_ret_ready,
    .w_ret_slot,
    .w_ret_pair,
    .w_ret_epoch,
    .w_ret_tile,
    .w_ret_group,
    .w_ret_model_identity,
    .w_ret_numeric_identity,
    .w_ret_task_context,
    .w_ret_q,
    .w_ret_scale,
    .w_ret_bias,
    .w_ret_mask,
    .w_release_valid,
    .w_release_ready,
    .w_release_done,
    .w_release_error,
    .w_release_slot,
    .w_release_epoch,
    .w_release_numeric_identity,
    .w_release_task_context
  );

  initial clk=0;always #5 clk=~clk;
  int cycles=0,commands=0,replies=0,a_acquires=0,w_acquires=0,a_releases=0,w_releases=0;
  int aw_count=0,w_count=0,b_count=0,zero_words=0;
  bit allow_a=1,allow_w=1,hold_a_lease=0,hold_w_lease=0,hold_a_read=0,hold_w_read=0,hold_b=1;
  bit a_pending=0,w_pending=0,a_active=0,w_active=0,ar_pending=0,wr_pending=0;
  bit aw_seen=0,w_seen=0;
  logic [63:0] write_address;
  logic [511:0] write_data;
  logic [63:0] write_strobe;
  assign a_acquire_ready=rst_n && allow_a && !a_pending && !a_active;
  assign w_lease_ready=rst_n && allow_w && !w_pending && !w_active;
  assign a_read_ready=rst_n && a_active && !ar_pending;
  assign w_read_ready=rst_n && w_active && !wr_pending;
  assign a_read_error=0;assign w_read_error=0;
  assign a_release_ready=rst_n && a_active && !ar_pending;
  assign w_release_ready=rst_n && w_active && !wr_pending;
  assign a_read_debt_zero=!ar_pending;
  assign physical_debt_zero=!a_pending && !w_pending && !a_active && !w_active &&
      !ar_pending && !wr_pending && !aw_seen && !w_seen && !m_axi_bvalid[0];
  assign m_axi_awready=2'b01;assign m_axi_wready=2'b01;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;
    if(cycles>10000)$fatal(1,"binding cycle cap state=%0d command=%0d",dut.matrix.state,commands);
    if(!rst_n)begin
      a_acquire_done<=0;w_lease_done<=0;a_release_done<=0;w_release_done<=0;
      a_acquire_error<=0;w_lease_error<=0;a_release_error<=0;w_release_error<=0;
      a_ret_valid<=0;w_ret_valid<=0;m_axi_bvalid<=0;m_axi_bresp<=0;
      a_pending<=0;w_pending<=0;a_active<=0;w_active<=0;ar_pending<=0;wr_pending<=0;
      aw_seen<=0;w_seen<=0;
    end else begin
      a_acquire_done<=0;w_lease_done<=0;a_release_done<=0;w_release_done<=0;
      if(service_command_valid && service_command_ready)commands++;
      if(service_completion_valid && service_completion_ready)replies++;
      if(a_acquire_valid && a_acquire_ready)begin
        if(a_active || a_pending)$fatal(1,"duplicate A acquire");
        a_pending<=1;a_acquires++;
      end
      if(a_pending && !hold_a_lease)begin a_pending<=0;a_active<=1;a_acquire_done<=1;end
      if(w_lease_valid && w_lease_ready)begin
        if(w_active || w_pending)$fatal(1,"duplicate W lease");
        w_pending<=1;w_acquires++;
      end
      if(w_pending && !hold_w_lease)begin w_pending<=0;w_active<=1;w_lease_done<=1;end
      if(a_read_valid && a_read_ready)begin
        ar_pending<=1;a_ret_slot<=a_read_slot;a_ret_slot_epoch<=a_read_slot_epoch;
        a_ret_numeric_identity<=a_read_numeric_identity;a_ret_linear_context<=a_read_linear_context;
        a_ret_a_ref<=a_read_a_ref;a_ret_row_block_base<=a_read_row_block_base;
        a_ret_rows<=a_read_rows;a_ret_group<=a_read_group;a_ret_q<=0;
        for(int r=0;r<4;r++)a_ret_scale[r]<=16'h3c00;
      end
      if(ar_pending && !hold_a_read && !a_ret_valid)a_ret_valid<=1;
      if(a_ret_valid && a_ret_ready)begin a_ret_valid<=0;ar_pending<=0;end
      if(w_read_valid && w_read_ready)begin
        wr_pending<=1;w_ret_slot<=w_read_slot;w_ret_pair<=w_read_pair;w_ret_epoch<=w_read_epoch;
        w_ret_tile<=w_read_tile;w_ret_group<=w_read_group;w_ret_model_identity<=w_read_model_identity;
        w_ret_numeric_identity<=w_read_numeric_identity;w_ret_task_context<=w_read_task_context;
        w_ret_q<=0;w_ret_bias<=0;w_ret_mask<=0;w_ret_mask[0]<=8'h03;
        for(int s=0;s<2;s++)for(int n=0;n<8;n++)w_ret_scale[s][n]<=16'h3c00;
      end
      if(wr_pending && !hold_w_read && !w_ret_valid)w_ret_valid<=1;
      if(w_ret_valid && w_ret_ready)begin w_ret_valid<=0;wr_pending<=0;end
      if(a_release_valid && a_release_ready)begin
        if(a_pending || ar_pending)$fatal(1,"A released before accepted work returns");
        a_active<=0;a_release_done<=1;a_releases++;
      end
      if(w_release_valid && w_release_ready)begin
        if(w_pending || wr_pending)$fatal(1,"W released before accepted work returns");
        w_active<=0;w_release_done<=1;w_releases++;
      end
      if(m_axi_awvalid[0] && m_axi_awready[0])begin
        if(aw_seen || m_axi_awlen[0]!=0 || m_axi_awsize[0]!=6 || m_axi_awburst[0]!=1)$fatal(1,"write AW framing");
        aw_seen<=1;write_address<=m_axi_awaddr[0];aw_count++;
      end
      if(m_axi_wvalid[0] && m_axi_wready[0])begin
        if(w_seen || !m_axi_wlast[0])$fatal(1,"write W framing");
        w_seen<=1;write_data<=m_axi_wdata[0];write_strobe<=m_axi_wstrb[0];w_count++;
      end
      if(aw_seen && w_seen && !hold_b && !m_axi_bvalid[0])m_axi_bvalid[0]<=1;
      if(m_axi_bvalid[0] && m_axi_bready[0])begin
        if(write_address!=64'h100001000 || write_strobe!=64'hff || write_data[63:0]!==64'd0)
          $fatal(1,"independent diagnostic zero output/address/strobe");
        zero_words+=2;b_count++;m_axi_bvalid[0]<=0;aw_seen<=0;w_seen<=0;
      end
      if(m_axi_awvalid[1] || m_axi_wvalid[1])$fatal(1,"unexpected second shard");
      if(dut.owner_retire_valid && !physical_debt_zero)$fatal(1,"owner offered with physical debt");
      if(service_completion_valid && !physical_debt_zero)$fatal(1,"completion before physical retirement");
    end
  end
  task automatic command(input int epoch);
    @(negedge clk);service_command=0;
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=3;service_command[GENERATION*8+:64]=64'(epoch);
    service_command[TASK*8+:32]=32'(100+epoch);
    service_command[COMMAND_BEATS*8+:16]=16;service_command[RESPONSE_BEATS*8+:16]=8;
    service_command[IDENTITY*8+:64]=1;service_command[(IDENTITY+8)*8+:64]=1;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=128;
    service_command[CONTEXT*8+:32]=32'(100+epoch);service_command[(CONTEXT+4)*8+:8]=8'h37;
    service_command[(CONTEXT+5)*8+:8]=6;service_command[(CONTEXT+8)*8+:8]=2;
    service_command[(CONTEXT+11)*8+:8]=1;
    service_command[SOURCE_REF*8+:64]=64'h0000000a00000001;
    service_command[A_REF*8+:64]=64'h0000002200000001;
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000000|64'(epoch);
    service_command[DST_REF*8+:64]=64'h0004000a00000000|64'(epoch);
    service_command[MODEL_IDENTITY*8+:3328]=0;
    service_command[K*8+:16]=256;service_command[N*8+:16]=2;
    service_command[ROWS*8+:8]=1;service_command[A_EPOCH*8+:32]=1;service_command[W_EPOCH*8+:32]=1;
    service_command[OUT0_ROLE*8+:8]=6;
    service_command[OUTPUT_RANGES*8+:64]=64'h10000;
    service_command[(OUTPUT_RANGES+8)*8+:64]=4096;service_command[(OUTPUT_RANGES+16)*8+:64]=64;
    service_command[ROW_STRIDE*8+:64]=8;service_command[BATCH_STRIDE*8+:64]=8;
    service_cancel=0;service_completion_ready=0;service_command_valid=1;
    #1;if(!command_frame_ok(service_command))$fatal(1,"diagnostic packet framing");
    while(!service_command_ready)tick();tick();@(negedge clk);service_command_valid=0;
  endtask
  task automatic cancel_now;
    @(negedge clk);service_cancel=1;tick();@(negedge clk);service_cancel=0;
  endtask
  task automatic assert_blocked;
    repeat(7)begin tick();if(service_completion_valid || dut.owner_retire_valid)$fatal(1,"cancel retired pending physical operation");end
  endtask
  task automatic response(input int status,input bit published);
    while(!service_completion_valid)tick();
    if(!response_binding_ok(service_completion,service_command) ||
       service_completion[OP_STATUS*8+:16]!=status || service_completion[RETIRE_FLAGS*8+1]!=published)
      $fatal(1,"binding response status=%0d expected=%0d flags=%h",service_completion[OP_STATUS*8+:16],status,service_completion[RETIRE_FLAGS*8+:8]);
    repeat(5)begin tick();if(!service_completion_valid)$fatal(1,"response not held");end
    @(negedge clk);service_completion_ready=1;tick();@(negedge clk);service_completion_ready=0;
    repeat(4)tick();if(!service_command_ready)$fatal(1,"binding did not recover idle");
  endtask
  initial begin
    rst_n=0;service_cancel=0;service_command=0;service_command_valid=0;service_completion_ready=0;
    latched_bo_base=0;latched_bo_span=0;latched_bo_base[6]=64'h100000000;latched_bo_span[6]=64'h10000;
    repeat(6)tick();@(negedge clk);rst_n=1;repeat(20)tick();
    allow_a=0;command(1);cancel_now();response(7,0);allow_a=1;
    hold_a_lease=1;command(2);while(!a_pending)tick();cancel_now();assert_blocked();
    hold_a_lease=0;response(7,0);
    hold_w_lease=1;command(3);while(!w_pending)tick();cancel_now();assert_blocked();
    hold_w_lease=0;response(7,0);
    hold_a_read=1;command(4);while(!ar_pending)tick();cancel_now();assert_blocked();
    hold_a_read=0;response(7,0);
    hold_w_read=1;command(5);while(!wr_pending)tick();cancel_now();assert_blocked();
    hold_w_read=0;response(7,0);
    command(6);while(!aw_seen || !w_seen)tick();cancel_now();assert_blocked();hold_b=0;response(7,0);
    command(7);response(0,1);
    if(commands!=7 || replies!=7 || a_acquires!=6 || a_releases!=6 || w_acquires!=5 || w_releases!=5 ||
       aw_count!=2 || w_count!=2 || b_count!=2 || zero_words!=4 || dut.ledger_publications!=1)
      $fatal(1,"coverage counters cmd=%0d rsp=%0d A=%0d/%0d W=%0d/%0d AW/W/B=%0d/%0d/%0d",commands,replies,a_acquires,a_releases,w_acquires,w_releases,aw_count,w_count,b_count);
    $display("FULL_CURRENT_MATRIX_BINDING_PASS commands=%0d replies=%0d cancel_cases=6 normal_recovery=1 A_leases=%0d W_leases=%0d AW=%0d W=%0d B=%0d independent_zero_words=%0d cycles=%0d",commands,replies,a_acquires,w_acquires,aw_count,w_count,b_count,zero_words,cycles);
    $finish;
  end
endmodule
