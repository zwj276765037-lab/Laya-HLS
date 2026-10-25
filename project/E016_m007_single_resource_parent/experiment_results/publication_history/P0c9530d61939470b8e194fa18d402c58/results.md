# E016/R002：两组功能通过，未观察到仿真成本改善

execution_state: completed
verdict: inconclusive
applicability: 仅同当前parent/同TB/原fixture的单次有序QKV3比较；不外推全部phase或FPGA性能。

| 指标 | O3/debug typical | O3/debug off |
| --- | --- | --- |
| 实际build | AT001 PASS，46.737763029s | AT003 PASS，52.533158917s |
| 实际QKV3 RTL | AT002 PASS，48.806138473s | AT004 PASS，54.403592327s |
| 命令→QKV3周期 | 8364 | 8364 |
| input / quant-return / Awrite / Aack | 各4096 | 各4096 |
| W_AR / W_R | 320 / 5024 | 320 / 5024 |
| public QKV32 / 逐位F32值 | 768 / 24576 | 768 / 24576 |
| 实际issue→ack / PS反馈 | 31 / 13拍 | 31 / 13拍 |
| 身份/跨层tensor零工作拒绝 | 8项 | 8项 |
| strict checked highwater | 155648 @ cycle8955 | 155648 @ cycle8955 |
| 自己的Tcl scope数 | 91940 | 90486 |
| 自己的所需13模块/服务路径 | 均恰1份 | 均恰1份 |

两例每块1024连续issue/commit，所有原实际W/A映射、prebias、公共QKV与Attention独立gold比较和原协议断言通过。终点parent phase5，真实父仍未完成。debug off完整保留当前TB内部引用且本机Tcl query成功；91940/90486是调试展开可见性差异，不是硬件资源减少。

本次off比typical慢5.597453854s，即11.468750%。每组仅1次、固定typical→off顺序，不提供方差、置信区间或普遍速度劣势结论；现有样本未支持成本改善，依合同结束本路径，不继续盲试旗标。普通生产runner仍保持原O3/debug typical。

实际已flush阶段wall差值（只签相同QKV3边界）：量化/A phase3→4为2.836810378/2.767173767s，均4187周期；matrix phase5→QKV3为39.544960920/45.218092302s，均4173周期。更多block差值见[phase_comparison.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/phase_comparison.json)。这些是主机观测时间，不是新硬件时序；没有本组合完整head/16head/context/WO成本样本，不能代入完整链作放行。

AT005审计PASS4.570399001s：R002634文件、3616检查；另重新核对R001冻结原artifact3032文件全部未变。两组源码/编译选项差/原TB保留/fixture/计数/周期/strict guard和预算一致性通过；4项xsim_script.tcl/xsimkernel.log运行可变差异单独保留。raw warning/error及自己的hierarchy query日志完整保留。

最终独立费用reference0/static103.841320947/RTL103.209730800/OOC0s，含审计；余额static196.158679053/RTL196.790269200s。无失败重跑或原预算转移。R001完整16head/WO成本门3494.951523668s>1200s继续COST_STOP/NOT_RUN；本段未创建长例。数值/物理/整图限制继续按R001版本边界保留。

证据：[成本对照](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/attempts/AT005_same_source_flag_comparison_audit/work/cost_comparison.json)、[审计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/attempts/AT005_same_source_flag_comparison_audit/work/evidence_audit.json)、[预算](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/ledger_reconciliation.json)、[协议](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/r002_sim_cost_protocol.md)。


---
Published: 2026-10-22T09:38:02.640680+00:00
Publication: Pb59087cd3b924b2598fdc3a1e351b6a9
