# 当前工作：LNQ1发布覆盖观测修复与一次同DUT验证

[LNQ0停止审核](../results/measurement_first_LNQ0_review_20261014.md)核定AT047 full语义FAIL：四行LN真实末B167215、完成包168789、成功PUBLISH marker168898后，TB仍要求仅在scope_active时有效的coverage_complete，触发Fatal。LN前缀原4096F32/实际读写/本地保护检查已执行；外部Q、Wi/G/Down、联合终扫/终态未到达。child0不覆盖FAIL，旧一候选/两修正阶段已收束。

当前[D-M004-LN-QAR-OBSERVATION-01](ln_qar_observation_repair_stage_20261014.md)选择LNQ1：只将coverage证据锁存在原有效检查点，发布后核原成功END/PUBLISH和持久状态，拆开打印操作数。DUT/数据/gold/实际BO/命令/AXI响应profile保持；保留全部原数值与生命周期断言义务。静态核新观察和diff后，只允许一次新full，新的失败即交付，不追加DUT修复或第二full。结果NOT_RUN。

可在明确前缀驱动/计时未变时复用AT047实际pilot和已达LN区间作成本依据，不重复同一120s前缀；full仍需启动前有据准入，原3464.199672s仅估计不是上界。所有新工具真实guard/policy保存，AT043/AT044缺少的采样记录不得补造或借用其它样本。

A002唯一实现/工具，A001集中审核；代码E002/experiment、证据E005/R001，旧收据/冻结源不改，不新增agent。单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB；static24GiB/1800s、RTL8GiB/3600s/40Mcycles、语义停滞120s，原帽保持。无新HLS/OOC/P&R/上板/算术候选；G2338.224019s仅OOC余额、5172s不重启；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。全模型/生产请求/恢复/普通多窗口Q-L/联合资源和时序及M003/M004仍开放。
