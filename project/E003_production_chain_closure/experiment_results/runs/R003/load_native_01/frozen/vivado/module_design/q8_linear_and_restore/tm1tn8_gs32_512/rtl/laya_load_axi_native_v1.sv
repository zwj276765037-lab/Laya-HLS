`timescale 1ns/1ps
// Read-only LOAD adapter. One converter per actual q0/q1/scale/AUX BO.
// Cold reset only; selected service ownership survives accepted SI reads,
// offered SI/MI AR and buffered SI R until their actual LAST handshakes.
module laya_load_axi_native_v1(
  input logic clk,
  input logic rst_n,
  input logic service_select,
  input logic [12:0] clear_error,
  output logic [12:0] selected_owner,
  output logic [12:0] debt_zero,
  output logic [12:0] protocol_error,
  output logic physical_debt_zero,
  output logic [3:0] upstream_read_pending,
  input logic [12:0][63:0] controller_araddr,
  output logic [12:0][63:0] memory_araddr,
  input logic [12:0] controller_arid,
  output logic [12:0] memory_arid,
  input logic [12:0][7:0] controller_arlen,
  output logic [12:0][7:0] memory_arlen,
  input logic [12:0][2:0] controller_arsize,
  output logic [12:0][2:0] memory_arsize,
  input logic [12:0][1:0] controller_arburst,
  output logic [12:0][1:0] memory_arburst,
  input logic [12:0][1:0] controller_arlock,
  output logic [12:0][1:0] memory_arlock,
  input logic [12:0][3:0] controller_arcache,
  output logic [12:0][3:0] memory_arcache,
  input logic [12:0][2:0] controller_arprot,
  output logic [12:0][2:0] memory_arprot,
  input logic [12:0][3:0] controller_arqos,
  output logic [12:0][3:0] memory_arqos,
  input logic [12:0][3:0] controller_arregion,
  output logic [12:0][3:0] memory_arregion,
  input logic [12:0] controller_aruser,
  output logic [12:0] memory_aruser,
  input logic [12:0] controller_arvalid,
  output logic [12:0] memory_arvalid,
  output logic [12:0] controller_arready,
  input logic [12:0] memory_arready,
  input logic [12:0][63:0] controller_awaddr,
  output logic [12:0][63:0] memory_awaddr,
  input logic [12:0] controller_awid,
  output logic [12:0] memory_awid,
  input logic [12:0][7:0] controller_awlen,
  output logic [12:0][7:0] memory_awlen,
  input logic [12:0][2:0] controller_awsize,
  output logic [12:0][2:0] memory_awsize,
  input logic [12:0][1:0] controller_awburst,
  output logic [12:0][1:0] memory_awburst,
  input logic [12:0][1:0] controller_awlock,
  output logic [12:0][1:0] memory_awlock,
  input logic [12:0][3:0] controller_awcache,
  output logic [12:0][3:0] memory_awcache,
  input logic [12:0][2:0] controller_awprot,
  output logic [12:0][2:0] memory_awprot,
  input logic [12:0][3:0] controller_awqos,
  output logic [12:0][3:0] memory_awqos,
  input logic [12:0][3:0] controller_awregion,
  output logic [12:0][3:0] memory_awregion,
  input logic [12:0] controller_awuser,
  output logic [12:0] memory_awuser,
  input logic [12:0] controller_awvalid,
  output logic [12:0] memory_awvalid,
  output logic [12:0] controller_awready,
  input logic [12:0] memory_awready,
  input logic [12:0][31:0] controller_wdata,
  output logic [12:0][31:0] memory_wdata,
  input logic [12:0][3:0] controller_wstrb,
  output logic [12:0][3:0] memory_wstrb,
  input logic [12:0] controller_wid,
  output logic [12:0] memory_wid,
  input logic [12:0] controller_wuser,
  output logic [12:0] memory_wuser,
  input logic [12:0] controller_wlast,
  output logic [12:0] memory_wlast,
  input logic [12:0] controller_wvalid,
  output logic [12:0] memory_wvalid,
  output logic [12:0] controller_wready,
  input logic [12:0] memory_wready,
  output logic [12:0][31:0] controller_rdata,
  input logic [12:0][31:0] memory_rdata,
  output logic [12:0][1:0] controller_rresp,
  input logic [12:0][1:0] memory_rresp,
  output logic [12:0] controller_rid,
  input logic [12:0] memory_rid,
  output logic [12:0] controller_ruser,
  input logic [12:0] memory_ruser,
  output logic [12:0] controller_rlast,
  input logic [12:0] memory_rlast,
  output logic [12:0] controller_rvalid,
  input logic [12:0] memory_rvalid,
  input logic [12:0] controller_rready,
  output logic [12:0] memory_rready,
  output logic [12:0][1:0] controller_bresp,
  input logic [12:0][1:0] memory_bresp,
  output logic [12:0] controller_bid,
  input logic [12:0] memory_bid,
  output logic [12:0] controller_buser,
  input logic [12:0] memory_buser,
  output logic [12:0] controller_bvalid,
  input logic [12:0] memory_bvalid,
  input logic [12:0] controller_bready,
  output logic [12:0] memory_bready,
  input logic [2:0][63:0] load_araddr,
  input logic [2:0][7:0] load_arlen,
  input logic [2:0][2:0] load_arsize,
  input logic [2:0][1:0] load_arburst,
  input logic [2:0] load_arvalid,
  output logic [2:0] load_arready,
  output logic [2:0][511:0] load_rdata,
  output logic [2:0][1:0] load_rresp,
  output logic [2:0] load_rlast,
  output logic [2:0] load_rvalid,
  input logic [2:0] load_rready,
  input logic [63:0] aux_araddr,
  input logic [7:0] aux_arlen,
  input logic [2:0] aux_arsize,
  input logic [1:0] aux_arburst,
  input logic aux_arvalid,
  output logic aux_arready,
  output logic [127:0] aux_rdata,
  output logic [1:0] aux_rresp,
  output logic aux_rlast,
  output logic aux_rvalid,
  input logic aux_rready,
  output logic [12:0][31:0] accepted_ar,
  output logic [12:0][31:0] returned_r,
  output logic [12:0][31:0] accepted_aw,
  output logic [12:0][31:0] accepted_w,
  output logic [12:0][31:0] returned_b
);
  logic [12:0] desired_owner;
  logic [12:0][1:0][63:0] owner_araddr;
  logic [12:0][1:0] owner_arid;
  logic [12:0][1:0][7:0] owner_arlen;
  logic [12:0][1:0][2:0] owner_arsize;
  logic [12:0][1:0][1:0] owner_arburst;
  logic [12:0][1:0][1:0] owner_arlock;
  logic [12:0][1:0][3:0] owner_arcache;
  logic [12:0][1:0][2:0] owner_arprot;
  logic [12:0][1:0][3:0] owner_arqos;
  logic [12:0][1:0][3:0] owner_arregion;
  logic [12:0][1:0] owner_aruser;
  logic [12:0][1:0] owner_arvalid;
  logic [12:0][1:0] owner_arready;
  logic [12:0][1:0][63:0] owner_awaddr;
  logic [12:0][1:0] owner_awid;
  logic [12:0][1:0][7:0] owner_awlen;
  logic [12:0][1:0][2:0] owner_awsize;
  logic [12:0][1:0][1:0] owner_awburst;
  logic [12:0][1:0][1:0] owner_awlock;
  logic [12:0][1:0][3:0] owner_awcache;
  logic [12:0][1:0][2:0] owner_awprot;
  logic [12:0][1:0][3:0] owner_awqos;
  logic [12:0][1:0][3:0] owner_awregion;
  logic [12:0][1:0] owner_awuser;
  logic [12:0][1:0] owner_awvalid;
  logic [12:0][1:0] owner_awready;
  logic [12:0][1:0][31:0] owner_wdata;
  logic [12:0][1:0][3:0] owner_wstrb;
  logic [12:0][1:0] owner_wid;
  logic [12:0][1:0] owner_wuser;
  logic [12:0][1:0] owner_wlast;
  logic [12:0][1:0] owner_wvalid;
  logic [12:0][1:0] owner_wready;
  logic [12:0][1:0][31:0] owner_rdata;
  logic [12:0][1:0][1:0] owner_rresp;
  logic [12:0][1:0] owner_rid;
  logic [12:0][1:0] owner_ruser;
  logic [12:0][1:0] owner_rlast;
  logic [12:0][1:0] owner_rvalid;
  logic [12:0][1:0] owner_rready;
  logic [12:0][1:0][1:0] owner_bresp;
  logic [12:0][1:0] owner_bid;
  logic [12:0][1:0] owner_buser;
  logic [12:0][1:0] owner_bvalid;
  logic [12:0][1:0] owner_bready;
  logic [3:0][63:0] cv_araddr;
  logic [3:0] cv_arid;
  logic [3:0][7:0] cv_arlen;
  logic [3:0][2:0] cv_arsize;
  logic [3:0][1:0] cv_arburst;
  logic [3:0][1:0] cv_arlock;
  logic [3:0][3:0] cv_arcache;
  logic [3:0][2:0] cv_arprot;
  logic [3:0][3:0] cv_arqos;
  logic [3:0][3:0] cv_arregion;
  logic [3:0] cv_aruser;
  logic [3:0] cv_arvalid;
  logic [3:0] cv_arready;
  logic [3:0][63:0] cv_awaddr;
  logic [3:0] cv_awid;
  logic [3:0][7:0] cv_awlen;
  logic [3:0][2:0] cv_awsize;
  logic [3:0][1:0] cv_awburst;
  logic [3:0][1:0] cv_awlock;
  logic [3:0][3:0] cv_awcache;
  logic [3:0][2:0] cv_awprot;
  logic [3:0][3:0] cv_awqos;
  logic [3:0][3:0] cv_awregion;
  logic [3:0] cv_awuser;
  logic [3:0] cv_awvalid;
  logic [3:0] cv_awready;
  logic [3:0][31:0] cv_wdata;
  logic [3:0][3:0] cv_wstrb;
  logic [3:0] cv_wid;
  logic [3:0] cv_wuser;
  logic [3:0] cv_wlast;
  logic [3:0] cv_wvalid;
  logic [3:0] cv_wready;
  logic [3:0][31:0] cv_rdata;
  logic [3:0][1:0] cv_rresp;
  logic [3:0] cv_rid;
  logic [3:0] cv_ruser;
  logic [3:0] cv_rlast;
  logic [3:0] cv_rvalid;
  logic [3:0] cv_rready;
  logic [3:0][1:0] cv_bresp;
  logic [3:0] cv_bid;
  logic [3:0] cv_buser;
  logic [3:0] cv_bvalid;
  logic [3:0] cv_bready;
  logic [3:0] si_arvalid,si_arready,si_rvalid,si_rready,si_rlast;
  assign physical_debt_zero=(&debt_zero) && upstream_read_pending==0 &&
    si_arvalid==0 && si_rvalid==0 && cv_arvalid==0 && cv_rvalid==0;
  for(genvar bo=0;bo<13;bo++)begin : native_bo
    if(bo>=2 && bo<=5)begin : load_bo
      assign desired_owner[bo]=service_select || upstream_read_pending[bo-2] ||
        si_arvalid[bo-2] || si_rvalid[bo-2] || cv_arvalid[bo-2] || cv_rvalid[bo-2];
    end else assign desired_owner[bo]=0;
    assign owner_araddr[bo][0]=controller_araddr[bo];
    if(bo>=2 && bo<=5)assign owner_araddr[bo][1]=cv_araddr[bo-2];
    else assign owner_araddr[bo][1]=0;
    assign owner_arid[bo][0]=controller_arid[bo];
    if(bo>=2 && bo<=5)assign owner_arid[bo][1]=cv_arid[bo-2];
    else assign owner_arid[bo][1]=0;
    assign owner_arlen[bo][0]=controller_arlen[bo];
    if(bo>=2 && bo<=5)assign owner_arlen[bo][1]=cv_arlen[bo-2];
    else assign owner_arlen[bo][1]=0;
    assign owner_arsize[bo][0]=controller_arsize[bo];
    if(bo>=2 && bo<=5)assign owner_arsize[bo][1]=cv_arsize[bo-2];
    else assign owner_arsize[bo][1]=0;
    assign owner_arburst[bo][0]=controller_arburst[bo];
    if(bo>=2 && bo<=5)assign owner_arburst[bo][1]=cv_arburst[bo-2];
    else assign owner_arburst[bo][1]=0;
    assign owner_arlock[bo][0]=controller_arlock[bo];
    if(bo>=2 && bo<=5)assign owner_arlock[bo][1]=cv_arlock[bo-2];
    else assign owner_arlock[bo][1]=0;
    assign owner_arcache[bo][0]=controller_arcache[bo];
    if(bo>=2 && bo<=5)assign owner_arcache[bo][1]=cv_arcache[bo-2];
    else assign owner_arcache[bo][1]=0;
    assign owner_arprot[bo][0]=controller_arprot[bo];
    if(bo>=2 && bo<=5)assign owner_arprot[bo][1]=cv_arprot[bo-2];
    else assign owner_arprot[bo][1]=0;
    assign owner_arqos[bo][0]=controller_arqos[bo];
    if(bo>=2 && bo<=5)assign owner_arqos[bo][1]=cv_arqos[bo-2];
    else assign owner_arqos[bo][1]=0;
    assign owner_arregion[bo][0]=controller_arregion[bo];
    if(bo>=2 && bo<=5)assign owner_arregion[bo][1]=cv_arregion[bo-2];
    else assign owner_arregion[bo][1]=0;
    assign owner_aruser[bo][0]=controller_aruser[bo];
    if(bo>=2 && bo<=5)assign owner_aruser[bo][1]=cv_aruser[bo-2];
    else assign owner_aruser[bo][1]=0;
    assign owner_arvalid[bo][0]=controller_arvalid[bo];
    if(bo>=2 && bo<=5)assign owner_arvalid[bo][1]=cv_arvalid[bo-2];
    else assign owner_arvalid[bo][1]=0;
    assign controller_arready[bo]=owner_arready[bo][0];
    if(bo>=2 && bo<=5)assign cv_arready[bo-2]=owner_arready[bo][1];
    assign owner_awaddr[bo][0]=controller_awaddr[bo];
    if(bo>=2 && bo<=5)assign owner_awaddr[bo][1]=cv_awaddr[bo-2];
    else assign owner_awaddr[bo][1]=0;
    assign owner_awid[bo][0]=controller_awid[bo];
    if(bo>=2 && bo<=5)assign owner_awid[bo][1]=cv_awid[bo-2];
    else assign owner_awid[bo][1]=0;
    assign owner_awlen[bo][0]=controller_awlen[bo];
    if(bo>=2 && bo<=5)assign owner_awlen[bo][1]=cv_awlen[bo-2];
    else assign owner_awlen[bo][1]=0;
    assign owner_awsize[bo][0]=controller_awsize[bo];
    if(bo>=2 && bo<=5)assign owner_awsize[bo][1]=cv_awsize[bo-2];
    else assign owner_awsize[bo][1]=0;
    assign owner_awburst[bo][0]=controller_awburst[bo];
    if(bo>=2 && bo<=5)assign owner_awburst[bo][1]=cv_awburst[bo-2];
    else assign owner_awburst[bo][1]=0;
    assign owner_awlock[bo][0]=controller_awlock[bo];
    if(bo>=2 && bo<=5)assign owner_awlock[bo][1]=cv_awlock[bo-2];
    else assign owner_awlock[bo][1]=0;
    assign owner_awcache[bo][0]=controller_awcache[bo];
    if(bo>=2 && bo<=5)assign owner_awcache[bo][1]=cv_awcache[bo-2];
    else assign owner_awcache[bo][1]=0;
    assign owner_awprot[bo][0]=controller_awprot[bo];
    if(bo>=2 && bo<=5)assign owner_awprot[bo][1]=cv_awprot[bo-2];
    else assign owner_awprot[bo][1]=0;
    assign owner_awqos[bo][0]=controller_awqos[bo];
    if(bo>=2 && bo<=5)assign owner_awqos[bo][1]=cv_awqos[bo-2];
    else assign owner_awqos[bo][1]=0;
    assign owner_awregion[bo][0]=controller_awregion[bo];
    if(bo>=2 && bo<=5)assign owner_awregion[bo][1]=cv_awregion[bo-2];
    else assign owner_awregion[bo][1]=0;
    assign owner_awuser[bo][0]=controller_awuser[bo];
    if(bo>=2 && bo<=5)assign owner_awuser[bo][1]=cv_awuser[bo-2];
    else assign owner_awuser[bo][1]=0;
    assign owner_awvalid[bo][0]=controller_awvalid[bo];
    if(bo>=2 && bo<=5)assign owner_awvalid[bo][1]=cv_awvalid[bo-2];
    else assign owner_awvalid[bo][1]=0;
    assign controller_awready[bo]=owner_awready[bo][0];
    if(bo>=2 && bo<=5)assign cv_awready[bo-2]=owner_awready[bo][1];
    assign owner_wdata[bo][0]=controller_wdata[bo];
    if(bo>=2 && bo<=5)assign owner_wdata[bo][1]=cv_wdata[bo-2];
    else assign owner_wdata[bo][1]=0;
    assign owner_wstrb[bo][0]=controller_wstrb[bo];
    if(bo>=2 && bo<=5)assign owner_wstrb[bo][1]=cv_wstrb[bo-2];
    else assign owner_wstrb[bo][1]=0;
    assign owner_wid[bo][0]=controller_wid[bo];
    if(bo>=2 && bo<=5)assign owner_wid[bo][1]=cv_wid[bo-2];
    else assign owner_wid[bo][1]=0;
    assign owner_wuser[bo][0]=controller_wuser[bo];
    if(bo>=2 && bo<=5)assign owner_wuser[bo][1]=cv_wuser[bo-2];
    else assign owner_wuser[bo][1]=0;
    assign owner_wlast[bo][0]=controller_wlast[bo];
    if(bo>=2 && bo<=5)assign owner_wlast[bo][1]=cv_wlast[bo-2];
    else assign owner_wlast[bo][1]=0;
    assign owner_wvalid[bo][0]=controller_wvalid[bo];
    if(bo>=2 && bo<=5)assign owner_wvalid[bo][1]=cv_wvalid[bo-2];
    else assign owner_wvalid[bo][1]=0;
    assign controller_wready[bo]=owner_wready[bo][0];
    if(bo>=2 && bo<=5)assign cv_wready[bo-2]=owner_wready[bo][1];
    assign controller_rdata[bo]=owner_rdata[bo][0];
    if(bo>=2 && bo<=5)assign cv_rdata[bo-2]=owner_rdata[bo][1];
    assign controller_rresp[bo]=owner_rresp[bo][0];
    if(bo>=2 && bo<=5)assign cv_rresp[bo-2]=owner_rresp[bo][1];
    assign controller_rid[bo]=owner_rid[bo][0];
    if(bo>=2 && bo<=5)assign cv_rid[bo-2]=owner_rid[bo][1];
    assign controller_ruser[bo]=owner_ruser[bo][0];
    if(bo>=2 && bo<=5)assign cv_ruser[bo-2]=owner_ruser[bo][1];
    assign controller_rlast[bo]=owner_rlast[bo][0];
    if(bo>=2 && bo<=5)assign cv_rlast[bo-2]=owner_rlast[bo][1];
    assign controller_rvalid[bo]=owner_rvalid[bo][0];
    if(bo>=2 && bo<=5)assign cv_rvalid[bo-2]=owner_rvalid[bo][1];
    assign owner_rready[bo][0]=controller_rready[bo];
    if(bo>=2 && bo<=5)assign owner_rready[bo][1]=cv_rready[bo-2];
    else assign owner_rready[bo][1]=0;
    assign controller_bresp[bo]=owner_bresp[bo][0];
    if(bo>=2 && bo<=5)assign cv_bresp[bo-2]=owner_bresp[bo][1];
    assign controller_bid[bo]=owner_bid[bo][0];
    if(bo>=2 && bo<=5)assign cv_bid[bo-2]=owner_bid[bo][1];
    assign controller_buser[bo]=owner_buser[bo][0];
    if(bo>=2 && bo<=5)assign cv_buser[bo-2]=owner_buser[bo][1];
    assign controller_bvalid[bo]=owner_bvalid[bo][0];
    if(bo>=2 && bo<=5)assign cv_bvalid[bo-2]=owner_bvalid[bo][1];
    assign owner_bready[bo][0]=controller_bready[bo];
    if(bo>=2 && bo<=5)assign owner_bready[bo][1]=cv_bready[bo-2];
    else assign owner_bready[bo][1]=0;
  end
  always_ff @(posedge clk)begin
    if(!rst_n)upstream_read_pending<=0;
    else for(int p=0;p<4;p++)begin
      if(si_arvalid[p] && si_arready[p])upstream_read_pending[p]<=1;
      if(si_rvalid[p] && si_rready[p] && si_rlast[p])upstream_read_pending[p]<=0;
    end
  end
  laya_axi_13bo_owner_v1 native_owners(
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
  assign si_arvalid[0]=load_arvalid[0];
  assign load_arready[0]=si_arready[0] && selected_owner[2];
  assign si_rvalid[0]=load_rvalid[0];
  assign si_rready[0]=load_rready[0];
  assign si_rlast[0]=load_rlast[0];
  assign cv_arid[0]=0;
  assign cv_arregion[0]=0;
  assign cv_aruser[0]=0;
  assign cv_awaddr[0]=0;
  assign cv_awid[0]=0;
  assign cv_awlen[0]=0;
  assign cv_awsize[0]=0;
  assign cv_awburst[0]=0;
  assign cv_awlock[0]=0;
  assign cv_awcache[0]=0;
  assign cv_awprot[0]=0;
  assign cv_awqos[0]=0;
  assign cv_awregion[0]=0;
  assign cv_awuser[0]=0;
  assign cv_awvalid[0]=0;
  assign cv_wdata[0]=0;
  assign cv_wstrb[0]=0;
  assign cv_wid[0]=0;
  assign cv_wuser[0]=0;
  assign cv_wlast[0]=0;
  assign cv_wvalid[0]=0;
  assign cv_bready[0]=0;
  logic cv_arlock0;
  assign cv_arlock[0]={1'b0,cv_arlock0};
  laya_load_dwidth512_v1 converter0(
    .s_axi_aclk(clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr(64'd0),
    .s_axi_awlen(8'd0),
    .s_axi_awsize(3'd0),
    .s_axi_awburst(2'd1),
    .s_axi_awlock(1'd0),
    .s_axi_awcache(4'd0),
    .s_axi_awprot(3'd0),
    .s_axi_awqos(4'd0),
    .s_axi_awvalid(1'd0),
    .s_axi_awready(),
    .s_axi_wdata(512'd0),
    .s_axi_wstrb(64'd0),
    .s_axi_wlast(1'd0),
    .s_axi_wvalid(1'd0),
    .s_axi_wready(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'd1),
    .s_axi_araddr(load_araddr[0]),
    .s_axi_arlen(load_arlen[0]),
    .s_axi_arsize(load_arsize[0]),
    .s_axi_arburst(load_arburst[0]),
    .s_axi_arvalid(si_arvalid[0] && selected_owner[2]),
    .s_axi_arready(si_arready[0]),
    .s_axi_arlock(1'd0),
    .s_axi_arcache(4'd3),
    .s_axi_arprot(3'd0),
    .s_axi_arqos(4'd0),
    .s_axi_rdata(load_rdata[0]),
    .s_axi_rresp(load_rresp[0]),
    .s_axi_rlast(load_rlast[0]),
    .s_axi_rvalid(load_rvalid[0]),
    .s_axi_rready(load_rready[0]),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awvalid(),
    .m_axi_awready(1'd0),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'd0),
    .m_axi_bresp(2'd0),
    .m_axi_bvalid(1'd0),
    .m_axi_bready(),
    .m_axi_araddr(cv_araddr[0]),
    .m_axi_arlen(cv_arlen[0]),
    .m_axi_arsize(cv_arsize[0]),
    .m_axi_arburst(cv_arburst[0]),
    .m_axi_arlock(cv_arlock0),
    .m_axi_arcache(cv_arcache[0]),
    .m_axi_arprot(cv_arprot[0]),
    .m_axi_arqos(cv_arqos[0]),
    .m_axi_arvalid(cv_arvalid[0]),
    .m_axi_arready(cv_arready[0]),
    .m_axi_rdata(cv_rdata[0]),
    .m_axi_rresp(cv_rresp[0]),
    .m_axi_rlast(cv_rlast[0]),
    .m_axi_rvalid(cv_rvalid[0]),
    .m_axi_rready(cv_rready[0])
  );
  assign si_arvalid[1]=load_arvalid[1];
  assign load_arready[1]=si_arready[1] && selected_owner[3];
  assign si_rvalid[1]=load_rvalid[1];
  assign si_rready[1]=load_rready[1];
  assign si_rlast[1]=load_rlast[1];
  assign cv_arid[1]=0;
  assign cv_arregion[1]=0;
  assign cv_aruser[1]=0;
  assign cv_awaddr[1]=0;
  assign cv_awid[1]=0;
  assign cv_awlen[1]=0;
  assign cv_awsize[1]=0;
  assign cv_awburst[1]=0;
  assign cv_awlock[1]=0;
  assign cv_awcache[1]=0;
  assign cv_awprot[1]=0;
  assign cv_awqos[1]=0;
  assign cv_awregion[1]=0;
  assign cv_awuser[1]=0;
  assign cv_awvalid[1]=0;
  assign cv_wdata[1]=0;
  assign cv_wstrb[1]=0;
  assign cv_wid[1]=0;
  assign cv_wuser[1]=0;
  assign cv_wlast[1]=0;
  assign cv_wvalid[1]=0;
  assign cv_bready[1]=0;
  logic cv_arlock1;
  assign cv_arlock[1]={1'b0,cv_arlock1};
  laya_load_dwidth512_v1 converter1(
    .s_axi_aclk(clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr(64'd0),
    .s_axi_awlen(8'd0),
    .s_axi_awsize(3'd0),
    .s_axi_awburst(2'd1),
    .s_axi_awlock(1'd0),
    .s_axi_awcache(4'd0),
    .s_axi_awprot(3'd0),
    .s_axi_awqos(4'd0),
    .s_axi_awvalid(1'd0),
    .s_axi_awready(),
    .s_axi_wdata(512'd0),
    .s_axi_wstrb(64'd0),
    .s_axi_wlast(1'd0),
    .s_axi_wvalid(1'd0),
    .s_axi_wready(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'd1),
    .s_axi_araddr(load_araddr[1]),
    .s_axi_arlen(load_arlen[1]),
    .s_axi_arsize(load_arsize[1]),
    .s_axi_arburst(load_arburst[1]),
    .s_axi_arvalid(si_arvalid[1] && selected_owner[3]),
    .s_axi_arready(si_arready[1]),
    .s_axi_arlock(1'd0),
    .s_axi_arcache(4'd3),
    .s_axi_arprot(3'd0),
    .s_axi_arqos(4'd0),
    .s_axi_rdata(load_rdata[1]),
    .s_axi_rresp(load_rresp[1]),
    .s_axi_rlast(load_rlast[1]),
    .s_axi_rvalid(load_rvalid[1]),
    .s_axi_rready(load_rready[1]),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awvalid(),
    .m_axi_awready(1'd0),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'd0),
    .m_axi_bresp(2'd0),
    .m_axi_bvalid(1'd0),
    .m_axi_bready(),
    .m_axi_araddr(cv_araddr[1]),
    .m_axi_arlen(cv_arlen[1]),
    .m_axi_arsize(cv_arsize[1]),
    .m_axi_arburst(cv_arburst[1]),
    .m_axi_arlock(cv_arlock1),
    .m_axi_arcache(cv_arcache[1]),
    .m_axi_arprot(cv_arprot[1]),
    .m_axi_arqos(cv_arqos[1]),
    .m_axi_arvalid(cv_arvalid[1]),
    .m_axi_arready(cv_arready[1]),
    .m_axi_rdata(cv_rdata[1]),
    .m_axi_rresp(cv_rresp[1]),
    .m_axi_rlast(cv_rlast[1]),
    .m_axi_rvalid(cv_rvalid[1]),
    .m_axi_rready(cv_rready[1])
  );
  assign si_arvalid[2]=load_arvalid[2];
  assign load_arready[2]=si_arready[2] && selected_owner[4];
  assign si_rvalid[2]=load_rvalid[2];
  assign si_rready[2]=load_rready[2];
  assign si_rlast[2]=load_rlast[2];
  assign cv_arid[2]=0;
  assign cv_arregion[2]=0;
  assign cv_aruser[2]=0;
  assign cv_awaddr[2]=0;
  assign cv_awid[2]=0;
  assign cv_awlen[2]=0;
  assign cv_awsize[2]=0;
  assign cv_awburst[2]=0;
  assign cv_awlock[2]=0;
  assign cv_awcache[2]=0;
  assign cv_awprot[2]=0;
  assign cv_awqos[2]=0;
  assign cv_awregion[2]=0;
  assign cv_awuser[2]=0;
  assign cv_awvalid[2]=0;
  assign cv_wdata[2]=0;
  assign cv_wstrb[2]=0;
  assign cv_wid[2]=0;
  assign cv_wuser[2]=0;
  assign cv_wlast[2]=0;
  assign cv_wvalid[2]=0;
  assign cv_bready[2]=0;
  logic cv_arlock2;
  assign cv_arlock[2]={1'b0,cv_arlock2};
  laya_load_dwidth512_v1 converter2(
    .s_axi_aclk(clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr(64'd0),
    .s_axi_awlen(8'd0),
    .s_axi_awsize(3'd0),
    .s_axi_awburst(2'd1),
    .s_axi_awlock(1'd0),
    .s_axi_awcache(4'd0),
    .s_axi_awprot(3'd0),
    .s_axi_awqos(4'd0),
    .s_axi_awvalid(1'd0),
    .s_axi_awready(),
    .s_axi_wdata(512'd0),
    .s_axi_wstrb(64'd0),
    .s_axi_wlast(1'd0),
    .s_axi_wvalid(1'd0),
    .s_axi_wready(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'd1),
    .s_axi_araddr(load_araddr[2]),
    .s_axi_arlen(load_arlen[2]),
    .s_axi_arsize(load_arsize[2]),
    .s_axi_arburst(load_arburst[2]),
    .s_axi_arvalid(si_arvalid[2] && selected_owner[4]),
    .s_axi_arready(si_arready[2]),
    .s_axi_arlock(1'd0),
    .s_axi_arcache(4'd3),
    .s_axi_arprot(3'd0),
    .s_axi_arqos(4'd0),
    .s_axi_rdata(load_rdata[2]),
    .s_axi_rresp(load_rresp[2]),
    .s_axi_rlast(load_rlast[2]),
    .s_axi_rvalid(load_rvalid[2]),
    .s_axi_rready(load_rready[2]),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awvalid(),
    .m_axi_awready(1'd0),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'd0),
    .m_axi_bresp(2'd0),
    .m_axi_bvalid(1'd0),
    .m_axi_bready(),
    .m_axi_araddr(cv_araddr[2]),
    .m_axi_arlen(cv_arlen[2]),
    .m_axi_arsize(cv_arsize[2]),
    .m_axi_arburst(cv_arburst[2]),
    .m_axi_arlock(cv_arlock2),
    .m_axi_arcache(cv_arcache[2]),
    .m_axi_arprot(cv_arprot[2]),
    .m_axi_arqos(cv_arqos[2]),
    .m_axi_arvalid(cv_arvalid[2]),
    .m_axi_arready(cv_arready[2]),
    .m_axi_rdata(cv_rdata[2]),
    .m_axi_rresp(cv_rresp[2]),
    .m_axi_rlast(cv_rlast[2]),
    .m_axi_rvalid(cv_rvalid[2]),
    .m_axi_rready(cv_rready[2])
  );
  assign si_arvalid[3]=aux_arvalid;
  assign aux_arready=si_arready[3] && selected_owner[5];
  assign si_rvalid[3]=aux_rvalid;
  assign si_rready[3]=aux_rready;
  assign si_rlast[3]=aux_rlast;
  assign cv_arid[3]=0;
  assign cv_arregion[3]=0;
  assign cv_aruser[3]=0;
  assign cv_awaddr[3]=0;
  assign cv_awid[3]=0;
  assign cv_awlen[3]=0;
  assign cv_awsize[3]=0;
  assign cv_awburst[3]=0;
  assign cv_awlock[3]=0;
  assign cv_awcache[3]=0;
  assign cv_awprot[3]=0;
  assign cv_awqos[3]=0;
  assign cv_awregion[3]=0;
  assign cv_awuser[3]=0;
  assign cv_awvalid[3]=0;
  assign cv_wdata[3]=0;
  assign cv_wstrb[3]=0;
  assign cv_wid[3]=0;
  assign cv_wuser[3]=0;
  assign cv_wlast[3]=0;
  assign cv_wvalid[3]=0;
  assign cv_bready[3]=0;
  logic cv_arlock3;
  assign cv_arlock[3]={1'b0,cv_arlock3};
  laya_load_dwidth128_v1 converter3(
    .s_axi_aclk(clk),
    .s_axi_aresetn(rst_n),
    .s_axi_awaddr(64'd0),
    .s_axi_awlen(8'd0),
    .s_axi_awsize(3'd0),
    .s_axi_awburst(2'd1),
    .s_axi_awlock(1'd0),
    .s_axi_awcache(4'd0),
    .s_axi_awprot(3'd0),
    .s_axi_awqos(4'd0),
    .s_axi_awvalid(1'd0),
    .s_axi_awready(),
    .s_axi_wdata(128'd0),
    .s_axi_wstrb(16'd0),
    .s_axi_wlast(1'd0),
    .s_axi_wvalid(1'd0),
    .s_axi_wready(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'd1),
    .s_axi_araddr(aux_araddr),
    .s_axi_arlen(aux_arlen),
    .s_axi_arsize(aux_arsize),
    .s_axi_arburst(aux_arburst),
    .s_axi_arvalid(si_arvalid[3] && selected_owner[5]),
    .s_axi_arready(si_arready[3]),
    .s_axi_arlock(1'd0),
    .s_axi_arcache(4'd3),
    .s_axi_arprot(3'd0),
    .s_axi_arqos(4'd0),
    .s_axi_rdata(aux_rdata),
    .s_axi_rresp(aux_rresp),
    .s_axi_rlast(aux_rlast),
    .s_axi_rvalid(aux_rvalid),
    .s_axi_rready(aux_rready),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awvalid(),
    .m_axi_awready(1'd0),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'd0),
    .m_axi_bresp(2'd0),
    .m_axi_bvalid(1'd0),
    .m_axi_bready(),
    .m_axi_araddr(cv_araddr[3]),
    .m_axi_arlen(cv_arlen[3]),
    .m_axi_arsize(cv_arsize[3]),
    .m_axi_arburst(cv_arburst[3]),
    .m_axi_arlock(cv_arlock3),
    .m_axi_arcache(cv_arcache[3]),
    .m_axi_arprot(cv_arprot[3]),
    .m_axi_arqos(cv_arqos[3]),
    .m_axi_arvalid(cv_arvalid[3]),
    .m_axi_arready(cv_arready[3]),
    .m_axi_rdata(cv_rdata[3]),
    .m_axi_rresp(cv_rresp[3]),
    .m_axi_rlast(cv_rlast[3]),
    .m_axi_rvalid(cv_rvalid[3]),
    .m_axi_rready(cv_rready[3])
  );
endmodule
