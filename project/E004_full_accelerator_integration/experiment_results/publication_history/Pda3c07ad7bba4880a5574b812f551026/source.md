# E004：完整软件基线与固定图最小复用接点

M004/SM004；A002唯一E002实现和工具owner。现阶段用当前E002/experiment的g++软件 `full_execute_cpu_request` 执行真实production-v2 B1/S128 id3/generation1一次正常全模型请求，原模型包、raw输入和47项独立gold不变；按46中间＋final18逐字节比较，记录完整输出、服务路径、资源和源码/输入SHA。历史四请求软件338.283s/峰630752KiB及构建10.278s作成本准入，不当本次实测。首段累计host≤1800s/16GiB、单次≤900s、同用例最多两次；CPU0–3/nice19/idle，MemAvailable>192GiB，单重工具。当前不运行EDA/GPU/参考gold生成。最小复用接点见R001报告。硬件完整请求、联合资源/时序和加速比仍为后段目标。


---
Published: 2026-10-14T14:39:25.496357+00:00
Publication: P1dba0f8fd62c49f093870bec35716eb3
