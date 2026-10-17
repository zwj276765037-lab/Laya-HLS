`timescale 1ns/1ps
module geglu_canonical_corner_tb;
 reg clk=0;always #3.333333 clk=~clk;
 reg reset=1,in_valid=0;reg [31:0] in_x=0,in_g=0;
 wire commit_valid;wire [31:0] data,status,failed;
 geglu_canonical_core dut(.*);
 reg [31:0] gold[0:7055];
 reg source_valid[0:1023];integer source_index[0:1023],accept_cycle[0:440];
 integer cycle=0,accepted=0,returned=0,step_checks=0,predicate_checks=0,i;
 string filename;
 task check_step(input integer step,input integer edge,input [31:0] value);
  integer src,index;
  begin
   src=(cycle-edge)%1024;
   if(cycle>=edge&&source_valid[src])begin
    index=source_index[src];
    if(gold[16*index+5][step])begin
     if(value!==gold[16*index+6+step])
      $fatal(1,"GEGLU_CANONICAL_CORNER_STEP index=%0d x=%08x g=%08x step=%0d got=%08x gold=%08x",index,gold[16*index],gold[16*index+1],step,value,gold[16*index+6+step]);
     step_checks=step_checks+1;
    end
   end
  end
 endtask
 task check_predicate(input integer step,input integer edge,input wire value);
  integer src,index;
  begin
   src=(cycle-edge)%1024;
   if(cycle>=edge&&source_valid[src])begin
    index=source_index[src];
    if(value!==gold[16*index+5][step])$fatal(1,"GEGLU_CANONICAL_CORNER_PREDICATE index=%0d step=%0d edge=%0d",index,step,edge);
    predicate_checks=predicate_checks+1;
   end
  end
 endtask
 always @(posedge clk)begin
  cycle=cycle+1;if(cycle>200000)$fatal(1,"GEGLU_CANONICAL_CORNER_CYCLE_CAP");
  if(reset)begin for(integer r=0;r<1024;r=r+1)source_valid[r]=0;end
  else begin
   source_valid[cycle%1024]=in_valid;source_index[cycle%1024]=accepted;
   if(in_valid)begin accept_cycle[accepted]=cycle;accepted=accepted+1;end
   check_step(0,16,dut.mul100);check_step(1,31,dut.mul101);check_step(2,38,dut.add100);
   check_step(3,53,dut.mul102);check_step(4,68,dut.mul103);check_step(5,453,dut.h);
   check_step(6,460,dut.add101);check_step(7,475,dut.mul104);check_step(8,490,dut.mul105);check_step(9,505,dut.mul106);
   check_predicate(0,2,dut.p0);check_predicate(1,17,dut.p1);check_predicate(2,32,dut.p2);
   check_predicate(3,39,dut.p3);check_predicate(4,54,dut.p4);check_predicate(5,69,dut.p5);
   check_predicate(6,454,dut.p6);check_predicate(7,461,dut.p7);check_predicate(8,476,dut.p8);check_predicate(9,491,dut.p9);
   if(commit_valid)begin
    if(returned>=accepted || cycle-accept_cycle[returned]!=506 ||
       {data,status,failed}!=={gold[16*returned+2],gold[16*returned+3],gold[16*returned+4]})
     $fatal(1,"GEGLU_CANONICAL_CORNER_RESULT index=%0d got=%08x/%0d/%0d gold=%08x/%0d/%0d",returned,data,status,failed,gold[16*returned+2],gold[16*returned+3],gold[16*returned+4]);
    returned=returned+1;
    if((returned%128)==0)$display("TANH_PROGRESS geglu_corner returned=%0d cycle=%0d",returned,cycle);
   end
  end
 end
 initial begin
  if(!$value$plusargs("CORNER_FILE=%s",filename))$fatal(1,"GEGLU_CANONICAL_MISSING_CORNER");
  $readmemh(filename,gold);
  for(i=0;i<7056;i=i+1)if($isunknown(gold[i]))$fatal(1,"GEGLU_CANONICAL_UNKNOWN_CORNER");
  repeat(4)@(negedge clk);reset=0;
  for(i=0;i<441;i=i+1)begin @(negedge clk);in_valid=1;in_x=gold[16*i];in_g=gold[16*i+1];end
  @(negedge clk);in_valid=0;
  wait(returned==441);@(negedge clk);
  if(accepted!=441||predicate_checks!=4410)$fatal(1,"GEGLU_CANONICAL_CORNER_DEBT");
  $display("GEGLU_CANONICAL_CORNER_RTL_PASS cases=441 applicable_steps=%0d predicate_checks=%0d commit_latency=506 original_scalar_reference=1 cycles=%0d",step_checks,predicate_checks,cycle);
  $finish;
 end
endmodule
