`timescale 1ns/1ps
module m007_fmul_rne_tb;
  localparam int MAXV=250000;
  logic clk=0; always #1.6665 clk=~clk;
  logic ce=1,rst_n=0,av=0,bv=0,rv;
  logic [31:0] a=0,b=0,y;
  logic [95:0] vectors [0:MAXV-1];
  logic [31:0] expected_q [0:MAXV+1023];
  int cycle_q [0:MAXV+1023];
  int count,accepted=0,returned=0,enabled_cycle=0,wall_cycle=0;
  int total_checked=0,phase=0,continuous_last=-1,reference_index=0;
  string vector_file;
  laya_fmul_rne_v1 dut(.aclk(clk),.aclken(ce),.aresetn(rst_n),
    .s_axis_a_tvalid(av),.s_axis_a_tdata(a),.s_axis_b_tvalid(bv),
    .s_axis_b_tdata(b),.m_axis_result_tvalid(rv),.m_axis_result_tdata(y));
  task automatic drive(input int k);
    reference_index=k;a=vectors[k][95:64];b=vectors[k][63:32];av=1;bv=1;
  endtask
  initial begin
    if(!$value$plusargs("VECTORS=%s",vector_file) ||
       !$value$plusargs("COUNT=%d",count) || count>MAXV || count<100)
      $fatal(1,"FMUL_FIXTURE_ARGUMENTS");
    $readmemh(vector_file,vectors,0,count-1);
    repeat(5) @(negedge clk);rst_n=1;phase=1;
    for(int k=0;k<count;k++) begin @(negedge clk);drive(k);end
    @(negedge clk);av=0;bv=0;
    wait(returned==count);repeat(3) @(negedge clk);
    $display("FMUL_CONTINUOUS_PASS count=%0d latency=8 ii=1",returned);
    phase=2;
    for(int k=0;k<128;k++) begin
      @(negedge clk);drive(k);
      if(k%11==0) begin
        ce=0;repeat(3) @(negedge clk);ce=1;
      end
    end
    @(negedge clk);av=0;bv=0;
    wait(returned==count+128);repeat(3) @(negedge clk);
    $display("FMUL_CE_PASS count=128 stalls=36");
    phase=3;
    for(int k=0;k<3;k++) begin @(negedge clk);drive(k);end
    @(negedge clk);rst_n=0;ce=0;av=0;bv=0;
    repeat(3) @(negedge clk);rst_n=1;ce=1;
    repeat(12) @(negedge clk);
    if(rv || accepted || returned) $fatal(1,"FMUL_RESET_LEAK");
    phase=4;
    for(int k=0;k<64;k++) begin
      @(negedge clk);drive(k);
      if(k%7==0) begin av=1;bv=0;end
      if(k%7==1) begin av=0;bv=1;end
    end
    @(negedge clk);av=0;bv=0;
    wait(returned==accepted);repeat(12) @(negedge clk);
    if(returned!=45) $fatal(1,"FMUL_PAIR_COUNT got=%0d",returned);
    $display("FMUL_RESET_PAIR_PASS discarded=3 returned=%0d",returned);
    $display("HARDWARE_AGENT_SIM_PASS FMUL_RNE checked=%0d latency=8 continuous_ii=1",total_checked);
    $finish;
  end
  logic [31:0] held_y;
  logic held_v;
  always @(posedge clk) if(rst_n && !ce) begin
    held_y=y;held_v=rv;
    #0.001;
    if(y!==held_y || rv!==held_v) $fatal(1,"FMUL_CE_HOLD");
  end
  always @(posedge clk) begin
    wall_cycle=wall_cycle+1;
    if(wall_cycle>2*MAXV) $fatal(1,"FMUL_TIMEOUT");
    if(!rst_n) begin accepted=0;returned=0;enabled_cycle=0;continuous_last=-1;end
    else if(ce) begin
      enabled_cycle=enabled_cycle+1;
      if(av && bv) begin
        expected_q[accepted]=vectors[reference_index][31:0];
        cycle_q[accepted]=enabled_cycle;accepted=accepted+1;
      end
      if(rv) begin
        if(returned>=accepted || y!==expected_q[returned])
          $fatal(1,"FMUL_NUMERIC phase=%0d index=%0d got=%h expected=%h",phase,returned,y,expected_q[returned]);
        if(enabled_cycle-cycle_q[returned]!=8)
          $fatal(1,"FMUL_LATENCY got=%0d",enabled_cycle-cycle_q[returned]);
        if(phase==1 && continuous_last>=0 && enabled_cycle!=continuous_last+1)
          $fatal(1,"FMUL_II");
        if(phase==1) continuous_last=enabled_cycle;
        returned=returned+1;total_checked=total_checked+1;
      end
    end
  end
endmodule
