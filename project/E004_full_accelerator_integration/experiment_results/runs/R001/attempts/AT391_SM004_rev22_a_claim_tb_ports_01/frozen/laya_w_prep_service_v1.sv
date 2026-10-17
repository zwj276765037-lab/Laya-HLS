`timescale 1ns/1ps

// One production W cache shared by legacy clients and fixed cold W_PREP.
`timescale 1ns/1ps

// Local supply/lease candidate, not a production MAC or model authenticator.
// model_identity = {Q8S2 descriptor words 64..151, four 128-bit tags}.
// numeric_identity = {four tags, S:u16, B:u16, generation:u64, request:u64}.
// task_context = {rows:u8,row0:u16,row_space:u8,batch:u8,layer:u8,stage:u8,
//                 op:u8,task_id:u32}. All identity bits are retained/compared.
// Only STRICT is admitted here; static-profile integration is a separate job.
module laya_w_prep_service_v1 #(
  parameter int BANK_DEPTH = 10496,
  parameter int BIAS_DEPTH = 328
) (
  input logic clk, rst_n,
  input logic load_cancel,
  input logic load_valid,
  output logic load_ready,
  input logic load_slot,
  input logic [31:0] load_epoch, load_k, load_n,
  input logic [15:0] load_weight_key,
  input logic [3327:0] load_model_identity,
  input logic [1023:0] load_expected_aux_header,
  input logic [2:0][63:0] load_base,
  input logic [2:0][31:0] load_bytes,
  input logic [63:0] load_aux_base, load_bias_base,
  input logic [31:0] load_bias_bytes,
  output logic load_done, load_error, load_reject,
  // Sticky classification for the most recent LOAD.  Keep load_error as the
  // legacy aggregate; callers must not infer a pure numeric fault from the
  // presence of load_bad_element when transport also failed.
  output logic load_protocol_error, load_numeric_error,
  output logic [31:0] load_scale_checks, load_bad_element,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch, slot_readers,
  output logic [1:0][3:0][31:0] slot_coverage,
  input logic [3:0] commit_ready,

  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,

  input logic lease_valid,
  output logic lease_ready, lease_done, lease_error,
  input logic lease_slot,
  input logic [31:0] lease_epoch, lease_k, lease_n,
  input logic [15:0] lease_weight_key,
  input logic [3327:0] lease_model_identity,
  input logic [671:0] lease_numeric_identity,
  input logic [95:0] lease_task_context,
  input logic read_valid,
  output logic read_ready, read_error,
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
  output logic ret_slot, ret_pair,
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
  output logic release_ready, release_done, release_error,
  input logic release_slot,
  input logic [31:0] release_epoch,
  input logic [671:0] release_numeric_identity,
  input logic [95:0] release_task_context,

  input logic wp_valid,
  output logic wp_ready,
  input logic [31:0] wp_id, wp_source_epoch, wp_epoch,
  input logic [63:0] wp_request, wp_generation,
  input logic [15:0] wp_key,
  input logic [3327:0] wp_model,
  input logic [671:0] wp_numeric,
  input logic [1023:0] wp_header,
  input logic [2:0][63:0] wp_base,
  input logic [2:0][31:0] wp_bytes,
  input logic [63:0] wp_aux_base, wp_bias_base,
  input logic [31:0] wp_bias_bytes,
  output logic wp_done_valid,
  input logic wp_done_ready,
  output logic [31:0] wp_done_id, wp_done_source_epoch, wp_done_epoch,
  output logic [63:0] wp_done_request, wp_done_generation,
  output logic [15:0] wp_done_key,
  output logic [3327:0] wp_done_model,
  output logic [671:0] wp_done_numeric,
  output logic [3:0] wp_done_status,
  output logic [7:0] wp_done_op,
  output logic [15:0] wp_done_check_status,
  output logic [31:0] wp_done_detail,
  output logic [63:0] wp_done_bad64
);
  typedef enum logic [1:0] {WP_IDLE, WP_LOAD, WP_WAIT, WP_DONE} wp_state_t;
  wp_state_t wp_state;
  logic [31:0] q_epoch;
  logic [3327:0] q_model;
  logic [671:0] q_numeric;
  logic [1023:0] q_header;
  logic [2:0][63:0] q_base;
  logic [2:0][31:0] q_bytes;
  logic [63:0] q_aux_base, q_bias_base;
  logic [31:0] q_bias_bytes;
  logic c_load_valid,c_load_ready,c_load_slot;
  logic [31:0] c_load_epoch,c_load_k,c_load_n;
  logic [15:0] c_load_weight_key;
  logic [3327:0] c_load_model_identity;
  logic [1023:0] c_load_expected_aux_header;
  logic [2:0][63:0] c_load_base;
  logic [2:0][31:0] c_load_bytes;
  logic [63:0] c_load_aux_base,c_load_bias_base;
  logic [31:0] c_load_bias_bytes;
  logic c_lease_valid,c_lease_ready,c_read_valid,c_read_ready;
  logic c_release_valid,c_release_ready;
  wire wp_load=wp_state==WP_LOAD;
  assign wp_ready=wp_state==WP_IDLE && !load_valid && !load_cancel &&
      c_load_ready && slot_readers[0]==0 && !ret_valid;
  assign wp_done_valid=wp_state==WP_DONE;
  assign load_ready=wp_state==WP_IDLE && !wp_valid && c_load_ready;
  assign lease_ready=wp_state==WP_IDLE && c_lease_ready;
  assign read_ready=wp_state==WP_IDLE && c_read_ready;
  assign release_ready=wp_state==WP_IDLE && c_release_ready;
  assign c_lease_valid=wp_state==WP_IDLE && lease_valid;
  assign c_read_valid=wp_state==WP_IDLE && read_valid;
  assign c_release_valid=wp_state==WP_IDLE && release_valid;
  assign c_load_valid=wp_load || (wp_state==WP_IDLE && !wp_valid && load_valid);
  assign c_load_slot=wp_load ? 1'b0 : load_slot;
  assign c_load_epoch=wp_load ? q_epoch : load_epoch;
  assign c_load_k=wp_load ? 32'd1024 : load_k;
  assign c_load_n=wp_load ? 32'd3072 : load_n;
  assign c_load_weight_key=wp_load ? wp_done_key : load_weight_key;
  assign c_load_model_identity=wp_load ? q_model : load_model_identity;
  assign c_load_expected_aux_header=wp_load ? q_header : load_expected_aux_header;
  assign c_load_base=wp_load ? q_base : load_base;
  assign c_load_bytes=wp_load ? q_bytes : load_bytes;
  assign c_load_aux_base=wp_load ? q_aux_base : load_aux_base;
  assign c_load_bias_base=wp_load ? q_bias_base : load_bias_base;
  assign c_load_bias_bytes=wp_load ? q_bias_bytes : load_bias_bytes;
  wire wp_desc_ok=wp_id!=0 && wp_source_epoch!=0 &&
      wp_request!=0 && wp_generation!=0 && wp_epoch!=0 &&
      slot_epoch[0]!=32'hffffffff && wp_epoch==slot_epoch[0]+32'd1 &&
      wp_key==16'h0001 && wp_numeric[63:0]==wp_request &&
      wp_numeric[127:64]==wp_generation &&
      wp_bytes[0]==32'd1572864 && wp_bytes[1]==32'd1572864 &&
      wp_bytes[2]==32'd196608 && wp_bias_bytes==0 && wp_aux_base[3:0]==0;
  wire wp_covered=slot_coverage[0][0]==32'd1572864 &&
      slot_coverage[0][1]==32'd1572864 &&
      slot_coverage[0][2]==32'd196608 && slot_coverage[0][3]==0 &&
      load_scale_checks==32'd98304;

  t4_dual_w_cache_v1 #(.BANK_DEPTH(BANK_DEPTH),.BIAS_DEPTH(BIAS_DEPTH)) cache (
    .clk(clk),
    .rst_n(rst_n),
    .load_cancel(load_cancel),
    .load_valid(c_load_valid),
    .load_ready(c_load_ready),
    .load_slot(c_load_slot),
    .load_epoch(c_load_epoch),
    .load_k(c_load_k),
    .load_n(c_load_n),
    .load_weight_key(c_load_weight_key),
    .load_model_identity(c_load_model_identity),
    .load_expected_aux_header(c_load_expected_aux_header),
    .load_base(c_load_base),
    .load_bytes(c_load_bytes),
    .load_aux_base(c_load_aux_base),
    .load_bias_base(c_load_bias_base),
    .load_bias_bytes(c_load_bias_bytes),
    .load_done(load_done),
    .load_error(load_error),
    .load_reject(load_reject),
    .load_protocol_error(load_protocol_error),
    .load_numeric_error(load_numeric_error),
    .load_scale_checks(load_scale_checks),
    .load_bad_element(load_bad_element),
    .slot_state(slot_state),
    .slot_epoch(slot_epoch),
    .slot_readers(slot_readers),
    .slot_coverage(slot_coverage),
    .commit_ready(commit_ready),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),
    .aux_araddr(aux_araddr),
    .aux_arlen(aux_arlen),
    .aux_arsize(aux_arsize),
    .aux_arburst(aux_arburst),
    .aux_arvalid(aux_arvalid),
    .aux_arready(aux_arready),
    .aux_rdata(aux_rdata),
    .aux_rresp(aux_rresp),
    .aux_rlast(aux_rlast),
    .aux_rvalid(aux_rvalid),
    .aux_rready(aux_rready),
    .lease_valid(c_lease_valid),
    .lease_ready(c_lease_ready),
    .lease_done(lease_done),
    .lease_error(lease_error),
    .lease_slot(lease_slot),
    .lease_epoch(lease_epoch),
    .lease_k(lease_k),
    .lease_n(lease_n),
    .lease_weight_key(lease_weight_key),
    .lease_model_identity(lease_model_identity),
    .lease_numeric_identity(lease_numeric_identity),
    .lease_task_context(lease_task_context),
    .read_valid(c_read_valid),
    .read_ready(c_read_ready),
    .read_error(read_error),
    .read_slot(read_slot),
    .read_epoch(read_epoch),
    .read_tile(read_tile),
    .read_group(read_group),
    .read_pair(read_pair),
    .read_model_identity(read_model_identity),
    .read_numeric_identity(read_numeric_identity),
    .read_task_context(read_task_context),
    .ret_valid(ret_valid),
    .ret_ready(ret_ready),
    .ret_slot(ret_slot),
    .ret_pair(ret_pair),
    .ret_epoch(ret_epoch),
    .ret_tile(ret_tile),
    .ret_group(ret_group),
    .ret_model_identity(ret_model_identity),
    .ret_numeric_identity(ret_numeric_identity),
    .ret_task_context(ret_task_context),
    .ret_q(ret_q),
    .ret_scale(ret_scale),
    .ret_bias(ret_bias),
    .ret_mask(ret_mask),
    .release_valid(c_release_valid),
    .release_ready(c_release_ready),
    .release_done(release_done),
    .release_error(release_error),
    .release_slot(release_slot),
    .release_epoch(release_epoch),
    .release_numeric_identity(release_numeric_identity),
    .release_task_context(release_task_context)
  );

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      wp_state<=WP_IDLE;q_epoch<=0;q_model<='0;q_numeric<='0;
      q_header<='0;q_base<='0;q_bytes<='0;
      q_aux_base<=0;q_bias_base<=0;q_bias_bytes<=0;
      wp_done_id<=0;wp_done_source_epoch<=0;wp_done_epoch<=0;
      wp_done_request<=0;wp_done_generation<=0;wp_done_key<=0;
      wp_done_model<='0;wp_done_numeric<='0;
      wp_done_status<=0;wp_done_op<=8'h80;wp_done_check_status<=0;
      wp_done_detail<=0;wp_done_bad64<=64'hffff_ffff_ffff_ffff;
    end else case(wp_state)
      WP_IDLE:if(wp_valid && wp_ready)begin
        q_epoch<=wp_epoch;q_model<=wp_model;q_numeric<=wp_numeric;
        q_header<=wp_header;q_base<=wp_base;q_bytes<=wp_bytes;
        q_aux_base<=wp_aux_base;q_bias_base<=wp_bias_base;
        q_bias_bytes<=wp_bias_bytes;
        wp_done_id<=wp_id;wp_done_source_epoch<=wp_source_epoch;
        wp_done_epoch<=wp_epoch;wp_done_request<=wp_request;
        wp_done_generation<=wp_generation;wp_done_key<=wp_key;
        wp_done_model<=wp_model;wp_done_numeric<=wp_numeric;
        wp_done_status<=0;wp_done_check_status<=0;wp_done_detail<=0;
        wp_done_bad64<=64'hffff_ffff_ffff_ffff;
        if(wp_desc_ok)wp_state<=WP_LOAD;
        else begin
          wp_done_status<=4'd7;wp_done_check_status<=16'd7;
          wp_done_detail<=32'h0780_0005;wp_state<=WP_DONE;
        end
      end
      WP_LOAD:if(c_load_ready)wp_state<=WP_WAIT;
      WP_WAIT:if(load_done)begin
        if(load_reject || load_protocol_error || !wp_covered ||
           slot_epoch[0]!=q_epoch || slot_readers[0]!=0 ||
           (load_error && !load_numeric_error) ||
           (slot_state[0]!=3'd2 && !load_numeric_error))begin
          wp_done_status<=4'd7;wp_done_check_status<=16'd7;
          wp_done_detail<=32'h0780_0005;
          wp_done_bad64<=64'hffff_ffff_ffff_ffff;
        end else if(load_numeric_error)begin
          wp_done_status<=4'd6;wp_done_check_status<=16'd6;
          wp_done_detail<=32'h0780_000f;
          wp_done_bad64<={32'd0,load_bad_element};
        end
        wp_state<=WP_DONE;
      end
      WP_DONE:if(wp_done_ready)wp_state<=WP_IDLE;
      default:wp_state<=WP_IDLE;
    endcase
  end
endmodule
