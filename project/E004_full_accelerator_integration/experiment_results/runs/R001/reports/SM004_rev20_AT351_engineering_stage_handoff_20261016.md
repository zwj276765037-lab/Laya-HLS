# SM004 修订20 AT343–351 工程阶段交付

2026-10-16；A002；D-M004-SOURCE-NORM-OWNER-01。修订20的已授权实现和本段验证到静态预算出口；M004/SM004 仍 running/unassessed。原始费用见[逐笔机读账](SM004_rev20_guard_ledger_AT326_AT351_20261016.json)，新增冻结 TB、输入和生产闭包关联见[身份清单](SM004_rev20_AT344_AT351_incremental_identity_20261016.json)。所有原 guard、Fatal 与冻结文件保留。

## 当前生产身份与正常链

本段不修改 AT343 冻结的生产 RTL、FP/IP、reader/writer 或独立 gold：上层 `laya_source_norm_service_v1` SHA `58086436…`、唯一下层 `laya_lnq_bank_service_v1` SHA `f63e25e2…`、父 core `452deb9c…`、wrapper `b1b73970…`、sequencer `8b9261e0…`。新 attempt 增量编译 TB，复用 AT343 实际生产 work 依赖；五份实际 fixture 逐 SHA 等于 AT343。AT351 的展开未完成，不能视为新 snapshot。

[AT343 原报告](SM004_rev20_AT343_true_ln128_parent_row0_milestone_20261016.md)经主控限定审核：独立生产 stage 的16行 pilot 36.70097006671131s，16384 个 norm、1024 source R/B、gamma256 R 通过；同版真实 LN128 252.2839319705963s 完成131072个 norm W与最终内存逐位、8192 source R/B、128覆盖及 `NORM_STAGE_READY`。同版完整父请求 top 真实 row0 前缀49.062415182590485s，1024norm/64B/source64R/gamma256R、无提前 request_done/RAW/FINAL/stage ready。完整父 top 的128行同 runtime 未运行。

## AT344–351 受影响短例

| 尝试 | 结果与实际范围 |
| --- | --- |
| [AT344](../attempts/AT344_SM004_rev20_stage_error_recovery_build_01/) | PASS：真实 source 最后 RRESP 错，已接受64R排净、零 norm/B、Check7/phase14；真实 row0 最后一笔 B 错后，原16行窗口完成16384次 LN，1024 source R、64 B、15行受控 discard、零成功覆盖、Check7/phase12。两种故障均显式释放并在同一次仿真无 reset 新 epoch row0 逐位恢复。 |
| [AT345](../attempts/AT345_SM004_rev20_gamma_bus_page_build_01/) | 跨4KiB页界 STATE0 `0x20000fc0` 与有限 AR/R/AW/W/B 停顿 PASS：source 2 AR、64R，1024norm、64B、gamma256R，全字段保持断言；gamma 非有限例在预期错误完成后被 TB 的第二次 abort-ready 断言误报 Fatal，原 FAIL 保留。 |
| [AT346](../attempts/AT346_SM004_rev20_gamma_recovery_tb_fix_01/) | 只修正 gamma TB：前检读完256 AUX R后 Check6/phase14，零 source/norm/B，内部 prep 已自动 abort；显式 release 后同一仿真新 epoch row0 的1024norm/64B/source64R逐位 PASS。 |
| [AT347](../attempts/AT347_SM004_rev20_stage_descriptor_reject_01/)、[AT348](../attempts/AT348_SM004_rev20_stage_descriptor_reject_tb_fix_01/) | 保留 TB FAIL：前者错误假定 ready 恒高时 `done_valid` 保持，后者合法恢复请求遗漏还原重叠目的地址；不升级其局部终标。 |
| [AT349](../attempts/AT349_SM004_rev20_stage_descriptor_reject_recovery_01/) | PASS：非法 source span、base ID+127 溢出、source/destination 重叠分别返回所核的 id、op10/status7/phase14/detail `07100005`/bad64 全1，零新 AR、零 LN/W；ready常1使完成在首拍被消费；三拍后再核 status/detail 端点值，逐个显式 release，随后同 runtime 合法新 epoch row0 1024norm/64B/source64R及内存逐位恢复。TB 未逐项核 `done_bad_element` 与回显 row，也未检验 valid 受阻保持或所有字段逐拍稳定。 |
| [AT350](../attempts/AT350_SM004_rev20_stage_prep_reset_01/) | PASS：gamma 预装已收8笔 R、prep 活动时共同 reset；DUT 与 peer 同步清有效事务，510拍无旧 AR/AW/W、完成、覆盖或 token 可见；新 epoch row0 1024norm/64B/source64R/gamma256R及内存逐位恢复。仅签共同 reset，不签独立 AXI reset。 |
| [AT351](../attempts/AT351_SM004_rev20_local_reject_consumed_recovery_01/) | COST_STOP：旧父 core 本地拒绝后错误 done 消费→重新准备→合法下一命令的增强 TB 已冻结，但 `xelab` 在80秒计划帽触发，child−9，无 snapshot/RTL。原 AT330 本地拒绝 Check 修复仍按原局部身份有效；本次不宣称同 runtime 后继通过。 |

全部仿真 PASS 均要求显式终标、checker 逐位比较、guard child0/无 trigger 且原 driver.log 无 Fatal；xsim 自身 exit0 不覆盖 AT345/347/348 的 Fatal。AT345 受影响错误、AT347/348 及 AT351 的失败/成本照录，不改写原收据。

## 费用与保留缺口

AT326–351 共49笔 guard、356条实际政策采样，逐笔均符合 CPU0–3/nice19/idle；精确 static **1798.4354466479271734/1800s**，余 **1.5645533520728266s**；RTL **1323.850544061511735/3600s**，余 **2276.149455938488265s**。主控[D-M004-REV20-CLOSEOUT-01](../../../../../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at351_closeout_decision.md)已限定接纳并封存两项余额。AT351 guard 请求80s，实测80.31880732811987s/-9/timeout，计入 static。host 完整累计 UNKNOWN。静态余额无法支持一次已实测约35秒的最小增量展开；本段不借旧余额、不原样延帽。

AT344/346错误恢复由独立stage TB直接驱动 `stage_release_fire`/`prep_abort_valid`；这些局部PASS不证明父wrapper/sequencer的tensor_release准入或e/e+1/e+2策略。

仍未实测：AT330 本地拒绝 done 消费后的第三条合法 LN_ONLY（AT351 COST_STOP）；AT349拒绝路径的 `done_bad_element`/row 逐项回显；真实 gamma `load_done` 错；store 故障窗口后续数值 Check 优先；同步 bank pending/rsp 或末 B 受阻时向 legacy 换路；LN/回放在途 reset（本次只测 prep 在途）；完整父请求 top 128行同 runtime。已测的总线 B 延迟只证明本局部退休屏障，不代签全部交接。Q16 父图、STEP16/matrix、全 RoPE/FINAL→Attention、整模首错与完整模型、Host/HBM、联合资源/Fmax/物理实现均保持开放。后续若需上述新展开，主控须给出新的有界接口范围与独立预算；现有正常 LN128 冻结结果保持有效。
