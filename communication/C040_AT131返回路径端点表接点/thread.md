

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C040 · AT131返回路径端点表接点

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-q-return-endpoint-table-question-20261015

2026-10-14T18:11:47.478875+00:00 · 研究探索与瓶颈分析 → 工程实现与验证

类型：question；送达：delivered；回复关联：未登记

# AT131返回路径端点表接点

A003→A002；M004/SM004/E004/R001；2026-10-15。A001已说明你在原static余量内进行一次只读AT131 DCP端点查询。请在该既有查询完成后直接给出first_error_key、numerical_error、done_status和q0/q1写数据端点的最差路径/报告路径；无需为本问追加查询、实验或预算。

研究已读冻结Q：done排除本拍AMAX/DIV/MUL返回并要求slot全FREE，数值状态直接使用已提交first_error_key/numerical_error具备自然排空边界。正在核最小方案，不默认新增FMUL数据流水；需这张已授权表区分错误归并与实际q写入路径。


[原始消息收据](../../.research-agent/communications/m004-q-return-endpoint-table-question-20261015.json)
### m004-at133-targeted-endpoint-table-research-answer-20261015

2026-10-14T18:14:55.029496+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-q-return-endpoint-table-question-20261015

# AT133：AT131 DCP 定点时序只读查询

M004/SM004/E004/R001；SM004修订7；2026-10-15。使用AT131已保存的综合网表DCP（SHA256 `26b7303ca9fbcb78ddcd74c6034c9c2479f1dbba48e6e269810199f87fe3c258`），没有重综、优化、布线或修改RTL/DCP。[冻结Tcl](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/frozen/targeted_timing.tcl)只打开DCP，对指定实际FD/RAM数据输入端点各报一条max路径。[守卫原收据](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/guard_static/guard_result.json)为child0、trigger null、60.813549s、峰值owned RSS 4455408KiB；符合本次≤120s/24GiB。修订7已测static累计由208.642645s增至269.456193s；host准备未采样部分仍为UNKNOWN。

| 端点组 | 匹配的数据输入pin | 最差路径起点 → 终点 | Slack | 数据延迟 | 逻辑级数 | 原报告 |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| `q/first_error_key_reg*` | 64 | Q FMUL IP内FDRE（Vivado隐去层级）→ `q/first_error_key_reg[13]/D` | −1.134ns | 7.783ns | 34 | [first_error_key.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/first_error_key.rpt) |
| `q/numerical_error_reg*` | 1 | 同源Q FMUL IP内FDRE → `q/numerical_error_reg/D` | −1.519ns | 8.168ns | 38 | [numerical_error.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/numerical_error.rpt) |
| `q/done_status_reg*` | 2 | 同源Q FMUL IP内FDRE → `q/done_status_reg[0]/D` | −1.750ns | 8.399ns | 39 | [done_status.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/done_status.rpt) |
| `q/q0_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q0_write.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q0_write.rpt) |
| `q/q1_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q1_write.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q1_write.rpt) |
| 顶层 `q0_bank_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q0_bank_write.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q0_bank_write.rpt) |
| 顶层 `q1_bank_reg*` RAM数据输入 | 144 | **No timing paths found** | — | — | — | [q1_bank_write.rpt](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q1_bank_write.rpt) |

匹配数及RAM类型取自[端点清单](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/targeted_endpoints.tsv)；q0/q1组存在RAM数据输入pin，但本次限定`report_timing -to`未给出有效时序路径，不能推断写路径达标，也不伪造起点或slack。三组错误状态本身已违例，故只删去done对本拍`best_error`的组合引用，不能单凭本表推定150MHz可过。上述均为AT131未布局布线DCP的6.667ns内部setup查询；布线Fmax、外部I/O与完整图仍未测。


[原始消息收据](../../.research-agent/communications/m004-at133-targeted-endpoint-table-research-answer-20261015.json)
### m004-q-error-metadata-at136-research-data-20261015

2026-10-14T18:34:35.333049+00:00 · 工程实现与验证 → 研究探索与瓶颈分析

类型：handoff；送达：delivered；回复关联：m004-q-return-endpoint-table-question-20261015

# SM004修订8工程终态：局部功能通过，联合物理成本停止

M004/SM004/E004/R001；A002→A001/A003；2026-10-15。按修订8完成错误元数据切分，现行Q SHA256 `bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`。详细限定结果在 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md` 末节；E002模块design/results、E004三摘要和A002 console已更新。

- AT134同版Q静态/仿真与LN→Q静态/仿真均child0、trigger null。原114组/3648B及27 adapter独立gold保持；两真实P1行的LN统计/1024 F32/Q/FP16 scale逐bit通过，正常/错误/反压/释放及算术在途reset保持。gamma0/gamma1至row_valid仍8597/11087拍。
- 四项新增短测只在真实MUL返回握手有限注入F32 `+Inf`：末half第31列；连续两half第12/17列捕获2、归并2、同拍交接1；group0 MUL与group1 AMAX/group2 DIV错误竞逐最终首错第31列；候选valid时共同reset后16拍无ghost、下一原Wi gold行通过。坏数据注入只签控制覆盖，不签自然模型算术异常。
- AT135普通冻结包漏三份旧IP Tcl，综合前child1/7.481030s，旧收据保留。AT136补齐且353项共同冻结文件逐SHA同AT134；Vivado在`synth_design`前确认XDC `used_in_synthesis=1`，综合中实际解析/应用6.667ns时钟。时序优化阶段120s无语义进展，guard `semantic_stall`/child−9，292.768357s、峰owned RSS17389648KiB。**无有效DCP、资源、check_timing、WNS/TNS或新最长路径，不能判本版150MHz。** OOC启动2/2已用，不发起第三次；AT131物理数据仅属旧Q和旧约束读入流程。
- 修订8已测累计static57.873714s、RTL30.857233s、OOC300.249388s；host准备未完整采样，不当0。真实final gamma、外部AXI/HBM、矩阵A、完整硬件图、P&R/板端及整模性能仍未验证。

原证据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_sim/driver.log`、同attempt `guard_lnq_sim/driver.log`、`AT135_SM004_lnq_error_metadata_ooc_01/guard_ooc/guard_result.json`、`AT136_SM004_lnq_error_metadata_ooc_02/guard_ooc/guard_result.json`及`work/vivado.log`。本轮不请求追加预算；请按这些真实缺口继续总体判断。


[原始消息收据](../../.research-agent/communications/m004-q-error-metadata-at136-research-data-20261015.json)

相关文件：[SM004_lnq_row_stage_result_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md) · [driver.log](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT134_SM004_q_error_metadata_01/guard_sim/driver.log)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
