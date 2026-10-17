`timescale 1ns/1ps
// One persistent transport shared by LOAD, QUANT, MATRIX, and GEGLU.  The
// service number on the validated v2 command selects exactly one endpoint.
// Old completions from another endpoint are drained locally so they cannot
// block a later command; they never enter the caller response path.
module laya_compute_portal_hub_v1 (
  input  logic clk,rst_n,cancel,
  input  logic [511:0] compute_cmd_din,
  input  logic compute_cmd_write,
  output logic compute_cmd_full_n,
  output logic [511:0] compute_rsp_dout,
  output logic compute_rsp_empty_n,
  input  logic compute_rsp_read,
  output logic [3:0] service_command_valid,
  input  logic [3:0] service_command_ready,
  output logic [8191:0] service_command,
  output logic [3:0] service_cancel,
  input  logic [3:0] service_completion_valid,
  output logic [3:0] service_completion_ready,
  input  logic [3:0][4095:0] service_completion,
  input  logic [3:0] service_physical_debt_zero,
  // State such as a rows16 parent pin may remain live between commands.  It
  // does not delay a view response, but it is included in cold-domain drain.
  input  logic [3:0] service_persistent_active,
  output logic transport_busy,cancel_pending,protocol_error,
  output logic hub_busy,domain_drained,
  output logic [2:0] active_service,
  output logic [31:0] accepted_commands,retired_responses,
  output logic [31:0] transport_stale_completions,
  output logic [3:0][31:0] service_accepts,service_completions,
  output logic [3:0][31:0] service_stale_completions,
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy
);
  import laya_compute_portal_layout_v1::*;
  logic transport_command_valid,transport_command_ready;
  logic transport_cancel;
  logic transport_completion_valid,transport_completion_ready;
  logic [4095:0] transport_completion;
  logic global_physical_debt_zero;
  logic active_valid;
  logic [1:0] active_index,issue_index;
  logic issue_service_valid,selected_completion_current;
  logic [15:0] issue_service;

  assign issue_service=service_command[OP_STATUS*8+:16];
  assign issue_service_valid=issue_service>=1 && issue_service<=4;
  assign issue_index=issue_service[1:0]-1'b1;
  assign global_physical_debt_zero=&service_physical_debt_zero;

  always_comb begin
    service_command_valid='0;
    transport_command_ready=1'b0;
    if(transport_command_valid && issue_service_valid)begin
      service_command_valid[issue_index]=1'b1;
      transport_command_ready=service_command_ready[issue_index];
    end
  end
  assign service_cancel={4{transport_cancel}};

  always_comb begin
    transport_completion_valid=1'b0;
    transport_completion='0;
    service_completion_ready='0;
    if(active_valid)begin
      transport_completion_valid=service_completion_valid[active_index];
      transport_completion=service_completion[active_index];
      service_completion_ready[active_index]=transport_completion_ready;
      for(int i=0;i<4;i++)begin
        if(i!=active_index)
          service_completion_ready[i]=service_physical_debt_zero[i];
      end
    end else begin
      // No command owns the response path.  Any held completion belongs to a
      // cancelled/older command and is safe to discard only after its service
      // reports all non-cancellable physical debt retired.
      for(int i=0;i<4;i++)
        service_completion_ready[i]=service_physical_debt_zero[i];
    end
  end

  assign selected_completion_current=active_valid &&
      service_completion_valid[active_index] &&
      service_completion[active_index][GENERATION*8+:64]==
        service_command[GENERATION*8+:64] &&
      service_completion[active_index][TASK*8+:32]==
        service_command[TASK*8+:32];
  assign active_service=active_valid ? {1'b0,active_index}+3'd1 : 3'd0;
  assign hub_busy=transport_busy || active_valid ||
                  (|service_persistent_active) ||
                  (|service_completion_valid);
  assign domain_drained=!cancel && !transport_busy && !active_valid &&
      global_physical_debt_zero && !(|service_persistent_active) &&
      !(|service_completion_valid);

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      active_valid<=1'b0;active_index<='0;
      service_accepts<='0;service_completions<='0;
      service_stale_completions<='0;
    end else begin
      if(transport_command_valid && transport_command_ready)begin
        active_valid<=1'b1;active_index<=issue_index;
        service_accepts[issue_index]<=service_accepts[issue_index]+1'b1;
      end
      for(int i=0;i<4;i++)begin
        if(service_completion_valid[i] && service_completion_ready[i])begin
          service_completions[i]<=service_completions[i]+1'b1;
          if(!active_valid || i!=active_index ||
             service_completion[i][GENERATION*8+:64]!=
               service_command[GENERATION*8+:64] ||
             service_completion[i][TASK*8+:32]!=
               service_command[TASK*8+:32])
            service_stale_completions[i]<=service_stale_completions[i]+1'b1;
        end
      end
      // A current completion ends endpoint ownership even when another bound
      // field is malformed; the transport converts that case to a rejection.
      if(selected_completion_current &&
         service_completion_ready[active_index])active_valid<=1'b0;
    end
  end

  laya_compute_portal_v1 transport(
    .clk,.rst_n,.cancel,
    .compute_cmd_din,.compute_cmd_write,.compute_cmd_full_n,
    .compute_rsp_dout,.compute_rsp_empty_n,.compute_rsp_read,
    .service_command_valid(transport_command_valid),
    .service_command_ready(transport_command_ready),
    .service_command,
    .service_cancel(transport_cancel),
    .service_completion_valid(transport_completion_valid),
    .service_completion_ready(transport_completion_ready),
    .service_completion(transport_completion),
    .physical_debt_zero(global_physical_debt_zero),
    .busy(transport_busy),.cancel_pending,.protocol_error,
    .accepted_commands,.retired_responses,
    .stale_completions(transport_stale_completions),
    .command_fifo_occupancy,.response_fifo_occupancy
  );
endmodule
