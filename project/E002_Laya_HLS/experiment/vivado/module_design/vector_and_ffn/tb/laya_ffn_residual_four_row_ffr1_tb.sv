`timescale 1ns/1ps
module laya_ffn_residual_four_row_ffr1_tb;
  localparam logic [63:0] STATE0 = 64'h300000000;
  localparam logic [63:0] STATE1 = 64'h310000000;
  localparam logic [63:0] TMP = STATE1 + 64'h800000;
  // Frozen production Status values; no expectation is read from DUT constants.
  localparam logic [7:0] E_NUMERICAL=8'd6, E_PROTOCOL=8'd7, E_INTERNAL=8'd8;
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
  bit pilot,error_only;
  integer cycle=0, active_bytes, expected_beats, expected_words;
  integer skip_model_ar=0,skip_model_r=0,down_model_ar=0,down_model_r=0;
  integer model_aw=0,model_w=0,model_b=0;
  integer last_w_cycle=-1,last_b_cycle=-1,first_ar_cycle=-1,first_r_cycle=-1;
  integer first_done_cycle=-1, consume_cycle=-1;
  bit normal_started=0;
  integer skip_due=0,down_due=0,b_due=0;
  logic skip_pending=0,down_pending=0,write_pending=0;
  logic [63:0] skip_pending_addr,down_pending_addr,write_addr;
  logic hold_skip_ar=0,hold_down_ar=0,hold_aw=0,hold_w=0;
  logic [63:0] held_skip_addr,held_down_addr,held_awaddr;
  logic [511:0] held_wdata;
  bit inject_skip_r=0,inject_down_r=0,inject_b=0;
  integer cfg_cycle=-1,normal_consume_cycle=-1;
  integer skip_first_ar=-1,skip_last_ar=-1,skip_first_r=-1,skip_last_r=-1;
  integer down_first_ar=-1,down_last_ar=-1,down_first_r=-1,down_last_r=-1;
  integer first_aw=-1,last_aw=-1,first_w=-1,first_b=-1;
  integer lock_rise=-1,lock_fall=-1,publish_rise=-1;
  integer add_accept_cycle=-1,add_latency_sum=0,add_latency_min=2147483647;
  integer add_latency_max=-1,add_latency_count=0,add_consumed=0;
  integer add_latency_hist[0:255];
  integer phase_cycles[0:10];
  integer progress_counts[0:11];
  integer progress_events=0;
  bit cfg_seen=0,normal_consumed=0,prev_locked=0,prev_published=0;

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
      if (hold_skip_ar && (!skip_arvalid || skip_araddr!==held_skip_addr))
        $fatal(1,"FFR0_SKIP_AR_NOT_HELD");
      if (hold_down_ar && (!down_arvalid || down_araddr!==held_down_addr))
        $fatal(1,"FFR0_DOWN_AR_NOT_HELD");
      if (hold_aw && (!awvalid || awaddr!==held_awaddr))
        $fatal(1,"FFR0_AW_NOT_HELD");
      if (hold_w && (!wvalid || wdata!==held_wdata || wstrb!=='1 || !wlast))
        $fatal(1,"FFR0_W_NOT_HELD");
      hold_skip_ar <= skip_arvalid && !skip_arready;
      hold_down_ar <= down_arvalid && !down_arready;
      hold_aw <= awvalid && !awready;
      hold_w <= wvalid && !wready;
      held_skip_addr <= skip_araddr;
      held_down_addr <= down_araddr;
      held_awaddr <= awaddr;
      held_wdata <= wdata;
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
        skip_rresp <= inject_skip_r ? 2'b10 : 2'b00;
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
        down_rresp <= inject_down_r ? 2'b10 : 2'b00;
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
      if (write_pending && model_w>model_b && !bvalid && cycle>=b_due) begin
        bvalid <= 1;
        bresp <= inject_b ? 2'b10 : 2'b00;
      end
      if (bvalid && bready) begin
        bvalid <= 0;
        write_pending <= 0;
        model_b <= model_b+1;
        last_b_cycle <= cycle;
      end
      if (rsp_valid && first_done_cycle<0) first_done_cycle <= cycle;
      if (rsp_valid && rsp_ready) consume_cycle <= cycle;
      if (normal_started && dst_published && model_b<expected_beats)
        $fatal(1,"FFR0_PUBLISHED_BEFORE_LAST_B b=%0d expected=%0d",model_b,expected_beats);
      if (normal_started && rsp_valid && rsp_status==0 && model_b<expected_beats)
        $fatal(1,"FFR0_SUCCESS_BEFORE_LAST_B b=%0d expected=%0d",model_b,expected_beats);
    end
  end

  // All reported edges are sampled at the active edge before NBA updates.
  // Only actual accepted transactions and arithmetic pulses advance the
  // watchdog counters; the cycle counter alone never prints progress.
  always @(posedge clk) begin : ffr1_monitor
    integer latency;
    bit event_seen,terminal_event;
    event_seen=0;terminal_event=0;
    if (rst_n) begin
      if (cfg_valid && cfg_ready) begin
        progress_counts[0]++;event_seen=1;terminal_event=1;
        if (normal_started && !cfg_seen) begin cfg_seen=1;cfg_cycle=cycle;end
      end
      if (skip_arvalid && skip_arready) begin
        progress_counts[1]++;event_seen=1;
        if(normal_started)begin
          if(skip_first_ar<0)skip_first_ar=cycle;
          skip_last_ar=cycle;
        end
      end
      if (skip_rvalid && skip_rready) begin
        progress_counts[2]++;event_seen=1;
        if(normal_started)begin
          if(skip_first_r<0)skip_first_r=cycle;
          skip_last_r=cycle;
        end
      end
      if (down_arvalid && down_arready) begin
        progress_counts[3]++;event_seen=1;
        if(normal_started)begin
          if(down_first_ar<0)down_first_ar=cycle;
          down_last_ar=cycle;
        end
      end
      if (down_rvalid && down_rready) begin
        progress_counts[4]++;event_seen=1;
        if(normal_started)begin
          if(down_first_r<0)down_first_r=cycle;
          down_last_r=cycle;
        end
      end
      if (dut.slot_accepted) begin
        progress_counts[5]++;event_seen=1;
        if(normal_started)begin
          if(add_accept_cycle>=0)$fatal(1,"FFR1_ADD_OVERLAP");
          add_accept_cycle=cycle;
        end
      end
      if (dut.slot_returned) begin
        progress_counts[6]++;event_seen=1;
        if(normal_started)begin
          if(add_accept_cycle<0)$fatal(1,"FFR1_ADD_UNMATCHED_RETURN");
          latency=cycle-add_accept_cycle;
          if(latency<0 || latency>255)$fatal(1,"FFR1_ADD_LATENCY_RANGE %0d",latency);
          add_latency_hist[latency]++;
          add_latency_sum+=latency;add_latency_count++;
          if(latency<add_latency_min)add_latency_min=latency;
          if(latency>add_latency_max)add_latency_max=latency;
          add_accept_cycle=-1;
        end
      end
      if (dut.slot_consumed) begin
        progress_counts[7]++;event_seen=1;
        if(normal_started)add_consumed++;
      end
      if (awvalid && awready) begin
        progress_counts[8]++;event_seen=1;
        if(normal_started)begin if(first_aw<0)first_aw=cycle;last_aw=cycle;end
      end
      if (wvalid && wready) begin
        progress_counts[9]++;event_seen=1;
        if(normal_started && first_w<0)first_w=cycle;
      end
      if (bvalid && bready) begin
        progress_counts[10]++;event_seen=1;
        if(normal_started && first_b<0)first_b=cycle;
      end
      if (rsp_valid && rsp_ready) begin
        progress_counts[11]++;event_seen=1;terminal_event=1;
        if(normal_started)begin normal_consumed=1;normal_consume_cycle=cycle;end
      end
      if(normal_started && cfg_seen && !normal_consumed)begin
        if(int'(dut.state)<0 || int'(dut.state)>10)$fatal(1,"FFR1_UNKNOWN_STATE");
        phase_cycles[int'(dut.state)]++;
      end else if(normal_started && normal_consumed && normal_consume_cycle==cycle)
        phase_cycles[int'(dut.state)]++;
      if(normal_started)begin
        if(source_locked && !prev_locked)lock_rise=cycle;
        if(!source_locked && prev_locked)lock_fall=cycle;
        if(dst_published && !prev_published)publish_rise=cycle;
      end
      prev_locked=source_locked;prev_published=dst_published;
      if(event_seen)begin
        progress_events++;
        if(terminal_event || progress_events%64==0)
          $display("FFR1_PROGRESS cfg=%0d sar=%0d sr=%0d dar=%0d dr=%0d aa=%0d ar=%0d ac=%0d aw=%0d w=%0d b=%0d rsp=%0d",
             progress_counts[0],progress_counts[1],progress_counts[2],
             progress_counts[3],progress_counts[4],progress_counts[5],
             progress_counts[6],progress_counts[7],progress_counts[8],
             progress_counts[9],progress_counts[10],progress_counts[11]);
      end
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
      consume_response(E_PROTOCOL);
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

  task automatic bus_error_probe(input integer kind);
    integer sar0,sr0,dar0,dr0,aw0,w0,b0;
    begin
      sar0=skip_model_ar;sr0=skip_model_r;
      dar0=down_model_ar;dr0=down_model_r;
      aw0=model_aw;w0=model_w;b0=model_b;
      inject_skip_r=(kind==0);
      inject_down_r=(kind==1);
      inject_b=(kind==2);
      issue_cfg();
      consume_response(E_INTERNAL);
      if(skip_model_ar-sar0!=1 || skip_model_r-sr0!=1 ||
         down_model_ar-dar0!=(kind==0 ? 0 : 1) ||
         down_model_r-dr0!=(kind==0 ? 0 : 1) ||
         model_aw-aw0!=(kind==2 ? 1 : 0) ||
         model_w-w0!=(kind==2 ? 1 : 0) ||
         model_b-b0!=(kind==2 ? 1 : 0) ||
         source_locked || dst_published || dut.slot_busy || dut.slot_out_valid ||
         skip_pending || down_pending || write_pending ||
         skip_rvalid || down_rvalid || bvalid)
        $fatal(1,"FFR1_AXI_ERROR_DEBT kind=%0d skip=%0d/%0d down=%0d/%0d AW/W/B=%0d/%0d/%0d",
          kind,skip_model_ar-sar0,skip_model_r-sr0,
          down_model_ar-dar0,down_model_r-dr0,
          model_aw-aw0,model_w-w0,model_b-b0);
      if(kind==2)
        for(int j=0;j<64;j++)
          if(dst_mem[j]!==dst_gold[j] || !dst_written[j])
            $fatal(1,"FFR1_B_ERROR_WRITE_FACT offset=%0d",j);
      repeat(4) @(negedge clk);
      if(skip_model_ar-sar0!=1 || down_model_ar-dar0!=(kind==0 ? 0 : 1) ||
         model_aw-aw0!=(kind==2 ? 1 : 0) || model_b-b0!=(kind==2 ? 1 : 0))
        $fatal(1,"FFR1_AX_ERROR_LATE_ACTIVITY kind=%0d",kind);
      inject_skip_r=0;inject_down_r=0;inject_b=0;
      $display("FFR1_AXI_REJECT_PASS kind=%0d status=8 skip_AR/R=%0d/%0d down_AR/R=%0d/%0d AW/W/B=%0d/%0d/%0d published=0",
        kind,skip_model_ar-sar0,skip_model_r-sr0,
        down_model_ar-dar0,down_model_r-dr0,
        model_aw-aw0,model_w-w0,model_b-b0);
    end
  endtask

  initial begin : main
    integer limit,base_skip_r,base_down_r,base_aw,base_w,base_b;
    integer phase_sum,hist_sum;
    if (!$value$plusargs("SKIP_FILE=%s",skip_file) ||
        !$value$plusargs("DOWN_FILE=%s",down_file) ||
        !$value$plusargs("GOLD_FILE=%s",gold_file))
      $fatal(1,"FFR0_MISSING_FIXTURE");
    pilot=$test$plusargs("PILOT");
    error_only=$test$plusargs("ERROR_ONLY");
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
    for(int i=0;i<256;i++)add_latency_hist[i]=0;
    for(int i=0;i<11;i++)phase_cycles[i]=0;
    for(int i=0;i<12;i++)progress_counts[i]=0;
    repeat(5) @(negedge clk);rst_n=1;
    for (int kind=0;kind<5;kind++) reject_probe(kind);
    $display("FFR0_DESCRIPTOR_REJECT_PASS cases=5 zero_axi=1");
    if(!error_only)begin
    first_done_cycle=-1;
    consume_cycle=-1;
    normal_started=1;
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
    base_skip_r=skip_model_r;base_down_r=down_model_r;
    base_aw=model_aw;base_w=model_w;base_b=model_b;
    normal_started=0;
    phase_sum=0;hist_sum=0;
    for(int i=0;i<11;i++)phase_sum+=phase_cycles[i];
    for(int i=0;i<256;i++)begin
      hist_sum+=add_latency_hist[i];
      if(add_latency_hist[i])
        $display("FFR1_ADD_LATENCY latency=%0d count=%0d",i,add_latency_hist[i]);
    end
    if(cfg_cycle<0 || normal_consume_cycle<cfg_cycle ||
       phase_sum!=normal_consume_cycle-cfg_cycle+1 ||
       hist_sum!=expected_words || add_latency_count!=expected_words ||
       add_consumed!=expected_words || add_accept_cycle!=-1 ||
       lock_rise<cfg_cycle || lock_fall<down_last_r ||
       publish_rise<last_b_cycle ||
       skip_first_ar<cfg_cycle || skip_last_r<skip_first_r ||
       down_first_ar<skip_first_r || down_last_r<down_first_r ||
       first_aw<down_first_r || first_b<first_w)
      $fatal(1,"FFR1_MEASUREMENT_INCONSISTENT phase=%0d elapsed=%0d hist=%0d words=%0d",
        phase_sum,normal_consume_cycle-cfg_cycle+1,hist_sum,expected_words);
    $display("FFR1_EDGES sample=posedge_preNBA cfg=%0d skip_AR=%0d/%0d skip_R=%0d/%0d down_AR=%0d/%0d down_R=%0d/%0d lock=%0d/%0d last_read=%0d AW=%0d/%0d W=%0d/%0d B=%0d/%0d publish=%0d response=%0d/%0d",
      cfg_cycle,skip_first_ar,skip_last_ar,skip_first_r,skip_last_r,
      down_first_ar,down_last_ar,down_first_r,down_last_r,
      lock_rise,lock_fall,(skip_last_r>down_last_r ? skip_last_r : down_last_r),
      first_aw,last_aw,first_w,last_w_cycle,first_b,last_b_cycle,
      publish_rise,first_done_cycle,normal_consume_cycle);
    $display("FFR1_ADD_SUM count=%0d consumed=%0d sum=%0d min=%0d max=%0d",
      add_latency_count,add_consumed,add_latency_sum,add_latency_min,add_latency_max);
    for(int i=0;i<11;i++)$display("FFR1_PHASE state=%0d cycles=%0d",i,phase_cycles[i]);
    $display("FFR1_PHASE_SUM cfg_to_consume_inclusive=%0d sum=%0d",normal_consume_cycle-cfg_cycle+1,phase_sum);
    end
    begin : numeric_error_probes
      integer old_aw,old_w,old_b;
      old_aw=model_aw;old_w=model_w;old_b=model_b;
      skip_mem[0]=8'h00;skip_mem[1]=8'h00;skip_mem[2]=8'hc0;skip_mem[3]=8'h7f;
      issue_cfg();
      consume_response(E_NUMERICAL);
      if (model_aw!=old_aw || model_w!=old_w || model_b!=old_b || dst_published || source_locked)
        $fatal(1,"FFR0_NAN_ERROR_DEBT");
      for (int j=0;j<4;j++) skip_mem[j]=skip_gold[j];
      skip_mem[0]=8'hff;skip_mem[1]=8'hff;skip_mem[2]=8'h7f;skip_mem[3]=8'h7f;
      down_mem[0]=8'hff;down_mem[1]=8'hff;down_mem[2]=8'h7f;down_mem[3]=8'h7f;
      issue_cfg();
      consume_response(E_NUMERICAL);
      if (model_aw!=old_aw || model_w!=old_w || model_b!=old_b || dst_published || source_locked)
        $fatal(1,"FFR0_OVERFLOW_ERROR_DEBT");
      for (int j=0;j<4;j++) begin
        skip_mem[j]=skip_gold[j];down_mem[j]=down_gold[j];
      end
      $display("FFR1_NUMERICAL_REJECT_PASS status=6 nan=1 finite_overflow=1 zero_new_writes=1");
    end
    cfg_rows=1;active_bytes=4096;expected_beats=64;expected_words=1024;
    cfg_src0_bytes=4096;cfg_src1_bytes=4096;cfg_dst_bytes=4096;
    for(int kind=0;kind<3;kind++)bus_error_probe(kind);
    $display("FFR1_ERROR_PASS numerical=2 axi=3 descriptor=5");
    if(!error_only)
      $display("FFR1_FOUR_ROW_PASS rows=%0d words=%0d R=%0d+%0d AW/W/B=%0d/%0d/%0d protected_bytes=196608",
             pilot ? 1 : 4,pilot ? 1024 : 4096,
             base_skip_r,base_down_r,base_aw,base_w,base_b);
    $finish;
  end
  initial begin
    repeat(800000) @(posedge clk);
    $fatal(1,"FFR0_TB_WATCHDOG");
  end
endmodule
