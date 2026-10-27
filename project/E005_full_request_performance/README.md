

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E005 · full_request_performance

关联：M004 / SM005

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E005当前结果

## FFN4 AT063 Down W发布后有界停止

唯一冷full为COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD：2080.298887s、child−9、峰1036164KiB；末认可进展后120.092913s触发。LN源、Wi矩阵/reader、GATE、第二次Q及Down W三端口装载达到原局部检查，Down W发布于cycle358880。日志没有Down cfg受理、TMP实写、末残差或整链PASS；停止不能判数值失败或DUT确定死锁。原FFN4 full额度已用尽，M005阶段A有界短测定位；联合资源/时序仍UNKNOWN。见[R001 FFN4报告](experiment_results/runs/R001/reports/FFN4_AT063_bounded_stop_20261014.md)、[AT063原收据](experiment_results/runs/R001/attempts/AT063_FFN4_wi_descriptor_01/receipt.json)及[原guard结果](experiment_results/runs/R001/attempts/AT063_FFN4_wi_descriptor_01/guard_full/guard_result.json)。

## FFN3 唯一冷full语义失败（AT062）

host准备累计7.11s，完整包及五个受控坏包同launcher闸口通过；真实冷prefix 5224cycle/1AR/64R、guard28.990s PASS。启动前成本规划3536.346s<3600s，唯一冷full实际1696.154s/峰1036100KiB、guard child0/null，但原TB在cycle271096报`Fatal: WIGQD Wi reader cfg rejected`，判FAIL_SEMANTIC_WI_READER_CONFIG。LN源阶段PASS，Wi W三端口R 41984/41984/5248及Wi writer 1312 AW/W/B、一次done消费到达；G cfg接受后Wi reader零真实AR/R，G/Down/末残差/终扫NOT_REACHED。冻结TB重绑共享cfg_bo_base[0]为STATE1而reader仍用DDR区域，与reader的BO范围检查矛盾；本轮只读定位、不重跑。详见[R001 FFN3报告](experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)及[AT062收据](experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/receipt.json)。M003/M004继续开放。

## FFN2启动包有界停止（AT060–AT061）

AT060隔离运行包262文件/130020393B、四种启动前闸口的host结果通过；它的外部动态库身份不完整。AT061唯一准备修正对Bash loader运行ldd返回1，未形成新完整包。xsim启动次数0，真实pilot和full均NOT_RUN，full未准入；状态COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION。旧AT058/0

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 63 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
