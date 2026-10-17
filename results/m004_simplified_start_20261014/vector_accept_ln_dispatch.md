# M004：向量局部接纳，连续推进完整LN行服务

A001→A002；回复 `m004-vector-axi-finite-fix-handoff-20261014`。

AT101原log/guard、13项冻结文件、当前服务SHA、4KiB分段和finite首错实现均已核。接纳本轮受控局部服务：4096项正常6955cycle、反压7206cycle，8AR/512R/4AW/256W/4B及10条无reset连续命令；实际源/目的限制、错误排空与局部验证范围按报告。AT099继续只签未变单lane流资源；没有总线服务资源、HBM或完整图结论。向量段在当前范围收束，旧AT097不追认为合规。

现在直接进入 **SM004修订5的LN单行段**，仍M004/SM004/E004/R001；不是新mission，也不需用户再次批准。已读A003现有LN小节、你的叶子/fixture答复和原layernorm_row_arithmetic。采用一个ADD/SUB、一个MUL、一个DIV、一个SQRT，X/G与T0/T1奇偶同步bank共14KiB payload；固定行FSM、逐层排空，完整保留两棵相邻树与每步F32舍入。具体命令/32bit输入输出/统计值/首错/reset接口已集中写入SM004后半节。

先短探针测现存MUL/DIV/SQRT接收/返回及精确数值；旧标签长度、IP latency不是本接口证据，sqrt喂din1且未接reset。允许固定CE持续推进＋本地valid屏蔽，不必为了通用CE暂停引入框架。叶子满足后直接实现完整1024行服务，做原真实gamma0/gamma1的mean/variance/inverse/y逐bit、反压/连续行/reset/首错；gamma2真实final夹具未定位则保留缺口，不能由gamma1代签。normalize/gamma分扫须按原逻辑元素/子步骤挑首错，后列norm错不能抢在前列gamma错前。通过后一次同版完整行OOC。

新增LN预算：host600s/8GiB；static/IP准备1800s/24GiB（单次600s）；RTL/pilot1200s/8GiB（单次300s/1Mcycle，pilot120s计入）；一次完整行OOC1200s/24GiB。单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB保持，旧额度不回填。可运行必要独立局部叶子/行参考，不能用DUT造gold或重跑全模型参考。无P&R/旧FFN full/新agent。

你唯一写E002的layernorm_engine既有source/design.md、results.md、rtl/tb及必要runner，E004保留新证据；不要撤销他人修改或复制第二套活动工程。A003维护其来源分析。普通实现、IP编译、标签/握手配对修正直接继续，实质数值/职责冲突集中说明；目标是完整LN行与资源结果，不在叶子探针通过后停等另一个批准。
