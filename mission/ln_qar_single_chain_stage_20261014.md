# LNQ0：单实例LN→Q→Wi→G→Q→Down有限同runtime连接

D-M004-LN-QAR-INTEGRATION-01；2026-10-14；M004/SM005/E005/R001。接续[LNQI0主控审核](../results/measurement_first_LNQI0_review_20261014.md)。A002唯一实现/工具owner，A001集中评判。工程按既有授权直接实施和有因修复；新联合RTL结果NOT_RUN。

## 目标与固定边界

以AT038独立enc0 attention residual前四行16384B为唯一声明外部激活源，在同一runtime、仅初始reset下完成：原baseline LN实际源读/算术/store→最后B/END/发布→真实source query/lease→后段唯一量化器/dualA epoch1→Wi→真实DDR/reader→G/GATE→同量化器/dualA epoch2→Down→最后B及实际完成消费。沿用独立LN/q/scale、Wi/G/Down/PS gold，不预装LN、Wi、GATE或预量化A中间数据。上游Attention/WO/residual硬件和末端FFN residual不在本有限窗口中。

保留AT040的83项LN baseline生成物、独立producer shell/monitor/hub；不实例化其自带Q/fullA的完整shell。后段以AT035为基线，仅一套quant_task、dualA、resident、strict dualW和KB1 writer，矩阵引擎分时Wi/Down。原缓存容量/算术核/错误语义保持，允许必要的有限接线、字段校验、单活动命令暂存及观测，不新增第二套算力、通用owner表或全局READY权威。新增持久字段按真实bit数单列，物理FF/LUT仍UNKNOWN。

数值请求固定3/1、B1/S128、batch0/row0四行；P=LN_FFN0x12/stage2/layer0，Q=QUANT0x20，Wi=0x32，G=GEGLU0x60，Down=0x33，LN gamma0/D1024/eps0x3727c5ac。LN源/gold分别保持AT038 SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`/`658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`。后段NumericIdentity使用同一canonical四tag；模型请求generation、portal单调generation、BO binding generation、A/W/Ref epoch各自保留语义，不能混成一个计数器。

## 两种身份与本诊断实际BO绑定

portal/hub继续完整416B canonical L13M及原精确比较；strict W继续原Q8S2方言/profile0及完整load/lease/read/return身份检查。两个身份都保留，不能将L13M @64 magic送入profile字段，也不能只换四tag。AT041证明六段Wi/Down权重/scale和配置、物理布局、bias0兼容，无重排或新gold需求。

AT041输出继承的BO表不作为最终绑定：其embedding base与LN STATE0 `0x300000000`冲突，q1/scale/aux记录也不等于AT035实际TB加载地址。下一诊断固定如下互不重叠的物理映射，容量不缩减：

| 区域/BO | 物理base | 容量/访问要求 |
| --- | --- | --- |
| 后段诊断输出区 | `0x100000000` | 保留原Wi/GATE/Down合法地址与所需跨度；旧预装LN源不再供数 |
| STATE0 | `0x300000000` | 16920576B；HIDDEN offset0，NORM offset8MiB |
| AUX | `0x400000000` | 1671872B；真实读canonical128B头 |
| W q0 | `0x500000000` | 184682496B |
| W q1 | `0x510000000` | 184680448B |
| W scale | `0x520000000` | 23085184B |
| embedding | `0x600000000` | 54803648B，只声明保留区，本窗口不访问 |

host可从原production-v2真实包与这份地址表产生冻结W方言bundle；包/manifest/build/GGUF摘要来自真实来源。cookie须非零并唯一绑定本次已配置BO/generation，不沿用一个与实际地址无关的旧记录。DUT有限适配边界保存/核对canonical与W方言的对应关系、role/flags/容量/base/cookie/generation；load地址必须等于相应BO base加原描述符offset，且完整span在BO内，Aux地址等于绑定base。后续W lease/read/return必须使用同一已接受W-wire，NumericIdentity四tag与canonical一致；任何改动或错配通过原拒绝语义或适配器一次显式拒绝结束，零实际AR。不能只在TB输出“通过”而旁路DUT检查。

这是冻结诊断BO表的有限绑定和一致性检查，不实现生产BO注册/认证或通用Q8S2控制器。host validation digest不冒充硬件认证。embedding未访问不能报告整五BO真实读取通过。若现有接口不能承载上述受控关系，在具体边界交付反例，不改strict W/hub的比较以放行。

## 外部Q与完整source lease的原子交接

有限适配器接收真实完整portal packet或从同一冻结命令记录构造它；P/Q/L、L13M、所有Ref、source role、窗口/offset/span/stride、rows/K和portal generation必须同源。禁止固定`published=1`、`owner_admitted=1`或第二份READY状态替代hub。NORM Ref沿AT040合法epoch9及来源关系，后续A/W/dst Ref依本次命令一致传递。

保持QAR0的G优先、已受理任务不抢占和响应隔离。外部Q成功接受与hub query-ready/granted在同一物理边沿绑定；G获选时不能提前取Q lease。hub暂忙时可保持待接命令，不能把ready=0误作拒绝。无grant或坏命令只产生一次拒绝且无Q AXI/fullA写入；未接受不能递增高水位。若采用有界暂存，区分上游入暂存和实际Q接受，暂存稳定性、终态归属和只释放真实grant的债务都须明示。

保留source-query与后段ready的无环依赖；必须给出组合依赖/唯一握手检查，不把`cfg_ready`不依赖published视为已经证明活性。Q活动中保存原完整lease key；真实Q响应消费、物理R债退休后才提交drained release，等待release被hub实际接受后才能丢弃该键或接下一个依赖请求。保持generation高水位，release不能清零它。dualA提交/矩阵消费责任按原模块边界分别关闭，不将source lease误延长成整个Down任务租约，也不能提前释放未退休的R。

## 必须取得的证据

1. 原四行完整独立gold：LN4096 F32；源Q4096 INT8/128 FP16 scale；Wi20992 F32/671744 PS；G10496 F32；GATE量化328组；Down4096 F32/335872 PS。保留原中间数据、身份/末B/lease/实际消费检查，两次Q共享同一物理量化器，Wi/Down共享同一矩阵引擎。只覆盖本四行normal，不能签完整S128输出或全模型。
2. 同一真实byte-addressed存储映射：LN实际4行写入NORM，Q从`0x300800000`真实AR/R读取这些字节；Wi真实writer/store和reader、GATE真实写读、Down末B闭合。源与各输出/保护区地址不重叠，所有WSTRB、边界、重复写、未授权写和实际数据检查保持；最终扫描实际分配的全部有效区及保护字节。允许稀疏完整BO模型，但报告准确终扫范围与未分配地址检查，不能声称全BO逐字节终扫。不得用两个同地址却不共享内容的数组伪造交接。
3. 新边界有限定向验证：发布前或坏完整身份的Q不产生AR/lease；G与外部Q竞争时只有G先受理且Q没有提前grant；合法Q响应至少7拍反压时lease/完整键保持，消费并排空后一次release；相同portal generation重放被拒绝且零新AR/无A内容破坏。保留原QAR0两方向活动/响应等待检查。另对W表与实际load base/cookie的一处错配作一次拒绝探针，修回合法命令后才真实加载；不以reset清理正常债务。记录明确触发和拒绝位置，未经覆盖的取消/公平性/恢复保持未验。
4. 记录全冷TB、新链各真实接受/首末AR/R/AW/W/B、LN末B/END/发布、Q grant/response consume/release、新A两次发布、W真实加载、Wi/G/Down实际完成消费和终态零债务。互斥阶段相加一致，stall区间标明是否重叠；单独标明定向探针开销，不能与旧独立样本相加或作优化对照。

## 执行与停止

一个有限连接候选，最多两轮有明确原因的受影响修正；不新增算术候选或调整latency。先冻结身份/真实地址/适配表/源码，静态编译及受影响默认配置检查，再≤120s新组合prefix pilot，再按实际成本准入决定四行full。报告原建议把LN最后B→Q/W前缀都放入120s pilot并无依据：允许pilot仅覆盖真实LN源读和部分算术迭代，明确它不能代签后续交接。不能降低工作量或在full前预装中间结果来满足pilot。

新组合可能降低仿真速度，必须用新pilot的实测速率/完成工作、固定开销和尚未进入阶段的保守预算说明full≤3600s是否可信。旧阶段cycle可作为结构性工作量参考，但不能把旧墙钟相加当新准入，也不能把历史周期之和报成新实测。无可信界内估计即COST_NOT_ADMITTED并交付；不能用3600s硬帽代替启动前估计。不要强求pilot完成一个在新profile下超过120s的LN整行。

LN计算段可能长于120s墙钟，观察器必须绑定真实AR/R/写响应或生成核实际有限迭代退休/循环索引推进等语义事件，说明所选信号对应的进展。周期心跳、固定重复状态/无债务变化快照不续命；不能改生成核或guard来制造进度。无明确语义观测则保留停止原因和缺口，不从最后一条日志推断最终停拍/死锁。

代码仅E002/experiment，证据E005/R001新AT，旧收据/日志/fixture不变，不撤销他人修改、不新增agent。全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static24GiB/1800s，RTL8GiB/3600s/40Mcycles，pilot/真实语义停滞120s。交付全部源码/输入/BO/生成物身份、真实计数和gold、存储保护、适配器/仲裁/lease证据、guard/policy/成本和三摘要。达到上述候选/修正上界即交付集中取舍，不加帽、不私自第三修复。

本轮无新HLS/OOC/P&R/上板/预算，G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；普通Q/L多窗口、多贡献Attention/QKV/原地epoch、完整28+2层/122矩阵/13BO请求/恢复、联合资源和物理时序仍是后续义务。有限接链通过也不关闭M003/M004。
