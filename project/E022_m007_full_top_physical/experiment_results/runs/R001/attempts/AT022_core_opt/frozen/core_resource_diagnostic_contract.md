Source: /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md
Source SHA256: 3b35039b82a0e5e985ff84cdae33e2f422047dd1083c2700a40b602c59d41a2c

### D38 核心实际资源超额后的同DCP优化诊断（2026-10-26 21:51）

AT019已形成真实完整矩阵core DCP与PASS收据；AT020的已完成utilization（Synthesized，已含LUT combining）给2139515 LUT，器件1303680，用户完整kernel预算900000。层级表本层直接逻辑1946767 LUT、dot_array137962、format54786，精确相加为core总量；本层直接逻辑已超器件，不把主因误归为DSP点积子树。当前综合态资源不通过，最终opt/物理变化仍待实际测量；原30层功能结果不变。这是实质资源出口，不能只报“最终fit尚未取得”。

主控采纳A014集中判断，先完成正在运行的AT020报告；A010仅对轻量serial PID/start核验后定点持留，保留AT020 guard/Vivado/无deadline监督，避免自动进入facade。原serial没有热gate，允许其单PID SIGSTOP，不动进程组/当前guard；持留单列证据，旧state不冒称新状态。AT020真实结束和锁释放后由A010依实际handler执行安全退出/回收旧serial，不能盲CONT导致自动启动全父阶段。普通运行脚本修改在A010 owner内连续实施，不要求用户逐项批准。

下一唯一实验由A010沿原E022/R001新attempt实施：输入只读core_synth.dcp，SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90；在新工作目录open_checkpoint后一次常规opt_design，候选DCP另存，保存实际命令、日志、身份与收据。不重跑综合/功能验证，不改RTL/数值/形状/接口、器件或300MHz约束；不加dummy tieoff、set_case_analysis、裁剪端口/cone、删保留属性等制造面积收益。完整core边界、端口/时钟/约束前后对应及零黑盒须核验。

一次优化前后使用同口径utilization/hierarchical/ram报告，记录本层primitive数量和有界网表名称/原源对象分组，定位本层直接逻辑中的实际占比；不从BRAM=0/大量FF或MUX直接推断具体buffer根因。读取/报告避免导出整个巨大网表。允许将不同已授权物理操作拆为独立stage/报告，以保留中间DCP及准确成本；opt_design本身仅一次，不自动重复尝试不同directive。

沿用户取消墙钟限制的同D38 implementation/reports类别执行，所有费用照实累计；单重工具锁、256GiB owned RSS、系统MemAvailable>192GiB、CPU0–3/nice19/idle、原真正停滞保护保持。当前工具不中止，旧费用/失败/DCP/恢复证据不改，无新增用户资源要求。

优化后若core LUT仍>1303680，候选core仍超器件，不启动place/route作无依据尝试；若<=器件但>900000，仍违反完整kernel预算，转集中架构/映射判断。即使<=900000，也只满足必要条件，需给其余父模块资源留量并审查完整链接，不能代签full-top fit或300MHz。该诊断结束立即集中审核实际结果再下达后继；不得自行改变存储容量/并发/延迟/数值来消除超额。完整top资源与P&R目标仍有效，按此依赖有因重排，旧无deadline授权保持。
