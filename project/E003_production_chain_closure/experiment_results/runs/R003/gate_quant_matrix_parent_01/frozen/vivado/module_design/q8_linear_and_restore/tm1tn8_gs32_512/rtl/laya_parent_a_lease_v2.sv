`timescale 1ns/1ps
// One parent pin over the real full-A cache. Local view grants are backed by a
// successfully acquired physical lease; only the last view or safe cancellation
// reaches the cache's destructive release. Read/return ports remain direct.
module laya_parent_a_lease_v2(
  input logic clk,rst_n,cancel,
  input logic view_valid,
  output logic view_ready,view_admitted,view_rejected,
  input logic [8191:0] view_command,
  input logic view_done,physical_debt_zero,
  output logic parent_live,parent_pinned,cancel_done,
  output logic [63:0] origin_generation,active_generation,
  output logic [4:0] next_row,
  input logic local_acquire_valid,
  output logic local_acquire_ready,local_acquire_done,local_acquire_error,
  input logic [1010:0] local_acquire_handle,
  output logic physical_acquire_valid,
  input logic physical_acquire_ready,physical_acquire_done,physical_acquire_error,
  output logic [1010:0] physical_acquire_handle,
  input logic local_release_valid,
  output logic local_release_ready,local_release_done,local_release_error,
  input logic [864:0] local_release_handle,
  output logic physical_release_valid,
  input logic physical_release_ready,physical_release_done,physical_release_error,
  output logic [864:0] physical_release_handle
);
  import laya_compute_portal_layout_v1::*;
  localparam int KEY_BITS=5336;
  logic [KEY_BITS-1:0] parent_key;
  logic [1010:0] acquire_handle;
  logic [864:0] release_handle;
  logic view_active,view_released,aborting,acquire_pending,release_pending,release_for_view;
  logic [4:0] view_end,parent_rows;
  logic acquire_match,release_match,last_view;
  function automatic logic [KEY_BITS-1:0] key(input logic [8191:0] c);
    return {c[IDENTITY*8+:672],c[PRODUCER_CONTEXT*8+:288],c[SOURCE_REF*8+:320],
      c[MODEL_IDENTITY*8+:3328],c[K*8+:32],c[A_SLOT*8+:16],c[A_EPOCH*8+:64],
      c[WEIGHT_KEY*8+:24],c[FUTURE_DST_REF*8+:64],c[OUT0_ROLE*8+:16],
      c[OUTPUT_RANGES*8+:384],c[ROW_STRIDE*8+:128]};
  endfunction
  function automatic logic [1010:0] command_acquire(input logic [8191:0] c);
    return {c[A_SLOT*8],c[A_EPOCH*8+:32],c[K*8+:13],c[(LINEAR_CONTEXT+11)*8+:5],
      c[IDENTITY*8+:672],c[LINEAR_CONTEXT*8+:96],c[A_REF*8+:64],c[W_REF*8+:64],c[DST_REF*8+:64]};
  endfunction
  function automatic logic [864:0] command_release(input logic [8191:0] c);
    return {c[A_SLOT*8],c[A_EPOCH*8+:32],c[IDENTITY*8+:672],c[LINEAR_CONTEXT*8+:96],c[A_REF*8+:64]};
  endfunction
  assign view_ready=rst_n && !view_active && !aborting && !cancel && !acquire_pending && !release_pending;
  assign view_admitted=view_ready && command_frame_ok(view_command) && view_command[OP_STATUS*8+:16]==3 &&
    (parent_live ? parent_pinned && key(view_command)==parent_key &&
      view_command[ROW_BLOCK*8+:8]==next_row && view_command[GENERATION*8+:64]>active_generation :
      view_command[ROW_BLOCK*8+:8]==0);
  assign acquire_match=local_acquire_handle==acquire_handle;
  assign release_match=local_release_handle==release_handle;
  assign last_view=view_end==parent_rows;
  assign physical_acquire_handle=acquire_handle;
  assign physical_release_handle=release_handle;
  assign physical_acquire_valid=view_active && !view_released && !parent_pinned && !aborting && !cancel &&
    local_acquire_valid && acquire_match && !acquire_pending && !local_acquire_done;
  assign local_acquire_ready=view_active && !view_released && !aborting && !cancel && !acquire_pending &&
    !local_acquire_done && (parent_pinned || !acquire_match || physical_acquire_ready);
  // Do not release the parent before actual read/FP/AXI debt has drained.
  assign physical_release_valid=parent_pinned && physical_debt_zero && !release_pending &&
    !local_release_done && !physical_release_done &&
    ((view_active && !view_released && local_release_valid && release_match && (last_view || aborting || cancel)) ||
      (aborting && !view_active));
  assign local_release_ready=view_active && !view_released && parent_pinned && physical_debt_zero &&
    !release_pending && !local_release_done &&
    (!release_match || (!(last_view || aborting || cancel)) || physical_release_ready);
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      parent_live<=0;parent_pinned<=0;view_active<=0;view_released<=0;aborting<=0;
      acquire_pending<=0;release_pending<=0;release_for_view<=0;
      view_rejected<=0;cancel_done<=0;local_acquire_done<=0;local_acquire_error<=0;
      local_release_done<=0;local_release_error<=0;next_row<=0;view_end<=0;parent_rows<=0;
      origin_generation<=0;active_generation<=0;parent_key<=0;acquire_handle<=0;release_handle<=0;
    end else begin
      view_rejected<=0;cancel_done<=0;local_acquire_done<=0;local_acquire_error<=0;
      local_release_done<=0;local_release_error<=0;
      if(cancel && parent_live)aborting<=1;
      if(view_valid && view_ready)begin
        view_rejected<=!view_admitted;
        if(view_admitted)begin
          view_active<=1;view_released<=0;active_generation<=view_command[GENERATION*8+:64];
          view_end<=5'(view_command[ROW_BLOCK*8+:8])+5'(view_command[ROWS*8+:8]);
          if(!parent_live)begin
            parent_live<=1;parent_key<=key(view_command);origin_generation<=view_command[GENERATION*8+:64];
            acquire_handle<=command_acquire(view_command);release_handle<=command_release(view_command);
            parent_rows<=view_command[(LINEAR_CONTEXT+11)*8+:5];next_row<=0;
          end
        end
      end
      if(local_acquire_valid && local_acquire_ready)begin
        if(!acquire_match || parent_pinned)begin
          local_acquire_done<=1;local_acquire_error<=!acquire_match;
        end else acquire_pending<=1;
      end
      if(acquire_pending && physical_acquire_done)begin
        acquire_pending<=0;local_acquire_done<=1;local_acquire_error<=physical_acquire_error;
        if(!physical_acquire_error)parent_pinned<=1;
      end
      if(local_release_valid && local_release_ready)begin
        if(!release_match)begin local_release_done<=1;local_release_error<=1;end
        else if(!(last_view || aborting || cancel))begin
          local_release_done<=1;view_released<=1;next_row<=view_end;
        end
      end
      if(physical_release_valid && physical_release_ready)begin
        release_pending<=1;release_for_view<=view_active;
      end
      if(release_pending && physical_release_done)begin
        release_pending<=0;
        if(release_for_view)begin local_release_done<=1;local_release_error<=physical_release_error;view_released<=1;end
        if(!physical_release_error)begin
          parent_pinned<=0;parent_live<=0;next_row<=0;
          if(aborting || cancel)begin aborting<=0;cancel_done<=1;end
        end
      end
      if(view_done && view_active)begin
        view_active<=0;
        if(!parent_pinned && !acquire_pending)begin parent_live<=0;aborting<=0;end
      end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    if(local_acquire_done && !local_acquire_error)assert(parent_pinned)
      else $fatal(1,"local view grant without a real parent A lease");
    if(physical_release_valid)assert(parent_pinned && physical_debt_zero)
      else $fatal(1,"physical parent release before real drain");
    if(view_done)assert(view_released || !parent_pinned)
      else $fatal(1,"view completion before its A use ended");
  end
`endif
endmodule
