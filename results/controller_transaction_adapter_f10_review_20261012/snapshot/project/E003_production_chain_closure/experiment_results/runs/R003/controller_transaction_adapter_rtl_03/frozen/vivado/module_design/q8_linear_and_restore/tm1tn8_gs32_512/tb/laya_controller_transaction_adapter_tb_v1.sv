`timescale 1ns/1ps
module laya_controller_transaction_adapter_tb_v1;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic [511:0] in_data[0:7],out_data[0:7];
  logic [7:0] test_in_valid=0,test_out_ready=0;
  wire [7:0] in_valid,in_ready,out_valid,out_ready;
  logic [1:0] occupancy[0:7];
  integer cycles=0,tx_reads=0,remote_writes=0,phase=0;
  string fixture_path,selected_case;
  logic [511:0] request_words[0:23],external_words[0:15];
  logic [511:0] response_words[0:7],completion_words[0:15];
  logic [4095:0] remote_packet;
  logic [8191:0] completion_packet;
  logic transaction_request_read,transaction_completion_write;
  logic compute_command_write,compute_response_read;
  logic provenance_command_write,provenance_response_read;
  logic producer_request_write,producer_completion_read;

  for(genvar i=0;i<8;i++)begin: fifos
    laya_private_fifo2_v1 queue(.clk,.rst_n,.in_valid(in_valid[i]),
      .in_ready(in_ready[i]),.in_data(in_data[i]),.out_valid(out_valid[i]),
      .out_ready(out_ready[i]),.out_data(out_data[i]),.occupancy(occupancy[i]));
  end

  assign in_valid[0]=test_in_valid[0];
  assign in_valid[3]=test_in_valid[3];
  assign in_valid[5]=test_in_valid[5];
  assign in_valid[7]=test_in_valid[7];
  assign out_ready[1]=test_out_ready[1];
  assign out_ready[2]=test_out_ready[2];
  assign out_ready[4]=test_out_ready[4];
  assign out_ready[6]=test_out_ready[6];
  assign out_ready[0]=transaction_request_read;
  assign out_ready[3]=compute_response_read;
  assign out_ready[5]=provenance_response_read;
  assign out_ready[7]=producer_completion_read;
  assign in_valid[1]=transaction_completion_write;
  assign in_valid[2]=compute_command_write;
  assign in_valid[4]=provenance_command_write;
  assign in_valid[6]=producer_request_write;
  laya_controller_transaction_adapter_shell_v1 dut(
    .ap_clk(clk),.ap_rst(!rst_n),.cancel,
    .transaction_request_dout(out_data[0]),.transaction_request_empty_n(out_valid[0]),
    .transaction_request_read,
    .transaction_completion_din(in_data[1]),.transaction_completion_full_n(in_ready[1]),
    .transaction_completion_write,
    .transaction_completion_consumer_read(test_out_ready[1]),
    .transaction_completion_consumer_empty_n(out_valid[1]),
    .compute_command_din(in_data[2]),.compute_command_full_n(in_ready[2]),.compute_command_write,
    .compute_response_dout(out_data[3]),.compute_response_empty_n(out_valid[3]),.compute_response_read,
    .provenance_command_din(in_data[4]),.provenance_command_full_n(in_ready[4]),.provenance_command_write,
    .provenance_response_dout(out_data[5]),.provenance_response_empty_n(out_valid[5]),.provenance_response_read,
    .producer_request_din(in_data[6]),.producer_request_full_n(in_ready[6]),.producer_request_write,
    .producer_completion_dout(out_data[7]),.producer_completion_empty_n(out_valid[7]),.producer_completion_read);

  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>1000000)$fatal(1,"adapter cycle cap phase=%0d",phase);
    if(rst_n)begin
      if(transaction_request_read && out_valid[0])tx_reads<=tx_reads+1;
      if((compute_command_write && in_ready[2]) ||
         (provenance_command_write && in_ready[4]) ||
         (producer_request_write && in_ready[6]))remote_writes<=remote_writes+1;
      if(transaction_completion_write && !in_ready[1])
        $fatal(1,"completion write while depth2 full");
      if(compute_command_write && !in_ready[2] ||
         provenance_command_write && !in_ready[4] ||
         producer_request_write && !in_ready[6])
        $fatal(1,"external write while depth2 full");
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
    // Stall a visible depth2 output and check that the head stays stable.
    repeat(3)begin tick();if(out_data[channel]!==expected)
      $fatal(1,"unstable/wrong FIFO head channel=%0d phase=%0d",channel,phase);end
    @(negedge clk);test_out_ready[channel]=1;tick();
    @(negedge clk);test_out_ready[channel]=0;
  endtask
  task automatic load_case(input string name);
    $readmemh({fixture_path,"/",name,"_request.hex"},request_words);
    $readmemh({fixture_path,"/",name,"_completion.hex"},completion_words);
    if(name!="cancel_producer")begin
      $readmemh({fixture_path,"/",name,"_external.hex"},external_words);
      $readmemh({fixture_path,"/",name,"_response.hex"},response_words);
    end
  endtask
  task automatic run_case(input string name,input integer command_channel,
                          input integer response_channel,input bit held_cancel);
    integer initial_reads,initial_remote,remote_after_first;
    load_case(name);@(negedge clk);cancel=held_cancel;
    initial_reads=tx_reads;initial_remote=remote_writes;
    for(int beat=0;beat<24;beat++)push(0,request_words[beat]);
    if(name!="cancel_producer")begin
      for(int beat=0;beat<16;beat++)pop_check(command_channel,external_words[beat]);
      for(int beat=0;beat<8;beat++)begin
        push(response_channel,response_words[beat]);
        if(beat==1)begin
          @(negedge clk);cancel=1;
          repeat(25)begin tick();if(out_valid[1])
            $fatal(1,"normalized completion before full response");end
        end
      end
    end
    while(occupancy[1]!=2)tick();
    // Completion is full and unconsumed.  Queue only the first two words of
    // the following descriptor; the adapter must leave them in the FIFO.
    push(0,request_words[0]);push(0,request_words[1]);
    repeat(12)begin
      tick();if(occupancy[0]!=2 || tx_reads!=initial_reads+24)
        $fatal(1,"new descriptor consumed before completion retirement");
    end
    completion_packet=0;
    for(int beat=0;beat<14;beat++)begin
      completion_packet[beat*512+:512]=completion_words[beat];
      pop_check(1,completion_words[beat]);
    end
    while(occupancy[1]!=2)tick();
    remote_after_first=remote_writes;
    repeat(12)begin
      tick();
      if(tx_reads!=initial_reads+24 || remote_writes!=remote_after_first ||
         occupancy[0]!=2 || !out_valid[1] ||
         out_data[1]!==completion_words[14])
        $fatal(1,"next transaction advanced with two completion beats unconsumed");
    end
    completion_packet[14*512+:512]=completion_words[14];
    pop_check(1,completion_words[14]);
    repeat(12)begin
      tick();
      if(tx_reads!=initial_reads+24 || remote_writes!=remote_after_first ||
         occupancy[0]!=2 || !out_valid[1] ||
         out_data[1]!==completion_words[15])
        $fatal(1,"next transaction advanced with final completion beat unconsumed");
    end
    completion_packet[15*512+:512]=completion_words[15];
    pop_check(1,completion_words[15]);
    while(tx_reads!=initial_reads+26)tick();
    if(name=="wait_end" &&
       ((completion_packet[12*8+:32]&32'h1f)!=32'h0b))
      $fatal(1,"undrained active END lost remote state");
    if(name=="wrong_end" && (completion_packet[12*8+:32]&2))
      $fatal(1,"wrong END received binding trust");
    if(name=="bad_producer" && (completion_packet[12*8+:32]&32'h12))
      $fatal(1,"bad producer frame received binding/terminal trust");
    if(name=="cancel_producer" && remote_writes!=initial_remote)
      $fatal(1,"cancel local reject issued external producer");
    $display("FULL_CURRENT_CONTROLLER_ADAPTER_RTL_CASE_PASS case=%s cycles=%0d",name,cycles);
    // Finish the already queued descriptor as a cancellation rejection.
    // This also checks partial internal frame progress while cancel is held.
    @(negedge clk);cancel=1;
    for(int beat=2;beat<24;beat++)push(0,request_words[beat]);
    if(name=="end" || name=="wait_end" || name=="wrong_end")begin
      // Cleanup END is still admissible during cancel, with the same binding.
      for(int beat=0;beat<16;beat++)pop_check(command_channel,external_words[beat]);
      for(int beat=0;beat<8;beat++)push(response_channel,response_words[beat]);
      for(int beat=0;beat<16;beat++)pop_check(1,completion_words[beat]);
    end else begin
      while(!out_valid[1])tick();
      if(out_data[1][12*8+:32]!==32'h41)
        $fatal(1,"partial next descriptor failed cancellation rejection");
      for(int beat=0;beat<16;beat++)begin
        while(!out_valid[1])tick();@(negedge clk);test_out_ready[1]=1;
        tick();@(negedge clk);test_out_ready[1]=0;
      end
    end
    @(negedge clk);cancel=0;
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture_path))$fatal(1,"fixture required");
    if(!$value$plusargs("CASE=%s",selected_case))$fatal(1,"CASE required");
    for(int i=0;i<8;i++)begin
      if(i==0 || i==3 || i==5 || i==7)in_data[i]=0;
    end
    repeat(10)tick();@(negedge clk);rst_n=1;
    if(selected_case=="compute")begin phase=1;run_case("compute",2,3,0);end
    else if(selected_case=="begin")begin phase=2;run_case("begin",4,5,0);end
    else if(selected_case=="producer")begin phase=3;run_case("producer",6,7,0);end
    else if(selected_case=="wait_end")begin phase=4;run_case("wait_end",4,5,1);end
    else if(selected_case=="wrong_end")begin phase=5;run_case("wrong_end",4,5,1);end
    else if(selected_case=="bad_producer")begin phase=6;run_case("bad_producer",6,7,0);end
    else if(selected_case=="cancel_producer")begin phase=7;run_case("cancel_producer",6,7,1);end
    else if(selected_case=="end")begin phase=8;run_case("end",4,5,1);end
    else $fatal(1,"unsupported case %s",selected_case);
    repeat(20)tick();
    for(int i=0;i<8;i++)if(occupancy[i]!=0)$fatal(1,"FIFO residual channel=%0d",i);
    $display("FULL_CURRENT_CONTROLLER_ADAPTER_RTL_PASS case=%s depth2_fifos=8 partial_frames=1 cancel_held=1 completion_tail14_stall=1 completion_tail15_stall=1 cycles=%0d",selected_case,cycles);
    $finish;
  end
endmodule
