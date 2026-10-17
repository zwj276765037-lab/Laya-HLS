`timescale 1ns/1ps
// Generated from actual cache ports. One full-capacity physical cache only.
// The portal holds the full packet through response consumption. Native AXI
// and matrix lease endpoints are exposed for the shared production shell.
module laya_load_portal_binding_v1(
  input logic clk,rst_n,service_cancel,
  input logic service_command_valid,
  output logic service_command_ready,
  input logic [8191:0] service_command,
  output logic service_completion_valid,
  input logic service_completion_ready,
  output logic [4095:0] service_completion,
  input logic physical_debt_zero,
  input logic [12:0][63:0] latched_bo_base,latched_bo_span,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch,
  output logic [1:0][31:0] slot_readers,
  output logic [1:0][3:0][31:0] slot_coverage,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast,
  input logic [2:0] rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast,
  input logic aux_rvalid,
  output logic aux_rready,
  input logic lease_valid,
  output logic lease_ready,
  output logic lease_done,
  output logic lease_error,
  input logic lease_slot,
  input logic [31:0] lease_epoch,
  input logic [31:0] lease_k,
  input logic [31:0] lease_n,
  input logic [15:0] lease_weight_key,
  input logic [3327:0] lease_model_identity,
  input logic [671:0] lease_numeric_identity,
  input logic [95:0] lease_task_context,
  input logic read_valid,
  output logic read_ready,
  output logic read_error,
  input logic read_slot,
  input logic [31:0] read_epoch,
  input logic [15:0] read_tile,
  input logic [7:0] read_group,
  input logic read_pair,
  input logic [3327:0] read_model_identity,
  input logic [671:0] read_numeric_identity,
  input logic [95:0] read_task_context,
  output logic ret_valid,
  input logic ret_ready,
  output logic ret_slot,
  output logic ret_pair,
  output logic [31:0] ret_epoch,
  output logic [15:0] ret_tile,
  output logic [7:0] ret_group,
  output logic [3327:0] ret_model_identity,
  output logic [671:0] ret_numeric_identity,
  output logic [95:0] ret_task_context,
  output logic [1:0][7:0][255:0] ret_q,
  output logic [1:0][7:0][15:0] ret_scale,
  output logic [1:0][7:0][31:0] ret_bias,
  output logic [1:0][7:0] ret_mask,
  input logic release_valid,
  output logic release_ready,
  output logic release_done,
  output logic release_error,
  input logic release_slot,
  input logic [31:0] release_epoch,
  input logic [671:0] release_numeric_identity,
  input logic [95:0] release_task_context
);
  import laya_compute_portal_layout_v1::*;
  logic load_cancel;
  logic load_valid;
  logic load_ready;
  logic load_slot;
  logic [31:0] load_epoch;
  logic [31:0] load_k;
  logic [31:0] load_n;
  logic [15:0] load_weight_key;
  logic [3327:0] load_model_identity;
  logic [1023:0] load_expected_aux_header;
  logic [2:0][63:0] load_base;
  logic [2:0][31:0] load_bytes;
  logic [63:0] load_aux_base;
  logic [63:0] load_bias_base;
  logic [31:0] load_bias_bytes;
  logic load_done;
  logic load_error;
  logic load_reject;
  logic [31:0] load_scale_checks;
  logic [31:0] load_bad_element;
  logic [3:0] commit_ready;
  logic active,response_pending,command_ok,canceled;
  logic [15:0] response_status;
  logic [31:0] response_detail,response_bad,response_checks,response_elements;
  logic [63:0] cycles;
  logic [2:0][64:0] range_end,absolute_base,absolute_end,bo_end;
  logic [64:0] aux_absolute,bias_absolute,aux_end,bias_end,aux_bo_end;
  logic [671:0] numeric_id;
  logic [15:0] k,n;
  function automatic logic shape_ok(input logic [15:0] k,input logic [15:0] n);
    return (k==1024 && (n==3072 || n==1024 || n==5248 || n==4096)) ||
      ((k==2624 || k==4096) && n==1024) || (k==256 && n==2);
  endfunction
  assign numeric_id=service_command[IDENTITY*8+:672];
  assign k=service_command[K*8+:16];assign n=service_command[N*8+:16];
  always_comb begin
    command_ok=command_frame_ok(service_command) && service_command[OP_STATUS*8+:16]==1 &&
      service_command[(CONTEXT+4)*8+:8]==8'h80 && shape_ok(k,n) &&
      numeric_id[63:0]!=0 && numeric_id[127:64]!=0 && numeric_id[143:128]>=1 && numeric_id[143:128]<=2 &&
      numeric_id[159:144]>=64 && numeric_id[159:144]<=1024 &&
      service_command[MODEL_IDENTITY*8+:512]==numeric_id[160+:512] &&
      service_command[W_REF*8+32+:8]==8'h23 &&
      service_command[W_REF*8+40+:8]==service_command[W_SLOT*8+:8] &&
      service_command[W_REF*8+:32]==service_command[W_EPOCH*8+:32] &&
      service_command[W_REF*8+48+:16]==0 && service_command[W_EPOCH*8+:32]!=0 &&
      service_command[BIAS_BYTES*8+:32]==(service_command[BIAS_KIND*8] ? 32'(n)*4 : 0);
    for(int p=0;p<3;p++)begin
      range_end[p]={1'b0,service_command[(WEIGHT_RANGES+p*16)*8+:64]}+
                   {1'b0,service_command[(WEIGHT_RANGES+p*16+8)*8+:64]};
      absolute_base[p]={1'b0,latched_bo_base[p+2]}+
                       {1'b0,service_command[(WEIGHT_RANGES+p*16)*8+:64]};
      absolute_end[p]={1'b0,latched_bo_base[p+2]}+range_end[p];
      bo_end[p]={1'b0,latched_bo_base[p+2]}+{1'b0,latched_bo_span[p+2]};
      load_base[p]=absolute_base[p][63:0];
      load_bytes[p]=service_command[(WEIGHT_RANGES+p*16+8)*8+:32];
      if(range_end[p][64] || absolute_base[p][64] || absolute_end[p][64] || bo_end[p][64] ||
        service_command[(WEIGHT_RANGES+p*16+12)*8+:32]!=0 ||
        range_end[p]>{1'b0,latched_bo_span[p+2]} || load_base[p][5:0]!=0)command_ok=0;
    end
    aux_absolute={1'b0,latched_bo_base[5]}+{1'b0,service_command[AUX_OFFSET*8+:64]};
    bias_absolute={1'b0,latched_bo_base[5]}+{1'b0,service_command[BIAS_OFFSET*8+:64]};
    aux_end=aux_absolute+65'd128;bias_end=bias_absolute+65'(service_command[BIAS_BYTES*8+:32]);
    aux_bo_end={1'b0,latched_bo_base[5]}+{1'b0,latched_bo_span[5]};
    if(aux_absolute[64] || aux_end[64] || aux_bo_end[64] || aux_end>aux_bo_end || aux_absolute[3:0]!=0)command_ok=0;
    if(service_command[BIAS_BYTES*8+:32]!=0 &&
       (bias_absolute[64] || bias_end[64] || bias_end>aux_bo_end || bias_absolute[3:0]!=0))command_ok=0;
  end
  assign service_command_ready=!active && !response_pending && !service_cancel && physical_debt_zero && load_ready;
  assign load_valid=service_command_valid && service_command_ready && command_ok;
  assign load_cancel=active && service_cancel;
  assign load_slot=service_command[W_SLOT*8];assign load_epoch=service_command[W_EPOCH*8+:32];
  assign load_k=32'(k);assign load_n=32'(n);assign load_weight_key=service_command[WEIGHT_KEY*8+:16];
  assign load_model_identity=service_command[MODEL_IDENTITY*8+:3328];
  assign load_expected_aux_header=service_command[EXPECTED_AUX_HEADER*8+:1024];
  assign load_aux_base=aux_absolute[63:0];assign load_bias_base=bias_absolute[63:0];
  assign load_bias_bytes=service_command[BIAS_BYTES*8+:32];assign commit_ready=4'hf;
  // Cancel must invalidate a completed slot and register its error response
  // before a pending completion can handshake on the same edge.
  assign service_completion_valid=response_pending && physical_debt_zero &&
    !(active && service_cancel && !canceled);
  always_comb begin
    service_completion=rejected_response(service_command,response_status,response_detail);
    service_completion[CYCLES*8+:64]=cycles;
    service_completion[COUNTERS*8+:32]=response_checks;
    service_completion[BAD_ELEMENT*8+:64]=response_bad==32'hffffffff ? 64'hffffffffffffffff : 64'(response_bad);
    if(response_status==0 && !service_cancel && !canceled)begin
      service_completion[ELEMENTS*8+:32]=response_elements;
      service_completion[UNIT*8+:8]=3;service_completion[RETIRE_FLAGS*8+1]=1;
    end
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin active<=0;response_pending<=0;canceled<=0;cycles<=0;
      response_status<=0;response_detail<=0;response_bad<='1;response_checks<=0;response_elements<=0;end
    else begin
      if(active && !response_pending)cycles<=cycles+1;
      if(service_command_valid && service_command_ready)begin
        active<=command_ok;canceled<=0;cycles<=0;response_pending<=!command_ok;
        response_status<=command_ok ? 0 : 5;response_detail<=command_ok ? 0 : 32'h04800008;
        response_bad<='1;response_checks<=0;response_elements<=0;
      end
      if(active && service_cancel)begin
        canceled<=1;
        if(response_pending)begin response_status<=7;response_detail<=32'h0780000e;end
      end
      if(active && load_done)begin
        response_pending<=1;response_bad<=load_bad_element;response_checks<=load_scale_checks;
        response_elements<=(((32'(n)+7)&32'hfffffff8)*(32'(k)>>5))*34;
        if(service_cancel || canceled)begin response_status<=7;response_detail<=32'h0780000e;end
        else if(load_error)begin
          response_status<=load_bad_element==32'hffffffff ? 7 : 6;
          response_detail<=load_bad_element==32'hffffffff ? 32'h07800008 : 32'h0780000f;
        end else begin response_status<=0;response_detail<=0;end
      end
      if(service_completion_valid && service_completion_ready)begin active<=0;response_pending<=0;canceled<=0;end
    end
  end
  t4_dual_w_cache_v1 cache(
    .clk,
    .rst_n,
    .load_cancel,
    .load_valid,
    .load_ready,
    .load_slot,
    .load_epoch,
    .load_k,
    .load_n,
    .load_weight_key,
    .load_model_identity,
    .load_expected_aux_header,
    .load_base,
    .load_bytes,
    .load_aux_base,
    .load_bias_base,
    .load_bias_bytes,
    .load_done,
    .load_error,
    .load_reject,
    .load_scale_checks,
    .load_bad_element,
    .slot_state,
    .slot_epoch,
    .slot_readers,
    .slot_coverage,
    .commit_ready,
    .araddr,
    .arlen,
    .arsize,
    .arburst,
    .arvalid,
    .arready,
    .rdata,
    .rresp,
    .rlast,
    .rvalid,
    .rready,
    .aux_araddr,
    .aux_arlen,
    .aux_arsize,
    .aux_arburst,
    .aux_arvalid,
    .aux_arready,
    .aux_rdata,
    .aux_rresp,
    .aux_rlast,
    .aux_rvalid,
    .aux_rready,
    .lease_valid,
    .lease_ready,
    .lease_done,
    .lease_error,
    .lease_slot,
    .lease_epoch,
    .lease_k,
    .lease_n,
    .lease_weight_key,
    .lease_model_identity,
    .lease_numeric_identity,
    .lease_task_context,
    .read_valid,
    .read_ready,
    .read_error,
    .read_slot,
    .read_epoch,
    .read_tile,
    .read_group,
    .read_pair,
    .read_model_identity,
    .read_numeric_identity,
    .read_task_context,
    .ret_valid,
    .ret_ready,
    .ret_slot,
    .ret_pair,
    .ret_epoch,
    .ret_tile,
    .ret_group,
    .ret_model_identity,
    .ret_numeric_identity,
    .ret_task_context,
    .ret_q,
    .ret_scale,
    .ret_bias,
    .ret_mask,
    .release_valid,
    .release_ready,
    .release_done,
    .release_error,
    .release_slot,
    .release_epoch,
    .release_numeric_identity,
    .release_task_context
  );
endmodule
