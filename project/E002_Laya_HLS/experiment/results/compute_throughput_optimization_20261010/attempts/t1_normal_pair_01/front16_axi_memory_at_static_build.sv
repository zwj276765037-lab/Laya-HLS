`timescale 1ns/1ps

// One physical AXI endpoint. DATA_W is taken from the generated RTL port.
module front16_axi_memory #(
  parameter int DATA_W=32,
  parameter int PORT_INDEX=0  // 0 STATE0, 1 AUX, 2 STATE1, 3 OBSERVED
) (
  input logic clk, rst_n, pressure,
  input logic AWVALID, output logic AWREADY, input logic [63:0] AWADDR,
  input logic AWID, input logic [7:0] AWLEN, input logic [2:0] AWSIZE,
  input logic [1:0] AWBURST,
  input logic WVALID, output logic WREADY, input logic [DATA_W-1:0] WDATA,
  input logic [DATA_W/8-1:0] WSTRB, input logic WLAST,
  input logic ARVALID, output logic ARREADY, input logic [63:0] ARADDR,
  input logic ARID, input logic [7:0] ARLEN, input logic [2:0] ARSIZE,
  input logic [1:0] ARBURST,
  output logic RVALID, input logic RREADY, output logic [DATA_W-1:0] RDATA,
  output logic RLAST, output logic RID, output logic [1:0] RRESP,
  output logic BVALID, input logic BREADY, output logic [1:0] BRESP,
  output logic BID,
  output logic debt_zero, output logic [31:0] ar_count, r_count,
  output logic [31:0] aw_count, w_count, b_count,
  output logic [31:0] r_hold_hits, b_hold_hits,
  output logic [31:0] r_hold_cycles, b_hold_cycles
);
  import "DPI-C" function int front16_mem_read_word(input int port,
      input longint unsigned address);
  import "DPI-C" function void front16_mem_read_accept(input int port,
      input longint unsigned address, input int bytes);
  import "DPI-C" function void front16_mem_write_word(input int port,
      input longint unsigned address, input int word, input byte unsigned strobe);
  import "DPI-C" function int front16_mem_import_bytes();
  import "DPI-C" function int front16_mem_gamma_bytes();

  localparam int BUS_BYTES=DATA_W/8;
  localparam int CHUNKS=DATA_W/32;
  logic rd_active=0, wr_active=0, b_valid=0;
  logic [63:0] rd_addr=0, wr_addr=0;
  logic [8:0] rd_left=0, wr_left=0;
  logic [2:0] rd_size=0, wr_size=0;
  logic rd_id=0, wr_id=0;
  logic last_output=0, r_hold_done=0, b_hold_done=0;
  logic [2:0] r_hold_count=0, b_hold_count=0;
  logic [15:0] r_debt=0, w_debt=0;
  logic stalled_ar=0, stalled_aw=0, stalled_w=0;
  logic [77:0] ar_snapshot, aw_snapshot;
  logic [DATA_W+BUS_BYTES:0] w_snapshot;
  logic r_target, b_target;

  assign ARREADY = rst_n && !rd_active;
  assign AWREADY = rst_n && !wr_active && !b_valid;
  assign WREADY = rst_n && wr_active;
  assign r_target = pressure && PORT_INDEX==0 && rd_active &&
      rd_addr <= 65535 && rd_addr + (64'(1) << rd_size) > 65535 &&
      front16_mem_import_bytes() == 65536 &&
      front16_mem_gamma_bytes() == 4096 && !r_hold_done;
  assign b_target = pressure && PORT_INDEX==2 && b_valid &&
      last_output && !b_hold_done;
  assign RVALID = rst_n && rd_active && !r_target && r_hold_count==0;
  assign RLAST = rd_active && rd_left==1;
  assign RID = rd_id;
  assign RRESP = 0;
  assign BVALID = rst_n && b_valid && !b_target && b_hold_count==0;
  assign BID = wr_id;
  assign BRESP = 0;
  assign debt_zero = !rd_active && !wr_active && !b_valid &&
      r_debt==0 && w_debt==0 && r_hold_count==0 && b_hold_count==0;

  for (genvar c=0; c<CHUNKS; c++) begin : read_lanes
    wire [63:0] bus_base = rd_addr & ~64'(BUS_BYTES-1);
    assign RDATA[c*32 +: 32] = rd_active ?
        front16_mem_read_word(PORT_INDEX, bus_base + 64'(4*c)) : 32'b0;
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      rd_active<=0; wr_active<=0; b_valid<=0;
      rd_left<=0; wr_left<=0; r_debt<=0; w_debt<=0;
      r_hold_count<=0; b_hold_count<=0;
      r_hold_done<=0; b_hold_done<=0; last_output<=0;
      r_hold_hits<=0; b_hold_hits<=0;
      r_hold_cycles<=0; b_hold_cycles<=0;
      ar_count<=0; r_count<=0; aw_count<=0; w_count<=0; b_count<=0;
      stalled_ar<=0; stalled_aw<=0; stalled_w<=0;
    end else begin
      if (stalled_ar && (!ARVALID || {ARADDR,ARLEN,ARSIZE,ARBURST,ARID}!==ar_snapshot))
        $fatal(1,"front16 AR unstable while stalled port=%0d",PORT_INDEX);
      if (stalled_aw && (!AWVALID || {AWADDR,AWLEN,AWSIZE,AWBURST,AWID}!==aw_snapshot))
        $fatal(1,"front16 AW unstable while stalled port=%0d",PORT_INDEX);
      if (stalled_w && (!WVALID || {WDATA,WSTRB,WLAST}!==w_snapshot))
        $fatal(1,"front16 W unstable while stalled port=%0d",PORT_INDEX);
      stalled_ar <= ARVALID && !ARREADY;
      stalled_aw <= AWVALID && !AWREADY;
      stalled_w <= WVALID && !WREADY;
      if (ARVALID && !ARREADY) ar_snapshot <= {ARADDR,ARLEN,ARSIZE,ARBURST,ARID};
      if (AWVALID && !AWREADY) aw_snapshot <= {AWADDR,AWLEN,AWSIZE,AWBURST,AWID};
      if (WVALID && !WREADY) w_snapshot <= {WDATA,WSTRB,WLAST};

      if (ARVALID && ARREADY) begin
        if (PORT_INDEX>1 || ARSIZE>$clog2(BUS_BYTES) || ARLEN>63 ||
            (ARADDR & ((64'(1)<<ARSIZE)-1))!=0 ||
            ARBURST!=2'b01 ||
            {1'b0,ARADDR[11:0]}+((13'(ARLEN)+1)<<ARSIZE)>4096)
          $fatal(1,"front16 bad AR port=%0d addr=%h len=%0d size=%0d",PORT_INDEX,ARADDR,ARLEN,ARSIZE);
        if (PORT_INDEX==1 && front16_mem_import_bytes()!=65536)
          $fatal(1,"front16 gamma before complete raw import");
        if (PORT_INDEX==0 && front16_mem_import_bytes()==65536 &&
            front16_mem_gamma_bytes()!=4096)
          $fatal(1,"front16 LN read before complete gamma");
        rd_active<=1; rd_addr<=ARADDR; rd_left<={1'b0,ARLEN}+1;
        rd_size<=ARSIZE; rd_id<=ARID;
        r_debt<=r_debt+{8'b0,ARLEN}+1;
        ar_count<=ar_count+1;
      end
      if (r_target) begin
        r_hold_done<=1; r_hold_count<=4; r_hold_hits<=r_hold_hits+1;
      end else if (r_hold_count!=0) begin
        r_hold_count<=r_hold_count-1; r_hold_cycles<=r_hold_cycles+1;
      end
      if (RVALID && RREADY) begin
        if (r_debt==0) $fatal(1,"front16 R without AR debt");
        front16_mem_read_accept(PORT_INDEX, rd_addr, 1<<rd_size);
        r_debt<=r_debt-1; r_count<=r_count+1;
        if (rd_left==1) rd_active<=0;
        else begin rd_addr<=rd_addr+(64'(1)<<rd_size); rd_left<=rd_left-1; end
      end
      if (AWVALID && AWREADY) begin
        if (PORT_INDEX<2 || AWSIZE>$clog2(BUS_BYTES) || AWLEN>63 ||
            (AWADDR & ((64'(1)<<AWSIZE)-1))!=0 ||
            AWBURST!=2'b01 ||
            {1'b0,AWADDR[11:0]}+((13'(AWLEN)+1)<<AWSIZE)>4096)
          $fatal(1,"front16 bad AW port=%0d addr=%h len=%0d size=%0d",PORT_INDEX,AWADDR,AWLEN,AWSIZE);
        wr_active<=1; wr_addr<=AWADDR; wr_left<={1'b0,AWLEN}+1;
        wr_size<=AWSIZE; wr_id<=AWID;
        w_debt<=w_debt+{8'b0,AWLEN}+1;
        aw_count<=aw_count+1;
      end
      if (WVALID && WREADY) begin
        if (w_debt==0 || WLAST!==(wr_left==1))
          $fatal(1,"front16 W debt/LAST mismatch port=%0d",PORT_INDEX);
        for (int c=0; c<CHUNKS; c++)
          front16_mem_write_word(PORT_INDEX,
              (wr_addr & ~64'(BUS_BYTES-1)) + 64'(c*4),
              WDATA[c*32 +: 32], byte'(WSTRB[c*4 +: 4]));
        if (PORT_INDEX==2 && wr_addr<=65535 &&
            wr_addr+(64'(1)<<wr_size)>65535) last_output<=1;
        w_debt<=w_debt-1; w_count<=w_count+1;
        if (wr_left==1) begin wr_active<=0; b_valid<=1; end
        else begin wr_addr<=wr_addr+(64'(1)<<wr_size); wr_left<=wr_left-1; end
      end
      if (b_target) begin
        b_hold_done<=1; b_hold_count<=4; b_hold_hits<=b_hold_hits+1;
      end else if (b_hold_count!=0) begin
        b_hold_count<=b_hold_count-1; b_hold_cycles<=b_hold_cycles+1;
      end
      if (BVALID && BREADY) begin
        if (w_debt!=0) $fatal(1,"front16 B before W retired");
        b_valid<=0; last_output<=0; b_count<=b_count+1;
      end
    end
  end
endmodule
