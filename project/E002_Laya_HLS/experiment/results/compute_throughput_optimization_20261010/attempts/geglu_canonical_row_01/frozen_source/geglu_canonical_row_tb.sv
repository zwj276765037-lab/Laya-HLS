`timescale 1ns/1ps
module geglu_canonical_row_tb;
 reg clk=0;always #3.333333 clk=~clk;
 reg reset=1,cmd_valid=0,wi_valid=0,wi_row_done_valid=0,v_ready=0,row_write_done_valid=0,done_ready=0;
 wire cmd_ready,cmd_reject,wi_ready,wi_row_done_ready,v_valid,v_last,row_success,row_write_done_ready,done_valid;
 reg [671:0] cmd_numeric_identity=0,wi_numeric_identity=0;
 reg [95:0] cmd_producer_context=0,cmd_quant_context=0,cmd_consumer_context=0;
 reg [63:0] cmd_source_ref=0,cmd_a_ref=0,cmd_w_ref=0,cmd_dst_ref=0,wi_source_ref=0;
 reg [7:0] cmd_region=0,cmd_batch=0,cmd_a_slot=0;
 reg [12:0] cmd_k=2624,wi_index=0;
 reg [4:0] cmd_rows=1;reg [15:0] cmd_row0=7,wi_row=0;
 reg [31:0] cmd_a_slot_epoch=0,wi_data=0,wi_status=0,wi_row_done_status=0;
 reg [63:0] wi_row_bad_element=0;
 reg wi_read_debt_zero=1;
 reg [31:0] row_write_status=0,row_write_task_id=0,row_write_dst_epoch=0;
 reg [15:0] row_write_row=0;reg [63:0] row_write_bad_element=0;reg row_write_debt_zero=1;
 wire [671:0] bound_numeric_identity;
 wire [95:0] bound_producer_context,bound_quant_context,bound_consumer_context;
 wire [63:0] bound_source_ref,bound_a_ref,bound_w_ref,bound_dst_ref;
 wire [7:0] bound_region,bound_batch,bound_a_slot;
 wire [31:0] bound_a_slot_epoch;
 wire [12:0] bound_k;wire [4:0] bound_rows;wire [15:0] bound_row0;
 wire [31:0] v_data,v_status,v_frame_tag,done_status;
 wire [15:0] v_row,row_success_row,done_bad_row;wire [12:0] v_col;
 wire [63:0] done_bad_element;wire arithmetic_debt_zero,local_row_coverage_complete;
 geglu_canonical_row_adapter dut(.*);
 reg [31:0] wi[0:5247],gold[0:26239];
 reg source_valid[0:1023];integer source_col[0:1023];
 integer cycle=0,mode=0,pilot=0,issued_count=0,returned_count=0,emitted=0,checked_steps=0;
 integer row_outputs=0,row_steps=0,first_issue=0,last_commit=0,first_output=0,last_output=0;
 integer credit_peak=0,i,j,expected_status=0;
 reg check_numeric=0,stalled=0;
 reg [125:0] stalled_payload;
 reg [95:0] saved_producer,saved_quant,saved_consumer;
 reg [671:0] saved_identity;
 reg [255:0] saved_refs;
 string wf,sf;
 always @(negedge clk) begin
  if(reset||mode==2)v_ready<=0;
  else if(mode==1)v_ready<=((cycle%17)>=6 && (cycle%53)>=9);
  else v_ready<=1;
  if(!reset && dut.state!=dut.IDLE) begin
   if({bound_numeric_identity,bound_producer_context,bound_quant_context,bound_consumer_context,
       bound_source_ref,bound_a_ref,bound_w_ref,bound_dst_ref}!==
      {saved_identity,saved_producer,saved_quant,saved_consumer,saved_refs})
    $fatal(1,"GEGLU_CANONICAL_CHANGED_RESIDENT_COMMAND");
   if(dut.credits>512 || dut.returned>dut.issued)$fatal(1,"GEGLU_CANONICAL_CREDIT_BOUND");
   if(dut.state==dut.RUN && dut.credits!==dut.issued-dut.returned)$fatal(1,"GEGLU_CANONICAL_CREDIT_CONSERVATION");
   if(dut.credits>credit_peak)credit_peak=dut.credits;
  end
 end
 task check_step(input integer step,input integer sample_edge,input [31:0] result);
  integer src,col;
  begin
   src=(cycle-sample_edge)%1024;
   if(check_numeric && cycle>=sample_edge && source_valid[src])begin
    col=source_col[src];
    if(result!==gold[10*col+step])
     $fatal(1,"GEGLU_CANONICAL_STEP_FAIL row=%0d col=%0d step=%0d got=%08x gold=%08x",dut.current_row,col,step,result,gold[10*col+step]);
    checked_steps=checked_steps+1;row_steps=row_steps+1;
   end
  end
 endtask
 always @(posedge clk) begin
  cycle=cycle+1;if(cycle>40000000)$fatal(1,"GEGLU_CANONICAL_CYCLE_CAP");
  if(reset)begin stalled=0;for(integer k=0;k<1024;k=k+1)source_valid[k]=0;end
  else begin
   source_valid[cycle%1024]=dut.arithmetic_accept;
   source_col[cycle%1024]=dut.issued;
   if(dut.arithmetic_accept)begin
    if(dut.loaded!=5248||dut.source_fault)$fatal(1,"GEGLU_CANONICAL_EARLY_ARITHMETIC");
    issued_count=issued_count+1;if(!first_issue)first_issue=cycle;
   end
   check_step(0,16,dut.arithmetic.mul100);
   check_step(1,31,dut.arithmetic.mul101);
   check_step(2,38,dut.arithmetic.add100);
   check_step(3,53,dut.arithmetic.mul102);
   check_step(4,68,dut.arithmetic.mul103);
   check_step(5,453,dut.arithmetic.h);
   check_step(6,460,dut.arithmetic.add101);
   check_step(7,475,dut.arithmetic.mul104);
   check_step(8,490,dut.arithmetic.mul105);
   check_step(9,505,dut.arithmetic.mul106);
   if(dut.arithmetic.tanh_commit_valid!==dut.arithmetic.valid_pipe[452])$fatal(1,"GEGLU_CANONICAL_TANH_TOKEN_ALIGNMENT");
   if(dut.core_commit)begin
    if(dut.credits==0||dut.returned>=dut.issued)$fatal(1,"GEGLU_CANONICAL_UNRESERVED_RETURN");
    returned_count=returned_count+1;last_commit=cycle;
    if(check_numeric && (dut.core_status!==0 || dut.core_failed!==32'hffffffff ||
       dut.core_data!==gold[10*dut.returned+9]))$fatal(1,"GEGLU_CANONICAL_CORE_RESULT");
    if((returned_count%128)==0)$display("TANH_PROGRESS geglu_canonical returned=%0d checked_steps=%0d cycle=%0d",returned_count,checked_steps,cycle);
   end
   if(row_success || v_valid)begin
    if(!arithmetic_debt_zero || !local_row_coverage_complete || dut.returned!=2624 ||
       dut.numeric_fault || dut.loaded!=5248 || dut.issued!=2624)
     $fatal(1,"GEGLU_CANONICAL_PREFIX_PUBLICATION");
   end
   if(stalled && (!v_valid || {v_data,v_status,v_frame_tag,v_row,v_col,v_last}!==stalled_payload))
    $fatal(1,"GEGLU_CANONICAL_UNSTABLE_ROW_OUTPUT");
   stalled=v_valid&&!v_ready;
   if(stalled)stalled_payload={v_data,v_status,v_frame_tag,v_row,v_col,v_last};
   if(v_valid&&v_ready)begin
    if(!check_numeric || expected_status!=0 || v_status!==0 || v_frame_tag!==saved_producer[31:0] ||
       v_row!==dut.current_row || v_col!==row_outputs || v_last!==(row_outputs==2623))
     $fatal(1,"GEGLU_CANONICAL_OUTPUT_METADATA");
    if(v_data!==gold[10*row_outputs+9])$fatal(1,"GEGLU_CANONICAL_GATE_OUTPUT");
    if(!first_output)first_output=cycle;
    row_outputs=row_outputs+1;emitted=emitted+1;last_output=cycle;
   end
  end
 end
 task prepare(input integer rows,input integer md,input integer ep,input integer expected);
  begin
   mode=md;expected_status=expected;check_numeric=expected==0;
   issued_count=0;returned_count=0;emitted=0;checked_steps=0;row_outputs=0;row_steps=0;
   first_issue=0;last_commit=0;first_output=0;last_output=0;credit_peak=0;
   cmd_rows=rows;cmd_row0=7;cmd_region=1;cmd_batch=0;cmd_k=2624;cmd_a_slot=0;cmd_a_slot_epoch=ep+10;
   cmd_numeric_identity={128'h445566,128'habcdef,128'h012345,128'h667788,16'd128,16'd1,64'(ep),64'habcddcba};
   cmd_producer_context={8'(rows),16'd7,8'd0,8'd0,8'd0,8'd2,8'h60,32'(ep)};
   cmd_quant_context={8'(rows),16'd7,8'd0,8'd0,8'd0,8'd2,8'h20,32'(ep+1)};
   cmd_consumer_context={8'(rows),16'd7,8'd0,8'd0,8'd0,8'd2,8'h33,32'(ep+2)};
   cmd_source_ref={8'd0,8'd1,8'd0,8'd6,32'(ep+1)};
   cmd_a_ref={8'd0,8'd2,8'd0,8'd22,32'(ep+2)};
   cmd_w_ref={8'd0,8'd0,8'd0,8'd0,32'(ep+3)};
   cmd_dst_ref={8'd0,8'd1,8'd0,8'd7,32'(ep+4)};
   saved_identity=cmd_numeric_identity;saved_producer=cmd_producer_context;
   saved_quant=cmd_quant_context;saved_consumer=cmd_consumer_context;
   saved_refs={cmd_source_ref,cmd_a_ref,cmd_w_ref,cmd_dst_ref};
   @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);
   @(negedge clk);cmd_valid=0;
  end
 endtask
 task load_row(input integer row,input integer bad_kind,input integer bad_col);
  begin
   wi_numeric_identity=saved_identity;wi_source_ref=cmd_source_ref;wi_row=row;
   wi_status=0;wi_row_done_status=0;wi_read_debt_zero=1;
   for(i=0;i<5248;i=i+1)begin
    @(negedge clk);wi_valid=1;wi_index=i;
    wi_data=((bad_kind==1||bad_kind==6) && i==bad_col)?32'h7fc00001:
            (((bad_kind==2||bad_kind==6) && i==2624+bad_col)?32'h7fc00001:wi[i]);
    if(bad_kind==3 && i==bad_col)wi_index=i+1;
    wi_numeric_identity=(bad_kind==4 && i==bad_col)?saved_identity^(672'b1<<500):saved_identity;
    wi_source_ref=(bad_kind==5 && i==bad_col)?cmd_source_ref^64'b1:cmd_source_ref;
    do @(posedge clk);while(!wi_ready);
   end
   @(negedge clk);wi_valid=0;wi_read_debt_zero=0;wi_row_done_valid=1;
   repeat(9)begin @(posedge clk);if(wi_row_done_ready||dut.arithmetic_accept||row_success)$fatal(1,"GEGLU_CANONICAL_SOURCE_READ_DEBT");end
   @(negedge clk);wi_read_debt_zero=1;
   do @(posedge clk);while(!wi_row_done_ready);
   @(negedge clk);wi_row_done_valid=0;
  end
 endtask
 task acknowledge_write(input integer row,input integer expected_rows);
  begin
   wait(row_outputs==2624);@(negedge clk);
   if(row_steps!=26240||!row_write_done_ready||!row_success)$fatal(1,"GEGLU_CANONICAL_INCOMPLETE_ROW");
   row_write_task_id=saved_producer[31:0];row_write_dst_epoch=cmd_dst_ref[31:0];
   row_write_row=row;row_write_status=0;row_write_bad_element=0;
   row_write_done_valid=0;
   repeat(11)begin @(posedge clk);if(done_valid||wi_ready)$fatal(1,"GEGLU_CANONICAL_BEFORE_PHYSICAL_WRITE_ACK");end
   @(negedge clk);row_write_debt_zero=1;row_write_done_valid=1;
   do @(posedge clk);while(!row_write_done_ready);
   @(negedge clk);row_write_done_valid=0;
   row_outputs=0;row_steps=0;
  end
 endtask
 task retire(input integer status,input integer bad,input integer row);
  begin
   wait(done_valid);@(negedge clk);
   if(done_status!==status || done_bad_element!==64'(bad) ||
      (status!=0 && done_bad_row!==row) || !arithmetic_debt_zero)
    $fatal(1,"GEGLU_CANONICAL_DONE status=%0d/%0d bad=%0d/%0d row=%0d/%0d",done_status,status,done_bad_element,bad,done_bad_row,row);
   repeat(5)begin @(posedge clk);if(!done_valid||cmd_ready||v_valid)$fatal(1,"GEGLU_CANONICAL_DONE_HOLD");end
   @(negedge clk);done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;check_numeric=0;
  end
 endtask
 task profile(input integer md,input integer rows,input integer epoch);
  begin
   prepare(rows,md,epoch,0);
   for(j=0;j<rows;j=j+1)begin load_row(7+j,0,0);acknowledge_write(7+j,rows);end
   retire(0,0,7);
   if(issued_count!=rows*2624 || returned_count!=rows*2624 || emitted!=rows*2624 || checked_steps!=rows*26240)
    $fatal(1,"GEGLU_CANONICAL_FULL_COMMAND_DEBT");
   $display("GEGLU_CANONICAL_ROW_PROFILE_PASS mode=%0d rows=%0d inputs=%0d outputs=%0d step_checks=%0d first_issue=%0d last_commit=%0d first_output=%0d last_output=%0d peak_credit=%0d",md,rows,rows*5248,emitted,checked_steps,first_issue,last_commit,first_output,last_output,credit_peak);
  end
 endtask
 task clean_reset;
  begin
   @(negedge clk);reset=1;cmd_valid=0;wi_valid=0;wi_row_done_valid=0;row_write_done_valid=0;done_ready=0;check_numeric=0;
   repeat(4)@(negedge clk);reset=0;
   repeat(600)begin @(posedge clk);if(v_valid||done_valid||row_success||dut.core_commit)$fatal(1,"GEGLU_CANONICAL_OLD_EPOCH");end
  end
 endtask
 initial begin
  if(!$value$plusargs("WI_FILE=%s",wf)||!$value$plusargs("STEP_FILE=%s",sf))$fatal(1,"GEGLU_CANONICAL_MISSING_FIXTURE");
  if($value$plusargs("PILOT=%d",pilot))begin end
  $readmemh(wf,wi);$readmemh(sf,gold);
  for(i=0;i<5248;i=i+1)if($isunknown(wi[i]))$fatal(1,"GEGLU_CANONICAL_UNKNOWN_WI");
  for(i=0;i<26240;i=i+1)if($isunknown(gold[i]))$fatal(1,"GEGLU_CANONICAL_UNKNOWN_GOLD");
  clean_reset();
  if(pilot)begin
   prepare(1,0,1,0);load_row(7,0,0);wait(returned_count==128);@(negedge clk);
   $display("GEGLU_CANONICAL_ROW_PILOT_PASS complete_wi=5248 returns=128 original_steps=1");$finish;
  end
  // Malformed command cannot acquire an active row or index RAM.
  @(negedge clk);cmd_valid=1;cmd_k=256;
  repeat(4)begin @(posedge clk);if(cmd_ready||!cmd_reject||wi_ready||v_valid)$fatal(1,"GEGLU_CANONICAL_BAD_COMMAND");end
  @(negedge clk);cmd_valid=0;
  prepare(1,0,2,2);load_row(7,3,31);retire(2,31,7);
  prepare(1,0,20,2);load_row(7,4,5200);retire(2,5200,7);
  prepare(1,0,21,2);load_row(7,5,31);retire(2,31,7);
  prepare(1,0,3,1);load_row(7,2,2623);retire(1,5247,7);
  if(emitted!=0)$fatal(1,"GEGLU_CANONICAL_LATE_G_ERROR_PUBLISHED");
  prepare(1,0,4,1);load_row(7,1,2623);retire(1,2623,7);
  if(emitted!=0)$fatal(1,"GEGLU_CANONICAL_LATE_U_ERROR_PUBLISHED");
  prepare(1,0,22,1);load_row(7,6,2623);retire(1,5247,7);
  prepare(1,0,23,0);
  wi_numeric_identity=saved_identity;wi_source_ref=cmd_source_ref;wi_row=7;wi_status=0;
  for(i=0;i<31;i=i+1)begin
   @(negedge clk);wi_valid=1;wi_index=i;wi_data=wi[i];
   do @(posedge clk);while(!wi_ready);
  end
  clean_reset();
  prepare(1,0,5,0);load_row(7,0,0);wait(dut.issued==128);clean_reset();
  prepare(1,2,6,0);load_row(7,0,0);wait(v_valid);repeat(20)@(posedge clk);clean_reset();
  profile(0,1,7);profile(1,1,8);profile(1,4,9);
  $display("GEGLU_CANONICAL_ROW_RTL_PASS full_rows=6 full_inputs=31488 full_outputs=15744 independent_step_checks=157440 loading_protocol=1 full_identity_reject=1 old_ref_reject=1 late_g=1 late_u=1 g_before_u=1 reset_loading=1 reset_inflight=1 reset_pending=1 physical_writer_ack_diagnostic_only=1 cycles=%0d",cycle);
  $finish;
 end
endmodule
