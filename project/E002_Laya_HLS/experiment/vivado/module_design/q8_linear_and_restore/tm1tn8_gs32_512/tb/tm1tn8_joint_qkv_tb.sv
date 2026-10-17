`timescale 1ns/1ps
module tm1tn8_joint_qkv_tb;
  localparam int MAX_ISSUES=49152, MAX_OUTPUT=12288;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n;
  logic [255:0] cfg_tdata, compute_cfg_tdata;
  logic cfg_tvalid, cfg_tready, compute_cfg_tvalid, compute_cfg_tready;
  logic [287:0] bias_tdata;
  logic bias_tvalid, bias_tready;
  logic [2815:0] group_tdata;
  logic group_tvalid, group_tready, finish_tvalid, finish_tready;
  logic [511:0] completion_tdata;
  logic completion_tvalid, completion_tready;
  logic [63:0] observed_base, observed_span;
  logic trace_command_start;
  logic [63:0] observed_awaddr, m0_awaddr, m1_awaddr;
  logic [7:0] observed_awlen, m0_awlen, m1_awlen;
  logic [2:0] observed_awsize, m0_awsize, m1_awsize;
  logic [1:0] observed_awburst, m0_awburst, m1_awburst;
  logic observed_awvalid, observed_awready, m0_awvalid, m0_awready,
        m1_awvalid, m1_awready;
  logic [31:0] observed_wdata;
  logic [3:0] observed_wstrb;
  logic observed_wlast, observed_wvalid, observed_wready;
  logic [511:0] m0_wdata, m1_wdata;
  logic [63:0] m0_wstrb, m1_wstrb;
  logic m0_wlast, m0_wvalid, m0_wready, m1_wlast, m1_wvalid, m1_wready;
  logic [1:0] observed_bresp, m0_bresp, m1_bresp;
  logic observed_bvalid, observed_bready, m0_bvalid, m0_bready,
        m1_bvalid, m1_bready;
  logic all_writer_debt_zero, any_writer_fault;
  tm1tn8_joint_bridge dut (.*);
  localparam logic [63:0] OBS_BASE=64'h0000_0001_0000_1000;
  localparam logic [63:0] OUT0_BASE=64'h0000_0002_0000_0000;
  localparam logic [63:0] OUT1_BASE=64'h0000_0003_0000_0000;
  logic [255:0] va [0:MAX_ISSUES-1], vdot [0:MAX_ISSUES-1],
                vdotf [0:MAX_ISSUES-1],
                vproduct [0:MAX_ISSUES-1], vterm [0:MAX_ISSUES-1],
                vps [0:MAX_ISSUES-1], vsw [0:MAX_ISSUES-1];
  logic [2047:0] vw [0:MAX_ISSUES-1];
  logic [31:0] vsa [0:MAX_ISSUES-1], vout [0:MAX_OUTPUT-1];
  logic [7:0] vmask [0:MAX_ISSUES-1];
  string vec_dir;
  int rows, trace_on, total, cycles, commits, issues;
  int dot_checked, term_checked;
  int aw0,w0,b0,aw1,w1,b1,awt,wt,bt;
  logic p0,p1,pt;
  int hold0,hold1,holdt;

  function automatic logic [63:0] expected_addr(input int shard, beat);
    int row, local_beat, head_in_shard, plane, local_head, d;
    logic [63:0] relative;
    row=beat/96;
    local_beat=beat%96;
    head_in_shard=local_beat/4;
    plane=head_in_shard/8;
    local_head=head_in_shard%8;
    d=(local_beat%4)*16;
    relative=64'((((plane*2)*8+local_head)*1024+row)*64+d)*4;
    return (shard ? OUT1_BASE : OUT0_BASE)+relative;
  endfunction
  function automatic int expected_n(input int shard, beat, lane);
    int local_beat, head_in_shard, plane, local_head, d;
    local_beat=beat%96;
    head_in_shard=local_beat/4;
    plane=head_in_shard/8;
    local_head=head_in_shard%8;
    d=(local_beat%4)*16;
    return plane*1024+(local_head*2+shard)*64+d+lane;
  endfunction
  function automatic logic [31:0] trace_expected(input int g,j);
    int seq;
    seq=g*384;
    case (j)
      0: return vdot[seq][31:0];
      1: return vsa[seq];
      2: return vsw[seq][31:0];
      3: return vproduct[seq][31:0];
      4: return vterm[seq][31:0];
      5: return vps[seq][31:0];
      6: return 32'(g);
      default: return 32'd1;
    endcase
  endfunction
  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] &&
          actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"QKV %s mismatch issue=%0d lane=%0d got=%h exp=%h",
               stage,seq,lane,actual[lane*32 +: 32],
               expected[lane*32 +: 32]);
  endtask
  task automatic send_cfg;
    @(negedge clk);
    cfg_tdata=0;
    cfg_tdata[63:0]=OUT0_BASE;
    cfg_tdata[127:64]=64'd12582912;
    cfg_tdata[191:128]=OUT1_BASE;
    cfg_tdata[255:192]=64'd12582912;
    cfg_tvalid=1;
    do @(posedge clk); while (!cfg_tready);
    @(negedge clk); cfg_tvalid=0;
    compute_cfg_tdata=0;
    compute_cfg_tdata[31:0]=1024;
    compute_cfg_tdata[63:32]=3072;
    compute_cfg_tdata[95:64]=32'(rows);
    compute_cfg_tdata[191:160]=8'h30;
    compute_cfg_tdata[223:192]=3;
    compute_cfg_tdata[224]=trace_on!=0;
    compute_cfg_tdata[225]=1;
    compute_cfg_tvalid=1;
    do @(posedge clk); while (!compute_cfg_tready);
    @(negedge clk); compute_cfg_tvalid=0;
  endtask
  task automatic send_biases;
    for (int tile=0; tile<384; tile++) begin
      @(negedge clk);
      bias_tdata=0;
      bias_tdata[264:256]=9'(tile);
      bias_tdata[272:265]=8'hff;
      bias_tvalid=1;
      do @(posedge clk); while (!bias_tready);
      @(negedge clk); bias_tvalid=0;
    end
  endtask
  task automatic send_group(input int seq);
    int row,g,tile;
    row=seq/(32*384);
    g=(seq/384)%32;
    tile=seq%384;
    @(negedge clk);
    group_tdata=0;
    group_tdata[255:0]=va[seq];
    group_tdata[2303:256]=vw[seq];
    group_tdata[2335:2304]=vsa[seq];
    group_tdata[2591:2336]=vsw[seq];
    group_tdata[2600:2592]=9'(tile);
    group_tdata[2606:2601]=6'(g);
    group_tdata[2608:2607]=2'(row);
    group_tdata[2616:2609]=vmask[seq];
    group_tdata[2617]=trace_on!=0 && row==0 && tile==0;
    group_tdata[2621]=(g==31);
    group_tdata[2653:2622]=3;
    group_tdata[2685:2654]=1;
    group_tdata[2717:2686]=1;
    group_tdata[2781:2718]=64'h1234;
    group_tvalid=1;
    do @(posedge clk); while (!group_tready);
    @(negedge clk); group_tvalid=0;
  endtask

  always @(posedge clk) if (rst_n) begin
    int seq,row,n;
    cycles <= cycles+1;
    if (cycles>2000000) $fatal(1,"QKV joint cycle timeout");
    if (group_tvalid && group_tready) issues <= issues+1;
    if (dut.ps_controller.arithmetic.commit_valid &&
        dut.ps_controller.arithmetic.commit_ready) begin
      seq=int'(dut.ps_controller.arithmetic.commit_tag[62:36]);
      if (seq!=commits || seq>=total ||
          dut.ps_controller.arithmetic.commit_bad_mask!==0 ||
          dut.ps_controller.arithmetic.commit_lane_mask!==8'hff)
        $fatal(1,"QKV PS commit identity seq=%0d expected=%0d",seq,commits);
      compare_lanes(dut.ps_controller.arithmetic.commit_next_ps,
                    vps[seq],vmask[seq],seq,"PS");
      commits <= commits+1;
    end
    if (m0_awvalid && m0_awready) begin
      if (m0_awaddr !== expected_addr(0,aw0) || m0_awlen!==0 ||
          m0_awsize!==6) $fatal(1,"QKV out0 AW beat=%0d",aw0);
      aw0 <= aw0+1;
    end
    if (m1_awvalid && m1_awready) begin
      if (m1_awaddr !== expected_addr(1,aw1) || m1_awlen!==0 ||
          m1_awsize!==6) $fatal(1,"QKV out1 AW beat=%0d",aw1);
      aw1 <= aw1+1;
    end
    if (m0_wvalid && m0_wready) begin
      row=w0/96;
      if (m0_wstrb !== '1 || !m0_wlast)
        $fatal(1,"QKV out0 WSTRB beat=%0d",w0);
      for (int lane=0;lane<16;lane++) begin
        n=expected_n(0,w0,lane);
        if (m0_wdata[lane*32 +: 32] !== vout[row*3072+n])
          $fatal(1,"QKV out0 data row=%0d n=%0d",row,n);
      end
      w0 <= w0+1; p0 <= 1; hold0 <= 2;
    end
    if (m1_wvalid && m1_wready) begin
      row=w1/96;
      if (m1_wstrb !== '1 || !m1_wlast)
        $fatal(1,"QKV out1 WSTRB beat=%0d",w1);
      for (int lane=0;lane<16;lane++) begin
        n=expected_n(1,w1,lane);
        if (m1_wdata[lane*32 +: 32] !== vout[row*3072+n])
          $fatal(1,"QKV out1 data row=%0d n=%0d",row,n);
      end
      w1 <= w1+1; p1 <= 1; hold1 <= 3;
    end
    if (m0_bvalid && m0_bready) begin
      b0 <= b0+1; m0_bvalid <= 0; p0 <= 0;
    end else if (p0 && !m0_bvalid) begin
      if (hold0!=0) hold0<=hold0-1;
      else m0_bvalid<=1;
    end
    if (m1_bvalid && m1_bready) begin
      b1 <= b1+1; m1_bvalid <= 0; p1 <= 0;
    end else if (p1 && !m1_bvalid) begin
      if (hold1!=0) hold1<=hold1-1;
      else m1_bvalid<=1;
    end
    if (observed_awvalid && observed_awready) begin
      if (!trace_on || observed_awaddr !==
          OBS_BASE+64'd70656+64'(awt/8)*32+64'(awt%8)*4 ||
          observed_awlen!==0 || observed_awsize!==2)
        $fatal(1,"QKV trace AW word=%0d",awt);
      awt<=awt+1;
    end
    if (observed_wvalid && observed_wready) begin
      if (!trace_on || observed_wdata !== trace_expected(wt/8,wt%8) ||
          observed_wstrb!==4'hf || !observed_wlast)
        $fatal(1,"QKV trace W word=%0d",wt);
      wt<=wt+1; pt<=1; holdt<=wt%8==7 ? 12 : 2;
    end
    if (observed_bvalid && observed_bready) begin
      bt<=bt+1; observed_bvalid<=0; pt<=0;
    end else if (pt && !observed_bvalid) begin
      if (holdt!=0) holdt<=holdt-1;
      else observed_bvalid<=1;
    end
    if (completion_tvalid &&
        (commits!=total || b0!=96*rows || b1!=96*rows ||
         bt!=(trace_on ? 256 : 0) || !all_writer_debt_zero))
      $fatal(1,"QKV completion before PS/output/trace B drain");
  end

  always @(negedge clk) if (rst_n) begin
    int seq;
    if (dut.ps_controller.arithmetic.fp_restore.valid_c) begin
      seq=int'(dut.ps_controller.arithmetic.fp_restore.meta_c.tag[62:36]);
      if (seq<0 || seq>=total) $fatal(1,"QKV converted tag out of range");
      compare_lanes(dut.ps_controller.arithmetic.fp_restore.meta_c.dot,
                    vdot[seq],vmask[seq],seq,"dot");
      compare_lanes(dut.ps_controller.arithmetic.fp_restore.dot_float_c,
                    vdotf[seq],vmask[seq],seq,"dotf");
      compare_lanes(dut.ps_controller.arithmetic.fp_restore.scale_product_c,
                    vproduct[seq],vmask[seq],seq,"scale product");
      dot_checked++;
    end
    if (dut.ps_controller.arithmetic.fp_restore.valid_add) begin
      seq=int'(dut.ps_controller.arithmetic.fp_restore.tag_add[62:36]);
      if (seq<0 || seq>=total) $fatal(1,"QKV term tag out of range");
      compare_lanes(dut.ps_controller.arithmetic.fp_restore.term_add,
                    vterm[seq],vmask[seq],seq,"term");
      term_checked++;
    end
  end

  initial begin : test
    if (!$value$plusargs("VEC_DIR=%s",vec_dir) ||
        !$value$plusargs("ROWS=%d",rows) ||
        !$value$plusargs("TRACE=%d",trace_on) ||
        (rows!=1 && rows!=4) || (trace_on!=0 && trace_on!=1))
      $fatal(1,"VEC_DIR/ROWS=1|4/TRACE=0|1 required");
    total=rows*32*384;
    $readmemh({vec_dir,"/a.hex"},va);
    $readmemh({vec_dir,"/w.hex"},vw);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    $readmemh({vec_dir,"/sw.hex"},vsw);
    $readmemh({vec_dir,"/mask.hex"},vmask);
    $readmemh({vec_dir,"/dot.hex"},vdot);
    $readmemh({vec_dir,"/dotf.hex"},vdotf);
    $readmemh({vec_dir,"/product.hex"},vproduct);
    $readmemh({vec_dir,"/term.hex"},vterm);
    $readmemh({vec_dir,"/ps.hex"},vps);
    $readmemh({vec_dir,"/output.hex"},vout);
    rst_n=0; cfg_tdata=0; compute_cfg_tdata=0;
    cfg_tvalid=0; compute_cfg_tvalid=0; bias_tdata=0; bias_tvalid=0;
    group_tdata=0; group_tvalid=0; finish_tvalid=0;
    completion_tready=0;
    observed_base=OBS_BASE; observed_span=64'd131072;
    trace_command_start=0;
    observed_awready=1; observed_wready=1;
    observed_bresp=0; observed_bvalid=0;
    m0_awready=1; m0_wready=1; m0_bresp=0; m0_bvalid=0;
    m1_awready=1; m1_wready=1; m1_bresp=0; m1_bvalid=0;
    cycles=0; commits=0; issues=0; dot_checked=0; term_checked=0;
    aw0=0; w0=0; b0=0; aw1=0; w1=0; b1=0;
    awt=0; wt=0; bt=0; p0=0; p1=0; pt=0;
    hold0=0; hold1=0; holdt=0;
    repeat (16) @(negedge clk);
    rst_n=1;
    trace_command_start=1;
    @(negedge clk); trace_command_start=0;
    send_cfg();
    send_biases();
    for (int seq=0;seq<total;seq++) send_group(seq);
    @(negedge clk); finish_tvalid=1;
    do @(posedge clk); while (!finish_tready);
    @(negedge clk); finish_tvalid=0;
    wait(completion_tvalid);
    @(negedge clk);
    if (completion_tdata[0] || completion_tdata[129] ||
        completion_tdata[64:1]!==64'(rows*96*64) ||
        completion_tdata[128:65]!==64'(rows*96*64) ||
        completion_tdata[257:226]!==32'(total) ||
        completion_tdata[289:258]!==32'(rows*3072) ||
        completion_tdata[353:290]!==64'(rows*3145728) ||
        completion_tdata[449:418]!==32'(trace_on ? 32 : 0) ||
        any_writer_fault || aw0!=96*rows || aw1!=96*rows ||
        wt!=(trace_on ? 256 : 0) || commits!=total ||
        issues!=total || dot_checked!=total || term_checked!=total)
      $fatal(1,"QKV joint completion statistics");
    completion_tready=1;
    @(negedge clk); completion_tready=0;
    $display("TM1TN8_JOINT_QKV_PASS rows=%0d trace=%0d groups=%0d dot=%0d term=%0d outB=%0d traceB=%0d",
             rows,trace_on,total,dot_checked,term_checked,b0+b1,bt);
    $finish;
  end
endmodule
