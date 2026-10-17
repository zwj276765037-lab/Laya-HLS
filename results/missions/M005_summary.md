# M005：代表通路与整模性能可行性评估——最终判断

execution_state: completed
verdict: inconclusive
investment_decision: stop_current_serial_implementation_branch
controller_decision: D-M005-FINAL-ASSESSMENT-01
updated: 2026-10-14

**本轮有界可行性评估已完成。当前串行实现不支持扩大工程投入；停止本轮实现与物理诊断分支。硬件可行性仍证据不足，完整加速器未验收。** 这项判断综合了真实功能失败、综合成本停止和全图条件模型；没有把评估完成写成硬件通过，也没有判定所有FPGA方案不可行。

| 用户问题 | 最终回答 | 证据及限制 |
| --- | --- | --- |
| 一条有代表性的完整通路能否稳定算对？ | **尚未证明。** LN→Q→Wi→G→Q→Down前缀及对应独立gold已到达，末残差未启动。 | AT073在cycle375074的Down→残差票据合取断言Fatal；3/3次full已用尽，无完整正常或独立合法反压样本通过。 |
| 综合资源是多少，关键路径能达到什么频率？ | **当前无法给出。** 没有有效联合网表、资源或时序报告，route未准入。 | AT087联合综合277.203887s达到任务24GiB owned RSS帽，峰25,205,756KiB。这不是器件fit失败；LUT/FF/DSP/BRAM/URAM/Fmax均UNKNOWN。 |
| 整模推理性能是否可观，值得继续投入吗？ | **当前条件预测吸引力不足，不支持扩大此串行路线投入。** | 假设150MHz、有效10GB/s及未测算子8cycle/单位，整模6.919–8.133s/请求；没有实测整模延迟、持续吞吐或同口径CPU/GPU加速比。 |

执行依据：[M005完整合同](../../mission/M005_代表通路与整模性能可行性评估/contract.md)及其A1/R2/R3修订。主控已核最终工程原guard/日志、预算与A003[最终独立判断](../../source/feasibility_20261014/final_assessment.md)；[机读最终决定](../feasibility_mission_20261014/final_decision.json)。以下结论是A001技术与排程决定，不是新的人类批准。

## 性能为什么不足以支持扩大投入

真实production-v2 B1/S128请求有72个有效token但物理计算128行，scorer16槽中2个有效候选但计算16槽；122次Q8共47,160,754,688 INT8 MAC。Attention QK/AV各503,316,480 FP MAC、LN 8,011,776元素、残差7,864,320次加法也计入预算，未用FFN乘层数替代全图。

下表来自冻结[v4预算](../../source/feasibility_20261014/v4/budget.json)与[研究报告](../../source/feasibility_20261014/report.md)。两列仅改变权重在128行/4行之间的复用；频率、10GB/s有效带宽及未测算子速率都是假设，**不是实测或有保证上下界**。原单request slot下模型完成间隔II＝延迟L，没有已实现的多请求流水吞吐。

| 假设频率 | 跨128行保留W：L/II | 仅跨4行保留W：L/II | 条件吞吐 |
| --- | ---: | ---: | ---: |
| 100MHz | 10.359s | 11.573s | 0.086–0.097请求/s |
| 150MHz | 6.919s | 8.133s | 0.123–0.145请求/s |
| 200MHz | 5.199s | 6.413s | 0.156–0.192请求/s |

150MHz、跨128行W复用场景中，LN约2.200s、Attention约1.863s、残差约1.322s，合计约78%；matrix约0.638s。仅把matrix加速10倍，整模条件收益约1.09倍；仅把残差加速4倍也约1.17倍。单纯扩大矩阵阵列不足以改变整体判断。同一量化器、矩阵和存储端口服务多层，其累计占用不能通过取“最慢一级”全部隐藏。

Q8权重本体392,448,128B；计入bias的W加载随复用范围约392.53MB至12.53GB/请求，另有约651.61MB建模外部流量。片上缓存容量不能容纳整模权重，也未证明跨全部窗口驻留。实际布线频率、未测速率迁移、有效带宽、完整控制/host开销及同口径CPU/GPU对照仍缺失，不能宣称已获推理加速收益。旧50ms GPU口径不用于加速比。

## 功能与物理停止事实

AT073的Down有256 AW/W/B及TMP独立gold，TMP总检查窗口64KiB＝16KiB输出＋48KiB未写哨兵。Down cfg358881→首次done375066差16185cycle；至实际消费375073差16192cycle，两端采样计入16193。v4原用16192，无需改参数。票据合取失败未逐项观察，不能认定唯一根因；末残差双源读/加/写、新HIDDEN、4096最终gold和655360B完整终扫均未到。旧AT049/AT054局部PASS不能拼接为本次全链PASS。

AT087原guard为child−9、owned_rss_at_or_above_limit；系统最低MemAvailable仍408,212,128KiB，触发的是本任务24GiB帽。原综合日志无Vivado ERROR或完成标记；没有有效DCP、utilization/timing/route。AT086同候选因不适用的静默守卫停止，AT087仅修综合守卫，不改写AT086记录。hub/store monitor/half解码的局部差分与回归只接纳各自范围：140已知几何输入、portal受影响回归、3097cycle monitor回归、全部65536个half输入等价。物理候选身份已变化，未经完整链和独立反压验证。

| 本轮预算类别 | 最终占用 | 终态解释 |
| --- | ---: | --- |
| 新full | 3/3次，4974.979578/10800s | 次数用尽；无第四次 |
| 联合综合 | 685.210200/3600s | AT087成本停止触发R3终态；剩余秒数不构成重跑权限 |
| 短测 | 保守上界283.855331/600s | 上界，不冒充全部精确实测 |
| static | 保守上界1335.673109/5400s | 上界，不冒充全部精确实测 |
| route | 0/3600s | 未准入 |
| 历史host | UNKNOWN | 不按0记账或补签全策略覆盖 |

证据：[工程终态报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_R3_bounded_physical_stop_20261014.md)、[AT087原guard](../../project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT087_M005_joint_physical_synth_guard_07/guard_synth/guard_result.json)、[预算账](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_budget_ledger_after_AT087_20261014.json)、[AT073报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT073_down_retirement_fail_20261014.md)、[A003原证据独立核查](../../source/feasibility_20261014/updates/at087/report.md)。

## 当前排程与重新投入条件

M005/SM006按有界评估完成、硬件判断inconclusive收束；M003/M004完整生产与加速器义务仍未完成。**M003普通Q/L保持paused，当前M004串行实施线停排。** 不恢复FullRuntime/executor、生产控制生成或全局恢复，不追加同候选full/综合/route，不升内存帽，不自动改多周期hub、缩容量或删检查。

A002可收尾一次已有来源、Ref/Context、窗口P/整owner发布、Q接受与父L provenance接点及未验证项的静态整理，保留现有路径和身份；不改RTL/TB/gold、不生成新硬件、不跑reference/HLS/RTL/OOC，不把静态准备记成实现完成。已有D-M003-ORDINARY-SOURCE-PROVENANCE-01及generated channel合同仍是未来技术约束，其旧预算不恢复、不重置，也不转换成本轮续跑权限。



静态收尾已交付（2026-10-14）：A002已发布E003三摘要及[普通Q/L接点盘点](../../project/E003_production_chain_closure/experiment_status/ordinary_ql_static_interface_inventory_20261014.md)，报告无RTL/TB/gold修改或新工具。主控已读盘点：caller generated BEGIN/END当前仅LN、hub普通窗口仅role6/TOKEN/F32；单rows16 NORM物理证据与四窗口HIDDEN sideband仍不同身份。Q错误位与成功退休、P→Q→A→父L同身份、多源/旧epoch及恢复缺口保留，仅为静态观察，不新增PASS。允许的一次静态收尾至此结束。

未来只优先一条重新立项条件：提出保持原数值/容量、针对LN/残差等非矩阵主要成本的可证伪吞吐架构，在计入Attention、存储与共享资源的全图预算后，证明必要改善足以改变一个明确使用场景的延迟/II判断，并给同一硬件边界的功能及物理验证方案。这是后续准入建议，本轮不启动新架构。当前最合理的投入决定是停止扩大既有串行实现，而不是继续为接通生产控制投入大量工程。

## 历史阶段记录（保留原时点判断）

以下均为最终决定前的历史快照；其中“继续/待测/运行中/未完成M005”等排程已由上文D-M005-FINAL-ASSESSMENT-01取代，不能据此启动新工具。原失败、局部PASS和证据路径保持。

## 阶段C第一版：条件预算与当前投入决定

依据[研究报告](../../source/feasibility_20261014/report.md)、[正式机读预算](../../source/feasibility_20261014/v4/budget.json)及[主控审核](../reviews/SM006.md)。40份冻结输入与当前来源SHA一致，重放输出逐文件相同；5147个模型服务事件、962个最多16行Q窗口、3845个最多4行matrix view与独立工作量相符。[主控核验记录](../feasibility_mission_20261014/research_delivery_audit.json)。这只接纳分析可复算性和条件模型，不是硬件通过。

下表同取10GB/s有效带宽、未测算子每工作单位8cycle；频率未由当前top布线证明。原架构的单request slot场景采用完成间隔II＝延迟L，不声称已支持多请求流水。

| 假设频率 | 跨128行保留W：L/II | 只跨4行保留W：L/II | 条件吞吐 |
| --- | ---: | ---: | ---: |
| 100MHz | 10.359s | 11.573s | 0.086–0.097请求/s |
| 150MHz | 6.919s | 8.133s | 0.123–0.145请求/s |
| 200MHz | 5.199s | 6.413s | 0.156–0.192请求/s |

150MHz、跨128行W保留的条件贡献：LN 2.200s、Attention 1.863s、残差1.322s、matrix 0.638s，前三者约占总服务78%。只把matrix加速10倍，整模条件收益约1.09倍；现阶段继续扩Q8阵列不是有据的首选。W装载随复用范围从约392.53MB增至12.53GB/请求，另有约651.61MB建模外部流量；带宽低且反复重载时存储会重新主导。

“流水”不能消除同一资源服务全部层的累计工作。假设另造多请求上下文，原LN服务需求仍给出150MHz下II≥约2.20s的必要条件；它不是已经实现或保证可达的II。外部shell、完整控制、主机初始化和同口径CPU/GPU对照仍UNKNOWN，暂不能算加速比。

主控阶段决定：保留M005 A/B原范围和预算，先回答同top能否稳定算对、实际fit与布线频率；不因研究估计额外授权新算术/HLS/复制阵列。后续候选优先核LN/残差的串行等待，但必须等物理证据再选一个有界改进，原数值/容量不变。若实际结果不能支持合理使用场景，则停止当前路线的大规模投入；目前尚不足以断言所有FPGA方案不可行。M005/M003/M004均未完成。

## 2026-10-14工程接管与容量核对

A002已接管M005；接管时AT063原full仍运行，随后终态见下节。A003已交付独立模型并核工程容量；新E006综合/布局布线仍NOT_RUN。

| 项目 | 已核范围 | 对可行性预算的影响 |
| --- | --- | --- |
| A缓存 | 两slot声明payload共139264B，单量化器 | 两slot不能计成两个并行量化器 |
| W缓存 | 两slot声明payload共11461632B，其中q为10747904B | 原392448128B声明权重无法全部驻留此缓存；slot不是独立矩阵引擎 |
| PS | 四row数据83968B＋metadata5248B | 支持四row tile，不能当作S128全部中间和同时驻留 |
| 权重复用 | 同一四row tile内已测；跨多个tile继续驻留/lease未动态闭合 | 完整请求流量须区分有复用与需重装场景，不能直接认定32次复用或32次重装 |
| scorer | 原完整参考对16槽计算scorer，再应用有效候选mask；样本2个有效候选 | scorer矩阵M保持16，不能按2计量；原47.16G MAC初核不因此缩减 |

以上为RTL声明容量和源码行为，**不是Vivado资源用量或整模实测性能**。来源：[工程容量答复](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/m005_capacity_reply_to_research_20261014.md)、[主控核对记录](../feasibility_mission_20261014/capacity_review.md)。具体BRAM/URAM映射、频率、跨请求重叠和部署余量仍待同top物理证据。

## AT063终态：Down W发布后有界停止

原FFN4唯一full于2026-10-14 10:02:59 CST停止：`COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD`，2080.298887s、child−9、末认可进展后120.092913s、峰1036164KiB；129条认可进展、0拒绝。主控核对了原guard/result/log；输入/包终态全量身份核验仍由工程交付，本次不补签。

本次实际推进到LN、Wi、Wi reader、GATE、第二次Q和Down W发布。末W发布cycle358880不是全链结束周期；Down cfg、Down TMP实写、末残差和最终655360B保护终扫均未到。没有整链PASS，也不能据此断言DUT死锁或数值错误。A003独立核对的四条前缀边界与AT049一致，仅限日志观察，不证明源码或全链等价；[研究补证](../../source/feasibility_20261014/updates/at063/report.md)。v4预算保持冻结，不以此次失败墙钟/末marker重新校准整模性能。

已直接通知A002在M005阶段A原累计预算内继续普通定位/修复，先用受影响短测核W发布后的配置驱动、准入边沿及仿真时间推进，再消耗新full；无需新合同或普通步骤批准。原AT063不重启、不改记录、旧full额度不回填。[工程停止报告](../../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN4_AT063_bounded_stop_20261014.md)；[主控答复](../feasibility_mission_20261014/at063_stop_response.md)。M005继续，资源/频率UNKNOWN和原投入判断不变。

## AT064/AT065：受影响短测与第一次新full

AT064同身份adapter＋真实ledger在受控Wi退休、matrix ready绑为空闲条件下13cycle通过，25.378452s/峰1333804KiB；不能复现或排除完整链W边界故障。原guard `simulation_started=false`是marker识别字段，实际xsim/完成以原日志为证，不回写旧收据。

AT065冻结TB相对AT063只有W边界被动时钟/准入打印与四态断言增强。static111.926796s通过，真实LN前缀1AR/64R、5224cycle、23.505724s；新冷full于2026-10-14 10:25:51 CST真实启动，原3600s/8GiB/40M/semantic stall120s帽保持。3318.039514s成本估计只用于准入；无根因或整链终态。新时钟打印不计为语义进展。

本次已占M005新full **1/3**，其余至多2次且10800s累计帽不变；优先留给最终同一可综合top normal和合法不同反压样本。上述为启动时记录，终态见下节。原TB联合链不能自动代签尚未提取的综合top。已见short累计48.884175s、static111.926796s；全mission完整消耗由工程持续记账。综合/route继续NOT_RUN，阶段C预算不变。[工程进展](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/m005_at064_at065_progress_20261014.md)；[主控范围/预算答复](../feasibility_mission_20261014/at064_at065_scope_budget_note.md)。

## AT065终态与代表top接口决定

AT065于2026-10-14 11:00:32 CST结束，**FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN**，2080.617893s、child0/trigger null、峰1036444KiB。child0不能覆盖原日志Fatal和runner FAIL。cycle358880已完成Down W发布，TB真实过negedge并拉高cfg_valid；ready/ledger/candidate为1，static_ok/matrix_valid为x，四态断言失败。Down真实受理/TMP实写、末残差、最终gold/655360B保护均未到，没有完整链周期。

冻结TB的g_cfg_K仅在gate_k连线上出现且未声明驱动；当前G硬件实际固定K2624。这是明确接线缺陷和X来源候选，未独立排除其它static_ok条件，不能预签唯一根因。AT063旧semantic_stall及AT064受控合法K的局部PASS各留原范围。

主控已集中确定[D-M005-FEASIBILITY-01-A1](../../mission/M005_代表通路与整模性能可行性评估/top_interface_addendum_20261014.md)：G K由实际内部固定配置提供；bridge只读引出quant任务债；top从真实AXI AR/R维护读债，与内部任务债共同限制LN源租约释放。新端口/计数器与所有实际核心纳入同版正常/反压及物理身份。这是待实施/验证的接口决定，尚无新top PASS或资源结果。[给工程的执行答复](../feasibility_mission_20261014/top_interface_controller_reply.md)。

实际已报新full 1/3及2080.617893/10800s；short48.884175/600s，static111.926796/5400s。原预算不扩，剩余两次full优先最终同top正常/反压，先短测/static及真实前缀准入，再依功能结果进入联合综合/route。阶段C v4与当前投入建议不变，M005仍未完成。

A003已独立核对相同Fatal边沿和冻结TB身份，结论与上述范围一致；[研究补证](../../source/feasibility_20261014/updates/at065/report.md)保留10份输入身份。H008仅0.053285s，A003累计3.266915s；v4三个SHA锚点不变，无模型重跑或新性能校准。

## AT070同top正常样本停止与最后一次full

AT070于2026-10-14 11:47:50 CST结束，**COST_STOP_SEMANTIC_STALL_AT_W_LOAD**，716.009461s、child−9、末进展后120.094206s，峰1014816KiB。主控核原guard/trigger/log；无Fatal/ERROR/CHAIN_PASS，不判数值FAIL或确定DUT死锁。LN四行原4096 gold、4AR/256R、4AW/256W/4B、16384B store/发布/lease检查于cycle170043通过；Q前缀到达。最后W q0 AR2/R64、scale AR1/R0、q1为0是日志观测，不是精确停机cycle。Wi、G、第二Q、Down/TMP、残差/最终gold及655360B保护未到。

工程已报告236项终态身份复核和端口/TB静态比对，主控本次沿用其限定结论而非重算全部包。静态映射相同不能证明提取top后动态等价。[原停止报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT070_top_normal_bounded_stop_20261014.md)。AT066局部读债短测、AT068–070静态及前缀证据仍仅限各自范围。

M005新full累计 **2/3、2796.627354/10800s**，剩余最多一次，已无法补齐两个完整正常/独立反压样本。主合同R2保持原稳定性通过标准和所有预算：先同top真实W短测定位，有可检验原因及修正/短测证据才按新成本准入使用最后正常full；否则不为用完次数启动。最后一次通过也只能得到单个完整正常样本。

R2同时解除“两个完整样本都通过才允许任何物理测量”的执行依赖：短测定位收束、结构和静态有效后，在原综合/route预算内诊断测量最终冻结同top候选，资源/频率与功能未闭合分列。不得通过关键裁剪、缩缓存或忽略未驱动/环路伪造代表性；无效网表或明显超器件时不route。该分支服务于投入判断，不降低阶段A验收或签可用加速器。[主控执行答复](../feasibility_mission_20261014/at070_controller_response.md)。v4不由此次失败前缀校准，当前不扩大串行路线投入的建议保持。

## AT071–AT073：W测试台接收边沿修正，最后full已启动

AT071同top冷W短测在时钟推进下3000cycle Fatal，guard15.236713s/child0，无通过。AT072仅改变TB W/AUX周期条件的相位并增加被动观察，实际第二q0 AR及其后R恢复，q0/q1/scale 128/128/64 R、cycle187 PASS，6.771937s。正常TB AT070→AT073 diff只增加negedge锁相位并替换四项ARREADY/RVALID表达式；支持接收边沿竞态的有限修复，不代签整链。

AT073同冻结top新冷pilot 22.688626s、5224cycle、LN真实1AR/64R；3316.187680s是准入估计。原launch记录2026-10-14 **12:11:05 CST**真实启动，主控当时核PID/startticks匹配及SIM_START/LN AR原日志。新full现占 **3/3**；启动前完成2796.627354s加本次真实耗时待终态，不改prelaunch full_started=false。当前完整gold、后段/保护/整链cycle尚未取得。

当前run按原guard继续，无第四次full。negedge锁相位不自动证明跨拍RVALID在RREADY低时保持，已要求终态利用既有blocked计数/保持检查登记实际覆盖，无检查则保留未验；不改变冻结run或追加full。独立合法反压完整样本仍缺，R2诊断综合/route的范围与原帽保持。工程完整236＋22身份核验沿原交付，主控本次核diff/原日志/成本/启动而非重算全包。[工程报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT071_AT073_W_phase_fix_progress_20261014.md)；[主控核对](../feasibility_mission_20261014/at071_at073_controller_review.md)。

## AT073终态与hub物理边界R3

AT073于2026-10-14 12:47:24 CST结束，**FAIL_SEMANTIC_DOWN_RESIDUAL_TICKET**，2178.352224s、child0/trigger null、峰1015196KiB。Down真实256 AW/W/B、TMP总64KiB检查窗口（含16KiB独立gold输出及48KiB邻区）、Wi/G前缀已过原检查；Down cfg358881、末B375058、首次done375066、实际消费375073。cfg→首次done端点差16185cycle；cfg→消费端点差16192cycle，两端采样均计入为16193cycle。cycle375074打印FFN0_PREFIX_PASS后票据合取断言Fatal；未逐项打印失败操作数，不独断具体子因。残差cfg/双源读取/4096 add/新HIDDEN及最终655360B终扫未到，无完整链PASS。

口径更正：本页先前把16185误记为“cfg→消费含两端”，把TMP邻区误记为输出之外64KiB；依据[A003独立核查](../../source/feasibility_20261014/updates/at073/report.md)及主控对原端点/冻结TB复算，已按上段修正。历史通信/原始日志不回写。v4原使用16192，三处审核SHA锚点仍一致，服务率及6.919–8.133s条件预算均无数值变化。

Down阶段W/AUX R不就绪计数全0，只说明该窗口没有跨拍RVALID等待覆盖；计数在Wi→Down切换重置，Wi及独立反压不据此补签。新full累计 **3/3、4974.979578s**，本轮全链尝试收束，不追加。主控核了原日志/guard；[工程终态报告](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT073_down_retirement_fail_20261014.md)。

诊断综合AT074/075/077分别因显式net声明、geometry_within动态循环、geometries_disjoint动态循环报错，累计 **127.352275s**；均无有效网表、资源或时序，不是器件fit结论。AT076前一函数固定32步后的portal短测27.401092s通过，仅限原收据范围，不覆盖后一函数。

主控R3选择继续保留原行为的有界组合展开：最多2×32区间、同role半开区间相交、自项排除、64bit规则和原接受/响应时序不变，可去除重复有序比较（最多2016无序对）并共享端点。先以冻结旧函数作差分参考及受影响portal检查；不改多周期、不删检查/缩容量、不把新物理候选冒充AT073同一完整验证身份。综合剩余3472.647725s，结构/fit有效后才原帽route；结果继续注明功能未闭合。[R3决定](../feasibility_mission_20261014/hub_geometry_physical_boundary_decision.md)。

最新[预算账](../../project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_budget_ledger_after_AT077_20261014.json)中short176.874256s/static390.634458s为已测下界，AT066–069及部分host未知时长须由原记录恢复实际或有据上界，不按0扣除。v4暂无新有效物理或末残差计量可替换；当前不扩大串行路线投入的建议保持。
