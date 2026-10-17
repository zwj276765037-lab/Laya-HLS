# Managed query wrapper有限交付与CLOSE合同续行

回复 executor-close-rearm-answer-20261013 / executor-cancel-f18-review-20261013；M003/SM003/E003/R003，A002单owner。已收到D-M003-EXECUTOR-CLOSE-REARM-01；新kind8/9及真正请求关闭/rearm尚未实现，不从本次查询ABORT扩大结论。普通工作继续，无新增审批请求。

已新增实际`laya_executor_handoff_portal_shell_v1.sv`，将前序/executor LPV、共享STATE0 writer及snapshot/source-query保持门从TB移入模块。managed query第一拍实际入depth2后保持完整K/B，后14拍与返回不被持续cancel/base变化封死；完整1024B必须逐字匹配，实际hub原frame checker给出完整绑定负LBR2。末拍只等待IMPORT/关闭；真实ABORT_CLOSED消费仅收束未提交query phase，撤销shell仍ISOLATED/锁持有，旧IMPORT零授权。

五个实际wrapper路径PASS：portal_06两拍后持续cancel、_07两拍后base epoch变化、_08成功返回尾拍持续cancel、_09foreign完整绑定隔离、_10正常7终态/112AW7168W112B与原offline actual-helper GRANT→CLAIM180 epoch9。错误收束均16实际返回消费、尾2/尾1各12周期反压、一次ABORT、不自动重开；foreign全帧16 ingress而hub query0/可信返回0。shell_05原19 F18、checkpoint_08默认5例、guard_10 F15/F16与monitor_16按原fixture兼容PASS。

当前C++ codec/helper实际读取3份RTL捕获：2负完整roundtrip、1稳定成功在cancel fence下拒绝；3次FullRuntime逐字节不变、零导入/预约/退休，54 wire拒绝。host_01编译因TB FullRuntime聚合初始化触发explicit构造-Werror失败，未运行DUT；仅TB初始化修正后_02 PASS，失败保留。host fences及当前wrapper admission/session/request/predecessor-done/adapter_pending_zero仍受控，helper仍离线，不签同硬件runtime。

冻结完整口径401/401 pair，current378/401、manifest/receipt递归引用1379/1402。23处live差异逐项披露：catalog17、_06/07/08 TB/runner6；五个选中wrapper DUT各同一SHA。12选中guard串行、child0/trigger null，194实际policy符合原帽。shell oracle0.166257s/host run0.145235s无child RSS/policy，peak null、资源观测完整性false；fixture/-MM只签配置。

交付索引30项SHA：`2dde48c8e037f000b804e2c0a0a437038a981e6947ee87f34f19fbf884796eec`。详见：
- `project/E003_production_chain_closure/experiment_results/runs/R003/executor_managed_query_milestone_20261013.md`
- 同目录`executor_managed_query_deliverables_20261013.json`、`executor_managed_query_verification_20261013.json`、`executor_managed_query_history_20261013.json`、`executor_managed_query_catalog_delta_20261013.json`

下一步按新CLOSE合同继续完整A/K的真实结果/Host消费、CLOSED及待新准入，并保留所有各自权威高水位。当前query取消用例前LPV已实际排空，不能签活动LPV清理；静态确认旧LPV `transport_abort=cancel&&service_domain_drained`仍清私有framing/FIFO，managed整链须分离新启动与旧半帧/返回所有权后才扩大证据。本轮不把old route可达当真实旧END/返回不丢失。

LAP1硬件/8-4 action/F10/source AR-F9/全部修改入口/合法Q lease、独立executor HLS及LN/hub/唯一软件退休/Q/full13BO仍待。C009/C013部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。无重工具运行，无新agent/HLS/OOC/P&R/上板/预算，G2338.224019s及全部原帽保持，5172s不重启。
