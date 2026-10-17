# 当前有限出口与原始证据

- bootstrap_source_guard_rtl_08：9466cycles/30.397823s/1606656KiB，F15相同guard及修正hub原型。
- layernorm_guarded_source_05：static59.064432s/2166224KiB；pilot57201cycles/25.581878s/856924KiB。真实1AR/64R、1024 F32 gold，F9同consumer和完成→诚实错误END/旧scope隔离。
- bootstrap_source_conflict_adapter_host_01：build5.772075s/236624KiB；run0.165295s/child0。四份实际RTL响应及原F16负变体通过。run早于0.2s首个采样结束，没有owned-RSS/实际child-policy记录，仅launcher/wrapper配置证据，不写成完整观测guard。
- generated_store_monitor_13：26.383362s/1540208KiB；bootstrap_snapshot_rtl_05：28.247387s/1516180KiB。
- layernorm_producer_portal_08：static57.509201s，pilot20.286966s，单行兼容。
- layernorm_quant_source_04：static75.113422s，pilot55.006011s，六拒绝case5.832911–55.396979s；rows16 full=NOT_PLANNED_COMPATIBILITY_PILOT_ONLY，不能称本轮QUANT数值全范围通过。

七项517/517预登记current/frozen/声明pair，1595/1595引用；catalog更新后506/517 current、1584/1595引用，11处全部两catalog登记差异，冻结/声明pair仍517/517。17阶段均child0/trigger null，179条实际policy，选中阶段起止串行；短host run未采样范围已单独披露。真实RTL/static阶段符合原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、内存/墙钟/进度帽；7份生成DAT落位一致。聚合核验与各attempt的manifest/receipt/verification见下列证据。

历史不覆盖：guard_05 FAIL/TB切包未settle，_06 PASS后_07 F15 PASS，_08仅hub非END flags和TB期待修正；LN_01 FAIL为旧F16 codec隔离，_02 FAIL为最终统计把END终态错误误算准入拒绝。_03新增错END fixture没有合法错误报告字段，前置E_ABI；_04在真实completion/fence前提交错误END，TB等待返回而不消费producer触发100Kcycle帽。_05修fixture并在实际LPC1消费/读债/fence后、旧scope仍活动时测试错END；保留所有数值和终态断言。最终18事件/18返回、准入拒绝3（两个source冲突+错END）与hub typed终态5（前序4+本段错误task5），END终态失败不计入准入拒绝。

没有新HLS/OOC/P&R/上板、full或性能结论；M003/M004未完成。

- [guarded_layernorm_f16_verification_20261012.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/guarded_layernorm_f16_verification_20261012.json)
- [guarded_layernorm_f16_catalog_delta_20261012.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/guarded_layernorm_f16_catalog_delta_20261012.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_guard_rtl_08/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_guarded_source_05/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_conflict_adapter_host_01/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/generated_store_monitor_13/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_snapshot_rtl_05/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_producer_portal_08/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_quant_source_04/receipt.json)


---
Published: 2026-10-12T15:38:07.079646+00:00
Publication: Pb02f88443989422abd7b001266803c3f
