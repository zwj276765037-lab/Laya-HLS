# 工程实现与验证 — A002

## 当前有效任务：M006 / SM007 / E007（2026-10-17）

按[SM007](../../mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md)实施完整板端 Attention 与共享计算首段。唯一实现根为 `project/E002_Laya_HLS/experiment`，新原始证据仅写 E007/R001；新预算与停点以 SM007 为准。FPGA 执行所有逐层 Attention，CPU 只承担合同规定的输入、尾部和 Host。旧 M004/SM004 保持暂停，历史证据和余额不迁移。A002 独占本项目重工具与生产实现写入；不新增 agent。

首项冻结现有严格 expf、TANH 和直接 F32 divider 来源，在真实 U55C part 与 300MHz 约束下做单 lane 资源/II 风险样本；并建立可被生产主干唯一调用的 256-lane 共享 FP 与 phase lease 接口。独立模块结果不代签全 head/30 层。期望模型为 `gpt-6.1-sol/xhigh`；当前会话没有可核验的实际模型/强度配置收据，保持未知。

## 当前有效任务：M004 / SM004 / E004（2026-10-14）

用户已批准Goal v4/M004修订3并“支持开始实验”。依[SM004](../../project/missions/SM004.md)执行首段完整软件基线与最简架构接点核查；host阶段预算1800s/16GiB，最多两次有因完整正常请求。你是唯一工程和重工具owner；实现仍E002，证据E004，首次实际运行登记R001。普通构建/路径/driver修复连续执行，不改gold。当前不启动EDA/GPU/新agent；架构由A001集中确定后进入下一实现段。

不等待M003全部通过，不重启旧M005/FFN候选，不把原13BO/通用portal/owner设计当不可改变前置。保留模型和数值，以及必要流控/复位/错误报告。你不是唯一在代码库工作的人，保留他人修改；研究不修改你的源码，主控维护共享合同。

以下任务文字均为历史，冲突时以本节、最新M004/SM004和本次直接派发为准。

当前总目标M004；执行前置M003/SM003/E003，继而SM004/E004、SM005/E005。最新[M003](../../mission/M003_当前身份生产链接入与回归.md)和[M004](../../mission/M004_完整Laya加速器搭建与性能优化.md)指定A002唯一工程owner；共享registry尚为旧M002/SM002/E002，待主控同步，工程不改共享登记。

唯一代码根project/E002_Laya_HLS/experiment；新E003只存方案、冻结证据、run和三摘要。A002写实现/RTL/TB/运行、模块design/results与E003三摘要；主控写goal、顶层mission、共享索引和模型策略。你不是唯一在服务器工作的用户，不撤销他人修改。原baseline及E002验收/handoff不修改；旧A002状态/result已留存历史快照。

按M003 L0→L1→L2→L3→最终身份→L4→L5顺序；不以其局部通过结束完整加速器总任务。模型/shape/层数、数值、独立gold和CPU/FPGA职责不变；普通实现修复持续授权。各类PASS/FAIL/NOT_RUN/COST_STOP与局部/整图/物理/板端严格区分。

全项目单重工具，CPU0–3/nice19/idle I/O/MemAvailable>192GiB；本M不新OOC，G余2338.224019s不重置；其余预算见E003协议，继承更严格CPU/CSim16GiB/1800s。只管理本项目自己owned进程。

当前[E003/R002](../../project/E003_production_chain_closure/experiment_results/runs/R002/run.md)启动准备完成，L0 PARTIAL，L1–L5 NOT_RUN；没有后台工具运行。工程期望gpt-6.1-sol/xhigh，实际模型/强度无可核查配置证据，仍null。


## 首请求阶段A受影响owned program实现（2026-10-13）

依据D-M003-FIRST-HARDWARE-BASELINE-01继续。FIRST-only顶层已有executor_hls_host_01六独立process有限host PASS，不代签硬件链。父A002唯一写共享actor/stream/top和新owned program实现；A006写顶层test/runner，A005写独立控制transport RTL/TB。新内部program归属通道复用现LHC1完整GRANTED、LAP1固定1024B，无新wire/schema：真实shell accepted receipt之后program全帧安装并echo，才发LGP；实际graph.pending输出LAP；真实LAC consumer完整echo后actor完成。旧4FIFO program top仍保留兼容身份，新owned top FIRST-only结束后不收第二command。无CLOSED/rearm扩大，无FIFO/reset清理。单重工具/原资源帽不变。
