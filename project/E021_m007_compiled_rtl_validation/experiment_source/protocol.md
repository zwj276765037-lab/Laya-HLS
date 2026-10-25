# E021 — D33同源码编译式RTL交叉验证

授权合同为SM012 D33。A012只写E002/experiment/tools/m007_verilator及E021证据；A010原父/TB/按需peer、A007共享RTL各自唯一owner。无生产数学叶子复制或替换，无DPI/C行为模型。旧M004/M006暂停。

工具固定为用户目录Verilator5.020，包、可执行文件和引导身份见R001/isolated_tool_bootstrap.json。每条命令仅设置VERILATOR_ROOT，执行--cc --main --exe --timing --assert -O3 -Wno-fatal；C++ make默认OPT_FAST=-O2、OPT_SLOW=-O1、-j4。完整实际argv保存在每stage command JSON。小模块输出拆分10000语句/200函数语句；父候选5000/100，实际flags另录。

独立期望：不运行新参考，直接复用E008原native IEEE binary32 ADDSS/MULSS/DIVSS的固定fixture和原TB；原FTZ/DAZ关闭、RNE身份保留。有限输入全fixture含subnormal、normal边界、half-ULP/carry/cancellation、正负零和输出overflow；这些fixture没有NaN/Infinity输入，DIV没有零除数，因此不签所有非有限输入排列。原8/8/32拍、II1、CE保持/36停拍、reset真实在途丢3及后继45条断言原样。

当前shared4与E010/R003/AT031五源逐字一致，完整租约/请求与响应身份、错误epoch拒绝、64信用、满拒绝14拍、独立MUL/ADD、holding、release禁止root/允许dependent drain、外部债、reset与active-lease空channel CE均执行。另保留E008旧冻结闭包AT005独立结果。

父正常前缀复用原完整kind5 checker和全部原输入；同源码XSim基线由A010冻结。所有M007_与HARDWARE_AGENT_SIM_PASS语义行必须非空、保留顺序/周期/握手/检查数。跨owned目录只对M007_ACTUAL_PUBLIC_CAPTURE中已登记EXPORT绝对路径字段作显式映射，raw轨迹和raw精确结果仍保存，其余字段不归一化。父数学和全图尚不能由叶子结果代签。

资源：唯一.research-agent/m007_heavy.lock覆盖全部guard和owned后代；CPU0–3/nice19/idle、MemAvailable>192GiB，static24GiB/RTL8GiB、40Mcycle、未知阶段≤120s、真实语义停滞120s。R001独立reference0/static1800/RTL1800/OOC0秒，RTL留300s。首阶段复用原production_guard，瞬态未采到的PID身份按UNKNOWN记录；后续父改只读调用原m007_parent_guard_v2，按实际PID/start_ticks采样，不以继承补证据。

保留每attempt源/fixture/tool SHA、exact flags、全部warning/error、translate/build/RTL分别归档。失败翻译残留C++或中止对象不当完整构建。runner变动前按原SHA保存真实字节，绑定旧manifest；新AT自动保存frozen_runner.py。Verilator二态不能替代XSim四态/X传播/未初始化证据。禁止OOC/P&R/GPU/板测或其它依赖安装。


## D37 / R005：修复版原30层一次BEGIN（A013）

唯一执行范围见SM012 D-M007-SM012-FIXED-ORIGINAL30-37。生产父9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6、共同TB2bd73c51255634e190b0b1c288ccd7150852f555c229218a755d7989fa734f2a及94源闭包均只读。新展开显式-GVERIFY_POST_ENCODER27_H=0，kind7/local0、无POST_ENCODER27_H/STOP；实际初始H仅原initial_H/embedding_norm。原完整checker/gold/shape/严格算术不变；后继全部真实RTL计算。所有模型TU fresh，只有原成功fixed-batch runtime按SHA复用；后端5.020+fixed-batch-v1/converge512、model1/context1。

使用fixed30_prepare/static/derive_main/complete_build/driver/launch_r005.py，实际命令分别保存在AT001/AT002。主控授权唯一完整RTL运行≤15000s、RTL15600保留600、static1800，逐层600、连续段/真实stall120、40Mcycle。Encoder27→finalLN→type→Decision0preLN为一个120s整段，最后Decision1→tail/DONE/idle一个120s段。CPU0–3/nice19/idle、MemAvailable>192GiB、static24GiB/RTL8GiB、全项目单锁；不自动重试/加帽。

原generic main逐层真实H采集保留；新增只读低沿快照，次posedge核原计数与实际Q plane0/hidden银行逐lane相同，对finalLN/type各4096唯一地址保存524288B及独立trace。不增加eval、不驱动DUT。最终重核30H、finalLN/type、69632B原tail544、原120矩阵/480head/60LN/61VECTOR/28G、两FC1各16384实际组写ACK发布后FC2、真实commit/heldDONE消费/idle/rc0。两态及已知调度局限保留；不作OOC/时序/上板结论。运行完成后证据核验/封账/owned清理并暂停。
