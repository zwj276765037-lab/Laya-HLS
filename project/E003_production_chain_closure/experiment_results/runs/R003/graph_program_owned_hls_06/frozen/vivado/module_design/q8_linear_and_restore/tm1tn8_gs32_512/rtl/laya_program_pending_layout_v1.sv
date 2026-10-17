package laya_program_pending_layout_v1;
  localparam int BYTES=1024, BEATS=16, VERSION=1;
  localparam logic [31:0] MAGIC=32'h3150414c;
  localparam int SESSION_OFFSET=16, REQUEST_OFFSET=24, SEQUENCE_OFFSET=32,
      HANDOFF_OFFSET=40, COMMAND_OFFSET=256, ACTION_OFFSET=512;
endpackage
