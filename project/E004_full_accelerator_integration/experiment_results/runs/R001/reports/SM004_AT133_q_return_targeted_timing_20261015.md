# AT133：AT131 DCP 定点时序只读查询

M004/SM004/E004/R001；SM004修订7；2026-10-15。使用AT131已保存的综合网表DCP（SHA256 `26b7303ca9fbcb78ddcd74c6034c9c2479f1dbba48e6e269810199f87fe3c258`），没有重综、优化、布线或修改RTL/DCP。[冻结Tcl](../attempts/AT133_SM004_lnq_dcp_target_timing_01/frozen/targeted_timing.tcl)只打开DCP，对指定实际FD/RAM数据输入端点各报一条max路径。[守卫原收据](../attempts/AT133_SM004_lnq_dcp_target_timing_01/guard_static/guard_result.json)为child0、trigger null、60.813549s、峰值owned RSS 4455408KiB；符合本次≤120s/24GiB。修订7已测static累计由208.642645s增至269.456193s；host准备未采样部分仍为UNKNOWN。

| 端点组 | 匹配的数据输入pin | 最差路径起点 → 终点 | Slack | 数据延迟 | 逻辑级数 | 原报告 |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| `q/first_error_key_reg*` | 64 | Q FMUL IP内FDRE（Vivado隐去层级）→ `q/first_error_key_reg[13]/D` | −1.134ns | 7.783ns | 34 | [first_error_key.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/first_error_key.rpt) |
| `q/numerical_error_reg*` | 1 | 同源Q FMUL IP内FDRE → `q/numerical_error_reg/D` | −1.519ns | 8.168ns | 38 | [numerical_error.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/numerical_error.rpt) |
| `q/done_status_reg*` | 2 | 同源Q FMUL IP内FDRE → `q/done_status_reg[0]/D` | −1.750ns | 8.399ns | 39 | [done_status.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/done_status.rpt) |
| `q/q0_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q0_write.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q0_write.rpt) |
| `q/q1_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q1_write.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q1_write.rpt) |
| 顶层 `q0_bank_reg*` RAM数据输入 | 156 | **No timing paths found** | — | — | — | [q0_bank_write.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q0_bank_write.rpt) |
| 顶层 `q1_bank_reg*` RAM数据输入 | 144 | **No timing paths found** | — | — | — | [q1_bank_write.rpt](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/q1_bank_write.rpt) |

匹配数及RAM类型取自[端点清单](../attempts/AT133_SM004_lnq_dcp_target_timing_01/work/targeted_endpoints.tsv)；q0/q1组存在RAM数据输入pin，但本次限定`report_timing -to`未给出有效时序路径，不能推断写路径达标，也不伪造起点或slack。三组错误状态本身已违例，故只删去done对本拍`best_error`的组合引用，不能单凭本表推定150MHz可过。上述均为AT131未布局布线DCP的6.667ns内部setup查询；布线Fmax、外部I/O与完整图仍未测。
