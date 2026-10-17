`timescale 1ns/1ps
module tm1tn8_joint_act_tb;
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
  localparam logic [63:0] OUT_BASE=64'h0000_0002_0000_2004;
  logic [255:0] va [0:7], vdot [0:7], vproduct [0:7],
                vterm [0:7], vps [0:7], vsw [0:7];
  logic [2047:0] vw [0:7];
  logic [31:0] vsa [0:7], vbias [0:1], vout [0:1];
  logic [7:0] vmask [0:7];
  string vec_dir;
  int commits, aw0, w0, b0, awt, wt, bt, cycles;
  int trace_hold, output_hold;
  logic trace_pending, output_pending;

  function automatic logic [31:0] trace_expected(input int g, input int j);
    case (j)
      0: return vdot[g][31:0];
      1: return vsa[g];
      2: return vsw[g][31:0];
      3: return vproduct[g][31:0];
      4: return vterm[g][31:0];
      5: return vps[g][31:0];
      6: return 32'(g);
      default: return 32'd1;
    endcase
  endfunction
  task automatic send_config;
    @(negedge clk);
    cfg_tdata=0;
    cfg_tdata[63:0]=OUT_BASE;
    cfg_tdata[127:64]=8;
    cfg_tvalid=1;
    do @(posedge clk); while (!cfg_tready);
    @(negedge clk); cfg_tvalid=0;
    compute_cfg_tdata=0;
    compute_cfg_tdata[31:0]=256;
    compute_cfg_tdata[63:32]=2;
    compute_cfg_tdata[95:64]=1;
    compute_cfg_tdata[191:160]=8'h37;
    compute_cfg_tdata[223:192]=3;
    compute_cfg_tdata[224]=1;
    compute_cfg_tdata[225]=1;
    compute_cfg_tvalid=1;
    do @(posedge clk); while (!compute_cfg_tready);
    @(negedge clk); compute_cfg_tvalid=0;
  endtask
  task automatic send_bias;
    @(negedge clk);
    bias_tdata=0;
    bias_tdata[31:0]=vbias[0];
    bias_tdata[63:32]=vbias[1];
    bias_tdata[272:265]=8'h03;
    bias_tdata[273]=1;
    bias_tvalid=1;
    do @(posedge clk); while (!bias_tready);
    @(negedge clk); bias_tvalid=0;
  endtask
  task automatic send_group(input int g);
    @(negedge clk);
    group_tdata=0;
    group_tdata[255:0]=va[g];
    group_tdata[2303:256]=vw[g];
    group_tdata[2335:2304]=vsa[g];
    group_tdata[2591:2336]=vsw[g];
    group_tdata[2606:2601]=6'(g);
    group_tdata[2616:2609]=vmask[g];
    group_tdata[2617]=1;
    group_tdata[2621]=(g==7);
    group_tdata[2653:2622]=3;
    group_tdata[2685:2654]=1;
    group_tdata[2717:2686]=1;
    group_tdata[2781:2718]=64'h1234;
    group_tvalid=1;
    do @(posedge clk); while (!group_tready);
    @(negedge clk); group_tvalid=0;
  endtask

  always @(posedge clk) if (rst_n) begin
    int seq;
    cycles <= cycles+1;
    if (cycles>10000) $fatal(1,"ACT joint timeout");
    if (dut.ps_controller.arithmetic.commit_valid &&
        dut.ps_controller.arithmetic.commit_ready) begin
      seq=int'(dut.ps_controller.arithmetic.commit_tag[62:36]);
      if (seq!=commits || seq>=8 ||
          dut.ps_controller.arithmetic.commit_bad_mask!==0 ||
          dut.ps_controller.arithmetic.commit_lane_mask!==8'h03)
        $fatal(1,"actual PS commit order/mask seq=%0d",seq);
      for (int lane=0; lane<2; lane++)
        if (dut.ps_controller.arithmetic.commit_next_ps[lane*32 +: 32] !==
            vps[seq][lane*32 +: 32])
          $fatal(1,"actual PS mismatch g=%0d lane=%0d",seq,lane);
      commits <= commits+1;
    end
    if (observed_awvalid && observed_awready) begin
      if (observed_awaddr !== OBS_BASE+64'd70656+64'(awt/8)*32+
                              64'(awt%8)*4 ||
          observed_awlen!==0 || observed_awsize!==2)
        $fatal(1,"trace AW order/address n=%0d",awt);
      awt <= awt+1;
    end
    if (observed_wvalid && observed_wready) begin
      if (observed_wdata !== trace_expected(wt/8,wt%8) ||
          observed_wstrb!==4'hf || !observed_wlast)
        $fatal(1,"real ACT trace word n=%0d",wt);
      wt <= wt+1;
      trace_pending <= 1;
      trace_hold <= wt%8==7 ? 12 : 2;
    end
    if (observed_bvalid && observed_bready) begin
      bt <= bt+1;
      observed_bvalid <= 0;
      trace_pending <= 0;
    end else if (trace_pending && !observed_bvalid) begin
      if (trace_hold!=0) trace_hold <= trace_hold-1;
      else observed_bvalid <= 1;
    end
    if (m0_awvalid && m0_awready) begin
      if (m0_awaddr !== (OUT_BASE & ~64'd63) ||
          m0_awlen!==0 || m0_awsize!==6)
        $fatal(1,"ACT output AW");
      aw0 <= aw0+1;
    end
    if (m0_wvalid && m0_wready) begin
      if (m0_wstrb !== 64'h0000_0000_0000_0ff0 ||
          m0_wdata[63:32] !== vout[0] ||
          m0_wdata[95:64] !== vout[1] || !m0_wlast)
        $fatal(1,"ACT output/WSTRB");
      w0 <= w0+1;
      output_pending <= 1;
      output_hold <= 20;
    end
    if (m0_bvalid && m0_bready) begin
      b0 <= b0+1;
      m0_bvalid <= 0;
      output_pending <= 0;
    end else if (output_pending && !m0_bvalid) begin
      if (output_hold!=0) output_hold <= output_hold-1;
      else m0_bvalid <= 1;
    end
    if (m1_awvalid || m1_wvalid || m1_bready)
      $fatal(1,"ACT wrote out1");
    if (completion_tvalid && (bt!=64 || b0!=1 || commits!=8 ||
                              !all_writer_debt_zero))
      $fatal(1,"completion before physical B/commit debt");
  end

  initial begin : test
    if (!$value$plusargs("VEC_DIR=%s",vec_dir))
      $fatal(1,"VEC_DIR required");
    $readmemh({vec_dir,"/a.hex"},va);
    $readmemh({vec_dir,"/w.hex"},vw);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    $readmemh({vec_dir,"/sw.hex"},vsw);
    $readmemh({vec_dir,"/mask.hex"},vmask);
    $readmemh({vec_dir,"/dot.hex"},vdot);
    $readmemh({vec_dir,"/product.hex"},vproduct);
    $readmemh({vec_dir,"/term.hex"},vterm);
    $readmemh({vec_dir,"/ps.hex"},vps);
    $readmemh({vec_dir,"/bias.hex"},vbias);
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
    commits=0; aw0=0; w0=0; b0=0; awt=0; wt=0; bt=0;
    cycles=0; trace_hold=0; output_hold=0;
    trace_pending=0; output_pending=0;
    repeat (16) @(negedge clk);
    rst_n=1;
    trace_command_start=1;
    @(negedge clk); trace_command_start=0;
    send_config();
    send_bias();
    for (int g=0; g<8; g++) send_group(g);
    @(negedge clk); finish_tvalid=1;
    do @(posedge clk); while (!finish_tready);
    @(negedge clk); finish_tvalid=0;
    wait(completion_tvalid);
    @(negedge clk);
    if (completion_tdata[0] || completion_tdata[129] ||
        completion_tdata[64:1]!==64 ||
        completion_tdata[128:65]!==0 ||
        completion_tdata[257:226]!==8 ||
        completion_tdata[289:258]!==2 ||
        completion_tdata[353:290]!==512 ||
        completion_tdata[449:418]!==8 ||
        any_writer_fault || aw0!=1 || w0!=1 || b0!=1 ||
        awt!=64 || wt!=64 || bt!=64 || commits!=8)
      $fatal(1,"ACT joint completion/statistics");
    completion_tready=1;
    @(negedge clk); completion_tready=0;
    $display("TM1TN8_JOINT_ACT_PASS groups=8 lanes=16 macs=512 traceB=64 outB=1");
    $finish;
  end
endmodule
