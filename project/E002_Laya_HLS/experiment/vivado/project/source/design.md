# 完整顶层 Vivado OOC 工程：创建与综合合同

**2026-10-08后续接口/性能核查新增功能缺口：生成QK/AV任务的合法context路径固定返回E_SHAPE、elements=0。** 因此本页OOC成功、资源与综合时序只描述当前制品；完整生成RTL成功推理不能成立，修复后资源/时序可能变化。[15模块输入输出、真实端口与条件算力预算](performance_and_interfaces.md)和[异常范围](performance_and_interfaces.md#rtl-anomaly)以最新核查为准。Q8完整成功图预算B1约29.31–32.59分钟、B2约58.62–65.17分钟@150MHz，仅为组体分量，非现有RTL请求实测。

合同日期：2026-10-08（Asia/Shanghai）。设计责任：GPT-6 Astra，`xhigh`；工程实现：GPT-6 Sol，`max`。本目录是现有完整顶层 RTL 的独立集成工程，权威硬件输入仍为正式 baseline 中已封存的 HLS 工件。`build/` 中的文件是逐项哈希校验、可再生的 staging，不是第二套维护实现。

## 1. 本轮目标与授权边界

工程创建阶段已完成并独立验收。用户现已明确授权开始完整 Vivado OOC 综合，执行已审查的 `scripts/run.py --synth --run-id 20261008T022231Z-2961016`；直接沿用既有 top、part、6.667 ns 时钟请求、13 个真实浮点 IP、201 DAT 与 PRE hook，不修改硬件架构或设计预算。

本轮授权由 Sol max 通过已审核入口启动 `synth_1`，实际综合完整顶层与所纳入的 IP，实现 OOC 映射、保存 DCP、资源和综合时序报告并核查意外 blackbox/未解析模块/初始化数据。保护固定为 4 线程、任务进程树 RSS 64 GiB、4 小时时限、主机 MemAvailable 保留 128 GiB。尚无完成结果时只能记录执行状态，不声明映射成功、器件适配或时序通过。

完整顶层 RTL cosim、布局布线、平台链接或上板仍不在本轮执行范围。不得重跑 HLS，修改原 C++/RTL、既有模型包或 103 项身份输入；本工程的配置、约束、脚本和证据全部留在 `vivado/project`。下文创建阶段的已验收事实保留其历史范围，当前完整综合要求见 §9。

## 2. 权威来源与适用性

原规格为统一规格 v1.0（2026-10-05）；下列位置于 2026-10-08 实际读取。原规格中的候选平台、访存宽度和历史未实现状态，应结合现行 `04934` 工件解释，不能覆盖当前已生成接口。

| 来源 | 已读取章节/位置 | 本工程采用的内容 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19) | §1 工具路线、§2 一个完整前向核、§3 13 个访存端口、§5 环境、§6 验证、§8 时钟复位 | 完整 forward 顶层、接口一致性、分阶段证据；OOC 工程不能代替 xclbin/XRT 部署 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113) | §8 共同的握手、背压、错误和复位规则 | 保留生成接口的 AXI 握手和排空语义；本工程不新造 stream、复位或 CDC 适配 |
| [top/source/design.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/top/source/design.md:166) | P2 C 批、P2 实际实现映射、综合内存修复现行代码映射 | 完整 28 Encoder＋2 Decision＋scorer/act 的既有实现；13 个 master 和两组 AXI-Lite 控制 |
| [report.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/report.md:1) | 修复内容与保留的语义、实际验证结果 | `04934` 完整 HLS 结果及物理阶段未执行边界；报告中的旧 repair 路径是历史生成位置 |
| [post_promotion_review_04934.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/post_promotion_review_04934.json) | `independent_postpromotion_checks`、`final_paths` | 正式 baseline 已接受的源/模型/工件身份与当前归档位置 |
| [artifact_manifest.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json) | `build_tag`、`counts`、`files` | 2,197 项归档输入的大小和 SHA-256 校验依据 |
| [laya_typed_q8_forward.v](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward.v:9) | HLS 生成信息、端口及参数（约 640 行起）、复位逻辑（约 3926/4438 行） | 实际 top、part、6.667 ns 请求、接口宽度、时钟与复位事实 |

## 3. 固定输入合同

| 项目 | 固定值或处理规则 | 状态 |
| --- | --- | --- |
| build tag | `04934c15b3f83e842ec2e92ac2a81bf2` | 工程事实；本轮不改变 |
| 顶层 | `laya_typed_q8_forward` | 明确复用现有完整顶层 |
| 器件 | `xcu55c-fsvh2892-2L-e` | 当前 HLS 工件及本工程合同 |
| 工具 | Vivado 2025.2；实际 build/version 写入结果 | 与生成工件一致的工程选择 |
| 时钟 | `ap_clk`，`create_clock -period 6.667`，约 150 MHz | 约束请求；不是已达成频率 |
| HLS RTL 语言 | 仅导入原 HLS Verilog 679 项 | 不同时导入同名 HLS VHDL；允许浮点 IP 自动生成的 VHDL 依赖 |
| 初始化数据 | 201 个原 `.dat`，保留全部 basename 与内容 | 原 RTL 通过相对 `$readmemh("./…dat")` 读取 |
| IP 定义 | 13 个原 `_ip.tcl`，逐个原样执行 | 参数、名称、精度、latency、DSP 模式及握手不改 |
| 顶层 RTL SHA-256 | `64fbd56f27dedee31d99d71b5039164f780dd27d76126d78f6f5dbafd963364b` | 固定身份校验 |
| 原 IP ZIP SHA-256 | `2bcc33c6fd2895361d73b810b3db422a3761d8f0f7a7a9d19c124a6441e5c4dc` | 归档核验及来源交叉检查 |

正式工件根为 [csynth_full/artifacts](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts)。清单中的 `source`/`capture` 旧绝对路径只保留溯源意义。运行器必须以经过校验的工件相对路径解析到此正式根，拒绝重复项、路径越界、缺失文件、大小/SHA 不符；不能依赖 repair 工程存在。

创建前核查全部 2,197 项归档；staging 选取 `rtl_verilog` 下 893 项（679 `.v`、201 `.dat`、13 `.tcl`）。逐项记录归档相对路径、实际正式源路径、大小、SHA-256、staged 路径及 staged SHA-256。先确认一一对应再加入工程；每次运行使用独立目录，不覆盖旧成功或失败运行。

## 4. 硬件结构、接口与数值保留

本工程的结构为：原顶层及 678 个原 Verilog 依赖＋201 个初始化数据文件＋13 个原 Tcl 生成的浮点 IP＋一份 OOC 时钟约束。运行器仅建立工程关系，不添加顶层包装逻辑，不改变层循环、缓存所有权、F0 调度、数值路径或 reset 行为。

| 接口 | 方向/实际形式 | 本工程处理 |
| --- | --- | --- |
| `ap_clk` | 输入、单个生成计算时钟端口 | 添加 6.667 ns 主时钟约束 |
| `ap_rst_n` | 输入、低有效；顶层反相为 `ap_rst_n_inv`，可见顶层时序过程在 `ap_clk` 上升沿检查 | 保留原连接及全部子模块实现；不据此声称平台 reset/CDC 已验证 |
| `m_axi_embedding/io/w_q0/w_q1/w_scale/aux/state0/state1/qkv0/qkv1/ff0/ff1/att_out` | 13 个 AXI master；原参数默认地址 64 bit、数据 32 bit | 参数不覆盖；保留 AW/W/B/AR/R 的所有信号及握手 |
| `s_axi_control` | AXI-Lite slave，原数据宽度 32 bit、地址宽度 4 bit | 原样导入 |
| `s_axi_control_r` | AXI-Lite slave，原数据宽度 32 bit、地址宽度 8 bit | 原样导入 |
| `interrupt` | 输出 | 原样导入 |

原规格曾提出 512-bit master；当前 `04934` 顶层实际生成的是 32-bit 默认数据宽度。本轮创建工程以字节不变的实际 RTL 为准，不做总线拓宽。原规格中的 2023.2/platform 参考组合也不作为本次 2025.2 OOC 的已验证部署环境。

Q8/F32/F64、量化/舍入/溢出、归约顺序、模型维度、请求字节布局、13 BO 顺序与缓存生命周期全部继承归档硬件及既有设计，不形成新的数值合同。浮点 IP 的名字和 latency 以 Tcl 的实际 `CONFIG.*` 值为准，不能仅凭文件名数字推导。完整功能、背压和复位恢复的 RTL 验证不在本轮范围。

## 5. 浮点 IP 与 DAT 处理

选择原始 RTL＋原始 IP Tcl 路线，不从头手填等价浮点参数。13 个脚本在目标 `.xpr` 中串行执行；Vivado 2025.2 对应 `floating_point` 7.1，保留脚本的 `generate_synth_checkpoint false`，生成 `{synthesis simulation}` output products。生成 HDL/XCI 或 simulation 产品不等于执行 `synth_ip`，也不等于综合完整顶层。

记录每个 IP 的名称、VLNV、XCI、配置摘要、生成状态、输出产品文件及 SHA-256；保存 `report_ip_status`、synthesis compile order 和来源文件列表，并检查 simulation 产品存在。本轮不编译或仿真 simulation 产品。依赖检查要排除同时引入封装 stub 与实际定义造成的重复模块，确认每个原 IP wrapper 的模块引用都有对应生成定义。浮点 IP 可以生成 VHDL synthesis wrapper 与共享 VHDL 库，因此工程采用 Mixed 语言依赖；这不等于重复导入 HLS 的另一套 679 个同名 VHDL。共享 IP 库由 Vivado 编译管理，不将库公共模块重复作为本地硬件加入。

201 个 DAT 必须保持原 basename，并作为数据文件加入工程。Vivado 2025.2 将 `.dat` 识别为 `Data Files`；不强制改成该扩展名不支持的 `Memory Initialization Files`。扫描所有原 `$readmemh` 引用，确认每项可解析到 staging 的同名文件。实现采用 `synth_1` 的 Tcl PRE hook，在实际综合工作目录复制并校验全部 201 个 DAT。创建阶段的独立 helper 试运行已通过；本次真实综合 run 也已触发 PRE hook，日志记录 `count=201 verified=201` 和实际 `synth_1` cwd，后续初始化错误门禁通过。受控 `--synth` 入口和真实日志才证明这一阶段执行，GUI 打开本身不提供该证据。

## 6. 工程目录与入口责任

```text
vivado/project/
  source/design.md       当前合同、原规格引用和实现映射
  source/results.md      分阶段状态和真实证据
  constraints/           OOC 时钟 XDC
  scripts/               输入核验、受保护运行、创建/重开及显式 --synth 入口
  build/<run_id>/         独立 staged 输入、.xpr、生成 IP、日志与核查证据
```

实现入口映射如下；文件交付及实际运行结果仍须按 §8 审核：

| 文件 | 责任 |
| --- | --- |
| [scripts/run.py](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/scripts/run.py) | `--check` 预检、`--create` 创建、显式 `--synth --run-id` 运行既有工程；资源保护和证据汇总 |
| [scripts/create_project.tcl](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/scripts/create_project.tcl) | 建工程、导入源/DAT/XDC、串行生成 13 IP、设置未来 OOC run |
| [scripts/verify_project.tcl](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/scripts/verify_project.tcl) | 独立 Vivado 进程重开及轻量检查 |
| [scripts/synth_ooc.tcl](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/scripts/synth_ooc.tcl) | 当前已授权完整顶层 OOC 综合及报告/blackbox 验收 |
| [scripts/prepare_dat.tcl](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/scripts/prepare_dat.tcl) | 综合 PRE hook 的模板；每次 run 固定 staged DAT 路径，本次真实 run 已执行 |
| [constraints/top_ooc.xdc](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/constraints/top_ooc.xdc) | 6.667 ns 的 `ap_clk` 请求 |
| [README.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/README.md) | 用户操作入口、工程路径和阶段边界 |

本目录是已有 top 模块的工程配置入口，不是新计算模块，因此复用既有 [top/rtl/README.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/top/rtl/README.md) 和 [top/tb/README.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/top/tb/README.md) 的模块工作区及真实实现/验证入口，不另建 `project/rtl` 或 `project/tb`。原自动生成 RTL 仍保留在正式归档与运行 staging；本工程不复制维护新的 C++、顶层 RTL 或软件参考。生成工程不得有指向 repair 目录的有效依赖；Vivado 工具安装位置与本次 build 内路径可以是实际绝对路径。

已创建的工程为 [build/20261008T022231Z-2961016/vivado/laya_ooc.xpr](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/build/20261008T022231Z-2961016/vivado/laya_ooc.xpr)。新进程批处理重开、配置/依赖核查已退出 0；实际 synthesis compile order 为 679 个 HLS Verilog＋13 个浮点 IP synthesis VHDL wrapper＋6 个共享 VHDL 库，共 698 项。创建阶段未启动图形桌面验收或综合；当前综合进展及原始日志分列于 [results.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/source/results.md)。

XDC 只描述 OOC `ap_clk` 请求。不虚构 U55C 引脚、HBM/PCIe shell、I/O delay、generated clocks、CDC false paths 或平台可用资源。未来 OOC 使用 `-mode out_of_context`，不因裸顶层外部引脚数量错误地加入板级 I/O buffer/placement 约束。Vivado 2025.2 的实际项目 run 配置采用 `set_property -dict [list {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context}] [get_runs synth_1]`，同时保持 `FLATTEN_HIERARCHY=none` 和 DAT `TCL.PRE`；不使用工具不支持的 `STEPS.SYNTH_DESIGN.ARGS.MODE`。该设置需在正式工程的新进程重开检查中再次确认。

## 7. 资源保护与运行记录

默认 `general.maxThreads=4`，IP 创建/生成串行；如果使用优先级调整，只对本任务子进程生效。create/verify 每个 Vivado 工具阶段默认进程树 RSS 上限 16 GiB、时限 30 分钟；未来显式综合默认 RSS 上限 64 GiB、时限 4 小时；主机 `MemAvailable` 下限默认 128 GiB。它们是避免影响其他项目的可配置保护值，不是实测资源需求、性能目标或完成保证。

启动前记录真实工具路径/版本、主机内存、参数、时间及 task-owned root PID；运行期间按进程树身份采样 RSS 和主机可用内存，超时或越界先停止再仅终止本任务所属进程树。不得通过广义进程名匹配终止其他 Vivado，不改全局环境，不安装工具或许可证。守护触发即本次未通过，应保留日志及退出码，不能自动无界提升限制重跑。

证据包含完整命令/参数、Vivado 日志与 journal、工具/主机快照、输入/staging/IP 产品哈希、运行开始/结束、退出码、采样峰值和最低可用内存。离散采样峰值必须标明口径，不作为绝对生命周期峰值。

## 8. 创建阶段验收与完整综合验收分离

已完成的创建阶段验收要求：

1. 正式归档 2,197 项核验通过，staging 893 项及顶层固定 hash 一致，没有 repair 有效路径依赖。
2. `.xpr` 已生成且可由新的 Vivado 会话 `open_project` 重开；GUI 可打开所需项目文件齐全。若未实开图形界面，只报告批处理重开验证，不能写“GUI 已人工验收”。
3. 重开后 top、part、Verilog 文件集、201 DAT、13 IP、6.667 ns XDC 与合同一致，全部 IP output products 可用；保存 compile order 和 IP status。
4. 静态模块/DAT 依赖核查通过；未执行完整 elaboration 的限制明确记录。创建不能靠忽略 Tcl/Vivado ERROR、缺失依赖或错误退出码伪造通过。
5. 默认入口仅创建，显式 `--synth` 独立可审查；创建阶段日志无 `synth_design`、`synth_ip` 或综合 run 启动证据。资源守护未触发，原硬件身份未变。

未来用户显式运行完整顶层 OOC 综合时：需要实际综合原完整顶层和 13 个 IP 实现，保持初始化数据可见，保存 DCP、层次 `report_utilization`、`report_timing_summary`、完整日志与输入身份。综合后检查意外 blackbox、未解析模块和缺失初始化数据；任何一项出现都不能当作完整资源结果。不得用仅含 stub 的 0 资源 IP、孤立 RAM pilot 或 HLS 估算填充完整映射值。

未来 OOC 综合报告仍不等于布局布线、平台链接或板上时序/吞吐；约 150 MHz 是时钟请求，裸 OOC 缺少平台外部时序条件，综合 timing 必须附此适用边界。资源/频率和各阶段实际状态统一维护在 [results.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/source/results.md)。

## 9. 当前已授权完整顶层 OOC 综合

本阶段直接执行 §8 既定完整综合验收，不增加新架构设计。沿用 `04934c15b3f83e842ec2e92ac2a81bf2`、`laya_typed_q8_forward`、`xcu55c-fsvh2892-2L-e`、`ap_clk=6.667 ns` 和现有 698 项 synthesis compile order。由真实 `synth_1` PRE hook 在运行工作目录复制/核验 201 DAT，13 个 IP 以真实 HDL 纳入顶层综合，不能用 stub 或旧孤立 pilot 代替。

结束后依据工具原始 run 状态、退出码、日志、DAT 标记、blackbox 检查、完整资源/层次资源、timing summary、DCP 及守护记录收口。若综合报错或保护触发，应保留本次真实结果，按证据判断是否需要合同内修复；不自行修改数值、时钟、器件或架构以制造通过。OOC 综合资源及综合估计时序仍不含平台 shell 和布局布线，不能推出 U55C 部署或板上 150 MHz 达成。

本次已执行完成，退出 0、blackboxes=0，201 DAT PRE 标记/门禁通过，DCP、总资源、层次资源和 timing summary 已交付。当前映射主要资源均低于裸器件总量；6.667 ns 的综合约束内 WNS +0.894 ns/TNS 0，但缺少外部 I/O delay 与实际 clock source/skew，仍无 P&R/平台/上板结论。实际资源、104.47 分钟完整 phase、38.8910 GiB 任务树 RSS 采样峰值及审核范围见 [results.md §6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/source/results.md)。这些为当前映射结果，不改变原数值/接口合同或设计预算。
