# E006 关键结果摘要

AT064在同身份adapter＋真实ledger、受控Wi退休和tied-idle matrix ready下于13cycle通过局部入口，guard25.378452s；不代签联合链。AT065 static111.926796s、真实LN前缀23.505724s通过，第一次新冷full运行2080.617893s后在cycle358880/3588801ns于Down受理前四态断言Fatal，判`FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN`。实际时钟、negedge和TB语句均推进，`cfg_ready/ledger_ready/ledger_admitted/candidate_ready=1`，`static_ok=x`、`matrix_valid=x`；Down cfg、TMP写、末残差、完整gold/保护终扫均未达。guard child0不覆盖Fatal，runner为FAIL；不是DUT数值FAIL或已证死锁。

AT065冻结TB的`g_cfg_K`只在handoff gate_k连接处出现，无声明/驱动；handoff静态准入要求K=2624，是X的明确来源候选，修后动态回归仍必需。AT065 342条源身份、262文件来源及两个隔离运行副本、7冻结文件/9工具/80库均逐bytes/SHA核对一致；7 ROM/63 fixture/11根preflight记录有效。三段policy共40条采样匹配。报告：`project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT065_down_admission_unknown_20261014.md`。

候选十实例可综合top仅已生成源码连接清单，未编译或动态验证；同top正常/不同反压full、联合综合、place/route均NOT_RUN，物理LUT/FF/DSP/BRAM/URAM、关键路径、布线频率UNKNOWN。A003首版150MHz/10GBps条件整模6.919–8.133s并非实测，AT065没有完整链周期可校准。


---
Published: 2026-10-14T03:04:44.588058+00:00
Publication: P071897ad1cc341c88ffed07cf3601a12
