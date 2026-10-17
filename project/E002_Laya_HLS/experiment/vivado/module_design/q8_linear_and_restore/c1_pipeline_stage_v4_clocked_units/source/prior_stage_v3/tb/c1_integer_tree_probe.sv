`timescale 1ns/1ps
// Dormant changing-tag clock probe. Bind a generated 32-lane product/tree
// wrapper before running; the bundled adapter fails fast while unbound.
module c1_integer_tree_probe;
  logic clk=0, rst_n=0, req_valid=0;
  logic req_ready, ret_valid;
  logic [16:0] req_seq=0, ret_seq;
  logic [1023:0] req_a_rows=0;
  logic [2047:0] req_w_columns=0;
  logic [671:0] ret_dot21;
  int cycle=0, accepted=0, retired=0;
  logic [16:0] accepted_seq[0:31];
  logic signed [20:0] expected_dot[0:31];
  int accepted_cycle[0:31];

  c1_unbound_integer_tree_adapter service (
    .clk(clk),.rst_n(rst_n),.req_valid(req_valid),.req_ready(req_ready),
    .req_seq(req_seq),.req_a_rows(req_a_rows),.req_w_columns(req_w_columns),
    .ret_valid(ret_valid),.ret_seq(ret_seq),.ret_dot21(ret_dot21));
  always #5ns clk=~clk;
  function automatic logic signed [20:0] frozen_dot(input int i);
    case (i)
      0: return 21'sd524288;    // 32 x (-128) x (-128)
      1: return -21'sd520192;   // 32 x 127 x (-128)
      2: return 21'sd0;         // zero lane
      3: return -21'sd32;       // 32 x 1 x (-1)
      default: return 21'sd516128; // 32 x 127 x 127
    endcase
  endfunction
  task automatic drive_vector(input int phase,input int i);
    logic [7:0] a_byte,w_byte;
    case(i)
      0: begin a_byte=8'h80;w_byte=8'h80;end
      1: begin a_byte=8'h7f;w_byte=8'h80;end
      2: begin a_byte=8'h00;w_byte=8'h7f;end
      3: begin a_byte=8'h01;w_byte=8'hff;end
      default: begin a_byte=8'h7f;w_byte=8'h7f;end
    endcase
    @(negedge clk);
    req_seq=17'(phase*16+i);
    for (int k=0;k<128;k++) req_a_rows[8*k+:8]=a_byte;
    for (int k=0;k<256;k++) req_w_columns[8*k+:8]=w_byte;
    req_valid=1;
    do @(posedge clk); while (req_ready!==1'b1);
    @(negedge clk); req_valid=0;
  endtask
  always @(posedge clk) begin
    cycle++;
    if (cycle>500) $fatal(1,"C1_INTEGER_STREAM_WATCHDOG");
    if (rst_n && req_valid && req_ready) begin
      if (accepted>=32) $fatal(1,"C1_INTEGER_ACCEPT_OVERFLOW");
      accepted_seq[accepted]=req_seq;
      expected_dot[accepted]=frozen_dot(req_seq%16);
      accepted_cycle[accepted]=cycle;
      accepted++;
    end
    #1ps;
    if (rst_n && ret_valid) begin
      if (retired>=accepted || ret_seq!==accepted_seq[retired])
        $fatal(1,"C1_INTEGER_TAG_ORDER");
      for (int lane=0;lane<32;lane++)
        if ($signed(ret_dot21[21*lane+:21])!==expected_dot[retired])
          $fatal(1,"C1_INTEGER_DOT lane=%0d tag=%0d",lane,ret_seq);
      $display("C1_INTEGER_OBS tag=%0d accept=%0d return=%0d latency=%0d",
               ret_seq,accepted_cycle[retired],cycle,
               cycle-accepted_cycle[retired]);
      retired++;
    end
  end
  initial begin
    repeat(4) @(negedge clk);
    rst_n=1;
    for (int i=0;i<5;i++) begin
      drive_vector(0,i);
      if (i==2) repeat(2) @(negedge clk);
    end
    wait(retired==5);
    repeat(3) @(negedge clk);
    rst_n=0; req_valid=0;
    repeat(3) @(negedge clk);
    accepted=0;retired=0;rst_n=1;
    for (int i=4;i>=0;i--) begin
      drive_vector(1,i);
      if (i==3) repeat(1) @(negedge clk);
    end
    wait(retired==5);
    $display("C1_INTEGER_STREAM_OBSERVATION_COMPLETE");
    $finish;
  end
endmodule
