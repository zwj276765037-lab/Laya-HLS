`timescale 1ns/1ps

// Loads validated bias once per RUN, performs the separate final F32 add
// only for bias_kind=1, then sends the production tile scatter packet to one
// of the two 512-bit writers. A tile is never published after a bad lane.
module tm1tn8_bias_output (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [255:0] cfg_tdata,
  input  logic         cfg_tvalid,
  output logic         cfg_tready,
  input  logic [287:0] bias_tdata,
  input  logic         bias_tvalid,
  output logic         bias_tready,
  output logic         bias_loaded,
  input  logic [319:0] tile_tdata,
  input  logic         tile_tvalid,
  output logic         tile_tready,
  output logic [287:0] out0_tdata,
  output logic         out0_tvalid,
  input  logic         out0_tready,
  output logic [287:0] out1_tdata,
  output logic         out1_tvalid,
  input  logic         out1_tready,
  input  logic         command_done,
  output logic         numerical_error,
  output logic [63:0]  first_error_rank,
  output logic [63:0]  first_bad_element,
  output logic [31:0]  first_error_detail,
  output logic         protocol_error,
  output logic [31:0]  committed_elements
);
  logic configured, run_mode, qkv;
  logic [31:0] N, rows, row0, batch, op, G;
  logic [8:0] T, bias_count;
  logic [31:0] bias [0:7][0:383];
  logic bias_kind [0:383];
  logic [255:0] add_result, add_captured, add_merged;
  logic add_launch, add_valid [0:7], add_busy;
  logic [7:0] held_active, add_seen, add_now, add_bad;
  logic [8:0] held_tile;
  logic [1:0] held_row;
  logic [7:0] held_bad, held_mask;
  logic [287:0] packet;
  logic pending, pending_shard;
  logic [8:0] incoming_tile;
  logic [1:0] incoming_row;
  logic [7:0] incoming_mask, incoming_bad;
  logic [255:0] final_bits;
  logic [7:0] final_bad;
  logic final_valid;
  logic [8:0] final_tile;
  logic [1:0] final_row;
  logic [7:0] final_mask;
  logic output_handshake;
  logic new_packet;
  logic [63:0] candidate_rank, candidate_bad_element;

  function automatic logic finite_f32(input logic [31:0] value);
    return value[30:23] != 8'hff;
  endfunction
  function automatic logic [3:0] pop8(input logic [7:0] value);
    logic [3:0] count;
    count=0;
    for (int lane=0; lane<8; lane++) count=count+value[lane];
    return count;
  endfunction
  assign incoming_tile = tile_tdata[264:256];
  assign incoming_row = tile_tdata[266:265];
  assign incoming_mask = tile_tdata[274:267];
  assign incoming_bad = tile_tdata[282:275];
  assign cfg_tready = !configured && !pending && !add_busy;
  assign bias_tready = configured && run_mode && bias_count < T;
  assign bias_loaded = configured && (!run_mode || bias_count == T);
  assign output_handshake =
      (out0_tvalid && out0_tready) || (out1_tvalid && out1_tready);
  assign new_packet = final_valid && final_bad == 0 &&
                      final_mask != 0 && !protocol_error;
  assign tile_tready = bias_loaded && !add_busy &&
      (!pending || output_handshake);
  assign add_launch = tile_tvalid && tile_tready &&
                      bias_kind[incoming_tile];
  assign out0_tdata = packet;
  assign out1_tdata = packet;
  assign out0_tvalid = pending && !pending_shard;
  assign out1_tvalid = pending && pending_shard;
  always_comb begin
    add_now = 0;
    add_merged = add_captured;
    add_bad = held_bad;
    for (int lane=0; lane<8; lane++) begin
      add_now[lane] = add_valid[lane];
      if (add_valid[lane])
        add_merged[lane*32 +: 32] = add_result[lane*32 +: 32];
      if (held_active[lane] &&
          !finite_f32(add_merged[lane*32 +: 32]))
        add_bad[lane] = 1;
    end
  end
  always_comb begin
    final_valid = 0;
    final_bits = 0;
    final_bad = 0;
    final_tile = 0;
    final_row = 0;
    final_mask = 0;
    if (add_busy && ((add_seen | add_now) & held_active) == held_active) begin
      final_valid = 1;
      final_bits = add_merged;
      final_bad = add_bad;
      final_tile = held_tile;
      final_row = held_row;
      final_mask = held_mask;
    end else if (tile_tvalid && tile_tready &&
                 !bias_kind[incoming_tile]) begin
      final_valid = 1;
      final_bits = tile_tdata[255:0];
      final_bad = incoming_bad;
      final_tile = incoming_tile;
      final_row = incoming_row;
      final_mask = incoming_mask;
    end
  end
  for (genvar lane=0; lane<8; lane++) begin : bias_add_lane
    tm1tn8_fadd_ip add_final_bias (
      .aclk(clk), .aclken(1'b1),
      .s_axis_a_tvalid(add_launch && incoming_mask[lane] &&
                       !incoming_bad[lane]),
      .s_axis_a_tdata(tile_tdata[lane*32 +: 32]),
      .s_axis_b_tvalid(add_launch && incoming_mask[lane] &&
                       !incoming_bad[lane]),
      .s_axis_b_tdata(bias[lane][incoming_tile]),
      .m_axis_result_tvalid(add_valid[lane]),
      .m_axis_result_tdata(add_result[lane*32 +: 32]));
  end
  always_comb begin
    candidate_rank = first_error_rank;
    candidate_bad_element = first_bad_element;
    if (final_valid && bias_kind[final_tile])
      for (int lane=0; lane<8; lane++)
        if (final_mask[lane] && final_bad[lane] &&
            !held_bad[lane]) begin
          logic [63:0] rank;
          rank = (((({55'd0,final_tile}*4+final_row)*8+lane)*
                   (G+1)+G)*5);
          if (rank < candidate_rank) begin
            candidate_rank = rank;
            candidate_bad_element =
                {62'd0,final_row}*5248*128 +
                ({55'd0,final_tile}*8+lane)*128 + G;
          end
        end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      configured <= 0;
      run_mode <= 0;
      qkv <= 0;
      N <= 0; rows <= 0; row0 <= 0; batch <= 0; op <= 0; G <= 0; T <= 0;
      bias_count <= 0;
      add_busy <= 0;
      held_tile <= 0; held_row <= 0; held_bad <= 0; held_mask <= 0;
      held_active <= 0; add_seen <= 0; add_captured <= 0;
      pending <= 0; pending_shard <= 0; packet <= 0;
      numerical_error <= 0;
      first_error_rank <= '1;
      first_bad_element <= '1;
      first_error_detail <= 0;
      protocol_error <= 0;
      committed_elements <= 0;
    end else begin
      if (cfg_tvalid && cfg_tready) begin
        configured <= 1;
        run_mode <= cfg_tdata[225];
        N <= cfg_tdata[63:32];
        rows <= cfg_tdata[95:64];
        row0 <= cfg_tdata[127:96];
        batch <= cfg_tdata[159:128];
        op <= cfg_tdata[191:160];
        G <= cfg_tdata[31:0]/32;
        T <= (cfg_tdata[63:32]+7)/8;
        qkv <= cfg_tdata[191:160] == 8'h30;
        bias_count <= 0;
        numerical_error <= 0;
        first_error_rank <= '1;
        first_bad_element <= '1;
        first_error_detail <= 0;
        protocol_error <= 0;
        committed_elements <= 0;
      end
      if (bias_tvalid && bias_tready) begin
        if (bias_tdata[264:256] != bias_count ||
            bias_tdata[272:265] !=
                ((bias_count == T-1) ?
                 8'((1 << (N-bias_count*8))-1) : 8'hff))
          protocol_error <= 1;
        for (int lane=0; lane<8; lane++)
          bias[lane][bias_count] <= bias_tdata[lane*32 +: 32];
        bias_kind[bias_count] <= bias_tdata[273];
        bias_count <= bias_count + 1'b1;
      end
      if (tile_tvalid && tile_tready) begin
        if (incoming_tile >= T || incoming_row >= rows ||
            incoming_mask != ((incoming_tile == T-1) ?
                              8'((1 << (N-incoming_tile*8))-1) : 8'hff))
          protocol_error <= 1;
        if (bias_kind[incoming_tile]) begin
          add_busy <= 1;
          held_tile <= incoming_tile;
          held_row <= incoming_row;
          held_bad <= incoming_bad;
          held_mask <= incoming_mask;
          held_active <= incoming_mask & ~incoming_bad;
          add_seen <= 0;
          add_captured <= tile_tdata[255:0];
        end
      end
      if (add_busy) begin
        for (int lane=0; lane<8; lane++)
          if (add_valid[lane]) begin
            if (!held_active[lane] || add_seen[lane]) protocol_error <= 1;
            add_seen[lane] <= 1;
            add_captured[lane*32 +: 32] <= add_result[lane*32 +: 32];
          end
        if (final_valid) add_busy <= 0;
      end
      if (final_valid) begin
        if (candidate_rank < first_error_rank) begin
          first_error_rank <= candidate_rank;
          numerical_error <= 1;
          first_bad_element <= candidate_bad_element;
          first_error_detail <= {8'd7,op[7:0],16'd15};
        end
        if (new_packet) begin
          if (pending && !output_handshake) protocol_error <= 1;
          pending <= 1;
          pending_shard <= qkv && ((final_tile*8%1024)/64)%2 != 0;
          packet <= 0;
          packet[255:0] <= final_bits;
          packet[267:256] <= 12'(final_tile*8);
          packet[269:268] <= final_row;
          packet[279:270] <= row0[9:0];
          packet[280] <= batch[0];
          packet[284:281] <= 4'(pop8(final_mask));
          packet[285] <= qkv;
        end
      end
      if (output_handshake && !new_packet) begin
        pending <= 0;
        committed_elements <= committed_elements + packet[284:281];
      end else if (output_handshake)
        committed_elements <= committed_elements + packet[284:281];
      if (configured && !run_mode && !pending && !add_busy)
        configured <= 0;
      if (command_done && !pending && !add_busy) configured <= 0;
    end
  end
endmodule
