`timescale 1ns/1ps
module laya_qkv_scratch_reset_tb;
  logic clk, rst_n;
  logic cmd_valid;
  logic cmd_ready;
  logic [31:0] cmd_id;
  logic cmd_cold;
  logic cmd_mode;
  logic [6:0] cmd_row;
  logic [31:0] cmd_w_epoch;
  logic [15:0] cmd_weight_key;
  logic [3327:0] cmd_model_identity;
  logic [671:0] cmd_numeric_identity;
  logic [95:0] cmd_task_context;
  logic [1023:0] cmd_expected_aux_header;
  logic [2:0][63:0] cmd_load_base;
  logic [2:0][31:0] cmd_load_bytes;
  logic [63:0] cmd_aux_base;
  logic [63:0] cmd_bias_base;
  logic [31:0] cmd_bias_bytes;
  logic [31:0] cmd_down_w_epoch;
  logic [15:0] cmd_down_weight_key;
  logic [1023:0] cmd_down_expected_aux_header;
  logic [2:0][63:0] cmd_down_load_base;
  logic [2:0][31:0] cmd_down_load_bytes;
  logic [63:0] cmd_down_aux_base;
  logic [63:0] cmd_down_bias_base;
  logic [31:0] cmd_down_bias_bytes;
  logic x_valid;
  logic x_ready;
  logic [31:0] x_bits;
  logic gamma_valid;
  logic gamma_ready;
  logic [31:0] gamma_bits;
  logic row_valid;
  logic rd_valid;
  logic rd_ready;
  logic [9:0] rd_tile;
  logic rsp_valid;
  logic rsp_ready;
  logic [9:0] rsp_tile;
  logic [255:0] rsp_bits;
  logic row_release_valid;
  logic row_release_ready;
  logic done_valid;
  logic done_ready;
  logic [3:0] done_status;
  logic [3:0] done_phase;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] done_bad_element;
  logic [31:0] mean_bits, variance_bits, inverse_bits;
  logic [31:0] actual_w_reads, actual_w_returns;
  logic [31:0] actual_stripes, actual_ps_commits;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst;
  logic [2:0] arvalid;
  logic [2:0] arready;
  logic [2:0][511:0] rdata;
  logic [2:0][1:0] rresp;
  logic [2:0] rlast, rvalid;
  logic [2:0] rready;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst;
  logic aux_arvalid;
  logic aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast, aux_rvalid;
  logic aux_rready;
  logic cmd_tensor_begin;
  logic [31:0] cmd_tensor_epoch;
  logic [2:0][31:0] cmd_dst_epoch;
  logic [2:0][63:0] cmd_dst_base, cmd_dst_span;
  logic cmd_source_hidden_bank;
  logic [31:0] done_id;
  logic tensor_release_valid;
  logic tensor_release_ready;
  logic tensor_release_discard;
  logic [31:0] tensor_release_epoch;
  logic [63:0] tensor_release_request, tensor_release_generation;
  logic tensor_raw_valid;
  logic [127:0] row_written;
  logic tensor_failed;
  logic [31:0] tensor_epoch;
  logic [63:0] tensor_request, tensor_generation;
  logic [3327:0] tensor_model_identity;
  logic [671:0] tensor_numeric_identity;
  logic [2:0][31:0] tensor_dst_epoch;
  logic [2:0][63:0] tensor_dst_base, tensor_dst_span;
  logic [2:0][63:0] m_axi_awaddr;
  logic [2:0][7:0] m_axi_awlen;
  logic [2:0][2:0] m_axi_awsize;
  logic [2:0][1:0] m_axi_awburst;
  logic [2:0] m_axi_awvalid;
  logic [2:0] m_axi_awready;
  logic [2:0][511:0] m_axi_wdata;
  logic [2:0][63:0] m_axi_wstrb;
  logic [2:0] m_axi_wlast, m_axi_wvalid;
  logic [2:0] m_axi_wready;
  logic [2:0][1:0] m_axi_bresp;
  logic [2:0] m_axi_bvalid;
  logic [2:0] m_axi_bready;
  logic [2:0][31:0] scratch_aw_count, scratch_w_count;
  logic [2:0][31:0] scratch_b_count;
  logic [9:0] scratch_rsp_count;
  logic [5:0] scratch_flush_count;
  logic [1:0] scratch_error_dst;
  logic [31:0] scratch_error_ordinal;
  logic [1:0] scratch_error_bresp;
  laya_qkv_scratch_row_v1 dut (
    .*, .cmd_stage_discard_norm(1'b0), .stage_store_fault(),
    .cmd_staged_ln(1'b0), .norm_written(), .norm_stage_ready(),
    .done_op(), .done_check_status(), .done_detail(), .done_bad64(), .cmd_input_from_state0(1'b0), .cmd_state0_base('0),
    .cmd_state0_span('0), .cmd_state0_epoch('0),
    .state0_araddr(), .state0_arlen(), .state0_arsize(),
    .state0_arburst(), .state0_arvalid(), .state0_arready(1'b0),
    .state0_rdata('0), .state0_rresp('0), .state0_rlast(1'b0),
    .state0_rvalid(1'b0), .state0_rready(),, .cmd_rope_enable(1'b0), .cmd_rope_aux_base(64'd0),
    .cmd_rope_aux_span(64'd0), .rope_arready('0),
    .rope_rdata('0), .rope_rresp('0), .rope_rlast('0),
    .rope_rvalid('0), .rope_araddr(), .rope_arlen(),
    .rope_arsize(), .rope_arburst(), .rope_arvalid(),
    .rope_rready(), .tensor_rope_enable(), .row_final(),
    .tensor_final_valid(), .tensor_final_dst_epoch(),
    .done_rope_check_valid(), .done_rope_check(),
    .done_rope_head(), .done_rope_plane()
  );
  initial clk=0;
  always #5 clk=~clk;
  int cycle_count=0, b_total=0, aw_total=0, w_total=0;
  int tb_phase=0;
  int tensor_b_base=0;
  bit inject_b_error=1;
  int aw_stalls[0:2], w_stalls[0:2];
  bit saw_aw_first=0, saw_w_first=0, saw_last_b_hold=0;
  logic [2:0] aw_seen, w_seen;
  logic [2:0][63:0] aw_saved;
  logic [2:0][511:0] w_saved;
  logic [2:0][63:0] strb_saved;
  int b_wait[0:2];
  function automatic logic [31:0] expected_word(input int row, tile, lane);
    expected_word={7'(row),7'd0,10'(tile),5'(lane)};
  endfunction
  always_comb begin
    for(int p=0;p<3;p++) begin
      m_axi_awready[p]=rst_n && !aw_seen[p] && !m_axi_bvalid[p] &&
                       aw_stalls[p]!=0 && (cycle_count%7 != p) &&
                       !(p==1 && scratch_aw_count[p]==0 && !w_seen[p]);
      m_axi_wready[p]=rst_n && !w_seen[p] && !m_axi_bvalid[p] &&
                      w_stalls[p]!=0 && (cycle_count%9 != (p+2)) &&
                      !(p==0 && scratch_w_count[p]==0 && !aw_seen[p]);
    end
  end
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      cycle_count<=0; b_total<=0; aw_total<=0; w_total<=0;
      aw_seen<='0; w_seen<='0; aw_saved<='0;
      w_saved<='0;strb_saved<='0;
      m_axi_bvalid<='0;m_axi_bresp<='0;
      for(int p=0;p<3;p++)begin
        b_wait[p]<=0;aw_stalls[p]<=0;w_stalls[p]<=0;
      end
      saw_aw_first<=0;saw_w_first<=0;saw_last_b_hold<=0;
    end else begin
      cycle_count<=cycle_count+1;
      if(cycle_count>1000000)$fatal(1,"scratch local peer timeout phase=%0d b=%0d state=%0d active=%0d failed=%0d raw=%0d epoch=%0d rel=%0d/%0d core_state=%0d",tb_phase,b_total,dut.state,dut.tensor_active,tensor_failed,tensor_raw_valid,tensor_epoch,tensor_release_valid,tensor_release_ready,dut.core.state);
      for(int p=0;p<3;p++)begin
        if(m_axi_awvalid[p]&&!m_axi_awready[p])aw_stalls[p]<=aw_stalls[p]+1;
        if(m_axi_wvalid[p]&&!m_axi_wready[p])w_stalls[p]<=w_stalls[p]+1;
        if(m_axi_awvalid[p]&&m_axi_awready[p])begin
          if(m_axi_awlen[p]!=0 || m_axi_awsize[p]!=3'd6 ||
             m_axi_awburst[p]!=2'b01)$fatal(1,"AW shape");
          aw_seen[p]<=1;aw_saved[p]<=m_axi_awaddr[p];aw_total<=aw_total+1;
        end
        if(m_axi_wvalid[p]&&m_axi_wready[p])begin
          if(m_axi_wstrb[p]!='1 || !m_axi_wlast[p])$fatal(1,"W shape");
          w_seen[p]<=1;w_saved[p]<=m_axi_wdata[p];
          strb_saved[p]<=m_axi_wstrb[p];w_total<=w_total+1;
        end
        if(aw_seen[p]&&!w_seen[p])saw_aw_first<=1;
        if(w_seen[p]&&!aw_seen[p])saw_w_first<=1;
        if(aw_seen[p]&&w_seen[p]&&!m_axi_bvalid[p])begin
          if(b_wait[p] < (inject_b_error && b_total==511 ? 12 : 2))begin
            b_wait[p]<=b_wait[p]+1;
            if(inject_b_error && b_total==511)begin
              saw_last_b_hold<=1;
              if(dut.core_release_valid || row_written[1] || done_valid)
                $fatal(1,"row published while final B held");
            end
          end else begin
            m_axi_bvalid[p]<=1;
            m_axi_bresp[p]<=inject_b_error && b_total==511 ? 2'b10 : 2'b00;
          end
        end
        if(m_axi_bvalid[p]&&m_axi_bready[p])begin : check_tx
          int row_no, row_tx, seg, beat, plane, head, dest;
          logic [63:0] expected_addr;
          row_no=(b_total-tensor_b_base)/256;
          row_tx=(b_total-tensor_b_base)%256;
          if(row_tx<192)begin
            seg=row_tx/4;beat=row_tx%4;
            plane=seg/16;head=seg%16;dest=head%2;
            expected_addr=64'h10000000+
                (((((plane*2)*8+head/2)*1024+row_no)*64)*4)+beat*64;
          end else begin
            seg=48;beat=row_tx-192;dest=2;
            expected_addr=64'h10000000+row_no*4096+beat*64;
          end
          if(p!=dest || aw_saved[p]!==expected_addr || strb_saved[p]!=='1)
            $fatal(1,"scatter address/route/strb txn=%0d port=%0d addr=%h expected=%h",b_total,p,aw_saved[p],expected_addr);
          for(int word=0;word<16;word++)begin
            int tile,lane;
            tile=seg==48 ? 384+beat*2+word/8 : seg*8+beat*2+word/8;
            lane=word%8;
            if(w_saved[p][word*32+:32]!==expected_word(row_no,tile,lane))
              $fatal(1,"scatter data txn=%0d word=%0d actual=%h expected=%h",b_total,word,w_saved[p][word*32+:32],expected_word(row_no,tile,lane));
          end
          if(m_axi_bresp[p] !=
             (inject_b_error && b_total==511 ? 2'b10 : 2'b00))
            $fatal(1,"BRESP injection identity");
          b_total<=b_total+1;
          aw_seen[p]<=0;w_seen[p]<=0;
          m_axi_bvalid[p]<=0;m_axi_bresp[p]<=0;b_wait[p]<=0;
        end
      end
    end
  end

  task automatic send_command(input bit qkv,input int row_no,input int id_no,
                              input bit begin_tensor);
    begin
      @(negedge clk);
      cmd_mode=qkv;cmd_row=7'(row_no);cmd_id=32'(id_no);
      cmd_tensor_begin=begin_tensor;
      cmd_task_context={8'd1,16'(row_no),8'd128,8'd1,8'd0,8'd0,8'd1,32'(id_no)};
      cmd_valid=1;
      while(!cmd_ready)@(negedge clk);
      @(negedge clk);cmd_valid=0;
    end
  endtask
  task automatic take_done(input logic [3:0] status,phase);
    logic [31:0] held_id;
    logic held_mode;logic [6:0] held_row;
    begin
      while(!done_valid)@(negedge clk);
      if(done_status!==status || done_phase!==phase ||
         done_bad_element!==32'hffffffff)
        $fatal(1,"done status=%0d phase=%0d bad=%h expected=%0d/%0d",done_status,done_phase,done_bad_element,status,phase);
      held_id=done_id;held_mode=result_mode;held_row=result_row;
      repeat(3)begin
        @(negedge clk);
        if(!done_valid || done_id!==held_id || result_mode!==held_mode ||
           result_row!==held_row || done_status!==status || done_phase!==phase)
          $fatal(1,"outer done not stable");
      end
      done_ready=1;
      @(negedge clk);done_ready=0;
    end
  endtask

  task automatic release_partial(input logic [31:0] epoch);
    begin
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=epoch;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
    end
  endtask
  task automatic reset_at(input int target);
    bit hit;
    begin
      hit=0;
      for(int guard=0;guard<20000&&!hit;guard++)begin
        @(negedge clk);
        case(target)
          0:hit=dut.read_pending && !dut.core_rsp_valid;
          1:hit=aw_seen[0] && !w_seen[0];
          2:hit=w_seen[1] && !aw_seen[1];
          3:hit=aw_seen[0] && w_seen[0] && !m_axi_bvalid[0];
        endcase
      end
      if(!hit)$fatal(1,"reset target not reached target=%0d B=%0d",target,b_total);
      $display("SCRATCH_RESET_TRIGGER target=%0d global=%0d AW=%0d W=%0d B=%0d read_debt=%0d",
        target,cycle_count,aw_total,w_total,b_total,dut.read_pending);
      rst_n=0;
      repeat(5)@(negedge clk);
      rst_n=1;
      tensor_b_base=0;
      for(int quiet=0;quiet<510;quiet++)begin
        @(negedge clk);
        if(row_valid || rsp_valid || done_valid || tensor_raw_valid ||
           |m_axi_awvalid || |m_axi_wvalid || |m_axi_bready ||
           row_written || tensor_failed || dut.read_pending ||
           !dut.writer_debt_zero)
          $fatal(1,"reset ghost target=%0d quiet=%0d",target,quiet);
      end
      if(!cmd_ready)$fatal(1,"reset did not restore command admission target=%0d",target);
    end
  endtask
  initial begin
    rst_n=0;cmd_valid=0;done_ready=0;rd_valid=0;rsp_ready=0;
    row_release_valid=0;cmd_mode=0;cmd_row=0;cmd_id=0;
    cmd_tensor_begin=0;cmd_tensor_epoch=1;
    cmd_dst_epoch='{default:32'd1};
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=64'd12582912;cmd_dst_span[1]=64'd12582912;
    cmd_dst_span[2]=64'd8388608;
    cmd_source_hidden_bank=0;inject_b_error=0;
    cmd_numeric_identity={512'd0,16'd128,16'd1,64'd1,64'd3};
    cmd_model_identity='h1234;
    tensor_release_valid=0;tensor_release_discard=0;
    tensor_release_epoch=0;tensor_release_request=0;
    tensor_release_generation=0;
    repeat(5)@(negedge clk);rst_n=1;
    for(int target=0;target<4;target++)begin
      tb_phase=target+1;
      cmd_tensor_epoch=target==0 ? 32'd1 : 32'd2;
      cmd_dst_epoch='{default:cmd_tensor_epoch};
      tensor_b_base=b_total;
      send_command(1,0,10+target,1);
      reset_at(target);
      cmd_tensor_epoch=1;cmd_dst_epoch='{default:32'd1};
      send_command(1,0,30+target,1);
      take_done(0,7);
      if(b_total!=256 || row_written!==(128'b1) || tensor_failed ||
         tensor_raw_valid || scratch_rsp_count!=512 ||
         scratch_flush_count!=49)
        $fatal(1,"reset recovery row bad target=%0d B=%0d",target,b_total);
      release_partial(1);
      if(tensor_epoch || row_written || tensor_failed || tensor_raw_valid)
        $fatal(1,"reset recovery release bad target=%0d",target);
    end
    $display("SCRATCH_RESET_LOCAL_PASS targets=read_pending,AW_first,W_first,AW_W_wait_B isolation=510 recovery_rows=4");
    $finish;
  end
endmodule
