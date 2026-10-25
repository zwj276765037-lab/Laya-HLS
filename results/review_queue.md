# 当前结果：修复版完整30层一次运行通过，项目暂停

updated: 2026-10-25（北京时间）
execution_state: paused
verdict: unassessed

主控增量128已接纳D37/E021 R005完整正常路径：正式参数0，从原embedding_norm开始，一次BEGIN连续计算28 Encoder、final LN/type、2 Decision和544组尾输出。13036119周期，RTL仿真10101.230975秒（2小时48分21秒）；原完整终标、实际尾部提交、heldDONE消费和idle全部通过。

主控独立核全部30层真实H及唯一采集trace、finalLN/type和69632B输出对原参考逐字一致；实际120矩阵/480head/60LN/61VECTOR/28GEGLU、两FC1各16384写/ACK/发布后才FC2。3200执行身份无失配，2262已知进程身份无存活/僵尸；2个瞬态policy样本保留UNKNOWN。22份费用收据复算static372.653189/1800s、RTL10101.230975/15600s；另2次失败准备耗时UNKNOWN、保守预留240s，余额封存不转。

本次证明修复版完整硬件主干在该原始请求上的RTL正常路径功能；未验所有异常/复位或四态行为，也未验联合物理时序、上板和实际吞吐。D35原FAIL及D36分段PASS保留。按用户要求完成核验归档后暂停，不启动后继。

[主控独立终审](reviews/m007_fixed30_final_review_20261024.json) · [工程最终收据](../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/final_fixed_original30_receipt.json)

---

以下为历史记录，不代表当前执行状态。

# 2026-10-24 当前结果：gamma修复及完整后缀通过，项目暂停

execution_state: paused
verdict: unassessed

主控增量127已接纳D36限定范围：旧版在真实gamma命令为0时复现数值错误；父端保持gamma到N_RUN后，使用已保存Encoder27实际H，完整final LN→type-add→两Decision→544组尾输出在同一次后缀仿真通过。四个131072值端点和69632B尾输出均匹配原参考，实际尾部提交、heldDONE消费和idle正常，主例710.202771s/900800cycle。

主控独立核143执行身份、全部实际输出及两Decision唯一采集trace；工程扩展核1654项身份。46笔费用收据复算一致：static710.513908/1800s、RTL754.460550/3600s，余额封存、旧余额不转。4525个已知进程身份均清空，2个瞬态政策采样保留UNKNOWN，完整host费用UNKNOWN。

前28Encoder保留原D35通过身份，未重新运行。原R003完整请求FAIL不改；SEGMENTED_SUFFIX不代签修复版完整30层一次BEGIN、端到端性能、四态全覆盖、物理或上板。当前按用户要求暂停，不启动后继。

[主控集中核验](reviews/m007_final_ln_suffix_review_20261024.json) · [后缀最终收据](../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004/attempts/AT006_fixed_complete_suffix/final_suffix_receipt.json)

---

以下为先前状态及历史证据。

# 最新状态：M007暂停（2026-10-24）

增量126已核：原28Encoder连续前缀通过，final gamma LN复合断言FAIL。当前验证结束，按用户要求归档后暂停，不自动派发修复或重跑。根因动态分支仍UNKNOWN；[暂停点](missions/M007_summary.md)。

---

以下为历史审核队列，原running/继续不构成暂停后的执行授权。

# 当前审核队列

2026-10-23：主控已核至增量111。完整Wi→GEGLU→Down同runtime及当前joint残差128→LN128已验。修复后新仿真器当前父QKV1的8192值与原86事件通过；完整层120s试跑已完成全部393216 QKV值和四个Attention head，随后成本停止。完整Encoder/原28+2仍未通过，现以同源单/四线程A/B测实际仿真速度；模型/数值/gold保持。

<!-- research-agent:stage-events:begin -->
## Stage review index

Active: 10. Resolved: 0. Newest events appear first. Full evidence and review history remain in the linked small-mission review pages.

### Pending / needs evidence / revise / paused

| Event | Small mission | Trigger | Review | Decision required | Summary |
|---|---|---|---|---|---|
| [EV_SM006_R001_AT087_physical_cost_stop](reviews/SM006.md) | SM006 | blocker | pending | true | M005 R3同一代表top联合综合在AT087达到24GiB owned RSS保护而停止，无有效DCP、联合资源或布线频率；AT073功能链在Down退休票据Fatal，full 3/3已用尽。 |
| [EV_SM006_AT063_DOWN_W_STOP_REVIEW_20261014](reviews/SM006.md) | SM006 | anomaly | pending | false | AT063原full在Down W发布后semantic_stall停止，2080.298887s；Down cfg/末残差/最终保护未到 |
| [EV_SM006_M005_STAGE_C_FIRST_ANALYSIS_20261014](reviews/SM006.md) | SM006 | milestone | pending | false | M005阶段C独立全图条件预算完成并经主控核对40输入；150MHz/10GBps及显式未测速率下6.919–8.133s，非整模实测 |
| [EV_SM005_FFR0_AT053_SCOPED_PASS_20261014](reviews/SM005.md) | SM005 | milestone | pending | true | FFR0 AT053 four-row external skip/Down residual RTL passed independent bitwise gold and actual AXI … |
| [EV_SM005_LNQ1_AT048_ROM_STAGING_STOP_20261014](reviews/SM005.md) | SM005 | blocker | pending | true | AT048 observation-only derivative static PASS; its sole admitted full stopped at semantic_stall bef… |
| [EV_SM005_LNQ0_AT047_BOUNDED_FAILURE_20261014](reviews/SM005.md) | SM005 | blocker | pending | true | AT047 unique combined full reached LN four-row B, completion and PUBLISH, then frozen TB asserted a… |
| [EV_SM005_ATN1_SCOPED_RESULT_20261013](reviews/SM005.md) | SM005 | milestone | pending | true | ATN1 one same-resource Attention scheduling candidate completed normal 128-row numeric/cycle compar… |
| [EV_SM005_KB1_DOWN_AB_20261013](reviews/SM005.md) | SM005 | milestone | pending | false | KB0/KB1四行Down同profile全gold PASS；命令到first done减少23.30%，全冷TB减少10.06%，实际写事务512→256。 |
| [EV_SM003_EXECUTOR_CHECKPOINT_RTL_20261013](reviews/SM003.md) | SM003 | milestone | pending | false | 真实v2 hub/LPV transport下界与16拍consumer、实际捕获C++导入及受影响兼容限定通过 |
| [EV_SM001_R001_baseline_import_complete](reviews/SM001.md) | SM001 | milestone | pending | false | 原baseline当前阶段收口后完整复制、双侧SHA核对和research-agent原生结构接入完成；原工程保留。 |

### Recent resolved (up to 8)

| Event | Small mission | Trigger | Review | Decision required | Summary |
|---|---|---|---|---|---|
| — | — | — | — | — | No entries |

Earlier resolved events omitted from this compact queue: 0. [Full per-mission review pages](reviews/).
<!-- research-agent:stage-events:end -->


2026-10-23 增量89–90：D31过程合并局部等价通过，单样本总仿真仅1.057倍，不升级LN128成本门；D30正式v3 ABI/模型装载/错误/tail协议及K4096静态容量已核。D29 type接线实际进行，D32完整父v3合同已落SM012，待实际followup启动；完整Encoder/原28+2层未验。旧R006余额保留，R007新预算不转。

2026-10-23：D32已实际followup复用A010，源码实施先行；D29优先重工具。登记不代签实现/运行完成。


2026-10-23 增量92–93：D29原type_add全128行/4096提交及真实joint通过并封存；D32独立W reader缺末拍/真实排债短例通过。新canonical父v3源已实施，TANHv3最小接入已实际派发，随后首次编译；完整Encoder/原28+2同runtime仍NOT_RUN。最新状态以mission/current.md为准。


2026-10-23 增量112：单线程完成全部QKV及首head数值/周期检查；四线程新构建成功但首head检查FAIL，正核实际错误项，未采用该配置。完整Encoder/原28+2仍未验；详见SM012集中审核。


2026-10-23 增量115：E021/R001 AT034完整Encoder0正常路径同runtime PASS，427305拍，实际524288B输出与原参考逐字一致；Wi→GEGLU→Down、残差/LN、16head及4矩阵全部原检查通过。原四线程/旧checker失败保留。D34/E021 R002已实际followup复用A012推进原28＋2一次BEGIN，8b55完整图TB/真实120矩阵；目前30层未验，M007仍running/unassessed。


2026-10-23 增量116：E021/R002 AT004真实kind7一次BEGIN完成global0 QKV与head0..7；119.134035s按未知pilot帽COST_STOP，无SV错误/停滞、无完整层checkpoint。正式30层成本门仍关闭。接续同exe首原global0层端点600s诊断、连续阶段各120s及原全部checker；并行只读模拟器加速分析。完整Encoder0 kind5的增量115结论保持。


2026-10-23 增量117：E021/R002 AT005在原kind7一次BEGIN中达到global0/checkpoint0（424292cycle）；真实4096组H/131072值/524288B经主控逐字核原Encoder0一致，SHA9d1c8d61…e55b。336.444740s，25个连续段均≤120s，最大81.945932s为LN后Wi/G/quant→Down。外部按计划停在首层，原请求仍active，记PREFIX_PASS而非完整kind7PASS。继续有限模拟器加速A/B与合法独立Decision准备，后续29层/finalLN/type/tail未验。


2026-10-23 增量118：E021/R002 AT010原kind6/local0完整Decision正常路径PASS，331.587451s、26/26连续阶段，FC1/ReLU/quant16384写/ACK真实发布后才FC2；实际global28 H及public output均524288B，主控逐字核原decision_00_out一致（SHA44ea5ccb…0546）。这是公开独立Decision，未代签kind7后继。590空dispatch候选语义/周期相同但慢约1.8%，已弃用；短PC采样未发现足以倍速的单热点，停止编译调参。继续同exe Decision1及完整图成本规划。


2026-10-23 增量119：AT011完整Decision1正常路径PASS339.304331s，实际524288B与原decision_01_out及public输出经主控逐字一致（SHA2403ecaa…f26a），两Decision26个成功cycle端点一致但不泛化数据成本。D34/R002组件/成本阶段收束不转余额；当前原30层仍未完成。按用户持续完成授权，D35/E021 R003制定一次完整kind7计划：分项代理约2.83h、条件规划14186s，独立RTL15600/留600、单次15000，每层600/各段120保护。仅此完整请求替代通用3600帽，CPU/内存/低优先级不变，原全部模型/参考/数值保持。


2026-10-23 增量120：D35/E021 R003 AT001原kind7一次BEGIN已实际运行；主控重核958项实际依赖/输入SHA零差异，复用AT010/011同exe，已观测单线程。全图driver通过3份既有真实组件事件回放及明确次序/超时拒绝，synthetic不代签跨层RTL。当前首层16head完成、WO进行中；30层与最终尾部待实际终标。额外Encoder27→finalLN/type→Decision0 preLN整体120s监督正在补入，原运行冻结driver与DUT不改。


2026-10-23 增量121：R003 AT001同一原kind7已完成global0..4，主控独立核5份实际H及各4096唯一采集坐标/trace重建、原参考SHA和全字节均一致。原完整层耗时325–328s，已进入global5；完整30层与tail仍待终点。


2026-10-23 增量122：R003 AT001同一原kind7已完成global0..9；主控独立核10份实际H、每层4096唯一trace及原参考全字节相同，共1310720个F32。已进入global10；30层和tail尚待完成。


2026-10-24 增量123：R003 AT001同一原kind7已完成global0..14；主控独立核15份实际H及原参考全字节相同，每层4096唯一trace重建完整。已进入global15；全30层/tail仍运行。用户明确本次验证、核对归档完成后暂停项目，禁止自动接续新实验。


2026-10-24 增量124：R003 AT001同一原kind7已完成global0..19；主控独立核20份实际H和每层4096唯一trace重建、原参考全字节相同。已进入global20；继续剩余10层及最终交接/tail，完成核对归档后按用户要求暂停。


2026-10-24 增量125：R003 AT001同一原kind7已完成global0..24；主控独立核25份实际H、全部唯一采集trace和原参考全字节相同。已进入global25；剩余3Encoder/2Decision及finalLN/type/tail仍待实际通过，验后暂停保持。
