#!/usr/bin/env python3
"""D34 authorized bounded original public Decision0 component, all original checks kept."""
import fcntl,importlib.util,json,os,subprocess,sys
from pathlib import Path
h=Path(__file__).resolve().parent;s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
at=m.RUN/'attempts/AT010_kind6_public_abi';work=at/'work';cfg=json.loads((at/'config.json').read_text());guard=Path(cfg['guard_path']);driver=h/'decision_segment_driver_r002.py';exe=work/'obj'/('V'+cfg['top']);prefix=next(v.split('=',1)[1] for v in cfg['plusargs'] if v.startswith('+EXPORT='))
gold=m.ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/decision_00_out.f32.bin'
for manifest in ['source_manifest.json','incremental_execution_manifest.json']:
 for x in json.loads((at/manifest).read_text())['sources_and_inputs']:
  if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('frozen execution input changed: '+x['path'])
source=next(Path(p) for p in cfg['sources'] if Path(p).name=='laya_m007_single_parent_v3.sv');tb=next(Path(p) for p in cfg['sources'] if Path(p).name=='m007_fullgraph_binary_tb.sv');text=source.read_text();tt=tb.read_text()
required=['P_RETIRE=86','E_RA_RELEASE=42','E_LN_RELEASE=47','E_RF_RELEASE=55','D1DRAIN=100','D2RUN=102','D2DRAIN=103','state<=state==P_RUN?P_RETIRE:state==N_RUN?N_RETIRE:E_LN_RELEASE;','state<=done_status==0?(decision_mode?D2SUB:WMSUB):F_RETURN;','D2SUB:if(m_cmd_valid&&m_cmd_ready)state<=D2RUN;','if(m_status!=0)fail(8\'h34','else state<=D2DRAIN;']
assert all(v in text for v in required),'source success predicates'
for v in ['fc1_Awrites[gl-28]!=16384','fc1_Aacks[gl-28]!=16384','!dut.front.producer_closed','!dut.front.producer_success','!dut.front.a_published','dut.front.a_write_debt!=0','!dut.global_idle','complete Decision component coverage','original full Decision public output','actual final heldDONE/retirement/one input chain']:assert v in tt,v
assert '+KIND=6' in cfg['plusargs'] and '+LAYER=0' in cfg['plusargs']
pred={'parent':m.identify(source),'original_TB':m.identify(tb),'preLN':'P_RUN successful LN kind0/status0/full4096 writes -> P_RETIRE86','QKV':'matrix_done1 from actual successful m_done; LSTART6','heads':'contiguous actual l_head_completed mask, each head individually','Attention':'CSUB8 follows successful original l_done','WO':'matrix_done2 successful m_done -> E_WO_POST35','residualA':'E_RA_RELEASE42 requires vector status0/full4096 issued-retired/Hidle','postLN':'E_LN_RELEASE47 requires LN kind0/status0/full4096 issued-written','FC2_admission':'actual D2SUB m_cmd accepted -> D2RUN102; original checker all16384 unique FC1/ReLU A1 writes +16384 ACKs + producer_closed/success/a_published/debt0; no reset at FC1 BEGIN/counters','FC2_success':'matrix_done4 and D2DRAIN103 only successful m_done status0','residualB':'E_RF_RELEASE55 requires full successful vector retirement','final':'original layer28/checkpoint30 + actual complete accepted H capture + public4096 original output + original held DONE consumed + actual global/transport/W idle + original PASS + normal exit + independent original Decision0 bit-exact','global_seconds':600,'consecutive_seconds':120,'component_only_not_kind7_substitution':True}
m.dump(at/'phase_source_predicates.json',pred);build=json.loads((at/'receipt_build.json').read_text());assert build['verdict']=='PASS' and m.sha(exe)==build['executable']['sha256']
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 for stage in ['validate','rtl']:
  out=at/('guard_'+stage)
  if out.exists():raise SystemExit('preserve prior execution')
  if stage=='validate':
   cmd=[sys.executable,str(driver),'replay','--receipt',str(work/'decision_segment_replay_result.json')];cap=20;cat='static'
   assert m.budget()['static']+cap<=1200
  else:
   assert json.loads((at/'receipt_validate.json').read_text())['verdict']=='PASS'
   assert 7200-m.budget()['rtl']>=1200,'retain600 after600 diagnostic'
   cmd=[sys.executable,str(driver),'run','--events',str(work/'wall_events.jsonl'),'--segments',str(work/'segment_retirements.jsonl'),'--receipt',str(work/'decision_driver_receipt.json'),'--capture-meta',prefix+'.layer28.capture.json','--capture-binary',prefix+'.layer28.f32.bin','--capture-trace',prefix+'.layer28.accepted.jsonl','--gold',str(gold),'--public-output',prefix+'.output.bin','--original-receipt',prefix+'.receipt.txt','--command',str(exe),*cfg['plusargs']];cap=600;cat='rtl'
   m.dump(at/'rtl_execution_identity.json',{'executable':m.identify(exe),'source_manifest':m.identify(at/'source_manifest.json'),'incremental_execution_manifest':m.identify(at/'incremental_execution_manifest.json'),'config':m.identify(at/'config.json'),'driver':m.identify(driver),'launcher':m.identify(Path(__file__)),'predicates':m.identify(at/'phase_source_predicates.json'),'original_gold':m.identify(gold),'public_kind6_local0':True,'fullgraph_complete':False})
  argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','24' if cat=='static' else '8','--timeout-seconds',str(cap),'--semantic-stall-seconds','120','--phase',cat]
  if cat=='static':argv+=['--artifact-progress-root',str(work)]
  argv+=['--',*cmd];m.dump(at/('command_'+stage+'.json'),{'category':cat,'argv':argv,'budget_before':m.budget(),'guard':m.identify(guard),'driver':m.identify(driver)})
  with (at/(stage+'_wrapper.log')).open('w') as f:rc=subprocess.call(argv,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT)
  g=json.loads((out/'guard_result.json').read_text());ip=work/('decision_segment_replay_result.json' if stage=='validate' else 'decision_driver_receipt.json');inner=json.loads(ip.read_text()) if ip.exists() else None;ok=rc==0 and not g['trigger'] and inner and inner['verdict']=='PASS';cost=bool(g['trigger']) or (inner and inner['verdict']=='COST_STOP');verdict='PASS' if ok else 'COST_STOP' if cost else 'FAIL'
  m.dump(at/('receipt_'+stage+'.json'),{'category':cat,'verdict':verdict,'guard':g,'guard_wrapper_exit':rc,'driver_receipt':inner,'fullgraph_complete':False,'public_kind6_complete':ok and stage=='rtl'});print(json.dumps({'stage':stage,'verdict':verdict,'elapsed_seconds':g['elapsed_seconds'],'reason':inner.get('reason') if inner else None,'trigger':g['trigger']}),flush=True)
  if not ok:raise SystemExit(124 if cost else 1)
