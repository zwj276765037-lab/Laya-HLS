`timescale 1ns/1ps
// Generated from actual historical 13BO declarations, with all bits checked.
// Controller is owner0, converted physical service is owner1. Active cancel
// changes desired_owner only; rst_n is cold fabric reset.
module laya_axi_13bo_owner_v1 (
  input logic clk,
  input logic rst_n,
  input logic [12:0] desired_owner,
  input logic [12:0] clear_error,
  output logic [12:0] selected_owner,
  output logic [12:0] debt_zero,
  output logic [12:0] protocol_error,
  input logic [12:0][1:0][63:0] owner_araddr,
  output logic [12:0][63:0] memory_araddr,
  input logic [12:0][1:0] owner_arid,
  output logic [12:0] memory_arid,
  input logic [12:0][1:0][7:0] owner_arlen,
  output logic [12:0][7:0] memory_arlen,
  input logic [12:0][1:0][2:0] owner_arsize,
  output logic [12:0][2:0] memory_arsize,
  input logic [12:0][1:0][1:0] owner_arburst,
  output logic [12:0][1:0] memory_arburst,
  input logic [12:0][1:0][1:0] owner_arlock,
  output logic [12:0][1:0] memory_arlock,
  input logic [12:0][1:0][3:0] owner_arcache,
  output logic [12:0][3:0] memory_arcache,
  input logic [12:0][1:0][2:0] owner_arprot,
  output logic [12:0][2:0] memory_arprot,
  input logic [12:0][1:0][3:0] owner_arqos,
  output logic [12:0][3:0] memory_arqos,
  input logic [12:0][1:0][3:0] owner_arregion,
  output logic [12:0][3:0] memory_arregion,
  input logic [12:0][1:0] owner_aruser,
  output logic [12:0] memory_aruser,
  input logic [12:0][1:0] owner_arvalid,
  output logic [12:0] memory_arvalid,
  output logic [12:0][1:0] owner_arready,
  input logic [12:0] memory_arready,
  input logic [12:0][1:0][63:0] owner_awaddr,
  output logic [12:0][63:0] memory_awaddr,
  input logic [12:0][1:0] owner_awid,
  output logic [12:0] memory_awid,
  input logic [12:0][1:0][7:0] owner_awlen,
  output logic [12:0][7:0] memory_awlen,
  input logic [12:0][1:0][2:0] owner_awsize,
  output logic [12:0][2:0] memory_awsize,
  input logic [12:0][1:0][1:0] owner_awburst,
  output logic [12:0][1:0] memory_awburst,
  input logic [12:0][1:0][1:0] owner_awlock,
  output logic [12:0][1:0] memory_awlock,
  input logic [12:0][1:0][3:0] owner_awcache,
  output logic [12:0][3:0] memory_awcache,
  input logic [12:0][1:0][2:0] owner_awprot,
  output logic [12:0][2:0] memory_awprot,
  input logic [12:0][1:0][3:0] owner_awqos,
  output logic [12:0][3:0] memory_awqos,
  input logic [12:0][1:0][3:0] owner_awregion,
  output logic [12:0][3:0] memory_awregion,
  input logic [12:0][1:0] owner_awuser,
  output logic [12:0] memory_awuser,
  input logic [12:0][1:0] owner_awvalid,
  output logic [12:0] memory_awvalid,
  output logic [12:0][1:0] owner_awready,
  input logic [12:0] memory_awready,
  input logic [12:0][1:0][31:0] owner_wdata,
  output logic [12:0][31:0] memory_wdata,
  input logic [12:0][1:0][3:0] owner_wstrb,
  output logic [12:0][3:0] memory_wstrb,
  input logic [12:0][1:0] owner_wid,
  output logic [12:0] memory_wid,
  input logic [12:0][1:0] owner_wuser,
  output logic [12:0] memory_wuser,
  input logic [12:0][1:0] owner_wlast,
  output logic [12:0] memory_wlast,
  input logic [12:0][1:0] owner_wvalid,
  output logic [12:0] memory_wvalid,
  output logic [12:0][1:0] owner_wready,
  input logic [12:0] memory_wready,
  output logic [12:0][1:0][31:0] owner_rdata,
  input logic [12:0][31:0] memory_rdata,
  output logic [12:0][1:0][1:0] owner_rresp,
  input logic [12:0][1:0] memory_rresp,
  output logic [12:0][1:0] owner_rid,
  input logic [12:0] memory_rid,
  output logic [12:0][1:0] owner_ruser,
  input logic [12:0] memory_ruser,
  output logic [12:0][1:0] owner_rlast,
  input logic [12:0] memory_rlast,
  output logic [12:0][1:0] owner_rvalid,
  input logic [12:0] memory_rvalid,
  input logic [12:0][1:0] owner_rready,
  output logic [12:0] memory_rready,
  output logic [12:0][1:0][1:0] owner_bresp,
  input logic [12:0][1:0] memory_bresp,
  output logic [12:0][1:0] owner_bid,
  input logic [12:0] memory_bid,
  output logic [12:0][1:0] owner_buser,
  input logic [12:0] memory_buser,
  output logic [12:0][1:0] owner_bvalid,
  input logic [12:0] memory_bvalid,
  input logic [12:0][1:0] owner_bready,
  output logic [12:0] memory_bready,
  output logic [12:0][31:0] accepted_ar,
  output logic [12:0][31:0] returned_r,
  output logic [12:0][31:0] accepted_aw,
  output logic [12:0][31:0] accepted_w,
  output logic [12:0][31:0] returned_b
);
  logic [12:0][1:0][95:0] owner_ar_payload;
  logic [12:0][95:0] memory_ar_payload;
  logic [12:0][1:0][95:0] owner_aw_payload;
  logic [12:0][95:0] memory_aw_payload;
  logic [12:0][1:0][37:0] owner_w_payload;
  logic [12:0][37:0] memory_w_payload;
  logic [12:0][1:0][35:0] owner_r_payload;
  logic [12:0][35:0] memory_r_payload;
  logic [12:0][1:0][3:0] owner_b_payload;
  logic [12:0][3:0] memory_b_payload;
  for(genvar bo=0;bo<13;bo++)begin : bo_owner
    for(genvar o=0;o<2;o++)begin : ar_pack
      assign owner_ar_payload[bo][o]={8'd0,{owner_araddr[bo][o],owner_arid[bo][o],owner_arsize[bo][o],owner_arburst[bo][o],owner_arlock[bo][o],owner_arcache[bo][o],owner_arprot[bo][o],owner_arqos[bo][o],owner_arregion[bo][o],owner_aruser[bo][o]}};
    end
      assign {memory_araddr[bo],memory_arid[bo],memory_arsize[bo],memory_arburst[bo],memory_arlock[bo],memory_arcache[bo],memory_arprot[bo],memory_arqos[bo],memory_arregion[bo],memory_aruser[bo]}=memory_ar_payload[bo][87:0];
    for(genvar o=0;o<2;o++)begin : aw_pack
      assign owner_aw_payload[bo][o]={8'd0,{owner_awaddr[bo][o],owner_awid[bo][o],owner_awsize[bo][o],owner_awburst[bo][o],owner_awlock[bo][o],owner_awcache[bo][o],owner_awprot[bo][o],owner_awqos[bo][o],owner_awregion[bo][o],owner_awuser[bo][o]}};
    end
      assign {memory_awaddr[bo],memory_awid[bo],memory_awsize[bo],memory_awburst[bo],memory_awlock[bo],memory_awcache[bo],memory_awprot[bo],memory_awqos[bo],memory_awregion[bo],memory_awuser[bo]}=memory_aw_payload[bo][87:0];
    for(genvar o=0;o<2;o++)begin : w_pack
      assign owner_w_payload[bo][o]={owner_wdata[bo][o],owner_wstrb[bo][o],owner_wid[bo][o],owner_wuser[bo][o]};
    end
      assign {memory_wdata[bo],memory_wstrb[bo],memory_wid[bo],memory_wuser[bo]}=memory_w_payload[bo][37:0];
    for(genvar o=0;o<2;o++)begin : r_pack
      assign {owner_rdata[bo][o],owner_rresp[bo][o],owner_rid[bo][o],owner_ruser[bo][o]}=owner_r_payload[bo][o][35:0];
    end
      assign memory_r_payload[bo]={memory_rdata[bo],memory_rresp[bo],memory_rid[bo],memory_ruser[bo]};
    for(genvar o=0;o<2;o++)begin : b_pack
      assign {owner_bresp[bo][o],owner_bid[bo][o],owner_buser[bo][o]}=owner_b_payload[bo][o][3:0];
    end
      assign memory_b_payload[bo]={memory_bresp[bo],memory_bid[bo],memory_buser[bo]};
    laya_axi_owner_v1 arbiter(
      .clk,
      .rst_n,
      .desired_owner(desired_owner[bo]),
      .clear_error(clear_error[bo]),
      .selected_owner(selected_owner[bo]),
      .debt_zero(debt_zero[bo]),
      .protocol_error(protocol_error[bo]),
      .owner_ar_payload(owner_ar_payload[bo]),
      .memory_ar_payload(memory_ar_payload[bo]),
      .owner_arlen(owner_arlen[bo]),
      .memory_arlen(memory_arlen[bo]),
      .owner_arvalid(owner_arvalid[bo]),
      .memory_arvalid(memory_arvalid[bo]),
      .owner_arready(owner_arready[bo]),
      .memory_arready(memory_arready[bo]),
      .owner_aw_payload(owner_aw_payload[bo]),
      .memory_aw_payload(memory_aw_payload[bo]),
      .owner_awlen(owner_awlen[bo]),
      .memory_awlen(memory_awlen[bo]),
      .owner_awvalid(owner_awvalid[bo]),
      .memory_awvalid(memory_awvalid[bo]),
      .owner_awready(owner_awready[bo]),
      .memory_awready(memory_awready[bo]),
      .owner_w_payload(owner_w_payload[bo]),
      .memory_w_payload(memory_w_payload[bo]),
      .owner_wlast(owner_wlast[bo]),
      .memory_wlast(memory_wlast[bo]),
      .owner_wvalid(owner_wvalid[bo]),
      .memory_wvalid(memory_wvalid[bo]),
      .owner_wready(owner_wready[bo]),
      .memory_wready(memory_wready[bo]),
      .owner_r_payload(owner_r_payload[bo]),
      .memory_r_payload(memory_r_payload[bo]),
      .owner_rlast(owner_rlast[bo]),
      .memory_rlast(memory_rlast[bo]),
      .owner_rvalid(owner_rvalid[bo]),
      .memory_rvalid(memory_rvalid[bo]),
      .owner_rready(owner_rready[bo]),
      .memory_rready(memory_rready[bo]),
      .owner_b_payload(owner_b_payload[bo]),
      .memory_b_payload(memory_b_payload[bo]),
      .owner_bvalid(owner_bvalid[bo]),
      .memory_bvalid(memory_bvalid[bo]),
      .owner_bready(owner_bready[bo]),
      .memory_bready(memory_bready[bo]),
      .accepted_ar(accepted_ar[bo]),
      .returned_r(returned_r[bo]),
      .accepted_aw(accepted_aw[bo]),
      .accepted_w(accepted_w[bo]),
      .returned_b(returned_b[bo])
    );
  end
endmodule
