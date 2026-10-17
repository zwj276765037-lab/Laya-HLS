`timescale 1ns/1ps
module laya_attention_final_tile_tb;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0;
  logic cmd_valid=0,cmd_ready,done_valid,done_ready=0;
  logic [31:0] cmd_id=501;
  logic [63:0] cmd_request=3,cmd_generation=1;
  logic [671:0] cmd_numeric_identity=0;
  logic [1759:0] cmd_binding_words=0;
  logic [1023:0] cmd_mask_bytes=0;
  logic [63:0] cmd_mask_request=3,cmd_mask_generation=1;
  logic [7:0] cmd_mask_length=128;
  logic [3:0] cmd_head=0;
  logic [6:0] cmd_row0=0;
  logic [31:0] cmd_service_epoch=501;
  logic [1:0][63:0] cmd_qkv_base='{default:64'h10000000};
  logic [1:0][63:0] cmd_qkv_span='{default:64'd12582912};
  logic [1:0][31:0] cmd_qkv_final_epoch='{default:32'd2};
  logic [63:0] cmd_att_base=64'h20000000,cmd_att_span=64'd8388608;
  logic [31:0] cmd_att_epoch=1;
  logic cmd_tensor_final_valid=0,cmd_tensor_failed=0;
  logic [127:0] cmd_row_final='1;
  logic cmd_source_debt_zero=1;
  logic [3:0] done_status,done_phase,done_head;
  logic [31:0] done_id,done_service_command,done_service_status,done_service_result;
  logic [6:0] done_row0;
  logic tile_success;
  logic read_load_valid,read_load_ready,read_load_done,read_load_error;
  logic [63:0] read_load_base;
  logic [31:0] read_load_bytes,read_load_epoch,read_committed_bytes;
  logic [511:0] read_out_data;
  logic [31:0] read_out_offset,read_out_epoch;
  logic [6:0] read_out_bytes;
  logic read_out_last,read_out_valid,read_out_ready,read_route;
  logic service_idle,service_done,service_result_valid,service_status_valid;
  logic [31:0] service_result,service_status;
  logic service_start,service_continue;
  logic [31:0] service_command,service_index,service_payload,service_epoch;
  logic writer_tile_valid,writer_tile_ready,writer_flush_req;
  logic [255:0] writer_tile_f32;
  logic [11:0] writer_tile_n0;
  logic [63:0] writer_output_base,writer_output_span;
  logic writer_flush_done,writer_debt_zero,writer_fault;
  logic writer_rearm_valid,writer_rearm_ready;
  logic [63:0] araddr,awaddr;
  logic [7:0] arlen,awlen;
  logic [2:0] arsize,awsize;
  logic [1:0] arburst,awburst;
  logic arvalid,arready,rvalid,rready,rlast;
  logic [511:0] rdata,wdata;
  logic [1:0] rresp,bresp;
  logic awvalid,awready,wvalid,wready,wlast,bvalid,bready;
  logic [63:0] wstrb;
  logic [31:0] aw_count,w_count,b_count;
  logic [63:0] useful_bytes,physical_bytes;
  logic [31:0] q[0:8191],k[0:8191],v[0:8191];
  logic [31:0] score[0:16383],prob[0:16383],out_gold[0:8191];
  logic [31:0] identity[0:20],mask[0:127];
  logic [31:0] words[0:54];
  logic [511:0] att_mem[0:519];
  string fixture;
  integer cycles=0,ar_count=0,r_count=0,score_count=0,prob_count=0;
  integer total_b=0;
  integer service_calls=0,load_count=0,done_count=0;
  integer qk_start=0,sm_start=0,av_start=0,write_start=0;
  integer last_progress=0;
  logic r_active=0;
  logic [63:0] r_addr=0;
  logic [7:0] r_remaining=0;
  logic aw_seen=0,w_seen=0;
  logic [63:0] held_aw=0;
  logic [511:0] held_w=0;
  logic [63:0] held_strb=0;
  logic [3:0] b_delay=0;
  integer final_b_delay_used=0;
  integer checked_tile=0,tile_count=1;
  integer error_mode=0,recovery_offset=0;
  integer baseline_r=0,baseline_ar=0,baseline_load=0,baseline_b=0;
  integer baseline_score=0,baseline_prob=0;
  logic inject_error=0;
  logic [63:0] source_base=64'h10000000;
  logic [1:0] r_gap=0;
  integer att_index;
  laya_attention_final_tile_adapter_v1 dut(.*);
  t4_w_reader_port_v1 #(.SCALE_MODE(0)) reader(
    .clk,.rst_n,.cancel(1'b0),.load_valid(read_load_valid),
    .load_ready(read_load_ready),.load_base(read_load_base),
    .load_bytes(read_load_bytes),.load_epoch(read_load_epoch),
    .load_done(read_load_done),.load_error(read_load_error),
    .committed_bytes(read_committed_bytes),.araddr,.arlen,.arsize,
    .arburst,.arvalid,.arready,.rdata,.rresp,.rlast,.rvalid,.rready,
    .out_data(read_out_data),.out_offset(read_out_offset),
    .out_epoch(read_out_epoch),.out_bytes(read_out_bytes),
    .out_last(read_out_last),.out_valid(read_out_valid),
    .out_ready(read_out_ready));
  tm1tn8_axi512_writer #(.SHARD(0)) writer(
    .clk,.rst_n,.tile_valid(writer_tile_valid),.tile_ready(writer_tile_ready),
    .tile_f32(writer_tile_f32),.tile_n0(writer_tile_n0),
    .tile_row_local(2'd0),.tile_row0(10'd0),.tile_batch(1'b0),
    .tile_lanes(4'd8),.mode_qkv(1'b0),
    .rearm_valid(writer_rearm_valid),.rearm_ready(writer_rearm_ready),
    .flush_req(writer_flush_req),.flush_done(writer_flush_done),
    .debt_zero(writer_debt_zero),.output_base(writer_output_base),
    .output_span(writer_output_span),.fault(writer_fault),
    .aw_count,.w_count,.b_count,.useful_bytes,.physical_bytes,
    .m_axi_awaddr(awaddr),.m_axi_awlen(awlen),.m_axi_awsize(awsize),
    .m_axi_awburst(awburst),.m_axi_awvalid(awvalid),.m_axi_awready(awready),
    .m_axi_wdata(wdata),.m_axi_wstrb(wstrb),.m_axi_wlast(wlast),
    .m_axi_wvalid(wvalid),.m_axi_wready(wready),
    .m_axi_bresp(bresp),.m_axi_bvalid(bvalid),.m_axi_bready(bready));
  attention_tile_service_v1 service(
    .ap_clk(clk),.ap_rst(!rst_n),.ap_ce(1'b1),
    .ap_start(service_start),.ap_continue(service_continue),
    .command(service_command),.index(service_index),
    .payload(service_payload),.epoch(service_epoch),
    .ap_done(service_done),.ap_idle(service_idle),.ap_ready(),
    .result(service_result),.status(service_status),
    .result_ap_vld(service_result_valid),.status_ap_vld(service_status_valid));
  function automatic [511:0] source_beat(input logic [63:0] addr);
    logic [511:0] bits;
    integer off,plane,head,s,d;
    begin
      bits='0;
      off=addr-source_base;
      plane=off/(1024*256)/16;
      head=(off/(1024*256))%16;
      s=(off/256)%1024;
      d=(off%256)/4;
      for(integer lane=0;lane<16;lane++)begin
        if(head==0&&s<128&&d+lane<64)begin
          case(plane)
            0:bits[lane*32 +: 32]=q[s*64+d+lane];
            1:bits[lane*32 +: 32]=k[s*64+d+lane];
            2:bits[lane*32 +: 32]=v[s*64+d+lane];
            default:bits[lane*32 +: 32]=32'hfeed0000;
          endcase
        end else bits[lane*32 +: 32]=32'hfeed0000;
      end
      return bits;
    end
  endfunction
  assign arready=!r_active && (error_mode!=3 || cycles[1]);
  assign rvalid=r_active && r_gap==0;
  assign rresp=(error_mode==1 && inject_error && r_count==0) ? 2'b10 : 0;
  assign rlast=r_active && r_remaining==1;
  assign rdata=source_beat(r_addr);
  assign awready=!aw_seen && cycles[0];
  assign wready=!w_seen && cycles[1];
  assign bvalid=aw_seen && w_seen && b_delay==0 &&
                !((total_b%64)==63 && final_b_delay_used==total_b/64);
  assign bresp=(error_mode==2 && inject_error && total_b==63) ? 2'b10 : 0;
  always @(posedge clk) if(rst_n)begin
    cycles=cycles+1;
    if(r_gap!=0)r_gap<=r_gap-1;
    if(read_load_valid&&read_load_ready)load_count=load_count+1;
    if(arvalid&&arready)begin
      if(read_route!=0||araddr<source_base||
         araddr>=source_base+64'd12582912||
         arsize!=6||arburst!=1||((araddr[11:0]+(arlen+1)*64)>4096))
        $fatal(1,"ATT_READER_AR_BAD addr=%h len=%0d",araddr,arlen);
      r_active<=1;r_addr<=araddr;r_remaining<=arlen+1;ar_count=ar_count+1;
    end
    if(rvalid&&rready)begin
      r_count=r_count+1;
      if(error_mode==3)r_gap<=2;
      if(r_remaining==1)r_active<=0;
      else begin r_addr<=r_addr+64;r_remaining<=r_remaining-1;end
    end
    if(service_start)begin
      if(!service_idle)$fatal(1,"ATT_SERVICE_NOT_IDLE");
      service_calls=service_calls+1;
      if(service_command==19)qk_start=cycles;
      if(service_command==20)sm_start=cycles;
      if(service_command==21)av_start=cycles;
    end
    for(integer bank=0;bank<16;bank++)begin
      if(service.sw[bank])begin
        integer pos;
        pos=(service.swa[bank]/64)*128+(service.swa[bank]%64)*16+bank;
        if(pos>=2048||service.swd[bank]!==score[checked_tile*2048+pos])
          $fatal(1,"ATT_SCORE_BAD tile=%0d pos=%0d actual=%h expected=%h",checked_tile,pos,service.swd[bank],score[checked_tile*2048+pos]);
        score_count=score_count+1;
      end
      if(service.pw[bank])begin
        integer pos;
        pos=(service.pwa[bank]/64)*128+(service.pwa[bank]%64)*16+bank;
        if(pos>=2048||service.pwd[bank]!==prob[checked_tile*2048+pos])
          $fatal(1,"ATT_PROB_BAD tile=%0d pos=%0d actual=%h expected=%h",checked_tile,pos,service.pwd[bank],prob[checked_tile*2048+pos]);
        prob_count=prob_count+1;
      end
    end
    if(awvalid&&awready)begin
      if(awlen!=0||awsize!=6||awburst!=1||awaddr<64'h20000000||
         awaddr>=64'h20000000+64'd8388608)
        $fatal(1,"ATT_AW_BAD %h",awaddr);
      aw_seen<=1;held_aw<=awaddr;
    end
    if(wvalid&&wready)begin
      if(!wlast||wstrb!=64'hffffffffffffffff)$fatal(1,"ATT_W_BAD");
      w_seen<=1;held_w<=wdata;held_strb<=wstrb;
    end
    if(aw_seen&&w_seen&&b_delay==0&&(total_b%64)==63&&
       final_b_delay_used==total_b/64)begin
      b_delay<=10;final_b_delay_used<=final_b_delay_used+1;
    end
    if(b_delay!=0)begin
      if(done_valid||tile_success)$fatal(1,"ATT_FINAL_B_EARLY_SUCCESS");
      b_delay<=b_delay-1;
    end
    if(bvalid&&bready)begin
      integer row,beat;
      row=(held_aw-64'h20000000)/4096;
      beat=((held_aw-64'h20000000)%4096)/64;
      if(row>=128||beat>=4||((held_aw-64'h20000000)%64)!=0)
        $fatal(1,"ATT_OUT_ADDRESS_BAD %h",held_aw);
      att_mem[row*4+beat]<=held_w;
      total_b=total_b+1;
      for(integer lane=0;lane<16;lane++)
        if(held_w[lane*32 +: 32]!==out_gold[row*64+beat*16+lane])
          $fatal(1,"ATT_OUT_BAD row=%0d d=%0d actual=%h expected=%h",row,beat*16+lane,held_w[lane*32 +: 32],out_gold[row*64+beat*16+lane]);
      aw_seen<=0;w_seen<=0;
    end
    if(done_valid)done_count=done_count+1;
    if(cycles%100000==0)begin
      $display("ATT_CONSUMER_PROGRESS cycles=%0d loads=%0d AR=%0d R=%0d svc=%0d score=%0d prob=%0d B=%0d state=%0d",cycles,load_count,ar_count,r_count,service_calls,score_count,prob_count,total_b,dut.state);
      if(cycles>40000000)$fatal(1,"ATT_CYCLE_CAP");
    end
  end
  initial begin
    if(!$value$plusargs("fixture=%s",fixture))$fatal(1,"fixture path required");
    void'($value$plusargs("tiles=%d",tile_count));
    void'($value$plusargs("error_mode=%d",error_mode));
    if(tile_count!=1 && tile_count!=8)$fatal(1,"ATT_TILE_COUNT_BAD");
    if(error_mode<0 || error_mode>3 || (error_mode!=0 && tile_count!=1))
      $fatal(1,"ATT_ERROR_MODE_BAD");
    if(error_mode==3)source_base=64'h10000fc0;
    $display("ATT_SIM_START");
    $readmemh({fixture,"/q.mem"},q);$readmemh({fixture,"/k.mem"},k);
    $readmemh({fixture,"/v.mem"},v);$readmemh({fixture,"/score.mem"},score);
    $readmemh({fixture,"/prob.mem"},prob);$readmemh({fixture,"/out.mem"},out_gold);
    $readmemh({fixture,"/identity_words.mem"},identity);
    $readmemh({fixture,"/mask.mem"},mask);
    for(integer n=0;n<21;n++)begin
      cmd_numeric_identity[n*32 +: 32]=identity[n];words[n]=identity[n];
    end
    for(integer n=21;n<55;n++)words[n]=0;
    for(integer n=0;n<3;n++)begin
      words[21+n*4]=501+n;
      words[22+n*4]=32'h250+n;
      words[23+n*4]=32'h00100000;
    end
    for(integer n=0;n<7;n++)begin
      case(n)
        0:words[33+n*3]=32'h25;
        1,2:words[33+n*3]=32'h26;
        3:words[33+n*3]=32'h28;
        4:words[33+n*3]=8;
        5:words[33+n*3]=5;
        6:words[33+n*3]=32'h105;
      endcase
      words[34+n*3]=n==1?1:2;
      words[35+n*3]=0;
    end
    words[54]=0;
    for(integer n=0;n<55;n++)cmd_binding_words[n*32 +: 32]=words[n];
    for(integer n=0;n<128;n++)cmd_mask_bytes[n*8 +: 8]=mask[n][7:0];
    for(integer n=0;n<520;n++)att_mem[n]='1;
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"ATT_INVALID_NOT_READY");
    @(negedge clk);cmd_valid=0;
    @(negedge clk);
    #1ps;if(!done_valid||done_status!=7||ar_count||service_calls)
      $fatal(1,"ATT_INVALID_ISSUED");
    done_ready=1;@(negedge clk);done_ready=0;
    cmd_tensor_final_valid=1;
    if(error_mode==1 || error_mode==2)begin
      @(negedge clk);inject_error=1;cmd_valid=1;
      #1ps;if(!cmd_ready)$fatal(1,"ATT_ERROR_CMD_NOT_READY");
      @(negedge clk);cmd_valid=0;
      for(integer wait_cycles=0;wait_cycles<300000&&!done_valid;wait_cycles++)@(negedge clk);
      if(!done_valid||done_status!=7||done_phase!=15||tile_success||
         done_id!=501||total_b!=(error_mode==2?64:0))
        $fatal(1,"ATT_EXPECTED_ERROR_BAD mode=%0d status=%0d B=%0d state=%0d",error_mode,done_status,total_b,dut.state);
      repeat(3)begin @(negedge clk);if(!done_valid||done_status!=7)$fatal(1,"ATT_ERROR_DONE_HOLD");end
      done_ready=1;@(negedge clk);done_ready=0;inject_error=0;
      baseline_r=r_count;baseline_ar=ar_count;baseline_load=load_count;
      baseline_b=total_b;baseline_score=score_count;baseline_prob=prob_count;
      recovery_offset=1;
      $display("ATT_ERROR_DRAIN_PASS mode=%0d R=%0d AR=%0d loads=%0d B=%0d svc=%0d",error_mode,r_count,ar_count,load_count,total_b,service_calls);
    end
    for(integer tile=0;tile<tile_count;tile++)begin
      @(negedge clk);
      checked_tile=tile;
      cmd_id=501+recovery_offset+tile;
      cmd_service_epoch=501+recovery_offset+tile;cmd_row0=tile*16;
      cmd_head=0;cmd_qkv_base='{default:source_base};
      cmd_att_base=64'h20000000;
      for(integer n=0;n<55;n++)cmd_binding_words[n*32 +: 32]=words[n];
      for(integer n=0;n<128;n++)cmd_mask_bytes[n*8 +: 8]=mask[n][7:0];
      cmd_binding_words[23*32 +: 32]=32'h00100000+tile*16;
      cmd_binding_words[27*32 +: 32]=32'h00100000+tile*16;
      cmd_binding_words[31*32 +: 32]=32'h00100000+tile*16;
      cmd_valid=1;
      #1ps;if(!cmd_ready)$fatal(1,"ATT_VALID_NOT_READY tile=%0d",tile);
      @(negedge clk);cmd_valid=0;
      cmd_head=7;cmd_row0=112;cmd_qkv_base='0;cmd_att_base=0;
      cmd_binding_words='0;cmd_mask_bytes='0;
      for(integer wait_cycles=0;wait_cycles<500000&&!done_valid;wait_cycles++)@(negedge clk);
      if(!done_valid||done_status!=0||done_phase!=15||!tile_success||
         done_id!=501+recovery_offset+tile||done_head!=0||done_row0!=tile*16||
         r_count!=baseline_r+1088*(tile+1)||
         ar_count!=baseline_ar+(error_mode==3?1026:1025)*(tile+1)||
         load_count!=baseline_load+1025*(tile+1)||
         total_b!=baseline_b+64*(tile+1)||
         score_count!=baseline_score+2048*(tile+1)||
         prob_count!=baseline_prob+2048*(tile+1))
        $fatal(1,"ATT_FINAL_BAD tile=%0d status=%0d phase=%0d R=%0d B=%0d score=%0d prob=%0d state=%0d",tile,done_status,done_phase,r_count,total_b,score_count,prob_count,dut.state);
      repeat(3)begin @(negedge clk);if(!done_valid||done_status!=0)$fatal(1,"ATT_DONE_HOLD");end
      done_ready=1;@(negedge clk);done_ready=0;
      $display("ATT_TILE_PASS tile=%0d R=%0d AR=%0d loads=%0d B=%0d svc=%0d score=%0d prob=%0d qk_at=%0d sm_at=%0d av_at=%0d",tile,r_count,ar_count,load_count,total_b,service_calls,score_count,prob_count,qk_start,sm_start,av_start);
    end
    for(integer row=0;row<tile_count*16;row++)
      for(integer beat=0;beat<4;beat++)
        for(integer lane=0;lane<16;lane++)
          if(att_mem[row*4+beat][lane*32 +: 32]!==out_gold[row*64+beat*16+lane])
            $fatal(1,"ATT_OUT_RESCAN_BAD row=%0d d=%0d",row,beat*16+lane);
    for(integer n=tile_count*64;n<520;n++)
      if(att_mem[n]!=='1)$fatal(1,"ATT_OUT_SENTINEL_BAD word=%0d",n);
    $display("ATT_FINAL_TILE_PASS tiles=%0d R=%0d AR=%0d loads=%0d B=%0d svc=%0d score=%0d prob=%0d",tile_count,r_count,ar_count,load_count,total_b,service_calls,score_count,prob_count);
    $finish;
  end
endmodule
