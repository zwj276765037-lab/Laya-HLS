#!/usr/bin/env python3
import os,resource,time,json,hashlib,sys
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));os.sched_setaffinity(0,{0,1,2,3});start=time.monotonic()
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'project/E016_m007_single_resource_parent/experiment_results/planning/full_parent_successor_20261022';stage=sys.argv[1];records=[];snippets={}
def load(rel):
 p=ROOT/rel;data=p.read_text();records.append({'path':rel,'sha256':hashlib.sha256(data.encode()).hexdigest(),'bytes':len(data.encode())});return data
if stage=='control':
 base='project/E002_Laya_HLS/experiment/vivado/module_design/'
 rel=base+'forward_controller/rtl/laya_m007_single_parent_v1.sv';s=load(rel);lines=s.splitlines();keep=[]
 for i,line in enumerate(lines):
  if any(x in line for x in ['localparam','wo_phase','state==','state<=','q_producer_close_success','assign out_','assign done_','assign m_cmd_','assign m_out_','assign m_done_','assign l_result_','assign c_','assign q_in_','assign q_cmd_','assign m_res_bind_']):keep.append(str(i+1)+': '+line)
 snippets['parent_control']='\n'.join(keep)
 rel=base+'attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv';s=load(rel);lines=s.splitlines();wanted=set()
 for i,line in enumerate(lines):
  if any(x in line for x in ['result_rd_','result_rsp_','result_discard_','context_consumed','head_context_valid','layer_idle','DONE_HOLD','RESULT','context_release']):wanted.update(range(max(0,i-2),min(len(lines),i+3)))
 snippets['layer_context_lifecycle']='\n'.join(str(i+1)+': '+lines[i] for i in sorted(wanted))
 rel=base+'forward_controller/rtl/laya_m007_context_quant_adapter_v1.sv';snippets['adapter']=load(rel)
 rel=base+'forward_controller/tb/m007_parent_run.py';snippets['runner']=load(rel)
 rel=base+'forward_controller/tb/m007_single_parent_tb.sv';s=load(rel);lines=s.splitlines();wanted=set()
 for i,line in enumerate(lines):
  if any(x in line for x in ['prefix','nheads','max_checked','scoregold','contextgold','qkvgold','prebias','araddr','cmd_base[0]','cmd_base[1]','out_ready','out_valid','h_done_valid','nrope','nscore','nprob','ncontext','nprob_ack','head_start_cycle','$finish']):wanted.update(range(max(0,i-1),min(len(lines),i+2)))
 snippets['tb_terminal_and_peer']='\n'.join(str(i+1)+': '+lines[i] for i in sorted(wanted))
 snippets['matrix_tb_files']='\n'.join(p.name for p in sorted((ROOT/(base+'q8_linear_and_restore/tb')).glob('*')) if p.is_file() and any(x in p.name for x in ['wo','context','f32','full']))
 fx=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R004/attempts/AT005_original_context_wo_fixture/work/fixture/wo_0_weight';snippets['WO_fixture_files']='\n'.join(p.name for p in sorted(fx.iterdir()) if p.is_file())
 for rel in ['project/E016_m007_single_resource_parent/experiment_results/runs/R001/reports/full_parent_16head_wo_cost_gate.json','project/E016_m007_single_resource_parent/experiment_results/runs/R002/phase_comparison.json','project/E012_m007_matrix_compute/experiment_results/runs/R004/final_delivery.md']:
  snippets[Path(rel).name]=load(rel)
elif stage=='wo_and_contract':
 paths=json.loads((OUT/'requested_second_read.json').read_text())['files']
 for rel in paths:
  data=load(rel)
  if rel.endswith('.sv'):
   lines=data.splitlines();wanted=set()
   keys=['gold','output.hex','pre_bias','out_valid','out_ready','out_row','out_col','out_data','error_stage<=','error_row<=','error_col<=','error_group<=','public_read','output_consumed','head_retire','head_completed','head_context_valid','L_RELEASE','L_DONE','context_release','q_done','context_failed','c_complete','c_idle','done_valid&&','a_published','lease_active']
   for i,line in enumerate(lines):
    if len(line)<700 and any(k in line for k in keys):wanted.update(range(max(0,i-1),min(len(lines),i+2)))
   snippets[rel]='\n'.join(str(i+1)+': '+lines[i] for i in sorted(wanted) if len(lines[i])<700)
  elif rel.endswith('driver.log'):
   snippets[rel]='\n'.join(x for x in data.splitlines() if '_PASS' in x or 'Fatal:' in x)
  else:snippets[rel]=data
else:raise RuntimeError('unknown bounded read stage')
elapsed=time.monotonic()-start;assert elapsed<20
receipt={'stage':stage,'elapsed_s':elapsed,'maxrss_kb':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'address_space_limit_bytes':1024**3,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice_policy':'idle through actual /usr/bin/ionice -c3 launch','timeout_s':20,'files':records,'scope':'read-only source/log inspection; no EDA or child process control'}
(OUT/(stage+'_read_receipt.json')).write_text(json.dumps(receipt,indent=2)+'\n');(OUT/(stage+'_excerpts.json')).write_text(json.dumps(snippets,indent=2)+'\n')
ledger={'limits_s':{'planning_read':60},'conservative_initial_uninstrumented_setup_read_charge_s':6.0,'initial_setup_policy':'First small source excerpt call preceded this wrapper; 6s outer call duration conservatively charged, its RSS/affinity not separately instrumented. All subsequent reads are measured/bounded. No EDA ran.','measured_read_receipts':[json.loads(p.read_text()) for p in sorted(OUT.glob('*_read_receipt.json'))]};ledger['used_s']=6+sum(x['elapsed_s'] for x in ledger['measured_read_receipts']);assert ledger['used_s']<=60;ledger['remaining_s']=60-ledger['used_s'];(OUT/'planning_ledger.json').write_text(json.dumps(ledger,indent=2)+'\n')
for k,v in snippets.items():print('\n'+k+'\n'+v)
print('BOUNDED_PLANNING_READ_PASS '+json.dumps({k:receipt[k] for k in ['stage','elapsed_s','maxrss_kb','cpu_ids','nice']}))
