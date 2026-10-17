`timescale 1ns/1ps
// Exercises the production bank/LNQ/prep/Q16 service without the inactive
// W-cache, matrix, G, residual or RoPE instances.
module laya_rev22_matrix_first_tn8_local_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0;
  logic cmd_valid=0,cmd_ready,done_valid,done_ready=0;
  logic [3:0] done_status;
  logic [31:0] done_bad;
  logic [31:0] cmd_id=0,cmd_epoch=1;
  logic [6:0] cmd_row=0;
  logic [1:0] match_kind=2'b10;
  logic staged_ln_cmd_valid=0,staged_ln_cmd_ready;
  logic staged_ln_view_valid,staged_ln_rd_valid=0;
  logic [9:0] staged_ln_rd_tile=0;
  logic staged_ln_rd_ready,staged_ln_done_valid;
  logic staged_ln_done_ready=0;
  logic [3:0] staged_ln_done_status,staged_ln_done_phase;
  logic [31:0] staged_ln_done_bad;
  logic [31:0] staged_ln_done_id,staged_ln_done_epoch;
  logic [6:0] staged_ln_done_row;
  logic [2:0] staged_ln_result_exec;
  logic [7:0] staged_ln_done_op;
  logic [15:0] staged_ln_done_check_status;
  logic [31:0] staged_ln_done_detail;
  logic [63:0] staged_ln_done_bad64;
  logic result_rsp_valid,result_rsp_ready,result_pending;
  logic [9:0] result_rsp_tile;
  logic [255:0] result_rsp_bits;
  logic ps_store_valid;
  logic [9:0] ps_store_tile;
  logic [255:0] ps_store_bits;
  logic g_x_read_valid=0,g_gate_read_valid=0,g_store_valid=0;
  logic [8:0] g_x_read_tile=0;
  logic [9:0] g_gate_read_tile=0;
  logic [11:0] g_store_index=0;
  logic [31:0] g_store_bits=0;
  logic [255:0] g_x_hold,g_gate_hold;
  logic qd_read_valid=0,res_read_valid=0,res_store_valid=0;
  logic [12:0] qd_read_word=0;
  logic [9:0] res_read_index=0,res_store_index=0;
  logic [31:0] qd_word,res_b_hold,res_store_bits=0;
  logic [3327:0] model_identity=0;
  logic [671:0] numeric_identity=0;
  logic prep_begin_valid=0,prep_begin_ready;
  logic [1:0] prep_kind=2'b10;
  logic [31:0] prep_id=0,prep_epoch=1;
  logic [6:0] prep_row=0;
  logic prep_write_valid=0,prep_write_ready;
  logic [10:0] prep_write_index=0;
  logic [31:0] prep_write_bits=0;
  logic prep_commit_valid=0,prep_commit_ready;
  logic prep_abort_valid=0,prep_abort_ready;
  logic prep_active,prep_token_valid,gamma_token_valid,prep_fault;
  logic a_window_ready,a_window_release_valid,a_window_discard;
  logic a_window_release_ready,q16_partial_owned,q16_window_ok;
  logic [6:0] a_window_base;
  logic [31:0] a_window_id,a_window_epoch,a_window_source_epoch;
  logic [3327:0] a_window_model;
  logic [671:0] a_window_numeric;
  logic [15:0] a_window_cover;
  logic a_claim_valid,a_claim_ready,a_claim_error,a_matrix_owned;
  logic [31:0] a_claim_id,a_claim_epoch,a_claim_source_epoch;
  logic [6:0] a_claim_base;
  logic [4:0] q16_next_row;
  laya_lnq_bank_link_v1 link();
  logic matrix_cmd_valid=0,matrix_cmd_ready,matrix_done_valid;
  logic [3:0] matrix_done_status;
  logic ps_tile_valid,ps_retire_ready;
  logic [9:0] ps_tile;
  logic [31:0] actual_a_reads,actual_a_returns,actual_w_reads,
      actual_w_returns,actual_stripes,actual_row_retired,
      actual_terminal,actual_ps_retired;
  logic w_lease_valid,w_lease_ready=1,w_lease_done=0;
  logic w_read_valid,w_read_ready=1,w_read_error=0;
  logic w_ret_valid=0,w_ret_ready;
  logic [15:0] w_read_tile,w_ret_tile;
  logic [7:0] w_read_group,w_ret_group;
  logic [31:0] w_ret_epoch;
  logic [3327:0] w_ret_model_identity;
  logic [671:0] w_ret_numeric_identity;
  logic [95:0] w_ret_task_context;
  logic [1:0][7:0][255:0] w_ret_q;
  logic [1:0][7:0][15:0] w_ret_scale;
  logic [1:0][7:0] w_ret_mask;
  logic [511:0] wq0[0:24575],wscale[0:3071];
  int ps_store_count=0;
  assign a_claim_valid=link.a_claim_valid;
  assign a_claim_id=link.a_claim_id;
  assign a_claim_epoch=link.a_claim_epoch;
  assign a_claim_source_epoch=link.a_claim_source_epoch;
  assign a_claim_base=link.a_claim_base;
  assign link.a_claim_ready=a_claim_ready;
  assign link.a_claim_error=a_claim_error;
  assign link.a_window_release_ready=a_window_release_ready;
  assign a_window_release_valid=link.matrix_a_release_valid;
  assign a_window_discard=link.matrix_a_release_discard;
  assign link.matrix_result_ready=!result_pending && !result_rsp_valid;
  assign link.result_pending=result_pending;
  assign link.result_rsp_valid=result_rsp_valid;
  assign link.result_rsp_tile=result_rsp_tile;
  assign link.result_rsp_bits=result_rsp_bits;
  assign result_rsp_ready=link.matrix_result_rsp_ready;
  assign ps_store_valid=link.matrix_ps_store_valid;
  assign ps_store_tile=link.matrix_ps_store_tile;
  assign ps_store_bits=link.matrix_ps_store_bits;
  always @(posedge clk)if(rst_n && ps_store_valid)
    ps_store_count<=ps_store_count+1;
  always @(posedge clk)if(rst_n)begin
    w_lease_done<=w_lease_valid && w_lease_ready;
    w_ret_valid<=w_read_valid && w_read_ready;
    if(w_read_valid && w_read_ready)begin
      w_ret_tile<=w_read_tile;w_ret_group<=w_read_group;
      w_ret_epoch<=32'd1;
      w_ret_model_identity<=model_identity;
      w_ret_numeric_identity<=numeric_identity;
      w_ret_task_context<=96'h100000000000000000000000;
      for(int lane=0;lane<8;lane++)begin
        w_ret_q[0][lane]<=wq0[int'(w_read_tile)*128+
            int'(w_read_group)*4+lane/2][(lane%2)*256+:256];
        w_ret_scale[0][lane]<=wscale[(int'(w_read_tile)*32+
            int'(w_read_group))/4][((int'(w_read_group)%4)*8+lane)*16+:16];
      end
      w_ret_mask[0]<=8'hff;
    end
  end
  laya_matrix_service_v1 matrix_u (
    .clk,.rst_n,.bank_link(link),
    .cmd_valid(matrix_cmd_valid),.cmd_ready(matrix_cmd_ready),
    .cmd_id(32'd100),.cmd_window_row0(7'd0),
    .cmd_source_epoch(32'd1),.cmd_a_epoch(32'd1),
    .cmd_w_epoch(32'd1),.cmd_w_key(16'h0001),
    .cmd_model(model_identity),.cmd_numeric(numeric_identity),
    .cmd_task_context(96'h100000000000000000000000),
    .done_valid(matrix_done_valid),.done_ready(1'b0),
    .done_status(matrix_done_status),
    .ps_tile_valid,.ps_tile,.ps_retire_valid(1'b0),
    .ps_retire_error(1'b0),.ps_retire_ready,
    .actual_a_reads,.actual_a_returns,.actual_w_reads,
    .actual_w_returns,.actual_stripes,.actual_row_retired,
    .actual_terminal,.actual_ps_retired,
    .w_lease_valid,.w_lease_ready,.w_lease_done,
    .w_lease_error(1'b0),
    .w_read_valid,.w_read_ready,.w_read_error,
    .w_read_tile,.w_read_group,
    .w_ret_valid,.w_ret_ready,.w_ret_slot(1'b0),
    .w_ret_pair(1'b0),.w_ret_epoch,.w_ret_tile,.w_ret_group,
    .w_ret_model_identity,.w_ret_numeric_identity,
    .w_ret_task_context,.w_ret_q,.w_ret_scale,.w_ret_mask,
    .w_release_ready(1'b1),.w_release_done(1'b1),
    .w_release_error(1'b0)
  );
  logic ln_rsp_valid;
  int cycle=0,q_rsp_count=0;

  laya_lnq_bank_service_v1 dut (
    .clk,.rst_n,
    .ln_cmd_valid(1'b0),.ln_cmd_ready(),
    .ln_source_mode(2'b00),.ln_gamma_kind(2'b00),
    .ln_cmd_row(16'd0),.ln_only_ready(1'b0),
    .staged_ln_cmd_valid,.staged_ln_cmd_ready,
    .staged_ln_row(cmd_row),.staged_ln_view_valid,
    .staged_ln_rd_valid,.staged_ln_rd_tile,
    .staged_ln_rd_ready,.staged_ln_release_valid(1'b0),
    .staged_ln_release_discard(1'b0),.staged_ln_release_ready(),
    .staged_ln_done_valid,.staged_ln_done_ready,
    .staged_ln_done_status,.staged_ln_done_phase,
    .staged_ln_done_bad,
    .staged_ln_done_id,.staged_ln_done_epoch,.staged_ln_done_row,
    .staged_ln_result_exec,.staged_ln_done_op,
    .staged_ln_done_check_status,.staged_ln_done_detail,
    .staged_ln_done_bad64,
    .ln_x_valid(1'b0),.ln_x_ready(),.ln_x_bits(32'd0),
    .ln_gamma_valid(1'b0),.ln_gamma_ready(),.ln_gamma_bits(32'd0),
    .ln_row_valid(),.ln_rd_valid(1'b0),.ln_rd_ready(),
    .ln_rd_group(7'd0),.ln_rsp_valid,
    .ln_rsp_ready(1'b0),.ln_rsp_group(),.ln_rsp_q(),.ln_rsp_scale(),
    .ln_release_valid(1'b0),.ln_release_ready(),
    .ln_done_valid(),.ln_done_ready(1'b0),
    .ln_done_status(),.ln_done_bad(),
    .ln_mean(),.ln_variance(),.ln_inverse(),
    .norm_valid(),.norm_index(),.norm_bits(),
    .q16_fill_cmd_valid(cmd_valid),.q16_fill_cmd_ready(cmd_ready),
    .q16_fill_done_valid(done_valid),.q16_fill_done_ready(done_ready),
    .q16_fill_done_status(done_status),.q16_fill_done_bad(done_bad),
    .q16_retire_success(done_valid && done_ready && done_status==0),
    .q16_window_begin(cmd_valid && cmd_ready && q16_next_row==0),
    .q16_row(cmd_row),.q16_epoch(cmd_epoch),
    .q16_model(model_identity),.q16_numeric(numeric_identity),
    .q16_done(),.q16_fault(),.q16_partial_owned,.q16_window_ok,
    .q16_next_row,.a_window_ready,
    .a_window_base,.a_window_id,.a_window_epoch,
    .a_window_source_epoch,.a_window_model,.a_window_numeric,
    .a_window_cover,.a_claim_valid,.a_claim_ready,.a_claim_error,
    .a_matrix_owned,.a_claim_id,.a_claim_epoch,.a_claim_source_epoch,
    .a_claim_base,.a_claim_model(link.a_claim_model),
    .a_claim_numeric(link.a_claim_numeric),
    .a_window_release_valid,.a_window_discard,.a_window_release_ready,
    .bank_idle(1'b1),.prep_begin_idle(!cmd_valid),
    .prep_begin_allow(1'b1),
    .prep_begin_valid,.prep_begin_ready,.prep_kind,.prep_id,.prep_row,
    .prep_epoch,.prep_model_identity(model_identity),
    .prep_numeric_identity(numeric_identity),
    .prep_gamma_aux_base(64'd0),.prep_gamma_aux_span(64'd0),
    .prep_write_valid,.prep_write_ready,.prep_write_index,.prep_write_bits,
    .prep_commit_valid,.prep_commit_ready,
    .prep_abort_valid,.prep_abort_ready,
    .prep_active,.prep_token_valid,.gamma_token_valid,.prep_fault,
    .prep_consume(cmd_valid && cmd_ready),
    .match_id(cmd_id),.match_row(cmd_row),.match_epoch(cmd_epoch),
    .match_model_identity(model_identity),
    .match_numeric_identity(numeric_identity),
    .match_kind,.match_gamma_aux_base(64'd0),
    .match_gamma_aux_span(64'd0),
    .prepared_basic_match(),.prepared_match(),.gamma_match(),
    .norm_store_valid(1'b0),.norm_store_index(10'd0),
    .norm_store_bits(32'd0),
    .ps_store_valid,.ps_store_tile,.ps_store_bits,
    .g_store_valid,.g_store_index,.g_store_bits,
    .res_store_valid,.res_store_index,.res_store_bits,
    .feed_start(1'b0),.feed_active(1'b0),.feed_state(),.replay_hold(),
    .result_reset(1'b0),.result_accept(link.matrix_result_accept),
    .result_physical_addr(link.matrix_result_physical_addr),
    .result_logical_tile(link.matrix_result_logical_tile),
    .result_pending,.result_rsp_valid,.result_rsp_ready,
    .result_rsp_tile,.result_rsp_bits,
    .g_x_read_valid,.g_x_read_tile,.g_x_hold,
    .g_gate_read_valid,.g_gate_read_tile,.g_gate_hold,
    .qd_read_valid,.qd_read_word,.qd_word,
    .res_read_valid,.res_read_index,.res_b_hold
  );
  logic [3327:0] model_rom[0:0];
  logic [31:0] norm_all[0:131071],observed[0:4351];
  logic [31:0] raw0[0:1023],gamma[0:1023];
  logic [255:0] qgold[0:127];
  logic [15:0] scalegold[0:127];
  string fixture;
  always @(posedge clk)if(rst_n)begin
    cycle<=cycle+1;
    if(ln_rsp_valid && dut.lnq.rsp_ready)q_rsp_count<=q_rsp_count+1;
    if(cycle>200000)$fatal(1,"SHARED_Q16_CYCLE_CAP");
  end
  task automatic prepare_norm(input int r,input int epoch);
    @(negedge clk);
    prep_id=32'(100+r);prep_row=7'(r);prep_epoch=32'(epoch);
    prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"SHARED_Q16_BEGIN row=%0d",r);
    @(negedge clk);prep_begin_valid=0;
    for(int i=0;i<1024;i++)begin
      if(r==15 && i==1023)begin
        prep_write_valid=0;
        repeat(4)@(negedge clk);
      end
      prep_write_valid=1;prep_write_index=11'(i);
      prep_write_bits=norm_all[r*1024+i];
      #1ps;if(!prep_write_ready)
        $fatal(1,"SHARED_Q16_PREP_WRITE row=%0d word=%0d",r,i);
      @(negedge clk);
    end
    prep_write_valid=0;prep_commit_valid=1;
    #1ps;if(!prep_commit_ready)$fatal(1,"SHARED_Q16_COMMIT row=%0d",r);
    @(negedge clk);prep_commit_valid=0;
    if(!prep_token_valid || prep_begin_ready)$fatal(1,"SHARED_Q16_TOKEN row=%0d",r);
  endtask
  task automatic run_row(input int r,input int epoch);
    int rsp_before;
    @(negedge clk);
    rsp_before=q_rsp_count;
    cmd_id=32'(100+r);cmd_row=7'(r);cmd_epoch=32'(epoch);
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"SHARED_Q16_CMD row=%0d",r);
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<50000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 ||
       done_bad!=32'hffffffff || q_rsp_count!=rsp_before+32)
      $fatal(1,"SHARED_Q16_DONE row=%0d status=%0d rsp=%0d",
             r,done_status,q_rsp_count);
    for(int g=0;g<32;g++)for(int lane=0;lane<8;lane++)begin
      int w;logic [31:0] expected;
      w=272*(r%16)+8*g+lane;
      expected=qgold[r*32+g][32*lane+:32];
      if(r<4 && dut.final_bank[w%8][w/8]!==expected)
        $fatal(1,"SHARED_Q16_Q_MISMATCH row=%0d group=%0d lane=%0d",
               r,g,lane);
    end
    for(int pair=0;pair<16;pair++)begin
      int w;logic [31:0] expected;
      w=272*(r%16)+256+pair;
      expected={scalegold[r*32+2*pair+1],scalegold[r*32+2*pair]};
      if(r<4 && dut.final_bank[w%8][w/8]!==expected)
        $fatal(1,"SHARED_Q16_SCALE_MISMATCH row=%0d pair=%0d",r,pair);
    end
    for(int w=272*r;w<272*(r+1);w++)
      observed[w]=dut.final_bank[w%8][w/8];
    repeat(3)begin
      @(negedge clk);if(!done_valid)$fatal(1,"SHARED_Q16_DONE_HOLD");
    end
    done_ready=1;@(negedge clk);done_ready=0;
    if(r<15 && a_window_ready)$fatal(1,"SHARED_Q16_EARLY_WINDOW");
  endtask
  task automatic check_complete_window;
    for(int w=0;w<4352;w++)
      if(dut.final_bank[w%8][w/8]!==observed[w])
        $fatal(1,"REV21_Q16_RESCAN w=%0d",w);
    $display("REV21_Q16_RESCAN_PASS words=4352");
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"SHARED_Q16_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/norm_s128.hex"},norm_all);
    $readmemh({fixture,"/q_rows4.hex"},qgold);
    $readmemh({fixture,"/scale_rows4.hex"},scalegold);
    $readmemh({fixture,"/qkv_q0.hex"},wq0);
    $readmemh({fixture,"/qkv_scale.hex"},wscale);
    model_identity=model_rom[0];
    numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    $display("REV21_Q16_SIM_START");
    repeat(5)@(negedge clk);rst_n=1;
    for(int r=0;r<16;r++)begin
      prepare_norm(r,1);run_row(r,1);
      $display("SHARED_Q16_ROW_PASS row=%0d cycle=%0d cover=%h",
               r,cycle,dut.q16_cover);
    end
    if(!a_window_ready || dut.q16_cover!==16'hffff ||
       q16_next_row!=5'd16 || prep_begin_ready || cmd_ready)
      $fatal(1,"SHARED_Q16_WINDOW_NOT_HELD");
    check_complete_window();
    if(a_window_id!==32'd100 || a_window_base!==7'd0 ||
       a_window_epoch!==32'd1 || a_window_source_epoch!==32'd1 ||
       a_window_cover!==16'hffff)
      $fatal(1,"REV22_MATRIX_A_DESCRIPTOR");
    @(negedge clk); matrix_cmd_valid=1;
    #1ps;if(!matrix_cmd_ready)$fatal(1,"REV22_MATRIX_CMD_READY");
    @(negedge clk);matrix_cmd_valid=0;
    for(int guard=0;guard<150000 && !ps_tile_valid;guard++)
      @(negedge clk);
    if(!ps_tile_valid || ps_tile!=0 || matrix_done_valid ||
       !a_matrix_owned || actual_a_reads!=1024 ||
       actual_a_returns!=1024 || actual_w_reads!=128 ||
       actual_w_returns!=128 || actual_stripes!=128 ||
       actual_row_retired!=512 || actual_terminal!=16 ||
       ps_store_count!=16 || actual_ps_retired!=0)
      $fatal(1,"REV22_MATRIX_TN8_COUNTS a=%0d/%0d w=%0d/%0d stripe=%0d row=%0d term=%0d ps=%0d state=%0d",
        actual_a_reads,actual_a_returns,actual_w_reads,
        actual_w_returns,actual_stripes,actual_row_retired,
        actual_terminal,ps_store_count,matrix_u.state);
    $display("REV22_MATRIX_TN8_LOCAL_PASS a=1024 w=128 stripe=128 row=512 term=16 ps=16 held=1");
    $finish;
  end
endmodule
