`timescale 1ns/1ps
module laya_lnq_stage_modes_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,x_valid=0,gamma_valid=0;
  logic [1:0] source_mode=0,gamma_kind=0;
  logic [15:0] cmd_row=0;
  logic [31:0] x_bits=0,gamma_bits=0;
  logic ln_only_ready=0;
  logic rd_valid=0,rsp_ready=0,row_release_valid=0,done_ready=0;
  logic [6:0] rd_group=0;
  wire cmd_ready,x_ready,gamma_ready,row_valid,rd_ready,rsp_valid;
  wire ln_only_valid,ln_only_last;
  wire [6:0] rsp_group;
  wire [255:0] rsp_q8;
  wire [15:0] rsp_scale;
  wire row_release_ready,done_valid;
  wire [3:0] done_status;
  wire [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  wire norm_valid;
  wire [9:0] norm_index;
  wire [31:0] norm_bits;
  logic [31:0] raw[0:1023],gamma[0:1023],norm[0:1023];
  logic [7:0] qgold[0:1023];
  logic [15:0] sgold[0:31];
  int cycles=0;
  laya_lnq_row_v1 dut(.*);
  always @(posedge clk) if(rst_n) begin
    cycles<=cycles+1;
    if(cycles>350000)$fatal(1,"STAGE_MODES_TIMEOUT");
  end

  task automatic start(input logic [1:0] mode,input logic [1:0] gkind);
    @(negedge clk);
    source_mode=mode;gamma_kind=gkind;cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"STAGE_MODES_CMD_NOT_READY mode=%0d",mode);
    @(negedge clk);cmd_valid=0;
  endtask

  initial begin
    string fixture;
    int xi,gi,yi,half_seen;
    logic [255:0] qexp;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"STAGE_MODES_FIXTURE");
    $readmemh({fixture,"/raw_row0.hex"},raw);
    $readmemh({fixture,"/gamma.hex"},gamma);
    $readmemh({fixture,"/norm_row0.hex"},norm);
    $readmemh({fixture,"/q_row0.hex"},qgold);
    $readmemh({fixture,"/scale_row0.hex"},sgold);
    repeat(5)@(negedge clk);rst_n=1;
    start(2'b10,2'd1);
    xi=0;gi=0;yi=0;
    while(!done_valid) begin
      @(negedge clk);
      x_valid=xi<1024 && cycles%5!=0;
      x_bits=raw[xi<1024?xi:1023];
      gamma_valid=gi<1024 && cycles%7!=0;
      gamma_bits=gamma[gi<1024?gi:1023];
      ln_only_ready=cycles%11<7;
      @(posedge clk);
      if(x_valid && x_ready)xi++;
      if(gamma_valid && gamma_ready)gi++;
      if(ln_only_valid && ln_only_ready) begin
        if(!norm_valid || norm_index!==10'(yi) ||
           norm_bits!==norm[yi] || ln_only_last!==(yi==1023))
          $fatal(1,"STAGE_MODES_NORM_GOLD index=%0d got=%08x exp=%08x",yi,norm_bits,norm[yi]);
        yi++;
      end
      if(row_valid || dut.q_start_fire || dut.q_out_fire)
        $fatal(1,"STAGE_MODES_LN_ONLY_STARTED_Q");
    end
    @(negedge clk);x_valid=0;gamma_valid=0;ln_only_ready=0;
    if(xi!=1024 || gi!=1024 || yi!=1024 || done_status!=0 ||
       done_bad_element!=32'hffffffff)
      $fatal(1,"STAGE_MODES_LN_ONLY_DONE x=%0d g=%0d y=%0d status=%0d",xi,gi,yi,done_status);
    repeat(3) begin
      @(negedge clk);
      if(!done_valid || done_status!=0 || row_valid)
        $fatal(1,"STAGE_MODES_LN_ONLY_HOLD");
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    start(2'b11,2'd0);
    xi=0;half_seen=0;
    while(!row_valid && !done_valid) begin
      @(negedge clk);
      x_valid=xi<1024 && cycles%9!=0;
      x_bits=norm[xi<1024?xi:1023];
      @(posedge clk);
      if(x_valid && x_ready)xi++;
      if(dut.q_out_fire) begin
        int qbase;
        qbase=int'(dut.q_out_group)*32+int'(dut.q_out_half)*16;
        if(qbase<0 || qbase>1008)$fatal(1,"STAGE_MODES_Q_TAG");
        for(int lane=0;lane<16;lane++)
          if(dut.q_out_bits[8*lane+:8]!==qgold[qbase+lane])
            $fatal(1,"STAGE_MODES_Q_GOLD index=%0d",qbase+lane);
        if(dut.q_out_half && dut.q_out_scale!==sgold[dut.q_out_group])
          $fatal(1,"STAGE_MODES_SCALE_GOLD group=%0d",dut.q_out_group);
        half_seen++;
      end
      if(dut.ln_cmd_valid || dut.ln_out_fire || gamma_ready || norm_valid)
        $fatal(1,"STAGE_MODES_DIRECT_STARTED_LN");
    end
    @(negedge clk);x_valid=0;
    if(!row_valid || done_valid || xi!=1024 || half_seen!=64 ||
       dut.q_accepted_groups!=32 || dut.q_covered_groups!=32 ||
       !dut.q_physical_debt_zero)
      $fatal(1,"STAGE_MODES_DIRECT_ROW x=%0d half=%0d",xi,half_seen);
    for(int group=0;group<32;group++) begin
      @(negedge clk);rd_group=7'(group);rd_valid=1;
      #1ps;if(!rd_ready)$fatal(1,"STAGE_MODES_RD_READY group=%0d",group);
      @(negedge clk);rd_valid=0;
      do @(negedge clk); while(!rsp_valid);
      qexp=0;
      for(int lane=0;lane<32;lane++)qexp[8*lane+:8]=qgold[32*group+lane];
      if(rsp_group!==7'(group) || rsp_q8!==qexp || rsp_scale!==sgold[group])
        $fatal(1,"STAGE_MODES_RSP_GOLD group=%0d",group);
      repeat(2) begin
        @(negedge clk);
        if(!rsp_valid || rsp_q8!==qexp || rsp_scale!==sgold[group])
          $fatal(1,"STAGE_MODES_RSP_HOLD group=%0d",group);
      end
      rsp_ready=1;
      @(negedge clk);rsp_ready=0;
    end
    @(negedge clk);row_release_valid=1;
    #1ps;if(!row_release_ready)$fatal(1,"STAGE_MODES_RELEASE_READY");
    @(negedge clk);row_release_valid=0;
    repeat(2)begin
      @(negedge clk);
      if(!done_valid || done_status!=0)$fatal(1,"STAGE_MODES_DIRECT_DONE");
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    $display("LNQ_STAGE_MODES_PASS ln_words=1024 q_words=1024 groups=32 cycles=%0d",cycles);
    $finish;
  end
endmodule
