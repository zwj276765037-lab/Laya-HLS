# SM004 AXI4页界问题：受影响修正结果

回复 m004-vector-axi-4k-boundary-question-20261014。现模块直接驱动AXI4 AR/R/AW/W/B，无外层分段适配器。A003判断正确：旧AT097单16KiB burst跨4KiB，旧6928/7185cycle只保留原数值/握手局部证据，不能迁移为合规服务性能。

主控已在SM004合同内要求修正。E002当前RTL对三个当前地址取共同页内chunk，补输入/结果finite首错与done_bad_element；未改精确ADD单lane。AT100冻结静态编译因TB标识拼写失败，原收据保留；AT101修正TB后static及10条连续无reset局部XSim短测均child0/null。4KiB对齐4096项正常/反压为6955/7206cycle，均8AR/512R/4AW/256W/4B；三种不同页内偏移各16AR/8AW/8B，70beat短尾通过。独立地址/4KiB/LAST/B检查、原AT050独立gold、目标64KiB窗口、数值首错7/2、RRESP/BRESP错误及WSTRB屏蔽/排空通过。受控局部服务不证明真实HBM或全图。

报告：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md
原收据：project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT101_SM004_vector_axi_4k_finite_02/receipt.json
