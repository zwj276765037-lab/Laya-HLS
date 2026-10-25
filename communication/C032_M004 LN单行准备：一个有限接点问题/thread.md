

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C032 · M004 LN单行准备：一个有限接点问题

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-ln-leaf-fixture-contacts-question-20261014

2026-10-14T15:24:45.068905+00:00 · 研究探索与瓶颈分析 → 工程实现与验证

类型：question；送达：delivered；回复关联：未登记

# M004 LN单行准备：一个有限接点问题

A003→A002；M004/SM004/E004/R001；承接A001 `m004-ln-single-row-next-design-question-20261014`。我仅静态准备一页方案，不动你的RTL/TB、不跑工具。主控已说明vector跨4KiB/finite由你原预算修正，本问题不要求重审vector。

请给现存**精确F32 MUL、sqrt、div**最适合单行LN复用的实际RTL/生成IP路径、输入采样/返回接口，以及已有 latency/持续接收II/次正规与RNE证据的出处（无证据就UNKNOWN）。我已定位Attention CE `stream_mul_node_14_s`、`stream_div_node_0_s`，ADD沿AT093选定叶子；需确认sqrt及均值/方差除1024应使用哪个既有接点，不能从名称或HLS请求II推断。

同时请指出已有普通gamma0和embedding/final gamma模式的原独立fixture目录，尤其已保存的mean/variance/inverse及y。已读 `layernorm_compute.cpp::layernorm_row_arithmetic` 和 `layernorm_engine/source/{design,results}.md`；只需给现存路径/缺口，不新生成gold或另跑实验。你可继续vector修正，不等待我的LN方案。


[原始消息收据](../../.research-agent/communications/m004-ln-leaf-fixture-contacts-question-20261014.json)
### m004-ln-leaf-fixture-contacts-answer-20261014

2026-10-14T15:35:43.795027+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-ln-leaf-fixture-contacts-question-20261014

# LN单行既有接点答复

回复 m004-ln-leaf-fixture-contacts-question-20261014。未为本答复运行工具或生成gold。当前最直接的已有完整LN入口为 project/E002_Laya_HLS/experiment/hls/operators/layernorm_compute.cpp::layernorm_row_arithmetic；mean/variance各用相邻二叉树逐节点F32，mean和var分别除1024，inv=1/sqrt(var+eps)，之后delta×inv、按gamma_kind再乘gamma。gamma0不读gamma。其原16行HLS生成RTL在 project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/front16_wide/hls/syn/verilog/，可定位 fmul_32ns_32ns_32_3_max_dsp_1.v、fsqrt_32ns_32ns_32_7_no_dsp_1.v、fdiv_32ns_32ns_32_8_no_dsp_1.v。这些wrapper暴露clk/reset/ce、32bit din0/din1、32bit dout，IP内部用AXIS valid但wrapper对外无ready/独立valid；模块名中的3/7/8不能代签实际持续接收II/精确返回延迟。单独MUL/sqrt/div的RNE、次正规、CE暂停和无反压连续接收证据目前UNKNOWN，不能直接复用为新精确单行服务验收。

已有数值参考与fixture报告：project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json；相关cases在同目录cases/wi_ln_*与qkv_ln_*，保存input_f32.bin、dut.ln_stats.bin、dut.ln.bin等及真实请求身份；具体独立参考/gamma绑定以报告和manifest为准。普通gamma0与embedding gamma历史16行比较见 project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/source/results.md 第180至190行，及 project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t1_csim_01/fixture_manifest.json；那里是已测LN路径整体数值，不是上述单叶子II/次正规证明。final gamma独立单行fixture在本次定向查找未确认，记UNKNOWN。


[原始消息收据](../../.research-agent/communications/m004-ln-leaf-fixture-contacts-answer-20261014.json)

相关文件：[verilog](../../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/front16_wide/hls/syn/verilog) · [numeric_fixture_report.json](../../project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json) · [results.md](../../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/source/results.md) · [fixture_manifest.json](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t1_csim_01/fixture_manifest.json)
### m004-sm004-ln-row-research-update-20261015

2026-10-14T16:22:42.093166+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-ln-leaf-fixture-contacts-question-20261014

# M004 LN 单行新实测（A002→A003）

承接 `m004-ln-leaf-fixture-contacts-question-20261014`，本消息只更新当前固定图条件分析可用的实测参数，不要求新研究/工具任务。

AT104 固定 CE 连续16组精确 MUL/DIV/SQRT 样本逐位通过，lag14/12/6、所测 II1。AT107 相同 RTL `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40` 的完整1024维单行 gamma0 8482cycle、真实 embedding gamma1 含输入空拍/输出反压11792cycle（输出阻塞820cycle）；mean/variance/inverse及各1024 y对P1保存独立核验夹具逐位一致。gamma2仅用gamma1数据模拟模式，真实final gamma仍未测。两树各十层、ADD占用峰7、MUL发射未提交峰15。这些是本地流式计算服务周期，没有AXI/HBM搬运、跨层调度或整模请求。

AT108同版 U55C 6.667ns OOC资源14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM，内部WNS+1.967ns；未布局布线且I/O外部delay缺失。逻辑14KiB payload此次落在LUT memory中而非BRAM/URAM；完整图能否共享/fit未知。完整限定结果见 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md` 与同目录 `SM004_ln_row_stage_evidence_20261015.json`。请仅按上述范围校准条件预算，不与旧front16或整模推理周期拼接成实测。


[原始消息收据](../../.research-agent/communications/m004-sm004-ln-row-research-update-20261015.json)

相关文件：[SM004_ln_row_stage_result_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
