`timescale 1ns/1ps
module laya_lnq0_admission_binding_tb_v1;
  import laya_compute_portal_layout_v1::*;
  import laya_lnq0_bound_identity_generated_v1::*;
  logic clk=0,rst_n=0;
  always #5 clk=~clk;
  logic candidate_valid=0,candidate_ready,candidate_reject;
  logic [8191:0] candidate_command=0;
  logic bridge_can_accept=0,bridge_ext_valid,bridge_ext_ready=1;
  logic bridge_ext_reject=0,bridge_done_valid=0,bridge_done_ready;
  logic candidate_done_ready=0,physical_r_debt_zero=0;
  logic source_query_valid,source_query_ready=0,source_query_granted=0;
  logic [8191:0] source_query_command,source_release_command;
  logic source_release_valid,source_release_ready=0,source_release_drained;
  logic lease_pending,protocol_error;
  logic ext_owner_admitted,ext_source_published,ext_a_slot;
  logic [31:0] ext_a_slot_epoch;
  logic [671:0] ext_numeric_identity;
  logic [95:0] ext_producer_context,ext_quant_context,ext_linear_context;
  logic [63:0] ext_source_ref,ext_a_ref,ext_w_ref,ext_dst_ref;
  logic [12:0] ext_K;
  logic [4:0] ext_rows;
  logic [63:0] ext_bo_base,ext_bo_span,ext_region_base,ext_region_span;
  logic [63:0] ext_row_stride_bytes,ext_batch_stride_bytes;
  laya_lnq0_external_quant_admission_v1 q_admit(.*);

  logic request_valid=0,request_ready,request_reject,cache_ready=1,cache_valid;
  logic [3327:0] model_identity=W_IDENTITY;
  logic [1023:0] expected_aux_header=AUX_HEADER;
  logic [63:0] aux_base=AUX_BASE;
  logic [2:0][63:0] load_base;
  logic [2:0][31:0] load_bytes;
  logic [15:0] K=1024,N=5248,weight_key=3;
  logic [31:0] bias_bytes=0;
  laya_lnq0_w_binding_v1 w_bind(.*);

  logic [511:0] query_words[0:15];
  string query_hex;
  task automatic step; @(posedge clk); #1; endtask
  initial begin
    if(!$value$plusargs("QUERY_HEX=%s",query_hex))$fatal(1,"missing query fixture");
    $readmemh(query_hex,query_words);
    for(int i=0;i<16;i++)candidate_command[i*512+:512]=query_words[i];
    // Same original LN_FFN source packet, with the downstream Wi opcode.
    candidate_command[LINEAR_CONTEXT*8+32+:8]=8'h32;
    candidate_command[FUTURE_DST_REF*8+:64]=64'h0000000600000001;
    if(!command_frame_ok(candidate_command))$fatal(1,"source packet invalid");
    load_base[0]=W_Q0_BASE+64'h3800000;
    load_base[1]=W_Q1_BASE+64'h3800000;
    load_base[2]=W_SCALE_BASE+64'h700000;
    load_bytes[0]=32'h290000;load_bytes[1]=32'h290000;
    load_bytes[2]=32'h52000;
    repeat(3)step(); @(negedge clk);rst_n=1;
    // A held external request cannot acquire a source lease while G owns
    // admission, or while the real provenance hub is busy.
    candidate_valid=1;step();
    if(candidate_ready || source_query_valid || bridge_ext_valid)
      $fatal(1,"Q admitted while bridge unavailable");
    @(negedge clk);bridge_can_accept=1;step();
    if(candidate_ready || !source_query_valid || bridge_ext_valid)
      $fatal(1,"Q escaped a busy source hub");
    @(negedge clk);source_query_ready=1;source_query_granted=0;
    step();
    if(!candidate_reject || bridge_ext_valid || lease_pending)
      $fatal(1,"source rejection produced a Q owner");
    @(negedge clk);candidate_valid=0;step();
    if(candidate_reject)$fatal(1,"duplicate reject");
    @(negedge clk);source_query_granted=1;candidate_valid=1;
    #1;
    if(!candidate_ready || !source_query_valid || !bridge_ext_valid ||
       !ext_owner_admitted || !ext_source_published ||
       ext_region_base!=64'h300800000)
      $fatal(1,"source grant and Q acceptance were not atomic");
    step();
    if(!lease_pending || protocol_error)$fatal(1,"granted lease missing");
    @(negedge clk);candidate_valid=0;bridge_done_valid=1;
    repeat(7)begin
      step();if(!lease_pending || source_release_valid || bridge_done_ready)
        $fatal(1,"Q response hold lost source lease");
    end
    @(negedge clk);candidate_done_ready=1;step();
    @(negedge clk);bridge_done_valid=0;candidate_done_ready=0;
    repeat(3)begin
      step();if(!lease_pending || source_release_valid)
        $fatal(1,"Q lease released before physical R debt retired");
    end
    @(negedge clk);physical_r_debt_zero=1;step();
    #1;if(!source_release_valid || source_release_command!==candidate_command)
      $fatal(1,"saved complete source key not offered for release");
    repeat(3)begin step();if(!lease_pending || !source_release_valid)
      $fatal(1,"release backpressure lost lease");end
    @(negedge clk);source_release_ready=1;step();
    if(lease_pending || source_release_valid || protocol_error)
      $fatal(1,"release did not complete");

    // A real cache request is blocked by the adapter on a wrong physical
    // load base, then the original Wi descriptor is accepted unchanged.
    @(negedge clk);load_base[1]=W_Q1_BASE+64'h3800040;request_valid=1;
    #1;if(cache_valid || !request_ready)$fatal(1,"bad W base reached cache");
    step();if(!request_reject || cache_valid)$fatal(1,"bad W base not rejected");
    @(negedge clk);request_valid=0;load_base[1]=W_Q1_BASE+64'h3800000;
    step();if(request_reject)$fatal(1,"duplicate W rejection");
    @(negedge clk);request_valid=1;#1;
    if(!cache_valid || !request_ready)$fatal(1,"valid W binding denied");
    step();if(request_reject)$fatal(1,"valid W binding rejected");
    $display("LNQ0_ADMISSION_BINDING_PASS no_early_grant=1 held_response=7 debt_fence=1 full_key_release=1 bad_W_zero_cache_valid=1");
    $finish;
  end
endmodule
