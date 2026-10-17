`timescale 1ns/1ps

module quant16_divider_tb;
  logic clk=0, rst=1, req_valid=0;
  wire req_ready, resp_valid, protocol_fault;
  logic [31:0] req_numerator=0, req_denominator=0;
  logic [101:0] req_tag=0;
  wire [31:0] resp_bits;
  wire [101:0] resp_tag;
  wire [5:0] pending;
  logic [31:0] wi_amax [0:31], wi_d [0:31], wi_recip [0:31];
  logic [31:0] down_amax [0:81], down_d [0:81], down_recip [0:81];
  logic [31:0] amax [0:81], d_full [0:81], reciprocal [0:81];
  string wi_amax_path, wi_d_path, wi_recip_path;
  string down_amax_path, down_d_path, down_recip_path;

  always #3.333 clk=~clk;
  quant16_divider_service dut (
      .clk(clk),.rst(rst),.req_valid(req_valid),.req_ready(req_ready),
      .req_numerator(req_numerator),.req_denominator(req_denominator),
      .req_tag(req_tag),.resp_valid(resp_valid),.resp_bits(resp_bits),
      .resp_tag(resp_tag),.pending(pending),.protocol_fault(protocol_fault)
  );

  task automatic run_case(input int id, input int n);
    int scale_issue, scale_return, recip_issue, recip_return, cycle;
    int recip_expected, last_issue, min_gap, peak_pending;
    int first_scale_last_cycle, first_scale_count;
    int epochs [0:31];
    bit busy [0:31], scale_ready [0:81];
    logic [101:0] scale_tags [0:81], recip_tags [0:81];
    logic [31:0] task_epoch;
    int drive_phase, drive_ordinal;
    logic [101:0] drive_tag;
    begin
      for (int i=0;i<n;i++) begin
        amax[i] = id==1 ? wi_amax[i] : down_amax[i];
        d_full[i] = id==1 ? wi_d[i] : down_d[i];
        reciprocal[i] = id==1 ? wi_recip[i] : down_recip[i];
        if ((^amax[i]===1'bx) || (^d_full[i]===1'bx) ||
            (^reciprocal[i]===1'bx))
          $fatal(1,"divider unknown reference case=%0d group=%0d",id,i);
      end
      for (int i=0;i<32;i++) begin busy[i]=0; epochs[i]=0; end
      for (int i=0;i<82;i++) scale_ready[i]=0;
      scale_issue=0; scale_return=0; recip_issue=0; recip_return=0;
      cycle=0; last_issue=-1; min_gap=2147483647; peak_pending=0;
      first_scale_last_cycle=-1; first_scale_count=0;
      recip_expected=0; task_epoch=id;
      for (int i=0;i<n;i++) if (d_full[i]!=0) recip_expected++;
      req_valid=0; rst=1;
      repeat (4) @(negedge clk);
      rst=0;
      while (scale_return<n || recip_return<recip_expected || pending!=0) begin
        @(negedge clk);
        cycle++;
        if (cycle>10000) $fatal(1,"divider watchdog case=%0d",id);
        req_valid=0; drive_phase=-1; drive_ordinal=-1;
        if (req_ready && scale_issue<n && !busy[scale_issue%32]) begin
          drive_phase=0; drive_ordinal=scale_issue;
          drive_tag={task_epoch,32'(epochs[scale_issue%32]+1),
                     5'(scale_issue%32),32'(scale_issue),1'b0};
          req_numerator=amax[scale_issue];
          req_denominator=32'h42fe0000;
          req_tag=drive_tag; req_valid=1;
        end else if (req_ready && recip_issue<n &&
                     scale_ready[recip_issue]) begin
          if (d_full[recip_issue]==0) begin
            recip_issue++;
          end else begin
            drive_phase=1; drive_ordinal=recip_issue;
            drive_tag={task_epoch,32'(epochs[recip_issue%32]),
                       5'(recip_issue%32),32'(recip_issue),1'b1};
            req_numerator=32'h3f800000;
            req_denominator=d_full[recip_issue];
            req_tag=drive_tag; req_valid=1;
          end
        end
        @(posedge clk);
        if (req_valid && req_ready) begin
          if (last_issue>=0 && cycle-last_issue<min_gap)
            min_gap=cycle-last_issue;
          last_issue=cycle;
          if (drive_phase==0) begin
            if (scale_issue<32) begin
              if (first_scale_last_cycle>=0 && cycle-first_scale_last_cycle!=1)
                $fatal(1,"divider first32 SCALE issue gap case=%0d ordinal=%0d gap=%0d",
                       id,scale_issue,cycle-first_scale_last_cycle);
              first_scale_last_cycle=cycle;
              first_scale_count++;
            end
            if (busy[drive_ordinal%32]) $fatal(1,"slot reuse before retirement");
            busy[drive_ordinal%32]=1;
            epochs[drive_ordinal%32]++;
            scale_tags[drive_ordinal]=drive_tag;
            scale_issue++;
          end else begin
            recip_tags[drive_ordinal]=drive_tag;
            recip_issue++;
          end
        end
        if (resp_valid) begin
          int ordinal;
          bit phase;
          ordinal=int'(resp_tag[32:1]);
          phase=resp_tag[0];
          if (ordinal<0 || ordinal>=n || resp_tag[101:70]!==task_epoch)
            $fatal(1,"divider response identity case=%0d tag=%h",id,resp_tag);
          if (!phase) begin
            if (resp_tag!==scale_tags[ordinal] ||
                resp_bits!==d_full[ordinal])
              $fatal(1,"divider SCALE mismatch case=%0d group=%0d got=%08x gold=%08x tag=%h",
                     id,ordinal,resp_bits,d_full[ordinal],resp_tag);
            scale_ready[ordinal]=1;
            scale_return++;
            if (d_full[ordinal]==0) busy[ordinal%32]=0;
          end else begin
            if (resp_tag!==recip_tags[ordinal] ||
                resp_bits!==reciprocal[ordinal])
              $fatal(1,"divider RECIP mismatch case=%0d group=%0d got=%08x gold=%08x tag=%h",
                     id,ordinal,resp_bits,reciprocal[ordinal],resp_tag);
            busy[ordinal%32]=0;
            recip_return++;
          end
        end
        if (pending>peak_pending) peak_pending=pending;
        if (protocol_fault) $fatal(1,"divider protocol fault case=%0d",id);
      end
      req_valid=0;
      if (scale_issue!=n || scale_return!=n ||
          recip_issue!=n || recip_return!=recip_expected ||
          first_scale_count!=32)
        $fatal(1,"divider conservation case=%0d si=%0d sr=%0d ri=%0d rr=%0d",
               id,scale_issue,scale_return,recip_issue,recip_return);
      for (int i=0;i<32;i++) if (busy[i])
        $fatal(1,"divider unretired slot case=%0d slot=%0d",id,i);
      $display("QUANT16_DIVIDER_REAL_PASS case=%0d groups=%0d scale=%0d recip=%0d min_issue_gap=%0d peak_pending=%0d cycles=%0d",
               id,n,scale_return,recip_return,min_gap,peak_pending,cycle);
    end
  endtask

  task automatic reset_with_old_inflight;
    logic [101:0] fresh_tag;
    int cycles, fresh_returns;
    begin
      req_valid=0; rst=1;
      repeat (3) @(negedge clk);
      rst=0;
      while (!req_ready) @(negedge clk);
      for (int i=0;i<3;i++) begin
        @(negedge clk);
        if (!req_ready) $fatal(1,"divider interrupted setup backpressure");
        req_valid=1;
        req_numerator=wi_amax[i];
        req_denominator=32'h42fe0000;
        req_tag={32'hdeadbeef,32'd1,5'(i),32'(i),1'b0};
        @(posedge clk);
      end
      @(negedge clk);
      req_valid=0; rst=1;
      repeat (2) @(negedge clk);
      rst=0;
      cycles=0;
      while (!req_ready) begin
        @(negedge clk);
        cycles++;
        if (resp_valid || protocol_fault || cycles>20)
          $fatal(1,"divider stale response during reset quarantine");
      end
      fresh_tag={32'h12345678,32'd1,5'd0,32'd0,1'b0};
      req_valid=1; req_numerator=wi_amax[0];
      req_denominator=32'h42fe0000; req_tag=fresh_tag;
      @(posedge clk);
      @(negedge clk); req_valid=0;
      fresh_returns=0;
      for (int i=0;i<25;i++) begin
        @(posedge clk);
        if (resp_valid) begin
          if (resp_tag!==fresh_tag || resp_bits!==wi_d[0])
            $fatal(1,"divider old-epoch response after reset tag=%h bits=%08x",
                   resp_tag,resp_bits);
          fresh_returns++;
        end
        if (protocol_fault) $fatal(1,"divider fault after reset");
      end
      if (fresh_returns!=1 || pending!=0)
        $fatal(1,"divider reset conservation fresh_returns=%0d pending=%0d",
               fresh_returns,pending);
      $display("QUANT16_DIVIDER_RESET_PASS quarantined_cycles=%0d fresh_returns=%0d",
               cycles,fresh_returns);
    end
  endtask

  initial begin
    if (!$value$plusargs("WI_AMAX=%s",wi_amax_path) ||
        !$value$plusargs("WI_D=%s",wi_d_path) ||
        !$value$plusargs("WI_RECIP=%s",wi_recip_path) ||
        !$value$plusargs("DOWN_AMAX=%s",down_amax_path) ||
        !$value$plusargs("DOWN_D=%s",down_d_path) ||
        !$value$plusargs("DOWN_RECIP=%s",down_recip_path))
      $fatal(1,"divider reference paths required");
    $readmemh(wi_amax_path,wi_amax);
    $readmemh(wi_d_path,wi_d);
    $readmemh(wi_recip_path,wi_recip);
    $readmemh(down_amax_path,down_amax);
    $readmemh(down_d_path,down_d);
    $readmemh(down_recip_path,down_recip);
    run_case(1,32);
    run_case(2,82);
    reset_with_old_inflight();
    $display("QUANT16_DIVIDER_RTL_PASS real_groups=114");
    $finish;
  end
endmodule
