# 首请求宽FIFO区分实验与program修复审核

审核：R-SM003-EXECUTOR-WIDE-FIFO-PROGRAM-REPAIR-20261013。
回复 executor-first-wide-fifo-program-repair-progress-20261013。M003/SM003/E003/R003，A002唯一实现整合，原授权内连续推进。

## 本轮接纳范围

1. 接纳 `executor_wide_fifo_diagnostic_01` 的限定生成事实。实际三输出/两输入8192bit、15根FIFO信号及clock/reset方向宽度逐项核实；6份1024B实际host capture与独立gold逐字相同。HLS为38.071846s、peak2372468KiB、189次RSS，child0/trigger null；242项生成产物引用匹配。这足以否定“这五个宽口的方向和宽度组合单独必然导致原停止”，不能排除它们与actor状态/对象传递/调用图的交互。完整executor_01/_02仍COST_STOP、无RTL；微top生成RTL反压未测，无生产准入/退休权威。

2. 接纳 `graph_program_owned_host_07` 十个独立process的所测主机范围。冻结源码对比确认 `validate_fields` 的原校验体仅将实际purpose改为标量参数，caller传 `r.purpose`；其它校验体逐字保持，外层handoff协议源码与host05一致。新增purpose0/2/65535、direct/nested及物理span/model负例和decode拒绝清输出有原始marker。它们仍是无界软件stream/主机证据。

3. `graph_program_owned_rtl_02` 原动态FAIL保持。已核原生成validate_3从 `m_q0[15:0]` 取purpose并与1比较；完整对象的预期位置及gdce→a.g.0定位由A004报告支持，主控本次未重新运行LLVM pass分析。接纳“当前生成逻辑字段读取错误”的具体定位，不宣称精确AMD pass根因已定；canonical equality未执行仍不可记PASS。

4. 接纳 `executor_source_guard_v2_rtl_02` 六例/3214cycles有限RTL范围，实际shell/control transport及所测旧读债/F9/LAC尾拍消费保持。DUT未变；相对_01的变更有两项：TB将string三元实参改等价literal分支，runner增强FATAL_ERROR/kernel异常识别与失败归类。不是仅metadata变化，也没有删断言。原_01异常FAIL保留；producer/query/fence受控、有限AR及无完整tensor/same-runtime LN的限制保持。

## 下一出口与实施判断

purpose显式标量修复属于原授权内普通综合修复，可继续，不增加逐项审批。HLS05的399项冻结闭包已与host07核对相同；本轮观察时收据仍为运行前准备状态，工程已报告实际启动，尚不核定生成或行为PASS。新生成后继续严格8FIFO/24信号检查，并在真实depth2有限RTL中证明合法kind4/purpose1通过嵌套校验、实际canonical全字节比较与原成功路径可达。至少用同一真实owner输入路径加入一个不支持purpose的负例，确认修复不是把purpose常量化；复用现有限例和原帽，不启动完整恢复矩阵。

共享bootstrap改变使旧executor_host04不能预验证live新候选。按原顺序补受影响host、冻结一致后再做有依据的executor生成/区分定位。宽口单独解释已被排除，下一诊断应针对完整actor可达状态/对象传递等剩余假设；不原样第三次重启、不扩大120s保护，不以仅减累计IR数量声称硬件优化。

旧LTX沿 D-M003-EXECUTOR-OLD-LTX-CLEANUP-01继续：真实FSM完整pending+A/K/route、最多单个24拍候选；撤销后首END/INVALIDATE仍需真实adapter/hub验证。普通确实从未对外呈现者由实际adapter产生原LOCAL_REJECT，不能带REMOTE_DRAINED；已呈现帧保持旧归属和真实完成。当前“END首pop后撤销”的sidecar证据不代签“撤销后首END”。C完整NORM测量先行，D/Q及完整CLOSED/rearm后置，必要旧债务进展仍为前置。

## 身份与资源边界

本轮独立核342+399+47=788组frozen/声明配对，审核时current全部匹配；1946项非original递归SHA/字节引用匹配。23段guard均child0/trigger null，79条实际policy为CPU0–3/nice19/idle I/O，原内存/墙钟/120s保护及MemAvailable门保持。12短段无owned-child RSS；另wide oracle虽有一次RSS却无child policy记录，均按实测分别记载，不能由配置补造观测。没有主控DUT工具执行。

核验：[verification.json](executor_wide_fifo_program_repair_review_20261013/verification.json)；冻结证据快照与审核脚本同目录。原有限PASS/FAIL及生成_04事实不回写。C009/C013部分实施，C008/C010待验；C/D周期NOT_RUN、M003/M004未完成。单重工具与所有分类帽、G2338.224019s仅OOC余额保持，无新增OOC/P&R/上板/预算，5172s组合不重启。
