`timescale 1ns/1ps
// Descriptor-entry test of the unchanged AT057 residual wrapper.
module ffn1_residual_destination_tb_v1;
  import laya_model_identity_13bo_generated_v1::L13M_CANONICAL;
  logic clk=0, rst_n=0;
  always #5 clk=~clk;
  logic cfg_valid=0, cfg_ready;
  logic [31:0] cfg_request=3, cfg_generation=1;
  logic [7:0] cfg_op=8'h62, cfg_stage=2, cfg_layer=0;
  logic [7:0] cfg_batch=0, cfg_row=0, cfg_rows=1;
  logic [15:0] cfg_length=1024, cfg_bias_id=16'hffff;
  logic [127:0] cfg_model_tag,cfg_numeric_tag,cfg_layout_tag,cfg_build_tag;
  logic [7:0] cfg_src0_role=3, cfg_src0_bank=0;
  logic [31:0] cfg_src0_epoch=1;
  logic [63:0] cfg_src0_base=64'h310800000;
  logic [31:0] cfg_src0_capacity=16919104,cfg_src0_bytes=4096;
  logic [7:0] cfg_src1_role=1, cfg_src1_bank=0;
  logic [31:0] cfg_src1_epoch=1;
  logic [63:0] cfg_src1_base=64'h300000000;
  logic [31:0] cfg_src1_capacity=16920576,cfg_src1_bytes=4096;
  logic [7:0] cfg_dst_role=1, cfg_dst_bank=1;
  logic [31:0] cfg_dst_epoch=2;
  logic [63:0] cfg_dst_base=64'h310000000;
  logic [31:0] cfg_dst_capacity=16919104,cfg_dst_bytes=4096;
  logic [415:0] cfg_context=416'h123456789abcdef;
  logic rsp_valid,rsp_ready=0;
  logic [7:0] rsp_status;
  logic [415:0] rsp_context;
  logic source_locked,dst_published;
  logic [15:0] skip_ar_count,skip_r_count,down_ar_count,down_r_count;
  logic [15:0] add_start_count,add_done_count,aw_count,w_count,b_count;
  logic skip_arvalid,skip_arready=1,skip_rready,skip_rvalid=0,skip_rlast=1;
  logic [63:0] skip_araddr;
  logic [7:0] skip_arlen;
  logic [2:0] skip_arsize;
  logic [511:0] skip_rdata=0;
  logic [1:0] skip_rresp=0;
  logic down_arvalid,down_arready=1,down_rready,down_rvalid=0,down_rlast=1;
  logic [63:0] down_araddr;
  logic [7:0] down_arlen;
  logic [2:0] down_arsize;
  logic [511:0] down_rdata=0;
  logic [1:0] down_rresp=0;
  logic awvalid,awready=1,wvalid,wready=1,wlast,bready,bvalid=0;
  logic [63:0] awaddr,wstrb;
  logic [7:0] awlen;
  logic [2:0] awsize;
  logic [511:0] wdata;
  logic [1:0] bresp=0;
  integer physical_skip_ar=0,physical_skip_r=0,physical_down_ar=0;
  integer physical_aw=0,physical_w=0;
  laya_ffn0_residual_four_row_v1 dut(.*);

  always @(posedge clk) begin
    if(!rst_n)begin
      physical_skip_ar<=0;physical_skip_r<=0;physical_down_ar<=0;
      physical_aw<=0;physical_w<=0;
    end else begin
      if(skip_arvalid && skip_arready)physical_skip_ar<=physical_skip_ar+1;
      if(skip_rvalid && skip_rready)physical_skip_r<=physical_skip_r+1;
      if(down_arvalid && down_arready)physical_down_ar<=physical_down_ar+1;
      if(awvalid && awready)physical_aw<=physical_aw+1;
      if(wvalid && wready)physical_w<=physical_w+1;
    end
  end
  task automatic tick(); @(posedge clk); #1; endtask
  task automatic cold();
    @(negedge clk);rst_n=0;cfg_valid=0;rsp_ready=0;
    skip_rvalid=0;skip_rresp=0;cfg_dst_bank=1;
    cfg_dst_base=64'h310000000;
    repeat(3)tick();
    @(negedge clk);rst_n=1;
  endtask
  task automatic issue();
    @(negedge clk);cfg_valid=1;
    if(!cfg_ready)$fatal(1,"FFN1 wrapper cfg not ready");
    tick();@(negedge clk);cfg_valid=0;
  endtask
  task automatic consume(input logic [7:0] status);
    if(!rsp_valid || rsp_status!==status || rsp_context!==cfg_context)
      $fatal(1,"FFN1 wrapper response status=%0d expected=%0d",rsp_status,status);
    repeat(7)begin
      tick();
      if(!rsp_valid || rsp_status!==status || rsp_context!==cfg_context)
        $fatal(1,"FFN1 wrapper held response changed");
    end
    @(negedge clk);rsp_ready=1;
    tick();@(negedge clk);rsp_ready=0;
    if(rsp_valid)$fatal(1,"FFN1 wrapper response not consumed once");
  endtask
  task automatic reject_dst(input integer kind);
    cold();
    if(kind==0)cfg_dst_bank=0;
    else cfg_dst_base=64'h300000000;
    issue();
    consume(8'd7);
    if(physical_skip_ar || physical_skip_r || physical_down_ar ||
       physical_aw || physical_w || skip_arvalid || down_arvalid ||
       awvalid || wvalid || source_locked || dst_published)
      $fatal(1,"FFN1 wrapper bad destination had physical AXI kind=%0d",kind);
    $display("FFN1_WRAPPER_DST_REJECT_PASS kind=%0d status=7 skip_AR/R=%0d/%0d down_AR=%0d AW/W=%0d/%0d published=%0d",
      kind,physical_skip_ar,physical_skip_r,physical_down_ar,
      physical_aw,physical_w,dst_published);
  endtask
  initial begin
    cfg_model_tag=L13M_CANONICAL[0+:128];
    cfg_numeric_tag=L13M_CANONICAL[128+:128];
    cfg_layout_tag=L13M_CANONICAL[256+:128];
    cfg_build_tag=L13M_CANONICAL[384+:128];
    reject_dst(0);
    reject_dst(1);
    cold();
    issue();
    if(!skip_arvalid || !source_locked ||
       skip_araddr!==64'h300000000 || skip_arlen!=0 || skip_arsize!=6)
      $fatal(1,"FFN1 legal descriptor did not reach real source AR");
    tick();
    @(negedge clk);skip_rvalid=1;skip_rresp=2'b10;
    if(!skip_rready)$fatal(1,"FFN1 legal source AR did not reach R phase");
    tick();@(negedge clk);skip_rvalid=0;
    consume(8'd8);
    if(physical_skip_ar!=1 || physical_skip_r!=1 ||
       physical_down_ar || physical_aw || physical_w || dst_published)
      $fatal(1,"FFN1 legal descriptor source path handshake mismatch");
    $display("FFN1_WRAPPER_LEGAL_SOURCE_PASS skip_AR/R=%0d/%0d status=8",
      physical_skip_ar,physical_skip_r);
    $display("FFN1_WRAPPER_DST_PASS rejects=2 legal_source=1");
    $finish;
  end
  initial begin repeat(500)tick();$fatal(1,"FFN1 wrapper TB watchdog");end
endmodule
