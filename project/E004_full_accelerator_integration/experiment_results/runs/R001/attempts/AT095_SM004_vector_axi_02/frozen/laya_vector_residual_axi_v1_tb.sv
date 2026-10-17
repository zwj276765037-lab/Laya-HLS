`timescale 1ns/1ps
module laya_vector_residual_axi_v1_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0,cfg_valid=0,cfg_ready,done_valid,done_ready=0;
  logic [63:0] cfg_src0_base=64'h10000,cfg_src1_base=64'h20000,cfg_dst_base=64'h40000;
  logic [31:0] cfg_elements=4096;
  logic [3:0] done_status;
  logic m_ar0valid,m_ar0ready,m_r0valid,m_r0ready,m_r0last;
  logic m_ar1valid,m_ar1ready,m_r1valid,m_r1ready,m_r1last;
  logic m_awvalid,m_awready,m_wvalid,m_wready,m_wlast,m_bvalid,m_bready;
  logic [63:0] m_ar0addr,m_ar1addr,m_awaddr,m_wstrb;
  logic [7:0] m_ar0len,m_ar1len,m_awlen;
  logic [2:0] m_ar0size,m_ar1size,m_awsize;
  logic [1:0] m_ar0burst,m_ar1burst,m_awburst,m_r0resp=0,m_r1resp=0,m_bresp=0;
  logic [511:0] m_r0data=0,m_r1data=0,m_wdata;
  logic [31:0] src0[0:4095],src1[0:4095],gold[0:4095],dst[0:16383];
  string a_file,b_file,gold_file;
  laya_vector_residual_axi_v1 dut (.*);

  function automatic [511:0] pack(input bit which,input integer beat);
    for (integer j=0;j<16;j++) pack[j*32 +: 32]=which ? src1[beat*16+j] : src0[beat*16+j];
  endfunction

  task automatic run_case(input integer mode);
    integer c,r0_index,r1_index,w_index,last_w_cycle,done_cycle;
    integer r0_block,r1_block,w_block,done_hold;
    bit cfg_seen,ar0_seen,ar1_seen,aw_seen,r0_pending,r1_pending,b_seen,done_consumed;
    begin
      @(negedge clk); rst_n=0; cfg_valid=0; done_ready=0;
      m_ar0ready=0; m_ar1ready=0; m_awready=0; m_wready=0;
      m_r0valid=0; m_r1valid=0; m_bvalid=0;
      repeat(3) @(negedge clk);
      rst_n=1;
      for (integer j=0;j<16384;j++) dst[j]=32'h7fc0beef;
      cfg_seen=0; ar0_seen=0; ar1_seen=0; aw_seen=0;
      r0_pending=0; r1_pending=0; b_seen=0; done_consumed=0;
      r0_index=0; r1_index=0; w_index=0;
      r0_block=0; r1_block=0; w_block=0; done_hold=0;
      last_w_cycle=-1; done_cycle=-1;
      for (c=0;c<30000 && !done_consumed;c++) begin
        @(negedge clk);
        cfg_valid=!cfg_seen;
        m_ar0ready=(mode==0 || c%5!=0);
        m_ar1ready=(mode==0 || c%7!=2);
        m_awready=(mode==0 || c%6!=3);
        m_wready=(mode==0 || c%9>=3);
        if (ar0_seen && !r0_pending && r0_index<256 && (mode==0 || c%11>=3)) begin
          r0_pending=1;
          m_r0data=pack(0,r0_index);
          m_r0last=(r0_index==255);
        end
        if (ar1_seen && !r1_pending && r1_index<256 && (mode==0 || c%13>=4)) begin
          r1_pending=1;
          m_r1data=pack(1,r1_index);
          m_r1last=(r1_index==255);
        end
        m_r0valid=r0_pending;
        m_r1valid=r1_pending;
        m_bvalid=(last_w_cycle>=0 && c-last_w_cycle>=7 && !b_seen);
        done_ready=(done_cycle>=0 && c-done_cycle>=5);
        @(posedge clk);
        if (cfg_valid && cfg_ready) cfg_seen=1;
        if (m_ar0valid && m_ar0ready) begin
          if (ar0_seen || m_ar0addr!==cfg_src0_base || m_ar0len!==8'd255 || m_ar0size!==3'd6 || m_ar0burst!==2'b01)
            $fatal(1,"VECTOR_AR0_BAD mode=%0d",mode);
          ar0_seen=1;
        end
        if (m_ar1valid && m_ar1ready) begin
          if (ar1_seen || m_ar1addr!==cfg_src1_base || m_ar1len!==8'd255 || m_ar1size!==3'd6 || m_ar1burst!==2'b01)
            $fatal(1,"VECTOR_AR1_BAD mode=%0d",mode);
          ar1_seen=1;
        end
        if (m_awvalid && m_awready) begin
          if (aw_seen || m_awaddr!==cfg_dst_base || m_awlen!==8'd255 || m_awsize!==3'd6 || m_awburst!==2'b01)
            $fatal(1,"VECTOR_AW_BAD mode=%0d",mode);
          aw_seen=1;
        end
        if (m_r0valid && !m_r0ready) r0_block++;
        if (m_r1valid && !m_r1ready) r1_block++;
        if (m_r0valid && m_r0ready) begin
          if (m_r0last !== (r0_index==255)) $fatal(1,"VECTOR_R0LAST_BAD beat=%0d",r0_index);
          r0_index++; r0_pending=0;
        end
        if (m_r1valid && m_r1ready) begin
          if (m_r1last !== (r1_index==255)) $fatal(1,"VECTOR_R1LAST_BAD beat=%0d",r1_index);
          r1_index++; r1_pending=0;
        end
        if (m_wvalid && !m_wready) w_block++;
        if (m_wvalid && m_wready) begin
          if (!aw_seen || m_wstrb!==64'hffffffffffffffff || m_wlast !== (w_index==255))
            $fatal(1,"VECTOR_W_PROTOCOL_BAD mode=%0d beat=%0d",mode,w_index);
          for (integer j=0;j<16;j++) begin
            if (m_wdata[j*32 +: 32] !== gold[w_index*16+j])
              $fatal(1,"VECTOR_AXI_GOLD_DIFF mode=%0d ordinal=%0d got=%08x gold=%08x",
                mode,w_index*16+j,m_wdata[j*32 +: 32],gold[w_index*16+j]);
            dst[w_index*16+j]=m_wdata[j*32 +: 32];
          end
          w_index++;
          if (w_index%64==0) $display("FFR0_PROGRESS VECTOR_AXI_W mode=%0d beats=%0d c=%0d",mode,w_index,c);
          if (w_index==256) last_w_cycle=c;
        end
        if (done_valid && !b_seen) $fatal(1,"VECTOR_DONE_BEFORE_B mode=%0d",mode);
        if (m_bvalid && m_bready) begin
          if (w_index!=256 || b_seen) $fatal(1,"VECTOR_B_BAD mode=%0d",mode);
          b_seen=1;
          $display("VECTOR_AXI_B mode=%0d c=%0d",mode,c);
        end
        if (done_valid) begin
          if (done_status!==0) $fatal(1,"VECTOR_DONE_STATUS mode=%0d status=%0d",mode,done_status);
          if (done_cycle<0) done_cycle=c;
          if (!done_ready) done_hold++;
          else done_consumed=1;
        end
      end
      @(negedge clk); cfg_valid=0; done_ready=0; m_r0valid=0; m_r1valid=0; m_bvalid=0;
      if (!done_consumed || done_valid || !cfg_ready || !ar0_seen || !ar1_seen || !aw_seen ||
          r0_index!=256 || r1_index!=256 || w_index!=256 || !b_seen || done_hold<5)
        $fatal(1,"VECTOR_AXI_DEBT mode=%0d r0=%0d r1=%0d w=%0d b=%0b done=%0b c=%0d",
          mode,r0_index,r1_index,w_index,b_seen,done_consumed,c);
      for (integer j=0;j<16384;j++)
        if (dst[j] !== (j<4096 ? gold[j] : 32'h7fc0beef))
          $fatal(1,"VECTOR_AXI_PROTECT mode=%0d ordinal=%0d got=%08x",mode,j,dst[j]);
      $display("VECTOR_AXI_CASE_PASS mode=%0d cycles=%0d ar=2 r=512 aw=1 w=256 b=1 bytes=49152 r0_block=%0d r1_block=%0d w_block=%0d done_hold=%0d",
        mode,c,r0_block,r1_block,w_block,done_hold);
    end
  endtask

  initial begin
    if (!$value$plusargs("A_FILE=%s",a_file) ||
        !$value$plusargs("B_FILE=%s",b_file) ||
        !$value$plusargs("GOLD_FILE=%s",gold_file)) $fatal(1,"VECTOR_AXI_MISSING_FIXTURE");
    $readmemh(a_file,src0); $readmemh(b_file,src1); $readmemh(gold_file,gold);
    for (integer j=0;j<4096;j++)
      if ($isunknown(src0[j]) || $isunknown(src1[j]) || $isunknown(gold[j]))
        $fatal(1,"VECTOR_AXI_UNKNOWN_FIXTURE ordinal=%0d",j);
    run_case(0);
    run_case(1);
    $display("VECTOR_AXI_PASS normal=4096 backpressure=4096");
    $finish;
  end
  initial begin
    repeat(100000) @(posedge clk);
    $fatal(1,"VECTOR_AXI_TIMEOUT");
  end
endmodule
