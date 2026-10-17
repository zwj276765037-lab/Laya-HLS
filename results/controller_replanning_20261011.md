# Laya-HLS 主控评估与下一阶段重规划（2026-10-11）

execution_state: completed
scope: 本轮工程交付核验、技术判断与goal/mission重规划
accelerator_verdict: NOT_ACCEPTED_EVIDENCE_INSUFFICIENT
next_execution_state: planned

## 先后顺序与交付身份

已严格完成：工程先交付当前实验评估和result→主控等待本次工程turn真实completed→核验handoff与文件→读取工程result/报告/三摘要→更新goal与新mission。本文件不是新硬件运行记录。

工程thread为01a129af-29ef-7102-b86a-a43995a36279，宿主remote-ssh-discovered:zwj-server。实际完成turn为01a129d6-a5eb-71d3-b2fa-f01e8eaac6f8；旧turn 01a129c6-322a-7933-92c4-27319c78615a因权限切换中断，未当成completed。原生wait_threads确认新turn completed，快照在[工程完成快照](controller_replanning_evidence_20261011/engineering_completed_snapshot.json)。

[handoff](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_handoff_20261011.json)的project_root、engineering_thread_id、turn_id、stage=engineering_acceptance、status=completed、completed_at均匹配。标记完成时间2026-10-11 15:29:07.227942北京时间，位于真实turn起止之间。handoff SHA256为4e197a9186a4d104a7a907d549188f28d3b17c85aff880ca95152ce2835590de；所列18份文件的SHA256和长度全部匹配，包括报告、A002/result和三摘要。主控未修改这些工程交付文件。[核验收据](controller_replanning_evidence_20261011/handoff_verification.json)。

本轮由既有主控对话01a129af-0395-7fd0-95ac-edd54873bd5f执行。请求配置为GPT-6 Astra/xhigh；工具未提供实际模型/强度证据，actual_model/actual_effort继续null，不把请求配置写成实测。权限变更没有改变模型策略或实验资源合同。

## 核心判断

接受工程报告作为本轮可追溯的工程评估交付。此技术决定只接受其证据与范围表述，不接受完整加速器，不记录虚构的用户approved。M002整体证据不足，方法判断inconclusive；运行失败和COST_STOP不等于方法被否定。

| 原目标或任务 | 当前证据与达成程度 | 主控判断 |
| --- | --- | --- |
| M001完整复制/接入 | 既有收据210038普通文件、6100 links；本轮不重扫 | 保留completed/supported |
| M002完整模型当前数值 | 旧build完整CPU/CSim PASS；当前46编译依赖7项变化，生成配置另变 | 旧结果不失效于旧身份；当前完整回归仍NOT_RUN |
| SM002生产连接与吞吐闭合 | resident/G/Attention各有局部PASS；Wi与A仍外部fixture，实际§3.9/13BO整链未证实 | 同runtime真实producer和安全退休是当前关键路径；不并行重复派发旧SM002 |
| 完整请求性能 | Attention同fixture模块计算604317 vs 6816248cycles；G与Down各局部边界 | 约11.279259倍只属Attention模块；不拼为整机耗时/吞吐或GPU加速比 |
| 可部署资源 | 当前G父与Attention OOC COST_STOP；旧父/子存在包含关系 | 不判fit，也不判数值失败；先列缺口，不能重复加账或借旧DCP代签 |
| 整图RTL、物理/板端、数据集准确率 | 尚无当前完整证据，且无U55C | 保持NOT_RUN，不由规划/对话/评估完成代替 |

Attention两处历史文档SHA缺口是追溯限制；运行源引用一致允许按原身份保留head128正常计算和tile16协议范围。不得把它表述为185项全部无漂移。历史tanh/quant tiny数值FAIL保留；successor限定PASS不追认旧失败。

## goal版本变更与依据

[旧goal v1](../goal/history/goal_v1_pre_replanning_20261011.md)逐字节保存；[预变更清单](controller_replanning_evidence_20261011/preimage_manifest.json)还保存旧current、M002/SM002、overview、主控状态与相关汇总。M001/M002/SM002原合同与旧模型政策保持原内容。新[goal v2](../goal/goal.md)保留长期U55C目标、完整模型/shape/层数/122矩阵、独立gold、CPU/FPGA分工和性能/资源/物理分层标准。

| v2调整 | 工程证据来源 | 意义 |
| --- | --- | --- |
| 明确当前源身份与旧完整回归分开 | 工程报告§2、§3：7项编译依赖变化 | 不再把旧build通过作为当前完整软件通过 |
| 将下一阶段收敛到真实生产链与安全退休 | §3、§4：fixture边界、13BO未接通、生产恢复缺口 | 先关闭连接证据缺口；不降低长期整图验收 |
| 增加有界阶段完整CPU/实际CSim和受影响RTL出口 | §5 P0/P1/P2及原141点/18,094,384 F32 | 新身份必须重新满足原数值口径，未变叶子证据复用 |
| 将新物理路线和容量优化留待后继任务 | §4/§5：两项COST_STOP、G余2338.224019s、TM4约46.055Mcycles超过40M帽 | 防止无依据扩大工具成本；不取消最终资源/性能目标 |
| 明确合作顺序、真实状态和requested/actual区别 | 本轮真实turn与handoff核验 | 可从文件恢复，避免读旧初始化或把评估完成写为加速器通过 |

没有更改模型、gold、容差、覆盖标准或预算来使结果通过。本阶段4row真实链是明示的覆盖切片，完整B1/S128模型仍由当前全量CPU/CSim验证；同runtime整图硬件依然是长期未完成项。

## 采纳、暂缓与不再重复的工作

采纳工程P0：冻结preimage、新build与输入/工具/配置身份；重建副本路径，保留原baseline。采纳P1：既定§3.9 cmd/rsp、真实13BO、安全退休以及由真实Wi Q8发起的连续链。采纳P2中的稳定身份完整回归、真实pilot与有界分段RTL。

暂缓P2物理闭合：本M不新增G分层OOC或Attention OOC，原G剩余2338.224019s必须继承。物理缺口不会通过本阶段软件/分段RTL被消除。保留§8.4.11为未执行候选，不原样重跑父OOC或加帽。

P3拆分处理：本M要求真实服务计数、停顿和联合资源缺口账，以便后续选择任务；完整请求冷暖延迟、完成间隔、填充排空及可比吞吐的最终验收仍未完成，不在缺整图证据时承诺给出端到端加速比。LN、更宽Q8、多请求调度待有效资源与请求边界证据后另定。

Attention v10生产切换暂缓：当前生产仍原标量路径，UNVERIFIED补丁不当已应用；保留其局部证据，不额外扩大本阶段接入风险。其历史文档追溯可在L0有界处理，不能为了补文档SHA重跑未变数值RTL。

不重复：E001全树复制核对、未变模型全量扫描、身份一致的resident/G/Attention叶子正常与局部恢复全套、原旧build完整回归以及旧OOC原样重试。新接口、恢复路径或新依赖变化只重跑受影响范围；历史FAIL/COST_STOP保留。

## 新任务与后继关系

已登记未占用的新[M003：当前身份生产链接入与回归](../mission/M003_当前身份生产链接入与回归.md)、[SM003](../project/missions/SM003.md)与E003 production_chain_closure。E003仅是新阶段证据容器；不创建第二份实现、不重绑E002/M002/SM002历史身份。

M003顺序：L0身份/路径→L1§3.9生产门户/13BO→L2真实Wi→G→quant→Down→L3退休/恢复→冻结新build→L4完整CPU/实际CSim及受影响分段RTL→L5工程交付。每一步可测通过标准、预算、停止条件和负责人在合同中给定。全项目单重工具与原帽不变；无新增OOC、整图长RTL、P&R、板卡或训练。

M003只有全部合同标准满足才可在本范围判supported；完成不关闭M002。M002后继仍需按真实缺口分别推进全图硬件、资源fit、完整请求性能、准确率、P&R/时序与板端。旧SM002的重叠工作由M003承接，不另启动重复实现；剩余长期目标继续保留。

用户取消逐轮人工审核的偏好及已有连续实现授权保留。本轮只完成评估和合同定义，没有派发或启动M003工程实验，也未向其他对话发送消息。首个后续工程动作是按L0核对owner/资源、冻结当前依赖与输入身份、重建副本配置并登记新的运行身份。

## 审核与交付

现有SM001 pending事件保留，未伪造用户批准；它不要求决策，也不阻塞M003。SM002既有审核页追加真实主控技术判断；本次规划无新增用户决策请求。

更新goal、mission/current、overview、硬件/方法汇总、A001的mission/result/status及主控核验记录；工程handoff保护的18份文件不改。工程本轮assessment completed、主控replanning completed、M003 planned和完整加速器NOT_ACCEPTED分别记录。最终完整性检查见[记录校验](controller_replanning_evidence_20261011/validation.json)。
