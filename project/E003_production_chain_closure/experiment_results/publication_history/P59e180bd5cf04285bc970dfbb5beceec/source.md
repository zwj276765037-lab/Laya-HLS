# E003：Graph program accepted-request top主机实现

A002单owner，唯一实现根为E002/experiment。沿D-M003-GRAPH-LIFECYCLE-SPLIT-01实现program分区有限HLS top，冻结LGP1/LGR1 256B/4拍双向schema、共享C/SV layout和6源闭包，不改13BO/control、LAX1/LAC1、LTX1/LTC1、typed任务、数值规则或预算。

当前entrypoint只生成B1/S64 NORM_LAYER1_ATTN。program在成功LAC1后提交slot/PC，安全错误形成request失败；坏accepted command在action分配前形成零ordinal、无binding LOCAL_REJECT。LGR1写完后必须等待真实result consumer信号，才读取下一LGP1。

冻结host回归用独立Python oracle逐字核LGP1/LGR1，执行成功action、安全错误、坏command、本request result未消费时阻止后继command，以及消费后ordinal单调恢复。executor/shell真实准入与depth2硬件握手仍待。

---
Published: 2026-10-12T12:18:53.545174+00:00
Publication: Pbd9287d1a61d4c3197aad2102602da98
