# FFN1：真实进展覆盖、补充短测与一次有界回放

D-M004-FFN-PROGRESS-REPLAY-01；2026-10-14；M004/SM005/E005/R001。接续[FFN0停止审核](../results/measurement_first_FFN0_review_20261014.md)。A002唯一实现/工具，A001集中验收。按既有授权连续执行本合同内的普通准备、测试和准入，无逐步审批。新FFN1 NOT_RUN。

## 固定实现与变更边界

AT057因观测未包含真实Wi W R而守卫停止，不是DUT终态。保持其所有功能RTL与生成核、LN ROM、FADD叶子/返回槽、Down→residual适配器、QAR0仲裁、BO/Ref映射、fixture/gold、任务/模型/请求/profile及正常TB驱动/反压/存储响应不变。尤其保留TMP逻辑bank0/epoch1、STATE1 TMP实际store/重读、单skip数组和另一HIDDEN目标，不能为通过观察器改变功能时序、预装中间值或从断点续跑。

本阶段只允许：被动进展/计量观察及必要打印；guard/parser与启动封装；独立观察器微测试；补齐原合同短适配器/残差descriptor负例的测试台。可提取非综合观察器公共模块，使联合TB与微测试复用同一冻结观察逻辑；不能增加功能队列/缓存或改ready/valid。所有功能DUT按AT057逐SHA保持，正常联合TB允许区域给精确diff，驱动/response/断言区域逐项保持。新增原义务断言可以加强，不能删除或弱化旧gold/保护/错误检查。

若补测发现真实DUT缺陷或需要改变功能接线、identity/数值、guard帽或响应策略，保留反例、停止本回放准入并集中交付；本合同不授权夹带第三个功能修正版。原AT055/056/057全部证据保留，AT056 Fatal/AT057 COST_STOP不改写。

## 整条链的进展事件

在编译前建立一张“阶段→真实信号/握手条件→累计计数→打印字段→parser接受条件”表。每项点名当前冻结信号和采样边沿。必须覆盖当前已有链的所有可能长计算/传输阶段，至少包括：

| 阶段 | 必须纳入的真实进展 |
| --- | --- |
| LN与来源门户 | 源AR/R、已绑定生成核真实迭代/行退休、AW/W/B、END/PUBLISH实际接受/响应消费 |
| 外部Q和GATE-Q | 各自真实AR/R、量化真实提交/返回、fullA提交/发布、响应消费及source release实际退休 |
| Wi/Down两次W加载 | **q0、q1、scale三端口分别的AR/R握手**；AUX读取/实际load完成，不能依赖q0变化替代另两路 |
| matrix运行 | A/W读接受与实际返回、PS/stripe真实提交、writer AW/W/B、owner退休与done实际消费 |
| Wi reader/G | reader AR/R/实际元素消费、G真实issue/return/emit、GATE AW/W/B；算术长段不能仅等尾部读或写 |
| Down→残差 | 实际适配器cfg/退休交接、两源AR/R、add接受/返回/槽消费、目的AW/W/B、响应实际消费和最终有限扫描完成 |

普通状态VALID、ready低、循环等待、cycle变化、重复snapshot或打印时间本身不算进展。目的发布等一次事件须绑定真实状态转换且只计一次；最终扫描完成不能周期性重复续命。没有外部握手的长算术段须有已说明因果关系的实际算术迭代退休，不能把任意FSM抖动当工作。

采用不回退/不绕回的累计事件计数，跨Wi/Down、两次Q及测试探针不能因局部计数归零再上涨而虚构进展。可以按真实握手脉冲直接累计，也可按已绑定的真实受理事务维护分项计数；若分项复用必须证明只有实际新命令能更换键，不能仅换文本或阶段号刷新。未知键/非法下降明确失败。总work可作为打印压缩，但附各关键family的计数以供事后审计，不允许总和掩盖非法分项回退。

guard保持SIM_START唯一转换，重复start不续命并拒绝；进入模拟后不再采用无约束编译文本规则。仅接受规定schema的严格新进展；重复/周期/普通completed/MATRIX_PROGRESS文本不续命。不要通过直接把所有MATRIX_PROGRESS行加入正则修补此次遗漏。打印节流须结合本次实测速率，确保正常事件能在120s内可见；没有新事件时仍会在120s停止，不得增大该帽。

## 启动full前的验证

1. **host逻辑时间测试**：复用实际parser/计时决策代码，保存输入事件、逻辑时刻、接受/拒绝和超时判定。至少覆盖首次R后无新事件但cycle/重复日志不停；相同work/重复start/普通completed；非法回退/未知键；真正单端口q0-only、q1-only、scale-only增长；在小于120s时真实推进会更新计时、其后静默满120s应停止。检查120s阈值前后及与生产比较符一致的边界。不实际等120s，不以host测试代签RTL，不把几条parser断言称为逻辑时间验证。
2. **同一观察器微测试**：短RTL或等价可审计观察逻辑测试，逐个激活表内关键事件（其余保持静止），包括仅W q0/q1/scale R、后段G算术、残差add与B、done/release真实消费。证明输出的累计字段由输入事件产生，再送实际parser/逻辑时间测试；重复valid但ready低不得计数。三个W端口同时握手不得少计或覆盖。另用AT057原52条W日志构造只读回放对照，记录旧观察遗漏与新规则预期，不伪造新的DUT样本或旧日志时间戳。静态连接表须核联合TB实际接了这些信号，微测试不代替真实连线。
3. **补齐FFN0短测缺口**：同SHA适配器，独立冷短用例允许各自reset；正常full仍只有初始reset。验证失败done、未绑定的旧/Wi completion、done_valid保持7拍但ready低、缺最后B/owner退休/READY/债务未零分别阻止残差；保留正确合法对照和唯一消费。坏TMP bank1/epoch2以及错最终目的在实际受影响的descriptor入口拒绝，零新增残差AXI；区分适配器输入和固定输出，不force其输出伪造用例。已有坏BO/Context/ledger忙/重复ticket/响应保持用例按同SHA可复用，但新TB覆盖必须实际运行。记录具体case/边沿/零副作用，不以一个总PASS替代未执行列表。
4. static编译与上述短测合格后，执行≤120s新联合真实LN源读/迭代前缀，确认新观察与原数据/驱动同源。前缀不必到在120s内不可达的W段；该段的观测接线/微测试/原W实读证据分别列明，不能声称prefix已实际验证W或后段。

已有同SHA算术/独立reference、52例FADD与AT054未受影响局部错误证据直接复用，无需新HLS或重跑参考。新短测试只为本合同缺口，不扩大全局取消/恢复矩阵。

## 运行包与重新准入

每次spawn前核完整冻结清单、真实cwd和xsim产物、7份ROM目标SHA、实际全部fixture/plusargs。显式验证FIXTURE=LN_FIXTURE别名，不能只核抽象roots却漏实际命令。保持正例和缺文件/错SHA的spawn前拒绝；host无RSS/policy样本时如实记UNKNOWN。生成IP若仅路径造成身份变化，保存实际闭包及参数比较，不伪称文件SHA未变。

重新记录时间、RSS和cycle工作量估计，使用本次prefix/观察开销与AT057已达阶段的真实数据，未见后段给有据保守成本。旧AT049/AT054仅可作注明身份/口径的结构性工作量参考，不能直接相加作新链周期；AT057的500000cycle/3536.346s不自动继承为确定上界。分别说明固定开销、各未见阶段及余量。新准入决定必须先于实际full spawn，估计可信落入3600s/8GiB/40Mcycles才运行；否则COST_NOT_ADMITTED并交付，不加帽、跳过前缀或把硬超时当准入。

一个被动观察修复方案，full前最多一次有因准备/观察/测试脚本纠正，无DUT修正额度。**本阶段最多一次新的冷四行full**，完整复走LN→Q→Wi→G→Q→Down→残差，不使用AT057中途snapshot/预加载A/W计算结果或修改profile。full失败、semantic/cost停止或达修正上界即集中交付，不追加第二次或换AT编号继续。

## 成功出口与保留范围

通过必须取得[FFN0原合同](ffn_single_runtime_stage_20261014.md)全部正常独立gold、同skip/刚写TMP重读、真实DUT退休门控、完整Ref/模型/任务归属、末B/lease/返回排空、七拍响应与一次消费、655360B本地保护以及实际整链周期/互斥阶段和加法分布。新观察计数与独立TB事务/实际日志交叉核对。仅新guard短测或过原停止点不算整链PASS，child0不覆盖Fatal/错误终态；资源/物理时序仍UNKNOWN。

代码只在E002/experiment，证据E005/R001新AT，工程更新模块design/results、E005三摘要/A002真实状态，直接交付精确变更表、所有guard/原日志/manifest、缺口/成本和实测范围。A002单工具owner，全项目单重工具，CPU0–3/nice19/idle、MemAvailable>192GiB；host≤8GiB/120s，static≤24GiB/1800s，RTL≤8GiB/3600s/40Mcycles，pilot及真实semantic stall120s。无新agent/HLS/OOC/P&R/上板；G2338.224019s只为OOC余额，5172s组合不重启。

普通Q/L生产控制、整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup保持停排。外部attention residual不代签上游Attention/WO，局部TMP保留不代签生产双源query/lease；全模型/13BO/恢复、普通多窗口、联合资源/时序和M003/M004继续开放。
