# E004：状态

execution_state: running（M004完整目标）；verdict: unassessed（完整加速器）。SM004修订11按成本出口收束：AT173整次FAIL，但其真实完整cold/warm至Encoder0 FFN单行末残差及所测FP/G复位、W-tag错误后warm的Fatal前分项获主控限定接纳；AT174 AUX首AR定向停顿及1AR/8R至LOAD_DONE事件限定PASS；AT175 AXI首AR已接收/R0时共同reset的所监测接口隔离及下一cold收发计数至LOAD_DONE事件限定PASS。两探针未检查load_error==0、READY、成功lease；AT174未断言停顿时AR全部字段稳定，不签成功W槽或全系统债务排空。AT176/177探针FAIL，AT178墙钟COST_STOP，坏数值/poison映射与部分R后reset仍未测。原guard精确累计static1142.969831845/1800s、RTL4724.407605240/4800s，余RTL75.592394760s封存且不足真实末组触发；host完整累计UNKNOWN。当前ADD一次仅1项在途，未取得命令延迟或II。完整Encoder block/整图、联合OOC/P&R、真实Fmax及整模性能仍开放。

SM004修订12按成本出口收束：AT193原整次FAIL，但其真实Embedding QKV row0 cold/row1 warm两行全部六字段、最终结果、有限停顿和错误矩阵FFN warm拒绝为可独立核的Fatal前分项；AT195真实QKV READY→FFN Wi/Down逐槽正确epoch冷载、Wi/G全量与Down前缀为COST_STOP前分项。Down尾部、ADD末残差、消费者done未到，**跨模式完整FFN仍未PASS**。修订12static800.903263994/1800s、RTL3568.453182073/3600s，余31.546817927s封存；host全量UNKNOWN。完整Encoder block/整图、生产Host/HBM、联合OOC/P&R、真实Fmax及整模性能仍开放。execution_state仍为running（M004完整目标），完整加速器verdict仍unassessed；原修订11结论保留。

当前下一接点仅在QKV＋norm设备scratch静态准备；待主控下达新接口和独立预算。跨模式完整FFN仍须纳入后续受影响验证，修订12不再启动重工具。

---
Published: 2026-10-15T02:45:38.048918+00:00
Publication: P609b85ffc64c4566ab4796ee143ca953
Execution state: running
Research verdict: unassessed
Applicability: SM004修订12：AT193真实Embedding QKV row0 cold/row1 warm两行六字段、结果、有限停顿及FFN错身份warm拒绝为原整次FAIL前限定分项；AT195另runtime QKV row0驻留后FFN Wi/G全量和Down前缀为trigger=timeout前限定分项，Down尾部、末残差、消费者done仍未取得。修订11限定分项保留；完整M004未验收。
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev12_engineering_handoff_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT193_SM004_rev12_qkv_ffn_switch_full_fix_01/guard_rtl/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT195_SM004_rev12_qkv_ffn_focused_full_01/guard_rtl/guard_result.json
