# 新对话从这里开始

## 最新工作入口：2026-10-14 FFN3语义失败与FFN4描述符分离

先读[当前任务](mission/current.md)、[FFN3审核](results/measurement_first_FFN3_review_20261014.md)、[FFN4合同](mission/ffn_wi_descriptor_replay_stage_20261014.md)。AT062类型感知准备与真实LN冷前缀通过，唯一full到LN/Q/Wi后在271096触发Wi reader cfg Fatal。Wi消费271089、完成标记271090；后段未到，旧失败不回写。1549文件路径核验、336来源引用和262文件/130020393B编译包身份相符。

FFN4只分离Wi DDR与Down STATE1描述符，保留功能DUT/reader校验/观察器/guard/gold；新static、四行reader正反短测、一次冷前缀后以分阶段成本决定唯一full。静态/短测有界修正及host累计120s内连续准备，详细额度以合同为准。旧snapshot不可代表新TB，旧3536秒不自动准入。新结果NOT_RUN，旧局部PASS不拼接；普通Q/L及整体生产控制停排，M003/M004开放。

根目录/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS。使用research-agent，硬件实现遵守hardware-agent。先读适用AGENTS、goal/goal.md、mission/current.md、results/overview.md、results/review_queue.md及results/mission_scope_revision_20261011.md；旧controller_replanning_20261011.md是此前有界规划历史，最新用户范围优先。

当前总mission是M004完整Laya加速器搭建与性能优化。用户要求尽量高性能，暂不设具体门槛；20%/5%建议未采纳，50ms不是硬门槛。完整请求基线、瓶颈优化和资源证据必须交付，不能仅完成局部链就结束。

M003/SM003/E003完成身份/真实链/退休前置；随后SM004/E004全模型集成和完整请求验证，SM005/E005性能与资源闭合，最终回归和整体交付。唯一实现根仍是E002/experiment，新E只作证据容器，不复制代码，不写回原baseline。A002单owner，原模型/shape/层数/122矩阵/独立gold/数值和CPU/FPGA分工不变。

工程原评估已交付并核验18文件SHA，完整加速器仍NOT_ACCEPTED。旧build软件和局部resident/G/Attention通过仅按原身份有效；当前7项编译依赖变化、两项OOC COST_STOP和Attention历史文档SHA缺口保留。本轮只是修订合同，所有新阶段planned/NOT_RUN。

后续状态更新（2026-10-11接口答复）：工程现已执行E003/R003，L0/L1 PARTIAL；前段planned/NOT_RUN仅为此前范围修订时点。最新接口真源为results/quant_g_portal_contract_v2_20261011.md，确定quant/G显式三Context/future-dst、有界未来预约、G分期及rows16父任务/view租约。按该补充继续原授权实施，定义已解决不代表生产使能或完整链通过。

全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB及原内存/墙钟/周期帽不变；G累计OOC余2338.224019s不重置。完整验证若超帽，保留缺口并有界推进，不加帽、不降低完整目标。离线工程、P&R/Fmax与实板部署分层报告，当前无U55C不得声称板端通过。

工程交付result/handoff→主控核验对应完成turn和文件SHA→更新阶段判断/goal/mission。请求工程GPT-6.1 Sol/xhigh连续实现修复，主控GPT-6 Astra/xhigh集中评判，actual无证据保持null。已有授权和取消逐轮人工审核偏好保留；本轮没有启动实验或派发任务。


## 四个职责会话自主通信（用户2026-10-11直接授权）

用户已明确授权主控、工程、研究、问答四个既有会话自主提问、答复、决策和交付，无需用户手工转发。直接人类来源及实际四个收发身份见 `.research-agent/communication.json`；技能规范见 `/home/zwj/.codex/skills/research-agent/references/communication.md`。优先使用原生发送工具；当前服务器会话缺少该工具时，运行 `python3 /home/zwj/.codex/skills/research-agent/scripts/communicate.py send --root /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS --from 自己的角色 --to 对方角色 --kind question或answer --id 稳定消息ID --message-file 项目内文本路径`。答复添加 `--in-reply-to 原问题ID`。发送会唤醒既有对话并保存原生接受回执；仅写Markdown不能宣称已通知。授权仅覆盖本项目现有任务内协作，不改变职责、合同、模型、审核停点或实验成本约束。

<!-- research-agent:organization-rules:begin -->
## 统一记录与导航（用户已授权落地）

日常入口为根目录 README.md；任务、实验、工作通信和用户问答分别从 mission/index.md、project/index.md、communication/index.md、question/index.md 定位。四个实际会话见 agent/index.md。详细规则见 /home/zwj/.codex/skills/research-agent/references/organization.md。

首页、索引、任务/实验/批次README和通信时间线由 organize.py 统一生成；不得手工重写生成区。主控继续维护 goal/任务合同/决定/审核，工程继续维护唯一E002实现及运行证据，研究维护source，问答维护question。手工更新原记录后运行 python3 /home/zwj/.codex/skills/research-agent/scripts/organize.py refresh --root /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS。发布、状态报告和辅助通信已有自动刷新钩子。

旧M/SM合同、R目录、attempt名称、输入/源码/原始日志和收据保留原路径。正在进行的R003及其已启动尝试继续原路径执行；不为目录整理重启、重跑或扩大预算。新批次采用R，新具体尝试采用AT；新mission采用任务文件夹。旧登记ID再次使用时保持原身份和路径。

消息统一写入 .research-agent/communications 并按回复链生成C讨论。使用 communicate.py send 自动归档，原生发送后 archive 实际接受结果。答复关联原消息；送达、答复、实施、验证状态分开，重要讨论由负责人确认范围并附证据后登记待验证/关闭，不要求普通消息反复确认或用户审批。

当前总mission仍是M004，M003是前置；导航不修改科学结论或验收状态。主控切换当前任务/依赖时运行 organize.py configure。仅有记录和局部PASS不能代签完整加速器。

<!-- research-agent:organization-rules:end -->
