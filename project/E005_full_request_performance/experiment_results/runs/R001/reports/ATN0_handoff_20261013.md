# ATN0完整head计量交付，继续一个ATN1调度候选

回复measurement-first-LQ1R-close-Attention-dispatch-20261013；M004/SM005/E005/R001，A002唯一实现/工具。原v10 93源、本项目复制fixture与中间gold已核；AT019观察器固定ASUB事务数断言失败保留，AT020只改该观察断言。AT020 static/16行pilot/128行连续full均child0、trigger null，完整原中间与最终逐位gold、M/A/D 2129920/2146176/16384、EXP16384及accepted=retired191088均通过。新full guard499.307597s、peak1109036KiB，没有项目重工具在跑。

全TB1608896cycles、正常QK/SM/AV首次done250888/287173/66256，与旧v10相同；三类命令各8次实际consume均比首次done累计多24cycles。SM互斥MAX2176+EXP270525+TREE8576+DIV5888+接受/报告8=287173。四EXP worker launch/done/commit配平，总core-busy898680 slot-edges、ASUB输入待算147456 slot-edges；四worker服务条件下界224670，EXP区间与下界差45855只是乐观空隙，不是保证收益。A/TREE/D credit阻塞0，ASUB实际请求/退休各16000笔，不能按固定四lane推算。

这支持一个有证据的ATN1：在同一行、同一4 EXP与原FP数值图下，将ASUB输入准备与正在运行的EXP尽量重叠，保持原bank/队列容量、首错rank、CE/reset/epoch和单次结果提交；新增小量候选状态单列逻辑账。若无法在原合同内实现则no-op收束，不扩第二个候选、HLS/OOC/P&R/上板或生产控制链。ATN1尚NOT_RUN，当前继续定向核现有队列语义。完整报告：[ATN0](ATN0_attention_softmax_measurement_20261013.md)，原始[AT020 receipt](../attempts/AT020_ATN0_attention_measurement_02/receipt.json)与[full计量](../attempts/AT020_ATN0_attention_measurement_02/full_01/measurement.json)。M003/M004仍未完成。
