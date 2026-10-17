# 完整顶层 Vivado OOC 工程：平台与验证结果

**2026-10-08后续接口/性能核查新增功能缺口：生成QK/AV任务的合法context路径固定返回E_SHAPE、elements=0。** 因此本页OOC成功、资源与综合时序只描述当前制品；完整生成RTL成功推理不能成立，修复后资源/时序可能变化。[15模块输入输出、真实端口与条件算力预算](performance_and_interfaces.md)和[异常范围](performance_and_interfaces.md#rtl-anomaly)以最新核查为准。Q8完整成功图预算B1约29.31–32.59分钟、B2约58.62–65.17分钟@150MHz，仅为组体分量，非现有RTL请求实测。

记录日期：2026-10-08（Asia/Shanghai）。**完整顶层 Vivado OOC 综合已完成，退出 0，blackboxes=0，DCP 与资源/时序报告已生成。** 当前映射为 345,505 CLB LUT、287,466 FF、437 DSP、690 BRAM tiles（1,380 个 18K 等效）及 179 URAM；上述裸器件总量均未超容量。6.667 ns 请求下综合 WNS 为 +0.894 ns、TNS 为 0；这不是布局布线或平台时序通过。实际执行、守护与适用边界见 §6，创建历史保留于 §4–§5。工程为 [laya_ooc.xpr](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/vivado/laya_ooc.xpr)。

合同与权威来源见 [design.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/source/design.md)。设计/审核角色为 GPT-6 Astra `xhigh`，实现角色为 GPT-6 Sol `max`。

## 1. 固定配置与阶段状态

| 项目 | 配置/状态 | 类型与边界 |
| --- | --- | --- |
| 工件身份 | `04934c15b3f83e842ec2e92ac2a81bf2` | 复用正式 baseline 的既有完整 HLS RTL |
| 顶层 | `laya_typed_q8_forward` | C++完整28 Encoder＋2 Decision＋scorer/act合同；生成RTL成功路径有新增QK/AV缺口 |
| 器件 | `xcu55c-fsvh2892-2L-e` | OOC 器件目标 |
| Vivado | 2025.2，SW Build 6299465，IP Build 6300035 | 实际运行版本保存在本次 [metadata.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/metadata.json) |
| 可执行文件 | `/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado` | 不依赖不存在的安装根 `settings64.sh` |
| 时钟 | `ap_clk`，6.667 ns，约 150 MHz | 约束请求；实际 Fmax 未测 |
| RTL/初始化/IP 定义 | 679 HLS Verilog、201 DAT、13 原 IP Tcl | HLS 只采用 Verilog；浮点 IP 自动生成的 VHDL wrapper/库通过 Mixed 语言正常纳入 |
| 外部数据口 | 13 个 master，原默认数据 32 bit/地址 64 bit；两组 AXI-Lite | 当前生成事实；原文候选 512-bit 不应用于本工程 |
| platform/shell/XRT | 本轮未链接、未核验部署组合 | 裸 OOC 无平台互连和 shell 资源计入 |
| 保护默认 | 4 threads、IP 串行；create/verify 每个 Vivado 阶段 16 GiB/30 分钟、综合 64 GiB/4 小时、可用内存保留 128 GiB | 工程保护参数，可配置；不是测量结果 |

| 验证阶段 | 当前状态 | 证据与限制 |
| --- | --- | --- |
| 正式归档输入核验 | 通过：2,197/2,197 大小/SHA-256 匹配；893 staged 输入一致 | metadata、输入 hash 及独立审核；manifest 的旧 repair 路径按正式归档相对路径解析 |
| DAT 静态扫描及实际 PRE | 通过：201 个引用齐全；真实 `synth_1` PRE 复制/核验 201 个 DAT | 真实 run 日志有成功标记及初始化读取记录，初始化错误门禁通过，见 §6 |
| DAT helper 独立试运行 | 通过：独立工作目录复制并逐字节核验 201 项，退出 0 | 创建阶段独立 helper 结果；实际综合运行另记 §6 |
| 创建/保存 `.xpr` | 通过：第三次 create 退出 0 | 原两次配置失败独立保留，见 §4 |
| 新会话重开及 compile-order/IP 检查 | 通过：创建阶段 verify/增强 verify 与综合前复核均退出 0 | top/part/XDC、13 IP/真实实现、DAT、PRE hook；compile order 共 698 项 |
| 13 IP output products generation | 通过：13 Synthesis＋13 Simulation targets | floating_point 7.1 rev21；生成 HDL/XCI 不代表 IP 已综合 |
| 独立 `synth_ip` | 未单独执行 | 13 IP 的真实 HDL 已由完整顶层综合统一纳入，无 IP 黑盒替代 |
| 完整顶层 OOC `synth_design` | 完成，退出 0；`synth_design Complete!`，blackboxes=0 | 实际 run、资源/时序/DCP 与守护见 §6；裸 OOC 范围 |
| 完整顶层 RTL cosim/XSim | 未执行 | 未新增完整顶层 testbench 或仿真结果 |
| 布局布线、布线后时序 | 未执行 | 无 WNS/TNS/hold/布线 Fmax 实测 |
| 平台链接/xclbin/上板/性能 | 未执行 | 工程创建不证明 U55C 可部署 |

## 2. 既有 HLS 估算与当前完整顶层映射

HLS 列来自 `04934` 的既有 [完整 HLS 报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/csynth.rpt)，Vivado 列来自本次真实 [utilization.rpt](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization.rpt)，状态为 `Synthesized`。本轮未修改计算源码或重跑 HLS。容量为报告所列整颗器件总量，未扣除 platform/shell 预留；未执行布局布线。

| 资源与单位 | 既有 HLS 估算 | 完整顶层 Vivado 映射 | 整颗器件容量 | 当前占比 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT 总量 | 1,813,717 | 345,505 | 1,303,680 | 26.50% |
| FF / CLB Registers | 477,288 | 287,466 | 2,607,360 | 11.03% |
| DSP / DSP48E2 | 485 | 437 | 9,024 | 4.84% |
| BRAM，18K 等效 | 570 | 1,380 | 4,032 | 34.23% |
| BRAM，36K tile | — | 690 | 2,016 | 34.23% |
| URAM / URAM288 | 44 | 179 | 960 | 18.65% |

345,505 CLB LUT 由 **339,874 LUT as Logic＋5,631 LUT as Memory** 构成；后者为 2,087 distributed RAM＋3,544 shift register LUT。`utilization.rpt` 的 LUT 总数已考虑 LUT combining，不能直接把 primitive LUT1…LUT6 行相加作为另一种器件占用。BRAM 实际为 **530 RAMB36E2＋320 RAMB18E2**，因此 `530+320/2=690 tiles`，或 `530×2+320=1,380 个 18K 等效`；两行是同一资源的单位转换，不能相加。

历史 HLS LUT 估算为 `1,813,717 / 1,303,680=139.12%`；真实 Vivado 映射为 26.50%，LUT 数比该估算低 80.95%。FF 从 477,288 变为 287,466，DSP 从 485 变为 437；BRAM 18K 等效从 570 增至 1,380，URAM 从 44 增至 179。这是不同工具阶段对同一冻结 RTL 的估算与映射差异，不是本轮另行做了算法或架构优化，也不能推出整个设计已自动共享全部算子。当前已无这些裸器件资源总量超限证据；平台预留、放置、拥塞和布线后的适配仍未验证。

完整 [层次资源报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt) 的根节点与总表一致。父节点包含后代，分析时只比较同级子树或排他行，不能重复求和。历史孤立 weight RAM OOC 的 175 URAM、HLS 44 URAM 和本次完整顶层 179 URAM 分属不同范围/阶段，不合并为新的完整设计总量。

实际计算子树仍存在：报告 [linear_15 行](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt:685) 为 44,790 LUT/35,647 FF/38 DSP，[fp_linear 行](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt:569) 为 10,642 LUT/10,608 FF/13 DSP；这些是包含后代的子树计数。真实浮点 [fmul IP](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt:486) 使用 3 DSP，[fadd IP](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt:613) 使用 2 DSP。它们证明这些数值电路已实际映射，不等于完整数值功能验证，也不足以解释全部 HLS→Vivado 差异。

HLS estimated slack −0.07 ns 与 estimated Fmax 202.58 MHz 保留各自历史报告含义；当前综合 timing 另见 §6.3。完整顶层 latency 在 HLS 表中未定义，本工程仍没有测得整图周期、首填/排空、吞吐、实际外存带宽或板上性能。

## 3. 既有功能结果的适用范围

同一 build tag 已有 27/27 CPU CTest、三组完整 CPU 前向共 141 个检查点/18,094,384 个 F32 值，以及真实 13 口 HLS CSim 的 47 个检查点/9,047,192 个 F32 值。详见 [最终修复报告的“实际验证结果”](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/report.md:19)。这些为既有软件/CSim 证据，不是本次项目创建期间重新执行，更不能替代完整顶层 RTL 仿真、reset/背压测试或映射综合。

## 4. 创建阶段实际运行历史

### 4.1 两次配置失败及实际修正

| run | 实际结果 | 修正与保留证据 |
| --- | --- | --- |
| `20261008T021957Z-2958131` | create 8.29 秒，退出 1；13 IP 尚未开始 | [日志](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T021957Z-2958131/logs/create.vivado.log:50)：`Data Files` 类型不允许用户改写。删除强制 `Memory Initialization Files` 设置，保留原 `.dat` 类型。 |
| `20261008T022033Z-2958706` | create 8.29 秒，退出 1；13 IP 尚未开始 | [日志](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022033Z-2958706/logs/create.vivado.log:50)：run 不支持 `STEPS.SYNTH_DESIGN.ARGS.MODE`。工具 probe 后采用 `{STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS}=-mode out_of_context`，保留 `FLATTEN_HIERARCHY=none` 与 `TCL.PRE`。 |

### 4.2 成功创建、补强和新会话验证

成功 run 为 `20261008T022231Z-2961016`，开始记录 `2026-10-08T02:22:31.989440Z`（本地 10:22:31）。完整命令、工具版本和各阶段退出码见 [metadata.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/metadata.json)。下列 RSS 为本任务进程树的离散采样峰值，不是整个生命周期的绝对峰值。

| 阶段 | 退出码 / 用时 | 进程树采样 RSS 峰值 | 最低主机 MemAvailable / 守护 |
| --- | --- | ---: | --- |
| 原 create＋13 IP output products | 0 / 22.88 秒 | 1,763,315,712 B（1.6422 GiB） | 未记录最低值；`guard_reason=null` |
| 原 fresh verify | 0 / 18.70 秒 | 1,737,551,872 B（1.6182 GiB） | 未记录最低值；`guard_reason=null` |
| `utils_1`/PRE hook 补强 | 0 / 8.95 秒 | 1,169,612,800 B（1.0893 GiB） | 457,758,883,840 B（426.3212 GiB）；未触发 |
| 增强 fresh verify | 0 / 17.58 秒 | 1,720,463,360 B（1.6023 GiB） | 457,198,788,608 B（425.7996 GiB）；未触发 |

原 create/verify 使用较早的守护记录格式，未保存 root PID、单阶段起止 UTC 或最低 MemAvailable；不能将后测值填入原阶段。增强 verify 实际限制为 4 threads、RSS 16 GiB、1800 秒、MemAvailable 下限 128 GiB；root PID `2967057`、start ticks `853912288`，执行时间 `02:29:23.229549Z` 至 `02:29:40.812423Z`。启动时主机记录 96 CPU、可用内存 458,209,124,352 B。

原创建日志保留 [13 IP generation 与创建完成](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/create.vivado.log:71)，原 [fresh verify](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/verify.vivado.log:117) 输出 `verilog=679 dat=201 ip=13 compile=698`。增强 [verify 日志](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/verify_20261008T022923Z_2966922.vivado.log:150) 采用新的独立编号，同样输出上述成功标记，没有覆盖原日志。

实际 [compile order](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/verify_20261008T022922Z_2966922/compile_order.rpt) 为 **679 个 HLS Verilog＋13 个浮点 IP synthesis VHDL wrapper＋6 个共享 VHDL 库＝698 项**，全部编译输入位于当前 run；没有导入另一套 679 个 HLS VHDL，也没有仅以 stub 代替浮点 IP 实现。[IP status](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/verify_20261008T022922Z_2966922/ip_status.rpt) 的 13 项均为 floating_point 7.1 rev21、`Up-to-date`、`Included`。增强 verify 同时确认各 IP 未锁定、`GENERATE_SYNTH_CHECKPOINT=false`，且 synth/sim VHDL 产品存在；这些检查不执行 IP synthesis。

创建时原 RTL 静态扫描声明 828 个 module，只有预期的 13 个浮点 IP 类型需要外部生成；上述真实 IP 产品已进入 Vivado synthesis compile order。该扫描和 compile-order 检查不是完整 HDL elaboration 或功能证明。201 个 `$readmemh` 名称均能解析到原 staged DAT；当时尚未进行实际综合加载，之后的真实结果见 §6。

首次成功创建时工具提示 PRE hook 未作为 `utils_1` 文件管理。随后按 [amendment_utils_hook.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/amendment_utils_hook.json) 在原工程登记 hook 并保留前后 XPR/hook SHA-256；补强进程退出 0，未重建 13 IP。当前 `prepare_dat.tcl` 在未来综合工作目录复制 201 DAT 后检查大小与逐字节内容，已绑定 `synth_1` PRE 且列入 `utils_1`。本轮另外直接试运行了此 helper，见 §4.4；没有由真实综合 run 触发 PRE 阶段。

日志仍有其他板卡定义不可用/空 BoardPart 提示及 `report_compile_order -fileset` 的弃用提示；目标 part 检查通过，本轮不选择板级 board/platform。它们不作为 U55C 平台部署已验证的证据。

### 4.3 输入与产物身份记录

| 证据 | 实际内容与适用边界 |
| --- | --- |
| [input_hashes.sha256](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/input_hashes.sha256) | 原创建时 901 项记录：manifest、原 IP ZIP、893 个 RTL/DAT/Tcl 输入及当时运行配置/脚本；保留原样，后续脚本修正不回写旧快照 |
| [增强 verify 输入快照](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/verify_20261008T022922Z_2966922.inputs.sha256) | 902 项，独立记录增强检查所用输入/配置/脚本 |
| [generated_ip_hashes.sha256](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/generated_ip_hashes.sha256) | 130 项 XCI 和生成 HDL 产品 SHA-256；IP 产品身份，不是映射网表证据 |
| 正式归档与 staged 输入 | 2,197 项正式归档及 893 staged 文件大小/SHA 匹配；固定顶层 SHA 为 `64fbd56f27dedee31d99d71b5039164f780dd27d76126d78f6f5dbafd963364b` |
| OOC/XDC | top=`laya_typed_q8_forward`、part=`xcu55c-fsvh2892-2L-e`、6.667 ns XDC 和 `-mode out_of_context` 由新进程重开检查；未推导板级引脚或 IO delay |

### 4.4 辅助脚本的独立试运行

[prepare_dat_probe.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/prepare_dat_probe.json) 记录 `2026-10-08T02:34:21.960437Z` 的 DAT helper 独立试运行：工作目录为本 run 的 `dat_hook_probe`，退出 0，复制并核验 201 项；[日志](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/prepare_dat_probe.log) 输出 `LAYA_DAT_STAGED count=201 verified=201`。helper SHA-256 为 `bbcb27ae2463cdb767c00d81e057f9a0e1c063df8260c42a1fe4b862483762bb`，与补强记录一致。临时复制物随后清理，保留日志与收据；独立审核没有复算已删除的临时副本，原 201 个 staged DAT 和 hook 本身仍可核查。此试运行验证复制/比对逻辑，不是 Vivado synthesis、RTL 仿真或真实综合 PRE 阶段。

[guard probe result.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/_guard_probe_20261008T023251Z/result.json) 使用本任务的轻量 mock tool 和独立 session 子进程检验超时清理；时限特设为 1 秒，2.89 秒结束，root PID `2970626` 退出 `-15`，`guard_reason="task exceeded 1 seconds"`。记录的子 PID `2970742` 在清理后不再运行。此负例验证任务所属进程的超时清理，不运行 Vivado 或完整顶层，也不将预期 `-15` 写成工程创建失败。RSS/最低可用内存正常路径来自 §4.2 的真实工具阶段；此 probe 不宣称穷尽所有中断和资源极限条件。

## 5. 创建阶段独立审核与当时的执行边界

独立审核由 GPT-6 Astra `xhigh` 的 `vivado_project_review_astra_xhigh` 执行，[review.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/review.json) 结论为 `ACCEPT_PROJECT_CREATION_AND_REOPEN_VERIFICATION; FULL_TOP_SYNTHESIS_AND_PHYSICAL_IMPLEMENTATION_NOT_EXECUTED`，无阻断项。本轮工程创建、配置/依赖、新进程重开、辅助脚本证据和未来入口静态检查可验收；此结论不包括完整综合或物理实现。

独立核查确认 2,197 个正式归档及 893 staged 文件大小/SHA 一致、顶层固定 SHA 匹配；13 个 XCI 合计 429 项 `CONFIG.*` 与原 IP Tcl 配置一致；13 synthesis＋13 simulation targets 已生成，13 个真实 synthesis wrapper 全部进入 698 项 compile order。审核同时保留原创建守护元数据不完整、GUI 未实开、helper 临时副本已清理及本轮未执行硬件阶段的证据边界。

上述创建审核时，`--synth`、DAT PRE hook 的真实综合运行、完整顶层 RTL 仿真、完整映射资源、布局布线、平台链接、xclbin、上板与吞吐/时序均未执行。该审核 JSON 的文档哈希对应当时快照，后续授权及结果更新不回写旧审核。工程创建通过只表示配置一致、依赖已纳入并可由新会话重开；实际资源、6.667 ns 是否满足及平台适配由对应阶段报告判定。

## 6. 完整顶层 OOC 综合实测（2026-10-08）

### 6.1 完成状态、实际配置与运行保护

**完成，退出 0，`LAYA_SYNTH_DONE status=synth_design Complete! blackboxes=0`。** 本次沿用同一工程 run 的独立 synth phase，未覆盖创建历史。真实 [runme.log](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/vivado/laya_ooc.runs/synth_1/runme.log:19) 执行 `synth_design -top laya_typed_q8_forward -part xcu55c-fsvh2892-2L-e -flatten_hierarchy none -mode out_of_context`；本次实际综合了完整 RTL 与浮点 IP HDL，没有把 IP output generation 当作顶层综合。

执行入口为 `scripts/run.py --synth --run-id 20261008T022231Z-2961016`。完整命令及保护记录保存在 [metadata.json 的 synth phase](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/metadata.json)，日志为 [synth.console.log](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/synth.console.log) 和 [synth.vivado.log](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/synth.vivado.log)。

| 项目 | 实测或实际设置 |
| --- | --- |
| synth phase 时间 | `2026-10-08T02:50:46.162139Z` → `04:35:14.516246Z`；本地 10:50:46 → 12:35:14 |
| 整个 synth phase 耗时 | 6,268.35 秒，约 104.47 分钟；包含 launch/wait、重开综合结果、资源/时序报告和最终 DCP 输出 |
| 进程身份 | runner PID 2986844；工具 root PID 2988104，start ticks 854040582 |
| 实际保护 | 4 线程、任务树 RSS 64 GiB、14,400 秒、主机 MemAvailable 保留 128 GiB |
| 任务进程树 RSS 采样峰值 | 41,758,941,184 B＝38.8910 GiB |
| 主机最低 MemAvailable | 411,732,381,696 B＝383.4557 GiB |
| 启动主机快照 | 96 CPU；MemAvailable 454,326,325,248 B |
| 退出/保护状态 | 退出 0；`guard_reason=null`，保护未触发 |

`runme.log` 单独记录 `synth_design` elapsed 01:38:41；它不含外层报告和最终 DCP 阶段，因此与 104.47 分钟的完整 phase 口径不同。38.8910 GiB 是离散采样的任务树 RSS，可能含共享页重复计数；不能与工具单进程 Memory、PSS 或生命周期绝对峰值混用。旧 HLS 修复运行的 9.068 GiB 属于另一个工具流程，本次完整 Vivado 映射并不是该 HLS 内存实验的复跑，也不是 FPGA 片内存储占用。

### 6.2 输入、DAT、blackbox 与 DCP

本阶段 [输入 SHA 快照](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/logs/synth_20261008T025045Z_2986844.inputs.sha256) 独立保留当次脚本/输入；原创建审核和输入快照未覆盖。真实 `synth_1` [PRE 日志](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/vivado/laya_ooc.runs/synth_1/runme.log:18) 输出 `LAYA_DAT_STAGED count=201 verified=201`，cwd 为实际综合 run 目录；后续可见至少 69 个不同 DAT 的 `$readmem` 读取成功记录。日志明确 [Synth 8-3876 消息达到 100 次后被抑制](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/vivado/laya_ooc.runs/synth_1/runme.log:833)，因此 69 不是完整读取总数，也不能由此认定其余文件都被优化掉。201 个实际 cwd 文件已逐项核对一致，初始化故障门禁通过。综合后查询 blackbox 数为 0，资源报告 Black Boxes 表为空。

报告目录为 [synth_20261008T025045Z_2986844](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844)：包含 [总资源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization.rpt)、[层次资源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt)、[综合时序](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/timing_summary.rpt) 与 [laya_ooc_synth.dcp](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/laya_ooc_synth.dcp)。DCP 为 136,924,450 B，SHA-256 为 `17249e553af7df93c62d4793ae3b6b38308b66cbd398cd1ba21b18769cdaf9af`。

### 6.3 综合时序与实际适用边界

`timing_summary.rpt` 状态为 `Synthesized`；时钟 `ap_clk` 周期 6.667 ns，显示频率 149.993 MHz。

| 时序字段 | 本次综合结果 |
| --- | ---: |
| WNS / TNS | +0.894 ns / 0.000 ns |
| setup 失败端点 / 总端点 | 0 / 610,601 |
| WHS / THS | +0.046 ns / 0.000 ns |
| hold 失败端点 / 总端点 | 0 / 610,601 |
| WPWS / TPWS | +2.633 ns / 0.000 ns |
| pulse-width 失败端点 / 总端点 | 0 / 294,358 |
| 内部未约束端点 / 无时钟寄存器引脚 | 0 / 0 |
| 无 input delay / 无 output delay 的端口 | 550 / 1,781 |

报告原句为 `All user specified timing constraints are met`，其含义限于当前裸 OOC 已给出的约束。未指定 550 个输入和 1,781 个输出的外部时序；日志另提示 `ap_clk` 缺少 `HD.CLK_SRC`，OOC 无法估计真实 clock delay/skew。此阶段使用综合网表，没有实际布局布线与平台时钟网络，因此不把 +0.894 ns 换算为已验证 Fmax，也不宣称 U55C 平台 150 MHz 已达成。

真实综合 run 结束汇总为 94 Warnings、0 Critical Warnings、0 Errors；外层 timing 另含上述 clock-source 提示。不能只引用中间阶段的“0 warnings”而省略最终日志口径。

### 6.4 当前结论与独立审核

独立 Astra `xhigh` 审核接受本轮完整顶层 OOC 综合交付，审核范围为实际 DAT PRE 准备/检查、blackboxes=0、DCP 及总资源/层次资源/综合时序报告，记录见 [synthesis_review.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)，旧创建 `review.json` 保留。当前真实证据支持“完整顶层 OOC 映射完成、无 blackbox、所列主要资源总量未超裸器件容量、当前综合约束内 setup/hold 检查通过”。平台预留、布线后资源/拥塞、完整外部接口时序和板上频率尚未验收。

本阶段只运行裸完整顶层 OOC 综合；完整 RTL cosim、布局布线、布线后时序、platform/shell 链接、xclbin、上板和性能测量仍未执行。
