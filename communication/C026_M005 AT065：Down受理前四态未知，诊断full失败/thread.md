

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C026 · M005 AT065：Down受理前四态未知，诊断full失败

状态：**已答复待实施**。已由D-M005-FEASIBILITY-01-A1集中答复并送达工程；AT065失败及原范围保留，修正与同top验证待执行。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m005-at065-fail-semantic-down-admission-20261014

2026-10-14T03:03:44.216052+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# M005 AT065：Down受理前四态未知，诊断full失败

日期：2026-10-14；M005/SM006/E006/R001；attempt `AT065_M005_down_boundary_observe_01`。判定：**FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN**。这是M005新full的第1/3次，原运行及冻结文件保持不变；候选可综合top的normal/反压full、联合综合和布局布线均未运行。

## 实际终态与边界

本次冷full在2026-10-14 10:25:51 CST启动；guard 2080.617893s、child0/null、峰owned RSS 1036444KiB、最低MemAvailable 421831236KiB。`child0`仅表示xsim进程正常退出；`driver.log`有`Fatal`且runner `result_full.json`为`FAIL`，不能当PASS。实际M005预算累计新full 1/3次、2080.617893/10800s；短测48.884175s/600s，static111.926796s/5400s。三段policy共40条，所采样进程CPU0–3/nice19/idle匹配。

冻结TB在cycle358880打印Down W发布，实际W R为20992/20992/2624、scale_checks83968。新增被动边界在同一cycle依次见到posedge时钟、测试台WAIT、下一negedge、`cfg_valid=1`和#1采样：`cfg_ready=1`、`ledger_ready=1`、`ledger_admitted=1`、`candidate_ready=1`、`handoff_error=0`，但`static_ok=x`、`matrix_valid=x`。四态断言在3588801ns报`Fatal: FFN0 Down candidate/owner claim not admitted`，还未出现真实Down cfg接受、TMP写或末残差。FFN1后段计数`rcfg/rsrc/radd/rwr/rdone`均0，无`FFN0_CHAIN_PASS`。本次没有完整gold、655360B终扫或整链周期。

冻结`frozen_new/ffn0_chain_tb_v1.sv:1768`的`.gate_k(g_cfg_K)`是全文件中`g_cfg_K`唯一出现，无声明或驱动；同冻结handoff RTL的`static_ok`要求`gate_k_held==13'd2624`。这是实际X的明确静态来源候选，且AT064短测是另行受控合法K，不能代签联合链。AT065动态见到X，但尚未逐项打印全部`static_ok`操作数；修正后短测必须证明K真实来源及受理边沿，不能只以本静态核查预签唯一根因。AT063旧semantic-stall记录保持：它缺本次四态断言/边沿打印，故不能追写为已实测同一Fatal或DUT死锁。

## 身份、准入与下一步

只读重算AT065 `source_manifest.json` 342条文件引用，bytes/SHA均吻合；`package_manifest.json` 262个runtime文件在来源、pilot副本、full副本共三份均吻合，7个frozen文件、9个工具文件、80个运行库身份吻合。full前preflight记录262 runtime、7 ROM、63 fixture和实际11根，六项坏包拒绝保留；pilot真实首LN AR/64R在23.505724s通过。规划准入3318.039514s是旧前缀/局部尾段投影，不是本次整链性能。static/短测/负例按原各自范围，不扩大为本次完整链。

按M005原合同，先在E002工作源码中修未驱动K的声明/真实G descriptor接线与四态接受边沿检查，做受影响短测/static。候选代表top还需把LN→Q物理读债从TB移入硬件、把LN shell与其它九实例放在同一可综合边界，外部DDR/fixture仍留TB。剩余最多两次新full优先同一冻结top正常和确定合法反压；每次先真实≤120s前缀和新成本准入。仅在两次全链通过后进入同版联合综合与有界place/route；如预算不足，交付实测缺口，不换名追加。

原证据：`attempts/AT065_M005_down_boundary_observe_01/guard_full/driver.log`、`guard_full/guard_result.json`、`result_full.json`、`source_manifest.json`、`package_manifest.json`、`launch_full.json`、`preflight_full.json`。本报告是解释层，不修改旧AT063或AT065原证据。


[原始消息收据](../../.research-agent/communications/m005-at065-fail-semantic-down-admission-20261014.json)

## 相关决定和审核


### 状态确认 2026-10-14T03:10:12.373441+00:00

项目主控与架构评判：已由D-M005-FEASIBILITY-01-A1集中答复并送达工程；AT065失败及原范围保留，修正与同top验证待执行。 → 已答复待实施

[top_interface_addendum_20261014.md](../../mission/M005_%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E4%B8%8E%E6%95%B4%E6%A8%A1%E6%80%A7%E8%83%BD%E5%8F%AF%E8%A1%8C%E6%80%A7%E8%AF%84%E4%BC%B0/top_interface_addendum_20261014.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
