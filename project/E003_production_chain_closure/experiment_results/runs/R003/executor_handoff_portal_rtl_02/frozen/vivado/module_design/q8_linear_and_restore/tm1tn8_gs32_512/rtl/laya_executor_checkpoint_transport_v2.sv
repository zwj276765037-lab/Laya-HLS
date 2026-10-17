`timescale 1ns/1ps
// Single diagnostic handoff. Original dispatch drains before acquisition;
// the hub response remains owned until the 16th actual consumer handshake.
module laya_executor_checkpoint_transport_v2 (
  input logic clk,rst_n,cancel,
  input logic [511:0] command_din,
  input logic command_write,
  output logic command_full_n,
  output logic [511:0] response_dout,
  output logic response_empty_n,
  input logic response_read,
  output logic request_valid,
  input logic request_ready,
  output logic [8191:0] request,
  input logic hub_response_valid,
  output logic hub_response_ready,
  input logic [8191:0] hub_response,
  input logic acquisition_safe,
  input logic base_valid,
  input logic [63:0] base_epoch,base_address,base_capacity,
  output logic dispatch_held,handoff_complete,handoff_pulse,
  output logic authority_valid,protocol_error,
  output logic [31:0] accepted_queries,consumed_responses,
  output logic [1:0] command_occupancy,response_occupancy
);
  typedef enum logic [2:0] {COLLECT,ISSUE,SEND,WAIT_CONSUMER,DONE} state_t;
  state_t state;
  logic [4:0] ingress_count,collect_count,send_count,consumer_count;
  logic cmd_ready,cmd_valid,cmd_pop,rsp_ready,rsp_valid,rsp_push,rsp_pop;
  logic [511:0] cmd_data,rsp_data;
  logic revoked,configuration_ok;
  assign configuration_ok=base_valid && request[40*8+:64]==base_epoch &&
    request[48*8+:64]==base_address && request[56*8+:64]==base_capacity;
  assign authority_valid=handoff_complete && !revoked && !cancel && configuration_ok;
  assign command_full_n=state==COLLECT && ingress_count<16 && cmd_ready && !cancel;
  assign cmd_pop=state==COLLECT;
  laya_private_fifo2_v1 command_fifo(.clk,.rst_n,
    .in_valid(command_write && command_full_n),.in_ready(cmd_ready),.in_data(command_din),
    .out_valid(cmd_valid),.out_ready(cmd_pop),.out_data(cmd_data),.occupancy(command_occupancy));
  assign request_valid=state==ISSUE && acquisition_safe && !cancel;
  // Holding the whole hub response excludes mutations even after all beats
  // have been copied into the depth2 FIFO. Only its real last read releases it.
  assign hub_response_ready=rsp_pop && consumer_count==15;
  assign rsp_push=state==SEND && hub_response_valid && send_count<16;
  assign rsp_data=hub_response[send_count[3:0]*512+:512];
  assign response_empty_n=rsp_valid;
  assign rsp_pop=rsp_valid && response_read;
  laya_private_fifo2_v1 response_fifo(.clk,.rst_n,
    .in_valid(rsp_push),.in_ready(rsp_ready),.in_data(rsp_data),
    .out_valid(rsp_valid),.out_ready(response_read),.out_data(response_dout),
    .occupancy(response_occupancy));
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=COLLECT;ingress_count<=0;collect_count<=0;
      send_count<=0;consumer_count<=0;request<=0;
      dispatch_held<=0;handoff_complete<=0;handoff_pulse<=0;
      revoked<=0;protocol_error<=0;accepted_queries<=0;consumed_responses<=0;
    end else begin
      handoff_pulse<=0;
      if(dispatch_held && (cancel || !configuration_ok))revoked<=1;
      if(command_write && command_full_n)ingress_count<=ingress_count+1'b1;
      if(cmd_valid && cmd_pop)begin
        request[collect_count[3:0]*512+:512]<=cmd_data;
        if(collect_count==15)begin state<=ISSUE;collect_count<=0;end
        else collect_count<=collect_count+1'b1;
      end
      if(request_valid && request_ready)begin
        dispatch_held<=1;revoked<=0;state<=SEND;
        accepted_queries<=accepted_queries+1'b1;
      end
      if(rsp_push && rsp_ready)begin
        if(send_count==15)state<=WAIT_CONSUMER;
        send_count<=send_count+1'b1;
      end
      if(rsp_pop)begin
        consumer_count<=consumer_count+1'b1;
        if(consumer_count==15)begin
          consumed_responses<=consumed_responses+1'b1;
          if(hub_response[10*8+:16]==0 && hub_response[12*8+:32]==255)begin
            // Fail closed if cancel/base changed while a stable response was
            // pending. No stale successful bytes become dispatch authority.
            state<=DONE;
            if(!revoked && !cancel && configuration_ok)begin
              handoff_complete<=1;handoff_pulse<=1;
            end else protocol_error<=1;
          end else begin
            state<=COLLECT;dispatch_held<=0;ingress_count<=0;
            collect_count<=0;send_count<=0;consumer_count<=0;request<=0;
          end
        end
      end
    end
  end
endmodule
