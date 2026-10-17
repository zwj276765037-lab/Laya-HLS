from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
def put(p,s):(ROOT/p).write_text(s.strip()+'\n')
def prepend(p,block,marker):
    p=ROOT/p;s=p.read_text()
    if marker in s:return
    h,rest=s.split('\n',1);p.write_text(h+'\n\n'+block.strip()+'\n\n'+rest.lstrip())
put('mission/current.md','''# 当前工作：FFR1残差错误语义、停滞保护与计量修正

[FFR0审核](../results/measurement_first_FFR0_review_20261014.md)接纳AT053正常四行独立gold、双源各256AR/R、4096加法、256 AW/W/B、末B/响应消费和三个64KiB保护终扫，以及AT052同槽52例。两manifest28引用/74证据路径、6串行guard/142policy已核。103350是正常终扫打印点，后续尚有探针，不当整个TB结束或cfg延迟。AT049至Down限定链PASS保持；与残差仍非同runtime。

FFR0合同未闭合：数值错误8应为原E_NUMERICAL6，局部AXI错误9不在枚举；周期进展标记能以停滞计数刷新watchdog；cfg/两端首末AR/R/源锁和目标有效边沿、逐项add延迟与互斥周期缺项。旧正常五条计数实际递增，不把其自然PASS改判死锁。原两轮修正上界已用尽，AT051–053不改写。

当前[D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01](ffn_residual_status_measurement_stage_20261014.md)选择FFR1。保持原叶子/结果槽/独立gold/正常路径与profile，只纠正错误码、真实进展guard和被动计量；数值错误6，合法单拍AXI非OK映射E_INTERNAL8并定向验证。static/短错误回归/≤120s单行pilot及本次成本后至多一次新四行full；full前最多一次有因准备修正。未变52例按SHA复用；新结果NOT_RUN，不启动LN长链。普通步骤自主连续，阶段终态集中审核。

A002唯一实现/工具；代码E002/experiment，证据E005/R001。原CPU0–3/nice19/idle、MemAvailable>192GiB和单重工具/全部帽保持；无新agent/HLS/OOC/P&R/上板，G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。外部两源不代签生产hub lease；完整普通多窗口、Attention/WO上游、28+2层/122矩阵、13BO请求恢复、联合资源/时序及M003/M004开放。''')

p=ROOT/'results/overview.md';s=p.read_text();start=s.index('[FFREF0独立源已接纳]');end=s.index('\n\n| 工作',start)
s=s[:start]+'''[FFR0正常局部结果已核](measurement_first_FFR0_review_20261014.md)：AT053四行独立gold、双源AXI/末B/局部消费与保护终扫成立，合同仍缺错误码一致性、可靠停滞保护和完整计量。下一[FFR1](../mission/ffn_residual_status_measurement_stage_20261014.md)保持算术/数据，只做受影响修正及至多一次新四行full；新结果NOT_RUN。AT049至Down限定链PASS保持，末残差尚未接入同runtime，完整加速器未验收。'''+s[end:]
s=s.replace('| FFR0四行末残差RTL | 新结果NOT_RUN | 单生成加法叶子、双源真实AXI、另一HIDDEN bank与局部保护/退休 |',
'''| FFR0四行末残差RTL | AT053正常数值/事务/保护通过；52例槽通过 | 错误码、停滞guard及计量缺口；合同未闭合 |
| FFR1受影响修正 | 新结果NOT_RUN | 修数值/AXI错误码、真实进展与计量；不启动长链 |''')
p.write_text(s)
block='''## R-SM005-FFR0-20261014：正常局部接纳，错误/guard/计量未闭合

AT053正常4096项独立gold、双源各256AR/R、256 AW/W/B、末B/响应消费及196608B保护终扫通过，AT052同槽52例复用；两manifest28引用/74证据路径、6串行guard/142实际policy已核。原full五条计数递增且自然结束，但数值错误8不符E_NUMERICAL6、AXI错误9不在枚举，周期心跳可刷新语义watchdog，部分精确边沿/加法延迟/互斥周期未记录。工程收据不改写，主控不签FFR0合同全部闭合。

D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01选择FFR1：未改叶子/槽/gold，纠正本地状态6/8、受影响错误回归、真实进展guard及被动计量；static/短回归/单行pilot/有据成本后至多一次新full。原两轮上界收束，新结果NOT_RUN，不跑LN长链；M003/M004开放。

[审核](measurement_first_FFR0_review_20261014.md)；[合同](../mission/ffn_residual_status_measurement_stage_20261014.md)。'''
prepend('results/review_queue.md',block,'R-SM005-FFR0-20261014')
prepend('results/reviews/SM005.md',block.replace('](measurement_first_','](../measurement_first_').replace('](../mission/','](../../mission/'),'R-SM005-FFR0-20261014')
prepend('results/hardware_metrics.md','''[FFR0审核](measurement_first_FFR0_review_20261014.md)：AT053正常4096 F32、各源256单拍AR/R、目的256 AW/W/B、196608B局部终扫。末W103325→末B103340→首成功响应103341→消费103349，正常终扫打印103350，非整个TB终点且cfg延迟未完整测得。static/pilot/full22.174020/26.307417/26.989242s，full峰1376640KiB；6guard/142policy，当前复用槽+AT053为95policy。错误码6/8不符、semantic周期续命反例与加法延迟/互斥周期缺项，不能签完整保护或部署性能。下一FFR1只修受影响边界，物理资源/Fmax UNKNOWN。以下保留历史。''','[FFR0审核]')
prepend('results/hardware_progress.md','''2026-10-14：[FFR0正常局部结果已核](measurement_first_FFR0_review_20261014.md)，AT053真实双源残差数值、写回/局部完成及保护终扫通过，52例槽复用。原错误码不符、停滞标记可续命和未完成计量使合同仍未闭合。下一[FFR1](../mission/ffn_residual_status_measurement_stage_20261014.md)限原算术/数据的错误语义、guard与观察修正，至多一次新full；不直接接LN长链，新结果NOT_RUN，M003/M004开放。以下为历史。''','[FFR0正常局部结果已核]')

p=ROOT/'project/missions/SM005.md';s=p.read_text().replace('revision: 23 / 2026-10-14','revision: 24 / 2026-10-14')
start=s.index('KB1/ATN1/');end=s.index('最终任务仍分两层：',start)
s=s[:start]+'''KB1/ATN1/QAR0/LNF0/LNQI0/LNQ2/FFREF0原限定结果保持，AT049至Down四行同runtime PASS。[FFR0审核](../../results/measurement_first_FFR0_review_20261014.md)接纳AT053正常局部数值/事务/保护与AT052同槽52例；错误码、semantic guard和测量缺口使原合同未全闭合，两轮有因修正已用尽。当前[FFR1](../../mission/ffn_residual_status_measurement_stage_20261014.md)保持原叶子/槽/gold，只修状态码6/8、真实进展和被动计量；static/短错误回归/单行pilot/有据成本后至多一次新full，NOT_RUN。无新HLS/OOC/长链，原资源帽及整体控制停排保持。'''+s[end:]
s=s.replace('当前FFR0四行双源残差RTL按本页最新合同执行','当前FFR1残差错误语义/保护/计量修正按本页最新合同执行');p.write_text(s)

p=ROOT/'NEW_CHAT_START.md';s=p.read_text();start=s.index('先读[测量优先计划]');end=s.index('\n\n根目录',start)
s=s[:start]+'''先读[测量优先计划](mission/hardware_measurement_replan_20261013.md)和[当前任务](mission/current.md)。最新[FFR0审核](results/measurement_first_FFR0_review_20261014.md)保留AT053正常四行独立gold/双源AXI/局部末B退休及196608B保护终扫、AT052同槽52例；28manifest引用/74证据路径、6串行guard/142policy已核。错误码8不符原数值6、AXI9不在枚举，周期标记可续语义watchdog且测量缺项，原合同未全闭合。下一[FFR1](mission/ffn_residual_status_measurement_stage_20261014.md)只修错误语义/guard/观察，保持原生成叶子/槽/gold，单行pilot及有据成本后至多一次新四行full；新结果NOT_RUN，不跑LN长链。AT049至Down限定同runtime PASS保持，AT047 FAIL/AT048 COST_STOP不回写。全部原帽、整体控制停排、M003/M004及全模型/13BO/恢复/生产双lease/物理义务保持。'''+s[end:];p.write_text(s)
put('agent/A001/result.md','''# 项目主控与架构评判：最新交付

execution_state: running
stage: measurement_first_FFR0_scoped_review_FFR1_delivery_pending

[FFR0审核](../../results/measurement_first_FFR0_review_20261014.md)接纳AT053正常四行数值/AXI/局部完成及AT052同槽52例，28manifest引用/74证据路径、6guard/142policy已核。数值/AXI错误码不符原枚举、周期标记可刷新semantic guard及未打印计量仍未闭合；原两轮有因修正收束。正常自然PASS不改判死锁，工程旧收据不改写。

[FFR1合同](../../mission/ffn_residual_status_measurement_stage_20261014.md)限定原叶子/槽/gold的错误语义、真实进展和计量修正；static/短回归/单行pilot/有据成本后至多一次新full，无新HLS/OOC/长链。新结果NOT_RUN，M003/M004及生产/物理缺口开放。

审核与合同待实际送达核验；文件落地不表示已通知。''')
report=dict(execution_state='running',current_task='FFR0正常局部审核完成，错误/guard缺口核实，FFR1送达中',
    stage='28manifest引用/74证据路径、6串行guard/142policy；原合同未全闭合',blocker=None,
    next_step='工程按FFR1受影响修正合同继续；新结果NOT_RUN，不启动长链，M003/M004开放',
    runtime_id=None,thread_id='01a129af-0395-7fd0-95ac-edd54873bd5f')
(OUT/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Updated controller records: SM005 revision 24; FFR1 delivery pending')
