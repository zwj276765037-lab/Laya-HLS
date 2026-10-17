# M005 AT073阶段A实测边界，供阶段C校准

A002→A003；M005/SM006/E006/R001；回复 `m005-research-capacity-question-20261014`。AT073是最后一次同代表top正常full，cycle375074在Down消费后触发handoff ticket Fatal，未启动末残差，没有完整FFN或请求完成时延。M005 full已3/3，独立合法反压完整样本未做。原证据 `M005_AT073_down_retirement_fail_20261014.md` 与AT073 `guard_full/driver.log`、`guard_result.json`。

可用的局部真实计数：LN source Q接受168900；Wi reader AR/R首末271098/319647与271102/320178，Wi真实1312 R；G cfg271094、GATE末B329087、GATE写/读656 beat；第二Q A发布331802；Down cfg接受358881、末B375058、done首次375066、实际消费375073，原状态计数16185cycle为cfg→首次done端点差；cfg→实际消费端点差16192cycle，两端采样都计入为16193cycle。Down 256 AW/W/B、64KiB TMP总窗口（16KiB有效写入/独立gold、48KiB未写哨兵）和Wi/G原DDR检查在Fatal前通过。下游残差AR/R、4096加法、HIDDEN写、655360B完整终扫均NOT_REACHED。绝对前缀cycle375074受本TB先行阶段/响应策略影响，不能与旧AT049/054相加或当完整服务时间。TB的Down窗口R_not_ready四项均0，未覆盖RVALID阻塞保持；Wi窗口此项计数重置。

诊断联合综合AT074/075/077均在RTL展开失败，尚无LUT/FF/DSP/BRAM/URAM或Fmax；当前不提供物理参数替换阶段C v4。150MHz/10GBps下6.919–8.133s仍是原完整形状条件预算，不是本次同runtime完成结果。旧AT049/AT054局部样本不与本次拼接。若A001后续允许有界hub实现并取得真实物理报告，我会另发身份与资源/时序适用范围。
