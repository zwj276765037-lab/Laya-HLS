#!/usr/bin/env python3
"""Compose the sole-resource M007 parent; shared owners' source is read-only."""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
OUT=BASE/'forward_controller/rtl/laya_m007_single_parent_v1.sv'
def ports(file):
 s=Path(file).read_text();s=s[s.index('(',s.index('module '))+1:];
 if s.lstrip().startswith('parameter'):s=s[s.index(')(')+2:]
 s=s[:s.index(');')];s=re.sub(r'//[^\n]*','',s)
 out={};direction=None;width=''
 for item in s.split(','):
  item=item.strip();m=re.match(r'(input|output|inout)\s+(?:logic|wire)?\s*((?:\[[^\]]+\]\s*)*)(\w+)$',item)
  if m:direction,width,name=m.groups()
  else:
   assert re.fullmatch(r'\w+',item),(file,item);name=item
  out[name]=(direction,width.strip())
 return out
F=BASE/'q8_linear_and_restore/rtl';A=BASE/'attention_and_fp_engine/rtl'
P={k:ports(f) for k,f in [('l',A/'laya_attention_layer_engine_v1.sv'),('m',F/'laya_m007_matrix_facade_v1.sv'),('q',F/'laya_m007_quant_a_fill_v1.sv'),('r',A/'laya_attention_resources_v1.sv')]}
# Fixed complete external identities are elaboration parameters bound to the deployment manifest.
header='''`timescale 1ns/1ps
module laya_m007_single_parent_v1 #(
 parameter logic [127:0] MODEL_ID=128'h6eb6ef58bc4f99bd9db40381604108af,
 parameter logic [127:0] NUMERIC_ID=128'haeb13e7937d29fe6a2c68c407249f294,
 parameter logic [127:0] TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965,
 parameter logic [127:0] GRAPH_ID=128'hf33f7848434b73048f957dcd232e1bd4,
 parameter logic [127:0] LAYOUT_ID=128'h2d848b5fb78236c795cb1d442f088393,
 parameter logic [127:0] BUILD_ID=128'h7209eb09c3f265363cfb274f7790a733
)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,
 input logic [63:0] cmd_request,input logic [31:0] cmd_generation,cmd_epoch,
 input logic [127:0] cmd_model_id,cmd_numeric_id,cmd_table_key,cmd_graph_id,cmd_layout_id,cmd_build_id,
 input logic [1:0] cmd_kind,input logic [4:0] cmd_layer,input logic [127:0] cmd_mask,
 input logic [1:0][31:0] cmd_tensor,
 input logic [1:0][3:0][63:0] cmd_base,cmd_span,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 output logic input_reject_valid,output logic [3:0] input_reject_code,
 input logic producer_fail_valid,input logic [95:0] producer_fail_tuple,
 input logic [63:0] producer_fail_request,input logic [31:0] producer_fail_generation,producer_fail_epoch,
 output logic producer_fail_ready,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,
 output logic done_valid,input logic done_ready,output logic [7:0] done_status,
 output logic [2:0] error_domain,output logic [95:0] error_tuple,
 output logic [7:0] source_status,
 input logic [127:0] bias_model_id,bias_numeric_id,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [4:0] parent_state,output logic [31:0] elapsed_cycles,
 output logic [15:0] layer_head_completed,
'''
# Preserve public coefficient and W interfaces; body maps each explicitly.
public={}
compat=ports(A/'laya_attention_layer_v1.sv')
for n,v in compat.items():
 if n.startswith('coeff_'):public[n]=v
for n,v in P['m'].items():
 if n.startswith(('coef_','ar','rv','rr','ri','rd','rl')) and (n.startswith('coef_') or n in ['arvalid','arready','araddr','arid','arlen','rvalid','rready','rid','rdata','rresp','rlast']):public[n]=v
header+=',\n'.join(' '+d+' logic '+w+' '+n for n,(d,w) in public.items())+'\n);\n'
# Compact keys derive from the original tensor catalog, never caller-selected shape aliases.
catalog=json.loads((Path(__file__).with_name('tensor_catalog.json')).read_text())
tensor_function=""" function automatic logic [31:0] tensor_key(input logic [1:0] k,input logic [4:0] l,input logic wo);
  case({k==2,l,wo})
   7'd0:return 32'd4; // qkv.0.weight
   7'd2:return 32'd5; // qkv.1.weight
   7'd4:return 32'd6; // qkv.2.weight
   7'd6:return 32'd7; // qkv.3.weight
   7'd8:return 32'd8; // qkv.4.weight
   7'd10:return 32'd9; // qkv.5.weight
   7'd12:return 32'd10; // qkv.6.weight
   7'd14:return 32'd11; // qkv.7.weight
   7'd16:return 32'd12; // qkv.8.weight
   7'd18:return 32'd13; // qkv.9.weight
   7'd20:return 32'd14; // qkv.10.weight
   7'd22:return 32'd15; // qkv.11.weight
   7'd24:return 32'd16; // qkv.12.weight
   7'd26:return 32'd17; // qkv.13.weight
   7'd28:return 32'd18; // qkv.14.weight
   7'd30:return 32'd19; // qkv.15.weight
   7'd32:return 32'd20; // qkv.16.weight
   7'd34:return 32'd21; // qkv.17.weight
   7'd36:return 32'd22; // qkv.18.weight
   7'd38:return 32'd23; // qkv.19.weight
   7'd40:return 32'd24; // qkv.20.weight
   7'd42:return 32'd25; // qkv.21.weight
   7'd44:return 32'd26; // qkv.22.weight
   7'd46:return 32'd27; // qkv.23.weight
   7'd48:return 32'd28; // qkv.24.weight
   7'd50:return 32'd29; // qkv.25.weight
   7'd52:return 32'd30; // qkv.26.weight
   7'd54:return 32'd31; // qkv.27.weight
   7'd1:return 32'd32; // wo.0.weight
   7'd3:return 32'd33; // wo.1.weight
   7'd5:return 32'd34; // wo.2.weight
   7'd7:return 32'd35; // wo.3.weight
   7'd9:return 32'd36; // wo.4.weight
   7'd11:return 32'd37; // wo.5.weight
   7'd13:return 32'd38; // wo.6.weight
   7'd15:return 32'd39; // wo.7.weight
   7'd17:return 32'd40; // wo.8.weight
   7'd19:return 32'd41; // wo.9.weight
   7'd21:return 32'd42; // wo.10.weight
   7'd23:return 32'd43; // wo.11.weight
   7'd25:return 32'd44; // wo.12.weight
   7'd27:return 32'd45; // wo.13.weight
   7'd29:return 32'd46; // wo.14.weight
   7'd31:return 32'd47; // wo.15.weight
   7'd33:return 32'd48; // wo.16.weight
   7'd35:return 32'd49; // wo.17.weight
   7'd37:return 32'd50; // wo.18.weight
   7'd39:return 32'd51; // wo.19.weight
   7'd41:return 32'd52; // wo.20.weight
   7'd43:return 32'd53; // wo.21.weight
   7'd45:return 32'd54; // wo.22.weight
   7'd47:return 32'd55; // wo.23.weight
   7'd49:return 32'd56; // wo.24.weight
   7'd51:return 32'd57; // wo.25.weight
   7'd53:return 32'd58; // wo.26.weight
   7'd55:return 32'd59; // wo.27.weight
   7'd64:return 32'd117; // head_qkv.0.weight
   7'd66:return 32'd119; // head_qkv.1.weight
   7'd65:return 32'd121; // head_wo.0.weight
   7'd67:return 32'd123; // head_wo.1.weight
   default:return 0;
  endcase
 endfunction"""
lines=[header,tensor_function]
for pref,ps in P.items():
 for n,(d,w) in ps.items():
  if n not in ['clk','rst_n']:lines.append(' logic '+w+' '+pref+'_'+n+';\n')
lines.append('''
 localparam [4:0] IDLE=0,PREP=1,QSUB=2,QRUN=3,QMSUB=4,QMRUN=5,LSTART=6,LRUN=7,CSUB=8,CRUN=9,CDRAIN=10,WMSUB=11,WMRUN=12,PCANCEL=13,PCWAIT=14,DISCARD=15,DISCWAIT=16,FINISH=17,ACANCEL=18,ACWAIT=19;
 logic [4:0] state;
 logic [63:0] request_id;logic [31:0] generation,epoch;
 logic [1:0] kind;logic [4:0] layer_index;logic [127:0] mask;
 logic [1:0][31:0] tensor_id;logic [1:0][3:0][63:0] base,span;
 logic [12:0] inputs_accepted;
 logic producer_failed,context_failed;
 wire producer_fail_fire=producer_fail_valid&&producer_fail_ready;
 wire producer_failure=producer_failed||producer_fail_fire;
 function automatic logic [7:0] matrix_status_map(input logic [2:0] v);
  case(v)0:return 0;1:return 5;2:return 1;default:return 2;endcase
 endfunction
 function automatic logic [7:0] layer_status_map(input logic [7:0] v);
  case(v)0:return 0;1:return 1;2:return 6;default:return 2;endcase
 endfunction
 wire context_phase=state==CSUB||state==CRUN||state==CDRAIN||state==DISCARD||state==DISCWAIT;
 wire matrix_owner=state>=QSUB&&state<=QMRUN||state==WMSUB||state==WMRUN;
 wire front_owner=matrix_owner||context_phase;
 wire wo_phase=state==WMSUB||state==WMRUN;
 wire legal_input=state==QRUN&&!producer_failed&&inputs_accepted<4096&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row=={1'b0,inputs_accepted[11:5]}&&in_group=={3'b0,inputs_accepted[4:0]};
 wire identity_ok=cmd_model_id==MODEL_ID&&cmd_numeric_id==NUMERIC_ID&&cmd_table_key==TABLE_KEY&&cmd_graph_id==GRAPH_ID&&cmd_layout_id==LAYOUT_ID&&cmd_build_id==BUILD_ID;
 wire tables_ready=cmd_kind==2||(coeff_bound_valid&&coeff_bound_model_id==MODEL_ID&&coeff_bound_numeric_id==NUMERIC_ID&&coeff_bound_table_key==TABLE_KEY&&coeff_family_complete[cmd_kind==1]);
 logic spans_ok;
 always_comb begin
  spans_ok=1;
  for(int t=0;t<2;t++)for(int p=0;p<4;p++)begin
   if(cmd_base[t][p][11:0]!=0||cmd_span[t][p]<(t==0?64'd884736:64'd294912)||({1'b0,cmd_base[t][p]}+{1'b0,cmd_span[t][p]})>65'hffffffffffffffff)spans_ok=0;
  end
 end
 wire tensor_ok=cmd_tensor[0]==tensor_key(cmd_kind,cmd_layer,0)&&cmd_tensor[1]==tensor_key(cmd_kind,cmd_layer,1);
 wire bias_identity_ok=bias_model_id==MODEL_ID&&bias_numeric_id==NUMERIC_ID&&coef_model==MODEL_ID[63:0]&&coef_request==(state==IDLE?cmd_request:request_id)&&coef_generation==(state==IDLE?cmd_generation:generation)&&coef_epoch==(state==IDLE?cmd_epoch:epoch)&&coef_tensor==tensor_key(state==IDLE?cmd_kind:kind,state==IDLE?cmd_layer:layer_index,coef_n==1024)&&((coef_n==3072&&state==IDLE)||(coef_n==1024&&(state==IDLE||state==LRUN||state==CSUB||state==CRUN||state==CDRAIN)));
 wire kind_ok=(cmd_kind==0&&cmd_layer<28&&cmd_layer%3==0)||(cmd_kind==1&&cmd_layer<28&&cmd_layer%3!=0)||(cmd_kind==2&&cmd_layer<2);
 logic c_rd_valid,c_rd_ready,c_rsp_valid,c_rsp_ready,c_out_valid,c_out_ready,c_idle,c_complete,c_fault,c_start_ready;
 logic [31:0] c_rd_generation,c_rd_tag,c_rsp_tag;logic [3:0] c_rd_head;logic [6:0] c_rd_query;logic c_rd_half;
 logic [31:0][31:0] c_rsp_data,c_out_data;logic [7:0] c_out_row,c_out_group;logic [12:0] c_accepted,c_consumed;
 assign parent_state=state;
 assign cmd_ready=rst_n&&state==IDLE&&l_layer_idle&&!coef_cfg_valid&&!coef_wr_valid;
 assign done_valid=state==FINISH;
 assign done_request=request_id;assign done_generation=generation;assign done_epoch=epoch;
 assign producer_fail_ready=rst_n&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch&&(state==QRUN||state==QMRUN||state==CRUN);
 assign in_ready=legal_input&&q_in_ready;
 assign input_reject_valid=rst_n&&in_valid&&!legal_input;
 assign input_reject_code=state!=QRUN?1:in_request!=request_id?2:in_generation!=generation?3:in_epoch!=epoch?4:in_row!={1'b0,inputs_accepted[11:5]}?5:6;
 assign out_valid=state==WMRUN&&m_out_valid;assign out_data=m_out_data;assign out_row=m_out_row;assign out_col=m_out_col;
 assign layer_head_completed=l_head_completed;
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;request_id<=0;generation<=0;epoch<=0;kind<=0;layer_index<=0;mask<=0;tensor_id<=0;base<=0;span<=0;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;end
  else begin
   if(state!=IDLE&&state!=FINISH)elapsed_cycles<=elapsed_cycles+1;
   if(cmd_valid&&cmd_ready)begin
    request_id<=cmd_request;generation<=cmd_generation;epoch<=cmd_epoch;kind<=cmd_kind;layer_index<=cmd_layer;mask<=cmd_mask;tensor_id<=cmd_tensor;base<=cmd_base;span<=cmd_span;inputs_accepted<=0;producer_failed<=0;context_failed<=0;done_status<=0;error_domain<=0;error_tuple<=0;source_status<=0;elapsed_cycles<=0;
    if(!identity_ok||!kind_ok||!tensor_ok)begin state<=FINISH;done_status<=4;error_domain<=1;end else if(!tables_ready||!spans_ok)begin state<=FINISH;done_status<=5;source_status<=1;error_domain<=1;end else state<=PREP;
   end
   if(producer_fail_fire)begin producer_failed<=1;done_status<=3;source_status<=3;error_domain<=2;error_tuple<=producer_fail_tuple;end
   if(in_valid&&in_ready)inputs_accepted<=inputs_accepted+1;
   if(state==PREP&&l_prepare_valid&&l_prepare_ready)state<=QSUB;
   if(state==QSUB)begin
    if(!m_descriptor_precheck_ok)begin state<=PCANCEL;done_status<=5;source_status<=1;error_domain<=1;end
    else if(q_cmd_valid&&q_cmd_ready)state<=QRUN;
   end
   if(state==QRUN&&q_done_valid&&q_done_ready)begin
    if(q_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end else state<=QMSUB;
   end
   if(state==QMSUB&&m_cmd_valid&&m_cmd_ready)state<=QMRUN;
   if(state==QMRUN&&m_done_valid&&m_done_ready)begin
    if(m_status!=0||producer_failure)begin
     state<=producer_failure?ACANCEL:PCANCEL;
     if(!producer_failure)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
    end else state<=LSTART;
   end
   if(state==ACANCEL&&m_fill_cancel_valid&&m_fill_cancel_ready)state<=ACWAIT;
   if(state==ACWAIT&&m_fill_cancel_rsp_valid&&m_fill_cancel_rsp_ready)state<=PCANCEL;
   if(state==PCANCEL&&l_prepare_cancel_valid&&l_prepare_cancel_ready)state<=PCWAIT;
   if(state==PCWAIT&&l_prepare_cancel_rsp_valid&&l_prepare_cancel_rsp_ready)state<=DISCWAIT;
   if(state==LSTART&&l_start_valid&&l_start_ready)state<=LRUN;
   if(state==LRUN&&l_done_valid&&l_done_ready)begin
    if(l_done_status!=0)begin state<=DISCWAIT;done_status<=layer_status_map(l_done_status);source_status<=l_done_status;error_domain<=5;error_tuple<=l_error_tuple;end
    else state<=CSUB;
   end
   if(state==CSUB&&q_cmd_valid&&q_cmd_ready&&c_start_ready)begin state<=CRUN;inputs_accepted<=0;end
   if(state==CRUN&&q_done_valid&&q_done_ready)begin
    state<=CDRAIN;
    if(q_status!=0||producer_failure||c_fault)begin context_failed<=1;if(!producer_failure)begin done_status<=q_status==0?2:matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'b0,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
   end
   if(state==CDRAIN&&c_idle)begin
    if(context_failed)begin if(l_layer_idle)state<=FINISH;else state<=DISCARD;end
    else if(c_complete&&l_layer_idle)state<=WMSUB;
   end
   if(state==DISCARD&&l_result_discard_valid&&l_result_discard_ready)state<=DISCWAIT;
   if(state==DISCWAIT&&l_layer_idle)state<=FINISH;
   if(state==WMSUB&&m_cmd_valid&&m_cmd_ready)state<=WMRUN;
   if(state==WMRUN&&m_done_valid&&m_done_ready)begin state<=FINISH;done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=m_status==0?0:4;error_tuple<={8'b0,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
   if(done_valid&&done_ready)state<=IDLE;
  end
 end
''')
assign={}
def setp(pref,n,v):assert n in P[pref],(pref,n);assert (pref,n) not in assign,(pref,n);assign[pref,n]=v
# Layer public inputs, with no compatibility shell instances.
lvals={'prepare_valid':'state==PREP','prepare_request_id':'request_id','prepare_model_id':'MODEL_ID','prepare_generation':'generation','prepare_epoch':'epoch','prepare_numeric_id':'NUMERIC_ID','prepare_table_key':'TABLE_KEY','prepare_kind':'kind','prepare_layer':'layer_index','prepare_mask':'mask','qkv_wr_valid':'state==QMRUN&&m_out_valid','qkv_wr_request_id':'m_out_request','qkv_wr_generation':'m_out_generation','qkv_wr_epoch':'m_out_epoch','qkv_wr_plane':'m_out_col[11:10]','qkv_wr_head':'m_out_col[9:6]','qkv_wr_token':'m_out_row','qkv_wr_half':'m_out_col[5]','qkv_wr_data':'m_out_data','start_valid':'state==LSTART','start_request_id':'request_id','start_generation':'generation','abort_valid':"1'b0",'qkv_read_grant':"3'b111",'done_ready':'state==LRUN','result_rd_valid':'c_rd_valid','result_rd_generation':'c_rd_generation','result_rd_tag':'c_rd_tag','result_rd_head':'c_rd_head','result_rd_query':'c_rd_query','result_rd_half':'c_rd_half','result_rsp_ready':'c_rsp_ready','result_discard_valid':'state==DISCARD','result_discard_generation':'generation','prepare_cancel_valid':'state==PCANCEL','prepare_cancel_request_id':'request_id','prepare_cancel_generation':'generation','prepare_cancel_epoch':'epoch','prepare_cancel_rsp_ready':'state==PCWAIT'}
for n in ['ps_grant','g_grant','context_grant','fp_grant','sfu_grant','exp_grant','div_grant','rope_write_grant']:lvals[n]="1'b1"
for n,v in lvals.items():setp('l',n,v)
for n in ['valid','model_id','numeric_id','table_key']:setp('l','cache_bound_'+n,'coeff_bound_'+n)
setp('l','cache_family_complete','coeff_family_complete')
# Actual quant/A one instance used for initial input and context.
qvals={'run_enable':"1'b1",'cmd_valid':'(state==QSUB&&m_descriptor_precheck_ok)||(state==CSUB&&c_start_ready)','cmd_slot':"1'b0",'cmd_k':"16'd1024",'cmd_request':'request_id','cmd_generation':'generation','cmd_epoch':'epoch','in_valid':'state==CRUN?c_out_valid:(in_valid&&legal_input)','in_data':'state==CRUN?c_out_data:in_data','in_request':'request_id','in_generation':'generation','in_epoch':'epoch','in_row':'state==CRUN?c_out_row:in_row','in_group':'state==CRUN?c_out_group:in_group','producer_close_valid':'(state==QRUN&&(inputs_accepted==4096||producer_failed))||(state==CRUN&&(c_complete||producer_failed||c_fault))','producer_close_success':'!producer_failed&&!c_fault','done_ready':'state==QRUN||state==CRUN'}
for n,v in qvals.items():setp('q',n,v)
# Fill/A ports are point-to-point, no added cache or acknowledgements.
for n,(d,w) in P['q'].items():
 if n.startswith(('acfg_','awr_','fill_cancel_')):
  if d=='input':setp('q',n,"(state==ACANCEL||state==ACWAIT)?'0:m_"+n if n.startswith('fill_cancel_') else 'm_'+n)
  else:
   cleanup={'fill_cancel_valid':'state==ACANCEL','fill_cancel_slot':"1'b0",'fill_cancel_request':'request_id','fill_cancel_generation':'generation','fill_cancel_epoch':'epoch','fill_cancel_rsp_ready':"1'b1"}
   setp('m',n,'(state==ACANCEL||state==ACWAIT)?('+cleanup[n]+'):q_'+n if n in cleanup else 'q_'+n)
# Matrix command selection retains original sole facade precheck/leases.
mvals={'cmd_valid':'state==QMSUB||state==WMSUB','cmd_version':"32'd1",'cmd_request':'request_id','cmd_model':'MODEL_ID[63:0]','cmd_generation':'generation','cmd_epoch':'epoch','cmd_tensor':'tensor_id[wo_phase]','cmd_k':"16'd1024",'cmd_n':"wo_phase?16'd1024:16'd3072",'cmd_a_slot':"1'b0",'cmd_bias':"kind==2",'cmd_base':'base[wo_phase]','cmd_span':'span[wo_phase]','done_ready':'state==QMRUN||state==WMRUN','out_ready':'state==QMRUN?l_qkv_wr_ready:(state==WMRUN&&out_ready)','run_enable':"1'b1"}
for n,v in mvals.items():setp('m',n,v)
for n in public:
 if n in P['m']:
  if P['m'][n][0]=='input':setp('m',n,'coef_cfg_valid&&bias_identity_ok' if n=='coef_cfg_valid' else n)
  else:lines.append(' assign '+n+'='+('m_coef_cfg_ready&&bias_identity_ok' if n=='coef_cfg_ready' else 'm_'+n)+';\n')
# Sole coefficient cache, same public identity and owner path as compatibility.
compat_s=(A/'laya_attention_layer_v1.sv').read_text();cache=compat_s[compat_s.index(' laya_rope_coeff_cache_v1 coeff'):];cache=cache[:cache.index(';')+1]
for n in sorted(P['l'],key=len,reverse=True):
 if n.startswith('cache_'):cache=re.sub(r'(?<=\()'+n+r'(?=\))','l_'+n,cache)
lines.append(cache+'\n')
# Resource paths independently selected. QKV/context/coeff are always layer-public.
mm={'res_fp_lease_valid':'m_bind_new_lease','res_fp_lease_request_id':'m_fp_owner_request','res_fp_lease_generation':'m_fp_owner_generation','res_fp_lease_epoch':'m_fp_owner_epoch','res_fp_lease_head':"4'b0",'res_fp_lease_phase':"3'd1",'res_fp_release_valid':'m_fp_release_valid','res_fp_release_phase':"3'd1",'res_fp_release_epoch':'m_fp_owner_epoch','res_fp_phase_debt_clear':'m_fp_phase_debt_clear','res_fp_mul_req_phase':"3'd1",'res_fp_mul_req_epoch':'m_fp_owner_epoch','res_st_bind_valid':'m_bind_new_lease','res_st_bind_request_id':'m_fp_owner_request','res_st_bind_generation':'m_fp_owner_generation','res_st_bind_epoch':'m_fp_owner_epoch','res_st_bind_head':"4'b0",'res_st_bind_phase':"3'd1",'res_st_op_request_id':'m_fp_owner_request','res_st_op_generation':'m_fp_owner_generation','res_st_op_epoch':'m_fp_owner_epoch','res_st_op_phase':"3'd1"}
# Generate common numerical request/response mapping by actual port names.
for n,(d,w) in P['r'].items():
 if n.startswith('res_fp_'):
  tail=n[len('res_fp_'):];mname={'lease_ready':'fp_lease_ready','release_ready':'fp_release_ready','lease_active':'fp_lease_active','draining':'fp_draining','protocol_fault':'fp_fault'}.get(tail,tail)
  if mname in P['m']:mm[n]='m_'+mname
 elif n.startswith('res_st_ps_'):
  if n[7:] in P['m']:mm[n]='m_'+n[7:]
 elif n=='res_st_bind_ready':mm[n]='m_storage_bind_ready'
 elif n=='res_st_idle':mm[n]='m_storage_idle'
for n,(d,w) in P['r'].items():
 if n in ['clk','rst_n']:continue
 if n.startswith('res_div_'):
  qn='d_'+n[len('res_div_'):]
  assert qn in P['q'],(n,qn)
  if d=='input':setp('r',n,'front_owner?q_'+qn+':l_'+n)
  else:
   setp('q',qn,'r_'+n if n in ['res_div_lease_active','res_div_draining','res_div_rsp_request_id','res_div_rsp_generation','res_div_rsp_epoch','res_div_rsp_head','res_div_rsp_phase','res_div_rsp_lane_mask','res_div_protocol_reject_code'] else '(front_owner?r_'+n+":'0)")
   if n in P['l']:setp('l',n,'r_'+n if n=='res_div_lease_active' else "(front_owner?'0:r_"+n+')')
 elif n in mm:
  mapped=mm[n]
  if d=='input':setp('r',n,'matrix_owner?'+mapped+':l_'+n)
  else:
   setp('m',mapped[2:],'r_'+n if n in ['res_st_idle','res_fp_lease_active','res_fp_draining','res_fp_protocol_fault'] else "(matrix_owner?r_"+n+":'0)")
   setp('l',n,'r_'+n if n in ['res_st_idle','res_fp_lease_active','res_fp_draining'] else "(matrix_owner?'0:r_"+n+')')
 else:
  if n not in P['l']:raise AssertionError(('unmapped physical',n))
  if d=='input':setp('r',n,'l_'+n)
  else:setp('l',n,'r_'+n)
# Matrix never uses storage/FP owner-return fields; gate only layer response.
# Cache public outputs already drive through the sole cache instance.
for pref,ps in P.items():
 for n,(d,w) in ps.items():
  if n in ['clk','rst_n']:continue
  if (pref,n) in assign:lines.append(' assign '+pref+'_'+n+'='+assign[pref,n]+';\n')
  elif d=='input':
   if pref=='l' and n.startswith('cache_'):pass # sole cache instance drives
   elif pref=='r':raise AssertionError(('resource input undriven',n))
   else:raise AssertionError(('input undriven',pref,n))
lines.append('''
 assign c_rd_ready=l_result_rd_ready;assign c_rsp_valid=l_result_rsp_valid;assign c_rsp_tag=l_result_rsp_tag;assign c_rsp_data=l_result_rsp_data;
 assign c_out_ready=state==CRUN&&q_in_ready;
 laya_m007_context_quant_adapter_v1 context_adapter(
  .clk,.rst_n,.start_valid(state==CSUB&&q_cmd_valid&&q_cmd_ready),.start_ready(c_start_ready),.generation,.cancel(producer_failed||c_fault||context_failed),
  .rd_valid(c_rd_valid),.rd_ready(c_rd_ready),.rd_generation(c_rd_generation),.rd_tag(c_rd_tag),.rd_head(c_rd_head),.rd_query(c_rd_query),.rd_half(c_rd_half),
  .rsp_valid(c_rsp_valid),.rsp_ready(c_rsp_ready),.rsp_tag(c_rsp_tag),.rsp_data(c_rsp_data),.out_valid(c_out_valid),.out_ready(c_out_ready),.out_data(c_out_data),.out_row(c_out_row),.out_group(c_out_group),
  .idle(c_idle),.complete(c_complete),.protocol_fault(c_fault),.accepted_reads(c_accepted),.consumed_groups(c_consumed));
''')
for pref,mod in [('l','laya_attention_layer_engine_v1'),('m','laya_m007_matrix_facade_v1'),('q','laya_m007_quant_a_fill_v1'),('r','laya_attention_resources_v1')]:
 lines.append(' '+mod+(' #(.PROFILE_ENABLE(0))' if pref=='m' else '')+' '+{'l':'layer','m':'matrix','q':'front','r':'resources'}[pref]+'(\n'+',\n'.join(' .'+n+'('+(''+n if n in ['clk','rst_n'] else pref+'_'+n)+')' for n in P[pref])+'\n );\n')
lines.append('endmodule\n');OUT.write_text(''.join(lines))
report={'source':str(OUT.relative_to(ROOT)),'ports':P,'explicit_assignments':{p+'_'+n:v for (p,n),v in assign.items()},'ownership':'parent only; shared sources read-only','resource_routing':'FP/PS/storage bind per matrix_owner; DIV independently front_owner; layer QKV/context/cache path unmasked'}
(ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001/reports/parent_port_map.json').write_text(json.dumps(report,indent=2)+'\n')
print('M007_PARENT_SOURCE_COMPOSED',len(assign),'actual input connections; no tool result')
