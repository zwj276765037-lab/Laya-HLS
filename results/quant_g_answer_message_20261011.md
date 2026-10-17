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
