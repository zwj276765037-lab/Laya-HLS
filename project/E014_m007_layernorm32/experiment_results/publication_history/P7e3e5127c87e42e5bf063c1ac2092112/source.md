# E014：LN-COMPACT-22 实验依据摘要

当前任务为 M007 / SM011 / D-M007-SM011-LN-COMPACT-22，独立批次 R002；R001 LN-05 的来源、输入、结果及失败记录原路径冻结。

本段在唯一 E002 实现中保留默认任意96bit tag，新增显式 canonical/external q-next 分支。Canonical tag 按身份、row、chunk重建；ADD64项metadata由176压到146bit，信用仍64；scalar局部标签3/2bit，外部模式全部控制读12288bit q、写next，无私有影子。Gamma132bit持久控制和18055bit数值状态保留。

正常已测版本为 core c612633a…1265、wrapper398d6f1e…304c、external scalars af9fe387…f382，layout v2为12120bit/168bit备用；精确身份见 [normal checkpoint](../experiment_results/runs/R002/normal_checkpoint_v1.json)。准备中的v3只补8bit blocked-offer保持状态，至12128bit/160bit备用，旧offset与公开端口不变；prepared core ab776938…0155尚未编译/测试。[v3接口](ln_compact_interface_v3.md)明确版本边界。

正常输入复用R001 AT001原encoder00/plain、encoder27/原final_norm_w和保存gold，原两棵10级相邻树、独立F32算术及完整中间checker不改。真实测试壳恰一sharedFP256、DIV8与32KiB LN-exp银行；q寄存器由TB拥有，因此只证明PURE_EXTERNAL_CONTROL_UNIT，不证明真实arena/父图fit或真实producer有限资格。

验收保持first≤448、rowII≤128、完整128行实际DONE退休≤16704拍；完整核131072最终F32、261888树节点及全部统计/中间和真实bank数据。协议需真实held reject、matching cancel、实际债排空、held terminal后无reset新gen恢复。完整CPU首错必须按tile/class/row/check/sub/element；当前仍为legacy物理先到/global stop，完整排序和source-summary仲裁未实现，不迁移正常PASS。

R002独立reference60/static600/RTL1200/OOC0秒；CPU0–3/nice19/idle、MemAvailable>192GiB、shared heavy lock、owned进程身份/资源保护与120s真实检查消费停滞帽保持。AT001..008采用guard_v1，只测leader策略，descendant策略UNKNOWN；未来guard_v2已准备逐owned PID/start_ticks采样/校正/留证，但未启动。模型请求gpt-6.1-sol/xhigh，实际运行配置未独立核实。


---
Published: 2026-10-23T02:51:25.135799+00:00
Publication: Pfacfa492de204cb7b46430a9c36742fc
