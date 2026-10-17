# E004：限定结果

AT130最终Q SHA `a1fd5b03…`：114组真实Q/3648字节及27 adapter边界逐位独立gold通过；82组任务164预约=164真实FP发射，四相位reset恢复、平衡选择标量oracle及受控同ordinal平局通过。最终同版LN→Q两真实P1行全部LN统计/1024输出和Q/FP16 scale逐位通过，5正常/4错误/1算术在途reset，合法反压/读释放/无reset恢复保持。gamma0/gamma1 cmd→row_valid 8597/11087cycle，比AT121同刺激+24/+23。

AT131唯一成功U55C联合OOC：37346 LUT、12518 FF、50 DSP、16 RAMB18E2，0 URAM/blackbox；相对AT116 LUT−4309、FF+326。6.667ns内部WNS −1.750ns、TNS −1225.669ns，150MHz仍FAIL；最差路径已改为FMUL结果→首错归并→done_status（39级）。AT132最终DCP只读核row_valid/done_valid为逻辑LUT2，并非综合网表GND。未做P&R，外部I/O无delay，实际Fmax未知。修订7受守卫实测static208.642645s、RTL100.811515s、OOC248.809009s；历史AT126静态FAIL、AT128相对路径启动FAIL保留。详见[同一阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)与[机读证据](runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json)。

AT133对AT131原DCP的[定点只读查询](runs/R001/reports/SM004_AT133_q_return_targeted_timing_20261015.md)显示first_error_key、numerical_error、done_status最差路径各为−1.134/−1.519/−1.750ns，34/38/39级，三者自身均未过6.667ns；q0/q1 RAM写数据输入各匹配156 pin但报告无有效路径。新增static60.813549s，修订7已测累计269.456193s；AT131原网表和阶段报告不变。

修订8同版Q SHA `bb47385…` 在AT134原114组/27 adapter独立gold、真实P1 LN→Q正常/错误/反压/释放/FP在途reset保持PASS；真实FMUL返回上的四个有限受控坏数据样本证明候选守恒、连续两half同拍交接、三来源首错和候选在途reset。gamma0/gamma1至row_valid仍8597/11087拍。AT135缺IP Tcl在综合前普通构建FAIL；AT136补齐后实际于综合内应用前置6.667ns XDC，但Timing Optimization连续120s无stdout语义进展而原守卫COST_STOP，292.768357s/峰owned RSS17389648KiB，无DCP、资源或WNS/TNS。主控随后更正守卫判据，准许一次同冻结候选测量恢复；修订8同版物理结果仍UNKNOWN，旧AT131数据不可迁移。static57.873714s、RTL30.857233s；详见[同一连接报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。

主控守卫勘误后，AT137用同一冻结RTL/IP/Tcl/XDC第三次且最终一次启动，371.136359s、峰owned RSS20560096KiB、无资源触发；前置XDC参与的`synth_design`完成。后续Tcl把返回的周期`6.66699981689453125`与`6.667`精确比较而child1，发生在资源/时序报告和DCP之前，故**FAIL_TOOL_POST_SYNTH_TCL_FLOAT_COMPARE**。原日志primitive计数仅作诊断，正式utilization、WNS/TNS与150MHz结论仍UNKNOWN。修订8 OOC合计671.385747s、启动3/3；AT134局部功能PASS不变，旧AT131物理值不能迁移。原[守卫终态](runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/guard_ooc/guard_result.json)与[综合日志](runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log)保留。


---
Published: 2026-10-14T18:33:55.986105+00:00
Publication: P427430f4091342f4920d20090ac5f3b6
