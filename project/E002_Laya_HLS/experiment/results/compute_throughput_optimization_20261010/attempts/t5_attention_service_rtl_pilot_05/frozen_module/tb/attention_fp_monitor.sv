`timescale 1ns/1ps
// Passive oracle at the actual vendor FP core ports. Idle repeats are tracked
// separately; no signal is forced and no expected value enters the DUT.
module attention_fp_monitor #(parameter int OP_KIND=0,CORE_LATENCY=5)(
 input logic clk,rst_n,advance,valid,finish_check,
 input logic[31:0] a,b,y);
 typedef logic[63:0] operand_pair_t;
 logic[31:0] oracle[operand_pair_t];
 logic[31:0] gold_pipe[0:CORE_LATENCY-1],expected;
 bit match_pipe[0:CORE_LATENCY-1],expected_valid;
 int checked=0,matched=0,core_steps=0;
 string fixture,op;int rows,count,fa,fb,fg,rv;logic[31:0] va,vb,vg;
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FP monitor fixture required");
  rows=8;if($value$plusargs("ROWS=%d",rows))begin end
  op=OP_KIND==0?"mul":(OP_KIND==1?"add":"div");
  count=rows*(OP_KIND==0?16640:(OP_KIND==1?16767:128));
  fa=$fopen({fixture,"/",op,"_a.mem"},"r");fb=$fopen({fixture,"/",op,"_b.mem"},"r");fg=$fopen({fixture,"/",op,"_gold.mem"},"r");
  if(!fa||!fb||!fg)$fatal(1,"FP monitor gold files missing op%s",op);
  for(int i=0;i<count;i++)begin
   rv=$fscanf(fa,"%h\n",va);if(rv!=1)$fatal(1,"FP oracle a truncated");
   rv=$fscanf(fb,"%h\n",vb);if(rv!=1)$fatal(1,"FP oracle b truncated");
   rv=$fscanf(fg,"%h\n",vg);if(rv!=1)$fatal(1,"FP oracle gold truncated");
   if(oracle.exists({va,vb})&&oracle[{va,vb}]!==vg)$fatal(1,"FP oracle inconsistent pair");
   oracle[{va,vb}]=vg;
  end
  $fclose(fa);$fclose(fb);$fclose(fg);
  $display("ATTENTION_FP_ORACLE_READY op=%s records=%0d unique=%0d core_latency=%0d",op,count,oracle.num(),CORE_LATENCY);
 end
 always @(posedge clk)begin
  if(!rst_n)begin
   expected_valid<=0;core_steps=0;
   for(int i=0;i<CORE_LATENCY;i++)begin match_pipe[i]<=0;gold_pipe[i]<=0;end
  end else if(advance)begin
   core_steps++;
   expected_valid<=match_pipe[CORE_LATENCY-1];expected<=gold_pipe[CORE_LATENCY-1];
   for(int i=CORE_LATENCY-1;i>0;i--)begin match_pipe[i]<=match_pipe[i-1];gold_pipe[i]<=gold_pipe[i-1];end
   match_pipe[0]<=0;
   if(!$isunknown({a,b})&&oracle.exists({a,b}))begin
    match_pipe[0]<=1;gold_pipe[0]<=oracle[{a,b}];matched++;
   end
  end else expected_valid<=0;
 end
 always @(negedge clk)if(rst_n&&expected_valid)begin
  if(!valid||y!==expected)$fatal(1,"ATTENTION_BASIC_FP_FAIL op=%s got=%08x gold=%08x valid%0d checked%0d steps%0d",op,y,expected,valid,checked,core_steps);
  checked++;
 end
 always @(posedge clk)if(finish_check)begin
  if(checked==0)$fatal(1,"FP monitor no real matched result op%s",op);
  $display("ATTENTION_BASIC_FP_PASS op=%s checked=%0d matched=%0d core_steps=%0d",op,checked,matched,core_steps);
 end
endmodule
