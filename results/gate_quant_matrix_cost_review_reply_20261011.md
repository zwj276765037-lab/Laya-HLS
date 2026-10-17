# R-SM003-GQM-COST-20261011：接纳成本中止，保留完整链缺口

主控已核查`gate-quant-matrix-cost-stop-20261011`，结论见`results/reviews/SM003.md`的R-SM003-GQM-COST-20261011，证据快照`results/gate_quant_matrix_cost_review_20261011/verification.json`。当前组合与guard检查166/166条文件引用匹配，消息所列四项manifest/receipt SHA一致。

接纳gate_quant_matrix_parent_03组合TB static与一行G pilot PASS，接纳full启动前COST_STOP/started:false；同runtime完整G/Q→父matrix继续NOT_RUN_COST。源码确已将split真实fullA端口接matrix，并加入独立A/W租约握手计数；pilot在Q0/W/matrix前退出，不能签这些运行断言或完整数值。_01→_03冻结files只新增no-wave运行Tcl，不能将静态连接称为完整生产链通过。

成本已复算：11773/63.410458=185.663382 cycles/s，872918参考周期×1.10/当前速率向上取整5172s，超过3600s。_02/_03确无full工具产物。该结论支持当前拒绝启动；872918来自分立组件，是参考工作量，尚非已证明的组合周期上界，5172s也不是实测完整时长或硬件性能。后续摘要请使用参考/估计口径，保留历史manifest原字段。

_01按3476s分立墙钟估算进入full后，因组合速率不支持该估算，在591.128178s主动终止；原FAIL/sigterm_requested/child=-9及无full PASS记录保留。此为估算适用性纠正、未完成运行，未发生实际3600s超帽，也不能判数值失败；不可追改成未启动。

gate_split_progress_guard_03已补上recognized split前缀解析失败返回False的分支，1000次重复与3类旧格式/缺字段/非法字段不刷新，两次真实增加及其它合法日志通过。前次窄修复项在有界分类/主循环接入范围内关闭；无须历史full重跑，不宣称重新验证了完整RTL或真实120s杀进程。

继续现合同内多父、其余Q/L、LOAD、唯一持久hub/generated caller等独立工作，同时保留组合full为未解除的验收依赖。预算内可有界诊断启动开销与各真实阶段模拟速率，并优化执行/观测开销；保持DUT语义、工作量、gold、自检和保护。_03已no-wave，同一profile无新证据时保持COST_STOP；有实际改进或更有代表性的成本证据，冻结身份且保守估算落帽后再启动full。分立PASS、删覆盖、加帽均不能替代同runtime完整结果。

下一次在实质成本改进、同runtime结果或新的合同阻塞时交付即可；普通修复无需逐项主控/用户审批。L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。完整Laya加速器与尽量高性能目标、原模型/shape/数值/13BO、单owner/单重工具、所有资源帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板。主控本轮未运行工程实验或改实现。
