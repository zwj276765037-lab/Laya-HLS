`timescale 1ns/1ps

// Full-head feature-0 projection using external, independent QK/softmax gold.
// The two invocations differ only in C3/C4 ctx binding and issue order.
module av_feedback_real_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, config_valid, config_ready;
  logic [15:0] config_active_mask;
  logic bind_valid, bind_ready;
  logic [3:0] bind_addr;
  logic [7:0] bind_slot;
  logic [31:0] bind_slot_epoch, bind_task_id;
  logic [15:0] bind_row;
  logic [671:0] bind_identity;
  logic [639:0] bind_refs;
  logic start_valid, start_ready, issue_valid, issue_ready;
  logic [7:0] issue_slot, issue_lane;
  logic [31:0] issue_slot_epoch, issue_task_id, issue_prob, issue_v;
  logic [15:0] issue_row, issue_key;
  logic diagnostic_valid, diagnostic_ready;
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

  logic [31:0] prob [0:4095], product [0:4095], partial_gold [0:4095];
  logic [31:0] v_feature0 [0:127];
  logic [671:0] numeric_identity [0:0];
  string gold_dir;
  int mode, cycles, batch_diagnostics, total_accepted, total_diagnostics;
  int stalls, mul_accepts, mul_returns, reads, read_returns;
  int add_accepts, add_returns, writes, diagnostic_retires;
  int last_read_tick [0:15], last_write_tick [0:15];
  int read_count [0:15], feedback_min, feedback_max, feedback_sum;
  int feedback_count, batch_first_tile, batch_contexts;
  int max_product_occupied, max_commit_occupied;
  int last_mul_accept_tick, accept_gap_min, accept_gap_max, accept_gap_sum;
  int accept_gap_count, batch_config_cycle, batch_first_issue_cycle;
  int batch_last_issue_cycle;
  int batch_first_read_cycle, batch_last_read_cycle, batch_read_count;
  int batch_last_write_cycle, batch_last_diag_cycle;

  function automatic logic [639:0] refs_for(input int row, slot, epoch);
    logic [639:0] result;
    for (int i=0;i<5;i++)
      result[i*128 +: 128] =
          {32'h41564642,32'(epoch),16'(row),8'(slot),40'(i)};
    return result;
  endfunction

  always @(posedge clk) begin
    int row, key, addr, index, tick;
    if (!rst_n) begin
      cycles=0;
    end else begin
      cycles++;
      tick=int'($time/10);
      if (cycles>40000000) $fatal(1,"AV real 40M cycle cap");
      if (mul_accept_event) mul_accepts++;
      if (mul_accept_event) begin
        if (last_mul_accept_tick >= 0) begin
          if (tick-last_mul_accept_tick < accept_gap_min)
            accept_gap_min=tick-last_mul_accept_tick;
          if (tick-last_mul_accept_tick > accept_gap_max)
            accept_gap_max=tick-last_mul_accept_tick;
          accept_gap_sum+=tick-last_mul_accept_tick;
          accept_gap_count++;
        end
        last_mul_accept_tick=tick;
      end
      if (int'(product_occupied)>max_product_occupied)
        max_product_occupied=int'(product_occupied);
      if (int'(commit_occupied)>max_commit_occupied)
        max_commit_occupied=int'(commit_occupied);
      if (mul_return_event) mul_returns++;
      if (add_accept_event) add_accepts++;
      if (add_return_event) add_returns++;
      if (partial_read_return_event) read_returns++;
      if (partial_read_accept_event) begin
        if (batch_first_read_cycle<0) batch_first_read_cycle=tick;
        batch_last_read_cycle=tick;
        batch_read_count++;
        addr=int'(partial_read_addr_event);
        if (read_count[addr]>0) begin
          if (last_write_tick[addr]<last_read_tick[addr] ||
              last_write_tick[addr]>=tick)
            $fatal(1,"AV real same-address read before prior write addr=%0d",addr);
          if (tick-last_read_tick[addr]<feedback_min)
            feedback_min=tick-last_read_tick[addr];
          if (tick-last_read_tick[addr]>feedback_max)
            feedback_max=tick-last_read_tick[addr];
          feedback_sum+=tick-last_read_tick[addr];
          feedback_count++;
        end
        last_read_tick[addr]=tick;
        read_count[addr]++;
        reads++;
      end
      if (partial_write_commit_event) begin
        addr=int'(partial_write_addr_event);
        if (last_read_tick[addr]<0 || last_read_tick[addr]>=tick)
          $fatal(1,"AV real write without preceding read addr=%0d",addr);
        last_write_tick[addr]=tick;
        batch_last_write_cycle=tick;
        writes++;
      end
      if (diagnostic_retire_event) begin
        row=int'(diagnostic_tag[43:28]);
        key=int'(diagnostic_tag[27:12]);
        addr=int'(diagnostic_tag[3:0]);
        index=(row/4)*128+key;
        if (row<0 || row>=128 || row%4!=0 || key<0 || key>=128 ||
            addr >= batch_contexts*4 ||
            row != (batch_first_tile+addr/4)*16+(addr%4)*4 ||
            diagnostic_tag[11:4] !== 8'd0 ||
            diagnostic_identity !== numeric_identity[0] ||
            diagnostic_refs !== refs_for(row,int'(diagnostic_tag[115:108]),
                                         int'(diagnostic_tag[107:76])) ||
            diagnostic_product !== product[index] ||
            diagnostic_old_partial !==
                (key==0 ? 32'd0 : partial_gold[index-1]) ||
            diagnostic_next_partial !== partial_gold[index])
          $fatal(1,"AV real diagnostic mismatch row=%0d key=%0d addr=%0d got=%h/%h/%h expected=%h/%h/%h",
                 row,key,addr,diagnostic_product,diagnostic_old_partial,
                 diagnostic_next_partial,product[index],
                 key==0 ? 32'd0 : partial_gold[index-1],partial_gold[index]);
        if (key != batch_diagnostics/(batch_contexts*4) ||
            addr != batch_diagnostics%(batch_contexts*4))
          $fatal(1,"AV real diagnostic order row=%0d key=%0d addr=%0d expected=%0d",
                 row,key,addr,batch_diagnostics);
        batch_diagnostics++;
        batch_last_diag_cycle=tick;
        total_diagnostics++;
        diagnostic_retires++;
      end
      if (cycles%100000==0)
        $display("AV_REAL_PROGRESS cycles=%0d accepted=%0d diagnostics=%0d",
                 cycles,total_accepted,total_diagnostics);
    end
  end

  initial begin : test
    int ctx, group, row, index, batch, first_tile, contexts, n, timeout;
    if (!$value$plusargs("GOLD_DIR=%s",gold_dir) ||
        !$value$plusargs("MODE=%d",mode) || (mode!=3 && mode!=4))
      $fatal(1,"AV GOLD_DIR and MODE=3|4 required");
    $readmemh({gold_dir,"/prob.mem"},prob);
    $readmemh({gold_dir,"/product.mem"},product);
    $readmemh({gold_dir,"/partial.mem"},partial_gold);
    $readmemh({gold_dir,"/v_feature0.mem"},v_feature0);
    $readmemh({gold_dir,"/numeric_identity.mem"},numeric_identity);
    rst_n=0; config_valid=0; config_active_mask=0;
    bind_valid=0; bind_addr=0; bind_slot=0; bind_slot_epoch=0;
    bind_task_id=0; bind_row=0; bind_identity=0; bind_refs=0;
    start_valid=0; issue_valid=0; issue_slot=0; issue_slot_epoch=0;
    issue_task_id=0; issue_row=0; issue_key=0; issue_lane=0;
    issue_prob=0; issue_v=0; diagnostic_ready=1;
    total_accepted=0; total_diagnostics=0; stalls=0;
    mul_accepts=0; mul_returns=0; reads=0; read_returns=0;
    add_accepts=0; add_returns=0; writes=0; diagnostic_retires=0;
    feedback_min=32'h7fffffff; feedback_max=0; feedback_sum=0;
    feedback_count=0; batch_diagnostics=0; batch_first_tile=0;
    batch_contexts=0;
    max_product_occupied=0; max_commit_occupied=0;
    last_mul_accept_tick=-1; accept_gap_min=32'h7fffffff;
    accept_gap_max=0; accept_gap_sum=0; accept_gap_count=0;
    for (int a=0;a<16;a++) begin
      last_read_tick[a]=-1; last_write_tick[a]=-1; read_count[a]=0;
    end
    repeat (12) @(negedge clk);
    rst_n=1;
    for (batch=0;batch<(mode==3 ? 3 : 2);batch++) begin
      first_tile=batch*mode;
      contexts=(8-first_tile<mode ? 8-first_tile : mode);
      n=contexts*4;
      batch_first_tile=first_tile;
      batch_contexts=contexts;
      batch_diagnostics=0;
      for (int a=0;a<16;a++) begin
        last_read_tick[a]=-1; last_write_tick[a]=-1; read_count[a]=0;
      end
      @(negedge clk);
      batch_config_cycle=int'($time/10);
      batch_first_issue_cycle=-1;
      batch_last_issue_cycle=-1;
      batch_first_read_cycle=-1;
      batch_last_read_cycle=-1;
      batch_read_count=0;
      batch_last_write_cycle=-1;
      batch_last_diag_cycle=-1;
      config_active_mask=16'((1<<n)-1);
      config_valid=1;
      #1ps;
      if (!config_ready) $fatal(1,"AV real config not ready batch=%0d",batch);
      @(posedge clk);
      @(negedge clk);
      config_valid=0;
      for (ctx=0;ctx<contexts;ctx++)
        for (group=0;group<4;group++) begin
          row=(first_tile+ctx)*16+group*4;
          bind_addr=4'(ctx*4+group);
          bind_slot=8'(ctx);
          bind_slot_epoch=32'(batch+1);
          bind_task_id=32'(500+first_tile+ctx);
          bind_row=16'(row);
          bind_identity=numeric_identity[0];
          bind_refs=refs_for(row,ctx,batch+1);
          bind_valid=1;
          #1ps;
          if (!bind_ready) $fatal(1,"AV real bind not ready row=%0d",row);
          @(posedge clk);
          @(negedge clk);
          bind_valid=0;
        end
      start_valid=1;
      #1ps;
      if (!start_ready || initialized_mask != config_active_mask)
        $fatal(1,"AV real batch init incomplete batch=%0d",batch);
      @(posedge clk);
      @(negedge clk);
      start_valid=0;
      for (int key=0;key<128;key++)
        for (ctx=0;ctx<contexts;ctx++)
          for (group=0;group<4;group++) begin
            row=(first_tile+ctx)*16+group*4;
            index=(row/4)*128+key;
            issue_slot=8'(ctx);
            issue_slot_epoch=32'(batch+1);
            issue_task_id=32'(500+first_tile+ctx);
            issue_row=16'(row);
            issue_key=16'(key);
            issue_lane=0;
            issue_prob=prob[index];
            issue_v=v_feature0[key];
            issue_valid=1;
            #1ps;
            while (!issue_ready) begin
              stalls++;
              @(negedge clk);
              #1ps;
              if (stalls>40000000) $fatal(1,"AV real issue timeout");
            end
            @(posedge clk);
            if (batch_first_issue_cycle < 0)
              batch_first_issue_cycle=int'($time/10);
            batch_last_issue_cycle=int'($time/10);
            total_accepted++;
            @(negedge clk);
          end
      issue_valid=0;
      timeout=0;
      while (!done_valid) begin
        @(negedge clk);
        timeout++;
        if (timeout>10000) $fatal(1,"AV real batch drain timeout");
      end
      if (done_error || protocol_failure || accepted_count != n*128 ||
          batch_diagnostics != n*128 || product_occupied != 0 ||
          commit_occupied != 0 || busy_mask != 0 ||
          batch_read_count != n*128)
        $fatal(1,"AV real batch terminal failure batch=%0d accepted=%0d diagnostics=%0d",
               batch,accepted_count,batch_diagnostics);
      $display("AV_REAL_BATCH mode=C%0d batch=%0d contexts=%0d init_to_first_issue=%0d issue_span=%0d read_span=%0d read_to_last_write=%0d write_to_done=%0d diag_to_done=%0d tail_to_done=%0d",
               mode,batch,contexts,batch_first_issue_cycle-batch_config_cycle,
               batch_last_issue_cycle-batch_first_issue_cycle+1,
               batch_last_read_cycle-batch_first_read_cycle+1,
               batch_last_write_cycle-batch_last_read_cycle,
               int'($time/10)-batch_last_write_cycle,
               int'($time/10)-batch_last_diag_cycle,
               int'($time/10)-batch_last_issue_cycle);
    end
    if (total_accepted!=4096 || total_diagnostics!=4096 ||
        mul_accepts!=4096 || mul_returns!=4096 || reads!=4096 ||
        read_returns!=4096 || add_accepts!=4096 || add_returns!=4096 ||
        writes!=4096 || diagnostic_retires!=4096 || feedback_count!=4064)
      $fatal(1,"AV real event conservation accepted=%0d diag=%0d read=%0d write=%0d feedback=%0d",
             total_accepted,total_diagnostics,reads,writes,feedback_count);
    $display("AV_FEEDBACK_REAL_PASS mode=C%0d contributions=4096 feedback_samples=%0d min=%0d max=%0d sum=%0d stalls=%0d cycles=%0d accept_gap_min=%0d accept_gap_max=%0d accept_gap_sum=%0d accept_gap_samples=%0d product_high=%0d commit_high=%0d",
             mode,feedback_count,feedback_min,feedback_max,feedback_sum,
             stalls,cycles,accept_gap_min,accept_gap_max,accept_gap_sum,
             accept_gap_count,max_product_occupied,max_commit_occupied);
    $finish;
  end
endmodule
