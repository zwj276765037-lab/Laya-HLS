package laya_controller_transaction_layout_v1;
  localparam int TX_REQUEST_BYTES = 1536;
  localparam int TX_REQUEST_BEATS = 24;
  localparam int TX_COMPLETION_BYTES = 1024;
  localparam int TX_COMPLETION_BEATS = 16;
  localparam logic [31:0] TX_REQUEST_MAGIC = 32'h3158544c;    // LTX1
  localparam logic [31:0] TX_COMPLETION_MAGIC = 32'h3143544c; // LTC1
  localparam logic [15:0] TX_VERSION = 16'd1;

  localparam logic [15:0] COMPUTE_TRANSACTION = 16'd1;
  localparam logic [15:0] PROVENANCE_TRANSACTION = 16'd2;
  localparam logic [15:0] PRODUCER_TRANSACTION = 16'd3;

  localparam int TX_MAGIC = 0;
  localparam int TX_VERSION_OFFSET = 4;
  localparam int TX_BEATS = 6;
  localparam int TX_KIND = 8;
  localparam int TX_PROTOCOL = 10;
  localparam int TX_FLAGS = 12;
  localparam int TX_SEQ = 16;
  localparam int TX_ORIGIN = 24;
  localparam int TX_REQUEST_FLAGS = 32;
  localparam int TX_REQUEST_IDENTITY = 64;
  localparam int TX_REQUEST_CONTEXT = 148;
  localparam int TX_REQUEST_MODEL = 160;
  localparam int TX_REQUEST_PAYLOAD = 576;

  localparam logic [31:0] TX_CANCEL_CLEANUP = 32'h00000001;
  localparam logic [31:0] TX_FRAME_COMPLETE = 32'h00000001;
  localparam logic [31:0] TX_BINDING_OK = 32'h00000002;
  localparam logic [31:0] TX_REMOTE_DRAINED = 32'h00000004;
  localparam logic [31:0] TX_REMOTE_SCOPE_ACTIVE = 32'h00000008;
  localparam logic [31:0] TX_REMOTE_TERMINAL = 32'h00000010;
  localparam logic [31:0] TX_REMOTE_PUBLISHED = 32'h00000020;
  localparam logic [31:0] TX_LOCAL_REJECT = 32'h00000040;

  localparam int TX_COMPLETION_STATUS = 32;
  localparam int TX_COMPLETION_UNIT = 34;
  localparam int TX_COMPLETION_DESCRIPTOR_COUNT = 35;
  localparam int TX_COMPLETION_DETAIL = 36;
  localparam int TX_COMPLETION_BAD_ELEMENT = 40;
  localparam int TX_COMPLETION_ELEMENTS = 48;
  localparam int TX_COMPLETION_METRIC0 = 56;
  localparam int TX_COMPLETION_METRIC1 = 64;
  localparam int TX_COMPLETION_IDENTITY = 72;
  localparam int TX_COMPLETION_CONTEXT = 156;
  localparam int TX_COMPLETION_PAYLOAD = 168;
endpackage
