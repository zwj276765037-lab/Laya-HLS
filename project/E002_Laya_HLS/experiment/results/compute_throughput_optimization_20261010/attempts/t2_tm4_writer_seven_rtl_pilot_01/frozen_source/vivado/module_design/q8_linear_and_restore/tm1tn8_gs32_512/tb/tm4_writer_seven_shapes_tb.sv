`timescale 1ns/1ps
module tm4_writer_seven_shapes_tb;
  logic clk=0,rst_n=0;
  always #5 clk=~clk;
  logic [1:0] cfg_valid=0,cfg_ready,packet_valid=0,packet_ready,flush_valid=0,flush_ready,flush_done,debt_zero,coverage_complete,fault;
  logic cfg_owner_admitted=1,cfg_target_invalidated=0,command_retire=0;
  logic [15:0] cfg_K,cfg_N,cfg_row0;
  logic [2:0] cfg_rows;
  logic [7:0] cfg_batch,cfg_op,cfg_G_count;
  logic [9:0] cfg_T_count;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_linear_context;
  logic [63:0] cfg_source_ref,cfg_a_ref,cfg_w_ref,cfg_ps_ref,cfg_dst_ref;
  logic [3327:0] cfg_w_model_identity;
  logic [1:0][63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span;
  logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes;
  logic [1:0][415:0] packet_data;
  wire [1:0][15:0] status;
  wire [1:0][31:0] aw_count,w_count,b_count,accepted_elements;
  wire [1:0][63:0] useful_bytes,physical_bytes,first_error_rank,first_bad_element;
  wire [1:0][63:0] awaddr,wstrb;
  wire [1:0][7:0] awlen;
  wire [1:0][2:0] awsize;
  wire [1:0][1:0] awburst;
  wire [1:0] awvalid,wlast,wvalid,bready;
  logic [1:0] awready,wready,bvalid=0;
  logic [1:0][1:0] bresp=0;
  wire [1:0][511:0] wdata;
  logic [1:0] have_aw=0,have_w=0,processed=0;
  logic [1:0][63:0] held_addr,held_strb;
  logic [1:0][511:0] held_data;
  integer response_delay[0:1];
  integer seen[0:20991];
  integer cycle=0,shape=0,epoch=0,checked=0,beats=0,held_b_cycles=0;
  integer inject_b_error=0;
  logic [1:0] last_aw_stall=0,last_w_stall=0;
  logic [1:0][63:0] previous_awaddr,previous_wstrb;
  logic [1:0][511:0] previous_wdata;
  function automatic logic [31:0] value(input integer n,input integer row);
    return 32'h3f000000 ^ 32'(n) ^ (32'(row)<<20) ^ (32'(shape)<<24);
  endfunction
  for(genvar s=0;s<2;s++) begin : writers
    tm4tn8_axi512_writer_v1 #(.SHARD(s)) dut(
      .clk,.rst_n,.cfg_valid(cfg_valid[s]),.cfg_ready(cfg_ready[s]),.cfg_owner_admitted,.cfg_target_invalidated,
      .cfg_K,.cfg_N,.cfg_row0,.cfg_rows,.cfg_batch,.cfg_op,.cfg_G_count,.cfg_T_count,
      .cfg_numeric_identity,.cfg_linear_context,.cfg_source_ref,.cfg_a_ref,.cfg_w_ref,.cfg_ps_ref,.cfg_dst_ref,.cfg_w_model_identity,
      .cfg_bo_base,.cfg_bo_span,.cfg_region_base,.cfg_region_span,.cfg_row_stride_bytes,.cfg_batch_stride_bytes,
      .packet_valid(packet_valid[s]),.packet_ready(packet_ready[s]),.packet_data(packet_data[s]),
      .flush_valid(flush_valid[s]),.flush_ready(flush_ready[s]),.flush_done(flush_done[s]),.debt_zero(debt_zero[s]),.coverage_complete(coverage_complete[s]),
      .command_retire,.fault(fault[s]),.status(status[s]),.first_error_rank(first_error_rank[s]),.first_bad_element(first_bad_element[s]),
      .aw_count(aw_count[s]),.w_count(w_count[s]),.b_count(b_count[s]),.accepted_elements(accepted_elements[s]),.useful_bytes(useful_bytes[s]),.physical_bytes(physical_bytes[s]),
      .m_axi_awaddr(awaddr[s]),.m_axi_awlen(awlen[s]),.m_axi_awsize(awsize[s]),.m_axi_awburst(awburst[s]),.m_axi_awvalid(awvalid[s]),.m_axi_awready(awready[s]),
      .m_axi_wdata(wdata[s]),.m_axi_wstrb(wstrb[s]),.m_axi_wlast(wlast[s]),.m_axi_wvalid(wvalid[s]),.m_axi_wready(wready[s]),
      .m_axi_bresp(bresp[s]),.m_axi_bvalid(bvalid[s]),.m_axi_bready(bready[s]));
  end
  always_comb begin
    for(int s=0;s<2;s++) begin awready[s]=!have_aw[s] && cycle%3!=0;wready[s]=!have_w[s] && cycle%5!=0;end
  end
  always @(posedge clk) begin : endpoint
    longint unsigned word,relative,global_row,batch_index,n;
    integer local_row,index,plane,head,d;
    cycle<=cycle+1;
    if(!rst_n) begin have_aw<=0;have_w<=0;processed<=0;bvalid<=0;last_aw_stall<=0;last_w_stall<=0;end
    else for(integer s=0;s<2;s++) begin
      if(last_aw_stall[s] && (!awvalid[s] || awaddr[s]!==previous_awaddr[s])) $fatal(1,"AW changed under stall");
      if(last_w_stall[s] && (!wvalid[s] || wdata[s]!==previous_wdata[s] || wstrb[s]!==previous_wstrb[s])) $fatal(1,"W changed under stall");
      last_aw_stall[s]<=awvalid[s] && !awready[s];last_w_stall[s]<=wvalid[s] && !wready[s];
      previous_awaddr[s]<=awaddr[s];previous_wdata[s]<=wdata[s];previous_wstrb[s]<=wstrb[s];
      if(awvalid[s] && awready[s]) begin
        if(awlen[s]!=0 || awsize[s]!=6 || awburst[s]!=1 || awaddr[s][5:0]!=0 || awaddr[s]<cfg_bo_base[s] || awaddr[s]+64>cfg_bo_base[s]+cfg_bo_span[s]) $fatal(1,"AW physical BO bounds");
        have_aw[s]<=1;held_addr[s]<=awaddr[s];
      end
      if(wvalid[s] && wready[s]) begin if(!wlast[s]) $fatal(1,"missing WLAST");have_w[s]<=1;held_data[s]<=wdata[s];held_strb[s]<=wstrb[s];end
      if(have_aw[s] && have_w[s] && !processed[s]) begin
        processed[s]<=1;response_delay[s]<=15+(cycle%7);beats=beats+1;
        for(integer lane=0;lane<16;lane++) begin
          if(held_strb[s][lane*4 +:4]!=0 && held_strb[s][lane*4 +:4]!=15) $fatal(1,"partial F32 strobe");
          if(held_strb[s][lane*4 +:4]==15) begin
            relative=held_addr[s]+lane*4-cfg_region_base[s];word=relative/4;
            if(held_addr[s]+lane*4<cfg_region_base[s] || held_addr[s]+lane*4+4>cfg_region_base[s]+cfg_region_span[s]) $fatal(1,"logical bounds");
            if(cfg_op==8'h30) begin
              d=word%64;global_row=(word/64)%1024;head=((word/(64*1024))%8)*2+s;
              batch_index=(word/(64*1024*8))%2;plane=word/(64*1024*8*2);n=plane*1024+head*64+d;
            end else begin
              batch_index=relative/cfg_batch_stride_bytes;relative=relative%cfg_batch_stride_bytes;
              global_row=relative/cfg_row_stride_bytes;n=(relative%cfg_row_stride_bytes)/4;
            end
            local_row=global_row-cfg_row0;index=local_row*5248+n;
            if(batch_index!=cfg_batch || global_row<cfg_row0 || local_row>=cfg_rows || n>=cfg_N || index<0 || index>=20992) $fatal(1,"address decode shape=%0d shard=%0d addr=%h row=%0d n=%0d batch=%0d",shape,s,held_addr[s]+lane*4,global_row,n,batch_index);
            if(seen[index]!=0 || held_data[s][lane*32 +:32]!==value(n,local_row)) $fatal(1,"duplicate or payload mismatch shape=%0d row=%0d n=%0d",shape,local_row,n);
            seen[index]=1;checked=checked+1;
          end
        end
      end
      if(processed[s] && !bvalid[s]) begin
        if(response_delay[s]>0) response_delay[s]<=response_delay[s]-1;
        else begin bvalid[s]<=1;bresp[s]<=inject_b_error ? 2 : 0;inject_b_error=0;end
      end
      if(processed[s] && response_delay[s]>0) held_b_cycles=held_b_cycles+1;
      if(bvalid[s] && bready[s]) begin bvalid[s]<=0;have_aw[s]<=0;have_w[s]<=0;processed[s]<=0;end
    end
    if(cycle>40000000) $fatal(1,"cycle protection");
  end
  task automatic configure(input integer k,input integer n,input integer opcode,input integer rr,input integer r0);
    begin
      epoch=epoch+1;cfg_K=k;cfg_N=n;cfg_op=opcode;cfg_rows=rr;cfg_row0=r0;cfg_batch=1;cfg_G_count=k/32;cfg_T_count=(n+7)/8;
      cfg_numeric_identity='h1;cfg_numeric_identity[143:128]=2;cfg_numeric_identity[159:144]=128;
      cfg_linear_context=0;cfg_linear_context[31:0]=epoch;cfg_linear_context[39:32]=opcode;cfg_linear_context[63:56]=1;
      cfg_linear_context[71:64]=opcode==8'h36 ? 1 : opcode==8'h37 ? 2 : 0;cfg_linear_context[87:72]=r0;cfg_linear_context[95:88]=rr;
      cfg_source_ref=64'h0000000700000000|64'(epoch);cfg_a_ref=64'h0000002200000000|64'(epoch);cfg_w_ref=64'h0000002300000000|64'(epoch);cfg_ps_ref=64'h0000002400000000|64'(epoch);
      cfg_dst_ref=(opcode==8'h30 ? 64'h0000000500000000 : opcode==8'h32 ? 64'h0000000600000000 : opcode==8'h34 ? 64'h0000000900000000 : opcode==8'h36 ? 64'h0000000a00000000 : opcode==8'h37 ? 64'h0004000a00000000 : 64'h0000000300000000)|64'(epoch);
      cfg_w_model_identity='h1;cfg_w_model_identity[3327]=1;
      cfg_row_stride_bytes=opcode==8'h32 ? 20992 : opcode==8'h34 ? 16384 : opcode==8'h37 ? 8 : 4096;
      cfg_batch_stride_bytes=cfg_row_stride_bytes*(opcode==8'h36 ? 16 : opcode==8'h37 ? 1 : 1024);
      for(integer s=0;s<2;s++) begin
        cfg_bo_base[s]=64'h100000000+s*64'h4000000;cfg_region_base[s]=cfg_bo_base[s]+64;
        cfg_region_span[s]=opcode==8'h30 ? 3*2*8*1024*64*4 : 2*cfg_batch_stride_bytes;cfg_bo_span[s]=cfg_region_span[s]+128;
      end
      for(integer i=0;i<20992;i++) seen[i]=0;checked=0;
      @(negedge clk);cfg_valid=opcode==8'h30 ? 3 : 1;
      while((cfg_ready & cfg_valid)!=cfg_valid) @(negedge clk);
      @(negedge clk);cfg_valid=0;
      if(fault[0] || (opcode==8'h30 && fault[1])) $fatal(1,"configuration rejected shape=%0d",shape);
    end
  endtask
  task automatic send_packet(input integer tile,input integer row,input bit wrong_tag);
    integer shard;
    logic [415:0] payload;
    begin
      shard=cfg_op==8'h30 ? (tile/8)%2 : 0;payload=0;
      payload[415:288]={cfg_dst_ref[31:0],cfg_w_ref[31:0],cfg_a_ref[31:0],cfg_linear_context[31:0]};
      if(wrong_tag) payload[415]=~payload[415];
      for(integer lane=0;lane<8;lane++) payload[lane*32 +:32]=value(tile*8+lane,row);
      payload[268:256]=tile*8;payload[270:269]=row;payload[278:271]=cfg_N==2 ? 3 : 255;
      payload[279]=tile==cfg_T_count-1 && row==cfg_rows-1;
      @(negedge clk);packet_data[shard]=payload;packet_valid[shard]=1;
      while(!packet_ready[shard]) @(negedge clk);
      @(negedge clk);packet_valid[shard]=0;
    end
  endtask
  task automatic finish_command(input bit expect_error);
    logic [1:0] used;
    begin
      used=cfg_op==8'h30 ? 3 : 1;
      @(negedge clk);flush_valid=used & flush_ready;
      @(negedge clk);flush_valid=0;
      while((debt_zero & used)!=used) @(negedge clk);
      repeat(3) @(negedge clk);
      if(expect_error) begin if((fault & used)==0) $fatal(1,"expected fault");end
      else begin
        if((fault & used)!=0 || (coverage_complete & used)!=used || checked!=cfg_N*cfg_rows) $fatal(1,"coverage/fault shape=%0d checked=%0d expected=%0d fault=%b",shape,checked,cfg_N*cfg_rows,fault);
        for(integer row=0;row<cfg_rows;row++) for(integer n=0;n<cfg_N;n++) if(seen[row*5248+n]!=1) $fatal(1,"missing row=%0d n=%0d",row,n);
        for(integer s=0;s<2;s++) if(used[s] && (aw_count[s]!=w_count[s] || w_count[s]!=b_count[s] || useful_bytes[s]!=64'(cfg_N)*cfg_rows*4/(cfg_op==8'h30 ? 2 : 1))) $fatal(1,"AXI debts/counts");
      end
      cfg_target_invalidated=expect_error;command_retire=1;
      @(negedge clk);command_retire=0;cfg_target_invalidated=0;
    end
  endtask
  initial begin
    repeat(5) @(negedge clk);rst_n=1;
    for(shape=0;shape<7;shape++) begin
      case(shape)
        0: configure(1024,3072,8'h30,4,124);
        1: configure(1024,1024,8'h31,4,124);
        2: configure(1024,5248,8'h32,4,124);
        3: configure(1024,4096,8'h34,4,124);
        4: configure(2624,1024,8'h33,4,124);
        5: configure(4096,1024,8'h35,4,124);
        6: configure(256,2,8'h37,1,0);
      endcase
      for(integer tile=0;tile<cfg_T_count;tile++) for(integer row=0;row<cfg_rows;row++) send_packet(tile,row,0);
      finish_command(0);
      $display("TM4_WRITER_SHAPE_PASS shape=%0d K=%0d N=%0d rows=%0d checked=%0d",shape,cfg_K,cfg_N,cfg_rows,checked);
    end
    shape=7;configure(1024,1024,8'h36,4,12);
    for(integer tile=0;tile<cfg_T_count;tile++) for(integer row=0;row<4;row++) send_packet(tile,row,0);
    finish_command(0);
    shape=8;configure(256,2,8'h37,1,0);send_packet(0,0,1);finish_command(1);
    if(aw_count[0]!=0 || w_count[0]!=0) $fatal(1,"wrong tag caused write");
    shape=9;configure(256,2,8'h37,1,0);inject_b_error=1;send_packet(0,0,0);finish_command(1);
    shape=10;configure(256,2,8'h37,1,0);send_packet(0,0,0);finish_command(0);
    $display("TM4_WRITER_SEVEN_SHAPES_PASS shapes=7 layouts=8 rows4=1 Wi_last_n=5247 G128=1 scorer_row15=1 ACT_mask03=1 wrong_tag_no_write=1 BRESP_new_epoch_recovery=1 held_b_cycles=%0d beats=%0d cycles=%0d",held_b_cycles,beats,cycle);
    $finish;
  end
endmodule
