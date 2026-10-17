# E005当前来源

## FFN4 AT063 原合同终态

沿D-M004-FFN-WI-DESCRIPTOR-REPLAY-01冻结同一真实四行LN/Q/Wi/G/Q/Down/末残差输入和FFN4修正；原唯一冷full已于2026-10-14结束，不重启。M005仅承接其终态及保持规格的后续定位，旧证据不回写。见[R001 FFN4报告](../experiment_results/runs/R001/reports/FFN4_AT063_bounded_stop_20261014.md)。

## FFN3 类型感知运行包（AT062）

按D-M004-FFN-TYPED-RUNTIME-PREPARATION-01保留AT059已编译snapshot、DUT/TB/guard/gold，只派生直接xsim launcher的脚本/ELF分类、wrapper真实库搜索路径、清单和启动闸口。262运行文件、336源码引用、7 ROM、63 fixture及11根同源核验；5个ELF根的readelf/ldd与80个解析库身份冻结。一次真实冷prefix合格后仅一次冷full，原正常激励未改。见[FFN3报告](../experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)。

## FFN2 直接xsim运行包准备（AT060–AT061）

沿D-M004-FFN-DIRECT-XSIM-REPLAY-01仅复用AT059 elaborated snapshot、原DUT/TB/guard/gold；AT060隔离复制262文件/130020393B并完成完整包、缺ROM、错ROM、缺reloc四项verify-only。首次清单遗漏完整动态库闭包，未启动xsim。一次纯准备纠正AT061在对Bash脚本Vivado loader调用ldd时退出1，包清单未生成，按合同停止。新的LN AR/R、四行full和成本准入均NOT_RUN。见[FFN2停止报告](../experiment_results/runs/R001/reports/FFN2_bounded_preparation_stop_20261014.md)。

## FFN1 被动进展与短测来源（AT058–AT059）

沿D-M004-FFN-PROGRESS-REPLAY-01逐SHA保留AT057功能DUT、数据、gold、响应策略和存储映射，仅为联合TB增加35分项真实握手/算术退休观察、固定schema守卫及合同遗漏的适配器和残差wrapper目的短测。AT058微测试因保留字任务名编译失败，AT059仅作一次有因测试台/尝试路径修正；未变static和短测按完整闭包身份复用。本轮真实前缀被错误的冷Vivado重编译占满120s，未到xsim，不准入full。见[FFN1停止报告](../experiment_results/runs/R001/reports/FFN1_bounded_prefix_preparation_stop_20261014.md)。

## FFN0 有限同 runtime FFN 接链来源（AT055–AT057）

沿D-M004-FFN-SINGLE-RUNTIME-01固定原request3/generation1、B1/S128四行与AT038/AT050独立gold；复用AT049唯一LN/Q/Wi/G/Down实例及AT054原生成FADD叶子/槽。新增单份外部只读skip的第二真实读口、STATE1+8MiB的Down TMP与STATE1+0末输出、Down cfg/ledger到残差受理的有限DUT退休互锁。AT055初版、AT056准备修正和AT057第二轮有因修正身份各自冻结；原数据、gold、生成算术不改。AT057短测/真实LN前缀后按本次成本记录准入唯一full；冻结进展观察器漏计Wi权重R导致有界停止，合同额度不再续开。代码唯一E002/experiment，原始身份、日志和局部证据见[R001 FFN0停止报告](../experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)。

## FFR1 受影响来源（AT054）

沿D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01从AT053派生唯一残差局部状态/观测版本。原AT050四行skip/Down/独立gold、已生成FADD叶子和有界结果槽不变；只将DUT两类有限状态映射到原laya_types.h的6/8，新增真实RRESP/BRESP错误探针、被动边沿/延迟/互斥状态计量与固定计数的120s进展guard。AT054冻结16项身份，host逻辑时间测试先行，static、短错误、单行pilot及有据成本后唯一四行full；AT052槽52例按SHA复用不重跑。无新HLS/OOC/P&R或AT049长链。

SM005/E005/R001沿D-M004-MEASUREMENT-FIRST-01、D-M004-KB1-NEXT-01及D-M004-LNQ-MEASUREMENT-01连续测量。四行resident Down KB0/KB1、two-64 KB2停止与独立CT0控制表实验保留原身份；此前算术入口LQ0/LQ1固定E003/R003/layernorm_quant_source_03的原16行LN→真实store→Q/fullA冻结闭包，源checkpoint为B1/S128前16×1024 F32，原独立LN/Q gold与AXI/lease/末B保持。仅观察TB与一个LN最终归一化循环II1候选构成受影响差异；代码唯一E002/experiment、证据E005/R001。整体executor/恢复停排，局部结果不代签完整M004。工具和数值规则详见protocol.md。

LQ1 AT015单LN生成与AT016原冻结16行连接仿真均完成；仅最终归一化循环显式PIPELINE II=1，实际II=2。LQ1与LQ0同fixture/gold/响应策略比较，周期结果与时序估计分别判断。

LQ1R沿D-M004-LNQ-TIMING-01只对LQ1最终normalize循环F32减/乘执行两版有据局部operator binding，不变150MHz与全部数值/错误/AXI合同；AT017减/乘请求4/3，AT018只将减法4→5。两版HLS估计时序不达标即停，未进入RTL。

ATN0沿D-M004-ATTENTION-MEASUREMENT-01切到原Attention v10完整head闭包；本项目复制树的93份原源、完整fixture和中间gold先核SHA，仅派生被动观察TB及终态runner。AT019固定事务数观察断言失败保留，AT020修正为真实发射/退休配平，原DUT/FP/EXP/数值/CE不变。ATN1 唯一同资源候选 AT021 已冻结并完成静态、16行 pilot、完整128行正常head；它在同row用最多四项私有 ASUB 值/key 将准备与既有 EXP 重叠，不改变原算子、gold、队列容量或 worker 数。AT022 保持完全相同 DUT，仅增强协议 TB/runner，真实回放六类首错、原四类活动管线及新增 pending/ready 的 CE/reset。数值/周期适用范围与状态债务论证见 R001 的 ATN1 对照报告。

GQD0沿D-M004-GQD-INTEGRATION-01由原bridge04冻结G/量化和AT002冻结KB1 Down构成同进程四行诊断接链；TB只供20992 Wi F32、W/metadata与命令，GATE经实际AXI写/重读，桥内唯一dualA直接供Down。新代码在E002/experiment，三次AT尝试及冻结身份在E005/R001；AT023/024保护停止原样保留，AT025为完整有限normal样本。

WI0沿D-M004-WI-RESIDENT-01，以原四行预量化LN_FFN A及独立Wi q/scale/W/PS/F32 fixture为外部边界，复用冻结dualA、严格W、单resident和KB1 writer；AT026/027受影响失败保留，AT028静态/前缀pilot/full依同一原始gold和响应策略验证。代码只在E002/experiment，证据在E005/R001；本轮不接Wi→G，也不恢复整体控制器。

WIGQD0沿D-M004-WIGQD-INTEGRATION-01将AT028真实Wi resident输出经唯一按字节寻址DDR和原Wi reader接至AT025 G→量化→KB1 Down；一套resident/dualW/dualA，同进程仅初始reset，统一四行B1/S128、batch0/row0。AT029/030/031为一次接线实现及两轮有因受影响修复；相邻冻结差异仅测试台。原fixture只用于独立检查，中间Wi不预装。合同上界已用尽；本轮有界停止，完整链待主控集中判断。

WIGQD1沿D-M004-WIGQD-OBSERVATION-01从AT031冻结闭包派生：仅测试台添加被动真实握手进度及不计入guard语义进展的有限状态快照，并冻结新runner。DUT、生成IP、全部fixture/gold、原响应/驱动时序、单resident/dualW/dualA容量及仅初始reset保持；AT032只有一次新full，完整Wi前缀不跳过。旧AT031和新AT032分别保留历史身份。

QWIGQD0沿D-M004-QWIGQD-INTEGRATION-01，以原enc0 LN_FFN前四行16384B F32为明确外部只读DDR输入，真实AXI送入桥内唯一quant_task，发布Wi dualA slot0/epoch1；随后同runtime Wi→真实DDR/reader→G→同一quant_task处理GATE并发布dualA epoch2→同一resident Down。AT033因TB误将每任务重置的计数跨两任务累加而full FAIL；AT034只修TB断言/runner，DUT、原gold/fixture、响应策略、容量及初始reset保持。原LN_FFN producer/FFN residual不在此入口，LQ0 LN_ATTN样本不拼接。

QAR0沿D-M004-SHARED-QUANT-ADMISSION-01从AT034冻结闭包派生，只改变唯一bridge的G优先组合选择/ready，及受影响TB/runner；原gold、fixture、单quant_task/dualA/dualW/resident、DDR/AXI响应策略和仅初始reset保持。诊断Context按本项目laya_tasks.h将LN_FFN/QUANT/Wi及GEGLU/QUANT/Down编码一致，原任务ID/ref/slot/epoch保持。AT035在同一四行完整链内插入双valid、两方向活动/响应反压等待及零工作拒绝探针；本轮不扩完整生产opcode权限、恢复或控制器。

AT036沿QAR0原合同补EXT_QUANT=0默认分支的受影响静态配置：完全复用AT035冻结桥与106行输入，只派生默认模块顶层Tcl；不追加DUT修复、算术候选或动态全链。

LNREF0沿D-M004-LN-FFN-SOURCE-01仅派生E002/tests的独立参考前缀runner，原`full_reference.py`数学与GGUF/五ABI输入不变。第2次`layernorm_many`是enc0 LN_FFN，原调用完成后截取residual与输出并结束；全S128 Attention依赖保留。AT037两次封装/启动失败原样保留，AT038仅修请求16B package tag核对，冻结runner、原参考/ABI/模型及主机guard。旧DUT capture和AT035外部源仅作后置比较；LQ0生成核、AT035桥与整体控制本轮只读、不运行。

LNF0沿D-M004-LN-FFN-RTL-01复用AT014 baseline LN生成核83项和原provenance/store/Q/fullA叶子，派生四行enc0 LN_FFN B1/S128/request3/generation1诊断fixture、TB与静态/RTL runner。AT038 residual是明确外部源，真实LN写目的后同runtime Q从写入字节读取；独立LN/q/scale gold只比较。AT039 END的layer字段错误留存，AT040仅修fixture descriptor layer1→0，不改DUT/数值/容量。四行正常路径之外的QAR0长链、上游producer及生产控制不在本轮。

LNQI0沿D-M004-LN-QAR-IDENTITY-01只对AT040当前production-v2 canonical包、AT035冻结Q8S2 Wi/Down权重和唯一量化器/portal接点做有界主机准备。AT041从真实GGUF、五BO、生成header/SV和冻结fixture逐字节核验，不改生成物、RTL、数值或旧收据；派生诊断W方言只用于下一接线设计，原L13M仍是LN hub的完整权威。联合RTL/HLS本轮不启动。

LNQ0沿D-M004-LN-QAR-INTEGRATION-01把AT040原LN producer/hub接到AT035唯一Q/dualA/resident/strict W，沿用AT038四行residual和AT043由真实BO映射得到的W绑定。AT044定向准入/绑定PASS；AT045/046/047联合静态与pilot/full依次推进。AT047为两轮有因修正后的冻结输入，联合TB仍保留PUBLISH后对瞬态monitor_coverage_complete的检查；原合同上界已用尽，不在本阶段作第三修正或追加full。见R001 LNQ0有界失败报告。

LNQ1沿D-M004-LN-QAR-OBSERVATION-01只派生AT047两份TB观测源；DUT、fixture、gold及响应profile未变。AT048冻结286项引用/285唯一路径逐SHA/bytes一致，static通过。唯一full的xsim工作目录漏放7份原LN生成ROM `.dat`，故运行输入部署与AT047不等价；不得用这次停止判新观测或DUT。一次full额度已用尽，旧冻结样本不改。

LNQ2沿D-M004-LN-QAR-RUNTIME-01从AT048完全相同DUT、两份TB、生成RTL/ROM、fixture/gold及响应策略派生AT049；仅冻结Tcl/launcher、7份ROM部署与逐次xsim启动前verify-only闸口，以及只读70μs前缀。一次static、一次真实AR/R前缀和一次冷full全部完成，旧AT048目录/失败不改；单实例四行normal链的完整结果见R001 LNQ2报告。

FFREF0沿D-M004-FFN-RESIDUAL-SOURCE-01在E002/tests派生一个只观察原图第770/777行的主机封装；原full_reference、GGUF和五ABI输入不改，保留B1/S128完整Attention/FFN依赖，在enc0输出checkpoint结束。AT050一次guarded host运行，冻结skip/Down/enc0结果完整128行及前四行；旧AT038、AT049 Down fixture与独立oracle只在计算后比较。硬件接点仍只设计，DUT/HLS/RTL不运行。

FFR0沿D-M004-FFN-RESIDUAL-RTL-01复用AT050原四行skip/Down/enc0输出及tanh_libm_round1_02已生成的独立FADD叶子，新增单结果槽和双外部源/单目标AXI512局部封装。AT051准备失败未启动工具；AT052静态/52例槽/单行通过；AT053只修联合TB观察，static/pilot/full通过。没有接回AT049长链或重跑HLS/OOC/P&R。


---
Published: 2026-10-14T02:10:51.526670+00:00
Publication: P771f97040d7344098d8a4a3bc10fe405
