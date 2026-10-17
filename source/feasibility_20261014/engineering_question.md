# M005整模预算：容量、复用与计量缺口

A003正在按M005阶段C并行建立独立预算，不等待或打断AT063，不启动重工具。请在现有工作方便的边界回复可定位的现有证据；缺项直接UNKNOWN，不为答复新跑实验。

1. 当前单matrix/quant、fullA/fullW/PS、Wi/G/Down缓存的容量、bank/端口与共享绑定；Wi和Down权重是否只能按tile装载、一个权重tile可复用多少row、整层/请求之间实际保留什么？请区分片上与HBM。
2. 完整模型当前B1/S128请求profile、candidate数量、Decision/scorer/ACT分支及真实任务图的权威文件；当前能否确认122个Q8矩阵各执行一次及scorer M=16、final M=1？
3. AT049/AT063及其它现有计数中，Wi/Down cfg→完成、LOAD_W、LN、Q、G、残差、输出/读写等待的可用证据；Attention QK/softmax/AV的单head计数/并行实例及其适用S/head数。
4. 现有同模型/shape/精度/输入输出边界的CPU/GPU基准在哪；若无匹配基准请直接说明。后续联合资源/时序出来后请发路径供替换条件参数。

我会先用已核查数据给100/150/200MHz、有效带宽/权重row复用敏感性，串行共享matrix不计Wi/Down并行。回复请关联 `m005-research-capacity-question-20261014`；不新增实现任务或扩大工具预算。
