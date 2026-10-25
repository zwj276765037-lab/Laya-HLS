#!/usr/bin/env python3
"""Publish material for the actual bounded E016 delivery; never upgrades full-parent scope."""
from pathlib import Path
import datetime as dt,hashlib,json
ROOT=Path(__file__).resolve().parents[3]
E=ROOT/'project/E016_m007_single_resource_parent';R=E/'experiment_results/runs/R001';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
def rel(p):return str(p.relative_to(ROOT))
def read(p):return json.loads(p.read_text())
now=dt.datetime.now(dt.timezone.utc).isoformat();audit=R/'attempts/AT024_final_version_aware_evidence_audit';a=read(audit/'work/evidence_audit.json');assert a['verdict']=='PASS' and not a['errors']
used={k:0. for k in ['reference','static','rtl','ooc']};attempts=[]
for p in sorted((R/'attempts').glob('*/receipt_*.json')):
 d=read(p);used[d['category']]+=d['wall_s'];attempts.append({'attempt':p.parent.name,'receipt':rel(p),'sha256':sha(p),'category':d['category'],'wall_s':d['wall_s'],'verdict':d['verdict']})
ledger=read(R/'budget_ledger.json');assert used==ledger['used_s'];assert all(used[k]<=ledger['limits_s'][k] for k in used)
dump(R/'ledger_reconciliation.json',{'at':now,'scope':'All24 closed outer attempt receipts, including FAIL/NOT_RUN and AT024 audit charge; nested synthetic guard work charged within outer AT008 only','all_outer_attempts_closed':len(attempts)==24,'used_s':used,'ledger_sha256':sha(R/'budget_ledger.json'),'remaining_s':ledger['remaining_s'],'caps_s':ledger['limits_s'],'attempts':attempts,'old_budget_transferred':False,'no_owned_tool_child_remaining':True})
boundary=read(R/'reports/context_fault_phase_boundary.json');parent=M/'rtl/laya_m007_single_parent_v1.sv';adapter=M/'rtl/laya_m007_context_quant_adapter_v1.sv'
assert sha(parent)==boundary['new_parent_sha256'];old=boundary['old_parent_sha256'];cur=sha(parent)
notrun=['Full16head → actual public layer context → quant/A → WO in one parent runtime (COST_STOP; no attempt/child launched)','Current parent actual context fault → next-generation input/QKV chain','Last QKV write held through top-level legal backpressure (no independent ready control exposed)','Normal successful parent response held (requires full WO)','Decision/bias complete parent numerical chain','Complete original graph Check tuple/identity/first-error semantics','Synthesis, OOC, physical resources/300MHz, CDC, HBM reset, U55C/Host deployment, full FFN/30layer/throughput']
versions={'old_parent_sha256':old,'current_parent_sha256':cur,'adapter_sha256':sha(adapter),'sole_change':boundary['exact_only_difference'],'added_control_bits':0,'old_parent_evidence':{'normal':'AT012 QKV3 and AT013 complete QKV/RoPE/first complete head','fault':'AT015 quant, AT016 late W and AT017 same-edge producer failure, each followed no-reset new-generation QKV3'},'current_parent_evidence':{'build':'AT022 actual current parent hierarchy/control audit and compilation','numerical':'AT023 active common reset, coefficient reload, full new-generation input and QKV3 only','consumer':'AT021 standalone exact production adapter/front/A/DIV; same adapter SHA, public source peer only; parent/layer16 not signed'},'audit':{'attempt':audit.name,'checked_files':a['checked_files'],'checks':len(a['checks']),'mutable_runtime_differences':len(a['mutable_runtime_snapshot_differences']),'inventory_sha256':a['inventory_sha256']},'not_run':notrun,'boundary_report':rel(R/'reports/context_fault_phase_boundary.json')}
dump(R/'current_version_evidence.json',versions)
source=f'''# E016：唯一资源父串联实现与版本边界

M007/SM012，D-M007-SM012-SINGLE-PARENT-11；工程负责人 A010。真实实现位于 forward_controller/rtl/laya_m007_single_parent_v1.sv 与 laya_m007_context_quant_adapter_v1.sv。父包含一份纯 layer、matrix facade、quant/A front、context adapter、原系数 cache 和 attention_resources；FP/PS/storage 与 DIV 分束路由。QKV 始终通过 layer 公开窄写口，context adapter 仅用实际公共响应保持，不复制整张 context。Profile=0。

完整128bit原始 source tags：model6eb6ef58bc4f99bd9db40381604108af、numeric aeb13e7937d29fe6a2c68c407249f294、table b1fdc9ca482c0210982c7245cc50c965、graph f33f7848434b73048f957dcd232e1bd4、layout2d848b5fb78236c795cb1d442f088393、build7209eb09c3f265363cfb274f7790a733。这些是原部署来源身份，当前布局 M007-W576-v1 与每次实际编译 manifest 分开；不是当前 bitstream 身份。tensor_catalog.json 从原 manifest ordinal+1 导出60项，按 kind/layer 选择 QKV/WO key；shape不能替代 tensor 身份。Bias配置检查完整 model/numeric 及 request/gen/epoch/tensor。

共享源只读：FP f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0；DIV8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79；纯 layer c3e80307f5a941c1d599eb579d8bc787021d428ea42453b81d7b80e037c7a9db；resource shell484f94579c1abe80b21e8080f32e52aefb30133b12502d42408556721c4c3a09（仅9个真实DIV输出引出）。完整依赖逐次冻结并由AT024核对。

当前 parent SHA `{cur}`；AT013/15–17 parent SHA `{old}`。唯一改变是 producer_close_success 仅在 CRUN 采用 c_fault，避免上一次 context fault 的空闲粘滞位污染新请求初始 QKV close；producer_failed仍全局有效，无新增寄存器。首head证据不改标当前版本；AT022/23仅补当前版编译及复位/QKV3。实际 context-fault→新generation父链仍未执行。

新增 parent+adapter控制1561bit、按模块取整196B；原保守3550B合计3746B，余350B。452个实际输入源=444显式赋值+8个cache直接驱动。固定算术metadata/共享队列在原物理账保留；这是声明/连接/展开证据，无物理fit结论。地址base/span由可信fixture/未来Host注册提供；RTL检查对齐、span与溢出，不能从任意合法BO地址推断tensor SHA。每次实际原W/输入及公共QKV数据独立逐位比对，但通用Host注册服务尚未实现。

方法与命令、资源限制、参考源见 [protocol.md](../experiment_source/protocol.md)。实验原始证据在R001/attempts，最终版本边界见 [current_version_evidence.json](runs/R001/current_version_evidence.json)。
'''
# Source summary links use the experiment_source directory.
source=source.replace('[protocol.md](../experiment_source/protocol.md)','[protocol.md](protocol.md)').replace('[current_version_evidence.json](runs/R001/current_version_evidence.json)','[current_version_evidence.json](../experiment_results/runs/R001/current_version_evidence.json)')
results=f'''# E016：有界功能交付；完整父链未验收

execution_state: completed
verdict: inconclusive
applicability: 原Encoder0、有界父前缀/首head/故障恢复与独立生产context consumer；精确版本见R001/current_version_evidence.json。

| 范围 | 实际结果 | 版本/边界 |
| --- | --- | --- |
| 唯一资源与控制账 | AT022 build PASS45.051571955s；91947实际展开scope；所需13个服务/模块路径均恰好一份；452输入源；3746B保守控制账 | 当前parent；旧AT00391923scope仅为历史TB展开 |
| 原始身份拒绝与QKV3 | AT006、AT012及当前AT023：六个完整128bit source tag高半部错误、两个跨层tensor key错误均零实际工作；243bit错误响应保持5拍；实际4096输入/量化/A写/ack，768QKV32/24576值 | 持稳已测；各回显字段与完整原graph Check期望值不是本轮全覆盖 |
| 完整QKV→首完整head | AT013 PASS782.969087822s；48块/12288QKV32/393216值，2048RoPE提交，head0 score16384/prob16384/context8192，2048softmax-bank ack；head11038拍≤11648；命令→layer.start56026拍；命令→head末69139拍 | 旧parent；一次真实layer.start；不是16head或parent DONE |
| 量化NaN取消恢复 | AT015 PASS60.229704667s；4096真实输入，0QKV/AR，1PREPcancel+1Acancel，status/raw/domain=1/2/3，显式期望tuple000001000000000011000000；无reset新gen完整输入→QKV3 | 旧parent |
| 晚W故障取消恢复 | AT016 PASS76.090052532s；1真实RRESP错前已256QKV32写，1PREPcancel、0Acancel，status/raw/domain=2/3/4；无reset新genQKV3 | 旧parent；tuple000007000000000000000000为观测值，缺独立精确tuple断言 |
| 同沿producer失败 | AT017 PASS58.860724688s；真实producer_fail_fire与q_done同沿；1实际A取消+1PREPcancel，0QKV/AR，status/raw/domain=3/3/2；tuple123456789abcdef0fedcba98显式核对；无reset新genQKV3 | 旧parent；三类错误响应完整243bit保持5拍 |
| 生产context consumer | AT021 PASS6.426384921s：117组时带真实DIV/quant债取消，118读/响应、45A写/ack、无发布；坏tag18读/17消费、坏响应仅排一次且同沿无续读；无reset后4096读/响应/量化/A写/ack、1发布；末响应保持12拍无早完成 | 实际生产adapter/front/A/DIV+合法public源peer；不能替代实际layer16/父交接 |
| 当前parent共同reset | AT023 PASS53.261602898s：4096真实输入后在FPmul9、FPadd pending及31算术债/PS忙时共同reset3拍；随后40干净周期，系数覆盖失效并真实重写512组；新gen9/epoch10完整输入→QKV3，8364拍、31/13拍被动反馈 | 当前parent；functional peer共同reset。继承generic marker的kind=quant/no_reset=1不解释为整例无reset；HBM物理reset未测 |

AT013使用原独立QKV/RoPE/score/prob/context参考。其首head终点核真实h_done握手与上述数据/周期断言；固定unfinished_parent打印不证明该长例逐拍禁止parent成功，max_checked不是独立终点断言。其wall started_at误写在接近退出处，原文件保留，仅使用单调event差值；后续driver已修正UTC起止字段。

全16head/WO成本门：1.35×(782.969087822+15×119.898432351)+10=3494.951523668s，尚未计context量化/WO，已超过单次1200s与当时扣240s恢复后的2425.271683606s。COST_STOP/NOT_RUN，未创建全16/WO子进程或attempt；不是数值FAIL。不得把独立E012/R004原context文件WO131072值/22129拍拼作真实父整链证据。

严格数值进度guard SHA76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b，RTL停滞120s，仅接收实际比较后全局递增的M007_PARENT_CHECKED；任意日志/文件增长不续命。AT008缩短2s反例验证沉默和重复计数停止、真实递增通过；AT013 checked highwater827392无trigger。AT024审计PASS6.307549500s：3032文件/3764检查；20项xsim_script.tcl/xsimkernel.log运行变化明确登记为可变文件，其余受核冻结项通过。审计数值语义仍以各TB原断言为准。

保留费用：AT001/007编排错误NOT_RUN0s，AT009声明顺序FAIL1.969928092s，AT010依赖NOT_RUN0s，AT019空闲粘滞fault测试观察器FAIL5.424140056s。AT020仅在idle排除合法粘滞fault；活跃意外fault仍断言，未改DUT/gold。最终独立累计reference0/static{used['static']:.9f}/RTL{used['rtl']:.9f}/OOC0s；AT024已计费，AT008内部synthetic工作只计外层static一次。

证据：[最终交付](runs/R001/final_delivery.md)、[版本](runs/R001/current_version_evidence.json)、[预算核对](runs/R001/ledger_reconciliation.json)、[审计](runs/R001/attempts/AT024_final_version_aware_evidence_audit/work/evidence_audit.json)。
'''
status=f'''# E016：有界阶段已交付

execution_state: completed
verdict: inconclusive
applicability: 有界唯一资源父/消费者验证已完成；M007/SM012完整父链与部署目标仍未验收。

A010已关闭AT001–024；无owned工具子进程、锁等待或后台运行。期望gpt-6.1-sol/xhigh；实际model/effort未核实（UNKNOWN），运行任务身份/root/m007_weight_supply_engineering。E012/R004保持冻结，无旧预算转入。

当前parent仅AT022/23编译/共同reset/新generation全输入QKV3签署；旧parent的AT013首head与AT015–17无reset错误恢复保持原SHA。AT021独立生产consumer完整4096组只签公共消费边界。完整16head→context→WO按同runtime成本门COST_STOP/NOT_RUN。

费用reference0/static{used['static']:.9f}/RTL{used['rtl']:.9f}/OOC0s；余额reference180/static{ledger['remaining_s']['static']:.9f}/RTL{ledger['remaining_s']['rtl']:.9f}/OOC0s；上限180/1800/3600/0s。失败与未运行记录和审计本身费用全部保留；预算未重置、未转移。

未执行范围：

'''+''.join('- '+x+'。\n' for x in notrun)+'''
下一步由主控集中审核本有界交付并安排有独立成本支持的后继范围；不原样扩大超时重跑长前缀。没有综合/物理fit/300MHz/U55C/完整图通过结论。
'''
publication={'source':source,'results':results,'status':status,'execution_state':'completed','verdict':'inconclusive','applicability':'Exact old-parent Encoder0 completeQKV/RoPE/first head and three fault recoveries; current-parent active common reset/newgen QKV3; standalone exact production context consumer4096. Full16/WO actual parent COST_STOP/NOT_RUN.','evidence':[rel(R/'current_version_evidence.json'),rel(R/'ledger_reconciliation.json'),rel(audit/'work/evidence_audit.json'),rel(audit/'receipt_static.json'),rel(R/'reports/full_parent_16head_wo_cost_gate.json'),rel(R/'attempts/AT013_complete_qkv_and_first_head/receipt_rtl.json'),rel(R/'attempts/AT021_consumer_partial_badtag_full_recovery/receipt_rtl.json'),rel(R/'attempts/AT023_current_parent_common_reset_recovery/receipt_rtl.json')]}
dump(R/'publication_final.json',publication)
delivery='# E016/R001 有界阶段交付\n\n'+f'更新时间UTC：{now}。负责人A010；SM012 SINGLE-PARENT-11。\n\n'+results.split('\n',1)[1]+'\n'+source.split('\n',1)[1]+'\n'+status.split('\n',1)[1]
delivery=delivery.replace('(protocol.md)','('+str(E/'experiment_source/protocol.md')+')').replace('(../experiment_results/runs/R001/','('+str(R)+'/').replace('(runs/R001/','('+str(R)+'/')
(R/'final_delivery.md').write_text(delivery)
for name,text in [('design.md',source),('results.md',results)]:
 p=M/'source'/name;s=p.read_text();marker='## M007 E016 SINGLE-PARENT-11 current bounded implementation (2026-10-22)';assert s.count(marker)==1;s=s[:s.index(marker)].rstrip()+'\n\n'+marker+'\n\n'+text.split('\n',1)[1].lstrip();s=s.replace('(protocol.md)','('+str(E/'experiment_source/protocol.md')+')').replace('(../experiment_results/runs/R001/','('+str(R)+'/').replace('(runs/R001/','('+str(R)+'/');p.write_text(s)
p=E/'experiment_source/protocol.md';s=p.read_text();mark='## Final bounded boundary and exact version interpretation';s=s.split(mark)[0].rstrip()+'\n\n'+mark+'\n\n'+f'''AT015/16/17 retain old parent SHA {old}. Current parent SHA {cur} differs only in q_producer_close_success context-fault gating (CRUN only). AT022 current source compile/control/hierarchy and AT023 actual active common-reset/new-generation full-input/QKV3 sign the new SHA in that limited scope. Actual previous layer-context fault→next-generation parent recovery is NOT_RUN; the source fix is not declared fully exercised merely because the short reset case passed.

AT021 actual production adapter/quant-A/physical-A/DIV consumer uses original full128 context fixture from E012/R004 AT005. It tests partial debt cancellation, malformed public response tag and4096-group no-reset recovery with the final actual peer response held12 clocks. The peer never fabricates layer16/DONE or parent success. AT019 failure is preserved; AT020 corrects only the observer that rejected legal idle sticky fault. Active unexpected faults remain fatal; all independent references are unchanged.

AT023 intentionally common-resets the production resource fabric and functional transport peer. A generic inherited M007_PARENT_RECOVERY_PASS line says kind=quant/no_reset=1; the actual case includes the documented3-cycle common reset. No-reset claims apply to AT015–17 and AT021, not to the whole AT023 scenario. Physical HBM reset/late external transactions remain NOT_RUN.

AT024 checks3032 files/3764 conditions, retaining20 runtime changes of xsim_script.tcl/xsimkernel.log separately from immutable compiled objects. Audit charge is closed by the outer receipt after the child completes, then independently reconciled in ledger_reconciliation.json. Final delivery_manifest seals audit artifacts, summaries and version boundaries; neither audit nor manifest is a new numerical simulation. Future work must preserve old/new parent boundaries and all FAIL/NOT_RUN charges.
''';p.write_text(s)
state=read(R/'engineering_state_current.json');state.update(execution_state='completed',current_task='E016 bounded sole-resource parent and production-consumer delivery',stage='AT024 final evidence audit PASS; actual bounded validation complete; full16/WO COST_STOP',blocker=None,next_step='Controller centralized review of final_delivery.md; any later full-parent work needs measured bounded-cost support',active_exec_session=None,reported_at=now,normal_functional_boundary='Old-parent AT013 fullQKV/RoPE/first head; current-parent AT023 reset/newgen QKV3 only',current_parent_sha256=cur,actual_model='UNKNOWN',actual_effort='UNKNOWN');state.update(ledger);dump(R/'engineering_state_current.json',state)
keys=('execution_state','current_task','stage','blocker','next_step','runtime_id','thread_id');dump(R/'console_report_current.json',{k:state[k] for k in keys})
p=ROOT/'agent/A010/result.md';p.write_text('''# A010 当前阶段交付

E012/R004保持冻结：原context文件WO131072值/22129拍，AT025审核1981文件；见[冻结交付](../../project/E012_m007_matrix_compute/experiment_results/runs/R004/final_delivery.md)。

E016/R001有界阶段已完成；完整parent仍未验收。旧parent AT013完整QKV/RoPE→首head通过；AT015–17三类真实故障/PREPcancel/无reset新gen QKV3通过。当前parent一行context-fault相位修复后，AT022/23真实编译/活跃共同reset/系数重装/新gen全输入QKV3通过。AT021独立实际consumer4096组通过，不替代实际layer16→parent→WO。

AT024证据审计3032文件/3764检查通过；完整16head/WO成本3494.951524s>1200s cap，COST_STOP/NOT_RUN。新增控制1561bit/196B，总保守3746B。费用与旧/新版精确边界见[最终交付](../../project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)和[版本证据](../../project/E016_m007_single_resource_parent/experiment_results/runs/R001/current_version_evidence.json)。

无owned实验进程；交主控集中审核。期望gpt-6.1-sol/xhigh，实际UNKNOWN；无物理/整链/30layer/板上通过结论。
''')
print('E016_FINAL_BOUNDED_DELIVERY_MATERIAL_WRITTEN')
