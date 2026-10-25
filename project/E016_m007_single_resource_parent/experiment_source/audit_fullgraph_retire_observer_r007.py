#!/usr/bin/env python3
"""Static audit only: observation-only delta and real retired-event counter logic."""
from pathlib import Path
import argparse,ctypes,hashlib,json,os,re,resource,time


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
 start=time.monotonic();ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();root=a.root.resolve();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));affinity=sorted(os.sched_getaffinity(0));nice=os.getpriority(os.PRIO_PROCESS,0);io=ctypes.CDLL(None).syscall(252,1,0);available=int(next(x.split()[1]for x in Path('/proc/meminfo').read_text().splitlines()if x.startswith('MemAvailable:')));assert affinity and set(affinity)<=set(range(4))and nice==19 and io>>13==3 and available>192*1024*1024
 r=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';m=root/'project/E002_Laya_HLS/experiment/vivado/module_design';old=r/'prepared/fullgraph_kind6_kind7_public_boundary_v2/frozen/m007_fullgraph_binary_tb.sv';top=m/'forward_controller/tb/m007_fullgraph_binary_tb.sv';before=old.read_text();after=top.read_text();assert sha(old)=='677e5bc9f74c6189ca37355fd6de569599a46a3a853961d933f9dda9266e8033';decl=' longint unsigned rtl_retired=0,rtl_last_retired=0;\n';block=re.search(r'   // RTL_RETIRE_OBSERVER_BEGIN.*?   // RTL_RETIRE_OBSERVER_END\n',after,re.S).group();assert after.count(decl)==1 and after.replace(decl,'',1).replace(block,'',1)==before
 assert 'M007_RTL_RETIRE_PROGRESS retired=%0d cycle=%0d'in block and 'rtl_retired-rtl_last_retired>=128'in block and 'if(completed>0)'in block
 conditions=re.findall(r'if\(([^\n]+)\)completed\+\+;',block);expected=['dut.matrix.core.ps_wr_rsp_valid&&dut.matrix.core.ps_wr_rsp_ready','dut.q_awr_rsp_valid&&dut.q_awr_rsp_ready','dut.resident.a_res_st_ps_wr_rsp_valid&&dut.resident.a_res_st_ps_wr_rsp_ready','dut.resident.a_res_st_context_wr_rsp_valid&&dut.resident.a_res_st_context_wr_rsp_ready','dut.resident.p_q_wr_valid&&dut.resident.p_q_wr_ready&&dut.resident.p_q_wr_commit','dut.g_out_valid&&dut.g_out_ready','dut.resident.vector_h_wr_valid&&dut.resident.vector_h_wr_ready&&dut.resident.vector_h_wr_commit'];assert conditions==expected
 assert not re.search(r'(?<!\w)checked\s*(?:[+]?=|\+\+)',block)and not re.search(r'\bdut\.[\w.]+\s*(?:<=|[+]?=(?!=))',block)
 assert ' always@(posedge clk)if(rst_n)begin\n  cycle++;'in after and '  if(full_active)begin\n   integer gl;gl=int\'(dut.layer_index);\n'+block in after
 assert after.count('rtl_retired+=')==1 and after.count('rtl_last_retired=rtl_retired')==1
 peer=m/'forward_controller/tb/m007_binary_weight_peer_tb.sv';one=m/'forward_controller/tb/m007_fullmodel_encoder_1d_tb.sv';binary=m/'forward_controller/tb/m007_fullmodel_encoder_binary_tb.sv';assert sha(peer)=='4d9265c219d1712327c31a0a0f3558d858563e84f0dc83374fc9431a0d31abe8'and sha(one)=='505e0b93652303b2f12049325ea3b4a9d434d9452a8795e634b91ace969f9327'and sha(binary)=='8a4a3956cff9289c026d16d1e1d7405d00393dc42ad586e62d4fdbb5624c4f8a'
 core=(m/'q8_linear_and_restore/rtl/laya_m007_matrix_engine_v1.sv').read_text();resident=(m/'attention_and_fp_engine/rtl/laya_m007_resident_joint_v3.sv').read_text();assert 'assign ps_wr_rsp_ready=1\'b1;'in core;assert 'assign p_q_wr_commit=ln_busy&&scratch_wr_commit;'in resident and 'assign p_q_wr_ready=ln_busy&&scratch_wr_ready;'in resident
 def advance(state,bits,enabled=True):
  total,last,cycle=state;cycle+=1;completed=sum(bits)if enabled else 0;printed=None
  if completed:
   total+=completed
   if total-last>=128:printed=(total,cycle);last=total
  return (total,last,cycle),printed
 # Exhaustive accepted-event domain combinations; every one is an event count,
 # never a F32 operation/word count or DUT/numerical-model simulation.
 for mask in range(128):
  bits=[(mask>>k)&1 for k in range(7)];initial=(121,0,10);state,printed=advance(initial,bits);assert state[0]==121+mask.bit_count();assert bool(printed)==(mask==127);assert advance(initial,bits,False)[0][0]==121
 state=(0,0,0);records=[];real_events=0
 for layer in range(30):
  for sample in range(257):
   bits=[int((sample+3*k+layer)%11==0)for k in range(7)]if sample<240 else[0]*7;real_events+=sum(bits);state,line=advance(state,bits)
   if line:records.append(line)
 assert state[0]==real_events and records and all(b[0]>a[0]and b[1]>a[1]for a,b in zip(records,records[1:]));last=state
 for _ in range(100):state,line=advance(state,[0]*7);assert not line and state[0]==last[0]
 result={'schema':'m007-r007-fullgraph-retire-observer-static-audit-v1','status':'PASS_STATIC_SOURCE_AND_COUNTER_MODEL_ONLY','top_sha256':sha(top),'previous_top_sha256':sha(old),'removing_only_two_counters_and_observer_reconstructs_677e5bc9':True,'conditions':conditions,'sample':'Same existing TB posedge process after its single cycle++ and inside full_active; samples pre-NBA valid/ready/commit at that actual edge. Existing cycle and checked paths unchanged.','emit':'Only if at least one actual accepted retirement event occurred and cumulative unprinted delta>=128. Counter starts0 once, never resets at layer transitions. Up to7 distinct interface events may count on one edge.','gold_checked_and_all_original_assertions_stimulus_and_gold_preserved':True,'independent_counter_model':{'accepted_domain_combinations':128,'layers_without_reset':30,'actual_synthetic_retirement_events':real_events,'printed_strict_records':len(records),'no_event_tail_cycles_no_print_or_increment':100,'scope':'Pure observer counter logic test with boolean protocol events, not RTL or model arithmetic.'},'same_top_kind5_505e_and_peer_unchanged':True,'SV_compile_or_RTL_or_floating_model_run':False,'scope_limit':'No frontend acceptance/runtime compatibility or fullgraph semantic-stall timing PASS. A012 must independently accept only the exact marker with strict global highwater; current Encoder driver is unchanged.','resource_policy_self':{'affinity':affinity,'nice':nice,'ioprio_class':io>>13,'initial_MemAvailable_KiB':available,'max_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'address_space_limit_B':1024**3},'wall_s':time.monotonic()-start};(out/'retire_observer_audit.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k]for k in ['status','top_sha256','independent_counter_model','resource_policy_self','wall_s']}))


if __name__=='__main__':main()
