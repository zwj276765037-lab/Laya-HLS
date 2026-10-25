`timescale 1ns/1ps
// Canonical pure q/next LN; legacy implementation is a separate generate branch.
module laya_m007_layernorm32_compact_v2 #(parameter bit EXTERNAL_CONTROL=0)(

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
 typedef logic[7:0] item_t;
 logic[12287:0]q_view,q_next;wire enabled=control_enable;
 generate if(EXTERNAL_CONTROL)begin:external_q
  assign q_view=control_q;
 end else begin:internal_q
  logic[12127:0]local_control;
  assign q_view={160'b0,local_control};
  always_ff@(posedge clk)begin if(!rst_n)local_control<=0;else if(enabled)local_control<=q_next[12127:0];end
 end endgenerate
 assign control_next=q_next;
 logic[31:0][31:0]gamma_mem[0:31];logic[31:0]gamma_coverage;
 logic gamma_loading,gamma_done_valid_i;logic[63:0]held_model;logic[31:0]held_key;
 logic[3:0][31:0]sum_value,mean_value,square_sum_value,shift_value,inverse_value;
 logic[1:0][3:0][4:0][31:0]left_value;
 logic[104:0][31:0]add_hold_a,add_hold_b,add_build_a,add_build_b;
 logic[95:0][31:0]mul_hold_a,mul_hold_b,mul_build_a,mul_build_b;
 logic[31:0][31:0]wr_hold_raw,wr_hold_delta,wr_build_raw,wr_build_delta;
 logic[175:0]am,add_build_meta;logic[23:0]mm,mul_build_meta;
 logic add_build_valid,mul_build_valid;logic[15:0]wr_build_desc,rd_build_desc;
 logic can_add,can_mul,can_write,root_capacity,take_input,take_add,take_mul,take_read;
 logic input_finite,gamma_finite,bad_now,work_debt_clear,physical_debt_clear,aborting;
 logic[4:0]bad_stage;logic[1:0]bad_ctx;logic[9:0]bad_node;logic[3:0]bad_level;logic[6:0]bad_row;
 logic scale_req_valid,scale_req_ready,scale_rsp_valid,scale_rsp_ready,scale_rsp_error;
 logic[31:0]scale_req_data,scale_rsp_data;logic[95:0]scale_req_tag,scale_rsp_tag;
 logic sqrt_req_valid,sqrt_req_ready,sqrt_rsp_valid,sqrt_rsp_ready,sqrt_rsp_error,sqrt_busy;
 logic[31:0]sqrt_req_data,sqrt_rsp_data;logic[95:0]sqrt_req_tag,sqrt_rsp_tag;
 logic[2:0]scale_local_tag;logic[1:0]sqrt_local_tag;logic[4:0]scale_control_next;logic[12:0]sqrt_control_next;
 integer scale_select,sqrt_select,raw_select,delta_select;
 integer add_change[0:3],mul_change[0:3],read_change[0:3],write_change[0:3],scalar_change[0:3];
 logic add_match,mul_match,read_match,write_match,div_match,proto_now,cancel_fire;
 logic[3:0]proto_code_now,raw_reject;logic[7:0]proto_location_now;
 logic[3:0]c_div_expected,n_div_expected;
 assign c_div_expected=q_view[12116+:4];
 logic  c_active,n_active;
 assign c_active=q_view[0+:1];
 logic  c_done_valid,n_done_valid;
 assign c_done_valid=q_view[1+:1];
 logic  c_done_error,n_done_error;
 assign c_done_error=q_view[2+:1];
 logic  c_out_valid,n_out_valid;
 assign c_out_valid=q_view[4+:1];
 logic [3:0] c_ctx_active,n_ctx_active;
 assign c_ctx_active=q_view[5+:4];
 logic [3:0][6:0] c_ctx_row,n_ctx_row;
 assign c_ctx_row=q_view[9+:28];
 logic [3:0][31:0] c_raw_coverage,n_raw_coverage;
 assign c_raw_coverage=q_view[37+:128];
 logic [3:0][31:0] c_delta_coverage,n_delta_coverage;
 assign c_delta_coverage=q_view[165+:128];
 logic [3:0][5:0] c_raw_read_count,n_raw_read_count;
 assign c_raw_read_count=q_view[293+:24];
 logic [3:0][5:0] c_delta_read_count,n_delta_read_count;
 assign c_delta_read_count=q_view[317+:24];
 logic [3:0][5:0] c_output_count,n_output_count;
 assign c_output_count=q_view[341+:24];
 logic [3:0] c_sum_wait,n_sum_wait;
 assign c_sum_wait=q_view[365+:4];
 logic [3:0] c_square_sum_wait,n_square_sum_wait;
 assign c_square_sum_wait=q_view[369+:4];
 logic [3:0] c_sqrt_wait,n_sqrt_wait;
 assign c_sqrt_wait=q_view[373+:4];
 logic [3:0] c_mean_valid,n_mean_valid;
 assign c_mean_valid=q_view[377+:4];
 logic [3:0] c_inverse_valid,n_inverse_valid;
 assign c_inverse_valid=q_view[381+:4];
 logic [1:0][3:0][4:0] c_left_valid,n_left_valid;
 assign c_left_valid=q_view[385+:40];
 logic  c_add_hold_valid,n_add_hold_valid;
 assign c_add_hold_valid=q_view[425+:1];
 logic  c_mul_hold_valid,n_mul_hold_valid;
 assign c_mul_hold_valid=q_view[426+:1];
 logic  c_rd_hold_valid,n_rd_hold_valid;
 assign c_rd_hold_valid=q_view[427+:1];
 logic  c_wr_hold_valid,n_wr_hold_valid;
 assign c_wr_hold_valid=q_view[428+:1];
 logic [5:0] c_add_tail,n_add_tail;
 assign c_add_tail=q_view[429+:6];
 logic [5:0] c_mul_tail,n_mul_tail;
 assign c_mul_tail=q_view[435+:6];
 logic [3:0][8:0] c_add_debt,n_add_debt;
 assign c_add_debt=q_view[441+:36];
 logic [3:0][8:0] c_mul_debt,n_mul_debt;
 assign c_mul_debt=q_view[477+:36];
 logic [3:0][6:0] c_read_debt,n_read_debt;
 assign c_read_debt=q_view[513+:28];
 logic [3:0][6:0] c_write_debt,n_write_debt;
 assign c_write_debt=q_view[541+:28];
 logic [3:0][3:0] c_scalar_debt,n_scalar_debt;
 assign c_scalar_debt=q_view[569+:16];
 logic [31:0] c_cycle_count,n_cycle_count;
 assign c_cycle_count=q_view[585+:32];
 logic [6:0] c_peak_add_pending,n_peak_add_pending;
 assign c_peak_add_pending=q_view[617+:7];
 logic [6:0] c_peak_mul_pending,n_peak_mul_pending;
 assign c_peak_mul_pending=q_view[624+:7];
 logic [4:0] c_error_order_code,n_error_order_code;
 assign c_error_order_code=q_view[631+:5];
 logic [3:0] c_error_level,n_error_level;
 assign c_error_level=q_view[636+:4];
 logic [6:0] c_error_row,n_error_row;
 assign c_error_row=q_view[640+:7];
 logic [9:0] c_error_node,n_error_node;
 assign c_error_node=q_view[647+:10];
 logic  c_mode_gamma,n_mode_gamma;
 assign c_mode_gamma=q_view[657+:1];
 logic [7:0] c_rows,n_rows;
 assign c_rows=q_view[658+:8];
 logic [7:0] c_input_row,n_input_row;
 assign c_input_row=q_view[666+:8];
 logic [4:0] c_input_chunk,n_input_chunk;
 assign c_input_chunk=q_view[674+:5];
 logic [7:0] c_total_retired,n_total_retired;
 assign c_total_retired=q_view[679+:8];
 logic [31:0] c_next_row_cycle,n_next_row_cycle;
 assign c_next_row_cycle=q_view[687+:32];
 logic [63:0] c_out_request_id,n_out_request_id;
 assign c_out_request_id=q_view[719+:64];
 logic [31:0] c_out_generation,n_out_generation;
 assign c_out_generation=q_view[783+:32];
 logic [31:0] c_out_epoch,n_out_epoch;
 assign c_out_epoch=q_view[815+:32];
 logic [63:0][145:0] c_add_metadata,n_add_metadata;
 assign c_add_metadata=q_view[847+:9344];
 logic [63:0][23:0] c_mul_metadata,n_mul_metadata;
 assign c_mul_metadata=q_view[10191+:1536];
 logic [145:0] c_add_hold_meta,n_add_hold_meta;
 assign c_add_hold_meta=q_view[11727+:146];
 logic [23:0] c_mul_hold_meta,n_mul_hold_meta;
 assign c_mul_hold_meta=q_view[11873+:24];
 logic [15:0] c_rd_hold_desc,n_rd_hold_desc;
 assign c_rd_hold_desc=q_view[11897+:16];
 logic [15:0] c_wr_hold_desc,n_wr_hold_desc;
 assign c_wr_hold_desc=q_view[11913+:16];
 logic [6:0] c_out_row,n_out_row;
 assign c_out_row=q_view[11929+:7];
 logic [4:0] c_out_chunk,n_out_chunk;
 assign c_out_chunk=q_view[11936+:5];
 logic [1:0][3:0][9:0] c_tree_checked,n_tree_checked;
 assign c_tree_checked=q_view[11962+:80];
 logic  c_protocol_fault,n_protocol_fault;
 assign c_protocol_fault=q_view[12042+:1];
 logic [3:0] c_protocol_code,n_protocol_code;
 assign c_protocol_code=q_view[12043+:4];
 logic [7:0] c_protocol_location,n_protocol_location;
 assign c_protocol_location=q_view[12047+:8];
 logic  c_source_bad_valid,n_source_bad_valid;
 assign c_source_bad_valid=q_view[12055+:1];
 logic [6:0] c_source_bad_row,n_source_bad_row;
 assign c_source_bad_row=q_view[12056+:7];
 logic [9:0] c_source_bad_element,n_source_bad_element;
 assign c_source_bad_element=q_view[12063+:10];
 logic  c_source_finite_qualified,n_source_finite_qualified;
 assign c_source_finite_qualified=q_view[12073+:1];
 logic  c_reject_pending,n_reject_pending;
 assign c_reject_pending=q_view[12074+:1];
 logic [3:0] c_reject_held_code,n_reject_held_code;
 assign c_reject_held_code=q_view[12075+:4];
 logic  c_cancel_active,n_cancel_active;
 assign c_cancel_active=q_view[12079+:1];
 logic [1:0] c_done_kind,n_done_kind;
 assign c_done_kind=q_view[12080+:2];
 logic  c_read_expected_valid,n_read_expected_valid;
 assign c_read_expected_valid=q_view[12082+:1];
 logic [15:0] c_read_expected_desc,n_read_expected_desc;
 assign c_read_expected_desc=q_view[12083+:16];
 logic  c_write_expected_valid,n_write_expected_valid;
 assign c_write_expected_valid=q_view[12099+:1];
 logic [15:0] c_write_expected_desc,n_write_expected_desc;
 assign c_write_expected_desc=q_view[12100+:16];
 logic  c_scale_offer_valid,n_scale_offer_valid;
 assign c_scale_offer_valid=q_view[12120+:1];
 logic [2:0] c_scale_offer_tag,n_scale_offer_tag;
 assign c_scale_offer_tag=q_view[12121+:3];
 logic  c_sqrt_offer_valid,n_sqrt_offer_valid;
 assign c_sqrt_offer_valid=q_view[12124+:1];
 logic [1:0] c_sqrt_offer_ctx,n_sqrt_offer_ctx;
 assign c_sqrt_offer_ctx=q_view[12125+:2];
 logic  c_div_offer_valid,n_div_offer_valid;
 assign c_div_offer_valid=q_view[12127+:1];
 logic [3:0] c_ctx_failed,n_ctx_failed;
 assign c_ctx_failed={q_view[11959+:3],q_view[3]};
 assign active=enabled&&c_active;
 assign done_valid=enabled&&c_done_valid;
 assign done_error=c_done_error;
 assign out_valid=enabled&&c_out_valid;
 assign ctx_active=enabled?c_ctx_active:4'b0;
 assign ctx_row=c_ctx_row;
 assign raw_coverage=c_raw_coverage;
 assign delta_coverage=c_delta_coverage;
 assign cycle_count=c_cycle_count;
 assign peak_add_pending=c_peak_add_pending;
 assign peak_mul_pending=c_peak_mul_pending;
 assign error_level=c_error_level;
 assign error_row=c_error_row;
 assign error_node=c_error_node;
 assign out_request_id=c_out_request_id;
 assign out_generation=c_out_generation;
 assign out_epoch=c_out_epoch;
 assign out_row=c_out_row;
 assign out_chunk=c_out_chunk;
 assign done_kind=c_done_kind;
 assign protocol_fault=enabled&&c_protocol_fault;
 assign protocol_code=c_protocol_code;
 assign protocol_location=c_protocol_location;
 assign gamma_done_valid=enabled&&gamma_done_valid_i;
 assign op_request_id=c_out_request_id;assign op_generation=c_out_generation;assign op_epoch=c_out_epoch;
 assign out_tag={16'h4c4e,c_out_epoch,c_out_generation,c_out_row,c_out_chunk,4'b0};
 assign cancel_rsp_valid=done_valid&&c_done_kind==3;
 assign error_class=c_error_order_code[4:3];assign error_check={1'b0,c_error_order_code[2:0]};
 assign error_stage=c_error_order_code[4:3]==0?0:c_error_order_code[4:3]==1?12:
  c_error_order_code[2:0]==0?1:c_error_order_code[2:0]==1?3:c_error_order_code[2:0]==2?4:
  c_error_order_code[2:0]==3?5:c_error_order_code[2:0]==4?6:c_error_order_code[2:0]==6?(c_mode_gamma?11:10):
  c_error_level==0?2:c_error_level==1?6:c_error_level==2?7:c_error_level==3?8:9;
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
 function automatic integer item_width(input integer s);
  return s<5?8:s<10?12-s:8;
 endfunction
 function automatic logic[145:0]encode_add(input logic[175:0]full);
  logic[145:0]packed_meta;integer off,w;packed_meta=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;
   packed_meta[off+w-1]=full[k*8+7];packed_meta[off+w-3+:2]=full[k*8+5+:2];
   for(int b=0;b<5;b++)if(b<w-3)packed_meta[off+b]=full[k*8+b];off+=w;
  end
  return packed_meta;
 endfunction
 function automatic logic[175:0]decode_add(input logic[145:0]compact);
  logic[175:0]full;integer off,w;full=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;full[k*8+7]=compact[off+w-1];full[k*8+5+:2]=compact[off+w-3+:2];
   for(int b=0;b<5;b++)if(b<w-3)full[k*8+b]=compact[off+b];off+=w;
  end
  return full;
 endfunction
 function automatic logic add_encoding_ok(input logic[175:0]full);
  logic ok;integer w;ok=1;
  for(int k=0;k<20;k++)begin w=item_width(k%10);if(full[k*8+7])for(int b=0;b<5;b++)if(b>=w-3&&full[k*8+b])ok=0;end
  return ok;
 endfunction
 function automatic logic[4:0]order_code(input logic[4:0]stage);
  case(stage)0:return 0;1:return 16;3:return 17;4:return 18;5:return 19;6:return 20;10,11:return 22;default:return 21;endcase
 endfunction
 assign add_match=add_pending!=0&&add_rsp_tag=={32'h4c4e4144,c_out_generation,26'b0,6'(c_add_tail-add_pending)};
 assign mul_match=mul_pending!=0&&mul_rsp_tag=={32'h4c4e4d55,c_out_generation,26'b0,6'(c_mul_tail-mul_pending)};
 assign read_match=c_read_expected_valid&&rd_rsp_tag=={32'h4c4e5244,c_out_generation,16'b0,c_read_expected_desc};
 assign write_match=c_write_expected_valid&&wr_rsp_tag=={32'h4c4e5752,c_out_generation,16'b0,c_write_expected_desc};
 assign div_match=div_pending!=0&&div_rsp_tag=={32'h4c4e5351,c_out_generation,30'b0,div_rsp_tag[1:0]}&&c_div_expected[div_rsp_tag[1:0]];
 assign reject_valid=enabled&&rst_n&&c_reject_pending;assign reject_code=c_reject_held_code;
 assign cancel_ready=enabled&&rst_n&&c_active&&!c_done_valid&&!c_cancel_active&&cancel_request_id==c_out_request_id&&cancel_generation==c_out_generation&&cancel_epoch==c_out_epoch;
 assign cancel_fire=cancel_valid&&cancel_ready;
 assign aborting=(|c_ctx_failed)||c_protocol_fault||c_cancel_active;
 always_comb begin
  proto_now=0;proto_code_now=0;proto_location_now=0;
  if(enabled&&c_active&&!c_protocol_fault)begin
   if(add_rsp_valid&&!add_match)begin proto_now=1;proto_code_now=1;end
   else if(mul_rsp_valid&&!mul_match)begin proto_now=1;proto_code_now=2;end
   else if(rd_rsp_valid&&!read_match)begin proto_now=1;proto_code_now=3;end
   else if(wr_rsp_valid&&!write_match)begin proto_now=1;proto_code_now=4;end
   else if(div_rsp_valid&&!div_match)begin proto_now=1;proto_code_now=5;end
   else if(add_build_valid&&!add_encoding_ok(add_build_meta))begin proto_now=1;proto_code_now=6;end
   else if(control_clear&&!control_retired)begin proto_now=1;proto_code_now=7;end
  end
 end
 assign am=add_match?decode_add(c_add_metadata[add_rsp_tag[5:0]]):176'b0;assign mm=mul_match?c_mul_metadata[mul_rsp_tag[5:0]]:24'b0;
 assign trace_add_valid=take_add;assign trace_add_meta=am;
 assign trace_mul_valid=take_mul;assign trace_mul_meta=mm;
 assign trace_row_start=take_input&&in_chunk==0;assign trace_row=in_row;
 assign can_add=!c_add_hold_valid;assign can_mul=!c_mul_hold_valid;assign can_write=!c_wr_hold_valid;
 assign root_capacity=add_pending<48&&mul_pending<48;
 assign gamma_begin_ready=enabled&&rst_n&&!c_active&&!c_done_valid&&!gamma_loading&&!gamma_done_valid_i;
 assign gamma_ready=enabled&&rst_n&&!c_active&&gamma_loading&&!gamma_done_valid_i&&!gamma_coverage[gamma_chunk];
 always_comb begin
  input_finite=1;gamma_finite=1;
  for(int l=0;l<32;l++)begin input_finite&=finite(in_data[l]);gamma_finite&=finite(gamma_data[l]);end
  raw_reject=0;
  if(cmd_valid)begin
   if(c_active||c_done_valid)raw_reject=1;
   else if(cmd_rows==0||cmd_rows>128)raw_reject=2;
   else if(cmd_gamma&&(!gamma_loaded||cmd_model!=held_model||cmd_key!=held_key))raw_reject=3;
  end
  if(in_valid)begin
   if(!c_active||aborting)raw_reject=4;
   else if(in_request_id!=op_request_id||in_generation!=op_generation||in_epoch!=op_epoch)raw_reject=5;
   else if(c_input_row>=c_rows||in_row!=c_input_row||in_chunk!=c_input_chunk)raw_reject=6;
  end
  if(gamma_valid&&(!gamma_loading||gamma_coverage[gamma_chunk]))raw_reject=7;

  cmd_ready=enabled&&rst_n&&!c_reject_pending&&!cancel_valid&&!c_active&&!c_done_valid&&!gamma_loading&&!gamma_begin_valid&&cmd_rows>0&&cmd_rows<=128&&(cmd_source_finite_qualified||cmd_source_summary_valid)&&(!cmd_source_bad_valid||cmd_source_bad_row<cmd_rows)&&
   (!cmd_gamma||(gamma_loaded&&cmd_model==held_model&&cmd_key==held_key));
  in_ready=enabled&&rst_n&&!c_reject_pending&&!cancel_valid&&c_active&&!aborting&&root_capacity&&can_add&&can_write&&c_input_row<c_rows&&
   in_request_id==op_request_id&&in_generation==op_generation&&in_epoch==op_epoch&&
   in_row==c_input_row&&in_chunk==c_input_chunk&&in_tag=={16'h4c4e,op_epoch,op_generation,in_row,in_chunk,4'b0}&&
   (c_input_chunk!=0||(!c_ctx_active[c_input_row[1:0]]&&c_cycle_count>=c_next_row_cycle));
  take_input=in_valid&&in_ready;
  add_rsp_ready=enabled&&c_active&&(aborting||(can_add&&(!am[20*8+7]||(can_mul&&can_write))));
  mul_rsp_ready=enabled&&c_active&&(aborting||
   ((!mm[7]||can_add)&&(!mm[15]||!c_mode_gamma||can_mul)&&
    (!(mm[23]||(mm[15]&&!c_mode_gamma))||!c_out_valid||out_ready)));
  rd_rsp_ready=enabled&&c_active&&(aborting||((!rd_rsp_tag[7]||can_add)&&(!rd_rsp_tag[15]||can_mul)));
  take_add=add_rsp_valid&&add_rsp_ready&&add_match&&!c_protocol_fault;take_mul=mul_rsp_valid&&mul_rsp_ready&&mul_match&&!c_protocol_fault;take_read=rd_rsp_valid&&rd_rsp_ready&&read_match&&!c_protocol_fault;
  wr_rsp_ready=enabled&&c_active;
  scale_rsp_ready=enabled&&c_active&&(aborting||!scale_rsp_tag[2]||can_add);
  div_rsp_ready=enabled&&c_active;
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
     bad_now=1;bad_ctx=am[s*8+5+:2];bad_row=c_ctx_row[bad_ctx];
     bad_stage=s==20?3:s==21?7:s<10?1:5;
     bad_level=s<20?4'(s%10+1):0;
     bad_node=s<20?10'(int'(am[s*8+:5])*(s%10<5?lane_count(s%10):1)+l):s==20?{am[s*8+:5],5'(l)}:10'b0;
    end
   end
  end
  for(int s=0;s<3;s++)if(take_mul&&mm[s*8+7])for(int l=0;l<32;l++)
   if(!bad_now&&!finite(mul_rsp_data[s*32+l]))begin
    bad_now=1;bad_ctx=mm[s*8+5+:2];bad_row=c_ctx_row[bad_ctx];bad_stage=s==0?4:s==1?10:11;
    bad_node={mm[s*8+:5],5'(l)};
   end
  if(scale_rsp_valid&&scale_rsp_ready&&!bad_now&&(scale_rsp_error||
   (scale_rsp_tag[2]&&scale_rsp_data[31]&&scale_rsp_data[30:0]!=0)))begin
   bad_now=1;bad_ctx=scale_rsp_tag[1:0];bad_row=c_ctx_row[bad_ctx];bad_stage=scale_rsp_tag[2]?6:2;
  end
  if(sqrt_rsp_valid&&sqrt_rsp_ready&&!bad_now&&sqrt_rsp_error)begin
   bad_now=1;bad_ctx=sqrt_rsp_tag[1:0];bad_row=c_ctx_row[bad_ctx];bad_stage=8;
  end
  if(div_rsp_valid&&div_rsp_ready&&!bad_now&&(div_rsp_error||!finite(div_rsp_data)))begin
   bad_now=1;bad_ctx=div_rsp_tag[1:0];bad_row=c_ctx_row[bad_ctx];bad_stage=9;
  end
 end
 // Build disjoint arithmetic lanes. Feedback is combinational from the real
 // shared response; only actual backpressure introduces an operand holding.
 always_comb begin
  add_build_a=0;add_build_b=0;add_build_meta=0;
  mul_build_a=0;mul_build_b=0;mul_build_meta=0;
  if(c_active&&!aborting&&!bad_now)begin
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
    if(mm[15]&&c_mode_gamma)begin
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
  add_req_valid=enabled&&c_active&&(c_add_hold_valid||add_build_valid);
  mul_req_valid=enabled&&c_active&&(c_mul_hold_valid||mul_build_valid);
  add_req_tag={32'h4c4e4144,op_generation,26'b0,c_add_tail};
  mul_req_tag={32'h4c4e4d55,op_generation,26'b0,c_mul_tail};
  add_a=0;add_b=0;mul_a=0;mul_b=0;
  add_a[0+:105]=c_add_hold_valid?add_hold_a:add_build_a;add_b[0+:105]=c_add_hold_valid?add_hold_b:add_build_b;
  mul_a[0+:96]=c_mul_hold_valid?mul_hold_a:mul_build_a;mul_b[0+:96]=c_mul_hold_valid?mul_hold_b:mul_build_b;
 end
 // One real read and one real write, each may merge raw and delta banksets.
 always_comb begin
  raw_select=-1;delta_select=-1;
  for(int c=0;c<4;c++)begin
   if(c_ctx_active[c]&&c_mean_valid[c]&&(&c_raw_coverage[c])&&c_raw_read_count[c]<32&&
    (raw_select<0||c_ctx_row[c]<c_ctx_row[raw_select]))raw_select=c;
   if(c_ctx_active[c]&&c_inverse_valid[c]&&(&c_delta_coverage[c])&&c_delta_read_count[c]<32&&
    (delta_select<0||c_ctx_row[c]<c_ctx_row[delta_select]))delta_select=c;
  end
  rd_build_desc=0;
  if(c_active&&!aborting&&!bad_now&&root_capacity&&!c_rd_hold_valid)begin
   if(raw_select>=0)rd_build_desc[0+:8]=item(raw_select,int'(c_raw_read_count[raw_select]));
   if(delta_select>=0)rd_build_desc[8+:8]=item(delta_select,int'(c_delta_read_count[delta_select]));
  end
  rd_tag={32'h4c4e5244,op_generation,16'b0,c_rd_hold_valid?c_rd_hold_desc:rd_build_desc};
  rd_valid=enabled&&c_active&&(c_rd_hold_valid||(|rd_build_desc));rd_mask=0;rd_addr=0;
  for(int k=0;k<2;k++)if(rd_tag[k*8+7])for(int l=0;l<32;l++)begin
   rd_mask[int'(rd_tag[k*8+5+:2])*64+k*32+l]=1;
   rd_addr[int'(rd_tag[k*8+5+:2])*64+k*32+l]=rd_tag[k*8+:5];
  end
  wr_build_desc=0;wr_build_raw=0;wr_build_delta=0;
  if(take_input)begin wr_build_desc[0+:8]=item(int'(in_row[1:0]),int'(in_chunk));wr_build_raw=in_data;end
  if(take_add&&am[20*8+7]&&!aborting&&!bad_now)begin
   wr_build_desc[8+:8]=am[20*8+:8];wr_build_delta=add_rsp_data[72+:32];
  end
  wr_tag={32'h4c4e5752,op_generation,16'b0,c_wr_hold_valid?c_wr_hold_desc:wr_build_desc};
  wr_valid=enabled&&c_active&&(c_wr_hold_valid||(|wr_build_desc));wr_mask=0;wr_addr=0;wr_data=0;
  for(int k=0;k<2;k++)if(wr_tag[k*8+7])for(int l=0;l<32;l++)begin
   wr_mask[int'(wr_tag[k*8+5+:2])*64+k*32+l]=1;
   wr_addr[int'(wr_tag[k*8+5+:2])*64+k*32+l]=wr_tag[k*8+:5];
   wr_data[int'(wr_tag[k*8+5+:2])*64+k*32+l]=k==0?
    (c_wr_hold_valid?wr_hold_raw[l]:wr_build_raw[l]):(c_wr_hold_valid?wr_hold_delta[l]:wr_build_delta[l]);
  end
 end
 always_comb begin
  scale_select=-1;sqrt_select=-1;
  for(int c=3;c>=0;c--)begin if(c_sum_wait[c]||c_square_sum_wait[c])scale_select=c;if(c_sqrt_wait[c])sqrt_select=c;end
  scale_req_valid=enabled&&c_active&&((!aborting&&scale_select>=0)||c_scale_offer_valid);scale_req_data=0;scale_req_tag=0;
  if(scale_select>=0)begin
   scale_req_data=c_sum_wait[scale_select]?sum_value[scale_select]:square_sum_value[scale_select];
   scale_req_tag={32'h4c4e5343,op_generation,29'b0,!c_sum_wait[scale_select],2'(scale_select)};
  end
  if(c_scale_offer_valid)begin scale_req_data=c_scale_offer_tag[2]?square_sum_value[c_scale_offer_tag[1:0]]:sum_value[c_scale_offer_tag[1:0]];scale_req_tag={32'h4c4e5343,op_generation,29'b0,c_scale_offer_tag};end
  sqrt_req_valid=enabled&&c_active&&((!aborting&&sqrt_select>=0)||c_sqrt_offer_valid);sqrt_req_data=0;sqrt_req_tag=0;
  if(sqrt_select>=0)begin sqrt_req_data=shift_value[sqrt_select];sqrt_req_tag={32'h4c4e5351,op_generation,30'b0,2'(sqrt_select)};end
  if(c_sqrt_offer_valid)begin sqrt_req_data=shift_value[c_sqrt_offer_ctx];sqrt_req_tag={32'h4c4e5351,op_generation,30'b0,c_sqrt_offer_ctx};end
  // The sqrt result slot itself holds a blocked direct inverse request.
  div_req_valid=enabled&&c_active&&(!aborting||c_div_offer_valid)&&sqrt_rsp_valid&&!sqrt_rsp_error;
  div_req_tag=sqrt_rsp_tag;div_a=32'h3f800000;div_b=sqrt_rsp_data;
  sqrt_rsp_ready=enabled&&c_active&&((aborting&&!c_div_offer_valid)||sqrt_rsp_error||div_req_ready);
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
 laya_m007_ln_div1024_external_v2 scale(.clk,.rst_n,.control_enable(enabled),.control_q(q_view[11941+:5]),.control_next(scale_control_next),
  .req_valid(scale_req_valid),.req_ready(scale_req_ready),.req_data(scale_req_data),.req_tag(scale_req_tag[2:0]),
  .rsp_valid(scale_rsp_valid),.rsp_ready(scale_rsp_ready),.rsp_data(scale_rsp_data),.rsp_error(scale_rsp_error),.rsp_tag(scale_local_tag));
 assign scale_rsp_tag={32'h4c4e5343,c_out_generation,29'b0,scale_local_tag};
 laya_m007_ln_sqrt_external_v2 square_root(.clk,.rst_n,.control_enable(enabled),.control_q(q_view[11946+:13]),.control_next(sqrt_control_next),
  .req_valid(sqrt_req_valid),.req_ready(sqrt_req_ready),.req_data(sqrt_req_data),.req_tag(sqrt_req_tag[1:0]),
  .rsp_valid(sqrt_rsp_valid),.rsp_ready(sqrt_rsp_ready),.rsp_data(sqrt_rsp_data),.rsp_error(sqrt_rsp_error),.rsp_tag(sqrt_local_tag),.busy(sqrt_busy));
 assign sqrt_rsp_tag={32'h4c4e5351,c_out_generation,30'b0,sqrt_local_tag};
 // Count actual issued/consumed semantics for each context, including merged
 // vector transactions. Holding operands are separately included in debt_clear.
 always_comb begin
  for(int c=0;c<4;c++)begin
   add_change[c]=0;mul_change[c]=0;read_change[c]=0;write_change[c]=0;scalar_change[c]=0;
   if(add_req_valid&&add_req_ready)add_change[c]+=meta_count(c_add_hold_valid?decode_add(c_add_hold_meta):add_build_meta,c);
   if(take_add)add_change[c]-=meta_count(am,c);
   if(mul_req_valid&&mul_req_ready)mul_change[c]+=mul_meta_count(c_mul_hold_valid?c_mul_hold_meta:mul_build_meta,c);
   if(take_mul)mul_change[c]-=mul_meta_count(mm,c);
   for(int k=0;k<2;k++)begin
    if(rd_valid&&rd_ready&&rd_tag[k*8+7]&&rd_tag[k*8+5+:2]==c)read_change[c]++;
    if(take_read&&rd_rsp_tag[k*8+7]&&rd_rsp_tag[k*8+5+:2]==c)read_change[c]--;
    if(wr_valid&&wr_ready&&wr_tag[k*8+7]&&wr_tag[k*8+5+:2]==c)write_change[c]++;
    if(wr_rsp_valid&&wr_rsp_ready&&write_match&&!c_protocol_fault&&wr_rsp_tag[k*8+7]&&wr_rsp_tag[k*8+5+:2]==c)write_change[c]--;
   end
   if(scale_req_valid&&scale_req_ready&&scale_req_tag[1:0]==c)scalar_change[c]++;
   if(scale_rsp_valid&&scale_rsp_ready&&scale_rsp_tag[1:0]==c)scalar_change[c]--;
   if(sqrt_req_valid&&sqrt_req_ready&&sqrt_req_tag[1:0]==c)scalar_change[c]++;
   if(sqrt_rsp_valid&&sqrt_rsp_ready&&sqrt_rsp_tag[1:0]==c)scalar_change[c]--;
   if(div_req_valid&&div_req_ready&&div_req_tag[1:0]==c)scalar_change[c]++;
   if(div_rsp_valid&&div_rsp_ready&&div_match&&!c_protocol_fault&&div_rsp_tag[1:0]==c)scalar_change[c]--;
  end
  physical_debt_clear=mul_pending==0&&add_pending==0&&div_pending==0&&bank_idle&&
   !c_add_hold_valid&&!c_mul_hold_valid&&!c_rd_hold_valid&&!c_wr_hold_valid&&!c_out_valid&&
   !sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!c_scale_offer_valid&&!c_sqrt_offer_valid&&!c_div_offer_valid;
  work_debt_clear=mul_pending==0&&add_pending==0&&div_pending==0&&bank_idle&&
   !c_add_hold_valid&&!c_mul_hold_valid&&!c_rd_hold_valid&&!c_wr_hold_valid&&!c_out_valid&&
   !sqrt_busy&&!sqrt_rsp_valid&&!scale_rsp_valid&&!c_scale_offer_valid&&!c_sqrt_offer_valid&&!c_div_offer_valid&&!(|c_sum_wait)&&!(|c_square_sum_wait)&&!(|c_sqrt_wait)&&
   c_add_debt==0&&c_mul_debt==0&&c_read_debt==0&&c_write_debt==0&&c_scalar_debt==0;
  if(c_protocol_fault)work_debt_clear=physical_debt_clear;
  debt_clear=enabled&&work_debt_clear&&!c_active&&!c_done_valid&&!c_reject_pending&&!gamma_loading&&!gamma_done_valid_i;
  control_retired=debt_clear&&!cancel_rsp_valid;
 end
 always_comb begin
  n_active=c_active;
  n_done_valid=c_done_valid;
  n_done_error=c_done_error;
  n_out_valid=c_out_valid;
  n_ctx_active=c_ctx_active;
  n_ctx_row=c_ctx_row;
  n_raw_coverage=c_raw_coverage;
  n_delta_coverage=c_delta_coverage;
  n_raw_read_count=c_raw_read_count;
  n_delta_read_count=c_delta_read_count;
  n_output_count=c_output_count;
  n_sum_wait=c_sum_wait;
  n_square_sum_wait=c_square_sum_wait;
  n_sqrt_wait=c_sqrt_wait;
  n_mean_valid=c_mean_valid;
  n_inverse_valid=c_inverse_valid;
  n_left_valid=c_left_valid;
  n_add_hold_valid=c_add_hold_valid;
  n_mul_hold_valid=c_mul_hold_valid;
  n_rd_hold_valid=c_rd_hold_valid;
  n_wr_hold_valid=c_wr_hold_valid;
  n_add_tail=c_add_tail;
  n_mul_tail=c_mul_tail;
  n_add_debt=c_add_debt;
  n_mul_debt=c_mul_debt;
  n_read_debt=c_read_debt;
  n_write_debt=c_write_debt;
  n_scalar_debt=c_scalar_debt;
  n_cycle_count=c_cycle_count;
  n_peak_add_pending=c_peak_add_pending;
  n_peak_mul_pending=c_peak_mul_pending;
  n_error_order_code=c_error_order_code;
  n_error_level=c_error_level;
  n_error_row=c_error_row;
  n_error_node=c_error_node;
  n_mode_gamma=c_mode_gamma;
  n_rows=c_rows;
  n_input_row=c_input_row;
  n_input_chunk=c_input_chunk;
  n_total_retired=c_total_retired;
  n_next_row_cycle=c_next_row_cycle;
  n_out_request_id=c_out_request_id;
  n_out_generation=c_out_generation;
  n_out_epoch=c_out_epoch;
  n_add_metadata=c_add_metadata;
  n_mul_metadata=c_mul_metadata;
  n_add_hold_meta=c_add_hold_meta;
  n_mul_hold_meta=c_mul_hold_meta;
  n_rd_hold_desc=c_rd_hold_desc;
  n_wr_hold_desc=c_wr_hold_desc;
  n_out_row=c_out_row;
  n_out_chunk=c_out_chunk;
  n_tree_checked=c_tree_checked;
  n_protocol_fault=c_protocol_fault;
  n_protocol_code=c_protocol_code;
  n_protocol_location=c_protocol_location;
  n_source_bad_valid=c_source_bad_valid;
  n_source_bad_row=c_source_bad_row;
  n_source_bad_element=c_source_bad_element;
  n_source_finite_qualified=c_source_finite_qualified;
  n_reject_pending=c_reject_pending;
  n_reject_held_code=c_reject_held_code;
  n_cancel_active=c_cancel_active;
  n_done_kind=c_done_kind;
  n_read_expected_valid=c_read_expected_valid;
  n_read_expected_desc=c_read_expected_desc;
  n_write_expected_valid=c_write_expected_valid;
  n_write_expected_desc=c_write_expected_desc;
  n_scale_offer_valid=c_scale_offer_valid;
  n_scale_offer_tag=c_scale_offer_tag;
  n_sqrt_offer_valid=c_sqrt_offer_valid;
  n_sqrt_offer_ctx=c_sqrt_offer_ctx;
  n_div_offer_valid=c_div_offer_valid;
  n_ctx_failed=c_ctx_failed;
  n_div_expected=c_div_expected;

  if(!rst_n)begin
   n_active = 0;n_done_valid = 0;n_done_error = 0;n_ctx_failed = 0;n_out_valid = 0;
   ;;;;;
   n_ctx_active = 0;n_raw_coverage = 0;n_delta_coverage = 0;n_raw_read_count = 0;n_delta_read_count = 0;n_output_count = 0;
   n_sum_wait = 0;n_square_sum_wait = 0;n_sqrt_wait = 0;n_mean_valid = 0;n_inverse_valid = 0;n_left_valid = 0;
   n_add_hold_valid = 0;n_mul_hold_valid = 0;n_rd_hold_valid = 0;n_wr_hold_valid = 0;n_add_tail = 0;n_mul_tail = 0;
   n_add_debt = 0;n_mul_debt = 0;n_read_debt = 0;n_write_debt = 0;n_scalar_debt = 0;
   n_cycle_count = 0;n_peak_add_pending = 0;n_peak_mul_pending = 0;n_error_order_code = 0;n_error_level = 0;n_error_row = 0;n_error_node = 0;
  end else begin
   if(gamma_done_valid_i&&gamma_done_ready);
   if(gamma_begin_valid&&gamma_begin_ready)begin
    ;;;;;;
   end
   if(gamma_valid&&gamma_ready)begin
    ;;
    if(!gamma_finite)begin ;;;;end
    else if((&(gamma_coverage|(32'b1<<gamma_chunk))))begin ;;;;end
   end
   if(c_done_valid&&done_ready)n_done_valid = 0;
   if(c_out_valid&&out_ready)begin n_out_valid = 0;n_output_count[c_out_row[1:0]] = c_output_count[c_out_row[1:0]]+1'b1;end
   if(cmd_valid&&cmd_ready)begin
    n_active = 1;n_ctx_failed = 0;n_done_error = 0;n_rows = cmd_rows;n_mode_gamma = cmd_gamma;
    n_out_request_id = cmd_request_id;n_out_generation = cmd_generation;n_out_epoch = cmd_epoch;
    n_input_row = 0;n_input_chunk = 0;n_total_retired = 0;n_next_row_cycle = 0;n_cycle_count = 0;
    n_ctx_active = 0;n_raw_coverage = 0;n_delta_coverage = 0;n_raw_read_count = 0;n_delta_read_count = 0;n_output_count = 0;
    n_sum_wait = 0;n_square_sum_wait = 0;n_sqrt_wait = 0;n_mean_valid = 0;n_inverse_valid = 0;n_left_valid = 0;
    n_peak_add_pending = 0;n_peak_mul_pending = 0;
   end
   if(c_active)begin
    n_cycle_count = c_cycle_count+1'b1;
    if(add_pending>c_peak_add_pending)n_peak_add_pending = add_pending;if(mul_pending>c_peak_mul_pending)n_peak_mul_pending = mul_pending;
    for(int c=0;c<4;c++)begin
     n_add_debt[c] = 9'(int'(c_add_debt[c])+add_change[c]);n_mul_debt[c] = 9'(int'(c_mul_debt[c])+mul_change[c]);
     n_read_debt[c] = 7'(int'(c_read_debt[c])+read_change[c]);n_write_debt[c] = 7'(int'(c_write_debt[c])+write_change[c]);
     n_scalar_debt[c] = 4'(int'(c_scalar_debt[c])+scalar_change[c]);
     if(c_ctx_active[c]&&c_output_count[c]==32&&c_add_debt[c]==0&&c_mul_debt[c]==0&&c_read_debt[c]==0&&c_write_debt[c]==0&&c_scalar_debt[c]==0&&
      !c_sum_wait[c]&&!c_square_sum_wait[c]&&!c_sqrt_wait[c])begin n_ctx_active[c] = 0;n_total_retired = c_total_retired+1'b1;end
    end

    if(aborting)begin n_sum_wait = 0;n_square_sum_wait = 0;n_sqrt_wait = 0;end
    if((aborting||c_total_retired==c_rows)&&work_debt_clear)begin n_active = 0;n_ctx_active = 0;n_done_valid = 1;end
    if(take_input)begin

     if(in_chunk==0)begin
      n_ctx_active[in_row[1:0]] = 1;n_ctx_row[in_row[1:0]] = in_row;
      n_raw_coverage[in_row[1:0]] = 0;n_delta_coverage[in_row[1:0]] = 0;
      n_raw_read_count[in_row[1:0]] = 0;n_delta_read_count[in_row[1:0]] = 0;n_output_count[in_row[1:0]] = 0;
      n_mean_valid[in_row[1:0]] = 0;n_inverse_valid[in_row[1:0]] = 0;
      n_left_valid[0][in_row[1:0]] = 0;n_left_valid[1][in_row[1:0]] = 0;
      n_next_row_cycle = c_cycle_count+128;
     end
     if(in_chunk==31)begin n_input_row = c_input_row+1'b1;n_input_chunk = 0;end else n_input_chunk = c_input_chunk+1'b1;
    end
    if(add_req_valid&&add_req_ready)begin n_add_metadata[c_add_tail] = c_add_hold_valid?c_add_hold_meta:encode_add(add_build_meta);n_add_tail = c_add_tail+1'b1;end
    if(mul_req_valid&&mul_req_ready)begin n_mul_metadata[c_mul_tail] = c_mul_hold_valid?c_mul_hold_meta:mul_build_meta;n_mul_tail = c_mul_tail+1'b1;end
    if(c_add_hold_valid)begin if(add_req_ready)n_add_hold_valid = 0;end
    else if(add_build_valid&&!add_req_ready)begin n_add_hold_valid = 1;;;n_add_hold_meta = encode_add(add_build_meta);end
    if(c_mul_hold_valid)begin if(mul_req_ready)n_mul_hold_valid = 0;end
    else if(mul_build_valid&&!mul_req_ready)begin n_mul_hold_valid = 1;;;n_mul_hold_meta = mul_build_meta;end
    if(c_rd_hold_valid)begin if(rd_ready)n_rd_hold_valid = 0;end
    else if((|rd_build_desc)&&!rd_ready)begin n_rd_hold_valid = 1;n_rd_hold_desc = rd_build_desc;end
    // Reserve scheduled reads when captured, not on every stalled cycle.
    if(!c_rd_hold_valid&&(|rd_build_desc))begin
     if(rd_build_desc[7])n_raw_read_count[rd_build_desc[5+:2]] = c_raw_read_count[rd_build_desc[5+:2]]+1'b1;
     if(rd_build_desc[15])n_delta_read_count[rd_build_desc[13+:2]] = c_delta_read_count[rd_build_desc[13+:2]]+1'b1;
    end
    if(c_wr_hold_valid)begin if(wr_ready)n_wr_hold_valid = 0;end
    else if((|wr_build_desc)&&!wr_ready)begin n_wr_hold_valid = 1;n_wr_hold_desc = wr_build_desc;;;end
    if(wr_rsp_valid&&wr_rsp_ready&&write_match&&!c_protocol_fault)begin
     if(wr_rsp_tag[7])n_raw_coverage[wr_rsp_tag[5+:2]][wr_rsp_tag[0+:5]] = 1;
     if(wr_rsp_tag[15])n_delta_coverage[wr_rsp_tag[13+:2]][wr_rsp_tag[8+:5]] = 1;
    end
    if(take_add&&!aborting&&!bad_now)begin
     for(int t=0;t<2;t++)for(int s=4;s<9;s++)if(am[(t*10+s)*8+7])begin
      if(!am[(t*10+s)*8])begin
       ;
       n_left_valid[t][am[(t*10+s)*8+5+:2]][s-4] = 1;
      end else n_left_valid[t][am[(t*10+s)*8+5+:2]][s-4] = 0;
     end
     if(am[9*8+7])begin ;n_sum_wait[am[9*8+5+:2]] = 1;end
     if(am[19*8+7])begin ;n_square_sum_wait[am[19*8+5+:2]] = 1;end
     if(am[21*8+7])begin ;n_sqrt_wait[am[21*8+5+:2]] = 1;end
    end
    if(scale_req_valid&&scale_req_ready)begin
     if(scale_req_tag[2])n_square_sum_wait[scale_req_tag[1:0]] = 0;else n_sum_wait[scale_req_tag[1:0]] = 0;
    end
    if(scale_rsp_valid&&scale_rsp_ready&&!aborting&&!bad_now&&!scale_rsp_tag[2])begin
     ;n_mean_valid[scale_rsp_tag[1:0]] = 1;
    end
    if(sqrt_req_valid&&sqrt_req_ready)n_sqrt_wait[sqrt_req_tag[1:0]] = 0;
    if(div_rsp_valid&&div_rsp_ready&&div_match&&!aborting&&!bad_now)begin ;n_inverse_valid[div_rsp_tag[1:0]] = 1;end
    if(take_mul&&!aborting&&!bad_now&&(mm[23]||(mm[15]&&!c_mode_gamma)))begin
     n_out_valid = 1;
     if(c_mode_gamma)begin
      n_out_row = c_ctx_row[mm[21+:2]];n_out_chunk = mm[16+:5];;
     end else begin
      n_out_row = c_ctx_row[mm[13+:2]];n_out_chunk = mm[8+:5];;
     end
    end
   end
  end
  if(enabled&&rst_n)begin
   if(c_reject_pending&&reject_ready)n_reject_pending=0;
   if(!c_reject_pending)begin
    if(raw_reject!=0)begin n_reject_pending=1;n_reject_held_code=raw_reject;end
    else if(in_valid&&c_active&&in_tag!={16'h4c4e,c_out_epoch,c_out_generation,in_row,in_chunk,4'b0})begin n_reject_pending=1;n_reject_held_code=8;end
    else if(cmd_valid&&((!cmd_source_finite_qualified&&!cmd_source_summary_valid)||(cmd_source_bad_valid&&cmd_source_bad_row>=cmd_rows)))begin n_reject_pending=1;n_reject_held_code=10;end
    else if(cancel_valid&&!cancel_ready)begin n_reject_pending=1;n_reject_held_code=11;end
   end
   if(cmd_valid&&cmd_ready)begin
    n_ctx_failed=0;n_protocol_fault=0;n_protocol_code=0;n_protocol_location=0;
    n_cancel_active=0;n_done_kind=0;n_tree_checked=0;n_div_expected=0;n_scale_offer_valid=0;n_scale_offer_tag=0;n_sqrt_offer_valid=0;n_sqrt_offer_ctx=0;n_div_offer_valid=0;
    n_read_expected_valid=0;n_write_expected_valid=0;
    n_source_finite_qualified=cmd_source_finite_qualified;n_source_bad_valid=cmd_source_bad_valid;
    n_source_bad_row=cmd_source_bad_row;n_source_bad_element=cmd_source_bad_element;
   end
   if(scale_req_valid&&scale_req_ready)n_scale_offer_valid=0;
   else if(scale_req_valid&&!c_scale_offer_valid)begin n_scale_offer_valid=1;n_scale_offer_tag=scale_req_tag[2:0];end
   if(sqrt_req_valid&&sqrt_req_ready)n_sqrt_offer_valid=0;
   else if(sqrt_req_valid&&!c_sqrt_offer_valid)begin n_sqrt_offer_valid=1;n_sqrt_offer_ctx=sqrt_req_tag[1:0];end
   if(div_req_valid&&div_req_ready)n_div_offer_valid=0;
   else if(div_req_valid&&!c_div_offer_valid)n_div_offer_valid=1;
   if(rd_rsp_valid&&rd_rsp_ready&&read_match)n_read_expected_valid=0;
   if(wr_rsp_valid&&wr_rsp_ready&&write_match)n_write_expected_valid=0;
   if(rd_valid&&rd_ready)begin n_read_expected_valid=1;n_read_expected_desc=rd_tag[15:0];end
   if(wr_valid&&wr_ready)begin n_write_expected_valid=1;n_write_expected_desc=wr_tag[15:0];end
   if(div_rsp_valid&&div_rsp_ready&&div_match)n_div_expected[div_rsp_tag[1:0]]=0;
   if(div_req_valid&&div_req_ready)n_div_expected[div_req_tag[1:0]]=1;
   if(cancel_fire)begin n_cancel_active=1;n_done_error=1;n_done_kind=c_protocol_fault?2:3;end
   if(bad_now&&!aborting)begin
    n_ctx_failed[bad_ctx]=1;n_done_error=1;n_done_kind=1;
    n_error_order_code=order_code(bad_stage);n_error_level=bad_level;n_error_row=bad_row;n_error_node=bad_node;
    n_sum_wait=0;n_square_sum_wait=0;n_sqrt_wait=0;
   end
   if(proto_now)begin
    n_protocol_fault=1;n_protocol_code=proto_code_now;n_protocol_location=proto_location_now;n_done_error=1;n_done_kind=2;
   end
   if(c_protocol_fault&&physical_debt_clear)begin
    n_add_debt=0;n_mul_debt=0;n_read_debt=0;n_write_debt=0;n_scalar_debt=0;
    n_read_expected_valid=0;n_write_expected_valid=0;n_div_expected=0;
   end
  end
  if(!rst_n)begin
   n_ctx_failed=0;n_tree_checked=0;n_protocol_fault=0;n_protocol_code=0;n_protocol_location=0;
   n_source_bad_valid=0;n_source_bad_row=0;n_source_bad_element=0;n_source_finite_qualified=0;
   n_reject_pending=0;n_reject_held_code=0;n_cancel_active=0;n_done_kind=0;n_scale_offer_valid=0;n_scale_offer_tag=0;n_sqrt_offer_valid=0;n_sqrt_offer_ctx=0;n_div_offer_valid=0;
   n_read_expected_valid=0;n_read_expected_desc=0;n_write_expected_valid=0;n_write_expected_desc=0;n_div_expected=0;
  end

 end always_ff@(posedge clk)if(!rst_n||enabled)begin
  if(!rst_n)begin
   ;;;;;
   gamma_loading<=0;gamma_loaded<=0;gamma_coverage<=0;gamma_done_valid_i<=0;gamma_done_error<=0;
   ;;;;;;
   ;;;;;;
   ;;;;;;
   ;;;;;
   ;;;;;;;
  end else begin
   if(gamma_done_valid_i&&gamma_done_ready)gamma_done_valid_i<=0;
   if(gamma_begin_valid&&gamma_begin_ready)begin
    held_model<=gamma_model;held_key<=gamma_key;gamma_loading<=1;gamma_loaded<=0;gamma_coverage<=0;gamma_done_error<=0;
   end
   if(gamma_valid&&gamma_ready)begin
    gamma_mem[gamma_chunk]<=gamma_data;gamma_coverage[gamma_chunk]<=1;
    if(!gamma_finite)begin gamma_loading<=0;gamma_done_valid_i<=1;gamma_done_error<=1;gamma_loaded<=0;end
    else if((&(gamma_coverage|(32'b1<<gamma_chunk))))begin gamma_loading<=0;gamma_done_valid_i<=1;gamma_done_error<=0;gamma_loaded<=1;end
   end
   if(c_done_valid&&done_ready);
   if(c_out_valid&&out_ready)begin ;;end
   if(cmd_valid&&cmd_ready)begin
    ;;;;;
    ;;;
    ;;;;;
    ;;;;;;
    ;;;;;;
    ;;
   end
   if(c_active)begin
    ;
    if(add_pending>c_peak_add_pending);if(mul_pending>c_peak_mul_pending);
    for(int c=0;c<4;c++)begin
     ;;
     ;;
     ;
     if(c_ctx_active[c]&&c_output_count[c]==32&&c_add_debt[c]==0&&c_mul_debt[c]==0&&c_read_debt[c]==0&&c_write_debt[c]==0&&c_scalar_debt[c]==0&&
      !c_sum_wait[c]&&!c_square_sum_wait[c]&&!c_sqrt_wait[c])begin ;;end
    end

    if(aborting)begin ;;;end
    if((aborting||c_total_retired==c_rows)&&work_debt_clear)begin ;;;end
    if(take_input)begin

     if(in_chunk==0)begin
      ;;
      ;;
      ;;;
      ;;
      ;;
      ;
     end
     if(in_chunk==31)begin ;;end else ;
    end
    if(add_req_valid&&add_req_ready)begin ;;end
    if(mul_req_valid&&mul_req_ready)begin ;;end
    if(c_add_hold_valid)begin if(add_req_ready);end
    else if(add_build_valid&&!add_req_ready)begin ;add_hold_a<=add_build_a;add_hold_b<=add_build_b;;end
    if(c_mul_hold_valid)begin if(mul_req_ready);end
    else if(mul_build_valid&&!mul_req_ready)begin ;mul_hold_a<=mul_build_a;mul_hold_b<=mul_build_b;;end
    if(c_rd_hold_valid)begin if(rd_ready);end
    else if((|rd_build_desc)&&!rd_ready)begin ;;end
    // Reserve scheduled reads when captured, not on every stalled cycle.
    if(!c_rd_hold_valid&&(|rd_build_desc))begin
     if(rd_build_desc[7]);
     if(rd_build_desc[15]);
    end
    if(c_wr_hold_valid)begin if(wr_ready);end
    else if((|wr_build_desc)&&!wr_ready)begin ;;wr_hold_raw<=wr_build_raw;wr_hold_delta<=wr_build_delta;end
    if(wr_rsp_valid&&wr_rsp_ready&&write_match&&!c_protocol_fault)begin
     if(wr_rsp_tag[7]);
     if(wr_rsp_tag[15]);
    end
    if(take_add&&!aborting&&!bad_now)begin
     for(int t=0;t<2;t++)for(int s=4;s<9;s++)if(am[(t*10+s)*8+7])begin
      if(!am[(t*10+s)*8])begin
       left_value[t][am[(t*10+s)*8+5+:2]][s-4]<=add_rsp_data[t*36+lane_start(s)];
       ;
      end else ;
     end
     if(am[9*8+7])begin sum_value[am[9*8+5+:2]]<=add_rsp_data[35];;end
     if(am[19*8+7])begin square_sum_value[am[19*8+5+:2]]<=add_rsp_data[71];;end
     if(am[21*8+7])begin shift_value[am[21*8+5+:2]]<=add_rsp_data[104];;end
    end
    if(scale_req_valid&&scale_req_ready)begin
     if(scale_req_tag[2]);else ;
    end
    if(scale_rsp_valid&&scale_rsp_ready&&!aborting&&!bad_now&&!scale_rsp_tag[2])begin
     mean_value[scale_rsp_tag[1:0]]<=scale_rsp_data;;
    end
    if(sqrt_req_valid&&sqrt_req_ready);
    if(div_rsp_valid&&div_rsp_ready&&div_match&&!aborting&&!bad_now)begin inverse_value[div_rsp_tag[1:0]]<=div_rsp_data;;end
    if(take_mul&&!aborting&&!bad_now&&(mm[23]||(mm[15]&&!c_mode_gamma)))begin
     ;
     if(c_mode_gamma)begin
      ;;out_data<=mul_rsp_data[64+:32];
     end else begin
      ;;out_data<=mul_rsp_data[32+:32];
     end
    end
   end
  end
 end always_comb begin
  q_next=q_view;
  if(enabled)begin
   q_next[0+:1]=n_active;
   q_next[1+:1]=n_done_valid;
   q_next[2+:1]=n_done_error;
   q_next[4+:1]=n_out_valid;
   q_next[5+:4]=n_ctx_active;
   q_next[9+:28]=n_ctx_row;
   q_next[37+:128]=n_raw_coverage;
   q_next[165+:128]=n_delta_coverage;
   q_next[293+:24]=n_raw_read_count;
   q_next[317+:24]=n_delta_read_count;
   q_next[341+:24]=n_output_count;
   q_next[365+:4]=n_sum_wait;
   q_next[369+:4]=n_square_sum_wait;
   q_next[373+:4]=n_sqrt_wait;
   q_next[377+:4]=n_mean_valid;
   q_next[381+:4]=n_inverse_valid;
   q_next[385+:40]=n_left_valid;
   q_next[425+:1]=n_add_hold_valid;
   q_next[426+:1]=n_mul_hold_valid;
   q_next[427+:1]=n_rd_hold_valid;
   q_next[428+:1]=n_wr_hold_valid;
   q_next[429+:6]=n_add_tail;
   q_next[435+:6]=n_mul_tail;
   q_next[441+:36]=n_add_debt;
   q_next[477+:36]=n_mul_debt;
   q_next[513+:28]=n_read_debt;
   q_next[541+:28]=n_write_debt;
   q_next[569+:16]=n_scalar_debt;
   q_next[585+:32]=n_cycle_count;
   q_next[617+:7]=n_peak_add_pending;
   q_next[624+:7]=n_peak_mul_pending;
   q_next[631+:5]=n_error_order_code;
   q_next[636+:4]=n_error_level;
   q_next[640+:7]=n_error_row;
   q_next[647+:10]=n_error_node;
   q_next[657+:1]=n_mode_gamma;
   q_next[658+:8]=n_rows;
   q_next[666+:8]=n_input_row;
   q_next[674+:5]=n_input_chunk;
   q_next[679+:8]=n_total_retired;
   q_next[687+:32]=n_next_row_cycle;
   q_next[719+:64]=n_out_request_id;
   q_next[783+:32]=n_out_generation;
   q_next[815+:32]=n_out_epoch;
   q_next[847+:9344]=n_add_metadata;
   q_next[10191+:1536]=n_mul_metadata;
   q_next[11727+:146]=n_add_hold_meta;
   q_next[11873+:24]=n_mul_hold_meta;
   q_next[11897+:16]=n_rd_hold_desc;
   q_next[11913+:16]=n_wr_hold_desc;
   q_next[11929+:7]=n_out_row;
   q_next[11936+:5]=n_out_chunk;
   q_next[11962+:80]=n_tree_checked;
   q_next[12042+:1]=n_protocol_fault;
   q_next[12043+:4]=n_protocol_code;
   q_next[12047+:8]=n_protocol_location;
   q_next[12055+:1]=n_source_bad_valid;
   q_next[12056+:7]=n_source_bad_row;
   q_next[12063+:10]=n_source_bad_element;
   q_next[12073+:1]=n_source_finite_qualified;
   q_next[12074+:1]=n_reject_pending;
   q_next[12075+:4]=n_reject_held_code;
   q_next[12079+:1]=n_cancel_active;
   q_next[12080+:2]=n_done_kind;
   q_next[12082+:1]=n_read_expected_valid;
   q_next[12083+:16]=n_read_expected_desc;
   q_next[12099+:1]=n_write_expected_valid;
   q_next[12100+:16]=n_write_expected_desc;
   q_next[12120+:1]=n_scale_offer_valid;
   q_next[12121+:3]=n_scale_offer_tag;
   q_next[12124+:1]=n_sqrt_offer_valid;
   q_next[12125+:2]=n_sqrt_offer_ctx;
   q_next[12127+:1]=n_div_offer_valid;
   q_next[3]=n_ctx_failed[0];q_next[11959+:3]=n_ctx_failed[3:1];
   q_next[11941+:5]=scale_control_next;q_next[11946+:13]=sqrt_control_next;
   q_next[12116+:4]=n_div_expected;
   if(!rst_n)q_next=0;
   else if(control_clear&&control_retired)q_next=0;
  end
 end

endmodule

// Public local codec verification wrapper. These are the exact production
// functions above; this wrapper adds no engine state and cannot inject faults.
module laya_m007_ln_compact_codec_v1(
 input logic[175:0]full,output logic[145:0]encoded,
 output logic[175:0]decoded,output logic encoding_ok
);
 function automatic integer item_width(input integer s);
  return s<5?8:s<10?12-s:8;
 endfunction
 function automatic logic[145:0]encode_add(input logic[175:0]full);
  logic[145:0]packed_meta;integer off,w;packed_meta=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;
   packed_meta[off+w-1]=full[k*8+7];packed_meta[off+w-3+:2]=full[k*8+5+:2];
   for(int b=0;b<5;b++)if(b<w-3)packed_meta[off+b]=full[k*8+b];off+=w;
  end
  return packed_meta;
 endfunction
 function automatic logic[175:0]decode_add(input logic[145:0]compact);
  logic[175:0]full;integer off,w;full=0;off=0;
  for(int k=0;k<22;k++)begin
   w=k<20?item_width(k%10):8;full[k*8+7]=compact[off+w-1];full[k*8+5+:2]=compact[off+w-3+:2];
   for(int b=0;b<5;b++)if(b<w-3)full[k*8+b]=compact[off+b];off+=w;
  end
  return full;
 endfunction
 function automatic logic add_encoding_ok(input logic[175:0]full);
  logic ok;integer w;ok=1;
  for(int k=0;k<20;k++)begin w=item_width(k%10);if(full[k*8+7])for(int b=0;b<5;b++)if(b>=w-3&&full[k*8+b])ok=0;end
  return ok;
 endfunction

 always_comb begin encoded=encode_add(full);decoded=decode_add(encoded);encoding_ok=add_encoding_ok(full);end
endmodule
