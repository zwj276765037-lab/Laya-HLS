`timescale 1ns/1ps
module laya_embedding_qkv_row_v1_tb;
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
  laya_lnq_wi_gqdown_row_v1 dut(.*, .cmd_prepared_source(1'b0), .cmd_source_epoch('0),
    .prep_begin_valid(1'b0), .prep_begin_ready(), .prep_id('0),
    .prep_row('0), .prep_epoch('0), .prep_write_valid(1'b0),
    .prep_write_ready(), .prep_write_index('0), .prep_write_bits('0),
    .prep_commit_valid(1'b0), .prep_commit_ready(),
    .prep_abort_valid(1'b0), .prep_abort_ready(),
    .prep_token_valid(), .prep_fault());

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
  string fixture;
  bit drive_source=0,aux_active=0,active[0:2],held_ar[0:2],held_aux=0;
  bit x_hold=0,gamma_hold=0,r_hold[0:2],aux_r_hold=0;
  logic [63:0] held_addr[0:2],held_aux_addr;
  logic [7:0] held_len[0:2],held_aux_len;
  logic [2:0] held_size[0:2],held_aux_size;
  logic [1:0] held_burst[0:2],held_aux_burst;
  int global_cycle=0,source_idx=0,gamma_idx=0,norm_idx=0,q_idx=0,ps_idx=0;
  int fp_a_count=0,fp_product_count=0,fp_term_count=0;
  int issued[0:2],read_index[0:2],left[0:2],ar_count[0:2],r_count[0:2];
  int ar_blocks[0:2],aux_blocks=0,aux_idx=0,aux_left=0,aux_ar_count=0,aux_r_count=0;
  int r_gaps[0:2],aux_gaps=0,x_gaps=0,gamma_gaps=0;
  int current_row=0;
  wire [2:0][31:0] active_bytes=cmd_load_bytes;
  wire [2:0][63:0] active_base=cmd_load_base;

  assign x_valid=drive_source && source_idx<1024 &&
    (global_cycle%13!=0 || x_hold);
  assign x_bits=raw[current_row*1024+(source_idx<1024 ? source_idx : 0)];
  assign gamma_valid=drive_source && gamma_idx<1024 &&
    (global_cycle%17!=0 || gamma_hold);
  assign gamma_bits=gamma[gamma_idx<1024 ? gamma_idx : 0];
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!active[p] && ar_blocks[p]>=2;
      rvalid[p]=active[p] && (global_cycle%11!=p || r_hold[p]);
      rresp[p]=0;
      rdata[p]=p==0 ? w_q0[read_index[p]] :
               p==1 ? w_q1[read_index[p]] : w_scale[read_index[p]];
      rlast[p]=active[p] && left[p]==1;
    end
    aux_arready=!aux_active && aux_blocks>=2;
    aux_rvalid=aux_active && (global_cycle%17!=0 || aux_r_hold);
    aux_rdata=header_words[aux_idx];aux_rresp=0;
    aux_rlast=aux_active && aux_left==1;
  end

  always @(posedge clk) if(!rst_n)begin
    global_cycle<=0;source_idx<=0;gamma_idx<=0;norm_idx<=0;q_idx<=0;ps_idx<=0;
    fp_a_count<=0;fp_product_count<=0;fp_term_count<=0;
    aux_active<=0;aux_idx<=0;aux_left<=0;aux_blocks<=0;aux_ar_count<=0;
    aux_r_count<=0;held_aux<=0;aux_r_hold<=0;
    x_hold<=0;gamma_hold<=0;x_gaps<=0;gamma_gaps<=0;aux_gaps<=0;
    for(int p=0;p<3;p++)begin
      active[p]<=0;read_index[p]<=0;left[p]<=0;issued[p]<=0;
      ar_count[p]<=0;r_count[p]<=0;ar_blocks[p]<=0;held_ar[p]<=0;
      r_hold[p]<=0;r_gaps[p]<=0;
    end
  end else begin : monitor
    int remaining,beats,page_beats,g,t,l,idx;
    logic [511:0] word512;
    global_cycle<=global_cycle+1;
    if(global_cycle>=1000000)$fatal(1,"QKV_GLOBAL_CYCLE_CAP");
    if(global_cycle%5000==0)
      $display("QKV_PROGRESS global=%0d row=%0d state=%0d group=%0d tile=%0d issue=%0d commit=%0d W=%0d/%0d",
        global_cycle,current_row,dut.state,dut.group_no,dut.tile_no,
        actual_stripes,actual_ps_commits,actual_w_reads,actual_w_returns);
    if(drive_source && source_idx<1024 && !x_valid)x_gaps<=x_gaps+1;
    if(drive_source && gamma_idx<1024 && !gamma_valid)gamma_gaps<=gamma_gaps+1;
    if(x_valid && !x_ready)x_hold<=1;
    if(x_valid && x_ready)begin source_idx<=source_idx+1;x_hold<=0;end
    if(gamma_valid && !gamma_ready)gamma_hold<=1;
    if(gamma_valid && gamma_ready)begin gamma_idx<=gamma_idx+1;gamma_hold<=0;end
    if(dut.norm_valid)begin
      if(norm_idx>=1024 || dut.norm_index!==10'(norm_idx) ||
         dut.norm_bits!==norm_gold[current_row*1024+norm_idx])
        $fatal(1,"QKV_NORM_MISMATCH row=%0d index=%0d",current_row,norm_idx);
      norm_idx<=norm_idx+1;
    end
    if(dut.ln_rsp_valid && dut.lnq.rsp_ready)begin
      if(q_idx>=32 || dut.ln_rsp_group!==7'(q_idx) ||
         dut.ln_rsp_q!==q_gold[current_row*32+q_idx] ||
         dut.ln_rsp_scale!==scale_gold[current_row*32+q_idx])
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
        if(active[p] || araddr[p]!=active_base[p]+issued[p] ||
           arsize[p]!=3'd6 || arburst[p]!=2'd1)
          $fatal(1,"QKV_W_AR_BAD port=%0d addr=%h",p,araddr[p]);
        remaining=(active_bytes[p]-issued[p])/64;
        page_beats=(4096-int'(araddr[p]%4096))/64;
        beats=remaining<64 ? remaining:64;
        if(beats>page_beats)beats=page_beats;
        if(beats<=0 || arlen[p]+1!=beats)$fatal(1,"QKV_W_AR_4K_BAD port=%0d",p);
        active[p]<=1;read_index[p]<=issued[p]/64;left[p]<=beats;
        issued[p]<=issued[p]+beats*64;ar_count[p]<=ar_count[p]+1;held_ar[p]<=0;
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
    end
    if(aux_arvalid && aux_arready)begin
      if(aux_active || aux_araddr!=cmd_aux_base || aux_arsize!=3'd4 ||
         aux_arburst!=2'd1 || aux_arlen!=7)
        $fatal(1,"QKV_AUX_AR_BAD");
      aux_active<=1;aux_idx<=0;aux_left<=8;aux_ar_count<=aux_ar_count+1;
      held_aux<=0;
    end
    if(aux_rvalid && aux_rready)begin
      if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
        $fatal(1,"QKV_AUX_R_BAD");
      aux_idx<=aux_idx+1;aux_left<=aux_left-1;
      if(aux_rlast)aux_active<=0;
      aux_r_count<=aux_r_count+1;aux_r_hold<=0;
    end
    if(dut.ret_valid && dut.ret_ready && dut.ret_ok)begin
      g=int'(dut.group_no);t=int'(dut.tile_no);
      for(l=0;l<8;l++)begin
        idx=(t/2)*32*4+g*4+l/2;
        word512=t[0] ? w_q1[idx] : w_q0[idx];
        if(dut.ret_q[0][l]!==word512[(l%2)*256+:256] ||
           dut.ret_scale[0][l]!==w_scale[(t*32+g)*8/32][((t*32+g)*8+l)%32*16+:16] ||
           !dut.ret_mask[0][l])
          $fatal(1,"QKV_W_BANK_MISMATCH row=%0d g=%0d t=%0d lane=%0d",current_row,g,t,l);
      end
    end
    if(dut.front.commit_valid[0] && dut.front.commit_ready[0])begin
      g=int'({dut.commit_tag[160],dut.commit_tag[11+:6]});
      t=int'(dut.commit_tile[9:0]);
      if(g>=32 || t>=384 || ps_idx>=12288 ||
         dut.commit_next_ps[255:0]!==ps_gold[current_row*12288+g*384+t])
        $fatal(1,"QKV_PS_MISMATCH row=%0d group=%0d tile=%0d",current_row,g,t);
      ps_idx<=ps_idx+1;
    end
    if(dut.front.row[0].arithmetic.fp_restore.valid_a)begin
      g=int'({dut.front.row[0].arithmetic.fp_restore.tag_a[160],
              dut.front.row[0].arithmetic.fp_restore.tag_a[16:11]});
      t=int'({dut.front.row[0].arithmetic.fp_restore.tag_a[161],
              dut.front.row[0].arithmetic.fp_restore.tag_a[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_a_count>=12288 ||
         dut.front.row[0].arithmetic.fp_restore.dot_a!==step0_gold[idx] ||
         dut.front.row[0].arithmetic.fp_restore.sa_a!==step1_gold[idx][31:0] ||
         dut.front.row[0].arithmetic.fp_restore.sw_a!==step2_gold[idx])
        $fatal(1,"QKV_FP_INPUT_STEPS_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_a_count<=fp_a_count+1;
    end
    if(dut.front.row[0].arithmetic.fp_restore.valid_c)begin
      g=int'({dut.front.row[0].arithmetic.fp_restore.meta_c.tag[160],
              dut.front.row[0].arithmetic.fp_restore.meta_c.tag[16:11]});
      t=int'({dut.front.row[0].arithmetic.fp_restore.meta_c.tag[161],
              dut.front.row[0].arithmetic.fp_restore.meta_c.tag[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_product_count>=12288 ||
         dut.front.row[0].arithmetic.fp_restore.scale_product_c!==step3_gold[idx])
        $fatal(1,"QKV_FP_PRODUCT_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_product_count<=fp_product_count+1;
    end
    if(dut.front.row[0].arithmetic.fp_restore.valid_add)begin
      g=int'({dut.front.row[0].arithmetic.fp_restore.tag_add[160],
              dut.front.row[0].arithmetic.fp_restore.tag_add[16:11]});
      t=int'({dut.front.row[0].arithmetic.fp_restore.tag_add[161],
              dut.front.row[0].arithmetic.fp_restore.tag_add[25:17]});
      idx=current_row*12288+g*384+t;
      if(g>=32 || t>=384 || fp_term_count>=12288 ||
         dut.front.row[0].arithmetic.fp_restore.term_add!==step4_gold[idx])
        $fatal(1,"QKV_FP_TERM_MISMATCH row=%0d g=%0d t=%0d",current_row,g,t);
      fp_term_count<=fp_term_count+1;
    end
    if(dut.g_issue || dut.g_commit || dut.add_accept || dut.add_consume)
      $fatal(1,"QKV_FFN_SERVICE_STARTED");
  end

  task automatic start_qkv(input bit cold,input int row);
    @(negedge clk);
    current_row=row;source_idx=0;gamma_idx=0;norm_idx=0;q_idx=0;ps_idx=0;
    fp_a_count=0;fp_product_count=0;fp_term_count=0;
    cmd_id=32'(81+row);cmd_mode=1;cmd_row=7'(row);cmd_cold=cold;
    cmd_task_context={8'd1,16'(row),8'd128,8'd1,8'd0,8'd0,8'd1,32'(81+row)};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"QKV_CMD_NOT_READY row=%0d",row);
    $display("QKV_CMD_ACCEPT row=%0d cold=%0d global=%0d",row,cold,global_cycle);
    @(negedge clk);cmd_valid=0;drive_source=1;
  endtask

  task automatic consume_row(input int row,input bit reverse_order);
    int tile,col;
    logic [255:0] held_bits;
    for(int n=0;n<514;n++)begin
      tile=n<512 ? (reverse_order ? 511-n : n) : (n==512 ? 0 : 511);
      @(negedge clk);rd_tile=10'(tile);rd_valid=1;
      #1ps;if(!rd_ready)$fatal(1,"QKV_READ_NOT_READY tile=%0d",tile);
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<5 && !rsp_valid;guard++)@(negedge clk);
      if(!rsp_valid || rsp_tile!==10'(tile) || result_mode!==1 || result_row!==7'(row))
        $fatal(1,"QKV_RSP_BAD tile=%0d",tile);
      held_bits=rsp_bits;
      repeat(2)begin
        @(negedge clk);
        if(!rsp_valid || rsp_tile!==10'(tile) || rsp_bits!==held_bits ||
           result_mode!==1 || result_row!==7'(row))
          $fatal(1,"QKV_RSP_HOLD_BAD tile=%0d",tile);
      end
      for(int lane=0;lane<8;lane++)begin
        col=tile*8+lane;
        if(rsp_bits[lane*32+:32]!==
           (tile<384 ? final_gold[row*3072+col] :
             norm_gold[row*1024+(tile-384)*8+lane]))
          $fatal(1,"QKV_FINAL_MISMATCH row=%0d tile=%0d lane=%0d",row,tile,lane);
      end
      rsp_ready=1;@(negedge clk);rsp_ready=0;
    end
    @(negedge clk);row_release_valid=1;rd_valid=1;rd_tile=0;
    #1ps;if(!row_release_ready || rd_ready)$fatal(1,"QKV_RELEASE_PRIORITY_BAD");
    @(negedge clk);row_release_valid=0;rd_valid=0;
  endtask

  task automatic finish_qkv(input int row,input bit reverse_order);
    for(int guard=0;guard<200000 && !row_valid && !done_valid;guard++)@(negedge clk);
    if(!row_valid || done_valid || done_status!=0 || result_mode!==1 ||
       result_row!==7'(row) || source_idx!=1024 || gamma_idx!=1024 ||
       norm_idx!=1024 || q_idx!=32 || ps_idx!=12288 ||
       fp_a_count!=12288 || fp_product_count!=12288 || fp_term_count!=12288 ||
       actual_w_reads!=12288 || actual_w_returns!=12288 ||
       actual_stripes!=12288 || actual_ps_commits!=12288 ||
       dut.norm_count!=1024 || dut.slot_readers[0]!=0 ||
       dut.slot_state[0]!=3'd2)
      $fatal(1,"QKV_ROW_INCOMPLETE row=%0d state=%0d status=%0d phase=%0d norm=%0d Q=%0d PS=%0d W=%0d/%0d",
        row,dut.state,done_status,done_phase,norm_idx,q_idx,ps_idx,actual_w_reads,actual_w_returns);
    $display("QKV_ROW_VISIBLE row=%0d global=%0d W=%0d/%0d PS=%0d AR=%0d/%0d/%0d AUX=%0d",
      row,global_cycle,actual_w_reads,actual_w_returns,ps_idx,
      ar_count[0],ar_count[1],ar_count[2],aux_ar_count);
    drive_source=0;
    consume_row(row,reverse_order);
    for(int guard=0;guard<10 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_phase!=4'd7 ||
       done_bad_element!=32'hffffffff || result_mode!==1 || result_row!==7'(row))
      $fatal(1,"QKV_DONE_BAD row=%0d status=%0d phase=%0d",row,done_status,done_phase);
    $display("QKV_DONE row=%0d global=%0d",row,global_cycle);
    done_ready=1;@(negedge clk);done_ready=0;
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"QKV_FIXTURE_REQUIRED");
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
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_expected_aux_header=header_rom[0];
    cmd_load_base[0]=64'h3800000;cmd_load_base[1]=64'h3800000;
    cmd_load_base[2]=64'h700000;
    cmd_load_bytes[0]=32'd1572864;cmd_load_bytes[1]=32'd1572864;
    cmd_load_bytes[2]=32'd196608;
    repeat(5)@(negedge clk);rst_n=1;
    start_qkv(1,0);
    if($test$plusargs("LEGACY_LN_BOUNDARY"))begin
      for(int guard=0;guard<100000 && norm_idx<1024 && !done_valid;guard++)
        @(negedge clk);
      if(norm_idx!=1024 || source_idx!=1024 || gamma_idx!=1024 ||
         dut.source_prepared || done_valid || dut.prep_token_valid ||
         dut.prep_active)
        $fatal(1,"LEGACY_EXTERNAL_LN_BAD raw=%0d gamma=%0d norm=%0d",
          source_idx,gamma_idx,norm_idx);
      $display("LEGACY_EXTERNAL_LN_PASS raw=1024 gamma=1024 norm=1024 global=%0d",
        global_cycle);
      $finish;
    end
    if($test$plusargs("PILOT"))begin
      for(int guard=0;guard<200000 && actual_stripes<256 && !done_valid;guard++)@(negedge clk);
      if(actual_stripes<256 || done_valid || ar_blocks[0]<2 || aux_blocks<2)
        $fatal(1,"QKV_PILOT_NO_PREFIX stripes=%0d status=%0d",actual_stripes,done_status);
      $display("QKV_PILOT_PASS global=%0d issue=%0d PS=%0d W=%0d/%0d AR=%0d/%0d/%0d AUX=%0d",
        global_cycle,actual_stripes,ps_idx,actual_w_reads,actual_w_returns,
        ar_count[0],ar_count[1],ar_count[2],aux_ar_count);
      $finish;
    end
    finish_qkv(0,0);
    start_qkv(0,1);
    finish_qkv(1,1);
    if(ar_count[0]!=384 || ar_count[1]!=384 || ar_count[2]!=48 ||
       r_count[0]!=24576 || r_count[1]!=24576 || r_count[2]!=3072 ||
       aux_ar_count!=1 || aux_r_count!=8 ||
       ar_blocks[0]<2 || ar_blocks[1]<2 || ar_blocks[2]<2 || aux_blocks<2 ||
       r_gaps[0]==0 || r_gaps[1]==0 || r_gaps[2]==0 || aux_gaps==0 ||
       x_gaps==0 || gamma_gaps==0)
      $fatal(1,"QKV_COLD_WARM_AR_BAD ar=%0d/%0d/%0d r=%0d/%0d/%0d aux=%0d/%0d",
        ar_count[0],ar_count[1],ar_count[2],r_count[0],r_count[1],r_count[2],aux_ar_count,aux_r_count);
    $display("QKV_ROW_COLD_WARM_PASS rows=2 norm=2048 six_field_lane_groups=196608 final=6144 W_AR=384/384/48 W_R=24576/24576/3072 AUX=1/8");
    $finish;
  end
endmodule
