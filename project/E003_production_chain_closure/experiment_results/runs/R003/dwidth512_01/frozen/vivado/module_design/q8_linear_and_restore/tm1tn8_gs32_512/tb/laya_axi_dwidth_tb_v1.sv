`timescale 1ns/1ps
module laya_axi_dwidth_tb_v1;
  localparam int SW=`LAYA_DWIDTH_SI, SB=SW/8, BEATS=2048/SB;
  localparam logic [63:0] BASE=64'h00000001_12340000;
  logic clk=0,rst_n=0;
  always #5 clk=~clk;
  int cycles=0,s_read_count=0,s_write_count=0,s_b_count=0;
  int m_ar_count=0,m_r_count=0,m_aw_count=0,m_w_count=0,m_b_count=0;
  logic [63:0] s_awaddr,s_araddr,m_awaddr,m_araddr;
  logic [7:0] s_awlen,s_arlen,m_awlen,m_arlen;
  logic [2:0] s_awsize,s_arsize,m_awsize,m_arsize;
  logic [1:0] s_awburst,s_arburst,m_awburst,m_arburst;
  logic s_awlock,s_arlock,m_awlock,m_arlock;
  logic [3:0] s_awcache,s_arcache,s_awqos,s_arqos,m_awcache,m_arcache,m_awqos,m_arqos;
  logic [2:0] s_awprot,s_arprot,m_awprot,m_arprot;
  logic s_awvalid,s_awready,s_arvalid,s_arready,m_awvalid,m_awready,m_arvalid,m_arready;
  logic [SW-1:0] s_wdata,s_rdata;
  logic [SB-1:0] s_wstrb;
  logic s_wlast,s_wvalid,s_wready,s_rlast,s_rvalid,s_rready;
  logic [1:0] s_bresp,s_rresp;
  logic s_bvalid,s_bready;
  logic [31:0] m_wdata,m_rdata;
  logic [3:0] m_wstrb;
  logic m_wlast,m_wvalid,m_wready,m_rlast,m_rvalid,m_rready;
  logic [1:0] m_bresp,m_rresp;
  logic m_bvalid,m_bready;
  logic [7:0] memory[0:8191],gold[0:8191];
  logic r_active=0,w_active=0,b_pending=0;
  logic hold_last_r=1,hold_last_b=1,hold_s_r=0;
  logic last_r_waiting=0,last_b_waiting=0;
  logic [63:0] r_addr,w_addr,b_end;
  int r_index=0,r_beats=0,w_index=0,w_beats=0;
  logic [1:0] pending_bresp;

  laya_axi_dwidth_native_v1 dut(
    .s_axi_aclk(clk),.s_axi_aresetn(rst_n),
    .s_axi_awaddr(s_awaddr),.s_axi_awlen(s_awlen),.s_axi_awsize(s_awsize),
    .s_axi_awburst(s_awburst),.s_axi_awlock(s_awlock),.s_axi_awcache(s_awcache),
    .s_axi_awprot(s_awprot),.s_axi_awqos(s_awqos),.s_axi_awvalid(s_awvalid),.s_axi_awready(s_awready),
    .s_axi_wdata(s_wdata),.s_axi_wstrb(s_wstrb),.s_axi_wlast(s_wlast),.s_axi_wvalid(s_wvalid),.s_axi_wready(s_wready),
    .s_axi_bresp(s_bresp),.s_axi_bvalid(s_bvalid),.s_axi_bready(s_bready),
    .s_axi_araddr(s_araddr),.s_axi_arlen(s_arlen),.s_axi_arsize(s_arsize),
    .s_axi_arburst(s_arburst),.s_axi_arlock(s_arlock),.s_axi_arcache(s_arcache),
    .s_axi_arprot(s_arprot),.s_axi_arqos(s_arqos),.s_axi_arvalid(s_arvalid),.s_axi_arready(s_arready),
    .s_axi_rdata(s_rdata),.s_axi_rresp(s_rresp),.s_axi_rlast(s_rlast),.s_axi_rvalid(s_rvalid),.s_axi_rready(s_rready),
    .m_axi_awaddr(m_awaddr),.m_axi_awlen(m_awlen),.m_axi_awsize(m_awsize),
    .m_axi_awburst(m_awburst),.m_axi_awlock(m_awlock),.m_axi_awcache(m_awcache),
    .m_axi_awprot(m_awprot),.m_axi_awqos(m_awqos),.m_axi_awvalid(m_awvalid),.m_axi_awready(m_awready),
    .m_axi_wdata(m_wdata),.m_axi_wstrb(m_wstrb),.m_axi_wlast(m_wlast),.m_axi_wvalid(m_wvalid),.m_axi_wready(m_wready),
    .m_axi_bresp(m_bresp),.m_axi_bvalid(m_bvalid),.m_axi_bready(m_bready),
    .m_axi_araddr(m_araddr),.m_axi_arlen(m_arlen),.m_axi_arsize(m_arsize),
    .m_axi_arburst(m_arburst),.m_axi_arlock(m_arlock),.m_axi_arcache(m_arcache),
    .m_axi_arprot(m_arprot),.m_axi_arqos(m_arqos),.m_axi_arvalid(m_arvalid),.m_axi_arready(m_arready),
    .m_axi_rdata(m_rdata),.m_axi_rresp(m_rresp),.m_axi_rlast(m_rlast),.m_axi_rvalid(m_rvalid),.m_axi_rready(m_rready));

  function automatic logic [7:0] initial_byte(input int address);
    return 8'(address*29+7);
  endfunction
  function automatic logic [7:0] write_byte(input int beat,input int lane);
    return 8'(beat*17+lane*11+93);
  endfunction
  function automatic bit enabled_byte(input int beat,input int lane);
    return ((lane+beat)%5==0) || lane==0 || lane==SB-1 || ((lane^beat)%11==3);
  endfunction
  function automatic logic [1:0] narrow_rresp(input int address);
    if(address==12'h834)return 3;
    if(address==12'h830 || address==12'h8b4)return 2;
    return 0;
  endfunction
  function automatic logic [1:0] wide_rresp(input int address);
    if(address<=12'h834 && address+SB>12'h834)return 3;
    if((address<=12'h830 && address+SB>12'h830) ||
       (address<=12'h8b4 && address+SB>12'h8b4))return 2;
    return 0;
  endfunction
  assign m_arready=rst_n && !r_active && cycles%7!=2;
  assign m_awready=rst_n && !w_active && !b_pending && !m_bvalid && cycles%7!=3;
  assign m_wready=rst_n && w_active && cycles%4!=1;
  assign s_rready=rst_n && !hold_s_r && cycles%5!=1;

  // Independent 32-bit memory peer. Its burst/LAST checks do not reuse any
  // converter implementation. Physical responses retain errors and delays.
  always @(posedge clk)begin : peer
    int address;
    cycles<=cycles+1;
    if(cycles>20000)$fatal(1,"width converter cycle cap SW=%0d reads=%0d writes=%0d B=%0d",SW,s_read_count,s_write_count,s_b_count);
    if(rst_n)begin
      if(m_arvalid && m_arready)begin
        if(m_araddr[63:32]!=BASE[63:32] || m_arsize!=2 || m_arburst!=1 ||
           m_araddr[1:0]!=0 || int'(m_araddr[11:0])+4*(int'(m_arlen)+1)>4096 ||
           m_arcache!=s_arcache || m_arprot!=s_arprot || m_arqos!=s_arqos || m_arlock!=s_arlock)
          $fatal(1,"narrow AR address/boundary/sideband");
        r_active<=1;r_addr<=m_araddr;r_index<=0;r_beats<=int'(m_arlen)+1;m_ar_count<=m_ar_count+1;
      end
      if(r_active && !m_rvalid && cycles%3!=0)begin
        address=int'(r_addr-BASE)+r_index*4;
        if(address==4092 && hold_last_r)last_r_waiting<=1;
        else begin
          for(int j=0;j<4;j++)m_rdata[j*8+:8]<=memory[address+j];
          m_rresp<=narrow_rresp(address);m_rlast<=r_index==r_beats-1;m_rvalid<=1;
        end
      end
      if(m_rvalid && m_rready)begin
        m_rvalid<=0;m_r_count<=m_r_count+1;r_index<=r_index+1;
        if(m_rlast)r_active<=0;
      end
      if(m_awvalid && m_awready)begin
        if(m_awaddr[63:32]!=BASE[63:32] || m_awsize!=2 || m_awburst!=1 ||
           m_awaddr[1:0]!=0 || int'(m_awaddr[11:0])+4*(int'(m_awlen)+1)>4096 ||
           m_awcache!=s_awcache || m_awprot!=s_awprot || m_awqos!=s_awqos || m_awlock!=s_awlock)
          $fatal(1,"narrow AW address/boundary/sideband");
        w_active<=1;w_addr<=m_awaddr;w_index<=0;w_beats<=int'(m_awlen)+1;m_aw_count<=m_aw_count+1;
        pending_bresp<=m_awaddr-BASE<3072 ? 2 : 3;
      end
      if(m_wvalid && m_wready)begin
        if(m_wlast!=(w_index==w_beats-1))$fatal(1,"narrow WLAST count");
        address=int'(w_addr-BASE)+w_index*4;
        for(int j=0;j<4;j++)if(m_wstrb[j])memory[address+j]<=m_wdata[j*8+:8];
        m_w_count<=m_w_count+1;w_index<=w_index+1;
        if(m_wlast)begin w_active<=0;b_pending<=1;b_end<=w_addr+64'(w_beats*4);end
      end
      if(b_pending && !m_bvalid && cycles%5!=2)begin
        if(b_end-BASE==4096 && hold_last_b)last_b_waiting<=1;
        else begin m_bvalid<=1;m_bresp<=pending_bresp;end
      end
      if(m_bvalid && m_bready)begin m_bvalid<=0;b_pending<=0;m_b_count<=m_b_count+1;end
      if(s_rvalid && s_rready)begin
        address=2048+s_read_count*SB;
        for(int j=0;j<SB;j++)if(s_rdata[j*8+:8]!==initial_byte(address+j))
          $fatal(1,"wide read byte SW=%0d beat=%0d lane=%0d",SW,s_read_count,j);
        if(s_rresp!==wide_rresp(address) || s_rlast!=(s_read_count==BEATS-1))
          $fatal(1,"wide read response/LAST SW=%0d beat=%0d actual=%0d expected=%0d",SW,s_read_count,s_rresp,wide_rresp(address));
        s_read_count<=s_read_count+1;
      end
      if(s_wvalid && s_wready)begin
        for(int j=0;j<SB;j++)if(s_wstrb[j])gold[2048+s_write_count*SB+j]<=s_wdata[j*8+:8];
        if(s_wlast!=(s_write_count==BEATS-1))$fatal(1,"wide source WLAST");
        s_write_count<=s_write_count+1;
      end
      if(s_bvalid && s_bready)begin
        if(s_bresp!=3 || m_b_count<2)$fatal(1,"split BRESP aggregation/retirement");
        s_b_count<=s_b_count+1;
      end
    end
  end

  task automatic tick;@(posedge clk);#1;endtask
  task automatic send_ar;
    @(negedge clk);s_arvalid=1;
    do @(posedge clk);while(!s_arready);
    @(negedge clk);s_arvalid=0;
  endtask
  task automatic send_aw;
    repeat(8)tick();@(negedge clk);s_awvalid=1;
    do @(posedge clk);while(!s_awready);
    @(negedge clk);s_awvalid=0;
  endtask
  task automatic send_w;
    for(int beat=0;beat<BEATS;beat++)begin
      @(negedge clk);s_wvalid=1;s_wlast=beat==BEATS-1;
      for(int j=0;j<SB;j++)begin s_wdata[j*8+:8]=write_byte(beat,j);s_wstrb[j]=enabled_byte(beat,j);end
      do @(posedge clk);while(!s_wready);
      @(negedge clk);s_wvalid=0;
    end
  endtask
  initial begin
    for(int j=0;j<8192;j++)begin memory[j]=initial_byte(j);gold[j]=initial_byte(j);end
    s_awaddr=BASE+2048;s_araddr=BASE+2048;s_awlen=8'(BEATS-1);s_arlen=8'(BEATS-1);
    s_awsize=3'($clog2(SB));s_arsize=3'($clog2(SB));s_awburst=1;s_arburst=1;
    s_awlock=0;s_arlock=0;s_awcache=3;s_arcache=3;s_awprot=5;s_arprot=5;s_awqos=9;s_arqos=9;
    s_awvalid=0;s_arvalid=0;s_wdata=0;s_wstrb=0;s_wlast=0;s_wvalid=0;s_bready=0;
    m_rdata=0;m_rresp=0;m_rlast=0;m_rvalid=0;m_bresp=0;m_bvalid=0;
    repeat(10)tick();@(negedge clk);rst_n=1;repeat(12)tick();
    send_ar();
    wait(last_r_waiting);repeat(20)begin tick();if(s_read_count==BEATS)$fatal(1,"read retired before final physical R");end
    @(negedge clk);hold_last_r=0;
    wait(s_read_count==BEATS);repeat(4)tick();
    fork send_aw();send_w();join
    wait(last_b_waiting);repeat(20)begin tick();if(s_bvalid || s_b_count!=0)$fatal(1,"write retired before final physical B");end
    @(negedge clk);hold_last_b=0;
    wait(s_bvalid);repeat(12)begin tick();if(!s_bvalid || s_bresp!=3)$fatal(1,"wide B changed under backpressure");end
    @(negedge clk);s_bready=1;wait(s_b_count==1);repeat(4)tick();
    for(int j=0;j<8192;j++)if(memory[j]!==gold[j])$fatal(1,"sparse write byte mismatch SW=%0d byte=%0d",SW,j);
    if(m_ar_count<2 || m_aw_count<2 || m_r_count!=512 || m_w_count!=512 ||
       m_b_count!=m_aw_count || s_read_count!=BEATS || s_write_count!=BEATS || s_b_count!=1 ||
       r_active || w_active || b_pending || m_rvalid || m_bvalid)
      $fatal(1,"width converter terminal debts/counts");
    $display("FULL_CURRENT_AXI_DWIDTH_PASS SI=%0d MI=32 bytes=2048 address64=1 sparse_WSTRB=1 split_AR=%0d split_AW=%0d actual_R=%0d actual_W=%0d actual_B=%0d errors_merged=1 held_last_R=1 held_last_B=1 wide_B_backpressure=1 cycles=%0d",SW,m_ar_count,m_aw_count,m_r_count,m_w_count,m_b_count,cycles);
    $finish;
  end
endmodule
