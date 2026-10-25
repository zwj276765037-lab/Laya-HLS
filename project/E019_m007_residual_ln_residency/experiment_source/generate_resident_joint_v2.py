from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[3]
M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
A=M/'attention_and_fp_engine/rtl'
# Source-only public interface generation; no compilation or EDA is performed.
def ports(path):
 s=re.sub(r'//[^\n]*','',path.read_text());h=s[:s.index(');')];p=h.index('(',h.index('module '))
 if '#' in h[:p]:
  depth=0
  for i in range(p,len(h)):
   if h[i]=='(':depth+=1
   elif h[i]==')':
    depth-=1
    if depth==0:p=h.index('(',i+1);break
 out=[];di=None;dims=''
 for item in h[p+1:].split(','):
  x=item.strip();m=re.fullmatch(r'(input|output)\s+(?:logic\s*)?((?:\[[^\]]+\]\s*)*)(\w+)',x)
  if m:di,dims,n=m.groups()
  else:assert re.fullmatch(r'\w+',x),x;n=x
  out.append((di,dims.strip(),n))
 return out
jp=ports(A/'laya_m007_control_workspace_joint_v2.sv');rp=ports(A/'laya_attention_resources_v1.sv');cp=ports(A/'laya_rope_coeff_cache_v1.sv')
pub=[]
def add(di,dims,n):
 assert n not in {p[2]for p in pub},n
 pub.append((di,dims,n))
def scalar(di,*names):
 for n in names:add(di,'',n)
scalar('input','clk','rst_n','owner_req_valid');add('input','[1:0]','owner_req')
scalar('output','owner_req_ready');add('output','[1:0]','owner');scalar('output','rearm','a_enable','g_enable','ln_enable','vector_enable')
scalar('input','resident_owner_valid');add('input','[63:0]','resident_owner_request_id');add('input','[31:0]','resident_owner_generation');add('input','[31:0]','resident_owner_epoch')
scalar('input','resident_inputs_ready','parent_matrix_retired','parent_quant_retired')
add('input','[63:0]','resident_access_request_id');add('input','[31:0]','resident_access_generation');add('input','[31:0]','resident_access_epoch')
for pre in ['h','q']:
 scalar('input',pre+'_wr_valid');scalar('output',pre+'_wr_ready',pre+'_wr_commit');add('input','[11:0]',pre+'_wr_addr');add('input','[31:0][31:0]',pre+'_wr_data')
 scalar('input',pre+'_rd_valid');scalar('output',pre+'_rd_ready');add('input','[11:0]',pre+'_rd_addr');scalar('output',pre+'_rsp_valid');scalar('input',pre+'_rsp_ready');add('output','[11:0]',pre+'_rsp_addr');add('output','[31:0][31:0]',pre+'_rsp_data');scalar('output',pre+'_reject_valid')
scalar('input','scratch_lease_valid','scratch_release_valid');scalar('output','scratch_lease_ready','scratch_release_ready','scratch_owner_active','scratch_retired','h_bank_idle','resident_bank_idle','shared_resources_idle','ln_provider_idle')
# Consumer public command/status bundles. Real resource ports are private wires.
a_exclude=('a_res_','a_rope_','a_cache_')
g_internal=('g_storage_owner_','g_sfu_owner_','g_fp_','g_sfu_req_','g_sfu_rsp_','g_sfu_protocol_','g_sfu_reject_','g_g_wr','g_g_rd')
vector_keep={'vector_start_valid','vector_start_ready','vector_start_op','vector_start_request_id','vector_start_generation','vector_start_epoch','vector_start_reject_valid','vector_done_valid','vector_done_ready','vector_done_status','vector_done_error_row','vector_done_error_column','vector_idle','vector_issued_vectors','vector_retired_vectors'}
ln_keep_prefix=('ln_gamma_','ln_error_','ln_protocol_','ln_trace_','ln_ctx_','ln_raw_','ln_delta_','ln_cycle_','ln_peak_')
ln_keep={'ln_reject_valid','ln_reject_code','ln_reject_ready','ln_cancel_valid','ln_cancel_ready','ln_cancel_request_id','ln_cancel_generation','ln_cancel_epoch','ln_done_valid','ln_done_error','ln_done_kind','ln_cancel_rsp_valid','ln_active','ln_debt_clear'}
for di,dims,n in jp:
 keep=(n.startswith('a_') and not n.startswith(a_exclude)) or (n.startswith('g_') and not n.startswith(g_internal) and n!='g_pool_reset_n') or n in vector_keep or n.startswith(ln_keep_prefix) or n in ln_keep
 # rope_cycles/write_grant are consumer diagnostics/grants, not cache traffic.
 if n in ['a_rope_cycles','a_rope_write_grant']:keep=True
 if keep and n not in {p[2]for p in pub}:add(di,dims,n)
for di,dims,n in cp:
 if n in ['clk','rst_n']or n.startswith(('owner_','rd_','rsp_')):continue
 add(di,dims,'coeff_'+n)
# Provider command parameters borrow parent-owned stable values until DONE consume.
scalar('input','resident_ln_start_valid');scalar('output','resident_ln_start_ready');add('input','[7:0]','resident_ln_rows');scalar('input','resident_ln_use_gamma');add('input','[63:0]','resident_ln_model');add('input','[31:0]','resident_ln_key')
scalar('output','resident_ln_done_valid');scalar('input','resident_ln_done_ready');add('output','[31:0]','resident_ln_done_status');add('output','[1:0]','resident_ln_done_kind');scalar('output','resident_ln_source_qualified');add('output','[12:0]','resident_ln_issued_vectors');add('output','[12:0]','resident_ln_written_vectors')
# Separate services preserve simultaneous matrix PS and G bank traffic.
for domain in ['fp','div','bind','ps','context']:scalar('input','ext_'+domain+'_select')
def ext_domain(n):
 if n.startswith('res_fp_'):return 'fp'
 if n.startswith('res_div_'):return 'div'
 if n.startswith('res_st_bind_')or n.startswith('res_st_op_')or n.startswith('res_st_rsp_')or n=='res_st_idle':return 'bind'
 if n.startswith('res_st_ps_'):return 'ps'
 if n.startswith('res_st_context_'):return 'context'
 return None
for di,dims,n in rp:
 if ext_domain(n):add(di,dims,'ext_'+n)
# G TANH resource lease; G request/response path is wired internally.
scalar('input','g_tanh_lease_valid');scalar('output','g_tanh_lease_ready');add('input','[63:0]','g_tanh_lease_request_id');add('input','[31:0]','g_tanh_lease_generation');add('input','[31:0]','g_tanh_lease_epoch');add('input','[2:0]','g_tanh_lease_phase')
scalar('input','g_tanh_release_valid');scalar('output','g_tanh_release_ready');add('input','[2:0]','g_tanh_release_phase');add('input','[31:0]','g_tanh_release_epoch');scalar('input','g_tanh_phase_debt_clear');scalar('output','g_tanh_lease_active','g_tanh_draining');add('output','[8:0]','g_tanh_pending_vectors');add('output','[8:0]','g_tanh_in_flight_vectors')
header='''`timescale 1ns/1ps
// Public production bundle v1, source preparation only; not yet compiled.
// Exactly one four-owner arena, one physical resource shell, H and Q alias.
module laya_m007_resident_joint_v2(
'''+',\n'.join(f' {di} logic {dims} {n}'for di,dims,n in pub)+'\n);\n'
(A/'laya_m007_resident_joint_v2_header.svh').write_text(header)
manifest={'schema':'m007-resident-joint-v2-public-v1','stage':'HEADER_FROZEN_IMPLEMENTATION_IN_PROGRESS_NOT_COMPILED','module':'laya_m007_resident_joint_v2','ports':pub,'domains':['fp','div','bind','ps','context'],'parent_responsibility':['resident owner identity held across all active banks/providers','H/Q complete load and projection-write counters and finite H input qualification','parent matrix and quant actual retirement probes','scratch release then epoch update then reacquire without payload clearing','ext selects stable until actual matching service retirement'],'wrapper_responsibility':['one physical arena/resources/H/Q/VECTOR/LN','finite witness from real VECTOR DONE status0 with issued/retired4096 and physical H idle','synchronous held H/Q responses','all consumer to resource routing and real switch barriers'],'state_added_by_public_bundle':0}
(Path(__file__).parent/'resident_joint_v2_public_ports_v1.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('public_ports',len(pub),'header_sha256',hashlib.sha256(header.encode()).hexdigest())
# The body is generated from the same exact public/consumer/resource headers.
# All routing is combinational; no owner or response shadow registers are added.
s=header+' parameter bit TANH_FORCE_CORE_CE=0;\n'
pubnames={p[2]for p in pub};jointnames={p[2]for p in jp};rnames={p[2]for p in rp}
assigned={};declared=set(pubnames);declarations=[]
def emit(x):
 global s;s+=x+'\n'
def decl(dims,n):
 if n in declared:return
 declared.add(n);declarations.append(f' logic {dims} {n};')
def assign(n,x):
 assert n not in assigned,(n,assigned.get(n),x)
 assigned[n]=x;emit(f' assign {n}={x};')
jmap={n:n for di,dims,n in jp}
# Gate ordinary A admissions while its Q plane is leased as scratch.
for base in ['prepare','qkv_wr','start','result_rd']:
 for suffix in ['valid','ready']:
  n='a_'+base+'_'+suffix
  jmap[n]='j_'+n;decl('',jmap[n])
 assign(jmap['a_'+base+'_valid'],'a_'+base+'_valid&&scratch_normal_enable')
 assign('a_'+base+'_ready',jmap['a_'+base+'_ready']+'&&scratch_normal_enable')
for n in ['ln_cancel_valid','ln_cancel_ready','ln_cancel_request_id','ln_cancel_generation','ln_cancel_epoch']:
 jmap[n]='j_'+n
for di,dims,n in jp:
 if jmap[n] not in pubnames:decl(dims,jmap[n])
# Actual physical resource wires.
for di,dims,n in rp:
 if n not in ['clk','rst_n']:decl(dims,'r_'+n)
# Provider wires retain its declared dimensions but do not own identity/payload FF.
pp=ports(A/'laya_m007_resident_ln32_v1.sv')
pm={}
for di,dims,n in pp:
 if n in ['clk','rst_n']:pm[n]=n
 else:pm[n]='p_'+n;decl(dims,pm[n])
for dims,n in [('', 'scratch_normal_enable'),('', 'raw_scratch_lease_ready'),('', 'raw_g_tanh_lease_ready'),('', 'raw_g_tanh_release_ready'),('', 'scratch_wr_valid'),('', 'scratch_wr_ready'),('', 'scratch_wr_commit'),('[11:0]','scratch_wr_addr'),('[31:0][31:0]','scratch_wr_data'),('', 'scratch_rd_valid'),('', 'scratch_rd_ready'),('[11:0]','scratch_rd_addr'),('', 'scratch_rsp_valid'),('', 'scratch_rsp_ready'),('[11:0]','scratch_rsp_addr'),('[31:0][31:0]','scratch_rsp_data'),('', 'scratch_adapter_reject'),('', 'raw_h_wr_valid'),('', 'raw_h_wr_ready'),('', 'raw_h_wr_commit'),('[11:0]','raw_h_wr_addr'),('[31:0][31:0]','raw_h_wr_data'),('', 'raw_h_rd_valid'),('', 'raw_h_rd_ready'),('[11:0]','raw_h_rd_addr'),('', 'raw_h_rsp_valid'),('', 'raw_h_rsp_ready'),('[11:0]','raw_h_rsp_addr'),('[31:0][31:0]','raw_h_rsp_data'),('', 'sq_wr_valid'),('', 'sq_wr_ready'),('[1:0]','sq_wr_plane'),('[3:0]','sq_wr_head'),('[6:0]','sq_wr_token'),('', 'sq_wr_half'),('[31:0][31:0]','sq_wr_data'),('', 'sq_rd_valid'),('', 'sq_rd_ready'),('[3:0]','sq_rd_head'),('[6:0]','sq_rd_token'),('[31:0]','sq_rd_tag'),('', 'sq_rsp_ready'),('[63:0]','tanh_request'),('[31:0]','tanh_generation'),('[31:0]','tanh_epoch'),('[2:0]','tanh_phase'),('[7:0]','tanh_rsp_mask'),('[3:0]','tanh_reject_code')]:decl(dims,n)
emit(' wire ext_allowed=rst_n&&(a_enable||g_enable);')
emit(' wire external_identity=resident_access_request_id==resident_owner_request_id&&resident_access_generation==resident_owner_generation&&resident_access_epoch==resident_owner_epoch;')
emit(' wire vector_busy=vector_enable&&!vector_idle;')
emit(' wire ln_busy=!ln_provider_idle;')
emit(' wire public_bank_access=rst_n&&resident_owner_valid&&external_identity&&!vector_busy&&!ln_busy&&!vector_start_valid&&!resident_ln_start_valid;')
emit(' wire vsource=vector_enable&&vector_done_valid&&vector_done_ready&&vector_done_status==0&&vector_issued_vectors==4096&&vector_retired_vectors==4096&&h_bank_idle&&!raw_h_wr_valid;')
# H is one synchronous bank, with no wrapper response buffering.
assign('raw_h_wr_valid','vector_busy?vector_h_wr_valid:(public_bank_access&&h_wr_valid)')
assign('raw_h_wr_addr','vector_busy?vector_h_wr_addr:h_wr_addr');assign('raw_h_wr_data','vector_busy?vector_h_wr_data:h_wr_data')
assign('vector_h_wr_ready','vector_busy&&raw_h_wr_ready');assign('vector_h_wr_commit','vector_busy&&raw_h_wr_commit')
assign('h_wr_ready','public_bank_access&&!vector_busy&&raw_h_wr_ready');assign('h_wr_commit','h_wr_valid&&h_wr_ready')
assign('raw_h_rd_valid','vector_busy?vector_h_rd_valid:ln_busy?p_h_rd_valid:(public_bank_access&&h_rd_valid)')
assign('raw_h_rd_addr','vector_busy?vector_h_rd_addr:ln_busy?p_h_rd_addr:h_rd_addr')
assign('vector_h_rd_ready','vector_busy&&raw_h_rd_ready');assign('p_h_rd_ready','ln_busy&&raw_h_rd_ready');assign('h_rd_ready','public_bank_access&&raw_h_rd_ready')
assign('vector_h_rsp_valid','vector_busy&&raw_h_rsp_valid');assign('vector_h_rsp_addr','raw_h_rsp_addr');assign('vector_h_rsp_data','raw_h_rsp_data')
assign('p_h_rsp_valid','ln_busy&&raw_h_rsp_valid');assign('p_h_rsp_addr','raw_h_rsp_addr');assign('p_h_rsp_data','raw_h_rsp_data')
assign('h_rsp_valid','!vector_busy&&!ln_busy&&raw_h_rsp_valid');assign('h_rsp_addr','raw_h_rsp_addr');assign('h_rsp_data','raw_h_rsp_data')
assign('raw_h_rsp_ready','vector_busy?vector_h_rsp_ready:ln_busy?p_h_rsp_ready:h_rsp_ready')
assign('h_reject_valid','rst_n&&(h_wr_valid||h_rd_valid)&&!public_bank_access')
emit(' laya_m007_hidden32_v1 hidden(.clk,.rst_n,.enabled(resident_owner_valid),.wr_valid(raw_h_wr_valid),.wr_ready(raw_h_wr_ready),.wr_addr(raw_h_wr_addr),.wr_data(raw_h_wr_data),.wr_commit(raw_h_wr_commit),.rd_valid(raw_h_rd_valid),.rd_ready(raw_h_rd_ready),.rd_addr(raw_h_rd_addr),.rd_rsp_valid(raw_h_rsp_valid),.rd_rsp_ready(raw_h_rsp_ready),.rd_rsp_addr(raw_h_rsp_addr),.rd_rsp_data(raw_h_rsp_data),.bank_idle(h_bank_idle));')
# Q uses only the existing QKV plane0 public synchronous port.
assign('scratch_wr_valid','ln_busy?p_q_wr_valid:(public_bank_access&&q_wr_valid)');assign('scratch_wr_addr','ln_busy?p_q_wr_addr:q_wr_addr');assign('scratch_wr_data','ln_busy?p_q_wr_data:q_wr_data')
assign('p_q_wr_ready','ln_busy&&scratch_wr_ready');assign('p_q_wr_commit','ln_busy&&scratch_wr_commit');assign('q_wr_ready','public_bank_access&&scratch_wr_ready');assign('q_wr_commit','q_wr_valid&&q_wr_ready')
assign('scratch_rd_valid','vector_busy?vector_q_rd_valid:(public_bank_access&&q_rd_valid)');assign('scratch_rd_addr','vector_busy?vector_q_rd_addr:q_rd_addr')
assign('vector_q_rd_ready','vector_busy&&scratch_rd_ready');assign('q_rd_ready','public_bank_access&&scratch_rd_ready')
assign('vector_q_rsp_valid','vector_busy&&scratch_rsp_valid');assign('vector_q_rsp_addr','scratch_rsp_addr');assign('vector_q_rsp_data','scratch_rsp_data')
assign('q_rsp_valid','!vector_busy&&scratch_rsp_valid');assign('q_rsp_addr','scratch_rsp_addr');assign('q_rsp_data','scratch_rsp_data');assign('scratch_rsp_ready','vector_busy?vector_q_rsp_ready:q_rsp_ready')
assign('q_reject_valid','scratch_adapter_reject||(rst_n&&(q_wr_valid||q_rd_valid)&&!public_bank_access)')
emit(' laya_m007_qscratch32_v1 scratch(.clk,.rst_n,.lease_valid(scratch_lease_valid&&resident_owner_valid),.lease_ready(raw_scratch_lease_ready),.release_valid(scratch_release_valid),.release_ready(scratch_release_ready),.layer_retired(a_layer_idle),.matrix_retired(parent_matrix_retired),.quant_retired(parent_quant_retired),.normal_requests_present(a_prepare_valid||a_qkv_wr_valid||a_start_valid||a_result_rd_valid||vector_start_valid||resident_ln_start_valid),.rope_owner_valid(a_rope_owner_valid),.qkv_rsp_valid(r_res_qkv_rd_rsp_valid),.owner_request_id(resident_owner_request_id),.owner_generation(resident_owner_generation),.owner_epoch(resident_owner_epoch),.owner_active(scratch_owner_active),.normal_enable(scratch_normal_enable),.access_request_id(resident_owner_request_id),.access_generation(resident_owner_generation),.access_epoch(resident_owner_epoch),.wr_valid(scratch_wr_valid),.wr_ready(scratch_wr_ready),.wr_addr(scratch_wr_addr),.wr_data(scratch_wr_data),.wr_commit(scratch_wr_commit),.rd_valid(scratch_rd_valid),.rd_ready(scratch_rd_ready),.rd_addr(scratch_rd_addr),.rd_rsp_valid(scratch_rsp_valid),.rd_rsp_ready(scratch_rsp_ready),.rd_rsp_addr(scratch_rsp_addr),.rd_rsp_data(scratch_rsp_data),.reject_valid(scratch_adapter_reject),.retired(scratch_retired),.q_wr_valid(sq_wr_valid),.q_wr_ready(sq_wr_ready),.q_wr_plane(sq_wr_plane),.q_wr_head(sq_wr_head),.q_wr_token(sq_wr_token),.q_wr_half(sq_wr_half),.q_wr_data(sq_wr_data),.q_rd_valid(sq_rd_valid),.q_rd_ready(sq_rd_ready),.q_rd_head(sq_rd_head),.q_rd_token(sq_rd_token),.q_rd_tag(sq_rd_tag),.q_rsp_valid(r_res_qkv_rd_rsp_valid[0]),.q_rsp_ready(sq_rsp_ready),.q_rsp_tag(r_res_qkv_rd_rsp_tag[0]),.q_rsp_data(r_res_qkv_rd_rsp_data[0]));')
assign('scratch_lease_ready','resident_owner_valid&&raw_scratch_lease_ready')
assign('g_tanh_lease_ready','g_enable&&raw_g_tanh_lease_ready');assign('g_tanh_release_ready','g_enable&&raw_g_tanh_release_ready')
assign('sq_wr_ready','scratch_owner_active&&r_res_qkv_wr_ready');assign('sq_rd_ready','scratch_owner_active&&r_res_qkv_rd_ready[0]')
assign('resident_bank_idle','h_bank_idle&&r_res_qkv_rd_rsp_valid==0&&!raw_h_wr_valid&&!raw_h_rd_valid&&!scratch_wr_valid&&!scratch_rd_valid')
# Provider is independent of the arena to retain its finite witness across rearm.
for n,x in {'control_enable':'ln_enable','source_success_valid':'vsource','source_invalidate':'h_wr_commit||(vector_start_valid&&vector_start_ready)','owner_request_id':'resident_owner_request_id','owner_generation':'resident_owner_generation','owner_epoch':'resident_owner_epoch','start_valid':'resident_ln_start_valid&&resident_owner_valid&&scratch_owner_active','rows':'resident_ln_rows','use_gamma':'resident_ln_use_gamma','model':'resident_ln_model','key':'resident_ln_key','done_ready':'resident_ln_done_ready','q_wr_commit':'ln_busy&&scratch_wr_commit','ln_debt_clear':'ln_debt_clear','ln_cancel_accepted':'j_ln_cancel_valid&&j_ln_cancel_ready','ln_reject_accepted':'ln_reject_valid&&ln_reject_ready','protocol_cancel_ready':'j_ln_cancel_ready','fp_active':'r_res_fp_lease_active','div_active':'r_res_div_lease_active','bank_idle':'r_res_ln_idle'}.items():
 if 'p_'+n not in assigned:assign('p_'+n,x)
for out,n in {'resident_ln_done_valid':'done_valid','resident_ln_done_status':'done_status','resident_ln_done_kind':'done_kind','resident_ln_source_qualified':'source_qualified','resident_ln_issued_vectors':'issued_vectors','resident_ln_written_vectors':'written_vectors','ln_provider_idle':'idle'}.items():assign(out,'p_'+n)
assign('resident_ln_start_ready','resident_owner_valid&&scratch_owner_active&&p_start_ready')
for n in ['cmd_valid','cmd_request_id','cmd_generation','cmd_epoch','cmd_rows','cmd_gamma','cmd_model','cmd_key','in_valid','in_request_id','in_generation','in_epoch','in_row','in_chunk','in_tag','in_data','out_ready','done_ready']:
 assign('ln_'+n,'p_ln_'+n)
for n in ['cmd_ready','in_ready','out_valid','out_request_id','out_generation','out_epoch','out_row','out_chunk','out_tag','out_data','done_valid','done_kind']:
 assign('p_ln_'+n,'ln_'+n)
assign('ln_cmd_source_finite_qualified','p_ln_source_finite_qualified');assign('ln_cmd_source_summary_valid',"1'b0");assign('ln_cmd_source_bad_valid',"1'b0");assign('ln_cmd_source_bad_row',"7'b0");assign('ln_cmd_source_bad_element',"10'b0");assign('ln_control_clear',"1'b0")
assign('j_ln_cancel_valid','p_protocol_cancel_valid||ln_cancel_valid');assign('j_ln_cancel_request_id','p_protocol_cancel_valid?resident_owner_request_id:ln_cancel_request_id');assign('j_ln_cancel_generation','p_protocol_cancel_valid?resident_owner_generation:ln_cancel_generation');assign('j_ln_cancel_epoch','p_protocol_cancel_valid?resident_owner_epoch:ln_cancel_epoch');assign('ln_cancel_ready','!p_protocol_cancel_valid&&j_ln_cancel_ready')
emit(' laya_m007_resident_ln32_v1 ln_provider(\n'+',\n'.join(' .'+n+'('+pm[n]+')'for di,dims,n in pp)+'\n );')
assign('vector_owner_valid','resident_owner_valid&&scratch_owner_active');assign('vector_inputs_ready','resident_inputs_ready&&scratch_owner_active');assign('vector_owner_request_id','resident_owner_request_id');assign('vector_owner_generation','resident_owner_generation');assign('vector_owner_epoch','resident_owner_epoch')
# G arithmetic and TANH are the sole production resources, identical to parent v1.
emit(' laya_m007_g_vector_pool_v1 g_pool(.clk,.rst_n(g_pool_reset_n),.req_valid(g_fp_req_valid),.req_ready(g_fp_req_ready),.req_tag(g_fp_req_tag),.req_a(g_fp_req_a),.req_b(g_fp_req_b),.rsp_valid(g_fp_rsp_valid),.rsp_tag(g_fp_rsp_tag),.rsp_data(g_fp_rsp_data),.rsp_status(g_fp_rsp_status),.protocol_fault(g_fp_pool_fault));')
emit(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(.clk,.rst_n,.lease_valid(g_enable&&g_tanh_lease_valid),.lease_ready(raw_g_tanh_lease_ready),.lease_request_id(g_tanh_lease_request_id),.lease_generation(g_tanh_lease_generation),.lease_epoch(g_tanh_lease_epoch),.lease_phase(g_tanh_lease_phase),.release_valid(g_enable&&g_tanh_release_valid),.release_ready(raw_g_tanh_release_ready),.release_phase(g_tanh_release_phase),.release_epoch(g_tanh_release_epoch),.phase_debt_clear(g_tanh_phase_debt_clear),.lease_active(g_tanh_lease_active),.draining(g_tanh_draining),.rsp_request_id(tanh_request),.rsp_generation(tanh_generation),.rsp_epoch(tanh_epoch),.rsp_phase(tanh_phase),.req_valid(g_sfu_req_valid),.req_ready(g_sfu_req_ready),.req_mode(2\'d1),.req_request_id(g_rsp_request_id),.req_generation(g_rsp_generation),.req_epoch(g_rsp_epoch),.req_phase(3\'d1),.req_tag(g_sfu_req_tag),.req_mask(g_sfu_req_mask),.req_x(g_sfu_req_x),.reject_valid(g_sfu_reject_valid),.reject_code(tanh_reject_code),.rsp_valid(g_sfu_rsp_valid),.rsp_ready(g_sfu_rsp_ready),.rsp_tag(g_sfu_rsp_tag),.rsp_mask(tanh_rsp_mask),.rsp_data(g_sfu_rsp_data),.rsp_status(g_sfu_rsp_status),.pending_vectors(g_tanh_pending_vectors),.in_flight_vectors(g_tanh_in_flight_vectors),.protocol_fault(g_sfu_protocol_fault));')
for n,x in {'g_storage_owner_valid':'g_enable&&r_res_fp_lease_active&&r_res_fp_rsp_request_id==resident_owner_request_id&&r_res_fp_rsp_generation==resident_owner_generation&&r_res_fp_rsp_epoch==resident_owner_epoch','g_storage_owner_request_id':'r_res_st_rsp_request_id','g_storage_owner_generation':'r_res_st_rsp_generation','g_storage_owner_epoch':'r_res_st_rsp_epoch','g_storage_owner_phase':'r_res_st_rsp_phase','g_sfu_owner_valid':'g_tanh_lease_active','g_sfu_owner_request_id':'tanh_request','g_sfu_owner_generation':'tanh_generation','g_sfu_owner_epoch':'tanh_epoch','g_sfu_owner_phase':'tanh_phase'}.items():assign(n,x)
# Resource adapter maps for LN and VECTOR.
lnmap={}
for n in ['lease_valid','lease_request_id','lease_generation','lease_epoch','lease_head','lease_phase','release_valid']:
 lnmap['res_fp_'+n]='p_fp_'+n if n in ['lease_valid','release_valid']else'p_'+n
 lnmap['res_div_'+n]='p_div_'+n if n in ['lease_valid','release_valid']else'p_'+n
for dom in ['fp','div']:
 for n,x in {'release_phase':"3'd6",'release_epoch':'resident_owner_epoch','phase_debt_clear':'p_phase_debt_clear'}.items():lnmap['res_'+dom+'_'+n]=x
lnmap.update(res_fp_mul_req_valid='ln_mul_req_valid',res_fp_mul_req_phase="3'd6",res_fp_mul_req_epoch='resident_owner_epoch',res_fp_mul_req_tag='ln_mul_req_tag',res_fp_mul_a='ln_mul_a',res_fp_mul_b='ln_mul_b',res_fp_mul_rsp_ready='ln_mul_rsp_ready',res_fp_add_req_valid="{6'b0,ln_add_req_valid}",res_fp_add_req_is_root="7'b0",res_fp_add_req_phase="{7{3'd6}}",res_fp_add_req_epoch='{7{resident_owner_epoch}}',res_fp_add_req_tag="{576'b0,ln_add_req_tag}",res_fp_add_a='ln_add_a',res_fp_add_b='ln_add_b',res_fp_add_rsp_ready="{6'b0,ln_add_rsp_ready}")
lnmap.update(res_div_req_valid='ln_div_req_valid',res_div_req_generation='resident_owner_generation',res_div_req_epoch='resident_owner_epoch',res_div_req_phase="3'd6",res_div_req_lane_mask="8'b1",res_div_req_tag='ln_div_req_tag',res_div_req_a="{224'b0,ln_div_a}",res_div_req_b="{224'b0,ln_div_b}",res_div_rsp_ready='ln_div_rsp_ready')
lnmap.update(res_ln_bind_valid='p_bank_bind_valid',res_ln_bind_request_id='resident_owner_request_id',res_ln_bind_generation='resident_owner_generation',res_ln_bind_epoch='resident_owner_epoch',res_ln_bind_head="4'b0",res_ln_bind_phase="3'd6",res_ln_op_request_id='ln_op_request_id',res_ln_op_generation='ln_op_generation',res_ln_op_epoch='ln_op_epoch',res_ln_op_phase="3'd6")
for n in ['wr_valid','wr_mask','wr_addr','wr_data','wr_tag','wr_rsp_ready','rd_valid','rd_mask','rd_addr','rd_tag','rd_rsp_ready']:lnmap['res_ln_'+n]='ln_'+n
vm={}
for di,dims,n in rp:
 if n.startswith('res_fp_'):
  b=n[7:];v='vector_fp_'+b
  if v in jointnames:vm[n]=v
for n in ['add_req_valid','add_req_is_root','add_req_phase','add_req_epoch','add_req_tag','add_a','add_b','add_rsp_ready']:vm['res_fp_'+n]='vector_'+n
# Each resource input has exactly one assignment. External selectors route only
# their own service; no global storage override can suppress G transactions.
for di,dims,n in rp:
 if n in ['clk','rst_n']:continue
 if di=='input':
  default='a_'+n if 'a_'+n in jointnames else "'0"
  domain=ext_domain(n)
  x=default
  if n.startswith(('res_fp_','res_div_','res_ln_')):
   if n.startswith('res_fp_'):x='ln_enable?('+lnmap.get(n,"'0")+'):vector_enable?('+vm.get(n,"'0")+'):('+default+')'
   elif n.startswith(('res_div_','res_ln_')):x='ln_enable?('+lnmap.get(n,"'0")+'):('+default+')'
  if n.startswith('res_st_g_'):
   gn='g_g_'+n[len('res_st_g_'):];x='g_enable?'+gn+':('+default+')'
  if domain:x='ext_'+domain+'_select?(ext_allowed?ext_'+n+":'0):("+x+')'
  if n.startswith('res_qkv_'):
   qmap={'res_qkv_wr_valid':'sq_wr_valid','res_qkv_wr_plane':'sq_wr_plane','res_qkv_wr_head':'sq_wr_head','res_qkv_wr_token':'sq_wr_token','res_qkv_wr_half':'sq_wr_half','res_qkv_wr_data':'sq_wr_data','res_qkv_rd_valid':"{2'b0,sq_rd_valid}",'res_qkv_rd_head':"{8'b0,sq_rd_head}",'res_qkv_rd_token':"{14'b0,sq_rd_token}",'res_qkv_rd_tag':"{64'b0,sq_rd_tag}",'res_qkv_rd_rsp_ready':"{2'b0,sq_rsp_ready}"}
   x='scratch_owner_active?('+qmap[n]+'):('+default+')'
  if n.startswith('rope_'):x='a_'+n
  assign('r_'+n,x)
 else:
  # IDs/data/pending/idle are observable; only ready and response-valid belong
  # to the selected consumer. This preserves real physical retirement probes.
  an='a_'+n
  mask=(n.endswith('_ready')or n.endswith('_rsp_valid')or n.endswith('_reject_valid')or n in ['res_scale_rsp_valid','res_sfu_reject_valid','res_div_protocol_reject_valid'])
  sel="1'b1"
  domain=ext_domain(n)
  if domain:sel='!ext_'+domain+'_select'
  if n.startswith('res_fp_'):sel+='&&!ln_enable&&!vector_enable'
  elif n.startswith(('res_div_','res_ln_')):sel+='&&!ln_enable'
  elif n.startswith('res_st_g_'):sel+='&&!g_enable'
  elif n.startswith('res_qkv_'):sel+='&&!scratch_owner_active'
  a_mask=mask and n not in ['res_fp_lease_ready','res_st_bind_ready']
  if an in jointnames:assign(an,'('+sel+')?r_'+n+":'0" if a_mask else 'r_'+n)
  if domain:assign('ext_'+n,'ext_allowed&&ext_'+domain+'_select?r_'+n+":'0" if mask else 'r_'+n)
# Actual FP responses and ready to VECTOR; phase ownership remains physical.
for n in ['lease_ready','release_ready','lease_active','rsp_request_id','rsp_generation','rsp_epoch','rsp_head','rsp_phase','protocol_fault']:
 vn='vector_fp_'+n
 if vn in jointnames:assign(vn,'r_res_fp_'+n if n not in ['lease_ready','release_ready']else'vector_enable&&!ext_fp_select&&r_res_fp_'+n)
for n in ['add_req_ready','add_rsp_valid','add_rsp_tag','add_rsp_data']:
 assign('vector_'+n,'r_res_fp_'+n if n not in ['add_req_ready','add_rsp_valid']else'vector_enable&&!ext_fp_select?r_res_fp_'+n+":'0")
for n in ['fp_lease_ready','fp_release_ready','div_lease_ready','div_release_ready','bank_bind_ready']:
 resource='res_ln_bind_ready'if n=='bank_bind_ready'else'res_'+n
 gate='!ext_div_select'if n.startswith('div_')else'!ext_fp_select'if n.startswith('fp_')else"1'b1"
 assign('p_'+n,'ln_enable&&'+gate+'&&r_'+resource)
for n,expr in {'mul_req_ready':'r_res_fp_mul_req_ready','mul_rsp_valid':'r_res_fp_mul_rsp_valid','mul_rsp_tag':'r_res_fp_mul_rsp_tag','mul_rsp_data':'r_res_fp_mul_rsp_data','mul_pending':'r_res_fp_mul_pending','add_req_ready':'r_res_fp_add_req_ready[0]','add_rsp_valid':'r_res_fp_add_rsp_valid[0]','add_rsp_tag':'r_res_fp_add_rsp_tag[0]','add_rsp_data':'r_res_fp_add_rsp_data','add_pending':'r_res_fp_add_pending[0]','div_req_ready':'r_res_div_req_ready','div_rsp_valid':'r_res_div_rsp_valid','div_rsp_tag':'r_res_div_rsp_tag','div_rsp_data':'r_res_div_rsp_data[0]','div_rsp_error':'r_res_div_rsp_numeric_error[0]','div_pending':'r_res_div_pending_vectors','bank_idle':'r_res_ln_idle'}.items():
 gate='ln_enable'
 if n.startswith(('add_','mul_')):gate+='&&!ext_fp_select'
 if n.startswith('div_'):gate+='&&!ext_div_select'
 mask=n.endswith('_ready')or n.endswith('_valid')
 assign('ln_'+n,gate+'?'+expr+":'0"if mask else expr)
for n in ['wr_ready','wr_rsp_valid','wr_rsp_tag','rd_ready','rd_rsp_valid','rd_rsp_data','rd_rsp_tag']:
 assign('ln_'+n,'ln_enable?r_res_ln_'+n+":'0"if n.endswith(('_ready','_valid'))else'r_res_ln_'+n)
for n in ['wr_ready','wr_rsp_valid','wr_rsp_tag','rd_ready','rd_rsp_valid','rd_rsp_data','rd_rsp_mask','rd_rsp_tag']:
 assign('g_g_'+n,'g_enable?r_res_st_g_'+n+":'0"if n.endswith(('_ready','_valid'))else'r_res_st_g_'+n)
# Persistent coefficient configuration and its sole A consumer.
cm={}
for di,dims,n in cp:
 if n in ['clk','rst_n']:cm[n]=n
 elif n.startswith(('owner_','rd_','rsp_')):cm[n]='a_cache_'+n
 elif n in ['bind_valid','wr_valid']:
  cm[n]='cfg_'+n;decl('',cm[n]);assign(cm[n],'a_enable&&a_layer_idle&&scratch_normal_enable&&coeff_'+n)
 elif n in ['bind_ready','wr_ready']:
  cm[n]='cfg_'+n;decl('',cm[n]);assign('coeff_'+n,'a_enable&&a_layer_idle&&scratch_normal_enable&&'+cm[n])
 else:cm[n]='coeff_'+n
for n in ['bound_valid','bound_model_id','bound_numeric_id','bound_table_key','family_complete']:
 assign('a_cache_'+n,'coeff_'+n)
emit(' laya_rope_coeff_cache_v1 coeff(\n'+',\n'.join(' .'+n+'('+cm[n]+')'for di,dims,n in cp)+'\n );')
# Real probes include leases, pending queues, held bank responses and admissions.
assign('shared_resources_idle','!r_res_fp_lease_active&&!r_res_fp_draining&&r_res_fp_mul_pending==0&&r_res_fp_add_pending==0&&!r_res_div_lease_active&&!r_res_div_draining&&r_res_div_pending_vectors==0&&r_res_div_in_flight_vectors==0&&r_res_div_in_flight_scalars==0&&!r_res_sfu_lease_active&&r_res_sfu_pending_vectors==0&&r_res_sfu_in_flight_vectors==0&&r_res_scale_pending==0&&r_res_st_idle&&r_res_ln_idle&&!g_tanh_lease_active&&g_tanh_pending_vectors==0&&g_tanh_in_flight_vectors==0')
emit(' wire external_new_work=ext_res_fp_lease_valid||ext_res_fp_mul_req_valid||(|ext_res_fp_add_req_valid)||ext_res_div_lease_valid||ext_res_div_req_valid||ext_res_st_bind_valid||ext_res_st_ps_wr_valid||ext_res_st_ps_rd_valid||ext_res_st_context_wr_valid||ext_res_st_context_rd_valid;')
emit(' wire resident_new_work=h_wr_valid||h_rd_valid||q_wr_valid||q_rd_valid||scratch_lease_valid||coeff_bind_valid||coeff_wr_valid;')
assign('outer_admission_quiet[0]','!external_new_work&&!resident_new_work&&!a_prepare_valid&&!a_qkv_wr_valid&&!a_start_valid&&!a_result_rd_valid')
assign('outer_admission_quiet[1]','!external_new_work&&!resident_new_work&&!g_tanh_lease_valid&&!g_cmd_valid&&!g_fill_valid')
assign('outer_admission_quiet[2]','!resident_new_work&&!resident_ln_start_valid')
assign('outer_admission_quiet[3]','!resident_new_work&&!vector_start_valid')
emit(' laya_m007_control_workspace_joint_v2 joint(\n'+',\n'.join(' .'+n+'('+jmap[n]+')'for di,dims,n in jp)+'\n );')
emit(' laya_attention_resources_v1 resources(\n'+',\n'.join(' .'+n+'('+('r_'+n if n not in ['clk','rst_n']else n)+')'for di,dims,n in rp)+'\n );')
emit('endmodule')
s=header+'\n'.join(declarations)+'\n'+s[len(header):]
(A/'laya_m007_resident_joint_v2.sv').write_text(s)
# Source-generation completeness check only, deliberately not a compile result.
unassigned=[]
for di,dims,n in jp:
 nn=jmap[n]
 if di=='input'and nn not in pubnames and nn not in assigned and nn not in ['clk','rst_n']:unassigned.append(nn)
for di,dims,n in pp:
 nn=pm[n]
 if di=='input'and nn not in assigned and nn not in ['clk','rst_n']:unassigned.append(nn)
report={'schema':'resident-joint-source-generation-v1','stage':'UNCOMPILED_UNTESTED','public_ports':len(pub),'body_sha256':hashlib.sha256(s.encode()).hexdigest(),'assigned_nets':len(assigned),'unassigned_consumer_or_provider_inputs':unassigned,'sequential_blocks_in_wrapper':s.count('always_ff'),'physical_instances':['joint','resources','hidden','scratch','ln_provider','coeff','g_pool','g_tanh']}
(Path(__file__).parent/'resident_joint_v2_generation_report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
