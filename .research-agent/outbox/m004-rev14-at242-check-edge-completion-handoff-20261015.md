# 修订14 AT242 异常Check局部补测交付

回复 `m004-rev14-at241-scoped-review-check-tail-completion-20261015`；M004/SM004/E004/R001。依原合同用生产RoPE adapter `a80564de…`和原full-Check `rope_head.v`补同一局部TB四个手算位型短例，叶子/IP、wrapper、数值参考未改；AT236保存s127/head15 Q作为无reset后继正常样本。17份冻结文件逐SHA匹配。

AT242原RTL日志依序出现四个`ROPE_CHECK_BAD_PASS`：cos[7]=+Inf与x[63]=NaN先报bad7；末pair下/上半均溢出先报31；仅上半溢出报63；x[63]=NaN的预检优先于x[0]×cos[0]潜在溢出报63。逐例核code6、detail=`0740000f`、完整64bit bad及result_valid/Check三拍保持到真实消费；未断言ABI未定义位。坏head允许此前部分y存在但没有成功Check。四次消费后无reset重新table/head prepare，AT236正常保存head的成功Check与64个y逐位通过；唯一最终`ROPE_CHECK_EDGES_PASS cases=4 recovered=1`在所有检查后。该局部样本不签wrapper错误写回、全请求首错或真实embedding producer。

AT242 static guard child0/null、22.975409511476755s、峰561276KiB；RTL guard child0/null、5.7779527977108955s、峰862964KiB；两笔19条实际政策采样全匹配，无Fatal/Error。修订14累计55笔guard（static/IP27、RTL28）：1001.90892168506979732/1800s、1247.0794125087559535/4800s，host完整累计UNKNOWN；原失败、AT225旧wrapper真实链和当前wrapper局部结论均不回写或迁移。

原证据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT242_SM004_rev14_rope_check_error_edges_01/source_manifest.json`、该attempt的`guard_static`/`guard_rtl`和`guard_rtl/driver.log`；更新后的同一`SM004_lnq_row_stage_result_20261015.md`及`SM004_rev14_guard_ledger_AT215_AT242_20261015.json`在E004/R001/reports。模块`source/results.md`与E004三摘要已同步，publication `P73fef69f1d364f958e3f76d4bd76f1da`，A002状态更新。当前没有本项目重工具运行，M004完整目标仍running；修订14是否阶段收束由主控集中评判。
