module tanh_libm_stream_wrapper(
 input wire clk,reset,
 input wire in_valid,output wire in_ready,
 input wire [31:0] in_data,in_tag,
 output wire out_valid,input wire out_ready,
 output wire [31:0] out_data,out_tag,out_status
);
 reg [31:0] result_mem[0:511],tag_mem[0:511],status_mem[0:511];
 reg [8:0] reserve_ptr,produce_ptr,consume_ptr;
 reg [9:0] credits,returned;
 wire ready,idle,done,result_valid,status_valid;
 wire [31:0] leaf_result,leaf_status;
 wire start=in_valid && !reset && credits<512;
 wire accept=in_valid && in_ready;
 wire consume=out_valid && out_ready;
 assign in_ready=!reset && credits<512 && ready;
 assign out_valid=!reset && returned!=0;
 assign out_data=result_mem[consume_ptr];
 assign out_tag=tag_mem[consume_ptr];
 assign out_status=status_mem[consume_ptr];
 tanh_libm_stream_leaf leaf(.ap_clk(clk),.ap_rst(reset),.ap_start(start),
   .ap_ready(ready),.ap_idle(idle),.ap_done(done),.x(in_data),
   .result(leaf_result),.result_ap_vld(result_valid),
   .status(leaf_status),.status_ap_vld(status_valid));
 always @(posedge clk) begin
  if(reset) begin
   reserve_ptr<=0; produce_ptr<=0; consume_ptr<=0; credits<=0; returned<=0;
  end else begin
   case({accept,consume})
    2'b10: credits<=credits+1;
    2'b01: credits<=credits-1;
   endcase
   case({result_valid,consume})
    2'b10: returned<=returned+1;
    2'b01: returned<=returned-1;
   endcase
   if(accept) begin
    tag_mem[reserve_ptr]<=in_tag;
    status_mem[reserve_ptr]<=(in_data&32'h7fffffff)>=32'h7f800000 ? 1:0;
    reserve_ptr<=reserve_ptr+1;
   end
   if(result_valid) begin
    result_mem[produce_ptr]<=leaf_result; produce_ptr<=produce_ptr+1;
   end
   if(consume) consume_ptr<=consume_ptr+1;
  end
 end
endmodule
