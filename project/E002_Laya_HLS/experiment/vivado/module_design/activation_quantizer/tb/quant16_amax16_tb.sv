`timescale 1ns/1ps

module quant16_amax16_tb;
  logic clk=0, rst=1, req_valid=0;
  logic [511:0] req_lanes=0;
  logic [101:0] req_tag=0;
  wire ret_valid;
  wire [31:0] ret_amax_bits;
  wire [3:0] ret_max_lane;
  wire [4:0] ret_first_bad_lane;
  wire [101:0] ret_tag;
  int checked=0;
  always #3.333 clk=~clk;
  quant16_amax16 dut (.*);

  task automatic check_response;
    int returned;
    begin
      if (ret_valid) begin
        returned=int'(ret_tag);
        if (returned!=checked)
          $fatal(1,"amax16 tag sequence got=%0d expected=%0d",returned,checked);
        checked++;
        if (returned==17) begin
          if (ret_first_bad_lane!==5'd5)
            $fatal(1,"amax16 earliest nonfinite lane");
        end else begin
          if (ret_first_bad_lane!==5'd16)
            $fatal(1,"amax16 spurious nonfinite lane");
          if (returned[0]) begin
            if (ret_amax_bits!==32'd0 || ret_max_lane!==4'd0)
              $fatal(1,"amax16 signed zero tie");
          end else if (ret_amax_bits!==32'h40600000 || ret_max_lane!==4'd2)
            $fatal(1,"amax16 magnitude tie");
        end
      end
    end
  endtask

  initial begin
    repeat (2) @(negedge clk);
    rst=0;
    for (int case_id=0;case_id<64;case_id++) begin
      @(negedge clk);
      req_valid=1; req_tag=102'(case_id);
      for (int lane=0;lane<16;lane++) req_lanes[lane*32 +: 32]=32'h00000000;
      if (case_id[0]) begin
        req_lanes[0 +: 32]=32'h80000000; // -0 ties +0, earliest lane 0.
        req_lanes[32 +: 32]=32'h00000000;
      end else begin
        req_lanes[2*32 +: 32]=32'hc0600000; // -3.5.
        req_lanes[9*32 +: 32]=32'h40600000; // +3.5, later tie.
      end
      if (case_id==17) req_lanes[5*32 +: 32]=32'h7f800000;
      @(posedge clk);
      check_response();
    end
    @(negedge clk); req_valid=0;
    repeat (8) begin @(posedge clk); check_response(); end
    if (checked!=64) $fatal(1,"amax16 return count=%0d",checked);
    $display("QUANT16_AMAX16_PASS requests=64 II=1");
    $finish;
  end
endmodule
