# LNQ0有界失败核定，转一次同DUT发布观测修复

R-SM005-LNQ0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNQ0-bounded-failure-handoff-20261014`，对应事件`EV_SM005_LNQ0_AT047_BOUNDED_FAILURE_20261014`。主控只核已有文件、原始日志、冻结身份及生命周期代码，没有运行DUT。

**核定AT047 full为语义FAIL，LNQ0旧候选及两轮修正收束。保留真实执行到LN发布的前缀证据，不接纳后段或完整链。下一[D-M004-LN-QAR-OBSERVATION-01](../mission/ln_qar_observation_repair_stage_20261014.md)选择LNQ1：只修正TB覆盖观察的生命周期时点，保持同DUT/数据/profile，静态核定后按原帽准入至多一次新full；不续开旧阶段的DUT修复额度。新结果NOT_RUN。**

## 原FAIL与可保留事实

原日志真实最后B167215、完成包last168789、PUBLISH marker168898，随后`Fatal: LN publication missed real store/last B`。full工具723.247161s、峰1033732KiB、child0/trigger null；它是TB语义停止，不是guard成本停止，child0不能覆盖Fatal。没有`LNQ0_CHAIN_PASS`、源阶段最终PASS、外部Q实际接受marker、Wi/G/Down或联合终扫。

源码顺序与已到日志相互支持：源阶段在有效时点检查coverage、原完成包字段和成功END响应，再核真实4 AR/256 R、4 AW/256 W/4 B、16384B、4096F32独立gold及本地NORM邻接哨兵，之后获得成功PUBLISH响应。这是已执行的LN前缀；source lease/Q与最终owner释放尚未到达，所以不写成新的LN→Q或完整源生命周期PASS。合并Fatal没有打印published-owner和B计数两个操作数的边沿值，不补签它们。

## 观测错误已定位

冻结联合TB在`while(!ln_published)`之后要求实时`monitor_coverage_complete`。同快照monitor明确`coverage_complete=scope_active && ...`，portal的PUBLISH物理观察明确要求`!monitor_scope_active && monitor_drained`。成功PUBLISH之后该coverage信号已超出有效生命周期，这个操作数足以触发原断言。它不证明后段正确，也不意味着应删除覆盖检查。

正确的测试证据是在原有效采样点（END包已提交、响应尚未消费）保留真实coverage/计数/身份snapshot，发布后检查成功END/PUBLISH及持久published owner，并把时间点与各操作数分别打印。原gold、最后B和保护区检查保留，不修改DUT、接口、源数据或响应profile。这个具体的时间语义错误支持一次TB限定修复；新出现的失败不能自动扩为第二次full或第三轮DUT修正。

## 尝试与证据口径

AT045静态工具通过但存在隐式声明警告，未pilot。AT046将连接移到声明之后；第一次pilot漏FIXTURE，工具child0但实际Fatal，后补参数pilot120.378604s timeout。AT047增加生成LN游标被动观察及runner参数，联合TB、adapter、bridge、W RTL的SHA相对AT046保持；full仍因原联合TB断言失败。旧失败/停止不回写。

AT047 static110.253319s/2978640KiB通过；pilot120.368007s/1033164KiB，child−9/timeout，到row0 pass1 cursor896/cycle24450，仅为真实前缀。主控从semantic_timeline复算速率207.736164cycles/s，工作量预算`(170031+206136×2.5)/rate×1.05=3464.199672s`，确在3600s内；其中历史cycle仅作预算参考，2.5倍未进入阶段减速和5%余量仍是估计，不是完整链已测周期或确定上界。

主控核AT045–047 manifest与AT047收据共863条引用，连同比较用文件共307路径，bytes/SHA全符；AT047286引用/285唯一路径准确。现有8段可读guard相互不交叠，110条实际policy符合原约束，AT047独有3guard/39条。AT043/AT044尝试根当前未见guard/policy材料，策略与工具帽实测保持UNKNOWN，不继承AT047合规性；可只读定位已有材料，不能补造。

AT044原xsim短日志有`LNQ0_ADMISSION_BINDING_PASS`；adapter/W绑定RTL与AT047相符。但TB直接控制source_query_ready/granted、bridge响应/债务和cache_ready，属于adapter叶子定向检查，不能描述为真实hub+quant+Wcache端到端已验证。其原有限逻辑证据保留，联合场景仍待新full。

## 下一阶段与整体边界

LNQ1只动TB观测/runner，至多一次新full。若新冻结观察不改变前缀驱动和计时，可复用AT047真实pilot与已达LN区间作成本依据；新静态编译与启动前成本记录仍需取得。所有新工具保存实际guard/policy，失败依据Fatal/数值/终态判定而非child0。发现新的语义失败、停滞或成本问题即交付集中取舍，不循环加版。

AT040/AT035原独立结果、AT041主机载荷兼容性和AT044有限adapter检查保持原范围。LNQ0后段NORM真实Q读回、完整Wi/G/Down、联合保护区、全部lease/实际消费与整链周期仍NOT_REACHED/UNKNOWN。普通多窗口Q/L、全模型/13BO生产请求/恢复、联合资源/物理时序/上板及M003/M004均未完成；原单owner/资源帽、G仅OOC余额与整体控制停排不变。

证据：[主控核验](measurement_first_LNQ0_review_20261014/verification.json)、[工程停止报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ0_bounded_failure_20261014.md)、[AT047原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/receipt.json)、[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/guard_full/driver.log)、[冻结TB](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/frozen_new/lnq0_chain_tb_v1.sv)、[成本记录](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/full_cost_decision.json)。
