# 当前方法和来源

部署框架参考两个Llama baseline的Host CPU/XRT/PCIe/HBM模式；算法和数值输入来自真实Laya量化微调模型。原研究/设计保存在副本 [source/](../project/E002_Laya_HLS/experiment/source/) 与 [vivado/design_source/](../project/E002_Laya_HLS/experiment/vivado/design_source/)，模块详细规格/结果在 [vivado/module_design/](../project/E002_Laya_HLS/experiment/vivado/module_design/)。

当前路线：CPU token Embedding＋固定模型一次校验，FPGA全部后续LN/动态量化/Q8/Attention/非线性/Decision；以宽块访存、权重广播与双缓存、同步PS、真实producer交接、共享FP服务改善吞吐。各候选只按独立参考和实测身份判断，软件整图与局部RTL证据分层解释。

当前设计与下一生产接口方案见 [联合设计](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/source/design.md)，阶段终态见 [stage_results](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md)。新项目没有新增算法论文或未经验证的性能结论；A003需按实际瓶颈提出可检验实验，而非扩展非关键报告任务。

路径采用[path_mapping.md](path_mapping.md)，完整副本核对独立于硬件正确性。50ms与150MHz都不能替代当前实测整网结论。
