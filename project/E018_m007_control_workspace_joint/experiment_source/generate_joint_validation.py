from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[3];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';A=MOD/'attention_and_fp_engine';G=MOD/'vector_and_ffn'
ports=json.loads((Path(__file__).parent/'joint_port_manifest.json').read_text())['layer'];skip={'clk','rst_n','external_control_enable','external_control_q','external_control_next','control_private_idle','control_retired'}
expose={'prepare_valid','prepare_ready','qkv_wr_valid','qkv_wr_ready','qkv_wr_plane','qkv_wr_head','qkv_wr_token','qkv_wr_half','qkv_wr_data','prepare_cancel_valid','prepare_cancel_ready','prepare_cancel_rsp_valid','prepare_cancel_rsp_ready','layer_idle'}
s=(G/'tb/m007_g_engine_validation_shell.sv').read_text().replace('module m007_g_engine_validation_shell(', 'module m007_control_arena_validation_shell(\n input logic owner_req_valid,owner_req_g,output logic owner_req_ready,a_enable,g_enable,rearm,owner_g,\n'+',\n'.join(f' {di} logic {dims} a_{n}'for di,dims,n in ports if n in expose)+',')
# All layer signals retain explicit quiescent boundary drivers; no constant safety
# flag enters the production workspace. Actual QKV/storage/TANH state is used.
decl=''
for di,dims,n in ports:
 if n not in skip and n not in expose:decl+=f' logic {dims} a_{n};\n'
known={'prepare_request_id':'request_id','prepare_generation':'generation','prepare_epoch':'epoch','prepare_kind':"2'd2",'qkv_wr_request_id':'request_id','qkv_wr_generation':'generation','qkv_wr_epoch':'epoch','prepare_cancel_request_id':'request_id','prepare_cancel_generation':'generation','prepare_cancel_epoch':'epoch','res_st_bind_ready':'storage_bind_ready','res_fp_lease_ready':"1'b1",'res_st_idle':'storage_idle','res_ln_idle':"1'b1",'res_sfu_lease_active':'lease_active','res_sfu_pending_vectors':'sfu_pending','res_sfu_in_flight_vectors':'sfu_flight'}
qkvinputs={n for di,d,n in ports if di=='input'and(n.startswith('res_qkv_')or n.startswith('rope_'))}
for di,dims,n in ports:
 if di=='input'and n not in skip|expose|qkvinputs:decl+=f' assign a_{n}={known.get(n,"\'0")};\n'
defs=''.join(x for x in decl.splitlines(True)if x.startswith(' assign '));decl=''.join(x for x in decl.splitlines(True)if not x.startswith(' assign '))
s=s.replace(' logic storage_bind_ready,',decl+' logic storage_bind_ready,',1)
s=s.replace(' assign slot_release_fire=',defs+' assign slot_release_fire=',1)
s=s.replace('engine.pair_release_','joint.g_engine.pair_release_')
start=s.index(' laya_m007_g_engine_v1 engine(');end=s.index('\n laya_m007_g_vector_pool_v1 pool',start)
inst=s[start:end].replace('laya_m007_g_engine_v1 engine','laya_m007_control_workspace_joint_v1 joint')
def rename_connection(m):
 n=m[1];pre=''if n in('clk','rst_n')else'g_'
 return '.'+pre+n+('('+n+')'if inst[m.end()]!='('else'')
inst=re.sub(r'\.([A-Za-z_]\w*)(?=[,()])',rename_connection,inst)
extra='.owner_req_valid,.owner_req_g,.owner_req_ready,.a_enable,.g_enable,.rearm,.owner_g,'+','.join(f'.a_{n}(a_{n})'for di,dims,n in ports if n not in skip)+','
inst=inst.replace('joint(', 'joint('+extra,1)
s=s[:start]+inst+s[end:]
# Real native bank commits every layer PREP write at its real handshake.
q=(A/'rtl/laya_attention_qkv_bank_v2.sv').read_text();header=q[q.index('(')+1:q.index(');')];qp=[]
for x in header.split(','):
 x=re.sub(r'//[^\n]*','',x).strip();m=re.search(r'([A-Za-z_]\w*)$',x);assert m,x;qp.append(m[1])
cons=[]
for n in qp:
 if n in('clk','rst_n'):v=n
 elif n.startswith(('wr_','rd_')):v='a_res_qkv_'+n
 else:v='a_'+n
 cons.append(f'.{n}({v})')
s=s.replace('endmodule',' laya_attention_qkv_bank_v2 qkv_bank('+','.join(cons)+');\nendmodule')
(G/'tb/m007_control_arena_validation_shell.sv').write_text(s)
t=(G/'tb/m007_g_engine_tb.sv').read_text().replace('module m007_g_engine_tb;','module m007_control_arena_engine_tb;').replace('m007_g_engine_validation_shell dut(.*);','m007_control_arena_validation_shell dut(.*);').replace('dut.engine.','dut.joint.g_engine.')
extra=' logic owner_req_valid=0,owner_req_g=0,owner_req_ready,a_enable,g_enable,rearm,owner_g;\n'
for di,dims,n in ports:
 if n in expose:extra+=f' logic {dims} a_{n}'+("='0"if di=='input'else'')+';\n'
extra+=''' task automatic edge_step;@(posedge clk);#0.01;endtask
 task automatic prep;
  @(negedge clk);a_prepare_valid=1;owner_req_valid=1;owner_req_g=1;#0.01;
  if(owner_req_ready)$fatal(1,"CONCURRENT_PREP_SWITCH_RACE");
  if(!a_prepare_ready)$fatal(1,"ACTUAL_LAYER_PREP_NOT_READY state=%0d real_idle=%0d h_ready=%0d q_ready=%0d bind=%0d lease=%0d",dut.joint.layer.state,dut.joint.layer.real_idle,dut.joint.layer.h_prepare_ready,dut.joint.layer.head.q_prepare_ready,dut.a_res_st_bind_ready,dut.a_res_fp_lease_ready);edge_step();@(negedge clk);a_prepare_valid=0;owner_req_valid=0;
  if(dut.joint.state_q!==0)$fatal(1,"PREP_COVERAGE_NOT_CLEAR");
 endtask
 task automatic write_coverage(input int index);
  @(negedge clk);a_qkv_wr_valid=1;a_qkv_wr_half=1'(index%2);a_qkv_wr_token=7'((index/2)%128);a_qkv_wr_plane=2'((index/256)%3);a_qkv_wr_head=4'(index/768);a_qkv_wr_data={32{32'h3f800000}};#0.01;
  if(!a_qkv_wr_ready)$fatal(1,"REAL_QKV_WRITE_NOT_READY");edge_step();@(negedge clk);a_qkv_wr_valid=0;
  if(dut.joint.state_q[index]!==1)$fatal(1,"ACTUAL_LAYER_COVERAGE index=%0d",index);
 endtask
 task automatic cancel_and_hold;
  @(negedge clk);a_prepare_cancel_valid=1;#0.01;if(!a_prepare_cancel_ready)$fatal(1,"CANCEL_NOT_READY");edge_step();@(negedge clk);a_prepare_cancel_valid=0;
  repeat(17)begin edge_step();if(!a_prepare_cancel_rsp_valid||owner_req_ready||dut.joint.state_q!==0)$fatal(1,"HELD_CANCEL_SWITCH_BARRIER");end
  @(negedge clk);a_prepare_cancel_rsp_ready=1;edge_step();@(negedge clk);a_prepare_cancel_rsp_ready=0;
  if(!a_layer_idle)$fatal(1,"CANCEL_NOT_ACTUALLY_IDLE");
 endtask
 task automatic switch_owner(input bit target);
  @(negedge clk);owner_req_valid=1;owner_req_g=target;#0.01;
  if(!owner_req_ready)$fatal(1,"ACTUAL_RETIREMENT_NOT_READY target=%0d a=%0d g=%0d",target,dut.joint.a_retired,dut.joint.g_retired);edge_step();
  if(!rearm||a_enable||g_enable||dut.joint.state_q!==0)$fatal(1,"ACTUAL_REARM");
  @(negedge clk);owner_req_valid=0;edge_step();
  if(rearm||g_enable!=target||a_enable==target||dut.joint.state_q!==0)$fatal(1,"ACTUAL_ENABLE_AFTER_REARM");
 endtask
 task automatic layer_prefix;
  prep();write_coverage(0);write_coverage(1);write_coverage(255);write_coverage(256);write_coverage(4095);write_coverage(4096);write_coverage(12287);write_coverage(0);write_coverage(12287);
  if($countones(dut.joint.state_q)!=7)$fatal(1,"DUPLICATE_OR_BOUNDARY_COVERAGE");
  @(negedge clk);owner_req_valid=1;owner_req_g=0;edge_step();if(rearm||$countones(dut.joint.state_q)!=7)$fatal(1,"ACTUAL_SAME_OWNER_CLEARED");
  @(negedge clk);owner_req_g=1;repeat(3)begin edge_step();if(owner_req_ready||rearm||g_enable)$fatal(1,"PREP_EARLY_SWITCH");end
  cancel_and_hold();owner_req_valid=0;switch_owner(1);
  $display("CONTROL_A_TO_G_PASS coverage_unique=7 real_qkv_writes=9 cancel_held=17");
 endtask
 task automatic layer_return;
  switch_owner(0);prep();write_coverage(12287);write_coverage(0);
  if($countones(dut.joint.state_q)!=2)$fatal(1,"RETURN_A_COVERAGE_RELOAD");
  owner_req_g=1;owner_req_valid=1;cancel_and_hold();owner_req_valid=0;
  $display("CONTROL_G_TO_A_PASS actual_done_consumed=1 resources_retired=1 coverage_reload=2");
 endtask
 always @(posedge clk)if(rst_n)begin
  if(!a_enable&&(a_prepare_ready||a_qkv_wr_ready||a_prepare_cancel_rsp_valid||dut.a_res_qkv_wr_valid||dut.a_res_qkv_rd_valid||dut.a_done_valid||dut.a_cache_rd_valid))$fatal(1,"INACTIVE_LAYER_PUBLISHED");
  if(!g_enable&&(out_valid||done_valid||dut.fp_req_valid||dut.sfu_req_valid||g_wr_valid||g_rd_valid||dut.pool_reset_n))$fatal(1,"INACTIVE_G_PUBLISHED");
  if(dut.a_start_valid||dut.a_res_fp_mul_req_valid||dut.a_res_sfu_req_valid)$fatal(1,"LAYER_LOCAL_MUST_NOT_LAUNCH_ARITHMETIC");
 end
'''
t=t.replace(' logic [383:0] vectors',extra+' logic [383:0] vectors',1)
t=t.replace('rst_n=1;bind_valid=1;', 'rst_n=1;layer_prefix();bind_valid=1;',1)
t=t.replace('if(resources_bound)$fatal(1,"RESOURCE_RELEASE");', 'if(resources_bound)$fatal(1,"RESOURCE_RELEASE");layer_return();',1)
t=t.replace('end else if(!active||done_valid||engine_idle)$fatal(1,"PREFIX_MUST_RETAIN_WAITING_COMMAND");', '''end else begin
   if(!active||done_valid||engine_idle)$fatal(1,"PREFIX_MUST_RETAIN_WAITING_COMMAND");
   @(negedge clk);owner_req_valid=1;owner_req_g=0;repeat(3)begin edge_step();if(owner_req_ready||rearm||!g_enable)$fatal(1,"ACTIVE_G_EARLY_SWITCH");end
   @(negedge clk);owner_req_valid=0;
  end''')
(G/'tb/m007_control_arena_engine_tb.sv').write_text(t)
# Existing driver assertion/report/cost interface stays unchanged, selected
# sources now elaborate the actual production joint composition.
s=(G/'tb/m007_g_engine_run.py').read_text()
s=s.replace("'tb/m007_g_engine_validation_shell.sv','tb/m007_g_engine_tb.sv'", "'tb/m007_control_arena_validation_shell.sv','tb/m007_control_arena_engine_tb.sv'")
s=s.replace("sources=[*shared,*[f/LOCAL/name for name in names]]", "sources=[*shared,*[f/LOCAL/name for name in names]]\n sources += [f/(MODULE.parent/'attention_and_fp_engine/rtl'/n).relative_to(ROOT) for n in ['laya_m007_control_workspace_v1.sv','laya_m007_control_workspace_joint_v1.sv','laya_attention_layer_engine_v1.sv','laya_attention_head_engine_v1.sv','laya_attention_qk_av_engine_v1.sv','laya_attention_softmax_engine_v1.sv','laya_attention_rope_engine_v1.sv','laya_attention_check_order_v1.sv','laya_attention_qkv_bank_v2.sv']]")
s=s.replace('work.m007_g_engine_tb','work.m007_control_arena_engine_tb').replace('g_engine_sim','control_arena_sim')
(G/'tb/m007_control_arena_run.py').write_text(s)
print('JOINT_VALIDATION_GENERATED')
