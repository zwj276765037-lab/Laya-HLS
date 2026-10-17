`timescale 1ns/1ps
// One protected generated AXI512 write port.  At most one burst is active.
// The monitor accepts a first W beat before AW, validates an INCR burst against
// the bound descriptor, tracks every asserted WSTRB byte, and holds the real B
// response until local protocol drain and the external adapter fence complete.
// If a later beat fails after AW has reached the peer, that beat and all
// remaining peer beats use zero WSTRB so the real burst can retire without an
// unauthorized write.  The first local error remains sticky for END.
module laya_generated_store_monitor_v1 #(
  parameter int MONITORED_ROLE=6,
  parameter int MAX_TRACKED_BYTES=16*5248*4,
  parameter int MAX_BURST_BEATS=64
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

  logic aw_hold_valid,w_hold_valid;
  logic [63:0] aw_hold_addr;
  logic [7:0] aw_hold_len;
  logic [2:0] aw_hold_size;
  logic [1:0] aw_hold_burst;
  logic [511:0] w_hold_data;
  logic [63:0] w_hold_strb;
  logic w_hold_last;

  logic txn_active,txn_forward,aw_sent,txn_error,txn_rejected;
  logic auto_zero_active,drain_extra_active,waiting_b;
  logic downstream_b_seen,upstream_b_valid;
  logic [1:0] downstream_bresp,upstream_bresp;
  logic [8:0] beats_total,beat_index;

  logic burst_header_illegal;
  logic [15:0] burst_header_status;
  logic [31:0] burst_header_detail;
  logic beat_illegal,beat_expected_last;
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
    integer match_count,selected;
    logic [64:0] first,after,value,repeat_base;
    logic [15:0] row_cursor,repeat_cursor;
    match_count=0;selected=-1;value={1'b0,address};
    for(int d=0;d<2;d++)begin
      repeat_base={1'b0,cfg_first[d]};first=repeat_base;
      row_cursor=0;repeat_cursor=0;
      // Accepted BEGIN geometry contains at most 32 intervals per descriptor.
      for(int k=0;k<32;k++)begin
        if(cfg_used[d] && repeat_cursor<cfg_repeats[d] &&
           row_cursor<cfg_rows[d])begin
          after=first+cfg_segment[d];
          if(value>=first && value<after)begin
            match_count=match_count+1;selected=d;
          end
          if(row_cursor+1<cfg_rows[d])begin
            row_cursor=row_cursor+1'b1;
            first=first+{1'b0,cfg_row_step[d]};
          end else begin
            row_cursor=0;
            repeat_cursor=repeat_cursor+1'b1;
            repeat_base=repeat_base+{1'b0,cfg_repeat_step[d]};
            first=repeat_base;
          end
        end
      end
    end
    return match_count==1 ? selected : -1;
  endfunction

  function automatic integer byte_index(input integer descriptor_index,
                                          input logic [63:0] address);
    integer selected;
    logic [64:0] first,after,value,repeat_base;
    logic [15:0] row_cursor,repeat_cursor;
    integer entry_index;
    selected=-1;value={1'b0,address};
    repeat_base={1'b0,cfg_first[descriptor_index]};first=repeat_base;
    row_cursor=0;repeat_cursor=0;entry_index=0;
    for(int k=0;k<32;k++)begin
      if(repeat_cursor<cfg_repeats[descriptor_index] &&
         row_cursor<cfg_rows[descriptor_index])begin
        after=first+cfg_segment[descriptor_index];
        if(value>=first && value<after)
          selected=entry_index*cfg_segment[descriptor_index]+(value-first);
        entry_index=entry_index+1;
        if(row_cursor+1<cfg_rows[descriptor_index])begin
          row_cursor=row_cursor+1'b1;
          first=first+{1'b0,cfg_row_step[descriptor_index]};
        end else begin
          row_cursor=0;
          repeat_cursor=repeat_cursor+1'b1;
          repeat_base=repeat_base+{1'b0,cfg_repeat_step[descriptor_index]};
          first=repeat_base;
        end
      end
    end
    return selected;
  endfunction

  always_comb begin : analyse_header
    logic [64:0] span,after,last_address;
    integer first_descriptor,last_descriptor;
    span=({57'd0,aw_hold_len}+65'd1)<<6;
    after={1'b0,aw_hold_addr}+span;
    last_address=after-1'b1;
    first_descriptor=-1;last_descriptor=-1;
    burst_header_illegal=!scope_active || aw_hold_len>=MAX_BURST_BEATS ||
      aw_hold_size!=3'd6 || aw_hold_burst!=2'b01 || aw_hold_addr[5:0]!=0 ||
      after[64] || ({53'd0,aw_hold_addr[11:0]}+span)>65'd4096;
    burst_header_status=E_PROTOCOL;
    burst_header_detail=32'h04000017;
    if(!burst_header_illegal)begin
      first_descriptor=byte_descriptor(aw_hold_addr);
      last_descriptor=byte_descriptor(last_address[63:0]);
      if(first_descriptor<0 || last_descriptor<0 ||
         first_descriptor!=last_descriptor)begin
        burst_header_illegal=1;
        burst_header_status=E_BUFFER;
        burst_header_detail=32'h04000008;
      end
    end
  end

  always_comb begin : analyse_beat
    integer descriptor_index,linear_index,sole_descriptor;
    logic [63:0] address,beat_base;
    sole_descriptor=cfg_used[0] && !cfg_used[1] ? 0 :
                    cfg_used[1] && !cfg_used[0] ? 1 : -1;
    beat_expected_last=beats_total!=0 && beat_index+1'b1==beats_total;
    beat_illegal=w_hold_last!=beat_expected_last;
    beat_bytes0=0;beat_bytes1=0;
    beat_error_status=beat_illegal ? E_PROTOCOL : 0;
    beat_error_detail=beat_illegal ? 32'h04000017 : 0;
    beat_base=aw_hold_addr+(64'(beat_index)<<6);
    for(int lane=0;lane<64;lane++)if(w_hold_strb[lane])begin
      address=beat_base+lane;
      descriptor_index=byte_descriptor(address);
      if(descriptor_index<0)begin
        if(!beat_illegal)begin
          beat_illegal=1;beat_error_status=E_BUFFER;
          beat_error_detail=32'h04000008;
        end
        if(sole_descriptor==0)beat_bytes0=beat_bytes0+1'b1;
        if(sole_descriptor==1)beat_bytes1=beat_bytes1+1'b1;
      end else begin
        linear_index=byte_index(descriptor_index,address);
        if(descriptor_index==0)begin
          beat_bytes0=beat_bytes0+1'b1;
          if((linear_index<0 || linear_index>=MAX_TRACKED_BYTES ||
              coverage0[linear_index]) && !beat_illegal)begin
            beat_illegal=1;beat_error_status=E_PROTOCOL;
            beat_error_detail=32'h04000017;
          end
        end else begin
          beat_bytes1=beat_bytes1+1'b1;
          if((linear_index<0 || linear_index>=MAX_TRACKED_BYTES ||
              coverage1[linear_index]) && !beat_illegal)begin
            beat_illegal=1;beat_error_status=E_PROTOCOL;
            beat_error_detail=32'h04000017;
          end
        end
      end
    end
  end

  assign bus_idle=!aw_hold_valid && !w_hold_valid && !txn_active &&
                  !upstream_b_valid && !waiting_b && !downstream_b_seen;
  assign begin_ready=!scope_active && bus_idle && adapter_pending_zero;
  assign physical_drained=bus_idle && adapter_pending_zero;
  assign coverage_complete=scope_active && physical_status==0 &&
      (!cfg_used[0] || unique_bytes0==cfg_total[0]) &&
      (!cfg_used[1] || unique_bytes1==cfg_total[1]);

  // Cancellation blocks a new producer.  An admitted producer retains its AW,
  // W, B and matching END/fence path until the old scope is safely closed.
  assign s_axi_awready=!begin_block && !aw_hold_valid && !txn_active &&
      !upstream_b_valid && (!cancel || scope_active || w_hold_valid);
  assign s_axi_wready=!begin_block && !w_hold_valid && !upstream_b_valid &&
      ((!txn_active && !aw_hold_valid) ||
       (!txn_active && aw_hold_valid) ||
       (txn_active && !auto_zero_active &&
        (drain_extra_active || beat_index<beats_total))) &&
      (!cancel || scope_active || aw_hold_valid || txn_active);

  assign m_axi_awaddr=aw_hold_addr;
  assign m_axi_awlen=aw_hold_len;
  assign m_axi_awsize=aw_hold_size;
  assign m_axi_awburst=aw_hold_burst;
  assign m_axi_awvalid=txn_active && txn_forward && !aw_sent;
  assign m_axi_wdata=auto_zero_active ? 512'd0 : w_hold_data;
  assign m_axi_wstrb=auto_zero_active || txn_error || beat_illegal ? 64'd0 :
                     w_hold_strb;
  assign m_axi_wlast=beat_expected_last;
  assign m_axi_wvalid=txn_active && txn_forward && aw_sent &&
      beat_index<beats_total && (auto_zero_active || w_hold_valid);
  assign m_axi_bready=txn_active && txn_forward && waiting_b &&
                      !downstream_b_seen;
  assign s_axi_bvalid=upstream_b_valid;
  assign s_axi_bresp=upstream_bresp;

  task automatic record_error(input logic [15:0] status,
                              input logic [31:0] detail);
    if(physical_status==0)begin
      physical_status<=status;physical_error_detail<=detail;
      physical_bad_element<=64'hffffffffffffffff;
    end
  endtask

  always_ff @(posedge clk)begin : monitor_state
    integer descriptor_index,linear_index;
    logic [6:0] drain_bytes;
    logic [63:0] beat_base;
    logic downstream_b_handshake;
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
      aw_hold_valid<=0;w_hold_valid<=0;
      aw_hold_addr<=0;aw_hold_len<=0;aw_hold_size<=0;aw_hold_burst<=0;
      w_hold_data<=0;w_hold_strb<=0;w_hold_last<=0;
      txn_active<=0;txn_forward<=0;aw_sent<=0;
      txn_error<=0;txn_rejected<=0;auto_zero_active<=0;
      drain_extra_active<=0;waiting_b<=0;downstream_b_seen<=0;
      downstream_bresp<=0;upstream_b_valid<=0;upstream_bresp<=0;
      beats_total<=0;beat_index<=0;
      forwarded_aw<=0;forwarded_w<=0;retired_b<=0;
      rejected_transactions<=0;
    end else begin
      downstream_b_handshake=m_axi_bvalid && m_axi_bready;

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
      if(s_axi_wvalid && s_axi_wready)begin
        w_hold_valid<=1;w_hold_data<=s_axi_wdata;
        w_hold_strb<=s_axi_wstrb;w_hold_last<=s_axi_wlast;
      end

      if(aw_hold_valid && !txn_active && !upstream_b_valid)begin
        txn_active<=1;txn_forward<=!burst_header_illegal;
        aw_sent<=0;txn_error<=burst_header_illegal;
        txn_rejected<=burst_header_illegal;
        auto_zero_active<=0;drain_extra_active<=0;
        waiting_b<=0;downstream_b_seen<=0;downstream_bresp<=0;
        beats_total<={1'b0,aw_hold_len}+1'b1;beat_index<=0;
        if(burst_header_illegal)begin
          rejected_transactions<=rejected_transactions+1'b1;
          record_error(burst_header_status,burst_header_detail);
        end
      end

      if(m_axi_awvalid && m_axi_awready)begin
        aw_sent<=1;forwarded_aw<=forwarded_aw+1'b1;
      end

      // A header rejected before the peer is still drained to the source WLAST
      // so the source receives exactly one local DECERR and the channel resyncs.
      if(txn_active && !txn_forward && w_hold_valid &&
         !drain_extra_active)begin
        observed_store_bytes0<=observed_store_bytes0+beat_bytes0;
        observed_store_bytes1<=observed_store_bytes1+beat_bytes1;
        w_hold_valid<=0;beat_index<=beat_index+1'b1;
        if(w_hold_last)begin
          if(!beat_expected_last)record_error(E_PROTOCOL,32'h04000017);
          upstream_b_valid<=1;upstream_bresp<=2'b11;
        end else if(beat_expected_last)begin
          record_error(E_PROTOCOL,32'h04000017);
          drain_extra_active<=1;
        end
      end

      if(m_axi_wvalid && m_axi_wready)begin
        forwarded_w<=forwarded_w+1'b1;
        if(auto_zero_active)begin
          beat_index<=beat_index+1'b1;
          if(beat_expected_last)begin
            auto_zero_active<=0;waiting_b<=1;
          end
        end else begin
          observed_store_bytes0<=observed_store_bytes0+beat_bytes0;
          observed_store_bytes1<=observed_store_bytes1+beat_bytes1;
          if(beat_illegal)begin
            txn_error<=1;
            if(!txn_rejected)begin
              txn_rejected<=1;
              rejected_transactions<=rejected_transactions+1'b1;
            end
            record_error(beat_error_status,beat_error_detail);
          end
          if(!txn_error && !beat_illegal)begin
            unique_bytes0<=unique_bytes0+beat_bytes0;
            unique_bytes1<=unique_bytes1+beat_bytes1;
            beat_base=aw_hold_addr+(64'(beat_index)<<6);
            for(int lane=0;lane<64;lane++)if(w_hold_strb[lane])begin
              descriptor_index=byte_descriptor(beat_base+lane);
              if(descriptor_index>=0)begin
                linear_index=byte_index(descriptor_index,beat_base+lane);
                if(descriptor_index==0)coverage0[linear_index]<=1;
                else coverage1[linear_index]<=1;
              end
            end
          end
          w_hold_valid<=0;beat_index<=beat_index+1'b1;
          if(w_hold_last && !beat_expected_last)
            auto_zero_active<=1;
          if(!w_hold_last && beat_expected_last)
            drain_extra_active<=1;
          if(beat_expected_last)waiting_b<=1;
        end
      end

      // If the source omitted WLAST on the declared final beat, the peer burst
      // has already been closed with a zero-strobe final beat.  Absorb source
      // beats until its real WLAST before returning the merged B response.
      if(txn_active && drain_extra_active && w_hold_valid)begin
        drain_bytes=0;
        for(int lane=0;lane<64;lane++)
          if(w_hold_strb[lane])drain_bytes=drain_bytes+1'b1;
        if(cfg_used[0] && !cfg_used[1])
          observed_store_bytes0<=observed_store_bytes0+drain_bytes;
        if(cfg_used[1] && !cfg_used[0])
          observed_store_bytes1<=observed_store_bytes1+drain_bytes;
        w_hold_valid<=0;
        if(w_hold_last)begin
          drain_extra_active<=0;
          if(!txn_forward)begin
            upstream_b_valid<=1;upstream_bresp<=2'b11;
          end else if(downstream_b_seen || downstream_b_handshake)begin
            upstream_b_valid<=1;
            upstream_bresp<=txn_error ? 2'b11 :
              downstream_b_handshake ? m_axi_bresp : downstream_bresp;
          end
        end
      end

      if(downstream_b_handshake)begin
        downstream_b_seen<=1;downstream_bresp<=m_axi_bresp;waiting_b<=0;
        if(m_axi_bresp!=0)record_error(E_BUFFER,32'h04000008);
        if(!drain_extra_active)begin
          upstream_b_valid<=1;
          upstream_bresp<=txn_error ? 2'b11 : m_axi_bresp;
        end
      end

      if(upstream_b_valid && s_axi_bready)begin
        retired_b<=retired_b+1'b1;upstream_b_valid<=0;
        aw_hold_valid<=0;w_hold_valid<=0;txn_active<=0;txn_forward<=0;
        aw_sent<=0;txn_error<=0;txn_rejected<=0;
        auto_zero_active<=0;drain_extra_active<=0;waiting_b<=0;
        downstream_b_seen<=0;downstream_bresp<=0;
        beats_total<=0;beat_index<=0;
      end
    end
  end
endmodule
