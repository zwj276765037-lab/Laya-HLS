`timescale 1ns/1ps
module quant_f32_two_row_feeder_tb_v1;
  logic clk,rst_n;
  logic cfg_valid;
  logic cfg_ready,cfg_reject;
  logic cfg_owner_admitted,cfg_source_published;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_producer_context,cfg_quant_context;
  logic [63:0] cfg_source_ref;
  logic [12:0] cfg_K;
  logic [4:0] cfg_rows;
  logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span;
  logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes;
  logic [63:0] m_axi_araddr;
  logic [7:0] m_axi_arlen;
  logic [2:0] m_axi_arsize;
  logic [1:0] m_axi_arburst;
  logic m_axi_arvalid;
  logic m_axi_arready;
  logic [511:0] m_axi_rdata;
  logic [1:0] m_axi_rresp;
  logic m_axi_rlast,m_axi_rvalid;
  logic m_axi_rready;
  logic row_start_valid;
  logic row_start_ready;
  logic [31:0] row_cfg_task_id,row_cfg_source_epoch;
  logic [15:0] row_cfg_row;
  logic [7:0] row_cfg_groups;
  logic in_valid;
  logic in_ready;
  logic [511:0] in_lanes;
  logic [31:0] in_task_id,in_source_epoch;
  logic [15:0] in_row;
  logic [6:0] in_group;
  logic in_half;
  logic [15:0] in_mask;
  logic row_done_valid;
  logic row_done_ready;
  logic [1:0] row_done_status;
  logic [15:0] row_done_bad_col;
  logic row_done_debt_zero;
  logic done_valid;
  logic done_ready;
  logic [2:0] done_status;
  logic [63:0] done_bad_element;
  logic debt_zero;
  logic [31:0] ar_count,r_count,complete_rows,quant_starts,input_beats,quant_rows;
  logic [1:0][2:0] slot_state;
  quant_f32_two_row_feeder_v1 dut(.*);
  initial clk=0;always #3.333 clk=~clk;
  integer cycles=0,verified=0,starts=0,stall_checks=0,both_slots=0;
  logic bus_active;
  logic [63:0] bus_addr;
  logic [7:0] bus_len,bus_index;
  logic qactive;
  integer qbeats,qrow,qdelay;
  integer inject_bad_row=-1,inject_num_row=-1;
  logic [511:0] held_lanes;
  logic [6:0] held_group;
  logic held_half,held_valid;
  function automatic logic [31:0] word_gold(input logic [63:0] address);
    return 32'h3f000000 | (32'(address>>2)^32'h003ac517)&32'h007fffff;
  endfunction
  function automatic logic [511:0] beat_gold(input logic [63:0] address);
    logic [511:0] v;
    for(int lane=0;lane<16;lane++)v[lane*32+:32]=word_gold(address+64'(lane)*4);
    return v;
  endfunction
  always @(negedge clk) begin
    m_axi_arready=rst_n && !bus_active && cycles%5!=0;
    m_axi_rvalid=bus_active && cycles%7!=0;
    m_axi_rdata=beat_gold(bus_addr+64'(bus_index)*64);
    m_axi_rlast=bus_index==bus_len;
    m_axi_rresp=(inject_bad_row>=0 && bus_addr>=cfg_region_base+64'(inject_bad_row)*cfg_row_stride_bytes && bus_addr<cfg_region_base+64'(inject_bad_row+1)*cfg_row_stride_bytes && bus_index==bus_len) ? 2 : 0;
    row_start_ready=rst_n && !qactive && qdelay==0 && !row_done_valid;
    in_ready=qactive && cycles%4!=0 && cycles%11!=0;
    if(qdelay>0)begin
      qdelay=qdelay-1;
      if(qdelay==0)begin row_done_valid=1;row_done_status=qrow==inject_num_row ? 1 : 0;row_done_bad_col=cfg_K-1;row_done_debt_zero=1;end
    end
  end
  always @(posedge clk) begin
    cycles=cycles+1;if(cycles>200000)$fatal(1,"cycle budget");
    if(!rst_n)begin bus_active=0;bus_addr=0;bus_len=0;bus_index=0;qactive=0;qdelay=0;qbeats=0;qrow=0;held_valid=0;end
    else begin
      if(m_axi_arvalid && m_axi_arready)begin
        if(bus_active || m_axi_arsize!=6 || m_axi_arburst!=1 || m_axi_araddr[5:0]!=0 ||
          13'(m_axi_araddr[11:0])+13'(m_axi_arlen+1)*64>4096 ||
          m_axi_araddr<cfg_region_base || m_axi_araddr+64'(m_axi_arlen+1)*64>cfg_region_base+cfg_region_span ||
          m_axi_araddr<cfg_bo_base || m_axi_araddr+64'(m_axi_arlen+1)*64>cfg_bo_base+cfg_bo_span)
          $fatal(1,"AR address/4KiB/bounds");
        bus_active=1;bus_addr=m_axi_araddr;bus_len=m_axi_arlen;bus_index=0;
      end else if(m_axi_rvalid && m_axi_rready)begin
        if(!bus_active)$fatal(1,"response without AR");
        if(bus_index==bus_len)bus_active=0;else bus_index=bus_index+1;
      end
      if(slot_state[0]!=0 && slot_state[1]!=0)both_slots=both_slots+1;
      if(row_start_valid && row_start_ready)begin
        if(qactive || row_cfg_task_id!=cfg_quant_context[31:0] || row_cfg_source_epoch!=cfg_source_ref[31:0] || row_cfg_groups!=cfg_K/32 ||
          row_cfg_row!=cfg_quant_context[87:72]+starts || complete_rows<=starts)
          $fatal(1,"row start before complete capture/identity");
        qactive=1;qrow=starts;qbeats=0;starts=starts+1;
      end
      if(held_valid)begin
        stall_checks=stall_checks+1;
        if(!in_valid || in_lanes!==held_lanes || in_group!==held_group || in_half!==held_half) $fatal(1,"quant input changed while stalled");
      end
      held_valid=in_valid && !in_ready;
      if(held_valid)begin held_lanes=in_lanes;held_group=in_group;held_half=in_half;end
      if(in_valid && in_ready)begin
        if(!qactive || in_task_id!=cfg_quant_context[31:0] || in_source_epoch!=cfg_source_ref[31:0] ||
          in_row!=cfg_quant_context[87:72]+qrow || in_group!=qbeats/2 || in_half!=(qbeats%2) || in_mask!=16'hffff ||
          in_lanes!==beat_gold(cfg_region_base+64'(cfg_quant_context[63:56])*cfg_batch_stride_bytes+64'(in_row)*cfg_row_stride_bytes+64'(qbeats)*64))
          $fatal(1,"quant source/order/identity mismatch row=%0d beat=%0d",qrow,qbeats);
        qbeats=qbeats+1;verified=verified+16;
        if(qbeats==cfg_K/16)begin qactive=0;qdelay=17;end
      end
      if(row_done_valid && row_done_ready)begin row_done_valid<=0;end
    end
  end
  task automatic tick;@(posedge clk);#1;endtask
  task automatic configure(input int kval,input int nrows,input int globalrow);
    @(negedge clk);cfg_K=13'(kval);cfg_rows=5'(nrows);starts=0;verified=0;
    cfg_numeric_identity=672'hf123456789abcdef00000000100000001;
    cfg_numeric_identity[127:64]=64'h200000001;cfg_numeric_identity[143:128]=1;cfg_numeric_identity[159:144]=128;
    cfg_quant_context=0;cfg_quant_context[31:0]=32'h80000002;cfg_quant_context[47:40]=kval==256 ? 6 : kval==4096 ? 4 : 2;
    cfg_quant_context[71:64]=kval==256 ? 2 : 0;cfg_quant_context[87:72]=16'(globalrow);cfg_quant_context[95:88]=8'(nrows);
    cfg_producer_context=cfg_quant_context;cfg_producer_context[31:0]=32'h80000001;
    cfg_source_ref=0;cfg_source_ref[31:0]=32'h80000001;cfg_source_ref[39:32]=kval==256 ? 10 : kval==2624 ? 7 : kval==4096 ? 9 : 2;cfg_source_ref[55:48]=kval==256 ? 2 : 0;
    cfg_bo_base=64'h100000000;cfg_bo_span=64'h4000000;cfg_region_base=cfg_bo_base+64'h1000;cfg_region_span=64'h2000000;
    cfg_row_stride_bytes=64'(kval)*4;cfg_batch_stride_bytes=cfg_row_stride_bytes*(kval==256 ? 1 : 1024);
    cfg_owner_admitted=1;cfg_source_published=1;cfg_valid=1;
    while(!cfg_ready)tick();tick();if(cfg_reject)$fatal(1,"legal command rejected");
    @(negedge clk);cfg_valid=0;
  endtask
  task automatic await_done(input int status);
    while(!done_valid)tick();
    if(done_status!=status || !debt_zero || bus_active)$fatal(1,"done status/debts got=%0d want=%0d",done_status,status);
    if(status==0 && (quant_rows!=cfg_rows || complete_rows!=cfg_rows || input_beats!=cfg_rows*(cfg_K/16) || verified!=cfg_rows*cfg_K))$fatal(1,"task coverage");
    repeat(9)begin tick();if(!done_valid || done_status!=status)$fatal(1,"held task result");end
    @(negedge clk);done_ready=1;tick();@(negedge clk);done_ready=0;
  endtask
  initial begin
    rst_n=0;cfg_valid=0;cfg_owner_admitted=0;cfg_source_published=0;cfg_numeric_identity=0;cfg_producer_context=0;cfg_quant_context=0;cfg_source_ref=0;cfg_K=0;cfg_rows=0;
    cfg_bo_base=0;cfg_bo_span=0;cfg_region_base=0;cfg_region_span=0;cfg_row_stride_bytes=0;cfg_batch_stride_bytes=0;
    m_axi_arready=0;m_axi_rdata=0;m_axi_rresp=0;m_axi_rlast=0;m_axi_rvalid=0;row_start_ready=0;in_ready=0;
    row_done_valid=0;row_done_status=0;row_done_bad_col=0;row_done_debt_zero=0;done_ready=0;
    repeat(4)tick();@(negedge clk);rst_n=1;
    configure(4096,16,1);await_done(0);
    configure(2624,4,124);await_done(0);
    configure(1024,1,127);await_done(0);
    configure(256,1,0);await_done(0);
    inject_bad_row=1;configure(2624,4,0);await_done(3);
    if(starts>1)$fatal(1,"failed source row offered to quant");
    inject_bad_row=-1;inject_num_row=3;configure(2624,4,0);await_done(1);
    if(done_bad_element!=3*4096+2623)$fatal(1,"quant original bad_element");
    inject_num_row=-1;configure(1024,1,0);await_done(0);
    // Invalid physical/logical bounds reject before AR.
    @(negedge clk);cfg_bo_span=64;cfg_valid=1;tick();if(!cfg_reject || m_axi_arvalid)$fatal(1,"bad bounds accepted");@(negedge clk);cfg_valid=0;
    // Reset in a live endpoint cancellation domain then reload a new task.
    configure(4096,4,0);while(!bus_active)tick();@(negedge clk);rst_n=0;row_done_valid=0;repeat(4)tick();@(negedge clk);rst_n=1;tick();
    if(!debt_zero || done_valid || m_axi_arvalid || in_valid)$fatal(1,"reset cancel");
    configure(256,1,0);await_done(0);
    $display("QUANT_F32_TWO_ROW_PASS storage_bytes=32768 K_cases=4 rows16=1 response_complete_barrier=1 stalls=%0d dual_slot_cycles=%0d read_error=1 late_quant_error=1 bounds=1 reset_recovery=1 cycles=%0d",stall_checks,both_slots,cycles);
    $finish;
  end
endmodule
