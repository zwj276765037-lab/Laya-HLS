# KB1冷W加载在当前TB供数条件下的界限

这是AT001/AT002原证据的只读补充，无新DUT、无新工具。前次集中报告称W加载27064cycles（全冷样本61.58%）是下一项大成本；本页区分“大成本”和“同供数条件下可通过读取器调度消除的成本”。

q0/q1各实际接收20992个512-bit R beat、各有5248个q_active且RVALID=0的周期，DUT三路R-not-ready均0；q0/q1各自的已观察活动拍+供数gap为26240cycles。当前TB对每个口固定`RVALID = q_active && cycle%5 != port`，最多连续五周期给四拍。保持每口20992个真实拍和这一response profile，单口完成这些传输的最乐观跨度也要至少26239cycles（允许最有利的周期相位）。整个W加载实测27064cycles，因此仅减少读取器调度/突发间隙、同时保持其它边界的理想节省上限约825cycles，即W加载3.05%、全冷TB1.88%。这只是上限，不能声称全部可实现。

冻结reader逐笔按完整burst预约，ISSUE→RECV串行；下一burst待上一笔末R后发出。AR门与发布/校验还可能占用上述约825周期，但没有逐项互斥分类，不能将它们全判可删除。q0/q1主数据拍和TB周期性无RVALID占据了绝大部分区间，现数据不支持把整27064cycles当成单模块调度优化空间。

若研究真实物理HBM服务、W重用或加载与计算重叠，应各自建立有声明边界的baseline和真实性/READY/债务证明；原同profile KB0/KB1不能直接当这些新范围的对照。当前同范围后继更值得先考察cfg→done16183cycles中的真实PS/计算/写入重叠条件；本轮仅提供瓶颈选择证据，不启动第二候选。

原依据：[数值/计数](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/measurement_full.json)、[冻结TB](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/tm4tn8_matrix_resident_tb_v2.sv)、[冻结reader](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/frozen/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv)、[推导JSON](KB1_W_load_service_bound_20261013.json)。
