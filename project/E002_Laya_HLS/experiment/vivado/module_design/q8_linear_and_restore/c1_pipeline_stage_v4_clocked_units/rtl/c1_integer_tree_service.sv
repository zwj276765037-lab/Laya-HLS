`timescale 1ns/1ps
// Six real register boundaries: signed products, then 16/8/4/2/1 sums.
// req_a_rows is a[row][k], req_w_columns is w[column][k], each byte LSB first.
// The 118-bit tag is the complete c1_stage::Tag, including its valid bit;
// req_old_ps carries all 32 raw words of c1_stage::DotContext.
module c1_integer_tree_service (
  input  logic clk, rst_n,
  input  logic req_valid,
  output logic req_ready,
  input  logic [117:0] req_tag,
  input  logic [1023:0] req_old_ps,
  input  logic [1023:0] req_a_rows,
  input  logic [2047:0] req_w_columns,
  output logic ret_valid,
  output logic [117:0] ret_tag,
  output logic [1023:0] ret_old_ps,
  output logic [671:0] ret_dot21
);
  // This all-register unit accepts one request on every non-reset edge.
  // Physical timing, DSP mapping, and system-level issue readiness are pending.
  assign req_ready = rst_n;
  logic [5:0] stage_valid;
  logic [117:0] stage_tag [0:5];
  logic [1023:0] stage_old_ps [0:5];

  // Synthesis intent only: actual 1024-DSP mapping needs a netlist review.
  (* use_dsp = "yes" *) logic signed [15:0] product [0:31][0:31];
  logic signed [16:0] tree1 [0:31][0:15];
  logic signed [17:0] tree2 [0:31][0:7];
  logic signed [18:0] tree3 [0:31][0:3];
  logic signed [19:0] tree4 [0:31][0:1];
  logic signed [20:0] tree5 [0:31];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      stage_valid <= 6'b0;
    end else begin
      stage_valid <= {stage_valid[4:0], (req_valid && req_ready)};
      if (req_valid && req_ready) begin
        stage_tag[0] <= req_tag;
        stage_old_ps[0] <= req_old_ps;
        for (int lane=0; lane<32; lane++) begin
          for (int k=0; k<32; k++) begin
            product[lane][k] <=
                $signed(req_a_rows[(lane/8)*256 + k*8 +: 8]) *
                $signed(req_w_columns[(lane%8)*256 + k*8 +: 8]);
          end
        end
      end
      for (int stage=1; stage<6; stage++) begin
        if (stage_valid[stage-1]) begin
          stage_tag[stage] <= stage_tag[stage-1];
          stage_old_ps[stage] <= stage_old_ps[stage-1];
        end
      end
      if (stage_valid[0]) begin
        for (int lane=0; lane<32; lane++)
          for (int k=0; k<16; k++)
            tree1[lane][k] <=
                $signed({product[lane][2*k][15], product[lane][2*k]}) +
                $signed({product[lane][2*k+1][15], product[lane][2*k+1]});
      end
      if (stage_valid[1]) begin
        for (int lane=0; lane<32; lane++)
          for (int k=0; k<8; k++)
            tree2[lane][k] <=
                $signed({tree1[lane][2*k][16], tree1[lane][2*k]}) +
                $signed({tree1[lane][2*k+1][16], tree1[lane][2*k+1]});
      end
      if (stage_valid[2]) begin
        for (int lane=0; lane<32; lane++)
          for (int k=0; k<4; k++)
            tree3[lane][k] <=
                $signed({tree2[lane][2*k][17], tree2[lane][2*k]}) +
                $signed({tree2[lane][2*k+1][17], tree2[lane][2*k+1]});
      end
      if (stage_valid[3]) begin
        for (int lane=0; lane<32; lane++)
          for (int k=0; k<2; k++)
            tree4[lane][k] <=
                $signed({tree3[lane][2*k][18], tree3[lane][2*k]}) +
                $signed({tree3[lane][2*k+1][18], tree3[lane][2*k+1]});
      end
      if (stage_valid[4]) begin
        for (int lane=0; lane<32; lane++)
          tree5[lane] <=
              $signed({tree4[lane][0][19], tree4[lane][0]}) +
              $signed({tree4[lane][1][19], tree4[lane][1]});
      end
    end
  end

  assign ret_valid = stage_valid[5];
  assign ret_tag = stage_tag[5];
  assign ret_old_ps = stage_old_ps[5];
  for (genvar lane=0; lane<32; lane++) begin : flat_completion
    assign ret_dot21[21*lane +: 21] = tree5[lane];
  end
endmodule
