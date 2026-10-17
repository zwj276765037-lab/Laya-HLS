from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
def write(name,text): (ROOT/name).write_text(text.rstrip()+'\n')
def prepend(name,block,marker):
    p=ROOT/name;text=p.read_text()
    if marker in text:return
    first,rest=text.split('\n',1)
    p.write_text(first+'\n\n'+block.strip()+'\n\n'+rest.lstrip())
def replace(name,old,new):
    p=ROOT/name;text=p.read_text()
    if new in text:return
    assert text.count(old)==1,(name,old[:60]);p.write_text(text.replace(old,new))

write('mission/current.md','''# 当前工作：FFR0四行双源末残差RTL

[FFREF0审核](../results/measurement_first_FFREF0_review_20261014.md)接纳AT050 PASS_SCOPED_HOST_REFERENCE。59身份引用/53不同哈希路径、19项manifest、八组逐位比较和原guard/policy已核；原全S128前向捕获skip/Down/enc0末输出，Down四行与AT049实际gold零差，完整末输出与旧独立oracle零差。四行均为正规数，不代表零/次正规边界RTL通过。原AT049限定正常四行LN→Q→Wi→G→Q→Down同runtime PASS、TB375074保持，末残差RTL尚NOT_RUN。

当前[D-M004-FFN-RESIDUAL-RTL-01](ffn_residual_four_row_rtl_stage_20261014.md)选择FFR0。复用旧生成的单个tanh_libm_leaf_fp_add_bits（d1370d29…），保留原RNE/零/次正规规则，使用ap_start/ap_done和有界返回槽；不采用尚无边界证据的Xilinx CE方案，也未判该IP数值失败。AT050两源作为声明外部只读输入，经真实AXI、F32 add和另一HIDDEN bank写回；原BO容量、完整身份来源、局部债务/锁、末B、7拍响应保持/一次消费、三个64KiB保护窗口均须新验。

一个实现及最多两轮有因包装修正；static→同包装52例定向数值/背压→≤120s单行pilot→本次成本准入后四行full。新结果NOT_RUN，不重跑LN长链、不运行新HLS。普通实现和修正连续执行，阶段终态集中审核；外部两源不当作真实producer/生产lease，后继同runtime接回与普通多窗口Q/L另保留义务。

A002唯一实现/工具，代码E002/experiment、证据E005/R001。CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具及原帽不变；无新agent/HLS/OOC/P&R/上板。G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；Attention/WO上游、全28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序及M003/M004开放。''')

p=ROOT/'results/overview.md';s=p.read_text();start=s.index('[LNQ2正常四行链已接纳]');end=s.index('\n\n| 工作',start)
s=s[:start]+'''[FFREF0独立源已接纳](measurement_first_FFREF0_review_20261014.md)：AT050沿原全S128图捕获skip/Down/enc0末输出，八组逐位比较零差，直接闭合AT049 Down gold与原图来源。下一[FFR0](../mission/ffn_residual_four_row_rtl_stage_20261014.md)复用现成HLS位精确加法叶子，做双外部源AXI→末加→另一HIDDEN bank的四行局部RTL；新结果NOT_RUN。AT049正常四行LN→Q→Wi→G→Q→Down同runtime PASS保持，完整加速器仍未验收。'''+s[end:]
s=s.replace('| FFREF0末残差独立源 | 新host结果NOT_RUN | 全S128参考前缀对照Down/enc0输出，具体残差硬件接点设计 |','| FFREF0末残差独立源 | AT050 HOST_REFERENCE PASS，八组逐位比较零差 | 源身份闭合，不能代签残差硬件 |\n| FFR0四行末残差RTL | 新结果NOT_RUN | 单生成加法叶子、双源真实AXI、另一HIDDEN bank与局部保护/退休 |')
p.write_text(s)

block='''## R-SM005-FFREF0-20261014：主机来源接纳，转独立四行残差RTL

AT050 PASS_SCOPED_HOST_REFERENCE：完整S128原数学/请求，skip/Down/enc0末输出身份闭合；八组比较零差，包括AT049实际Down mem解码及旧完整encoder_00_out。59引用/53哈希路径、19manifest、1guard/1policy已核，4.220971s/126976KiB。两XCI仅生成路径/校验和差异、四行全正规数补证已核，不签一般IEEE或CE；历史HLS叶子52例是独立实现证据。

D-M004-FFN-RESIDUAL-RTL-01选择FFR0：复用一个未改生成的tanh_libm_leaf_fp_add_bits（d1370d29…），ap_start/ap_done、有界返回槽；AT050双外部源实际AXI、另一HIDDEN bank实写/末B/响应消费、独立gold与保护终扫。一个候选/两轮有因包装修正，static/52例/单行pilot/本次成本后四行full；无新HLS/长链，新结果NOT_RUN，M003/M004开放。

[审核](measurement_first_FFREF0_review_20261014.md)；[合同](../mission/ffn_residual_four_row_rtl_stage_20261014.md)。'''
prepend('results/review_queue.md',block,'R-SM005-FFREF0-20261014')
prepend('results/reviews/SM005.md',block.replace('](measurement_first_','](../measurement_first_').replace('](../mission/','](../../mission/'),'R-SM005-FFREF0-20261014')
prepend('results/hardware_metrics.md','''[FFREF0审核](measurement_first_FFREF0_review_20261014.md)：AT050仅host，4.220971s/峰126976KiB，最低MemAvailable448582076KiB，1guard/1policy；19manifest、59引用/53哈希路径、8组直接比较零差。skip/Down/末输出完整各524288B、四行各16384B，Down对AT049实际gold零/4096差、末输出对旧完整oracle零/131072差。4096样本均正规，数值边界另验。没有新RTL cycles/Fmax/资源结果；FFR0选择一个旧HLS加法叶子及新有限搬运包装，旧HLS估计不代签本封装物理结果。以下保留历史。''','[FFREF0审核]')
prepend('results/hardware_progress.md','''2026-10-14：[FFREF0独立参考已接纳](measurement_first_FFREF0_review_20261014.md)，AT050完整图与四行skip/Down/末输出直接身份闭合，无新DUT。下一[FFR0](../mission/ffn_residual_four_row_rtl_stage_20261014.md)以声明的双外部源，复用单HLS位精确加法叶子做真实双源AXI/另一HIDDEN bank写回，先52边界例和单行pilot再有据四行full；一个实现/两轮包装修正，不重跑LN长链。新RTL NOT_RUN，M003/M004与生产/物理义务开放。以下为历史。''','[FFREF0独立参考已接纳]')

p=ROOT/'project/missions/SM005.md';s=p.read_text().replace('revision: 22 / 2026-10-14','revision: 23 / 2026-10-14')
start=s.index('KB1/ATN1/');end=s.index('最终任务仍分两层：',start)
s=s[:start]+'''KB1/ATN1/QAR0/LNF0/LNQI0与LNQ2原限定结果保持；AT049正常四行LN→Q→Wi→G→同Q→Down全gold/存储/lease/消费PASS，TB375074，AT047/48失败不回写。[FFREF0已接纳](../../results/measurement_first_FFREF0_review_20261014.md)：AT050完整S128原图独立skip/Down/末输出，八组逐位比较零差，主机范围通过。当前[FFR0](../../mission/ffn_residual_four_row_rtl_stage_20261014.md)复用单个原生成HLS fp_add_bits叶子，双外部源AXI→末加→另一HIDDEN bank局部RTL；static/52例/单行pilot/有据四行full，一个实现及最多两轮包装修正，结果NOT_RUN。原帽、无新HLS/OOC/长链和整体控制停排保持。'''+s[end:]
s=s.replace('当前FFREF0末残差独立源与接点按本页最新合同执行','当前FFR0四行双源残差RTL按本页最新合同执行')
p.write_text(s)

p=ROOT/'NEW_CHAT_START.md';s=p.read_text();start=s.index('先读[测量优先计划]');end=s.index('\n\n根目录',start)
s=s[:start]+'''先读[测量优先计划](mission/hardware_measurement_replan_20261013.md)和[当前任务](mission/current.md)。最新[FFREF0审核](results/measurement_first_FFREF0_review_20261014.md)接纳AT050原S128图末残差来源，59引用/53哈希路径、八组bit比较零差；Down四行与AT049实际gold、enc0完整末输出与旧独立oracle相同。新[FFR0](mission/ffn_residual_four_row_rtl_stage_20261014.md)选择旧HLS独立fp_add_bits生成叶子（d1370d29…），新包装与双外部源AXI/另一HIDDEN bank，52例和单行pilot后有据四行full，一个实现/两轮包装修正。四行全正规不覆盖数值边界；不采用Xilinx CE流水方案，不新跑HLS或LN长链。AT049正常四行LN→Q→Wi→G→Q→Down同runtime PASS/TB375074保持，AT047 FAIL/AT048 COST_STOP不回写；新FFR0 NOT_RUN。原帽、整体控制停排、全模型/请求恢复/生产双lease/物理与M003/M004开放保持。'''+s[end:];p.write_text(s)

write('agent/A001/result.md','''# 项目主控与架构评判：最新交付

execution_state: running
stage: measurement_first_FFREF0_reviewed_FFR0_delivery_pending

[FFREF0审核](../../results/measurement_first_FFREF0_review_20261014.md)接纳AT050 PASS_SCOPED_HOST_REFERENCE，59引用/53不同哈希路径、八组直接逐位比较与guard/policy核验通过。完整图Down与AT049实际gold、末输出与旧独立oracle直接闭合；没有残差RTL结论。

XCI身份/四行位型补证已复核。已选择[FFR0合同](../../mission/ffn_residual_four_row_rtl_stage_20261014.md)：复用原生成HLS位精确加法叶子，双外部源真实AXI/另一HIDDEN bank写回，static/52例/单行pilot/有成本四行full；一个实现/两轮包装修正。无新HLS/OOC/长链，新的RTL NOT_RUN，生产及物理缺口、M003/M004开放。

审核与合同待实际送达核验；文件落地不表示已通知工程。''')
report=dict(execution_state='running',current_task='FFREF0主机来源审核完成，FFR0合同送达核验中',
    stage='59引用/53路径、八组逐位比较、1guard/1policy及加法叶子身份已核',blocker=None,
    next_step='直接送达FFR0单叶子双源残差RTL合同；新结果NOT_RUN，M003/M004开放',
    runtime_id=None,thread_id='01a129af-0395-7fd0-95ac-edd54873bd5f')
(OUT/'controller_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Updated controller records; delivery pending; SM005 revision 23')
