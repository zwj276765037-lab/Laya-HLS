# ATN1阶段交付：完整head与同DUT协议回放

M004/SM005/E005/R001；A002。阶段事件`EV_SM005_ATN1_SCOPED_RESULT_20261013`已登记，E005三摘要和A002状态已同步；当前无owned重工具。请求主控按[D-M004-ATTENTION-MEASUREMENT-01](../../../../../../mission/attention_softmax_measurement_stage_20261013.md)集中审核限定候选并选下一阶段，普通运行无需新审批。

AT021唯一同资源候选完整128行正常head逐位gold、原全部M/A/D/EXP工作量及191088受理/退休配平PASS。ATN0→ATN1：SM首次done287173→265084（−22089，7.6919%）、实际consume287197→265108；QK/AV不变；三段首次done和604317→582228（−3.6552%），全TB1608896→1586807（−1.3729%）。SM净差只在EXP互斥区间；四worker core-busy898680 slot-edges不变。AT021 static/pilot/full guard全部child0/trigger null，full482.110123s、peak1108904KiB。

AT022与AT021的DUT SHA同为`11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`，只变协议TB/runner；static及PROTOCOL=1 16行RTL均child0/trigger null。实际命中ASUB pending及四项ready未分发，新增全部状态在CE低8拍保持、reset清空；原M/A/D/EXP活动、六首错、合法重载/chain及账本210966=210960+6和末尾16行gold PASS。协议运行226.536195s、peak955724KiB，不能与正常full比性能。五段guard串行，63条实际policy样本合规。

新增179bit包含四项值/key数据；源码的一批接受→A返回→按完整key唯一分发→EXP一次提交关系支持行完成前债务排空，正常full数值和定向CE/reset是动态佐证；未作内部槽位逐边沿形式证明。物理FF/LUT/Fmax、生产请求、13BO及M003/M004仍未验。完整解释与链接见[ATN1工程报告](ATN1_attention_softmax_comparison_20261013.md)、[定向冻结/guard核验](ATN1_evidence_check_20261013.json)和AT021/AT022各`receipt.json`。本次不追加第二候选/HLS/OOC/P&R/上板。
