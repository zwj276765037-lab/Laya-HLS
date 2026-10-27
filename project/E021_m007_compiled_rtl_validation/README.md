

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E021 · m007_compiled_rtl_validation

关联：M007 / SM012

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E021：D37 完整30层实际结果

execution_state: completed
verdict: supported
applicability: R005修复版参数0/kind7/local0原输入、同一runtime/一次BEGIN正常全图PASS

唯一正式完整运行guard/driver均PASS，正常模型rc0、driver/guard0、trigger=null。单次实耗10101.230974940001s（约2小时48分21秒，功能仿真墙钟），CPU9913.698424s；原成功收据cycles=13036119，BEGIN=1、30层/120矩阵/60LN/61VECTOR/28GEGLU、69632B输出/1真实tail_commit/1DONE消费。782个连续成功段中480个真实head成功，全部原checker无Fatal/Error。

全部30份真实H共15728640B/3932160F32，每层4096唯一地址、独立accepted trace重建一致，全部逐字等于原独立参考。finalLN/type各524288B/131072F32和4096唯一trace全同原gold，实际银行断言全通过；SHA分别6501eb1e…和9f1eb1d4…。两Decision H SHA44ea5ccb…与2403ecaa…；544组尾部69632B全同原tail544，SHAa8698e55921b0300643a01f63bb38abc52e026af7251b526f02bddfbd6d9536f。两FC1均16384真实写/ACK且closed/success/published=1/debt0后才FC2。60条实际LN命令gamma序列55个0、1个1、4个0，60次实际LN成功各issued=written4096。

最长层376.578261544s，最长成功段78.948596365s；原Encoder27 LAYER_END→finalLN→type→Decision0preLN整段27.901888213s；最后Decision1→全部真实尾写/flush/延迟commit/heldDONE消费/idle/正常退出0.394367401s。1005次实际模型线程样本均1；aggregate RSS峰62684KiB，MemAvailable最低466978148KiB，资源保护未触发。

参数0翻译PASS48.089340662s，fresh741TU完整构建PASS246.065725911s，各批≤120s；成功只读main派生61.398219224s。两次前置静态预检失败（生成优化别名和printf格式匹配）原证据保留，未发生RTL pilot或额外完整重试。它们的实耗UNKNOWN，预算另保守预留240s且不伪填为实测。

终审重核3200个唯一执行身份、全部实际值/独立trace及归档成员PASS。2262个已知PID/start无live/无zombie、实际policy样本0不匹配；2个瞬态未采样与未guard准备/作者/审计policy范围保持UNKNOWN，start身份缺失0。

R005封账：static实测372.653188777040s，RTL10101.2

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 34 |
| R002 | [本批结果与证据](experiment_results/runs/R002/README.md) | 11 |
| R003 | [本批结果与证据](experiment_results/runs/R003/README.md) | 1 |
| R004 | [本批结果与证据](experiment_results/runs/R004/README.md) | 6 |
| R005 | [本批结果与证据](experiment_results/runs/R005/README.md) | 2 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
