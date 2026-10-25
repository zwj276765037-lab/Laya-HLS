# E021：同源码编译式RTL交叉验证

任务M007/SM012 D33，工程A012。生产RTL、原TB、原gold只读。唯一runner目录E002/experiment/tools/m007_verilator。隔离Verilator5.020原安装与系统环境未改；临时运行库修复另存为runtime_fixed_batch_v1/verilated_timing.cpp，保存stock原字节/SHA和明确patched身份。

原owner的临时1D ROM加载及残差scalar→group32无损pack保持原比特；独立整数审计4096组/131072lane完全等于原attention_residual.bin。当前父93源与172d3019…5d555冻结TB不变。

stock runtime遍历并清空恢复中的同一零延迟vector，原EXP连续#0 8×168小例raw SIGSEGV。local fixed-batch仅swap待恢复batch，后续#0留到下一同tick组合求值；不删RTL delay、不做runtime while批量排尽。原168等待实际触发default100收敛上限，显式--converge-limit512。混合clock/reset/反值初始化小例同源SHA0e22986a…bebcc4与XSim13条事件逐字相同；8组全部168赋值tick0完成，250ps全值/500ps首clock/2750ps终点通过。原header承认#0 before-combinational的不完整调度；不能泛称完整SV #0等价。

该runtime再次通过原严格ADD/MUL/DIV和当前shared4完整fixture、原XSim全部语义行。父512新翻译4生成头全同，744cpp中742全同；2TU仅三处收敛常量100→512，742原成功对象按SHA复用。原PCH/O2-fast/O1-slow与MMD传递依赖、实际flags绑定，只编2TU+1patched runtime并新archive/newexe，原对象/archive不动。

固定单重工具锁/CPU0–3/nice19/idle/MemAvailable>192GiB；static24GiB、RTL8GiB/40Mcycle。未知阶段≤120s、语义停滞120s；R001独立static1800/RTL1800、RTL留300，reference0/OOC0。两态证据不替代XSim四态、X传播和未初始化检查。
