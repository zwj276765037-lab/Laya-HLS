`timescale 1ns/1ps
module laya_graph_program_tb_v1;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic [511:0] in_data[0:3],out_data[0:3];
  logic [3:0] test_in_valid=0,test_out_ready=0;
  wire [3:0] in_valid,in_ready,out_valid,out_ready;
  logic [1:0] occupancy[0:3];
  logic command_read,result_write,action_write,completion_read;
  integer cycles=0,command_reads=0,action_writes=0,phase=0;
  string fixture_path;
  bit pilot;
  logic [511:0] commands[0:15],actions[0:23];
  logic [511:0] completions[0:11],results[0:15];

  for(genvar i=0;i<4;i++)begin: fifos
    laya_private_fifo2_v1 queue(.clk,.rst_n,.in_valid(in_valid[i]),
      .in_ready(in_ready[i]),.in_data(in_data[i]),.out_valid(out_valid[i]),
      .out_ready(out_ready[i]),.out_data(out_data[i]),.occupancy(occupancy[i]));
  end
  assign in_valid[0]=test_in_valid[0];
  assign in_valid[3]=test_in_valid[3];
  assign out_ready[1]=test_out_ready[1];
  assign out_ready[2]=test_out_ready[2];
  assign out_ready[0]=command_read;
  assign out_ready[3]=completion_read;
  assign in_valid[1]=result_write;
  assign in_valid[2]=action_write;
  laya_graph_program_shell_v1 dut(
    .ap_clk(clk),.ap_rst(!rst_n),.cancel,
    .accepted_command_dout(out_data[0]),.accepted_command_empty_n(out_valid[0]),
    .accepted_command_read(command_read),
    .request_result_din(in_data[1]),.request_result_full_n(in_ready[1]),
    .request_result_write(result_write),
    .request_result_consumer_read(test_out_ready[1]),
    .request_result_consumer_empty_n(out_valid[1]),
    .action_request_din(in_data[2]),.action_request_full_n(in_ready[2]),
    .action_request_write(action_write),
    .action_completion_dout(out_data[3]),.action_completion_empty_n(out_valid[3]),
    .action_completion_read(completion_read));

  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>1000000)$fatal(1,"program cycle cap phase=%0d",phase);
    if(rst_n)begin
      if(command_read && out_valid[0])command_reads<=command_reads+1;
      if(action_write && in_ready[2])action_writes<=action_writes+1;
      if(result_write && !in_ready[1] || action_write && !in_ready[2])
        $fatal(1,"write while depth2 full");
    end
  end
  task automatic tick; @(posedge clk);#1;endtask
  task automatic push(input integer channel,input logic [511:0] data);
    bit accepted;
    @(negedge clk);in_data[channel]=data;test_in_valid[channel]=1;
    do begin @(posedge clk);accepted=in_ready[channel];#1;end while(!accepted);
    @(negedge clk);test_in_valid[channel]=0;
  endtask
  task automatic pop_check(input integer channel,input logic [511:0] expected);
    while(!out_valid[channel])tick();
    repeat(3)begin tick();if(out_data[channel]!==expected)
      $fatal(1,"wrong/stalled head channel=%0d phase=%0d",channel,phase);end
    @(negedge clk);test_out_ready[channel]=1;tick();
    @(negedge clk);test_out_ready[channel]=0;
  endtask
  task automatic hold_result_tail(input integer request_index,
                                  input integer expected_actions,
                                  input bit queued_next);
    while(occupancy[1]!=2)tick();
    repeat(12)begin
      tick();
      if(command_reads!=4*(request_index+1) ||
         action_writes!=expected_actions ||
         (queued_next && occupancy[0]!=2) ||
         out_data[1]!==results[4*request_index+2] || dut.result_consumed)
        $fatal(1,"two-tail consumption boundary phase=%0d",phase);
    end
    pop_check(1,results[4*request_index+2]);
    repeat(12)begin
      tick();
      if(command_reads!=4*(request_index+1) ||
         action_writes!=expected_actions ||
         (queued_next && occupancy[0]!=2) ||
         out_data[1]!==results[4*request_index+3] || dut.result_consumed)
        $fatal(1,"one-tail consumption boundary phase=%0d",phase);
    end
    pop_check(1,results[4*request_index+3]);
    if(!dut.result_consumed)$fatal(1,"actual final read notification missing");
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture_path))$fatal(1,"fixture required");
    pilot=$test$plusargs("PILOT");
    $readmemh({fixture_path,"/commands.hex"},commands);
    $readmemh({fixture_path,"/actions.hex"},actions);
    $readmemh({fixture_path,"/completions.hex"},completions);
    $readmemh({fixture_path,"/results.hex"},results);
    repeat(8)tick();@(negedge clk);rst_n=1;
    for(int beat=0;beat<4;beat++)push(0,commands[beat]);
    for(int request_index=0,action_index=0;request_index<4;request_index++)begin
      phase=request_index;
      if(request_index!=2)begin
        for(int beat=0;beat<8;beat++)pop_check(2,actions[action_index*8+beat]);
        for(int beat=0;beat<4;beat++)begin
          push(3,completions[action_index*4+beat]);
          if(beat==1)begin
            repeat(25)begin tick();if(out_valid[1])
              $fatal(1,"result before full LAC1");end
          end
        end
        action_index++;
      end
      // Leave the next descriptor queued at the real FIFO output even while
      // the current result is still partially unconsumed.
      while(occupancy[1]!=2)tick();
      if(request_index<3)begin
        push(0,commands[(request_index+1)*4]);
        push(0,commands[(request_index+1)*4+1]);
      end
      pop_check(1,results[request_index*4]);
      pop_check(1,results[request_index*4+1]);
      hold_result_tail(request_index,8*action_index,request_index<3);
      if(pilot)begin
        $display("FULL_CURRENT_GRAPH_PROGRAM_RTL_PILOT_PASS cycles=%0d commands=1 actions=1 tail2=1 tail1=1",cycles);
        $finish;
      end
      if(request_index<3)begin
        // Read-side gate may open on the following cycle.  HLS remains free
        // to sample the persistent notification before it reads that frame.
        while(command_reads!=4*(request_index+1)+2)tick();
        if(dut.result_consumed)$fatal(1,"old notification leaked after next first read");
        push(0,commands[(request_index+1)*4+2]);
        push(0,commands[(request_index+1)*4+3]);
      end
    end
    // No next command: notification must survive arbitrary HLS scheduling.
    repeat(25)begin tick();if(!dut.result_consumed)
      $fatal(1,"consumer notification did not persist");end
    for(int i=0;i<4;i++)if(occupancy[i]!=0)$fatal(1,"final FIFO nonempty %0d",i);
    if(command_reads!=16 || action_writes!=24)$fatal(1,"wrong total work");
    $display("FULL_CURRENT_GRAPH_PROGRAM_RTL_PASS cycles=%0d commands=4 actions=3 safe_error=1 local_reject=1 ordinal_recovery=1 tail2=1 tail1=1 notification_persistent=1 notification_cleared=1 depth2=1 final_empty=1",cycles);
    $finish;
  end
endmodule
