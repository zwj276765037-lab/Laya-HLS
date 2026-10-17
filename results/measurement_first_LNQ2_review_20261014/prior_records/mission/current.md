# 当前工作：LNQ2运行文件准入与一次同DUT冷启动重放

[LNQ1停止审核](../results/measurement_first_LNQ1_review_20261014.md)核定AT048 static PASS、full COST_STOP_INVALID_RUNTIME_ROM_STAGING。7份冻结LN ROM在实际xsim目录全部缺失，原日志8条读取告警；末观测marker149，尚未到LN source AR。没有新END/PUBLISH或Q/Wi/G/Down结果，不能判DUT死锁。旧LNQ1一次full额度已消耗，AT047语义FAIL和独立局部PASS保留。

当前[D-M004-LN-QAR-RUNTIME-01](ln_qar_runtime_replay_stage_20261014.md)选择LNQ2：保持AT048全部DUT、两份TB、数据/gold/真实BO和响应profile，只修Tcl/launcher、运行包及只读启动核验。先新目录部署7份ROM，实际每次xsim启动前verify-only核源/目标bytes/SHA及全部fixture/plusargs；缺失/错SHA负例须在spawn前拒绝。已有工程helper只是host准备，不代签新RTL。

static之后，≤120s冷前缀必须观测真实LN source AR及R；成本有据且在3600s内，才准入最多一次新冷full。full前允许一次有因准备修正（总至多两次static/两次短前缀），无需逐项审批；不改TB/DUT。新full一旦启动即消耗额度，任何失败/停止保存原证据交付，不追加full。新结果NOT_RUN，送达不等于执行。

A002唯一实现/工具，A001集中审核；代码E002/experiment、证据E005/R001，不补旧AT048目录或收据、不新增agent。单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB；static24GiB/1800s、RTL8GiB/3600s/40Mcycles、前缀≤120s、语义停滞120s。原帽/guard保持，无新HLS/OOC/P&R/上板。G2338.224019s仅OOC余额、5172s不重启；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。完整普通多窗口Q/L、全模型/13BO请求/恢复、联合资源/物理时序与M003/M004仍开放。
