`ifndef LAYA_EXECUTOR_HANDOFF_LAYOUT_V1_SV
`define LAYA_EXECUTOR_HANDOFF_LAYOUT_V1_SV
package laya_executor_handoff_layout_v1;
  localparam integer CONTROL_BYTES=1024,CONTROL_BEATS=16;
  localparam logic [31:0] CONTROL_MAGIC=32'h3143484c;
  localparam logic [15:0] CONTROL_VERSION=1;
  localparam integer KIND_OFFSET=8,STATUS_OFFSET=10,SEQUENCE_OFFSET=16;
  localparam integer HANDOFF_OFFSET=680,SESSION_OFFSET=776;
  localparam integer ACCEPTED_REQUEST_OFFSET=784,COMMITTED_OFFSET=792;
  localparam logic [7:0] HOLD=1,HELD=2,IMPORT_OK=3,GRANTED=4;
  localparam logic [7:0] ABORT=5,ABORT_CLOSED=6,REJECT=7;
endpackage
`endif
