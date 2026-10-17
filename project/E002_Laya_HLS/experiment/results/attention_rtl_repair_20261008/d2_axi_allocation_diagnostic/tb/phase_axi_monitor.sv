`timescale 1ns/1ps

// Passive monitor for one actual 32-bit data / 1-bit-ID m_axi interface.
// Seven instances are bound in the copied generated autotb. No payload is kept.
module d2_phase_axi_monitor #(
    parameter string PORT = "unnamed"
) (
    input logic clk, input logic rst_n,
    input logic awvalid, input logic awready,
    input logic wvalid, input logic wready, input logic [3:0] wstrb,
    input logic wlast, input logic bvalid, input logic bready,
    input logic arvalid, input logic arready,
    input logic [0:0] arid, input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic rvalid, input logic rready,
    input logic [0:0] rid, input logic rlast
);
    localparam int IDS = 2;
    localparam int RING = 16;
    // 2 IDs x 16 entries x (3-bit ARSIZE + 9-bit remaining beats) = 48 B.
    // Six 32-bit head/tail/count scalars add 24 B per instance, 504 B total
    // across seven ports. All counters below are also fixed-size scalars.
    logic [2:0] size_ring [0:IDS-1][0:RING-1];
    logic [8:0] remaining_ring [0:IDS-1][0:RING-1];
    integer head [0:IDS-1];
    integer tail [0:IDS-1];
    integer used [0:IDS-1];
    longint unsigned aw_count = 0, ar_count = 0;
    longint unsigned w_beats = 0, r_beats = 0, b_count = 0;
    longint unsigned wlast_count = 0, rlast_count = 0;
    longint unsigned w_strobe_bytes = 0, r_transfer_bytes = 0;

    initial begin
        for (int id = 0; id < IDS; id++) begin
            head[id] = 0;
            tail[id] = 0;
            used[id] = 0;
        end
    end

    task automatic consume_read(input int id);
        if (used[id] == 0)
            $fatal(1, "D2_PHASE_PROBE_INVALID unmatched R port=%s id=%0d", PORT, id);
        if ((remaining_ring[id][head[id]] == 9'd1) != (rlast === 1'b1))
            $fatal(1, "D2_PHASE_PROBE_INVALID RLAST mismatch port=%s id=%0d remaining=%0d last=%b",
                   PORT, id, remaining_ring[id][head[id]], rlast);
        r_transfer_bytes += (64'd1 << size_ring[id][head[id]]);
        r_beats++;
        if (rlast === 1'b1) begin
            rlast_count++;
            head[id] = (head[id] + 1) % RING;
            used[id]--;
        end else begin
            remaining_ring[id][head[id]]--;
        end
    endtask

    // Retire an existing R first, so a full ring can accept a same-clock AR.
    // If the ring was empty, insert the AR first so a same-clock R can match.
    // The top-level samples one picosecond after these blocking updates.
    always @(posedge clk) begin : record_handshakes
        int id;
        int strobe_bytes;
        bit read_handshake;
        bit read_on_empty;
        if (rst_n === 1'b1) begin
            read_handshake = rvalid === 1'b1 && rready === 1'b1;
            if (read_handshake && $isunknown({rid, rlast}))
                $fatal(1, "D2_PHASE_PROBE_INVALID unknown RID/RLAST port=%s", PORT);
            read_on_empty = read_handshake && used[int'(rid)] == 0;
            if (read_handshake && !read_on_empty) consume_read(int'(rid));
            if (awvalid === 1'b1 && awready === 1'b1) aw_count++;
            if (arvalid === 1'b1 && arready === 1'b1) begin
                if ($isunknown({arid, arlen, arsize}) || arsize > 3'd2)
                    $fatal(1, "D2_PHASE_PROBE_INVALID AR metadata port=%s id=%b len=%b size=%b",
                           PORT, arid, arlen, arsize);
                id = int'(arid);
                if (used[id] >= RING)
                    $fatal(1, "D2_PHASE_PROBE_INVALID read-ring overflow port=%s id=%0d", PORT, id);
                size_ring[id][tail[id]] = arsize;
                remaining_ring[id][tail[id]] = {1'b0, arlen} + 9'd1;
                tail[id] = (tail[id] + 1) % RING;
                used[id]++;
                ar_count++;
            end
            if (wvalid === 1'b1 && wready === 1'b1) begin
                if ($isunknown({wstrb, wlast}))
                    $fatal(1, "D2_PHASE_PROBE_INVALID WSTRB/WLAST port=%s", PORT);
                strobe_bytes = 0;
                for (int bit_idx = 0; bit_idx < 4; bit_idx++)
                    if (wstrb[bit_idx] === 1'b1) strobe_bytes++;
                w_strobe_bytes += strobe_bytes;
                w_beats++;
                if (wlast === 1'b1) wlast_count++;
            end
            if (read_on_empty) consume_read(int'(rid));
            if (bvalid === 1'b1 && bready === 1'b1) b_count++;
        end
    end

    task automatic report(input longint unsigned sampled_posedge);
        $display("D2_PHASE_AXI port=%s sampled_posedge=%0d sim_ps=%0d aw=%0d ar=%0d w_beats=%0d r_beats=%0d b=%0d wlast=%0d rlast=%0d w_strobe_bytes=%0d r_transfer_bytes=%0d aw_minus_b=%0d ar_minus_rlast=%0d read_ring_id0=%0d read_ring_id1=%0d",
                 PORT, sampled_posedge, longint'($realtime * 1000.0),
                 aw_count, ar_count, w_beats, r_beats, b_count,
                 wlast_count, rlast_count, w_strobe_bytes, r_transfer_bytes,
                 aw_count - b_count, ar_count - rlast_count, used[0], used[1]);
    endtask
endmodule
