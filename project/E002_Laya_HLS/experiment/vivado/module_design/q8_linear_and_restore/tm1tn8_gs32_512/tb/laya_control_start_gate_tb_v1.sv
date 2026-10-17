`timescale 1ns/1ps
module laya_control_start_gate_tb_v1;
  logic clk=0,rst_n=0;always #5 clk=~clk;
  logic [3:0] s_awaddr=0,s_araddr=0,m_awaddr,m_araddr;
  logic s_awvalid=0,s_awready,s_wvalid=0,s_wready,s_bvalid,s_bready=0;
  logic [31:0] s_wdata=0,s_rdata,m_wdata,m_rdata=0;
  logic [3:0] s_wstrb=0,m_wstrb;
  logic [1:0] s_bresp,s_rresp,m_bresp=0,m_rresp=0;
  logic s_arvalid=0,s_arready,s_rvalid,s_rready=0;
  logic m_awvalid,m_awready=1,m_wvalid,m_wready=1,m_bvalid=0,m_bready;
  logic m_arvalid,m_arready=1,m_rvalid=0,m_rready;
  logic host_start_valid,host_start_ready=0,start_accepted,start_rejected;
  logic write_idle,read_idle;
  logic [31:0] forwarded_writes,rejected_starts;
  int inner_aw=0,inner_w=0,inner_ar=0,accepted=0,rejected=0,cycles=0;
  laya_control_start_gate_v1 dut(.*);
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;
    if(cycles>3000)$fatal(1,"control gate cycle cap");
    if(m_awvalid&&m_awready)inner_aw++;
    if(m_wvalid&&m_wready)inner_w++;
    if(m_arvalid&&m_arready)inner_ar++;
    if(start_accepted)accepted++;
    if(start_rejected)rejected++;
  end
  task automatic write(input logic [3:0] address,input logic [31:0] data,
      input logic [3:0] strobe,input logic [1:0] expected_resp,input int hold_b);
    @(negedge clk);s_awaddr=address;s_awvalid=1;
    while(!s_awready)tick();tick();@(negedge clk);s_awvalid=0;
    repeat(2)tick();@(negedge clk);s_wdata=data;s_wstrb=strobe;s_wvalid=1;
    while(!s_wready)tick();tick();@(negedge clk);s_wvalid=0;
    repeat(hold_b)begin tick();if(s_bvalid && s_bresp!==expected_resp)$fatal(1,"held BRESP mismatch");end
    while(!s_bvalid)tick();
    if(s_bresp!==expected_resp)$fatal(1,"BRESP mismatch expected=%0h got=%0h",expected_resp,s_bresp);
    @(negedge clk);s_bready=1;tick();@(negedge clk);s_bready=0;
  endtask
  task automatic read(input logic [3:0] address,input logic [31:0] expected);
    @(negedge clk);s_araddr=address;s_arvalid=1;
    while(!s_arready)tick();tick();@(negedge clk);s_arvalid=0;
    repeat(3)tick();
    while(!s_rvalid)tick();
    if(s_rdata!==expected || s_rresp!=0)$fatal(1,"read proxy mismatch");
    repeat(3)tick();
    @(negedge clk);s_rready=1;tick();@(negedge clk);s_rready=0;
  endtask
  initial begin : inner_model
    forever begin
      @(posedge clk);#1;
      if(m_wvalid && m_wready)begin m_bvalid<=1;m_bresp<=0;end
      if(m_bvalid && m_bready)m_bvalid<=0;
      if(m_arvalid && m_arready)begin
        m_rvalid<=1;m_rdata<={28'hc001d00,m_araddr};m_rresp<=0;
      end
      if(m_rvalid && m_rready)m_rvalid<=0;
    end
  end
  initial begin : run
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    write(4'h4,32'h00000001,4'hf,2'b00,3);
    if(inner_aw!=1||inner_w!=1||accepted||rejected)$fatal(1,"ordinary write accounting");
    write(4'h0,32'h00000001,4'h1,2'b10,4);
    if(inner_aw!=1||inner_w!=1||accepted||rejected!=1)$fatal(1,"rejected start reached controller");
    host_start_ready=1;
    write(4'h0,32'h00000081,4'h1,2'b00,5);
    if(inner_aw!=2||inner_w!=2||accepted!=1||rejected!=1)$fatal(1,"accepted start accounting");
    host_start_ready=0;
    write(4'h0,32'h00000001,4'h0,2'b00,1);
    if(inner_aw!=3||inner_w!=3||rejected!=1)$fatal(1,"masked start was gated");
    read(4'h0,32'hc001d000);
    read(4'hc,32'hc001d00c);
    if(inner_ar!=2 || forwarded_writes!=3 || rejected_starts!=1 || !write_idle || !read_idle)
      $fatal(1,"final control gate accounting");
    $display("FULL_CURRENT_CONTROL_START_GATE_PASS forwarded=%0d rejected=%0d reads=%0d cycles=%0d",
      forwarded_writes,rejected_starts,inner_ar,cycles);
    $finish;
  end
endmodule
