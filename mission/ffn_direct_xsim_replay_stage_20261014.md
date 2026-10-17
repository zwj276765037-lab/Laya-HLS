# FFN2：隔离复用编译产物，直接xsim前缀与有据回放

D-M004-FFN-DIRECT-XSIM-REPLAY-01；2026-10-14；M004/SM005/E005/R001。依据[FFN1集中审核](../results/measurement_first_FFN1_review_20261014.md)。A002唯一实现/工具owner，A001集中验收。按既有测量优先授权连续完成本合同，不逐步请求批准。新阶段NOT_RUN；FFN1旧准备修正已结束、full未启动。

## 唯一受影响范围

选择AT059已完成elaborate的 `ffn0_chain_tb_v1_behav` 编译snapshot作为运行包来源，AT058同源码static/适配器/目的wrapper短测及AT059微测试/host结果按原身份复用。只允许新launcher、运行包清单、verify-only闸口、实际命令/cwd/输出隔离及冷xsim控制Tcl。功能DUT、联合TB（含35分项观察与固定目的断言）、guard/parser、生成叶子/IP配置/ROM、独立gold/fixture、任务模型/Ref/BO、正常驱动/反压全部按AT059冻结保持；不加功能或被动RTL修复。

本阶段不运行Vivado compile/elaborate、HLS/OOC/P&R，不重新生成IP。snapshot不可重用、运行依赖不明确或需改变DUT/TB/guard时，保存证据并交付，不切换隐藏候选或扩大帽。旧AT058/059的输入、工作目录、日志/收据不写回。

## 运行包和启动闸口

1. 在新AT目录冻结实际launcher、Tcl、完整源码manifest及snapshot运行依赖清单。不能只核xsimk：列出选定snapshot的二进制/内存/重定位/库/配置等实际依赖和工具版本、来源、bytes/SHA；动态输出与只读依赖区分。核AT058静态闭包与AT059联合源码/观察器一致，微TB改名不影响联合snapshot。缺少完整来源时先停止，不靠存在xsim.dir目录准入。
2. 将所需运行依赖复制到新尝试的隔离运行目录，逐SHA核副本。旧目录和输入只作只读来源；符号链接若会让xsim写回旧目录则不得用。prefix和full各自用原始编译snapshot的独立工作副本与新进程，均从初始reset冷启动。禁止使用前缀运行内存、checkpoint或中间A/W结果续跑。新目录无法支持现有snapshot时交付该证据，本合同不授权重编译。
3. 每次真正spawn前核新实际cwd、完整冻结清单、编译产物身份、7 ROM目标、63 fixture引用/实际文件集合和命令本身的11个fixture plusarg；FIXTURE必须与LN_FIXTURE完全同源。prefix另有PREFIX=1，full必须去掉PREFIX及任何提前结束模式。冻结候选命令和最终实际命令的差异；不得让抽象roots正确而实际命令漏参。新preflight必须早于本次spawn，旧停止后ACCEPT只作背景证据。
4. launcher在同一受控路径执行verify-only并根据结果决定spawn；用临时副本验证完整包可准入、缺ROM、错SHA及缺snapshot依赖都会在spawn前拒绝。保存真实返回码与spawned=false；不能通过只写字段证明未启动。完整源码/数据hash检查与复制属于独立有帽host准备，避免塞进120s重新做EDA编译；临近spawn仍复核可变运行副本/命令身份。host≤8GiB/120s，实际policy/内存无样本写UNKNOWN。

## 一次前缀与full准入

完成上述准备和静态命令检查后，至多启动一次≤120s、≤8GiB的直接xsim冷前缀；沿用AT057冻结prefix Tcl的run70us和TB的真实首LN AR/64R结束条件，不改TB/激励来缩短。记录实际xsim进程、SIM_START、LN AR/R、观察器分项、原PREFIX_PASS/$finish和无Fatal/ERROR，guard无触发；仅xsim正常退出但未达目标不算PASS。前缀的LN迭代及其他分项按实际值报告，不假设已到W/G/残差。短测guard中的simulation_started模式标志与真正执行记录分开，新联合前缀必须进入原SIM_START语义计时模式。

分别记录准备/verify/spawn、模拟开始与达到前缀目标的墙钟，cycles/AR/R、RSS、实际CPU0–3/nice19/idle样本。2048cycle打印间隔须结合本次速率确认能在120s内反映真实事件；不改observer或提高semantic帽。正常进展计数与独立事务计数交叉核对。

前缀合格后才写带时间的full成本决定。用本次速率/启动固定成本、AT057实际LN/W工作及旧AT049/AT054注明身份的阶段工作量，分开列出未测Wi/G/Down/残差、观察开销与保守余量；最初1AR/64R速率不能直接代表所有后段。旧3536.346s估计、旧两段cycles/墙钟相加和当前编译耗时均不自动构成新上界。估计可信落在3600s/8GiB/40Mcycles才admit=true并启动；证据不足或超帽记COST_NOT_ADMITTED并交付，不等硬超时替代准入。

full至多一次，使用新进程/新运行副本、完整四行原正常profile，Tcl允许运行到原终态，并保留40Mcycle及墙钟/semantic守卫。完整复走LN→Q→Wi→G→Q→Down→residual，仅初始reset。启动前再次preflight，不复用前缀状态；full必须先有本次准入决定和一次性启动记录，不换AT绕过限制。

## 上界、出口与交付

一个launcher方案；在首次实际xsim前最多一次有因纯准备/脚本纠正，不增加DUT/TB/guard修正额度。实际前缀一旦失败/超帽即交付，不在本合同重启；full一旦启动，任何失败/COST_STOP或自然结束均结束本阶段，不追加第二次full。未使用额度不自动滚入后继。普通准备步骤在合同内连续执行。

成功出口继承[FFN0原合同](ffn_single_runtime_stage_20261014.md)、[FFN1进展合同](ffn_progress_replay_stage_20261014.md)及[A1入口澄清](../results/measurement_first_FFN1_destination_clarification_20261014.md)：原独立gold，同skip与刚写STATE1 TMP重读，完整身份/Ref/真实DUT退休门控，末B/lease/债务排空、固定HIDDEN实际受理/写回，七拍响应及一次消费，655360B本地保护、整链周期/互斥阶段和加法分布。新guard与独立事务/原日志对照；过AT057停止点或仅有CHAIN_PASS文字不足以替代全部检查。

报告同时保留失败前缀、复用证据来源、两次冷运行区别、完整运行包身份、所有guard/原日志/实际命令/成本先后及未测范围。A002写唯一E002/experiment实现和模块design/results，E005/R001新AT证据及三摘要/A002真实状态，阶段终态直接交主控。原单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB、RTL≤8GiB/3600s/40Mcycles、prefix≤120s、semantic stall120s保持；无新agent/参考/HLS/OOC/P&R/上板，G2338.224019s只为OOC余额、5172s组合不重启。

普通Q/L生产控制及整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排。外部attention residual、生产双源lease、完整BO/13BO、全模型/恢复、联合资源/物理时序及M003/M004继续开放；局部链通过不等于最终目标完成。
