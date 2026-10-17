`timescale 1ns/1ps
module m005_quant_axi_debt_monitor_tb_v1;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0;
  logic arvalid=0,arready=0,rvalid=0,rready=0,rlast=0;
  logic [7:0] arlen=0;
  logic quant_task_debt_zero=1;
  logic physical_and_task_debt_zero,burst_in_flight,accounting_error;
  logic [8:0] beats_remaining;
  laya_quant_axi_debt_monitor_v1 dut(.*);

  task automatic tick;
    @(posedge clk); #1;
  endtask
  task automatic cold_reset;
    @(negedge clk);
    rst_n=0;arvalid=0;arready=0;rvalid=0;rready=0;rlast=0;
    quant_task_debt_zero=1;
    tick();
    @(negedge clk);rst_n=1;
    #1;
    if(physical_and_task_debt_zero!==1'b1 ||
       accounting_error!==1'b0 || beats_remaining!==0)
      $fatal(1,"M005 debt monitor reset");
  endtask
  task automatic expect_blocked;
    if(physical_and_task_debt_zero!==1'b0)
      $fatal(1,"M005 debt monitor released early");
  endtask
  initial begin
    cold_reset();
    arvalid=1;arlen=8'd2;#1;expect_blocked();
    arready=1;tick();
    if(beats_remaining!==9'd3 || !burst_in_flight) $fatal(1,"ARLEN+1");
    @(negedge clk);arvalid=0;arready=0;rvalid=1;rready=0;
    repeat(3)begin tick();if(beats_remaining!==9'd3) $fatal(1,"R stall");end
    @(negedge clk);rready=1;tick();
    if(beats_remaining!==9'd2) $fatal(1,"first R");
    @(negedge clk);tick();
    if(beats_remaining!==9'd1) $fatal(1,"middle R");
    @(negedge clk);rlast=1;quant_task_debt_zero=0;tick();
    if(beats_remaining!==0 || burst_in_flight) $fatal(1,"last R");
    expect_blocked();
    @(negedge clk);rvalid=0;rready=0;rlast=0;#1;expect_blocked();
    quant_task_debt_zero=1;#1;
    if(physical_and_task_debt_zero!==1'b1) $fatal(1,"drained release");

    // No corresponding AR: fault must persist even when later pins go idle.
    @(negedge clk);rvalid=1;rready=1;rlast=1;tick();
    if(!accounting_error) $fatal(1,"orphan R accepted");
    @(negedge clk);rvalid=0;rready=0;#1;expect_blocked();

    cold_reset();
    arvalid=1;arready=1;arlen=1;tick();
    @(negedge clk);arvalid=0;arready=0;rvalid=1;rready=1;rlast=1;tick();
    if(!accounting_error) $fatal(1,"early RLAST accepted");

    cold_reset();
    arvalid=1;arready=1;arlen=0;rvalid=1;rready=1;rlast=1;tick();
    if(!accounting_error) $fatal(1,"same-edge AR/R accepted");

    cold_reset();
    arvalid=1;arready=1;arlen=1;tick();
    @(negedge clk);arlen=0;tick();
    if(!accounting_error) $fatal(1,"second AR accepted");

    cold_reset();
    arvalid=1;arready=1;arlen=64;tick();
    if(!accounting_error) $fatal(1,"unsupported burst accepted");
    $display("M005_QUANT_AXI_DEBT_MONITOR_PASS");
    $finish;
  end
endmodule
