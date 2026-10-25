# E016/R002 阶段交付


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


SM012 D-M007-SM012-SIM-COST-13；A010。R001原首head/故障/消费者/共同reset证据与成本出口冻结，见[原有界交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)。本段无生产RTL变更，parent SHA e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8，Profile0，原sharedFP/DIV/layer/resource依赖与原模型fixture保持。

两组逐文件冻结源码完全相同，xelab命令均为work.m007_single_parent_tb --relax -debug VALUE -mt4 --O3 -s m007_parent_sim；唯一选项差VALUE=typical/off。off直接复制typical冻结closure。两个snapshot保留实际生产模块、原独立数值gold、内部协议/排债/身份/连续issue/PS反馈断言及原checker频度。相同R002 TB统一仅增加一个被动quant-return计数、4096终点断言和既有input/quant/A/W/QKV握手打印；AT005去掉这些插入后逐字节恢复原TB SHA，确认未删改任何原checker/驱动。

原fixture复用R001 AT012记录的28个文件，全部逐SHA核对。每组相同原Encoder0 QKV3，不跳实际parent相位，不发布父成功，不跑16head/WO。全部实际tool子进程串行持m007_heavy.lock，CPU0–3/nice19/idle，MemAvailable>192GiB，static24GiB/RTL8GiB、120s单次帽、strict numerical progress120s与40Mcycle不变。新独立reference0/static300/RTL300/OOC0s，无R001余额转移。

协议：[r002_sim_cost_protocol.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/r002_sim_cost_protocol.md)。实际源码/命令/产品/fixture/日志/guard与receipt分别在R002/attempts。debug off的Tcl结果只用自己的query，不继承typical层次；观察到的scope可见性不作为物理实例/资源比较。


execution_state: completed
verdict: inconclusive
applicability: 原Encoder0当前parent/同TB的单样本QKV3 debug选项对照。

AT001–005全部实际闭合：typical/off构建与数值RTL均PASS，审计PASS。off54.403592327s慢于typical48.806138473s；实际计数和8364周期完全一致。本路径未观察到改善，按合同停止，不继续其它旗标，不自动运行16head/WO，不修改硬件或默认runner选项。完整父/30层/部署与300MHz仍未验收。

已无owned工具子进程或锁等待。A010运行身份/root/m007_weight_supply_engineering；期望gpt-6.1-sol/xhigh，实际model/effort UNKNOWN。新预算0/300/300/0s，已用reference0/static103.841320947/RTL103.209730800/OOC0，余额static196.158679053/RTL196.790269200s。R001冻结原artifact3032文件复核未变；无旧余额转移。

下一步交主控集中审核“debug off未带来本次QKV3成本改善”的实际结果。完整链后继必须有其它可证方法及独立scope/成本证据；本段不签全phase费用或硬件吞吐结论。
