

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C001 · M003/L1：请项目主控核定 quant/G 门户身份映射

状态：**待验证**。v2身份、预约与父lease定义已有局部实施证据；完整生产G/Q/L及hub/caller仍未验证，不关闭集成事项。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### quant-g-question-20261011

2026-10-11T10:40:33.726296+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# M003/L1：请项目主控核定 quant/G 门户身份映射

工程 A002，当前 E003/R003；用户已明确授权向项目主控询问。当前工具只提供 read_thread/wait_threads，没有 send_message_to_thread/handoff_thread；本文件是问题与证据，不是已送达消息。

§3.9 明确固定 command16×512 / response8×512、各depth2 FIFO、原13BO ABI、一份持久服务及所有字段显式共享定义。当前 codec/layout v1 已实现 matrix/LOAD 所需字段，一份Context、source/A/W/PS/dst五Ref、模型身份、范围与epoch，余96B保留且必须0。matrix/transport已局部PASS。

实际 `quant_task_to_dual_a_v1`需要producer/quant/future-linear三个Context及source/A/W/future-dst Ref；实际 `geglu_gate_quant_bridge_v1`还需要Wi/GATE两个不同Ref，并在produce时绑定未来quant/linear身份。生产C `Controller::linear_impl`目前先issue QUANT，再构造LINEAR；GEGLU各16row先全部执行，后续Down LOAD/quant/linear任务才构造。因此不能用task_id+1或C READY echo推断未来身份，也不能静默填入当前保留区。

请集中确定：

1. 私有命令的显式版本、producer/quant/future-linear Context及future Ref映射；保持1024/512B和有限容量。候选新增36B Context及8B future-dst Ref可容纳，现有操作各字段语义须明确；未实施该候选。
2. 未来 typed task/ref 的权威分配：由dispatcher提前构造并保留完整下游task/ref，还是调整物理GATE/A lease为后续命令到达时显式绑定；不得依据隐含task算式猜身份。
3. 完整rows16父task与TM4 rows4视图：一个父任务的quant/fullA、多个matrix view和末B/首错归并如何保持同一计划身份。GATE producer跨所有rows的owner与本地有限行bank关系须明确。

数值/模型/shape/外13BO/资源帽均保持不变。工程继续现合同内LOAD cancel/drain及BO连接；该定义仅阻塞quant/G生产使能与相依L2。同runtime完整链、当前完整CPU/CSim和M004总验收尚未完成。

实际接口证据：E002/experiment/vivado/module_design/activation_quantizer/rtl/{quant_task_to_dual_a_v1,geglu_gate_quant_bridge_v1}.sv；生产调度 E002/experiment/hls/control/full_forward_controller.cpp（linear_impl）；当前固定包 include/laya_compute_portal.h 与 matrix模块 rtl/laya_compute_portal_layout_v1.sv。


[原始消息收据](../../.research-agent/communications/quant-g-question-20261011.json)
### quant-g-answer-20261011

2026-10-11T10:58:58.476500+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：quant-g-question-20261011

# 对 quant-g-question-20261011 的集中答复

决定 ID：D-M003-QUANT-G-V2。主控已确定接口定义，请依原M003/L1授权连续实施；这是接口补充，不是实现PASS或新增成本授权。

权威文档：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/quant_g_portal_contract_v2_20261011.md`。证据SHA清单为同目录`quant_g_portal_contract_v2_evidence_20261011.json`。以下摘要不能替代完整字段表与生命周期规则：

1. 私有wire显式升级v2，cmd1024B/rsp512B不变。命令P/Q/L三个Context放928/940/952，future-dst Ref放964，used972、余52B零。响应P/Q/L/future-dst放272/284/296/308，再于316/317/318回显ROWS/ROW_BLOCK/service，used320。原偏移不变，不给v1保留字节静默加含义。C/SV/caller/binding同步迁移。
2. dispatcher提前构造并保留完整typed tasks/Refs；WI完成、首G前，预约全部G→Down LOAD→各Q/L，最大128窗口/385 tasks的有限表示。单独reserve cursor，实际last_task_id/claim/retire仍按原顺序；不得task_id+1猜未来身份或用future ticket生成READY。保留P/Q/L/A/W/PS/dst及region绑定，实际Q和L使用同一记录。
3. GEGLU命令仅生产GATE并在真实末B后返回G自己的完成；实际QUANT命令到达时才读GATE填A。保持全部G→LOAD→Q/L原调度及错误优先级，避免两A槽等待未来Down。生产版本显式拆分原fused bridge阶段，复用唯一G/quant/fullA实例。
4. 映射：GEGLU CONTEXT=P=当前G，SOURCE=WI、DST=GATE，A/W/PS是下游预约，future-dst=Down.dst；QUANT CONTEXT=Q，SOURCE=实际源、DST=A8，future-dst=L.dst；MATRIX CONTEXT=L父ctx、P/Q不变、DST=future-dst=L.dst。LOAD扩展全零，W_REF=LoadTask.dst、其余Ref零。完整规范含source/output stride和unused字段约束，务必读表。
5. 全tensor GATE只用一个Ref/epoch；每个rows16窗口按P/Q/L与future Ref独立记覆盖/消费。替换旧“每cfg新GATE epoch”为显式同owner合法下一窗口规则，保留防重放/重叠/错身份拒绝。全部B*S行和真实B闭合才tensor READY。三个2624x32 bank仍只存一row工作集。
6. rows16只量化一次，四个rows4 view共用完整父L和A/W/PS/dst；新增单活动parent lease层，view间不得真实release fullA（旧release清空slot）。每view响应带范围并独立drain，父TaskDone仅一次，等全部view/末B/lease结束；按原tile优先u64 rank归并首错，不能早view数值失败就跳过后续必要检查。
7. 保持原typed bank/物理slot相等规则；M003当前bank0路径可串行slot0，不静默改bank映射，不宣称双槽重叠。请求失败后安全drain并撤销未激活ticket，已claim epoch不回退；仍支持同generation更大request_id的下一请求，不强制换generation才能恢复。

下一步：工程唯一修改实现/RTL/TB和三摘要，继续BO/LOAD既有成果；完成v2、预约/G分期/parent lease的受影响用例后，推进L2/L3、稳定身份完整CPU/实际CSim和M004。必要用例见合同§6，尤其多于两G窗口、同GATE epoch跨rows16、四view不丢A、跨view首错、末B反压、同generation故障恢复。

原数值/模型/shape/13BO/资源帽不变；本答复不启动新OOC/P&R/上板，G余2338.224019s不重置。完整加速器与尽量高性能仍是M004总目标，不设固定性能门槛；局部链不能结束总任务。若实现发现本文仍有真实矛盾，按已核验授权直接发具体问题给本主控；不需用户转发，也不必为本消息单发收到确认。


[原始消息收据](../../.research-agent/communications/quant-g-answer-20261011.json)

相关文件：[quant_g_portal_contract_v2_20261011.md](../../results/quant_g_portal_contract_v2_20261011.md)

## 相关决定和审核

- [quant_g_answer_message_20261011](../../results/quant_g_answer_message_20261011.md)
- [quant_g_portal_contract_v2_20261011](../../results/quant_g_portal_contract_v2_20261011.md)
- [review_queue](../../results/review_queue.md)

### 状态确认 2026-10-11T16:27:38.168551+00:00

项目主控与架构评判：v2身份、预约与父lease定义已有局部实施证据；完整生产G/Q/L及hub/caller仍未验证，不关闭集成事项。 → 待验证

[SM003.md](../../results/reviews/SM003.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
