from pathlib import Path
from datetime import datetime,timezone
import hashlib,json

R=Path(__file__).resolve().parents[2]
D=Path(__file__).resolve().parent
B=R/'project/E003_production_chain_closure/experiment_results/runs/R003'
rid='D-M003-OWNED-PURPOSE-COVERAGE-01'
reply='executor_owned_purpose_coverage_reply_20261013.md'
paths=[
 R/'project/E002_Laya_HLS/experiment/hls/control/executor_handoff_protocol.cpp',
 R/'project/E002_Laya_HLS/experiment/hls/control/bootstrap_snapshot_protocol.cpp',
 B/'graph_program_owned_hls_05/frozen/hls/control/executor_handoff_protocol.cpp',
 B/'graph_program_owned_hls_05/frozen/hls/control/bootstrap_snapshot_protocol.cpp',
 B/'graph_program_owned_hls_05/work/hls/syn/verilog/laya_graph_program_owned_sequencer_validate_2.v',
 B/'graph_program_owned_hls_05/work/hls/syn/verilog/laya_graph_program_owned_sequencer_p_anonymous_namespace_validate_fields.v',
 R/'results/executor_wide_fifo_program_repair_reply_20261013.md',
 R/'.research-agent/communications/executor-owned-purpose-negative-scope-question-20261013.json',
 R/'results'/reply]
source=paths[0].read_text()
assert 'm.kind = Kind(p[8])' in source and 'source[8] = 1; source[9] = 0;' in source
assert paths[0].read_bytes()==paths[2].read_bytes()
assert paths[1].read_bytes()==paths[3].read_bytes()
caller=paths[4].read_text();validator=paths[5].read_text()
assert '.purpose(trunc_ln102_1_reg_720)' in caller
assert 'input  [15:0] purpose;' in validator
assert "purpose == 16'd1" in validator
snaps=[]
for p in paths:
 out=D/'snapshot'/p.relative_to(R);out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(p.read_bytes())
 snaps.append({'source':str(p.relative_to(R)),'snapshot':str(out.relative_to(R)),
               'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'bytes':out.stat().st_size})
v={'decision':rid,'created_at':datetime.now(timezone.utc).isoformat(),'snapshots':snaps,
 'source_frozen_equal':True,'wire_has_independent_source_purpose':False,
 'nested_validator_has_actual_16bit_scalar_purpose':True,
 'supersedes':'Previous demand for unsupported purpose through LHC owner wire',
 'no_DUT_tools_run':True,'functional_generation_review':'NOT_PERFORMED_IN_THIS_DECISION',
 'new_RTL_negative_test':'NOT_RUN_BY_CONTROLLER'}
(D/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')

def insert(rel,text):
 p=R/rel;s=p.read_text();assert rid not in s
 q=D/'prior_records'/rel;q.parent.mkdir(parents=True,exist_ok=True);q.write_text(s)
 title,rest=s.split('\n',1);p.write_text(title+'\n\n'+text+'\n\n'+rest.lstrip('\n'))

for rel,pre in [('mission/current.md','../results/'),('results/overview.md','')]:
 insert(rel,'最新[purpose覆盖边界更正]('+pre+reply+')（'+rid+'）：LHC owner wire不携独立source purpose，撤回此前要求该wire传unsupported purpose的测试路径。保留真实owned top合法路径，接纳同冻结实际nested validator的16bit参数负例；模块拒绝不代签顶层无安装副作用。schema和原冻结不改，C完整NORM基线仍先行，M003/M004未完成。')
for rel,pre in [('results/review_queue.md',''),('results/reviews/SM003.md','../')]:
 insert(rel,'## '+rid+'：更正不可表达的owner purpose负例要求\n\n已核LHC解码固定恢复source purpose1，bytes8是kind。采用原top合法kind4正路径，加同冻结generated nested validate_fields端口purpose1正对照及0/2/0x0101负例；独立模块只签非OK返回，不代签owner安装/完整wire路径。无需修改schema或新增HLS，已运行RTL03冻结保持；补例实施/验收待工程，C优先和预算不变。\n\n[答复]('+pre+reply+')；[静态证据]('+pre+'executor_owned_purpose_coverage_decision_20261013/verification.json)。')
p=R/'agent/A001/result.md';q=D/'prior_records/agent/A001/result.md';q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
p.write_text('# 项目主控与架构评判：最新交付\n\nexecution_state: completed\nstage: owned_purpose_coverage_corrected\n\n[接口答复](../../results/'+reply+')更正上一审核不可表达的LHC owner purpose负例要求。已静态核wire恢复purpose1与生成nested validator的实际16bit接口。采用原top合法路径和同冻结模块端口负例，schema/冻结不变，不代签顶层副作用或当前RTL行为。\n\n工程继续原授权串行验证，C完整NORM测量先行；C/D周期未取得、M003/M004未完成，原预算不变。主控未执行DUT工具。\n')
report={'execution_state':'completed','current_task':'核定owned purpose真实可表达负例边界并更正前次审核',
 'stage':'owned_purpose_coverage_corrected','blocker':None,
 'next_step':'工程复用冻结generated validator有界补例，继续program/executor及C基线',
 'runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'decision':rid,'snapshot_count':len(snaps),'records_updated':5}))
