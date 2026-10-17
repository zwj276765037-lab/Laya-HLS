# E003：当前生产链接入与回归

M003/SM003，工程A002；为M004完整加速器总任务的前置阶段。唯一代码根为project/E002_Laya_HLS/experiment。E003保存新方案与证据；原baseline和E002验收快照保持历史身份。

使用验收绑定的真实GGUF/五BO、原四请求和独立gold，数值与完整shape/层数不变。按[协议](protocol.md)连续落实L0当前依赖、L1 §3.9私有FIFO/单服务/13BO、L2真实Wi→G→quant→Down、L3安全退休/恢复、稳定最终身份后的L4完整CPU/真实CSim与受影响RTL、L5交付。

[R002准备](../experiment_results/runs/R002/run.md)已完成真实依赖提取：完整请求闭包57项（56源码＋1包header），全构建目标61项。当前compiler/config/module/IP/XDC库存与输入/reference审计、新路径计划已冻结；L0实际生产生成闭包和最终build绑定尚待补齐。旧回归不能覆盖当前7项源码内容变化。

准备和后续实验继承单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；CPU/CSim仍16GiB/1800s，static24GiB/1800s，RTL8GiB/3600s/40Mcycles且120s pilot。本M无新增OOC，G余2338.224019s保留。模块/整图/物理/板端及实际与预测性能分开记录。


---
Published: 2026-10-11T08:13:46.070272+00:00
Publication: Pf0666919935040a7bd4e92f9f4dc8dbb
