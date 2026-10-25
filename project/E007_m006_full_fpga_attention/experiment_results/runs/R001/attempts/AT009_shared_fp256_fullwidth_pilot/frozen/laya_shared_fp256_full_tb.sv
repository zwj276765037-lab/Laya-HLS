`timescale 1ns/1ps

// All 256 physical lanes of the production array.
// Exercise all response data, 64 outstanding vectors and phase handoff.
module laya_shared_fp256_full_tb;
  localparam int LANES = 256;
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
    for (int lane=0;lane<LANES;lane++) begin
      case (lane % 4)
        0: mul_a[lane]=32'h3f800000;
        1: mul_a[lane]=32'h3fc00000;
        2: mul_a[lane]=32'h40000000;
        3: mul_a[lane]=32'h40800000;
      endcase
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

    for(int k=0;k<64;k++) begin
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
    wait(received==64);
    @(negedge clk);
    release_phase=3'd2;release_epoch=32'd7;
    #1;
    if(pending!=0 || !release_ready)
      $fatal(1,"FP_DRAIN pending=%0d ready=%b",pending,release_ready);
    release_valid=1;
    @(negedge clk);release_valid=0;

    lease_valid=1;lease_phase=3'd4;lease_epoch=32'd8;
    @(posedge clk);
    if(!lease_ready) $fatal(1,"FP_LEASE_AV");
    @(negedge clk);lease_valid=0;
    issue_valid=1;issue_phase=3'd4;issue_epoch=32'd7;
    #1;
    if(issue_ready) $fatal(1,"FP_OLD_EPOCH_ACCEPTED");
    issue_epoch=32'd8;issue_tag=96'd64;
    @(posedge clk);
    if(!issue_ready) $fatal(1,"FP_AV_ISSUE");
    @(negedge clk);issue_valid=0;
    wait(received==65);
    @(negedge clk);
    if(pending!=0 || protocol_fault) $fatal(1,"FP_FINAL_DRAIN");
    $display("SHARED_FP_FULL_PASS lanes=256 qk=64 av=1 held=3 epoch_reject=1");
    $finish;
  end

  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(cycle>300 || protocol_fault)
      $fatal(1,"FP_CYCLE_OR_PROTOCOL cycle=%0d fault=%b",cycle,protocol_fault);
    if(rsp_valid && rsp_ready) begin
      if(rsp_tag!==96'(received) ||
         rsp_phase!==(received<64 ? 3'd2 : 3'd4) ||
         rsp_epoch!==(received<64 ? 32'd7 : 32'd8))
        $fatal(1,"FP_RSP_IDENTITY index=%0d tag=%h phase=%h epoch=%h",
               received,rsp_tag,rsp_phase,rsp_epoch);
      for (int lane=0;lane<LANES;lane++) begin
        case (lane % 4)
          0: if(rsp_mul[lane]!==32'h40000000 || rsp_add[lane]!==32'h40400000)
               $fatal(1,"FP_RSP_DATA index=%0d lane=%0d",received,lane);
          1: if(rsp_mul[lane]!==32'h40400000 || rsp_add[lane]!==32'h40600000)
               $fatal(1,"FP_RSP_DATA index=%0d lane=%0d",received,lane);
          2: if(rsp_mul[lane]!==32'h40800000 || rsp_add[lane]!==32'h40800000)
               $fatal(1,"FP_RSP_DATA index=%0d lane=%0d",received,lane);
          3: if(rsp_mul[lane]!==32'h41000000 || rsp_add[lane]!==32'h40c00000)
               $fatal(1,"FP_RSP_DATA index=%0d lane=%0d",received,lane);
        endcase
      end
      received<=received+1;
    end
  end
endmodule
