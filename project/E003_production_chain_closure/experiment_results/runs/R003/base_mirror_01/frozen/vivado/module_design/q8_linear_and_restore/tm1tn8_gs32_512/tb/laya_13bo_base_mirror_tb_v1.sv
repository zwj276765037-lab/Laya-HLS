`timescale 1ns/1ps
// Compare passive mirror against the original actual generated pointer control.
// This test does not stand in for current generated controller/13BO integration.
module laya_13bo_base_mirror_tb_v1;
  logic clk=0,rst_n=0;always #5 clk=~clk;
  logic [7:0] AWADDR=0,ARADDR=0;
  logic AWVALID=0,AWREADY,WVALID=0,WREADY,BVALID,BREADY=0;
  logic [31:0] WDATA=0,RDATA;logic [3:0] WSTRB=0;logic [1:0] BRESP,RRESP;
  logic ARVALID=0,ARREADY,RVALID,RREADY=0,request_accept=0,protocol_error;
  logic [12:0][63:0] actual_base,programmed_bo_base,latched_bo_base,snapshot;
  logic [31:0] accepted_requests;
  integer writes=0,cycles=0;
  laya_typed_q8_forward_control_r_s_axi original(
    .ACLK(clk),.ARESET(!rst_n),.ACLK_EN(1'b1),
    .AWADDR,.AWVALID,.AWREADY,.WDATA,.WSTRB,.WVALID,.WREADY,.BRESP,.BVALID,.BREADY,
    .ARADDR,.ARVALID,.ARREADY,.RDATA,.RRESP,.RVALID,.RREADY,
    .embedding_r(actual_base[0]),
    .io_r(actual_base[1]),
    .w_q0_r(actual_base[2]),
    .w_q1_r(actual_base[3]),
    .w_scale_r(actual_base[4]),
    .aux_r(actual_base[5]),
    .state0_r(actual_base[6]),
    .state1_r(actual_base[7]),
    .qkv0_r(actual_base[8]),
    .qkv1_r(actual_base[9]),
    .ff0_r(actual_base[10]),
    .ff1_r(actual_base[11]),
    .att_out_r(actual_base[12])
  );
  laya_13bo_base_mirror_v1 mirror(
    .clk,.rst_n,.awaddr(AWADDR),.awvalid(AWVALID),.awready(AWREADY),
    .wdata(WDATA),.wstrb(WSTRB),.wvalid(WVALID),.wready(WREADY),.request_accept,
    .programmed_bo_base,.latched_bo_base,.accepted_requests,.protocol_error);
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>15000)$fatal(1,"base mirror cycle cap");
  end
  always @(negedge clk)if(rst_n)begin
    if(programmed_bo_base!==actual_base || protocol_error)$fatal(1,"base mirror differs from generated register behavior");
  end
  task automatic write_word(input logic [7:0] address,input logic [31:0] data,
                            input logic [3:0] strobe,input bit early_w,input bit accept_with_w);
    @(negedge clk);AWADDR=address;AWVALID=1;WDATA=data;WSTRB=strobe;WVALID=early_w;
    while(!AWREADY)tick();tick();@(negedge clk);AWVALID=0;
    if(!early_w)begin repeat(3)tick();@(negedge clk);WVALID=1;end
    request_accept=accept_with_w;snapshot=actual_base;
    while(!WREADY)tick();tick();
    if(accept_with_w && latched_bo_base!==snapshot)$fatal(1,"accept must snapshot the same pre-write bases as generated controller");
    @(negedge clk);WVALID=0;request_accept=0;
    repeat(4)begin tick();if(!BVALID || BRESP!=0)$fatal(1,"native control B backpressure");end
    @(negedge clk);BREADY=1;tick();@(negedge clk);BREADY=0;writes++;
  endtask
  task automatic accept;
    @(negedge clk);request_accept=1;snapshot=actual_base;tick();
    if(latched_bo_base!==snapshot)$fatal(1,"request base snapshot mismatch");
    @(negedge clk);request_accept=0;
  endtask
  initial begin
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    for(int role=0;role<13;role++)begin
      // Oracle DUT decodes these writes using its actual frozen register RTL.
      write_word(8'(16+12*role),32'h89abcdef^32'(role),4'hf,0,0);
      write_word(8'(20+12*role),32'h10000001+32'(role),4'hf,1,0);
    end
    accept();snapshot=latched_bo_base;
    for(int mask=0;mask<16;mask++)begin
      write_word(8'ha6,32'h76543210^32'(mask),4'(mask),0,0);
      if(latched_bo_base!==snapshot)$fatal(1,"running base changed on later pointer write");
      write_word(8'h11,32'h01234567+32'(mask),4'(mask),1,0);
      if(latched_bo_base!==snapshot)$fatal(1,"running base changed on later pointer write");
    end
    write_word(8'h18,32'hffffffff,4'hf,0,0);
    write_word(8'h00,32'hffffffff,4'hf,0,0);
    write_word(8'h58,32'h01234567,4'h5,0,1);
    accept();
    if(accepted_requests!=3 || writes!=61)$fatal(1,"base mirror coverage");
    $display("FULL_CURRENT_13BO_BASE_PASS roles=13 initial_words=26 strobe_masks=16 native_writes=%0d snapshots=%0d cycles=%0d",writes,accepted_requests,cycles);$finish;
  end
endmodule
