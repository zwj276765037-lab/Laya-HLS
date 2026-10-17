`timescale 1ns/1ps
// Passive AXI4 monitor for either side of the finite timing adapter.  AXI W
// may precede AW, so both are queued before their beats are paired.  The
// accepted endpoint completes transactions in FIFO order across both IDs.
module q8_axi_monitor #(
    parameter int DATA_BITS = 32,
    parameter int PORT = 0,
    parameter int SIDE = 0
) (
    input logic clk, resetn,
    input logic [1:0][63:0] read_lo, read_hi,
    input logic [3:0][63:0] write_lo, write_hi,
    input logic awvalid, awready,
    input logic [63:0] awaddr,
    input logic awid,
    input logic [7:0] awlen,
    input logic [2:0] awsize,
    input logic [1:0] awburst, awlock,
    input logic [3:0] awcache, awqos, awregion,
    input logic [2:0] awprot,
    input logic awuser,
    input logic wvalid, wready,
    input logic [DATA_BITS-1:0] wdata,
    input logic [DATA_BITS/8-1:0] wstrb,
    input logic wlast, wid, wuser,
    input logic bvalid, bready,
    input logic [1:0] bresp,
    input logic bid, buser,
    input logic arvalid, arready,
    input logic [63:0] araddr,
    input logic arid,
    input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic [1:0] arburst, arlock,
    input logic [3:0] arcache, arqos, arregion,
    input logic [2:0] arprot,
    input logic aruser,
    input logic rvalid, rready,
    input logic [DATA_BITS-1:0] rdata,
    input logic [1:0] rresp,
    input logic rlast, rid, ruser,
    output logic [31:0] aw_count, w_count, b_count,
    output logic [31:0] ar_count, r_count, rlast_count,
    output logic [63:0] read_bus_bytes, write_bus_bytes,
    output logic [63:0] write_useful_bytes,
    output logic write_pending, read_pending
);
  localparam int BEAT_BYTES = DATA_BITS/8;
  localparam int Q = 16;
  // Endpoint W FIFO is 64 deep and the DUT-facing adapter can hold one more.
  localparam int WQ = 80;
  logic [63:0] aw_address [0:Q-1], ar_address [0:Q-1];
  logic [7:0] aw_length [0:Q-1], ar_length [0:Q-1];
  logic [2:0] aw_size [0:Q-1], ar_size [0:Q-1];
  logic aw_id [0:Q-1], ar_id [0:Q-1], b_id [0:Q-1];
  logic [7:0] aw_beat [0:Q-1], ar_beat [0:Q-1];
  logic [DATA_BITS-1:0] w_data [0:WQ-1];
  logic [BEAT_BYTES-1:0] w_strb [0:WQ-1];
  logic w_last [0:WQ-1], w_id [0:WQ-1], w_user [0:WQ-1];
  integer aw_head, aw_tail, aw_used, ar_head, ar_tail, ar_used;
  integer w_head, w_tail, w_used, b_head, b_tail, b_used;

  assign write_pending = aw_used != 0 || w_used != 0 || b_used != 0;
  assign read_pending = ar_used != 0;

  function automatic bit allowed_read(input logic [63:0] first,
                                      input logic [63:0] last);
    for (int i=0; i<2; i++)
      if (first >= read_lo[i] && last < read_hi[i]) return 1;
    return 0;
  endfunction
  function automatic bit allowed_write(input logic [63:0] first,
                                       input logic [63:0] last);
    for (int i=0; i<4; i++)
      if (first >= write_lo[i] && last < write_hi[i]) return 1;
    return 0;
  endfunction
  function automatic int burst_error(input logic [63:0] addr,
                                     input logic [7:0] len,
                                     input logic [2:0] size,
                                     input logic [1:0] burst);
    logic [64:0] ending;
    if (burst !== 2'b01 || len >= 16 || size > $clog2(BEAT_BYTES)) return 1;
    if ((addr & ((64'd1 << size)-1)) != 0) return 2;
    ending = {1'b0,addr} + (({57'd0,len}+65'd1) << size) - 65'd1;
    if (ending[64] || ending[63:12] != addr[63:12]) return 3;
    return 0;
  endfunction

  // Blocking updates keep the simultaneous AW/W/AR/R/B edge internally
  // consistent.  Completion checks in the parent sample this monitor later
  // in the same time step, after the edge has settled.
  always @(posedge clk) begin : record
    logic [64:0] first_byte, last_byte, lane_byte, beat_base;
    int strobed;
    if (!resetn) begin
      aw_head=0; aw_tail=0; aw_used=0;
      ar_head=0; ar_tail=0; ar_used=0;
      w_head=0; w_tail=0; w_used=0;
      b_head=0; b_tail=0; b_used=0;
      aw_count=0; w_count=0; b_count=0;
      ar_count=0; r_count=0; rlast_count=0;
      read_bus_bytes=0; write_bus_bytes=0; write_useful_bytes=0;
    end else begin
      if ($isunknown({awvalid,awready,wvalid,wready,bvalid,bready,
                      arvalid,arready,rvalid,rready}))
        $fatal(1,"Q8_AXI_CHANNEL_UNKNOWN port=%0d side=%0d",PORT,SIDE);
      if (awvalid && awready) begin
        if (aw_used == Q || $isunknown({awaddr,awid,awlen,awsize,awburst,
                                         awlock,awcache,awprot,awqos,awregion,
                                         awuser}) ||
            burst_error(awaddr,awlen,awsize,awburst) != 0)
          $fatal(1,"Q8_AXI_AW_METADATA port=%0d side=%0d",PORT,SIDE);
        first_byte={1'b0,awaddr};
        last_byte=first_byte+(({57'd0,awlen}+65'd1)<<awsize)-65'd1;
        if (last_byte[64] || !allowed_write(awaddr,last_byte[63:0]))
          $fatal(1,"Q8_AXI_AW_RANGE port=%0d side=%0d addr=%h",PORT,SIDE,awaddr);
        aw_address[aw_tail]=awaddr;
        aw_length[aw_tail]=awlen;
        aw_size[aw_tail]=awsize;
        aw_id[aw_tail]=awid;
        aw_beat[aw_tail]=0;
        aw_tail=(aw_tail+1)%Q;
        aw_used++;
        aw_count++;
      end
      if (wvalid && wready) begin
        if (w_used == WQ || $isunknown({wid,wstrb,wlast,wuser}))
          $fatal(1,"Q8_AXI_W_METADATA port=%0d side=%0d",PORT,SIDE);
        w_data[w_tail]=wdata;
        w_strb[w_tail]=wstrb;
        w_last[w_tail]=wlast;
        w_id[w_tail]=wid;
        w_user[w_tail]=wuser;
        w_tail=(w_tail+1)%WQ;
        w_used++;
        w_count++;
      end
      if (arvalid && arready) begin
        if (ar_used == Q || $isunknown({araddr,arid,arlen,arsize,arburst,
                                         arlock,arcache,arprot,arqos,arregion,
                                         aruser}) ||
            burst_error(araddr,arlen,arsize,arburst) != 0)
          $fatal(1,"Q8_AXI_AR_METADATA port=%0d side=%0d",PORT,SIDE);
        first_byte={1'b0,araddr};
        last_byte=first_byte+(({57'd0,arlen}+65'd1)<<arsize)-65'd1;
        if (last_byte[64] || !allowed_read(araddr,last_byte[63:0]))
          $fatal(1,"Q8_AXI_AR_RANGE port=%0d side=%0d addr=%h",PORT,SIDE,araddr);
        ar_address[ar_tail]=araddr;
        ar_length[ar_tail]=arlen;
        ar_size[ar_tail]=arsize;
        ar_id[ar_tail]=arid;
        ar_beat[ar_tail]=0;
        ar_tail=(ar_tail+1)%Q;
        ar_used++;
        ar_count++;
      end
      // The endpoint can accept W before AW; pair one queued beat per edge.
      if (aw_used != 0 && w_used != 0) begin
        if (w_id[w_head] !== aw_id[aw_head] ||
            w_last[w_head] !== (aw_beat[aw_head] == aw_length[aw_head]))
          $fatal(1,"Q8_AXI_W_BEAT port=%0d side=%0d beat=%0d",
                 PORT,SIDE,aw_beat[aw_head]);
        beat_base={1'b0,aw_address[aw_head]}+
                  ({57'd0,aw_beat[aw_head]}<<aw_size[aw_head]);
        first_byte=beat_base;
        last_byte=beat_base+(65'd1<<aw_size[aw_head])-65'd1;
        strobed=0;
        for (int lane=0; lane<BEAT_BYTES; lane++) begin
          if (w_strb[w_head][lane]) begin
            lane_byte=beat_base-(beat_base%BEAT_BYTES)+lane;
            if (lane_byte<first_byte || lane_byte>last_byte ||
                !allowed_write(lane_byte[63:0],lane_byte[63:0]) ||
                $isunknown(w_data[w_head][lane*8 +: 8]))
              $fatal(1,"Q8_AXI_W_STRB port=%0d side=%0d lane=%0d",
                     PORT,SIDE,lane);
            strobed++;
          end
        end
        write_bus_bytes += 64'd1<<aw_size[aw_head];
        write_useful_bytes += strobed;
        w_head=(w_head+1)%WQ;
        w_used--;
        if (w_last[(w_head+WQ-1)%WQ]) begin
          if (b_used==Q)
            $fatal(1,"Q8_AXI_B_RING_FULL port=%0d side=%0d",PORT,SIDE);
          b_id[b_tail]=aw_id[aw_head];
          b_tail=(b_tail+1)%Q;
          b_used++;
          aw_head=(aw_head+1)%Q;
          aw_used--;
        end else aw_beat[aw_head]++;
      end
      if (rvalid && rready) begin
        if (ar_used==0 || $isunknown({rid,rdata,rresp,rlast,ruser}) ||
            rid !== ar_id[ar_head] || rresp !== 2'b00 ||
            rlast !== (ar_beat[ar_head] == ar_length[ar_head]))
          $fatal(1,"Q8_AXI_R_RETIRE port=%0d side=%0d",PORT,SIDE);
        first_byte={1'b0,ar_address[ar_head]}+
                   ({57'd0,ar_beat[ar_head]}<<ar_size[ar_head]);
        last_byte=first_byte+(65'd1<<ar_size[ar_head])-65'd1;
        if (last_byte[64] || !allowed_read(first_byte[63:0],last_byte[63:0]))
          $fatal(1,"Q8_AXI_R_RANGE port=%0d side=%0d",PORT,SIDE);
        read_bus_bytes += 64'd1<<ar_size[ar_head];
        r_count++;
        if (rlast) begin
          ar_head=(ar_head+1)%Q;
          ar_used--;
          rlast_count++;
        end else ar_beat[ar_head]++;
      end
      if (bvalid && bready) begin
        if (b_used==0 || $isunknown({bid,bresp,buser}) ||
            bid !== b_id[b_head] || bresp !== 2'b00)
          $fatal(1,"Q8_AXI_B_RETIRE port=%0d side=%0d",PORT,SIDE);
        b_head=(b_head+1)%Q;
        b_used--;
        b_count++;
      end
      if (b_count>aw_count || rlast_count>ar_count)
        $fatal(1,"Q8_AXI_RESPONSE_WITHOUT_REQUEST port=%0d side=%0d",PORT,SIDE);
    end
  end
endmodule
