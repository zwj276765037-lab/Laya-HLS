`timescale 1ns/1ps
module ln_leaf_probe_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst=1,ce=1,capture=0;
  logic [31:0] a=0,b=0,mul_bits,div_bits,sqrt_bits;
  logic [31:0] oracle[0:79];
  logic [31:0] sm[0:63],sd[0:63],ss[0:63];
  integer sample_count=0,ml=-1,dl=-1,sl=-1;
  attention_tile_ce_tanh_libm_stream_leaf_stream_mul_node_14_s mul(
    .ap_clk(clk),.ap_rst(rst),.ap_ce(ce),.laya_global_ce(ce),
    .a(a),.b(b),.ap_return(mul_bits));
  attention_tile_ce_tanh_libm_stream_leaf_stream_div_node_0_s div(
    .ap_clk(clk),.ap_rst(rst),.ap_ce(ce),.laya_global_ce(ce),
    .a(a),.b(b),.ap_return(div_bits));
  laya_front16_wide_fsqrt_32ns_32ns_32_7_no_dsp_1 sqrt(
    .clk(clk),.reset(rst),.ce(ce),.din0(32'd0),.din1(b),.dout(sqrt_bits));
  always @(posedge clk) if(capture) begin
    if(sample_count<64) begin
      sm[sample_count]=mul_bits;
      sd[sample_count]=div_bits;
      ss[sample_count]=sqrt_bits;
    end
    sample_count=sample_count+1;
  end
  initial begin
    string f;
    bit goodm,goodd,goods;
    if(!$value$plusargs("ORACLE=%s",f)) $fatal(1,"ORACLE_MISSING");
    $readmemh(f,oracle);
    repeat(3) @(negedge clk);
    rst=0; capture=1;
    for(integer i=0;i<16;i++) begin
      a=oracle[i*5]; b=oracle[i*5+1];
      @(negedge clk);
    end
    a=0; b=32'h3f800000;
    repeat(30) @(negedge clk);
    capture=0;
    for(integer lag=0;lag<26;lag++) begin
      goodm=1; goodd=1; goods=1;
      for(integer i=0;i<16;i++) begin
        if(sm[lag+i] !== oracle[i*5+2]) goodm=0;
        if(sd[lag+i] !== oracle[i*5+3]) goodd=0;
        if(ss[lag+i] !== oracle[i*5+4]) goods=0;
      end
      if(goodm && ml<0) ml=lag;
      if(goodd && dl<0) dl=lag;
      if(goods && sl<0) sl=lag;
    end
    if(ml<0 || dl<0 || sl<0) begin
      for(integer i=0;i<22;i++)
        $display("LN_PROBE_SAMPLE i=%0d mul=%08x div=%08x sqrt=%08x",i,sm[i],sd[i],ss[i]);
      $fatal(1,"LN_LEAF_MISMATCH mul_lag=%0d div_lag=%0d sqrt_lag=%0d",ml,dl,sl);
    end
    $display("LN_LEAF_PROBE_PASS n=16 mul_lag=%0d div_lag=%0d sqrt_lag=%0d continuous_II=1",ml,dl,sl);
    $finish;
  end
  initial begin repeat(200) @(posedge clk); $fatal(1,"LN_LEAF_TIMEOUT"); end
endmodule
