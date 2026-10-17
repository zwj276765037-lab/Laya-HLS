# 修订21 AT378：W错误后独立stage恢复限定接纳

2026-10-16；D-M004-REV21-AT378-01；A001→A002；回复`m004-rev21-at378-w-error-discard-recovery-20261016`。修订21继续running/unassessed，不收束、不封账、不增加预算。

[增量审核](ln128_wprep_q16_rev21_at378_review_20261016.json)254项通过，148项冻结/fixture、两笔原guard及11条实际政策一致；原AT352–377的51笔账与已核身份保持。上/下层、W服务/cache同AT368，只有TB变化。实际构建snapshot及同一次运行两个终标、child0/null、无Fatal/Error均已核；静态45.80028396472335s、RTL286.08507612906396s。

接纳`PASS_SCOPED_W_ERROR_STAGE_DISCARD_THEN_REAL_LN_ROW0`：真实LN128→W末q0 SLVERR，三路R=24576/24576/3072及AUX8完成、零STATE1/Q、131072 norm保持；TB通过生产stage_release_fire直接显式discard，随后以id300/source epoch2刺激同一生产入口，无reset，新增gamma256R/source64R/norm1024/64B及生产退休数1。逐W握手的独立norm检查仍在运行，不只是复扫先前内存；恢复首行逐位通过。

边界保持精确：释放端点直接断言的是cmd_ready、stage IDLE、退休0及writer_debt_zero；W三路以实际响应计数取证，不扩写成所有内部债逐项断言。id300/epoch2为输入刺激，未另逐项核完整回显。后继止于LN row0，**没有再次成功W加载、Q16或完整请求恢复**；不签父wrapper/sequencer的tensor_release/e/e+1/e+2和请求发布。先前W错误三拍保持仍只签实际字段子集。

日志row255已定位为TB在生产退休计数128→0时无条件打印8bit的`stage_retired_rows-1`，不是生产行事件；终点直接断言生产退休1及新增真实工作量。后续若编辑同TB，可顺手区分release诊断，现无需为打印单独重编/重跑，原日志不回写。AT377报告已按上次审核更正非法未接受、保持字段、BVALID/RVALID延迟及Q16无AXI B，确认这些文档更正不改变原冻结实验。

累计53guard/352已观测政策，static **1070.59817872010170202/1800s**、RTL **2827.7368308156728665/3600s**；剩 **729.40182127989829798s / 772.2631691843271335s**，host完整UNKNOWN，AT361未观测policy/RSS仍UNKNOWN。原FAIL/COST_STOP保持；新一次运行帽不得大于剩余总额，未知路径仍先原≤120s pilot，不借旧余额。

下一步仍优先父层实际W/Q固定委派的有界短例，及真实接口可合法施加的交接。没有可独立施加的pending/rsp/done/legacy阻塞按实际接口保留未测，不force内部债或增生产接口；不再为已闭合的W错误→LN row0恢复重复完整LN128前缀。父完整128→A16同runtime未验且无可据本例外推的成本上界。阶段交付/成本出口集中回传最终身份、父层实际范围与缺口，随后衔接[矩阵接口](a16_matrix16_interface_decision_20261016.md)的独立实施合同；当前不使用矩阵预算。普通修复连续推进，无需确认收信或用户逐项批准。

审核消息`m004-rev21-at378-scoped-stage-recovery-review-20261016`已于`2026-10-15T21:53:33.558723+00:00`送达原工程会话，turn`01a14112-00a9-7e33-9a64-f3cbfbbff010`；无用户转发或确认事项。
