# E017/R001实际方案

Authority：mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md末节D-M007-SM011-SFU-RESOURCE-12。A007唯一写新测量TB/Tcl/runner、模块source增量与E017。既有EXP生成源及当前生产依赖只读。

## 平台与身份

工具为服务器已装Vivado2025.2，part xcu55c-fsvh2892-2L-e。每AT冻结源码/TB/runner/guard/输入/XDC/Tcl，记录SHA256、命令、主机、guard起止/退出、实际资源/策略；不复用旧预算。

## 整数helper验证

原生成helper默认14×12/26位；本次明确覆盖din0_WIDTH=32,din1_WIDTH=32,dout_WIDTH=50/64，保持NUM_STAGE原默认。独立Python精确无符号整数乘法产生64位乘积gold，50位比较gold[49:0]。固定边界交叉、每位及其邻值、全1/高位模式与固定seed样本，不宣称全域证明。RTL每拍更换连续输入，有限CE停顿并改变停顿期间输入；有有效payload后测试reset+CE0保持及reset+CE1更新。原helper没有有效位且reset未使用，不要求清零。核捕获一有效时钟沿与连续II1。

先独立reference AT，再build/static AT及RTL AT，保留所有失败。新AT不能覆盖旧目录。单次未知<=120s。

## OOC

两个helper分别对原top用synth_design -generic设真实32×32/50或64，-mode out_of_context，flatten_hierarchy none。read_xdc包含3.333333ns时钟、0.100ns uncertainty、除clk全部输入0.500ns延迟与全部输出0.500ns延迟；setup/hold报告分开，report_unconstrained与check_timing保留。synth+opt，无P&R。要求零blackbox，保留DCP与EDIF及真实DSP/LUT/FF利用率，不能把名义资源乘为联合fit。

## 后续F64mul

在helper真实测量后仅六文件最小闭包做显式底向上DCP链接；记录实际实例及子DCP SHA。首pilot<=120s，成本出口不能原样延帽。复用冻结独立binary64参考，缺失时仅生成本helper范围并计reference。核原合法输入域/输出/16拍/II1及CE/reset，不能改FTZ或近似。

## 成本与停止

reference120/static600/RTL600/OOC900秒；reference16GiB/static-OOC24GiB/RTL8GiB，RTL40Mcycles；全后代m007_heavy.lock、CPU0-3/nice19/idle/MemAvailable>192GiB，真实语义停滞120s。无mtime或任意心跳续期。锁等待不记实际执行费用；预算按guard真实墙钟计所有成功/失败/COST_STOP。不得P&R/板卡/GPU/安装/全阵列OOC。

普通脚本和编译修复按合同连续执行，实质架构/数值/接口或预算变更上报主控。第一真实helper映射、成本出口和最终完成立即报告。

## 真实阶段调整：AT011成本出口后的复用

AT011120.223383s COST_STOP，child DCP open/export实际27+14s已完成，父stub综合未完成。A001据实际证据授权原E017余额内拆分：冻结原child EDIF/hash；AT012只parent-stub synth<=120s并保存真实stub DCP/EDIF；只有真实产出后AT013 link/opt/report<=120s。无child重开/无原样延帽；若parent-only再次超时无checkpoint，本段结束于成本出口。原全项目锁/资源/真实语义120s保护与总预算保持。完整四boundary、实际DCP/EDIF SHA、零blackbox/完整IO保持。

## 已执行终态

AT012 parent-only120.264021s COST_STOP，最后完成XDC应用（synth elapsed101s），到Start Technology Mapping，无parent DCP/EDIF；AT013未创建。按A001明确停止条件结束本段，不再EDA。功能/资源边界与费用见R001/final_delivery.json；requested周期3.333333ns被Vivado按1ps粒度实际取3.333ns。
