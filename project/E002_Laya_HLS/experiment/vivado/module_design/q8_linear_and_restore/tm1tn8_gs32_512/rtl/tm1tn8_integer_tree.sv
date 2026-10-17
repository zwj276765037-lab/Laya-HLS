`timescale 1ns/1ps

// One GS32 A8 vector is broadcast to eight independent W8 columns.
// Six registered boundaries: products, then 16/8/4/2/1 adjacent sums.
// The caller reserves completion storage before asserting req_valid; this
// fixed-latency service has no output backpressure or unreserved return.
module tm1tn8_integer_tree #(
  parameter int TAG_W = 160
) (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic                 req_valid,
  output logic                 req_ready,
  input  logic [TAG_W-1:0]     req_tag,
  input  logic [255:0]         req_old_ps,
  input  logic [255:0]         req_a,
  input  logic [2047:0]        req_w,
  output logic                 ret_valid,
  output logic [TAG_W-1:0]     ret_tag,
  output logic [255:0]         ret_old_ps,
  output logic [167:0]         ret_dot21
);
  assign req_ready = rst_n;

  logic [5:0] valid_pipe;
  logic [TAG_W-1:0] tag_pipe [0:5];
  logic [255:0] ps_pipe [0:5];

  // Mapping intent only; DSP use is decided by the generated netlist/OOC.
  (* use_dsp = "yes" *) logic signed [15:0] product [0:7][0:31];
  logic signed [16:0] sum16 [0:7][0:15];
  logic signed [17:0] sum8  [0:7][0:7];
  logic signed [18:0] sum4  [0:7][0:3];
  logic signed [19:0] sum2  [0:7][0:1];
  logic signed [20:0] sum1  [0:7];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_pipe <= '0;
    end else begin
      valid_pipe <= {valid_pipe[4:0], req_valid && req_ready};
      if (req_valid && req_ready) begin
        tag_pipe[0] <= req_tag;
        ps_pipe[0] <= req_old_ps;
        for (int lane = 0; lane < 8; lane++) begin
          for (int k = 0; k < 32; k++) begin
            product[lane][k] <=
                $signed(req_a[k*8 +: 8]) *
                $signed(req_w[lane*256 + k*8 +: 8]);
          end
        end
      end
      for (int stage = 1; stage < 6; stage++) begin
        if (valid_pipe[stage-1]) begin
          tag_pipe[stage] <= tag_pipe[stage-1];
          ps_pipe[stage] <= ps_pipe[stage-1];
        end
      end
      if (valid_pipe[0]) begin
        for (int lane = 0; lane < 8; lane++)
          for (int k = 0; k < 16; k++)
            sum16[lane][k] <=
                $signed({product[lane][2*k][15], product[lane][2*k]}) +
                $signed({product[lane][2*k+1][15], product[lane][2*k+1]});
      end
      if (valid_pipe[1]) begin
        for (int lane = 0; lane < 8; lane++)
          for (int k = 0; k < 8; k++)
            sum8[lane][k] <=
                $signed({sum16[lane][2*k][16], sum16[lane][2*k]}) +
                $signed({sum16[lane][2*k+1][16], sum16[lane][2*k+1]});
      end
      if (valid_pipe[2]) begin
        for (int lane = 0; lane < 8; lane++)
          for (int k = 0; k < 4; k++)
            sum4[lane][k] <=
                $signed({sum8[lane][2*k][17], sum8[lane][2*k]}) +
                $signed({sum8[lane][2*k+1][17], sum8[lane][2*k+1]});
      end
      if (valid_pipe[3]) begin
        for (int lane = 0; lane < 8; lane++)
          for (int k = 0; k < 2; k++)
            sum2[lane][k] <=
                $signed({sum4[lane][2*k][18], sum4[lane][2*k]}) +
                $signed({sum4[lane][2*k+1][18], sum4[lane][2*k+1]});
      end
      if (valid_pipe[4]) begin
        for (int lane = 0; lane < 8; lane++)
          sum1[lane] <=
              $signed({sum2[lane][0][19], sum2[lane][0]}) +
              $signed({sum2[lane][1][19], sum2[lane][1]});
      end
    end
  end

  assign ret_valid = valid_pipe[5];
  assign ret_tag = tag_pipe[5];
  assign ret_old_ps = ps_pipe[5];
  for (genvar lane = 0; lane < 8; lane++) begin : dot_output
    assign ret_dot21[lane*21 +: 21] = sum1[lane];
  end
endmodule
