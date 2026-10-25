# E014 / R001：D-M007-SM011-LN-05实验方案

## 真实来源、假设与基线

2026-10-21 A001实际followup授权，A008在E013冻结发布后接续。权威合同为
mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md的LN-05节。
唯一数值依据为冻结E002/experiment/tests/full_reference.py，SHA
fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784，layernorm_rows。
不恢复旧HLS/LQ1，旧RTL、模型、gold、E009/E013和其它owner文件只读。
A008只写layernorm_engine下laya_m007_*/m007_*及source增量和E014证据。

## 平台与输入身份

实际工具Vivado2025.2/xvlog/xelab/xsim；OOC目标xcu55c-fsvh2892-2L-e，300MHz为目标，
非已测结果。代码和输入每次AT独立快照/完整SHA；实际编译源取frozen路径，XSim运行前
保存实际xsim.dir库SHA清单，日志排除；生成控制文件与实际编译制品的变化分开。
原B1_from_b0_S128 encoder_00_out输入524288B/SHA9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b；
encoder_27_out524288B/SHA964be7a3b198234aa78643f9dda0d538af70f04a31b2a71b8b652f17710f9f38。
后者乘原GGUF final_norm_w，最终全128行必须等原final_norm.f32.bin，SHA
6501eb1ea077d04a36e3955a1f995afb215c2d862fcea1c78f6e2fc3be3b74ef。
原GGUF455179648B/SHA6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18；
原inventory SHA40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6，
gamma offset2059616/4096B另记录实际字节SHA，不由gold反推。

## 步骤、控制变量和独立期望

先独立参考/标量叶子，再共享银行/phase6受影响回归，再四行pilot与同版完整两模式S128。
32F32/拍三遍1024：相邻树sum/1024→mean；delta、square、相邻树square_sum/1024→variance；
F32(variance+EPS3727C5AC)、F32_RNE_sqrt、shared_div8 phase6 lane0的1/root；最后独立norm/gamma乘法。
所有F32步骤分别RNE，保留finite、variance非负、signedzero与渐进下溢，不用FMA/E[x²]-mean²/近似rsqrt。
独立`m007_ln_reference.py`调用原局部函数，另按原操作保存raw/delta/square/两树全部10级
节点、mean/variance/shifted/root/inverse/norm/output。完整最终gamma输出绑定原保存gold；不生成新全模型gold。
标量div1024覆盖每指数类/符号和下溢tie边界；sqrt用原NumPy、host sqrtf和整数中点判据三方核对，
seed20261021加实际stats。DUT与期望独立，不注入stats/inverse、force债或改期待值。

唯一只读sharedFP256/LNexp/div8原源，A007 phase6旁路sharedFP SHA
80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230。
phase6依赖add8拍、held落槽/满槽/reset及phase1/3受影响回归由E014实际测。
LN-exp实体256bank×32F32=32KiB，bank=(ctx*2+raw_or_delta)*32+element%32，address=element//32。
四ctx各8KiB raw+delta；gamma4KiB只一份既定系数区。纯engine公开端口，不复制payload或FP树。

生产验证入口`tb/m007_ln_engine_run.py`：`--stage build`冻结全部实际编译源，`--stage rtl --build ...`
复核当前/归档源与实际snapshot编译制品身份。`--rows 4`为未知成本pilot，成本支持后`--rows 128`分别
`--gamma 0/1`执行两组真实128行。`--stall 1 --rows 8`加入合法held输入、1800拍输出暂停及有限
FP/银行仲裁停顿，记录真实pending峰值，保持所有已接受操作数/数据/tag。mode0正常，mode1输入Inf，
mode3 finite正负max相邻抵消后square overflow，mode4 finite max在第1树第1级overflow；三个错误
只用作实际错误分类/排债诊断，实际观察失败至done≤128拍，随后不reset换generation完成正常四行，
不称原真实数值主例。mode2检查缺gamma/错model/旧generation并在
epsilon/FP真实在途共同reset，隔离40拍后新generation重新完成真实四行。normal trace逐位检查
两棵树全部2046节点/行、delta/square/norm/最终gamma、七个stats和真实银行读写；未层次读写payload。
`m007_ln_audit.py`按全部实际非阻塞赋值寄存器核对位账/唯一资源壳；不是综合资源报告。
小叶子OOC只使用`m007_ln_scalar_ooc.py`，两种标量分别综合/opt，3.333333ns时钟、0.1ns uncertainty、
所有非clock输入和全部输出0.5ns delay；检查blackbox/约束覆盖，综合后WNS不当P&R/Fmax或整LN时序。

## 指标、采集与结论规则

div1024≤16拍，精确sqrt≤32拍且仅一个pending/result槽；LN first row≤448、rowII≤128、
全S128命令/输入至最后输出和done退休≤16704；pass1/2/3≤128/256/64，树尾≤80，inverse≤32。
全部实测逐项分报，不以单行外推全流。metadata/tag/reduce holding等≤8192B，列实际位账。
覆盖身份/gamma缺失/坏数错误排债、有限input/output停顿、held不复用ctx、存储同ctx冲突与异ctx并行、
在途共同reset/newgen。功能/综合/P&R/上板分别报告；父全域首错、LN→Q→矩阵与全父共享另验。

## 资源、异常与阶段报告

独立reference900s、static1800s、RTL2400s、模块OOC900s，旧E013余额不转。
所有实际计算和EDA经m007_ln_guard.py，公共m007_heavy.lock直到整个child进程组终结；
CPU0–3/nice19/idle，MemAvailable>192GiB，reference16GiB/static-OOC24GiB/RTL8GiB。
AT018/proc退出竞态后，实际守卫使用Linux child-subreaper和PID start_ticks核实所属后代，正常路径
等待leader先退的孙进程，BaseException/采样/receipt写异常均在finally确认本次PGID及所属后代退出
后释放锁。`m007_ln_guard_selftest.py`先用真实短睡孙进程和受控异常验证；原失败/UNKNOWN墙钟保留，
budget_adjustments.json中的120s是独立保守扣账，不当实测。engine公开debt_clear还含active/done退休，
held done明确阻FP/div release；完整周期取实际done_valid/ready握手，包含测试额外5拍done保持。
当前保守单child≤120s；后续只有同版实际成本支持才按合同≤600s static/OOC、≤1200s RTL/40Mcycles，
仍受各总帽/120s语义停滞约束。仅管理本任务owned进程，等待锁不算计算成本。
小叶子/小bank OOC允许，全阵列/P&R/上板/新整模gold禁止。所有失败原样计费保留；
基础设施失败不反驳方法。阶段真实结果及时消息A001并更新三摘要/console，普通修复按既有授权连续进行。
