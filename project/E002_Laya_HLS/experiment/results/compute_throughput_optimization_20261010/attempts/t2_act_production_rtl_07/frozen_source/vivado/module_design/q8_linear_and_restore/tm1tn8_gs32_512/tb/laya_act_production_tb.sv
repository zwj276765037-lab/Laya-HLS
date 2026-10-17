`timescale 1ns/1ps
module laya_act_production_tb;


  logic clk=0, rst_n=0;
  logic load_valid;
  logic load_ready;
  logic load_slot;
  logic [31:0] load_epoch, load_k, load_n;
  logic [15:0] load_weight_key;
  logic [3327:0] load_model_identity;
  logic [1023:0] load_expected_aux_header;
  logic [2:0][63:0] load_base;
  logic [2:0][31:0] load_bytes;
  logic [63:0] load_aux_base, load_bias_base;
  logic [31:0] load_bias_bytes;
  logic load_done, load_error, load_reject;
  logic [31:0] load_scale_checks, load_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch, slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic [3:0] commit_ready;
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
  logic start_valid;
  logic start_ready;
  logic [671:0] cfg_numeric_identity, cfg_source_identity;
  logic [95:0] cfg_quant_context, cfg_linear_context;
  logic [63:0] cfg_source_ref, cfg_a_ref, cfg_ps_ref, cfg_dst_ref;
  logic [255:0] cfg_source_coverage;
  logic cfg_source_published, cfg_a_slot, cfg_w_slot;
  logic [31:0] cfg_w_epoch;
  logic [63:0] cfg_output_base, cfg_output_span;
  logic source_valid;
  logic source_ready;
  logic [511:0] source_lanes;
  logic [671:0] source_numeric_identity;
  logic [31:0] source_task_id, source_epoch;
  logic [15:0] source_row, source_mask;
  logic [6:0] source_group;
  logic source_half;
  logic done_valid;
  logic done_ready;
  logic [2:0] done_status;
  logic [31:0] done_bad_element;
  logic [1:0][2:0] a_state;
  logic [1:0][31:0] a_epoch;
  logic [1:0][7:0] a_coverage;
  logic [63:0] command_cycles;
  logic [63:0] m_axi_awaddr;
  logic [7:0] m_axi_awlen;
  logic [2:0] m_axi_awsize;
  logic [1:0] m_axi_awburst;
  logic m_axi_awvalid;
  logic m_axi_awready;
  logic [511:0] m_axi_wdata;
  logic [63:0] m_axi_wstrb;
  logic m_axi_wlast, m_axi_wvalid;
  logic m_axi_wready;
  logic [1:0] m_axi_bresp;
  logic m_axi_bvalid;
  logic m_axi_bready;
  always #5 clk=~clk;
  laya_act_production_v1 dut(.*);
  logic [511:0] q0[0:31],q1[0:0],scales[0:1],source[0:15];
  logic [127:0] header[0:7],gold_q[0:15];
  logic [15:0] gold_scale[0:7];
  logic [31:0] gold_y[0:1],bias[0:1];
  logic [1023:0] gold_ps[0:7],gold_dot[0:7],gold_dotf[0:7],gold_product[0:7],gold_term[0:7];
  logic [3327:0] model[0:0];
  logic [1023:0] exp_header[0:0];
  logic [63:0] config_words[0:12];
  string fixture;
  int cycles=0,loads=0,qcommits=0,pscommits=0,runs=0,rejects=0;
  int ridx[0:2],rleft[0:2],rdebt[0:2];
  bit ractive[0:2];
  int aux_idx=0,aux_left=0,aux_debt=0;
  bit aux_active=0,aux_bias=0;
  bit aw_seen=0,w_seen=0;
  int b_delay=0,aw_seen_count=0,w_seen_count=0,b_seen_count=0;
  logic [63:0] accepted_awaddr;
  logic [7:0] output_mem[0:63];
  int output_writes=0,held_b_cycles=0;
  bit corrupt_source=0,reset_watch=0;
  always_comb begin
    for(int p=0;p<3;p++) begin
      arready[p]=!ractive[p];rvalid[p]=ractive[p];rlast[p]=ractive[p] && rleft[p]==1;
      rresp[p]=0;
      case(p) 0:rdata[p]=q0[ridx[p]];1:rdata[p]=q1[0];default:rdata[p]=scales[ridx[p]];endcase
    end
    aux_arready=!aux_active;aux_rvalid=aux_active;aux_rlast=aux_active && aux_left==1;
    aux_rresp=0;aux_rdata=0;
    if(aux_bias) begin aux_rdata[31:0]=bias[0];aux_rdata[63:32]=bias[1];end
    else aux_rdata=header[aux_idx];
    commit_ready=4'hf;
    m_axi_awready=!aw_seen && cycles%3!=0;
    m_axi_wready=!w_seen && cycles%4!=0;
    m_axi_bvalid=aw_seen && w_seen && b_delay==0;
    m_axi_bresp=0;
  end
  always @(posedge clk) begin
    if(!rst_n) begin
      for(int p=0;p<3;p++) begin ractive[p]<=0;ridx[p]<=0;rleft[p]<=0;rdebt[p]<=0;end
      aux_active<=0;aux_idx<=0;aux_left<=0;aux_debt<=0;
      aw_seen<=0;w_seen<=0;b_delay<=0;
    end else begin
      cycles<=cycles+1;
      if(cycles>5000) $fatal(1,"ACT bounded deadlock phase=%0d q=%0d ps=%0d",dut.phase,qcommits,pscommits);
      if(cycles%100==0) $display("ACT_DEBUG cycles=%0d phase=%0d load=%0d q=%0d ps=%0d",cycles,dut.phase,loads,qcommits,pscommits);
      for(int p=0;p<3;p++) begin
        if(rvalid[p] && rready[p]) begin
          ridx[p]<=ridx[p]+1;rleft[p]<=rleft[p]-1;
          if(rleft[p]==1) begin ractive[p]<=0;rdebt[p]<=rdebt[p]-1;end
        end
        if(arvalid[p] && arready[p]) begin
          if(arsize[p]!=6 || arburst[p]!=1 || araddr[p][5:0]!=0 ||
             araddr[p][11:0]+(arlen[p]+1)*64>4096) $fatal(1,"ACT input AXI shape");
          ractive[p]<=1;ridx[p]<=(araddr[p]-load_base[p])/64;rleft[p]<=arlen[p]+1;rdebt[p]<=rdebt[p]+1;
        end
      end
      if(aux_rvalid && aux_rready) begin
        aux_idx<=aux_idx+1;aux_left<=aux_left-1;
        if(aux_left==1) begin aux_active<=0;aux_debt<=aux_debt-1;end
      end
      if(aux_arvalid && aux_arready) begin
        if((aux_arsize!=4 && aux_arsize!=3) || aux_arburst!=1) $fatal(1,"ACT AUX shape");
        aux_bias<=aux_araddr==load_bias_base;
        if(aux_araddr!=load_bias_base && aux_araddr!=load_aux_base) $fatal(1,"ACT AUX address");
        aux_active<=1;aux_idx<=0;aux_left<=aux_arlen+1;aux_debt<=aux_debt+1;
      end
      if(m_axi_awvalid && m_axi_awready) begin
        if(m_axi_awaddr!=cfg_output_base || m_axi_awlen!=0 || m_axi_awsize!=6 || m_axi_awburst!=1)
          $fatal(1,"ACT output physical address");
        accepted_awaddr=m_axi_awaddr;aw_seen<=1;aw_seen_count++;
      end
      if(m_axi_wvalid && m_axi_wready) begin
        if(!m_axi_wlast || m_axi_wstrb!=64'hff) $fatal(1,"ACT output exact 8B strobe");
        for(int i=0;i<64;i++) if(m_axi_wstrb[i]) begin output_mem[i]=m_axi_wdata[i*8 +:8];output_writes++;end
        w_seen<=1;w_seen_count++;b_delay<=7;
      end
      if(aw_seen && w_seen && b_delay>0) begin b_delay<=b_delay-1;held_b_cycles<=cycles+1;end
      if(m_axi_bvalid && m_axi_bready) begin aw_seen<=0;w_seen<=0;b_seen_count++;end
      if(load_done && !load_error) begin
        if(rdebt[0]!=0 || rdebt[1]!=0 || rdebt[2]!=0 || aux_debt!=0) $fatal(1,"ACT LOAD debt");
        loads++;
      end
      if(dut.q_out_valid && dut.phase==dut.QUANT) begin
        if(!corrupt_source) begin
          if(dut.q_out!==gold_q[dut.q_out_group*2+dut.q_out_half]) $fatal(1,"ACT produced q mismatch group=%0d half=%0d",dut.q_out_group,dut.q_out_half);
          if(dut.q_out_half && dut.q_scale!==gold_scale[dut.q_out_group]) $fatal(1,"ACT produced half scale");
        end
        qcommits++;
      end
      if(dut.commit_valid[0] && dut.commit_ready_mac[0]) begin
        if(dut.commit_tag[159:64]!==dut.short_identity[159:64] || dut.commit_mask[7:0]!=3 || dut.commit_bad[7:0]!=0)
          $fatal(1,"ACT production commit metadata");
        for(int lane=0;lane<2;lane++)
          if(dut.commit_ps[lane*32 +:32]!==gold_ps[pscommits%8][lane*32 +:32])
            $fatal(1,"ACT production PS group=%0d lane=%0d got=%h gold=%h",pscommits%8,lane,
              dut.commit_ps[lane*32 +:32],gold_ps[pscommits%8][lane*32 +:32]);
        pscommits++;
      end
      if(done_valid && done_status==0) begin
        if(!dut.writer_debt_zero || aw_seen || w_seen || b_delay!=0 ||
           dut.result_reserved!=0 || dut.result_returned!=0 || slot_readers!=0 ||
           a_state[dut.a_slot]!=0) $fatal(1,"ACT first done debt/lease phase=%0d ready=%0b writer=%0b aw=%0b w=%0b bdelay=%0d reserved=%h returned=%h readers=%h aslot=%0d astate=%0d",dut.phase,done_ready,dut.writer_debt_zero,aw_seen,w_seen,b_delay,dut.result_reserved,dut.result_returned,slot_readers,dut.a_slot,a_state[dut.a_slot]);
      end
      if(cycles%1000000==0) $display("ACT_PRODUCTION_PROGRESS cycles=%0d q=%0d ps=%0d",cycles,qcommits,pscommits);
    end
  end
  always @(negedge clk) begin
    int seq;
    if(rst_n && dut.mac.row[0].arithmetic.fp_restore.valid_c) begin
      seq=dut.mac.row[0].arithmetic.fp_restore.meta_c.tag[62:36];
      for(int lane=0;lane<2;lane++) begin
        if(dut.mac.row[0].arithmetic.fp_restore.meta_c.dot[lane*32 +:32]!==gold_dot[seq][lane*32 +:32] ||
           dut.mac.row[0].arithmetic.fp_restore.dot_float_c[lane*32 +:32]!==gold_dotf[seq][lane*32 +:32] ||
           dut.mac.row[0].arithmetic.fp_restore.scale_product_c[lane*32 +:32]!==gold_product[seq][lane*32 +:32])
          $fatal(1,"ACT production dot/convert/product group=%0d lane=%0d",seq,lane);
      end
    end
    if(rst_n && dut.mac.row[0].arithmetic.fp_restore.valid_add) begin
      seq=dut.mac.row[0].arithmetic.fp_restore.tag_add[62:36];
      for(int lane=0;lane<2;lane++)
        if(dut.mac.row[0].arithmetic.fp_restore.term_add[lane*32 +:32]!==gold_term[seq][lane*32 +:32])
          $fatal(1,"ACT production term group=%0d lane=%0d",seq,lane);
    end
  end
  task automatic load_weights(input bit slot,input int epoch);
    @(negedge clk);load_slot=slot;load_epoch=epoch;load_valid=1;
    do @(posedge clk);while(!load_ready);
    @(negedge clk);load_valid=0;
    wait(load_done);@(negedge clk);
    if(load_error || slot_state[slot]!=2 || slot_coverage[slot][0]!=2048 ||
       slot_coverage[slot][2]!=128 || slot_coverage[slot][3]!=8 || load_scale_checks!=64)
      $fatal(1,"ACT real complete W publication");
  endtask
  task automatic run_row(input bit aslot,input int epoch,input bit bad);
    int old_writes,old_ps,old_q;
    old_writes=output_writes;old_ps=pscommits;old_q=qcommits;
    @(negedge clk);cfg_a_slot=aslot;cfg_a_ref={8'd0,8'd0,7'd0,aslot,8'h22,32'(epoch)};
    cfg_quant_context[31:0]=32'(10+epoch*2);cfg_linear_context[31:0]=32'(11+epoch*2);
    source_task_id=cfg_quant_context[31:0];corrupt_source=bad;start_valid=1;
    do @(posedge clk);while(!start_ready);
    @(negedge clk);start_valid=0;
    for(int b=0;b<16;b++) begin
      source_lanes=source[b];
      if(bad && b==15) source_lanes[511:480]=32'h7f800000;
      source_group=7'(b/2);source_half=1'(b%2);source_valid=1;
      do @(posedge clk);while(!source_ready && !done_valid);
      @(negedge clk);source_valid=0;
      if(done_valid) break;
    end
    wait(done_valid);@(negedge clk);
    if(bad) begin
      if(done_status!=1 || done_bad_element!=255 || output_writes!=old_writes ||
         pscommits!=old_ps || a_state[aslot]!=4 || slot_state[0]!=2 || slot_readers!=0)
        $fatal(1,"ACT quant failure isolation/status=%0d bad=%0d",done_status,done_bad_element);
      rejects++;
    end else begin
      if(done_status!=0 || output_writes-old_writes!=8 || qcommits-old_q!=16 || pscommits-old_ps!=8)
        $fatal(1,"ACT production normal counts/status %0d",done_status);
      for(int n=0;n<2;n++)
        if({output_mem[n*4+3],output_mem[n*4+2],output_mem[n*4+1],output_mem[n*4]}!==gold_y[n])
          $fatal(1,"ACT production physical output n=%0d",n);
      for(int i=8;i<64;i++) if(output_mem[i]!=8'h5a) $fatal(1,"ACT output sentinel");
      $display("ACT_PRODUCTION_ROW_PASS slot=%0d epoch=%0d cycles=%0d q16=16 ps8=8 bytes=8",aslot,epoch,command_cycles);
      runs++;
    end
    done_ready=1;@(posedge clk);@(negedge clk);done_ready=0;
  endtask
  task automatic reset_active_quant;
    @(negedge clk);cfg_a_slot=1;cfg_a_ref={8'd0,8'd0,8'd1,8'h22,32'd3};
    cfg_quant_context[31:0]=32'd30;cfg_linear_context[31:0]=32'd31;
    source_task_id=30;corrupt_source=0;start_valid=1;
    do @(posedge clk);while(!start_ready);
    @(negedge clk);start_valid=0;source_lanes=source[0];
    source_group=0;source_half=0;source_valid=1;
    do @(posedge clk);while(!source_ready);
    @(negedge clk);source_valid=0;
    if(a_state[1]!=1 || done_valid) $fatal(1,"ACT reset must interrupt real FILLING owner");
    rst_n=0;repeat(16) @(posedge clk);@(negedge clk);rst_n=1;
    repeat(4) @(posedge clk);@(negedge clk);
    if(done_valid || a_state!='0 || a_epoch!='0 || slot_state!='0 || slot_readers!='0 ||
       dut.result_reserved!='0 || dut.result_returned!='0 || !dut.writer_debt_zero)
      $fatal(1,"ACT active reset old-owner cancellation");
    $display("ACT_PRODUCTION_RESET_PASS active_quant=1 old_owner_cancelled=1");
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture)) $fatal(1,"ACT fixture required");
    $readmemh({fixture,"/model_identity.hex"},model);$readmemh({fixture,"/expected_aux_header.hex"},exp_header);
    $readmemh({fixture,"/aux_header.hex"},header);$readmemh({fixture,"/act_q0.hex"},q0);
    $readmemh({fixture,"/act_q1.hex"},q1);$readmemh({fixture,"/act_scale.hex"},scales);
    $readmemh({fixture,"/act_bias.hex"},bias);$readmemh({fixture,"/act_config.hex"},config_words);
    $readmemh({fixture,"/source.mem"},source);$readmemh({fixture,"/gold_q.mem"},gold_q);
    $readmemh({fixture,"/gold_scale.mem"},gold_scale);$readmemh({fixture,"/gold_y.mem"},gold_y);
    $readmemh({fixture,"/ps.mem"},gold_ps);$readmemh({fixture,"/dot.mem"},gold_dot);
    $readmemh({fixture,"/dotf.mem"},gold_dotf);$readmemh({fixture,"/product.mem"},gold_product);
    $readmemh({fixture,"/term.mem"},gold_term);
    if($isunknown({model[0],exp_header[0],source[0],source[15],gold_y[0],gold_y[1]})) $fatal(1,"ACT fixture unknown");
    start_valid=0;source_valid=0;done_ready=0;load_valid=0;load_slot=0;load_epoch=0;
    load_k=256;load_n=2;load_weight_key=16'hff0c;load_model_identity=model[0];load_expected_aux_header=exp_header[0];
    load_base[0]=config_words[3];load_base[1]=config_words[4];load_base[2]=config_words[5];
    load_bytes[0]=2048;load_bytes[1]=0;load_bytes[2]=128;load_aux_base=0;
    load_bias_base=config_words[9];load_bias_bytes=8;
    cfg_numeric_identity={model[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cfg_source_identity=cfg_numeric_identity;source_numeric_identity=cfg_numeric_identity;
    cfg_quant_context={8'd1,16'd0,8'd2,8'd0,8'hff,8'd6,8'h20,32'd12};
    cfg_linear_context={8'd1,16'd0,8'd2,8'd0,8'hff,8'd6,8'h37,32'd13};
    cfg_source_ref={8'd0,8'd2,8'd0,8'd10,32'd1};
    cfg_ps_ref={8'd0,8'd0,8'd0,8'h24,32'd1};cfg_dst_ref={8'd0,8'd4,8'd0,8'd10,32'd1};
    cfg_source_coverage='1;cfg_source_published=1;cfg_w_slot=0;cfg_w_epoch=1;
    cfg_output_base=64'h1000;cfg_output_span=64;
    source_epoch=1;source_row=0;source_mask=16'hffff;source_group=0;source_half=0;source_lanes=0;
    for(int i=0;i<64;i++) output_mem[i]=8'h5a;
    repeat(16) @(posedge clk);@(negedge clk);rst_n=1;
    load_weights(0,1);
    run_row(0,1,0);run_row(1,1,1);run_row(1,2,0);run_row(0,2,0);
    reset_active_quant();load_weights(0,1);run_row(1,1,0);
    if(runs!=4 || rejects!=1 || loads!=2 || aw_seen_count!=4 || w_seen_count!=4 || b_seen_count!=4)
      $fatal(1,"ACT final counts");
    $display("ACT_PRODUCTION_PASS real_rows=4 quant_error_recovery=1 active_reset_recovery=1 dual_a=1 warm_w=1 q_halves=%0d ps_groups=%0d aw=%0d w=%0d b=%0d held_b=%0d",qcommits,pscommits,aw_seen_count,w_seen_count,b_seen_count,held_b_cycles);
    $finish;
  end
endmodule
