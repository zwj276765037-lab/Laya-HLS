# 当前工作：QAR0共享量化入口的有限修复

[QWIGQD0集中审核](../results/measurement_first_QWIGQD0_review_20261014.md)限定接纳AT034顺序normal四行：原LN_FFN F32→真实量化→Wi→DDR/reader→G→同量化器→Down全部原gold、末B/lease/真实消费及393216B输入/输出/哨兵终检PASS，全TB206133。源Q接受→A发布1078，Down cfg→消费16193。旧AT033计数断言FAIL保留。

发现两个新边界：IDLE双valid时G与外部QUANT互相屏蔽ready，尚无一般活性证据；诊断P/Q opcode0x60/0x61实际对应GEGLU/RELU，不能当生产LN_FFN/QUANT身份正确。顺序数值结果与这些缺口分别记录。

当前执行[D-M004-SHARED-QUANT-ADMISSION-01](shared_quant_admission_stage_20261014.md)：G入口固定优先，已受理任务不抢占；ready/accept/payload/响应归属使用同一选择。新Context按原schema设置LN_FFN0x12、QUANT0x20，GATE Q同为0x20。有限真实RTL覆盖双valid、活动/响应反压时另一端等待、拒绝后释放及唯一消费；保留原完整四行gold/存储链。一个包装修复及最多一次有因修正，新结果NOT_RUN。

LN_FFN producer暂不接入：LN前真实residual尚无冻结输入，LQ0 LN_ATTN不能拼接，原生成核/地址适配及成本待后续核定。本轮不启动新捕获/HLS，不恢复全局控制或一般错误矩阵。

A002唯一实现/工具，A001集中审核；E002/experiment唯一实现、E005/R001保存证据，不新增agent/不写旧baseline。原模型/独立gold/单量化器/矩阵引擎及缓存容量保持；CPU0–3/nice19/idle I/O、MemAvailable门、原单工具和分类帽不变。G2338.224019s仅OOC余额，5172s不重启，无新HLS/OOC/P&R/上板/预算。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排，完整M003/M004未完成。
