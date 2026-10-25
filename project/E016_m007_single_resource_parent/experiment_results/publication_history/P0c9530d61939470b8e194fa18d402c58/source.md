# E016/R002：同源QKV3的debug选项成本对照

SM012 D-M007-SM012-SIM-COST-13；A010。R001原首head/故障/消费者/共同reset证据与成本出口冻结，见[原有界交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)。本段无生产RTL变更，parent SHA e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8，Profile0，原sharedFP/DIV/layer/resource依赖与原模型fixture保持。

两组逐文件冻结源码完全相同，xelab命令均为work.m007_single_parent_tb --relax -debug VALUE -mt4 --O3 -s m007_parent_sim；唯一选项差VALUE=typical/off。off直接复制typical冻结closure。两个snapshot保留实际生产模块、原独立数值gold、内部协议/排债/身份/连续issue/PS反馈断言及原checker频度。相同R002 TB统一仅增加一个被动quant-return计数、4096终点断言和既有input/quant/A/W/QKV握手打印；AT005去掉这些插入后逐字节恢复原TB SHA，确认未删改任何原checker/驱动。

原fixture复用R001 AT012记录的28个文件，全部逐SHA核对。每组相同原Encoder0 QKV3，不跳实际parent相位，不发布父成功，不跑16head/WO。全部实际tool子进程串行持m007_heavy.lock，CPU0–3/nice19/idle，MemAvailable>192GiB，static24GiB/RTL8GiB、120s单次帽、strict numerical progress120s与40Mcycle不变。新独立reference0/static300/RTL300/OOC0s，无R001余额转移。

协议：[r002_sim_cost_protocol.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/r002_sim_cost_protocol.md)。实际源码/命令/产品/fixture/日志/guard与receipt分别在R002/attempts。debug off的Tcl结果只用自己的query，不继承typical层次；观察到的scope可见性不作为物理实例/资源比较。


---
Published: 2026-10-22T09:38:02.640680+00:00
Publication: Pb59087cd3b924b2598fdc3a1e351b6a9
