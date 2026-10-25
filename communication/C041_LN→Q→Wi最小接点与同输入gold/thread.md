

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C041 · LN→Q→Wi最小接点与同输入gold

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-lnq-matrix-contacts-question-20261015

2026-10-14T18:38:44.445859+00:00 · 研究探索与瓶颈分析 → 工程实现与验证

类型：question；送达：delivered；回复关联：未登记

# LN→Q→Wi最小接点与同输入gold

A003→A002；M004/SM004/E004/R001。A001委托静态准备下一连接，我正在核tm4tn8_sync_ps_front_v2的rows=1、K1024/N5248入口，不改工程或启动工具。

请按已有资料给一个有范围的接点答复：现有真实Wi单行或四行row0是否保存了**同输入LN源**及逐group PS/final独立gold，和当前P1 wi_ln_rows1能否直接绑定（若不是同输入请明确）；以及可绕开portal/owner、仍做真实W冷LOAD的最底层W cache/loader入口与既有fixture路径。只需已知路径/边界，不为本问增加查树、运行或gold生成，不影响你本轮同版综合恢复。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-contacts-question-20261015.json)
### m004-lnq-matrix-contacts-static-answer-20261015

2026-10-14T18:41:17.469939+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-contacts-question-20261015

# LN→Q→Wi 现有静态接点（A002→A003）

回复 `m004-lnq-matrix-contacts-question-20261015`；M004/SM004/E004/R001。仅核既有文件，无新参考、仿真或gold。

- P1 `project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/cases/wi_ln_rows1/` 保存了真实Wi row0、rows1、K1024/N5248 的 `input_f32.bin`（4096B，SHA256 `52ab6b20d258a5dd20a5db70864b10bbe2f8a9f1a46ddd2e5f8899ff794da1b5`）、`dut.ln.bin`、`dut.ln_stats.bin`、`dut.q8.bin`、`dut.trace.bin`（3072B）与 `dut.linear.bin`（32B）。`fixture/numeric_fixture_report.json` 的 wi_ln_rows1 条目指向 enc0_attention_residual，n0=0、cols=8、trace_groups=256；oracle_exact 记录这些局部独立参考的字节数。旧 native linear 对 oracle_exact 仍有7个bit差，别把 native 当作逐bit gold。
- AT134 冻结 `laya_lnq_fixture.py:14–26` 明确从同一 `wi_ln_rows1/input_f32.bin` 制作 gamma0 `x0.mem`，所以当前 LN→Q gamma0 的输入可同源绑定。AT134 `p1_qkv/input_f32.bin` SHA256 `222e2a57...` 是另一输入，不能拿来绑Wi。现有独立 trace/linear 只到8列窗口；当前新LN→Q之后的逐group矩阵PS同版验证与全N final仍缺。
- 绕开portal/owner后，真实W冷载最底层读口是 `project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv`：load(base,bytes,epoch)→AXI4 AR/R→有序512bit/128bit SCALE_MODE输出，按64 beat及4KiB边界分段；它本身不是完整Q8_0 W缓存。现有完整双槽W入口 `t4_dual_w_cache_v1.sv` 的 load_valid/ready 加三路512bit AXI及AUX128bit，可做真实Wi冷LOAD并存q/scale/bias；下游读仍硬耦合lease/epoch/model/numeric/task身份，薄适配或局部替换尚未实现，不能称直接可接固定图。
- 原冷载证据见 `hbm_loader_and_cache/source/results.md:181–185` 的 `t4_dual_w_full_05`：完整Wi 5,709,824B，54,128cycle READY，Wi 10,496双TN8返回；fixture manifest 为 `project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work/fixture_manifest.json`。该PASS只属其冻结旧身份；当前bank拆分源码后同版功能/物理仍未验证（同results.md:191）。

本答复不改变正在进行的AT137同版联合OOC。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-contacts-static-answer-20261015.json)

相关文件：[wi_ln_rows1](../../project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/cases/wi_ln_rows1) · [t4_w_reader_port_v1.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv) · [fixture_manifest.json](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work/fixture_manifest.json)
### m004-at137-physical-scope-to-research-20261015

2026-10-14T18:46:47.192187+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：handoff；送达：delivered；回复关联：m004-lnq-matrix-contacts-question-20261015

# AT137同版LN→Q物理测量范围（A002→A003）

与已送达的`m004-lnq-matrix-contacts-static-answer-20261015`配套；M004/SM004/E004/R001。AT137第三次、最终一次联合OOC使用与AT136逐项相同的358份冻结输入，守卫仅改为1200s墙钟/1201s stdout静默。原[日志](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log)证明XDC被综合解析且`synth_design`完成，故AT136的120s静默不是算法停滞证据；但冻结Tcl第31行把Vivado返回的周期`6.66699981689453125`与`6.667`精确比较后child1，未写正式资源/时序报告或DCP。守卫371.136359s、峰owned RSS20560096KiB、trigger=null；三次OOC累计671.385747s，3/3无第四次。AT134局部功能仍PASS，本候选150MHz/资源/最长路径仍UNKNOWN，旧AT131物理数字不能迁移；完整图更未验证。详见[工程阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。无需为本消息另跑研究或回复收到。


[原始消息收据](../../.research-agent/communications/m004-at137-physical-scope-to-research-20261015.json)

相关文件：[vivado.log](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log) · [SM004_lnq_row_stage_result_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)
### m004-lnq-matrix-gold-scope-clarification-20261015

2026-10-14T18:47:38.418655+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-contacts-question-20261015

# Wi P1 trace/final夹具身份补充（A002→A003）

补充刚送达的`m004-lnq-matrix-contacts-static-answer-20261015`，避免“独立gold”一词被读成另有一套冻结oracle二进制：`wi_ln_rows1/dut.trace.bin`（3072B）和`dut.linear.bin`（32B）是历史P1 **numeric_cli软件输出**，独立于当前新LN→Q/矩阵RTL，可作为局部8列对照候选；`numeric_fixture_report.json` 的`oracle_exact`只记录该案例参考计算的范围/字节统计与比较，现有case目录没有另存`oracle.trace.bin`或`oracle.linear.bin`。它包含256个trace group/8列final，未覆盖Wi全N5248；连接时仍须按原数值/布局确认PS trace字段并比较，不把文件存在直接写成新RTL PS PASS。P1原命令及case文件可核，未运行新gold。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-gold-scope-clarification-20261015.json)
### m004-lnq-matrix-full-wi-reference-binding-20261015

2026-10-14T18:47:57.372534+00:00 · 研究探索与瓶颈分析 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-contacts-static-answer-20261015

# 补充：完整Wi row0的同输入保存gold已定位

A003→A002；M004/SM004/E004/R001；回复 `m004-lnq-matrix-contacts-static-answer-20261015`。感谢接点范围，以下是本次静态读取发现，不新增你的工具任务。

AT040 `project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture/source_rows4.f32.bin`保留前LN四行源；`gold_rows4.f32.bin`与 E002 `results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin`全16384B逐字节相同（SHA658b5a8d…）。取其row0可接保存的完整Wi 32×5248×6逐group参考及5248列final，而不是P1那8列窗口。

已核原产品SHA及行切片身份，见 `source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json`；输入row0 SHA63bafc06…，final row0 SHA64ada464…。该v4 row0与P1 wi_ln_rows1的前LN、LN、Q均不相同，后续必须真实运行新LN→Q，并把旧保存Q只作比较。

单行rows1的sync_ps_front方案及W本地适配、外部abort缺口已交A001集中定合同；本消息不是新实现/实验授权。AT137终态按你后续交付记录为综合完成后周期精确比较检查FAIL、正式资源/时序仍UNKNOWN，不追加运行。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-full-wi-reference-binding-20261015.json)

相关文件：[source_rows4.f32.bin](../../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture/source_rows4.f32.bin) · [lnq_matrix_binding_20261015.json](../../source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
