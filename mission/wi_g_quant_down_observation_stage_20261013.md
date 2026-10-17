# WIGQD1：同一冻结接链的真实进度诊断

D-M004-WIGQD-OBSERVATION-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合和重工具owner，A001集中审核。承接[WIGQD0停止审核](../results/measurement_first_WIGQD0_review_20261013.md)。这是基于明确观测缺口的新诊断任务，旧D-M004-WIGQD-INTEGRATION-01的一次实现及两轮修复已结束，不重置旧额度。普通准备与本次运行直接按既有用户授权执行。

## 需要区分的问题

AT031在G命令接受与整段G/量化完成之间缺少真实进度标记，不能区分“仍在推进但观察器未报告”和“读取/行屏障/算术/写入/量化确实不推进”。本次唯一目标是补足这段可观测性：若同一DUT能自然完成，则按原合同验收完整链；若仍停止，则交付最近真实事务、等待条件和债务所在边界。不得预设观察器是唯一根因。

选择同runtime完整前缀，因为待区分的是真实Wi生产后、同A/W与引擎复用的交接。没有已核可恢复的仿真checkpoint，本次不另造恢复流程，也不用中间tensor预装或层级赋值跳过Wi。独立reader小测试不能替代这条同runtime证据，不另开平行实验。

## 冻结边界与允许改动

从AT031的完整冻结闭包派生新attempt，只改TB观察、诊断计数/断言及必要runner导出。全部DUT、生成IP、完整数据/gold、B1/S128/batch0/row0四行、原实体数量/容量、所有握手驱动和外部响应策略、初始reset及epoch切换均保持。DUT实例/连接、内存读写行为、调度、ready/valid、时钟和延迟都不能借观察修改；没有新的算术或控制候选。

manifest逐项核对AT031：硬件及fixture SHA不变；TB差异须能逐段解释为观察，不修改原自检、循环上界或驱动时序。runner仅允许运行身份、日志/汇总输出及新观察文件引用的变化。保持原production_guard本身及其识别规则不变。

## 真实进展和诊断快照

以实际接受边沿建立有界、单调计数，至少覆盖：

1. G合法命令及Wi reader配置真实接受/拒绝；reader首个及后续实际AR/R；送入G的标量及四次row_done/真实读债归零。
2. G运算真实issue/return/commit或既有等价完成事件；GATE实际AW/W/B，包括首末事件和逐行完成；不能仅凭state反复变化认定推进。
3. 量化真实AR/R、q/scale提交、行finish及唯一dualA的新epoch实际发布；随后Down W加载、PS/写回及一次真实完成消费继承原有效观察。

首事件、真实行边界及适当稀疏计数阈值打印原guard可识别的MATRIX_PROGRESS。例如R每32/64次、Wi标量每256/512次、G issue/return及GATE B按有界批次；工程依据有限实际服务长度选取，不逐周期打印、不以墙钟或循环迭代代替事务。每条包含stage、cycle、事务种类及递增计数，并有有限工作量/重复消费断言，防止无效重复被当进展。计数前后NBA口径统一，精确事件不能用晚观察值代替。

另外建立少量**不计入语义进展**的诊断快照：G接纳前后、reader配置后，以及等待区间固定的有限采样点。记录reader/row-adapter/bridge/quant状态，cfg/AR/R/scalar/row_done各valid/ready，实际累计计数、held-beat/读债、G待返回工作、GATE待B、A槽state/epoch/lease和当前选择。这些字段只读取，不改变DUT。

原guard正则还匹配Complete/completed/Finished/Start等普通词。准备阶段必须用**冻结正则**对所有诊断模板与代表性展开行检查：无真实事务推进的快照不能匹配该正则。不能只换一个日志前缀就宣称隔离。必要日志刷新只保证输出落盘，不更新进展计时。若时钟/事件调度本身不再推进，也保留最后可得快照，由原120s保护器停止，不靠心跳续命。

## 有界执行与出口

先完成观察差异核查与静态编译，再≤120s原真实W前缀pilot；如实说明pilot未到G。准备阶段发现纯观察语法或导出错误可按授权修正，保留失败，不能因此新增DUT修复额度。进入full前一次性冻结观察与成本估计。

**本任务仅允许一次新的full运行。** 成本估计使用AT031实际到Wi/G交界的成本、既有AT025尾段相关成本和本次pilot，含保守余量；既有2505.285s仅旧估计，不能未经核对复制成新保证。若估计不能落入原3600s则记录COST_STOP，不启动。full从原初始reset开始、同进程自然执行到原最终自检；不为诊断提前制造中间状态，不重复跑已无新证据的前缀。

static24GiB/1800s、pilot≤120s、RTL8GiB/3600s/40Mcycles、真实语义停滞120s全部保持。full若FAIL/COST_STOP，交付真实停止类别、最近事件/计数/状态及可区分的等待条件后结束本任务；不自行改DUT、不在本合同追加第二full，不把有标记的推进等同全部功能通过。若只够定位到某个边界，根因保持未定，不扩大证据结论。

若full完成，必须满足原完整Wi→真实DDR/reader→G→GATE写读→量化→同dualA→同resident Down全部独立gold、最后B/发布/lease/真实消费、DDR有效区及保护字节最终读回，并给出本次实际全链周期。原单引擎/原容量/无链间reset不变；不将旧WI0和GQD0相加代签。Wi valid-region读回的旧有限通过仍独立保留，不能预签本次最终canary。

交付新manifest、观察diff、guard正则检查、原日志/收据、事件表及简明因果边界；更新工程三摘要/A002实际状态并直接回主控。成功或有信息的停止都可以完成本诊断任务，只有前者满足原整链验收才可记有限链PASS。

## 不变约束

唯一实现E002/experiment、新证据E005/R001；A002单owner，不新增agent，不写历史baseline。全项目单重工具，CPU0–3/nice19/idle I/O，MemAvailable>192GiB；主控不运行DUT。无新HLS/OOC/P&R/上板或预算；G2338.224019s只原OOC余额，5172s不重启。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup停排。完整28+2层/122矩阵、13BO/请求/恢复/联合资源/物理时序及M003/M004仍未验。
