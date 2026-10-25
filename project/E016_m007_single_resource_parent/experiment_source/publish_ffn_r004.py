#!/usr/bin/env python3
"""Audit actual R004 partial reference and publish the contract cost exit."""
import contextlib,datetime as dt,fcntl,hashlib,io,json,os,resource,runpy,signal,sys,tarfile,time
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1<<30,1<<30));os.sched_setaffinity(0,{0,1,2,3})
ROOT=Path(__file__).resolve().parents[3];RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R004';OUT=RUN/'reports';sys.dont_write_bytecode=True
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def ident(p):return {'path':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':sha(p)}
def save(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def deadline(signum,frame):raise TimeoutError('R004 metadata publication20s')
print('WAITING_PROJECT_HEAVY_LOCK R004_PUBLICATION',flush=True)
with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
 fcntl.flock(lock,fcntl.LOCK_EX);start=time.monotonic();start_at=dt.datetime.now(dt.timezone.utc).isoformat();signal.signal(signal.SIGALRM,deadline);signal.setitimer(signal.ITIMER_REAL,19.8)
 assert not(OUT/'publication.json').exists(),'Do not replace a completed publication'
 receipts=[json.loads(q.read_text())for q in sorted((RUN/'attempts').glob('AT*/receipt.json'))];assert len(receipts)==3
 archive_checks=0
 for r in receipts:
  at=RUN/'attempts'/r['attempt'];assert r['status']=='EXIT_ZERO'and r['exit_code']==0 and r['owned_after_cleanup']==[]and not r['owned_group_after_cleanup_exists']
  assert sha(at/'sources.tar.gz')==r['source_archive_sha256']
  with tarfile.open(at/'sources.tar.gz','r:gz')as ar:
   for name,digest in r['sources'].items():assert hashlib.sha256(ar.extractfile(name).read()).hexdigest()==digest;archive_checks+=1
  report=json.loads((at/'work/report.json').read_text());assert report['status']=='PASS'and sha(at/'work/report.json')==r['report_sha256']
  for d in report['outputs'].values():assert sha(ROOT/d['path'])==d['sha256'];archive_checks+=1
 pilot=RUN/'attempts/AT002_one_row_reference_pilot/work';pr=json.loads((pilot/'report.json').read_text());audit=RUN/'attempts/AT003_cost_exit_audit/work';au=json.loads((audit/'report.json').read_text());gate=json.loads((audit/'cost_exit.json').read_text())
 assert pr['rows']==au['rows']==1 and gate['decision']=='COST_STOP'and gate['full128_execution']=='NOT_RUN'and gate['full128_bound_s']>120
 for d in pr['inputs'].values():assert sha(ROOT/d['path'])==d['sha256'];archive_checks+=1
 save(OUT/'cost_exit.json',gate)
 control=json.loads((OUT/'ffn_control_budget.json').read_text());assert control['parent_added_bits']==sum(x['bits']for x in control['parent_added_fields'])==20
 assert control['planned_joint_bits']==control['baseline_bits']+control['parent_added_bits']+control['G_CANCEL17_actual_declared_bits']==32311
 assert control['planned_joint_bytes']==32311/8 and control['planned_joint_bytes_ceiling']==4039
 cancel=ROOT/control['G_CANCEL17_evidence'];cancel_identity=ident(cancel)
 save(RUN/'data/fixture_manifest.json',{'schema':'m007-ffn-original-one-row-fixture-v1','status':'ONE_ROW_READY_FULL128_COST_STOP','rows':1,'original_row':0,'full128_ready':False,'full128_cost_gate':ident(OUT/'cost_exit.json'),'reference':pr['original_reference'],'inputs':pr['inputs'],'products':pr['outputs'],'pilot_driver':pr['driver'],'audit_driver':au['driver'],'scope':'Only original G/norm_ff row0 and Down row0; native serializers declare rows1; not complete128-row RTL fixture'})
 basis={'execution_state':'completed','verdict':'COST_STOP_FULL128; ONE_ROW_LOCAL_REFERENCE_PASS','applicability':'Independent original CPU reference only; exact original row0 Q8(G)/Down and native serialization; no production RTL or EDA','blocker':'Contract full128 bound127.26535248011352s exceeds120s cap','next_step':'Controller decides successor from actual cost exit; no timeout extension or pilot replay','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','runtime_id':'/root/m007_weight_supply_engineering','full128_reference':'NOT_RUN','G_CANCEL17':'AT0123-bit audit/partial cancellation cases reported PASS on6b8b0114...; complete normal regression/final handoff still pending','G_cancel_evidence':cancel_identity,'RTL':'NOT_RUN','static_compile':'NOT_RUN/NOT_REQUIRED','R003':'frozen; no run/budget transfer'}
 save(RUN/'status.json',basis)
 marker='## E016/R004 FFN-REFERENCE-18 current stage (2026-10-23)'
 source=marker+'\n\n原fe9678e4独立CPU参考直接调用，原AT007 norm_ff/G与原权重输入；原逐次F32舍入、Q8 reciprocal/half/roundf、group顺序不变。AT001已有Down诊断row112和AT007 norm_ff→Wi row0交集逐位PASS；仅局部原G row0生成Q8/Down，完整128行严格按成本门未准入。无RTL/EDA/整模重算；唯一后继连线及20bit新增父控制设计预算单列。\n\n证据：[R004交付](../experiment_results/runs/R004/final_delivery.md)、[协议](protocol_ffn_r004.md)。R003以下原摘要原文保留。\n\n---\n\n'
 result=marker+'\n\nexecution_state: completed\nverdict: COST_STOP_FULL128 / ONE_ROW_LOCAL_REFERENCE_PASS\napplicability: 原保存G/norm_ff row0的CPU期望；不签完整128行或RTL。\n\n单行实际0.6786189379636198s，1.35*128*P+10=127.26535248011352s>120；全128 NOT_RUN。已生成G2624个S8 codes/82个F16 scale、norm_ff32组、Down1024个F32；AT003原scalar-vs-batch quant/序列化核对PASS。现20bit父控制计划加A007已声明3bit取消，4036B保守基线上4038.875B/向上4039B，非新父实现/物理fit。\n\n证据：[R004交付](runs/R004/final_delivery.md)、[预算](runs/R004/reports/budget.json)、[cost gate](runs/R004/reports/cost_exit.json)。R003以下原PASS和封账原文保留。\n\n---\n\n'
 status=marker+'\n\nexecution_state: completed\nverdict: COST_STOP_FULL128 / ONE_ROW_REFERENCE_PASS\napplicability: 已完成合同要求的成本出口与实际1行局部参考、接口/控制预算交付；完整128行仍未准入。\n\n无owned参考child/锁等待，G共享文件只读。A010模型实际UNKNOWN；完整同runtime FFN、真实residual/LN/Encoder/30层及物理仍NOT_RUN。下一步交主控集中处理127.265s>120s成本门，不自行延帽或原样重跑。\n\n证据：[R004状态](../experiment_results/runs/R004/status.json)、[R004交付](../experiment_results/runs/R004/final_delivery.md)。R003以下原状态原文保留。\n\n---\n\n'
 changes={}
 for rel,prefix in [('project/E016_m007_single_resource_parent/experiment_source/summary.md',source),('project/E016_m007_single_resource_parent/experiment_results/summary.md',result),('project/E016_m007_single_resource_parent/experiment_status/summary.md',status)]:
  p=ROOT/rel;old=p.read_bytes();assert marker.encode()not in old;new=prefix.encode()+old;p.write_bytes(new);assert new.endswith(old);changes[rel]={'before_sha256':hashlib.sha256(old).hexdigest(),'after_sha256':sha(p),'old_content_preserved_verbatim':True}
 for kind in ['design','results']:
  p=ROOT/f'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/source/{kind}.md';old=p.read_bytes();mark='## M007 FFN-REFERENCE-18 R004 local reference exit (2026-10-23)';assert mark.encode()not in old
  addition='\n'+mark+'\n\nA010：原G row0独立Q8(2624 codes/82 half scales)、norm_ff32组及Down1024 F32参考生成并审计PASS；完整128行成本式127.26535248011352s>120s，严格COST_STOP/NOT_RUN，无RTL/EDA/整模gold。原参考/运行库/完整输出SHA与真实收据见[局部参考交付](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/final_delivery.md)。[逐束连线表](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/reports/ffn_connections.md)固定norm_ff→Wi native0..81→双槽G→1024bit拼接→同quant/A槽1→完整成功屏障→Down；新父计划20bit，复用2套descriptor和原5bit state。A007取消实际声明3bit但最终正常回归待交，联合设计投影4038.875B/向上4039B，非实现fit。若另存两套Wi/Down descriptor将增1024bit超帽。完整Encoder真实skip/residual/LN和本输入128行Down参考仍未就绪；不继承旧e354 PASS。\n'
  p.write_bytes(old+addition.encode());changes[str(p.relative_to(ROOT))]={'before_sha256':hashlib.sha256(old).hexdigest(),'after_sha256':sha(p),'change':'append only'}
 p=RUN/'run.md';old=p.read_text();p.write_text(old.replace('Execution state: planned','Execution state: completed').replace('Verdict: unassessed','Verdict: COST_STOP_FULL128 / ONE_ROW_LOCAL_REFERENCE_PASS')+'\nCurrent qualified results, identities, exact commands and limits: [final_delivery.md](final_delivery.md), reports/publication.json and reports/budget.json. Static/RTL/OOC all0; current contract cost exit does not complete128-row reference.\n')
 report={'execution_state':'completed','current_task':'SM012 FFN-REFERENCE-18 E016/R004 local original Q8(G)/Down CPU reference','stage':'One-row authority/reference/serialization PASS; full128 contract cost gate STOP; connection/control budget delivered','blocker':'Full128 measured bound127.26535248011352s >120s cap','next_step':'Controller decides reference successor; no automatic pilot replay or timeout extension','runtime_id':'/root/m007_weight_supply_engineering','thread_id':None};save(OUT/'A010_completed.json',report)
 sys.path.insert(0,'/home/zwj/.codex/skills/research-agent/scripts');sys.argv=['console.py','report','--root',str(ROOT),'--agent','A010','--input',str(OUT/'A010_completed.json')];log=io.StringIO()
 with contextlib.redirect_stdout(log):
  try:runpy.run_path('/home/zwj/.codex/skills/research-agent/scripts/console.py',run_name='__main__')
  except SystemExit as e:
   if e.code not in [None,0]:raise
 (OUT/'console_completion.log').write_text(log.getvalue());actual_state=json.loads((ROOT/'agent/A010/state.json').read_text());assert actual_state['execution_state']=='completed'and 'FFN-REFERENCE-18'in actual_state['current_task']
 elapsed=time.monotonic()-start;bootstrap=json.loads((OUT/'bootstrap_reads.json').read_text());used=bootstrap['elapsed_s']+sum(r['child_wall_s']for r in receipts)+elapsed;assert elapsed<20 and used<=180
 save(OUT/'budget.json',{'schema':'m007-ffn-reference18-budget-v1','limits_s':{'reference':180,'static':60,'rtl':0,'ooc':0},'used_s':{'reference':used,'static':0,'rtl':0,'ooc':0},'remaining_s':{'reference':180-used,'static':60,'rtl':0,'ooc':0},'reference_child_sum_s':sum(r['child_wall_s']for r in receipts),'bootstrap_read_and_conservative_failure_charge_s':bootstrap['elapsed_s'],'publication_actual_s':elapsed,'bootstrap_basis':bootstrap,'receipt_charges':{r['attempt']:r['child_wall_s']for r in receipts},'old_planning_or_R003_transfer':False})
 artifacts={str(p.relative_to(RUN)):ident(p)for p in sorted(RUN.rglob('*'))if p.is_file()and p!=OUT/'publication.json'}
 save(OUT/'publication.json',{'schema':'m007-ffn-reference18-publication-v1','started_at':start_at,'finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'publication_elapsed_s':elapsed,'peak_self_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'CPU_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'address_space_limit_bytes':1<<30,'stage_verdict':basis['verdict'],'numerical_fixtures_rows':1,'full128':'NOT_RUN_COST_GATE','archive_and_output_checks':archive_checks,'changes':changes,'actual_console_state':actual_state,'G_cancel_declaration_evidence':cancel_identity,'artifacts':artifacts,'R003_raw_files_modified':False,'production_RTL_modified':False,'runtime_identity':'/root/m007_weight_supply_engineering'})
 signal.setitimer(signal.ITIMER_REAL,0);fcntl.flock(lock,fcntl.LOCK_UN)
 print('M007_FFN_REFERENCE18_DELIVERY '+json.dumps({'verdict':basis['verdict'],'full128_cost_bound_s':gate['full128_bound_s'],'reference_charged_s':used,'remaining_reference_s':180-used,'publication_s':elapsed,'checks':archive_checks,'console':actual_state['execution_state']}),flush=True)
