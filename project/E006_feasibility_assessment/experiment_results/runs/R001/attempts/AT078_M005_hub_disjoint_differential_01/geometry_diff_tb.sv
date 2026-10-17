`timescale 1ns/1ps
module geometry_diff_tb;
  import laya_generated_provenance_layout_v1::*;
  logic [8191:0] packet;
  logic old_result,new_result;
  int checked;
  int unsigned seed;
  old_eval old_dut(.packet(packet),.result(old_result));
  new_eval new_dut(.packet(packet),.result(new_result));

  task automatic descriptor(input int d,role,
      input logic [63:0] base,owner_first,capacity,owner_length,
      input logic [31:0] segment,
      input int rows,repeats,
      input logic [63:0] row_step,repeat_step);
    int doff,goff;
    doff=(DESCRIPTOR0+d*128)*8;
    goff=(GEOMETRY0+d*64)*8;
    packet[doff+28*8+:8]=8'(role);
    packet[doff+32*8+:64]=capacity;
    packet[doff+40*8+:64]=owner_first;
    packet[doff+64*8+:64]=owner_length;
    packet[goff+0+:64]=base;
    packet[goff+8*8+:32]=segment;
    packet[goff+12*8+:16]=16'(rows);
    packet[goff+14*8+:16]=16'(repeats);
    packet[goff+16*8+:64]=row_step;
    packet[goff+24*8+:64]=repeat_step;
  endtask
  task automatic check(input string name,input logic expected);
    #1;
    if(old_result!==new_result || new_result!==expected)
      $fatal(1,"DIFF_FAIL %s old=%b new=%b expected=%b",name,old_result,new_result,expected);
    checked++;
    $display("DIFF_OK %s result=%b",name,new_result);
  endtask
  task automatic reset_packet(input int count);
    packet='0;
    packet[DESCRIPTOR_COUNT*8+:8]=8'(count);
  endtask
  initial begin
    checked=0;seed=32'h1a73c591;
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,1,1,10,100);
    check("one_interval",1);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,2,1,10,100);
    check("same_role_touch",1);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,2,1,9,100);
    check("same_role_overlap",0);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,32,1,9,100);
    check("last_interval_overlap",0);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,32,1,10,100);
    check("max32_touch",1);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,33,1,10,100);
    check("over32_rejected",0);
    reset_packet(1);descriptor(0,8,100,101,10000,10000,10,1,1,10,100);
    check("owner_first_rejected",0);
    reset_packet(1);descriptor(0,8,64'hfffffffffffffff8,0,64'hffffffffffffffff,
        64'hffffffffffffffff,10,1,1,10,100);
    check("wrap_rejected",0);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,2,2,20,5);
    check("cross_repeat_overlap",0);
    reset_packet(2);descriptor(0,8,100,0,10000,10000,10,1,1,10,100);
    descriptor(1,9,100,0,10000,10000,10,1,1,10,100);
    check("different_role_same_address",1);
    reset_packet(2);descriptor(0,8,100,0,10000,10000,10,1,1,10,100);
    descriptor(1,8,100,0,10000,10000,10,1,1,10,100);
    check("cross_descriptor_overlap",0);
    reset_packet(2);descriptor(0,8,100,0,10000,10000,10,1,1,10,100);
    descriptor(1,8,110,0,10000,10000,10,1,1,10,100);
    check("cross_descriptor_touch",1);
    for(int n=0;n<128;n++)begin
      int rows0,repeats0,rows1,repeats1,base0,base1,step0,step1,seg0,seg1,role0,role1;
      logic expected;
      seed=seed*32'd1664525+32'd1013904223; rows0=1+(seed%4);
      seed=seed*32'd1664525+32'd1013904223; repeats0=1+(seed%4);
      seed=seed*32'd1664525+32'd1013904223; rows1=1+(seed%4);
      seed=seed*32'd1664525+32'd1013904223; repeats1=1+(seed%4);
      seed=seed*32'd1664525+32'd1013904223; base0=100+(seed%80);
      seed=seed*32'd1664525+32'd1013904223; base1=100+(seed%80);
      seed=seed*32'd1664525+32'd1013904223; step0=1+(seed%24);
      seed=seed*32'd1664525+32'd1013904223; step1=1+(seed%24);
      seed=seed*32'd1664525+32'd1013904223; seg0=1+(seed%24);
      seed=seed*32'd1664525+32'd1013904223; seg1=1+(seed%24);
      seed=seed*32'd1664525+32'd1013904223; role0=8+(seed%2);
      seed=seed*32'd1664525+32'd1013904223; role1=8+(seed%2);
      reset_packet(2);
      descriptor(0,role0,64'(base0),0,10000,10000,32'(seg0),rows0,repeats0,64'(step0),64'(step0*rows0+3));
      descriptor(1,role1,64'(base1),0,10000,10000,32'(seg1),rows1,repeats1,64'(step1),64'(step1*rows1+3));
      #1;
      if(old_result!==new_result || (^new_result)===1'bx)
        $fatal(1,"RANDOM_DIFF_FAIL n=%0d seed=%h old=%b new=%b",n,seed,old_result,new_result);
      checked++;
    end
    reset_packet(0);#1;
    if(new_result!==1'b0 || request_frame_ok(packet)!==1'b0)
      $fatal(1,"BAD_COUNT_ZERO_ACCEPTED new=%b",new_result);
    reset_packet(3);#1;
    if(new_result!==1'b0 || request_frame_ok(packet)!==1'b0)
      $fatal(1,"BAD_COUNT_THREE_ACCEPTED new=%b",new_result);
    reset_packet(1);descriptor(0,8,100,0,10000,10000,10,2,1,9,100);
    packet[(DESCRIPTOR0+28)*8+:8]='x;#1;
    if(new_result===1'b1)$fatal(1,"UNKNOWN_ROLE_ACCEPTED");
    $display("GEOMETRY_DIFFERENTIAL_PASS known_cases=%0d invalid_counts=2 unknown_role=1 seed=%h",checked,seed);
    $finish;
  end
endmodule
