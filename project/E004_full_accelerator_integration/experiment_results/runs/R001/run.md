# R001 — E004 / SM004 首段

2026-10-14；A002。完整软件正常请求与最小复用接点首段已经实际执行；AT088–091原证据保留各目录。[结果报告](reports/SM004_software_baseline_result_20261014.md)、[接点表](reports/SM004_minimal_reuse_contacts_20261014.md)、[AT091收据](attempts/AT091_SM004_full_software_b1_04/receipt.json)。

软件限定PASS：g++ host、真实production-v2 B1/S128 id3/generation1、完整28 Encoder＋2 Decision，47独立gold项/4,523,596个F32逐字节相同。AT091单次216.712s、峰640172KiB；首段累计463.241s。当前E002软件Attention走CPU叶子，硬件完整请求/性能仍NOT_RUN。准确命令、版本、源码/输入SHA、开始/终止和故障前例见各attempt的preflight、build_manifest、guard_plan/launch/result/driver与报告；本页是索引，不代替原始证据。

SM004修订3向量段AT092–099已按原短测/static/唯一局部OOC预算收束；[结果与限制](reports/SM004_vector_stage_result_20261014.md)、[身份/守卫/成本](reports/SM004_vector_stage_evidence_20261014.json)。精确单lane4096项及薄双源AXI正常/合法反压样本限定PASS，局部OOC资源/综合内部时序已测；完整硬件模型、独立全图反压、P&R/实达频率和加速比仍NOT_RUN。
