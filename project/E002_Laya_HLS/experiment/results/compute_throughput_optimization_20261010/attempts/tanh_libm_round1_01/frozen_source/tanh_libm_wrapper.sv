module tanh_libm_wrapper(
 input wire clk, input wire reset,
 input wire in_valid, output wire in_ready,
 input wire [31:0] in_data, input wire [31:0] in_tag,
 output reg out_valid, input wire out_ready,
 output reg [31:0] out_data, output reg [31:0] out_tag,
 output reg [31:0] out_status
);
 reg busy,start,seen_result,seen_status;
 reg [31:0] operand,tag,result_hold,status_hold;
 wire [31:0] leaf_result,leaf_status;
 wire result_valid,status_valid,done,ready,idle;
 assign in_ready=!reset && !busy && !out_valid;
 tanh_libm_leaf leaf(.ap_clk(clk),.ap_rst(reset),.ap_start(start),
   .ap_done(done),.ap_idle(idle),.ap_ready(ready),.x(operand),
   .result(leaf_result),.result_ap_vld(result_valid),
   .status(leaf_status),.status_ap_vld(status_valid));
 always @(posedge clk) begin
   if(reset) begin
     busy<=0; start<=0; out_valid<=0; seen_result<=0; seen_status<=0;
     operand<=0; tag<=0; result_hold<=0; status_hold<=0;
     out_data<=0; out_tag<=0; out_status<=0;
   end else begin
     start<=0;
     if(out_valid && out_ready) out_valid<=0;
     if(in_valid && in_ready) begin
       operand<=in_data; tag<=in_tag; busy<=1; start<=1;
       seen_result<=0; seen_status<=0;
     end
     if(busy && result_valid) begin result_hold<=leaf_result; seen_result<=1; end
     if(busy && status_valid) begin status_hold<=leaf_status; seen_status<=1; end
     if(busy && done) begin
       busy<=0; out_valid<=1; out_tag<=tag;
       out_data<=result_valid?leaf_result:result_hold;
       out_status<=status_valid?leaf_status:status_hold;
     end
   end
 end
endmodule
