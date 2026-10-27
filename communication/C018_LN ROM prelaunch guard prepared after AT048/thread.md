

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C018 · LN ROM prelaunch guard prepared after AT048

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### measurement-first-LNQ1-ROM-prelaunch-guard-addendum-20261014

2026-10-13T20:13:16.080764+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# LN ROM prelaunch guard prepared after AT048

2026-10-14; M004/SM005/E005/R001; A002. This is a live runner preparation fix for any **future** frozen attempt. It does not modify AT048 or authorize another LNQ1 full.

The live `run_lnq0_chain_v1.tcl` now sources `stage_ln_roms_v1.tcl` immediately after elaboration and before `LNQ0_STATIC_PASS` or simulation. The helper requires the xsim directory, validates the seven exact generated LN ROM names and their SHA-256 against the frozen AT040 baseline, copies them into the xsim working directory, and rechecks the staged hashes. A missing helper, source, destination or mismatched hash makes the static entry fail before a full launch. A future attempt must freeze **both** Tcl files and record their identities; the generated LN RTL and ROM contents remain unchanged.

Live runner SHA-256: `2c7f28d45a8af296b8026073cd989a2b2ac80f666b10551121c51a6819e489b6`; helper SHA-256: `31d7e56d5e2b63cf1510d84129db542f35779704dfc051cf9f36f11286e17a85`. A host-only `tclsh` check staged all seven AT040 frozen ROMs into a temporary directory and verified every target digest against its source. Corrupting one temporary source was rejected before any target copy. This checks the helper's good and bad branches; a new Vivado compile/simulation has **not** been run and remains subject to a new stage contract and the original tool caps.

AT048 still has static PASS/full COST_STOP due to its absent runtime ROMs. Its frozen inputs, work directory, original logs and receipt were not changed. No END/PUBLISH or Q/Wi/G/Down result can be inferred from this preparation fix.


[原始消息收据](../../.research-agent/communications/measurement-first-LNQ1-ROM-prelaunch-guard-addendum-20261014.json)

## 相关决定和审核

- [measurement_first_LNQ1_review_20261014](../../results/measurement_first_LNQ1_review_20261014.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
