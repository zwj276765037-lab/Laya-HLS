`timescale 1ns/1ps
// Persistent four-service routing test. Endpoints are controlled protocol
// peers; numerical/cache/AXI behavior remains outside this test's scope.
module laya_compute_portal_hub_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic [511:0] compute_cmd_din,compute_rsp_dout;
  logic compute_cmd_write=0,compute_cmd_full_n,compute_rsp_empty_n;
  logic compute_rsp_read=0;
  logic [3:0] service_command_valid,service_command_ready=0,service_cancel;
  logic [8191:0] service_command;
  logic [3:0] service_completion_valid=0,service_completion_ready;
  logic [3:0][4095:0] service_completion=0;
  logic [3:0] service_physical_debt_zero='1,service_persistent_active=0;
  logic transport_busy,cancel_pending,protocol_error,hub_busy,domain_drained;
  logic [2:0] active_service;
  logic [31:0] accepted_commands,retired_responses,transport_stale_completions;
  logic [3:0][31:0] service_accepts,service_completions,service_stale_completions;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;
  laya_compute_portal_hub_v1 dut(.*);

  logic [511:0] command_beats[0:15],response_beats[0:7];
  logic [3:0][8191:0] commands;
  logic [3:0][4095:0] responses;
  logic [8191:0] command;
  logic [4095:0] response;
  string fixture;
  int cycles=0;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>12000)$fatal(1,"portal hub cycle cap");
    if($countones(service_command_valid)>1)$fatal(1,"multiple service command valids");
  end
  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic send_packet(input logic [8191:0] packet);
    for(int beat=0;beat<16;beat++)begin
      compute_cmd_din=packet[beat*512+:512];compute_cmd_write=1;
      do begin @(posedge clk);end while(!compute_cmd_full_n);
      #1;@(negedge clk);compute_cmd_write=0;
    end
  endtask
  task automatic accept_endpoint(input int index,input logic [8191:0] packet);
    while(!service_command_valid[index])tick();
    if(service_command_valid!=(4'b0001<<index) || service_command!==packet ||
       active_service!=0)$fatal(1,"bad service route index=%0d",index);
    repeat(3)begin
      if(service_command!==packet || service_command_valid!=(4'b0001<<index))
        $fatal(1,"command changed under endpoint backpressure");
      tick();
    end
    service_command_ready[index]=1;tick();service_command_ready[index]=0;
    if(active_service!=index+1 || service_command_valid)
      $fatal(1,"endpoint ownership not latched index=%0d",index);
  endtask
  task automatic return_endpoint(input int index,input logic [4095:0] packet);
    service_completion[index]=packet;service_completion_valid[index]=1;
    do begin @(posedge clk);end while(!service_completion_ready[index]);
    #1;@(negedge clk);service_completion_valid[index]=0;
  endtask
  task automatic receive_packet(input logic [4095:0] packet);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!compute_rsp_empty_n)tick();
      held=compute_rsp_dout;
      repeat(2)begin
        if(!compute_rsp_empty_n || compute_rsp_dout!==held)
          $fatal(1,"response changed under caller backpressure");
        tick();
      end
      if(held!==packet[beat*512+:512])$fatal(1,"response mismatch beat=%0d",beat);
      compute_rsp_read=1;tick();compute_rsp_read=0;
    end
    repeat(2)tick();
  endtask
  function automatic logic [4095:0] rejected(input logic [8191:0] cmd);
    logic [4095:0] r;
    r=0;r[0+:32]=32'h3152434c;r[VER*8+:16]=2;r[OP_STATUS*8+:16]=E_PROTOCOL;
    r[GENERATION*8+:64]=cmd[GENERATION*8+:64];r[TASK*8+:32]=cmd[TASK*8+:32];
    r[FLAGS_DETAIL*8+:32]=32'h04000015;r[RANK*8+:64]='1;r[BAD_ELEMENT*8+:64]='1;
    r[RETIRE_FLAGS*8]=1;
    r[RESPONSE_IDENTITY*8+:672]=cmd[IDENTITY*8+:672];
    r[RESPONSE_CONTEXT*8+:96]=cmd[CONTEXT*8+:96];
    r[RESPONSE_REFS*8+:320]=cmd[SOURCE_REF*8+:320];
    r[RESPONSE_A_EPOCH*8+:32]=cmd[A_EPOCH*8+:32];
    r[RESPONSE_W_EPOCH*8+:32]=cmd[W_EPOCH*8+:32];
    r[RESPONSE_PRODUCER_CONTEXT*8+:352]=cmd[PRODUCER_CONTEXT*8+:352];
    r[RESPONSE_ROWS*8+:8]=cmd[ROWS*8+:8];
    r[RESPONSE_ROW_BLOCK*8+:8]=cmd[ROW_BLOCK*8+:8];
    r[RESPONSE_SERVICE*8+:16]=cmd[OP_STATUS*8+:16];
    return r;
  endfunction
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    for(int service=1;service<=4;service++)begin
      $readmemh($sformatf("%s/%0d_command.hex",fixture,service),command_beats);
      $readmemh($sformatf("%s/%0d_response.hex",fixture,service),response_beats);
      for(int beat=0;beat<16;beat++)commands[service-1][beat*512+:512]=command_beats[beat];
      for(int beat=0;beat<8;beat++)responses[service-1][beat*512+:512]=response_beats[beat];
    end
    compute_cmd_din=0;
    repeat(5)tick();rst_n=1;tick();
    if(!domain_drained || hub_busy)$fatal(1,"hub not initially drained");

    // All services share one transport and one strictly increasing H_closed.
    for(int index=0;index<4;index++)begin
      command=commands[index];command[GENERATION*8+:64]=64'(101+index);
      response=responses[index];response[GENERATION*8+:64]=64'(101+index);
      send_packet(command);accept_endpoint(index,command);
      return_endpoint(index,response);receive_packet(response);
    end
    if(accepted_commands!=4 || retired_responses!=4 || service_accepts!={32'd1,32'd1,32'd1,32'd1})
      $fatal(1,"four-service counts");

    // Replaying the last generation on another service is rejected before
    // endpoint admission, proving the high-water is shared by the hub.
    command=commands[1];command[GENERATION*8+:64]=104;
    send_packet(command);receive_packet(rejected(command));
    if(accepted_commands!=4 || service_accepts[1]!=1)$fatal(1,"cross-service replay admitted");

    // A stale completion from the selected endpoint is drained by transport;
    // endpoint ownership remains until the current generation returns.
    command=commands[2];command[GENERATION*8+:64]=110;
    response=responses[2];response[GENERATION*8+:64]=109;
    send_packet(command);accept_endpoint(2,command);return_endpoint(2,response);
    if(active_service!=3 || transport_stale_completions!=1 || compute_rsp_empty_n)
      $fatal(1,"selected stale completion changed ownership");
    response[GENERATION*8+:64]=110;service_physical_debt_zero[2]=0;
    service_completion[2]=response;service_completion_valid[2]=1;#1;
    repeat(5)begin
      if(service_completion_ready[2])$fatal(1,"completion retired before physical debt");
      tick();
    end
    service_physical_debt_zero[2]=1;tick();service_completion_valid[2]=0;
    receive_packet(response);

    // An old return from another service cannot enter the current response
    // path and is drained locally before the selected GEGLU completion.
    command=commands[3];command[GENERATION*8+:64]=120;
    response=responses[0];response[GENERATION*8+:64]=101;
    send_packet(command);accept_endpoint(3,command);return_endpoint(0,response);
    if(active_service!=4 || service_stale_completions[0]!=1 || compute_rsp_empty_n)
      $fatal(1,"nonselected stale completion polluted caller");
    response=responses[3];response[GENERATION*8+:64]=120;
    return_endpoint(3,response);receive_packet(response);

    // Between matrix views the transport can be idle while the parent lease
    // stays pinned. Cancel must still reach every service and block cold drain.
    service_persistent_active[2]=1;#1;
    if(!hub_busy || domain_drained)$fatal(1,"parent pin absent from hub state");
    cancel=1;#1;
    if(service_cancel!=4'hf || domain_drained)$fatal(1,"gap cancel not broadcast");
    repeat(4)tick();service_persistent_active[2]=0;tick();cancel=0;tick();
    if(!domain_drained || hub_busy)$fatal(1,"gap parent cancel did not drain");

    if(!protocol_error || accepted_commands!=6 || retired_responses!=7 ||
       service_accepts!={32'd2,32'd2,32'd1,32'd1} ||
       service_completions[0]!=2 || service_completions[1]!=1 ||
       service_completions[2]!=3 || service_completions[3]!=2)
      $fatal(1,"final hub accounting accepted=%0d retired=%0d",accepted_commands,retired_responses);
    $display("FULL_CURRENT_PORTAL_HUB_PASS services=4 accepted=%0d retired=%0d transport_stale=%0d local_stale=%0d gap_parent_cancel=1 global_watermark=1 cycles=%0d",
      accepted_commands,retired_responses,transport_stale_completions,
      service_stale_completions[0],cycles);
    $finish;
  end
endmodule
