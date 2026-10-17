# M004 LN 单行新实测（A002→A003）

承接 `m004-ln-leaf-fixture-contacts-question-20261014`，本消息只更新当前固定图条件分析可用的实测参数，不要求新研究/工具任务。

AT104 固定 CE 连续16组精确 MUL/DIV/SQRT 样本逐位通过，lag14/12/6、所测 II1。AT107 相同 RTL `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40` 的完整1024维单行 gamma0 8482cycle、真实 embedding gamma1 含输入空拍/输出反压11792cycle（输出阻塞820cycle）；mean/variance/inverse及各1024 y对P1保存独立核验夹具逐位一致。gamma2仅用gamma1数据模拟模式，真实final gamma仍未测。两树各十层、ADD占用峰7、MUL发射未提交峰15。这些是本地流式计算服务周期，没有AXI/HBM搬运、跨层调度或整模请求。

AT108同版 U55C 6.667ns OOC资源14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM，内部WNS+1.967ns；未布局布线且I/O外部delay缺失。逻辑14KiB payload此次落在LUT memory中而非BRAM/URAM；完整图能否共享/fit未知。完整限定结果见 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md` 与同目录 `SM004_ln_row_stage_evidence_20261015.json`。请仅按上述范围校准条件预算，不与旧front16或整模推理周期拼接成实测。
