`timescale 1ns/1ps

// Finite, exact F32 diagnostics for the same bank and real FP IP as C3/C4.
module av_feedback_short_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0, config_valid=0, config_ready;
  logic [15:0] config_active_mask=0;
  logic bind_valid=0, bind_ready;
  logic [3:0] bind_addr=0;
  logic [7:0] bind_slot=0;
  logic [31:0] bind_slot_epoch=0, bind_task_id=0;
  logic [15:0] bind_row=0;
  logic [671:0] bind_identity=0;
  logic [639:0] bind_refs=0;
  logic start_valid=0, start_ready;
  logic issue_valid=0, issue_ready;
  logic [7:0] issue_slot=0, issue_lane=0;
  logic [31:0] issue_slot_epoch=0, issue_task_id=0;
  logic [15:0] issue_row=0, issue_key=0;
  logic [31:0] issue_prob=0, issue_v=0;
  logic diagnostic_valid, diagnostic_ready=1;
  logic [115:0] diagnostic_tag;
  logic [671:0] diagnostic_identity;
  logic [639:0] diagnostic_refs;
  logic [31:0] diagnostic_product, diagnostic_old_partial;
  logic [31:0] diagnostic_next_partial;
  logic mul_accept_event, mul_return_event;
  logic partial_read_accept_event, partial_read_return_event;
  logic [3:0] partial_read_addr_event;
  logic add_accept_event, add_return_event, partial_write_commit_event;
  logic [3:0] partial_write_addr_event;
  logic diagnostic_retire_event;
  logic [5:0] product_occupied, commit_occupied;
  logic [15:0] busy_mask, initialized_mask;
  logic done_valid, done_error, protocol_failure;
  logic [12:0] accepted_count;
  av_feedback_bank_v1 dut (.*);

  localparam logic [31:0] ONE=32'h3f800000;
  localparam logic [671:0] IDENTITY=672'h2345;
  localparam logic [639:0] REFS=640'h6789;
  int epoch=0, ticks=0, accepts=0, diagnostics=0, writes=0;
  int reads=0, mul_returns=0, read_returns=0, add_accepts=0;
  int add_returns=0, feedback_min=32'h7fffffff, feedback_max=0;
  int last_read [0:15], last_write [0:15];
  int last_accept=-1, gap_min=32'h7fffffff;
  int gap_max=0, measured_f=0, measured_ii=0, credit_blocked=0;

  function automatic logic [31:0] f32_uint(input int value);
    int exponent, mantissa;
    if (value==0) return 32'd0;
    exponent=0;
    for (int b=1;b<8;b++)
      if (value >= (1<<b)) exponent=b;
    mantissa=(value<<(23-exponent))-(1<<23);
    return {1'b0,8'(exponent+127),23'(mantissa)};
  endfunction

  always @(posedge clk) begin : observe
    int addr, key;
    if (!rst_n) begin
      ticks=0; accepts=0; diagnostics=0; writes=0; reads=0;
      mul_returns=0; read_returns=0; add_accepts=0; add_returns=0;
      feedback_min=32'h7fffffff; feedback_max=0;
      last_accept=-1; gap_min=32'h7fffffff; gap_max=0;
      for (int a=0;a<16;a++) begin
        last_read[a]=-1;
        last_write[a]=-1;
      end
    end else begin
      ticks++;
      if (ticks>200000) $fatal(1,"AV short cycle cap");
      if (mul_accept_event) begin
        if (last_accept>=0) begin
          if (ticks-last_accept<gap_min) gap_min=ticks-last_accept;
          if (ticks-last_accept>gap_max) gap_max=ticks-last_accept;
        end
        last_accept=ticks;
        accepts++;
      end
      if (mul_return_event) mul_returns++;
      if (partial_read_return_event) read_returns++;
      if (add_accept_event) add_accepts++;
      if (add_return_event) add_returns++;
      if (partial_read_accept_event) begin
        addr=int'(partial_read_addr_event);
        if (last_read[addr]>=0) begin
          if (last_write[addr]<=last_read[addr] ||
              last_write[addr]>=ticks)
            $fatal(1,"AV short read before same-address write addr=%0d",addr);
          if (ticks-last_read[addr]<feedback_min)
            feedback_min=ticks-last_read[addr];
          if (ticks-last_read[addr]>feedback_max)
            feedback_max=ticks-last_read[addr];
        end
        last_read[addr]=ticks;
        reads++;
      end
      if (partial_write_commit_event) begin
        addr=int'(partial_write_addr_event);
        if (last_read[addr]<0 || last_read[addr]>=ticks)
          $fatal(1,"AV short write without prior read addr=%0d",addr);
        last_write[addr]=ticks;
        writes++;
      end
      if (diagnostic_retire_event) begin
        addr=int'(diagnostic_tag[3:0]);
        key=int'(diagnostic_tag[27:12]);
        if (diagnostic_tag[115:108] !== 8'(addr/4) ||
            diagnostic_tag[107:76] !== 32'(epoch) ||
            diagnostic_tag[75:44] !== 32'(100+epoch) ||
            diagnostic_tag[43:28] !== 16'((addr%4)*4) ||
            diagnostic_tag[11:4] !== 8'd0 ||
            diagnostic_identity !== IDENTITY || diagnostic_refs !== REFS ||
            diagnostic_product !== ONE ||
            diagnostic_old_partial !== f32_uint(key) ||
            diagnostic_next_partial !== f32_uint(key+1))
          $fatal(1,"AV short diagnostic mismatch addr=%0d key=%0d epoch=%0d old=%h next=%h",
                 addr,key,epoch,diagnostic_old_partial,
                 diagnostic_next_partial);
        diagnostics++;
      end
    end
  end

  task automatic reset_bank;
    @(negedge clk);
    rst_n=0; config_valid=0; bind_valid=0; start_valid=0;
    issue_valid=0; diagnostic_ready=1;
    repeat (12) @(negedge clk);
    rst_n=1;
  endtask

  task automatic configure(input logic [15:0] mask, input int new_epoch);
    @(negedge clk);
    epoch=new_epoch;
    config_active_mask=mask; config_valid=1;
    #1ps;
    if (!config_ready) $fatal(1,"AV short config not ready");
    @(posedge clk);
    @(negedge clk);
    config_valid=0;
    for (int a=0;a<16;a++) if (mask[a]) begin
      bind_addr=4'(a); bind_slot=8'(a/4);
      bind_slot_epoch=32'(epoch); bind_task_id=32'(100+epoch);
      bind_row=16'((a%4)*4);
      bind_identity=IDENTITY; bind_refs=REFS; bind_valid=1;
      #1ps;
      if (!bind_ready) $fatal(1,"AV short bind not ready addr=%0d",a);
      @(posedge clk);
      @(negedge clk);
      bind_valid=0;
    end
    start_valid=1;
    #1ps;
    if (!start_ready || initialized_mask !== mask)
      $fatal(1,"AV short initialization mismatch");
    @(posedge clk);
    @(negedge clk);
    start_valid=0;
  endtask

  task automatic set_issue(input int addr, input int key);
    issue_slot=8'(addr/4);
    issue_slot_epoch=32'(epoch);
    issue_task_id=32'(100+epoch);
    issue_row=16'((addr%4)*4);
    issue_key=16'(key);
    issue_lane=0;
    issue_prob=ONE;
    issue_v=ONE;
    issue_valid=1;
  endtask

  task automatic send_one(input int addr, input int key);
    int patience;
    @(negedge clk);
    set_issue(addr,key);
    #1ps;
    patience=0;
    while (!issue_ready) begin
      @(negedge clk);
      #1ps;
      patience++;
      if (patience>2000) $fatal(1,"AV short issue timeout");
    end
    @(posedge clk);
    @(negedge clk);
    issue_valid=0;
  endtask

  task automatic await_diagnostics(input int expected);
    int patience;
    patience=0;
    while (diagnostics<expected) begin
      @(negedge clk);
      patience++;
      if (patience>10000) $fatal(1,"AV short diagnostic drain timeout");
    end
    if (diagnostics!=expected || accepts!=expected ||
        mul_returns!=expected || reads!=expected ||
        read_returns!=expected || add_accepts!=expected ||
        add_returns!=expected || writes!=expected ||
        product_occupied!=0 || commit_occupied!=0 || busy_mask!=0)
      $fatal(1,"AV short event debt expected=%0d accept=%0d diag=%0d mul=%0d read=%0d add=%0d write=%0d",
             expected,accepts,diagnostics,mul_returns,reads,
             add_returns,writes);
  endtask

  task automatic await_done(input bit expect_error);
    int patience;
    patience=0;
    while (!done_valid) begin
      @(negedge clk);
      patience++;
      if (patience>10000) $fatal(1,"AV short done timeout");
    end
    if (done_error !== expect_error || protocol_failure !== expect_error)
      $fatal(1,"AV short wrong done error=%0d protocol=%0d",done_error,
             protocol_failure);
  endtask

  initial begin : test
    int blocked, next_key, patience;
    logic [115:0] held_tag;
    logic [31:0] held_product, held_old, held_next;
    reset_bank();
    configure(16'h0001,1);
    for (int key=0;key<128;key++) send_one(0,key);
    await_done(0);
    await_diagnostics(128);
    if (feedback_min==32'h7fffffff || feedback_min!=feedback_max)
      $fatal(1,"AV short intrinsic feedback inconsistent min=%0d max=%0d",
             feedback_min,feedback_max);
    measured_f=feedback_min;

    reset_bank();
    configure(16'hffff,2);
    // Measure 256 accept intervals over sixteen independent addresses.
    for (int key=0;key<16;key++)
      for (int addr=0;addr<16;addr++) begin
        @(negedge clk);
        set_issue(addr,key);
        #1ps;
        patience=0;
        while (!issue_ready) begin
          @(negedge clk);
          #1ps;
          patience++;
          if (patience>1000)
            $fatal(1,"AV short multi-address issue timeout key=%0d addr=%0d",key,addr);
        end
        @(posedge clk);
      end
    @(negedge clk);
    issue_valid=0;
    await_diagnostics(256);
    if (gap_min<1 || gap_max<gap_min)
      $fatal(1,"AV short multi-address interval invalid min=%0d max=%0d",gap_min,gap_max);
    measured_ii=gap_max;

    reset_bank();
    configure(16'h0001,3);
    diagnostic_ready=0;
    next_key=0; blocked=0; patience=0;
    while (blocked<20) begin
      @(negedge clk);
      set_issue(0,next_key);
      #1ps;
      if (issue_ready) begin
        if (next_key>=128) $fatal(1,"AV short failed to fill credit");
        next_key++;
        blocked=0;
      end else if (commit_occupied==32 && product_occupied==32) begin
        blocked++;
        credit_blocked=1;
      end
      @(posedge clk);
      patience++;
      if (patience>3000) $fatal(1,"AV short credit did not fill");
    end
    @(negedge clk);
    issue_valid=0;
    if (!diagnostic_valid || diagnostics!=0 || !credit_blocked)
      $fatal(1,"AV short diagnostic credit did not block");
    held_tag=diagnostic_tag;
    held_product=diagnostic_product;
    held_old=diagnostic_old_partial;
    held_next=diagnostic_next_partial;
    repeat (8) begin
      @(negedge clk);
      if (!diagnostic_valid || diagnostic_tag !== held_tag ||
          diagnostic_product !== held_product ||
          diagnostic_old_partial !== held_old ||
          diagnostic_next_partial !== held_next)
        $fatal(1,"AV short diagnostic payload changed under backpressure");
    end
    diagnostic_ready=1;
    for (int key=next_key;key<128;key++) send_one(0,key);
    await_done(0);
    await_diagnostics(128);

    for (int fault=0;fault<3;fault++) begin
      reset_bank();
      configure(16'h0001,10+fault);
      @(negedge clk);
      set_issue(0,0);
      if (fault==0) issue_slot_epoch=32'(epoch+1);
      if (fault==1) issue_row=16'd4;
      if (fault==2) issue_key=16'd1;
      #1ps;
      if (!issue_ready) $fatal(1,"AV short invalid request not accepted");
      @(posedge clk);
      @(negedge clk);
      issue_valid=0;
      await_done(1);
      if (accepted_count!=0 || accepts!=0 || writes!=0 ||
          product_occupied!=0 || commit_occupied!=0)
        $fatal(1,"AV short invalid request changed debt fault=%0d",fault);
    end

    reset_bank();
    configure(16'h0001,20);
    send_one(0,0);
    reset_bank(); // FMUL valid is still in flight.
    configure(16'h0001,21);
    send_one(0,0);
    patience=0;
    while (!add_accept_event) begin
      @(negedge clk);
      patience++;
      if (patience>100) $fatal(1,"AV short FADD in-flight setup timeout");
    end
    reset_bank(); // FADD valid is now in flight.
    configure(16'h0001,22);
    for (int key=0;key<128;key++) send_one(0,key);
    await_done(0);
    await_diagnostics(128);
    $display("AV_FEEDBACK_SHORT_PASS intrinsic_F=%0d multi_address_II=%0d credit_blocked=%0d reset_recovery=2 rejects=3",
             measured_f,measured_ii,credit_blocked);
    $finish;
  end
endmodule
