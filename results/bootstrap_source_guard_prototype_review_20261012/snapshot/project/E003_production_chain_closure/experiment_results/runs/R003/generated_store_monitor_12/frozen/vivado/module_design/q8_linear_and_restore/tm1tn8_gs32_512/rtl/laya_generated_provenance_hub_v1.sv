`timescale 1ns/1ps
// Persistent transaction ledger for validated LPV1 requests.  Physical AXI
// monitoring is an explicit input to this block; this module does not infer
// WSTRB coverage or adapter emptiness from C-level completion.
module laya_generated_provenance_hub_v1 #(
  parameter int OWNERS=32,
  parameter bit ENABLE_BOOTSTRAP_SNAPSHOT=0,
  parameter bit ENABLE_BOOTSTRAP_SOURCE_GUARD=0
) (
  input  logic clk,rst_n,
  input  logic request_valid,
  output logic request_ready,
  input  logic [8191:0] request,
  input  logic cancel,
  input  logic begin_external_ready,
  input  logic begin_external_supported,
  input  logic physical_observation_valid,
  output logic physical_observation_ready,
  input  logic [15:0] physical_status,
  input  logic [31:0] physical_error_detail,
  input  logic [63:0] physical_bad_element,
  input  logic [63:0] physical_observed_store_bytes0,
  input  logic [63:0] physical_observed_store_bytes1,
  input  logic physical_drained,
  input  logic physical_coverage_complete,
  input  logic source_query_valid,
  output logic source_query_ready,
  input  logic [8191:0] source_query_command,
  output logic source_query_granted,
  input  logic source_release_valid,
  output logic source_release_ready,
  input  logic [8191:0] source_release_command,
  input  logic source_release_drained,
  output logic source_lease_active,
  output logic response_valid,
  input  logic response_ready,
  output logic [4095:0] response,
  output logic scope_active,
  output logic domain_drained,
  output logic cancel_pending,
  output logic [5:0] active_owners,published_owners,
  output logic [31:0] accepted_events,semantic_rejections,terminal_tasks,
  input logic snapshot_request_valid,
  output logic snapshot_request_ready,
  input logic [6143:0] snapshot_request,
  output logic snapshot_response_valid,
  input logic snapshot_response_ready,
  output logic [6143:0] snapshot_response,
  // The unique outer shell supplies its locked source BO/base lifecycle and
  // real monitor/adapter/read-debt fence.  No owner publication is delegated.
  input logic snapshot_physical_quiescent,snapshot_base_valid,
  input logic [63:0] snapshot_base_epoch,snapshot_base_address,snapshot_base_capacity,
  output logic [63:0] snapshot_sequence_high_water,
  input logic bootstrap_source_guard_active,
  input logic [6143:0] bootstrap_source_guard_key,
  output logic bootstrap_source_guard_match
);
  import laya_generated_provenance_layout_v1::*;

  logic owner_valid[0:OWNERS-1],owner_active[0:OWNERS-1];
  logic owner_published[0:OWNERS-1],owner_invalid[0:OWNERS-1];
  logic [671:0] owner_identity[0:OWNERS-1];
  logic [3327:0] owner_model_identity[0:OWNERS-1];
  logic [1023:0] owner_descriptor[0:OWNERS-1];
  logic [31:0] owner_max_epoch[0:OWNERS-1];
  logic [127:0] owner_window_closed[0:OWNERS-1];
  logic [95:0] owner_window_context[0:OWNERS-1][0:127];
  logic [63:0] owner_last_q_generation[0:OWNERS-1];
  logic typed_valid[0:OWNERS-1];
  logic [671:0] typed_identity[0:OWNERS-1];
  logic [31:0] typed_last_task[0:OWNERS-1];
  logic [8191:0] active_begin;
  logic [$clog2(OWNERS)-1:0] active_typed_slot;
  logic admitted_identity_valid;
  logic [671:0] admitted_identity;
  logic pending_end;
  logic [8191:0] pending_end_request;
  logic [15:0] pending_physical_status;
  logic [31:0] pending_physical_detail;
  logic [63:0] pending_physical_bad;
  logic [$clog2(OWNERS)-1:0] source_lease_slot;
  logic [671:0] source_lease_identity;
  logic [95:0] source_lease_producer_context,source_lease_quant_context;
  logic [95:0] source_lease_linear_context;
  logic [63:0] source_lease_ref,source_lease_a_ref,source_lease_w_ref;
  logic [63:0] source_lease_ps_ref,source_lease_dst_ref;
  logic [63:0] source_lease_future_dst_ref,source_lease_generation;
  logic [63:0] source_lease_offset,source_lease_span,source_lease_stride;
  logic [63:0] source_lease_row_stride,source_lease_batch_stride;
  logic [15:0] source_lease_k;
  logic [7:0] source_lease_rows,source_lease_role;

  logic [15:0] request_action;
  logic needs_physical;
  assign request_action=request[ACTION*8+:16];
  assign needs_physical=request_action==END_EVENT || request_action==PUBLISH ||
                        request_action==RELEASE || request_action==INVALIDATE;
  // LPV and old-action cleanup have priority over an unaccepted snapshot.
  // A held accepted snapshot response still excludes all owner mutation.
  assign request_ready=!response_valid && !pending_end &&
                       (!ENABLE_BOOTSTRAP_SNAPSHOT ||
                        (!snapshot_response_valid)) &&
                       (!ENABLE_BOOTSTRAP_SOURCE_GUARD || !guard_conflict(request)) &&
                       (request_action!=BEGIN_EVENT || begin_external_ready) &&
                       (!needs_physical || physical_observation_valid);
  assign physical_observation_ready=(pending_end && !response_valid) ||
                                    (request_valid && request_ready &&
                                     needs_physical);
  assign domain_drained=!scope_active && !pending_end && !response_valid &&
                        !source_lease_active &&
                        !cancel_pending && active_owners==0 &&
                        (!ENABLE_BOOTSTRAP_SOURCE_GUARD || !bootstrap_source_guard_active);

  always_comb begin
    active_owners=0;published_owners=0;
    for(int i=0;i<OWNERS;i++)begin
      if(owner_valid[i] && owner_active[i])active_owners=active_owners+1'b1;
      if(owner_valid[i] && owner_active[i] && owner_published[i])
        published_owners=published_owners+1'b1;
    end
  end

  function automatic logic same_physical(input logic [1023:0] a,b);
    return a[4*8+:24]==b[4*8+:24] && a[28*8+:8]==b[28*8+:8] &&
      a[32*8+:64]==b[32*8+:64] && a[40*8+:64]==b[40*8+:64];
  endfunction

  function automatic integer find_physical(input logic [1023:0] descriptor);
    find_physical=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_physical<0 && owner_valid[i] &&
         same_physical(owner_descriptor[i],descriptor))find_physical=i;
  endfunction

  function automatic integer find_exact(input logic [671:0] identity,
                                          input logic [1023:0] descriptor);
    find_exact=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_exact<0 && owner_valid[i] && owner_active[i] &&
         owner_identity[i]==identity && owner_descriptor[i]==descriptor)
        find_exact=i;
  endfunction

  function automatic integer find_source(input logic [671:0] identity,
                                           input logic [63:0] source_ref);
    find_source=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_source<0 && owner_valid[i] && owner_active[i] &&
         owner_identity[i]==identity && owner_descriptor[i][0+:64]==source_ref)
        find_source=i;
  endfunction

  function automatic integer find_empty(input integer excluded);
    find_empty=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_empty<0 && i!=excluded && !owner_valid[i])find_empty=i;
  endfunction

  function automatic integer find_typed(input logic [671:0] identity);
    find_typed=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_typed<0 && typed_valid[i] && typed_identity[i]==identity)
        find_typed=i;
  endfunction

  function automatic integer find_empty_typed;
    find_empty_typed=-1;
    for(int i=0;i<OWNERS;i++)
      if(find_empty_typed<0 && !typed_valid[i])find_empty_typed=i;
  endfunction

  function automatic logic identity_newer(input logic [671:0] candidate,
                                            input logic [671:0] current);
    return candidate[8*8+:64]>current[8*8+:64] ||
      (candidate[8*8+:64]==current[8*8+:64] &&
       candidate[0+:64]>current[0+:64]);
  endfunction

  function automatic logic owner_descriptors_ok(input logic [8191:0] packet);
    logic [7:0] count;
    logic [1023:0] first,second;
    logic no_old,old_pair;
    count=packet[DESCRIPTOR_COUNT*8+:8];
    first=packet[DESCRIPTOR0*8+:1024];second=packet[DESCRIPTOR1*8+:1024];
    if((first[8*8+:64]==0 && first[14*8+:8]!=0) ||
       (first[4*8+:8]!=5 && first[5*8+:8]!=0))return 0;
    if(count==1)return first[4*8+:8]!=5;
    if((second[8*8+:64]==0 && second[14*8+:8]!=0))return 0;
    no_old=first[8*8+:64]==0 && second[8*8+:64]==0;
    old_pair=first[12*8+:8]==5 && second[12*8+:8]==5 &&
      first[13*8+:8]==0 && second[13*8+:8]==1 &&
      first[8*8+:32]==second[8*8+:32] &&
      first[14*8+:16]==0 && second[14*8+:16]==0;
    return first[4*8+:8]==5 && second[4*8+:8]==5 &&
      first[5*8+:8]==0 && second[5*8+:8]==1 &&
      first[0+:32]==second[0+:32] && first[6*8+:16]==0 &&
      second[6*8+:16]==0 && first[27*8+:8]==1 &&
      second[27*8+:8]==1 && first[28*8+:8]==8 &&
      second[28*8+:8]==9 && first[16*8+:96]==second[16*8+:96] &&
      first[32*8+:448]==second[32*8+:448] && (no_old || old_pair);
  endfunction

  function automatic logic geometry_within(input logic [1023:0] descriptor,
                                             input logic [511:0] geometry);
    logic valid;
    logic [63:0] owner_first,owner_after,first,after;
    logic [31:0] segment;
    logic [15:0] rows,repeats;
    logic [63:0] row_step,repeat_step;
    owner_first=descriptor[40*8+:64];
    owner_after=owner_first+descriptor[64*8+:64];
    first=geometry[0+:64];segment=geometry[8*8+:32];
    rows=geometry[12*8+:16];repeats=geometry[14*8+:16];
    row_step=geometry[16*8+:64];repeat_step=geometry[24*8+:64];
    valid=owner_after>=owner_first && owner_after<=descriptor[32*8+:64] &&
      64'(rows)*64'(repeats)<=32 && geometry[32*8+:64]<=16*5248*4;
    for(int repeat_index=0;repeat_index<repeats;repeat_index++)
      for(int row=0;row<rows;row++)begin
        first=geometry[0+:64]+64'(repeat_index)*repeat_step+
              64'(row)*row_step;
        after=first+segment;
        valid=valid && first>=owner_first && after>=first && after<=owner_after;
      end
    return valid;
  endfunction

  function automatic logic geometries_disjoint(input logic [8191:0] packet);
    logic valid;
    logic [7:0] count;
    logic [1023:0] descriptor[0:1];
    logic [511:0] geometry[0:1];
    logic [63:0] af,ae,bf,be;
    count=packet[DESCRIPTOR_COUNT*8+:8];
    descriptor[0]=packet[DESCRIPTOR0*8+:1024];
    descriptor[1]=packet[DESCRIPTOR1*8+:1024];
    geometry[0]=packet[GEOMETRY0*8+:512];
    geometry[1]=packet[GEOMETRY1*8+:512];valid=1;
    for(int a=0;a<count;a++)begin
      valid=valid && geometry_within(descriptor[a],geometry[a]);
      for(int ar=0;ar<geometry[a][14*8+:16];ar++)
        for(int ai=0;ai<geometry[a][12*8+:16];ai++)begin
          af=geometry[a][0+:64]+64'(ar)*geometry[a][24*8+:64]+
             64'(ai)*geometry[a][16*8+:64];
          ae=af+geometry[a][8*8+:32];
          for(int b=a;b<count;b++)
            if(descriptor[a][28*8+:8]==descriptor[b][28*8+:8])
              for(int br=0;br<geometry[b][14*8+:16];br++)
                for(int bi=0;bi<geometry[b][12*8+:16];bi++)begin
                  if(a!=b || ar!=br || ai!=bi)begin
                    bf=geometry[b][0+:64]+64'(br)*geometry[b][24*8+:64]+
                       64'(bi)*geometry[b][16*8+:64];
                    be=bf+geometry[b][8*8+:32];
                    valid=valid && !(af<be && bf<ae);
                  end
                end
        end
    end
    return valid;
  endfunction

  function automatic logic end_binding_ok(input logic [8191:0] ending,
                                            input logic [8191:0] beginning);
    logic valid;
    valid=ending[ORIGIN_SEQ*8+:64]==beginning[EVENT_SEQ*8+:64] &&
      ending[IDENTITY*8+:672]==beginning[IDENTITY*8+:672] &&
      ending[CONTEXT*8+:96]==beginning[CONTEXT*8+:96] &&
      ending[MODEL_IDENTITY*8+:3328]==beginning[MODEL_IDENTITY*8+:3328] &&
      ending[DESCRIPTOR_COUNT*8+:8]==beginning[DESCRIPTOR_COUNT*8+:8] &&
      ending[EXPECTED_UNIT*8+:8]==beginning[EXPECTED_UNIT*8+:8] &&
      ending[EXPECTED_ELEMENTS*8+:32]==beginning[EXPECTED_ELEMENTS*8+:32] &&
      ending[DESCRIPTOR0*8+:128*8]==beginning[DESCRIPTOR0*8+:128*8] &&
      ending[GEOMETRY0*8+:64*8]==beginning[GEOMETRY0*8+:64*8];
    if(beginning[DESCRIPTOR_COUNT*8+:8]==2)
      valid=valid && ending[DESCRIPTOR1*8+:128*8]==
        beginning[DESCRIPTOR1*8+:128*8] &&
        ending[GEOMETRY1*8+:64*8]==beginning[GEOMETRY1*8+:64*8];
    return valid;
  endfunction

  function automatic logic source_owner_supported(input logic [1023:0] d);
    return d[19*8+:8]==0 && d[26*8+:8]==1 && d[27*8+:8]==0 &&
           d[28*8+:8]==6 && d[18*8+:8]==8'hff &&
           d[20*8+:16]==0 && d[22*8+:16]>=1 &&
           d[22*8+:16]<=1024 && d[24*8+:16]>=1;
  endfunction

  function automatic integer source_window_index(
      input logic [95:0] ctx,input logic [1023:0] descriptor);
    integer windows_per_batch,batch_index,row_delta;
    begin
      windows_per_batch=(descriptor[22*8+:16]+15)/16;
      batch_index=descriptor[18*8+:8]==8'hff ? ctx[56+:8] : 0;
      row_delta=ctx[72+:16]-descriptor[20*8+:16];
      source_window_index=batch_index*windows_per_batch+row_delta/16;
    end
  endfunction

  function automatic logic source_window_event_ok(
      input logic [8191:0] packet,input logic [1023:0] descriptor);
    logic [95:0] ctx;
    logic [511:0] geometry;
    logic [15:0] owner_rows,owner_row0,width,context_row0,expected_rows;
    logic [7:0] context_rows,context_batch;
    logic [63:0] expected_first,expected_step,expected_total;
    begin
      ctx=packet[CONTEXT*8+:96];geometry=packet[GEOMETRY0*8+:512];
      owner_row0=descriptor[20*8+:16];owner_rows=descriptor[22*8+:16];
      width=descriptor[24*8+:16];context_batch=ctx[56+:8];
      context_row0=ctx[72+:16];context_rows=ctx[88+:8];
      if(context_row0<owner_row0 ||
         32'(context_row0)>=32'(owner_row0)+32'(owner_rows))
        expected_rows=0;
      else if(32'(owner_row0)+32'(owner_rows)-32'(context_row0)>16)
        expected_rows=16;
      else expected_rows=16'(32'(owner_row0)+32'(owner_rows)-
                             32'(context_row0));
      expected_step=context_rows==1 ? 0 : descriptor[48*8+:64];
      expected_total=64'(context_rows)*64'(width)*4;
      expected_first=descriptor[40*8+:64]+
        (descriptor[18*8+:8]==8'hff ?
          64'(context_batch)*descriptor[56*8+:64] : 0)+
        64'(context_row0-owner_row0)*descriptor[48*8+:64];
      source_window_event_ok=source_owner_supported(descriptor) &&
        ctx[40+:8]==descriptor[16*8+:8] &&
        ctx[48+:8]==descriptor[17*8+:8] && ctx[64+:8]==0 &&
        (descriptor[18*8+:8]==8'hff ||
         context_batch==descriptor[18*8+:8]) &&
        context_row0>=owner_row0 && context_rows==expected_rows &&
        (context_row0-owner_row0)%16==0 &&
        32'(context_row0)+32'(context_rows)<=32'(owner_row0)+32'(owner_rows) &&
        packet[EXPECTED_UNIT*8+:8]==1 &&
        packet[EXPECTED_ELEMENTS*8+:32]==32'(context_rows)*32'(width) &&
        geometry[0+:64]==expected_first &&
        geometry[8*8+:32]==32'(width)*4 &&
        geometry[12*8+:16]==context_rows && geometry[14*8+:16]==1 &&
        geometry[16*8+:64]==expected_step && geometry[24*8+:64]==0 &&
        geometry[32*8+:64]==expected_total && geometry[40*8+:8]==0 &&
        geometry[41*8+:8]==8'hff && geometry[42*8+:8]==0;
    end
  endfunction

  function automatic logic source_owner_complete(input integer slot);
    integer required_windows;
    logic complete;
    begin
      required_windows=(owner_descriptor[slot][22*8+:16]+15)/16;
      if(owner_descriptor[slot][18*8+:8]==8'hff)
        required_windows=required_windows*owner_identity[slot][128+:16];
      complete=required_windows>=1 && required_windows<=128;
      for(int window=0;window<128;window++)
        if(window<required_windows)complete=complete &&
          owner_window_closed[slot][window];
      source_owner_complete=complete;
    end
  endfunction

  // LBS1/LBR1 offsets are frozen in laya_bootstrap_snapshot_layout_v1.sv.
  // This optional interface reads the very same owner arrays used by LPV1.
  function automatic logic snapshot_frame_ok(input logic [6143:0] p);
    logic [1023:0] d;
    logic [15:0] b,s;
    logic [63:0] capacity,address_value,extent;
    logic valid;
    d=p[576*8+:1024];b=p[80*8+:16];s=p[82*8+:16];
    capacity=p[56*8+:64];address_value=p[48*8+:64];
    extent=64'(b-1)*64'd4194304+64'(s)*64'd4096;
    valid=p[0+:32]==32'h3153424c && p[4*8+:16]==1 && p[6*8+:16]==12 &&
      p[8*8+:16]==1 && p[10*8+:48]==0 && p[16*8+:64]!=0 &&
      p[24*8+:128]==0 && p[40*8+:64]!=0 && address_value!=0 &&
      address_value[5:0]==0 && capacity>=64'd8388608 &&
      capacity<=64'hffffffffffffffff-address_value &&
      identity_ok(p[64*8+:672]) && p[148*8+:96]==0 &&
      laya_model_identity_13bo_generated_v1::l13m_canonical_ok(p[160*8+:3328]) &&
      laya_model_identity_13bo_generated_v1::l13m_numeric_tags_ok(
          p[160*8+:3328],p[64*8+:672]) &&
      descriptor_ok(d) && d[4*8+:32]==32'd1 && d[8*8+:64]==0 &&
      d[16*8+:32]==32'h00ff0002 && d[20*8+:16]==0 && d[22*8+:16]==s &&
      d[24*8+:16]==1024 && d[26*8+:24]==24'h060001 && d[29*8+:24]==0 &&
      d[32*8+:64]==capacity && d[40*8+:64]==0 && d[48*8+:64]==4096 &&
      d[56*8+:64]==4194304 && d[64*8+:64]==extent &&
      d[72*8+:448]==0 && p[704*8+:512]==0;
    return valid;
  endfunction

  // The unique shell owns only the exclusion interval/key. Recheck its key
  // against these original arrays at every producer admission; no READY table.
  always_comb begin : guard_match
    integer slot;
    slot=find_exact(bootstrap_source_guard_key[64*8+:672],
                    bootstrap_source_guard_key[576*8+:1024]);
    bootstrap_source_guard_match=0;
    if(ENABLE_BOOTSTRAP_SOURCE_GUARD && bootstrap_source_guard_active && slot>=0)
      bootstrap_source_guard_match=owner_published[slot] && !owner_invalid[slot] &&
        owner_model_identity[slot]==bootstrap_source_guard_key[160*8+:3328] &&
        source_owner_complete(slot);
  end
  function automatic logic guard_descriptor_conflict(input logic [1023:0] d);
    logic [1023:0] protected_descriptor;
    logic [63:0] first,after,protected_first,protected_after;
    protected_descriptor=bootstrap_source_guard_key[576*8+:1024];
    first=d[40*8+:64];after=first+d[64*8+:64];
    protected_first=protected_descriptor[40*8+:64];
    protected_after=protected_first+protected_descriptor[64*8+:64];
    return same_physical(d,protected_descriptor) ||
      d[8*8+:64]==protected_descriptor[0+:64] ||
      (d[28*8+:8]==protected_descriptor[28*8+:8] &&
       (after<first || (first<protected_after && protected_first<after)));
  endfunction
  function automatic logic guard_conflict(input logic [8191:0] p);
    guard_conflict=0;
    if(bootstrap_source_guard_active)begin
      // A new identity can recycle the owner domain. Keep old binding intact.
      guard_conflict=p[IDENTITY*8+:672]!=bootstrap_source_guard_key[64*8+:672];
      if(p[ACTION*8+:16]!=END_EVENT)begin
        guard_conflict=guard_conflict || guard_descriptor_conflict(p[DESCRIPTOR0*8+:1024]);
        if(p[DESCRIPTOR_COUNT*8+:8]==2)
          guard_conflict=guard_conflict || guard_descriptor_conflict(p[DESCRIPTOR1*8+:1024]);
      end
    end
  endfunction

  assign snapshot_request_ready=ENABLE_BOOTSTRAP_SNAPSHOT &&
    !snapshot_response_valid && !request_valid && !response_valid &&
    !pending_end && !scope_active && !source_lease_active && !cancel_pending && !cancel &&
    (!ENABLE_BOOTSTRAP_SOURCE_GUARD || !bootstrap_source_guard_active);

  always_ff @(posedge clk) begin : snapshot_readonly
    integer slot;
    logic [6143:0] reply;
    logic [15:0] status;
    logic matched;
    if(!rst_n)begin
      snapshot_response_valid<=0;snapshot_response<=0;
      snapshot_sequence_high_water<=0;
    end else if(ENABLE_BOOTSTRAP_SNAPSHOT)begin
      if(snapshot_response_valid && snapshot_response_ready)
        snapshot_response_valid<=0;
      if(snapshot_request_valid && snapshot_request_ready)begin
        reply=0;status=E_PROTOCOL;matched=0;
        reply[0+:32]=32'h3152424c;reply[4*8+:16]=1;reply[6*8+:16]=12;
        reply[8*8+:16]=1;reply[10*8+:16]=E_ABI;
        reply[24*8+:32]=32'h0700000e;reply[32*8+:64]=64'hffffffffffffffff;
        if(snapshot_frame_ok(snapshot_request))begin
          reply=snapshot_request;
          reply[0+:32]=32'h3152424c;reply[12*8+:32]=3;
          reply[24*8+:32]=32'h0700000e;reply[32*8+:64]=64'hffffffffffffffff;
          if(snapshot_request[16*8+:64]>snapshot_sequence_high_water)begin
            snapshot_sequence_high_water<=snapshot_request[16*8+:64];
            slot=find_exact(snapshot_request[64*8+:672],
                            snapshot_request[576*8+:1024]);
            status=E_BUFFER;
            if(slot>=0)begin
              matched=owner_published[slot] && !owner_invalid[slot] &&
                owner_model_identity[slot]==snapshot_request[160*8+:3328] &&
                source_owner_complete(slot);
              if(matched)begin
                status=E_PROTOCOL;
                if(snapshot_physical_quiescent && snapshot_base_valid &&
                   snapshot_request[40*8+:64]==snapshot_base_epoch &&
                   snapshot_request[48*8+:64]==snapshot_base_address &&
                   snapshot_request[56*8+:64]==snapshot_base_capacity)begin
                  status=0;reply[12*8+:32]=63;reply[24*8+:32]=0;
                  // Echo the immutable descriptor from the matched hub slot.
                  reply[576*8+:1024]=owner_descriptor[slot];
                end
              end
            end
          end
          reply[10*8+:16]=status;
        end
        snapshot_response<=reply;snapshot_response_valid<=1;
      end
    end
  end

  always_comb begin : source_query_logic
    integer slot,window;
    logic [1023:0] descriptor;
    logic [95:0] producer,quant;
    logic [63:0] expected_span;
    source_query_ready=!source_lease_active && !scope_active && !pending_end &&
      (!ENABLE_BOOTSTRAP_SNAPSHOT ||
       (!snapshot_request_valid && !snapshot_response_valid)) &&
      !request_valid && !response_valid && !cancel_pending &&
      (!ENABLE_BOOTSTRAP_SOURCE_GUARD || !bootstrap_source_guard_active);
    source_query_granted=0;slot=-1;window=-1;descriptor=0;
    producer=source_query_command[laya_compute_portal_layout_v1::PRODUCER_CONTEXT*8+:96];
    quant=source_query_command[laya_compute_portal_layout_v1::QUANT_CONTEXT*8+:96];
    expected_span=0;
    if(source_query_valid && source_query_ready)begin
      slot=find_source(source_query_command[laya_compute_portal_layout_v1::IDENTITY*8+:672],
                       source_query_command[laya_compute_portal_layout_v1::SOURCE_REF*8+:64]);
      if(slot>=0)begin
        descriptor=owner_descriptor[slot];
        window=source_window_index(quant,descriptor);
        expected_span=descriptor[64*8+:64];
        source_query_granted=
          laya_compute_portal_layout_v1::command_frame_ok(source_query_command) &&
          source_query_command[laya_compute_portal_layout_v1::OP_STATUS*8+:16]==2 &&
          source_query_command[laya_compute_portal_layout_v1::CONTEXT*8+:96]==quant &&
          source_query_command[laya_compute_portal_layout_v1::MODEL_IDENTITY*8+:3328]==
            owner_model_identity[slot] && owner_published[slot] &&
          !owner_invalid[slot] && source_owner_supported(descriptor) &&
          window>=0 && window<128 && owner_window_closed[slot][window] &&
          owner_window_context[slot][window]==producer &&
          producer[56+:40]==quant[56+:40] &&
          source_query_command[laya_compute_portal_layout_v1::SOURCE_ROLE*8+:8]==
            descriptor[28*8+:8] &&
          source_query_command[laya_compute_portal_layout_v1::K*8+:16]==
            descriptor[24*8+:16] &&
          source_query_command[laya_compute_portal_layout_v1::ROWS*8+:8]==quant[88+:8] &&
          source_query_command[laya_compute_portal_layout_v1::SOURCE_OFFSET*8+:64]==
            descriptor[40*8+:64] &&
          source_query_command[laya_compute_portal_layout_v1::SOURCE_SPAN*8+:64]==expected_span &&
          source_query_command[laya_compute_portal_layout_v1::SOURCE_STRIDE*8+:64]==
            64'(descriptor[24*8+:16])*4 &&
          source_query_command[laya_compute_portal_layout_v1::ROW_STRIDE*8+:64]==
            descriptor[48*8+:64] &&
          source_query_command[laya_compute_portal_layout_v1::BATCH_STRIDE*8+:64]==
            descriptor[56*8+:64] &&
          source_query_command[laya_compute_portal_layout_v1::GENERATION*8+:64]>
            owner_last_q_generation[slot];
      end
    end
  end

  always_comb begin
    source_release_ready=source_lease_active && source_release_drained &&
      source_release_command[laya_compute_portal_layout_v1::IDENTITY*8+:672]==
        source_lease_identity &&
      source_release_command[laya_compute_portal_layout_v1::GENERATION*8+:64]==
        source_lease_generation &&
      source_release_command[laya_compute_portal_layout_v1::PRODUCER_CONTEXT*8+:96]==
        source_lease_producer_context &&
      source_release_command[laya_compute_portal_layout_v1::QUANT_CONTEXT*8+:96]==
        source_lease_quant_context &&
      source_release_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96]==
        source_lease_linear_context &&
      source_release_command[laya_compute_portal_layout_v1::SOURCE_REF*8+:64]==
        source_lease_ref &&
      source_release_command[laya_compute_portal_layout_v1::A_REF*8+:64]==
        source_lease_a_ref &&
      source_release_command[laya_compute_portal_layout_v1::W_REF*8+:64]==
        source_lease_w_ref &&
      source_release_command[laya_compute_portal_layout_v1::PS_REF*8+:64]==
        source_lease_ps_ref &&
      source_release_command[laya_compute_portal_layout_v1::DST_REF*8+:64]==
        source_lease_dst_ref &&
      source_release_command[laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64]==
        source_lease_future_dst_ref &&
      source_release_command[laya_compute_portal_layout_v1::MODEL_IDENTITY*8+:3328]==
        owner_model_identity[source_lease_slot] &&
      source_release_command[laya_compute_portal_layout_v1::K*8+:16]==
        source_lease_k &&
      source_release_command[laya_compute_portal_layout_v1::ROWS*8+:8]==
        source_lease_rows &&
      source_release_command[laya_compute_portal_layout_v1::SOURCE_ROLE*8+:8]==
        source_lease_role &&
      source_release_command[laya_compute_portal_layout_v1::SOURCE_OFFSET*8+:64]==
        source_lease_offset &&
      source_release_command[laya_compute_portal_layout_v1::SOURCE_SPAN*8+:64]==
        source_lease_span &&
      source_release_command[laya_compute_portal_layout_v1::SOURCE_STRIDE*8+:64]==
        source_lease_stride &&
      source_release_command[laya_compute_portal_layout_v1::ROW_STRIDE*8+:64]==
        source_lease_row_stride &&
      source_release_command[laya_compute_portal_layout_v1::BATCH_STRIDE*8+:64]==
        source_lease_batch_stride;
  end

  function automatic logic [4095:0] make_response(
      input logic [8191:0] packet,input logic [15:0] status,
      input logic [31:0] detail,input logic [63:0] bad,
      input logic keep_scope,input logic drained,input logic published,
      input logic [63:0] observed0,input logic [63:0] observed1);
    logic [4095:0] result;
    logic [7:0] count;
    count=packet[DESCRIPTOR_COUNT*8+:8];result=0;
    result[MAGIC*8+:32]=RESPONSE_MAGIC;result[VER*8+:16]=VERSION;
    result[ACTION*8+:16]=packet[ACTION*8+:16];
    result[EVENT_SEQ*8+:64]=packet[EVENT_SEQ*8+:64];
    result[RESPONSE_ORIGIN_SEQ*8+:64]=packet[ORIGIN_SEQ*8+:64];
    result[RESPONSE_STATUS*8+:16]=status;
    result[RESPONSE_FLAGS*8+:8]=8'((drained?1:0) | (keep_scope?2:0) |
                                          (published?4:0));
    result[RESPONSE_DETAIL*8+:32]=detail;result[RESPONSE_BAD*8+:64]=bad;
    result[RESPONSE_DESCRIPTOR_COUNT*8+:8]=count;
    result[RESPONSE_IDENTITY*8+:672]=packet[IDENTITY*8+:672];
    result[RESPONSE_CONTEXT*8+:96]=packet[CONTEXT*8+:96];
    result[RESPONSE_TARGET0*8+:64]=packet[DESCRIPTOR0*8+:64];
    result[RESPONSE_OLD0*8+:64]=packet[(DESCRIPTOR0+8)*8+:64];
    if(count==2)begin
      result[RESPONSE_TARGET1*8+:64]=packet[DESCRIPTOR1*8+:64];
      result[RESPONSE_OLD1*8+:64]=packet[(DESCRIPTOR1+8)*8+:64];
    end
    if(packet[ACTION*8+:16]==END_EVENT)begin
      result[RESPONSE_OBSERVED0*8+:64]=observed0;
      result[RESPONSE_OBSERVED1*8+:64]=observed1;
      if(status==0)begin
        result[RESPONSE_ELEMENTS*8+:32]=packet[EXPECTED_ELEMENTS*8+:32];
        result[RESPONSE_UNIT*8+:8]=packet[EXPECTED_UNIT*8+:8];
      end
    end
    return result;
  endfunction

  task automatic reject(input logic [15:0] status,
                         input logic [31:0] detail,
                         input logic keep_scope,
                         input logic drained);
    response<=make_response(request,status,detail,64'hffffffffffffffff,
                            keep_scope,drained,0,0,0);
    response_valid<=1;semantic_rejections<=semantic_rejections+1'b1;
  endtask

  task automatic finish_end(
      input logic [8191:0] packet,
      input logic [15:0] observed_status,
      input logic [31:0] observed_detail,
      input logic [63:0] observed_bad,
      input logic [63:0] observed_bytes0,
      input logic [63:0] observed_bytes1,
      input logic observed_coverage);
    integer end_slot0,end_slot1,end_window;
    logic [7:0] end_count;
    logic [671:0] end_identity;
    logic [15:0] end_status;
    logic [31:0] end_detail;
    logic [63:0] end_bad;
    begin
      end_count=packet[DESCRIPTOR_COUNT*8+:8];
      end_identity=packet[IDENTITY*8+:672];
      end_status=observed_status;end_detail=observed_detail;
      end_bad=observed_bad;
      if(end_status==0 && packet[REPORTED_STATUS*8+:16]!=0)begin
        end_status=packet[REPORTED_STATUS*8+:16];
        end_detail=packet[REPORTED_DETAIL*8+:32];
        end_bad=packet[REPORTED_BAD*8+:64];
      end
      if(end_status==0 && !observed_coverage)begin
        end_status=E_BUFFER;end_detail=32'h04000008;
        end_bad=64'hffffffffffffffff;
      end
      if(end_status==0 &&
         (packet[ISSUED0*8+:64]!=packet[GEOMETRY0*8+32*8+:64] ||
          packet[ISSUED1*8+:64]!=
            (end_count==2 ? packet[GEOMETRY1*8+32*8+:64] : 0)))begin
        end_status=E_PROTOCOL;end_detail=32'h04000017;
        end_bad=64'hffffffffffffffff;
      end
      end_slot0=find_exact(end_identity,packet[DESCRIPTOR0*8+:1024]);
      end_slot1=-1;
      if(end_count==2)
        end_slot1=find_exact(end_identity,packet[DESCRIPTOR1*8+:1024]);
      end_window=-1;
      if(end_status==0 && end_slot0>=0 &&
         source_owner_supported(owner_descriptor[end_slot0]))begin
        if(end_count!=1 ||
           !source_window_event_ok(packet,owner_descriptor[end_slot0]))begin
          end_status=E_PROTOCOL;end_detail=32'h04000017;
          end_bad=64'hffffffffffffffff;
        end else begin
          end_window=source_window_index(packet[CONTEXT*8+:96],
                                         owner_descriptor[end_slot0]);
          if(end_window<0 || end_window>=128 ||
             owner_window_closed[end_slot0][end_window])begin
            end_status=E_PROTOCOL;end_detail=32'h04000017;
            end_bad=64'hffffffffffffffff;end_window=-1;
          end
        end
      end
      if(end_status!=0)begin
        if(end_slot0>=0)begin
          owner_invalid[end_slot0]<=1;owner_published[end_slot0]<=0;
        end
        if(end_count==2 && end_slot1>=0)begin
          owner_invalid[end_slot1]<=1;owner_published[end_slot1]<=0;
        end
      end else if(end_window>=0)begin
        owner_window_closed[end_slot0][end_window]<=1;
        owner_window_context[end_slot0][end_window]<=packet[CONTEXT*8+:96];
      end
      typed_last_task[active_typed_slot]<=packet[TASK*8+:32];
      scope_active<=0;active_begin<=0;terminal_tasks<=terminal_tasks+1'b1;
      response<=make_response(packet,end_status,end_detail,end_bad,
          0,1,0,observed_bytes0,observed_bytes1);
      response_valid<=1;
    end
  endtask

  task automatic finish_owner_event(
      input logic [8191:0] packet,
      input logic [15:0] observed_status,
      input logic [31:0] observed_detail,
      input logic [63:0] observed_bad,
      input logic observed_coverage);
    integer event_slot0,event_slot1;
    logic [7:0] event_count;
    logic [15:0] event_action,event_status;
    logic event_ok;
    begin
      event_count=packet[DESCRIPTOR_COUNT*8+:8];
      event_action=packet[ACTION*8+:16];
      event_slot0=find_exact(packet[IDENTITY*8+:672],
                             packet[DESCRIPTOR0*8+:1024]);
      event_slot1=-1;
      if(event_count==2)
        event_slot1=find_exact(packet[IDENTITY*8+:672],
                               packet[DESCRIPTOR1*8+:1024]);
      event_ok=event_slot0>=0 &&
               (event_count==1 || (event_slot1>=0 && event_slot1!=event_slot0));
      if(event_ok && observed_status==0)begin
        if(event_action==PUBLISH)
          event_ok=observed_coverage && !owner_published[event_slot0] &&
            !owner_invalid[event_slot0] &&
            (!source_owner_supported(owner_descriptor[event_slot0]) ||
             source_owner_complete(event_slot0)) &&
            (event_count==1 || (!owner_published[event_slot1] &&
                                !owner_invalid[event_slot1]));
        if(event_action==RELEASE)
          event_ok=owner_published[event_slot0] && !owner_invalid[event_slot0] &&
            (event_count==1 || (owner_published[event_slot1] &&
                                !owner_invalid[event_slot1]));
        if((event_action==RELEASE || event_action==INVALIDATE) &&
           source_lease_active &&
           (source_lease_slot==event_slot0 ||
            (event_count==2 && source_lease_slot==event_slot1)))
          event_ok=0;
      end else event_ok=0;
      event_status=observed_status!=0 ? observed_status :
                   event_ok ? 0 : E_BUFFER;
      if(!event_ok)begin
        response<=make_response(packet,event_status,
            observed_status!=0 ? observed_detail : 32'h04000008,
            observed_status!=0 ? observed_bad : 64'hffffffffffffffff,
            0,1,0,0,0);
        response_valid<=1;semantic_rejections<=semantic_rejections+1'b1;
      end else begin
        if(event_action==PUBLISH)begin
          owner_published[event_slot0]<=1;
          if(event_count==2)owner_published[event_slot1]<=1;
        end else begin
          owner_active[event_slot0]<=0;owner_published[event_slot0]<=0;
          owner_window_closed[event_slot0]<=0;
          if(event_action==INVALIDATE)owner_invalid[event_slot0]<=1;
          if(event_count==2)begin
            owner_active[event_slot1]<=0;owner_published[event_slot1]<=0;
            owner_window_closed[event_slot1]<=0;
            if(event_action==INVALIDATE)owner_invalid[event_slot1]<=1;
          end
        end
        response<=make_response(packet,0,0,64'hffffffffffffffff,
            0,1,event_action==PUBLISH,0,0);response_valid<=1;
      end
    end
  endtask

  always_ff @(posedge clk)begin : ledger_state
    integer slot0,slot1,typed_slot;
    logic [7:0] count;
    logic [1023:0] descriptor0,descriptor1;
    logic [671:0] identity;
    logic semantic_ok,new_identity;
    if(!rst_n)begin
      response_valid<=0;response<=0;scope_active<=0;active_begin<=0;
      active_typed_slot<=0;cancel_pending<=0;accepted_events<=0;
      semantic_rejections<=0;terminal_tasks<=0;
      admitted_identity_valid<=0;admitted_identity<=0;
      pending_end<=0;pending_end_request<=0;
      pending_physical_status<=0;pending_physical_detail<=0;
      pending_physical_bad<=64'hffffffffffffffff;
      source_lease_active<=0;source_lease_slot<=0;source_lease_identity<=0;
      source_lease_producer_context<=0;source_lease_quant_context<=0;
      source_lease_linear_context<=0;source_lease_ref<=0;
      source_lease_a_ref<=0;source_lease_w_ref<=0;source_lease_ps_ref<=0;
      source_lease_dst_ref<=0;source_lease_future_dst_ref<=0;
      source_lease_generation<=0;source_lease_offset<=0;source_lease_span<=0;
      source_lease_stride<=0;source_lease_row_stride<=0;
      source_lease_batch_stride<=0;source_lease_k<=0;source_lease_rows<=0;
      source_lease_role<=0;
      for(int i=0;i<OWNERS;i++)begin
        owner_valid[i]<=0;owner_active[i]<=0;owner_published[i]<=0;
        owner_invalid[i]<=0;owner_identity[i]<=0;owner_descriptor[i]<=0;
        owner_model_identity[i]<=0;owner_window_closed[i]<=0;
        owner_last_q_generation[i]<=0;
        owner_max_epoch[i]<=0;typed_valid[i]<=0;typed_identity[i]<=0;
        typed_last_task[i]<=0;
      end
    end else begin
      if(response_valid && response_ready)response_valid<=0;
      if(cancel)cancel_pending<=1;
      if(cancel_pending && !scope_active && !response_valid)begin
        for(int i=0;i<OWNERS;i++)begin
          if(owner_valid[i] && owner_active[i] &&
             !(ENABLE_BOOTSTRAP_SOURCE_GUARD && bootstrap_source_guard_active &&
               owner_identity[i]==bootstrap_source_guard_key[64*8+:672] &&
               owner_descriptor[i]==bootstrap_source_guard_key[576*8+:1024]))begin
            if(!source_lease_active)owner_active[i]<=0;
            owner_published[i]<=0;owner_invalid[i]<=1;
          end
        end
        if(!source_lease_active &&
           (!ENABLE_BOOTSTRAP_SOURCE_GUARD || !bootstrap_source_guard_active))cancel_pending<=0;
      end
      if(source_query_valid && source_query_ready && source_query_granted)begin
        slot0=find_source(
          source_query_command[laya_compute_portal_layout_v1::IDENTITY*8+:672],
          source_query_command[laya_compute_portal_layout_v1::SOURCE_REF*8+:64]);
        source_lease_active<=1;
        source_lease_slot<=slot0[$clog2(OWNERS)-1:0];
        source_lease_identity<=
          source_query_command[laya_compute_portal_layout_v1::IDENTITY*8+:672];
        source_lease_producer_context<=source_query_command[
          laya_compute_portal_layout_v1::PRODUCER_CONTEXT*8+:96];
        source_lease_quant_context<=source_query_command[
          laya_compute_portal_layout_v1::QUANT_CONTEXT*8+:96];
        source_lease_linear_context<=source_query_command[
          laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
        source_lease_ref<=source_query_command[
          laya_compute_portal_layout_v1::SOURCE_REF*8+:64];
        source_lease_a_ref<=source_query_command[
          laya_compute_portal_layout_v1::A_REF*8+:64];
        source_lease_w_ref<=source_query_command[
          laya_compute_portal_layout_v1::W_REF*8+:64];
        source_lease_ps_ref<=source_query_command[
          laya_compute_portal_layout_v1::PS_REF*8+:64];
        source_lease_dst_ref<=source_query_command[
          laya_compute_portal_layout_v1::DST_REF*8+:64];
        source_lease_future_dst_ref<=source_query_command[
          laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64];
        source_lease_generation<=source_query_command[
          laya_compute_portal_layout_v1::GENERATION*8+:64];
        source_lease_k<=source_query_command[
          laya_compute_portal_layout_v1::K*8+:16];
        source_lease_rows<=source_query_command[
          laya_compute_portal_layout_v1::ROWS*8+:8];
        source_lease_role<=source_query_command[
          laya_compute_portal_layout_v1::SOURCE_ROLE*8+:8];
        source_lease_offset<=source_query_command[
          laya_compute_portal_layout_v1::SOURCE_OFFSET*8+:64];
        source_lease_span<=source_query_command[
          laya_compute_portal_layout_v1::SOURCE_SPAN*8+:64];
        source_lease_stride<=source_query_command[
          laya_compute_portal_layout_v1::SOURCE_STRIDE*8+:64];
        source_lease_row_stride<=source_query_command[
          laya_compute_portal_layout_v1::ROW_STRIDE*8+:64];
        source_lease_batch_stride<=source_query_command[
          laya_compute_portal_layout_v1::BATCH_STRIDE*8+:64];
        owner_last_q_generation[slot0]<=source_query_command[
          laya_compute_portal_layout_v1::GENERATION*8+:64];
      end
      if(source_release_valid && source_release_ready)begin
        source_lease_active<=0;source_lease_identity<=0;
        source_lease_producer_context<=0;source_lease_quant_context<=0;
        source_lease_linear_context<=0;source_lease_ref<=0;
        source_lease_a_ref<=0;source_lease_w_ref<=0;source_lease_ps_ref<=0;
        source_lease_dst_ref<=0;source_lease_future_dst_ref<=0;
        source_lease_generation<=0;source_lease_offset<=0;source_lease_span<=0;
        source_lease_stride<=0;source_lease_row_stride<=0;
        source_lease_batch_stride<=0;source_lease_k<=0;source_lease_rows<=0;
        source_lease_role<=0;
      end
      if(pending_end && physical_observation_valid && !physical_drained &&
         !response_valid && pending_physical_status==0 && physical_status!=0)begin
        // The observation stream may report an error before the final fence.
        // Preserve the first such error while continuing to wait for drain.
        pending_physical_status<=physical_status;
        pending_physical_detail<=physical_error_detail;
        pending_physical_bad<=physical_bad_element;
      end
      if(pending_end && physical_observation_valid &&
         physical_drained && !response_valid)begin
        if(pending_end_request[ACTION*8+:16]==END_EVENT)begin
          if(physical_observed_store_bytes0!=
                pending_end_request[ISSUED0*8+:64] ||
             physical_observed_store_bytes1!=
                pending_end_request[ISSUED1*8+:64])begin
            response<=make_response(pending_end_request,E_PROTOCOL,
                32'h04000017,64'hffffffffffffffff,1,1,0,0,0);
            response_valid<=1;
            semantic_rejections<=semantic_rejections+1'b1;
          end else begin
            finish_end(pending_end_request,
                pending_physical_status!=0 ? pending_physical_status :
                                             physical_status,
                pending_physical_status!=0 ? pending_physical_detail :
                                             physical_error_detail,
                pending_physical_status!=0 ? pending_physical_bad :
                                             physical_bad_element,
                physical_observed_store_bytes0,
                physical_observed_store_bytes1,
                physical_coverage_complete);
          end
        end else begin
          finish_owner_event(pending_end_request,
              pending_physical_status!=0 ? pending_physical_status :
                                           physical_status,
              pending_physical_status!=0 ? pending_physical_detail :
                                           physical_error_detail,
              pending_physical_status!=0 ? pending_physical_bad :
                                           physical_bad_element,
              physical_coverage_complete);
        end
        pending_end<=0;pending_end_request<=0;
        pending_physical_status<=0;pending_physical_detail<=0;
        pending_physical_bad<=64'hffffffffffffffff;
      end
      if(request_valid && request_ready)begin
        accepted_events<=accepted_events+1'b1;
        count=request[DESCRIPTOR_COUNT*8+:8];
        descriptor0=request[DESCRIPTOR0*8+:1024];
        descriptor1=request[DESCRIPTOR1*8+:1024];
        identity=request[IDENTITY*8+:672];slot0=-1;slot1=-1;
        case(request_action)
          CLAIM:begin
            if(scope_active || !owner_descriptors_ok(request))
              reject(E_PROTOCOL,32'h04000017,0,1);
            else begin
              new_identity=!admitted_identity_valid ||
                           admitted_identity!=identity;
              if(new_identity && admitted_identity_valid &&
                 (active_owners!=0 ||
                  !identity_newer(identity,admitted_identity)))
                reject(E_PROTOCOL,32'h04000017,0,1);
              else begin
              slot0=find_physical(descriptor0);
              if(slot0<0)slot0=find_empty(-1);
              if(count==2)begin
                slot1=find_physical(descriptor1);
                if(slot1<0)slot1=find_empty(slot0);
              end
              semantic_ok=slot0>=0 && (count==1 || (slot1>=0 && slot1!=slot0));
              if(semantic_ok)begin
                if(descriptor0[8*8+:64]!=0)
                  semantic_ok=owner_active[slot0] && owner_published[slot0] &&
                    !owner_invalid[slot0] && owner_identity[slot0]==identity &&
                    owner_descriptor[slot0][0+:64]==descriptor0[8*8+:64] &&
                    descriptor0[0+:32]==descriptor0[8*8+:32]+1'b1;
                else if(owner_valid[slot0])
                  semantic_ok=!owner_active[slot0] &&
                    descriptor0[0+:32]>owner_max_epoch[slot0];
              end
              if(semantic_ok && count==2)begin
                if(descriptor1[8*8+:64]!=0)
                  semantic_ok=owner_active[slot1] && owner_published[slot1] &&
                    !owner_invalid[slot1] && owner_identity[slot1]==identity &&
                    owner_descriptor[slot1][0+:64]==descriptor1[8*8+:64] &&
                    descriptor1[0+:32]==descriptor1[8*8+:32]+1'b1;
                else if(owner_valid[slot1])
                  semantic_ok=!owner_active[slot1] &&
                    descriptor1[0+:32]>owner_max_epoch[slot1];
              end
              if(!semantic_ok)reject(E_BUFFER,32'h04000008,0,1);
              else begin
                if(new_identity)begin
                  admitted_identity_valid<=1;admitted_identity<=identity;
                  for(int i=0;i<OWNERS;i++)begin
                    typed_valid[i]<=0;typed_identity[i]<=0;
                    typed_last_task[i]<=0;
                  end
                end
                owner_valid[slot0]<=1;owner_active[slot0]<=1;
                owner_published[slot0]<=0;owner_invalid[slot0]<=0;
                owner_identity[slot0]<=identity;owner_descriptor[slot0]<=descriptor0;
                owner_model_identity[slot0]<=request[MODEL_IDENTITY*8+:3328];
                owner_window_closed[slot0]<=0;owner_last_q_generation[slot0]<=0;
                if(descriptor0[0+:32]>owner_max_epoch[slot0])
                  owner_max_epoch[slot0]<=descriptor0[0+:32];
                if(count==2)begin
                  owner_valid[slot1]<=1;owner_active[slot1]<=1;
                  owner_published[slot1]<=0;owner_invalid[slot1]<=0;
                  owner_identity[slot1]<=identity;owner_descriptor[slot1]<=descriptor1;
                  owner_model_identity[slot1]<=request[MODEL_IDENTITY*8+:3328];
                  owner_window_closed[slot1]<=0;owner_last_q_generation[slot1]<=0;
                  if(descriptor1[0+:32]>owner_max_epoch[slot1])
                    owner_max_epoch[slot1]<=descriptor1[0+:32];
                end
                response<=make_response(request,0,0,64'hffffffffffffffff,
                                        0,1,0,0,0);response_valid<=1;
              end
              end
            end
          end
          BEGIN_EVENT:begin
            typed_slot=find_typed(identity);
            if(typed_slot<0)typed_slot=find_empty_typed();
            slot0=find_exact(identity,descriptor0);
            if(count==2)slot1=find_exact(identity,descriptor1);
            semantic_ok=!scope_active && typed_slot>=0 && slot0>=0 &&
              (count==1 || slot1>=0) && begin_external_ready &&
              begin_external_supported;
            if(semantic_ok)semantic_ok=
              (!typed_valid[typed_slot] ||
               request[TASK*8+:32]>typed_last_task[typed_slot]) &&
              !owner_invalid[slot0] && !owner_published[slot0] &&
              (count==1 || (!owner_invalid[slot1] && !owner_published[slot1])) &&
              geometries_disjoint(request);
            if(!semantic_ok)reject(E_PROTOCOL,32'h04000017,0,1);
            else begin
              if(!typed_valid[typed_slot])begin
                typed_valid[typed_slot]<=1;typed_identity[typed_slot]<=identity;
                typed_last_task[typed_slot]<=0;
              end
              active_typed_slot<=typed_slot[$clog2(OWNERS)-1:0];
              active_begin<=request;scope_active<=1;
              response<=make_response(request,0,0,64'hffffffffffffffff,
                                      1,1,0,0,0);response_valid<=1;
            end
          end
          END_EVENT:begin
            if(!scope_active || !end_binding_ok(request,active_begin))
              reject(E_PROTOCOL,32'h04000017,scope_active,physical_drained);
            else if(!physical_drained)begin
              pending_end<=1;pending_end_request<=request;
              pending_physical_status<=physical_status;
              pending_physical_detail<=physical_error_detail;
              pending_physical_bad<=physical_bad_element;
            end else if(physical_observed_store_bytes0!=request[ISSUED0*8+:64] ||
                    physical_observed_store_bytes1!=request[ISSUED1*8+:64])
              reject(E_PROTOCOL,32'h04000017,1,1);
            else finish_end(request,physical_status,physical_error_detail,
                physical_bad_element,physical_observed_store_bytes0,
                physical_observed_store_bytes1,physical_coverage_complete);
          end
          PUBLISH,RELEASE,INVALIDATE:begin
            if(scope_active || !owner_descriptors_ok(request))
              reject(E_PROTOCOL,32'h04000017,scope_active,physical_drained);
            else if(!physical_drained)begin
              pending_end<=1;pending_end_request<=request;
              pending_physical_status<=physical_status;
              pending_physical_detail<=physical_error_detail;
              pending_physical_bad<=physical_bad_element;
            end
            else begin
              finish_owner_event(request,physical_status,physical_error_detail,
                  physical_bad_element,physical_coverage_complete);
            end
          end
          default:reject(E_PROTOCOL,32'h04000017,scope_active,!scope_active);
        endcase
      end
    end
  end
endmodule
