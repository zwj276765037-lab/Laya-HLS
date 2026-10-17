# LNQ1：修正发布后覆盖观测，一次同DUT联合验证

D-M004-LN-QAR-OBSERVATION-01；2026-10-14；M004/SM005/E005/R001。接续[LNQ0有界失败审核](../results/measurement_first_LNQ0_review_20261014.md)。A002唯一实现/工具owner，A001集中判定。旧LNQ0的一个候选/两轮修正已结束，AT047仍为FAIL；本次是针对已定位TB时间语义错误的新有界观察任务，不恢复旧阶段的修正额度。工程按既有授权直接执行，无需用户转发或逐次审批。

## 选择依据

AT047已执行四行真实LN读/写、4096F32独立gold和局部保护检查，最后B167215、完成包168789、成功PUBLISH响应后marker168898。联合TB随后要求实时`monitor_coverage_complete`，但原monitor定义它为`scope_active && ...`，原portal的PUBLISH观察条件要求`!monitor_scope_active`。该操作数在发布后为假是确定的生命周期语义，不是已证的LN数值错误或DUT死锁。合并断言未打印另两个操作数，不能因此预签published owner状态；Q/Wi/G/Down未到达。

## 唯一允许的修改

从AT047冻结快照派生新AT，仅修改`laya_lnq0_source_stage_v1.sv`与`lnq0_chain_tb_v1.sv`中的验证观察、必要的测试入口/runner和证据输出。保持LN生成物83项、producer/monitor/hub、external admission adapter、bridge、W binding及其package、quant/dualA/resident/strict W/writer全部DUT SHA不变；实际BO映射、输入/独立gold、reset/clock、命令顺序、AXI响应/反压和原数值/错误检查保持。source_stage虽然有测试驱动，只准加入被动证据，不修改驱动行为或额外等待来改变profile。

1. 在原`if(!monitor_coverage_complete)`的有效采样点锁存本任务的coverage witness。该点是END包已提交、END响应尚未消费，不能误写为“END之前”。保留原实时检查；snapshot必须来自当时真实scope/coverage、状态/字节/计数和完整任务/Ref/窗口，而非由后来的`ln_published`倒推为真。随后原完成包字段、计数、gold和保护字节检查全部保持；可另记这些检查已实际执行的被动标记。
2. 发布后改为核本任务已捕获的覆盖证据、成功END/PUBLISH响应、原真实最后B/计数，以及当前应持久存在的published owner/完整身份。在稳定采样边沿检查scope已关闭/物理drained等正确状态；不用发布后已经失效的实时coverage信号替代历史证据。不得删掉“覆盖足够、数据正确、最后B已退休才发布”的义务，不强置内部状态，不新增任何发布/READY权威。
3. 合并断言拆成可定位的观察项，输出真实采样时间、coverage/scope/drained/status、计数、END/PUBLISH响应与published owner值；声明snapshot在哪一任务上下文有效，并在reset/新任务时失效。诊断打印不改变DUT输入、不增加逻辑时钟延迟；普通快照不加入guard进展正则。

发布判断通过后沿AT047原有后段路径运行，保留其全部新边界定向检查、真实NORM读回/原子query-grant/响应保持/drained release、高水位重放、W错配拒绝及完整LN/Q/Wi/G/Q/Down gold、存储保护、末B/lease/实际完成消费。不得为了使这一次full通过而再修改未运行后段的断言/接口/DUT。发现新的语义FAIL、挂起或成本停止就保存原始证据交付，本任务不追加修复或第二full。

## 执行、成本与停止

先做新冻结源码diff、观察覆盖检查与静态编译，证明修改限于上述TB观测及runner。原始AT047的pilot已是同DUT、同输入/profile的真实120s前缀；若静态核定新观察在其前缀内仅被动、不改变驱动/计时，可复用该pilot及原full已达LN区间作成本依据，不为同一前缀重复支付一次120s。若存在不能说明的profile变化，不能称同DUT观测修复并继续full，应交付差异。

**只准入一次新的四行full。** 启动前冻结成本记录：原估计3464.199672s可复算，但仍是基于实测前缀和未进入阶段2.5倍减速预算的估计，不是上界保证。可用AT047已测723.247161s/168898周期前缀校核，保留未运行后段预算；不得以失败前缀已完成就忽略全冷重复成本，也不得相加旧独立墙钟冒充联合测量。新估计不满足原3600s帽或缺少可信依据则不启动full，记COST_NOT_ADMITTED。

static仍24GiB/1800s，RTL8GiB/3600s/40Mcycles、真实语义停滞120s。使用实际guard；CPU0–3/nice19/idle I/O、MemAvailable>192GiB，全项目单重工具。已有真实语义marker保留，周期心跳/固定状态快照不能续命。任何Fatal、缺失最终链PASS或终态计数错误均FAIL/未达，即使xsim/guard child0也不当通过。若新full正常通过，必须再核原独立gold、有效/保护区、lease/debt、实际响应消费和精确计量边界才交付；这里只是有限四行normal，不是生产请求或全模型。

AT043/AT044当前尝试目录未见guard/policy记录。工程可只读补定位已有真实启动/采样证据；确实没有则写UNKNOWN，不补造或借用AT047样本，不要求为此重跑AT044。其短测试只是TB控制hub/bridge/cache响应的adapter叶子检查，不代签真正端点互连。本次所有工具必须保存实际guard/命令/policy和工具身份。

代码只在E002/experiment，证据E005/R001新AT；旧AT042–047及冻结文件/日志/收据保持，源manifest的NOT_RUN仅是冻结时点，不覆盖receipt实际终态。交付新旧SHA/diff、观察采样解释、原始日志/guard/成本、三摘要和有限结论。不新增agent、不撤销他人修改。无新HLS/OOC/P&R/上板/算术候选/缓存扩容；不增加工具帽或重置累计OOC预算。G2338.224019s仅OOC余额、5172s不重启，整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；普通多窗口Q/L、全模型/生产请求/恢复/联合资源和时序及M003/M004仍开放。
