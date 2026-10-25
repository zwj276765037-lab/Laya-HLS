`timescale 1ns/1ps
module m007_sfu_integer_tb;
  reg clk=0, ce=0, reset=0;
  reg [31:0] din0=0,din1=0;
  wire [49:0] out50;
  wire [63:0] out64;
  attention_exp_leaf_mul_32ns_32ns_50_2_1 #(
    .din0_WIDTH(32),.din1_WIDTH(32),.dout_WIDTH(50)) u50
    (.clk(clk),.ce(ce),.reset(reset),.din0(din0),.din1(din1),.dout(out50));
  attention_exp_leaf_mul_32ns_32ns_64_2_1 #(
    .din0_WIDTH(32),.din1_WIDTH(32),.dout_WIDTH(64)) u64
    (.clk(clk),.ce(ce),.reset(reset),.din0(din0),.din1(din1),.dout(out64));
  always #1.666667 clk=~clk;
  reg [63:0] expected=0;
  integer checks=0,accepts=0,holds=0,reset_updates=0,reset_holds=0;
  integer cycles=0;
  task tick(input bit en,input bit rst,input reg [31:0] a,b,
            input reg [63:0] independent_product);
    begin
      @(negedge clk); ce=en; reset=rst; din0=a; din1=b;
      if(en) expected=independent_product;
      @(posedge clk); #0.01;
      cycles=cycles+1;
      if(out50 !== expected[49:0] || out64 !== expected)
        $fatal(1,"INTEGER_MISMATCH cycle=%0d ce=%b reset=%b a=%h b=%h got50=%h got64=%h expected=%h",
               cycles,en,rst,a,b,out50,out64,expected);
      checks=checks+2;
      if(en) begin accepts=accepts+1; if(rst) reset_updates=reset_updates+1; end
      else begin holds=holds+1; if(rst) reset_holds=reset_holds+1; end
    end
  endtask
  string data;
  integer fd,rc,index;
  reg [31:0] a,b;
  reg [63:0] product;
  initial begin
    if(!$value$plusargs("DATA=%s",data)) $fatal(1,"missing DATA");
    fd=$fopen({data,"/integer_vectors.txt"},"r");
    if(!fd) $fatal(1,"missing independent vectors");
    tick(1,0,32'hffffffff,32'hffffffff,64'hfffffffe00000001);
    // All independent vectors accepted on consecutive clock edges (II1).
    index=0;
    while(!$feof(fd)) begin
      rc=$fscanf(fd,"%h %h %h\n",a,b,product);
      if(rc!=3) $fatal(1,"malformed independent vector at %0d",index);
      tick(1,0,a,b,product); index=index+1;
    end
    $fclose(fd);
    if(index<16000) $fatal(1,"fixture unexpectedly short %0d",index);
    $display("SFU_PHASE_PASS continuous_pairs=%0d checks=%0d",index,checks);
    fd=$fopen({data,"/integer_vectors.txt"},"r");
    // First 512 independent pairs, with finite 1..7-cycle CE holds and reset.
    for(index=0;index<512;index=index+1) begin
      rc=$fscanf(fd,"%h %h %h\n",a,b,product);
      if(rc!=3) $fatal(1,"short stall fixture");
      repeat(1+(index%7)) tick(0,index%2,~a,~b,0);
      tick(1,index%3==0,a,b,product);
    end
    $fclose(fd);
    tick(1,1,32'h80000000,32'h80000000,64'h4000000000000000);
    repeat(9) tick(0,1,32'h12345678,32'h9abcdef0,0);
    tick(1,0,32'hffffffff,32'h80000000,64'h7fffffff80000000);
    if(holds<2000 || reset_updates<100 || reset_holds<1000)
      $fatal(1,"missing CE/reset coverage");
    $display("SFU_RTL_PASS vectors=%0d checks=%0d accepts=%0d holds=%0d reset_updates=%0d reset_holds=%0d cycles=%0d latency_enabled_edges=1 II=1 reset_payload=ignored",
             index,checks,accepts,holds,reset_updates,reset_holds,cycles);
    $finish;
  end
  initial begin
    #1000000; $fatal(1,"bounded TB timeout");
  end
endmodule
