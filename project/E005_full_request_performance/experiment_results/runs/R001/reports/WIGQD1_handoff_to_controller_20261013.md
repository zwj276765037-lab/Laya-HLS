# WIGQD1 AT032有限完整链结果，供A001集中审核

回复 measurement-first-WIGQD0-review-observation-dispatch-20261013。A002按D-M004-WIGQD-OBSERVATION-01仅执行一次新full；同AT031 DUT、fixture、gold和响应策略，仅观察TB变化、另冻结runner。static/pilot/full均child0、trigger null，full1750.811857s、峰1504888KiB，原成本准入估计2871.684102s<3600s。

正常B1/S128、batch0/row0四行同runtime连续链全部原独立gold和真实交接PASS：预量化LN_FFN外部A→Wi resident 20992F32/671744PS、1312 AW/W/B→实际DDR/reader 1312R→G 10496 GATE F32、656 AW/W/B→量化656R/328组→同dualA epoch2→Down 335872PS/4096F32、256 AW/W/B。两段末B、A/W lease、7拍保持及一次实际done消费通过。最终327680B DDR全扫：83968B Wi、41984B GATE、16384B Down逐字节gold，其余185344B哨兵及written标记无破坏。全TB205314cycles；G cfg101339→结束103975，Down cfg189122→消费205313为16191。旧WI0/GQD0独立周期未相加。

旧AT031最后G接受cycle101339后的观测空窗在本次显出真实进展：reader cfg101341、首AR/R101343/101347、四次row_done、G算术、GATE首/末B110109/159328、量化R159341/161680、新A publish162045、Down完成。旧COST_STOP原样保留，不写成旧DUT死锁或旧full通过。

103行manifest/101不同冻结路径；相对AT031只有第57行TB SHA改变并新增runner，206份source/frozen bytes/SHA与tool身份全匹配。3段guard实际policy31/9/9全部合规，状态快照通过冻结正则检查而不会续命。原`WIGQD_BOUNDARIES A_publish=290`是Wi前置A发布，不能用于新量化A；应看新增真实marker162045（bridge消费后ready观察162057）。

报告与可复算证据：
- project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_observation_result_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/raw_full.log
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT032_WIGQD1_observation_01/verification.json

E005三摘要及A002实际状态已同步，当前无本项目重工具。请求按有限四行normal链审核并集中选择后继；完整全模型/生产13BO/请求与恢复、联合资源/物理时序及M003/M004不关闭。不另启候选或重工具。
