`timescale 1ns/1ps
module laya_qkv_rope_real_chain_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1,cmd_mode=1;
  logic [6:0] cmd_row=0;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] cmd_id=0,cmd_w_epoch=1,cmd_down_w_epoch=0;
  logic [15:0] cmd_weight_key=16'h0001,cmd_down_weight_key=0;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0,cmd_down_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0,cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic x_valid,x_ready,gamma_valid,gamma_ready;
  logic [31:0] x_bits,gamma_bits;
  logic row_valid,rd_valid=0,rd_ready,rsp_valid,rsp_ready=0;
  logic [9:0] rd_tile=0,rsp_tile;
  logic [255:0] rsp_bits;
  logic row_release_valid=0,row_release_ready,done_valid,done_ready=0;
  logic [3:0] done_status,done_phase;
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
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst;
  logic aux_arvalid,aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast,aux_rvalid,aux_rready;
  logic cmd_tensor_begin=0;
  logic [31:0] cmd_tensor_epoch=1,done_id;
  logic [2:0][31:0] cmd_dst_epoch;
  logic [2:0][63:0] cmd_dst_base,cmd_dst_span;
  logic cmd_source_hidden_bank=0;
  logic tensor_release_valid=0,tensor_release_ready,tensor_release_discard=0;
  logic [31:0] tensor_release_epoch=0,tensor_epoch;
  logic [63:0] tensor_release_request=0,tensor_release_generation=0;
  logic tensor_raw_valid,tensor_failed;
  logic [127:0] row_written;
  logic [63:0] tensor_request,tensor_generation;
  logic [3327:0] tensor_model_identity;
  logic [671:0] tensor_numeric_identity;
  logic [2:0][31:0] tensor_dst_epoch;
  logic [2:0][63:0] tensor_dst_base,tensor_dst_span;
  logic [2:0][63:0] m_axi_awaddr;
  logic [2:0][7:0] m_axi_awlen;
  logic [2:0][2:0] m_axi_awsize;
  logic [2:0][1:0] m_axi_awburst;
  logic [2:0] m_axi_awvalid,m_axi_awready;
  logic [2:0][511:0] m_axi_wdata;
  logic [2:0][63:0] m_axi_wstrb;
  logic [2:0] m_axi_wlast,m_axi_wvalid,m_axi_wready;
  logic [2:0][1:0] m_axi_bresp;
  logic [2:0] m_axi_bvalid,m_axi_bready;
  logic [2:0][31:0] scratch_aw_count,scratch_w_count,scratch_b_count;
  logic [9:0] scratch_rsp_count;
  logic [5:0] scratch_flush_count;
  logic [1:0] scratch_error_dst,scratch_error_bresp;
  logic [31:0] scratch_error_ordinal;
  logic cmd_rope_enable=1;
  logic [63:0] cmd_rope_aux_base=0,cmd_rope_aux_span=64'd1142528;
  logic tensor_rope_enable,tensor_final_valid;
  logic [127:0] row_final;
  logic [2:0][31:0] tensor_final_dst_epoch;
  logic done_rope_check_valid,done_rope_plane;
  logic [127:0] done_rope_check;
  logic [3:0] done_rope_head;
  logic [1:0][63:0] rope_araddr;
  logic [1:0][7:0] rope_arlen;
  logic [1:0][2:0] rope_arsize;
  logic [1:0][1:0] rope_arburst;
  logic [1:0] rope_arvalid,rope_arready,rope_rlast,rope_rvalid,rope_rready;
  logic [1:0][511:0] rope_rdata;
  logic [1:0][1:0] rope_rresp;
  laya_qkv_scratch_row_v1 dut (
    .*, .cmd_input_from_state0(1'b0), .cmd_state0_base('0),
    .cmd_state0_span('0), .cmd_state0_epoch('0),
    .state0_araddr(), .state0_arlen(), .state0_arsize(),
    .state0_arburst(), .state0_arvalid(), .state0_arready(1'b0),
    .state0_rdata('0), .state0_rresp('0), .state0_rlast(1'b0),
    .state0_rvalid(1'b0), .state0_rready(),
  );

  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [511:0] w_q0[0:24575],w_q1[0:24575],w_scale[0:3071];
  logic [31:0] raw[0:2047],norm_gold[0:2047],gamma[0:1023];
  logic [255:0] q_gold[0:63],ps_gold[0:24575];
  logic [255:0] step0_gold[0:24575],step1_gold[0:24575],
                step2_gold[0:24575],step3_gold[0:24575],step4_gold[0:24575];
  logic [15:0] scale_gold[0:63];
  logic [31:0] final_gold[0:6143];
  logic [31:0] rope_final_gold[0:6143];
  logic [127:0] cos_words[0:31],sin_words[0:31];
  logic [511:0] scratch_qkv_mem[0:2][0:1][0:15][0:3];
  logic [511:0] scratch_norm_mem[0:1][0:63];
  bit scratch_qkv_valid[0:2][0:1][0:15][0:3];
  logic [63:0] wi_cfg[0:12],down_cfg[0:12];
  logic [3327:0] ffn_model_rom[0:0];
  logic [1023:0] ffn_header_rom[0:0];
  logic [127:0] ffn_header_words[0:7];
  logic [511:0] wi_q0[0:41983],wi_q1[0:41983],wi_scale[0:5247];
  logic [511:0] down_q0[0:20991],down_q1[0:20991],down_scale[0:2623];
  logic [31:0] ffn_source[0:1023],ffn_ln[0:1023],wi_final[0:5247];
  logic [31:0] g_gold[0:2623],down_final[0:1023],residual_gold[0:1023];
  logic [255:0] wi_q_gold[0:31],wi_ps_gold[0:20991];
  logic [255:0] down_q_gold[0:81],down_ps_gold[0:10495];
  logic [15:0] wi_scale_gold[0:31],down_scale_gold[0:81];
  string fixture,ffn_fixture;
  bit ffn_active=0,cross_recovery_only=0;
  int ffn_ln_count=0,wi_q_count=0,wi_ps_count=0,down_q_count=0;
  int down_ps_count=0,g_count=0,add_count=0,ffn_w_base=0,ffn_ar_base[0:2];
  int load_good=0;
  bit drive_source=0,aux_active=0,active[0:2],held_ar[0:2],held_aux=0;
  bit x_hold=0,gamma_hold=0,r_hold[0:2],aux_r_hold=0;
  logic [63:0] held_addr[0:2],held_aux_addr;
  logic [7:0] held_len[0:2],held_aux_len;
  logic [2:0] held_size[0:2],held_aux_size;
  logic [1:0] held_burst[0:2],held_aux_burst;
  int global_cycle=0,source_idx=0,gamma_idx=0,norm_idx=0,q_idx=0,ps_idx=0;
  int pcmd=0,par=0,pr=0,paar=0,parr=0,psrc=0,pln=0,pw=0;
  int pissue=0,pcommit=0,pbranch=0,prsp=0;
  int fp_a_count=0,fp_product_count=0,fp_term_count=0;
  int issued[0:1][0:2],read_index[0:2],left[0:2],ar_count[0:2],r_count[0:2];
  bit rslot[0:2];
  int ar_blocks[0:2],aux_blocks=0,aux_idx=0,aux_left=0,aux_ar_count=0,aux_r_count=0;
  int r_gaps[0:2],aux_gaps=0,x_gaps=0,gamma_gaps=0;
  int current_row=0;
  wire [2:0][31:0] active_bytes=dut.core.active_slot ? cmd_down_load_bytes : cmd_load_bytes;
  wire [2:0][63:0] active_base=dut.core.active_slot ? cmd_down_load_base : cmd_load_base;
  int scratch_aw_total=0,scratch_w_total=0,scratch_b_total=0;
  int raw_b_total=0,rope_b_total=0;
  int rope_ar_total=0,rope_r_total=0,rope_aux_ar_total=0,rope_aux_r_total=0;
  int rope_aux_ar_stalls=0;
  int header_aux_ar_stalls=0;
  bit rope_bus_active[0:1];
  bit rope_bus_r_hold[0:1];
  int rope_bus_left[0:1],rope_bus_plane[0:1],rope_bus_row[0:1];
  int rope_bus_head[0:1],rope_bus_beat[0:1];
  int rope_bus_ar_stalls[0:1],rope_bus_r_gaps[0:1];
  bit rope_table_bus=0,rope_table_is_sin=0;
  int scratch_aw_stalls[0:2],scratch_w_stalls[0:2];
  bit scratch_aw_first=0,scratch_w_first=0,scratch_last_b_hold=0;
  logic [2:0] scratch_aw_seen,scratch_w_seen;
  logic [2:0][63:0] scratch_aw_saved,scratch_strb_saved;
  logic [2:0][511:0] scratch_w_saved;
  int scratch_b_wait[0:2];
  always_comb begin
    for(int p=0;p<3;p++)begin
      m_axi_awready[p]=rst_n && !scratch_aw_seen[p] && !m_axi_bvalid[p] &&
          scratch_aw_stalls[p]!=0 && (global_cycle%7!=p) &&
          !(p==1 && scratch_aw_count[p]==0 && !scratch_w_seen[p]);
      m_axi_wready[p]=rst_n && !scratch_w_seen[p] && !m_axi_bvalid[p] &&
          scratch_w_stalls[p]!=0 && (global_cycle%9!=(p+2)) &&
          !(p==0 && scratch_w_count[p]==0 && !scratch_aw_seen[p]);
    end
  end
  always @(posedge clk) begin
    if(!rst_n)begin
      scratch_aw_total<=0;scratch_w_total<=0;scratch_b_total<=0;
      raw_b_total<=0;rope_b_total<=0;
      scratch_aw_seen<='0;scratch_w_seen<='0;
      scratch_aw_saved<='0;scratch_strb_saved<='0;scratch_w_saved<='0;
      m_axi_bvalid<='0;m_axi_bresp<='0;
      scratch_aw_first<=0;scratch_w_first<=0;scratch_last_b_hold<=0;
      for(int p=0;p<3;p++)begin
        scratch_aw_stalls[p]<=0;scratch_w_stalls[p]<=0;
        scratch_b_wait[p]<=0;
      end
    end else begin
      for(int p=0;p<3;p++)begin
        if(m_axi_awvalid[p]&&!m_axi_awready[p])
          scratch_aw_stalls[p]<=scratch_aw_stalls[p]+1;
        if(m_axi_wvalid[p]&&!m_axi_wready[p])
          scratch_w_stalls[p]<=scratch_w_stalls[p]+1;
        if(m_axi_awvalid[p]&&m_axi_awready[p])begin
          if(m_axi_awlen[p]!=0 || m_axi_awsize[p]!=3'd6 ||
             m_axi_awburst[p]!=2'b01)$fatal(1,"SCRATCH_AW_SHAPE");
          scratch_aw_seen[p]<=1;scratch_aw_saved[p]<=m_axi_awaddr[p];
          scratch_aw_total<=scratch_aw_total+1;
        end
        if(m_axi_wvalid[p]&&m_axi_wready[p])begin
          if(m_axi_wstrb[p]!='1 || !m_axi_wlast[p])
            $fatal(1,"SCRATCH_W_SHAPE");
          scratch_w_seen[p]<=1;scratch_w_saved[p]<=m_axi_wdata[p];
          scratch_strb_saved[p]<=m_axi_wstrb[p];
          scratch_w_total<=scratch_w_total+1;
        end
        if(scratch_aw_seen[p]&&!scratch_w_seen[p])scratch_aw_first<=1;
        if(scratch_w_seen[p]&&!scratch_aw_seen[p])scratch_w_first<=1;
        if(scratch_aw_seen[p]&&scratch_w_seen[p]&&!m_axi_bvalid[p])begin
          if(scratch_b_wait[p]<(dut.rope_aux_owner &&
                               rope_b_total==255 ? 12 : 2))begin
            scratch_b_wait[p]<=scratch_b_wait[p]+1;
            if(dut.rope_aux_owner && rope_b_total==255)begin
              scratch_last_b_hold<=1;
              if(row_final[1] || done_valid || tensor_final_valid)
                $fatal(1,"ROPE_LAST_B_EARLY_FINAL");
            end
          end else begin
            m_axi_bvalid[p]<=1;
            m_axi_bresp[p]<=2'b00;
          end
        end
        if(m_axi_bvalid[p]&&m_axi_bready[p])begin : check_scratch_tx
          int row_no,row_tx,seg,beat,plane,head,dest,tile,lane,col;
          logic [63:0] expected_addr;
          logic [31:0] expected_data;
          if(dut.rope_aux_owner)begin
            row_no=rope_b_total/128;row_tx=rope_b_total%128;
            plane=(row_tx/4)%2;head=row_tx/8;beat=row_tx%4;
            seg=plane*16+head;dest=head%2;
            expected_addr=64'h10000000+
                (((((plane*2)*8+head/2)*1024+row_no)*64)*4)+beat*64;
          end else begin
            row_no=raw_b_total/256;row_tx=raw_b_total%256;
            if(row_tx<192)begin
              seg=row_tx/4;beat=row_tx%4;
              plane=seg/16;head=seg%16;dest=head%2;
              expected_addr=64'h10000000+
                  (((((plane*2)*8+head/2)*1024+row_no)*64)*4)+beat*64;
            end else begin
              seg=48;beat=row_tx-192;dest=2;
              expected_addr=64'h10000000+row_no*4096+beat*64;
            end
          end
          if(p!=dest || scratch_aw_saved[p]!==expected_addr ||
             scratch_strb_saved[p]!=='1)
            $fatal(1,"SCRATCH_ADDR_BAD txn=%0d port=%0d actual=%h expected=%h",
              scratch_b_total,p,scratch_aw_saved[p],expected_addr);
          for(int word=0;word<16;word++)begin
            if(dut.rope_aux_owner)begin
              col=plane*1024+head*64+beat*16+word;
              expected_data=rope_final_gold[row_no*3072+col];
            end else begin
              tile=seg==48 ? 384+beat*2+word/8 : seg*8+beat*2+word/8;
              lane=word%8;col=tile*8+lane;
              expected_data=tile<384 ? final_gold[row_no*3072+col] :
                  norm_gold[row_no*1024+(tile-384)*8+lane];
            end
            if(scratch_w_saved[p][word*32+:32]!==expected_data)
              $fatal(1,"SCRATCH_DATA_BAD txn=%0d word=%0d actual=%h expected=%h",
                scratch_b_total,word,scratch_w_saved[p][word*32+:32],expected_data);
          end
          scratch_b_total<=scratch_b_total+1;
          if(dut.rope_aux_owner)rope_b_total<=rope_b_total+1;
          else raw_b_total<=raw_b_total+1;
          if(dest<2)begin
            scratch_qkv_mem[plane][row_no][head][beat]<=scratch_w_saved[p];
            scratch_qkv_valid[plane][row_no][head][beat]<=1;
          end else scratch_norm_mem[row_no][beat]<=scratch_w_saved[p];
          scratch_aw_seen[p]<=0;scratch_w_seen[p]<=0;
          m_axi_bvalid[p]<=0;m_axi_bresp[p]<=0;scratch_b_wait[p]<=0;
        end
      end
    end
  end

  // The read peer returns bytes committed by real RAW W/B transactions in
  // the same physical QKV domain. No QKV result is preloaded here.
  always_comb begin
    for(int p=0;p<2;p++)begin
      rope_arready[p]=rst_n && !rope_bus_active[p] &&
                      rope_bus_ar_stalls[p]>=2;
      rope_rvalid[p]=rope_bus_active[p] &&
                     (global_cycle%11!=p || rope_bus_r_hold[p]);
      rope_rdata[p]=rope_bus_active[p] ?
          scratch_qkv_mem[rope_bus_plane[p]][rope_bus_row[p]]
                         [rope_bus_head[p]][rope_bus_beat[p]] : '0;
      rope_rresp[p]=0;
      rope_rlast[p]=rope_bus_active[p] && rope_bus_left[p]==1;
    end
  end
  always @(posedge clk) begin : rope_read_peer
    int off,plane,pair_no,row_no,head_no;
    if(!rst_n)begin
      rope_ar_total<=0;rope_r_total<=0;
      for(int p=0;p<2;p++)begin
        rope_bus_active[p]<=0;rope_bus_r_hold[p]<=0;
        rope_bus_left[p]<=0;rope_bus_plane[p]<=0;
        rope_bus_row[p]<=0;rope_bus_head[p]<=0;rope_bus_beat[p]<=0;
        rope_bus_ar_stalls[p]<=0;rope_bus_r_gaps[p]<=0;
      end
      for(int pl=0;pl<3;pl++)
        for(int s=0;s<2;s++)
          for(int h=0;h<16;h++)
            for(int b=0;b<4;b++)scratch_qkv_valid[pl][s][h][b]<=0;
    end else for(int p=0;p<2;p++)begin
      if(rope_arvalid[p]&&!rope_arready[p])
        rope_bus_ar_stalls[p]<=rope_bus_ar_stalls[p]+1;
      if(rope_bus_active[p]&&!rope_rvalid[p])
        rope_bus_r_gaps[p]<=rope_bus_r_gaps[p]+1;
      if(rope_rvalid[p]&&!rope_rready[p])rope_bus_r_hold[p]<=1;
      if(rope_arvalid[p]&&rope_arready[p])begin
        if(rope_bus_active[p] || rope_araddr[p]<64'h10000000 ||
           rope_arsize[p]!=3'd6 || rope_arburst[p]!=2'd1 ||
           rope_arlen[p]!=3)
          $fatal(1,"ROPE_SCRATCH_AR_SHAPE port=%0d addr=%h len=%0d",
                 p,rope_araddr[p],rope_arlen[p]);
        off=int'(rope_araddr[p]-64'h10000000);
        plane=off/4194304;pair_no=(off%4194304)/262144;
        row_no=(off%262144)/256;head_no=pair_no*2+p;
        if(plane>=2 || pair_no>=8 || row_no>=2 || off%256!=0 ||
           !scratch_qkv_valid[plane][row_no][head_no][0] ||
           !scratch_qkv_valid[plane][row_no][head_no][1] ||
           !scratch_qkv_valid[plane][row_no][head_no][2] ||
           !scratch_qkv_valid[plane][row_no][head_no][3])
          $fatal(1,"ROPE_SCRATCH_READ_UNWRITTEN port=%0d off=%0d",p,off);
        rope_bus_plane[p]<=plane;rope_bus_row[p]<=row_no;
        rope_bus_head[p]<=head_no;rope_bus_beat[p]<=0;
        rope_bus_left[p]<=4;rope_bus_active[p]<=1;
        rope_ar_total<=rope_ar_total+1;
      end
      if(rope_rvalid[p]&&rope_rready[p])begin
        if(!rope_bus_active[p] || rope_bus_left[p]<=0 ||
           rope_rlast[p]!=(rope_bus_left[p]==1))
          $fatal(1,"ROPE_SCRATCH_R_SHAPE port=%0d",p);
        rope_bus_beat[p]<=rope_bus_beat[p]+1;
        rope_bus_left[p]<=rope_bus_left[p]-1;
        rope_r_total<=rope_r_total+1;
        rope_bus_r_hold[p]<=0;
        if(rope_rlast[p])rope_bus_active[p]<=0;
      end
    end
  end

  assign x_valid=drive_source && dut.core.state==6'd4 && source_idx<1024 &&
    x_gaps>=2 &&
    (global_cycle%13!=0 || x_hold);
  assign x_bits=ffn_active ? ffn_source[source_idx<1024 ? source_idx : 0] :
    raw[current_row*1024+(source_idx<1024 ? source_idx : 0)];
  assign gamma_valid=!ffn_active && drive_source && dut.core.state==6'd4 &&
    gamma_idx<1024 && gamma_gaps>=2 &&
    (global_cycle%17!=0 || gamma_hold);
  assign gamma_bits=gamma[gamma_idx<1024 ? gamma_idx : 0];
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!active[p] && ar_blocks[p]>=2;
      rvalid[p]=active[p] && (global_cycle%11!=p || r_hold[p]);
      rresp[p]=0;
      rdata[p]=ffn_active ?
        (rslot[p] ? (p==0 ? down_q0[read_index[p]] :
                        p==1 ? down_q1[read_index[p]] : down_scale[read_index[p]]) :
                    (p==0 ? wi_q0[read_index[p]] :
                        p==1 ? wi_q1[read_index[p]] : wi_scale[read_index[p]])) :
        (p==0 ? w_q0[read_index[p]] :
         p==1 ? w_q1[read_index[p]] : w_scale[read_index[p]]);
      rlast[p]=active[p] && left[p]==1;
    end
    aux_arready=!aux_active && aux_blocks>=2;
    aux_rvalid=aux_active && (aux_gaps>=2 || aux_r_hold);
    aux_rdata=rope_table_bus ?
      (rope_table_is_sin ? sin_words[current_row*16+aux_idx] :
                           cos_words[current_row*16+aux_idx]) :
      (ffn_active ? ffn_header_words[aux_idx] : header_words[aux_idx]);
    aux_rresp=0;
    aux_rlast=aux_active && aux_left==1;
  end

  always @(posedge clk) if(!rst_n)begin
    global_cycle<=0;source_idx<=0;gamma_idx<=0;norm_idx<=0;q_idx<=0;ps_idx<=0;
    pcmd<=0;par<=0;pr<=0;paar<=0;parr<=0;psrc<=0;pln<=0;pw<=0;
    pissue<=0;pcommit<=0;pbranch<=0;prsp<=0;
    fp_a_count<=0;fp_product_count<=0;fp_term_count<=0;
    aux_active<=0;aux_idx<=0;aux_left<=0;aux_blocks<=0;aux_ar_count<=0;
    aux_r_count<=0;held_aux<=0;aux_r_hold<=0;
    rope_table_bus<=0;rope_table_is_sin<=0;
    rope_aux_ar_total<=0;rope_aux_r_total<=0;rope_aux_ar_stalls<=0;
    header_aux_ar_stalls<=0;
    x_hold<=0;gamma_hold<=0;x_gaps<=0;gamma_gaps<=0;aux_gaps<=0;
    for(int p=0;p<3;p++)begin
      active[p]<=0;read_index[p]<=0;left[p]<=0;rslot[p]<=0;
      for(int s=0;s<2;s++)issued[s][p]<=0;
      ar_count[p]<=0;r_count[p]<=0;ar_blocks[p]<=0;held_ar[p]<=0;
      r_hold[p]<=0;r_gaps[p]<=0;
    end
  end else begin : monitor
    int remaining,beats,page_beats,g,t,l,idx,s;
    logic [511:0] word512;
    global_cycle<=global_cycle+1;
    if(global_cycle>=1000000)$fatal(1,"QKV_GLOBAL_CYCLE_CAP");
    if(cmd_valid && cmd_ready)pcmd<=pcmd+1;
    if(|(arvalid & arready))par<=par+1;
    if(|(rvalid & rready))pr<=pr+1;
    if(aux_arvalid && aux_arready)paar<=paar+1;
    if(aux_rvalid && aux_rready)parr<=parr+1;
    if((x_valid && x_ready) || (gamma_valid && gamma_ready))psrc<=psrc+1;
    if(dut.core.lnq.ln_out_fire || dut.core.lnq.q_out_fire)pln<=pln+1;
    if(dut.core.ret_valid && dut.core.ret_ready)pw<=pw+1;
    if(dut.core.issue_fire)pissue<=pissue+1;
    if(dut.core.front.commit_valid[0] && dut.core.front.commit_ready[0])
      pcommit<=pcommit+1;
    if(dut.core.g_issue || dut.core.g_commit || dut.core.add_accept || dut.core.add_consume)
      pbranch<=pbranch+1;
    if((rd_valid && rd_ready) || (rsp_valid && rsp_ready) ||
       (done_valid && done_ready))prsp<=prsp+1;
    if(global_cycle%500==0)
      $display("FFR1_PROGRESS cfg=%0d sar=%0d sr=%0d dar=%0d dr=%0d aa=%0d ar=%0d ac=%0d aw=%0d w=%0d b=%0d rsp=%0d",
        pcmd,par,pr,paar,parr,psrc,pln,pw,pissue,pcommit,pbranch,prsp);
    if(global_cycle%500==0)
      $display("SCRATCH_PROGRESS global=%0d cmd=%0d rsp=%0d aw=%0d w=%0d b=%0d flush=%0d route=%0d",
        global_cycle,pcmd,scratch_rsp_count,scratch_aw_total,
        scratch_w_total,scratch_b_total,scratch_flush_count,dut.route);
    if(global_cycle%500==0)
      $display("ROPE_PROGRESS global=%0d row=%0d state=%0d RAW_B=%0d ROPE_AR=%0d ROPE_R=%0d TABLE_AR=%0d TABLE_R=%0d leaf_done=%0d head=%0d rope_B=%0d",
        global_cycle,current_row,dut.state,raw_b_total,rope_ar_total,
        rope_r_total,rope_aux_ar_total,rope_aux_r_total,
        done_rope_check_valid,dut.rope_head_count,rope_b_total);
    if(dut.core.load_done)begin
      if(dut.core.load_error || dut.core.load_reject)
        $fatal(1,"SWITCH_LOAD_ERROR mode=%0d slot=%0d",ffn_active,dut.core.active_slot);
      load_good<=load_good+1;
      $display("SWITCH_LOAD_DONE mode=%0d slot=%0d epoch=%0d global=%0d",
        ffn_active,dut.core.active_slot,dut.core.slot_epoch[dut.core.active_slot],global_cycle);
    end
    if(global_cycle%5000==0)
      $display("QKV_PROGRESS global=%0d row=%0d state=%0d group=%0d tile=%0d issue=%0d commit=%0d W=%0d/%0d",
        global_cycle,current_row,dut.core.state,dut.core.group_no,dut.core.tile_no,
        actual_stripes,actual_ps_commits,actual_w_reads,actual_w_returns);
    if(drive_source && dut.core.state==6'd4 && x_ready &&
       source_idx<1024 && !x_valid)
      x_gaps<=x_gaps+1;
    if(!ffn_active && drive_source && dut.core.state==6'd4 && gamma_ready &&
       gamma_idx<1024 && !gamma_valid)
      gamma_gaps<=gamma_gaps+1;
    if(x_valid && !x_ready)x_hold<=1;
    if(x_valid && x_ready)begin source_idx<=source_idx+1;x_hold<=0;end
    if(gamma_valid && !gamma_ready)gamma_hold<=1;
    if(gamma_valid && gamma_ready)begin gamma_idx<=gamma_idx+1;gamma_hold<=0;end
    if(!ffn_active && !cross_recovery_only && dut.core.norm_valid)begin
      if(norm_idx>=1024 || dut.core.norm_index!==10'(norm_idx) ||
         dut.core.norm_bits!==norm_gold[current_row*1024+norm_idx])
        $fatal(1,"QKV_NORM_MISMATCH row=%0d index=%0d",current_row,norm_idx);
      norm_idx<=norm_idx+1;
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.ln_rsp_valid && dut.core.lnq.rsp_ready)begin
      if(q_idx>=32 || dut.core.ln_rsp_group!==7'(q_idx) ||
         dut.core.ln_rsp_q!==q_gold[current_row*32+q_idx] ||
         dut.core.ln_rsp_scale!==scale_gold[current_row*32+q_idx])
        $fatal(1,"QKV_A_MISMATCH row=%0d group=%0d",current_row,q_idx);
      q_idx<=q_idx+1;
    end
    for(int p=0;p<3;p++)begin
      if(active[p] && !rvalid[p])r_gaps[p]<=r_gaps[p]+1;
      if(rvalid[p] && !rready[p])r_hold[p]<=1;
      if(held_ar[p] && !arvalid[p])$fatal(1,"QKV_W_AR_VALID_DROPPED port=%0d",p);
      if(held_ar[p] && arvalid[p] &&
         (araddr[p]!==held_addr[p] || arlen[p]!==held_len[p] ||
          arsize[p]!==held_size[p] || arburst[p]!==held_burst[p]))
        $fatal(1,"QKV_W_AR_UNSTABLE port=%0d",p);
      if(arvalid[p] && !arready[p])begin
        held_ar[p]<=1;held_addr[p]<=araddr[p];held_len[p]<=arlen[p];
        held_size[p]<=arsize[p];held_burst[p]<=arburst[p];
        if(ar_blocks[p]<2)ar_blocks[p]<=ar_blocks[p]+1;
      end
      if(arvalid[p] && arready[p])begin
        s=int'(dut.core.active_slot);
        if(active[p] || araddr[p]!=active_base[p]+issued[s][p] ||
           arsize[p]!=3'd6 || arburst[p]!=2'd1)
          $fatal(1,"QKV_W_AR_BAD port=%0d addr=%h",p,araddr[p]);
        remaining=(active_bytes[p]-issued[s][p])/64;
        page_beats=(4096-int'(araddr[p]%4096))/64;
        beats=remaining<64 ? remaining:64;
        if(beats>page_beats)beats=page_beats;
        if(beats<=0 || arlen[p]+1!=beats)$fatal(1,"QKV_W_AR_4K_BAD port=%0d",p);
        active[p]<=1;rslot[p]<=dut.core.active_slot;
        read_index[p]<=issued[s][p]/64;left[p]<=beats;
        issued[s][p]<=issued[s][p]+beats*64;
        ar_count[p]<=ar_count[p]+1;held_ar[p]<=0;
      end
      if(rvalid[p] && rready[p])begin
        if(!active[p] || left[p]<=0 || rlast[p]!=(left[p]==1))
          $fatal(1,"QKV_W_R_BAD port=%0d",p);
        read_index[p]<=read_index[p]+1;left[p]<=left[p]-1;
        if(rlast[p])active[p]<=0;
        r_count[p]<=r_count[p]+1;r_hold[p]<=0;
      end
    end
    if(aux_active && !aux_rvalid)aux_gaps<=aux_gaps+1;
    if(aux_rvalid && !aux_rready)aux_r_hold<=1;
    if(held_aux && !aux_arvalid)$fatal(1,"QKV_AUX_AR_VALID_DROPPED");
    if(held_aux && aux_arvalid &&
       (aux_araddr!==held_aux_addr || aux_arlen!==held_aux_len ||
        aux_arsize!==held_aux_size || aux_arburst!==held_aux_burst))
      $fatal(1,"QKV_AUX_AR_UNSTABLE");
    if(aux_arvalid && !aux_arready)begin
      held_aux<=1;held_aux_addr<=aux_araddr;held_aux_len<=aux_arlen;
      held_aux_size<=aux_arsize;held_aux_burst<=aux_arburst;
      if(aux_blocks<2)aux_blocks<=aux_blocks+1;
      if(dut.rope_aux_owner)rope_aux_ar_stalls<=rope_aux_ar_stalls+1;
      else header_aux_ar_stalls<=header_aux_ar_stalls+1;
    end
    if(aux_arvalid && aux_arready)begin
      if(dut.rope_aux_owner)begin
        if(aux_active || aux_arsize!=3'd4 || aux_arburst!=2'd1 ||
           aux_arlen!=15 ||
           (aux_araddr!=cmd_rope_aux_base+64'd617728+current_row*256 &&
            aux_araddr!=cmd_rope_aux_base+64'd880128+current_row*256))
          $fatal(1,"ROPE_TABLE_AR_BAD addr=%h",aux_araddr);
        rope_table_is_sin<=
          aux_araddr==cmd_rope_aux_base+64'd880128+current_row*256;
        rope_table_bus<=1;aux_left<=16;
        rope_aux_ar_total<=rope_aux_ar_total+1;
      end else begin
        if(aux_active ||
           aux_araddr!=(dut.core.active_slot ? cmd_down_aux_base : cmd_aux_base) ||
           aux_arsize!=3'd4 || aux_arburst!=2'd1 || aux_arlen!=7)
          $fatal(1,"QKV_AUX_AR_BAD");
        rope_table_bus<=0;aux_left<=8;aux_ar_count<=aux_ar_count+1;
      end
      aux_active<=1;aux_idx<=0;aux_blocks<=0;
      held_aux<=0;
    end
    if(aux_rvalid && aux_rready)begin
      if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
        $fatal(1,"QKV_AUX_R_BAD");
      aux_idx<=aux_idx+1;aux_left<=aux_left-1;
      if(aux_rlast)begin aux_active<=0;rope_table_bus<=0;end
      if(rope_table_bus)rope_aux_r_total<=rope_aux_r_total+1;
      else aux_r_count<=aux_r_count+1;
      aux_r_hold<=0;
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.ret_valid && dut.core.ret_ready && dut.core.ret_ok)begin
      g=int'(dut.core.group_no);t=int'(dut.core.tile_no);
      for(l=0;l<8;l++)begin
        idx=(t/2)*32*4+g*4+l/2;
        word512=t[0] ? w_q1[idx] : w_q0[idx];
        if(dut.core.ret_q[0][l]!==word512[(l%2)*256+:256] ||
           dut.core.ret_scale[0][l]!==w_scale[(t*32+g)*8/32][((t*32+g)*8+l)%32*16+:16] ||
           !dut.core.ret_mask[0][l])
          $fatal(1,"QKV_W_BANK_MISMATCH row=%0d g=%0d t=%0d lane=%0d",current_row,g,t,l);
      end
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.front.commit_valid[0] && dut.core.front.commit_ready[0])begin
      g=int'({dut.core.commit_tag[160],dut.core.commit_tag[11+:6]});
      t=int'(dut.core.commit_tile[9:0]);
      if(g>=32 || t>=384 || ps_idx>=12288 ||
         dut.core.commit_next_ps[255:0]!==ps_gold[current_row*12288+g*384+t])
        $fatal(1,"QKV_PS_MISMATCH row=%0d group=%0d tile=%0d",current_row,g,t);
      ps_idx<=ps_idx+1;
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.front.row[0].arithmetic.fp_restore.valid_a)begin
      g=int'({dut.core.front.row[0].arithmetic.fp_restore.tag_a[160],
              dut.core.front.row[0].arithmetic.fp_restore.tag_a[16:11]});
      t=int'({dut.core.front.row[0].arithmetic.fp_restore.tag_a[161],
              dut.core.front.row[0].arithmetic.fp_restore.tag_a[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_a_count>=12288 ||
         dut.core.front.row[0].arithmetic.fp_restore.dot_a!==step0_gold[idx] ||
         dut.core.front.row[0].arithmetic.fp_restore.sa_a!==step1_gold[idx][31:0] ||
         dut.core.front.row[0].arithmetic.fp_restore.sw_a!==step2_gold[idx])
        $fatal(1,"QKV_FP_INPUT_STEPS_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_a_count<=fp_a_count+1;
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.front.row[0].arithmetic.fp_restore.valid_c)begin
      g=int'({dut.core.front.row[0].arithmetic.fp_restore.meta_c.tag[160],
              dut.core.front.row[0].arithmetic.fp_restore.meta_c.tag[16:11]});
      t=int'({dut.core.front.row[0].arithmetic.fp_restore.meta_c.tag[161],
              dut.core.front.row[0].arithmetic.fp_restore.meta_c.tag[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_product_count>=12288 ||
         dut.core.front.row[0].arithmetic.fp_restore.scale_product_c!==step3_gold[idx])
        $fatal(1,"QKV_FP_PRODUCT_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_product_count<=fp_product_count+1;
    end
    if(!ffn_active && !cross_recovery_only &&
       dut.core.front.row[0].arithmetic.fp_restore.valid_add)begin
      g=int'({dut.core.front.row[0].arithmetic.fp_restore.tag_add[160],
              dut.core.front.row[0].arithmetic.fp_restore.tag_add[16:11]});
      t=int'({dut.core.front.row[0].arithmetic.fp_restore.tag_add[161],
              dut.core.front.row[0].arithmetic.fp_restore.tag_add[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_term_count>=12288 ||
         dut.core.front.row[0].arithmetic.fp_restore.term_add!==step4_gold[idx])
        $fatal(1,"QKV_FP_TERM_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_term_count<=fp_term_count+1;
    end
    if(!ffn_active && (dut.core.g_issue || dut.core.g_commit || dut.core.add_accept || dut.core.add_consume))
      $fatal(1,"QKV_FFN_SERVICE_STARTED");
    if(ffn_active)begin
      if(dut.core.lnq.source_direct && dut.core.norm_valid)
        $fatal(1,"SWITCH_DIRECT_NORM_EVENT");
      if(dut.core.lnq.ln_out_fire)begin
        if(ffn_ln_count>=1024 || dut.core.lnq.ln_out_index!==10'(ffn_ln_count) ||
           dut.core.lnq.ln_out_bits!==ffn_ln[ffn_ln_count])
          $fatal(1,"SWITCH_FFN_LN_BAD index=%0d",ffn_ln_count);
        ffn_ln_count<=ffn_ln_count+1;
      end
      if(dut.core.ln_rsp_valid && dut.core.lnq.rsp_ready)begin
        if(dut.core.phase_down)begin
          if(down_q_count>=82 || dut.core.ln_rsp_group!==7'(down_q_count) ||
             dut.core.ln_rsp_q!==down_q_gold[down_q_count] ||
             dut.core.ln_rsp_scale!==down_scale_gold[down_q_count])
            $fatal(1,"SWITCH_DOWN_Q_BAD group=%0d",down_q_count);
          down_q_count<=down_q_count+1;
        end else begin
          if(wi_q_count>=32 || dut.core.ln_rsp_group!==7'(wi_q_count) ||
             dut.core.ln_rsp_q!==wi_q_gold[wi_q_count] ||
             dut.core.ln_rsp_scale!==wi_scale_gold[wi_q_count])
            $fatal(1,"SWITCH_WI_Q_BAD group=%0d",wi_q_count);
          wi_q_count<=wi_q_count+1;
        end
      end
      if(dut.core.front.commit_valid[0] && dut.core.front.commit_ready[0])begin
        g=int'({dut.core.commit_tag[160],dut.core.commit_tag[11+:6]});
        t=int'(dut.core.commit_tile[9:0]);
        if(dut.core.phase_down)begin
          if(g>=82 || t>=128 ||
             dut.core.commit_next_ps[255:0]!==down_ps_gold[g*128+t])
            $fatal(1,"SWITCH_DOWN_PS_BAD group=%0d tile=%0d",g,t);
          down_ps_count<=down_ps_count+1;
        end else begin
          if(g>=32 || t>=656 ||
             dut.core.commit_next_ps[255:0]!==wi_ps_gold[g*656+t])
            $fatal(1,"SWITCH_WI_PS_BAD group=%0d tile=%0d",g,t);
          wi_ps_count<=wi_ps_count+1;
        end
      end
      if(dut.core.g_commit)begin
        if(g_count>=2624 || dut.core.g_status!=0 || dut.core.g_data!==g_gold[g_count])
          $fatal(1,"SWITCH_G_BAD index=%0d",g_count);
        g_count<=g_count+1;
      end
      if(dut.core.g_issue)begin
        idx=int'(dut.core.g_issued);
        if(idx>=2624 || dut.core.g_x_hold[dut.core.g_lane*32+:32]!==wi_final[idx] ||
           dut.core.g_gate_hold[dut.core.g_lane*32+:32]!==wi_final[2624+idx] ||
           dut.core.g_gate_tile!==10'(328+idx/8))
          $fatal(1,"SWITCH_G_INPUT_BAD index=%0d",idx);
      end
      if(dut.core.add_accept)begin
        idx=int'(dut.core.res_issued);
        if(idx>=1024 || dut.core.res_a_hold!==ffn_source[idx] ||
           dut.core.res_b_hold!==down_final[idx])
          $fatal(1,"SWITCH_ADD_INPUT_BAD index=%0d",idx);
      end
      if(dut.core.add_consume)begin
        if(add_count>=1024 || dut.core.add_bits!==residual_gold[add_count])
          $fatal(1,"SWITCH_ADD_BAD index=%0d",add_count);
        add_count<=add_count+1;
      end
    end
  end

  task automatic start_qkv(input bit cold,input int row);
    @(negedge clk);
    current_row=row;source_idx=0;gamma_idx=0;norm_idx=0;q_idx=0;ps_idx=0;
    x_gaps=0;gamma_gaps=0;x_hold=0;gamma_hold=0;
    fp_a_count=0;fp_product_count=0;fp_term_count=0;
    cmd_id=32'(81+row);cmd_mode=1;cmd_row=7'(row);cmd_cold=cold;
    cmd_tensor_begin=(row==0);
    cmd_task_context={8'd1,16'(row),8'd128,8'd1,8'd0,8'd0,8'd1,32'(81+row)};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"QKV_CMD_NOT_READY row=%0d",row);
    $display("QKV_CMD_ACCEPT row=%0d cold=%0d global=%0d",row,cold,global_cycle);
    @(negedge clk);cmd_valid=0;drive_source=1;
    cmd_row=7'(row^1); // The accepted row must remain latched.
  endtask

  task automatic reject_mode_row(input bit mode,input logic [6:0] row);
    int prior_ar[0:2],prior_aux;
    for(int p=0;p<3;p++)prior_ar[p]=ar_count[p];
    prior_aux=aux_ar_count;
    @(negedge clk);
    cmd_id=32'd79;cmd_mode=mode;cmd_row=row;cmd_cold=1;
    cmd_down_w_epoch=1;
    cmd_task_context={8'd1,16'd0,8'd128,8'd1,8'd0,8'd0,8'd1,32'd79};
    if(!mode)cmd_task_context[87:72]={9'd0,row};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"SWITCH_REJECT_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<5 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || row_valid || done_status!=4'd7 ||
       result_mode!==mode || result_row!==row ||
       actual_stripes!=0 || actual_w_reads!=0 ||
       ar_count[0]!=prior_ar[0] || ar_count[1]!=prior_ar[1] ||
       ar_count[2]!=prior_ar[2] || aux_ar_count!=prior_aux)
      $fatal(1,"SWITCH_REJECT_BAD mode=%0d row=%0d",mode,row);
    done_ready=1;@(negedge clk);done_ready=0;
    $display("SWITCH_MODE_ROW_REJECT_PASS mode=%0d row=%0d",mode,row);
  endtask

  task automatic finish_qkv(input int row,input bit expect_bad);
    for(int guard=0;guard<200000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || row_valid || result_mode!==1 ||
       result_row!==7'(row) || done_id!==32'(81+row) ||
       source_idx!=1024 || gamma_idx!=1024 || norm_idx!=1024 ||
       q_idx!=32 || ps_idx!=12288 || fp_a_count!=12288 ||
       fp_product_count!=12288 || fp_term_count!=12288 ||
       actual_w_reads!=12288 || actual_w_returns!=12288 ||
       actual_stripes!=12288 || actual_ps_commits!=12288 ||
       dut.core.norm_count!=1024 || dut.core.slot_readers[0]!=0 ||
       dut.core.slot_state[0]!=3'd2 || scratch_rsp_count!=512 ||
       scratch_flush_count!=(expect_bad ? 48 : 49) ||
       scratch_aw_count[0]!=96 || scratch_aw_count[1]!=96 ||
       scratch_aw_count[2]!=64 || scratch_w_count[0]!=96 ||
       scratch_w_count[1]!=96 || scratch_w_count[2]!=64 ||
       scratch_b_count[0]!=96 || scratch_b_count[1]!=96 ||
       scratch_b_count[2]!=64 || scratch_b_total!=256*(row+1))
      $fatal(1,"SCRATCH_QKV_INCOMPLETE row=%0d state=%0d status=%0d norm=%0d Q=%0d PS=%0d rsp=%0d flush=%0d AW=%0d/%0d/%0d B=%0d",
        row,dut.state,done_status,norm_idx,q_idx,ps_idx,scratch_rsp_count,
        scratch_flush_count,scratch_aw_count[0],scratch_aw_count[1],
        scratch_aw_count[2],scratch_b_total);
    if(expect_bad)begin
      if(done_status!=4'd7 || done_phase!=4'd12 ||
         done_bad_element!=32'hffffffff || row_written!==(128'b1) ||
         !tensor_failed || tensor_raw_valid ||
         scratch_error_dst!=2 || scratch_error_bresp!=2'b10)
        $fatal(1,"SCRATCH_QKV_LAST_B_ERROR_BAD");
    end else if(done_status!=0 || done_phase!=4'd7 ||
                row_written!==(128'b1) || tensor_failed || tensor_raw_valid)
      $fatal(1,"SCRATCH_QKV_ROW0_SUCCESS_BAD");
    $display("SCRATCH_QKV_DONE row=%0d status=%0d global=%0d AW=%0d W=%0d B=%0d rsp=%0d flush=%0d",
      row,done_status,global_cycle,scratch_aw_total,scratch_w_total,
      scratch_b_total,scratch_rsp_count,scratch_flush_count);
    drive_source=0;
    done_ready=1;@(negedge clk);done_ready=0;
  endtask

  task automatic finish_rope_qkv(input int row);
    logic [127:0] expected_bits;
    int idx;
    for(int guard=0;guard<300000 && !done_valid;guard++)@(negedge clk);
    expected_bits=(128'b1 << (row+1))-1'b1;
    if(!done_valid || row_valid || result_mode!==1 ||
       result_row!==7'(row) || done_id!==32'(81+row) ||
       done_status!=0 || done_phase!=4'd7 ||
       done_bad_element!=32'hffffffff ||
       !done_rope_check_valid || done_rope_check[15:0]!=0 ||
       done_rope_check[63:32]!=0 ||
       done_rope_check[127:64]!==64'hffffffffffffffff ||
       done_rope_head!=4'd15 || !done_rope_plane ||
       source_idx!=1024 || gamma_idx!=1024 || norm_idx!=1024 ||
       q_idx!=32 || ps_idx!=12288 || fp_a_count!=12288 ||
       fp_product_count!=12288 || fp_term_count!=12288 ||
       actual_w_reads!=12288 || actual_w_returns!=12288 ||
       actual_stripes!=12288 || actual_ps_commits!=12288 ||
       scratch_rsp_count!=512 || scratch_flush_count!=49 ||
       dut.rope_head_count!=32 || dut.rope_flush_count!=32 ||
       dut.rope_b_ok_count!=128 ||
       scratch_aw_count[0]!=160 || scratch_aw_count[1]!=160 ||
       scratch_aw_count[2]!=64 || scratch_w_count[0]!=160 ||
       scratch_w_count[1]!=160 || scratch_w_count[2]!=64 ||
       scratch_b_count[0]!=160 || scratch_b_count[1]!=160 ||
       scratch_b_count[2]!=64 ||
       raw_b_total!=256*(row+1) || rope_b_total!=128*(row+1) ||
       scratch_b_total!=384*(row+1) ||
       rope_ar_total!=32*(row+1) || rope_r_total!=128*(row+1) ||
       rope_aux_ar_total!=2*(row+1) ||
       rope_aux_r_total!=32*(row+1) ||
       row_written!==expected_bits || row_final!==expected_bits ||
       tensor_failed || tensor_raw_valid || tensor_final_valid ||
       !tensor_rope_enable || tensor_final_dst_epoch[0]!=2 ||
       tensor_final_dst_epoch[1]!=2 || tensor_final_dst_epoch[2]!=1)
      $fatal(1,"ROPE_QKV_INCOMPLETE row=%0d state=%0d status=%0d rawB=%0d ropeB=%0d ropeAR=%0d ropeR=%0d tableAR=%0d tableR=%0d head=%0d",
        row,dut.state,done_status,raw_b_total,rope_b_total,
        rope_ar_total,rope_r_total,rope_aux_ar_total,rope_aux_r_total,
        dut.rope_head_count);
    for(int plane=0;plane<2;plane++)
      for(int head=0;head<16;head++)
        for(int beat=0;beat<4;beat++)
          for(int word=0;word<16;word++)begin
            idx=plane*1024+head*64+beat*16+word;
            if(scratch_qkv_mem[plane][row][head][beat][word*32+:32] !==
               rope_final_gold[row*3072+idx])
              $fatal(1,"ROPE_MEM_FINAL_MISMATCH row=%0d idx=%0d",row,idx);
          end
    for(int head=0;head<16;head++)
      for(int beat=0;beat<4;beat++)
        for(int word=0;word<16;word++)begin
          idx=2048+head*64+beat*16+word;
          if(scratch_qkv_mem[2][row][head][beat][word*32+:32] !==
             final_gold[row*3072+idx])
            $fatal(1,"ROPE_V_CHANGED row=%0d idx=%0d",row,idx);
        end
    for(int beat=0;beat<64;beat++)
      for(int word=0;word<16;word++)
        if(scratch_norm_mem[row][beat][word*32+:32] !==
           norm_gold[row*1024+beat*16+word])
          $fatal(1,"ROPE_NORM_CHANGED row=%0d idx=%0d",row,beat*16+word);
    $display("ROPE_QKV_ROW_PASS row=%0d global=%0d RAW_B=%0d ROPE_B=%0d head=%0d",
      row,global_cycle,raw_b_total,rope_b_total,dut.rope_head_count);
    drive_source=0;
    done_ready=1;@(negedge clk);done_ready=0;
  endtask

  task automatic start_ffn(input bit cold,input int new_id);
    @(negedge clk);
    source_idx=0;ffn_ln_count=0;wi_q_count=0;wi_ps_count=0;
    down_q_count=0;down_ps_count=0;g_count=0;add_count=0;
    cmd_valid=1;cmd_mode=0;cmd_row=0;cmd_cold=cold;cmd_id=32'(new_id);
    cmd_task_context={8'd1,16'd0,8'd128,8'd1,8'd0,8'd0,8'd1,32'(new_id)};
    #1ps;if(!cmd_ready)$fatal(1,"SWITCH_FFN_CMD_NOT_READY");
    $display("SWITCH_FFN_ACCEPT cold=%0d id=%0d global=%0d",cold,new_id,global_cycle);
    @(negedge clk);cmd_valid=0;drive_source=1;
  endtask

  task automatic ffn_wrong_warm;
    int prior_ar[0:2],prior_aux;
    for(int p=0;p<3;p++)prior_ar[p]=ar_count[p];
    prior_aux=aux_ar_count;
    start_ffn(0,90);
    for(int guard=0;guard<30000 && !done_valid && !row_valid;guard++)@(negedge clk);
    if(!done_valid || row_valid || done_status!=4'd7 ||
       done_phase!=4'd3 || result_mode!==0 || result_row!==0 ||
       source_idx!=1024 || ffn_ln_count!=1024 || actual_stripes!=0 ||
       dut.core.slot_readers[0]!=0 || dut.core.slot_readers[1]!=0 ||
       ar_count[0]!=prior_ar[0] || ar_count[1]!=prior_ar[1] ||
       ar_count[2]!=prior_ar[2] || aux_ar_count!=prior_aux)
      $fatal(1,"SWITCH_WRONG_WARM_BAD status=%0d phase=%0d x=%0d issue=%0d",
        done_status,done_phase,source_idx,actual_stripes);
    drive_source=0;
    $display("SWITCH_WRONG_WARM_PASS global=%0d status=7 phase=3 issue=0 AR_delta=0",
      global_cycle);
    done_ready=1;@(negedge clk);done_ready=0;
  endtask

  task automatic finish_ffn;
    logic [255:0] held_bits;
    int tile;
    for(int guard=0;guard<300000 && !row_valid && !done_valid;guard++)@(negedge clk);
    if(!row_valid || done_valid || done_status!=0 ||
       result_mode!==0 || result_row!==0 ||
       source_idx!=1024 || ffn_ln_count!=1024 ||
       wi_q_count!=32 || wi_ps_count!=20992 ||
       g_count!=2624 || down_q_count!=82 || down_ps_count!=10496 ||
       add_count!=1024 || actual_w_reads!=31488 ||
       actual_w_returns!=31488 || actual_stripes!=31488 ||
       actual_ps_commits!=31488 || dut.core.slot_readers[0]!=0 ||
       dut.core.slot_readers[1]!=0)
      $fatal(1,"SWITCH_FFN_NOT_PUBLISHED status=%0d phase=%0d x=%0d WiPS=%0d G=%0d DownPS=%0d ADD=%0d",
        done_status,done_phase,source_idx,wi_ps_count,g_count,down_ps_count,add_count);
    $display("SWITCH_FFN_ROW_VISIBLE global=%0d WiPS=%0d G=%0d DownPS=%0d ADD=%0d",
      global_cycle,wi_ps_count,g_count,down_ps_count,add_count);
    drive_source=0;
    for(int n=0;n<130;n++)begin
      tile=n<128 ? (127-n) : (n==128 ? 0 : 127);
      @(negedge clk);rd_valid=1;rd_tile=10'(tile);
      #1ps;if(!rd_ready)$fatal(1,"SWITCH_FFN_READ_NOT_READY tile=%0d",tile);
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<5 && !rsp_valid;guard++)@(negedge clk);
      if(!rsp_valid || rsp_tile!==10'(tile) || result_mode!==0 || result_row!==0)
        $fatal(1,"SWITCH_FFN_RSP_BAD tile=%0d",tile);
      held_bits=rsp_bits;
      repeat(2)begin
        @(negedge clk);
        if(!rsp_valid || rsp_bits!==held_bits || rsp_tile!==10'(tile) ||
           result_mode!==0 || result_row!==0)
          $fatal(1,"SWITCH_FFN_RSP_HOLD_BAD tile=%0d",tile);
      end
      for(int lane=0;lane<8;lane++)
        if(rsp_bits[lane*32+:32]!==residual_gold[tile*8+lane])
          $fatal(1,"SWITCH_FFN_FINAL_BAD index=%0d",tile*8+lane);
      rsp_ready=1;@(negedge clk);rsp_ready=0;
    end
    @(negedge clk);row_release_valid=1;rd_valid=1;rd_tile=0;
    #1ps;if(!row_release_ready || rd_ready)
      $fatal(1,"SWITCH_FFN_RELEASE_PRIORITY_BAD");
    @(negedge clk);row_release_valid=0;rd_valid=0;
    for(int guard=0;guard<10 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_phase!=4'd7 ||
       done_bad_element!=32'hffffffff || result_mode!==0 || result_row!==0)
      $fatal(1,"SWITCH_FFN_DONE_BAD status=%0d phase=%0d",done_status,done_phase);
    $display("SWITCH_FFN_DONE global=%0d W_AR_delta=%0d/%0d/%0d AUX_delta=%0d",
      global_cycle,ar_count[0]-ffn_ar_base[0],ar_count[1]-ffn_ar_base[1],
      ar_count[2]-ffn_ar_base[2],aux_ar_count-ffn_w_base);
    done_ready=1;@(negedge clk);done_ready=0;
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"QKV_FIXTURE_REQUIRED");
    if(!$value$plusargs("FFN_FIXTURE=%s",ffn_fixture))
      $fatal(1,"FFN_FIXTURE_REQUIRED");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/w_q0.hex"},w_q0);
    $readmemh({fixture,"/w_q1.hex"},w_q1);
    $readmemh({fixture,"/w_scale.hex"},w_scale);
    $readmemh({fixture,"/raw_row0.hex"},raw,0,1023);
    $readmemh({fixture,"/raw_row1.hex"},raw,1024,2047);
    $readmemh({fixture,"/norm_row0.hex"},norm_gold,0,1023);
    $readmemh({fixture,"/norm_row1.hex"},norm_gold,1024,2047);
    $readmemh({fixture,"/gamma.hex"},gamma);
    $readmemh({fixture,"/q_row0.hex"},q_gold,0,31);
    $readmemh({fixture,"/q_row1.hex"},q_gold,32,63);
    $readmemh({fixture,"/scale_row0.hex"},scale_gold,0,31);
    $readmemh({fixture,"/scale_row1.hex"},scale_gold,32,63);
    $readmemh({fixture,"/ps_row0.hex"},ps_gold,0,12287);
    $readmemh({fixture,"/ps_row1.hex"},ps_gold,12288,24575);
    $readmemh({fixture,"/step0_row0.hex"},step0_gold,0,12287);
    $readmemh({fixture,"/step0_row1.hex"},step0_gold,12288,24575);
    $readmemh({fixture,"/step1_row0.hex"},step1_gold,0,12287);
    $readmemh({fixture,"/step1_row1.hex"},step1_gold,12288,24575);
    $readmemh({fixture,"/step2_row0.hex"},step2_gold,0,12287);
    $readmemh({fixture,"/step2_row1.hex"},step2_gold,12288,24575);
    $readmemh({fixture,"/step3_row0.hex"},step3_gold,0,12287);
    $readmemh({fixture,"/step3_row1.hex"},step3_gold,12288,24575);
    $readmemh({fixture,"/step4_row0.hex"},step4_gold,0,12287);
    $readmemh({fixture,"/step4_row1.hex"},step4_gold,12288,24575);
    $readmemh({fixture,"/final_row0.hex"},final_gold,0,3071);
    $readmemh({fixture,"/final_row1.hex"},final_gold,3072,6143);
    $readmemh({fixture,"/rope_final_row0.hex"},rope_final_gold,0,3071);
    $readmemh({fixture,"/rope_final_row1.hex"},rope_final_gold,3072,6143);
    $readmemh({fixture,"/rope_cos.hex"},cos_words);
    $readmemh({fixture,"/rope_sin.hex"},sin_words);
    $readmemh({ffn_fixture,"/wi_config.hex"},wi_cfg);
    $readmemh({ffn_fixture,"/down_config.hex"},down_cfg);
    $readmemh({ffn_fixture,"/model_identity.hex"},ffn_model_rom);
    $readmemh({ffn_fixture,"/expected_aux_header.hex"},ffn_header_rom);
    $readmemh({ffn_fixture,"/aux_header.hex"},ffn_header_words);
    $readmemh({ffn_fixture,"/wi_q0.hex"},wi_q0);
    $readmemh({ffn_fixture,"/wi_q1.hex"},wi_q1);
    $readmemh({ffn_fixture,"/wi_scale.hex"},wi_scale);
    $readmemh({ffn_fixture,"/down_q0.hex"},down_q0);
    $readmemh({ffn_fixture,"/down_q1.hex"},down_q1);
    $readmemh({ffn_fixture,"/down_scale.hex"},down_scale);
    $readmemh({ffn_fixture,"/ln_source_row0.hex"},ffn_source);
    $readmemh({ffn_fixture,"/ln_gold_row0.hex"},ffn_ln);
    $readmemh({ffn_fixture,"/q_row0.hex"},wi_q_gold);
    $readmemh({ffn_fixture,"/scale_row0.hex"},wi_scale_gold);
    $readmemh({ffn_fixture,"/ps_row0.hex"},wi_ps_gold);
    $readmemh({ffn_fixture,"/final_row0.hex"},wi_final);
    $readmemh({ffn_fixture,"/g_row0.hex"},g_gold);
    $readmemh({ffn_fixture,"/down_q_row0.hex"},down_q_gold);
    $readmemh({ffn_fixture,"/down_scale_row0.hex"},down_scale_gold);
    $readmemh({ffn_fixture,"/down_ps_row0.hex"},down_ps_gold);
    $readmemh({ffn_fixture,"/down_final_row0.hex"},down_final);
    $readmemh({ffn_fixture,"/residual_row0.hex"},residual_gold);
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_expected_aux_header=header_rom[0];
    cmd_load_base[0]=64'h3800000;cmd_load_base[1]=64'h3800000;
    cmd_load_base[2]=64'h700000;
    cmd_load_bytes[0]=32'd1572864;cmd_load_bytes[1]=32'd1572864;
    cmd_load_bytes[2]=32'd196608;
    cmd_tensor_epoch=1;
    cmd_dst_epoch='{default:32'd1};
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=64'd12582912;cmd_dst_span[1]=64'd12582912;
    cmd_dst_span[2]=64'd8388608;
    cmd_source_hidden_bank=0;
    $display("FFR1_SIM_START");
    cross_recovery_only=0;
    repeat(5)@(negedge clk);rst_n=1;
    reject_mode_row(0,7'd1);
    reject_mode_row(1,7'd1);
    cmd_down_w_epoch=0;
    start_qkv(1,0);
    if($test$plusargs("PILOT"))begin
      for(int guard=0;guard<200000 && actual_stripes<256 && !done_valid;guard++)@(negedge clk);
      if(actual_stripes<256 || done_valid || ar_blocks[0]<2 ||
         header_aux_ar_stalls<2)
        $fatal(1,"QKV_PILOT_NO_PREFIX stripes=%0d status=%0d",actual_stripes,done_status);
      $display("QKV_PILOT_PASS global=%0d issue=%0d PS=%0d W=%0d/%0d AR=%0d/%0d/%0d AUX=%0d",
        global_cycle,actual_stripes,ps_idx,actual_w_reads,actual_w_returns,
        ar_count[0],ar_count[1],ar_count[2],aux_ar_count);
      $finish;
    end
    finish_rope_qkv(0);
    start_qkv(0,1);
    finish_rope_qkv(1);
    if(ar_count[0]!=384 || ar_count[1]!=384 || ar_count[2]!=48 ||
       r_count[0]!=24576 || r_count[1]!=24576 || r_count[2]!=3072 ||
       aux_ar_count!=1 || aux_r_count!=8 ||
       rope_aux_ar_total!=4 || rope_aux_r_total!=64 ||
       rope_ar_total!=64 || rope_r_total!=256 ||
       raw_b_total!=512 || rope_b_total!=256 || scratch_b_total!=768 ||
       !scratch_last_b_hold || !scratch_aw_first || !scratch_w_first ||
       header_aux_ar_stalls<2 || rope_aux_ar_stalls<2 ||
       rope_bus_ar_stalls[0]<2 || rope_bus_ar_stalls[1]<2 ||
       row_written!==128'd3 || row_final!==128'd3 ||
       tensor_raw_valid || tensor_final_valid || tensor_failed)
      $fatal(1,"ROPE_TWO_ROW_COVERAGE_BAD W_AR=%0d/%0d/%0d table=%0d/%0d scratch=%0d/%0d RAW_B=%0d ROPE_B=%0d",
        ar_count[0],ar_count[1],ar_count[2],
        rope_aux_ar_total,rope_aux_r_total,rope_ar_total,rope_r_total,
        raw_b_total,rope_b_total);
    $display("ROPE_TWO_ROW_REAL_PASS rows=2 RAW_B=512 ROPE_B=256 scratch_R=256 table_R=64");
    tensor_release_discard=1;
    tensor_release_epoch=1;
    tensor_release_request=3;
    tensor_release_generation=1;
    @(negedge clk);tensor_release_valid=1;
    #1ps;if(!tensor_release_ready)$fatal(1,"ROPE_PARTIAL_DISCARD_NOT_READY");
    @(negedge clk);tensor_release_valid=0;
    if(row_written!=0 || row_final!=0 || tensor_final_valid ||
       tensor_raw_valid || dut.last_released_epoch!=2)
      $fatal(1,"ROPE_PARTIAL_DISCARD_BAD");
    $display("ROPE_PARTIAL_DISCARD_PASS next_epoch=3");
    $display("ROPE_QKV_ROWS_REAL_PASS");
    $finish;
  end
endmodule
