`timescale 1ns/1ps
module laya_load_native_tb_v1;
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
  logic native_debt_zero,si_hold=0;
  logic [2:0] converted_rvalid;
  logic [511:0] held_wide_data;
  logic [12:0] clear_error;
  logic [12:0] selected_owner;
  logic [12:0] debt_zero;
  logic [12:0] protocol_error;
  logic [3:0] upstream_read_pending;
  logic [12:0][63:0] controller_araddr;
  logic [12:0][63:0] memory_araddr;
  logic [12:0] controller_arid;
  logic [12:0] memory_arid;
  logic [12:0][7:0] controller_arlen;
  logic [12:0][7:0] memory_arlen;
  logic [12:0][2:0] controller_arsize;
  logic [12:0][2:0] memory_arsize;
  logic [12:0][1:0] controller_arburst;
  logic [12:0][1:0] memory_arburst;
  logic [12:0][1:0] controller_arlock;
  logic [12:0][1:0] memory_arlock;
  logic [12:0][3:0] controller_arcache;
  logic [12:0][3:0] memory_arcache;
  logic [12:0][2:0] controller_arprot;
  logic [12:0][2:0] memory_arprot;
  logic [12:0][3:0] controller_arqos;
  logic [12:0][3:0] memory_arqos;
  logic [12:0][3:0] controller_arregion;
  logic [12:0][3:0] memory_arregion;
  logic [12:0] controller_aruser;
  logic [12:0] memory_aruser;
  logic [12:0] controller_arvalid;
  logic [12:0] memory_arvalid;
  logic [12:0] controller_arready;
  logic [12:0] memory_arready;
  logic [12:0][63:0] controller_awaddr;
  logic [12:0][63:0] memory_awaddr;
  logic [12:0] controller_awid;
  logic [12:0] memory_awid;
  logic [12:0][7:0] controller_awlen;
  logic [12:0][7:0] memory_awlen;
  logic [12:0][2:0] controller_awsize;
  logic [12:0][2:0] memory_awsize;
  logic [12:0][1:0] controller_awburst;
  logic [12:0][1:0] memory_awburst;
  logic [12:0][1:0] controller_awlock;
  logic [12:0][1:0] memory_awlock;
  logic [12:0][3:0] controller_awcache;
  logic [12:0][3:0] memory_awcache;
  logic [12:0][2:0] controller_awprot;
  logic [12:0][2:0] memory_awprot;
  logic [12:0][3:0] controller_awqos;
  logic [12:0][3:0] memory_awqos;
  logic [12:0][3:0] controller_awregion;
  logic [12:0][3:0] memory_awregion;
  logic [12:0] controller_awuser;
  logic [12:0] memory_awuser;
  logic [12:0] controller_awvalid;
  logic [12:0] memory_awvalid;
  logic [12:0] controller_awready;
  logic [12:0] memory_awready;
  logic [12:0][31:0] controller_wdata;
  logic [12:0][31:0] memory_wdata;
  logic [12:0][3:0] controller_wstrb;
  logic [12:0][3:0] memory_wstrb;
  logic [12:0] controller_wid;
  logic [12:0] memory_wid;
  logic [12:0] controller_wuser;
  logic [12:0] memory_wuser;
  logic [12:0] controller_wlast;
  logic [12:0] memory_wlast;
  logic [12:0] controller_wvalid;
  logic [12:0] memory_wvalid;
  logic [12:0] controller_wready;
  logic [12:0] memory_wready;
  logic [12:0][31:0] controller_rdata;
  logic [12:0][31:0] memory_rdata;
  logic [12:0][1:0] controller_rresp;
  logic [12:0][1:0] memory_rresp;
  logic [12:0] controller_rid;
  logic [12:0] memory_rid;
  logic [12:0] controller_ruser;
  logic [12:0] memory_ruser;
  logic [12:0] controller_rlast;
  logic [12:0] memory_rlast;
  logic [12:0] controller_rvalid;
  logic [12:0] memory_rvalid;
  logic [12:0] controller_rready;
  logic [12:0] memory_rready;
  logic [12:0][1:0] controller_bresp;
  logic [12:0][1:0] memory_bresp;
  logic [12:0] controller_bid;
  logic [12:0] memory_bid;
  logic [12:0] controller_buser;
  logic [12:0] memory_buser;
  logic [12:0] controller_bvalid;
  logic [12:0] memory_bvalid;
  logic [12:0] controller_bready;
  logic [12:0] memory_bready;
  logic [12:0][31:0] accepted_ar;
  logic [12:0][31:0] returned_r;
  logic [12:0][31:0] accepted_aw;
  logic [12:0][31:0] accepted_w;
  logic [12:0][31:0] returned_b;
  laya_load_axi_native_v1 native_adapter(
    .clk(clk),
    .rst_n(rst_n),
    .service_select((service_command_valid || dut.active) && !service_cancel),
    .clear_error(clear_error),
    .selected_owner(selected_owner),
    .debt_zero(debt_zero),
    .protocol_error(protocol_error),
    .physical_debt_zero(native_debt_zero),
    .upstream_read_pending(upstream_read_pending),
    .controller_araddr(controller_araddr),
    .memory_araddr(memory_araddr),
    .controller_arid(controller_arid),
    .memory_arid(memory_arid),
    .controller_arlen(controller_arlen),
    .memory_arlen(memory_arlen),
    .controller_arsize(controller_arsize),
    .memory_arsize(memory_arsize),
    .controller_arburst(controller_arburst),
    .memory_arburst(memory_arburst),
    .controller_arlock(controller_arlock),
    .memory_arlock(memory_arlock),
    .controller_arcache(controller_arcache),
    .memory_arcache(memory_arcache),
    .controller_arprot(controller_arprot),
    .memory_arprot(memory_arprot),
    .controller_arqos(controller_arqos),
    .memory_arqos(memory_arqos),
    .controller_arregion(controller_arregion),
    .memory_arregion(memory_arregion),
    .controller_aruser(controller_aruser),
    .memory_aruser(memory_aruser),
    .controller_arvalid(controller_arvalid),
    .memory_arvalid(memory_arvalid),
    .controller_arready(controller_arready),
    .memory_arready(memory_arready),
    .controller_awaddr(controller_awaddr),
    .memory_awaddr(memory_awaddr),
    .controller_awid(controller_awid),
    .memory_awid(memory_awid),
    .controller_awlen(controller_awlen),
    .memory_awlen(memory_awlen),
    .controller_awsize(controller_awsize),
    .memory_awsize(memory_awsize),
    .controller_awburst(controller_awburst),
    .memory_awburst(memory_awburst),
    .controller_awlock(controller_awlock),
    .memory_awlock(memory_awlock),
    .controller_awcache(controller_awcache),
    .memory_awcache(memory_awcache),
    .controller_awprot(controller_awprot),
    .memory_awprot(memory_awprot),
    .controller_awqos(controller_awqos),
    .memory_awqos(memory_awqos),
    .controller_awregion(controller_awregion),
    .memory_awregion(memory_awregion),
    .controller_awuser(controller_awuser),
    .memory_awuser(memory_awuser),
    .controller_awvalid(controller_awvalid),
    .memory_awvalid(memory_awvalid),
    .controller_awready(controller_awready),
    .memory_awready(memory_awready),
    .controller_wdata(controller_wdata),
    .memory_wdata(memory_wdata),
    .controller_wstrb(controller_wstrb),
    .memory_wstrb(memory_wstrb),
    .controller_wid(controller_wid),
    .memory_wid(memory_wid),
    .controller_wuser(controller_wuser),
    .memory_wuser(memory_wuser),
    .controller_wlast(controller_wlast),
    .memory_wlast(memory_wlast),
    .controller_wvalid(controller_wvalid),
    .memory_wvalid(memory_wvalid),
    .controller_wready(controller_wready),
    .memory_wready(memory_wready),
    .controller_rdata(controller_rdata),
    .memory_rdata(memory_rdata),
    .controller_rresp(controller_rresp),
    .memory_rresp(memory_rresp),
    .controller_rid(controller_rid),
    .memory_rid(memory_rid),
    .controller_ruser(controller_ruser),
    .memory_ruser(memory_ruser),
    .controller_rlast(controller_rlast),
    .memory_rlast(memory_rlast),
    .controller_rvalid(controller_rvalid),
    .memory_rvalid(memory_rvalid),
    .controller_rready(controller_rready),
    .memory_rready(memory_rready),
    .controller_bresp(controller_bresp),
    .memory_bresp(memory_bresp),
    .controller_bid(controller_bid),
    .memory_bid(memory_bid),
    .controller_buser(controller_buser),
    .memory_buser(memory_buser),
    .controller_bvalid(controller_bvalid),
    .memory_bvalid(memory_bvalid),
    .controller_bready(controller_bready),
    .memory_bready(memory_bready),
    .load_araddr(araddr),
    .load_arlen(arlen),
    .load_arsize(arsize),
    .load_arburst(arburst),
    .load_arvalid(arvalid),
    .load_arready(arready),
    .load_rdata(rdata),
    .load_rresp(rresp),
    .load_rlast(rlast),
    .load_rvalid(converted_rvalid),
    .load_rready(rready & {2'b11,!si_hold}),
    .aux_araddr(aux_araddr),
    .aux_arlen(aux_arlen),
    .aux_arsize(aux_arsize),
    .aux_arburst(aux_arburst),
    .aux_arvalid(aux_arvalid),
    .aux_arready(aux_arready),
    .aux_rdata(aux_rdata),
    .aux_rresp(aux_rresp),
    .aux_rlast(aux_rlast),
    .aux_rvalid(aux_rvalid),
    .aux_rready(aux_rready),
    .accepted_ar(accepted_ar),
    .returned_r(returned_r),
    .accepted_aw(accepted_aw),
    .accepted_w(accepted_w),
    .returned_b(returned_b)
  );
  assign rvalid=converted_rvalid & {2'b11,!si_hold};
  int held_buffer_cycles=0,narrow_aux_beats=0;
  logic [12:0] mi_reading=0;
  logic [12:0][63:0] mi_addr;
  int mi_index[13],mi_beats[13];
  logic mi_aux_tail[13];
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
  assign physical_debt_zero=!physical_hold && native_debt_zero;
  task automatic tick;@(posedge clk);#1;endtask
  function automatic logic [7:0] qbyte(input int address);
    return 8'(address*13+17);
  endfunction
  function automatic logic [127:0] aux_value(input int address);
    if(address==256)return {64'd0,32'hc0200000,32'h3fc00000};
    return 0;
  endfunction
  always_comb begin
    memory_arready=0;
    for(int bo=2;bo<=5;bo++)memory_arready[bo]=rst_n && !mi_reading[bo] &&
      !(bo==2 && q_ar_block) && cycles%7!=2;
    memory_awready=0;memory_wready=0;memory_bresp=0;
    memory_bid=0;memory_buser=0;memory_bvalid=0;
    reading=mi_reading[4:2];aux_reading=mi_reading[5];
  end
  always @(posedge clk)begin : peer
    int relative,word_byte;
    cycles++;
    if(cycles>30000)$fatal(1,"native LOAD cycle cap commands=%0d replies=%0d SIdebt=%b MIdebt=%b",commands,replies,upstream_read_pending,debt_zero);
    if(rst_n)begin
      for(int bo=2;bo<=5;bo++)begin
        if(memory_arvalid[bo] && memory_arready[bo])begin
          if(mi_reading[bo] || memory_arsize[bo]!=2 || memory_arburst[bo]!=1 ||
             memory_araddr[bo]<latched_bo_base[bo] || memory_araddr[bo][1:0]!=0 ||
             int'(memory_araddr[bo][11:0])+4*(int'(memory_arlen[bo])+1)>4096)
            $fatal(1,"native LOAD AR address/shape mismatch BO=%0d",bo);
          if(selected_owner[bo])begin
            if(memory_arid[bo]!=0 || memory_aruser[bo]!=0 || memory_arregion[bo]!=0 ||
               memory_arlock[bo]!=0 || memory_arcache[bo]!=3 || memory_arprot[bo]!=0 || memory_arqos[bo]!=0)
              $fatal(1,"native service AR sideband mismatch BO=%0d",bo);
          end else if(memory_arid[bo]!==controller_arid[bo] || memory_aruser[bo]!==controller_aruser[bo] ||
              memory_arregion[bo]!==controller_arregion[bo] || memory_arlock[bo]!==controller_arlock[bo] ||
              memory_arcache[bo]!==controller_arcache[bo] || memory_arprot[bo]!==controller_arprot[bo] ||
              memory_arqos[bo]!==controller_arqos[bo])$fatal(1,"controller sideband loss through native adapter");
          memory_rid[bo]<=memory_arid[bo];memory_ruser[bo]<=memory_aruser[bo];
          mi_reading[bo]<=1;mi_addr[bo]<=memory_araddr[bo];mi_index[bo]<=0;mi_beats[bo]<=int'(memory_arlen[bo])+1;
          mi_aux_tail[bo]<=bo==5 && memory_araddr[bo]-latched_bo_base[bo]==256;
          total_ar++;if(bo==2)q_ar++;if(bo==5)aux_ar++;
        end
        if(mi_reading[bo] && !memory_rvalid[bo] && cycles%3!=0 &&
           !(bo==2 && q_hold) && !(bo==5 && aux_hold))begin
          relative=int'(mi_addr[bo]-latched_bo_base[bo])+mi_index[bo]*4;
          for(int j=0;j<4;j++)begin
            word_byte=relative+j;
            if(bo==4)memory_rdata[bo][j*8+:8]<=word_byte%2==0 ? 8'h00 : 8'h3c;
            else if(bo==5)begin
              case(word_byte)
                256:memory_rdata[bo][j*8+:8]<=8'h00;
                257:memory_rdata[bo][j*8+:8]<=8'h00;
                258:memory_rdata[bo][j*8+:8]<=8'hc0;
                259:memory_rdata[bo][j*8+:8]<=8'h3f;
                260:memory_rdata[bo][j*8+:8]<=8'h00;
                261:memory_rdata[bo][j*8+:8]<=8'h00;
                262:memory_rdata[bo][j*8+:8]<=8'h20;
                263:memory_rdata[bo][j*8+:8]<=8'hc0;
                default:memory_rdata[bo][j*8+:8]<=0;
              endcase
            end else memory_rdata[bo][j*8+:8]<=qbyte(word_byte);
          end
          memory_rresp[bo]<=bo==5 && inject_aux_error ? 2 : 0;
          memory_rlast[bo]<=mi_index[bo]==mi_beats[bo]-1;memory_rvalid[bo]<=1;
        end
        if(memory_rvalid[bo] && memory_rready[bo])begin
          memory_rvalid[bo]<=0;mi_index[bo]<=mi_index[bo]+1;total_r++;
          if(bo==2)q_r++;
          if(bo==5)begin aux_r++;if(mi_aux_tail[bo])narrow_aux_beats++;end
          if(memory_rlast[bo])mi_reading[bo]<=0;
        end
        if(upstream_read_pending[bo-2] && !selected_owner[bo])
          $fatal(1,"native owner handed off with SI response debt BO=%0d",bo);
        if(upstream_read_pending[bo-2] && debt_zero[bo] && !mi_reading[bo])held_buffer_cycles++;
        if(protocol_error[bo])$fatal(1,"native arbiter protocol error BO=%0d",bo);
        if(controller_arready[bo] || controller_rvalid[bo] || controller_bvalid[bo])begin
          if(selected_owner[bo])$fatal(1,"inactive controller leaked handshake/response BO=%0d",bo);
        end
      end
      if(service_completion_valid && !native_debt_zero)$fatal(1,"LOAD completed with converter debt");
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
    packet[MODEL_IDENTITY*8+576+:64]=1;packet[K*8+:16]=256;packet[N*8+:16]=2;packet[ROWS*8+:8]=1;
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
    controller_araddr=0;
    controller_arid=0;
    controller_arlen=0;
    controller_arsize=0;
    controller_arburst=0;
    controller_arlock=0;
    controller_arcache=0;
    controller_arprot=0;
    controller_arqos=0;
    controller_arregion=0;
    controller_aruser=0;
    controller_arvalid=0;
    controller_awaddr=0;
    controller_awid=0;
    controller_awlen=0;
    controller_awsize=0;
    controller_awburst=0;
    controller_awlock=0;
    controller_awcache=0;
    controller_awprot=0;
    controller_awqos=0;
    controller_awregion=0;
    controller_awuser=0;
    controller_awvalid=0;
    controller_wdata=0;
    controller_wstrb=0;
    controller_wid=0;
    controller_wuser=0;
    controller_wlast=0;
    controller_wvalid=0;
    controller_rready=0;
    controller_bready=0;
    clear_error=0;memory_rdata=0;memory_rresp=0;memory_rlast=0;memory_rvalid=0;memory_rid=0;memory_ruser=0;
    for(int bo=0;bo<13;bo++)begin mi_index[bo]=0;mi_beats[bo]=0;mi_aux_tail[bo]=0;end
    rst_n=0;
    service_cancel=0;
    service_command_valid=0;
    service_command=0;
    service_completion_ready=0;
    latched_bo_base=0;
    latched_bo_span=0;
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
    q_ar_block=1;prepare(3,3);submit();wait(memory_arvalid[2]);repeat(2)tick();@(negedge clk);service_cancel=1;
    repeat(8)begin tick();if(!memory_arvalid[2] || service_completion_valid)$fatal(1,"offered LOAD AR withdrawn on cancel");end
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
    // FIFO_MODE0 has a cut-through final MI word: holding the actual final
    // converted SI response also holds that real MI LAST. Both debts survive
    // a request to return ownership to the controller.
    prepare(10,12);submit();wait(converted_rvalid[0] && rlast[0]);
    @(negedge clk);si_hold=1;service_cancel=1;#1;held_wide_data=rdata[0];
    repeat(12)begin tick();
      if(!selected_owner[2] || !upstream_read_pending[0] || service_completion_valid ||
         !converted_rvalid[0] || !rlast[0] || rdata[0]!==held_wide_data)
        $fatal(1,"final buffered SI R debt lost across native owner cancel");
    end
    if(debt_zero[2] || !memory_rvalid[2] || !memory_rlast[2] || memory_rready[2])
      $fatal(1,"cut-through final MI LAST was lost while SI tail was held");
    @(negedge clk);si_hold=0;completion(7,4,10);
    prepare(11,13);submit();completion(0,2,11);check_stripe(11);
    // Real controller-side ownership is available again after cancellation
    // and recovery; all original native fields survive the shared adapter.
    wait(!selected_owner[2]);@(negedge clk);
    controller_araddr[2]=latched_bo_base[2]+64;controller_arlen[2]=0;
    controller_arsize[2]=2;controller_arburst[2]=1;controller_arid[2]=1;
    controller_aruser[2]=1;controller_arlock[2]=2;controller_arcache[2]=10;
    controller_arprot[2]=6;controller_arqos[2]=7;controller_arregion[2]=9;
    controller_arvalid[2]=1;
    do @(posedge clk);while(!controller_arready[2]);
    @(negedge clk);controller_arvalid[2]=0;wait(controller_rvalid[2]);#1;
    for(int j=0;j<4;j++)if(controller_rdata[2][j*8+:8]!==qbyte(64+j))$fatal(1,"controller recovery read byte");
    repeat(8)begin tick();
      if(!controller_rvalid[2] || !controller_rlast[2] || controller_rresp[2]!=0 ||
         !controller_rid[2] || !controller_ruser[2] || selected_owner[2] || native_debt_zero)
        $fatal(1,"controller recovery held return identity/owner/debt");
    end
    @(negedge clk);controller_rready[2]=1;tick();@(negedge clk);controller_rready[2]=0;repeat(3)tick();
    if(held_buffer_cycles==0 || narrow_aux_beats<2)$fatal(1,"native converter debt/narrow AUX coverage missing");
    if(commands!=13 || replies!=13 || slot_readers[0]!=0 || !physical_debt_zero)$fatal(1,"LOAD portal coverage counts");
    $display("FULL_CURRENT_LOAD_NATIVE_PASS converters=4 physical_BO=13 narrow_aux8B=1 SI_MI_debt=1 controller_recovery=1 commands=%0d replies=%0d cancel_cases=6 AUX_error=1 overflow_reject=2 recoveries=3 external_debt_barrier=1 pending_cancel_ready=1 actual_q_AR=%0d actual_q_R=%0d actual_aux_AR=%0d actual_aux_R=%0d independent_q_scale_nonzero_bias=2 full_capacity_cache=1 cycles=%0d",commands,replies,q_ar,q_r,aux_ar,aux_r,cycles);$finish;
  end
endmodule
