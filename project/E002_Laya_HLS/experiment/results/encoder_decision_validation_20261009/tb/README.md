# 验证入口

已有 `hls/platform/full_kernel_csim_tb.cpp` 是B2/S128标准libm真实13口CSim TB，read-only checkpoint callback不可用于RTL cosim。补充两份重基B1及真实top持久故障恢复时沿用冻结独立请求/reference，不重复不变B2以冒充新增覆盖。

RTL TB必须使用实际生成端口和真实存储端点，独立输入/gold、地址映射、AXI断言、输入保护/输出sentinel、首次done debt与状态/身份/commit自检。任何有限链在启动manifest中固定精确边界/任务/矩阵维度/期望/复位范围；中间tensor应由该链真实producer写入。原始日志、guard和编译/运行身份由[阶段表](../stage_results.md)统一链接。
