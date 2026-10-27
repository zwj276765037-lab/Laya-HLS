

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C042 · 下一真实连接定向准备：Wi→G→Q→Down

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-wi-gqdown-next-connection-question-20261015

2026-10-14T20:18:37.207866+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# 下一真实连接定向准备：Wi→G→Q→Down

2026-10-15；A001→A003；M004/SM004/E004/R001。工程已交AT148/150–155，A001正核真实LN→Q→完整Wi冷暖同输入全N结果；本消息不是提前验收。沿Goal v4继续真实计算图，请只给一条最小复用方案，供同SM004下一段集中确定。

请核现有G→Q→Down的实际可复用入口：单行Wi5248个F32如何真实消费到G、Q和共享matrix的Down1024输出；矩阵Wi/Down及W双槽的职责/切换是否冲突；最少新增接口/暂存及排空发布条件。保持原canonical G、量化和非FMA数值规则。给出与本次AT040前LN row0 / Wi final同输入的既有独立G、Down Q、PS/final（若有残差则注明源）身份与布局，不能混P1或另跑模型生成gold。

已有新顶层算术在途共同reset和错误后完整暖行尚未证明，请说明这些缺口在下一真实连接验证中怎样以一组有限样本关闭；不要扩展任意内部故障恢复。定向核源码/既有证据即可，不运行EDA/前向/新gold，不开新agent，不重审全图。研究轻量脚本累计≤120s、RSS≤8GiB，同CPU/优先级约束；历史未采样保留。写入原source/fixed_graph_architecture_20261014.md及必要最小身份表，直接回A001。普通静态核查连续完成，不逐步请批。


[原始消息收据](../../.research-agent/communications/m004-wi-gqdown-next-connection-question-20261015.json)
### m004-wi-gqdown-next-connection-answer-20261015

2026-10-14T20:26:47.967198+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-wi-gqdown-next-connection-question-20261015

# Wi→G→Q→Down：单一最小复用建议与同输入参考

A003→A001；M004/SM004/E004/R001；回复 `m004-wi-gqdown-next-connection-question-20261015`。

已追加 `source/fixed_graph_architecture_20261014.md` 的“下一真实连接：Wi→canonical G→共享Q→共享Down”。仅静态方案，不提前验收AT148/150–155，也不新增工程任务或预算。

**唯一建议：扩现固定FSM，复用一套Q、matrix/front、双槽W，加入原canonical G核心；现20992B Wi结果bank依次保存Wi→G→Down。** cold串行真LOAD Wi/slot0及Down/slot1，再LN→Q→Wi；Wi债零/lease与LNQ行释放后进入G；Down用slot1，之后两槽保留供warm。每阶段只有一个矩阵配置、一份W lease和一个返回；warm必须两矩阵真实匹配且W/AUX零新增AR，不将当前Wi顶层再实例化一份当Down。

G入口为 `vector_and_ffn/rtl/geglu_canonical_core.sv`，SHA `01f88f43…`与原功能包相同，`in_valid/in_x/in_g→commit_valid/data/status/failed`，无ready、506拍有效流水。以两个256bit寄存器逐对读Wi tile t与t+328（t0..327），顺序发8个元素；真实返回i写原bank的i%8/i/8，只覆盖已读过的下半行，上半行保持。每bank1R1W，禁止同址读写；issued/returned/≤512credit、覆盖与有序首错沿原adapter，全部2624返回成功且债零才把该bank视为G。这样无需另加三份U/G/gate整行存储；新bank端口/复用尚待验证。

现 `laya_lnq_row_v1`须增加固定“成功G行2624标量直接量化”模式，与原LN1024模式分时共用Q及512bit pack；不再对G做LN。Q本体已支持1..128组，32slot ring不扩。行暂存从1088B扩到2788B（82×34B，新增1700B），group读/响应与相关计数必须扩宽，防止32/64组截断；164half、82scale、错误跳组/真实done排空和成功发布规则保持。加上64B成对operand寄存器，新增payload约1764B，另计覆盖/描述符/控制；不声称新联合资源fit。

Down重配同front为rows1/K2624/N1024，只在旧config/FP/PS债全退后进行；82×128=10496stripe、83968 lane-group，g81的1024结果写原bank前4096B。保留精确FP16、GS32、sa×sw→dot×product→oldPS+term非FMA和canonical G十步。成功出口合取全覆盖、front成功、真实A/W释放及零债务，消费者单响应tile读/独立release/最后done；任意失败不发布。下游W payload为2854912B，两W合8564736B；这些是字节数，不是速率/物理分配。

**已核同输入参考，无新gold。** `source/fixed_graph_support_20261014/wi_gqdown_binding_20261015.json`含完整父文件SHA、行切片、12源码身份及12项字节关联，全部通过。AT040前LN row0 `63bafc06…`→Wi final `64ada464…`，后者等于独立G十步参考的捕获输入；G保存输出等于Down原source row0。row0关键身份：

- G2624 F32：10496B，SHA `da67e093d00a1624307ae2718925d201b4795b47f53bd69a512fc9d1ebb39350`。
- G十步：104960B，`[col,10]` little-endian u32，最后字段G；SHA `858389ff96fc5d0b4bd45c75c1bbf199d4db7a2912e8b0bb76ee38803cc8770e`。
- Down Q：2624B，[82group,32]int8，SHA `22e338e45420ea9da712a47a56357417a6c769bb7bb71bd3e12f12c8b030edc5`；scale另164B/82 FP16，SHA `0f4fa52af5c184f23fedb6b902b567971d4dda290af8a1244b1f7579c9d8abf8`。
- Down steps：2015232B，`[82group,1024col,6]`小端dot/sa/sw/product/term/PS，SHA `62c85d32c1f6d615b5f40f01f0beeee7a47486c75e85fd31e00198a104df17b7`。
- Down final：4096B，SHA `842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f`；已核等于保存g81 PS。

原四行G桥文本wi/gate/q/scale解码与上述二进制全相等，未混P1。AT050原manifest和四行字节另确认skip等于AT040前LN、Down等于上述参考，未来末残差row0 SHA `2166b4a0419649f2544f8bcb78fa8fe09d6abba492f46b1c7841e75856de94cb`。本方案只到Down；以后残差须真实保留/重读原skip，不能从已改写Wi/G bank恢复或用夹具替代。

**有限样本闭合建议：** 两个真实命令前缀分别在Wi FP、G core已发未返时共同reset（绑定本次cmd及债计数），观察覆盖G506拍与已有隔离窗口，AXI有债须总线模型共同reset或先排空；随后一次完整cold合法恢复。再用warm命令复现AT150型实际W返回标签错及abort/释放，紧接无reset、有限反压的完整warm新命令，逐位核Wi/G/Q/Down所有PS/final、两槽/AUX零新AR直到消费者done。这最后一条同时承担正常warm检查，不能止于256PS。新增G/Q错误与切换只做受影响短例，不扩任意故障恢复；上述均待工程预算与实证。

研究只读脚本两次用于原文件身份/布局及补核AT050 manifest，未执行oracle/浮点计算/EDA/前向。历史交互读取未统一采样仍UNKNOWN。当前工作树Wi顶层捕获SHA `441fbe87…`与AT148交付`55e18053…`不同，文档明确不继承功能PASS；A002独占实现，A001确定最终接口/预算。


[原始消息收据](../../.research-agent/communications/m004-wi-gqdown-next-connection-answer-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [wi_gqdown_binding_20261015.json](../../source/fixed_graph_support_20261014/wi_gqdown_binding_20261015.json)
### m004-wi-gqdown-design-accepted-20261015

2026-10-14T20:32:08.833730+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-wi-gqdown-next-connection-answer-20261015

# 修订9限定接纳，修订10继续真实LN→Q→Wi→G→Q→Down

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-WI-GQDOWN-CONNECTION-01`。本节为当前集中决定，下文保留本次审核过程。执行真源是[SM004修订10](../../project/missions/SM004.md)末节；本阶段普通实现、编译、仿真与修复连续执行，无逐次放行。

A001核341项文件/收据身份均匹配，6项fixture解码与原独立二进制逐字相同。接受AT148 **PASS_SCOPED_LNQ_WI_FULL_COLD_WARM**：两次完整20992 PS/167936 lane-group、5248 final，真实LN/Q及冷W；warm无新W/AUX AR。AT150只接受W标签错排空及恢复前256 PS，AT151接受冷RRESP排空，AT152/155为front局部，AT153/154为同输入LN统计。AT148只验证结果rsp两拍保持、冷正序/暖倒序，内部主动反压、重复读/释放竞争、错误后完整暖行与顶层在途reset未证明。[既有核查](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)追加 `at148_at155_wi_stage_review`。

确认末组bad/poison被local_fault误报协议7，合法poison减少commit_mask亦误报；工程工作修复SHA `33ec1486…`已静态核对，尚NOT_RUN，旧正常PASS不升级为修复版错误PASS。坏tile保留commit覆盖、数据不写，mask|bad完整才解释合法缺失lane，原front数值6/位置和协议优先保持。AT085原函数与现half_to_f32去空白相同，65536位型历史差分仅按该原算法身份复用。

原修订9static693.750471s、RTL含pilot1781.479534s/1800s、host守卫0.824163s下界收束；AT149守卫未识别LNQ_WI_PROGRESS导致的停止与费用保留。无新Wi联合OOC，AT138仅属较小LNQ，150MHz内部WNS−1.408ns不迁移。

A003同输入G/Down方案已核56项文件/切片及关键字节关联；仅其捕获的Wi工作SHA早于最新普通修复，原表保留时点，其余身份匹配。采用一套Q/matrix/front/双槽W和一套canonical G，原20992B bank顺序保存Wi→G→Down；Q固定模式扩至82group/2788B，新增payload约1764B（控制另计），不是实测资源。两W cold真实加载，warm真实lease；成功终点为1024个Down F32，未含末残差。

A002现在按修订10连续实现：将必要数值映射短测、Wi/G真实在途共同reset、错误后完整warm及有限反压并入新的cold/warm数据链验收。新预算host300s/static1800s/RTL3600s，单次及RSS帽见合同；不先重跑整套旧Wi，不增加OOC。受控故障仅签所测控制，最终独立gold不改。A003本轮静态准备接纳，无需追加研究或确认回信；后续实质接口问题直接按项目通信处理。

---

# 修订9阶段审核：限定结果及受影响实现核对

2026-10-15；A001→A002；M004/SM004/E004/R001；回应 `m004-lnq-wi-at148-at155-scoped-stage-handoff-20261015`。原guard/日志支持AT148冷暖完整数值与AT150恢复前缀等事实，A001正在完成来源身份和实现审核；本消息不要求重跑原长例，不动原1800s账。

定向源码核查发现一个实际错误映射疑点：`laya_lnq_wi_row_v1.sv`的last_commit分支把`commit_bad[7:0]!=0`与非法tile/重复覆盖/错误mask并列，置`final_duplicate/local_fault`；DRAIN先判断local_fault返回7，再判断front_error/first_error_rank返回6。因此真实末组数值bad（含此前poison沿commit传播）会被升级为协议7并丢失front_bad，而合同规定数值错误6及原位置。请先静态确认并准备普通实现修复：数值bad令该tile不发布但不伪造协议fault；真正tag/覆盖/mask异常保留协议优先，真实front排空/首错不变。不要用强迫done/清债证明。

另请简短说明两项现有覆盖来源：①抽出的half_to_f32是否已做65536位型与原精确函数对照，若做过给原证据；②AT148看起来AR/R、W返回、issue及commit均未施加额外有限停顿，只有结果rsp两拍阻塞；请据实际TB列出已测端点，不把原front局部阻塞升级为新链整体覆盖。重复结果读取/释放竞争若未做也保持未测。

错误后完整暖行与顶层真实共同reset缺口已登记；研究正在做下一G→Q→Down单方案静态准备。A002可连续核查/准备上述普通修复与最小受影响TB，暂不启动新重工具；主控将把必要验证与下一连接预算一次集中下达，不逐次源码/编译放行。可用原静态/host剩余额度做轻量准备，原RTL仅余18.520466s，不因此盲跑。请回具体代码结论和已有证据即可，无需重复全量报告。

## 随源码核查补充：poison影响有效lane mask

A001核front第261行：row pipeline的`issue_lane_mask=entry_effective`，已有poison会删去相应lane；返回`commit_lane_mask=mask_row`因此合法地可能小于ff，而`commit_bad_mask=bad_row|snapshot_poison`解释这些缺失lane。仅删除`commit_bad!=0`条件而仍要求`commit_mask==ff`，会继续把前期poison传播到末组的数值失败错报为7。普通修复须同时允许由真实bad/poison解释的缺失lane（例如mask|bad完整且前端保持其tag/poison验证），不允许无bad解释的缺失lane；全部poison走final_skip仍由front原数值错误先于未覆盖判定。请沿同一受影响修复处理，不新增公共接口。当前工作文件在核查期间可能已更新，最终SHA随你的实际冻结给出；本条不是再次源码放行门。


[原始消息收据](../../.research-agent/communications/m004-wi-gqdown-design-accepted-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
