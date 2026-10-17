// Fixed-capacity, four-state AXI memory endpoint for bounded RTL verification.
module axi_static_memory #(
    parameter int DATA_BITS = 32,
    parameter int ADDR_BITS = 64,
    parameter int ID_BITS = 1,
    parameter int PAGE_CAPACITY = 4,
    // Page i occupies bits [64*i +: 64]. A later DUT may bind 32 or more
    // finite pages without changing the protocol engine.
    parameter logic [PAGE_CAPACITY*64-1:0] PAGE_BASES = {
        64'h0000_0011_0000_3000, 64'h0000_0011_0000_2000,
        64'h0000_0022_0000_1000, 64'h0000_0011_0000_1000}
) (
    input  logic                    aclk,
    input  logic                    aresetn,
    input  logic [ID_BITS-1:0]      awid,
    input  logic [ADDR_BITS-1:0]    awaddr,
    input  logic [7:0]              awlen,
    input  logic [2:0]              awsize,
    input  logic [1:0]              awburst,
    input  logic                    awvalid,
    output logic                    awready,
    input  logic [ID_BITS-1:0]      wid,
    input  logic [DATA_BITS-1:0]    wdata,
    input  logic [DATA_BITS/8-1:0]  wstrb,
    input  logic                    wlast,
    input  logic                    wvalid,
    output logic                    wready,
    output logic [ID_BITS-1:0]      bid,
    output logic [1:0]              bresp,
    output logic                    bvalid,
    input  logic                    bready,
    input  logic [ID_BITS-1:0]      arid,
    input  logic [ADDR_BITS-1:0]    araddr,
    input  logic [7:0]              arlen,
    input  logic [2:0]              arsize,
    input  logic [1:0]              arburst,
    input  logic                    arvalid,
    output logic                    arready,
    output logic [ID_BITS-1:0]      rid,
    output logic [DATA_BITS-1:0]    rdata,
    output logic [1:0]              rresp,
    output logic                    rlast,
    output logic                    rvalid,
    input  logic                    rready
);
  localparam int PAGE_BYTES = 4096;
  localparam int DATA_BYTES = DATA_BITS / 8;
  localparam int AW_DEPTH = 4;
  localparam int AR_DEPTH = 4;
  localparam int W_DEPTH = 64;
  localparam int B_DEPTH = 4;

  // Four-state data survives every synchronous protocol reset.
  logic [7:0] mem [0:PAGE_CAPACITY*PAGE_BYTES-1];

  logic [63:0] aw_address [0:AW_DEPTH-1];
  logic [7:0] aw_length [0:AW_DEPTH-1];
  logic [2:0] aw_size [0:AW_DEPTH-1];
  logic [ID_BITS-1:0] aw_id [0:AW_DEPTH-1];
  logic [1:0] aw_head, aw_tail;
  logic [2:0] aw_count;
  logic [4:0] write_beat;

  logic [DATA_BITS-1:0] w_data [0:W_DEPTH-1];
  logic [DATA_BYTES-1:0] w_strobe [0:W_DEPTH-1];
  logic w_last [0:W_DEPTH-1];
  logic [ID_BITS-1:0] w_id [0:W_DEPTH-1];
  logic [5:0] w_head, w_tail;
  logic [6:0] w_count;

  logic [ID_BITS-1:0] b_id [0:B_DEPTH-1];
  logic [1:0] b_head, b_tail;
  logic [2:0] b_count;

  logic [63:0] ar_address [0:AR_DEPTH-1];
  logic [7:0] ar_length [0:AR_DEPTH-1];
  logic [2:0] ar_size [0:AR_DEPTH-1];
  logic [ID_BITS-1:0] ar_id [0:AR_DEPTH-1];
  logic [1:0] ar_head, ar_tail;
  logic [2:0] ar_count;
  logic [4:0] read_beat;

  logic aw_push, aw_pop, w_push, w_pop, b_push, b_pop;
  logic ar_push, ar_pop, write_commit, read_take;

  function automatic logic [63:0] page_base(input int slot);
    return PAGE_BASES[slot*64 +: 64];
  endfunction

  function automatic int page_slot(input logic [63:0] address);
    logic [63:0] base;
    for (int p=0; p<PAGE_CAPACITY; ++p) begin
      base=page_base(p);
      if (address[63:12] == base[63:12]) return p;
    end
    return -1;
  endfunction

  // 65-bit end arithmetic distinguishes a legal page end from wraparound.
  function automatic int burst_error(input logic [63:0] address,
                                     input logic [7:0] len,
                                     input logic [2:0] size,
                                     input logic [1:0] burst);
    logic [64:0] bytes_total;
    logic [64:0] last_byte;
    if (burst !== 2'b01) return 1;
    if (len >= 16) return 2;
    if (size > $clog2(DATA_BYTES)) return 3;
    if ((address & ((64'd1 << size)-1)) != 0) return 4;
    bytes_total = ({57'd0, len} + 65'd1) << size;
    last_byte = {1'b0,address} + bytes_total - 65'd1;
    if (last_byte[64]) return 5;
    if (address[63:12] != last_byte[63:12]) return 6;
    if (page_slot(address) < 0 || page_slot(last_byte[63:0]) < 0) return 7;
    return 0;
  endfunction

  initial begin : initialize_backing
    logic [63:0] base_p, base_q;
    if (ADDR_BITS != 64 || ID_BITS != 1 || PAGE_CAPACITY < 1 ||
        (DATA_BITS != 32 && DATA_BITS != 512))
      $fatal(1, "AXI_STATIC_BAD_PARAMETERS");
    for (int p=0; p<PAGE_CAPACITY; ++p) begin
      base_p=page_base(p);
      if (base_p[11:0] != 0)
        $fatal(1, "AXI_STATIC_UNALIGNED_PAGE");
      for (int q=0; q<p; ++q) begin
        base_q=page_base(q);
        if (base_p == base_q)
          $fatal(1, "AXI_STATIC_DUP_PAGE");
      end
    end
    for (int i = 0; i < PAGE_CAPACITY*PAGE_BYTES; ++i)
      mem[i] = 8'((i*37 + 13) & 255);
  end

  always_comb begin
    awready = aresetn && (aw_count < AW_DEPTH);
    wready  = aresetn && (w_count < W_DEPTH);
    arready = aresetn && (ar_count < AR_DEPTH);
    bvalid  = aresetn && (b_count != 0);
    bid     = b_id[b_head];
    bresp   = 2'b00;
    aw_push = awvalid && awready;
    w_push  = wvalid && wready;
    ar_push = arvalid && arready;
    b_pop   = bvalid && bready;
    // Conservative B reservation: every final commit has a free response slot.
    write_commit = aresetn && (aw_count != 0) && (w_count != 0) &&
                   (b_count < B_DEPTH);
    w_pop = write_commit;
    aw_pop = write_commit && (write_beat == aw_length[aw_head]);
    b_push = aw_pop;
    read_take = rvalid && rready;
    ar_pop = read_take && rlast;
  end

  always_ff @(posedge aclk) begin : protocol_step
    logic [64:0] beat_address;
    logic [64:0] lane_address;
    logic [64:0] word_base;
    logic [64:0] transfer_end;
    logic [DATA_BITS-1:0] next_read_data;
    int slot;
    int error_code;
    if (!aresetn) begin
      aw_head <= 0; aw_tail <= 0; aw_count <= 0; write_beat <= 0;
      w_head <= 0; w_tail <= 0; w_count <= 0;
      b_head <= 0; b_tail <= 0; b_count <= 0;
      ar_head <= 0; ar_tail <= 0; ar_count <= 0; read_beat <= 0;
      rvalid <= 0; rdata <= 0; rid <= 0; rresp <= 0; rlast <= 0;
    end else begin
      if ($isunknown({awvalid,wvalid,arvalid,bready,rready}))
        $fatal(1,"AXI_STATIC_CHANNEL_UNKNOWN");
      if (aw_push) begin
        if ($isunknown({awid,awaddr,awlen,awsize,awburst}))
          $fatal(1,"AXI_STATIC_AWUNKNOWN");
        error_code = burst_error(awaddr,awlen,awsize,awburst);
        case (error_code)
          1: $fatal(1,"AXI_STATIC_AWBURST");
          2: $fatal(1,"AXI_STATIC_AWLEN");
          3: $fatal(1,"AXI_STATIC_AWSIZE");
          4: $fatal(1,"AXI_STATIC_AWALIGN");
          5: $fatal(1,"AXI_STATIC_AWOVERFLOW");
          6: $fatal(1,"AXI_STATIC_4K_CROSS");
          7: $fatal(1,"AXI_STATIC_AWUNMAPPED");
        endcase
        aw_address[aw_tail] <= awaddr;
        aw_length[aw_tail] <= awlen;
        aw_size[aw_tail] <= awsize;
        aw_id[aw_tail] <= awid;
        aw_tail <= aw_tail + 1'b1;
      end
      if (w_push) begin
        if ($isunknown({wid,wstrb,wlast}))
          $fatal(1,"AXI_STATIC_WUNKNOWN");
        for (int lane=0; lane<DATA_BYTES; ++lane)
          if (wstrb[lane] && $isunknown(wdata[lane*8 +: 8]))
            $fatal(1,"AXI_STATIC_WDATA_UNKNOWN");
        w_data[w_tail] <= wdata;
        w_strobe[w_tail] <= wstrb;
        w_last[w_tail] <= wlast;
        w_id[w_tail] <= wid;
        w_tail <= w_tail + 1'b1;
      end
      if (ar_push) begin
        if ($isunknown({arid,araddr,arlen,arsize,arburst}))
          $fatal(1,"AXI_STATIC_ARUNKNOWN");
        error_code = burst_error(araddr,arlen,arsize,arburst);
        case (error_code)
          1: $fatal(1,"AXI_STATIC_ARBURST");
          2: $fatal(1,"AXI_STATIC_ARLEN");
          3: $fatal(1,"AXI_STATIC_ARSIZE");
          4: $fatal(1,"AXI_STATIC_ARALIGN");
          5: $fatal(1,"AXI_STATIC_AROVERFLOW");
          6: $fatal(1,"AXI_STATIC_4K_CROSS");
          7: $fatal(1,"AXI_STATIC_ARUNMAPPED");
        endcase
        ar_address[ar_tail] <= araddr;
        ar_length[ar_tail] <= arlen;
        ar_size[ar_tail] <= arsize;
        ar_id[ar_tail] <= arid;
        ar_tail <= ar_tail + 1'b1;
      end

      if (write_commit) begin
        if (w_id[w_head] !== aw_id[aw_head])
          $fatal(1,"AXI_STATIC_WID");
        if (w_last[w_head] !== (write_beat == aw_length[aw_head]))
          $fatal(1,"AXI_STATIC_WLAST");
        beat_address = {1'b0,aw_address[aw_head]} +
                       ({60'd0,write_beat} << aw_size[aw_head]);
        transfer_end = beat_address + (65'd1 << aw_size[aw_head]) - 65'd1;
        word_base = beat_address - (beat_address % DATA_BYTES);
        for (int lane = 0; lane < DATA_BYTES; ++lane) begin
          if (w_strobe[w_head][lane]) begin
            lane_address = word_base + lane;
            if (lane_address < beat_address || lane_address > transfer_end)
              $fatal(1,"AXI_STATIC_WSTRB");
            slot = page_slot(lane_address[63:0]);
            if (lane_address[64] || slot < 0)
              $fatal(1,"AXI_STATIC_WUNMAPPED");
            mem[slot*PAGE_BYTES + lane_address[11:0]] <=
                w_data[w_head][lane*8 +: 8];
          end
        end
        w_head <= w_head + 1'b1;
        if (aw_pop) begin
          b_id[b_tail] <= aw_id[aw_head];
          b_tail <= b_tail + 1'b1;
          aw_head <= aw_head + 1'b1;
          write_beat <= 0;
        end else write_beat <= write_beat + 1'b1;
      end
      if (b_pop) b_head <= b_head + 1'b1;

      if (read_take) begin
        rvalid <= 0;
        if (rlast) begin
          ar_head <= ar_head + 1'b1;
          read_beat <= 0;
        end else read_beat <= read_beat + 1'b1;
      end else if (!rvalid && ar_count != 0) begin
        beat_address = {1'b0,ar_address[ar_head]} +
                       ({60'd0,read_beat} << ar_size[ar_head]);
        transfer_end = beat_address + (65'd1 << ar_size[ar_head]) - 65'd1;
        word_base = beat_address - (beat_address % DATA_BYTES);
        next_read_data = '0;
        for (int lane = 0; lane < DATA_BYTES; ++lane) begin
          lane_address = word_base + lane;
          if (lane_address >= beat_address && lane_address <= transfer_end) begin
            slot = page_slot(lane_address[63:0]);
            if (lane_address[64] || slot < 0)
              $fatal(1,"AXI_STATIC_RUNMAPPED");
            if ($isunknown(mem[slot*PAGE_BYTES + lane_address[11:0]]))
              $fatal(1,"AXI_STATIC_UNKNOWN_READ");
            next_read_data[lane*8 +: 8] =
                mem[slot*PAGE_BYTES + lane_address[11:0]];
          end
        end
        rdata <= next_read_data;
        rid <= ar_id[ar_head];
        rresp <= 2'b00;
        rlast <= (read_beat == ar_length[ar_head]);
        rvalid <= 1;
      end

      // Each count has exactly one owner, including simultaneous push/pop.
      aw_count <= aw_count + aw_push - aw_pop;
      w_count  <= w_count + w_push - w_pop;
      b_count  <= b_count + b_push - b_pop;
      ar_count <= ar_count + ar_push - ar_pop;
      if (aw_count > AW_DEPTH || w_count > W_DEPTH ||
          b_count > B_DEPTH || ar_count > AR_DEPTH)
        $fatal(1,"AXI_STATIC_FIFO_COUNT");
    end
  end
endmodule
