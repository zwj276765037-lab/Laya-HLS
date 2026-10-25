# 原30层完整图成本规划

正式整图E仍UNKNOWN，未启动kind7完整长跑。原图固定10full/18sliding Encoder、2Decision，共120矩阵、60LN、61vector、28GEGLU。滑窗QK仍遍历32 query group×128 key、AV仍完成4096组累加/128key，finite mask不裁调度，不能按滑窗面积削减成本。

setup/H只算一次7.203s，Encoder0核心329.075s，后继27层各新增preLN代理11.512s，Decision0核心321.435s，Decision1核心或代理329.072s（独立完整实测=True），另finalLN代理11.512s、type代理2.666s。未测tail前加权代理10196.799s（2.83小时）。条件规划范围9177–12866s（2.55–3.57小时）；上沿取1.25×代理+120s未测尾部余量，是工程计划余量，并非已测或证明的保守E。

缺口仍含未完整实测sliding层、final gamma/type/tail及连续kind7交接，数据也可能改变CPU成本。中央代理需约2.83倍加速才合3600s；规划上沿需3.57倍。R002总7200s比中央代理少2997s；当前留600后可支配5275.778s。两Decision已按实际guard收据扣费。组件通过不能打开旧长跑门。

最小完整方案复用同一exe/数学模型不重译，另立单次13000s/独立RTL13600s含600保留的成本合同；保持1线程、CPU0–3/nice19/idle IO、8GiB/40Mcycle、单锁与连续真实成功阶段120s。一次原kind7/local0 BEGIN，真实0..29连续前后依赖、不注入中间fixture，保留全部原checkpoint、tail、544组公开输出、成功DONE消费、真实idle及正常退出。通用捕获记录30层实际H作独立复核，不能替代TB。此为具体建议，未获新成本合同不执行。

机器可核公式和源身份见同目录fullgraph_cost_projection_after_Decision0.json。
