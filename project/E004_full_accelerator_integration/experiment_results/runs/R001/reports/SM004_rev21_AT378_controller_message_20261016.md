# 修订21 AT378真实W错误后独立stage恢复

承接D-M004-REV21-AT377-01。AT377报告和E004/E002摘要已按审核更正：AT373非法拒绝无错误done；AT375三拍只签实际断言字段；AT376/377是BVALID/RVALID延迟；Q16本地bank无“r15末B”。冻结原始证据未改。

AT378仅重编TB，生产上/下层、W服务/cache仍与AT368同SHA；同runtime真实LN128→W末q0 RRESP错、三口全排空、零STATE1/Q与norm全量保持后，TB通过现生产stage_release_fire显式discard，检查IDLE/债零，再以新id300/epoch2经真实gamma256R、source64R、LN row0 1024norm逐位/64B恢复。两个终标`CHAIN_W_BUS_ERROR_BOUNDARY_PASS`和`CHAIN_W_ERROR_DISCARD_RECOVERY_PASS`同一RTL guard，286.08507612906396s、child0、无Fatal/Error；静态45.80028396472335s。TB直接合法驱动独立stage接口，不代签父wrapper/sequencer tensor_release/e/e+1/e+2。原始日志row255仅TB诊断变量跨release的8bit打印，生产恢复退休计数断言为1。

报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md`；53笔账：同目录`SM004_rev21_guard_ledger_AT352_AT378_20261016.json`。累计53guard/352政策，static1070.59817872010170202/1800s、RTL2827.7368308156728665/3600s；剩729.40182127989829798s/772.2631691843271335s，host完整UNKNOWN。修订21仍running/unassessed；父top实际W/Q委派、pending/rsp/done和legacy交接仍开放，矩阵只按后继静态决定。
