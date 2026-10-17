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
  int parent_completions=0,parent_completion_baseline=0;
  int aw_count=0,w_count=0,b_count=0,zero_words=0;
  bit allow_a=1,allow_w=1,hold_a_lease=0,hold_w_lease=0,hold_a_read=0,hold_w_read=0,hold_b=1;
  bit a_pending=0,w_pending=0,a_active=0,w_active=0,ar_pending=0,wr_pending=0;
  bit aw_seen=0,w_seen=0;
  bit inject_all_poison=0;
  bit checked_poison_coverage=0;
  logic [63:0] write_address;
  logic [511:0] write_data;
  logic [63:0] write_strobe;
  logic [63:0] expected_write_address,expected_write_strobe;
  logic [63:0] injected_parent_rank;
  logic [31:0] injected_parent_bad;
  bit parent_write_mode=0;
  int parent_write_beat=0,parent_write_row_block=0;
  int previous_state=-1;
  assign a_acquire_ready=rst_n && allow_a && !a_pending && !a_active;
  assign w_lease_ready=rst_n && allow_w && !w_pending && !w_active;
  assign a_read_ready=rst_n && a_active && !ar_pending;
  assign w_read_ready=rst_n && w_active && !wr_pending;
  assign a_read_error=0;assign w_read_error=0;
  assign a_release_ready=rst_n && a_active && !ar_pending;
  assign w_release_ready=rst_n && w_active && !wr_pending;
  assign a_read_debt_zero=!ar_pending;
  // Persistent parent pins are ownership, not outstanding physical traffic.
  assign physical_debt_zero=!a_pending && !w_pending &&
      !ar_pending && !wr_pending && !aw_seen && !w_seen && !m_axi_bvalid[0];
  assign m_axi_awready=2'b01;assign m_axi_wready=2'b01;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;
    if(dut.matrix.state!=previous_state)begin
      $display("FULL_CURRENT_MATRIX_BINDING_PROGRESS cycles=%0d command=%0d state=%0d A=%b/%b/%b W=%b/%b/%b release=%b/%b/%b leased=%b fault=%b",cycles,commands,dut.matrix.state,a_pending,a_active,ar_pending,w_pending,w_active,wr_pending,w_release_valid,w_release_ready,w_release_done,dut.matrix.w_leased,dut.matrix.protocol_fault);
      previous_state=dut.matrix.state;
      if(dut.matrix.state==3 || dut.matrix.state==8 || dut.matrix.state==12)
        $display("FULL_CURRENT_MATRIX_NUMERIC_DIAG rank=%0d numeric=%b parent_invalid=%b writer_cancel=%b configured=%b elements=%0d copies=%0d bias=%0d",dut.matrix.front_rank,dut.matrix.numeric_fault,dut.cfg_target_invalidated,dut.matrix.writers[0].writer.publication_cancelled,dut.matrix.writers[0].writer.configured,dut.matrix.writers[0].writer.accepted_elements,dut.matrix.actual_final_copies,dut.matrix.bias_committed);
    end
    if(cycles>200000)$fatal(1,"binding cycle cap state=%0d command=%0d W=%b/%b/%b release=%b/%b/%b leased=%b",dut.matrix.state,commands,w_pending,w_active,wr_pending,w_release_valid,w_release_ready,w_release_done,dut.matrix.w_leased);
    if(dut.ledger_parent_complete)parent_completions++;
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
      if(a_ret_valid && a_ret_ready && !dut.matrix.a_return_ok)
        $display("FULL_CURRENT_MATRIX_A_RETURN_MISMATCH slot=%0d/%0d epoch=%0d/%0d id=%b ctx=%b ref=%h/%h row=%0d/%0d rows=%0d/%0d group=%0d/%0d",
          a_ret_slot,dut.matrix.a_slot,a_ret_slot_epoch,dut.matrix.a_epoch,
          a_ret_numeric_identity==dut.matrix.numeric_id,a_ret_linear_context==dut.matrix.parent_context,
          a_ret_a_ref,dut.matrix.a_ref,a_ret_row_block_base,dut.matrix.row_block_base,
          a_ret_rows,dut.matrix.rows,a_ret_group,dut.matrix.group_index);
      if(dut.matrix.state==4 && (dut.matrix.front_protocol || dut.matrix.adapter_protocol ||
          dut.matrix.bias_protocol || (|dut.matrix.writer_fault)))
        $display("FULL_CURRENT_MATRIX_EARLY_PROTOCOL front=%b adapter=%b bias=%b writer=%b",
          dut.matrix.front_protocol,dut.matrix.adapter_protocol,dut.matrix.bias_protocol,dut.matrix.writer_fault);
      if(w_read_valid && w_read_ready)begin
        wr_pending<=1;w_ret_slot<=w_read_slot;w_ret_pair<=w_read_pair;w_ret_epoch<=w_read_epoch;
        w_ret_tile<=w_read_tile;w_ret_group<=w_read_group;w_ret_model_identity<=w_read_model_identity;
        w_ret_numeric_identity<=w_read_numeric_identity;w_ret_task_context<=w_read_task_context;
        w_ret_q<=0;w_ret_bias<=0;w_ret_mask<=0;
        w_ret_mask[0]<=service_command[N*8+:16]==2 ? 8'h03 : 8'hff;
        for(int s=0;s<2;s++)for(int n=0;n<8;n++)w_ret_scale[s][n]<=16'h3c00;
        if(inject_all_poison && w_read_group==0)begin
          w_ret_scale[0][0]<=16'h7e00;w_ret_scale[0][1]<=16'h7e00;
        end
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
        if(write_address!=expected_write_address || write_strobe!=expected_write_strobe || write_data!==0)
          $fatal(1,"independent diagnostic zero output/address/strobe address=%h/%h strobe=%h/%h",
            write_address,expected_write_address,write_strobe,expected_write_strobe);
        zero_words+=$countones(write_strobe)/4;b_count++;m_axi_bvalid[0]<=0;aw_seen<=0;w_seen<=0;
        if(parent_write_mode)begin
          parent_write_beat<=parent_write_beat+1;
          expected_write_address<=64'h200001000+
            64'((parent_write_row_block+((parent_write_beat+1)%4))*4096)+
            64'((((parent_write_beat+1)/4)/2)*64);
          expected_write_strobe<=(((parent_write_beat+1)/4)&1) ? 64'hffffffff00000000 : 64'h00000000ffffffff;
        end
      end
      if(m_axi_awvalid[1] || m_axi_wvalid[1])$fatal(1,"unexpected second shard");
      if(dut.owner_retire_valid && !physical_debt_zero)$fatal(1,"owner offered with physical debt");
      if(dut.owner_retire_valid && commands==8)begin
        if(!dut.matrix.adapter_coverage || dut.matrix.adapter_protocol ||
           dut.matrix.final_adapter.retired_packets!=1)$fatal(1,"all-poison final sequence incomplete at real retirement");
        checked_poison_coverage=1;
      end
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
    service_command[(CONTEXT+5)*8+:8]=6;service_command[(CONTEXT+6)*8+:8]=255;service_command[(CONTEXT+8)*8+:8]=2;
    service_command[(CONTEXT+11)*8+:8]=1;
    service_command[SOURCE_REF*8+:64]=64'h0000000a00000001;
    service_command[A_REF*8+:64]=64'h0000002200000001;
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000000|64'(epoch);
    service_command[DST_REF*8+:64]=64'h0004000a00000000|64'(epoch);
    service_command[LINEAR_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[QUANT_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[QUANT_CONTEXT*8+:32]=32'(90+epoch);service_command[(QUANT_CONTEXT+4)*8+:8]=8'h20;
    service_command[PRODUCER_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[PRODUCER_CONTEXT*8+:32]=32'(80+epoch);service_command[(PRODUCER_CONTEXT+4)*8+:8]=8'h61;
    service_command[FUTURE_DST_REF*8+:64]=service_command[DST_REF*8+:64];
    service_command[MODEL_IDENTITY*8+:3328]=0;
    service_command[K*8+:16]=256;service_command[N*8+:16]=2;
    service_command[ROWS*8+:8]=1;service_command[A_EPOCH*8+:32]=1;service_command[W_EPOCH*8+:32]=1;
    service_command[OUT0_ROLE*8+:8]=6;
    service_command[OUTPUT_RANGES*8+:64]=64'h10000;
    service_command[(OUTPUT_RANGES+8)*8+:64]=4096;service_command[(OUTPUT_RANGES+16)*8+:64]=64;
    service_command[ROW_STRIDE*8+:64]=8;service_command[BATCH_STRIDE*8+:64]=8;
    expected_write_address=64'h100001000;expected_write_strobe=64'hff;
    parent_write_mode=0;parent_write_beat=0;parent_write_row_block=0;
    service_cancel=0;service_completion_ready=0;service_command_valid=1;
    #1;if(!command_frame_ok(service_command))$fatal(1,"diagnostic packet framing");
    while(!service_command_ready)tick();tick();@(negedge clk);service_command_valid=0;
  endtask
  task automatic parent_command(input int portal_generation,input int request_id,input int task_id,
      input int resource_epoch,input int dst_epoch,input int row_block);
    int byte_offset;
    @(negedge clk);service_command=0;
    service_command[MAGIC*8+:32]=CMD_MAGIC;service_command[VER*8+:16]=VERSION;
    service_command[OP_STATUS*8+:16]=3;service_command[GENERATION*8+:64]=64'(portal_generation);
    service_command[TASK*8+:32]=32'(task_id);
    service_command[COMMAND_BEATS*8+:16]=16;service_command[RESPONSE_BEATS*8+:16]=8;
    service_command[IDENTITY*8+:64]=64'(request_id);service_command[(IDENTITY+8)*8+:64]=1;
    service_command[(IDENTITY+16)*8+:16]=1;service_command[(IDENTITY+18)*8+:16]=128;
    service_command[CONTEXT*8+:32]=32'(task_id);service_command[(CONTEXT+4)*8+:8]=8'h36;
    service_command[(CONTEXT+5)*8+:8]=6;service_command[(CONTEXT+6)*8+:8]=255;
    service_command[(CONTEXT+8)*8+:8]=1;service_command[(CONTEXT+11)*8+:8]=16;
    service_command[SOURCE_REF*8+:64]=64'h0000000600000000|64'(resource_epoch);
    service_command[A_REF*8+:64]=64'h0000002200000000|64'(resource_epoch);
    service_command[W_REF*8+:64]=64'h0000002300000001;
    service_command[PS_REF*8+:64]=64'h0000002400000000|64'(resource_epoch);
    service_command[DST_REF*8+:64]=64'h0000000a00000000|64'(dst_epoch);
    service_command[LINEAR_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[QUANT_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[QUANT_CONTEXT*8+:32]=32'(task_id-1);service_command[(QUANT_CONTEXT+4)*8+:8]=8'h20;
    service_command[PRODUCER_CONTEXT*8+:96]=service_command[CONTEXT*8+:96];
    service_command[PRODUCER_CONTEXT*8+:32]=32'(task_id-2);service_command[(PRODUCER_CONTEXT+4)*8+:8]=8'h61;
    service_command[FUTURE_DST_REF*8+:64]=service_command[DST_REF*8+:64];
    service_command[MODEL_IDENTITY*8+:3328]=0;
    service_command[K*8+:16]=1024;service_command[N*8+:16]=1024;
    service_command[ROWS*8+:8]=4;service_command[ROW_BLOCK*8+:8]=8'(row_block);
    service_command[A_EPOCH*8+:32]=32'(resource_epoch);service_command[W_EPOCH*8+:32]=1;
    service_command[OUT0_ROLE*8+:8]=10;
    service_command[OUTPUT_RANGES*8+:64]=64'h100000;
    service_command[(OUTPUT_RANGES+8)*8+:64]=4096;service_command[(OUTPUT_RANGES+16)*8+:64]=65536;
    service_command[ROW_STRIDE*8+:64]=4096;service_command[BATCH_STRIDE*8+:64]=65536;
    byte_offset=(row_block*4096)&63;
    expected_write_address=64'h200001000+64'(row_block*4096);
    expected_write_strobe=64'h00000000ffffffff;
    parent_write_mode=1;parent_write_beat=0;parent_write_row_block=row_block;
    service_cancel=0;service_completion_ready=0;service_command_valid=1;
    #1;if(!command_frame_ok(service_command))$fatal(1,"parent packet framing");
    while(!service_command_ready)tick();tick();@(negedge clk);service_command_valid=0;
    if(dut.parent_a.active_generation!=portal_generation || dut.parent_w.active_generation!=portal_generation)
      $fatal(1,"parent command generation was not latched independently g=%0d A=%0d W=%0d",
        portal_generation,dut.parent_a.active_generation,dut.parent_w.active_generation);
  endtask
  task automatic inject_parent_rank(input logic [63:0] rank,input logic [31:0] bad);
    while(!dut.matrix.configured)tick();
    injected_parent_rank=rank;injected_parent_bad=bad;
    force dut.matrix.front_rank=injected_parent_rank;force dut.matrix.front_bad=injected_parent_bad;
    tick();
    release dut.matrix.front_rank;release dut.matrix.front_bad;
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
  task automatic parent_response(input int status,input bit published,input logic [63:0] rank);
    while(!service_completion_valid)tick();
    if(!response_binding_ok(service_completion,service_command) ||
       service_completion[OP_STATUS*8+:16]!=status || service_completion[RETIRE_FLAGS*8+1]!=published ||
       service_completion[RANK*8+:64]!=rank)
      $fatal(1,"parent response status=%0d/%0d publish=%0d/%0d rank=%0d/%0d g=%0d row=%0d",
        service_completion[OP_STATUS*8+:16],status,service_completion[RETIRE_FLAGS*8+1],published,
        service_completion[RANK*8+:64],rank,service_completion[GENERATION*8+:64],
        service_completion[RESPONSE_ROW_BLOCK*8+:8]);
    repeat(5)begin tick();if(!service_completion_valid)$fatal(1,"parent response not held");end
    @(negedge clk);service_completion_ready=1;tick();@(negedge clk);service_completion_ready=0;
    repeat(4)tick();if(!service_command_ready)$fatal(1,"parent binding did not recover idle");
  endtask
  initial begin
    rst_n=0;service_cancel=0;service_command=0;service_command_valid=0;service_completion_ready=0;
    latched_bo_base=0;latched_bo_span=0;latched_bo_base[6]=64'h100000000;latched_bo_span[6]=64'h10000;
    latched_bo_base[10]=64'h200000000;latched_bo_span[10]=64'h100000;
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
    inject_all_poison=1;command(8);
    wait(service_completion_valid);#1;
    if(service_completion[RANK*8+:64]!=0 || service_completion[BAD_ELEMENT*8+:64]!=0 ||
       dut.matrix.protocol_fault || dut.matrix.frontend.skip_rows_count!=7 ||
       dut.matrix.actual_final_copies!=0 || !checked_poison_coverage)
      $fatal(1,"all-poison final skip/rank changed rank=%0d skip=%0d copies=%0d protocol=%b",service_completion[RANK*8+:64],dut.matrix.frontend.skip_rows_count,dut.matrix.actual_final_copies,dut.matrix.protocol_fault);
    response(6,0);inject_all_poison=0;
    command(9);response(0,1);
    if(commands!=9 || replies!=9 || a_acquires!=8 || a_releases!=8 || w_acquires!=7 || w_releases!=7 ||
       aw_count!=3 || w_count!=3 || b_count!=3 || zero_words!=6 || dut.ledger_publications!=2)
      $fatal(1,"coverage counters cmd=%0d rsp=%0d A=%0d/%0d W=%0d/%0d AW/W/B=%0d/%0d/%0d",commands,replies,a_acquires,a_releases,w_acquires,w_releases,aw_count,w_count,b_count);
    if($test$plusargs("PILOT"))begin
      $display("FULL_CURRENT_MATRIX_BINDING_PILOT_PASS commands=%0d replies=%0d A_leases=%0d W_leases=%0d AW=%0d W=%0d B=%0d cycles=%0d",
        commands,replies,a_acquires,w_acquires,aw_count,w_count,b_count,cycles);
      $finish;
    end
    parent_completion_baseline=parent_completions;
    // One successful rows16 parent: four commands have distinct portal g while
    // the full parent L and all stable entity bindings remain identical.
    hold_a_lease=1;hold_w_lease=1;parent_command(10,2,200,10,1,0);
    while(!a_pending)tick();repeat(4)tick();hold_a_lease=0;
    while(!w_pending)tick();repeat(4)tick();hold_w_lease=0;
    parent_response(0,1,'1);
    if(!a_active || !w_active || !dut.parent_a.parent_pinned || !dut.parent_w.parent_pinned)
      $fatal(1,"parent leases did not survive view0");
    hold_a_read=1;parent_command(11,2,200,10,1,4);while(!ar_pending)tick();repeat(4)tick();hold_a_read=0;
    parent_response(0,1,'1);
    hold_w_read=1;parent_command(12,2,200,10,1,8);while(!wr_pending)tick();repeat(4)tick();hold_w_read=0;
    parent_response(0,1,'1);
    parent_command(13,2,200,10,1,12);while(dut.matrix.actual_b_count[0]<511)tick();hold_b=1;
    while(!aw_seen || !w_seen)tick();repeat(7)tick();hold_b=0;
    parent_response(0,1,'1);
    if(a_active || w_active || dut.parent_a.parent_live || dut.parent_w.parent_live ||
       parent_completions!=parent_completion_baseline+1 || dut.ledger_publications!=3 || dut.ledger_tensor_publications!=3)
      $fatal(1,"successful rows16 parent did not retire once complete=%0d parent_pub=%0d tensor_pub=%0d",
        parent_completions,dut.ledger_publications,dut.ledger_tensor_publications);
    // Cancellation while the portal is idle but the next parent remains pinned.
    parent_command(14,3,300,11,2,0);parent_response(0,1,'1);
    if(!dut.parent_a.parent_pinned || !dut.parent_w.parent_pinned)$fatal(1,"inter-view parent was not pinned");
    cancel_now();
    repeat(20)begin tick();if(service_completion_valid)$fatal(1,"inter-view cancel fabricated response");end
    if(a_active || w_active || dut.parent_a.parent_live || dut.parent_w.parent_live)
      $fatal(1,"inter-view cancel did not drain/release parent");
    if(parent_completions!=parent_completion_baseline+1)
      $fatal(1,"inter-view cancel fabricated parent TaskDone");
    // A later request in the same session recovers. Controlled rank injection
    // checks sticky min-rank merge while all four real views still execute.
    parent_command(15,4,400,12,3,0);inject_parent_rank(64'd2112000,32'h1111);parent_response(6,0,64'd2112000);
    parent_command(16,4,400,12,3,4);inject_parent_rank(64'd5280,32'h2222);parent_response(6,0,64'd5280);
    parent_command(17,4,400,12,3,8);parent_response(6,0,64'd5280);
    parent_command(18,4,400,12,3,12);parent_response(6,0,64'd5280);
    if(commands!=18 || replies!=18 || a_acquires!=11 || a_releases!=11 ||
       w_acquires!=10 || w_releases!=10 || aw_count!=2563 || w_count!=2563 || b_count!=2563 ||
       zero_words!=20486 || parent_completions!=parent_completion_baseline+2 ||
       dut.ledger_publications!=3 || dut.ledger_tensor_publications!=3)
      $fatal(1,"parent integration counters cmd=%0d rsp=%0d A=%0d/%0d W=%0d/%0d AW/W/B=%0d/%0d/%0d words=%0d parent_pub=%0d tensor_pub=%0d",
        commands,replies,a_acquires,a_releases,w_acquires,w_releases,aw_count,w_count,b_count,zero_words,
        dut.ledger_publications,dut.ledger_tensor_publications);
    $display("FULL_CURRENT_MATRIX_BINDING_PASS commands=%0d replies=%0d cancel_cases=6 normal_recovery=2 all_poison_final_skip=1 numerical_rank=0 parent_views=9 distinct_view_generations=9 parent_taskdone=2 inter_view_cancel=1 controlled_cross_view_rank=5280 A_leases=%0d W_leases=%0d AW=%0d W=%0d B=%0d independent_zero_words=%0d cycles=%0d",commands,replies,a_acquires,w_acquires,aw_count,w_count,b_count,zero_words,cycles);
    $finish;
  end
endmodule
