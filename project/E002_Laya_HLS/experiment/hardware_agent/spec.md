# Hardware-agent 规格入口

统一规格 v1.0，2026-10-05。目标工程：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`。

本工程沿用用户指定的`vivado/design_source`文档约定。此文件仅作技能入口，不另存一份规格正文。

- 权威阅读入口：[design_source/README.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/README.md)。
- 总体规格、值/状态/来源和缺口：[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md) §9–§10。
- 模块01–13，共同接口：[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。
- 验证门槛、证据和当前状态：[14 验证与验收](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)。
- 当前任务边界与实际检查：[task.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/task.md)。
- 模块工作区：[module_design/README.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/README.md)，含15个模块的详细design.md、平台/资源/性能results.md及rtl/tb目录；design.md第2节直接引用原规格路径与章节。

P2完整F0功能工程已搭建：[task.md §12](task.md)定义冻结数值、真实存储/owner、全部typed任务、28 Encoder＋2 Decision与scorer/act及最终分阶段验收。当前包CPU S128三次成功整图141点和真实13口top标准libm CSim47点均逐位通过，另含同Runtime故障恢复。完整top实验综合因工具主机内存限制终止，物理综合、整网RTL及平台/上板性能保持未验收。P0/P1保留历史回归；实际入口见[项目README](../README.md)及15模块results。

本轮设计、文档与审核由实际GPT-6 Astra xhigh承担；HLS/Host/独立参考与测试由GPT-6 Sol max分工实现。2026-10-05原生软件采集使用GPT-6.1 Sol是历史事实。未测的资源、端口、时序、质量和上板性能继续保留缺口，候选配置不作为已达结果。
