# Host与CPU尾部实现

内部记录ID：A008。

角色：engineering；小 mission：SM009；实验：E009。

## 当前合同

链接 goal、M、SM、E 与适用 AGENTS；说明要交付的行为和验收。

当前实际接续：M007/SM011 D-M007-SM011-TANH-G8-08 / E015 R001（2026-10-21）。E014/LN-05已冻结交付，不再追加工作。期望gpt-6.1-sol/xhigh，实际模型/effort未核实；runtime_id=/root/m007_host_tail_engineering。

先严格add3/mul4/direct-div12→原glibc单TANH→8lane/纯G。外部TANH≤160/II1与300MHz、G完整335872输出及全域首错/双slot真实银行另验；参考生成、功能仿真、综合与P&R分开报告。当前预算reference900/static1800/RTL3000/OOC1800s，所有compute/EDA持唯一m007_heavy.lock覆盖owned后代。写入仅vector_and_ffn新M007文件/source增量、E015证据及自身状态；共享FP/DIV/EXP/storage、A010矩阵和旧canonical/gold只读。

## 依赖、写入范围与资源

待定义允许修改路径、共享接口、资源预算及停止条件。

## 阶段回传

重要里程碑/异常/全局影响及时通过实际消息工具发给主控；详细证据留在实验目录。
