# 当前工作：LNQ0单实例LN→Q→Wi→G→Q→Down有限连接

[LNQI0主机预检已接纳](../results/measurement_first_LNQI0_review_20261014.md)：AT041真实canonical与AT035 actual-r2的四个非AUX完整BO及Wi/Down六段载荷相同；AUX仅头内layout/build32B不同，原数学/gold可复用，无权重重排需求。两种416B身份仍需分别保留；AT041继承BO表未绑定实际AXI，不能作为RTL PASS。

当前[D-M004-LN-QAR-INTEGRATION-01](ln_qar_single_chain_stage_20261014.md)选择LNQ0四行有限同runtime链。保留AT040 LN producer/monitor/hub与83项生成物，接AT035唯一quant/dualA/resident/strict W；完整source-query/grant与外部Q原子受理，真实NORM store重读，响应消费/物理R债后release。按合同重建无冲突BO表及有限DUT身份/地址拒绝边界，不预装中间值、不重复Q。

一个连接候选、最多两轮有因修正；static→≤120s新组合真实前缀pilot→有据成本准入的四行full。pilot不要求在120s内完成整行LN；必须有真实语义进展，心跳不续命。联合结果/成本仍NOT_RUN/UNKNOWN，旧墙钟与周期不能相加代签。

A002唯一实现/工具，A001集中审核；代码E002/experiment、证据E005/R001，旧记录不变，不新增agent。单重工具，CPU0–3/nice19/idle、MemAvailable>192GiB，static24GiB/1800s、RTL8GiB/3600s/40Mcycles、pilot/语义停滞120s原帽保持。无新HLS/OOC/P&R/上板/预算；G2338.224019s仅OOC余额、5172s不重启；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。普通Q/L多窗口物理、全模型/生产请求/恢复与联合资源/物理时序未验，M003/M004开放。
