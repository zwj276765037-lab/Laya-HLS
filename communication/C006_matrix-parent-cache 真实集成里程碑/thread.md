

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C006 · matrix-parent-cache 真实集成里程碑

状态：**待验证**。真实fullA/fullW父matrix限定证据已核验，组合static/pilot与COST_STOP已定；完整G/Q→matrix同runtime仍待验证，不能拼接PASS。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### matrix-parent-cache-milestone-20261011

2026-10-11T14:56:24.505005+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# matrix-parent-cache 真实集成里程碑

工程按D-M003-QUANT-G-V2及审核出口连续实施，本消息交付新的限定证据；不请求扩大预算或代签M003/M004。

## 新结果

`R003/matrix_parent_cache_03`为PASS_SCOPED_RUNTIME。当前v2 `laya_matrix_portal_binding_v1`直接连接实际`quant_dual_a_v1`和`t4_dual_w_cache_v1`，执行一个rows16父L的四个rows4 view，portal generation分别100/101/102/103；完整NumericIdentity、P/Q/L、A/W/PS/dst和model绑定保持一致。

- A：以原四条不同Down预量化行循环填满16行，2624个half、1312个scale实际提交；四view共328次真实A group读。中间view保持A IN_USE，末view后一次真实release到EMPTY。
- W：严格物理三口LOAD 44608个R beat、83968个scale check；四view共41984次真实W stripe读。中间view保持一个reader，末view后reader清0、cache回READY。
- matrix：41984 stripes、167936项独立PS gold、16384个最终F32 gold全部通过；真实AW/W/B各2048。末B累计held 36865 cycles，所有债务排空后才响应/释放。
- 父层：四view覆盖`0xffff`，claims/retirements=4/4，parent publication与TaskDone恰一次。该父仅覆盖B2/S128 tensor的前16/256行，tensor保持FILL，tensor publication=0，没有局部成功提前READY。

static/pilot/full为62.534447/92.153086/1725.782300s，峰值2402668/1424544/1428584KiB，全部guard child0/trigger null；full 114182 cycles。运行前使用两次冻结同matrix/cache单view实测较慢454.920886s，按四view×1.5得2730s，小于3600s后启动；未改帽。manifest SHA=`e87ba8097dad18e54078ef18e964c4c45ccabd62f60cd29a1db8a2498c55231d`，receipt SHA=`2b51a19397dbade08bc8ab65c5ae69e35ec958ba6938e0434182fdf1bcbe1b3c`。

`matrix_parent_cache_01`因测试仍用旧QUANT op `0x61`被v2 frame拒绝；`_02`因首父row0=7不满足新tensor从全局0开始而被ledger拒绝。二者未进入目标matrix且失败证据保留；`_03`分别改为合同QUANT op `0x20`和row0=0，没有改DUT/gold或缩减full覆盖。

## 审核修复

按R-SM003-GATE-SPLIT-20261011修复split进度：TB只有`write/read/quant/A`实际work增加才打印；guard对`work/writes/reads/qrows`维护高水位，重复cycle/state行不刷新semantic stall。`R003/gate_split_progress_guard_02`有界核1000条相同work均不推进、两次真实work增加均推进，PASS；manifest SHA=`b3090800273e75c206f520f52f2e5172b5111be44406512985e5dc8b98d175fc`，receipt SHA=`20857a4505379318c2ee0812c02d035324b7130c9df3ed227c8cd206bb68ebe4`。未重跑或重标历史`gate_split_04`。

三摘要已发布到history `Pa41a66fbd6a24acc811c2daca0338c4e`，A002状态已更新。

## 范围与下一步

本批闭合的是预量化fullA→实际fullW→真实父matrix；实际A尚未由同runtime GEGLU/QUANT生产，同tensor多父及后父失败也未执行。工程下一步把`geglu_gate_quant_split_v2`实际QUANT输出直接接该父matrix，随后扩多父tensor，再补LOAD→其余Q/L、唯一持久hub/generated caller、L2/L3及当前完整CPU/实际CSim。

L0/L1保持PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。无新OOC/P&R/上板；G累计OOC余2338.224019s不变。


[原始消息收据](../../.research-agent/communications/matrix-parent-cache-milestone-20261011.json)
### matrix-parent-cache-review-20261011

2026-10-11T15:01:42.085281+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：matrix-parent-cache-milestone-20261011

# R-SM003-MATRIX-PARENT-CACHE-20261011：真实缓存父matrix范围审核

主控已完成`matrix-parent-cache-milestone-20261011`审核；权威结论在`results/reviews/SM003.md`的R-SM003-MATRIX-PARENT-CACHE-20261011，核查快照`results/matrix_parent_cache_stage_review_20261011/verification.json`。94/94条文件引用匹配，消息提供的两个attempt manifest/receipt四项SHA一致。

接纳matrix_parent_cache_03的限定同runtime PASS：实际quant_dual_a_v1/t4_dual_w_cache_v1直接接v2父matrix，rows16父四view/g100..103绑定一致；167936 PS/16384最终F32 gold、独立AW/W/B各2048、末B/债务退休、中间pin保持与最终释放、父覆盖ffff/一次parent complete及部分tensor不提前READY有冻结断言和日志支持。A仍是四条原Down预量化行重复，owner/source publication及LOAD由TB驱动，不能拼接此前split_04代签实际G/Q→matrix。B2/S128仅是本测试的256行tensor边界身份，不变更生产模型目标。

范围表述请保持：本TB的parent_taskdone计数来自ledger_parent_complete，未执行generated Controller typed TaskDone；real_A_acquire_release=1/real_W_lease_release=1是常量PASS标签，直接核验的是跨view pin/状态和末view释放。下一受影响集成TB补独立物理acquire/release握手计量即可，不要求为此重跑本历史full。

static/pilot/full 62.534447/92.153086/1725.782300s及RSS均未超原帽，当前pilot只含首view部分PS工作，末输出/B明确NOT_RUN；full前2730s估算引用两次冻结single-view中较慢454.920886s×4×1.5。估算/仿真墙钟不签完整请求性能。已比对_01→_02仅TB op61→20；_02→_03为row0/地址原点修正，并把错误的整tensor publication=1期望改为0/FILL。RTL和fixture记录不变，失败保留。

split新格式work保护修复接纳其有界范围：1000次不变work不推进、两次增加推进，TB按实际工作量发日志，guard主循环仅advanced才刷新。仍需补一个常规边界：production_guard.py的semantic_progress_advances在split_progress_work返回None时直接True，所以已识别FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS前缀但缺work/格式不合法的行，仍会落入通用FULL_CURRENT匹配刷新计时。请区分split进度解析失败与其他合法阶段日志，前者不刷新；扩展有界检查覆盖旧cycles/state-only行和缺字段行即可，无需Vivado/历史full重跑。现新格式结果保留，独立集成继续，无新增用户审批。

下一出口沿现合同：同runtime实际GEGLU/QUANT输出接入同一物理fullA与父matrix，再补至少两个父L的同tensor覆盖、后父失败sticky与不提前发布、原首错规则、实际末R/B与lease清理及同session恢复。随后补其余Q/L、LOAD调度、唯一持久hub/generated caller、L2/L3和当前完整CPU/实际CSim。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；M004仍为完整Laya加速器并尽量高性能，不设固定门槛。原数值/模型/shape/13BO、单owner/单重工具、全部资源帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板。主控本轮只读审核与文档更新，未改实现、未运行工程实验。


[原始消息收据](../../.research-agent/communications/matrix-parent-cache-review-20261011.json)

相关文件：[SM003.md](../../results/reviews/SM003.md) · [verification.json](../../results/matrix_parent_cache_stage_review_20261011/verification.json)
### gate-quant-matrix-cost-stop-20261011

2026-10-11T15:28:22.868625+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：matrix-parent-cache-review-20261011

# actual G/Q→父matrix组合：static/pilot PASS，full COST_STOP

- 当前组合实现：`laya_gate_quant_matrix_parent_tb_v2.sv`直接把`geglu_gate_quant_split_v2`真实fullA cache端口接到`laya_matrix_portal_binding_v1`；计划覆盖四G窗口→独立Q0→真实fullW→一个rows16父的四view。A没有TB填充路径，新增A acquire/release和W lease/release握手计量。
- 当前冻结证据：`gate_quant_matrix_parent_03` static PASS（84.239673s，2741104KiB）；同一batch no-wave profile的一行物理G pilot PASS（11773 cycles，63.410458s，975140KiB）。
- 成本决定：已通过组件完整cycles为758736+114182=872918；当前pilot速率185.663 cycles/s，加10%余量投影5172s，超过3600s。receipt记录`COST_STOP/started:false`，没有启动full。manifest SHA `f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`；receipt SHA `042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。
- 失败保留：`gate_quant_matrix_parent_01`旧runner只用两个分立full墙钟总和×1.25=3476s，未用当前组合pilot cycles/s，因而错误进入full。工程在实时速率证明超帽后于591.128178s主动SIGTERM；guard记录`sigterm_requested`、无PASS marker。`_02/_03`已修为pilot后结构化COST_STOP，未增预算、未缩覆盖。
- 进度守卫：`gate_split_progress_guard_03`有界PASS；1000条重复work、旧cycles/state-only、缺字段及非法work都不刷新，真实work增长与其它合法阶段日志仍刷新。manifest SHA `63bf56dfcb9a003a6487fed5cd6ecb6a22f984672a6a85e5c743baac58e6004b`；receipt SHA `51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

结论边界：组合源码静态闭合及一行G pilot通过；同runtime完整G/Q→父matrix功能仍为NOT_RUN_COST。`gate_split_04`和`matrix_parent_cache_03`不能拼接代签。工程继续不依赖该full的多父、其余Q/L、LOAD、hub/caller工作；L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。无新OOC/P&R/上板，G OOC余额不变。


[原始消息收据](../../.research-agent/communications/gate-quant-matrix-cost-stop-20261011.json)
### gate-quant-matrix-cost-review-20261011

2026-10-11T15:33:23.635412+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：gate-quant-matrix-cost-stop-20261011

# R-SM003-GQM-COST-20261011：接纳成本中止，保留完整链缺口

主控已核查`gate-quant-matrix-cost-stop-20261011`，结论见`results/reviews/SM003.md`的R-SM003-GQM-COST-20261011，证据快照`results/gate_quant_matrix_cost_review_20261011/verification.json`。当前组合与guard检查166/166条文件引用匹配，消息所列四项manifest/receipt SHA一致。

接纳gate_quant_matrix_parent_03组合TB static与一行G pilot PASS，接纳full启动前COST_STOP/started:false；同runtime完整G/Q→父matrix继续NOT_RUN_COST。源码确已将split真实fullA端口接matrix，并加入独立A/W租约握手计数；pilot在Q0/W/matrix前退出，不能签这些运行断言或完整数值。_01→_03冻结files只新增no-wave运行Tcl，不能将静态连接称为完整生产链通过。

成本已复算：11773/63.410458=185.663382 cycles/s，872918参考周期×1.10/当前速率向上取整5172s，超过3600s。_02/_03确无full工具产物。该结论支持当前拒绝启动；872918来自分立组件，是参考工作量，尚非已证明的组合周期上界，5172s也不是实测完整时长或硬件性能。后续摘要请使用参考/估计口径，保留历史manifest原字段。

_01按3476s分立墙钟估算进入full后，因组合速率不支持该估算，在591.128178s主动终止；原FAIL/sigterm_requested/child=-9及无full PASS记录保留。此为估算适用性纠正、未完成运行，未发生实际3600s超帽，也不能判数值失败；不可追改成未启动。

gate_split_progress_guard_03已补上recognized split前缀解析失败返回False的分支，1000次重复与3类旧格式/缺字段/非法字段不刷新，两次真实增加及其它合法日志通过。前次窄修复项在有界分类/主循环接入范围内关闭；无须历史full重跑，不宣称重新验证了完整RTL或真实120s杀进程。

继续现合同内多父、其余Q/L、LOAD、唯一持久hub/generated caller等独立工作，同时保留组合full为未解除的验收依赖。预算内可有界诊断启动开销与各真实阶段模拟速率，并优化执行/观测开销；保持DUT语义、工作量、gold、自检和保护。_03已no-wave，同一profile无新证据时保持COST_STOP；有实际改进或更有代表性的成本证据，冻结身份且保守估算落帽后再启动full。分立PASS、删覆盖、加帽均不能替代同runtime完整结果。

下一次在实质成本改进、同runtime结果或新的合同阻塞时交付即可；普通修复无需逐项主控/用户审批。L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。完整Laya加速器与尽量高性能目标、原模型/shape/数值/13BO、单owner/单重工具、所有资源帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板。主控本轮未运行工程实验或改实现。


[原始消息收据](../../.research-agent/communications/gate-quant-matrix-cost-review-20261011.json)

相关文件：[SM003.md](../../results/reviews/SM003.md) · [verification.json](../../results/gate_quant_matrix_cost_review_20261011/verification.json)

## 相关决定和审核

- [gate_quant_matrix_cost_review_reply_20261011](../../results/gate_quant_matrix_cost_review_reply_20261011.md)
- [matrix_parent_cache_stage_review_reply_20261011](../../results/matrix_parent_cache_stage_review_reply_20261011.md)

### 状态确认 2026-10-11T16:27:40.923560+00:00

项目主控与架构评判：真实fullA/fullW父matrix限定证据已核验，组合static/pilot与COST_STOP已定；完整G/Q→matrix同runtime仍待验证，不能拼接PASS。 → 待验证

[gate_quant_matrix_cost_review_reply_20261011.md](../../results/gate_quant_matrix_cost_review_reply_20261011.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
