module geglu_row_wrapper(
 input wire clk,reset,
 input wire in_valid,output wire in_ready,
 input wire [31:0] in_data,in_tag,input wire [12:0] in_index,
 output reg out_valid,input wire out_ready,
 output reg [31:0] out_data,out_tag,out_status,
 output reg [11:0] out_index,output reg out_last,
 output wire trace_valid,output wire [3:0] trace_index,
 output wire [31:0] trace_data,trace_tag,output wire [11:0] trace_column
);
 localparam LOAD=0,PREP=1,RUN=2,RETURN=3;
 reg [1:0] state;
 reg [31:0] u_mem[0:2623],g_mem[0:2623];
 reg [12:0] loaded;
 reg [11:0] column;
 reg [31:0] frame_tag,x_operand,g_operand;
 reg start,seen_result,seen_status;
 reg [31:0] result_hold,status_hold;
 wire done,idle,ready,result_valid,status_valid;
 wire [31:0] result,status;
 wire [3:0] steps_address0;
 wire steps_ce0,steps_we0;
 wire [31:0] steps_d0;
 assign in_ready=!reset && state==LOAD && !out_valid;
 assign trace_valid=!reset && state==RUN && steps_ce0 && steps_we0;
 assign trace_index=steps_address0; assign trace_data=steps_d0;
 assign trace_tag=frame_tag; assign trace_column=column;
 geglu_libm_leaf leaf(.ap_clk(clk),.ap_rst(reset),.ap_start(start),
   .ap_done(done),.ap_idle(idle),.ap_ready(ready),.x(x_operand),.g(g_operand),
   .result(result),.result_ap_vld(result_valid),
   .status(status),.status_ap_vld(status_valid),
   .steps_address0(steps_address0),.steps_ce0(steps_ce0),
   .steps_we0(steps_we0),.steps_d0(steps_d0));
 always @(posedge clk) begin
  if(reset) begin
   state<=LOAD; loaded<=0; column<=0; frame_tag<=0;
   x_operand<=0; g_operand<=0; start<=0; out_valid<=0;
   out_data<=0; out_tag<=0; out_status<=0; out_index<=0; out_last<=0;
   seen_result<=0; seen_status<=0; result_hold<=0; status_hold<=0;
  end else begin
   start<=0;
   if(in_valid&&in_ready) begin
    if(in_index!=loaded || (loaded!=0 && in_tag!=frame_tag)) begin
     state<=RETURN; out_valid<=1; out_data<=0; out_tag<=in_tag;
     out_status<=2; out_index<=0; out_last<=1;
    end else begin
     if(loaded==0) frame_tag<=in_tag;
     if(loaded<2624) u_mem[loaded]<=in_data;
     else g_mem[loaded-2624]<=in_data;
     loaded<=loaded+1;
     if(loaded==5247) begin column<=0; state<=PREP; end
    end
   end
   if(state==PREP) begin
    x_operand<=u_mem[column]; g_operand<=g_mem[column];
    start<=1; state<=RUN; seen_result<=0; seen_status<=0;
   end
   if(state==RUN&&result_valid) begin result_hold<=result; seen_result<=1; end
   if(state==RUN&&status_valid) begin status_hold<=status; seen_status<=1; end
   if(state==RUN&&done) begin
    out_data<=result_valid?result:result_hold;
    out_status<=status_valid?status:status_hold;
    out_tag<=frame_tag; out_index<=column;
    out_last<=column==2623 || (status_valid?status:status_hold)!=0;
    out_valid<=1; state<=RETURN;
   end
   if(out_valid&&out_ready) begin
    out_valid<=0;
    if(out_last) begin loaded<=0; column<=0; state<=LOAD; end
    else begin column<=column+1; state<=PREP; end
   end
  end
 end
endmodule
