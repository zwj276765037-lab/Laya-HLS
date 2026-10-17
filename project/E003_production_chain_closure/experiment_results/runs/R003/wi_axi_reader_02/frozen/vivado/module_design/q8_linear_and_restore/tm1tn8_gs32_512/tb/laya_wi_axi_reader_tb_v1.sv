`timescale 1ns/1ps
module laya_wi_axi_reader_tb_v1;
  logic clk=0,rst_n=0,cancel=0;always #5 clk=~clk;
  logic cfg_valid=0,cfg_ready,cfg_reject;
  logic [671:0] cfg_numeric_identity=0;
  logic [95:0] cfg_producer_context=0;
  logic [63:0] cfg_source_ref=64'h0000000000000001;
  logic [63:0] cfg_bo_base=64'h100000000,cfg_bo_span=64'h4000000;
  logic [63:0] cfg_region_base=64'h100000040,cfg_region_span=64'h3000000;
  logic [63:0] cfg_row_stride_bytes=20992,cfg_batch_stride_bytes=21495808;
  logic wi_valid,wi_ready=0;logic [31:0] wi_data,wi_status;
  logic [671:0] wi_numeric_identity;logic [63:0] wi_source_ref;
  logic [15:0] wi_row;logic [12:0] wi_index;
  logic wi_row_done_valid,wi_row_done_ready=0;logic [31:0] wi_row_done_status;
  logic [63:0] wi_row_bad_element;logic read_debt_zero,active;
  logic [31:0] ar_count,r_count,complete_rows;
  logic [63:0] m_axi_araddr;logic [7:0] m_axi_arlen;logic [2:0] m_axi_arsize;
  logic [1:0] m_axi_arburst;logic m_axi_arvalid,m_axi_arready=1;
  logic [511:0] m_axi_rdata=0;logic [1:0] m_axi_rresp=0;
  logic m_axi_rlast=0,m_axi_rvalid=0,m_axi_rready;
  int cycles=0,words=0,rows_done=0,commands=0;
  int mem_left=0;logic [63:0] mem_addr=0;int mem_beat=0;
  bit inject_error=0,inject_late_last=0;
  laya_wi_axi_reader_v1 dut(.*);
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>60000)$fatal(1,"WI reader cycle cap");
    wi_ready<=active && cycles%7!=0;
    wi_row_done_ready<=wi_row_done_valid && cycles%5!=0;
    if(wi_valid && wi_ready)begin
      logic [31:0] expected;
      expected=32'((cfg_region_base+64'(wi_row)*cfg_row_stride_bytes)/4+wi_index);
      if(commands==1 && wi_status==0 && wi_data!==expected)$fatal(1,"WI word mismatch row=%0d index=%0d",wi_row,wi_index);
      if(wi_numeric_identity!==cfg_numeric_identity || wi_source_ref!==cfg_source_ref)$fatal(1,"WI binding mismatch");
      words++;
    end
    if(wi_row_done_valid && wi_row_done_ready)begin
      if(commands==1 && wi_row_done_status!=0)$fatal(1,"successful row failed");
      if(commands==2 && (wi_row_done_status!=3 || wi_row_bad_element!=32))$fatal(1,"error row result mismatch");
      if((commands==3 || commands==4) &&
         (wi_row_done_status!=3 || wi_row_bad_element!=64'hffffffffffffffff))
        $fatal(1,"cancel row result mismatch command=%0d",commands);
      if(commands==5 && (wi_row_done_status!=3 || wi_row_bad_element!=992))
        $fatal(1,"late RLAST row result mismatch");
      rows_done++;
    end
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin m_axi_rvalid<=0;mem_left<=0;mem_addr<=0;mem_beat<=0;end
    else begin
      if(m_axi_arvalid && m_axi_arready)begin
        if(mem_left!=0)$fatal(1,"overlapping AR");
        mem_left<=m_axi_arlen+1+(inject_late_last ? 1 : 0);mem_addr<=m_axi_araddr;mem_beat<=0;
      end
      if(!m_axi_rvalid && mem_left!=0)begin
        for(int lane=0;lane<16;lane++)m_axi_rdata[lane*32+:32]<=32'(mem_addr/4+64'(mem_beat)*16+lane);
        m_axi_rresp<=inject_error && mem_beat==2 ? 2'b10 : 0;
        m_axi_rlast<=mem_left==1;m_axi_rvalid<=1;
      end
      if(m_axi_rvalid && m_axi_rready)begin
        m_axi_rvalid<=0;mem_left<=mem_left-1;mem_beat<=mem_beat+1;
      end
    end
  end
  task automatic start(input int rows,input bit fault,input bit late_last);
    while(!cfg_ready)tick();
    @(negedge clk);inject_error=fault;inject_late_last=late_last;
    cfg_producer_context[95:88]=8'(rows);cfg_valid=1;commands++;
    tick();@(negedge clk);cfg_valid=0;
    if(cfg_reject)$fatal(1,"legal WI config rejected");
  endtask
  initial begin
    cfg_numeric_identity[63:0]=64'h11;cfg_numeric_identity[127:64]=64'h22;
    cfg_numeric_identity[143:128]=1;cfg_numeric_identity[159:144]=64;
    cfg_producer_context[31:0]=1;cfg_producer_context[39:32]=8'h60;
    cfg_producer_context[47:40]=2;cfg_producer_context[63:56]=0;
    cfg_producer_context[71:64]=0;cfg_producer_context[87:72]=0;
    cfg_source_ref[39:32]=6;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    start(2,0,0);while(active)tick();
    if(words!=10496 || rows_done!=2 || ar_count!=6 || r_count!=656 || complete_rows!=2)$fatal(1,"successful WI coverage");
    words=0;rows_done=0;start(1,1,0);while(active)tick();
    if(words!=5248 || rows_done!=1 || ar_count!=1 || r_count!=63 || complete_rows!=1)$fatal(1,"error WI drain/stop");
    words=0;rows_done=0;m_axi_arready=0;start(1,0,0);
    while(!m_axi_arvalid)tick();
    @(negedge clk);cancel=1;tick();@(negedge clk);cancel=0;
    while(active)tick();m_axi_arready=1;
    if(words!=0 || rows_done!=1 || ar_count!=0 || r_count!=0 || complete_rows!=1)$fatal(1,"ADDR cancel did not terminate debt-free");
    words=0;rows_done=0;start(1,0,0);
    while(r_count<5)tick();
    @(negedge clk);cancel=1;tick();@(negedge clk);cancel=0;
    while(active)tick();
    if(words!=1008 || rows_done!=1 || ar_count!=1 || r_count!=63 || complete_rows!=1)$fatal(1,"DATA cancel did not drain one accepted burst");
    words=0;rows_done=0;start(1,0,1);while(active)tick();
    if(words!=5248 || rows_done!=1 || ar_count!=1 || r_count!=64 || complete_rows!=1)$fatal(1,"late RLAST drain/stop");
    if(!read_debt_zero || m_axi_rvalid || mem_left!=0)$fatal(1,"WI reader debt remained");
    $display("FULL_CURRENT_WI_AXI_READER_PASS commands=%0d words=%0d success_rows=2 error_rows=2 cancel_rows=2 cycles=%0d",commands,10496+5248+1008+words,cycles);
    $finish;
  end
endmodule
