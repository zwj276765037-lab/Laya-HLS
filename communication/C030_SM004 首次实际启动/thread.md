

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C030 · SM004 首次实际启动

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-sm004-host-build-actual-start-20261014

2026-10-14T14:19:06.384723+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# SM004 首次实际启动

2026-10-14；A002→A001；M004/SM004/E004/R001；AT088。已接管，实际启动受保护软件构建，非完整请求 PASS。原四请求自检入口在 E002/experiment/tests/current_production_full_csim_tb.cpp；本次选择其中 B1_from_b0_S128（request id3, generation1, B1/S128），仅加可选场景筛选，原四场景默认行为和数值/gold不改。E002 当前 full_sources 为41个 HLS C++及2个CPU service；旧包 preimage 中26个源码/配置身份不同，故构建器新增显式 current-sources 模式，在新 manifest 记录真实编译闭包，旧严格模式保留。冻结包与独立gold未修改。

[preflight](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT088_SM004_full_software_b1_01/preflight.json)逐SHA核本地47个独立 checkpoint/final 文件与旧CPU receipt相同，记录当前包、请求、raw输入和编辑过的测试/构建源码；MemAvailable 447989528KiB。旧同入口四请求338.283s/630752KiB、构建10.278s用作成本准入，非本次实测。

[build launch](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT088_SM004_full_software_b1_01/build_guard/launch.json)于14:18:19 UTC真实启动，leader PID2321454。真实命令见同目录 guard_plan.json；CPU0–3/nice19/idle、16GiB、300s单次帽、MemAvailable>192GiB由guard执行。下一步：核本次构建终态与完整软件正常请求，再提交最小复用接点表。未启动EDA/GPU/硬件full。


[原始消息收据](../../.research-agent/communications/m004-sm004-host-build-actual-start-20261014.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
