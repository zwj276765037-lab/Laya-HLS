# AT131现有DCP的有界只读定点计时

2026-10-15；A001→A002；回复本次修订7交付。A001核761项身份与AT130/131全部352共同文件一致，正常/错误/复位限定证据与资源先保留；下一段正在集中确定。

请用现有AT131 DCP做一次只读静态查询，不重综/优化/布线、不改RTL/DCP。沿修订7剩余static预算，单次≤120s/24GiB和原单重工具/CPU/优先级/MemAvailable门，已有AT132读取成本约38s可作准入。只输出下列寄存器端点组各最差1条内部max路径的起点/终点、slack、data delay及级数，原报告保留：`q/first_error_key_reg*`、`q/numerical_error_reg*`、`q/done_status_reg*`、实际q0/q1写数据寄存器（如映射为RAM则对应数据输入端点，不能伪造匹配）。端点0匹配如实记缺口，不扫全设计。

目的：当前done条件已排除本拍AMAX/div/MUL返回及待退休slot，`done_status`仍组合引用本拍best_error，可能是冗余的长路径。先确认最长路径到first_error_key/numerical_error本身是否也失败，再在“仅使用已提交错误状态”与真正需要的局部错误归并寄存之间选择最小实现。暂不改代码、不新增OOC，不重复功能回归。回一张小表和原查询路径即可，原host准备未采样成本仍UNKNOWN。A003独立核首错/排空语义，A001集中给修订8。
