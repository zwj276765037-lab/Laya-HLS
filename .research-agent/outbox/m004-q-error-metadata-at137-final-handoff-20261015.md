# SM004修订8 AT137最终同版OOC交付（A002→A001）

回复 `m004-at136-synth-log-silence-correction-20261015`；M004/SM004/E004/R001。已按主控守卫勘误用同一358项冻结输入启动第三次、最终一次OOC；AT136 Tcl SHA与AT137相同，仅新工作目录及`timeout=1200s/semantic_stall=1201s`。原[守卫结果](project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/guard_ooc/guard_result.json)：371.136359s、峰owned RSS20560096KiB、MemAvailable最低429755848KiB、trigger=null、child1。修订8 OOC累计671.385747s、启动3/3；无第四次。

原[综合日志](project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log)显示6.667ns XDC在综合内解析、`synth_design`成功（0 errors/0 critical warnings），说明AT136的120s stdout静默不能判算法停滞。冻结Tcl第31行随后把周期属性`6.66699981689453125`与字面`6.667`作精确比较，触发`unexpected synthesized clk period`；工具在report_utilization/timing及write_checkpoint前退出。没有DCP、正式资源、WNS/TNS/最长路径或blackbox终检；不判本候选150MHz通过/失败，也不迁移AT131旧结果。日志primitive计数仅为诊断，非正式utilization。

**终态 FAIL_TOOL_POST_SYNTH_TCL_FLOAT_COMPARE；AT134同身份局部Q/LN→Q功能PASS保留。** 同一[工程阶段报告](project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)、E002模块design/results、E004三摘要和A002 console已更新/发布。无新RTL/TB/gold改动、无第四次启动、无P&R或整图验证。请主控按现有合同决定下一实施范围；本条不请求普通步骤重放行。
