`timescale 1ns/1ps
// Exercises the production bank/LNQ/prep/Q16 service without the inactive
// W-cache, matrix, G, residual or RoPE instances.
module laya_shared_q16_service_tb;
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
  logic result_rsp_valid,result_rsp_ready=0;
  logic [9:0] result_rsp_tile;
  logic [255:0] result_rsp_bits;
  logic ps_store_valid=0;
  logic [9:0] ps_store_tile=0;
  logic [255:0] ps_store_bits=0;
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
  logic a_window_ready,a_window_release_valid=0,a_window_discard=0;
  logic a_window_release_ready,q16_partial_owned,q16_window_ok;
  logic [4:0] q16_next_row;
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
    .result_reset(1'b0),.result_accept(1'b0),
    .result_physical_addr(10'd0),.result_logical_tile(10'd0),
    .result_pending(),.result_rsp_valid,.result_rsp_ready,
    .result_rsp_tile,.result_rsp_bits,
    .g_x_read_valid,.g_x_read_tile,.g_x_hold,
    .g_gate_read_valid,.g_gate_read_tile,.g_gate_hold,
    .qd_read_valid,.qd_read_word,.qd_word,
    .res_read_valid,.res_read_index,.res_b_hold
  );
  logic [3327:0] model_rom[0:0];
  logic [31:0] norm0[0:1023],norm1[0:1023];
  logic [31:0] raw0[0:1023],gamma[0:1023];
  logic [255:0] q0[0:31],q1[0:31];
  logic [15:0] scale0[0:31],scale1[0:31];
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
      prep_write_bits=r[0] ? norm1[i] : norm0[i];
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
      expected=r[0] ? q1[g][32*lane+:32] : q0[g][32*lane+:32];
      if(dut.final_bank[w%8][w/8]!==expected)
        $fatal(1,"SHARED_Q16_Q_MISMATCH row=%0d group=%0d lane=%0d",
               r,g,lane);
    end
    for(int pair=0;pair<16;pair++)begin
      int w;logic [31:0] expected;
      w=272*(r%16)+256+pair;
      expected=r[0] ? {scale1[2*pair+1],scale1[2*pair]} :
                        {scale0[2*pair+1],scale0[2*pair]};
      if(dut.final_bank[w%8][w/8]!==expected)
        $fatal(1,"SHARED_Q16_SCALE_MISMATCH row=%0d pair=%0d",r,pair);
    end
    repeat(3)begin
      @(negedge clk);if(!done_valid)$fatal(1,"SHARED_Q16_DONE_HOLD");
    end
    done_ready=1;@(negedge clk);done_ready=0;
    if(r<15 && a_window_ready)$fatal(1,"SHARED_Q16_EARLY_WINDOW");
  endtask
  task automatic check_complete_window;
    for(int r=0;r<16;r++)begin
      for(int g=0;g<32;g++)for(int lane=0;lane<8;lane++)begin
        int w;
        logic [31:0] expected;
        w=272*r+8*g+lane;
        expected=r[0] ? q1[g][32*lane+:32] : q0[g][32*lane+:32];
        if(dut.final_bank[w%8][w/8]!==expected)
          $fatal(1,"SHARED_Q16_FINAL_Q row=%0d group=%0d lane=%0d",r,g,lane);
      end
      for(int pair=0;pair<16;pair++)begin
        int w;
        logic [31:0] expected;
        w=272*r+256+pair;
        expected=r[0] ? {scale1[2*pair+1],scale1[2*pair]} :
                          {scale0[2*pair+1],scale0[2*pair]};
        if(dut.final_bank[w%8][w/8]!==expected)
          $fatal(1,"SHARED_Q16_FINAL_SCALE row=%0d pair=%0d",r,pair);
      end
    end
    $display("SHARED_Q16_FINAL_RESCAN_PASS words=4352");
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"SHARED_Q16_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/norm_row0.hex"},norm0);
    $readmemh({fixture,"/norm_row1.hex"},norm1);
    $readmemh({fixture,"/raw_row0.hex"},raw0);
    $readmemh({fixture,"/gamma.hex"},gamma);
    $readmemh({fixture,"/q_row0.hex"},q0);
    $readmemh({fixture,"/q_row1.hex"},q1);
    $readmemh({fixture,"/scale_row0.hex"},scale0);
    $readmemh({fixture,"/scale_row1.hex"},scale1);
    model_identity=model_rom[0];
    numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    $display("SHARED_Q16_SIM_START");
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
    repeat(3)@(negedge clk);
    if(!a_window_ready)$fatal(1,"SHARED_Q16_WINDOW_HOLD");
    a_window_release_valid=1;
    #1ps;if(!a_window_release_ready)$fatal(1,"SHARED_Q16_RELEASE_READY");
    @(negedge clk);a_window_release_valid=0;
    if(a_window_ready || dut.q16_cover!=0 || q16_next_row!=0)
      $fatal(1,"SHARED_Q16_RELEASE_FAILED");
    prepare_norm(0,2);
    @(negedge clk);cmd_id=100;cmd_row=0;cmd_epoch=3;cmd_valid=1;
    #1ps;if(cmd_ready)$fatal(1,"SHARED_Q16_BAD_EPOCH_ACCEPTED");
    repeat(4)@(negedge clk);
    if(done_valid || q16_next_row!=0 || dut.q16_cover!=0)
      $fatal(1,"SHARED_Q16_BAD_EPOCH_EFFECT");
    cmd_valid=0;
    run_row(0,2);
    if(!q16_partial_owned || q16_next_row!=1 || dut.q16_cover!=16'h0001)
      $fatal(1,"SHARED_Q16_PARTIAL_OWNER_MISSING");
    for(int k=0;k<3;k++)begin
      prep_kind=k==0 ? 2'b00 : k==1 ? 2'b01 : 2'b11;
      prep_begin_valid=1;
      #1ps;if(prep_begin_ready)
        $fatal(1,"SHARED_Q16_PARTIAL_PREP_ACCEPT kind=%0d",prep_kind);
      @(negedge clk);
      prep_begin_valid=0;
    end
    prep_kind=2'b10;
    prep_id=101;prep_row=1;prep_epoch=2;
    prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"SHARED_Q16_TEMP_BEGIN");
    @(negedge clk);prep_begin_valid=0;
    prep_write_valid=1;prep_write_index=0;prep_write_bits=norm1[0];
    #1ps;if(!prep_write_ready)$fatal(1,"SHARED_Q16_TEMP_WRITE");
    @(negedge clk);prep_write_valid=0;prep_abort_valid=1;
    #1ps;if(!prep_abort_ready)$fatal(1,"SHARED_Q16_TEMP_ABORT_READY");
    @(negedge clk);prep_abort_valid=0;
    if(!q16_partial_owned || q16_next_row!=1 || dut.q16_cover!=16'h0001 ||
       dut.final_bank[0][0]!==q0[0][31:0])
      $fatal(1,"SHARED_Q16_TEMP_ABORT_LOST_ROW0");
    prepare_norm(1,2);run_row(1,2);
    a_window_discard=1;a_window_release_valid=1;
    #1ps;if(!a_window_release_ready)
      $fatal(1,"SHARED_Q16_PARTIAL_DISCARD_READY");
    @(negedge clk);a_window_release_valid=0;a_window_discard=0;
    if(q16_partial_owned || q16_next_row!=0 || dut.q16_cover!=0)
      $fatal(1,"SHARED_Q16_PARTIAL_DISCARD_FAILED");
    prepare_norm(0,3);run_row(0,3);
    a_window_discard=1;a_window_release_valid=1;
    #1ps;if(!a_window_release_ready)
      $fatal(1,"SHARED_Q16_NEW_EPOCH_DISCARD_READY");
    @(negedge clk);a_window_release_valid=0;a_window_discard=0;
    // The same production lower service also owns LN_ONLY replay, norm
    // capture, synchronous view and error retirement. Inputs here are saved
    // raw/gamma bytes; this local check does not claim AXI source service.
    match_kind=2'b01;cmd_id=200;cmd_row=0;cmd_epoch=4;
    for(int kind=0;kind<2;kind++)begin
      prep_kind=kind==0 ? 2'b11 : 2'b01;
      prep_id=200;prep_row=0;prep_epoch=4;
      prep_begin_valid=1;
      #1ps;if(!prep_begin_ready)
        $fatal(1,"SHARED_LN_PREP_BEGIN kind=%0d",prep_kind);
      @(negedge clk);prep_begin_valid=0;
      for(int i=0;i<1024;i++)begin
        prep_write_valid=1;prep_write_index=11'(i);
        prep_write_bits=kind==0 ? gamma[i] : raw0[i];
        #1ps;if(!prep_write_ready)
          $fatal(1,"SHARED_LN_PREP_WRITE kind=%0d i=%0d",prep_kind,i);
        @(negedge clk);
      end
      prep_write_valid=0;prep_commit_valid=1;
      #1ps;if(!prep_commit_ready)
        $fatal(1,"SHARED_LN_PREP_COMMIT kind=%0d",prep_kind);
      @(negedge clk);prep_commit_valid=0;
    end
    if(!prep_token_valid || !gamma_token_valid || !staged_ln_cmd_ready)
      $fatal(1,"SHARED_LN_STAGED_TOKEN");
    staged_ln_cmd_valid=1;
    @(negedge clk);staged_ln_cmd_valid=0;
    for(int guard=0;guard<50000 && !staged_ln_view_valid;guard++)
      @(negedge clk);
    if(!staged_ln_view_valid || staged_ln_done_valid)
      $fatal(1,"SHARED_LN_VIEW_NOT_READY");
    for(int i=0;i<1024;i++)
      if(dut.final_bank[i%8][384+i/8]!==norm0[i])
        $fatal(1,"SHARED_LN_NORM_MISMATCH i=%0d",i);
    staged_ln_rd_tile=10'd127;staged_ln_rd_valid=1;
    #1ps;if(!staged_ln_rd_ready)$fatal(1,"SHARED_LN_VIEW_RD_READY");
    @(negedge clk);staged_ln_rd_valid=0;
    for(int guard=0;guard<8 && !result_rsp_valid;guard++)@(negedge clk);
    if(!result_rsp_valid || result_rsp_tile!=10'd127)
      $fatal(1,"SHARED_LN_VIEW_RSP_TAG");
    for(int lane=0;lane<8;lane++)
      if(result_rsp_bits[lane*32+:32]!==norm0[1016+lane])
        $fatal(1,"SHARED_LN_VIEW_RSP_DATA lane=%0d",lane);
    repeat(3)begin
      @(negedge clk);
      if(!result_rsp_valid || staged_ln_rd_ready)
        $fatal(1,"SHARED_LN_VIEW_RSP_HOLD");
    end
    result_rsp_ready=1;@(negedge clk);result_rsp_ready=0;
    staged_ln_rd_tile=10'd128;staged_ln_rd_valid=1;
    #1ps;if(staged_ln_rd_ready)
      $fatal(1,"SHARED_LN_BAD_TILE_READY");
    @(negedge clk);staged_ln_rd_valid=0;
    for(int guard=0;guard<8 && !staged_ln_done_valid;guard++)
      @(negedge clk);
    if(!staged_ln_done_valid || staged_ln_done_status!=4'd7 ||
       staged_ln_done_phase!=4'd12 ||
       staged_ln_done_bad!=32'hffffffff)
      $fatal(1,"SHARED_LN_BAD_TILE_DIAG status=%0d phase=%0d",
        staged_ln_done_status,staged_ln_done_phase);
    repeat(3)begin
      @(negedge clk);
      if(!staged_ln_done_valid)$fatal(1,"SHARED_LN_BAD_TILE_HOLD");
    end
    staged_ln_done_ready=1;@(negedge clk);staged_ln_done_ready=0;
    $display("SHARED_LN_ONLY_VIEW_BAD_TILE_PASS norm=1024 tile127=8 status=7 phase=12");
    // Legal inactive-phase clients: keep the original synchronous eight-lane
    // read edge and a different-address scalar return write on the same bank.
    ps_store_tile=2;
    for(int lane=0;lane<8;lane++)
      ps_store_bits[lane*32+:32]=32'h1020_0000+32'(lane);
    ps_store_valid=1;@(negedge clk);ps_store_valid=0;
    ps_store_tile=3;
    for(int lane=0;lane<8;lane++)
      ps_store_bits[lane*32+:32]=32'h3040_0000+32'(lane);
    ps_store_valid=1;@(negedge clk);ps_store_valid=0;
    g_x_read_tile=2;g_x_read_valid=1;
    g_store_index=12'd32;g_store_bits=32'h55aa_1234;g_store_valid=1;
    @(negedge clk);g_x_read_valid=0;g_store_valid=0;
    for(int lane=0;lane<8;lane++)
      if(g_x_hold[lane*32+:32]!==32'h1020_0000+32'(lane))
        $fatal(1,"SHARED_BANK_G_X lane=%0d",lane);
    if(dut.final_bank[0][4]!==32'h55aa_1234)
      $fatal(1,"SHARED_BANK_G_RETURN");
    g_gate_read_tile=3;g_gate_read_valid=1;
    g_store_index=12'd41;g_store_bits=32'h66bb_2345;g_store_valid=1;
    @(negedge clk);g_gate_read_valid=0;g_store_valid=0;
    for(int lane=0;lane<8;lane++)
      if(g_gate_hold[lane*32+:32]!==32'h3040_0000+32'(lane))
        $fatal(1,"SHARED_BANK_G_GATE lane=%0d",lane);
    if(dut.final_bank[1][5]!==32'h66bb_2345)
      $fatal(1,"SHARED_BANK_G_GATE_RETURN");
    qd_read_word=13'd16;qd_read_valid=1;
    @(negedge clk);qd_read_valid=0;
    if(qd_word!==32'h1020_0000)$fatal(1,"SHARED_BANK_QD_WORD");
    res_read_index=10'd16;res_read_valid=1;
    res_store_index=10'd48;res_store_bits=32'h7788_3456;
    res_store_valid=1;
    @(negedge clk);res_read_valid=0;res_store_valid=0;
    if(res_b_hold!==32'h1020_0000 ||
       dut.final_bank[0][6]!==32'h7788_3456)
      $fatal(1,"SHARED_BANK_ADD_READ_WRITE");
    $display("SHARED_BANK_CLIENTS_PASS ps=16 G_x_gate_1R1W=2 QD=1 ADD_1R1W=1");
    $display("SHARED_Q16_SERVICE_PASS full_rows=16 words=4352 full_rsp=512 partial_abort_discard=1 new_epoch=1");
    $finish;
  end
endmodule
