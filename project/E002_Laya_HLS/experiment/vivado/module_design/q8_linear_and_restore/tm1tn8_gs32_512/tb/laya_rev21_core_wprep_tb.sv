`timescale 1ns/1ps
module laya_rev21_core_wprep_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0;
  logic wp_valid=0,wp_ready,wp_done_valid,wp_done_ready=0;
  logic [31:0] wp_id=210,wp_source_epoch=1,wp_epoch=1;
  logic [63:0] wp_request=3,wp_generation=1;
  logic [15:0] wp_key=16'h0001;
  logic [3327:0] wp_model;
  logic [671:0] wp_numeric;
  logic [1023:0] wp_header;
  logic [2:0][63:0] wp_base;
  logic [2:0][31:0] wp_bytes;
  logic [63:0] wp_aux_base=0,wp_bias_base=0;
  logic [31:0] wp_bias_bytes=0;
  logic [31:0] wp_done_id,wp_done_source_epoch,wp_done_epoch;
  logic [63:0] wp_done_request,wp_done_generation;
  logic [15:0] wp_done_key;
  logic [3327:0] wp_done_model;
  logic [671:0] wp_done_numeric;
  logic [3:0] wp_done_status;
  logic [7:0] wp_done_op;
  logic [15:0] wp_done_check_status;
  logic [31:0] wp_done_detail;
  logic [63:0] wp_done_bad64;
  logic [3:0] done_phase;
  logic [2:0] result_exec;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] done_bad_element;
  logic load_done,load_error,load_reject;
  logic load_protocol_error,load_numeric_error;
  logic [31:0] load_scale_checks,load_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch,slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst,rresp;
  logic [2:0] arvalid,arready,rlast,rvalid,rready;
  logic [2:0][511:0] rdata;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst,aux_rresp;
  logic aux_arvalid,aux_arready,aux_rlast,aux_rvalid,aux_rready;
  logic [127:0] aux_rdata;
  laya_lnq_wi_gqdown_row_v1 dut (
    .clk,.rst_n,.cmd_valid(wp_valid),.cmd_ready(wp_ready),
    .cmd_id(wp_id),.cmd_cold(1'b1),.cmd_mode(1'b1),
    .cmd_row(7'd0),.cmd_prepared_source,.cmd_source_epoch(wp_source_epoch),
    .cmd_exec,.cmd_gamma_aux_base(64'd0),.cmd_gamma_aux_span(64'd0),
    .prep_begin_valid(1'b0),.prep_begin_ready(),.prep_kind(2'd0),
    .prep_id(32'd0),.prep_row(7'd0),.prep_epoch(32'd0),
    .prep_model_identity('0),.prep_numeric_identity('0),
    .prep_gamma_aux_base(64'd0),.prep_gamma_aux_span(64'd0),
    .prep_write_valid(1'b0),.prep_write_ready(),
    .prep_write_index(11'd0),.prep_write_bits(32'd0),
    .prep_commit_valid(1'b0),.prep_commit_ready(),
    .prep_abort_valid(1'b0),.prep_abort_ready(),
    .prep_token_valid(),.gamma_token_valid(),.prep_fault(),
    .a_window_ready(),.a_window_release_valid(1'b0),
    .a_window_discard(1'b0),.a_window_release_ready(),
    .cmd_w_epoch(wp_epoch),.cmd_weight_key(wp_key),
    .cmd_model_identity(wp_model),.cmd_numeric_identity(wp_numeric),
    .cmd_task_context({8'd1,16'd0,8'd128,8'd1,16'd0,8'd1,32'd210}),
    .cmd_expected_aux_header(wp_header),
    .cmd_load_base(wp_base),.cmd_load_bytes(wp_bytes),
    .cmd_aux_base(wp_aux_base),.cmd_bias_base(wp_bias_base),
    .cmd_bias_bytes(wp_bias_bytes),
    .cmd_down_w_epoch(32'd0),.cmd_down_weight_key(16'd0),
    .cmd_down_expected_aux_header('0),.cmd_down_load_base('0),
    .cmd_down_load_bytes('0),.cmd_down_aux_base(64'd0),
    .cmd_down_bias_base(64'd0),.cmd_down_bias_bytes(32'd0),
    .x_valid(1'b0),.x_ready(),.x_bits(32'd0),
    .gamma_valid(1'b0),.gamma_ready(),.gamma_bits(32'd0),
    .row_valid(),.rd_valid(1'b0),.rd_ready(),.rd_tile(10'd0),
    .rsp_valid(),.rsp_ready(1'b0),.rsp_tile(),.rsp_bits(),
    .row_release_valid(1'b0),.row_release_discard(1'b0),
    .row_release_ready(),.done_valid(wp_done_valid),
    .done_ready(wp_done_ready),.done_status(wp_done_status),
    .done_phase,.done_op(wp_done_op),
    .done_check_status(wp_done_check_status),
    .done_detail(wp_done_detail),.done_bad64(wp_done_bad64),
    .result_mode,.result_exec,.result_row,
    .done_bad_element,.mean_bits(),.variance_bits(),.inverse_bits(),
    .actual_w_reads(),.actual_w_returns(),.actual_stripes(),
    .actual_ps_commits(),.araddr,.arlen,.arsize,.arburst,
    .arvalid,.arready,.rdata,.rresp,.rlast,.rvalid,.rready,
    .aux_araddr,.aux_arlen,.aux_arsize,.aux_arburst,.aux_arvalid,
    .aux_arready,.aux_rdata,.aux_rresp,.aux_rlast,.aux_rvalid,.aux_rready,
    .wprep_result_id(wp_done_id),
    .wprep_result_source_epoch(wp_done_source_epoch),
    .wprep_result_epoch(wp_done_epoch),
    .wprep_result_request(wp_done_request),
    .wprep_result_generation(wp_done_generation),
    .wprep_result_key(wp_done_key),
    .wprep_result_model(wp_done_model),
    .wprep_result_numeric(wp_done_numeric)
  );
  assign load_done=dut.engine.w_cache.load_done;
  assign load_error=dut.engine.w_cache.load_error;
  assign load_reject=dut.engine.w_cache.load_reject;
  assign load_protocol_error=dut.engine.w_cache.load_protocol_error;
  assign load_numeric_error=dut.engine.w_cache.load_numeric_error;
  assign load_scale_checks=dut.engine.w_cache.load_scale_checks;
  assign load_bad_element=dut.engine.w_cache.load_bad_element;
  assign slot_state=dut.engine.w_cache.slot_state;
  assign slot_epoch=dut.engine.w_cache.slot_epoch;
  assign slot_readers=dut.engine.w_cache.slot_readers;
  assign slot_coverage=dut.engine.w_cache.slot_coverage;
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [63:0] cfg[0:12];
  logic [511:0] q0[0:24575],q1[0:24575],scales[0:3071];
  string fixture;
  int cycle=0,r_count[0:2],issued[0:2],beat[0:2],left[0:2];
  bit active[0:2];
  int aux_count=0,aux_beat=0,aux_left=0;
  bit aux_active=0;
  bit bus_fault,scale_fault;
  logic [4363:0] held_check;
  logic [2:0] cmd_exec=3'd1;
  logic cmd_prepared_source=1;
  function automatic logic [511:0] payload(input int p,input int idx);
    case(p)0:return q0[idx];1:return q1[idx];default:return scales[idx];endcase
  endfunction
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!active[p] && cycle%5!=p;
      rvalid[p]=active[p] && cycle%7!=p;
      rdata[p]=payload(p,beat[p]);
      if(scale_fault && p==2 && beat[p]==0)rdata[p][15:0]=16'h7c00;
      rresp[p]=(bus_fault && p==0 && beat[p]==24575) ? 2'b10 : 0;
      rlast[p]=active[p] && left[p]==1;
    end
    aux_arready=!aux_active && cycle%3!=0;
    aux_rvalid=aux_active && cycle%5!=0;
    aux_rdata=header_words[aux_beat];
    aux_rresp=0;aux_rlast=aux_active && aux_left==1;
  end
  always @(posedge clk)begin
    int remain,page,beats;
    if(!rst_n)begin
      cycle<=0;aux_count<=0;aux_active<=0;aux_beat<=0;aux_left<=0;
      for(int p=0;p<3;p++)begin
        r_count[p]<=0;issued[p]<=0;beat[p]<=0;left[p]<=0;active[p]<=0;
      end
    end else begin
      cycle<=cycle+1;
      if(cycle>40000000)$fatal(1,"W_PREP_CYCLE_CAP");
      if(cycle%5000==0)$display("W_PREP_PROGRESS p0=%0d p1=%0d scale=%0d aux=%0d cycle=%0d",r_count[0],r_count[1],r_count[2],aux_count,cycle);
      for(int p=0;p<3;p++)begin
        if(arvalid[p] && arready[p])begin
          if(active[p] || araddr[p]!=wp_base[p]+issued[p] ||
             arsize[p]!=3'd6 || arburst[p]!=2'd1)
            $fatal(1,"W_PREP_AR p=%0d addr=%h",p,araddr[p]);
          remain=(int'(wp_bytes[p])-issued[p])/64;
          page=(4096-int'(araddr[p]%4096))/64;
          beats=remain<64 ? remain:64;
          if(beats>page)beats=page;
          if(beats<=0 || arlen[p]+1!=beats)$fatal(1,"W_PREP_AR_LEN p=%0d",p);
          active[p]<=1;beat[p]<=issued[p]/64;left[p]<=beats;
          issued[p]<=issued[p]+beats*64;
        end
        if(rvalid[p] && rready[p])begin
          if(!active[p] || left[p]<=0 || rlast[p]!=(left[p]==1))
            $fatal(1,"W_PREP_R p=%0d",p);
          beat[p]<=beat[p]+1;left[p]<=left[p]-1;
          r_count[p]<=r_count[p]+1;
          if(rlast[p])active[p]<=0;
        end
      end
      if(aux_arvalid && aux_arready)begin
        if(aux_active || aux_araddr!=wp_aux_base+aux_count*16 ||
           aux_arsize!=3'd4 || aux_arburst!=2'd1)
          $fatal(1,"W_PREP_AUX_AR addr=%h count=%0d",aux_araddr,aux_count);
        aux_active<=1;aux_beat<=aux_count;aux_left<=int'(aux_arlen)+1;
      end
      if(aux_rvalid && aux_rready)begin
        if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
          $fatal(1,"W_PREP_AUX_R");
        aux_count<=aux_count+1;aux_beat<=aux_beat+1;
        aux_left<=aux_left-1;
        if(aux_rlast)aux_active<=0;
      end
    end
  end
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"W_PREP_FIXTURE");
    bus_fault=$test$plusargs("BUS_FAULT");
    scale_fault=$test$plusargs("SCALE_FAULT");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/qkv_config.hex"},cfg);
    $readmemh({fixture,"/qkv_q0.hex"},q0);
    $readmemh({fixture,"/qkv_q1.hex"},q1);
    $readmemh({fixture,"/qkv_scale.hex"},scales);
    wp_model=model_rom[0];wp_header=header_rom[0];
    wp_numeric={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    for(int p=0;p<3;p++)begin
      wp_base[p]=cfg[3+p];wp_bytes[p]=cfg[6+p][31:0];
    end
    wp_bias_base=cfg[9];
    if(wp_bytes[0]!=32'd1572864 || wp_bytes[1]!=32'd1572864 ||
       wp_bytes[2]!=32'd196608 || cfg[10]!=0)
      $fatal(1,"W_PREP_FIXTURE_SHAPE");
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);#1ps;if(!wp_ready)$fatal(1,"CORE_LOCAL_REJECT_NOT_READY");
    wp_valid=1;@(negedge clk);wp_valid=0;
    for(int guard=0;guard<16 && !wp_done_valid;guard++)@(negedge clk);
    if(!wp_done_valid || wp_done_status!=7 || wp_done_op!=8'h10 ||
       wp_done_check_status!=7 || wp_done_detail!=32'h0710_0005 ||
       wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
       done_phase!=4'd14 || done_bad_element!=32'hffff_ffff ||
       !result_mode || result_exec!=3'd1 || result_row!=0 ||
       r_count[0]!=0 || r_count[1]!=0 || r_count[2]!=0 || aux_count!=0)
      $fatal(1,"CORE_LOCAL_REJECT_CHECK");
    repeat(3)begin
      @(negedge clk);
      if(!wp_done_valid || wp_done_status!=7 || wp_done_op!=8'h10 ||
         wp_done_check_status!=7 || wp_done_detail!=32'h0710_0005 ||
         wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
         done_phase!=4'd14 || done_bad_element!=32'hffff_ffff ||
         !result_mode || result_exec!=3'd1 || result_row!=0 ||
         r_count[0]!=0 || r_count[1]!=0 || r_count[2]!=0 || aux_count!=0)
        $fatal(1,"CORE_LOCAL_REJECT_HOLD");
    end
    wp_done_ready=1;@(negedge clk);wp_done_ready=0;
    cmd_exec=3'd4;cmd_prepared_source=0;
    @(negedge clk);#1ps;if(!wp_ready)$fatal(1,"W_PREP_NOT_READY");
    wp_valid=1;@(negedge clk);wp_valid=0;
    for(int guard=0;guard<40000000 && !wp_done_valid;guard++)@(negedge clk);
    if(!wp_done_valid || r_count[0]!=24576 || r_count[1]!=24576 ||
       r_count[2]!=3072 || aux_count!=8 ||
       slot_coverage[0][0]!=32'd1572864 ||
       slot_coverage[0][1]!=32'd1572864 ||
       slot_coverage[0][2]!=32'd196608 ||
       load_scale_checks!=32'd98304 ||
       wp_done_id!=wp_id || wp_done_source_epoch!=wp_source_epoch ||
       wp_done_epoch!=wp_epoch || wp_done_request!=wp_request ||
       wp_done_generation!=wp_generation || wp_done_key!=wp_key ||
       wp_done_model!=wp_model || wp_done_numeric!=wp_numeric ||
       wp_done_op!=8'h80)
      $fatal(1,"W_PREP_COVERAGE_OR_IDENTITY count=%0d/%0d/%0d aux=%0d",r_count[0],r_count[1],r_count[2],aux_count);
    if(bus_fault)begin
      if(wp_done_status!=7 || wp_done_check_status!=7 ||
         wp_done_detail!=32'h0780_0005 ||
         wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
         !load_protocol_error)$fatal(1,"W_PREP_BUS_CLASS");
    end else if(scale_fault)begin
      if(wp_done_status!=6 || wp_done_check_status!=6 ||
         wp_done_detail!=32'h0780_000f ||
         wp_done_bad64!=0 || !load_numeric_error ||
         load_protocol_error)$fatal(1,"W_PREP_SCALE_CLASS");
    end else if(wp_done_status!=0 || wp_done_check_status!=0 ||
                wp_done_detail!=0 || wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
                slot_state[0]!=3'd2 || slot_readers[0]!=0)
      $fatal(1,"W_PREP_SUCCESS_CLASS status=%0d",wp_done_status);
    held_check={wp_done_status,wp_done_op,wp_done_check_status,
                wp_done_detail,wp_done_bad64,wp_done_model,wp_done_numeric,
                wp_done_id,wp_done_source_epoch,wp_done_epoch,
                wp_done_request,wp_done_generation,wp_done_key};
    repeat(3)begin
      @(negedge clk);
      if(!wp_done_valid || {wp_done_status,wp_done_op,
          wp_done_check_status,wp_done_detail,wp_done_bad64,
          wp_done_model,wp_done_numeric,wp_done_id,
          wp_done_source_epoch,wp_done_epoch,wp_done_request,
          wp_done_generation,wp_done_key}!==held_check)
        $fatal(1,"W_PREP_DONE_NOT_HELD");
    end
    wp_done_ready=1;@(negedge clk);wp_done_ready=0;
    if(wp_done_valid)$fatal(1,"W_PREP_DONE_NOT_CONSUMED");
    wp_epoch=0;
    @(negedge clk);#1ps;if(!wp_ready)$fatal(1,"W_PREP_BAD_EPOCH_NOT_READY");
    wp_valid=1;@(negedge clk);wp_valid=0;
    for(int guard=0;guard<16 && !wp_done_valid;guard++)@(negedge clk);
    if(!wp_done_valid || wp_done_status!=7 || wp_done_op!=8'h80 ||
       wp_done_check_status!=7 || wp_done_detail!=32'h0780_0005 ||
       wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
       r_count[0]!=24576 || r_count[1]!=24576 ||
       r_count[2]!=3072 || aux_count!=8)
      $fatal(1,"W_PREP_BAD_EPOCH_REJECT");
    repeat(3)begin
      @(negedge clk);
      if(!wp_done_valid || wp_done_status!=7 ||
         wp_done_check_status!=7 || wp_done_detail!=32'h0780_0005 ||
         wp_done_bad64!=64'hffff_ffff_ffff_ffff ||
         r_count[0]!=24576 || r_count[1]!=24576 ||
         r_count[2]!=3072 || aux_count!=8)
        $fatal(1,"W_PREP_BAD_EPOCH_HOLD");
    end
    wp_done_ready=1;@(negedge clk);wp_done_ready=0;
    if(wp_done_valid)$fatal(1,"W_PREP_BAD_EPOCH_NOT_CONSUMED");
    $display("REV21_CORE_WPREP_PASS status=%0d protocol=%0d numeric=%0d cycles=%0d",wp_done_status,load_protocol_error,load_numeric_error,cycle);
    $finish;
  end
endmodule
