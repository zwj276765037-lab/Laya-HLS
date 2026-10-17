`timescale 1ns/1ps

// Two complete stripe entries and synchronous 32 PS / 4 metadata banks.
// E0 admits/read-preclaims, E1 copies RAM q, E2 earliest arithmetic launch.
// The old async v1 remains an immutable baseline; matrix residency is upstream.
module tm4tn8_sync_ps_front_v2 #(parameter bit PACKED = 0) (
  input  logic          clk,
  input  logic          rst_n,
  input  logic          config_valid,
  output logic          config_ready,
  input  logic [15:0]   config_k,
  input  logic [15:0]   config_n,
  input  logic [2:0]    config_rows,
  input  logic [15:0]   config_row0,
  input  logic [159:0]  config_identity,
  input  logic          issue_valid,
  output logic          issue_ready,
  input  logic [95:0]   issue_identity,
  input  logic [3:0]    issue_version,
  input  logic [26:0]   issue_sequence,
  input  logic [6:0]    issue_group,
  input  logic [9:0]    issue_tile,
  input  logic [7:0]    issue_lane_mask,
  input  logic [3:0]    issue_trace_mask,
  input  logic [11:0]   issue_trace_lane,
  input  logic [1023:0] issue_a8,
  input  logic [127:0]  issue_sa,
  input  logic [2047:0] issue_w8,
  input  logic [255:0]  issue_sw,
  output logic [3:0]    commit_valid,
  input  logic [3:0]    commit_ready,
  output logic [767:0]  commit_tag,
  output logic [39:0]   commit_tile,
  output logic [31:0]   commit_lane_mask,
  output logic [31:0]   commit_bad_mask,
  output logic [95:0]   commit_phase,
  output logic [1023:0] commit_next_ps,
  output logic [3:0] final_skip_valid,
  input logic [3:0] final_skip_ready,
  output logic [9:0] final_skip_tile,
  output logic [7:0] final_skip_mask,
  output logic [3:0]    trace_valid,
  input  logic [3:0]    trace_ready,
  output logic [7:0]    trace_slot,
  output logic [767:0]  trace_tag,
  output logic [1023:0] trace_payload,
  input  logic [3:0]    trace_ack_valid,
  input  logic [7:0]    trace_ack_slot,
  input  logic [767:0]  trace_ack_tag,
  input  logic [3:0]    trace_ack_ok,
  output logic [23:0]   result_free,
  output logic [23:0]   result_reserved,
  output logic [23:0]   result_returned,
  output logic [11:0]   trace_free,
  output logic          done_valid,
  output logic          done_error,
  output logic          protocol_failure,
  output logic [63:0]   first_error_rank,
  output logic [31:0]   first_bad_element,
  output logic [26:0]   accepted_stripes
);
  typedef enum logic [1:0] {IDLE,RUN,DRAIN,FINISHED} state_t;
  state_t state;
  logic [15:0] K,N,row0;
  logic [7:0] G;
  logic [9:0] T,next_tile;
  logic [7:0] next_group;
  logic [26:0] next_sequence;
  logic [31:0] expected_stripes;
  logic [159:0] identity;
  logic [3:0] rowmask;
  logic numeric_failure;
  logic [655:0] initialized[0:3],busy[0:3];

  // Both slots hold complete immutable payloads. A RAM return carries the
  // slot generation, never an unqualified FIFO head pointer.
  logic head,tail;
  logic [1:0] entry_count;
  logic [1:0] entry_valid,entry_copied,entry_failed;
  logic [15:0] entry_generation[0:1];
  logic [159:0] entry_identity[0:1];
  logic [6:0] entry_group[0:1];
  logic [9:0] entry_tile[0:1];
  logic [7:0] entry_mask[0:1];
  logic [3:0] entry_trace[0:1];
  logic [11:0] entry_trace_lane[0:1];
  logic [1023:0] entry_a[0:1];
  logic [127:0] entry_sa[0:1];
  logic [2047:0] entry_w[0:1];
  logic [255:0] entry_sw[0:1];
  logic [255:0] entry_old_ps[0:1][0:3];
  logic [7:0] entry_poison[0:1][0:3];
  logic [7:0] entry_effective[0:1][0:3];
  logic [3:0] entry_skip[0:1];
  logic read_pending,read_entry;
  logic [15:0] read_generation;
  logic [1:0] preclaim[0:3],pretrace[0:3];

  logic header_ok,dependency_ready,credit_ready,space_ready;
  logic accepted,rejected,pop,discard,launch,head_ready,copy_bad;
  logic [3:0] row_ready,row_issue_valid,row_protocol_error;
  logic [3:0] raw_commit_valid,row_commit_ready,commit_ok,commit_fire;
  logic [191:0] tag_row[0:3],allocated_tag[0:3];
  logic [5:0] allocated_slot[0:3],commit_slot[0:3];
  logic [9:0] tile_row[0:3];
  logic [7:0] mask_row[0:3],bad_row[0:3];
  logic [23:0] phase_row[0:3];
  logic [255:0] next_ps_row[0:3];
  logic [5:0] free_row[0:3],reserved_row[0:3],returned_row[0:3];
  logic [2:0] trace_free_row[0:3];
  logic [34:0] snapshot_valid[0:3];
  logic [191:0] snapshot_tag[0:3][0:34];
  logic [7:0] snapshot_poison[0:3][0:34];
  logic [15:0] meta_q[0:3],meta_wdata[0:3];
  logic [31:0] ps_q[0:3][0:7];
  logic [3:0] meta_we,skip_fire;
  logic [9:0] meta_waddr[0:3];
  logic all_credits_free;
  logic [63:0] cycle_rank;
  logic [31:0] cycle_bad_element;

  // These are actual edge counters, not a configured II claim.
  logic [31:0] header_accepted_count,header_rejected_count;
  logic [31:0] read_request_count,read_copy_count,read_rejected_count;
  logic [31:0] launch_stripes_count,skip_rows_count,commit_rows_count;
  logic [31:0] busy_stall_count,credit_stall_count,front_stall_count;
  logic [31:0] launch_stall_count,commit_stall_count;

  always_comb begin
    header_ok=issue_identity==identity[159:64] && issue_version==1 &&
      issue_sequence==next_sequence && issue_group<G && issue_tile<656 &&
      issue_tile<T && issue_group==next_group && issue_tile==next_tile &&
      issue_lane_mask!=0 && (issue_trace_mask & ~rowmask)==0;
    if(issue_tile==T-1)
      header_ok=header_ok && issue_lane_mask==(N[2:0]==0 ? 8'hff :
                                            8'((1<<N[2:0])-1));
    else header_ok=header_ok && issue_lane_mask==8'hff;
    dependency_ready=1;
    credit_ready=1;
    for(int r=0;r<4;r++) if(rowmask[r]) begin
      if(!header_ok) dependency_ready=0;
      else if(busy[r][issue_tile] ||
              (issue_group!=0 && !initialized[r][issue_tile]))
        dependency_ready=0;
      if(free_row[r]<=6'(preclaim[r]) ||
         (issue_trace_mask[r] && trace_free_row[r]<=3'(pretrace[r])))
        credit_ready=0;
    end
    copy_bad=0;
    if(read_pending) begin
      if(!entry_valid[read_entry] ||
         entry_generation[read_entry]!=read_generation) copy_bad=1;
      for(int r=0;r<4;r++) if(rowmask[r]) begin
        if(entry_group[read_entry]!=0 &&
           meta_q[r][7:0]!={1'b0,entry_group[read_entry]}) copy_bad=1;
        if(entry_trace[read_entry][r] && entry_group[read_entry]!=0 &&
           meta_q[r][8+entry_trace_lane[read_entry][r*3+:3]]) copy_bad=1;
      end
    end
    all_credits_free=entry_count==0 && !read_pending;
    for(int r=0;r<4;r++)
      if(free_row[r]!=35 || reserved_row[r]!=0 || returned_row[r]!=0 ||
         trace_free_row[r]!=4 || preclaim[r]!=0 || pretrace[r]!=0 ||
         raw_commit_valid[r] || trace_valid[r]) all_credits_free=0;
  end
  assign config_ready=(state==IDLE || state==FINISHED) && all_credits_free;
  assign space_ready=entry_count<2 || pop;
  assign issue_ready=state==RUN && !copy_bad &&
                     (!header_ok || (space_ready && dependency_ready && credit_ready));
  assign accepted=issue_valid && issue_ready && header_ok;
  assign rejected=issue_valid && issue_ready && !header_ok;
  assign discard=state==DRAIN || entry_failed[head];
  always_comb begin
    head_ready=entry_count!=0 && entry_valid[head] && entry_copied[head];
    if(head_ready && !discard)
      for(int r=0;r<4;r++) if(rowmask[r]) begin
        if(entry_skip[head][r]) begin
          if(commit_fire[r]) head_ready=0;
          if(entry_group[head]==G-1 && !final_skip_ready[r])head_ready=0;
        end else if(!row_ready[r]) head_ready=0;
      end
  end
  assign pop=head_ready;
  assign launch=pop && !discard && !copy_bad && !rejected && !(|row_protocol_error);
  assign final_skip_tile=entry_tile[head];
  assign final_skip_mask=entry_mask[head];
  for(genvar r=0;r<4;r++)begin:final_skips
    assign final_skip_valid[r]=launch && rowmask[r] && entry_skip[head][r] && entry_group[head]==G-1;
  end

  always_comb begin
    cycle_rank='1;
    cycle_bad_element='1;
    for(int r=0;r<4;r++) begin
      commit_slot[r]={tag_row[r][63],tag_row[r][4:0]};
      commit_ok[r]=0;
      if(commit_slot[r]<35 && tile_row[r]<T && tile_row[r]<656)
        commit_ok[r]=snapshot_valid[r][commit_slot[r]] &&
          snapshot_tag[r][commit_slot[r]]==tag_row[r] &&
          tag_row[r][159:64]==identity[159:64] &&
          tag_row[r][167:164]==1 && tag_row[r][27:26]==2'(r) &&
          {tag_row[r][161],tag_row[r][25:17]}==tile_row[r] &&
          {tag_row[r][160],tag_row[r][16:11]}<G &&
          tag_row[r][35:28]==mask_row[r] && busy[r][tile_row[r]];
      commit_valid[r]=raw_commit_valid[r] && commit_ok[r];
      row_commit_ready[r]=commit_ready[r] && commit_ok[r];
      commit_fire[r]=raw_commit_valid[r] && row_commit_ready[r];
      skip_fire[r]=launch && rowmask[r] && entry_skip[head][r];
      meta_we[r]=commit_fire[r] || skip_fire[r];
      meta_waddr[r]=commit_fire[r] ? tile_row[r] : entry_tile[head];
      meta_wdata[r]={entry_poison[head][r],8'(entry_group[head]+8'd1)};
      if(commit_fire[r]) begin
        meta_wdata[r]={snapshot_poison[r][commit_slot[r]] | bad_row[r],
                      8'({tag_row[r][160],tag_row[r][16:11]}+8'd1)};
        for(int lane=0;lane<8;lane++) if(mask_row[r][lane] && bad_row[r][lane]) begin
          if((((longint'(tile_row[r])*16+longint'(row0)+r)*8+lane)*
              (longint'(G)+1)+longint'({tag_row[r][160],tag_row[r][16:11]}))*5+
              longint'(phase_row[r][lane*3+:3]) < cycle_rank) begin
            cycle_rank=(((longint'(tile_row[r])*16+longint'(row0)+r)*8+lane)*
              (longint'(G)+1)+longint'({tag_row[r][160],tag_row[r][16:11]}))*5+
              longint'(phase_row[r][lane*3+:3]);
            cycle_bad_element=32'((int'(row0)+r)*5248*128+
              (int'(tile_row[r])*8+lane)*128+
              int'({tag_row[r][160],tag_row[r][16:11]}));
          end
        end
      end
    end
  end

  for(genvar r=0;r<4;r++) begin:row
    assign row_issue_valid[r]=launch && rowmask[r] && !entry_skip[head][r];
    assign commit_tag[r*192+:192]=tag_row[r];
    assign commit_tile[r*10+:10]=tile_row[r];
    assign commit_lane_mask[r*8+:8]=mask_row[r];
    assign commit_bad_mask[r*8+:8]=bad_row[r] |
      (commit_slot[r]<35 ? snapshot_poison[r][commit_slot[r]] : 8'd0);
    assign commit_phase[r*24+:24]=phase_row[r];
    assign commit_next_ps[r*256+:256]=next_ps_row[r];
    assign result_free[r*6+:6]=free_row[r]-6'(preclaim[r]);
    assign result_reserved[r*6+:6]=reserved_row[r]+6'(preclaim[r]);
    assign result_returned[r*6+:6]=returned_row[r];
    assign trace_free[r*3+:3]=trace_free_row[r]-3'(pretrace[r]);
    tm4tn8_sync_bank_v2 #(.WIDTH(16)) metadata (
      .clk,.rd_en(accepted && rowmask[r]),.rd_addr(issue_tile),.rd_data(meta_q[r]),
      .wr_en(meta_we[r]),.wr_addr(meta_waddr[r]),.wr_data(meta_wdata[r]));
    for(genvar lane=0;lane<8;lane++) begin:lane_bank
      tm4tn8_sync_bank_v2 ps_bank (
        .clk,.rd_en(accepted && rowmask[r]),.rd_addr(issue_tile),.rd_data(ps_q[r][lane]),
        .wr_en(commit_fire[r] && mask_row[r][lane] && !bad_row[r][lane]),
        .wr_addr(tile_row[r]),.wr_data(next_ps_row[r][lane*32+:32]));
    end
    tm4tn8_row_pipeline_v1 #(.PACKED(PACKED)) arithmetic (
      .clk,.rst_n,.issue_valid(row_issue_valid[r]),.issue_ready(row_ready[r]),
      .issue_identity_tag({32'd0,entry_identity[head]}),
      .issue_tile(entry_tile[head]),.issue_lane_mask(entry_effective[head][r]),
      .issue_trace(entry_trace[head][r]),.issue_trace_lane(entry_trace_lane[head][r*3+:3]),
      .issue_group(entry_group[head]),.issue_row(2'(r)),
      .issue_a8(entry_a[head][r*256+:256]),.issue_w8(entry_w[head]),
      .issue_old_ps(entry_old_ps[head][r]),.issue_sa(entry_sa[head][r*32+:32]),
      .issue_sw(entry_sw[head]),.commit_valid(raw_commit_valid[r]),
      .commit_ready(row_commit_ready[r]),.commit_tag(tag_row[r]),.commit_tile(tile_row[r]),
      .commit_lane_mask(mask_row[r]),.commit_bad_mask(bad_row[r]),
      .commit_phase(phase_row[r]),.commit_next_ps(next_ps_row[r]),
      .trace_valid(trace_valid[r]),.trace_ready(trace_ready[r]),
      .trace_slot(trace_slot[r*2+:2]),.trace_tag(trace_tag[r*192+:192]),
      .trace_payload(trace_payload[r*256+:256]),
      .trace_ack_valid(trace_ack_valid[r]),.trace_ack_slot(trace_ack_slot[r*2+:2]),
      .trace_ack_tag(trace_ack_tag[r*192+:192]),.trace_ack_ok(trace_ack_ok[r]),
      .result_free(free_row[r]),.result_reserved(reserved_row[r]),
      .result_returned(returned_row[r]),.trace_free(trace_free_row[r]),
      .protocol_error(row_protocol_error[r]),.allocated_result_slot(allocated_slot[r]),
      .allocated_issue_tag(allocated_tag[r]));
  end

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE;head<=0;tail<=0;entry_count<=0;entry_valid<=0;
      entry_copied<=0;entry_failed<=0;read_pending<=0;
      entry_generation[0]<=0;entry_generation[1]<=0;
      done_valid<=0;done_error<=0;protocol_failure<=0;numeric_failure<=0;
      first_error_rank<='1;first_bad_element<='1;
      accepted_stripes<=0;next_sequence<=0;next_group<=0;next_tile<=0;
      header_accepted_count<=0;header_rejected_count<=0;read_request_count<=0;
      read_copy_count<=0;read_rejected_count<=0;launch_stripes_count<=0;
      skip_rows_count<=0;commit_rows_count<=0;busy_stall_count<=0;
      credit_stall_count<=0;front_stall_count<=0;launch_stall_count<=0;commit_stall_count<=0;
      for(int r=0;r<4;r++) begin
        initialized[r]<='0;busy[r]<='0;preclaim[r]<=0;pretrace[r]<=0;
        snapshot_valid[r]<='0;
      end
    end else begin
      if(config_valid && config_ready) begin
        if((config_rows==1 || config_rows==4) && config_row0+config_rows<=128 &&
          ((config_k==256 && config_n==2) ||
           (config_k==1024 && config_n==3072) ||
           (config_k==1024 && config_n==1024) ||
           (config_k==1024 && config_n==4096) ||
           (config_k==4096 && config_n==1024) ||
           (config_k==1024 && config_n==5248) ||
           (config_k==2624 && config_n==1024))) begin
          K<=config_k;N<=config_n;G<=config_k[12:5];
          T<=(config_n+16'd7)>>3;row0<=config_row0;
          identity<=config_identity;rowmask<=config_rows==1 ? 4'b0001 : 4'b1111;
          expected_stripes<=(32'(config_k)>>5)*((32'(config_n)+7)>>3);
          accepted_stripes<=0;next_sequence<=0;next_group<=0;next_tile<=0;
          state<=RUN;done_valid<=0;done_error<=0;numeric_failure<=0;
          protocol_failure<=0;first_error_rank<='1;first_bad_element<='1;
          head<=0;tail<=0;entry_count<=0;entry_valid<=0;entry_copied<=0;
          entry_failed<=0;read_pending<=0;
          header_accepted_count<=0;header_rejected_count<=0;read_request_count<=0;
          read_copy_count<=0;read_rejected_count<=0;launch_stripes_count<=0;
          skip_rows_count<=0;commit_rows_count<=0;busy_stall_count<=0;
          credit_stall_count<=0;front_stall_count<=0;launch_stall_count<=0;commit_stall_count<=0;
          for(int r=0;r<4;r++) begin
            initialized[r]<='0;busy[r]<='0;preclaim[r]<=0;pretrace[r]<=0;
            snapshot_valid[r]<='0;
          end
        end else begin
          state<=FINISHED;done_valid<=1;done_error<=1;protocol_failure<=1;
        end
      end else begin
        read_pending<=accepted;
        if(rejected || copy_bad || (|row_protocol_error) ||
           (|(raw_commit_valid & ~commit_ok))) begin
          protocol_failure<=1;state<=DRAIN;
        end
        if(rejected) header_rejected_count<=header_rejected_count+1;
        if(copy_bad) read_rejected_count<=read_rejected_count+1;
        if(state==RUN && issue_valid && header_ok && !issue_ready) begin
          if(!dependency_ready) busy_stall_count<=busy_stall_count+1;
          if(!credit_ready) credit_stall_count<=credit_stall_count+1;
          if(!space_ready) front_stall_count<=front_stall_count+1;
        end
        if(entry_count!=0 && entry_copied[head] && !pop)
          launch_stall_count<=launch_stall_count+1;
        if(|(raw_commit_valid & ~row_commit_ready)) commit_stall_count<=commit_stall_count+1;
        if(read_pending) begin
          read_copy_count<=read_copy_count+1;
          entry_copied[read_entry]<=1;entry_failed[read_entry]<=copy_bad;
          for(int r=0;r<4;r++) begin
            entry_poison[read_entry][r]<=entry_group[read_entry]==0 ? 0 : meta_q[r][15:8];
            entry_effective[read_entry][r]<=entry_mask[read_entry] &
                (entry_group[read_entry]==0 ? 8'hff : ~meta_q[r][15:8]);
            entry_skip[read_entry][r]<=rowmask[r] &&
                (entry_mask[read_entry] &
                 (entry_group[read_entry]==0 ? 8'hff : ~meta_q[r][15:8]))==0;
            for(int lane=0;lane<8;lane++)
              entry_old_ps[read_entry][r][lane*32+:32]<=
                 entry_group[read_entry]==0 ? 32'd0 : ps_q[r][lane];
          end
        end
        entry_count<=entry_count+2'(accepted)-2'(pop);
        if(pop) begin
          entry_valid[head]<=0;entry_copied[head]<=0;entry_failed[head]<=0;
          head<=~head;
        end
        if(accepted) begin
          entry_valid[tail]<=1;entry_copied[tail]<=0;entry_failed[tail]<=0;
          entry_generation[tail]<=entry_generation[tail]+16'd1;
          read_entry<=tail;read_generation<=entry_generation[tail]+16'd1;
          entry_identity[tail]<=identity;
          entry_identity[tail][62:36]<=issue_sequence;
          entry_group[tail]<=issue_group;entry_tile[tail]<=issue_tile;
          entry_mask[tail]<=issue_lane_mask;entry_trace[tail]<=issue_trace_mask;
          entry_trace_lane[tail]<=issue_trace_lane;
          entry_a[tail]<=issue_a8;entry_sa[tail]<=issue_sa;
          entry_w[tail]<=issue_w8;entry_sw[tail]<=issue_sw;tail<=~tail;
          accepted_stripes<=accepted_stripes+1;next_sequence<=next_sequence+1;
          header_accepted_count<=header_accepted_count+1;read_request_count<=read_request_count+1;
          if(next_tile==T-1) begin next_tile<=0;next_group<=next_group+1;end
          else next_tile<=next_tile+1;
        end
        if(launch) begin
          launch_stripes_count<=launch_stripes_count+1;
          skip_rows_count<=skip_rows_count+32'(skip_fire[0])+32'(skip_fire[1])+
                           32'(skip_fire[2])+32'(skip_fire[3]);
        end
        commit_rows_count<=commit_rows_count+32'(commit_fire[0])+32'(commit_fire[1])+
                           32'(commit_fire[2])+32'(commit_fire[3]);
        if(cycle_rank<first_error_rank) begin
          first_error_rank<=cycle_rank;first_bad_element<=cycle_bad_element;
        end
        for(int r=0;r<4;r++) begin
          preclaim[r]<=preclaim[r]+2'(accepted && rowmask[r])-2'(pop && rowmask[r]);
          pretrace[r]<=pretrace[r]+2'(accepted && rowmask[r] && issue_trace_mask[r])-
                         2'(pop && rowmask[r] && entry_trace[head][r]);
          if(commit_fire[r]) begin
            busy[r][tile_row[r]]<=0;initialized[r][tile_row[r]]<=1;
            snapshot_valid[r][commit_slot[r]]<=0;
            if(|bad_row[r]) numeric_failure<=1;
          end
          if(pop && rowmask[r] && (discard || !launch || entry_skip[head][r])) begin
            busy[r][entry_tile[head]]<=0;
            if(skip_fire[r]) initialized[r][entry_tile[head]]<=1;
          end
          if(row_issue_valid[r] && row_ready[r]) begin
            snapshot_valid[r][allocated_slot[r]]<=1;
            snapshot_tag[r][allocated_slot[r]]<=allocated_tag[r];
            snapshot_poison[r][allocated_slot[r]]<=entry_poison[head][r];
          end
          if(accepted && rowmask[r]) busy[r][issue_tile]<=1;
        end
        if((state==RUN && accepted_stripes==expected_stripes && all_credits_free) ||
           (state==DRAIN && all_credits_free)) begin
          done_valid<=1;done_error<=protocol_failure || numeric_failure ||
            (|row_protocol_error) || rejected || copy_bad;
          state<=FINISHED;
        end
      end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk) if(rst_n) begin
    assert(entry_count<=2) else $fatal(1,"sync PS front entry capacity");
    for(int r=0;r<4;r++) begin
      assert(int'(free_row[r])-int'(preclaim[r])+int'(preclaim[r])+
             int'(reserved_row[r])+int'(returned_row[r])==35)
        else $fatal(1,"sync PS Q35 conservation row %0d",r);
      assert(free_row[r]>=preclaim[r] && trace_free_row[r]>=pretrace[r])
        else $fatal(1,"sync PS preclaim credit underflow row %0d",r);
      assert(!(commit_fire[r] && skip_fire[r]))
        else $fatal(1,"sync PS metadata write collision row %0d",r);
      if(row_issue_valid[r]) assert(entry_copied[head] && row_ready[r])
        else $fatal(1,"sync PS launch before copy/credit");
    end
  end
`endif
endmodule
