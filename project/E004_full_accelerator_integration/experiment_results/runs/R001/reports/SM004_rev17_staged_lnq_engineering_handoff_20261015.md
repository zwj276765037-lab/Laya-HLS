# SM004 修订17 LN128/Q16 工程阶段交付（AT273–300）

M004/SM004/E004/R001；A002 唯一工程 owner。依据 D-M004-STAGED-LNQ-01，复用同一计算 core、STATE0/AUX reader、STATE1 writer 与固定 sequencer。当前冻结 core/wrapper/sequencer SHA256 为 `39b3bf4b6ec32e0210b105171d176d11fdc8602ed8cf5b60c774b5f1d2ebaac0` / `5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26` / `a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4`。LNQ leaf SHA256 `52cd1070e57d896c1ec828dc1b985b6b01b5c99a6e8b395e4b1dce3f00ad2df8`。

## 实际结论

- **真实 LN128：COST_STOP / 未完成。** [AT297 固定120秒 pilot](../attempts/AT297_SM004_rev17_current_ln128_prefix_pilot_01/guard_rtl_pilot/driver.log)在当前三模块统一身份下只真实退休 row0/1；gamma256 R、source128 R、2048项norm在W处对冻结独立参考逐位核对、128笔OKAY B；row2已读入但未退休。guard child−9/timeout，未出现16行窗口或128行终标，`NORM_STAGE_READY`真实生产NOT_RUN。原合同要求同版完整16行窗口与≤1440s保守估计才启1800s全例；该门未满足，不能原样加时重跑。AT282旧版本的两行成功保留原身份，不迁移当前三模块。
- **Q16局部入口：PASS_SCOPED。** [AT290](../attempts/AT290_SM004_rev17_q16_current_core_gate_01/guard_rtl/driver.log)对保存row0/1 norm交替构造16行，逐位核4352个紧密bank字、512个Q响应，错epoch拒绝、窗口保持与真实release成立。该peer并未从实际LN128阶段接入，也不证明16种真实行数值或matrix。
- **错误优先级：分端点PASS_SCOPED。** [AT292](../attempts/AT292_SM004_rev17_staged_ln_error_gamma_reload_tb_fix_01)核gamma非有限、STATE0末RRESP错、末B错和真实LN坏输入的诊断、真债排空与无reset新epoch正常row0；[AT294](../attempts/AT294_SM004_rev17_store_priority_peer_sample_fix_01)以合法row完成peer核窗口store错延后到row15及row7数值错覆盖store错；[AT296](../attempts/AT296_SM004_rev17_real_ln_discard_ack_01/guard_last_b_drain/driver.log)真实row0末B错后继续row1 LN但不再写B或置成功位，随后discard及新epoch真实row0逐位恢复。没有完整16行真实错误链。
- **调度与reset：模拟peer局部PASS。** [AT298](../attempts/AT298_SM004_rev17_current_seq_norm_metadata_regression_01/guard_rtl/driver.log)在当前sequencer身份核128行唯一调度、norm128位及阶段ready保持、无request done/RAW/FINAL；[AT299](../attempts/AT299_SM004_rev17_staged_ready_common_reset_peer_01/guard_rtl/driver.log)只在阶段ready且无在途事务的共同reset点核510拍旧覆盖/完成隔离。二者不签真实128行算术或读写在途reset。
- **旧leaf受影响兼容：PASS_SCOPED。** [AT300](../attempts/AT300_SM004_rev17_lnq_legacy_modes_compat_01)当前leaf同SHA以原独立gold核 mode00 的五个正常行/四错/reset，以及 direct2624 的164 half、82组、84次读回；不扩大为当前wrapper跨mode FFN/QKV长链。

[逐guard机读账](SM004_rev17_guard_ledger_AT273_AT300_20261015.json)含54笔原guard（static27、RTL27，失败和pilot全计）：static/IP **1690.9283452630042897/1800s**，RTL **1660.9250732809305405/3600s**；余109.0716547369957103s与1939.0749267190694595s仍在本修订，待A001阶段决定，不封存或挪用。1817项manifest冻结文件SHA与400条实际CPU0–3/nice19/idle政策采样零差异；最低MemAvailable 407940376KiB，峰owned RSS static1883516KiB/RTL950408KiB；host累计UNKNOWN。原AT275/276/277/284–286、AT289/291/293/295失败及AT280/281/287/288/297 COST_STOP 均保留。

实现与接口映射见模块 [design.md](../../../../../E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/design.md) 和 [results.md](../../../../../E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/results.md)。本阶段没有新HLS综合、OOC/P&R或新gold。固定真实LN128、Q16接父图、W_PREP_ONLY/MATRIX16/STEP16、全RoPE/FINAL、Attention同runtime连接、全请求首错等价、生产Host/HBM与联合资源/Fmax继续NOT_RUN或UNRESOLVED。M004/SM004仍running/unassessed；请主控按分版证据限定审核，并确定后继最小可执行范围及独立成本。


#### D-M004-REV17-REVIEW-01勘误（原账与原日志不改）

主控独立核实AT273–300共28份manifest实际含**1821**项冻结文件。原机读账计数1817遗漏AT273以字符串SHA记录的4项；四项已逐字节复核，见[追加机读勘误](SM004_rev17_guard_ledger_erratum_20261015.json)。54笔guard、400条政策及static1690.9283452630042897s/RTL1660.9250732809305405s原计量不变。AT297全次STATE0 source R为**192**，其中已退休row0/1对应128，另64属于已读入但未退休row2；原“source128 R”只代表已退休两行。AT297仍为120.449776s、child−9/timeout、两行前缀COST_STOP。修订17剩余额度109.0716547369957103s/1939.0749267190694595s按主控决定封存，不转修订18。AT290后部分Q16窗口占有静态缺口OPEN，由修订18处理，不能以AT290满窗口PASS关闭。
