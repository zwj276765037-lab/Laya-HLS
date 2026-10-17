# Graph sequencer结构阻塞审核与分区决定

回复：`graph-sequencer-hls-structural-blocker-20261012`  
审核：`R-SM003-GRAPH-SEQUENCER-STRUCTURAL-20261012`  
决定：**D-M003-GRAPH-LIFECYCLE-SPLIT-01**，M003/SM003/E003/R003。

**允许program sequencer与task lifecycle executor两个内部HLS分区，并采用这一方向；executor须改为复用通用生命周期步骤的有界状态机。** 不要求继续单一graph HLS top。完整条款已写入[生产分区合同§8](production_hls_partition_contract_20261012.md)，它仅细分原§7 graph sequencer职责，既有adapter/F10 shell、LTX1/LTC1、18根协议连接信号、13BO/control、typed/数值合同和预算保持。工程可直接连续实施，无须再等逐项批准。

## 审核依据

主控核`graph_sequencer_hls_01`的58/58 current、58/58 frozen、58/58声明pair、615/615 manifest/receipt SHA引用和四个交付SHA全部一致。原guard确为FAIL/semantic_stall、child -9，1336.192305s、7005432KiB；MemAvailable最低392270164KiB，policy与原帽符合。synthesizability为0 error/1 warning，Loop/function优化已完成；479文件/147825110B高水位未再增长，停止时约120.374s无可观察进展。没有RTL candidate/top或端口证据。保留原失败；这不是永久编译死锁或硬件不可实现的证明。

host build/run exit0只覆盖受控transaction dispatch和top链接，不是完整图运行。外部codec/exchange及算术闭包没有回流，但`execute_graph_action` Compile/Link **2,144,057/2,145,023=99.95%**，PC外壳差值仅966。总规模2,223,180，最终HW Transforms为1,122,623；逐函数表中的1,119,956/1,119,600属于Performance列，不单独改称函数HW计数。**隔离PC本身未证明executor成本显著下降，不要把同一action调用树原样移到新top便启动重跑。** 核查、原始报告和更新前合同见[审核记录](graph_sequencer_structural_review_20261012/verification.json)。主控未重跑编译、仿真或HLS。

## 唯一状态归属与接口

- program独占完整PC/layer/shape/batch、下一GraphAction、graph slot逻辑别名及内部action ordinal；保留28层encoder、2层decision和全部17类action。slots只是有版本的句柄，不复制READY/owner权威。
- executor独占原请求/模型准入绑定、NumericIdentity、Task/Ref/epoch预约、高水位、各协议seq/generation、逻辑owner/lease/native状态、BEGIN/producer/END、首错/取消收束及唯一typed退休。它执行当前action的有界window/view循环，不选下一GraphAction；物理成功/发布仍以唯一hub为准。
- 两者之间冻结版本化、小端、固定宽度的action descriptor/completion，通过512bit/depth2内部FIFO。传完整identity/action键、PC/原action参数、源句柄版本和必要目标信息，完成返回真实Check/绑定/终态状态及有限slot增量。精确字段/包长由工程在共享C/SV schema和独立byte oracle中冻结，不跨界传指针、FullRuntime、可变GraphState或tensor。
- 一个活动action、一请求槽和一完成槽。完整准入检查前无副作用；安全完成且program真实消费完成末拍之后，下一周期才开放后继首拍。非终态上报不释放action；坏头/错绑定不能沿用旧可信输出。program仅在完整绑定的安全成功后提交正常slot增量/推进PC。PC_DONE不能独自触发成功Host结果或后继请求准入。
- executor直接使用原LTX1/LTC1，F10 shell消费信号改接真实executor读端；adapter仍每次只执行一笔协议事务。新action消费门控与已有24/16拍事务门控是两个不同边界，必须各自验证。

cancel到达所有相关分区，program停新action，executor保留旧活动身份并完成必需END/lease清理。只有真实安全终态才退休；坏返回隔离不等于已恢复。F6本地拒绝lease收束、F7清旧输出、F8每轮END可信检查、F9全绑定以及F10真实消费规则全部保留。immutable request/model配置可共享只读，请求准入、业务编号及结果写回不能复制出第二个权威。

## 实施出口

先提交到唯一registry的17类action映射、持久状态表、两分区source闭包和冻结schema；这是正常实施记录，不是新增审批门。executor把reserve/claim、事务构造/收发/核验、实际issued记录、END/fence、retire/release和局部游标推进编排为共享有限步骤；不要按family克隆整份Controller/FullRuntime或重新拉入旧同步全family树。功能参考与数值gold保持，内部串行化不改变原任务次序或数值计算顺序。

先做host组合回归，再生成有实质结构变化的有限分区，连接真实program→executor→F10 shell/adapter→LN master/monitor/hub，以真实completion构造END、唯一退休并返回action完成，随后接原source lease→Q/fullA gold。先实现LN子集可以取得限定出口；尚未实现的family须在副作用前诚实拒绝，不能空操作成功或宣称全图完成。扩family后再完成完整模型和13BO请求。

有界回归覆盖新边界坏/旧键、源句柄版本、末1/2拍停读及后继已排队、两层depth2背压、合法非终态END、真实部分提交/取消清理和同session恢复；只签实际执行范围。各次生成保留当前源码/配置、设计规模、guard终态及真实端口，不加帽、不原样重试失败profile。若新实现仍失败，提交具体分区瓶颈及有区分的下一方案，继续独立工作。

A002已更新为本attempt终态/当前无重工具，消除了此前运行中状态；后续三摘要/A002同步本决定与实际实施阶段即可。合同本次后续修订会使旧attempt的live合同SHA改变；审核已保存修订前副本，冻结attempt、原receipt和manifest不改写，也不因此撤销其身份核验。

C009保持awaiting_implementation，C008/C010整体awaiting_verification；既有adapter/F10和LN→hub→Q限定PASS保持，F6/F7/F8/F9/C012旧关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。原资源帽、单重工具、G OOC余2338.224019s不变；5172s组合不重启，无新增OOC/P&R/上板、agent或预算。
