`timescale 1ns/1ps
// Local diagnostic: original, saved Wi row drives the unchanged G core.
module laya_g_saved_wi_direct_tb;
  logic clk=0; always #5 clk=~clk;
  logic reset=1,in_valid;
  logic [31:0] in_x,in_g;
  wire commit_valid;
  wire [31:0] data,status,failed;
  geglu_canonical_core dut(.*);
  logic [31:0] wi[0:5247],gold[0:2623];
  string fixture;
  int sent=0,returned=0,cycle=0;
  assign in_valid=!reset && sent<2624;
  assign in_x=wi[sent<2624 ? sent : 0];
  assign in_g=wi[sent<2624 ? 2624+sent : 2624];
  always @(posedge clk) if(!reset)begin
    cycle<=cycle+1;
    if(in_valid)sent<=sent+1;
    if(commit_valid)begin
      if(returned>=2624 || status!=0 || data!==gold[returned])
        $fatal(1,"G_SAVED_WI_MISMATCH index=%0d x=%h gate=%h got=%h expected=%h status=%h",
          returned,wi[returned],wi[2624+returned],data,gold[returned],status);
      returned<=returned+1;
    end
  end
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE_REQUIRED");
    $readmemh({fixture,"/final_row0.hex"},wi);
    $readmemh({fixture,"/g_row0.hex"},gold);
    repeat(5)@(negedge clk);reset=0;
    for(int guard=0;guard<4000 && returned<2624;guard++)@(negedge clk);
    if(sent!=2624 || returned!=2624)$fatal(1,"G_SAVED_WI_DEBT sent=%0d returned=%0d",sent,returned);
    $display("G_SAVED_WI_CORE_PASS sent=2624 returned=2624 cycles=%0d",cycle);
    $finish;
  end
endmodule
