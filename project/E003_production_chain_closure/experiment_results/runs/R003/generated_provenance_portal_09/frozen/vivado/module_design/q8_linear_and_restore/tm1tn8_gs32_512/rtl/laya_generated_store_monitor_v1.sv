`timescale 1ns/1ps
// One protected generated AXI512 write port.  AW and W are captured before a
// single-beat transaction is forwarded, so address, WSTRB coverage and replay
// are checked before any downstream handshake.  Bursts are drained locally as
// failures until a bounded burst buffer is added; this keeps the production
// boundary safe while the first ordinary rows16 owner is integrated.
module laya_generated_store_monitor_v1 #(
  parameter int MONITORED_ROLE=6,
  parameter int MAX_TRACKED_BYTES=16*5248*4
) (
  input  logic clk,rst_n,cancel,
  input  logic begin_valid,
  output logic begin_ready,
  input  logic begin_block,
  input  logic [8191:0] candidate_packet,
  input  logic [8191:0] begin_packet,
  input  logic [63:0] bo_base,
  input  logic end_commit,
  input  logic adapter_pending_zero,
  output logic begin_supported,
  output logic scope_active,
  output logic physical_drained,
  output logic coverage_complete,
  output logic [15:0] physical_status,
  output logic [31:0] physical_error_detail,
  output logic [63:0] physical_bad_element,
  output logic [63:0] observed_store_bytes0,
  output logic [63:0] observed_store_bytes1,
  output logic [31:0] forwarded_aw,forwarded_w,retired_b,
  output logic [31:0] rejected_transactions,

  input  logic [63:0] s_axi_awaddr,
  input  logic [7:0] s_axi_awlen,
  input  logic [2:0] s_axi_awsize,
  input  logic [1:0] s_axi_awburst,
  input  logic s_axi_awvalid,
  output logic s_axi_awready,
  input  logic [511:0] s_axi_wdata,
  input  logic [63:0] s_axi_wstrb,
  input  logic s_axi_wlast,
  input  logic s_axi_wvalid,
  output logic s_axi_wready,
  output logic [1:0] s_axi_bresp,
  output logic s_axi_bvalid,
  input  logic s_axi_bready,

  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input  logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast,
  output logic m_axi_wvalid,
  input  logic m_axi_wready,
  input  logic [1:0] m_axi_bresp,
  input  logic m_axi_bvalid,
  output logic m_axi_bready
);
  import laya_generated_provenance_layout_v1::*;

  logic cfg_used[0:1];
  logic [63:0] cfg_first[0:1],cfg_row_step[0:1],cfg_repeat_step[0:1];
  logic [31:0] cfg_segment[0:1];
  logic [15:0] cfg_rows[0:1],cfg_repeats[0:1];
  logic [63:0] cfg_total[0:1];
  logic [MAX_TRACKED_BYTES-1:0] coverage0,coverage1;
  logic [63:0] unique_bytes0,unique_bytes1;

  logic aw_hold_valid,w_hold_valid,legal_active,aw_sent,w_sent,waiting_b;
  logic local_b_valid,local_drain_active;
  logic [8:0] local_drain_remaining;
  logic [63:0] aw_hold_addr;
  logic [7:0] aw_hold_len;
  logic [2:0] aw_hold_size;
  logic [1:0] aw_hold_burst;
  logic [511:0] w_hold_data;
  logic [63:0] w_hold_strb;
  logic w_hold_last;
  logic beat_illegal;
  logic [6:0] beat_bytes0,beat_bytes1;
  logic [15:0] beat_error_status;
  logic [31:0] beat_error_detail;
  logic bus_idle;

  function automatic logic descriptor_candidate_ok(
      input logic [8191:0] packet,input integer descriptor_index);
    logic [1023:0] descriptor;
    logic [511:0] geometry;
    logic [64:0] after;
    descriptor=packet[(DESCRIPTOR0+descriptor_index*128)*8+:1024];
    geometry=packet[(GEOMETRY0+descriptor_index*64)*8+:512];
    after={1'b0,bo_base}+{1'b0,geometry[0+:64]}+
          {1'b0,geometry[32*8+:64]};
    return descriptor[28*8+:8]==MONITORED_ROLE &&
      geometry[32*8+:64]!=0 && geometry[32*8+:64]<=MAX_TRACKED_BYTES &&
      after[64]==0;
  endfunction

  always_comb begin : candidate_check
    integer count,matching;
    count=candidate_packet[DESCRIPTOR_COUNT*8+:8];matching=0;
    begin_supported=count==1;
    for(int d=0;d<2;d++)begin
      if(d<count && candidate_packet[(DESCRIPTOR0+d*128+28)*8+:8]==MONITORED_ROLE)begin
        matching=matching+1;
        begin_supported=begin_supported && descriptor_candidate_ok(candidate_packet,d);
      end
    end
    begin_supported=begin_supported && matching==count && matching!=0;
  end

  function automatic integer byte_descriptor(input logic [63:0] address);
    integer matches,selected;
    logic [64:0] first,after,value;
    matches=0;selected=-1;value={1'b0,address};
    for(int d=0;d<2;d++)if(cfg_used[d])
      for(int repeat_index=0;repeat_index<cfg_repeats[d];repeat_index++)
        for(int row=0;row<cfg_rows[d];row++)begin
          first={1'b0,cfg_first[d]}+
            65'(repeat_index)*{1'b0,cfg_repeat_step[d]}+
            65'(row)*{1'b0,cfg_row_step[d]};
          after=first+cfg_segment[d];
          if(value>=first && value<after)begin
            matches=matches+1;selected=d;
          end
        end
    return matches==1 ? selected : -1;
  endfunction

  function automatic integer byte_index(input integer descriptor_index,
                                          input logic [63:0] address);
    integer selected;
    logic [64:0] first,after,value;
    selected=-1;value={1'b0,address};
    for(int repeat_index=0;repeat_index<cfg_repeats[descriptor_index];repeat_index++)
      for(int row=0;row<cfg_rows[descriptor_index];row++)begin
        first={1'b0,cfg_first[descriptor_index]}+
          65'(repeat_index)*{1'b0,cfg_repeat_step[descriptor_index]}+
          65'(row)*{1'b0,cfg_row_step[descriptor_index]};
        after=first+cfg_segment[descriptor_index];
        if(value>=first && value<after)
          selected=(repeat_index*cfg_rows[descriptor_index]+row)*
            cfg_segment[descriptor_index]+(value-first);
      end
    return selected;
  endfunction

  always_comb begin : analyse_beat
    integer descriptor_index,linear_index,sole_descriptor;
    logic [63:0] address;
    sole_descriptor=cfg_used[0] && !cfg_used[1] ? 0 :
                    cfg_used[1] && !cfg_used[0] ? 1 : -1;
    beat_illegal=aw_hold_len!=0 || aw_hold_size!=3'd6 ||
                 aw_hold_burst!=2'b01 || aw_hold_addr[5:0]!=0 ||
                 !w_hold_last;
    beat_bytes0=0;beat_bytes1=0;
    beat_error_status=beat_illegal ? E_PROTOCOL : 0;
    beat_error_detail=beat_illegal ? 32'h04000017 : 0;
    for(int lane=0;lane<64;lane++)if(w_hold_strb[lane])begin
      address=aw_hold_addr+lane;
      descriptor_index=byte_descriptor(address);
      if(descriptor_index<0)begin
        beat_illegal=1;beat_error_status=E_BUFFER;
        beat_error_detail=32'h04000008;
        if(sole_descriptor==0)beat_bytes0=beat_bytes0+1'b1;
        if(sole_descriptor==1)beat_bytes1=beat_bytes1+1'b1;
      end else begin
        linear_index=byte_index(descriptor_index,address);
        if(descriptor_index==0)begin
          beat_bytes0=beat_bytes0+1'b1;
          if(linear_index<0 || linear_index>=MAX_TRACKED_BYTES ||
             coverage0[linear_index])begin
            beat_illegal=1;beat_error_status=E_PROTOCOL;
            beat_error_detail=32'h04000017;
          end
        end else begin
          beat_bytes1=beat_bytes1+1'b1;
          if(linear_index<0 || linear_index>=MAX_TRACKED_BYTES ||
             coverage1[linear_index])begin
            beat_illegal=1;beat_error_status=E_PROTOCOL;
            beat_error_detail=32'h04000017;
          end
        end
      end
    end
  end

  assign bus_idle=!aw_hold_valid && !w_hold_valid && !legal_active &&
                  !waiting_b && !local_b_valid && !local_drain_active;
  assign begin_ready=!scope_active && bus_idle && adapter_pending_zero;
  assign physical_drained=bus_idle && adapter_pending_zero;
  assign coverage_complete=scope_active && physical_status==0 &&
      (!cfg_used[0] || unique_bytes0==cfg_total[0]) &&
      (!cfg_used[1] || unique_bytes1==cfg_total[1]);

  assign s_axi_awready=!begin_block && !aw_hold_valid && !legal_active &&
      !waiting_b && !local_b_valid && (!cancel || w_hold_valid);
  assign s_axi_wready=local_drain_active ? !local_b_valid :
      (!begin_block && !w_hold_valid && !legal_active && !waiting_b &&
       !local_b_valid && (!cancel || aw_hold_valid));
  assign m_axi_awaddr=aw_hold_addr;
  assign m_axi_awlen=aw_hold_len;
  assign m_axi_awsize=aw_hold_size;
  assign m_axi_awburst=aw_hold_burst;
  assign m_axi_awvalid=legal_active && !aw_sent;
  assign m_axi_wdata=w_hold_data;
  assign m_axi_wstrb=w_hold_strb;
  assign m_axi_wlast=w_hold_last;
  assign m_axi_wvalid=legal_active && !w_sent;
  assign s_axi_bvalid=local_b_valid || (waiting_b && m_axi_bvalid);
  assign s_axi_bresp=local_b_valid ? 2'b11 : m_axi_bresp;
  assign m_axi_bready=waiting_b && !local_b_valid && s_axi_bready;

  task automatic record_error(input logic [15:0] status,
                              input logic [31:0] detail);
    if(physical_status==0)begin
      physical_status<=status;physical_error_detail<=detail;
      physical_bad_element<=64'hffffffffffffffff;
    end
  endtask

  always_ff @(posedge clk)begin : monitor_state
    integer descriptor_index,linear_index;
    logic aw_handshake,w_handshake;
    logic [6:0] drain_bytes;
    if(!rst_n)begin
      scope_active<=0;physical_status<=0;physical_error_detail<=0;
      physical_bad_element<=64'hffffffffffffffff;
      observed_store_bytes0<=0;observed_store_bytes1<=0;
      unique_bytes0<=0;unique_bytes1<=0;coverage0<='0;coverage1<='0;
      cfg_used[0]<=0;cfg_used[1]<=0;
      for(int d=0;d<2;d++)begin
        cfg_first[d]<=0;cfg_segment[d]<=0;cfg_rows[d]<=0;
        cfg_repeats[d]<=0;cfg_row_step[d]<=0;cfg_repeat_step[d]<=0;
        cfg_total[d]<=0;
      end
      aw_hold_valid<=0;w_hold_valid<=0;legal_active<=0;
      aw_sent<=0;w_sent<=0;waiting_b<=0;local_b_valid<=0;
      local_drain_active<=0;local_drain_remaining<=0;
      aw_hold_addr<=0;aw_hold_len<=0;aw_hold_size<=0;aw_hold_burst<=0;
      w_hold_data<=0;w_hold_strb<=0;w_hold_last<=0;
      forwarded_aw<=0;forwarded_w<=0;retired_b<=0;
      rejected_transactions<=0;
    end else begin
      if(begin_valid && begin_ready)begin
        scope_active<=1;physical_status<=0;physical_error_detail<=0;
        physical_bad_element<=64'hffffffffffffffff;
        observed_store_bytes0<=0;observed_store_bytes1<=0;
        unique_bytes0<=0;unique_bytes1<=0;coverage0<='0;coverage1<='0;
        for(int d=0;d<2;d++)begin
          cfg_used[d]<=d<begin_packet[DESCRIPTOR_COUNT*8+:8] &&
            begin_packet[(DESCRIPTOR0+d*128+28)*8+:8]==MONITORED_ROLE;
          cfg_first[d]<=bo_base+
            begin_packet[(GEOMETRY0+d*64)*8+:64];
          cfg_segment[d]<=begin_packet[(GEOMETRY0+d*64+8)*8+:32];
          cfg_rows[d]<=begin_packet[(GEOMETRY0+d*64+12)*8+:16];
          cfg_repeats[d]<=begin_packet[(GEOMETRY0+d*64+14)*8+:16];
          cfg_row_step[d]<=begin_packet[(GEOMETRY0+d*64+16)*8+:64];
          cfg_repeat_step[d]<=begin_packet[(GEOMETRY0+d*64+24)*8+:64];
          cfg_total[d]<=begin_packet[(GEOMETRY0+d*64+32)*8+:64];
        end
      end else if(begin_valid)begin
        scope_active<=0;record_error(E_PROTOCOL,32'h04000017);
      end

      if(end_commit)begin
        scope_active<=0;cfg_used[0]<=0;cfg_used[1]<=0;
      end

      if(s_axi_awvalid && s_axi_awready)begin
        aw_hold_valid<=1;aw_hold_addr<=s_axi_awaddr;
        aw_hold_len<=s_axi_awlen;aw_hold_size<=s_axi_awsize;
        aw_hold_burst<=s_axi_awburst;
      end
      if(s_axi_wvalid && s_axi_wready && !local_drain_active)begin
        w_hold_valid<=1;w_hold_data<=s_axi_wdata;
        w_hold_strb<=s_axi_wstrb;w_hold_last<=s_axi_wlast;
      end

      if(local_drain_active && s_axi_wvalid && s_axi_wready)begin
        drain_bytes=0;
        for(int lane=0;lane<64;lane++)
          if(s_axi_wstrb[lane])drain_bytes=drain_bytes+1'b1;
        observed_store_bytes0<=observed_store_bytes0+drain_bytes;
        if(local_drain_remaining==1)begin
          if(!s_axi_wlast)record_error(E_PROTOCOL,32'h04000017);
          local_drain_active<=0;local_drain_remaining<=0;
          local_b_valid<=1;
        end else begin
          if(s_axi_wlast)record_error(E_PROTOCOL,32'h04000017);
          local_drain_remaining<=local_drain_remaining-1'b1;
        end
      end

      if(aw_hold_valid && w_hold_valid && !legal_active &&
         !local_b_valid && !waiting_b)begin
        if(!scope_active || beat_illegal)begin
          rejected_transactions<=rejected_transactions+1'b1;
          observed_store_bytes0<=observed_store_bytes0+beat_bytes0;
          observed_store_bytes1<=observed_store_bytes1+beat_bytes1;
          record_error(!scope_active?E_PROTOCOL:beat_error_status,
                       !scope_active?32'h04000017:beat_error_detail);
          if(aw_hold_len!=0 && !w_hold_last)begin
            local_drain_active<=1;
            local_drain_remaining<={1'b0,aw_hold_len};
          end else local_b_valid<=1;
        end else begin
          legal_active<=1;aw_sent<=0;w_sent<=0;
        end
      end

      aw_handshake=m_axi_awvalid && m_axi_awready;
      w_handshake=m_axi_wvalid && m_axi_wready;
      if(aw_handshake)begin aw_sent<=1;forwarded_aw<=forwarded_aw+1'b1;end
      if(w_handshake)begin
        w_sent<=1;forwarded_w<=forwarded_w+1'b1;
        observed_store_bytes0<=observed_store_bytes0+beat_bytes0;
        observed_store_bytes1<=observed_store_bytes1+beat_bytes1;
        unique_bytes0<=unique_bytes0+beat_bytes0;
        unique_bytes1<=unique_bytes1+beat_bytes1;
        for(int lane=0;lane<64;lane++)if(w_hold_strb[lane])begin
          descriptor_index=byte_descriptor(aw_hold_addr+lane);
          if(descriptor_index>=0)begin
            linear_index=byte_index(descriptor_index,aw_hold_addr+lane);
            if(descriptor_index==0)coverage0[linear_index]<=1;
            else coverage1[linear_index]<=1;
          end
        end
      end
      if(legal_active && (aw_sent || aw_handshake) &&
         (w_sent || w_handshake))begin
        legal_active<=0;waiting_b<=1;
      end
      if(waiting_b && m_axi_bvalid && m_axi_bready)begin
        if(m_axi_bresp!=0)record_error(E_BUFFER,32'h04000008);
        retired_b<=retired_b+1'b1;waiting_b<=0;
        aw_hold_valid<=0;w_hold_valid<=0;aw_sent<=0;w_sent<=0;
      end
      if(local_b_valid && s_axi_bready)begin
        retired_b<=retired_b+1'b1;local_b_valid<=0;
        local_drain_active<=0;local_drain_remaining<=0;
        aw_hold_valid<=0;w_hold_valid<=0;aw_sent<=0;w_sent<=0;
      end
    end
  end
endmodule
