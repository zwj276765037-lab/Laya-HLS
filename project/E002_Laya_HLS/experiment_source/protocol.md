# E002：继承基线与下一实现实验方案

## 范围与权威来源

完整工程代码位于 `experiment/`，来自原baseline阶段收口后完整复制。所有原代码、HLS生成、RTL/TB、模型包、build、原始attempt日志/receipt保留；复制证据在E001。当前硬件合同/结果为 [联合设计](../experiment/results/compute_throughput_optimization_20261010/source/design.md)、[联合结果](../experiment/results/compute_throughput_optimization_20261010/source/results.md)、[阶段表](../experiment/results/compute_throughput_optimization_20261010/stage_results.md)。此协议映射既有证据，**没有在新目录运行硬件**。

## 平台、数据与身份

目标U55C，Host CPU/XRT/PCIe/HBM框架；真实板卡不存在，部署平台/XRT实测未验证。已有Vivado/Vitis2025.2实际路径/版本以每次原receipt为准。真实Q8 GGUF SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；共享模型只读，输入为完整B1/S128、28 Encoder＋2 Decision/scorer/ACT，122矩阵。旧软件完整PASS身份是build23c62cd4778f54e3cc7508f5d05558de，当前working源已改变，应新建身份验证。

## 步骤和独立参考

按SM002顺序核对现状→显式生产cmd/rsp接口与13BO外层→真实producer及驻留服务连接→稳定新身份CPU/CSim→有界RTL/性能计量→受影响模块资源→集中技术评判。CPU参考/原独立gold和中间checkpoint必须沿用原定义，不读取DUT结果改gold。

原attempt脚本的绝对路径保持历史内容，禁止直接启动；从副本重新生成配置和新的本实验运行R目录，每次记录全部实际源、IP/XDC、模型/输入/reference/tool/config身份与完整日志/退出码/保护原因。复用旧已通过闭包必须验证身份与协议/语义未变，并写“复用”，不是新实测。

## 判定、计量和成本

自检逐位/原适用LN容差及首错/反压/CE/reset/owner/响应退休断言；进程0与实际PASS marker及完整动态计数共同判定。真实输入的几个请求一致不推出数据集准确率。冷暖延迟与完整请求完成间隔按同模型/shape/条件单列，局部cycles、条件150MHz及综合估计不当端到端/Fmax。

原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。

成本中止与功能FAIL分开。长仿真先实速pilot，不能合理完成则做有界模块/边界替代并注明未覆盖同runtime整图。新运行尚未启动，E002当前状态为planned、整体verdict unassessed。
