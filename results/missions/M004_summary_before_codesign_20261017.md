# M004 当前状态：修订21成本收束，修订22唯一矩阵服务/首TN8推进

## 修订21成本收束与修订22矩阵合同（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[修订21成本出口](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_at383_closeout_decision.md)已定：AT368独立真实LN128→W→首A16和受影响局部错误/恢复按原SHA/断言范围接纳，AT379补上层stage done未消费屏障。AT382当前父top实际O3展开及真实row0通过；AT383固定120s只退休两行，COST_STOP，父动态W/Q/A16和完整父同runtime仍OPEN。

905项增量核验，744冻结/7guard/46政策通过；最终60guard/398政策，static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s。余static605.50865154154599468s/RTL323.3846215400844935s封存，不转后继；host完整与AT361未观测policy/RSS仍UNKNOWN，旧FAIL/COST_STOP保持。另核父TB只是LN阶段：W响应关闭、STATE1绑零、LN128即结束；延长原TB不能验证W/Q，后继父链须补真实peer与相位checker。

[修订22正式合同](../m004_simplified_start_20261014/a16_matrix16_rev22_decision.md)采用已审核唯一matrix服务、A16 claim/SL_MATRIX、同步A/PS单口及完整rows16/K1024/N3072 STEP16。独立真实主例从LN128→W冷载→Q16→首TN8，核128stripe/512行组/128final/16笔B及ps_retire；前4行独立gold、后12行传递/覆盖分开。首TN8不发父完成/RAW/FINAL。父完整链欠账继续保留，不作为所有矩阵推进前置。

新独立host300s/static1800s/RTL3600s预算，未知路径先≤120s；新组合真实LN16与同版W/Q16/首TN8局部完整样本支持合同2.5倍计划式≤1440s且余RTL≥1800s时，自动一次≤1800s主例。全项目单重工具/CPU0–3/nice19/idle/内存及语义停滞保护不变。普通修复连续执行，不原样续跑AT383、不启动HLS/OOC/P&R或新gold，不新建agent。修订22实现/动态结果待工程交付，完整模型/Host-HBM/联合物理未验。

以下为历史审核时点，当前范围以上段及正式合同为准。

## 修订21 AT378独立stage错误恢复限定接纳（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[AT378审核](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_at378_milestone_decision.md)接纳同AT368生产SHA的真实W错误后独立stage显式discard→无reset真实LN row0恢复。一次运行先LN128/W末q0 SLVERR、零STATE1/Q和norm保持，再以id300/source epoch2刺激恢复gamma256R/source64R/1024norm逐W握手gold/64B，生产退休1；RTL286.085076s。直接stage_release_fire不签父tensor_release/e/e+1/e+2，不签再次W加载/Q16或完整请求。row255为TB释放诊断8bit减1，不是生产行事件。

254项增量核验成立，148冻结/fixture、2guard/11政策；原51笔保持，累计53guard/352已观测政策。static1070.59817872010170202/1800s、RTL2827.7368308156728665/3600s；剩729.40182127989829798s/772.2631691843271335s，host完整UNKNOWN。AT377报告已按上次审核更正，原实验不改。

修订21不收束、不封账、不增帽。工程继续优先父层实际W/Q固定委派及合法接口交接短例；不可独立施加的内部阻塞按接口保留未测，不force或添加生产ready，不再重复已闭合恢复长前缀。阶段交付/成本出口后集中衔接已静态接纳的MATRIX16接口。父请求完整128→A16、完整模型及Host/HBM/联合物理仍未验。

以下为此前审核记录，当前状态以上段为准。

## 修订21 AT377错误与末拍屏障限定接纳（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[AT377限定审核](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_at377_milestone_decision.md)接纳同AT368四份生产SHA的AT373–377新增范围：下层部分A拒绝/显式discard/新epoch Q恢复、Q输入在途reset所列控制状态510拍隔离；独立真实LN128后W末q0 RRESP错零STATE1/Q且norm保持；LN末B延迟禁止continue及gamma退休；STATE1末R延迟禁止r15提前启动、随后完整A16观察和前4行独立gold。父完整请求同runtime及父W/Q实际委派未由这些测试代签。

审核收窄：AT373非法kind/epoch只是ready低、未接受，没有本次错误done消费；cmd_epoch同时改变A与match epoch，非两项独立拒绝。AT374未直接核全部叶子返回。AT375三拍只保持断言的valid/status16/detail子集；AT376/377分别延迟BVALID/RVALID，不签valid已置位的反压稳定。Q16导出是本地bank写及叶子release/done，没有“r15导出末B”；真实末B在LN阶段。

1005项增量核验通过，744冻结/fixture、10新增guard/64政策；旧41笔账保持，累计51guard/341已观测政策。static1024.79789475537835202/1800s、RTL2541.6517546866089065/3600s；余775.20210524462164798s/1058.3482453133910935s仍属修订21，不封存、不加帽，host完整UNKNOWN。主控首次脚本字面匹配错误另存，原工程证据不改。

工程继续原合同，优先父层实际W/Q固定委派及可经合法接口施加的pending/rsp/done/legacy交接短例；不重复已接纳长前缀、不force内部债或增加不存在的bank背压口。历史未测排列不作为全部矩阵推进前置。[首A16→MATRIX16接口](../m004_simplified_start_20261014/a16_matrix16_interface_decision_20261016.md)仍仅静态接纳，待本段阶段交付后集中衔接独立实施预算；无用户逐项审批事项。完整模型/Host-HBM/联合物理未验。

以下保留前次审核时点；当前进度以上段为准。

## 首A16到MATRIX16静态接口已接纳（2026-10-16）

[D-M004-A16-MATRIX16-INTERFACE-01](../m004_simplified_start_20261014/a16_matrix16_interface_decision_20261016.md)采用唯一共同matrix服务、A16 claim/SL_MATRIX、真实W lease/read/ret、同步A和单口PS退休。826项静态身份/字节/整数核验通过，9份current仍匹配冻结依据；未运行EDA/矩阵或生成新gold。后继首出口固定为完整rows16/K1024/N3072描述符的第一TN8：128stripe、512行组、128final、16笔OKAY B和ps_retire，A/W仍持有，无父完成/RAW/FINAL。前4行独立gold与其余12行传输/覆盖证据分开。

修订21继续原受影响交接与父W/Q委派验证，既有41guard预算账不变；此设计接纳不启动新修订、不使用当前余额做矩阵实现，也不要求工程等待研究。后继独立预算在修订21阶段交付时集中下达；未测历史控制排列不成为全部矩阵推进前置。M004/SM004仍running/unassessed。

## 修订21 AT372阶段内审核（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[AT372集中审核](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_at372_milestone_decision.md)接纳新增正常观察与core/W局部恢复。AT368与AT364同四份生产SHA，317.274436s完成真实独立LN128→W冷载→STATE1首Q16；真实Q入口16384字逐位、512组叶子响应独立映射、4352字导出/退休/最终保持通过，前4行独立Q/scale gold保留。r4..15现在可签传递/布局/保持，仍无独立算术gold；独立TB的完整发布常量不签父请求行为。

AT371四类W主回执补齐错误status16及全部声明身份字段三拍逐拍保持；错epoch按实际Check/零新增R范围。AT372同SHA core/O3四类局部实测通过：缺token LN_ONLY拒绝Check保持/消费→无reset真实exec100冷W与回执→错epoch拒绝。末终标status7属于最后错epoch，不能误读此前正常W；合法后继是W，不签第三条合法LN_ONLY。AT370 O0前缀timeout保留，不与O3完整终点计算加速比。

AT367完整父请求top实际展开及真实row0通过，1024norm/64B/source64R/gamma256R、真实未提前发布。兼容壳新增W输出固定透传不改其engine字节；父请求同runtime LN128→A16及父阶段完整W/Q委派仍未验。AT365/366/369失败和AT370成本停止不回写。

1569项增量检查成立，1191项冻结/fixture、新增19guard/132实际政策一致；累计41guard/277已观测政策，AT361未观测policy/RSS继续UNKNOWN。精确static818.12698524072765102/1800s、RTL1656.3998062927275925/3600s；余981.87301475927234898s/1943.6001937072724075s，host完整UNKNOWN。本修订不收束、不封账、不增帽。

工程按[原合同](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_decision.md)继续continue末B/pending/rsp/done、gamma退休/legacy交接、norm末R/r15受阻、部分A/显式discard和受影响reset/父固定控制短例。已通过正常串联与W四组不因整理报告重跑。原研究会话已收到[首A16到MATRIX16静态接口准备](../m004_simplified_start_20261014/a16_matrix16_next_interface_question_20261016.md)，只核现生产切口与参考，不授权新实现/预算或EDA，也不阻塞工程。STEP16/matrix、RoPE/FINAL→Attention、旧整模首错、完整模型及Host/HBM/联合物理仍开放。

审核消息m004-rev21-at372-scoped-observer-core-review-20261016已送达活跃A002；研究消息m004-a16-matrix16-next-interface-question-20261016已送达并唤醒原A003。无用户转发或逐项审批事项。

以下为历史时点，当前状态以上述审核为准。

## 修订21 AT364阶段内限定接纳（2026-10-16）

2026-10-16；M004/SM004 running/unassessed。[AT364里程碑审核](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_at364_milestone_decision.md)限定接纳同版独立生产组合的真实LN128→W冷载→STATE1首16行Q执行/A16保持：302.661219s，131072norm逐位、8192sourceR/成功B、真实W三口24576/24576/3072R和AUX8R、STATE1 1024R，前4行Q/scale对独立gold逐位通过。上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…为本次身份；完整重父top同runtime尚未通过。

证据口径已收窄：r4..15现为行退休bank快照与最终bank保持比较，尚非叶子输出→bank逐位传输检查；Q入口16384项仅计数，逐位检查实际位于STATE1 R端。独立TB的request/RAW/FINAL标志是常量，不签父请求发布行为。前四行独立数值结果保持，缺失monitor并入后续受影响验证，必要时按原帽集中增强串联，不删原checker或改旧FAIL。

1646项审核检查成立，1228frozen/94fixture SHA、22guard/145条实际政策匹配；AT361快速child127没有policy/RSS观测，明确UNKNOWN。AT363 Fatal及全部失败费用保留。同串联层次AT363真实LN16为40.053438s，成本式更新880.383237s仍满足原≤1440s门槛；不重跑成本调查。

截至AT364 static488.59907988831400432/1800s、RTL736.4435322098433930/3600s；余1311.40092011168599568s/2863.5564677901566070s，host完整UNKNOWN。修订21继续、不封账、不增预算。工程按[原合同](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_decision.md)继续最终父top展开/实际委派、交接阻塞与错误/恢复，补Q入口/真实叶子映射和W回执完整字段；旧修订余额不转移。STEP16/matrix/全RoPE/FINAL→Attention、旧整模首错、完整模型及Host/HBM/联合物理未验。

审核消息m004-rev21-at364-scoped-chain-review-20261016已于2026-10-15T20:34:39.001043+00:00送达活跃工程原turn01a14112-00a9-7e33-9a64-f3cbfbbff010；没有等待用户逐项审批。

以下为历史时点，当前进度以本次审核为准。

## 修订20 AT351集中审核与成本出口（2026-10-16）

2026-10-16；M004/SM004仍running/unassessed。[修订20成本出口审核](../m004_simplified_start_20261014/source_norm_owner_rev20_at351_closeout_decision.md)已送达A002。701项检查成立，49笔原guard与356条实际政策相符；static1798.4354466479271734/1800s、RTL1323.850544061511735/3600s，未用1.5645533520728266s/2276.149455938488265s封存，不转后继，host完整UNKNOWN。

AT343最终生产身份的独立真实LN128正常链保持接纳：252.283932s、131072norm逐位、8192sourceR/成功B和NORM_STAGE_READY；同版完整父请求top仅row0。AT344–350增加晚source读错、末B错后16行真实LN/discard、页界/有限停顿、gamma非有限、非法描述符及gamma预装在途共同reset的限定证据。恢复为独立stage直接release/abort及新epoch，未证明父tensor_release或e/e+1/e+2完整协议。

AT349只签实际断言的done_id/op/status/phase/detail/bad64；bad_element与回显row未测。三拍后端点检查不等于阻塞保持或逐拍全字段检查。AT351增强父core拒绝后合法后继只有冻结TB，静态timeout，无snapshot/RTL。gamma总线load_done错、store/numeric竞争优先、pending/rsp/末B切相位、LN/回放在途reset仍开放；原Fatal/timeout保留。

[修订21合同](../m004_simplified_start_20261014/ln128_wprep_q16_rev21_decision.md)已于2026-10-15T19:37:41.304003+00:00实际送达并唤醒原A002，turn01a14112-00a9-7e33-9a64-f3cbfbbff010。固定目标为真实LN128→唯一W服务冷载→STATE1首16行Q16→A16保持；保留norm上下文、单cache/reader/bank及原算术。104项静态身份/字节/整数核验成立，接口实现与主例结果尚未交付。

新独立host300/static1800/RTL3600s；新未知路径先≤120s，完整LN16/真实冷W/局部Q16样本支持保守估计≤1440s且余RTL≥1800s时自动一次≤1800s主例。前4行有独立Q/scale gold，其余12行只签真实输入、输出传输/布局/保持；不得声称16行全部独立数值通过。原失败与各SHA范围保持。完整父图128同runtime、STEP16/matrix/全RoPE/FINAL→Attention、旧全请求首错等价、整模、Host/HBM/物理BO及联合资源/Fmax未验。无需用户转发或逐项审批。

以下为历史时点，当前状态以上述审核为准。

execution_state: running
verdict: unassessed
review_state: approved_by_user
updated: 2026-10-16

## 当前修订20：上层生产循环与真实独立LN128正常链接纳（2026-10-16）

[AT340–343审核](../m004_simplified_start_20261014/source_norm_owner_rev20_progress.md)434项新增核验成立：14项早期源码SHA、AT343最终130项frozen及两组10项实际fixture、9guard/55政策一致。上层58086436…实际持有128循环、预装/真实LN/同步norm写回与退休，父staged分支只代理；下层/core/reader/writer/FP及gold沿原身份复用。AT343同版独立16行36.700970s满足成本门，真实LN128于252.283932s完成131072norm逐位、8192sourceR/8192OKAY B、gamma256R和真实NORM_STAGE_READY。独立TB只喂真实raw/gamma与AXI，不用保存norm替代计算。同版父请求top49.062415s仅row0/1024norm/64B通过，不能代签父图全128同runtime。

累计32guard/245政策；static1413.8123060390353384/1800s、RTL1213.266668045893288/3600s，余386.1876939609646616s/2386.733331954106712s。最终同版父图构建已完成，原400s预留计划已用于其目的；剩余预算继续定向错误/停顿/页界/交接/在途共同reset510拍和恢复，不重跑未改长例。AT340失败、AT342旧SHA全例与全部费用保留；host完整UNKNOWN。正常路径接纳不关闭错误覆盖、Q16/matrix/RoPE/FINAL→Attention、完整模型或物理结论。以下为历史时点。

[最新AT332–339审核](../m004_simplified_start_20261014/source_norm_owner_rev20_progress.md)986项成立：397冻结/15fixture/2探针、11guard/90政策匹配。AT339上层6721c8e4…在AT336完整闭包重编展开，实际S128请求row0预装与norm写回通过1024norm逐位、64B/source64R/gamma256R，153810ns明确终标。AT336漏接flush_done的timeout原FAIL/COST_STOP保留，AT337/338仅诊断，AT339仅补一根端口后正常通过；AT333缺库失败不改。当前128循环/16行错误屏障、请求描述符及准入/Check/退休代理仍依赖父层，独立stage/真实16行/LN128尚未运行。

累计23guard/190政策；static1183.5299725364893745/1800s、RTL589.942395463585853/3600s，余616.4700274635106255s/3010.057604536414147s。400s最终父top静态计划保留，其余构建余216.4700274635106255s，host完整UNKNOWN。完成全部剩余控制迁移后集中独立stage及最终父请求验证，不重复中间重父图；原同版16行成本门不变，修订20继续不封账或增加预算。以下AT331为历史时点。

[阶段进展](../m004_simplified_start_20261014/source_norm_owner_rev20_progress.md)：AT328固定151根bank信号透传、下层本体不变及父请求top唯一LNQ/bank已核。AT329旧版真实复现本地拒绝回显旧成功Check，AT330修复后协议Check正确，问题状态CLOSED_SCOPED_REPRO_AND_CHECK_FIX；错误done消费后同runtime无reset合法后继仍待迁移后恢复短例。AT331同修复engine的真实S128请求row0通过，1024norm/64B/source64R/gamma256R为明确终标全次计数，未提前发布。上层128循环/16行错误屏障及source/norm控制尚未迁完，独立stage、真实16行/LN128仍NOT_RUN。

[AT331机读审核](../m004_simplified_start_20261014/source_norm_owner_rev20_at331_review_20261016.json)1878项成立：累计749冻结＋24fixture＝773项、12guard/100政策匹配。static713.91580555960536/1800s、RTL267.289995469152928/3600s，余1086.08419444039464s/3332.710004530847072s；host完整UNKNOWN。保留400s最终父top静态计划空间。限定回复m004-rev20-at331-scoped-bank-check-review-20261016已送达活跃工程；修订20继续，不封账、不增预算，历史失败与分版结论保留。

[新合同](../m004_simplified_start_20261014/source_norm_owner_rev20_decision.md)已送达并唤醒原工程会话：移动source/norm控制、128循环和16行store错归并至现上层；独立stage与真实S128请求父top同版复用唯一下层及I/O。新host300/static1800/RTL3600s，首真实16行pilot≤120s，满足原保守成本门后自动LN128。生产切口不变，不扩矩阵/Q16父图或新算术；无用户逐项审批。

[修订19阶段审核](../m004_simplified_start_20261014/ln_shared_service_rev19_at325_stage_decision.md)5411项检查成立，2139冻结/另外69声明fixture/30实际输入绑定/38guard/288政策匹配。下层63da9112…LN_ONLY局部生命周期与Q16全窗最终复扫接纳，当前行包装层row0/错误恢复端点接纳；上层单一归属未完成，真实16行/LN128未跑。AT322三快照和AT323正常前缀没有S128请求top，保留逐行TB边界。

static1706.08185053430498095s、RTL1473.825600214302521s；余93.91814946569501905s/2126.174399785697479s封存，host完整UNKNOWN。后继起点五份生产SHA已核；消息m004-rev19-review-rev20-source-norm-owner-dispatch-20261016已delivered至turn01a14093-1fdb-7aa1-bb38-668a63e88b63，新实现/测试待实际结果。完整M004及联合物理仍未完成。

## 历史修订19 AT315阶段内审核（2026-10-16）

[AT313–315审核](../m004_simplified_start_20261014/ln_shared_service_rev19_at315_milestone_decision.md)限定接纳下层d39a5479…两份保存norm交替16槽的Q16局部检查，以及父top9fc852c9…/b353e634…的真实row0退休前缀。AT314逐行4352字/512响应通过；AT315观察1024norm及64B、cycle15375，完整16/128行未到。source64仅属退休时点，非全次末计数。AT313 child0/Fatal仍FAIL，原始证据不改。

主控818项检查成立：357冻结、12份fixture、六guard/38政策；AT307–315费用单独汇总16笔，static879.9686042405664817s、RTL395.898595323786132s。后续费用继续入账，余额未封存。下层LN_ONLY及上层source/norm、128循环/16行错误屏障仍须完成单一owner迁移；原合同内继续实施，决定已送达活跃工程会话，无待用户审批。

[修订18审核](../m004_simplified_start_20261014/lnq_cost_owner_rev18_closeout_decision.md)核756冻结/12guard/101政策、1033项检查成立；Q16局部占有漏洞修复接纳。同版默认/O3的38事件与逐位检查一致，单次93.291409s→89.642302s；AT306 120.308519s仍只两行，无16行/LN128。余static157.61403870023786266s/RTL2036.72993215359746s封存，112共有条目/事件序列化勘误已同步。

[修订19合同](../m004_simplified_start_20261014/ln_shared_service_rev19_decision.md)保持数值/clock/reset、真实AXI、G同步1R+1W和无ready返回。新host300/static1800/RTL3600s，先≤120s完整16行pilot，保守全128≤1440s且余额足够才自动≤1800s LN128。当前只接纳上述局部兼容，独立阶段和收益未验；独立LN128不代签父top同runtime，整模/物理仍未验。

## 历史修订18下达与研究审核时点

[研究成本交付审核](../m004_simplified_start_20261014/ln128_cost_static_review_decision.md)已完成并送达工程：31项身份等37项检查成立，待本机动态核实的--O3为唯一候选；同修复SHA/TB及实际库闭包要求保持。空闲G/tanh/RoPE可能增加成本，未测占比或加速；生产前端抽取仅后备设计。A002已报告旧core反例编译/RTL启动，新增结果未交付，原自动LN128条件和预算不变。

[修订17集中审核](../m004_simplified_start_20261014/staged_lnq_rev17_stage_decision.md)按成本出口结束：当前AT297 120.449776s超时，仅row0/1退休、2048 norm逐位、128笔B；总source192R含row2在途64，真实LN128/NORM_STAGE_READY未完成。Q16顺序16行布局、分版错误/恢复、模拟调度/ready reset与当前leaf兼容分别接纳。

主控实际核1821项冻结（原报1817需勘误）、54guard/400政策，精确账static1690.9283452630042897s/RTL1660.9250732809305405s相符；旧余109.0716547369957103s/1939.0749267190694595s封存。新增静态反例REV17-Q16-PARTIAL-OWNER：部分窗口存活时仍可接受raw/gamma准备并覆盖已存A；未经RTL复现，接口整体验收保持开放。

[修订18](../m004_simplified_start_20261014/lnq_cost_and_ownership_rev18_decision.md)已下达工程，新host300/static900/RTL2400s：最小复现/修复占有；同生产SHA/TB比较默认与一个受支持优化构建，同版16行及成本落帽后自动全128 LN。没有原样延时、数值替换或未定义clock/CE变化。A003独立核仿真成本和必要结构备选，新实验未交付。完整QKV producer/FINAL→Attention、全图首错、整模及联合物理仍未验。

## 历史修订17下达时点


[D-M004-STAGED-LNQ-01](../m004_simplified_start_20261014/staged_lnq_frontend_rev17_decision.md)已实际送达工程：LN_ONLY/DIRECT_NORM1024、准备token和现bank的Q16布局，真实STATE0/gamma→LN128→STATE1写B。完整16行窗口pilot≤120s，同版保守预计落帽后自动全128 LN；新host300/static1800/RTL3600s独立，原服务器政策不变。尚无新实验结果，内部阶段就绪不等于完整请求成功。

[D-M004-REV16-CLOSEOUT-01](../m004_simplified_start_20261014/attention_rev16_closeout_decision.md)已分版接纳旧八tile与新单tile/错误恢复；644项冻结/21guard/231政策一致，static308.28305006958544s、RTL1094.2193052433431273s，余额1491.71694993041456s/2505.7806947566568727s封存，hostUNKNOWN。R供给间隔/B返回延迟与VALID反压覆盖分开，物理BO未签；旧失败保留。

研究接口交付已采用模式/bank部分，Q内部完成与外层done、LN正常release与故障discard的生命周期已写清。STEP16、矩阵和全RoPE阶段留待后继实施；真实128 producer→FINAL→Attention、全模型与联合物理仍未验，全请求首错等价UNRESOLVED。工程继续，无需用户再次批准。

## 历史修订16 AT268里程碑（已由AT272阶段结论收束）


修订15后因A001未及时衔接合同的空档已纠正。AT268实际完成同runtime head0八tile消费者，413.674108074978s、child0/null、峰863248KiB；8192输出、score/prob各16384项逐位匹配，512笔真实OKAY B。[限定接纳决定](../m004_simplified_start_20261014/attention_at268_milestone_decision.md)只属于adapter5a44a3bc…冻结身份与模拟发布peer/t5捕获输入。没有真实128行上游producer或同runtime FINAL交接证明。

主控核92项manifest、六组mem/bin、当前mask及八笔guard/91条政策。AT266失败保留；截至AT268原账static130.61212972551584s、RTL532.7055163476616233s，launch basis前账0.0003512605720733s偏差登记勘误，不影响启动条件。后续短例尚在执行，host完整UNKNOWN。工程继续Q中途读错排空、writer错误rearm及恢复/页界/停顿短例，新SHA不继承长例。原host300/static1800/RTL3600s和单重工具政策不变，修订16未收束。

[研究增量审核](../m004_simplified_start_20261014/s128_continuation_controller_review.md)确认全请求首错差异不止RoPE先后，还涉及LN128、Q16/TN8及完整表前检，继续UNRESOLVED。A003已收到分阶段producer窄接口静态任务；未授权新gold、900s生产器profile或生产RTL重构。修订15封账与旧局部范围保留，全16head/Encoder/模型、Host/HBM及联合物理仍未验，M004 running/unassessed。

## 历史修订15 AT265补项接纳与有界收束（2026-10-15）

[D-M004-REV15-CLOSEOUT-01](../m004_simplified_start_20261014/source_s128_rev15_closeout_decision.md)接纳生产sequencer＋合法完成peer的第127行错误出口：128命令、127成功＋1错误，7/14/bad全1/id208/row127保持3拍到真实消费，前127位成功/末位0，无回绕或FINAL。该项只签调度局部，原合同指定补项闭合。

新增5冻结/12原产物/11政策相符，原42条账不变；现44笔（21static/23RTL），1275项冻结与413条政策全部匹配。static1773.706414608284832/1800s、RTL2773.568239858373999/4800s；余额26.293585391715168s/2026.431760141626001s封存，不转移，hostUNKNOWN。原失败/timeout不回写。

修订15bounded_closed，M004/SM004仍running/unassessed。旧AT250两行前缀与当前AT264单行/逻辑哨兵分版保留；当前两行连续、128行真实生产、请求成功/FINAL、完整首错等价、物理BO/Host-HBM、Attention/整模和联合物理未验。后继实施/预算另列，无新用户审批或修订16自动启动。

## 历史修订15 AT264阶段审核（2026-10-15）

[D-M004-REV15-AT264-01](../m004_simplified_start_20261014/source_s128_at264_stage_review.md)已送达工程：预装abort真实排债与source RAW-only gamma AUX描述符两项修复接纳；当前wrapper d4856aee…的AT264真实row0全量数值、384笔B和输入/未生产row1逻辑哨兵通过。旧AT250 d8e52ea3…固定S128请求两行前缀保持原范围，当前两行连续PASS未取得。

主控累计核1270项冻结、402条政策和42笔原guard，新增342份实际fixture父文件逐字相同。static1769.133914342150093/1800s、RTL2768.097435323521494/4800s；余30.866085657849907s/2031.902564676478506s，hostUNKNOWN，原失败保留。原合同第127行错误尚缺直接调度测试，已交A002仅用生产sequencer/合法peer补127成功＋最后错误，不发布FINAL、不回绕、保持原错误完成；static/RTL各累计≤20s扣原余额。

修订15pending_last_row_error_probe，暂不封账。局部/旧身份错误reset、页界、token、legacy证据按审核限定保留；全128真实生产、真正请求成功/FINAL发布、当前SHA两行、完整请求异常次序等价、物理BO/Host-HBM、Attention/整模和联合物理仍未验。无新增预算或用户审批项。

## 历史修订15 AT250里程碑（2026-10-15）

[D-M004-REV15-AT250-01](../m004_simplified_start_20261014/source_s128_at250_milestone_review.md)限定接纳同一固定S128请求经真实STATE0/AUX预装、bank回放完成row0冷/row1暖QKV→scratch→RoPE。全两行正常数值、4096 Q/K FINAL与V/norm实际逻辑内存保持通过，共1024 row响应、768笔B；仅两行覆盖，无request done或tensor发布。证据限core29db0515…/wrapper d8e52ea3…/sequencer b44b5563…。

主控547冻结/60产物/135政策、57份同AT225fixture和14父窗口核对一致。AT250 RTL806.8281200714409s/child0/null；AT243–250累计快照static731.453528914600612s、RTL946.227504860609739s，后续成本另计，hostUNKNOWN。AT245 timeout、AT243/248失败不回写。

原预算内继续预装abort与读债出口、source RAW-only gamma AUX身份两项静态修正及既定局部回归。新身份不自动继承完整前缀PASS，不要求重跑长例。阶段未收束；AT249仅模拟peer的128调度，真实128生产/整请求/整模首错/物理BO/Attention/整模仍未验。以下为修订15下达及此前历史时点。

## 修订15合同下达时点：真实入口与固定128行调度（2026-10-15）

[D-M004-SOURCE-S128-01](../m004_simplified_start_20261014/source_s128_connection_decision.md)已明确实施：STATE0 raw和完整模型AUX gamma每行读入既有bank，成功后真实同步回放LN，再沿单core的QKV/scratch/RoPE链串行128行。命令全部锁存，输入失败7/phase14必须在core启动前真实排空；request成功只在128个真实行完成与FINAL发布之后。

A001独立核81项身份/30项字节与整数条件/6窗口比较全部一致，完整外层静态审核0.22s/49080KiB，非EDA。t5 head0参考只作未来同输入Attention消费者依据，软件捕获QKV不替代真实producer。原整模异常次序不因当前row-major服务改写，仍未接纳其等价。

新host300s/static1800s/RTL4800s，先一次固定≤120s真实入口pilot；主场景为真实固定128行调度器的row0冷/row1暖完整数值前缀，两行后无整请求done/发布。合法128行peer只签调度元数据。Attention/new gold/OOC/P&R不在本段，新工程尚NOT_RUN，实际执行以工程收据为准。修订14分版结论与未用余额封存；完整模型目标继续running。

以下保留既往授权、基线和阶段时点，当前实施范围以上节为准。

直接授权为用户“支持开始实验”。[Goal](../../goal/goal.md)、[M004](../../mission/M004_完整Laya加速器搭建与性能优化.md)生效；[SM004修订3](../../project/missions/SM004.md)已选择固定FSM与六类跨层共享服务，并给出外部scratch和首个精确F32残差实验接口/预算。硬件段执行委派见[工程指令](../m004_simplified_start_20261014/fixed_graph_engineering_decision.md)。

AT091原日志记录47项/4,523,596个F32检查通过，guard child0、无trigger、216.712004691s、峰640172KiB。主控另将actual final18的72B与原独立gold逐字节核对相同，SHA256为b54436f6ec76ad541a001ae06ccd4a867584e90ac973cc0438a730a5959de2ad。接受范围为单个完整正常B1/S128软件请求；Attention为CPU QK/SM/AV各61440次，状态服务命令0。AT089路径FAIL保留，软件验收开关只允许所选单场景，原默认路径断言保留。工程[集中报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md)给出完整来源与预算；首段两次完整请求已用尽。

AT166已完成真实LN→Q→Wi→G→共享Q→Down的同输入完整单行cold/warm数值验证，限定接纳；修订10按成本出口收束。此前[SM004修订11](../../project/missions/SM004.md)已取得真实FFN单行及有限恢复的分项证据；AT173整体FAIL保留，修订11按成本出口收束，该时点下一QKV尚在静态准备；当前修订12见下节，完整模型未验收。

## 历史修订14 AT242补测验收与分版收束（2026-10-15）

D-M004-REV14-CLOSEOUT-01：主控核AT242新增17项冻结、10份原产物、19条实际政策，AT236原保存参考、运行时输入和原adapter/leaf/IP身份一致。四个手算Check例bad依次7/31/63/63，code6/detail0740000f/完整64bit bad、结果三拍保持与真实消费通过；随后无reset正常保存head成功Check及64项输出逐位通过。唯一最终ROPE_CHECK_EDGES_PASS，无Fatal/Error。原合同本次指定缺项在局部范围闭合。

[修订14收束决定](../m004_simplified_start_20261014/qkv_rope_rev14_closeout_decision.md)已送达工程。总55笔guard（27 static/28 RTL），static1001.90892168506979732/1800s、RTL1247.0794125087559535/4800s；旧53笔逐项不变，hostUNKNOWN。余额798.09107831493020268s/3552.9205874912440465s封存，不转移。所有原失败及未测范围保留。

旧AT225 b1315262…真实两行正常链与当前0d3e340e…局部修复/回归、AT232展开分版接纳；AT242只属adapter/原leaf，不能代签当前wrapper完整真实长链。严格IP未返reset、全128真实生产、完整请求首错、物理BO/哨兵、Attention/整图/Host-HBM/联合物理未验。A003已收到下一S128→Attention静态接点任务，无修订15实施预算；M004仍running/unassessed。

## 修订14 AT241阶段审核（历史，2026-10-15）

D-M004-REV14-AT241-REVIEW-01：主控核958项冻结、237份原产物、456条实际政策和全部53笔guard；13项保存参考/无损格式/整数关系补核通过。当前wrapper0d3e340e…的逐head Q→K和AUX旧sticky error后新load记账两项修复在所测局部范围闭合。AT230/231同TB旧失败/新成功，AT230双坏输入先报K/head0的6/13/bad1024；当前原core/adapter/writer/leaf不变，AT232只为真实core/IP展开。旧AT225真实两行正常链仅属b1315262…，不迁移新版完整数值实测。

AT230/241所测RRESP/BRESP错误排空、discard后无reset恢复、RAW-only/FFN局部回归和页界/逐口持稳接纳；AT236/237原保存head及非对称表是局部叶子数值。AT233仅签MUL已接受但HLS未采样隔离，严格IP未返回仍NOT_RUN。AT234前三个触发在RAW写阶段，四次各510拍隔离、序列末尾一行完整恢复；AT240仅模拟core/快速叶子128位元数据，不证明128行真实producer，打印next_begin5未实际运行。

[阶段审核](../m004_simplified_start_20261014/qkv_rope_stage_handoff_review.md)已送达A002。原合同末pair上下半溢出、多个非finite、预检与算术首错的四个Check短例尚需补齐；原预算内连续完成，无逐步审批或长链重演，修订14暂不封账。总账static978.93351217359304232/1800s、RTL1241.301459711045058/4800s；AT227启动失败没有政策采样，host完整UNKNOWN，旧FAIL/COST_STOP保留。

A003同步进行[下一真实S128生产与FINAL→Attention静态接点](../m004_simplified_start_20261014/qkv_final_attention_next_design_question.md)，无修订15工程/EDA授权。当前同SHA完整真实两行、全128真实生产、完整请求首错、物理BO/哨兵、Attention/整图/生产Host-HBM/联合物理仍未验。机读字段revision14_at215_at241_closeout_review保存本轮审核（名称用于阶段交付，stage_status明确为running，非封账）。

## 修订14 AT225限定接纳与受影响控制修正（历史，2026-10-15）

主控核143条冻结身份、9份原产物、24条政策，原QKV/FFN fixture及新增两行FINAL/表窗口绑定一致。AT225 wrapper b1315262…/adapter a80564de…在同runtime真实row0 cold→row1 warm完成LN/Q/QKV、RAW写、真实scratch读、full RoPE及原址写回。4096个Q/K FINAL全量逐位过原冻结独立派生参考，V/norm各行不变；768笔B、64head、256scratch R、64AUX R，child0/null、791.7965642139316s。仅两位RAW/FINAL覆盖，未发布整tensor；partial discard消耗至epoch2。全局done cycle111837/195897不称命令latency。

接纳PASS_SCOPED_QKV_SCRATCH_ROPE_ROWS01_NORMAL，仅限上述冻结身份。完整Check字段只显式核每行最后head；紧凑两行内存不提供完整BO/邻域哨兵证明，AW/W次序仅全局、未核新增scratch受阻全字段保持，4KiB split及下一begin3未测。原失败/timeout保留。

[D-M004-REV14-AT225-REVIEW-01](../m004_simplified_start_20261014/qkv_rope_at225_scoped_review_decision.md)已送达A002：当前plane-major遍历改为合同head0 Q,K→head1 Q,K；AUX旧sticky error与新load接受记账按真实事务修正。局部生产适配器检验双错次序、部分R后错误排空及discard后新epoch无reset恢复；其余受影响错误/reset/元数据回归按原帽继续，不重演791s长例、不扩预算。旧SHA正常链不自动迁移新SHA。

截至AT225完成guard时点账static543.2655436191707835/1800s、RTL1043.750234801322253/4800s，15笔（10 static/5 RTL）；后续另计，host完整UNKNOWN。修订14仍running。全128真实生产、全请求首错、Attention/整图、Host/HBM及联合资源/Fmax未验。[集中审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)和机读字段revision14_at225_normal_rows_review保存原依据。

## 修订13收束与修订14实施下达时点（历史，2026-10-15）

AT212旧wrapper9c55ae10…复现flush同拍身份错挂起，AT213新版daae5611…以真实读写债零完成、显式discard/新epoch局部恢复，受影响局部回归通过；AT214只有真实core/IP展开。主控核98冻结/31产物/56政策/7笔guard，修订13最终static615.5153379254043043s、RTL1498.1496843509375738s，hostUNKNOWN，余额封存。AT204旧e5dde5cc…真实两行写错后完整FFN限定证据保留，不迁移新版完整实测。

[修订14正式合同](../m004_simplified_start_20261014/qkv_rope_connection_decision.md)保持单core/单writer，增加完整Check RoPE叶子和真实scratch/AUX reader，隐藏逐行RAW→FINAL，双epoch和真实B退休后发布。当前两行独立参考由原冻结oracle有界补齐，旧参考/工程gold未覆盖，主控61项身份/字节关系已核。新host300/static1800/RTL4800s独立预算，工程连续实施/普通修复，无逐步审批；新连接NOT_RUN。

主场景真实row0 cold→RoPE→row1 warm→RoPE，全Q/K FINAL逐bit核并检查V/norm/内存哨兵；全128位才允许tensor发布。局部错误/reset/元数据单列。全128真实producer、全请求首错顺序、Attention/完整图、Host/HBM与联合资源/Fmax未验。[集中审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)保存分版证据。

## AT196–208集中审核（历史时点）（2026-10-15）

D-M004-REV13-AT204-REVIEW-01：主控核229条冻结身份、105份原产物、168条政策及53份fixture原参考关联。AT204旧wrapper e5dde5cc…同runtime真实两行QKV/norm共1024读响应/512写事务、末B错排空后完整FFN末残差消费者done限定接纳。AT197/205/207/208按叶子或合法peer范围接纳，不升级128行真实QKV。全局AW先/W先flag不等于三口逐口两种顺序；当前新增局部回归补持稳/末B屏障。

累计static319.7074945475906148s、RTL1455.8813096918165374s，hostUNKNOWN。wrapper F_ROW漏接core直接错误done和结果回显未比较已实际交A002原帽内普通修复，旧AT204保留，新身份待证；不重跑1404s长例或增加预算。A003已收到[RoPE下一静态接点](../m004_simplified_start_20261014/qkv_rope_next_design_question.md)，没有修订14实施/EDA授权。详见[集中审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)及机读字段revision13_at196_at208_stage_review。

以下为历史阶段时点。

## 修订13实施下达范围（历史时点）（2026-10-15）

D-M004-QKV-SCRATCH-ROW-01：[实施合同](../m004_simplified_start_20261014/qkv_scratch_connection_decision.md)已形成并生效。 正式合同通过消息m004-qkv-scratch-revision13-implementation-dispatch-20261015实际送达A002，recipient turn 01a13d82-52a1-7a02-84e0-9ba7e0a2bce3；研究采纳边界亦已独立送达。送达不等于工程完成。复用一套计算top和一个writer，QKV按真实AW/W/B写三目的scratch，FFN行读透传；新增债零rearm、phase12、tensor begin/epoch/128bit覆盖/sticky失败/显式释放，未成功写完整请求不得发布。主控核52条身份和20项独立byte/整数布局条件，新连接NOT_RUN。

本段以生产adapter短例和一个合并runtime验证：row0 cold全部写回成功，row1 warm末norm B错误真实排空，随后无reset以Wi slot0 epoch2/Down slot1 epoch1完成FFN到末残差消费者done。修订12未完成跨mode保留，只有本段实证完成才关闭。新预算host300s/static1800s/RTL4800s，RTL单次2400s/1Mcycle、pilot120s计入；无OOC/P&R、新gold/代理。旧31.546817927s余额封存。

以下为此前阶段时点；全128行、RoPE/Attention、完整模型及联合物理仍未验收。

## 修订12阶段结论与下一连接（历史时点）（2026-10-15）

D-M004-REV12-CLOSEOUT-01：主控核602条冻结/夹具引用、85份原产物、142条政策采样、28项原参考字节关联，23份FFN fixture另与AT173相同。固定顶层54fe628f…/LNQ cd35f5a6…在AT184/188/193/195间保持；AT192→194仅switch TB变化，不称全冻结包零差异。

AT193限定接纳真实Embedding QKV row0 cold/row1 warm：共196608 lane-group六字段PS、6144 QKV final、2048norm，512tile全读/重复首末/保持/release/done，W/AUX真实阻塞与warm零新增AR；错误mode/row及相同model/epoch不同key/shape的FFN warm拒绝有证据。其后首次slot1 Down误配epoch3触原cache拒绝，整体FAIL_TB_SLOT1_EPOCH不改。

AT195独立runtime真实QKV row0完成生产/释放（只抽查首末结果tile），随后无reset以Wi slot0 epoch2/Down slot1 epoch1完成成功冷载；Wi20992 PS、G2624返回逐位通过，Down最后记录issue9542/10496、commit9530/10496。1100.280453s/trigger timeout/child−9时仍有在途，Down尾/ADD/发布和消费者未到。完整跨mode FFN仍COST_STOP/NOT_RUN，不将AT193/195拼为一次成功。

原guard合计static800.9032639935613s/1800s、RTL3568.45318207331s/3600s；余31.546817926689982s封存，host已测1.2153561394661665s下界、全量UNKNOWN。本段不再重工具。下一[QKV＋norm设备写回静态问题](../m004_simplified_start_20261014/qkv_scratch_next_design_question.md)已直接交A003，核真实writer/AW-W-B债/末响应后release和保存地址数据参考。当前无新RTL/OOC预算，不仅加帽原样重演AT195；遗留完整FFN重入与其他覆盖在有新接点的验证中继续保留。完整S128写回/RoPE/Attention、整图与联合物理仍开放。

[审核记录](../m004_simplified_start_20261014/lnq_wi_stage_review.md)及[机读证据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)字段revision12_at179_at195_stage_review保存原结果。以下为此前阶段时点。

## 修订12实施下达时点：共享Embedding LN/Q/QKV及跨mode验证（2026-10-15）

[实施决定](../m004_simplified_start_20261014/embedding_qkv_connection_decision.md)已通过消息m004-embedding-qkv-row-revision12-dispatch-20261015实际送达A002，recipient turn 01a13d07-c808-7030-bedc-21a1632b7610。新cmd_mode/row及norm真实消费保存口，原bank的0..383tile保存QKV、384..511保存embedding_norm；一套LN/Q/matrix/双槽W，FFN保留。QKV key为16'h0001，gamma每行真实输入，warm须真实lease且零新增AR；切回FFN须正确cold重载，不把QKV槽误命中。

A001独立核78条文件/窗口身份和17项字节/整数布局条件，包括10对当前/AT173源码、前4行PS-final/scatter；3份大W BO父SHA仍仅历史声明。新阶段验证row0 cold、row1 warm完整N3072及norm，再错FFN warm拒绝→cold FFN完整末残差；只签实际行样本，不称S128 QKV或Attention通过。预算host300s/static1800s/RTL3600s独立记账，RTL单次1800s/1Mcycle、pilot120s计入，无OOC/P&R。新实施/测试NOT_RUN，送达不等于完成。

原修订11收束、AT173 FAIL与限定FFN分项、AT174/175缺load成功状态、Wi/Down数值覆盖及物理缺口均保留。详见[主控证据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的revision12_embedding_qkv_static_review；后文为各历史阶段时点。

## 修订11已按成本出口收束（2026-10-15）

新增475份冻结输入、45份原产物、95条政策采样已核。AT174限定接纳AUX两次阻塞及1AR/8R至slot0 LOAD_DONE；AT175限定接纳首W AR/R0共同reset后510拍所测隔离，以及新cold slot0 AR/R计数至LOAD_DONE。两例未检查load_error==0/READY身份，不称完整成功冷载或完整FFN恢复。AT176加载先拒绝、AT177目标前W数据断言失败、AT178超时均未完成目标数值映射测试；原终态保留。

AT173整次FAIL及已核FFN冷/暖数值和有限恢复分项保持，AUX短例不回写长例。修订11最终static约1142.970s/1800s、RTL约4724.408s/4800s，余75.592s封存，不重置/转移；host完整累计UNKNOWN。Wi/Down bad/poison、内部主动反压、部分R后reset及联合物理未证。当前转向embedding LN→Q→Encoder0 QKV的最小静态接点和同输入参考核查，问题已送A003；尚无新RTL/EDA预算。完整模型继续开放。[阶段审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)。

## 修订11 AT173中间审核：FFN单行数值/所测恢复限定接纳（2026-10-15）

主控核379份冻结输入、44份原产物及10次guard政策；AT173顶层92941815…、22份原夹具及AT050残差row0绑定一致。真实FP发1/convert返0与G发2返0的510拍隔离、所测两reset序列后的完整cold FFN残差、W标签错后无reset完整warm残差均有Fatal之前的有效断言与完成点；结果重复/倒序读、保持和release竞争通过。整体终态仍FAIL_TB_AUX_STALL_COVERAGE_ZERO（child1/null，2131.186815s），AUX AR受控停顿未命中，不写整体PASS。

截至AT173 static506.331534s/1800s、RTL3688.187977s/4800s，余1111.812023s（后续另扣），全部pilot/失败/旧SHA正常full费用保留。工程按原合同继续有成本依据的AUX等短探针，不重跑长基线、不追加额度。当前ADD逐项退休，仅1项在途，研究≤2060cycle估算不适用；cmd握手/尾部精确时序未采样。数值bad/poison、其他内部反压与AXI在途reset等按所测范围保留缺口，完整模型/联合物理仍开放。[集中审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)。

## 修订11实施已下达，研究交叉核查接纳（2026-10-15）

决定D-M004-FFN-ROW-RESIDUAL-01已以m004-ffn-residual-row-revision11-dispatch-20261015送达A002。同一FSM保存外部真实握手的4096B skip，Down成功排空/释放后复用32credit精确ADD，1024结果有序覆写现bank且无债务/错误才发布。done_phase扩4bit、8为RESIDUAL，0..7不变；64bit保持可复用已退休G寄存器，独立8B保持也在原合同内。

A003依据交叉核查35项记录中33项身份一致，其余为派发后改变的工作top/TB历史快照；冻结AT166和全部8项保存字节关联成立。原AT050残差row0 SHA2166b4a0…仅作checker，不运行新oracle/gold。≤2060cycle尾部仅为结构估算。工作修改不继承旧功能PASS；尚无新段结果交付。

新段host累计300s/8GiB、static1800s/24GiB（单次600s）、RTL含pilot4800s/8GiB（单次2700s/全局1Mcycle，pilot120s计入）。保留一个重工具及CPU0–3/nice19/idle、MemAvailable>192GiB约束；无OOC/P&R/新代理。验证合并真实FP/G在途reset→完整cold恢复、实际W-tag故障→无reset完整warm残差，以及有限数值bad/poison、反压/重复读/释放竞争。真实FP采样必须在实际IP接受及未返回点，AT168不能代签。局部与完整覆盖分列，普通修复按合同连续推进。[实施决定](../m004_simplified_start_20261014/ffn_residual_connection_decision.md)。

## 修订10成本出口集中审核：AT167–169（2026-10-15）

A001核279份冻结输入、20份原产物，全部源码清单匹配，同AT166顶层3a749c89…；AT168/169同94项，复用AT167已编译快照。AT168新cmd40在矩阵行流水接受2项/PS0/预留2、W读返3/3后reset；AT169新cmd50在Wi20992 PS完成后G实际发2返0/credits2时reset。两次各510拍监测row/done、front协议/提交、G提交/credit、slot readers及issue/PS计数无ghost。分别限定接纳矩阵行流水与G核心在途隔离；AT168的fp_launches位于六级整数树之前，不能据该命名认定真实浮点IP已接收请求。均无AXI在途，也没有reset后完整cold恢复。

AT167原guard把合法reset后的计数归零误判回退，202.464809s/child−9保留COST_STOP；修正仅在明确reset标记开启新epoch，其他回退仍拒绝。AT168203.568609s、AT169521.349162s均child0/null，四次guard政策全匹配。原AT166完整cold/warm数值与原失败记录保持。

修订10按实际命令终账static1113.567624s/1800s、RTL3459.293175s/3600s，余140.706825s，host未全采样UNKNOWN。该段按成本出口收束，不增加旧额度或借余额跑至少203s的冷前缀；未测的bad/poison数值映射、真实FP复位与完整恢复、错误后完整warm、内部反压、重复读/释放竞争和AXI在途reset继续开放。后继已由同SM004修订11接管真实Down＋原skip末残差与必要覆盖，执行/结果以本页最新段为准。[当前审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)、[逐项依据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的at167_at169_reset_stage_closeout保留细节。以下为此前时点。

## AT166时点守卫分类勘误（2026-10-15）

A001已按AT156–166全部20条实际命令重新分类：AT156 guard_direct/guard_ln、AT157/158 guard_ln均执行xsim，共44.618770s，先前误计入static。更正为截至AT166 static987.806881s、RTL2531.910594s、RTL余额1068.089405s；总费用未减少，原错误汇总保存在机读证据的revision10_guard_classification_correction，原guard/通信不回写。simulation_started=false是观察器字段，不能覆盖真实xsim命令与日志。AT167已完成编译另耗125.760743s，因此static累计至该编译为1113.567624s；AT167 RTL费用另计，终态待工程交付。AT166限定功能接纳与修订10原预算保持。

## AT166完整到Down冷暖数值限定接纳（2026-10-15）

A001核AT164–166共275份冻结输入、27份产物，以及17项fixture与既有独立二进制的解码/切片，全部一致。最终顶层SHA `3a749c8981e833b75a0645f92bb84546158551735758c35870847838010ddcf1`；原core/Q/矩阵算术和夹具不变。AT163→165以运算前10bit扩宽修复gate回绕，真实发射operand和全部G值通过；AT165→166修复单tile返回应取pair0而非slot号，Down全数据链通过。AT164保存Wi连续供数仅签局部core。原AT163/165失败保留，当前runner已区分进程状态和Fatal/终态PASS。

接纳 **PASS_SCOPED_FULL_LNQ_WI_G_Q_DOWN_COLD_WARM**：真实前LN row0、两槽AXI冷载、LN1024/Wi32组Q及scale/20992 PS、G2624、Down82组Q及scale/10496 PS及1024 final逐位匹配同输入独立参考。每命令31488次W读/返、issue与PS守恒；G输入逐项配对，gate tile511/512/655边界通过。冷/暖命令消费者done为TB绝对cycle178317/291678，不能当作各自延迟或II。两命令累计Wi AR656/656/82、Down328/328/41、AUX2，warm无新增LOAD AR。最终结果冷正序/暖倒序、各响应两拍等待已测，重复读及release/read竞争未测。

AT166 RTL1261.580029s、峰owned RSS967920KiB、child0/trigger null；六次新guard政策均匹配。AT156–166已核累计static987.806881s/1800s、RTL2531.910594s/3600s，余1068.089405s仅为截至AT166余额，不含后续运行或未采样host。工程继续原合同内定向短测；同等cold+warm长例已超过余额，不原样重跑或扩帽。数值bad/poison映射、错误后完整warm、顶层真实在途reset及有限内部反压仍开放，本里程碑不关闭修订10。末残差/完整图/新联合资源与物理时序尚未验证。

[当前集中回复](../m004_simplified_start_20261014/lnq_wi_stage_review.md)与[逐项审核](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的at164_at166_full_chain_review保存依据；[AT166原日志](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT166_SM004_down_ret_pair_index_full_01/guard_rtl/driver.log)保存原终态。以下为此前判断时点。

## AT163异常与定位记录（后续已由AT165/166修复验证）

A001已核AT163全部91份冻结输入的bytes/SHA、4份manifest/守卫/日志产物，并核G夹具解码与既有独立参考一致。冻结顶层SHA为a2f0dca3…，canonical G核心仍为01f88f43…，扩展LNQ为a8672a89…，Q为bb47385d…。双槽LOAD、1024个LN输出、32组Q及全部20992条Wi PS提交逐位通过；G前1472个返回通过，index1472的DUT/参考为b97327a2/3c1445eb、status0。原日志Fatal判定为**FAIL_G_NUMERICAL_COMPARISON**，guard child0/trigger null仅描述进程和成本保护终态；Down及新链完整cold/warm未通过。

冻结顶层第541行使用9bit的g_tile+9'd328作为gate索引。index1472对应tile184，184+328=512，9bit表达式回绕到0；这是明确静态位宽缺陷，与首错边界吻合，尚待动态因果确认。已直接交A002在加法前扩宽两操作数，核真实G发射的x/gate/顺序与边界511/512/655，并保持相同core和发射空拍做局部对照、随后继续合同内整链回归。保存Wi输入的局部诊断不能代签真实连接；不改gold/数值规则、不增加OOC或预算，不新增逐步放行。

AT163实耗542.019495s、峰owned RSS965572KiB、MemAvailable最低446613444KiB。已核AT156–163守卫小计static693.965556s、RTL706.982711s；这不是后续运行或未采样host准备的全账。原失败和收据保持。审核记录见[机读依据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的at163_g_numeric_failure_review，工程诊断消息及边界要求见[集中审核](../m004_simplified_start_20261014/lnq_wi_stage_review.md)。

## 修订10连接决定与修订9验收边界（2026-10-15）

主控核341项文件/收据及6份独立字节绑定。AT148真实LN/Q、冷W AXI与20992个PS提交（167936 lane-group）、5248 final在cold/warm两命令全部逐位通过；warm W/AUX零新增AR。冷/暖发布绝对cycle115019/190675，done118957/194613；这些不是命令相对延迟或整模II。AT150仅签错误排空与恢复前256PS，AT151冷RRESP/AT152及155 front局部/AT153与154统计各保持范围。内部定向反压、重复读/释放竞争、错误后完整暖行和新链共同在途reset仍需补测。

旧顶层末组bad/poison置local_fault、合法部分mask要求ff，导致数值失败错报7；工程已作工作修复33ec1486…，待动态验证。原正常证据保持旧55e18053…；没有用新源码继承错误PASS。half转换与AT085原函数一致，复用历史65536位型差分，非独立IEEE oracle。修订9原static693.750471s、RTL1781.479534s/1800s、host0.824163s下界，旧失败/守卫停止全部保留。

采纳研究唯一方案，56项源/参考切片与关键同输入字节已核：共享原Q、matrix/front、双槽W，新增原canonical G；同一20992B bank依次供Wi/G/Down，Q暂存扩82组2788B。新链完整Down为rows1/K2624/N1024，10496 stripe/83968 lane-group；成功发布1024F32，尚无末残差。新冷暖验证合并必要修复、Wi/G在途reset和标签错后的完整暖恢复；独立预算host300s/static1800s/RTL3600s及单次/RSS帽见合同，旧账不转移，不新开OOC。具体接口和连续执行要求见[集中决定](../m004_simplified_start_20261014/lnq_wi_stage_review.md)及[审核依据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)。

下列章节为此前阶段状态，当前执行以上述修订10为准。

## 当前决定：修订8测量收束，推进完整Wi连接（2026-10-15）

A001核AT138全部358项冻结输入、24份产物身份，以及AT139实际查询的最终DCP；相对AT137仅Tcl改变，与AT134共同353项输入全部一致。[审核记录](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的 `at138_at139_physical_closeout` 保存核查。接纳 **PASS_SCOPED_LNQ_SYNTH_NETLIST_AND_RESOURCES**，复用AT134同身份功能结果；修订8功能和测量完成不等于硬件时序通过。

AT138 U55C同版为37569 LUT、12543 FF、50 DSP、16 RAMB18E2、0 URAM/blackbox/latch；raw与最终DCP、资源/时序/check_timing报告齐全。前置6.667ns约束下WNS−1.408ns、TNS−863.788ns、1316个setup违例端点；最差divider/head→first_error_key，数据8.057ns/32级。AT139定点核first_error_key/numerical_error/done_status分别−1.408/+0.477/+4.014ns；首错路径仍FAIL。RAM写数据查询虽匹配pin但无路径，保持未知；无未约束内部端点，95输入/416输出仍无外部delay。无P&R，实际Fmax未知；AT131与本版RTL及约束流程同时变化，不作单因归因。

AT138 guard child0/null、406.915653s、峰owned RSS20558300KiB；AT139 child0/null、60.418869s。原修订8最终OOC1078.301400s/1800s、static118.292583s、RTL30.857233s，host未采样部分UNKNOWN。AT135–137失败和成本保留；普通Tcl容差修复完成，首个有效网表后收束。**当前不再Q改版/OOC/定点查询；DIV返回/FP16恢复至首错归并登记为后续联合物理闭合缺口。** [集中交付回复](../m004_simplified_start_20261014/q_metadata_measurement_recovery.md)复用原测量决定文件，不新增mission或逐步放行。

**D-M004-LNQ-WI-ROW-CONNECTION-01 / SM004修订9** 采纳研究唯一方案；A001核20份来源/产品、6份row0切片及PS front/W cache实际接口。真实AT040前LN row0与完整Wi独立gold建立同输入链，保持K1024/N5248、32group/656tile/20992stripe；不用P1不同输入的8列结果扩充gold。复用LNQ发布暂存、每group A/sa锁存、W一个活动槽真实冷载/lease/read/release、同步PS/Q35和20992B独立结果行。现四行算术/双槽W的物理容量保持，未宣称缩面积。[连接指令](../m004_simplified_start_20261014/lnq_wi_connection_dispatch.md)已下达。

front只补外部abort→DRAIN：同拍禁止新issue/launch，预留按真实RAM返回丢弃、已发FP真实退休，abort与末完成同拍仍失败；未改正常数值或伪造expected_stripes/零债。冷正常、无reset暖反压的完整逐PS/final比较与有限读错/排空/reset覆盖为本段出口。修订9host300s/static1800s/RTL1800s及各单次/RSS帽详见[合同](../../project/missions/SM004.md)，修订8已结束，工程进入本段源码准备，重工具串行、成本独立；本段无新联合OOC/P&R。研究方案已接纳，新连接功能与资源/时序仍未验证。

以下各节保存此前决定与适用时点，不覆盖上述当前状态。

## AT134–136集中判断：功能接纳，纠正综合静默判据（2026-10-15）

A001核353/355/358项冻结输入（共1066项）均匹配，AT134与AT136共同353项一致；当前Q SHA为`bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`。复核元数据寄存/首错平衡归并和TB真实返回上的有限坏值注入、守恒/释放/reset；接纳 **PASS_SCOPED_Q_ERROR_METADATA_AND_LNQ**。原114真实组/3648B、27 adapter独立gold及两真实P1行统计/1024 F32/q/scale保持，gamma0/gamma1至row_valid仍8597/11087拍。末坏half、连续两候选同拍交接、三来源首错与候选valid时reset按四个受控样本接纳，不能称自然模型算术异常或完整图通过。

AT135漏IP Tcl，综合前child1/7.481030s；AT136前置6.667ns约束已实际应用，但292.768357s时由120s日志静默触发`semantic_stall`/child−9，owned RSS峰17389648KiB、MemAvailable最低433047680KiB，未达1200s/24GiB帽。冻结守卫只以stdout匹配阶段词刷新semantic_last，日志静默并非算法停滞的充分证据；没有CPU时间/算法进展采样，不能声称它当时一定仍在计算。**无有效DCP/资源/check_timing/WNS/TNS，本版物理结果UNKNOWN**，AT131旧物理结果不迁移。[逐项审核](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)追加本次证据。

决定 **D-M004-SYNTH-LOG-SILENCE-CORRECTION-01**，详见[测量恢复指令](../m004_simplified_start_20261014/q_metadata_measurement_recovery.md)与[SM004修订8补充](../../project/missions/SM004.md)。工程按原2/2上限停止正确；主控针对守卫与综合阶段不适配，现仅追加1次恢复启动，把综合静默阈值置1201s、总墙钟仍1200s，保留24GiB及其它资源限制。原OOC300.249387784s不重置，累计仍≤1800s；AT136 RTL/IP/XDC/综合设置不变、AT134功能复用，任一终态交付，无第四次。原static57.873714s/RTL30.857233s与未采样host成本保留。研究只做下一真实LN→Q→矩阵A的有限静态连接方案，不运行EDA或重审全图；下一总体方向保持真实数据链集成。

## 当前决定：错误元数据切分（修订8，2026-10-15）

**D-M004-Q-ERROR-METADATA-PIPE-01** 已送达A002/A003，原生回执均为delivered并有recipient_turn_id；送达不代表新候选已验证。[执行决定](../m004_simplified_start_20261014/q_error_metadata_engineering_dispatch.md)和[SM004修订8](../../project/missions/SM004.md)规定设计、验收与独立预算，继续同一主mission。

AT133只读AT131同一DCP，三份冻结输入与DCP逐bytes/SHA匹配；11份报告/guard产物身份已记录。first_error_key、numerical_error、done_status分别为WNS−1.134/−1.519/−1.750ns，数据延迟7.783/8.168/8.399ns。因此done改读已提交寄存器虽与原完成谓词等价，单独修改仍不足。四类RAM写数据端点未得到路径，保持UNKNOWN。查询60.813549s、child0/trigger null；修订7static最终269.456193s，RTL100.811515s、OOC248.809009s不变，未采样host仍UNKNOWN。[审核依据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)保存核对结果。

只增加valid＋16bit坏mask＋64bit完整key前缀的81bit寄存级。原MUL返回仍转换/写q，坏mask立即阻止错误槽正常输出；下一拍平衡选择最低坏lane，与AMAX/DIV/已提交key做两级min。numerical_error取原本地坏事件sticky OR；done只读已提交状态，新候选必须纳入start、完成、零债务与reset。完整key在返回时锁存，候选消费/新捕获可同拍，保留原int8舍入和FP16规则。受影响短测覆盖末坏half、连续候选、跨来源首错、slot释放与归并同拍、候选在途reset及真实gold恢复。

同版功能通过后，6.667ns时钟XDC必须在综合优化前读入；首个成功联合网表后结束本候选，不预签150MHz。与AT131的对照同时包含RTL及约束流程变化，不把改善全部归于寄存切分。新段累计帽host300s/static1200s/RTL900s/联合OOC1800s，单次及RSS约束详见合同；无P&R或旧版补跑。此段出口仍服务于后续矩阵A连接和完整固定图，尚无完整硬件性能结论。

## 修订7交付集中审核：AT130/131（2026-10-15）

接受 **PASS_SCOPED_Q_PARTITION_AND_LNQ**；150MHz综合内部时序仍FAIL。A001核761项冻结/日志/manifest/guard/产物身份，AT130与AT131全部352份共同文件一致，DCP SHA匹配，并核新选择器/寄存/真实债务与TB相位触发。最终Q `a1fd5b03…`；LN `a46d468e…`、顶层`7c194fa3…`未改。[逐项依据](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)追加at131_q_partition_review。

独立Q的32＋82真实组、3648 Q字节及27原adapter边界逐位通过；82组164次扫描/预约/真实FP发射守恒，四槽/银行比较与独立标量选槽核对，受控平局只签比较语义。扫描、已预约、已分类、FIRE受阻四相位reset与无额外reset的gold恢复通过；真实LN→Q还复核FP已发未返共同reset和旧raw返回隔离。两P1真实行的LN统计/1024值和q/scale、5正常/4错误、反压/可复读/释放保持。gamma0/gamma1至row_valid为8597/11087cycle，同刺激增加24/23；消费者done包含故意读等待。快速供数82组Q任务2156cycle/输入停1173cycle是当前容量证据，不能用LN每行仅多24拍外推所有Q消费者均无吞吐代价。

AT131同版U55C联合资源37346 LUT、12518 FF、50 DSP、16 RAMB18E2、0 URAM/blackbox/latch；相对AT116为LUT−4309（−10.34%）、FF+326，算术/RAM数未变。WNS−1.750ns/TNS−1225.669ns，1294 setup违例端点。最差从FMUL结果至done_status，39级/8.399ns，原32槽选择链已消除。AT132最终DCP输出仍为实际LUT2，不能用中途常量警告判最终裁剪。两版均在synth_design后才create_clock，故是同设置综合网表计时，未按目标时钟优化/未P&R；实际Fmax未知。

原修订7实耗static208.642645s、RTL100.811515s、唯一OOC248.809009s；AT126缺TB端口FAIL、AT128无DUT启动exit127保留，均计入预算。host guard未运行的0不等于轻量准备零成本，未采样保持UNKNOWN。首个成功OOC已收束，不原样续综。A001已交A002一次现有DCP四类端点最差路径只读查询（原static余量、≤120s/24GiB），A003只核首错/完成最小性；下一候选将6.667ns约束前移到综合优化前，须明确与旧流不再是单一RTL变量比较。无用户审批项，不启动P&R或矩阵连接重工具。

## AT124复位覆盖关闭（2026-10-15）

A001核109份冻结文件及manifest/guard/原日志共114项身份，27份共同非TB RTL与AT116同版，并复核TB实际触发/隔离观察。接纳 **PASS_SCOPED_LNQ_FP_INFLIGHT_COMMON_RESET**：row31新cmd与Q start各1次，2half真实接受；route0 FP发1/返0、div_pending=fp_pending=1时共同reset。随后16拍内旧FP原始result_valid出现1次，FP/语义接受、Q输出/row/done及protocol_fault均无，12拍quarantine结束且债零；下一真实P1正常行逐位通过。

关闭修订6此次算术在途reset缺口。AT121原marker不追认，AT123只签已收未处理组，AT122失败原样保留；不外推其它相位、AXI或新架构reset。原连接段以host1.606030s/static404.133281s/RTL175.407140s/唯一OOC242.194084s收束，AT116的时序FAIL保持。[接纳通知](../m004_simplified_start_20261014/lnq_reset_closeout.md)已交工程；工程现已接管修订7，不需额外批准。下文reset待补段落为此前审核过程。

## Q时序集中决定（修订7，2026-10-15）

决定 **D-M004-Q-TIMING-PARTITION-01** 已直接送达工程/研究，详见[执行指令](../m004_simplified_start_20261014/lnq_timing_engineering_dispatch.md)。A003拆解原路径，A001核9份来源身份：231级/55.661ns中194级/49.778ns对应32槽argmin串接；tiny实际已有六级helper，不能按综合层级名称误判为组合30步tiny除法。

采用一个待发描述符：资格快照→8拍每拍4槽比较→预约/raw/tag→分类/最高位→操作数寄存→真实FP接受。无阻塞积压时接受间隔13拍；同组至多两请求26拍与当前至少34拍/group供数只是设计容量比较，不是提速实测。原精确tiny/subnormal、舍入/首错、FP/helper双返回及物理排空保持。主控同时将AMAX/REPLAY的同型线性argmin改为显式五级平衡树，保持原逐拍选择/两half读取语义；不预签时序。新scan/预约/待发债务与reset必须实测。

修订7预算为host600s/static1800s/RTL1200s/联合OOC1800s及各单次/RSS帽，首次成功网表后停止，至多一次有因普通构建纠正；无独立Q OOC/P&R/完整模型重跑。仅新候选消耗新预算，旧修订6修复不转移。下一出口是同版精确Q与LN→Q回归、总周期/接受间隔及联合资源/新最差路径；当前新候选尚未取得结果。

**reset补证进展。** AT123的109份冻结文件及日志/guard共113项已核、27份共同RTL与AT116一致；实际新cmd/row31、Q start、2half、accepted1/covered0已证明，关闭AT121旧计数导致零循环的问题。但触发位于第二half后的紧邻negedge，首组刚到AMAX_READY，尚未证明算术/输出在途。已要求原预算内移到真实FP已发未返、记录issue/return/pending、观察12拍quarantine后无旧返回接纳，再接真实正常行；AT123保持已接受未处理组的限定范围，AT122采样断言FAIL保留。当前原段累计static371.231127s、RTL163.986859s，唯一OOC不变。

## LN→Q连接集中审核（AT116/AT121，2026-10-15）

A001独立重算251项冻结文件、manifest、guard和产物bytes/SHA均匹配；AT116与AT121共27份非TB RTL逐字同版。[核查记录](../m004_simplified_start_20261014/lnq_review_evidence_20261015.json)。顶层为`7c194fa3…`，LN为修复版`a46d468e…`，Q为`23c18d6a…`。

接纳**正常行/四错误路径的局部数值与接口证据、同版联合综合资源**。AT121五正常行的真实input/gamma→LN全部1024值/三统计→32组q/scale逐位匹配历史独立核验夹具；gamma0到row_valid为8573cycle，embedding gamma1含输入空拍与42cycle Q输出阻塞为11064cycle。倒序/重复读取、响应保持、release优先、错误行不发布及错误后正常行按所测范围通过；P1样本不是当前production-v2完整请求。

**在途reset覆盖暂不接纳。** 冻结TB先检查旧q_started/half_sent，再发新命令；前行done后这些值仍可为1/64。原日志`pre_reset_half_sent=64`符合循环零次执行，新命令未被证明接受的缺口。尚无DUT reset失效证据。[普通TB修复已直接交工程](../m004_simplified_start_20261014/lnq_reset_coverage_fix.md)，要求本次命令/row/RUN及真实未退休Q工作、复位前锁存、无ghost与随后真实行；使用修订6剩余static/RTL，不追加OOC。原AT121日志和各自正常/错误结果保留。

AT116为U55C同版LN+Q+pack/可复读暂存：41655 LUT、12192 FF、50 DSP、16 RAMB18（8 tile）、0 URAM、blackbox0；本地1088B行暂存映射LUTRAM。内部WNS−49.011ns、TNS−50792.254ns，最差ordinal→divider路径55.661ns/231级；**150MHz综合内部检查FAIL**。无外部delay/P&R，实际Fmax未知，不以面积或周期替代可运行性能。AT120同DCP核row_valid/done_valid由LUT2驱动，消除最终GND裁剪疑问但不消除时序问题。

原修订6实耗host1.606030s（极短采样缺口保留）、static307.264625s、RTL144.865745s、唯一OOC242.194084s，均在原帽内。A003[定向核查实际路径](../m004_simplified_start_20261014/lnq_timing_research_request.md)，只形成一套保持精确tiny/次正规规则的寄存/多周期切分；工程不擅自重启OOC。下一阶段由A001在同SM004明确接口/预算；完整AXI/HBM、矩阵A读取、final gamma和完整硬件图仍开放。

## AT110首错修复接纳（2026-10-15）

主控核215项冻结/夹具/guard/当前RTL及原行参考身份无差异，并核原日志及唯一受影响RTL差异。AT109旧RTL动态复现bad1023对参考bad0的语义FAIL，零输出；AT110取消DELTA1末提前DONE，保留候选并完成SQUARE，原反例和抵消溢出均正确bad0/零输出。常数、交替抵消、近常数、次正规四条正常行的全部1024输出与统计值逐位通过；六例边界与原九例回归均通过。真实gamma0/gamma1仍8482/11792cycle，复位前MUL发射计数现正确锁存为8。

接受 **PASS_SCOPED_LN_FIRST_ERROR_FIX**，关闭此前DELTA1/square首错缺口。当前RTL SHA `a46d468e3e03e0feef55f36f4be8425d7a3468a13e7c68f16624b213b9ce5f72`；[主控依据](../m004_simplified_start_20261014/ln_row_review_evidence_20261015.json)追加at110_closeout，原收据不改。此次主控只读核查0.016386s，未重跑实验。AT109初始manifest早于生成夹具的缺口用另列13份边界夹具身份说明，不追写历史清单。

原LN实耗host1.804670s为下界，static175.923183s、RTL49.592227s、唯一OOC152.791918s；AT108的14279 LUT/3375 FF/2 DSP/WNS只属于旧SHA，修复版等LN→Q联合OOC。真实final gamma缺口和受控gamma竞争force的范围保留。[关闭与继续决定](../m004_simplified_start_20261014/ln_first_error_closed.md)直接交工程/研究，连接合同与预算不变。下文“待修”是此前审核时点。

## LN→Q连接设计与执行决定（2026-10-15）

A003交付同输入P1来源、量化布局及当前Q完成/错误语义，A001复核14份来源身份和两份Q布局一致，未运行oracle或生成gold。采用一个512bit pack＋q0/q1各32×128bit＋32×16bit scale，新增1152B payload；整个LN/Q资源另需实测。量化参考每组为LE16 scale＋32个int8，连续32组，不能误读成两个大连续区；历史样本为abi_replay B2中的单行，不称production-v2完整请求。

连接以LN首out_valid触发Q start，避免等待LN done的环；真实1024元素流入Q，成功done/实际64half及32scale覆盖/零债务后才发布row_valid。对外支持重复同步group读，读响应反压保持，独立release排空读取后释放，成功done在release之后。Q数值失败保留输入排空，协议提前结束丢弃LN余数；错误行始终不可读，不使用旧portal/lease/hub。

[工程指令](../m004_simplified_start_20261014/lnq_connection_engineering_dispatch.md)已送达，新增连接host600s/static1800s/RTL1200s及有限联合OOC预算仅用于新连接，原LN首错修复仍计旧预算。真实输入/原gold、连续行、合法反压、错误隔离、在途共同reset、计算至行可用周期和完整连接资源是出口；尚无新连接启动/通过或Fmax。A003[定向研究任务](../m004_simplified_start_20261014/lnq_connection_research_decision.md)完成，不新增分析分支。完整矩阵/外部搬运/整图仍开放。

## LN单行集中审核（2026-10-15，AT102–108）

A001核AT104/107/108共65/20/22份冻结文件及来源、AT107/108各7份fixture、原日志/guard和OOC产物，269项身份引用无差异。[核查依据](../m004_simplified_start_20261014/ln_row_review_evidence_20261015.json)保留边界；仅本次有界host核查0.034373s和路径复核0.000948s，交互读取历史耗时未统一采样。

- 接纳AT104固定CE的16组叶子样本，MUL/DIV/SQRT所测lag14/12/6、II1，不扩展到任意数值域或CE暂停。
- 接纳AT107九例既有样本：两棵树各10层、真实gamma0为8482cycle、真实embedding gamma1含反压11792cycle，mean/variance/inverse与1024输出逐bit匹配历史独立核验夹具。gamma2复用gamma1数据；gamma与normalize竞争由TB force验证。局部在途reset后新行通过，复位前计数日志为复位后读数，不能用于实际在途计量。
- 接纳AT108冻结SHA `da8adccc…`的局部综合：14279 LUT（5460 LUTRAM）、3375 FF、2 DSP、0 BRAM/URAM、blackbox0；内部WNS +1.967ns@6.667ns，未布线且无外部delay。14KiB逻辑payload未映射BRAM；重复ADD定义字节相同，后续构建清单去重，不增加本段OOC。
- **首错合同待修复。** 原函数逐元素先delta再square；现DELTA1整扫后遇错直接DONE。host反例为1024项正零，x[1000]=x[1022]=`ff7fffff`、x[1023]=`7f7fffff`：树均有限、mean=`fa7fffff`，第0项平方溢出早于第1023项减法溢出。原语义bad=0，RTL静态路径预测bad=1023；动态复现尚未运行。正常数值样本不因此改签，完整首错验收暂不通过。

[工程修复指令](../m004_simplified_start_20261014/ln_review_engineering_response.md)已送达：保留原冻结证据，先用未改RTL复现，再保留delta候选并完成可能更早square检查，做真实行/首错/连续恢复受影响短回归及必要常数/近常数边界。原static106.040047s、RTL29.865697s继续累计；唯一OOC已用，修复后不能把旧OOC写成新RTL同版证据。host历史准备计量缺口保留。

下一数据路径方向选择LN→16元素打包→现有Q。A003[定向核查](../m004_simplified_start_20261014/lnq_connection_research_request.md)只处理同一行Q/scale参考与完成/排空接口；当前未启动该连接RTL或扩大预算。仍是同一M004/SM004，不新增mission。

以下首build记录保留其发生时状态，后续软件结果以上文为准。

## 首个真实构建启动（AT088）

A002已于2026-10-14 22:18:19（Asia/Shanghai）启动当前源码的受保护软件构建。主控核preflight与原launch/guard：选B1_from_b0_S128、request3/generation1，47份独立checkpoint/final与原收据身份匹配；此次只选一个正常请求，不覆盖原四请求序列或故障恢复。

首个build在14.286626s以child1结束，完整full_csim目标已链接，随后独立numeric测试目标缺check_context链接依赖。整体构建失败保留；尚无本次完整请求运行或数值结论。这是本段已授权的普通构建修复，A002继续处理，不新增mission或用户审批。实际编译闭包与旧包差异显式记录，旧源码通过不代签当前源码。

[preflight](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT088_SM004_full_software_b1_01/preflight.json)；[首build原结果](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT088_SM004_full_software_b1_01/build_guard/guard_result.json)。

## 向量段首个实际启动（AT092）

A002已接管SM004修订3。AT092于2026-10-14 22:47:50（Asia/Shanghai）启动两种现存ADD叶子的XSim编译/展开，guard在7.044748s以child0、无trigger结束，峰261312KiB。A001核实际launch/plan/result、静态日志与7项冻结输入bytes/SHA相符。首探针使用原52组directed ADD fixture；这次编译完成不证明数值、II或连续接收能力，真实4096对残差与封装/搬运/OOC仍依后续实际记录验收。

原[启动记录](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT092_SM004_vector_leaf_probe_01/guard_static/launch.json)与[编译结果](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT092_SM004_vector_leaf_probe_01/guard_static/guard_result.json)。工程在同段预算内继续短RTL与受影响修复，不新设审批。

## 向量段集中判断（AT092–099）

A001核AT093/097/098/099冻结输入、原日志、manifest及AT099四份OOC产物bytes/SHA相符，报告和真实源码交叉核查。**接纳算术流限定PASS；搬运服务待修复。**

- AT093真实4096对残差逐bitgold通过，连续接受II=1，正常4103cycle、确定反压6444cycle，32项总容量与16项在途局部reset通过。AT098仅签原52定向及CE暂停/复位样本，不推全F32域。
- AT099同SHA单lane流封装＋CE ADD为1283LUT/614FF、DSP/BRAM/URAM0，内部WNS+3.057ns@6.667ns；仅综合，未布线、缺外部delay，不是完整AXI服务资源或实达Fmax。
- AT097使用一次256×64B=16KiB突发，原三基址0x10000/0x20000/0x40000，跨4KiB违反AXI4。TB仅固定核len255，未检查边界。原正常6928cycle/反压7185cycle和gold/保护观察保留，不称合规服务性能，也不据此发布旧新加速比。
- 新服务缺少原add_row对两输入及结果的finite检查，可能将非有限值报OK；需补原E_NUMERICAL和按逻辑序号的首错。具体完成口、合法排空、分段和受影响用例统一写在[SM004修订4](../../project/missions/SM004.md)，已[直接要求工程普通修复](../m004_simplified_start_20261014/vector_review_engineering_response.md)。

累计工具时间static36.409680s、RTL28.104722s、唯一OOC78.220358s；剩余原static/RTL预算继续用于这些修复，不重置、不再OOC。host准备未独立采样缺口保留。A003仅在既有轻量预算准备LN完整单行的精确树/银行/算术接点，见[定向任务](../m004_simplified_start_20261014/ln_next_research_request.md)。

[工程阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md)和[原机读证据](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_evidence_20261014.json)保留原运行身份。

## AT101修复接纳与LN实施决定

A001核AT101 receipt、static/sim原guard与日志、13项冻结输入bytes/SHA、工作服务与冻结SHA一致，检查分段/首错RTL及TB独立4KiB边界断言。接纳 **PASS_SCOPED_VECTOR_AXI_4K_FINITE**：10条无reset连续局部命令，4KiB对齐4096项正常6955cycle/反压7206cycle，8AR/512R/4AW/256W/4B；不同页内偏移、70beat尾块、原gold/64KiB保护、数值首错7/2及RRESP/BRESP错误屏蔽与排空通过。AT097原记录仍非AXI合规证据。

向量段工具累计static44.381434s、RTL34.727431s、OOC78.220358s；host准备采样缺口保持。AT099只复用未变单lane流，当前不增加向量综合或性能搜索；外部HBM、总线服务面积/布线频率、AXI在途reset和全图均未验。

[SM004修订5](../../project/missions/SM004.md)确定下一完整LN单行：一个ADD/SUB、MUL、标量DIV、SQRT，X/G/T0/T1共14KiB，原相邻树及每步舍入；先核实际叶子延迟/II与精确样本，然后完整真实gamma0/gamma1行及统计值、反压/连续行/局部reset/首错，最后一次同版行服务OOC。真实final gamma2夹具未确认，覆盖缺口保留。新增预算只覆盖这一LN范围，不恢复旧候选。[工程指令](../m004_simplified_start_20261014/vector_accept_ln_dispatch.md)已送达；A003[单行方案](../../source/fixed_graph_architecture_20261014.md)已接纳。LN新工具是否启动仍以工程实际回执为准。

[AT101原收据](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT101_SM004_vector_axi_4k_finite_02/receipt.json)；[当前唯一工程报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md)。

修订15实际投递：m004-source-s128-revision15-implementation-dispatch-20261015 → A002，turn 01a13e5f-1a2f-75e2-baae-fdeaa084d917；范围答复m004-s128-source-static-adoption-rev15-20261015 → A003，turn 01a13e5f-dd0f-7b33-8cb8-3b7dadd1b1e9，均delivered。工程运行/验收另按实际证据记录。
