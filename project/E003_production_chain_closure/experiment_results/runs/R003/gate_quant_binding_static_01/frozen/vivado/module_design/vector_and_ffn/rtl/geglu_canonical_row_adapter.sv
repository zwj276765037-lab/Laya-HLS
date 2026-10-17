// §7.3.3: one resident full command, complete WI capture, complete gate row barrier.
// Physical GATE writes, B responses and task owner publication belong to production.
module geglu_canonical_row_adapter(
 input wire clk,reset,
 input wire cmd_valid,output wire cmd_ready,output wire cmd_reject,
 input wire [671:0] cmd_numeric_identity,
 input wire [95:0] cmd_producer_context,cmd_quant_context,cmd_consumer_context,
 input wire [63:0] cmd_source_ref,cmd_a_ref,cmd_w_ref,cmd_dst_ref,
 input wire [7:0] cmd_region,cmd_batch,
 input wire [12:0] cmd_k,input wire [4:0] cmd_rows,input wire [15:0] cmd_row0,
 input wire [7:0] cmd_a_slot,input wire [31:0] cmd_a_slot_epoch,
 output reg [671:0] bound_numeric_identity,
 output reg [95:0] bound_producer_context,bound_quant_context,bound_consumer_context,
 output reg [63:0] bound_source_ref,bound_a_ref,bound_w_ref,bound_dst_ref,
 output reg [7:0] bound_region,bound_batch,bound_a_slot,
 output reg [31:0] bound_a_slot_epoch,
 output reg [12:0] bound_k,output reg [4:0] bound_rows,output reg [15:0] bound_row0,
 input wire wi_valid,output wire wi_ready,input wire [31:0] wi_data,wi_status,
 input wire [671:0] wi_numeric_identity,input wire [63:0] wi_source_ref,
 input wire [15:0] wi_row,input wire [12:0] wi_index,
 input wire wi_row_done_valid,output wire wi_row_done_ready,
 input wire [31:0] wi_row_done_status,input wire [63:0] wi_row_bad_element,
 input wire wi_read_debt_zero,
 output wire row_success,output wire [15:0] row_success_row,
 output wire v_valid,input wire v_ready,
 output wire [31:0] v_data,v_status,v_frame_tag,
 output wire [15:0] v_row,output wire [12:0] v_col,output wire v_last,
 input wire row_write_done_valid,output wire row_write_done_ready,
 input wire [31:0] row_write_status,row_write_task_id,row_write_dst_epoch,
 input wire [15:0] row_write_row,input wire [63:0] row_write_bad_element,
 input wire row_write_debt_zero,
 output wire done_valid,input wire done_ready,
 output reg [31:0] done_status,output reg [63:0] done_bad_element,
 output reg [15:0] done_bad_row,
 output wire arithmetic_debt_zero,output wire local_row_coverage_complete
);
 localparam IDLE=0,LOAD=1,PREP=2,RUN=3,EMIT=4,WAIT_WRITE=5,DONE=6;
 reg [2:0] state;
 reg operand_valid,emit_slot_valid;
 reg [12:0] operand_index;
 reg [31:0] row_generation,operand_generation,emit_generation;
 reg [12:0] loaded,issued,returned,emit_col;
 reg [3:0] row_local;
 reg [9:0] credits;
 wire [31:0] x_operand,g_operand,emit_data;
 reg source_fault,numeric_fault;
 reg [31:0] source_fault_status;
 reg [63:0] source_fault_element;
 reg [2623:0] gate_coverage;
 wire [15:0] current_row=bound_row0+row_local;
 wire legal_command=cmd_k==2624 && cmd_rows>=1 && cmd_rows<=16 &&
  {1'b0,cmd_row0}+cmd_rows<=17'd65536 &&
  cmd_producer_context[39:32]==8'h60 && cmd_producer_context[47:40]==8'd2 &&
  cmd_producer_context[71:64]==0 && cmd_producer_context[63:56]==cmd_batch &&
  cmd_producer_context[87:72]==cmd_row0 && cmd_producer_context[95:88]==cmd_rows &&
  cmd_source_ref[39:32]==8'd6 && cmd_dst_ref[39:32]==8'd7 &&
  cmd_source_ref[55:48]==cmd_region && cmd_dst_ref[55:48]==cmd_region;
 assign cmd_ready=!reset && state==IDLE && legal_command;
 assign cmd_reject=!reset && state==IDLE && cmd_valid && !legal_command;
 assign wi_ready=!reset && state==LOAD && loaded<5248;
 assign wi_row_done_ready=!reset && state==LOAD && loaded==5248 && wi_read_debt_zero;
 wire wi_match=wi_numeric_identity==bound_numeric_identity && wi_source_ref==bound_source_ref &&
  wi_row==current_row && wi_index==loaded && wi_index<5248;
 wire core_commit;
 wire [31:0] core_data,core_status,core_failed;
 wire arithmetic_accept=!reset && state==RUN && operand_valid &&
  operand_generation==row_generation && operand_index==issued &&
  !numeric_fault && issued<2624 && credits<512 &&
  !(core_commit && core_status!=0);
 wire [10:0] next_credits={1'b0,credits}+arithmetic_accept-core_commit;
 wire capture_word=!reset && wi_valid && wi_ready && wi_match && wi_status==0;
 wire u_wr_en=capture_word && loaded<2624;
 wire g_wr_en=capture_word && loaded>=2624;
 wire [11:0] capture_addr=loaded<2624 ? loaded[11:0] : loaded-13'd2624;
 wire operand_rd_en=!reset && (state==PREP || (arithmetic_accept && issued<2623));
 wire [11:0] operand_rd_addr=state==PREP ? 12'd0 : issued+13'd1;
 wire core_return_legal=state==RUN && credits!=0 && returned<2624 && !gate_coverage[returned];
 wire gate_wr_en=!reset && core_commit && core_return_legal && core_status==0;
 wire complete_commit=!reset && state==RUN && core_commit && core_return_legal &&
  core_status==0 && returned==2623 && issued==2624 && next_credits==0 &&
  !numeric_fault && (&gate_coverage[2622:0]);
 wire gate_rd_en=!reset && (complete_commit || (v_valid && v_ready && emit_col<2623));
 wire [11:0] gate_rd_addr=complete_commit ? 12'd0 : emit_col+13'd1;
 geglu_row_bank_v1 u_bank(.clk(clk),.wr_en(u_wr_en),.wr_addr(capture_addr),.wr_data(wi_data),
  .rd_en(operand_rd_en),.rd_addr(operand_rd_addr),.q(x_operand));
 geglu_row_bank_v1 g_bank(.clk(clk),.wr_en(g_wr_en),.wr_addr(capture_addr),.wr_data(wi_data),
  .rd_en(operand_rd_en),.rd_addr(operand_rd_addr),.q(g_operand));
 geglu_row_bank_v1 gate_bank(.clk(clk),.wr_en(gate_wr_en),.wr_addr(returned[11:0]),.wr_data(core_data),
  .rd_en(gate_rd_en),.rd_addr(gate_rd_addr),.q(emit_data));
 geglu_canonical_core arithmetic(.clk(clk),.reset(reset),.in_valid(arithmetic_accept),
  .in_x(x_operand),.in_g(g_operand),.commit_valid(core_commit),
  .data(core_data),.status(core_status),.failed(core_failed));
 assign arithmetic_debt_zero=!reset && credits==0;
 assign local_row_coverage_complete=!reset && returned==2624 && (&gate_coverage) && credits==0 && !numeric_fault;
 assign row_success=!reset && (state==EMIT || state==WAIT_WRITE) && local_row_coverage_complete;
 assign row_success_row=current_row;
 assign v_valid=!reset && state==EMIT && emit_slot_valid && emit_generation==row_generation;
 assign v_data=emit_data;assign v_status=0;
 assign v_frame_tag=bound_producer_context[31:0];
 assign v_row=current_row;assign v_col=emit_col;assign v_last=emit_col==2623;
 assign row_write_done_ready=!reset && state==WAIT_WRITE && credits==0 && !operand_valid && !emit_slot_valid;
 assign done_valid=!reset && state==DONE;
 always @(posedge clk) begin
  if(reset) begin
   state<=IDLE;loaded<=0;issued<=0;returned<=0;emit_col<=0;row_local<=0;credits<=0;
   operand_valid<=0;emit_slot_valid<=0;operand_index<=0;row_generation<=0;
   operand_generation<=0;emit_generation<=0;
   source_fault<=0;numeric_fault<=0;source_fault_status<=0;source_fault_element<=0;
   gate_coverage<=0;done_status<=0;done_bad_element<=0;done_bad_row<=0;
   bound_numeric_identity<=0;bound_producer_context<=0;bound_quant_context<=0;bound_consumer_context<=0;
   bound_source_ref<=0;bound_a_ref<=0;bound_w_ref<=0;bound_dst_ref<=0;
   bound_region<=0;bound_batch<=0;bound_a_slot<=0;bound_a_slot_epoch<=0;
   bound_k<=0;bound_rows<=0;bound_row0<=0;
  end else begin
   case({arithmetic_accept,core_commit})
    2'b10:credits<=credits+1;
    2'b01:credits<=credits-1;
   endcase
   if(cmd_valid && cmd_ready) begin
    bound_numeric_identity<=cmd_numeric_identity;
    bound_producer_context<=cmd_producer_context;bound_quant_context<=cmd_quant_context;
    bound_consumer_context<=cmd_consumer_context;
    bound_source_ref<=cmd_source_ref;bound_a_ref<=cmd_a_ref;bound_w_ref<=cmd_w_ref;bound_dst_ref<=cmd_dst_ref;
    bound_region<=cmd_region;bound_batch<=cmd_batch;bound_k<=cmd_k;bound_rows<=cmd_rows;bound_row0<=cmd_row0;
    bound_a_slot<=cmd_a_slot;bound_a_slot_epoch<=cmd_a_slot_epoch;
    loaded<=0;issued<=0;returned<=0;emit_col<=0;row_local<=0;credits<=0;gate_coverage<=0;
    source_fault<=0;numeric_fault<=0;done_status<=0;done_bad_element<=0;done_bad_row<=cmd_row0;
    row_generation<=row_generation+1;operand_valid<=0;emit_slot_valid<=0;
    state<=LOAD;
   end
   if(wi_valid && wi_ready) begin
    if(!wi_match || wi_status!=0) begin
     if(!source_fault) begin
      source_fault<=1;source_fault_status<=wi_status!=0?wi_status:32'd2;
      source_fault_element<=loaded;
     end
    end
    loaded<=loaded+1;
   end
   if(wi_row_done_valid && wi_row_done_ready) begin
    if(source_fault || wi_row_done_status!=0) begin
     done_status<=wi_row_done_status!=0?wi_row_done_status:source_fault_status;
     done_bad_element<=wi_row_done_status!=0?wi_row_bad_element:source_fault_element;
     done_bad_row<=current_row;state<=DONE;
    end else state<=PREP;
   end
   if(state==PREP) begin
    operand_valid<=1;operand_index<=0;operand_generation<=row_generation;
    issued<=0;returned<=0;credits<=0;
    gate_coverage<=0;numeric_fault<=0;state<=RUN;
   end
   if(arithmetic_accept) begin
    issued<=issued+1;
    if(issued<2623)operand_index<=issued+1;
    else operand_valid<=0;
   end
   if(core_commit) begin
    returned<=returned+1;
    if(!core_return_legal)begin
     numeric_fault<=1;done_status<=2;done_bad_row<=current_row;done_bad_element<=returned;operand_valid<=0;
    end else if(core_status!=0) begin
     operand_valid<=0;
     if(!numeric_fault) begin
      numeric_fault<=1;done_status<=1;done_bad_row<=current_row;
      done_bad_element<=core_failed==10?64'd2624+returned:returned;
     end
    end else gate_coverage[returned]<=1;
   end
   if(state==RUN && (numeric_fault || (core_commit && (core_status!=0 || !core_return_legal))) && next_credits==0)begin
    operand_valid<=0;state<=DONE;
   end else if(complete_commit) begin
    emit_col<=0;emit_slot_valid<=1;emit_generation<=row_generation;state<=EMIT;
   end
   if(v_valid && v_ready) begin
    if(emit_col==2623)begin emit_slot_valid<=0;state<=WAIT_WRITE;end
    else emit_col<=emit_col+1;
   end
   if(row_write_done_valid && row_write_done_ready) begin
    if(row_write_task_id!=bound_producer_context[31:0] || row_write_dst_epoch!=bound_dst_ref[31:0] ||
       row_write_row!=current_row || !row_write_debt_zero) begin
     done_status<=2;done_bad_element<=0;done_bad_row<=current_row;state<=DONE;
    end else if(row_write_status!=0) begin
     done_status<=row_write_status;done_bad_element<=row_write_bad_element;done_bad_row<=current_row;state<=DONE;
    end else if({1'b0,row_local}+1==bound_rows)begin done_status<=0;done_bad_element<=0;state<=DONE;end
    else begin
     row_local<=row_local+1;loaded<=0;issued<=0;returned<=0;source_fault<=0;numeric_fault<=0;gate_coverage<=0;
     row_generation<=row_generation+1;operand_valid<=0;emit_slot_valid<=0;
     state<=LOAD;
    end
   end
   if(done_valid && done_ready)state<=IDLE;
  end
 end
endmodule
