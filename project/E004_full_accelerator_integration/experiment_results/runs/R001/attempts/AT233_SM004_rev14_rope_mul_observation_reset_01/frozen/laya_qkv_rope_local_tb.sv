`timescale 1ns/1ps
`define ROPE_PIPE dut.rope_adapter.leaf.grp_rope_head_Pipeline_VITIS_LOOP_25_2_fu_171
`define ROPE_MUL `ROPE_PIPE.fmul_32ns_32ns_32_3_max_dsp_1_U7
module laya_qkv_rope_local_tb;
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
  logic cmd_rope_enable;
  logic [63:0] cmd_rope_aux_base, cmd_rope_aux_span;
  logic tensor_rope_enable, tensor_final_valid;
  logic [127:0] row_final;
  logic [2:0][31:0] tensor_final_dst_epoch;
  logic done_rope_check_valid, done_rope_plane;
  logic [127:0] done_rope_check;
  logic [3:0] done_rope_head;
  logic [1:0][63:0] rope_araddr;
  logic [1:0][7:0] rope_arlen;
  logic [1:0][2:0] rope_arsize;
  logic [1:0][1:0] rope_arburst;
  logic [1:0] rope_arvalid, rope_arready, rope_rlast, rope_rvalid, rope_rready;
  logic [1:0][511:0] rope_rdata;
  logic [1:0][1:0] rope_rresp;
  laya_qkv_scratch_row_v1 dut (
    .*
  );
  initial clk=0;
  always #5 clk=~clk;
  int cycle_count=0, b_total=0, aw_total=0, w_total=0;
  int core_release_events=0, core_done_events=0;
  int tb_phase=0;
  int tensor_b_base=0;
  bit inject_b_error=1;
  bit rope_probe=0, inject_rope_b_error=0, inject_rope_r_error=0;
  bit inject_table_r_error=0, table_r_error_seen=0;
  int rope_b_count=0, rope_ar_count=0, rope_r_count=0;
  int rope_b_base=0;
  int rope_table_ar_count=0, rope_table_r_count=0;
  int table_load_accepts=0, table_load_dones=0;
  int scratch_load_accepts=0, scratch_load_dones=0;
  int leaf_current_count=0, leaf_total_count=0;
  bit rope_r_error_seen=0, rope_b_error_seen=0;
  logic [511:0] local_qkv_mem[0:1][0:15][0:3];
  bit local_qkv_valid[0:1][0:15][0:3];
  bit [1:0] rope_bus_active;
  int rope_bus_beat[0:1], rope_bus_plane[0:1], rope_bus_head[0:1];
  int rope_bus_stalls[0:1], rope_bus_r_gaps[0:1];
  bit [1:0] rope_bus_hold;
  bit table_active, table_sin, table_hold;
  int table_beat, table_stalls;
  int aw_stalls[0:2], w_stalls[0:2];
  int aw_first_count[0:2], w_first_count[0:2];
  bit saw_aw_first=0, saw_w_first=0, saw_last_b_hold=0;
  bit saw_normal_last_b_hold=0, saw_error_b_no_success=0;
  logic [2:0] aw_held, w_held;
  logic [2:0][63:0] held_awaddr, held_wstrb;
  logic [2:0][7:0] held_awlen;
  logic [2:0][2:0] held_awsize;
  logic [2:0][1:0] held_awburst;
  logic [2:0][511:0] held_wdata;
  logic [2:0] held_wlast;
  logic tx_route_held;
  logic [1:0] held_route;
  logic [63:0] held_base, held_span;
  int route_hold_checks=0;
  logic [2:0] aw_seen, w_seen;
  logic [2:0][63:0] aw_saved;
  logic [2:0][511:0] w_saved;
  logic [2:0][63:0] strb_saved;
  int b_wait[0:2];
  function automatic logic [31:0] expected_word(input int row, tile, lane);
    expected_word=(cmd_id==32'd703 && lane==0 &&
                   (tile==8 || tile==128)) ? 32'h7fc00000 :
                  32'h3f000000 + 32'(tile*8+lane);
  endfunction
  always_comb begin
    for(int p=0;p<3;p++) begin
      m_axi_awready[p]=rst_n && !aw_seen[p] && !m_axi_bvalid[p] &&
                       aw_stalls[p]!=0 && (cycle_count%7 != p) &&
                       !(scratch_b_count[p][0] && !w_seen[p]);
      m_axi_wready[p]=rst_n && !w_seen[p] && !m_axi_bvalid[p] &&
                      w_stalls[p]!=0 && (cycle_count%9 != (p+2)) &&
                      !(!scratch_b_count[p][0] && !aw_seen[p]);
    end
  end
  always_comb begin
    aux_arready = rst_n && !table_active && table_stalls>=2;
    aux_rvalid = table_active && (cycle_count%7!=0 || table_hold);
    aux_rdata = table_sin ? '0 : {4{32'h3f800000}};
    aux_rresp = inject_table_r_error && !table_r_error_seen &&
                !table_sin && table_beat==2 ? 2'b10 : 2'b00;
    aux_rlast = table_active && table_beat==15;
    for(int p=0;p<2;p++)begin
      rope_arready[p] = rst_n && !rope_bus_active[p] && rope_bus_stalls[p]>=2;
      rope_rvalid[p] = rope_bus_active[p] &&
                       (cycle_count%9!=p || rope_bus_hold[p]);
      rope_rdata[p] = rope_bus_active[p] ?
          local_qkv_mem[rope_bus_plane[p]][rope_bus_head[p]][rope_bus_beat[p]] : '0;
      rope_rresp[p] = (inject_rope_r_error && !rope_r_error_seen &&
                       p==0 && rope_bus_beat[p]==2) ? 2'b10 : 2'b00;
      rope_rlast[p] = rope_bus_active[p] && rope_bus_beat[p]==3;
    end
  end
  always @(posedge clk) begin : local_rope_read_peers
    int off,pl,pair_no,row_no,head_no;
    if(!rst_n)begin
      table_active<=0;table_sin<=0;table_hold<=0;
      table_beat<=0;table_stalls<=0;
      rope_ar_count<=0;rope_r_count<=0;
      rope_table_ar_count<=0;rope_table_r_count<=0;
      rope_r_error_seen<=0;table_r_error_seen<=0;
      table_load_accepts<=0;table_load_dones<=0;
      scratch_load_accepts<=0;scratch_load_dones<=0;
      leaf_current_count<=0;leaf_total_count<=0;
      for(int p=0;p<2;p++)begin
        rope_bus_active[p]<=0;rope_bus_beat[p]<=0;
        rope_bus_plane[p]<=0;rope_bus_head[p]<=0;
        rope_bus_stalls[p]<=0;rope_bus_r_gaps[p]<=0;
        rope_bus_hold[p]<=0;
      end
    end else begin
      if(cmd_valid && cmd_ready)leaf_current_count<=0;
      if(dut.rope_result_valid && dut.rope_result_ready)begin
        if(dut.rope_head_index!=5'(leaf_current_count) ||
           dut.rope_result_protocol_error ||
           !(cmd_id==32'd703 && leaf_current_count==1) &&
           dut.rope_y_coverage!==64'hffffffffffffffff)
          $fatal(1,"LOCAL_ROPE_LEAF_ORDER_OR_COVERAGE leaf=%0d idx=%0d cov=%h",
            leaf_current_count,dut.rope_head_index,dut.rope_y_coverage);
        if(cmd_id==32'd703 && leaf_current_count==1)begin
          if(dut.rope_result_check[15:0]!=16'd6 ||
             dut.rope_result_check[95:64]!=0)
            $fatal(1,"LOCAL_ROPE_K0_CHECK_BAD check=%h",dut.rope_result_check);
        end else if(dut.rope_result_check[15:0]!=0 ||
                    dut.rope_result_check[63:32]!=0 ||
                    dut.rope_result_check[127:64]!==64'hffffffffffffffff)
          $fatal(1,"LOCAL_ROPE_SUCCESS_CHECK_BAD leaf=%0d check=%h",
            leaf_current_count,dut.rope_result_check);
        leaf_current_count<=leaf_current_count+1;
        leaf_total_count<=leaf_total_count+1;
      end
      if(dut.table_reader_load_valid && dut.table_reader_load_ready)
        table_load_accepts<=table_load_accepts+1;
      if(dut.table_reader_done)table_load_dones<=table_load_dones+1;
      if(dut.scratch_reader_load_valid && dut.scratch_reader_load_ready)
        scratch_load_accepts<=scratch_load_accepts+1;
      if(dut.scratch_reader_done)scratch_load_dones<=scratch_load_dones+1;
      if(aux_arvalid && !aux_arready)table_stalls<=table_stalls+1;
      if(aux_rvalid && !aux_rready)table_hold<=1;
      if(aux_arvalid && aux_arready)begin
        if(table_active || aux_arsize!=3'd4 || aux_arburst!=2'd1 ||
           aux_arlen!=15 ||
           (aux_araddr!=cmd_rope_aux_base+64'd617728 &&
            aux_araddr!=cmd_rope_aux_base+64'd880128))
          $fatal(1,"LOCAL_TABLE_AR_BAD addr=%h",aux_araddr);
        table_active<=1;table_beat<=0;
        table_sin<=aux_araddr==cmd_rope_aux_base+64'd880128;
        rope_table_ar_count<=rope_table_ar_count+1;
      end
      if(aux_rvalid && aux_rready)begin
        if(aux_rresp!=0)table_r_error_seen<=1;
        rope_table_r_count<=rope_table_r_count+1;
        table_hold<=0;
        if(aux_rlast)table_active<=0;
        else table_beat<=table_beat+1;
      end
      for(int p=0;p<2;p++)begin
        if(rope_arvalid[p] && !rope_arready[p])
          rope_bus_stalls[p]<=rope_bus_stalls[p]+1;
        if(rope_bus_active[p] && !rope_rvalid[p])
          rope_bus_r_gaps[p]<=rope_bus_r_gaps[p]+1;
        if(rope_rvalid[p] && !rope_rready[p])rope_bus_hold[p]<=1;
        if(rope_arvalid[p] && rope_arready[p])begin
          if(rope_bus_active[p] || rope_araddr[p]<64'h10000000 ||
             rope_arsize[p]!=3'd6 || rope_arburst[p]!=2'd1 ||
             rope_arlen[p]!=3)
            $fatal(1,"LOCAL_SCRATCH_AR_SHAPE port=%0d",p);
          off=int'(rope_araddr[p]-64'h10000000);
          pl=off/4194304;pair_no=(off%4194304)/262144;
          row_no=(off%262144)/256;head_no=pair_no*2+p;
          if(pl>=2 || pair_no>=8 || row_no!=0 || off%256!=0)
            $fatal(1,"LOCAL_SCRATCH_AR_ADDRESS port=%0d off=%0d",p,off);
          for(int beat=0;beat<4;beat++)
            if(!local_qkv_valid[pl][head_no][beat])
              $fatal(1,"LOCAL_SCRATCH_READ_BEFORE_RAW port=%0d head=%0d beat=%0d",p,head_no,beat);
          rope_bus_plane[p]<=pl;rope_bus_head[p]<=head_no;
          rope_bus_beat[p]<=0;rope_bus_active[p]<=1;
          rope_ar_count<=rope_ar_count+1;
        end
        if(rope_rvalid[p] && rope_rready[p])begin
          if(!rope_bus_active[p] || rope_rlast[p]!=(rope_bus_beat[p]==3))
            $fatal(1,"LOCAL_SCRATCH_R_SHAPE port=%0d",p);
          if(rope_rresp[p]!=0)rope_r_error_seen<=1;
          rope_r_count<=rope_r_count+1;
          rope_bus_hold[p]<=0;
          if(rope_rlast[p])rope_bus_active[p]<=0;
          else rope_bus_beat[p]<=rope_bus_beat[p]+1;
        end
      end
    end
  end
  always_ff @(posedge clk) begin
    if(!rst_n)begin
      cycle_count<=0; b_total<=0; aw_total<=0; w_total<=0;
      rope_b_count<=0;rope_b_error_seen<=0;
      for(int pl0=0;pl0<2;pl0++)
        for(int h=0;h<16;h++)
          for(int beat=0;beat<4;beat++)local_qkv_valid[pl0][h][beat]<=0;
      aw_seen<='0; w_seen<='0; aw_saved<='0;
      w_saved<='0;strb_saved<='0;
      m_axi_bvalid<='0;m_axi_bresp<='0;
      for(int p=0;p<3;p++)begin
        b_wait[p]<=0;aw_stalls[p]<=0;w_stalls[p]<=0;
      end
      saw_aw_first<=0;saw_w_first<=0;saw_last_b_hold<=0;
      saw_normal_last_b_hold<=0;saw_error_b_no_success<=0;
      aw_held<='0;w_held<='0;tx_route_held<=0;
      held_route<=0;held_base<=0;held_span<=0;
      route_hold_checks<=0;
      for(int p=0;p<3;p++)begin
        aw_first_count[p]<=0;w_first_count[p]<=0;
      end
    end else begin
      cycle_count<=cycle_count+1;
      if(dut.core_release_valid && dut.core_release_ready)
        core_release_events<=core_release_events+1;
      if(dut.core_done_valid && dut.core_done_ready)
        core_done_events<=core_done_events+1;
      if(cycle_count>1000000)$fatal(1,"scratch local peer timeout phase=%0d b=%0d state=%0d active=%0d failed=%0d raw=%0d epoch=%0d rel=%0d/%0d core_state=%0d",tb_phase,b_total,dut.state,dut.tensor_active,tensor_failed,tensor_raw_valid,tensor_epoch,tensor_release_valid,tensor_release_ready,dut.core.state);
      if(tx_route_held)begin
        route_hold_checks<=route_hold_checks+1;
        if(dut.route!==held_route || dut.segment_base!==held_base ||
           dut.segment_span!==held_span)
          $fatal(1,"scratch route/base changed before B route=%0d",held_route);
        if((|m_axi_awvalid || |m_axi_wvalid) &&
           !(m_axi_awvalid[held_route] || m_axi_wvalid[held_route]))
          $fatal(1,"scratch active TX changed route");
      end else if(|m_axi_awvalid || |m_axi_wvalid)begin
        tx_route_held<=1;
        held_route<=dut.route;
        held_base<=dut.segment_base;
        held_span<=dut.segment_span;
      end
      for(int p=0;p<3;p++)begin
        if(aw_held[p] && (!m_axi_awvalid[p] ||
           m_axi_awaddr[p]!==held_awaddr[p] ||
           m_axi_awlen[p]!==held_awlen[p] ||
           m_axi_awsize[p]!==held_awsize[p] ||
           m_axi_awburst[p]!==held_awburst[p]))
          $fatal(1,"scratch AW hold changed port=%0d",p);
        if(w_held[p] && (!m_axi_wvalid[p] ||
           m_axi_wdata[p]!==held_wdata[p] ||
           m_axi_wstrb[p]!==held_wstrb[p] ||
           m_axi_wlast[p]!==held_wlast[p]))
          $fatal(1,"scratch W hold changed port=%0d",p);
        aw_held[p]<=m_axi_awvalid[p]&&!m_axi_awready[p];
        w_held[p]<=m_axi_wvalid[p]&&!m_axi_wready[p];
        if(m_axi_awvalid[p]&&!m_axi_awready[p])begin
          held_awaddr[p]<=m_axi_awaddr[p];held_awlen[p]<=m_axi_awlen[p];
          held_awsize[p]<=m_axi_awsize[p];
          held_awburst[p]<=m_axi_awburst[p];
        end
        if(m_axi_wvalid[p]&&!m_axi_wready[p])begin
          held_wdata[p]<=m_axi_wdata[p];held_wstrb[p]<=m_axi_wstrb[p];
          held_wlast[p]<=m_axi_wlast[p];
        end
        if(m_axi_awvalid[p]&&!m_axi_awready[p])aw_stalls[p]<=aw_stalls[p]+1;
        if(m_axi_wvalid[p]&&!m_axi_wready[p])w_stalls[p]<=w_stalls[p]+1;
        if(m_axi_awvalid[p]&&m_axi_awready[p])begin
          if(!w_seen[p] && !(m_axi_wvalid[p]&&m_axi_wready[p]))
            aw_first_count[p]<=aw_first_count[p]+1;
          if(m_axi_awlen[p]!=0 || m_axi_awsize[p]!=3'd6 ||
             m_axi_awburst[p]!=2'b01)$fatal(1,"AW shape");
          aw_seen[p]<=1;aw_saved[p]<=m_axi_awaddr[p];aw_total<=aw_total+1;
        end
        if(m_axi_wvalid[p]&&m_axi_wready[p])begin
          if(!aw_seen[p] && !(m_axi_awvalid[p]&&m_axi_awready[p]))
            w_first_count[p]<=w_first_count[p]+1;
          if(m_axi_wstrb[p]!='1 || !m_axi_wlast[p])$fatal(1,"W shape");
          w_seen[p]<=1;w_saved[p]<=m_axi_wdata[p];
          strb_saved[p]<=m_axi_wstrb[p];w_total<=w_total+1;
        end
        if(aw_seen[p]&&!w_seen[p])saw_aw_first<=1;
        if(w_seen[p]&&!aw_seen[p])saw_w_first<=1;
        if(aw_seen[p]&&w_seen[p]&&!m_axi_bvalid[p])begin
          if(b_wait[p] < ((b_total==255 ||
                           (inject_b_error && b_total==511) ||
                           (rope_probe && dut.rope_aux_owner &&
                            rope_b_count-rope_b_base==127)) ? 12 : 2))begin
            b_wait[p]<=b_wait[p]+1;
            if(b_total==255)begin
              saw_normal_last_b_hold<=1;
              if(dut.core_release_valid || row_written[0] || done_valid)
                $fatal(1,"normal row published while final B held");
            end
            if(inject_b_error && b_total==511)begin
              saw_last_b_hold<=1;
              if(dut.core_release_valid || row_written[1] || done_valid)
                $fatal(1,"row published while final B held");
            end
            if(rope_probe && dut.rope_aux_owner &&
               rope_b_count-rope_b_base==127 &&
               (row_final[0] || done_valid))
              $fatal(1,"RoPE FINAL published before last B");
          end else begin
            m_axi_bvalid[p]<=1;
            m_axi_bresp[p]<=((inject_b_error && b_total==511) ||
              (rope_probe && inject_rope_b_error &&
               dut.rope_aux_owner &&
               rope_b_count-rope_b_base==127)) ? 2'b10 : 2'b00;
          end
        end
        if(m_axi_bvalid[p]&&m_axi_bready[p])begin : check_tx
          int row_no, row_tx, seg, beat, plane, head, dest;
          logic [63:0] expected_addr;
          if(rope_probe && dut.rope_aux_owner)begin
            plane=((rope_b_count-rope_b_base)/4)%2;
            head=(rope_b_count-rope_b_base)/8;
            beat=(rope_b_count-rope_b_base)%4;
            dest=head%2;
            expected_addr=64'h10000000+
                (((((plane*2)*8+head/2)*1024)*64)*4)+beat*64;
          end else begin
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
          end
          if(p!=dest || aw_saved[p]!==expected_addr || strb_saved[p]!=='1)
            $fatal(1,"scatter address/route/strb txn=%0d port=%0d addr=%h expected=%h",b_total,p,aw_saved[p],expected_addr);
          if(!(rope_probe && dut.rope_aux_owner))begin
            for(int word=0;word<16;word++)begin
              int tile,lane;
              tile=seg==48 ? 384+beat*2+word/8 : seg*8+beat*2+word/8;
              lane=word%8;
              if(w_saved[p][word*32+:32]!==expected_word(row_no,tile,lane))
                $fatal(1,"scatter data txn=%0d word=%0d actual=%h expected=%h",b_total,word,w_saved[p][word*32+:32],expected_word(row_no,tile,lane));
            end
          end
          if(m_axi_bresp[p] !=
             ((inject_b_error && b_total==511) ||
              (rope_probe && inject_rope_b_error &&
               dut.rope_aux_owner &&
               rope_b_count-rope_b_base==127) ? 2'b10 : 2'b00))
            $fatal(1,"BRESP injection identity");
          if(rope_probe && dut.rope_aux_owner)begin
            if(w_saved[p]!==local_qkv_mem[plane][head][beat])
              $fatal(1,"LOCAL_ROPE_IDENTITY_DATA_BAD plane=%0d head=%0d beat=%0d",
                plane,head,beat);
            rope_b_count<=rope_b_count+1;
            if(m_axi_bresp[p]!=0)begin
              rope_b_error_seen<=1;
              if(row_final[0] || tensor_final_valid || done_valid)
                $fatal(1,"RoPE B error published success");
            end
            local_qkv_mem[plane][head][beat]<=w_saved[p];
            local_qkv_valid[plane][head][beat]<=1;
          end else if(rope_probe && row_tx<192)begin
            local_qkv_mem[plane][head][beat]<=w_saved[p];
            local_qkv_valid[plane][head][beat]<=1;
          end
          if(inject_b_error && b_total==511)begin
            if(row_written[1] || tensor_raw_valid || done_valid)
              $fatal(1,"error B produced premature success");
            saw_error_b_no_success<=1;
          end
          b_total<=b_total+1;
          tx_route_held<=0;
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

  initial begin
    rst_n=0;cmd_valid=0;done_ready=0;rd_valid=0;rsp_ready=0;
    row_release_valid=0;cmd_mode=0;cmd_row=0;cmd_id=0;
    cmd_tensor_begin=0;cmd_tensor_epoch=1;
    cmd_dst_epoch='{default:32'd1};
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=64'd12582912;cmd_dst_span[1]=64'd12582912;
    cmd_dst_span[2]=64'd8388608;
    cmd_source_hidden_bank=0;
    cmd_rope_enable=0;cmd_rope_aux_base=0;cmd_rope_aux_span=0;
    cmd_numeric_identity={512'd0,16'd128,16'd1,64'd1,64'd3};
    cmd_model_identity='h1234;
    tensor_release_valid=0;tensor_release_discard=0;
    tensor_release_epoch=0;tensor_release_request=0;
    tensor_release_generation=0;
    repeat(5)@(negedge clk);rst_n=1;
    if($test$plusargs("ROPE_MUL_TRACE_PROBE") ||
       $test$plusargs("ROPE_MUL_RESET_PROBE"))begin : rope_mul_probe
      logic [31:0] selected_x,selected_cos;
      bit reset_sample;
      int select_cycle,accept_cycle,retire_cycle;
      reset_sample=$test$plusargs("ROPE_MUL_RESET_PROBE");
      rope_probe=1;inject_b_error=0;
      cmd_rope_enable=1;cmd_rope_aux_base=64'h20000000;
      cmd_rope_aux_span=64'd1142528;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      send_command(1,0,708,1);
      for(int guard=0;guard<100000 &&
          !(dut.rope_head_index==0 && dut.rope_leaf_active &&
            `ROPE_PIPE.ap_CS_fsm_pp0_stage1 &&
            `ROPE_PIPE.ap_enable_reg_pp0_iter0_reg &&
            !`ROPE_PIPE.ap_block_pp0_stage1);guard++)@(negedge clk);
      if(!(dut.rope_head_index==0 && dut.rope_leaf_active &&
           `ROPE_PIPE.ap_CS_fsm_pp0_stage1 &&
           `ROPE_PIPE.ap_enable_reg_pp0_iter0_reg &&
           !`ROPE_PIPE.ap_block_pp0_stage1))
        $fatal(1,"LOCAL_MUL_VALID_STAGE1_NOT_REACHED");
      selected_x=`ROPE_MUL.din0;selected_cos=`ROPE_MUL.din1;
      select_cycle=cycle_count;
      if(selected_x!==expected_word(0,0,0) ||
         selected_cos!==32'h3f800000 ||
         dut.rope_adapter.x_coverage!==64'hffffffffffffffff ||
         dut.rope_adapter.cos_coverage!==64'hffffffffffffffff)
        $fatal(1,"LOCAL_MUL_SOURCE_BAD x=%h cos=%h",selected_x,selected_cos);
      @(posedge clk);#1ps;
      if(`ROPE_MUL.din0_buf1!==selected_x ||
         `ROPE_MUL.din1_buf1!==selected_cos)
        $fatal(1,"LOCAL_MUL_INPUT_BUFFER_BAD");
      @(posedge clk);
      accept_cycle=cycle_count;
      if(!`ROPE_MUL.aclken || !`ROPE_MUL.a_tvalid ||
         !`ROPE_MUL.b_tvalid ||
         `ROPE_MUL.a_tdata!==selected_x ||
         `ROPE_MUL.b_tdata!==selected_cos ||
         (`ROPE_PIPE.ap_CS_fsm_pp0_stage3 &&
          `ROPE_PIPE.ap_enable_reg_pp0_iter0_reg &&
          !`ROPE_PIPE.ap_block_pp0_stage3_11001))
        $fatal(1,"LOCAL_MUL_PHYSICAL_ACCEPT_OR_HLS_GAP_BAD");
      #1ps;
      $display("LOCAL_MUL_A_ACCEPT row=0 epoch=1 plane=0 head=0 pair=0 select_cycle=%0d accept_cycle=%0d x=%h cos=%h ip_valid_after=%0d ip_data_after=%h",
        select_cycle,accept_cycle,selected_x,selected_cos,
        `ROPE_MUL.r_tvalid,`ROPE_MUL.r_tdata);
      if(reset_sample)begin
        @(negedge clk);rst_n=0;
        repeat(3)@(negedge clk);
        rst_n=1;
        repeat(510)begin
          @(negedge clk);
          if(done_valid || row_final || row_written ||
             dut.rope_result_valid || |m_axi_awvalid ||
             |m_axi_wvalid || |rope_arvalid || aux_arvalid)
            $fatal(1,"LOCAL_MUL_RESET_OLD_VISIBLE cycle=%0d",cycle_count);
        end
        if(dut.rope_adapter.reset_guard!=0 || tensor_failed ||
           tensor_epoch || row_written || row_final)
          $fatal(1,"LOCAL_MUL_RESET_GUARD_OR_METADATA_BAD");
        tensor_b_base=b_total;rope_b_base=rope_b_count;
        send_command(1,0,709,1);
        take_done(0,7);
        if(b_total!=384 || rope_b_count!=128 ||
           row_written!==128'b1 || row_final!==128'b1 ||
           tensor_failed || leaf_current_count!=32)
          $fatal(1,"LOCAL_MUL_RESET_RECOVERY_BAD B=%0d leaf=%0d",
            b_total,leaf_current_count);
        $display("LOCAL_MUL_ACCEPTED_HLS_UNSAMPLED_RESET_PASS isolation=510 recovery_head=32 ip_return_status_observed_only=1");
      end else begin
        retire_cycle=-1;
        for(int guard=0;guard<10 && retire_cycle<0;guard++)begin
          @(posedge clk);
          if(`ROPE_PIPE.ap_CS_fsm_pp0_stage3 &&
             `ROPE_PIPE.ap_enable_reg_pp0_iter0_reg &&
             !`ROPE_PIPE.ap_block_pp0_stage3_11001)begin
            retire_cycle=cycle_count;
            $display("LOCAL_MUL_A_HLS_SAMPLE cycle=%0d ip_valid=%0d ip_data=%h reg_input=%h",
              retire_cycle,`ROPE_MUL.r_tvalid,`ROPE_MUL.r_tdata,
              `ROPE_PIPE.grp_fu_223_p2);
          end
        end
        if(retire_cycle<0 || retire_cycle<=accept_cycle)
          $fatal(1,"LOCAL_MUL_HLS_SAMPLE_NOT_ORDERED");
        take_done(0,7);
        if(leaf_current_count!=32 || row_final!==128'b1)
          $fatal(1,"LOCAL_MUL_TRACE_HEAD_INCOMPLETE");
        $display("LOCAL_MUL_TRACE_PASS physical_accept_before_HLS_sample=1 output_relation_logged=1");
      end
      $finish;
    end
    if($test$plusargs("ROPE_STICKY_PROBE"))begin : rope_sticky_probe
      int before_b, before_table_load;
      rope_probe=1;inject_b_error=0;inject_table_r_error=1;
      cmd_rope_enable=1;cmd_rope_aux_base=64'h20000000;
      cmd_rope_aux_span=64'd1142528;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      send_command(1,0,706,1);
      take_done(7,13);
      if(!table_r_error_seen || table_load_accepts!=1 ||
         table_load_dones!=1 || rope_table_r_count!=16 ||
         table_active || row_written!==128'b1 || row_final ||
         !tensor_failed || b_total!=256)
        $fatal(1,"LOCAL_TABLE_FIRST_ERROR_INCOMPLETE load=%0d/%0d R=%0d",
          table_load_accepts,table_load_dones,rope_table_r_count);
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=1;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
      before_b=b_total;before_table_load=table_load_accepts;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      cmd_tensor_epoch=3;cmd_dst_epoch='{default:32'd3};
      inject_table_r_error=0;
      send_command(1,0,707,1);
      take_done(0,7);
      if(table_load_accepts!=before_table_load+2 ||
         table_load_accepts!=table_load_dones ||
         scratch_load_accepts!=scratch_load_dones ||
         b_total!=before_b+384 || rope_b_count!=128 ||
         row_written!==128'b1 || row_final!==128'b1 ||
         tensor_failed || tensor_final_valid || leaf_current_count!=32)
        $fatal(1,"LOCAL_TABLE_STICKY_REENTRY_BAD load=%0d/%0d B=%0d leaf=%0d",
          table_load_accepts,table_load_dones,b_total,leaf_current_count);
      $display("LOCAL_ROPE_STICKY_REENTRY_PASS old_RRESP_error=1 new_epoch=3 table_load=%0d/%0d leaf=32 final_row0=1",
        table_load_accepts,table_load_dones);
      $finish;
    end
    if($test$plusargs("ROPE_ORDER_PROBE"))begin : rope_order_probe
      rope_probe=1;inject_b_error=0;
      cmd_rope_enable=1;cmd_rope_aux_base=64'h20000000;
      cmd_rope_aux_span=64'd1142528;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      send_command(1,0,703,1);
      for(int guard=0;guard<20000 && !done_valid;guard++)@(negedge clk);
      if(!done_valid || done_status!=6 || done_phase!=13 ||
         done_bad_element!=32'd1024 || !done_rope_check_valid ||
         done_rope_check[15:0]!=16'd6 ||
         done_rope_check[95:64]!=0 ||
         done_rope_head!=0 || done_rope_plane!=1 ||
         rope_ar_count!=2 || rope_r_count!=8 ||
         rope_b_count!=4 || b_total!=260 ||
         row_written!==128'b1 || row_final || !tensor_failed ||
         tensor_final_valid || !dut.writer_debt_zero ||
         table_load_accepts!=table_load_dones ||
         scratch_load_accepts!=scratch_load_dones)
        $fatal(1,"LOCAL_ROPE_ORDER_FIRST_BAD status=%0d/%0d bad=%0d check=%h plane=%0d head=%0d AR=%0d R=%0d B=%0d",
          done_status,done_phase,done_bad_element,done_rope_check,
          done_rope_plane,done_rope_head,rope_ar_count,rope_r_count,rope_b_count);
      repeat(3)@(negedge clk);
      if(!done_valid || done_status!=6 || done_bad_element!=32'd1024)
        $fatal(1,"LOCAL_ROPE_NUMERIC_DONE_UNSTABLE");
      done_ready=1;@(negedge clk);done_ready=0;
      $display("LOCAL_ROPE_HEAD_ORDER_PASS Q0_then_K0_first_bad=1024 Q1_not_started=1 check=%h",
        done_rope_check);
      $finish;
    end
    if($test$plusargs("ROPE_ERROR_PROBE"))begin : rope_error_probe
      int before_b, before_r;
      rope_probe=1;inject_b_error=0;inject_rope_b_error=1;
      cmd_rope_enable=1;cmd_rope_aux_base=64'h20000000;
      cmd_rope_aux_span=64'd1142528;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      send_command(1,0,700,1);
      take_done(7,13);
      if(!rope_b_error_seen || rope_b_count!=128 ||
         b_total!=384 || rope_ar_count!=32 || rope_r_count!=128 ||
         rope_table_ar_count!=2 || rope_table_r_count!=32 ||
         row_written!==128'b1 || row_final || !tensor_failed ||
         tensor_raw_valid || tensor_final_valid ||
         !dut.writer_debt_zero)
        $fatal(1,"LOCAL_ROPE_B_ERROR_DEBT_OR_METADATA b=%0d rb=%0d ar=%0d r=%0d table=%0d/%0d",
          b_total,rope_b_count,rope_ar_count,rope_r_count,
          rope_table_ar_count,rope_table_r_count);
      $display("LOCAL_ROPE_LAST_B_ERROR_PASS raw_B=256 rope_B=128 scratch_R=128 table_R=32 final=0");
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=1;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
      if(tensor_failed || row_written || row_final || tensor_epoch)
        $fatal(1,"LOCAL_ROPE_ERROR_DISCARD_1");
      before_b=b_total;before_r=rope_r_count;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      cmd_tensor_epoch=3;cmd_dst_epoch='{default:32'd3};
      inject_rope_b_error=0;inject_rope_r_error=1;
      send_command(1,0,701,1);
      take_done(7,13);
      if(!rope_r_error_seen || rope_r_count<before_r+3 ||
         b_total!=before_b+256 || rope_b_count!=rope_b_base ||
         row_written!==128'b1 || row_final || !tensor_failed ||
         tensor_final_valid || !dut.writer_debt_zero ||
         rope_bus_active[0] || rope_bus_active[1])
        $fatal(1,"LOCAL_ROPE_PARTIAL_R_ERROR_DRAIN b=%0d r=%0d active=%b",
          b_total,rope_r_count,rope_bus_active);
      $display("LOCAL_ROPE_PARTIAL_R_ERROR_PASS accepted_R_delta=%0d rope_B=0 final=0",
        rope_r_count-before_r);
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=3;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
      if(tensor_failed || row_written || row_final || tensor_epoch)
        $fatal(1,"LOCAL_ROPE_ERROR_DISCARD_2");
      before_b=b_total;before_r=rope_table_r_count;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      cmd_tensor_epoch=5;cmd_dst_epoch='{default:32'd5};
      inject_rope_r_error=0;inject_table_r_error=1;
      send_command(1,0,704,1);
      take_done(7,13);
      if(!table_r_error_seen || rope_table_r_count!=before_r+16 ||
         table_load_accepts!=table_load_dones ||
         scratch_load_accepts!=scratch_load_dones ||
         b_total!=before_b+256 || rope_b_count!=rope_b_base ||
         row_written!==128'b1 || row_final || !tensor_failed ||
         tensor_final_valid || !dut.writer_debt_zero || table_active)
        $fatal(1,"LOCAL_ROPE_TABLE_PARTIAL_R_ERROR_DRAIN table_R_delta=%0d loads=%0d/%0d",
          rope_table_r_count-before_r,table_load_accepts,table_load_dones);
      $display("LOCAL_ROPE_TABLE_R_ERROR_PASS accepted_R_delta=%0d accepted_loads=%0d retired_loads=%0d",
        rope_table_r_count-before_r,table_load_accepts,table_load_dones);
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=5;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
      if(tensor_failed || row_written || row_final || tensor_epoch)
        $fatal(1,"LOCAL_ROPE_ERROR_DISCARD_3");
      before_b=b_total;before_r=rope_r_count;
      tensor_b_base=b_total;rope_b_base=rope_b_count;
      cmd_tensor_epoch=7;cmd_dst_epoch='{default:32'd7};
      inject_table_r_error=0;
      send_command(1,0,702,1);
      take_done(0,7);
      if(b_total!=before_b+384 || rope_b_count!=rope_b_base+128 ||
         rope_r_count!=before_r+128 ||
         row_written!==128'b1 || row_final!==128'b1 ||
         tensor_failed || tensor_raw_valid || tensor_final_valid ||
         !dut.writer_debt_zero)
        $fatal(1,"LOCAL_ROPE_RECOVERY_BAD b=%0d r=%0d final=%h",
          b_total,rope_r_count,row_final);
      if(table_load_accepts!=table_load_dones ||
         scratch_load_accepts!=scratch_load_dones)
        $fatal(1,"LOCAL_ROPE_LOAD_DEBT_NOT_RETIRED table=%0d/%0d scratch=%0d/%0d",
          table_load_accepts,table_load_dones,
          scratch_load_accepts,scratch_load_dones);
      $display("LOCAL_ROPE_ERROR_RECOVERY_PASS epoch=7 raw_B=256 rope_B=128 final_row0=1 table_load=%0d/%0d scratch_load=%0d/%0d",
        table_load_accepts,table_load_dones,
        scratch_load_accepts,scratch_load_dones);
      $finish;
    end
    if($test$plusargs("FLUSH_ECHO_PROBE"))begin : flush_echo_probe
      int before_release,before_core_done,before_b;
      send_command(1,0,410,1);
      for(int guard=0;guard<400 &&
          !(dut.writer_flush_done && dut.writer_debt_zero &&
            scratch_rsp_count==8);guard++)@(negedge clk);
      if(!(dut.writer_flush_done && dut.writer_debt_zero &&
           scratch_rsp_count==8) || b_total!=4 || aw_total!=4 || w_total!=4)
        $fatal(1,"first real segment flush boundary not reached");
      before_release=core_release_events;
      before_core_done=core_done_events;
      before_b=b_total;
      dut.core.corrupt_result_echo();
      #1ps;
      if(!dut.core_identity_bad || !dut.writer_flush_done)
        $fatal(1,"identity/flush coincidence not established");
      for(int guard=0;guard<30 && !done_valid;guard++)@(negedge clk);
      if(!done_valid)$fatal(1,"FLUSH_ERROR_HANG");
      if(done_status!=7 || done_phase!=12 ||
         done_bad_element!=32'hffffffff ||
         core_release_events!=before_release+1 ||
         b_total!=before_b || aw_total!=before_b || w_total!=before_b ||
         row_written || !tensor_failed || tensor_raw_valid ||
         !dut.writer_debt_zero || dut.read_pending || dut.core_rsp_valid)
        $fatal(1,"flush echo error completion/debt/tensor mismatch");
      take_done(7,12);
      if(core_done_events!=before_core_done+1)
        $fatal(1,"flush echo core done not consumed once");
      @(negedge clk);
      tensor_release_valid=1;tensor_release_discard=1;
      tensor_release_epoch=1;tensor_release_request=3;
      tensor_release_generation=1;
      do @(posedge clk); while(!tensor_release_ready);
      @(negedge clk);tensor_release_valid=0;
      if(tensor_failed || row_written || tensor_raw_valid || tensor_epoch)
        $fatal(1,"flush echo discard failed");
      tensor_b_base=b_total;
      inject_b_error=0;
      cmd_tensor_epoch=2;cmd_dst_epoch='{default:32'd2};
      send_command(1,0,411,1);
      take_done(0,7);
      if(b_total!=before_b+256 || aw_total!=b_total || w_total!=b_total ||
         row_written!==(128'b1) || tensor_failed || tensor_raw_valid ||
         scratch_rsp_count!=512 || scratch_flush_count!=49)
        $fatal(1,"flush echo recovery row/rearm accounting");
      $display("SCRATCH_FLUSH_ECHO_PASS coincident_flush=1 error_B=%0d release=1 core_done=1 discard=1 recovered_B=256",before_b);
      $finish;
    end
    if($test$plusargs("TERMINAL_PROBE"))begin : terminal_probe
      int before_b,before_release,before_core_done;
      send_command(1,0,10,1);
      take_done(0,7);
      if(row_written!==(128'b1) || tensor_failed || tensor_raw_valid ||
         b_total!=256)$fatal(1,"terminal probe tensor setup");
      before_b=b_total;
      before_release=core_release_events;
      before_core_done=core_done_events;
      send_command(0,0,400,0);
      for(int guard=0;guard<10 && !row_valid;guard++)@(negedge clk);
      if(!row_valid || done_valid)$fatal(1,"FFN terminal row absent");
      @(negedge clk);rd_valid=1;rd_tile=10'd128;
      #1ps;if(rd_ready)$fatal(1,"FFN illegal tile accepted");
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<20 && !done_valid;guard++)@(negedge clk);
      if(!done_valid)$fatal(1,"FFN_DIRECT_ERROR_HANG");
      if(done_status!=7 || done_phase!=7 ||
         done_bad_element!=32'hffffffff || row_valid ||
         core_release_events!=before_release || b_total!=before_b ||
         row_written!==(128'b1) || tensor_failed || tensor_raw_valid)
        $fatal(1,"FFN direct error status/debt/tensor");
      take_done(7,7);
      if(core_done_events!=before_core_done+1)
        $fatal(1,"FFN direct core done not consumed");
      send_command(0,0,13,0);
      for(int guard=0;guard<10 && !row_valid;guard++)@(negedge clk);
      if(!row_valid)$fatal(1,"next legal FFN not admitted");
      @(negedge clk);rd_valid=1;rd_tile=0;
      #1ps;if(!rd_ready)$fatal(1,"next legal FFN read rejected");
      @(negedge clk);rd_valid=0;
      for(int guard=0;guard<10 && !rsp_valid;guard++)@(negedge clk);
      if(!rsp_valid || rsp_tile!=0)$fatal(1,"next legal FFN rsp absent");
      rsp_ready=1;@(negedge clk);rsp_ready=0;
      row_release_valid=1;
      for(int guard=0;guard<10 && !row_release_ready;guard++)@(negedge clk);
      if(!row_release_ready)$fatal(1,"next legal FFN release absent");
      @(negedge clk);row_release_valid=0;
      take_done(0,7);
      if(b_total!=before_b || row_written!==(128'b1) || tensor_failed)
        $fatal(1,"legal FFN changed scratch/tensor");
      before_release=core_release_events;
      before_core_done=core_done_events;
      send_command(0,0,401,0);
      for(int guard=0;guard<30 && !done_valid;guard++)begin
        @(negedge clk);
        if(row_valid || rd_ready || rsp_valid ||
           |m_axi_awvalid || |m_axi_wvalid)
          $fatal(1,"FFN wrong identity exposed row or scratch");
      end
      if(!done_valid || done_status!=7 || done_phase!=7 ||
         b_total!=before_b || row_written!==(128'b1) || tensor_failed ||
         core_release_events!=before_release+1)
        $fatal(1,"FFN wrong identity rejection");
      take_done(7,7);
      if(core_done_events!=before_core_done+1)
        $fatal(1,"FFN wrong identity core done not consumed");
      before_b=b_total;
      before_release=core_release_events;
      before_core_done=core_done_events;
      send_command(1,1,402,0);
      for(int guard=0;guard<40 && !done_valid;guard++)begin
        @(negedge clk);
        if(row_valid || |m_axi_awvalid || |m_axi_wvalid)
          $fatal(1,"QKV wrong identity exposed data/write");
      end
      if(!done_valid || done_status!=7 || done_phase!=12 ||
         b_total!=before_b || row_written!==(128'b1) ||
         !tensor_failed || tensor_raw_valid ||
         core_release_events!=before_release+1)
        $fatal(1,"QKV wrong identity rejection");
      take_done(7,12);
      if(core_done_events!=before_core_done+1)
        $fatal(1,"QKV wrong identity core done not consumed");
      $display("SCRATCH_TERMINAL_IDENTITY_PASS direct_ffn=1 recovered_ffn=1 ffn_echo_reject=1 qkv_echo_reject=1 scratch_B=%0d",b_total);
      $finish;
    end
    send_command(1,0,10,1);
    tb_phase=1;
    take_done(0,7);
    tb_phase=2;
    if(b_total!=256 || aw_total!=256 || w_total!=256 ||
       !saw_normal_last_b_hold ||
       row_written!==(128'b1) || tensor_failed || tensor_raw_valid ||
       scratch_rsp_count!=512 || scratch_flush_count!=49 ||
       scratch_b_count[0]!=96 || scratch_b_count[1]!=96 ||
       scratch_b_count[2]!=64)
      $fatal(1,"row0 scratch completion accounting");
    send_command(1,0,11,0);
    take_done(7,12);
    tb_phase=3;
    if(b_total!=256 || row_written!==(128'b1) || tensor_failed)
      $fatal(1,"duplicate row changed tensor or bus");
    send_command(1,1,12,0);
    take_done(7,12);
    tb_phase=4;
    if(b_total!=512 || aw_total!=512 || w_total!=512 ||
       row_written!==(128'b1) || !tensor_failed || tensor_raw_valid ||
       scratch_error_dst!=2 || scratch_error_ordinal!=255 ||
       scratch_error_bresp!=2'b10 ||
       !saw_last_b_hold || !saw_error_b_no_success ||
       !saw_aw_first || !saw_w_first)
      $fatal(1,"row1 BRESP failure/ordering accounting");
    for(int p=0;p<3;p++)
      if(aw_stalls[p]==0 || w_stalls[p]==0 ||
         aw_first_count[p]==0 || w_first_count[p]==0)
        $fatal(1,"AW/W stall/order missed port=%0d aw_first=%0d w_first=%0d",
          p,aw_first_count[p],w_first_count[p]);
    send_command(0,0,13,0);
    tb_phase=5;
    while(!row_valid)@(negedge clk);
    rd_tile=0;rd_valid=1;
    while(!rd_ready)@(negedge clk);
    @(negedge clk);rd_valid=0;
    while(!rsp_valid)@(negedge clk);
    if(rsp_tile!=0 || rsp_bits[31:0]!==expected_word(0,0,0))
      $fatal(1,"FFN read passthrough");
    rsp_ready=1;@(negedge clk);rsp_ready=0;
    row_release_valid=1;
    while(!row_release_ready)@(negedge clk);
    @(negedge clk);row_release_valid=0;
    take_done(0,7);
    tb_phase=6;
    if(b_total!=512 || !tensor_failed || row_written!==(128'b1))
      $fatal(1,"FFN changed scratch/tensor state");
    @(negedge clk);
    tensor_release_valid=1;tensor_release_discard=1;
    tensor_release_epoch=1;tensor_release_request=3;
    tensor_release_generation=1;
    do @(posedge clk); while(!tensor_release_ready);
    tb_phase=7;
    @(negedge clk);tensor_release_valid=0;
    if(tensor_failed || row_written || tensor_raw_valid || tensor_epoch)
      $fatal(1,"discard did not clear tensor metadata");
    // A local legal row peer can exercise all 128 metadata bits without
    // claiming 128 real QKV producer rows or a model-wide numeric result.
    tensor_b_base=b_total;
    inject_b_error=0;
    cmd_tensor_epoch=2;
    cmd_dst_epoch='{default:32'd2};
    tb_phase=8;
    for(int row_no=0;row_no<128;row_no++)begin
      send_command(1,row_no,100+row_no,row_no==0);
      take_done(0,7);
      if(b_total!=tensor_b_base+256*(row_no+1) ||
         scratch_rsp_count!=512 || scratch_flush_count!=49 ||
         scratch_b_count[0]!=96 || scratch_b_count[1]!=96 ||
         scratch_b_count[2]!=64 || tensor_failed ||
         tensor_raw_valid!=(row_no==127))
        $fatal(1,"128-row metadata/write count row=%0d B=%0d",row_no,b_total);
      for(int k=0;k<128;k++)
        if(row_written[k] !== (k<=row_no))
          $fatal(1,"128-row coverage bit row=%0d bit=%0d",row_no,k);
    end
    if(!tensor_raw_valid || tensor_epoch!=2 ||
       tensor_request!=3 || tensor_generation!=1)
      $fatal(1,"tensor RAW publication identity");
    @(negedge clk);
    tensor_release_valid=1;tensor_release_discard=1;
    tensor_release_epoch=2;tensor_release_request=3;
    tensor_release_generation=1;
    #1ps;
    if(tensor_release_ready || cmd_ready)
      $fatal(1,"published tensor accepted discard or concurrent cmd");
    @(negedge clk);tensor_release_discard=0;cmd_valid=1;
    #1ps;if(cmd_ready)$fatal(1,"release did not have priority over command");
    do @(posedge clk); while(!tensor_release_ready);
    @(negedge clk);tensor_release_valid=0;cmd_valid=0;
    if(tensor_raw_valid || row_written || tensor_epoch || tensor_failed)
      $fatal(1,"published tensor release did not retire metadata");
    tb_phase=9;
    cmd_tensor_epoch=4;cmd_dst_epoch='{default:32'd4};
    send_command(1,0,300,1);take_done(7,12);
    if(tensor_epoch || b_total!=tensor_b_base+32768)
      $fatal(1,"skipped epoch changed tensor/bus");
    cmd_tensor_epoch=3;cmd_dst_epoch='{default:32'd3};
    cmd_dst_span[0]=64'd256;
    send_command(1,0,301,1);take_done(7,12);
    if(tensor_epoch || b_total!=tensor_b_base+32768)
      $fatal(1,"short descriptor changed tensor/bus");
    cmd_dst_span[0]=64'd12582912;
    cmd_dst_base[0]=64'hfffffffffffff000;
    send_command(1,0,302,1);take_done(7,12);
    if(tensor_epoch || b_total!=tensor_b_base+32768)
      $fatal(1,"overflow descriptor changed tensor/bus");
    cmd_dst_base[0]=64'h10000000;
    cmd_source_hidden_bank=1;
    send_command(1,0,303,1);take_done(7,12);
    if(tensor_epoch || b_total!=tensor_b_base+32768)
      $fatal(1,"STATE1 source changed tensor/bus");
    cmd_source_hidden_bank=0;
    send_command(1,0,98,1);
    take_done(7,12);
    if(row_written || !tensor_failed || tensor_raw_valid ||
       b_total!=tensor_b_base+32768)
      $fatal(1,"bad synchronous row tag was published");
    @(negedge clk);
    tensor_release_valid=1;tensor_release_discard=1;
    tensor_release_epoch=3;tensor_release_request=3;
    tensor_release_generation=1;
    do @(posedge clk); while(!tensor_release_ready);
    @(negedge clk);tensor_release_valid=0;
    cmd_tensor_epoch=4;cmd_dst_epoch='{default:32'd4};
    send_command(1,0,99,1);
    while(!done_valid)@(negedge clk);
    if(done_status!=6 || done_phase!=11 || done_bad_element!=42 ||
       row_written || !tensor_failed || tensor_raw_valid)
      $fatal(1,"early core numerical error lost");
    done_ready=1;@(negedge clk);done_ready=0;
    @(negedge clk);
    tensor_release_valid=1;tensor_release_discard=1;
    tensor_release_epoch=4;tensor_release_request=3;
    tensor_release_generation=1;
    do @(posedge clk); while(!tensor_release_ready);
    @(negedge clk);tensor_release_valid=0;
    $display("SCRATCH_LOCAL_COVERAGE aw_first=%0d/%0d/%0d w_first=%0d/%0d/%0d aw_stall=%0d/%0d/%0d w_stall=%0d/%0d/%0d route_hold_checks=%0d normal_last_B_hold=%0d error_B_no_success=%0d",
      aw_first_count[0],aw_first_count[1],aw_first_count[2],
      w_first_count[0],w_first_count[1],w_first_count[2],
      aw_stalls[0],aw_stalls[1],aw_stalls[2],
      w_stalls[0],w_stalls[1],w_stalls[2],route_hold_checks,
      saw_normal_last_b_hold,saw_error_b_no_success);
    $display("SCRATCH_LOCAL_PEER_PASS row0=256 row1_bad=256 full128=32768 bad_tag=1 early_numeric=1 aw_before_w=%0d w_before_aw=%0d",saw_aw_first,saw_w_first);
    $finish;
  end
endmodule
