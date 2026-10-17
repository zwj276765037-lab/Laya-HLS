`timescale 1ns/1ps

// Each width has a separate driver, wire monitor, and byte oracle.
module axi_static_unit_agent #(
    parameter int DATA_BITS = 32
) (
    input logic clk,
    input logic resetn,
    input logic [1:0] mode,
    output logic done
);
  localparam int DATA_BYTES = DATA_BITS/8;
  localparam int TOTAL_BYTES = 4*4096;
  localparam logic [63:0] BASE0 = 64'h0000_0011_0000_1000;
  localparam logic [63:0] BASE1 = 64'h0000_0022_0000_1000;
  localparam logic [63:0] BASE2 = 64'h0000_0011_0000_2000;
  localparam logic [63:0] BASE3 = 64'h0000_0011_0000_3000;

  logic warm_reset;
  wire dut_resetn = resetn && !warm_reset;
  logic awid, awvalid, awready, wid, wlast, wvalid, wready;
  logic bid, bvalid, bready, arid, arvalid, arready;
  logic rid, rlast, rvalid, rready;
  logic [63:0] awaddr, araddr;
  logic [7:0] awlen, arlen;
  logic [2:0] awsize, arsize;
  logic [1:0] awburst, arburst, bresp, rresp;
  logic [DATA_BITS-1:0] wdata, rdata;
  logic [DATA_BYTES-1:0] wstrb;

  axi_static_memory #(.DATA_BITS(DATA_BITS)) dut (
      .aclk(clk), .aresetn(dut_resetn),
      .awid(awid), .awaddr(awaddr), .awlen(awlen), .awsize(awsize),
      .awburst(awburst), .awvalid(awvalid), .awready(awready),
      .wid(wid), .wdata(wdata), .wstrb(wstrb), .wlast(wlast),
      .wvalid(wvalid), .wready(wready),
      .bid(bid), .bresp(bresp), .bvalid(bvalid), .bready(bready),
      .arid(arid), .araddr(araddr), .arlen(arlen), .arsize(arsize),
      .arburst(arburst), .arvalid(arvalid), .arready(arready),
      .rid(rid), .rdata(rdata), .rresp(rresp), .rlast(rlast),
      .rvalid(rvalid), .rready(rready)
  );

  logic [7:0] expected_bytes [0:TOTAL_BYTES-1];
  int pair_index, tx_beats, tx_bytes, tx_page;
  logic [63:0] tx_addr;
  logic tx_id;
  int send_beat, b_pause, r_pause;
  logic aw_fire_q, w_fire_q, b_fire_q, ar_fire_q, r_fire_q, r_last_fire_q;
  int aw_seen, w_seen, b_seen, ar_seen, r_seen, expected_beat_total;
  int w_in_pair, r_in_pair;
  logic aw_accepted_pair, b_seen_for_pair;
  logic aw_held, w_held, ar_held, b_held, r_held;
  logic held_awid, held_wid, held_wlast, held_arid;
  logic [63:0] held_awaddr, held_araddr;
  logic [7:0] held_awlen, held_arlen;
  logic [2:0] held_awsize, held_arsize;
  logic [1:0] held_awburst, held_arburst;
  logic [DATA_BITS-1:0] held_wdata;
  logic [DATA_BYTES-1:0] held_wstrb;
  logic held_bid, held_rid, held_rlast;
  logic [1:0] held_bresp, held_rresp;
  logic [DATA_BITS-1:0] held_rdata;
  int b_stall_run, r_stall_run, b_stall_max, r_stall_max;
  int cov_page [0:3];
  int cov_len [0:2];
  int cov_id [0:1];
  int cov_full, cov_narrow, cov_nonzero_lane, cov_aw_first, cov_w_first;
  int cov_zero_strobe, cov_sparse_strobe, cov_full_strobe, cov_boundary;

  typedef enum logic [3:0] {
    PLAN, AW_FIRST, W_BEFORE_AW, AW_AFTER_W, WRITE_BEATS,
    WAIT_B, SEND_AR, WAIT_R, WARM_ONE, WARM_TWO, FINAL_CHECK,
    FINISHED, NEG_AW, NEG_W, NEG_WAIT
  } driver_state_t;
  driver_state_t state;

  function automatic logic [63:0] planned_page(input int page);
    case (page)
      0: return BASE0;
      1: return BASE1;
      2: return BASE2;
      default: return BASE3;
    endcase
  endfunction

  // The oracle uses complete 64-bit ranges and an independent arithmetic map.
  function automatic int expected_index(input logic [63:0] address);
    if (address >= BASE0 && address < BASE0+64'd4096)
      return int'(address-BASE0);
    if (address >= BASE1 && address < BASE1+64'd4096)
      return 4096+int'(address-BASE1);
    if (address >= BASE2 && address < BASE2+64'd4096)
      return 8192+int'(address-BASE2);
    if (address >= BASE3 && address < BASE3+64'd4096)
      return 12288+int'(address-BASE3);
    $fatal(1,"AXI_STATIC_SCOREBOARD_UNMAPPED address=%h",address);
    return -1;
  endfunction

  function automatic logic [DATA_BITS-1:0] planned_data(input int pair,
                                                          input int beat);
    logic [DATA_BITS-1:0] value;
    for (int lane=0; lane<DATA_BYTES; ++lane)
      value[8*lane +: 8] = 8'((pair*11 + beat*23 + lane*7 + DATA_BYTES) & 255);
    return value;
  endfunction

  function automatic logic [2:0] size_code(input int bytes_per_beat);
    case (bytes_per_beat)
      1: return 0;
      2: return 1;
      4: return 2;
      8: return 3;
      64: return 6;
      default: begin
        $fatal(1,"AXI_STATIC_BAD_PLANNED_SIZE");
        return 3'bxxx;
      end
    endcase
  endfunction

  function automatic logic [DATA_BYTES-1:0] planned_strobe(
      input int pair, input int beat, input logic [63:0] address,
      input int bytes_per_beat);
    logic [DATA_BYTES-1:0] value;
    logic [63:0] byte_address;
    logic [63:0] bus_base;
    value='0;
    byte_address=address+beat*bytes_per_beat;
    bus_base=byte_address-(byte_address % DATA_BYTES);
    for (int lane=0; lane<DATA_BYTES; ++lane) begin
      if (bus_base+lane >= byte_address &&
          bus_base+lane < byte_address+bytes_per_beat) begin
        if (pair%3 == 1 || (pair%3 == 2 && ((lane+beat)&1)==0))
          value[lane]=1;
      end
    end
    return value;
  endfunction

  // A zero-time helper only; the clocked driver below owns all timing.
  task automatic put_write_beat(input int beat);
    wdata = planned_data(pair_index,beat);
    wstrb = planned_strobe(pair_index,beat,tx_addr,tx_bytes);
    wid = tx_id;
    wlast = (beat == tx_beats-1);
    wvalid = 1;
  endtask

  task automatic prepare_pair(input int pair);
    int offset;
    tx_page = pair%4;
    case (pair%3)
      0: tx_beats=1;
      1: tx_beats=2;
      default: tx_beats=16;
    endcase
    case (pair%4)
      0: tx_bytes=DATA_BYTES;
      1: tx_bytes=1;
      2: tx_bytes=2;
      default: tx_bytes=(DATA_BYTES==4 ? 4 : 8);
    endcase
    if (pair%16 == 15) offset=4096-tx_beats*tx_bytes;
    else if (tx_bytes == DATA_BYTES)
      offset=((128+pair*37)%2048)/DATA_BYTES*DATA_BYTES;
    else
      offset=128+(((pair*37)%1000)/DATA_BYTES)*DATA_BYTES+tx_bytes;
    tx_addr=planned_page(tx_page)+offset;
    tx_id=1'((pair/4)&1);
    awaddr=tx_addr; awlen=8'(tx_beats-1);
    awsize=size_code(tx_bytes); awburst=2'b01; awid=tx_id;
    araddr=tx_addr; arlen=8'(tx_beats-1);
    arsize=size_code(tx_bytes); arburst=2'b01; arid=tx_id;
    send_beat=0; b_pause=0; r_pause=0;
  endtask

  initial begin
    for (int i=0; i<TOTAL_BYTES; ++i)
      expected_bytes[i]=8'((i*37+13)&255);
  end

  // All driven controls change at negedge, and VALID/data remain until a
  // sampled posedge handshake. No timed task or nested wait context is used.
  always @(negedge clk) begin
    if (!resetn) begin
      state=PLAN; pair_index=0; send_beat=0; b_pause=0; r_pause=0;
      warm_reset=0; done=0;
      awid=0; awaddr=0; awlen=0; awsize=0; awburst=0; awvalid=0;
      wid=0; wdata=0; wstrb=0; wlast=0; wvalid=0; bready=0;
      arid=0; araddr=0; arlen=0; arsize=0; arburst=0; arvalid=0;
      rready=0;
    end else begin
      case (state)
        PLAN: begin
          if (mode == 0 || (mode != 1 && DATA_BITS == 512)) begin
            done=1; state=FINISHED;
          end else if (mode == 2 || mode == 3) begin
            awid=1; awaddr=BASE0+(mode==2 ? 64'd4092 : 64'd0);
            awlen=1; awsize=2; awburst=2'b01; awvalid=1;
            state=NEG_AW;
          end else if (pair_index == 512) begin
            state=WARM_ONE;
          end else begin
            prepare_pair(pair_index);
            if ((pair_index & 1) == 0) begin
              awvalid=1; state=AW_FIRST;
            end else begin
              put_write_beat(0); state=W_BEFORE_AW;
            end
          end
        end
        AW_FIRST: if (aw_fire_q) begin
          awvalid=0; put_write_beat(0); state=WRITE_BEATS;
        end
        W_BEFORE_AW: if (w_fire_q) begin
          wvalid=0; send_beat=1; awvalid=1; state=AW_AFTER_W;
        end
        AW_AFTER_W: if (aw_fire_q) begin
          awvalid=0;
          if (send_beat == tx_beats) state=WAIT_B;
          else begin put_write_beat(send_beat); state=WRITE_BEATS; end
        end
        WRITE_BEATS: if (w_fire_q) begin
          send_beat=send_beat+1;
          if (send_beat == tx_beats) begin
            wvalid=0; state=WAIT_B;
          end else put_write_beat(send_beat);
        end
        WAIT_B: begin
          if (b_fire_q) begin
            bready=0; arvalid=1; state=SEND_AR;
          end else if (bvalid && b_pause < 3) begin
            bready=0; b_pause=b_pause+1;
          end else if (bvalid) bready=1;
        end
        SEND_AR: if (ar_fire_q) begin
          arvalid=0; rready=0; state=WAIT_R;
        end
        WAIT_R: begin
          if (r_fire_q && r_last_fire_q) begin
            rready=0; pair_index=pair_index+1; state=PLAN;
          end else if (rvalid && r_pause < 3) begin
            rready=0; r_pause=r_pause+1;
          end else if (rvalid) rready=1;
        end
        WARM_ONE: begin warm_reset=1; state=WARM_TWO; end
        WARM_TWO: begin warm_reset=0; state=FINAL_CHECK; end
        FINAL_CHECK: begin
          if (bvalid || rvalid || dut.aw_count!=0 || dut.w_count!=0 ||
              dut.b_count!=0 || dut.ar_count!=0)
            $fatal(1,"AXI_STATIC_WARM_RESET_STALE width=%0d",DATA_BITS);
          done=1; state=FINISHED;
        end
        NEG_AW: if (aw_fire_q) begin
          awvalid=0;
          if (mode==3) begin
            wid=1; wdata='0; wstrb='1; wlast=1; wvalid=1;
            state=NEG_W;
          end else state=NEG_WAIT;
        end
        NEG_W: if (w_fire_q) begin wvalid=0; state=NEG_WAIT; end
        NEG_WAIT: ;
        FINISHED: ;
        default: $fatal(1,"AXI_STATIC_DRIVER_STATE");
      endcase
    end
  end

  // Independent monitor samples wires before endpoint NBA state updates.
  always @(posedge clk) begin : wire_monitor
    logic [63:0] beat_addr, bus_base, lane_addr;
    logic [DATA_BITS-1:0] wanted;
    int index;
    if (!resetn) begin
      aw_fire_q<=0; w_fire_q<=0; b_fire_q<=0;
      ar_fire_q<=0; r_fire_q<=0; r_last_fire_q<=0;
      aw_seen<=0; w_seen<=0; b_seen<=0; ar_seen<=0; r_seen<=0;
      expected_beat_total<=0; w_in_pair<=0; r_in_pair<=0;
      aw_accepted_pair<=0; b_seen_for_pair<=0;
      aw_held<=0; w_held<=0; ar_held<=0; b_held<=0; r_held<=0;
      b_stall_run<=0; r_stall_run<=0;
      b_stall_max<=0; r_stall_max<=0;
      cov_full<=0; cov_narrow<=0; cov_nonzero_lane<=0;
      cov_aw_first<=0; cov_w_first<=0; cov_zero_strobe<=0;
      cov_sparse_strobe<=0; cov_full_strobe<=0; cov_boundary<=0;
      for (int p=0; p<4; ++p) cov_page[p]<=0;
      for (int n=0; n<3; ++n) cov_len[n]<=0;
      for (int id=0; id<2; ++id) cov_id[id]<=0;
    end else if (warm_reset) begin
      aw_fire_q<=0; w_fire_q<=0; b_fire_q<=0;
      ar_fire_q<=0; r_fire_q<=0; r_last_fire_q<=0;
      aw_held<=0; w_held<=0; ar_held<=0; b_held<=0; r_held<=0;
    end else begin
      aw_fire_q<=awvalid && awready;
      w_fire_q<=wvalid && wready;
      b_fire_q<=bvalid && bready;
      ar_fire_q<=arvalid && arready;
      r_fire_q<=rvalid && rready;
      r_last_fire_q<=rvalid && rready && rlast;
      if (mode==1) begin
        if (aw_held && (!awvalid || awid !== held_awid ||
                        awaddr !== held_awaddr || awlen !== held_awlen ||
                        awsize !== held_awsize || awburst !== held_awburst))
          $fatal(1,"AXI_STATIC_AW_UNSTABLE width=%0d",DATA_BITS);
        if (w_held && (!wvalid || wid !== held_wid ||
                       wdata !== held_wdata || wstrb !== held_wstrb ||
                       wlast !== held_wlast))
          $fatal(1,"AXI_STATIC_W_UNSTABLE width=%0d",DATA_BITS);
        if (ar_held && (!arvalid || arid !== held_arid ||
                        araddr !== held_araddr || arlen !== held_arlen ||
                        arsize !== held_arsize || arburst !== held_arburst))
          $fatal(1,"AXI_STATIC_AR_UNSTABLE width=%0d",DATA_BITS);
        if (b_held && (!bvalid || bid !== held_bid ||
                       bresp !== held_bresp))
          $fatal(1,"AXI_STATIC_B_UNSTABLE width=%0d",DATA_BITS);
        if (r_held && (!rvalid || rid !== held_rid ||
                       rdata !== held_rdata || rresp !== held_rresp ||
                       rlast !== held_rlast))
          $fatal(1,"AXI_STATIC_R_UNSTABLE width=%0d",DATA_BITS);
        aw_held<=awvalid && !awready;
        w_held<=wvalid && !wready;
        ar_held<=arvalid && !arready;
        if (awvalid && !awready) begin
          held_awid<=awid; held_awaddr<=awaddr; held_awlen<=awlen;
          held_awsize<=awsize; held_awburst<=awburst;
        end
        if (wvalid && !wready) begin
          held_wid<=wid; held_wdata<=wdata; held_wstrb<=wstrb;
          held_wlast<=wlast;
        end
        if (arvalid && !arready) begin
          held_arid<=arid; held_araddr<=araddr; held_arlen<=arlen;
          held_arsize<=arsize; held_arburst<=arburst;
        end
        b_held<=bvalid && !bready;
        r_held<=rvalid && !rready;
        if (bvalid && !bready) begin
          held_bid<=bid; held_bresp<=bresp;
          b_stall_run<=b_stall_run+1;
          if (b_stall_run+1>b_stall_max) b_stall_max<=b_stall_run+1;
        end else b_stall_run<=0;
        if (rvalid && !rready) begin
          held_rid<=rid; held_rresp<=rresp; held_rdata<=rdata;
          held_rlast<=rlast; r_stall_run<=r_stall_run+1;
          if (r_stall_run+1>r_stall_max) r_stall_max<=r_stall_run+1;
        end else r_stall_run<=0;

        if (awvalid && awready) begin
          if (awaddr !== tx_addr || awlen !== 8'(tx_beats-1) ||
              awsize !== size_code(tx_bytes) || awburst !== 2'b01 ||
              awid !== tx_id || aw_accepted_pair)
            $fatal(1,"AXI_STATIC_AW_MISMATCH width=%0d pair=%0d",DATA_BITS,pair_index);
          if (pair_index&1) begin
            if (w_in_pair!=1) $fatal(1,"AXI_STATIC_W_BEFORE_AW_MISSING");
            cov_w_first<=cov_w_first+1;
          end else begin
            if (w_in_pair!=0) $fatal(1,"AXI_STATIC_AW_BEFORE_W_MISSING");
            cov_aw_first<=cov_aw_first+1;
          end
          aw_accepted_pair<=1; aw_seen<=aw_seen+1;
          expected_beat_total<=expected_beat_total+tx_beats;
          cov_page[tx_page]<=cov_page[tx_page]+1;
          cov_id[tx_id]<=cov_id[tx_id]+1;
          cov_len[pair_index%3]<=cov_len[pair_index%3]+1;
          if (tx_bytes==DATA_BYTES) cov_full<=cov_full+1;
          else cov_narrow<=cov_narrow+1;
          if (tx_bytes<DATA_BYTES && (tx_addr%DATA_BYTES)!=0)
            cov_nonzero_lane<=cov_nonzero_lane+1;
          if ((tx_addr-planned_page(tx_page)) + tx_beats*tx_bytes == 4096)
            cov_boundary<=cov_boundary+1;
        end
        if (wvalid && wready) begin
          if (wid !== tx_id || wdata !== planned_data(pair_index,w_in_pair) ||
              wstrb !== planned_strobe(pair_index,w_in_pair,tx_addr,tx_bytes) ||
              wlast !== (w_in_pair==tx_beats-1))
            $fatal(1,"AXI_STATIC_W_MISMATCH width=%0d pair=%0d beat=%0d",
                   DATA_BITS,pair_index,w_in_pair);
          if ((pair_index&1)==0 && !aw_accepted_pair)
            $fatal(1,"AXI_STATIC_AW_FIRST_ORDER");
          beat_addr=tx_addr+w_in_pair*tx_bytes;
          bus_base=beat_addr-(beat_addr%DATA_BYTES);
          for (int lane=0; lane<DATA_BYTES; ++lane) begin
            if (wstrb[lane]) begin
              lane_addr=bus_base+lane;
              if (lane_addr<beat_addr || lane_addr>=beat_addr+tx_bytes)
                $fatal(1,"AXI_STATIC_ORACLE_STROBE");
              index=expected_index(lane_addr);
              expected_bytes[index]=wdata[8*lane +:8];
            end
          end
          w_in_pair<=w_in_pair+1; w_seen<=w_seen+1;
          case (pair_index%3)
            0: cov_zero_strobe<=cov_zero_strobe+1;
            1: cov_full_strobe<=cov_full_strobe+1;
            2: cov_sparse_strobe<=cov_sparse_strobe+1;
          endcase
        end
        if (bvalid && !b_seen_for_pair) begin
          if (!aw_accepted_pair || w_in_pair!=tx_beats)
            $fatal(1,"AXI_STATIC_B_BEFORE_FINAL_W");
          // B must follow real memory commit, not a software completion flag.
          for (int byte_no=0; byte_no<tx_beats*tx_bytes; ++byte_no) begin
            index=expected_index(tx_addr+byte_no);
            if (dut.mem[index] !== expected_bytes[index])
              $fatal(1,"AXI_STATIC_B_BEFORE_COMMIT width=%0d pair=%0d byte=%0d",
                     DATA_BITS,pair_index,byte_no);
          end
          b_seen_for_pair<=1;
        end
        if (bvalid && bready) begin
          if (bid !== tx_id || bresp !== 2'b00 || !b_seen_for_pair)
            $fatal(1,"AXI_STATIC_B_MISMATCH");
          b_seen<=b_seen+1;
        end
        if (arvalid && arready) begin
          if (araddr !== tx_addr || arlen !== 8'(tx_beats-1) ||
              arsize !== size_code(tx_bytes) || arburst !== 2'b01 ||
              arid !== tx_id || b_seen!=pair_index+1)
            $fatal(1,"AXI_STATIC_AR_MISMATCH");
          ar_seen<=ar_seen+1;
        end
        if (rvalid && rready) begin
          beat_addr=tx_addr+r_in_pair*tx_bytes;
          bus_base=beat_addr-(beat_addr%DATA_BYTES);
          wanted='0;
          for (int lane=0; lane<DATA_BYTES; ++lane) begin
            lane_addr=bus_base+lane;
            if (lane_addr>=beat_addr && lane_addr<beat_addr+tx_bytes) begin
              index=expected_index(lane_addr);
              wanted[8*lane +:8]=expected_bytes[index];
            end
          end
          if (rid !== tx_id || rresp !== 2'b00 ||
              rlast !== (r_in_pair==tx_beats-1) || rdata !== wanted ||
              $isunknown(rdata))
            $fatal(1,"AXI_STATIC_R_MISMATCH width=%0d pair=%0d beat=%0d",
                   DATA_BITS,pair_index,r_in_pair);
          r_seen<=r_seen+1;
          if (rlast) begin
            if (r_in_pair!=tx_beats-1 || w_in_pair!=tx_beats)
              $fatal(1,"AXI_STATIC_PAIR_INCOMPLETE");
            r_in_pair<=0; w_in_pair<=0;
            aw_accepted_pair<=0; b_seen_for_pair<=0;
          end else r_in_pair<=r_in_pair+1;
        end
      end
    end
  end

  task automatic verify_final;
    if (!done || bvalid || rvalid || awvalid || wvalid || arvalid ||
        dut.aw_count!=0 || dut.w_count!=0 || dut.b_count!=0 ||
        dut.ar_count!=0 || dut.write_beat!=0 || dut.read_beat!=0)
      $fatal(1,"AXI_STATIC_NOT_DRAINED width=%0d",DATA_BITS);
    for (int i=0; i<TOTAL_BYTES; ++i) begin
      if ($isunknown(dut.mem[i]) || dut.mem[i] !== expected_bytes[i])
        $fatal(1,"AXI_STATIC_FINAL_BYTE width=%0d index=%0d expected=%h got=%h",
               DATA_BITS,i,expected_bytes[i],dut.mem[i]);
    end
    if (mode==0) begin
      if (aw_seen!=0 || w_seen!=0 || b_seen!=0 || ar_seen!=0 || r_seen!=0)
        $fatal(1,"AXI_STATIC_IDLE_ACTIVITY width=%0d",DATA_BITS);
    end else if (mode==1) begin
      if (pair_index!=512 || aw_seen!=512 || b_seen!=512 || ar_seen!=512 ||
          w_seen!=expected_beat_total || r_seen!=expected_beat_total ||
          b_stall_max<3 || r_stall_max<3 ||
          cov_full==0 || cov_narrow==0 || cov_nonzero_lane==0 ||
          cov_aw_first==0 || cov_w_first==0 || cov_zero_strobe==0 ||
          cov_sparse_strobe==0 || cov_full_strobe==0 || cov_boundary==0)
        $fatal(1,"AXI_STATIC_COVERAGE width=%0d pairs=%0d AW=%0d B=%0d AR=%0d W=%0d R=%0d expected=%0d bstall=%0d rstall=%0d",
               DATA_BITS,pair_index,aw_seen,b_seen,ar_seen,w_seen,r_seen,
               expected_beat_total,b_stall_max,r_stall_max);
      for (int p=0;p<4;++p) if (cov_page[p]==0)
        $fatal(1,"AXI_STATIC_PAGE_COVERAGE width=%0d page=%0d",DATA_BITS,p);
      for (int n=0;n<3;++n) if (cov_len[n]==0)
        $fatal(1,"AXI_STATIC_LEN_COVERAGE width=%0d len_class=%0d",DATA_BITS,n);
      for (int id=0;id<2;++id) if (cov_id[id]==0)
        $fatal(1,"AXI_STATIC_ID_COVERAGE width=%0d id=%0d",DATA_BITS,id);
    end
  endtask
endmodule

module axi_static_unit_top;
  logic clk=0;
  always #5 clk=~clk;
  logic resetn=0;
  logic [1:0] mode;
  logic done32, done512;
  int post_reset_clocks=0;
  import "DPI-C" function void phase_probe_stage(input string label,
      input longint sim_time_ps, input longint clock_count,
      input longint value0, input longint value1);

  axi_static_unit_agent #(.DATA_BITS(32)) u32 (
      .clk(clk),.resetn(resetn),.mode(mode),.done(done32));
  axi_static_unit_agent #(.DATA_BITS(512)) u512 (
      .clk(clk),.resetn(resetn),.mode(mode),.done(done512));

  initial begin
    if ($test$plusargs("STATIC_MODE=idle")) mode=0;
    else if ($test$plusargs("STATIC_MODE=traffic")) mode=1;
    else if ($test$plusargs("STATIC_MODE=reject_4k")) mode=2;
    else if ($test$plusargs("STATIC_MODE=reject_wlast")) mode=3;
    else $fatal(1,"AXI_STATIC_MODE_MISSING");
    repeat (5) @(negedge clk);
    #1;
    resetn=1;
    if (mode==0)
      phase_probe_stage("static_idle",longint'($realtime*1000.0),
                        0,u32.aw_seen,u512.aw_seen);
    else if (mode==1)
      phase_probe_stage("static_traffic",longint'($realtime*1000.0),
                        0,u32.aw_seen,u512.aw_seen);
  end

  initial begin
    forever begin
      @(posedge clk);
      if (resetn) begin
        post_reset_clocks=post_reset_clocks+1;
        if ((mode==0 || mode==1) &&
            (post_reset_clocks==10000 || post_reset_clocks==50000 ||
             post_reset_clocks==100000)) begin
          if (mode==0)
            phase_probe_stage("static_idle",longint'($realtime*1000.0),
                              post_reset_clocks,u32.aw_seen,u512.aw_seen);
          else
            phase_probe_stage("static_traffic",longint'($realtime*1000.0),
                              post_reset_clocks,u32.aw_seen,u512.aw_seen);
        end
        if (mode>=2 && post_reset_clocks>=1000)
          $fatal(1,"AXI_STATIC_REJECTION_MISSING");
        if ((mode==0 || mode==1) && post_reset_clocks==100000) begin
          u32.verify_final();
          u512.verify_final();
          if (mode==0)
            $display("AXI_STATIC_IDLE_PASS clocks=100000 bytes=32768 aw=0 w=0 b=0 ar=0 r=0");
          else
            $display("AXI_STATIC_TRAFFIC_PASS clocks=100000 pairs=1024 bytes=32768 aw=%0d b=%0d ar=%0d w=%0d r=%0d bstall32=%0d rstall32=%0d bstall512=%0d rstall512=%0d",
                     u32.aw_seen+u512.aw_seen,u32.b_seen+u512.b_seen,
                     u32.ar_seen+u512.ar_seen,u32.w_seen+u512.w_seen,
                     u32.r_seen+u512.r_seen,u32.b_stall_max,u32.r_stall_max,
                     u512.b_stall_max,u512.r_stall_max);
          $finish;
        end
      end
    end
  end
endmodule
