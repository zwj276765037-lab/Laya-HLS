# FFN4：分离 Wi DDR 与 Down STATE1 描述符后有据回放

D-M004-FFN-WI-DESCRIPTOR-REPLAY-01；2026-10-14；M004/SM005/E005/R001。依据[FFN3审核](../results/measurement_first_FFN3_review_20261014.md)。A002为唯一实现、TB与工具owner，A001集中验收。FFN3唯一full已结束且失败记录不改；本合同新结果NOT_RUN，按既有授权连续执行，无需逐步申请普通修正。

## 唯一修正及存储身份

选择一个受影响的TB接线修正：Wi reader不能再从已切换为Down的`cfg_bo_base[0]/cfg_bo_span[0]`取得BO描述符。保留原reader RTL及其全部`command_ok`校验，不放宽范围判断，也不通过推迟Down配置来掩盖描述符共享。

| 对象 | 固定BO和区域 | 使用约束 |
| --- | --- | --- |
| Wi writer及Wi reader | DDR BO `0x100000000`/`0x2000000`；Wi region `0x100001000`/`0x1000000`；row/batch stride `20992/21495808` | 使用同一份稳定的TB声明；在Wi实际cfg受理边沿保存/检查writer所收值，reader受理时逐字段比对此绑定。四行实际有效数据83968B，不能把声明的整个region当作已分配/已写。 |
| Down writer及退休适配器 | STATE1 BO `0x310000000`/16919104B；TMP region `0x310800000`/8388608B；row/batch stride `4096/4194304`；TMP bank0/epoch1 | 保留实际Down claim时的原身份、Ref、物理绑定，不能为修Wi而把Down恢复到诊断DDR。 |
| 末残差 | 原同一skip源、真实刚写的STATE1 TMP；固定HIDDEN bank1/epoch2、地址STATE1+0 | 继承原DUT退休门控、描述符及固定目的合同，不增加生产接口或owner授权。 |

允许修改联合TB的Wi描述符声明/连接和Wi、Down实际接受边沿的被动断言/打印，新增受影响短TB与对应runner/清单。可用共享TB include/函数保证短测和联合TB采用同一绑定。检查reader所有输入的来源：numeric identity、G context/op0x60/stage2、WI Ref、窗口、跨度/stride/对齐与溢出检查逐项列明；完整Context、Ref、正常时序和数据保持原样。若发现另一项必须改变功能身份、DUT或协议的缺陷，停止并交付，不暗中纳入本修正。

AT059/AT062的功能DUT（reader、LN/source、quant/dualA/G、resident/strict W、owner ledger、Down→residual适配器、残差/FADD槽和生成叶子）、35分项观察器、guard/parser、模型/shape/request/generation、独立gold/fixture、存储数组/written/AXI响应及正常反压保持身份。不可复制Wi/Down gold回灌联合源，不取消断言。普通Q/L、生产控制及完整恢复仍停排。

## 短测与新编译准入

先冻结受影响源码diff及新清单，逐项列出相对AT059/AT062变化和不变身份。TB接线变化必须重新compile/elaborate，不得拿旧snapshot运行后宣称修正已验证。允许在新项目中按原脚本重建相同配置的仿真IP产物，记录实际生成身份及参数等价；不改变IP版本/数值/流水配置，不运行HLS、OOC或P&R。生成LN核/ROM及残差加法叶子内容保持。

在新编译snapshot基础上执行一组有限reader定向短测，实例化相同冻结reader，不force输出/内部状态：

1. 用实际输入重现旧组合：Wi DDR region配STATE1 BO，真实cfg握手后拒绝，零AR/R、无流输出、无读债；保留独立预期拒绝标记。
2. 合法Wi描述符下，先将共享矩阵槽切到Down STATE1/TMP，再受理reader；reader仍使用已绑定的Wi DDR描述符。四行实际AXI读取1312R并产生20992个F32，对原独立Wi fixture逐bit；逐地址核AR、4KiB burst边界/末R、行索引与完整四行终态，末读债归零。至少一次R和流输出/行终态等待，核有效数据与身份保持和一次消费。
3. 被动检查联合接线及Down claim，证明修正只隔离Wi描述符、未使Down落回DDR。短测用外部预装Wi数据仅证明reader/接线局部行为；真正Wi producer写入同一DDR后读取仍由full证明。

一个方案，static/短测阶段允许至多两轮有因受影响修正，逐版保留失败与diff；不因普通拼写/runner错误逐条请主控批准。每轮static≤24GiB/1800s，定向动态短测≤8GiB/120s；至多三轮static/短测（首次加两修正）。纯host准备/冻结/依赖/闸口在本阶段累计实际执行≤120s/8GiB内连续修普通错误，不能换AT重置；编辑和等待不计入，执行原输出/返回码与预算累计保留。资源无采样写UNKNOWN，实际CPU/nice/I/O检查不可只写计划值。

## 运行包、一次冷前缀与成本决定

复用AT062已验证的类型感知launcher方法和同SHA guard/parser，仅适配新编译包、支持文件路径与身份。原262项是旧包数量，不强制新包同数量：需完整列出新增/变化/删除原因，冻结真实二进制/内存/reloc/配置、脚本解释器/source链、ELF依赖与实际解析环境。7 ROM、63 fixture与11个实际fixture plusarg保持，`FIXTURE=LN_FIXTURE`。输出日志、WDB及调试临时文件与只读依赖分别列明。

每次spawn前，同一launcher重新核真实cwd、命令、运行副本及数据身份；以临时副本执行完整包对照及缺/坏ROM、缺reloc、错ELF/库身份的五项拒绝，保留真实返回码和到spawn前的拒绝路径。prefix与full分别从新编译原始包复制到隔离目录、新进程、初始reset；禁止续用prefix内存或旧运行状态。各次源/输入身份前后核验，晚期加载的证据只按实际观测范围报告。

static和短测合格后，至多一次≤120s的直接xsim冷前缀，沿用原70us/首LN 1AR、64R目标，不能再把冷编译塞进pilot帽。须真实SIM_START、事件分项、PREFIX_PASS、自然结束且无Fatal/ERROR/guard触发。单独记录准备、preflight、spawn、模拟开始及目标到达时间、真实cycles/AR/R、RSS和policy。该前缀若失败或超帽即阶段停止，不重启前缀。

full启动前保存新的成本决定：

- 用本轮新编译包的冷前缀确定启动成本和LN速率；以AT062真实1696.153932s及已达到的Wi完成边沿作为到Wi阶段的证据，注明其中含启动与失败尾段、不能精确拆分。
- 按不重叠区间分别列出尚未测的Wi reader/G/第二Q/Down、残差及终扫/观察开销。旧AT049后段及AT054残差可提供明确身份下的工作量估计，不能把历史整段墙钟或两段周期相加当新链实测；不得重复计入已完成Wi前缀。
- 说明本次与旧运行的速率差异、同runtime新增存储/观察成本及保守余量。最初1AR/64R速率不能直接代表全部后段，旧500000cycles/5%余量/3536.346s不得自动沿用。估计有据落在3600s/8GiB/40Mcycles内才可`admit=true`；证据不足/超帽记COST_NOT_ADMITTED并交付。

仅准入后至多一次四行冷full。启动一次即用尽本合同full额度；任何Fatal/失败/COST_STOP或自然终态均交付，不追加第二次，不换AT绕过上界。

## 验收与不变上界

继承[FFN0](ffn_single_runtime_stage_20261014.md)、[FFN1](ffn_progress_replay_stage_20261014.md)、[固定目的澄清](../results/measurement_first_FFN1_destination_clarification_20261014.md)和[FFN2回放出口](ffn_direct_xsim_replay_stage_20261014.md)：同runtime且仅初始reset，LN→Q→Wi→G→Q→Down→residual；Wi reader从刚写DDR读取，Down实写STATE1 TMP后残差从同skip/该TMP重读；完整独立gold、真实末B/债务/lease/退休门控、固定HIDDEN受理写回、七拍响应与一次消费、655360B局部保护、整链周期/互斥阶段/加法分布。需出现原CHAIN_PASS并核所有底层条件，无Fatal/ERROR；child0或过Wi拒绝点均不足以代签。

周期按posedge预NBA/发布后NBA口径明确区分实际消费、完成标记与正常终扫；guard周期快照不冒作最终事务总数。短测及full分别报告，不将旧AT049与AT054拼成联合PASS。

单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；full≤8GiB/3600s/40Mcycles、真实semantic stall120s，static和host帽如上。无新agent/参考重算/HLS/OOC/P&R/上板，G2338.224019s仅旧OOC余额，5172s组合不重启。唯一实现根E002/experiment；A002维护相关design/results、E005三摘要和真实状态后直接交付。

外部Attention residual、真实生产双源lease、普通Q/L多窗口、完整STATE0/1及13BO、全模型/恢复、联合资源/物理时序仍未闭合；M003/M004保持开放。
