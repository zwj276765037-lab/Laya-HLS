`timescale 1ns/1ps
module m007_quant_local_tb;
 logic clk=0,rst_n=0,in_valid=0;always#5 clk=~clk;
 logic[1023:0]in_data=0;logic[15:0]in_tag=0,out_tag;
 logic out_valid,out_bad;logic[31:0]out_amax;logic[4:0]out_bad_element;
 logic[31:0]format_input=0;logic[15:0]half;logic[7:0]q;
 logic half_error,product_nonfinite,range_error;
 logic[67:0]formats[0:4095];logic[1023:0]edges[0:255];logic[391:0]edge_gold[0:255];
 integer format_count,edge_count,seen=0,cycle=0,accepted_at[0:65535];
 string format_path,edge_path,gold_path;
 laya_m007_quant_format_v1 format_dut(.scale_f32(format_input),.product_f32(format_input),
  .scale_f16(half),.q8(q),.half_error,.product_nonfinite,.range_error);
 laya_m007_quant_amax32_v1#(.TAG_WIDTH(16))amax_dut(.*);
 always@(posedge clk)begin
  cycle=cycle+1;if(cycle>100000)$fatal(1,"local cycle limit");
  if(rst_n&&in_valid)accepted_at[in_tag]=cycle;
  #1;
  if(rst_n&&out_valid)begin
   if(cycle-accepted_at[out_tag]!=4)$fatal(1,"amax latency tag=%h latency=%0d",out_tag,cycle-accepted_at[out_tag]);
   if(out_tag[15:12]==8)begin
    if(out_tag[11:0]==3)begin
     if(!out_bad||out_bad_element!=2||out_amax!=0)$fatal(1,"custom first bad mismatch");
    end else if(out_bad||out_amax!=32'h3f800000)$fatal(1,"custom amax tie/moved maximum mismatch tag=%h",out_tag);
   end else begin
    if(out_tag>=edge_count)$fatal(1,"stale/unrecognized tag=%h",out_tag);
    if(out_amax!==edge_gold[out_tag][367:336]||out_bad!==(edge_gold[out_tag][383:376]==1)||
       (out_bad&&out_bad_element!==edge_gold[out_tag][372:368]))
     $fatal(1,"amax independent mismatch tag=%0d actual=%h bad=%0d element=%0d",out_tag,out_amax,out_bad,out_bad_element);
   end
   seen=seen+1;
  end
 end
 task automatic send_custom(input integer n,input logic[15:0]tag);
  @(negedge clk);in_valid=1;in_tag=tag;in_data=0;
  for(int lane=0;lane<32;lane++)in_data[lane*32+:32]=32'h3f000000;
  in_data[(n%32)*32+:32]=32'h3f800000;in_data[((31-n)%32)*32+:32]=32'hbf800000;
  if(n==3)begin in_data[2*32+:32]=32'h7fc00000;in_data[7*32+:32]=32'h7f800000;end
 endtask
 initial begin
  if(!$value$plusargs("FORMAT=%s",format_path)||!$value$plusargs("EDGES=%s",edge_path)||
     !$value$plusargs("GOLD=%s",gold_path)||!$value$plusargs("FORMAT_COUNT=%d",format_count)||
     !$value$plusargs("EDGE_COUNT=%d",edge_count))$fatal(1,"fixture args required");
  $readmemh(format_path,formats);$readmemh(edge_path,edges);$readmemh(gold_path,edge_gold);
  repeat(3)@(negedge clk);rst_n=1;
  for(int i=0;i<format_count;i++)begin
   format_input=formats[i][31:0];#1;
   if(half!==formats[i][47:32]||q!==formats[i][55:48]||half_error!==formats[i][56]||
      range_error!==formats[i][60]||product_nonfinite!==formats[i][64])
    $fatal(1,"format mismatch i=%0d input=%h half=%h q=%h flags=%b%b%b expected=%h",i,format_input,half,q,product_nonfinite,range_error,half_error,formats[i]);
  end
  $display("M007_QUANT_LOCAL_PROGRESS formats=%0d",format_count);
  for(int i=0;i<edge_count;i++)begin @(negedge clk);in_valid=1;in_tag=16'(i);in_data=edges[i];end
  for(int i=0;i<32;i++)send_custom(i,16'h8000|16'(i));
  @(negedge clk);in_valid=0;
  wait(seen==edge_count+32);@(negedge clk);
  for(int i=0;i<4;i++)send_custom(i,16'hf000|16'(i));
  @(negedge clk);rst_n=0;in_valid=0;
  repeat(2)@(negedge clk);rst_n=1;
  for(int i=0;i<4;i++)send_custom(i,16'h8000|16'(i));
  @(negedge clk);in_valid=0;
  wait(seen==edge_count+36);repeat(8)@(negedge clk);
  $display("HARDWARE_AGENT_SIM_PASS M007_QUANT_LOCAL formats=%0d amax=%0d latency_edges=5 reset_inflight=1",format_count,seen);$finish;
 end
endmodule
