# E004：首段结果

**软件限定PASS**：[project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md)。AT091当前E002 g++ host全图B1/S128正常请求，47项/4,523,596个F32逐字节等于原独立gold，18,887任务、962 QUANT；actual final18/32KiB IO留存。运行216.712s、峰640172KiB，guard child0/null；全部4次构建＋2次完整请求累计463.241s。首例AT089数值比较全到但旧B1 stateful Attention路径断言失败；第二次AT091显式软件CPU叶子QK/SM/AV各61440、状态服务命令0，故本PASS不包含Attention RTL。源码编译闭包95项；模型/请求/raw及47 oracle SHA留存。硬件完整推理、独立反压、II、资源、频率及加速比NOT_RUN。接点表：[project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_minimal_reuse_contacts_20261014.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_minimal_reuse_contacts_20261014.md)。


---
Published: 2026-10-14T14:39:25.496357+00:00
Publication: P1dba0f8fd62c49f093870bec35716eb3
