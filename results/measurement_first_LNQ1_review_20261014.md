# LNQ1运行包缺失核定，转LNQ2有界有效重放

R-SM005-LNQ1-20261014；M004/SM005/E005/R001；对应`EV_SM005_LNQ1_AT048_ROM_STAGING_STOP_20261014`。回复`measurement-first-LNQ1-AT048-ROM-stage-stop-handoff-20261014`，合并`measurement-first-LNQ1-ROM-prelaunch-guard-addendum-20261014`。主控仅审查已有文件/日志/身份，未执行DUT。

**核定AT048 static PASS，唯一full为COST_STOP_INVALID_RUNTIME_ROM_STAGING。LNQ1已收束，未取得新发布观察或联合行为结果。下一[D-M004-LN-QAR-RUNTIME-01](../mission/ln_qar_runtime_replay_stage_20261014.md)选择LNQ2：保留AT048全部DUT、两份TB及数据/profile，只补运行包和启动闸口；短前缀及成本合格后至多一次新冷启动full。工程按合同连续执行，普通准备步骤无需逐项审批。新RTL结果NOT_RUN。**

## AT048实际边界

主控逐SHA/bytes核298条引用（manifest、receipt链接、AT047比较源），并独立核guard和ROM部署材料，共哈希314条路径；AT048 manifest准确为286引用/285路径。相对AT047只有源阶段与联合TB两份观察文件变化，DUT/fixture/runner/guard保持。两段guard串行，35条实际policy（31+4）全部CPU0–3/nice19/idle，内存与墙钟上限符合合同。

static为108.767826s、峰2950116KiB、child0/trigger null，原日志有`LNQ0_STATIC_PASS`。full为126.977810s、峰1033296KiB、child−9/semantic_stall。实际观测到base配置23、BEGIN响应132、producer请求完成148和行游标149；149仅是末条已见marker，不是已证最终停拍。没有LN source AR、算术/写回、END/PUBLISH witness、外部Q、Wi/G/Down或联合终扫/PASS。该次full额度已用尽，旧目录及失败不补改。

原日志共有8条无法读取告警，对应7个不同LN ROM（roles文件告警两次）。7份冻结源合338B逐SHA匹配manifest，也与AT047实际xsim目录中的副本相同；AT048实际cwd中全部缺失。这足以判运行包不完整，无法将这次停止用于评判新观察或DUT活性；不声称已证明DUT死锁或唯一内部门级根因。

## 观察修复与成本的适用范围

两份TB差异锁存原有效采样点（END包已提交、响应尚未消费）的scope/coverage/状态/计数/完整packet；保留原实时检查、完成字段、gold和保护字节检查，另存成功END/PUBLISH响应。发布后核历史证据、任务身份、真实计数及当前scope关闭/drained/published owner，拆分打印。差异未修改DUT输入/时钟/响应时序，没有加入额外等待；快照不是续命进度。但AT048没有执行到这些新观察，仍无动态验证。

原成本3464.199672s<3600s可以复算，但依赖运行部署与原有效前缀等价；AT048未满足这个前提。它不是联合周期、部署时延或完成保证。后继必须先证明新包可执行真实LN读事务，再重新形成成本准入，不能以静态PASS或源SHA一致替代运行环境完整性。

## ROM补充检查与后继执行

已核工程live runner/helper为补充消息所列SHA。helper枚举的7个名称与预期SHA全部等于冻结源，先核全部源再复制、复核目标；runner在elaborate之后、static PASS之前调用。主控留有这两份审查时点副本。工程报告的临时目录host正例/源损坏反例仅属host检查，未有新Vivado或DUT结果，本次未重跑该检查。

现有改动覆盖编译后部署，但AT048此前通过独立xsim命令启动full。LNQ2因此要求在每次实际xsim启动前对解析后的cwd、7个目标和全部fixture/plusargs做verify-only闸口，并冻结真实运行清单；目标缺失/损坏负例必须在spawn之前拒绝。不能靠再次覆盖目标让负例消失。新的运行期文件告警应立即归类准备失败，保留原guard，不再浪费120秒等待停滞。

新合同允许一个准备方案及full前一次有因launcher修正（至多两次static/两次≤120s前缀，复用未受影响项），不修改AT048 DUT/TB。短前缀必须见真实source AR和R，之后依据新成本记录准入至多一次冷full。任一新full失败就交付，不续开旧LNQ1额度，也不添加TB/DUT修复。工程无需为正常准备步骤回问用户。

AT047原语义FAIL、AT040/AT035独立局部PASS和AT044受控adapter检查保持原边界，不能拼成联合PASS。LN→Q→Wi→G→Q→Down新联合终态仍未验；完整普通多窗口Q/L、28+2层/122矩阵、13BO请求/恢复、联合资源/时序/上板与M003/M004均未完成。原资源帽、A002单owner、G仅OOC余额与整体控制停排保持。

证据：[主控核验](measurement_first_LNQ1_review_20261014/verification.json)、[AT048收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/receipt.json)、[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/guard_full/driver.log)、[原ROM核对](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/missing_dat_audit.json)、[工程准备补充](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_ROM_prelaunch_guard_addendum_20261014.md)、[审查时helper副本](measurement_first_LNQ1_review_20261014/reviewed_preparation/stage_ln_roms_v1.tcl)。
