`timescale 1ns/1ps
// Observer-only synthetic signals. No model output or downstream-chain claim.
module m007_public_f32_capture_directed_tb;
 logic clk=0,rst_n=0,command_fire=0,input_fire=0,output_fire=0,receipt_fire=0;
 logic [63:0]request_id=64'h0123456789abcdef;
 logic [31:0]generation=17,source_epoch=29;
 logic [4:0]layer_index=0;logic [2:0]kind=4;
 logic [7:0]input_row=0,input_group=0;
 logic [31:0][31:0]input_data=0,data=0;
 logic [6:0]row=0;logic [15:0]col=0;
 logic [7:0]receipt_status=0,receipt_source_status=0;
 logic [2:0]receipt_domain=0;logic [95:0]receipt_tuple=0;
 logic all_resources_retired=1;
 integer test_case=0,total=4096;
 always #5 clk=~clk;
 m007_public_f32_capture_tb_v2 capture(.*);
 function automatic logic [31:0]pattern(input integer address,lane,stream_id);
  for(integer octet=0;octet<4;octet++)
   pattern[8*octet+:8]=(address*13+lane*17+octet*67+stream_id*37)&255;
 endfunction
 task automatic vector_at(input integer in_address,out_address);
  @(negedge clk);
  input_fire=1;output_fire=1;
  input_row=in_address/32;input_group=in_address%32;
  row=out_address/32;col=(out_address%32)*32;
  for(integer lane=0;lane<32;lane++)begin
   input_data[lane]=pattern(in_address,lane,0);
   data[lane]=pattern(out_address,lane,1);
  end
 endtask
 initial begin
  if(!$value$plusargs("CASE=%d",test_case))test_case=0;
  if(test_case<0||test_case>6)$fatal(1,"directed case range");
  if(test_case==5)total=16;
  if(test_case==6)total=4095;
  repeat(3)@(negedge clk);rst_n=1;command_fire=1;
  @(negedge clk);command_fire=0;
  for(integer seq=0;seq<total;seq++)
   vector_at((seq*2053+97)%4096,(seq*3077+243)%4096);
  if(test_case==5)begin
   // One duplicate per direction, then one invalid input and output coordinate.
   vector_at(97,243);
   vector_at(0,0);input_group=32;col=1;
  end
  @(negedge clk);input_fire=0;output_fire=0;
  if(test_case!=5)begin
   if(capture.input_unique!=total||capture.unique_words!=total||capture.input_errors!=0||capture.coordinate_errors!=0||capture.duplicate_errors!=0)$fatal(1,"actual observer unique/error accounting");
  end else if(capture.input_accepted!=18||capture.accepted!=18||capture.input_unique!=16||capture.unique_words!=16||capture.input_errors!=2||capture.coordinate_errors!=1||capture.duplicate_errors!=1)$fatal(1,"actual malformed/duplicate accounting");
  if(test_case==2)begin receipt_status=2;receipt_source_status=8;receipt_domain=7;receipt_tuple=96'h820000000000000000000001;end
  if(test_case==3)all_resources_retired=0;
  if(test_case!=1)receipt_fire=1;
  @(negedge clk);receipt_fire=0;
  if(capture.commands!=1||capture.receipts!=(test_case==1?0:1)||capture.successful_receipts!=((test_case==1||test_case==2||test_case==3)?0:1))$fatal(1,"actual observer receipt accounting");
  capture.finish_capture(test_case!=4);
  $display("HARDWARE_AGENT_SIM_PASS M007_CAPTURE_DIRECTED case=%0d groups=%0d",test_case,total);
  $finish;
 end
 initial begin #1000000;$fatal(1,"directed cycle timeout");end
endmodule
