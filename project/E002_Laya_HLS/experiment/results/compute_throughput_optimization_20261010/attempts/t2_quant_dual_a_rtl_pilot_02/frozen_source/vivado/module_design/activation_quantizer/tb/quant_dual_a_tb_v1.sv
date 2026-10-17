`timescale 1ns/1ps
module quant_dual_a_tb_v1;
  logic clk,rst_n;
  logic fill_valid;
  logic fill_ready,fill_reject;
  logic fill_owner_admitted,fill_source_published,fill_slot;
  logic [31:0] fill_slot_epoch;
  logic [12:0] fill_K;
  logic [4:0] fill_rows;
  logic [671:0] fill_numeric_identity;
  logic [95:0] fill_producer_context,fill_quant_context,fill_linear_context;
  logic [63:0] fill_source_ref,fill_a_ref,fill_w_ref,fill_dst_ref;
  logic commit_valid;
  logic commit_ready,commit_error;
  logic [671:0] commit_numeric_identity;
  logic [95:0] commit_quant_context;
  logic [63:0] commit_a_ref;
  logic [3:0] commit_row;
  logic [6:0] commit_group;
  logic commit_half;
  logic [127:0] commit_q;
  logic [15:0] commit_scale;
  logic row_done_valid;
  logic row_done_ready;
  logic [3:0] row_done_row;
  logic [1:0] row_done_status;
  logic [15:0] row_done_bad_col;
  logic row_done_debt_zero;
  logic finish_valid;
  logic finish_ready,fill_done,fill_error,publish_valid;
  logic finish_debt_zero;
  logic [63:0] fill_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch;
  logic [1:0][15:0] slot_rows_done;
  logic [31:0] physical_half_commits,physical_scale_commits;
  logic acquire_valid;
  logic acquire_ready,acquire_done,acquire_error;
  logic acquire_slot;
  logic [31:0] acquire_slot_epoch;
  logic [12:0] acquire_K;
  logic [4:0] acquire_rows;
  logic [671:0] acquire_numeric_identity;
  logic [95:0] acquire_linear_context;
  logic [63:0] acquire_a_ref,acquire_w_ref,acquire_dst_ref;
  logic read_valid;
  logic read_ready,read_error;
  logic read_slot;
  logic [31:0] read_slot_epoch;
  logic [671:0] read_numeric_identity;
  logic [95:0] read_linear_context;
  logic [63:0] read_a_ref;
  logic [3:0] read_row_block_base;
  logic [2:0] read_rows;
  logic [6:0] read_group;
  logic ret_valid;
  logic ret_ready;
  logic ret_slot;
  logic [31:0] ret_slot_epoch;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_linear_context;
  logic [63:0] ret_a_ref;
  logic [3:0] ret_row_block_base;
  logic [2:0] ret_rows;
  logic [6:0] ret_group;
  logic [3:0][255:0] ret_q;
  logic [3:0][15:0] ret_scale;
  logic release_valid;
  logic release_ready,release_done,release_error;
  logic release_slot;
  logic [31:0] release_slot_epoch;
  logic [671:0] release_numeric_identity;
  logic [95:0] release_linear_context;
  logic [63:0] release_a_ref;
  logic read_debt_zero;
  quant_dual_a_v1 dut(.*);
  initial clk=0; always #3.333 clk=~clk;
  integer cycles=0,checked=0,held=0,overlap_reads=0;
  always @(posedge clk) begin cycles<=cycles+1; if(cycles>100000) $fatal(1,"cycle budget");end
  function automatic logic [127:0] qgold(input int slot,input int row,input int group,input int half);
    logic [127:0] value;
    for(int lane=0;lane<16;lane++) value[lane*8+:8]=8'((slot*73+row*17+group*3+half*16+lane)%255);
    return value;
  endfunction
  function automatic logic [15:0] sgold(input int slot,input int row,input int group);
    return 16'h3400+16'(slot*512+row*16+group);
  endfunction
  task automatic tick; @(posedge clk); #1;endtask
  task automatic setup(input int slot,input int epoch,input int kval,input int nrows);
    @(negedge clk);
    fill_slot=1'(slot);fill_slot_epoch=epoch;fill_K=13'(kval);fill_rows=5'(nrows);
    fill_numeric_identity=672'hfedcba98765432100123456789abcdef;
    fill_numeric_identity[63:0]=64'h100000001;fill_numeric_identity[127:64]=64'h200000001;
    fill_numeric_identity[143:128]=1;fill_numeric_identity[159:144]=128;fill_numeric_identity[671:640]=32'h80000001;
    fill_quant_context=0;fill_quant_context[31:0]=epoch*16+1;
    fill_quant_context[47:40]=kval==256 ? 6 : kval==4096 ? 4 : 2;
    fill_quant_context[71:64]=kval==256 ? 2 : 0;
    fill_quant_context[95:88]=8'(nrows);
    fill_producer_context=fill_quant_context;fill_producer_context[31:0]=epoch*16;
    fill_linear_context=fill_quant_context;fill_linear_context[31:0]=epoch*16+2;
    fill_source_ref=0;fill_source_ref[31:0]=epoch;
    fill_source_ref[39:32]=kval==256 ? 10 : kval==2624 ? 7 : kval==4096 ? 9 : 2;
    fill_source_ref[55:48]=kval==256 ? 2 : 0;
    fill_a_ref=0;fill_a_ref[31:0]=epoch;fill_a_ref[39:32]=8'h22;fill_a_ref[47:40]=8'(slot);
    fill_w_ref=64'h0023000000000001;fill_dst_ref=64'h0003000000000001;
    fill_owner_admitted=1;fill_source_published=1;
    fill_valid=1;
    while(!fill_ready)tick();tick();
    if(fill_reject) $fatal(1,"legal fill rejected slot=%0d K=%0d rows=%0d",slot,kval,nrows);
    @(negedge clk);fill_valid=0;
    commit_numeric_identity=fill_numeric_identity;commit_quant_context=fill_quant_context;commit_a_ref=fill_a_ref;
  endtask
  task automatic half_commit(input int slot,input int row,input int group,input int half);
    @(negedge clk);commit_row=4'(row);commit_group=7'(group);commit_half=1'(half);
    commit_q=qgold(slot,row,group,half);commit_scale=half ? sgold(slot,row,group) : 0;commit_valid=1;
    while(!commit_ready)tick();tick();
    if(commit_error) $fatal(1,"legal commit rejected");
    @(negedge clk);commit_valid=0;
  endtask
  task automatic endrow(input int row,input int status,input int badcol);
    @(negedge clk);row_done_row=4'(row);row_done_status=2'(status);row_done_bad_col=16'(badcol);row_done_debt_zero=1;row_done_valid=1;
    tick();@(negedge clk);row_done_valid=0;
  endtask
  task automatic finish(input bit success);
    @(negedge clk);finish_debt_zero=0;finish_valid=1;repeat(7)tick();
    if(finish_ready || publish_valid) $fatal(1,"published before debt retirement");
    @(negedge clk);finish_debt_zero=1;tick();
    if(!fill_done || fill_error==success || publish_valid!=success) $fatal(1,"finish mismatch");
    @(negedge clk);finish_valid=0;
  endtask
  task automatic acquire(input int slot);
    @(negedge clk);acquire_slot=1'(slot);acquire_slot_epoch=fill_slot_epoch;
    acquire_K=fill_K;acquire_rows=fill_rows;acquire_numeric_identity=fill_numeric_identity;
    acquire_linear_context=fill_linear_context;acquire_a_ref=fill_a_ref;acquire_w_ref=fill_w_ref;acquire_dst_ref=fill_dst_ref;
    acquire_valid=1;tick();if(!acquire_done || acquire_error) $fatal(1,"acquire failed");
    @(negedge clk);acquire_valid=0;
    read_slot=1'(slot);read_slot_epoch=acquire_slot_epoch;read_numeric_identity=acquire_numeric_identity;
    read_linear_context=acquire_linear_context;read_a_ref=acquire_a_ref;
    release_slot=1'(slot);release_slot_epoch=acquire_slot_epoch;release_numeric_identity=acquire_numeric_identity;
    release_linear_context=acquire_linear_context;release_a_ref=acquire_a_ref;
  endtask
  task automatic checkread(input int slot,input int row,input int view,input int group,input int stalls);
    logic [3:0][255:0] saved_q;logic [3:0][15:0] saved_s;logic [671:0] saved_identity;
    @(negedge clk);read_row_block_base=4'(row);read_rows=3'(view);read_group=7'(group);read_valid=1;ret_ready=0;
    while(!read_ready)tick();tick();
    if(read_error) $fatal(1,"legal read rejected");
    @(negedge clk);read_valid=0;
    while(!ret_valid)tick();
    if(ret_slot!=slot || ret_row_block_base!=row || ret_rows!=view || ret_group!=group ||
      ret_slot_epoch!=read_slot_epoch || ret_numeric_identity!=read_numeric_identity || ret_linear_context!=read_linear_context || ret_a_ref!=read_a_ref)
      $fatal(1,"return handle mismatch");
    for(int rr=0;rr<4;rr++) begin
      if(rr<view) begin
        if(ret_q[rr]!=={qgold(slot,row+rr,group,1),qgold(slot,row+rr,group,0)} || ret_scale[rr]!==sgold(slot,row+rr,group))
          $fatal(1,"payload mismatch slot=%0d row=%0d group=%0d",slot,row+rr,group);
      end else if(ret_q[rr]!==0 || ret_scale[rr]!==0) $fatal(1,"inactive return lane");
    end
    saved_q=ret_q;saved_s=ret_scale;saved_identity=ret_numeric_identity;
    release_valid=1;
    repeat(stalls) begin
      tick();held=held+1;
      if(!ret_valid || ret_q!==saved_q || ret_scale!==saved_s || ret_numeric_identity!==saved_identity || release_ready || read_debt_zero)
        $fatal(1,"held return or early release");
    end
    @(negedge clk);release_valid=0;ret_ready=1;tick();
    @(negedge clk);ret_ready=0;checked=checked+view;if(dut.fill_active) overlap_reads=overlap_reads+1;
  endtask
  task automatic release_lease;
    @(negedge clk);release_valid=1;tick();
    if(!release_done || release_error || !read_debt_zero) $fatal(1,"release failed");
    @(negedge clk);release_valid=0;
  endtask
  initial begin
    rst_n=0;fill_valid=0;fill_owner_admitted=0;fill_source_published=0;fill_slot=0;fill_slot_epoch=0;fill_K=0;fill_rows=0;
    fill_numeric_identity=0;fill_producer_context=0;fill_quant_context=0;fill_linear_context=0;fill_source_ref=0;fill_a_ref=0;fill_w_ref=0;fill_dst_ref=0;
    commit_valid=0;commit_numeric_identity=0;commit_quant_context=0;commit_a_ref=0;commit_row=0;commit_group=0;commit_half=0;commit_q=0;commit_scale=0;
    row_done_valid=0;row_done_row=0;row_done_status=0;row_done_bad_col=0;row_done_debt_zero=0;finish_valid=0;finish_debt_zero=0;
    acquire_valid=0;acquire_slot=0;acquire_slot_epoch=0;acquire_K=0;acquire_rows=0;acquire_numeric_identity=0;acquire_linear_context=0;acquire_a_ref=0;acquire_w_ref=0;acquire_dst_ref=0;
    read_valid=0;read_slot=0;read_slot_epoch=0;read_numeric_identity=0;read_linear_context=0;read_a_ref=0;read_row_block_base=0;read_rows=0;read_group=0;ret_ready=0;
    release_valid=0;release_slot=0;release_slot_epoch=0;release_numeric_identity=0;release_linear_context=0;release_a_ref=0;
    repeat(4)tick();@(negedge clk);rst_n=1;
    // Every physical row and high group in the full-capacity slot is written.
    setup(0,1,4096,16);
    for(int row=0;row<16;row++) begin
      for(int g=0;g<128;g++) begin half_commit(0,row,g,0);half_commit(0,row,g,1);end
      endrow(row,0,0);
    end
    finish(1);if(physical_half_commits!=4096 || physical_scale_commits!=2048 || slot_rows_done[0]!=16'hffff) $fatal(1,"full coverage counters");
    acquire(0);
    // Slot 0 remains leased while the second full-capacity slot is filled.
    setup(1,1,4096,16);
    for(int row=0;row<16;row++) begin
      for(int g=0;g<128;g++) begin
        half_commit(1,row,g,0);half_commit(1,row,g,1);
        if(g==127)checkread(0,(row/4)*4,4,g,3);
      end
      endrow(row,0,0);
    end
    finish(1);release_lease();acquire(1);
    for(int row=0;row<16;row+=4) for(int g=0;g<128;g++) checkread(1,row,4,g,g==127 ? 11 : 0);
    // Full identity high-bit mismatch is rejected before any bank enable.
    @(negedge clk);read_numeric_identity[671]=~read_numeric_identity[671];read_valid=1;tick();
    if(!read_error || ret_valid || !read_debt_zero) $fatal(1,"wrong full identity admitted");
    @(negedge clk);read_valid=0;read_numeric_identity[671]=~read_numeric_identity[671];
    release_lease();
    setup(0,2,2624,4);
    for(int row=0;row<4;row++) begin
      for(int g=0;g<82;g++)begin half_commit(0,row,g,0);half_commit(0,row,g,1);end
      endrow(row,0,0);
    end
    finish(1);acquire(0);checkread(0,0,4,81,7);release_lease();
    // A final-element numerical error invalidates the whole newly filled task.
    setup(0,3,1024,1);
    for(int g=0;g<32;g++)begin half_commit(0,0,g,0);half_commit(0,0,g,1);end
    endrow(0,1,1023);finish(0);
    if(slot_state[0]!=4 || fill_bad_element!=1023) $fatal(1,"late error publication");
    setup(0,4,256,1);
    for(int g=0;g<8;g++)begin half_commit(0,0,g,0);half_commit(0,0,g,1);end
    endrow(0,0,0);finish(1);acquire(0);checkread(0,0,1,7,4);release_lease();
    // Reset cancels valid metadata and outstanding local RAM return, no payload reset.
    setup(0,5,1024,1);half_commit(0,0,0,0);
    @(negedge clk);rst_n=0;repeat(3)tick();@(negedge clk);rst_n=1;tick();
    if(slot_state!='0 || ret_valid || !read_debt_zero || publish_valid) $fatal(1,"reset cancel");
    setup(0,1,256,1);for(int g=0;g<8;g++)begin half_commit(0,0,g,0);half_commit(0,0,g,1);end
    endrow(0,0,0);finish(1);acquire(0);checkread(0,0,1,7,3);release_lease();
    $display("QUANT_DUAL_A_FULL_PASS capacity_bytes=139264 slots=2 rows=16 G128=1 checked_row_groups=%0d held=%0d overlap_reads=%0d late_error=1 full_identity=1 reset_recovery=1 cycles=%0d",checked,held,overlap_reads,cycles);
    $finish;
  end
endmodule
