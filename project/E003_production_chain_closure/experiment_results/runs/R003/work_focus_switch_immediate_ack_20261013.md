# 立即换路执行状态（先交收束事实，算术盘点随后集中补交）

回复 user-work-focus-switch-immediate-20261013；A002唯一整合。已落实用户最新优先级，不启动executor HLS05/冷INIT生成或任何旧方向后继。当前无在跑重工具。此前真实启动的collector RTL01已按原guard自然完成，原收据PASS_SCOPED_RTL_TRANSACTION_COLLECTOR；实际FSM exporter、adapter/F10/sidecar、hub cleanup及same-runtime C仍NOT_RUN。此有限出口不扩大生产链范围。

保存而退出优先队列：
- 冷INIT：E002/include/laya_cold_table.h、laya_executor_cold_init.h、hls/control/executor_cold_init.cpp及受影响full_runtime/task_reservation/actor/top/source清单；FIRST七case host09已PASS，host08首case因新TB把queued input sentinel套进旧no_dispatch断言FAIL保留，09仅修该检查。全定义默认值新test/runner准备由A005在自然边界保存；未跑，executor HLS05未创建/未启动。
- 真实pending exporter：include/laya_executor_transaction_export.h与hls/control/executor_transaction_export.cpp，未编译/未接top/source/端口。A004 exporter后续只读委派因agent thread limit未启动，不能记已执行。
- collector：rtl/laya_executor_transaction_collector_v1.sv、tb/laya_executor_transaction_collector_tb_v1.sv及run_executor_transaction_collector.py；RTL01有限受控输入完成后不续跑。
- managed adapter坏帧隔离：host02原88+两独立坏帧process PASS；HLS01真实guard PASS/462.750790s/peak6140864KiB，实际生成top，但脚本最后复核live原文件时因root独立冷INIT改动full_runtime/task_reservation而FAIL。原FAIL保留；另immutable_generation_audit核809 frozen pair/8676immutable引用、精确27端口（8FIFO/24信号）PASS，只签冻结生成出口，不签RTL。无重跑。
- CLOSE/rearm与撤销后首END/INVALIDATE仍未闭合，暂停新增实现，不把未完成写成验收。

A005/A006已通过实际消息收到停止旧方向、保存现状及转只读算术盘点；A004交付后已不在live agent列表，向其followup/send因agent thread limit失败，未重启或新增agent。Root承接其Attention盘点，不让消息失败阻碍换路。

现盘点LN/Q（A005）、Q8 matrix/G/Down（A006）与Attention（Root），精确核冻结kernel、原真实输入/gold与runner/cycles/AXI/资源，独立算术实验允许受控driver，但不代签production/完整请求。新重工具均NOT_RUN，待主控详细合同。M003未完成，M004目标、原资源帽、G仅OOC余额和5172s不重启保持。

证据：R003/executor_hls_host_08、executor_hls_host_09、executor_transaction_collector_rtl_01、controller_transaction_adapter_managed_host_02、controller_transaction_adapter_managed_hls_01原收据与controller_transaction_adapter_managed_hls_01_immutable_generation_audit_20261013.json；共享模块source/design.md/results.md与A004/A005/A006/result.md保存原方向工作。
