`timescale 1ns/1ps
module laya_13bo_model_binding_tb_v1;
  logic clk=0,rst_n=0;always #5 clk=~clk;
  logic [7:0] AWADDR=0,ARADDR=0;
  logic AWVALID=0,AWREADY,WVALID=0,WREADY,BVALID,BREADY=0;
  logic [31:0] WDATA=0,RDATA;logic [3:0] WSTRB=0;logic [1:0] BRESP,RRESP;
  logic ARVALID=0,ARREADY,RVALID,RREADY=0;
  logic host_ap_start=0,soft_cancel=0,cold_rebind=0,domain_drained=1;
  logic core_ap_start,start_ready,binding_valid,candidate_valid,candidate_matches;
  logic binding_conflict,cold_rebind_rejected,mirror_protocol_error;
  logic [12:0][63:0] actual_base,programmed_bo_base,latched_bo_base;
  logic [4:0][63:0] bound_model_base,bound_snapshot;
  logic [12:0][63:0] latched_snapshot;
  logic [31:0] accepted_requests,rejected_requests;
  integer writes=0,cycles=0;
  laya_typed_q8_forward_control_r_s_axi original(
    .ACLK(clk),.ARESET(!rst_n),.ACLK_EN(1'b1),
    .AWADDR,.AWVALID,.AWREADY,.WDATA,.WSTRB,.WVALID,.WREADY,.BRESP,.BVALID,.BREADY,
    .ARADDR,.ARVALID,.ARREADY,.RDATA,.RRESP,.RVALID,.RREADY,
    .embedding_r(actual_base[0]),.io_r(actual_base[1]),.w_q0_r(actual_base[2]),
    .w_q1_r(actual_base[3]),.w_scale_r(actual_base[4]),.aux_r(actual_base[5]),
    .state0_r(actual_base[6]),.state1_r(actual_base[7]),.qkv0_r(actual_base[8]),
    .qkv1_r(actual_base[9]),.ff0_r(actual_base[10]),.ff1_r(actual_base[11]),
    .att_out_r(actual_base[12]));
  laya_13bo_request_gate_v1 gate(
    .clk,.rst_n,.awaddr(AWADDR),.awvalid(AWVALID),.awready(AWREADY),
    .wdata(WDATA),.wstrb(WSTRB),.wvalid(WVALID),.wready(WREADY),
    .host_ap_start,.soft_cancel,.cold_rebind,.domain_drained,.core_ap_start,.start_ready,
    .programmed_bo_base,.latched_bo_base,.binding_valid,.bound_model_base,
    .candidate_valid,.candidate_matches,.binding_conflict,.cold_rebind_rejected,
    .accepted_requests,.rejected_requests,.mirror_protocol_error);
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>20000)$fatal(1,"model binding cycle cap");
  end
  always @(negedge clk)if(rst_n)begin
    if(programmed_bo_base!==actual_base || mirror_protocol_error)
      $fatal(1,"request gate mirror differs from generated control");
  end
  task automatic write_word(input logic [7:0] address,input logic [31:0] data,
                            input logic [3:0] strobe);
    @(negedge clk);AWADDR=address;AWVALID=1;WDATA=data;WSTRB=strobe;WVALID=0;
    while(!AWREADY)tick();tick();@(negedge clk);AWVALID=0;
    repeat(2)tick();@(negedge clk);WVALID=1;
    while(!WREADY)tick();tick();@(negedge clk);WVALID=0;
    repeat(2)begin tick();if(!BVALID || BRESP!=0)$fatal(1,"native control B");end
    @(negedge clk);BREADY=1;tick();@(negedge clk);BREADY=0;writes++;
  endtask
  task automatic write_base(input int role,input logic [63:0] value);
    write_word(8'(16+12*role),value[31:0],4'hf);
    write_word(8'(20+12*role),value[63:32],4'hf);
  endtask
  task automatic start_request(input bit expected);
    logic [12:0][63:0] before_latched;
    before_latched=latched_bo_base;
    @(negedge clk);host_ap_start=1;#1;
    if(core_ap_start!==expected || (expected && !start_ready))$fatal(1,"start gate expected=%0d",expected);
    tick();
    if(expected && latched_bo_base!==programmed_bo_base)$fatal(1,"accepted start snapshot");
    if(!expected && latched_bo_base!==before_latched)$fatal(1,"rejected start changed active base");
    @(negedge clk);host_ap_start=0;#1;
    if(core_ap_start)$fatal(1,"core start held after host pulse");
  endtask
  task automatic cold(input bit drained);
    @(negedge clk);domain_drained=drained;cold_rebind=1;tick();
    @(negedge clk);cold_rebind=0;domain_drained=1;tick();
  endtask
  initial begin
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    for(int role=0;role<13;role++)write_base(role,64'h0000001000000000+64'(role)*64'h10000000);
    if(!candidate_valid || binding_valid)$fatal(1,"initial candidate validity");
    start_request(1);bound_snapshot=bound_model_base;latched_snapshot=latched_bo_base;
    if(!binding_valid || accepted_requests!=1 || rejected_requests!=0)$fatal(1,"first bind");
    start_request(1); // Same bases, next request/session identity is legal.
    @(negedge clk);soft_cancel=1;tick();@(negedge clk);soft_cancel=0;tick();
    if(!binding_valid || bound_model_base!==bound_snapshot)$fatal(1,"soft cancel cleared binding");
    start_request(1);
    // Non-model IO/workspace bases remain request-scoped.
    write_base(6,64'h0000002200000000);start_request(1);latched_snapshot=latched_bo_base;
    if(bound_model_base!==bound_snapshot)$fatal(1,"workspace write changed model binding");
    // A partial low-word model rewrite is visible to the real control mirror,
    // but cannot overwrite the persistent binding or reach core_ap_start.
    write_word(8'(16+12*2),32'h00000080,4'b0001);
    if(candidate_matches)$fatal(1,"model low WSTRB change not observed");
    start_request(0);
    if(bound_model_base!==bound_snapshot || latched_bo_base!==latched_snapshot)
      $fatal(1,"bad low model base overwrote old binding");
    write_base(2,bound_snapshot[1]);start_request(1);
    // A high-word rewrite is rejected independently.
    write_word(8'(20+12*5),32'h00000040,4'hf);start_request(0);
    write_base(5,bound_snapshot[4]);start_request(1);
    if(!binding_conflict || rejected_requests!=2)$fatal(1,"model conflict accounting");
    // Cold clear cannot occur while the enclosing physical domain is live.
    cold(0);
    if(!binding_valid || !cold_rebind_rejected || bound_model_base!==bound_snapshot)
      $fatal(1,"undrained cold clear changed binding");
    // A drained cold boundary permits a new binding. Misalignment is refused.
    cold(1);if(binding_valid || bound_model_base!=='0)$fatal(1,"drained cold clear");
    write_base(0,64'h0000003000000001);start_request(0);
    write_base(0,64'h0000003000000000);start_request(1);
    if(!binding_valid || bound_model_base[0]!=64'h0000003000000000)$fatal(1,"post-cold rebind");
    // Exact generated size is included in the overflow check.
    cold(1);write_base(0,64'hffffffffffffffc0);start_request(0);
    write_base(0,64'h0000004000000000);start_request(1);
    if(accepted_requests!=8 || rejected_requests!=4 || writes!=42)
      $fatal(1,"binding counts accepted=%0d rejected=%0d writes=%0d",accepted_requests,rejected_requests,writes);
    $display("FULL_CURRENT_13BO_MODEL_BINDING_PASS model_roles=5 accepted=%0d rejected=%0d writes=%0d soft_cancel_retained=1 undrained_cold_rejected=1 rebind=2 low_high_wstrb=1 cycles=%0d",accepted_requests,rejected_requests,writes,cycles);
    $finish;
  end
endmodule
