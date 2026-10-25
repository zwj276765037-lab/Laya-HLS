# E007：实验状态摘要

- 用户暂停落实（2026-10-17）: AT023为最后已完成attempt；当前无本Laya-HLS owned综合/编译/仿真进程。AT020 OOC局部完成，AT021/AT022/AT023的xsim虽child0但Fatal，均FAIL_NUMERIC。原[33笔账](../experiment_results/runs/R001/guard_ledger_AT001_AT023_20261017.json)和原日志保留；M006/SM007仍unassessed。等待用户明确恢复，不启动TANH DAG或strict叶子修复。

- AT019当前增量: 直接F32除法8拍IP已取得单lane零黑盒OOC/DCP与16个定向输入同版RTL逐位PASS；原6拍版综合WNS−0.458ns、8拍版综合WNS+0.768ns，均非布局布线时序。TANH旧384拍与合同≤160拍风险已直接报主控，未实测新实现。
- 当前资源账: [AT001–019逐笔账](../experiment_results/runs/R001/guard_ledger_AT001_AT019_20261017.json)，26guard/198条policy零失配；参考1.2089934079995146s、static151.683702415000875s、RTL40.636666693004372s、HLS＋OOC829.946112331996125s；host完整UNKNOWN。原AT016黑盒失败保留。
- 当前接续: 按[D-M006-SM007-FP-DATAFLOW-01](../../../results/reviews/SM007_fp_dataflow_interface.md)改同一物理阵列的mul/add独立事务及QK七组/AV反馈，并把生产add的11拍修至≤8；独立divider工作不代签QK/AV或8lane SFU。

- execution_state: paused
- verdict: unassessed；strict expf单lane CPU/定向RTL、共享FP全宽局部接口、QKV银行局部RTL及单模块OOC限定PASS；原失败/中止保留
- applicability: M006/SM007，生产exp SHA `54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`、FP阵列 SHA `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`、QKV银行 SHA `15973d7a0d4a02485b770174d7f185c08f9b0fa9b22c97457eb857b5145d03fe` 及各AT冻结身份
- 当前阶段/运行 R: R001 AT001–019完成局部样本；按主控D-M006-SM007-AT006-01转入真实QK/AV与银行连接，F64 mul原样综合路线停止
- 进度与可交付部分: HLS II1/167拍，独立CPU16396＋200000位比较，生成RTL12样本；共享阵列AT009核256lane×65向量，AT013核QKV银行3plane×64bank×2048word，AT012/014分别取得F64 add/银行零黑盒DCP与综合资源/时序；均不代表完整head
- 阻塞、异常和全局影响: AT004及AT011 mul OOC超时无DCP；AT010于新派发后安全中止并计费；AT007 child0但有Fatal，按FAIL_TB记。mul未成使底向上完整leaf联结条件不成立；8lane及896DSP联合风险开放
- 资源使用: [26笔guard账](../experiment_results/runs/R001/guard_ledger_AT001_AT019_20261017.json)；参考1.2089934079995146s、static151.683702415000875s、RTL40.636666693004372s、模块HLS＋OOC829.946112331996125s；host完整UNKNOWN
- 下一步与负责人: A002继续接QKV、共享FP与真实QK/AV，保持单重工具和原预算；strict SFU问题交主控按实际子模块结果集中评判
- 阶段事件/审核: 本里程碑待A001范围审核，M006目标继续运行/unassessed
