`timescale 1ns/1ps

// Passive, stable pre-edge monitor for one actual 32-bit / 1-bit-ID m_axi.
// Seven instances share one sampled event each. Only last response scalars are kept.
module d2_phase_axi_monitor #(
    parameter string PORT = "unnamed"
) (
    input logic clk, input logic rst_n,
    input logic awvalid, input logic awready,
    input logic wvalid, input logic wready, input logic [3:0] wstrb,
    input logic wlast, input logic bvalid, input logic bready,
    input logic [0:0] bid, input logic [1:0] bresp,
    input logic arvalid, input logic arready,
    input logic [0:0] arid, input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic rvalid, input logic rready,
    input logic [0:0] rid, input logic rlast,
    input logic [31:0] rdata, input logic [1:0] rresp
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
    longint unsigned sample_cycle = 0;
    logic [0:0] last_b_id, last_r_id;
    logic [1:0] last_b_resp, last_r_resp;
    logic [31:0] last_r_data;
    logic last_r_last;
    bit first_b_seen = 0, first_r_seen = 0;

    // Every counter and response field below is derived from this one stable
    // pre-edge image. A newly asserted active-region VALID belongs to the next
    // edge rather than being retroactively counted on the current edge.
    clocking sample_cb @(posedge clk);
        default input #1step;
        input rst_n;
        input awvalid, awready;
        input wvalid, wready, wstrb, wlast;
        input bvalid, bready, bid, bresp;
        input arvalid, arready, arid, arlen, arsize;
        input rvalid, rready, rid, rlast, rdata, rresp;
    endclocking

    initial begin
        for (int id = 0; id < IDS; id++) begin
            head[id] = 0;
            tail[id] = 0;
            used[id] = 0;
        end
    end

    task automatic consume_read(input int id, input logic sampled_rlast);
        if (used[id] == 0)
            $fatal(1, "D2_PHASE_PROBE_INVALID unmatched R port=%s id=%0d", PORT, id);
        if ((remaining_ring[id][head[id]] == 9'd1) != (sampled_rlast === 1'b1))
            $fatal(1, "D2_PHASE_PROBE_INVALID RLAST mismatch port=%s id=%0d remaining=%0d last=%b",
                   PORT, id, remaining_ring[id][head[id]], sampled_rlast);
        r_transfer_bytes += (64'd1 << size_ring[id][head[id]]);
        r_beats++;
        if (sampled_rlast === 1'b1) begin
            rlast_count++;
            head[id] = (head[id] + 1) % RING;
            used[id]--;
        end else begin
            remaining_ring[id][head[id]]--;
        end
    endtask

    // Retire an existing R first, so a full ring can accept a same-clock AR.
    // If the ring was empty, insert the sampled AR first so sampled R can match.
    // The top-level observes these blocking updates one picosecond after the edge.
    always @(sample_cb) begin : record_handshakes
        int id;
        int strobe_bytes;
        bit read_handshake;
        bit read_on_empty;
        if (sample_cb.rst_n === 1'b1) begin
            sample_cycle++;
            read_handshake = sample_cb.rvalid === 1'b1 &&
                             sample_cb.rready === 1'b1;
            if (read_handshake && $isunknown({sample_cb.rid, sample_cb.rlast}))
                $fatal(1, "D2_PHASE_PROBE_INVALID unknown RID/RLAST port=%s", PORT);
            read_on_empty = read_handshake && used[int'(sample_cb.rid)] == 0;
            if (read_handshake) begin
                last_r_id = sample_cb.rid;
                last_r_resp = sample_cb.rresp;
                last_r_last = sample_cb.rlast;
                last_r_data = sample_cb.rdata;
                if (!first_r_seen) begin
                    first_r_seen = 1;
                    $display("DIAG_FIRST_R_SAMPLE port=%s cycle=%0d count=%0d id=%b resp=%b last=%b",
                             PORT, sample_cycle, r_beats+1,
                             last_r_id, last_r_resp, last_r_last);
                end
            end
            if (read_handshake && !read_on_empty)
                consume_read(int'(sample_cb.rid), sample_cb.rlast);
            if (sample_cb.awvalid === 1'b1 && sample_cb.awready === 1'b1)
                aw_count++;
            if (sample_cb.arvalid === 1'b1 && sample_cb.arready === 1'b1) begin
                if ($isunknown({sample_cb.arid, sample_cb.arlen, sample_cb.arsize}) ||
                    sample_cb.arsize > 3'd2)
                    $fatal(1, "D2_PHASE_PROBE_INVALID AR metadata port=%s id=%b len=%b size=%b",
                           PORT, sample_cb.arid, sample_cb.arlen, sample_cb.arsize);
                id = int'(sample_cb.arid);
                if (used[id] >= RING)
                    $fatal(1, "D2_PHASE_PROBE_INVALID read-ring overflow port=%s id=%0d", PORT, id);
                size_ring[id][tail[id]] = sample_cb.arsize;
                remaining_ring[id][tail[id]] = {1'b0, sample_cb.arlen} + 9'd1;
                tail[id] = (tail[id] + 1) % RING;
                used[id]++;
                ar_count++;
            end
            if (sample_cb.wvalid === 1'b1 && sample_cb.wready === 1'b1) begin
                if ($isunknown({sample_cb.wstrb, sample_cb.wlast}))
                    $fatal(1, "D2_PHASE_PROBE_INVALID WSTRB/WLAST port=%s", PORT);
                strobe_bytes = 0;
                for (int bit_idx = 0; bit_idx < 4; bit_idx++)
                    if (sample_cb.wstrb[bit_idx] === 1'b1) strobe_bytes++;
                w_strobe_bytes += strobe_bytes;
                w_beats++;
                if (sample_cb.wlast === 1'b1) wlast_count++;
            end
            if (read_on_empty)
                consume_read(int'(sample_cb.rid), sample_cb.rlast);
            if (sample_cb.bvalid === 1'b1 && sample_cb.bready === 1'b1) begin
                last_b_id = sample_cb.bid;
                last_b_resp = sample_cb.bresp;
                if (!first_b_seen) begin
                    first_b_seen = 1;
                    $display("DIAG_FIRST_B_SAMPLE port=%s cycle=%0d count=%0d id=%b resp=%b",
                             PORT, sample_cycle, b_count+1, last_b_id, last_b_resp);
                end
                b_count++;
            end
            if (PORT == "qkv0" && sample_cycle >= 9998 && sample_cycle <= 10024) begin
                $display("DIAG_EDGE_WINDOW kind=monitor_preedge_1step cycle=%0d sim_ps=%0d aw=%b%b w=%b%b b=%b%b bid=%b bresp=%b ar=%b%b r=%b%b rid=%b rresp=%b rlast=%b rdata=%08x counts=%0d,%0d,%0d,%0d,%0d stored_b=%b,%b stored_r=%b,%b,%b,%08x first=%b,%b",
                         sample_cycle, longint'($realtime*1000.0),
                         sample_cb.awvalid, sample_cb.awready,
                         sample_cb.wvalid, sample_cb.wready,
                         sample_cb.bvalid, sample_cb.bready,
                         sample_cb.bid, sample_cb.bresp,
                         sample_cb.arvalid, sample_cb.arready,
                         sample_cb.rvalid, sample_cb.rready,
                         sample_cb.rid, sample_cb.rresp,
                         sample_cb.rlast, sample_cb.rdata,
                         aw_count, w_beats, b_count, ar_count, r_beats,
                         last_b_id, last_b_resp,
                         last_r_id, last_r_resp, last_r_last, last_r_data,
                         first_b_seen, first_r_seen);
                $fflush();
            end
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
