from pathlib import Path
from datetime import datetime,timezone
import json,hashlib
R=Path(__file__).resolve().parents[2];D=Path(__file__).resolve().parent
B=R/'project/E003_production_chain_closure/experiment_results/runs/R003/resident_regression_02'
def sha(p):
 with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def valid(x):
 p=Path(x['path']);return p.is_file() and p.stat().st_size==x['bytes'] and sha(p)==x['sha256']
m=json.loads((B/'input_manifest.json').read_text());r=json.loads((B/'receipt.json').read_text())
assert sha(B/'input_manifest.json')=='2a8d23b82ce961f0b878b47b88823a3578d4afe43eefec468410b3db7ab6697d'
assert len(m['files'])==26 and len(m['fixture_files'])==12
drift=[]
for x in m['files']:
 assert valid(x['frozen']) and all(x['frozen'][k]==x['original'][k] for k in ['bytes','sha256'])
 if not valid(x['original']):drift.append(x['original']['path'])
for x in m['fixture_files']:
 assert valid(x['current']) and all(x['current'][k]==x['original'][k] for k in ['bytes','sha256'])
log=r['full']['driver_log'];assert valid(log)
body=Path(log['path']).read_text()
assert r['full']['status']=='PASS' and all(marker in body for marker in r['full']['marker'])
assert 'cycles=48862' in body and 'actual_AW=512 actual_W=512 actual_B=512 held_B=9217' in body
items=[]
def preserve(p,kind='snapshot'):
 q=D/kind/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
 items.append({'source':str(p.relative_to(R)),'snapshot':str(q.relative_to(R)),'sha256':sha(q)})
for p in [B/'input_manifest.json',B/'receipt.json',Path(log['path']),R/'project/E005_full_request_performance/experiment_results/runs/R001/reports/arithmetic_entry_inventory_20261013.md',R/'project/E005_full_request_performance/experiment_source/protocol.md',R/'.research-agent/communications/measurement-first-P0-entry-progress-20261013.json']:
 preserve(p)
note='2026-10-13 P0入口已确定：resident_regression_02的26份冻结源/脚本、12份fixture及原full标记定向核验；6处live漂移隔离。AT001新数值/周期仍NOT_RUN。按[计时边界答复](measurement_first_P0_review_20261013.md)直接继续P1，KB0可用后做KB1；不等待生产控制器。'
for rel in ['results/overview.md','results/review_queue.md','results/reviews/SM005.md']:
 p=R/rel;preserve(p,'prior_records');old=p.read_text();first,rest=old.split('\n',1)
 txt=note.replace('(measurement_first_P0_review_20261013.md)','(../measurement_first_P0_review_20261013.md)') if rel=='results/reviews/SM005.md' else note
 if rel=='results/overview.md':
  rest=rest.replace('已下达盘点，新的测量NOT_RUN','已选冻结resident Down，AT001计量准备；新测量NOT_RUN')
 p.write_text(first+'\n\n'+txt+'\n\n'+rest.lstrip('\n'))
p=R/'agent/A001/result.md';preserve(p,'prior_records')
p.write_text('# 项目主控与架构评判：最新交付\n\nexecution_state: completed\nstage: measurement_first_P0_reviewed\n\n[所选入口及计时边界](../../results/measurement_first_P0_review_20261013.md)已核定，P0结束并直接继续P1 Down KB0。定向核26份frozen源/脚本、12fixture、原48862全TB周期与512 AW/W/B，6处live变化隔离。新AT001数值/周期尚NOT_RUN，held_B不能未经定义直接当可优化瓶颈。\n\nKB0后直接按实测选KB1；P3架构表只读并行，旧控制生成停排，原帽保持。主控未执行DUT工具。\n')
v={'review':'R-SM005-MEASUREMENT-FIRST-P0-20261013','at':datetime.now(timezone.utc).isoformat(),'frozen_sources_verified':26,'fixture_current_verified':12,'source_live_drift':drift,'original_full_markers_verified':r['full']['marker'],'snapshots':items,'no_DUT_tools_run':True,'scope':'Selected entry identity only; no new numerical/performance acceptance; other inventory entries not re-audited'}
(D/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
report={'execution_state':'completed','current_task':'核定Down KB0所选冻结入口与可比较计时边界','stage':'measurement_first_P0_reviewed','blocker':None,'next_step':'工程完成AT001真实数值和周期分解，直接选择一个瓶颈做KB1；P3只读比较继续','runtime_id':None,'thread_id':'01a129af-0395-7fd0-95ac-edd54873bd5f'}
(D/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'frozen':26,'fixtures':12,'live_drift':len(drift),'new_KB0':'NOT_RUN'},ensure_ascii=False))
