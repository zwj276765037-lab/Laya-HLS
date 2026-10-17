# 修订11阶段收束：AT174–178短探针限定接纳，数值错误缺口保留

2026-10-15；A001；M004/SM004/E004/R001；回应m004-rev11-at174-at178-stage-closeout-20261015。决定D-M004-REV11-CLOSEOUT-01：按有界成本出口收束修订11，不给全项阶段PASS，不继续使用剩余RTL预算启动仿真。M004整体仍running/unassessed。

主控核AT174–178各95项、合计475份冻结输入及45份manifest/原日志/guard产物，逐bytes/SHA一致；95条实际CPU/nice/idle政策采样全匹配。顶层均为AT173的92941815b70e58df6f6d27edb988e9d318abfe566dda5f588775480c00dcd463，23份fixture与AT173完全相同；相邻尝试只改TB/runner，重编模式及compiled_parent来源已核。[机读审核](lnq_review_evidence_20261015.json)追加revision11_at174_at178_stage_closeout。

- AT174：接纳真实AUX AR的2个阻塞采样拍、随后1次AR/8次R及slot0 LOAD_DONE事件；guard child0/null、129.358357s。冻结TB终止断言未检查load_error==0、READY身份或lease成功，原日志也未输出该状态，因此只签事务计数至LOAD_DONE，不补称成功可用W槽或完整冷行。没有独立的AR全字段在两拍停顿期间稳定断言，不扩大为任意AXI反压覆盖。
- AT175：接纳W q0首AR已接受、R0/left64时DUT与总线模型共同reset，510拍所监测端点无旧活动；新cmd72真实slot0重载至LOAD_DONE，W AR656/656/82、R41984/41984/5248，AUX1/8，guard child0/null、129.176531s。终止断言同样缺load_error==0/READY成功检查。该样本不证明部分R返回后的reset、独立物理总线复位、全系统所有债务或reset后完整FFN。共同模型reset清除旧总线事务属于本样本合同，不是正常事务排空证明。
- AT176：外部模型末scale half +Inf在LOAD被拒绝，status7/phase0/bad167935、Wi PS0，child1/null、120.644968s；保留FAIL_PROBE_NOT_REACH_FRONT，不推断前端数值6或poison。
- AT177：首个W返回group0/tile0/lane0出现W_BANK_MISMATCH，目标注入尚未触发，child1/null、206.639684s；保留FAIL_TB_BEFORE_INJECTION，此命名不等于本次审核已查明根因。
- AT178：450.400088s/child−9/timeout，最后记录约cycle115000/group21、Wi PS13779；没有目标ISSUE_INJECT标记，保留COST_STOP_TIMEOUT，不认定状态6/首错/poison或排空已测。

AT173原整次FAIL_TB_AUX_STALL_COVERAGE_ZERO保持；AT174只增补独立端点样本。前述AT173同版真实FFN冷/暖数值、FP/G复位序列后完整cold、W标签错后完整warm及读释放分项接纳保持，完整范围和单项ADD调度界限沿下文中间审核。Wi/Down bad/poison状态映射、内部主动反压、ADD在途/末项错误补测、部分R后reset、本顶层联合OOC/P&R/Fmax仍开放。

实际guard合计static1142.969831845s/1800s、RTL4724.407605240s/4800s；人读约1142.970s/4724.408s，余RTL约75.592s封存不转移。工程末位显示与直接原值相加约差1微秒，只属显示舍入，不改费用/结论。host完整累计仍UNKNOWN。原AT170–178所有失败、pilot、守卫误停及旧SHA正常full均计入，不重置旧账，不再沿冷LOAD跑同一末组数值注入。

后续固定图方向为真实入口侧embedding LN→Q→Encoder0完整QKV，保留当前FFN为后续消费者。A003已收到m004-embedding-qkv-minimal-next-design-20261015，核实际embedding gamma/Encoder0免重复LN、QKV布局/数值、共享LN/Q/matrix/W配置与同输入独立参考，并列RoPE/Attention的128行依赖。当前只做既有资料和字节身份静态准备（轻量脚本累计≤60s/1GiB），不新增EDA/模型/gold/代理；接口与后续实施预算待该有界证据后在同SM004确定，不向用户重新索取普通实施权限。

---

# 修订11 AT173中间审核：完整FFN数值/所测恢复分项接纳，运行终态FAIL保留

2026-10-15；A001；回复m004-rev11-at173-aux-stall-terminal-risk-20261015。此为截至AT173的中间审核，修订11继续原合同短测，不是阶段全项验收。

主控核AT170–173共379份冻结输入、44份manifest/原guard与日志产物，全部清单匹配，10次guard采样政策均匹配。AT173顶层SHA92941815b70e58df6f6d27edb988e9d318abfe566dda5f588775480c00dcd463；相对AT172修正ADD valid独立于ready及skip末握手fault处理，重编top/TB已核。22份既有fixture与AT166同身份；新增残差1024值解码等于AT050原row0，SHA2166b4a0…，未改gold。[逐项证据](lnq_review_evidence_20261015.json)的revision11_at173_intermediate_scope_review。

AT173原终态保留 **FAIL_TB_AUX_STALL_COVERAGE_ZERO**：child1、trigger null、2131.186815s、峰968272KiB。唯一Fatal为终端AUX AR受控停顿计数0，缺GQDOWN_COMBINED_PASS；不能改成整次PASS。已完成且在Fatal前持续受断言检查的以下分项可接纳：

- cmd51本行真实fp_restore.valid_a在时钟沿驱动convert/multiply IP输入，接受1/convert lane0返回0、预留4后共同reset；510拍所监测语义端点隔离通过。该观测补上AT168行流水入口与实际IP入口的区别，不外推其他FP返回阶段或全部lane逐个监测。
- 随后cmd52真实cold前缀完成Wi20992 PS，在G实际发2返0/credits2时共同reset，510拍隔离；两个reset触发均无AXI在途。
- 这两次reset序列后，cmd61完整cold从真实前LN输入到LN1024、Wi Q32/20992 PS、G2624、Down Q82/10496 PS，再以真实skip/Down得到1024残差，逐位核至消费者done。该结果证明所测复位序列后的完整恢复；不称每个reset窗口各自独立后接完整cold。
- cmd62在实际W返回、issue16/预留11、W读17/返16时注入标签错；随后W17/17、front abort/error、所测预留/返回槽/reader债零且无发布。cmd63无reset完整warm至同一全链残差消费者done，W两槽及AUX AR较cmd61零新增；此为所测W标签错后的完整恢复，不代签数值bad/poison恢复。
- 每个成功行读取128tile（cold正序、warm倒序）再重复tile0/127，逐响应保持2拍核valid/tile/全部256bit，release与新read同拍优先通过。W AR阻塞及R插入空拍已命中。1163/33587是跨整次运行“至少一口满足条件”的时钟计数，多口同拍NBA只加1，不是每口stall数或带宽。

AUX AR停顿仍未证，独立同DUT短探针可补此端点但不能覆盖原FAIL。Wi/Down数值bad/poison映射、主动内部W返回/front issue/commit/ADD消费停顿、ADD在途reset及AXI在途reset等未由本例证明。当前残差为RES_READ→RES_SEND→RES_WAIT逐项退休，最多1项在途；原32credit ADD叶子未变不等于新顶层测到32项并发。研究≤2060cycle估算不适用于此调度，缺真实cmd握手/残差起止采样，不能报告精确请求latency、II或该尾部上界；不为补指标重跑长例。

AT170–173按实际命令复账：static506.331534s/1800s，RTL3688.187977s/4800s，余1111.812023s（后续另扣）。其中AT170 pilot超时120.446267s、AT171 guard计数误判32.270439s及AT172旧SHA完整正常1337.750995s均计入；不回写旧FAIL/COST_STOP，不再重复正常cold/warm。工程继续原合同内保证命中的AUX短探针及有成本依据的剩余定向例，按场景分列真实覆盖；不新增预算/OOC/P&R或逐步审批。整模型与联合物理仍未验。

---

# 修订10成本出口集中审核：正常链与两类在途隔离限定接纳

2026-10-15；A001；M004/SM004/E004/R001；回应m004-gqdown-reset-at168-at169-stage-handoff-20261015。本节为当前集中判断。

A001核AT167/168/169共279份冻结输入、20份原产物身份，清单全部匹配；顶层均为AT166的3a749c89…，AT168/169共同94份完全相同。AT167相对AT166只改TB与runner；后两次只增加守卫源码并换reset模式，复用AT167实际编译快照。原命令、日志、policy及guard epoch修正已核，四次guard采样政策全部匹配。[逐项依据](lnq_review_evidence_20261015.json)追加at167_at169_reset_stage_closeout。

接受AT168 **PASS_SCOPED_WI_ROW_PIPELINE_INFLIGHT_RESET_ISOLATION**：新cold cmd40在row pipeline已接受2项、PS0、预留2且W读返3/3后共同reset，510拍所监测端点无旧发布/提交/协议错，G credit和slot reader/issue/PS计数保持零。必须收窄“FP发2”的转述：TB的fp_launches实际统计row_issue_valid && row_ready，后面尚有六级整数树；没有真实fp_restore.valid_a/IP发射采样，不能签物理FP已发未返。这不是DUT复位失败；A002已在m004-at168-row-pipeline-scope-correction-20261015确认缺少实际FP采样并收窄工程文档，不重跑旧长例。

接受AT169 **PASS_SCOPED_G_CORE_INFLIGHT_RESET_ISOLATION**：新cold cmd50完成真实Wi20992 PS/W读返后，G实际issued2/returned0/credits2时reset，510拍同一组语义端点隔离通过。两个样本均无AXI在途，无reset后新完整cold命令；不签完整恢复、所有内部信号或任意复位相位。AT166正常完整cold/warm数值接纳保持，旧AT163/165 FAIL不改。

AT167因真实reset计数归零被旧guard误判semantic_counter_regression，202.464809s/child−9为COST_STOP，隔离未完成。AT168203.568609s、AT169521.349162s均child0/null；reset-aware guard只在冻结TB的真实GQDOWN_RESET_PRE处重新建立计数epoch，其他回退仍走原拒绝规则，原单测日志保留。原始guard不回写，停止和修正后的费用均计入。

修订10全部AT156–169按实际命令汇总static1113.567624s/1800s、RTL3459.293175s/3600s，余RTL140.706825s，host未完整采样UNKNOWN。以有界成本出口收束该段，不借余额再起已知至少203s的真实冷前缀；未完成项保留为验收缺口，而非通过。缺口包括Wi/Down数值bad/poison映射、真实FP请求在途复位、reset后完整cold、错误后完整warm、主动内部反压、重复读/释放竞争及AXI在途reset。

同SM004修订11已实际送达A002，连接真实Down＋原skip末残差并合并必要恢复/错误覆盖。A003静态交叉核查35项记录中33项身份匹配，两项为派发后已改动的工作top/TB历史快照；冻结AT166及8项保存字节关联全部成立。4096B真实skip、复用原ADD/结果bank与4bit phase规则采用；64bit operand可复用已退休G保持。≤2060cycle仅为结构估算。新预算host300s/static1800s/RTL4800s独立计量，无OOC/P&R；源码已变化但尚无新段结果交付，不继承旧PASS。详见[实施决定](ffn_residual_connection_decision.md)。完整图/联合物理/整模性能开放。

---

## AT166时点守卫分类勘误（2026-10-15）

A001已按AT156–166全部20条实际命令重新分类：AT156 guard_direct/guard_ln、AT157/158 guard_ln均执行xsim，共44.618770s，先前误计入static。更正为截至AT166 static987.806881s、RTL2531.910594s、RTL余额1068.089405s；总费用未减少，原错误汇总保存在机读证据的revision10_guard_classification_correction，原guard/通信不回写。simulation_started=false是观察器字段，不能覆盖真实xsim命令与日志。AT167已完成编译另耗125.760743s，因此static累计至该编译为1113.567624s；AT167 RTL费用另计，终态待工程交付。AT166限定功能接纳与修订10原预算保持。

# AT166冷暖完整到Down限定接纳，修订10继续受影响覆盖

2026-10-15；A001→A002；M004/SM004/E004/R001；回复 `m004-gqdown-at166-full-cold-warm-pass-20261015`。本节为最新阶段判断，下文保留此前诊断与连接决定。

A001核AT164/165/166共275份冻结输入和27份manifest/guard/原日志产物，全部bytes/SHA匹配；17项fixture解码/切片与既有同输入独立二进制逐字节一致。AT166最终顶层SHA `3a749c8981e833b75a0645f92bb84546158551735758c35870847838010ddcf1`；AT163→165仅顶层gate扩宽及TB/runner改变，AT165→166仅顶层与TB返回pair索引改变，原G/Q/矩阵算术与全部fixture保持。核原完整终态标记及无Fatal/ERROR，接受 **PASS_SCOPED_FULL_LNQ_WI_G_Q_DOWN_COLD_WARM**。详情追加在同目录 `lnq_review_evidence_20261015.json` 的 `at164_at166_full_chain_review`。

接受范围是同一真实前LN row0经双槽冷W、LN1024/Wi Q32/20992 PS、G2624、共享Q82/Down10496 PS到1024 final的两条完整cold/warm命令；真实G发射x/gate逐项核对和511/512/655边界通过。每命令W读/返、issue、PS均31488；两命令累计Wi AR656/656/82、Down328/328/41、AUX2，warm无新增LOAD AR。冷/暖消费者done178317/291678是TB绝对cycle，不是两条命令各自延迟、II或实测速率。结果覆盖冷正序/暖倒序及每响应两拍等待；重复读、release/read竞争与内部主动反压未由本样本证明。

AT163 gate地址9bit回绕原因已由AT165完整真实输入/全部G返回和AT166冷暖复核闭合；AT164仅是连续保存Wi入口的2624项原core局部PASS，不能独立代签真实bank供数。AT165的Down slot1响应误按slot而非pair索引读取已由AT166修复、全部Down与最终输出闭合；cache源码明确ret_q[0]/ret_scale[0]是单tile响应，slot身份另核。原AT163/165 FAIL与原费用保留。runner现在要求终态PASS且无Fatal/ERROR，AT165已以child1记录语义失败。

AT166 RTL1261.580029s、峰owned RSS967920KiB、child0/trigger null；六次static/RTL guard政策均匹配。A001核AT156–166累计static987.806881s/1800s、RTL2531.910594s/3600s，截至AT166余1068.089405s；后续已运行尝试必须继续计入，host未采样部分仍UNKNOWN。本轮只做轻量身份/字节和源码核查，无新EDA或gold。

修订10保持running，当前数值里程碑接纳不关闭原合同中的Wi数值bad/poison映射、错误后完整warm、真实Wi/G在途共同reset及有限反压/读释放覆盖。工程继续原预算内已授权定向短测；依据实测速率先估长场景，AT166同等完整cold+warm重跑1261.58s已高于当前余额，不应原样启动。可完成的受影响局部覆盖按真实入口/注入范围报告，未完成的长场景明确列缺口，不伪造完成或重置预算。阶段末给准确成本与每命令相对周期（能由真实握手记录取得才报告）。没有新增OOC/预算/数值规则或审批门，无需确认回信；末残差、完整图及新联合物理仍开放。

---

# 修订10 AT163诊断：G gate地址在tile512处回绕

2026-10-15；A001→A002；回应 `m004-gqdown-at163-g-numeric-fail-diagnostic-20261015`。AT163保留 **FAIL_G_NUMERICAL_COMPARISON**，guard child0/null不抵消原Fatal；已有Wi前缀只按实际检查接纳，Down/冷暖新链尚未通过。修订10合同和预算不变，普通修复连续执行，无新放行门。

主控核冻结顶层 `laya_lnq_wi_gqdown_row_v1.sv` 第541行：`final_bank[lane][g_tile+9'd328]`，g_tile本身9bit；数组索引中的该加法只保留9bit。首错index1472对应t=1472/8=184，正确gate tile=184+328=512，恰为首次回绕到0的点；之前1472个值通过与此边界吻合。bank下半部此时已写入G返回，误读tile0还可能读到G0，而非原Wi值。

请优先用这个可证伪接线原因组织现有局部诊断：在G真实发射处逐项对照已保存独立Wi的x[i]、gate[2624+i]，特别检查i1471/1472/1479/1480与最后2623及gate地址511/512/655；正常期应明确得到10bit的328..655。把加法两操作数在运算前显式扩为10bit（例如`{1'b0,g_tile}+10'd328`），不要在9bit相加之后才强制类型转换。相关地址/计数同步做有范围宽度检查，不改G算术/gold/模型尺寸。正常数值相同输入、相同core、相同发射空拍及2624个G返回的局部对照可先区分原因，之后直接继续合同内受影响整链验证，不需再次源码审批；只保留模拟bank/保存Wi入口的诊断范围，不称完整链通过。

现有TB只比较G返回，建议同时增加输入operand及顺序配对断言，避免经过昂贵前缀后才发现地址错。若该宽度修复后operand正确但返回仍错，再依真实输入/空拍序列做core分支诊断；不预先改canonical core。现线索是明确的静态宽度缺陷，尚待动态修复证据。

普通runner还应把Fatal/ERROR、缺少最终完整PASS与shell退出码分别记录；child0不能转成语义PASS。原AT163 guard不回写，后续报告引用原日志。本段不追加预算/OOC，不重跑已知相同失败的长例。工程继续原阶段，状态与摘要在实质阶段变化时同步，无需确认回信。

---

# 修订9限定接纳，修订10继续真实LN→Q→Wi→G→Q→Down

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-WI-GQDOWN-CONNECTION-01`。本节为当前集中决定，下文保留本次审核过程。执行真源是[SM004修订10](../../project/missions/SM004.md)末节；本阶段普通实现、编译、仿真与修复连续执行，无逐次放行。

A001核341项文件/收据身份均匹配，6项fixture解码与原独立二进制逐字相同。接受AT148 **PASS_SCOPED_LNQ_WI_FULL_COLD_WARM**：两次完整20992 PS/167936 lane-group、5248 final，真实LN/Q及冷W；warm无新W/AUX AR。AT150只接受W标签错排空及恢复前256 PS，AT151接受冷RRESP排空，AT152/155为front局部，AT153/154为同输入LN统计。AT148只验证结果rsp两拍保持、冷正序/暖倒序，内部主动反压、重复读/释放竞争、错误后完整暖行与顶层在途reset未证明。[既有核查](lnq_review_evidence_20261015.json)追加 `at148_at155_wi_stage_review`。

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


## 2026-10-15：修订12Embedding LN/Q/QKV静态依据与实施合同

D-M004-EMBEDDING-QKV-ROW-01采纳A003唯一共享接法。A001独立只读核78条文件/窗口身份、10对当前/AT173源及17项字节/整数布局条件；其中前4行g31 PS=final、head-parity scatter均核。第一次主控checker误将scatter第四字段所有行都期望0；查原generator后更正为row-local r并重核通过，未改数据/参考，失败及修正记录在机读证据。3份大W BO父身份不重hash，只核本次窗口；无浮点重算/新gold/EDA。

[修订12决定](embedding_qkv_connection_decision.md)明确cmd_mode/row/result回显、LN真实消费norm观察口、QKV0..383与norm384..511tile复用、gamma1/真实行、slot0 key0001/真实lease以及跨FFN冷重载；4bit phase增加9/10/11，FFN0..8保持。主样本为真实row0 cold与row1 warm全N，再错FFN warm拒绝→无reset cold FFN完整末残差回归。host300s/static1800s/RTL3600s独立计量，single RTL1800s/1Mcycle、pilot120s计入。全项目原资源保护保持，无OOC/P&R。

工程消息m004-embedding-qkv-row-revision12-dispatch-20261015已delivered，recipient turn 01a13d07-c808-7030-bedc-21a1632b7610；并非实现/验证完成。新模式与QKV行连接NOT_RUN，旧FFN仅按原冻结身份保留。修订11旧失败/成本及bad/poison等未测覆盖不转移、不追认，完整模型与联合物理仍开放。


## 2026-10-15：修订12 AT179–195集中审核与成本出口

D-M004-REV12-CLOSEOUT-01。核602条冻结/夹具/引用身份、85份原产物、142条政策采样和28项原参考字节关联。AT192→194共同75份冻结输入仅switch TB改变，生产顶层/LNQ与AT182/186相同；23份FFN fixture另匹配AT173。当前顶层SHA54fe628fac0d1a9dd4c61455c45e55eb3abe499034d7bb23157b9ac8d4b8bf78、LNQ SHAcd35f5a620c8720917ffbc2481e3581b819e13d699c4214a0505321cace0371e。

AT193在后续Fatal前两行完整QKV/norm六字段、结果/消费者与有限停顿均完成，限定接纳PASS_SCOPED_EMBEDDING_QKV_ROW0_COLD_ROW1_WARM；相同模型/slot0 epoch1而key/shape不同的FFN warm在LN之后matrix之前状态7/phase3、无发布/零AR亦接纳。每行98304 lane-group，总196608；最终6144 QKV和2048norm。命令起止TB记号差78677/50909cycle仅为该样本，非II/Fmax/整模性能。非法tile512仅检查rd_ready=0，主动错误请求完成仍未签。

AT193随后slot0 Wi epoch2成功，首次slot1错误epoch3遭原逐槽+1规则拒绝：整体FAIL_TB_SLOT1_EPOCH保留。AT195另起runtime只运行QKV row0生产前置，逐位抽查tile0/511，成功release/done后无reset以正确epoch冷载Wi/Down；生产RTL在LOAD_WAIT核load_error/reject/READY/epoch/readers，后续Wi/G实际推进提供同runtime依据。完整Wi20992 PS/G2624返回通过，最后已记录Down issue9542、commit9530，停止点仍有真实债。guard trigger=timeout/child−9，1100.280453s；Down尾/ADD/发布/消费者未到，完整跨模式FFN不接纳，两个runtime不能拼成一次通过。

原guard复算static800.9032639935613s、RTL3568.45318207331s、host已测1.2153561394661665s下界；host全量UNKNOWN。各实际命令分类/政策/RSS/MemAvailable匹配，余RTL31.546817926689982s封存，修订12成本出口收束。AT187 pilot timeout、AT188覆盖FAIL、AT191非法读后TB误期待release、AT193 FAIL及AT195 COST_STOP不追改。工程报告中AT195 child−9/null需改为trigger timeout，冻结包“零差异”限生产RTL/夹具，A002状态/发布元数据需同步；均为记录修正，不要求重跑。

下一选择是[QKV＋norm真实设备scratch写回静态准备](qkv_scratch_next_design_question.md)。不仅加帽重演AT195；完整FFN重入缺口保留并纳入有新连接后的受影响验证与成本安排。当前不发新RTL/OOC预算。机读证据字段revision12_at179_at195_stage_review记录逐项依据；完整图及联合物理继续开放。


## 修订13静态依据审核与scratch实施合同（2026-10-15）

D-M004-QKV-SCRATCH-ROW-01：A001独立核研究52条文件/窗口SHA、20项保存byte/整数布局条件，7份当前计算RTL与AT192/194相同；writer109身份及原9例PASS/child0/null证据保留。row0/1各3072个scatter词及norm父文件一致；全128行32768个域内64B beat互不重叠且页内，QKV各最大exclusive offset10256384B、norm524288B。采样0.045292405s/23528KiB，CPU0–3/nice19、1GiB/20s保护；交互读取UNKNOWN。无EDA、模型计算、新gold。详见机读证据revision13_qkv_scratch_static_review。

按[正式实施合同](qkv_scratch_connection_decision.md)采用单top/单writer，明确三目的BO域、STATE1 norm、债零rearm、phase12、tensor begin/release/epoch/完整128位覆盖。新的命令及接口尚NOT_RUN。预算host300s/static1800s/RTL4800s，单RTL2400s/1Mcycle及pilot120s计入；新额度只覆盖新scratch和受影响重入，不迁移修订12余量。

有限主场景为同runtime真实row0 cold写回成功、row1 warm末norm B错误排空、无reset完整FFN至末残差消费者done；local adapter peer只签其端点/元数据，不代签全128行真实计算。AT193原FAIL与两行限定证据、AT195 Down前缀timeout、旧预算全部保持，跨mode缺口待实际完成。没有OOC/P&R或整图验收。

正式合同通过消息m004-qkv-scratch-revision13-implementation-dispatch-20261015实际送达A002，recipient turn 01a13d82-52a1-7a02-84e0-9ba7e0a2bce3；研究采纳边界亦已独立送达。送达不等于工程完成。


## 修订13 AT196–208集中审核：真实写回与FFN重入接纳，局部错误边界修复（2026-10-15）

D-M004-REV13-AT204-REVIEW-01。主控独立核229项manifest SHA、105份原始manifest/guard/plan/policy/log、168条实际CPU/nice/I/O政策记录，AT204的30份QKV/23份FFN fixture与AT194同名字节一致。按实际命令和原guard十进制数复算static319.7074945475906148s、RTL1455.8813096918165374s，与工程账一致；host完整累计UNKNOWN。未运行EDA或新gold。

限定接纳AT204冻结wrapper e5dde5cc…、core54fe628f…、writeree1121c5…的PASS_SCOPED_QKV_SCRATCH_B_ERROR_THEN_FFN_FULL：真实row0 cold/row1 warm各norm1024、32组Q/scale、12288个8lane六字段PS及3072final；总1024个同步行响应（每行512）、512个64B AW/W/B事务。row0成功49flush，row1末norm SLVERR后48成功flush、协议7/phase12/真排空，保留row0位而不置row1位/RAW。随后同runtime无reset真实Wi slot0 epoch2/Down slot1 epoch1成功冷载，完整Wi20992 PS/G2624/Down10496 PS/ADD1024与残差消费者/release/done通过，FFN段scratch事务无增量。整次SCRATCH_FULL_CHAIN_PASS/child0/null、1404.0506762936711s。所测跨mode完整FFN缺口在这个冻结样本闭合，不拼接旧AT195或外推任意故障。

AT197原writer九例/rearm有限证据、AT203/205/208合法同步行peer下的生产wrapper/writer事务与128位RAW发布/拒绝、AT207四个共同reset后510拍所监测隔离/下一局部行按各自范围接纳。局部128行不是128行真实QKV。旧AT199–202/206失败保留：AT202原Fatal明确为local peer timeout phase6，TB release采样为原因解释，不替换原终标。

覆盖收窄：AT204三口各AW/W有限阻塞确有末端断言；两种接受顺序仅全局flag，未证明每个目的两种顺序。AT204没有scratch阻塞字段逐拍稳定监测，原AT197叶子证据不代签外层三口；主场景检查全部接受写事务的精确地址/数据/strb，没有外存回读/物理BO哨兵模型。正常末B前禁release未独立动态断言，错误末B hold有显式断言。上述已交同生产wrapper局部回归补测，不重跑1404秒长例。

源码发现wrapper F_ROW只由release转F_DONE，而原core非法读可直接报错done，外层可能卡住；另core_result_mode/row仅声明/连线，无消费前硬件回显比较。已通过m004-rev13-at204-wrapper-terminal-review-fix-20261015及覆盖补充实际送达A002，recipient turn01a13dbd-d27c-7791-b7d8-5e62243e900b；按修订13剩余static1480.2925054524093852s/RTL3344.1186903081834626s连续普通局部修复，无新预算或逐步审批。工作wrapper已变化，旧AT204不自动迁移给新身份；最终差异与受影响回归待集中复核。

A003已实际收到m004-qkv-rope-minimal-next-design-20261015（turn01a13dc0-d6d5-7ab3-813b-7e5e9cd4d1fd），仅核RAW scratch到Encoder0 full RoPE的最小真实接点、同输入原参考及隐藏逐行调度是否可行；不得填128位/缩S/保存值代producer。轻量脚本60s/单次20s/1GiB、CPU0–3/nice19/idle，无EDA/gold/代理。没有修订14实施预算，修订13未封账；全128行生产/完整图/联合物理继续开放。


## 修订13 AT209–211局部修复审核（2026-10-15）

主控独立核新增97条manifest身份、27份原始manifest/guard/plan/policy/log、49条政策采样；原core54fe628f…和writeree1121c5…与AT204及AT211/current同SHA，wrapper已变为9c55ae10…。两段总账static474.5678006708621898s、RTL1473.8209624327718898s与原guard完全一致，hostUNKNOWN；无新增EDA或gold。机读证据字段revision13_at209_at211_fix_review保存逐项原路径/命令/身份。

AT209使用与AT210相同SHA的同步peer，以非法FFN tile128复现旧wrapper直接done未接住，20拍后Fatal FFN_DIRECT_ERROR_HANG/child1；原FAIL保留。AT210终态短例核7/7保持与一次core done、无伪release、下一合法局部FFN行；FFN错mode和QKV错row在消费前拒绝，分别7/7且tensor不受影响、7/12且sticky failed。局部包另核三口逐口AW先/W先6240/6240/4160次各一套，受阻全部字段/VALID稳定，route/base/span到B共175128次检查、正常末B和错误末B发布屏障。上述只签生产wrapper/writer＋同步peer，128行32768笔B响应元数据不是128行真实QKV。AT211仅真实core/IP静态展开通过，无新wrapper完整真实长链数值实测。

现有两个原审核缺漏在所测局部范围闭合；AT204旧wrapper真实长链证据按冻结身份保留。进一步发现新增FLUSH_SEG身份错误优先于一次性flush_done：若同拍命中，进入ERR_FLUSH后writer_fault=0/debt_zero=1，但flush_reported=1且flush_req持续，无法再等到flush_done。这一具体控制交互仍是静态发现、动态复现待交付。已直接送达m004-rev13-at210-flush-error-drain-fix-20261015，recipient turn01a13dcb-f91e-72f2-ab28-0d63e44c4ad0；按原合同以真实读/写债零作错误退出、保留必要flush发pack，不等第二个成功脉冲。仅复现该边界并做受影响局部回归及必要编译，不扩任意故障、不重演1404s长例、不加预算。

修订13尚未封账；余static1325.4321993291378102s、RTL3326.1790375672281102s。下一RoPE静态问题已在研究侧，尚无修订14实现授权。旧失败、各身份的有限通过与全128行/整图/物理缺口保持。


## 修订13 AT212–214最终审核与修订14决定（2026-10-15）

主控独立核98条冻结SHA、31份原manifest/guard/plan/policy/log、56条政策。7笔guard按实际命令分类为3 static/4 RTL；累计static615.5153379254043043s、RTL1498.1496843509375738s与原guard一致，hostUNKNOWN。AT211/214共同80项仅wrapper改变；AT212/213同步peer/TB/writer同SHA，旧9c55ae10…首段真实8rsp/4AW-W-B时身份错与flush_done同拍复现挂死，新daae5611…保持flush与真实rsp消费、等真实债零完成7/12，一次release/done，discard后epoch2局部行完整局部行（256笔B、512读、49flush）通过。AT213终态/回显/逐口保持/128位元数据局部回归及AT214真实core/IP展开接纳。该新版未跑AT204真实长链；旧e5dde5cc…的完整数值/错误后FFN事实按原身份保留。修订13收束、未用余额封存，详见[收束决定](qkv_scratch_rev13_closeout_decision.md)，机读字段revision13_at212_at214_drain_closeout_review。

研究RoPE静态82条身份独立核81条匹配，唯一当前差异为后续wrapper普通修复；另核15项字节/整数关系，含39个row1同输入pair及全128行16384个Q/K beat合法/唯一/不交V。采用单leaf/reader/writer隐藏逐行方案，同时明确双epoch、norm独立版本、phase13及row-local Check不等同旧全请求首先遇错顺序。

参考缺口按D-M004-ROPE-REFERENCE-01补齐：原fe9678e4…独立oracle不改，仅算既定两行RoPE，先校准四旧叶子256项/旧两行6144项；研究363检查，host0.41s。主控核61条父文件/冻结窗口/产品/脚本身份以及4096个步骤lower/upper与FINAL字节绑定、V/norm不变、row0恒等/row1非退化及旧78项；未重复浮点求值。冻结manifest979b1030…，row1 FINAL f4fa2f82…；接受为指定两行完整独立checker，不是硬件通过，机读字段rope_rows01_independent_reference_review。

[修订14正式合同](qkv_rope_connection_decision.md)规定真实两行RAW→scratch读→full RoPE→写回/真B，完整FINAL数值与内存哨兵/合法反压检查；RAW-only和FFN只做受影响局部回归，不重演同版长FFN。新host300/static1800/RTL4800s独立帽、旧余额封存；新连接NOT_RUN，无OOC/P&R/整模前向/新agent。完整128真实生产、Attention、全请求首错、生产Host/HBM及联合物理仍开放。


### 修订14 MUL观测口径澄清（2026-10-15）

D-M004-ROPE-MUL-OBS-01已直接答复工程并写入合同。原IP无输入ready、a/b valid常1、ce常1、一级输入寄存与c_latency1；仅Pipeline活动窗口不足以证明当前head操作。主控核三份原源码SHA，明确stage1/5/12/16操作选择、stage3/7/14/18 HLS结果采样，允许只读影子token绑定真实来源/物理接受，但必须分别标定IP输出与控制消费。若严格“IP已接受未输出”的安全reset窗口不能证明，该项保持NOT_RUN/UNKNOWN；可另签“已接受但HLS未采样”的有限控制隔离，不能代签严格覆盖。不改IP/数值/预算、不制造同沿竞态；正常连接继续。详见[观测决定](qkv_rope_mul_observation_decision.md)，无新EDA/PASS声明。

## 修订14 AT225两行正常链审核与控制修正（2026-10-15）

D-M004-REV14-AT225-REVIEW-01：主控核143项冻结身份、9份原manifest/guard/plan/policy/log、24条政策；30份QKV和23份FFN原fixture同AT204，新FINAL文本解码逐字匹配冻结独立派生参考，表字节同原AUX s0/s1。原full-Check叶子及依赖身份保持。机读字段revision14_at225_normal_rows_review保存来源、逐项SHA、checker范围及实际命令账；没有新EDA或浮点参考求值。

接纳AT225 wrapper b131526237fa63c52603b8a4c3ce4fbc4b0e52f70ed0418d8e3f5214a4de9c38、adapter a80564dee57a8e07bcb4af2ddd758efe6012f7af92c188e5135bd00a493582e0的PASS_SCOPED_QKV_SCRATCH_ROPE_ROWS01_NORMAL。同runtime真实row0 cold→row1 warm，原LN/norm1024、Q/scale32组、12288×8lane PS六字段和3072pre-QKV每行完整核对。实际RAW成功B写入模型，再从实际数据读64head/256个512bit R；两行表4AR/64个128bit R，512笔RAW＋256笔RoPE＝768笔B。4096个Q/K FINAL全量逐位过，V/norm各行不变；仅两位覆盖/无RAW或FINAL tensor发布，末head B hold及partial discard至last_released_epoch2有效。guard child0/null、791.7965642139316s、峰981884KiB；唯一ROPE_QKV_ROWS_REAL_PASS、无Fatal/Error。done全局cycle111837/195897不当作请求latency。

完整Check字段只在每行末head显式断言，其他head通过code和输出覆盖控制；主场景紧凑两行逻辑内存不等同完整BO/邻区哨兵，row1后未重扫row0。AW先/W先仅全局，新增scratch AR/AW/W受阻全字段未监测；head256B对齐未测4KiB split；打印next_epoch3不等于真实begin3。上述边界不以PASS标记扩大。

静态发现两项需修正：wrapper按Q所有head再K所有head遍历，违反合同逐head Q,K次序，K/head0与Q/head1双错可区分首先遇错；R_TABLE_LOAD优先看reader旧sticky error，可能在同拍新load真实接受时进入R_ERR并漏记table_load_active。已以[合并决定](qkv_rope_at225_scoped_review_decision.md)发A002，消息m004-rev14-at225-scoped-acceptance-control-fixes-20261015确认delivered、recipient turn01a13dde-28e2-7b11-a66f-c08352db1fa1。要求最小一致解码与逐事务错误/真实接受记账，局部双错顺序、部分R错误排空→discard→新epoch无reset合法行及受影响回归。此时为静态发现，未声称修复通过。

截至AT225完成guard累计static543.2655436191707835s/1800s、RTL1043.750234801322253s/4800s，共15笔（10 static/5 RTL），host完整UNKNOWN；后续正在运行的短例另计。AT220/221 timeout、AT222语义失败及其他原终态保留。工程继续原合同局部错误/reset/元数据与必要持稳/哨兵/页界覆盖，不为迁移PASS重跑791s长例、不增预算。旧SHA完整正常链仅属旧身份，新身份受影响证据单列；全128真实生产、全请求首错、Attention/整图/Host-HBM/联合物理仍开放。


## 修订14 AT215–241阶段审核：两项修复闭合，Check短例待补（2026-10-15）

D-M004-REV14-AT241-REVIEW-01。主控核958项冻结SHA、237份原manifest/guard/plan/policy/log、456条实际政策，53笔guard（26 static/27 RTL）完整对应实际目录；总账static978.93351217359304232s、RTL1241.301459711045058s与工程精确一致。AT227child127路径启动失败没有policy_checks，保持未采样；其费用与所有原timeout/Fatal均计入，host完整UNKNOWN。核查脚本首次因该缺失停止0.34450199s，修正只读审计后全部匹配，未跑EDA/浮点oracle。

AT225→AT232共同源只有wrapper和真实链TB变更，当前core54fe628f…/writer ee1121c5…/adapter a80564de…保持原身份。当前wrapper0d3e340e…解码/地址/路由/Check改为逐head Q,K；地址先验、真实load记债、当前done判错。AT230/231同TB直接对照旧sticky error导致新合法命令失败，新版AUX第三R报错后收满16R/一次done→discard→epoch3完成局部正常行。AT230双坏K/head0和Q/head1先报K/head0，6/13/bad1024；两项控制修复限定接纳。AT230/241传输错误排空和epoch7局部恢复、RAW-only/FFN受影响回归及AT232真实core/IP展开按各自边界接纳。旧AT225b1315262…真实两行正常链不迁移新身份。

AT236的原s127/h15 Q/K保存输入/expected及无损格式、AT237两半非对称表手算位型、guard集完整性共13项byte/整数补核通过。叶子正常值与成功Check仅局部接纳；AT241原叶子页界64scratchAR/128R和3tableAR/32R、两QKV口各32次AW先/W先、受阻全字段/route/base保持及末B屏障成立。无实际物理BO/邻区哨兵模型。

AT233原时序说明实际MUL接受沿后输出已可见而HLS次拍采样，只签已接受/HLS未采样共同reset后510拍控制隔离及后继局部行；严格IP未返回NOT_RUN。AT234前三触发为RAW写AW-only/W-only/AW-W待B，第四为RoPE scratch收2R；四次分别510拍隔离，只有四次序列末尾完整恢复一行，不升级每次独立整行恢复或RoPE写阶段reset。AT240模拟core/快速leaf只签128位/49152笔B元数据，成功release2→begin3及partial discard消耗4成立，next_begin5仅打印允许值，未实际运行。

原合同还明确要求末pair/多非finite及预检/计算首错，现有NaN首元素例不足。已送达[阶段审核回复](qkv_rope_stage_handoff_review.md)，消息m004-rev14-at241-scoped-review-check-tail-completion-20261015，turn01a13e3e-86d4-7063-b8e3-280bf0ef1edf：原预算补四个原leaf/adapter小例，核code6/detail0740000f/完整64bit bad和后继正常head；不改gold/IP，不重演791s长例或真实core展开，无逐步审批。修订14暂不封账，后续实耗追加，不转移旧余额。

A003已收到[下一S128真实生产与FINAL→Attention静态问题](qkv_final_attention_next_design_question.md)，消息m004-s128-final-attention-minimal-next-design-20261015，turn01a13e3f-768c-7d30-96b9-e39cd118e86e。仅静态定位源reader、单行调度、128覆盖、Attention加载/mask/skip和同输入参考/成本缺口，host脚本60s/单次20s/1GiB，无EDA/前向/新gold/新代理或修订15实施。全128真实producer、完整请求首错、物理BO/哨兵、Attention/模型/生产Host-HBM/联合物理仍未验。


## 修订14 AT242异常Check补测验收与分版收束（2026-10-15）

D-M004-REV14-CLOSEOUT-01：主控新增核17条冻结SHA、10份原manifest/guard/plan/policy/log/总账、19条实际政策；AT242四份work hex/冻结hex/AT236原参考逐字一致，adapter与原leaf/FP依赖未改。冻结TB按原预检及算术顺序构造四个明确位型，原日志bad7、31、63、63；逐例code6/detail0740000f/完整64bit bad及无协议错、result_valid/Check/覆盖三拍保持与实际消费通过。末pair例只有前62项y，预检错无y；四坏例后无reset重prepare，原s127/head15 Q成功Check和64项输出逐位匹配。唯一ROPE_CHECK_EDGES_PASS在全部自检后，无Fatal/Error，两个guard child0/null。

接纳PASS_SCOPED_ROPE_CHECK_EDGE_ORDER_AND_LOCAL_REUSE，仅属原adapter/leaf局部异常次序及正常复用，原合同本次指定缺项闭合。当前wrapper/core/adapter/writer仍等于AT232。旧AT225b1315262…真实两行正常链不迁移当前0d3e340e…，后者依然只有局部控制/恢复/页界/元数据及AT232真实展开；严格IP未返、当前真实长链、全128真实生产、物理BO/邻区哨兵、完整请求首错、Attention/整图/Host-HBM/联合物理保留NOT_RUN边界。

新增static22.975409511476755s、RTL5.7779527977108955s；原53笔机读记录逐项未变，总55笔（27static/28RTL），static1001.90892168506979732/1800s、RTL1247.0794125087559535/4800s，hostUNKNOWN。余额798.09107831493020268s/3552.9205874912440465s封存；原FAIL/COST_STOP/未采样政策不回写。修订14按[收束决定](qkv_rope_rev14_closeout_decision.md)有界结束，M004保持running/unassessed。工程收束消息m004-rev14-at242-scoped-closeout-20261015已送达；下一S128→Attention问题此前已交A003，仅静态准备，无修订15实现/新EDA/新oracle授权。机读字段revision14_at242_check_completion_review为本次证据。


## 修订15静态复核与实施合同（2026-10-15）

D-M004-SOURCE-S128-01：[真实入口合同](source_s128_connection_decision.md)已定。A003的81项身份全部当前相同；A001独立复算30项保存字节/整数条件、6个head0窗口（384F32）全部相同。STATE0有效524288B等于独立raw、前四行norm与矩阵父输入一致、gamma和mask窗口绑定成立；t5 Q/K/V的来源仍为软件捕获，不提升为QKV独立gold。外层time0.22s/49080KiB/exit0，CPU0–3/nice19/idle，20s/1GiB帽；内部落盘前采样另列，交互UNKNOWN。

采纳现bank8KiB预装、单reader分时路由、真实LN回放与固定128行调度。检查现core在IDLE命令/冷W载入不清final_bank、LN norm写384..511、矩阵后写0..383，生命周期支持预装，但新接口尚未实现/验证。新增INPUT phase14，锁存所有延迟命令字段并用真实读/写债屏障；准备token按id/row/epoch一次消费，原数值不变。

新host300/static1800/RTL4800s，固定≤120s真实入口pilot计入，主场景只验固定128调度的真实两行完整前缀；合法128行peer仅签调度/地址。Attention不在本次实现；旧全图先QKV后RoPE及head/window优先次序未改合同，逐行阶段错误不等于整模首错等价。新实验NOT_RUN，修订14封账及余额不迁移。机读字段revision15_source_s128_static_review保存全部身份和条件。

修订15实际投递：m004-source-s128-revision15-implementation-dispatch-20261015 → A002，turn 01a13e5f-1a2f-75e2-baae-fdeaa084d917；范围答复m004-s128-source-static-adoption-rev15-20261015 → A003，turn 01a13e5f-dd0f-7b33-8cb8-3b7dadd1b1e9，均delivered。工程运行/验收另按实际证据记录。


## 修订15 AT250阶段内正常前缀审核（2026-10-15）

D-M004-REV15-AT250-01已送达A002，详见[当前审核](source_s128_at250_milestone_review.md)。主控核547条冻结身份、60原产物、135实际政策样本、57份同AT225夹具及14父窗口，5项hex解码关系相同。AT250子进程0/null，固定请求真实两行全数值前缀、768笔B及仅两位覆盖成立，按冻结三模块身份接纳；原失败、AT246/249局部范围及整模缺口保留。新身份不迁移旧完整前缀PASS。

两项静态问题为IN_ERR中过早abort导致可能等待第二个ready、source RAW-only续行漏核模型AUX描述符；原合同内局部修复，无新预算/长例重跑。当前报告静态推理不是已复现FAIL。原guard至AT250为static731.453528914600612s、RTL946.227504860609739s，阶段运行中，后续另计。主控轻量审核首次因manifest键重复加.hex路径错误退出1（0.46s），修正后退出0（0.50s/45524KiB）；原time保留，未执行EDA或新gold，交互读取UNKNOWN。


## 修订15 AT264阶段审核与末行错误补项（2026-10-15）

[D-M004-REV15-AT264-01](source_s128_at264_stage_review.md)接纳提前abort与RAW-only source gamma身份两项控制修复，以及当前wrapper d4856aee…的AT264真实单行/逻辑哨兵。旧AT250固定S128两行证据保持原d8e52ea3…身份；旧版共同reset、当前局部prepared peer/调度/legacy/页界/token证据按报告逐项限定，不拼接完整恢复或128生产。

主控新增核723项冻结、164份原产物、267条政策和342份实际fixture父文件比较，结合此前共1270项冻结/402条政策。42笔原guard逐项一致：static1769.133914342150093/1800s、RTL2768.097435323521494/4800s，余额30.866085657849907s/2031.902564676478506s，hostUNKNOWN。AT253无guard不记执行；原编译失败、timeout及守卫误停保留。AT264复用AT261非TB依赖和4份编译数据库身份已核。

阶段暂不封账：原合同第127行错误未被正常128行peer覆盖，已直接要求A002仅用生产sequencer/合法row peer补127成功＋最后7/14/bad全1错误、请求错误保持与一次消费、128接受/127成功/1失败、无回绕和FINAL。static及RTL各累计≤20s扣原余额，不能改生产RTL/gold或重跑长例。消息m004-rev15-at264-scoped-review-last-row-error-completion-20261015实际delivered，turn 01a13edf-8060-7fc3-8bbd-402bcdc5553f。当前pending_last_row_error_probe，完整模型running/unassessed。

主控只读helper首次因假定AT263存在fixture副本退出1（0.85s/40072KiB），第二次路径日期笔误退出2（0.03s/9472KiB），修正后退出0（1.12s/46676KiB）；三份time原件保留，累计2.00s，非工程EDA预算。成功内部落盘前0.905455s/34508KiB仅为部分采样，不冒充完整进程成本；交互读取UNKNOWN。机读字段revision15_at264_stage_closeout_review保存完整审核，字段名不表示封账。


## 修订15 AT265末行错误接纳与有界收束（2026-10-15）

[D-M004-REV15-CLOSEOUT-01](source_s128_rev15_closeout_decision.md)接纳AT265生产sequencer/合法完成peer的最后一行错误出口。主控独立核5冻结SHA、12原产物、11政策，生产sequencer同AT252/当前身份，所有当前主要RTL保持AT264。原log唯一PASS、child0/null；128行命令/127成功/1错误、id208/row127/7/14/bad全1及3拍稳定到消费、retired_rows127/首127位保留/末位0、无回绕或FINAL。仅签调度元数据，不签真实row127读错/128生产。

新增static4.572500266134739s/RTL5.470804534852505s均在20s帽内；旧42条逐项未变，总44笔（21static/23RTL）。累计1275冻结/413政策零差异，static1773.706414608284832s、RTL2773.568239858373999s，host完整UNKNOWN。余额26.293585391715168s/2026.431760141626001s封存不迁移，原FAIL/timeout/guard误停保留。旧AT250两行、当前AT264单行及各局部/旧reset边界不扩大，完整模型与异常次序缺口保留。

主控只读核验外层time0.19s/45416KiB/exit0，内部落盘前采样另列，无EDA/模型求值/新gold。此前三次helper2.00s及其失败原time保留；交互读取UNKNOWN。机读字段revision15_at265_last_row_error_closeout_review保存所有证据，AT264历史pending由本决定闭合。修订15bounded_closed，M004/SM004整体running/unassessed；不启动修订16实现。
