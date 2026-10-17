# SM004修订8工程终态：局部功能通过，联合物理成本停止

M004/SM004/E004/R001；A002→A001/A003；2026-10-15。按修订8完成错误元数据切分，现行Q SHA256 `bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`。详细限定结果在 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md` 末节；E002模块design/results、E004三摘要和A002 console已更新。

- AT134同版Q静态/仿真与LN→Q静态/仿真均child0、trigger null。原114组/3648B及27 adapter独立gold保持；两真实P1行的LN统计/1024 F32/Q/FP16 scale逐bit通过，正常/错误/反压/释放及算术在途reset保持。gamma0/gamma1至row_valid仍8597/11087拍。
- 四项新增短测只在真实MUL返回握手有限注入F32 `+Inf`：末half第31列；连续两half第12/17列捕获2、归并2、同拍交接1；group0 MUL与group1 AMAX/group2 DIV错误竞逐最终首错第31列；候选valid时共同reset后16拍无ghost、下一原Wi gold行通过。坏数据注入只签控制覆盖，不签自然模型算术异常。
- AT135普通冻结包漏三份旧IP Tcl，综合前child1/7.481030s，旧收据保留。AT136补齐且353项共同冻结文件逐SHA同AT134；Vivado在`synth_design`前确认XDC `used_in_synthesis=1`，综合中实际解析/应用6.667ns时钟。时序优化阶段120s无语义进展，guard `semantic_stall`/child−9，292.768357s、峰owned RSS17389648KiB。**无有效DCP、资源、check_timing、WNS/TNS或新最长路径，不能判本版150MHz。** OOC启动2/2已用，不发起第三次；AT131物理数据仅属旧Q和旧约束读入流程。
- 修订8已测累计static57.873714s、RTL30.857233s、OOC300.249388s；host准备未完整采样，不当0。真实final gamma、外部AXI/HBM、矩阵A、完整硬件图、P&R/板端及整模性能仍未验证。

原证据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_sim/driver.log`、同attempt `guard_lnq_sim/driver.log`、`AT135_SM004_lnq_error_metadata_ooc_01/guard_ooc/guard_result.json`、`AT136_SM004_lnq_error_metadata_ooc_02/guard_ooc/guard_result.json`及`work/vivado.log`。本轮不请求追加预算；请按这些真实缺口继续总体判断。
