`timescale 1ns/1ps
module laya_axi_13bo_owner_tb_v1;
  logic clk;
  logic rst_n;
  logic [12:0] desired_owner;
  logic [12:0] clear_error;
  logic [12:0] selected_owner;
  logic [12:0] debt_zero;
  logic [12:0] protocol_error;
  logic [12:0][1:0][63:0] owner_araddr;
  logic [12:0][63:0] memory_araddr;
  logic [12:0][1:0] owner_arid;
  logic [12:0] memory_arid;
  logic [12:0][1:0][7:0] owner_arlen;
  logic [12:0][7:0] memory_arlen;
  logic [12:0][1:0][2:0] owner_arsize;
  logic [12:0][2:0] memory_arsize;
  logic [12:0][1:0][1:0] owner_arburst;
  logic [12:0][1:0] memory_arburst;
  logic [12:0][1:0][1:0] owner_arlock;
  logic [12:0][1:0] memory_arlock;
  logic [12:0][1:0][3:0] owner_arcache;
  logic [12:0][3:0] memory_arcache;
  logic [12:0][1:0][2:0] owner_arprot;
  logic [12:0][2:0] memory_arprot;
  logic [12:0][1:0][3:0] owner_arqos;
  logic [12:0][3:0] memory_arqos;
  logic [12:0][1:0][3:0] owner_arregion;
  logic [12:0][3:0] memory_arregion;
  logic [12:0][1:0] owner_aruser;
  logic [12:0] memory_aruser;
  logic [12:0][1:0] owner_arvalid;
  logic [12:0] memory_arvalid;
  logic [12:0][1:0] owner_arready;
  logic [12:0] memory_arready;
  logic [12:0][1:0][63:0] owner_awaddr;
  logic [12:0][63:0] memory_awaddr;
  logic [12:0][1:0] owner_awid;
  logic [12:0] memory_awid;
  logic [12:0][1:0][7:0] owner_awlen;
  logic [12:0][7:0] memory_awlen;
  logic [12:0][1:0][2:0] owner_awsize;
  logic [12:0][2:0] memory_awsize;
  logic [12:0][1:0][1:0] owner_awburst;
  logic [12:0][1:0] memory_awburst;
  logic [12:0][1:0][1:0] owner_awlock;
  logic [12:0][1:0] memory_awlock;
  logic [12:0][1:0][3:0] owner_awcache;
  logic [12:0][3:0] memory_awcache;
  logic [12:0][1:0][2:0] owner_awprot;
  logic [12:0][2:0] memory_awprot;
  logic [12:0][1:0][3:0] owner_awqos;
  logic [12:0][3:0] memory_awqos;
  logic [12:0][1:0][3:0] owner_awregion;
  logic [12:0][3:0] memory_awregion;
  logic [12:0][1:0] owner_awuser;
  logic [12:0] memory_awuser;
  logic [12:0][1:0] owner_awvalid;
  logic [12:0] memory_awvalid;
  logic [12:0][1:0] owner_awready;
  logic [12:0] memory_awready;
  logic [12:0][1:0][31:0] owner_wdata;
  logic [12:0][31:0] memory_wdata;
  logic [12:0][1:0][3:0] owner_wstrb;
  logic [12:0][3:0] memory_wstrb;
  logic [12:0][1:0] owner_wid;
  logic [12:0] memory_wid;
  logic [12:0][1:0] owner_wuser;
  logic [12:0] memory_wuser;
  logic [12:0][1:0] owner_wlast;
  logic [12:0] memory_wlast;
  logic [12:0][1:0] owner_wvalid;
  logic [12:0] memory_wvalid;
  logic [12:0][1:0] owner_wready;
  logic [12:0] memory_wready;
  logic [12:0][1:0][31:0] owner_rdata;
  logic [12:0][31:0] memory_rdata;
  logic [12:0][1:0][1:0] owner_rresp;
  logic [12:0][1:0] memory_rresp;
  logic [12:0][1:0] owner_rid;
  logic [12:0] memory_rid;
  logic [12:0][1:0] owner_ruser;
  logic [12:0] memory_ruser;
  logic [12:0][1:0] owner_rlast;
  logic [12:0] memory_rlast;
  logic [12:0][1:0] owner_rvalid;
  logic [12:0] memory_rvalid;
  logic [12:0][1:0] owner_rready;
  logic [12:0] memory_rready;
  logic [12:0][1:0][1:0] owner_bresp;
  logic [12:0][1:0] memory_bresp;
  logic [12:0][1:0] owner_bid;
  logic [12:0] memory_bid;
  logic [12:0][1:0] owner_buser;
  logic [12:0] memory_buser;
  logic [12:0][1:0] owner_bvalid;
  logic [12:0] memory_bvalid;
  logic [12:0][1:0] owner_bready;
  logic [12:0] memory_bready;
  logic [12:0][31:0] accepted_ar;
  logic [12:0][31:0] returned_r;
  logic [12:0][31:0] accepted_aw;
  logic [12:0][31:0] accepted_w;
  logic [12:0][31:0] returned_b;
  laya_axi_13bo_owner_v1 dut(
    .clk,
    .rst_n,
    .desired_owner,
    .clear_error,
    .selected_owner,
    .debt_zero,
    .protocol_error,
    .owner_araddr,
    .memory_araddr,
    .owner_arid,
    .memory_arid,
    .owner_arlen,
    .memory_arlen,
    .owner_arsize,
    .memory_arsize,
    .owner_arburst,
    .memory_arburst,
    .owner_arlock,
    .memory_arlock,
    .owner_arcache,
    .memory_arcache,
    .owner_arprot,
    .memory_arprot,
    .owner_arqos,
    .memory_arqos,
    .owner_arregion,
    .memory_arregion,
    .owner_aruser,
    .memory_aruser,
    .owner_arvalid,
    .memory_arvalid,
    .owner_arready,
    .memory_arready,
    .owner_awaddr,
    .memory_awaddr,
    .owner_awid,
    .memory_awid,
    .owner_awlen,
    .memory_awlen,
    .owner_awsize,
    .memory_awsize,
    .owner_awburst,
    .memory_awburst,
    .owner_awlock,
    .memory_awlock,
    .owner_awcache,
    .memory_awcache,
    .owner_awprot,
    .memory_awprot,
    .owner_awqos,
    .memory_awqos,
    .owner_awregion,
    .memory_awregion,
    .owner_awuser,
    .memory_awuser,
    .owner_awvalid,
    .memory_awvalid,
    .owner_awready,
    .memory_awready,
    .owner_wdata,
    .memory_wdata,
    .owner_wstrb,
    .memory_wstrb,
    .owner_wid,
    .memory_wid,
    .owner_wuser,
    .memory_wuser,
    .owner_wlast,
    .memory_wlast,
    .owner_wvalid,
    .memory_wvalid,
    .owner_wready,
    .memory_wready,
    .owner_rdata,
    .memory_rdata,
    .owner_rresp,
    .memory_rresp,
    .owner_rid,
    .memory_rid,
    .owner_ruser,
    .memory_ruser,
    .owner_rlast,
    .memory_rlast,
    .owner_rvalid,
    .memory_rvalid,
    .owner_rready,
    .memory_rready,
    .owner_bresp,
    .memory_bresp,
    .owner_bid,
    .memory_bid,
    .owner_buser,
    .memory_buser,
    .owner_bvalid,
    .memory_bvalid,
    .owner_bready,
    .memory_bready,
    .accepted_ar,
    .returned_r,
    .accepted_aw,
    .accepted_w,
    .returned_b
  );
  initial clk=0;always #5 clk=~clk;
  int cycles=0,transactions=0;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>3000)$fatal(1,"13BO owner cycle cap");
    if(rst_n)for(int bo=0;bo<13;bo++)begin
      if(owner_arready[bo][!selected_owner[bo]] || owner_awready[bo][!selected_owner[bo]] ||
         owner_wready[bo][!selected_owner[bo]] || owner_rvalid[bo][!selected_owner[bo]] ||
         owner_bvalid[bo][!selected_owner[bo]])$fatal(1,"13BO cross-owner leakage bo=%0d",bo);
      if(memory_arvalid[bo] && memory_araddr[bo]!==owner_araddr[bo][selected_owner[bo]])
        $fatal(1,"named araddr mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arid[bo]!==owner_arid[bo][selected_owner[bo]])
        $fatal(1,"named arid mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arsize[bo]!==owner_arsize[bo][selected_owner[bo]])
        $fatal(1,"named arsize mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arburst[bo]!==owner_arburst[bo][selected_owner[bo]])
        $fatal(1,"named arburst mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arlock[bo]!==owner_arlock[bo][selected_owner[bo]])
        $fatal(1,"named arlock mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arcache[bo]!==owner_arcache[bo][selected_owner[bo]])
        $fatal(1,"named arcache mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arprot[bo]!==owner_arprot[bo][selected_owner[bo]])
        $fatal(1,"named arprot mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arqos[bo]!==owner_arqos[bo][selected_owner[bo]])
        $fatal(1,"named arqos mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arregion[bo]!==owner_arregion[bo][selected_owner[bo]])
        $fatal(1,"named arregion mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_aruser[bo]!==owner_aruser[bo][selected_owner[bo]])
        $fatal(1,"named aruser mismatch bo=%0d",bo);
      if(memory_arvalid[bo] && memory_arlen[bo]!==owner_arlen[bo][selected_owner[bo]])
        $fatal(1,"named arlen mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awaddr[bo]!==owner_awaddr[bo][selected_owner[bo]])
        $fatal(1,"named awaddr mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awid[bo]!==owner_awid[bo][selected_owner[bo]])
        $fatal(1,"named awid mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awsize[bo]!==owner_awsize[bo][selected_owner[bo]])
        $fatal(1,"named awsize mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awburst[bo]!==owner_awburst[bo][selected_owner[bo]])
        $fatal(1,"named awburst mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awlock[bo]!==owner_awlock[bo][selected_owner[bo]])
        $fatal(1,"named awlock mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awcache[bo]!==owner_awcache[bo][selected_owner[bo]])
        $fatal(1,"named awcache mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awprot[bo]!==owner_awprot[bo][selected_owner[bo]])
        $fatal(1,"named awprot mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awqos[bo]!==owner_awqos[bo][selected_owner[bo]])
        $fatal(1,"named awqos mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awregion[bo]!==owner_awregion[bo][selected_owner[bo]])
        $fatal(1,"named awregion mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awuser[bo]!==owner_awuser[bo][selected_owner[bo]])
        $fatal(1,"named awuser mismatch bo=%0d",bo);
      if(memory_awvalid[bo] && memory_awlen[bo]!==owner_awlen[bo][selected_owner[bo]])
        $fatal(1,"named awlen mismatch bo=%0d",bo);
      if(memory_wvalid[bo] && memory_wdata[bo]!==owner_wdata[bo][selected_owner[bo]])
        $fatal(1,"named wdata mismatch bo=%0d",bo);
      if(memory_wvalid[bo] && memory_wstrb[bo]!==owner_wstrb[bo][selected_owner[bo]])
        $fatal(1,"named wstrb mismatch bo=%0d",bo);
      if(memory_wvalid[bo] && memory_wid[bo]!==owner_wid[bo][selected_owner[bo]])
        $fatal(1,"named wid mismatch bo=%0d",bo);
      if(memory_wvalid[bo] && memory_wuser[bo]!==owner_wuser[bo][selected_owner[bo]])
        $fatal(1,"named wuser mismatch bo=%0d",bo);
      if(memory_wvalid[bo] && memory_wlast[bo]!==owner_wlast[bo][selected_owner[bo]])
        $fatal(1,"named wlast mismatch bo=%0d",bo);
      if(owner_rvalid[bo][selected_owner[bo]] && memory_rdata[bo]!==owner_rdata[bo][selected_owner[bo]])
        $fatal(1,"named rdata mismatch bo=%0d",bo);
      if(owner_rvalid[bo][selected_owner[bo]] && memory_rresp[bo]!==owner_rresp[bo][selected_owner[bo]])
        $fatal(1,"named rresp mismatch bo=%0d",bo);
      if(owner_rvalid[bo][selected_owner[bo]] && memory_rid[bo]!==owner_rid[bo][selected_owner[bo]])
        $fatal(1,"named rid mismatch bo=%0d",bo);
      if(owner_rvalid[bo][selected_owner[bo]] && memory_ruser[bo]!==owner_ruser[bo][selected_owner[bo]])
        $fatal(1,"named ruser mismatch bo=%0d",bo);
      if(owner_rvalid[bo][selected_owner[bo]] && memory_rlast[bo]!==owner_rlast[bo][selected_owner[bo]])
        $fatal(1,"named rlast mismatch bo=%0d",bo);
      if(owner_bvalid[bo][selected_owner[bo]] && memory_bresp[bo]!==owner_bresp[bo][selected_owner[bo]])
        $fatal(1,"named bresp mismatch bo=%0d",bo);
      if(owner_bvalid[bo][selected_owner[bo]] && memory_bid[bo]!==owner_bid[bo][selected_owner[bo]])
        $fatal(1,"named bid mismatch bo=%0d",bo);
      if(owner_bvalid[bo][selected_owner[bo]] && memory_buser[bo]!==owner_buser[bo][selected_owner[bo]])
        $fatal(1,"named buser mismatch bo=%0d",bo);
    end
  end
  initial begin
    rst_n=0;
    desired_owner=0;
    clear_error=0;
    owner_araddr=0;
    owner_arid=0;
    owner_arlen=0;
    owner_arsize=0;
    owner_arburst=0;
    owner_arlock=0;
    owner_arcache=0;
    owner_arprot=0;
    owner_arqos=0;
    owner_arregion=0;
    owner_aruser=0;
    owner_arvalid=0;
    memory_arready=0;
    owner_awaddr=0;
    owner_awid=0;
    owner_awlen=0;
    owner_awsize=0;
    owner_awburst=0;
    owner_awlock=0;
    owner_awcache=0;
    owner_awprot=0;
    owner_awqos=0;
    owner_awregion=0;
    owner_awuser=0;
    owner_awvalid=0;
    memory_awready=0;
    owner_wdata=0;
    owner_wstrb=0;
    owner_wid=0;
    owner_wuser=0;
    owner_wlast=0;
    owner_wvalid=0;
    memory_wready=0;
    memory_rdata=0;
    memory_rresp=0;
    memory_rid=0;
    memory_ruser=0;
    memory_rlast=0;
    memory_rvalid=0;
    owner_rready=0;
    memory_bresp=0;
    memory_bid=0;
    memory_buser=0;
    memory_bvalid=0;
    owner_bready=0;
    memory_arready='1;memory_awready='1;memory_wready='1;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    for(int bo=0;bo<13;bo++)begin
      for(int src=0;src<2;src++)begin
        @(negedge clk);desired_owner[bo]=1'(src);
        repeat(3)tick();if(selected_owner[bo]!=src || !debt_zero[bo])$fatal(1,"13BO idle selection bo=%0d",bo);
        @(negedge clk);
        owner_araddr[bo][src]=64'h8123456789000000+64'(bo*4096+src*64+0);
        owner_arlen[bo][src]=0;
        owner_arid[bo][src]=1'(bo*7+src*11+4);
        owner_arsize[bo][src]=3'(bo*7+src*11+6);
        owner_arburst[bo][src]=2'(bo*7+src*11+7);
        owner_arlock[bo][src]=2'(bo*7+src*11+6);
        owner_arcache[bo][src]=4'(bo*7+src*11+7);
        owner_arprot[bo][src]=3'(bo*7+src*11+6);
        owner_arqos[bo][src]=4'(bo*7+src*11+5);
        owner_arregion[bo][src]=4'(bo*7+src*11+8);
        owner_aruser[bo][src]=1'(bo*7+src*11+6);
        owner_awaddr[bo][src]=64'h8123456789000000+64'(bo*4096+src*64+128);
        owner_awlen[bo][src]=0;
        owner_awid[bo][src]=1'(bo*7+src*11+4);
        owner_awsize[bo][src]=3'(bo*7+src*11+6);
        owner_awburst[bo][src]=2'(bo*7+src*11+7);
        owner_awlock[bo][src]=2'(bo*7+src*11+6);
        owner_awcache[bo][src]=4'(bo*7+src*11+7);
        owner_awprot[bo][src]=3'(bo*7+src*11+6);
        owner_awqos[bo][src]=4'(bo*7+src*11+5);
        owner_awregion[bo][src]=4'(bo*7+src*11+8);
        owner_awuser[bo][src]=1'(bo*7+src*11+6);
        owner_wdata[bo][src]=32'hf0123456^32'(bo*67+src*31);
        owner_wstrb[bo][src]=4'(bo+src+1);owner_wid[bo][src]=1'(bo);owner_wuser[bo][src]=1'(src);
        owner_wlast[bo][src]=1;owner_arvalid[bo][src]=1;owner_awvalid[bo][src]=1;owner_wvalid[bo][src]=1;
        #1;if(!owner_arready[bo][src] || !owner_awready[bo][src] || !owner_wready[bo][src])$fatal(1,"13BO admission readiness");
        tick();@(negedge clk);owner_arvalid[bo][src]=0;owner_awvalid[bo][src]=0;owner_wvalid[bo][src]=0;
        desired_owner[bo]=!1'(src);
        memory_rdata[bo]=32'h98765432^32'(bo*127+src*7);memory_rresp[bo]=2'(bo+src);
        memory_rid[bo]=1'(src);memory_ruser[bo]=!1'(src);memory_rlast[bo]=1;memory_rvalid[bo]=1;
        memory_bresp[bo]=2'(bo+src+1);memory_bid[bo]=!1'(src);memory_buser[bo]=1'(src);memory_bvalid[bo]=1;
        repeat(5)begin tick();if(selected_owner[bo]!=src || debt_zero[bo] || memory_rready[bo] || memory_bready[bo])$fatal(1,"13BO held response debt bo=%0d",bo);end
        @(negedge clk);owner_rready[bo][src]=1;owner_bready[bo][src]=1;
        tick();@(negedge clk);memory_rvalid[bo]=0;memory_bvalid[bo]=0;owner_rready[bo][src]=0;owner_bready[bo][src]=0;
        repeat(4)tick();if(selected_owner[bo]!=!1'(src) || !debt_zero[bo] || protocol_error[bo])$fatal(1,"13BO safe return bo=%0d",bo);
        transactions++;
      end
      if(accepted_ar[bo]!=2 || returned_r[bo]!=2 || accepted_aw[bo]!=2 || accepted_w[bo]!=2 || returned_b[bo]!=2)
        $fatal(1,"13BO counter coverage bo=%0d",bo);
    end
    if(selected_owner!=0 || debt_zero!='1 || protocol_error!=0 || transactions!=26)$fatal(1,"13BO final state");
    $display("FULL_CURRENT_13BO_OWNER_PASS BOs=13 owners=2 transactions=26 named_fields=45 AR=26 R=26 AW=26 W=26 B=26 held_R_B=26 all_ID_USER_LOCK_REGION_RESP=1 cycles=%0d",cycles);$finish;
  end
endmodule
