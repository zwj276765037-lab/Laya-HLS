`timescale 1ns/1ps
// Default mode preserves the frozen E014 opaque96-bit-tag implementation.
// Canonical/external mode is an explicit production interface with no shadow q.
module laya_m007_layernorm32_v1 #(parameter bit CANONICAL_TAGS=0,EXTERNAL_CONTROL=0)(

 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,input logic[63:0]cmd_request_id,
 input logic[31:0]cmd_generation,cmd_epoch,input logic[7:0]cmd_rows,
 input logic cmd_gamma,input logic[63:0]cmd_model,input logic[31:0]cmd_key,
 input logic gamma_begin_valid,output logic gamma_begin_ready,input logic[63:0]gamma_model,
 input logic[31:0]gamma_key,input logic gamma_valid,output logic gamma_ready,
 input logic[4:0]gamma_chunk,input logic[31:0][31:0]gamma_data,
 output logic gamma_done_valid,input logic gamma_done_ready,output logic gamma_done_error,
 output logic gamma_loaded,
 input logic in_valid,output logic in_ready,input logic[63:0]in_request_id,
 input logic[31:0]in_generation,in_epoch,input logic[6:0]in_row,input logic[4:0]in_chunk,
 input logic[95:0]in_tag,input logic[31:0][31:0]in_data,
 output logic out_valid,input logic out_ready,output logic[63:0]out_request_id,
 output logic[31:0]out_generation,out_epoch,output logic[6:0]out_row,
 output logic[4:0]out_chunk,output logic[95:0]out_tag,output logic[31:0][31:0]out_data,
 output logic done_valid,input logic done_ready,output logic done_error,
 output logic[4:0]error_stage,output logic[3:0]error_level,output logic[6:0]error_row,output logic[9:0]error_node,
 output logic reject_valid,output logic[3:0]reject_code,output logic active,debt_clear,
 output logic[63:0]op_request_id,output logic[31:0]op_generation,op_epoch,
 output logic mul_req_valid,input logic mul_req_ready,output logic[95:0]mul_req_tag,
 output logic[255:0][31:0]mul_a,mul_b,input logic mul_rsp_valid,
 output logic mul_rsp_ready,input logic[95:0]mul_rsp_tag,input logic[255:0][31:0]mul_rsp_data,
 input logic[6:0]mul_pending,
 output logic add_req_valid,input logic add_req_ready,output logic[95:0]add_req_tag,
 output logic[255:0][31:0]add_a,add_b,input logic add_rsp_valid,
 output logic add_rsp_ready,input logic[95:0]add_rsp_tag,input logic[255:0][31:0]add_rsp_data,
 input logic[6:0]add_pending,
 output logic div_req_valid,input logic div_req_ready,output logic[95:0]div_req_tag,
 output logic[31:0]div_a,div_b,input logic div_rsp_valid,output logic div_rsp_ready,
 input logic[95:0]div_rsp_tag,input logic[31:0]div_rsp_data,input logic div_rsp_error,
 input logic[5:0]div_pending,
 output logic wr_valid,input logic wr_ready,output logic[255:0]wr_mask,
 output logic[255:0][4:0]wr_addr,output logic[255:0][31:0]wr_data,output logic[95:0]wr_tag,
 input logic wr_rsp_valid,output logic wr_rsp_ready,input logic[95:0]wr_rsp_tag,
 output logic rd_valid,input logic rd_ready,output logic[255:0]rd_mask,
 output logic[255:0][4:0]rd_addr,output logic[95:0]rd_tag,
 input logic rd_rsp_valid,output logic rd_rsp_ready,input logic[255:0][31:0]rd_rsp_data,
 input logic[95:0]rd_rsp_tag,input logic bank_idle,
 output logic trace_add_valid,output logic[175:0]trace_add_meta,
 output logic trace_mul_valid,output logic[23:0]trace_mul_meta,
 output logic[6:0]trace_scalar_valid,output logic[6:0][1:0]trace_scalar_ctx,
 output logic[6:0][31:0]trace_scalar_data,
 output logic trace_row_start,output logic[6:0]trace_row,
 output logic[3:0]ctx_active,output logic[3:0][6:0]ctx_row,
 output logic[3:0][31:0]raw_coverage,delta_coverage,
 output logic[31:0]cycle_count,output logic[6:0]peak_add_pending,peak_mul_pending,
 input logic control_enable,control_clear,input logic[12287:0]control_q,
 output logic[12287:0]control_next,output logic control_retired,
 input logic reject_ready,input logic cancel_valid,output logic cancel_ready,
 input logic[63:0]cancel_request_id,input logic[31:0]cancel_generation,cancel_epoch,
 output logic[1:0]done_kind,output logic cancel_rsp_valid,
 output logic protocol_fault,output logic[3:0]protocol_code,output logic[7:0]protocol_location,
 output logic[1:0]error_class,output logic[3:0]error_check,
 input logic cmd_source_finite_qualified,cmd_source_summary_valid,cmd_source_bad_valid,
 input logic[6:0]cmd_source_bad_row,input logic[9:0]cmd_source_bad_element
);
 generate if(!CANONICAL_TAGS)begin:legacy_mode
  if(EXTERNAL_CONTROL)begin:invalid_configuration
   initial $fatal(1,"EXTERNAL_CONTROL_REQUIRES_CANONICAL_TAGS");
  end
  laya_m007_layernorm32_legacy_v1 legacy_unit(.*);
  assign control_next=control_q;assign control_retired=1'b0;
  assign cancel_ready=1'b0;assign cancel_rsp_valid=1'b0;
  assign done_kind=done_error?2'd1:2'd0;
  assign protocol_fault=1'b0;assign protocol_code=0;assign protocol_location=0;
  assign error_class=0;assign error_check=0;
 end else begin:canonical_mode
  laya_m007_layernorm32_compact_v2 #(.EXTERNAL_CONTROL(EXTERNAL_CONTROL)) compact_unit(.*);
 end endgenerate
endmodule

`timescale 1ns/1ps
// Pure four-context LN controller. All vector arithmetic and row payload use
// public ports of the sole shared256 FP / DIV8 / LN-exp resources.
module laya_m007_layernorm32_legacy_v1(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,input logic[63:0]cmd_request_id,
 input logic[31:0]cmd_generation,cmd_epoch,input logic[7:0]cmd_rows,
 input logic cmd_gamma,input logic[63:0]cmd_model,input logic[31:0]cmd_key,
 input logic gamma_begin_valid,output logic gamma_begin_ready,input logic[63:0]gamma_model,
 input logic[31:0]gamma_key,input logic gamma_valid,output logic gamma_ready,
 input logic[4:0]gamma_chunk,input logic[31:0][31:0]gamma_data,
 output logic gamma_done_valid,input logic gamma_done_ready,output logic gamma_done_error,
 output logic gamma_loaded,
 input logic in_valid,output logic in_ready,input logic[63:0]in_request_id,
 input logic[31:0]in_generation,in_epoch,input logic[6:0]in_row,input logic[4:0]in_chunk,
 input logic[95:0]in_tag,input logic[31:0][31:0]in_data,
 output logic out_valid,input logic out_ready,output logic[63:0]out_request_id,
 output logic[31:0]out_generation,out_epoch,output logic[6:0]out_row,
 output logic[4:0]out_chunk,output logic[95:0]out_tag,output logic[31:0][31:0]out_data,
 output logic done_valid,input logic done_ready,output logic done_error,
 output logic[4:0]error_stage,output logic[3:0]error_level,output logic[6:0]error_row,output logic[9:0]error_node,
 output logic reject_valid,output logic[3:0]reject_code,output logic active,debt_clear,
 output logic[63:0]op_request_id,output logic[31:0]op_generation,op_epoch,
 output logic mul_req_valid,input logic mul_req_ready,output logic[95:0]mul_req_tag,
 output logic[255:0][31:0]mul_a,mul_b,input logic mul_rsp_valid,
 output logic mul_rsp_ready,input logic[95:0]mul_rsp_tag,input logic[255:0][31:0]mul_rsp_data,
 input logic[6:0]mul_pending,
 output logic add_req_valid,input logic add_req_ready,output logic[95:0]add_req_tag,
 output logic[255:0][31:0]add_a,add_b,input logic add_rsp_valid,
 output logic add_rsp_ready,input logic[95:0]add_rsp_tag,input logic[255:0][31:0]add_rsp_data,
 input logic[6:0]add_pending,
 output logic div_req_valid,input logic div_req_ready,output logic[95:0]div_req_tag,
 output logic[31:0]div_a,div_b,input logic div_rsp_valid,output logic div_rsp_ready,
 input logic[95:0]div_rsp_tag,input logic[31:0]div_rsp_data,input logic div_rsp_error,
 input logic[5:0]div_pending,
 output logic wr_valid,input logic wr_ready,output logic[255:0]wr_mask,
 output logic[255:0][4:0]wr_addr,output logic[255:0][31:0]wr_data,output logic[95:0]wr_tag,
 input logic wr_rsp_valid,output logic wr_rsp_ready,input logic[95:0]wr_rsp_tag,
 output logic rd_valid,input logic rd_ready,output logic[255:0]rd_mask,
 output logic[255:0][4:0]rd_addr,output logic[95:0]rd_tag,
 input logic rd_rsp_valid,output logic rd_rsp_ready,input logic[255:0][31:0]rd_rsp_data,
 input logic[95:0]rd_rsp_tag,input logic bank_idle,
 output logic trace_add_valid,output logic[175:0]trace_add_meta,
 output logic trace_mul_valid,output logic[23:0]trace_mul_meta,
 output logic[6:0]trace_scalar_valid,output logic[6:0][1:0]trace_scalar_ctx,
 output logic[6:0][31:0]trace_scalar_data,
 output logic trace_row_start,output logic[6:0]trace_row,
 output logic[3:0]ctx_active,output logic[3:0][6:0]ctx_row,
 output logic[3:0][31:0]raw_coverage,delta_coverage,
 output logic[31:0]cycle_count,output logic[6:0]peak_add_pending,peak_mul_pending
);
 typedef logic[7:0] item_t; // {valid, context, chunk/node}
 logic[31:0][31:0] gamma_mem[0:31]; // sole1024F32 coefficient copy
 logic[31:0]gamma_coverage;logic gamma_loading;logic[63:0]held_model;logic[31:0]held_key;
 logic mode_gamma,aborting;logic[7:0]rows,total_retired,input_row;
 logic[4:0]input_chunk;logic[31:0]next_row_cycle;
 logic[95:0]input_tags[0:3][0:31];
 logic[3:0][5:0]raw_read_count,delta_read_count,output_count;
 logic[3:0][31:0]sum_value,mean_value,square_sum_value,shift_value,inverse_value;
 logic[3:0]sum_wait,square_sum_wait,sqrt_wait,mean_valid,inverse_valid;
 logic[1:0][3:0][4:0][31:0]left_value;
 logic[1:0][3:0][4:0]left_valid;
 logic[63:0][175:0]add_metadata;
 logic[63:0][23:0]mul_metadata;
 logic[5:0]add_tail,mul_tail;
 logic[175:0]am,add_build_meta,add_hold_meta;
 logic[23:0]mm,mul_build_meta,mul_hold_meta;
 logic add_hold_valid,mul_hold_valid;
 logic[104:0][31:0]add_hold_a,add_hold_b,add_build_a,add_build_b;
 logic[95:0][31:0]mul_hold_a,mul_hold_b,mul_build_a,mul_build_b;
 logic add_build_valid,mul_build_valid;
 logic wr_hold_valid,rd_hold_valid;
 logic[15:0]wr_hold_desc,rd_hold_desc,wr_build_desc,rd_build_desc;
 logic[31:0][31:0]wr_hold_raw,wr_hold_delta,wr_build_raw,wr_build_delta;
 logic can_add,can_mul,can_write,root_capacity,take_input,take_add,take_mul,take_read;
 logic input_finite,gamma_finite,bad_now,work_debt_clear;logic[4:0]bad_stage;logic[1:0]bad_ctx;
 logic[9:0]bad_node;logic[3:0]bad_level;logic[6:0]bad_row;
 logic scale_req_valid,scale_req_ready,scale_rsp_valid,scale_rsp_ready,scale_rsp_error;
 logic[31:0]scale_req_data,scale_rsp_data;logic[95:0]scale_req_tag,scale_rsp_tag;
 logic sqrt_req_valid,sqrt_req_ready,sqrt_rsp_valid,sqrt_rsp_ready,sqrt_rsp_error,sqrt_busy;
 logic[31:0]sqrt_req_data,sqrt_rsp_data;logic[95:0]sqrt_req_tag,sqrt_rsp_tag;
 integer scale_select,sqrt_select,raw_select,delta_select;
 logic[3:0][8:0]add_debt,mul_debt;
 logic[3:0][6:0]read_debt,write_debt;
 logic[3:0][3:0]scalar_debt;
 integer add_change[0:3],mul_change[0:3],read_change[0:3],write_change[0:3],scalar_change[0:3];
 function automatic item_t item(input integer c,n);return {1'b1,2'(c),5'(n)};endfunction
 function automatic bit finite(input logic[31:0]v);return v[30:23]!=255;endfunction
 function automatic integer lane_start(input integer s);
  case(s)0:return 0;1:return 16;2:return 24;3:return 28;4:return 30;
   5:return 31;6:return 32;7:return 33;8:return 34;default:return 35;endcase
 endfunction
 function automatic integer lane_count(input integer s);return s<5?(16>>s):1;endfunction
 function automatic integer meta_count(input logic[175:0]m,input integer c);
  integer n;n=0;for(int s=0;s<22;s++)if(m[s*8+7]&&m[s*8+5+:2]==c)n++;return n;
 endfunction
 function automatic integer mul_meta_count(input logic[23:0]m,input integer c);
  integer n;n=0;for(int s=0;s<3;s++)if(m[s*8+7]&&m[s*8+5+:2]==c)n++;return n;
 endfunction
 assign op_request_id=out_request_id;assign op_generation=out_generation;assign op_epoch=out_epoch;
 assign am=add_metadata[add_rsp_tag[5:0]];assign mm=mul_metadata[mul_rsp_tag[5:0]];
 assign trace_add_valid=take_add;assign trace_add_meta=am;
 assign trace_mul_valid=take_mul;assign trace_mul_meta=mm;
 assign trace_row_start=take_input&&in_chunk==0;assign trace_row=in_row;
 assign can_add=!add_hold_valid;assign can_mul=!mul_hold_valid;assign can_write=!wr_hold_valid;
 assign root_capacity=add_pending<48&&mul_pending<48;
 assign gamma_begin_ready=rst_n&&!active&&!done_valid&&!gamma_loading&&!gamma_done_valid;
 assign gamma_ready=rst_n&&!active&&gamma_loading&&!gamma_done_valid&&!gamma_coverage[gamma_chunk];
 always_comb begin
  input_finite=1;gamma_finite=1;
  for(int l=0;l<32;l++)begin input_finite&=finite(in_data[l]);gamma_finite&=finite(gamma_data[l]);end
  reject_code=0;
  if(cmd_valid)begin
   if(active||done_valid)reject_code=1;
   else if(cmd_rows==0||cmd_rows>128)reject_code=2;
   else if(cmd_gamma&&(!gamma_loaded||cmd_model!=held_model||cmd_key!=held_key))reject_code=3;
  end
  if(in_valid)begin
   if(!active||aborting)reject_code=4;
   else if(in_request_id!=op_request_id||in_generation!=op_generation||in_epoch!=op_epoch)reject_code=5;
   else if(input_row>=rows||in_row!=input_row||in_chunk!=input_chunk)reject_code=6;
  end
  if(gamma_valid&&(!gamma_loading||gamma_coverage[gamma_chunk]))reject_code=7;
  reject_valid=rst_n&&reject_code!=0;
  cmd_ready=rst_n&&!active&&!done_valid&&!gamma_loading&&!gamma_begin_valid&&cmd_rows>0&&cmd_rows<=128&&
   (!cmd_gamma||(gamma_loaded&&cmd_model==held_model&&cmd_key==held_key));
  in_ready=rst_n&&active&&!aborting&&root_capacity&&can_add&&can_write&&input_row<rows&&
   in_request_id==op_request_id&&in_generation==op_generation&&in_epoch==op_epoch&&
   in_row==input_row&&in_chunk==input_chunk&&
   (input_chunk!=0||(!ctx_active[input_row[1:0]]&&cycle_count>=next_row_cycle));
  take_input=in_valid&&in_ready;
  add_rsp_ready=active&&(aborting||(can_add&&(!am[20*8+7]||(can_mul&&can_write))));
  mul_rsp_ready=active&&(aborting||
   ((!mm[7]||can_add)&&(!mm[15]||!mode_gamma||can_mul)&&
    (!(mm[23]||(mm[15]&&!mode_gamma))||!out_valid||out_ready)));
  rd_rsp_ready=active&&(aborting||((!rd_rsp_tag[7]||can_add)&&(!rd_rsp_tag[15]||can_mul)));
  take_add=add_rsp_valid&&add_rsp_ready;take_mul=mul_rsp_valid&&mul_rsp_ready;take_read=rd_rsp_valid&&rd_rsp_ready;
  wr_rsp_ready=active;
  scale_rsp_ready=active&&(aborting||!scale_rsp_tag[2]||can_add);
  div_rsp_ready=active;
 end
 // Detect finite-domain failures at actual observed stages. This local tuple
 // is deliberately not advertised as whole-model original first-error order.
 always_comb begin
  bad_now=0;bad_stage=0;bad_ctx=0;bad_node=0;bad_level=0;bad_row=0;
  if(take_input&&!input_finite)begin
   bad_now=1;bad_stage=0;bad_ctx=in_row[1:0];bad_row=in_row;
   for(int l=31;l>=0;l--)if(!finite(in_data[l]))bad_node={in_chunk,5'(l)};
  end
  for(int s=0;s<22;s++)if(take_add&&am[s*8+7])begin
   for(int l=0;l<(s==20?32:s==21?1:lane_count(s%10));l++)begin
    if(!bad_now&&!finite(add_rsp_data[s==20?72+l:s==21?104:(s>=10?36:0)+lane_start(s%10)+l]))begin
     bad_now=1;bad_ctx=am[s*8+5+:2];bad_row=ctx_row[bad_ctx];
     bad_stage=s==20?3:s==21?7:s<10?1:5;
     bad_level=s<20?4'(s%10+1):0;
     bad_node=s<20?10'(int'(am[s*8+:5])*(s%10<5?lane_count(s%10):1)+l):s==20?{am[s*8+:5],5'(l)}:10'b0;
    end
   end
  end
  for(int s=0;s<3;s++)if(take_mul&&mm[s*8+7])for(int l=0;l<32;l++)
   if(!bad_now&&!finite(mul_rsp_data[s*32+l]))begin
    bad_now=1;bad_ctx=mm[s*8+5+:2];bad_row=ctx_row[bad_ctx];bad_stage=s==0?4:s==1?10:11;
    bad_node={mm[s*8+:5],5'(l)};
   end
  if(scale_rsp_valid&&scale_rsp_ready&&!bad_now&&(scale_rsp_error||
   (scale_rsp_tag[2]&&scale_rsp_data[31]&&scale_rsp_data[30:0]!=0)))begin
   bad_now=1;bad_ctx=scale_rsp_tag[1:0];bad_row=ctx_row[bad_ctx];bad_stage=scale_rsp_tag[2]?6:2;
  end
  if(sqrt_rsp_valid&&sqrt_rsp_ready&&!bad_now&&sqrt_rsp_error)begin
   bad_now=1;bad_ctx=sqrt_rsp_tag[1:0];bad_row=ctx_row[bad_ctx];bad_stage=8;
  end
  if(div_rsp_valid&&div_rsp_ready&&!bad_now&&(div_rsp_error||!finite(div_rsp_data)))begin
   bad_now=1;bad_ctx=div_rsp_tag[1:0];bad_row=ctx_row[bad_ctx];bad_stage=9;
  end
 end
 // Build disjoint arithmetic lanes. Feedback is combinational from the real
 // shared response; only actual backpressure introduces an operand holding.
 always_comb begin
  add_build_a=0;add_build_b=0;add_build_meta=0;
  mul_build_a=0;mul_build_b=0;mul_build_meta=0;
  if(active&&!aborting&&!bad_now)begin
   if(take_input)begin
    add_build_meta[0+:8]=item(int'(in_row[1:0]),int'(in_chunk));
    for(int l=0;l<16;l++)begin add_build_a[l]=in_data[2*l];add_build_b[l]=in_data[2*l+1];end
   end
   if(take_add)begin
    for(int t=0;t<2;t++)for(int s=0;s<9;s++)if(am[(t*10+s)*8+7])begin
     if(s<4)begin
      add_build_meta[(t*10+s+1)*8+:8]=am[(t*10+s)*8+:8];
      for(int l=0;l<lane_count(s+1);l++)begin
       add_build_a[t*36+lane_start(s+1)+l]=add_rsp_data[t*36+lane_start(s)+2*l];
       add_build_b[t*36+lane_start(s+1)+l]=add_rsp_data[t*36+lane_start(s)+2*l+1];
      end
     end else if(am[(t*10+s)*8])begin
      add_build_meta[(t*10+s+1)*8+:8]=item(int'(am[(t*10+s)*8+5+:2]),int'(am[(t*10+s)*8+:5])>>1);
      add_build_a[t*36+lane_start(s+1)]=left_value[t][am[(t*10+s)*8+5+:2]][s-4];
      add_build_b[t*36+lane_start(s+1)]=add_rsp_data[t*36+lane_start(s)];
     end
    end
    if(am[20*8+7])begin
     mul_build_meta[0+:8]=am[20*8+:8];
     for(int l=0;l<32;l++)begin mul_build_a[l]=add_rsp_data[72+l];mul_build_b[l]=add_rsp_data[72+l];end
    end
   end
   if(take_mul)begin
    if(mm[7])begin
     add_build_meta[10*8+:8]=mm[0+:8];
     for(int l=0;l<16;l++)begin add_build_a[36+l]=mul_rsp_data[2*l];add_build_b[36+l]=mul_rsp_data[2*l+1];end
    end
    if(mm[15]&&mode_gamma)begin
     mul_build_meta[16+:8]=mm[8+:8];
     for(int l=0;l<32;l++)begin mul_build_a[64+l]=mul_rsp_data[32+l];mul_build_b[64+l]=gamma_mem[mm[8+:5]][l];end
    end
   end
   if(take_read)begin
    if(rd_rsp_tag[7])begin
     add_build_meta[20*8+:8]=rd_rsp_tag[0+:8];
     for(int l=0;l<32;l++)begin
      add_build_a[72+l]=rd_rsp_data[int'(rd_rsp_tag[5+:2])*64+l];
      add_build_b[72+l]=mean_value[rd_rsp_tag[5+:2]]^32'h80000000;
     end
    end
    if(rd_rsp_tag[15])begin
     mul_build_meta[8+:8]=rd_rsp_tag[8+:8];
     for(int l=0;l<32;l++)begin
      mul_build_a[32+l]=rd_rsp_data[int'(rd_rsp_tag[13+:2])*64+32+l];
      mul_build_b[32+l]=inverse_value[rd_rsp_tag[13+:2]];
     end
    end
   end
   if(scale_rsp_valid&&scale_rsp_ready&&scale_rsp_tag[2])begin
    add_build_meta[21*8+:8]=item(int'(scale_rsp_tag[1:0]),0);
    add_build_a[104]=scale_rsp_data;add_build_b[104]=32'h3727c5ac;
   end
  end
  add_build_valid=|add_build_meta;mul_build_valid=|mul_build_meta;
  add_req_valid=active&&(add_hold_valid||add_build_valid);
  mul_req_valid=active&&(mul_hold_valid||mul_build_valid);
  add_req_tag={32'h4c4e4144,op_generation,26'b0,add_tail};
  mul_req_tag={32'h4c4e4d55,op_generation,26'b0,mul_tail};
  add_a=0;add_b=0;mul_a=0;mul_b=0;
  add_a[0+:105]=add_hold_valid?add_hold_a:add_build_a;add_b[0+:105]=add_hold_valid?add_hold_b:add_build_b;
  mul_a[0+:96]=mul_hold_valid?mul_hold_a:mul_build_a;mul_b[0+:96]=mul_hold_valid?mul_hold_b:mul_build_b;
 end
 // One real read and one real write, each may merge raw and delta banksets.
 always_comb begin
  raw_select=-1;delta_select=-1;
  for(int c=0;c<4;c++)begin
   if(ctx_active[c]&&mean_valid[c]&&(&raw_coverage[c])&&raw_read_count[c]<32&&
    (raw_select<0||ctx_row[c]<ctx_row[raw_select]))raw_select=c;
   if(ctx_active[c]&&inverse_valid[c]&&(&delta_coverage[c])&&delta_read_count[c]<32&&
    (delta_select<0||ctx_row[c]<ctx_row[delta_select]))delta_select=c;
  end
  rd_build_desc=0;
  if(active&&!aborting&&!bad_now&&root_capacity&&!rd_hold_valid)begin
   if(raw_select>=0)rd_build_desc[0+:8]=item(raw_select,int'(raw_read_count[raw_select]));
   if(delta_select>=0)rd_build_desc[8+:8]=item(delta_select,int'(delta_read_count[delta_select]));
  end
  rd_tag={32'h4c4e5244,op_generation,16'b0,rd_hold_valid?rd_hold_desc:rd_build_desc};
  rd_valid=active&&(rd_hold_valid||(|rd_build_desc));rd_mask=0;rd_addr=0;
  for(int k=0;k<2;k++)if(rd_tag[k*8+7])for(int l=0;l<32;l++)begin
   rd_mask[int'(rd_tag[k*8+5+:2])*64+k*32+l]=1;
   rd_addr[int'(rd_tag[k*8+5+:2])*64+k*32+l]=rd_tag[k*8+:5];
  end
  wr_build_desc=0;wr_build_raw=0;wr_build_delta=0;
  if(take_input)begin wr_build_desc[0+:8]=item(int'(in_row[1:0]),int'(in_chunk));wr_build_raw=in_data;end
  if(take_add&&am[20*8+7]&&!aborting&&!bad_now)begin
   wr_build_desc[8+:8]=am[20*8+:8];wr_build_delta=add_rsp_data[72+:32];
  end
  wr_tag={32'h4c4e5752,op_generation,16'b0,wr_hold_valid?wr_hold_desc:wr_build_desc};
  wr_valid=active&&(wr_hold_valid||(|wr_build_desc));wr_mask=0;wr_addr=0;wr_data=0;
  for(int k=0;k<2;k++)if(wr_tag[k*8+7])for(int l=0;l<32;l++)begin
   wr_mask[int'(wr_tag[k*8+5+:2])*64+k*32+l]=1;
   wr_addr[int'(wr_tag[k*8+5+:2])*64+k*32+l]=wr_tag[k*8+:5];
   wr_data[int'(wr_tag[k*8+5+:2])*64+k*32+l]=k==0?
    (wr_hold_valid?wr_hold_raw[l]:wr_build_raw[l]):(wr_hold_valid?wr_hold_delta[l]:wr_build_delta[l]);
  end
 end
 always_comb begin
  scale_select=-1;sqrt_select=-1;
  for(int c=3;c>=0;c--)begin if(sum_wait[c]||square_sum_wait[c])scale_select=c;if(sqrt_wait[c])sqrt_select=c;end
  scale_req_valid=active&&!aborting&&scale_select>=0;scale_req_data=0;scale_req_tag=0;
  if(scale_select>=0)begin
   scale_req_data=sum_wait[scale_select]?sum_value[scale_select]:square_sum_value[scale_select];
   scale_req_tag={32'h4c4e5343,op_generation,29'b0,!sum_wait[scale_select],2'(scale_select)};
  end
  sqrt_req_valid=active&&!aborting&&sqrt_select>=0;sqrt_req_data=0;sqrt_req_tag=0;
  if(sqrt_select>=0)begin sqrt_req_data=shift_value[sqrt_select];sqrt_req_tag={32'h4c4e5351,op_generation,30'b0,2'(sqrt_select)};end
  // The sqrt result slot itself holds a blocked direct inverse request.
  div_req_valid=active&&!aborting&&sqrt_rsp_valid&&!sqrt_rsp_error;
  div_req_tag=sqrt_rsp_tag;div_a=32'h3f800000;div_b=sqrt_rsp_data;
  sqrt_rsp_ready=active&&(aborting||sqrt_rsp_error||div_req_ready);
  trace_scalar_valid=0;trace_scalar_ctx=0;trace_scalar_data=0;
  for(int t=0;t<2;t++)if(take_add&&am[(t*10+9)*8+7])begin
   trace_scalar_valid[t*2]=1;trace_scalar_ctx[t*2]=am[(t*10+9)*8+5+:2];trace_scalar_data[t*2]=add_rsp_data[t*36+35];
  end
  if(scale_rsp_valid&&scale_rsp_ready)begin
   trace_scalar_valid[scale_rsp_tag[2]?3:1]=1;trace_scalar_ctx[scale_rsp_tag[2]?3:1]=scale_rsp_tag[1:0];
   trace_scalar_data[scale_rsp_tag[2]?3:1]=scale_rsp_data;
  end
  if(take_add&&am[21*8+7])begin trace_scalar_valid[4]=1;trace_scalar_ctx[4]=am[21*8+5+:2];trace_scalar_data[4]=add_rsp_data[104];end
  if(sqrt_rsp_valid&&sqrt_rsp_ready)begin trace_scalar_valid[5]=1;trace_scalar_ctx[5]=sqrt_rsp_tag[1:0];trace_scalar_data[5]=sqrt_rsp_data;end
  if(div_rsp_valid&&div_rsp_ready)begin trace_scalar_valid[6]=1;trace_scalar_ctx[6]=div_rsp_tag[1:0];trace_scalar_data[6]=div_rsp_data;end
 end
 laya_m007_ln_div1024_v1 scale(.clk,.rst_n,.req_valid(scale_req_valid),.req_ready(scale_req_ready),.req_data(scale_req_data),.req_tag(scale_req_tag),
  .rsp_valid(scale_rsp_valid),.rsp_ready(scale_rsp_ready),.rsp_data(scale_rsp_data),.rsp_error(scale_rsp_error),.rsp_tag(scale_rsp_tag));
 laya_m007_ln_sqrt_v1 square_root(.clk,.rst_n,.req_valid(sqrt_req_valid),.req_ready(sqrt_req_ready),.req_data(sqrt_req_data),.req_tag(sqrt_req_tag),
  .rsp_valid(sqrt_rsp_valid),.rsp_ready(sqrt_rsp_ready),.rsp_data(sqrt_rsp_data),.rsp_error(sqrt_rsp_error),.rsp_tag(sqrt_rsp_tag),.busy(sqrt_busy));
 // Count actual issued/consumed semantics for each context, including merged
 // vector transactions. Holding operands are separately included in debt_clear.
 always_comb begin
  for(int c=0;c<4;c++)begin
   add_change[c]=0;mul_change[c]=0;read_change[c]=0;write_change[c]=0;scalar_change[c]=0;
   if(add_req_valid&&add_req_ready)add_change[c]+=meta_count(add_hold_valid?add_hold_meta:add_build_meta,c);
   if(take_add)add_change[c]-=meta_count(am,c);
   if(mul_req_valid&&mul_req_ready)mul_change[c]+=mul_meta_count(mul_hold_valid?mul_hold_meta:mul_build_meta,c);
   if(take_mul)mul_change[c]-=mul_meta_count(mm,c);
   for(int k=0;k<2;k++)begin
    if(rd_valid&&rd_ready&&rd_tag[k*8+7]&&rd_tag[k*8+5+:2]==c)read_change[c]++;
    if(take_read&&rd_rsp_tag[k*8+7]&&rd_rsp_tag[k*8+5+:2]==c)read_change[c]--;
    if(wr_valid&&wr_ready&&wr_tag[k*8+7]&&wr_tag[k*8+5+:2]==c)write_change[c]++;
    if(wr_rsp_valid&&wr_rsp_ready&&wr_rsp_tag[k*8+7]&&wr_rsp_tag[k*8+5+:2]==c)write_change[c]--;
   end
   if(scale_req_valid&&scale_req_ready&&scale_req_tag[1:0]==c)scalar_change[c]++;
   if(scale_rsp_valid&&scale_rsp_ready&&scale_rsp_tag[1:0]==c)scalar_change[c]--;
   if(sqrt_req_valid&&sqrt_req_ready&&sqrt_req_tag[1:0]==c)scalar_change[c]++;
   if(sqrt_rsp_valid&&sqrt_rsp_ready&&sqrt_rsp_tag[1:0]==c)scalar_change[c]--;
   if(div_req_valid&&div_req_ready&&div_req_tag[1:0]==c)scalar_change[c]++;
   if(div_rsp_valid&&div_rsp_ready&&div_rsp_tag[1:0]==c)scalar_change[c]--;
  end
  work_debt_clear=mul_pending==0&&add_pending==0&&div_pending==0&&bank_idle&&
   !add_hold_valid&&!mul_hold_valid&&!rd_hold_valid&&!wr_hold_valid&&!out_valid&&
   !sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!(|sum_wait)&&!(|square_sum_wait)&&!(|sqrt_wait)&&
   add_debt==0&&mul_debt==0&&read_debt==0&&write_debt==0&&scalar_debt==0;
  debt_clear=work_debt_clear&&!active&&!done_valid;
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin
   active<=0;done_valid<=0;done_error<=0;aborting<=0;out_valid<=0;
   gamma_loading<=0;gamma_loaded<=0;gamma_coverage<=0;gamma_done_valid<=0;gamma_done_error<=0;
   ctx_active<=0;raw_coverage<=0;delta_coverage<=0;raw_read_count<=0;delta_read_count<=0;output_count<=0;
   sum_wait<=0;square_sum_wait<=0;sqrt_wait<=0;mean_valid<=0;inverse_valid<=0;left_valid<=0;
   add_hold_valid<=0;mul_hold_valid<=0;rd_hold_valid<=0;wr_hold_valid<=0;add_tail<=0;mul_tail<=0;
   add_debt<=0;mul_debt<=0;read_debt<=0;write_debt<=0;scalar_debt<=0;
   cycle_count<=0;peak_add_pending<=0;peak_mul_pending<=0;error_stage<=0;error_level<=0;error_row<=0;error_node<=0;
  end else begin
   if(gamma_done_valid&&gamma_done_ready)gamma_done_valid<=0;
   if(gamma_begin_valid&&gamma_begin_ready)begin
    held_model<=gamma_model;held_key<=gamma_key;gamma_loading<=1;gamma_loaded<=0;gamma_coverage<=0;gamma_done_error<=0;
   end
   if(gamma_valid&&gamma_ready)begin
    gamma_mem[gamma_chunk]<=gamma_data;gamma_coverage[gamma_chunk]<=1;
    if(!gamma_finite)begin gamma_loading<=0;gamma_done_valid<=1;gamma_done_error<=1;gamma_loaded<=0;end
    else if((&(gamma_coverage|(32'b1<<gamma_chunk))))begin gamma_loading<=0;gamma_done_valid<=1;gamma_done_error<=0;gamma_loaded<=1;end
   end
   if(done_valid&&done_ready)done_valid<=0;
   if(out_valid&&out_ready)begin out_valid<=0;output_count[out_row[1:0]]<=output_count[out_row[1:0]]+1'b1;end
   if(cmd_valid&&cmd_ready)begin
    active<=1;aborting<=0;done_error<=0;rows<=cmd_rows;mode_gamma<=cmd_gamma;
    out_request_id<=cmd_request_id;out_generation<=cmd_generation;out_epoch<=cmd_epoch;
    input_row<=0;input_chunk<=0;total_retired<=0;next_row_cycle<=0;cycle_count<=0;
    ctx_active<=0;raw_coverage<=0;delta_coverage<=0;raw_read_count<=0;delta_read_count<=0;output_count<=0;
    sum_wait<=0;square_sum_wait<=0;sqrt_wait<=0;mean_valid<=0;inverse_valid<=0;left_valid<=0;
    peak_add_pending<=0;peak_mul_pending<=0;
   end
   if(active)begin
    cycle_count<=cycle_count+1'b1;
    if(add_pending>peak_add_pending)peak_add_pending<=add_pending;if(mul_pending>peak_mul_pending)peak_mul_pending<=mul_pending;
    for(int c=0;c<4;c++)begin
     add_debt[c]<=9'(int'(add_debt[c])+add_change[c]);mul_debt[c]<=9'(int'(mul_debt[c])+mul_change[c]);
     read_debt[c]<=7'(int'(read_debt[c])+read_change[c]);write_debt[c]<=7'(int'(write_debt[c])+write_change[c]);
     scalar_debt[c]<=4'(int'(scalar_debt[c])+scalar_change[c]);
     if(ctx_active[c]&&output_count[c]==32&&add_debt[c]==0&&mul_debt[c]==0&&read_debt[c]==0&&write_debt[c]==0&&scalar_debt[c]==0&&
      !sum_wait[c]&&!square_sum_wait[c]&&!sqrt_wait[c])begin ctx_active[c]<=0;total_retired<=total_retired+1'b1;end
    end
    if(bad_now&&!aborting)begin
     aborting<=1;done_error<=1;error_stage<=bad_stage;error_level<=bad_level;error_row<=bad_row;error_node<=bad_node;
     sum_wait<=0;square_sum_wait<=0;sqrt_wait<=0;
    end
    if(aborting)begin sum_wait<=0;square_sum_wait<=0;sqrt_wait<=0;end
    if((aborting||total_retired==rows)&&work_debt_clear)begin active<=0;ctx_active<=0;done_valid<=1;end
    if(take_input)begin
     input_tags[in_row[1:0]][in_chunk]<=in_tag;
     if(in_chunk==0)begin
      ctx_active[in_row[1:0]]<=1;ctx_row[in_row[1:0]]<=in_row;
      raw_coverage[in_row[1:0]]<=0;delta_coverage[in_row[1:0]]<=0;
      raw_read_count[in_row[1:0]]<=0;delta_read_count[in_row[1:0]]<=0;output_count[in_row[1:0]]<=0;
      mean_valid[in_row[1:0]]<=0;inverse_valid[in_row[1:0]]<=0;
      left_valid[0][in_row[1:0]]<=0;left_valid[1][in_row[1:0]]<=0;
      next_row_cycle<=cycle_count+128;
     end
     if(in_chunk==31)begin input_row<=input_row+1'b1;input_chunk<=0;end else input_chunk<=input_chunk+1'b1;
    end
    if(add_req_valid&&add_req_ready)begin add_metadata[add_tail]<=add_hold_valid?add_hold_meta:add_build_meta;add_tail<=add_tail+1'b1;end
    if(mul_req_valid&&mul_req_ready)begin mul_metadata[mul_tail]<=mul_hold_valid?mul_hold_meta:mul_build_meta;mul_tail<=mul_tail+1'b1;end
    if(add_hold_valid)begin if(add_req_ready)add_hold_valid<=0;end
    else if(add_build_valid&&!add_req_ready)begin add_hold_valid<=1;add_hold_a<=add_build_a;add_hold_b<=add_build_b;add_hold_meta<=add_build_meta;end
    if(mul_hold_valid)begin if(mul_req_ready)mul_hold_valid<=0;end
    else if(mul_build_valid&&!mul_req_ready)begin mul_hold_valid<=1;mul_hold_a<=mul_build_a;mul_hold_b<=mul_build_b;mul_hold_meta<=mul_build_meta;end
    if(rd_hold_valid)begin if(rd_ready)rd_hold_valid<=0;end
    else if((|rd_build_desc)&&!rd_ready)begin rd_hold_valid<=1;rd_hold_desc<=rd_build_desc;end
    // Reserve scheduled reads when captured, not on every stalled cycle.
    if(!rd_hold_valid&&(|rd_build_desc))begin
     if(rd_build_desc[7])raw_read_count[rd_build_desc[5+:2]]<=raw_read_count[rd_build_desc[5+:2]]+1'b1;
     if(rd_build_desc[15])delta_read_count[rd_build_desc[13+:2]]<=delta_read_count[rd_build_desc[13+:2]]+1'b1;
    end
    if(wr_hold_valid)begin if(wr_ready)wr_hold_valid<=0;end
    else if((|wr_build_desc)&&!wr_ready)begin wr_hold_valid<=1;wr_hold_desc<=wr_build_desc;wr_hold_raw<=wr_build_raw;wr_hold_delta<=wr_build_delta;end
    if(wr_rsp_valid&&wr_rsp_ready)begin
     if(wr_rsp_tag[7])raw_coverage[wr_rsp_tag[5+:2]][wr_rsp_tag[0+:5]]<=1;
     if(wr_rsp_tag[15])delta_coverage[wr_rsp_tag[13+:2]][wr_rsp_tag[8+:5]]<=1;
    end
    if(take_add&&!aborting&&!bad_now)begin
     for(int t=0;t<2;t++)for(int s=4;s<9;s++)if(am[(t*10+s)*8+7])begin
      if(!am[(t*10+s)*8])begin
       left_value[t][am[(t*10+s)*8+5+:2]][s-4]<=add_rsp_data[t*36+lane_start(s)];
       left_valid[t][am[(t*10+s)*8+5+:2]][s-4]<=1;
      end else left_valid[t][am[(t*10+s)*8+5+:2]][s-4]<=0;
     end
     if(am[9*8+7])begin sum_value[am[9*8+5+:2]]<=add_rsp_data[35];sum_wait[am[9*8+5+:2]]<=1;end
     if(am[19*8+7])begin square_sum_value[am[19*8+5+:2]]<=add_rsp_data[71];square_sum_wait[am[19*8+5+:2]]<=1;end
     if(am[21*8+7])begin shift_value[am[21*8+5+:2]]<=add_rsp_data[104];sqrt_wait[am[21*8+5+:2]]<=1;end
    end
    if(scale_req_valid&&scale_req_ready)begin
     if(scale_req_tag[2])square_sum_wait[scale_req_tag[1:0]]<=0;else sum_wait[scale_req_tag[1:0]]<=0;
    end
    if(scale_rsp_valid&&scale_rsp_ready&&!aborting&&!bad_now&&!scale_rsp_tag[2])begin
     mean_value[scale_rsp_tag[1:0]]<=scale_rsp_data;mean_valid[scale_rsp_tag[1:0]]<=1;
    end
    if(sqrt_req_valid&&sqrt_req_ready)sqrt_wait[sqrt_req_tag[1:0]]<=0;
    if(div_rsp_valid&&div_rsp_ready&&!aborting&&!bad_now)begin inverse_value[div_rsp_tag[1:0]]<=div_rsp_data;inverse_valid[div_rsp_tag[1:0]]<=1;end
    if(take_mul&&!aborting&&!bad_now&&(mm[23]||(mm[15]&&!mode_gamma)))begin
     out_valid<=1;
     if(mode_gamma)begin
      out_row<=ctx_row[mm[21+:2]];out_chunk<=mm[16+:5];out_tag<=input_tags[mm[21+:2]][mm[16+:5]];out_data<=mul_rsp_data[64+:32];
     end else begin
      out_row<=ctx_row[mm[13+:2]];out_chunk<=mm[8+:5];out_tag<=input_tags[mm[13+:2]][mm[8+:5]];out_data<=mul_rsp_data[32+:32];
     end
    end
   end
  end
 end
endmodule
