# Laya Typed-Decisions Q8 / U55C 硬件规格

统一规格 v1.0，2026-10-05。此目录只有一套当前规格，按 **总体设计＋分模块＋联合接口/验收** 组织。后续修改直接维护这些文件。

## 从哪里开始读

1. [00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)：CPU/FPGA分工、完整数据流、规格来源、工程现状与缺口。
2. [16 两个Llama baseline的源码依据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md)：借鉴的具体代码与Laya必须重做的部分。
3. [02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)：怎样生成xclbin、经XRT在U55C运行，以及尚未冻结的平台条件。
4. [15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)：关联模块一起考虑接口、背压、缓存、共享计算与性能。

模块工作区入口为[module_design目录与规格对应表](../module_design/README.md)。每模块采用source/、rtl/、tb/，source只保留详细design.md和平台/资源/性能results.md，原规格路径和对应章节在design.md中引用；尚无RTL实现。

## 文档分工

| 层次 | 文件 | 负责的内容 |
| --- | --- | --- |
| 总体 | 00 | 目标、范围、CPU/FPGA架构、来源与缺口登记 |
| Host与控制 | 01、02、03 | 请求/结果、XRT/平台、前向调度 |
| 数据与存储 | 04、05 | 模型包、地址、BO/HBM、片上缓存与带宽 |
| 基础算子 | 06、07、08、09 | Embedding、LayerNorm、量化、Q8 Linear/恢复 |
| 主干链路 | 10、11、12 | RoPE/mask、attention、FFN/residual |
| 输出模块 | 13 | Decision、scorer、act与CPU解码边界 |
| 验证 | 14 | 数值/质量/资源建议线、上板流程、实际验证状态 |
| 共同接口 | 15 | 模块交接、资源互斥、联合周期与变更传播 |
| 代码依据 | 16 | 两个baseline的版本、源码对应和迁移限制 |

每份模块文档先列“目标要求、工程现状、状态、来源”，再解释具体设计。**推断/待确认不等于已实现或已验收**。150MHz、阵列规模、13个master和性能预算均有条件；完整神经网络在U55C推理是最终目标。

## 唯一维护规则

- 00管理总体目标与来源；各模块管理本模块细节；15统一交接；14统一验收。出现矛盾时记录并联动修订，不由某一模块静默覆盖另一模块。
- [source中的早期推导](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/source/laya_baseline_design.md)继续作为模型研究和公式来源，当前硬件规格与状态以此目录为入口；不把早期试算值直接升级为硬指标。
- [hardware-agent规格入口](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/spec.md)与[本次任务记录](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/task.md)只做索引/范围记录，不复制另一套规格正文。

## 历史文件存放在哪里

整理前35份Markdown（包含当前稿、旧archive和source设计依据）已完整打包到[目录外历史备份](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_history/design_source_before_unification_20261005.tar.gz)；每份原始文件的SHA-256见[备份清单](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_history/design_source_before_unification_20261005.manifest.json)。备份已逐文件验证，旧archive不再留在本目录。需要追溯时解压到临时目录，不能覆盖当前规格。

本次完成的是文档归并，尚未执行HLS/RTL、综合、实现、时序或U55C推理验证。下一实施关口及缺口见00§10和14。


本次详细接口入口：01§6请求、04§7布局、14§9结果/错误与§10真实参考、15§10–§16内部任务/数据/生命周期；各模块source/design.md§10–§11给具体绑定及已捕获节点。真实Typed Q8软件数据见[reference/README.md](../../reference/README.md)，本次未执行硬件验证。
