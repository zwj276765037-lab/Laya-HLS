# M003：真实 LayerNorm generated master→monitor/hub→source lease 出口

A002交付 `layernorm_producer_portal_06`，限定 PASS_SCOPED_RTL。同一runtime真实生成 gamma0 LN_ATTN、D1024、rows16 producer，从实际 checkpoint 前16行计算，经 STATE0 AXI→monitor/唯一hub，PUBLISH 一个诚实 rows16 诊断 owner，然后全身份 source query/原子lease取得、释放与owner清理。

static 55.061775s/2077580KiB；rows1 pilot 47267cycles、20.786439s/856556KiB；完整rows16 655511cycles、245.157115s/856796KiB。三guard child0/trigger null，真实policy符合CPU0–3/nice19/idle I/O/MemAvailable>192GiB。source AR/R=16/1024，destination AW/W/B=16/1024/16，真实有效WSTRB65536B；八拍completion携helper实际store/source各65536B。16384项独立binary32 adjacent-tree LayerNorm gold逐位通过。BEGIN完整响应消费前无producer外发；提前END到末B与完整completion/fence前无终态返回；source lease取得和释放、最终owner/debt归零有断言。

成本由本次同层级no-wave pilot实速2273.934517cycles/s、冻结16行工作量与按行参考756272cycles×1.5在full前决定，投影499s并实际准入。参考不是已证明的完整周期上界或硬件性能；full实耗见上。保留原3600s/8GiB/120s进展保护，TB更严格5Mcycle帽。

修复链 `_01.._05` 均保留原FAIL终态：DAT运行目录缺失、engine与SV包不同build tag、rows16 pilot超120s，以及source-query TB驱动/采样竞态。_05→_06共同112项闭包只有TB改变，gold/完整16行/DUT未变。_04的rows1 query没有单独重验，此前白名单归因依据不足，现按采样问题限定记录。canonical SV包从实际所选C头产生；C头与engine生成时冻结头逐字节一致。每个ROM DAT原样从冻结副本落位并核SHA。

身份核查382/382引用，112/112 current、frozen、pair一致，三个guard策略/预算、current-pilot成本和canonical包一致：
- manifest `83aa4a3446f0886dd72be6ea3b675b2346d853a96d06139f5c8a9e3a417b48d9`
- receipt `7b7347fc6f8f5e81b06ce8330430c938889318f5671d0de57672b138dd807ded`
- `layernorm_producer_portal_verification_20261012.json` `f4baaafdd5ec9d0efd75e64b7b0056d6addce6718a28390a9e31e642d9eadca7`

路径均在 `project/E003_production_chain_closure/experiment_results/runs/R003`；源码与实施说明在 E002/experiment 的 tm1tn8_gs32_512/rtl、tb、source/design.md、source/results.md。registry已经登记该shell闭包；partition保持integration_under_test，因完整生产仍未完。

边界：caller请求和提前END由TB构造；END先声明冻结成功提交量，终态再核真实completion一致，尚未签生产caller从completion构造END。producer AP-FIFO端口由TB驱动/backpressure，不能代签真实sequencer/adapter depth2整链。source query/lease尚未接真实QUANT消费者，无QUANT/fullA数值运行。该owner仅16行，不是全S64/S128发布；多window/owner/role/QKV、活动取消/故障/旧返回恢复、LOAD/MATRIX、最终13BO top及完整请求尚待。

三摘要已原生发布 `Pc12e05ded50b47cbb482ec55b17aabad`，A002已report当前出口及下一步。继续真实LayerNorm输出→共享Q/fullA及completion→生产END，streaming adapter和多窗口/取消回归按原授权推进。此次仅本LayerNorm runner使用current pilot成本，旧gate_split runner成本修复仍需落实；5172s组合profile不重启。

不请求新增审批，不关闭C008/C009/C010整体；C012及F6/F7/F8旧限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。无新OOC/P&R/上板或agent，G OOC余2338.224019s不变。
