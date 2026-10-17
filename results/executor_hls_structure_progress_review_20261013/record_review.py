from pathlib import Path
from datetime import datetime,timezone
import json,hashlib
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E003_production_chain_closure/experiment_results/runs/R003';E=R/'project/E002_Laya_HLS/experiment'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def get(p):return json.loads(p.read_text())
def meta(p):return {'path':str(p.relative_to(R)),'sha256':sha(p),'bytes':p.stat().st_size}
def ref(x):
 p=Path(x['path']);return sha(p)==x['sha256'] and p.stat().st_size==x['bytes']
p1=B/'graph_program_owned_hls_01';r1=get(p1/'receipt.json');g1=get(p1/'guard_hls/guard_result.json')
assert r1['status']=='FAIL' and g1==r1['hls']['guard'] and g1['trigger'] is None and g1['child_exit_code']==1
assert len(r1['generated_candidates'])==0
assert ref(r1['hls']['driver_log'])
log=(p1/'guard_hls/driver.log').read_text(); lines=[x for x in log.splitlines() if 'Undefined function memcmp' in x];assert len(lines)==4 and 'Syn check fail!' in log
p2=B/'graph_program_owned_hls_02';r2=get(p2/'receipt.json');f2=get(p2/'driver_failure.json')
assert r2['status']=='FAIL_REUSE_IDENTITY' and not r2['hls']['started'] and not f2['hls_started']
p3=B/'graph_program_owned_hls_03'
# Snapshot the mutable candidate once; it is not a terminal verdict.
r3=get(p3/'receipt.json');launch3=get(p3/'guard_hls/launch.json')
s=(B/'executor_hls_01/work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.err.log').read_text()
assert s.count('cost=never')==1138 and s.count('Inlining function')==1
paths=[
R/'.research-agent/communications/executor-first-hls-structure-progress-20261013.json',
B/'executor_hls_01_cost_diagnosis_A005_20261013.md',
B/'executor_hls_01/work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.err.log',
p1/'receipt.json',p1/'guard_hls/driver.log',p1/'guard_hls/guard_result.json',
p2/'receipt.json',p2/'driver_failure.json',
B/'graph_program_owned_host_04/receipt.json',
p3/'receipt.json',p3/'guard_hls/launch.json',p3/'guard_hls/guard_plan.json',p3/'guard_hls/driver.log',
E/'include/laya_packet_equal.h',
E/'hls/platform/generated_provenance_events.cpp',
E/'include/laya_generated_provenance_events.h',E/'hls/control/task_lifecycle_fsm.cpp',
R/'agent/A005/result.md',R/'agent/A006/result.md',
R/'mission/current.md',R/'results/overview.md',R/'results/review_queue.md',R/'results/reviews/SM003.md',R/'agent/A001/result.md']
snaps=[]
for p in paths:
 rel=p.relative_to(R); b=p.read_bytes(); out=D/'snapshot'/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(b)
 snaps.append({'source':str(rel),'snapshot':str(out.relative_to(R)),'sha256':sha(out),'bytes':len(b)})
v={'schema':1,'review':'R-SM003-EXECUTOR-HLS-STRUCTURE-PROGRESS-20261013','created_at':datetime.now(timezone.utc).isoformat(),
'scope':'Bounded static diagnosis and candidate-direction review; no new DUT run, no host-wide or hardware PASS',
'executor_lto_remarks':{'never_inline':1138,'explicit_inline':1,'last_events':s.splitlines()[-6:],'root_cause_not_proven':True},
'program_hls_01':{'status':r1['status'],'guard':g1,'errors':lines,'driver_reference_verified':True,'generated_candidates':0},
'program_hls_02':{'status':r2['status'],'failure':f2,'hls_started':False},
'program_hls_03_observation':{'initial_or_current_receipt_status':r3['status'],'receipt_hls':r3.get('hls'),'actual_launch':launch3,'not_terminal_verdict':True},
'host_04_receipt_status':get(B/'graph_program_owned_host_04/receipt.json')['status'],
'reply':meta(R/'results/executor_hls_structure_progress_reply_20261013.md'),'snapshots':snaps}
vp=D/'verification.json';assert not vp.exists();vp.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
section="""## R-SM003-EXECUTOR-HLS-STRUCTURE-PROGRESS-20261013：具体结构修复继续

定位口径已核：executor最后LTO reflow/宽口disaggregate，1138 NeverInline及1明确inline，不支持自动inline爆炸归因。NORM专用descriptor/BEGIN精简有具体可达结构依据，仍须双宏完整gold/泛型对照、受影响host及新HLS回答效果；不扩展D/Q或恢复范围。

program_owned_hls_01四项Undefined memcmp为实际综合FAIL（123.832938s、peak2536828KiB、618RSS capture、child1/trigger null），区别于executor COST_STOP。_02因NORM header漂移在复用预检查拒绝、HLS未启动。完整逐byte XOR/OR修复静态语义可接受；host_04 PASS仅按receipt/工程报告记录，新_03有真实launch和中间报告，尚未签终态或端口/资源。不同top指令数不能直接比较。

接受C接线中producer物理fence与F10整体排空分开，sidecar原A/route持续至真实LTC末pop；有限段验证不代签全链。工程按原授权连续推进，无新审批前置，下一集中判断看生成实际出口。C先行、D及完整恢复后置，原帽/预算/单重工具不变，C/D周期NOT_RUN、M003/M004未完成。

[答复](LINK)及[静态证据快照](AUDIT)；无主控DUT运行或新增硬件PASS。

"""
def insert(rel,txt):
 p=R/rel;old=p.read_text();assert 'R-SM003-EXECUTOR-HLS-STRUCTURE-PROGRESS-20261013' not in old
 first,rest=old.split('\n',1);p.write_text(first+'\n\n'+txt+rest.lstrip('\n'))
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,section.replace('LINK',pre+'executor_hls_structure_progress_reply_20261013.md').replace('AUDIT',pre+'executor_hls_structure_progress_review_20261013/verification.json'))
for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[生成结构进展核定]('+pre+'executor_hls_structure_progress_reply_20261013.md)（R-SM003-EXECUTOR-HLS-STRUCTURE-PROGRESS-20261013）：NORM专用地址/BEGIN为待验证结构减法；program原memcmp综合FAIL已定位，完整byte比较修复后新候选已实际启动，未签生成通过。复用header漂移拒绝保留，独立接线准备继续；producer物理安全与F10整体排空分开。C先交真实NORM，D和完整恢复后置，无新增审批/预算，M003/M004未完成。\n\n')
(R/'agent/A001/result.md').write_text("""# 项目主控与架构评判：最新交付

execution_state: completed
stage: executor_hls_structure_progress_reviewed
scope: 首生成候选的具体结构修复及program综合错误分类

[答复](../../results/executor_hls_structure_progress_reply_20261013.md)接受NORM专用descriptor/BEGIN结构减法方向，效果待双宏gold/泛型对照、受影响host及新HLS。executor LTO证据不支持auto-inline爆炸归因；旧COST_STOP保持。

program_owned_hls_01为明确Undefined memcmp综合FAIL；_02复用身份预检查拒绝未启动HLS。逐byte XOR/OR完整相等修复静态语义可接受，_03已有真实launch及中间报告，尚无本次生成验收。host_04仅记录receipt所载有限PASS，未重审或扩大。

C sidecar以真实adapter帧建立旧A/route并保持至LTC末pop；producer物理fence与全adapter排空分开以免BEGIN/END自等待。工程无需新审批继续候选与独立接线，C先行、D/完整恢复后置。原预算/帽/单重工具保持，C/D周期NOT_RUN、M003/M004未完成。[静态核查](../../results/executor_hls_structure_progress_review_20261013/verification.json)不代表新硬件PASS。
""")
report={'execution_state':'completed','current_task':'核定executor NORM结构候选及program memcmp综合修复','stage':'executor_hls_structure_progress_reviewed','blocker':None,'next_step':'工程继续受影响验证与新生成；下一集中审核真实生成出口，随后C NORM数值周期','runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'snapshots':len(snaps),'verification_sha256':sha(vp),'review_scope':v['scope']},ensure_ascii=False))

