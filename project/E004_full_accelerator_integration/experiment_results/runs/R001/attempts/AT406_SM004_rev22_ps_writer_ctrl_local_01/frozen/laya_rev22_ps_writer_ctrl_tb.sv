`timescale 1ns/1ps
// Local fixed PS controller + the original physical AXI writer. The PS bank
// read peer supplies the saved first-four-row final values at the public port.
module laya_rev22_ps_writer_ctrl_tb;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,start_valid=0,active=0;
  laya_lnq_bank_link_v1 link();
  logic read_accept,rsp_ready,segment_begin,tile_valid;
  logic [9:0] read_physical,read_tag;
  logic [1:0] segment_route;
  logic [64:0] segment_address;
  logic [255:0] tile_bits;
  logic [11:0] tile_n0;
  logic rearm_valid,flush_req,rearm_ready,tile_ready,flush_done,
        debt_zero,writer_fault;
  logic [31:0] aw_count,w_count,b_count,ok_b_count,retired_tiles;
  logic [31:0] useful_bytes,physical_bytes;
  logic [63:0] awaddr,output_base;
  logic [7:0] awlen;
  logic [2:0] awsize;
  logic [1:0] awburst,bresp=0;
  logic awvalid,awready,wlast,wvalid,wready,bvalid,bready;
  logic [511:0] wdata;
  logic [63:0] wstrb;
  logic rsp_pending=0,rsp_valid=0;
  logic [9:0] rsp_tag=0;
  logic [255:0] rsp_bits=0;
  logic tile_offered=1;
  logic aw_seen=0,w_seen=0;
  int b_delay=0,actual_b=0,cycle=0;
  byte unsigned final_gold[0:49151];
  string fixture;

  assign link.matrix_ps_tile_valid=tile_offered;
  assign link.matrix_ps_tile=10'd0;
  assign link.matrix_ps_tile_discard=1'b0;
  assign link.matrix_ps_retire_ready=tile_offered;
  assign link.result_pending=rsp_pending;
  assign link.result_rsp_valid=rsp_valid;
  assign link.result_rsp_tile=rsp_tag;
  assign link.result_rsp_bits=rsp_bits;
  assign link.matrix_result_accept=1'b0;
  assign link.matrix_ps_store_valid=1'b0;
  assign awready=!aw_seen;
  assign wready=aw_seen && !w_seen;
  assign bvalid=w_seen && b_delay>=3;

  laya_matrix_ps_writer_ctrl_v1 ctrl (
    .clk,.rst_n,.bank_link(link),.start_valid,.active,.discard(1'b0),
    .dest_base('{64'h32000000,64'h30000000}),
    .dest_span('{64'd12582912,64'd12582912}),
    .result_read_accept(read_accept),.result_rsp_ready(rsp_ready),
    .bank_read_physical(read_physical),.bank_read_tag(read_tag),
    .segment_begin,.segment_route,.segment_address,
    .writer_tile_valid(tile_valid),.writer_tile_bits(tile_bits),
    .writer_tile_n0(tile_n0),.writer_rearm_valid(rearm_valid),
    .writer_flush_req(flush_req),.writer_rearm_ready(rearm_ready),
    .writer_tile_ready(tile_ready),.writer_flush_done(flush_done),
    .writer_debt_zero(debt_zero),.writer_fault,
    .writer_awvalid(awvalid),.writer_wvalid(wvalid),
    .writer_aw_count(aw_count),.writer_w_count(w_count),
    .writer_b_count(b_count),.ok_b_count,.retired_tiles);
  tm1tn8_axi512_writer #(.SHARD(1'b0)) writer (
    .clk,.rst_n,.tile_valid,.tile_ready,
    .tile_f32(tile_bits),.tile_n0,
    .tile_row_local(2'd0),.tile_row0(10'd0),
    .tile_batch(1'b0),.tile_lanes(4'd8),.mode_qkv(1'b0),
    .rearm_valid,.rearm_ready,.flush_req,.flush_done,.debt_zero,
    .output_base,.output_span(64'd64),.fault(writer_fault),
    .aw_count,.w_count,.b_count,.useful_bytes,.physical_bytes,
    .m_axi_awaddr(awaddr),.m_axi_awlen(awlen),
    .m_axi_awsize(awsize),.m_axi_awburst(awburst),
    .m_axi_awvalid(awvalid),.m_axi_awready(awready),
    .m_axi_wdata(wdata),.m_axi_wstrb(wstrb),
    .m_axi_wlast(wlast),.m_axi_wvalid(wvalid),
    .m_axi_wready(wready),.m_axi_bresp(bresp),
    .m_axi_bvalid(bvalid),.m_axi_bready(bready));

  always @(posedge clk)begin
    if(!rst_n)begin
      rsp_pending<=0;rsp_valid<=0;rsp_tag<=0;rsp_bits<=0;
      output_base<=0;aw_seen<=0;w_seen<=0;b_delay<=0;
      actual_b<=0;cycle<=0;tile_offered<=1;
    end else begin
      cycle<=cycle+1;
      if(cycle>20000)$fatal(1,"REV22_PS_CTRL_CYCLE_CAP");
      if(segment_begin)begin
        if(segment_route!=0 || segment_address[64] || !debt_zero)
          $fatal(1,"REV22_PS_ROUTE");
        output_base<=segment_address[63:0];
      end
      if(rsp_valid && rsp_ready)rsp_valid<=0;
      if(rsp_pending)begin rsp_pending<=0;rsp_valid<=1;end
      if(read_accept)begin
        int row;
        row=int'(read_physical)-544;
        if(rsp_pending || rsp_valid || row<0 || row>=16 ||
           read_tag!=10'd896+10'(row))
          $fatal(1,"REV22_PS_BANK_READ row=%0d",row);
        rsp_tag<=read_tag;rsp_bits<=0;rsp_pending<=1;
        if(row<4)for(int lane=0;lane<8;lane++)begin
          int off;
          off=(row*3072+lane)*4;
          rsp_bits[lane*32+:32]<=
            {final_gold[off+3],final_gold[off+2],
             final_gold[off+1],final_gold[off]};
        end
      end
      if(awvalid && awready)begin
        if(awlen!=0 || awsize!=3'd6 || awburst!=2'd1 ||
           awaddr!=64'h30000000+64'(actual_b)*64'd256)
          $fatal(1,"REV22_PS_AW b=%0d addr=%h",actual_b,awaddr);
        aw_seen<=1;
      end
      if(wvalid && wready)begin
        if(!wlast || wstrb!==64'h00000000ffffffff)
          $fatal(1,"REV22_PS_W_STROBE b=%0d strobe=%h",actual_b,wstrb);
        if(actual_b<4)for(int lane=0;lane<8;lane++)begin
          int off;
          logic [31:0] expected;
          off=(actual_b*3072+lane)*4;
          expected={final_gold[off+3],final_gold[off+2],
                    final_gold[off+1],final_gold[off]};
          if(wdata[lane*32+:32]!==expected)
            $fatal(1,"REV22_PS_W_GOLD row=%0d lane=%0d",actual_b,lane);
        end
        w_seen<=1;b_delay<=0;
      end
      if(w_seen)b_delay<=b_delay+1;
      if(bvalid && bready)begin
        aw_seen<=0;w_seen<=0;b_delay<=0;
        actual_b<=actual_b+1;
      end
      if(link.matrix_ps_retire_valid && link.matrix_ps_retire_ready)
        tile_offered<=0;
    end
  end
  initial begin
    int fd,nread;
    if(!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"REV22_PS_CTRL_FIXTURE");
    fd=$fopen({fixture,"/qkv_rows4_output_f32.bin"},"rb");
    if(fd==0)$fatal(1,"REV22_PS_CTRL_GOLD_OPEN");
    nread=$fread(final_gold,fd);$fclose(fd);
    if(nread!=49152)$fatal(1,"REV22_PS_CTRL_GOLD_SIZE");
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);start_valid=1;active=1;
    @(negedge clk);start_valid=0;
    for(int guard=0;guard<20000 && tile_offered;guard++)
      @(negedge clk);
    if(tile_offered || actual_b!=16 || ok_b_count!=16 ||
       retired_tiles!=1 || !debt_zero || writer_fault)
      $fatal(1,"REV22_PS_CTRL_FINAL B=%0d ok=%0d retire=%0d debt=%b fault=%b",
          actual_b,ok_b_count,retired_tiles,debt_zero,writer_fault);
    $display("REV22_PS_WRITER_LOCAL_PASS rows=16 OKAY_B=16 retire=1 gold_rows=4");
    $finish;
  end
endmodule
