`timescale 1ns/1ps

module tm4tn8_tag_v1_tb;
  logic [159:0] identity;
  logic [6:0] group;
  logic [9:0] tile;
  logic [1:0] row;
  logic [5:0] result_slot;
  logic [1:0] trace_slot;
  logic trace_enable;
  logic [2:0] trace_lane;
  logic [7:0] lane_mask;
  logic [191:0] tag;
  int checked = 0;

  tm4tn8_tag_v1 dut (.*);

  initial begin
    identity = {32'hfee1_8917, 32'hc129_a50f, 32'h7134_8001,
                32'hffff_ffff, 32'hbad1_9821};
    for (int gi = 0; gi < 4; gi++) begin
      case (gi)
        0: group = 63;
        1: group = 64;
        2: group = 81;
        3: group = 127;
      endcase
      for (int ti = 0; ti < 4; ti++) begin
        case (ti)
          0: tile = 511;
          1: tile = 512;
          2: tile = 655;
          3: tile = 1023;
        endcase
        for (int ri = 0; ri < 4; ri++) begin
          row = ri;
          result_slot = (gi*17 + ti*9 + ri) % 35;
          trace_slot = (gi + ri) % 4;
          trace_enable = (ti + ri) % 2;
          trace_lane = ri + 3;
          lane_mask = 8'hff ^ (8'(1) << ri);
          #1;
          if ({tag[160], tag[16:11]} !== group ||
              {tag[161], tag[25:17]} !== tile ||
              tag[27:26] !== row ||
              {tag[63], tag[4:0]} !== result_slot ||
              tag[6:5] !== trace_slot || tag[7] !== trace_enable ||
              tag[10:8] !== trace_lane || tag[35:28] !== lane_mask ||
              tag[62:36] !== identity[62:36] ||
              tag[159:64] !== identity[159:64] ||
              tag[167:164] !== 4'd1 || tag[163:162] !== 0 ||
              tag[191:168] !== 0)
            $fatal(1, "TM4 tag mismatch g=%0d t=%0d row=%0d", group, tile, row);
          checked++;
        end
      end
    end
    if (checked != 64) $fatal(1, "TM4 tag count");
    $display("TM4TN8_TAG_V1_PASS cases=%0d", checked);
    $finish;
  end
endmodule
