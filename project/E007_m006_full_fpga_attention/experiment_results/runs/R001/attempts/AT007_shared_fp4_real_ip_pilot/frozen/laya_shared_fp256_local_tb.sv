`timescale 1ns/1ps

// Four physical lanes of the parameterized 256-lane production array.
// Checks independent mul/add results and a real phase handoff.
module laya_shared_fp256_local_tb;
  localparam int LANES = 4;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0;
  logic lease_valid = 0, release_valid = 0, issue_valid = 0;
  logic lease_ready, release_ready, issue_ready;
  logic [2:0] lease_phase = 0, release_phase = 0, issue_phase = 0;
  logic [31:0] lease_epoch = 0, release_epoch = 0, issue_epoch = 0;
  logic [95:0] issue_tag = 0;
  logic [LANES-1:0][31:0] mul_a, mul_b, add_a, add_b;
  logic rsp_valid, rsp_ready = 0, protocol_fault;
  logic [2:0] rsp_phase;
  logic [31:0] rsp_epoch;
  logic [95:0] rsp_tag;
  logic [LANES-1:0][31:0] rsp_mul, rsp_add;
  logic [6:0] pending;
  int received = 0, cycle = 0;

  laya_shared_fp256_v1 #(.LANES(LANES)) dut (
    .clk, .rst_n, .lease_valid, .lease_ready, .lease_phase, .lease_epoch,
    .release_valid, .release_ready, .release_phase, .release_epoch,
    .issue_valid, .issue_ready, .issue_phase, .issue_epoch, .issue_tag,
    .mul_a, .mul_b, .add_a, .add_b,
    .rsp_valid, .rsp_ready, .rsp_phase, .rsp_epoch, .rsp_tag,
    .rsp_mul, .rsp_add, .pending, .protocol_fault
  );

  initial begin
    mul_a[0]=32'h3f800000; mul_a[1]=32'h3fc00000;
    mul_a[2]=32'h40000000; mul_a[3]=32'h40800000;
    for (int lane=0;lane<LANES;lane++) begin
      mul_b[lane]=32'h40000000;
      add_a[lane]=mul_a[lane];
      add_b[lane]=32'h40000000;
    end
    repeat(5) @(negedge clk);
    rst_n=1;
    @(negedge clk);
    lease_valid=1;lease_phase=3'd2;lease_epoch=32'd7;
    @(posedge clk);
    if(!lease_ready) $fatal(1,"FP_LEASE_QK");
    @(negedge clk);lease_valid=0;

    for(int k=0;k<8;k++) begin
      @(negedge clk);
      issue_valid=1;issue_phase=3'd2;issue_epoch=32'd7;
      issue_tag=96'(k);
      @(posedge clk);
      if(!issue_ready) $fatal(1,"FP_QK_ISSUE_GAP k=%0d",k);
    end
    @(negedge clk);issue_valid=0;
    if(release_ready) $fatal(1,"FP_RELEASE_EARLY");
    wait(rsp_valid);
    repeat(3) begin
      @(posedge clk);
      if(!rsp_valid || rsp_tag!=0 || release_ready)
        $fatal(1,"FP_HELD_RSP");
    end
    @(negedge clk);rsp_ready=1;
    wait(received==8);
    @(negedge clk);
    if(pending!=0 || !release_ready)
      $fatal(1,"FP_DRAIN pending=%0d ready=%b",pending,release_ready);
    release_valid=1;release_phase=3'd2;release_epoch=32'd7;
    @(negedge clk);release_valid=0;

    lease_valid=1;lease_phase=3'd4;lease_epoch=32'd8;
    @(posedge clk);
    if(!lease_ready) $fatal(1,"FP_LEASE_AV");
    @(negedge clk);lease_valid=0;
    issue_valid=1;issue_phase=3'd4;issue_epoch=32'd7;
    #1;
    if(issue_ready) $fatal(1,"FP_OLD_EPOCH_ACCEPTED");
    issue_epoch=32'd8;issue_tag=96'd8;
    @(posedge clk);
    if(!issue_ready) $fatal(1,"FP_AV_ISSUE");
    @(negedge clk);issue_valid=0;
    wait(received==9);
    @(negedge clk);
    if(pending!=0 || protocol_fault) $fatal(1,"FP_FINAL_DRAIN");
    $display("SHARED_FP_LOCAL_PASS lanes=4 qk=8 av=1 held=3 epoch_reject=1");
    $finish;
  end

  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(cycle>300 || protocol_fault)
      $fatal(1,"FP_CYCLE_OR_PROTOCOL cycle=%0d fault=%b",cycle,protocol_fault);
    if(rsp_valid && rsp_ready) begin
      if(rsp_tag!==96'(received) ||
         rsp_phase!==(received<8 ? 3'd2 : 3'd4) ||
         rsp_epoch!==(received<8 ? 32'd7 : 32'd8))
        $fatal(1,"FP_RSP_IDENTITY index=%0d tag=%h phase=%h epoch=%h",
               received,rsp_tag,rsp_phase,rsp_epoch);
      if(rsp_mul[0]!==32'h40000000 || rsp_add[0]!==32'h40400000 ||
         rsp_mul[1]!==32'h40400000 || rsp_add[1]!==32'h40600000 ||
         rsp_mul[2]!==32'h40800000 || rsp_add[2]!==32'h40800000 ||
         rsp_mul[3]!==32'h41000000 || rsp_add[3]!==32'h40c00000)
        $fatal(1,"FP_RSP_DATA index=%0d",received);
      received<=received+1;
    end
  end
endmodule
