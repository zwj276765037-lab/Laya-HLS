`timescale 1ns/1ps
module laya_13bo_control_plane_tb_v1;
  logic clk=0,rst_n=0;always #5 clk=~clk;
  logic soft_cancel=0,cold_rebind=0,domain_drained=1;
  logic [3:0] s_control_awaddr=0,s_control_araddr=0,m_control_awaddr,m_control_araddr;
  logic s_control_awvalid=0,s_control_awready,s_control_wvalid=0,s_control_wready;
  logic [31:0] s_control_wdata=0,s_control_rdata,m_control_wdata,m_control_rdata;
  logic [3:0] s_control_wstrb=0,m_control_wstrb;
  logic [1:0] s_control_bresp,s_control_rresp,m_control_bresp,m_control_rresp;
  logic s_control_bvalid,s_control_bready=0,s_control_arvalid=0,s_control_arready,s_control_rvalid,s_control_rready=0;
  logic m_control_awvalid,m_control_awready,m_control_wvalid,m_control_wready,m_control_bvalid,m_control_bready;
  logic m_control_arvalid,m_control_arready,m_control_rvalid,m_control_rready;
  logic [7:0] s_control_r_awaddr=0,s_control_r_araddr=0,m_control_r_awaddr,m_control_r_araddr;
  logic s_control_r_awvalid=0,s_control_r_awready,s_control_r_wvalid=0,s_control_r_wready;
  logic [31:0] s_control_r_wdata=0,s_control_r_rdata,m_control_r_wdata,m_control_r_rdata;
  logic [3:0] s_control_r_wstrb=0,m_control_r_wstrb;
  logic [1:0] s_control_r_bresp,s_control_r_rresp,m_control_r_bresp,m_control_r_rresp;
  logic s_control_r_bvalid,s_control_r_bready=0,s_control_r_arvalid=0,s_control_r_arready,s_control_r_rvalid,s_control_r_rready=0;
  logic m_control_r_awvalid,m_control_r_awready,m_control_r_wvalid,m_control_r_wready,m_control_r_bvalid,m_control_r_bready;
  logic m_control_r_arvalid,m_control_r_arready,m_control_r_rvalid,m_control_r_rready;
  logic core_start_admitted,start_ready,start_rejected,binding_valid,candidate_valid,candidate_matches;
  logic binding_conflict,cold_rebind_rejected,mirror_protocol_error,control_write_idle,control_read_idle;
  logic [12:0][63:0] programmed_bo_base,latched_bo_base,actual_bo_base;
  logic [4:0][63:0] bound_model_base;
  logic [31:0] accepted_requests,rejected_requests,forwarded_control_writes,rejected_control_starts;
  logic interrupt,inner_ap_start,inner_ap_done=0,inner_ap_ready=0,inner_ap_idle=1;
  int cycles=0,inner_starts=0;

  laya_13bo_control_plane_v1 dut(.*);
  laya_typed_q8_forward_control_s_axi inner_control(
    .ACLK(clk),.ARESET(!rst_n),.ACLK_EN(1'b1),
    .AWADDR(m_control_awaddr),.AWVALID(m_control_awvalid),.AWREADY(m_control_awready),
    .WDATA(m_control_wdata),.WSTRB(m_control_wstrb),.WVALID(m_control_wvalid),.WREADY(m_control_wready),
    .BRESP(m_control_bresp),.BVALID(m_control_bvalid),.BREADY(m_control_bready),
    .ARADDR(m_control_araddr),.ARVALID(m_control_arvalid),.ARREADY(m_control_arready),
    .RDATA(m_control_rdata),.RRESP(m_control_rresp),.RVALID(m_control_rvalid),.RREADY(m_control_rready),
    .interrupt,.ap_start(inner_ap_start),.ap_done(inner_ap_done),.ap_ready(inner_ap_ready),.ap_idle(inner_ap_idle));
  laya_typed_q8_forward_control_r_s_axi inner_pointers(
    .ACLK(clk),.ARESET(!rst_n),.ACLK_EN(1'b1),
    .AWADDR(m_control_r_awaddr),.AWVALID(m_control_r_awvalid),.AWREADY(m_control_r_awready),
    .WDATA(m_control_r_wdata),.WSTRB(m_control_r_wstrb),.WVALID(m_control_r_wvalid),.WREADY(m_control_r_wready),
    .BRESP(m_control_r_bresp),.BVALID(m_control_r_bvalid),.BREADY(m_control_r_bready),
    .ARADDR(m_control_r_araddr),.ARVALID(m_control_r_arvalid),.ARREADY(m_control_r_arready),
    .RDATA(m_control_r_rdata),.RRESP(m_control_r_rresp),.RVALID(m_control_r_rvalid),.RREADY(m_control_r_rready),
    .embedding_r(actual_bo_base[0]),.io_r(actual_bo_base[1]),.w_q0_r(actual_bo_base[2]),
    .w_q1_r(actual_bo_base[3]),.w_scale_r(actual_bo_base[4]),.aux_r(actual_bo_base[5]),
    .state0_r(actual_bo_base[6]),.state1_r(actual_bo_base[7]),.qkv0_r(actual_bo_base[8]),
    .qkv1_r(actual_bo_base[9]),.ff0_r(actual_bo_base[10]),.ff1_r(actual_bo_base[11]),
    .att_out_r(actual_bo_base[12]));
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>10000)$fatal(1,"control plane cycle cap");
    if(core_start_admitted)inner_starts++;
  end
  always @(negedge clk)if(rst_n && programmed_bo_base!==actual_bo_base)
    $fatal(1,"pointer mirror diverged from generated register bank");
  task automatic pointer_write(input logic [7:0] address,input logic [31:0] data);
    @(negedge clk);s_control_r_awaddr=address;s_control_r_awvalid=1;
    while(!s_control_r_awready)tick();tick();@(negedge clk);s_control_r_awvalid=0;
    repeat(2)tick();@(negedge clk);s_control_r_wdata=data;s_control_r_wstrb=4'hf;s_control_r_wvalid=1;
    while(!s_control_r_wready)tick();tick();@(negedge clk);s_control_r_wvalid=0;
    while(!s_control_r_bvalid)tick();
    if(s_control_r_bresp!=0)$fatal(1,"pointer BRESP");
    @(negedge clk);s_control_r_bready=1;tick();@(negedge clk);s_control_r_bready=0;
  endtask
  task automatic set_base(input int role,input logic [63:0] value);
    pointer_write(8'(16+12*role),value[31:0]);
    pointer_write(8'(20+12*role),value[63:32]);
  endtask
  task automatic control_write(input logic [31:0] data,input logic [1:0] expected);
    @(negedge clk);s_control_awaddr=0;s_control_awvalid=1;
    while(!s_control_awready)tick();tick();@(negedge clk);s_control_awvalid=0;
    repeat(3)tick();@(negedge clk);s_control_wdata=data;s_control_wstrb=4'h1;s_control_wvalid=1;
    while(!s_control_wready)tick();tick();@(negedge clk);s_control_wvalid=0;
    repeat(3)tick();while(!s_control_bvalid)tick();
    if(s_control_bresp!==expected)$fatal(1,"control BRESP expected=%h got=%h",expected,s_control_bresp);
    @(negedge clk);s_control_bready=1;tick();@(negedge clk);s_control_bready=0;
  endtask
  task automatic clear_inner_start;
    @(negedge clk);inner_ap_ready=1;tick();@(negedge clk);inner_ap_ready=0;repeat(2)tick();
    if(inner_ap_start)$fatal(1,"inner ap_start did not clear");
  endtask
  initial begin
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(4)tick();
    for(int role=0;role<13;role++)set_base(role,64'h0000000100000000+64'(role)*64'h01000000);
    if(!candidate_valid || binding_valid)$fatal(1,"initial candidate state");
    control_write(1,0);repeat(2)tick();
    if(!binding_valid || inner_starts!=1 || latched_bo_base!==actual_bo_base || !inner_ap_start)
      $fatal(1,"first bound start did not reach controller");
    clear_inner_start();
    set_base(1,64'h0000000200000000);
    control_write(1,0);repeat(2)tick();
    if(inner_starts!=2 || !candidate_matches || latched_bo_base!==actual_bo_base)
      $fatal(1,"non-model base update was rejected");
    clear_inner_start();
    set_base(0,64'h0000000300000000);
    if(candidate_matches)$fatal(1,"changed model base matched old binding");
    control_write(1,2'b10);repeat(2)tick();
    if(inner_starts!=2 || !binding_conflict || rejected_requests!=1 || rejected_control_starts!=1)
      $fatal(1,"model conflict reached inner controller");
    soft_cancel=1;tick();soft_cancel=0;
    control_write(1,2'b10);repeat(2)tick();
    if(inner_starts!=2 || rejected_requests!=2)$fatal(1,"soft cancel cleared binding");
    domain_drained=0;cold_rebind=1;tick();cold_rebind=0;
    if(!cold_rebind_rejected || !binding_valid)$fatal(1,"unsafe cold rebind accepted");
    domain_drained=1;cold_rebind=1;tick();cold_rebind=0;repeat(2)tick();
    if(binding_valid)$fatal(1,"drained cold rebind did not clear binding");
    control_write(1,0);repeat(2)tick();
    if(!binding_valid || inner_starts!=3 || bound_model_base[0]!=64'h0000000300000000)
      $fatal(1,"post-cold-rebind start failed");
    if(mirror_protocol_error || accepted_requests!=3 || forwarded_control_writes!=3 ||
       rejected_control_starts!=2 || !control_write_idle || !control_read_idle)
      $fatal(1,"final control plane accounting");
    $display("FULL_CURRENT_13BO_CONTROL_PLANE_PASS starts=%0d rejected=%0d pointer_words=30 forwarded=%0d cycles=%0d",
      accepted_requests,rejected_requests,forwarded_control_writes,cycles);
    $finish;
  end
endmodule
