`timescale 1ns/1ps
// One read and one write transaction per physical BO. Payloads contain every
// generated sideband/ID/error bit; LEN/LAST are separate, unchanged AXI fields.
// Active cancellation changes desired_owner; it never resets these debts.
module laya_axi_owner_v1 #(
  parameter int A_PAYLOAD_WIDTH=96,W_PAYLOAD_WIDTH=38,
  parameter int R_PAYLOAD_WIDTH=36,B_PAYLOAD_WIDTH=4
)(
  input logic clk,rst_n,desired_owner,clear_error,
  output logic selected_owner,debt_zero,protocol_error,
  input logic [1:0][A_PAYLOAD_WIDTH-1:0] owner_ar_payload,owner_aw_payload,
  input logic [1:0][7:0] owner_arlen,owner_awlen,
  input logic [1:0] owner_arvalid,owner_awvalid,
  output logic [1:0] owner_arready,owner_awready,
  input logic [1:0][W_PAYLOAD_WIDTH-1:0] owner_w_payload,
  input logic [1:0] owner_wvalid,owner_wlast,
  output logic [1:0] owner_wready,
  output logic [1:0][R_PAYLOAD_WIDTH-1:0] owner_r_payload,
  output logic [1:0] owner_rvalid,owner_rlast,
  input logic [1:0] owner_rready,
  output logic [1:0][B_PAYLOAD_WIDTH-1:0] owner_b_payload,
  output logic [1:0] owner_bvalid,
  input logic [1:0] owner_bready,
  output logic [A_PAYLOAD_WIDTH-1:0] memory_ar_payload,memory_aw_payload,
  output logic [7:0] memory_arlen,memory_awlen,
  output logic memory_arvalid,memory_awvalid,
  input logic memory_arready,memory_awready,
  output logic [W_PAYLOAD_WIDTH-1:0] memory_w_payload,
  output logic memory_wvalid,memory_wlast,
  input logic memory_wready,
  input logic [R_PAYLOAD_WIDTH-1:0] memory_r_payload,
  input logic memory_rvalid,memory_rlast,
  output logic memory_rready,
  input logic [B_PAYLOAD_WIDTH-1:0] memory_b_payload,
  input logic memory_bvalid,
  output logic memory_bready,
  output logic [31:0] accepted_ar,returned_r,accepted_aw,accepted_w,returned_b
);
  logic read_active,aw_seen,wlast_seen,b_seen,write_complete;
  logic [8:0] read_remaining,write_expected,w_count;
  logic ar_fire,r_fire,aw_fire,w_fire,b_fire,offered;
  assign debt_zero=!read_active && !aw_seen && w_count==0 && !b_seen;
  assign offered=owner_arvalid[selected_owner] || owner_awvalid[selected_owner] || owner_wvalid[selected_owner];
  assign memory_ar_payload=owner_ar_payload[selected_owner];
  assign memory_arlen=owner_arlen[selected_owner];
  assign memory_arvalid=owner_arvalid[selected_owner] && !read_active;
  assign memory_aw_payload=owner_aw_payload[selected_owner];
  assign memory_awlen=owner_awlen[selected_owner];
  assign memory_awvalid=owner_awvalid[selected_owner] && !aw_seen;
  assign memory_w_payload=owner_w_payload[selected_owner];
  assign memory_wlast=owner_wlast[selected_owner];
  assign memory_wvalid=owner_wvalid[selected_owner] && !wlast_seen;
  assign memory_rready=owner_rready[selected_owner] && read_active;
  assign memory_bready=owner_bready[selected_owner] && aw_seen && wlast_seen;
  assign ar_fire=memory_arvalid && memory_arready;
  assign r_fire=memory_rvalid && memory_rready;
  assign aw_fire=memory_awvalid && memory_awready;
  assign w_fire=memory_wvalid && memory_wready;
  assign b_fire=memory_bvalid && memory_bready;
  assign write_complete=aw_seen && wlast_seen && b_seen;
  always_comb begin
    owner_arready=0;owner_awready=0;owner_wready=0;owner_r_payload=0;owner_rvalid=0;owner_rlast=0;
    owner_b_payload=0;owner_bvalid=0;
    owner_arready[selected_owner]=memory_arready && !read_active;
    owner_awready[selected_owner]=memory_awready && !aw_seen;
    owner_wready[selected_owner]=memory_wready && !wlast_seen;
    owner_r_payload[selected_owner]=memory_r_payload;
    owner_rvalid[selected_owner]=memory_rvalid && read_active;
    owner_rlast[selected_owner]=memory_rlast;
    owner_b_payload[selected_owner]=memory_b_payload;
    owner_bvalid[selected_owner]=memory_bvalid && aw_seen && wlast_seen;
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      selected_owner<=0;read_active<=0;aw_seen<=0;wlast_seen<=0;b_seen<=0;
      read_remaining<=0;write_expected<=0;w_count<=0;protocol_error<=0;
      accepted_ar<=0;returned_r<=0;accepted_aw<=0;accepted_w<=0;returned_b<=0;
    end else begin
      if(clear_error && debt_zero && !offered)protocol_error<=0;
      if(debt_zero && !offered)selected_owner<=desired_owner;
      if(ar_fire)begin
        read_active<=1;read_remaining<={1'b0,memory_arlen}+1;accepted_ar<=accepted_ar+1;
      end
      if(r_fire)begin
        returned_r<=returned_r+1;
        if(memory_rlast!=(read_remaining==1))protocol_error<=1;
        if(read_remaining!=0)read_remaining<=read_remaining-1;
        if(memory_rlast)begin read_active<=0;read_remaining<=0;end
      end
      if(aw_fire)begin
        aw_seen<=1;write_expected<={1'b0,memory_awlen}+1;accepted_aw<=accepted_aw+1;
      end
      if(w_fire)begin
        accepted_w<=accepted_w+1;
        if(w_count==256)protocol_error<=1;else w_count<=w_count+1;
        if(memory_wlast)wlast_seen<=1;
      end
      if(b_fire)begin b_seen<=1;returned_b<=returned_b+1;end
      if(write_complete)begin
        if(w_count!=write_expected)protocol_error<=1;
        aw_seen<=0;wlast_seen<=0;b_seen<=0;write_expected<=0;w_count<=0;
      end
    end
  end
endmodule
