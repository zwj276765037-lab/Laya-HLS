# M002：完整Laya加速器实现

execution_state: planned
verdict: unassessed
applicability: 尚未在新项目启动实现；继承结果各按原冻结身份和范围解释。

## 痛点与当前基线

完整CPU/CSim是旧稳定build23c62cd4的软件通过；目前新Q8驻留、Attention与G存储优化是局部硬件结果，实际13BO生产入口未完整连接。直接复用局部PASS不能判整网硬件通过。权威现状是[副本阶段结果](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md)与[联合设计](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/source/design.md)，历史已知失败、成本中止和未验证保留。

## 实现和验收

通过SM002恢复同一副本工程与当前输入身份；按已定义的显式命令/完成FIFO、持久fullA/W/PS/bias/writer、真实AXI owner/debt绑定原13BO生产壳。先接通同runtime最小真实producer边界，再冻结新build进行完整CPU/CSim与有界分段RTL；能合理完成才整层/整图RTL。当前Attention/G/PS结果复用必须身份匹配。最终用完整请求延迟和完成间隔检验性能；不能用条件150MHz换算当物理频率或端到端实测。

原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。

## 负责人、资源与停止条件

A001主控/架构结果评判；A002唯一工程实现负责人；A003按实际需要研究瓶颈。角色目前仅登记未启动。工程GPT-6.1 Sol/xhigh连续修复；Astra/xhigh在综合结果后集中评判及改进。普通修复无用户逐步审批，实质合同改变处理受影响边界；不新增无关正式审核材料。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。

当前接入不启动实现。新对话应先读取[交接入口](../NEW_CHAT_START.md)、核对既有路线与缺口，保持功能/吞吐优先，基于实际资源账再决定G存储物理闭合、LN和更宽Q8的顺序。长仿真先pilot和实速估成本，不能合理完成则列分段替代覆盖和未覆盖项。
