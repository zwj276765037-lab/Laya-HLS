"""Publish controller-owned current records, preserving prior snapshots/history."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
review='measurement_first_LNQ1_review_20261014.md'
contract='ln_qar_runtime_replay_stage_20261014.md'
def write(name, text): (ROOT/name).write_text(text)
def prepend(name, text):
    p=ROOT/name; old=p.read_text(); head, sep, tail=old.partition('\n\n')
    p.write_text(head+'\n\n'+text.strip()+'\n\n'+tail)
assert 'revision: 20 /' in (ROOT/'project/missions/SM005.md').read_text()
write('mission/current.md', f'''# 当前工作：LNQ2运行文件准入与一次同DUT冷启动重放

[LNQ1停止审核](../results/{review})核定AT048 static PASS、full COST_STOP_INVALID_RUNTIME_ROM_STAGING。7份冻结LN ROM在实际xsim目录全部缺失，原日志8条读取告警；末观测marker149，尚未到LN source AR。没有新END/PUBLISH或Q/Wi/G/Down结果，不能判DUT死锁。旧LNQ1一次full额度已消耗，AT047语义FAIL和独立局部PASS保留。

当前[D-M004-LN-QAR-RUNTIME-01]({contract})选择LNQ2：保持AT048全部DUT、两份TB、数据/gold/真实BO和响应profile，只修Tcl/launcher、运行包及只读启动核验。先新目录部署7份ROM，实际每次xsim启动前verify-only核源/目标bytes/SHA及全部fixture/plusargs；缺失/错SHA负例须在spawn前拒绝。已有工程helper只是host准备，不代签新RTL。

static之后，≤120s冷前缀必须观测真实LN source AR及R；成本有据且在3600s内，才准入最多一次新冷full。full前允许一次有因准备修正（总至多两次static/两次短前缀），无需逐项审批；不改TB/DUT。新full一旦启动即消耗额度，任何失败/停止保存原证据交付，不追加full。新结果NOT_RUN，送达不等于执行。

A002唯一实现/工具，A001集中审核；代码E002/experiment、证据E005/R001，不补旧AT048目录或收据、不新增agent。单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB；static24GiB/1800s、RTL8GiB/3600s/40Mcycles、前缀≤120s、语义停滞120s。原帽/guard保持，无新HLS/OOC/P&R/上板。G2338.224019s仅OOC余额、5172s不重启；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。完整普通多窗口Q/L、全模型/13BO请求/恢复、联合资源/物理时序与M003/M004仍开放。
''')
p=ROOT/'results/overview.md'; s=p.read_text(); start=s.index('\n\n')+2; end=s.index('\n\n| 工作', start)
s=s[:start]+f'''[LNQ1有界停止已核]({review})：AT048 static PASS，full缺7份运行ROM而COST_STOP；LN source AR及新发布观察未到达，不能判DUT死锁。下一[LNQ2](../mission/{contract})保持同DUT/TB/数据/profile，只修运行部署/逐次启动核验；短前缀实见LN AR/R、成本准入后至多一次新冷full。新结果NOT_RUN，完整加速器仍未验收。'''+s[end:]
s=s.replace('| LNQ1观测修复 | 新RTL NOT_RUN | 同DUT/数据/profile，修覆盖证据采样时点，至多一次full |',
'''| LNQ1观测修复 | AT048静态PASS；full缺7份ROM而COST_STOP | 新观察/下游未到达，旧额度结束 |
| LNQ2运行包有效重放 | 新RTL NOT_RUN | 逐次启动核验、短前缀AR/R、成本合格后至多一次冷full |''')
p.write_text(s)
prepend('results/hardware_metrics.md', f'''[LNQ1停止审核]({review})：AT048 static108.767826s/2950116KiB、child0/null；full126.977810s/1033296KiB、child−9/semantic_stall。7份338B ROM未部署，8告警；末marker149不是已证最终cycle，无源AR或整链时延。298引用、314哈希路径、2串行guard/35policy已核；286 manifest引用/285路径。3464.199672s只是依赖运行包等价的预算，本次条件不成立。后继LNQ2没有新硬件性能或物理结果。以下保留历史。''')
prepend('results/hardware_progress.md', f'''2026-10-14：[LNQ1停止已核]({review})，AT048新TB静态通过但缺7份ROM，full在源AR前COST_STOP，END/PUBLISH和后段未验证。下一[LNQ2](../mission/{contract})固定同DUT/TB，修部署并加入每次xsim前闸口；短前缀真实AR/R及有据成本后至多一次新full。旧失败不改写，M003/M004开放。以下为历史。''')
for name, rp, cp in [('results/review_queue.md','', '../mission/'), ('results/reviews/SM005.md','../','../../mission/')]:
    prepend(name, f'''## R-SM005-LNQ1-20261014：运行包停止核定，转一次有效重放

对应EV_SM005_LNQ1_AT048_ROM_STAGING_STOP_20261014，并合并ROM prelaunch addendum。AT048 static PASS、full COST_STOP_INVALID_RUNTIME_ROM_STAGING：7份338B源完整，但实际xsim副本全部缺失，8条读取告警；末marker149，无LN source AR/新发布观察/后段。298引用、314哈希路径、2guard/35policy已核；原full额度结束，不补旧目录或判DUT死锁。

D-M004-LN-QAR-RUNTIME-01选择LNQ2。保留AT048 DUT/TB/数据/profile，只修运行文件与逐次启动verify-only闸口；缺失/错SHA目标负例须拒绝spawn。短前缀实见LN AR/R，成本合格后至多一次新冷full；full前一次有因准备修正，普通步骤无需再审批。新结果NOT_RUN，M003/M004开放。

[审核]({rp}{review})；[合同]({cp}{contract})。''')
p=ROOT/'project/missions/SM005.md';s=p.read_text().replace('revision: 20 /','revision: 21 /')
start=s.index('KB1/ATN1/QAR0');end=s.index('最终任务仍分两层：',start)
s=s[:start]+f'''KB1/ATN1/QAR0/LNF0与LNQI0原限定结果保留。[LNQ1停止已核](../../results/{review})：AT048 static PASS，full缺7份运行ROM而COST_STOP，未达LN source AR及新观察；旧一次full额度结束。当前[LNQ2](../../mission/{contract})固定同DUT/两份TB/数据/profile，只修部署与逐次启动核验；短前缀真实AR/R、成本合格后至多一次新冷full。full前允许一次有因准备修正，普通步骤无需逐项审批，不改DUT/TB。新结果NOT_RUN，原帽/无新HLS-OOC及整体控制停排保持。'''+s[end:]
s=s.replace('当前LNQ1观测修复按本页最新合同执行。','当前LNQ2运行包与有效重放按本页最新合同执行。')
p.write_text(s)
p=ROOT/'NEW_CHAT_START.md';s=p.read_text();start=s.index('先读[测量优先计划]');end=s.index('\n\n根目录',start)
s=s[:start]+f'''先读[测量优先计划](mission/hardware_measurement_replan_20261013.md)和[当前任务](mission/current.md)。SM005/E005/R001保留KB1/ATN1/QAR0/LNF0与LNQI0有限结果。最新[LNQ1审核](results/{review})核定AT048 static PASS、full因7份ROM未部署而COST_STOP，末marker149，无源AR、新发布观察或后段；旧一次full额度已用尽，AT047原语义FAIL不改。当前[LNQ2](mission/{contract})固定AT048 DUT/两份TB/数据/profile，只修运行包及每次xsim启动前verify-only闸口，先短前缀真实LN AR/R，再有据准入至多一次冷full。full前一次有因准备修正，无逐项审批；新结果NOT_RUN，送达不代签执行。原帽/无新HLS-OOC/整体控制停排保持。完整普通多窗口Q/L、全模型/13BO请求/恢复/联合资源时序及M003/M004开放。'''+s[end:]
p.write_text(s)
write('agent/A001/result.md', f'''# 项目主控与架构评判：当前审核

execution_state: running
stage: measurement_first_LNQ1_reviewed_LNQ2_delivery_pending

[LNQ1审核](../../results/{review})核定AT048 static PASS/full运行ROM缺失COST_STOP；新发布观察和后段未验证。298引用/314哈希路径、2串行guard/35policy、7份338B ROM及live helper预期身份已核。旧失败与目录保持。

[LNQ2合同](../../mission/{contract})只修运行包和逐次启动核验，固定AT048 DUT/TB/数据/profile；短前缀真实AR/R、成本合格后至多一次新冷full。当前正在直接送达工程，尚不宣称送达或执行；M003/M004开放。
''')
report=dict(execution_state='running', current_task='LNQ1证据审核及LNQ2合同记录完成，正在直接送达工程',
            stage='AT048运行ROM缺失COST_STOP核定；DUT与新观察动态结果未到达', blocker=None,
            next_step='核验工程消息送达，然后等待有界运行包/前缀及至多一次full证据', runtime_id=None,
            thread_id='01a129af-0395-7fd0-95ac-edd54873bd5f')
(OUT/'controller_report_pending.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Updated 9 controller source records; A001 state to be published via console report. Prior 10 records retained.')
