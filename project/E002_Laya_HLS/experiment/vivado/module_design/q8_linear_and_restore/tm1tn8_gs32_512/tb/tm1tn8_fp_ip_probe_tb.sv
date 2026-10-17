`timescale 1ns/1ps
module tm1tn8_fp_ip_probe_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic valid=0;
  wire cv, mv, av;
  wire [31:0] cd, md, ad;
  logic seen_c=0, seen_m=0, seen_a=0;

  tm1tn8_sitofp_ip convert_dot (
    .aclk(clk), .s_axis_a_tvalid(valid),
    .s_axis_a_tdata(32'hfffffff9),
    .m_axis_result_tvalid(cv), .m_axis_result_tdata(cd));
  tm1tn8_fmul_ip multiply_scales (
    .aclk(clk), .s_axis_a_tvalid(valid),
    .s_axis_a_tdata(32'h3f800000),
    .s_axis_b_tvalid(valid), .s_axis_b_tdata(32'h3f800000),
    .m_axis_result_tvalid(mv), .m_axis_result_tdata(md));
  tm1tn8_fadd_ip add_ps (
    .aclk(clk), .aclken(1'b1),
    .s_axis_a_tvalid(valid), .s_axis_a_tdata(32'h3f800000),
    .s_axis_b_tvalid(valid), .s_axis_b_tdata(32'h40000000),
    .m_axis_result_tvalid(av), .m_axis_result_tdata(ad));

  always @(negedge clk) begin
    if (cv === 1'b1) begin
      if (cd !== 32'hc0e00000) $fatal(1,"sitofp data=%h",cd);
      seen_c=1;
    end
    if (mv === 1'b1) begin
      if (md !== 32'h3f800000) $fatal(1,"fmul data=%h",md);
      seen_m=1;
    end
    if (av === 1'b1) begin
      if (ad !== 32'h40400000) $fatal(1,"fadd data=%h",ad);
      seen_a=1;
    end
  end

  initial begin
    repeat (16) @(negedge clk);
    valid=1;
    repeat (40) @(negedge clk);
    if (!(seen_c && seen_m && seen_a))
      $fatal(1,"FP IP valid timeout cv=%b mv=%b av=%b",cv,mv,av);
    $display("TM1TN8_FP_IP_PROBE_PASS conversion=-7 multiply=1 add=3");
    $finish;
  end
endmodule
