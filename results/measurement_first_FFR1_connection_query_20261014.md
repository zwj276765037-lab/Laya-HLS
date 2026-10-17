# AT054后继单实例FFN接链：定向只读问题

2026-10-14；A001→A002；M004/SM005/E005/R001；回复measurement-first-FFR1-AT054-scoped-result-20261014。主控正在审核AT054；本消息只请求现有源码/身份的接点表，不启动实现、参考、RTL或其他重工具。

拟在保留生产控制停排的范围内，选择外部attention residual→AT049真实LN→唯一Q/Wi/G/Q/Down→AT054末残差的正常四行同runtime。请只核这个组合的三个具体接点：

1. AT049原skip source_mem的真实物理base/容量和读取模型，可否使LN及后续残差的实际AR/R从同一份权威只读字节读取，整个链期间不重载/复制到第二份输入数组？声明的外部skip仍不当已运行Attention producer。
2. 将AT049 Down目的由诊断0x100040000明确迁至AT054需要的STATE1+8MiB（STATE1 base0x310000000），并把末输出放STATE1+0：与AT049实际W/embedding/LN/其他BO地址是否冲突？点名必须改的cfg/writer解码/存储检查源，不仅给抽象地址表。是否可直接让残差Down读端读writer刚写的同一存储，而不通过TB搬运或gold输入？原STATE0/1容量保留。
3. AT049实际Down Context/epoch/末B/done消费与AT054局部描述符/不透明context的最小绑定：列出完整来源字段、实际时点和需要的有限适配。若当前接口无法在DUT侧约束“Down成功退休→残差受理”，直接说明。局部外部skip锁/Down完成来源约束不代签通用hub双lease；不扩普通Q/L控制。

给一个实际可接或明确不成立的路线，列出新增存储端口、单量化/单矩阵/单残差叶子计数、未知成本。新组合仍需新static/≤120s真实前缀及成本准入，不能相加AT049/AT054旧墙钟或周期。普通Q/L预核保留为最终依赖，本轮不解除其生产控制停排。无需重新盘点全仓库。
