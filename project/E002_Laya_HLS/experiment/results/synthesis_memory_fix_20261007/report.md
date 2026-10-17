# Laya 完整顶层综合内存修复实测报告

2026-10-07 的最终候选 build tag 为 `04934c15b3f83e842ec2e92ac2a81bf2`。真实 25 源、13 口完整顶层 Vitis HLS 综合退出 0，完成全部 RTL 模型并生成顶层 Verilog、VHDL、综合报告和 Vivado IP。本次受保护运行的进程树 RSS 采样峰值为 **9,508,924 KiB（9.068 GiB）**，没有触发 32 GiB RSS 或 192 GiB 可用内存保护。原始失败运行的同口径进程树采样峰值为 **361.572 GiB**，其中 Clang 单进程为 **360.629 GiB**；本次观测值约低 97.49%，相当于原值的 1/39.87。两次运行的阶段、采样间隔不同，都是离散采样值，不能据此推断各自整个生命周期的绝对峰值。

**当前 RTL 不满足器件资源预算。** 完整顶层 HLS 报告估算 LUT 1,813,717 个，为目标 U55C 所列 1,303,680 个 LUT 的 139%；顶层表的 HLS 估算 slack 为 −0.07 ns。工具另给出 202.58 MHz 的估算 Fmax，这些估算字段不能代替物理实现后的时序或可布局结论。因此，“越过原内存热点”“完整 RTL 已生成”和“能够装入器件”是三个分别判断的结果：前两项已有实测证据，第三项仍未达标。

原工程为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`；本报告中的构建、模型包和完整综合来自隔离候选 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007`。最终结果依据 [完整综合结果](followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)、[原始日志](followon_r1/new_identity_r1/csynth_full/csynth.log)、[守护记录](followon_r1/new_identity_r1/csynth_full_guard/guard_result.json)及 [2,197 项工件清单](followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。

## 修复内容与保留的语义

原诊断定位到综合器把 `runtime` 中约 8.24 MiB 的全零数值 cache 与非零控制初值合成巨型常量，令编译器内存增长至数百 GiB。修复把 13 个精确类型、尺寸不变的数值数组在 `__SYNTHESIS__` 路径拆为独立全零静态对象，用固定访问器访问；普通 CPU 路径仍由每个 Runtime 私有保存这些数组。控制 metadata 的 INVALID、epoch、owner、请求身份、哨兵及错误初值没有改，回收和软复位继续按原规则更新 metadata，未增加整块数值 RAM 清零。声明的 13 数组逻辑容量合计 8,641,536 B，不含控制 metadata、局部缓冲和物理碎片。

owner 查找使用 0…31 的整数索引和 32 的未找到哨兵，保留按物理对象先查、再取首个空槽的顺序；QKV 双槽在写入前完成选择与拒绝检查，busy/readers 拒绝、epoch 高水位、覆盖状态和故障恢复顺序维持原合同。`weight_q` 与 `weight_scale` 保留数组元素类型，分别作 cyclic 8 和 4 的存储字 reshape；这只改变存储组织，不增加 F0 算术并行度。此前独立物理 OOC pilot 对这两组 RAM 得到 164+11=175 URAM；本次完整 HLS 的 44 URAM 是另一层估算，不能替代该 pilot，更不能证明完整设计可放置。

旧 f1a 完整顶层已越过内存热点，却在 `SYNCHK 200-42` 指针比较处停止，**当时没有完整 RTL**。随后只对五个获准的生产文件作窄修复：QK 任务把长度为 `S` 的原始 mask 字节逐字复制到自动局部数组，再用固定基址调用未改的 `qk_row`；包括大于 1 的非法字节在内，叶子函数的原有校验与拒绝规则不变。必填 index 的三个生产调用改走引用索引查找，旧可选指针 API 保留且失败时不写输出；Controller 的两处 owner 遍历改用固定 32 项整数索引，仍保留首匹配、busy 提前返回、失效和 epoch 规则。[源码差异](followon_r1/new_identity_r1/pre_export_source_delta.json)及 [真实完整 IR 复核](followon_r1/new_identity_r1/csynth_full/ir_capture/precheck_pointer_scan.json)记录 103 项身份输入仅五项变化、实际 precheck 有 0 条指针类型 `icmp`；九个算术文件、数值前像和模型权重不变。

旧 f1a 模型包已经原样归档，10 个文件改名前后哈希一致，见 [归档映射](followon_r1/new_identity_r1/f1a_archive_mapping.json)。新包仍使用同一冻结 GGUF，四个非 AUX BO 整文件不变，AUX 仅 128 B 身份头中的 build tag 字节变化，生成头仅 build tag 行变化；[新包身份记录](followon_r1/new_identity_r1/new_package_identity.json)与 [独立严格包检验](followon_r1/new_identity_r1/package_verify/full_model_package_report.json)确认 103 个当前源码输入无 stale、153 个 tensor、152 个保留 payload、122 个 Q8 矩阵和 124 个 weight key。13 个外部端口、数值/布局 tag、§12.2 的 4,953 B 数值前像、数组元素类型与全部有效范围均未更改。

## 实际验证结果

| 阶段 | 新 tag 实测结果 | 证据 |
| --- | --- | --- |
| 完整 CPU | 27/27 CTest；75 项数值正例及 1 项既有预期拒绝；三组前向共 141 个检查点逐位通过；同一 Runtime 的四个请求含一次预期故障和恢复。新旧 f1a 的 141 个 oracle 与 141 个 DUT F32 文件分别逐项 SHA 一致。 | [功能链汇总](followon_r1/new_identity_r1/functional_chain_summary.json)、[CPU 门禁](followon_r1/new_identity_r1/cpu_full/full_final_gate_report.json) |
| 真实 `__SYNTHESIS__` shadow | 25 个生产源、13 口真实顶层；同进程四次调用中三次成功、一次预期故障，72 个有效 F32 值与独立 oracle 一致。首次误用旧 f1a 请求被身份校验拒绝，失败日志保留；新请求只重绑定 16 B build tag 后通过，旧请求未覆盖。 | [通过报告](followon_r1/new_identity_r1/shadow_r2/shadow_report.json)、[请求重绑定](followon_r1/new_identity_r1/rebound_requests/rebind_report.json)、[首次失败](followon_r1/new_identity_r1/shadow/shadow_report.json) |
| 真实 Vitis CSim | 13 口完整顶层、47 个检查点、9,047,192 个 F32 值、37,158 个任务；工具报告 0 错误。 | [CSim 日志](followon_r1/new_identity_r1/csim_full/csim.log) |
| 完整 Vitis HLS csynth | 25 源输入哈希 65 项当前核对通过；实际 `SYNCHK` 为 0 错误、1 条 QoR 警告；综合退出 0，完整顶层 Verilog/VHDL、610 份报告及 IP 导出。进程树峰值 9.068 GiB，最低 `MemAvailable` 431,424,316 KiB，守护未触发。 | [完整结果](followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)、[顶层报告](followon_r1/new_identity_r1/csynth_full/artifacts/reports/csynth.rpt) |

完整综合的资源均为 **HLS 估算**：BRAM_18K 570（14%）、DSP 485（5%）、FF 477,288（18%）、LUT 1,813,717（139%）、URAM 44（4%）。顶层 latency 在报告中未定义，不能从局部循环行拼出整图性能。LUT 估算已经超过器件总量，当前实现不能宣称 U55C 适配或 150 MHz 时序达成；后续资源优化需要另立设计与验证合同。

[独立资源复核](../../../Laya-baseline/results/synthesis_memory_fix_20261007/full_resource_review_04934.json)把完整报告按互斥层级计数：`graph` 层约 1,742,745 LUT，四个并列 linear 实例合计 618,806 LUT；同类 `load_weight`、`issueLinear`、`issueQuant` 路径在多处实例化，`graph` 自身的 mux 类估算为 64,914 LUT。父子层级不能相加为额外用量。下一步应先量化重复实例、调用生命周期及共享约束，再在独立资源设计合同下评估结构变更与分级验证，不能凭本次报告直接改共享调度。顶层接口除 13 个 `m_axi` bundle 外，还实际生成 `s_axi_control` 与 `s_axi_control_r` 两组 AXI-Lite 控制接口；平台链接尚未验证。

真实 RTL 与报告的封存目录为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts`：[顶层 Verilog](followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward.v)、[顶层 VHDL](followon_r1/new_identity_r1/csynth_full/artifacts/rtl_vhdl/laya_typed_q8_forward.vhd)、[顶层综合报告](followon_r1/new_identity_r1/csynth_full/artifacts/reports/csynth.rpt)、[Vivado IP 包](followon_r1/new_identity_r1/csynth_full/artifacts/ip/xilinx_com_hls_laya_typed_q8_forward_1_0.zip)。Verilog 输出目录的 893 个文件包括 679 个 `.v`、201 个 `.dat`、13 个 `.tcl`；VHDL 输出目录的 692 个文件包括 679 个 `.vhd`、13 个 `.tcl`。工件已与生成目录逐文件核对。

完整顶层 **RTL cosim 未执行**；完整设计的物理综合、布局布线、后布局时序、平台编译/链接、xclbin、上板和性能测量均未执行。已有的 focused pilot RTL 与 RAM OOC pilot 只证明各自范围，不替代这些阶段。本报告也不把 HLS 估算资源或频率写成物理实测。
