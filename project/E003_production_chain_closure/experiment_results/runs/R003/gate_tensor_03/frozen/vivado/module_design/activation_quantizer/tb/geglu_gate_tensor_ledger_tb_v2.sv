`timescale 1ns/1ps
`default_nettype none
module geglu_gate_tensor_ledger_tb_v2;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic claim_valid,claim_ready,claim_admitted,claim_rejected,claim_plan_admitted;
  logic [671:0] claim_numeric_identity;
  logic [95:0] claim_producer_context,claim_quant_context,claim_linear_context;
  logic [63:0] claim_source_ref,claim_gate_ref,claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref;
  logic [7:0] claim_gate_region,claim_dst_region;
  logic [327:0] claim_output_binding;
  logic window_retire_valid,window_retire_ready,window_retire_error,window_retire_success,window_write_debt_zero;
  logic tensor_published,cancel_done;
  logic [2:0] gate_owner_state;
  logic [7:0] next_window;
  logic [127:0] valid_windows,covered_windows,consumed_windows;
  logic [2047:0] covered_rows;
  logic gate_acquire_valid,gate_acquire_ready,gate_acquire_done,gate_acquire_error;
  logic [671:0] gate_acquire_numeric_identity;
  logic [63:0] gate_acquire_ref;
  logic [6:0] gate_acquire_window;
  logic [551:0] gate_acquire_binding;
  logic gate_release_valid,gate_release_ready,gate_release_done,gate_release_error;
  logic [671:0] gate_release_numeric_identity;
  logic [63:0] gate_release_ref;
  logic [6:0] gate_release_window;
  logic [551:0] gate_release_binding;
  logic gate_release_read_debt_zero;
  logic tensor_release_valid,tensor_release_ready,tensor_release_done,tensor_release_error;
  logic [671:0] tensor_release_numeric_identity;
  logic [63:0] tensor_release_ref;
  logic tensor_release_debt_zero;
  geglu_gate_tensor_ledger_v2 dut(.*);
  int cycles=0,rejects=0,publishes=0,acquires=0,releases=0;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>20000)$fatal(1,"GATE tensor ledger cycle cap");
    if(claim_rejected)rejects++;if(tensor_published)publishes++;
    if(gate_acquire_done && !gate_acquire_error)acquires++;
    if(gate_release_done && !gate_release_error)releases++;
  end
  function automatic logic [551:0] current_binding;
    return {claim_producer_context,claim_quant_context,claim_linear_context,
      claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref,claim_dst_region};
  endfunction
  task automatic prepare(input int request_id,epoch,b,s,window);
    int batch,row;
    batch=window/((s+15)/16);row=(window%((s+15)/16))*16;
    claim_numeric_identity=0;claim_numeric_identity[63:0]=64'(request_id);
    claim_numeric_identity[127:64]=1;claim_numeric_identity[143:128]=16'(b);
    claim_numeric_identity[159:144]=16'(s);
    claim_producer_context=0;claim_producer_context[31:0]=32'(100+window);
    claim_producer_context[39:32]=8'h60;claim_producer_context[47:40]=2;claim_producer_context[55:48]=7;
    claim_producer_context[63:56]=8'(batch);claim_producer_context[71:64]=0;
    claim_producer_context[87:72]=16'(row);claim_producer_context[95:88]=8'(s-row<16?s-row:16);
    claim_quant_context=claim_producer_context;claim_quant_context[31:0]=32'(300+2*window);claim_quant_context[39:32]=8'h20;
    claim_linear_context=claim_producer_context;claim_linear_context[31:0]=32'(301+2*window);claim_linear_context[39:32]=8'h33;
    claim_source_ref=64'h0000000600000001;claim_gate_ref=64'h0000000700000000|64'(epoch);
    claim_a_ref=64'h0000002200000000|64'(window+1);claim_w_ref=64'h0000002300000001;
    claim_ps_ref=64'h0000002400000000|64'(window+1);claim_dst_ref=64'h0000000300000001;
    claim_gate_region=0;claim_dst_region=0;claim_output_binding=328'h123456;
    claim_plan_admitted=1;
  endtask
  task automatic claim(input bit accepted=1);
    #1;if(!claim_ready || claim_admitted!=accepted)$fatal(1,"GATE claim admission expected=%0d window=%0d",accepted,dut.claim_window);
    claim_valid=1;tick();@(negedge clk);claim_valid=0;
    if(!accepted)begin tick();@(negedge clk);end
  endtask
  task automatic retire_window(input bit success=1,input bit should_publish=0);
    window_retire_success=success;window_retire_valid=1;window_write_debt_zero=0;
    repeat(5)begin tick();if(window_retire_ready || tensor_published)$fatal(1,"GATE window retired before final B/debt");end
    @(negedge clk);window_write_debt_zero=1;tick();
    if(window_retire_error==success || tensor_published!=should_publish)
      $fatal(1,"GATE retire status/publication success=%0d error=%0d publish=%0d expected_publish=%0d active_window=%0d next=%0d rows=%0d windows=%0d state=%0d",
        success,window_retire_error,tensor_published,should_publish,dut.active_window,next_window,
        $countones(covered_rows),$countones(covered_windows),gate_owner_state);
    @(negedge clk);window_retire_valid=0;window_write_debt_zero=0;tick();@(negedge clk);
  endtask
  task automatic acquire_window(input int window,input bit accepted=1);
    prepare(claim_numeric_identity[63:0],claim_gate_ref[31:0],claim_numeric_identity[143:128],
      claim_numeric_identity[159:144],window);
    gate_acquire_numeric_identity=claim_numeric_identity;gate_acquire_ref=claim_gate_ref;
    gate_acquire_window=7'(window);gate_acquire_binding=current_binding();gate_acquire_valid=1;tick();
    if(!gate_acquire_done || gate_acquire_error==accepted)$fatal(1,"GATE acquire expected=%0d window=%0d",accepted,window);
    @(negedge clk);gate_acquire_valid=0;
  endtask
  task automatic release_window(input int window);
    gate_release_numeric_identity=gate_acquire_numeric_identity;gate_release_ref=gate_acquire_ref;
    gate_release_window=7'(window);gate_release_binding=gate_acquire_binding;gate_release_valid=1;
    gate_release_read_debt_zero=0;
    repeat(6)begin tick();if(gate_release_ready || gate_release_done)$fatal(1,"GATE read lease released with debt");end
    @(negedge clk);gate_release_read_debt_zero=1;tick();
    if(!gate_release_done || gate_release_error)$fatal(1,"GATE release failed");
    @(negedge clk);gate_release_valid=0;gate_release_read_debt_zero=0;tick();@(negedge clk);
  endtask
  task automatic release_tensor;
    tensor_release_numeric_identity=claim_numeric_identity;tensor_release_ref=claim_gate_ref;
    tensor_release_valid=1;tensor_release_debt_zero=0;
    repeat(4)begin tick();if(tensor_release_ready || tensor_release_done)$fatal(1,"GATE tensor release ignored debt");end
    @(negedge clk);tensor_release_debt_zero=1;tick();
    if(!tensor_release_done || tensor_release_error || gate_owner_state!=0)$fatal(1,"GATE tensor release");
    @(negedge clk);tensor_release_valid=0;tensor_release_debt_zero=0;tick();@(negedge clk);
  endtask
  initial begin
    claim_valid=0;claim_plan_admitted=0;claim_numeric_identity=0;claim_producer_context=0;claim_quant_context=0;claim_linear_context=0;
    claim_source_ref=0;claim_gate_ref=0;claim_a_ref=0;claim_w_ref=0;claim_ps_ref=0;claim_dst_ref=0;
    claim_gate_region=0;claim_dst_region=0;claim_output_binding=0;window_retire_valid=0;window_retire_success=0;window_write_debt_zero=0;
    gate_acquire_valid=0;gate_acquire_numeric_identity=0;gate_acquire_ref=0;gate_acquire_window=0;gate_acquire_binding=0;
    gate_release_valid=0;gate_release_numeric_identity=0;gate_release_ref=0;gate_release_window=0;gate_release_binding=0;gate_release_read_debt_zero=0;
    tensor_release_valid=0;tensor_release_numeric_identity=0;tensor_release_ref=0;tensor_release_debt_zero=0;
    repeat(5)tick();@(negedge clk);rst_n=1;tick();
    // Eight windows share one Ref/epoch. The true final debt publishes once.
    for(int w=0;w<8;w++)begin
      prepare(1,1,2,64,w);
      if(w==1)begin
        prepare(1,1,2,64,2);claim(0);
        prepare(1,1,2,64,1);claim_a_ref[31:0]+=1;claim_plan_admitted=0;claim(0);
        prepare(1,1,2,64,1);claim_gate_ref[31:0]+=1;claim(0);
        prepare(1,1,2,64,1);
      end
      claim();retire_window(1,w==7);
      if(w<7 && gate_owner_state!=1)$fatal(1,"early GATE tensor READY");
      if(w==2)begin
        acquire_window(0,0); // Full tensor is not READY yet.
      end
    end
    if(gate_owner_state!=2 || $countones(valid_windows)!=8 || $countones(covered_windows)!=8 ||
       $countones(covered_rows)!=128 || publishes!=1)$fatal(1,"GATE tensor coverage/publication");
    for(int w=0;w<8;w++)begin
      if(w==0)begin
        acquire_window(0);release_window(0);acquire_window(0,0);
      end else begin acquire_window(w);release_window(w);end
    end
    if($countones(consumed_windows)!=8 || acquires!=8 || releases!=8)$fatal(1,"GATE per-window consumption");
    release_tensor();
    // Cancellation in an inter-window gap burns the epoch and bindings.
    prepare(1,2,1,64,0);claim();retire_window();
    cancel=1;tick();@(negedge clk);cancel=0;tick();
    if(gate_owner_state!=4 || !cancel_done)$fatal(1,"GATE inter-window cancel");
    prepare(1,2,1,64,1);claim(0);
    // Same session, larger request recovers with a later epoch.
    for(int w=0;w<4;w++)begin prepare(2,3,1,64,w);claim();retire_window(1,w==3);end
    if(gate_owner_state!=2 || publishes!=2)$fatal(1,"GATE same-session recovery");
    cancel=1;tick();@(negedge clk);cancel=0;tick();
    // Failed actual window invalidates without publishing.
    prepare(3,4,1,64,0);claim();retire_window(0,0);
    if(gate_owner_state!=4 || publishes!=2)$fatal(1,"failed GATE window published");
    // Maximum legal finite table: B2*S1024 = 128 windows / 2048 rows.
    for(int w=0;w<128;w++)begin
      prepare(4,5,2,1024,w);claim();retire_window(1,w==127);
      if(w<127 && gate_owner_state!=1)$fatal(1,"maximum GATE published early");
    end
    if(gate_owner_state!=2 || next_window!=128 || $countones(valid_windows)!=128 ||
       $countones(covered_windows)!=128 || $countones(covered_rows)!=2048 || publishes!=3 || rejects!=4)
      $fatal(1,"maximum GATE ledger coverage next=%0d valid=%0d covered=%0d rows=%0d rejects=%0d",next_window,$countones(valid_windows),$countones(covered_windows),$countones(covered_rows),rejects);
    $display("FULL_CURRENT_GATE_TENSOR_PASS same_epoch_windows=128 covered_rows=2048 final_debt_publication=1 plan_reject=1 overlap_reject=1 inter_window_cancel=1 same_session_recovery=1 per_window_lease=8 held_read_release=1 rejects=%0d publishes=%0d cycles=%0d",rejects,publishes,cycles);$finish;
  end
endmodule
`default_nettype wire
