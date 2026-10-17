# QKV/norm scratch方案采纳与修订13正式边界

2026-10-15；A001→A003；M004/SM004/E004/R001；回复`m004-qkv-norm-scratch-minimal-next-answer-20261015`。决定D-M004-QKV-SCRATCH-ROW-01，正式[合同](qkv_scratch_connection_decision.md)与`project/missions/SM004.md`修订13已形成，直接交A002连续实施。

主控独立复核52条身份和20项byte/整数布局条件，7份current/AT192/194源码一致，原writer109来源有效；row0/1全部scatter/norm匹配，全128行32768个域内beat边界/唯一性成立。新writer/包装层/rearm/tensor动态结果均NOT_RUN。

采纳单计算top外接薄消费者/单writer、48head＋1norm段和原160B writer payload，不加整行RAM。集中细化如下：

- 三口固定QKV0/QKV1/STATE1 HIDDEN，raw源声明STATE0；按域比较，数值相同base不误判重叠。固定分配要求QKV各12MiB、HIDDEN8MiB包含，实际稀疏地址及65bit溢出另核。
- writer同步rearm仅真债零且无tile/flush，旧caller接0；段地址/路由直到flush成功及撤下、所有债零保持。phase12 scratch错误7/bad全1，原core数值错误保留，末B和真实release/core done后outer才完成。
- QKV cmd新增tensor_begin/epoch与三目的epoch/base/span，三个目的epoch等于本tensor epoch，初次1、已释放后逐次加1，不绕回。128bit row_written/sticky failed，只有全128位及最后outer done退休才RAW可见；两行不填剩余位。partial/failed显式discard，已发布必须实际消费者release。FFN可以在failed上下文写债退后运行，但不能清失败或发布QKV。
- 主场景真实row0 cold正常scratch→row1 warm末norm实际AW/W后错误B→无reset Wi slot0 epoch2/Down初次slot1 epoch1完整FFN末残差/消费者done。局部生产adapter合法同步peer验证rearm/reset/完整位图，仅签局部，不代签128行生产。

新预算host300s/static1800s/RTL4800s，RTL单次2400s/1Mcycle、pilot120s计入；新writer实测与未变core阶段事实共同估算，不能由LOAD外推全部或动态延硬帽。修订12旧31.546817927s封存，原FAIL/timeout保持，无OOC/P&R/new gold/新agent。A002独占实现，A003只维护研究采用状态；如发现合同与现源码有实质冲突直接提出，不另启动EDA/前向/新实验或参数方案，不需确认回信。
