// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *) module q8_joint_tm4tn8_control_r_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 7,
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
    output wire [63:0]                   descriptor,
    output wire [63:0]                   w_q0,
    output wire [63:0]                   w_q1,
    output wire [63:0]                   w_scale,
    output wire [63:0]                   aux,
    output wire [63:0]                   activation,
    output wire [63:0]                   out0,
    output wire [63:0]                   out1,
    output wire [63:0]                   observed
);
//------------------------Address Info-------------------
// Protocol Used: ap_ctrl_none
//
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of descriptor
//        bit 31~0 - descriptor[31:0] (Read/Write)
// 0x14 : Data signal of descriptor
//        bit 31~0 - descriptor[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of w_q0
//        bit 31~0 - w_q0[31:0] (Read/Write)
// 0x20 : Data signal of w_q0
//        bit 31~0 - w_q0[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of w_q1
//        bit 31~0 - w_q1[31:0] (Read/Write)
// 0x2c : Data signal of w_q1
//        bit 31~0 - w_q1[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of w_scale
//        bit 31~0 - w_scale[31:0] (Read/Write)
// 0x38 : Data signal of w_scale
//        bit 31~0 - w_scale[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of aux
//        bit 31~0 - aux[31:0] (Read/Write)
// 0x44 : Data signal of aux
//        bit 31~0 - aux[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of activation
//        bit 31~0 - activation[31:0] (Read/Write)
// 0x50 : Data signal of activation
//        bit 31~0 - activation[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of out0
//        bit 31~0 - out0[31:0] (Read/Write)
// 0x5c : Data signal of out0
//        bit 31~0 - out0[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of out1
//        bit 31~0 - out1[31:0] (Read/Write)
// 0x68 : Data signal of out1
//        bit 31~0 - out1[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of observed
//        bit 31~0 - observed[31:0] (Read/Write)
// 0x74 : Data signal of observed
//        bit 31~0 - observed[63:32] (Read/Write)
// 0x78 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_DESCRIPTOR_DATA_0 = 7'h10,
    ADDR_DESCRIPTOR_DATA_1 = 7'h14,
    ADDR_DESCRIPTOR_CTRL   = 7'h18,
    ADDR_W_Q0_DATA_0       = 7'h1c,
    ADDR_W_Q0_DATA_1       = 7'h20,
    ADDR_W_Q0_CTRL         = 7'h24,
    ADDR_W_Q1_DATA_0       = 7'h28,
    ADDR_W_Q1_DATA_1       = 7'h2c,
    ADDR_W_Q1_CTRL         = 7'h30,
    ADDR_W_SCALE_DATA_0    = 7'h34,
    ADDR_W_SCALE_DATA_1    = 7'h38,
    ADDR_W_SCALE_CTRL      = 7'h3c,
    ADDR_AUX_DATA_0        = 7'h40,
    ADDR_AUX_DATA_1        = 7'h44,
    ADDR_AUX_CTRL          = 7'h48,
    ADDR_ACTIVATION_DATA_0 = 7'h4c,
    ADDR_ACTIVATION_DATA_1 = 7'h50,
    ADDR_ACTIVATION_CTRL   = 7'h54,
    ADDR_OUT0_DATA_0       = 7'h58,
    ADDR_OUT0_DATA_1       = 7'h5c,
    ADDR_OUT0_CTRL         = 7'h60,
    ADDR_OUT1_DATA_0       = 7'h64,
    ADDR_OUT1_DATA_1       = 7'h68,
    ADDR_OUT1_CTRL         = 7'h6c,
    ADDR_OBSERVED_DATA_0   = 7'h70,
    ADDR_OBSERVED_DATA_1   = 7'h74,
    ADDR_OBSERVED_CTRL     = 7'h78,
    WRIDLE                 = 2'd0,
    WRDATA                 = 2'd1,
    WRRESP                 = 2'd2,
    WRRESET                = 2'd3,
    RDIDLE                 = 2'd0,
    RDDATA                 = 2'd1,
    RDRESET                = 2'd2,
    ADDR_BITS                = 7;

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
    reg  [63:0]                   int_descriptor = 'b0;
    reg  [63:0]                   int_w_q0 = 'b0;
    reg  [63:0]                   int_w_q1 = 'b0;
    reg  [63:0]                   int_w_scale = 'b0;
    reg  [63:0]                   int_aux = 'b0;
    reg  [63:0]                   int_activation = 'b0;
    reg  [63:0]                   int_out0 = 'b0;
    reg  [63:0]                   int_out1 = 'b0;
    reg  [63:0]                   int_observed = 'b0;

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
                ADDR_DESCRIPTOR_DATA_0: begin
                    rdata <= int_descriptor[31:0];
                end
                ADDR_DESCRIPTOR_DATA_1: begin
                    rdata <= int_descriptor[63:32];
                end
                ADDR_W_Q0_DATA_0: begin
                    rdata <= int_w_q0[31:0];
                end
                ADDR_W_Q0_DATA_1: begin
                    rdata <= int_w_q0[63:32];
                end
                ADDR_W_Q1_DATA_0: begin
                    rdata <= int_w_q1[31:0];
                end
                ADDR_W_Q1_DATA_1: begin
                    rdata <= int_w_q1[63:32];
                end
                ADDR_W_SCALE_DATA_0: begin
                    rdata <= int_w_scale[31:0];
                end
                ADDR_W_SCALE_DATA_1: begin
                    rdata <= int_w_scale[63:32];
                end
                ADDR_AUX_DATA_0: begin
                    rdata <= int_aux[31:0];
                end
                ADDR_AUX_DATA_1: begin
                    rdata <= int_aux[63:32];
                end
                ADDR_ACTIVATION_DATA_0: begin
                    rdata <= int_activation[31:0];
                end
                ADDR_ACTIVATION_DATA_1: begin
                    rdata <= int_activation[63:32];
                end
                ADDR_OUT0_DATA_0: begin
                    rdata <= int_out0[31:0];
                end
                ADDR_OUT0_DATA_1: begin
                    rdata <= int_out0[63:32];
                end
                ADDR_OUT1_DATA_0: begin
                    rdata <= int_out1[31:0];
                end
                ADDR_OUT1_DATA_1: begin
                    rdata <= int_out1[63:32];
                end
                ADDR_OBSERVED_DATA_0: begin
                    rdata <= int_observed[31:0];
                end
                ADDR_OBSERVED_DATA_1: begin
                    rdata <= int_observed[63:32];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign descriptor = int_descriptor;
assign w_q0       = int_w_q0;
assign w_q1       = int_w_q1;
assign w_scale    = int_w_scale;
assign aux        = int_aux;
assign activation = int_activation;
assign out0       = int_out0;
assign out1       = int_out1;
assign observed   = int_observed;
// int_descriptor[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_descriptor[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_DESCRIPTOR_DATA_0)
            int_descriptor[31:0] <= (WDATA[31:0] & wmask) | (int_descriptor[31:0] & ~wmask);
    end
end

// int_descriptor[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_descriptor[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_DESCRIPTOR_DATA_1)
            int_descriptor[63:32] <= (WDATA[31:0] & wmask) | (int_descriptor[63:32] & ~wmask);
    end
end

// int_w_q0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q0_DATA_0)
            int_w_q0[31:0] <= (WDATA[31:0] & wmask) | (int_w_q0[31:0] & ~wmask);
    end
end

// int_w_q0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q0_DATA_1)
            int_w_q0[63:32] <= (WDATA[31:0] & wmask) | (int_w_q0[63:32] & ~wmask);
    end
end

// int_w_q1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q1_DATA_0)
            int_w_q1[31:0] <= (WDATA[31:0] & wmask) | (int_w_q1[31:0] & ~wmask);
    end
end

// int_w_q1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_q1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_Q1_DATA_1)
            int_w_q1[63:32] <= (WDATA[31:0] & wmask) | (int_w_q1[63:32] & ~wmask);
    end
end

// int_w_scale[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_scale[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_SCALE_DATA_0)
            int_w_scale[31:0] <= (WDATA[31:0] & wmask) | (int_w_scale[31:0] & ~wmask);
    end
end

// int_w_scale[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_w_scale[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_W_SCALE_DATA_1)
            int_w_scale[63:32] <= (WDATA[31:0] & wmask) | (int_w_scale[63:32] & ~wmask);
    end
end

// int_aux[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_aux[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AUX_DATA_0)
            int_aux[31:0] <= (WDATA[31:0] & wmask) | (int_aux[31:0] & ~wmask);
    end
end

// int_aux[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_aux[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AUX_DATA_1)
            int_aux[63:32] <= (WDATA[31:0] & wmask) | (int_aux[63:32] & ~wmask);
    end
end

// int_activation[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_activation[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_ACTIVATION_DATA_0)
            int_activation[31:0] <= (WDATA[31:0] & wmask) | (int_activation[31:0] & ~wmask);
    end
end

// int_activation[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_activation[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_ACTIVATION_DATA_1)
            int_activation[63:32] <= (WDATA[31:0] & wmask) | (int_activation[63:32] & ~wmask);
    end
end

// int_out0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_out0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OUT0_DATA_0)
            int_out0[31:0] <= (WDATA[31:0] & wmask) | (int_out0[31:0] & ~wmask);
    end
end

// int_out0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_out0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OUT0_DATA_1)
            int_out0[63:32] <= (WDATA[31:0] & wmask) | (int_out0[63:32] & ~wmask);
    end
end

// int_out1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_out1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OUT1_DATA_0)
            int_out1[31:0] <= (WDATA[31:0] & wmask) | (int_out1[31:0] & ~wmask);
    end
end

// int_out1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_out1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OUT1_DATA_1)
            int_out1[63:32] <= (WDATA[31:0] & wmask) | (int_out1[63:32] & ~wmask);
    end
end

// int_observed[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_observed[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OBSERVED_DATA_0)
            int_observed[31:0] <= (WDATA[31:0] & wmask) | (int_observed[31:0] & ~wmask);
    end
end

// int_observed[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_observed[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OBSERVED_DATA_1)
            int_observed[63:32] <= (WDATA[31:0] & wmask) | (int_observed[63:32] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule
