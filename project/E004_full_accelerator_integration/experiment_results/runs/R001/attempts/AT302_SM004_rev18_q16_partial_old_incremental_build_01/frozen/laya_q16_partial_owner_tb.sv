`timescale 1ns/1ps
module laya_q16_partial_owner_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1;
  logic cmd_mode=0;
  logic [6:0] cmd_row=0;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] cmd_id=1,cmd_w_epoch=1,cmd_down_w_epoch=1;
  logic [15:0] cmd_weight_key=3,cmd_down_weight_key=4;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0,cmd_down_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0,cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic x_valid,x_ready,drive_source=0;
  logic [31:0] x_bits;
  logic gamma_valid=0,gamma_ready;
  logic [31:0] gamma_bits=0;
  logic row_valid,rd_valid=0,rd_ready;
  logic [9:0] rd_tile=0,rsp_tile;
  logic rsp_valid,rsp_ready=0;
  logic [255:0] rsp_bits;
  logic row_release_valid=0,row_release_ready;
  logic done_valid,done_ready=0;
  logic [3:0] done_status;
  logic [3:0] done_phase;
  logic [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [31:0] actual_w_reads,actual_w_returns,actual_stripes,actual_ps_commits;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst;
  logic [2:0] arvalid,arready;
  logic [2:0][511:0] rdata;
  logic [2:0][1:0] rresp;
  logic [2:0] rlast,rvalid,rready;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize,aux_arburst;
  logic aux_arvalid,aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast,aux_rvalid,aux_rready;
  logic [2:0] cmd_exec=3'd2, result_exec;
  logic cmd_prepared_source=1;
  logic [31:0] cmd_source_epoch=1;
  logic [63:0] cmd_gamma_aux_base=0,cmd_gamma_aux_span=0;
  logic prep_begin_valid=0,prep_begin_ready;
  logic [1:0] prep_kind=2'd2;
  logic [31:0] prep_id=0,prep_epoch=1;
  logic [6:0] prep_row=0;
  logic [3327:0] prep_model_identity=0;
  logic [671:0] prep_numeric_identity=0;
  logic [63:0] prep_gamma_aux_base=0,prep_gamma_aux_span=0;
  logic prep_write_valid=0,prep_write_ready;
  logic [10:0] prep_write_index=0;
  logic [31:0] prep_write_bits=0;
  logic prep_commit_valid=0,prep_commit_ready;
  logic prep_abort_valid=0,prep_abort_ready;
  logic prep_token_valid,gamma_token_valid,prep_fault;
  logic a_window_ready,a_window_release_valid=0,a_window_discard=0;
  logic a_window_release_ready,row_release_discard=0;
  logic [7:0] done_op;
  logic [15:0] done_check_status;
  logic [31:0] done_detail;
  logic [63:0] done_bad64;
  laya_lnq_wi_gqdown_row_v1 dut(.*);

  logic [3327:0] model_rom[0:0];
  logic [31:0] norm0[0:1023],norm1[0:1023];
  logic [255:0] q0[0:31],q1[0:31];
  logic [15:0] scale0[0:31],scale1[0:31];
  string fixture;
  int cycle=0, q_rsp_count=0;
  always_comb begin
    arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;
    aux_arready=0;aux_rdata=0;aux_rresp=0;aux_rlast=0;aux_rvalid=0;
  end
  always @(posedge clk) if(rst_n)begin
    cycle<=cycle+1;
    if(|arvalid || aux_arvalid || x_ready || gamma_ready || row_valid ||
       actual_w_reads!=0 || actual_w_returns!=0 || actual_stripes!=0 ||
       actual_ps_commits!=0)
      $fatal(1,"Q16_UNEXPECTED_W_OR_EXTERNAL_INPUT cycle=%0d",cycle);
    if(dut.ln_rsp_valid && dut.lnq.rsp_ready)q_rsp_count<=q_rsp_count+1;
    if(cycle%5000==0)
      $display("Q16_PROGRESS cycle=%0d row=%0d state=%0d rsp=%0d cover=%h",
               cycle,cmd_row,dut.state,q_rsp_count,dut.q16_cover);
    if(cycle>200000)$fatal(1,"Q16_CYCLE_CAP state=%0d row=%0d",dut.state,cmd_row);
  end
  task automatic prepare_norm(input int r,input int epoch);
    @(negedge clk);
    prep_kind=2'd2;prep_id=32'(100+r);prep_row=7'(r);
    prep_epoch=32'(epoch);prep_model_identity=cmd_model_identity;
    prep_numeric_identity=cmd_numeric_identity;
    prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"Q16_PREP_BEGIN_NOT_READY row=%0d",r);
    @(negedge clk);prep_begin_valid=0;
    if(prep_begin_ready)$fatal(1,"Q16_DUPLICATE_PREP_ALLOWED row=%0d",r);
    for(int i=0;i<1024;i++)begin
      prep_write_valid=1;prep_write_index=11'(i);
      prep_write_bits=r[0] ? norm1[i] : norm0[i];
      #1ps;if(!prep_write_ready)$fatal(1,"Q16_PREP_WRITE_NOT_READY row=%0d word=%0d",r,i);
      @(negedge clk);
    end
    prep_write_valid=0;prep_commit_valid=1;
    #1ps;if(!prep_commit_ready)$fatal(1,"Q16_PREP_COMMIT_NOT_READY row=%0d",r);
    @(negedge clk);prep_commit_valid=0;
    if(!prep_token_valid || prep_begin_ready)
      $fatal(1,"Q16_PREP_TOKEN_MISSING row=%0d",r);
  endtask
  task automatic run_row(input int r,input int epoch,input bit expect_ok);
    int q_rsp_before;
    q_rsp_before=q_rsp_count;
    @(negedge clk);
    cmd_id=32'(100+r);cmd_row=7'(r);cmd_source_epoch=32'(epoch);
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"Q16_CMD_NOT_READY row=%0d",r);
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<50000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid)$fatal(1,"Q16_NO_DONE row=%0d state=%0d",r,dut.state);
    if(expect_ok)begin
      if(done_status!=0 || done_check_status!=0 || done_op!=8'h20 ||
         done_bad64!=64'hffff_ffff_ffff_ffff || result_exec!=3'd2 ||
         result_row!=7'(r) || q_rsp_count!=q_rsp_before+32)
        $fatal(1,"Q16_DONE_BAD row=%0d status=%0d rsp=%0d",r,done_status,q_rsp_count);
      for(int g=0;g<32;g++)for(int lane=0;lane<8;lane++)begin
        int w;logic [31:0] expected;
        w=272*(r%16)+8*g+lane;
        expected=r[0] ? q1[g][32*lane+:32] : q0[g][32*lane+:32];
        if(dut.final_bank[w%8][w/8]!==expected)
          $fatal(1,"Q16_Q_BANK_MISMATCH row=%0d group=%0d lane=%0d",r,g,lane);
      end
      for(int pair=0;pair<16;pair++)begin
        int w;logic [31:0] expected;
        w=272*(r%16)+256+pair;
        expected=r[0] ? {scale1[2*pair+1],scale1[2*pair]} :
                          {scale0[2*pair+1],scale0[2*pair]};
        if(dut.final_bank[w%8][w/8]!==expected)
          $fatal(1,"Q16_SCALE_BANK_MISMATCH row=%0d pair=%0d",r,pair);
      end
    end else if(done_status!=4'd7 || done_phase!=4'd14 || q_rsp_count!=512)
      $fatal(1,"Q16_BAD_EPOCH_NOT_REJECTED status=%0d phase=%0d",done_status,done_phase);
    repeat(3)begin
      @(negedge clk);
      if(!done_valid)$fatal(1,"Q16_DONE_HOLD row=%0d",r);
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    if(r<15 && a_window_ready)$fatal(1,"Q16_WINDOW_EARLY row=%0d",r);
  endtask
  task automatic check_a_row0;
    for(int g=0;g<32;g++)for(int lane=0;lane<8;lane++)begin
      int w;w=8*g+lane;
      if(dut.final_bank[w%8][w/8]!==q0[g][32*lane+:32])
        $fatal(1,"Q16_PARTIAL_ROW0_Q_CHANGED word=%0d",w);
    end
    for(int pair=0;pair<16;pair++)begin
      int w;w=256+pair;
      if(dut.final_bank[w%8][w/8]!=={scale0[2*pair+1],scale0[2*pair]})
        $fatal(1,"Q16_PARTIAL_ROW0_SCALE_CHANGED pair=%0d",pair);
    end
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"Q16_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/norm_row0.hex"},norm0);
    $readmemh({fixture,"/norm_row1.hex"},norm1);
    $readmemh({fixture,"/q_row0.hex"},q0);
    $readmemh({fixture,"/q_row1.hex"},q1);
    $readmemh({fixture,"/scale_row0.hex"},scale0);
    $readmemh({fixture,"/scale_row1.hex"},scale1);
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_mode=1;cmd_cold=0;cmd_exec=3'd2;
    x_valid=0;x_bits=0;gamma_valid=0;gamma_bits=0;
    rd_valid=0;rsp_ready=0;row_release_valid=0;done_ready=0;
    repeat(5)@(negedge clk);rst_n=1;
    prepare_norm(0,1);
    run_row(0,1,1);
    check_a_row0();
    if(dut.q16_next_row!=1 || dut.q16_cover!=16'h0001 || a_window_ready)
      $fatal(1,"Q16_PARTIAL_NOT_OWNED");
    if($test$plusargs("OLD_REPRO"))begin
      @(negedge clk);
      prep_kind=2'b01;prep_id=32'd999;prep_row=7'd0;
      prep_begin_valid=1;
      #1ps;if(!prep_begin_ready)$fatal(1,"Q16_OLD_REPRO_NO_BEGIN");
      @(negedge clk);prep_begin_valid=0;
      prep_write_valid=1;prep_write_index=0;prep_write_bits=32'hdeadbeef;
      #1ps;if(!prep_write_ready)$fatal(1,"Q16_OLD_REPRO_NO_WRITE");
      @(negedge clk);prep_write_valid=0;
      #1ps;
      if(dut.final_bank[0][0]!==32'hdeadbeef ||
         dut.q16_cover!=16'h0001 || dut.q16_next_row!=1)
        $fatal(1,"Q16_OLD_REPRO_NOT_OBSERVED");
      $display("Q16_PARTIAL_OLD_OVERWRITE_REPRO begin=1 write0=1 cover=0001");
      $finish;
    end
    for(int kind=0;kind<4;kind++)if(kind!=2)begin
      @(negedge clk);
      prep_kind=2'(kind);prep_id=32'd999;prep_row=7'd0;
      prep_begin_valid=1;
      #1ps;if(prep_begin_ready)$fatal(1,"Q16_PARTIAL_WRONG_KIND_READY kind=%0d",kind);
      @(negedge clk);prep_begin_valid=0;
    end
    for(int mode=0;mode<2;mode++)begin
      @(negedge clk);
      cmd_exec=mode==0 ? 3'd0 : 3'd1;
      cmd_prepared_source=mode!=0;cmd_valid=1;
      #1ps;if(cmd_ready)$fatal(1,"Q16_PARTIAL_WRONG_CMD_READY mode=%0d",mode);
      @(negedge clk);cmd_valid=0;
      if(done_valid || |arvalid || aux_arvalid ||
         dut.q16_cover!=16'h0001 || dut.q16_next_row!=1)
        $fatal(1,"Q16_PARTIAL_WRONG_CMD_EFFECT mode=%0d",mode);
    end
    cmd_exec=3'd2;cmd_prepared_source=1;
    check_a_row0();
    @(negedge clk);
    prep_kind=2'b10;prep_id=32'd101;prep_row=7'd1;
    prep_epoch=1;prep_model_identity=cmd_model_identity;
    prep_numeric_identity=cmd_numeric_identity;
    prep_begin_valid=1;
    #1ps;if(!prep_begin_ready)$fatal(1,"Q16_PARTIAL_NEXT_NORM_BEGIN");
    @(negedge clk);prep_begin_valid=0;
    prep_write_valid=1;prep_write_index=0;prep_write_bits=norm1[0];
    #1ps;if(!prep_write_ready)$fatal(1,"Q16_PARTIAL_NEXT_NORM_WRITE");
    @(negedge clk);prep_write_valid=0;prep_abort_valid=1;
    #1ps;if(!prep_abort_ready)$fatal(1,"Q16_PARTIAL_ABORT_READY");
    @(negedge clk);prep_abort_valid=0;
    if(dut.q16_cover!=16'h0001 || dut.q16_next_row!=1 ||
       prep_token_valid || a_window_ready)
      $fatal(1,"Q16_PARTIAL_ABORT_LOST_OWNER");
    check_a_row0();
    prepare_norm(1,1);
    run_row(1,1,1);
    check_a_row0();
    if(dut.q16_cover!=16'h0003 || dut.q16_next_row!=2 || a_window_ready)
      $fatal(1,"Q16_PARTIAL_NEXT_ROW_BAD");
    @(negedge clk);
    a_window_discard=1;a_window_release_valid=1;
    #1ps;if(!a_window_release_ready)$fatal(1,"Q16_PARTIAL_DISCARD_READY");
    @(negedge clk);a_window_release_valid=0;a_window_discard=0;
    if(dut.q16_cover!=0 || dut.q16_next_row!=0 || a_window_ready)
      $fatal(1,"Q16_PARTIAL_DISCARD_FAILED");
    prepare_norm(0,2);
    run_row(0,2,1);
    check_a_row0();
    $display("Q16_PARTIAL_OWNER_PASS rows=0,1,new0 rejects=5 abort=1 discard=1");
    $finish;
  end
endmodule
