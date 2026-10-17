`timescale 1ns/1ps
// Pure v2 command decoder for the shared GEGLU/QUANT physical service.  It
// converts relative BO ranges to absolute addresses and rejects malformed
// ranges before the split datapath, WI reader, or full-A cache can see valid.
module laya_gate_quant_portal_decode_v1(
  input  logic [8191:0] service_command,
  input  logic [12:0][63:0] latched_bo_base,latched_bo_span,
  output logic g_command_ok,q_command_ok,q_gate_command_ok,
  output logic [671:0] numeric_identity,
  output logic [95:0] producer_context,quant_context,linear_context,
  output logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref,future_dst_ref,
  output logic a_slot,
  output logic [31:0] a_slot_epoch,
  output logic [6:0] window,
  output logic [7:0] source_role,output_role,gate_region,dst_region,
  output logic [63:0] source_bo_base,source_bo_span,
  output logic [63:0] source_region_base,source_region_span,
  output logic [63:0] output_bo_base,output_bo_span,
  output logic [63:0] output_region_base,output_region_span,
  output logic [327:0] output_binding
);
  import laya_compute_portal_layout_v1::*;
  logic [15:0] service,k,n,b,s;
  logic [7:0] rows,row_space,batch;
  logic [15:0] row0;
  logic [63:0] source_offset,source_span,source_stride,row_stride,batch_stride;
  logic [63:0] output_declared_span,output_offset,output_span;
  logic [64:0] source_offset_end,source_absolute,source_absolute_end,source_physical_end;
  logic [64:0] output_offset_end,output_absolute,output_absolute_end,output_physical_end;
  logic [127:0] source_first,source_last,output_first,output_last;
  logic [127:0] expected_source_stride,expected_source_batch;
  logic source_range_ok,output_range_ok,q_source_ok;

  always_comb begin
    service=service_command[OP_STATUS*8+:16];
    numeric_identity=service_command[IDENTITY*8+:672];
    producer_context=service_command[PRODUCER_CONTEXT*8+:96];
    quant_context=service_command[QUANT_CONTEXT*8+:96];
    linear_context=service_command[LINEAR_CONTEXT*8+:96];
    source_ref=service_command[SOURCE_REF*8+:64];
    a_ref=service_command[A_REF*8+:64];
    w_ref=service_command[W_REF*8+:64];
    ps_ref=service_command[PS_REF*8+:64];
    dst_ref=service_command[DST_REF*8+:64];
    future_dst_ref=service_command[FUTURE_DST_REF*8+:64];
    a_slot=service_command[A_SLOT*8];
    a_slot_epoch=service_command[A_EPOCH*8+:32];
    k=service_command[K*8+:16];n=service_command[N*8+:16];
    rows=service_command[ROWS*8+:8];row_space=quant_context[71:64];
    batch=quant_context[63:56];row0=quant_context[87:72];
    b=numeric_identity[143:128];s=numeric_identity[159:144];
    source_role=service_command[SOURCE_ROLE*8+:8];
    output_role=service_command[OUT0_ROLE*8+:8];
    gate_region=dst_ref[55:48];dst_region=future_dst_ref[55:48];
    source_offset=service_command[SOURCE_OFFSET*8+:64];
    source_span=service_command[SOURCE_SPAN*8+:64];
    source_stride=service_command[SOURCE_STRIDE*8+:64];
    row_stride=service_command[ROW_STRIDE*8+:64];
    batch_stride=service_command[BATCH_STRIDE*8+:64];
    output_declared_span=service_command[OUTPUT_RANGES*8+:64];
    output_offset=service_command[(OUTPUT_RANGES+8)*8+:64];
    output_span=service_command[(OUTPUT_RANGES+16)*8+:64];
    source_bo_base=0;source_bo_span=0;output_bo_base=0;output_bo_span=0;
    if(source_role<=12)begin
      source_bo_base=latched_bo_base[source_role];
      source_bo_span=latched_bo_span[source_role];
    end
    if(output_role<=12)begin
      output_bo_base=latched_bo_base[output_role];
      output_bo_span=latched_bo_span[output_role];
    end
    source_offset_end={1'b0,source_offset}+{1'b0,source_span};
    source_absolute={1'b0,source_bo_base}+{1'b0,source_offset};
    source_absolute_end=source_absolute+{1'b0,source_span};
    source_physical_end={1'b0,source_bo_base}+{1'b0,source_bo_span};
    source_region_base=source_absolute[63:0];source_region_span=source_span;
    output_offset_end={1'b0,output_offset}+{1'b0,output_span};
    output_absolute={1'b0,output_bo_base}+{1'b0,output_offset};
    output_absolute_end=output_absolute+{1'b0,output_span};
    output_physical_end={1'b0,output_bo_base}+{1'b0,output_bo_span};
    output_region_base=output_absolute[63:0];output_region_span=output_span;
    expected_source_stride=128'(k)*4;
    expected_source_batch=expected_source_stride*(row_space==0 ? 1024 : row_space==1 ? 16 : 1);
    if(service==4)begin
      expected_source_stride=128'(k)*8;
      expected_source_batch=expected_source_stride*1024;
    end
    source_first=128'(source_region_base)+128'(batch)*expected_source_batch+
      128'(row0)*expected_source_stride;
    source_last=source_first+128'(rows)*expected_source_stride;
    output_first=128'(output_region_base)+128'(producer_context[63:56])*128'(batch_stride)+
      128'(producer_context[87:72])*128'(row_stride);
    output_last=output_first+128'(rows)*128'(row_stride);
    source_range_ok=source_role<=12 && source_bo_span!=0 && source_span!=0 &&
      !source_offset_end[64] && !source_absolute[64] && !source_absolute_end[64] &&
      !source_physical_end[64] && source_offset_end<={1'b0,source_bo_span} &&
      source_absolute_end<=source_physical_end && source_first[127:64]==0 &&
      source_last[127:64]==0 && source_first[5:0]==0 &&
      source_first>=128'(source_region_base) &&
      source_last<=128'(source_absolute_end);
    output_range_ok=output_role<=12 && output_bo_span!=0 && output_span!=0 &&
      output_declared_span==output_bo_span && !output_offset_end[64] &&
      !output_absolute[64] && !output_absolute_end[64] && !output_physical_end[64] &&
      output_offset_end<={1'b0,output_bo_span} && output_absolute_end<=output_physical_end &&
      output_first[127:64]==0 && output_last[127:64]==0 && output_first[5:0]==0 &&
      output_first>=128'(output_region_base) && output_last<=128'(output_absolute_end);
    window=7'(quant_context[63:56])*7'((numeric_identity[159:144]+15)/16)+
      7'(quant_context[87:72]>>4);
    output_binding={output_role,service_command[OUTPUT_RANGES*8+:192],row_stride,batch_stride};
    q_source_ok=0;
    case(quant_context[47:40])
      2:q_source_ok=row_space==0 &&
        ((k==1024 && (source_ref[39:32]==1 || source_ref[39:32]==2 || source_ref[39:32]==8)) ||
         (k==2624 && source_ref[39:32]==7));
      4:q_source_ok=row_space==0 &&
        ((k==1024 && (source_ref[39:32]==1 || source_ref[39:32]==2 || source_ref[39:32]==8)) ||
         (k==4096 && source_ref[39:32]==9));
      5:q_source_ok=row_space==1 && k==1024 && source_ref[39:32]==10 && source_ref[55:48]==0;
      6:q_source_ok=row_space==2 && k==256 && source_ref[39:32]==10 && source_ref[55:48]==2;
      default:q_source_ok=0;
    endcase

    g_command_ok=command_frame_ok(service_command) && service==4 &&
      service_command[CONTEXT*8+:96]==producer_context && k==2624 && n==1024 &&
      rows==producer_context[95:88] && service_command[ROW_BLOCK*8+:8]==0 &&
      source_role==10 && output_role==11 && source_ref[39:32]==6 && dst_ref[39:32]==7 &&
      source_stride==64'd20992 && row_stride==64'd10496 && batch_stride==64'd10747904 &&
      source_range_ok && output_range_ok;
    q_command_ok=command_frame_ok(service_command) && service==2 &&
      service_command[CONTEXT*8+:96]==quant_context &&
      rows==quant_context[95:88] && service_command[ROW_BLOCK*8+:8]==0 && q_source_ok &&
      source_stride==expected_source_stride && row_stride==expected_source_stride &&
      batch_stride==expected_source_batch && source_range_ok;
    q_gate_command_ok=q_command_ok && k==2624 && n==1024 &&
      source_ref[39:32]==7 && source_role==11 && producer_context[39:32]==8'h60 &&
      linear_context[39:32]==8'h33;
  end
endmodule
