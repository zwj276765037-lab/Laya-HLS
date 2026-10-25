`timescale 1ns/1ps
// Observation-only TB helper. No output drives any DUT producer.
// Shape128x1024F32; native public stream may arrive in any coordinate order.
module m007_public_f32_capture_tb_v1(
 input logic clk,rst_n,command_fire,
 input logic[63:0]request_id,input logic[31:0]generation,source_epoch,
 input logic output_fire,input logic[6:0]row,input logic[15:0]col,
 input logic[31:0][31:0]data
);
 logic[1023:0]words[0:4095];logic[4095:0]seen;
 logic[63:0]held_request;logic[31:0]held_generation,held_epoch;
 integer accepted=0,unique_words=0,coordinate_errors=0,duplicate_errors=0,commands=0,cycle=0,trace_fd=0;
 string prefix;
 initial begin
  if(!$value$plusargs("EXPORT=%s",prefix))prefix="actual_public_output";
  trace_fd=$fopen({prefix,".accepted.jsonl"},"w");
  if(!trace_fd)$fatal(1,"actual public capture trace could not open");
 end
 always@(posedge clk)begin
  cycle++;
  if(!rst_n)begin seen=0;accepted=0;unique_words=0;coordinate_errors=0;duplicate_errors=0;commands=0;held_request=0;held_generation=0;held_epoch=0;end
  else begin
   if(command_fire)begin commands++;seen=0;accepted=0;unique_words=0;coordinate_errors=0;duplicate_errors=0;held_request=request_id;held_generation=generation;held_epoch=source_epoch;end
   if(output_fire)begin
    $fdisplay(trace_fd,"{\"accept_seq\":%0d,\"cycle\":%0d,\"request_hex\":\"%016h\",\"generation\":%0d,\"source_epoch\":%0d,\"row\":%0d,\"col\":%0d,\"data_hex_lane0_lsb\":\"%0256h\"}",accepted,cycle,held_request,held_generation,held_epoch,row,col,data);
    accepted++;
    if(col>=1024||col[4:0]!=0)coordinate_errors++;
    else begin
     int address;address=int'(row)*32+int'(col)/32;
     if(seen[address])duplicate_errors++;
     else begin seen[address]=1;unique_words++;end
     words[address]=data;
    end
   end
  end
 end
 task automatic finish_capture(input logic full_functional_success);
  integer data_fd,meta_fd,byte_count;logic complete;
  begin
   complete=full_functional_success&&commands==1&&accepted==4096&&unique_words==4096&&coordinate_errors==0&&duplicate_errors==0&&(&seen);
   $fflush(trace_fd);$fclose(trace_fd);trace_fd=0;byte_count=0;
   if(complete)begin
    data_fd=$fopen({prefix,".f32.bin"},"wb");if(!data_fd)$fatal(1,"actual public capture binary could not open");
    for(int address=0;address<4096;address++)for(int lane=0;lane<32;lane++)for(int octet=0;octet<4;octet++)begin $fwrite(data_fd,"%c",words[address][32*lane+8*octet+:8]);byte_count++;end
    $fclose(data_fd);
   end
   meta_fd=$fopen({prefix,".capture.json"},"w");if(!meta_fd)$fatal(1,"actual public capture metadata could not open");
   $fdisplay(meta_fd,"{\"schema\":\"m007-observed-public-f32-v1\",\"provenance\":\"actual public out_valid&&out_ready only; no DUT drive\",\"complete\":%s,\"request_hex\":\"%016h\",\"generation\":%0d,\"source_epoch\":%0d,\"commands\":%0d,\"accepted_groups32\":%0d,\"unique_groups32\":%0d,\"coordinate_errors\":%0d,\"duplicate_errors\":%0d,\"shape\":[1,128,1024],\"serialization\":\"row-major,lane0-first,F32bits-little-endian\",\"bytes\":%0d,\"data_sha256\":null,\"sha256_requires_postprocessor\":true}",complete?"true":"false",held_request,held_generation,held_epoch,commands,accepted,unique_words,coordinate_errors,duplicate_errors,byte_count);
   $fclose(meta_fd);
   $display("M007_ACTUAL_PUBLIC_CAPTURE complete=%0d accepts=%0d unique=%0d bytes=%0d prefix=%s",complete,accepted,unique_words,byte_count,prefix);$fflush();
  end
 endtask
endmodule
