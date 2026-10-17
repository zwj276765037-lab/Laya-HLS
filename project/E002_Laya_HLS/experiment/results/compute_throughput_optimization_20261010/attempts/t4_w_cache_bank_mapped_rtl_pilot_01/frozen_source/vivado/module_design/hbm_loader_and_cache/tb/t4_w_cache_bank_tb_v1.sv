`timescale 1ns/1ps
module t4_w_cache_bank_tb_v1;
  logic clk=0;
  always #3.3335 clk=~clk;
  logic q_we=0,s_we=0,b_we=0,qs_re=0,b_re=0;
  logic [13:0] q_waddr=0,s_waddr=0,qs_raddr=0;
  logic [8:0] b_waddr=0,b_raddr=0;
  logic [255:0] q_wdata=0,q_rdata;
  logic [15:0] s_wdata=0,s_rdata;
  logic [31:0] b_wdata=0,b_rdata;
  int cycles=0;
  always @(posedge clk) cycles<=cycles+1;
  t4_w_cache_bank_v1 dut(.*);
  function automatic logic [255:0] qp(input int address);
    for (int word=0;word<8;word++)
      qp[word*32 +:32]=32'h94c1375b ^ (32'(address)*32'h00010001) ^ (32'(word)<<24);
  endfunction
  function automatic logic [15:0] sp(input int address);
    return 16'(address)^16'h3a59;
  endfunction
  function automatic logic [31:0] bp(input int address);
    return 32'h1ca875b3 ^ (32'(address)*32'h01010101);
  endfunction
  initial begin
    logic [255:0] previous_q,hold_q;
    logic [15:0] previous_s,hold_s;
    logic [31:0] hold_b;
    // Distinct q/scale/bias write ports commit together for all bias addresses.
    for (int address=0;address<10496;address++) begin
      @(negedge clk);
      q_we=1;s_we=1;b_we=address<328;
      q_waddr=14'(address);s_waddr=14'(address);b_waddr=9'(address);
      q_wdata=qp(address);s_wdata=sp(address);b_wdata=bp(address);
      @(posedge clk);#1;
    end
    @(negedge clk);q_we=0;s_we=0;b_we=0;
    for (int address=0;address<10496;address++) begin
      previous_q=q_rdata;previous_s=s_rdata;
      qs_re=1;qs_raddr=14'(address);
      b_re=address<328;b_raddr=9'(address);
      #1;
      if (address!=0 && (q_rdata!==previous_q || s_rdata!==previous_s))
        $fatal(1,"T4_BANK_ASYNC_READ address=%0d",address);
      @(posedge clk);#1;
      if (q_rdata!==qp(address) || s_rdata!==sp(address))
        $fatal(1,"T4_BANK_FULL_DEPTH_READ address=%0d",address);
      if (address<328 && b_rdata!==bp(address))
        $fatal(1,"T4_BANK_BIAS_READ address=%0d",address);
      if (address==8191 || address==8192 || address==10495)
        $display("ACT_RTL_BANK_PROGRESS address=%0d cycles=%0d",address,cycles);
      @(negedge clk);
    end
    qs_re=0;b_re=0;hold_q=q_rdata;hold_s=s_rdata;hold_b=b_rdata;
    for (int stall=0;stall<31;stall++) begin
      qs_raddr=14'(stall*311);b_raddr=9'(stall*7);
      @(posedge clk);#1;
      if(q_rdata!==hold_q || s_rdata!==hold_s || b_rdata!==hold_b)
        $fatal(1,"T4_BANK_DISABLED_READ_NOT_HELD");
      @(negedge clk);
    end
    $display("T4_W_CACHE_BANK_PASS q_scale_addresses=10496 bias_addresses=328 synchronous_read=1 output_hold=31 parallel_write_ports=3 cycles=%0d",cycles);
    $finish;
  end
  initial begin
    repeat(40000) @(posedge clk);
    $fatal(1,"T4_BANK_CYCLE_WATCHDOG");
  end
endmodule
