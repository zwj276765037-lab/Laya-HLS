`timescale 1ns/1ps
// Dormant bank request/return probe. Required preload codes:
// 0=Wq, 1=Ws, 2=Aq, 3=As, 4=PS, 5=lane_bad. Bind a generated
// wrapper with explicit bank preload/read ports before running.
module c1_bank_probe;
  logic clk=0,rst_n=0,load_valid=0,req_valid=0;
  logic [2:0] load_kind=0;
  logic [5:0] load_bank=0;
  logic [14:0] load_address=0;
  logic [255:0] load_data=0;
  logic req_ready,ret_valid;
  logic [16:0] req_seq=0,ret_seq;
  logic [6:0] req_g=0;
  logic [31:0] req_shape_mask=0,ret_bad_mask;
  logic [14:0] req_w_address=0;
  logic [8:0] req_a_address=0;
  logic [9:0] req_ps_address=0;
  logic req_ps_read_enable=0;
  logic [1023:0] ret_a_rows,ret_old_ps;
  logic [2047:0] ret_w_columns;
  logic [63:0] ret_sa_half;
  logic [127:0] ret_sw_half;
  int cycle=0,accepted=0,retired=0;
  logic [16:0] expected_seq[0:7];
  logic [31:0] expected_ps0[0:7];
  logic [7:0] expected_a_byte[0:7];
  int accepted_cycle[0:7];

  c1_unbound_bank_adapter service (
    .clk(clk),.rst_n(rst_n),.load_valid(load_valid),
    .load_kind(load_kind),.load_bank(load_bank),
    .load_address(load_address),.load_data(load_data),
    .req_valid(req_valid),.req_ready(req_ready),.req_seq(req_seq),
    .req_g(req_g),.req_shape_mask(req_shape_mask),
    .req_w_address(req_w_address),.req_a_address(req_a_address),
    .req_ps_address(req_ps_address),.req_ps_read_enable(req_ps_read_enable),
    .ret_valid(ret_valid),.ret_seq(ret_seq),.ret_bad_mask(ret_bad_mask),
    .ret_a_rows(ret_a_rows),.ret_w_columns(ret_w_columns),
    .ret_sa_half(ret_sa_half),.ret_sw_half(ret_sw_half),
    .ret_old_ps(ret_old_ps));
  always #5ns clk=~clk;
  task automatic load_word(input logic [2:0] kind,
                           input logic [5:0] bank,
                           input logic [14:0] address,
                           input logic [255:0] data);
    @(negedge clk);
    load_kind=kind;load_bank=bank;load_address=address;
    load_data=data;load_valid=1;
    @(posedge clk);
    @(negedge clk);load_valid=0;
  endtask
  task automatic prepare_banks(input logic [7:0] a_byte,
                               input logic [31:0] ps0);
    logic [255:0] packed;
    for (int bank=0;bank<8;bank++) begin
      packed=0;
      for (int k=0;k<32;k++)
        packed[8*k+:8]=bank==0 ? 8'h80 : bank==1 ? 8'h7f : 8'h00;
      load_word(3'd0,6'(bank),15'd7,packed);
      load_word(3'd1,6'(bank),15'd7,256'h3c00);
    end
    for (int bank=0;bank<4;bank++) begin
      packed=0;
      for (int k=0;k<32;k++) packed[8*k+:8]=a_byte;
      load_word(3'd2,6'(bank),15'd3,packed);
      load_word(3'd3,6'(bank),15'd3,256'h3c00);
    end
    // Every lane_bad is initialized. Only active lane0 has a valid old PS;
    // lane1 is failed, and the other PS payloads remain deliberately unwritten.
    for (int bank=0;bank<32;bank++)
      load_word(3'd5,6'(bank),15'd5,256'(bank==1));
    load_word(3'd4,6'd0,15'd5,256'(ps0));
  endtask
  task automatic request(input logic [16:0] seq,input logic [6:0] g,
                         input logic [7:0] a_byte,
                         input logic [31:0] ps0);
    @(negedge clk);
    req_seq=seq;req_g=g;req_shape_mask=32'h3;
    req_w_address=15'd7;req_a_address=9'd3;req_ps_address=10'd5;
    req_ps_read_enable=(g!=0);req_valid=1;
    do @(posedge clk); while (req_ready!==1'b1);
    @(negedge clk);req_valid=0;
  endtask
  always @(posedge clk) begin
    cycle++;
    if (cycle>500) $fatal(1,"C1_BANK_STREAM_WATCHDOG");
    if (rst_n && req_valid && req_ready) begin
      if (accepted>=8) $fatal(1,"C1_BANK_ACCEPT_OVERFLOW");
      expected_seq[accepted]=req_seq;
      expected_ps0[accepted]=req_g==0 ? 32'h00000000 :
                              (req_seq==17'd8 ? 32'h3f800000 :
                               32'h40400000);
      expected_a_byte[accepted]=req_seq<17'd16 ? 8'h12 : 8'h34;
      accepted_cycle[accepted]=cycle;
      accepted++;
    end
    #1ps;
    if (rst_n && ret_valid) begin
      if (retired>=accepted || ret_seq!==expected_seq[retired])
        $fatal(1,"C1_BANK_TAG_ORDER");
      if (ret_bad_mask[1]!==1'b1 ||
          ret_old_ps[31:0]!==expected_ps0[retired] ||
          ret_old_ps[63:32]!==32'h0 ||
          ret_old_ps[1023:64]!==960'h0)
        $fatal(1,"C1_BANK_FIRST_USE_OR_MASK");
      for (int k=0;k<32;k++)
        if (ret_a_rows[8*k+:8]!==expected_a_byte[retired])
          $fatal(1,"C1_BANK_A_RETURN");
      if (ret_w_columns[255:0]!=={32{8'h80}} ||
          ret_w_columns[511:256]!=={32{8'h7f}} ||
          ret_sa_half[15:0]!==16'h3c00 ||
          ret_sw_half[15:0]!==16'h3c00)
        $fatal(1,"C1_BANK_OPERAND_RETURN");
      $display("C1_BANK_OBS tag=%0d accept=%0d return=%0d",
               ret_seq,accepted_cycle[retired],cycle);
      retired++;
    end
  end
  initial begin
    repeat(4) @(negedge clk);rst_n=1;
    prepare_banks(8'h12,32'h3f800000);
    request(17'd7,7'd0,8'h12,32'h3f800000);
    repeat(2) @(negedge clk);
    request(17'd8,7'd1,8'h12,32'h3f800000);
    wait(retired==2);
    repeat(3) @(negedge clk);rst_n=0;
    repeat(3) @(negedge clk);accepted=0;retired=0;rst_n=1;
    prepare_banks(8'h34,32'h40400000);
    request(17'd23,7'd0,8'h34,32'h40400000);
    request(17'd24,7'd1,8'h34,32'h40400000);
    wait(retired==2);
    $display("C1_BANK_STREAM_OBSERVATION_COMPLETE");
    $finish;
  end
endmodule
