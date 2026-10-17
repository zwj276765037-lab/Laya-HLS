`timescale 1ns/1ps
module ffn1_progress_observer_micro_tb_v1;
  logic clk=0,rst_n=0;
  logic [34:0][2:0] event_inc;
  logic [34:0][63:0] counts;
  logic [63:0] work;
  logic [34:0] event_valid,event_ready;
  ffn1_progress_observer_v1 #(.FAMILIES(35)) dut(
    .clk,.rst_n,.event_inc,.counts,.work);
  always #5 clk=~clk;
  always_comb begin
    event_inc='0;
    for(integer k=0;k<35;k++)event_inc[k]={2'b00,
      event_valid[k] && event_ready[k]};
  end
  task automatic edge();
    @(posedge clk); #1;
  endtask
  initial begin
    event_valid='0;event_ready='0;
    repeat(3)edge();
    @(negedge clk);rst_n=1;
    // Every family uses a real valid/ready-qualified event, not a valid
    // level. Exercise each input in isolation with the others held still.
    for(integer k=0;k<35;k++)begin
      @(negedge clk);event_valid[k]=1;event_ready[k]=0;
      repeat(3)edge();
      if(counts[k]!=0 || work!=64'(k))
        $fatal(1,"FFN1 micro valid without ready family=%0d",k);
      @(negedge clk);event_ready[k]=1;
      edge();
      if(counts[k]!=1 || work!=64'(k+1))
        $fatal(1,"FFN1 micro isolated event family=%0d",k);
      @(negedge clk);event_valid[k]=0;event_ready[k]=0;
    end
    // The three physical W R ports can all return on the same edge.
    @(negedge clk);event_valid[10]=1;event_valid[12]=1;
    event_valid[14]=1;event_ready[10]=1;event_ready[12]=1;
    event_ready[14]=1;
    edge();
    if(counts[10]!=2 || counts[12]!=2 || counts[14]!=2 || work!=38)
      $fatal(1,"FFN1 micro simultaneous q0/q1/scale R");
    @(negedge clk);event_valid='0;event_ready='0;
    repeat(3)edge();
    if(work!=38)$fatal(1,"FFN1 micro idle advanced");
    $display("FFN1_PROGRESS work=%0d lnar=%0d lnr=%0d lnit=%0d lnwr=%0d lnport=%0d qowner=%0d qread=%0d qmath=%0d afill=%0d w0ar=%0d w0r=%0d w1ar=%0d w1r=%0d wsar=%0d wsr=%0d aux=%0d wpub=%0d ma=%0d mw=%0d mps=%0d mwr=%0d mret=%0d wiread=%0d wicons=%0d giss=%0d gret=%0d gemit=%0d gwr=%0d gqread=%0d gqmath=%0d rcfg=%0d rsrc=%0d radd=%0d rwr=%0d rdone=%0d",
      work,
      counts[0],
      counts[1],
      counts[2],
      counts[3],
      counts[4],
      counts[5],
      counts[6],
      counts[7],
      counts[8],
      counts[9],
      counts[10],
      counts[11],
      counts[12],
      counts[13],
      counts[14],
      counts[15],
      counts[16],
      counts[17],
      counts[18],
      counts[19],
      counts[20],
      counts[21],
      counts[22],
      counts[23],
      counts[24],
      counts[25],
      counts[26],
      counts[27],
      counts[28],
      counts[29],
      counts[30],
      counts[31],
      counts[32],
      counts[33],
      counts[34]);
    $display("FFN1_OBSERVER_MICRO_PASS families=35 isolated=35 simultaneous_W_R=3 held_valid_ready_low=1 work=%0d",work);
    $finish;
  end
endmodule
