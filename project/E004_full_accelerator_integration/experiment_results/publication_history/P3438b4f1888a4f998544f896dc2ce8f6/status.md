# E004：状态

execution_state: running；verdict: unassessed（完整M004加速器）。SM004修订8工程段已到有界出口：同版Q/LN→Q局部功能PASS，AT137同版OOC在synth_design后因Tcl浮点精确比较错误退出，未得到新DCP或正式资源/时序结论；最终三次启动上限已用。无本项目owned重工具运行。主控据此决定后续矩阵A连接或物理障碍处理。真实final gamma、外部AXI/HBM、矩阵A、完整硬件图、P&R、板端和整模性能仍NOT_RUN；本局部PASS不代签全图。

主控将AT136的120s stdout静默守卫误判改为墙钟主保护，准许同冻结候选第三次最终OOC。AT137已终止：`synth_design`完成，后置Tcl因6.667ns浮点精确比较错误child1，DCP及正式资源/时序报告均未生成；无本项目owned重工具。修订8累计OOC671.385747s、启动3/3，按合同不再运行。局部功能PASS仍只属AT134；本候选物理结论UNKNOWN，主控据此决定下一范围。

AT133已完成原AT131 DCP的有界只读查询（child0、trigger null）：错误状态三个端点组各有违例路径；q0/q1写数据RAM pin有匹配但无有效时序路径。修订7static已测累计269.456193s；细节见[AT133报告](../experiment_results/runs/R001/reports/SM004_AT133_q_return_targeted_timing_20261015.md)。此查询没有启动新OOC或更改候选身份。

AT134静态/Q及LN→Q仿真均child0/null；AT135普通构建缺IP Tcl为FAIL，AT136前置时钟已被综合解析应用但原stdout静默守卫触发、child−9/无DCP。AT137完成综合后Tcl错误child1/无DCP。修订8static57.873714s、RTL30.857233s、OOC671.385747s，启动3/3。详见[同一工程报告](../experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。AT131资源/WNS仍仅属旧Q候选；新候选150MHz结论UNKNOWN。

AT136的静默只说明原守卫判据命中；AT137证明该同版综合可完成，但其冻结Tcl随后普通脚本FAIL。原AT135/136记录不变，修订8最新OOC账为671.385747s/3次；新候选完整OOC仍未通过，无第四次授权。


---
Published: 2026-10-14T18:45:57.366945+00:00
Publication: P8d5e365cf11840e9a2ca709a32d0cbc7
Execution state: running
Research verdict: unassessed
Applicability: SM004修订8同版Q/LN→Q局部RTL功能PASS；AT137综合已完成但冻结Tcl后置精确浮点比较FAIL，无DCP/正式资源/时序；完整硬件图及150MHz未知
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_lnq_sim/driver.log
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/source_manifest.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/guard_ooc/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log
