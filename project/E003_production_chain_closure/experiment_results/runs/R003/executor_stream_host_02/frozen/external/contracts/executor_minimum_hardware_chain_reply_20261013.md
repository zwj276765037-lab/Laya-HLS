# 首请求硬件基线的实施顺序确认

消息：executor-minimum-hardware-chain-review-20261013；回复 executor-minimum-hardware-chain-answer-20261013。
决定：D-M003-FIRST-HARDWARE-BASELINE-01。M003/SM003/E003/R003；A002负责实现与整合。

接受A→B→C→D关键路径，按原授权立即以首请求真实计算和可复现周期基线为近期出口，不将完整跨request恢复列为首次测量的无条件前置。此决定调整实施顺序，不降低M003/M004最终验收标准，也不新增通用控制框架。

## 阶段出口和估时口径

| 阶段 | 必须交付的可见出口 | 工程粗估 |
| --- | --- | --- |
| A | 有界executor入口及新冻结闭包；实际FIRST准入/A、完整控制consumer、实际helper导入授权；受影响host/oracle | 2–4小时 |
| B | executor生成RTL及真实端口/消费接口；接口确需变化时重生成program，保留候选身份及资源估计 | 1–3小时 |
| C | 同runtime program→executor→F10/adapter→LN/monitor/唯一hub→真实END/唯一退休，完整声明工作量的数值对照与首个LN周期/等待/AXI基线 | 2–4小时 |
| D | 由实际program或原合同内真实sequencer发起Q，真实lease/AR/读债/释放和gold；形成首条含Q基线，转入该链的测量驱动优化 | 2–4小时 |

A/B约3–7工程小时，C累计粗估5–11工程小时，D累计7–15工程小时。仅作为当前任务分解的工作量区间，不是墙钟倒计时、日期承诺或成功上界；executor尚无成功生成样本，失败、接口不兼容或pilot成本变化后按实际证据重估。无需等D或完整恢复才报告C的真实计算测量。

进度报告围绕这些出口说明已完成项、剩余关键依赖和估时变化。A/B/C/D普通实现与受影响验证连续推进，不新增逐项审批；如果某项异常恢复被发现确实阻塞首次安全计算，指出具体代码/合同依赖，而非整体回退为“先完善全部控制链”。

## 首次测量仍必需的正确性

真实请求/模型/物理绑定、完整A/K、HOLD→完整LBR2→实际helper提交→匹配GRANT、持续撤销启动门、source已接入入口保护、旧半帧/返回/END与真实读写债务、两层末拍消费和唯一退休保持原合同。Q必须由实际硬件控制发起，不能以TB send_q作为整链出口。不得用常量或受控TB信号代签真实consumer、adapter pending/fence。

基线明确冻结输入shape、目标范围及窗口数。声称完成的目标必须有全部对应实际写入/END/发布与gold，不能用一行短提交代签完整tensor；若前序source仍来自受控真实writer，注明来源，不称已完成encoder或完整模型。数值正确后才将周期作为有效性能样本。

no-LGP/committed ABORT完整错误结果矩阵、CLOSED接全、新accepted-request/rearm可按工程答复后置。测量中若触发未完成错误出口，终止该样本、保留完整A/K/commit/下界并隔离，禁止第二请求；旧物理债务和已接受帧不能因此被丢弃或堵死。它不是已完成的错误请求。

成功计算测量后可以保持旧请求/锁等待，不释放A、不进入下一请求。缺真实Host/安全事实/CLOSED完整消费时，不签“生产请求安全关闭”。完整错误结果与第二请求义务仍在原CLOSE/rearm合同，未执行路径明确待验。

## 复用身份和预算核定

主控重核三manifest的files配对34/33/30，共97项；另program外部合同1项，完整口径98项冻结均匹配。三生成top SHA一致，files current漂移6/5/7与盘点相同；旧artifact只按明确冻结接口复用，不能给当前所有源码挂旧PASS。adapter_hls_03原receipt FAIL及后续端口纠正/RTL审核分别保留。

引用措辞请明确：rows16→Q/fullA完整gold来自`layernorm_quant_source_03`冻结full PASS；`layernorm_quant_source_04`的full为NOT_PLANNED_COMPATIBILITY_PILOT_ONLY，只实际做单行pilot与拒绝兼容。盘点中“quant_source_04旧冻结rows16”容易混淆来源，后续新计划/交付明确引用_03即可，不改旧attempt，不因此重跑无关full。

接受G2338.224019s是G累计OOC余额的更正。本轮HLS/RTL按各自原类别和逐次限制记账，不能从G余额扣作共享秒池，也不增加OOC/P&R授权。600–1800s仅为无返工条件下的工具规划参考，不是新增总预算或成功保证。单重工具及CPU0–3/nice19/idle I/O/MemAvailable>192GiB保持；HLS/static24GiB/1800s、120s真实停滞，pilot8GiB/120s及原RTL总帽/更严格入口帽保持。完整CPU/CSim仍沿原更严格限制。

C/D先交真实周期、FIFO等待、AXI计数及分模块HLS资源估计。联合LUT/FF/BRAM/DSP、物理时序和上板结论等待对应真实工具证据；测量驱动的本链调度/接口优化不自动扩展为新tile/更宽Q8、整体OOC/P&R或大规模扫参。5172s组合不重启。

[独立盘点核验](executor_minimum_hardware_chain_decision_20261013/verification.json)保存原始身份、合同和前像。本决定无新DUT运行、无新增实现PASS。C009/C013部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。
