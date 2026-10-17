`timescale 1ns/1ps
module laya_ffn_residual_four_row_v1_tb;
  localparam logic [63:0] STATE0 = 64'h300000000;
  localparam logic [63:0] STATE1 = 64'h310000000;
  localparam logic [63:0] TMP = STATE1 + 64'h800000;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0, cfg_valid=0, cfg_ready;
  logic [31:0] cfg_request=3, cfg_generation=1;
  logic [7:0] cfg_op=8'h62, cfg_stage=2, cfg_layer=0;
  logic [7:0] cfg_batch=0, cfg_row=0, cfg_rows=4;
  logic [15:0] cfg_length=1024, cfg_bias_id=16'hffff;
  logic [127:0] cfg_model_tag=128'h6eb6ef58bc4f99bd9db40381604108af;
  logic [127:0] cfg_numeric_tag=128'haeb13e7937d29fe6a2c68c407249f294;
  logic [127:0] cfg_layout_tag=128'h2d848b5fb78236c795cb1d442f088393;
  logic [127:0] cfg_build_tag=128'h7209eb09c3f265363cfb274f7790a733;
  logic [7:0] cfg_src0_role=3, cfg_src0_bank=1, cfg_src1_role=1;
  logic [7:0] cfg_src1_bank=0, cfg_dst_role=1, cfg_dst_bank=1;
  logic [31:0] cfg_src0_epoch=2, cfg_src1_epoch=1, cfg_dst_epoch=2;
  logic [63:0] cfg_src0_base=TMP, cfg_src1_base=STATE0, cfg_dst_base=STATE1;
  logic [31:0] cfg_src0_capacity=16919104, cfg_src1_capacity=16920576;
  logic [31:0] cfg_dst_capacity=16919104;
  logic [31:0] cfg_src0_bytes=16384, cfg_src1_bytes=16384, cfg_dst_bytes=16384;
  logic [415:0] cfg_context=416'h123456789abcdef;
  logic rsp_valid, rsp_ready=0;
  logic [7:0] rsp_status;
  logic [415:0] rsp_context;
  logic source_locked, dst_published;
  logic [15:0] skip_ar_count,skip_r_count,down_ar_count,down_r_count;
  logic [15:0] add_start_count,add_done_count,aw_count,w_count,b_count;
  logic skip_arvalid,skip_arready,skip_rready,skip_rvalid,skip_rlast;
  logic [63:0] skip_araddr;
  logic [7:0] skip_arlen;
  logic [2:0] skip_arsize;
  logic [511:0] skip_rdata;
  logic [1:0] skip_rresp=0;
  logic down_arvalid,down_arready,down_rready,down_rvalid,down_rlast;
  logic [63:0] down_araddr;
  logic [7:0] down_arlen;
  logic [2:0] down_arsize;
  logic [511:0] down_rdata;
  logic [1:0] down_rresp=0;
  logic awvalid,awready,wvalid,wready,wlast,bready,bvalid;
  logic [63:0] awaddr,wstrb;
  logic [7:0] awlen;
  logic [2:0] awsize;
  logic [511:0] wdata;
  logic [1:0] bresp=0;

  laya_ffn_residual_four_row_v1 dut (.*);

  byte unsigned skip_mem[0:65535], down_mem[0:65535], dst_mem[0:65535];
  byte unsigned skip_gold[0:16383], down_gold[0:16383], dst_gold[0:16383];
  bit dst_written[0:65535];
  string skip_file,down_file,gold_file;
  bit pilot;
  integer cycle=0, active_bytes, expected_beats, expected_words;
  integer skip_model_ar=0,skip_model_r=0,down_model_ar=0,down_model_r=0;
  integer model_aw=0,model_w=0,model_b=0;
  integer last_w_cycle=-1,last_b_cycle=-1,first_ar_cycle=-1,first_r_cycle=-1;
  integer first_done_cycle=-1, consume_cycle=-1;
  integer skip_due=0,down_due=0,b_due=0;
  logic skip_pending=0,down_pending=0,write_pending=0;
  logic [63:0] skip_pending_addr,down_pending_addr,write_addr;

  assign skip_arready = !skip_pending && (cycle%5 != 0);
  assign down_arready = !down_pending && (cycle%7 != 0);
  assign awready = !write_pending && (cycle%11 != 0);
  assign wready = write_pending && !bvalid && (cycle%13 != 0);

  task automatic load_bytes(input string path,output byte unsigned arr[0:16383]);
    integer fd,n;
    begin
      fd=$fopen(path,"rb");
      if (!fd) $fatal(1,"FFR0_FILE_OPEN %s",path);
      n=$fread(arr,fd,0,16384);
      $fclose(fd);
      if (n!=16384) $fatal(1,"FFR0_FILE_SIZE path=%s read=%0d",path,n);
    end
  endtask

  task automatic check_read(input logic [63:0] addr,input logic [63:0] base,
                            input logic [7:0] len,input logic [2:0] size);
    begin
      if (addr<base || addr>base+64'd16320 || addr[5:0]!=0 ||
          len!=0 || size!=3'd6 || addr[11:0]>12'hfc0)
        $fatal(1,"FFR0_BAD_AR addr=%h base=%h len=%0d size=%0d",addr,base,len,size);
    end
  endtask

  always @(posedge clk) begin : axi_model
    integer offset;
    cycle <= cycle+1;
    if (rst_n) begin
      if (skip_arvalid && skip_arready) begin
        check_read(skip_araddr,STATE0,skip_arlen,skip_arsize);
        if (skip_pending || skip_rvalid) $fatal(1,"FFR0_SKIP_OVERLAP");
        skip_pending <= 1;
        skip_pending_addr <= skip_araddr;
        skip_due <= cycle+2+(cycle%3);
        skip_model_ar <= skip_model_ar+1;
        if (first_ar_cycle<0) first_ar_cycle <= cycle;
      end
      if (skip_pending && !skip_rvalid && cycle>=skip_due) begin
        offset=skip_pending_addr-STATE0;
        for (int j=0;j<64;j++) skip_rdata[8*j+:8] <= skip_mem[offset+j];
        skip_rvalid <= 1;
        skip_rlast <= 1;
      end
      if (skip_rvalid && skip_rready) begin
        skip_rvalid <= 0;
        skip_pending <= 0;
        skip_model_r <= skip_model_r+1;
        if (first_r_cycle<0) first_r_cycle <= cycle;
      end
      if (down_arvalid && down_arready) begin
        check_read(down_araddr,TMP,down_arlen,down_arsize);
        if (down_pending || down_rvalid) $fatal(1,"FFR0_DOWN_OVERLAP");
        down_pending <= 1;
        down_pending_addr <= down_araddr;
        down_due <= cycle+3+(cycle%4);
        down_model_ar <= down_model_ar+1;
      end
      if (down_pending && !down_rvalid && cycle>=down_due) begin
        offset=down_pending_addr-TMP;
        for (int j=0;j<64;j++) down_rdata[8*j+:8] <= down_mem[offset+j];
        down_rvalid <= 1;
        down_rlast <= 1;
      end
      if (down_rvalid && down_rready) begin
        down_rvalid <= 0;
        down_pending <= 0;
        down_model_r <= down_model_r+1;
      end
      if (awvalid && awready) begin
        if (awaddr<STATE1 || awaddr>STATE1+64'd16320 ||
            awaddr[5:0]!=0 || awaddr[11:0]>12'hfc0 ||
            awlen!=0 || awsize!=3'd6)
          $fatal(1,"FFR0_BAD_AW addr=%h len=%0d size=%0d",awaddr,awlen,awsize);
        if (write_pending || bvalid) $fatal(1,"FFR0_AW_OVERLAP");
        write_pending <= 1;
        write_addr <= awaddr;
        model_aw <= model_aw+1;
      end
      if (wvalid && wready) begin
        if (!write_pending || wstrb!==64'hffffffffffffffff || !wlast)
          $fatal(1,"FFR0_BAD_W");
        offset=write_addr-STATE1;
        for (int j=0;j<64;j++) begin
          dst_mem[offset+j] <= wdata[8*j+:8];
          dst_written[offset+j] <= 1;
        end
        model_w <= model_w+1;
        last_w_cycle <= cycle;
        b_due <= cycle + ((offset==active_bytes-64) ? 14 : 3+(cycle%3));
      end
      if (write_pending && model_w>model_b && !bvalid && cycle>=b_due)
        bvalid <= 1;
      if (bvalid && bready) begin
        bvalid <= 0;
        write_pending <= 0;
        model_b <= model_b+1;
        last_b_cycle <= cycle;
      end
      if (rsp_valid && first_done_cycle<0) first_done_cycle <= cycle;
      if (rsp_valid && rsp_ready) consume_cycle <= cycle;
      if (cycle%20000==0 && (skip_model_r || down_model_r))
        $display("FFR0_PROGRESS cycle=%0d skip_R=%0d down_R=%0d add_done=%0d B=%0d",
                 cycle,skip_model_r,down_model_r,add_done_count,model_b);
    end
  end

  task automatic issue_cfg;
    begin
      @(negedge clk); cfg_valid=1;
      do @(posedge clk); while (!cfg_ready);
      @(negedge clk); cfg_valid=0;
    end
  endtask

  task automatic consume_response(input logic [7:0] expected_status);
    logic [415:0] saved_context;
    begin
      do @(negedge clk); while (!rsp_valid);
      saved_context=rsp_context;
      if (rsp_status!=expected_status || rsp_context!==cfg_context)
        $fatal(1,"FFR0_BAD_RESPONSE status=%0d expected=%0d",rsp_status,expected_status);
      repeat(7) begin
        @(negedge clk);
        if (!rsp_valid || rsp_status!=expected_status || rsp_context!==saved_context)
          $fatal(1,"FFR0_RESPONSE_HOLD");
      end
      rsp_ready=1;
      @(posedge clk);
      @(negedge clk); rsp_ready=0;
      if (rsp_valid) $fatal(1,"FFR0_DOUBLE_RESPONSE");
    end
  endtask

  task automatic reject_probe(input integer kind);
    integer ar_before,aw_before;
    begin
      ar_before=skip_model_ar+down_model_ar;
      aw_before=model_aw;
      case (kind)
        0: cfg_op=8'h61;
        1: cfg_dst_bank=0;
        2: cfg_dst_base=STATE0;
        3: cfg_src0_bytes=cfg_src0_capacity+1;
        4: cfg_generation=0;
      endcase
      issue_cfg();
      consume_response(8'd7);
      if (skip_model_ar+down_model_ar!=ar_before || model_aw!=aw_before ||
          source_locked || dst_published)
        $fatal(1,"FFR0_REJECT_HAD_AXI kind=%0d",kind);
      cfg_op=8'h62;
      cfg_dst_bank=1;
      cfg_dst_base=STATE1;
      cfg_src0_bytes=active_bytes;
      cfg_generation=1;
    end
  endtask

  initial begin : main
    integer limit;
    if (!$value$plusargs("SKIP_FILE=%s",skip_file) ||
        !$value$plusargs("DOWN_FILE=%s",down_file) ||
        !$value$plusargs("GOLD_FILE=%s",gold_file))
      $fatal(1,"FFR0_MISSING_FIXTURE");
    pilot=$test$plusargs("PILOT");
    cfg_rows=pilot ? 1 : 4;
    active_bytes=pilot ? 4096 : 16384;
    expected_beats=pilot ? 64 : 256;
    expected_words=pilot ? 1024 : 4096;
    cfg_src0_bytes=active_bytes;
    cfg_src1_bytes=active_bytes;
    cfg_dst_bytes=active_bytes;
    load_bytes(skip_file,skip_gold);
    load_bytes(down_file,down_gold);
    load_bytes(gold_file,dst_gold);
    for (int i=0;i<65536;i++) begin
      skip_mem[i]=i<16384 ? skip_gold[i] : 8'ha5;
      down_mem[i]=i<16384 ? down_gold[i] : 8'ha5;
      dst_mem[i]=8'ha5;
      dst_written[i]=0;
    end
    skip_rvalid=0;skip_rlast=0;down_rvalid=0;down_rlast=0;bvalid=0;
    repeat(5) @(negedge clk);rst_n=1;
    for (int kind=0;kind<5;kind++) reject_probe(kind);
    $display("FFR0_DESCRIPTOR_REJECT_PASS cases=5 zero_axi=1");
    issue_cfg();
    limit=pilot ? 200000 : 700000;
    while (!rsp_valid && cycle<limit) @(negedge clk);
    if (!rsp_valid) $fatal(1,"FFR0_CHAIN_TIMEOUT cycle=%0d",cycle);
    if (!dst_published || source_locked || rsp_status!=0)
      $fatal(1,"FFR0_EARLY_OR_BAD_PUBLISH status=%0d publish=%0d source_lock=%0d",
             rsp_status,dst_published,source_locked);
    if (skip_ar_count!=expected_beats || skip_r_count!=expected_beats ||
        down_ar_count!=expected_beats || down_r_count!=expected_beats ||
        add_start_count!=expected_words || add_done_count!=expected_words ||
        aw_count!=expected_beats || w_count!=expected_beats || b_count!=expected_beats)
      $fatal(1,"FFR0_DUT_COUNTS skip=%0d/%0d down=%0d/%0d add=%0d/%0d AW/W/B=%0d/%0d/%0d",
             skip_ar_count,skip_r_count,down_ar_count,down_r_count,
             add_start_count,add_done_count,aw_count,w_count,b_count);
    if (model_aw!=expected_beats || model_w!=expected_beats || model_b!=expected_beats ||
        skip_model_ar!=expected_beats || skip_model_r!=expected_beats ||
        down_model_ar!=expected_beats || down_model_r!=expected_beats ||
        last_b_cycle-last_w_cycle<13)
      $fatal(1,"FFR0_MODEL_COUNTS_OR_LAST_B last_gap=%0d",last_b_cycle-last_w_cycle);
    consume_response(0);
    for (int i=0;i<65536;i++) begin
      if (skip_mem[i] !== (i<16384 ? skip_gold[i] : 8'ha5))
        $fatal(1,"FFR0_SKIP_PROTECTION offset=%0d",i);
      if (down_mem[i] !== (i<16384 ? down_gold[i] : 8'ha5))
        $fatal(1,"FFR0_DOWN_PROTECTION offset=%0d",i);
      if (i<active_bytes) begin
        if (dst_mem[i] !== dst_gold[i] || !dst_written[i])
          $fatal(1,"FFR0_DST_DIFF offset=%0d got=%02x gold=%02x written=%0d",
                 i,dst_mem[i],dst_gold[i],dst_written[i]);
      end else if (dst_mem[i]!==8'ha5 || dst_written[i])
        $fatal(1,"FFR0_DST_PROTECTION offset=%0d",i);
    end
    $display("FFR0_BOUNDARIES pilot=%0d first_AR=%0d first_R=%0d last_W=%0d last_B=%0d first_done=%0d consume=%0d total=%0d",
             pilot,first_ar_cycle,first_r_cycle,last_w_cycle,last_b_cycle,
             first_done_cycle,consume_cycle,cycle);
    $display("FFR0_FOUR_ROW_PASS rows=%0d words=%0d R=%0d+%0d AW/W/B=%0d/%0d/%0d protected_bytes=196608",
             cfg_rows,expected_words,skip_model_r,down_model_r,model_aw,model_w,model_b);
    $finish;
  end
  initial begin
    repeat(800000) @(posedge clk);
    $fatal(1,"FFR0_TB_WATCHDOG");
  end
endmodule
