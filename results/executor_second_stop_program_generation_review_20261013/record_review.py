from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,re,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E003_production_chain_closure/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def get(p):return json.loads(p.read_text())
def ref(x):
 p=Path(x['path']);return p.is_file() and sha(p)==x['sha256'] and p.stat().st_size==x['bytes']
checks={}; snapshots=[]
for name in ['executor_hls_02','graph_program_owned_hls_03','graph_program_owned_hls_04']:
 p=B/name; rec=get(p/'receipt.json');man=get(p/'input_manifest.json');g=get(p/'guard_hls/guard_result.json');pl=get(p/'guard_hls/guard_plan.json');pol=get(p/'guard_hls/policy_checks.json')
 assert rec['hls']['guard']==g
 assert pl['maximum_seconds']==1800 and pl['maximum_owned_rss_kb']==24*1024*1024 and pl['semantic_stall_seconds']==120
 assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in pol)
 assert ref(rec['input_manifest']) and ref(rec['hls']['driver_log'])
 rows=[]
 for f in man['files']:
  assert ref(f['frozen']) and f['frozen']['sha256']==f['original']['sha256']
  rows.append({'relative':f['relative'],'sha256':f['frozen']['sha256']})
 checks[name]={'status':rec['status'],'guard':g,'policy_samples':len(pol),'frozen_pairs':rows,'source_count':man['source_count']}
 for rel in ['receipt.json','input_manifest.json','guard_hls/guard_result.json','guard_hls/guard_plan.json','guard_hls/policy_checks.json','guard_hls/driver.log']:
  snapshots.append(p/rel)
e=checks['executor_hls_02'];assert e['status']=='COST_STOP' and e['guard']['trigger']=='semantic_stall'
p3=B/'graph_program_owned_hls_03';r3=get(p3/'receipt.json');assert r3['status']=='FAIL_PORTS' and not r3['port_evidence']['pass']
t3=Path(r3['port_evidence']['generated']['path']);assert ref(r3['port_evidence']['generated']);assert "assign program_pending_read = 1'b0;" in t3.read_text()
p4=B/'graph_program_owned_hls_04';r4=get(p4/'receipt.json');pe=r4['port_evidence'];assert r4['status']=='PASS_SCOPED_GENERATION' and pe['pass']
assert pe['fifo_count']==8 and pe['fifo_signal_count']==24
top=Path(pe['generated']['path']);assert ref(pe['generated']);sv=top.read_text()
verified=[]
for group in list(pe['fifos'].values())+[pe['scalars']]:
 for k, spec in group.items():
  assert spec['pass'] and len(spec['actual'])==1
  name=spec['actual'][0];m=re.search(r'^\s*(input|output)\s*(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?'+re.escape(name)+r'\s*;',sv,re.M)
  assert m,name
  width=int(m.group(2))-int(m.group(3))+1 if m.group(2) is not None else 1
  assert m.group(1)==spec['expected_direction'] and width==spec['expected_width']
  verified.append({'port':name,'direction':m.group(1),'width':width})
assert 'assign program_pending_write = grp_step_fu_719_program_pending_write;' in sv
mod=next(m for m in r4['resource_evidence']['modules'] if m['module']=='laya_graph_program_owned_sequencer');assert ref(mod['file'])
xml=ET.parse(mod['file']['path']);res=xml.find('.//AreaEstimates/Resources');actual={x.tag:int(x.text) for x in res};reported={k:int(v) for k,v in mod['estimated_resources'].items()}
assert all(actual[k]==v for k,v in reported.items())
checks['graph_program_owned_hls_04'].update({'verified_top_ports':verified,'generated_top':pe['generated'],'HLS_top_estimate':reported,'behavioral_RTL_not_reviewed':True})
snapshots += [t3,top,Path(mod['file']['path']),B/'graph_program_owned_hls_03_port_diagnosis_A004_20261013.md',
 B/'executor_hls_02/work/hls/syn/report/csynth_design_size.rpt',B/'norm_provenance_specialization_host_01/receipt.json',
 B/'executor_hls_host_03/receipt.json',B/'graph_program_owned_host_05/receipt.json',
 R/'.research-agent/communications/executor-first-hls-second-stop-progress-20261013.json',
 R/'agent/A002/state.json',R/'mission/current.md',R/'results/overview.md',R/'results/review_queue.md',R/'results/reviews/SM003.md',R/'agent/A001/result.md']
items=[]
for p in snapshots:
 rel=p.relative_to(R);out=D/'snapshot'/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(p.read_bytes())
 items.append({'source':str(rel),'snapshot':str(out.relative_to(R)),'sha256':sha(out)})
v={'schema':1,'review':'R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION-20261013','created_at':datetime.now(timezone.utc).isoformat(),
'scope':'Executor COST_STOP, program old FAIL_PORTS and new generation/port/estimate facts only; no new dynamic host or RTL behavior verdict',
'attempts':checks,'snapshots':items,'no_dut_tools_run':True,
'not_independently_recomputed':['gdce direct nondebug instruction counts and defined function counts','A004 LLVM per-pass control-flow analysis','host nine/seven/twelve-process functional coverage'] }
vp=D/'verification.json';assert not vp.exists();vp.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
section="""## R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION-20261013：executor仍停，program生成端口恢复

executor_hls_02 COST_STOP已核，285.493267s、1476484KiB/1426实际RSS，Compile/Link226981仍Unroll/Inline pending；NORM与byte比较联合变化未解决生成瓶颈，不作硬件收益。program_03保留FAIL_PORTS，原LAP被生成成dangling input/read0。

核查期间program_04完成PASS_SCOPED_GENERATION：442.930003s、peak5421624KiB/2204RSS，8FIFO/24信号与3标量实际声明核验，LAP8192bit output din/full_n/write及真实step连接恢复。顶层SHA e9bc2882d48b411d5c5243c96622006385ef8c8b40793e876888020702aada92；仅候选HLS估计BRAM18=24/DSP1/FF69372/LUT254536/URAM0。接纳这些生成事实，不代签depth2真实LAP/LAX/LAC行为、executor或整链。

[答复](LINK)及[核验](AUDIT)固定三attempt冻结/guard/端口证据。工程先执行已准备program有限RTL，executor完整比较修复及针对剩余假设的有界诊断继续；不反复仅减累计指令，不原样重启/扩帽，无新审批前置。C正常NORM先行，D/完整恢复后置，C/D周期NOT_RUN、M003/M004未完成，原预算不变。

"""
def insert(rel,text):
 p=R/rel;old=p.read_text();assert 'R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION-20261013' not in old
 title,rest=old.split('\n',1);p.write_text(title+'\n\n'+text+rest.lstrip('\n'))
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,section.replace('LINK',pre+'executor_second_stop_program_generation_reply_20261013.md').replace('AUDIT',pre+'executor_second_stop_program_generation_review_20261013/verification.json'))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[第二停止与program生成核定]('+pre+'executor_second_stop_program_generation_reply_20261013.md)（R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION-20261013）：executor_02仍COST_STOP/无RTL；program_04已完成限定生成且8FIFO端口正确、LAP输出恢复。下一先验证program真实depth2行为，executor残余memcmp修复及区分性定位继续；未签C/D计算周期或联合资源。C先行，D/完整恢复后置，原帽/预算及M003/M004未完成状态保持。\n\n')
(R/'agent/A001/result.md').write_text("""# 项目主控与架构评判：最新交付

execution_state: completed
stage: executor_second_stop_program_generation_reviewed
scope: 第二次executor成本停止、program生成及端口限定事实核定

[审核答复](../../results/executor_second_stop_program_generation_reply_20261013.md)保留executor_hls_02 COST_STOP；联合结构变化虽减累计中间指令，仍无RTL，未证明解决原瓶颈。

program_owned_hls_03保持FAIL_PORTS；核查期间_04完成PASS_SCOPED_GENERATION，实际8FIFO/24信号与3标量方向/宽度正确，8192位LAP从step接到输出，资源XML仅作该候选估计。不是depth2行为、executor或整链PASS。三attempt冻结及原始guard/top证据见[核验](../../results/executor_second_stop_program_generation_review_20261013/verification.json)。

工程继续program有限RTL、executor完整比较修复及有区分力定位；无逐项审批前置，不原样重启或扩保护。C正常NORM先行，D/完整恢复后置；原单重工具/全部帽/G仅OOC预算保持，C/D周期NOT_RUN、M003/M004未完成。主控未启动DUT工具。
""")
report={'execution_state':'completed','current_task':'核定executor第二停止与program实际生成端口出口','stage':'executor_second_stop_program_generation_reviewed','blocker':None,'next_step':'工程验证生成program实际depth2行为；executor受影响host后有依据的新候选或区分实验，C先行','runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'frozen_pairs':{n:len(x['frozen_pairs']) for n,x in checks.items()},'program04_ports_verified':len(verified),'snapshot_files':len(items),'verification_sha256':sha(vp)},ensure_ascii=False))

