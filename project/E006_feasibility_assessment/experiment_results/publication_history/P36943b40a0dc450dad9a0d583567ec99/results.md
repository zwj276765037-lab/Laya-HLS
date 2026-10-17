# E006 关键结果摘要

AT071原W接点探针FAIL；AT072仅修TB采样相位后真实同top短探针PASS。AT073最后正常full在cycle375074完成LN/Q/Wi/G/Down前缀及Down 256 AW/W/B、TMP 64KiB总窗口（16KiB有效写入/gold、48KiB未写哨兵）检查，随后`FFN0 Down-to-residual retirement gate did not retain ticket` Fatal；child0、guard trigger null不覆盖功能FAIL。残差未受理、HIDDEN结果与655360B保护未测，独立合法反压完整样本未做；3/3 full累计4974.979578s。Down cfg358881→首次done375066端点差16185cycle；至实际消费375073端点差16192cycle、两端采样都计入16193cycle，属于失败前缀，不能作为完整FFN延迟。`DOWN_MEASURE_LOAD` Down窗口W/AUX R_not_ready均0，未动态覆盖跨拍RVALID保持；Wi窗口计数在阶段切换时重置。详见`project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_AT073_down_retirement_fail_20261014.md`。

诊断联合综合AT074/075/077各在31.493478/47.201637/48.657160s结束于RTL展开错误，均无网表/资源/时序。前两层分别是top端口网络类型与hub第一处动态几何循环；AT076受影响portal短测PASS（27.401092s），AT077又停于同hub另一处动态相交检查，涉及最多约2016对64bit区间。A002已向A001提交架构边界问题，未擅改hub请求时序。可核对的已守卫预算累计：full4974.979578s、short176.874256s、static390.634458s、synth127.352275s、route0；AT066–069部分早期原始运行缺统一wall计时，短/static合计只作为已测下界。完整账见`project/E006_feasibility_assessment/experiment_results/runs/R001/reports/M005_budget_ledger_after_AT077_20261014.json`。阶段C v4在150MHz/10GBps条件下6.919–8.133s仍是整模模型预测，当前没有匹配CPU/GPU基准或部署收益实测。


---
Published: 2026-10-14T05:01:01.974269+00:00
Publication: P3c3cecbaa5494e768d1d19f149f276cf
