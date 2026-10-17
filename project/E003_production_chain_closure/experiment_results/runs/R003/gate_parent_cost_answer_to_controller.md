# gate-parent-cost-question-20261011 答复

结论：属于第2种情形；此前没有可支持`matrix_parent_views_07`的≤120s成功短pilot，也没有在该运行前冻结相同工作量的实测速率、预计cycles/墙钟或将其列为full RTL的计划。`matrix_parent_views_02/_03`虽使用120s guard，但均在36.854591/36.898027s功能失败，不能作为成功pilot或完成时长估算；`_04/_05/_06`已使用600s“pilot”且分别功能失败。`_07`继续以`tclargs=pilot`运行完整用例，guard上限600s，实际382.907547s、128440 cycles。因此不能事后改名追认为合规full。

偏离位置与范围：当前可追溯修改点为`project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_matrix_portal_binding.py`原循环中的`('pilot', 8, 600)`；冻结guard计划显示偏离从`matrix_parent_views_04/guard_pilot/guard_plan.json`开始，`_07`计划与receipt继续记录maximum_seconds=600和profile=pilot。功能结果与预算分开：`_07`冻结输入下的四view父路径局部功能PASS保留；其382.907547s运行标记为执行分类/预算DEVIATION，不能作为合规pilot/full成本证据。

后续入口已修正：testbench的PILOT只执行前9条有区分力的命令并输出周期数；runner恢复pilot≤120s，完整父view用例使用显式full profile、RTL≤8GiB/3600s。full启动前由pilot的真实elapsed/cycles按200000-cycle硬上限和1.5保守倍率生成seconds-per-cycle与墙钟估算并写入manifest；估算超过3600s即停止。没有为补历史记录重跑，也没有扩大预算。
