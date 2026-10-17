package laya_graph_program_layout_v1;
  localparam int PROGRAM_COMMAND_BYTES = 256;
  localparam int PROGRAM_COMMAND_BEATS = 4;
  localparam int PROGRAM_RESULT_BYTES = 256;
  localparam int PROGRAM_RESULT_BEATS = 4;
  localparam logic [31:0] PROGRAM_COMMAND_MAGIC = 32'h3150474c; // LGP1
  localparam logic [31:0] PROGRAM_RESULT_MAGIC = 32'h3152474c;  // LGR1
  localparam logic [15:0] PROGRAM_VERSION = 16'd1;

  localparam int PROGRAM_ENTRYPOINT = 8;
  localparam int PROGRAM_COMMAND_SOURCE_SLOT = 9;
  localparam int PROGRAM_FLAGS = 16;
  localparam int PROGRAM_RESULT_ACTION_ORDINAL = 24;
  localparam int PROGRAM_IDENTITY = 64;
  localparam int PROGRAM_COMMAND_SOURCE_VERSION = 160;
  localparam int PROGRAM_COMMAND_SOURCE_OWNER = 168;

  localparam logic [31:0] PROGRAM_SOURCE_READY_PROOF = 32'h00000001;
  localparam logic [31:0] PROGRAM_FRAME_COMPLETE = 32'h00000001;
  localparam logic [31:0] PROGRAM_BINDING_OK = 32'h00000002;
  localparam logic [31:0] PROGRAM_SAFE_TERMINAL = 32'h00000004;
  localparam logic [31:0] PROGRAM_REQUEST_COMPLETE = 32'h00000008;
  localparam logic [31:0] PROGRAM_SLOT_UPDATE_VALID = 32'h00000010;
  localparam logic [31:0] PROGRAM_LOCAL_REJECT = 32'h00000020;

  localparam int PROGRAM_RESULT_PC = 9;
  localparam int PROGRAM_RESULT_STATUS = 148;
  localparam int PROGRAM_RESULT_DETAIL = 152;
  localparam int PROGRAM_RESULT_BAD_ELEMENT = 156;
  localparam int PROGRAM_RESULT_SLOT = 176;
  localparam int PROGRAM_RESULT_SLOT_VERSION = 184;
  localparam int PROGRAM_RESULT_OWNER = 192;
endpackage
