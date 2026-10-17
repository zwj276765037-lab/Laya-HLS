`timescale 1ns/1ps
module laya_load_portal_tb_v1;
  import laya_compute_portal_layout_v1::*;
  logic clk;
  logic rst_n;
  logic service_cancel;
  logic service_command_valid;
  logic service_command_ready;
  logic [8191:0] service_command;
  logic service_completion_valid;
  logic service_completion_ready;
  logic [4095:0] service_completion;
  logic physical_debt_zero;
  logic [12:0][63:0] latched_bo_base;
  logic [12:0][63:0] latched_bo_span;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch;
  logic [1:0][31:0] slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst;
  logic [2:0] arvalid;
  logic [2:0] arready;
  logic [2:0][511:0] rdata;
  logic [2:0][1:0] rresp;
  logic [2:0] rlast;
  logic [2:0] rvalid;
  logic [2:0] rready;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst;
  logic aux_arvalid;
  logic aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast;
  logic aux_rvalid;
  logic aux_rready;
  logic lease_valid;
  logic lease_ready;
  logic lease_done;
  logic lease_error;
  logic lease_slot;
  logic [31:0] lease_epoch;
  logic [31:0] lease_k;
  logic [31:0] lease_n;
  logic [15:0] lease_weight_key;
  logic [3327:0] lease_model_identity;
  logic [671:0] lease_numeric_identity;
  logic [95:0] lease_task_context;
  logic read_valid;
  logic read_ready;
  logic read_error;
  logic read_slot;
  logic [31:0] read_epoch;
  logic [15:0] read_tile;
  logic [7:0] read_group;
  logic read_pair;
  logic [3327:0] read_model_identity;
  logic [671:0] read_numeric_identity;
  logic [95:0] read_task_context;
  logic ret_valid;
  logic ret_ready;
  logic ret_slot;
  logic ret_pair;
  logic [31:0] ret_epoch;
  logic [15:0] ret_tile;
  logic [7:0] ret_group;
  logic [3327:0] ret_model_identity;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_task_context;
  logic [1:0][7:0][255:0] ret_q;
  logic [1:0][7:0][15:0] ret_scale;
  logic [1:0][7:0][31:0] ret_bias;
  logic [1:0][7:0] ret_mask;
  logic release_valid;
  logic release_ready;
  logic release_done;
  logic release_error;
  logic release_slot;
  logic [31:0] release_epoch;
  logic [671:0] release_numeric_identity;
  logic [95:0] release_task_context;
  laya_load_portal_binding_v1 dut(
    .clk,
    .rst_n,
    .service_cancel,
    .service_command_valid,
    .service_command_ready,
    .service_command,
    .service_completion_valid,
    .service_completion_ready,
    .service_completion,
    .physical_debt_zero,
    .latched_bo_base,
    .latched_bo_span,
    .slot_state,
    .slot_epoch,
    .slot_readers,
    .slot_coverage,
    .araddr,
    .arlen,
    .arsize,
    .arburst,
    .arvalid,
    .arready,
    .rdata,
    .rresp,
    .rlast,
    .rvalid,
    .rready,
    .aux_araddr,
    .aux_arlen,
    .aux_arsize,
    .aux_arburst,
    .aux_arvalid,
    .aux_arready,
    .aux_rdata,
    .aux_rresp,
    .aux_rlast,
    .aux_rvalid,
    .aux_rready,
    .lease_valid,
    .lease_ready,
    .lease_done,
    .lease_error,
    .lease_slot,
    .lease_epoch,
    .lease_k,
    .lease_n,
    .lease_weight_key,
    .lease_model_identity,
    .lease_numeric_identity,
    .lease_task_context,
    .read_valid,
    .read_ready,
    .read_error,
    .read_slot,
    .read_epoch,
    .read_tile,
    .read_group,
    .read_pair,
    .read_model_identity,
    .read_numeric_identity,
    .read_task_context,
    .ret_valid,
    .ret_ready,
    .ret_slot,
    .ret_pair,
    .ret_epoch,
    .ret_tile,
    .ret_group,
    .ret_model_identity,
    .ret_numeric_identity,
    .ret_task_context,
    .ret_q,
    .ret_scale,
    .ret_bias,
    .ret_mask,
    .release_valid,
    .release_ready,
    .release_done,
    .release_error,
    .release_slot,
    .release_epoch,
    .release_numeric_identity,
    .release_task_context
  );
  initial clk=0;always #5 clk=~clk;
  int cycles=0,commands=0,replies=0,total_ar=0,total_r=0;
  logic [2:0] reading=0;
  logic [2:0][63:0] saved_addr;
  int read_index[3],read_beats[3];
  logic aux_reading=0,aux_hold=0,q_hold=0,q_ar_block=0;
  logic [63:0] aux_addr;
  int aux_index=0,aux_beats=0;
  logic [2:0] aux_size;
  int q_ar=0,q_r=0,aux_ar=0,aux_r=0;
  logic inject_aux_error=0,physical_hold=0;
  logic [8191:0] packet;
  logic [4095:0] captured;
  assign arready=rst_n ? {2'b11,!q_ar_block} : 0;
  assign aux_arready=rst_n && !aux_reading;
  assign physical_debt_zero=!physical_hold && reading==0 && !aux_reading && rvalid==0 && !aux_rvalid && arvalid==0 && !aux_arvalid;
  task automatic tick;@(posedge clk);#1;endtask
  function automatic logic [7:0] qbyte(input int address);
    return 8'(address*13+17);
  endfunction
  function automatic logic [127:0] aux_value(input int address);
    if(address==256)return {64'd0,32'hc0200000,32'h3fc00000};
    return 0;
  endfunction
  always @(posedge clk)begin : peer
    int relative;
    cycles++;if(cycles>30000)$fatal(1,"LOAD portal cycle cap commands=%0d replies=%0d busy=%0d cache_fill=%0d",commands,replies,dut.active,dut.cache.fill_busy);
    if(rst_n)begin
      for(int p=0;p<3;p++)begin
        if(arvalid[p] && arready[p])begin
          if(reading[p] || arsize[p]!=6 || arburst[p]!=1 || araddr[p]<latched_bo_base[p+2] ||
             araddr[p][5:0]!=0 || int'(araddr[p][11:0])+64*(int'(arlen[p])+1)>4096)$fatal(1,"LOAD actual AR");
          reading[p]<=1;saved_addr[p]<=araddr[p];read_index[p]<=0;read_beats[p]<=int'(arlen[p])+1;
          total_ar++;if(p==0)q_ar++;
        end
        if(reading[p] && !rvalid[p] && cycles%3!=0 && !(p==0 && q_hold))begin
          relative=int'(saved_addr[p]-latched_bo_base[p+2])+read_index[p]*64;
          if(p==2)for(int lane=0;lane<32;lane++)rdata[p][lane*16+:16]<=16'h3c00;
          else for(int j=0;j<64;j++)rdata[p][j*8+:8]<=qbyte(relative+j);
          rresp[p]<=0;rlast[p]<=read_index[p]==read_beats[p]-1;rvalid[p]<=1;
        end
        if(rvalid[p] && rready[p])begin
          rvalid[p]<=0;read_index[p]<=read_index[p]+1;total_r++;if(p==0)q_r++;
          if(rlast[p])reading[p]<=0;
        end
      end
      if(aux_arvalid && aux_arready)begin
        if(aux_arsize!=4 && aux_arsize!=3)$fatal(1,"AUX actual size");
        aux_reading<=1;aux_addr<=aux_araddr;aux_index<=0;aux_beats<=int'(aux_arlen)+1;aux_size<=aux_arsize;aux_ar++;
      end
      if(aux_reading && !aux_rvalid && cycles%4!=1 && !aux_hold)begin
        relative=int'(aux_addr-latched_bo_base[5])+(aux_index<<aux_size);
        aux_rdata<=aux_value(relative);aux_rresp<=inject_aux_error ? 2 : 0;
        aux_rlast<=aux_index==aux_beats-1;aux_rvalid<=1;
      end
      if(aux_rvalid && aux_rready)begin
        aux_rvalid<=0;aux_index<=aux_index+1;aux_r++;
        if(aux_rlast)aux_reading<=0;
      end
      if(service_completion_valid && !physical_debt_zero)$fatal(1,"LOAD completion before physical retirement");
      if(service_command_valid && service_command_ready)commands++;
      if(service_completion_valid && service_completion_ready)replies++;
    end
  end
  task automatic prepare(input int epoch,input int command_id);
    packet=0;packet[0+:32]=CMD_MAGIC;packet[VER*8+:16]=VERSION;packet[OP_STATUS*8+:16]=1;
    packet[GENERATION*8+:64]=64'(command_id);packet[TASK*8+:32]=32'(command_id);
    packet[COMMAND_BEATS*8+:16]=16;packet[RESPONSE_BEATS*8+:16]=8;
    packet[IDENTITY*8+:64]=1;packet[(IDENTITY+8)*8+:64]=1;packet[(IDENTITY+16)*8+:16]=1;packet[(IDENTITY+18)*8+:16]=128;
    packet[CONTEXT*8+:32]=32'(command_id);packet[(CONTEXT+4)*8+:8]=8'h80;
    packet[(CONTEXT+5)*8+:8]=6;packet[(CONTEXT+6)*8+:8]=255;packet[(CONTEXT+8)*8+:8]=2;packet[(CONTEXT+11)*8+:8]=1;
    packet[W_REF*8+:32]=32'(epoch);packet[(W_REF+4)*8+:8]=8'h23;
    packet[MODEL_IDENTITY*8+576+:64]=1;packet[K*8+:16]=256;packet[N*8+:16]=2;
    packet[W_EPOCH*8+:32]=32'(epoch);packet[WEIGHT_KEY*8+:16]=16'hff0a;packet[BIAS_KIND*8+:8]=1;
    packet[(WEIGHT_RANGES+8)*8+:64]=2048;packet[(WEIGHT_RANGES+40)*8+:64]=128;
    packet[BIAS_OFFSET*8+:64]=256;packet[BIAS_BYTES*8+:32]=8;
  endtask
  task automatic submit;
    @(negedge clk);service_command=packet;service_command_valid=1;
    do @(posedge clk);while(!service_command_ready);
    @(negedge clk);service_command_valid=0;
  endtask
  task automatic completion(input int status,input int state,input int epoch);
    wait(service_completion_valid);#1;captured=service_completion;
    if(!response_binding_ok(captured,packet) || captured[OP_STATUS*8+:16]!=status ||
      slot_state[0]!=state || slot_epoch[0]!=epoch || !physical_debt_zero)$fatal(1,"LOAD response/status/cache owner status=%0d expected=%0d state=%0d expected=%0d",captured[OP_STATUS*8+:16],status,slot_state[0],state);
    repeat(8)begin tick();if(!service_completion_valid || service_completion!==captured)$fatal(1,"LOAD response changed under backpressure");end
    @(negedge clk);service_completion_ready=1;tick();@(negedge clk);service_completion_ready=0;service_cancel=0;repeat(3)tick();
  endtask
  task automatic check_stripe(input int epoch);
    @(negedge clk);lease_valid=1;lease_slot=0;lease_epoch=32'(epoch);lease_k=256;lease_n=2;
    lease_weight_key=16'hff0a;lease_model_identity=packet[MODEL_IDENTITY*8+:3328];lease_numeric_identity=packet[IDENTITY*8+:672];
    lease_task_context=96'h01000000ff063700000063;
    do @(posedge clk);while(!lease_ready);
    #1;if(!lease_done || lease_error)$fatal(1,"actual W lease failed");@(negedge clk);lease_valid=0;
    read_valid=1;read_slot=0;read_epoch=32'(epoch);read_tile=0;read_group=3;read_pair=0;
    read_model_identity=lease_model_identity;read_numeric_identity=lease_numeric_identity;read_task_context=lease_task_context;
    do @(posedge clk);while(!read_ready);
    @(negedge clk);read_valid=0;wait(ret_valid);#1;
    if(ret_epoch!=epoch || ret_group!=3 || ret_mask[0]!=8'h03 || ret_bias[0][0]!=32'h3fc00000 || ret_bias[0][1]!=32'hc0200000)$fatal(1,"actual stripe metadata/bias");
    for(int lane=0;lane<8;lane++)begin
      if(ret_scale[0][lane]!=16'h3c00)$fatal(1,"actual stripe scale");
      for(int k=0;k<32;k++)if(ret_q[0][lane][k*8+:8]!==qbyte(3*256+lane*32+k))$fatal(1,"actual stripe q lane=%0d k=%0d",lane,k);
    end
    repeat(5)tick();@(negedge clk);ret_ready=1;tick();@(negedge clk);ret_ready=0;
    release_valid=1;release_slot=0;release_epoch=32'(epoch);release_numeric_identity=lease_numeric_identity;release_task_context=lease_task_context;
    do @(posedge clk);while(!release_ready);
    #1;if(!release_done || release_error)$fatal(1,"actual W release failed");@(negedge clk);release_valid=0;repeat(3)tick();
  endtask
  initial begin
    rst_n=0;
    service_cancel=0;
    service_command_valid=0;
    service_command=0;
    service_completion_ready=0;
    latched_bo_base=0;
    latched_bo_span=0;
    rdata=0;
    rresp=0;
    rlast=0;
    rvalid=0;
    aux_rdata=0;
    aux_rresp=0;
    aux_rlast=0;
    aux_rvalid=0;
    lease_valid=0;
    lease_slot=0;
    lease_epoch=0;
    lease_k=0;
    lease_n=0;
    lease_weight_key=0;
    lease_model_identity=0;
    lease_numeric_identity=0;
    lease_task_context=0;
    read_valid=0;
    read_slot=0;
    read_epoch=0;
    read_tile=0;
    read_group=0;
    read_pair=0;
    read_model_identity=0;
    read_numeric_identity=0;
    read_task_context=0;
    ret_ready=0;
    release_valid=0;
    release_slot=0;
    release_epoch=0;
    release_numeric_identity=0;
    release_task_context=0;
    for(int bo=0;bo<13;bo++)begin latched_bo_base[bo]=64'h100000000+64'(bo*65536);latched_bo_span[bo]=65536;end
    for(int p=0;p<3;p++)begin read_index[p]=0;read_beats[p]=0;end
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    prepare(1,1);submit();completion(0,2,1);
    if(captured[ELEMENTS*8+:32]!=2176 || captured[UNIT*8+:8]!=3 || !captured[RETIRE_FLAGS*8+1] ||
       slot_coverage[0][0]!=2048 || slot_coverage[0][2]!=128 || slot_coverage[0][3]!=8)$fatal(1,"normal complete LOAD coverage");
    check_stripe(1);
    // Cancel after a real AR, before any q return. Its debt must survive.
    q_hold=1;prepare(2,2);submit();wait(reading[0]);@(negedge clk);service_cancel=1;
    repeat(15)begin tick();if(service_completion_valid || !reading[0] || slot_epoch[0]!=2)$fatal(1,"accepted q AR cancel lost debt");end
    @(negedge clk);q_hold=0;completion(7,4,2);
    // Offered AR is stable until actual acceptance, even across cancel.
    q_ar_block=1;prepare(3,3);submit();wait(arvalid[0]);repeat(2)tick();@(negedge clk);service_cancel=1;
    repeat(8)begin tick();if(!arvalid[0] || service_completion_valid)$fatal(1,"offered LOAD AR withdrawn on cancel");end
    @(negedge clk);q_ar_block=0;completion(7,4,3);
    // AUX returns are also non-cancellable physical debt.
    aux_hold=1;prepare(4,4);submit();wait(aux_reading);@(negedge clk);service_cancel=1;
    repeat(12)begin tick();if(service_completion_valid || !aux_reading)$fatal(1,"accepted AUX AR cancel lost debt");end
    @(negedge clk);aux_hold=0;completion(7,4,4);
    // Real response error drains the complete accepted burst, invalidates W.
    inject_aux_error=1;prepare(5,5);submit();completion(7,4,5);inject_aux_error=0;
    // Reject u65 overflow before claims or reads; prior high-water is intact.
    prepare(6,6);packet[WEIGHT_RANGES*8+:64]=64'hffffffffffffffc0;submit();completion(5,4,5);
    prepare(6,7);submit();completion(0,2,6);check_stripe(6);
    // A BO snapshot whose full span wraps is rejected before cache claims,
    // even when this command's smaller addressed range itself would fit.
    @(negedge clk);latched_bo_base[2]=64'hffffffffffff0000;latched_bo_span[2]=131072;
    prepare(7,8);submit();completion(5,2,6);
    @(negedge clk);latched_bo_base[2]=64'h100020000;latched_bo_span[2]=65536;
    // Cancel coincident with cache load_done, before the binding latches it.
    prepare(7,9);submit();wait(dut.load_done);@(negedge clk);service_cancel=1;
    tick();@(negedge clk);service_cancel=0;completion(7,4,7);
    // A previously offered success is cancelled with READY also asserted.
    // No success may retire before the physical slot becomes INVALID.
    prepare(8,10);submit();wait(service_completion_valid);repeat(4)tick();
    @(negedge clk);service_cancel=1;service_completion_ready=1;#1;
    if(service_completion_valid)$fatal(1,"pending success retired on cancel edge");
    tick();@(negedge clk);service_completion_ready=0;
    if(!service_completion_valid || service_completion[OP_STATUS*8+:16]!=7 || slot_state[0]!=4)
      $fatal(1,"pending LOAD cancel did not invalidate before response");
    completion(7,4,8);
    // The caller's external physical ledger remains a retirement barrier.
    prepare(9,11);submit();@(negedge clk);physical_hold=1;wait(dut.response_pending);
    repeat(10)begin tick();if(service_completion_valid)$fatal(1,"external physical debt ignored");end
    @(negedge clk);physical_hold=0;completion(0,2,9);check_stripe(9);
    if(commands!=11 || replies!=11 || slot_readers[0]!=0 || !physical_debt_zero)$fatal(1,"LOAD portal coverage counts");
    $display("FULL_CURRENT_LOAD_PORTAL_PASS commands=%0d replies=%0d cancel_cases=5 AUX_error=1 overflow_reject=2 recoveries=2 external_debt_barrier=1 pending_cancel_ready=1 actual_q_AR=%0d actual_q_R=%0d actual_aux_AR=%0d actual_aux_R=%0d independent_q_scale_nonzero_bias=2 full_capacity_cache=1 cycles=%0d",commands,replies,q_ar,q_r,aux_ar,aux_r,cycles);$finish;
  end
endmodule
