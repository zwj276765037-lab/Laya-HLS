# Type 成本恢复后的集中最终验收

2026-10-09。审核：GPT-6 Astra / xhigh；实现与工具执行：GPT-6 Sol / xhigh。依据[同阶段合同的 Type 成本恢复补充](../../mission/offline_validation_workflow.md)和[唯一阶段结果表](stage_results.md)，本次集中核对受影响的 Type 交付，不重新执行或审核未变的 Head15、Ws、Scorer。

**验收结论：Type qtype2、qtype1 两个完整冷请求均 PASS；本轮规定的四项离线功能范围全部完成。整个 Laya 离线工程仍未完成。** 先前三项 PASS 复用[原集中验收](final_acceptance.md)；其中当时 Type 成本阻塞的结论、旧失败和旧预算保持历史原状，由本次实际终态增加后继结论。无 Encoder→Decision 整模型、完整 FC1→ACT→FC2、完整新 top 资源/平台集成、P&R/Fmax、上板或端到端 50 ms 验收；C1 仍暂停，本次未启动访存架构整改。

## 实际运行与完整数值

| 用例 | 正式冷进程及编译来源 | 墙钟 / 峰值 owned RSS | 最后 TYPE_ROWS R 的实际地址 |
| --- | --- | --- | --- |
| qtype2 | [full_03](attempts/type_qtype2_full_03/)，[compile_07](attempts/type_qtype2_compile_07/) | 2105.396994 s / 859684 KiB | `0x0000000501022ffc` |
| qtype1 | [full_01](attempts/type_qtype1_full_01/)，[compile_02](attempts/type_qtype1_compile_02/) | 2181.429559 s / 859676 KiB | `0x0000000501021ffc` |

两个正式运行各在全新进程中执行相应冷请求，完整经过 64 行 ingress、真实 Controller 的 1 次 EMB_TYPE 和 4 次 ADD_TYPE。各自 guard 退出 0、无触发，原始日志无 ERROR/FATAL，实际到达 `TYPE_COLD_STATIC_TB_DONE`。qtype1 使用自己独立编译、独立请求和 gold；复用选择器数字并未替代其实际事务/地址检查。

[qtype2 数值审计](attempts/type_qtype2_full_audit_01/work/numeric_audit.json)及[qtype1 数值审计](attempts/type_qtype1_full_audit_01/work/numeric_audit.json)均由原冻结独立 checker 完成。审核者又独立读取两例原始七份 dump，分别精确比较 **843776 B / 206 映射页、65536 个 F32 输出字**：真实 hidden 输入、embedding 尾页、完整映射 IO/AUX、STATE0 ingress、所选 TYPE_ROWS 行及两行未用 sentinel、STATE1 全输出、32 个 observed 状态/身份/owner 字及页尾 sentinel 全部一致。覆盖五个任务退休、三次 owner claim、输出 READY 且 64 行完整覆盖、TYPE_ROWS 与旧 HIDDEN 释放；未把 CPU 结果或 trace dump 代作正式 RTL 输出。

qtype2 输出 SHA-256 为 `ccfafda7e9909f8528220dbe14c60b436666474d90baff6ec41542ec4f5ee9dc`，qtype1 为 `a08859b3a516d026ed3e85a2cc0c8d9399b047416dba15fa568b6a0c8627c903`，分别等于原独立 gold。所选 STATE0 slot 为 66/65，Type 行和输出确实不同；未改 gold 或容差。此验证覆盖全部建模物理页，不声称转储了未映射 BO gaps；禁访区仍由真实端口断言限制。

## 原协议、末端停顿及首次 done

审核者从两份原始日志独立解码 119-bit accepted-R record：valid=1、ordinal=131072、RLAST=1，地址分别为上表值；实际 R hold 均为 **18 clocks**。STATE1 最后 B ordinal=262144、最后 AW=`0x000000060003fffc`，hold **17 clocks**；observed 最后 B ordinal=6、最后 AW=`0x0000000700000064`、len=6，hold **16 clocks**。末写 span 分别到 STATE1+262144 和 observed+128，初始 observed 写未误当成末响应。

首次 done 的真实总计均为 STATE0 AR/R=131072、STATE1 AW/B=262144、observed AW/B=6，R hold=1、B hold=2。本地 R 观察计数与独立 monitor 计数相同；双侧物理端口无未决读写，各 adapter accepted/delivered 相等，原协议、数据稳定、访问区间和终态身份断言保留并完成检查。

两例锁存的 `start_cycle=129`、`first_done_cycle=24003570`，故 **AP 接受至首次 done 为 24003441 clocks**。原日志 `TYPE_COLD_FIRST_DONE cycle=24003571` 在 `#1ps` 后读取已经自增的 clocks；它是延后显示值，不是另一个首次 done 周期。该仿真计数含静态端点等待，不作为板上毫秒、Fmax 或 50 ms 结论。

## 普通 TB 修复与失败保留

最终修复限于未冻结测试环境：用[本地被动 AR/R FIFO 观察器](tb/type/type_r_hold_selector.sv)记录真实端点握手，替代直接跨层读取 monitor 的 unpacked queue；在稳定时相形成地址/ordinal 选择，原地址＋ordinal＋RLAST 的定向 hold 含义不变。独立 monitor 继续负责协议检查，正式末端另用其 accepted-R record 核对目标地址、ordinal 与 RLAST。`terminal_checked` 只在原 `#1ps` debt/身份检查及打印完成后置位，结束路径等待该标志，消除提前结束竞态。共享 stall 文件只扩展 fatal 信息中的原信号打印，检查条件和行为未改；DUT、端点、FP 算术、gold 与已通过三项的验证语义不变。

[真实端口短边界用例](attempts/type_r_hold_boundary_11/work/xsim.log)实际 PASS：AR=3、R=3、一次最后 R hold=18，独立 accepted record 为 ordinal=3、地址 BASE+4092、RLAST=1；该用例只支持观察器修复，不替代上述完整冷请求。

所有旧尝试保留：[trace_06](attempts/type_qtype2_trace_06/)只提供诊断 dump/成本与已存在的末 B 事件；其缺失末 R/终态打印及首次 done debt 未被补写为 PASS。[full_01](attempts/type_qtype2_full_01/) 的末 R hold 控制未知、[full_02](attempts/type_qtype2_full_02/) 的首个 STATE0 AR 地址观察未知，以及 boundary_01–10 的失败均维持真实 FAIL。先前 120 s pilot/成本停止也继续保留，不能与后继正式结果合并改写成通过。

## 身份与资源核对

两次编译各 371 项输入绑定、两次正式运行各 19 项绑定、边界诊断 13 项及两次数值审计各 8 项均已重新核对哈希；mutable source snapshot 的 archive 哈希一致。相对于原 compile_03，358 项冻结外部编译输入保持相同。审核还核对实际 build/launch 日志、运行 `xsim.dir` 链接及 DAT 绑定，两例分别指向自己的新编译快照；当前每个快照 331 个文件可读。本轮合计读取并哈希 1075 个唯一文件、118791838 B。编译 manifest 绑定的是源码闭包，运行 manifest 引用对应编译 manifest；没有另一个运行前后二进制 snapshot seal，不将当前制品核对表述成不存在的历史 seal。

qtype2/qtype1 编译分别为 131.377590/132.653742 s、峰值 1275752/1238496 KiB，均正常退出。正式运行的最小 MemAvailable 分别为 443831084/443884092 KiB；CPU 0–3、nice 19、idle I/O、0.2 s owned-RSS 采样及严格高于 192 GiB 的门槛均符合合同。正式运行低于已授权的 7200 s、80M clocks、8 GiB 上限；没有改大额度后继续超帽，也没有新运行 EDA 来做本次验收。

本次实际 STATE0 读取已按每个 F32 一次 32-bit 返回，共 131072 次 AR/R；STATE1 仍为每个 F32 四次 AW/B，共 262144。不能仅因 C++ 内有字节循环，就把读口也写成每个 F32 四次 AXI 事务；这些计数仅为已验配置的事实，不构成后继访存优化或性能验收。

Type 的 10 个持久 metadata 标量仍只有 cold 初值、没有 ordinary reset；本次通过不覆盖暖复位、在途恢复、其他 shape 或整模型。README/mission 当前入口已更新；更新前的[文档精确前像](document_history/status_before_type_resumption_acceptance_20261009/manifest.json)和原集中验收完整保留。

签署：**GPT-6 Astra / xhigh。TYPE_TWO_COLD_PASS；本轮限定阶段范围完成，完整离线工程未完成。**
