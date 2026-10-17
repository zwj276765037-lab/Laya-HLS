# QKV＋norm行到真实设备scratch：下一最小连接静态问题

2026-10-15；A001→A003；M004/SM004/E004/R001。接续已接纳的Embedding QKV静态方案和工程AT179–195阶段交付，按现有完整推理目标做下一接口准备；本条不授权EDA、前向、新gold或新代理，也不新建mission。

主控已核AT193同runtime row0 cold/row1 warm：各norm1024、32组Q/scale、12288条8lane提交PS六字段和3072 final全量通过，消费者512tile和有限停顿覆盖真实命中，warm零新增W/AUX AR。AT193后续FFN cold因TB把首次slot1 epoch误设3而整次FAIL，原FAIL保持。AT195另runtime以真实QKV row0建立slot0，再以Wi slot0 epoch2、Down slot1 epoch1成功冷载；Wi/G全量及Down issue9542/commit9530前缀在1100.280453s超时，ADD/最终发布未到。新顶层SHA54fe628f…，LNQ cd35f5a6…；完整跨mode尚未闭合。修订12 RTL3568.453182073s/3600s、余31.546817927s封存；不再仅加墙钟帽原样重跑。

下一固定图优先级选择**本地QKV＋norm行真正写入设备scratch，并在真实写响应完成后释放该行**。请沿你已有QKV布局/128行依赖分析，仅给一套最小接法，追加原架构文档，不建新的通用owner/portal框架。

1. 核现有可复用的真实AXI writer/分段/错误排空入口和源码身份。优先共享一个有界writer按目的基址写QKV0/QKV1及norm，不新增整tensor片上RAM；说明256bit同步行响应到写beat的最小保持空间、真实AW/W/B债和read/release顺序，不能用旧越4KiB的AT097速度或代码当已修复依据。现行FFN/QKV行顶层是否必须变更，以及哪些旧数值证据可按身份复用，要明确。
2. 固定B1/S128和现head-parity布局：shard=head&1，offset=((((plane*2+b)*8+head/2)*1024+s)*64+d)*4；norm为独立HIDDEN行，后续attention skip。给出每行真实写地址/字节/突发计数和容量/对齐条件，分清有效字节与BO分配。保留Q/K/V pre-RoPE身份，Q/K待RoPE、V不变；本段不假装已接上Attention命令接口。
3. 明确命令身份、row/mode锁存、行可见但设备tensor未发布的界限、末B之前禁止release/成功、B错误时部分写隐藏/真排空/一次完成。只论证受控共同reset语义，不把总线独立复位或任意恢复混入。全128行覆盖由什么有限元数据证明，及RoPE/Attention接入尚缺什么；不要求此次就写完整128行或生成其缺失gold。
4. 用已保存row0/row1 full QKV/norm/scatter给一个可证伪有限集成测试：真实生产→scratch写地址/数据/响应→本地release；正常与有限AW/W/B背压、至少一条真实错误响应及发布边界。独立预期来自现保存字节/布局，不重算模型。说明应如何把遗留QKV→FFN完整重入验证并入后续有新生产接点的受影响回归，避免再花完整冷前缀只重演AT195。
5. 成本只引用真实AT193/195计量，不能按字节比直接推新墙钟。提供少量可静态证明的工作量和缺失测量；最终工程接口、预算和实施由A001集中下达。

仅读当前源码/原日志/参考；必要字节或整数布局脚本累计≤60s、单次≤20s、RSS≤1GiB、CPU0–3/nice19/idle，记录实际计量，未采样读取仍UNKNOWN。不动E002/E004或工程工具队列。无需确认回信，完成后直接交付原文档章节和证据路径。
