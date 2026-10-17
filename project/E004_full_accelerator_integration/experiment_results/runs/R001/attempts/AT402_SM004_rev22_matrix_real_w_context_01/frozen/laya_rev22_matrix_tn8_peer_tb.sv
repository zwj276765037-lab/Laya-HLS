`timescale 1ns/1ps
// Public-interface matrix/front pilot. A and W responses are legal fixture
// peers; this does not replace the independent chain's real bank or cache.
module laya_rev22_matrix_tn8_peer_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready;
  logic done_valid;
  logic [3:0] done_status;
  logic ps_tile_valid,ps_retire_ready;
  logic [9:0] ps_tile;
  logic [31:0] actual_a_reads,actual_a_returns,actual_w_reads,
      actual_w_returns,actual_stripes,actual_row_retired,
      actual_terminal,actual_ps_retired;
  logic w_lease_valid,w_lease_done=0;
  logic w_read_valid,w_ret_valid=0,w_ret_ready;
  logic [15:0] w_read_tile,w_ret_tile;
  logic [7:0] w_read_group,w_ret_group;
  logic [1:0][7:0][255:0] w_ret_q;
  logic [1:0][7:0][15:0] w_ret_scale;
  logic [1:0][7:0] w_ret_mask;
  logic [511:0] wq0[0:24575],wscale[0:3071];
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
      w_lease_done<=0;w_ret_valid<=0;
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
      w_lease_done<=w_lease_valid;
      w_ret_valid<=w_read_valid;
      if(w_read_valid)begin
        w_ret_tile<=w_read_tile;w_ret_group<=w_read_group;
        for(int lane=0;lane<8;lane++)begin
          w_ret_q[0][lane]<=wq0[int'(w_read_tile)*128+
              int'(w_read_group)*4+lane/2][(lane%2)*256+:256];
          w_ret_scale[0][lane]<=wscale[(int'(w_read_tile)*32+
              int'(w_read_group))/4]
              [((int'(w_read_group)%4)*8+lane)*16+:16];
        end
        w_ret_mask[0]<=8'hff;
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
    .w_lease_valid,.w_lease_ready(1'b1),
    .w_lease_done,.w_lease_error(1'b0),
    .w_read_valid,.w_read_ready(1'b1),.w_read_error(1'b0),
    .w_read_tile,.w_read_group,
    .w_ret_valid,.w_ret_ready,.w_ret_slot(1'b0),
    .w_ret_pair(1'b0),.w_ret_epoch(32'd1),
    .w_ret_tile,.w_ret_group,
    .w_ret_model_identity(model_identity),
    .w_ret_numeric_identity(numeric_identity),
    .w_ret_task_context(task_context),.w_ret_q,.w_ret_scale,
    .w_ret_mask,.w_release_ready(1'b1),
    .w_release_done(1'b1),.w_release_error(1'b0));
  initial begin
    int fd,nread;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"REV22_MATRIX_PEER_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/q_rows4.hex"},qgold);
    $readmemh({fixture,"/scale_rows4.hex"},scalegold);
    $readmemh({fixture,"/qkv_q0.hex"},wq0);
    $readmemh({fixture,"/qkv_scale.hex"},wscale);
    fd=$fopen({fixture,"/qkv_rows4_output_f32.bin"},"rb");
    if(fd==0)$fatal(1,"REV22_MATRIX_PEER_FINAL_OPEN");
    nread=$fread(final_gold,fd);
    $fclose(fd);
    if(nread!=49152)$fatal(1,"REV22_MATRIX_PEER_FINAL_BYTES %0d",nread);
    model_identity=model_rom[0];
    numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_valid=1;
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
