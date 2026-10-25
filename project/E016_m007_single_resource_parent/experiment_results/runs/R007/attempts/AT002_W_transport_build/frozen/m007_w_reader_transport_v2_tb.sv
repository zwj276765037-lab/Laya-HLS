`timescale 1ns/1ps
// Independent real transport test. No math mock and no parent-state forcing.
module m007_w_reader_transport_v2_tb;
 logic clk=0,rst=1,start=0;logic[63:0]start_addr=64'h1000;logic[31:0]byte_count=128;
 logic arvalid,arready=0;logic[63:0]araddr;logic[2:0]arid;logic[7:0]arlen;
 logic rvalid=0,rready;logic[2:0]rid=0;logic[511:0]rdata=0;logic[1:0]rresp=0;logic rlast=0;
 logic out_valid,out_ready=0;logic[511:0]out_data;logic done;logic[1:0]errors;logic[3:0]inflight,peak_inflight;logic[31:0]accepted_ar,accepted_r;logic transport_idle;
 laya_m007_w_reader_v2 dut(.*);always #1 clk=~clk;
 integer received=0;logic[511:0]held;integer checked=0,cycle=0;
 always@(posedge clk)begin cycle++;if(out_valid&&out_ready)begin
  if(out_data!==(received==0?512'h0123:512'h4567))$fatal(1,"real received payload changed");received++;
 end if(cycle>1000)$fatal(1,"bounded transport watchdog");end
 task automatic step;begin @(posedge clk);#0.001;end endtask
 task automatic beat(input logic[511:0]data,input logic last);
  begin @(negedge clk);rvalid=1;rdata=data;rlast=last;do @(posedge clk);while(!rready);@(negedge clk);rvalid=0;end
 endtask
 initial begin
  repeat(3)step();@(negedge clk);rst=0;#0.001;if(!transport_idle)$fatal(1,"reset idle");
  @(negedge clk);start=1;step();@(negedge clk);start=0;
  wait(arvalid);held=araddr;repeat(4)begin step();if(!arvalid||araddr!==held[63:0]||transport_idle)$fatal(1,"held AR hidden by idle");end
  @(negedge clk);arready=1;step();@(negedge clk);arready=0;
  beat(512'h0123,0);beat(512'h4567,0);
  repeat(6)begin step();if(transport_idle||done||out_valid)$fatal(1,"missing actual RLAST fabricated completion");end
  beat(512'hdead,1);wait(out_valid);held=out_data;repeat(4)begin step();if(!out_valid||out_data!==held||transport_idle)$fatal(1,"held payload hidden by idle");end
  @(negedge clk);out_ready=1;wait(done);#0.001;
  if(received!=2||errors!=2||accepted_ar!=1||accepted_r!=3||!transport_idle)$fatal(1,"real drain/strict error/count/idle");
  checked=2;$display("M007_PARENT_CHECKED checked=%0d phase=W_TRANSPORT cycle=%0d",checked,cycle);$display("HARDWARE_AGENT_SIM_PASS M007_W_READER_TRANSPORT");$fflush();$finish;
 end
endmodule
