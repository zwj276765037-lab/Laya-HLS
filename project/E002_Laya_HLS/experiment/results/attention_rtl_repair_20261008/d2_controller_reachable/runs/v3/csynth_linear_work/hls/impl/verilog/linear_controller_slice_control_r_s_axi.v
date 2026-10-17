// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *) module linear_controller_slice_control_r_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 8,
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire [63:0]                   norm_input_r,
    output wire [63:0]                   io_r,
    output wire [63:0]                   w_q0_r,
    output wire [63:0]                   w_q1_r,
    output wire [63:0]                   w_scale_r,
    output wire [63:0]                   aux_r,
    output wire [63:0]                   state0_r,
    output wire [63:0]                   qkv0_r,
    output wire [63:0]                   qkv1_r,
    output wire [63:0]                   observed_r
);
//------------------------Address Info-------------------
// Protocol Used: ap_ctrl_none
//
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of norm_input_r
//        bit 31~0 - norm_input_r[31:0] (Read/Write)
// 0x14 : Data signal of norm_input_r
//        bit 31~0 - norm_input_r[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of io_r
//        bit 31~0 - io_r[31:0] (Read/Write)
// 0x20 : Data signal of io_r
//        bit 31~0 - io_r[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of w_q0_r
//        bit 31~0 - w_q0_r[31:0] (Read/Write)
// 0x2c : Data signal of w_q0_r
//        bit 31~0 - w_q0_r[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of w_q1_r
//        bit 31~0 - w_q1_r[31:0] (Read/Write)
// 0x38 : Data signal of w_q1_r
//        bit 31~0 - w_q1_r[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of w_scale_r
//        bit 31~0 - w_scale_r[31:0] (Read/Write)
// 0x44 : Data signal of w_scale_r
//        bit 31~0 - w_scale_r[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of aux_r
//        bit 31~0 - aux_r[31:0] (Read/Write)
// 0x50 : Data signal of aux_r
//        bit 31~0 - aux_r[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of state0_r
//        bit 31~0 - state0_r[31:0] (Read/Write)
// 0x5c : Data signal of state0_r
//        bit 31~0 - state0_r[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[31:0] (Read/Write)
// 0x68 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[31:0] (Read/Write)
// 0x74 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[63:32] (Read/Write)
// 0x78 : reserved
// 0x7c : Data signal of observed_r
//        bit 31~0 - observed_r[31:0] (Read/Write)
// 0x80 : Data signal of observed_r
//        bit 31~0 - observed_r[63:32] (Read/Write)
// 0x84 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_NORM_INPUT_R_DATA_0 = 8'h10,
    ADDR_NORM_INPUT_R_DATA_1 = 8'h14,
    ADDR_NORM_INPUT_R_CTRL   = 8'h18,
    ADDR_IO_R_DATA_0         = 8'h1c,
    ADDR_IO_R_DATA_1         = 8'h20,
    ADDR_IO_R_CTRL           = 8'h24,
    ADDR_W_Q0_R_DATA_0       = 8'h28,
    ADDR_W_Q0_R_DATA_1       = 8'h2c,
    ADDR_W_Q0_R_CTRL         = 8'h30,
    ADDR_W_Q1_R_DATA_0       = 8'h34,
    ADDR_W_Q1_R_DATA_1       = 8'h38,
    ADDR_W_Q1_R_CTRL         = 8'h3c,
    ADDR_W_SCALE_R_DATA_0    = 8'h40,
    ADDR_W_SCALE_R_DATA_1    = 8'h44,
    ADDR_W_SCALE_R_CTRL      = 8'h48,
    ADDR_AUX_R_DATA_0        = 8'h4c,
    ADDR_AUX_R_DATA_1        = 8'h50,
    ADDR_AUX_R_CTRL          = 8'h54,
    ADDR_STATE0_R_DATA_0     = 8'h58,
    ADDR_STATE0_R_DATA_1     = 8'h5c,
    ADDR_STATE0_R_CTRL       = 8'h60,
    ADDR_QKV0_R_DATA_0       = 8'h64,
    ADDR_QKV0_R_DATA_1       = 8'h68,
    ADDR_QKV0_R_CTRL         = 8'h6c,
    ADDR_QKV1_R_DATA_0       = 8'h70,
    ADDR_QKV1_R_DATA_1       = 8'h74,
    ADDR_QKV1_R_CTRL         = 8'h78,
    ADDR_OBSERVED_R_DATA_0   = 8'h7c,
    ADDR_OBSERVED_R_DATA_1   = 8'h80,
    ADDR_OBSERVED_R_CTRL     = 8'h84,
    WRIDLE                   = 2'd0,
    WRDATA                   = 2'd1,
    WRRESP                   = 2'd2,
    WRRESET                  = 2'd3,
    RDIDLE                   = 2'd0,
    RDDATA                   = 2'd1,
    RDRESET                  = 2'd2,
    ADDR_BITS                = 8;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg  [63:0]                   int_norm_input_r = 'b0;
    reg  [63:0]                   int_io_r = 'b0;
    reg  [63:0]                   int_w_q0_r = 'b0;
    reg  [63:0]                   int_w_q1_r = 'b0;
    reg  [63:0]                   int_w_scale_r = 'b0;
    reg  [63:0]                   int_aux_r = 'b0;
    reg  [63:0]                   int_state0_r = 'b0;
    reg  [63:0]                   int_qkv0_r = 'b0;
    reg  [63:0]                   int_qkv1_r = 'b0;
    reg  [63:0]                   int_observed_r = 'b0;

//------------------------Instantiation------------------


//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BVALID  = (wstate == WRRESP);
assign BRESP   = 2'b00;  // OKAY
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY & BVALID)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= {AWADDR[ADDR_BITS-1:2], {2{1'b0}}};
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 'b0;
            case (raddr)
                ADDR_NORM_INPUT_R_DATA_0: begin
                    rdata <= int_norm_input_r[31:0];
                end
                ADDR_NORM_INPUT_R_DATA_1: begin
                    rdata <= int_norm_input_r[63:32];
                end
                ADDR_IO_R_DATA_0: begin
                    rdata <= int_io_r[31:0];
                end
                ADDR_IO_R_DATA_1: begin
                    rdata <= int_io_r[63:32];
                end
                ADDR_W_Q0_R_DATA_0: begin
                    rdata <= int_w_q0_r[31:0];
                end
                ADDR_W_Q0_R_DATA_1: begin
                    rdata <= int_w_q0_r[63:32];
                end
                ADDR_W_Q1_R_DATA_0: begin
                    rdata <= int_w_q1_r[31:0];
                end
                ADDR_W_Q1_R_DATA_1: begin
                    rdata <= int_w_q1_r[63:32];
                end
                ADDR_W_SCALE_R_DATA_0: begin
                    rdata <= int_w_scale_r[31:0];
                end
                ADDR_W_SCALE_R_DATA_1: begin
                    rdata <= int_w_scale_r[63:32];
                end
                ADDR_AUX_R_DATA_0: begin
                    rdata <= int_aux_r[31:0];
                end
                ADDR_AUX_R_DATA_1: begin
                    rdata <= int_aux_r[63:32];
                end
                ADDR_STATE0_R_DATA_0: begin
                    rdata <= int_state0_r[31:0];
                end
                ADDR_STATE0_R_DATA_1: begin
                    rdata <= int_state0_r[63:32];
                end
                ADDR_QKV0_R_DATA_0: begin
                    rdata <= int_qkv0_r[31:0];
                end
                ADDR_QKV0_R_DATA_1: begin
                    rdata <= int_qkv0_r[63:32];
                end
                ADDR_QKV1_R_DATA_0: begin
                    rdata <= int_qkv1_r[31:0];
                end
                ADDR_QKV1_R_DATA_1: begin
                    rdata <= int_qkv1_r[63:32];
                end
                ADDR_OBSERVED_R_DATA_0: begin
                    rdata <= int_observed_r[31:0];
                end
                ADDR_OBSERVED_R_DATA_1: begin
                    rdata <= int_observed_r[63:32];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign norm_input_r = int_norm_input_r;
assign io_r         = int_io_r;
assign w_q0_r       = int_w_q0_r;
assign w_q1_r       = int_w_q1_r;
assign w_scale_r    = int_w_scale_r;
assign aux_r        = int_aux_r;
assign state0_r     = int_state0_r;
assign qkv0_r       = int_qkv0_r;
assign qkv1_r       = int_qkv1_r;
assign observed_r   = int_observed_r;
// int_norm_input_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_norm_input_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_NORM_INPUT_R_DATA_0)
            int_norm_input_r[31:0] <= (WDATA[31:0] & wmask) | (int_norm_input_r[31:0] & ~wmask);
    end
end

// int_norm_input_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_norm_input_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_NORM_INPUT_R_DATA_1)
            int_norm_input_r[63:32] <= (WDATA[31:0] & wmask) | (int_norm_input_r[63:32] & ~wmask);
    end
end

// int_io_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_io_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IO_R_DATA_0)
            int_io_r[31:0] <= (WDATA[31:0] & wmask) | (int_io_r[31:0] & ~wmask);
    end
end

// int_io_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_io_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IO_R_DATA_1)
            int_io_r[63:32] <= (WDATA[31:0] & wmask) | (int_io_r[63:32] & ~wmask);
    end
end

// int_w_q0_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q0_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q0_R_DATA_0)
            int_w_q0_r[31:0] <= (WDATA[31:0] & wmask) | (int_w_q0_r[31:0] & ~wmask);
    end
end

// int_w_q0_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q0_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q0_R_DATA_1)
            int_w_q0_r[63:32] <= (WDATA[31:0] & wmask) | (int_w_q0_r[63:32] & ~wmask);
    end
end

// int_w_q1_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q1_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q1_R_DATA_0)
            int_w_q1_r[31:0] <= (WDATA[31:0] & wmask) | (int_w_q1_r[31:0] & ~wmask);
    end
end

// int_w_q1_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q1_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q1_R_DATA_1)
            int_w_q1_r[63:32] <= (WDATA[31:0] & wmask) | (int_w_q1_r[63:32] & ~wmask);
    end
end

// int_w_scale_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_scale_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_SCALE_R_DATA_0)
            int_w_scale_r[31:0] <= (WDATA[31:0] & wmask) | (int_w_scale_r[31:0] & ~wmask);
    end
end

// int_w_scale_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_scale_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_SCALE_R_DATA_1)
            int_w_scale_r[63:32] <= (WDATA[31:0] & wmask) | (int_w_scale_r[63:32] & ~wmask);
    end
end

// int_aux_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_aux_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AUX_R_DATA_0)
            int_aux_r[31:0] <= (WDATA[31:0] & wmask) | (int_aux_r[31:0] & ~wmask);
    end
end

// int_aux_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_aux_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AUX_R_DATA_1)
            int_aux_r[63:32] <= (WDATA[31:0] & wmask) | (int_aux_r[63:32] & ~wmask);
    end
end

// int_state0_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_state0_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_STATE0_R_DATA_0)
            int_state0_r[31:0] <= (WDATA[31:0] & wmask) | (int_state0_r[31:0] & ~wmask);
    end
end

// int_state0_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_state0_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_STATE0_R_DATA_1)
            int_state0_r[63:32] <= (WDATA[31:0] & wmask) | (int_state0_r[63:32] & ~wmask);
    end
end

// int_qkv0_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_qkv0_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_QKV0_R_DATA_0)
            int_qkv0_r[31:0] <= (WDATA[31:0] & wmask) | (int_qkv0_r[31:0] & ~wmask);
    end
end

// int_qkv0_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_qkv0_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_QKV0_R_DATA_1)
            int_qkv0_r[63:32] <= (WDATA[31:0] & wmask) | (int_qkv0_r[63:32] & ~wmask);
    end
end

// int_qkv1_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_qkv1_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_QKV1_R_DATA_0)
            int_qkv1_r[31:0] <= (WDATA[31:0] & wmask) | (int_qkv1_r[31:0] & ~wmask);
    end
end

// int_qkv1_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_qkv1_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_QKV1_R_DATA_1)
            int_qkv1_r[63:32] <= (WDATA[31:0] & wmask) | (int_qkv1_r[63:32] & ~wmask);
    end
end

// int_observed_r[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_observed_r[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OBSERVED_R_DATA_0)
            int_observed_r[31:0] <= (WDATA[31:0] & wmask) | (int_observed_r[31:0] & ~wmask);
    end
end

// int_observed_r[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_observed_r[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OBSERVED_R_DATA_1)
            int_observed_r[63:32] <= (WDATA[31:0] & wmask) | (int_observed_r[63:32] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule
