`timescale 1ns/1ps
// Dormant selected-route mux/tag probe. Route codes are source-adapter
// bindings: 0=D_ZERO, 1=PROVEN_ZERO, 2=NORMAL, 3=SCALED,
// 4=ERROR_NEUTRAL. This checks selection/alignment, not the FP calculation.
module c1_selected_route_probe;
  logic clk=0,rst_n=0,req_valid=0,req_ready,ret_valid;
  logic [16:0] req_seq=0,ret_seq;
  logic [2:0] req_route=0;
  logic [31:0] req_normal_bits=0,req_bypass_bits=0,ret_selected_bits;
  int cycle=0,accepted=0,retired=0;
  logic [16:0] expected_seq[0:31];
  logic [31:0] expected_bits[0:31];
  int accepted_cycle[0:31];

  c1_unbound_selected_route_adapter service(
    .clk(clk),.rst_n(rst_n),.req_valid(req_valid),.req_ready(req_ready),
    .req_seq(req_seq),.req_route(req_route),
    .req_normal_bits(req_normal_bits),.req_bypass_bits(req_bypass_bits),
    .ret_valid(ret_valid),.ret_seq(ret_seq),
    .ret_selected_bits(ret_selected_bits));
  always #5ns clk=~clk;
  function automatic logic [31:0] frozen_normal(input int i);
    case(i)
      0: return 32'h80000000;
      1: return 32'h00000001;
      2: return 32'h3f800000;
      3: return 32'h00000001;
      4: return 32'h7f800000;
      default: return 32'h80000000;
    endcase
  endfunction
  function automatic logic [31:0] frozen_bypass(input int i);
    case(i)
      0,1,3,4: return 32'h00000000;
      2: return 32'hdeadbeef;
      default: return 32'h00000001;
    endcase
  endfunction
  function automatic logic [2:0] frozen_route(input int i);
    case(i)
      0: return 3'd0;
      1: return 3'd1;
      2: return 3'd2;
      3: return 3'd3;
      4: return 3'd4;
      default: return 3'd2;
    endcase
  endfunction
  function automatic logic [31:0] frozen_expected(input int i);
    return (i==0 || i==1 || i==4) ? frozen_bypass(i) :
                                          frozen_normal(i);
  endfunction
  task automatic send(input int phase,input int i);
    @(negedge clk);
    req_seq=17'(phase*16+i);
    req_route=frozen_route(i);
    req_normal_bits=frozen_normal(i);
    req_bypass_bits=frozen_bypass(i);
    req_valid=1;
    do @(posedge clk); while (req_ready!==1'b1);
    @(negedge clk); req_valid=0;
  endtask
  always @(posedge clk) begin
    cycle++;
    if (cycle>500) $fatal(1,"C1_SELECTED_ROUTE_WATCHDOG");
    if (rst_n && req_valid && req_ready) begin
      if (accepted>=32) $fatal(1,"C1_SELECTED_ROUTE_ACCEPT_OVERFLOW");
      expected_seq[accepted]=req_seq;
      expected_bits[accepted]=frozen_expected(req_seq%16);
      accepted_cycle[accepted]=cycle;
      accepted++;
    end
    #1ps;
    if (rst_n && ret_valid) begin
      if (retired>=accepted || ret_seq!==expected_seq[retired] ||
          ret_selected_bits!==expected_bits[retired])
        $fatal(1,"C1_SELECTED_ROUTE_TAG_OR_DATA");
      $display("C1_SELECTED_ROUTE_OBS tag=%0d accept=%0d return=%0d",
               ret_seq,accepted_cycle[retired],cycle);
      retired++;
    end
  end
  initial begin
    repeat(4) @(negedge clk);rst_n=1;
    for(int i=0;i<6;i++) begin
      send(0,i);
      if (i==1) repeat(2) @(negedge clk);
    end
    wait(retired==6);
    repeat(3) @(negedge clk);rst_n=0;
    repeat(3) @(negedge clk);accepted=0;retired=0;rst_n=1;
    for(int i=5;i>=0;i--) send(1,i);
    wait(retired==6);
    $display("C1_SELECTED_ROUTE_OBSERVATION_COMPLETE");
    $finish;
  end
endmodule
