#!/usr/bin/env python3
"""Owned deterministic kind3 extension; shared implementations remain read-only."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005'
parent=MOD/'forward_controller/rtl/laya_m007_single_parent_v1.sv';baseline=RUN/'reports/parent_e354_before_ffn.sv';receipt=RUN/'reports/ffn_parent_generation.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
if not baseline.exists():
 assert sha(parent)=='e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8';baseline.write_bytes(parent.read_bytes())
else:assert sha(parent)==(json.loads(receipt.read_text())['parent_sha256']if receipt.exists()else sha(baseline)),'Unexpected owned-file drift; preserve others work'
s=baseline.read_text()
manifest=ROOT/'project/E002_Laya_HLS/experiment/build/model-q8-session-v2-actual-r2-20261010/manifest.json';assert sha(manifest)=='46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
catalog=json.loads((ROOT/'project/E016_m007_single_resource_parent/experiment_source/tensor_catalog.json').read_text());tensors=json.loads(manifest.read_text())['tensors'];keys={t['name']:i+1 for i,t in enumerate(tensors)}
for name in ['mlp_wi.0.weight','mlp_wo.0.weight']:
 if not any(r['name']==name for r in catalog['records']):
  i=keys[name]-1;catalog['records'].append({'key':i+1,'manifest_array_index':i,**tensors[i]})
(RUN/'reports/ffn_tensor_catalog.json').write_text(json.dumps(catalog,indent=2)+'\n')
(ROOT/'project/E016_m007_single_resource_parent/experiment_source/tensor_catalog.json').write_text(json.dumps(catalog,indent=2)+'\n')
s=s.replace('case({k==2,l,wo})',f"if(k==3)return l==0?(wo?32'd{keys['mlp_wo.0.weight']}:32'd{keys['mlp_wi.0.weight']}):32'hffffffff;\n  case({{k==2,l,wo}})",1)
joint=MOD/'attention_and_fp_engine/rtl/laya_m007_control_workspace_joint_v1.sv';header=joint.read_text().split(');',1)[0]
gp=[];direction=None;width=''
for token in header[header.index('(')+1:].split(','):
 token=token.strip();m=re.match(r'(input|output)\s+logic\s*((?:\[[^\]]+\]\s*)*)(\w+)$',token)
 if m:direction,width,name=m.group(1),m.group(2).strip(),m.group(3)
 else:
  assert re.fullmatch(r'\w+',token),token
  name=token
 if name.startswith('g_'):gp.append((name,width))
assert len(gp)>80
match=re.search(r'\n\s*laya_attention_layer_engine_v1 layer\([\s\S]*?\n\s*\);',s);assert match
begin,end=match.span();old=match.group()
connections=re.findall(r'\.(\w+)\(([^)]+)\)',old)
bindings=[f'   .{p if p in ["clk","rst_n"] else "a_"+p}({v})'for p,v in connections]
bindings+=['   .owner_req_valid(ws_owner_req_valid)', '   .owner_req_g(ws_owner_req_g)', '   .owner_req_ready(ws_owner_req_ready)', '   .a_enable(ws_a_enable)', '   .g_enable(ws_g_enable)', '   .rearm(ws_rearm)', '   .owner_g(ws_owner_g)']+[f'   .{p}({p})'for p,w in gp]
s=s[:begin]+'  laya_m007_control_workspace_joint_v1 layer(\n'+',\n'.join(bindings)+'\n  );'+s[end:]
decl='\n'.join('  logic '+(w+' 'if w else'')+p+';'for p,w in gp)+'''
  logic ws_owner_req_valid,ws_owner_req_g,ws_owner_req_ready,ws_a_enable,ws_g_enable,ws_rearm,ws_owner_g;
  logic [15:0] pack_seq; logic pack_full,pack_fault,g_cancel_sent,q_close_sent;
  logic [31:0][31:0] pack_data;
  wire [15:0] pack_previous=pack_seq-1'b1;
  wire ffn_mode=kind==3;
  wire ffn_state=state>=20;

  wire [8:0] tanh_pending,tanh_flight;
  logic tanh_lease_ready,tanh_lease_active,tanh_draining,tanh_release_ready;
  logic [63:0] tanh_request;logic [31:0] tanh_generation,tanh_epoch;logic [2:0] tanh_phase;
  logic [7:0] tanh_rsp_mask;logic [1:0] tanh_reject_code;
  wire g_all_covered=&{g_covered[0]==335872,g_covered[1]==335872,g_covered[2]==335872,g_covered[3]==335872,g_covered[4]==335872,g_covered[5]==335872,g_covered[6]==335872,g_covered[7]==335872};
  wire g_output_fire=g_out_valid&&g_out_ready;
  wire ffn_close_fire=q_producer_close_valid&&q_producer_close_ready;
  wire ffn_failure=pack_fault||g_protocol_fault||done_status!=0;
'''
s=s.replace('localparam [4:0] IDLE=',decl+'  localparam [4:0] IDLE=',1)
s=s.replace('logic [4:0] state;','localparam [4:0] F_ARENA=20,F_NQSUB=21,F_NQRUN=22,F_WISUB=23,F_GQSUB=24,F_RUN=25,F_CLOSE=26,F_QDRAIN=27,F_ABORT=28,F_DISCARD=29,F_RELEASE=30,F_RETURN=31;\n  logic [4:0] state;',1)
def assignment(name,value):
 global s
 # Retain every legacy expression exactly; only kind3 selects the new branch.
 if name.startswith(('m_','q_'))or name=='l_qkv_wr_valid':
  original=re.search(r'assign '+re.escape(name)+r'\s*=(.*?);',baseline.read_text()).group(1)
  value='ffn_mode?('+value+'):('+original+')'
 pattern=r'assign '+re.escape(name)+r'\s*=.*?;';s,n=re.subn(pattern,'assign '+name+'='+value+';',s,count=1);assert n,name
s=s.replace('wire matrix_owner=state>=QSUB&&state<=QMRUN||state==WMSUB||state==WMRUN;', 'wire matrix_owner=(state>=QSUB&&state<=QMRUN)||state==WMSUB||state==WMRUN||ffn_state;')
s=s.replace('wire legal_input=state==QRUN', 'wire legal_input=(state==QRUN||state==F_NQRUN)')
s=s.replace('wire tables_ready=cmd_kind==2||','wire tables_ready=cmd_kind==3||cmd_kind==2||')
s=s.replace('(t==0?64\'d884736:64\'d294912)',"(cmd_kind==3?(t==0?64'd1511424:64'd755712):(t==0?64'd884736:64'd294912))")
s=s.replace('(cmd_kind==2&&cmd_layer<2);','(cmd_kind==2&&cmd_layer<2)||(cmd_kind==3&&cmd_layer==0);')
s=s.replace('else state<=PREP;','else state<=cmd_kind==3?F_ARENA:PREP;',1)
s=s.replace('state==QRUN||state==QMRUN||state==CRUN)', 'state==QRUN||state==QMRUN||state==CRUN||state==F_NQRUN)')
s=s.replace('if(state==WMRUN&&m_done_valid&&m_done_ready)begin state<=FINISH;', 'if(state==WMRUN&&m_done_valid&&m_done_ready)begin state<=ffn_mode?F_RETURN:FINISH;')
ffsm='''
    if(state==F_ARENA&&ws_g_enable)state<=F_NQSUB;
    if(state==F_NQSUB&&q_cmd_valid&&q_cmd_ready)state<=F_NQRUN;
    if(state==F_NQRUN&&q_done_valid&&q_done_ready)begin
     if(q_status!=0||producer_failure)begin state<=F_RELEASE;if(!producer_failure)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd1,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end end
     else state<=F_WISUB;
    end
    if(state==F_WISUB&&m_cmd_valid&&m_cmd_ready)state<=F_GQSUB;
    if(state==F_GQSUB&&g_cmd_valid&&g_cmd_ready&&q_cmd_valid&&q_cmd_ready)state<=F_RUN;
    if((state==F_RUN||state==F_GQSUB)&&(pack_fault||g_protocol_fault||(m_done_valid&&m_status!=0)))state<=F_ABORT;
    if(state==F_RUN&&m_done_valid&&m_status==0&&g_done_valid)begin
     if(g_done_status!=0||g_done_cancelled)state<=F_ABORT;
     else if(pack_seq==41984&&!pack_full&&g_all_covered&&q_quant_accepted==10496)state<=F_CLOSE;
    end
    if(state==F_CLOSE&&ffn_close_fire)state<=F_QDRAIN;
    if(state==F_QDRAIN&&q_done_valid&&q_done_ready)begin
     state<=F_RELEASE;
     if(q_status!=0)begin done_status<=matrix_status_map(q_status);source_status<={5'b0,q_status};error_domain<=3;error_tuple<={8'd4,16'(q_quant_phase),16'(q_quant_row),16'(q_quant_group),16'(q_quant_element),24'b0};end
    end
    if(state==F_ABORT)begin
     if(m_done_valid&&m_done_ready&&m_status!=0)begin done_status<=matrix_status_map(m_status);source_status<={5'b0,m_status};error_domain<=4;error_tuple<={8'd2,16'(m_error_stage),16'(m_error_row),m_error_col,16'(m_error_group),24'b0};end
     else if(g_done_valid&&g_done_ready&&error_domain!=4)begin done_status<=g_done_status==6?8'd1:8'd2;source_status<=g_done_status==6?8'd6:8'd8;error_domain<=6;error_tuple<={8'd3,16'(g_done_error_rank),16'(g_done_error_row),16'(g_done_error_column),16'b0,24'b0};end
     else if((pack_fault||g_protocol_fault)&&done_status==0)begin done_status<=2;source_status<=8;error_domain<=7;error_tuple<={8'd3,56'b0,16'b0,pack_seq};end
     if(m_cmd_ready&&!g_active&&!g_done_valid&&q_cmd_ready&&(g_needs_discard||g_engine_idle))state<=F_DISCARD;
    end
    if(state==F_DISCARD&&(!g_needs_discard||(g_discard_valid&&g_discard_ready)))state<=F_RELEASE;
    if(state==F_RELEASE&&g_engine_idle&&!tanh_lease_active&&r_res_st_idle&&!r_res_fp_lease_active&&!r_res_div_lease_active&&m_cmd_ready&&q_cmd_ready)state<=done_status==0?WMSUB:F_RETURN;
    if(state==F_RETURN&&ws_a_enable)state<=FINISH;
'''
s=s.replace('if(done_valid&&done_ready)state<=IDLE;',ffsm+'    if(done_valid&&done_ready)state<=IDLE;',1)
assignment('m_cmd_valid','state==QMSUB||state==WMSUB||state==F_WISUB')
assignment('m_cmd_k',"ffn_mode&&wo_phase?16'd2624:16'd1024")
assignment('m_cmd_n',"wo_phase?16'd1024:(ffn_mode?16'd5248:16'd3072)")
assignment('m_cmd_a_slot',"ffn_mode&&wo_phase")
assignment('m_done_ready','state==QMRUN||state==WMRUN||(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT')
assignment('m_out_ready','ffn_mode?(wo_phase?out_ready:(state==F_ABORT?1\'b1:g_fill_ready)):wo_phase?out_ready:l_qkv_wr_ready')
assignment('l_qkv_wr_valid','!ffn_mode&&state==QMRUN&&m_out_valid')
assignment('q_cmd_valid','state==QSUB||state==CSUB||state==F_NQSUB||(state==F_GQSUB&&g_cmd_ready)')
assignment('q_cmd_k',"state==F_GQSUB?16'd2624:16'd1024")
assignment('q_cmd_slot',"state==F_GQSUB")
assignment('q_in_valid',"ffn_mode?((state==F_NQRUN)?(in_valid&&legal_input):((state==F_RUN||state==F_CLOSE||state==F_ABORT)&&pack_full&&!q_close_sent)):(context_phase?c_out_valid:(in_valid&&legal_input))")
assignment('q_in_data','ffn_mode&&state!=F_NQRUN?pack_data:context_phase?c_out_data:in_data')
assignment('q_in_row',"ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[8:2]}:context_phase?c_out_row:in_row")
assignment('q_in_group',"ffn_mode&&state!=F_NQRUN?{1'b0,pack_previous[15:9]}:context_phase?c_out_group:in_group")
# Existing source identity ports are assigned to the latched parent context.
assignment('q_producer_close_valid',"ffn_mode?((state==F_NQRUN)&&(inputs_accepted==4096||producer_failure)||(state==F_CLOSE)||(state==F_ABORT&&!q_close_sent&&!q_cmd_ready&&!q_done_valid)):(state==QRUN&&(inputs_accepted==4096||producer_failure)||state==CRUN&&(c_complete||producer_failure||c_fault))")
assignment('q_producer_close_success',"ffn_mode?(state!=F_ABORT&&!producer_failure):(!producer_failure&&!c_fault)")
assignment('q_done_ready','state==QRUN||state==CRUN||state==F_NQRUN||state==F_QDRAIN||state==F_ABORT')
for suffix in ['wr_valid','wr_mask','wr_addr','wr_data','wr_tag','wr_rsp_ready','rd_valid','rd_mask','rd_addr','rd_tag','rd_rsp_ready']:
 assignment('r_res_st_g_'+suffix,'ffn_mode?g_g_'+suffix+':l_res_st_g_'+suffix)
new='''
  assign ws_owner_req_valid=state==F_ARENA||state==F_RETURN;
  assign ws_owner_req_g=state==F_ARENA;
  assign g_cmd_valid=state==F_GQSUB&&q_cmd_ready;
  assign g_cmd_request_id=request_id;assign g_cmd_generation=generation;assign g_cmd_epoch=epoch;
  assign g_storage_owner_valid=ffn_mode&&r_res_fp_lease_active&&r_res_fp_rsp_request_id==request_id&&r_res_fp_rsp_generation==generation&&r_res_fp_rsp_epoch==epoch;
  assign g_storage_owner_request_id=r_res_st_rsp_request_id;assign g_storage_owner_generation=r_res_st_rsp_generation;assign g_storage_owner_epoch=r_res_st_rsp_epoch;assign g_storage_owner_phase=r_res_st_rsp_phase;
  assign g_sfu_owner_valid=tanh_lease_active;assign g_sfu_owner_request_id=tanh_request;assign g_sfu_owner_generation=tanh_generation;assign g_sfu_owner_epoch=tanh_epoch;assign g_sfu_owner_phase=tanh_phase;
  assign g_fill_valid=ffn_mode&&g_active&&state!=F_ABORT&&m_out_valid&&!wo_phase;
  assign g_fill_request_id=m_out_request;assign g_fill_generation=m_out_generation;assign g_fill_epoch=m_out_epoch;
  assign g_fill_slot=m_out_s[0];assign g_fill_s=m_out_s[6:0];assign g_fill_half=m_out_col>=2624;assign g_fill_row=m_out_row;assign g_fill_data=m_out_data;
  assign g_out_ready=state==F_ABORT?1'b1:((state==F_RUN||state==F_CLOSE)&&(!pack_full||q_in_ready)&&pack_seq<41984);
  assign g_done_ready=(state==F_CLOSE&&ffn_close_fire)||state==F_ABORT;
  assign g_producer_cancel_valid=state==F_ABORT&&g_active&&!g_cancel_sent;
  assign g_producer_cancel_request_id=request_id;assign g_producer_cancel_generation=generation;assign g_producer_cancel_epoch=epoch;
  assign g_discard_valid=state==F_DISCARD&&g_needs_discard;
  assign g_discard_request_id=request_id;assign g_discard_generation=generation;assign g_discard_epoch=epoch;
  always_ff @(posedge clk)begin
   if(!rst_n)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
   else begin
    if(cmd_valid&&cmd_ready)begin pack_seq<=0;pack_full<=0;pack_fault<=0;g_cancel_sent<=0;q_close_sent<=0;end
    if(q_in_valid&&q_in_ready&&ffn_mode&&state!=F_NQRUN)pack_full<=0;
    if(g_output_fire&&state!=F_ABORT)begin
     if(g_out_tag!={generation,epoch,16'b0,pack_seq})pack_fault<=1;
     pack_data[8*pack_seq[1:0]+:8]<=g_out_data;pack_seq<=pack_seq+1'b1;
     if(pack_seq[1:0]==3)pack_full<=1;
    end
    if(g_producer_cancel_valid&&g_producer_cancel_ready)g_cancel_sent<=1;
    if(ffn_close_fire&&ffn_mode&&state!=F_NQRUN)begin q_close_sent<=1;if(state==F_ABORT)pack_full<=0;end
   end
  end
  laya_m007_g_vector_pool_v1 g_pool(.clk,.rst_n(g_pool_reset_n),.req_valid(g_fp_req_valid),.req_ready(g_fp_req_ready),.req_tag(g_fp_req_tag),.req_a(g_fp_req_a),.req_b(g_fp_req_b),.rsp_valid(g_fp_rsp_valid),.rsp_tag(g_fp_rsp_tag),.rsp_data(g_fp_rsp_data),.rsp_status(g_fp_rsp_status),.protocol_fault(g_fp_pool_fault));
  laya_m007_tanh8_v1 g_tanh(.clk,.rst_n,.lease_valid(state==F_GQSUB&&!tanh_lease_active&&ws_g_enable),.lease_ready(tanh_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_phase(3'd1),
   .release_valid(state==F_RELEASE&&tanh_lease_active&&g_engine_idle&&r_res_st_idle&&tanh_pending==0&&tanh_flight==0),.release_ready(tanh_release_ready),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(g_engine_idle&&r_res_st_idle),
   .lease_active(tanh_lease_active),.draining(tanh_draining),.rsp_request_id(tanh_request),.rsp_generation(tanh_generation),.rsp_epoch(tanh_epoch),.rsp_phase(tanh_phase),
   .req_valid(g_sfu_req_valid),.req_ready(g_sfu_req_ready),.req_mode(2'd1),.req_request_id(g_rsp_request_id),.req_generation(g_rsp_generation),.req_epoch(g_rsp_epoch),.req_phase(3'd1),.req_tag(g_sfu_req_tag),.req_mask(g_sfu_req_mask),.req_x(g_sfu_req_x),
   .reject_valid(g_sfu_reject_valid),.reject_code(tanh_reject_code),.rsp_valid(g_sfu_rsp_valid),.rsp_ready(g_sfu_rsp_ready),.rsp_tag(g_sfu_rsp_tag),.rsp_mask(tanh_rsp_mask),.rsp_data(g_sfu_rsp_data),.rsp_status(g_sfu_rsp_status),.pending_vectors(tanh_pending),.in_flight_vectors(tanh_flight),.protocol_fault(g_sfu_protocol_fault));
'''
for suffix in ['wr_ready','wr_rsp_valid','wr_rsp_tag','rd_ready','rd_rsp_valid','rd_rsp_data','rd_rsp_mask','rd_rsp_tag']:
 new+='  assign g_g_'+suffix+'=ffn_mode?r_res_st_g_'+suffix+":'0;\n"
s,n=re.subn(r'\n\s*endmodule\s*$',new+'\nendmodule\n',s);assert n==1
parent.write_text(s);receipt.write_text(json.dumps({'parent_sha256':sha(parent),'baseline_sha256':sha(baseline),'joint_source_sha256':sha(joint),'tensor_keys':{n:keys[n]for n in ['mlp_wi.0.weight','mlp_wo.0.weight']},'added_control_bits':20,'payload_bits':1024,'joint_G_ports':len(gp),'scope':'generated production extension, not compiled/tested yet'},indent=2)+'\n')
print(receipt.read_text())
