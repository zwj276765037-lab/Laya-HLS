# E004：限定结果

软件基线AT091仍为g++ host全图B1/S128单正常请求：47项/4,523,596 F32逐字节等于独立gold，运行216.712s；当前软件Attention采用CPU QK/SM/AV各61440次，不是RTL PASS。

新向量结果见[SM004结果报告](../experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md)及[机读证据](../experiment_results/runs/R001/reports/SM004_vector_stage_evidence_20261014.json)：CE ADD每拍接受原52组directed、逐bit52/52，暂停3拍保持、复位对照PASS；旧FSM FADD固定零刺激`ap_ready`间隔3拍。单lane真实4096对gold正常4103cycle、确定性反压6444cycle、峰32、16项在途局部reset后无ghost。薄AXI服务同样4096对gold及64KiB目标窗口保护PASS；normal6928cycle、R/W/B等待7185cycle，每次2AR/512R/1AW/256W/1B＝49152B，压力样本W阻塞256cycle并保持DATA/LAST，末B后done保持5拍。局部OOC实际1283LUT/614FF、DSP/BRAM/URAM0、blackbox0，6.667ns请求下内部WNS+3.057ns；不是P&R Fmax。受守卫static/RTL/OOC累计36.409680/28.104722/78.220358s，触发均null。完整硬件图功能、跨层存储与性能、加速比仍NOT_RUN。

---
Published: 2026-10-14T15:15:37.235968+00:00
Publication: P450d2ef0e98242728634382e683b0447
