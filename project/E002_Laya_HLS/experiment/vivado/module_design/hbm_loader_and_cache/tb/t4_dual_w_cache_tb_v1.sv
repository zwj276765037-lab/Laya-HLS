`timescale 1ns/1ps

module t4_dual_w_cache_tb_v1;
  localparam int WI=0, DOWN=1, ACT=2, SCORER=3, QKV=4, DECFC1=5, DECFC2=6;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0;
  logic load_valid=0,load_ready,load_slot=0;
  logic [31:0] load_epoch=0,load_k=0,load_n=0;
  logic [15:0] load_weight_key=0;
  logic [3327:0] load_model_identity=0;
  logic [1023:0] load_expected_aux_header=0;
  logic [2:0][63:0] load_base='0;
  logic [2:0][31:0] load_bytes='0;
  logic [63:0] load_aux_base=0,load_bias_base=0;
  logic [31:0] load_bias_bytes=0;
  logic load_done,load_error,load_reject;
  logic [31:0] load_scale_checks,load_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch,slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic [3:0] commit_ready;
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
  logic lease_valid=0,lease_ready,lease_done,lease_error,lease_slot=0;
  logic [31:0] lease_epoch=0,lease_k=0,lease_n=0;
  logic [15:0] lease_weight_key=0;
  logic [3327:0] lease_model_identity=0;
  logic [671:0] lease_numeric_identity=0;
  logic [95:0] lease_task_context=0;
  logic read_valid=0,read_ready,read_error,read_slot=0;
  logic [31:0] read_epoch=0;
  logic [15:0] read_tile=0;
  logic [7:0] read_group=0;
  logic read_pair=0;
  logic [3327:0] read_model_identity=0;
  logic [671:0] read_numeric_identity=0;
  logic [95:0] read_task_context=0;
  logic ret_valid,ret_ready,ret_slot,ret_pair;
  logic [31:0] ret_epoch;
  logic [15:0] ret_tile;
  logic [7:0] ret_group;
  logic [3327:0] ret_model_identity;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_task_context;
  logic [1:0][7:0][255:0] ret_q;
  logic [1:0][7:0][15:0] ret_scale;
  logic [1:0][7:0][31:0] ret_bias;
  logic [1:0][7:0] ret_mask;
  logic release_valid=0,release_ready,release_done,release_error,release_slot=0;
  logic [31:0] release_epoch=0;
  logic [671:0] release_numeric_identity=0;
  logic [95:0] release_task_context=0;

  t4_dual_w_cache_v1 dut (.load_cancel(1'b0),.*);

  logic [63:0] cfg[0:6][0:12];
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [511:0] wi_q0[0:41983],wi_q1[0:41983],wi_scale[0:5247];
  logic [511:0] down_q0[0:20991],down_q1[0:20991],down_scale[0:2623];
  logic [511:0] act_q0[0:31],act_q1[0:0],act_scale[0:1];
  logic [511:0] scorer_q0[0:8191],scorer_q1[0:8191],scorer_scale[0:1023];
  logic [31:0] wi_bias[0:0],down_bias[0:0],act_bias[0:1],scorer_bias[0:1023];
  logic [511:0] qkv_q0[0:24575],qkv_q1[0:24575],qkv_scale[0:3071];
  logic [511:0] decfc1_q0[0:32767],decfc1_q1[0:32767],decfc1_scale[0:4095];
  logic [511:0] decfc2_q0[0:32767],decfc2_q1[0:32767],decfc2_scale[0:4095];
  logic [31:0] qkv_bias[0:0],decfc1_bias[0:4095],decfc2_bias[0:1023];

  string fixture;
  int cycle=0,active_case=WI,slot_case[0:1];
  int fault_mode=0,accepted_loads=0,overlap_reads=0,scan_limit=0;
  int read_seen[0:1],read_expected[0:1];
  bit check_reads[0:1];
  int q_issued[0:2],q_index[0:2],q_left[0:2],q_bursts[0:2];
  bit q_active[0:2];
  int aux_index=0,aux_left=0,aux_issued=0,aux_bursts=0;
  bit aux_active=0,aux_is_bias=0;
  logic [671:0] numeric_id;
  logic [95:0] task_id;

  function automatic logic [511:0] qbeat(input int c,input int p,input int idx);
    case (c)
      WI: case (p) 0:return wi_q0[idx];1:return wi_q1[idx];default:return wi_scale[idx];endcase
      DOWN: case (p) 0:return down_q0[idx];1:return down_q1[idx];default:return down_scale[idx];endcase
      ACT: case (p) 0:return act_q0[idx];1:return act_q1[0];default:return act_scale[idx];endcase
      QKV: case (p) 0:return qkv_q0[idx];1:return qkv_q1[idx];default:return qkv_scale[idx];endcase
      DECFC1: case (p) 0:return decfc1_q0[idx];1:return decfc1_q1[idx];default:return decfc1_scale[idx];endcase
      DECFC2: case (p) 0:return decfc2_q0[idx];1:return decfc2_q1[idx];default:return decfc2_scale[idx];endcase
      default: case (p) 0:return scorer_q0[idx];1:return scorer_q1[idx];default:return scorer_scale[idx];endcase
    endcase
  endfunction
  function automatic logic [31:0] biasword(input int c,input int idx);
    case(c)
      ACT:return act_bias[idx];
      SCORER:return scorer_bias[idx];
      DECFC1:return decfc1_bias[idx];
      DECFC2:return decfc2_bias[idx];
      default:return 0;
    endcase
  endfunction
  function automatic logic [127:0] auxbeat(input int c,input bit is_bias,input int idx);
    logic [127:0] v;
    v=0;
    if (!is_bias) return header_words[idx];
    for (int j=0;j<4;j++)
      if ((idx*4+j)*4 < cfg[c][10]) v[j*32 +: 32]=biasword(c,idx*4+j);
    return v;
  endfunction

  always_comb begin
    commit_ready[0]=cycle%11!=0;
    commit_ready[1]=cycle%13!=1;
    commit_ready[2]=cycle%7!=2;
    commit_ready[3]=cycle%9!=3;
    ret_ready=cycle%7!=0;
    for (int p=0;p<3;p++) begin
      arready[p]=!q_active[p] && cycle%3!=p;
      rvalid[p]=q_active[p] && cycle%5!=p;
      rdata[p]=qbeat(active_case,p,q_index[p]);
      rresp[p]=(fault_mode==1 && p==0 && q_index[p]==0) ? 2'b10 : 0;
      rlast[p]=q_active[p] && q_left[p]==1;
    end
    aux_arready=!aux_active && cycle%3!=0;
    aux_rvalid=aux_active && cycle%5!=0;
    aux_rdata=auxbeat(active_case,aux_is_bias,aux_index);
    if (fault_mode==2 && aux_is_bias && aux_index==0)
      aux_rdata[31:0]=32'h7f800000;
    aux_rresp=0;
    aux_rlast=aux_active && aux_left==1;
  end

  always @(posedge clk) begin : endpoint_and_checker
    int beats,page_beats,remaining,case_id,g,t,idx;
    bit bias_phase_now;
    logic [511:0] word512;
    logic [15:0] expected_scale;
    logic [255:0] expected_q;
    logic [31:0] expected_bias;
    if (!rst_n) begin
      cycle<=0;aux_active<=0;aux_issued<=0;aux_bursts<=0;
      for (int p=0;p<3;p++) begin
        q_active[p]<=0;q_issued[p]<=0;q_index[p]<=0;q_left[p]<=0;q_bursts[p]<=0;
      end
      read_seen[0]<=0;read_seen[1]<=0;
    end else begin
      cycle<=cycle+1;
      if (cycle>40000000) $fatal(1,"T4 cycle cap");
      for (int p=0;p<3;p++) begin
        if (arvalid[p] && arready[p]) begin
          if (q_active[p] || araddr[p]!=load_base[p]+q_issued[p] ||
              arsize[p]!=6 || arburst[p]!=1)
            $fatal(1,"q AR identity p=%0d got=%h expected=%h size=%0d burst=%0d active=%0d",
                   p,araddr[p],load_base[p]+q_issued[p],arsize[p],arburst[p],q_active[p]);
          remaining=(load_bytes[p]-q_issued[p])/64;
          page_beats=(4096-int'(araddr[p]%4096))/64;
          beats=remaining<64 ? remaining:64;
          if (beats>page_beats) beats=page_beats;
          if (beats<=0 || arlen[p]+1!=beats) $fatal(1,"q AR boundary p=%0d",p);
          q_active[p]<=1;q_index[p]<=q_issued[p]/64;q_left[p]<=beats;
          q_issued[p]<=q_issued[p]+beats*64;q_bursts[p]<=q_bursts[p]+1;
        end
        if (rvalid[p] && rready[p]) begin
          if (!q_active[p] || q_left[p]<=0 || rlast[p]!=(q_left[p]==1))
            $fatal(1,"q R retirement p=%0d",p);
          q_index[p]<=q_index[p]+1;q_left[p]<=q_left[p]-1;
          if (rlast[p]) q_active[p]<=0;
        end
      end
      if (aux_arvalid && aux_arready) begin
        bias_phase_now=load_bias_bytes!=0 && aux_araddr>=load_bias_base;
        if (aux_active || aux_arburst!=1 ||
            aux_araddr!=(bias_phase_now ?
                        load_bias_base+(aux_is_bias ? aux_issued:0) :
                        load_aux_base+aux_issued))
          $fatal(1,"AUX AR identity");
        if (bias_phase_now) begin
          aux_is_bias<=1;
          idx=int'((aux_araddr-load_bias_base)/16);
        end else idx=int'((aux_araddr-load_aux_base)/16);
        if (aux_arsize!=3 && aux_arsize!=4) $fatal(1,"AUX AR size");
        beats=aux_arlen+1;
        if (beats<=0 || beats>64 || (aux_araddr%4096)+beats*(1<<aux_arsize)>4096)
          $fatal(1,"AUX AR boundary");
        aux_active<=1;aux_index<=idx;aux_left<=beats;
        aux_bursts<=aux_bursts+1;
        aux_issued<=(bias_phase_now && !aux_is_bias ? 0 : aux_issued)+
                    beats*(1<<aux_arsize);
      end
      if (aux_rvalid && aux_rready) begin
        if (!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
          $fatal(1,"AUX R retirement");
        aux_index<=aux_index+1;aux_left<=aux_left-1;
        if (aux_rlast) aux_active<=0;
      end
      if (ret_valid && ret_ready) begin
        case_id=slot_case[ret_slot];
        if (!check_reads[ret_slot]) $fatal(1,"unexpected W return");
        g=int'(cfg[case_id][11]);
        t=case_id==ACT ? read_seen[ret_slot]/g : 2*(read_seen[ret_slot]/g);
        if (ret_tile!=t || ret_group!=read_seen[ret_slot]%g ||
            ret_pair!=(case_id!=ACT) || ret_epoch!=slot_epoch[ret_slot] ||
            ret_model_identity!=model_rom[0] ||
            ret_numeric_identity!=numeric_id || ret_task_context!=task_id)
          $fatal(1,"W return identity/order slot=%0d seq=%0d",ret_slot,read_seen[ret_slot]);
        if (slot_state[1]==1 && ret_slot==0) overlap_reads<=overlap_reads+1;
        for (int half=0;half<(ret_pair ? 2:1);half++) begin
          for (int lane=0;lane<8;lane++) begin
            idx=((t+half)/2)*g*4+int'(ret_group)*4+lane/2;
            word512=qbeat(case_id,(t+half)%2,idx);
            expected_q=word512[(lane%2)*256 +: 256];
            idx=((t+half)*g+int'(ret_group))*8+lane;
            word512=qbeat(case_id,2,idx/32);
            expected_scale=word512[(idx%32)*16 +: 16];
            expected_bias=((t+half)*8+lane<int'(cfg[case_id][1])) ?
              biasword(case_id,(t+half)*8+lane):0;
            if (ret_q[half][lane]!==expected_q ||
                ret_scale[half][lane]!==expected_scale ||
                ret_bias[half][lane]!==expected_bias ||
                ret_mask[half][lane]!==((t+half)*8+lane<int'(cfg[case_id][1])))
              $fatal(1,"W bank word mismatch case=%0d slot=%0d tile=%0d group=%0d lane=%0d q=%h/%h scale=%h/%h bias=%h/%h mask=%b/%b",
                     case_id,ret_slot,t+half,ret_group,lane,ret_q[half][lane],
                     expected_q,ret_scale[half][lane],expected_scale,
                     ret_bias[half][lane],expected_bias,ret_mask[half][lane],
                     ((t+half)*8+lane<int'(cfg[case_id][1])));
          end
        end
        read_seen[ret_slot]<=read_seen[ret_slot]+1;
      end
    end
  end

  localparam int RET_BITS=$bits(ret_slot)+$bits(ret_pair)+$bits(ret_epoch)+
    $bits(ret_tile)+$bits(ret_group)+$bits(ret_model_identity)+
    $bits(ret_numeric_identity)+$bits(ret_task_context)+$bits(ret_q)+
    $bits(ret_scale)+$bits(ret_bias)+$bits(ret_mask);
  wire [RET_BITS-1:0] return_record={ret_slot,ret_pair,ret_epoch,ret_tile,
    ret_group,ret_model_identity,ret_numeric_identity,ret_task_context,
    ret_q,ret_scale,ret_bias,ret_mask};
  logic [RET_BITS-1:0] stalled_record;
  bit was_stalled=0;
  int pair_run=0,pair_run_max=0,overlap_commits=0;
  always @(posedge clk) begin
    if(!rst_n)begin was_stalled=0;pair_run=0;end
    else begin
      if(was_stalled && (!ret_valid || return_record!==stalled_record))
        $fatal(1,"full return owner/payload changed duringbackpressure");
      was_stalled=ret_valid && !ret_ready;stalled_record=return_record;
      if(ret_valid && ret_ready && ret_pair)begin
        pair_run=pair_run+1;
        if(pair_run>pair_run_max)pair_run_max=pair_run;
        if(dut.fill_busy && dut.fill_slot!=ret_slot &&
           |(dut.out_valid & dut.out_ready))overlap_commits=overlap_commits+1;
      end else pair_run=0;
    end
  end
  task automatic setup_case(input int s,input int c,input int epoch);
    active_case=c;slot_case[s]=c;
    load_slot=s;load_epoch=epoch;load_k=cfg[c][0][31:0];load_n=cfg[c][1][31:0];
    load_weight_key=cfg[c][2][15:0];load_model_identity=model_rom[0];
    load_expected_aux_header=header_rom[0];
    for (int p=0;p<3;p++) begin
      load_base[p]=cfg[c][3+p];load_bytes[p]=cfg[c][6+p][31:0];
      q_issued[p]=0;q_index[p]=0;q_left[p]=0;q_bursts[p]=0;q_active[p]=0;
    end
    load_aux_base=0;load_bias_base=cfg[c][9];load_bias_bytes=cfg[c][10][31:0];
    aux_issued=0;aux_index=0;aux_left=0;aux_bursts=0;aux_active=0;aux_is_bias=0;
  endtask
  task automatic do_load(input int s,input int c,input int epoch,input bit expect_error);
    @(negedge clk);setup_case(s,c,epoch);
    #1;
    if (!load_ready) $fatal(1,"load not ready slot=%0d",s);
    load_valid=1;
    @(negedge clk);load_valid=0;
    do @(negedge clk); while (!load_done);
    if (load_error!=expect_error || slot_state[s]!=(expect_error ? 4:2))
      $fatal(1,"LOAD completion case=%0d slot=%0d error=%0d state=%0d",c,s,load_error,slot_state[s]);
    if (!expect_error) begin
      for (int p=0;p<3;p++)
        if (slot_coverage[s][p]!=load_bytes[p] || q_issued[p]!=load_bytes[p] || q_active[p])
          $fatal(1,"LOAD physical bytes case=%0d port=%0d",c,p);
      if (slot_coverage[s][3]!=load_bias_bytes ||
          load_scale_checks!=int'(cfg[c][11]*cfg[c][12]*8))
        $fatal(1,"LOAD AUX/scale coverage case=%0d",c);
    end
    accepted_loads++;
    $display("T4_LOAD_CASE case=%0d slot=%0d epoch=%0d state=%0d cycles=%0d",c,s,epoch,slot_state[s],cycle);
  endtask
  task automatic take_lease(input int s,input int c,input int epoch);
    @(negedge clk);
    lease_slot=s;lease_epoch=epoch;lease_k=cfg[c][0][31:0];lease_n=cfg[c][1][31:0];
    lease_weight_key=cfg[c][2][15:0];lease_model_identity=model_rom[0];
    lease_numeric_identity=numeric_id;lease_task_context=task_id;
    #1;
    if (!lease_ready) $fatal(1,"lease not ready");
    lease_valid=1;
    @(negedge clk);lease_valid=0;
    if (!lease_done || lease_error || slot_state[s]!=3 || slot_readers[s]!=1)
      $fatal(1,"lease failed slot=%0d",s);
  endtask
  task automatic reject_lease(input int s,input int c,input int epoch,
                              input bit wrong_model);
    logic [2:0] prior_state;
    @(negedge clk);
    prior_state=slot_state[s];
    lease_slot=s;lease_epoch=epoch;
    lease_k=cfg[c][0][31:0];lease_n=cfg[c][1][31:0];
    lease_weight_key=cfg[c][2][15:0];
    lease_model_identity=model_rom[0] ^ (wrong_model ? 3328'd1 : 3328'd0);
    lease_numeric_identity=numeric_id;lease_task_context=task_id;
    #1;
    if (!lease_ready) $fatal(1,"negative lease not accepted for classification");
    lease_valid=1;
    @(negedge clk);lease_valid=0;
    if (!lease_done || !lease_error || slot_state[s]!=prior_state || slot_readers[s]!=0)
      $fatal(1,"bad lease modified slot=%0d",s);
  endtask
  task automatic reject_read(input int s,input int epoch);
    @(negedge clk);
    read_slot=s;read_epoch=epoch;read_tile=0;read_group=0;read_pair=1;
    read_model_identity=model_rom[0];read_numeric_identity=numeric_id;
    read_task_context=task_id;read_valid=1;
    #1;
    if (!read_ready) $fatal(1,"negative read not accepted for classification");
    @(negedge clk);read_valid=0;
    if (!read_error || ret_valid || slot_readers[s]!=1)
      $fatal(1,"bad read escaped slot=%0d",s);
  endtask
  task automatic reject_release(input int s,input int epoch);
    @(negedge clk);
    release_slot=s;release_epoch=epoch;
    release_numeric_identity=numeric_id;release_task_context=task_id;
    #1;
    if (!release_ready) $fatal(1,"negative release not ready");
    release_valid=1;
    @(negedge clk);release_valid=0;
    if (!release_done || !release_error || slot_state[s]!=3 || slot_readers[s]!=1)
      $fatal(1,"bad release changed lease slot=%0d",s);
  endtask
  task automatic scan_slot(input int s,input int c,input int epoch);
    int g,t,total;
    g=int'(cfg[c][11]);t=int'(cfg[c][12]);
    total=(c==ACT ? t : t/2)*g;
    if (scan_limit!=0 && total>scan_limit) total=scan_limit;
    read_seen[s]=0;read_expected[s]=total;check_reads[s]=1;
    for (int i=0;i<total;i++) begin
      @(negedge clk);
      read_slot=s;read_epoch=epoch;read_tile=c==ACT ? i/g : 2*(i/g);
      read_group=i%g;read_pair=c!=ACT;
      read_model_identity=model_rom[0];read_numeric_identity=numeric_id;
      read_task_context=task_id;read_valid=1;
      while (!read_ready) @(negedge clk);
    end
    @(negedge clk);read_valid=0;
    while (read_seen[s]!=total) @(negedge clk);
    check_reads[s]=0;
    $display("T4_BANK_SCAN_PASS case=%0d slot=%0d returns=%0d cycles=%0d",c,s,total,cycle);
  endtask
  task automatic release_lease(input int s,input int epoch);
    @(negedge clk);
    release_slot=s;release_epoch=epoch;
    release_numeric_identity=numeric_id;release_task_context=task_id;
    #1;
    while (!release_ready) @(negedge clk);
    release_valid=1;
    @(negedge clk);release_valid=0;
    if (!release_done || release_error || slot_state[s]!=2 || slot_readers[s]!=0)
      $fatal(1,"release failed slot=%0d",s);
  endtask

  initial begin
    if (!$value$plusargs("FIXTURE=%s",fixture)) $fatal(1,"FIXTURE required");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/wi_config.hex"},cfg[WI]);
    $readmemh({fixture,"/down_config.hex"},cfg[DOWN]);
    $readmemh({fixture,"/act_config.hex"},cfg[ACT]);
    $readmemh({fixture,"/scorer_config.hex"},cfg[SCORER]);
    $readmemh({fixture,"/wi_q0.hex"},wi_q0);$readmemh({fixture,"/wi_q1.hex"},wi_q1);
    $readmemh({fixture,"/wi_scale.hex"},wi_scale);$readmemh({fixture,"/wi_bias.hex"},wi_bias);
    $readmemh({fixture,"/down_q0.hex"},down_q0);$readmemh({fixture,"/down_q1.hex"},down_q1);
    $readmemh({fixture,"/down_scale.hex"},down_scale);$readmemh({fixture,"/down_bias.hex"},down_bias);
    $readmemh({fixture,"/act_q0.hex"},act_q0);$readmemh({fixture,"/act_q1.hex"},act_q1);
    $readmemh({fixture,"/act_scale.hex"},act_scale);$readmemh({fixture,"/act_bias.hex"},act_bias);
    $readmemh({fixture,"/scorer_q0.hex"},scorer_q0);$readmemh({fixture,"/scorer_q1.hex"},scorer_q1);
    $readmemh({fixture,"/scorer_scale.hex"},scorer_scale);$readmemh({fixture,"/scorer_bias.hex"},scorer_bias);
    $readmemh({fixture,"/qkv_config.hex"},cfg[QKV]);
    $readmemh({fixture,"/qkv_q0.hex"},qkv_q0);
    $readmemh({fixture,"/qkv_q1.hex"},qkv_q1);
    $readmemh({fixture,"/qkv_scale.hex"},qkv_scale);
    $readmemh({fixture,"/qkv_bias.hex"},qkv_bias);
    $readmemh({fixture,"/decfc1_config.hex"},cfg[DECFC1]);
    $readmemh({fixture,"/decfc1_q0.hex"},decfc1_q0);
    $readmemh({fixture,"/decfc1_q1.hex"},decfc1_q1);
    $readmemh({fixture,"/decfc1_scale.hex"},decfc1_scale);
    $readmemh({fixture,"/decfc1_bias.hex"},decfc1_bias);
    $readmemh({fixture,"/decfc2_config.hex"},cfg[DECFC2]);
    $readmemh({fixture,"/decfc2_q0.hex"},decfc2_q0);
    $readmemh({fixture,"/decfc2_q1.hex"},decfc2_q1);
    $readmemh({fixture,"/decfc2_scale.hex"},decfc2_scale);
    $readmemh({fixture,"/decfc2_bias.hex"},decfc2_bias);
    load_model_identity=model_rom[0];
    numeric_id={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    task_id={8'd1,16'd0,8'd128,8'd1,8'd0,8'd0,8'd1,32'd1};
    repeat(8) @(negedge clk);rst_n=1;
    @(negedge clk);setup_case(0,WI,2);load_valid=1;
    @(negedge clk);load_valid=0;
    if (!load_done || !load_reject || !load_error || slot_state[0]!=0 || q_bursts[0]!=0)
      $fatal(1,"wrong first LOAD epoch must reject without DMA");
    do_load(0,WI,1,0);
    take_lease(0,WI,1);
    reject_read(0,2);
    reject_release(0,2);
    @(negedge clk);setup_case(0,ACT,2);
    #1;
    if (load_ready) $fatal(1,"IN_USE slot overwrite admitted");
    slot_case[0]=WI;
    if ($test$plusargs("PILOT")) begin
      @(negedge clk);setup_case(1,DOWN,1);
      #1;
      if (!load_ready) $fatal(1,"pilot Down load not ready");
      load_valid=1;
      @(negedge clk);load_valid=0;
      scan_limit=4096;scan_slot(0,WI,1);
      if (slot_state[1]!=1 || overlap_reads==0)
        $fatal(1,"pilot missed Down FILLING/Wi read overlap");
      $display("T4_DUAL_W_PILOT_PASS cycles=%0d overlap=%0d down_coverage=%0d",cycle,overlap_reads,slot_coverage[1][0]);
      $finish;
    end
    fork
      do_load(1,DOWN,1,0);
      scan_slot(0,WI,1);
    join
    if (overlap_reads==0) $fatal(1,"no Wi read overlapped Down fill");
    reject_lease(1,DOWN,1,1);
    take_lease(1,DOWN,1);scan_slot(1,DOWN,1);release_lease(1,1);
    fault_mode=1;do_load(1,ACT,2,1);fault_mode=0;
    if (slot_state[0]!=3 || slot_readers[0]!=1 || slot_state[1]!=4)
      $fatal(1,"failed prefetch poisoned leased Wi");
    reject_lease(1,ACT,2,0);
    fault_mode=2;do_load(1,SCORER,3,1);fault_mode=0;
    if (load_bad_element!=0 || load_scale_checks!=32768 ||
        slot_state[0]!=3 || slot_readers[0]!=1)
      $fatal(1,"bad scorer bias error rank/checks/other slot got=%0d/%0d/%0d/%0d",
             load_bad_element,load_scale_checks,slot_state[0],slot_readers[0]);
    do_load(1,SCORER,4,0);
    if (aux_bursts<6) $fatal(1,"full scorer bias did not exercise 4KiB AUX split");
    take_lease(1,SCORER,4);scan_slot(1,SCORER,4);release_lease(1,4);
    release_lease(0,1);
    @(negedge clk);setup_case(0,ACT,2);load_valid=1;
    @(negedge clk);load_valid=0;
    repeat(4) @(negedge clk);
    if (!(q_active[0] || q_active[1] || q_active[2] || aux_active))
      $fatal(1,"reset did not intercept a real AXI response");
    rst_n=0;
    repeat(4) @(negedge clk);
    if (slot_state[0]!=0 || slot_state[1]!=0 || slot_readers[0]!=0)
      $fatal(1,"reset retained W identity");
    rst_n=1;
    do_load(0,ACT,1,0);take_lease(0,ACT,1);scan_slot(0,ACT,1);release_lease(0,1);
    for (int c=QKV;c<=DECFC2;c++) begin
      task_id={8'd4,16'd0,8'd0,8'd0,8'd0,(c==QKV ? 8'd2 : 8'd4),
               (c==QKV ? 8'h30 : c==DECFC1 ? 8'h34 : 8'h35),32'(c+1)};
      do_load(0,c,c-QKV+2,0);take_lease(0,c,c-QKV+2);
      if(c==DECFC2) begin
        @(negedge clk);read_slot=0;read_epoch=c-QKV+2;read_tile=0;
        read_group=128;read_pair=1;read_model_identity=model_rom[0];
        read_numeric_identity=numeric_id;read_task_context=task_id;read_valid=1;
        #1;if(!read_ready)$fatal(1,"group128 classification notready");
        @(negedge clk);read_valid=0;
        if(!read_error || ret_valid)$fatal(1,"group128 read escaped fullG128");
      end
      scan_slot(0,c,c-QKV+2);release_lease(0,c-QKV+2);
    end
    if(pair_run_max<4 || overlap_commits==0)
      $fatal(1,"continuous512B read/supply overlap missing max=%0d overlap=%0d",pair_run_max,overlap_commits);
    $display("T4_DUAL_W_SEVEN_SHAPES_PASS shapes=7 G128_last=127 illegal128=1 pair_run_max=%0d overlap_commits=%0d",pair_run_max,overlap_commits);
    $display("T4_DUAL_W_FULL_PASS cycles=%0d loads=%0d overlap=%0d",cycle,accepted_loads,overlap_reads);
    $finish;
  end
endmodule
