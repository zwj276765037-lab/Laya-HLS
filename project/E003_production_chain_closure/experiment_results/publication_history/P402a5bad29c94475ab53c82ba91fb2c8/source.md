# F16实际返回语义与有限真实guarded LayerNorm接线

M003/SM003/E003/R003，沿生产分区§8与D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01；回复bootstrap-source-guard-f15-review-20261012。F15已由主控在_07受控原型范围关闭，本轮_08保留同一guard并修正hub非END冲突返回scope映射，申请F16按实际decoder/adapter及有限RTL范围核验。C009和完整生产source保护仍未关闭。

实际hub来源通过正常CLAIM、四个BEGIN→真实monitor AW/W/B→END、PUBLISH建立B1/S64完整HIDDEN checkpoint，64AW/4096W/64B、262144B。memory初始未知，仅实际W写入，冻结16行数值输入重复到64行；这是受控encoder_00_out前序，不是实际encoder计算。唯一固定STATE0内的前序writer与实际生成LN writer共用同一monitor/hub/物理写口，guard期间前序writer无AW/W准入；LN真实AR的memory VALID与engine READY使用同一allowed门控。base/epoch/capacity捕获并持续比较，证明只限已接入的两个writer和单base，全部13BO生命周期及旁路未闭合。

LN_05实际使用既有layernorm_producer_hls_01相同生成RTL/7DAT，完整F9请求/完成验证、同一真实depth2 LPC1 consumer末2/末1拍各停12周期；producer job/fence保持到真实最后消费。1AR/64R、4096B，1024 F32 gold逐字比较。真实LPC1字段构造END；完整64行target只提交1行，诚实返回短窗口E_PROTOCOL，hub task5终态恰一次并INVALIDATE。LAC1安全错误来自受控byte fixture，其真实depth2 consumer末2/末1拍门控后释放guard，不是生成executor报告或完整action成功。

F16修复保持原codec/layout：非END冲突返回E_BUFFER、drained0、scope0，内部旧scope仍保持；错误END可报告scope1。LN_05实际采集18份完整LPV request/response（36文件）。host_01读取其中idle冲突、活动scope非END冲突、错误END及匹配短窗口终态END四对，现C++ provenance decoder逐字roundtrip，真实C++ transaction adapter逐字外发并核LTC1绑定/终态。错END为drained1/scope1，保持非终态；短窗口END为drained1/scope0、安全错误。原F16非END scope1变体在decoder/adapter均隔离，零可信后继完成。没有放宽codec或清旧scope迎合测试。

默认guard禁用兼容：monitor_13保持旧部分失败/末B/cancel/恢复fixture；snapshot_05保持F14持续valid仲裁；LN portal_08为单行pilot；LN→Q_04为单行pilot及全部六F9拒绝case，rows16 full未启动，旧_03完整LN→Q/fullA gold仍只按原冻结身份复用。


---
Published: 2026-10-12T15:38:07.079646+00:00
Publication: Pb02f88443989422abd7b001266803c3f
