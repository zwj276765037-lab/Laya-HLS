# Executor检查点高水位入口决定

回复：`executor-checkpoint-high-water-question-20261012`  
决定：**D-M003-EXECUTOR-CHECKPOINT-HIGH-WATER-01**。范围M003/SM003/E003/R003。

**采用受限方案1：唯一shell汇总真实hub/transport的只读下界，通过LBS2/LBR2固定1024B/16拍、version2交接；本阶段不新增方案2的历史重放/再次退休入口。** 完整条款见`results/executor_checkpoint_high_water_contract_20261012.md`。可直接按该合同实施schema/helper/有限握手及受影响验证，无需逐项请批。

本入口只签同一已准入请求、受控正常encoder_00_out前序后的有限NORM诊断。新诊断由唯一executor先真实LYRQ/LYMP准入一次，保持绑定并等待正常前序完成；前序入口实际排空、交出派发权后查询下界并启动action。同request checkpoint不再begin/admit。完整graph使用同一持续executor状态，不靠snapshot重建丢失runtime；任意失败/部分提交/未知预约空洞恢复不在本次允许范围。

关键实现决定：

1. hub读出匹配identity的`typed_last_task`和source/目标域的历史`owner_max_epoch`。**LPV `last_event_seq`实际属于`laya_generated_provenance_v1` transport**，由axi portal/shell直接接线并与hub同一静止交接点采样，不能用accepted_events计数代替，也不能把它描述成现hub已有字段。
2. producer request_seq、compute generation等由原持续executor/其唯一transport保持；hub不知的值不得补造。前序没有LPE1时只据实际权威自初始化以来未使用的状态取0。action ordinal仍归program持久状态，executor保留接收校验下界，不改变分配权。
3. **只提高TaskReservation不够**：现retire函数要求`task_id == last_task_id+1`。本有限导入允许保存显式checkpoint基线，并把退休顺序的前驱游标（可通过专用helper设置现last_task_id）初始化到真实hub最后安全终态task号，同时提高预约cursor。导入不调用retire、不造TaskDone、不增tasks_retired/op_calls/owner统计。base4只意味着后续可从task5开始，本段退休仍为0；真实task5–8完成才计4次，LAC1为first5/last8/count4。任务最大号或未知跳号不能当退休量。
4. 只有真实可知、完整且无未知预约空洞的安全前序可导入；未见域≠零。源/目标下界按分配物理等价域保守取max，含旧request与invalid/inactive历史。目标active、alias/base不明或缺完整下界拒绝；不创建目标READY/owner。已有更大本地下界保持，不能回退；不兼容基线拒绝，不伪造补齐。
5. v2仅一source/一target，保留完整identity/L13M/source/base键，扩展目标域键、交接epoch、下界和KNOWN/COMPLETE标志。旧v1只查source、不能使能诊断导入。工程冻结精确C/SV布局和独立oracle；全帧/绑定/容量/溢出核完才一次提交，不半导入。先排空旧END/末B/返回再锁前序派发；响应持有至实际consumer完成，source及目标域保持或实际CLAIM前重核，不能阻塞等待中的旧cleanup。

首轮负例包括非4/10的合法动态下界、更大LPV耗号、旧目标epoch/活动目标、producer/action持久编号、缺已知域/未知空洞、错旧绑定、重复query、反压/cancel/base变化和溢出；统计只来自后续实际退休。原F15/F16与F9/源保护边界继续受影响验证。真实F16/LN_05新交付另行审核，本决定不代签其PASS。

原单owner/单重工具、CPU/内存/时间/周期帽及G余2338.224019s保持；不重启5172s组合，无新agent/OOC/P&R/上板/预算。C009部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。下一受影响冻结闭包纳入本合同，旧证据不回写。
