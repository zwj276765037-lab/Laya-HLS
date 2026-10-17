# Laya-HLS：独立 research-agent 项目

先读 `NEW_CHAT_START.md`、`goal/goal.md`、`mission/current.md`、`results/overview.md` 和 `results/review_queue.md`。使用 `/home/zwj/.codex/skills/research-agent/SKILL.md`，硬件实现同时使用 hardware-agent。

本项目根为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`；唯一新实现工程为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`。原 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline` 是保留的历史来源，禁止删除、移动或因副本开发写回原工程。复制的文件是历史原样记录，未来新运行路径依 source/path_mapping.md 重建。

父目录Laya的AGENTS中，M002/SM002/E002/A002、refresh_console.py及Laya-repair描述属于旧Laya顶层投影，**不是本独立项目的登记**。本项目同名ID只在自身 `.research-agent/project.json` 中解释。不改Laya顶层goal/mission/results/刷新器或其他项目；本项目摘要由research.py publish原生维护。

主控唯一维护goal、顶层mission、索引、模型策略、review与总结果。工程维护E002实现、模块source/design.md和results.md、RTL/TB及原始运行；研究维护方法与瓶颈证据。模块复用既有source/rtl/tb目录，design.md只引用design_source规格位置，不额外复制规格。共享RTL/接口与索引必须只有一位写入负责人；你不是唯一在服务器工作的用户，不得撤销他人修改或管理无关进程。

最新分工：GPT-6.1 Sol/xhigh按既定mission连续实现、编译、仿真、修复和受影响回归；GPT-6 Astra/xhigh仅在实际综合结果之后集中评判结果和改进方案。普通实现或脚本错误没有逐次源码/编译/运行审批，不要求用户逐轮审核。未定义的实质架构、接口或数值变化不得偷偷替换合同，按现行模型政策处理受影响边界。仅在实质阻塞、阶段完成或最终结束时向用户报告。

原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。

PASS、FAIL、NOT_RUN和COST_STOP分别记录，软件CPU/CSim、分段RTL、同runtime完整RTL、OOC、P&R/时序、上板独立报告。目标优先正确性、完整推理、可核实吞吐改善与资源预算；50ms不是唯一硬门槛。代理注册不代表启动，未取得真实runtime/thread/model不得填写为已运行。

## Codex工作对话

同名分区Laya-HLS已创建四个职责对话：项目主控与架构评判、工程实现与验证、研究探索与瓶颈分析、技术问答。入口与真实绑定见agent/work_chats.md及.research-agent/codex_workspace.json。A编号仅为内部兼容标识；三个主角色目录保留。技术问答维护question，工程仍是实现文件的唯一写入负责人；建立聊天不代表启动硬件实验。恢复时复用既有入口，不重复创建。


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
