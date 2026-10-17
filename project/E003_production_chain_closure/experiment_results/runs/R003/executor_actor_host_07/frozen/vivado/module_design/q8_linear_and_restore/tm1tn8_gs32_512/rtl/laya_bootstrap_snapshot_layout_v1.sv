`timescale 1ns/1ps
package laya_bootstrap_snapshot_layout_v1;
  localparam integer BYTES=768,BEATS=12;
  localparam logic [31:0] REQUEST_MAGIC=32'h3153424c,
                          RESPONSE_MAGIC=32'h3152424c;
  localparam integer VERSION=4,BEAT_COUNT=6,PURPOSE=8,STATUS=10,FLAGS=12,
                     SEQUENCE=16,DETAIL=24,BAD=32,BASE_EPOCH=40,
                     BASE_ADDRESS=48,BASE_CAPACITY=56,IDENTITY=64,
                     MODEL_IDENTITY=160,OWNER=576;
  localparam logic [31:0] SUCCESS_FLAGS=63,ERROR_FLAGS=3;
endpackage
