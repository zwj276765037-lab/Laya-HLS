`timescale 1ns/1ps
// Observation only: actual accepted public source and final output bytes.
// Partial files remain explicitly incomplete and cannot qualify a later chain.
// Byte indexing is lane then bit: the outer packed dimension is 32-bit lanes.
module m007_public_f32_capture_tb_v2(
 input logic clk,rst_n,command_fire,
 input logic[63:0]request_id,input logic[31:0]generation,source_epoch,
 input logic[4:0]layer_index,input logic[2:0]kind,
 input logic input_fire,input logic[7:0]input_row,input_group,
 input logic[31:0][31:0]input_data,
 input logic output_fire,input logic[6:0]row,input logic[15:0]col,
 input logic[31:0][31:0]data,
 input logic receipt_fire,input logic[7:0]receipt_status,receipt_source_status,
 input logic[2:0]receipt_domain,input logic[95:0]receipt_tuple,
 input logic all_resources_retired
);
 logic[4095:0]seen,input_seen;
 logic[63:0]held_request;logic[31:0]held_generation,held_epoch;logic[4:0]held_layer;logic[2:0]held_kind;
 integer accepted=0,unique_words=0,coordinate_errors=0,duplicate_errors=0,commands=0,cycle=0;
 integer input_accepted=0,input_unique=0,input_errors=0,receipts=0,successful_receipts=0,terminal_cycle=-1;
 integer trace_fd=0,input_trace_fd=0,data_fd=0,input_data_fd=0;
 string prefix;
 initial begin
  if(!$value$plusargs("EXPORT=%s",prefix))prefix="actual_public_output";
  trace_fd=$fopen({prefix,".accepted.jsonl"},"w");input_trace_fd=$fopen({prefix,".input.accepted.jsonl"},"w");
  data_fd=$fopen({prefix,".f32.bin"},"wb");input_data_fd=$fopen({prefix,".input.f32.bin"},"wb");
  if(!trace_fd||!input_trace_fd||!data_fd||!input_data_fd)$fatal(1,"actual public capture files could not open");
 end
 always@(posedge clk)begin
  cycle++;
  if(!rst_n)begin seen=0;input_seen=0;accepted=0;unique_words=0;coordinate_errors=0;duplicate_errors=0;commands=0;input_accepted=0;input_unique=0;input_errors=0;receipts=0;successful_receipts=0;terminal_cycle=-1;held_request=0;held_generation=0;held_epoch=0;held_layer=0;held_kind=0;end
  else begin
   if(command_fire)begin commands++;held_request=request_id;held_generation=generation;held_epoch=source_epoch;held_layer=layer_index;held_kind=kind;end
   if(input_fire)begin
    int address;address=int'(input_row)*32+int'(input_group);
    $fdisplay(input_trace_fd,"{\"accept_seq\":%0d,\"cycle\":%0d,\"request_hex\":\"%016h\",\"generation\":%0d,\"source_epoch\":%0d,\"row\":%0d,\"col\":%0d,\"data_hex_lane0_lsb\":\"%0256h\"}",input_accepted,cycle,held_request,held_generation,held_epoch,input_row,int'(input_group)*32,input_data);
    input_accepted++;
    if(input_row>=128||input_group>=32||input_seen[address])input_errors++;
    else begin
     input_seen[address]=1;input_unique++;
     if($fseek(input_data_fd,address*128,0)!=0)$fatal(1,"actual input binary coordinate seek");
     for(int lane=0;lane<32;lane++)for(int octet=0;octet<4;octet++)$fwrite(input_data_fd,"%c",input_data[lane][8*octet+:8]);
    end
   end
   if(output_fire)begin
    int address;address=int'(row)*32+int'(col)/32;
    $fdisplay(trace_fd,"{\"accept_seq\":%0d,\"cycle\":%0d,\"request_hex\":\"%016h\",\"generation\":%0d,\"source_epoch\":%0d,\"row\":%0d,\"col\":%0d,\"data_hex_lane0_lsb\":\"%0256h\"}",accepted,cycle,held_request,held_generation,held_epoch,row,col,data);
    accepted++;
    if(col>=1024||col[4:0]!=0)coordinate_errors++;
    else if(seen[address])duplicate_errors++;
    else begin
     seen[address]=1;unique_words++;
     if($fseek(data_fd,address*128,0)!=0)$fatal(1,"actual output binary coordinate seek");
     for(int lane=0;lane<32;lane++)for(int octet=0;octet<4;octet++)$fwrite(data_fd,"%c",data[lane][8*octet+:8]);
    end
   end
   if(receipt_fire)begin
    receipts++;terminal_cycle=cycle;
    if(receipt_status==0&&receipt_source_status==0&&receipt_domain==0&&receipt_tuple==0&&all_resources_retired)successful_receipts++;
   end
  end
 end
 task automatic finish_capture(input logic full_functional_success);
  integer meta_fd;logic complete;
  begin
   complete=full_functional_success&&commands==1&&accepted==4096&&unique_words==4096&&coordinate_errors==0&&duplicate_errors==0&&(&seen)&&input_accepted==4096&&input_unique==4096&&input_errors==0&&(&input_seen)&&receipts==1&&successful_receipts==1&&all_resources_retired;
   $fflush(trace_fd);$fflush(input_trace_fd);$fflush(data_fd);$fflush(input_data_fd);
   $fclose(trace_fd);$fclose(input_trace_fd);$fclose(data_fd);$fclose(input_data_fd);
   meta_fd=$fopen({prefix,".capture.json"},"w");if(!meta_fd)$fatal(1,"actual capture metadata could not open");
   $fdisplay(meta_fd,"{\"schema\":\"m007-observed-public-f32-v2\",\"provenance\":\"binary bytes written directly from actual public accepted handshakes; no DUT drive or gold reconstruction\",\"complete\":%s,\"request_hex\":\"%016h\",\"generation\":%0d,\"source_epoch\":%0d,\"layer\":%0d,\"kind\":%0d,\"commands\":%0d,\"accepted_groups32\":%0d,\"unique_groups32\":%0d,\"coordinate_errors\":%0d,\"duplicate_errors\":%0d,\"input_accepted_groups32\":%0d,\"input_unique_groups32\":%0d,\"input_errors\":%0d,\"parent_receipts_consumed\":%0d,\"successful_parent_receipts_consumed\":%0d,\"actual_terminal_cycle\":%0d,\"all_resources_retired\":%s,\"shape\":[1,128,1024],\"serialization\":\"row-major,lane0-first,F32bits-little-endian\",\"complete_bytes\":524288,\"sha256_requires_postprocessor\":true}",complete?"true":"false",held_request,held_generation,held_epoch,held_layer,held_kind,commands,accepted,unique_words,coordinate_errors,duplicate_errors,input_accepted,input_unique,input_errors,receipts,successful_receipts,terminal_cycle,all_resources_retired?"true":"false");
   $fclose(meta_fd);
   $display("M007_ACTUAL_PUBLIC_CAPTURE complete=%0d output=%0d input=%0d terminal=%0d prefix=%s",complete,accepted,input_accepted,terminal_cycle,prefix);$fflush();
  end
 endtask
endmodule
