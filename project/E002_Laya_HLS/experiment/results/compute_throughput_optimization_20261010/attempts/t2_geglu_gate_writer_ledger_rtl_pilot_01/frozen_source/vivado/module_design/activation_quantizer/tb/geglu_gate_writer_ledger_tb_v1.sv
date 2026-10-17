`timescale 1ns/1ps
module geglu_gate_writer_ledger_tb_v1;
  logic clk,rst_n;
  logic cfg_valid;
  logic cfg_ready,cfg_reject;
  logic cfg_owner_admitted;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_producer_context,cfg_quant_context,cfg_consumer_context;
  logic [63:0] cfg_source_ref,cfg_gate_ref,cfg_a_ref,cfg_w_ref,cfg_down_dst_ref;
  logic [4:0] cfg_rows;
  logic [63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span;
  logic row_success;
  logic [15:0] row_success_row;
  logic v_valid;
  logic v_ready;
  logic [31:0] v_data,v_status,v_frame_tag;
  logic [15:0] v_row;
  logic [12:0] v_col;
  logic v_last;
  logic row_write_done_valid;
  logic row_write_done_ready;
  logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch;
  logic [15:0] row_write_row;
  logic [63:0] row_write_bad_element;
  logic row_write_debt_zero;
  logic service_done_valid;
  logic service_done_ready;
  logic [31:0] service_done_status;
  logic [63:0] service_done_bad_element;
  logic [15:0] service_done_bad_row;
  logic service_read_debt_zero,service_arithmetic_debt_zero;
  logic producer_done_valid;
  logic producer_done_ready;
  logic [31:0] producer_done_status,producer_done_task_id,producer_done_dst_epoch;
  logic [63:0] producer_done_bad_element;
  logic [15:0] producer_done_covered_rows;
  logic producer_done_write_debt_zero;
  logic [2:0] gate_owner_state;
  logic gate_acquire_valid;
  logic gate_acquire_ready,gate_acquire_done,gate_acquire_error;
  logic [671:0] gate_acquire_numeric_identity;
  logic [95:0] gate_acquire_quant_context;
  logic [63:0] gate_acquire_ref;
  logic gate_release_valid;
  logic gate_release_ready,gate_release_done,gate_release_error;
  logic [671:0] gate_release_numeric_identity;
  logic [95:0] gate_release_quant_context;
  logic [63:0] gate_release_ref;
  logic gate_release_read_debt_zero;
  logic [671:0] bound_numeric_identity;
  logic [95:0] bound_quant_context,bound_consumer_context;
  logic [63:0] bound_gate_ref,bound_a_ref,bound_w_ref,bound_down_dst_ref;
  logic [31:0] aw_count,w_count,b_count,accepted_words;
  logic [63:0] useful_bytes,physical_bytes;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid;
  logic m_axi_awready;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic m_axi_wlast,m_axi_wvalid;
  logic m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic m_axi_bvalid;
  logic m_axi_bready;
  geglu_gate_writer_ledger_v1 dut(.*);
  initial clk=0;always #3.333 clk=~clk;
  integer cycles=0,checked=0,txn=0,held=0,bwait=0;
  integer inject_b=-1;
  logic aw_seen,w_seen;
  logic [63:0] aw_addr,aw_held;
  logic [511:0] wd_held;
  logic aw_hold,w_hold;
  function automatic logic [31:0] word_gold(input int row,input int col);
    return 32'h3f000000 | (32'(row*2624+col)^32'h0029a54d)&32'h007fffff;
  endfunction
  always @(negedge clk)begin
    m_axi_awready=rst_n && !aw_seen && cycles%5!=0;m_axi_wready=rst_n && !w_seen && cycles%7!=0;
    if(bwait>0)begin bwait=bwait-1;if(bwait==0)begin m_axi_bvalid=1;m_axi_bresp=txn==inject_b ? 2 : 0;end end
  end
  always @(posedge clk)begin
    cycles=cycles+1;if(cycles>150000)$fatal(1,"cycle budget");
    if(!rst_n)begin aw_seen=0;w_seen=0;bwait=0;m_axi_bvalid<=0;aw_hold=0;w_hold=0;txn=0;end
    else begin
      if(aw_hold && (!m_axi_awvalid || m_axi_awaddr!==aw_held))$fatal(1,"AW changed during stall");
      if(w_hold && (!m_axi_wvalid || m_axi_wdata!==wd_held))$fatal(1,"W changed during stall");
      aw_hold=m_axi_awvalid && !m_axi_awready;w_hold=m_axi_wvalid && !m_axi_wready;
      if(aw_hold)begin aw_held=m_axi_awaddr;held=held+1;end
      if(w_hold)begin wd_held=m_axi_wdata;held=held+1;end
      if(m_axi_awvalid && m_axi_awready)begin
        if(aw_seen || m_axi_awsize!=6 || m_axi_awlen!=0 || m_axi_awburst!=1 || m_axi_awaddr[5:0]!=0)$fatal(1,"AW protocol");
        aw_seen=1;aw_addr=m_axi_awaddr;
      end
      if(m_axi_wvalid && m_axi_wready)begin
        if(w_seen || m_axi_wstrb!==64'hffffffffffffffff || !m_axi_wlast)$fatal(1,"GATE WSTRB/WLAST");
        w_seen=1;
        for(int lane=0;lane<16;lane++)begin
          int row,col;
          row=txn/164;col=(txn%164)*16+lane;
          if(m_axi_wdata[lane*32+:32]!==word_gold(row,col))$fatal(1,"GATE payload row=%0d col=%0d",row,col);
          checked=checked+1;
        end
      end
      if(aw_seen && w_seen && bwait==0 && !m_axi_bvalid)begin
        if(aw_addr!==cfg_region_base+64'(cfg_producer_context[63:56])*1024*10496+64'(cfg_producer_context[87:72]+txn/164)*10496+64'(txn%164)*64)$fatal(1,"physical GATE address");
        if(aw_addr<cfg_bo_base || aw_addr+64>cfg_bo_base+cfg_bo_span || aw_addr<cfg_region_base || aw_addr+64>cfg_region_base+cfg_region_span)$fatal(1,"GATE physical/logical bound");
        bwait=13;
      end
      if(m_axi_bvalid && m_axi_bready)begin m_axi_bvalid<=0;aw_seen=0;w_seen=0;txn=txn+1;end
      if(gate_owner_state==2 && (aw_count!=b_count || w_count!=b_count || !producer_done_write_debt_zero))$fatal(1,"published with write debt");
    end
  end
  task automatic tick;@(posedge clk);#1;endtask
  task automatic configure(input int epoch,input int nrows);
    @(negedge clk);txn=0;checked=0;cfg_rows=5'(nrows);cfg_numeric_identity=672'hfa9876543210fedc;
    cfg_numeric_identity[63:0]=64'h100000001;cfg_numeric_identity[127:64]=64'h200000001;cfg_numeric_identity[143:128]=2;cfg_numeric_identity[159:144]=128;
    cfg_producer_context=0;cfg_producer_context[31:0]=32'h80000001+epoch*3;cfg_producer_context[39:32]=8'h60;cfg_producer_context[47:40]=2;
    cfg_producer_context[63:56]=1;cfg_producer_context[87:72]=124;cfg_producer_context[95:88]=8'(nrows);
    cfg_quant_context=cfg_producer_context;cfg_quant_context[31:0]=cfg_producer_context[31:0]+1;cfg_quant_context[39:32]=8'h61;
    cfg_consumer_context=cfg_producer_context;cfg_consumer_context[31:0]=cfg_producer_context[31:0]+2;cfg_consumer_context[39:32]=8'h33;
    cfg_source_ref=64'h0000000600000001;cfg_gate_ref=64'h0000000700000000+epoch;cfg_a_ref=64'h0000002200000001;cfg_w_ref=64'h0000002300000001;cfg_down_dst_ref=64'h0000000300000001;
    cfg_bo_base=64'h100000000;cfg_bo_span=64'h3000000;cfg_region_base=cfg_bo_base+4096;cfg_region_span=64'h2000000;cfg_owner_admitted=1;cfg_valid=1;
    while(!cfg_ready)tick();tick();if(cfg_reject)$fatal(1,"legal GATE command rejected");@(negedge clk);cfg_valid=0;
  endtask
  task automatic send_row(input int row,input bit wrong_tag,input int expected_status);
    for(int col=0;col<2624;col++)begin
      @(negedge clk);row_success=1;row_success_row=124+row;v_valid=1;v_data=word_gold(row,col);v_status=0;v_frame_tag=cfg_producer_context[31:0]+(wrong_tag && col==0);
      v_row=124+row;v_col=13'(col);v_last=col==2623;
      while(!v_ready)tick();tick();@(negedge clk);v_valid=0;
    end
    while(!row_write_done_valid)tick();
    if(row_write_status!=expected_status || row_write_task_id!=cfg_producer_context[31:0] || row_write_dst_epoch!=cfg_gate_ref[31:0] || row_write_row!=124+row || !row_write_debt_zero)$fatal(1,"row write receipt");
    repeat(7)begin tick();if(!row_write_done_valid || !row_write_debt_zero || gate_owner_state==2)$fatal(1,"early task publication");end
    @(negedge clk);row_write_done_ready=1;tick();@(negedge clk);row_write_done_ready=0;
  endtask
  task automatic finish_service(input int status,input int success_rows);
    @(negedge clk);service_done_valid=1;service_done_status=status;service_done_bad_element=status ? 2623 : 64'hffffffffffffffff;service_done_bad_row=124;
    service_read_debt_zero=0;service_arithmetic_debt_zero=1;
    repeat(9)begin tick();if(service_done_ready || producer_done_valid)$fatal(1,"producer retired before source read debt");end
    @(negedge clk);service_read_debt_zero=1;while(!service_done_ready)tick();tick();@(negedge clk);service_done_valid=0;
    while(!producer_done_valid)tick();
    if(producer_done_status!=status || producer_done_covered_rows!=(16'hffff>>(16-success_rows)) || !producer_done_write_debt_zero || gate_owner_state==2)$fatal(1,"task producer receipt");
    repeat(11)begin tick();if(!producer_done_valid || gate_acquire_ready)$fatal(1,"terminal hold/publication");end
    @(negedge clk);producer_done_ready=1;tick();@(negedge clk);producer_done_ready=0;
    if(gate_owner_state!=(status==0 ? 2 : 4))$fatal(1,"task publication state");
  endtask
  task automatic acquire_release;
    @(negedge clk);gate_acquire_numeric_identity=cfg_numeric_identity;gate_acquire_quant_context=cfg_quant_context;gate_acquire_ref=cfg_gate_ref;
    gate_acquire_numeric_identity[671]=~gate_acquire_numeric_identity[671];gate_acquire_valid=1;tick();if(!gate_acquire_done || !gate_acquire_error || gate_owner_state!=2)$fatal(1,"full source identity mismatch accepted");
    @(negedge clk);gate_acquire_numeric_identity=cfg_numeric_identity;tick();if(!gate_acquire_done || gate_acquire_error || gate_owner_state!=3)$fatal(1,"real published source acquire");@(negedge clk);gate_acquire_valid=0;
    gate_release_numeric_identity=cfg_numeric_identity;gate_release_quant_context=cfg_quant_context;gate_release_ref=cfg_gate_ref;gate_release_valid=1;gate_release_read_debt_zero=0;
    repeat(13)begin tick();if(gate_release_ready || gate_owner_state!=3)$fatal(1,"early source release");end
    @(negedge clk);gate_release_read_debt_zero=1;tick();if(!gate_release_done || gate_release_error || gate_owner_state!=0)$fatal(1,"source release");@(negedge clk);gate_release_valid=0;
  endtask
  initial begin
    rst_n=0;cfg_valid=0;cfg_owner_admitted=0;cfg_numeric_identity=0;cfg_producer_context=0;cfg_quant_context=0;cfg_consumer_context=0;cfg_source_ref=0;cfg_gate_ref=0;cfg_a_ref=0;cfg_w_ref=0;cfg_down_dst_ref=0;cfg_rows=0;
    cfg_bo_base=0;cfg_bo_span=0;cfg_region_base=0;cfg_region_span=0;row_success=0;row_success_row=0;v_valid=0;v_data=0;v_status=0;v_frame_tag=0;v_row=0;v_col=0;v_last=0;
    row_write_done_ready=0;service_done_valid=0;service_done_status=0;service_done_bad_element=0;service_done_bad_row=0;service_read_debt_zero=0;service_arithmetic_debt_zero=0;producer_done_ready=0;
    gate_acquire_valid=0;gate_acquire_numeric_identity=0;gate_acquire_quant_context=0;gate_acquire_ref=0;gate_release_valid=0;gate_release_numeric_identity=0;gate_release_quant_context=0;gate_release_ref=0;gate_release_read_debt_zero=0;
    m_axi_awready=0;m_axi_wready=0;m_axi_bresp=0;m_axi_bvalid=0;
    repeat(4)tick();@(negedge clk);rst_n=1;
    configure(1,4);for(int row=0;row<4;row++)send_row(row,0,0);finish_service(0,4);
    if(accepted_words!=10496 || useful_bytes!=41984 || physical_bytes!=41984 || aw_count!=656 || w_count!=656 || b_count!=656)$fatal(1,"GATE complete bytes/response count");
    acquire_release();
    configure(2,1);send_row(0,1,2);finish_service(2,0);if(aw_count!=0 || w_count!=0)$fatal(1,"wrong associated tag wrote");
    inject_b=10;configure(3,1);send_row(0,0,3);finish_service(3,0);inject_b=-1;
    configure(4,1);finish_service(1,0);if(aw_count!=0 || w_count!=0)$fatal(1,"failed arithmetic row wrote");
    configure(5,1);send_row(0,0,0);finish_service(0,1);acquire_release();
    configure(6,1);@(negedge clk);rst_n=0;repeat(3)tick();@(negedge clk);rst_n=1;tick();if(gate_owner_state!=0 || producer_done_valid || row_write_done_valid)$fatal(1,"reset cancel");
    configure(1,1);send_row(0,0,0);finish_service(0,1);acquire_release();
    $display("GEGLU_GATE_WRITER_LEDGER_PASS rows4=1 final_b_barrier=1 source_lease=1 no_preloaded_gate=1 wrong_tag_no_write=1 b_error_recovery=1 numeric_error_no_write=1 reset_recovery=1 held=%0d cycles=%0d",held,cycles);
    $finish;
  end
endmodule
