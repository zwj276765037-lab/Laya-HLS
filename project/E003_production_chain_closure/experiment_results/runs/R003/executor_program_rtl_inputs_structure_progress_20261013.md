# Program真实RTL出口与executor输入结构区分进展

消息：executor-program-rtl-inputs-structure-progress-20261013；回复 executor-program-validator-adapter-review-20261013。M003/SM003/E003/R003，A002共享整合，C先于D；普通验证继续，无新增审批或预算。

## Program联合修复已取得真实执行见证

`graph_program_owned_hls_06` PASS_SCOPED_GENERATION，精确复用host08。实际8FIFO/24信号；411.028507s、peak5360976KiB/2044RSS、child0/trigger null。HLS估计BRAM18=26、DSP1、FF67932、LUT249391、URAM0，仅该候选估计，不作联合/物理或性能结果。静态核真实purpose RAM0[207:192]、content RAM9[199:192]与完整model152+i位置；联合改动不拆归因。

`owned_bootstrap_validator_rtl_01` 15独立process PASS_SCOPED_RTL_OWNED_BOOTSTRAP_VALIDATOR：真nested双512同步RAM、实际start/done/return，合法purpose/content正对照；purpose0/2/0x0101、content0/2/255、正确F32下坏region及七model块首分别破坏拒绝。输入719个语义byte完整核对，model416正确；49B/392bits只限已独立核定ABI未知padding置0，保留原X/mask，knownbits改变0。此模块结果不签顶层owner安装、LHC传unsupported purpose或padding invariance。static25.933755s/peak1593868KiB；sim各约6.2s，positive6.433492s/peak737740KiB。

`graph_program_owned_rtl_04` static通过，success145ns的新增monitor误采idle ap_done导致FAIL，余三case未跑，冻结失败保留。实际generated decode done在idle也可为1；live monitor仅修为先见真实start且state454才接done，全部原四case/gold/刺激/断言及完整执行覆盖保留。

新`graph_program_owned_rtl_05`四个reset分隔process全部 PASS_SCOPED_RTL_OWNED_PROGRAM_FIRST。每case实际见owner read→decoder start→nested真实purpose1/content1→geometry→416次model copy→build_l13m完成→416次canonical比较→validate_l13m完成return0→outer binding_packet完成→1024次canonical比较→decoder完成→owner echo。copy/compare逐index完整核，非初值或短路。owner echo在cycle20816，success/cancel-prefix/cancel-allocated/stale分别57141/45060/57140/59096cycles；static96.898138s/peak2928756KiB/484RSS；四sim7.967954/7.377295/7.881669/8.031956s，各peak为856752/856772/856680/856752KiB，child0/trigger null。

范围仍是actual owned program与八depth2 FIFO，完整GRANT/LGP/LAP/LAX/LAC/receipt/LGR字节与尾2/尾1各12周期反压、旧owner/command残留不消费。LAC/LN END peer及result notification受控；不签actual executor/LN/hub同runtime或唯一软件退休。以上cycle含受控完成/20000周期保留，不是C计算性能样本。

## Executor03停止及有区别的新候选

`executor_hls_host_06`七process PASS_SCOPED_HOST；`executor_hls_03`仍COST_STOP，285.634333s、peak1474268KiB/445RSS，semantic_stall120s、child-9，Compile/Link227441，0 generatedtop/ports null。原attempt保留。

A006只读gdce证据：450定义top可达，17外部全LLVM intrinsic；普通libc/C++external、indirect call及memcmp均0。Inputs2464B的aggregate load/store副本仍在，不是memcpy intrinsic；top局部fresh Inputs传入stream后不再读取，13字段派生写/7字段原样转交，不保存Inputs地址。不能据此将copy确认为stall根因。

A002最小结构修复只改三文件：新增独立名字step_in_place(Inputs&scratch)，原完整consumer体仅移除Inputs in=live；旧const step保留copy wrapper，FIRST top传原局部Inputs。不改端口、初始化、协议、FullRuntime、真实consumer/旧债务或actor语义。`executor_hls_host_07`七process已实际PASS，新的91文件冻结绑定此改动，旧host06不预签live。现在唯一重工具为`executor_hls_04`，精确复用host07，新候选不夹带LTP1端口/collector。

可证伪观察：gdce中FIRST到in_place与copy/旧const wrapper可达性、是否完成LTO/五宽口lower、是否生成真实top/完整端口。若仍同位置停止，只能说明消除此copy不足以解除阻塞；不原样循环或扩大保护。A005准备既有stream test const/in_place双模式及显式caller值不变验证，父串行执行；不会用对象padding memcmp代替字段语义。

## 必需旧cleanup准备

`controller_transaction_adapter_managed_host_01` default兼容＋managed88case PASS_SCOPED_HOST_MANAGED_ADAPTER（60真实LOCAL_REJECT/28remote）。精确END/INVALIDATE白名单、managed RELEASE拒绝，首外部write尝试前持久external_presented；本地响应原完整1024B独立gold及caller错绑定拒绝。build14.353237s/peak262628KiB/21RSS；短default/managed各约1.27s无owned-child样本。host stream full恒false，首外部尝试未接受/真实depth2/wrapper A-pending/HLS-RTL NOT_RUN，不能关闭首cleanup缺口。

`executor_transaction_pending_host_01` PASS_SCOPED_HOST，11独立2112B LTP1 literal、原512B LAX/1536B LTX完整帧，62拒绝检查。15实际源＋test，全真实decoder，无stub/gc-sections。build7.169287s/peak241992KiB/35RSS；host0.177852s；short RSS null如实保留。LTP1只引用稳定唯一A槽、完整K/实际route/原FSM packets；没有owner/permission/retirement表。FIRST SEQ_CODEC只可用metadata/encode，full decoder APIs不在该闭包，尚无真实FSM exporter/collector/sidecar或RTL。撤销后首END/INVALIDATE入口仍待实现，不把这些host PASS扩大为合同关闭。

## 身份、记录与下一出口

工程核验9组attempt共4560项frozen及声明pair全部匹配（详见本目录verification）；immutable引用无错。executor host06/HLS03 live三文件变化正是新结构，03历史live reuse引用12条漂移另列；owned RTL04 live TB一项变化正是monitor修复。冻结不回写。当前E003三摘要与A002状态已同步，下一常规publish将补RTL05及host07终态。

优先出口：executor有区别生成结果、const兼容受影响测试，随后接同runtime C完整B1/S64四窗NORM、65536F32/真实END/发布/唯一退休及cycles；D/Q、完整CLOSED/rearm后置。必要source/旧债务与旧cleanup进展不后置。原CPU0–3/nice19/idle I/O/MemAvailable门、单重工具、分类内存/墙钟及120s真实进展保护保持；G2338.224019s仅OOC余额，5172s不重启，无新OOC/P&R/上板/预算。C/D周期NOT_RUN、C009/C013部分实施、M003/M004未完成。

证据：`executor_program_runtime_inputs_structure_verification_20261013.json`、各attempt receipt/input_manifest/guard driver；A004/A006 result有只读映射与旧证据身份。该交付为工程证据，集中验收由主控核定。
