"""Update controller source records after the AT049 scoped review."""
from pathlib import Path
import hashlib,json
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
review='measurement_first_LNQ2_review_20261014.md';contract='ffn_residual_reference_stage_20261014.md'
def write(n,s):(ROOT/n).write_text(s)
def prepend(n,s):
 p=ROOT/n;head,_,tail=p.read_text().partition('\n\n');p.write_text(head+'\n\n'+s.strip()+'\n\n'+tail)
assert 'revision: 21 /' in (ROOT/'project/missions/SM005.md').read_text()
basis=[]
for n in ['project/E002_Laya_HLS/experiment/tests/full_reference.py',
          'project/E002_Laya_HLS/experiment/hls/operators/vector_and_ffn.cpp',
          'project/E002_Laya_HLS/experiment/hls/operators/vector_full_compute.cpp',
          'project/E002_Laya_HLS/experiment/hls/common/laya_memory_map.cpp',
          'project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_FFN_residual_readonly_20261014.md']:
 p=ROOT/n;b=p.read_bytes();basis.append(dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
deliveries=[]
for mid in ['measurement-first-LNQ2-FFN-residual-readonly-query-20261014','measurement-first-LNQ2-FFN-residual-readonly-answer-20261014']:
 p=ROOT/'.research-agent/communications'/f'{mid}.json';d=json.loads(p.read_text());assert d['status']=='delivered'
 fields=['from_role','from_thread_id','to_role','to_thread_id','kind','text','in_reply_to']
 h=hashlib.sha256(json.dumps({k:d[k] for k in fields},ensure_ascii=False,sort_keys=True).encode()).hexdigest()
 assert h==d['payload_sha256'];assert (ROOT/d['message_file']).read_text()==d['text']
 deliveries.append(dict(id=mid,path=str(p),payload_sha256=h,status=d['status']))
(OUT/'successor_basis.json').write_text(json.dumps(dict(at=datetime.now(timezone.utc).isoformat(),files=basis,
 messages=deliveries,verified='reference F32 add(hidden,down), no bias, TMP/HIDDEN task fields and alternate-bank memory mapping',
 limitations='Historical Down/encoder checkpoint SHA and D2-I reuse limits are engineering-reported here; FFREF0 must freeze/verify actual source paths and direct graph comparison before adoption'),ensure_ascii=False,indent=2)+'\n')
write('mission/current.md',f'''# 当前工作：FFREF0末FFN残差独立参考与硬件接点

[LNQ2限定审核](../results/{review})接纳AT049正常四行单实例同runtime：外部enc0 residual→LN→原唯一Q→Wi→真实DDR/reader→G→同Q→Down，全部原独立gold/真实存储/末B/lease/实际消费通过，全冷TB375074cycles。480引用/328哈希路径、289 manifest引用/288路径、3串行guard/39policy已核。LN目的本地64KiB、下游393216B终检通过，不签全STATE0/13BO。AT047 FAIL与AT048 COST_STOP不回写；完整M003/M004未完成。

当前[D-M004-FFN-RESIDUAL-SOURCE-01]({contract})选择FFREF0。末残差skip是LN前HIDDEN；原图F32 add(hidden,down)、无bias，生产任务以TMP/Down和HIDDEN/skip为两源，写另一HIDDEN bank。先沿AT038原完整S128参考前缀捕获skip/Down/enc0末输出及四行，直接核AT049 Down gold和旧独立encoder_00_out；同时给出点名现成F32加法核的有限双源AXI残差producer方案。旧D2-I固定S64/stage4/64行的CPU/CSim及生成结构不当本四行RTL。

本阶段仅host≤8GiB/120s、一个观察封装及一次有因修正；保留数学/原输入/全S128依赖。新DUT/HLS/RTL/整链不运行，FFREF0结果NOT_RUN。普通准备连续执行，无逐步用户审批；工程交付后再集中选择具体残差硬件验证。

A002唯一实现/工具；代码E002/experiment、证据E005/R001。CPU0–3/nice19/idle、MemAvailable>192GiB、全项目单重工具及原所有帽保持，无新agent。无新HLS/OOC/P&R/上板；G2338.224019s仅OOC余额，5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；完整普通Q/L多窗口、Attention/WO/residual硬件、28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序及M003/M004开放。
''')
p=ROOT/'results/overview.md';s=p.read_text();start=s.index('\n\n')+2;end=s.index('\n\n| 工作',start)
s=s[:start]+f'''[LNQ2正常四行链已接纳]({review})：AT049以外部enc0 residual为输入，真实LN→同Q→Wi→DDR/reader→G→同Q→Down连续完成全部原gold/存储/末B/lease/消费；全冷375074cycles。下一[FFREF0](../mission/{contract})先冻结末残差skip/Down/输出的完整图独立身份并明确双源读写接口，只运行有界host前缀。完整加速器仍未验收。'''+s[end:]
s=s.replace('| LNQ2运行包有效重放 | 新RTL NOT_RUN | 逐次启动核验、短前缀AR/R、成本合格后至多一次冷full |',
'''| LNQ2运行包有效重放 | AT049正常四行同runtime LN→Q→Wi→G→Q→Down PASS；全TB375074 | 限定接纳；外部residual、末FFN residual与生产/物理缺口保留 |
| FFREF0末残差独立源 | 新host结果NOT_RUN | 全S128参考前缀对照Down/enc0输出，具体残差硬件接点设计 |''')
s=s.replace('LN producer已在AT040独立有限样本通过，尚未接入该后段；完整模型与生产恢复未验证。',
            'LN producer已在AT049接入同一后段并通过限定四行检查；末FFN residual、完整模型与生产恢复未验证。')
p.write_text(s)
prepend('results/hardware_metrics.md',f'''[LNQ2限定审核]({review})：AT049全冷TB375074cycles，源Q接受168901→A169979=1078，Wi cfg224172→消费271089=46917，Down cfg358881→消费375073=16192。G cfg271094→最终消费=103979；新A publish331802与ready观察331815分开。END witness168820、响应168843、PUBLISH168898、源lease终检170043。下游393216B终扫含142336B输出/250880B保护，LN另有64KiB窗口；非全BO。480引用/328路径、3guard/39policy核验；工具static/prefix/full109.060587/34.095397/2526.459942s，full峰1034284KiB，均原帽内。仅本profile模块链周期，不签优化收益/吞吐/Fmax；FFREF0为host准备。以下保留历史。''')
prepend('results/hardware_progress.md',f'''2026-10-14：[LNQ2四行链已接纳]({review})，AT049保留AT048 DUT/TB，仅修启动包后取得原独立gold、LN真实发布/lease到Q/Wi/G/Q/Down及最终存储/消费PASS。原AT047/48失败不改写。下一[FFREF0](../mission/{contract})独立完整图捕获末残差两源/结果并定双源AXI/另一HIDDEN bank接点，只运行host前缀；未新跑残差RTL。M003/M004开放。以下为历史。''')
for n,rp,cp in [('results/review_queue.md','','../mission/'),('results/reviews/SM005.md','../','../../mission/')]:
 prepend(n,f'''## R-SM005-LNQ2-20261014：四行同runtime接纳，转末残差独立源

AT049 PASS_SCOPED_NORMAL_FOUR_ROWS：真实LN→唯一Q→Wi→DDR/reader→G→同Q→Down、原独立gold/存储/末B/lease/响应消费及保护终扫通过，全冷375074cycles。480引用/328哈希路径、289 manifest/288路径、3串行guard/39policy已核；运行包闸口与原END/PUBLISH观察实际执行。原AT047 FAIL/AT048 COST_STOP保持；不签全STATE0/13BO、任意并发/恢复或物理部署。

D-M004-FFN-RESIDUAL-SOURCE-01选择FFREF0：原完整S128参考前缀捕获skip/Down/末输出，核AT049与旧独立enc0 checkpoint；同时点名可复用F32加法和双源AXI/另一HIDDEN bank方案。host≤8GiB/120s、一封装/一次有因修正，无新DUT/RTL/HLS或长链；新结果NOT_RUN，M003/M004开放。

[审核]({rp}{review})；[合同]({cp}{contract})。''')
p=ROOT/'project/missions/SM005.md';s=p.read_text().replace('revision: 21 /','revision: 22 /')
start=s.index('KB1/ATN1/QAR0');end=s.index('最终任务仍分两层：',start)
s=s[:start]+f'''KB1/ATN1/QAR0/LNF0与LNQI0原限定结果保留。[LNQ2已接纳](../../results/{review})：AT049四行单实例LN→Q→Wi→G→同Q→Down同runtime全gold/存储/lease/消费PASS，TB375074；旧AT047/48失败不回写。当前[FFREF0](../../mission/{contract})只做原全S128参考前缀，冻结末残差skip/Down/输出并核直接字节身份，设计一个有限双源残差producer接点。host≤8GiB/120s、一个封装及一次有因修正，不新跑DUT/HLS/RTL；新结果NOT_RUN，原工具帽及整体控制停排保持。'''+s[end:]
s=s.replace('当前LNQ2运行包与有效重放按本页最新合同执行。','当前FFREF0末残差独立源与接点按本页最新合同执行。');p.write_text(s)
p=ROOT/'NEW_CHAT_START.md';s=p.read_text();start=s.index('先读[测量优先计划]');end=s.index('\n\n根目录',start)
s=s[:start]+f'''先读[测量优先计划](mission/hardware_measurement_replan_20261013.md)和[当前任务](mission/current.md)。最新[LNQ2审核](results/{review})接纳AT049正常四行单实例LN→同Q→Wi→DDR/reader→G→同Q→Down，同runtime原gold/末B/lease/消费及保护终检通过，全冷375074cycles。外部输入仍为独立enc0 attention residual，末FFN residual、生产全图/恢复/物理未验；AT047语义FAIL/AT048缺ROM COST_STOP保留。当前[FFREF0](mission/{contract})沿原全S128参考捕获skip/Down/enc0末输出并核AT049 gold，给具体残差双源AXI/另一HIDDEN bank方案，仅host≤8GiB/120s、一封装/一次有因修正，无新DUT/HLS/RTL长链。新结果NOT_RUN，送达不代签执行；原帽、无新OOC、整体控制停排及M003/M004开放保持。'''+s[end:];p.write_text(s)
write('agent/A001/result.md',f'''# 项目主控与架构评判：当前审核

execution_state: running
stage: measurement_first_LNQ2_reviewed_FFREF0_delivery_pending

[LNQ2审核](../../results/{review})接纳AT049正常四行LN→Q→Wi→G→同Q→Down同runtime PASS，TB375074。480引用/328路径、3guard/39policy及实际数值/存储/lease检查已核；旧失败保留，M003/M004开放。

工程残差只读答复已核主要原图/任务/存储语义。[FFREF0合同](../../mission/{contract})只运行有界原参考前缀，冻结末残差两源/结果与具体硬件接点；无新残差RTL。本轮正在直接送达，尚不宣称交付或执行。
''')
report=dict(execution_state='running',current_task='LNQ2限定接纳及FFREF0合同已记录，正在直接送达工程',stage='480引用/328路径、3guard/39policy已核；四行真实链PASS，末残差前置身份待补',blocker=None,next_step='核验消息送达；工程执行有界FFREF0独立参考与硬件接点，无新RTL',runtime_id=None,thread_id='01a129af-0395-7fd0-95ac-edd54873bd5f')
(OUT/'controller_report_pending.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Nine source records updated; prior ten files retained; successor evidence and read-only communication verified.')
