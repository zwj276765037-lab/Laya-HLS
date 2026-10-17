# E004：限定结果

AT091真实B1/S128软件基线按独立gold通过；AT101向量AXI服务、AT110 LN首错及AT124算术在途reset各保留原局部范围。SM004修订7 AT130真实Q和LN→Q两P1行独立数值/错误/反压/释放局部通过，gamma0/gamma1至row_valid为8597/11087cycle；AT131旧版联合OOC 37346 LUT/12518 FF/50 DSP/16 RAMB18、内部WNS−1.750ns，150MHz未过。AT133旧DCP定点查询first_error_key/numerical_error/done_status三类均违例，RAM写数据脚无有效路径。

修订8 Q SHA `bb47385…` 的AT134原114组/27 adapter独立gold、真实P1 LN→Q正常/错误/反压/释放/FP在途reset保持PASS；四项真实FMUL返回受控坏数据仅证明错误元数据控制路径。两行至row_valid仍8597/11087cycle。AT135缺IP Tcl普通构建FAIL；AT136因120s stdout静默守卫COST_STOP；AT137完成synth_design后因Tcl精确比较6.667与6.66699981689453125而child1，均无有效DCP。原失败收据未回写。

A001修订8普通脚本修复后，AT138同版RTL/IP/XDC的OOC成功：守卫406.915653s、峰owned RSS20558300KiB、child0/null；raw与最终DCP、正式资源/时序报告完整，blackbox/latch=0。Vivado 2025.2 U55C、前置6.667ns下37569 LUT、12543 FF、50 DSP、16 RAMB18、0 URAM；check_timing无未约束内部端点，但95输入/416输出无I/O delay。综合内部WNS−1.408ns、TNS−863.788ns、1316个setup违例，最差q divider head→first_error_key，32级/8.057ns数据路径。150MHz内部时序FAIL；无P&R或布线Fmax。旧AT131与本版RTL及约束流程不同，不能单因比较。

AT139只读同DCP：first_error_key−1.408ns、numerical_error+0.477ns、done_status+4.014ns；q0/q1及顶层行bank RAM写数据脚有对象匹配但无可报告路径，仍未验证该路径时序。修订8 OOC累计1078.301400s/1800s，已测static118.292583s；完整工程及新LN→Q→Wi仍NOT_RUN。见[同一阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)、[AT138守卫](runs/R001/attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04/guard_ooc/guard_result.json)与[时序报告](runs/R001/attempts/AT138_SM004_lnq_error_metadata_ooc_tcl_tolerance_04/work/timing_summary.rpt)。


---
Published: 2026-10-14T19:02:22.087285+00:00
Publication: P3438b4f1888a4f998544f896dc2ce8f6
