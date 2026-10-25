# 修订21成本出口与修订22正式矩阵合同

execution_state: running
stage: M004_revision21_closeout_revision22_matrix_contract

2026-10-16；M004/SM004 running/unassessed。[修订21成本出口](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at383_closeout_decision.md)已定：AT368独立真实LN128→W→首A16和受影响局部错误/恢复按原SHA/断言范围接纳，AT379补上层stage done未消费屏障。AT382当前父top实际O3展开及真实row0通过；AT383固定120s只退休两行，COST_STOP，父动态W/Q/A16和完整父同runtime仍OPEN。

905项增量核验，744冻结/7guard/46政策通过；最终60guard/398政策，static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s。余static605.50865154154599468s/RTL323.3846215400844935s封存，不转后继；host完整与AT361未观测policy/RSS仍UNKNOWN，旧FAIL/COST_STOP保持。另核父TB只是LN阶段：W响应关闭、STATE1绑零、LN128即结束；延长原TB不能验证W/Q，后继父链须补真实peer与相位checker。

[修订22正式合同](../../results/m004_simplified_start_20261014/a16_matrix16_rev22_decision.md)采用已审核唯一matrix服务、A16 claim/SL_MATRIX、同步A/PS单口及完整rows16/K1024/N3072 STEP16。独立真实主例从LN128→W冷载→Q16→首TN8，核128stripe/512行组/128final/16笔B及ps_retire；前4行独立gold、后12行传递/覆盖分开。首TN8不发父完成/RAW/FINAL。父完整链欠账继续保留，不作为所有矩阵推进前置。

新独立host300s/static1800s/RTL3600s预算，未知路径先≤120s；新组合真实LN16与同版W/Q16/首TN8局部完整样本支持合同2.5倍计划式≤1440s且余RTL≥1800s时，自动一次≤1800s主例。全项目单重工具/CPU0–3/nice19/idle/内存及语义停滞保护不变。普通修复连续执行，不原样续跑AT383、不启动HLS/OOC/P&R或新gold，不新建agent。修订22实现/动态结果待工程交付，完整模型/Host-HBM/联合物理未验。

实施派发`m004-rev21-closeout-rev22-matrix-dispatch-20261016`已于`2026-10-15T22:16:27.904307+00:00`送达原工程会话，turn`01a141a3-5df7-7db2-a8a6-7994715a150f`；保持既有工程角色/模型配置。送达不表示新RTL已完成，当前新阶段实测待交付。
