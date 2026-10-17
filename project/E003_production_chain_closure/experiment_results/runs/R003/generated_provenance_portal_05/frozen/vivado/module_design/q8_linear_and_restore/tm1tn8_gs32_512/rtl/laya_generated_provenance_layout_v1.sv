`timescale 1ns/1ps
package laya_generated_provenance_layout_v1;
  localparam logic [31:0] REQUEST_MAGIC=32'h3156504c;
  localparam logic [31:0] RESPONSE_MAGIC=32'h3141504c;
  localparam int VERSION=1,REQUEST_BYTES=1024,RESPONSE_BYTES=512;
  localparam int REQUEST_BEATS=16,RESPONSE_BEATS=8;
  localparam int MAGIC=0,VER=4,ACTION=6,EVENT_SEQ=8,TASK=16;
  localparam int COMMAND_BEATS=24,RSP_BEATS=26,ORIGIN_SEQ=32;
  localparam int REPORTED_STATUS=40,REPORTED_UNIT=42,REPORTED_ELEMENTS=44;
  localparam int REPORTED_DETAIL=48,REPORTED_BAD=56,IDENTITY=64,CONTEXT=148;
  localparam int MODEL_IDENTITY=160,DESCRIPTOR_COUNT=576,EXPECTED_UNIT=578;
  localparam int EXPECTED_ELEMENTS=580,ISSUED0=584,ISSUED1=592;
  localparam int DESCRIPTOR0=608,DESCRIPTOR1=736,GEOMETRY0=864,GEOMETRY1=928;
  localparam int RESPONSE_STATUS=24,RESPONSE_FLAGS=26,RESPONSE_DETAIL=28;
  localparam int RESPONSE_BAD=32,RESPONSE_ELEMENTS=40,RESPONSE_UNIT=44;
  localparam int RESPONSE_DESCRIPTOR_COUNT=45,RESPONSE_OBSERVED0=48;
  localparam int RESPONSE_OBSERVED1=56,RESPONSE_IDENTITY=64;
  localparam int RESPONSE_CONTEXT=148,RESPONSE_TARGET0=160;
  localparam int RESPONSE_OLD0=168,RESPONSE_TARGET1=176,RESPONSE_OLD1=184;
  localparam logic [15:0] E_ABI=1,E_MODEL=2,E_BUFFER=5,
      E_NUMERICAL=6,E_PROTOCOL=7,E_INTERNAL=8;
  localparam logic [15:0] CLAIM=1,BEGIN_EVENT=2,END_EVENT=3,
      PUBLISH=4,RELEASE=5,INVALIDATE=6;

  function automatic logic bytes_zero(input logic [8191:0] p,
      input int first,input int after);
    logic valid;
    valid=1;
    for(int i=first;i<after;i++)valid=valid && p[i*8+:8]==0;
    return valid;
  endfunction

  function automatic logic response_bytes_zero(input logic [4095:0] p,
      input int first,input int after);
    logic valid;
    valid=1;
    for(int i=first;i<after;i++)valid=valid && p[i*8+:8]==0;
    return valid;
  endfunction

  function automatic logic action_ok(input logic [15:0] action);
    return action>=CLAIM && action<=INVALIDATE;
  endfunction

  function automatic logic identity_ok(input logic [671:0] identity);
    logic [15:0] b,s;
    b=identity[16*8+:16];s=identity[18*8+:16];
    return identity[0+:64]!=0 && identity[8*8+:64]!=0 &&
      b>=1 && b<=2 && (s==64 || s==128 || s==256 || s==512 || s==1024);
  endfunction

  function automatic logic zero_context(input logic [95:0] context_bits);
    return context_bits==0;
  endfunction

  function automatic logic descriptor_ok(input logic [1023:0] descriptor);
    logic [63:0] target_ref,old_ref;
    logic [63:0] bo_span,base,extent,head_stride,plane_stride;
    logic [7:0] layout;
    target_ref=descriptor[0+:64];old_ref=descriptor[8*8+:64];
    layout=descriptor[27*8+:8];bo_span=descriptor[32*8+:64];
    base=descriptor[40*8+:64];extent=descriptor[64*8+:64];
    head_stride=descriptor[72*8+:64];plane_stride=descriptor[80*8+:64];
    return target_ref[32+:8]!=0 &&
      laya_compute_portal_layout_v1::ref_ok(target_ref) &&
      (old_ref==0 || laya_compute_portal_layout_v1::ref_ok(old_ref)) &&
      descriptor[19*8+:8]<=2 && descriptor[22*8+:16]!=0 &&
      descriptor[24*8+:16]!=0 && descriptor[26*8+:8]<=7 &&
      layout<=1 && descriptor[28*8+:8]<=12 && bo_span!=0 && extent!=0 &&
      base<=bo_span && extent<=bo_span-base &&
      ((layout==0 && head_stride==0 && plane_stride==0) ||
       (layout==1 && head_stride!=0 && plane_stride!=0)) &&
      descriptor[7*8+:8]==0 && descriptor[15*8+:8]==0 &&
      descriptor[29*8+:24]==0 && descriptor[88*8+:320]==0;
  endfunction

  function automatic logic geometry_ok(input logic [511:0] geometry);
    logic [31:0] segment;
    logic [15:0] rows,repeats;
    logic [63:0] row_step,repeat_step,total,calculated;
    logic [7:0] component,head,plane;
    segment=geometry[8*8+:32];rows=geometry[12*8+:16];
    repeats=geometry[14*8+:16];row_step=geometry[16*8+:64];
    repeat_step=geometry[24*8+:64];total=geometry[32*8+:64];
    component=geometry[40*8+:8];head=geometry[41*8+:8];
    plane=geometry[42*8+:8];
    calculated=64'(segment)*64'(rows)*64'(repeats);
    return segment!=0 && segment[1:0]==0 && rows!=0 && repeats!=0 &&
      ((rows==1)==(row_step==0)) && ((repeats==1)==(repeat_step==0)) &&
      total==calculated && component<=2 &&
      ((component==0 && head==255 && plane==0) ||
       (component==1 && head<16 && plane==0) ||
       (component==2 && head<16 && plane!=0 && plane[7:3]==0)) &&
      geometry[43*8+:168]==0;
  endfunction

  function automatic logic request_header_ok(input logic [511:0] header);
    logic [15:0] action,status;
    logic [63:0] sequence_value,origin;
    logic [31:0] task_id;
    action=header[ACTION*8+:16];sequence_value=header[EVENT_SEQ*8+:64];
    task_id=header[TASK*8+:32];origin=header[ORIGIN_SEQ*8+:64];
    status=header[REPORTED_STATUS*8+:16];
    if(header[MAGIC*8+:32]!=REQUEST_MAGIC ||
       header[VER*8+:16]!=VERSION || !action_ok(action) || sequence_value==0 ||
       header[COMMAND_BEATS*8+:16]!=REQUEST_BEATS ||
       header[RSP_BEATS*8+:16]!=RESPONSE_BEATS ||
       header[20*8+:32]!=0 || header[28*8+:32]!=0 || header[43*8+:8]!=0 ||
       header[52*8+:32]!=0)return 0;
    if(action==CLAIM || action==PUBLISH || action==RELEASE ||
       action==INVALIDATE)
      return task_id==0 && origin==0 && status==0 &&
        header[REPORTED_UNIT*8+:8]==0 &&
        header[REPORTED_ELEMENTS*8+:32]==0 &&
        header[REPORTED_DETAIL*8+:32]==0 && header[REPORTED_BAD*8+:64]==0;
    if(task_id==0 || task_id==32'hffffffff)return 0;
    if(action==BEGIN_EVENT)
      return origin==sequence_value && status==0 && header[REPORTED_UNIT*8+:8]==0 &&
        header[REPORTED_ELEMENTS*8+:32]==0 &&
        header[REPORTED_DETAIL*8+:32]==0 && header[REPORTED_BAD*8+:64]==0;
    return origin!=0 && origin!=sequence_value && status<=E_INTERNAL &&
      header[REPORTED_UNIT*8+:8]<=3;
  endfunction

  function automatic logic request_frame_ok(input logic [8191:0] packet);
    logic valid,task_event;
    logic [15:0] action,status,b,s;
    logic [7:0] count;
    logic [95:0] context_bits;
    action=packet[ACTION*8+:16];status=packet[REPORTED_STATUS*8+:16];
    count=packet[DESCRIPTOR_COUNT*8+:8];context_bits=packet[CONTEXT*8+:96];
    b=packet[(IDENTITY+16)*8+:16];s=packet[(IDENTITY+18)*8+:16];
    task_event=action==BEGIN_EVENT || action==END_EVENT;
    valid=request_header_ok(packet[0+:512]) &&
      identity_ok(packet[IDENTITY*8+:672]) && count>=1 && count<=2 &&
      packet[577*8+:8]==0 && packet[579*8+:8]==0 &&
      packet[600*8+:64]==0 && bytes_zero(packet,992,1024) &&
      descriptor_ok(packet[DESCRIPTOR0*8+:1024]);
    if(count==2)valid=valid && descriptor_ok(packet[DESCRIPTOR1*8+:1024]);
    else valid=valid && bytes_zero(packet,DESCRIPTOR1,GEOMETRY0) &&
                     bytes_zero(packet,GEOMETRY1,992);
    if(task_event)begin
      valid=valid && laya_compute_portal_layout_v1::context_ok(context_bits,b,s) &&
        packet[TASK*8+:32]==context_bits[0+:32] &&
        packet[EXPECTED_UNIT*8+:8]==1 &&
        packet[EXPECTED_ELEMENTS*8+:32]!=0 &&
        geometry_ok(packet[GEOMETRY0*8+:512]);
      if(count==2)valid=valid && geometry_ok(packet[GEOMETRY1*8+:512]);
      if(action==BEGIN_EVENT)
        valid=valid && packet[ISSUED0*8+:128]==0;
      else if(status==0)
        valid=valid && packet[REPORTED_UNIT*8+:8]==packet[EXPECTED_UNIT*8+:8] &&
          packet[REPORTED_ELEMENTS*8+:32]==packet[EXPECTED_ELEMENTS*8+:32];
      else valid=valid && packet[REPORTED_UNIT*8+:8]==0 &&
                           packet[REPORTED_ELEMENTS*8+:32]==0;
    end else begin
      valid=valid && zero_context(context_bits) && packet[ORIGIN_SEQ*8+:64]==0 &&
        packet[REPORTED_STATUS*8+:16]==0 &&
        packet[REPORTED_UNIT*8+:8]==0 &&
        packet[REPORTED_ELEMENTS*8+:32]==0 &&
        packet[REPORTED_DETAIL*8+:32]==0 && packet[REPORTED_BAD*8+:64]==0 &&
        packet[EXPECTED_UNIT*8+:8]==0 &&
        packet[EXPECTED_ELEMENTS*8+:32]==0 && packet[ISSUED0*8+:128]==0 &&
        bytes_zero(packet,GEOMETRY0,992);
    end
    return valid;
  endfunction

  function automatic logic response_binding_ok(input logic [4095:0] response,
      input logic [8191:0] request);
    logic valid,scope_expected,publish_expected;
    logic [15:0] action,status;
    logic [7:0] count,flags;
    action=request[ACTION*8+:16];status=response[RESPONSE_STATUS*8+:16];
    count=request[DESCRIPTOR_COUNT*8+:8];flags=response[RESPONSE_FLAGS*8+:8];
    scope_expected=action==BEGIN_EVENT && status==0;
    publish_expected=action==PUBLISH && status==0;
    valid=response[0+:32]==RESPONSE_MAGIC &&
      response[VER*8+:16]==VERSION && response[ACTION*8+:16]==action &&
      response[EVENT_SEQ*8+:64]==request[EVENT_SEQ*8+:64] &&
      response[ORIGIN_SEQ*8+:64]==request[ORIGIN_SEQ*8+:64] &&
      status<=E_INTERNAL && flags[0] && flags[7:3]==0 &&
      (action==END_EVENT && status!=0 ? 1'b1 : flags[1]==scope_expected) &&
      flags[2]==publish_expected && response[27*8+:8]==0 &&
      response[RESPONSE_UNIT*8+:8]<=3 &&
      response[RESPONSE_DESCRIPTOR_COUNT*8+:8]==count &&
      response[46*8+:16]==0 && response[RESPONSE_IDENTITY*8+:672]==
        request[IDENTITY*8+:672] && response[RESPONSE_CONTEXT*8+:96]==
        request[CONTEXT*8+:96] && response_bytes_zero(response,192,512);
    valid=valid && response[RESPONSE_TARGET0*8+:64]==
        request[DESCRIPTOR0*8+:64] && response[RESPONSE_OLD0*8+:64]==
        request[(DESCRIPTOR0+8)*8+:64];
    if(count==2)valid=valid && response[RESPONSE_TARGET1*8+:64]==
        request[DESCRIPTOR1*8+:64] && response[RESPONSE_OLD1*8+:64]==
        request[(DESCRIPTOR1+8)*8+:64];
    else valid=valid && response[RESPONSE_TARGET1*8+:128]==0 &&
                     response[RESPONSE_OBSERVED1*8+:64]==0;
    if(action==END_EVENT && status==0)
      valid=valid && response[RESPONSE_ELEMENTS*8+:32]==
          request[EXPECTED_ELEMENTS*8+:32] && response[RESPONSE_UNIT*8+:8]==
          request[EXPECTED_UNIT*8+:8] && response[RESPONSE_OBSERVED0*8+:64]==
          request[ISSUED0*8+:64] && response[RESPONSE_OBSERVED1*8+:64]==
          request[ISSUED1*8+:64];
    else valid=valid && response[RESPONSE_ELEMENTS*8+:32]==0 &&
                         response[RESPONSE_UNIT*8+:8]==0 &&
        (action==END_EVENT || response[RESPONSE_OBSERVED0*8+:128]==0);
    return valid;
  endfunction

  function automatic logic [4095:0] rejected_response(
      input logic [8191:0] request,input logic [15:0] status,
      input logic [31:0] detail,input logic scope_active);
    logic [4095:0] response;
    logic [7:0] count;
    count=request[DESCRIPTOR_COUNT*8+:8];response=0;
    response[MAGIC*8+:32]=RESPONSE_MAGIC;
    response[VER*8+:16]=VERSION;response[ACTION*8+:16]=request[ACTION*8+:16];
    response[EVENT_SEQ*8+:64]=request[EVENT_SEQ*8+:64];
    response[ORIGIN_SEQ*8+:64]=request[ORIGIN_SEQ*8+:64];
    response[RESPONSE_STATUS*8+:16]=status;
    response[RESPONSE_FLAGS*8+:8]=8'(1 | (scope_active ? 2 : 0));
    response[RESPONSE_DETAIL*8+:32]=detail;
    response[RESPONSE_BAD*8+:64]='1;
    response[RESPONSE_DESCRIPTOR_COUNT*8+:8]=count;
    response[RESPONSE_IDENTITY*8+:672]=request[IDENTITY*8+:672];
    response[RESPONSE_CONTEXT*8+:96]=request[CONTEXT*8+:96];
    response[RESPONSE_TARGET0*8+:64]=request[DESCRIPTOR0*8+:64];
    response[RESPONSE_OLD0*8+:64]=request[(DESCRIPTOR0+8)*8+:64];
    if(count==2)begin
      response[RESPONSE_TARGET1*8+:64]=request[DESCRIPTOR1*8+:64];
      response[RESPONSE_OLD1*8+:64]=request[(DESCRIPTOR1+8)*8+:64];
    end
    return response;
  endfunction
endpackage
