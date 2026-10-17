## 2026-10-13 SM005局部Down KB0/KB1

依据D-M004-MEASUREMENT-FIRST-01，局部算术测量先于恢复executor。KB0采用E003/R003/resident_regression_02原26 frozen闭包与12独立fixture；新增tm4tn8_down_measurement_tb_v1.sv只加观察/真实done消费，保持4distinct预量化A、K2624/N1024、bias0/冷reset、PS及4096F32独立gold、AXI末B/局部owner、原7cycle done hold。计量边界cfg接受→first done pre-NBA采样及实际consume，加载在cfg之前另记。非互斥stall不加成总延迟。

KB1普通缓冲候选为rtl/tm4tn8_axi512_writer_rowpack_kb1.sv；与原writer同module名，只通过新AT frozen source override编译，不能同一compile加原文件。保留完整config/packet/address校验、一个held packet与一个不可变tx；单pack改4个row-keyed pack。相邻两TN8 tile同row/同64B地址合并，full或同row地址变化/flush时选一个sealed pack转原tx，只有tx空或实际B消费才能替换tx。所有pack、held、旧tx均空才debt_zero，flush/owner发布仍等实际末B。四row流不改算术/PS反馈/归约，只改存储合并。

预期4096F32 useful bytes仍16384，AXI512单beat数512→256、physical bytes32768→16384；原响应策略AW cycle%7/W cycle%11及B延迟17+(实际beat序号%3)、done7hold原样保持。不是减少测试台等待来求收益。额外pack字段3×(512data+64addr+64strobe+1valid)=1923bits，约240.375B逻辑存储；无新增算术IP/DSP，具体LUT/FF/RAM映射、联合资源/时序UNKNOWN，本轮无OOC/P&R/上板。

本候选目前仅源码准备，实际数值/cycles待同口径KB0完成后串行KB1。有限normal测试不能签通用fault恢复；原坏packet握手同沿可能transfer一旧sealed pack的窗口继承不变，不在本优化修改。若实验内fault立即停样本。生产控制/cleanup/全请求未完成项保留。
