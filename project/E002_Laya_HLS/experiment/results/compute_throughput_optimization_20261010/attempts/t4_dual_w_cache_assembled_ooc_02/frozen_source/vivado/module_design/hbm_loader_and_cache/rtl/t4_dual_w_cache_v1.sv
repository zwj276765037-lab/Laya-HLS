`timescale 1ns/1ps

// Local supply/lease candidate, not a production MAC or model authenticator.
// model_identity = {Q8S2 descriptor words 64..151, four 128-bit tags}.
// numeric_identity = {four tags, S:u16, B:u16, generation:u64, request:u64}.
// task_context = {rows:u8,row0:u16,row_space:u8,batch:u8,layer:u8,stage:u8,
//                 op:u8,task_id:u32}. All identity bits are retained/compared.
// Only STRICT is admitted here; static-profile integration is a separate job.
module t4_dual_w_cache_v1 #(
  parameter int BANK_DEPTH = 10496,
  parameter int BIAS_DEPTH = 328
) (
  input logic clk, rst_n,
  input logic load_valid,
  output logic load_ready,
  input logic load_slot,
  input logic [31:0] load_epoch, load_k, load_n,
  input logic [15:0] load_weight_key,
  input logic [3327:0] load_model_identity,
  input logic [1023:0] load_expected_aux_header,
  input logic [2:0][63:0] load_base,
  input logic [2:0][31:0] load_bytes,
  input logic [63:0] load_aux_base, load_bias_base,
  input logic [31:0] load_bias_bytes,
  output logic load_done, load_error, load_reject,
  output logic [31:0] load_scale_checks, load_bad_element,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch, slot_readers,
  output logic [1:0][3:0][31:0] slot_coverage,
  input logic [3:0] commit_ready,

  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,

  input logic lease_valid,
  output logic lease_ready, lease_done, lease_error,
  input logic lease_slot,
  input logic [31:0] lease_epoch, lease_k, lease_n,
  input logic [15:0] lease_weight_key,
  input logic [3327:0] lease_model_identity,
  input logic [671:0] lease_numeric_identity,
  input logic [95:0] lease_task_context,
  input logic read_valid,
  output logic read_ready, read_error,
  input logic read_slot,
  input logic [31:0] read_epoch,
  input logic [15:0] read_tile,
  input logic [7:0] read_group,
  input logic read_pair,
  input logic [3327:0] read_model_identity,
  input logic [671:0] read_numeric_identity,
  input logic [95:0] read_task_context,
  output logic ret_valid,
  input logic ret_ready,
  output logic ret_slot, ret_pair,
  output logic [31:0] ret_epoch,
  output logic [15:0] ret_tile,
  output logic [7:0] ret_group,
  output logic [3327:0] ret_model_identity,
  output logic [671:0] ret_numeric_identity,
  output logic [95:0] ret_task_context,
  output logic [1:0][7:0][255:0] ret_q,
  output logic [1:0][7:0][15:0] ret_scale,
  output logic [1:0][7:0][31:0] ret_bias,
  output logic [1:0][7:0] ret_mask,
  input logic release_valid,
  output logic release_ready, release_done, release_error,
  input logic release_slot,
  input logic [31:0] release_epoch,
  input logic [671:0] release_numeric_identity,
  input logic [95:0] release_task_context
);
  localparam logic [2:0] EMPTY=0, FILLING=1, READY=2, IN_USE=3, INVALID=4;
  logic [3327:0] model_id [0:1];
  logic [671:0] numeric_id [0:1];
  logic [95:0] task_id [0:1];
  logic [31:0] matrix_k [0:1], matrix_n [0:1];
  logic [15:0] weight_key [0:1], groups [0:1], tiles [0:1];
  logic has_bias [0:1];
  // 2 slots x 2 parity banks x 8 column banks. Each q column stores GS32.
  // Payload storage lives in 32 independent one-dimensional bank modules.
  logic fill_busy, fill_slot, fill_error;
  logic [31:0] fill_epoch;
  logic [2:0][31:0] fill_bytes;
  logic [31:0] fill_bias_bytes;
  logic [63:0] fill_bias_base;
  logic [1023:0] expected_header;
  logic [2:0] seen_done, reader_done, reader_error;
  logic [2:0][31:0] reader_committed, out_offset, out_epoch;
  logic [2:0][511:0] out_data;
  logic [2:0][6:0] out_bytes;
  logic [2:0] out_valid, out_ready, out_last;
  logic reader_ready;
  logic aux_ready, aux_done, aux_error, aux_phase, aux_pending, aux_all_done;
  logic [31:0] aux_committed, aux_out_offset, aux_out_epoch, header_coverage;
  logic [127:0] aux_out_data;
  logic [4:0] aux_out_bytes;
  logic aux_out_valid, aux_out_ready, aux_out_last, aux_start;
  logic [63:0] aux_start_base;
  logic [31:0] aux_start_bytes, aux_start_epoch;
  logic [15:0] scale_tile, scale_group;
  logic [31:0] scale_tile_base;
  logic scale_bad, bias_bad;
  logic [31:0] scale_bad_rank, bias_bad_rank, scale_bad_min, bias_bad_min;
  logic [31:0] command_groups, command_tiles, command_bank_depth;
  logic command_ok, load_accept, reader_start;
  logic lease_ok, read_ok, release_ok, read_accept;
  logic [31:0] read_addr;
  logic [1:0][1:0][7:0][255:0] returned_q;
  logic [1:0][1:0][7:0][15:0] returned_scale;
  logic [1:0][1:0][7:0][31:0] returned_bias;
  wire reader_done_all, reader_error_all;

  always_comb begin
    command_groups=load_k >> 5;
    command_tiles=(load_n+7) >> 3;
    command_bank_depth=((command_tiles+1)>>1)*command_groups;
    command_ok=load_epoch!=0 && slot_epoch[load_slot]!=32'hffffffff &&
      load_epoch==slot_epoch[load_slot]+1 && load_k!=0 && load_k[4:0]==0 &&
      command_groups<=128 && load_n!=0 && load_n<=5248 &&
      command_tiles<=656 && command_bank_depth<=BANK_DEPTH &&
      load_bytes[0]==command_bank_depth*256 &&
      load_bytes[1]==(command_tiles>>1)*command_groups*256 &&
      load_bytes[2]==command_tiles*command_groups*16 &&
      (load_bias_bytes==0 || load_bias_bytes==load_n*4) &&
      load_model_identity[512 +: 32]==0 &&
      load_model_identity[576 +: 64]!=0 &&
      load_aux_base[3:0]==0 && load_bias_base[3:0]==0;
  end
  assign load_ready=!fill_busy && reader_ready && aux_ready &&
    slot_readers[load_slot]==0 && slot_state[load_slot]!=FILLING &&
    slot_state[load_slot]!=IN_USE && !(ret_valid && ret_slot==load_slot);
  assign load_accept=load_valid && load_ready;
  assign reader_start=load_accept && command_ok;
  assign out_ready=commit_ready[2:0] & {3{fill_busy}};
  t4_three_port_reader_v1 reader (
    .clk,.rst_n,.load_valid(reader_start),.load_ready(reader_ready),
    .load_base,.load_bytes,.load_epoch,
    .load_done(reader_done_all),.load_error(reader_error_all),
    .committed_bytes(reader_committed),.araddr,.arlen,.arsize,.arburst,
    .arvalid,.arready,.rdata,.rresp,.rlast,.rvalid,.rready,
    .out_data,.out_offset,.out_epoch,.out_bytes,.out_last,.out_valid,.out_ready
  );
  // The aggregate reader has already retired all three per-port FIFOs/R.
  assign reader_done={3{reader_done_all}};
  assign reader_error={3{reader_error_all}};
  assign aux_start=reader_start || aux_pending;
  assign aux_start_base=reader_start ? load_aux_base : fill_bias_base;
  assign aux_start_bytes=reader_start ? 32'd128 : fill_bias_bytes;
  assign aux_start_epoch=reader_start ? load_epoch : fill_epoch;
  assign aux_out_ready=commit_ready[3] && fill_busy;
  t4_aux_bias_reader_v1 aux_reader (
    .clk,.rst_n,.load_valid(aux_start),.load_ready(aux_ready),
    .load_base(aux_start_base),.load_bytes(aux_start_bytes),
    .load_epoch(aux_start_epoch),.load_done(aux_done),.load_error(aux_error),
    .committed_bytes(aux_committed),.araddr(aux_araddr),.arlen(aux_arlen),
    .arsize(aux_arsize),.arburst(aux_arburst),.arvalid(aux_arvalid),
    .arready(aux_arready),.rdata(aux_rdata),.rresp(aux_rresp),
    .rlast(aux_rlast),.rvalid(aux_rvalid),.rready(aux_rready),
    .out_data(aux_out_data),.out_offset(aux_out_offset),.out_epoch(aux_out_epoch),
    .out_bytes(aux_out_bytes),.out_last(aux_out_last),.out_valid(aux_out_valid),
    .out_ready(aux_out_ready)
  );

  always_comb begin
    scale_bad=0;scale_bad_rank=32'hffffffff;
    for (int lane=0;lane<8;lane++) begin
      if (out_data[2][lane*16+10 +: 5]==5'h1f ||
          (out_data[2][lane*16+15] && out_data[2][lane*16 +: 15]!=0)) begin
        scale_bad=1;
        if (((scale_tile*8+lane)*groups[fill_slot]+scale_group)<scale_bad_rank)
          scale_bad_rank=(scale_tile*8+lane)*groups[fill_slot]+scale_group;
      end
    end
    bias_bad=0;bias_bad_rank=32'hffffffff;
    for (int lane=0;lane<4;lane++)
      if (lane*4<aux_out_bytes && aux_out_data[lane*32+23 +: 8]==8'hff) begin
        bias_bad=1;
        if (aux_out_offset/4+lane<bias_bad_rank)
          bias_bad_rank=aux_out_offset/4+lane;
      end
  end

  logic [1:0] q_commit_ok;
  logic scale_commit_ok, bias_commit_ok, commit_address_bad;
  always_comb begin
    for (int port=0;port<2;port++)
      q_commit_ok[port]=out_epoch[port]==fill_epoch &&
        out_offset[port]==slot_coverage[fill_slot][port] &&
        out_bytes[port]==64 && out_offset[port][5:0]==0 &&
        {1'b0,out_offset[port]}+out_bytes[port]<={1'b0,fill_bytes[port]} &&
        (out_offset[port]>>8)<BANK_DEPTH;
    scale_commit_ok=out_epoch[2]==fill_epoch &&
      out_offset[2]==slot_coverage[fill_slot][2] && out_bytes[2]==16 &&
      out_offset[2][3:0]==0 &&
      {1'b0,out_offset[2]}+out_bytes[2]<={1'b0,fill_bytes[2]} &&
      scale_tile<tiles[fill_slot] && scale_group<groups[fill_slot] &&
      scale_tile_base+scale_group<BANK_DEPTH;
    bias_commit_ok=aux_out_epoch==fill_epoch &&
      aux_out_offset==slot_coverage[fill_slot][3] &&
      aux_out_offset[1:0]==0 && aux_out_bytes[1:0]==0 && aux_out_bytes!=0 &&
      {1'b0,aux_out_offset}+aux_out_bytes<={1'b0,fill_bias_bytes};
    commit_address_bad=0;
    for (int port=0;port<2;port++)
      if (out_valid[port] && out_ready[port] && !q_commit_ok[port])
        commit_address_bad=1;
    if (out_valid[2] && out_ready[2] && !scale_commit_ok)
      commit_address_bad=1;
    if (aux_phase && aux_out_valid && aux_out_ready && !bias_commit_ok)
      commit_address_bad=1;
  end
  for (genvar s=0;s<2;s++) begin : slots
    for (genvar p=0;p<2;p++) begin : parity
      for (genvar lane=0;lane<8;lane++) begin : columns
        wire q_we=rst_n && fill_busy && fill_slot==s &&
          out_valid[p] && out_ready[p] && q_commit_ok[p] &&
          out_offset[p][7:6]==lane/2;
        wire s_we=rst_n && fill_busy && fill_slot==s &&
          out_valid[2] && out_ready[2] && scale_commit_ok && scale_tile[0]==p;
        wire qs_re=rst_n && read_accept && read_slot==s &&
          (read_pair || read_tile[0]==p);
        wire b_present=has_bias[s] &&
          ((read_tile+(read_pair && p ? 16'd1 : 16'd0))*8+lane<matrix_n[s]);
        logic b_we, returned_b_present;
        logic [8:0] b_waddr;
        logic [31:0] b_wdata, b_rdata;
        always_comb begin
          b_we=0;b_waddr=0;b_wdata=0;
          if (rst_n && fill_busy && fill_slot==s && aux_phase &&
              aux_out_valid && aux_out_ready && bias_commit_ok)
            for (int word=0;word<4;word++)
              if (word*4<aux_out_bytes &&
                  ((aux_out_offset/4+word)%8)==lane &&
                  (((aux_out_offset/4+word)/8)%2)==p &&
                  (aux_out_offset/4+word)/16<BIAS_DEPTH) begin
                b_we=1;
                b_waddr=9'((aux_out_offset/4+word)/16);
                b_wdata=aux_out_data[word*32 +:32];
              end
        end
        t4_w_cache_bank_v1 #(.BANK_DEPTH(BANK_DEPTH),.BIAS_DEPTH(BIAS_DEPTH)) bank (
          .clk,.q_we,.s_we,.b_we,
          .q_waddr(14'(out_offset[p]>>8)),
          .s_waddr(14'(scale_tile_base+scale_group)),.b_waddr,
          .q_wdata(out_data[p][(lane%2)*256 +:256]),
          .s_wdata(out_data[2][lane*16 +:16]),.b_wdata,
          .qs_re,.qs_raddr(14'(read_addr)),
          .b_re(qs_re && b_present),.b_raddr(9'(read_tile>>1)),
          .q_rdata(returned_q[s][p][lane]),
          .s_rdata(returned_scale[s][p][lane]),.b_rdata
        );
        always_ff @(posedge clk)
          if (qs_re) returned_b_present<=b_present;
        assign returned_bias[s][p][lane]=returned_b_present ? b_rdata : 32'd0;
`ifndef SYNTHESIS
        always_ff @(posedge clk)
          if (rst_n && qs_re && (q_we || s_we || b_we))
            $fatal(1,"T4_BANK_ILLEGAL_SAME_SLOT_READ_WRITE slot=%0d parity=%0d lane=%0d",s,p,lane);
`endif
      end
    end
  end
  always_comb begin
    ret_q='0;ret_scale='0;ret_bias='0;ret_mask='0;
    for (int lane=0;lane<8;lane++) begin
      ret_q[0][lane]=returned_q[ret_slot][ret_tile[0]][lane];
      ret_scale[0][lane]=returned_scale[ret_slot][ret_tile[0]][lane];
      ret_bias[0][lane]=returned_bias[ret_slot][ret_tile[0]][lane];
      ret_mask[0][lane]=ret_tile*8+lane<matrix_n[ret_slot];
      if (ret_pair) begin
        ret_q[1][lane]=returned_q[ret_slot][1][lane];
        ret_scale[1][lane]=returned_scale[ret_slot][1][lane];
        ret_bias[1][lane]=returned_bias[ret_slot][1][lane];
        ret_mask[1][lane]=(ret_tile+1)*8+lane<matrix_n[ret_slot];
      end
    end
  end
  assign lease_ready=slot_readers[lease_slot]==0 &&
    slot_state[lease_slot]!=FILLING &&
    !(load_accept && command_ok && load_slot==lease_slot);
  assign lease_ok=slot_state[lease_slot]==READY &&
    lease_epoch==slot_epoch[lease_slot] && lease_model_identity==model_id[lease_slot] &&
    lease_weight_key==weight_key[lease_slot] && lease_k==matrix_k[lease_slot] &&
    lease_n==matrix_n[lease_slot] && lease_numeric_identity[160 +: 512]==model_id[lease_slot][511:0] &&
    lease_numeric_identity[63:0]!=0 && lease_numeric_identity[64 +: 64]!=0 &&
    lease_task_context[31:0]!=0;
  assign read_ready=!ret_valid || ret_ready;
  assign read_ok=slot_state[read_slot]==IN_USE && slot_readers[read_slot]==1 &&
    read_epoch==slot_epoch[read_slot] && read_model_identity==model_id[read_slot] &&
    read_numeric_identity==numeric_id[read_slot] && read_task_context==task_id[read_slot] &&
    read_tile<tiles[read_slot] && read_group<groups[read_slot] &&
    (!read_pair || (!read_tile[0] && read_tile+1<tiles[read_slot])) &&
    read_addr<BANK_DEPTH && (read_tile>>1)<BIAS_DEPTH;
  assign read_accept=read_valid && read_ready && read_ok;
  assign read_addr=(read_tile>>1)*groups[read_slot]+read_group;
  assign release_ready=!(ret_valid && ret_slot==release_slot) &&
    !(read_valid && read_ready && read_slot==release_slot);
  assign release_ok=slot_state[release_slot]==IN_USE && slot_readers[release_slot]==1 &&
    release_epoch==slot_epoch[release_slot] &&
    release_numeric_identity==numeric_id[release_slot] &&
    release_task_context==task_id[release_slot];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      slot_state<='0;slot_epoch<='0;slot_readers<='0;slot_coverage<='0;
      fill_busy<=0;fill_slot<=0;fill_error<=0;fill_epoch<=0;
      fill_bytes<='0;fill_bias_bytes<=0;fill_bias_base<=0;expected_header<='0;
      seen_done<=0;aux_phase<=0;aux_pending<=0;aux_all_done<=0;
      header_coverage<=0;scale_tile<=0;scale_group<=0;scale_tile_base<=0;
      scale_bad_min<=32'hffffffff;bias_bad_min<=32'hffffffff;
      load_done<=0;load_error<=0;load_reject<=0;
      load_scale_checks<=0;load_bad_element<=32'hffffffff;
      lease_done<=0;lease_error<=0;read_error<=0;release_done<=0;release_error<=0;
      ret_valid<=0;ret_slot<=0;ret_pair<=0;ret_epoch<=0;ret_tile<=0;ret_group<=0;
      ret_model_identity<='0;ret_numeric_identity<='0;ret_task_context<='0;
      for (int s=0;s<2;s++) begin
        model_id[s]<='0;numeric_id[s]<='0;task_id[s]<='0;
        matrix_k[s]<=0;matrix_n[s]<=0;weight_key[s]<=0;
        groups[s]<=0;tiles[s]<=0;has_bias[s]<=0;
      end
    end else begin
      load_done<=0;load_reject<=0;lease_done<=0;lease_error<=0;
      read_error<=0;release_done<=0;release_error<=0;
      if (ret_valid && ret_ready) ret_valid<=0;
      if (load_accept) begin
        load_error<=0;
        if (!command_ok) begin
          load_done<=1;load_error<=1;load_reject<=1;
        end else begin
          fill_busy<=1;fill_slot<=load_slot;fill_epoch<=load_epoch;fill_error<=0;
          fill_bytes<=load_bytes;fill_bias_bytes<=load_bias_bytes;fill_bias_base<=load_bias_base;
          expected_header<=load_expected_aux_header;header_coverage<=0;
          seen_done<=0;aux_phase<=0;aux_pending<=0;aux_all_done<=0;
          scale_tile<=0;scale_group<=0;scale_tile_base<=0;
          scale_bad_min<=32'hffffffff;bias_bad_min<=32'hffffffff;
          load_scale_checks<=0;load_bad_element<=32'hffffffff;
          slot_state[load_slot]<=FILLING;slot_epoch[load_slot]<=load_epoch;
          slot_coverage[load_slot]<='0;
          model_id[load_slot]<=load_model_identity;weight_key[load_slot]<=load_weight_key;
          matrix_k[load_slot]<=load_k;matrix_n[load_slot]<=load_n;
          groups[load_slot]<=16'(command_groups);tiles[load_slot]<=16'(command_tiles);
          has_bias[load_slot]<=load_bias_bytes!=0;
        end
      end
      if (fill_busy) begin
        if (commit_address_bad) fill_error<=1;
        seen_done<=seen_done | reader_done;
        if (|(reader_done & reader_error)) fill_error<=1;
        for (int p=0;p<3;p++)
          if (out_valid[p] && out_ready[p]) begin
            slot_coverage[fill_slot][p]<=slot_coverage[fill_slot][p]+out_bytes[p];
            if (out_epoch[p]!=fill_epoch || out_offset[p]!=slot_coverage[fill_slot][p] ||
                out_offset[p]+out_bytes[p]>fill_bytes[p]) fill_error<=1;
          end
        if (out_valid[2] && out_ready[2]) begin
          load_scale_checks<=load_scale_checks+8;
          if (scale_bad) begin
            fill_error<=1;
            if (scale_bad_rank<scale_bad_min) scale_bad_min<=scale_bad_rank;
          end
          if (scale_group+1==groups[fill_slot]) begin
            scale_group<=0;scale_tile<=scale_tile+1;
            if (scale_tile[0]) scale_tile_base<=scale_tile_base+groups[fill_slot];
          end else scale_group<=scale_group+1;
        end
        if (aux_pending && aux_ready) aux_pending<=0;
        if (aux_out_valid && aux_out_ready) begin
          if (aux_out_epoch!=fill_epoch) fill_error<=1;
          if (!aux_phase) begin
            header_coverage<=header_coverage+aux_out_bytes;
            if (aux_out_offset!=header_coverage || aux_out_bytes!=16 ||
                aux_out_data !== 128'(expected_header >> (aux_out_offset*8))) fill_error<=1;
          end else begin
            slot_coverage[fill_slot][3]<=slot_coverage[fill_slot][3]+aux_out_bytes;
            if (aux_out_offset!=slot_coverage[fill_slot][3] ||
                aux_out_offset+aux_out_bytes>fill_bias_bytes) fill_error<=1;
            if (bias_bad) begin
              fill_error<=1;
              if (bias_bad_rank<bias_bad_min) bias_bad_min<=bias_bad_rank;
            end
          end
        end
        if (aux_done) begin
          if (aux_error) fill_error<=1;
          if (!aux_phase && fill_bias_bytes!=0 && !aux_error) begin
            aux_phase<=1;aux_pending<=1;
          end else aux_all_done<=1;
        end
        if (&seen_done && aux_all_done) begin
          fill_busy<=0;load_done<=1;
          if (fill_error || slot_coverage[fill_slot][0]!=fill_bytes[0] ||
              slot_coverage[fill_slot][1]!=fill_bytes[1] ||
              slot_coverage[fill_slot][2]!=fill_bytes[2] ||
              slot_coverage[fill_slot][3]!=fill_bias_bytes || header_coverage!=128 ||
              load_scale_checks!=tiles[fill_slot]*groups[fill_slot]*8) begin
            slot_state[fill_slot]<=INVALID;load_error<=1;
          end else begin
            slot_state[fill_slot]<=READY;load_error<=0;
          end
          load_bad_element<=scale_bad_min!=32'hffffffff ? scale_bad_min : bias_bad_min;
        end
      end
      if (lease_valid && lease_ready) begin
        lease_done<=1;lease_error<=!lease_ok;
        if (lease_ok) begin
          slot_state[lease_slot]<=IN_USE;slot_readers[lease_slot]<=1;
          numeric_id[lease_slot]<=lease_numeric_identity;task_id[lease_slot]<=lease_task_context;
        end
      end
      if (read_valid && read_ready) begin
        if (!read_ok) read_error<=1;
        else begin
          ret_valid<=1;ret_slot<=read_slot;ret_epoch<=read_epoch;
          ret_tile<=read_tile;ret_group<=read_group;ret_pair<=read_pair;
          ret_model_identity<=model_id[read_slot];ret_numeric_identity<=numeric_id[read_slot];
          ret_task_context<=task_id[read_slot];
        end
      end
      if (release_valid && release_ready) begin
        release_done<=1;release_error<=!release_ok;
        if (release_ok) begin
          slot_readers[release_slot]<=0;slot_state[release_slot]<=READY;
        end
      end
    end
  end
endmodule
