package laya_graph_action_layout_v1;
  localparam int ACTION_REQUEST_BYTES = 512;
  localparam int ACTION_REQUEST_BEATS = 8;
  localparam int ACTION_COMPLETION_BYTES = 256;
  localparam int ACTION_COMPLETION_BEATS = 4;
  localparam logic [31:0] ACTION_REQUEST_MAGIC = 32'h3158414c;    // LAX1
  localparam logic [31:0] ACTION_COMPLETION_MAGIC = 32'h3143414c; // LAC1
  localparam logic [15:0] ACTION_VERSION = 16'd1;

  localparam int ACTION_KIND = 8;
  localparam int ACTION_PC = 9;
  localparam int ACTION_OP = 10;
  localparam int ACTION_STAGE = 11;
  localparam int ACTION_LAYER = 12;
  localparam int ACTION_FLAGS = 16;
  localparam int ACTION_ORDINAL = 24;
  localparam int ACTION_IDENTITY = 64;
  localparam int ACTION_SOURCE = 160;
  localparam int ACTION_TARGET = 224;
  localparam int ACTION_PARAMETERS = 256;

  localparam logic [31:0] ACTION_FRAME_COMPLETE = 32'h00000001;
  localparam logic [31:0] ACTION_BINDING_OK = 32'h00000002;
  localparam logic [31:0] ACTION_SAFE_TERMINAL = 32'h00000004;
  localparam logic [31:0] ACTION_REMOTE_DRAINED = 32'h00000008;
  localparam logic [31:0] ACTION_SLOT_UPDATE_VALID = 32'h00000010;
  localparam logic [31:0] ACTION_TYPED_RETIRED = 32'h00000020;
  localparam logic [31:0] ACTION_LOCAL_REJECT = 32'h00000040;

  localparam int ACTION_COMPLETION_STATUS = 148;
  localparam int ACTION_COMPLETION_DETAIL = 152;
  localparam int ACTION_COMPLETION_BAD_ELEMENT = 156;
  localparam int ACTION_COMPLETION_FIRST_TASK = 164;
  localparam int ACTION_COMPLETION_LAST_TASK = 168;
  localparam int ACTION_COMPLETION_RETIRED_TASKS = 172;
  localparam int ACTION_COMPLETION_SLOT = 176;
  localparam int ACTION_COMPLETION_SLOT_VERSION = 184;
  localparam int ACTION_COMPLETION_OWNER = 192;
endpackage
