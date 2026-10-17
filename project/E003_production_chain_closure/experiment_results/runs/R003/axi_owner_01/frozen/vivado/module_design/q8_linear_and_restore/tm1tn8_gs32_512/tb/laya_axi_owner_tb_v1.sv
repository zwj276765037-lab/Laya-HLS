`timescale 1ns/1ps
// Actual owner arbiter control regression, with independent manual AXI peers.
// Complete payload vectors include errors/IDs/sidebands and are compared intact.
module laya_axi_owner_tb_v1;
  localparam int A_PAYLOAD_WIDTH=96,W_PAYLOAD_WIDTH=38,R_PAYLOAD_WIDTH=36,B_PAYLOAD_WIDTH=4;
  logic  clk;
  logic  rst_n;
  logic  desired_owner;
  logic  clear_error;
  logic  selected_owner;
  logic  debt_zero;
  logic  protocol_error;
  logic [1:0][A_PAYLOAD_WIDTH-1:0] owner_ar_payload;
  logic [1:0][A_PAYLOAD_WIDTH-1:0] owner_aw_payload;
  logic [1:0][7:0] owner_arlen;
  logic [1:0][7:0] owner_awlen;
  logic [1:0] owner_arvalid;
  logic [1:0] owner_awvalid;
  logic [1:0] owner_arready;
  logic [1:0] owner_awready;
  logic [1:0][W_PAYLOAD_WIDTH-1:0] owner_w_payload;
  logic [1:0] owner_wvalid;
  logic [1:0] owner_wlast;
  logic [1:0] owner_wready;
  logic [1:0][R_PAYLOAD_WIDTH-1:0] owner_r_payload;
  logic [1:0] owner_rvalid;
  logic [1:0] owner_rlast;
  logic [1:0] owner_rready;
  logic [1:0][B_PAYLOAD_WIDTH-1:0] owner_b_payload;
  logic [1:0] owner_bvalid;
  logic [1:0] owner_bready;
  logic [A_PAYLOAD_WIDTH-1:0] memory_ar_payload;
  logic [A_PAYLOAD_WIDTH-1:0] memory_aw_payload;
  logic [7:0] memory_arlen;
  logic [7:0] memory_awlen;
  logic  memory_arvalid;
  logic  memory_awvalid;
  logic  memory_arready;
  logic  memory_awready;
  logic [W_PAYLOAD_WIDTH-1:0] memory_w_payload;
  logic  memory_wvalid;
  logic  memory_wlast;
  logic  memory_wready;
  logic [R_PAYLOAD_WIDTH-1:0] memory_r_payload;
  logic  memory_rvalid;
  logic  memory_rlast;
  logic  memory_rready;
  logic [B_PAYLOAD_WIDTH-1:0] memory_b_payload;
  logic  memory_bvalid;
  logic  memory_bready;
  logic [31:0] accepted_ar;
  logic [31:0] returned_r;
  logic [31:0] accepted_aw;
  logic [31:0] accepted_w;
  logic [31:0] returned_b;
  laya_axi_owner_v1 dut(
    .clk,
    .rst_n,
    .desired_owner,
    .clear_error,
    .selected_owner,
    .debt_zero,
    .protocol_error,
    .owner_ar_payload,
    .owner_aw_payload,
    .owner_arlen,
    .owner_awlen,
    .owner_arvalid,
    .owner_awvalid,
    .owner_arready,
    .owner_awready,
    .owner_w_payload,
    .owner_wvalid,
    .owner_wlast,
    .owner_wready,
    .owner_r_payload,
    .owner_rvalid,
    .owner_rlast,
    .owner_rready,
    .owner_b_payload,
    .owner_bvalid,
    .owner_bready,
    .memory_ar_payload,
    .memory_aw_payload,
    .memory_arlen,
    .memory_awlen,
    .memory_arvalid,
    .memory_awvalid,
    .memory_arready,
    .memory_awready,
    .memory_w_payload,
    .memory_wvalid,
    .memory_wlast,
    .memory_wready,
    .memory_r_payload,
    .memory_rvalid,
    .memory_rlast,
    .memory_rready,
    .memory_b_payload,
    .memory_bvalid,
    .memory_bready,
    .accepted_ar,
    .returned_r,
    .accepted_aw,
    .accepted_w,
    .returned_b
  );
  initial clk=0;always #5 clk=~clk;
  integer cycles=0;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>3000)$fatal(1,"AXI owner cycle cap");
    if(rst_n)begin
      if(memory_arvalid && memory_ar_payload!==owner_ar_payload[selected_owner])$fatal(1,"AR payload changed");
      if(memory_awvalid && memory_aw_payload!==owner_aw_payload[selected_owner])$fatal(1,"AW payload changed");
      if(memory_wvalid && memory_w_payload!==owner_w_payload[selected_owner])$fatal(1,"W payload changed");
      if(owner_rvalid[selected_owner] && owner_r_payload[selected_owner]!==memory_r_payload)$fatal(1,"R data/error/ID changed");
      if(owner_bvalid[selected_owner] && owner_b_payload[selected_owner]!==memory_b_payload)$fatal(1,"B response/ID changed");
      if(owner_rvalid[!selected_owner] || owner_bvalid[!selected_owner] || owner_arready[!selected_owner] ||
         owner_awready[!selected_owner] || owner_wready[!selected_owner])$fatal(1,"response or handshake leaked into next owner");
    end
  end
  task automatic ar(input bit owner,input logic [7:0] len);
    @(negedge clk);owner_arvalid[owner]=1;owner_arlen[owner]=len;
    owner_ar_payload[owner]=96'h81234567_89abcdef_01234567^96'(len);
    while(!owner_arready[owner])tick();tick();@(negedge clk);owner_arvalid[owner]=0;
  endtask
  task automatic aw(input bit owner,input logic [7:0] len);
    @(negedge clk);owner_awvalid[owner]=1;owner_awlen[owner]=len;
    owner_aw_payload[owner]=96'hfedcba98_76543210_12345678^96'(len);
    while(!owner_awready[owner])tick();tick();@(negedge clk);owner_awvalid[owner]=0;
  endtask
  task automatic w(input bit owner,input bit last,input logic [37:0] payload);
    @(negedge clk);owner_wvalid[owner]=1;owner_wlast[owner]=last;owner_w_payload[owner]=payload;
    while(!owner_wready[owner])tick();tick();@(negedge clk);owner_wvalid[owner]=0;
  endtask
  task automatic r(input bit owner,input bit last,input bit stall,input logic [35:0] payload);
    @(negedge clk);memory_rvalid=1;memory_rlast=last;memory_r_payload=payload;
    owner_rready[owner]=!stall;
    if(stall)begin
      repeat(7)begin tick();if(selected_owner!=owner || debt_zero || memory_rready ||
        !owner_rvalid[owner] || owner_r_payload[owner]!==payload)$fatal(1,"owner changed under held R");end
      @(negedge clk);owner_rready[owner]=1;
    end
    while(!memory_rready)tick();tick();@(negedge clk);memory_rvalid=0;
  endtask
  task automatic b(input bit owner,input logic [3:0] payload);
    @(negedge clk);memory_bvalid=1;memory_b_payload=payload;owner_bready[owner]=0;
    repeat(9)begin tick();if(selected_owner!=owner || debt_zero || memory_bready ||
      !owner_bvalid[owner] || owner_b_payload[owner]!==payload)$fatal(1,"owner changed under held B");end
    @(negedge clk);owner_bready[owner]=1;tick();@(negedge clk);memory_bvalid=0;
    repeat(3)tick();
  endtask
  task automatic await_owner(input bit owner);
    repeat(3)tick();if(selected_owner!=owner || !debt_zero)$fatal(1,"owner did not switch after all real debts");
  endtask
  initial begin
    rst_n=0;desired_owner=0;clear_error=0;owner_ar_payload=0;owner_aw_payload=0;
    owner_arlen=0;owner_awlen=0;owner_arvalid=0;owner_awvalid=0;owner_w_payload=0;owner_wvalid=0;
    owner_wlast=0;owner_rready=3;owner_bready=3;memory_arready=1;memory_awready=1;memory_wready=1;
    memory_r_payload=0;memory_rvalid=0;memory_rlast=0;memory_b_payload=0;memory_bvalid=0;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    ar(0,3);desired_owner=1;
    r(0,0,0,36'h111111112);r(0,0,0,36'h22222222e);r(0,0,0,36'h333333337);r(0,1,1,36'h44444444b);
    await_owner(1);
    // W-first is accepted physical debt; owner cannot change before later AW/B.
    w(1,0,38'h01234567ff);desired_owner=0;
    repeat(5)begin tick();if(selected_owner!=1 || debt_zero)$fatal(1,"W-first partial transaction lost");end
    w(1,1,38'h0765432105);aw(1,1);b(1,4'he);await_owner(0);
    // An offered AW under backpressure is retained, even before acceptance.
    @(negedge clk);memory_awready=0;owner_awvalid[0]=1;owner_awlen[0]=2;
    owner_aw_payload[0]=96'h12345678_00000001_abcd1234;desired_owner=1;
    repeat(8)begin tick();if(selected_owner!=0 || !memory_awvalid || memory_aw_payload!==owner_aw_payload[0])$fatal(1,"held AW owner/payload changed");end
    @(negedge clk);memory_awready=1;tick();@(negedge clk);owner_awvalid[0]=0;
    w(0,0,38'h0333333333);w(0,0,38'h0222222222);w(0,1,38'h0111111111);b(0,4'h7);await_owner(1);
    // Concurrent read/write: last B cannot release an outstanding read.
    ar(1,1);aw(1,0);w(1,1,38'h00ffff0001);desired_owner=0;b(1,4'ha);
    if(selected_owner!=1 || debt_zero)$fatal(1,"write completion erased read debt");
    clear_error=1;repeat(5)begin tick();if(selected_owner!=1 || debt_zero)$fatal(1,"clear_error erased active debt");end
    clear_error=0;r(1,0,0,36'h12340000b);r(1,1,1,36'h56780000e);await_owner(0);
    if(protocol_error)$fatal(1,"legal transactions flagged as malformed");
    // A real early LAST retires physical AR, while recording the length error.
    ar(0,2);r(0,1,0,36'h01010101f);repeat(2)tick();
    if(!protocol_error || !debt_zero)$fatal(1,"early LAST error/debt accounting");
    clear_error=1;tick();clear_error=0;tick();if(protocol_error)$fatal(1,"safe fault clear failed");
    ar(0,0);r(0,1,0,36'h999999992);repeat(2)tick();
    if(accepted_ar!=4 || returned_r!=8 || accepted_aw!=3 || accepted_w!=6 || returned_b!=3 || !debt_zero || protocol_error)
      $fatal(1,"AXI owner coverage AR/R=%0d/%0d AW/W/B=%0d/%0d/%0d",accepted_ar,returned_r,accepted_aw,accepted_w,returned_b);
    $display("FULL_CURRENT_AXI_OWNER_PASS AR=%0d R=%0d AW=%0d W=%0d B=%0d held_R=2 held_B=3 W_before_AW=1 malformed_LAST_recovery=1 cycles=%0d",accepted_ar,returned_r,accepted_aw,accepted_w,returned_b,cycles);$finish;
  end
endmodule
