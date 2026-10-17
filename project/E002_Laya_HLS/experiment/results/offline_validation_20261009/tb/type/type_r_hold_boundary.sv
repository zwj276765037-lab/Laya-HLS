`timescale 1ns/1ps
// Short diagnostic of the exact Type selector with the production AXI port.
module type_r_hold_boundary;
  localparam logic [63:0] BASE=64'h0000000501022000;
  logic clk=0, resetn=0;
  always #3.335 clk=~clk;
  logic arvalid=0, arready;
  logic [63:0] araddr=0;
  logic rvalid, rlast, hold_final_r, r_hold_applied;
  logic row_pending_stable;
  logic [63:0] row_beat_addr_stable;
  logic [31:0] ram_ar_count, ram_r_count, r_special_wait_cycles;
  logic [118:0] ram_accepted_r_record;
  integer hold_count=0, pending_seen=0;

  att_axi_port #(.DATA_BITS(32),.PORT(4),.PAGE_COUNT(1),
                 .PAGE_BASES(BASE)) u_port_state0 (
    .clk(clk),.resetn(resetn),
    .read_lo({64'd0,64'd0,64'd0,BASE}),
    .read_hi({64'd0,64'd0,64'd0,BASE+64'd4096}),
    .write_lo('0),.write_hi('0),
    .hold_final_r(hold_final_r),.hold_final_b(1'b0),
    .r_hold_applied(r_hold_applied),.b_hold_applied(),
    .r_special_wait_cycles(r_special_wait_cycles),.b_special_wait_cycles(),
    .awvalid(1'b0),.awready(),.awaddr('0),.awid(1'b0),
    .awlen(8'd0),.awsize(3'd2),.awburst(2'b01),.awlock(2'b00),
    .awcache(4'd0),.awqos(4'd0),.awregion(4'd0),
    .awprot(3'd0),.awuser(1'b0),
    .wvalid(1'b0),.wready(),.wdata(32'd0),.wstrb(4'd0),
    .wlast(1'b1),.wid(1'b0),.wuser(1'b0),
    .bvalid(),.bready(1'b1),.bresp(),.bid(),.buser(),
    .arvalid(arvalid),.arready(arready),.araddr(araddr),.arid(1'b0),
    .arlen(8'd0),.arsize(3'd2),.arburst(2'b01),.arlock(2'b00),
    .arcache(4'd0),.arqos(4'd0),.arregion(4'd0),
    .arprot(3'd0),.aruser(1'b0),
    .rvalid(rvalid),.rready(1'b1),.rdata(),.rresp(),
    .rlast(rlast),.rid(),.ruser(),
    .dut_aw_count(),.dut_w_count(),.dut_b_count(),
    .dut_ar_count(),.dut_r_count(),.dut_rlast_count(),
    .dut_read_bus_bytes(),.dut_write_bus_bytes(),
    .dut_write_useful_bytes(),.dut_write_pending(),.dut_read_pending(),
    .ram_aw_count(),.ram_w_count(),.ram_b_count(),
    .ram_ar_count(ram_ar_count),.ram_r_count(ram_r_count),
    .ram_rlast_count(),.ram_read_bus_bytes(),.ram_write_bus_bytes(),
    .ram_write_useful_bytes(),.ram_write_pending(),.ram_read_pending(),
    .ram_accepted_r_record(ram_accepted_r_record),
    .accepted(),.delivered());

  type_r_hold_selector #(.TYPE_ROW_END(BASE+64'd4096)) selector (
    .clk(clk),.resetn(resetn),.selected_r_ordinal(32'd3),
    .arvalid(u_port_state0.e_arvalid),.arready(u_port_state0.e_arready),
    .araddr(u_port_state0.e_araddr),.arlen(u_port_state0.e_arlen),
    .arsize(u_port_state0.e_arsize),
    .rvalid(u_port_state0.e_rvalid),.rready(u_port_state0.e_rready),
    .rlast(u_port_state0.e_rlast),.hold_final_r(hold_final_r),
    .row_pending_stable(row_pending_stable),
    .row_beat_addr_stable(row_beat_addr_stable));

  always @(posedge clk) if (resetn && r_hold_applied) begin
    if (r_special_wait_cycles < 16)
      $fatal(1,"TYPE_R_BOUNDARY_HOLD_SHORT cycles=%0d",r_special_wait_cycles);
    hold_count++;
  end
  always @(negedge clk) begin
    #1ps;
    if (resetn && row_pending_stable) pending_seen++;
    if (resetn && (selector.used>0 || u_port_state0.e_rvalid))
      $display("TYPE_R_BOUNDARY_DEBUG count=%0d local_count=%0d selected=%0d ar_used=%0d head=%0d source_valid=%b selector_valid=%b source_ready=%b rlast=%b selector_last=%b resetn=%b pending=%b stable_addr=%h end=%h addr_match=%b ordinal_match=%b hold=%b",
               ram_r_count,selector.accepted_r_count_local,selector.selected_r_ordinal,selector.used,selector.head,
               u_port_state0.e_rvalid,selector.rvalid,u_port_state0.e_rready,
               u_port_state0.e_rlast,selector.rlast,selector.resetn,row_pending_stable,
               row_beat_addr_stable,selector.TYPE_ROW_END,
               row_beat_addr_stable==selector.TYPE_ROW_END-64'd4,
               ram_r_count+32'd1==selector.selected_r_ordinal,
               hold_final_r);
  end

  task automatic send_ar(input logic [63:0] addr);
    @(negedge clk);
    araddr=addr;
    arvalid=1;
    do @(posedge clk); while (!arready);
    @(negedge clk);
    arvalid=0;
  endtask

  initial begin
    repeat (8) @(negedge clk);
    resetn=1;
    send_ar(BASE);
    send_ar(BASE+64'd4);
    send_ar(BASE+64'd4092);
    do @(negedge clk); while (ram_r_count != 3 || hold_count != 1);
    if (ram_ar_count != 3 || ram_r_count != 3 ||
        selector.accepted_r_count_local != ram_r_count || hold_count != 1 ||
        pending_seen < 1 || row_pending_stable !== 1'b0 ||
        ram_accepted_r_record[118] !== 1'b1 ||
        ram_accepted_r_record[117:86] !== 32'd3 ||
        ram_accepted_r_record[85:22] !== BASE+64'd4092 ||
        ram_accepted_r_record[0] !== 1'b1)
      $fatal(1,"TYPE_R_BOUNDARY_IDENTITY ar=%0d r=%0d hold=%0d pending=%0d record=%h",
             ram_ar_count,ram_r_count,hold_count,pending_seen,
             ram_accepted_r_record);
    $display("TYPE_R_BOUNDARY_PASS ar=3 r=3 hold=%0d wait=%0d record=%h",
             hold_count,r_special_wait_cycles,ram_accepted_r_record);
    $finish;
  end
  initial begin
    #10000ns;
    $fatal(1,"TYPE_R_BOUNDARY_WATCHDOG ar=%0d r=%0d local_r=%0d hold=%0d pending=%b rvalid=%b rlast=%b",
           ram_ar_count,ram_r_count,selector.accepted_r_count_local,
           hold_count,row_pending_stable,rvalid,rlast);
  end
endmodule
