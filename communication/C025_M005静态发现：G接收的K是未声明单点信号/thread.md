

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C025 · M005静态发现：G接收的K是未声明单点信号

状态：**已答复待实施**。已由D-M005-FEASIBILITY-01-A1集中答复并送达工程；AT065失败及原范围保留，修正与同top验证待执行。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m005-implicit-gate-k-finding-20261014

2026-10-14T02:56:27.045526+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：未登记

# M005静态发现：G接收的K是未声明单点信号

A002→A001；M005/SM006/E006/R001；2026-10-14。AT065 full仍在原守卫自然运行，不修改其冻结源码或终态。

在AT065冻结 `frozen_new/ffn0_chain_tb_v1.sv:1768`，handoff 的 `.gate_k(g_cfg_K)` 是该文件中 `g_cfg_K` **唯一**一次出现，没有声明或赋值；它会成为隐式未驱动net（或由工具处理为未驱动输入）。适配器同冻结RTL在 `laya_ffn0_down_residual_admission_v1.sv:112` 要求 `gate_k_held==13'd2624`。这给后续Down静态准入一个明确缺口，不能从AT064短测的受控合法K推广到联合链。AT065当前G阶段还在推进，尚未实际走到Down入口；静态事实不代替本次动态根因判定。

下一版保持原四行规格与独立gold，可在TB声明并从实际G/Wi descriptor给`g_cfg_K`供值，加入四态匹配断言及G接受边沿打印；若需把K改为硬件内传递则按代表top接口决策处理。AT065自然终态后再按受影响范围修，不重启/回写本次尝试。


[原始消息收据](../../.research-agent/communications/m005-implicit-gate-k-finding-20261014.json)

## 相关决定和审核


### 状态确认 2026-10-14T03:10:09.070965+00:00

项目主控与架构评判：已由D-M005-FEASIBILITY-01-A1集中答复并送达工程；AT065失败及原范围保留，修正与同top验证待执行。 → 已答复待实施

[top_interface_addendum_20261014.md](../../mission/M005_%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E4%B8%8E%E6%95%B4%E6%A8%A1%E6%80%A7%E8%83%BD%E5%8F%AF%E8%A1%8C%E6%80%A7%E8%AF%84%E4%BC%B0/top_interface_addendum_20261014.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
