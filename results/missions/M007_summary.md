# 当前结果：修复版完整30层一次运行通过，项目暂停

updated: 2026-10-25（北京时间）
execution_state: paused
verdict: unassessed

主控增量128已接纳D37/E021 R005完整正常路径：正式参数0，从原embedding_norm开始，一次BEGIN连续计算28 Encoder、final LN/type、2 Decision和544组尾输出。13036119周期，RTL仿真10101.230975秒（2小时48分21秒）；原完整终标、实际尾部提交、heldDONE消费和idle全部通过。

主控独立核全部30层真实H及唯一采集trace、finalLN/type和69632B输出对原参考逐字一致；实际120矩阵/480head/60LN/61VECTOR/28GEGLU、两FC1各16384写/ACK/发布后才FC2。3200执行身份无失配，2262已知进程身份无存活/僵尸；2个瞬态policy样本保留UNKNOWN。22份费用收据复算static372.653189/1800s、RTL10101.230975/15600s；另2次失败准备耗时UNKNOWN、保守预留240s，余额封存不转。

本次证明修复版完整硬件主干在该原始请求上的RTL正常路径功能；未验所有异常/复位或四态行为，也未验联合物理时序、上板和实际吞吐。D35原FAIL及D36分段PASS保留。按用户要求完成核验归档后暂停，不启动后继。

[主控独立终审](../reviews/m007_fixed30_final_review_20261024.json) · [工程最终收据](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/final_fixed_original30_receipt.json)

---

以下为历史记录，不代表当前执行状态。

# 2026-10-24 当前结果：gamma修复及完整后缀通过，项目暂停

execution_state: paused
verdict: unassessed

主控增量127已接纳D36限定范围：旧版在真实gamma命令为0时复现数值错误；父端保持gamma到N_RUN后，使用已保存Encoder27实际H，完整final LN→type-add→两Decision→544组尾输出在同一次后缀仿真通过。四个131072值端点和69632B尾输出均匹配原参考，实际尾部提交、heldDONE消费和idle正常，主例710.202771s/900800cycle。

主控独立核143执行身份、全部实际输出及两Decision唯一采集trace；工程扩展核1654项身份。46笔费用收据复算一致：static710.513908/1800s、RTL754.460550/3600s，余额封存、旧余额不转。4525个已知进程身份均清空，2个瞬态政策采样保留UNKNOWN，完整host费用UNKNOWN。

前28Encoder保留原D35通过身份，未重新运行。原R003完整请求FAIL不改；SEGMENTED_SUFFIX不代签修复版完整30层一次BEGIN、端到端性能、四态全覆盖、物理或上板。当前按用户要求暂停，不启动后继。

[主控集中核验](../reviews/m007_final_ln_suffix_review_20261024.json) · [后缀最终收据](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004/attempts/AT006_fixed_complete_suffix/final_suffix_receipt.json)

---

以下为先前状态及历史证据。

# M007 当前结果与暂停点

updated: 2026-10-24
execution_state: paused
verdict: unassessed

按用户“完成验证后 暂时暂停项目”收尾。本次 D35/E021 R003 AT001 已结束，主控核至增量126：**原 kind7 一次 BEGIN 连续完成28个 Encoder，随后 final gamma LN 复合断言失败；完整30层未通过。** 失败和既有通过证据均保留，未修改生产实现或重跑。

| 范围 | 当前已核结果 |
|---|---|
| Wi→GEGLU→Down、残差/LN、完整 Encoder | AT034 独立完整 Encoder0 已通过；本次28个 Encoder 中实际连续执行 |
| 连续28个 Encoder | 112矩阵、448head、55次完成LN、56残差、28GEGLU；28份实际H、每层4096唯一采集坐标及重建与原独立参考全字节相同 |
| 失败位置 | 冻结 m007_fullgraph_binary_tb.sv:257，`original final gamma LN checkpoint`；检查身份/重复地址/epoch448/数据，原日志未区分分支，动态根因UNKNOWN |
| 两个 Decision | R002 AT010/011 各自完整独立PASS；本次kind7未到达，不能替代真实前驱交接 |
| 本次未完成 | final LN成功、type加法、两Decision、544向量尾部、flush/commit、成功DONE与idle |

本次RTL guard9085.828054s（约2小时31分26秒），无资源/超时触发；最大已完成层338.475548s、最大连续阶段80.200750s。原28层端点cycle12142238，失败前进入N_RUN。模型实际单线程；958项源码/输入身份结束后重核零差异。原始Fatal后driver终止模型rc−9，不能当作COST_STOP。

静态后继线索：final LN 的 use_gamma 仅在 N_START 拉高，而resident LN适配器延后发命令且未锁存该资格；这是尚待动态区分的接口保持风险，未据此宣布本次具体根因或修复成功。暂停期间不启动修复、测试、综合或部署；仅等待用户明确恢复。M007整体仍未验收，两态RTL结果不代签四态、联合物理或上板性能。

[主控实际核对](../reviews/m007_original30_final_review_20261024.json) · [完整审核记录](../reviews/SM012.md) · [工程原始尝试](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R003/attempts/AT001_original30_kind7)


收尾核验：最终合并FAIL、额外交接监督NOT_REACHED；5个已知PID/start无存活或僵尸、实际政策零不匹配，未guard准备范围仍UNKNOWN。源码/原始日志/实际输出与费用保留，项目已暂停。


---

以下为历史时点，running/继续表述不代表暂停后的执行授权。

# M007当前状态

updated: 2026-10-23
execution_state: running
verdict: unassessed

主控已核至增量111。完整Wi→GEGLU→Down同runtime及当前joint残差128→LN128已验。修复后新仿真器当前父QKV1的8192值与原86事件通过；完整层120s试跑已完成全部393216 QKV值和四个Attention head，随后成本停止。完整Encoder/原28+2仍未通过，现以同源单/四线程A/B测实际仿真速度；模型/数值/gold保持。

| 范围 | 实际结果 | 尚缺验证 |
|---|---|---|
| 完整FFN / E016 R005 AT027 | 一次父请求Wi671744、G335872/3358720节点、Down131072逐位；137302拍 | 公开norm_ff入口，未与前段完整Encoder同runtime；无可导出重建的实际public binary |
| 当前残差/LN / E016 R007 AT025 | 两次残差8192提交，LN128的131072值逐位；LN16617拍 | 父完整WO→残差/LN→Wi串联 |
| 当前父图 / R007 AT031 | 全QKV393216、RoPE2048；首head score/max/prob已检查 | post-QKV120s成本停止，无HEAD_END/Context或父DONE |
| 完整Encoder checker / AT036–037 | 全checker编译；原H524288B身份一致，QKV3的24576值通过 | 后段checker和完整层尚未执行；AT036三个瞬态进程政策未采样 |
| 全模型供数 / AT038–039 | 120矩阵×4口，2897AR/1475136B样本，保持/多ID锁存通过 | AT041真实Wreader/cache退休已核8描述符/1608记录；父catalog集成、全120载荷未验 |
| Verilator / E021 D33 | ADD/MUL/DIV全原fixture与当前shared4协议同源码通过，根已核增量102 | 隔离fixedbatch修复经XSim时序及原FP/shared验证；当前父QKV1和四head已验，完整层120s成本停止；不替代四态/X传播 |
| 完整模型/平台 | 28Encoder+2Decision生产图已实现，47原checkpoint身份已核 | 一次BEGIN完整模型、正常tail_commit、联合物理/板卡与A6000比较未验 |

已验旧Attention父链E016/R003保留独立身份：全QKV、16head、Context/WO通过；不能替代当前canonical父完整层。旧M004/M006保持暂停，原FAIL/COST_STOP及预算不转。仿真墙钟不是硬件延迟。

[详细审核](../reviews/SM012.md)、[阶段合同](../../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md)、[架构与模型ABI](../../source/m007_residual_encoder30_20261023.md)。


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
