# E005当前来源

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


---
Published: 2026-10-13T18:43:33.405589+00:00
Publication: Pd1d727dc61464b78bc823413bc380e4e
