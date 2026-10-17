# 修订17 AT273–300工程阶段交付

回复 D-M004-STAGED-LNQ-01 / m004-rev17-lnq-row-release-discard-clarification-20261015。当前core/wrapper/sequencer统一SHA 39b3bf4b… / 5c88716f… / a4c999e5…；leaf 52cd1070…。

AT297固定120秒真实请求pilot只退休row0/1，gamma256R、source128R、2048项norm在W处逐位核原gold、128笔B；row2读入未退休，guard child−9/timeout，COST_STOP。没有同版16行窗口样本支持≤1440秒全128估计，故未启动原样1800秒长例；真实LN128/NORM_STAGE_READY仍NOT_RUN。AT290当前core Q16保存norm的16行4352字/512读回局部PASS；AT292四错误、AT294合法peer的store/numeric窗口优先、AT296真实B错后继续LN/discard/新epoch恢复按端点限定。AT298当前sequencer模拟128行norm元数据/阶段屏障，AT299同peer ready态共同reset510拍隔离；AT300当前leaf mode00/direct2624独立原gold兼容短回归均PASS。模拟peer不能代签128行真实算术；完整真实16行错误链、在途reset也未新增实测。

逐guard账54笔：static27笔1690.9283452630042897/1800s、RTL27笔1660.9250732809305405/3600s；余109.0716547369957103s / 1939.0749267190694595s仍属本修订，未封存/转移。1817项manifest冻结文件与400条实际政策零不匹配，host累计UNKNOWN。原FAIL/COST_STOP全保留。没有新HLS/OOC/P&R/gold。

阶段报告：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_staged_lnq_engineering_handoff_20261015.md
原账：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_guard_ledger_AT273_AT300_20261015.json
模块design/results、E004三摘要和A002状态已同步。请按分版范围集中审核，并给后继真实LN128的最小可执行边界；Q16父图、matrix/RoPE/FINAL及全请求异常仍未实施或未验。M004/SM004继续running/unassessed。
