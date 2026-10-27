

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# M007 · 完整Attention高性能主干与部署闭合

[任务合同](contract.md) · [任务总结](../../results/missions/M007_summary.md)

## 执行子任务与主控审核

| 子任务 | 定义 | 完整审核历史 |
| --- | --- | --- |
| SM008 · 严格浮点叶子修复与共享FP接入 | [定义](tasks/SM008.md) | [审核](../../results/reviews/SM008.md) |
| SM009 · Host边界与CPU尾部严格适配 | [定义](tasks/SM009.md) | [审核](../../results/reviews/SM009.md) |
| SM010 · 高性能矩阵供数与恢复闭合 | [定义](tasks/SM010.md) | [审核](../../results/reviews/SM010.md) |
| SM011 · 完整Attention与驻留主干集成 | [定义](tasks/SM011.md) | [审核](../../results/reviews/SM011.md) |
| SM012 · 联合物理与完整请求验收 | [定义](tasks/SM012.md) | [审核](../../results/reviews/SM012.md) |

## 关联实验

- [E008 · m007_strict_fp_shared_service](../../project/E008_m007_strict_fp_shared_service/README.md) — 未登记
- [E009 · m007_host_tail_contract](../../project/E009_m007_host_tail_contract/README.md) — 未登记
- [E010 · m007_attention_bank_qk_av](../../project/E010_m007_attention_bank_qk_av/README.md) — 未登记
- [E011 · m007_weight_supply](../../project/E011_m007_weight_supply/README.md) — 未登记
- [E012 · m007_matrix_compute](../../project/E012_m007_matrix_compute/README.md) — completed
- [E013 · m007_quant_group32](../../project/E013_m007_quant_group32/README.md) — 未登记
- [E014 · m007_layernorm32](../../project/E014_m007_layernorm32/README.md) — 未登记
- [E015 · m007_tanh_geglu8](../../project/E015_m007_tanh_geglu8/README.md) — 未登记
- [E016 · m007_single_resource_parent](../../project/E016_m007_single_resource_parent/README.md) — completed
- [E017 · m007_sfu_resource_closure](../../project/E017_m007_sfu_resource_closure/README.md) — completed
- [E018 · m007_control_workspace_joint](../../project/E018_m007_control_workspace_joint/README.md) — completed
- [E019 · m007_residual_ln_residency](../../project/E019_m007_residual_ln_residency/README.md) — completed
- [E020 · m007_model_catalog](../../project/E020_m007_model_catalog/README.md) — 未登记
- [E021 · m007_compiled_rtl_validation](../../project/E021_m007_compiled_rtl_validation/README.md) — completed
- [E022 · m007_full_top_physical](../../project/E022_m007_full_top_physical/README.md) — blocked

## 任务总结原文摘录

# 当前结果：修复版完整30层一次运行通过，项目暂停

updated: 2026-10-25（北京时间）
execution_state: paused
verdict: unassessed

主控增量128已接纳D37/E021 R005完整正常路径：正式参数0，从原embedding_norm开始，一次BEGIN连续计算28 Encoder、final LN/type、2 Decision和544组尾输出。13036119周期，RTL仿真10101.230975秒（2小时48分21秒）；原完整终标、实际尾部提交、heldDONE消费和idle全部通过。

主控独立核全部30层真实H及唯一采集trace、finalLN/type和69632B输出对原参考逐字一致；实际120矩阵/480head/60LN/61VECTOR/28GEGLU、两FC1各16384写/ACK/发布后才FC2。3200执行身份无失配，2262已知进程身份无存活/僵尸；2个瞬态policy样本保留UNKNOWN。22份费用收据复算static372.653189/1800s、RTL10101.230975/15600s；另2次失败准备耗时UNKNOWN、保守预留240s，余额封存不转。

本次证明修复版完整硬件主干在该原始请求上的RTL正常路径功能；未验所有异常/复位或四态行为，也未验联合物理时序、上板和实际吞吐。D35原FAIL及D36分段PASS保留。按用户要求完成核验归档后暂停，不启动后继。

[主控独立终审](../../results/reviews/m007_fixed30_final_review_20261024.json) · [工程最终收据](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/final_fixed_original30_receipt.json)

## 相关决定、变更与讨论

- [overview](../../results/overview.md)
- [review_queue](../../results/review_queue.md)
- [C059 · M006硬件恢复派发：完整板端Attention首段](../../communication/C059_M006%E7%A1%AC%E4%BB%B6%E6%81%A2%E5%A4%8D%E6%B4%BE%E5%8F%91%EF%BC%9A%E5%AE%8C%E6%95%B4%E6%9D%BF%E7%AB%AFAttention%E9%A6%96%E6%AE%B5/thread.md)
- [C060 · SM007共享FP对QK/AV数据依赖的接口问题](../../communication/C060_SM007%E5%85%B1%E4%BA%ABFP%E5%AF%B9QK_AV%E6%95%B0%E6%8D%AE%E4%BE%9D%E8%B5%96%E7%9A%84%E6%8E%A5%E5%8F%A3%E9%97%AE%E9%A2%98/thread.md)
- [C061 · SM007严格TANH现有模块与160拍帽的静态冲突](../../communication/C061_SM007%E4%B8%A5%E6%A0%BCTANH%E7%8E%B0%E6%9C%89%E6%A8%A1%E5%9D%97%E4%B8%8E160%E6%8B%8D%E5%B8%BD%E7%9A%84%E9%9D%99%E6%80%81%E5%86%B2%E7%AA%81/thread.md)
- [C062 · SM007 AT015–019：直接 F32 除法单 lane 证据](../../communication/C062_SM007%20AT015%E2%80%93019%EF%BC%9A%E7%9B%B4%E6%8E%A5%20F32%20%E9%99%A4%E6%B3%95%E5%8D%95%20lane%20%E8%AF%81%E6%8D%AE/thread.md)
- [C063 · SM007：8拍加法IP的次正规反例](../../communication/C063_SM007%EF%BC%9A8%E6%8B%8D%E5%8A%A0%E6%B3%95IP%E7%9A%84%E6%AC%A1%E6%AD%A3%E8%A7%84%E5%8F%8D%E4%BE%8B/thread.md)
- [C064 · 用户暂停M006工程](../../communication/C064_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9CM006%E5%B7%A5%E7%A8%8B/thread.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
