# SM004 修订18工程阶段交付：Q16 部分窗口占有与 LN128 成本

2026-10-15；D-M004-LNQ-COST-OWNER-01、D-M004-REV18-COST-STATIC-01；E004/R001，AT301–306。M004/SM004 完整目标继续 `running/unassessed`。本交付是工程证据，待 A001 限定审核。

## 生产差异和 Q16 反例

当前生产 core SHA256 `a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`；wrapper `5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26`、sequencer `a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4`、LNQ/量化叶子与独立 gold 未变。core 在 `q16_next_row!=0 && !a_window_ready` 时只接受 `cmd_exec=010` 和 `prep_kind=10`；不兼容命令和预装无握手，不能在部分窗口占有期覆盖 A bank。满窗口 release/discard 语义和数值/布局不变。

[AT302 旧版原日志](../attempts/AT302_SM004_rev18_q16_partial_old_incremental_build_01/guard_old_repro/driver.log)实际以保存 norm、真实 Q 叶子填首行，再由 `prep_kind=01` 接受 index0 写覆盖 A row0，而 cover 仍 `0001`，终标 `Q16_PARTIAL_OLD_OVERWRITE_REPRO`。AT301 自设 45 秒静态帽超时，原失败保留。[AT303 修复版原日志](../attempts/AT303_SM004_rev18_q16_partial_owner_fix_01/guard_rtl/driver.log)终标 `Q16_PARTIAL_OWNER_PASS rows=0,1,new0 rejects=5 abort=1 discard=1`：kind00/01/11 和 legacy/LN 命令均零准入，原 A row0 的 272 字保持；合法 row1 继续、临时准备 abort 不释放窗口，显式 partial discard 后新 epoch row0 逐位通过。此为局部两行 Q16 生命周期，不代表 16 个真实 producer 行或父图接续。旧 AT290 满窗口和错 epoch 范围仍按原身份保留。

## 同源默认/`--O3` 有界诊断

[AT304 默认](../attempts/AT304_SM004_rev18_ln128_current_default_diag_01/guard_rtl_diag/driver.log)与[AT305 `--O3`](../attempts/AT305_SM004_rev18_ln128_o3_diag_01/guard_rtl_diag_o3/driver.log)在同一修复 core、未变 wrapper/sequencer、同一冻结 TB/fixture 和原 FP/IP 库闭包下运行固定 30000 cycle。两份manifest共有112个同名条目逐SHA相同（107个frozen源码/脚本与5个fixture）；AT304目录另有3个未列入manifest的Python字节码缓存，不能计作冻结来源。实际 `xelab` 接受 `--O3`，仅编译选项和 snapshot 名不同，均保留 `-L` 库、`--relax`、`-mt off` 与全部逐位检查。A/B 的 38 条 source、gamma、LN 输入/输出、norm W/B、行退休及进度 cycle 事件逐字相同；这38行以LF连接且不附末换行的SHA256为 `337b04e89ed48d7992cf2b81dee476f8fb6755da7ae82217e2492d02ae04a9db`；附一处末换行为 `8b5138a2292694ee77866ef34c46b8d7fc8a03b8c70bbba24882c20b29ac0fae`。两臂均退休 row0/1，核 2048 个 norm F32、128 笔 OKAY B；gamma256 R、全次 source192 R，其中 row2 的64 R已读入但未退休；`NORM_STAGE_READY`、request done 与 RAW/FINAL 均未发布。

默认/`--O3` 静态构建分别为 148.10003847070038s / 147.29114942997694s；RTL guard 93.29140920005739s / 89.64230179227889s，单次观测差 3.6491074077785015s（约3.91%），不能当作统计稳定加速或按两行外推128行。详细身份、命令和[机读对照](SM004_rev18_ln128_default_vs_O3_cost_20261015.json)保存。AT305首次 guard 因相对脚本路径错误 child127/0.17315470799803734s，原收据保留；正确绝对路径的新 guard 独立成功，不能回写首次终态。

`--O3` 有测得的小幅改善，故按合同自动执行[AT306 同版真实请求 pilot](../attempts/AT306_SM004_rev18_ln128_o3_16row_pilot_01/guard_rtl_pilot_o3/driver.log)。原完整128行 TB/逐位 norm checker 保持，120 秒帽内实际只退休 row0/1；2048 项 norm 与128笔 B已核，row2 的64 source R已读入而未退休。guard 120.30851850099862s、child−9/`timeout`，结果 **COST_STOP**。未完成首个16行窗口，因而没有保守 LN128 落帽估计，不启动1800秒长例；真实 LN128、`NORM_STAGE_READY` 均未通过。

## 成本账与后继边界

[AT301–306 逐 guard 账](SM004_rev18_guard_ledger_AT301_AT306_20261015.json)含所有失败、启动错误、A/B 和 pilot：static 7 笔 **742.38596129976213734/900s**，RTL 5 笔 **363.27006784640254/2400s**；余 157.61403870023786266s / 2036.72993215359746s 属修订18本阶段未用额度，交 A001 决定，不并入旧修订。6 份 manifest 共756项逐 SHA 匹配，101 条实际 CPU0–3/nice19/idle 政策样本零不匹配；host 准备完整累计 UNKNOWN，MemAvailable 全部大于192GiB。旧修订17余额封存不动。没有新 HLS、OOC/P&R、oracle/gold 或第二计算 top。

当前成本瓶颈只证明完整父 top 仿真未落本段 16 行 pilot 帽，未以声明计数推定具体叶子开销。下一最小工程边界是单独合同下抽出仍由生产父 top 唯一例化的共享 LNQ/bank/prep/真实 source 与 norm 服务验证层，先用相同 gold/总线债核完整 16 行实测成本，再判断能否运行真实 LN128；不在本修订自行改 CE/时钟或算术。Q16 父图、MATRIX16/STEP16、全 RoPE/FINAL→Attention、旧全请求首错等价、完整模型及 Host/HBM/联合物理仍未验。


### 主控限定审核与计数勘误（D-M004-REV18-REVIEW-01）

主控[原始证据审核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/m004_simplified_start_20261014/lnq_cost_owner_rev18_review_20261015.json)限定接纳AT303当前core的部分Q16窗口占有修复与AT304/305同终点单次成本观测；AT306继续COST_STOP，修订18按成本出口收束。原static/RTL余157.61403870023786266s/2036.72993215359746s封存，不转后继。报告上文及[机读A/B](SM004_rev18_ln128_default_vs_O3_cost_20261015.json)现将共有manifest条目纠正为112=107 frozen+5 fixture，并列明事件文本有无末换行的两种SHA；[勘误记录](SM004_rev18_at306_count_erratum_20261015.json)保存更正前机读文件SHA。AT304/305原manifest、日志和guard未改，AT304旧purpose文字仍为冻结历史，不作为`--O3`是否成功的证据。
