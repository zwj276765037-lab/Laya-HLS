`timescale 1ns/1ps
// Binary32 add, RNE, gradual underflow. Eight enabled-edge pipeline stages.
// Nonblocking paired inputs: an operation is accepted iff both valid and CE.
// Finite input domain is complete, including signed zero/subnormals/overflow.
module laya_fadd_rne_v1 (
  input logic aclk, aclken, aresetn,
  input logic s_axis_a_tvalid, s_axis_b_tvalid,
  input logic [31:0] s_axis_a_tdata, s_axis_b_tdata,
  output logic m_axis_result_tvalid,
  output logic [31:0] m_axis_result_tdata
);
  logic [7:0] valid;
  logic [30:0] mag_a1, mag_b1;
  logic sa1, sb1;
  logic [7:0] ea1, eb1;
  logic [23:0] ma1, mb1;
  logic special1;
  logic [31:0] special_bits1;
  logic [7:0] diff2;
  logic [8:0] exp2, exp3, exp4, exp5, exp6, exp7;
  logic [26:0] big2, small2, big3, small3;
  logic sub2, sub3;
  logic sign2, sign3, sign4, sign5, sign6, sign7;
  logic zero_negative2, zero_negative3, zero_negative4;
  logic zero_negative5, zero_negative6, zero_negative7;
  logic [27:0] sum4, sum5;
  logic [4:0] shift5;
  logic right5;
  logic [26:0] normalized6;
  logic [24:0] rounded7;
  logic special2, special3, special4, special5, special6, special7;
  logic [31:0] special_bits2, special_bits3, special_bits4;
  logic [31:0] special_bits5, special_bits6, special_bits7;

  function automatic [26:0] shr_jam27(input logic [26:0] x,
                                     input logic [7:0] n);
    logic [26:0] shifted, mask;
    begin
      if (n == 0) shr_jam27 = x;
      else if (n >= 27) shr_jam27 = {26'b0, |x};
      else begin
        shifted = x >> n;
        mask = ~(27'h7ffffff << n);
        shr_jam27 = shifted | {26'b0, |(x & mask)};
      end
    end
  endfunction
  function automatic [4:0] lzc27(input logic [26:0] x);
    logic [31:0] t;
    logic [4:0] n;
    begin
      t = {x,5'b0}; n = 0;
      if (t[31:16] == 0) begin t = t << 16; n = n + 16; end
      if (t[31:24] == 0) begin t = t << 8; n = n + 8; end
      if (t[31:28] == 0) begin t = t << 4; n = n + 4; end
      if (t[31:30] == 0) begin t = t << 2; n = n + 2; end
      if (t[31] == 0) n = n + 1;
      lzc27 = n;
    end
  endfunction
  logic [4:0] leading4;
  logic [8:0] packed_exp7;
  logic [22:0] packed_frac7;
  always_comb begin
    leading4 = lzc27(sum4[26:0]);
    packed_exp7 = exp7;
    packed_frac7 = rounded7[22:0];
    if (rounded7[24]) begin
      packed_exp7 = exp7 + 1'b1;
      packed_frac7 = rounded7[23:1];
    end else if (exp7 == 1 && !rounded7[23]) packed_exp7 = 0;
  end
  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      valid <= 0;
      m_axis_result_tdata <= 0;
    end else if (aclken) begin
      valid <= {valid[6:0],s_axis_a_tvalid && s_axis_b_tvalid};
      // 1: Decode; exponent 1 represents both subnormal and minimum normal.
      mag_a1 <= s_axis_a_tdata[30:0]; mag_b1 <= s_axis_b_tdata[30:0];
      sa1 <= s_axis_a_tdata[31]; sb1 <= s_axis_b_tdata[31];
      ea1 <= s_axis_a_tdata[30:23] == 0 ? 8'd1 : s_axis_a_tdata[30:23];
      eb1 <= s_axis_b_tdata[30:23] == 0 ? 8'd1 : s_axis_b_tdata[30:23];
      ma1 <= {s_axis_a_tdata[30:23] != 0,s_axis_a_tdata[22:0]};
      mb1 <= {s_axis_b_tdata[30:23] != 0,s_axis_b_tdata[22:0]};
      // Special values remain visible to the existing caller finite checks.
      special1 <= (&s_axis_a_tdata[30:23]) || (&s_axis_b_tdata[30:23]);
      if (((&s_axis_a_tdata[30:23]) && |s_axis_a_tdata[22:0]) ||
          ((&s_axis_b_tdata[30:23]) && |s_axis_b_tdata[22:0]) ||
          ((&s_axis_a_tdata[30:23]) && (&s_axis_b_tdata[30:23]) &&
           s_axis_a_tdata[31] != s_axis_b_tdata[31]))
        special_bits1 <= 32'h7fc00000;
      else if (&s_axis_a_tdata[30:23]) special_bits1 <= s_axis_a_tdata;
      else special_bits1 <= s_axis_b_tdata;
      // 2: Magnitude order, so subtraction never requires a sign correction.
      if (mag_a1 >= mag_b1) begin
        big2 <= {ma1,3'b0}; small2 <= {mb1,3'b0};
        exp2 <= {1'b0,ea1}; diff2 <= ea1 - eb1; sign2 <= sa1;
      end else begin
        big2 <= {mb1,3'b0}; small2 <= {ma1,3'b0};
        exp2 <= {1'b0,eb1}; diff2 <= eb1 - ea1; sign2 <= sb1;
      end
      sub2 <= sa1 != sb1;
      zero_negative2 <= sa1 && sb1;
      special2 <= special1; special_bits2 <= special_bits1;
      // 3: Retain guard/round/sticky for every exponent distance.
      big3 <= big2; small3 <= shr_jam27(small2,diff2);
      exp3 <= exp2; sub3 <= sub2; sign3 <= sign2;
      zero_negative3 <= zero_negative2;
      special3 <= special2; special_bits3 <= special_bits2;
      // 4: One exact extended significand add/subtract.
      if (sub3) sum4 <= {1'b0,big3} - {1'b0,small3};
      else sum4 <= {1'b0,big3} + {1'b0,small3};
      exp4 <= exp3; sign4 <= sign3; zero_negative4 <= zero_negative3;
      special4 <= special3; special_bits4 <= special_bits3;
      // 5: Leading-zero tree and exponent cap implement gradual underflow.
      sum5 <= sum4; right5 <= sum4[27];
      if (sum4[27]) begin shift5 <= 0; exp5 <= exp4 + 1'b1; end
      else if ({4'b0,leading4} >= exp4) begin
        shift5 <= 5'(exp4 - 1'b1); exp5 <= 1;
      end else begin shift5 <= leading4; exp5 <= exp4 - leading4; end
      sign5 <= sign4; zero_negative5 <= zero_negative4;
      special5 <= special4; special_bits5 <= special_bits4;
      // 6: Normalize. Carry shift jams discarded bits before the sole round.
      if (right5) normalized6 <= {sum5[27:2],|sum5[1:0]};
      else normalized6 <= sum5[26:0] << shift5;
      exp6 <= exp5; sign6 <= sign5; zero_negative6 <= zero_negative5;
      special6 <= special5; special_bits6 <= special_bits5;
      // 7: Round to nearest, ties to even; no flush-to-zero path.
      rounded7 <= {1'b0,normalized6[26:3]} +
                  (normalized6[2] && (|normalized6[1:0] || normalized6[3]));
      exp7 <= exp6; sign7 <= sign6; zero_negative7 <= zero_negative6;
      special7 <= special6; special_bits7 <= special_bits6;
      // 8: Pack, including rounding carry, overflow, and RNE zero sign.
      if (special7) m_axis_result_tdata <= special_bits7;
      else if (rounded7 == 0) m_axis_result_tdata <= {zero_negative7,31'b0};
      else if (packed_exp7 >= 255) m_axis_result_tdata <= {sign7,8'hff,23'b0};
      else m_axis_result_tdata <= {sign7,packed_exp7[7:0],packed_frac7};
    end
  end
  assign m_axis_result_tvalid = valid[7];
endmodule
