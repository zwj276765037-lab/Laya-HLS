`timescale 1ns/1ps
module m007_sfu_f64_tb;
  reg clk=0,ce=0,reset=0;
  reg [63:0] a=0,b=0;
  wire [63:0] result;
  attention_exp_leaf_attention_f64_mul dut(.ap_clk(clk),.ap_ce(ce),.ap_rst(reset),.a(a),.b(b),.ap_return(result));
  always #1.666667 clk=~clk;
  reg [63:0] gold_pipe[0:16];
  reg [16:0] valid_pipe=0;
  reg [63:0] held_output;
  integer checks=0,cycles=0,issued=0,stalls=0,reset_updates=0,reset_holds=0;
  task tick(input bit en,rst,valid,input reg[63:0] av,bv,gold);
    integer j;
    begin
      @(negedge clk);ce=en;reset=rst;a=av;b=bv;held_output=result;
      if(en)begin
        for(j=16;j>0;j=j-1)gold_pipe[j]=gold_pipe[j-1];
        gold_pipe[0]=gold;valid_pipe={valid_pipe[15:0],valid};
      end
      @(posedge clk);#0.01;cycles=cycles+1;
      if(en && valid_pipe[16])begin
        if(result!==gold_pipe[16])$fatal(1,"F64_MISMATCH cycle=%0d got=%h gold=%h ce=%b reset=%b",cycles,result,gold_pipe[16],en,rst);
        checks=checks+1;
      end
      if(!en)begin
        if(result!==held_output)$fatal(1,"F64_CE_HOLD cycle=%0d",cycles);
        stalls=stalls+1;if(rst)reset_holds=reset_holds+1;
      end
      if(en&&valid)begin issued=issued+1;if(rst)reset_updates=reset_updates+1;end
    end
  endtask
  string data;
  integer fd,rc,index;
  reg[63:0] av,bv,gold;
  initial begin
    if(!$value$plusargs("DATA=%s",data))$fatal(1,"missing DATA");
    fd=$fopen({data,"/f64_vectors.txt"},"r");if(!fd)$fatal(1,"missing binary64 reference");
    index=0;
    while(!$feof(fd))begin
      rc=$fscanf(fd,"%h %h %h\n",av,bv,gold);if(rc!=3)$fatal(1,"malformed binary64 vector");
      tick(1,0,1,av,bv,gold);index=index+1;
    end
    $fclose(fd);
    repeat(16)tick(1,0,0,0,0,0);
    if(checks!=index || index!=100400)$fatal(1,"continuous retirement count %0d %0d",checks,index);
    $display("SFU_PHASE_PASS f64_continuous=%0d latency=16 II=1",checks);
    fd=$fopen({data,"/f64_vectors.txt"},"r");
    for(index=0;index<1024;index=index+1)begin
      rc=$fscanf(fd,"%h %h %h\n",av,bv,gold);if(rc!=3)$fatal(1,"short binary64 fixture");
      if(index%3==0)repeat(1+(index%5))tick(0,index%2,0,~av,~bv,0);
      tick(1,index%7==0,1,av,bv,gold);
    end
    $fclose(fd);
    repeat(16)tick(1,0,0,0,0,0);
    repeat(9)tick(0,1,0,64'h1234,64'h5678,0);
    // Raw helper reset is ignored. All pre-reset results must still be exact;
    // external service valid/token reset isolation is outside this raw test.
    if(checks!=issued || reset_updates<100 || reset_holds<100 || stalls<1000)
      $fatal(1,"F64 missing coverage checks=%0d issued=%0d",checks,issued);
    $display("SFU_RTL_PASS f64_checks=%0d issued=%0d ce_holds=%0d reset_updates=%0d reset_holds=%0d cycles=%0d latency=16 II=1 raw_reset_payload=ignored",
       checks,issued,stalls,reset_updates,reset_holds,cycles);
    $finish;
  end
  initial begin #4000000;$fatal(1,"F64 bounded TB timeout");end
endmodule
