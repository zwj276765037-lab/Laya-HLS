`timescale 1ns/1ps
module laya_lnq_wi_gqdown_row_v1_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1;
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
  laya_lnq_wi_gqdown_row_v1 dut(.*);

  logic [63:0] wi_cfg[0:12],down_cfg[0:12];
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [511:0] wi_q0[0:41983],wi_q1[0:41983],wi_scale[0:5247];
  logic [511:0] down_q0[0:20991],down_q1[0:20991],down_scale[0:2623];
  logic [31:0] source[0:1023],ln_gold[0:1023],wi_final[0:5247];
  logic [31:0] g_gold[0:2623],down_final[0:1023],residual_gold[0:1023];
  logic [255:0] wi_q_gold[0:31],wi_ps_gold[0:20991];
  logic [255:0] down_q_gold[0:81],down_ps_gold[0:10495];
  logic [15:0] wi_scale_gold[0:31],down_scale_gold[0:81];
  string fixture;
  int cycle=0,x_index=0,ln_index=0,wi_q_index=0,down_q_index=0;
  int wi_ps_count=0,down_ps_count=0,g_count=0;
  int residual_accepted=0,residual_returned=0;
  int fp_launches=0;
  int issued[0:1][0:2],read_index[0:2],left[0:2],rslot[0:2];
  bit active[0:2];
  int ar_count[0:1][0:2],r_count[0:1][0:2],aux_ar_count=0,aux_r_count=0;
  bit aux_active=0,pilot;
  int aux_index=0,aux_left=0;
  int cmd_number=0;
  int progress_count=0;
  wire [2:0][31:0] active_bytes=dut.active_slot ? cmd_down_load_bytes : cmd_load_bytes;
  wire [2:0][63:0] active_base=dut.active_slot ? cmd_down_load_base : cmd_load_base;
  assign x_valid=drive_source && x_index<1024;
  assign x_bits=source[x_index<1024 ? x_index : 0];
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!active[p];rvalid[p]=active[p];rresp[p]=0;
      rdata[p]=rslot[p] ? (p==0 ? down_q0[read_index[p]] :
                             p==1 ? down_q1[read_index[p]] : down_scale[read_index[p]]) :
                            (p==0 ? wi_q0[read_index[p]] :
                             p==1 ? wi_q1[read_index[p]] : wi_scale[read_index[p]]);
      rlast[p]=active[p] && left[p]==1;
    end
    aux_arready=!aux_active;aux_rvalid=aux_active;
    aux_rdata=header_words[aux_index];aux_rresp=0;
    aux_rlast=aux_active && aux_left==1;
  end

  always @(posedge clk) if(!rst_n)begin
    cycle<=0;progress_count<=0;x_index<=0;ln_index<=0;wi_q_index<=0;down_q_index<=0;
    wi_ps_count<=0;down_ps_count<=0;g_count<=0;fp_launches<=0;
    residual_accepted<=0;residual_returned<=0;
    aux_active<=0;aux_index<=0;aux_left<=0;aux_ar_count<=0;aux_r_count<=0;
    for(int p=0;p<3;p++)begin
      active[p]<=0;read_index[p]<=0;left[p]<=0;rslot[p]<=0;
      for(int s=0;s<2;s++)begin issued[s][p]<=0;ar_count[s][p]<=0;r_count[s][p]<=0;end
    end
  end else begin : check
    int beats,page_beats,remain,g,t,l,idx,s;
    logic [511:0] word512;
    logic [255:0] expected_q;
    logic [15:0] expected_scale;
    cycle<=cycle+1;
    if((|(arvalid & arready)) || (|(rvalid & rready)) ||
       (aux_arvalid && aux_arready) || (aux_rvalid && aux_rready) ||
       (x_valid && x_ready) || dut.lnq.ln_out_fire ||
       dut.lnq.q_in_fire || dut.lnq.q_out_fire ||
       dut.issue_fire || (dut.front.commit_valid[0] && dut.front.commit_ready[0]) ||
       dut.g_issue || dut.g_commit ||
       dut.add_accept || dut.add_consume ||
       (dut.ln_rsp_valid && dut.lnq.rsp_ready) ||
       (rd_valid && rd_ready) || (rsp_valid && rsp_ready) ||
       (done_valid && done_ready)) progress_count<=progress_count+1;
    if(cycle%500==0)
      $display("FFR1_PROGRESS cfg=0 sar=0 sr=0 dar=0 dr=0 aa=0 ar=0 ac=0 aw=0 w=0 b=0 rsp=%0d",progress_count);
    if(cycle>1000000)$fatal(1,"GQDOWN_CYCLE_CAP state=%0d",dut.state);
    if(cycle%5000==0)
      $display("GQDOWN_PROGRESS cycle=%0d state=%0d slot=%0b group=%0d tile=%0d x=%0d WiPS=%0d G=%0d DownPS=%0d issue=%0d",
        cycle,dut.state,dut.active_slot,dut.group_no,dut.tile_no,x_index,wi_ps_count,g_count,down_ps_count,actual_stripes);
    if(dut.load_done)$display("GQDOWN_LOAD_DONE slot=%0b cycle=%0d error=%0b",dut.active_slot,cycle,dut.load_error);
    if(dut.g_returned==2624 && g_count==2624 && cycle%5000==0)
      $display("GQDOWN_G_DONE cycle=%0d issued=%0d returned=%0d",cycle,dut.g_issued,dut.g_returned);
    if(row_valid)$display("GQDOWN_ROW_VISIBLE cycle=%0d",cycle);
    if(x_valid && x_ready)x_index<=x_index+1;
    if(dut.front.row_issue_valid[0] && dut.front.row_ready[0])fp_launches<=fp_launches+1;
    if(dut.lnq.ln_out_fire)begin
      if(dut.lnq.ln_out_bits!==ln_gold[ln_index] || dut.lnq.ln_out_index!==10'(ln_index))
        $fatal(1,"LN_GOLD_MISMATCH index=%0d",ln_index);
      ln_index<=ln_index+1;
    end
    if(dut.ln_rsp_valid && dut.lnq.rsp_ready)begin
      if(dut.phase_down)begin
        if(down_q_index>=82 || dut.ln_rsp_group!==7'(down_q_index) ||
           dut.ln_rsp_q!==down_q_gold[down_q_index] ||
           dut.ln_rsp_scale!==down_scale_gold[down_q_index])
          $fatal(1,"DOWN_Q_GOLD_MISMATCH group=%0d got=%h expected=%h",down_q_index,dut.ln_rsp_q,down_q_gold[down_q_index]);
        down_q_index<=down_q_index+1;
      end else begin
        if(wi_q_index>=32 || dut.ln_rsp_group!==7'(wi_q_index) ||
           dut.ln_rsp_q!==wi_q_gold[wi_q_index] ||
           dut.ln_rsp_scale!==wi_scale_gold[wi_q_index])
          $fatal(1,"WI_Q_GOLD_MISMATCH group=%0d",wi_q_index);
        wi_q_index<=wi_q_index+1;
      end
    end
    for(int p=0;p<3;p++)begin
      if(arvalid[p] && arready[p])begin
        s=int'(dut.active_slot);
        if(active[p] || araddr[p]!=active_base[p]+issued[s][p] ||
           arsize[p]!=3'd6 || arburst[p]!=2'd1)
          $fatal(1,"W_AR_BAD slot=%0d port=%0d addr=%h expected=%h",s,p,araddr[p],active_base[p]+issued[s][p]);
        remain=(active_bytes[p]-issued[s][p])/64;
        page_beats=(4096-int'(araddr[p]%4096))/64;
        beats=remain<64 ? remain:64;
        if(beats>page_beats)beats=page_beats;
        if(beats<=0 || arlen[p]+1!=beats)$fatal(1,"W_AR_4K_BAD slot=%0d port=%0d",s,p);
        active[p]<=1;rslot[p]<=s;read_index[p]<=issued[s][p]/64;
        left[p]<=beats;issued[s][p]<=issued[s][p]+beats*64;
        ar_count[s][p]<=ar_count[s][p]+1;
      end
      if(rvalid[p] && rready[p])begin
        if(!active[p] || left[p]<=0 || rlast[p]!=(left[p]==1))$fatal(1,"W_R_LAST_BAD p=%0d",p);
        read_index[p]<=read_index[p]+1;left[p]<=left[p]-1;
        if(rlast[p])active[p]<=0;
        r_count[rslot[p]][p]<=r_count[rslot[p]][p]+1;
      end
    end
    if(aux_arvalid && aux_arready)begin
      if(aux_active || aux_araddr!=(dut.active_slot ? cmd_down_aux_base : cmd_aux_base) ||
         aux_arsize!=3'd4 || aux_arburst!=2'd1 || aux_arlen!=7 || aux_araddr[11:0]+128>4096)
        $fatal(1,"AUX_AR_BAD slot=%0d",dut.active_slot);
      aux_active<=1;aux_index<=0;aux_left<=8;aux_ar_count<=aux_ar_count+1;
    end
    if(aux_rvalid && aux_rready)begin
      if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))$fatal(1,"AUX_R_LAST_BAD");
      aux_index<=aux_index+1;aux_left<=aux_left-1;
      if(aux_rlast)aux_active<=0;
      aux_r_count<=aux_r_count+1;
    end
    if(dut.ret_valid && dut.ret_ready && dut.ret_ok)begin
      g=int'(dut.group_no);t=int'(dut.tile_no);s=int'(dut.active_slot);
      for(l=0;l<8;l++)begin
        idx=(t/2)*(s ? 82 : 32)*4+g*4+l/2;
        word512=s ? (t[0] ? down_q1[idx] : down_q0[idx]) :
                    (t[0] ? wi_q1[idx] : wi_q0[idx]);
        expected_q=word512[(l%2)*256+:256];
        idx=(t*(s ? 82 : 32)+g)*8+l;
        word512=s ? down_scale[idx/32] : wi_scale[idx/32];
        expected_scale=word512[(idx%32)*16+:16];
        if(dut.ret_q[0][l]!==expected_q || dut.ret_scale[0][l]!==expected_scale || !dut.ret_mask[0][l])
          $fatal(1,"W_BANK_MISMATCH slot=%0d g=%0d t=%0d lane=%0d",s,g,t,l);
      end
    end
    if(dut.front.commit_valid[0] && dut.front.commit_ready[0])begin
      g=int'({dut.commit_tag[160],dut.commit_tag[11+:6]});
      t=int'(dut.commit_tile[9:0]);
      if(dut.phase_down)begin
        if(g>=82 || t>=128 || dut.commit_next_ps[255:0]!==down_ps_gold[g*128+t])
          $fatal(1,"DOWN_PS_GOLD_MISMATCH g=%0d t=%0d got=%h exp=%h",g,t,dut.commit_next_ps[255:0],down_ps_gold[g*128+t]);
        down_ps_count<=down_ps_count+1;
      end else begin
        if(g>=32 || t>=656 || dut.commit_next_ps[255:0]!==wi_ps_gold[g*656+t])
          $fatal(1,"WI_PS_GOLD_MISMATCH g=%0d t=%0d",g,t);
        wi_ps_count<=wi_ps_count+1;
      end
    end
    if(dut.g_commit)begin
      if(g_count>=2624 || dut.g_status!=0 || dut.g_data!==g_gold[g_count])
        $fatal(1,"G_GOLD_MISMATCH index=%0d got=%h exp=%h status=%h",g_count,dut.g_data,g_gold[g_count],dut.g_status);
      g_count<=g_count+1;
    end
    if(dut.g_issue)begin
      idx=int'(dut.g_issued);
      if(idx>=2624 || dut.g_x_hold[dut.g_lane*32+:32]!==wi_final[idx] ||
         dut.g_gate_hold[dut.g_lane*32+:32]!==wi_final[2624+idx] ||
         dut.g_gate_tile!==10'(328+idx/8))
        $fatal(1,"G_INPUT_BINDING_MISMATCH index=%0d gate_tile=%0d expected_tile=%0d x=%h/%h gate=%h/%h",
          idx,dut.g_gate_tile,328+idx/8,
          dut.g_x_hold[dut.g_lane*32+:32],wi_final[idx],
          dut.g_gate_hold[dut.g_lane*32+:32],wi_final[2624+idx]);
      if(idx==1471 || idx==1472 || idx==1479 || idx==1480 || idx==2623)
        $display("G_INPUT_BOUNDARY_PASS index=%0d gate_tile=%0d x=%h gate=%h",
          idx,dut.g_gate_tile,wi_final[idx],wi_final[2624+idx]);
    end
    if(dut.add_accept)begin
      idx=residual_accepted;
      if(idx>=1024 || dut.res_ordinal!==10'(idx) ||
         dut.res_a_hold!==source[idx] || dut.res_b_hold!==down_final[idx])
        $fatal(1,"RESIDUAL_INPUT_MISMATCH index=%0d a=%h/%h b=%h/%h",
          idx,dut.res_a_hold,source[idx],dut.res_b_hold,down_final[idx]);
      residual_accepted<=residual_accepted+1;
    end
    if(dut.add_consume)begin
      idx=residual_returned;
      if(idx>=1024 || dut.add_bits!==residual_gold[idx])
        $fatal(1,"RESIDUAL_GOLD_MISMATCH index=%0d got=%h expected=%h",
          idx,dut.add_bits,residual_gold[idx]);
      residual_returned<=residual_returned+1;
    end
  end

  task automatic start_cmd(input bit cold,input int new_id);
    @(negedge clk);cmd_cold=cold;cmd_id=32'(new_id);
    cmd_task_context={8'd1,16'd0,8'd128,8'd1,8'd0,8'd0,8'd1,32'(new_id)};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"GQDOWN_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;drive_source=1;cmd_number=new_id;
    x_index=0;ln_index=0;wi_q_index=0;down_q_index=0;
    wi_ps_count=0;down_ps_count=0;g_count=0;
    residual_accepted=0;residual_returned=0;
  endtask

  task automatic reset_probe(input bit at_g);
    bit reached;
    int prior_issue,prior_commit,prior_g_issue,prior_g_return;
    reached=0;
    start_cmd(1,at_g ? 50 : 40);
    for(int guard=0;guard<1000000 && !reached;guard++)begin
      @(negedge clk);
      if(at_g)
        reached=dut.g_issued>=2 && dut.g_returned==0 && dut.g_credits>=2;
      else
        reached=fp_launches>=2 && dut.front.result_reserved[5:0]!=0 &&
                actual_ps_commits<actual_stripes;
    end
    if(!reached || row_valid || done_valid ||
       active[0] || active[1] || active[2] || aux_active)
      $fatal(1,"GQDOWN_RESET_TRIGGER_MISSING phase=%0d state=%0d FP=%0d G=%0d/%0d",
        at_g,dut.state,fp_launches,dut.g_issued,dut.g_returned);
    prior_issue=actual_stripes;prior_commit=actual_ps_commits;
    prior_g_issue=dut.g_issued;prior_g_return=dut.g_returned;
    $display("GQDOWN_RESET_PRE phase=%0d cmd=%0d state=%0d issue=%0d commit=%0d FP=%0d reserved=%0d G=%0d/%0d credits=%0d W=%0d/%0d",
      at_g,cmd_number,dut.state,prior_issue,prior_commit,fp_launches,
      dut.front.result_reserved[5:0],prior_g_issue,prior_g_return,dut.g_credits,
      actual_w_reads,actual_w_returns);
    drive_source=0;rst_n=0;
    repeat(3)@(negedge clk);
    rst_n=1;
    repeat(510)begin
      @(negedge clk);
      if(row_valid || done_valid || dut.front_protocol || dut.g_commit ||
         dut.front.commit_valid[0] || actual_stripes!=0 ||
         actual_ps_commits!=0 || dut.g_credits!=0 ||
         dut.slot_readers[0]!=0 || dut.slot_readers[1]!=0)
        $fatal(1,"GQDOWN_RESET_GHOST phase=%0d cycle=%0d",at_g,cycle);
    end
    $display("GQDOWN_RESET_ISOLATED phase=%0d quarantine=510 cycle=%0d",at_g,cycle);
    if(at_g)begin
      $display("GQDOWN_RESET_G_INFLIGHT_PASS issued=%0d returned=%0d",prior_g_issue,prior_g_return);
      $finish;
    end
    if(!$test$plusargs("RESET_WI_RECOVER"))begin
      $display("GQDOWN_RESET_WI_INFLIGHT_PASS issue=%0d commit=%0d",prior_issue,prior_commit);
      $finish;
    end
    start_cmd(1,41);
    for(int guard=0;guard<1000000 && actual_ps_commits<16;guard++)@(negedge clk);
    if(actual_ps_commits<16 || wi_ps_count<16 || x_index!=1024 ||
       ln_index!=1024 || row_valid || done_valid || dut.front_protocol)
      $fatal(1,"GQDOWN_RESET_WI_RECOVERY_PREFIX_BAD PS=%0d/%0d x=%0d ln=%0d",
        actual_ps_commits,wi_ps_count,x_index,ln_index);
    $display("GQDOWN_RESET_WI_PREFIX_PASS pre_issue=%0d pre_commit=%0d recovery_PS=%0d cycle=%0d",
      prior_issue,prior_commit,wi_ps_count,cycle);
    $finish;
  endtask

  task automatic read_row(input bit reverse_order);
    int tile;
    for(int n=0;n<128;n++)begin
      tile=reverse_order ? 127-n : n;
      @(negedge clk);rd_tile=10'(tile);rd_valid=1;
      #1ps;if(!rd_ready)$fatal(1,"RESULT_RD_NOT_READY tile=%0d",tile);
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<5 && !rsp_valid;guard++)@(negedge clk);
      if(!rsp_valid || rsp_tile!==10'(tile))$fatal(1,"RESULT_RSP_BAD tile=%0d",tile);
      repeat(2)begin
        @(negedge clk);
        if(!rsp_valid || rsp_tile!==10'(tile))$fatal(1,"RESULT_HOLD_BAD tile=%0d",tile);
      end
      for(int lane=0;lane<8;lane++)
        if(rsp_bits[lane*32+:32]!==residual_gold[tile*8+lane])
          $fatal(1,"RESIDUAL_FINAL_MISMATCH col=%0d got=%h exp=%h",tile*8+lane,rsp_bits[lane*32+:32],residual_gold[tile*8+lane]);
      rsp_ready=1;@(negedge clk);rsp_ready=0;
    end
    @(negedge clk);row_release_valid=1;
    #1ps;if(!row_release_ready)$fatal(1,"RESULT_RELEASE_BLOCKED");
    @(negedge clk);row_release_valid=0;
  endtask

  task automatic finish_cmd(input bit reverse_order);
    for(int guard=0;guard<1000000 && !row_valid && !done_valid;guard++)@(negedge clk);
    if(!row_valid || done_valid || done_status!=0)
      $fatal(1,"GQDOWN_NOT_PUBLISHED cmd=%0d status=%0d phase=%0d state=%0d WiPS=%0d G=%0d DownPS=%0d",
             cmd_number,done_status,done_phase,dut.state,wi_ps_count,g_count,down_ps_count);
    drive_source=0;
    if(x_index!=1024 || ln_index!=1024 || wi_q_index!=32 || wi_ps_count!=20992 ||
       g_count!=2624 || down_q_index!=82 || down_ps_count!=10496 ||
       actual_w_reads!=31488 || actual_w_returns!=31488 ||
       actual_stripes!=31488 || actual_ps_commits!=31488 ||
       residual_accepted!=1024 || residual_returned!=1024 ||
       dut.skip_count!=11'd1024 || dut.res_written!=11'd1024)
      $fatal(1,"GQDOWN_CONSERVATION cmd=%0d x=%0d ln=%0d wiq=%0d wips=%0d g=%0d dq=%0d dps=%0d W=%0d/%0d issue=%0d PS=%0d",
        cmd_number,x_index,ln_index,wi_q_index,wi_ps_count,g_count,down_q_index,down_ps_count,
        actual_w_reads,actual_w_returns,actual_stripes,actual_ps_commits);
    read_row(reverse_order);
    for(int guard=0;guard<5 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_phase!=4'd7 || done_bad_element!=32'hffffffff)
      $fatal(1,"GQDOWN_DONE_BAD cmd=%0d status=%0d phase=%0d",cmd_number,done_status,done_phase);
    done_ready=1;@(negedge clk);done_ready=0;
    $display("GQDOWN_CMD_PASS cmd=%0d cycle=%0d WiPS=%0d G=%0d DownPS=%0d ARWi=%0d/%0d/%0d ARDown=%0d/%0d/%0d AUX=%0d",
      cmd_number,cycle,wi_ps_count,g_count,down_ps_count,
      ar_count[0][0],ar_count[0][1],ar_count[0][2],
      ar_count[1][0],ar_count[1][1],ar_count[1][2],aux_ar_count);
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE_REQUIRED");
    pilot=$test$plusargs("PILOT");
    $readmemh({fixture,"/wi_config.hex"},wi_cfg);
    $readmemh({fixture,"/down_config.hex"},down_cfg);
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/wi_q0.hex"},wi_q0);
    $readmemh({fixture,"/wi_q1.hex"},wi_q1);
    $readmemh({fixture,"/wi_scale.hex"},wi_scale);
    $readmemh({fixture,"/down_q0.hex"},down_q0);
    $readmemh({fixture,"/down_q1.hex"},down_q1);
    $readmemh({fixture,"/down_scale.hex"},down_scale);
    $readmemh({fixture,"/ln_source_row0.hex"},source);
    $readmemh({fixture,"/ln_gold_row0.hex"},ln_gold);
    $readmemh({fixture,"/q_row0.hex"},wi_q_gold);
    $readmemh({fixture,"/scale_row0.hex"},wi_scale_gold);
    $readmemh({fixture,"/ps_row0.hex"},wi_ps_gold);
    $readmemh({fixture,"/final_row0.hex"},wi_final);
    $readmemh({fixture,"/g_row0.hex"},g_gold);
    $readmemh({fixture,"/down_q_row0.hex"},down_q_gold);
    $readmemh({fixture,"/down_scale_row0.hex"},down_scale_gold);
    $readmemh({fixture,"/down_ps_row0.hex"},down_ps_gold);
    $readmemh({fixture,"/down_final_row0.hex"},down_final);
    $readmemh({fixture,"/residual_row0.hex"},residual_gold);
    $display("GQDOWN_FIXTURES_READY time=%0t",$time);
    $display("FFR1_SIM_START");
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_expected_aux_header=header_rom[0];
    cmd_down_expected_aux_header=header_rom[0];
    for(int p=0;p<3;p++)begin
      cmd_load_base[p]=wi_cfg[3+p];cmd_load_bytes[p]=wi_cfg[6+p][31:0];
      cmd_down_load_base[p]=down_cfg[3+p];cmd_down_load_bytes[p]=down_cfg[6+p][31:0];
    end
    cmd_weight_key=wi_cfg[2][15:0];cmd_down_weight_key=down_cfg[2][15:0];
    cmd_bias_base=wi_cfg[9];cmd_bias_bytes=wi_cfg[10][31:0];
    cmd_down_bias_base=down_cfg[9];cmd_down_bias_bytes=down_cfg[10][31:0];
    repeat(5)@(negedge clk);rst_n=1;
    if($test$plusargs("RESET_WI"))reset_probe(0);
    if($test$plusargs("RESET_G"))reset_probe(1);
    start_cmd(1,1);
    if(pilot)begin
      for(int guard=0;guard<1000000 && actual_stripes<256;guard++)@(negedge clk);
      if(actual_stripes<256)$fatal(1,"GQDOWN_PILOT_NO_PREFIX");
      $display("GQDOWN_PILOT_PASS cycle=%0d WiPS=%0d W=%0d/%0d ARWi=%0d/%0d/%0d ARDown=%0d/%0d/%0d AUX=%0d",
        cycle,wi_ps_count,actual_w_reads,actual_w_returns,
        ar_count[0][0],ar_count[0][1],ar_count[0][2],
        ar_count[1][0],ar_count[1][1],ar_count[1][2],aux_ar_count);
      $finish;
    end
    finish_cmd(0);
    start_cmd(0,2);
    finish_cmd(1);
    $display("GQDOWN_FULL_PASS cold=1 warm=1 gold=AT040_v4_row0_G_and_Down_independent");
    $finish;
  end
endmodule
