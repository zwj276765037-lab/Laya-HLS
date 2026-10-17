# Laya 完整顶层 Vivado OOC 工程

**2026-10-08后续接口/性能核查新增功能缺口：生成QK/AV任务的合法context路径固定返回E_SHAPE、elements=0。** 因此本页OOC成功、资源与综合时序只描述当前制品；完整生成RTL成功推理不能成立，修复后资源/时序可能变化。[15模块输入输出、真实端口与条件算力预算](source/performance_and_interfaces.md)和[异常范围](source/performance_and_interfaces.md#rtl-anomaly)以最新核查为准。Q8完整成功图预算B1约29.31–32.59分钟、B2约58.62–65.17分钟@150MHz，仅为组体分量，非现有RTL请求实测。

本工程从固定 build tag `04934c15b3f83e842ec2e92ac2a81bf2` 的[完整 HLS 归档](../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/)创建，不修改 HLS C++ 或自动生成的 RTL。顶层为 `laya_typed_q8_forward`，器件为 `xcu55c-fsvh2892-2L-e`；[OOC XDC](constraints/top_ooc.xdc)仅约束 `ap_clk` 为 6.667 ns。本工程没有平台 `.xpfm`、封装连接或布局布线设置。

已交付工程：[laya_ooc.xpr](build/20261008T022231Z-2961016/vivado/laya_ooc.xpr)。**完整顶层 Vivado 2025.2 OOC 综合已完成，退出 0、blackboxes=0，DCP 与资源/时序报告已生成。** 映射资源为 345,505 CLB LUT（26.50%）、287,466 FF（11.03%）、437 DSP（4.84%）、690 BRAM tiles（34.23%）与 179 URAM（18.65%），主要资源未超裸器件总量。LUT 为 339,874 logic＋5,631 memory；BRAM 为 530 RAMB36＋320 RAMB18，等效 1,380 个 18K。HLS 的 LUT 139.1% 仅为先前估算。

6.667 ns 请求下综合 WNS +0.894 ns/TNS 0、WHS +0.046 ns；550 输入与 1,781 输出没有外部 delay，且实际 clock source/skew 未定义。**完整 RTL 协同仿真、布局布线、平台链接、上板和性能仍未执行；不能据此宣布板上 150 MHz 达成。** 详细结果见 [source/results.md](source/results.md) 和 [独立综合审核](build/20261008T022231Z-2961016/synthesis_review.json)。

创建和复核阶段确认正式归档 2,197 项哈希匹配；staging 为 679 HLS Verilog、201 DAT 和 13 原 IP Tcl；13 个 Floating-point 7.1 IP 已串行生成 synthesis/simulation 产品。实际 [synthesis compile order](build/20261008T022231Z-2961016/reports/compile_order.rpt)为 679 份 HLS Verilog＋13 个 IP synthesis VHDL wrapper＋6 个共享 VHDL 库，共 698 项；`Missing instances` 为 `< empty >`。HLS 的另一套同名 VHDL 未重复导入，simulation 产品未执行编译或仿真。

在 `Laya-baseline` 根目录执行：

```sh
python3 vivado/project/scripts/run.py --check
python3 vivado/project/scripts/run.py --create
python3 vivado/project/scripts/run.py --check --run-id 20261008T022231Z-2961016
```

`--check` 不带 run id 时验证冻结归档、模块静态依赖和 Vivado；带 run id 时重新打开该 `.xpr`，核对 top、part、OOC 设置、XDC、201 DAT、13 IP 的 XCI 与 synthesis/simulation 输出、IP 实现文件的编译顺序和生成物哈希。`--create` 在 `build/<run_id>/` 下独立暂存并复核原始文件，再创建工程与逐个生成 IP，随后在新 Vivado 进程执行相同工程检查。原 HLS IP zip 中另有一份 Verilog/VHDL，本工程只将 loose Verilog 加入文件集，避免重复模块。`--help` 显示全部资源参数；默认最多 4 个 Vivado 线程，创建/验证进程树 RSS 16 GiB、单次 30 分钟，完整综合进程树 RSS 64 GiB、4 小时，主机 `MemAvailable` 保留至少 128 GiB。守护仅清理本次命令捕获的进程树。

本次完整顶层资源报告由以下显式 OOC 综合入口取得；该命令会执行综合，已有结果可直接从下方报告读取：

```sh
python3 vivado/project/scripts/run.py --synth --run-id 20261008T022231Z-2961016
```

该入口先重验归档、暂存内容和 IP 输出，再运行 `synth_1`。`prepare_dat.tcl` 作为 PRE hook，已在实际综合工作目录复制并逐字节核对 201 DAT；[真实 run 日志](build/20261008T022231Z-2961016/vivado/laya_ooc.runs/synth_1/runme.log)记录 `LAYA_DAT_STAGED count=201 verified=201`，初始化错误门禁与 blackbox 检查通过。完整 synth phase 用时 6,268.35 秒（104.47 分钟），任务树 RSS 采样峰值 38.8910 GiB、最低主机 MemAvailable 383.4557 GiB，保护未触发。

本次完整报告位于 [synth_20261008T025045Z_2986844](build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/)：

- [总资源](build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization.rpt)与[层次资源](build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt)。父节点包含后代，不能相加重复统计。
- [综合时序](build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/timing_summary.rpt)，仅对应裸 OOC 综合态。
- [综合网表 DCP](build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/laya_ooc_synth.dcp)，SHA-256 `17249e553af7df93c62d4793ae3b6b38308b66cbd398cd1ba21b18769cdaf9af`。
- [综合控制日志](build/20261008T022231Z-2961016/logs/synth.console.log)、[阶段输入快照](build/20261008T022231Z-2961016/logs/synth_20261008T025045Z_2986844.inputs.sha256)及 [metadata](build/20261008T022231Z-2961016/metadata.json) 中的 `synth` 阶段，保留真实配置、起止、退出码和守护记录。

创建历史证据保留在同一[运行目录](build/20261008T022231Z-2961016/)：`input_hashes.sha256` 是首次创建快照；`generated_ip_hashes.sha256` 固定 IP 产品；`logs/create.console.log`、`logs/verify.console.log` 和首次 compile-order/IP-status 报告没有覆盖。增强复核另有独立日志、输入哈希及真实根 PID/最低 MemAvailable；首次创建未采集的字段没有追填。`amendment_utils_hook.json` 保留 `utils_1`/DAT 核验补强，[DAT helper 独立试运行](build/20261008T022231Z-2961016/reports/prepare_dat_probe.json)仍按创建阶段证据解释；本次真实综合 PRE 另见上文 run 日志。原两次配置失败与[创建审核](build/20261008T022231Z-2961016/review.json)保持历史记录，新增综合审核单独保存。
