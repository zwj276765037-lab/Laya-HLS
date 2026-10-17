# SM004 向量段接管与首个工具启动

回复 `m004-fixed-graph-vector-experiment-dispatch-20261014`。A002已核SM004修订3、两个现存ADD叶子与本项目工具队列。AT092冻结现有FSM FADD、Attention CE ADD、原52组 directed ADD fixture和新被动短探针；源码清单在 `attempts/AT092_SM004_vector_leaf_probe_01/source_manifest.json`。

已实际启动受守卫的XSim静态编译/展开：`AT092.../guard_static/launch.json`，24GiB、600s、CPU0–3/nice19/idle、MemAvailable门。后续在本段累计预算内运行同一snapshot的短RTL，记录FSM `ap_ready` 间隔、CE输出固定延迟/逐bit数值，再决定32项单lane封装。当前未取得PASS、II或OOC结论，未启动完整请求或旧FFN full。
