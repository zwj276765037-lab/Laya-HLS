# 2026-10-09 离线验证阶段集中验收

审核：GPT-6 Astra / xhigh；实现与工具执行：GPT-6 Sol / xhigh。审核依据为[本轮阶段合同](../../mission/offline_validation_workflow.md)、[唯一阶段结果表](stage_results.md)及[机器状态](stage_results.json)。这是本轮唯一的最终验收文件；不另设模块放行或普通修复审核门。

**结论：部分验收通过，Type 完整冷启动请求存在成本阻塞，本轮范围尚未全部完成。** 接受 Head15/query63 四命令、Ws 当前 DCP 的 335872 B 有效逻辑容量，以及 Scorer FC1 有效不同三行的限定 RTL 结果。Type 两例已完成页准备、静态编译并实际运行诊断 trace，但均未完成完整请求验收；其完整测试状态为 `NOT_RUN_COST_LIMIT`，数值与终态为 `NOT_VERIFIED`。已执行的成本中止 trace 归为 `RESOURCE_STOP`，不能从该状态判断 DUT 数值 PASS 或 FAIL。

整个 Laya 离线工作仍未完成。Encoder→Decision→ACT/Scorer 全链数值 RTL、新完整 top 的同源资源和平台集成、布局布线/时序、U55C 上板与端到端 50 ms 均未闭合。C1 性能新架构保持暂停。本次未启动新编译、仿真或后继阶段。

## 1. Head15/query63：限定 PASS

接受 B1/S64、外部预置 head15/query63 的 BEGIN、重复 BEGIN 拒绝、RUN、replay 拒绝四命令。[最小诊断](attempts/head_probe_08/)执行了 4 阶段 × 7 端口，使用 14 组独立固定 119-bit record/32-bit count 字面值，并覆盖复位零值及指定 bit40 注入 X；审核者按固定字段位置独立解码，全部一致。

相对于冻结 monitor-v4，实际端口封装修复只把 accepted-R record 的连续转发改成上升沿后 1 ps 的被动观察采样。owning monitor、静态端点、有限控制、DUT 与 gold 不变；原 R ordinal/端口关联、协议、hold、debt 和数值断言保留。该修复解决本测试连接的观察问题，不据此宣布仿真器的一般根因。

[实际编译](attempts/head15_compile_01/) 190.6106 s、峰值 2471868 KiB；[实际运行](attempts/head15_runtime_01/) 111.7499 s、峰值 859472 KiB，均退出 0、无 guard 触发。四命令测试台计时分别为 26633、1017、500658、3778 clocks；这些是测试台命令口径，不是硬件纯计算延迟或板上频率。

审核者从原始输出重新比较 QK 64 字精确值、64 个概率的原容差，并用实际概率按原顺序 binary32 运算重算 AV 64 字，精确比较及原端到端容差均通过。四页 observed、261888 B 尾部 sentinel 和 262144 B 整块 replay 保留通过；选定 R/B hold 实际发生 19/17 clocks。对应[独立数值检查](attempts/head15_runtime_01/work/numeric_check.json)、[运行 seal](attempts/head15_runtime_01/work/runtime_seal.json)和原始日志一致。

此 PASS 不覆盖生产 QKV/Encoder 连接、其他 shape 或动态 pin reset；旧 head0/query0 验收继续按原身份保留。

## 2. Ws：当前实际 DCP 有效容量 PASS

输入为冻结 v6 的[八份 funcsim 与十一张父 DCP 图表](../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v6/runs/export_graph_v1/reports/)。[完整 join](attempts/ws_join_03/work/actual_join.json)闭合八 bank 与 17424 项属性记录：16656 项来自显式 funcsim override，768 项来自匹配模型的正式缺省声明；DCP 状态为 16560 项 OK、768 项原始 MISSING，另有 96 项仅属仿真语义而无 DCP 状态。

父层 n32 的实际来源是唯一 GND/G 活动驱动，16 个所选 pin、0 个外部驱动；八 bank 的 ce1/reset 按真实父网绑定为 0，没有给切片伪造内部 tieoff。96 个 RAMB36E2 的八个反相参数原始 DCP 空值/MISSING 保留，语义来源明确标为 `MATCHED_UNISIM_DECLARATION_DEFAULT`。绑定的 Vivado 2025.2 RAMB36E2.v 为 188935 B、SHA-256 `de300b57debd3f31771fa1d7a343f12200658cea6317e4da2a8c3d2f8e61519d`，第 195–202 行是无条件的一位 0 正式声明；导出工具、checkpoint 与八份导出 header 同为 build 6299465。这里接受的是实际 HDL 的有效参数，不把缺省值写成恢复出的 DCP 属性。精确尾部 glbl capsule 及原结构约束保留；[五组实际图正反例](attempts/ws_negative_02/)覆盖父常量、缺失/多驱动、错误边界、相反 literal/网别名、默认冲突与模型漂移。

[准备的实际 bank 网表](attempts/ws_capacity_prepare_03/prepared/)只作模块名隔离及已绑定 glbl capsule 处理。[编译身份](attempts/ws_capacity_compile_02/work/compile_identity.json)的 17 个所选文件均复核一致；编译 54.4337 s、峰值 548752 KiB、退出 0。

全容量验证使用逻辑位标签 `((bank * 20992 + address) * 16 + bit) + 1`，标签为 1…2686976，互不相同且均可用 22 位表示。[phase 00](attempts/ws_capacity_phase_00/) 至 [phase 21](attempts/ws_capacity_phase_21/)逐一写标签的对应一位；**每个 phase 都先写完全部八 bank 的全部 20992 地址，再读完全部地址**。因此，对这份实际原语网表的固定存储映射，任意两个 bank/address/bit 若别名，至少有一个 phase 的期望值不同，会在整轮写后读检查中暴露。验证同时覆盖高地址 16384–20991、地址 bit14、实际 CE/WE 控制、WE-low 保留及 0/16383/16384/20991 初始化探针；ce1/reset 固定值遵从父 DCP，未假装它们在该设计中可任意切换。

审核者逐一核对 22 份原始日志、phase 编号、完整计数、日志哈希及 guard，22/22 通过。[汇总](attempts/ws_capacity_aggregate_01/aggregate.json)为 2686976 逻辑位，即 **335872 B**；总读字 3694592，其中高地址读字 811008。每相位 37.6570–53.3661 s、峰值不超过 989232 KiB，无资源触发；最小 MemAvailable 为 424347756 KiB，高于 192 GiB。

接受当前 DCP funcsim 的实际全逻辑地址/位容量；该结论不覆盖所有可能的 RAM 故障模型、物理 P&R/时序、平台 shell 余量或完整模型适配。历史 join、编译与 pilot 失败完整保留。

## 3. Scorer FC1 有效不同三行：限定 PASS

范围为 K1024/N1024、B2/S128 的 batch1 rows0–2，mask=1、markers 147/163/174。同一冷进程实际完成 LOAD_W、trace ON RUN、复用权重的 trace OFF RUN。冻结 4f12 checkpoint 提供外部 ingress/gold，当前 DUT 为 fe067；这是该 FC1 矩阵的验证，未新执行 FC1→ACT→FC2 或 Encoder→Decision 整链。

复用已接受的[三行静态快照](../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/rtl_full_dimensions_distinct_rows3_v1/runs/static_build_v1/)及其 825 项输入绑定。审核者重新核对 61952000 B 快照 archive 的 SHA-256 `6dfeef7f0be5bc0f2e778b989c6d05de21f34ad266dbcd7df1c23a60e585fb27`，349 个 tar 条目中的 346 个文件与当前快照逐一一致。[运行页与实际原始日志/dump](attempts/scorer_prepare_01/pages/)包含 13 个 memh、341 页；原始运行输出位于该准备目录，不能仅按 runtime 目录名查找。

[受控运行](attempts/scorer_runtime_01/) 2954.9891 s、峰值 859200 KiB，退出 0、无 guard 触发。≤120 s 的实际进度 pilot 是这个完整进程中的现场观察，没有另一个独立归档的 pilot 运行包；原进度及 guard 时间线保留。

| 命令 | 测试台 command clocks | AP 接受至首次 done clocks |
| --- | ---: | ---: |
| LOAD_W | 1496052 | 1496042 |
| trace ON RUN | 5383748 | 5383738 |
| 复用 W、trace OFF RUN | 5375358 | 5375348 |

两种计时起点不同，每条相差 10 clocks，均不能当作板上毫秒实测。每个 RUN 实际 4096 issue/retire、3072 F32 输出、96 个量化组、3072 commits、3145728 MAC，trace 为 32/0；权重复用及原协议、hold、debt/sentinel 检查保留，不额外声称新 terminal-backpressure 覆盖。

[输出审计](attempts/scorer_audit_01/audit.json)通过。审核者又从三个命令的原始 observed/out0/out1 读取并独立核对共 602112 B payload，全部等于冻结 gold，三个输入行及输出行的身份分别不同。该结论不外推其他矩阵、shape、尾行、整核资源或 50 ms 性能。

## 4. Type：准备与编译 PASS；完整冷请求成本阻塞

[qtype2 页审核](attempts/type_qtype2_prepare_01/pages/audit.json)和[qtype1 页审核](attempts/type_qtype1_prepare_01/pages/audit.json)均为 `PASS_NO_EDA`，各实际材料化并独立核对 206 页；它们证明输入准备正确，不是 DUT 输出数值通过。两个修复后独立冷编译实际 PASS：qtype2 [compile_03](attempts/type_qtype2_compile_03/) 为 127.9653 s、1232624 KiB；qtype1 [compile_01](attempts/type_qtype1_compile_01/) 为 126.5198 s、1270236 KiB。

qtype2 [trace_04](attempts/type_qtype2_trace_04/) 在第 129 时钟接受真实请求，120.348 s pilot 成本停止，最后进度为 1310720 clocks、STATE0 AW=32602。后继 [trace_05](attempts/type_qtype2_trace_05/) 在 372.9698 s 停止，最后原始进度为 4456448 clocks、STATE0 AW=111734、STATE0 AR=0、STATE1 AW=0，仍在 ingress FSM14；guard 记录 `sigterm_requested`、child exit −9，峰值 859776 KiB，最小 MemAvailable 428345672 KiB。此为根据实际成本主动停止拥有的进程，不是完整请求终态。

qtype1 [trace_01](attempts/type_qtype1_trace_01/) 亦在第 129 时钟接受真实请求，120.3648 s pilot 到 1310720 clocks、STATE0 AW=32602、STATE0 AR=0、STATE1 AW=0；guard 为 `timeout`、child exit −9，峰值 859820 KiB，最小 MemAvailable 433220572 KiB。两例在共同 ingress 路径给出一致成本证据，因此没有再原样启动注定超出原预算的 qtype1 完整运行。

冻结 [Type 顶层源码](../attention_rtl_repair_20261008/d2_type_producer_binary_v1/source/type_producer_binary_slice.cpp)第 16–25 行为 64 行 ×4096 B 的 ingress；[full_write](../../hls/common/laya_full_memory.cpp)第 155–167 行逐字节写，生成 RTL 也以 4096 为内层退出值、以 64 为行数退出值。由此产生 262144 次写事务。实际约 40 clocks/AW、约 12000 clocks/s，单 ingress 约需 10.5M clocks、880–900 s，之后尚有 EMB_TYPE 和四个 ADD_TYPE，已超过每例 600 s 合同上限。`xelab -mt 4` 只改变编译并行度，没有可据此采用的 XSim runtime 多线程加速开关；本轮不以增额重试、强推 FSM、预装跳过 ingress 或拼接新进程片段替代完整验证。

早期 TB 复位/接受观察失败作为 `FAIL` 保留。尤其 [qtype2 trace_01](attempts/type_qtype2_trace_01/) 的 `ATT_R_RECORD_PORT_RESET port=6` 即使模拟器退出 0，仍是语义失败；端口观察后来采用本轮 Head15 已验证的修复，不能把旧 TB 故障的消除写成 Type DUT 数值通过。

两例均未完成 65536 F32 输出与独立 gold 比较、所选 TYPE_ROWS 结果及未用行 sentinel 最终比较、32 字 observed 状态/所有权、完整终态、所选末端 R/B hold 与首次 done debt 检查。10 个持久 metadata 标量只有冷初值，无 ordinary reset；不声明暖恢复。原两个冷 CPU 与 HLS 静态验收保留，CSim 为 NOT_RUN，HLS 5.158 ns 也不是物理时序通过。

## 5. 身份、资源与历史证据

审核采用本轮已有原始输出与只读轻量复核，没有再次运行 EDA。Head/Scorer/Ws 复核读取 1136 个唯一当前文件、225889002 B；Type 读取 425 个唯一文件、104860273 B，未发现非预期输入漂移。历史可变源码变化与每次尝试的 `mutable_source_snapshot.tar.gz` 对应；Ws 所选编译身份、Scorer archive/当前快照、两例 Type 当前 manifests 均一致。这些数字描述审核实际读取范围，不代表把所有历史文件重新计算一遍。

所核受控运行的 CPU 0–3、nice 19、idle I/O、0.2 s owned-RSS 采样和 `MemAvailable > 192 GiB` 策略一致；上述通过项退出正常且 RSS 在原上限内。Type 的停止原因明确为 pilot timeout 或成本判断后的身份终止，未出现内存门触发；未延长 600 s 完整例预算，也未处理无关任务进程。材料化的 guard 分别位于 `guard_materialize`/`guard_verify`。独立原始数值复算和身份检查由审核者在会话中执行，未另造模块审核包或不存在的 pilot 报告。

所有冻结版本、原始失败及历史验收继续有效；本文件只增加当前限定结果和未闭合项，不撤销旧失败记录。README 与 mission 当前表更新前的[精确前像](document_history/status_before_final_acceptance_20261009/manifest.json)保留；历史段落中的“待审/未运行”按当时状态理解，当前结论以上述范围及阶段结果表为准。

## 6. 后继建议及覆盖边界

以下仅为可另立合同的建议，均 **NOT_RUN**，本轮未启动：用实际生成的 `full_write` 验证一行 4096 B（约当前 ingress 的 1/64）；用真实 EMB_TYPE 核验一个 1024 F32 行及独立 qtype gold；用真实 ADD_TYPE 核验一个 16×1024 tile，先 pilot 再判断完整 tile 成本。每项都应保留真实 AXI 事务和独立参考。

这些方案最多增加模块/事务数值覆盖，不能关闭完整冷 Controller 的所有权、发布、端到端调用与末端响应链。若选择完整请求方案，应先有可解释的成本改进及相应阶段合同；不假设尚未证明的仿真 checkpoint/restart 能力，不以局部通过替代完整请求。三个已通过范围无需因 Type 阻塞原样重跑。

签署：**GPT-6 Astra / xhigh，2026-10-09。阶段结论：PARTIAL_ACCEPTANCE / TYPE_COST_BLOCKED；整个 Laya 离线验证未完成。**
