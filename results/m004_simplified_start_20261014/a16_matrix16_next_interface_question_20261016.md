# 首A16保持之后：现生产接口上的MATRIX16最小增量

2026-10-16；A001→A003；M004/SM004。工程修订21继续受影响控制短例，不等待本研究。AT368已在同runtime真实LN128→冷W→STATE1首16行Q→A16_HELD，前4行独立Q/scale、全16行真实输入与叶子输出到4352字bank映射通过；父top仅row0，core真实exec100局部回执已测。上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…；以AT368冻结为准，父engine以AT367/372冻结为准。

请复用原架构的STEP16/TN8/四block方案，只核对现端口落地所需的静态增量，准备下一段正式合同。不要提出替代路线，不改工程：

1. A16_HELD和真实W READY如何进入唯一现front的MATRIX16，真实W lease/read/release与A source/a_epoch怎样绑定；哪些必要控制尚在父engine，如何让独立生产层与父top调用同一个实际实现且不复制W cache、bank、FP或矩阵算术。
2. 固定rows16/K1024/N3072的STEP16入口，TN8→四block→32group及PS retirement、同步A读取所需新增寄存器/端口，沿原容量预算给精确最小变化。明确首TN8完整16行的可测出口与全N父任务之间的关系；不得把缩小描述符或TB自行排序当完整父任务。
3. W已READY不等于lease或实际matrix取W已验。按现实际生产连接给一组最小合法A/W/PS事务与原数值错误排序反例；store错误后继续原任务算术检查、最后返回store错误的规则怎样落实，不取已观察min绕过尚未执行的旧优先窗口。
4. 对首4行已有Q/六字段PS/pre-QKV独立参考，给固定N窗口/行/group索引绑定与剩余12行证据缺口。只复用原保存文件及已核SHA，不求值新gold或把叶子观察值当独立oracle。

交付一个可实施的有界后继建议，主例/局部pilot范围由真实接口决定，工程预算与启动门由A001另定。原修订21工程不暂停，也不把所有未测旧控制排列设为矩阵推进前置。完整父图同runtime、后7个A16窗口、RoPE/FINAL/整模及物理结论仍开放。

只追加原fixed_graph_architecture及小支持记录，写入范围仍为source。只读脚本单次≤20s/1GiB、累计静态处理≤60s，CPU0–3/nice19/idle；交互UNKNOWN。无EDA/profile/HLS/OOC/P&R/模型/新gold/新agent。无需确认收信，具体增量直接回复A001。
