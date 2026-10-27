# E022 当前实际结果与边界

AT019 同源策略综合仍在运行：原 f849/91源与ROM、父9d877217/11generic、U55C/OOC/PROFILE0/flatten none、完整dot/format子树、300MHz XDC保持。仅core增加-no_timing_driven，未改RTL或应用PS候选。实际日志L281完成RTL Elaboration（工具elapsed00:33:32），L290完成RTL Optimization Phase1（00:33:38）。截至 2026-10-26T00:03:32.235332+00:00，综合仍未返回，没有core DCP或最终映射资源；当前owned RSS 33459036KiB、CPU ticks 223232、trigger null，不能据此推断完成比例或剩余时间。

当前无墙钟监督于23:44:46.737830 UTC实际生效，deadline=null；原Vivado3583093/start66052106、原leader3583000/start66052093保持，source_identity/原command SHA未变，原父guard单PID暂停保留锁。物理synthesis/implementation/reports单次/累计时间均显式禁用，历史费用/帽/收据保持；256GiB RSS、系统余量、CPU政策、单锁和300s真实进展保护不变。10/10真实小进程监督测试PASS只验证基础设施，包括越原帽和finally异常，不是硬件结果。

AT015历史COST_STOP21601.398908304s、峰110.976433GiB、最低可用343.694820GiB；完成Area/XDC后停留Timing Optimization直到6h，无DCP。其原FAIL/-9和verified effective分类/完整cleanup审计保留。原D37完整30层正常路径功能PASS与局部四态表示等价证据按原适用范围保留，未重新运行或扩大覆盖。

主控按用户授权仅删除已结束AT002/003/015的153个可重建.rtd/.tim缓存，释放4.14223GiB，其余358份旧文件SHA未变；AT019/共享输入/DCP及有效证据保持。串行continuation3603650/start66216629仅等待实际core PASS与真实DCP/cleanup/锁释放，尚未启动下个重工具，attempt数19。后续真实装配、完整资源和原300MHz布局布线/STA仍待执行；跳过综合内部时序驱动优化不能签最终时序。

新增实际阶段结果：vivado.log L327完成RTL Optimization Phase2（工具elapsed01:17:00、CPU01:12:51）。2026-10-26T00:47:36.890018+00:00采样：elapsed 4781.907881498337s、owned RSS 108934288KiB、MemAvailable 379526388KiB、CPUticks 507402、trigger null。原Vivado3583093/start66052106及各监督/等待器PID/start已再次核实存活，原guard仍T并持锁。当前owned9个进程，仍是同一Vivado综合调用，没有新重工具。尚无core DCP或最终映射资源。

---
Published: 2026-10-26T00:47:37.560606+00:00
Publication: P93d4a37940eb4a9b97fad0efe8f1b4fe
