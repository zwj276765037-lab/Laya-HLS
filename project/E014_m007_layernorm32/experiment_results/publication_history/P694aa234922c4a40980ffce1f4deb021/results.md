# E014：关键结果摘要

完整plain128与真实gamma128全部逐位/周期通过，有限停顿/局部错误排债/恢复通过。
现版engine2799427b…c263；原full_reference.py、模型/gold未改，仅调用原局部LN。

| 指标 | 结果 | 证据 |
| --- | --- | --- |
| 原encoder00/27各128行 | 原局部LN与独立逐步重组逐位一致；encoder27+原gamma最终等原保存final_norm全部524288B | runs/R001/attempts/AT001_original_ln_reference/fixture/report.json |
| 原gamma | GGUF offset2059616/4096B，SHA0287e235c9744bbf9f36e9eae1e36f9fdebe1b5732b7b3ac301f1659b9113844 | 同AT001 |
| 精确div1024/sqrt | 各13575独立向量+4复位后恢复，逐位/错误位全通过；延迟1/25拍，目标≤16/32 | runs/R001/attempts/AT003_scalar_rtl/work/report.json |
| hold/reset | div3540/sqrt31661 held cycles完整数据/tag/error稳定；实际pending/busy共同reset后30拍无旧返回 | 同AT003 stdout |
| 运行身份 | 实际frozen源SHA及xsim.dir编译库运行前/后清单；scalar RTL SHA7fffa46f…84be | AT002/003 |
| full256 sharedFP AT006 | 原数据7/10级树+mul共12链/5496实际树节点逐位；phase6/1/3依赖8/9/8拍；mul/add各64真实信用满阻65、held及在途reset新gen通过 | runs/R001/attempts/AT006_phase6_dependencies_rtl/work/report.json |
| LN-exp银行AT010 | 全256bank×32F32/32768B；35写/41读请求、同址读优先、异ctx真并行、held响应/ack阻rebind、旧身份、在途reset和新gen保留payload通过 | runs/R001/attempts/AT010_ln_bank_rtl/work/report.json |
| 完整plain128 AT042 | 全131072最终F32、261888树节点及全部delta/square/norm/七stats每行/真实bank逐位；first322、done可用16612/实际退休16618拍 | runs/R001/attempts/AT042_ln_plain_full128/work/report.json |
| 完整真实gamma128 AT043 | 原encoder27+final_norm_w并等原saved final_norm；同样全量逐位；first330、done可用16620/实际退休16626拍 | runs/R001/attempts/AT043_ln_gamma_full128/work/report.json |
| 无外部停顿阶段周期 | 输入rowII严格128、每输出row间隔≤128；pass1/2/3=113/197/42或50，树尾80，固定scale含调度2/sqrt含调度26/inverse32 | AT042/043 stdout/report |
| 真四ctx/有限停顿 AT033 | 原8行gamma全量逐位；实际4ctx占满并阻第5行，1865拍held输出，add/mul峰27/54，最终真债零；本例a097…仅与现版两处idle系数准入不同，active流相同 | runs/R001/attempts/AT033_ln_four_ctx_finite_stalls/work/report.json |
| 协议/共同reset AT038 | 缺/partial/非finite/错model gamma、旧gen、同时gamma_begin/cmd只接受loader；实际FP在途共同reset后新gen完整4行通过；held done阻release | runs/R001/attempts/AT038_ln_gamma_arbitration_reset/work/report.json |
| 局部数值排债 AT039–041 | 输入Inf/平方溢出/树第1级溢出实际观察后3/9/9拍done；无输出，随后不reset换gen正常完整4行逐位；保存stage/level/row/node | 对应work/report.json |
| 有限存储 AT031 | gamma唯一4096B；metadata/holding/tag含两标量44761bit/5596B≤8192B；测试壳恰一FP256/DIV8/LN-exp | runs/R001/attempts/AT031_ln_compliant_storage_ledger/work/report.json |
| 小sqrt OOC AT044 | 综合/opt：347LUT/340FF/0DSP/0latch/0blackbox；WNS+0.344/TNS0，WHS−0.027/THS−2.248ns、166hold端点；完整约束检查零缺失 | runs/R001/attempts/AT044_ln_sqrt_only_io_ooc/work/report.json |
| 小div1024 OOC AT045 | 综合/opt：195LUT/130FF/0DSP/0latch/0blackbox；WNS+0.605/TNS0，WHS−0.027/THS−0.035ns、2hold端点；完整约束检查零缺失 | runs/R001/attempts/AT045_ln_div1024_io_ooc/work/report.json |

实际done退休包含额外5拍done保持；均满足16704拍。scalar OOC为3.333ns/uncertainty0.1ns、全部非clock输入/输出delay0.5ns；仅综合/opt，hold违例保留，不能签物理300MHz。

最终实测reference1.720864/static95.861117/RTL134.939409/OOC297.863061s，均在独立900/1800/2400/900s帽内；另AT018墙钟UNKNOWN独立保守扣120s，static预算扣215.861117s。OOC含原失败120.214213s。
保留AT007保留字/AT008错误build入口、AT015/016解析器失败；AT018提前释锁和UNKNOWN费用、AT020重叠审计只保留静态范围、AT022 harness争锁断言失败均不回写。AT026–029真进程反例通过，最终guard收尾已实核；AT031为合规位账。
AT036两叶批次COST_STOP且旧XDC不支持remove_from_collection、131输入缺delay；其旧timing无效。AT044/045分别≤120s、修正XDC，未提高原cap。AT046最终源码/archive/snapshot/位账检查通过；完整证据runs/R001/release_evidence_v1.json，交付接口与边界见runs/R001/ln05_handoff.md。
研究判断：完整S128功能/周期与本段协议范围SUPPORTED；小叶setup正、hold仍FAIL；整体物理时序未验证。

适用范围：Vivado2025.2行为RTL与两小标量综合/opt。原16行tile/全模型首错、LN→quant→matrix、整60次LN、父图物理共享、整体LN综合/P&R/板测仍未验证。
