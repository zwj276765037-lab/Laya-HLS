`timescale 1ns/1ps
// Fixed private FIFO transport. A service response is accepted only after the
// enclosing AXI/cache/FP debt ledger is empty. Cancellation never resets it.
module laya_compute_portal_v1 (
  input logic clk,rst_n,cancel,
  input logic [511:0] compute_cmd_din,
  input logic compute_cmd_write,
  output logic compute_cmd_full_n,
  output logic [511:0] compute_rsp_dout,
  output logic compute_rsp_empty_n,
  input logic compute_rsp_read,
  output logic service_command_valid,
  input logic service_command_ready,
  output logic [8191:0] service_command,
  output logic service_cancel,
  input logic service_completion_valid,
  output logic service_completion_ready,
  input logic [4095:0] service_completion,
  input logic physical_debt_zero,
  output logic busy,cancel_pending,protocol_error,
  output logic [31:0] accepted_commands,retired_responses,stale_completions,
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy
);
  import laya_compute_portal_layout_v1::*;
  typedef enum logic [2:0] {COLLECT,CHECK,ISSUE,WAIT_SERVICE,SEND,WAIT_CALLER} state_t;
  state_t state;
  logic [4:0] ingress_count,collect_count;
  logic [3:0] send_count,caller_count;
  // Closed-command high-water survives soft cancellation. rst_n is the
  // safely isolated cold domain; active reset must use cancel/drain.
  logic [63:0] last_generation,active_g;
  logic header_seen,header_trusted;
  logic [4095:0] response;
  logic cmd_push,cmd_ready,cmd_valid,cmd_pop,rsp_push,rsp_ready,rsp_valid,rsp_pop;
  logic [511:0] cmd_data,rsp_data;
  logic completion_match,completion_current,transport_abort,fifo_rst_n;
  assign compute_cmd_full_n=cmd_ready && ingress_count<CMD_BEATS && state==COLLECT && !cancel;
  assign cmd_push=compute_cmd_write && compute_cmd_full_n;
  assign cmd_pop=cmd_valid && state==COLLECT;
  laya_private_fifo2_v1 command_fifo(.clk,.rst_n(fifo_rst_n),.in_valid(cmd_push),.in_ready(cmd_ready),
    .in_data(compute_cmd_din),.out_valid(cmd_valid),.out_ready(state==COLLECT),
    .out_data(cmd_data),.occupancy(command_fifo_occupancy));
  assign rsp_push=state==SEND && send_count<RSP_BEATS;
  assign rsp_data=response[send_count[2:0]*512+:512];
  assign rsp_pop=compute_rsp_empty_n && compute_rsp_read;
  assign compute_rsp_empty_n=rsp_valid && !transport_abort;
  laya_private_fifo2_v1 response_fifo(.clk,.rst_n(fifo_rst_n),.in_valid(rsp_push),.in_ready(rsp_ready),
    .in_data(rsp_data),.out_valid(rsp_valid),.out_ready(compute_rsp_read && !transport_abort),
    .out_data(compute_rsp_dout),.occupancy(response_fifo_occupancy));
  assign busy=state!=COLLECT || ingress_count!=0;
  assign service_command_valid=state==ISSUE && !cancel_pending && !cancel;
  assign service_cancel=cancel_pending || cancel; // Also reaches a hub parent pin between commands.
  assign completion_match=response_binding_ok(service_completion,service_command);
  assign completion_current=service_completion[GENERATION*8+:64]==service_command[GENERATION*8+:64] &&
      service_completion[TASK*8+:32]==service_command[TASK*8+:32];
  // Stale returns are consumed for drainage without authorizing a response.
  assign service_completion_ready=state==WAIT_SERVICE &&
      (!completion_current || physical_debt_zero);
  // A cancelled caller need not finish a partial packet or read an old reply.
  // Only private transport storage is cleared; physical service debt survives.
  assign transport_abort=(cancel && physical_debt_zero && state!=WAIT_SERVICE) ||
      (state==WAIT_SERVICE && (cancel_pending || cancel) &&
       service_completion_valid && service_completion_ready && completion_current);
  assign fifo_rst_n=rst_n && !transport_abort;
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=COLLECT;ingress_count<=0;collect_count<=0;send_count<=0;caller_count<=0;
      last_generation<=0;active_g<=0;header_seen<=0;header_trusted<=0;service_command<=0;response<=0;cancel_pending<=0;
      protocol_error<=0;accepted_commands<=0;retired_responses<=0;stale_completions<=0;
    end else if(transport_abort)begin
      state<=COLLECT;ingress_count<=0;collect_count<=0;send_count<=0;caller_count<=0;
      cancel_pending<=0;
      if(header_seen && header_trusted && active_g>last_generation)last_generation<=active_g;
      header_seen<=0;header_trusted<=0;active_g<=0;
    end else begin
      if(cmd_push)begin
        ingress_count<=ingress_count+1;
        if(ingress_count==0)begin
          header_seen<=1;header_trusted<=command_header_ok(compute_cmd_din);
          active_g<=compute_cmd_din[GENERATION*8+:64];
        end
      end
      if(cancel && busy)cancel_pending<=1;
      if(cmd_pop)begin
        service_command[collect_count*512+:512]<=cmd_data;
        collect_count<=collect_count+1;
        if(collect_count==CMD_BEATS-1)state<=CHECK;
      end
      if(rsp_pop)begin
        caller_count<=caller_count+1;
        if(caller_count==RSP_BEATS-1)begin
          state<=COLLECT;ingress_count<=0;collect_count<=0;send_count<=0;caller_count<=0;
          if(header_seen && header_trusted && active_g>last_generation)last_generation<=active_g;
          header_seen<=0;header_trusted<=0;active_g<=0;
          cancel_pending<=0;retired_responses<=retired_responses+1;
        end
      end
      case(state)
        COLLECT:;
        CHECK:begin
          if(!command_frame_ok(service_command))begin
            response<=rejected_response(service_command,E_ABI,32'h04000014);state<=SEND;
          end else if(service_command[GENERATION*8+:64]<=last_generation || cancel_pending || cancel)begin
            response<=rejected_response(service_command,E_PROTOCOL,32'h04000015);state<=SEND;
          end else state<=ISSUE;
        end
        ISSUE:begin
          if(cancel_pending || cancel)begin
            response<=rejected_response(service_command,E_PROTOCOL,32'h04000015);state<=SEND;
          end else if(service_command_valid && service_command_ready)begin
            accepted_commands<=accepted_commands+1;state<=WAIT_SERVICE;
          end
        end
        WAIT_SERVICE:begin
          if(service_completion_valid && service_completion_ready)begin
            if(!completion_current)begin
              stale_completions<=stale_completions+1;protocol_error<=1;
            end else begin
              if(!completion_match)begin
                response<=rejected_response(service_command,E_PROTOCOL,32'h04000015);
                protocol_error<=1;
              end else response<=service_completion;
              state<=SEND;
            end
          end
        end
        SEND:if(rsp_push && rsp_ready)begin
          send_count<=send_count+1;
          if(send_count==RSP_BEATS-1)state<=WAIT_CALLER;
        end
        WAIT_CALLER:;
        default:state<=COLLECT;
      endcase
    end
  end
endmodule
