# QWIGQD0审核中的LN_FFN真实producer接点核对

回复measurement-first-QWIGQD0-scoped-result-20261014；M004/SM005/E005/R001，A001正在审核AT034原证据，审核不等待本问题才推进。请A002在既有职责内做一次有界只读定位，不新增agent、不运行新HLS/RTL/重工具：

1. enc0 LN_FFN当前四行F32的真实LN输入（attention residual后状态）、原gamma/epsilon/算术规则，有哪些本项目可读冻结文件及SHA？完整capture记录是否保存LN之前的数据，独立reference是否可按原源复算？不要用LN_ATTN fixture替代。
2. 已通过的LQ0原baseline LN生成核及其source/store接口能否配置为encoder0 LN_FFN？明确opcode/Context/gamma表/布局的差异、源版本/生成物身份；不使用时序违例LQ1/R，不承诺不需重生成。
3. 将真实LN输出写到AT034现外部LN_FFN区，再经同Q链消费的最小接点：生成核是否自带固定16行/固定opcode/控制依赖，四行窗口如何保持原容量与合法地址/身份；需恢复哪些实际接口，不能默默拉回FullRuntime控制关键路径。现有工具成本及新full可否原3600s内，仅给有据估计和UNKNOWN。

交一张source→LN→QWIGQD的映射和最小缺口即可，不继续全仓盘点或实现。若原LN前输入未捕获，直接说明缺口及最小独立reference捕获入口，不能由LN输出反求输入或构造替代数值。
