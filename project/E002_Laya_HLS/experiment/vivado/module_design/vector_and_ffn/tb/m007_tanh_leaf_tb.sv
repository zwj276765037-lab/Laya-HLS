`timescale 1ns/1ps
module m007_tanh_leaf_tb;
 localparam int MAXV=600000;
 logic clk=0;always #1.6665 clk=~clk;
 logic ce=1,rst_n=0,av=0,bv=0;logic [31:0] a=0,b=0;
 wire [2:0] rv;wire [31:0] y[0:2];
 int op,lat,count,accepted=0,returned=0,cycles=0,wall=0,checked=0,reference_index=0,phase=0,last=-1;
 logic [95:0] vectors[0:MAXV-1];logic [31:0] expected_q[0:MAXV+1023];int cycle_q[0:MAXV+1023];string vector_file;
 laya_m007_tanh_add3_v1 add(.aclk(clk),.aclken(ce),.aresetn(rst_n),.s_axis_a_tvalid(av),.s_axis_b_tvalid(bv),.s_axis_a_tdata(a),.s_axis_b_tdata(b),.m_axis_result_tvalid(rv[0]),.m_axis_result_tdata(y[0]));
 laya_m007_tanh_mul4_v1 mul(.aclk(clk),.aclken(ce),.aresetn(rst_n),.s_axis_a_tvalid(av),.s_axis_b_tvalid(bv),.s_axis_a_tdata(a),.s_axis_b_tdata(b),.m_axis_result_tvalid(rv[1]),.m_axis_result_tdata(y[1]));
 laya_m007_tanh_div12_v1 div(.aclk(clk),.aclken(ce),.aresetn(rst_n),.s_axis_a_tvalid(av),.s_axis_b_tvalid(bv),.s_axis_a_tdata(a),.s_axis_b_tdata(b),.m_axis_result_tvalid(rv[2]),.m_axis_result_tdata(y[2]));
 task automatic drive(input int i);reference_index=i;a=vectors[i][95:64];b=vectors[i][63:32];av=1;bv=1;endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vector_file)||!$value$plusargs("COUNT=%d",count)||!$value$plusargs("OP=%d",op)||count>MAXV||count<100||op>2)$fatal(1,"ARGS");
  lat=op==0?3:(op==1?4:12);$readmemh(vector_file,vectors,0,count-1);
  repeat(5)@(negedge clk);rst_n=1;phase=1;
  for(int i=0;i<count;i++)begin @(negedge clk);drive(i);end
  @(negedge clk);av=0;bv=0;wait(returned==count);repeat(3)@(negedge clk);
  $display("CONTINUOUS_PASS op=%0d count=%0d latency=%0d ii=1",op,count,lat);phase=2;
  for(int i=0;i<128;i++)begin @(negedge clk);drive(i);if(i%11==0)begin ce=0;repeat(3)@(negedge clk);ce=1;end end
  @(negedge clk);av=0;bv=0;wait(returned==count+128);repeat(3)@(negedge clk);phase=3;
  for(int i=0;i<2;i++)begin @(negedge clk);drive(i);end
  @(negedge clk);if(accepted==returned)$fatal(1,"RESET_NOT_INFLIGHT");rst_n=0;ce=0;av=0;bv=0;
  repeat(3)@(negedge clk);rst_n=1;ce=1;repeat(16)@(negedge clk);
  if(rv[op]||accepted||returned)$fatal(1,"RESET_LEAK");phase=4;
  for(int i=0;i<64;i++)begin @(negedge clk);drive(i);if(i%7==0)bv=0;if(i%7==1)av=0;end
  @(negedge clk);av=0;bv=0;wait(returned==accepted);repeat(16)@(negedge clk);
  if(returned!=45)$fatal(1,"PAIR_COUNT");
  $display("HARDWARE_AGENT_SIM_PASS TANH_FAST_LEAF op=%0d checked=%0d latency=%0d ii=1 ce_holds=36 reset_discard=2 pair_recovery=45",op,checked,lat);$finish;
 end
 logic [31:0] held;logic held_v;
 always @(posedge clk)if(rst_n&&!ce)begin held=y[op];held_v=rv[op];#0.001;if(held!==y[op]||held_v!==rv[op])$fatal(1,"CE_HOLD");end
 always @(posedge clk)begin
  wall=wall+1;if(wall>2*MAXV)$fatal(1,"TIMEOUT");
  if(!rst_n)begin accepted=0;returned=0;cycles=0;last=-1;end
  else if(ce)begin
   cycles=cycles+1;
   if(av&&bv)begin expected_q[accepted]=vectors[reference_index][31:0];cycle_q[accepted]=cycles;accepted=accepted+1;end
   if(rv[op])begin
    if(returned>=accepted||y[op]!==expected_q[returned])$fatal(1,"NUMERIC op=%0d phase=%0d index=%0d a=%h b=%h got=%h expected=%h",op,phase,returned,vectors[returned][95:64],vectors[returned][63:32],y[op],expected_q[returned]);
    if(cycles-cycle_q[returned]!=lat)$fatal(1,"LATENCY got=%0d expected=%0d",cycles-cycle_q[returned],lat);
    if(phase==1&&last>=0&&cycles!=last+1)$fatal(1,"II");if(phase==1)last=cycles;
    returned=returned+1;checked=checked+1;
   end
  end
 end
endmodule
