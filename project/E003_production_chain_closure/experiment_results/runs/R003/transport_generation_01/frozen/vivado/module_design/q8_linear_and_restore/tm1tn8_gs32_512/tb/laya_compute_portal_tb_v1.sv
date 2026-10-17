`timescale 1ns/1ps
// Transport-only test. The controlled service endpoint exercises handshakes;
// it is not numerical, cache, 13BO, or producer-chain validation.
module laya_compute_portal_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic [511:0] compute_cmd_din,compute_rsp_dout;
  logic compute_cmd_write=0,compute_cmd_full_n,compute_rsp_empty_n,compute_rsp_read=0;
  logic service_command_valid,service_command_ready=0,service_cancel;
  logic [8191:0] service_command;
  logic service_completion_valid=0,service_completion_ready,physical_debt_zero=1;
  logic [4095:0] service_completion;
  logic busy,cancel_pending,protocol_error;
  logic [31:0] accepted_commands,retired_responses,stale_completions;
  logic [1:0] command_fifo_occupancy,response_fifo_occupancy;
  laya_compute_portal_v1 dut(.*);
  logic [511:0] command_beats[0:15],response_beats[0:7];
  logic [8191:0] base_command,command;
  logic [4095:0] base_response,expected;
  string fixture;
  int total_cycles=0;
  always @(posedge clk)begin
    total_cycles<=total_cycles+1;
    if(total_cycles>12000)$fatal(1,"portal transport cycle limit");
    if(command_fifo_occupancy>2 || response_fifo_occupancy>2)$fatal(1,"private FIFO depth");
  end
  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic send_packet(input logic [8191:0] packet,input int count=16);
    for(int beat=0;beat<count;beat++)begin
      if(beat%3==1)tick();
      compute_cmd_din=packet[beat*512+:512];compute_cmd_write=1;
      do begin @(posedge clk);end while(!compute_cmd_full_n);
      #1;@(negedge clk);compute_cmd_write=0;
      if(beat<15 && service_command_valid)$fatal(1,"service issued before full packet");
    end
  endtask
  task automatic accept_service(input logic [8191:0] packet);
    while(!service_command_valid)tick();
    repeat(9)begin
      if(service_command!==packet || !service_command_valid)$fatal(1,"held command changed");
      if(compute_cmd_full_n)$fatal(1,"next packet accepted before response retirement");
      tick();
    end
    service_command_ready=1;tick();service_command_ready=0;
    if(service_command_valid)$fatal(1,"duplicate service command");
  endtask
  task automatic return_completion(input logic [4095:0] packet);
    service_completion=packet;service_completion_valid=1;
    do begin @(posedge clk);end while(!service_completion_ready);
    #1;@(negedge clk);service_completion_valid=0;
  endtask
  task automatic receive_packet(input logic [4095:0] packet);
    logic [511:0] held;
    for(int beat=0;beat<8;beat++)begin
      while(!compute_rsp_empty_n)tick();
      held=compute_rsp_dout;
      repeat(beat%4+2)begin
        if(!compute_rsp_empty_n || compute_rsp_dout!==held)$fatal(1,"held response changed");
        if(compute_cmd_full_n)$fatal(1,"command slot reused before complete response");
        tick();
      end
      if(held!==packet[beat*512+:512])$fatal(1,"response byte mismatch beat=%0d",beat);
      compute_rsp_read=1;tick();compute_rsp_read=0;
    end
    repeat(2)tick();
    if(busy || compute_rsp_empty_n || cancel_pending)$fatal(1,"transport did not retire");
  endtask
  task automatic first_push_cancel(input logic [8191:0] packet,input logic [63:0] closed);
    @(negedge clk);compute_cmd_din=packet[0+:512];compute_cmd_write=1;
    @(posedge clk);#1;
    if(dut.ingress_count!=1 || dut.collect_count!=0)$fatal(1,"first ingress not isolated from pop");
    @(negedge clk);compute_cmd_write=0;cancel=1;#1;
    if(!service_cancel)$fatal(1,"cancel did not reach persistent hub");
    tick();cancel=0;repeat(2)tick();
    if(busy || dut.last_generation!=closed || dut.header_seen || command_fifo_occupancy!=0)
      $fatal(1,"first push cancellation high-water closed=%h expected=%h",dut.last_generation,closed);
  endtask
  function automatic logic [4095:0] error_expected(input logic [8191:0] cmd,input logic [15:0] status);
    logic [4095:0] r;
    r=0;r[0+:32]=32'h3152434c;r[32+:16]=2;r[48+:16]=status;
    r[64+:64]=cmd[64+:64];r[128+:32]=cmd[128+:32];
    r[160+:32]=status==1 ? 32'h04000014 : 32'h04000015;
    r[192+:64]='1;r[256+:64]='1;r[360]=1;
    r[1024+:672]=cmd[512+:672];r[1696+:96]=cmd[1184+:96];
    r[1792+:320]=cmd[1280+:320];r[2112+:32]=cmd[4992+:32];r[2144+:32]=cmd[5024+:32];
    r[272*8+:352]=cmd[928*8+:352];
    r[316*8+:8]=cmd[620*8+:8];r[317*8+:8]=cmd[621*8+:8];r[318*8+:16]=cmd[6*8+:16];
    return r;
  endfunction
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    $readmemh({fixture,"/command.hex"},command_beats);
    $readmemh({fixture,"/response.hex"},response_beats);
    for(int b=0;b<16;b++)base_command[b*512+:512]=command_beats[b];
    for(int b=0;b<8;b++)base_response[b*512+:512]=response_beats[b];
    // Independent C/Python fixtures exercise all operation maps, including
    // LOAD's all-zero extension. Direct checks do not grant service admission.
    for(int op=1;op<=4;op++)begin
      $readmemh($sformatf("%s/%0d_command.hex",fixture,op),command_beats);
      $readmemh($sformatf("%s/%0d_response.hex",fixture,op),response_beats);
      for(int b=0;b<16;b++)command[b*512+:512]=command_beats[b];
      for(int b=0;b<8;b++)expected[b*512+:512]=response_beats[b];
      if(!command_frame_ok(command) || !response_binding_ok(expected,command))$fatal(1,"v2 operation fixture map op=%0d",op);
      command[VER*8+:16]=1;if(command_frame_ok(command))$fatal(1,"v1 accepted by v2");command[VER*8+:16]=2;
      for(int byteoff=272;byteoff<320;byteoff++)begin
        expected[byteoff*8]=!expected[byteoff*8];
        if(response_binding_ok(expected,command))$fatal(1,"extension response mismatch accepted op=%0d byte=%0d",op,byteoff);
        expected[byteoff*8]=!expected[byteoff*8];
      end
      if(op==1)for(int byteoff=928;byteoff<972;byteoff++)begin
        command[byteoff*8]=1;
        if(command_frame_ok(command))$fatal(1,"LOAD extension not zero byte=%0d",byteoff);
        command[byteoff*8]=0;
      end
      else begin
        for(int byteoff=0;byteoff<12;byteoff++)begin
          int repeated;
          repeated=op==2 ? 940 : op==3 ? 952 : 928;
          command[(repeated+byteoff)*8]=!command[(repeated+byteoff)*8];
          if(command_frame_ok(command))$fatal(1,"repeated context mismatch accepted op=%0d byte=%0d",op,byteoff);
          command[(repeated+byteoff)*8]=!command[(repeated+byteoff)*8];
        end
      end
    end
    compute_cmd_din=0;service_completion=0;
    repeat(5)tick();rst_n=1;tick();
    command=base_command;send_packet(command);accept_service(command);
    physical_debt_zero=0;
    expected=base_response;expected[GENERATION*8+:64]=base_response[GENERATION*8+:64]-1;
    return_completion(expected);
    if(stale_completions!=1 || compute_rsp_empty_n)$fatal(1,"stale completion published");
    service_completion=base_response;service_completion_valid=1;
    #1; // Observe combinational ready after the newly driven packet settles.
    repeat(13)begin
      if(service_completion_ready || compute_rsp_empty_n)$fatal(1,"completion before last physical debt");
      tick();
    end
    physical_debt_zero=1;tick();service_completion_valid=0;
    receive_packet(base_response);
    if(accepted_commands!=1 || retired_responses!=1)$fatal(1,"one-command/one-response count");

    // Replay generation is a local rejection and cannot reach the service.
    send_packet(base_command);expected=error_expected(base_command,7);receive_packet(expected);
    if(accepted_commands!=1 || retired_responses!=2)$fatal(1,"replay service admission");

    // Reserved-bit mutation is rejected before service admission.
    command=base_command;command[GENERATION*8+:64]+=1;command[1023*8+:8]=1;
    send_packet(command);receive_packet(error_expected(command,1));
    if(accepted_commands!=1)$fatal(1,"reserved bit reached service");

    // A malformed current return fails safely, after real debt becomes zero.
    command=base_command;command[GENERATION*8+:64]+=2;
    send_packet(command);accept_service(command);
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    expected[RESPONSE_IDENTITY*8+671]=!expected[RESPONSE_IDENTITY*8+671];
    physical_debt_zero=0;service_completion=expected;service_completion_valid=1;
    #1;
    repeat(8)begin if(service_completion_ready)$fatal(1,"malformed current return retired early");tick();end
    physical_debt_zero=1;tick();service_completion_valid=0;
    receive_packet(error_expected(command,7));

    // Active cancellation retains debt, then drops the old caller's response.
    command=base_command;command[GENERATION*8+:64]+=3;
    send_packet(command);accept_service(command);physical_debt_zero=0;
    cancel=1;tick();cancel=0;
    repeat(11)begin
      if(!service_cancel || !busy || compute_cmd_full_n || compute_rsp_empty_n)$fatal(1,"cancel lost debt ownership");
      tick();
    end
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    service_completion=expected;service_completion_valid=1;
    #1;
    repeat(5)begin if(service_completion_ready)$fatal(1,"cancelled service debt retired early");tick();end
    physical_debt_zero=1;tick();service_completion_valid=0;
    repeat(3)tick();
    if(busy || compute_rsp_empty_n || cancel_pending)$fatal(1,"cancel drain did not clear transport");

    // Partial command cancellation requires no missing beats or fake reply.
    command[GENERATION*8+:64]+=1;send_packet(command,3);
    cancel=1;tick();cancel=0;repeat(2)tick();
    if(busy || compute_rsp_empty_n || command_fifo_occupancy!=0)$fatal(1,"partial cancel retained old packet");

    command=base_command;command[GENERATION*8+:64]+=5;
    send_packet(command);accept_service(command);
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    return_completion(expected);receive_packet(expected);
    if(accepted_commands!=4 || retired_responses!=5 || stale_completions!=1)$fatal(1,"initial transport counts");
    // v2 failures must remain local to transport, with no new service activity.
    for(int bad_case=0;bad_case<4;bad_case++)begin
      command=base_command;command[GENERATION*8+:64]+=64'(6+bad_case);
      case(bad_case)
        0:command[VER*8+:16]=1;
        1:command[LINEAR_CONTEXT*8]=!command[LINEAR_CONTEXT*8];
        2:command[(FUTURE_DST_REF+6)*8]=!command[(FUTURE_DST_REF+6)*8];
        3:command[WEIGHT_RANGES*8]=1;
      endcase
      send_packet(command);receive_packet(error_expected(command,1));
      if(accepted_commands!=4)$fatal(1,"v2 malformed binding reached service case=%0d",bad_case);
    end
    // Current-generation wrong view/future identity fails after real drain.
    command=base_command;command[GENERATION*8+:64]+=10;
    send_packet(command);accept_service(command);
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    expected[RESPONSE_ROW_BLOCK*8]=!expected[RESPONSE_ROW_BLOCK*8];
    physical_debt_zero=0;service_completion=expected;service_completion_valid=1;#1;
    repeat(9)begin if(service_completion_ready || compute_rsp_empty_n)$fatal(1,"v2 mismatch retired with debt");tick();end
    physical_debt_zero=1;tick();service_completion_valid=0;receive_packet(error_expected(command,7));
    // A larger request_id in the same session generation can recover. Old
    // command returns drain without entering the new request's response.
    command=base_command;command[GENERATION*8+:64]+=11;command[IDENTITY*8+:64]+=1;
    send_packet(command);accept_service(command);return_completion(base_response);
    if(compute_rsp_empty_n || stale_completions!=2)$fatal(1,"old request polluted recovery");
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    expected[RESPONSE_IDENTITY*8+:64]=command[IDENTITY*8+:64];
    return_completion(expected);receive_packet(expected);
    if(accepted_commands!=6 || retired_responses!=11 || stale_completions!=2)$fatal(1,"final v2 transport counts");
    // Cold rst_n was used only at initial isolated startup. These are soft
    // cancellations, which preserve H_closed and reach any hub pin in a gap.
    command=base_command;command[GENERATION*8+:64]+=12;
    first_push_cancel(command,command[GENERATION*8+:64]);
    if(accepted_commands!=6 || retired_responses!=11)$fatal(1,"header consumption counted as service work");
    // No ingress handshake while cancel is asserted: ignore the old assembly.
    compute_cmd_din=base_command[0+:512];compute_cmd_write=1;cancel=1;#1;
    if(compute_cmd_full_n || !service_cancel)$fatal(1,"no-handshake cancellation domain");
    tick();compute_cmd_write=0;cancel=0;repeat(2)tick();
    if(dut.last_generation!=base_command[GENERATION*8+:64]+12)$fatal(1,"no ingress consumed stale g");
    // Each bad fixed-header category carrying a huge g is harmless to the
    // watermark, through both full failed-response and first-push cancel paths.
    for(int bad_head=0;bad_head<9;bad_head++)begin
      command=base_command;command[GENERATION*8+:64]='1;
      case(bad_head)
        0:command[MAGIC*8]=!command[MAGIC*8];
        1:command[VER*8+:16]=1;
        2:command[COMMAND_BEATS*8+:16]=15;
        3:command[RESPONSE_BEATS*8+:16]=7;
        4:command[FLAGS_DETAIL*8]=1;
        5:command[63*8]=1;
        6:command[TASK*8+:32]='1;
        7:command[OP_STATUS*8+:16]=0;
        8:command[GENERATION*8+:64]=0;
      endcase
      send_packet(command);receive_packet(error_expected(command,1));
      if(dut.last_generation!=base_command[GENERATION*8+:64]+12)$fatal(1,"bad header poisoned g case=%0d",bad_head);
      first_push_cancel(command,base_command[GENERATION*8+:64]+12);
    end
    // A trusted header with an incomplete body burns its g only at safe cancel.
    command=base_command;command[GENERATION*8+:64]+=13;send_packet(command,3);
    cancel=1;tick();cancel=0;repeat(2)tick();
    if(dut.last_generation!=command[GENERATION*8+:64])$fatal(1,"trusted partial did not burn g");
    // Trusted header, bad tail: full failure closes g; replay remains forbidden.
    command=base_command;command[GENERATION*8+:64]+=14;command[1023*8]=1;
    send_packet(command);receive_packet(error_expected(command,1));
    if(dut.last_generation!=command[GENERATION*8+:64])$fatal(1,"bad tail did not close trusted g");
    command[1023*8]=0;send_packet(command);receive_packet(error_expected(command,7));
    // Soft-cancel a partially read response. Only genuinely read packets count
    // as retired; the trusted g survives cancellation and later session change.
    command=base_command;command[GENERATION*8+:64]+=15;
    send_packet(command);accept_service(command);
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    return_completion(expected);while(!compute_rsp_empty_n)tick();
    compute_rsp_read=1;tick();compute_rsp_read=0;cancel=1;tick();cancel=0;repeat(2)tick();
    if(busy || compute_rsp_empty_n || dut.last_generation!=command[GENERATION*8+:64])$fatal(1,"partial response cancel did not close");
    // New session generation still continues the same portal counter.
    command=base_command;command[GENERATION*8+:64]+=20;
    command[IDENTITY*8+:64]+=2;command[(IDENTITY+8)*8+:64]+=1;
    send_packet(command);accept_service(command);
    expected=base_response;expected[GENERATION*8+:64]=command[GENERATION*8+:64];
    expected[RESPONSE_IDENTITY*8+:672]=command[IDENTITY*8+:672];
    return_completion(expected);receive_packet(expected);
    if(accepted_commands!=8 || retired_responses!=23 || stale_completions!=2)$fatal(1,"lifecycle counts accepted=%0d retired=%0d",accepted_commands,retired_responses);
    $display("FULL_CURRENT_PORTAL_TRANSPORT_PASS version=2 trusted_header_categories=9 first_push_cancel=10 soft_cancel_watermark=1 same_session_recovery=1 new_session_recovery=1 accepted=%0d retired=%0d stale=%0d cycles=%0d",accepted_commands,retired_responses,stale_completions,total_cycles);
    $finish;
  end
endmodule
