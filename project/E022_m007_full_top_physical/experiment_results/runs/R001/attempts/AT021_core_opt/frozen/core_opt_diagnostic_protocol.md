# D38 完整matrix core同DCP一次优化诊断

执行人A010；主控授权为SM012末节“D38 核心实际资源超额后的同DCP优化诊断（2026-10-26 21:51）”。范围快照位于R001/input/core_resource_diagnostic_contract.md，保留原合同路径与SHA。A014独立审核、主控集中判断；A010唯一维护E022运行与三摘要。

输入是AT019完整matrix core的core_synth.dcp，520296664字节，SHA256 `a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90`。顶层`laya_m007_matrix_engine_v1`，器件`xcu55c-fsvh2892-2L-e`，原core 3.333333333ns时钟；输入DCP只读，91源/ROM/父11generic身份与D37功能证据保持。不得改RTL、数值、形状、端口、cone、保留属性或约束，不加tieoff、case analysis或伪常量。BRAM为0不能单独支持具体buffer映射根因。

实际前置是AT020正常完成、PASS收据/source_verify_after/owned清理/原锁释放。旧serial已按其确切PID/start单独SIGSTOP，AT020 guard/tool不受信号；原state只是历史快照，另有hold_receipt。轻量隔离fixture真实导入原stop handler，exit0/7均证明排队SIGTERM、核pending、再CONT会置requested_stop、回收原子进程并保留退出码，不启动facade。生产退出入口只在上述前置真实满足后使用同一方式，核serial/guard退出、无新attempt并记录父回收；不操作codex父进程。

独立入口为E002唯一实现树physical_d38/run_core_opt_diagnostic_d38.py，Tcl为core_opt_diagnostic_d38.tcl。原canonical run_physical_d38.py保持SHA `42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89`；新入口从该版本沿用资源、owned进程、真实停滞和精确Z回收实现，差异与新SHA保存在R001/core_opt_diagnostic_source。当前AT020冻结版本不变。

顺序只允许两个新stage，不启动独立serial或全父队列：

1. `core_opt`（implementation）：新attempt open原core DCP；保存完整port/direction、core clock/period/waveform/source及导出约束签名、part/top/零blackbox；保存before utilization/hierarchical/ram/clocks及本层直接primitive有界统计。写opt_invoked标记后仅调用一次常规opt_design，无directive搜索；立即另存checkpoints/core_opt.dcp，再核port/clock/constraint签名完全保持。任何既有opt_invoked都会阻止第二次core_opt，后报告错误不能导致重做优化。
2. `report_core_opt`（reports）：只打开候选core_opt.dcp，再保存同口径optimized utilization/hierarchical/ram/clocks、本层直接primitive统计及边界签名。候选DCP有独立SHA/source identity/生产attempt元数据。独立报告阶段允许保留中间DCP、准确划分费用并避免报告故障重跑opt。

主控在AT020实际时序/6091级最差路径核验后追加必要观察：`report_core_opt`还须保存优化后的全core最差setup路径，以及原`n_reg[1]`到`error_col_reg[0]/CE`的固定路径，各最多1条。记录真实端点、SLACK、逻辑级、逻辑/未布局net估计延迟和实际可用path属性；对照AT020原最差路径，明确是否变化。原对象被优化移除、合并或查不到路径时保留实际匹配数和不可用说明，不填0或宣称通过。基线timing_finding及最差路径header在新attempt冻结。两条有界路径报告不代表完整top/routed setup/hold覆盖；不为此重综合或重验功能。

本层primitive通过不带-hierarchical的get_cells选当前顶层直接primitive，导出每种REF_NAME实际计数。名称按数组起始及数字归一化分组，最多4096个一般组加每种primitive的OTHER桶，仅输出前256组、每组最多3个真实名称；可用的ORIG_CELL_NAME/ORIG_REF_NAME/文件行号等属性只对这些有界样例输出。保存实际可用属性名及overflow计数，不导出整个网表，不把名称归组当成源码因果结论。

两个stage沿原全项目m007_heavy.lock串行，256GiB owned RSS、MemAvailable>192GiB、CPU0–3/nice19/idle I/O、maxThreads4，implementation/reports单次及累计maximum_seconds为null/disabled。原300s实际owned CPU或log/checkpoint进展停滞保护保持。保存原始命令、冻结代码、日志、真实起止/退出码、内存峰值/系统余量、source_verify_after及owned清理；历史费用不清零、不双计恢复成本。

优化后core LUT仍>1303680，候选仍超器件，停止在集中架构/映射出口；<=器件但>900000仍违反完整kernel预算，也集中判断。即使<=900000仍需给外围父模块留余量，不代签full-top fit或300MHz。两个阶段均不自动接facade/parent/place/route；完整P&R与部署指标保持未验收。

准备期仅有Python语法检查、Tcl完整性检查、--plan源身份预检和轻量fixture；这些不属于实际EDA结果。实际启动后以新attempt/launch与stage receipt为准。
