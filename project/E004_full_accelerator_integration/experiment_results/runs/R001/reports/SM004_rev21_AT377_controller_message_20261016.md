# 修订21 AT373–377工程限定里程碑

承接D-M004-REV21-AT372-01，修订21仍running/unassessed，不封账、不加帽。AT373下层部分A错kind/epoch→显式discard→新epoch Q恢复、AT374 Q输入在途共同reset510拍→新epoch恢复均局部PASS；不代签上层/父层。AT375真实独立LN128后注入W末q0 RRESP错，实际W三口完整排尽、norm131072字保持、零STATE1/Q，协议status7 PASS。AT376末B阻塞三拍continue不准入，释放后真实B8192/128行退休、gamma token退休 PASS。AT377 STATE1最后R阻塞三拍，r15 Q未提前启动；释放后独立真实A16完整checker、前4行Q/scale独立gold和后12行叶子到bank传递均PASS。

五次仅改冻结TB，实际上层`e2be4e1e…`、下层`30816465…`、W服务`519a2ccb…`、cache`6d13fae4…`同AT368；AT377 TB SHA`362d3714…`。新增五份manifest 744项逐SHA/字节零差异。AT352–377精确51guard、341政策；static1024.79789475537835202/1800s、RTL2541.6517546866089065/3600s；余static775.20210524462164798s、RTL1058.3482453133910935s，host完整UNKNOWN。原Fatal/timeout未改写。

阶段报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md`；机读账：同目录`SM004_rev21_guard_ledger_AT352_AT377_20261016.json`。E002 design/results及E004三摘要已更新。仍开放同步pending/rsp/done未消费屏障、legacy换路、r15导出末B、父top实际W/Q委派及完整父请求同runtime LN128→A16。D-M004-A16-MATRIX16-INTERFACE-01仅作为后继静态接口，当前没有矩阵实施或预算使用；最小迁移是父engine唯一front/矩阵FSM抽共同服务、现上层独立A claim与结果路由，保持同一W服务/cache和LNQ/bank。按原合同继续受影响验证。
