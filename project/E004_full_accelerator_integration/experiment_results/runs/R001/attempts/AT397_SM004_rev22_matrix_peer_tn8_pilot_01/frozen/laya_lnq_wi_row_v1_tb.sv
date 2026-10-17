`timescale 1ns/1ps
module laya_lnq_wi_row_v1_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready;
  logic [31:0] cmd_id=0,cmd_w_epoch=1;
  logic cmd_cold=1;
  logic [15:0] cmd_weight_key=3;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0;
  logic [31:0] cmd_bias_bytes=0;
  logic x_valid,x_ready;
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
  laya_lnq_wi_row_v1 dut (.*);

  logic [63:0] cfg[0:12];
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [511:0] wi_q0[0:41983],wi_q1[0:41983],wi_scale[0:5247];
  logic [31:0] source[0:1023],ln_gold[0:1023],final_gold[0:5247];
  logic [255:0] q_gold[0:31],ps_gold[0:20991];
  logic [15:0] scale_gold[0:31];
  string fixture;
  int cycle=0,x_index=0,ln_index=0,q_index=0,ps_count=0;
  int q_issued[0:2],q_read_index[0:2],q_left[0:2];
  bit q_active[0:2];
  int ar_count[0:2],r_count[0:2],aux_ar_count=0,aux_r_count=0;
  bit aux_active=0,drive_source=0;
  int aux_index=0,aux_left=0,cmd_number=0;
  bit pilot,prefix_diag;
  wire [2:0][31:0] q_bytes=cmd_load_bytes;
  assign x_valid=drive_source && x_index<1024;
  assign x_bits=source[x_index<1024 ? x_index:0];
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!q_active[p];
      rvalid[p]=q_active[p];
      rdata[p]=p==0 ? wi_q0[q_read_index[p]] :
               p==1 ? wi_q1[q_read_index[p]] : wi_scale[q_read_index[p]];
      rresp[p]=0;
      rlast[p]=q_active[p] && q_left[p]==1;
    end
    aux_arready=!aux_active;
    aux_rvalid=aux_active;
    aux_rdata=header_words[aux_index];
    aux_rresp=0;
    aux_rlast=aux_active && aux_left==1;
  end

  always @(posedge clk) if(!rst_n)begin
    cycle<=0;x_index<=0;ln_index<=0;q_index<=0;ps_count<=0;
    aux_active<=0;aux_index<=0;aux_left<=0;aux_ar_count<=0;aux_r_count<=0;
    for(int p=0;p<3;p++)begin
      q_active[p]<=0;q_issued[p]<=0;q_read_index[p]<=0;q_left[p]<=0;
      ar_count[p]<=0;r_count[p]<=0;
    end
  end else begin : scoreboard
    int beats,page_beats,remain,g,t,l,idx;
    logic [511:0] word512;
    logic [255:0] expected_q;
    logic [15:0] expected_scale;
    cycle<=cycle+1;
    if(dut.front_protocol)
      $fatal(1,"Wi normal front protocol failure state=%0d issue=%0d",dut.state,actual_stripes);
    if((pilot || prefix_diag) && cycle%5000==0)
      $display("LNQ_WI_PROGRESS cycle=%0d state=%0d load_done=%0b qR=%0d/%0d/%0d x=%0d q=%0d issue=%0d PS=%0d",
        cycle,dut.state,dut.load_done,r_count[0],r_count[1],r_count[2],
        x_index,q_index,actual_stripes,ps_count);
    if(cycle>1000000)$fatal(1,"LNQ_WI cycle cap");
    if(x_valid && x_ready)x_index<=x_index+1;
    if(dut.lnq.ln_out_fire)begin
      if(dut.lnq.ln_out_bits!==ln_gold[ln_index] ||
         dut.lnq.ln_out_index!==10'(ln_index))
        $fatal(1,"LN original gold mismatch index=%0d got=%h expected=%h",
               ln_index,dut.lnq.ln_out_bits,ln_gold[ln_index]);
      ln_index<=ln_index+1;
    end
    if(dut.ln_rsp_valid && dut.lnq.rsp_ready)begin
      if(dut.ln_rsp_group!==5'(q_index) ||
         dut.ln_rsp_q!==q_gold[q_index] ||
         dut.ln_rsp_scale!==scale_gold[q_index])
        $fatal(1,"Q original gold mismatch group=%0d",q_index);
      q_index<=q_index+1;
    end
    for(int p=0;p<3;p++)begin
      if(arvalid[p] && arready[p])begin
        if(q_active[p] || araddr[p]!=cmd_load_base[p]+q_issued[p] ||
           arsize[p]!=3'd6 || arburst[p]!=2'd1)
          $fatal(1,"W AR address/protocol p=%0d addr=%h",p,araddr[p]);
        remain=(q_bytes[p]-q_issued[p])/64;
        page_beats=(4096-int'(araddr[p]%4096))/64;
        beats=remain<64 ? remain:64;
        if(beats>page_beats)beats=page_beats;
        if(beats<=0 || arlen[p]+1!=beats)
          $fatal(1,"W AR 4KiB/length p=%0d len=%0d expect=%0d",p,arlen[p],beats);
        q_active[p]<=1;q_read_index[p]<=q_issued[p]/64;
        q_left[p]<=beats;q_issued[p]<=q_issued[p]+beats*64;
        ar_count[p]<=ar_count[p]+1;
      end
      if(rvalid[p] && rready[p])begin
        if(!q_active[p] || q_left[p]<=0 || rlast[p]!=(q_left[p]==1))
          $fatal(1,"W R last p=%0d",p);
        q_read_index[p]<=q_read_index[p]+1;q_left[p]<=q_left[p]-1;
        if(rlast[p])q_active[p]<=0;
        r_count[p]<=r_count[p]+1;
      end
    end
    if(aux_arvalid && aux_arready)begin
      if(aux_active || aux_araddr!=cmd_aux_base ||
         aux_arsize!=3'd4 || aux_arburst!=2'd1 ||
         aux_arlen!=7 || aux_araddr[11:0]+128>4096)
        $fatal(1,"AUX AR invalid");
      aux_active<=1;aux_index<=0;aux_left<=8;aux_ar_count<=aux_ar_count+1;
    end
    if(aux_rvalid && aux_rready)begin
      if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
        $fatal(1,"AUX R last");
      aux_index<=aux_index+1;aux_left<=aux_left-1;
      if(aux_rlast)aux_active<=0;
      aux_r_count<=aux_r_count+1;
    end
    if(dut.ret_valid && dut.ret_ready)begin
      g=int'(dut.group_no);t=int'(dut.tile_no);
      if(!dut.ret_ok)$fatal(1,"W cache return tag mismatch g=%0d t=%0d",g,t);
      for(l=0;l<8;l++)begin
        idx=(t/2)*32*4+g*4+l/2;
        word512=t[0] ? wi_q1[idx] : wi_q0[idx];
        expected_q=word512[(l%2)*256+:256];
        idx=(t*32+g)*8+l;
        word512=wi_scale[idx/32];
        expected_scale=word512[(idx%32)*16+:16];
        if(dut.ret_q[0][l]!==expected_q ||
           dut.ret_scale[0][l]!==expected_scale ||
           !dut.ret_mask[0][l])
          $fatal(1,"W cache actual bank mismatch g=%0d t=%0d lane=%0d",g,t,l);
      end
    end
    if(dut.front.commit_valid[0] && dut.front.commit_ready[0])begin
      g=int'({dut.commit_tag[160],dut.commit_tag[11+:6]});
      t=int'(dut.commit_tile[9:0]);
      if(g>=32 || t>=656 || dut.commit_next_ps[255:0]!==ps_gold[g*656+t])
        $fatal(1,"PS independent gold mismatch g=%0d t=%0d got=%h exp=%h",
               g,t,dut.commit_next_ps[255:0],ps_gold[g*656+t]);
      ps_count<=ps_count+1;
    end
  end

  task automatic start_cmd(input bit cold,input int new_id);
    @(negedge clk);
    cmd_cold=cold;cmd_id=new_id;
    cmd_task_context={8'd1,16'd0,8'd128,8'd1,8'd0,8'd0,8'd1,32'(new_id)};
    cmd_valid=1;
    #1ps;
    if(!cmd_ready)$fatal(1,"next Wi command not ready");
    @(negedge clk);
    cmd_valid=0;drive_source=1;
    cmd_number=new_id;
    x_index=0;ln_index=0;q_index=0;ps_count=0;
  endtask
  task automatic read_row(input bit reverse_order);
    logic [255:0] hold_bits;
    int tile;
    for(int n=0;n<656;n++)begin
      tile=reverse_order ? 655-n:n;
      @(negedge clk);rd_tile=10'(tile);rd_valid=1;
      #1ps;if(!rd_ready)$fatal(1,"result read not ready tile=%0d",tile);
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<5 && !rsp_valid;guard++)@(negedge clk);
      if(!rsp_valid || rsp_tile!==10'(tile))$fatal(1,"result response tile=%0d",tile);
      hold_bits=rsp_bits;
      repeat(2)begin
        @(negedge clk);
        if(!rsp_valid || rsp_tile!==10'(tile) || rsp_bits!==hold_bits)
          $fatal(1,"result hold tile=%0d",tile);
      end
      for(int lane=0;lane<8;lane++)
        if(rsp_bits[lane*32+:32]!==final_gold[tile*8+lane])
          $fatal(1,"Wi independent final mismatch col=%0d got=%h exp=%h",
                 tile*8+lane,rsp_bits[lane*32+:32],final_gold[tile*8+lane]);
      rsp_ready=1;
      @(negedge clk);rsp_ready=0;
    end
    @(negedge clk);row_release_valid=1;
    #1ps;if(!row_release_ready)$fatal(1,"result release blocked");
    @(negedge clk);row_release_valid=0;
  endtask
  task automatic finish_cmd(input bit reverse_order);
    for(int guard=0;guard<1000000 && !row_valid && !done_valid;guard++)
      @(negedge clk);
    if(!row_valid || done_valid || done_status!=0)
      $fatal(1,"Wi did not publish cmd=%0d status=%0d stripes=%0d",
             cmd_number,done_status,actual_stripes);
    drive_source=0;
    if(x_index!=1024 || ln_index!=1024 || q_index!=32 ||
       actual_stripes!=20992 || actual_w_reads!=20992 ||
       actual_w_returns!=20992 || actual_ps_commits!=20992 || ps_count!=20992)
      $fatal(1,"Wi conservation cmd=%0d x=%0d ln=%0d q=%0d issue=%0d W=%0d/%0d PS=%0d/%0d",
             cmd_number,x_index,ln_index,q_index,actual_stripes,
             actual_w_reads,actual_w_returns,actual_ps_commits,ps_count);
    read_row(reverse_order);
    for(int guard=0;guard<5 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_bad_element!=32'hffffffff)
      $fatal(1,"Wi final done cmd=%0d status=%0d",cmd_number,done_status);
    done_ready=1;
    @(negedge clk);done_ready=0;
    $display("LNQ_WI_CMD_PASS cmd=%0d cycle=%0d AR=%0d/%0d/%0d AUX=%0d R=%0d/%0d/%0d PS=%0d",
      cmd_number,cycle,ar_count[0],ar_count[1],ar_count[2],aux_ar_count,
      r_count[0],r_count[1],r_count[2],ps_count);
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
    pilot=$test$plusargs("PILOT");
    prefix_diag=$test$plusargs("PREFIX_DIAG");
    $readmemh({fixture,"/wi_config.hex"},cfg);
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/wi_q0.hex"},wi_q0);
    $readmemh({fixture,"/wi_q1.hex"},wi_q1);
    $readmemh({fixture,"/wi_scale.hex"},wi_scale);
    $readmemh({fixture,"/ln_source_row0.hex"},source);
    $readmemh({fixture,"/ln_gold_row0.hex"},ln_gold);
    $readmemh({fixture,"/q_row0.hex"},q_gold);
    $readmemh({fixture,"/scale_row0.hex"},scale_gold);
    $readmemh({fixture,"/ps_row0.hex"},ps_gold);
    $readmemh({fixture,"/final_row0.hex"},final_gold);
    $display("LNQ_WI_FIXTURES_READY time=%0t",$time);
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_expected_aux_header=header_rom[0];
    for(int p=0;p<3;p++)begin
      cmd_load_base[p]=cfg[3+p];cmd_load_bytes[p]=cfg[6+p][31:0];
    end
    cmd_weight_key=cfg[2][15:0];
    cmd_bias_base=cfg[9];cmd_bias_bytes=cfg[10][31:0];
    repeat(5)@(negedge clk);
    rst_n=1;
    start_cmd(1,1);
    if(pilot || prefix_diag)begin
      for(int guard=0;guard<1000000 && actual_stripes<256;guard++)@(negedge clk);
      if(actual_stripes<256)$fatal(1,"Wi prefix did not reach 256 stripes");
      $display("LNQ_WI_PREFIX_PASS cycle=%0d issue=%0d AR=%0d/%0d/%0d AUX=%0d R=%0d/%0d/%0d PS=%0d",
        cycle,actual_stripes,ar_count[0],ar_count[1],ar_count[2],aux_ar_count,
        r_count[0],r_count[1],r_count[2],ps_count);
      $finish;
    end
    finish_cmd(0);
    begin
      int old_ar0,old_ar1,old_ar2,old_aux;
      old_ar0=ar_count[0];old_ar1=ar_count[1];old_ar2=ar_count[2];old_aux=aux_ar_count;
      start_cmd(0,2);
      finish_cmd(1);
      if(ar_count[0]!=old_ar0 || ar_count[1]!=old_ar1 ||
         ar_count[2]!=old_ar2 || aux_ar_count!=old_aux)
        $fatal(1,"warm command added AXI AR");
    end
    $display("LNQ_WI_FULL_PASS cold=1 warm=1 gold=AT040_v4_row0_and_independent_Wi_allN");
    $finish;
  end
endmodule
