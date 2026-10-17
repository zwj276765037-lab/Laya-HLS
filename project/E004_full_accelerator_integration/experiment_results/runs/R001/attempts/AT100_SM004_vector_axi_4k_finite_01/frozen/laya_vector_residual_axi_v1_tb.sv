`timescale 1ns/1ps
module laya_vector_residual_axi_v1_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0,cfg_valid=0,cfg_ready,done_valid,done_ready=0;
  logic [63:0] cfg_src0_base=0,cfg_src1_base=0,cfg_dst_base=0;
  logic [31:0] cfg_elements=0;
  logic [3:0] done_status;
  logic [31:0] done_bad_element;
  logic m_ar0valid,m_ar0ready,m_r0valid,m_r0ready,m_r0last;
  logic m_ar1valid,m_ar1ready,m_r1valid,m_r1ready,m_r1last;
  logic m_awvalid,m_awready,m_wvalid,m_wready,m_wlast,m_bvalid,m_bready;
  logic [63:0] m_ar0addr,m_ar1addr,m_awaddr,m_wstrb;
  logic [7:0] m_ar0len,m_ar1len,m_awlen;
  logic [2:0] m_ar0size,m_ar1size,m_awsize;
  logic [1:0] m_ar0burst,m_ar1burst,m_awburst,m_r0resp=0,m_r1resp=0,m_bresp=0;
  logic [511:0] m_r0data=0,m_r1data=0,m_wdata;
  logic [31:0] src0[0:4095],src1[0:4095],base0[0:4095],base1[0:4095];
  logic [31:0] gold[0:4095],dst[0:16383];
  string a_file,b_file,gold_file;
  laya_vector_residual_axi_v1 dut (.*);

  function automatic [511:0] pack(input bit which,input integer beat);
    for (integer j=0;j<16;j++)
      pack[j*32 +: 32]=which ? src1[beat*16+j] : src0[beat*16+j];
  endfunction

  function automatic integer page_chunk(input integer beat,
      input integer total_beats,input logic [63:0] a,b,d);
    integer n,p;
    begin
      n=total_beats-beat;
      p=(4096-((a+beat*64)%4096))/64; if(p<n)n=p;
      p=(4096-((b+beat*64)%4096))/64; if(p<n)n=p;
      p=(4096-((d+beat*64)%4096))/64; if(p<n)n=p;
      page_chunk=n;
    end
  endfunction

  task automatic check_ax(input logic [63:0] got_addr,
      input logic [7:0] got_len,input logic [2:0] got_size,
      input logic [1:0] got_burst,input logic [63:0] base,
      input integer beat,input integer total_beats,input integer test_id);
    integer n;
    begin
      n=page_chunk(beat,total_beats,cfg_src0_base,cfg_src1_base,cfg_dst_base);
      if(got_addr !== base+beat*64 || got_len !== n-1 ||
         got_size !== 3'd6 || got_burst !== 2'b01 ||
         got_addr[5:0] !== 0 || got_addr[11:0]+(got_len+1)*64>4096)
        $fatal(1,"AXI4_4K_OR_AX_BAD test=%0d beat=%0d addr=%h len=%0d expected_len=%0d",
          test_id,beat,got_addr,got_len,n-1);
    end
  endtask

  // kind: 0 normal; 1 input NaN at 7; 2 overflow at 2 plus later NaN at 5;
  // 3 first R0 response error; 4 first write response error.
  task automatic run_case(input integer test_id,input integer elements,
      input logic [63:0] a,b,d,input bit throttle,input integer kind);
    integer c,total_beats,r0_index,r1_index,w_index;
    integer r0_left,r1_left,w_left,ar0_count,ar1_count,aw_count,b_count;
    integer expected_chunks,first_chunk,first_bad_expected,write_prefix;
    integer last_w_cycle,done_cycle,done_hold,r0_block,r1_block,w_block;
    integer chunk_beat;
    bit cfg_seen,done_consumed,ar0_active,ar1_active,aw_active;
    bit r0_pending,r1_pending,b_pending,w_blocked_prev;
    logic [511:0] w_held_data;
    logic [63:0] w_held_strb;
    logic w_held_last;
    logic [63:0] expected_strb;
    begin
      @(negedge clk);
      cfg_valid=0; done_ready=0;
      cfg_src0_base=a; cfg_src1_base=b; cfg_dst_base=d;
      cfg_elements=elements; total_beats=elements/16;
      for(integer j=0;j<4096;j++) begin src0[j]=base0[j]; src1[j]=base1[j]; end
      if(kind==1) src0[7]=32'h7fc00000;
      if(kind==2) begin
        src0[2]=32'h7f7fffff; src1[2]=32'h7f7fffff;
        src0[5]=32'h7fc00000;
      end
      for(integer j=0;j<16384;j++) dst[j]=32'h7fc0beef;
      expected_chunks=0; chunk_beat=0;
      first_chunk=page_chunk(0,total_beats,a,b,d);
      while(chunk_beat<total_beats) begin
        chunk_beat+=page_chunk(chunk_beat,total_beats,a,b,d);
        expected_chunks++;
      end
      first_bad_expected=kind==1 ? 7 : kind==2 ? 2 : -1;
      write_prefix=kind==1 ? 7 : kind==2 ? 2 : kind==3 ? 0 :
                   kind==4 ? first_chunk*16 : elements;
      cfg_seen=0; done_consumed=0;
      ar0_active=0; ar1_active=0; aw_active=0;
      r0_pending=0; r1_pending=0; b_pending=0;
      r0_left=0; r1_left=0; w_left=0;
      r0_index=0; r1_index=0; w_index=0;
      ar0_count=0; ar1_count=0; aw_count=0; b_count=0;
      last_w_cycle=-1; done_cycle=-1; done_hold=0;
      r0_block=0; r1_block=0; w_block=0; w_blocked_prev=0;
      for(c=0;c<30000 && !done_consumed;c++) begin
        @(negedge clk);
        cfg_valid=!cfg_seen;
        m_ar0ready=!throttle || c%5!=0;
        m_ar1ready=!throttle || c%7!=2;
        m_awready=!throttle || c%6!=3;
        m_wready=!throttle || c%7>=3;
        if(ar0_active && !r0_pending && (!throttle || c%11>=3)) begin
          r0_pending=1;
          m_r0data=pack(0,r0_index);
          m_r0last=(r0_left==1);
          m_r0resp=(kind==3 && r0_index==0) ? 2'b10 : 0;
        end
        if(ar1_active && !r1_pending && (!throttle || c%13>=4)) begin
          r1_pending=1;
          m_r1data=pack(1,r1_index);
          m_r1last=(r1_left==1);
          m_r1resp=0;
        end
        m_r0valid=r0_pending; m_r1valid=r1_pending;
        m_bvalid=b_pending && c-last_w_cycle>=7;
        m_bresp=(kind==4 && b_count==0) ? 2'b10 : 0;
        done_ready=done_cycle>=0 && c-done_cycle>=5;
        @(posedge clk);
        if(cfg_valid && cfg_ready) cfg_seen=1;
        if(m_ar0valid && m_ar0ready) begin
          if(ar0_active) $fatal(1,"AR0_DOUBLE test=%0d",test_id);
          check_ax(m_ar0addr,m_ar0len,m_ar0size,m_ar0burst,a,r0_index,total_beats,test_id);
          ar0_left=m_ar0len+1; ar0_active=1; ar0_count++;
        end
        if(m_ar1valid && m_ar1ready) begin
          if(ar1_active) $fatal(1,"AR1_DOUBLE test=%0d",test_id);
          check_ax(m_ar1addr,m_ar1len,m_ar1size,m_ar1burst,b,r1_index,total_beats,test_id);
          ar1_left=m_ar1len+1; ar1_active=1; ar1_count++;
        end
        if(m_awvalid && m_awready) begin
          if(aw_active || b_pending) $fatal(1,"AW_DOUBLE test=%0d",test_id);
          check_ax(m_awaddr,m_awlen,m_awsize,m_awburst,d,w_index,total_beats,test_id);
          w_left=m_awlen+1; aw_active=1; aw_count++;
        end
        if(m_r0valid && !m_r0ready) r0_block++;
        if(m_r1valid && !m_r1ready) r1_block++;
        if(m_r0valid && m_r0ready) begin
          if(!ar0_active || m_r0last !== (r0_left==1))
            $fatal(1,"R0_LAST test=%0d beat=%0d",test_id,r0_index);
          r0_left--; r0_index++; r0_pending=0;
          if(r0_left==0) ar0_active=0;
        end
        if(m_r1valid && m_r1ready) begin
          if(!ar1_active || m_r1last !== (r1_left==1))
            $fatal(1,"R1_LAST test=%0d beat=%0d",test_id,r1_index);
          r1_left--; r1_index++; r1_pending=0;
          if(r1_left==0) ar1_active=0;
        end
        if(w_blocked_prev &&
           (!m_wvalid || m_wdata !== w_held_data ||
            m_wstrb !== w_held_strb || m_wlast !== w_held_last))
          $fatal(1,"W_HOLD test=%0d beat=%0d",test_id,w_index);
        w_blocked_prev=m_wvalid && !m_wready;
        if(w_blocked_prev) begin
          w_block++; w_held_data=m_wdata;
          w_held_strb=m_wstrb; w_held_last=m_wlast;
        end
        if(m_wvalid && m_wready) begin
          if(!aw_active || m_wlast !== (w_left==1))
            $fatal(1,"W_LAST test=%0d beat=%0d",test_id,w_index);
          expected_strb=0;
          for(integer j=0;j<16;j++)
            if(w_index*16+j<write_prefix)
              expected_strb[j*4 +: 4]=4'hf;
          if(m_wstrb !== expected_strb)
            $fatal(1,"W_STRB test=%0d beat=%0d got=%h expected=%h",
              test_id,w_index,m_wstrb,expected_strb);
          for(integer j=0;j<16;j++) if(expected_strb[j*4 +: 4]!=0) begin
            if(m_wdata[j*32 +: 32] !== gold[w_index*16+j])
              $fatal(1,"GOLD_DIFF test=%0d ordinal=%0d got=%08x expected=%08x",
                test_id,w_index*16+j,m_wdata[j*32 +: 32],gold[w_index*16+j]);
            dst[w_index*16+j]=m_wdata[j*32 +: 32];
          end
          w_left--; w_index++;
          if(w_left==0) begin
            aw_active=0; b_pending=1; last_w_cycle=c;
          end
          if(w_index%64==0) $display("FFR0_PROGRESS VECTOR_AXI_W test=%0d beats=%0d c=%0d",test_id,w_index,c);
        end
        if(done_valid && (b_pending || b_count!=aw_count || b_count==0))
          $fatal(1,"DONE_BEFORE_B test=%0d",test_id);
        if(m_bvalid && m_bready) begin
          if(!b_pending || b_count>=aw_count) $fatal(1,"B_DEBT test=%0d",test_id);
          b_pending=0; b_count++;
        end
        if(done_valid) begin
          if(done_status !== ((kind==1 || kind==2) ? 4'd6 :
                              (kind==3 || kind==4) ? 4'd8 : 4'd0) ||
             done_bad_element !== (first_bad_expected<0 ? 32'hffffffff : first_bad_expected))
            $fatal(1,"DONE_STATUS test=%0d status=%0d bad=%0d",
              test_id,done_status,done_bad_element);
          if(done_cycle<0) done_cycle=c;
          if(!done_ready) done_hold++;
          else done_consumed=1;
        end
      end
      @(negedge clk);
      cfg_valid=0; done_ready=0;
      m_r0valid=0; m_r1valid=0; m_bvalid=0;
      if(!done_consumed || done_valid || !cfg_ready ||
         r0_index!=total_beats || r1_index!=total_beats || w_index!=total_beats ||
         ar0_count!=expected_chunks || ar1_count!=expected_chunks ||
         aw_count!=expected_chunks || b_count!=expected_chunks ||
         r0_left!=0 || r1_left!=0 || w_left!=0 || b_pending || done_hold<5)
        $fatal(1,"AXI_DEBT test=%0d r=%0d/%0d w=%0d ar=%0d/%0d aw=%0d b=%0d chunks=%0d",
          test_id,r0_index,r1_index,w_index,ar0_count,ar1_count,aw_count,b_count,expected_chunks);
      for(integer j=0;j<16384;j++)
        if(dst[j] !== (j<write_prefix ? gold[j] : 32'h7fc0beef))
          $fatal(1,"PROTECT test=%0d ordinal=%0d got=%08x",test_id,j,dst[j]);
      $display("VECTOR_AXI_CASE_PASS test=%0d cycles=%0d ar=%0d r=%0d aw=%0d w=%0d b=%0d bytes=%0d first_bad=%0d r0_block=%0d r1_block=%0d w_block=%0d",
        test_id,c,ar0_count+ar1_count,r0_index+r1_index,aw_count,w_index,b_count,
        (r0_index+r1_index+w_index)*64,first_bad_expected,r0_block,r1_block,w_block);
    end
  endtask

  initial begin
    if(!$value$plusargs("A_FILE=%s",a_file) ||
       !$value$plusargs("B_FILE=%s",b_file) ||
       !$value$plusargs("GOLD_FILE=%s",gold_file))
      $fatal(1,"VECTOR_AXI_MISSING_FIXTURE");
    $readmemh(a_file,base0); $readmemh(b_file,base1); $readmemh(gold_file,gold);
    for(integer j=0;j<4096;j++)
      if($isunknown(base0[j]) || $isunknown(base1[j]) || $isunknown(gold[j]))
        $fatal(1,"UNKNOWN_FIXTURE ordinal=%0d",j);
    repeat(3) @(negedge clk);
    rst_n=1;
    run_case(0,4096,64'h10000,64'h20000,64'h40000,0,0);
    run_case(1,4096,64'h10000,64'h20000,64'h40000,1,0);
    run_case(2,4096,64'h10040,64'h20000,64'h40000,0,0);
    run_case(3,4096,64'h10000,64'h20080,64'h40000,0,0);
    run_case(4,4096,64'h10000,64'h20000,64'h400c0,0,0);
    run_case(5,1120,64'h10040,64'h20080,64'h400c0,1,0);
    run_case(6,4096,64'h10000,64'h20000,64'h40000,1,1);
    run_case(7,4096,64'h10000,64'h20000,64'h40000,1,2);
    run_case(8,4096,64'h10000,64'h20000,64'h40000,1,3);
    run_case(9,4096,64'h10000,64'h20000,64'h40000,1,4);
    $display("VECTOR_AXI_PASS cases=10 sequential_no_reset=1");
    $finish;
  end
  initial begin
    repeat(250000) @(posedge clk);
    $fatal(1,"VECTOR_AXI_TIMEOUT");
  end
endmodule
