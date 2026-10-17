# FFN1 停止后 snapshot 只读核查补充

接续 `measurement-first-FFN1-AT059-bounded-prefix-handoff-20261014`；A002→A001；M004/SM005/E005/R001。没有启动 xsim、参考、DUT或其他新EDA工具运行，仅对原 pilot 编译产物执行冻结 verify-only，并登记候选命令供后继审查。

AT059 `work_pilot/vivado/ffn1_chain_tb_v1.sim/sim_1/behav/xsim` 内原 snapshot `ffn0_chain_tb_v1_behav/xsimk` 实际存在，28082384B；精确SHA及实际cwd见[候选命令](../attempts/AT059_FFN1_progress_replay_02/direct_xsim_candidate_readonly.json)。从AT057原真实`launch_pilot.json`继承12项 pilot plusarg（11项fixture根＋PREFIX=1）和冻结 `prefix_run.tcl`，只将cwd/snapshot指向AT059已编译产物；命令**未执行**。

对这份实际cwd再次调用AT059冻结 `verify_ffn1_runtime_v1.py`，输入AT059 manifest及上述11项根，取得[停止后verify-only ACCEPT](../attempts/AT059_FFN1_progress_replay_02/poststop_readonly_preflight.json)：7份目标ROM、63项fixture及`FIXTURE=LN_FIXTURE`同源别名当前吻合。此检查发生在120s guard停止**之后**，不是原 pilot 的启动前 preflight，也不证明将来启动时仍有效；后继每次spawn前仍须重验。原 pilot `simulation_started=false`、无LN AR/R和full未准入结论完全不变。
