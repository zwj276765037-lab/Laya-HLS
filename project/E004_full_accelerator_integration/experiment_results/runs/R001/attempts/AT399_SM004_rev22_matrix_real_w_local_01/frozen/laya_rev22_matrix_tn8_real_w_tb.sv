`timescale 1ns/1ps
// Public-interface matrix/front pilot. A and W responses are legal fixture
// peers; this does not replace the independent chain's real bank or cache.
module laya_rev22_matrix_tn8_real_w_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready;
  logic done_valid;
  logic [3:0] done_status;
  logic ps_tile_valid,ps_retire_ready;
  logic [9:0] ps_tile;
  logic [31:0] actual_a_reads,actual_a_returns,actual_w_reads,
      actual_w_returns,actual_stripes,actual_row_retired,
      actual_terminal,actual_ps_retired;
  logic w_lease_valid,w_lease_ready,w_lease_done,w_lease_error;
  logic w_lease_slot;
  logic [31:0] w_lease_epoch,w_lease_k,w_lease_n;
  logic [15:0] w_lease_weight_key;
  logic [3327:0] w_lease_model_identity;
  logic [671:0] w_lease_numeric_identity;
  logic [95:0] w_lease_task_context;
  logic w_read_valid,w_read_ready,w_read_error,w_read_slot,w_read_pair;
  logic [31:0] w_read_epoch;
  logic [3327:0] w_read_model_identity;
  logic [671:0] w_read_numeric_identity;
  logic [95:0] w_read_task_context;
  logic w_ret_valid,w_ret_ready,w_ret_slot,w_ret_pair;
  logic w_release_valid,w_release_ready,w_release_done,w_release_error;
  logic w_release_slot;
  logic [31:0] w_release_epoch;
  logic [671:0] w_release_numeric_identity;
  logic [95:0] w_release_task_context;
  logic [63:0] w_cfg[0:12];
  logic [1023:0] header_rom[0:0];
  logic [2:0][63:0] wp_base;
  logic [2:0][31:0] wp_bytes;
  logic wp_valid=0,wp_ready,wp_done_valid,wp_done_ready=0;
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
  logic [15:0] w_read_tile,w_ret_tile;
  logic [7:0] w_read_group,w_ret_group;
  logic [1:0][7:0][255:0] w_ret_q;
  logic [1:0][7:0][15:0] w_ret_scale;
  logic [1:0][7:0] w_ret_mask;
  logic [255:0] qgold[0:127];
  logic [15:0] scalegold[0:127];
  byte unsigned final_gold[0:49151];
  logic [3327:0] model_rom[0:0];
  logic [3327:0] model_identity;
  logic [671:0] numeric_identity;
  logic [95:0] task_context=96'h100000000000000000000000;
  logic rsp_pending=0,rsp_valid=0;
  logic [9:0] rsp_tag=0;
  logic [255:0] rsp_bits=0;
  logic [15:0] ps_cover=0;
  int cycle=0,ps_count=0;
  string fixture;
  laya_lnq_bank_link_v1 link();

  assign link.a_claim_ready=rst_n;
  assign link.a_claim_error=1'b0;
  assign link.a_window_release_ready=1'b1;
  assign link.matrix_result_ready=!rsp_pending && !rsp_valid;
  assign link.result_pending=rsp_pending;
  assign link.result_rsp_valid=rsp_valid;
  assign link.result_rsp_tile=rsp_tag;
  assign link.result_rsp_bits=rsp_bits;

  always @(posedge clk)begin
    if(!rst_n)begin
      rsp_pending<=0;rsp_valid<=0;rsp_tag<=0;rsp_bits<=0;
      cycle<=0;ps_count<=0;ps_cover<=0;
    end else begin
      cycle<=cycle+1;
      if(cycle>100000)$fatal(1,"REV22_MATRIX_PEER_CYCLE_CAP");
      if(rsp_valid && link.matrix_result_rsp_ready)rsp_valid<=0;
      if(rsp_pending)begin rsp_pending<=0;rsp_valid<=1;end
      if(link.matrix_result_accept)begin
        int row,group;
        row=int'(link.matrix_result_physical_addr)/34;
        group=int'(link.matrix_result_physical_addr)%34;
        if(row>=16 || group>=34 || rsp_pending || rsp_valid)
          $fatal(1,"REV22_MATRIX_PEER_A_REQUEST row=%0d group=%0d",row,group);
        rsp_tag<=link.matrix_result_logical_tile;
        rsp_pending<=1;
        rsp_bits<=0;
        if(row<4)begin
          if(group<32)rsp_bits<=qgold[row*32+group];
          else for(int pair=0;pair<8;pair++)
            rsp_bits[pair*32+:32]<=
              {scalegold[row*32+(group-32)*16+pair*2+1],
               scalegold[row*32+(group-32)*16+pair*2]};
        end
      end
      if(link.matrix_ps_store_valid)begin
        int row;
        row=int'(link.matrix_ps_store_tile)-544;
        if(row<0 || row>=16 || ps_cover[row])
          $fatal(1,"REV22_MATRIX_PEER_PS_TAG %0d",row);
        if($isunknown(link.matrix_ps_store_bits))
          $fatal(1,"REV22_MATRIX_PEER_PS_X row=%0d",row);
        if(row<4)for(int lane=0;lane<8;lane++)begin
          int off;
          logic [31:0] expected;
          off=(row*3072+lane)*4;
          expected={final_gold[off+3],final_gold[off+2],
                    final_gold[off+1],final_gold[off]};
          if(link.matrix_ps_store_bits[lane*32+:32]!==expected)
            $fatal(1,"REV22_MATRIX_PEER_FINAL_GOLD row=%0d lane=%0d got=%h expected=%h",
                row,lane,link.matrix_ps_store_bits[lane*32+:32],expected);
        end
        ps_cover[row]<=1;ps_count<=ps_count+1;
      end
    end
  end
  laya_matrix_service_v1 dut (
    .clk,.rst_n,.bank_link(link),
    .cmd_valid,.cmd_ready,.cmd_id(32'd100),
    .cmd_window_row0(7'd0),.cmd_source_epoch(32'd1),
    .cmd_a_epoch(32'd1),.cmd_w_epoch(32'd1),
    .cmd_w_key(16'h0001),.cmd_model(model_identity),
    .cmd_numeric(numeric_identity),.cmd_task_context(task_context),
    .done_valid,.done_ready(1'b0),.done_status,
    .ps_tile_valid,.ps_tile,.ps_retire_valid(1'b0),
    .ps_retire_error(1'b0),.ps_retire_ready,
    .actual_a_reads,.actual_a_returns,.actual_w_reads,
    .actual_w_returns,.actual_stripes,.actual_row_retired,
    .actual_terminal,.actual_ps_retired,
    .w_lease_valid,.w_lease_ready,.w_lease_done,.w_lease_error,
    .w_lease_slot,.w_lease_epoch,.w_lease_k,.w_lease_n,
    .w_lease_weight_key,.w_lease_model_identity,
    .w_lease_numeric_identity,.w_lease_task_context,
    .w_read_valid,.w_read_ready,.w_read_error,.w_read_slot,
    .w_read_epoch,.w_read_tile,.w_read_group,.w_read_pair,
    .w_read_model_identity,.w_read_numeric_identity,
    .w_read_task_context,.w_ret_valid,.w_ret_ready,.w_ret_slot,
    .w_ret_pair,.w_ret_epoch,.w_ret_tile,.w_ret_group,
    .w_ret_model_identity,.w_ret_numeric_identity,
    .w_ret_task_context,.w_ret_q,.w_ret_scale,.w_ret_mask,
    .w_release_valid,.w_release_ready,.w_release_done,
    .w_release_error,.w_release_slot,.w_release_epoch,
    .w_release_numeric_identity,.w_release_task_context);
  laya_rev22_w_matrix_peer w_peer (
    .clk,.rst_n,.fixture,
    .wp_valid,.wp_ready,.wp_done_valid,.wp_done_ready,
    .wp_id(32'd200),.wp_source_epoch(32'd1),.wp_epoch(32'd1),
    .wp_request(64'd3),.wp_generation(64'd1),.wp_key(16'h0001),
    .wp_model(model_identity),.wp_numeric(numeric_identity),
    .wp_header(header_rom[0]),.wp_base,.wp_bytes,
    .wp_aux_base(64'd0),.wp_bias_base(64'd0),.wp_bias_bytes(32'd0),
    .wp_done_id,.wp_done_source_epoch,.wp_done_epoch,
    .wp_done_request,.wp_done_generation,.wp_done_key,
    .wp_done_model,.wp_done_numeric,.wp_done_status,
    .wp_done_op,.wp_done_check_status,.wp_done_detail,.wp_done_bad64,
    .w_lease_valid,.w_lease_ready,.w_lease_done,.w_lease_error,
    .w_lease_slot,.w_lease_epoch,.w_lease_k,.w_lease_n,
    .w_lease_weight_key,.w_lease_model_identity,
    .w_lease_numeric_identity,.w_lease_task_context,
    .w_read_valid,.w_read_ready,.w_read_error,.w_read_slot,
    .w_read_epoch,.w_read_tile,.w_read_group,.w_read_pair,
    .w_read_model_identity,.w_read_numeric_identity,
    .w_read_task_context,.w_ret_valid,.w_ret_ready,.w_ret_slot,
    .w_ret_pair,.w_ret_epoch,.w_ret_tile,.w_ret_group,
    .w_ret_model_identity,.w_ret_numeric_identity,
    .w_ret_task_context,.w_ret_q,.w_ret_scale,.w_ret_mask,
    .w_release_valid,.w_release_ready,.w_release_done,
    .w_release_error,.w_release_slot,.w_release_epoch,
    .w_release_numeric_identity,.w_release_task_context
  );
  initial begin
    int fd,nread;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"REV22_MATRIX_PEER_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/q_rows4.hex"},qgold);
    $readmemh({fixture,"/scale_rows4.hex"},scalegold);
    $readmemh({fixture,"/qkv_config.hex"},w_cfg);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    for(int p=0;p<3;p++)begin
      wp_base[p]=w_cfg[3+p];wp_bytes[p]=w_cfg[6+p][31:0];
    end
    fd=$fopen({fixture,"/qkv_rows4_output_f32.bin"},"rb");
    if(fd==0)$fatal(1,"REV22_MATRIX_PEER_FINAL_OPEN");
    nread=$fread(final_gold,fd);
    $fclose(fd);
    if(nread!=49152)$fatal(1,"REV22_MATRIX_PEER_FINAL_BYTES %0d",nread);
    model_identity=model_rom[0];
    numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);wp_valid=1;
    #1ps;if(!wp_ready)$fatal(1,"REV22_REAL_W_WP_NOT_READY");
    @(negedge clk);wp_valid=0;
    for(int guard=0;guard<200000 && !wp_done_valid;guard++)
      @(negedge clk);
    if(!wp_done_valid || wp_done_status!=0 ||
       w_peer.r_count[0]!=24576 || w_peer.r_count[1]!=24576 ||
       w_peer.r_count[2]!=3072 || w_peer.aux_count!=8)
      $fatal(1,"REV22_REAL_W_LOAD status=%0d r=%0d/%0d/%0d aux=%0d",
        wp_done_status,w_peer.r_count[0],w_peer.r_count[1],
        w_peer.r_count[2],w_peer.aux_count);
    wp_done_ready=1;@(negedge clk);wp_done_ready=0;
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"REV22_MATRIX_PEER_CMD_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<100000 && !ps_tile_valid && !done_valid;guard++)
      @(negedge clk);
    if(done_valid || !ps_tile_valid || ps_tile!=0 ||
       actual_a_reads!=1024 || actual_a_returns!=1024 ||
       actual_w_reads!=128 || actual_w_returns!=128 ||
       actual_stripes!=128 || actual_row_retired!=512 ||
       actual_terminal!=16 || ps_count!=16 || ps_cover!=16'hffff ||
       actual_ps_retired!=0)
      $fatal(1,"REV22_MATRIX_PEER_TN8 a=%0d/%0d w=%0d/%0d stripe=%0d row=%0d term=%0d ps=%0d status=%0d state=%0d",
          actual_a_reads,actual_a_returns,actual_w_reads,
          actual_w_returns,actual_stripes,actual_row_retired,
          actual_terminal,ps_count,done_status,dut.state);
    $display("REV22_MATRIX_TN8_PEER_PASS a=1024 w=128 stripe=128 row=512 term=16 ps=16 held=1");
    $finish;
  end
endmodule

module laya_rev22_w_matrix_peer(
  input string fixture,
  input logic clk,rst_n,wp_valid,wp_done_ready,
  output logic wp_ready,wp_done_valid,
  input logic [31:0] wp_id,wp_source_epoch,wp_epoch,
  input logic [63:0] wp_request,wp_generation,
  input logic [15:0] wp_key,
  input logic [3327:0] wp_model,
  input logic [671:0] wp_numeric,
  input logic [1023:0] wp_header,
  input logic [2:0][63:0] wp_base,
  input logic [2:0][31:0] wp_bytes,
  input logic [63:0] wp_aux_base,wp_bias_base,
  input logic [31:0] wp_bias_bytes,
  output logic [31:0] wp_done_id,wp_done_source_epoch,wp_done_epoch,
  output logic [63:0] wp_done_request,wp_done_generation,
  output logic [15:0] wp_done_key,
  output logic [3327:0] wp_done_model,
  output logic [671:0] wp_done_numeric,
  output logic [3:0] wp_done_status,
  output logic [7:0] wp_done_op,
  output logic [15:0] wp_done_check_status,
  output logic [31:0] wp_done_detail,
  output logic [63:0] wp_done_bad64,
  input logic w_lease_valid,w_lease_slot,
  input logic [31:0] w_lease_epoch,w_lease_k,w_lease_n,
  input logic [15:0] w_lease_weight_key,
  input logic [3327:0] w_lease_model_identity,
  input logic [671:0] w_lease_numeric_identity,
  input logic [95:0] w_lease_task_context,
  output logic w_lease_ready,w_lease_done,w_lease_error,
  input logic w_read_valid,w_read_slot,w_read_pair,
  input logic [31:0] w_read_epoch,
  input logic [15:0] w_read_tile,
  input logic [7:0] w_read_group,
  input logic [3327:0] w_read_model_identity,
  input logic [671:0] w_read_numeric_identity,
  input logic [95:0] w_read_task_context,
  output logic w_read_ready,w_read_error,
  output logic w_ret_valid,w_ret_slot,w_ret_pair,
  input logic w_ret_ready,
  output logic [31:0] w_ret_epoch,
  output logic [15:0] w_ret_tile,
  output logic [7:0] w_ret_group,
  output logic [3327:0] w_ret_model_identity,
  output logic [671:0] w_ret_numeric_identity,
  output logic [95:0] w_ret_task_context,
  output logic [1:0][7:0][255:0] w_ret_q,
  output logic [1:0][7:0][15:0] w_ret_scale,
  output logic [1:0][7:0] w_ret_mask,
  input logic w_release_valid,w_release_slot,
  input logic [31:0] w_release_epoch,
  input logic [671:0] w_release_numeric_identity,
  input logic [95:0] w_release_task_context,
  output logic w_release_ready,w_release_done,w_release_error
);
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
  laya_w_prep_service_v1 dut (
    .clk,
    .rst_n,
    .load_cancel('0),
    .load_valid('0),
    .load_slot('0),
    .load_epoch('0),
    .load_k('0),
    .load_n('0),
    .load_weight_key('0),
    .load_model_identity('0),
    .load_expected_aux_header('0),
    .load_base('0),
    .load_bytes('0),
    .load_aux_base('0),
    .load_bias_base('0),
    .load_bias_bytes('0),
    .commit_ready(4'hf),
    .arready,
    .rdata,
    .rresp,
    .rlast,
    .rvalid,
    .aux_arready,
    .aux_rdata,
    .aux_rresp,
    .aux_rlast,
    .aux_rvalid,
    .lease_valid(w_lease_valid),
    .lease_slot(w_lease_slot),
    .lease_epoch(w_lease_epoch),
    .lease_k(w_lease_k),
    .lease_n(w_lease_n),
    .lease_weight_key(w_lease_weight_key),
    .lease_model_identity(w_lease_model_identity),
    .lease_numeric_identity(w_lease_numeric_identity),
    .lease_task_context(w_lease_task_context),
    .read_valid(w_read_valid),
    .read_slot(w_read_slot),
    .read_epoch(w_read_epoch),
    .read_tile(w_read_tile),
    .read_group(w_read_group),
    .read_pair(w_read_pair),
    .read_model_identity(w_read_model_identity),
    .read_numeric_identity(w_read_numeric_identity),
    .read_task_context(w_read_task_context),
    .ret_ready(w_ret_ready),
    .release_valid(w_release_valid),
    .release_slot(w_release_slot),
    .release_epoch(w_release_epoch),
    .release_numeric_identity(w_release_numeric_identity),
    .release_task_context(w_release_task_context),
    .wp_valid,
    .wp_id,
    .wp_source_epoch,
    .wp_epoch,
    .wp_request,
    .wp_generation,
    .wp_key,
    .wp_model,
    .wp_numeric,
    .wp_header,
    .wp_base,
    .wp_bytes,
    .wp_aux_base,
    .wp_bias_base,
    .wp_bias_bytes,
    .wp_done_ready,
    .load_ready(),
    .load_done,
    .load_error,
    .load_reject,
    .load_protocol_error,
    .load_numeric_error,
    .load_scale_checks,
    .load_bad_element,
    .slot_state,
    .slot_epoch,
    .slot_readers,
    .slot_coverage,
    .araddr,
    .arlen,
    .arsize,
    .arburst,
    .arvalid,
    .rready,
    .aux_araddr,
    .aux_arlen,
    .aux_arsize,
    .aux_arburst,
    .aux_arvalid,
    .aux_rready,
    .lease_ready(w_lease_ready),
    .lease_done(w_lease_done),
    .lease_error(w_lease_error),
    .read_ready(w_read_ready),
    .read_error(w_read_error),
    .ret_valid(w_ret_valid),
    .ret_slot(w_ret_slot),
    .ret_pair(w_ret_pair),
    .ret_epoch(w_ret_epoch),
    .ret_tile(w_ret_tile),
    .ret_group(w_ret_group),
    .ret_model_identity(w_ret_model_identity),
    .ret_numeric_identity(w_ret_numeric_identity),
    .ret_task_context(w_ret_task_context),
    .ret_q(w_ret_q),
    .ret_scale(w_ret_scale),
    .ret_bias(),
    .ret_mask(w_ret_mask),
    .release_ready(w_release_ready),
    .release_done(w_release_done),
    .release_error(w_release_error),
    .wp_ready,
    .wp_done_valid,
    .wp_done_id,
    .wp_done_source_epoch,
    .wp_done_epoch,
    .wp_done_request,
    .wp_done_generation,
    .wp_done_key,
    .wp_done_model,
    .wp_done_numeric,
    .wp_done_status,
    .wp_done_op,
    .wp_done_check_status,
    .wp_done_detail,
    .wp_done_bad64
  );
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [63:0] cfg[0:12];
  logic [511:0] q0[0:24575],q1[0:24575],scales[0:3071];
  int cycle=0,r_count[0:2],issued[0:2],beat[0:2],left[0:2];
  bit active[0:2];
  int aux_count=0,aux_beat=0,aux_left=0;
  bit aux_active=0;
  bit bus_fault,scale_fault;
  logic [4123:0] held_check;
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
    bus_fault=$test$plusargs("CHAIN_W_BUS_FAULT");scale_fault=0;
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/qkv_q0.hex"},q0);
    $readmemh({fixture,"/qkv_q1.hex"},q1);
    $readmemh({fixture,"/qkv_scale.hex"},scales);
  end
endmodule
