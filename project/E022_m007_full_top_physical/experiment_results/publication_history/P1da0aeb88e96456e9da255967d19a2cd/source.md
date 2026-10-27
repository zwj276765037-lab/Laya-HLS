# E022：一次同DCP优化完成，候选只读复核运行

A010 / SM012 / D38；同f849生产matrix core、91源/ROM、父11 generic、xcu55c-fsvh2892-2L-e、原3.333333333ns XDC。D37原完整30层正常功能保持其原版本；operand表示版只沿用已验局部四态桥接，没有重跑功能。完整parent/top联合网表仍未形成。

AT019原完整core_synth.dcp为520296664B，SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90。AT020实际完成报告/源码核验/清理。旧serial已精确有序退出并回收，intentional exit3，无facade后继。AT021/022仅在pre-opt身份API检查失败，费用/原件保留；current_design.NAME是checkpoint容器，fileset.TOP为空。AT023改用真实utilization报告Design/Device标头严格核载入网表，结合SHA绑定的dcp.xml；解析及实际before均通过，没有降低top/part检查。

AT023仅调用一次普通opt_design，成功返回；候选core_opt.dcp493065634B，SHA97426945bdf39b3ad1b6e0056583fa5153df570018efb219a017e9a87ca942f3。完整190017位port名字/方向已与全部RTL声明机械枚举全等，before/after完整port/clock/导出XDC边界字节相等、零BB，原DCP SHA不变。候选另存，没有覆盖原件。实际Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5、guard4b6d3135...，canonical421649...保持。

AT024_report_core_opt于UTC20:35:22.805725实际启动，只读复开候选，做同口径util/hierarchy/ram/clocks、直接primitive有界归组，以及全局最差setup和原n_reg[1]→error_col_reg[0]/CE固定路径各最多1条。对象/路径缺失则如实记录不可用。无完整post-opt TNS/hold/placed/routed验收。

不改RTL/数值/shape/接口/容量/并发、时钟、保留属性；不加tieoff/case analysis，不抑制UTLZ，不重综合/功能或重复opt。沿原单锁、256GiB、MemAvailable>192GiB、CPU0–3/nice19/idle/max4线程、300s真实CPU/log/checkpoint停滞保护及无物理墙钟期限；全部历史费用保留。候选LUT仍超器件，禁止自动place/route或完整父装配，完成本诊断后交主控集中判断。

协议：[core_opt_diagnostic_protocol.md](core_opt_diagnostic_protocol.md)；原始身份和证据在project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt与AT024_report_core_opt。


实际候选复开边界与AT023 after字节全等，资源复核完成；当前只剩原授权的两条setup观察与最终清理/证据核验。


---
Published: 2026-10-26T20:49:11.607928+00:00
Publication: P48acbd97843945a6ad243c0776c01eb1
